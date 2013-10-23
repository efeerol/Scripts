require "Utils"
require "spell_damage"
print("\nMalbert's")
print("\nSimple Aatrox E")
print("\nVersion 1.0")

local WBT=true

AatroxConfig = scriptConfig("Aatrox", "Aatrox Hotkeys")
AatroxConfig:addParam("W", "W Changer", SCRIPT_PARAM_ONKEYTOGGLE, true, 55) 
AatroxConfig:permaShow("W")


function AjaxRun()
	if AatroxConfig.W then
		if myHero.health<myHero.maxHealth*0.5 and CanCastSpell('W') and GetSpellLevel('W')>0 and WBT==false then
			CastSpellTarget('W',myHero)
		end
		if myHero.health<myHero.maxHealth*0.5 and not CanCastSpell('W') and GetSpellLevel('W')>0 and WBT==false then
			WBT=true
		end
		if myHero.health>myHero.maxHealth*0.7 and CanCastSpell('W') and GetSpellLevel('W')>0 and WBT==true then
			CastSpellTarget('W',myHero)
		end
		if myHero.health>myHero.maxHealth*0.7 and not CanCastSpell('W') and GetSpellLevel('W')>0 and WBT==true then
			WBT=false
		end
	end
end


SetTimerCallback("AjaxRun")