require 'Utils'

local version = '1.0'
local target
local targetIgnite
local minion
local striking = false
local t0_striking = 0

function NasusRun()
	target = GetWeakEnemy('PHYS',700)
	targetIgnite = GetWeakEnemy('TRUE',600)
	Util__OnTick()
	if NasusConfig.combo then combo() end
	if NasusConfig.ignite then ignite() end
	if NasusConfig.autoFarm then autoFarm() end
end

NasusConfig = scriptConfig("Nasus Config", "nasusconf")
NasusConfig:addParam("combo", "Combo (X)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
NasusConfig:addParam("autoFarm", "Auto Farm (Z)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
NasusConfig:addParam("autoStrike", "Siphoning Strike", SCRIPT_PARAM_ONKEYTOGGLE, true, 111)
NasusConfig:addParam("useItems", "Use Items", SCRIPT_PARAM_ONKEYTOGGLE, true, 112)
NasusConfig:addParam("ignite", "Auto Ignite", SCRIPT_PARAM_ONKEYTOGGLE, true, 113)
NasusConfig:permaShow("autoFarm")
NasusConfig:permaShow("combo")
NasusConfig:permaShow("autoStrike")
NasusConfig:permaShow("useItems")
NasusConfig:permaShow("ignite")

function combo()
	if target ~= nil then
		if NasusConfig.useItems then
			UseAllItems(target)
		end
		if CanCastSpell("W") and GetDistance(myHero, target) < 700 then
			CastSpellTarget("W",target)
		end
		if CanCastSpell("E") and GetDistance(myHero, target) < 650 then
			CastSpellXYZ("E",target.x,target.y,target.z)
		end
		if CanCastSpell("Q") and GetDistance(myHero, target) < 350 then
			CastSpellTarget("Q",myHero)
		end
		if CanCastSpell("R") and GetDistance(myHero, target) < 350 then
			CastSpellTarget("R",myHero)
		end
	end
	if target == nil and NasusConfig.combo then
		MoveToMouse()
	elseif NasusConfig.combo then
		AttackTarget(target)
	end
end

function ignite()
	local damage = (myHero.selflevel*20)+50
	if targetIgnite ~= nil and targetIgnite.health < damage then
		CastSummonerIgnite(targetIgnite) 
	end
end

function autoFarm()
	local strikeDamage = (GetSpellLevel("Q")*20)+10+myHero.baseDamage+myHero.addDamage
	local enemyMinion = GetLowestHealthEnemyMinion(700)
	if enemyMinion ~= nil and CanCastSpell("Q") and enemyMinion.health < strikeDamage then
		CastSpellTarget("Q",myHero)
	end
	if GetClock() > t0_striking and striking then
		striking = false
	end
	if enemyMinion ~= nil and enemyMinion.health < strikeDamage and striking then
		AttackTarget(enemyMinion)
		minion = enemyMinion
	else
		MoveToMouse()
		minion = nil
	end
end

function OnProcessSpell(unit,spell)
	if unit ~= nil and spell ~= nil and unit.charName == myHero.charName then
		if (spell.name == "NasusBasicAttack" or spell.name == "NasusBasicAttack2") and NasusConfig.autoStrike and CanUseSpell("Q") then
			CastSpellTarget("Q",myHero)
		end
		if spell.name == "SiphoningStrikeNew" then
			striking = true
			t0_striking = GetClock()+10000
		end
		if spell.name == "SiphoningStrikeAttack" then
			striking = false
		end
	end
end

function OnDraw()
	if myHero.dead == 0 then
		CustomCircle(700,6,3,myHero)
		if target ~= nil then
			CustomCircle(100,4,2,target)
		end
		if minion ~= nil then
			CustomCircle(100,4,5,minion)
		end
	end
end

SetTimerCallback("NasusRun")
print("\nChad's Nasus v"..version.."\n")