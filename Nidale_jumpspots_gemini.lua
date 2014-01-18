require "Utils"

holdKey = string.byte("G") -- Key to hold to automate moving Nidalee

------------- Configuration ------------------

local moveNidalee	= false -- Enables automatically moving Nidalee
local showLocationsInRange = 3000 -- When you hold G, pounce locations within 3,000 units will be shown
local showClose = true -- Shows pounce locations that are close to you while true
local showCloseRange = 800 -- Range for above showClose variable
------------ > Don't touch anything below here < --------------

if myHero.name ~= "Nidalee" then return end

local blue = 0x000099
local green = 0x00FF00

pounceSpots = {

	worksWell = { 

		Locations = {
{ x = 5050.10, 	y = -63.04, z = 10514.81},  -- Baron #1	
{ x = 4950.10, 	y = -63.04, z = 11900},  -- Purple Side: Grave Above Baron #1
{ x = 4950.10, 	y = -63.04, z = 11600},  -- Purple Side: Grave Above Baron #2
{ x = 7300.00, 	y = 54.95, z = 9079.00},  -- Purple Side: Wraith Camp #1
{ x = 7035.00, 	y = 54.95, z = 8795.00},  -- Purple Side: Wraith Camp #2
{ x = 2800.00, 	y = 54.95, z = 6100.00},  -- Blue Side: Wolves #1
{ x = 2600.00, 	y = 54.95, z = 5900.00},  -- Blue Side: Wolves #2
{ x = 2700.00, 	y = 54.95, z = 6400.00},  -- Blue Side: Wolves #3
{ x = 2400.00, 	y = 54.95, z = 6400.00},  -- Blue Side: Wolves #4
{ x = 3325.00, 	y = 54.95, z = 6500.00},  -- Blue Side: Wolves #5
{ x = 3200.00, 	y = 54.95, z = 6750.00},  -- Blue Side: Wolves #6
{ x = 3580.00, 	y = 54.95, z = 6200.00},  -- Blue Side: Wolves #7
{ x = 3800.00, 	y = 54.95, z = 6000.00},  -- Blue Side: Wolves #8
{ x = 3200.00, 	y = 54.95, z = 7100.00},  -- Blue Side: Blue Buff #1
{ x = 3200.00, 	y = 54.95, z = 7400.00},  -- Blue Side: Blue Buff #2
{ x = 3500.00, 	y = 54.95, z = 7500.00},  -- Blue Side: Blue Buff #3
{ x = 3650.00, 	y = 54.95, z = 7150.00},  -- Blue Side: Blue Buff #4
{ x = 3700.00, 	y = 54.95, z = 7700.00},  -- Blue Side: Blue Buff #5
{ x = 3900.00, 	y = 54.95, z = 7900.00},  -- Blue Side: Blue Buff #6
{ x = 1850.00, 	y = 54.95, z = 8000.00},  -- Blue Side: Wall Leading to Top Lane #1
{ x = 1750.00, 	y = 54.95, z = 7750.00},  -- Blue Side: Wall Leading to Top Lane #2
{ x = 1600.00, 	y = 54.95, z = 8540.00},  -- Blue Side: Wall Leading to Top Lane #3
{ x = 1261.00, 	y = 54.95, z = 8595.00},  -- Blue Side: Wall Leading to Top Lane #4
{ x = 2175.00, 	y = 54.95, z = 8917.00},  -- Blue Side: Wall Leading to Top Lane #5
{ x = 2440.00, 	y = 54.95, z = 8945.00},  -- Blue Side: Wall Leading to Top Lane #6 
{ x = 2440.00, 	y = 54.95, z = 9250.00},  -- Blue Side: Wall Leading to Top Lane #7 
{ x = 2120.00, 	y = 54.95, z = 9350.00},  -- Blue Side: Wall Leading to Top Lane #8 
{ x = 2893.00, 	y = 54.95, z = 9281.00},  -- Blue Side: River Leading to Top Lane #1
{ x = 3071.00, 	y = 54.95, z = 9312.00},  -- Blue Side: River Leading to Top Lane #2
{ x = 3010.00, 	y = 54.95, z = 9700.00},  -- Blue Side: River Leading to Top Lane #3
{ x = 2808.00, 	y = 54.95, z = 9565.00},  -- Blue Side: River Leading to Top Lane #4
{ x = 2806.00, 	y = 54.95, z = 10102.00},  -- Blue Side: River Leading to Top Lane #5
{ x = 2599.00, 	y = 54.95, z = 9872.00},  -- Blue Side: River Leading to Top Lane #6
{ x = 6700.00, 	y = 54.95, z = 8050.00},  -- Mid Lane: Top Brush #1
{ x = 6850.00, 	y = 54.95, z = 8250.00},  -- Mid Lane: Top Brush #2
{ x = 6500.00, 	y = 54.95, z = 8300.00},  -- Mid Lane: Top Brush #3
{ x = 6700.00, 	y = 54.95, z = 8500.00},  -- Mid Lane: Top Brush #4
{ x = 6175.00, 	y = 54.95, z = 8475.00},  -- Mid Lane: Top Brush #5
{ x = 6350.00, 	y = 54.95, z = 8750.00}  -- Mid Lane: Top Brush #6					
		},
color = green,
	},		

needsSomeWork = 	{ 
						Locations = {
{ x = 5300.10, 	y = -63.04, z = 10990},  -- Baron #2   << Needs some work >>
{ x = 5990.10, 	y = -63.04, z = 11845},  -- Purple Side: Double Golem #1   << Needs some work >>
{ x = 6050.10, 	y = -63.04, z = 11490},  -- Purple Side: Double Golem #2    << Needs some work >>
{ x = 6380.00, 	y = 54.95, z = 10800.00},  -- Purple Side: Red Buff #1   << Needs some work >>
{ x = 6165.00, 	y = 54.95, z = 11150.00}  -- Purple Side: Red Buff #2   << Needs some work >>
									},
color = blue,
					}
}

