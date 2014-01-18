-- Mind's Dark Yordle Veigar
require "Utils"
require "spell_damage"
printtext("\nGrasp The Event Horizon\n")

local target
local myHero = GetSelf()    
local dmg
local eSpell


function Run()
    if VeigarConfig.Farm then Farm() end
    if VeigarConfig.qFarm then qFarm() end
    if VeigarConfig.Combo then Combo() end
    if VeigarConfig.Poke then Poke() end
end
    

function Farm()
CastHotkey("ATTACK:WEAKMINION ONEHIT=1 RANGE=525")
end    

function qFarm()
if CanUseSpell("Q") then
        CastHotkey("SPELLQ:WEAKMINION RANGE=650 ONESPELLHIT=((35+spellq_level*45)+(player_ap*.6))") end
end    
    
function Poke()
local target = GetWeakEnemy('MAGIC',600,"NEARMOUSE")
	if target ~= nil then
		if GetDistance(myHero, target) < 600 and IsSpellReady("Q") then CastSpellTarget("Q", target) end
	AttackTarget(target)
        end
        if target == nil and VeigarConfig.movement then
		MoveToMouse()
	elseif target ~= nil then
		if VeigarConfig.autoAttack then
			AttackTarget(target)
		elseif VeigarConfig.movement then
			MoveToMouse()
		end
	end
end    
 
function Combo()
local target = GetWeakEnemy('MAGIC',600,"NEARMOUSE")
              if target ~= nil then
                if VeigarConfig.useItems then UseTargetItems(target) end  
					circleRadius=350 --no idea what's the real radius
					local delta = {x = target.x-myHero.x, z = target.z-myHero.z}
					dist = math.sqrt(math.pow(delta.x,2)+math.pow(delta.z,2))
					local eSpell = {x = target.x-(circleRadius/dist)*delta.x, z = target.z-(circleRadius/dist)*delta.z}
					if GetDistance(myHero, target) < 600 and IsSpellReady("E") then
					CastSpellXYZ("E",eSpell.x,0,eSpell.z) end
					if GetDistance(myHero, target) < 900 and IsSpellReady("W") then 
					CastSpellTarget("W", target) end
                    if GetDistance(myHero, target) < 650 and IsSpellReady("Q") then 
					CastSpellTarget("Q", target) end
                    if GetDistance(myHero, target) < 650 and IsSpellReady("R") then
					CastSpellTarget("R", target) end
                    AttackTarget(target)
                end
        if target == nil and VeigarConfig.movement then
				MoveToMouse()
			elseif target ~= nil then
				if VeigarConfig.autoAttack then
					AttackTarget(target)
				elseif VeigarConfig.movement then
					MoveToMouse()
				end
			end
end    

function OnDraw()
    if VeigarConfig.drawCircles then
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
				local wdmg = getDmg("W",enemy,myHero)*CanUseSpell("W")
				dmg = qdmg + wdmg
                if enemy.health < (dmg+rdmg+admg) then       
                    CustomCircle(500,4,2,enemy)
                    DrawTextObject("Killable", enemy, Color.Red)                    
                end
            end
        end
    end
end


VeigarConfig = scriptConfig("Veigar Config", "Veigarconf")
VeigarConfig:addParam("Farm", "Auto Farm", SCRIPT_PARAM_ONKEYTOGGLE, false, 88)
VeigarConfig:addParam("qFarm", "Q Farm", SCRIPT_PARAM_ONKEYTOGGLE, false, 89)
VeigarConfig:addParam("Combo", "Press Space to Win", SCRIPT_PARAM_ONKEYDOWN, false, 32)
VeigarConfig:addParam("Poke", "Press Z to Poke", SCRIPT_PARAM_ONKEYDOWN, false, 90)
VeigarConfig:addParam("drawCircles", "Kill Markers", SCRIPT_PARAM_ONOFF, false, 89)
VeigarConfig:addParam("movement", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)
VeigarConfig:addParam("autoAttack", "Auto Attack After Combo", SCRIPT_PARAM_ONOFF, true)
VeigarConfig:addParam("useItems", "Use Items", SCRIPT_PARAM_ONOFF, true)
VeigarConfig:permaShow("Poke")
VeigarConfig:permaShow("Farm")
VeigarConfig:permaShow("qFarm")
VeigarConfig:permaShow("Combo")
VeigarConfig:permaShow("drawCircles")



SetTimerCallback("Run")