--[[Deadly Caitlyn by CCONN81
Version 1.1 updated 7/16/2013--]]

require "Utils"
require "spell_damage"
 
p = printtext
 
local target
local target2
local target3
local target4
local targetHero
local startAttackSpeed
local projSpeed = 1
local lastAttack = GetTickCount()
local shotFired = false
local range = myHero.range + GetDistance(GetMinBBox(myHero))
local attackDelayOffset = 600
local isMoving = false
local startAttackSpeed = 0.625
 
function OnTick()
targetReset()
if CaitlynConfig.EQCombo then EQCombo() end
KillSteal()
        if target and target.dead == 1 then target = nil end
 
        if CaitlynConfig.AutoCarry and IsChatOpen() == 0 then
        CustomCircle(range,2,4,myHero)
            if target2 ~= nil then target = target2 else target = GetWeakEnemy("PHYS",range) end
                if target ~= nil then
                UseAllItems(target)
                Action() 
                Q()
				W()
                else
				moveToCursor()
                end
        end    
       
         if CaitlynConfig.Hybrid and IsChatOpen() == 0 then
                CustomCircle(range,2,4,myHero)
				DrawTextObject("PUSH LANE", myHero, Color.Yellow)
				harassQ()
                targetHero = GetWeakEnemy("PHYS",range)
            if targetHero ~= nil then
                target = targetHero
                Action()
            else target = GetLowestHealthEnemyMinion(range) end
            if target ~= nil then
                    Action()
			if HeadShotReady() and getDmg("AD",target,myHero)*2.5 >= target.health then
                    Action()
                end
                    else
						moveToCursor()
                    end
                end
                       
       
       if CaitlynConfig.Farm and IsChatOpen() == 0 then
                CustomCircle(range,2,4,myHero)
				DrawTextObject("FARM", myHero, Color.Yellow)
				harassQ()
                targetHero = GetWeakEnemy("PHYS",range)
            if targetHero ~= nil then
                target = targetHero
                Action()
            else target = GetLowestHealthEnemyMinion(range) end
            if target ~= nil then
                if getDmg("AD",target,myHero) >= target.health then
                    Action()
                end
				if HeadShotReady() and getDmg("AD",target,myHero)*2.5 >= target.health then
                    Action()
                end
					else
						moveToCursor()
                    end
            end
               
        if CaitlynConfig.AutoCarry or CaitlynConfig.Hybrid or CaitlynConfig.Farm then
		moveToCursor()
        end
       
        if CaitlynConfig.Draw then
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

function HeadShotReady()
    for i = 1, objManager:GetMaxObjects(), 1 do
        obj = objManager:GetObject(i)
        if obj~=nil and target~=nil then
			if (obj.charName:find("headshot_rdy_indicator")) and GetDistance(obj, myHero) < 100 then
                return true
            end
        end
    end
end

function harassQ()
	target3 = GetWeakEnemy("PHYS",1300)
	if target3 ~= nil then
		if CanCastSpell("Q") and GetDistance(myHero, target3) <= 1300 then
			if GetDistance(myHero, target3) > 650 then
				CastSpellXYZ('Q',GetFireahead(target3,2,16))
			end
		end
	end
end

function Q()
	if CanCastSpell("Q") and GetDistance(myHero, target) <= 1300 then
		if GetDistance(myHero, target) > 650 then
			CastSpellXYZ('Q',GetFireahead(target,2,16))
		end
	end
end

function W()
	if CanCastSpell("W") and GetDistance(myHero, target) <= 800 then
		CastSpellTarget('W',target)
	end
end

function E()
	if CanCastSpell("E") and GetDistance(myHero, target) <= 1000 then
		CastSpellXYZ('E',GetFireahead(target,2,32))
	end
end

function EQCombo()
	target4 = GetWeakEnemy("PHYS",1000)
	if target4 ~= nil then
		--if CanCastSpell("E") and CanCastSpell("Q") then
			CastSpellXYZ('E',GetFireahead(target4,2,32))
			CastSpellXYZ('Q',GetFireahead(target4,2,16))
		--[[elseif CanCastSpell("E") then
			CastSpellXYZ('E',GetFireahead(target4,2,32))
		end--]]
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
       Caitlyn      = { projSpeed = 2.5, aaParticles = {"caitlyn_basicAttack_cas", "caitlyn_headshot_tar", "caitlyn_mis_04"}, aaSpellName = "caitlynbasicattack", startAttackSpeed = "0.625" },
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
        		if qdmg > enemy.health and CanCastSpell("Q") and GetDistance(enemy) < 1300 then
        		    CastSpellXYZ("Q",GetFireahead(enemy,2,16))
				end
				if wdmg > enemy.health and CanCastSpell("W") and GetDistance(enemy) < 800 then
        		    CastSpellTarget("W",enemy)
				end
				if edmg > enemy.health and CanCastSpell("E") and GetDistance(enemy) < 1000 then
        		    CastSpellXYZ("E",GetFireahead(enemy,2,32))
        		end
				if rdmg - 47 > enemy.health and CanCastSpell("R") and GetDistance(enemy) < (1500+(500*GetSpellLevel("R"))) and GetDistance(enemy) > 650 then
					CastSpellTarget("R",enemy)
				end
				if aadmg * 1.5 > enemy.health and GetDistance(enemy) <= range then
					AttackTarget(enemy)
				end
		end
	end
end
 
OnLoad()
if GetAAData()[myHero.name] ~= nil then p("\n\nAuto Carry Loaded: "..myHero.name.."\n") end
  
CaitlynConfig = scriptConfig("Deadly Caitlyn", "Caitlyn")
CaitlynConfig:addParam("AutoCarry", "OrbWalk", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
CaitlynConfig:addParam("Hybrid", "Hybrid", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
CaitlynConfig:addParam("Farm", "Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
CaitlynConfig:addParam("EQCombo", "EQ Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
CaitlynConfig:addParam("Kite", "Kite", SCRIPT_PARAM_ONOFF, true,string.byte("O"))
CaitlynConfig:addParam("Draw", "Draw Circles", SCRIPT_PARAM_ONOFF, true,string.byte("P"))

SetTimerCallback("OnTick")