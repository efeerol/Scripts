--NewGen Timers

--require 'Utils'
local uiconfig = require 'uiconfig'
local runrunrun = require 'runrunrun'

local prefixes = {}
prefixes[1] = 'Dragon'
prefixes[2] = 'AncientGolem'
prefixes[3] = 'LizardElder'
prefixes[4] = 'Golem'
prefixes[5] = 'GiantWolf'
prefixes[6] = 'Wraith'
prefixes[7] = 'Worm'  --Baron
prefixes[8] = 'GreatWraith' --Wight

local track = {}

local Map = GetMap() --0=ProvingGrounds; 1=SummonersRift; 2=CrystalScar; 3=TwistedTreeline
if Map == 1 then
	Inhibits = {
	--BLU
		Order_Top = {x = 840, y = 101, z = 3359, team = 100, object = nil, status = nil, shatter = 0},
		Order_Mid = {x = 2788, y = 94, z = 2981, team = 100, object = nil, status = nil, shatter = 0},
		Order_Bot = {x = 3037, y = 98, z = 1035, team = 100, object = nil, status = nil, shatter = 0},
	--RED
		Chaos_Top = {x = 10959, y = 91, z = 13435, team = 200, object = nil, status = nil, shatter = 0},
		Chaos_Mid = {x = 11239, y = 92, z = 11471, team = 200, object = nil, status = nil, shatter = 0},
		Chaos_Bot = {x = 13209, y = 107, z = 11175, team = 200, object = nil, status = nil, shatter = 0}
	}
	--[[Monsters = {	
		Worm =
		Dragon =

	}]]
else return end --if not SR exit script


	--MENU
	CfgSettings, menu = uiconfig.add_menu('NewGen Timer')	
	menu.keytoggle('Minimap', 'Minimap', Keys.M, true)
	menu.permashow("Minimap")

function OnTick()
	Tick = GetTickCount()
	InhibTimer()
	JungleTimer()
	DrawThings()
end

local DrawBlue = false
local DrawList = {}

function DrawThings()
local toRemove = nil	
	for i,monster in pairs(DrawList) do
		if DrawList[i] ~= nil then
			local o = monster.object
      		local x, y = screen_position(monster)
		 	local tempTime = TimeFormat(monster.time)
		 	DrawText(tempTime,x,y,Color.White)
		 	if CfgSettings.Minimap then
				DrawTextMinimap(tempTime,monster.x,monster.z,Color.Yellow) 
			end
		 	if (math.floor((monster.time-GetTickCount())/1000)) <= 0 then
		 		DrawList[i] = nil
		 		toRemove = i
		 		--printtext("Removed!")		 			
		 	end
		 end	 	 
	end
	if toRemove ~= nil then
		table.remove( DrawList, toRemove )
		toRemove = nil		
	end
end

function JungleTimer()	
   	for key,t in pairs(track) do
        local o = t.object
        local still_valid = false
        if IsMonster(o) and is_alive(o) then 
        	local current_key = get_key(o)
        	if key == current_key then
                still_valid = true        		 
            end
      	end
        if still_valid then
            --printtext("Alive")
        else            
        	--printtext("Dead")        
        	local TempTime = GetRespawnTime(o)        	
        	tempObj = { x = o.x, y = o.y, z = o.z, time = TempTime }
        	table.insert(DrawList, tempObj)
        	track[key] = nil    	
        end
    end  
end

function screen_position(unit)
    if unit == nil then return nil end
    local x, y, z = unit.x, unit.y, unit.z
    if x ~= nil and y ~= nil and z ~= nil then
        xScreen = GetScreenX()/2+(x-GetWorldX())
        yScreen = GetScreenY()/2-(z-GetWorldY())-y
        --adjust by percent--
        xScreen = xScreen-((xScreen-GetScreenX()/2)/100*30)
        yScreen = yScreen-((yScreen-GetScreenY()/2)/100*30)
        return xScreen, yScreen
    end
end

