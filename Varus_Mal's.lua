require "Utils"
require 'spell_damage'

require 'winapi'
require 'SKeys'
local send = require 'SendInputScheduled'

local metakey = SKeys.Control
print=printtext
printtext("\nVarus\n")
printtext("\nBy Malbert\n")
printtext("\nVersion 2.4\n")


local target600
local targetE
local target
local targetrange
local ignitedamage=0
local willDie=false
local shield=true
local lastAttack=0
local startAttackSpeed = 0.6579
local shotFired = false
local range = myHero.range + GetDistance(GetMinBBox(myHero))
local attackDelayOffset = 0.08--0.275
local isMoving = false
local Stacks={}
local QReady=true
local QTime=0
local QTimer=0
local explodeP={"1","2","3"}
local hurricane={}
local Wait=0
local Qmana=0
local explosions={}
local moveX
local moveZ
local _registry = {}


local shot=false
local shotDelay=0

local tqfxQ,tqfyQ,tqfzQ
local tqfaQ

local tqfx,tqfy,tqfz
local tqfa
			
local tefx,tefy,tefz 
local tefa

local tefxE,tefyE,tefzE 
local tefaE

local trfx,trfy,trfz 
local trfa

local trfxR,trfyR,trfzR 
local trfaR

local wUsedAt = 0
local vUsedAt = 0
local timer=os.clock()
local bluePill = nil
--------Spell Stuff
local QRDY=0
local WRDY=0
local ERDY=0
local RRDY=0

local cc = 0
local skillshotArray = { 
}
local colorcyan = 0x0000FFFF
local coloryellow = 0xFFFFFF00
local colorgreen = 0xFF00FF00
local drawskillshot = true
local dodgeskillshot = false
local playerradius = 150
local skillshotcharexist = false
local show_allies=0
     
local _registry = {}

VarusConfig = scriptConfig("Varus", "Varus Config")
VarusConfig:addParam("q", "Q Poke", SCRIPT_PARAM_ONKEYDOWN, false, 65)
VarusConfig:addParam("h", "Harass OrbWalk", SCRIPT_PARAM_ONKEYDOWN, false, 88)
VarusConfig:addParam("teamfight", "Teamfight OrbWalk", SCRIPT_PARAM_ONKEYDOWN, false, 84)
VarusConfig:addParam("f", "Farm", SCRIPT_PARAM_ONKEYDOWN, false, 67)
VarusConfig:addParam("ult", "Ult On/Off", SCRIPT_PARAM_ONOFF, true)
VarusConfig:addParam("pf", "Protect when Farming", SCRIPT_PARAM_ONKEYTOGGLE, true,57)
VarusConfig:addParam("EW", "AutoE Pop W", SCRIPT_PARAM_ONOFF, true)
VarusConfig:addParam("QW", "AutoQ Pop W", SCRIPT_PARAM_ONOFF, false)
VarusConfig:addParam('popNumber', "Stacks To Pop", SCRIPT_PARAM_NUMERICUPDOWN, 3, 48,1,3,1)
VarusConfig:addParam("ik", "Ignite KillSteal", SCRIPT_PARAM_ONOFF, true)
VarusConfig:addParam("pots", "Pots", SCRIPT_PARAM_ONOFF, true)
VarusConfig:addParam('Qdelay', "Q Delay", SCRIPT_PARAM_NUMERICUPDOWN, 1.6, 189,0,10,0.1)
VarusConfig:addParam('Edelay', "E Speed", SCRIPT_PARAM_NUMERICUPDOWN, 3.1, 187,0,10,0.1)
VarusConfig:addParam('kk', "Delay", SCRIPT_PARAM_NUMERICUPDOWN, 0.08, 119,0,1.5,0.01)
VarusConfig:addParam('RR', "R Delay", SCRIPT_PARAM_NUMERICUPDOWN, 6, 118,0,10,0.1)

VarusConfig:permaShow("teamfight")
VarusConfig:permaShow("pf")
VarusConfig:permaShow("ult")
VarusConfig:permaShow("EW")
VarusConfig:permaShow("QW")
VarusConfig:permaShow("ik")
VarusConfig:permaShow("kk")
VarusConfig:permaShow("RR")
VarusConfig:permaShow("Edelay")
VarusConfig:permaShow("Qdelay")

--Q 1.6 19.2
--E 2.25,18 
--R 3.5 19.5
local rrr=0
function tick()
	--[[kkkk=VarusConfig.kk
	if shot==true then
		if shotDelay<os.clock() then
			lastAttack = os.clock()+1/myHero.attackspeed -kkkk--math.min(kkkk,(myHero.attackspeed*attackDelayOffset/startAttackSpeed))
			shotFired = false
			shot=false
		end
	end--]]
	        ------------
        if myHero.SpellTimeQ > 1.0 and GetSpellLevel('Q') > 0 then
                QRDY = 1
                else QRDY = 0
        end
        if myHero.SpellTimeW > 1.0 and GetSpellLevel('W') > 0 then
                WRDY = 1
                else WRDY = 0
        end
        if myHero.SpellTimeE > 1.0 and GetSpellLevel('E') > 0 then
                ERDY = 1
                else ERDY = 0
        end
        if myHero.SpellTimeR > 1.0 and GetSpellLevel('R') > 0 then
                RRDY = 1
        else RRDY = 0 end
        --------------------------
	
	willDie=false
	target=GetWeakEnemy("PHYS", 1600)
	targetE=GetWeakEnemy("PHYS", 925)
	targetrange=GetWeakEnemy("PHYS", range)
	target600=GetWeakEnemy("TRUE", 600)
	Qmana=65+5*GetSpellLevel('Q')
	if targetrange~=nil then	
		local qdelay=VarusConfig.Qdelay
		local eSpeed=VarusConfig.Edelay
		local rrr=VarusConfig.RR
		tqfx,tqfy,tqfz = GetFireahead(targetrange,qdelay,19.2)
		tqfa={x=tqfx,y=tqfy,z=tqfz}
		tefx,tefy,tefz = GetFireahead(targetrange,eSpeed,18)
		tefa={x=tefx,y=tefy,z=tefz}
		trfx,trfy,trfz = GetFireahead(targetrange,rrr,19.5)
		trfa={x=trfx,y=trfy,z=trfz}
	end
	
	if target~=nil then		
		local qdelay=VarusConfig.Qdelay
		local eSpeed=VarusConfig.Edelay
		local rrr=VarusConfig.RR
		tqfxQ,tqfyQ,tqfzQ = GetFireahead(target,qdelay,19.2)
		tqfaQ={x=tqfxQ,y=tqfyQ,z=tqfzQ}
		tefxE,tefyE,tefzE = GetFireahead(target,eSpeed,18)
		tefaE={x=tefxE,y=tefyE,z=tefzE}
		trfxR,trfyR,trfzR = GetFireahead(target,rrr,19.5)
		trfa={x=trfxR,y=trfyR,z=trfzR}
	end
	
	for i=1, objManager:GetMaxHeroes(), 1 do
		hero = objManager:GetHero(i)
		if hero~=nil and hero.team~=myHero.team then
			if not Stacks[hero.name] then
				Stacks[hero.name]={name=hero.name,unit=hero,stacks=0,counter=0,stackDelay=0}
				--print("\nAdded: "..Stacks[hero.name].name)
			--table.insert(enemyInStacks,hero.name)
			end
		end
	end
	
	if myHero.dead~=1 then
		local moveSqr = math.sqrt((GetCursorWorldX() - myHero.x)^2+(GetCursorWorldZ() - myHero.z)^2)
		moveX = myHero.x + 300*((GetCursorWorldX() - myHero.x)/moveSqr)
		moveZ = myHero.z + 300*((GetCursorWorldZ() - myHero.z)/moveSqr)
	end
	if VarusConfig.pots then RedElixir() end
	checkStacks()
	--manualStacks()
	explodeStacks()
	if QReady==false then
		if QTimer<os.clock() then
			QReady=true
		end
	end
	if VarusConfig.EW and VarusConfig.QW and ERDY==1 and QRDY==1 and not VarusConfig.teamfight and not VarusConfig.q and not VarusConfig.h then EW() 
	elseif VarusConfig.EW and ERDY==1 and not VarusConfig.teamfight and not VarusConfig.q and not VarusConfig.h then EW()
	elseif VarusConfig.QW and QRDY==1 and not VarusConfig.teamfight and not VarusConfig.q and not VarusConfig.h then QW() end
	if IsChatOpen() == 0 and VarusConfig.q and target~=nil then Q(tqfaQ) --print("\n"..myHero.SpellNameQ)
	elseif IsChatOpen() == 0 and VarusConfig.q and target==nil then moveToCursor() 
	--print("\n"..myHero.SpellNameQ) 
	end
		--last() end
	if IsChatOpen() == 0 and VarusConfig.h then harass() end
	if IsChatOpen() == 0 and VarusConfig.teamfight then teamfight() end
	if IsChatOpen() == 0 and VarusConfig.f and VarusConfig.pf then 
		farm2() 
	elseif IsChatOpen() == 0 and VarusConfig.f and not VarusConfig.pf then 
		farm()
	end
	
	if IsChatOpen() == 0 and VarusConfig.ik then ignite() ik() end


	if drawskillshot == true then
        for i=1, #skillshotArray, 1 do
            if skillshotArray[i].shot == 1 then
                local radius = skillshotArray[i].radius
                local color = skillshotArray[i].color
				if skillshotArray[i].isline == false then
					for number, point in pairs(skillshotArray[i].skillshotpoint) do
						DrawCircle(point.x, point.y, point.z, radius, color)
					end
				else
					startVector = Vector(skillshotArray[i].p1x,skillshotArray[i].p1y,skillshotArray[i].p1z)
					endVector = Vector(skillshotArray[i].p2x,skillshotArray[i].p2y,skillshotArray[i].p2z)
					directionVector = (endVector-startVector):normalized()
					local angle=0
					if (math.abs(directionVector.x)<.00001) then
						if directionVector.z > 0 then angle=90
						elseif directionVector.z < 0 then angle=270
						else angle=0
						end
					else
						local theta = math.deg(math.atan(directionVector.z / directionVector.x))
						if directionVector.x < 0 then theta = theta + 180 end
						if theta < 0 then theta = theta + 360 end
						angle=theta
					end
				angle=((90-angle)*2*math.pi)/360
				DrawLine(startVector.x, startVector.y, startVector.z, GetDistance(startVector, endVector)+170, 1,angle,radius)
				end
            end
        end
    end
	for i=1, #skillshotArray, 1 do 
		if os.clock() > (skillshotArray[i].lastshot + skillshotArray[i].time) then
        	skillshotArray[i].shot = 0
    	end
    end
	
    --send.tick()
