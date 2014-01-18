require 'Utils'
require 'spell_shot'

local version = '2.1'
local target
local target2
local target3
local attacking = false
local t0_attacking = 0
local attackAnimationDuration = 250
local spellShot = {shot = false, radius = 0, time = 0, shotX = 0, shotZ = 0, shotY = 0, safeX = 0, safeY = 0, safeZ = 0, isline = false}
local startPos = {x=0, y=0, z=0}
local endPos = {x=0, y=0, z=0}
local shotMe = false

function JannaRun()
	local maxHealth = 9999
	target = nil
	target3 = GetWeakEnemy('Phys',600)
  for i=1, objManager:GetMaxHeroes(), 1 do
		local object = objManager:GetHero(i)
		if object ~= nil and object.team == myHero.team and GetDistance(object) < 800 and object.charName ~= myHero.charName then
			if object.health < maxHealth then
				maxHealth = object.health
				target = object;
			end
		end
	end
	Util__OnTick()
	ResetTimer()
	if JannaConfig.combo then combo() end
	if JannaConfig.autoGale then autoGale() end
	if JannaConfig.dodge then dodge() end
end

JannaConfig = scriptConfig("JannaConfig Config", "jannaconf")
JannaConfig:addParam("combo", "Combo (X)", SCRIPT_PARAM_ONKEYDOWN, false, 88)
JannaConfig:addParam("autoGale", "Howling Gale", SCRIPT_PARAM_ONKEYTOGGLE, true, 111)
JannaConfig:addParam("autoShield", "Eye Of The Storm", SCRIPT_PARAM_ONKEYTOGGLE, true, 112)
JannaConfig:addParam("exhaust", "Auto Exhaust", SCRIPT_PARAM_ONKEYTOGGLE, true, 113)
JannaConfig:addParam("dodge", "Auto Dodge", SCRIPT_PARAM_ONKEYTOGGLE, true, 114)
JannaConfig:permaShow("combo")
JannaConfig:permaShow("autoGale")
JannaConfig:permaShow("autoShield")
JannaConfig:permaShow("exhaust")
JannaConfig:permaShow("dodge")

function ResetTimer()
	if GetTickCount() - spellShot.time > 0 then
		spellShot.shot = false
		spellShot.time = 0
		shotMe = false
	end
end

function IsHero(unit)
  for i=1, objManager:GetMaxHeroes(), 1 do
		local object = objManager:GetHero(i)
		if object ~= nil and object.charName == unit.charName then
			return true
		end
	end
	return false
end

function dodge()
	if spellShot.shot and shotMe and GetDistance({x=spellShot.shotX, y=spellShot.shotY, z=spellShot.shotZ}) > spellShot.radius then
		spellShot.shot = false
		shotMe = false
	end
	if spellShot.shot and shotMe then
		MoveToXYZ(spellShot.safeX, spellShot.safeY, spellShot.safeZ)
	end
end

function combo()
	if spellShot.shot and shotMe then return end
	if target3 ~= nil then
		if CanCastSpell("W") and GetDistance(myHero, target3) < 600 then
			CastSpellTarget("W",target3)
		end
		if CanCastSpell("Q") and GetDistance(myHero, target3) < 1100 then
			CastSpellXYZ("Q",target3.x,target3.y,target3.z)
		end
	end	
	if target3 == nil and JannaConfig.combo then
		MoveToMouse()
	elseif JannaConfig.combo then
		AttackTarget(target3)
	end
	if JannaConfig.exhaust then exhaust() end
end

function autoGale()
	if target2 ~= nil and shotMe == false and GetClock() > t0_attacking then
	 	if target2.dead == 0 and CanCastSpell("Q") and GetDistance(target2) < 1100 then
			attacking = true
			CastSpellXYZ("Q",target2.x,target2.y,target2.z)
		end
		target2 = nil
	end
end

function autoShield(target)
	if JannaConfig.autoShield and CanCastSpell("E") then
		CastSpellTarget("E",target)
	end	
	t0_attacking = GetClock()+attackAnimationDuration
end

function exhaust()
	if target3 ~= nil and GetDistance(target3) < 550 then
		CastSummonerExhaust(target3) 
	end
end

function OnProcessSpell(unit, spell)
	if unit ~= nil and spell ~= nil and unit.team ~= myHero.team and IsHero(unit) then
		startPos = spell.startPos
		endPos = spell.endPos
		if spell.target ~= nil then
			local targetSpell = spell.target
			if target ~= nil and target.charName == targetSpell.charName then
				target2 = unit
				autoShield(target)
			end
			if myHero.charName == targetSpell.charName then
				target2 = unit
				autoShield(myHero)
			end			
		end
		if target ~= nil then
			local shot = SpellShotTarget(unit, spell, target)
			if shot ~= nil then
				spellShot = shot
				if spellShot.shot then
					target2 = unit
					autoShield(target)	
				end
			end
		end
		local shot = SpellShotTarget(unit, spell, myHero)
		if shot ~= nil then
			spellShot = shot
			if spellShot.shot then
				shotMe = true
				target2 = unit
				autoShield(myHero)	
			end
		end
	end
	if unit ~= nil and spell ~= nil and string.find(spell.name,"HowlingGale") and unit.charName == myHero.charName and attacking then
		attacking = false
		CastSpellTarget("Q",myHero)
	end
end

function OnDraw()
	if myHero.dead == 0 then
		CustomCircle(600,6,3,myHero)
		CustomCircle(800,6,1,myHero)
		if target ~= nil then
			CustomCircle(100,4,1,target)
		end
		if target2 ~= nil and GetDistance(target2) < 1100 then
			CustomCircle(100,4,3,target2)
		end
		if target3 ~= nil then
			CustomCircle(100,4,2,target3)
		end
		if spellShot.shot then
			if spellShot.isline then
				local angle = GetAngle(endPos, startPos)
				DrawLine(startPos.x, startPos.y, startPos.z, GetDistance(startPos, endPos)+spellShot.radius, 1, angle, spellShot.radius)
			else
				CustomCircle(spellShot.radius,1,3,"",endPos.x,endPos.y,endPos.z)
			end
			if shotMe then
				CustomCircle(100,4,5,"",spellShot.safeX,spellShot.safeY,spellShot.safeZ)
			end
		end
	end
end

SetTimerCallback("JannaRun")
print("\nChad's Janna v"..version.."\n")