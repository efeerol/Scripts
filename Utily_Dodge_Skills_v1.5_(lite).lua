require 'Utils'
require 'winapi'
require 'SKeys'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local version = '1.5 Lite'
local skillshotArray = {}
local xa = 50/1920*GetScreenX()
local xb = 1870/1920*GetScreenX()
local ya = 50/1080*GetScreenY()
local yb = 1030/1080*GetScreenY()
local cc = 0
local key = 0
--local KD = {1,2,3,4,5,6,32,9,13,16,18,112,113,114,115,116,117,118,119,120,121,122,123,46,45,36,35,34,33,97,98,99,100,101,102,103,104,105,107,109,111,106,37,39,38,40,49,50,51,52,53,54,55,56,57,48,121,189,190,188,226,220,27,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90}
local KD = {}
local debugmode = false

KD[1] = {key = 1}
KD[2] = {key = 2}
KD[3] = {key = 3}
KD[4] = {key = 4}
KD[5] = {key = 5}
KD[6] = {key = 6}
KD[7] = {key = 32}
KD[8] = {key = 9}
KD[9] = {key = 13}
KD[10] = {key = 16}
KD[11] = {key = 18}
KD[12] = {key = 112}
KD[13] = {key = 113}
KD[14] = {key = 114}
KD[15] = {key = 115}
KD[16] = {key = 116}
KD[17] = {key = 117}
KD[18] = {key = 118}
KD[19] = {key = 119}
KD[20] = {key = 120}
KD[21] = {key = 121}
KD[22] = {key = 122}
KD[23] = {key = 123}
KD[24] = {key = 46}
KD[25] = {key = 45}
KD[26] = {key = 36}
KD[27] = {key = 35}
KD[28] = {key = 34}
KD[29] = {key = 33}
KD[30] = {key = 97}
KD[31] = {key = 98}
KD[32] = {key = 99}
KD[33] = {key = 100}
KD[34] = {key = 101}
KD[35] = {key = 102}
KD[36] = {key = 103}
KD[37] = {key = 104}
KD[38] = {key = 105}
KD[39] = {key = 107}
KD[40] = {key = 109}
KD[41] = {key = 111}
KD[42] = {key = 106}
KD[43] = {key = 37}
KD[44] = {key = 39}
KD[45] = {key = 38}
KD[46] = {key = 40}
KD[47] = {key = 49}
KD[48] = {key = 50}
KD[49] = {key = 51}
KD[50] = {key = 52}
KD[51] = {key = 53}
KD[52] = {key = 54}
KD[53] = {key = 55}
KD[54] = {key = 56}
KD[55] = {key = 57}
KD[56] = {key = 48}
KD[57] = {key = 121}
KD[58] = {key = 189}
KD[59] = {key = 190}
KD[60] = {key = 188}
KD[61] = {key = 226}
KD[62] = {key = 220}
KD[63] = {key = 27}
KD[64] = {key = 65}
KD[65] = {key = 66}
KD[66] = {key = 67}
KD[67] = {key = 68}
KD[68] = {key = 69}
KD[69] = {key = 70}
KD[70] = {key = 71}
KD[71] = {key = 72}
KD[72] = {key = 73}
KD[73] = {key = 74}
KD[74] = {key = 75}
KD[75] = {key = 76}
KD[76] = {key = 77}
KD[77] = {key = 78}
KD[78] = {key = 79}
KD[79] = {key = 88}
KD[80] = {key = 81}
KD[81] = {key = 82}
KD[82] = {key = 83}
KD[83] = {key = 84}
KD[84] = {key = 85}
KD[85] = {key = 86}
KD[86] = {key = 87}
KD[87] = {key = 88}
KD[88] = {key = 89}
KD[89] = {key = 90}


