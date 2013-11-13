--[[SamSong's OP Renekton--]]
 
require 'Utils'
require 'spell_damage'
require 'winapi'
require 'SKeys'
local send = require 'SendInputScheduled'

local version = '1.0'
local target
local targetIgnite
local Q,W,E,R = 'Q','W','E','R'

function RenektonRun()
    target = GetWeakEnemy('PHYS',700)
    targetIgnite = GetWeakEnemy('TRUE',600)
	Util__OnTick()
	if RenektonConfig.combo then combo() end
	if RenektonConfig.ignite then ignite() end
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
		
RenektonConfig = scriptConfig("Renekton Config", "Renektonconfg")
RenektonConfig:addParam("combo", "Combo (X)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
RenektonConfig:addParam("useItems", "Use Items", SCRIPT_PARAM_ONKEYTOGGLE, true, 112)
RenektonConfig:addParam("ignite", "Auto Ignite", SCRIPT_PARAM_ONKEYTOGGLE, true, 113)
 
RenektonConfig:permaShow("combo")
RenektonConfig:permaShow("useItems")
RenektonConfig:permaShow("ignite")

function combo()
	if target ~= nil then
		if RenektonConfig.useItems then
			UseAllItems(target)
		end
		if CanCastSpell("Q") and GetDistance(myHero, target) < 700 then
			CastSpellTarget("Q",target)
		end
		if CanCastSpell("W") and GetDistance(myHero, target) < 100 then
			CastSpellTarget("W",myHero)
		end
		if CanCastSpell("E") and GetDistance(myHero, target) < 650 then
			CastSpellXYZ("E",target.x,target.y,target.z)
		end
		if CanCastSpell("R") and GetDistance(myHero, target) < 350 then
			CastSpellTarget("R",myHero)
		end
	end
	if target == nil and RenektonConfig.combo then
		MoveToMouse()
	elseif RenektonConfig.combo then
		AttackTarget(target)
	end
end

function ignite()
	local damage = (myHero.selflevel*20)+50
	if targetIgnite ~= nil and targetIgnite.health < damage then
		CastSummonerIgnite(targetIgnite) 
	end
end

function autoult()
if myHero.health < myHero.maxHealth*(15 / 100) then
	CastSpellTarget("R",myHero)
	end
end
		
 
SetTimerCallback("RenektonRun")