end




function checkStacks()
	if GetSpellLevel('W')>0 then
		for i, enemy in pairs(Stacks) do
			if enemy~=nil and enemy.unit~=nil and enemy.unit.dead~=1 and enemy.stacks>0 then
					--print("\n  Checking\n")
				if os.clock()>enemy.counter then
					enemy.stacks=0
					print("\n  StacksTimedOut -> "..enemy.name)
				
				end
			end
		end
		
		for i, item in pairs(hurricane) do
			if item~=nil and item.x~=nil then
				for j, enemy in pairs(Stacks) do
					if enemy~=nil and enemy.unit.dead~=1 and GetD(item,enemy.unit)<10 then
						print("\nHurricane Applied To -> "..enemy.name)
						enemy.stacks=math.min(enemy.stacks+1,4)
						enemy.counter=os.clock()+6
						enemy.stackDelay=os.clock()+0.27
					end
				end
			elseif item~=nil and item.x==nil then
				table.remove(hurricane,i)
			elseif item==nil then
				table.remove(hurricane,i)
			end
		end
	end
	
end

function manualStacks()
	if GetSpellLevel('W')>0 then
		for i, object in pairs(explodeP) do
			if object~=nil and object.x~=nil then
				for j, enemy in pairs(Stacks) do
					if enemy~=nil and enemy.unit~=nil and enemy.unit.dead~=1 and enemy.stacks>0 then
						if i==1 then
							if GetD(enemy.unit,object)<150 then enemy.stacks=0 
							print("\nQGotStacks -> "..enemy.name) 
							end
						elseif i ==2 then
							if GetD(enemy.unit,object)<20 then enemy.stacks=0 
							print("\nEGotStacks -> "..enemy.name) 
							end
						elseif i ==3 then
							if GetD(enemy.unit,object)<200 then enemy.stacks=0 
							print("\nRGotStacks -> "..enemy.name) 
							end
						end
					
					end
				end
			end
		
		end
	end
end

function EW()
	if targetE~=nil then
		local designatedTarget=nil
		for j=1, objManager:GetMaxHeroes(), 1 do
				local herotarget = objManager:GetHero(j)	
				if herotarget~=nil then
					local eSpeed=VarusConfig.Edelay
					local tefxEE,tefyEE,tefzEE = GetFireahead(herotarget,eSpeed,18)
					local tefaEE={x=tefxEE,y=tefyEE,z=tefzEE}
					if (designatedTarget==nil or designatedTarget.dead==1 or designatedTarget.visible==0) and herotarget~=nil and herotarget.team~=myHero.team and herotarget.visible==1 and herotarget.dead~=1 and GetD(tefaEE)<975 and Stacks[herotarget.name].stacks>=VarusConfig.popNumber and Stacks[herotarget.name].stackDelay<=os.clock() then
						designatedTarget=herotarget
						DT=tefaEE
					elseif designatedTarget~=nil and herotarget~=nil and herotarget.team~=myHero.team and herotarget.visible==1 and herotarget.dead~=1 and GetD(tefaEE)<975 and Stacks[herotarget.name].stacks>=VarusConfig.popNumber and Stacks[herotarget.name].stackDelay<=os.clock() and designatedTarget.health>herotarget.health then
						designatedTarget=herotarget
						DT=tefaEE
					end
				end
		end	
		if designatedTarget~=nil then

			if ERDY==1 then
				E(DT)
			end
		end
	end
end
function QW()
	if target~=nil then	
		local designatedTarget=nil
		local DT=nil
		for j=1, objManager:GetMaxHeroes(), 1 do
				local herotarget = objManager:GetHero(j)
				if herotarget~=nil then
					local qdelay=VarusConfig.Qdelay
					local dqfxQ,dqfyQ,dqfzQ = GetFireahead(herotarget,qdelay,19.2)
					local dqfaQ={x=dqfxQ,y=dqfyQ,z=dqfzQ}
					if (designatedTarget==nil or designatedTarget.dead==1 or designatedTarget.visible==0) and herotarget~=nil and herotarget.team~=myHero.team and herotarget.visible==1 and herotarget.dead~=1 and GetD(dqfaQ)<1600 and Stacks[herotarget.name].stacks>=VarusConfig.popNumber and Stacks[herotarget.name].stackDelay<=os.clock() then
						designatedTarget=herotarget
						DT=dqfaQ
					elseif designatedTarget~=nil and herotarget~=nil and herotarget.team~=myHero.team and herotarget.visible==1 and herotarget.dead~=1 and GetD(dqfaQ)<1600 and Stacks[herotarget.name].stacks>=VarusConfig.popNumber and Stacks[herotarget.name].stackDelay<=os.clock() and designatedTarget.health>herotarget.health then
						designatedTarget=herotarget
						DT=dqfaQ
					end
				end
		end	
		if designatedTarget~=nil then
			
			if QRDY==1 and (myHero.mana>Qmana or QReady==false) then
				Q(DT)
			elseif QRDY==1 and QReady==false then
				Q(DT)
			end
		end
	end
end