function InhibTimer()
--Tick = GetTickCount()
	for i,inhibit in pairs(Inhibits) do
		if inhibit.object ~= nil then
			if inhibit.status == 'destoryed' then
				if CfgSettings.Minimap then
					if Map == 1 then
						if inhibit.team == 100 then 
						DrawTextMinimap(TimeFormat(inhibit.shatter),inhibit.x-100,inhibit.z-100,Color.Yellow)
						else 
						DrawTextMinimap(TimeFormat(inhibit.shatter),inhibit.x-600,inhibit.z-600,Color.Yellow) 
						end
					end
				end
				if inhibit.shatter >= Tick then 
					DrawTextObject('\n\n\n\n\n\n\n'..TimeFormat(inhibit.shatter),inhibit.object,Color.White)
					else 
					inhibit.status = 'spawned'
				end	
			end		
		elseif inhibit.object == nil then
			for i = 1, objManager:GetMaxObjects(), 1 do
				object = objManager:GetObject(i)
				if object ~= nil then
					if object.charName == 'Order_Inhibit_Gem.troy' and inhibit.team == 100 and GetDistance(inhibit, object) < 100 then
						inhibit.object = object
						inhibit.status = 'spawned'
						--print("BLUE Team Inhibitor Set: ",inhibit,object)
					elseif object.charName == 'Chaos_Inhibit_Gem.troy' and inhibit.team == 200 and GetDistance(inhibit, object) < 100 then
						inhibit.object = object
						inhibit.status = 'spawned'
						--print("RED Team Inhibitor Set: ",inhibit,object)
					end					
				end
			end
		end
	end	
end

function OnCreateObj(o)
	--Inhibs
	check_inhib(o)
	
	if IsMonster(o) then			
		start_tracking(o)
		--printtext("Tracking now!")	  
	end 
end

function GetRespawnTime(o)
	local tempPrefix = WhatMonster(o)	
	local tempTime = 0
		--Respawn times in miliseconds
		
		if tempPrefix == prefixes[1] then --Dragon
			tempTime = GetTickCount()+360000
		elseif tempPrefix == prefixes[2] then --AncientGolem
			tempTime = GetTickCount()+300000
		elseif tempPrefix == prefixes[3] then --LizardElder
			tempTime = GetTickCount()+300000
		elseif tempPrefix == prefixes[4] then --Golem
			tempTime = GetTickCount()+50000
		elseif tempPrefix == prefixes[5] then --Wolve
			tempTime = GetTickCount()+50000
		elseif tempPrefix == prefixes[6] then --WraithWight
			tempTime = GetTickCount()+50000
		elseif tempPrefix == prefixes[7] then --Worm (Baron)
			tempTime = GetTickCount()+420000
		elseif tempPrefix == prefixes[8] then --Wight
			tempTime = GetTickCount()+50000
		end
		return tempTime
end


function starts_with(s, sub)
    return s:sub(1,string.len(sub))==sub
end

function IsMonster(o)
    if o ~= nil and is_valid(o) and o.name ~= nil and o.charName ~= nil then
        for i=1,#prefixes do
            local prefix = prefixes[i]
            -- name is the short thing, charName is name+numbers
            if starts_with(o.name, prefix) then
                return true
            end
        end
    end
    return false
end

function WhatMonster(o)
if o ~= nil and is_valid(o) and o.name ~= nil and o.charName ~= nil then
        for i=1,#prefixes do
            local prefix = prefixes[i]
            -- name is the short thing, charName is name+numbers
            if starts_with(o.name, prefix) then
                return prefix
            end
        end
    end
    return nil
end

function start_tracking(o)
    local key = get_key(o)    
    track[key] = {object=o, button_value=default_button_value, started=os.clock()} --GetRespawnTime(o)
end

function get_key(o)
    return tostring(o.id)..','..o.name..','..o.charName
end

function check_inhib(object)
if object ~= nil then
		if object.charName == 'Chaos_Inhibit_Crystal_Shatter.troy' then
			for i,inhibit in pairs(Inhibits) do
				if inhibit.object ~= nil and inhibit.team == 100 and GetDistance(object, inhibit) < 100 then
					inhibit.status = 'destoryed'
					inhibit.shatter = GetTickCount()+240000
					--print('BLUE Team Inhibitor is destoryed')
				end
			end
		elseif object.charName == 'Order_Inhibit_Crystal_Shatter.troy' then
			for i,inhibit in pairs(Inhibits) do
				if inhibit.object ~= nil and inhibit.team == 200 and GetDistance(object, inhibit) < 100 then
					inhibit.status = 'destoryed'
					inhibit.shatter = GetTickCount()+240000
					--print('PURPLE Team Inhibitor is destoryed')
				end
			end
		end		
	end
end

function is_alive(o)
    return o.dead == 0 and o.health > 0
end

function is_valid(o)
    return o.valid == 1
end


function TimeFormat(Time)
	if Time ~= nil and Time > 0 then
		Seconds = math.floor((Time-GetTickCount())/1000)
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
	return "0:00"
end

SetTimerCallback('OnTick')