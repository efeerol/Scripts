-- Karthus The Omega v0.1 - by Dasia

print = printtext

-- Debug --
local debugging = true

-- Hotkeys --
local hotkeyFarm = 65 -- A
local hotkeyRange = 112 -- F1
local hotkeyMonitor = 113 -- F2
local hotkeyBeep = 114 -- F3
local hotkeyAutoR = 115 -- F4
-- trigonometry = 10
-- UI --
local position = { x = 100, y = 200 }
local offset = { x = 0, y = 0 }
local moving = false

-- Internal Config --
local minionRadius = 70

local spellQRadius = 140
local spellQRange = 875
local spellWRange = 0
local spellERange = 0
local baseRegen = 0.8 -- per second

-- Internal Vars --
local myHero = GetSelf()
local dead = false
local deadTimer = 0
local regenTimer = 0

local enemyHeroes = {}
local allyHeroes = {}

local enemyMinions = {}
local allyMinions = {}

local bestMinion = nil
local minionDamage = 0

local showMonitor = true
local showMonitorPressed = false

local showRange = true
local showRangePressed = false

local farm = false
local farmPressed = false
local farmHitSpot = { x = 0, y = 0, z = 0, single = 0 }
local farmMultiHit = {}

local beep = true
local beepPressed = false
local beepFrequency = 4 -- seconds
local beepTimer = 0

local autoR = false
local autoRPressed = false
local autoRSafeRange = 900
local autoRSafeCount = 2
local autoRHeroes = {}

for i = 1, objManager:GetMaxHeroes(), 1 do
    local player = objManager:GetHero(i)
    if player and player ~= nil and player.team ~= myHero.team then
        local object = { hero = object, name = object.name, health = object.health, maxHealth = object.maxHealth, seen = GetClock(), fresh = false, fade = 0 }
        table.insert(enemyHeroes, object)
    end
end

