require 'Utils'
require 'spell_damage'

local version = '2.3.1'
local target
local targetlong
local targetignite
local timer = 0
local t0_attacking = 0
local MousePos = nil
local EnemyPos = nil
local HeroPos = nil
local GatePos = nil
local attack0 = false
local attack1 = false
local attack2 = false
local attack3 = false
local RangeAttack = false
local Killsteal = false
local attackAnimationDuration = 100
local EQmanacost = ((GetSpellLevel("Q")*5)+100)
local GateTimer = 0

function Jayce2Run()
	target = GetWeakEnemy('PHYS',700)
	targetlong = GetWeakEnemy('PHYS',1600,"NEARMOUSE")
	targetignite = GetWeakEnemy('TRUE',600)
	
	JayceDraw()
	
	if myHero.SpellTimeQ > 1.0 then
	QRDY = true
	else QRDY = false
	end

	if myHero.SpellTimeW > 1.0 then
	WRDY = true
	else WRDY = false
	end

	if myHero.SpellTimeE > 1.0 then
	ERDY = true
	else ERDY = false
	end

	if myHero.SpellTimeR > 1.0 then
	RRDY = true
	else RRDY = false
	end
	
	if myHero.SpellNameR == "jaycestancegth" then 
	RangeStance = true
	HammerStance = false 
	end 
	if myHero.SpellNameR == "JayceStanceHtG" then 
	RangeStance = false
	HammerStance = true
	end
	
	if GetTickCount() - timer > 1500 then timer = 0 end
	if GetTickCount() - GateTimer  > 1000 then 
		GatePos = nil
		GateTimer = 0
	end
	if JayceConfig.QEman or JayceConfig.Poke or JayceConfig.Combo or Killsteal == true then if GatePos ~= nil then CastSpellXYZ("E", GatePos.x, 0, GatePos.z) end end
	if HammerStance == true and QRDY == false and WRDY == false and ERDY == false and RRDY == true and JayceConfig.Combo and JayceConfig.autoswitch then CastSpellXYZ("R", myHero.x, myHero.y, myHero.z) end
	
	if JayceConfig.Combo then Combo() end
	if JayceConfig.QEman and IsChatOpen() == 0 then QEman() end
	if JayceConfig.Poke then Poke() end
	if JayceConfig.ignite then ignite() end
	if JayceConfig.smite then smitesteal() end
	if JayceConfig.EQKillsteal then EQKillsteal() end
end

	JayceConfig = scriptConfig("Jayce Config", "jayce2conf")
	JayceConfig:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 88)
	JayceConfig:addParam("Poke", "Poke", SCRIPT_PARAM_ONKEYDOWN, false, 89)
	JayceConfig:addParam("QEman", "Manual QE", SCRIPT_PARAM_ONKEYDOWN, false, 90)
	JayceConfig:addParam("smite", "Smitesteal", SCRIPT_PARAM_ONKEYTOGGLE, false, 112)
	JayceConfig:addParam("GateDistance", "GateDistance", SCRIPT_PARAM_NUMERICUPDOWN, 100, 113, 20, 200, 20)
	JayceConfig:addParam("ignite", "Auto-Ignite", SCRIPT_PARAM_ONOFF, true)
	JayceConfig:addParam("useItems", "Auto-Items", SCRIPT_PARAM_ONOFF, true)
	JayceConfig:addParam("autoswitch", "Auto switch to Range", SCRIPT_PARAM_ONOFF, true)
	JayceConfig:addParam("AAW", "Auto AA-W", SCRIPT_PARAM_ONOFF, true)
	JayceConfig:addParam("EQKillsteal", "E-Q Killsteal", SCRIPT_PARAM_ONOFF, true)
	JayceConfig:addParam("KSnotifications", "Show KS notifications", SCRIPT_PARAM_ONOFF, true)
	JayceConfig:permaShow("Combo")
	JayceConfig:permaShow("Poke")
	JayceConfig:permaShow("QEman")
	JayceConfig:permaShow("ignite")
	JayceConfig:permaShow("smite")
	JayceConfig:permaShow("GateDistance")
	JayceConfig:permaShow("useItems")
	JayceConfig:permaShow("AAW")
	JayceConfig:permaShow("EQKillsteal")