function teamfight()

	CustomCircle(range,2,4,myHero)
	if targetrange~=nil then
		Action()
		if VarusConfig.ult and RRDY==1 and Wait<os.clock() and GetSpellLevel('W')>0 and Stacks[targetrange.name].stacks>2 and Stacks[targetrange.name].stackDelay<=os.clock() then
			if GetD(trfa)<range+200 then
				R(trfa)
				return
			end
		elseif VarusConfig.ult and RRDY==1 and GetSpellLevel('W')==0 then
			if GetD(trfa)<range+100 then
				R(trfa)
				return
			end
		end
		if ERDY==1 and GetSpellLevel('W')>0 and Wait<os.clock() and Stacks[targetrange.name].stacks>2 and Stacks[targetrange.name].stackDelay<=os.clock() then
			if GetD(tefa)<975 then
				E(tefa)
				return
			end
		elseif ERDY==1 and GetSpellLevel('W')==0 then
			if GetD(tefa)<975 then
				E(tefa)
				return
			end
		end
		if QRDY==1 and GetSpellLevel('W')>0 and Wait<os.clock() and (myHero.mana>Qmana or QReady==false) and Stacks[targetrange.name].stacks>2 and Stacks[targetrange.name].stackDelay<=os.clock() then
			Q(tqfa)
		elseif QRDY==1 and (myHero.mana>Qmana or QReady==false) and GetSpellLevel('W')==0 then
			Q(tqfa)
		elseif QRDY==1 and QReady==false then
			Q(tqfa)
		end
		if GetD(targetrange)<600 then
			UseAllItems(target)
		end
	elseif target~=nil then
		if ERDY==1 and GetSpellLevel('W')>0 and Stacks[target.name].stacks>0 and Stacks[target.name].stackDelay<=os.clock() then
			if GetD(tefaE)<975 then
				E(tefaE)
				return
			end
		elseif ERDY==1 and (GetSpellLevel('W')==0 or runningAway(target)) then
			if GetD(tefaE)<975 then
				E(tefaE)
				return
			end
		end
		if QRDY==1 and (myHero.mana>Qmana or QReady==false) and GetSpellLevel('W')>0 and Stacks[target.name].stacks>0 and Stacks[target.name].stackDelay<=os.clock() then
			Q(tqfaQ)
		elseif QRDY==1 and (myHero.mana>Qmana or QReady==false) and (GetSpellLevel('W')==0 or runningAway(target)) then
			Q(tqfaQ)
		elseif QRDY==1 and QReady==false then
			Q(tqfaQ)
		end
		
	
	end
	moveToCursor()
end



function harass()
	
        CustomCircle(range,2,4,myHero)
		if targetrange~=nil then
			Action()
			if ERDY==1 and GetSpellLevel('W')>0 and Wait<os.clock() and Stacks[targetrange.name].stacks>2 and Stacks[targetrange.name].stackDelay<=os.clock() then
			if GetD(tefa)<975 then
				E(tefa)
				return
			end
			elseif ERDY==1 and GetSpellLevel('W')==0 then
			if GetD(tefa)<975 then
				E(tefa)
				return
			end
			end
			if QRDY==1 and (myHero.mana>Qmana or QReady==false) and Wait<os.clock() and GetSpellLevel('W')>0 and Stacks[targetrange.name].stacks>2 and Stacks[targetrange.name].stackDelay<=os.clock() then
				Q(tqfa)
			elseif QRDY==1 and (myHero.mana>Qmana or QReady==false) and GetSpellLevel('W')==0 then
				Q(tqfa)
			elseif QRDY==1 and QReady==false then
				Q(tqfa)
			end
			
			if GetD(targetrange)<600 then
				UseAllItems(target)
			end

		elseif target~=nil then
			if ERDY==1 and GetSpellLevel('W')>0 and Stacks[target.name].stacks>0 and Stacks[target.name].stackDelay<=os.clock() then
			if GetD(tefaE)<975 then
				E(tefaE)
				return
			end
			elseif ERDY==1 and (GetSpellLevel('W')==0 or runningAway(target)) then
			if GetD(tefaE)<975 then
				E(tefaE)
				return
			end
			end
			if QRDY==1 and GetSpellLevel('W')>0 and (myHero.mana>Qmana or QReady==false) and Stacks[target.name].stacks>0 and Stacks[target.name].stackDelay<=os.clock() then
				Q(tqfaQ)
			elseif QRDY==1 and (myHero.mana>Qmana or QReady==false) and (GetSpellLevel('W')==0 or runningAway(target))then
				Q(tqfaQ)
			elseif QRDY==1 and QReady==false then
				Q(tqfaQ)
			end

		
		end
		moveToCursor()
end

function farm()
	CustomCircle(range,2,4,myHero)
	if GetLowestHealthEnemyMinion(range) ~= nil then 
	targetrange = GetLowestHealthEnemyMinion(range) end
        if targetrange ~= nil then
			if getDmg("AD",targetrange,myHero)+CalcMagicDamage(targetrange,(6+4*GetSpellLevel('W'))*math.min(1,GetSpellLevel('W'))) >= targetrange.health then
				Action()
			end
			moveToCursor()
		else
			moveToCursor()
		end

end


function farm2()
	CustomCircle(range,2,4,myHero)
                        
	if targetrange ~= nil then
		Action(targetrange)
	else targetrange = GetLowestHealthEnemyMinion(range) 
	end
	if targetrange ~= nil then
		if getDmg("AD",targetrange,myHero)+CalcMagicDamage(targetrange,(6+4*GetSpellLevel('W'))*math.min(1,GetSpellLevel('W'))) >= targetrange.health then
			Action()
		end
		moveToCursor()
	else
		moveToCursor()
	end

end

function explodeStacks()
	if GetSpellLevel('W')>0 then
		for i, coord in pairs(explosions) do
			if coord~=nil and coord.x~=nil then
				print("\nStage1")
				for j, enemy in pairs(Stacks) do
					if enemy~=nil and enemy.unit~=nil and enemy.unit.dead~=1 and enemy.stacks>0 and GetD(coord,enemy.unit)<200 then
						local ok=true
				print("\nStage2")
						for p, enemy2 in pairs(Stacks) do
							if enemy.name~=enemy2.name and GetD(enemy.unit,enemy2.unit)<300 then
				print("\nStage3")
								manualStacks()
								ok=false
								break
							end
						end
						if ok==true then
							enemy.stacks=0	 
							print("\nStacksExploded -> "..enemy.name)
						end
					end
				end
				table.remove(explosions,i)
			end
		end
	end
end

--[[
function Action(j)
        if timeToShoot() then
            attackEnemy(j)
                        CustomCircle(100,10,1,j)
        else
                        CustomCircle(100,5,2,j)
            if heroCanMove() then moveToCursor() end
        end
end

function timeToShoot()
    if os.clock() > lastAttack then--lastAttack +(1*(-0.375+(0.625/startAttackSpeed))) /(myHero.attackspeed/(1/startAttackSpeed)) then
    return true
    end
    return false
end 

function attackEnemy(k)
        AttackTarget(k)
        --shotFired = true
end
--]]

function Action()
        if timeToShoot() then
            attackEnemy(targetrange)
                        CustomCircle(100,10,1,targetrange)
        else
                        CustomCircle(100,5,2,targetrange)
            if heroCanMove() then moveToCursor() end
        end
end
 
function attackEnemy(targetrange)
        if ValidTarget(targetrange) then
        AttackTarget(targetrange)
        shotFired = True
        end
end
 
function GetNextAttackTime()
return lastAttack + 275 / GetAttackSpeed()
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

function moveToCursor() 
    isMoving = true
    MoveToXYZ(moveX,0,moveZ)
end




------------------------------------------------------------------------------------------------------------
function Q(enemy)
		tx=mousePos.x
		ty=mousePos.y
		tz=mousePos.z
	if QRDY==1 then
		if GetD(enemy)<=1000 then 
			if GetD(enemy)<=1000 and QTime+6<os.clock() then
				print("\nH4")
				--run_every(1,Click,enemy)
				send.key_press(0x74)
				--QTime=os.clock()
			elseif GetD(enemy)<=1000 then
				print("\nH4.5")
				ClickSpellXYZ('Q',enemy.x,enemy.y,enemy.z,0)
				send.key_press(0x74)
			end
		elseif GetD(enemy)>1000 then
			if GetD(enemy)<1650 and QTime+6<os.clock() then
			print("\nH5")
				--run_every(1,Click,enemy)
				send.key_press(0x74)
				--QTime=os.clock()
			elseif GetD(enemy)<1650 and QTime+(1.25*(GetD(enemy)-1000)/650)<os.clock() then
			
			print("\nH6")
				ClickSpellXYZ('Q',enemy.x,enemy.y,enemy.z,0)
				send.key_press(0x74)
			end
			
		end
		
	 send.tick() 
	end
