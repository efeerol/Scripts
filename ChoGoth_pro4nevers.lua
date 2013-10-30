--[[
Very basic Cho'Gath script by cookiec1025/pro4never

Press Spacebar to win or use onscreen drawing to help improve your aim!
-]]

require "GUI_Framework"
require "Utils"

--[[CONFIG]]--
local target
local predictLoc
local myHero = GetSelf()

local ChoWindow
local colorOn = 0xFF02A543--Green
local colorOff = 0xFFFF1A00--Red

local comboKey = 32--Space Key
local smiteKey = 127--Delete key

local lastAttackTime = GetClock()

local showRupture = true

local useRupture = true
local useScream = true
local useFeast = true
local useSmite = true
--[[END CONFIG]]--

function OnTick()
	target = GetWeakEnemy("MAGIC", 900)	
	if target ~= nil then
		predictLoc = getFireaheadLocation(target,11,0)		
		if showRupture and predictLoc ~= nil then
			DrawCircle(predictLoc.x,predictLoc.y,predictLoc.z,175,2)		
		end
	end	
	if IsKeyDown(comboKey) == 1 then
		if target ~= nil then				
			if useRupture and predictLoc ~= nil and CanUseSpell('Q') == 1 and GetDistance(myHero,predictLoc) < 900 then			
				CastSpellXYZ('Q',predictLoc.x,predictLoc.y,predictLoc.z)
			elseif useScream and CanUseSpell('W') == 1 and GetDistance(myHero,target) < 700 then
				CastSpellXYZ('W',target.x,target.y,target.z)
			elseif GetDistance(myHero,target) < 250 then	
				if GetDistance(myHero,target) < 150 then
					if useFeast and CanUseSpell('R') == 1 then
						CastSpellTarget('R',target)
					elseif IsAttackReady() then
						AttackTarget(target)	
						lastAttackTime = GetClock()
					end
				elseif GetClock() - lastAttackTime > 250 then
					MoveToXYZ(target.x,target.y,target.z)
				end
			end
		end
		MoveToMouse()
	end		
	
	if useSmite and IsKeyDown(smiteKey) == 1 then
		autoSmite()
	end
	
	CustomCircle(950,4,3,myHero)
	CustomCircle(680,1,4,myHero)
end

function autoSmite()
	if myHero.SummonerD == "SummonerSmite" then
			CastHotkey("AUTO 100,30000 SPELLD:SMITESTEAL RANGE=600 TRUE COOLDOWN")
	elseif myHero.SummonerF == "SummonerSmite" then
			CastHotkey("AUTO 100,30000 SPELLF:SMITESTEAL RANGE=600 TRUE COOLDOWN")
	end
end

function toggleVariable(variable, child)
	variable = not variable
	if variable then
		child.color = colorOn
		child.value = "ON"
	else
		child.color = colorOff
		child.value = "OFF"
	end
end

function showRupture_Click(window, child)
	showRupture = not showRupture
	if showRupture then
		child.color = colorOn
		child.value = "ON"
	else
		child.color = colorOff
		child.value = "OFF"
	end	
end

function useRupture_Click(window, child)
	useRupture = not useRupture
	if useRupture then
		child.color = colorOn
		child.value = "ON"
	else
		child.color = colorOff
		child.value = "OFF"
	end
end

function useScream_Click(window, child)
	useScream = not useScream
	if useScream then	
		child.color = colorOn
		child.value = "ON"
	else
		child.color = colorOff
		child.value = "OFF"
	end
end

function useFeast_Click(window, child)
	useFeast = not useFeast
	if useFeast then	
		child.color = colorOn
		child.value = "ON"
	else
		child.color = colorOff
		child.value = "OFF"
	end
end

function useSmite_Click(window, child)
	useSmite = not useSmite
	if useSmite then
		child.color = colorOn
		child.value = "ON"
	else
		child.color = colorOff
		child.value = "OFF"
	end
end


--Helper method so we have a proper structure for our fireahead location
function getFireaheadLocation(target,casttime,traveltime)
	local _x,_y,_z = GetFireahead(target,casttime,traveltime)
	return {x = _x, y=_y, z=_z}
end

SetTimerCallback("OnTick")
printtext("\nCho'Goth ACTIVATE!\n")
ChoWindow = CreateNewWindow("Pro4Never's Cho'Goth", 800,200,250,GetScriptNumber())
InsertChild(ChoWindow,"Show Rupture:","ON",GetScriptNumber(),colorOn,showRupture_Click)
InsertChild(ChoWindow,"Use Rupture:","ON",GetScriptNumber(),colorOn,useRupture_Click)
InsertChild(ChoWindow,"Use Scream:","ON",GetScriptNumber(),colorOn,useScream_Click)
InsertChild(ChoWindow,"Use Feast:","ON",GetScriptNumber(),colorOn,useFeast_Click)
InsertChild(ChoWindow,"Auto Smite:","ON",GetScriptNumber(),colorOn,useSmite_Click)
