-- ################################################################################?###################### --
-- #                                                                                                     # --
-- #                                    Sida's Katarina (Val's revision)                        		 # --
-- #                                                                                                     # --
-- ################################################################################?###################### --

require "Utils"
require 'spell_damage'
require 'winapi'
require 'SKeys'
local send = require 'SendInputScheduled'

local version = '2.1.1'

local target
local target2
local lastRDagger = 0
local lastHotkey = 3
local spinning = false
local ultblock = false

local Wards = {2044, 2049, 2045, 2043, 3154}
local lastWard = 0

local X = 10
local Y = 120
local basicthickness = 10
local radius = 60

local cc = 0
local skillshotArray = {}
local colorcyan = 0x0000FFFF
local coloryellow = 0xFFFFFF00
local colorgreen = 0xFF00FF00
local skillshotcharexist = false
local show_allies = 0

local Q,W,E,R = 'Q','W','E','R'
local metakey = SKeys.Control
local attempts = 0
local lastAttempt = 0
local skillingOrder = {Katarina={Q,E,W,Q,Q,R,Q,E,Q,W,R,W,W,W,E,R,E,E},}

local passive = false
local Qrange = 0
local bluePill = nil
local timer = os.clock()

local QSS = {
"Stun_glb",
"AlZaharNetherGrasp_tar",
"InfiniteDuress_tar",
"skarner_ult_tail_tip",
"SwapArrow_red", "summoner_banish",
"Global_Taunt",
"mordekaiser_cotg_tar",
"Global_Fear",
"Ahri_Charm_buf",
"leBlanc_shackle_tar",
"LuxLightBinding_tar",
"Fizz_UltimateMissle_Orbit",
"Fizz_UltimateMissle_Orbit_Lobster",
"RunePrison_tar",
"DarkBinding_tar",
"nassus_wither_tar",
"Amumu_SadRobot_Ultwrap",
"Amumu_Ultwrap",
"maokai_elementalAdvance_root_01",
"RengarEMax_tar",
"VarusRHitFlash"
}
local Cleanselist = {
"Stun_glb",
"summoner_banish",
"Global_Taunt",
"Global_Fear",
"Ahri_Charm_buf",
"leBlanc_shackle_tar",
"LuxLightBinding_tar",
"RunePrison_tar",
"DarkBinding_tar",
"nassus_wither_tar",
"Amumu_SadRobot_Ultwrap",
"Amumu_Ultwrap",
"maokai_elementalAdvance_root_01",
"RengarEMax_tar",
"VarusRHitFlash"
}

function KatRun()
	if IsChatOpen() == 0 and tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client" then
	target = GetWeakEnemy('MAGIC',730)
	target2 = GetWeakEnemy('TRUE',700)
		
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
	
	if GetTickCount() > lastRDagger + 250 then spinning = false end
	if KatConfig.combo then combo() end
	if KatConfig.harass then harass() end
	if KatConfig.steal and target ~= nil then steal() end
	if KatConfig.wardJump then wardjump() end
	if KatConfig.ignite then ignite() end
	if KatConfig.smite then smitesteal() end
	if KatConfig.autoLevelSpells then AutoLevel() end
	if KatConfig.blockult then blockult() end
	if KatConfig.ShowStuns then StunDraw() end
	if KatConfig.drawskillshots then Skillshots() end
	if KatConfig.killminions then killminions() end
	if KatConfig.drawCircles then KatDraw() end
	end
end