end



function E(enemy)
	if ERDY==1 and GetD(enemy)<975 then
		CastSpellXYZ('E',enemy.x,enemy.y,enemy.z)
	end
end

function R(enemy)

	if RRDY==1 and GetD(enemy)<900 then
		CastSpellXYZ('R',enemy.x,enemy.y,enemy.z)
	end

end

function Click(T)
	ClickSpellXYZ('M',T.x,T.y,T.z,0)
end


-------------------------------------------------------------------------------------------------------------
----------------------------------------------------
function OnDraw()

    if myHero.dead ~= 1 then
		if targetrange~=nil then
			CustomCircle(GetD(targetrange),2,5,myHero)
		end
		if QRDY==1 then
			
			CustomCircle(900,2,3,myHero)
			CustomCircle(1550,2,3,myHero)
			if QReady==false then
			CustomCircle(math.min(1550,900+650*(os.clock()-QTime)/1.25),10,2,myHero)
			end
		end
	end

end

function runningAway(slowtarget)
   local d1 = GetD(slowtarget)
   local x, y, z = GetFireahead(slowtarget,5,0)
   local d2 = GetD({x=x, y=y, z=z})
   local d3 = GetD({x=x, y=y, z=z},slowtarget)
   local angle = math.acos((d2*d2-d3*d3-d1*d1)/(-2*d3*d1))
   
   return angle%(2*math.pi)>math.pi/2 and angle%(2*math.pi)<math.pi*3/2

end

function ignite()
		if myHero.SummonerD == 'SummonerDot' then
			ignitedamage = ((myHero.selflevel*20)+50)*IsSpellReady('D')
		elseif myHero.SummonerF == 'SummonerDot' then
				ignitedamage = ((myHero.selflevel*20)+50)*IsSpellReady('F')
		else
				ignitedamage=0
		end
end

function ik()
	if target600~=nil and target600.health<ignitedamage then
		if myHero.SummonerD == 'SummonerDot' then
			if IsSpellReady('D') then CastSpellTarget('D',target600) end
		end
		if myHero.SummonerF == 'SummonerDot' then
			if IsSpellReady('F') then CastSpellTarget('F',target600) end
		end
	end             
end

