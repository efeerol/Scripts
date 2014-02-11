--Lua's InhibiTimer v1.0

require 'Utils'
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

function OnTick()
	Tick = GetTickCount()
	for i,inhibit in pairs(Inhibits) do
		if inhibit.object ~= nil then
		--	if inhibit.status == 'spawned' then DrawTextObject('\n\n\n\n\n\n\n Spawned',inhibit.object,Color.White) end
			if inhibit.status == 'destoryed' then
				if inhibit.shatter >= Tick then DrawTextObject('\n\n\n\n\n\n\n'..TimeFormat(inhibit.shatter),inhibit.object,Color.White)
				else inhibit.status = 'spawned' end
--[[			elseif inhibit.status == nil then --REMOVED, this couldn't get inhibitor is up or down
				for i = 1, objManager:GetMaxObjects(), 1 do
					object = objManager:GetObject(i)
					if object ~= nil and inhibit.status == nil then
						if object.charName == 'Order_Inhibit_Crystal_Glow.troy' and inhibit.team == 100 and GetDistance(inhibit, object) < 100 then
							inhibit.status = 'spawned'
							print("BLUE TEAM Inhibitor Confirm: ",inhibit,object)
						elseif object.charName == 'Chaos_Inhibit_Crystal_Glow.troy' and inhibit.team == 200 and GetDistance(inhibit, object) < 100 then
							inhibit.status = 'spawned'
							print("RED TEAM Inhibitor Confirm: ",inhibit,object)
						end
					end
				end
				if inhibit.status == nil then
					inhibit.status = 'unknown'
					inhibit.shatter = GetTickCount()+240000
					print('This inhibitor was destoryed before load',inhibit)
				end ]]--
			elseif inhibit.status ~= 'spawned' then
				if inhibit.shatter >= Tick then DrawTextObject('\n\n\n\n\n\n\n'..TimeFormat(inhibit.shatter)..'\n(?)',inhibit.object,Color.White)
				else inhibit.status = 'spawned' end
			end
		elseif inhibit.object == nil then
			for i = 1, objManager:GetMaxObjects(), 1 do
				object = objManager:GetObject(i)
				if object ~= nil then
					if object.charName == 'Order_Inhibit_Gem.troy' and inhibit.team == 100 and GetDistance(inhibit, object) < 100 then
						inhibit.object = object
						inhibit.status = 'spawned'
						print("BLUE TEAM Inhibitor Set: ",inhibit,object)
					elseif object.charName == 'Chaos_Inhibit_Gem.troy' and inhibit.team == 200 and GetDistance(inhibit, object) < 100 then
						inhibit.object = object
						inhibit.status = 'spawned'
						print("RED TEAM Inhibitor Set: ",inhibit,object)
					end
				end
			end
			if inhibit.object == nil then
				inhibit.status = 'unknown'
				inhibit.shatter = GetTickCount()+240000
				print('This inhibitor cannot found the object',inhibit)
			end
		end
	end
end

function OnCreateObj(object)
	if object ~= nil then
		if object.charName == 'Chaos_Inhibit_Crystal_Shatter.troy' then
			for i,inhibit in pairs(Inhibits) do
				if inhibit.object ~= nil and inhibit.team == 100 and GetDistance(object, inhibit) < 100 then
					inhibit.status = 'destoryed'
					inhibit.shatter = GetTickCount()+240000
				end
			end
		elseif object.charName == 'Order_Inhibit_Crystal_Shatter.troy' then
			for i,inhibit in pairs(Inhibits) do
				if inhibit.object ~= nil and inhibit.team == 200 and GetDistance(object, inhibit) < 100 then
					inhibit.status = 'destoryed'
					inhibit.shatter = GetTickCount()+240000
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