KatConfig = scriptConfig("Sida's Katarina", "sidaskat")
KatConfig:addParam("combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
KatConfig:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
KatConfig:addParam("harassMode", "Harass Mode", SCRIPT_PARAM_DOMAINUPDOWN, 2, string.byte("T"), {"Q","Q+W","Q+W+E"})
KatConfig:addParam("wardJump", "Ward Jump", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
KatConfig:addParam("steal", "Kill Steal", SCRIPT_PARAM_ONOFF, false)
KatConfig:addParam("movement", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)
KatConfig:addParam("useItems", "Use Items", SCRIPT_PARAM_ONOFF, true)
KatConfig:addParam("drawCircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
KatConfig:addParam("autoAttack", "Auto Attack After Combo", SCRIPT_PARAM_ONOFF, true)
KatConfig:addParam("ignite", "Auto-Ignite", SCRIPT_PARAM_ONOFF, false)
KatConfig:addParam("cleanse", "Auto Cleanse", SCRIPT_PARAM_ONOFF, true)
KatConfig:addParam("QSS", "Auto QSS", SCRIPT_PARAM_ONOFF, true)
KatConfig:addParam("autoLevelSpells", "AutoLevel", SCRIPT_PARAM_ONOFF, false)
KatConfig:addParam("drawskillshots", "Draw Skillshots", SCRIPT_PARAM_ONOFF, true)
KatConfig:addParam("dodgeskillshots", "Dodge Skillshots", SCRIPT_PARAM_ONOFF, true)
KatConfig:addParam("ShowStuns", "Show Stuns", SCRIPT_PARAM_ONOFF, false)
KatConfig:addParam("blockult", "Ult Block CC avoider", SCRIPT_PARAM_ONOFF, false)
KatConfig:addParam("DetectionRange", "DetectionRange", SCRIPT_PARAM_NUMERICUPDOWN, 2500, 97, 100, 3000, 100)
KatConfig:addParam("blockultrange", "blockultrange", SCRIPT_PARAM_NUMERICUPDOWN, 1200, 98, 100, 3000, 100)
KatConfig:addParam("AutoWooglets", "Auto Wooglets", SCRIPT_PARAM_ONOFF, false)
KatConfig:addParam("AutoWoogletspercent", "Auto Wooglets %", SCRIPT_PARAM_NUMERICUPDOWN, 20, 99, 5, 95, 5)
--KatConfig:addParam("killminions", "Kill Minions", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
KatConfig:permaShow("combo")
KatConfig:permaShow("harass")
KatConfig:permaShow("harassMode")
--KatConfig:permaShow("killminions")
KatConfig:permaShow("wardJump")

--- ### UTILITY ### ---
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

function AutoWooglets()
	if spinning == false and bluePill == nil then
		if myHero.health < ((myHero.maxHealth*KatConfig.AutoWoogletspercent)/100) then
			GetInventorySlot(3090)
			UseItemOnTarget(3090, myHero)
		end
	end
	if (os.clock() < timer + 5000) then
		bluePill = nil 
	end
end

function OnCreateObj(obj)
	if obj ~= nil then
		if (string.find(obj.charName,"katarina_deathLotus_mis.troy") ~= nil) then
			spinning = true
			lastRDagger = GetTickCount()
		end
		if GetTickCount() - lastWard < 3000 and string.find(obj.name, "Ward") ~= nil  or string.find(obj.name, "WriggleLantern") ~= nil or string.find(obj.name, "Sightstone") ~= nil and GetDistance(obj, mousePos) < 600 then
			CastSpellTarget("E", obj)
		end
		if (GetDistance(myHero, obj)) < 100 and KatConfig.QSS then
			if listContains(QSS, obj.charName) then
				GetInventorySlot(3139)
				UseItemOnTarget(3139, myHero)
				GetInventorySlot(3140)
				UseItemOnTarget(3140, myHero)
			end            
			if listContains(Cleanselist, obj.charName) and KatConfig.cleanse then
				if myHero.SummonerD == "SummonerBoost" then
					CastSpellXYZ("D",myHero.x,myHero.y,myHero.z)
				elseif myHero.SummonerF == "SummonerBoost" then
					CastSpellXYZ("F",myHero.x,myHero.y,myHero.z)
				end
			end
		end
		--[[
		for i = 1, objManager:GetMaxHeroes()  do
			local enemie = objManager:GetHero(i)
			if (enemie ~= nil and enemie.team ~= myHero.team and enemie.visible == 1 and enemie.dead == 0) then
				if string.find(obj.name, "StunReady") and GetDistance(enemie,obj) < 100 then
					passive = true
				end
			end
		end
		]]--
		if GetDistance(obj) < 100 and KatConfig.AutoWooglets then
			if string.find(obj.charName,"FountainHeal") then
				timer = os.clock()
				bluePill = obj
			end	
		end
	end
end

function listContains(list, particleName)
	for _, particle in pairs(list) do
			if particleName:find(particle) then return true end
	end
	return false
end
--- ### ------- ### ---


--- ### ACTIVE SKILLS + KILLSTEAL ### ---

function combo()
        if target ~= nil then
		if KatConfig.useItems then UseAllItems(target) end
            if spinning == false then
                if GetDistance(target) < 675 then
                    castQ(target) 
                end
                if GetDistance(target) < 375 then
                    castW(target)
                end
                if GetDistance(target) < 700 then
                    castE(target) 
                end
                if GetDistance(target) < 275 then
                    castR(target) 
                end
            end
        end
        if spinning == false then
			if target == nil and KatConfig.movement then
				MoveToMouse()
			elseif target ~= nil then
				if KatConfig.autoAttack then
					AttackTarget(target)
				elseif KatConfig.movement then
					MoveToMouse()
				end
			end
        end
    end 

	
function harass()
	if KatConfig.movement then
		MoveToMouse()
	end
	if target ~= nil then
		if GetDistance(target) < 675 then
			castQ(target) 
		end
		if KatConfig.harassMode > 1 and GetDistance(target) < 375 then
			castW(target)
		end
		if KatConfig.harassMode > 2 and GetDistance(target) < 700 then
			castE(target) 
		end
	end
end

--[[
function steal()
	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) then
			local Q = getDmg("Q",enemy,myHero)*IsSpellReady("Q")
			local W = getDmg("W",enemy,myHero)*IsSpellReady("W")
			local E = getDmg("E",enemy,myHero)*IsSpellReady("E")
			if lastHotkey == 3 then
				if enemy.health<Q+W+E then
					castE(enemy)
				end
			lastHotkey = 1
			return
			elseif lastHotkey == 1 then
				if enemy.health<Q+W+E then
					castW(enemy)
				end
			lastHotkey = 2
			return
			elseif lastHotkey == 2 then
				if enemy.health<Q+W+E then
					castQ(enemy)
				end
			lastHotkey = 3
			return
			end
		end
    end
end
]]--

function steal()
	if lastHotkey == 3 then 
        CastHotkey("SPELLE:WEAKENEMY ONESPELLHIT=#((spellq_ready)*(((spellq_level*35)+25+((player_ap*45)/100))-1)+(spelle_ready)*(((spelle_level*25)+35+((player_ap*4)/10))-1)+(spellw_ready)*(((spellw_level*35)+5+((player_ap*25)/100)+((player_ad*6)/10))-1)) RANGE=700 NOSHOW")
        lastHotkey = 1
        return
    elseif lastHotkey == 1 then
        CastHotkey("SPELLW:WEAKENEMY ONESPELLHIT=#((spellq_ready)*(((spellq_level*35)+25+((player_ap*45)/100))-1)+(spelle_ready)*(((spelle_level*25)+35+((player_ap*4)/10))-1)+(spellw_ready)*(((spellw_level*35)+5+((player_ap*25)/100)+((player_ad*6)/10))-1)) RANGE=375 NOSHOW")
        lastHotkey = 2
        return
    elseif lastHotkey == 2 then
        CastHotkey("SPELLQ:WEAKENEMY ONESPELLHIT=#((spellq_ready)*(((spellq_level*35)+25+((player_ap*45)/100))-1)+(spelle_ready)*(((spelle_level*25)+35+((player_ap*4)/10))-1)+(spellw_ready)*(((spellw_level*35)+5+((player_ap*25)/100)+((player_ad*6)/10))-1)) RANGE=675 NOSHOW")
        lastHotkey = 3
        return
    end
end

function castQ(target)
    if QRDY then
        CastSpellTarget("Q",target)
    end
end

function castW(target)
    if WRDY then
		CastSpellTarget("W",target)
    end
end

function castE(target)
    if ERDY then
        CastSpellTarget("E",target)
    end
end

function castR(target)    
    if RRDY then
		if KatConfig.blockult == true then
			if ultblock == false then
				if QRDY == false and WRDY == false and ERDY == false then
					CastSpellTarget("R", target)
					spinning = true
				end
			end
		elseif KatConfig.blockult == false then
			if QRDY == false and WRDY == false and ERDY == false then
				CastSpellTarget("R", target)
				spinning = true
			end
		end
    end
end

function castQ(enemy)
    if QRDY then
        CastSpellTarget("Q",enemy)
    end
end

function castW(enemy)
    if WRDY then
		CastSpellTarget("W",enemy)
    end
end

function castE(enemy)
    if ERDY then
        CastSpellTarget("E",enemy)
    end
end
--- ### ------------------------- ### ---


--- ### WARDJUMP ### ---
function wardjump()
	for _, ward in pairs(Wards) do
		if ERDY and GetInventorySlot(ward) ~= nil and GetTickCount() - lastWard > 3000 then
			local pos = getWardPos()
			UseItemLocation(ward, pos.x, 0, pos.z)
			lastWard = GetTickCount()
		end
	end
end

function getWardPos()
	local MousePos = Vector(mousePos.x, mousePos.y, mousePos.z)
	local HeroPos = Vector(myHero.x, myHero.y, myHero.z)
	return HeroPos + ( HeroPos - MousePos )*(-600/GetDistance(HeroPos, MousePos))
end

function KatDraw()
	CustomCircle(700,4,3,myHero)
	if target ~= nil then
		CustomCircle(100,4,1,target)
	end
	for i = 1, objManager:GetMaxHeroes()  do
		local enemy = objManager:GetHero(i)
		if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) then
			local Q = getDmg("Q",enemy,myHero)*IsSpellReady("Q")
			local W = getDmg("W",enemy,myHero)*IsSpellReady("W")
			local E = getDmg("E",enemy,myHero)*IsSpellReady("E")
				if enemy.health<Q+W+E then
				CustomCircle(100,4,2,enemy)
				DrawTextObject("KILL HIM!!!", enemy, Color.Red)					
			end
		end
	end
end
--- ### -------- ### ---


--- ### AUTO LEVEL ### ---
function AutoLevel()
	local spellLevelSum = GetSpellLevel(Q) + GetSpellLevel(W) + GetSpellLevel(E) + GetSpellLevel(R)
	if attempts <= 10 or (attempts > 10 and GetTickCount() > lastAttempt+1500) then
		if spellLevelSum < myHero.selflevel then
			if lastSpellLevelSum ~= spellLevelSum then attempts = 0 end
			letter = skillingOrder[myHero.name][spellLevelSum+1]
			Level_Spell(letter, spellLevelSum)
			attempts = attempts+1
			lastAttempt = GetTickCount()
			lastSpellLevelSum = spellLevelSum
		else
			attempts = 0
		end
	end
	send.tick()
end

function Level_Spell(letter)  
     if letter == Q then send.key_press(0x69)
     elseif letter == W then send.key_press(0x6a)
     elseif letter == E then send.key_press(0x6b)
     elseif letter == R then send.key_press(0x6c) end
end
--- ### ---------- ### ---


--- ### STUN DETECTOR + ULTBLOCK ### ---
function blockult()
	local stunChamps = 0
	local amountCC = 0
	for i = 1, objManager:GetMaxHeroes()  do
	local enemie = objManager:GetHero(i)
		if (enemie ~= nil and enemie.team ~= myHero.team and enemie.visible == 1 and enemie.dead == 0) and GetDistance(myHero,enemie) < KatConfig.blockultrange then
			local targetCC = GetTargetCC("HardCC",enemie)
			if targetCC > 0 then
				stunChamps = stunChamps+1
				amountCC = amountCC+targetCC
				ultblock = true
				DrawText("ULT BLOCK", 10, 160, 0xFFFFFF00)
			else
				ultblock = false
			end
		end
	end
end

function StunDraw()
	local stunChamps = 0
	local amountCC = 0
	for i = 1, objManager:GetMaxHeroes()  do
	local enemie = objManager:GetHero(i)
		if (enemie ~= nil and enemie.team ~= myHero.team and enemie.visible == 1 and enemie.dead == 0) and GetDistance(myHero,enemie) < KatConfig.DetectionRange then
			local targetCC = GetTargetCC("HardCC",enemie)
			if targetCC > 0 then
				stunChamps = stunChamps+1
				amountCC = amountCC+targetCC
				if enemie.visible then
					thickness = basicthickness*targetCC
					for j=1, thickness do
						local ycircle = (j*(radius/thickness*2)-radius)
						local r = math.sqrt(radius^2-ycircle^2)
						ycircle = ycircle/1.3
						DrawCircle(enemie.x, enemie.y+250+ycircle, enemie.z, r, 0x00FF00)
					end
				end
			end
		end
	end
	DrawText("Hard CC: "..amountCC, X, Y, 0xFFFFFF00)
	DrawText("CC champions: "..stunChamps, X, Y+15, 0xFFFFFF00)
end

function GetTargetCC(typeCC,enemie)
	local HardCC, Airborne, Charm, Fear, Taunt, Polymorph, Silence, Stun, Suppression = 0, 0, 0, 0, 0, 0, 0, 0, 0
	local SoftCC, Blind, Entangle, Slow, Snare, Wall = 0, 0, 0, 0, 0, 0
	local targetName = enemie.name
	local QREADY = enemie.SpellTimeQ > 1
	local WREADY = enemie.SpellTimeW > 1
	local EREADY = enemie.SpellTimeE > 1
	local RREADY = enemie.SpellTimeR > 1
	if targetName == "Ahri" then
		if EREADY then
			HardCC = HardCC+1
			Charm = Charm+1
		end
	elseif targetName == "Alistar" then
		if QREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
		if WREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Amumu" then
		if QREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
		if RREADY then
			SoftCC = SoftCC+1
			Entangle = Entangle+1
		end
	elseif targetName == "Anivia" then
		if QREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
		--[[
	elseif targetName == "Annie" then
		if passive and (QREADY or WREADY or RREADY) then
			HardCC = HardCC+1
			Stun = Stun+1
		end
		]]--
	elseif targetName == "Ashe" then
		if RREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "Blitzcrank" then
		if QREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
		if EREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Brand" then
		if QREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "Cassiopeia" then
		if RREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "Chogath" then
		if QREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
		if WREADY then
			HardCC = HardCC+1
			Silence = Silence+1
		end
	elseif targetName == "Darius" then
		if EREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Diana" then
		if EREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Draven" then
		if EREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Elise" then
		if EREADY and enemie.range > 300 then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "FiddleSticks" then
		if QREADY then
			HardCC = HardCC+1
			Fear = Fear+1
		end
		if RREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Fizz" then
		if RREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Galio" then
		if RREADY then
			HardCC = HardCC+1
			Taunt = Taunt+1			
		end
	elseif targetName == "Garen" then
		if QREADY then
			HardCC = HardCC+1
			Silence = Silence+1			
		end
	elseif targetName == "Gragas" then
		if RREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1		
		end
	elseif targetName == "Hecarim" then
		if EREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1	
		end
		if RREADY then
			HardCC = HardCC+1
			Fear = Fear+1
		end
	elseif targetName == "Heimerdinger" then
		if EREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "Irelia" then
		if EREADY then
			if (enemie.health/enemie.maxHealth) <= (myHero.health/myHero.maxHealth) then
				HardCC = HardCC+1
				Stun = Stun+1
			end			
		end
	elseif targetName == "Janna" then
		if QREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
		if RREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "JarvanIV" then
		if QREADY and EREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Jax" then
		if EREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "Jayce" then
		if EREADY and enemie.SpellNameR == "JayceThunderingBlow" then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Kassadin" then
		if QREADY then
			HardCC = HardCC+1
			Silence = Silence+1
		end
	elseif targetName == "Kennen" then
		if QREADY and WREADY and EREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
		if RREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "LeBlanc" then
		if QREADY and (WREADY or EREADY or RREADY) then
			HardCC = HardCC+1
			Silence = Silence+1
		end
		if RREADY and enemie.SpellNameR == "LeblancChaosOrbM" and (WREADY or EREADY or QREADY) then
			HardCC = HardCC+1
			Silence = Silence+1
		end
	elseif targetName == "LeeSin" then
		if RREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Leona" then
		if QREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
		if RREADY then
			HardCC = HardCC+1
			Stun = Stun+11
		end
	elseif targetName == "Lissandra" then
		if RREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "Lulu" then
		if WREADY then
			HardCC = HardCC+1
			Polymorph = Polymorph+1
		end
		if RREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Malphite" then
		if RREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Malzahar" then
		if QREADY then
			HardCC = HardCC+1
			Silence = Silence+1			
		end
		if RREADY then
			HardCC = HardCC+1
			Suppression = Suppression+1
		end
	elseif targetName == "Nami" then
		if QREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
		if RREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Nautilus" then
		HardCC = HardCC+1
		Stun = Stun+1
		if QREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
		if RREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end	
	elseif targetName == "Nocturne" then
		if EREADY then
			HardCC = HardCC+1
			Fear = Fear+1
		end
	elseif targetName == "Orianna" then
		if RREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Pantheon" then
		if WREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "Poppy" then
		if EREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
			Stun = Stun+1
		end
		elseif targetName == "Quinn" then
			if QREADY then
				SoftCC = SoftCC+1
				Blind = Blind+1
			end
			if EREADY then
				SoftCC = SoftCC+1
				Slow = Slow+1
				HardCC = HardCC+1
				Stun = Stun+1
			end
	elseif targetName == "Rammus" then
		if QREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
		if EREADY then
			HardCC = HardCC+1
			Taunt = Taunt+1	
		end
	elseif targetName == "Renekton" then
		if WREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "Riven" then
		if QREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
		if WREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "Sejuani" then
		if QREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
		if RREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "Shen" then
		if EREADY then
			HardCC = HardCC+1
			Taunt = Taunt+1
		end
	elseif targetName == "Shyvana" then
		if RREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Singed" then
		if EREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Sion" then
		if QREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "Skarner" then
		if RREADY then
			HardCC = HardCC+1
			Suppression = Suppression+1
		end
	elseif targetName == "Sona" then
		if RREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "Soraka" then
		if EREADY then
			HardCC = HardCC+1
			Silence = Silence+1
		end
	elseif targetName == "Syndra" then
		if EREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end	
	elseif targetName == "Talon" then
		if EREADY then
			HardCC = HardCC+1
			Silence = Silence+1
		end
	elseif targetName == "Taric" then
		if EREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "Thresh" then
		if QREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
		if EREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Tristana" then
		if RREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "TwistedFate" then
		if enemie.SpellNameW == "goldcardlock" then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "Udyr" then
		if EREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "Urgot" then
		if RREADY then
			HardCC = HardCC+1
			Suppression = Suppression+1
		end
	elseif targetName == "Vayne" then
		if EREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
			Stun = Stun+1
		end
	elseif targetName == "Veigar" then
		if EREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "Vi" then
		if QREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
		if RREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Viktor" then
		if WREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
		if RREADY then
			HardCC = HardCC+1
			Silence = Silence+1
		end
	elseif targetName == "Volibear" then
		if QREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Warwick" then
		if RREADY then
			HardCC = HardCC+1
			Suppression = Suppression+1
		end
	elseif targetName == "MonkeyKing" then
		if RREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Xerath" then
		if EREADY and (QREADY or RREADY) then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "XinZhao" then
		if QREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
		if RREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Zac" then
		if EREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
		if RREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Zyra" then
		if RREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	end
	if typeCC == "HardCC" then return HardCC
	elseif typeCC == "Airborne" then return Airborne
	elseif typeCC == "Charm" then return Charm
	elseif typeCC == "Fear" then return Fear
	elseif typeCC == "Taunt" then return Taunt
	elseif typeCC == "Polymorph" then return Polymorph
	elseif typeCC == "Silence" then return Silence
	elseif typeCC == "Stun" then return Stun
	elseif typeCC == "Suppression" then return Suppression
	elseif typeCC == "SoftCC" then return SoftCC
	elseif typeCC == "Blind" then return Blind
	elseif typeCC == "Entangle" then return Entangle
	elseif typeCC == "Slow" then return Slow
	elseif typeCC == "Snare" then return Snare
	elseif typeCC == "Wall" then return Wall
	else return 0 end
end
--- ### ------------------------ ### ---


--- ### SHOW-/DODGE SKILLSHOTS ### ---
function Skillshots()
	cc=cc+1
	if (cc==30) then
		LoadTable()
	end
	for i=1, #skillshotArray, 1 do
		if skillshotArray[i].shot == 1 then
			local radius = skillshotArray[i].radius
			local color = skillshotArray[i].color
			if skillshotArray[i].isline == false then
				for number, point in pairs(skillshotArray[i].skillshotpoint) do
					DrawCircle(point.x, point.y, point.z, radius, color)
				end
			else
				startVector = Vector(skillshotArray[i].p1x,skillshotArray[i].p1y,skillshotArray[i].p1z)
				endVector = Vector(skillshotArray[i].p2x,skillshotArray[i].p2y,skillshotArray[i].p2z)
				directionVector = (endVector-startVector):normalized()
				local angle=0
				if (math.abs(directionVector.x)<.00001) then
					if directionVector.z > 0 then angle=90
					elseif directionVector.z < 0 then angle=270
					else angle=0
					end
				else
					local theta = math.deg(math.atan(directionVector.z / directionVector.x))
					if directionVector.x < 0 then theta = theta + 180 end
						if theta < 0 then theta = theta + 360 end
							angle=theta
						end
							angle=((90-angle)*2*math.pi)/360
							DrawLine(startVector.x, startVector.y, startVector.z, GetDistance(startVector, endVector)+170, 1,angle,radius)
					end
				end
			end
	for i=1, #skillshotArray, 1 do
		if os.clock() > (skillshotArray[i].lastshot + skillshotArray[i].time) then
		skillshotArray[i].shot = 0
		end
	end
end

function OnProcessSpell(unit,spell)
	local P1 = spell.startPos
	local P2 = spell.endPos
	local calc = (math.floor(math.sqrt((P2.x-unit.x)^2 + (P2.z-unit.z)^2)))
	if string.find(unit.name,"Minion_") == nil and string.find(unit.name,"Turret_") == nil then
		if (unit.team ~= myHero.team or (show_allies==1)) and string.find(spell.name,"Basic") == nil then
			for i=1, #skillshotArray, 1 do
				local maxdist
				local dodgeradius
				dodgeradius = skillshotArray[i].radius
				maxdist = skillshotArray[i].maxdistance
				if spell.name == skillshotArray[i].name then
					skillshotArray[i].shot = 1
					skillshotArray[i].lastshot = os.clock()
					if skillshotArray[i].type == 1 then
						skillshotArray[i].p1x = unit.x
						skillshotArray[i].p1y = unit.y
						skillshotArray[i].p1z = unit.z
						skillshotArray[i].p2x = unit.x + (maxdist)/calc*(P2.x-unit.x)
						skillshotArray[i].p2y = P2.y
						skillshotArray[i].p2z = unit.z + (maxdist)/calc*(P2.z-unit.z)
						dodgelinepass(unit, P2, dodgeradius, maxdist)
					elseif skillshotArray[i].type == 2 then
						skillshotArray[i].px = P2.x
						skillshotArray[i].py = P2.y
						skillshotArray[i].pz = P2.z
						dodgelinepoint(unit, P2, dodgeradius)
					elseif skillshotArray[i].type == 3 then
						skillshotArray[i].skillshotpoint = calculateLineaoe(unit, P2, maxdist)
						if skillshotArray[i].name ~= "SummonerClairvoyance" then
							dodgeaoe(unit, P2, dodgeradius)
						end
					elseif skillshotArray[i].type == 4 then
						skillshotArray[i].px = unit.x + (maxdist)/calc*(P2.x-unit.x)
						skillshotArray[i].py = P2.y
						skillshotArray[i].pz = unit.z + (maxdist)/calc*(P2.z-unit.z)
						dodgelinepass(unit, P2, dodgeradius, maxdist)
					elseif skillshotArray[i].type == 5 then
						skillshotArray[i].skillshotpoint = calculateLineaoe2(unit, P2, maxdist)
						dodgeaoe(unit, P2, dodgeradius)
					end
				end
			end
		end
	end
end

function dodgeaoe(pos1, pos2, radius)
	print('dodgeaoe', pos1, pos2, radius, maxDist)
	print('dodgeaoe:pos1:', pos1.x, pos1.y, pos1.z)
	print('dodgeaoe:pos2:', pos2.x, pos2.y, pos2.z)
	local calc = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
	local dodgex
	local dodgez
	dodgex = pos2.x + ((radius+50)/calc)*(myHero.x-pos2.x)
	dodgez = pos2.z + ((radius+50)/calc)*(myHero.z-pos2.z)
	if calc < radius and not spinning and KatConfig.dodgeskillshots then
        MoveToXYZ(dodgex,0,dodgez)
	end
end

function dodgelinepoint(pos1, pos2, radius)
	local calc1 = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
	local calc2 = (math.floor(math.sqrt((pos1.x-myHero.x)^2 + (pos1.z-myHero.z)^2)))
	local calc4 = (math.floor(math.sqrt((pos1.x-pos2.x)^2 + (pos1.z-pos2.z)^2)))
	local calc3
	local perpendicular
	local k
	local x4
	local z4
	local dodgex
	local dodgez
	perpendicular = (math.floor((math.abs((pos2.x-pos1.x)*(pos1.z-myHero.z)-(pos1.x-myHero.x)*(pos2.z-pos1.z)))/(math.sqrt((pos2.x-pos1.x)^2 + (pos2.z-pos1.z)^2))))
	k = ((pos2.z-pos1.z)*(myHero.x-pos1.x) - (pos2.x-pos1.x)*(myHero.z-pos1.z)) / ((pos2.z-pos1.z)^2 + (pos2.x-pos1.x)^2)
	x4 = myHero.x - k * (pos2.z-pos1.z)
	z4 = myHero.z + k * (pos2.x-pos1.x)
	calc3 = (math.floor(math.sqrt((x4-myHero.x)^2 + (z4-myHero.z)^2)))
	dodgex = x4 + ((radius+50)/calc3)*(myHero.x-x4)
	dodgez = z4 + ((radius+50)/calc3)*(myHero.z-z4)
	if perpendicular < radius and calc1 < calc4 and calc2 < calc4 and not spinning and KatConfig.dodgeskillshots then
        MoveToXYZ(dodgex,0,dodgez)
	end
end

function dodgelinepass(pos1, pos2, radius, maxDist)
	print('dodgelinepass', pos1, pos2, radius, maxDist)
	print('dodgelinepass:pos1:', pos1.x, pos1.y, pos1.z)
	print('dodgelinepass:pos2:', pos2.x, pos2.y, pos2.z)
	local pm2x = pos1.x + (maxDist)/(math.floor(math.sqrt((pos1.x-pos2.x)^2 + (pos1.z-pos2.z)^2)))*(pos2.x-pos1.x)
	local pm2z = pos1.z + (maxDist)/(math.floor(math.sqrt((pos1.x-pos2.x)^2 + (pos1.z-pos2.z)^2)))*(pos2.z-pos1.z)
	local calc1 = (math.floor(math.sqrt((pm2x-myHero.x)^2 + (pm2z-myHero.z)^2)))
	local calc2 = (math.floor(math.sqrt((pos1.x-myHero.x)^2 + (pos1.z-myHero.z)^2)))
	local calc3
	local calc4 = (math.floor(math.sqrt((pos1.x-pm2x)^2 + (pos1.z-pm2z)^2)))
	local perpendicular
	local k
	local x4
	local z4
	local dodgex
	local dodgez
	perpendicular = (math.floor((math.abs((pm2x-pos1.x)*(pos1.z-myHero.z)-(pos1.x-myHero.x)*(pm2z-pos1.z)))/(math.sqrt((pm2x-pos1.x)^2 + (pm2z-pos1.z)^2))))
	k = ((pm2z-pos1.z)*(myHero.x-pos1.x) - (pm2x-pos1.x)*(myHero.z-pos1.z)) / ((pm2z-pos1.z)^2 + (pm2x-pos1.x)^2)
	x4 = myHero.x - k * (pm2z-pos1.z)
	z4 = myHero.z + k * (pm2x-pos1.x)
	calc3 = (math.floor(math.sqrt((x4-myHero.x)^2 + (z4-myHero.z)^2)))
	dodgex = x4 + ((radius+50)/calc3)*(myHero.x-x4)
	dodgez = z4 + ((radius+50)/calc3)*(myHero.z-z4)
	if perpendicular < radius and calc1 < calc4 and calc2 < calc4 and not spinning and KatConfig.dodgeskillshots then
        MoveToXYZ(dodgex,0,dodgez)
	end
end

function calculateLinepass(pos1, pos2, spacing, maxDist)
	local calc = (math.floor(math.sqrt((pos2.x-pos1.x)^2 + (pos2.z-pos1.z)^2)))
	local line = {}
	local point1 = {}
	point1.x = pos1.x
	point1.y = pos1.y
	point1.z = pos1.z
	local point2 = {}
	point1.x = pos1.x + (maxDist)/calc*(pos2.x-pos1.x)
	point1.y = pos2.y
	point1.z = pos1.z + (maxDist)/calc*(pos2.z-pos1.z)
	table.insert(line, point2)
	table.insert(line, point1)
	return line
end

function calculateLineaoe(pos1, pos2, maxDist)
	local line = {}
	local point = {}
	point.x = pos2.x
	point.y = pos2.y
	point.z = pos2.z
	table.insert(line, point)
	return line
end

function calculateLineaoe2(pos1, pos2, maxDist)
	local calc = (math.floor(math.sqrt((pos2.x-pos1.x)^2 + (pos2.z-pos1.z)^2)))
	local line = {}
	local point = {}
		if calc < maxDist then
		point.x = pos2.x
		point.y = pos2.y
		point.z = pos2.z
		table.insert(line, point)
	else
		point.x = pos1.x + maxDist/calc*(pos2.x-pos1.x)
		point.z = pos1.z + maxDist/calc*(pos2.z-pos1.z)
		point.y = pos2.y
		table.insert(line, point)
	end
	return line
end

function calculateLinepoint(pos1, pos2, spacing, maxDist)
	local line = {}
	local point1 = {}
	point1.x = pos1.x
	point1.y = pos1.y
	point1.z = pos1.z
	local point2 = {}
	point1.x = pos2.x
	point1.y = pos2.y
	point1.z = pos2.z
	table.insert(line, point2)
	table.insert(line, point1)
	return line
end

function table_print (tt, indent, done)
	done = done or {}
	indent = indent or 0
	if type(tt) == "table" then
		local sb = {}
		for key, value in pairs (tt) do
			table.insert(sb, string.rep (" ", indent)) -- indent it
			if type (value) == "table" and not done [value] then
				done [value] = true
				table.insert(sb, "{\n");
				table.insert(sb, table_print (value, indent + 2, done))
				table.insert(sb, string.rep (" ", indent)) -- indent it
				table.insert(sb, "}\n");
			elseif "number" == type(key) then
				table.insert(sb, string.format("\"%s\"\n", tostring(value)))
			else
				table.insert(sb, string.format(
				"%s = \"%s\"\n", tostring (key), tostring(value)))
			end
		end
		return table.concat(sb)
	else
	return tt .. "\n"
	end
end

function LoadTable()
	print("table loaded::")
	local iCount=objManager:GetMaxHeroes()
	print(" heros:" .. tostring(iCount))
	iCount=1;
	for i=0, iCount, 1 do
		local skillshotplayerObj = GetSelf();
		print(" name:" .. skillshotplayerObj.name);
		if 1==1 or skillshotplayerObj.name == "Quinn" then
			table.insert(skillshotArray,{name= "QuinnQMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1025, type = 1, radius = 40, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Lissandra" then
			table.insert(skillshotArray,{name= "LissandraQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 725, type = 1, radius = 100, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "LissandraE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 100, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Zac" then
			table.insert(skillshotArray,{name= "ZacQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 550, type = 1, radius = 100, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "ZacE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1550, type = 3, radius = 200, color= colorcyan, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Syndra" then
			table.insert(skillshotArray,{name= "SyndraQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 200, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "SyndraE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 1, radius = 100, color= coloryellow, time = 0.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "syndrawcast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 200, color= colorcyan, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Jayce" then
			table.insert(skillshotArray,{name= "jayceshockblast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1470, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Nami" then
			table.insert(skillshotArray,{name= "NamiQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 875, type = 3, radius = 200, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "NamiR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2550, type = 1, radius = 350, color= colorcyan, time = 3, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Vi" then
			table.insert(skillshotArray,{name= "ViQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 150, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
			if 1==1 or skillshotplayerObj.name == "Thresh" then
			table.insert(skillshotArray,{name= "ThreshQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Khazix" then
			table.insert(skillshotArray,{name= "KhazixE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 3, radius = 200, color= colorcyan, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "KhazixW", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 120, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "khazixwlong", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "khazixelong", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 200, color= colorcyan, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Elise" then
			table.insert(skillshotArray,{name= "EliseHumanE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Zed" then
			table.insert(skillshotArray,{name= "ZedShuriken", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 100, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "ZedShadowDash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 550, type = 3, radius = 150, color= colorcyan, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "zedw2", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 550, type = 3, radius = 150, color= colorcyan, time = 0.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Ahri" then
			table.insert(skillshotArray,{name= "AhriOrbofDeception", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 880, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			table.insert(skillshotArray,{name= "AhriSeduce", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Amumu" then
			table.insert(skillshotArray,{name= "BandageToss", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Anivia" then
			table.insert(skillshotArray,{name= "FlashFrostSpell", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 90, color= colorcyan, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Ashe" then
			table.insert(skillshotArray,{name= "EnchantedCrystalArrow", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 50000, type = 4, radius = 120, color= colorcyan, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Blitzcrank" then
			table.insert(skillshotArray,{name= "RocketGrabMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Brand" then
			table.insert(skillshotArray,{name= "BrandBlazeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 70, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			table.insert(skillshotArray,{name= "BrandFissure", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Cassiopeia" then
			table.insert(skillshotArray,{name= "CassiopeiaMiasma", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 175, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "CassiopeiaNoxiousBlast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 75, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Caitlyn" then
			table.insert(skillshotArray,{name= "CaitlynEntrapmentMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 50, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "CaitlynPiltoverPeacemaker", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Corki" then
			table.insert(skillshotArray,{name= "MissileBarrageMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1225, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "MissileBarrageMissile2", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1225, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "CarpetBomb", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 2, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Chogath" then
			table.insert(skillshotArray,{name= "Rupture", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 275, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "DrMundo" then
			table.insert(skillshotArray,{name= "InfectedCleaverMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Heimerdinger" then
			table.insert(skillshotArray,{name= "CH1ConcussionGrenade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 225, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Draven" then
			table.insert(skillshotArray,{name= "DravenDoubleShot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 125, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "DravenRCast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 1, radius = 100, color= colorcyan, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Ezreal" then
			table.insert(skillshotArray,{name= "EzrealEssenceFluxMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "EzrealMysticShotMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "EzrealTrueshotBarrage", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 4, radius = 150, color= colorcyan, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "EzrealArcaneShift", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 475, type = 5, radius = 100, color= colorgreen, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Fizz" then
			table.insert(skillshotArray,{name= "FizzMarinerDoom", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1275, type = 2, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "FiddleSticks" then
			table.insert(skillshotArray,{name= "Crowstorm", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 600, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Karthus" then
			table.insert(skillshotArray,{name= "LayWaste", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 875, type = 3, radius = 150, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Galio" then
			table.insert(skillshotArray,{name= "GalioResoluteSmite", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 905, type = 3, radius = 200, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "GalioRighteousGust", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 120, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Graves" then
			table.insert(skillshotArray,{name= "GravesChargeShot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 110, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "GravesClusterShot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 750, type = 1, radius = 50, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "GravesSmokeGrenade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 3, radius = 275, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Gragas" then
			table.insert(skillshotArray,{name= "GragasBarrelRoll", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 320, color= coloryellow, time = 2.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "GragasBodySlam", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 2, radius = 60, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "GragasExplosiveCask", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 3, radius = 400, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Irelia" then
			table.insert(skillshotArray,{name= "IreliaTranscendentBlades", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 150, color= colorcyan, time = 0.8, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Janna" then
			table.insert(skillshotArray,{name= "HowlingGale", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1700, type = 1, radius = 100, color= colorcyan, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "JarvanIV" then
			table.insert(skillshotArray,{name= "JarvanIVDemacianStandard", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 830, type = 3, radius = 150, color= coloryellow, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "JarvanIVDragonStrike", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 770, type = 1, radius = 70, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "JarvanIVCataclysm", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 3, radius = 300, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Kassadin" then
			table.insert(skillshotArray,{name= "RiftWalk", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 5, radius = 150, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Katarina" then
			table.insert(skillshotArray,{name= "ShadowStep", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 3, radius = 75, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Kennen" then
			table.insert(skillshotArray,{name= "KennenShurikenHurlMissile1", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 75, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "KogMaw" then
			table.insert(skillshotArray,{name= "KogMawVoidOozeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1115, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "KogMawLivingArtillery", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2200, type = 3, radius = 200, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Lucian" then
			table.insert(skillshotArray,{name= "LucianQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= colorcyan, time = 0.75, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "LucianW", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "LucianR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1400, type = 1, radius = 250, color= colorcyan, time = 3, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Leblanc" then
			table.insert(skillshotArray,{name= "LeblancSoulShackle", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "LeblancSoulShackleM", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "LeblancSlide", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "LeblancSlideM", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "leblancslidereturn", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 50, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "leblancslidereturnm", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 50, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "LeeSin" then
			table.insert(skillshotArray,{name= "BlindMonkQOne", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "BlindMonkRKick", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Leona" then
			table.insert(skillshotArray,{name= "LeonaZenithBladeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Lux" then
			table.insert(skillshotArray,{name= "LuxLightBinding", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1175, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "LuxLightStrikeKugel", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 300, color= coloryellow, time = 2.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "LuxMaliceCannon", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 3000, type = 1, radius = 180, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Lulu" then
			table.insert(skillshotArray,{name= "LuluQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 50, color= colorcyan, time = 1, isline = true, px =0, py =0 , pz =0, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Maokai" then
			table.insert(skillshotArray,{name= "MaokaiTrunkLineMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "MaokaiSapling2", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 350 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Malphite" then
			table.insert(skillshotArray,{name= "UFSlash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 325, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Malzahar" then
			table.insert(skillshotArray,{name= "AlZaharCalloftheVoid", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 100 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "AlZaharNullZone", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 250 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "MissFortune" then
			table.insert(skillshotArray,{name= "MissFortuneScattershot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 400, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Morgana" then
			table.insert(skillshotArray,{name= "DarkBindingMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 90, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "TormentedSoil", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 300, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Nautilus" then
			table.insert(skillshotArray,{name= "NautilusAnchorDrag", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 1, radius = 150, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Nidalee" then
			table.insert(skillshotArray,{name= "JavelinToss", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1500, type = 1, radius = 150, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Nocturne" then
			table.insert(skillshotArray,{name= "NocturneDuskbringer", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 150, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Olaf" then
			table.insert(skillshotArray,{name= "OlafAxeThrow", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 2, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Orianna" then
			table.insert(skillshotArray,{name= "OrianaIzunaCommand", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 825, type = 3, radius = 150, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Renekton" then
			table.insert(skillshotArray,{name= "RenektonSliceAndDice", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 450, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "renektondice", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 450, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Rumble" then
			table.insert(skillshotArray,{name= "RumbleGrenadeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "RumbleCarpetBomb", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1700, type = 1, radius = 100, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Sivir" then
			table.insert(skillshotArray,{name= "SpiralBlade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Singed" then
			table.insert(skillshotArray,{name= "MegaAdhesive", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 350, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Shen" then
			table.insert(skillshotArray,{name= "ShenShadowDash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 2, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Shaco" then
			table.insert(skillshotArray,{name= "Deceive", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 500, type = 5, radius = 100, color= colorgreen, time = 3.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Shyvana" then
			table.insert(skillshotArray,{name= "ShyvanaTransformLeap", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 150, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "ShyvanaFireballMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Skarner" then
			table.insert(skillshotArray,{name= "SkarnerFracture", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Sona" then
			table.insert(skillshotArray,{name= "SonaCrescendo", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Sejuani" then
			table.insert(skillshotArray,{name= "SejuaniGlacialPrison", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1150, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Swain" then
			table.insert(skillshotArray,{name= "SwainShadowGrasp", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 265 , color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Tryndamere" then
			table.insert(skillshotArray,{name= "Slash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 2, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Tristana" then
			table.insert(skillshotArray,{name= "RocketJump", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 200, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "TwistedFate" then
			table.insert(skillshotArray,{name= "WildCards", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1450, type = 1, radius = 150, color= colorcyan, time = 5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Urgot" then
			table.insert(skillshotArray,{name= "UrgotHeatseekingLineMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= colorcyan, time = 0.8, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "UrgotPlasmaGrenade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 300, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Vayne" then
			table.insert(skillshotArray,{name= "VayneTumble", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 250, type = 3, radius = 100, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Varus" then
			--table.insert(skillshotArray,{name= "VarusQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1475, type = 1, radius = 50, color= coloryellow, time = 1})
			table.insert(skillshotArray,{name= "VarusR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 150, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Veigar" then
			table.insert(skillshotArray,{name= "VeigarDarkMatter", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 225, color= coloryellow, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Viktor" then
			--table.insert(skillshotArray,{name= "ViktorDeathRay", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 150, color= coloryellow, time = 2})
		end
		if 1==1 or skillshotplayerObj.name == "Xerath" then
			table.insert(skillshotArray,{name= "xeratharcanopulsedamage", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "xeratharcanopulsedamageextended", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "xeratharcanebarragewrapper", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "xeratharcanebarragewrapperext", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Ziggs" then
			table.insert(skillshotArray,{name= "ZiggsQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 160, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "ZiggsW", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 225 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "ZiggsE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "ZiggsR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5300, type = 3, radius = 550, color= coloryellow, time = 3, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Zyra" then
			table.insert(skillshotArray,{name= "ZyraQFissure", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 825, type = 3, radius = 275, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "ZyraGraspingRoots", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 90, color= colorcyan, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Diana" then
			table.insert(skillshotArray,{name= "DianaArc", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 205, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
    end
end
--- ### ---------------------- ### ---

function killminions()
	local minion = GetLowestHealthEnemyMinion(700)
	if minion ~= nil then
		if QRDY and GetDistance(minion) < 675 then
			CastSpellXYZ('Q', GetCursorWorldX(),GetCursorWorldY(),GetCursorWorldZ())
		end
		if ERDY and QRDY == false and GetDistance(minion) < 700 then
			CastSpellXYZ('E', GetCursorWorldX(),GetCursorWorldY(),GetCursorWorldZ())
		end
		if WRDY and QRDY == false and ERDY == false and GetDistance(minion) < 375 then
			CastSpellXYZ('W', GetCursorWorldX(),GetCursorWorldY(),GetCursorWorldZ())
		end
	end
end

SetTimerCallback("KatRun")
print("\nSida's Katarina (Val's revision) v"..version.."\n")