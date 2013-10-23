require "Utils"
require "basic_functions"
print=printtext
 
local myHero = GetSelf()	
local target
local script_loaded=1

function VayneRun()	
	target = GetWeakEnemy('PHYS',450)

	if VayneConfig.useItems then useItems() end
end

VayneConfig = scriptConfig("Vayne Config", "vayneconf")
VayneConfig:addParam("useItems", "Use Items", SCRIPT_PARAM_ONKEYTOGGLE, true, 115)
VayneConfig:permaShow("useItems")


function useItems()
		AttackRange = 550
	if target ~= nil then
		if GetDistance(myHero, target) < 400 then -- IR
			UseItemOnTarget(3144, target) -- Bilgewater Cutlass
		end		
		if GetDistance(myHero, target) < 700 then -- IR
			UseItemOnTarget(3146, target) -- Hextech Gunblade
		end		
		if GetDistance(myHero, target) < 500 then -- IR
			UseItemOnTarget(3153, target) -- Blade of the Ruined King
		end		
		if GetDistance(myHero, target) < 750 then -- IR
			UseItemOnTarget(3128, target) -- Deathfire Grasp
		end		
		if GetDistance(myHero, target) < AttackRange+10 then -- AR
			UseItemOnTarget(3184, target) -- Entropy
		end		
		if GetDistance(myHero, target) < 525 then -- IR
			UseItemOnTarget(3180, target) -- Odyn's Veil
		end		
		if GetDistance(myHero, target) < 400 then -- IR
			UseItemOnTarget(3143, target) -- Randuin's Omen
		end		
		if GetDistance(myHero, target) < AttackRange+10 then -- AR
			UseItemOnTarget(3074, target) -- Ravenous Hydra
		end		
		if GetDistance(myHero, target) < AttackRange+10 then -- AR
			UseItemOnTarget(3131, target) -- Sword of the Divine
		end		
		if GetDistance(myHero, target) < AttackRange+10 then -- AR
			UseItemOnTarget(3142, target) -- Youmuu's Ghostblade
		end
	end
end

function useItem(item)
	if GetInventoryItem(1) == item then 
		CastSpellTarget("1", target)
	elseif GetInventoryItem(2) == item then 
		CastSpellTarget("2", target)
	elseif GetInventoryItem(3) == item then 
		CastSpellTarget("3", target)
	elseif GetInventoryItem(4) == item then 
		CastSpellTarget("4", target)
	elseif GetInventoryItem(5) == item then 
		CastSpellTarget("5", target)
	elseif GetInventoryItem(6) == item then 
		CastSpellTarget("6", target)
	end
end

SetTimerCallback("VayneRun")