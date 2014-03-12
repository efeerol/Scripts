--[[
--    Script: IGER's Fully Automated Soraka Bot v1.5 Open Beta
--    Author: PedobearIselectMasterGER
--    Credits: Arivo for the great idea of such a fully automated bot!
]]--
local version = "1.6 Open Beta"

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
    local nonManaChampNames = {"DrMundo" , "Mordekaiser" , "Vladimir" , "Zac", "Rumble", "Renekton" , "Shyvana" , "Tryndamere", "Garen" , "Katarina" , "Riven", "Rengar", "Akali" , "Kennen" , "LeeSin" , "Shen" , "Zed", "Aatrox", "Lee Sin", "Shen", "Yasuo"}
    local wardNames = {"Sightstone","RubySightstone","StealthWard","VisionWard","Ward_Sight_Idle.troy","Ward_Vision_Idle.troy","Ward_Wriggles_Idle.troy"}
    
    --Script config menu--
    IGERsSorakaBotConfig = scriptConfig("IGERs SorakaBot", "IGERsSorakaBot")
    IGERsSorakaBotConfig:addParam("mainSwitch", "[Numpad 0]Bot MainSwitch", SCRIPT_PARAM_ONKEYTOGGLE, true, 96)
    IGERsSorakaBotConfig:addParam("spellAI", "[Numpad 1]Spell_AI", SCRIPT_PARAM_ONKEYTOGGLE, true, 97)
    IGERsSorakaBotConfig:addParam("itemAI", "[Numpad 2]Item_AI", SCRIPT_PARAM_ONKEYTOGGLE, true, 98)
    IGERsSorakaBotConfig:addParam("moveAI", "[Numpad 3]Move_AI", SCRIPT_PARAM_ONKEYTOGGLE, true, 99)
    IGERsSorakaBotConfig:addParam("dodgeAI", "[Numpad 4]Dodge_AI", SCRIPT_PARAM_ONKEYTOGGLE, true, 100)
    IGERsSorakaBotConfig:addParam("autoAttackAI", "[Numpad 5]AutoAttack_AI", SCRIPT_PARAM_ONKEYTOGGLE, true, 101)
    IGERsSorakaBotConfig:addParam("buyItemsAI", "[Numpad 6]BuyItems_AI", SCRIPT_PARAM_ONKEYTOGGLE, true, 102)
    IGERsSorakaBotConfig:addParam("levelSpellsAI", "[Numpad 7]LevelSpells_AI", SCRIPT_PARAM_ONKEYTOGGLE, true, 103)
    IGERsSorakaBotConfig:addParam("selectMaster", "[Numpad *]Select New Master", SCRIPT_PARAM_ONKEYDOWN, false, 106)
	