function OnTick()

    -- handle toggles
    UpdateToggles()

    -- handle unit/player discovery
    UpdateTables()

    -- death timer
    if dead == false and myHero.dead == 1 then
        dead = true
        deadTimer = GetClock()
        PrintDebug("Death timer started!")
    elseif dead == true and myHero.dead == 0 then
        dead = false
        PrintDebug("Death timer ended (Total: " .. tostring((GetClock() - deadTimer) / 1000) .. " sec)")
    end

    -- remove unkillable auto ult heroes
    if autoR == true and #autoRHeroes > 0 then
        for i, player in ipairs(autoRHeroes) do
            if player == nil or player.hero == nil or (player.health + (baseRegen * 3)) > GetRDamage(player.hero) then
                PrintDebug("Removing auto ult enemy (" .. player.name .. ")")
                table.remove(autoRHeroes, i)
            end
        end
    end

    -- beep / auto ult
    for i, player in ipairs(enemyHeroes) do
        -- make sure player is valid
        if player == nil or player.hero == nil or player.name == nil or string.find(player.hero.name, player.name) == nil then
            PrintDebug("Removing enemy player (" .. player.name .. ")")
            table.remove(enemyHeroes, i)
        else
            -- update freshness and simulate regen
            if player.hero.visible == 1 then
                player.health = player.hero.health
                player.seen = GetClock()
                player.fresh = true
            else
                player.fresh = false
                --if player.maxHealth ~= 0 and player.health < player.maxHealth and (GetClock() - regenTimer) >= 500 then
                --    player.health = math.min((player.health + (baseRegen / 2)), player.maxHealth)
                --    regenTimer = GetClock()
                --end
            end
            -- make sure is alive
            if player.hero.dead ~= 1 and (beep == true or autoR == true) then

                if player.fresh == true and GetRDamage(player.hero) > (player.health + (baseRegen * 3)) then
                    -- auto beep
                    if beep and (GetClock() - beepTimer) >= (beepFrequency * 1000) then
                        PlaySound("Beep")
                        beepTimer = GetClock()
                    end

                    -- auto ult
                    if autoR and player.hero.invulnerable ~= 1 then

                        local autoRExists = false
                        for j, enemy in ipairs(autoRHeroes) do
                            if string.find(enemy.name, player.name) then autoRExists = true end
                        end
                        if autoRExists == false then
                            local object = { hero = player, name = player.name }
                            table.insert(autoRHeroes, object)
                        end

                        -- kill count reached
                        if #autoRHeroes >= autoRSafeCount then
                            local safe = true
                            for j, enemy in ipairs(enemyHeroes) do
                                if GetDistance(myHero, enemy.hero) < autoRSafeRange then safe = false end
                            end
                            -- safe, ult now!
                            if safe == true then CastSpellTarget('R', myHero) end
                        end
                    end
                end
            end
        end
    end

    if farm == true then
        -- find closest lowest hp minion
        for i, minion in ipairs(enemyMinions) do
            if minion == nil or minion.dead == 1 or minion.team == myHero.team then
                if minion == bestMinion then
                    bestMinion = nil
                    PrintDebug("Removing best minion (" .. i .. ")" .. minion.name)
                else
                    PrintDebug("Removing enemy minion " .. minion.name)
                end
                table.remove(enemyMinions, i)
            elseif minion.x == nil or minion.y == nil or minion.z == nil or minion.name == nil then
                if minion == bestMinion then
                    bestMinion = nil
                    PrintDebug("Removing invalid best minion")
                else
                    PrintDebug("Removing invalid enemy minion")
                end
                table.remove(enemyMinions, i)
            else
                local dist = GetDistance(myHero, minion)
                if dist < spellQRange then
                    if bestMinion == nil or bestMinion.dead == 1 or minion.health < bestMinion.health then
                        bestMinion = minion
                    end
                end
            end
        end
        -- found a minion to murder
        if bestMinion ~= nil then

            -- todo, create new health calc

            -- if multi then find best spot
            if CheckMultiHit(bestMinion) then
                FindHitSpot()
            else
                farmHitSpot.x = bestMinion.x;
                farmHitSpot.y = bestMinion.y;
                farmHitSpot.z = bestMinion.z;
                farmHitSpot.single = 1
            end

            -- calculate damage mode
            local spellQDamage = GetQDamage(bestMinion)
            local totalQDamage = spellQDamage + (spellQDamage * farmHitSpot.single) + minionDamage

            if totalQDamage >= bestMinion.health then
                if bestMinion.health <= minionDamage and GetDistance(myHero, bestMinion) <= spellERange then
                    -- todo E backup spell
                    CastSpellTarget('E', myHero)
                else
                    -- todo figure in basic movement prediction
                    CastSpellXYZ('Q', farmHitSpot.x, farmHitSpot.y, farmHitSpot.z)
                end
            end
        end
    end

    OnDraw()
end

function OnDraw()
    -- draw player range
    if showRange == true then
        DrawText("[" .. string.char(hotkeyRange) .. "] Show Range: On", 1170, 890, 0xFF00FF00)
        DrawCircleObject(myHero, 875, 4)
    else
        DrawText("[" .. string.char(hotkeyRange) .. "] Show Range: Off", 1170, 890, 0xFFFF0000)
    end
    -- health monitor
    if showMonitor == true then
        DrawText("[" .. string.char(hotkeyMonitor) .. "] Health Monitor: On", 1170, 910, 0xFF00FF00)
        DrawMonitor()
    else
        DrawText("[" .. string.char(hotkeyMonitor) .. "] Health Monitor: Off", 1170, 910, 0xFFFF0000)
    end
    -- draw auto farm
    if farm == true then
        DrawText("[" .. string.char(hotkeyFarm) .. "] Auto Farm: On", 1170, 930, 0xFF00FF00)
        if debugging == true then
            for i, minion in ipairs(enemyMinions) do
                if minion ~= bestMinion then
                    DrawCircle(minion.x, minion.y, minion.z, minionRadius, 2)
                elseif bestMinion ~= nil and minion == bestMinion then
                    DrawCircle(bestMinion.x, bestMinion.y, bestMinion.z, minionRadius, 5)
                    DrawCircle(farmHitSpot.x, farmHitSpot.y, farmHitSpot.z, spellQRadius, 1)
                end
            end
        end
    else
        DrawText("[" .. string.char(hotkeyFarm) .. "] Auto Farm: Off", 1170, 930, 0xFFFF0000)
    end

    -- auto beep
    if beep == true then
        DrawText("[" .. string.char(hotkeyBeep) .. "] Beep: On", 1170, 950, 0xFF00FF00)
    else
        DrawText("[" .. string.char(hotkeyBeep) .. "] Beep: Off", 1170, 950, 0xFFFF0000)
    end
    -- auto ult
    if autoR == true then
        DrawText("[" .. string.char(hotkeyAutoR) .. "] Auto Ult: On", 1170, 970, 0xFF00FF00)
    else
        DrawText("[" .. string.char(hotkeyAutoR) .. "] Auto Ult: Off", 1170, 970, 0xFFFF0000)
    end
