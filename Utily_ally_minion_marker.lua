require 'Utils'
require 'winapi'
require 'spell_damage'
local send = require 'SendInputScheduled'
local MinionsAA = { }
local SORT_CUSTOM = function(a, b) return a.maxHealth and b.maxHealth and a.maxHealth < b.maxHealth end
 
function Main()
	if IsLolActive() then
		MinionsAA = GetAllyMinions(SORT_CUSTOM)
		local target = getAD(1000)
		if target ~= nil then
			for i, minionAA in pairs(MinionsAA) do
				if minionAA ~= nil then
					if GetDistance(minionAA) < 1000 and GetDistance(target, minionAA) < 800 then
						AAdam = getDmg("AD",minionAA,myHero)
						if AAdam ~= nil then
							if minionAA.health < AAdam then CustomCircle(50,5,2,minionAA) end
							if minionAA.health < AAdam * 1.5 then 
								CustomCircle(70,5,3,minionAA)
								CustomCircle(80,5,1,target)
							end
						end
					end
				end
			end
		end
	end
end

function getEnemiesInRange(range)
local champs = {}														
local maxHeroes = objManager:GetMaxHeroes()								
	for i=0, maxHeroes ,1 do											
		local champion = objManager:GetHero(i)							
        if champion.team ~= myHero.team and champion.dead == 0 then		
			if GetDistance(myHero, champion) < range then				
				champs[champion.name] = champion						
			end
		end
	end
	return champs														
end

function getAD(range)								
local ADChamp													
	for _,enemy in pairs(getEnemiesInRange(range)) do	---enemy is ID
		for k, ADname in pairs(ADTable) do
			if enemy.name == ADname then 
				ADChamp = enemy
			end
		end
	end
	return ADChamp													
end	

ADTable = {"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jinx", "KogMaw", "Lucian", "MissFortune", "Quinn", "Sivir", "Tristana", "Twitch", "Urgot", "Varus", "Vayne"}

function IsLolActive()
    return tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client"
end
 
SetTimerCallback('Main')