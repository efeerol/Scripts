--[[
Vincent - 6:37 AM 6/7/2013
1.1 - Added Autocarry Functionality
1.2 - Increased condemn range from 300 to 400m.
1.3 - Decreased condemn range to 200, 300 and 400 were firing blanks.
1.4 - Changed hotkey.
1.5 - Integrated auto carry.
1.6 - Added Ult toggle for those who dont want to waste it.
1.7 - Added E Toggle, and 470 range for E
1.8 - Added Flexible E range, Press + on numpad to increase range to a max of 450
--]]

require "Utils"
require "spell_damage"
 
p = printtext
 
local target
local target2
local targetHero
local startAttackSpeed
local projSpeed = 1
local lastAttack = GetTickCount()
local shotFired = false
local range = myHero.range + GetDistance(GetMinBBox(myHero))
local attackDelayOffset = 275
local isMoving = false
local startAttackSpeed = 0.625
 
function OnTick()
targetReset()
        if target and target.dead == 1 then target = nil end
 
        if OrbConfig.AutoCarry and IsChatOpen() == 0 then
        CustomCircle(range,2,4,myHero)
            if target2 ~= nil then target = target2 else target = GetWeakEnemy("PHYS",range) end
                if target ~= nil then
                UseAllItems(target)
                Action()
                castR()
                castQ()
                castE()
                else
                moveToCursor()
                end
        end    
       
        if OrbConfig.Hybrid and IsChatOpen() == 0 then
                        CustomCircle(range,2,4,myHero)
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
                       
       
        if OrbConfig.Farm and IsChatOpen() == 0 then
        CustomCircle(range,2,4,myHero)
            if target2 ~= nil then target = target2 elseif GetLowestHealthEnemyMinion(range) ~= nil then target = GetLowestHealthEnemyMinion(range) end
                if target ~= nil then
                if getDmg("AD",target,myHero) >= target.health then
                Action()
                end
                else
                moveToCursor()
                end
        end
               
        if OrbConfig.AutoCarry or OrbConfig.Hybrid or OrbConfig.Farm then
        moveToCursor()
        end
       
        if OrbConfig.Draw then
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

function castQ()
	if CanCastSpell("Q") then
		CastSpellXYZ("Q",mousePos.x,0,mousePos.z) 
	end
end

function castR(target)
    if OrbConfig.AutoUlt then
        if CanCastSpell("R") then
            CastSpellTarget("R",myHero) 
        end
    end
end

function castE()
    if OrbConfig.AutoCondemn then
        if WillHitWall(target,OrbConfig.ERange) == 1 and (GetDistance(myHero, target) < 575) then
            CastSpellTarget("E", target)
        end
    end
end
 
function moveToCursor() -- Removes derping when mouse is in one position instead of myHero:MoveTo mousePos
    isMoving = true
    local moveSqr = math.sqrt((mousePos.x - myHero.x)^2+(mousePos.z - myHero.z)^2)
    local moveX = myHero.x + 300*((mousePos.x - myHero.x)/moveSqr)
    local moveZ = myHero.z + 300*((mousePos.z - myHero.z)/moveSqr)
    MoveToXYZ(moveX,0,moveZ)
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
        Vayne        = { projSpeed = 2.0, aaParticles = {"vayne_basicAttack_mis", "vayne_critAttack_mis", "vayne_ult_mis" }, aaSpellName = "vaynebasicattack", startAttackSpeed = "0.658",  },
    }
end
 
OnLoad()
if GetAAData()[myHero.name] ~= nil then p("\n\nAuto Carry Loaded: "..myHero.name.."\n") end
  
OrbConfig = scriptConfig("AutoCarry", "Orb")
OrbConfig:addParam("AutoCarry", "OrbWalk", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
OrbConfig:addParam("Hybrid", "Hybrid", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
OrbConfig:addParam("Farm", "Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
OrbConfig:addParam("Kite", "Kite", SCRIPT_PARAM_ONOFF, true,string.byte("O"))
OrbConfig:addParam("ERange", "E Range", SCRIPT_PARAM_NUMERICUPDOWN, 150, 107, 150, 450, 50)
OrbConfig:addParam("AutoUlt", "Use R in combo", SCRIPT_PARAM_ONOFF, true)
OrbConfig:addParam("AutoCondemn", "Use E in combo", SCRIPT_PARAM_ONOFF, true)
OrbConfig:addParam("Draw", "Draw Circles", SCRIPT_PARAM_ONOFF, true,string.byte("P"))
OrbConfig:permaShow("AutoCarry")
OrbConfig:permaShow("Hybrid")
OrbConfig:permaShow("Farm")

SetTimerCallback("OnTick")