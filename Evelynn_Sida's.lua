require "Utils"

if myHero.name ~= "Evelynn" then return end
local range = 650
local target

EvelynnConfig = scriptConfig("Sida's Evelynn", "evelynncombo")
EvelynnConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
EvelynnConfig:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X")) --x
EvelynnConfig:addParam("autoFarm", "Auto Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C")) --c
EvelynnConfig:addParam("movement", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)
EvelynnConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
EvelynnConfig:permaShow("autoFarm")
EvelynnConfig:permaShow("harass")

function OnTick()
	target = GetWeakEnemy('MAGIC', 650)
	
	-- [[ Harass ]] --
	if EvelynnConfig.harass and target and GetDistance(target) < 500 then
		if CanCastSpell("Q") then CastSpellTarget("Q", target) end
		if CanCastSpell("E") then CastSpellTarget("E", target) end
		AttackTarget(target)
	end	
	
	-- [[ Full Combo ]] --
	if EvelynnConfig.scriptActive and target then
		UseAllItems(target)
		if CanCastSpell("R") then
			ultPos = GetMEC(250, 650, target)
			if ultPos then
				CastSpellXYZ("R", ultPos.x, ultPos.y, ultPos.z)
			else
				CastSpellTarget("R", target)
			end
		end
		
		if CanCastSpell("Q") then CastSpellTarget("Q", target) end
		if CanCastSpell("E") then CastSpellTarget("E", target) end
		AttackTarget(target)
	end

	-- [[ Auto Farm ]] --
	if EvelynnConfig.autoFarm and CanCastSpell("Q") then
		local myQ = math.floor(((GetSpellLevel("Q")-1)*20) + 40 + (myHero.ap * .45) + (myHero.addDamage * .5))
		local minion = GetLowestHealthEnemyMinion(500)
		if minion then
		DrawCircle(minion.x, minion.y, minion.z, 100, Color.Red) end
		if minion ~= nil and minion.health <= CalcMagicDamage(minion, myQ) then
			CastSpellTarget("Q", minion)
		end
	end
	
	-- [[ Movement ]] --
	if (EvelynnConfig.autoFarm or (EvelynnConfig.scriptActive and target == nil) or (EvelynnConfig.harass and target == nil)) and EvelynnConfig.movement then
		MoveToMouse()
	end
	
	-- [[ Hold Q ]] --
	if KeyDown(string.byte("Q")) then
		CastSpellTarget("Q", myHero)
	end

end

function OnDraw()
	if EvelynnConfig.drawcircles and myHero.dead == 0 then
		CustomCircle(500, 10, 3, myHero) -- Q range
		CustomCircle(650, 5, 2, myHero) -- R range
		if target ~= nil then
			CustomCircle(100, 10, 2, target)
		end
	end
end

SetTimerCallback("OnTick")