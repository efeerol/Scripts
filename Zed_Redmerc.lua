																								
require "Utils" 

local hotkey = GetScriptKey() 	
local myHero = GetSelf()	
local target 
local doAttack = false 


function Run() 
	ZedDraw() 
		local key = IsKeyDown(hotkey) 
	target = GetWeakEnemy('PHYS',900)  
		if key == 1 then   
			if target ~= nil then								
				AutoIgnite()
				ZedR(target)
					UseAllItems(target) 
						ZedW(target)
						ZedQ(target)	
						ZedE(target)
						AttackTarget(target) 
			end 
				if target == nil or not doAttack then
					MoveToMouse() 
				end
		end 
end 

function ZedQ(target)
	if CanCastSpell("Q") then CastSpellXYZ("Q",target.x,target.y,target.z) end 
end 

function ZedW(target)
	if CanCastSpell("W") then CastSpellXYZ("W",target.x,target.y,target.z) end
    if (GetDistance(target) < 250) and CanCastSpell("E") then CastSpellTarget("E",target)	end
end

function ZedE(target)
if GetDistance(target) < 250 and CanCastSpell("E") then CastSpellTarget("E",target) end
end

function ZedR(target)
if CanCastSpell("R") then CastSpellTarget("R",target) end
end

function AutoIgnite()
    local target = GetWeakEnemy('TRUE', 600)
    local IgniteDMG = 50+(20*myHero.selflevel)

    if CanCastSpell("R") and target ~= nil and myHero.SummonerD == "SummonerDot" and target.visible and target.dead ~= 1 and target.invulnerable ~= 1 then
        if IsSpellReady("D") == 1 then
            CastSpellTarget("D",target)
        end
    end
	end
	

function ZedDraw() 
		CustomCircle(900,1,2,myHero) 
		CustomCircle(625,10,1,myHero)
end  


SetTimerCallback("Run")