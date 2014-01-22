--[[SamSong's OP Annie--]]
 
require 'Utils'
require 'spell_damage'
require 'winapi'
require 'SKeys'
local send = require 'SendInputScheduled'

local version = '1.0'
local target
local targetIgnite
local targetHarass
local Q,W,E,R = 'Q','W','E','R'

function AnnieRun()
    target = GetWeakEnemy('PHYS',700)
    targetIgnite = GetWeakEnemy('TRUE',600)
	Util__OnTick()
	if AnnieConfig.combo then combo() end
	if AnnieConfig.ignite then ignite() end
end
local Summoners =
        {
                Ignite = {Key = nil, Name = 'SummonerDot'},
                Exhaust = {Key = nil, Name = 'SummonerExhaust'},
                Heal = {Key = nil, Name = 'SummonerHeal'},
                Clarity = {Key = nil, Name = 'SummonerMana'},
                Barrier = {Key = nil, Name = 'SummonerBarrier'},
                Clairvoyance = {Key = nil, Name = 'SummonerClairvoyance'},
                Cleanse = {Key = nil, Name = 'SummonerBoost'}
        }
		
AnnieConfig = scriptConfig("Annie Config", "Annieconfg")
AnnieConfig:addParam("combo", "Combo (X)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
AnnieConfig:addParam("useItems", "Use Items", SCRIPT_PARAM_ONKEYTOGGLE, true, 112)
AnnieConfig:addParam("ignite", "Auto Ignite", SCRIPT_PARAM_ONKEYTOGGLE, true, 113)
 
AnnieConfig:permaShow("combo")
AnnieConfig:permaShow("useItems")
AnnieConfig:permaShow("ignite")

function combo()
	if target ~= nil then
		if AnnieConfig.useItems then
			UseAllItems(target)
		end
		if CanCastSpell("Q") and GetDistance(myHero, target) < 625 then
			CastSpellTarget("Q",target)
		end
		if CanCastSpell("W") and GetDistance(myHero, target) < 620 then
			CastSpellTarget("W",myHero)
		end
		if CanCastSpell("R") and GetDistance(myHero, target) < 600 then
			CastSpellXYZ("R",target.x,target.y,target.z)
		end
	end
	if target == nil and AnnieConfig.combo then
		MoveToMouse()
	elseif AnnieConfig.combo then
		AttackTarget(target)
	end
end

function ignite()
	local damage = (myHero.selflevel*20)+50
	if targetIgnite ~= nil and targetIgnite.health < damage then
		CastSummonerIgnite(targetIgnite) 
	end
end
		
SetTimerCallback("AnnieRun")