--[[
   __        __ _ __ _    ___                  
  /__\ ___  / _| / _\ |_ / _ \ _ __ ___  _ __  
 / \/// _ \| |_| \ \| __| | | | '_ ` _ \| '_ \ 
/ _  \ (_) |  _| |\ \ |_| |_| | | | | | | |_) |
\/ \_/\___/|_| |_\__/\__|\___/|_| |_| |_| .__/ 
                                        |_|    
					\ \/ (_)_ __                                   
					 \  /| | '_ \                                  
					 /  \| | | | |                                 
					/_/\_\_|_| |_ [ ]

-- Usage - Shift In-Game Menu to configure Hotkeys / Bind PRIORITY to something as a hotkey. 
Set up your priorities whilst walking to lane- 
Note: It will never use R, mainly because it's so situational.

// Combo 1: E > AACancel > WQQQ with Items / Ignite
// Combo 2: AA Cancel > WQQQ
// Shield : Casts Locket of the Iron Solari (Best 0/21 Xin MUSTHAVE item) if you're about to die from a TARGETED spell.
// TARGETING IS BASED ON NEARMOUSE UNTIL I CBA TO USE GETMARKEDTARGET
-- 
]]

require "Utils"
require "spell_damage"
p = printtext
if myHero.name == "XinZhao" then p("RoflStomp Xin by EZG Loaded") end


	XinConfig = scriptConfig("roflXin", "config")
	XinConfig:addParam("combo", "EWQQQ", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
	XinConfig:addParam("harass", "WQQQ", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	XinConfig:addParam("shield", "AutoLocket", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("J"))



local lastAttack = GetTickCount()
local projSpeed = 1
local startAttackSpeed = 0.672
local target
local target2
local Swing = 1
local shotFired = false
local range = myHero.range + GetDistance(GetMinBBox(myHero))
local attackDelayOffset = 275
local isMoving = false


function OnLoad()
    if GetAAData()[myHero.name] ~= nil then
        if GetAAData()[myHero.name].projSpeed ~= nil then
            projSpeed = GetAAData()[myHero.name].projSpeed
        end
    end
    if GetAAData()[myHero.name] ~= nil then
        if GetAAData()[myHero.name].startAttackSpeed ~= nil then
            startAttackSpeed = GetAAData()[myHero.name].startAttackSpeed
        end
    end
end



function OnTick()
Target()

	if target ~= nil then
		if XinConfig.combo then Combo() end
		if XinConfig.harass then Harass() end
	end
		if XinConfig.combo or XinConfig.harass then
		moveToCursor()
	end
	
end


function Target()
if GetMarkedTarget() ~= nil then
target = GetMarkedTarget()
else
target = GetWeakEnemy("PHYS", 650) 
end

end

function Combo()
	if target ~= nil then
		UseTargetItems(target)
		CastSummonerIgnite(target)
		if CanCastSpell("E") then CastSpellTarget("E",target) end
		if CanCastSpell("W") and GetDistance(target) < range then CastSpellTarget("W",myHero) end
		if Swing == 1 and CanCastSpell("Q") and GetDistance(target) < range then CastSpellTarget("Q",myHero) end
		Action()
	end
end

function Harass()
	if target ~= nil then
	if CanCastSpell("W") and GetDistance(target) < range then CastSpellTarget("W",myHero) end
	if Swing == 1 and CanCastSpell("Q") and GetDistance(target) < range then CastSpellTarget("Q",myHero) end
	Action() 
	end
end


function Action()
        if timeToShoot() then
            attackEnemy(target)
			swing = 0
			if target.dead ~= 1 then CustomCircle(100,10,1,target) end
        else
			if target.dead ~= 1 then CustomCircle(100,5,2,target) end
			swing = 1
            if heroCanMove() and GetDistance(target) < range/2 then moveToCursor() end
        end
end

function attackEnemy(target)
	if ValidTarget(target) then
	AttackTarget(target)
	shotFired = True
	end
end

function GetNextAttackTime()
return lastAttack + attackDelayOffset / GetAttackSpeed()
end

function GetAttackSpeed()
return myHero.attackspeed/(1/startAttackSpeed)
end

function timeToShoot()
    if GetTickCount() > GetNextAttackTime() then
    return true
    end
    return false
end

function heroCanMove()
    if shotFired == false or timeToShoot() then
        return true
    end
    return false
end

function moveToCursor() 
    isMoving = true
    local moveSqr = math.sqrt((mousePos.x - myHero.x)^2+(mousePos.z - myHero.z)^2)
    local moveX = myHero.x + 300*((mousePos.x - myHero.x)/moveSqr)
    local moveZ = myHero.z + 300*((mousePos.z - myHero.z)/moveSqr)
    MoveToXYZ(moveX,0,moveZ)
end

function OnCreateObj(object)
	if GetAAData()[myHero.name] ~= nil then
		for _, v in pairs(GetAAData()[myHero.name].aaParticles) do
			if string.find(object.charName,v)
				then
				shotFired = false
				lastAttack = GetTickCount()
			end
		end
	end
end

function OnProcessSpell(obj,spell)
	if GetAAData()[myHero.name] ~= nil then
		for _, v in pairs(GetAAData()[myHero.name].aaSpellName) do
			if string.find(spell.name,v)
				then
				shotFired = false
				lastAttack = GetTickCount()
			end
		end
	end
	
	if spell.target ~= nil and spell.target.name == myHero.name then
	if CheckSpellSlot(obj.name,spell.name) ~= nil then
	local spellslot = CheckSpellSlot(obj.name,spell.name)
		if getDmg(spellslot,myHero,obj) >= myHero.health then
		if XinConfig.shield then UseLocket() end
		end	
	end
	end
end



function CheckSpellSlot(caster, spell)
local slot
if caster.SpellNameQ == spell then slot = "Q" 
elseif caster.SpellNameW == spell then slot = "W" 
elseif caster.SpellNameE == spell then slot = "E"
elseif caster.SpellNameR == spell then slot = "R"
elseif string.find(spell,"ttack") then slot = "AD"
end
return (slot)
end

function GetAAData()
    return {
        XinZhao = { aaParticles = {"xenZiou_ChainAttack_01", "xenZiou_ChainAttack_02", "xenZiou_ChainAttack_03"}, aaSpellName = {"XinZhaoBasicAttack", "XinZhaoBasicAttack2", "XenZhaoThrust" }, startAttackSpeed = 0.675,  }
	}
end

function OnDraw()

	if myHero.dead ~= 1 then	CustomCircle(650,4,3,myHero) end
		if target ~= nil and GetDistance(myHero, target) < 650 and target.dead ~= 1 then
			CustomCircle(100,4,1,target)
		end
		for i = 1, objManager:GetMaxHeroes()  do
			local enemy = objManager:GetHero(i)
			if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) then
				local qdmg = getDmg("Q",enemy,myHero)*CanUseSpell("Q") 
				local wdmg = getDmg("W",enemy,myHero)*CanUseSpell("W")
				local edmg = getDmg("E",enemy,myHero)*CanUseSpell("E")
				local rdmg = getDmg("R",enemy,myHero)*CanUseSpell("R")
				local aaDmg = getDmg("AD",enemy,myHero)

			if enemy.health < (qdmg+wdmg+edmg+(aaDmg*3)) then 
			CustomCircle(200,4,3,enemy)	
				end
			end
		end
	end

	
local items = {
        LCK = {id=3190, range = 10000, reqTarget = false, slot = nil},    -- Locket of the Iron Solari
        }
		
function UseLocket()
    for _,item in pairs(items) do
        item.slot = GetInventorySlot(item.id)
        if item.slot ~= nil then
            if not item.reqTarget then
                    CastSpellTarget(item.slot,myHero)
            end
        end
    end
end
		
OnLoad()
SetTimerCallback("OnTick")