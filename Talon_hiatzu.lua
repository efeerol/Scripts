require "Utils" 

local target
Hiatzustalon = scriptConfig("Hiatzustalon", "Hiatzustalon")
Hiatzustalon:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
Hiatzustalon:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))


function OnTick()	
	TalonDraw()
	target = GetWeakEnemy('PHYS',700,"NEARMOUSE")  
	if Hiatzustalon.Combo then
		if target == nil then
			MoveToMouse()
		elseif target ~= nil then
			CustomCircle(100,5,2,target)
			if GetDistance(myHero, target) < 595 then      
				TalonW(target)
			end      
				TalonE(target)
				TalonQ(target)                                 
				TalonR(target)
				AttackTarget(target)
			end
		end
	end
	if Hiatzustalon.Harass then
		if target == nil then
			MoveToMouse()
		elseif target ~= nil then
			CustomCircle(100,5,2,target)
			AttackTarget(target)                                   
			if GetDistance(myHero, target) < 595 then      
				TalonW(target)
			end  
			AttackTarget(target)
		end
	end		


function TalonDraw()
        CustomCircle(600,2,3,myHero) 
end

function TalonQ(target)
        if IsSpellReady("Q") == 1 then
                CastSpellTarget("Q",target)
        end
end

function TalonW(target)
        if IsSpellReady("W") == 1 then
                CastSpellTarget("W",target)
        end
end
 
function TalonE(target)
        if target ~= nil and GetDistance(myHero, target) < 700 then
                CastSpellTarget('E',target)
        end
end
 
function TalonR(target)
        if IsSpellReady("R") == 1 then
                CastSpellTarget("R",myHero)                                    
        end
end

function killSteal()
	CastHotkey("SPELLW:WEAKENEMY ONESPELLHIT=((spellw_level*50)+10+((player_bonusad*12)/10))")
	end

SetTimerCallback("OnTick")