-- #Annie Annie Annie!
require "Utils"
require "spell_damage"

printtext("\nHave you seen my Tibbers?.. ~Annie\n")


local range = 650
local target


AnnieConfig = scriptConfig("Annies Config", "Annieconf")
AnnieConfig:addParam("harass", "harass", SCRIPT_PARAM_ONKEYDOWN, false, 88)
AnnieConfig:addParam("autoFarm", "Q Farm", SCRIPT_PARAM_ONKEYDOWN, false, 89)
AnnieConfig:addParam("scriptActive", "Press to Win", SCRIPT_PARAM_ONKEYDOWN, false, 89)
AnnieConfig:addParam("drawCircles", "Kill Markers", SCRIPT_PARAM_ONOFF, false, 89)
AnnieConfig:addParam("movement","movement", SCRIPT_PARAM_ONOFF,true, 120)
AnnieConfig:permaShow("harass")
AnnieConfig:permaShow("autoFarm")
AnnieConfig:permaShow("scriptActive")
AnnieConfig:permaShow("drawCircles")

function Run()
Util__OnTick()
        target = GetWeakEnemy('MAGIC', 650, "NEARMOUSE")
       
        -- [[ Harass ]] --
        if AnnieConfig.harass and target and GetDistance(target) < 650 then
                if CanCastSpell("Q") then CastSpellTarget("Q", target) end
                if CanCastSpell("W") then CastSpellTarget("W", target) end
                AttackTarget(target)
        end    
       
        -- [[ Full Combo ]] --
        if AnnieConfig.scriptActive and target then
                UseAllItems(target)
                if CanCastSpell("R") then
                        ultPos = GetMEC(230, 600, target)
                        if ultPos then
                                CastSpellXYZ("R", ultPos.center.x, 0, ultPos.center.z)
                        else
                                CastSpellTarget("R", target)
                        end
                end
               
                if CanCastSpell("Q") then CastSpellTarget("Q", target) end
                if CanCastSpell("W") then CastSpellTarget("W", target) end
                AttackTarget(target)
        end
 
        -- [[ Auto Farm ]] --
        if AnnieConfig.autoFarm and CanCastSpell("Q") then
                local myQ = math.floor(((GetSpellLevel("Q")-1)*40) + 85 + (myHero.ap * .7))
                local minion = GetLowestHealthEnemyMinion(600)
                if minion then
                DrawCircle(minion.x, minion.y, minion.z, 100, Color.Red) end
                if minion ~= nil and minion.health <= CalcMagicDamage(minion, myQ) then
                        CastSpellTarget("Q", minion)
                end
        end
       
        -- [[ Movement ]] --
        if (AnnieConfig.autoFarm or (AnnieConfig.scriptActive and target == nil) or (AnnieConfig.harass and target == nil)) and AnnieConfig.movement then
                MoveToMouse()
        end
       
        
end




function OnDraw()
            			
    if AnnieConfig.drawCircles then
	CustomCircle(625, 10, 3, myHero) -- Q range
    CustomCircle(600, 5, 2, myHero) -- R range
                 for i = 1, objManager:GetMaxHeroes()  do
			local enemy = objManager:GetHero(i)
			if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) then
				local qdmg = getDmg("Q",enemy,myHero)*CanUseSpell("Q") 
				local wdmg = getDmg("W",enemy,myHero)*CanUseSpell("W")

				local rdmg = getDmg("R",enemy,myHero)*CanUseSpell("R")
				local aadmg = getDmg("AD",enemy,myHero)
				
					if enemy.health < qdmg+wdmg+rdmg then CustomCircle(20,50,5,enemy) end
                end
            end
			end
			end




SetTimerCallback("Run")