function OnProcessSpell(unit,spell)
	if unit ~= nil and spell ~= nil and unit.charName == myHero.charName then
		if spell.name == "jayceaccelerationgate" then
			GatePos = nil
		end
		if JayceConfig.Combo then
			if spell.name == "JayceToTheSkies" and target ~= nil and spell.target then
				attack0 = true
				attack1 = false
				attack2 = false
				attack3 = false
				timer = GetTickCount()
			end
			if attack0 == true then
				if (spell.name == "JayceBasicAttack" or spell.name == "JayceBasicAttack2" or spell.name == "JayceBasicAttack3" or spell.name == "JayceCritAttack") and target ~= nil and spell.target then
					attack0 = false
					attack1 = true
					attack2 = false
					attack3 = false
					timer = GetTickCount()
				end
			elseif attack1 == true then
				if (spell.name == "JayceBasicAttack" or spell.name == "JayceBasicAttack2" or spell.name == "JayceBasicAttack3" or spell.name == "JayceCritAttack") and target ~= nil and spell.target then
					attack0 = false
					attack1 = false
					attack2 = true
					attack3 = false
					timer = GetTickCount()
				end
			elseif attack2 == true then
				if (spell.name == "JayceBasicAttack" or spell.name == "JayceBasicAttack2" or spell.name == "JayceBasicAttack3" or spell.name == "JayceCritAttack") and target ~= nil and spell.target then
					attack0 = false
					attack1 = false
					attack2 = false
					attack3 = true
					t0_attacking = GetClock()+attackAnimationDuration
					timer = GetTickCount()
				end
			elseif myHero.dead == 1 or spell.name == "JayceThunderingBlow" and target ~= nil and spell.target then
					attack0 = false
					attack1 = false
					attack2 = false
					attack3 = false
			end
		end	
		if (spell.name == "jaycepassiverangedattack" or spell.name == "JayceRangedAttack" or spell.name == "JayceRangedAttack2" or spell.name == "JayceRangedAttack3" or spell.name == "JayceRangedCritAttack") and target ~= nil and spell.target and JayceConfig.AAW and JayceConfig.Combo == false then
			RangeAttack = true
		end
	end
end

function OnCreateObj(obj)
	if obj ~= nil and JayceConfig.AAW then
		if string.find(obj.charName, "Jayce_Range_Basic_Mis") ~= nil and GetDistance(myHero, obj) < 200 and RangeAttack == true then
			CastSpellXYZ('W',myHero.x,myHero.y,myHero.z)
			RangeAttack = false
		end
	end
end

function QEman()
	if HammerStance == true then
		CastSpellXYZ("R", myHero.x, myHero.y, myHero.z)
	elseif RangeStance == true then
		if QRDY == true and ERDY == true and myHero.mana >= EQmanacost then
			MousePos = Vector(GetCursorWorldX(), GetCursorWorldY(), GetCursorWorldZ())
			HeroPos = Vector(myHero.x, myHero.y, myHero.z)
			GatePos = HeroPos + ( HeroPos - MousePos )*(-JayceConfig.GateDistance/GetDistance(HeroPos, MousePos))
			GateTimer = GetTickCount()
			CastSpellXYZ("Q", GetCursorWorldX(), GetCursorWorldY(), GetCursorWorldZ())
		end
	end
end

function Poke()
	if targetlong ~= nil then
		if HammerStance == true then
			CastSpellXYZ("R", myHero.x, myHero.y, myHero.z)
		elseif RangeStance == true then
			if QRDY == true and ERDY == true and myHero.mana >= EQmanacost and CreepBlock(GetFireahead(targetlong,1.6,22)) == 0 then
				EnemyPos = Vector(targetlong.x,targetlong.y,targetlong.z)
				HeroPos = Vector(myHero.x, myHero.y, myHero.z)
				GatePos = HeroPos + ( HeroPos - EnemyPos )*(-JayceConfig.GateDistance/GetDistance(myHero, targetlong))
				GateTimer = GetTickCount()
				CastSpellXYZ("Q", GetFireahead(targetlong,1.6,22))	
			end
		end
	end
end

