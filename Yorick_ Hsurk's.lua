require "Utils"
 
printtext("\nYorick Beta By hsurk\n")
local target
local target2

local attacking = false
local timer0 = 0
local t0_attacking = 0
local t1_attacking = 0
local attackAnimationDuration = 250

 
YorickConfig = scriptConfig("Yorickbot", "Yorickcombo")
YorickConfig:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("E"))
YorickConfig:addParam("Build", "Build", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("N"))
YorickConfig:addParam("movement", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)
YorickConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)

function OnProcessSpell(unit,spell)
        if unit ~= nil and spell ~= nil and unit.charName == myHero.charName then
                if spell.name == "YorickBasicAttack" or spell.name == "YorickBasicAttack2" or spell.name == "YorickCritAttack" and target ~= nil and spell.target and CanUseSpell("Q") then
                        t0_attacking = GetClock()+attackAnimationDuration
                        attacking = true
                        timer0 = GetTickCount()
						end
 end
 end
 
 function ResetTimer()
        if GetTickCount() - timer0 > 275 then
                attacking = false
                timer0 = 0
        end
end
 
function useQ()
        if target ~= nil then
                if attacking == true and GetClock() > t0_attacking and GetDistance(myHero, target) < 275 then
                        CastSpellXYZ("Q",myHero.x,myHero.y,myHero.z)
                        attacking = false
                        timer0 = 0
                end
    end
end
 
function Combo()
DrawText("Death is only the beginning.",20,75,0xFF00EE22)
        target = GetWeakEnemy("PHYS", 550, "NEARMOUSE")
		target2 = GetWeakEnemy("PHYS", 250, "NEARMOUSE")
        if target ~= nil then
			CustomCircle(100,4,1,target)
        
			if CanCastSpell("W") then
				wPos = GetMEC(100, 600, target)
                if wPos then
					CastSpellXYZ("W", wPos.x, wPos.y, wPos.z)
                else
                    CastSpellTarget("W", target)
				end
			end
		
			if CanCastSpell("E") then 
				CastSpellTarget("E", target) 
			end
		
			
        end
end
               
function Build()
DrawText("IRONMAN: FaerieCharm+Pots-Boots-Tear-MercuryThreads-ManaMune-SpiritVisage-IcebornGauntlet/FrozenHeart-Warmogs/FrozenMallet-GuardianAngel",20,50,0xFF00EE22)
DrawText("MUHAMMAD ALI: FaerieCharm+Pots-Boots-Tear-MercuryThreads-ManaMune-Brutalizer-FrozenMallet-FrozenHeart-BlackCleaver/Bloodthurster-LastWhisper",20,61,0xFF00EE22)
end

               
               
 
function OnTick()

if YorickConfig.Combo then Combo() end
if YorickConfig.Build then Build() end
if YorickConfig.movement and YorickConfig.Combo and not target2 and GetDistance(mousePos,myHero)>250 then
				MoveToMouse()
			else if target2~=nil and YorickConfig.Combo then
				AttackTarget(target2)
				useQ()
			end   
			end
end
 
 
function OnDraw()
if YorickConfig.drawcircles then
		CustomCircle(250,1,4,myHero) -- AA RANGE
        CustomCircle(550,10,1,myHero) --Combo
if target then  CustomCircle(50,5,2,target) end
end
                        end    
 
SetTimerCallback("OnTick")