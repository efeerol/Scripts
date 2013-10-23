require 'Utils'
require 'winapi'
require 'SKeys'
require "spell_damage"
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local Q,W,E,R = 'Q','W','E','R'

local version = '1.0 Directors Cut'
local target,targetaa,ulttarget
local timer2,timer3 = 0,0,0

----- CONFIG: -----
local delay = 120
local ping = 25
local dodgedelay = 500
local skillingOrder = {JarvanIV = {Q,W,E,Q,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},}
------- END -------

function KingRun()
	if IsChatOpen() == 0 and myHero.name == "JarvanIV" then
	SetVariables()
	
	if KingConfig.combo then combo() end
	if KingConfig.UseEQ then EQTarget() end
	if KingConfig.Ult then SpellTarget(R,RRDY,myHero,target,650) end
	if KingConfig.Escape then EscapeJump() end
	if KingConfig.drawcircles then KingDraw() end
	if KingConfig.drawskillshots then Skillshots() end
	if KingConfig.autolevel then Autolevel() end
	if KingConfig.ignite then ignite() end
end
end

	KingConfig, menu = uiconfig.add_menu('KING Jarvan Config', 200)
    menu.keydown('combo', 'Combo', Keys.X)
	menu.keydown('UseEQ', 'Q or EQ', Keys.Y)
	menu.keydown('Ult', 'Use Ult', Keys.R)
	menu.keydown('Escape', 'EQ Escape', Keys.T)
	menu.checkbutton('autoW', 'Auto-Shield', true)
	menu.checkbutton('ignite', 'Auto-Ignite', true)
	menu.checkbutton('autolevel', 'Auto Level', false)
	menu.checkbutton('useItems', 'Auto-Items', true)
	menu.checkbutton('movement', 'Auto-Move', true)
	menu.checkbutton('drawcircles', 'Draw Circles', true)
	menu.checkbutton('drawskillshots', 'Draw Skillshots', true)
	menu.checkbutton('dodgeskillshots', 'Dodge Skillshots', true)
	menu.checkbutton('forceskillshots', 'Force Dodge Skillshots', true)
	menu.checkbutton('forceaoeskillshots', 'Force Dodge AOE Skillshots', false)
	menu.permashow('combo')
	menu.permashow('UseEQ')
	menu.permashow('Ult')
	menu.permashow('Escape')

function combo()
	if target ~= nil then
		EQTarget()
		castQ()
	end
	if targetaa ~= nil then
		if KingConfig.useItems then
			UseAllItems(targetaa)
		end
		if KingConfig.autoW then
			SpellXYZ(W,WRDY,myHero,myHero,10,myHero.x,myHero.z)
		end
		if timer2 == 0 then AttackTarget(targetaa) end
	end
	if KingConfig.movement and timer2 == 0 then
		if target == nil then
			MoveToMouse()
		else
			MoveToXYZ(target.x, target.y, target.z)
		end
	end
end

function castQ()
	if myHero.SpellTimeQ-3.6>myHero.SpellTimeE and ERDY == 0 then 
		SpellXYZ(Q,QRDY,myHero,target,750,target.x,target.z) 
	end
end

function EscapeJump()
	local pos = getPosCursor()
	if QRDY == 1 then 
		SpellXYZ(E,ERDY,myHero,myHero,1,mousePos.x,mousePos.z) 
	end
	SpellXYZ(Q,QRDY,myHero,myHero,1,pos.x,pos.z)
end

function EQTarget()
	if target ~= nil then
		local pos = getPosTarget()
		if QRDY == 1 and ERDY == 1 then 
			SpellXYZ(E,ERDY,myHero,target,800,pos.x,pos.z) 
		end
		if QRDY == 1 then
			SpellXYZ(Q,QRDY,myHero,target,800,pos.x,pos.z) 
		end
	end
end

function getPosCursor()
	local MousePos = Vector(GetCursorWorldX(), GetCursorWorldY(), GetCursorWorldZ())
	local HeroPos = Vector(myHero.x, myHero.y, myHero.z)
	return HeroPos + ( HeroPos - MousePos )*(-800/GetDistance(HeroPos, MousePos))
end