IGERsSorakaBotConfig:permaShow("mainSwitch")
IGERsSorakaBotConfig:permaShow("spellAI")
IGERsSorakaBotConfig:permaShow("itemAI")
IGERsSorakaBotConfig:permaShow("moveAI")
IGERsSorakaBotConfig:permaShow("dodgeAI")
IGERsSorakaBotConfig:permaShow("autoAttackAI")
IGERsSorakaBotConfig:permaShow("buyItemsAI")
IGERsSorakaBotConfig:permaShow("levelSpellsAI")
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
                if spell.name ~= nil and spell.name == "Recall" and GetDistance(followTarget) < 800 then 
				StopMove()
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
            if GetDistance(spot) < 1000 and (nearestWard == nil or GetDistance(nearestWard,spot) > 1500) then
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
                if GetDistance(followTarget) < 800 then
				StopMove()
                    Recall()
                else
                    MoveToXYZ(followTarget.x,followTarget.y,followTarget.z)
                end
                return
            end
            if IsRecalling(followTarget) then 
                if GetDistance(followTarget) < 150 or GetDistance(followTarget) > 3000 then
				StopMove()
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
				StopMove()
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
				StopMove()
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
for i = 1, objManager:GetMaxHeroes() do
         local object = objManager:GetHero(i)
         if (object~=nil and object.team==myHero.team) then
             if KeyDown(106) and GetDistance(object,mousePos)<200 then --left click over the champ
                 Markedobject = object -- the champ to follow
             end
         end
     end
        if adCarry == nil then
            for i=1, objManager:GetMaxHeroes(), 1 do
         local object = objManager:GetHero(i)
         if (object~=nil and object.team==myHero.team) then
             if KeyDown(106) and GetDistance(object,mousePos)<200 then --left click over the champ
                 adCarry = object -- the champ to follow
             end
         end
     end
        return adCarry
    end
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
                    if GetDistance(object,unit) < 800 then
                    return true end
                end
            end
        end
        return false
    end
    
    function Recall()
        if IsLolActive() and IsChatOpen() == 0 then
		StopMove()
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
                BuyItem("stealth ward")
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
                    elseif myHero.gold >= 75 and not BoughtItem("Sightstone") and not BoughtItem("Ruby Sightstone") and not BoughtItem("Stealth Ward") then 
                        BuyItem("Stealth Ward")
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
    shoppingList = {"Ancient Coin","Boots of Speed","Faerie Charm","Nomad's Medallion","Talisman of Ascension","Ruby Crystal","Sightstone","Ionian Boots of Lucidity","Ruby Crystal","Ruby Sightstone","Cloth Armor","Ruby Crystal","Aegis of the Legion","Locket of the Iron Solari","Blasting Wand","Giant's Belt","Amplifying Tome","Rylai's Crystal Scepter","Chalice of Harmony","Mikael's Crucible"}
    itemdb = {
        ["Warding Totem (Trinket)"] = { id = 3340, name = 'Warding Totem (Trinket)', iconPath = '3340_YellowTrinket.png', price = 0, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 25.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Boots of Speed"] = { id = 1001, name = 'Boots of Speed', iconPath = '1001_Boots_of_Speed.png', price = 325, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 25.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
		["Ancient Coin"] = { id = 3301, name = 'Ancient Coin', iconPath = '3301_BabyPhilo.png', price = 365, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.6, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
		["Talisman of Ascension"] = { id = 3069, name = 'Talisman of Ascension', iconPath = '3069_Shurelyas_Firecrest.png', price = 955, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.6, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
		["Nomad's Medallion"] = { id = 3096, name = "Nomad's Medallion", iconPath = '3096_Soul_Pendant.png', price = 500, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.6, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Faerie Charm"] = { id = 1004, name = 'Faerie Charm', iconPath = '1004_Faerie_Charm.png', price = 180, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.6, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Giant's Belt"] = { id = 1011, name = "Giant's Belt", iconPath = '1011_Mighty_Waistband_of_the_Reaver.png', price = 1000, flatHPPoolMod = 380.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Blasting Wand"] = { id = 1026, name = 'Blasting Wand', iconPath = '1026_Blasting_Band.png', price = 860, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 40.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Ruby Crystal"] = { id = 1028, name = 'Ruby Crystal', iconPath = '1028_Ruby_Sphere.png', price = 475, flatHPPoolMod = 180.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Cloth Armor"] = { id = 1029, name = 'Cloth Armor', iconPath = '1029_Cloth_Armour.png', price = 300, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 15.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Amplifying Tome"] = { id = 1052, name = 'Amplifying Tome', iconPath = '1052_Amplifying_Scepter.png', price = 435, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 20.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Health Potion"] = { id = 2003, name = 'Health Potion', iconPath = '2003_Regeneration_Potion.png', price = 35, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Mana Potion"] = { id = 2004, name = 'Mana Potion', iconPath = '2004_Flask_of_Crystal_Water.png', price = 35, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
		["Stealth Ward"] = { id = 2044, name = 'Stealth Ward', iconPath = '1020_Glowing_Orb.png', price = 75, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Ruby Sightstone"] = { id = 2045, name = 'Ruby Sightstone', iconPath = '2049_Ruby_Ward.png', price = 125, flatHPPoolMod = 360.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Sightstone"] = { id = 2049, name = 'Sightstone', iconPath = '2049_Sightstone.png', price = 475, flatHPPoolMod = 180.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Boots of Swiftness"] = { id = 3009, name = 'Boots of Swiftness', iconPath = '3009_Boots_of_Teleportation.png', price = 650, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 60.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Sorcerer's Shoes"] = { id = 3020, name = "Sorcerer's Shoes", iconPath = '3020_Flamewalkers.png', price = 750, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Aegis of the Legion"] = { id = 3105, name = 'Aegis of the Legion', iconPath = '034_Steel_Shield.png', price = 1100, flatHPPoolMod = 250.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 20.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 20.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Mercury's Treads"] = { id = 3111, name = "Mercury's Treads", iconPath = '3008_Boots_Of_Swiftness.png', price = 450, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 25.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Rylai's Crystal Scepter"] = { id = 3116, name = "Rylai's Crystal Scepter", iconPath = '3116_Rylais_Sceptre.png', price = 605, flatHPPoolMod = 500.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 80.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Boots of Mobility"] = { id = 3117, name = 'Boots of Mobility', iconPath = '3004_Assault_Treads.png', price = 650, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 105.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
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
        ["Locket of the Iron Solari"] = { id = 3190, name = 'Locket of the Iron Solari', iconPath = '3190_Crest_of_the_Iron_Solari.png', price = 600, flatHPPoolMod = 300.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 2.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 35.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Seeker's Armguard"] = { id = 3191, name = "Seeker's Armguard", iconPath = '3191_Seekers_Armguard.png', price = 125, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 30.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 20.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 0,  },
        ["Augment: Power"] = { id = 3196, name = 'Augment: Power', iconPath = '3196_AugmentQ.png', price = 1000, flatHPPoolMod = 220.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 1.2, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Augment: Gravity"] = { id = 3197, name = 'Augment: Gravity', iconPath = '3197_AugmentW.png', price = 1000, flatHPPoolMod = 0.0, flatMPPoolMod = 200.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 1.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Augment: Death"] = { id = 3198, name = 'Augment: Death', iconPath = '3198_AugmentE.png', price = 1000, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 45.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Spirit of the Spectral Wraith"] = { id = 3206, name = 'Spirit of the Spectral Wraith', iconPath = '3206_SoulEaterWraith.png', price = 100, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 2.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 50.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Mikael's Crucible"] = { id = 3222, name = "Mikael's Crucible", iconPath = '3222_Mikaels_Crucible.png', price = 920, flatHPPoolMod = 0.0, flatMPPoolMod = 300.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 1.8, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 0.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 40.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 2,  },
        ["Enchantment: Homeguard"] = { id = 3275, name = 'Enchantment: Homeguard', iconPath = '3158_Ionian_Boots_of_Lucidity_A.png', price = 475, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Captain"] = { id = 3276, name = 'Enchantment: Captain', iconPath = '3158_Ionian_Boots_of_Lucidity_B.png', price = 750, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Furor"] = { id = 3277, name = 'Enchantment: Furor', iconPath = '3158_Ionian_Boots_of_Lucidity_C.png', price = 650, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Distortion"] = { id = 3278, name = 'Enchantment: Distortion', iconPath = '3158_Ionian_Boots_of_Lucidity_D.png', price = 475, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 45.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
        ["Enchantment: Alacrity"] = { id = 3279, name = 'Enchantment: Alacrity', iconPath = '3158_Ionian_Boots_of_Lucidity_E.png', price = 475, flatHPPoolMod = 0.0, flatMPPoolMod = 0.0, percentHPPoolMod = 0.0, percentMPPoolMod = 0.0, flatHPRegenMod = 0.0, percentHPRegenMod = 0.0, flatMPRegenMod = 0.0, percentMPRegenMod = 0.0, flatArmorMod = 0.0, percentArmorMod = 0.0, flatAttackDamageMod = 0.0, percentAttackDamageMod = 0.0, flatAbilityPowerMod = 0.0, percentAbilityPowerMod = 0.0, flatMovementSpeedMod = 60.0, percentMovementSpeedMod = 0.0, flatAttackSpeedMod = 0.0, percentAttackSpeedMod = 0.0, flatDodgeMod = 0.0, percentDodgeMod = 0.0, flatCritChanceMod = 0.0, percentCritChanceMod = 0.0, flatCritDamageMod = 0.0, percentCritDamageMod = 0.0, flatMagicResistMod = 0.0, percentMagicResistMod = 0.0, flatEXPBonus = 0.0, percentEXPBonus = 0.0, epicness = 1,  },
    }

    function SpellLevelHandler()
        local skillOrder = {"W","E","W","Q","W","R","W","E","W","E","R","E","Q","E","Q","R","Q","Q"}
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