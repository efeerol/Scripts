require 'Utils'
require 'winapi'
require 'SKeys'
require 'vals_lib'
local Q,W,E,R = 'Q','W','E','R'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local version = '1.1'
local Range, timer = 0,0
local skillshotArray = {}
local xa,xb,ya,yb,cc = 50/1920*GetScreenX(),1870/1920*GetScreenX(),50/1080*GetScreenY(),1030/1080*GetScreenY(),0

    XerathSettings, menu = uiconfig.add_menu('Xerath Settings', 250)
    menu.checkbutton('AutoQ', 'AutoQ', true)
    menu.checkbutton('AutoW', 'AutoW', true)
    menu.checkbutton('AutoE', 'AutoE', true)
    menu.checkbutton('AutoR', 'AutoR', true)
    menu.permashow('AutoQ')
    menu.permashow('AutoW')
    menu.permashow('AutoE')
    menu.permashow('AutoR')
    
    DodgeConfig, menu = uiconfig.add_menu('DodgeSkillshot Config', 250)
    menu.checkbutton('DrawSkillShots', 'Draw Skillshots', true)
    menu.checkbutton('DodgeSkillShots', 'Dodge Skillshots', true)
    menu.checkbutton('DodgeSkillShotsAOE', 'Dodge Skillshots for AOE', true)
    menu.slider('BlockSettings', 'Block user input', 1, 2, 1, {'FixBlock','NoBlock'})
    menu.slider('BlockSettingsAOE', 'Block user input for AOE', 1, 2, 2, {'FixBlock','NoBlock'})
    menu.slider('BlockTime', 'Block imput time', 0, 1000, 750)
    menu.permashow('DrawSkillShots')
    menu.permashow('DodgeSkillShots')
    
function Main()
    if IsLolActive() then
        GetCD()
        SetVariables()
        Skillshots()
        if XerathSettings.AutoQ then AutoQ() end
        if XerathSettings.AutoW then Bullseye(W,1100) end
        if XerathSettings.AutoE then AutoPrediction(E,ERDY,950,1.6,13) end
        if XerathSettings.AutoR then AutoR() end
    end
end

function SetVariables()
    target = GetWeakEnemy('MAGIC',1450)
    target2 = GetWeakEnemy('MAGIC',2000+(myHero.SpellLevelR+1200))
    if (GetTickCount()-timer)<1500 and (GetTickCount()-timer)~=0 then
        Range=750+((GetTickCount()-timer)*.467)
    elseif (GetTickCount()-timer)>1500 and (GetTickCount()-timer)<3000 then
        Range = 1450
    elseif (GetTickCount()-timer)>3000 then
        timer = 0
    end
    if QRDY==0 then Range = 0 end
end

function OnCreateObj(obj)
    if obj ~= nil then
        if string.find(obj.charName,'Xerath_Base_Q_cas_charge')~=nil and GetDistance(obj, myHero) < 100 then
            timer = GetTickCount()
        end
    end
end

function AutoQ()
    if target~=nil and QRDY==1 and Range>0 then
        XX,YY,ZZ = GetFireahead(target,550/100,0)
        if distXYZ(XX,ZZ,myHero.x,myHero.z)<Range-100 then
            CustomCircle(125,10,1,target)
            ClickSpellXYZ('Q',XX,YY,ZZ,0)
            StopMove()
        end
    end
end

function AutoR()
    if target2~=nil and IsBuffed(myHero,'Xerath_Base_R_buf') then
        StopMove()
        --XX,YY,ZZ = GetFireahead(target2,5,0)
        CustomCircle(75,30,2,target2)
        SpellPred(R,RRDY,myHero,target2,2000+(myHero.SpellLevelR+1200),5,0)
    end
end

function OnDraw()
    if myHero.dead==0 then
        if QRDY==1 then CustomCircle(1450,2,2,myHero) end
        if RRDY==1 then CustomCircle(2000+(myHero.SpellLevelR+1200),3,1,myHero) end
    end
end

