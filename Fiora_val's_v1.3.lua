require "Utils"
require 'spell_damage'
local uiconfig = require 'uiconfig'

local version = '1.3'
local target
local target2
local target3
local t0_attacking = 0
local t1_attacking = 0
local attackAnimationDuration = 3500
local attackAnimationDuration2 = 500
local Qattack = false

function FioraRun()
	target = GetWeakEnemy('PHYS',600,"NEARMOUSE")
	target2 = GetWeakEnemy('TRUE',600)
	AArange = (myHero.range+(GetDistance(GetMinBBox(myHero), GetMaxBBox(myHero))/2))
	targetaa = GetWeakEnemy('PHYS',AArange)
	
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
	
	if FioraConfig.Combo then Combo() end
	if FioraConfig.ignite then ignite() end
	if FioraConfig.smite then smitesteal() end
	if FioraConfig.Killsteal then Killsteal() end
end

    FioraConfig, menu = uiconfig.add_menu('Val Fiora Config', 16)
    menu.keydown('Combo', 'Combo', Keys.X)
	menu.keytoggle('ignite', 'Auto-Ignite', Keys.NumPad1, true)
    menu.keytoggle('smite', 'Smitesteal', Keys.NumPad2, false)
    menu.keytoggle('Killsteal', 'Killsteal', Keys.NumPad3, true)
    
    menu.checkbutton('AutoW', 'Auto Shield', true)
    menu.checkbutton('useItems', 'Auto-Items', true)
	
	menu.permashow('Combo')
	menu.permashow('ignite')  
	menu.permashow('smite')
	menu.permashow('Killsteal')
	menu.permashow('AutoW')
	menu.permashow('useItems')
	
function OnProcessSpell(unit,spell)
 	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 then
			if unit ~= nil and spell ~= nil and unit.name == enemy.name then
				if spell.target ~= nil and spell.target.name == myHero.name and FioraConfig.AutoW then
					if (string.find(spell.name,"Attack") ~= nil or string.find(spell.name,"attack") ~= nil) and WRDY == 1 then
						CastSpellTarget("W", myHero)
					end
				end
			end
		end
	end
	if unit ~= nil and spell ~= nil and unit.charName == myHero.charName then
		if spell.name == "FioraQ" then
			t0_attacking = GetClock()+attackAnimationDuration
			t1_attacking = GetClock()+attackAnimationDuration2
		end
	end
end

function OnCreateObj(obj)
	if obj ~= nil then
		if string.find(obj.charName, "FioraQLunge") ~= nil and GetDistance(obj) < 100 and FioraConfig.Combo then
			Qattack = true
		end
	end
end

function Combo()
	if target ~= nil then
		if FioraConfig.useItems and (QRDY == 1 or GetDistance(target) > AArange) then
			UseAllItems(target)
		end	
		if QRDY == 1 and Qattack == false then
			if ERDY == 1 then
				CastSpellTarget("E", myHero)
			end
			CastSpellTarget("Q", target)
		end
		if (GetDistance(target) > AArange and GetClock() > t1_attacking) or (QRDY == 1 and Qattack == true and GetClock() > t0_attacking) then
			CastSpellTarget("Q", target)
			Qattack = false
		end
		AttackTarget(target)
	end
	if targetaa ~= nil then
		if ERDY == 1 then
			CastSpellTarget("E", targetaa)
		end
	end
	if targetaa == nil then	
		MoveToMouse()
	end
end

function Killsteal()
	if target ~= nil then
		local Q = getDmg("Q",target,myHero)
		local Q2 = getDmg("Q",target,myHero)*2
		if QRDY == 1 and Qattack == false then
			if target.health < Q2 then
				CastSpellTarget("Q", target)
			end
			if target.health < Q then
				CastSpellTarget("Q", target)
			end
		end
		if QRDY == 1 and Qattack == true then
			if target.health < Q then
				CastSpellTarget("Q", target)
				Qattack = false
			end
		end
	end
end

function smitesteal()
	if myHero.SummonerD == "SummonerSmite" then
		CastHotkey("AUTO 100,0 SPELLD:SMITESTEAL RANGE=600 TRUE COOLDOWN")
		return
	end
	if myHero.SummonerF == "SummonerSmite" then
		CastHotkey("AUTO 100,0 SPELLF:SMITESTEAL RANGE=600 TRUE COOLDOWN")
		return
	end
end

function ignite()
	local damage = (myHero.selflevel*20)+50
	if target2 ~= nil then
		if myHero.SummonerD == "SummonerDot" then
			if target2.health < damage then
				CastSpellTarget("D",target2)
			end
		end
		if myHero.SummonerF == "SummonerDot" then
			if target2.health < damage then
				CastSpellTarget("F",target2)
			end
		end
	end
end

function OnDraw()
	if myHero.dead == 0 then
		CustomCircle(600,3,3,myHero)
		if target ~= nil then
			CustomCircle(100,4,2,target)
		end
	end
	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) then
		local Q = getDmg("Q",enemy,myHero)
		local Q2 = getDmg("Q",enemy,myHero)*2
			if enemy.health < Q2 then
				DrawTextObject("QQ", enemy, Color.Yellow)
			end
			if enemy.health < Q then
				DrawTextObject("Q", enemy, Color.Yellow)
			end
		end
	end
end

SetTimerCallback("FioraRun")
print("\nVal's Fiora v"..version.."\n")