function Combo()
	if target ~= nil then
		if JayceConfig.useItems then
			UseAllItems(target)
		end	
		if RangeStance == true then
			if QRDY == true and ERDY == true and myHero.mana >= EQmanacost and CreepBlock(GetFireahead(target,1.6,22)) == 0 then
				EnemyPos = Vector(target.x,target.y,target.z)
				HeroPos = Vector(myHero.x, myHero.y, myHero.z)
				GatePos = HeroPos + ( HeroPos - EnemyPos )*(-JayceConfig.GateDistance/GetDistance(myHero, target))
				GateTimer = GetTickCount()
				CastSpellXYZ("Q", GetFireahead(target,1.6,22))
			elseif QRDY == true and ERDY == false and CreepBlock(GetFireahead(target,1.6,13)) == 0 then
				CastSpellXYZ("Q", GetFireahead(target,1.6,(1450/100)))
			end		
			if (QRDY == false and ERDY == false) or (QRDY == false and ERDY == true) then
				CastSpellXYZ("W", myHero.x, myHero.y, myHero.z)
				CastSpellXYZ("R", myHero.x, myHero.y, myHero.z)
			end
			if (QRDY == false and WRDY == false and ERDY == false and RRDY == false) or (QRDY == false and WRDY == false and ERDY == true and RRDY == false) then
				AttackTarget(target)
			end
		end
		if HammerStance == true then
			AttackTarget(target) 
			if QRDY == true then
				AttackTarget(target)
				CastSpellXYZ("W", myHero.x, myHero.y, myHero.z)
				CastSpellTarget("Q", target)
			end
			if GetDistance(myHero, target) < myHero.range+150 then 
				AttackTarget(target) 
			end
			if attack3 == false then				
				if GetDistance(myHero, target) < myHero.range+150 then
					AttackTarget(target) 
				end	
			elseif attack3 == true and GetClock() > t0_attacking then				
				if ERDY == true then
					CastSpellTarget("E", target)
				end
			end
			if GetTickCount() - timer > 1000 then
				if ERDY == true then
					CastSpellTarget("E", target)
				end
			end
		end
	end
	if target == nil then
		MoveToMouse()
	end
end

function EQKillsteal()
	if targetlong ~= nil then
		local Qdam = getDmg("Q",targetlong,myHero,3)
		if RangeStance == true and myHero.mana >= EQmanacost and CreepBlock(GetFireahead(targetlong,1.6,22)) == 0  and targetlong.health<Qdam and QRDY == true and ERDY == true then
			Killsteal = true
			EnemyPos = Vector(targetlong.x,targetlong.y,targetlong.z)
			HeroPos = Vector(myHero.x, myHero.y, myHero.z)
			GatePos = HeroPos + ( HeroPos - EnemyPos )*(-JayceConfig.GateDistance/GetDistance(myHero, targetlong))	
			GateTimer = GetTickCount()
			CastSpellXYZ("Q", GetFireahead(targetlong,1.6,22))
		else Killsteal = false
		end
	end
end

function smitesteal()
	if myHero.SummonerD == "SummonerSmite" then
		CastHotkey("AUTO 100,0 SPELLD:SMITESTEAL RANGE=600 TRUE COOLDOWN")
		return
	end
	if myHero.SummonerF == "SummonerSmite" then
		CastHotkey("AUTO 100,0 SPELLF:SMITESTEAL RANGE=600 TRUE COOLDOWN")
		return
	end
end

function ignite()
	local damage = (myHero.selflevel*20)+50
	if targetignite ~= nil then
		if myHero.SummonerD == "SummonerDot" then
			if targetignite.health < damage then
				CastSpellTarget("D",targetignite)
			end
		end
		if myHero.SummonerF == "SummonerDot" then
			if targetignite.health < damage then
				CastSpellTarget("F",targetignite)
			end
		end
	end
end

function JayceDraw()
	if RangeStance == true then
		if QRDY == true and ERDY == true then
			CustomCircle(1600,6,2,myHero)
		end
		if targetlong ~= nil then
			CustomCircle(100,4,2,targetlong)
		end
	end	
	CustomCircle(600,6,1,myHero)
	if JayceConfig.KSnotifications then
		for i = 1, objManager:GetMaxHeroes() do
			local enemy = objManager:GetHero(i)
			if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) then
				local Qdam = getDmg("Q",enemy,myHero)
				local Bdam = getDmg("QM",enemy,myHero)+getDmg("WM",enemy,myHero)+getDmg("EM",enemy,myHero)+getDmg("R",enemy,myHero)+getDmg("Q",enemy,myHero,3)+getDmg("W",enemy,myHero)+(getDmg("AD",enemy,myHero)*3)
				if enemy.health<Qdam then
					DrawTextObject("POKE KILL", enemy, Color.Red)
				elseif enemy.health<Bdam then
					DrawTextObject("FULL BURST", enemy, Color.Red)
				end
			end
		end
	end
end

SetTimerCallback("Jayce2Run")
print("\nVal's Jayce revision v"..version.."\n")