end

function DrawMonitor()
    for i, player in ipairs(enemyHeroes) do
        local newY = position.y + (i * 20) - 20
        local enemyUltDmg = GetRDamage(player.hero)
        local enemyHpColor = GetHealthColor(player.health, player.hero.maxHealth)

        if player.hero.dead == 1 then
            enemyHpColor = 0xFFBFBFBF
        elseif player.health < enemyUltDmg then
            if player.fade > 6 then
                enemyHpColor = 0xFFFF0000
                if player.fade > 12 and (GetClock() - player.seen) < 10000 then
                    player.fade = 0
                end
            else enemyHpColor = 0xFFAD0000
            end
            player.fade = player.fade + 1
        end

        DrawText(player.name, position.x, newY, enemyHpColor)

        if player.hero.dead == 1 then
            DrawText("dead", position.x + 75, newY, enemyHpColor)
        else
            DrawText(string.format("%u", player.health), position.x + 75, newY, enemyHpColor)
        end

        DrawText("(" .. string.format("%u", enemyUltDmg) .. ")", position.x + 115, newY, enemyHpColor)

        if player.hero.visible == 0 and player.hero.dead ~= 1 then
            DrawText("mia " .. string.format("%u", (GetClock() - player.seen) / 1000) .. "s", position.x + 150, newY, enemyHpColor)
        end
    end

    if GetCursorX() > position.x - 50 and GetCursorX() < position.x + 200 and GetCursorY() > position.y - 50 and GetCursorY() < position.y + 200 then
        if moving then
            DrawText("@", position.x - 18, position.y, 0xFF72D8DB)
        else
            DrawText("@", position.x - 18, position.y, 0xFFDEFEFF)
        end
    end
end

function UpdateToggles()
    -- Show Range
    if IsKeyDown(hotkeyRange) == 1 then
        showRangePressed = true
    elseif showRangePressed == true then
        showRangePressed = false
        showRange = not showRange
        PrintDebug("Toggled show range (" .. tostring(showRange) .. ")")
    end
    -- Show Health Monitor
    if IsKeyDown(hotkeyMonitor) == 1 then
        showMonitorPressed = true
    elseif showMonitorPressed == true then
        showMonitorPressed = false
        showMonitor = not showMonitor
        PrintDebug("Toggled show monitor (" .. tostring(showMonitor) .. ")")
    end
    -- Auto Farm
    if IsKeyDown(hotkeyFarm) == 1 then
        farmPressed = true
    elseif farmPressed == true then
        farmPressed = false
        farm = not farm
        PrintDebug("Toggled auto farm (" .. tostring(farm) .. ")")
    end
    -- Auto Beep
    if IsKeyDown(hotkeyBeep) == 1 then
        beepPressed = true
    elseif beepPressed == true then
        beepPressed = false
        beep = not beep
        PrintDebug("Toggled auto beep (" .. tostring(beep) .. ")")
    end
    -- Auto Ult
    if IsKeyDown(hotkeyAutoR) == 1 then
        autoRPressed = true
    elseif autoRPressed == true then
        autoRPressed = false
        autoR = not autoR
        PrintDebug("Toggled auto ult (" .. tostring(autoR) .. ")")
    end
    -- UI
    if IsKeyDown(1) == 1 then
        if moving == true then
            position.x = GetCursorX() - offset.x
            position.y = GetCursorY() - offset.y
        else
            if GetCursorX() > position.x - 20 and GetCursorX() < position.x - 6 and GetCursorY() > position.y and GetCursorY() < position.y + 16 then
                offset.x = GetCursorX() - position.x
                offset.y = GetCursorY() - position.y
                moving = true
                PrintDebug("Started UI move (Pos: " .. math.floor(position.x) .. "," .. math.floor(position.y) .. " Off: " .. math.floor(offset.x) .. "," .. math.floor(offset.y) .. ")")
            end
        end
    else
        if moving == true then
            moving = false
            PrintDebug("Finished UI move (Pos: " .. math.floor(position.x) .. "," .. math.floor(position.y) .. ")")
        end
    end
