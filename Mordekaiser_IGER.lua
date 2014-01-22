--[[
    Script: Insane Mordekaiser BurstCombo v0.2
    Author: PedobearIGER
]]--

if GetSelf().name == "Mordekaiser" then
    require "Utils"
    local version = "0.2"
    local hotkey = 32 --combohotkey (default: space)
    local minRange = nil --only cast the combo if the target is in this range, set it to nil to use the spells ranges defnited in the table below
    local targeting = "MostLikelyKillable" -- future updates will also support "MarkedUnit", "NearestToMouse", "MostExpenciveItems"
    
    local fullCombo = {"DeathfireGrasp","Q","W","E","R","HextechGunblade","BilgewaterCutlass","Ignite","Exhaust"}
    local noQWCombo = {"DeathfireGrasp","E","R","HextechGunblade","BilgewaterCutlass","Ignite","Exhaust"}
    local LowHpCombo = {"DeathfireGrasp","Q","W","R","E","HextechGunblade","BilgewaterCutlass","Ignite","Exhaust"}
    local noQWLowHpCombo = {"DeathfireGrasp","R","E","HextechGunblade","BilgewaterCutlass","Ignite","Exhaust"}
    
    local spellInfo = {
        --spellName: "Q","W","E" or "R"
        --castType: "None", "Target" or "Position"
        --range: for example: 0 or 100 or 550 or "Global"
        --dmgType: 'phys', 'magic' or 'true'
        --mode: "ActivateOnly", "SeöfCast" or "EnemyCast"
        Q = { spellName = "Q", castType = "None",     range = 0,   dmgType = 'none',  mode = "ActivateOnly", },
        W = { spellName = "W", castType = "Target",   range = 600, dmgType = 'magic', mode = "SelfCast",     },
        E = { spellName = "E", castType = "Position", range = 650, dmgType = 'magic', mode = "EnemyCast",    },
        R = { spellName = "R", castType = "Target",   range = 850, dmgType = 'magic', mode = "EnemyCast",    },
        
        Barrier =      { spellName = "Barrier",      castType = "None",     range = 0,        dmgType = 'none',  mode = "ActivateOnly", },
      --Clairvoience = { spellName = "Clairvoience", castType = "Position", range = "Global", dmgType = 'none',  mode = "---",          },
        Clarity =      { spellName = "Clarity",      castType = "None",     range = 0,        dmgType = 'none',  mode = "ActivateOnly", },
        Cleanse =      { spellName = "Cleanse",      castType = "None",     range = 0,        dmgType = 'none',  mode = "ActivateOnly", },
        Exhaust =      { spellName = "Exhaust",      castType = "Target",   range = 550,      dmgType = 'phys',  mode = "EnemyCast",    },
        Flash =        { spellName = "Flash",        castType = "Position", range = 400,      dmgType = 'magic', mode = "EnemyCast",    },
      --Garrison =     { spellName = "Garrison",     castType = "Target",   range = 1000,     dmgType = 'none',  mode = "---",          },
        Ghost =        { spellName = "Ghost",        castType = "None",     range = 0,        dmgType = 'none',  mode = "ActivateOnly", },
        Heal =         { spellName = "Heal",         castType = "None",     range = 0,        dmgType = 'none',  mode = "ActivateOnly", },
        Ignite =       { spellName = "Ignite",       castType = "Target",   range = 600,      dmgType = 'true',  mode = "EnemyCast",    },
      --Smite =        { spellName = "Smite",        castType = "Target",   range = 625,      dmgType = 'true',  mode = "---",          },
      --Teleport =     { spellName = "Cleanse",      castType = "Target",   range = "Global", dmgType = 'none',  mode = "---",          },
        Revive =       { spellName = "Revive",       castType = "None",     range = 0,        dmgType = 'none',  mode = "ActivateOnly", },
        
        DeathfireGrasp =       { spellName = "DeathfireGrasp",       castType = "Target", range = 750, dmgType = 'magic', mode = "EnemyCast",    },
        HextechGunblade =      { spellName = "HextechGunblade",      castType = "Target", range = 700, dmgType = 'magic', mode = "EnemyCast",    },
        BilgewaterCutlass =    { spellName = "BilgewaterCutlass",    castType = "Target", range = 400, dmgType = 'magic', mode = "EnemyCast",    },
        BladeOfTheRuinedKing = { spellName = "BladeOfTheRuinedKing", castType = "Target", range = 500, dmgType = 'phys',  mode = "EnemyCast",    },
        Entropy =              { spellName = "Entropy",              castType = "Target", range = 400, dmgType = 'true',  mode = "EnemyCast",    },
        OdynsVeil =            { spellName = "OdynsVeil",            castType = "Target", range = 525, dmgType = 'magic', mode = "EnemyCast",    },
        RanduinsOmen =         { spellName = "RanduinsOmen",         castType = "Target", range = 500, dmgType = 'phys',  mode = "EnemyCast",    },
        RavenousHydra =        { spellName = "RavenousHydra",        castType = "Target", range = 400, dmgType = 'phys',  mode = "EnemyCast",    },
        SwordOfTheDivine =     { spellName = "SwordOfTheDivine",     castType = "None",   range = 0,   dmgType = 'none',  mode = "ActivateOnly", },
        YoumuusGhostblade =    { spellName = "YoumuusGhostblade",    castType = "None",   range = 0,   dmgType = 'none',  mode = "ActivateOnly", },
    }
    
    MordeConfig = scriptConfig("Insane Mordekaiser BurstCombo","enableMordeCombo")
    MordeConfig:addParam("enableMordeCombo", "Mordekaiser Combo", SCRIPT_PARAM_ONKEYDOWN, false, hotkey)
    MordeConfig:permaShow("enableMordeCombo")
    
    function OnTick()
       Util__OnTick()
       if MordeConfig.enableMordeCombo then 
           if GetWeakEnemy('magic',100) ~= nil then 
               if myHero.health < myHero.maxHealth/100*15 then
                   DoCombo(noQWLowHpCombo)
               else 
                   DoCombo(noQWCombo)
               end
           else
               if myHero.health < myHero.maxHealth/100*15 then
                   DoCombo(LowHpCombo)
               else 
                   DoCombo(fullCombo)
               end
           end
       end
       if myHero.dead == 0 then DrawCircleObject(myHero,850,3) end
    end
    
    function DoCombo(spells)
        for i,spell in ipairs(spells) do
            if spell ~= nil and spellInfo[spell].spellName ~= nil then
                if spellInfo[spell].spellName == "Q" and IsSpellCastable(spellInfo[spell].spellName) and MordeQActive() == false then 
                    CastSpellCustom(spellInfo[spell].spellName,spellInfo[spell].castType,spellInfo[spell].range,spellInfo[spell].dmgType,spellInfo[spell].mode)
                    break
                elseif spellInfo[spell].spellName == "W" and IsSpellCastable(spellInfo[spell].spellName) then
                    CastSpellCustom(spellInfo[spell].spellName,spellInfo[spell].castType,spellInfo[spell].range,spellInfo[spell].dmgType,spellInfo[spell].mode)
                    break
                elseif spellInfo[spell].spellName == "E" and IsSpellCastable(spellInfo[spell].spellName) then
                    CastSpellCustom(spellInfo[spell].spellName,spellInfo[spell].castType,spellInfo[spell].range,spellInfo[spell].dmgType,spellInfo[spell].mode)
                    break
                elseif spellInfo[spell].spellName == "R" and IsSpellCastable(spellInfo[spell].spellName) then
                    CastSpellCustom(spellInfo[spell].spellName,spellInfo[spell].castType,spellInfo[spell].range,spellInfo[spell].dmgType,spellInfo[spell].mode)
                    break
                elseif spellInfo[spell].spellName == "Clarity" and IsSpellCastable(spellInfo[spell].spellName) then
                    CastSpellCustom(GetSlot(spellInfo[spell].spellName),spellInfo[spell].castType,spellInfo[spell].range,spellInfo[spell].dmgType,spellInfo[spell].mode)
                    break
                elseif spellInfo[spell].spellName == "Ghost" and IsSpellCastable(spellInfo[spell].spellName) then
                    CastSpellCustom(GetSlot(spellInfo[spell].spellName),spellInfo[spell].castType,spellInfo[spell].range,spellInfo[spell].dmgType,spellInfo[spell].mode)
                    break
                elseif spellInfo[spell].spellName == "Heal" and IsSpellCastable(spellInfo[spell].spellName) then
                    CastSpellCustom(GetSlot(spellInfo[spell].spellName),spellInfo[spell].castType,spellInfo[spell].range,spellInfo[spell].dmgType,spellInfo[spell].mode)
                    break
                elseif spellInfo[spell].spellName == "Revive" and IsSpellCastable(spellInfo[spell].spellName) then
                    CastSpellCustom(GetSlot(spellInfo[spell].spellName),spellInfo[spell].castType,spellInfo[spell].range,spellInfo[spell].dmgType,spellInfo[spell].mode)
                    break
                elseif spellInfo[spell].spellName == "Cleanse" and IsSpellCastable(spellInfo[spell].spellName) then
                    CastSpellCustom(GetSlot(spellInfo[spell].spellName),spellInfo[spell].castType,spellInfo[spell].range,spellInfo[spell].dmgType,spellInfo[spell].mode)
                    break
                elseif spellInfo[spell].spellName == "Barrier" and IsSpellCastable(spellInfo[spell].spellName) then
                    CastSpellCustom(GetSlot(spellInfo[spell].spellName),spellInfo[spell].castType,spellInfo[spell].range,spellInfo[spell].dmgType,spellInfo[spell].mode)
                    break
                elseif spellInfo[spell].spellName == "Exhaust" and IsSpellCastable(spellInfo[spell].spellName) then
                    CastSpellCustom(GetSlot(spellInfo[spell].spellName),spellInfo[spell].castType,spellInfo[spell].range,spellInfo[spell].dmgType,spellInfo[spell].mode)
                    break
                elseif spellInfo[spell].spellName == "Ignite" and IsSpellCastable(spellInfo[spell].spellName) then
                    CastSpellCustom(GetSlot(spellInfo[spell].spellName),spellInfo[spell].castType,spellInfo[spell].range,spellInfo[spell].dmgType,spellInfo[spell].mode)
                    break
                elseif spellInfo[spell].spellName == "Flash" and IsSpellCastable(spellInfo[spell].spellName) then
                    CastSpellCustom(GetSlot(spellInfo[spell].spellName),spellInfo[spell].castType,spellInfo[spell].range,spellInfo[spell].dmgType,spellInfo[spell].mode)
                    break
                elseif spellInfo[spell].spellName == "DeathfireGrasp" and IsSpellCastable(spellInfo[spell].spellName) then
                    CastSpellCustom(GetSlot(spellInfo[spell].spellName),spellInfo[spell].castType,spellInfo[spell].range,spellInfo[spell].dmgType,spellInfo[spell].mode)
                    break
                elseif spellInfo[spell].spellName == "HextechGunblade" and IsSpellCastable(spellInfo[spell].spellName) then
                    CastSpellCustom(GetSlot(spellInfo[spell].spellName),spellInfo[spell].castType,spellInfo[spell].range,spellInfo[spell].dmgType,spellInfo[spell].mode)
                    break
                elseif spellInfo[spell].spellName == "BilgewaterCutlass" and IsSpellCastable(spellInfo[spell].spellName) then
                    CastSpellCustom(GetSlot(spellInfo[spell].spellName),spellInfo[spell].castType,spellInfo[spell].range,spellInfo[spell].dmgType,spellInfo[spell].mode)
                    break
                elseif spellInfo[spell].spellName == "BladeOfTheRuinedKing" and IsSpellCastable(spellInfo[spell].spellName) then
                    CastSpellCustom(GetSlot(spellInfo[spell].spellName),spellInfo[spell].castType,spellInfo[spell].range,spellInfo[spell].dmgType,spellInfo[spell].mode)
                    break
                elseif spellInfo[spell].spellName == "Entropy" and IsSpellCastable(spellInfo[spell].spellName) then
                    CastSpellCustom(GetSlot(spellInfo[spell].spellName),spellInfo[spell].castType,spellInfo[spell].range,spellInfo[spell].dmgType,spellInfo[spell].mode)
                    break
                elseif spellInfo[spell].spellName == "OdynsVeil" and IsSpellCastable(spellInfo[spell].spellName) then
                    CastSpellCustom(GetSlot(spellInfo[spell].spellName),spellInfo[spell].castType,spellInfo[spell].range,spellInfo[spell].dmgType,spellInfo[spell].mode)
                    break
                elseif spellInfo[spell].spellName == "RanduinsOmen" and IsSpellCastable(spellInfo[spell].spellName) then
                    CastSpellCustom(GetSlot(spellInfo[spell].spellName),spellInfo[spell].castType,spellInfo[spell].range,spellInfo[spell].dmgType,spellInfo[spell].mode)
                    break
                elseif spellInfo[spell].spellName == "RavenousHydra" and IsSpellCastable(spellInfo[spell].spellName) then
                    CastSpellCustom(GetSlot(spellInfo[spell].spellName),spellInfo[spell].castType,spellInfo[spell].range,spellInfo[spell].dmgType,spellInfo[spell].mode)
                    break
                elseif spellInfo[spell].spellName == "SwordOfTheDivine" and IsSpellCastable(spellInfo[spell].spellName) then
                    CastSpellCustom(GetSlot(spellInfo[spell].spellName),spellInfo[spell].castType,spellInfo[spell].range,spellInfo[spell].dmgType,spellInfo[spell].mode)
                    break
                elseif spellInfo[spell].spellName == "YoumuusGhostblade" and IsSpellCastable(spellInfo[spell].spellName) then
                    CastSpellCustom(GetSlot(spellInfo[spell].spellName),spellInfo[spell].castType,spellInfo[spell].range,spellInfo[spell].dmgType,spellInfo[spell].mode)
                    break
                end
            end
        end
    end
        
    function CastSpellCustom(spell,castType,range,dmgType,mode)
        if minRange ~= nil then range = minRange end
        if range == "Global" then range = 20000 end
        printtext(spell)
        if (mode == "SelfCast" or mode == "ActivateOnly") then 
            if myHero.dead == 0 then
                if castType == "Position" then CastSpellXYZ(spell,myHero.x,myHero.y,myHero.z)
                elseif castType == "Target" or castType == "None" then CastSpellTarget(spell,myHero) end
            end
        elseif mode == "EnemyCast" then 
            if targeting == "MostLikelyKillable" then target = GetWeakEnemy(dmgType,range) end
            if target ~= nil and target.dead == 0 and target.health > 0 then --and target.visible == 0 and target.invulnerable == 0 then 
                if castType == "Position" then CastSpellXYZ(spell,target.x,target.y,target.z)
                elseif castType == "Target" then CastSpellTarget(spell,target) end
            end
        end
    end
    
    function IsSpellCastable(spell)
        if ((spell == "Q" or spell == "W" or spell == "E" or spell == "R") and GetSpellLevel(spell) > 0 and IsSpellReady(spell) == 1) or ((spell == "Exhaust" or spell == "Ignite" or spell == "DeathfireGrasp" or spell == "HextechGunblade" or spell == "BilgewaterCutlass") and GetSlot(spell) ~= nil and IsSpellReady(GetSlot(spell)) == 1) then return true end
    end
    
    function GetSlot(itemName)
        if itemName == "DeathfireGrasp" then return GetSlotForId(3128)
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
    
    function MordeQActive()
        for i=1, objManager:GetMaxObjects(), 1 do
            local object = objManager:GetObject(i)
            if object ~= nil and object.charName ~= nil and object.charName == "mordakaiser_maceOfSpades_activate.troy" then
                return true
            end
        end
        return false
    end
    
    function GetNearestChamp()
        local nearest = nil
        for i=1, objManager:GetMaxHeroes(), 1 do
            local hero = objManager:GetHero(i)
            if hero ~= nil and hero.team ~= myHero.team and (nearest ~= nil or GetDistance(myHero,hero) < GetDistance(myHero,nearest)) then nearest = hero end
        end
    end
    
    SetTimerCallback("OnTick")
    printtext("\n >> IGER's Insane Mordekaiser BurstCombo "..version.." loaded!\n")
end