function OnProcessSpell(unit,spell)


	if unit.name==myHero.name and unit.team==myHero.team then  
		--print("\nSpellname: "..spell.name)
		if string.find(spell.name,"VarusQ") ~= nil then --Mordeandra_E_End
			--if QReady==true then
				
				QTimer=os.clock()+4
				Wait=os.clock()+3/myHero.attackspeed+VarusConfig.Qdelay
			--elseif QReady==false then
			--	Wait=os.clock()+3
			--	QReady=true
			--end
		elseif string.find(spell.name,"VarusE") then
				Wait=os.clock()+3/myHero.attackspeed+VarusConfig.Edelay+1
		elseif string.find(spell.name,"VarusR") then
				Wait=os.clock()+3/myHero.attackspeed+VarusConfig.RR
		elseif string.find(spell.name,"ttack") and GetSpellLevel('W')>0 then  
			--shotDelay=os.clock()+kkkk--math.min(kkkk,myHero.attackspeed*attackDelayOffset/startAttackSpeed)
			--shotFired = true
			--shot=true
			--lastAttack = GetTickCount()
			if spell.target~=nil and spell.target.name~=nil and Stacks[spell.target.name] then
				--print("\nadded\n")
				Stacks[spell.target.name].stacks=math.min(Stacks[spell.target.name].stacks+1,3)
				Stacks[spell.target.name].counter=os.clock()+6
				Stacks[spell.target.name].stackDelay=os.clock()+0.275/myHero.attackspeed
				--print('\n'..0.275/myHero.attackspeed)
			end 			
			--print("\nTimeBegin: "..os.clock())
            --lastAttack = os.clock()+1/myHero.attackspeed -(myHero.attackspeed*attackDelayOffset/startAttackSpeed)
				

        end	
		


	elseif (shield==true or dodgeskillshot==true) and unit~=nil then
	local Q
	local W
	local E
	local R
		Q = unit.SpellNameQ
		W = unit.SpellNameW
		E = unit.SpellNameE
		R = unit.SpellNameR
		
		
		local P1 = spell.startPos
		local P2 = spell.endPos
		local calc = (math.floor(math.sqrt((P2.x-unit.x)^2 + (P2.z-unit.z)^2)))
		if shield==true then
		--unit.name~="Worm" and unit.name~="TT_Spiderboss7.1.1" and
		if spell ~= nil and unit.team ~= myHero.team and spell.target~=nil and spell.target.name~=nil and spell.target.name == myHero.name then
			
		--print("\nEnemySpell: "..spell.name)
		--print("\nEnemySpells: "..Q.."-"..W.."-"..E.."-"..R)
			if spell.name == Q then
				--CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
				if spellDmg[unit.name] and getDmg("Q",myHero,unit)~=nil and getDmg("Q",myHero,unit) > myHero.health then
					CastSummonerBarrier()
					CastSummonerHeal()
				end
    		
			elseif spell.name == W then
        		--CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
        		if spellDmg[unit.name] and getDmg("W",myHero,unit)~=nil and getDmg("W",myHero,unit) > myHero.health then
					
					CastSummonerBarrier()
					CastSummonerHeal()
				end
    		
			elseif spell.name == E then
   			   -- CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
    			if spellDmg[unit.name] and getDmg("E",myHero,unit)~=nil and getDmg("E",myHero,unit) > myHero.health then
					
					CastSummonerBarrier()
					CastSummonerHeal()
        		end

			elseif spell.name == R then
        		--CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
        		if spellDmg[unit.name] and getDmg("R",myHero,unit)~=nil and getDmg("R",myHero,unit) > myHero.health then
					
					CastSummonerBarrier()
					CastSummonerHeal()
        		end
    		
			elseif string.find(unit.name,"minion") == nil and string.find(unit.name,"Minion_") == nil and (spell.name:find("BasicAttack") or spell.name:find("BasicAttack2") or spell.name:find("BasicaAttack3") or spell.name:find("ChaosTurretFire")) then
        		--CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
				if (unit.baseDamage + unit.addDamage) > myHero.health then
					--print("\nMN "..unit.name)
					
					CastSummonerBarrier()
					CastSummonerHeal()
				end	
			elseif spell.name:find("BasicAttack") or spell.name:find("BasicAttack2") or spell.name:find("BasicaAttack3")  or spell.name:find("ChaosTurretFire") then
        		if (unit.baseDamage + unit.addDamage) > myHero.health then
        			--CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
					
					CastSummonerBarrier()
					CastSummonerHeal()
				end	
			elseif spell.name:find("Attack")  or spell.name:find("frostarrow") then
        		--CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
        		if 2*(unit.baseDamage + unit.addDamage) > myHero.health then
					
					CastSummonerBarrier()
					CastSummonerHeal()
				end
			
        	end
    
		end
		end
		
		if string.find(unit.name,"Minion_") == nil and string.find(unit.name,"Turret_") == nil then
			if (unit.team ~= myHero.team) and string.find(spell.name,"Basic") == nil then

				if spell.name == Q then
					if shield==true and spellDmg[unit.name] and getDmg("Q",myHero,unit)~=nil and getDmg("Q",myHero,unit) > myHero.health then
						willDie=true
					end
						for i=1, #skillshotArray, 1 do
						local maxdist
						local dodgeradius
						dodgeradius = skillshotArray[i].radius
						maxdist = skillshotArray[i].maxdistance
							if spell.name == skillshotArray[i].name then
								skillshotArray[i].shot = 1
								skillshotArray[i].lastshot = os.clock()
								if skillshotArray[i].type == 1 then
												skillshotArray[i].p1x = unit.x
												skillshotArray[i].p1y = unit.y
												skillshotArray[i].p1z = unit.z 
												skillshotArray[i].p2x = unit.x + (maxdist)/calc*(P2.x-unit.x)
												skillshotArray[i].p2y = P2.y
												skillshotArray[i].p2z = unit.z + (maxdist)/calc*(P2.z-unit.z)
									dodgelinepass(unit, P2, dodgeradius, maxdist)
								elseif skillshotArray[i].type == 2 then
									skillshotArray[i].px = P2.x
												skillshotArray[i].py = P2.y
												skillshotArray[i].pz = P2.z
									dodgelinepoint(unit, P2, dodgeradius)
								elseif skillshotArray[i].type == 3 then
									skillshotArray[i].skillshotpoint = calculateLineaoe(unit, P2, maxdist)
									if skillshotArray[i].name ~= "SummonerClairvoyance" then
										dodgeaoe(unit, P2, dodgeradius)
									end
								elseif skillshotArray[i].type == 4 then
												skillshotArray[i].px = unit.x + (maxdist)/calc*(P2.x-unit.x)
												skillshotArray[i].py = P2.y
												skillshotArray[i].pz = unit.z + (maxdist)/calc*(P2.z-unit.z)
									dodgelinepass(unit, P2, dodgeradius, maxdist)
								elseif skillshotArray[i].type == 5 then
									skillshotArray[i].skillshotpoint = calculateLineaoe2(unit, P2, maxdist)
									dodgeaoe(unit, P2, dodgeradius)
								end
							end
						end
					--end
				elseif spell.name == W then
					if shield==true and spellDmg[unit.name] and getDmg("W",myHero,unit)~=nil and getDmg("W",myHero,unit) > myHero.health then
						willDie=true
					end
						for i=1, #skillshotArray, 1 do
						local maxdist
						local dodgeradius
						dodgeradius = skillshotArray[i].radius
						maxdist = skillshotArray[i].maxdistance
							if spell.name == skillshotArray[i].name then
								skillshotArray[i].shot = 1
								skillshotArray[i].lastshot = os.clock()
								if skillshotArray[i].type == 1 then
												skillshotArray[i].p1x = unit.x
												skillshotArray[i].p1y = unit.y
												skillshotArray[i].p1z = unit.z 
												skillshotArray[i].p2x = unit.x + (maxdist)/calc*(P2.x-unit.x)
												skillshotArray[i].p2y = P2.y
												skillshotArray[i].p2z = unit.z + (maxdist)/calc*(P2.z-unit.z)
									dodgelinepass(unit, P2, dodgeradius, maxdist)
								elseif skillshotArray[i].type == 2 then
									skillshotArray[i].px = P2.x
												skillshotArray[i].py = P2.y
												skillshotArray[i].pz = P2.z
									dodgelinepoint(unit, P2, dodgeradius)
								elseif skillshotArray[i].type == 3 then
									skillshotArray[i].skillshotpoint = calculateLineaoe(unit, P2, maxdist)
									if skillshotArray[i].name ~= "SummonerClairvoyance" then
										dodgeaoe(unit, P2, dodgeradius)
									end
								elseif skillshotArray[i].type == 4 then
												skillshotArray[i].px = unit.x + (maxdist)/calc*(P2.x-unit.x)
												skillshotArray[i].py = P2.y
												skillshotArray[i].pz = unit.z + (maxdist)/calc*(P2.z-unit.z)
									dodgelinepass(unit, P2, dodgeradius, maxdist)
								elseif skillshotArray[i].type == 5 then
									skillshotArray[i].skillshotpoint = calculateLineaoe2(unit, P2, maxdist)
									dodgeaoe(unit, P2, dodgeradius)
								end
							end
						end
					--end
				elseif spell.name == E then
					if shield==true and spellDmg[unit.name] and getDmg("E",myHero,unit)~=nil and getDmg("E",myHero,unit) > myHero.health then
						willDie=true
					end
						for i=1, #skillshotArray, 1 do
						local maxdist
						local dodgeradius
						dodgeradius = skillshotArray[i].radius
						maxdist = skillshotArray[i].maxdistance
							if spell.name == skillshotArray[i].name then
								skillshotArray[i].shot = 1
								skillshotArray[i].lastshot = os.clock()
								if skillshotArray[i].type == 1 then
												skillshotArray[i].p1x = unit.x
												skillshotArray[i].p1y = unit.y
												skillshotArray[i].p1z = unit.z 
												skillshotArray[i].p2x = unit.x + (maxdist)/calc*(P2.x-unit.x)
												skillshotArray[i].p2y = P2.y
												skillshotArray[i].p2z = unit.z + (maxdist)/calc*(P2.z-unit.z)
									dodgelinepass(unit, P2, dodgeradius, maxdist)
								elseif skillshotArray[i].type == 2 then
									skillshotArray[i].px = P2.x
												skillshotArray[i].py = P2.y
												skillshotArray[i].pz = P2.z
									dodgelinepoint(unit, P2, dodgeradius)
								elseif skillshotArray[i].type == 3 then
									skillshotArray[i].skillshotpoint = calculateLineaoe(unit, P2, maxdist)
									if skillshotArray[i].name ~= "SummonerClairvoyance" then
										dodgeaoe(unit, P2, dodgeradius)
									end
								elseif skillshotArray[i].type == 4 then
												skillshotArray[i].px = unit.x + (maxdist)/calc*(P2.x-unit.x)
												skillshotArray[i].py = P2.y
												skillshotArray[i].pz = unit.z + (maxdist)/calc*(P2.z-unit.z)
									dodgelinepass(unit, P2, dodgeradius, maxdist)
								elseif skillshotArray[i].type == 5 then
									skillshotArray[i].skillshotpoint = calculateLineaoe2(unit, P2, maxdist)
									dodgeaoe(unit, P2, dodgeradius)
								end
							end
						end
					--end
				elseif spell.name == R then
					if shield==true and spellDmg[unit.name] and getDmg("R",myHero,unit)~=nil and getDmg("R",myHero,unit) > myHero.health then
						willDie=true
					end
						for i=1, #skillshotArray, 1 do
						local maxdist
						local dodgeradius
						dodgeradius = skillshotArray[i].radius
						maxdist = skillshotArray[i].maxdistance
							if spell.name == skillshotArray[i].name then
								skillshotArray[i].shot = 1
								skillshotArray[i].lastshot = os.clock()
								if skillshotArray[i].type == 1 then
												skillshotArray[i].p1x = unit.x
												skillshotArray[i].p1y = unit.y
												skillshotArray[i].p1z = unit.z 
												skillshotArray[i].p2x = unit.x + (maxdist)/calc*(P2.x-unit.x)
												skillshotArray[i].p2y = P2.y
												skillshotArray[i].p2z = unit.z + (maxdist)/calc*(P2.z-unit.z)
									dodgelinepass(unit, P2, dodgeradius, maxdist)
								elseif skillshotArray[i].type == 2 then
									skillshotArray[i].px = P2.x
												skillshotArray[i].py = P2.y
												skillshotArray[i].pz = P2.z
									dodgelinepoint(unit, P2, dodgeradius)
								elseif skillshotArray[i].type == 3 then
									skillshotArray[i].skillshotpoint = calculateLineaoe(unit, P2, maxdist)
									if skillshotArray[i].name ~= "SummonerClairvoyance" then
										dodgeaoe(unit, P2, dodgeradius)
									end
								elseif skillshotArray[i].type == 4 then
												skillshotArray[i].px = unit.x + (maxdist)/calc*(P2.x-unit.x)
												skillshotArray[i].py = P2.y
												skillshotArray[i].pz = unit.z + (maxdist)/calc*(P2.z-unit.z)
									dodgelinepass(unit, P2, dodgeradius, maxdist)
								elseif skillshotArray[i].type == 5 then
									skillshotArray[i].skillshotpoint = calculateLineaoe2(unit, P2, maxdist)
									dodgeaoe(unit, P2, dodgeradius)
								end
							end
						end
					--end
		
				end
		
			end
		end
	end
	
	
end


