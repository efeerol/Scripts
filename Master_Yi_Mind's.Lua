-- #Dunk Yi
require "Utils"
require "spell_damage"
printtext("\nCommence Dunking\n")

local target
local myHero = GetSelf()    



function Run()
Util__OnTick()
    if YiConfig.Farm then Farm() end
    if YiConfig.qFarm then qFarm() end
    if YiConfig.Combo then Combo() end
	if YiConfig.Poke then Poke() end
	if YiConfig.autoHeal then meditate() end
	    end
    
function meditate()
if myHero.health < (myHero.maxHealth*(YiConfig.health/100)) and CanUseSpell("W") then
                CastSpellTarget("W",myHero) end 
end
	
function Farm()
CastHotkey("ATTACK:WEAKMINION ONEHIT=1 RANGE=500")
end    

function qFarm()
if CanUseSpell("Q") then
        CastHotkey("SPELLQ:WEAKMINION RANGE=600 ONESPELLHIT=((50+spellq_level*50)+(player_ap))") end
end    
    
function Poke()
local target = GetWeakEnemy('MAGIC',600,"NEARMOUSE")
              if target ~= nil then
					if GetDistance(myHero, target) < 600 and IsSpellReady("E") then CastSpellTarget("E", target) end
                    if GetDistance(myHero, target) < 600 and IsSpellReady("Q") then CastSpellTarget("Q", target) end
					AttackTarget(target)
                end
        if target == nil and YiConfig.movement then
				MoveToMouse()
			elseif target ~= nil then
				if YiConfig.autoAttack then
					AttackTarget(target)
				elseif YiConfig.movement then
					MoveToMouse()
				end
			end
end    
 
function Combo()
local target = GetWeakEnemy('MAGIC',600,"NEARMOUSE")
              if target ~= nil then
					if YiConfig.useItems then UseTargetItems(target) end  
					if GetDistance(myHero, target) < 600 and IsSpellReady("E") then CastSpellTarget("E", target) end
                    if GetDistance(myHero, target) < 600 and IsSpellReady("R") then CastSpellTarget("R", target) end
                    if GetDistance(myHero, target) < 600 and IsSpellReady("Q") then CastSpellTarget("Q", target) end
                    AttackTarget(target)
                end
        if target == nil and YiConfig.movement then
				MoveToMouse()
			elseif target ~= nil then
				if YiConfig.autoAttack then
					AttackTarget(target)
				elseif YiConfig.movement then
					MoveToMouse()
				end
			end
end    

function OnDraw()
    if YiConfig.drawCircles then
        CustomCircle(125,4,3,myHero)
		CustomCircle(600,4,3,myHero)
        if target ~= nil then
            CustomCircle(100,4,1,target)
        end
        for i = 1, objManager:GetMaxHeroes()  do
            local enemy = objManager:GetHero(i)
            if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) then
                local qdmg = getDmg("Q",enemy,myHero)*CanUseSpell("Q")
				local admg = (myHero.baseDamage + myHero.addDamage)
                local rdmg = getDmg("R",enemy,myHero)*CanUseSpell("R")
                if enemy.health < (qdmg+rdmg+(admg*5)) then       
                    CustomCircle(500,4,2,enemy)
                    DrawTextObject("Killable", enemy, Color.Red)                    
                end
            end
        end
    end
end


YiConfig = scriptConfig("Yi Config", "Yiconf")
YiConfig:addParam("Farm", "Auto Farm", SCRIPT_PARAM_ONKEYTOGGLE, false, 88)
YiConfig:addParam("qFarm", "Q Farm", SCRIPT_PARAM_ONKEYTOGGLE, false, 89)
YiConfig:addParam("Combo", "Press Space to Win", SCRIPT_PARAM_ONKEYDOWN, false, 32)
YiConfig:addParam("Poke", "Press Z to Poke", SCRIPT_PARAM_ONKEYDOWN, false, 90)
YiConfig:addParam("drawCircles", "Kill Markers", SCRIPT_PARAM_ONOFF, false, 89)
YiConfig:addParam("movement", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)
YiConfig:addParam("autoHeal", "Auto Meditate", SCRIPT_PARAM_ONOFF, true)
YiConfig:addParam("autoAttack", "Auto Attack After Combo", SCRIPT_PARAM_ONOFF, true)
YiConfig:addParam("health", "Auto-Meditate %", SCRIPT_PARAM_NUMERICUPDOWN, 5, 72, 0, 100, 5)
YiConfig:addParam("useItems", "Use Items", SCRIPT_PARAM_ONOFF, true)
YiConfig:permaShow("Poke")
YiConfig:permaShow("autoHeal")
YiConfig:permaShow("Farm")
YiConfig:permaShow("qFarm")
YiConfig:permaShow("Combo")
YiConfig:permaShow("drawCircles")



SetTimerCallback("Run")