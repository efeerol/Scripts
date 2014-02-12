--Lua's InhibiTimer v2.1
----Supported Maps: Proving Grounds, Summoners Rift, Twisted Treeline

require 'Utils'
local uiconfig = require 'uiconfig'

local Unlock = 0
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
elseif Map == 0 then
	Inhibits = {
	--BLU
		BLUE = {x = 3111, y = -201, z = 3190, team = 100, object = nil, status = nil, shatter = 0},
	--RED
		RED = {x = 9690, y = -190, z = 9525, team = 200, object = nil, status = nil, shatter = 0}
	}
elseif Map == 3 then
	Inhibits = {
	--BLU
		Altar_Left = {x = 5329, y = -37, z = 6758, team = 100, object = nil, status = nil, shatter = 0},
		Order_Top = {x = 2147, y = 14, z = 8421, team = 100, object = nil, status = nil, shatter = 0},
		Order_Bot = {x = 2127, y = -4, z = 6147, team = 100, object = nil, status = nil, shatter = 0},
	--RED
		Altar_Right = {x = 10072, y = -37, z = 6762, team = 200, object = nil, status = nil, shatter = 0},
		Chaos_Top = {x = 13276, y = 23, z = 8417, team = 200, object = nil, status = nil, shatter = 0},
		Chaos_Bot = {x = 13286, y = 11, z = 6125, team = 200, object = nil, status = nil, shatter = 0}
	}
else return end

InhibiTimer, menu = uiconfig.add_menu('Inhibitor Timer')
menu.checkbox('Minimap', 'Minimap', true)

function OnTick()
	Tick = GetTickCount()
	for i,inhibit in pairs(Inhibits) do
		if inhibit.object ~= nil then
			if inhibit.status == 'destoryed' then
				if InhibiTimer.Minimap then
					if Map == 1 then
						if inhibit.team == 100 then DrawTextMinimap(TimeFormat(inhibit.shatter),inhibit.x-100,inhibit.z-100,Color.Yellow)
						else DrawTextMinimap(TimeFormat(inhibit.shatter),inhibit.x-600,inhibit.z-600,Color.Yellow) end
					elseif Map == 0 then
						if inhibit.team == 100 then DrawTextMinimap(TimeFormat(inhibit.shatter),inhibit.x-200,inhibit.z+200,Color.Yellow)
						else DrawTextMinimap(TimeFormat(inhibit.shatter),inhibit.x+400,inhibit.z+800,Color.Yellow) end
					else
						if inhibit.team == 100 then DrawTextMinimap(TimeFormat(inhibit.shatter),inhibit.x-900,inhibit.z-950,Color.Yellow)
						else DrawTextMinimap(TimeFormat(inhibit.shatter),inhibit.x-1500,inhibit.z-950,Color.Yellow) end
					end
				end
				if inhibit.shatter >= Tick then DrawTextObject('\n\n\n\n\n\n\n'..TimeFormat(inhibit.shatter),inhibit.object,Color.White)
				else inhibit.status = 'spawned' end
			elseif inhibit.status == 'Locked' then
				if InhibiTimer.Minimap then
					if inhibit.team == 100 then DrawTextMinimap(TimeFormat(inhibit.shatter),inhibit.x-900,inhibit.z-950,Color.Yellow)
					else DrawTextMinimap(TimeFormat(inhibit.shatter),inhibit.x-1500,inhibit.z-950,Color.Yellow) end
				end
				if inhibit.shatter >= Tick then DrawTextObject('\n\n\n\n\n\n\n'..TimeFormat(inhibit.shatter),inhibit.object,Color.White)
				else inhibit.status = 'Unlocked' end
			end
		elseif inhibit.object == nil then
			for i = 1, objManager:GetMaxObjects(), 1 do
				object = objManager:GetObject(i)
				if object ~= nil then
					if object.charName == 'Order_Inhibit_Gem.troy' and inhibit.team == 100 and GetDistance(inhibit, object) < 100 then
						inhibit.object = object
						inhibit.status = 'spawned'
						print("BLUE Team Inhibitor Set: ",inhibit,object)
					elseif object.charName == 'Chaos_Inhibit_Gem.troy' and inhibit.team == 200 and GetDistance(inhibit, object) < 100 then
						inhibit.object = object
						inhibit.status = 'spawned'
						print("RED Team Inhibitor Set: ",inhibit,object)
					elseif Map == 3 then
						if object.charName == 'TT_Buffplat_L' and inhibit.team == 100 and GetDistance(inhibit, object) < 100 then
							inhibit.object = object
							inhibit.status = 'setup'
							print("Left Altar Set: ",inhibit,object)
						elseif object.charName == 'TT_Buffplat_R' and inhibit.team == 200 and GetDistance(inhibit, object) < 100 then
							inhibit.object = object
							inhibit.status = 'setup'
							print("Right Altar Set: ",inhibit,object)
						end
					end
				end
			end
		end
	end
	if Map == 3 and Unlock > 0 and Unlock > Tick then
		DrawTextMinimap(TimeFormat(Unlock),Inhibits.Altar_Left.x-900,Inhibits.Altar_Left.z-950,Color.Yellow)
		if Inhibits.Altar_Left.object ~= nil then DrawTextObject('\n\n\n\n\n\n\n'..TimeFormat(Unlock),Inhibits.Altar_Left.object,Color.White) end
		DrawTextMinimap(TimeFormat(Unlock),Inhibits.Altar_Right.x-1500,Inhibits.Altar_Right.z-950,Color.Yellow)
		if Inhibits.Altar_Right.object ~= nil then DrawTextObject('\n\n\n\n\n\n\n'..TimeFormat(Unlock),Inhibits.Altar_Right.object,Color.White) end
	end
