require "Utils"
require 'spell_damage'
local uiconfig = require 'uiconfig'

if myHero.name ~= "Evelynn" then return end
local target

EvelynnConfig, menu = uiconfig.add_menu('Sidas Evelynn', 200)
menu.keydown('scriptActive', 'Combo', 32)
menu.keydown('harass', 'Harass', Keys.X)
menu.keydown('autoFarm', 'autoFarm', Keys.C)
menu.keytoggle('movement', 'Move To Mouse', Keys.NumPad1, true)
menu.keytoggle('drawcircles', 'Draw Circles', Keys.NumPad2, true)
menu.permashow('autoFarm')
menu.permashow('harass')  

function OnTick()
    target = GetWeakEnemy('MAGIC', 650)
    AArange = (myHero.range+(GetDistance(GetMinBBox(myHero), GetMaxBBox(myHero))/2))
    
    if myHero.SpellTimeQ > 1.0 then
    QRDY = true
    else QRDY = false
    end
    if myHero.SpellTimeW > 1.0 then
    WRDY = true
    else WRDY = false
    end
    if myHero.SpellTimeE > 1.0 then
    ERDY = true
    else ERDY = false
    end
    if myHero.SpellTimeR > 1.0 then
    RRDY = true
    else RRDY = false
    end
    
    -- [[ Harass ]] --
    if EvelynnConfig.harass and target and GetDistance(target) < 500 then
        if QRDY then CastSpellTarget("Q", target) end
        if ERDY then CastSpellTarget("E", target) end
        AttackTarget(target)
    end    
    
    -- [[ Full Combo ]] --
    if EvelynnConfig.scriptActive and target then
        UseAllItems(target)
        if RRDY then
            ultPos = GetMEC(250, 650, target)
            if ultPos then
                CastSpellXYZ("R", ultPos.x, ultPos.y, ultPos.z)
            else
                CastSpellTarget("R", target)
            end
        end
        
        if QRDY then CastSpellTarget("Q", target) end
        if ERDY then CastSpellTarget("E", target) end
        AttackTarget(target)
    end

    -- [[ Auto Farm ]] --
    if EvelynnConfig.autoFarm and QRDY then
        local myQ = math.floor(((GetSpellLevel("Q")-1)*20) + 40 + (myHero.ap * .45) + (myHero.addDamage * .5))
        local minion = GetLowestHealthEnemyMinion(500)
        if minion then
        DrawCircle(minion.x, minion.y, minion.z, 100, Color.Red) end
        if minion ~= nil and minion.health <= CalcMagicDamage(minion, myQ) then
            CastSpellTarget("Q", minion)
        end
    end
    
    -- [[ Movement ]] --
    if (EvelynnConfig.autoFarm or (EvelynnConfig.scriptActive and target == nil) or (EvelynnConfig.harass and target == nil)) and EvelynnConfig.movement then
        MoveToMouse()
    end
    
    -- [[ Hold Q ]] --
    if KeyDown(string.byte("Q")) then
        CastSpellTarget("Q", myHero)
    end

end

function OnDraw()
    if EvelynnConfig.drawcircles and myHero.dead == 0 then
        CustomCircle(500, 10, 3, myHero) -- Q range
        CustomCircle(650, 5, 2, myHero) -- R range
        if target ~= nil then
            CustomCircle(100, 10, 2, target)
        end
    end
end

SetTimerCallback("OnTick")