end

function UpdateTables()
    -- insert new minions
    for i = 1, objManager:GetMaxNewObjects(), 1 do
        local object = objManager:GetNewObject(i)
        if object and object ~= nil and string.find(object.charName, "Minion_") then
            if object.team ~= 0 then
                if object.team ~= myHero.team then
                    table.insert(enemyMinions, object)
                    --PrintDebug("Inserting enemy minion "..object.name.." ("..object.charName..")")
                else
                    table.insert(allyMinions, object)
                    --PrintDebug("Inserting ally minion "..object.name.." ("..object.charName..")")
                end
            end
            if object.x == nil or object.y == nil or object.z == nil then
                PrintDebug("Object invalid x,y,z")
            end
        end
    end
    -- if tables are wrong then attempt update
    if #enemyHeroes ~= 5 or #allyHeroes ~= 5 then
        for i = 1, objManager:GetMaxHeroes(), 1 do
            local player = objManager:GetHero(i)
            if player and player ~= nil and player.team ~= 0 then
                -- check if player already exists
                local entry = nil
                if player.team ~= myHero.team then
                    for i, enemy in ipairs(enemyHeroes) do
                        if enemy and enemy ~= nil and string.find(enemy.name, player.name) then entry = enemy end
                    end
                else
                    for i, ally in ipairs(allyHeroes) do
                        if ally and ally ~= nil and string.find(ally.name, player.name) then entry = ally end
                    end
                end
                -- if found update, else insert new
                if entry == nil then
                    local object = { hero = player, name = player.name, health = player.health, maxHealth = player.maxHealth, seen = GetClock(), fresh = false, fade = 0 }
                    if player.team ~= myHero.team then
                        table.insert(enemyHeroes, object)
                        PrintDebug("Inserting enemy player " .. player.name)
                    else
                        table.insert(allyHeroes, object)
                        PrintDebug("Inserting ally player " .. player.name)
                    end
                elseif entry.hero.name ~= player.name then
                    entry.hero = player
                    PrintDebug("Upating hero " .. player.name)
                end
            end
        end
    end
end

-- TODO
function DoSpells()
    local a = { GetCastSpell() }
    local g = 0
    while (a[1] ~= nil and g < 200) do
        local spell = {}
        local startPos = {}
        local endPos = {}
        spell.name = a[2]
        startPos.x = a[3]
        startPos.y = a[4]
        startPos.z = a[5]
        endPos.x = a[6]
        endPos.y = a[7]
        endPos.z = a[8]
        spell.startPos = startPos
        spell.endPos = endPos

        -- handle

        a = { GetCastSpell() }
        g = g + 1
    end
end

