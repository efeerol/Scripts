----------[[WoWoW Vanye v1.1 by Dym71]]
require "Utils"
require "spell_damage"
require 'winapi'
require 'keys'
require 'SKeys'
local send = require 'SendInputScheduled'

----------[[Variables]]
local targetSafeZone = nil
local target3
local range = myHero.range + GetDistance(GetMinBBox(myHero))
local timerw = nil
local target
local targetHero
local tlow
local thigh
local projSpeed = 1
local lastAttack = GetTickCount()
local shotFired = false
local attackDelayOffset = 275
local isMoving = false
local startAttackSpeed = 0.625
local lA = GetGameTime()
local lQ = GetGameTime()
local oneshot = false
local oneread = false
local lastGetMinion = GetTickCount()
local v_JumpToStunned, v_RepulsiveEnemies, v_KillstealE, v_Autostun, v_StealthMode = false, false, false, false, false
----------[[/Variables]]

----------[[Config Menu]]
local uiconfig = require 'uiconfig'
VayneConfig, menu = uiconfig.add_menu('WoWoW Vayne', 200)
menu.keydown('AutoCarry', 'Auto Carry', Keys.Z)
menu.keydown('AutoCarryEnhanced', 'Auto Carry +', Keys.X)
menu.keydown('Farm', 'Last Hit + AC', Keys.C)
menu.keydown('Escape', 'Escape', Keys.A)
menu.keydown('LaneClear', 'Lane Clear', Keys.S)
menu.keydown('SpecialHarras', 'Q AA E Harras', Keys.D)
menu.keytoggle('JumpToStunned', 'Q To Stunned', Keys.J, true)
menu.keytoggle('RepulsiveEnemies', 'Repulsive Enemy', Keys.H, true)
menu.keytoggle('KillstealE', 'Killsteal E', Keys.K, true)
menu.keytoggle('Autostun', 'Autostun E', Keys.O, true)
menu.keytoggle('StealthMode', 'Stealth Mode', Keys.I, false)
----------[[/Config Menu]]


----------[[Functions]]
function Vayne()
	send.tick()
	if IsChatOpen() == 0 then
		if oneread then
			if v_JumpToStunned ~= VayneConfig.JumpToStunned then
				send.key_press(SKeys.J)
			end
			if v_RepulsiveEnemies ~= VayneConfig.RepulsiveEnemies then
				send.key_press(SKeys.H)
			end
			if v_KillstealE ~= VayneConfig.KillstealE then
				send.key_press(SKeys.K)
			end
			if v_Autostun ~= VayneConfig.Autostun then
				send.key_press(SKeys.O)
			end
			if v_StealthMode ~= VayneConfig.StealthMode then
				send.key_press(SKeys.I)
			end
		end
		oneread = false
		UpdateRange()
		targetReset()
		target = GetWeakEnemy('PHYS', (610+(20*GetSpellLevel("W"))))
		targetSafeZone = GetWeakEnemy('PHYS', 300)
		if target and target.dead == 1 then target = nil end
		if VayneConfig.RepulsiveEnemies and targetSafeZone ~= nil and IsChatOpen() == 0 then
			RepulsiveEnemies()
		end
		if VayneConfig.KillstealE then
			killE()
		end
		if VayneConfig.Autostun then
			Autostun()
		end
		if VayneConfig.Escape and IsChatOpen() == 0 then
			Escape()
			Draw()
		end
		if VayneConfig.LaneClear and IsChatOpen() == 0 then
			LaneClear()
			Draw()
		end
		if VayneConfig.SpecialHarras and IsChatOpen() == 0 then
			SpecialHarras()
			Draw()
		end
		if VayneConfig.AutoCarry and IsChatOpen() == 0 then
			AutoCarry()
		end
		if VayneConfig.AutoCarryEnhanced and IsChatOpen() == 0 then
			AutoCarryEnhanced()
		end
		if VayneConfig.Farm and IsChatOpen() == 0 then
			Hybrid()
		end
		if VayneConfig.AutoCarry or VayneConfig.Farm or VayneConfig.LaneClear then
			moveToCursor()
			Draw()
		end
		if VayneConfig.AutoCarryEnhanced then
			moveToCursorEnhanced()
			Draw()
		end
	else
		if oneread == false then
			ReadSettings()
			oneread = true
		end
	end
end

function Draw()
	if not VayneConfig.StealthMode then
		if VayneConfig.AutoCarry then
			DrawText("Auto Carry", 10, 10, Color.Yellow)
		end
		if VayneConfig.AutoCarryEnhanced then
			DrawText("Auto Carry +", 10, 10, Color.Yellow)
		end
		if VayneConfig.Farm then
			DrawText("Last Hit Auto Carry", 10, 10, Color.Yellow)
		end
		if VayneConfig.Escape then
			DrawText("Escape", 10, 10, Color.Yellow)
		end
		if VayneConfig.LaneClear then
			DrawText("Farm", 10, 10, Color.Yellow)
		end
		if VayneConfig.SpecialHarras then
			DrawText("Special Harras", 10, 10, Color.Yellow)
		end
	end
