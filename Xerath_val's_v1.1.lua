require 'Utils'

local version = '1.1.1'
local target
local QRange = 900
local ERange = 600
local RRange = 900
local attacking = false
local timer = 0
local t0_attacking = 0
local attackAnimationDuration = 200
local GetXerathLocus = 0

function XerathRun()
	target = GetWeakEnemy('MAGIC',1300)
	
	if myHero.SpellTimeQ > 1.0 then
	QRDY = 1
	else QRDY = 0
	end
	if myHero.SpellTimeW > 1.0 then
	WRDY = 1
	else WRDY = 0
	end
	if myHero.SpellTimeE > 1.0 then
	ERDY = 1
	else ERDY = 0
	end
	if myHero.SpellTimeR > 1.0 then
	RRDY = 1
	else RRDY = 0
	end

--	ResetTimer()
	if XerathConfig.BreakLocus then BreakLocus() end
	if XerathConfig.Combo then Combo() end
	if XerathConfig.Harass then Harass() end
end

	XerathConfig = scriptConfig("Xerath Config", "xerathconfig")
	XerathConfig:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 88)
	XerathConfig:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, 89)
	XerathConfig:addParam("useR", "Use Ult", SCRIPT_PARAM_ONKEYTOGGLE, true, 112)
	XerathConfig:addParam("useItems", "Use Items", SCRIPT_PARAM_ONKEYTOGGLE, true, 113)
	XerathConfig:addParam("BreakLocus", "RM break Locus", SCRIPT_PARAM_ONKEYTOGGLE, true, 114)
	XerathConfig:permaShow("Combo")
	XerathConfig:permaShow("Harass")
	XerathConfig:permaShow("useR")
	XerathConfig:permaShow("useItems")
	XerathConfig:permaShow("BreakLocus")
	
function OnProcessSpell(unit,spell)
	if target ~= nil then
		if unit ~= nil and spell ~= nil and unit.charName == myHero.charName then
			if spell.name == "xerathmagechains" and spell.target then
				t0_attacking = GetClock()+attackAnimationDuration
				attacking = true
				timer = GetTickCount()
			end
		end
	end
	if unit ~= nil and spell ~= nil and unit.charName == myHero.charName then
		if spell.name == "XerathLocusOfPower" then
			GetXerathLocus = 1
			QRange = 1300
			ERange = 900
			RRange = 1300
		end
		if spell.name == "xerathlocusofpowertoggle" then
			GetXerathLocus = 0
			QRange = 900
			ERange = 600
			RRange = 900
		end
	end
end

function ResetTimer()
	if GetTickCount() - timer > 300 then
		attacking = false
		timer = 0
	end
end

function BreakLocus()
	if GetXerathLocus == 1 and KeyDown(2) then
		CastSpellXYZ("W",myHero.x,myHero.y,myHero.z)
		MoveToXYZ(GetCursorWorldX(),GetCursorWorldY(),GetCursorWorldZ())
	end
end
	
function CastQ()
	if GetDistance(target) < QRange then
		if QRDY == 1 then
			CastSpellXYZ("Q",GetFireahead(target,5,99))
		end
	end
end
	
function CastW()
	if WRDY == 1 then
		if GetXerathLocus == 0 then
			CastSpellXYZ("W",myHero.x,myHero.y,myHero.z)
		end
	end
end
	
function CastE()
	if GetDistance(target) < ERange then
		if ERDY == 1 then
			CastSpellTarget("E",target)
		end
	end
end
	
function CastR()
	if XerathConfig.useR then
		if RRDY == 1 then
			if GetDistance(target) < RRange then
				CastSpellXYZ("R",GetFireahead(target,4,99))
			end
		end
	end
end

function Combo()
	if target ~= nil then
		if XerathConfig.useItems then
			UseTargetItems(target)
		end
		if ERDY == 1 and GetDistance(target) < 600 then
			CastE()
			if attacking == true and GetClock() > t0_attacking then
			CastQ()
			end
			attacking = false
			CastR()
		elseif ERDY == 1 and GetDistance(target) < 1000 then
			CastW()
			CastE()
			if attacking == true and GetClock() > t0_attacking then
			CastQ()
			end
			attacking = false
			CastR()
		elseif ERDY == 0 and GetDistance(target) < 900 then
			CastQ()
			CastR()
		elseif ERDY == 0 and GetDistance(target) < 1300 then
			CastW()
			CastQ()
			CastR()
		end
	end
end

function Harass()
	if target ~= nil then
		if GetDistance(target) < 900 then
			CastQ()
		elseif GetDistance(target) < 1300 then
			CastW()
			CastQ()
		end
	end
end

function OnDraw()
	if myHero.dead == 0 then
		if WRDY == 1 and QRDY == 1 then
			CustomCircle(1300,1,1,myHero) -- GREEN thin
			if target ~= nil then
				if GetDistance(target) < 1300 then
					CustomCircle(100,4,3,target) -- BLUE target
				end
			end
		end
		if WRDY == 1 and ERDY == 1 then
			CustomCircle(1000,1,2,myHero) -- RED thin
			if target ~= nil then
				if GetDistance(target) < 1000 then
					CustomCircle(100,8,3,target) -- BLUE target
				end
			end
		end
		if QRDY == 1 then
			CustomCircle(900,6,1,myHero) -- GREEN
			if target ~= nil then
				if GetDistance(target) < 900 then
					CustomCircle(100,4,2,target) -- RED target
				end
			end
		end
		if ERDY == 1 then
			CustomCircle(600,6,2,myHero) -- RED
			if target ~= nil then
				if GetDistance(target) < 600 then
					CustomCircle(100,8,3,target) -- RED target
				end
			end
		end
	end
end

SetTimerCallback("XerathRun")
print("\nVal's Xerath v"..version.."\n")