function getPosTarget()
	local EnemyPos = Vector(target.x, target.y, target.z)
	local HeroPos = Vector(myHero.x, myHero.y, myHero.z)
	return HeroPos + ( HeroPos - EnemyPos )*(((GetDistance(HeroPos, EnemyPos)+100)*(-1))/GetDistance(HeroPos, EnemyPos))
end

function SetVariables()
	AArange = (myHero.range+(GetDistance(GetMinBBox(myHero), GetMaxBBox(myHero))/2))
	target = GetWeakEnemy('PHYS',800)
	targetaa = GetWeakEnemy('PHYS',AArange)
	ulttarget = GetWeakEnemy('PHYS',650,"ONLYNEARMOUSE")
	
	if GetTickCount() - timer2 > (((delay+ping)/myHero.attackspeed)+ping*2) then
		timer2 = 0
	end
	if GetTickCount() - timer3 > dodgedelay then
		timer3 = 0
	end	
	if targetaa ~= nil and timer2 ~= 0 then
		if GetTickCount() - timer2 > ((delay+ping)/myHero.attackspeed) then
			MoveToXYZ(myHero.x+100, myHero.y, myHero.z-100)
			MouseRightClick(GetLastOrder())
			timer2 = 0
		end
	end
	
	if myHero.SpellTimeQ>1.0 and GetSpellLevel('Q')~=0 and myHero.mana>(45+(myHero.SpellLevelQ*5)) then
	QRDY = 1
	else QRDY = 0
	end
	if myHero.SpellTimeW>1.0 and GetSpellLevel('W')~=0 and myHero.mana>55 then
	WRDY = 1
	else WRDY = 0
	end
	if myHero.SpellTimeE>1.0 and GetSpellLevel('E')~=0 and myHero.mana>50 then
	ERDY = 1
	else ERDY = 0
	end
	if myHero.SpellTimeR>1.0 and GetSpellLevel('R')~=0 and myHero.mana>(75+(myHero.SpellLevelQ*25)) then
	RRDY = 1
	else RRDY = 0
	end
end

function KingDraw()
	if QRDY == 1 and ERDY == 1 then
		CustomCircle(800,1,2,myHero)
	elseif QRDY == 1 and ERDY == 0 then
		CustomCircle(750,1,2,myHero)
	else
		CustomCircle(750,1,3,myHero)
	end
	CustomCircle(AArange,1,3,myHero)
	if target ~= nil then
		CustomCircle(100,5,2,target)
	end
end

local cc = 0
local colorcyan = 0x0000FFFF
local coloryellow = 0xFFFFFF00
local colorgreen = 0xFF00FF00
local skillshotcharexist = false
local skillshotArray = {}
local show_allies = 0

function OnProcessSpell(unit,spell)
    if unit ~= nil and spell ~= nil and unit.charName == myHero.charName then
		if spell.name == "JarvanIVBasicAttack" or spell.name == "JarvanIVBasicAttack2" or spell.name == "JarvanIVBasicAttack3" or spell.name == "JarvanIVCritAttack" and targetaa ~= nil and spell.targetaa then
			timer2 = GetTickCount()
		end
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

local metakey = SKeys.Control
local attempts = 0
local lastAttempt = 0

function Autolevel()
	local spellLevelSum = GetSpellLevel(Q) + GetSpellLevel(W) + GetSpellLevel(E) + GetSpellLevel(R)
	if attempts <= 10 or (attempts > 10 and GetTickCount() > lastAttempt+1500) then
		if spellLevelSum < myHero.selflevel then
			if lastSpellLevelSum ~= spellLevelSum then attempts = 0 end
			letter = skillingOrder[myHero.name][spellLevelSum+1]
			Level_Spell(letter, spellLevelSum)
			attempts = attempts+1
			lastAttempt = GetTickCount()
			lastSpellLevelSum = spellLevelSum
		else
			attempts = 0
		end
	end
	send.tick()
end

function Level_Spell(letter)  
     if letter == Q then send.key_press(0x69)
     elseif letter == W then send.key_press(0x6a)
     elseif letter == E then send.key_press(0x6b)
     elseif letter == R then send.key_press(0x6c) end
end

