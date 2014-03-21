require 'Utils'
require 'winapi'
require 'SKeys'
require 'vals_lib'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local Q,W,E,R = 'Q','W','E','R'
local version = '1.6'
local RangeAttackQ,RangeAttackW = false,false

function Main()
	if IsLolActive() then
		target = GetWeakEnemy('PHYS',1100)
		targetaa = GetWeakEnemy('PHYS',700)
		GetCD()
		if EzrealConfig.useQ then SpellPred(Q,QRDY,myHero,target,1100,1.5,20,1) end
		if EzrealConfig.useW then SpellPred(W,WRDY,myHero,target,900,1.5,15,0) end
		if EzrealConfig.useE then SpellXYZ(E,ERDY,myHero,myHero,100,mousePos.x,mousePos.z) end
	end
end
	
	EzrealConfig, menu = uiconfig.add_menu('Ezreal Config', 200)
    menu.keydown('useQ', 'Use Q', Keys.Y)
	menu.keydown('useW', 'Use W', Keys.W)
	menu.keydown('useE', 'Use E', Keys.X)
	menu.checkbutton('useItems', 'useItems', true)
	menu.checkbutton('autoq', 'Auto-Q after AA', true)
	menu.checkbutton('autow', 'Auto-W after AA', true)
	menu.permashow('useQ')
	menu.permashow('useW')
	menu.permashow('useE')
	
function OnProcessSpell(unit,spell)
	if unit ~= nil and spell ~= nil and unit.charName == myHero.charName and spell.name == "EzrealBasicAttack" or spell.name == "EzrealBasicAttack2" or spell.name == "EzrealCritAttack" and targetaa ~= nil and spell.targetaa then
		if EzrealConfig.useItems and target~=nil then UseAllItems(target) end
		if target~=nil and QRDY == 1 and CreepBlock(GetFireahead(target,1.5,20)) == 0 and EzrealConfig.autoq then RangeAttackQ = true end
		if QRDY == 0 and WRDY == 1 and EzrealConfig.autow then RangeAttackW = true end
	end
end

function OnCreateObj(obj)
	if obj ~= nil and targetaa ~= nil and obj.charName == 'Ezreal_basicattack_mis.troy' and GetDistance(obj) < 250 then
		if RangeAttackQ then
			if EzrealConfig.useItems then UseAllItems(target) end
			SpellPred(Q,QRDY,myHero,target,1100,1.5,20,1)
			RangeAttackQ = false
		end
		if RangeAttackW then	
			if EzrealConfig.useItems then UseAllItems(target) end
			SpellPred(W,WRDY,myHero,target,900,1.5,15,0)
			RangeAttackW = false
		end
	end
end

function OnDraw()
	if QRDY == 1 then CustomCircle(1100,1,2,myHero)
	else CustomCircle(1100,1,3,myHero) end
	if target ~= nil then CustomCircle(100,10,2,target) end
end

SetTimerCallback('Main')
