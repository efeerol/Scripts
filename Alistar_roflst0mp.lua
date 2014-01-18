require "Utils"
require "spell_damage"

printtext("\nAlistar's Dead, Baby")
local target
local pTimer = 0

AlistarConfig = scriptConfig("Alistarbot", "Alistarcombo")
AlistarConfig:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
AlistarConfig:addParam("headbutt", "AutoSmash", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X")) --x
AlistarConfig:addParam("popup", "Defend", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C")) --x
AlistarConfig:addParam("killsteal", "KillSteal", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("J")) --x
AlistarConfig:addParam("safe", "Safe Harass", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("K")) --x
AlistarConfig:addParam("movement", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)
AlistarConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)

function OnTick()
if IsChatOpen() == 0 then


if AlistarConfig.Combo then
	target = GetWeakEnemy("MAGIC", 650, "NEARMOUSE")
	if target ~= nil then
	CustomCircle(100,4,1,target)
	
		UseAllItems(target)
		
		if GetDistance(target) < myHero.range then
		AttackTarget(target)
		end
		
		if CanCastSpell("W") then 
			if GetDistance(target) < 650 then CastSpellTarget('W',target)
			printtext("W\n")
			end
		end
		
		if CanCastSpell("Q") then
			if GetDistance(target) < 400 then CastSpellTarget('Q',target)
			printtext("Q\n")
			pTimer = GetTickCount() + 2850
			end
		end

		if CanCastSpell("E") then
			if GetTickCount() > pTimer and GetDistance(target) < 180 then CastSpellTarget('E',target)
			printtext("E\n")
			end
		end
		
		if CanCastSpell("R") then
			if GetTickCount() > pTimer and GetDistance(target) < 180 then CastSpellTarget('R',target)
			printtext("R\n")
			end
		end

	end
end


if AlistarConfig.headbutt then
	target = GetWeakEnemy("MAGIC", 650, "NEARMOUSE")
	if target ~= nil then
	CustomCircle(100,4,1,target)
	
		
		if GetDistance(target) < myHero.range then
		AttackTarget(target)
		end
		
		if CanCastSpell("W") then 
			if GetDistance(target) < 650 then CastSpellTarget('W',target)
			printtext("R\n")
			end
		end
		if CanCastSpell("Q") then
			if GetDistance(target) < 400 then CastSpellTarget('Q',target)
			printtext("R\n")
			pTimer = GetTickCount() + 2850
			end
		end


		


	end
end

if AlistarConfig.popup then
local popTimer = 0
	target = GetWeakEnemy("MAGIC", 650, "NEARMOUSE")
	if target ~= nil then
	CustomCircle(100,4,1,target)
	
		
		if GetDistance(target) < myHero.range then
		AttackTarget(target)
		end
				
		if CanCastSpell("Q") then
			if GetDistance(target) < 400 then CastSpellTarget('Q',target)
			printtext("R\n")
			popTimer = GetTickCount() + 500
			end
		end
		if CanCastSpell("W") then 
			if target.y > myHero.y and not CanCastSpell("Q") then CastSpellTarget('W',target)
			printtext("R\n")
			end
		end



	end
end



if AlistarConfig.movement and (AlistarConfig.headbutt or AlistarConfig.Combo or AlistarConfig.popup or AlistarConfig.escape) then
MoveToMouse()
end	
end
end

function OnDraw()
if AlistarConfig.drawcircles then
	CustomCircle(975,5,2,myHero) --E
	CustomCircle(800,1,1,myHero) --W
	CustomCircle(myHero.range,1,4,myHero) 
	CustomCircle(880,10,3,myHero) --Q
if target then 	CustomCircle(50,5,2,target) end
for i = 1, objManager:GetMaxHeroes()  do
			local enemy = objManager:GetHero(i)
			if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) then
				local pdmg = getDmg("P",enemy,myHero) 
				local qdmg = getDmg("Q",enemy,myHero)*CanUseSpell("Q") 
				local wdmg = getDmg("W",enemy,myHero)*CanUseSpell("W")
				local edmg = getDmg("E",enemy,myHero)*CanUseSpell("E")
				local rdmg = getDmg("R",enemy,myHero)*CanUseSpell("R")
				local aadmg = getDmg("AD",enemy,myHero)
				
				if qdmg+wdmg+edmg+rdmg > enemy.health then CustomCircle(50,10,5,enemy) DrawTextObject("ComboKill!", enemy, Color.Red)	end
				
				
				if AlistarConfig.killsteal then
					if qdmg+wdmg > enemy.health then
						if CanCastSpell("W") then 
							if GetDistance(target) < 650 then CastSpellTarget('W',target)
							end
						end
						if CanCastSpell("Q") then
							if GetDistance(target) < 400 then CastSpellTarget('Q',target)
							printtext("R\n")
							end
						end

					end
				end
				
end
end
	end
end
SetTimerCallback("OnTick")