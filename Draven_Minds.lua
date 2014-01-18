local key = 0x5A -- Z k
local script_loaded=1

local active = false
local myHero = GetSelf()
require "utils"
	DravenConfig = scriptConfig('Draven Config', 'dravenconfig')
	DravenConfig:addParam('catchaxe', 'CatchAxe', SCRIPT_PARAM_ONKEYTOGGLE, true, key)
	DravenConfig:permaShow('catchaxe')

function OnCreateObj(obj)
	if obj ~= nil and DravenConfig.catchaxe then
		if string.find(obj.charName, "Draven_Q_reticle") then
			if GetDistance(obj,myHero)<600 then
				MoveToXYZ(obj.x,obj.y,obj.z)
			end
			if GetDistance(obj) < 75 then CastHotkey('AUTO 100,0 PATROLSTRAFE=350 STOPAFTER') end
		end
		if string.find(obj.charName, "Draven_Q_ReticleCatchSuccess") then
			local target = GetWeakEnemy('PHYS',600,'NEARMOUSE')
			if (target~=nil) then
				AttackTarget(target)
			else
				target = GetWeakEnemy('PHYS',900,'NEARMOUSE')
				if (target~=nil) then
					AttackTarget(target)
				end
			end
		end
	end
end
function sample_CallBackDraven()
Util__OnTick()
end

SetTimerCallback("sample_CallBackDraven")