end

function OnCreateObj(object)
	if object ~= nil then
		if object.charName == 'Chaos_Inhibit_Crystal_Shatter.troy' then
			for i,inhibit in pairs(Inhibits) do
				if inhibit.object ~= nil and inhibit.team == 100 and GetDistance(object, inhibit) < 100 then
					inhibit.status = 'destoryed'
					inhibit.shatter = GetTickCount()+240000
					print('BLUE Team Inhibitor is destoryed')
				end
			end
		elseif object.charName == 'Order_Inhibit_Crystal_Shatter.troy' then
			for i,inhibit in pairs(Inhibits) do
				if inhibit.object ~= nil and inhibit.team == 200 and GetDistance(object, inhibit) < 100 then
					inhibit.status = 'destoryed'
					inhibit.shatter = GetTickCount()+240000
					print('PURPLE Team Inhibitor is destoryed')
				end
			end
		elseif Map == 3 then
			if Unlock == 0 and (object.charName == 'Minion_T100L0S01N0001' or object.charName == 'Minion_T200L0S01N0001') then
				Unlock = GetTickCount()+105000
				print('Minion Spawned, Altar Timer Setup')
			elseif Unlock > 0 and (object.charName == 'TT_Audio-Altar_West_Unlocked.troy' or object.charName == 'TT_Audio-Altar_East_Unlocked.troy') then
				Unlock = -1
				print('Altar Started')
			end
			if string.find(object.charName, 'LockComplete') ~= nil then
				if string.find(object.charName, 'L.troy') ~= nil then
					Inhibits.Altar_Left.status = 'Locked'
					Inhibits.Altar_Left.shatter = GetTickCount()+88000
					print('Left Altar is locked for 90s')
				else
					Inhibits.Altar_Right.status = 'Locked'
					Inhibits.Altar_Right.shatter = GetTickCount()+88000
					print('Right Altar is locked for 90s')
				end
			elseif string.find(object.charName, 'Unlock') ~= nil then
				if Inhibits.Altar_Left.status ~= 'setup' and string.find(object.charName, 'L.troy') ~= nil then
					Inhibits.Altar_Left.status = 'Unlocked'
					Inhibits.Altar_Left.shatter = GetTickCount()
					print('Left Altar is unlocked')
				elseif Inhibits.Altar_Right.status ~= 'setup' then
					Inhibits.Altar_Right.status = 'Unlocked'
					Inhibits.Altar_Right.shatter = GetTickCount()
					print('Right Altar is unlocked')
				end
			end
		end
	end
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