function dodgeaoe(pos1, pos2, radius)
	local calc = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
	local dodgex
	local dodgez
	dodgex = pos2.x + ((radius+50)/calc)*(myHero.x-pos2.x)
	dodgez = pos2.z + ((radius+50)/calc)*(myHero.z-pos2.z)
	if calc < radius and KingConfig.dodgeskillshots then
		if KingConfig.forceaoeskillshots then timer3 = GetTickCount() end
        MoveToXYZ(dodgex,0,dodgez)
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
	dodgex = x4 + ((radius+50)/calc3)*(myHero.x-x4)
	dodgez = z4 + ((radius+50)/calc3)*(myHero.z-z4)
	if perpendicular < radius and calc1 < calc4 and calc2 < calc4 and KingConfig.dodgeskillshots then
		if KingConfig.forceskillshots then timer3 = GetTickCount() end
        MoveToXYZ(dodgex,0,dodgez)
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
	dodgex = x4 + ((radius+50)/calc3)*(myHero.x-x4)
	dodgez = z4 + ((radius+50)/calc3)*(myHero.z-z4)
	if perpendicular < radius and calc1 < calc4 and calc2 < calc4 and KingConfig.dodgeskillshots then
		if KingConfig.forceskillshots then timer3 = GetTickCount() end
        MoveToXYZ(dodgex,0,dodgez)
	end
end

------------------------------------------------------
------------------------------------------------------

function SpellTarget(spell,cd,a,b,range)
	if cd==1 and a~=nil and b~=nil and GetDistance(a,b)<=range then
		CastSpellTarget(spell,b)
	end
end

function SpellXYZ(spell,cd,a,b,range,x,z)
	local y = 0
	if (cd == 1 or cd) and a ~= nil and b ~= nil and x ~= nil and z ~= nil and GetDistance(a,b) < range then
		CastSpellXYZ(spell,x,y,z)
	end
end

function SpellPred(spell,cd,a,b,range,delay,speed,block)
	if (cd == 1 or cd) and a ~= nil and b ~= nil and delay ~= nil and speed ~= nil and GetDistance(a,b) < range then
		if block == 1 then
			if CreepBlock(GetFireahead(b,delay,speed)) == 0 then
				CastSpellXYZ(spell,GetFireahead(b,delay,speed))
			end
		else CastSpellXYZ(spell,GetFireahead(b,delay,speed))
		end
	end
end

function distXYZ(a1,a2,b1,b2)
	if b1 == nil or b2 == nil then
		b1 = myHero.x
		b2 = myHero.z
	end
	if a2 ~= nil and b2 ~= nil and a1~=nil and b1~=nil then
		a = (b1-a1)
		b = (b2-a2)
		if a~=nil and b~=nil then
			a2=a*a
			b2=b*b
			if a2~=nil and b2~=nil then
				return math.sqrt(a2+b2)
			else
				return 99999
			end
		else
			return 99999
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
	for i=1, #skillshotArray, 1 do
		if os.clock() > (skillshotArray[i].lastshot + skillshotArray[i].time) then
		skillshotArray[i].shot = 0
		end
	end
end

function LoadTable()
	print("table loaded::")
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
		if 1==1 or skillshotplayerObj.name == "Lucian" then
			table.insert(skillshotArray,{name= "LucianQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= colorcyan, time = 0.75, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "LucianW", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "LucianR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1400, type = 1, radius = 250, color= colorcyan, time = 3, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
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
			table.insert(skillshotArray,{name= "LuxLightBinding", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1175, type = 1, radius = 225, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
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
			table.insert(skillshotArray,{name= "WildCards", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1450, type = 1, radius = 150, color= colorcyan, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
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
			table.insert(skillshotArray,{name= "VarusQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1475, type = 1, radius = 50, color= coloryellow, time = 1})
			table.insert(skillshotArray,{name= "VarusR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 150, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Veigar" then
			table.insert(skillshotArray,{name= "VeigarDarkMatter", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 225, color= coloryellow, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Viktor" then
			table.insert(skillshotArray,{name= "ViktorDeathRay", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 150, color= coloryellow, time = 2})
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

SetTimerCallback("KingRun")
print("\nVal's KING Jarvan v"..version.."\n")