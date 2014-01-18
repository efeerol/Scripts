--[[
Vincent - 12:18 PM 6/14/2013
0.12 - Released
TSM mod
--]]

require "utils"
require "spell_damage"

local target
local myHero = GetSelf()
local ball = false
local RAOE = false
local WAOE = false

OriannaConfig = scriptConfig("Oriannabot", "Oriannacombo")
OriannaConfig:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
OriannaConfig:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
OriannaConfig:addParam("movement", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)
OriannaConfig:addParam("Draw", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
OriannaConfig:permaShow("Combo")

function OriannaRun()
	target = GetWeakEnemy('Magic',825)
		if OriannaConfig.Draw then OnDraw()
		end
		if OriannaConfig.movement and (OriannaConfig.Combo or OriannaConfig.Harass) and not target then
		MoveToMouse()
		end    
			if OriannaConfig.Combo then
				if target ~= nil then
				UseTargetItems(target)
				if CanCastSpell("Q") and ValidTarget(target) then CastSpellXYZ('Q',GetFireahead(target,1.2,18)) end
				if CanCastSpell("W") and WAOE ~= false then CastSpellXYZ('W',target.x,0,target.z) end
				if CanCastSpell("R") and ValidTarget(target) and RAOE ~= false then CastSpellXYZ('R',target.x,0,target.z) end
				end
			end
               
			if OriannaConfig.Harass then
				if target ~= nil then
				if CanCastSpell("Q") and ValidTarget(target) then CastSpellXYZ('Q',GetFireahead(target,1.2,18)) end
				if CanCastSpell("W") and WAOE ~= false then CastSpellXYZ('W',target.x,0,target.z) end
				end
			end
end

function OnCreateObj(obj)
	target = GetWeakEnemy('Magic',825)
		if obj ~= nil then
			if string.find(obj.charName, "TheDoomBall") ~= nil then
				ball = true
				if GetDistance(obj,target) < 250 then WAOE = true
				else WAOE = false
				end
				if GetDistance(obj,target) < 325 then RAOE = true
				else RAOE = false
				end
			end
		end
end

function OnDraw()
	CustomCircle(825,4,3,myHero)
	if target ~= nil then
	CustomCircle(100,4,1,target)
	end
		for i = 1, objManager:GetMaxHeroes()  do
			local enemy = objManager:GetHero(i)
			if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) then
				local Q = getDmg("Q",enemy,myHero)*IsSpellReady("Q")
				local W = getDmg("W",enemy,myHero)*IsSpellReady("W")
				local R = getDmg("R",enemy,myHero)*IsSpellReady("R")
					if enemy.health<Q+W+R then
					CustomCircle(100,4,2,enemy)
					DrawTextObject("FINISH HIM!!!", enemy, Color.Red)                                
					end
			end
		end
end

SetTimerCallback("OriannaRun")