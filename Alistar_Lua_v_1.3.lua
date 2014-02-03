--Lua's Little Cow Helper v1.3 (Simple version)

--CowButt: WQ+AA, if enemy is in 325 range it will cast Q only otherwise it kicks away the enemy ._.
--ButtSlap: W+AA
--Smart-Q: Auto-Q when enemy is in Q Range
--AutoSlap: When after casting spell, *Slap* the target. just like W+AA

--UseItems (In-menu Option): Use Items to Target with CowButt Combo

require "Utils"
require 'vals_lib'
local uiconfig = require 'uiconfig'
local target, target2, QRDY, WRDY--, ERDY, RRDY
local WQ, SLAP, StopMoving, LastAA = false, false, false, 0
local QMana, WMana, EMana, RMana = 70, 70, 40, 100
local AARange = myHero.range+(GetDistance(GetMinBBox(myHero)))

function OnTick()
	if LastAA ~= 0 and GetTickCount()-LastAA > 200 then
		LastAA = 0
		StopMoving = false
	end
	if myHero.dead == 0 then
		QMana = 60+(GetSpellLevel('Q')*10)
		WMana = 60+(GetSpellLevel('W')*10)
--		EMana = 30+(GetSpellLevel('E')*10)
		if myHero.SpellTimeQ > 0.9 and GetSpellLevel('Q') > 0 then QRDY = 1
		else QRDY = 0
		end
		if myHero.SpellTimeW > 0.9 and GetSpellLevel('W') > 0 then WRDY = 1
		else WRDY = 0
		end
--[[	if myHero.SpellTimeE > 0.9 and GetSpellLevel('E') > 0 then ERDY = 1
		else ERDY = 0
		end
		if myHero.SpellTimeR > 0.9 and GetSpellLevel('R') > 0 then RRDY = 1
		else RRDY = 0
		end ]]--
		CustomCircle(650, 3, 3, myHero)
		CustomCircle(350, 1, 5, myHero)
		target = GetWeakEnemy("MAGIC", 650, "NEARMOUSE")
		if target ~= nil then
			DrawCircleObject(target,150,4)
			if Alistar.WQ then
				if QRDY == 1 and WRDY == 1 and myHero.mana >= WMana+QMana and GetDistance(target, myHero) < 650 and GetDistance(target, myHero) > 325 then
					if Alistar.UseItems then UseAllItems(target) end
					CastSpellTarget('W',target)
					WQ = true
				elseif QRDY == 1 and myHero.mana >= QMana and GetDistance(target, myHero) < 325 then CastSpellTarget('Q',myHero)
				elseif not StopMoving then MoveToMouse() end
			end
			if Alistar.WAA and WRDY == 1 and myHero.mana >= WMana and GetDistance(target, myHero) < 650 then
				CastSpellTarget('W',target)
				AATarget(target)
				SLAP = true
			elseif Alistar.WAA and not SLAP and not StopMoving then MoveToMouse() end
		elseif (Alistar.WQ or Alistar.WAA) and not StopMoving then MoveToMouse()
		end
		target2 = GetWeakEnemy("MAGIC", 325)
		if target2 ~= nil and myHero.mana >= QMana and QRDY == 1 and Alistar.SmartQ then CastSpellTarget('Q',myHero)
		elseif Alistar.SmartQ and not StopMoving then MoveToMouse() end
	else
		WQ = false
		SLAP = false
	end
end

function OnProcessSpell(unit,spell)
	--Q: Pulverize
	--W: Headbutt
	--E: TriumphantRoar
	--R: FerociousHowl
	if unit.team == myHero.team and unit.name == myHero.name then
		if spell.name == 'Headbutt' then
			if myHero.mana >= QMana and QRDY == 1 then
				if WQ and target ~= nil and target.dead == 0 then
					CastSpellTarget('Q',myHero)
					AATarget(target)
				elseif Alistar.AutoSlap and not SLAP and spell.target ~= nil then AATarget(spell.target)
				elseif Alistar.WAA and SLAP then AATarget(target)
				end
			end
			WQ = false
			SLAP = false
		elseif spell.name == 'Pulverize' and Alistar.AutoSlap and target2 ~= nil then AATarget(target2) end
		if spell.name == 'AlistarBasicAttack' or spell.name == 'AlistarBasicAttack2' or spell.name == 'AlistarCritAttack' then LastAA = GetTickCount() end
	end
end

function AATarget(target)
	if target ~= nil then
		StopMoving = true
		AttackTarget(target)
	end
end

Alistar, alistar = uiconfig.add_menu('Alistar Config')
alistar.keydown('WQ', 'CowButt', Keys.T)
alistar.keydown('WAA', 'ButtSlap', Keys.C)
alistar.keydown('SmartQ', 'Stomp', Keys.N)
alistar.keytoggle('AutoSlap', 'Auto-Slap', Keys.F1, true)
alistar.checkbox('UseItems', 'Use Items to Target with CowButt Combo', true)
alistar.permashow('WQ')
alistar.permashow('WAA')
alistar.permashow('SmartQ')
alistar.permashow('AutoSlap')

SetTimerCallback('OnTick')