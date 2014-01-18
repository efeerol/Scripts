require "Utils" 

Osteonstalon = scriptConfig("Osteonstalon", "Osteonstalon")
Osteonstalon:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
Osteonstalon:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
Osteonstalon:addParam("KillSteal", "Killsteal", SCRIPT_PARAM_ONOFF, true)

if Osteonstalon.Combo then Combo() end
if Osteonstalon.Harras then Harrass() end
if Osteonstalon.killSteal then killSteal() end

function OnTick()
	TalonDraw()
	target = GetWeakEnemy('PHYS',700,"NEARMOUSE")  
			if Osteonstalon.Combo then
				if target == nil or not doAttack then
					MoveToMouse()
				if target ~= nil then
				CustomCircle(100,5,2,target)
				DrawSphere(50,25,3,target.x,target.y+300,target.z)
				UtilityFunction()
				if GetDistance(myHero, target) < 700 then
					TalonE(target)
				end    
				TalonQ(target)
				AttackTarget(target)                                   
				if GetDistance(myHero, target) < 595 then      
					TalonW(target)
				end    
				TalonR(target)
				AttackTarget(target)
			end
			end
		end
			if Osteonstalon.Harass then
				if target == nil or not doAttack then
					MoveToMouse()
				if target ~= nil then
				CustomCircle(100,5,2,target)
				DrawSphere(50,25,3,target.x,target.y+300,target.z)
				UtilityFunction()
				AttackTarget(target)                                   
				if GetDistance(myHero, target) < 595 then      
					TalonW(target)
				end    
				AttackTarget(target)
			end
			end
		end		
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