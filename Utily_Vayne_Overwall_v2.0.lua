------------------------------------------------
------------------------------------------------
--Vayne Overwall tumbling v2.0
----by Lua
------------------------------------------------
------------------------------------------------

require "utils"
local uiconfig = require "uiconfig"
if myHero.name ~= "Vayne" then return end

local version = "2.0"
local TumbleSpot = { x=6634,  y=56, z=8670 }
local TumblePoint = { x=6298,  y=-64, z=8456 }
local TumbleSpotBackward = { x=6550,  y=56, z=8730 }
local TumbleSpotBackward2 = { x=6715,  y=56, z=8730 }
local DoItCount = 0
local Afterwalk = 0
local Afterwalk_stop = 0
local StuckPoint = 0
local StuckCount = 0

	VayneOverwallConfig, menu = uiconfig.add_menu('Vayne Overwall Config')
	menu.keytoggle('tumblewall', 'Overwall Tumbling', Keys.N, false)
	menu.permashow('tumblewall')

function OnTick()
    if VayneOverwallConfig.tumblewall then
		if Afterwalk==0 and StuckPoint~=GetDistance(TumbleSpot,myHero) then
			if GetDistance(TumbleSpot,myHero)<800 and GetDistance(TumbleSpot,myHero)>23 and myHero.y>0 then
				MoveToXYZ(TumbleSpot.x,TumbleSpot.y,TumbleSpot.z)
				if GetDistance(TumbleSpot,myHero)<80 then
					StuckPoint=GetDistance(TumbleSpot,myHero)
				else StuckCount = 0
				end
			else
				if GetDistance(TumbleSpot,myHero)>19 and GetDistance(TumbleSpot,myHero)<23 then
					StuckPoint=GetDistance(TumbleSpot,myHero)
					MoveToXYZ(TumbleSpotBackward.x,TumbleSpotBackward.y,TumbleSpotBackward.z)
					--print("Backward")
					--print(GetDistance(TumbleSpot,myHero))
				else
					if GetDistance(TumbleSpot,myHero)<19 then
						if DoItCount<3 then DoItCount = DoItCount + 1
						else DoIt()
						end
					end
				end
			end
		else
			if Afterwalk ~= 0 and GetClock() > Afterwalk then
				if Afterwalk_stop==0 then
					StopMove()
					Afterwalk_stop=1
					Afterwalk = GetClock()+350
				else
					MoveToXYZ(TumblePoint.x,TumblePoint.y,8380)
					Afterwalk=0
				end
			end
			if StuckPoint==GetDistance(TumbleSpot,myHero) then
				if StuckCount < 6 then
					--print(StuckCount)
					StuckCount = StuckCount + 1
				else
					--print("Stuck! Moving backward")
					MoveToXYZ(TumbleSpotBackward2.x,TumbleSpotBackward2.y,TumbleSpotBackward2.z)
					StuckCount = 0
				end
			else StuckCount = 0
			end
		end
		ShowMeAWay()
		--print(GetDistance(TumbleSpot,myHero))
	else
		StuckCount = 0
		Afterwalk = 0
		Afterwalk_stop = 0
		DrawCircle(TumbleSpot.x, TumbleSpot.y, TumbleSpot.z, 120, 0x000099)
		DrawCircle(TumbleSpot.x, TumbleSpot.y, TumbleSpot.z, 123, 0x000099)
	end
end

function DoIt()
	if myHero.SpellTimeQ >= 1.0 and myHero.SpellLevelQ > 0 then
		--print(GetDistance(TumbleSpot,myHero))
		MoveToXYZ(TumbleSpot.x,TumbleSpot.y,TumbleSpot.z)
		CastSpellXYZ("Q", TumblePoint.x, 0, TumblePoint.z)
		Afterwalk = GetClock()+500
		Afterwalk_stop=0
		DoItCount = 0
	else
		StuckCount = 0
	end
end

function ShowMeAWay()
	if GetDistance(TumbleSpot,myHero)<800 and GetDistance(TumbleSpot,myHero)>30 and myHero.y>0 then
		DrawCircle(TumbleSpot.x, TumbleSpot.y, TumbleSpot.z, 120, 0x02)
		DrawCircle(TumbleSpot.x, TumbleSpot.y, TumbleSpot.z, 123, 0x02)
	else
		if GetDistance(TumbleSpot,myHero)>800 or myHero.y<0 then
			DrawCircle(TumbleSpot.x, TumbleSpot.y, TumbleSpot.z, 120, 0x000099)
			DrawCircle(TumbleSpot.x, TumbleSpot.y, TumbleSpot.z, 123, 0x000099)
		else
			DrawCircle(TumbleSpot.x, TumbleSpot.y, TumbleSpot.z, 120, 0x02)
			DrawCircle(TumbleSpot.x, TumbleSpot.y, TumbleSpot.z, 123, 0x02)
		end
	end
end

SetTimerCallback("OnTick")