--[[Deadly Tristana by CCONN81
Version 1.3 updated 7/16/2013--]]

require "Utils"
require "spell_damage"
 
p = printtext
 
local target
local target2
local targetHero
local targetignite
local startAttackSpeed
local projSpeed = 1
local lastAttack = GetTickCount()
local shotFired = false
local range = myHero.range + GetDistance(GetMinBBox(myHero))
local attackDelayOffset = 600
local isMoving = false
local startAttackSpeed = 0.658
 
function OnTick()
targetReset()
KillSteal()
ProtectR()
AutoIgnite()
        if target and target.dead == 1 then target = nil end
 
        if TristanaConfig.AutoCarry and IsChatOpen() == 0 then
        CustomCircle(range,2,4,myHero)
            if target2 ~= nil then target = target2 else target = GetWeakEnemy("PHYS",range) end
                if target ~= nil then
                UseAllItems(target)
                Action() 
                castQ()
				castE()
                else
				moveToCursor()
                end
        end    
       
        if TristanaConfig.Hybrid and IsChatOpen() == 0 then
                        CustomCircle(range,2,4,myHero)
						DrawTextObject("PUSH LANE", myHero, Color.Yellow)
                        targetHero = GetWeakEnemy("PHYS",range)
            if targetHero ~= nil then
                                target = targetHero
                Action()
            else target = GetLowestHealthEnemyMinion(range) end
            if target ~= nil then
                                        Action()
                        else
								moveToCursor()
                        end
                end
                       
       
       if TristanaConfig.Farm and IsChatOpen() == 0 then
                        CustomCircle(range,2,4,myHero)
						DrawTextObject("FARM", myHero, Color.Yellow)
                        targetHero = GetWeakEnemy("PHYS",range)
            if targetHero ~= nil then
                                target = targetHero
                Action()
            else target = GetLowestHealthEnemyMinion(range) end
            if target ~= nil then
                if getDmg("AD",target,myHero) >= target.health then
                                        Action()
                end
                        else
								moveToCursor()
                        end
                end
               
        if TristanaConfig.AutoCarry or TristanaConfig.Hybrid or TristanaConfig.Farm then
		moveToCursor()
        end
       
        if TristanaConfig.Draw then
        if myHero.dead ~= 1 then
        CustomCircle(trueRange(),2,5,myHero)
        end
        end    
end
 
function OnLoad()
    if GetAAData()[myHero.name] ~= nil then
        if GetAAData()[myHero.name].projSpeed ~= nil then
            projSpeed = GetAAData()[myHero.name].projSpeed
        end
    end
    if GetAAData()[myHero.name] ~= nil then
        if GetAAData()[myHero.name].startAttackSpeed ~= nil then
            startAttackSpeed = GetAAData()[myHero.name].startAttackSpeed
        end
    end
        p("\nTrue Range: "..math.ceil(range).."\nTraditional Range: "..myHero.range)
end
 
function trueRange()
local trueRangeValue
        if target ~= nil and GetDistance(target) < range then
                trueRangeValue = range -(range-GetDistance(target))
        else
                trueRangeValue = range
        end
        return trueRangeValue
end
 
function targetReset()
        if not target and not target2 and not targetHero then
        target = nil
        target2 = nil
        targetHero = nil
        end
end
 
function Action()
        if timeToShoot() then
            attackEnemy(target)
                        CustomCircle(100,10,1,target)
        else
                        CustomCircle(100,5,2,target)
            if heroCanMove() then moveToCursor() end
        end
end
 
function attackEnemy(target)
        if ValidTarget(target) then
        AttackTarget(target)
        shotFired = True
        end
end
 
function GetNextAttackTime()
return lastAttack + attackDelayOffset / GetAttackSpeed()
end
 
function GetAttackSpeed()
return myHero.attackspeed/(1/startAttackSpeed)
end
 
function timeToShoot()
    if GetTickCount() > GetNextAttackTime() then
    return true
    end
    return false
end
 
function heroCanMove()
    if shotFired == false or timeToShoot() then
        return true
    end
    return false
end

