require "Utils" 

AASConfig = scriptConfig("AAS Bot", "AKSbot")
AASConfig:addParam("onoff", "On/Off", SCRIPT_PARAM_ONOFF, true)

local shroud = nil
local delay = 0
 
function OnTick()
if AASConfig.onoff then
    if shroud ~= nil and GetTickCount() > delay + math.random(250,750) and GetDistance(myHero, obj) < 600 then
        UseItemLocation(2043, shroud.x, shroud.y, shroud.z)
    end
end
end
 
function OnCreateObj(obj)
        if obj.charName:find("akali_smoke_bomb_tar_team_red") then
                shroud = obj
				delay = GetTickCount()
        end
       
        if obj.charName:find("VisionWard") and obj.team == myHero.team and GetDistance(obj) < 600 then
                shroud = nil
        end
end

SetTimerCallback("OnTick")