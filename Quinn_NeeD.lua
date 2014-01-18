require "Utils"

if myHero.name ~= "Quinn" then return end
local range = 1025
local target

QuinnConfig = scriptConfig("NeeD'S Quinn", "quinnncombo")
QuinnConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
QuinnConfig:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X")) --x
QuinnConfig:addParam("autoFarm", "Auto Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V")) --V
QuinnConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
QuinnConfig:permaShow("scriptActive")
QuinnConfig:permaShow("harass")
QuinnConfig:permaShow("autoFarm")

function OnTick()
		DetectBird()
        target = GetWeakEnemy('PHYS',1025,"NEARMOUSE")
        -- [[ Harass ]] --
        if QuinnConfig.harass and target and Bird == false and GetDistance(target) < 1025 then
                if CanCastSpell("Q") and CreepBlock(myHero.x,myHero.y,myHero.z,GetFireahead(target,2,16)) == 0 then CastSpellXYZ('Q',GetFireahead(target,2,16)) end
                AttackTarget(target)
        end    
       
        -- [[ Full Combo ]] --
        if QuinnConfig.scriptActive and target then
                UseAllItems(target)
               if Bird == false then
                if CanCastSpell("Q") and CreepBlock(myHero.x,myHero.y,myHero.z,GetFireahead(target,2,16)) == 0 then CastSpellXYZ('Q',GetFireahead(target,2,16)) end
                if CanCastSpell("E") then CastSpellTarget("E", target) end
                AttackTarget(target)
        end
		if Bird == true then
		if CanCastSpell("Q") then CastSpellTarget("Q", target) end
        if CanCastSpell("E") then CastSpellTarget("E", target) end
                AttackTarget(target)
		end
		end
        -- [[ Auto Farm ]] --
        if QuinnConfig.autoFarm then
                local ad = myHero.baseDamage
                local minion = GetLowestHealthEnemyMinion(525)
                if minion then
                DrawCircle(minion.x, minion.y, minion.z, 100, Color.Red) end
                if minion ~= nil and minion.health <= CalcMagicDamage(minion, ad) then
                        AttackTarget(minion)
                end
        end
       
        -- [[ Movement ]] --
        if QuinnConfig.autoFarm then
                MoveToMouse()
        end
		end
       


function DetectBird()
        if myHero.range < 200 then
            DrawText("Bird Form",10,40,0xFF00EE00);
            Bird = true
        else
            DrawText("Human Form",10,40,0xFF00EE00);
            Bird = false
    end
end
 
function OnDraw()
        if QuinnConfig.drawcircles and myHero.dead == 0 then
                CustomCircle(1025, 10, 3, myHero) -- Q range
                CustomCircle(750, 5, 2, myHero) -- E range
				CustomCircle(2100, 10, 4, myHero) -- W range
                if target ~= nil then
                        CustomCircle(100, 10, 2, target)
                end
        end
end
 
SetTimerCallback("OnTick")