function FindHitSpot()
    -- clean up non killables
    local areaMinions = {}
    for i, minion in ipairs(enemyMinions) do
        if minion ~= bestMinion and GetDistance(bestMinion, minion) <= (minionRadius + spellQRadius) then
            if minion.health <= GetQDamage(minion) then
                table.insert(areaMinions, minion)
            end
        end
    end
    -- multikill is better than single
    if #areaMinions > 0 then
        local totalSpace = { x = 0, y = 0, z = 0 }

        for m, minion in ipairs(areaMinions) do
            totalSpace.x = totalSpace.x + minion.x
            totalSpace.y = totalSpace.y + minion.y
            totalSpace.z = totalSpace.z + minion.z
        end
        -- hit right between them
        farmHitSpot.x = (totalSpace.x + bestMinion.x) / (#areaMinions + 1)
        farmHitSpot.y = (totalSpace.y + bestMinion.y) / (#areaMinions + 1)
        farmHitSpot.z = (totalSpace.z + bestMinion.z) / (#areaMinions + 1)
        farmHitSpot.single = 0
    else
        local spot = { x = 0, y = 0, z = 0 }
        local angle = 0
        local spotFound = false
        -- find a single hit spot
        for i = 0, 360, 10 do
            local rads = angle * (math.pi / 180)
            spot.x = bestMinion.x + spellQRadius * math.cos(rads)
            spot.y = bestMinion.y
            spot.z = bestMinion.z + spellQRadius * math.sin(rads)
            local spotClear = true
            if CheckMultiHit(spot) == false then
                farmHitSpot.x = spot.x
                farmHitSpot.y = spot.y
                farmHitSpot.z = spot.z
                farmHitSpot.single = 1
                spotFound = true
                --PrintDebug("FindHitSpot() Single spot found)")
                break
            end
            angle = angle - 10
        end
        -- couldn't find spot..
        if spotFound ~= true then
            farmHitSpot.x = bestMinion.x
            farmHitSpot.y = bestMinion.y
            farmHitSpot.z = bestMinion.z
            farmHitSpot.single = 0
            PrintDebug("FindHitSpot() Spot not found, using bestMinion center")
        end
    end
end

function CheckMultiHit(target)
    if target ~= nil and bestMinion ~= nil then
        if target.x ~= nil and target.z ~= nil then
            for i, minion in ipairs(enemyMinions) do
                if minion ~= bestMinion and GetDistance(target, minion) <= (minionRadius + spellQRadius) then
                    return true
                end
            end
        else PrintDebug("CheckMultiHit() invalid target. Expected x,z")
        end
    else PrintDebug("CheckMultiHit() target or bestMinion were nil")
    end
    return false
end

function GetQDamage(player)
    if GetSpellLevel('Q') < 1 then return 0
    else return CalcMagicDamage(player, (20 + (20 * GetSpellLevel('Q')) + (myHero.ap * 0.3)))
    end
end

function GetRDamage(player)
    if GetSpellLevel('R') < 1 then return 0
    else return CalcMagicDamage(player, (100 + (150 * GetSpellLevel('R')) + (player.ap * 0.6)))
    end
end

function GetDistance(o1, o2)
    if o1 and o2 and o1 ~= nil and o2 ~= nil then
        if o1.x == nil or o1.z == nil then
            PrintDebug("GetDistance() o1 nil x,y")
        elseif o2.x == nil or o2.z == nil then
            PrintDebug("GetDistance() o2 nil x,y")
        else
            return math.sqrt(math.pow(o1.x - o2.x, 2) + math.pow(o1.z - o2.z, 2))
        end
    end
end

function GetHealthColor(minHp, maxHp)
    local perc = minHp / maxHp * 100
    if perc >= 70 then return 0xFF33FF33 -- green
    elseif perc >= 30 then return 0xFFFFFF00 -- yellow
    elseif perc < 30 then return 0xFFFF9900 -- orange
    else return 0xFFFFFFFF
    end -- white
end

function PrintDebug(message)
    if debugging == true then printtext("Debug: " .. message .. "\n") end
end

SetTimerCallback("OnTick")
printtext("\nKarthus The Omega v0.1 - by Dasia\n")
if debugging == true then printtext("< Debug enabled! >\n") end