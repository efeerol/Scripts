--[[
Lua's Anti-Lantern
			v1.3.2
]]--
require 'Utils'
local warding = 0
local lastLantern = nil
local delay = 0
local random = {x = 0, z = 0}

function onTick()
	if warding ~= 0 and lastLantern ~= nil and GetTickCount() - warding > delay and GetDistance(myHero,lastLantern) <= 650 and not FindWards(lastLantern) and NearEnemys(lastLantern) ~= nil then
		local NearEnemy = NearEnemys(lastLantern)
		if (NearEnemy.health/NearEnemy.maxHealth*100) < 50 then
			if GetWardSlot(3362) ~= nil then
				CastSpellXYZ(GetWardSlot(3362), random.x, 0, random.z)
			elseif GetWardSlot(2043) ~= nil then
				CastSpellXYZ(GetWardSlot(2043), random.x, 0, random.z)
			else
				print('no wards ._.')
			end
		end
		lastLantern = nil
		warding = 0
	elseif warding ~= 0 and lastLantern ~= nil and GetTickCount() - warding > 4000 then
		lastLantern = nil
		warding = 0
	end
end

function OnCreateObj(object)
	if object.charName == 'ThreshLantern' and object.name == 'ThreshLantern' and object.team ~= myHero.team then
		warding = GetTickCount()
		lastLantern = object
		random.x = object.x + math.random(4,24)
		random.z = object.z + math.random(4,24)
		delay = math.random(250,666)
	end
end

function NearEnemys(lantern)
    for i = 1, objManager:GetMaxHeroes() do
	local enemy = objManager:GetHero(i)
		if enemy ~= nil and enemy.team ~= myHero.team and GetDistance(enemy,lantern) <= 500 then
			for i = 1, objManager:GetMaxHeroes() do
			local enemyThresh = objManager:GetHero(i)
				if enemyThresh.name == 'Thresh' and enemyThresh.team ~= myHero.team and (GetDistance(enemyThresh,lantern) >= 350 or enemyThresh.visible == 0) then
					return enemy
				end
			end
		end
    end
	return nil
end

function FindWards(lantern)
    for i=1, objManager:GetMaxObjects(), 1 do
        local object = objManager:GetObject(i)
		if object ~= nil and object.team == myHero.team and (object.charName == 'VisionWard' or object.name == 'RelicVisionLantern') and GetDistance(lantern,object) <= 60 then
			return true
		end
    end
	return false
end

function GetWardSlot(item) -- Thanks to fter44
	for i=1,7 do
		if GetInventoryItem(i) == item and myHero["SpellTime"..i] >= 1 then
			return i
		end
	end
	return nil
end

SetTimerCallback('onTick')