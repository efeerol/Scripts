local key = 90
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
			if GetDistance(obj,myHero)<200 then
				MoveToXYZ(obj.x,obj.y,obj.z)
			end
			if GetDistance(obj,myHero)>200 and GetDistance(obj,myHero)<700 then
				--CastSpellTarget('W',myHero)
				MoveToXYZ(obj.x,obj.y,obj.z)
			end
			if GetDistance(obj) < 40 then StopMove() end
		end
		if string.find(obj.charName, "Draven_Q_ReticleCatchSuccess") then
			local target = GetWeakEnemy('PHYS',600,'NEARMOUSE')
			if (target~=nil) then
				AttackTarget(target)
			else
				target = GetWeakEnemy('PHYS',900,'NEARMOUSE')
				if (target~=nil) and GetDistance(target,myHero)>400 then
					--CastSpellTarget('W',myHero)
					AttackTarget(target)
				end
			end
		end
	end
end
function sample_CallBackDraven()
end

SetTimerCallback("sample_CallBackDraven")