function OnCreateObj(object)
		--if GetD(object)<200 then -- VarusW_counter_03
		--	print("\nObjName: "..object.charName.. " TIME "..os.clock())
		--end
	
	if string.find(object.charName,"VarusWDetonate") then
		local coord={x=object.x,y=object.y,z=object.z}
		table.insert(explosions,coord)
		--[[for j, enemy in pairs(Stacks) do
				if enemy~=nil and enemy.unit.dead~=1 and enemy.stacks>0 and GetD(object,enemy.unit)<250 then
					local ok=true
					for p, enemy2 in pairs(Stacks) do
						if GetD(enemy.unit,enemy2.unit)<100 then
							manualStacks()
							ok=false
							break
						end
					end
					if ok==true then
						enemy.stacks=0	 
						print("\nStacksExploded\n\n")
					end
				end
		end--]]
	
	elseif string.find(object.charName,"VarusQ_mis") and GetD(object)<200 then
		explodeP[1]=object
		QReady=true
			--print("\nFoundQ")
	elseif string.find(object.charName,"VarusQChannel") and GetD(object)<100 then
		QReady=false
				QTime=os.clock()
				QTimer=os.clock()+4
	elseif string.find(object.charName,"VarusEMissileLong") and GetD(object)<150 then
		explodeP[2]=object
			--print("\nFoundE")
	
	elseif string.find(object.charName,"VarusRMissile") and GetD(object)<130 then
		explodeP[3]=object
			--print("\nFoundR")
	elseif string.find(object.charName,"ItemHurricane_mis") and GetD(object)<120 then
		table.insert(hurricane,object)
			--print("\nFoundH")
	
		
				--print("\nFoundH")
	end
	if GetAAData()[myHero.name] ~= nil then
                for _, v in pairs(GetAAData()[myHero.name].aaParticles) do
                        if string.find(object.charName,v)  
                                then
                                shotFired = false
                                lastAttack = GetTickCount()
                        end
                end
    end
	if (GetDistance(myHero, object)) < 100 and VarusConfig.pots then
		if string.find(object.charName,"FountainHeal") then
			timer=os.clock()
			bluePill = object
		end
	end
	

			--if string.find(object.charName,"arus_basicAttack_mis") or string.find(object.charName,"arus_critAttack_mis") then
				--shotFired = false
			--end

end


function GetAAData()
    return {  
        Varus = { projSpeed = 2.0, aaParticles = {"Varus_basicAttack_mis","Varus_critAttack_mis"}, aaSpellName = "BasicAttack", startAttackSpeed = "0.658",  },
        }
end
------------------------------------Pots

function RedElixir()
	if bluePill == nil then
		if myHero.health < 4/10*myHero.maxHealth and os.clock() > wUsedAt + 15 then
			usePotion()
			wUsedAt = os.clock()
		elseif myHero.health < 5/10*myHero.maxHealth and os.clock() > vUsedAt + 10 then 
			useFlask()
			vUsedAt = os.clock()
		elseif myHero.health < 3/10*myHero.maxHealth then
			useElixir()
		end
	end
	if (os.clock() < timer + 5) then
		bluePill = nil 
	end
end


function usePotion()
	GetInventorySlot(2003)
	UseItemOnTarget(2003,myHero)
end

function useFlask()
	GetInventorySlot(2041)
	UseItemOnTarget(2041,myHero)
end


function useElixir()
	GetInventorySlot(2037)
	UseItemOnTarget(2037,myHero)
end




function dodgeaoe(pos1, pos2, radius)
    local calc = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
	local dodgex
    local dodgez
    dodgex = pos2.x + ((radius+150)/calc)*(myHero.x-pos2.x)
    dodgez = pos2.z + ((radius+150)/calc)*(myHero.z-pos2.z)
	
	
    if calc < radius then
		if willDie==true and MordeCofig.zh and zh==true then
			
			CastSummonerBarrier()
			CastSummonerHeal()
		elseif dodgeskillshot == true then
			MoveToXYZ(dodgex,0,dodgez)
		end
        			--CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
					
    end
end

function dodgelinepoint(pos1, pos2, radius)
    local calc1 = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
    local calc2 = (math.floor(math.sqrt((pos1.x-myHero.x)^2 + (pos1.z-myHero.z)^2)))
    local calc4 = (math.floor(math.sqrt((pos1.x-pos2.x)^2 + (pos1.z-pos2.z)^2)))
    local calc3
    local perpendicular
    local k 
    local x4
    local z4
    local dodgex
    local dodgez
    perpendicular = (math.floor((math.abs((pos2.x-pos1.x)*(pos1.z-myHero.z)-(pos1.x-myHero.x)*(pos2.z-pos1.z)))/(math.sqrt((pos2.x-pos1.x)^2 + (pos2.z-pos1.z)^2))))
    k = ((pos2.z-pos1.z)*(myHero.x-pos1.x) - (pos2.x-pos1.x)*(myHero.z-pos1.z)) / ((pos2.z-pos1.z)^2 + (pos2.x-pos1.x)^2)
	x4 = myHero.x - k * (pos2.z-pos1.z)
	z4 = myHero.z + k * (pos2.x-pos1.x)
	calc3 = (math.floor(math.sqrt((x4-myHero.x)^2 + (z4-myHero.z)^2)))
	dodgex = x4 + ((radius+150)/calc3)*(myHero.x-x4)
    dodgez = z4 + ((radius+150)/calc3)*(myHero.z-z4)
    if perpendicular < radius and calc1 < calc4 and calc2 < calc4 then
		if willDie==true and MordeCofig.zh and zh==true then
			
			CastSummonerBarrier()
			CastSummonerHeal()
		elseif dodgeskillshot == true then
			MoveToXYZ(dodgex,0,dodgez)
		end
    end
end

function dodgelinepass(pos1, pos2, radius, maxDist)
	local pm2x = pos1.x + (maxDist)/(math.floor(math.sqrt((pos1.x-pos2.x)^2 + (pos1.z-pos2.z)^2)))*(pos2.x-pos1.x)
    local pm2z = pos1.z + (maxDist)/(math.floor(math.sqrt((pos1.x-pos2.x)^2 + (pos1.z-pos2.z)^2)))*(pos2.z-pos1.z)
    local calc1 = (math.floor(math.sqrt((pm2x-myHero.x)^2 + (pm2z-myHero.z)^2)))
    local calc2 = (math.floor(math.sqrt((pos1.x-myHero.x)^2 + (pos1.z-myHero.z)^2)))
    local calc3
    local calc4 = (math.floor(math.sqrt((pos1.x-pm2x)^2 + (pos1.z-pm2z)^2)))
    local perpendicular
    local k 
    local x4
    local z4
    local dodgex
    local dodgez
    perpendicular = (math.floor((math.abs((pm2x-pos1.x)*(pos1.z-myHero.z)-(pos1.x-myHero.x)*(pm2z-pos1.z)))/(math.sqrt((pm2x-pos1.x)^2 + (pm2z-pos1.z)^2))))
    k = ((pm2z-pos1.z)*(myHero.x-pos1.x) - (pm2x-pos1.x)*(myHero.z-pos1.z)) / ((pm2z-pos1.z)^2 + (pm2x-pos1.x)^2)
	x4 = myHero.x - k * (pm2z-pos1.z)
	z4 = myHero.z + k * (pm2x-pos1.x)
	calc3 = (math.floor(math.sqrt((x4-myHero.x)^2 + (z4-myHero.z)^2)))
	dodgex = x4 + ((radius+150)/calc3)*(myHero.x-x4)
    dodgez = z4 + ((radius+150)/calc3)*(myHero.z-z4)
    if perpendicular < radius and calc1 < calc4 and calc2 < calc4 then
		if willDie==true and MordeCofig.zh and zh==true then
			
			CastSummonerBarrier()
			CastSummonerHeal()
		elseif dodgeskillshot == true then
			MoveToXYZ(dodgex,0,dodgez)
		end
    end
end

function calculateLineaoe(pos1, pos2, maxDist)
    local line = {}
    local point = {}
    point.x = pos2.x
    point.y = pos2.y
    point.z = pos2.z
    table.insert(line, point)
    return line
end

function calculateLineaoe2(pos1, pos2, maxDist)
	local calc = (math.floor(math.sqrt((pos2.x-pos1.x)^2 + (pos2.z-pos1.z)^2)))
    local line = {}
    local point = {}
    if calc < maxDist then
    point.x = pos2.x
    point.y = pos2.y
    point.z = pos2.z
    table.insert(line, point)
    else
    point.x = pos1.x + maxDist/calc*(pos2.x-pos1.x)
	point.z = pos1.z + maxDist/calc*(pos2.z-pos1.z)
	point.y = pos2.y
	table.insert(line, point)
	end
    return line
end

