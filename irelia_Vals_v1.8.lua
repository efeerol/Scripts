require 'Utils'
require 'winapi'
require 'SKeys'
require 'vals_lib'
require 'runrunrun'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local Q,W,E,R = 'Q','W','E','R'
local version = '1.8'
local Minions = {}
local SORT_CUSTOM = function(a, b) return a.maxHealth and b.maxHealth and a.maxHealth < b.maxHealth end

	IreliaConfig, menu = uiconfig.add_menu('Irelia Hotkeys', 200)
	menu.keydown('Combo', 'Combo', Keys.X)
	menu.keydown('Ultimate', 'Ultimate', Keys.Y)
	menu.keytoggle('AutoFarm', 'AutoFarm', Keys.F1, false)
	menu.checkbutton('AutoW', 'AutoW', true)
	menu.checkbutton('AutoE', 'AutoE', true)
	menu.checkbutton('killsteal', 'killsteal', true)
	menu.checkbutton('useItems', 'useItems', true)
	menu.checkbutton('DrawCircles', 'DrawCircles', true)
	menu.checkbutton('MouseMove', 'MouseMove', true)
	menu.permashow('Combo')
	menu.permashow('Ultimate')
	menu.permashow('AutoFarm')
	menu.permashow('killsteal')

function Main()
	if IsLolActive() then
		target = GetWeakEnemy('PHYS',650)
		target2 = GetWeakEnemy('PHYS',AArange+50)
		Minions = GetEnemyMinions(SORT_CUSTOM)
		if myHero.SpellTimeR<-10 then Ziel = nil end
		GetCD()
		if IreliaConfig.Combo then Combo() end
		if IreliaConfig.AutoFarm then AutoFarm() end
		if IreliaConfig.killsteal then killsteal() end
		UltimateAlwaysOn()
		if IreliaConfig.Ultimate then Once_Ultimate() end
	end
end

function Combo()
	if target2~=nil then 
		if IreliaConfig.useItems then UseAllItems(target2) end
		AttackTarget(target2)
	end
	if target~=nil then
		if GetDistance(target)>AArange and QRDY==1 then CastSpellTarget("Q", target) end
		if GetDistance(target)<425 and ERDY==1 and IreliaConfig.AutoE and myHero.health<target.health then CastSpellTarget("E", target) end
	end
	if target~=nil and IreliaConfig.MouseMove then MoveTarget(target)
	else MoveMouse() end
end

function Ultimate()
	local target3 = GetWeakEnemy('PHYS',1000)
	if target3~=nil then Ziel = target3 end
	if Ziel == nil then
		return true
	end
end

function Once_Ultimate()
    run_many_reset(1, Ultimate)
end

function UltimateAlwaysOn()
	if Ziel~=nil then SpellPred(R,RRDY,myHero,Ziel,900,1.6,20) end
end

function killsteal()
	if target ~= nil then
		local effhealth = target.health*(1+(((target.armor*myHero.armorPenPercent)-myHero.armorPen)/100))
		local xQ = (((30*myHero.SpellLevelQ)-10)+myHero.baseDamage+myHero.addDamage)*QRDY
		if target.health < xQ*QRDY and GetDistance(myHero, target)<650 and not DomCap() then CastSpellTarget('Q', target) end
	end
end

function AutoFarm()
	for i, minion in pairs(Minions) do
		if minion~=nil and minion.visible==1 and minion.dead==0 then
			local effhealth = minion.health*(1+(((minion.armor*myHero.armorPenPercent)-myHero.armorPen)/100))
			local xQ = (((30*myHero.SpellLevelQ)-10)+myHero.baseDamage+myHero.addDamage)*QRDY
			if effhealth<xQ then CustomCircle(75,1,5,minion)
				if GetDistance(minion) < 650 and not DomCap() then CastSpellTarget("Q",minion) end
			end
		end
	end
end

function OnDraw()
	if myHero.dead==0 and IreliaConfig.DrawCircles then CustomCircle(650,1,4,myHero) end
	if target ~= nil then CustomCircle(100,4,2,target) end	
end

function DomCap()
	if IsBuffed(myHero,'OdinCaptureBeam') or IsBuffed(myHero,'TeleportHome') then
		return true
	end
end

function OnProcessSpell(unit,spell)
	if unit ~= nil and spell ~= nil and unit.charName == myHero.charName and target2~=nil then
		if spell.name == "IreliaBasicAttack" or spell.name == "IreliaBasicAttack2" or spell.name == "IreliaCritAttack" and spell.target2 and IreliaConfig.AutoW and WRDY==1 then CastSpellTarget("W", target2) end
	end
end

SetTimerCallback('Main')