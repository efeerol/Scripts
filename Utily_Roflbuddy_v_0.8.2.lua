--[[
==================================================
 RoflBuddy Version 0.8.2 by EZGAMER, Lua - A Gameplay Assistant Tool 
 
 Features:
			GUI: Sleek graphical display to display data
				// Enemy Names
				// Enemy HP
				// Enemy HP %
				// Estimated HP % left after using a rotation of currently available spells
				// MIA Timer
				// ETA Timer - If they go MIA, it displays how long until they reach your lane
				// Perfect Creep Count - Displays a perfect Last Hit # for your lane.
			
			Mouse-Over Tool Tips:
				Hold down the MenuConfig.mouseover key to display details about the enemy you are hovering your mouse over
				Set MenuConfig.mouseOverType in GUI to swap between tooltips at Cursor or side of screen
				// Estimated Damage
				// Damage needed to complete the kill (Great for team mates using LB too)
				// AA Counter- How many Auto Attacks it would take to kill (Useful for ADC)
				
			RoflMap: Improved Colour Coordinated Minimap
				// TextColor based on HP% (Green / Yellow / Red / White)
				// MIA Timer
				// Death Marker for enemies KIA

			SmartTimers: Place ward timers for wards that LB misses (ones placed in brushes / FOW)
				// Hold down MenuConfig.quickWard and Left Click to place a 3 Minute Timer			

			JungleBuddy: Turn ON/OFF via GUI
				// Detailed Jungle timer for *ALL* camps for summoners rift (Twisted Treeline to come soon)
				
			]]--
			

require "Utils"
require "spell_damage"
local uiconfig = require "uiconfig"
local version = '0.8.2'

local menuX = GetScreenX()-450
local menuY = 100
local menuWidth = GetScreenX()-menuX
local menuHeight = 175

local tabX = GetScreenX()-40
local tabY = 100
local tabWidth = GetScreenX()-menuX
local tabHeight = 175
local tab = 1
tabColor = 0x5000A1E6
if moving == false then
tabColor = 0x5000A1E6
elseif moving == true then
tabColor = 0x9900A1E6
end

local enemies = {}
local enemy = {}
local position = {x = menuX + 30, y = menuY + 30}
local offset = {x = 0, y = 0}
local player = GetSelf()
local offset = {}
local moving = false
local textPosition = 0

local beepFrequency = 2 -- time between beeps. (in seconds)
local toggleBeep = true
local toggleBeepKey = 112 -- F1
local toggleBeepPressed = false
local beepTimer = 0
 
local beepThreshold = 25
local toggleThresholdKey = 113 -- F2
local toggleThresholdPressed = false

local minionCount = 0
local team = 0
local teamColor = 0
local jungle = {}
local creep = {}
local wards = {}
local lastQuick = 0

local junglePosition = {

{ name = "Worm", team = 'NA', { x = 4600,y = 0, z = 10250} },
{ name = "Dragon", team = 'NA', location = Vector(9459,0,4193) },
{ name = "AncientGolem", team = TEAM_BLUE, location = { x = 3632, y = 0, z = 7600} },
{ name = "GiantWolf", team = TEAM_BLUE, location = { x = 3373,y = 0, z = 6223} },
{ name = "Wraith", team = TEAM_BLUE, location = { x = 6446,y = 0, z = 5214} },
{ name = "GreatWraith", team = TEAM_BLUE, location = { x = 1684,y = 0, z = 8207} },
{ name = "LizardElder", team = TEAM_BLUE, location = { x = 7455,y = 0, z = 3890} },
{ name = "Golem", team = TEAM_BLUE, location = { x = 8216,y = 0, z = 2533} },
{ name = "AncientGolem", team = TEAM_RED, location = Vector(10386,0,6811) },
{ name = "GiantWolf", team = TEAM_RED, location = Vector(10651,0,8116) },
{ name = "Wraith", team = TEAM_RED, location = Vector(7580,0,9250) },
{ name = "GreatWraith", team = TEAM_RED, location = Vector(12337,0,6263) },
{ name = "LizardElder", team = TEAM_RED, location = Vector(6504,0,10584) },
{ name = "Golem", team = TEAM_RED, location = Vector(6140,0,11935) }

}

