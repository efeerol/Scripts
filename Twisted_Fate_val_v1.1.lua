require "Utils"

local version = '1.1'
local target
local target2
local GoldCardLock = false
local RedCardLock = false
local BlueCardLock = false
local timer = 0

function TFRun()
	target = GetWeakEnemy('MAGIC',1400,"NEARMOUSE")
	target2 = GetWeakEnemy('TRUE',600)
	AArange = (myHero.range+(GetDistance(GetMinBBox(myHero), GetMaxBBox(myHero))/2))
	targetaa = GetWeakEnemy('MAGIC',AArange)
	
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
	
	if myHero.mana > ((myHero.maxMana*4)/10) then
		manacheck = true
	else
		manacheck = false
	end

	if TFConfig.Combo then Combo() end
	if TFConfig.BlueCard then CastHotkey("AUTO 100,0 SPELLW:SELFTARGET PICKACARD=BLUE") end
	if TFConfig.RedCard then CastHotkey("AUTO 100,0 SPELLW:SELFTARGET PICKACARD=RED") end
	if TFConfig.GoldCard then CastHotkey("AUTO 100,0 SPELLW:SELFTARGET PICKACARD=YELLOW") end
	if TFConfig.ignite then ignite() end
end

	TFConfig = scriptConfig("TF Config", "tf2conf")
	TFConfig:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Y"))
	TFConfig:addParam("BlueCard", "BlueCard", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
	TFConfig:addParam("RedCard", "RedCard", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	TFConfig:addParam("GoldCard", "GoldCard", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	TFConfig:addParam("AutoQ", "Auto Q", SCRIPT_PARAM_ONKEYTOGGLE, true, 112)
	TFConfig:addParam("Qmanacheck", "Q only when Mana>40%", SCRIPT_PARAM_ONKEYTOGGLE, true, 113)
	TFConfig:addParam("OnlyQgold", "Q only by Goldcard", SCRIPT_PARAM_ONKEYTOGGLE, true, 114)
	TFConfig:addParam("ignite", "Auto-Ignite", SCRIPT_PARAM_ONKEYTOGGLE, true, 115)
	TFConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
	TFConfig:permaShow("BlueCard")
	TFConfig:permaShow("RedCard")
	TFConfig:permaShow("GoldCard")
	TFConfig:permaShow("AutoQ")
	TFConfig:permaShow("Qmanacheck")
	TFConfig:permaShow("OnlyQgold")
	TFConfig:permaShow("ignite")

function OnCreateObj(obj)
	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) and obj ~= nil then
			if string.find(obj.charName, "Stun") ~= nil and GetDistance(enemy, obj) < 50 and GetDistance(myHero, obj) < 1400 and TFConfig.AutoQ and QRDY == true and TFConfig.OnlyQgold == false then
				if TFConfig.Qmanacheck and manacheck == true then
					CastSpellXYZ('Q',obj.x,0,obj.z)
				else 
					CastSpellXYZ('Q',obj.x,0,obj.z)
				end
			end
			if string.find(obj.charName, "PickaCard_yellow_tar") ~= nil and GetDistance(enemy, obj) < 100 and GetDistance(myHero, obj) < 1400 and TFConfig.AutoQ and QRDY == true and TFConfig.OnlyQgold == true then
				if TFConfig.Qmanacheck and manacheck == true then
					CastSpellXYZ('Q',obj.x,0,obj.z)
				else 
					CastSpellXYZ('Q',obj.x,0,obj.z)
				end
			end
		end
	end
end

function Combo()
	if targetaa ~= nil then
		UseAllItems(targetaa)
		CastHotkey("AUTO 100,0 SPELLW:SELFTARGET PICKACARD=YELLOW")
		if QRDY == true then 
			if TFConfig.Qmanacheck and manacheck == true then
				CastSpellXYZ('Q',targetaa.x,0,targetaa.z)
			else 
				CastSpellXYZ('Q',targetaa.x,0,targetaa.z)
			end
		end
		AttackTarget(targetaa)
	end
	if targetaa == nil then MoveToMouse() end
end	

function ignite()
	local damage = (myHero.selflevel*20)+50
	if target2 ~= nil then
		if myHero.SummonerD == "SummonerDot" then
			if target2.health < damage then
				CastSpellTarget("D",target2)
			end
		end
		if myHero.SummonerF == "SummonerDot" then
			if target2.health < damage then
				CastSpellTarget("F",target2)
			end
		end
	end
end

function OnDraw()
	if TFConfig.drawcircles then
		if myHero.dead == 0 then
			if QRDY == true then
				CustomCircle(1450,3,3,myHero)
			end
			if RRDY == true then
				CustomCircle(5400,10,1,myHero)
			end
			if target ~= nil then
				CustomCircle(100,4,2,target)
			end
		end
	end
end

SetTimerCallback("TFRun")
print("\nVal's Twisted Fate v"..version.."\n")