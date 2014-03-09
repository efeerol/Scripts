require 'Utils'
require 'winapi'
require 'SKeys'
require 'runrunrun'
require 'vals_lib'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local Q,W,E,R = 'Q','W','E','R'
local version = '1.4'
local Qattack = false
local attacked = 0

function Main()
	target = GetWeakEnemy('PHYS',600,"NEARMOUSE")
	targetaa = GetWeakEnemy('PHYS',AArange+50)
	GetCD()
	if FioraConfig.Combo then Combo() end
	if FioraConfig.Killsteal then Killsteal() end
end
	
	FioraConfig, menu = uiconfig.add_menu('Fiora Config', 200)
    menu.keydown('Combo', 'Combo', Keys.X)
	menu.checkbutton('useItems', 'useItems', true)
	menu.checkbutton('Killsteal', 'Killsteal', true)
	menu.checkbutton('AutoW', 'Auto Shield', true)
	menu.permashow('Combo')
	
function QQ()
	CastSpellTarget('Q', target)
end

function OnProcessSpell(unit,spell)
	if unit~=nil and spell~=nil and unit.team~=myHero.team and (string.find(spell.name,"Attack")~=nil or string.find(spell.name,"attack")~=nil) and spell.target~=nil and spell.target.name == myHero.name and FioraConfig.AutoW and WRDY==1 then CastSpellTarget("W", myHero) end
	if unit~=nil and spell~=nil and unit.charName==myHero.charName and spell.name == "FioraQ" and attacked == 0 then attacked = GetTickCount() end
end

function OnCreateObj(obj)
	if obj ~= nil and obj.charName == 'FioraQLunge_tar.troy' and GetDistance(obj)<100 and FioraConfig.Combo then Qattack = true end
end

function Combo()
	if target ~= nil then
		if FioraConfig.useItems and (QRDY==1 or GetDistance(target)>AArange+100) then UseAllItems(target) end	
		if QRDY==1 and Qattack==false then
			if ERDY==1 then CastSpellTarget("E",myHero) end
			CastSpellTarget('Q',target)
		end
		if (QRDY==1 and GetDistance(target)>AArange+100 and attacked~=0 and GetTickCount()>attacked+10000) or (QRDY==1 and Qattack and attacked~=0 and GetTickCount()>attacked+3500) then
			run_every(1,QQ)
			Qattack = false
			attacked = 0
		end
		AttackTarget(target)
	end
	if targetaa~=nil then
		if ERDY==1 then CastSpellTarget("E", targetaa) end
	end
	if targetaa==nil then MoveMouse() end
end

function Killsteal()
	if target~=nil and ValidTarget(target,600) then
		local effhealth = target.health*(1+(((target.armor*myHero.armorPenPercent)-myHero.armorPen)/100))
		local xQ = ((15+(myHero.SpellLevelQ*25)+(myHero.addDamage*.6))*QRDY)
		if QRDY==1 and Qattack==false and (effhealth<xQ*2 or effhealth<xQ) then CastSpellTarget("Q", target) end
		if QRDY==1 and Qattack and effhealth<xQ then
			CastSpellTarget('Q', target)
			Qattack = false
		end
	end
end

function OnDraw()
	if myHero.dead == 0 then CustomCircle(600,3,3,myHero)
	CustomCircle(AArange,3,3,myHero)
		if target ~= nil then CustomCircle(100,4,2,target) end
	end
	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) then
			local effhealth = enemy.health*(1+(((enemy.armor*myHero.armorPenPercent)-myHero.armorPen)/100))
			local xQ = ((15+(myHero.SpellLevelQ*25)+(myHero.addDamage*.6))*QRDY)
			if QRDY==1 and Qattack==false then
				if effhealth<xQ*2 then DrawTextObject('QQ', enemy, Color.Yellow) end
				if effhealth<xQ then DrawTextObject('Q', enemy, Color.Yellow) end
			end
			if QRDY==1 and Qattack and effhealth<xQ then DrawTextObject('Q', enemy, Color.Yellow) end
		end
	end
end

SetTimerCallback("Main")