drawPounceSpots = false

function OnLoad()
--removed
end

function OnTick()
	OnDraw()
	OnLoad()
	for i,group in pairs(pounceSpots) do
		for x, pounceSpot in pairs(group.Locations) do
				if pounceConfig.PerfectPounce and moveNidalee and GetDistance(pounceSpot, mousePos) <= 100 then
						MoveToXYZ(pounceSpot.x, 1, pounceSpot.z) -- Moves sNidalee			
				elseif pounceConfig.PerfectPounce and pounceConfig.autoPounce and GetDistance(pounceSpot) <= 100 then
						CastSpellXYZ("W", pounceSpot.x, 1, pounceSpot.z) -- Casts W				
				end					
		end			
	end
	if pounceConfig.hold then
			drawPounceSpots = true -- Draws all pounce spots in range of predetermined units
			moveNidalee = true -- Enable Pouncing
	elseif pounceConfig.hold == false then
			drawPounceSpots = false -- Stops drawing all pounce spots past predetermined units
			moveNidalee = false -- Enable Pouncing
	end
end

function OnWndMsg(msg,key)
	if msg == KEY_DOWN and key == 96 then
			PrintChat(tostring(mousePos.x).. " " .. tostring(mousePos.z))
	end		
	SC__OnWndMsg(msg,key)
end



function drawCircles(x,y,z,color)
	DrawCircle(x, y, z, 100, color)
end

function OnDraw()
	for i,group in pairs(pounceSpots) do
			if drawPounceSpots then
				for x, pounceSpot in pairs(group.Locations) do
					if GetDistance(pounceSpot) < showLocationsInRange then
						if GetDistance(pounceSpot, mousePos) <= 100 then
							pouncecolor = 0xFFFFFF
						else
							pouncecolor = group.color
						end
						drawCircles(pounceSpot.x, pounceSpot.y, pounceSpot.z,pouncecolor)
					end
				end
			elseif showClose then
				for x, pounceSpot in pairs(group.Locations) do
					if GetDistance(pounceSpot) <= showCloseRange then
						if GetDistance(pounceSpot, mousePos) <= 100 then
							pouncecolor = 0xFFFFFF
						else
							pouncecolor = group.color
						end
						drawCircles(pounceSpot.x, pounceSpot.y, pounceSpot.z,pouncecolor)
					end
				end
			end
	end	
end

	pounceConfig = scriptConfig("PerfectPounce", "PerfectPounce")
	pounceConfig:addParam("EnablePerfectPounce", "PerfectPounce", SCRIPT_PARAM_ONOFF, true)
	pounceConfig:addParam("EnableAutoPounce", "AutoPounce", SCRIPT_PARAM_ONOFF, true)
	pounceConfig:addParam("hold", "Hotkey", SCRIPT_PARAM_ONKEYDOWN, false, holdKey)
	

SetTimerCallback("OnTick")