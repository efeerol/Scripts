-- ###################################################################################################### --
-- #                                                                                                    # --
-- #                                             Val's Zilean Double Bomb								# --
-- #											 (based on Sida's Akali)                  				# --                        
-- #                                                                                                    # --
-- ###################################################################################################### --

require "basic_functions"
		
local hotkey = GetScriptKey() 	
local myHero = GetSelf()							

function ZileanRun()	
	Draw()
	local key = IsKeyDown(hotkey) 						
	local target = getLowestHPChampionInRange(700) 		
	
	if key == 1 then 									
		if target ~= nil then	
		
			if GetDistance(myHero, target) < 700 then 	
				castQ(target)
			end		

			if GetDistance(myHero, target) < 700 and IsSpellReady("Q") == 0 and IsSpellReady("W") == 1 then	
			CastSpellXYZ("W",myHero.x, myHero.y, myHero.z)
			end	
			
			AttackTarget(target)
			
		end
	end
end

function castQ(target)									
	CastSpellTarget("Q", target) 						
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

function Draw()
	DrawCircle(myHero.x, myHero.y, myHero.z, 700, 0x02)
end

SetTimerCallback("ZileanRun")