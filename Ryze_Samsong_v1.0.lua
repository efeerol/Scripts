--[[SamSong's OP Ryze--]]
 
require 'Utils'
require 'spell_damage'
require 'winapi'
require 'SKeys'
local send = require 'SendInputScheduled'

local version = '1.0'
local target
local targetIgnite
local Q,W,E,R = 'Q','W','E','R'

function RyzeRun()
    target = GetWeakEnemy('PHYS',700)
    targetIgnite = GetWeakEnemy('TRUE',600)
	Util__OnTick()
	if RyzeConfig.combo then combo() end
	if RyzeConfig.chase then chase() end
	if RyzeConfig.ignite then ignite() end
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
		
RyzeConfig = scriptConfig("Ryze Config", "Ryzeconfg")
RyzeConfig:addParam("combo", "Combo (X)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
RyzeConfig:addParam("chase", "Chase Combo (C)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
RyzeConfig:addParam("useItems", "Use Items", SCRIPT_PARAM_ONKEYTOGGLE, true, 112)
RyzeConfig:addParam("ignite", "Auto Ignite", SCRIPT_PARAM_ONKEYTOGGLE, true, 113)
 
RyzeConfig:permaShow("combo")
RyzeConfig:permaShow("chase")
RyzeConfig:permaShow("useItems")
RyzeConfig:permaShow("ignite")

function combo()
	if target ~= nil then
		if RyzeConfig.useItems then
			UseAllItems(target)
		end
		if CanCastSpell("Q") and GetDistance(myHero, target) < 600 then
			CastSpellTarget("Q",target)
		end
		if CanCastSpell("R") and GetDistance(myHero, target) < 600 then
			CastSpellTarget("R",myHero)
		end
		if CanCastSpell("W") and GetDistance(myHero, target) < 600 then
			CastSpellTarget("W",target)
		end
		if CanCastSpell("E") and GetDistance(myHero, target) < 600 then
			CastSpellTarget("E",target)
		end
	end
	if target == nil and RyzeConfig.combo then
		MoveToMouse()
	elseif RyzeConfig.combo then
		AttackTarget(target)
	end
end

function chase()
	if target ~= nil then
		if RyzeConfig.useItems then
			UseAllItems(target)
		end
		if CanCastSpell("W") and GetDistance(myHero, target) < 600 then
			CastSpellTarget("W",target)
		end
		if CanCastSpell("Q") and GetDistance(myHero, target) < 600 then
			CastSpellTarget("Q",target)
		end
		if CanCastSpell("R") and GetDistance(myHero, target) < 600 then
			CastSpellTarget("R",myHero)
		end
		if CanCastSpell("E") and GetDistance(myHero, target) < 600 then
			CastSpellTarget("E",target)
		end
	end
	if target == nil and RyzeConfig.chase then
		MoveToMouse()
	elseif RyzeConfig.chase then
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
		
 
SetTimerCallback("RyzeRun")