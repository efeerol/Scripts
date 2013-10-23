--[[
--    Script: IGER's Fully Automated Soraka Bot v1.5 Open Beta
--    Author: PedobearIGER
--    Credits: Arivo for the great idea of such a fully automated bot!
]]--
local version = "1.5 Open Beta"

--require 'winapi'
--function print_keys_down()
--    local state = winapi.get_async_keyboard_state()
--    for vk,flag in pairs(state) do
--        if flag then
--            print('key is down:', vk)
--        end
--    end
--end

if GetSelf().name == "Soraka" then
    require 'Utils'
    require 'winapi'
    require 'MapPositionLB'
    require 'SKeys'
    local send = require 'SendInputScheduled'
    local spells = {"R","E","W",myHero.SummonerD,myHero.SummonerF,"Q"}
    --local turretNames = {
    --    blue = {"Turret_OrderTurretShrine_A","Turret_T1_C_01_A","Turret_T1_C_02_A","Turret_T1_C_03_A","Turret_T1_C_04_A","Turret_T1_C_05_A","Turret_T1_C_06_A","Turret_T1_C_07_A","Turret_T1_L_02_A","Turret_T1_L_03_A","Turret_T1_R_02_A","Turret_T1_R_03_A","Turret_OrderTurretShrine_A","Turret_OrderTurretShrine1_A","Turret_OrderTurretShrine_A","Turret_T1_C_07_A","Turret_T1_C_08_A","Turret_T1_C_09_A","Turret_T1_C_010_A","Turret_OrderTurretShrine_A","Turret_T1_R_02_A","Turret_T1_C_07_A","Turret_T1_C_06_A","Turret_T1_C_01_A","Turret_T1_L_02_A"},
    --    red = {"Turret_ChaosTurretShrine_A","Turret_T2_C_01_A","Turret_T2_C_02_A","Turret_T2_C_03_A","Turret_T2_C_04_A","Turret_T2_C_05_A","Turret_T2_L_01_A","Turret_T2_L_02_A","Turret_T2_L_03_A","Turret_T2_R_01_A","Turret_T2_R_02_A","Turret_T2_R_03_A","Turret_ChaosTurretShrine_A","Turret_ChaosTurretShrine1_A","Turret_ChaosTurretShrine_A","Turret_T2_L_01_A","Turret_T2_L_02_A","Turret_T2_L_03_A","Turret_T2_L_04_A","Turret_ChaosTurretShrine_A","Turret_T2_L_01_A","Turret_T2_C_01_A","Turret_T2_L_02_A","Turret_T2_R_01_A","Turret_T2_R_02_A"}
    --}
    local allTurretNames = {"Turret_OrderTurretShrine_A","Turret_T1_C_01_A","Turret_T1_C_02_A","Turret_T1_C_03_A","Turret_T1_C_04_A","Turret_T1_C_05_A","Turret_T1_C_06_A","Turret_T1_C_07_A","Turret_T1_L_02_A","Turret_T1_L_03_A","Turret_T1_R_02_A","Turret_T1_R_03_A","Turret_OrderTurretShrine_A","Turret_OrderTurretShrine1_A","Turret_OrderTurretShrine_A","Turret_T1_C_07_A","Turret_T1_C_08_A","Turret_T1_C_09_A","Turret_T1_C_010_A","Turret_OrderTurretShrine_A","Turret_T1_R_02_A","Turret_T1_C_07_A","Turret_T1_C_06_A","Turret_T1_C_01_A","Turret_T1_L_02_A","Turret_ChaosTurretShrine_A","Turret_T2_C_01_A","Turret_T2_C_02_A","Turret_T2_C_03_A","Turret_T2_C_04_A","Turret_T2_C_05_A","Turret_T2_L_01_A","Turret_T2_L_02_A","Turret_T2_L_03_A","Turret_T2_R_01_A","Turret_T2_R_02_A","Turret_T2_R_03_A","Turret_ChaosTurretShrine_A","Turret_ChaosTurretShrine1_A","Turret_ChaosTurretShrine_A","Turret_T2_L_01_A","Turret_T2_L_02_A","Turret_T2_L_03_A","Turret_T2_L_04_A","Turret_ChaosTurretShrine_A","Turret_T2_L_01_A","Turret_T2_C_01_A","Turret_T2_L_02_A","Turret_T2_R_01_A","Turret_T2_R_02_A"}
    local doNotAttackUnitNames = {"Blue_Minion_Basic","Blue_Minion_Wizard","Blue_Minion_MechCannon","Blue_Minion_MechMelee","Red_Minion_Basic","Red_Minion_Wizard","Red_Minion_MechCannon","Red_Minion_MechMelee","AncientGolem","LizardElder","GiantWolf","Wraith"}    
    local allTurretNames2 = {"OrderTurretShrine","OrderTurretAngel","OrderTurretDragon","OrderTurretNormal2","OrderTurretNormal","TT_OrderTurret1","TT_OrderTurret2","TT_OrderTurret3","TT_OrderTurret4","ChaosTurretShrine","ChaosTurretNormal","ChaosTurretGiant","ChaosTurretWorm2","ChaosTurretWorm","TT_ChaosTurret1","TT_ChaosTurret2","TT_ChaosTurret3","TT_ChaosTurret4"}
    local turretNames = {
        blue = {"OrderTurretShrine","OrderTurretAngel","OrderTurretDragon","OrderTurretNormal2","OrderTurretNormal","TT_OrderTurret1","TT_OrderTurret2","TT_OrderTurret3","TT_OrderTurret4","OdinOrderTurretShrine","HA_AP_OrderTurret3","HA_AP_OrderTurret2","HA_AP_OrderTurret"},
        red = {"ChaosTurretShrine","ChaosTurretNormal","ChaosTurretGiant","ChaosTurretWorm2","ChaosTurretWorm","TT_ChaosTurret1","TT_ChaosTurret2","TT_ChaosTurret3","TT_ChaosTurret4","OdinChaosTurretShrine","HA_AP_ChaosTurret3","HA_AP_ChaosTurret2","HA_AP_ChaosTurret"}
    }
    local baseTurrets = {"TT_OrderTurret4","TT_ChaosTurret4","OrderTurretShrine","ChaosTurretShrine","OdinOrderTurretShrine","OdinChaosTurretShrine","HA_AP_ChaosTurretShrine","HA_AP_OrderTurretShrine"}
    local nonManaChampNames = {"DrMundo" , "Mordekaiser" , "Vladimir" , "Zac", "Rumble", "Renekton" , "Shyvana" , "Tryndamere", "Garen" , "Katarina" , "Riven", "Rengar", "Akali" , "Kennen" , "LeeSin" , "Shen" , "Zed", "Aatrox"}
    local wardNames = {"SightWard","VisionWard","Ward_Sight_Idle.troy","Ward_Vision_Idle.troy","Ward_Wriggles_Idle.troy"}
    
    --Script config menu--
    IGERsSorakaBotConfig = scriptConfig("IGERs SorakaBot", "IGERsSorakaBot")
    IGERsSorakaBotConfig:addParam("mainSwitch", "[Numpad 0]Bot MainSwitch", SCRIPT_PARAM_ONKEYTOGGLE, true, 96)
    IGERsSorakaBotConfig:permaShow("mainSwitch")
    IGERsSorakaBotConfig:addParam("spellAI", "[Numpad 1]Spell_AI", SCRIPT_PARAM_ONKEYTOGGLE, true, 97)
    IGERsSorakaBotConfig:permaShow("spellAI")
    IGERsSorakaBotConfig:addParam("itemAI", "[Numpad 2]Item_AI", SCRIPT_PARAM_ONKEYTOGGLE, true, 98)
    IGERsSorakaBotConfig:permaShow("itemAI")
    IGERsSorakaBotConfig:addParam("moveAI", "[Numpad 3]Move_AI", SCRIPT_PARAM_ONKEYTOGGLE, true, 99)
    IGERsSorakaBotConfig:permaShow("moveAI")
    IGERsSorakaBotConfig:addParam("dodgeAI", "[Numpad 4]Dodge_AI", SCRIPT_PARAM_ONKEYTOGGLE, true, 100)
    IGERsSorakaBotConfig:permaShow("dodgeAI")
    IGERsSorakaBotConfig:addParam("autoAttackAI", "[Numpad 5]AutoAttack_AI", SCRIPT_PARAM_ONKEYTOGGLE, true, 101)
    IGERsSorakaBotConfig:permaShow("autoAttackAI")
    IGERsSorakaBotConfig:addParam("buyItemsAI", "[Numpad 6]BuyItems_AI", SCRIPT_PARAM_ONKEYTOGGLE, true, 102)
    IGERsSorakaBotConfig:permaShow("buyItemsAI")
    IGERsSorakaBotConfig:addParam("levelSpellsAI", "[Numpad 7]LevelSpells_AI", SCRIPT_PARAM_ONKEYTOGGLE, true, 103)
    IGERsSorakaBotConfig:permaShow("levelSpellsAI")
    IGERsSorakaBotConfig:addParam("selectMaster", "[Numpad *]Select New Master", SCRIPT_PARAM_ONKEYDOWN, false, 106)
    IGERsSorakaBotConfig:permaShow("selectMaster")
    ----------------------
    
    --Callbacks--
    function OnLoad()
        repeat
            if string.format(myHero.team) == "100" then
                playerTeam = "blue"
                enemyTeam = "red"
            elseif  string.format(myHero.team) == "200" then  
                playerTeam = "red"
                enemyTeam = "blue"
            end
        until playerTeam ~= nil and playerTeam ~= "0"
        baseTurret = GetBaseTurret().ally
        baseTurretEnemy = GetBaseTurret().enemy
        Test_OnLoadDodge()
        loaded = true
    end
    
    function OnTick()
        if GetGameTime() < 5 then return end
        if loaded == nil then OnLoad() end
        if IGERsSorakaBotConfig.mainSwitch then
            if IGERsSorakaBotConfig.spellAI then SpellHandler(spells) end
            if IGERsSorakaBotConfig.itemAI then ItemHandler() end
            if IGERsSorakaBotConfig.moveAI then MoveHandler() end
            if IGERsSorakaBotConfig.dodgeAI then DodgeHandler() end
            if IGERsSorakaBotConfig.autoAttackAI then AttackHandler() end
            if IGERsSorakaBotConfig.buyItemsAI then ItemBuyHandler() end
            if IGERsSorakaBotConfig.levelSpellsAI then SpellLevelHandler() end
            if myHero.dead == 0 then
                local nearAlly = GetNearestHero("ally",{myHero})
                if nearAlly ~= nil and GetDistance(nearAlly) <= 750 then CustomCircle(750,6,1,myHero)
                else CustomCircle(750,6,2,myHero) end
            end
            if followTarget ~= nil and followTarget.dead == 0 then
                CustomCircle(100,6,2,followTarget)
                DrawTextObject("Master",followTarget,0xFFFF0000)
            end
        end
        --if lolActive == nil then lolActive = false end
        --if IsLolActive() then lolActive = true end
        --if lolActive and not IsLolActive() then 
        --    --send.key_up(SKeys.Control)
        --    --send.wait(100)
        --    --send.key_up(SKeys.Control)
        --    --lolActive = false
        --end
        if IsLolActive() then
            send.tick()
        end
    end
    
    function OnProcessSpell(object,spell)
        if IsValid(object) and IsValid(spell) then
            Test_DodgeHandler(object,spell)
            if followTarget ~= nil and object.team == myHero.team and object.charName == followTarget.charName then
                if spell.name ~= nil and spell.name == "Recall" and GetDistance(followTarget) < 400 then 
                    Recall() 
                    lastRecall = GetClock()
                    return
                end
                local spellPos = {}
                if spell.target ~= nil then spellPos = {x=spell.target.x,y=spell.target.y,z=spell.target.z}
                elseif spell.endPos ~= nil then spellPos = {x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}
                elseif spell.startPos ~= nil then spellPos = {x=spell.startPos.x,y=spell.startPos.y,z=spell.startPos.z}
                else return end
                position = {x=followTarget.x,y=followTarget.y,z=followTarget.z}
                masterInfo = {lastSpellPos=spellPos,lastCastPos=position,lastCastTick=GetClock()}
            elseif object.team == myHero.team and object.charName == myHero.charName then
                --if spell.name ~= nil then printtext(spell.name.."\n") end
                --
                --  if IGERsSorakaBotConfig.autoAttackAI and spell.target ~= nil then
                --      printtext(spell.target.name.."\n"..spell.target.charName.."\n")
                --      local tgn = spell.target.name
                --      if string.find(tgn,"Minion_") ~= nil or tgn == "AncientGolem" or tgn == "LizardElder" or tgn == "GiantWolf" or tgn == "Wraith" then
                --          StopMove()
                --          return
                --      end
                --  end
                --
                local spellPos = {}
                if spell.target ~= nil then spellPos = {x=spell.target.x,y=spell.target.y,z=spell.target.z}
                elseif spell.endPos ~= nil then spellPos = {x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}
                elseif spell.startPos ~= nil then spellPos = {x=spell.startPos.x,y=spell.startPos.y,z=spell.startPos.z}
                else spellPos = nil end
                position = {x=myHero.x,y=myHero.y,z=myHero.z}
                selfInfo = {lastSpellPos=spellPos,lastCastPos=position,lastCastTick=GetClock()}
            --elseif object.team ~= myHero.team and (spell.target == nil or spell.target.name ~= nil) and spell.endPos ~= nil then
            --    if GetDistance(spell.endPos) < 100 then
            --        spellDodgePos = {x=object.x-myHero.x,y=0,z=-(object.z)}
            --        dodgeInfo = {dodgePos=spellDodgePos,lastDodge=GetClock()}
            --    end
            end
            if spell.target ~= nil and IGERsSorakaBotConfig.moveAI then
                for i,turretName in ipairs(turretNames[enemyTeam]) do
                    if object.charName == turretName and spell.target.charName == myHero.charName then
                        dodgeing = true
                        dodgetimeout = GetClock()+3000
                        MoveToXYZ(baseTurret.x,baseTurret.y,baseTurret.z)
                    end
                end
            end
        end
    end
    
    --Handler+Functions--
    function SpellHandler(spells)
        for i,spell in ipairs(spells) do
            target = SpellTarget(spell)
            if IsValid(target) then
                if spell == myHero.SummonerD then CastSpellTarget("D",target)
                elseif spell == myHero.SummonerF then CastSpellTarget("F",target)
                elseif CanCastSpell(spell) then
                    CastSpellTarget(spell,target)
                end
            end
        end
    end
    
    function SpellTarget(spell)
        if not IsRecalling(myHero) then
            if spell == "R" then
                local countA,countB,countC = 0,0,0
                for i=1, objManager:GetMaxHeroes(), 1 do
                    local object = objManager:GetHero(i)
                    if IsValid(object) and object.team == myHero.team and object.dead == 0 and object.health > 0 and not IsIgnited(object) then 
                        if object.health < 100+myHero.selflevel*20 then countA = countA+1 end
                        if object.health < 250+myHero.selflevel*15 then countB = countB+1 end
                        if object.maxHealth-object.health >= 200*GetSpellLevel("R")+myHero.ap*0.7 then countC = countC+1 end
                    end
                end
                if countA >= 1 or countB >= 2 or countC >= 4 then return myHero end
            elseif spell == "W" then
                local lowestMate = nil
                for i=1, objManager:GetMaxHeroes(), 1 do
                    local object = objManager:GetHero(i)
                    if IsValid(object) and object.team == myHero.team and object.dead == 0 and object.health > 1 and not IsIgnited(object) and object.maxHealth-object.health >= 70*GetSpellLevel("W")+myHero.ap*0.45 and GetDistance(object) <= 900 then --750
                        if lowestMate == nil or object.health < lowestMate.health then lowestMate = object end
                    end
                end
                if not IsRecalling(myHero) or (lowestMate ~= nil and lowestMate.health < 300) then
                    return lowestMate
                end
            elseif spell == "E" then
                local lowestMate = nil
                local strongestEnemy = nil
                local target = nil
                for i=1, objManager:GetMaxHeroes(), 1 do
                    local object = objManager:GetHero(i)
                    if IsValid(object) and object.team == myHero.team and object.dead == 0 and object.health > 1 and not IsRecalling(object) and object.charName ~= myHero.charName and object.maxMana-object.mana >= 50*GetSpellLevel("E")+myHero.ap*0.6 and GetDistance(object) <= 725 then
                        if lowestMate == nil or object.mana < lowestMate.mana then lowestMate = object end
                    end
                end
                if lowestMate == nil then
                    for i=1, objManager:GetMaxHeroes(), 1 do
                        local object = objManager:GetHero(i)
                        if IsValid(object) and object.team ~= 0 and object.team ~= myHero.team and object.dead == 0 and object.health > 1 and GetDistance(object) <= 725 then
                            if strongestEnemy == nil or object.ap > strongestEnemy.ap then strongestEnemy = object end
                        end
                    end
                    target = strongestEnemy
                else
                    target = lowestMate
                end
                enemTurr = GetNearestEnemyTurret()
                if not IsRecalling(myHero) and (enemTurr == nil or GetDistance(enemTurr) > 950) then
                    return target
                end
            elseif spell == "SummonerHeal" then
                local countA,countB,countC = 0,0,0
                for i=1, objManager:GetMaxHeroes(), 1 do
                    local object = objManager:GetHero(i)
                    if IsValid(object) and object.team == myHero.team and object.dead == 0 and object.health > 1 and object.mana > 1 and not IsIgnited(object) and GetDistance(object) <= 600 then
                        if object.health < 150+myHero.selflevel*20 then countA = countA+1 end
                        if object.health < 300+myHero.selflevel*20 then countB = countB+1 end
                        if object.maxHealth-object.health >= 75+15*myHero.selflevel then countC = countC+1 end
                    end
                end
                if (countA >= 1 or countB >= 2 or countC >= 3) and not IsRecalling(myHero) then return myHero end
            elseif spell == "SummonerMana" then
                local countA = 0
                for i=1, objManager:GetMaxHeroes(), 1 do
                    local object = objManager:GetHero(i)
                    if IsValid(object) and object.team == myHero.team and object.dead == 0 and object.mana ~= nil and object.mana > 1 and GetDistance(object) <= 600 then
                        if object.charName == myHero.charName and myHero.mana/myHero.maxMana <= 0.4 then return myHero end
                        if object.mana/object.maxMana <= 0.2 then countA = countA+1 end
                    end
                end
                if countA >= 2 and not IsRecalling(myHero) then return myHero end
            elseif spell == "Q" then
                nearMinion = GetNearestMinion()
                nearEnemyChamp = GetNearestHero("enemy")
                if myHero.mana > 500 and (GetDistance(baseTurret) < 5000 or GetDistance(baseTurretEnemy) < 6000 or ((nearMinion == nil or GetDistance(nearMinion) > 700) and nearEnemyChamp ~= nil and GetDistance(nearEnemyChamp) < 700) or (MapPosition:onLane(myHero) and GetGameTime() > 1800)) then
                    return myHero
                end
            end
        end
        return nil
    end
    
    function IsIgnited(unit)
        for i=1, objManager:GetMaxObjects(), 1 do
            local object = objManager:GetObject(i)
            if IsValid(object) then
                if object.charName == "Summoner_Dot.troy" then
                    if GetDistance(object,unit) < 10 then return true end
                end
            end
        end
        return false
    end
    
    function GetNearestMinion()
        local nearestMinion = nil
        for i=1, objManager:GetMaxObjects(), 1 do
            local object = objManager:GetObject(i)
            if IsValid(object) and object.team ~= 0 and object.team ~= myHero.team and object.dead == 0 and object.health > 0 then
                for i,creatureName in ipairs(doNotAttackUnitNames) do
                   if object.name == creatureName then
                       if nearestMinion == nil or GetDistance(object) < GetDistance(nearestMinion) then nearestMinion = object end
                   end
                end
            end
        end
        return nearestMinion
    end

    lastWardTick = 0
    nextWriggles = 0
    function ItemHandler()
        if GetDistance(baseTurret) < 400 then sightStoneCount = 0 end
        if not IsRecalling(myHero) then
            for i=1,6,1 do
                item = GetInventoryItem(i)
                if item == 2009 then --Mastery Bicuit
                    if myHero.maxHealth-myHero.health >= 130 and myHero.maxMana-myHero.mana >= 100 and not IsDrinkingHealthPotion() and not IsDrinkingManaPotion() then 
                        CastSpellTarget(i,myHero)
                    end
                elseif item == 2003 then --Health Potion
                    if myHero.maxHealth-myHero.health >= 200 and not IsDrinkingHealthPotion() then 
                        CastSpellTarget(i,myHero)
                    end
                elseif item == 2004 then --Mana Potion
                    if myHero.maxMana-myHero.mana >= 150 and not IsDrinkingManaPotion() then 
                        CastSpellTarget(i,myHero)
                    end
                elseif item == 3069 then --shurelias
                    if CanUseSpell(i) == 1 and GetDistance(baseTurret) > 1500 then 
                        CastSpellTarget(i,myHero)
                    end
                elseif item == 2045 and GetClock() > lastWardTick+500 then --wards
                    AutoWard(i)
                    lastWardTick = GetClock()
                elseif item == 2049 and GetClock() > lastWardTick+500 then
                    AutoWard(i)
                    lastWardTick = GetClock()
                elseif item == 3154 and GetClock() > lastWardTick+500 and GetClock() > nextWriggles then
                    AutoWard(i)
                    lastWardTick = GetClock()
                    nextWriggles = GetClock()+180000
                elseif item == 2044 and GetClock() > lastWardTick+500 then
                    AutoWard(i)
                    lastWardTick = GetClock()
                elseif item == 2043 and GetClock() > lastWardTick+500 then
                    AutoWard(i)
                    lastWardTick = GetClock()
                elseif item == 2050 and GetClock() > lastWardTick+500 then
                    AutoWard(i)
                    lastWardTick = GetClock()
                end
            end
        end
    end
    
    function AutoWard(slot)
        for i,spot in ipairs(wardSpots) do
            local nearestWard = GetNearestWard(spot)
            if GetDistance(spot) < 600 and (nearestWard == nil or GetDistance(nearestWard,spot) > 1500) then
                if MapPosition:inMyJungle(spot) then
                    if GetGameTime() > 30*60 then
                        CastSpellXYZ(slot,spot.x,0,spot.z)
                    end
                else
                    CastSpellXYZ(slot,spot.x,0,spot.z)
                end
            end
        end
    end
    
    function GetSlotById(id)
        for i=1,6 do
            if GetInventoryItem(i) == id then return string.format(i) end
        end
    end
    
    function GetNearestWard(pos)
        local nearestWard = nil
        for i=1, objManager:GetMaxObjects(), 1 do
            local object = objManager:GetObject(i)
            if IsValid(object) and object.team == myHero.team and object.mana > 15 then
                for i,wardName in ipairs(wardNames) do
                   if object.charName == wardName then
                       if nearestWard == nil or GetDistance(object,pos) < GetDistance(nearestWard,pos) then nearestWard = object end
                   end
                end
            end
        end
        return nearestWard
    end
    
    function IsDrinkingHealthPotion()
        for i=1, objManager:GetMaxObjects(), 1 do
            local object = objManager:GetObject(i)
            if IsValid(object) and object.charName == "Regenerationpotion_itm.troy" and GetDistance(object) < 10 then
                return true
            end
        end
        return false
    end
    
    function IsDrinkingManaPotion()
        for i=1, objManager:GetMaxObjects(), 1 do
            local object = objManager:GetObject(i)
            if IsValid(object) and object.charName == "ManaPotion_itm.troy" and GetDistance(object) < 10 then
                return true
            end
        end
        return false
    end
    
    wardSpots = {
        { x = 2572,    y = 45.84,  z = 7457},     -- BLUE GOLEM
        { x = 7422,    y = 46.53,  z = 3282},     -- BLUE LIZARD
        { x = 10148,   y = 44.41,  z = 2839},     -- BLUE TRI BUSH
        { x = 6269,    y = 42.51,  z = 4445},     -- BLUE PASS BUSH
        { x = 7406,    y = 43.31,  z = 4995},     -- BLUE RIVER ENTRANCE
        { x = 4325,    y = 44.38,  z = 7241.54},  -- BLUE ROUND BUSH
        { x = 4728,    y = -51.29, z = 8336},     -- BLUE RIVER ROUND BUSH
        { x = 6598,    y = 46.15,  z = 2799},     -- BLUE SPLIT PUSH BUSH

        { x = 11500,   y = 45.75,  z = 7095},     -- PURPLE GOLEM
        { x = 6661,    y = 44.46,  z = 11197},    -- PURPLE LIZARD
        { x = 3883,    y = 39.87,  z = 11577},    -- PURPLE TRI BUSH
        { x = 7775,    y = 43.14,  z = 10046.49}, -- PURPLE PASS BUSH
        { x = 6625.47, y = 47.66,  z = 9463},     -- PURPLE RIVER ENTRANCE
        { x = 9720,    y = 45.79,  z = 7210},     -- PURPLE ROUND BUSH
        { x = 9191,    y = -73.46, z = 6004},     -- PURPLE RIVER ROUND BUSH
        { x = 7490,    y = 41,     z = 11681},    -- PURPLE SPLIT PUSH BUSH

        { x = 3527.43, y = -74.95, z = 9534.51},  -- NASHOR
        { x = 10473,   y = -73,    z = 5059},     -- DRAGON
    }
    
    function MoveHandler()  --holy fuck, this function got sooo freaking dirty.....
        if (attacking ~= nil and attacking) or (dodgeing ~= nil and dodgeing) then 
            if not IsValid(followTarget) or followTarget.dead == 1 then
                attacking = false
            else
                return 
            end
        end
        if IGERsSorakaBotConfig.selectMaster then 
            followTarget = GetMarkedTarget()
            if followTarget ~= nil then targetSetManually = true end
        end
        if targetSetManually == nil and not IsValid(followTarget) then followTarget = GetADCarry() end
        if lastRecall ~= nil and GetClock() < lastRecall+500 then 
            Recall() 
            return
        end
        if tempNewMaster ~= nil and oldADC.dead == 0 then
            followTarget = oldADC
            tempNewMaster = nil
        end
        --if not IsValid(followTarget) then followTarget = GetMarkedTarget() end
        --if myHero.gold > 1500 and GetDistance(baseTurret) > 1000 then
        --    local nearestTurret = GetNearestTurret()
        --    if GetDistance(nearestTurret) < 100 then Recall()
        --    else MoveToXYZ(baseTurret.x,baseTurret.y,baseTurret.z) end
        --    return
        --end
       --if followTarget == nil then
       --   followTarget = GetMarkedTarget()
       --end
        --if GetGameTime() > 3 and GetGameTime() <  GetNearestAllyNC(followTarget) ~= nil and GetDistance(GetNearestAllyNC(followTarget),followTarget) < 900 then
        --    followBadCount = followBadCount+1
        --end
        --if followBadCount > 120000 then
        --    --entered lane
        --end
        -----if not IsValid(followTarget) or followTarget.dead == 1 then
        -----    if IsValid(attackTurret) and IsValid(attackTurretPos) and GetDistance(attackTurretPos,followTarget) < 30 then
        -----        AttackTarget(attackTurret)
        -----        return
        -----    end
        -----end

        if IsValid(followTarget) and followTarget.dead == 0 then
            if GetDistance(baseTurret) > 1000 and IsRecalling(myHero) and (IsRecalling(followTarget) or GetDistance(baseTurret,followTarget) < 1000) then
                if GetDistance(followTarget) < 150 then
                    Recall()
                else
                    MoveToXYZ(followTarget.x,followTarget.y,followTarget.z)
                end
                return
            end
            if IsRecalling(followTarget) then 
                if GetDistance(followTarget) < 150 or GetDistance(followTarget) > 3000 then
                    Recall()
                else
                    MoveToXYZ(followTarget.x,followTarget.y,followTarget.z)
                    return
                end
            elseif CapturesTurret(followTarget) then
                local capTurr = GetDominionTurret()
                if capTurr ~= nil and IsLolActive() then ClickSpellXYZ('M',capTurr.x,capTurr.y,capTurr.z,0) end
            else
                local nearestEnemy = GetNearestHero("enemy")
                local nearestEnemyTurret = GetNearestEnemyTurret()
                local nearestTurret = GetNearestTurret()
                if GetDistance(baseTurret) > 1000 and GetDistance(followTarget) > 3000 and GetDistance(baseTurret,followTarget) < 3500 and (nearestEnemy == nil or GetDistance(nearestEnemy) > 1000) and GetDistance(nearestEnemyTurret) > 1000 then
                    Recall()
                    return
                end
                local minDist = 200
                local minDistB = 1
                if (MapPosition:onLane(followTarget) or MapPosition:inBase(followTarget)) and not MapPosition:inBush(followTarget) then
                    if nearestEnemy ~= nil then
                        minDistB = 400
                    else
                        minDistB = 350
                    end
                end
                
                
                if GetDistance(baseTurret) < GetDistance(baseTurretEnemy) then
                    delta = {x = followTarget.x-baseTurret.x, z = followTarget.z-baseTurret.z}
                    dist = math.sqrt(math.pow(delta.x,2)+math.pow(delta.z,2))
                    movePos = {x=followTarget.x-(minDistB/dist)*delta.x,y=100,z=followTarget.z-(minDistB/dist)*delta.z}
                else
                    delta = {x = followTarget.x-baseTurretEnemy.x, z = followTarget.z-baseTurretEnemy.z}
                    dist = math.sqrt(math.pow(delta.x,2)+math.pow(delta.z,2))
                    movePos = {x=followTarget.x+(minDistB/dist)*delta.x,y=100,z=followTarget.z+(minDistB/dist)*delta.z}
                end
                
                if MapPosition:intersectsWall(LineSegment(Point(followTarget.x,followTarget.z),Point(movePos.x,movePos.z))) then
                    movePos = {x=followTarget.x,y=100,z=followTarget.z}
                end
                
                
                --if nearestEnemy ~= nil then
                --    if GetDistance(nearestEnemy) < 150 or GetDistance(nearestEnemy) > 1200 then
                --        nearestEnemy2 = GetNearestHero("enemy",{nearestEnemy})
                --        if nearestEnemy2 ~= nil then
                --            movePos = {x=followTarget.x,y=followTarget.y,z=followTarget.z}
                --        else
                --            if GetDistance(nearestEnemy,nearestTurret) < GetDistance(nearestTurret) then
                --                movePos = {x=followTarget.x,y=followTarget.y,z=followTarget.z}
                --            else
                --                delta = {x = followTarget.x-baseTurretEnemy.x, z = followTarget.z-baseTurretEnemy.z}
                --                dist = math.sqrt(math.pow(delta.x,2)+math.pow(delta.z,2))
                --                movePos = {x=followTarget.x+(minDistB/dist)*delta.x,y=100,z=followTarget.z+(minDistB/dist)*delta.z}
                --                if GetDistance(movePos,nearestTurret) < 500 then
                --                    delta = {x = followTarget.x-baseTurret.x, z = followTarget.z-baseTurret.z}
                --                    dist = math.sqrt(math.pow(delta.x,2)+math.pow(delta.z,2))
                --                    movePos = {x=followTarget.x-(minDistB/dist)*delta.x,y=100,z=followTarget.z-(minDistB/dist)*delta.z}
                --                end
                --            end
                --        end
                --    else
                --        delta = {x = followTarget.x-baseTurretEnemy.x, z = followTarget.z-baseTurretEnemy.z}
                --        dist = math.sqrt(math.pow(delta.x,2)+math.pow(delta.z,2))
                --        movePos = {x=followTarget.x+(minDistB/dist)*delta.x,y=100,z=followTarget.z+(minDistB/dist)*delta.z}
                --        if GetDistance(movePos,nearestTurret) < 500 then
                --            delta = {x = followTarget.x-baseTurret.x, z = followTarget.z-baseTurret.z}
                --            dist = math.sqrt(math.pow(delta.x,2)+math.pow(delta.z,2))
                --            movePos = {x=followTarget.x-(minDistB/dist)*delta.x,y=100,z=followTarget.z-(minDistB/dist)*delta.z}
                --        end
                --    end
                --else
                --    delta = {x = followTarget.x-baseTurretEnemy.x, z = followTarget.z-baseTurretEnemy.z}
                --    dist = math.sqrt(math.pow(delta.x,2)+math.pow(delta.z,2))
                --    movePos = {x=followTarget.x+(minDistB/dist)*delta.x,y=100,z=followTarget.z+(minDistB/dist)*delta.z}
                --    if GetDistance(movePos,nearestTurret) < 500 then
                --        delta = {x = followTarget.x-baseTurret.x, z = followTarget.z-baseTurret.z}
                --        dist = math.sqrt(math.pow(delta.x,2)+math.pow(delta.z,2))
                --        movePos = {x=followTarget.x-(minDistB/dist)*delta.x,y=100,z=followTarget.z-(minDistB/dist)*delta.z}
                --    end
                --end
                    
                if GetDistance(movePos) > minDist then
                    MoveToXYZ(movePos.x,movePos.y,movePos.z)
                    if move == nil then move = 1
                    else move = move+1 end
                else
                    if IGERsSorakaBotConfig.autoAttackAI and move ~= nil and move ~= 0 then
                        StopMove()
                        if move > 4 then move = 0 end
                    end
                end
                DrawCircle(movePos.x,movePos.y,movePos.z,minDist,5)
            end
        else
            local nearestTurret = GetNearestTurret()
            if GetDistance(nearestTurret) < 3000 then
                local minDist = 300
                local minDistB = 300
                local delta = {x = nearestTurret.x-baseTurret.x, z = nearestTurret.z-baseTurret.z}
                local dist = math.sqrt(math.pow(delta.x,2)+math.pow(delta.z,2))
                local movePos = {x=nearestTurret.x-(minDistB/dist)*delta.x,y=100,z=nearestTurret.z-(minDistB/dist)*delta.z}
                if GetDistance(movePos) < 150 then
                    Recall()
                else
                    MoveToXYZ(movePos.x,movePos.y,movePos.z)
                    DrawCircle(movePos.x,movePos.y,movePos.z,minDist,5)
                end
            else
                local nearestAlly = GetNearestHero("ally",{myHero})
                if GetGameTime() > 20*60 and nearestAlly ~= nil and GetDistance(nearestAlly) < 2000 then
                    tempNewMaster = true
                    oldADC = followTarget
                    followTarget = nearestAlly
                else
                    MoveToXYZ(nearestTurret.x,nearestTurret.y,nearestTurret.z)
                end
            end
        end
    end
    
    function GetADCarry()
        local adCarry = nil
        for i=1, objManager:GetMaxHeroes(), 1 do
            local object = objManager:GetHero(i)
            if IsValid(object) and object.team == myHero.team and object.range > 350 and object.charName ~= myHero.charName then
                local objectDPS = (object.baseDamage+object.addDamage)*object.attackspeed
                if adCarry == nil or objectDPS > ((adCarry.baseDamage+adCarry.addDamage)*adCarry.attackspeed) then adCarry = object end
            end
        end
        if adCarry == nil then
            for i=1, objManager:GetMaxHeroes(), 1 do
                local object = objManager:GetHero(i)
                if IsValid(object) and object.team == myHero.team and object.charName ~= myHero.charName then
                    local objectDPS = (object.baseDamage+object.addDamage)*object.attackspeed
                    if adCarry == nil or objectDPS > ((adCarry.baseDamage+adCarry.addDamage)*adCarry.attackspeed) then adCarry = object end
                end
            end
        end
        return adCarry
    end
    
    function GetNearestTurret()
        local nearestTurret = nil
        for i=1, objManager:GetMaxObjects(), 1 do
            local object = objManager:GetObject(i)
            if IsValid(object) then
                for i,turretName in ipairs(turretNames[playerTeam]) do
                   if object.name == turretName then
                       if nearestTurret == nil or GetDistance(object) < GetDistance(nearestTurret) then nearestTurret = object end
                   end
                end
            end
        end
        return nearestTurret
    end

    function GetNearestEnemyTurret()
        local nearestTurret = nil
        for i=1, objManager:GetMaxObjects(), 1 do
            local object = objManager:GetObject(i)
            if IsValid(object) then
                for i,turretName in ipairs(turretNames[enemyTeam]) do
                   if object.name == turretName then
                       if nearestTurret == nil or GetDistance(object) < GetDistance(nearestTurret) then nearestTurret = object end
                   end
                end
            end
        end
        return nearestTurret
    end

    function IsRecalling(unit)
        for i=1, objManager:GetMaxObjects(), 1 do
            local object = objManager:GetObject(i)
            if IsValid(object) then
                if object.charName == "TeleportHome.troy" or object.charName == "TeleportHomeImproved.troy" then
                    if GetDistance(object,unit) < 30 then
                    return true end
                end
            end
        end
        return false
    end
    
    function Recall()
        if IsLolActive() and IsChatOpen() == 0 then
            os.execute("ExtAhkFuncs.exe Recall")
            --send.key_press(SKeys.B)
        end
    end

    --[[ Old Dodge
    function DodgeHandler()
        if dodgeTurret ~= nil and GetClock() < dodgeTurret+2000 then
            MoveToXYZ(baseTurret.x,baseTurret.y,baseTurret.z)
            dodgeing = true
            return
        end
        if IsValid(dodgeInfo,{dodgePos,lastDodge}) and GetTickCount() < dodgeInfo.lastDodge+500 then
            MoveToXYZ(dodgeInfo.dodgePos.x,dodgeInfo.dodgePos.y,dodgeInfo.dodgePos.z)
            dodgeing = true
            return true
        end
        if IsValid(dodgeInfo,{dodgePos,lastDodge}) and GetTickCount() > dodgeInfo.lastDodge+500 then
            dodgeing = false
        end
    end
    ]]--
    
    function GetNearestHero(team,exeptions)
        local nearest = nil
        for i=1, objManager:GetMaxHeroes(), 1 do
            local hero = objManager:GetHero(i)
            if IsValid(hero) and hero.dead == 0 and hero.visible == 1 and (team == "enemy" and myHero.team ~= hero.team) or (team == "ally" and myHero.team == hero.team) then
                local heroOk = true
                if exeptions ~= nil and #exeptions > 0 then
                    for i,exeption in ipairs(exeptions) do
                        if exeption.charName == hero.charName then heroOk = false end
                    end
                end
                if heroOk then
                    if nearest == nil or GetDistance(myHero,hero) < GetDistance(myHero,nearest) then nearest = hero end
                end
            end
        end
        return nearest
    end
    
    function AttackHandler()
        if CapturesTurret(followTarget) then
            local capTurr = GetDominionTurret()
            if capTurr ~= nil then 
                if IsLolActive() then ClickSpellXYZ('M',capTurr.x,capTurr.y,capTurr.z,0) end
                attacking = true
                lasthitting = false
                return
            end
        end
        nearestAlly = GetNearestHero("ally")
        if (not IsValid(followTarget) or followTarget.dead == 1) and (nearestAlly == nil or GetDistance(nearestAlly) > 1000) then
            Lasthit()
            lasthitting = true
            return
        end
        lasthitting = false
        attacking = false
        if IsValid(masterInfo,{"lastSpellPos","lastCastPos","lastCastTick"}) and GetClock() < masterInfo.lastCastTick+400 and IsValid(followTarget) and GetDistance(masterInfo.lastCastPos,followTarget) < 20 then
            local target = nil
            for i=1, objManager:GetMaxObjects(), 1 do
                local object = objManager:GetObject(i)
                if IsValid(object) and object.health > 1 and (IsBuilding(object) or string.find(object.charName,".troy") == nil) then
                    if GetDistance(object,masterInfo.lastSpellPos) < 30 and (target == nil or GetDistance(object,masterInfo.lastSpellPos) < GetDistance(target,masterInfo.lastSpellPos)) then target = object end
                end
            end
            if not IsValid(target) then return end
            
            for i,listName in ipairs(doNotAttackUnitNames) do
                if listName == target.name then return end
            end
            if (IsBuilding(target) or string.find(target.charName,".troy") ~= nil or string.find(target.name,".troy") ~= nil or target.charName == " " or target.name == " " or target.charName == "  " or target.name == "  " or string.find(target.charName,"OdinNeutralGuardien") ~= nil or string.find(target.name,"OdinNeutralGuardien") ~= nil) and IsLolActive() then
                --local mouse = {x=GetCursorWorldX(),y=GetCursorWorldY(),z=GetCursorWorldZ()}
                ClickSpellXYZ('M',target.x,target.y+50,target.z,0)
                --ClickSpellXYZ('M',mouse.x,mouse.y,mouse.z,0)
            end
            AttackTarget(target)
            attacking = true
        end
        if lasthitting ~= nil and lasthitting then attacking = true end
        if IsValid(selfInfo,{"lastSpellPos","lastCastPos","lastCastTick"}) and GetClock() < selfInfo.lastCastTick+400 and GetDistance(selfInfo.lastCastPos,myHero) < 20 then
            if lasthitting == nil or not lasthitting then
                local target = nil
                for i=1, objManager:GetMaxObjects(), 1 do
                    local object = objManager:GetObject(i)
                    if IsValid(object) and ValidTarget(object) and object.health > 1 and (IsBuilding(object) or string.find(object.charName,".troy") == nil) then
                        if GetDistance(object,selfInfo.lastSpellPos) < 30 and (target == nil or GetDistance(object,selfInfo.lastSpellPos) < GetDistance(target,selfInfo.lastSpellPos)) then target = object end
                    end
                end
                if not IsValid(target) then return end
                for i,listName in ipairs(doNotAttackUnitNames) do
                    if listName == target.name then StopMove() end
                end
            end
        end
    end
    
    function CapturesTurret(unit)
        for i=1, objManager:GetMaxObjects(), 1 do
            local object = objManager:GetObject(i)
            if IsValid(object) then
                if object.charName == "OdinCaptureBeam.troy" or object.charName == "OdinCaptureBeamEngaged_green.troy" or object.charName == "capture_point_gauge.troy" then
                    if GetDistance(object,unit) < 50 then return true end
                end
            end
        end
        return false
    end
    
    function GetDominionTurret()
        local nearestTurret = nil
        for i=1, objManager:GetMaxObjects(), 1 do
            local object = objManager:GetObject(i)
            if IsValid(object) and object.name == "OdinNeutralGuardian" then
                if nearestTurret == nil or GetDistance(object) < GetDistance(nearestTurret) then nearestTurret = object end
            end
        end
        return nearestTurret
    end
    
    function IsBuilding(unit)
        local unn = unit.name
        local unc = unit.charName
        if string.find(unc,"Inhibit_") ~= nil or string.find(unc,"Nexus_") ~= nil or unn == "OrderTurretAngel" or unn == "OrderTurretDragon" or unn == "OrderTurretNormal2" or unn == "OrderTurretNormal" or unn == "ChaosTurretShrine" or unn == "ChaosTurretNormal" or unn == "ChaosTurretGiant" or unn == "ChaosTurretWorm2" or unn == "ChaosTurretWorm" then return true end
        return false
    end
    
    function Lasthit()
        local target = GetHighestKillableMinion()
        if target == nil and GetDistance(GetNearestTurret()) > 300 then
            lasthitting = false
        elseif target ~= nil then
            --lasthitting = true
            AttackTarget(target)
        end
    end
    
    function GetHighestKillableMinion()
        minionTarget = nil
        for i=1, objManager:GetMaxObjects(), 1 do
            local object = objManager:GetObject(i)
            if IsValid(object) then
                for i,listName in ipairs(doNotAttackUnitNames) do
                    if listName == object.name and GetDistance(object) < myHero.range+200 and (minionTarget == nil or GetDistance(minionTarget) > GetDistance(object)) then minionTarget = object end
                end
            end
        end
        return minionTarget
    end
    buyTries = 0
    countFix = 0
    function ItemBuyHandler()
        if IsChatOpen() == 0 and IsLolActive() and GetMap() == 1 and (GetDistance(baseTurret) < 1300 or myHero.dead == 1) then 
            countFix = countFix+1
            if buyTries > 4 then
                if countFix > 50 then
                    buyTries = 0
                    countFix = 0
                end
                return
            end
            dodgeing = true
            dodgetimeout = GetClock()+1500
            StopMove()
            if GetGameTime() > 10 and NoItems() then --start items
                BuyItem("sight ward")
                BuyItem("sight ward")
                BuyItem("heal")
            end
            
            for i,name in ipairs(shoppingList) do
                printtext("Checking on: "..name.."\n")
                if BoughtItem(name) then
                     tries = 0
                     countFix = 0
                     printtext("Bought: "..name.."\n")
                     table.remove(shoppingList,i)
                     return
                else
                    if myHero.gold >= itemdb[name].price then 
                    BuyItem(name) 
                    elseif myHero.gold >= 75 and not BoughtItem("Sightstone") and not BoughtItem("Ruby Sightstone") and not BoughtItem("Sight Ward") then 
                        BuyItem("Sight Ward")
                        BuyItem("Sight Ward")
                        BuyItem("Sight Ward")
                    end
                    buyTries = buyTries+1
                    return
                end
            end
        else
            buyTries = 0
            countFix = 0
        end
    end
    
    function NoItems()
        for i=1,6 do
            local id = GetInventoryItem(i)
            if id ~= 0 and id ~= 2009 and id ~= 2052 and id ~= 2050 then return false end
        end
        return true
    end
    
    function IsInventoryFull()
        for i=1,6 do
            if GetInventoryItem(i) == 0 then return false end
        end
        return true
    end
    
    function BoughtItem(name)
        for i=1,6 do
            if GetInventoryItem(i) == itemdb[name].id then return true end
        end
    end
    
    function BuyItem(name)
        os.execute("ExtAhkFuncs.exe BuyItem "..name)
    end
    shoppingList = {"Boots of Speed","Faerie Charm","Rejuvenation Bead","Philosopher's Stone","Amplifying Tome","Kage's Lucky Pick","Ruby Crystal","Sightstone","Ionian Boots of Lucidity","Ruby Crystal","Ruby Sightstone","Cloth Armor","Rejuvenation Bead","Emblem of Valor","Null-Magic Mantle","Aegis of the Legion","Ruby Crystal","Kindlegem","Shurelya's Reverie","Null-Magic Mantle","Runic Bulwark","Ruby Crystal","Kindlegem","Zeke's Herald"}
    itemdb = {
        ["Boots of Speed"] = { id = 1001, name = 'Boots of Speed', iconPath = '1001_Boots_of_Speed.png', price = 325, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 25.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Faerie Charm"] = { id = 1004, name = 'Faerie Charm', iconPath = '1004_Faerie_Charm.png', price = 180, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.6, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Rejuvenation Bead"] = { id = 1006, name = 'Rejuvenation Bead', iconPath = '1006_Rejuvenation_Bead.png', price = 180, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 1.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Giant's Belt"] = { id = 1011, name = "Giant's Belt", iconPath = '1011_Mighty_Waistband_of_the_Reaver.png', price = 1000, flatHPPoolMod = 380.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Cloak of Agility"] = { id = 1018, name = 'Cloak of Agility', iconPath = '1018_Cloak_of_Agility.png', price = 730, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.15, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Blasting Wand"] = { id = 1026, name = 'Blasting Wand', iconPath = '1026_Blasting_Band.png', price = 860, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 40.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Sapphire Crystal"] = { id = 1027, name = 'Sapphire Crystal', iconPath = '1027_Sapphire_Sphere.png', price = 400, flatHPPoolMod = 0.0, flatMPPoolMod = 200.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Ruby Crystal"] = { id = 1028, name = 'Ruby Crystal', iconPath = '1028_Ruby_Sphere.png', price = 475, flatHPPoolMod = 180.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Cloth Armor"] = { id = 1029, name = 'Cloth Armor', iconPath = '1029_Cloth_Armour.png', price = 300, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 15.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Chain Vest"] = { id = 1031, name = 'Chain Vest', iconPath = '1031_Chain_Vest.png', price = 720, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 40.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Null-Magic Mantle"] = { id = 1033, name = 'Null-Magic Mantle', iconPath = '1033_Elementium_Threaded_Cloak.png', price = 400, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 20.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Long Sword"] = { id = 1036, name = 'Long Sword', iconPath = '1036_Long_Sword.png', price = 400, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 10.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Pickaxe"] = { id = 1037, name = 'Pickaxe', iconPath = '1037_Broadsword.png', price = 875, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 25.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["B. F. Sword"] = { id = 1038, name = 'B. F. Sword', iconPath = '1038_BF_Sword.png', price = 1550, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 45.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Hunter's Machete"] = { id = 1039, name = "Hunter's Machete", iconPath = '1039_Butchers_Machete.png', price = 300, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Dagger"] = { id = 1042, name = 'Dagger', iconPath = '1042_Dagger.png', price = 400, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.12, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Recurve Bow"] = { id = 1043, name = 'Recurve Bow', iconPath = '1043_Steel_Stiletto.png', price = 950, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.3, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Brawler's Gloves"] = { id = 1051, name = "Brawler's Gloves", iconPath = '1051_Brawlers_Gloves.png', price = 400, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.08, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Amplifying Tome"] = { id = 1052, name = 'Amplifying Tome', iconPath = '1052_Amplifying_Scepter.png', price = 435, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 20.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Vampiric Scepter"] = { id = 1053, name = 'Vampiric Scepter', iconPath = '3054_Scepter_of_Death.png', price = 400, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 10.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Doran's Shield"] = { id = 1054, name = "Doran's Shield", iconPath = '033_Buckler.png', price = 475, flatHPPoolMod = 100.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 1.6, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 5.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Doran's Blade"] = { id = 1055, name = "Doran's Blade", iconPath = 'PetAttack.png', price = 475, flatHPPoolMod = 80.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 10.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Doran's Ring"] = { id = 1056, name = "Doran's Ring", iconPath = '165_Harmony_Ring.png', price = 475, flatHPPoolMod = 80.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.6, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 15.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Negatron Cloak"] = { id = 1057, name = 'Negatron Cloak', iconPath = '161_Elementium_Woven_Mantle.png', price = 720, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 40.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Needlessly Large Rod"] = { id = 1058, name = 'Needlesrsly Large Rod', iconPath = '1058_Needlessly_Large_Wand.png', price = 1600, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 80.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Prospector's Blade"] = { id = 1062, name = "Prospector's Blade", iconPath = '1062_ProspectorsBlade.png', price = 950, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 20.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Prospector's Ring"] = { id = 1063, name = "Prospector's Ring", iconPath = '1063_ProspectorsRing.png', price = 950, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 2.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 40.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Spirit Stone"] = { id = 1080, name = 'Spirit Stone', iconPath = '1080_SoulEater.png', price = 40, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 2.8, percentHPRegenMod = 0.0, flatMPRegenMod = 1.4, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Health Potion"] = { id = 2003, name = 'Health Potion', iconPath = '2003_Regeneration_Potion.png', price = 35, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Mana Potion"] = { id = 2004, name = 'Mana Potion', iconPath = '2004_Flask_of_Crystal_Water.png', price = 35, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Elixir of Fortitude"] = { id = 2037, name = 'Elixir of Fortitude', iconPath = '2037_Potion_of_Giant_Strength.png', price = 250, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Elixir of Brilliance"] = { id = 2039, name = 'Elixir of Brilliance', iconPath = '2039_Potion_of_Brilliance.png', price = 250, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Ichor of Rage"] = { id = 2040, name = 'Ichor of Rage', iconPath = '2040_Ichor_of_Rage.png', price = 500, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Crystalline Flask"] = { id = 2041, name = 'Crystalline Flask', iconPath = '2041_Crystalline_Flask.png', price = 345, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Oracle's Elixir"] = { id = 2042, name = "Oracle's Elixir", iconPath = '2026_Arcane_Protection_Potion.png', price = 400, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Vision Ward"] = { id = 2043, name = 'Vision Ward', iconPath = '096_Eye_of_the_Observer.png', price = 125, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Sight Ward"] = { id = 2044, name = 'Sight Ward', iconPath = '1020_Glowing_Orb.png', price = 75, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Ruby Sightstone"] = { id = 2045, name = 'Ruby Sightstone', iconPath = '2049_Ruby_Ward.png', price = 125, flatHPPoolMod = 360.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Oracle's Extract"] = { id = 2047, name = "Oracle's Extract", iconPath = '2047_OraclesExtract.png', price = 250, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Ichor of Illumination"] = { id = 2048, name = 'Ichor of Illumination', iconPath = '2048_Ichor_of_Illumination.png', price = 500, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Sightstone"] = { id = 2049, name = 'Sightstone', iconPath = '2049_Sightstone.png', price = 475, flatHPPoolMod = 180.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Guardian's Horn"] = { id = 2051, name = "Guardian's Horn", iconPath = '2051_Guardians_Horn.png', price = 370, flatHPPoolMod = 180.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 2.4, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Abyssal Scepter"] = { id = 3001, name = 'Abyssal Scepter', iconPath = '3001_Abyssal_Scepter.png', price = 980, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 70.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 45.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Archangel's Staff"] = { id = 3003, name = "Archangel's Staff", iconPath = '3003_Archangels_Staff_of_Apocalypse.png', price = 1140, flatHPPoolMod = 0.0, flatMPPoolMod = 250.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 2.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 60.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Manamune"] = { id = 3004, name = 'Manamune', iconPath = '3004_Manamune.png', price = 1000, flatHPPoolMod = 0.0, flatMPPoolMod = 250.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 1.42, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 20.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Atma's Impaler"] = { id = 3005, name = "Atma's Impaler", iconPath = '3005_Atmas_Impaler.png', price = 780, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 45.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.15, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Berserker's Greaves"] = { id = 3006, name = "Berserker's Greaves", iconPath = '3006_Berserkers_Greaves.png', price = 150, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.2, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Boots of Swiftness"] = { id = 3009, name = 'Boots of Swiftness', iconPath = '3009_Boots_of_Teleportation.png', price = 650, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 60.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Catalyst the Protector"] = { id = 3010, name = 'Catalyst the Protector', iconPath = '3010_Catalyst_the_Protector.png', price = 325, flatHPPoolMod = 200.0, flatMPPoolMod = 300.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Sorcerer's Shoes"] = { id = 3020, name = "Sorcerer's Shoes", iconPath = '3020_Flamewalkers.png', price = 750, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Frozen Mallet"] = { id = 3022, name = 'Frozen Mallet', iconPath = '3022_Frozen_Mallet.png', price = 835, flatHPPoolMod = 700.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 30.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Twin Shadows"] = { id = 3023, name = 'Twin Shadows', iconPath = '3023_Wraith_Collar.png', price = 735, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 40.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.06, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 40.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Glacial Shroud"] = { id = 3024, name = 'Glacial Shroud', iconPath = '3024_Glacial_Shroud.png', price = 230, flatHPPoolMod = 0.0, flatMPPoolMod = 300.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 45.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Iceborn Gauntlet"] = { id = 3025, name = 'Iceborn Gauntlet', iconPath = '3025_Frozen_Fist.png', price = 700, flatHPPoolMod = 0.0, flatMPPoolMod = 500.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 70.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 30.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Guardian Angel"] = { id = 3026, name = 'Guardian Angel', iconPath = '3026_Guardian_Angel.png', price = 1480, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 50.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 30.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Rod of Ages"] = { id = 3027, name = 'Rod of Ages', iconPath = '3027_Guinsoos_Rod_of_Oblivion.png', price = 740, flatHPPoolMod = 450.0, flatMPPoolMod = 450.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 60.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Chalice of Harmony"] = { id = 3028, name = 'Chalice of Harmony', iconPath = '3028_Harmony_Ring.png', price = 120, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 1.4, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 25.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Infinity Edge"] = { id = 3031, name = 'Infinity Edge', iconPath = '3031_Infinity_Edge.png', price = 645, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 70.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.25, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Last Whisper"] = { id = 3035, name = 'Last Whisper', iconPath = '3035_Last_Whisper.png', price = 1025, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 40.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Mana Manipulator"] = { id = 3037, name = 'Mana Manipulator', iconPath = '3037_Mana_Manipulator.png', price = 40, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Mejai's Soulstealer"] = { id = 3041, name = "Mejai's Soulstealer", iconPath = '3041_Mejais_Soulstealer.png', price = 800, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 20.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Phage"] = { id = 3044, name = 'Phage', iconPath = '3044_Phage.png', price = 590, flatHPPoolMod = 200.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 20.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Phantom Dancer"] = { id = 3046, name = 'Phantom Dancer', iconPath = '3046_Phantom_Dancer.png', price = 495, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.05, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.5, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.3, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Ninja Tabi"] = { id = 3047, name = 'Ninja Tabi', iconPath = '3047_Phase_Striders.png', price = 350, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 25.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Zeke's Herald"] = { id = 3050, name = "Zeke's Herald", iconPath = '3050_Rallying_Banner.png', price = 1700, flatHPPoolMod = 250.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Ohmwrecker"] = { id = 3056, name = 'Ohmwrecker', iconPath = '3056_Ohmwrecker.png', price = 800, flatHPPoolMod = 350.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 3.0, percentHPRegenMod = 0.0, flatMPRegenMod = 3.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 50.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Sheen"] = { id = 3057, name = 'Sheen', iconPath = '3057_Sheen.png', price = 365, flatHPPoolMod = 0.0, flatMPPoolMod = 200.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 25.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Banner of Command"] = { id = 3060, name = 'Banner of Command', iconPath = '3060_Banner_of_Command.png', price = 890, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 30.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 40.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Spirit Visage"] = { id = 3065, name = 'Spirit Visage', iconPath = '3065_Spirit_Visage.png', price = 630, flatHPPoolMod = 200.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 50.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Kindlegem"] = { id = 3067, name = 'Kindlegem', iconPath = '3067_Kindlegem.png', price = 375, flatHPPoolMod = 200.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Sunfire Cape"] = { id = 3068, name = 'Sunfire Cape', iconPath = '3068_Sunfire_Cape.png', price = 930, flatHPPoolMod = 450.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 45.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Shurelya's Reverie"] = { id = 3069, name = "Shurelya's Reverie", iconPath = '3069_Shurelyas_Firecrest.png', price = 550, flatHPPoolMod = 250.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 2.0, percentHPRegenMod = 0.0, flatMPRegenMod = 2.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Tear of the Goddess"] = { id = 3070, name = 'Tear of the Goddess', iconPath = '3070_Tear_of_the_Goddess.png', price = 120, flatHPPoolMod = 0.0, flatMPPoolMod = 250.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 1.4, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["The Black Cleaver"] = { id = 3071, name = 'The Black Cleaver', iconPath = '3071_The_Black_Cleaver.png', price = 1188, flatHPPoolMod = 200.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 50.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["The Bloodthirster"] = { id = 3072, name = 'The Bloodthirster', iconPath = '3072_The_Bloodthirster.png', price = 850, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 70.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Ravenous Hydra (Melee Only)"] = { id = 3074, name = 'Ravenous Hydra (Melee Only)', iconPath = '3074_Ravenous_Hydra.png', price = 200, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 3.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 75.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Thornmail"] = { id = 3075, name = 'Thornmail', iconPath = '3075_Thornmail.png', price = 1180, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 100.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Tiamat (Melee Only)"] = { id = 3077, name = 'Tiamat (Melee Only)', iconPath = '3077_Tiamat.png', price = 665, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 3.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 50.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Trinity Force"] = { id = 3078, name = 'Trinity Force', iconPath = '3078_Trinity_Force.png', price = 3, flatHPPoolMod = 250.0, flatMPPoolMod = 200.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 30.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 30.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.08, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.3, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.1, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Warden's Mail"] = { id = 3082, name = "Warden's Mail", iconPath = '3082_Wardens_Mail.png', price = 500, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 50.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Warmog's Armor"] = { id = 3083, name = "Warmog's Armor", iconPath = '3083_Warmog_the_Living_Armor.png', price = 995, flatHPPoolMod = 1000.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Overlord's Bloodmail"] = { id = 3084, name = "Overlord's Bloodmail", iconPath = '3084_Overlords_Bloodmail.png', price = 980, flatHPPoolMod = 850.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Runaan's Hurricane (Ranged Only)"] = { id = 3085, name = "Runaan's Hurricane (Ranged Only)", iconPath = '3085_Runaans_Hurricane.png', price = 1000, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.7, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Zeal"] = { id = 3086, name = 'Zeal', iconPath = '3058_Sheen_and_Phage.png', price = 375, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.05, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.18, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.1, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Statikk Shiv"] = { id = 3087, name = 'Statikk Shiv', iconPath = '3087_Statikk_Shiv.png', price = 525, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.06, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.4, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.2, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Rabadon's Deathcap"] = { id = 3089, name = "Rabadon's Deathcap", iconPath = '3089_Banksys_wizard_Hat.png', price = 840, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 120.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Wooglet's Witchcap"] = { id = 3090, name = "Wooglet's Witchcap", iconPath = '3090_Wooglets_Witchcap.png', price = 1060, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 40.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 100.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Wit's End"] = { id = 3091, name = "Wit's End", iconPath = '3091_Wits_End.png', price = 850, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.4, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 25.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Shard of True Ice"] = { id = 3092, name = 'Shard of True Ice', iconPath = '3092_Kages_Last_Breath.png', price = 535, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 45.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Avarice Blade"] = { id = 3093, name = 'Avarice Blade', iconPath = '3093_Avarice_Blade.png', price = 400, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.1, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Philosopher's Stone"] = { id = 3096, name = "Philosopher's Stone", iconPath = '3062_Soul_Pendant.png', price = 340, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 1.4, percentHPRegenMod = 0.0, flatMPRegenMod = 1.8, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Emblem of Valor"] = { id = 3097, name = 'Emblem of Valor', iconPath = '3052_Reverb_Coil.png', price = 170, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 20.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Kage's Lucky Pick"] = { id = 3098, name = "Kage's Lucky Pick", iconPath = '3090_Thoughtbreaker.png', price = 330, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 25.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Lich Bane"] = { id = 3100, name = 'Lich Bane', iconPath = '126_Zeal_and_Sheen.png', price = 940, flatHPPoolMod = 0.0, flatMPPoolMod = 250.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 80.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.05, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Stinger"] = { id = 3101, name = 'Stinger', iconPath = '059_Sheen.png', price = 450, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.4, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Banshee's Veil"] = { id = 3102, name = "Banshee's Veil", iconPath = '066_Sindoran_Shielding_Amulet.png', price = 600, flatHPPoolMod = 400.0, flatMPPoolMod = 300.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 45.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Aegis of the Legion"] = { id = 3105, name = 'Aegis of the Legion', iconPath = '034_Steel_Shield.png', price = 1100, flatHPPoolMod = 250.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 20.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 20.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Madred's Razors"] = { id = 3106, name = "Madred's Razors", iconPath = '139_Strygwyrs_Reaver.png', price = 100, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 25.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Runic Bulwark"] = { id = 3107, name = 'Runic Bulwark', iconPath = '3107_Runic_Bulwark.png', price = 400, flatHPPoolMod = 300.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 20.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 30.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Fiendish Codex"] = { id = 3108, name = 'Fiendish Codex', iconPath = '113_Tome_of_Minor_Necro_Compulsion.png', price = 385, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 30.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Frozen Heart"] = { id = 3110, name = 'Frozen Heart', iconPath = '122_Frozen_Heart.png', price = 550, flatHPPoolMod = 0.0, flatMPPoolMod = 400.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 95.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Mercury's Treads"] = { id = 3111, name = "Mercury's Treads", iconPath = '3008_Boots_Of_Swiftness.png', price = 450, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 25.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Malady"] = { id = 3114, name = 'Malady', iconPath = '3114_Malady.png', price = 800, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 25.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.45, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Nashor's Tooth"] = { id = 3115, name = "Nashor's Tooth", iconPath = '3115_Nashors_Tooth.png', price = 430, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 65.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.5, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Rylai's Crystal Scepter"] = { id = 3116, name = "Rylai's Crystal Scepter", iconPath = '3116_Rylais_Sceptre.png', price = 605, flatHPPoolMod = 500.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 80.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Boots of Mobility"] = { id = 3117, name = 'Boots of Mobility', iconPath = '3004_Assault_Treads.png', price = 650, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 105.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Executioner's Calling"] = { id = 3123, name = "Executioner's Calling", iconPath = '3069_Sword_of_Light_and_Shadow.png', price = 700, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 25.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.2, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Guinsoo's Rageblade"] = { id = 3124, name = "Guinsoo's Rageblade", iconPath = '3064_Spike_the_Ripper.png', price = 865, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 30.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 40.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Deathfire Grasp"] = { id = 3128, name = 'Deathfire Grasp', iconPath = '055_Borses_Staff_of_Apocalypse.png', price = 680, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 120.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Sword of the Divine"] = { id = 3131, name = 'Sword of the Divine', iconPath = '3084_Widowmaker.png', price = 850, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["The Brutalizer"] = { id = 3134, name = 'The Brutalizer', iconPath = '037_Big_Stick.png', price = 537, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 25.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Void Staff"] = { id = 3135, name = 'Void Staff', iconPath = '073_Zettas_Mana-Stick.png', price = 1000, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 70.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Haunting Guise"] = { id = 3136, name = 'Haunting Guise', iconPath = '3014_Doppleganker.png', price = 575, flatHPPoolMod = 200.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 25.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Mercurial Scimitar"] = { id = 3139, name = 'Mercurial Scimitar', iconPath = '3139_Mercurial_Scimitar.png', price = 600, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 60.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 45.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Quicksilver Sash"] = { id = 3140, name = 'Quicksilver Sash', iconPath = '1008_Sash_of_Valor.png', price = 830, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 45.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Sword of the Occult"] = { id = 3141, name = 'Sword of the Occult', iconPath = '3034_Kenyus_Kukri.png', price = 800, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 10.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Youmuu's Ghostblade"] = { id = 3142, name = "Youmuu's Ghostblade", iconPath = '3142_Youmus_Spectral_Blade.png', price = 563, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 30.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.15, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Randuin's Omen"] = { id = 3143, name = "Randuin's Omen", iconPath = '3143_Randuins_Omen.png', price = 1000, flatHPPoolMod = 500.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 70.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Bilgewater Cutlass"] = { id = 3144, name = 'Bilgewater Cutlass', iconPath = '3144_Bilgewater_Cutlass.png', price = 200, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 25.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Hextech Revolver"] = { id = 3145, name = 'Hextech Revolver', iconPath = '3145_Hextech_Revolver.png', price = 330, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 40.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Hextech Gunblade"] = { id = 3146, name = 'Hextech Gunblade', iconPath = '3146_Hextech_Gunblade.png', price = 800, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 45.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 65.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Liandry's Torment"] = { id = 3151, name = "Liandry's Torment", iconPath = '3151_Liandrys_Lament.png', price = 980, flatHPPoolMod = 300.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 50.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Will of the Ancients"] = { id = 3152, name = 'Will of the Ancients', iconPath = '2008_Tome_of_Combat_Mastery.png', price = 585, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 50.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Blade of the Ruined King"] = { id = 3153, name = 'Blade of the Ruined King', iconPath = '3153_Blade_of_the_Ruined_King.png', price = 1000, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 25.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.4, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Wriggle's Lantern"] = { id = 3154, name = "Wriggle's Lantern", iconPath = '3154_WriggleLantern.png', price = 100, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 30.0, percentArmorMod = 0.0, flatAttackDamageMod = 15.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Hexdrinker"] = { id = 3155, name = 'Hexdrinker', iconPath = '3155_Hexdrinker.png', price = 550, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 25.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 25.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Maw of Malmortius"] = { id = 3156, name = 'Maw of Malmortius', iconPath = '3156_PhaseBlade.png', price = 975, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 55.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 36.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Zhonya's Hourglass"] = { id = 3157, name = "Zhonya's Hourglass", iconPath = '3157_Zhonyas_Hourglass.png', price = 500, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 50.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 120.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Ionian Boots of Lucidity"] = { id = 3158, name = 'Ionian Boots of Lucidity', iconPath = '3158_Ionian_Boots_of_Lucidity.png', price = 700, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Grez's Spectral Lantern"] = { id = 3159, name = "Grez's Spectral Lantern", iconPath = '3159_Soulsight_Lantern.png', price = 150, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 20.0, percentArmorMod = 0.0, flatAttackDamageMod = 20.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Morellonomicon"] = { id = 3165, name = 'Morellonomicon', iconPath = '3165_Noxusnomicon.png', price = 435, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 2.4, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 75.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Bonetooth Necklace"] = { id = 3166, name = 'Bonetooth Necklace', iconPath = '3166_RengarTrophy.png', price = 800, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 5.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Zephyr"] = { id = 3172, name = 'Zephyr', iconPath = '3172_Zephyr.png', price = 725, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 25.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.1, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.5, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Eleisa's Miracle"] = { id = 3173, name = "Eleisa's Miracle", iconPath = '3173_Eleisas_Miracle.png', price = 400, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 2.0, percentHPRegenMod = 0.0, flatMPRegenMod = 3.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Athene's Unholy Grail"] = { id = 3174, name = "Athene's Unholy Grail", iconPath = '3174_AthenesUnholyGrail.png', price = 900, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 3.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 60.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 40.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Odyn's Veil"] = { id = 3180, name = "Odyn's Veil", iconPath = '3180_OdynsVeil.png', price = 600, flatHPPoolMod = 350.0, flatMPPoolMod = 350.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 50.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Sanguine Blade"] = { id = 3181, name = 'Sanguine Blade', iconPath = '3181_SanguineBlade.png', price = 500, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 65.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Entropy"] = { id = 3184, name = 'Entropy', iconPath = '3184_FrozenWarhammer.png', price = 600, flatHPPoolMod = 275.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 70.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["The Lightbringer"] = { id = 3185, name = 'The Lightbringer', iconPath = '3185_Lightbringer.png', price = 300, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 20.0, percentArmorMod = 0.0, flatAttackDamageMod = 50.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Kitae's Bloodrazor"] = { id = 3186, name = "Kitae's Bloodrazor", iconPath = '3186_KitaesBloodrazor.png', price = 700, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 30.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.4, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Hextech Sweeper"] = { id = 3187, name = 'Hextech Sweeper', iconPath = '3187_HextechSweeper.png', price = 200, flatHPPoolMod = 300.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 50.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Blackfire Torch"] = { id = 3188, name = 'Blackfire Torch', iconPath = '3188_Blackfire_Torch.png', price = 700, flatHPPoolMod = 250.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 80.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Locket of the Iron Solari"] = { id = 3190, name = 'Locket of the Iron Solari', iconPath = '3190_Crest_of_the_Iron_Solari.png', price = 520, flatHPPoolMod = 300.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 2.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 35.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Seeker's Armguard"] = { id = 3191, name = "Seeker's Armguard", iconPath = '3191_Seekers_Armguard.png', price = 125, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 30.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 20.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Augment: Power"] = { id = 3196, name = 'Augment: Power', iconPath = '3196_AugmentQ.png', price = 1000, flatHPPoolMod = 220.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 1.2, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Augment: Gravity"] = { id = 3197, name = 'Augment: Gravity', iconPath = '3197_AugmentW.png', price = 1000, flatHPPoolMod = 0.0, flatMPPoolMod = 200.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 1.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Augment: Death"] = { id = 3198, name = 'Augment: Death', iconPath = '3198_AugmentE.png', price = 1000, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 45.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Spirit of the Spectral Wraith"] = { id = 3206, name = 'Spirit of the Spectral Wraith', iconPath = '3206_SoulEaterWraith.png', price = 100, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 2.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 50.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Spirit of the Ancient Golem"] = { id = 3207, name = 'Spirit of the Ancient Golem', iconPath = '3207_SoulEaterGolem.png', price = 600, flatHPPoolMod = 500.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 2.8, percentHPRegenMod = 0.0, flatMPRegenMod = 1.4, percentMPRegenMod = 0.0, flatArmorMod = 30.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Spirit of the Elder Lizard"] = { id = 3209, name = 'Spirit of the Elder Lizard', iconPath = '3209_SoulEaterLizard.png', price = 725, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 2.8, percentHPRegenMod = 0.0, flatMPRegenMod = 1.4, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 50.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Mikael's Crucible"] = { id = 3222, name = "Mikael's Crucible", iconPath = '3222_Mikaels_Crucible.png', price = 920, flatHPPoolMod = 0.0, flatMPPoolMod = 300.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 1.8, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 40.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Enchantment: Homeguard"] = { id = 3250, name = 'Enchantment: Homeguard', iconPath = '3006_Berserkers_Greaves_A.png', price = 475, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.2, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Captain"] = { id = 3251, name = 'Enchantment: Captain', iconPath = '3006_Berserkers_Greaves_B.png', price = 750, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.2, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Furor"] = { id = 3252, name = 'Enchantment: Furor', iconPath = '3006_Berserkers_Greaves_C.png', price = 650, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.2, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Distortion"] = { id = 3253, name = 'Enchantment: Distortion', iconPath = '3006_Berserkers_Greaves_D.png', price = 475, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.2, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Alacrity"] = { id = 3254, name = 'Enchantment: Alacrity', iconPath = '3006_Berserkers_Greaves_E.png', price = 475, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 60.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.2, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Homeguard"] = { id = 3255, name = 'Enchantment: Homeguard', iconPath = '3020_Flamewalkers_A.png', price = 475, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Captain"] = { id = 3256, name = 'Enchantment: Captain', iconPath = '3020_Flamewalkers_B.png', price = 750, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Furor"] = { id = 3257, name = 'Enchantment: Furor', iconPath = '3020_Flamewalkers_C.png', price = 650, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Distortion"] = { id = 3258, name = 'Enchantment: Distortion', iconPath = '3020_Flamewalkers_D.png', price = 475, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Alacrity"] = { id = 3259, name = 'Enchantment: Alacrity', iconPath = '3020_Flamewalkers_E.png', price = 475, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 60.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Homeguard"] = { id = 3260, name = 'Enchantment: Homeguard', iconPath = '3047_Phase_Striders_A.png', price = 475, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 25.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Captain"] = { id = 3261, name = 'Enchantment: Captain', iconPath = '3047_Phase_Striders_B.png', price = 750, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 25.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Furor"] = { id = 3262, name = 'Enchantment: Furor', iconPath = '3047_Phase_Striders_C.png', price = 650, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 25.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Distortion"] = { id = 3263, name = 'Enchantment: Distortion', iconPath = '3047_Phase_Striders_D.png', price = 475, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 25.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Alacrity"] = { id = 3264, name = 'Enchantment: Alacrity', iconPath = '3047_Phase_Striders_E.png', price = 475, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 25.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 60.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Homeguard"] = { id = 3265, name = 'Enchantment: Homeguard', iconPath = '3008_Boots_Of_Swiftness_A.png', price = 475, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 25.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Captain"] = { id = 3266, name = 'Enchantment: Captain', iconPath = '3008_Boots_Of_Swiftness_B.png', price = 750, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 25.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Furor"] = { id = 3267, name = 'Enchantment: Furor', iconPath = '3008_Boots_Of_Swiftness_C.png', price = 650, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 25.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Distortion"] = { id = 3268, name = 'Enchantment: Distortion', iconPath = '3008_Boots_Of_Swiftness_D.png', price = 475, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 25.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Alacrity"] = { id = 3269, name = 'Enchantment: Alacrity', iconPath = '3008_Boots_Of_Swiftness_E.png', price = 475, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 60.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 25.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Homeguard"] = { id = 3270, name = 'Enchantment: Homeguard', iconPath = '3004_Assault_Treads_A.png', price = 475, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 105.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Captain"] = { id = 3271, name = 'Enchantment: Captain', iconPath = '3004_Assault_Treads_B.png', price = 750, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 105.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Furor"] = { id = 3272, name = 'Enchantment: Furor', iconPath = '3004_Assault_Treads_C.png', price = 650, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 105.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Distortion"] = { id = 3273, name = 'Enchantment: Distortion', iconPath = '3004_Assault_Treads_D.png', price = 475, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 105.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Alacrity"] = { id = 3274, name = 'Enchantment: Alacrity', iconPath = '3004_Assault_Treads_E.png', price = 475, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 120.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Homeguard"] = { id = 3275, name = 'Enchantment: Homeguard', iconPath = '3158_Ionian_Boots_of_Lucidity_A.png', price = 475, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Captain"] = { id = 3276, name = 'Enchantment: Captain', iconPath = '3158_Ionian_Boots_of_Lucidity_B.png', price = 750, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Furor"] = { id = 3277, name = 'Enchantment: Furor', iconPath = '3158_Ionian_Boots_of_Lucidity_C.png', price = 650, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Distortion"] = { id = 3278, name = 'Enchantment: Distortion', iconPath = '3158_Ionian_Boots_of_Lucidity_D.png', price = 475, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Alacrity"] = { id = 3279, name = 'Enchantment: Alacrity', iconPath = '3158_Ionian_Boots_of_Lucidity_E.png', price = 475, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 60.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Homeguard"] = { id = 3280, name = 'Enchantment: Homeguard', iconPath = '3009_Boots_of_Teleportation_A.png', price = 475, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 60.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Captain"] = { id = 3281, name = 'Enchantment: Captain', iconPath = '3009_Boots_of_Teleportation_B.png', price = 750, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 60.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Furor"] = { id = 3282, name = 'Enchantment: Furor', iconPath = '3009_Boots_of_Teleportation_C.png', price = 650, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 60.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Distortion"] = { id = 3283, name = 'Enchantment: Distortion', iconPath = '3009_Boots_of_Teleportation_D.png', price = 475, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 60.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Alacrity"] = { id = 3284, name = 'Enchantment: Alacrity', iconPath = '3009_Boots_of_Teleportation_E.png', price = 475, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 75.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
    }

    function SpellLevelHandler()
        local skillOrder = {"W","E","W","E","W","R","W","E","W","E","R","E","Q","Q","Q","R","Q","Q"}
        local spellLevelSum = GetSpellLevel("Q") + GetSpellLevel("W") + GetSpellLevel("E") + GetSpellLevel("R")
        if spellLevelSum < myHero.selflevel then LevelSpell(skillOrder[spellLevelSum+1]) end
    end

    function LevelSpell(letter)
        if IsLolActive() and IsChatOpen() == 0 then
            os.execute("ExtAhkFuncs.exe LevelSpell "..letter)
            --if letter == "Q" then send.key_press(0x69)
            --elseif letter == "W" then send.key_press(0x6A)
            --elseif letter == "E" then send.key_press(0x6B)
            --elseif letter == "R" then send.key_press(0x6C) end
        end
    end
    --[[ Old Levelspell
    --function LevelSpell_OLD(letter)
    --    print('LevelSpell OLD', letter)
    --    if IsLolActive() and IsChatOpen() == 0 then
    --        print('Valid time to level spell OLD', letter)
    --        send.key_down(SKeys.Control)
    --        send.wait(100)
    --        if letter == "Q" then send.key_down(SKeys.Q)
    --        elseif letter == "W" then send.key_down(SKeys.W)
    --        elseif letter == "E" then send.key_down(SKeys.E)
    --        elseif letter == "R" then send.key_down(SKeys.R) end
    --        send.wait(100)
    --        if letter == "Q" then send.key_up(SKeys.Q)
    --        elseif letter == "W" then send.key_up(SKeys.W)
    --        elseif letter == "E" then send.key_up(SKeys.E)
    --        elseif letter == "R" then send.key_up(SKeys.R) end
    --        send.wait(100)
    --        send.key_up(SKeys.Control)
    --    end
    --end
    ]]--
    
    function Test_OnLoadDodge()
        cc = 0
        skillshotArray = {}
        colorcyan = 0x0000FFFF
        coloryellow = 0xFFFFFF00
        colorgreen = 0xFF00FF00
        skillshotcharexist = false
        show_allies = 0
        firstDodge = false
    end
    
    function DodgeHandler()
        if firstDodge == nil then Test_OnLoadDodge() end
        if dodgetimeout ~= nil and GetClock() > dodgetimeout then dodgeing = false end
        Skillshots()
        send.tick()
    end
    
    function Test_DodgeHandler(unit,spell)
        local P1 = spell.startPos
        local P2 = spell.endPos
        local calc = (math.floor(math.sqrt((P2.x-unit.x)^2 + (P2.z-unit.z)^2)))
        if string.find(unit.name,"Minion_") == nil and string.find(unit.name,"Turret_") == nil then
                if (unit.team ~= myHero.team or (show_allies==1)) and string.find(spell.name,"Basic") == nil then
                        for i=1, #skillshotArray, 1 do
                                local maxdist
                                local dodgeradius
                                dodgeradius = skillshotArray[i].radius
                                maxdist = skillshotArray[i].maxdistance
                                if spell.name == skillshotArray[i].name then
                                        skillshotArray[i].shot = 1
                                        skillshotArray[i].lastshot = os.clock()
                                        if skillshotArray[i].type == 1 then
                                                skillshotArray[i].p1x = unit.x
                                                skillshotArray[i].p1y = unit.y
                                                skillshotArray[i].p1z = unit.z
                                                skillshotArray[i].p2x = unit.x + (maxdist)/calc*(P2.x-unit.x)
                                                skillshotArray[i].p2y = P2.y
                                                skillshotArray[i].p2z = unit.z + (maxdist)/calc*(P2.z-unit.z)
                                                dodgelinepass(unit, P2, dodgeradius, maxdist)
                                        elseif skillshotArray[i].type == 2 then
                                                skillshotArray[i].px = P2.x
                                                skillshotArray[i].py = P2.y
                                                skillshotArray[i].pz = P2.z
                                                dodgelinepoint(unit, P2, dodgeradius)
                                        elseif skillshotArray[i].type == 3 then
                                                skillshotArray[i].skillshotpoint = calculateLineaoe(unit, P2, maxdist)
                                                if skillshotArray[i].name ~= "SummonerClairvoyance" then
                                                        dodgeaoe(unit, P2, dodgeradius)
                                                end
                                        elseif skillshotArray[i].type == 4 then
                                                skillshotArray[i].px = unit.x + (maxdist)/calc*(P2.x-unit.x)
                                                skillshotArray[i].py = P2.y
                                                skillshotArray[i].pz = unit.z + (maxdist)/calc*(P2.z-unit.z)
                                                dodgelinepass(unit, P2, dodgeradius, maxdist)
                                        elseif skillshotArray[i].type == 5 then
                                                skillshotArray[i].skillshotpoint = calculateLineaoe2(unit, P2, maxdist)
                                                dodgeaoe(unit, P2, dodgeradius)
                                        end
                                end
                        end
                end
        end
    end
        
    function dodgeaoe(pos1, pos2, radius)
            --print('dodgeaoe', pos1, pos2, radius, maxDist)
            --print('dodgeaoe:pos1:', pos1.x, pos1.y, pos1.z)
            --print('dodgeaoe:pos2:', pos2.x, pos2.y, pos2.z)
            local calc = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
            local dodgex
            local dodgez
            dodgex = pos2.x + ((radius+50)/calc)*(myHero.x-pos2.x)
            dodgez = pos2.z + ((radius+50)/calc)*(myHero.z-pos2.z)
            if calc < radius then
                    send.block_input(true,500)
                    dodgeing = true
                    dodgetimeout = GetClock()+500
            MoveToXYZ(dodgex,0,dodgez)
            end
    end
     
    function dodgelinepoint(pos1, pos2, radius)
            local calc1 = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
            local calc2 = (math.floor(math.sqrt((pos1.x-myHero.x)^2 + (pos1.z-myHero.z)^2)))
            local calc4 = (math.floor(math.sqrt((pos1.x-pos2.x)^2 + (pos1.z-pos2.z)^2)))
            local calc3
            local perpendicular
            local k
            local x4
            local z4
            local dodgex
            local dodgez
            perpendicular = (math.floor((math.abs((pos2.x-pos1.x)*(pos1.z-myHero.z)-(pos1.x-myHero.x)*(pos2.z-pos1.z)))/(math.sqrt((pos2.x-pos1.x)^2 + (pos2.z-pos1.z)^2))))
            k = ((pos2.z-pos1.z)*(myHero.x-pos1.x) - (pos2.x-pos1.x)*(myHero.z-pos1.z)) / ((pos2.z-pos1.z)^2 + (pos2.x-pos1.x)^2)
            x4 = myHero.x - k * (pos2.z-pos1.z)
            z4 = myHero.z + k * (pos2.x-pos1.x)
            calc3 = (math.floor(math.sqrt((x4-myHero.x)^2 + (z4-myHero.z)^2)))
            dodgex = x4 + ((radius+50)/calc3)*(myHero.x-x4)
            dodgez = z4 + ((radius+50)/calc3)*(myHero.z-z4)
            if perpendicular < radius and calc1 < calc4 and calc2 < calc4 then
                    send.block_input(true,500)
            dodgeing = true
            dodgetimeout = GetClock()+500
            MoveToXYZ(dodgex,0,dodgez)
            end
    end
     
    function dodgelinepass(pos1, pos2, radius, maxDist)
            --print('dodgelinepass', pos1, pos2, radius, maxDist)
            --print('dodgelinepass:pos1:', pos1.x, pos1.y, pos1.z)
            --print('dodgelinepass:pos2:', pos2.x, pos2.y, pos2.z)
            local pm2x = pos1.x + (maxDist)/(math.floor(math.sqrt((pos1.x-pos2.x)^2 + (pos1.z-pos2.z)^2)))*(pos2.x-pos1.x)
            local pm2z = pos1.z + (maxDist)/(math.floor(math.sqrt((pos1.x-pos2.x)^2 + (pos1.z-pos2.z)^2)))*(pos2.z-pos1.z)
            local calc1 = (math.floor(math.sqrt((pm2x-myHero.x)^2 + (pm2z-myHero.z)^2)))
            local calc2 = (math.floor(math.sqrt((pos1.x-myHero.x)^2 + (pos1.z-myHero.z)^2)))
            local calc3
            local calc4 = (math.floor(math.sqrt((pos1.x-pm2x)^2 + (pos1.z-pm2z)^2)))
            local perpendicular
            local k
            local x4
            local z4
            local dodgex
            local dodgez
            perpendicular = (math.floor((math.abs((pm2x-pos1.x)*(pos1.z-myHero.z)-(pos1.x-myHero.x)*(pm2z-pos1.z)))/(math.sqrt((pm2x-pos1.x)^2 + (pm2z-pos1.z)^2))))
            k = ((pm2z-pos1.z)*(myHero.x-pos1.x) - (pm2x-pos1.x)*(myHero.z-pos1.z)) / ((pm2z-pos1.z)^2 + (pm2x-pos1.x)^2)
            x4 = myHero.x - k * (pm2z-pos1.z)
            z4 = myHero.z + k * (pm2x-pos1.x)
            calc3 = (math.floor(math.sqrt((x4-myHero.x)^2 + (z4-myHero.z)^2)))
            dodgex = x4 + ((radius+50)/calc3)*(myHero.x-x4)
            dodgez = z4 + ((radius+50)/calc3)*(myHero.z-z4)
            if perpendicular < radius and calc1 < calc4 and calc2 < calc4 then
                    send.block_input(true,500)
            dodgeing = true
            dodgetimeout = GetClock()+500
            MoveToXYZ(dodgex,0,dodgez)
            end
    end
     
    function calculateLinepass(pos1, pos2, spacing, maxDist)
            local calc = (math.floor(math.sqrt((pos2.x-pos1.x)^2 + (pos2.z-pos1.z)^2)))
            local line = {}
            local point1 = {}
            point1.x = pos1.x
            point1.y = pos1.y
            point1.z = pos1.z
            local point2 = {}
            point1.x = pos1.x + (maxDist)/calc*(pos2.x-pos1.x)
            point1.y = pos2.y
            point1.z = pos1.z + (maxDist)/calc*(pos2.z-pos1.z)
            table.insert(line, point2)
            table.insert(line, point1)
            return line
    end
     
    function calculateLineaoe(pos1, pos2, maxDist)
            local line = {}
            local point = {}
            point.x = pos2.x
            point.y = pos2.y
            point.z = pos2.z
            table.insert(line, point)
            return line
    end
     
    function calculateLineaoe2(pos1, pos2, maxDist)
            local calc = (math.floor(math.sqrt((pos2.x-pos1.x)^2 + (pos2.z-pos1.z)^2)))
            local line = {}
            local point = {}
                    if calc < maxDist then
                    point.x = pos2.x
                    point.y = pos2.y
                    point.z = pos2.z
                    table.insert(line, point)
            else
                    point.x = pos1.x + maxDist/calc*(pos2.x-pos1.x)
                    point.z = pos1.z + maxDist/calc*(pos2.z-pos1.z)
                    point.y = pos2.y
                    table.insert(line, point)
            end
            return line
    end
     
    function calculateLinepoint(pos1, pos2, spacing, maxDist)
            local line = {}
            local point1 = {}
            point1.x = pos1.x
            point1.y = pos1.y
            point1.z = pos1.z
            local point2 = {}
            point1.x = pos2.x
            point1.y = pos2.y
            point1.z = pos2.z
            table.insert(line, point2)
            table.insert(line, point1)
            return line
    end
     
    function table_print (tt, indent, done)
            done = done or {}
            indent = indent or 0
            if type(tt) == "table" then
                    local sb = {}
                    for key, value in pairs (tt) do
                            table.insert(sb, string.rep (" ", indent)) -- indent it
                            if type (value) == "table" and not done [value] then
                                    done [value] = true
                                    table.insert(sb, "{\n");
                                    table.insert(sb, table_print (value, indent + 2, done))
                                    table.insert(sb, string.rep (" ", indent)) -- indent it
                                    table.insert(sb, "}\n");
                            elseif "number" == type(key) then
                                    table.insert(sb, string.format("\"%s\"\n", tostring(value)))
                            else
                                    table.insert(sb, string.format(
                                    "%s = \"%s\"\n", tostring (key), tostring(value)))
                            end
                    end
                    return table.concat(sb)
            else
            return tt .. "\n"
            end
    end
     
    function Skillshots()
            cc=cc+1
            if (cc==30) then
                    LoadTable()
            end
            for i=1, #skillshotArray, 1 do
                    if skillshotArray[i].shot == 1 then
                            local radius = skillshotArray[i].radius
                            local color = skillshotArray[i].color
                            if skillshotArray[i].isline == false then
                                    for number, point in pairs(skillshotArray[i].skillshotpoint) do
                                            DrawCircle(point.x, point.y, point.z, radius, color)
                                    end
                            else
                                    startVector = Vector(skillshotArray[i].p1x,skillshotArray[i].p1y,skillshotArray[i].p1z)
                                    endVector = Vector(skillshotArray[i].p2x,skillshotArray[i].p2y,skillshotArray[i].p2z)
                                    directionVector = (endVector-startVector):normalized()
                                    local angle=0
                                    if (math.abs(directionVector.x)<.00001) then
                                            if directionVector.z > 0 then angle=90
                                            elseif directionVector.z < 0 then angle=270
                                            else angle=0
                                            end
                                    else
                                            local theta = math.deg(math.atan(directionVector.z / directionVector.x))
                                            if directionVector.x < 0 then theta = theta + 180 end
                                                    if theta < 0 then theta = theta + 360 end
                                                            angle=theta
                                                    end
                                                            angle=((90-angle)*2*math.pi)/360
                                                            DrawLine(startVector.x, startVector.y, startVector.z, GetDistance(startVector, endVector)+170, 1,angle,radius)
                                            end
                                    end
                            end
            for i=1, #skillshotArray, 1 do
                    if os.clock() > (skillshotArray[i].lastshot + skillshotArray[i].time) then
                    skillshotArray[i].shot = 0
                    end
            end
    end
     
    function LoadTable()
            --print("table loaded::")
            table.insert(skillshotArray,{name= "SummonerClairvoyance", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 50000, type = 3, radius = 1300, color= coloryellow, time = 6})
            local iCount=objManager:GetMaxHeroes()
            --print(" heros:" .. tostring(iCount))
            iCount=1;
            for i=0, iCount, 1 do
                    local skillshotplayerObj = GetSelf();
                    --print(" name:" .. skillshotplayerObj.name);
                    if 1==1 or skillshotplayerObj.name == "Quinn" then
                            table.insert(skillshotArray,{name= "QuinnQMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1025, type = 1, radius = 40, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Lissandra" then
                            table.insert(skillshotArray,{name= "LissandraQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 725, type = 1, radius = 100, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "LissandraE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 100, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Zac" then
                            table.insert(skillshotArray,{name= "ZacQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 550, type = 1, radius = 100, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "ZacE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1550, type = 3, radius = 200, color= colorcyan, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Syndra" then
                            table.insert(skillshotArray,{name= "SyndraQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 200, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "SyndraE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 1, radius = 100, color= coloryellow, time = 0.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "syndrawcast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 200, color= colorcyan, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Jayce" then
                            table.insert(skillshotArray,{name= "jayceshockblast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1470, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Nami" then
                            table.insert(skillshotArray,{name= "NamiQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 875, type = 3, radius = 200, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "NamiR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2550, type = 1, radius = 350, color= colorcyan, time = 3, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Vi" then
                            table.insert(skillshotArray,{name= "ViQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 150, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            skillshotcharexist = true
                    end
                            if 1==1 or skillshotplayerObj.name == "Thresh" then
                            table.insert(skillshotArray,{name= "ThreshQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Khazix" then
                            table.insert(skillshotArray,{name= "KhazixE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 3, radius = 200, color= colorcyan, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "KhazixW", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 120, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "khazixwlong", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "khazixelong", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 200, color= colorcyan, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Elise" then
                            table.insert(skillshotArray,{name= "EliseHumanE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Zed" then
                            table.insert(skillshotArray,{name= "ZedShuriken", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 100, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "ZedShadowDash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 550, type = 3, radius = 150, color= colorcyan, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "zedw2", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 550, type = 3, radius = 150, color= colorcyan, time = 0.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Ahri" then
                            table.insert(skillshotArray,{name= "AhriOrbofDeception", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 880, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                            table.insert(skillshotArray,{name= "AhriSeduce", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Amumu" then
                            table.insert(skillshotArray,{name= "BandageToss", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Anivia" then
                            table.insert(skillshotArray,{name= "FlashFrostSpell", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 90, color= colorcyan, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Ashe" then
                            table.insert(skillshotArray,{name= "EnchantedCrystalArrow", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 50000, type = 4, radius = 120, color= colorcyan, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Blitzcrank" then
                            table.insert(skillshotArray,{name= "RocketGrabMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Brand" then
                            table.insert(skillshotArray,{name= "BrandBlazeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 70, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                            table.insert(skillshotArray,{name= "BrandFissure", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Cassiopeia" then
                            table.insert(skillshotArray,{name= "CassiopeiaMiasma", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 175, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "CassiopeiaNoxiousBlast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 75, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Caitlyn" then
                            table.insert(skillshotArray,{name= "CaitlynEntrapmentMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 50, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "CaitlynPiltoverPeacemaker", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Corki" then
                            table.insert(skillshotArray,{name= "MissileBarrageMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1225, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "MissileBarrageMissile2", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1225, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "CarpetBomb", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 2, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Chogath" then
                            table.insert(skillshotArray,{name= "Rupture", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 275, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "DrMundo" then
                            table.insert(skillshotArray,{name= "InfectedCleaverMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Heimerdinger" then
                            table.insert(skillshotArray,{name= "CH1ConcussionGrenade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 225, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Draven" then
                            table.insert(skillshotArray,{name= "DravenDoubleShot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 125, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                            table.insert(skillshotArray,{name= "DravenRCast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 1, radius = 100, color= colorcyan, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Ezreal" then
                            table.insert(skillshotArray,{name= "EzrealEssenceFluxMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                            table.insert(skillshotArray,{name= "EzrealMysticShotMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                            table.insert(skillshotArray,{name= "EzrealTrueshotBarrage", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 4, radius = 150, color= colorcyan, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                            table.insert(skillshotArray,{name= "EzrealArcaneShift", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 475, type = 5, radius = 100, color= colorgreen, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Fizz" then
                            table.insert(skillshotArray,{name= "FizzMarinerDoom", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1275, type = 2, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "FiddleSticks" then
                            table.insert(skillshotArray,{name= "Crowstorm", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 600, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Karthus" then
                            table.insert(skillshotArray,{name= "LayWaste", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 875, type = 3, radius = 150, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Galio" then
                            table.insert(skillshotArray,{name= "GalioResoluteSmite", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 905, type = 3, radius = 200, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "GalioRighteousGust", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 120, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Graves" then
                            table.insert(skillshotArray,{name= "GravesChargeShot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 110, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "GravesClusterShot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 750, type = 1, radius = 50, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "GravesSmokeGrenade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 3, radius = 275, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Gragas" then
                            table.insert(skillshotArray,{name= "GragasBarrelRoll", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 320, color= coloryellow, time = 2.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "GragasBodySlam", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 2, radius = 60, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "GragasExplosiveCask", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 3, radius = 400, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Irelia" then
                            table.insert(skillshotArray,{name= "IreliaTranscendentBlades", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 150, color= colorcyan, time = 0.8, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Janna" then
                            table.insert(skillshotArray,{name= "HowlingGale", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1700, type = 1, radius = 100, color= colorcyan, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "JarvanIV" then
                            table.insert(skillshotArray,{name= "JarvanIVDemacianStandard", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 830, type = 3, radius = 150, color= coloryellow, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "JarvanIVDragonStrike", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 770, type = 1, radius = 70, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "JarvanIVCataclysm", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 3, radius = 300, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Kassadin" then
                            table.insert(skillshotArray,{name= "RiftWalk", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 5, radius = 150, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Katarina" then
                            table.insert(skillshotArray,{name= "ShadowStep", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 3, radius = 75, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Kennen" then
                            table.insert(skillshotArray,{name= "KennenShurikenHurlMissile1", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 75, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "KogMaw" then
                            table.insert(skillshotArray,{name= "KogMawVoidOozeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1115, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "KogMawLivingArtillery", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2200, type = 3, radius = 200, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Leblanc" then
                            table.insert(skillshotArray,{name= "LeblancSoulShackle", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "LeblancSoulShackleM", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "LeblancSlide", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "LeblancSlideM", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                            table.insert(skillshotArray,{name= "leblancslidereturn", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 50, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                            table.insert(skillshotArray,{name= "leblancslidereturnm", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 50, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "LeeSin" then
                            table.insert(skillshotArray,{name= "BlindMonkQOne", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "BlindMonkRKick", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Leona" then
                            table.insert(skillshotArray,{name= "LeonaZenithBladeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Lux" then
                            table.insert(skillshotArray,{name= "LuxLightBinding", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1175, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            --table.insert(skillshotArray,{name= "LuxLightStrikeKugel", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 300, color= coloryellow, time = 2.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "LuxMaliceCannon", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 3000, type = 1, radius = 180, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Lulu" then
                            table.insert(skillshotArray,{name= "LuluQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 50, color= colorcyan, time = 1, isline = true, px =0, py =0 , pz =0, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Maokai" then
                            table.insert(skillshotArray,{name= "MaokaiTrunkLineMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "MaokaiSapling2", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 350 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Malphite" then
                            table.insert(skillshotArray,{name= "UFSlash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 325, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Malzahar" then
                            table.insert(skillshotArray,{name= "AlZaharCalloftheVoid", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 100 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "AlZaharNullZone", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 250 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    --if 1==1 or skillshotplayerObj.name == "MissFortune" then
                    --        table.insert(skillshotArray,{name= "MissFortuneScattershot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 400, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                    --skillshotcharexist = true
                    --end
                    if 1==1 or skillshotplayerObj.name == "Morgana" then
                            table.insert(skillshotArray,{name= "DarkBindingMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 90, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "TormentedSoil", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 300, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Nautilus" then
                            table.insert(skillshotArray,{name= "NautilusAnchorDrag", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 1, radius = 150, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Nidalee" then
                            table.insert(skillshotArray,{name= "JavelinToss", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1500, type = 1, radius = 150, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Nocturne" then
                            table.insert(skillshotArray,{name= "NocturneDuskbringer", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 150, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Olaf" then
                            table.insert(skillshotArray,{name= "OlafAxeThrow", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 2, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Orianna" then
                            table.insert(skillshotArray,{name= "OrianaIzunaCommand", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 825, type = 3, radius = 150, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Renekton" then
                            table.insert(skillshotArray,{name= "RenektonSliceAndDice", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 450, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                            table.insert(skillshotArray,{name= "renektondice", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 450, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Rumble" then
                            table.insert(skillshotArray,{name= "RumbleGrenadeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                            table.insert(skillshotArray,{name= "RumbleCarpetBomb", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1700, type = 1, radius = 100, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Sivir" then
                            table.insert(skillshotArray,{name= "SpiralBlade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Singed" then
                            table.insert(skillshotArray,{name= "MegaAdhesive", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 350, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Shen" then
                            table.insert(skillshotArray,{name= "ShenShadowDash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 2, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Shaco" then
                            table.insert(skillshotArray,{name= "Deceive", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 500, type = 5, radius = 100, color= colorgreen, time = 3.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Shyvana" then
                            table.insert(skillshotArray,{name= "ShyvanaTransformLeap", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 150, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "ShyvanaFireballMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Skarner" then
                            table.insert(skillshotArray,{name= "SkarnerFracture", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Sona" then
                            table.insert(skillshotArray,{name= "SonaCrescendo", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Sejuani" then
                            table.insert(skillshotArray,{name= "SejuaniGlacialPrison", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1150, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Swain" then
                            table.insert(skillshotArray,{name= "SwainShadowGrasp", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 265 , color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Tryndamere" then
                            table.insert(skillshotArray,{name= "Slash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 2, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Tristana" then
                            table.insert(skillshotArray,{name= "RocketJump", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 200, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "TwistedFate" then
                            table.insert(skillshotArray,{name= "WildCards", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1450, type = 1, radius = 150, color= colorcyan, time = 5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Urgot" then
                            table.insert(skillshotArray,{name= "UrgotHeatseekingLineMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= colorcyan, time = 0.8, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "UrgotPlasmaGrenade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 300, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Vayne" then
                            table.insert(skillshotArray,{name= "VayneTumble", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 250, type = 3, radius = 100, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Varus" then
                            --table.insert(skillshotArray,{name= "VarusQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1475, type = 1, radius = 50, color= coloryellow, time = 1})
                            table.insert(skillshotArray,{name= "VarusR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 150, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Veigar" then
                            table.insert(skillshotArray,{name= "VeigarDarkMatter", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 225, color= coloryellow, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Viktor" then
                            --table.insert(skillshotArray,{name= "ViktorDeathRay", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 150, color= coloryellow, time = 2})
                    end
                    if 1==1 or skillshotplayerObj.name == "Xerath" then
                            table.insert(skillshotArray,{name= "xeratharcanopulsedamage", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "xeratharcanopulsedamageextended", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                            table.insert(skillshotArray,{name= "xeratharcanebarragewrapper", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "xeratharcanebarragewrapperext", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Ziggs" then
                            table.insert(skillshotArray,{name= "ZiggsQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 160, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                            table.insert(skillshotArray,{name= "ZiggsW", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 225 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                            table.insert(skillshotArray,{name= "ZiggsE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "ZiggsR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5300, type = 3, radius = 550, color= coloryellow, time = 3, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Zyra" then
                            table.insert(skillshotArray,{name= "ZyraQFissure", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 825, type = 3, radius = 275, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                            table.insert(skillshotArray,{name= "ZyraGraspingRoots", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 90, color= colorcyan, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
                    if 1==1 or skillshotplayerObj.name == "Diana" then
                            table.insert(skillshotArray,{name= "DianaArc", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 205, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                    skillshotcharexist = true
                    end
        end
    end
    
    --General Functions--
    function IsValid(object,vars)
        if object == nil then return false end
        if vars == nil or #vars < 1 then return true end
        for i,var in ipairs(vars) do
            if object[var] == nil then return false end
        end
        return true
    end

    function GetBaseTurret()
        for i=1, objManager:GetMaxObjects(), 1 do
            local object = objManager:GetObject(i)
            if IsValid(object) then
                if object.team == myHero.team then
                    for i,turretName in ipairs(baseTurrets) do
                       if object.name == turretName then
                           baseTurretAlly = object
                       end
                    end
                else
                    for i,turretName in ipairs(baseTurrets) do
                       if object.name == turretName then
                           baseTurretEnemy = object
                       end
                    end
                end
            end
        end
        return {ally=baseTurretAlly,enemy=baseTurretEnemy}
    end
    
    function IsLolActive()
        return tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client"
    end

    --[[
    --function OnWndMsg(msg, key)
    --    if true then
    --        if msg == KEY_DOWN then
    --            print('\nkey down...'..tostring(key))        
    --        elseif msg == KEY_UP then
    --            print('\nkey up...'..tostring(key))
    --        end
    --    end
    --end
    ]]--
    printtext("\n >> IGERs SorakaBot " .. version .. " loaded!\n")
    SetTimerCallback("OnTick")
end