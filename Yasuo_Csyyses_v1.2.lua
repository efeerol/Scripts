require 'winapi'
    require 'vals_lib'
    require 'utils'
    local uiconfig = require 'uiconfig'
    local target 
    local boxWidth=25
    local rang=475   
    local eRange=475+boxWidth     
    local wrang=400
    local AArange = myHero.range+boxWidth  
    local cc = 0
    local skillshotArray = {}
    local deviation=200
    function Main()

            GetCD()
            target = GetWeakEnemy('PHYS',475+boxWidth)
            if YasouHotkeys.RunUseE then RunUseE() end
            if not YasouHotkeys.RunUseE and YasouHotkeys.AutoR then AutoR() end
            if not YasouHotkeys.RunUseE and YasouHotkeys.AutoQ then AutoQ() end
            --printtext(cc)
            --printtext('\n')
            --printtext(#skillshotArray)
            --printtext('-----\n')
            cc=cc+1
            if cc==30 then LoadTable() end
           -- for i=1, #skillshotArray, 1 do
           --         if os.clock() > (skillshotArray[i].lastshot + skillshotArray[i].time) then
            --                skillshotArray[i].shot = 0
           --         end
           -- end
            --if YasouHotkeys.AutoE then AutoE() end
    end
    
            YasouHotkeys, menu = uiconfig.add_menu('Yasou hotkeys', 200)
            menu.keytoggle('AutoR', 'AutoR', Keys.F1, false)
            menu.slider('AutoRHp', 'AutoR Target Hp%', 0, 100, 50)  
            menu.slider('EDeviation', 'E Deviation', 0, 300, 150)  
            menu.keytoggle('AutoQ', 'AutoQ', Keys.F2, true)
            menu.keytoggle('AutoW', 'AutoW', Keys.F3, true)
            menu.keydown('RunUseE', 'RunUseE', Keys.X)
            menu.permashow('AutoQ')
            menu.permashow('AutoW')
            menu.permashow('AutoR')
            menu.permashow('AutoRHp')
            menu.permashow('RunUseE')
    function AutoQ()
           if   myHero.SpellNameQ ~= 'yasuoq3w' then
                    SpellPredHero('Q',QRDY,myHero,target,rang,0,1800)
                    elseif ERDY and GetDistance(target)>300 and target.invulnerable==0 and YasouHotkeys.AutoR and RRDY then
                           CastSpellTarget("E",target)
                        SpellPredHero('Q',QRDY,myHero,target,900,0,1200,1)
                           CastSpellTarget("R",myHero)
            else
                        local target900=GetWeakEnemy('PHYS',900)
                        SpellPredHero('Q',QRDY,myHero,target900,900,0,1200,1)
            end

    end
    local SORT_Near = function(a, b) 
        return  GetDistance(a) <  GetDistance(b) 
    end
    function RunUseE()
    if ERDY then 
        local Minions = GetEnemyMinions(SORT_Near)
         for i, Minion in pairs(Minions) do   
         local tempD=GetDistance(Minion)
            if tempD >=eRange then
                break
            elseif (IsBetween(myHero,Minion,mousePos,YasouHotkeys.EDeviation) and tempD > (eRange - YasouHotkeys.EDeviation)) or (IsBetween(myHero,eEndPos(Minion),mousePos,YasouHotkeys.EDeviation))  then
            CastSpellTarget("E",Minion)
            --printtext(IsSpellReady('E'))
            --printtext('\n')
              if not IsSpellReady('E') then 
                    break
              end
            end
         end
    end 
        MouseRightClick()
    end
function eEndPos(unit)
    local endPos={}
    local endPosX = unit.x-myHero.x
    local endPosZ = unit.z-myHero.z
    abs = math.sqrt(endPosX*endPosX + endPosZ*endPosZ)
    endPos.x=myHero.x + (eRange*(endPosX/abs))
    endPos.z=myHero.z + (eRange*(endPosZ/abs))
    
    return endPos
end
    function AutoR()
            if RRDY  then
                 for i = 1, objManager:GetMaxHeroes() do
                    local enemy = objManager:GetHero(i)
                    if ValidTarget(enemy,1350+boxWidth) and enemy.y>myHero.y+15 and enemy.invulnerable==0 and enemy.health < ((enemy.maxHealth*YasouHotkeys.AutoRHp)/100)   then
                        CastSpellTarget('R',enemy)
                        break
                    end
                end
            end
    end

    function OnProcessSpell(unit, spell)
if WRDY and YasouHotkeys.AutoW and myHero.team ~= unit.team and IsBetween(unit,myHero,spell.endPos,200) then 
    if  unit.addDamage>120  then
        --CastSpellXYZ('W',unit.x,unit.y,unit.z)    
            --MouseRightClick()
         elseif  string.find(spell.name, "Basic") == nil    then
        for i=1, #skillshotArray, 1 do
            if spell.name == skillshotArray[i].name and skillshotArray[i].l > 1  then
            CastSpellXYZ('W',unit.x,unit.y,unit.z)    
                MouseRightClick()
                break
            end
        end
    end
end
end
    --para l 1=low 2=high 3=slow 4=c
        function LoadTable()
            for i = 1, objManager:GetMaxHeroes() do
                    local enemy = objManager:GetHero(i)
                    if (enemy ~= nil and enemy.team ~= myHero.team) then
                            if enemy.name == 'Aatrox' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=3})
                            elseif enemy.name == 'Ahri' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=4})
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=4})
                            elseif enemy.name == 'Alistar' then
                                    --table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 50, type = 3, radius = 200, color= 0x0000FFFF, time = 0.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                            elseif enemy.name == 'Amumu' then
                                   table.insert(skillshotArray,{name= enemy.SpellNameQ,l=4})
                            elseif enemy.name == 'Anivia' then
                                   table.insert(skillshotArray,{name= enemy.SpellNameQ,l=4})
                                   table.insert(skillshotArray,{name= enemy.SpellNameE,l=2})
                            elseif enemy.name == 'Annie' then
                                   table.insert(skillshotArray,{name= enemy.SpellNameQ,l=4})
                            elseif enemy.name == 'Ashe' then
                                   table.insert(skillshotArray,{name= enemy.SpellNameW,l=3})
                                   table.insert(skillshotArray,{name= enemy.SpellNameR,l=4})
                            elseif enemy.name == 'Blitzcrank' then
                                   table.insert(skillshotArray,{name= enemy.SpellNameQ,l=4})
                            elseif enemy.name == 'Brand' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=4})
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=2})
                                    table.insert(skillshotArray,{name= enemy.SpellNameR,l=2})
                            elseif enemy.name == 'Cassiopeia' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=2})
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=3})
                                    table.insert(skillshotArray,{name= enemy.SpellNameR,l=2})
                            elseif enemy.name == 'Caitlyn' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=2})
                            elseif enemy.name == 'Corki' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=1})
                                    table.insert(skillshotArray,{name= enemy.SpellNameR,l=2})
                            elseif enemy.name == 'Chogath' then

                            elseif enemy.name == 'Darius' then

                            elseif enemy.name == 'Diana' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=2})
                            elseif enemy.name == 'Draven' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=1})
                                    table.insert(skillshotArray,{name= enemy.SpellNameR,l=2})
                            elseif enemy.name == 'DrMundo' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=3})
                            elseif enemy.name == 'Elise' and enemy.range>300 then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=2})
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=4})
                            elseif enemy.name == 'Ezreal' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=2})
                                    table.insert(skillshotArray,{name= enemy.SpellNameW,l=1})
                                    table.insert(skillshotArray,{name= enemy.SpellNameR,l=2})
                            elseif enemy.name == 'FiddleSticks' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=2})
                            elseif enemy.name == 'Fizz' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameR,l=4})
                            elseif enemy.name == 'Galio' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=3})
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=2})
                            elseif enemy.name == 'Gragas' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=2})
                                    table.insert(skillshotArray,{name= enemy.SpellNameR,l=4})
                            elseif enemy.name == 'Graves' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=2})
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=3})
                                    table.insert(skillshotArray,{name= enemy.SpellNameR,l=2})
                            elseif enemy.name == 'Hecarim' then

                            elseif enemy.name == 'Heimerdinger' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameW,l=2})
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=2})
                            --[[elseif enemy.name == 'Irelia' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 80, color= 0x0000FFFF, time = 0.8, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                             ]]
                            elseif enemy.name == 'Janna' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=3})
                            elseif enemy.name == 'JarvanIV' then
                                    
                            elseif enemy.name == 'Jayce' and enemy.range>300 then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=2})
                            elseif enemy.name == 'Jinx' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameW,l=3})
                                    table.insert(skillshotArray,{name= enemy.SpellNameR,l=2})
                            elseif enemy.name == 'Karma' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=2})
                            elseif enemy.name == 'Karthus' then
                                    
                            elseif enemy.name == 'Kassadin' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=3})
                            elseif enemy.name == 'Kennen' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=2})
                            elseif enemy.name == 'Khazix' then
                                     table.insert(skillshotArray,{name= enemy.SpellNameE,l=3})
                            elseif enemy.name == 'KogMaw' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=2})
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=3})
                            elseif enemy.name == 'Leblanc' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=2})
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=3})
                            elseif enemy.name == 'LeeSin' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=4})
                            elseif enemy.name == 'Leona' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=4})
                            elseif enemy.name == 'Lissandra' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=2})
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=3})
                            elseif enemy.name == 'Lucian' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=2})
                                    table.insert(skillshotArray,{name= enemy.SpellNameR,l=4})
                            elseif enemy.name == 'Lulu' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=3})
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=3})
                            elseif enemy.name == 'Lux' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=4})
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=3})
                            elseif enemy.name == 'Malphite' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=3})
                            elseif enemy.name == 'Malzahar' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=3})
                            elseif enemy.name == 'Maokai' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=1})
                            elseif enemy.name == 'MissFortune' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=2})
                                    table.insert(skillshotArray,{name= enemy.SpellNameR,l=4})
                            elseif enemy.name == 'Morgana' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=4})
                            elseif enemy.name == 'Nami' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=4})
                                    table.insert(skillshotArray,{name= enemy.SpellNameR,l=4})
                            elseif enemy.name == 'Nautilus' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=4})
                                    table.insert(skillshotArray,{name= enemy.SpellNameR,l=4})
                            elseif enemy.name == 'Nidalee' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=2})
                            elseif enemy.name == 'Nocturne' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=3})
                            elseif enemy.name == 'Nunu' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=3})
                            elseif enemy.name == 'Olaf' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=3})
                            elseif enemy.name == 'Orianna' then
                                  
                            elseif enemy.name == 'Quinn' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=3})
                            elseif enemy.name == 'Riven' then
                                    table.insert(skillshotArray,{name= 'rivenizunablade',l=4})
                            elseif enemy.name == 'Renekton' then
                                    
                            elseif enemy.name == 'Rumble' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=3})
                            elseif enemy.name == 'Sejuani' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameR,l=4})
                            elseif enemy.name == 'Shen' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=2})
                            elseif enemy.name == 'Shyvana' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=2})
                            elseif enemy.name == 'Sivir' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=2})
                            elseif enemy.name == 'Shaco' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=2})
                            elseif enemy.name == 'Sion' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=4})
                            elseif enemy.name == 'Skarner' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=1})
                            elseif enemy.name == 'Sona' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameR,l=4})
                            elseif enemy.name == 'Swain' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=3})
                            elseif enemy.name == 'Syndra' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=4})
                                    table.insert(skillshotArray,{name= enemy.SpellNameR,l=4})
                            elseif enemy.name == 'Teemo' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=3})
                            elseif enemy.name == 'Talon' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameW,l=3})
                            elseif enemy.name == 'Thresh' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=4})
                            elseif enemy.name == 'Tristana' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=2})
                                    table.insert(skillshotArray,{name= enemy.SpellNameR,l=4})
                            elseif enemy.name == 'Tryndamere' then
                                    
                            elseif enemy.name == 'TwistedFate' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=2})
                            elseif enemy.name == 'Urgot' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=2})
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=3})
                            elseif enemy.name == 'Varus' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=2})
                                    table.insert(skillshotArray,{name= enemy.SpellNameR,l=4})
                            elseif enemy.name == 'Veigar' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=2})
                                    table.insert(skillshotArray,{name= enemy.SpellNameR,l=4})
                            elseif enemy.name == 'Vayne' then    
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=4})
                            elseif enemy.name == 'Vi' then
                                    
                            elseif enemy.name == 'Viktor' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=2})
                            elseif enemy.name == 'Xerath' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=4})
                            elseif enemy.name == 'Yasuo' then
                                    table.insert(skillshotArray,{name= 'yasuoq3w',l=4})
                            elseif enemy.name == 'Zac' then
                                    
                            elseif enemy.name == 'Zed' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=2})
                                    table.insert(skillshotArray,{name= enemy.SpellNameW,l=2})
                            elseif enemy.name == 'Ziggs' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameQ,l=2})
                                    table.insert(skillshotArray,{name= enemy.SpellNameW,l=2})
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=2})
                            elseif enemy.name == 'Zyra' then
                                    table.insert(skillshotArray,{name= enemy.SpellNameE,l=2})
                            end
                    end
            end
    end
     function SpellPredHero(spell,cd,a,b,range,delay,speed,visble)
    if (cd == 1 or cd) and a ~= nil and b ~= nil and (visble==nil or b.invulnerable==0) and a.dead==0 and  b.dead == 0 and delay ~= nil and speed ~= nil and GetDistance(a,b)<range then
        local FX,FY,FZ = GetFireahead(b,delay,speed)
        CastSpellXYZ(spell,FX,FY,FZ)
        --MoveToMouse() 
        --MouseRightClick()
    end
end
    SetTimerCallback('Main')