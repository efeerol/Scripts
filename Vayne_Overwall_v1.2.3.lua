------------------------------------------------
------------------------------------------------
--Vayne Overwall tumbling
----by Lua
------------------------------------------------
------------------------------------------------

require "utils"

local version = "1.2.3"
local TumbleSpot = { x=11575, y=52, z=4650 }
local TumbleSpotBackward = { x=11615, y=52, z=4670 }
local TumbleSpotBackward2 = { x=11685, y=52, z=4700 }
local TumblePoint = { x=11305, y=-62, z=4482 }
local AfterTumle = { x=11220, y=-62, z=4390 }
local Afterwalk = 0
local Afterwalk_stop = 0
local StuckPoint = 0
local StuckCount = 0

VayneOverwallConfig = scriptConfig("Vayne Overwall Config", "VayneOverwallConfig")
VayneOverwallConfig:addParam("tumblewall", "Overwall Tumbling", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("N"))
VayneOverwallConfig:permaShow("tumblewall")

if myHero.name ~= "Vayne" then return end

function OnTick()
    if VayneOverwallConfig.tumblewall then
		if Afterwalk==0 and StuckPoint~=GetDistance(TumbleSpot,myHero) then
			if GetDistance(TumbleSpot,myHero)<1000 and GetDistance(TumbleSpot,myHero)>23 and myHero.y>0 then
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
					if GetDistance(TumbleSpot,myHero)<19 then DoIt() end
				end
			end
		else
			if Afterwalk ~= 0 and GetClock() > Afterwalk then
				if Afterwalk_stop==0 then
					StopMove()
					Afterwalk_stop=1
					Afterwalk = GetClock()+250
				else
					MoveToXYZ(AfterTumle.x,AfterTumle.y,AfterTumle.z)
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
		--print(GetDistance(TumbleSpot,myHero))
	end
	ShowMeAWay()
end

function DoIt()
	if CanCastSpell("Q") then
		--print(GetDistance(TumbleSpot,myHero))
		MoveToXYZ(TumbleSpot.x,TumbleSpot.y,TumbleSpot.z)
		CastSpellXYZ("Q", TumblePoint.x, 0, TumblePoint.z)
		Afterwalk = GetClock()+500
		Afterwalk_stop=0
	else
		StuckCount = 0
	end
end

function ShowMeAWay()
    if VayneOverwallConfig.tumblewall then
		if GetDistance(TumbleSpot,myHero)<1000 and GetDistance(TumbleSpot,myHero)>30 and myHero.y>0 then
			DrawCircle(TumbleSpot.x, TumbleSpot.y, TumbleSpot.z, 150, 0x02)
			DrawCircle(TumbleSpot.x, TumbleSpot.y, TumbleSpot.z, 153, 0x02)
		else
			if GetDistance(TumbleSpot,myHero)>1000 or myHero.y<0 then
				DrawCircle(TumbleSpot.x, TumbleSpot.y, TumbleSpot.z, 150, 0x000099)
				DrawCircle(TumbleSpot.x, TumbleSpot.y, TumbleSpot.z, 153, 0x000099)
			else
				DrawCircle(TumbleSpot.x, TumbleSpot.y, TumbleSpot.z, 150, 0x02)
				DrawCircle(TumbleSpot.x, TumbleSpot.y, TumbleSpot.z, 153, 0x02)
			end
		end
	else
			DrawCircle(TumbleSpot.x, TumbleSpot.y, TumbleSpot.z, 150, 0x000099)
			DrawCircle(TumbleSpot.x, TumbleSpot.y, TumbleSpot.z, 153, 0x000099)
	end
end

SetTimerCallback("OnTick")