--HAIRYFOOT's TROLLCRANK!
require "Utils"
require "basic_functions"
print=printtext
lanternx = 0
lanterny = 0
lanternz = 0


function Trollcrank()
	Util__OnTick()  
end


function OnCreateObj(obj)
     if string.find(obj.charName,"Thresh_Lantern.troy") ~= nil then
     lanternobject = obj
          lanternx = obj.x
          lanterny = obj.y
          lanternz = obj.z
     end
     
end
     
function OnProcessSpell(object,spell)
          
          if object.name == "Blitzcrank" and spell.name== "RocketGrab" then
          print("\nRocket Grab Detected!")
               if math.abs(myHero.x - lanternx) < 350 and math.abs(myHero.y - lanterny) < 350 and math.abs(myHero.z - lanternz) < 350 then  
               
                    print("\nLantern within range! Transporting!")
                    ClickSpellXYZ('M',lanternx,lanterny,lanternz,0)
               else
                    print("\nNo lantern in range.")
               end
                                   
          end
end



function OnDraw()
	DrawText("Trollcrank Loaded",10,20,0xFF00EE00)
end

SetTimerCallback("Trollcrank")
printtext("\nTrollcrankin time!")