end

function ReadSettings()
	if VayneConfig.RepulsiveEnemies then
		v_RepulsiveEnemies = true
	else
		v_RepulsiveEnemies = false
	end
	if VayneConfig.KillstealE then
		v_KillstealE = true
	else
		v_KillstealE = false
	end
	if VayneConfig.Autostun then
		v_Autostun = true
	else
		v_Autostun = false
	end
	if VayneConfig.StealthMode then
		v_StealthMode = true
	else
		v_StealthMode = false
	end
	if VayneConfig.JumpToStunned then
		v_JumpToStunned = true
	else
		v_JumpToStunned = false
	end
end

function UpdateRange()
	if timerw ~= nil then
		if os.time() < timerw + 8 then
			range = myHero.range + GetDistance(GetMinBBox(myHero)) + (110+(20*GetSpellLevel("W")))
			else
			range = myHero.range + GetDistance(GetMinBBox(myHero))
		end
	end
end

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

function trueRange()
local trueRangeValue
        if target ~= nil and GetDistance(target) < range then
                trueRangeValue = range -(range-GetDistance(target))
        else
                trueRangeValue = range
        end
        return trueRangeValue
end

function targetReset()
        if not target and not targetHero then
        target = nil
        targetHero = nil
        end
end

function Action()
        if timeToShoot() then
            attackEnemy(target)
			if not VayneConfig.StealthMode then
				CustomCircle(100,10,1,target)
			end
        else
			if not VayneConfig.StealthMode then
				CustomCircle(100,5,2,target)
			end
            if heroCanMove() then moveToCursor() end
        end
end

function ActionEnhanced()
        if timeToShoot() then
			attackEnemy(target)
			if not VayneConfig.StealthMode then
				CustomCircle(100,10,1,target)
			end
        else
			if not VayneConfig.StealthMode then
				CustomCircle(100,5,2,target)
			end
            if heroCanMove() then moveToCursorEnhanced() end
        end
end

function attackEnemy(target)
        if ValidTarget(target) then
        AttackTarget(target)
        shotFired = True
		lA = GetGameTime()
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

function moveToCursorEnhanced()
    castR()
	castE()
	castQ()
	isMoving = true
    local moveSqr = math.sqrt((mousePos.x - myHero.x)^2+(mousePos.z - myHero.z)^2)
    local moveX = myHero.x + 300*((mousePos.x - myHero.x)/moveSqr)
    local moveZ = myHero.z + 300*((mousePos.z - myHero.z)/moveSqr)
    MoveToXYZ(moveX,0,moveZ)
end

function Escape()
    castQ()
	local targetEscape = GetWeakEnemy("PHYS",550)
	if targetEscape ~= nil and IsChatOpen() == 0 then
		if CanCastSpell("E") then
			CastSpellTarget('E', targetEscape)
			targetEscape = nil
		end
	end
	local targetEscape = GetWeakEnemy("PHYS",700)
	targetQ = GetHighestHealthEnemyMinion(range)
	if oneshot == false and targetEscape == nil and targetQ ~= nil and timeToShoot() and isQbuff() then
		target = targetQ
		Action()
		oneshot = true
	else
		isMoving = true
		local moveSqr = math.sqrt((mousePos.x - myHero.x)^2+(mousePos.z - myHero.z)^2)
		local moveX = myHero.x + 300*((mousePos.x - myHero.x)/moveSqr)
		local moveZ = myHero.z + 300*((mousePos.z - myHero.z)/moveSqr)
		MoveToXYZ(moveX,0,moveZ)
	end
end

function isQbuff()
	if lA < lQ and (GetGameTime()-lQ)<6 then
		return true
	else
		return false
	end
end

function castQ()
	if CanCastSpell("Q") then
		CastSpellXYZ("Q",mousePos.x, 0, mousePos.z)
		lQ = GetGameTime()
		oneshot = false
	end
end

function castR()
    if CanCastSpell("R") then
		CastSpellTarget('R', GetSelf())
	end
end

function Autostun()
    if target ~= nil then
		if WillHitWall(target,440) == 1 and (GetDistance(myHero, target) <= 550) then
			CastSpellTarget("E", target)
			if VayneConfig.JumpToStunned then
				if CanCastSpell("Q") then
					CastSpellXYZ("Q",target.x, 0, target.z)
				end
			end
		end
	end
end

