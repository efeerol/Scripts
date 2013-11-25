--[[
    Script: IGER's GlobalMultiChampCombo v1.0
    Author: PedobearIGER
]]--

spellNameTable = {
    "EnchantedCrystalArrow", --Ashe
    "EzrealMysticShot", --Ezreal
    "DravenRCast", --Draven
    "CannonBarrage", --Gangplank
    "FallenOne", --? Kartus
    "LuxMaliceCannon", --Lux
    "??", --?? Nocturne
    "Pantheon_GrandSkyfall_Fall", --Pantheon Pantheon_GrandSkyfall_Jump
    "gate", --Twisted Fate Destiny
    "ZiggsR" --Ziggs
}

if (GetSelf().name == "Ashe" or GetSelf().name == "Ezreal" or GetSelf().name == "Draven" or GetSelf().name == "Gangplank" or GetSelf().name == "Kartus" or GetSelf().name == "Lux" or GetSelf().name == "Nocturne" or GetSelf().name == "Pantheon" or GetSelf().name == "TwistedFate" or GetSelf().name == "Ziggs") then
    require "Utils"
    function OnProcessSpell(object,spell)
        if object.team == myHero.team and object ~= nil and spell ~= nil and object.x ~= nil and spell.name ~= nil and object.name ~= nil then
            if object.name == "Nocturne" then printtext(spell.name.."\n") end
            for i,spellName in ipairs(spellNameTable) do 
                if spellName == spell.name then
                    if spell.target ~= nil and spell.target.x ~= nil and (myHero.name == "TwistedFate" or myHero.name == "Ashe" or myHero.name == "Ezreal" or myHero.name == "Draven" or myHero.name == "Gangplank" or myHero.name == "Kartus" or (myHero.name == "Lux" and GetDistance(spell.target) < 3000) or (myHero.name == "Pantheon" and GetDistance(spell.target) < 5500) or (myHero.name == "Ziggs" and GetDistance(spell.target) < 5300) or (myHero.name == "Nocturne" and GetDistance(spell.target) < 1250+GetSpellLevel("R")*750)) then 
                        CastSpellTarget("R",spell.target)
                        CastSpellXYZ("R",spell.target.x,spell.target.y,spell.target.z)
                        CastSpellTarget("R",myHero)
                    elseif spell.endPos ~= nil and spell.endPos.x ~= nil and (myHero.name == "TwistedFate" or myHero.name == "Ashe" or myHero.name == "Ezreal" or myHero.name == "Draven" or myHero.name == "Gangplank" or myHero.name == "Kartus" or (myHero.name == "Lux" and GetDistance(spell.endPos) < 3000) or (myHero.name == "Pantheon" and GetDistance(spell.endPos) < 5500) or (myHero.name == "Ziggs" and GetDistance(spell.endPos) < 5300) or (myHero.name == "Nocturne" and GetDistance(spell.endPos) < 1250+GetSpellLevel("R")*750)) then
                            CastSpellXYZ("R",spell.endPos.x,spell.endPos.y,spell.endPos.z)
                            CastSpellTarget("R",myHero)
                        end
                    end
                    break
                end
            end
        end
    end
end

function OnTick()
--This useless function is needed
--because you can't load scripts
--that have not TimerCallback.
end
SetTimerCallback("OnTick")