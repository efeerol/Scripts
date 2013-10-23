require 'Utils'
require 'spell_shot'

local version = '1.1'
local target
local targetIgnite
local x1, y1, z1
local x2, y2, z2
local x3, y3, z3
local seedX = 0
local seedY = 0
local seedZ = 0
local attacking = false
local planting = false
local timer0 = 0
local timer1 = 0
local t0_attacking = 0
local attackAnimationDuration = 250
local spellShot = {shot = false, radius = 0, time = 0, shotX = 0, shotZ = 0, shotY = 0, safeX = 0, safeY = 0, safeZ = 0, isline = false}
local startPos = {x=0, y=0, z=0}
local endPos = {x=0, y=0, z=0}

function ZyraRun()
	if planting then
		target = GetWeakEnemy('TRUE',1500)
	else
		target = GetWeakEnemy('MAGIC',1100)
	end
	targetIgnite = GetWeakEnemy('TRUE',600)
	if target ~= nil then
		x1, y1, z1 = GetFireahead(target,3,6.2)
		x2, y2, z2 = GetFireahead(target,0.5,8.8)
		x3, y3, z3 = GetFireahead(target,4,99)
	end
	Util__OnTick()
	ResetTimer()
	if ZyraConfig.combo then combo() end
	if ZyraConfig.autoGrowth then autoGrowth() end
	if ZyraConfig.autoThorns then autoThorns() end
	if ZyraConfig.ignite then ignite() end
	if ZyraConfig.dodge then dodge() end
end

ZyraConfig = scriptConfig("Zyra Config", "zyraconfig")
ZyraConfig:addParam("combo", "Combo (X)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
ZyraConfig:addParam("autoThorns", "Rise of the Thorns", SCRIPT_PARAM_ONKEYTOGGLE, true, 111)
ZyraConfig:addParam("autoGrowth", "Rampant Growth", SCRIPT_PARAM_ONKEYTOGGLE, true, 112)
ZyraConfig:addParam("useItems", "Use Items", SCRIPT_PARAM_ONKEYTOGGLE, true, 113)
ZyraConfig:addParam("ignite", "Auto Ignite", SCRIPT_PARAM_ONKEYTOGGLE, true, 114)
ZyraConfig:addParam("dodge", "Auto Dodge", SCRIPT_PARAM_ONKEYTOGGLE, true, 115)
ZyraConfig:permaShow("combo")
ZyraConfig:permaShow("autoThorns")
ZyraConfig:permaShow("autoGrowth")
ZyraConfig:permaShow("useItems")
ZyraConfig:permaShow("ignite")
ZyraConfig:permaShow("dodge")

function ResetTimer()
	if GetTickCount() - timer0 > 275 then
		attacking = false
		timer0 = 0
	end
	if GetTickCount() - timer1 > 10000 then
		planting = false
		timer1 = 0
	end
	if GetTickCount() - spellShot.time > 100 then
		spellShot.shot = false
		spellShot.time = 0
	end
end

function dodge()
	if spellShot.shot and GetDistance({x=spellShot.shotX, y=spellShot.shotY, z=spellShot.shotZ}) > spellShot.radius then
		spellShot.shot = false
	end
	if spellShot.shot then
		MoveToXYZ(spellShot.safeX, spellShot.safeY, spellShot.safeZ)
	end
end

function ignite()
	local damage = (myHero.selflevel*20)+50
	if targetIgnite ~= nil and targetIgnite.health < damage then
		CastSummonerIgnite(targetIgnite) 
	end
end

function combo()
	if spellShot.shot then return end
	if target ~= nil then
		if ZyraConfig.useItems then
			UseAllItems(target)
		end
		if attacking == false and CanCastSpell("E") and GetDistance({x=x2, y=y2, z=z2}) < 1100 then
			CastSpellXYZ("E",x2,y2,z2)
		end
		if attacking == false and CanCastSpell("Q") and GetDistance({x=x1, y=y1, z=z1}) < 825 then
			CastSpellXYZ("Q",x1,y1,z1)
		end
		if attacking == false and CanCastSpell("R") and GetDistance({x=x3, y=y3, z=z3}) < 700 then
			CastSpellXYZ("R",x3,y3,z3)
		end
	end
	if target == nil and ZyraConfig.combo then
		MoveToMouse()
	elseif ZyraConfig.combo then
		AttackTarget(target)
	end
end

function autoThorns()
	if planting then
		if target ~= nil then
			local x, y, z = GetFireahead(target,2,18)			
			if CanCastSpell("Q") then
				CastSpellXYZ("Q",x,y,z)
			end
			if CanCastSpell("E") then
				CastSpellXYZ("E",x,y,z)
			end
			if CanCastSpell("W") then
				CastSpellXYZ("W",x,y,z)
			end
			end			
		end
end

function autoGrowth()
	if target ~= nil then
		if attacking == true and GetClock() > t0_attacking then
			if CanCastSpell("W") then
				CastSpellXYZ("W",seedX,seedY,seedZ)
			end	
			attacking = false
			timer0 = 0
		end
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

function OnProcessSpell(unit,spell)
	if target ~= nil and unit ~= nil and spell ~= nil and unit.charName == myHero.charName then
		if string.find(spell.name,"ZyraQFissure") then
			seedX = spell.endPos.x
			seedY = spell.endPos.y
			seedZ = spell.endPos.z
			t0_attacking = GetClock()+attackAnimationDuration
			attacking = true
			timer0 = GetTickCount()			
		end
		if string.find(spell.name,"ZyraGraspingRoots") then		
    	local angle = GetAngle(spell.startPos,spell.endPos)
    	local point = GetLinePoint(spell.startPos,angle,820)	
    	seedX = point.x
    	seedY = 0
    	seedZ = point.z	    			
			t0_attacking = GetClock()+attackAnimationDuration
			attacking = true
			timer0 = GetTickCount()			
		end
	end
	if unit ~= nil and unit.team ~= myHero.team and IsHero(unit) and spell ~= nil then
		local shot = SpellShotTarget(unit, spell, myHero)
		if shot ~= nil then
			startPos = spell.startPos
			endPos = spell.endPos
			spellShot = shot	
		end
	end
end

function OnCreateObj(obj)
  if obj~=nil then
  	if string.find(obj.charName,"zyra_emote_death_sound") then
			planting = true
			timer1 = GetTickCount()			
  	end
  end
end

function OnDraw()
	if myHero.dead == 0 then
		CustomCircle(1100,6,3,myHero)
		CustomCircle(825,6,5,myHero)
		CustomCircle(700,6,2,myHero)
		if target ~= nil then
			if planting then
				CustomCircle(100,4,1,target)
			else
				if GetDistance({x=x3,y=y3,z=z3}) < 700 then
					CustomCircle(100,4,2,target)
				elseif GetDistance({x=x1,y=y1,z=z1}) < 825 then
					CustomCircle(100,4,5,target)
				elseif GetDistance({x=x2,y=y2,z=z2}) < 1100 then
					CustomCircle(100,4,3,target)
				end
			end
		end
		if spellShot.shot then
			if spellShot.isline then
				local angle = GetAngle(endPos, startPos)
				DrawLine(startPos.x, startPos.y, startPos.z, GetDistance(startPos, endPos)+spellShot.radius, 1, angle, spellShot.radius)
			else
				CustomCircle(spellShot.radius,1,3,"",endPos.x,endPos.y,endPos.z)
			end
			CustomCircle(100,4,1,"",spellShot.safeX,spellShot.safeY,spellShot.safeZ)
		end
	end
end

SetTimerCallback("ZyraRun")
print("\nChad's Zyra v"..version.."\n")