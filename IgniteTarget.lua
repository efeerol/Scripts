--[[
--IgniteTarget v1.3b by Lua
----IgniteTarget(target, SpellKey, BurnGA, BurnEgg, BurnAatrox, BurnZac)

----Option
------BurnGA (Guardian Angel): Auto Ignite if target has Guardian Angel
------BurnEgg,Aatrox,Zac: If target has Eggnivia passive and its enabled it will Auto Cooking to make Egg!
------					  (Auto Ignite if target has Passive)

----Feature
------Barrier
--------Only Ignite Target when killable by ignite

------Tryndamere
--------If Trynd has Undying Rage or up in 5sec, wont Auto Ignite
--------Only Ignite Trynd when killable by ignite (Thanks to Val and Mal!)

------Kayle
--------If Kayle has Intervention or up in 5sec, wont Auto Ignite
--------Only Ignite Kayle when killable by ignite (Thanks to Val and Mal!)

------Zilean
--------If Zilean has Chrono Shift or up in 5sec, wont Auto Ignite
--------Only Ignite when Zilean uses Chrono Shift and 4.5sec or 6sec over

------Anivia (Eggnivia)
--------If Anivia has Eggnivia Passive, wont Auto Ignite
--------Only Ignite when Eggnivia is on CD or Ignite Egg option is Enabled

------Master Yi
--------If Yi has Meditate, wont Auto Ignite until half damage of ignite can kill him
--------or Only Ignite when Meditate is on CD

------Intervention (Kayle's ult ._.)
--------Only Ignite Kayle when killable by ignite (Thanks to Val and Mal!)

------Chrono Shift (Zilean's ult ._.)
--------Only Ignite when 4.5sec or 6sec over

Exmaple Script in forum
http://leaguebot.net/forum/Upload/showthread.php?tid=3160
]]--
require 'Utils'
require 'IsInvulnerable' --Download it from http://leaguebot.net/forum/Upload/showthread.php?tid=3105
local lastCheck = {name = nil, time = 0}
local secondsNeeded = 0
local enemyKey = nil

function IgniteTarget(target, Key, BurnGA, BurnEgg, BurnAatrox, BurnZac)
	if lastCheck.name ~= nil and GetTickCount()-lastCheck.time > 8000 then lastCheck = {name = nil, time = 0} end
	local igniteDamage = 50+(20*myHero.selflevel)
	if target ~= nil and Key ~= nil and myHero["Summoner"..Key] == 'SummonerDot' and igniteDamage > target.health then
		local status = IsInvulnerable(target)
		if BurnGA and status.name == 'Guardian Angel' then status = {status = 0, name = nil, amount = nil, type = nil} end
		if BurnAatrox and status.name == 'Aatrox' then status = {status = 0, name = nil, amount = nil, type = nil} end
		if BurnZac and status.name == 'Zac' then status = {status = 0, name = nil, amount = nil, type = nil} end
		local enemyKey = nil
		local Barrier = 0
		if target.SpellNameD == 'SummonerBarrier' then enemyKey = 'D'
		elseif target.SpellNameF == 'SummonerBarrier' then enemyKey = 'F'
		end
		if enemyKey ~= nil and target["SpellTime"..enemyKey] > -2 then Barrier = 2000 end
		if status.status == 0 and target.name ~= 'Tryndamere' and target.name ~= 'Kayle' and target.name ~= 'Zilean' and target.name ~= 'Anivia' and target.name ~= 'MasterYi' and target.name ~= 'Aatrox' and target.name ~= 'Zac' then CastIgnite(Key,igniteDamage,target,Barrier)
		elseif target.name == 'Tryndamere' then
			if status.name == 'Undying Rage' then
				secondsNeeded = target.health/(igniteDamage/5)*1000
				if lastCheck.name == status.name and secondsNeeded<5000 and GetTickCount()-lastCheck.time > 5000-(5000-secondsNeeded) then CastIgnite(Key,igniteDamage,target,Barrier)
				else lastCheck = {name = status.name, time = GetTickCount()} end
			elseif target.SpellLevelR == 0 or target.SpellTimeR < -4 and status.status ~= 1 and status.status ~= 3 then CastIgnite(Key,igniteDamage,target,Barrier)
			end
		elseif status.name == 'Intervention' then
				secondsNeeded = target.health/(igniteDamage/5)*1000
				if lastCheck.name == status.name and secondsNeeded<5000 and GetTickCount()-lastCheck.time > godhateskayle-(5000-secondsNeeded) then CastIgnite(Key,igniteDamage,target,Barrier)
				else
					for i= 1,objManager:GetMaxHeroes(),1 do
						local hero=objManager:GetHero(i)
						if hero.team == target.team and hero.name == 'Kayle' then
							godhateskayle = (1.5+(hero.SpellLevelR*0.5))*1000
						end
					end
					lastCheck = {name = status.name, time = GetTickCount()}
				end
		elseif status.name == 'Chrono Shift' then
			if lastCheck.name == status.name then
				local halfigniteDamage = igniteDamage/2
				if halfigniteDamage < target.health and GetTickCount()-lastCheck.time > 4500 then CastIgnite(Key,igniteDamage,target,Barrier)
				else
					local halfigniteDamage = igniteDamage/5
					if halfigniteDamage < target.health and GetTickCount()-lastCheck.time > 6000 then CastIgnite(Key,igniteDamage,target,Barrier) end
				end
			else lastCheck = {name = status.name, time = GetTickCount()}
			end
		elseif target.name == 'Kayle' then
			if target.SpellLevelR == 0 or target.SpellTimeR < -4 then CastIgnite(Key,igniteDamage,target,Barrier)
			else
				secondsNeeded = target.health/(igniteDamage/5)*1000
				if secondsNeeded<5000 then CastIgnite(Key,igniteDamage,target,Barrier) end
			end
		elseif target.name == 'Zilean' then
			if target.SpellLevelR == 0 or target.SpellTimeR < -4 then CastIgnite(Key,igniteDamage,target,Barrier)
			end
		elseif target.name == 'Anivia' then
			if status.name == 'Egg' and BurnEgg then CastIgnite(Key,igniteDamage,target,Barrier)
			elseif status.status ~= 1 and status.status ~= 3 then CastIgnite(Key,igniteDamage,target,Barrier)
			end
		elseif target.name == 'Aatrox' then
			if status.name == 'Aatrox' and BurnAatrox then CastIgnite(Key,igniteDamage,target,Barrier)
			elseif status.status ~= 1 and status.status ~= 3 then CastIgnite(Key,igniteDamage,target,Barrier)
			end
		elseif target.name == 'Zac' then
			if status.name == 'Zac' and BurnZac then CastIgnite(Key,igniteDamage,target,Barrier)
			elseif status.status ~= 1 and status.status ~= 3 then CastIgnite(Key,igniteDamage,target,Barrier)
			end
		elseif target.name == 'MasterYi' then
			if target.SpellLevelW == 0 or target.SpellTimeW < -4 then CastIgnite(Key,igniteDamage,target,Barrier)
			elseif target.SpellLevelW > 0 and target.SpellTimeW > 0 then
				local halfigniteDamage = igniteDamage/2
				if halfigniteDamage > target.health then CastIgnite(Key,igniteDamage,target,Barrier) end
			end
		end
	end
end

function CastIgnite(ignitekey, damage, target, shield)
	if shield == nil or shield == 0 then CastSpellTarget(ignitekey,target)
	else
		local CastsecondsNeeded = target.health/(damage/5)*1000
		if CastsecondsNeeded+2000<5000 then CastSpellTarget(ignitekey,target) end
	end
end