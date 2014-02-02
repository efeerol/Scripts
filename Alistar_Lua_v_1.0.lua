--Lua's Little Cow Helper v1.0 (Simple version)

--CowButt: WQ+AA and If you have item like deathfire, it will use it to target and(2) if enemy is in 325 range, it will cast Q only otherwise it kicks away the enemy ._.
--ButtSlap: W+AA
--Stomp: Auto-Q when enemy is in Q Range
--Auto-Slap: When after casting spell, *Slap* the target. just like W+AA

require "Utils"
local uiconfig = require 'uiconfig'
local target, target2, slaptarget, QRDY, WRDY--, ERDY, RRDY
local WQ, SLAP = false, false
local QMana, WMana, EMana, RMana = 70, 70, 40, 100
local AARange = myHero.range+(GetDistance(GetMinBBox(myHero)))

function OnTick()
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
			if Alistar.WQ then
				if QRDY == 1 and WRDY == 1 and myHero.mana >= WMana+QMana and GetDistance(target, myHero) < 650 and GetDistance(target, myHero) > 325 then
					UseAllItems(target)
					CastSpellTarget('W',target)
					WQ = true
				elseif QRDY == 1 and myHero.mana >= QMana and GetDistance(target, myHero) < 325 then CastSpellTarget('Q',myHero) end
			end
			if Alistar.WAA and WRDY == 1 and myHero.mana >= WMana and GetDistance(target, myHero) < 650 then
				CastSpellTarget('W',target)
				AttackTarget(target)
				SLAP = true
			end
		end
		target2 = GetWeakEnemy("MAGIC", 325)
		if target2 ~= nil and myHero.mana >= QMana and QRDY == 1 and Alistar.SmartQ then CastSpellTarget('Q',myHero) end
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
					AttackTarget(target)
				elseif Alistar.AutoSlap and not SLAP and spell.target ~= nil then AttackTarget(spell.target)
				end
			end
			WQ = false
			SLAP = false
		elseif spell.name == 'Pulverize' and Alistar.AutoSlap then
			AARange = myHero.range+(GetDistance(GetMinBBox(myHero)))
			slaptarget = GetWeakEnemy("PHYS", AARange)
			if slaptarget ~= nil then AttackTarget(slaptarget) end
		end
	end
end

Alistar, alistar = uiconfig.add_menu('Alistar Config')
alistar.keydown('WQ', 'CowButt', Keys.T)
alistar.keydown('WAA', 'ButtSlap', Keys.C)
alistar.keydown('SmartQ', 'Stomp', Keys.N)
alistar.keytoggle('AutoSlap', 'Auto-Slap', Keys.F1, true)
alistar.permashow('WQ')
alistar.permashow('WAA')
alistar.permashow('SmartQ')
alistar.permashow('AutoSlap')

SetTimerCallback('OnTick')