function calculateLinepoint(pos1, pos2, spacing, maxDist)
	local line = {}
	local point1 = {}
	point1.x = pos1.x
  point1.y = pos1.y
  point1.z = pos1.z
	local point2 = {}
	point1.x = pos2.x
  point1.y = pos2.y
  point1.z = pos2.z
				table.insert(line, point2)
        table.insert(line, point1)
    return line
end


function run_every(interval, fn, ...)
    return internal_run({fn=fn, interval=interval}, ...)
end

function internal_run(t, ...)    
    local fn = t.fn
    local key = t.key or fn
   
    local now = os.clock()
    local data = _registry[key]
       
    if data == nil or t.reset then
        local args = {}
        local n = select('#', ...)
        local v
        for i=1,n do
            v = select(i, ...)
            table.insert(args, v)
        end      
        data = {count=0, last=0, complete=false, t=t, args=args}
        _registry[key] = data
    end
       
    local countCheck = (t.count==nil or data.count < t.count)
    local startCheck = (data.t.start==nil or now >= data.t.start)
    local intervalCheck = (t.interval==nil or now-data.last >= t.interval)
    if not data.complete and countCheck and startCheck and intervalCheck then                
        if t.count ~= nil then 
            data.count = data.count + 1
        end
        data.last = now        
       
        if t._while==nil and t._until==nil then
            return fn(...)
        else
            local signal = t._until ~= nil
            local checker = t._while or t._until
            local result
            if fn == checker then            
                result = fn(...)
                if result == signal then
                    data.complete = true
                end
                return result
            else
                result = checker(...)
                if result == signal then
                    data.complete = true
                else
                    return fn(...)
                end
            end            
        end
    end    
end


function GetD(p1, p2)
if p2 == nil then p2 = myHero end
if (p1.z == nil or p2.z == nil) and p1.x~=nil and p1.y ~=nil and p2.x~=nil and p2.y~=nil then
px=p1.x-p2.x
py=p1.y-p2.y
if px~=nil and py~=nil then
px2=px*px
py2=py*py
if px2~=nil and py2~=nil then
return math.sqrt(px2+py2)
else
return 99999
end
else
return 99999
end

elseif p1.x~=nil and p1.z ~=nil and p2.x~=nil and p2.z~=nil then
px=p1.x-p2.x
pz=p1.z-p2.z
if px~=nil and pz~=nil then
px2=px*px
pz2=pz*pz
if px2~=nil and pz2~=nil then
return math.sqrt(px2+pz2)
else
return 99999
end
else    
return 99999
end

else
return 99999
end
end

function run_every(interval, fn, ...)
    return internal_run({fn=fn, interval=interval}, ...)
end

function internal_run(t, ...)    
    local fn = t.fn
    local key = t.key or fn
   
    local now = os.clock()
    local data = _registry[key]
       
    if data == nil or t.reset then
        local args = {}
        local n = select('#', ...)
        local v
        for i=1,n do
            v = select(i, ...)
            table.insert(args, v)
        end  
        -- the first t and args are stored in registry        
        data = {count=0, last=0, complete=false, t=t, args=args}
        _registry[key] = data
    end
       
    --assert(data~=nil, 'data==nil')
    --assert(data.count~=nil, 'data.count==nil')
    --assert(now~=nil, 'now==nil')
    --assert(data.t~=nil, 'data.t==nil')
    --assert(data.t.start~=nil, 'data.t.start==nil')
    --assert(data.last~=nil, 'data.last==nil')
    -- run
    local countCheck = (t.count==nil or data.count < t.count)
    local startCheck = (data.t.start==nil or now >= data.t.start)
    local intervalCheck = (t.interval==nil or now-data.last >= t.interval)
    --print('', 'countCheck', tostring(countCheck))
    --print('', 'startCheck', tostring(startCheck))
    --print('', 'intervalCheck', tostring(intervalCheck))
    --print('')
    if not data.complete and countCheck and startCheck and intervalCheck then                
        if t.count ~= nil then -- only increment count if count matters
            data.count = data.count + 1
        end
        data.last = now        
       
        if t._while==nil and t._until==nil then
            return fn(...)
        else
            -- while/until handling
            local signal = t._until ~= nil
            local checker = t._while or t._until
            local result
            if fn == checker then            
                result = fn(...)
                if result == signal then
                    data.complete = true
                end
                return result
            else
                result = checker(...)
                if result == signal then
                    data.complete = true
                else
                    return fn(...)
                end
            end            
        end
    end    
end

function LoadTable()
--print("table loaded::")
    local iCount=objManager:GetMaxHeroes()
