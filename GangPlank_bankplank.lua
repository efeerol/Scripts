--[[
Simplified Gangplank script by Pro4Never
--]]
require "GUI_Framework"
require "Utils"

--[[Config]]--

local target					--Current target
local myHero = GetSelf()		--My Character

local GPWindow					--GUI Window
local colorOn = 0xFF02A543		--Green
local colorOff = 0xFFFF1A00		--Red

local comboKey = 32				--Space
local attackDelay = 300
local lastAttack = GetClock()


local CleanseList = {"Stun_glb", "AlZaharNetherGrasp_tar", "InfiniteDuress_tar", "skarner_ult_tail_tip", "SwapArrow_red", "Global_Taunt", "Global_Fear", "Ahri_Charm_buf", "leBlanc_shackle_tar", "LuxLightBinding_tar", "RunePrison_tar", "DarkBinding_tar", "nassus_wither_tar", "Amumu_SadRobot_Ultwrap", "Amumu_Ultwrap", "maokai_elementalAdvance_root_01", "RengarEMax_tar", "VarusRHitFlash"}

function GP_Tick()
	target = GetWeakEnemy("PHYS", 625)	
	if target ~= nil then
		local dmg = GetQDamage(target)
		DrawText("Q Damage vs " .. target.name .. " = " .. dmg, 0,50,0xFFFFFF00)
	end
	
	if IsKeyDown(comboKey) == 1 then
		--Combo pressed
		if target ~= nil then
			if GetClock() > lastAttack + attackDelay then
				if GetDistance(myHero, target) < myHero.range then
					AttackTarget(target)	
					lastAttack = GetClock()
				elseif CanCastSpell("Q") then
					CastSpellTarget("Q", target)
					lastAttack = GetClock()
				elseif CanCastSpell("E") then
					CastSpellTarget("E", myHero)				
				else
					local intercept = getFireaheadLocation(target,1,4)
					MoveToXYZ(intercept.x,intercept.y,intercept.z)
				end	
				if target.health < GetIgniteDamage() then
					CastSummonerIgnite(target)
				end
			end
		else
			MoveToXYZ(GetCursorWorldX(), GetCursorWorldY(), GetCursorWorldZ())
		end		
	end	
	
	if GetChildByKey("Killsteal:").value == "ON" then
		if target ~= nil then
			local dmg = GetQDamage(target)
			if CanCastSpell("Q") then
				if target.health < dmg then
					CastSpellTarget("Q", target)
					lastAttack = GetClock()
					printtext("\nKillstealing target " .. target.name .. " with ".. math.floor(target.health) .. " health")
				elseif GetChildByKey("Auto Harass:").value == "ON" then
					if GetDistance(myHero, target) < myHero.range and (GetClock() > lastAttack + attackDelay)  then
						AttackTarget(target)	
						lastAttack = GetClock()
					else
						CastSpellTarget("Q", target)
						lastAttack = GetClock()
					end
				end
			end
		end
	end	
	
	
	if GetChildByKey("Auto Farm:").value == "ON" then
		target = GetLowestHealthEnemyMinion(625)
		if target ~= nil then
			local dmg = myHero.baseDamage+myHero.addDamage
			if CanCastSpell("Q") then
				dmg = GetQDamage(target)
				if target.health < dmg then					
					CastSpellTarget("Q", target)
					lastAttack = GetClock()
				end
			elseif target.health < dmg and GetDistance(myHero, target) < myHero.range and (GetClock() > lastAttack + attackDelay)  then
				AttackTarget(target)	
				lastAttack = GetClock()
			end
		end
	end
	
	if GetChildByKey("Auto Ult:").value == "ON" and CanCastSpell("R") then
		target = GetGlobalTarget()
		if target ~= nil then
			DrawText("Lowest health enemy is " .. target.name .. " with " .. target.health .. " health", 0,70,0xFFFFFF00)
			local ballDmg = 45*GetSpellLevel("R")+30+.2*myHero.ap
			if target.health < ballDmg * 2 then				
				targetLoc = GetMEC(600, 9999999, target)
				if targetLoc ~= nil then
					CastSpellXYZ('R',targetLoc.x,targetLoc.y,targetLoc.z)
					printtext("\nUlting target: "..target.name.." with "..math.floor(target.health).." health\n")
				end
			end
		end
	end	
end


function OnCreateObj(object)
	if GetDistance(myHero, object) < 100 then
		if GetChildByKey("Auto Cleanse:").value == "ON" and listContains(CleanseList,object.charName) then	
			if CanCastSpell("W") then
				CastSpellTarget("W", myHero)
			elseif GetInventorySlot(3139) ~= nil then
				UseItemOnTarget(3139, myHero)
			elseif GetInventorySlot(3140) ~= nil  then
				UseItemOnTarget(3140, myHero)			
			end
		end
	end
end

function GetGlobalTarget()
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

function getFireaheadLocation(target,casttime,traveltime)
	local _x,_y,_z = GetFireahead(target,casttime,traveltime)
	return {x = _x, y=_y, z=_z}
end

function GetIgniteDamage()
	return myHero.selflevel*20+50
end

function GetQDamage(t)	
	local qDmg = 25*GetSpellLevel('Q')-5+GetSheenBonusPercentage()*myHero.baseDamage+myHero.addDamage
	return CalcDamage(t,qDmg)		
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

function listContains(list, particleName)
	for _, particle in pairs(list) do
		if particleName:find(particle) then return true end
	end
	return false
end

function toggleChild(window,child)
	if child.value == "ON" then
		child.value = "OFF"
		child.color = colorOff
	else
		child.value = "ON"
		child.color = colorOn
	end
end

function Initialize()
	printtext("\nWelcome to Pro4Never's Bankplank!\n")
	SetTimerCallback("GP_Tick")
	GPWindow = CreateNewWindow("Pro4Never's Bankplank", 800,200,250,GetScriptNumber())
	
	InsertChild(GPWindow,"Auto Farm:","ON",GetScriptNumber(),colorOn,toggleChild)
	InsertChild(GPWindow,"Auto Harass:","ON",GetScriptNumber(),colorOn,toggleChild)	
	InsertChild(GPWindow,"Killsteal:","ON",GetScriptNumber(),colorOn,toggleChild)
	InsertChild(GPWindow,"Auto Ult:","ON",GetScriptNumber(),colorOn,toggleChild)	
	InsertChild(GPWindow,"Auto Cleanse:","ON",GetScriptNumber(),colorOn,toggleChild)
end

if myHero.name == "Gangplank" then
	Initialize()
else
	printtext("\nError: Please only run if you are using gangplank\n")
end