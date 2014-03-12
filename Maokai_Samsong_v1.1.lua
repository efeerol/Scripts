require 'Utils'
require 'winapi'
require 'SKeys'
require 'vals_lib'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local Q,W,E,R = 'Q','W','E','R'
local version = '1.0'

MaokaiConf, menu = uiconfig.add_menu('Maokai Hotkeys', 200)
        menu.keydown('Combo', 'Combo', Keys.X)
        menu.checkbutton('UseItems', 'UseItems', true)
		menu.checkbutton('Ignite', 'Ignite', true)
		EliseConfig:addParam('smite', 'SmiteSteal', SCRIPT_PARAM_ONOFF, true)
        menu.permashow('Combo')
		
		
function MaokaiRun()
target = GetWeakEnemy('PHYS',600,'NEARMOUSE')
targetIgnite = GetWeakEnemy('TRUE',600,'NEARMOUSE')
if MaokaiConf.combo then Combo() end
if MaokaiConfig.ignite then Ignite() end
if MaokaiConfig.smite then smitesteal() end
end

function Combo()
	if target ~= nil then
		if MaokaiConf.useItems then
			UseAllItems(target)
		end
		if CanCastSpell("W") and GetDistance(myHero, target) < 650 then
			CastSpellTarget("Q",target)
		end
		if CanCastSpell("Q") and GetDistance(myHero, target) < 600 then
			CastSpellXYZ("E",target.x,target.y,target.z)
		end
		if CanCastSpell("E") and GetDistance(myHero, target) < 1100 then
			CastSpellXYZ("E",target.x,target.y,target.z)
		end
	end
	if target == nil and MaokaiConf.Combo then
		MoveToMouse()
	elseif MaokaiConf.Combo then
		AttackTarget(target)
	end
end

function Ignite()
	local damage = (myHero.selflevel*20)+50
	if targetIgnite ~= nil and targetIgnite.health < damage then
		CastSummonerIgnite(targetIgnite) 
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

SetTimerCallback("MaokaiRun")