function AutoPrediction(spell,cd,range,delay,speed)
    for i = 1, objManager:GetMaxHeroes() do
        local enemy = objManager:GetHero(i)
        if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0 and enemy.dead == 0) then
            if (IsBuffed(enemy,'LOC_Stun') or 
                IsBuffed(enemy,'LOC_Suppress') or 
                IsBuffed(enemy,'LOC_Taunt') or 
                IsBuffed(enemy,'LuxLightBinding') or 
                IsBuffed(enemy,'DarkBinding_tar') or 
                IsBuffed(enemy,'RunePrison') or 
                IsBuffed(enemy,'Zyra_E_sequence_root') or 
                IsBuffed(enemy,'monkey_king_ult_unit_tar_02') or 
                IsBuffed(enemy,'xenZiou_ChainAttack_03') or 
                IsBuffed(enemy,'tempkarma_spiritbindroot_tar')) and 
                GetDistance(enemy)<range then
                if CreepBlock(enemy.x,enemy.y,enemy.z,75)==0 then
                    CastSpellXYZ(spell,enemy.x,enemy.y,enemy.z)
                end
            end
            if     IsBuffed(enemy,'GLOBAL_SLOW') or IsBuffed(enemy,'Global_Slow') then
                SpellPred(spell,cd,myHero,enemy,range,delay,speed,1,75)
            end
        end
    end
end

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

function dodgeaoe(pos1, pos2, radius)
    local calc = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
    local dodgex
    local dodgez
    dodgex = pos2.x + ((radius+50)/calc)*(myHero.x-pos2.x)
    dodgez = pos2.z + ((radius+50)/calc)*(myHero.z-pos2.z)
    if calc < radius and DodgeConfig.DodgeSkillShotsAOE == true and GetCursorX() > xa and GetCursorX() < xb and GetCursorY() > ya and GetCursorY() < yb and not IsBuffed(myHero,'Xerath_Base_R_buf') then
        if DodgeConfig.BlockSettingsAOE == 1 then
            dodgetimer = GetTickCount()
            send.block_input(true,DodgeConfig.BlockTime)
            MoveToXYZ(dodgex,0,dodgez)
        elseif DodgeConfig.BlockSettingsAOE == 2 then
            dodgetimer = GetTickCount()
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
    dodgex = x4 + ((radius+100)/calc3)*(myHero.x-x4)
    dodgez = z4 + ((radius+100)/calc3)*(myHero.z-z4)
    if perpendicular < radius and calc1 < calc4 and calc2 < calc4 and DodgeConfig.DodgeSkillShots == true and GetCursorX() > xa and GetCursorX() < xb and GetCursorY() > ya and GetCursorY() < yb and not IsBuffed(myHero,'Xerath_Base_R_buf') then
        if DodgeConfig.BlockSettings == 1 then
            dodgetimer = GetTickCount()
            send.block_input(true,DodgeConfig.BlockTime)
            MoveToXYZ(dodgex,0,dodgez)
        elseif DodgeConfig.BlockSettings == 2 then
            dodgetimer = GetTickCount()
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
    dodgex = x4 + ((radius+100)/calc3)*(myHero.x-x4)
    dodgez = z4 + ((radius+100)/calc3)*(myHero.z-z4)
    if perpendicular < radius and calc1 < calc4 and calc2 < calc4 and DodgeConfig.DodgeSkillShots == true and GetCursorX() > xa and GetCursorX() < xb and GetCursorY() > ya and GetCursorY() < yb and not IsBuffed(myHero,'Xerath_Base_R_buf') then
        if DodgeConfig.BlockSettings == 1 then
            dodgetimer = GetTickCount()
            send.block_input(true,DodgeConfig.BlockTime)
            MoveToXYZ(dodgex,0,dodgez)
        elseif DodgeConfig.BlockSettings == 2 then
            dodgetimer = GetTickCount()
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
                    DrawLine(startVector.x, startVector.y, startVector.z, GetD(startVector, endVector)+170, 1,angle,radius)
                end
            end
        end
    end
end

