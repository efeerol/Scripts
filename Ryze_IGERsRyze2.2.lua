--[[
    Script: IGER's RyzeSpammer v2.2
    Author: PedobearIGER
]]--

require "Utils"
version = "2.2"
if GetSelf().name == "Ryze" then
        masterKey = 32       -- The masterKey needs to be pressed for all combos.                                       [default: Spacebar]
        useMasterKey = true  -- If you set this option to false there will be no need to hold the masterKey.            
        masterKeySwitch = 100-- Enable/Disable the need to hold the masterkey
        modeSwitch = 101     -- switch between the simple and advanced mode                                             [default: Numpad 5]
        autoQMinionsKey = 81 -- [Auto-Q Minions; casts a Q on the nearest minion that should die from it]               [default: Q]
        snareComboKey = 87   -- [W,Q,E,Q; targets the enemy champion that would most likely die from your attack]       [default: W]
        dpsComboKey = 69     -- [Q,W,E,Q; targets the enemy champion that would most likely die from your attack]       [default: E]
        ultComboKey = 84     -- [Q,R,W,Q,E; targets the enemy champion that would most likely die from your attack]     [default: T]
        igniteKey = 70       -- [Ignite,Q,W,E,Q; targets the enemy champion that would most likely die from your attack][default: F]
        markedComboKey = 65  -- [Q,W,E,Q; targets the marked Unit]                                                      [default: A]
        
        maxRange = 600                   -- only cast the combo if the target is in this range, set it to nil to use the spells ranges defnited in the table below
        targeting = "MostLikelyKillable" -- "MostLikelyKillable" or "MarkedUnit" ... future updates will also support "StrongestEmemy" and maybe "NearsetToMouse" and "MostExpensiveItmes"
        targetingModeSwitch = 102        -- Switch between the available Targeting Modes.                               [default: Numpad 6]
        
        snareCombo = {"W","Q","E"}
        dpsCombo = {"Q","W","E"}
        ultCombo = {"DeathfireGrasp","Q","R","W","E"}
        igniteCombo = {"Ignite","DeathfireGrasp","Q","R","W","E"}
        markedCombo = {"DeathfireGrasp","Q","R","W","E"}
        
        spellInfo = {
            --spellName: "Q","W","E" or "R"
            --castType: "None", "Target" or "Position"
            --range: for example: 0 or 100 or 550 or "Global"
            --dmgType: 'phys', 'magic' or 'true'
            --mode: "ActivateOnly", "SelfCast" or "EnemyCast"
            --condition & value: the script will  only cast the spell if condition == value (condition & value can also be a function, example: condition = GetMap(), value = 1 (if map=summoners rift) )
            
            Q = { spellName = "Q", castType = "Target", range = 600, dmgType = 'magic', mode = "EnemyCast",    condition = "None", value = "None" },
            W = { spellName = "W", castType = "Target", range = 600, dmgType = 'magic', mode = "EnemyCast",    condition = "None", value = "None" },
            E = { spellName = "E", castType = "Target", range = 600, dmgType = 'magic', mode = "EnemyCast",    condition = "None", value = "None" },
            R = { spellName = "R", castType = "None",   range = 0,   dmgType = 'none',  mode = "ActivateOnly", condition = "None", value = "None" },
            
            Barrier =      { spellName = "Barrier",      castType = "None",     range = 0,        dmgType = 'none',  mode = "ActivateOnly", condition = "None", value = "None" },
          --Clairvoience = { spellName = "Clairvoience", castType = "Position", range = "Global", dmgType = 'none',  mode = "---",          condition = "None", value = "None" },
            Clarity =      { spellName = "Clarity",      castType = "None",     range = 0,        dmgType = 'none',  mode = "ActivateOnly", condition = "None", value = "None" },
            Cleanse =      { spellName = "Cleanse",      castType = "None",     range = 0,        dmgType = 'none',  mode = "ActivateOnly", condition = "None", value = "None" },
            Exhaust =      { spellName = "Exhaust",      castType = "Target",   range = 550,      dmgType = 'phys',  mode = "EnemyCast",    condition = "None", value = "None" },
            Flash =        { spellName = "Flash",        castType = "Position", range = 400,      dmgType = 'magic', mode = "EnemyCast",    condition = "None", value = "None" },
          --Garrison =     { spellName = "Garrison",     castType = "Target",   range = 1000,     dmgType = 'none',  mode = "---",          condition = "None", value = "None" },
            Ghost =        { spellName = "Ghost",        castType = "None",     range = 0,        dmgType = 'none',  mode = "ActivateOnly", condition = "None", value = "None" },
            Heal =         { spellName = "Heal",         castType = "None",     range = 0,        dmgType = 'none',  mode = "ActivateOnly", condition = "None", value = "None" },
            Ignite =       { spellName = "Ignite",       castType = "Target",   range = 600,      dmgType = 'true',  mode = "EnemyCast",    condition = "None", value = "None" },
          --Smite =        { spellName = "Smite",        castType = "Target",   range = 625,      dmgType = 'true',  mode = "---",          condition = "None", value = "None" },
          --Teleport =     { spellName = "Cleanse",      castType = "Target",   range = "Global", dmgType = 'none',  mode = "---",          condition = "None", value = "None" },
            Revive =       { spellName = "Revive",       castType = "None",     range = 0,        dmgType = 'none',  mode = "ActivateOnly", condition = "None", value = "None" },
            
            DeathfireGrasp =       { spellName = "DeathfireGrasp",       castType = "Target", range = 750, dmgType = 'magic', mode = "EnemyCast",    condition = "None", value = "None" },
            HextechGunblade =      { spellName = "HextechGunblade",      castType = "Target", range = 700, dmgType = 'magic', mode = "EnemyCast",    condition = "None", value = "None" },
            BilgewaterCutlass =    { spellName = "BilgewaterCutlass",    castType = "Target", range = 400, dmgType = 'magic', mode = "EnemyCast",    condition = "None", value = "None" },
            BladeOfTheRuinedKing = { spellName = "BladeOfTheRuinedKing", castType = "Target", range = 500, dmgType = 'phys',  mode = "EnemyCast",    condition = "None", value = "None" },
            Entropy =              { spellName = "Entropy",              castType = "Target", range = 400, dmgType = 'true',  mode = "EnemyCast",    condition = "None", value = "None" },
            OdynsVeil =            { spellName = "OdynsVeil",            castType = "Target", range = 525, dmgType = 'magic', mode = "EnemyCast",    condition = "None", value = "None" },
            RanduinsOmen =         { spellName = "RanduinsOmen",         castType = "Target", range = 500, dmgType = 'phys',  mode = "EnemyCast",    condition = "None", value = "None" },
            RavenousHydra =        { spellName = "RavenousHydra",        castType = "Target", range = 400, dmgType = 'phys',  mode = "EnemyCast",    condition = "None", value = "None" },
            SwordOfTheDivine =     { spellName = "SwordOfTheDivine",     castType = "None",   range = 0,   dmgType = 'none',  mode = "ActivateOnly", condition = "None", value = "None" },
            YoumuusGhostblade =    { spellName = "YoumuusGhostblade",    castType = "None",   range = 0,   dmgType = 'none',  mode = "ActivateOnly", condition = "None", value = "None" },
        }
        
        IGERsNewRyzeConfig = scriptConfig("IGERsRyzeSpammer","IGERs RyzeSpammer")
        IGERsNewRyzeConfig:addParam("ryzeMasterKey", "MasterKey", SCRIPT_PARAM_ONKEYDOWN, false, masterKey)
        IGERsNewRyzeConfig:permaShow("ryzeMasterKey")
        IGERsNewRyzeConfig:addParam("advancedMode", "[Default: Num5]Advanced Mode", SCRIPT_PARAM_ONKEYTOGGLE, true, modeSwitch)
        IGERsNewRyzeConfig:permaShow("advancedMode")
        IGERsNewRyzeConfig:addParam("useTheMasterKey", "[Default: Num4]Need to hold masterkey", SCRIPT_PARAM_ONKEYTOGGLE, true, masterKeySwitch)
        IGERsNewRyzeConfig:permaShow("useTheMasterKey")
        IGERsNewRyzeConfig:addParam("targetingMode", "[Default: Num6]Targeting Mode", SCRIPT_PARAM_DOMAINUPDOWN, 1, targetingModeSwitch, {"MostLikelyKillable","MarkedUnit"})
        IGERsNewRyzeConfig:permaShow("targetingMode")
        IGERsNewRyzeConfig:addParam("autoQ", "Auto Q", SCRIPT_PARAM_ONKEYDOWN, false, autoQMinionsKey)
        IGERsNewRyzeConfig:addParam("snareCombo", "Snare Combo", SCRIPT_PARAM_ONKEYDOWN, false, snareComboKey)
        IGERsNewRyzeConfig:addParam("dpsCombo", "Dps Combo", SCRIPT_PARAM_ONKEYDOWN, false, dpsComboKey)
        IGERsNewRyzeConfig:addParam("ultCombo", "Ult Combo", SCRIPT_PARAM_ONKEYDOWN, false, ultComboKey)
        IGERsNewRyzeConfig:addParam("igniteCombo", "Ignite Combo", SCRIPT_PARAM_ONKEYDOWN, false, igniteKey)
        IGERsNewRyzeConfig:addParam("markedCombo", "Marked Combo", SCRIPT_PARAM_ONKEYDOWN, false, markedComboKey)
        
        function OnTick()
           if IGERsNewRyzeConfig.targetingMode == 1 then targeting = "MostLikelyKillable"
           elseif IGERsNewRyzeConfig.targetingMode == 2 then targeting = "MarkedUnit" end
           if (IGERsNewRyzeConfig.useTheMasterKey == false or IGERsNewRyzeConfig.ryzeMasterKey == true) then
               if IGERsNewRyzeConfig.markedCombo then
                   targeting = "MarkedUnit"
                   DoCombo(markedCombo)
                   CustomCircle(600,6,5,myHero)
                   DrawTextObject("MarkedUnit Combo",myHero,0xFFFFFF00)
                   if IGERsNewRyzeConfig.targetingMode == 1 then targeting = "MostLikelyKillable"
                   elseif IGERsNewRyzeConfig.targetingMode == 2 then targeting = "MarkedUnit" end
               end
               if IGERsNewRyzeConfig.advancedMode then
                   if IGERsNewRyzeConfig.igniteCombo then
                       DoCombo(igniteCombo)
                       DrawTextObject("Ignite Combo",myHero,0xFFFF8C00)
                       DrawCircleObject(myHero,594,5)
                       DrawCircleObject(myHero,596,2)
                       DrawCircleObject(myHero,598,5)
                       DrawCircleObject(myHero,600,2)
                       DrawCircleObject(myHero,602,5)
                   elseif IGERsNewRyzeConfig.ultCombo then
                       DoCombo(ultCombo)
                       DrawTextObject("Ult Combo",myHero,0xFFFF0000)
                       CustomCircle(600,6,2,myHero) 
                   elseif IGERsNewRyzeConfig.dpsCombo then
                       DoCombo(dpsCombo)
                       DrawTextObject("DPS Combo",myHero,0xFF00C8FF)
                       CustomCircle(600,6,3,myHero)
                   elseif IGERsNewRyzeConfig.snareCombo then
                       DoCombo(snareCombo)
                       DrawTextObject("Snare Combo",myHero,0xFF00FF00)
                       CustomCircle(600,6,1,myHero) 
                   elseif IGERsNewRyzeConfig.autoQ then
                       AutoQMinions()
                       --TearStackExploit()
                       DrawTextObject("AutoQMinions",myHero,0xFFFF33CC)
                       CustomCircle(600,6,4,myHero)
                   end
               else
                   DoCombo(dpsCombo)
                   if myHero.dead == 0 then 
                       if GetNearestChamp() ~= nil and GetNearestChamp().x ~= nil and GetDistance(myHero,GetNearestChamp()) <= 650 then 
                           CustomCircle(600,6,2,myHero) 
                           DrawTextObject("DPS Combo",myHero,0xFFFF0000)
                       else 
                           CustomCircle(600,6,3,myHero)
                           DrawTextObject("DPS Combo",myHero,0xFF00C8FF)
                       end
                   end
               end
           end
           qDmg = 35+(25*GetSpellLevel("Q"))+(0.4*myHero.ap)+(myHero.maxMana*0.065)
           
           for i,minion in pairs(GetEnemyMinions(MINION_SORT_HEALTH_DEC)) do 
               if minion.visible == 1 then
                   if minion ~= nil and minion.health ~= nil and minion.x ~= nil and minion.health <= myHero.baseDamage+myHero.addDamage then 
                       CustomCircle(70,6,2,minion)
                       --CalculateDamage(myHero,minion,"phys,damage)
                   elseif minion.health <= qDmg then 
                       CustomCircle(70,6,3,minion)
                   end
               end
           end
      end
      
        -->----------------------------------------
        -->-------------AutoQMinions---------------
        -->----------------------------------------
        function AutoQMinions()
            for i,minion in pairs(GetEnemyMinions(MINION_SORT_HEALTH_DEC)) do 
                if minion ~= nil and minion.health ~= nil and minion.x ~= nil and GetDistance(myHero,minion) <= 650 and minion.health <= qDmg then
                    CastSpellTarget('Q',minion)
                    break
                end
            end
        end
        ----------------------------------------<--
        ----------------AutoQMinions------------<--
        ----------------------------------------<--
        
        -->----------------------------------------
        -->-----------TearStackExploit-------------
        -->----------------------------------------
        --qKill = nil
        --ping = 24
        --divisor = 6.1
        --delay = 296+ping
        --function OnProcessSpell(object, spell)
        --    if object ~= nil and spell ~= nil and object.name ~= nil and spell.name ~= nil and spell.target ~= nil and spell.target.health ~= nil and object.charName == myHero.charName then
        --        if spell.name == "Overload" then
        --            local qDmg = 35+(25*GetSpellLevel("Q"))+(0.4*myHero.ap)+(myHero.maxMana*0.065)
        --            if CalcMagicDamage(spell.target,qDmg) > spell.target.health then 
        --                qKill = {}
        --                qKill = {tick=GetClock(),unit=spell.target,dist=GetDistance(myHero,spell.target)}
        --            end
        --        elseif spell.name == "RunePrison" then
        --            qKill = nil
        --        end
        --    end
        --end
        --
        --function TearStackExploit()
        --    if qKill ~= nil and qKill.tick ~= nil and qKill.unit ~= nil and qKill.unit.health ~= nil then 
        --        if GetClock() < qKill.tick+400 then
        --            delay = 296+ping-(100-100/625*qKill.dist)/divisor
        --            if GetClock() > qKill.tick+delay then CastSpellTarget("W",qKill.unit) end
        --        else qKill = nil end
        --    end
        --end
        
        --TearStackTesting 2
      --qKill = nil
        --casttime: 82
        --createObject time: 293
        --projectilespeed: 1.179
      --ping = 23
      --delay = -680
      --function OnProcessSpell(object, spell)
      --    if object ~= nil and spell ~= nil and object.name ~= nil and spell.name ~= nil and spell.target ~= nil and spell.target.health ~= nil and object.charName == myHero.charName then
      --        if spell.name == "Overload" then
      --            local qDmg = 35+(25*GetSpellLevel("Q"))+(0.4*myHero.ap)+(myHero.maxMana*0.065)
      --            if CalcMagicDamage(spell.target,qDmg) > spell.target.health then 
      --                qKill = {}
      --                qKill = {tick=GetClock()+293+GetDistance(spell.target)/1.179+ping,unit=spell.target,dist=GetDistance(myHero,spell.target)}
      --            end
      --        elseif spell.name == "RunePrison" then
      --            qKill = nil
      --        end
      --    end
      --end
      --
      --function TearStackExploit()
      --    if qKill ~= nil and qKill.tick ~= nil and qKill.unit ~= nil and qKill.unit.health ~= nil then
      --        if GetClock() > qKill.tick+delay and GetClock() < qKill.tick+100 then
      --        CastSpellTarget("W",qKill.unit)
      --        else qKill = nil end
      --    end
      --end
      ------------------------------------------<--
      ----------------TearStackExploit----------<--
      ------------------------------------------<--
      --
      SetTimerCallback("OnTick")
      printtext("\n >> IGER's RyzeSpammer "..version.." loaded!\n")
--elseif GetSelf().name == "Mordekaiser" then
--        hotkey = 32 --comboHotkey (default: Space)
--        targetingModeSwitch = 102
--        maxRange = nil
--        targeting = "MostLikelyKillable"
--        fullCombo = {"DeathfireGrasp","Q","W","AutoAttack","E","R","HextechGunblade","BilgewaterCutlass","Ignite","Exhaust"}
--        noQWCombo = {"DeathfireGrasp","E","R","HextechGunblade","BilgewaterCutlass","Ignite","Exhaust"}
--        LowHpCombo = {"DeathfireGrasp","Q","W","AutoAttack","R","E","HextechGunblade","BilgewaterCutlass","Ignite","Exhaust"}
--        noQWLowHpCombo = {"DeathfireGrasp","R","E","HextechGunblade","BilgewaterCutlass","Ignite","Exhaust"}
--        -->----------------------------------------
--        -->------------QSpellParticle--------------
--        -->----------------------------------------
--        function MordeQCheck()
--            if IsSpellCastable("Q") then 
--                for i=1, objManager:GetMaxObjects(), 1 do
--                    local object = objManager:GetObject(i)
--                    if object ~= nil and object.charName ~= nil and object.charName == "mordakaiser_maceOfSpades_activate.troy" then
--                        return false
--                    end
--                end
--                return true
--            end
--            return false
--        end
--        -----------------------------------------<--
--        ---------------QSpellParticle------------<--
--        -----------------------------------------<--
--        spellInfo = {
--            AutoAttack = { spellName = "AutoAttack", castType = "Target", range = myHero.range+100, dmgType = 'phys', mode = "EnemyCast", condition = MordeQCheck, value = false },
--            
--            Q = { spellName = "Q", castType = "None",     range = 0,   dmgType = 'none',  mode = "ActivateOnly", condition = MordeQCheck,  value = true   },
--            W = { spellName = "W", castType = "Target",   range = 600, dmgType = 'magic', mode = "SelfCast",     condition = "None",       value = "None" },
--            E = { spellName = "E", castType = "Position", range = 650, dmgType = 'magic', mode = "EnemyCast",    condition = "None",       value = "None" },
--            R = { spellName = "R", castType = "Target",   range = 850, dmgType = 'magic', mode = "EnemyCast",    condition = "None",       value = "None" },
--            
--            Barrier =      { spellName = "Barrier",      castType = "None",     range = 0,        dmgType = 'none',  mode = "ActivateOnly", condition = "None", value = "None" },
--          --Clairvoience = { spellName = "Clairvoience", castType = "Position", range = "Global", dmgType = 'none',  mode = "---",          condition = "None", value = "None" },
--            Clarity =      { spellName = "Clarity",      castType = "None",     range = 0,        dmgType = 'none',  mode = "ActivateOnly", condition = "None", value = "None" },
--            Cleanse =      { spellName = "Cleanse",      castType = "None",     range = 0,        dmgType = 'none',  mode = "ActivateOnly", condition = "None", value = "None" },
--            Exhaust =      { spellName = "Exhaust",      castType = "Target",   range = 550,      dmgType = 'phys',  mode = "EnemyCast",    condition = "None", value = "None" },
--            Flash =        { spellName = "Flash",        castType = "Position", range = 400,      dmgType = 'magic', mode = "EnemyCast",    condition = "None", value = "None" },
--          --Garrison =     { spellName = "Garrison",     castType = "Target",   range = 1000,     dmgType = 'none',  mode = "---",          condition = "None", value = "None" },
--            Ghost =        { spellName = "Ghost",        castType = "None",     range = 0,        dmgType = 'none',  mode = "ActivateOnly", condition = "None", value = "None" },
--            Heal =         { spellName = "Heal",         castType = "None",     range = 0,        dmgType = 'none',  mode = "ActivateOnly", condition = "None", value = "None" },
--            Ignite =       { spellName = "Ignite",       castType = "Target",   range = 600,      dmgType = 'true',  mode = "EnemyCast",    condition = "None", value = "None" },
--          --Smite =        { spellName = "Smite",        castType = "Target",   range = 625,      dmgType = 'true',  mode = "---",          condition = "None", value = "None" },
--          --Teleport =     { spellName = "Cleanse",      castType = "Target",   range = "Global", dmgType = 'none',  mode = "---",          condition = "None", value = "None" },
--            Revive =       { spellName = "Revive",       castType = "None",     range = 0,        dmgType = 'none',  mode = "ActivateOnly", condition = "None", value = "None" },
--            
--            DeathfireGrasp =       { spellName = "DeathfireGrasp",       castType = "Target", range = 750, dmgType = 'magic', mode = "EnemyCast",    condition = "None", value = "None" },
--            HextechGunblade =      { spellName = "HextechGunblade",      castType = "Target", range = 700, dmgType = 'magic', mode = "EnemyCast",    condition = "None", value = "None" },
--            BilgewaterCutlass =    { spellName = "BilgewaterCutlass",    castType = "Target", range = 400, dmgType = 'magic', mode = "EnemyCast",    condition = "None", value = "None" },
--            BladeOfTheRuinedKing = { spellName = "BladeOfTheRuinedKing", castType = "Target", range = 500, dmgType = 'phys',  mode = "EnemyCast",    condition = "None", value = "None" },
--            Entropy =              { spellName = "Entropy",              castType = "Target", range = 400, dmgType = 'true',  mode = "EnemyCast",    condition = "None", value = "None" },
--            OdynsVeil =            { spellName = "OdynsVeil",            castType = "Target", range = 525, dmgType = 'magic', mode = "EnemyCast",    condition = "None", value = "None" },
--            RanduinsOmen =         { spellName = "RanduinsOmen",         castType = "Target", range = 500, dmgType = 'phys',  mode = "EnemyCast",    condition = "None", value = "None" },
--            RavenousHydra =        { spellName = "RavenousHydra",        castType = "Target", range = 400, dmgType = 'phys',  mode = "EnemyCast",    condition = "None", value = "None" },
--            SwordOfTheDivine =     { spellName = "SwordOfTheDivine",     castType = "None",   range = 0,   dmgType = 'none',  mode = "ActivateOnly", condition = "None", value = "None" },
--            YoumuusGhostblade =    { spellName = "YoumuusGhostblade",    castType = "None",   range = 0,   dmgType = 'none',  mode = "ActivateOnly", condition = "None", value = "None" },
--        }
--        
--        MordeConfig2 = scriptConfig("Insane Mordekaiser BurstCombo","enableMordeCombo")
--        MordeConfig2:addParam("enableMordeCombo", "Mordekaiser Combo", SCRIPT_PARAM_ONKEYDOWN, false, hotkey)
--        MordeConfig2:permaShow("enableMordeCombo")
--        MordeConfig2:addParam("targetingMode", "[Default: Num6]Targeting Mode", SCRIPT_PARAM_DOMAINUPDOWN, 1, targetingModeSwitch, {"MostLikelyKillable","MarkedUnit"})
--        MordeConfig2:permaShow("targetingMode")
--        function OnTick()
--           if MordeConfig2.targetingMode == 1 then targeting = "MostLikelyKillable"
--           elseif MordeConfig2.targetingMode == 2 then targeting = "MarkedUnit" end
--           if MordeConfig2.enableMordeCombo then
--               if GetNearestChamp() ~= nil and GetNearestChamp().x ~= nil and GetDistance(myHero,GetNearestChamp()) < myHero.range+100 then
--                   if myHero.health < myHero.maxHealth/100*15 then
--                       DoCombo(LowHpCombo)
--                   else
--                       DoCombo(fullCombo)
--                   end
--               else
--                   if myHero.health < myHero.maxHealth/100*15 then
--                       DoCombo(noQWLowHpCombo)
--                   else
--                       DoCombo(noQWCombo)
--                   end
--               end
--           end
--           if myHero.dead == 0 then 
--               if GetNearestChamp() ~= nil and GetNearestChamp().x ~= nil and GetDistance(myHero,GetNearestChamp()) < 850 then CustomCircle(850,6,2,myHero) 
--               else CustomCircle(850,6,5,myHero) end
--           end
--        end
--        
--        SetTimerCallback("OnTick")
--        printtext("\n >> IGER's ComboCollection [Mordekaiser] "..version.." loaded!\n")
end

-->------------------------------------------
-->-----------GetNearestChampion-------------
-->------------------------------------------
function GetNearestChamp()
    local nearest = nil
    for i=1, objManager:GetMaxHeroes(), 1 do
        local hero = objManager:GetHero(i)
        if hero ~= nil and hero.x ~= nil and hero.team ~= myHero.team and hero.visible == 1 and hero.dead == 0 and (nearest == nil or GetDistance(myHero,hero) < GetDistance(myHero,nearest)) then nearest = hero end
    end
    return nearest
end
-----------------------------------------<--
-------------GetNearestChampion----------<--
-----------------------------------------<--

-->----------------------------------------
-->IGER's ComboScript Template Functions---
-->----------------------------------------

function DoCombo(spells)
    for i,spell in ipairs(spells) do
        if spell ~= nil and spellInfo[spell].spellName ~= nil then
            if (spellName == "AutoAttack" and IsAttackReady() and spellInfo[spell].condition == "None") or (IsSpellCastable(spellInfo[spell].spellName) and spellInfo[spell].condition == "None") or (spellInfo[spell].condition ~= "None" and spellInfo[spell].condition() == spellInfo[spell].value) or (spellInfo[spell].condition ~= "None" and spellInfo[spell].condition() == spellInfo[spell].value and spellName == "AutoAttack" and IsAttackReady()) then
                CastSpellCustom(GetSlot(spellInfo[spell].spellName),spellInfo[spell].castType,spellInfo[spell].range,spellInfo[spell].dmgType,spellInfo[spell].mode)
                break
            end
        end
    end
end

function CastSpellCustom(spell,castType,range,dmgType,mode)
    target = nil
    if maxRange ~= nil and maxRange < range then range = maxRange end
    if range == "Global" then range = 20000 end
    if (mode == "SelfCast" or mode == "ActivateOnly") then 
        if myHero.dead == 0 then
            if castType == "Position" then CastSpellXYZ(spell,myHero.x,myHero.y,myHero.z)
            elseif castType == "Target" or castType == "None" then CastSpellTarget(spell,myHero) end
        end
    elseif mode == "EnemyCast" then 
        if targeting == "MostLikelyKillable" then target = GetWeakEnemy(dmgType,range)
        elseif targeting == "MarkedUnit" and GetMarkedTarget() ~= nil and GetMarkedTarget().x ~= nil and GetDistance(myHero,GetMarkedTarget()) < range then target = GetMarkedTarget() end
        if target ~= nil and target.dead == 0 and target.health > 0 and target.visible == 1 then -- and target.invulnerable == 0 then 
            if castType == "Position" then CastSpellXYZ(spell,target.x,target.y,target.z)
            elseif castType == "Target" then 
                if spell == "AA" then AttackTarget(target)
                else CastSpellTarget(spell,target) end
            end
        end
    elseif mode == "AllyCast" then
        if targeting == "MostLikelyKillable" then target = GetWeakAlly(dmgType,range)
        elseif targeting == "MarkedUnit" and GetMarkedTarget() ~= nil and GetMarkedTarget().x ~= nil and GetDistance(myHero,GetMarkedTarget()) < range then target = GetMarkedTarget()
        else target = GetWeakAlly(dmgType,range) end
        if target ~= nil and target.dead == 0 then 
            if castType == "Position" then CastSpellXYZ(spell,target.x,target.y,target.z)
            elseif castType == "Target" then CastSpellTarget(spell,target) end
        end
    end
end

function IsSpellCastable(spell)
    if ((spell == "Q" or spell == "W" or spell == "E" or spell == "R") and GetSpellLevel(spell)-0.1 > 0 and GetCooldown(myHero,spell) <= 0.2) or ((spell == "Exhaust" or spell == "Ignite" or spell == "DeathfireGrasp" or spell == "HextechGunblade" or spell == "BilgewaterCutlass") and GetSlot(spell) ~= nil and IsSpellReady(GetSlot(spell)) == 1) then return true end
end

function GetSlot(itemName)
    if itemName == "AutoAttack" then return "AA"
    elseif itemName == "Q" then return "Q"
    elseif itemName == "W" then return "W"
    elseif itemName == "E" then return "E"
    elseif itemName == "R" then return "R"
    elseif itemName == "DeathfireGrasp" then return GetSlotForId(3128)
    elseif itemName == "HextechGunblade" then return GetSlotForId(3146)
    elseif itemName == "BilgewaterCutlass" then return GetSlotForId(3144)
    elseif itemName == "BladeOfTheRuinedKing" then return GetSlotForId(3153)
    elseif itemName == "Entropy" then return GetSlotForId(3184)
    elseif itemName == "OdynsVeil" then return GetSlotForId(3180)
    elseif itemName == "RanduinsOmen" then return GetSlotForId(3143)
    elseif itemName == "RavenousHydra" then return GetSlotForId(3074)
    elseif itemName == "SwordOfTheDivine" then return GetSlotForId(3131)
    elseif itemName == "YoumuusGhostblade" then return GetSlotForId(3142)
    elseif itemName == "Barrier" then return GetSlotSummonerSpell("SummonerBarrier")
    elseif itemName == "Clarity" then return GetSlotSummonerSpell("SummonerClarity")
    elseif itemName == "Cleanse" then return GetSlotSummonerSpell("SummonerBoost")
    elseif itemName == "Exhaust" then return GetSlotSummonerSpell("SummonerExhaust")
    elseif itemName == "Flash" then return GetSlotSummonerSpell("SummonerFlash")
    elseif itemName == "Ghost" then return GetSlotSummonerSpell("SummonerHaste")
    elseif itemName == "Heal" then return GetSlotSummonerSpell("SummonerHeal")
    elseif itemName == "Ignite" then return GetSlotSummonerSpell("SummonerDot")
    elseif itemName == "Revive" then return GetSlotSummonerSpell("SummonerRevive") 
    end
end

function GetSlotSummonerSpell(spellName)
    if myHero.SummonerD == spellName then return "D"
    elseif myHero.SummonerF == spellName then return "F" end
end

function GetSlotForId(id)
    for i=1,6,1 do
        if GetInventoryItem(i) == id then 
            return string.format(i) 
        end
    end
end

function GetWeakAlly(dmgType,range)
    if dmgType == "None" then dmgType = 'magic' end
    local target = nil
    for i=1, objManager:GetMaxHeroes(), 1 do
        local ally = objManager:GetHero(i)
        if ally ~= nil and ally.team ~= nil and ally.dead == 0 and ally.team == myHero.team and GetDistance(myHero,ally) <= range and (target == nil or target.health-CalculateDamage(myHero,target,dmgType,100) > ally.health-CalculateDamage(myHero,ally,dmgType,100)) then target = ally end
    end
    return target
end

function CalculateDamage(source,target,type,damage)
    local target = target
    if source ~= nil and target ~= nil and type ~= nil and damage ~= nil then
        if type == 'magic' and target.magicArmor ~= nil and source.magicPenPercent ~= nil and source.magicPen ~= nil then
            local targetMagicResistance = target.magicArmor-source.magicPen
            if targetMagicResistance > 0 then targetMagicResistance = targetMagicResistance*source.magicPenPercent end
            if targetMagicResistance > 0 then return damage*(100/(100+targetMagicResistance))
            elseif targetMagicResistance <= 0 then return damage*(2-(100/(100-targetMagicResistance))) end
        elseif type == 'phys' and target.armor ~= nil and source.armorPenPercent ~= nil and source.armorPen ~= nil then            
            local targetArmor = target.armor-source.armorPen
            if targetArmor > 0 then targetArmor = targetArmor*source.armorPenPercent end
            if targetArmor > 0 then return damage*(100/(100+targetArmor))
            elseif targetArmor <= 0 then return damage*(2-(100/(100-targetArmor))) end
        elseif type == 'true' then return damage end
    end
end

function GetCooldown(hero,spell)
    if spell == "Q" then spellTime=hero.SpellTimeQ
    elseif spell == "W" then spellTime=hero.SpellTimeW
    elseif spell == "E" then spellTime=hero.SpellTimeE
    elseif spell == "R" then spellTime=hero.SpellTimeR
    elseif spell == "D" then spellTime=hero.SpellTimeD
    elseif spell == "F" then spellTime=hero.SpellTimeF end
    return (math.floor(spellTime)-math.floor(spellTime)*2)+1
end

----------------------------------------<--
---IGER's ComboScript Template Functions<--
----------------------------------------<--