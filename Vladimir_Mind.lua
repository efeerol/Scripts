-- #Vlad Script
require "Utils"
require "spell_damage" 

printtext("\nDo I sparkle?\n")

local target

function Run()
	target = GetWeakEnemy('MAGIC',1220)
	igniter = GetWeakEnemy('TRUE',600)
	if VladConfig.QEPoke then QEPoke() end
	if VladConfig.QPoke then QPoke() end
	if VladConfig.AutoIgnite then autoIgnite() end
	if VladConfig.Combo then Combo() end
	if VladConfig.rCombo then rCombo() end
end 

function Q()
if GetDistance(target) < 600 then
		if CanCastSpell("Q") then
			CastSpellTarget("Q",target) end
	end
end	

function W()
	if GetDistance(target) < 270 then
		if CanCastSpell("W") then
			CastSpellTarget("W",myHero) end
	end
end

function E()
	if GetDistance(target) < 1220 then
		if CanCastSpell("E") then 
		CastSpellTarget("E",target) end
	end
end

function R()
	if GetDistance(target) < 700 then
	if CanCastSpell("R") then
			local ultPos = GetMEC(350, 700, target)
			if ultPos then
				CastSpellXYZ("R", ultPos.center.x, 0, ultPos.center.z)
			else
				CastSpellTarget("R", target)
			end
		end
	end
end
	
function autoIgnite()
    local damage = (myHero.selflevel*20)+50
    if igniter ~= nil then
                if myHero.SummonerD == "SummonerDot" then
                        if target.health < damage then
                                CastSpellTarget("D",igniter)
                        end
                end
                if myHero.SummonerF == "SummonerDot" then
                        if target.health < damage then
                                CastSpellTarget("F",igniter)
                        end
                end
        end
end
 
function Combo() 
	if target ~= nil then
		if GetDistance(target) < 600 then
		UseTargetItems(target) 
		E()
		Q()
		R()
		W()
		E()
		Q()
		end
	end
end	
function rCombo() 
	if target ~= nil then
		if GetDistance(target) < 600 then
		UseTargetItems(target) 
		R()
		E()
		Q()
		W()
		end
	end
end	

function QEPoke() 
	if target ~= nil then
		if GetDistance(target) < 600 then	
		E()
		Q()
		end
	end
end	

function QPoke() 
	if target ~= nil then
		if GetDistance(target) < 600 then	
		Q()
		end
	end
end	

function kSteal()	
	if target ~= nil then 
	qDmg = getDmg("Q", target,myHero)
	wDmg = getDmg("W", target,myHero)
	eDmg = getDmg("E", target,myHero)
	rDmg = getDmg("R", target,myHero)
	if GetDistance(myHero,target) < 700 then
	if target.health<(eDmg+wDmg+qDmg+rDmg) then
				E()
		end
		if GetDistance(target) < 200 then
		if target.health<(eDmg+wDmg+qDmg+rDmg) then
				W() end
		end
		if target.health<(eDmg+wDmg+qDmg+rDmg) then
				Q()
		end
		if target.health<(eDmg+wDmg+qDmg+rDmg) then
				R()
		end
		if target.health<(eDmg+wDmg+qDmg+rDmg) then
				AttackTarget(target)
			end
		end
	end
end

function OnDraw()
    if VladConfig.drawCircles then 	
        CustomCircle(myHero.range,4,3,myHero) 
        if target ~= nil then 
            CustomCircle(100,4,1,target) 
        for i = 1, objManager:GetMaxHeroes()  do
            local enemy = objManager:GetHero(i)
            if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) then
                local qdmg = getDmg("Q",enemy,myHero)*CanUseSpell("Q")
                local wdmg = getDmg("W",enemy,myHero)*CanUseSpell("W")
				local edmg = getDmg("E", enemy, myHero)*CanUseSpell("E") 
                local rdmg = getDmg("R",enemy,myHero)*CanUseSpell("R")
                if enemy.health < (qdmg+wdmg+edmg+rdmg) then 
                    DrawTextObject("BURN THE WITCH", enemy, Color.Red)
                    CustomCircle(500,4,2,enemy)
					end
                end
            end
        end
    end
end


VladConfig = scriptConfig("Vladimir Config", "vladconf") 
VladConfig:addParam("Combo", "Press to Space to Combo#1", SCRIPT_PARAM_ONKEYDOWN, false, 32)
VladConfig:addParam("rCombo", "Press to Space Combo#2(Ult-Start)", SCRIPT_PARAM_ONKEYDOWN, false, 84)
VladConfig:addParam("QEPoke", "Press to X to QEPoke", SCRIPT_PARAM_ONKEYTOGGLE, false, 88)
VladConfig:addParam("QPoke", "Press to Z to QPoke", SCRIPT_PARAM_ONKEYTOGGLE, false, 90)
VladConfig:addParam("AutoIgnite", "Auto-Igniter", SCRIPT_PARAM_ONKEYTOGGLE, false, 113)
VladConfig:addParam("drawCircles", "Kill Markers", SCRIPT_PARAM_ONOFF, false, 112)
VladConfig:permaShow("Combo")
VladConfig:permaShow("rCombo")
VladConfig:permaShow("QEPoke")
VladConfig:permaShow("QPoke")
VladConfig:permaShow("AutoIgnite")
VladConfig:permaShow("drawCircles")

SetTimerCallback("Run")