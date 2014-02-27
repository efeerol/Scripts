--[[
--IsInvulnerable function v1.6 by Lua
----IsInvulnerable(target)
	
----return (as table)
----.status	(current status)
--------0: is NOT Invulnerable
--------1: is NOT Invulnerable but target has Time Reverse or Undying Rage or Guardian Angel or Egg(!) or Aatrox, Zac's passive
--------2: is NOT Invulnerable but target has Spell Shield, such as Sivir Shield or Morgana Shield or Banshee
--------3: is Invulnerable by Kayle or Poppy (If Poppy Diplomatic Immunity on myHero, will returns NOT Invulnerable)
----.name	(Spell or Item name)
----.amount	(Max amount of shield)
----.type	(Type (NONE, ALL, MAGIC, PHYS, SPELL, REVIVE))

----Example:
local target = GetWeakEnemy('MAGIC',600)
if target ~= nil then
	local enemy = IsInvulnerable(target)
	if myHero.SpellTimeQ > 0 and myHero.SpellLevelQ > 0 and enemy.status == 0 then
		CastSpellTarget('Q',target)
	end
end
]]--
require "Utils"
local egg = {
allied = {time = 0},
enemy = {time = 0}
}
local zac = {
allied = {time = 0},
enemy = {time = 0}
}
local aatrox = {
allied = {time = 0},
enemy = {time = 0}
}

function IsInvulnerable(target)
	if target ~= nil and target.dead == 0 then
		if target.invulnerable == 1 then return {status = 3, name = nil, amount = nil, type = nil}
		else for i=1, objManager:GetMaxObjects(), 1 do
				local object = objManager:GetObject(i)
				if object ~= nil then
					if string.find(object.charName,"eyeforaneye") ~= nil and GetDistance(target,object) <= 20 then return {status = 3, name = 'Intervention', amount = 0, type = 'ALL'}
					elseif string.find(object.charName,"nickoftime") ~= nil and GetDistance(target,object) <= 20 then return {status = 1, name = 'Chrono Shift', amount = 0, type = 'REVIVE'}
					elseif target.name == 'Poppy' and string.find(object.charName,"DiplomaticImmunity_tar") ~= nil and GetDistance(myHero,object) > 20 then
						for i=1, objManager:GetMaxObjects(), 1 do
							local diObject = objManager:GetObject(i)
							if diObject ~= nil and string.find(diObject.charName,"DiplomaticImmunity_buf") ~= nil and GetDistance(target,diObject) <= 20 then return {status = 3, name = 'Diplomatic Immunity', amount = 0, type = 'ALL'} end
						end
					elseif target.name == 'Vladimir' and string.find(object.charName,"VladSanguinePool_buf") ~= nil and GetDistance(myHero,object) <= 20 then return {status = 3, name = 'Sanguine Pool', amount = 0, type = 'ALL'}