function Main()
	--if tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client" then
		send.tick()
		cc=cc+1
		if cc==30 then LoadTable() end
		for i=1, #skillshotArray, 1 do
			if os.clock() > (skillshotArray[i].lastshot + skillshotArray[i].time) then
				skillshotArray[i].shot = 0
			end
		end
		Skillshots()
		
		for v=1,89 do
			if IsKeyDown(KD[v].key)==1 then
				key = 1
				break
			else
				key = 0
			end
		end
		if debugmode then
			DrawText(key,70,170,Color.Yellow)
		end
	--end
end
    
    DodgeConfig, menu = uiconfig.add_menu('DodgeSkillshot Config', 250)
    menu.checkbutton('DrawSkillShots', 'Draw Skillshots', true)
    menu.checkbutton('DodgeSkillShots', 'Dodge Skillshots', true)
    menu.checkbutton('DodgeSkillShotsAOE', 'Dodge Skillshots for AOE', true)
    menu.slider('BlockSettings', 'Block user input', 1, 2, 1, {'FixBlock','NoBlock'})
    menu.slider('BlockSettingsAOE', 'Block user input for AOE', 1, 2, 2, {'FixBlock','NoBlock'})
    menu.slider('BlockTime', 'Block imput time', 0, 1000, 750)
    menu.permashow('DrawSkillShots')
    menu.permashow('DodgeSkillShots')

function MakeStateMatch(changes)
    for scode,flag in pairs(changes) do    
        local vk = winapi.map_virtual_key(scode, 3)
        local is_down = winapi.get_async_key_state(vk)
        if flag then
            if is_down then
                send.wait(60)
                send.key_down(scode)
                send.wait(60)
            else
            end            
        else
            if is_down then
            else
                send.wait(60)
                send.key_up(scode)
                send.wait(60)
            end
        end
    end
end

function OnProcessSpell(unit,spell)
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
    dodgex = pos2.x + ((radius+50)/calc)*(myHero.x-pos2.x)
    dodgez = pos2.z + ((radius+50)/calc)*(myHero.z-pos2.z)
    if calc < radius and DodgeConfig.DodgeSkillShotsAOE == true and GetCursorX() > xa and GetCursorX() < xb and GetCursorY() > ya and GetCursorY() < yb then
		if DodgeConfig.BlockSettingsAOE == 1 then
			if key == 0 then send.block_input(true,DodgeConfig.BlockTime) end
			MoveToXYZ(dodgex,0,dodgez)
		elseif DodgeConfig.BlockSettingsAOE == 2 then
			MoveToXYZ(dodgex,0,dodgez)
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
    dodgex = x4 + ((radius+150)/calc3)*(myHero.x-x4)
    dodgez = z4 + ((radius+150)/calc3)*(myHero.z-z4)
    if perpendicular < radius and calc1 < calc4 and calc2 < calc4 and DodgeConfig.DodgeSkillShots == true and GetCursorX() > xa and GetCursorX() < xb and GetCursorY() > ya and GetCursorY() < yb then
		if DodgeConfig.BlockSettings == 1 then
			if key == 0 then send.block_input(true,DodgeConfig.BlockTime) end
			MoveToXYZ(dodgex,0,dodgez)
		elseif DodgeConfig.BlockSettings == 2 then
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
    if perpendicular < radius and calc1 < calc4 and calc2 < calc4 and DodgeConfig.DodgeSkillShots == true and GetCursorX() > xa and GetCursorX() < xb and GetCursorY() > ya and GetCursorY() < yb then
		if DodgeConfig.BlockSettings == 1 then
			if key == 0 then send.block_input(true,DodgeConfig.BlockTime) end
			MoveToXYZ(dodgex,0,dodgez)
		elseif DodgeConfig.BlockSettings == 2 then
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

function Skillshots()
    if DodgeConfig.DrawSkillShots == true then
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
end