MenuConfig, roflbuddy = uiconfig.add_menu("RoflBuddy Menu")
roflbuddy.keytoggle("toggle", "Show GUI", true, Keys.F1)
roflbuddy.keytoggle("beep", "Beep Alert", true, Keys.F2)
roflbuddy.keytoggle("jungleBuddy", "Jungle Buddy", true, Keys.F3)
roflbuddy.keytoggle("minimap", "Roflmap", true, Keys.F4)
roflbuddy.keytoggle("mouseover", "MouseOver Tool Tips", true, Keys.F5)
roflbuddy.slider('mouseOverType', 'MouseOver Toolbox Type', 1, 2, 1, {"At Mouse","At Side"})
roflbuddy.keydown("quickWard", "Set Quick Timer", false, Keys.N)




for i=1, objManager:GetMaxHeroes(), 1 do
    object = objManager:GetHero(i)
    if object and object ~= nil and object.team ~= player.team then
        enemy = {hero = object, name = object.name, health = object.health, seen = GetClock(), fresh = false, fade = 0}
        table.insert(enemies, enemy)
    end
end


function OnCreateObj(object)
for i, x in ipairs(junglePosition) do
		if object.name == x.name then 
		
			printtext("\nFound "..object.name.."\n "..GetDistance(object,x.position))
			if GetDistance(object,x.location) < 1000 then
			local name = object.name
			local team = x.team
			printtext("\ntimetocheckTEAM")
			 entry = CheckCreep(name,team) 
			if entry == nil then
		creep = { hero = object, name = object.name, team = x.team, death = 0, location = x.location }
			printtext("..add it\n")
		table.insert(jungle,creep)
		else 
		creep = { hero = object, name = object.name, team = x.team, death = 0, location = x.location}
			printtext("..add it after dupe deletion\n")
		table.insert(jungle,creep)
		printtext("We've now got "..#jungle.." creeps in the jungle table")
		
		
	 end
	 end
end
end

if object.team == myHero.team and string.find(object.charName,"Minion") then
minionCount = minionCount + 1
end
end


function OnTick()
wardUpdate()
quickWard()
Positioning()
    if #enemies ~= 5 then
        for i=1, objManager:GetMaxHeroes(), 1 do
            object = objManager:GetHero(i)
            if object and object ~= nil and object.team ~= player.team then
                local entry = CheckEnemy(object.name)
                if entry == nil then
                    enemy = {hero = object, name = object.name, health = object.health, seen = GetClock(), fresh = false, fade = 0}
                    table.insert(enemies, enemy)
                elseif entry.hero ~= object then
                    entry.hero = object
                end
            end
        end
    end
   if #enemies > 0 then
    for i,enemy in ipairs(enemies) do
   
        if enemy == nil or enemy.hero == nil or not enemy then
            table.remove(enemies,i)
        elseif enemy.name == nil or string.find(enemy.hero.name, enemy.name) == nil then
            table.remove(enemies,i)
        else
            if enemy.hero.visible == 1 then
                enemy.seen = GetClock()
                if enemy.hero.health ~= enemy.health then
                    enemy.health = enemy.hero.health
                    enemy.fresh = true
                end
            else enemy.fresh = false end
           
            if player.dead ~= 1 and enemy.hero.invulnerable ~= 1 and enemy.hero.dead ~= 1 then
                local enemyThreshold = math.ceil((enemy.hero.health / enemy.hero.maxHealth) * 100)
                if enemy.fresh and beepThreshold >= enemyThreshold then
                    if MenuConfig.beep and (GetClock() - beepTimer) >= (beepFrequency * 1000) and enemy.hero.visible == 1 then
                        PlaySound("Beep")
                        beepTimer = GetClock()
                    end
                end
            end
        end
    end
	end

if MenuConfig.toggle then
		if tab  == 1 then
		DrawText("RoflBuddy v"..version,menuX+ 30,menuY+10,0xFFCD853F)
		DrawBox(menuX,menuY,menuWidth,menuHeight,0x99000000)
        DrawBox(menuX+5,menuY+5,menuWidth-10,menuHeight,0x10000000)
		
		DrawBox(menuX-20,tabY,20,tabHeight,0x99000000)--BORDER
       DrawBox(menuX-15,tabY+5,30,tabHeight-145 ,tabColor) --Smaller
     DrawBox(menuX-15,tabY+40,30,tabHeight-45,0x7000A1E6)
--DrawBox(tabX+5,tabY+5,tabWidth,tabHeight-270,0x5000A1E6)
--DrawBox(tabX+5,tabY+40,tabWidth,tabHeight-45,0x7000A1E6)

    if #enemies > 0 then
        for i,enemy in ipairs(enemies) do
				
				local pdmg = getDmg("P",enemy.hero,myHero) 
				local qdmg = getDmg("Q",enemy.hero,myHero)*CanUseSpell("Q") 
				local wdmg = getDmg("W",enemy.hero,myHero)*CanUseSpell("W")
				local edmg = getDmg("E",enemy.hero,myHero)*CanUseSpell("E")
				local rdmg = getDmg("R",enemy.hero,myHero)*CanUseSpell("R")
				local aadmg = getDmg("AD",enemy.hero,myHero)
				local totaldmg = qdmg+wdmg+edmg+rdmg+(aadmg*3)
				     
            local newY = position.y + (i * 20)
	
            local enemyThreshold = math.ceil((enemy.hero.health / enemy.hero.maxHealth) * 100)
            local dmgThreshold = math.ceil(((enemy.hero.health-totaldmg) / enemy.hero.maxHealth) * 100)
            local enemyHpColor = GetHealthColor(enemy.hero.health, enemy.hero.maxHealth)
			
            if MenuConfig.mouseover then mouseOver(enemy.hero,dmgThreshold,totaldmg) end -- MOUSE OVER IS HERE
			
            if enemy.hero.dead == 1 then
                enemyHpColor = 0xFFBFBFBF
            elseif beepThreshold >= enemyThreshold then
                if enemy.fade > 6 then
                    enemyHpColor = 0xFFFF0000
                    if enemy.fade > 12 then enemy.fade = 0 end
                else  enemyHpColor = 0xFFAD0000 end
                enemy.fade = enemy.fade + 1
            end
           --DRAWING STUFF STARTS HERE
            if enemy.hero.name ~= 'MonkeyKing' and enemy.hero.name ~= 'FiddleSticks' then DrawText(enemy.hero.name, position.x, newY, enemyHpColor)
			elseif enemy.hero.name == 'MonkeyKing' then DrawText('Wukong', position.x, newY, enemyHpColor)
			elseif enemy.hero.name == 'FiddleSticks' then DrawText('Fiddle', position.x, newY, enemyHpColor) end
           
            if enemy.hero.dead == 0 then
                DrawText(string.format("%u", enemy.hero.health), position.x + 80, newY, enemyHpColor)
                DrawText("/", position.x + 120, newY, enemyHpColor)
                DrawText(string.format("%u", enemy.hero.maxHealth), position.x + 130, newY, enemyHpColor)
                if enemyThreshold < 100 then DrawText(enemyThreshold.."%", position.x + 175, newY, enemyHpColor)
                elseif enemyThreshold == 100 then DrawText(enemyThreshold.."%", position.x + 170, newY, enemyHpColor) end
         --   else
         --       DrawText("Dead", position.x + 80, newY, enemyHpColor)
            end
           
		     
		   
			if dmgThreshold > 0 then
				DrawText(dmgThreshold.."% REM",position.x + 215, newY, enemyHpColor)
		    elseif enemy.hero.dead == 0 then
				DrawText("KILL",position.x + 230, newY, Color.Red)
			end
			
            if enemy.hero.visible == 0 and enemy.hero.dead == 0 then
                DrawText("MIA "..string.format("%u", (GetClock() - enemy.seen) / 1000).."s",  position.x + 290, newY, enemyHpColor)
				if (math.ceil(GetDistance(enemy.hero)/enemy.hero.movespeed)-string.format("%u", (GetClock() - enemy.seen) / 1000)) > 0 then
					DrawText("ETA: "..math.ceil(GetDistance(enemy.hero)/enemy.hero.movespeed)-string.format("%u", (GetClock() - enemy.seen) / 1000).."s", position.x + 350, newY, enemyHpColor)
				elseif (math.ceil(GetDistance(enemy.hero)/enemy.hero.movespeed)-string.format("%u", (GetClock() - enemy.seen) / 1000)) <= 0 then
					DrawText("CARE", position.x + 360, newY, Color.Red)
				end

            end
        end
    end
	
	-----------MINION COUNTER---------------------------------------
			
            DrawText("Perfect Creep Score: "..math.floor(minionCount / 3), position.x, position.y+150, Color.White)
			end

			

		
		if tab == 0 then
				DrawBox(tabX,tabY,tabWidth,tabHeight,0x99000000)
				if moving == false then
        DrawBox(tabX+5,tabY+5,tabWidth,tabHeight-145,0x5000A1E6)
				elseif moving == true then
		        DrawBox(tabX+5,tabY+5,tabWidth,tabHeight-145,0x99FFFFFF)
				end			
        DrawBox(tabX+5,tabY+40,tabWidth,tabHeight-45,0x7000A1E6)
		end
		
		
	end
end

function OnDraw()
if MenuConfig.minimap then
   if #enemies > 0 then

        for i,enemy in ipairs(enemies) do
  if enemy.hero.health ~= nil then
            local newY = position.y + (i * 20)
            local enemyThreshold = math.ceil((enemy.hero.health / enemy.hero.maxHealth) * 100)
            local enemyHpColor = GetHealthColor(enemy.hero.health, enemy.hero.maxHealth)
       
            if enemy.hero.dead == 1 then
                enemyHpColor = 0xFFBFBFBF
			end
							if enemy.hero.visible == 1 and enemy.hero.dead ~= 1 then
			                DrawTextMinimap(enemyThreshold.."% ", enemy.hero.x,enemy.hero.z, enemyHpColor)
							elseif enemy.hero.visible == 0 and enemy.hero.dead == 1 then
							  DrawTextMinimap(enemy.hero.name.." KIA", enemy.hero.x,enemy.hero.z, enemyHpColor)
							elseif enemy.hero.visible ~= 1 and enemy.hero.dead == 0 then
							  DrawTextMinimap(enemy.hero.name.." "..enemyThreshold.."%"..string.format("SS %u", (GetClock() - enemy.seen) / 1000).."s", enemy.hero.x,enemy.hero.z, enemyHpColor)
							  end



end
end
end
end
end

function Positioning()
if IsKeyDown(1) == 1 and moving == true then

	 menuY = GetCursorY()-15
	 tabY = GetCursorY()-15
	 position = {x = menuX + 30, y = menuY + 30}

    end
end

function GetHealthColor(minHp, maxHp)
    local perc = minHp / maxHp * 100
    if perc >= 70 then return 0xFF33FF33 -- green
    elseif perc >= 40 then return 0xFFFFFF00 -- yellow
    elseif perc >= 20 then return 0xFFFF9900 -- orange
    elseif perc < 20 then return 0xFFFF0000 -- red
    else return 0xFFFFFFFF end -- white
end

function CheckEnemy(name)
    if #enemies > 0 then
        for i,enemy in ipairs(enemies) do
            if enemy and enemy ~= nil and string.find(enemy.name, name) then return enemy end
        end
    end
    return nil
end

function mouseOver(object,message,message2)
local total = math.floor((message2/object.maxHealth)*100)


				local pdmg = getDmg("P",object,myHero) 
				local qdmg = getDmg("Q",object,myHero)*CanUseSpell("Q") 
				local wdmg = getDmg("W",object,myHero)*CanUseSpell("W")
				local edmg = getDmg("E",object,myHero)*CanUseSpell("E")
				local rdmg = getDmg("R",object,myHero)*CanUseSpell("R")
				local aadmg = getDmg("AD",object,myHero)
				local aaHits = math.floor(enemy.health / aadmg)

				
if GetDistance(object,mousePos) < 150 then
	local enemyobject = object
	if MenuConfig.mouseOverType == 1 then

		DrawBox(GetCursorX()+50,GetCursorY()-70,100,85,0x99000000)
		DrawBox(GetCursorX()+55,GetCursorY()+15,70,75,130,0x99000000)
		DrawText(enemyobject.name,GetCursorX()+55,GetCursorY()-65,0x99FFFFFF)
		DrawText(enemyobject.charName,GetCursorX()+55,GetCursorY()-50,0x50FFFFFF)

		if message > 0 then
			DrawText(total.."% Inflicted", GetCursorX()+55, GetCursorY()-35, Color.White)
			DrawText(message.."% remaining", GetCursorX()+55, GetCursorY()-20, Color.White)
			else DrawText("KILLABLE", GetCursorX()+55, GetCursorY()-35, Color.Red)
		end

		if aaHits > 0 then
			DrawText("AA Hits :"..aaHits, GetCursorX()+55, GetCursorY()-5, Color.White)
		else
			DrawText("AA KILLABLE", GetCursorX()+55, GetCursorY()+10, Color.Red)
		end

		elseif MenuConfig.mouseOverType == 2 then
			local setX = 200
			local setY = 200
			DrawBox(setX,setY-70,100,85,0x99000000)
			DrawBox(setX+5,setY+5,70,75,130,0x99000000)
			DrawText(enemyobject.name,setX+5,setY-65,0x99FFFFFF)
			DrawText(enemyobject.charName,setX+5,setY-50,0x50FFFFFF)

			if message > 0 then
				DrawText(total.."% Inflicted", setX+5, setY-35, Color.White)
				DrawText(message.."% remaining", setX+5, setY-20, Color.White)
				
				else DrawText("KILLABLE", setX+5, setY-35, Color.Red)
				end

			if aaHits > 0 then
			DrawText("AA Hits :"..aaHits, setX+5, setY-5, Color.White)
			else
			DrawText("AA KILLABLE", setX+5, setY+10, Color.Red)
			end
		end
	end

end



function quickWard()
local ward = {}
if MenuConfig.quickWard then
    DrawCircle(GetCursorWorldX(),GetCursorWorldY(),GetCursorWorldZ(),100,3)
if IsKeyDown(1) == 1 and GetClock() - lastQuick > 800 then
	ward ={ location = { x=GetCursorWorldX(),y=GetCursorWorldY(),z=GetCursorWorldZ() }, timer = (GetClock() + 180000) } 
	table.insert(wards,ward)
	lastQuick = GetClock()
	printtext("ward timer placed")

end
end
end

function wardUpdate()
if #wards > 0  then
for _, ward in pairs(wards) do
	DrawTextMinimap(math.floor((ward.timer - GetClock())/1000), ward.location.x, ward.location.z, 0xFFFFFFFF)
	DrawCircle(ward.location.x, ward.location.y, ward.location.z, 100, 4)
	DrawCircle(ward.location.x, ward.location.y, ward.location.z, 98, 4)
	if ward.timer - GetClock() < 0 then
	printtext("ward removed\n")
	table.remove(wards,ward)
	end

end
end
end

function OnWndMsg(msg,key)
    if msg == WM_LBUTTONDOWN and GetCursorX() >= tabX+5 then
		if GetCursorY() >= tabY+5 and GetCursorY() < tabY+35 then moving = true
		elseif GetCursorY() >= tabY+40 and GetCursorY() < tabY+300 then tab = (tab+1)%2 end	 
	elseif msg == WM_LBUTTONUP and moving == true then moving = false
	end
end

--####JUNGLEBUDDY########################

function UpdatejungleTable()
	for i=1, objManager:GetMaxObjects(), 1 do
		object = objManager:GetObject(i)
		if object ~= nil then
			for i, x in ipairs(junglePosition) do
				if object.name == x.name then
					if GetDistance(object,x.location) < 1000 then
						local name = object.name
						local team = x.team
						entry = CheckCreep(name,team)
						if entry == nil then
							creep = { hero = object, name = object.name, team = x.team, death = 0, location = x.location }
							table.insert(jungle,creep)
						else 
							creep = { hero = object, name = object.name, team = x.team, death = 0, location = x.location}
							table.insert(jungle,creep)
						end
					end
				end
			end
		end
	end

	for i,jungle in ipairs(jungle) do
		if jungle.hero.dead == 1 then
			if jungle.name == "Wraith" or jungle.name == "GiantWolf" or jungle.name == "Golem" or jungle.name == "GreatWraith" then jungle.death = GetClock() + 50000
			elseif jungle.name == "AncientGolem" or jungle.name == "LizardElder" then jungle.death = GetClock() + 300000
			elseif jungle.name == "Worm" then jungle.death = GetClock() + 420000
			elseif jungle.name == "Dragon" then jungle.death = GetClock() + 360000 end
		end
	end
end

function CheckCreep(name,team)
    if #jungle > 0 then
        for i,enemy in ipairs(jungle) do
            if name == enemy.name and team == enemy.team then 
			table.remove(jungle,i)
			return enemy.name
		end
        end
    end
    return nil
end




function DrawJungle()
local team = 0
local teamColor = 0
local jungleMove = 0

	if MenuConfig.jungleBuddy then
		local tabHeight = 90
		local tabWidth = 170
		local setX = GetScreenX()-tabWidth-100
		local setY = 440
		local position = {x = setX + 10, y = setY + 10}

		DrawText("JungleBuddy",setX+35,setY+8,0xFFADFF2F)
		--DrawBox(setX,setY,tabWidth,tabHeight+40,0x99000000)
		--DrawBox(setX+5,setY+5,tabWidth,tabHeight,0x10000000)
		DrawBox(setX-40,setY,tabWidth+40,tabHeight+115,0x99000000)--BORDER
		DrawBox(setX-35,setY+5,30,25,tabColor) --Title Blue
		DrawBox(setX-35,setY+35,30,tabHeight-30,0x7000A1E6) -- Middle Blue
		DrawBox(setX-35,setY+100,30,100,tabColor) --Bottom Blue

		DrawText("Baron", position.x+48,position.y + 25,Color.White)
		DrawText("Dragon", position.x+45,position.y + 60,Color.White)

		DrawText("Red", position.x,position.y + 95,Color.White)
		DrawText("Blue", position.x,position.y + 110,Color.White)
		DrawText("Wraiths", position.x,position.y + 125,Color.White)
		DrawText("Wolves", position.x,position.y + 140,Color.White)
		DrawText("Golems", position.x,position.y + 155,Color.White)
		DrawText("Wight", position.x,position.y + 170,Color.White)

		if #jungle > 0 then
			for i, jungle in pairs(jungle) do
				if jungle.name == "Worm" then
					if jungle.death - GetClock() > 0 then
						DrawText(JungleTime(jungle.death), position.x+60,position.y + 43,Color.Purple)							
					else
						DrawText("ALIVE", position.x+50,position.y + 43,Color.Purple)
					end
				elseif jungle.name == "Dragon" then
					if jungle.death - GetClock() > 0 then
						DrawText(JungleTime(jungle.death), position.x+60,position.y + 77,Color.LightBlue)
					else
						DrawText("ALIVE", position.x+50,position.y + 77,Color.LightBlue)
					end
				elseif jungle.name == "LizardElder" then
					if jungle.death - GetClock() > 0 then
						if jungle.team == myHero.team then
							DrawText(JungleTime(jungle.death), position.x+70,position.y + 95,Color.Red)
						elseif jungle.team == TEAM_ENEMY then
							DrawText(JungleTime(jungle.death), position.x+120,position.y + 95,Color.Red)
						end
					elseif jungle.team == myHero.team then
						DrawText("ALIVE", position.x+60,position.y + 95,Color.Green) 
					elseif jungle.team == TEAM_ENEMY then
						DrawText("ALIVE", position.x+110,position.y + 95,Color.Red)
					end
				elseif jungle.name == "AncientGolem" then
					if jungle.death - GetClock() > 0 then
						if jungle.team == myHero.team then
							DrawText(JungleTime(jungle.death), position.x+70,position.y + 110,Color.Red)
						elseif jungle.team == TEAM_ENEMY then
							DrawText(JungleTime(jungle.death), position.x+120,position.y + 110,Color.Red)
						end
					elseif jungle.team == myHero.team then
						DrawText("ALIVE", position.x+60,position.y + 110,Color.Green) 
					elseif jungle.team == TEAM_ENEMY then
						DrawText("ALIVE", position.x+110,position.y + 110,Color.Red)
					end
				elseif jungle.name == "Wraith" then
					if jungle.death - GetClock() > 0 then
						if jungle.team == myHero.team then
							DrawText(JungleTime(jungle.death), position.x+70,position.y + 125,Color.Red)
						elseif jungle.team == TEAM_ENEMY then
							DrawText(JungleTime(jungle.death), position.x+120,position.y + 125,Color.Red)
						end
					elseif jungle.team == myHero.team then
						DrawText("ALIVE", position.x+60,position.y + 125,Color.Green) 
					elseif jungle.team == TEAM_ENEMY then
						DrawText("ALIVE", position.x+110,position.y + 125,Color.Red) 
					end
				elseif jungle.name == "GiantWolf" then
					if jungle.death - GetClock() > 0 then
						if jungle.team == myHero.team then
							DrawText(JungleTime(jungle.death), position.x+70,position.y + 140,Color.Red)
						elseif jungle.team == TEAM_ENEMY then
							DrawText(JungleTime(jungle.death), position.x+120,position.y + 140,Color.Red)
						end
					elseif jungle.team == myHero.team then
						DrawText("ALIVE", position.x+60,position.y + 140,Color.Green) 
					elseif jungle.team == TEAM_ENEMY then
						DrawText("ALIVE", position.x+110,position.y + 140,Color.Red) 
					end
				elseif jungle.name == "Golem" then
					if jungle.death - GetClock() > 0 then
						if jungle.team == myHero.team then
							DrawText(JungleTime(jungle.death), position.x+70,position.y + 155,Color.Red)
						elseif jungle.team == TEAM_ENEMY then
							DrawText(JungleTime(jungle.death), position.x+120,position.y + 155,Color.Red)
						end
					elseif jungle.team == myHero.team then
						DrawText("ALIVE", position.x+60,position.y + 155,Color.Green) 
					elseif jungle.team == TEAM_ENEMY then
						DrawText("ALIVE", position.x+110,position.y + 155,Color.Red) 
					end
				elseif jungle.name == "GreatWraith" then
					if jungle.death - GetClock() > 0 then
						if jungle.team == myHero.team then
							DrawText(JungleTime(jungle.death), position.x+70,position.y + 170,Color.Red)
						elseif jungle.team == TEAM_ENEMY then
							DrawText(JungleTime(jungle.death), position.x+120,position.y + 170,Color.Red)
						end
					end
				end
			end
		end
	end
end

function JungleTime(Time)
	if Time ~= nil then
		Seconds = math.floor((Time - GetClock())/1000)
        if Seconds > 59 then
			Minutes = math.floor(Seconds/60)
			Seconds = math.floor(Seconds-(math.floor(Seconds/60)*60))
			if Seconds < 10 then Seconds = "0"..Seconds end
			Result = Minutes..":"..Seconds
        else
			if Seconds < 10 then Seconds = "0"..Seconds end
			Result = "0:"..Seconds
        end
        return Result
	end
end

SetTimerCallback("OnTick")
SetTimerCallback("UpdatejungleTable")
SetTimerCallback("DrawJungle")