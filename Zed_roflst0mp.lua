require "Utils"
require "spell_damage"

printtext("\nZed's Dead, Baby")
local target

ZedConfig = scriptConfig("Zedbot", "Zedcombo")
ZedConfig:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
ZedConfig:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X")) --x
ZedConfig:addParam("escape", "Escape", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C")) --x
ZedConfig:addParam("killsteal", "KillSteal", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("J")) --x
ZedConfig:addParam("safe", "Safe Harass", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("K")) --x
ZedConfig:addParam("movement", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)


function OnTickZed()
if IsChatOpen() == 0 then

if ZedConfig.Combo then
	target = GetWeakEnemy("PHYS", 900, "NEARMOUSE")
	if target ~= nil then
	CustomCircle(100,4,1,target)
	UseAllItems(target)
	
	if CanCastSpell("R") then CastSpellTarget("R",target) end
	if CanCastSpell("W") then CastSpellXYZ("W",target.x,target.y,target.z) end
	if CanCastSpell("F") then CastSpellTarget("F",target) end
	if GetDistance(target) < 250 and CanCastSpell("E") then CastSpellTarget("E",target) end
	if CanCastSpell("Q") then CastSpellXYZ("Q",target.x,target.y,target.z) end
	if CanCastSpell("E") then CastSpellTarget("E",target) end
	if IsAttackReady() and GetDistance(target) < 200 then AttackTarget(target) end

end
end


if ZedConfig.harass then
target = GetWeakEnemy("PHYS", 900, "NEARMOUSE")
		if target ~= nil then
	CustomCircle(100,4,1,target)
		
		if ZedConfig.safe then if CanCastSpell("W") and myHero.SpellNameW == "ZedShadowDash" then CastSpellXYZ("W",target.x,target.y,target.z) end end
		if not ZedConfig.safe then if CanCastSpell("W") then CastSpellXYZ("W",target.x,target.y,target.z) end end
		if (GetDistance(target) < 900) and CanCastSpell("E") then CastSpellTarget("E",target) end
		if CanCastSpell("Q") then CastSpellXYZ("Q",target.x,target.y,target.z) end

		end

end


if ZedConfig.escape then
escape = {}
	target = GetWeakEnemy("PHYS", 900, "NEARMOUSE")

	if CanCastSpell("W") then CastSpellXYZ("W",mousePos.x,mousePos.y,mousePos.z) 
	escape = { x = mousePos.x, y = mousePos.y, z = mousePos.z }
	end

end



if ZedConfig.movement and (ZedConfig.harass or ZedConfig.Combo or ZedConfig.escape)  and not target then
MoveToMouse()
end	
end
end


SetTimerCallback("OnTickZed")