function LoadTable()
    for i = 1, objManager:GetMaxHeroes() do
        local e = objManager:GetHero(i)
        if (e ~= nil and e.team ~= myHero.team) then
            if e.name == 'Ahri' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 880, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
            end
            if e.name == 'Amumu' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
            end
            if e.name == 'Anivia' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 90, color= 0x0000FFFF, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
            end
            if e.name == 'Ashe' then
                table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 50000, type = 4, radius = 120, color= 0x0000FFFF, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
            end
            if e.name == 'Blitzcrank' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 120, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
            end
            if e.name == 'Brand' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 50, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                table.insert(skillshotArray,{name= e.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Cassiopeia' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 125, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Caitlyn' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 50, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Corki' then
                table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1225, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Chogath' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 275, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Diana' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 205, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Draven' then
                table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 125, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 1, radius = 100, color= 0x0000FFFF, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'DrMundo' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Elise' and e.range>300 then
                table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Ezreal' then
                if e.ap>e.addDamage then
                    table.insert(skillshotArray,{name= e.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                elseif e.ap<e.addDamage then
                    table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                end
                table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 4, radius = 150, color= 0x0000FFFF, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            end
            if e.name == 'Fizz' then
                table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1275, type = 2, radius = 100, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Galio' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 905, type = 3, radius = 200, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 120, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Gragas' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 320, color= 0xFFFFFF00, time = 2.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 3, radius = 400, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Graves' then
                table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 110, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Hecarim' then
                table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 125, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Heimerdinger' then
                table.insert(skillshotArray,{name= e.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 225, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Janna' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1700, type = 1, radius = 100, color= 0x0000FFFF, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Jayce' and e.range>300 then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1500, type = 1, radius = 125, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Jinx' then
                table.insert(skillshotArray,{name= e.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1500, type = 1.5, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 3, radius = 225, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Karma' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Karthus' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 875, type = 3, radius = 75, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Kennen' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 75, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Khazix' then    
                table.insert(skillshotArray,{name= e.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 75, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })    
            end
            if e.name == 'KogMaw' then
                table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1115, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2200, type = 3, radius = 200, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Leblanc' then
                table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'LeeSin' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Leona' then
                table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Lissandra' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 725, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Lucian' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= 0x0000FFFF, time = 0.75, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= e.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Lulu' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 50, color= 0x0000FFFF, time = 1, isline = true, px =0, py =0 , pz =0, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Lux' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1175, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 300, color= 0xFFFFFF00, time = 2.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 3000, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Malzahar' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 100 , color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= e.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 250 , color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Maokai' then
                table.insert(skillshotArray,{name= 'MaokaiTrunkLineMissile', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 350 , color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Morgana' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 100, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Nami' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 875, type = 3, radius = 210, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2750, type = 1, radius = 335, color= 0xFFFFFF00, time = 3, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Nautilus' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Nidalee' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1500, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            end
            if e.name == 'Olaf' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 2, radius = 100, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Orianna' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 825, type = 3, radius = 150, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            end
            if e.name == 'Rumble' then
                table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 100, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1700, type = 1, radius = 100, color= 0xFFFFFF00, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            end
            if e.name == 'Sejuani' then
                table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1150, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = f, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Shen' then
                table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 2, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            end
            if e.name == 'Shyvana' then
                table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Sivir' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Skarner' then
                table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Sona' then
                table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Swain' then
                table.insert(skillshotArray,{name= e.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 265 , color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Syndra' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 250, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 1, radius = 100, color= 0xFFFFFF00, time = 0.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= e.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 210, color= 0x0000FFFF, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Thresh' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 160, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'TwistedFate' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1450, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Urgot' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= 0x0000FFFF, time = 0.8, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 300, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            end
            if e.name == 'Varus' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1475, type = 1, radius = 50, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Veigar' then
                table.insert(skillshotArray,{name= e.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 225, color= 0xFFFFFF00, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            end
            if e.name == 'Vi' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 725, type = 1, radius = 75, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Viktor' then
                table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 80, color= 0xFFFFFF00, time = 2})
            end
            if e.name == 'Xerath' then
                table.insert(skillshotArray,{name= 'xeratharcanopulsedamage', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= 'xeratharcanopulsedamageextended', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= 'xeratharcanebarragewrapper', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= 'xeratharcanebarragewrapperext', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 3, radius = 250, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            end
            if e.name == 'Yasuo' then
                table.insert(skillshotArray,{name= 'yasuoq3w', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 125, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Zac' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 550, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1550, type = 5, radius = 200, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Zed' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 55, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Ziggs' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 160, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= e.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 225 , color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5300, type = 3, radius = 550, color= 0xFFFFFF00, time = 3, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
            if e.name == 'Zyra' then
                table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 825, type = 3, radius = 275, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 90, color= 0x0000FFFF, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            end
        end
    end
end

SetTimerCallback("Main")