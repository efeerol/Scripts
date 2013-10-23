require 'utils'
require 'spell_damage'
local LocusOn = false
local LocusTimer = 0
local CanQ, CanW, CanE, CanR = false, false, false, false

MyTwoXerathsConfig = scriptConfig("My Two Xeraths", "mytwoxerathsconfig")
MyTwoXerathsConfig:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 90)
MyTwoXerathsConfig:addParam("KillSteal", "KillSteal", SCRIPT_PARAM_ONKEYDOWN, true, 99)

function MyTwoXeraths()
    BreakLocus()
    if myHero.SpellLevelQ > 0 and myHero.SpellTimeQ > 1 then CanQ=true else CanQ=false end
    if myHero.SpellLevelW > 0 and myHero.SpellTimeW > 1 then CanW=true else CanW=false end
    if myHero.SpellLevelE > 0 and myHero.SpellTimeE > 1 then CanE=true else CanE=false end
    if myHero.SpellLevelR > 0 and myHero.SpellTimeR > 1 then CanR=true else CanR=false end
    if GetClock()-LocusTimer > 0 then
        LocusOn=false
    end
    if LocusOn or (LocusOn==false and CanW) then
        target=GetWeakEnemy('Magic', 1675)
        LocusCircles()
        if ValidTarget(target) and MyTwoXerathsConfig.Combo then
            LocusCombo()
        end
    else
        target=GetWeakEnemy('Magic', 1100)
        NoLocusCircles()
        if ValidTarget(target) and MyTwoXerathsConfig.Combo then
            NoLocusCombo()
        end
    end
    targetignite = GetWeakEnemy('TRUE',600)
    KillSteal()
    AutoIgnite()
end

function LocusCombo()
    if ValidTarget(target) then
        if LocusOn==false and CanE then
            if (GetDistance(target) > 650 and GetDistance(target) < 950) then
                CastSpellTarget("W", myHero)
            elseif GetDistance(target) < 650 then
                CastSpellTarget("E", target)
            end
        end
        if LocusOn==false and CanR and RCheck(target) then
            if GetDistance(target) > 1100 then
                CastSpellTarget("W", myHero)
            elseif GetDistance(target) < 1100 then
                CastSpellXYZ("R",GetFireahead(target,4,99))
            end
        end
        if LocusOn==false and CanQ then
            if GetDistance(target) > 1100 then
                CastSpellTarget("W", myHero)
            elseif GetDistance(target) < 1100 then
                CastSpellXYZ("Q",GetFireahead(target,5,99))
            end
        end

        if LocusOn and CanE then
            if GetDistance(target) < 950 then
                CastSpellTarget("E", target)
            end
        end
        if LocusOn and CanR and RCheck(target) then
            if GetDistance(target) < 1675 then
                CastSpellXYZ("R",GetFireahead(target,4,99))
            end
        end
        if LocusOn and CanQ then
            if GetDistance(target) < 1675 then
                CastSpellXYZ("Q",GetFireahead(target,5,99))
            end
        end
    end
end

function NoLocusCombo()
    if ValidTarget(target) then
        if CanE and GetDistance(target) < 650 then
            CastSpellTarget("E", target)
        elseif CanR and GetDistance(target) < 1050 and RCheck(target) then
            CastSpellXYZ("R",GetFireahead(target,4,99))
        elseif CanQ and GetDistance(target) < 1050 then
            CastSpellXYZ("Q",GetFireahead(target,5,99))
        end
    end
end

function LocusCircles()
    if CanR then CustomCircle(1675, 3, 5, myHero) end
    if CanQ then CustomCircle(1672, 3, 2, myHero) end
    if CanE then CustomCircle(950, 3, 4, myHero) end
end

function NoLocusCircles()
    if CanR then CustomCircle(1050, 3, 5, myHero) end
    if CanQ then CustomCircle(1047, 3, 2, myHero) end
    if CanE then CustomCircle(650, 3, 4, myHero) end
end

function BreakLocus()
    if GetXerathLocus()==1 and IsKeyDown(2)==1 then
        CastSpellTarget("W", myHero)
        MoveToMouse()
        LocusOn=false
    end
end

function AutoIgnite()
    local damage = (myHero.selflevel*20)+50
    if targetignite ~= nil then
        if myHero.SummonerD == "SummonerDot" then
            if targetignite.health < damage then
                CastSpellTarget("D",targetignite)
            end
        end
        if myHero.SummonerF == "SummonerDot" then
            if targetignite.health < damage then
                CastSpellTarget("F",targetignite)
            end
        end
    end
end

function KillSteal()
    for i = 1, objManager:GetMaxHeroes()  do
    	local enemy = objManager:GetHero(i)
    	if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0 and enemy.dead==0) then
    		local qdmg = getDmg("Q",enemy,myHero)*CanUseSpell("Q")
    		local edmg = getDmg("E",enemy,myHero)*CanUseSpell("E")
    		local rdmg = getDmg("R",enemy,myHero)*CanUseSpell("R")
    		local aadmg = getDmg("AD",enemy,myHero)
        	if MyTwoXerathsConfig.KillSteal then
        		if LocusOn==false and edmg > enemy.health and CanE and GetDistance(enemy) < 650 then
        		    CastSpellTarget("E",enemy)
        		elseif LocusOn and CanE and edmg > enemy.health and GetDistance(enemy) < 950 then
        		    CastSpellTarget("E",enemy)
        		elseif LocusOn==false and CanQ and qdmg > enemy.health and GetDistance(enemy) < 1050 then
        		    CastSpellXYZ("Q",GetFireahead(enemy,5,99))
        		elseif LocusOn and CanQ and qdmg > enemy.health and GetDistance(enemy) < 1675 then
        		    CastSpellXYZ("Q",GetFireahead(enemy,5,99))
        		elseif LocusOn==false and CanR and rdmg > enemy.health and GetDistance(enemy) < 1050 then
        		    CastSpellXYZ("R",GetFireahead(enemy,4,99))
        		elseif LocusOn and CanR and rdmg > enemy.health and GetDistance(enemy) < 1675 then
        		    CastSpellXYZ("R",GetFireahead(enemy,4,99))
        		end
        	end
    	end
    end
end

function RCheck(target)
	local qdmg = getDmg("Q",target,myHero)*CanUseSpell("Q")
	local edmg = getDmg("E",target,myHero)*CanUseSpell("E")
	local rdmg = getDmg("R",target,myHero)*CanUseSpell("R")
	if ((rdmg*3)+qdmg) > target.health then
	    return true
	end
end


function OnProcessSpell(myHero, spell)
    if spell.name=="XerathLocusOfPower" then
        LocusOn=true
        LocusTimer=GetClock()+8000
    end
end

SetTimerCallback('MyTwoXeraths')
