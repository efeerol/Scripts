--[[
8888888b.            .d888 888  .d8888b.  888     .d8888b.                                      d8888 888              d8b 
888   Y88b          d88P"  888 d88P  Y88b 888    d88P  Y88b                                    d88888 888              Y8P 
888    888          888    888 Y88b.      888    888    888                                   d88P888 888                  
888   d88P  .d88b.  888888 888  "Y888b.   888888 888    888 88888b.d88b.  88888b.            d88P 888 88888b.  888d888 888 
8888888P"  d88""88b 888    888     "Y88b. 888    888    888 888 "888 "88b 888 "88b          d88P  888 888 "88b 888P"   888 
888 T88b   888  888 888    888       "888 888    888    888 888  888  888 888  888         d88P   888 888  888 888     888 
888  T88b  Y88..88P 888    888 Y88b  d88P Y88b.  Y88b  d88P 888  888  888 888 d88P        d8888888888 888  888 888     888 
888   T88b  "Y88P"  888    888  "Y8888P"   "Y888  "Y8888P"  888  888  888 88888P"        d88P     888 888  888 888     888 
                                                                          888                                              
                                                                          888                                              
                                                                          888                                              
--]]

require "Utils"
require "spell_damage"

printtext("\nAhri's Dead, Baby")
local target
local rTimer = 0

AhriConfig = scriptConfig("Ahribot", "Ahricombo")
AhriConfig:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
AhriConfig:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X")) --x
AhriConfig:addParam("escape", "Escape", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C")) --x
AhriConfig:addParam("killsteal", "KillSteal", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("J")) --x
AhriConfig:addParam("movement", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)
AhriConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)

function OnTick()
if IsChatOpen() == 0 then


if AhriConfig.Combo then
	target = GetWeakEnemy("MAGIC", 975, "NEARMOUSE")
	if target ~= nil then
	CustomCircle(100,4,1,target)
	
		UseAllItems(target)
		
		if GetDistance(target) < 880 then
		CastHotkey('AUTO 100,0 ATTACK:WEAKENEMY PATROLSTRAFE')
		end
		
		if CanCastSpell("R") and GetDistance(target) < 550 then CastSpellXYZ('R',mousePos.x,0,mousePos.z)
		printtext("R\n")
		end
		
		if CanCastSpell("Q") and GetDistance(target) < 880 then
		CastSpellXYZ("Q",GetFireahead(target,2,15)) 
		printtext("Q\n")
		end
	
		if CanCastSpell("E") and GetDistance(target) < 975 and CreepBlock(target.x,target.y,target.z) == 0 then
		CastSpellXYZ("E",GetFireahead(target,2,16)) 
		printtext("E\n")
		end
		
	
		if CanCastSpell("W") and GetDistance(target) < 800 then
		CastSpellTarget("W",target) 
		printtext("W\n")
		end

	end
end


if AhriConfig.harass then
target = GetWeakEnemy("MAGIC", 975, "NEARMOUSE")
		if target ~= nil then
	CustomCircle(100,4,1,target)
		
		if GetDistance(target) < 880 then
		CastHotkey('AUTO 100,0 ATTACK:WEAKENEMY PATROLSTRAFE')
		end
		
		if CanCastSpell("R") and GetDistance(target) < 900 then CastSpellXYZ('R',mousePos.x,0,mousePos.z)
		printtext("R\n")
		end
		
		if CanCastSpell("Q") and GetDistance(target) < 880 then
		CastSpellXYZ("Q",GetFireahead(target,2,15)) 
		printtext("Q\n")
		end
	
		if CanCastSpell("E") and GetDistance(target) < 975 and CreepBlock(target.x,target.y,target.z) == 0 then
		CastSpellXYZ("E",GetFireahead(target,2,16)) 
		printtext("E\n")
		end
		
	end

end


if AhriConfig.escape then
		if CanCastSpell("R") then CastSpellXYZ('R',mousePos.x,0,mousePos.z)
		end
end



if AhriConfig.movement and (AhriConfig.harass or AhriConfig.Combo or AhriConfig.escape) then
MoveToMouse()
end	
end
end

function OnDraw()
if AhriConfig.drawcircles then
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
				
				
				if AhriConfig.killsteal then
					if qdmg > enemy.health and CanCastSpell("Q") and GetDistance(enemy) < 880 then
					CastSpellXYZ("Q",GetFireahead(enemy,2,15)) 
					printtext("Qsteal\n")
					end
				end
				
end
end
	end
end
SetTimerCallback("OnTick")