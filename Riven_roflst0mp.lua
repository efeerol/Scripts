-- Riven and stuff - Another quality release from EZG
require "Utils"
require "spell_damage"

printtext("\nYou will not escape me!")
local target
local order 
local etimer = 0
local atimer = 0
local coord = {}
local aspeed = (1000/myHero.attackspeed)

RivenConfig = scriptConfig("Rivenbot", "Rivencombo")
RivenConfig:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
RivenConfig:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X")) --x
RivenConfig:addParam("escape", "Escape", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C")) --x
RivenConfig:addParam("movement", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)
RivenConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
RivenConfig:addParam("QSteal", "Killsteal", SCRIPT_PARAM_ONOFF, true)
RivenConfig:addParam("print", "print", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K")) --- For debugging only

function OnTick()
 
if RivenConfig.print then

printtext("\nPRINTOUT")
printtext("\nQ:"..myHero.SpellNameQ)
printtext("\nW:"..myHero.SpellNameW)
printtext("\nE:"..myHero.SpellNameE)
printtext("\nR:"..myHero.SpellNameR)
end
   
if RivenConfig.Combo then
	target = GetWeakEnemy("PHYS", 900, "NEARMOUSE")
	if target ~= nil then
	CustomCircle(100,4,1,target)
	if myHero.SpellNameR == "RivenFengShuiEngine" and CanCastSpell("R") and GetDistance(target) < 500 then CastSpellTarget("R",myHero) etimer = (GetTickCount() + 13000) end
	if myHero.SpellNameQ == "RivenTriCleave"  and CanCastSpell("Q") and (GetTickCount() > atimer) then CastSpellXYZ("Q",mousePos.x,mousePos.y,mousePos.z) atimer = (GetTickCount() + aspeed) end
	if myHero.SpellNameQ == "riventricleavebuffer" then AttackTarget(target) end
	if CanCastSpell("W") and GetDistance(target) < 200 then CastSpellTarget("W",myHero) end
	if CanCastSpell("E")  then CastSpellTarget("E",target) end
	 if IsAttackReady() then AttackTarget(target) else MoveToMouse() end 
		 if myHero.SpellNameR ~= "RivenFengShuiEngine" and CanCastSpell("R") and GetTickCount() < etimer then if (getDmg("R",target,myHero) > target.health) then CastSpellTarget("R", target) end
	 if myHero.SpellNameR ~= "RivenFengShuiEngine" and CanCastSpell("R") and GetTickCount() >= etimer then CastSpellTarget("R",target) end
end
end
end

if RivenConfig.harass then
target = GetWeakEnemy("PHYS", 900, "NEARMOUSE")
	if target ~= nil then
	CustomCircle(100,4,1,target)
	if myHero.SpellNameQ == "RivenTriCleave"  and CanCastSpell("Q") then coord = {x = myHero.x, y=myHero.y, z=myHero.z} CastSpellXYZ("Q",mousePos.x,mousePos.y,mousePos.z) end
	if myHero.SpellNameQ == "riventricleavebuffer" and GetDistance(target) > myHero.range then AttackTarget(target) end
	if CanCastSpell("W") and GetDistance(target) < 200 then CastSpellTarget("W",myHero) end
	if CanCastSpell("E") and GetDistance(target) > myHero.range then CastSpellXYZ("E",coord.x,coord.y,coord.z) end
	 if IsAttackReady() then AttackTarget(target) else MoveToMouse() end 

                end
end


if RivenConfig.escape then
	if CanCastSpell("Q") then CastSpellXYZ("Q",mousePos.x,mousePos.y,mousePos.z) end
	if CanCastSpell("E") then CastSpellXYZ("E",mousePos.x,mousePos.y,mousePos.z) end
	escape = { x = mousePos.x, y = mousePos.y, z = mousePos.z }
	end





if RivenConfig.movement and (RivenConfig.harass or RivenConfig.Combo or RivenConfig.escape) and not target then
MoveToMouse()
end	
end

function OnDraw()
if RivenConfig.drawcircles then
	CustomCircle(900,1,2,myHero) --Q
	CustomCircle(myHero.range,1,4,myHero) 
	CustomCircle(625,10,1,myHero) --R
if target then 	CustomCircle(50,5,2,target) end

for i = 1, objManager:GetMaxHeroes()  do
			local enemy = objManager:GetHero(i)
			if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) then
				local pdmg = getDmg("P",enemy,myHero) 
				local qdmg = getDmg("Q",enemy,myHero)*CanUseSpell("Q") 
				local wdmg = getDmg("W",enemy,myHero)*CanUseSpell("W")
				local edmg = getDmg("E",enemy,myHero)*CanUseSpell("E")
				local rdmg = getDmg("R",enemy,myHero)*CanUseSpell("R")
				local aadmg = getDmg("AD",enemy,myHero)
				
				if qdmg+wdmg+rdmg >= enemy.health then CustomCircle(100,20,2,enemy) end
				
				if RivenConfig.QSteal then
				if qdmg >= enemy.health and GetDistance(myHero,enemy) < 300 then CastSpellTarget("Q",enemy)
				CustomCircle(100,10,7,enemy)	
				end
				end
				end
				
					
					
					end
				end
			end	
	
	
	


SetTimerCallback("OnTick")