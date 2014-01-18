-- #Cass the Gorgon
require "Utils"
require "spell_damage"
printtext("\nTurning to Stone\n")

local target, poison
local CastR = 0
local counter3 = GetTickCount() - 3000
local FLEEING, CHASING, STATIONARY = 0, 1, 2
local qDmg,wDmg,eDmg,rDmg

function CassRun()
Util__OnTick()
target = GetWeakEnemy("Magic",800)
    if CassConfig.Combo then Combo() end
	if CassConfig.Poke then Poke() end	
	if CassConfig.KS then KS() end
end

function Q()
if GetDistance(myHero,target) <750 then	
				if CanCastSpell("Q") then
				local x,y,z = GetFireahead(target,6,0)
				CastSpellXYZ("Q",x,y,z)  end
			end
		end

function W()
if CanCastSpell("W") then
					local x,y,z = GetFireahead(target,2.65,25)
					CastSpellXYZ("W",x,y,z) end
						end

function E()
if poison==1 then
						if CanCastSpell("E") then -- or target.hp < getDmg("E",target,myHero) then
						CastSpellTarget("E",target) 
					end
				end
			end	
	
function R()
if GetDistance(myHero,target) < 850 then
	if CanCastSpell("R") and GetTargetDirection(target) == CHASING then
		CastSpellTarget("R",target) 
		end
		end
	end

		
function Combo()
if target == nil then
	MoveToMouse()
	else if target ~= nil then
		UseTargetItems(target)
			Q()
			W()	
			E()
			R()
		end	
	end
end

function Poke() 
	if target == nil then
		MoveToMouse()
	else if target ~= nil then	
		Q()
		E()
		end
	end
end

function mehCheck()
	if target.hp < (target.maxHealth*(.4)) then
	CastR = 1
	end
end

function GetTargetDirection()
            local distanceTarget = GetDistance(target)
            local x1, y1, z1 = GetFireahead(target,2,10)
            local distancePredicted = GetDistance({x = x1, y = y1, z = z1})
           
            return (distanceTarget > distancePredicted and CHASING or (distanceTarget < distancePredicted and FLEEING or STATIONARY))
end

function timeCheck()
		if poison == 1 and timer == 0 then	
		if GetTickCount() - counter3 > 3000 then
		poison = 0
		timer = 1
		end
	end
end	

function KS()	
	if target ~= nil then 
	qDmg = getDmg("Q", target,myHero)
	wDmg = getDmg("W", target,myHero)
	eDmg = getDmg("E", target,myHero)
	rDmg = getDmg("R", target,myHero)
	if GetDistance(myHero,target) < 700 then
	if target.health<((eDmg*2)+wDmg+qDmg+rDmg) then
				W()
		end
		if target.health<(eDmg+wDmg+qDmg+rDmg) then
				Q()
		end
		if target.health<(eDmg+qDmg) then
				E()
				E()
		end
		if target.health<(eDmg+wDmg+qDmg+rDmg) then
				R()
		end
		if target.health<(eDmg+wDmg+qDmg+rDmg) then
				AttackTarget(target)
			end
		end
	end
end
function OnDraw()
    if CassConfig.drawCircles then
        CustomCircle(myHero.range,4,3,myHero)
        if target ~= nil then
            CustomCircle(100,4,1,target)
        end
        for i = 1, objManager:GetMaxHeroes()  do
            local enemy = objManager:GetHero(i)
            if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) then
                local qdmg = getDmg("Q",enemy,myHero)*CanUseSpell("Q")
                local wdmg = getDmg("W",enemy,myHero)*CanUseSpell("W")
				local edmg = getDmg("E", enemy, myHero)*CanUseSpell("E")
                local rdmg = getDmg("R",enemy,myHero)*CanUseSpell("R")
                if enemy.health < (qdmg+wdmg+edmg+rdmg) then    
                    CustomCircle(500,4,2,enemy)
                    DrawTextObject("BURN THE WITCH", enemy, Color.Red)                    
                end
            end
        end
    end
end

function OnCreateObj(obj)
        if target ~= nil then
                if obj ~= nil and obj.charName ~= nil then
                        if (obj.charName:lower():find("global_poison")) and GetDistance(obj, target) < 50 then
                                poison = 1
								timer = 0
								counter3 = GetTickCount()
                        end
                end
        end
end

CassConfig = scriptConfig("Auto Poison", "Cassconf")
CassConfig:addParam("Combo", "Press Space to Win", SCRIPT_PARAM_ONKEYDOWN, false, 32)
CassConfig:addParam("Poke", "Press X to Poke", SCRIPT_PARAM_ONKEYDOWN, false, 88)
CassConfig:addParam("KS", "Toggle F2 To KS!", SCRIPT_PARAM_ONKEYTOGGLE, true,113)
CassConfig:addParam("drawCircles", "Kill Markers", SCRIPT_PARAM_ONOFF, false, 89)
CassConfig:permaShow("Combo")
CassConfig:permaShow("Poke")
CassConfig:permaShow("KS")
CassConfig:permaShow("drawCircles")

SetTimerCallback("CassRun")