function LoadTable()
	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if (enemy ~= nil and enemy.team ~= myHero.team) then
			if enemy.name == 'Ahri' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 880, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			end
			if enemy.name == 'Amumu' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			end
			if enemy.name == 'Anivia' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 90, color= 0x0000FFFF, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			end
			if enemy.name == 'Ashe' then
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 50000, type = 4, radius = 120, color= 0x0000FFFF, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			end
			if enemy.name == 'Blitzcrank' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 120, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			end
			if enemy.name == 'Brand' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 50, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Cassiopeia' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 125, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Caitlyn' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 50, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Corki' then
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1225, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Chogath' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 275, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Diana' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 205, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Draven' then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 125, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 1, radius = 100, color= 0x0000FFFF, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'DrMundo' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Elise' and enemy.range>300 then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Ezreal' then
				if enemy.ap>enemy.addDamage then
					table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
				elseif enemy.ap<enemy.addDamage then
					table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
				end
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 4, radius = 150, color= 0x0000FFFF, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if enemy.name == 'Fizz' then
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1275, type = 2, radius = 100, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Galio' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 905, type = 3, radius = 200, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 120, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Gragas' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 320, color= 0xFFFFFF00, time = 2.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 3, radius = 400, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Graves' then
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 110, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Hecarim' then
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 125, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Heimerdinger' then
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 225, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Janna' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1700, type = 1, radius = 100, color= 0x0000FFFF, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Jayce' and enemy.range>300 then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1500, type = 1, radius = 125, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Jinx' then
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1500, type = 1.5, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 3, radius = 225, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Karma' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Karthus' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 875, type = 3, radius = 75, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Kennen' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 75, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Khazix' then	
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 75, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })	
			end
			if enemy.name == 'KogMaw' then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1115, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2200, type = 3, radius = 200, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Leblanc' then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'LeeSin' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Leona' then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Lissandra' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 725, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Lucian' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= 0x0000FFFF, time = 0.75, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Lulu' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 50, color= 0x0000FFFF, time = 1, isline = true, px =0, py =0 , pz =0, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Lux' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1175, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 300, color= 0xFFFFFF00, time = 2.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 3000, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Malzahar' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 100 , color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 250 , color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Maokai' then
				table.insert(skillshotArray,{name= 'MaokaiTrunkLineMissile', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 350 , color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Morgana' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 100, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Nami' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 875, type = 3, radius = 210, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2750, type = 1, radius = 335, color= 0xFFFFFF00, time = 3, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Nautilus' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Nidalee' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1500, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if enemy.name == 'Olaf' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 2, radius = 100, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Orianna' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 825, type = 3, radius = 150, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if enemy.name == 'Rumble' then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 100, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1700, type = 1, radius = 100, color= 0xFFFFFF00, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if enemy.name == 'Sejuani' then
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1150, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = f, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Shen' then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 2, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if enemy.name == 'Shyvana' then
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Sivir' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Skarner' then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Sona' then
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Swain' then
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 265 , color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Syndra' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 250, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 1, radius = 100, color= 0xFFFFFF00, time = 0.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 210, color= 0x0000FFFF, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Thresh' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 160, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'TwistedFate' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1450, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Urgot' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= 0x0000FFFF, time = 0.8, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 300, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if enemy.name == 'Varus' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1475, type = 1, radius = 50, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Veigar' then
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 225, color= 0xFFFFFF00, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if enemy.name == 'Velkoz' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 225, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Vi' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 725, type = 1, radius = 75, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Viktor' then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 80, color= 0xFFFFFF00, time = 2})
			end
			if enemy.name == 'Xerath' then
				table.insert(skillshotArray,{name= 'xeratharcanopulse2', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1450, type = 1, radius = 150, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1450, type = 3, radius = 225, color= 0xFFFFFF00, time = 0.8, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= 'xerathrmissilewrapper', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2000+(enemy.SpellLevelR+1200), type = 3, radius = 75, color= 0xFFFFFF00, time = 0.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Yasuo' then
				table.insert(skillshotArray,{name= 'yasuoq3w', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 125, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Zac' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 550, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1550, type = 5, radius = 200, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Zed' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 55, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Ziggs' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 160, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 225 , color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5300, type = 3, radius = 550, color= 0xFFFFFF00, time = 3, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Zyra' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 825, type = 3, radius = 275, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 90, color= 0x0000FFFF, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
		end
	end
end

SetTimerCallback('Main')