function moveToCursor() -- Removes derping when mouse is in one position instead of myHero:MoveTo mousePos
    isMoving = true
    local moveSqr = math.sqrt((mousePos.x - myHero.x)^2+(mousePos.z - myHero.z)^2)
    local moveX = myHero.x + 300*((mousePos.x - myHero.x)/moveSqr)
    local moveZ = myHero.z + 300*((mousePos.z - myHero.z)/moveSqr)
    MoveToXYZ(moveX,0,moveZ)
end

function castQ()
	if CanCastSpell("Q") then
		CastSpellTarget("Q",myHero) 
	end
end

function castE()
	if CanCastSpell("E") then
		CastSpellTarget("E",target) 
	end
end

function castR()
    if TristanaConfig.AutoUlt then
        if CanCastSpell("R") then
            CastSpellTarget("R",target) 
        end
    end
end

function ProtectR()
	targetHero = GetWeakEnemy("PHYS",range)
	if targetHero ~= nil and GetDistance(myHero, targetHero) < 175 then
		CastSpellTarget("R", targetHero)
	end
end
 
function OnCreateObj(object)
        if GetAAData()[myHero.name] ~= nil then
                for _, v in pairs(GetAAData()[myHero.name].aaParticles) do
                        if string.find(object.charName,v)  
                                then
                                shotFired = false
                                lastAttack = GetTickCount()
                        end
                end
        end
end
 
function OnProcessSpell(obj,spell)
    if obj ~= nil and obj.name == myHero.name then
                if string.find(spell.name,"attack") then                       
                        lastAttack = GetTickCount()
                end
        end
end
 
function GetAAData()
    return {  
        Tristana     = { projSpeed = 2.25, aaParticles = {"TristannaBasicAttack_mis"}, aaSpellName = "tristanabasicattack", startAttackSpeed = "0.656",  },
    }
end

function KillSteal()
    for i = 1, objManager:GetMaxHeroes()  do
    	local enemy = objManager:GetHero(i)
    	if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) then
    		local qdmg = getDmg("Q",enemy,myHero)*CanUseSpell("Q")
			local wdmg = getDmg("W",enemy,myHero)*CanUseSpell("W")
    		local edmg = getDmg("E",enemy,myHero)*CanUseSpell("E")
    		local rdmg = getDmg("R",enemy,myHero)*CanUseSpell("R")
    		local aadmg = getDmg("AD",enemy,myHero)
        		if edmg > enemy.health and CanCastSpell("E") and GetDistance(enemy) < (range + 100) then
        		    CastSpellTarget("E",enemy)
        		end
				if wdmg > enemy.health and CanCastSpell("W") and GetDistance(enemy) < 900 then
        		    CastSpellXYZ("W",GetFireahead(enemy,2,20))
				end
				if rdmg > enemy.health and CanCastSpell("R") and GetDistance(enemy) < 645 then
					CastSpellTarget("R",enemy)
				end
				if wdmg+edmg+rdmg > enemy.health and CanCastSpell("W") and CanCastSpell("E") and CanCastSpell("R") and GetDistance(enemy) < 645 then
					CastSpellXYZ("W",GetFireahead(enemy,2,20))
					CastSpellTarget("E",enemy)
					CastSpellTarget("R",enemy)
				end
		end
	end
end

function AutoIgnite()
    local damage = (myHero.selflevel*20)+50
    if targetignite ~= nil then
        if myHero.SummonerD == "SummonerDot" then
            if targetignite.health < damage then
                    CastSpellTarget("D",targetignite)
            end
        end
        if myHero.SummonerF == "SummonerDot" then
            if targetignite.health < damage then
                    CastSpellTarget("F",targetignite)
            end
        end
    end
end
 
OnLoad()
if GetAAData()[myHero.name] ~= nil then p("\n\nAuto Carry Loaded: "..myHero.name.."\n") end
  
TristanaConfig = scriptConfig("Deadly Tristana", "Tristana")
TristanaConfig:addParam("AutoCarry", "OrbWalk", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
TristanaConfig:addParam("Hybrid", "Hybrid", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
TristanaConfig:addParam("Farm", "Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
TristanaConfig:addParam("Kite", "Kite", SCRIPT_PARAM_ONOFF, true,string.byte("O"))
TristanaConfig:addParam("Draw", "Draw Circles", SCRIPT_PARAM_ONOFF, true,string.byte("P"))

SetTimerCallback("OnTick")