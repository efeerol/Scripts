require "Utils"

if myHero.name ~= "Sona" then return end
local target
local range = 900

SonaConfig = scriptConfig("NewkLand's Sona", "sonaq")
SonaConfig:addParam("q", "Q", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X")) --X
SonaConfig:permaShow("q")

function OnTick()

	target = GetWeakEnemy('MAGIC', 890)
	local minionCounter = 0
	
	if target ~= nil then

	local minions = GetEnemyMinions(MINION_SORT_HEALTH_ASC)
		for _, minion in pairs(minions) do
		if GetDistance(minion) < GetDistance(target) then
			minionCounter = minionCounter +1
			end
		end
	
	if SonaConfig.q and target and GetDistance(target) < 690 then
		if CanCastSpell("Q") then CastSpellTarget("Q",myHero)
		end
	end

	if SonaConfig.q and target and GetDistance(target) < 890 and minionCounter < 2 then
		if CanCastSpell("Q") then CastSpellTarget("Q",myHero)
		end
	end

	end
end

SetTimerCallback("OnTick")