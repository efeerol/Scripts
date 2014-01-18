--Hairy's invisopoison and sky auto Singed!

require "Utils"
require "basic_functions"
print=printtext

local myHero = GetSelf()
local target

SingedConfig = scriptConfig("Hairyfoot's Singed", "hairyssinged")
SingedConfig:addParam("usePoison", "Use Poison", SCRIPT_PARAM_ONKEYTOGGLE, false, 84) --T to active poison trail
SingedConfig:permaShow("usePoison")

function Run()
     target = GetWeakEnemy('MAGIC',300)
     DrawRange()

	
     if SingedConfig.usePoison then ReleasePoison() end
end

function ReleasePoison()
        CastSpellTarget("Q", myHero)
end


function OnProcessSpell(object,spell)
          
          
          
          if object.name == "Singed" and spell.name== "Fling" then
                    
                    print("\nSpellName: " .. spell.name)
                    print("\nSpell Target: " .. spell.target.name)
                    
                    if target ~= nil then
                         print("\nTarget: " .. target.name)
                         ClickSpellXYZ('M',target.x,target.y,target.z,0)
                    end
          
                                 
          end
          
          -- if object ~= nil and spell ~= nil and object.charName == myHero.charName and (string.find(spell.name,"BasicAttack") or string.find(spell.name,"ritAttack"))  then
               -- printtext(spell.name.."\n")
          -- end
end


function DrawRange()
     DrawCircleObject(myHero, 200, 2) 
end


SetTimerCallback("Run")
printtext("\nHairy's Singed")