function castE()
    if target ~= nil then
		if WillHitWall(target,440) == 1 and (GetDistance(myHero, target) <= 550) then
			CastSpellTarget("E", target)
			if VayneConfig.JumpToStunned then
				if CanCastSpell("Q") then
					CastSpellXYZ("Q",target.x, 0, target.z)
				end
			end
		end
		if not VayneConfig.KillstealE then
			killE()
		end
	end
end

function killE()
	local targetKillsteal = GetWeakEnemy("PHYS",550)
    if targetKillsteal ~= nil and IsChatOpen() == 0 then
		local dmg = GetSelf().addDamage/2
		if GetSelf().SpellLevelE == 0 then
			dmg = 0
		elseif GetSelf().SpellLevelE == 1 then
			dmg = dmg + 45
		elseif GetSelf().SpellLevelE == 2 then
			dmg = dmg + 80
		elseif GetSelf().SpellLevelE == 3 then
			dmg = dmg + 115
		elseif GetSelf().SpellLevelE == 4 then
			dmg = dmg + 150
		elseif GetSelf().SpellLevelE == 5 then
			dmg = dmg + 185
		end
		if CalcDamage(targetKillsteal,dmg) >= targetKillsteal.health then
			if CanCastSpell("E") then
				CastSpellTarget('E', targetKillsteal)
				targetKillsteal = nil
			end
		end
	end
end

function RepulsiveEnemies()
    if CanCastSpell("E") then
		CastSpellTarget('E', targetSafeZone)
	end
	targetSafeZone = nil
end

function OnCreateObj(object)
    if GetAAData()[myHero.name] ~= nil then
        for _, v in pairs(GetAAData()[myHero.name].aaParticles) do
            if string.find(object.charName,v) then
                shotFired = false
                lastAttack = GetTickCount()
            end
        end
    end
end

function OnProcessSpell(obj,spell)
    if obj ~= nil and obj.name == myHero.name then
        if string.find(spell.name,"attack") then
            lastAttack = GetTickCount()
        end
    end
end

function GetAAData()
    return {
        Vayne        = { projSpeed = 2.0, aaParticles = {"vayne_basicAttack_mis", "vayne_critAttack_mis", "vayne_ult_mis" }, aaSpellName = "vaynebasicattack", startAttackSpeed = "0.658",  },
    }
end

function AutoCarry()
	if not VayneConfig.StealthMode then
	    CustomCircle(range,2,4,myHero)
	end
    target = GetWeakEnemy("PHYS",range)

    if target ~= nil then
        Action()
    else
        moveToCursor()
    end
end

function AutoCarryEnhanced()
    if not VayneConfig.StealthMode then
	    CustomCircle(range,2,4,myHero)
	end
    target = GetWeakEnemy("PHYS",range)

    if target ~= nil then
        UseAllItems(target)
        ActionEnhanced()
    else
        moveToCursorEnhanced()
    end
end

function Hybrid()
    if not VayneConfig.StealthMode then
	    CustomCircle(range,2,4,myHero)
	end
    targetHero = GetWeakEnemy("PHYS",range)
	tlow = GetLowestHealthEnemyMinion(range)

	if tlow ~= nil and tlow.health <= getDmg('AD',tlow,myHero) then
		target = tlow
		Action()
	elseif targetHero ~= nil then
        target = targetHero
		Action()
    else
        target = GetLowestHealthEnemyMinion(range)
    end

    if target ~= nil then
        if ( getDmg("AD",target,myHero) ) >= target.health then
            Action()
        end
    else
        moveToCursor()
    end
end

function SpecialHarras()
	if not VayneConfig.StealthMode then
	    CustomCircle(830,2,4,myHero)
	end
    target = GetWeakEnemy("PHYS",830)

    if target ~= nil and CanCastSpell("Q") and CanCastSpell("E") and myHero.mana >= 120 and timeToShoot() then
        CastSpellXYZ("Q",target.x, 0, target.z)
		if target ~= nil then
			attackEnemy(target)
			if not VayneConfig.StealthMode then
				CustomCircle(100,10,1,target)
			end
		end
    end
	if target ~= nil and not CanCastSpell("Q") and not timeToShoot() and CanCastSpell("E") then
		CastSpellTarget('E', target)
	end
end

function LaneClear()
    if not VayneConfig.StealthMode then
	    CustomCircle(range,2,4,myHero)
	end
    if (GetTickCount()-lastGetMinion) > 250 then
		tlow=GetLowestHealthEnemyMinion(range)
		lastGetMinion = GetTickCount()
	end
    if tlow~= nil then
        target = tlow
    end

    if target ~= nil then
        Action()
    else
		moveToCursor()
    end
end
----------[[/Functions]]

OnLoad()

SetTimerCallback("Vayne")