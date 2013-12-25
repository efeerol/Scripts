--[[
Ziggs... 
FYI... this won't work as great as you might imagine. 
The Q and R, and W for that matter... are all things that probably need
some human touches, not scripted... but such is life. Lets see how effective
this can actually be!?! Also... i love you all <3

-xXGeminiXx
--]]
require "Utils"

local target					--Current target
local myHero = GetSelf()		--My Character
local lastAttack = GetClock()   --For later use

function Boom()
--	UtilityFunction()
	Draw()
	DrawText("xXGeminiXx's OneButton Ziggs", 105, 25, Color.Green)	
	if ZiggsConfig.combo then combo() end
	if ZiggsConfig.harass then harass() end
	if target == nil and ZiggsConfig.combo then
		MoveToMouse() 
	end
	if target == nil and ZiggsConfig.harass then
		MoveToMouse() 
	end
	
end

function GetGlobalTarget() --Credits to Pro4Never
	local ultTarget = objManager:GetHero(1)
	for i = 2, objManager:GetMaxHeroes() do
		local t = objManager:GetHero(i)
		if t.health < ultTarget.health and t.team ~= myHero.team and t.visible == 1 and t.dead==0 then
			ultTarget = t
		end
	end
	if ultTarget.team == myHero.team or ultTarget.visible == 0 or ultTarget.dead == 1 then
		ultTarget = nil
	end
	return ultTarget
end

function getFireaheadLocation(target,casttime,traveltime) --Again, Pro4Never
	local _x,_y,_z = GetFireahead(target,casttime,traveltime)
	return {x = _x, y=_y, z=_z}
end

function GetIgniteDamage() --for later use
	return myHero.selflevel*20+50
end

function GetSheenBonusPercentage()
	local boost = 1	
	if GetInventorySlot(3057) ~= nil then
		boost = 2
	elseif GetInventorySlot(3025) ~= nil then
		boost = 2.25
	elseif GetInventorySlot(3087) ~= nil then
		boost = 2.5
	end
	return boost
end

function Initialize()
	printtext("\nWelcome to Gemmy's Ziggs!\n")
	SetTimerCallback("Boom")

	ZiggsConfig = scriptConfig("ZiggsConfig", "ZiggsConfig")
	ZiggsConfig:addParam("combo", "combo", SCRIPT_PARAM_ONKEYDOWN, false, 84)
	ZiggsConfig:addParam("harass", "harass", SCRIPT_PARAM_ONKEYDOWN, false, 90)

end

function Draw()
	DrawCircle(myHero.x, myHero.y, myHero.z, 800, 0x02)
end

function DrawSphere(radius,thickness,color,x,y,z)
    for j=1, thickness do
        local ycircle = (j*(radius/thickness*2)-radius)
        local r = math.sqrt(radius^2-ycircle^2)
        ycircle = ycircle/1.3
        DrawCircle(x,y+ycircle,z,r,color)
    end
end

function ZiggsQ(target)
	if CanUseSpell("Q") == 1 then
		CastSpellTarget("Q",target)
	end
end

function ZiggsW(target)
	if CanUseSpell("W") == 1 then
		CastSpellTarget("W",target)
	end
end

function ZiggsE(target)
	if CanUseSpell("E") == 1 then
		if CanUseSpell("E") == 1 then
			CastSpellTarget("E",target)
		end
	end
end

function ZiggsR(target)
	if CanUseSpell("R") == 1 then
	target = GetGlobalTarget()
	if target ~= nil then
			--DrawText("Lowest health enemy is " .. target.name .. " with " .. target.health .. " health", 0,70,0xFFFFFF00)
			--local ultDMG = 45*GetSpellLevel("R")+30+.2*myHero.ap
		--	if target.health < ultDMG * 2 then				
				targetLoc = GetMEC(550, 5300, target)
				if targetLoc ~= nil then
					CastSpellXYZ('R',targetLoc.x,targetLoc.y,targetLoc.z)
				end
			--end
	end
		CastSummonerIgnite(target)
		CastSummonerExhaust(target)
		UseAllItems(target)
	target = GetWeakEnemy('MAGIC',1000,"NEARMOUSE")
	end
end

function combo()

target = GetWeakEnemy('MAGIC',1000,"NEARMOUSE")

	if target ~= nil then	
	DrawText("Rapemode ENGAGED", 125, 40, Color.Red)
	DrawSphere(50,25,3,target.x,target.y+300,target.z)
	
		if GetDistance(myHero, target) < 900 then 	
			ZiggsE(target)
		end			
		if GetDistance(myHero, target) < 850 then 	
			ZiggsQ(target)
		end		
		if GetDistance(myHero, target) < 1000 then	
			ZiggsW(target)
			ZiggsW(target)
		end		
		if GetDistance(myHero, target) < 5300 then 	
			ZiggsR(target)
		end		
	end
end

function harass()
target = GetWeakEnemy('MAGIC',1000,"NEARMOUSE")
	if target ~= nil then	
	DrawText("Rapemode ENGAGED", 125, 40, Color.Red)
	DrawSphere(50,25,3,target.x,target.y+300,target.z)
		if GetDistance(myHero, target) < 850 then 	
			ZiggsQ(target)
		end				
	end
end

if myHero.name == "Ziggs" then
	Initialize()
else
	printtext("\nError: Please only run if you are playing with Ziggs\n")
end