--					elseif string.find(object.charName,"Summoner_Barrier") ~= nil and GetDistance(target,object) <= 20 then return 2--, 'NONE'
					elseif string.find(object.charName,"Global_Spellimmunity") ~= nil or string.find(object.charName,"Morgana_Blackthorn_Blackshield") ~= nil and GetDistance(target,object) <= 20 then
						local amount = 0
						for i= 1,objManager:GetMaxHeroes(),1 do
							local hero=objManager:GetHero(i)
							if hero.team == target.team and hero.name == 'Morgana' then
								amount = 30+(65*hero.SpellLevelE)+(hero.ap*0.7)
								return {status = 2, name = 'Black Shield', amount = amount, type = 'MAGIC'}
							end
						end
					elseif string.find(object.charName,"bansheesveil_buf") ~= nil and GetDistance(target,object) <= 20 then return {status = 2, name = 'Banshees Veil', amount = 0, type = 'SPELL'}
					elseif target.name == 'Sivir' and string.find(object.charName,"Sivir_Base_E_shield") ~= nil and GetDistance(target,object) <= 20 then return {status = 2, name = 'Spell Shield', amount = 0, type = 'SPELL'}
					elseif target.name == 'Nocturne' and string.find(object.charName,"nocturne_shroudofDarkness_shield") ~= nil and GetDistance(target,object) <= 20 then return {status = 2, name = 'Shroud of Darkness', amount = 0, type = 'SPELL'}
					elseif target.name == 'Tryndamere' and string.find(object.charName,"UndyingRage_buf") ~= nil and GetDistance(target,object) <= 20 then return {status = 1, name = 'Undying Rage', amount = 0, type = 'NONE'}
					elseif string.find(object.charName,"rebirthready") ~= nil and GetDistance(target,object) <= 20 then return {status = 1, name = 'Guardian Angel', amount = 0, type = 'REVIVE'}
					elseif target.name == 'Anivia' then
						if target.team == myHero.team then
							if GetTickCount()-egg.allied.time > 240000 or egg.allied.time == 0 then return {status = 1, name = 'Egg', amount = 0, type = 'REVIVE'}
							else return {status = 0, name = nil, amount = nil, type = nil} end
						else
							if GetTickCount()-egg.enemy.time > 240000 or egg.enemy.time == 0 then return {status = 1, name = 'Egg', amount = 0, type = 'REVIVE'}
							else return {status = 0, name = nil, amount = nil, type = nil} end
						end
					elseif target.name == 'Aatrox' then
						if target.team == myHero.team then
							if GetTickCount()-aatrox.allied.time > 225000 or aatrox.allied.time == 0 then return {status = 1, name = 'Aatrox', amount = 0, type = 'REVIVE'}
							else return {status = 0, name = nil, amount = nil, type = nil}
							end
						elseif target.team ~= myHero.team then
							if GetTickCount()-aatrox.enemy.time > 225000 or aatrox.enemy.time == 0 then return {status = 1, name = 'Aatrox', amount = 0, type = 'REVIVE'}
							else return {status = 0, name = nil, amount = nil, type = nil}
							end
						end
					elseif target.name == 'Zac' then
						if target.team == myHero.team then
							if GetTickCount()-zac.allied.time > 300000 or zac.allied.time == 0 then return {status = 1, name = 'Zac', amount = 0, type = 'REVIVE'}
							else return {status = 0, name = nil, amount = nil, type = nil}
							end
						elseif target.team ~= myHero.team then
							if GetTickCount()-zac.enemy > 300000 or zac.enemy.time == 0 then return {status = 1, name = 'Zac', amount = 0, type = 'REVIVE'}
							else return {status = 0, name = nil, amount = nil, type = nil}
							end
						end
--					elseif string.find(object.charName,"GLOBAL_Item_FoM_Shield") ~= nil and GetDistance(target,object) <= 30 then return 2--, 'NONE'
--					elseif target.name == 'Nautilus' and string.find(object.charName,"Nautilus_W_shield_cas") ~= nil and GetDistance(target,object) <= 20 then return 2--, 'NONE'
					end
				end
			end
		end
	end
	return {status = 0, name = nil, amount = nil, type = nil}
end

function OnCreateObj(obj)
	if obj ~= nil then
		if obj.charName == 'EggTimer.troy' then
			for i= 1,objManager:GetMaxHeroes(),1 do
				local hero=objManager:GetHero(i)
				if hero.name == 'Anivia' and GetDistance(obj, hero) < 10 then
					if hero.team == myHero.team then egg.allied.time = GetTickCount()
					else egg.enemy.time = GetTickCount() end
				end
			end
		elseif obj.charName == 'Aatrox_Passive_Death_Activate.troy' then
			for i= 1,objManager:GetMaxHeroes(),1 do
				local hero=objManager:GetHero(i)
				if hero.name == 'Aatrox' and GetDistance(obj, hero) < 10 then
					if hero.team == myHero.team then aatrox.allied.time = GetTickCount()
					else aatrox.enemy.time = GetTickCount() end
				end
			end
		elseif obj.charName == 'ZacPassiveExplosion.troy' then
			for i= 1,objManager:GetMaxHeroes(),1 do
				local hero=objManager:GetHero(i)
				if hero.name == 'Zac' and GetDistance(obj, hero) < 10 then
					if hero.team == myHero.team then zac.allied.time = GetTickCount()
					else zac.enemy.time = GetTickCount() end
				end
			end
		end
	end
end