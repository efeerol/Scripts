-- ✈ ▌▌ 9/11 Edition
require "Utils"
require "spell_damage"

printtext("\nMalzahar 9/11")
local target
local order 
local timer = 0
local coord = {}
local stun = 0

MalzConfig = scriptConfig("Malzbot", "Malzcombo")
MalzConfig:addParam("Combo", "Kill Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
MalzConfig:addParam("harass", "Hard Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X")) --x
MalzConfig:addParam("escape", "Light Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C")) --x
MalzConfig:addParam("movement", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)
MalzConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
MalzConfig:addParam("QSteal", "Killsteal", SCRIPT_PARAM_ONOFF, true)


function OnTick()


 
if MalzConfig.Combo then
	target = GetWeakEnemy("MAGIC", 900)
	if target ~= nil then
		CustomCircle(100,4,1,target) 
		UseAllItems(target)
		CastSummonerIgnite(target)
		
			if CanCastSpell("Q") and GetDistance(target) <= 900 then 
			CastSpellXYZ('Q',GetFireahead(target,3,10))
			end
			
			
			if CanCastSpell("E") and GetDistance(target) < 650 then
			CastSpellTarget('E',target) 
			end
			
			if CanCastSpell("W") and GetDistance(target) < 800 then
			CastSpellTarget('W',target) 
			end
				
				
			if CanCastSpell("R") and GetTickCount() > timer and GetDistance(target) < 700 then 
			CastSpellTarget("R",target)
			end

	end
	

end

if MalzConfig.harass then
	target = GetWeakEnemy("MAGIC", 900, "NEARMOUSE")
	if target ~= nil then
		CustomCircle(100,4,1,target)
			if CanCastSpell("Q") and GetDistance(target) <= 900 then 
			CastSpellXYZ('Q',GetFireahead(target,3,10))
			end


			
			if CanCastSpell("W") and GetDistance(target) < 800 then
			CastSpellTarget('W',target) 
			end
	end
end

if MalzConfig.escape then
	target = GetWeakEnemy("MAGIC", 900, "NEARMOUSE")
	if target ~= nil then
		CustomCircle(100,4,1,target)
			if CanCastSpell("Q") and GetDistance(target) <= 900 then 
			CastSpellXYZ('Q',GetFireahead(target,3,10))
			end
			
			
			if CanCastSpell("E") and GetDistance(target) < 650 then
			CastSpellTarget('E',target) 
			end
			
			if CanCastSpell("W") and GetDistance(target) < 800 then
			CastSpellTarget('W',target) 
			end
	end
end



if MalzConfig.movement and (MalzConfig.harass or MalzConfig.Combo) and not target then
MoveToMouse()
end	

end

function OnProcessSpell(object,spell)
if spell ~= nil and string.find(spell.name,"AlZaharNetherGrasp") then
timer = GetTickCount() + 2500
end
end

function OnDraw()
if MalzConfig.drawcircles then
	CustomCircle(980,1,2,myHero) --Q
	CustomCircle(myHero.range,1,4,myHero) 
	CustomCircle(200,10,1,myHero) --R
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
				
				if MalzConfig.QSteal then
				if edmg >= enemy.health and GetDistance(myHero,enemy) < 650 then CastSpellTarget('Q',target)
				CustomCircle(100,10,7,enemy)	
				end
				end
				
					
					
					end
				end
			end	
	
	
	
	end



SetTimerCallback("OnTick")