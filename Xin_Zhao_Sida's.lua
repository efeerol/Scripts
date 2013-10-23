-- ###################################################################################################### --
-- #                                                                                                    # --
-- #                                             Sida's Xin Zhao                                         # --
-- #                                                                                                    # --
-- ###################################################################################################### --

require "basic_functions"
		
local hotkey = GetScriptKey() 	
local myHero = GetSelf()
local challenge = nil	
local attacked = false			

function Run()	
	Draw()
	FindNewObjects()
	local key = IsKeyDown(hotkey) 						
	local target = getLowestHPChampionInRange(630) 		
	
	if key == 1 then 									
		if target ~= nil then	
		
			if GetDistance(myHero, target) < 600 then 	
				castE(target)
			end		

			if GetDistance(myHero, target) < 300 then	
				castR(target)
			end	
	
				castW(target)		
				castQ(target) 							
			attacked = false
			AttackTarget(target)
			
		end
	end
end

function castQ(target)	
	if GetSpellLevel("W") < 1 or attacked then								
		CastSpellTarget("Q", myHero) 	
	end
end

function castW(target)
	if GetSpellLevel("W") > 0 and attacked then
		CastSpellTarget("W", myHero) 	
	end
end

function castE(target)
	CastSpellTarget("E", target) 						
end

function castR(target)
	if challenge ~= nil and challenged(target) then
		CastSpellTarget("R", target) 			
	end
end

function challenged(target)
	if challenge ~= nil and challenge.x == target.x and challenge.z == target.z then return true
	else return false
	end
end


function getLowestHPChampionInRange(range)								
local lowestChamp													
	for _,enemy in pairs(getEnemiesInRange(range)) do				
		if lowestChamp == nil then lowestChamp = enemy			
		else															
			if lowestChamp.health > enemy.health then					
				lowestChamp = enemy										
			end
		end
	end
	return lowestChamp													
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

function FindNewObjects()
	for i = 1, objManager:GetMaxNewObjects(), 1 do
		local object = objManager:GetNewObject(i)
		local s=object.charName

		if (s ~= nil) then
			if string.find(s,"xen_ziou_intimidate") ~= nil then
				challenge = object
			end
			if string.find(s,"xenZiou_heal_passive") ~= nil or string.find(s,"xenZiou_Chain") and GetDistance(myHero, object) < 50 then
				attacked = true
			end
		end
	end
end

function Draw()
	DrawCircle(myHero.x, myHero.y, myHero.z, 600, 0x02)
end

SetTimerCallback("Run")