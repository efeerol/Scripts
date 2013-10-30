require "Utils" 

local target

Osteonshyvana = scriptConfig("Osteonshyvana", "Osteonshyvana")
Osteonshyvana:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
Osteonshyvana:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
Osteonshyvana:addParam("killSteal", "Kill Steal", SCRIPT_PARAM_ONKEYTOGGLE, true, 113)
Osteonshyvana:addParam("useItems", "Use Items", SCRIPT_PARAM_ONKEYTOGGLE, true, 112)


function OnTick()	
	ShyvanaDraw()
	target = GetWeakEnemy('PHYS',700,"NEARMOUSE")  
	if Osteonshyvana.Combo then
		if target == nil then
			MoveToMouse()
		elseif target ~= nil then
			CustomCircle(100,5,2,target)
			if GetDistance(myHero, target) < 700 then      
				ShyvanaW(target)
			end 
if Osteonshyvana.useItems then
	UseAllItems(target)
end	
				ShyvanaE(target)
				ShyvanaQ(target)                                 
				AttackTarget(target)
			end
		end
	end
	
if Osteonshyvana.Harass then
		if target == nil then
			MoveToMouse()
		elseif target ~= nil then
			CustomCircle(100,5,2,target)
			AttackTarget(target)                                   
			if GetDistance(myHero, target) < 595 then      
				ShyvanaE(target)
			end  
			AttackTarget(target)
		end
end		


function ShyvanaDraw()
        CustomCircle(600,2,3,myHero) 
end

function ShyvanaQ(target)
        if target ~= nil and GetDistance(myHero, target) < 200 then
                CastSpellTarget("Q",target)
        end
end

function ShyvanaE(target)
        if target ~= nil and GetDistance(myHero, target) < 700 then
                CastSpellXYZ('E',GetFireahead(target,2.4,16))
        end
end
 
function ShyvanaW(target)
        if target ~= nil and GetDistance(myHero, target) < 700 then
                CastSpellTarget('W',target)
        end
end


function killSteal()
	CastHotkey("SPELLR:WEAKENEMY RANGE=1000 FIREAHEAD=1.6,20 ONESPELLHIT=((spellr_level*100)+100+((player_ap*7)/10))")
	end

SetTimerCallback("OnTick")