--print(" heros:" .. tostring(iCount))
	iCount=1;
    for i=0, iCount, 1 do
			if 1==1 or myHero.name == "Ahri" then
		table.insert(skillshotArray,{name= "AhriOrbofDeception", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 880, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
		table.insert(skillshotArray,{name= "AhriSeduce", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Amumu" then
		table.insert(skillshotArray,{name= "BandageToss", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Anivia" then
		table.insert(skillshotArray,{name= "FlashFrostSpell", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 90, color= colorcyan, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Ashe" then
		table.insert(skillshotArray,{name= "EnchantedCrystalArrow", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 50000, type = 4, radius = 120, color= colorcyan, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Blitzcrank" then
		table.insert(skillshotArray,{name= "RocketGrabMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Brand" then
		table.insert(skillshotArray,{name= "BrandBlazeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 50, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
		table.insert(skillshotArray,{name= "BrandFissure", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Cassiopeia" then
		table.insert(skillshotArray,{name= "CassiopeiaMiasma", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 175, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "CassiopeiaNoxiousBlast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 75, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Caitlyn" then
		table.insert(skillshotArray,{name= "CaitlynEntrapmentMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 50, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "CaitlynPiltoverPeacemaker", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Corki" then
		table.insert(skillshotArray,{name= "MissileBarrageMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1225, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "MissileBarrageMissile2", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1225, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "CarpetBomb", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 2, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Chogath" then
		table.insert(skillshotArray,{name= "Rupture", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 275, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "DrMundo" then
		table.insert(skillshotArray,{name= "InfectedCleaverMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Heimerdinger" then
		table.insert(skillshotArray,{name= "CH1ConcussionGrenade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 225, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Draven" then
		table.insert(skillshotArray,{name= "DravenDoubleShot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 125, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		table.insert(skillshotArray,{name= "DravenRCast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 20000, type = 1, radius = 100, color= colorcyan, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Ezreal" then
		table.insert(skillshotArray,{name= "EzrealEssenceFluxMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		table.insert(skillshotArray,{name= "EzrealMysticShotMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		table.insert(skillshotArray,{name= "EzrealTrueshotBarrage", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 50000, type = 4, radius = 150, color= colorcyan, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		table.insert(skillshotArray,{name= "EzrealArcaneShift", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 475, type = 5, radius = 100, color= colorgreen, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Fizz" then
		table.insert(skillshotArray,{name= "FizzMarinerDoom", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1275, type = 2, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "FiddleSticks" then
		table.insert(skillshotArray,{name= "Crowstorm", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 600, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Karthus" then
		table.insert(skillshotArray,{name= "LayWaste", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 875, type = 3, radius = 150, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Galio" then
		table.insert(skillshotArray,{name= "GalioResoluteSmite", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 905, type = 3, radius = 200, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "GalioRighteousGust", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 120, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Graves" then
		table.insert(skillshotArray,{name= "GravesChargeShot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 110, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "GravesClusterShot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 750, type = 1, radius = 50, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "GravesSmokeGrenade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 3, radius = 275, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Gragas" then
		table.insert(skillshotArray,{name= "GragasBarrelRoll", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 320, color= coloryellow, time = 2.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "GragasBodySlam", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 2, radius = 60, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "GragasExplosiveCask", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 3, radius = 400, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Irelia" then
		table.insert(skillshotArray,{name= "IreliaTranscendentBlades", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 80, color= colorcyan, time = 0.8, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Janna" then
		table.insert(skillshotArray,{name= "HowlingGale", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1700, type = 1, radius = 100, color= colorcyan, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "JarvanIV" then
		table.insert(skillshotArray,{name= "JarvanIVDemacianStandard", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 830, type = 3, radius = 150, color= coloryellow, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "JarvanIVDragonStrike", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 770, type = 1, radius = 70, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "JarvanIVCataclysm", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 3, radius = 300, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Kassadin" then
		table.insert(skillshotArray,{name= "RiftWalk", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 5, radius = 150, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Katarina" then
		table.insert(skillshotArray,{name= "ShadowStep", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 3, radius = 75, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Kennen" then
		table.insert(skillshotArray,{name= "KennenShurikenHurlMissile1", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 75, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "KogMaw" then
		table.insert(skillshotArray,{name= "KogMawVoidOozeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1115, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "KogMawLivingArtillery", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2200, type = 3, radius = 200, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Leblanc" then
		table.insert(skillshotArray,{name= "LeblancSoulShackle", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "LeblancSoulShackleM", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "LeblancSlide", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "LeblancSlideM", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		table.insert(skillshotArray,{name= "leblancslidereturn", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 50, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		table.insert(skillshotArray,{name= "leblancslidereturnm", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 50, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "LeeSin" then
		table.insert(skillshotArray,{name= "BlindMonkQOne", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "BlindMonkRKick", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Leona" then
		table.insert(skillshotArray,{name= "LeonaZenithBladeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Lux" then
		table.insert(skillshotArray,{name= "LuxLightBinding", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1175, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "LuxLightStrikeKugel", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 300, color= coloryellow, time = 2.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "LuxMaliceCannon", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 3000, type = 1, radius = 80, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Lulu" then
		table.insert(skillshotArray,{name= "LuluQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 50, color= colorcyan, time = 1, isline = true, px =0, py =0 , pz =0, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Maokai" then
		table.insert(skillshotArray,{name= "MaokaiTrunkLineMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "MaokaiSapling2", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 350 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Malphite" then
		table.insert(skillshotArray,{name= "UFSlash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 325, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Malzahar" then
		table.insert(skillshotArray,{name= "AlZaharCalloftheVoid", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 100 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "AlZaharNullZone", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 250 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "MissFortune" then
		table.insert(skillshotArray,{name= "MissFortuneScattershot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 400, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Morgana" then
		table.insert(skillshotArray,{name= "DarkBindingMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "TormentedSoil", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 350, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Nautilus" then
		table.insert(skillshotArray,{name= "NautilusAnchorDrag", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 1, radius = 80, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Nidalee" then
		table.insert(skillshotArray,{name= "JavelinToss", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1500, type = 1, radius = 80, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Nocturne" then
		table.insert(skillshotArray,{name= "NocturneDuskbringer", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 80, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Olaf" then
		table.insert(skillshotArray,{name= "OlafAxeThrow", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 2, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Orianna" then
		table.insert(skillshotArray,{name= "OrianaIzunaCommand", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 825, type = 3, radius = 150, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Renekton" then
		table.insert(skillshotArray,{name= "RenektonSliceAndDice", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 450, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		table.insert(skillshotArray,{name= "renektondice", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 450, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Rumble" then
		table.insert(skillshotArray,{name= "RumbleGrenadeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		table.insert(skillshotArray,{name= "RumbleCarpetBomb", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1700, type = 1, radius = 100, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Sivir" then
		table.insert(skillshotArray,{name= "SpiralBlade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Singed" then
		table.insert(skillshotArray,{name= "MegaAdhesive", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 350, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Shen" then
		table.insert(skillshotArray,{name= "ShenShadowDash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 2, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Shaco" then
		table.insert(skillshotArray,{name= "Deceive", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 500, type = 5, radius = 100, color= colorgreen, time = 3.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Shyvana" then
		table.insert(skillshotArray,{name= "ShyvanaTransformLeap", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 80, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "ShyvanaFireballMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Skarner" then
		table.insert(skillshotArray,{name= "SkarnerFracture", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Sona" then
		table.insert(skillshotArray,{name= "SonaCrescendo", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Sejuani" then
		table.insert(skillshotArray,{name= "SejuaniGlacialPrison", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1150, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Swain" then
		table.insert(skillshotArray,{name= "SwainShadowGrasp", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 265 , color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Tryndamere" then
		table.insert(skillshotArray,{name= "Slash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 2, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Tristana" then
		table.insert(skillshotArray,{name= "RocketJump", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 200, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "TwistedFate" then
		table.insert(skillshotArray,{name= "WildCards", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1450, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Urgot" then
		table.insert(skillshotArray,{name= "UrgotHeatseekingLineMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= colorcyan, time = 0.8, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "UrgotPlasmaGrenade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 300, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Vayne" then
		table.insert(skillshotArray,{name= "VayneTumble", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 250, type = 3, radius = 100, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Varus" then
		--table.insert(skillshotArray,{name= "VarusQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1475, type = 1, radius = 50, color= coloryellow, time = 1})
		table.insert(skillshotArray,{name= "VarusR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 80, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Veigar" then
		table.insert(skillshotArray,{name= "VeigarDarkMatter", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 225, color= coloryellow, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Viktor" then
		--table.insert(skillshotArray,{name= "ViktorDeathRay", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 80, color= coloryellow, time = 2})
	end
	if 1==1 or myHero.name == "Xerath" then
		table.insert(skillshotArray,{name= "xeratharcanopulsedamage", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "xeratharcanopulsedamageextended", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		table.insert(skillshotArray,{name= "xeratharcanebarragewrapper", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "xeratharcanebarragewrapperext", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Ziggs" then
		table.insert(skillshotArray,{name= "ZiggsQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 160, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		table.insert(skillshotArray,{name= "ZiggsW", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 225 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		table.insert(skillshotArray,{name= "ZiggsE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "ZiggsR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5300, type = 3, radius = 550, color= coloryellow, time = 3, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Zyra" then
		table.insert(skillshotArray,{name= "ZyraQFissure", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 825, type = 3, radius = 275, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "ZyraGraspingRoots", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 90, color= colorcyan, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Diana" then
		table.insert(skillshotArray,{name= "DianaArc", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 205, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
				if 1==1 or myHero.name == "Syndra" then
						table.insert(skillshotArray,{name= "SyndraQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 190, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						table.insert(skillshotArray,{name= "syndrawcast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 210, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						skillshotcharexist = true
				end
				if 1==1 or myHero.name == "Khazix" then
						table.insert(skillshotArray,{name= "KhazixW", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 70, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						table.insert(skillshotArray,{name= "khazixwlong", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 400, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						table.insert(skillshotArray,{name= "KhazixE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 5, radius = 310, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						table.insert(skillshotArray,{name= "khazixelong", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 5, radius = 310, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						skillshotcharexist = true
				end
				if 1==1 or myHero.name == "Elise" then
						table.insert(skillshotArray,{name= "EliseHumanE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 80, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						skillshotcharexist = true
				end
				if 1==1 or myHero.name == "Zed" then
						table.insert(skillshotArray,{name= "ZedShuriken", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 55, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						skillshotcharexist = true
				end
				if 1==1 or myHero.name == "Nami" then
						table.insert(skillshotArray,{name= "NamiQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 875, type = 3, radius = 210, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						table.insert(skillshotArray,{name= "NamiR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2750, type = 1, radius = 335, color= coloryellow, time = 3, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						skillshotcharexist = true
				end
				if 1==1 or myHero.name == "Vi" then
						table.insert(skillshotArray,{name= "ViQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 725, type = 1, radius = 65, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						skillshotcharexist = true
				end
				if 1==1 or myHero.name == "Thresh" then
						table.insert(skillshotArray,{name= "ThreshQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 70, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						skillshotcharexist = true
				end
				if 1==1 or myHero.name == "Quinn" then
						table.insert(skillshotArray,{name= "QuinnQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1025, type = 1, radius = 150, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						skillshotcharexist = true
				end
				if 1==1 or myHero.name == "Zac" then
						table.insert(skillshotArray,{name= "ZacE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1550, type = 5, radius = 200, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						skillshotcharexist = true
				end
				if 1==1 or myHero.name == "Lissandra" then
						table.insert(skillshotArray,{name= "LissandraQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 725, type = 1, radius = 100, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						table.insert(skillshotArray,{name= "LissandraE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 120, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						skillshotcharexist = true
				end
        --end
    end
end

SetTimerCallback("tick")