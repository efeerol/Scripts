--[[
--IsInvulnerable function v1.1 by Lua
----IsInvulnerable(target)
----return
----0: is NOT Invulnerable
----1: is NOT Invulnerable but target has Time Reverse or Undying Rage with HIGH Hp (more then 20%)
----2: is NOT Invulnerable but target has Time Reverse or Undying Rage with LOW Hp (less then 20%)
----3: is Invulnerable

----Example:
local target = GetWeakEnemy('MAGIC',600)
if target ~= nil and IsInvulnerable(target) < 2 then CastSpellTarget('Q',target) end
]]--
require "Utils"

function IsInvulnerable(target)
	if target ~= nil and target.dead == 0 then
		if target.invulnerable == 1 then return 3
		else for i=1, objManager:GetMaxObjects(), 1 do
				local object = objManager:GetObject(i)
				if object ~= nil then
					if string.find(object.charName,"eyeforaneye") ~= nil and GetDistance(target,object) <= 15 then return 3
					elseif string.find(object.charName,"nickoftime") ~= nil and GetDistance(target,object) <= 15 then
						if (target.health/target.maxHealth*100) >= 20 then return 1
						else return 2 end
					elseif target.name == 'Tryndamere' and string.find(object.charName,"UndyingRage_buf") ~= nil and GetDistance(target,object) <= 15 then
						if (target.health/target.maxHealth*100) >= 20 then return 1
						else return 2 end
					end
				end
			end
		end
	end
	return 0
end