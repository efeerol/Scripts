-- ###################################################################################################### --
-- #                                                                                                    # --
-- #                            Val's Darius - rtk217 - Deadscale revision                              # --
-- #                                                                                                    # --
-- ###################################################################################################### --
 
require "Utils"
require 'winapi'
require 'SKeys'
local send = require 'SendInputScheduled'
printtext("\nDarius\n")


local version = '1.0'
local target
local targetaa
local target2
local targetignite
local clock = GetClock()
local script_loaded=1
local hero_table = {}
local hero_table_timer = {}
local toggle_timer=os.clock()
local blood_object="darius_hemo_bleed_trail_only"
local blood_len=string.len(blood_object)
local cast_ult_timer=0
local targettimer = 0
local herotimer = 0
local MinAttTime = 50
local MaxAttTime = 900
local DebugInfo = false
local wUsedAt = 0
local vUsedAt = 0
local countdown = 0
local beeps=0
local cc = 0
local skillshotArray = {}
local colorcyan = 0x0000FFFF
local coloryellow = 0xFFFFFF00
local colorgreen = 0xFF00FF00
local skillshotcharexist = false
local show_allies=0
local iHero = GetSelf()		
local wUsedAt = 0
local vUsedAt = 0
local timer=os.clock()
local bluePill = nil

        DariusConfig = scriptConfig("Darius Config", "dariusconf")
        DariusConfig:addParam("QAA", "Use Q", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
        DariusConfig:addParam("QE", "Use E", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("E"))
        DariusConfig:addParam("Dariusdunk", "Auto Ult", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("5"))
        DariusConfig:addParam("AutoW", "Auto AA-W", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("6"))
        DariusConfig:addParam("AutoQ", "Auto Q", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("7"))
        DariusConfig:addParam("ignite", "Auto-Ignite", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("0"))
        DariusConfig:addParam("useItems", "Use Items", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("8"))
        DariusConfig:addParam("Potion", "Potion", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("9"))
        DariusConfig:addParam("HpPotion", "Potion Toggle", SCRIPT_PARAM_ONOFF, true)
        DariusConfig:addParam("Flask", "Flask Toggle", SCRIPT_PARAM_ONOFF, true)
        DariusConfig:addParam("Biscuit", "Biscuit Toggle", SCRIPT_PARAM_ONOFF, true)
        DariusConfig:addParam("Elixir", "Elixir Toggle", SCRIPT_PARAM_ONOFF, true)
        DariusConfig:addParam("PotionValue", "Potion Trigger HP", SCRIPT_PARAM_NUMERICUPDOWN, 0.75, 103, 0, 1, .1)
        DariusConfig:addParam("FlaskValue", "Flask Trigger HP", SCRIPT_PARAM_NUMERICUPDOWN, 0.74, 100, 0, 1, .1)
        DariusConfig:addParam("BiscuitValue", "Biscuit Trigger HP", SCRIPT_PARAM_NUMERICUPDOWN, 0.60, 97, 0, 1, .1)
        DariusConfig:addParam("ElixirValue", "Elixir Trigger HP", SCRIPT_PARAM_NUMERICUPDOWN, 0.30, 96, 0, 1, .1)
        DariusConfig:addParam("drawskillshot", "Draw Skillshots", SCRIPT_PARAM_ONOFF, true)
        DariusConfig:addParam("dodgekillshot", "Dodge Skillshots", SCRIPT_PARAM_ONOFF, true)
        DariusConfig:addParam("BlockInputDelay", "BlockInput Delay", SCRIPT_PARAM_NUMERICUPDOWN, 500, 113, 0, 2500, 250)
        DariusConfig:permaShow("QAA")
        DariusConfig:permaShow("QE")
        DariusConfig:permaShow("Dariusdunk")
        DariusConfig:permaShow("AutoW")
        DariusConfig:permaShow("AutoQ")
        DariusConfig:permaShow("useItems")
        DariusConfig:permaShow("ignite")
        DariusConfig:permaShow("Potion")
        DariusConfig:permaShow("BlockInputDelay")
 
function DariusRun()
        target = GetWeakEnemy('PHYS',500)
        targetaa = GetWeakEnemy('PHYS',300)
        target2 = GetWeakEnemy('PHYS',750)
        targetignite = GetWeakEnemy('TRUE',600)
        FindHit()
        AAreset()
        RedElixir()
        Skillshots()
    
        if tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client" then
        send.tick()
        end
        
        if myHero.SpellTimeQ > 1.0 and CanUseSpell("Q") == 1 then
        QRDY = true
        else QRDY = false
        end
 
        if myHero.SpellTimeW > 1.0 and CanUseSpell("W") == 1 then
        WRDY = true
        else WRDY = false
        end
 
        if myHero.SpellTimeE > 1.0 and CanUseSpell("E") == 1 then
        ERDY = true
        else ERDY = false
        end
 
        if myHero.SpellTimeR > 1.0 and CanUseSpell("R") == 1 then
        RRDY = true
        else RRDY = false
        end
        
        
        if DariusConfig.QAA then QAA() end
        if (DariusConfig.QE and IsSpellReady("E") == 1) then QE() end
        if DariusConfig.Dariusdunk then Dariusdunk() end
        if DariusConfig.AutoQ then Qspell(target) end
        if DariusConfig.useItems and target ~= nil then UseAllItems(target) end
        if DariusConfig.Potion then RedElixir() end
        if DariusConfig.ignite then ignite() end
end

function RedElixir()
	if DariusConfig.Potion and bluePill == nil then
		if iHero.health < iHero.maxHealth * DariusConfig.PotionValue and DariusConfig.HpPotion and GetClock() > wUsedAt + 15000 then
			usePotion()
			wUsedAt = GetTick()
		elseif iHero.health < iHero.maxHealth * DariusConfig.FlaskValue and DariusConfig.Flask and GetClock() > vUsedAt + 10000 then 
			useFlask()
			vUsedAt = GetTick()
		elseif iHero.health < iHero.maxHealth * DariusConfig.BiscuitValue and DariusConfig.Biscuit then
			useBiscuit()
		elseif iHero.health < iHero.maxHealth * DariusConfig.ElixirValue and DariusConfig.Elixir then
			useElixir()
		end
	end
	if (os.clock() < timer + 5000) then
		bluePill = nil 
	end
end

function OnCreateObj(obj)
        if (GetDistance(myHero, obj)) < 100 then
                if string.find(obj.charName,"FountainHeal") then
                        timer = os.clock()
                        bluePill = 1
                end
        end
end

function usePotion()
	GetInventorySlot(2003)
	UseItemOnTarget(2003,iHero)
end

function useFlask()
	GetInventorySlot(2041)
	UseItemOnTarget(2041,iHero)
end

function useBiscuit()
	GetInventorySlot(2009)
	UseItemOnTarget(2009,iHero)
end

function useElixir()
	GetInventorySlot(2037)
	UseItemOnTarget(2037,iHero)
end

function GetTick()
	return GetClock()
end

function OnDraw()
	if DariusConfig.Potion then
		DrawText("Potion Active", 100, 30, 0xFF00EE00)
	end
end

function ignite()
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
 
function FindHit()
if targetaa ~= nil and WRDY == true then
        for i = 1, objManager:GetMaxNewObjects(), 1 do
                local object = objManager:GetNewObject(i)
                local s=object.charName
                if (s ~= nil) then
                        if string.find(s,"globalhit_bloodslash") ~= nil and GetDistance(targetaa, object) < 300 then
                                targettimer = GetClock()
                                end
                        end
                end
        end
end
 
function AAreset()
        if (targettimer - herotimer > MinAttTime) and (targettimer - herotimer < MaxAttTime) then
                if targetaa ~= nil then
                        if DariusConfig.AutoW and WRDY == true and GetDistance(myHero, targetaa) < 300 then
                                CastSpellTarget("W", myHero)
                                herotimer = 0
                                targettimer = 0
                        end
                end
        end
end
 
function QAA()
                if target ~= nil then
                        Qspell(target)
                end
                if IsSpellReady("Q") == 0 then
                        if targetaa ~= nil then
                                AttackTarget(targetaa)
                        end
                end
end
 
function Qspell()
        if target ~= nil then
                if GetDistance(myHero, target) < 415 and GetDistance(myHero, target) > 275 and IsSpellReady("Q") == 1 then
                        CastSpellXYZ("Q",myHero.x, myHero.y, myHero.z)
                end
        end
end
 
function QE()
        if target ~= nil then
                if GetDistance(myHero, target) < 420 and GetDistance(myHero, target) > 275 and IsSpellReady("Q") ~= 0 then
                CastSpellXYZ("Q",myHero.x, myHero.y, myHero.z)
                CastSpellTarget("E",target)
                elseif GetDistance(myHero, target) < 535 then
                        CastSpellTarget("E", target)
                end
        end
end
 
function Dariusdunk()
	CLOCK=os.clock()
	local spellr_level=GetSpellLevel('R')
	if (CLOCK-cast_ult_timer<.3) then
		return
	end
	local p=GetSelf()
	local key=GetScriptKey();
	local max_new_objects=objManager:GetMaxNewObjects()
	local max_heroes=objManager:GetMaxHeroes()
	local player_team=p.team
	local darius_ult_base=70+spellr_level*90+.75*p.addDamage
	if (IsKeyDown(key)~=0 and CLOCK-toggle_timer>1.2 and key~=0) then
		toggle_timer=CLOCK
		script_loaded= ((script_loaded+1)%2)
	end
	if (script_loaded==1) then
		DrawText("Darius Dunk loaded",10,40,0xFF00EE00);
		if (CLOCK-toggle_timer<6) then
			DrawText("Press key again to toggle",10,50,0xFF00EE00);
		end
	else
		DrawText("Darius Dunk unloaded",10,40,0xFFFFFF00);
		return
	end
	for i = 1,max_new_objects, 1 do
		local object = objManager:GetNewObject(i)
		local s=object.charName
		if (s ~= nil) then
		local chk=string.find(s,"darius_hemo_bleed_trail_only")
		if (chk ~= nil) then
			chk=chk+blood_len
			local counter=string.sub(s,chk,chk)
			for j = 1, max_heroes, 1 do
				local h=objManager:GetHero(j)
				if (GetDistance(h,object)<10) then
					local name=h.charName
					hero_table[name]=tonumber(counter)
					hero_table_timer[name]=CLOCK
					printtext("\nhero:" .. h.name .. " x:" .. h.x .. " z:" .. h.z .. " counter:" .. counter)
				end
			end
		end
		end
	end
	for i= 1,max_heroes,1 do
		local h=objManager:GetHero(i)
		if (h.team ~= player_team and h.visible==1 and h.invulnerable==0) then
			local name=h.charName
			local stacks=hero_table[name]
			if (stacks==nil or CLOCK-hero_table_timer[name]>4.5) then
				stacks=0
			end
			if (stacks==6) then
				stacks=5
			end
			local damage=darius_ult_base*(1+stacks*.2)
			if (h.health<damage and spellr_level>0) then
				printtext("\ntarget:" .. h.name .. " damage:" .. damage .. " hp:" .. h.health)
				if (GetDistance(p,h)<475) then
					CastSpellTarget('R',h)
					cast_ult_timer=CLOCK
					break
				end
			end
		end
	end
end
 
function OnDraw()
        if cast_ult_timer + 12000 > GetClock() then
                countdown = 12000 - (GetClock() - cast_ult_timer)
                DrawText("Countdown (Sec): " .. countdown/1000,10,40,0xFF00EE00);
        end
                if myHero.dead == 0 then
                CustomCircle(500,6,3,myHero)
                if DariusConfig.QAA and QRDY == true then
                        DrawCircleObject(myHero, 275, 5)
                        DrawCircleObject(myHero, 420, 5)
                else
                        DrawCircleObject(myHero, 275, 2)
                end
        end
end

function OnProcessSpell(unit,spell)
        if spell.name == "DariusBasicAttack" or spell.name == "DariusBasicAttack2" or spell.name == "DariusCritAttack" and WRDY == true then
            herotimer = GetClock()
        end
    local P1 = spell.startPos
	local P2 = spell.endPos
	local calc = (math.floor(math.sqrt((P2.x-unit.x)^2 + (P2.z-unit.z)^2)))
	if string.find(unit.name,"Minion_") == nil and string.find(unit.name,"Turret_") == nil then
		if (unit.team ~= myHero.team or (show_allies==1)) and string.find(spell.name,"Basic") == nil then
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
		end
	end
end

function dodgeaoe(pos1, pos2, radius)
	local calc = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
	local dodgex
	local dodgez
	dodgex = pos2.x + ((radius+150)/calc)*(myHero.x-pos2.x)
	dodgez = pos2.z + ((radius+150)/calc)*(myHero.z-pos2.z)
	if calc < radius and DariusConfig.dodgekillshot == true then
		MoveToXYZ(dodgex,0,dodgez)
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
	if perpendicular < radius and calc1 < calc4 and calc2 < calc4 and DariusConfig.dodgekillshot == true then
        if DariusConfig.QAA == false and DariusConfig.QE == false then
			if DariusConfig.BlockInputDelay ~= 0 then
				send.block_input(true, DariusConfig.BlockInputDelay)
			end
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
	if perpendicular < radius and calc1 < calc4 and calc2 < calc4 and DariusConfig.dodgekillshot == true then
        if DariusConfig.QAA == false and DariusConfig.QE == false then
			if DariusConfig.BlockInputDelay ~= 0 then
				send.block_input(true, DariusConfig.BlockInputDelay)
			end
		MoveToXYZ(dodgex,0,dodgez)
		end
	end
end


function calculateLinepass(pos1, pos2, spacing, maxDist)
	local calc = (math.floor(math.sqrt((pos2.x-pos1.x)^2 + (pos2.z-pos1.z)^2)))
	local line = {}
	local point1 = {}
	point1.x = pos1.x
	point1.y = pos1.y
	point1.z = pos1.z
	local point2 = {}
	point1.x = pos1.x + (maxDist)/calc*(pos2.x-pos1.x)
	point1.y = pos2.y
	point1.z = pos1.z + (maxDist)/calc*(pos2.z-pos1.z)
	table.insert(line, point2)
	table.insert(line, point1)
	return line
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

function table_print (tt, indent, done)
	done = done or {}
	indent = indent or 0
	if type(tt) == "table" then
		local sb = {}
		for key, value in pairs (tt) do
			table.insert(sb, string.rep (" ", indent)) -- indent it
			if type (value) == "table" and not done [value] then
				done [value] = true
				table.insert(sb, "{\n");
				table.insert(sb, table_print (value, indent + 2, done))
				table.insert(sb, string.rep (" ", indent)) -- indent it
				table.insert(sb, "}\n");
			elseif "number" == type(key) then
				table.insert(sb, string.format("\"%s\"\n", tostring(value)))
			else
				table.insert(sb, string.format(
				"%s = \"%s\"\n", tostring (key), tostring(value)))
			end
		end
		return table.concat(sb)
	else
	return tt .. "\n"
	end
end

function Skillshots()
	cc=cc+1
	if (cc==30) then
		LoadTable()
	end
	if DariusConfig.drawskillshot == true then
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
end

function LoadTable()
	print("table loaded::")
	table.insert(skillshotArray,{name= "SummonerClairvoyance", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 50000, type = 3, radius = 1300, color= coloryellow, time = 6})
	local iCount=objManager:GetMaxHeroes()
	print(" heros:" .. tostring(iCount))
	iCount=1;
	for i=0, iCount, 1 do
		local skillshotplayerObj = GetSelf();
		print(" name:" .. skillshotplayerObj.name);
		if 1==1 or skillshotplayerObj.name == "Quinn" then
			table.insert(skillshotArray,{name= "QuinnQMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1025, type = 1, radius = 40, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Lissandra" then
			table.insert(skillshotArray,{name= "LissandraQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 725, type = 1, radius = 100, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "LissandraE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 100, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Zac" then
			table.insert(skillshotArray,{name= "ZacQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 550, type = 1, radius = 100, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "ZacE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1550, type = 3, radius = 200, color= colorcyan, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Syndra" then
			table.insert(skillshotArray,{name= "SyndraQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 200, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "SyndraE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 1, radius = 100, color= coloryellow, time = 0.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "syndrawcast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 200, color= colorcyan, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Jayce" then
			table.insert(skillshotArray,{name= "jayceshockblast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1470, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Nami" then
			table.insert(skillshotArray,{name= "NamiQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 875, type = 3, radius = 200, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "NamiR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2550, type = 1, radius = 350, color= colorcyan, time = 3, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Vi" then
			table.insert(skillshotArray,{name= "ViQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 150, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
			if 1==1 or skillshotplayerObj.name == "Thresh" then
			table.insert(skillshotArray,{name= "ThreshQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Khazix" then
			table.insert(skillshotArray,{name= "KhazixE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 3, radius = 200, color= colorcyan, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "KhazixW", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 120, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "khazixwlong", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "khazixelong", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 200, color= colorcyan, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Elise" then
			table.insert(skillshotArray,{name= "EliseHumanE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Zed" then
			table.insert(skillshotArray,{name= "ZedShuriken", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 100, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "ZedShadowDash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 550, type = 3, radius = 150, color= colorcyan, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "zedw2", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 550, type = 3, radius = 150, color= colorcyan, time = 0.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Ahri" then
			table.insert(skillshotArray,{name= "AhriOrbofDeception", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 880, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			table.insert(skillshotArray,{name= "AhriSeduce", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Amumu" then
			table.insert(skillshotArray,{name= "BandageToss", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Anivia" then
			table.insert(skillshotArray,{name= "FlashFrostSpell", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 90, color= colorcyan, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Ashe" then
			table.insert(skillshotArray,{name= "EnchantedCrystalArrow", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 50000, type = 4, radius = 120, color= colorcyan, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Blitzcrank" then
			table.insert(skillshotArray,{name= "RocketGrabMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Brand" then
			table.insert(skillshotArray,{name= "BrandBlazeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 70, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			table.insert(skillshotArray,{name= "BrandFissure", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Cassiopeia" then
			table.insert(skillshotArray,{name= "CassiopeiaMiasma", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 175, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "CassiopeiaNoxiousBlast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 75, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Caitlyn" then
			table.insert(skillshotArray,{name= "CaitlynEntrapmentMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 50, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "CaitlynPiltoverPeacemaker", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Corki" then
			table.insert(skillshotArray,{name= "MissileBarrageMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1225, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "MissileBarrageMissile2", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1225, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "CarpetBomb", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 2, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Chogath" then
			table.insert(skillshotArray,{name= "Rupture", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 275, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "DrMundo" then
			table.insert(skillshotArray,{name= "InfectedCleaverMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Heimerdinger" then
			table.insert(skillshotArray,{name= "CH1ConcussionGrenade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 225, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Draven" then
			table.insert(skillshotArray,{name= "DravenDoubleShot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 125, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "DravenRCast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 1, radius = 100, color= colorcyan, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Ezreal" then
			table.insert(skillshotArray,{name= "EzrealEssenceFluxMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "EzrealMysticShotMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "EzrealTrueshotBarrage", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 4, radius = 150, color= colorcyan, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "EzrealArcaneShift", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 475, type = 5, radius = 100, color= colorgreen, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Fizz" then
			table.insert(skillshotArray,{name= "FizzMarinerDoom", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1275, type = 2, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "FiddleSticks" then
			table.insert(skillshotArray,{name= "Crowstorm", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 600, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Karthus" then
			table.insert(skillshotArray,{name= "LayWaste", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 875, type = 3, radius = 150, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Galio" then
			table.insert(skillshotArray,{name= "GalioResoluteSmite", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 905, type = 3, radius = 200, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "GalioRighteousGust", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 120, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Graves" then
			table.insert(skillshotArray,{name= "GravesChargeShot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 110, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "GravesClusterShot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 750, type = 1, radius = 50, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "GravesSmokeGrenade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 3, radius = 275, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Gragas" then
			table.insert(skillshotArray,{name= "GragasBarrelRoll", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 320, color= coloryellow, time = 2.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "GragasBodySlam", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 2, radius = 60, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "GragasExplosiveCask", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 3, radius = 400, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Irelia" then
			table.insert(skillshotArray,{name= "IreliaTranscendentBlades", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 150, color= colorcyan, time = 0.8, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Janna" then
			table.insert(skillshotArray,{name= "HowlingGale", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1700, type = 1, radius = 100, color= colorcyan, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "JarvanIV" then
			table.insert(skillshotArray,{name= "JarvanIVDemacianStandard", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 830, type = 3, radius = 150, color= coloryellow, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "JarvanIVDragonStrike", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 770, type = 1, radius = 70, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "JarvanIVCataclysm", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 3, radius = 300, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Kassadin" then
			table.insert(skillshotArray,{name= "RiftWalk", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 5, radius = 150, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Katarina" then
			table.insert(skillshotArray,{name= "ShadowStep", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 3, radius = 75, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Kennen" then
			table.insert(skillshotArray,{name= "KennenShurikenHurlMissile1", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 75, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "KogMaw" then
			table.insert(skillshotArray,{name= "KogMawVoidOozeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1115, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "KogMawLivingArtillery", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2200, type = 3, radius = 200, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Leblanc" then
			table.insert(skillshotArray,{name= "LeblancSoulShackle", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "LeblancSoulShackleM", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "LeblancSlide", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "LeblancSlideM", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "leblancslidereturn", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 50, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "leblancslidereturnm", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 50, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "LeeSin" then
			table.insert(skillshotArray,{name= "BlindMonkQOne", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "BlindMonkRKick", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Leona" then
			table.insert(skillshotArray,{name= "LeonaZenithBladeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Lux" then
			table.insert(skillshotArray,{name= "LuxLightBinding", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1175, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "LuxLightStrikeKugel", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 300, color= coloryellow, time = 2.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "LuxMaliceCannon", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 3000, type = 1, radius = 180, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Lulu" then
			table.insert(skillshotArray,{name= "LuluQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 50, color= colorcyan, time = 1, isline = true, px =0, py =0 , pz =0, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Maokai" then
			table.insert(skillshotArray,{name= "MaokaiTrunkLineMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "MaokaiSapling2", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 350 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Malphite" then
			table.insert(skillshotArray,{name= "UFSlash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 325, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Malzahar" then
			table.insert(skillshotArray,{name= "AlZaharCalloftheVoid", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 100 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "AlZaharNullZone", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 250 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "MissFortune" then
			table.insert(skillshotArray,{name= "MissFortuneScattershot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 400, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Morgana" then
			table.insert(skillshotArray,{name= "DarkBindingMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 90, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "TormentedSoil", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 300, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Nautilus" then
			table.insert(skillshotArray,{name= "NautilusAnchorDrag", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 1, radius = 150, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Nidalee" then
			table.insert(skillshotArray,{name= "JavelinToss", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1500, type = 1, radius = 150, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Nocturne" then
			table.insert(skillshotArray,{name= "NocturneDuskbringer", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 150, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Olaf" then
			table.insert(skillshotArray,{name= "OlafAxeThrow", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 2, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            table.insert(skillshotArray,{name= "OlafAxeThrowCast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 2, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Orianna" then
			table.insert(skillshotArray,{name= "OrianaIzunaCommand", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 825, type = 3, radius = 150, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Renekton" then
			table.insert(skillshotArray,{name= "RenektonSliceAndDice", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 450, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "renektondice", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 450, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Rumble" then
			table.insert(skillshotArray,{name= "RumbleGrenadeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "RumbleCarpetBomb", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1700, type = 1, radius = 100, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Sivir" then
			table.insert(skillshotArray,{name= "SpiralBlade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Singed" then
			table.insert(skillshotArray,{name= "MegaAdhesive", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 350, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Shen" then
			table.insert(skillshotArray,{name= "ShenShadowDash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 2, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Shaco" then
			table.insert(skillshotArray,{name= "Deceive", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 500, type = 5, radius = 100, color= colorgreen, time = 3.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Shyvana" then
			table.insert(skillshotArray,{name= "ShyvanaTransformLeap", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 150, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "ShyvanaFireballMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Skarner" then
			table.insert(skillshotArray,{name= "SkarnerFracture", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Sona" then
			table.insert(skillshotArray,{name= "SonaCrescendo", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Sejuani" then
			table.insert(skillshotArray,{name= "SejuaniGlacialPrison", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1150, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Swain" then
			table.insert(skillshotArray,{name= "SwainShadowGrasp", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 265 , color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Tryndamere" then
			table.insert(skillshotArray,{name= "Slash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 2, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Tristana" then
			table.insert(skillshotArray,{name= "RocketJump", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 200, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "TwistedFate" then
			table.insert(skillshotArray,{name= "WildCards", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1450, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Urgot" then
			table.insert(skillshotArray,{name= "UrgotHeatseekingLineMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= colorcyan, time = 0.8, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "UrgotPlasmaGrenade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 300, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Vayne" then
			table.insert(skillshotArray,{name= "VayneTumble", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 250, type = 3, radius = 100, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Varus" then
			--table.insert(skillshotArray,{name= "VarusQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1475, type = 1, radius = 50, color= coloryellow, time = 1})
			table.insert(skillshotArray,{name= "VarusR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 150, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Veigar" then
			table.insert(skillshotArray,{name= "VeigarDarkMatter", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 225, color= coloryellow, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Viktor" then
			--table.insert(skillshotArray,{name= "ViktorDeathRay", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 150, color= coloryellow, time = 2})
		end
		if 1==1 or skillshotplayerObj.name == "Xerath" then
			table.insert(skillshotArray,{name= "xeratharcanopulsedamage", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "xeratharcanopulsedamageextended", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "xeratharcanebarragewrapper", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "xeratharcanebarragewrapperext", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Ziggs" then
			table.insert(skillshotArray,{name= "ZiggsQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 160, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "ZiggsW", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 225 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "ZiggsE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "ZiggsR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5300, type = 3, radius = 550, color= coloryellow, time = 3, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Zyra" then
			table.insert(skillshotArray,{name= "ZyraQFissure", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 825, type = 3, radius = 275, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "ZyraGraspingRoots", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 90, color= colorcyan, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Diana" then
			table.insert(skillshotArray,{name= "DianaArc", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 205, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
    end
end


 
SetTimerCallback("DariusRun")