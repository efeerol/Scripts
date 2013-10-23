require 'Utils'
require 'winapi'
require 'SKeys'
require 'spell_damage'
require 'runrunrun'

local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local version = '1.5'
local target
local target2
local target3
local targetignite
local GlobalTarget
local GG = false
local timer = 0
local timer2 = 0
local xy,xb,ya,yb = nil,nil,nil,nil
local spellShot = {shot = false, radius = 0, time = 0, shotX = 0, shotZ = 0, shotY = 0, safeX = 0, safeY = 0, safeZ = 0, isline = false}
local startPos = {x=0, y=0, z=0}
local endPos = {x=0, y=0, z=0}
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
local skillingOrder = {Karma = {Q,W,E,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},}

function Karma()
	if IsChatOpen() == 0 and tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client" then
	
	xa = 30/1920*GetScreenX()
	xb = 1890/1920*GetScreenX()
	ya = 30/1080*GetScreenY()
	yb = 1050/1080*GetScreenY()

	target2 = GetWeakEnemy('MAGIC',650)
	target3 = GetWeakEnemy('MAGIC',850)
	targetignite = GetWeakEnemy('TRUE',600)
	GetWeakAlly()
	GetWeakOpponent()
	Cooldown_Handling()
	
	if KarmaConfig.ignite then ignite() end
	
	if KarmaConfig.QSpell then
		if target3 ~= nil and QRDY == 1 and CreepBlock(GetFireahead(target3,1.6,17,150)) == 0 then
			CastSpellXYZ('Q',GetFireahead(target3,1.6,17))
		end
	end
	
	if KarmaConfig.Wspell then 
		if target2 ~= nil and WRDY == 1 then
			CastSpellTarget('W',target2)
		end
	end
	
	if KarmaConfig.Espell then
		if KarmaConfig.Val == true then
			if ERDY == 1 then
				CastSpellTarget('E',myHero)
			end
		elseif KarmaConfig.Val == false then
			CastHotkey("AUTO 100,0 SPELLE:WEAKALLY RANGE=800 COOLDOWN")
		end
	end
	
	if GetTickCount() - spellShot.time > 0 then
		spellShot.shot = false
		spellShot.time = 0
		shotMe = false
	end
	
	if timer2 ~= 0 and GetTickCount() - timer2 > 200 then
		timer2 = 0
		GG = false
	end
	
	if GG == true and GlobalTarget ~= nil then
		if RRDY == 1 then
			CastSpellTarget('R',GlobalTarget)
		end
		CastSpellXYZ('Q',GlobalTarget.x,GlobalTarget.y,GlobalTarget.z)
	end
	
	if blockAndMove ~= nil then blockAndMove() end
	send.tick()
	
	if KarmaConfig.killsteal then run_every((1/10),killsteal) end
	if KarmaConfig.autolevel then Autolevel() end

end
end

	KarmaConfig, menu = uiconfig.add_menu('Karma Config', 200)
    menu.keydown('QSpell', 'QSpell', Keys.Y)
	menu.keydown('Wspell', 'Wspell', Keys.X)
	menu.keydown('Espell', 'Espell', Keys.E)
	menu.checkbutton('ignite', 'Auto Ignite', true)
	menu.checkbutton('AutoRQ', 'Auto-RQ', true)
	menu.checkbutton('autoshield', 'AutoShield', true)
	menu.checkbutton('drawcircles', 'Draw Circles', true)
	menu.checkbutton('drawskillshots', 'Draw Skillshots', true)
	menu.checkbutton('dodgeskillshots', 'Dodge Skillshots', true)
	menu.checkbutton('killsteal', 'Killsteal', true)
	menu.checkbutton('killnotes', 'Killsteal notifications', true)
	menu.checkbutton('autolevel', 'Auto Level', true)
	menu.checkbutton('Val', 'Leave this off!', false)
	menu.permashow('QSpell')
	menu.permashow('Wspell')
	menu.permashow('Espell')
	
function killsteal()
	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) then
			local Qdam = getDmg("Q",enemy,myHero,1)*QRDY
			local QRdam = (getDmg("Q",enemy,myHero,1)+getDmg("Q",enemy,myHero,2))*QRDY*RRDY
			local Wdam = getDmg("W",enemy,myHero,1)*WRDY/3
			local WRdam = (getDmg("W",enemy,myHero,1)+getDmg("W",enemy,myHero,2))*WRDY*RRDY/3
			local ERdam = getDmg("E",enemy,myHero)*ERDY
			
			-- W
			if GetDistance(myHero,enemy) < 650 and enemy.health < Wdam then
				CastSpellTarget('W',enemy)
			-- Q
			elseif GetDistance(myHero,enemy) < 900 and enemy.health < Qdam and CreepBlock(GetFireahead(enemy,1.6,17,150)) == 0 then
				CastSpellXYZ('Q',GetFireahead(enemy,1.6,17))
			-- E+R
			elseif GetDistance(myHero,enemy) < 600 and enemy.health < ERdam then
				CastSpellTarget('R',enemy)
				CastSpellTarget('E',myHero)
			-- Q+W
			elseif GetDistance(myHero,enemy) < 650 and enemy.health < Qdam+Wdam and CreepBlock(GetFireahead(enemy,1.6,17,150)) == 0 then
				CastSpellTarget('W',enemy)
				CastSpellXYZ('Q',GetFireahead(enemy,1.6,17))
			-- WR
			elseif GetDistance(myHero,enemy) < 650 and enemy.health < WRdam then
				CastSpellTarget('R',enemy)
				CastSpellTarget('W',enemy)
			-- QR
				elseif GetDistance(myHero,enemy) < 900 and enemy.health < QRdam and CreepBlock(GetFireahead(enemy,1.6,17,150)) == 0 then
					CastSpellTarget('R',enemy)
					CastSpellXYZ('Q',GetFireahead(enemy,1.6,17))
			-- QR+W
			elseif GetDistance(myHero,enemy) < 650 and enemy.health < QRdam+Wdam and CreepBlock(GetFireahead(enemy,1.6,17,150)) == 0 then
				CastSpellTarget('W',enemy)
				CastSpellTarget('R',enemy)
				CastSpellXYZ('Q',GetFireahead(enemy,1.6,17))
			-- W+ER
			elseif GetDistance(myHero,enemy) < 600 and enemy.health < Wdam+ERdam then
				CastSpellTarget('W',enemy)
				CastSpellTarget('R',enemy)
				CastSpellTarget('E',myHero)
			-- Q+ER
			elseif GetDistance(myHero,enemy) < 600 and enemy.health < Qdam+ERdam and CreepBlock(GetFireahead(enemy,1.6,17,150)) == 0 then
				CastSpellTarget('R',enemy)
				CastSpellTarget('E',myHero)
				CastSpellXYZ('Q',GetFireahead(enemy,1.6,17))
			-- Q+WR
			elseif GetDistance(myHero,enemy) < 650 and enemy.health < Qdam+WRdam and CreepBlock(GetFireahead(enemy,1.6,17,150)) == 0 then
				CastSpellTarget('R',enemy)
				CastSpellTarget('W',enemy)
				CastSpellXYZ('Q',GetFireahead(enemy,1.6,17))
			-- Q+W+ER
			elseif GetDistance(myHero,enemy) < 600 and enemy.health < Qdam+Wdam+ERdam and CreepBlock(GetFireahead(enemy,1.6,17,150)) == 0 then
				CastSpellTarget('R',enemy)
				CastSpellTarget('E',myHero)
				CastSpellTarget('W',enemy)
				CastSpellXYZ('Q',GetFireahead(enemy,1.6,17))
			end
		end
	end
end

function Autolevel()
	local spellLevelSum = (GetSpellLevel(Q) + GetSpellLevel(W) + GetSpellLevel(E) + GetSpellLevel(R))-1
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
						
local spells = {
	Ahri = {
		{name= "AhriOrbofDeception", radius = 80, time = 1, isline = true},
		{name= "AhriSeduce", radius = 80, time = 1, isline = true},
	},
	Amumu = {
		{name= "BandageToss", radius = 80, time = 1, isline = true},
	},
	Anivia = {
		{name= "FlashFrostSpell", radius = 90, time = 2, isline = true},
	},
	Ashe = {
		{name= "EnchantedCrystalArrow", radius = 120, time = 4, isline = true},
	},
	Blitzcrank = {
		{name= "RocketGrabMissile", radius = 80, time = 1, isline = true},
	},
	Brand = {
		{name= "BrandBlazeMissile", radius = 70, time = 1, isline = true},
		{name= "BrandFissure", radius = 250, time = 4, isline = false},
	},
	Cassiopeia = {
		{name= "CassiopeiaMiasma", radius = 175, time = 1, isline = false},
		{name= "CassiopeiaNoxiousBlast", radius = 75, time = 1, isline = false},
	},
	Caitlyn = {
		{name= "CaitlynEntrapmentMissile", radius = 50, time = 1, isline = true},
		{name= "CaitlynPiltoverPeacemaker", radius = 80, time = 1, isline = true},
	},
	Corki = {
		{name= "MissileBarrageMissile", radius = 80, time = 1, isline = true},
		{name= "MissileBarrageMissile2", radius = 100, time = 1, isline = true},
		{name= "CarpetBomb", radius = 150, time = 1, isline = true},
	},
	Chogath = {
		{name= "Rupture", radius = 275, time = 1, isline = false},
	},
	Diana = {
		{name= "DianaArc", radius = 205, time = 1, isline = true},
	},
	DrMundo = {
		{name= "InfectedCleaverMissile", radius = 80, time = 1, isline = true},
	},
	Draven = {
		{name= "DravenDoubleShot", radius = 125, time = 1, isline = true},
		{name= "DravenRCast", radius = 100, time = 4, isline = true},
	},
	Elise = {
		{name= "EliseHumanE", radius = 100, time = 1, isline = true},
	},
	Ezreal = {
		{name= "EzrealEssenceFluxMissile", radius = 100, time = 1, isline = true},
		{name= "EzrealMysticShotMissile", radius = 80, time = 1, isline = true},
		{name= "EzrealEssenceFluxMissile", radius = 150, time = 4, isline = true},
		{name= "EzrealArcaneShift", radius = 100, time = 1, isline = true},
	},
	Fizz = {
		{name= "FizzMarinerDoom", radius = 100, time = 1.5, isline = true},
	},
	FiddleSticks = {
		{name= "Crowstorm", radius = 600, time = 1.5, isline = false},
	},
	Karthus = {
		{name= "LayWaste", radius = 150, time = 1, isline = false},
	},
	Galio = {
		{name= "GalioResoluteSmite", radius = 200, time = 1.5, isline = false},
		{name= "GalioRighteousGust", radius = 120, time = 1.5, isline = true},
	},
	Graves = {
		{name= "GravesChargeShot", radius = 110, time = 1, isline = true},
		{name= "GalioRighteousGust", radius = 50, time = 1, isline = true},
		{name= "GalioRighteousGust", radius = 275, time = 1.5, isline = false},
	},
	Gragas = {
		{name= "GragasBarrelRoll", radius = 320, time = 2.5, isline = false},
		{name= "GragasBodySlam", radius = 60, time = 1.5, isline = true},
		{name= "GragasExplosiveCask", radius = 400, time = 1.5, isline = false},
	},
	Heimerdinger = {
		{name= "CH1ConcussionGrenade", radius = 225, time = 1.5, isline = true},
	},
	Irelia = {
		{name= "IreliaTranscendentBlades", radius = 80, time = 0.8, isline = true},
	},
	Janna = {
		{name= "HowlingGale", radius = 100, time = 2, isline = true},
	},
	JarvanIV = {
		{name= "JarvanIVDemacianStandard", radius = 150, time = 2, isline = false},
		{name= "JarvanIVDragonStrike", radius = 70, time = 1, isline = true},
		{name= "JarvanIVCataclysm", radius = 300, time = 1.5, isline = false},
	},
	Kassadin = {
		{name= "RiftWalk", radius = 150, time = 1, isline = false},
	},
	Katarina = {
		{name= "ShadowStep", radius = 75, tzime = 1, isline = false},
	},
	Kennen = {
		{name= "KennenShurikenHurlMissile1", radius = 75, time = 1, isline = true},
	},
	Khazix = {
		{name= "KhazixE", radius = 200, time = 1, isline = false},
		{name= "KhazixW", radius = 120, time = 0.5, isline = true},
		{name= "khazixwlong", radius = 80, time = 1, isline = true},
		{name= "khazixelong", radius = 200, time = 1, isline = false},
	},
	KogMaw = {
		{name= "KogMawVoidOozeMissile", radius = 100, time = 1, isline = true},
		{name= "KogMawLivingArtillery", radius = 200, time = 1.5, isline = false},
	},
	Leblanc = {
		{name= "LeblancSoulShackle", radius = 80, time = 1, isline = true},
		{name= "LeblancSoulShackleM", radius = 80, time = 1, isline = true},
		{name= "LeblancSlide", radius = 250, time = 1, isline = false},
		{name= "LeblancSlideM", radius = 250, time = 1, isline = false},
		{name= "leblancslidereturn", radius = 50, time = 1, isline = false},
		{name= "leblancslidereturnm", radius = 50, time = 1, isline = false},
	},
	LeeSin = {
		{name= "BlindMonkQOne", radius = 80, time = 1, isline = true},
		{name= "BlindMonkRKick", radius = 100, time = 1.5, isline = true},
	},
	LeeSin = {
		{name= "BlindMonkQOne", radius = 80, time = 1, isline = true},
		{name= "BlindMonkRKick", radius = 100, time = 1, isline = true},
	},
	Leona = {
		{name= "LeonaZenithBladeMissile", radius = 80, time = 1, isline = true},
	},
	Lux = {
		{name= "LuxLightBinding", radius = 150, time = 1, isline = true},
		{name= "LuxLightStrikeKugel", radius = 300, time = 2.5, isline = false},
		{name= "LuxMaliceCannon", radius = 180, time = 1.5, isline = true},
	},
	Lulu = {
		{name= "LuluQ", radius = 50, time = 1, isline = true},
	},
	Maokai = {
		{name= "MaokaiTrunkLineMissile", radius = 100, time = 1, isline = true},
		{name= "MaokaiSapling2", radius = 350, time = 1, isline = false},
	},
	Malphite = {
		{name= "UFSlash", radius = 325, time = 1, isline = false},
	},
	Malzahar = {
		{name= "AlZaharCalloftheVoid", radius = 100, time = 1, isline = false},
		{name= "AlZaharNullZone", radius = 250, time = 1, isline = false},
	},
	MissFortune = {
		{name= "MissFortuneScattershot", radius = 400, time = 3, isline = false},
	},
	Morgana = {
		{name= "DarkBindingMissile", radius = 90, time = 1.5, isline = true},
		{name= "TormentedSoil", radius = 300, time = 1.5, isline = false},
	},
	Nautilus = {
		{name= "NautilusAnchorDrag", radius = 80, time = 1.5, isline = true},
	},
	Nidalee = {
		{name= "JavelinToss", radius = 80, time = 1.5, isline = true},
	},
	Nocturne = {
		{name= "NocturneDuskbringer", radius = 80, time = 1.5, isline = true},
	},
	Olaf = {
		{name= "OlafAxeThrow", radius = 100, time = 1.5, isline = true},
	},
	Orianna = {
		{name= "OrianaIzunaCommand", radius = 150, time = 1.5, isline = false},
	},
	Quinn = {
		{name= "QuinnQMissile", radius = 40, time = 1, isline = true},
	},
	Renekton = {
		{name= "RenektonSliceAndDice", radius = 80, time = 1, isline = true},
		{name= "renektondice", radius = 80, time = 1, isline = true},
	},
	Rumble = {
		{name= "RumbleGrenadeMissile", radius = 100, time = 1.5, isline = true},
		{name= "renektondice", radius = 100, time = 1.5, isline = true},
	},
	Sivir = {
		{name= "SpiralBlade", radius = 100, time = 1, isline = true},
	},
	Singed = {
		{name= "MegaAdhesive", radius = 350, time = 1.5, isline = false},
	},
	Singed = {
		{name= "ShenShadowDash", radius = 80, time = 1, isline = true},
	},
	Shaco = {
		{name= "Deceive", radius = 100, time = 3.5, isline = false},
	},
	Shyvana = {
		{name= "ShyvanaTransformLeap", radius = 80, time = 1.5, isline = true},
		{name= "ShyvanaFireballMissile", radius = 80, time = 1, isline = true},
	},
	Skarner = {
		{name= "SkarnerFracture", radius = 100, time = 1, isline = true},
	},
	Sona = {
		{name= "SonaCrescendo", radius = 150, time = 1, isline = true},
	},
	Sejuani = {
		{name= "SejuaniGlacialPrison", radius = 180, time = 1, isline = true},
	},
	Swain = {
		{name= "SwainShadowGrasp", radius = 265, time = 1.5, isline = false},
	},
	Syndra = {
		{name= "SyndraQ", radius = 200, time = 1, isline = false},
		{name= "SyndraE", radius = 100, time = 0.5, isline = true},
		{name= "syndrawcast", radius = 200, time = 1, isline = false},
	},
	Tryndamere = {
		{name= "Slash", radius = 100, time = 1, isline = true},
	},
	Tristana = {
		{name= "RocketJump", radius = 200, time = 1, isline = false},
	},
	TwistedFate = {
		{name= "WildCards", radius = 80, time = 1, isline = true},
	},
	Urgot = {
		{name= "UrgotHeatseekingLineMissile", radius = 80, time = 0.8, isline = true},
		{name= "UrgotPlasmaGrenade", radius = 300, time = 1, isline = false},
	},
	Vayne = {
		{name= "VayneTumble", radius = 100, time = 1, isline = false},
	},
	Varus = {
		{name= "VarusQ", radius = 50, time = 1, isline = true},
		{name= "VarusR", radius = 80, time = 1.5, isline = true},
	},
	Veigar = {
		{name= "VeigarDarkMatter", radius = 225, time = 2, isline = false},
	},
	Viktor = {
		{name= "ViktorDeathRay", radius = 80, time = 2, isline = true},
	},
	Xerath = {
		{name= "xeratharcanopulsedamage", radius = 80, time = 1, isline = true},
		{name= "xeratharcanopulsedamageextended", radius = 80, time = 1, isline = true},
		{name= "xeratharcanebarragewrapper", radius = 250, time = 1, isline = false},
		{name= "xeratharcanebarragewrapperext", radius = 250, time = 1, isline = false},
	},
	Zed = {
		{name= "ZedShuriken", radius = 100, time = 1, isline = true},
		{name= "ZedShadowDash", radius = 150, time = 1, isline = false},
		{name= "zedw2", radius = 150, time = 0.5, isline = false},
	},
	Ziggs = {
		{name= "ZiggsQ", radius = 160, time = 1, isline = true},
		{name= "ZiggsW", radius = 225, time = 1, isline = false},
		{name= "ZiggsE", radius = 250, time = 1, isline = false},
		{name= "ZiggsR", radius = 550, time = 3, isline = false},
	},
	Zyra = {
		{name= "ZyraQFissure", radius = 275, time = 1.5, isline = true},
		{name= "ZyraGraspingRoots", radius = 90, time = 2, isline = true},
	},
}  

local ParticleNames = {    
	{charName= "LOC_Stun.troy"},
	{charName= "LOC_Suppress.troy"},
	{charName= "LOC_Taunt.troy"},
	{charName= "CurseBandages.troy"},
	{charName= "Vi_R_land.troy.troy"},
	{charName= "JarvanCataclysm_tar.troy"},
	{charName= "RunePrison.troy"},
	{charName= "LuxLightBinding.troy"},
--	{charName= "GLOBAL_SLOW.troy"},
	{charName= "leBlanc_shackle_tar_blood.troy"},
	{charName= "DarkBinding_tar.troy"},
	{charName= "RengarEMax_tar.troy"},
	{charName= "tempkarma_spiritbindroot_tar.troy"}
}

function OnCreateObj(obj)
	if obj ~= nil and GlobalTarget ~= nil and KarmaConfig.AutoRQ then
		if (string.find(obj.charName, "LOC_Stun") or string.find(obj.charName, "LOC_Suppress") or string.find(obj.charName, "LOC_Taunt") or string.find(obj.charName, "CurseBandages") or string.find(obj.charName, "Vi_R_land") or string.find(obj.charName, "JarvanCataclysm_tar") or string.find(obj.charName, "RunePrison") or string.find(obj.charName, "LuxLightBinding") or string.find(obj.charName, "leBlanc_shackle_tar_blood") or string.find(obj.charName, "DarkBinding_tar") or string.find(obj.charName, "RengarEMax_tar") or string.find(obj.charName, "tempkarma_spiritbindroot_tar")) and GetDistance(obj,GlobalTarget) < 50 then
			if QRDY == 1 and CreepBlock(GlobalTarget.x,GlobalTarget.y,GlobalTarget.z) == 0 then
				GG = true
				timer2 = GetTickCount()
			end
		end
	end
end

function OnProcessSpell(unit,spell)
	if unit ~= nil and spell ~= nil and unit.charName == myHero.charName then
		if spell.name == "KarmaQ" then
			timer2 = 0
			GG = false
		end
	end
	if unit ~= nil and spell ~= nil and unit.team ~= myHero.team and IsHero(unit) then
		startPos = spell.startPos
		endPos = spell.endPos
		if spell.target ~= nil then
			local targetSpell = spell.target
			if target ~= nil and target.charName == targetSpell.charName then
				autoShield(target)
			end
			if myHero.charName == targetSpell.charName then
				autoShield(myHero)
			end			
		end
		if target ~= nil then
			local shot = SpellShotTarget(unit, spell, target)
			if shot ~= nil then
				spellShot = shot
				if spellShot.shot then
					autoShield(target)	
				end
			end
		end
		local shot = SpellShotTarget(unit, spell, myHero)
		if shot ~= nil then
			spellShot = shot
			if spellShot.shot then
				shotMe = true
				autoShield(myHero)	
			end
		end
	end
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

function autoShield(target)
	if KarmaConfig.autoshield and ERDY == 1 then
		CastSpellTarget("E",target)
	end
end

function ignite()
	local damage = (myHero.selflevel*20)+50
	if targetignite ~= nil then
		if myHero.SummonerD == 'SummonerDot' then
			if targetignite.health < damage then
				CastSpellTarget('D',targetignite)
			end
		end
		if myHero.SummonerF == 'SummonerDot' then
			if targetignite.health < damage then
				CastSpellTarget('F',targetignite)
			end
		end
	end
end

function GetWeakAlly()
	local maxHealth = 9999
	target = nilz
	for i=1, objManager:GetMaxHeroes(), 1 do
	local object = objManager:GetHero(i)
		if KarmaConfig.Val == true then
			if object ~= nil and object.team == myHero.team and GetDistance(object) < 800 and object.charName ~= myHero.charName and (object.SummonerD == 'SummonerRevive' or object.SummonerF == 'SummonerRevive') and object.name ~= "Kassadin"  and object.name ~= "Teemo" and object.name ~= "Nidalee"  and object.name ~= "Khazix" then
				if object.health < maxHealth then
					maxHealth = object.health
					target = object;
				end
			end
		elseif KarmaConfig.Val == false then
			if object ~= nil and object.team == myHero.team and GetDistance(object) < 800 and object.charName ~= myHero.charName then
				if object.health < maxHealth then
					maxHealth = object.health
					target = object;
				end
			end
		end
	end
end

function GetWeakOpponent()
	GlobalTarget = nil
	for i=1, objManager:GetMaxHeroes(), 1 do
		local object = objManager:GetHero(i)
		if object ~= nil and object.team ~= myHero.team and GetDistance(object) < 950 and object.visible == 1 and object.invulnerable==0 then
			GlobalTarget = object;
		end
	end
end
	
function IsHero(unit)
  for i=1, objManager:GetMaxHeroes(), 1 do
		local object = objManager:GetHero(i)
		if object ~= nil and object.charName == unit.charName then
			return true
		end
	end
	return false
end

function Cooldown_Handling()
	if myHero.SpellTimeQ > 1.0 and myHero.mana >= (45+(myHero.SpellLevelQ*5)) then
	QRDY = 1
	else QRDY = 0
	end
	if myHero.SpellTimeW > 1.0 and myHero.mana >= (65+(myHero.SpellLevelW*5)) then
	WRDY = 1
	else WRDY = 0
	end
	if myHero.SpellTimeE > 1.0 and myHero.mana >= (50+(myHero.SpellLevelE*10)) then
	ERDY = 1
	else ERDY = 0
	end
	if myHero.SpellTimeR > 1.0 then
	RRDY = 1
	else RRDY = 0
	end
end

function GetAngle(p1, p2) 
	local a = p1.x - p2.x
	local b = p1.z - p2.z
  local angle = math.atan(a/b)
  if b < 0 then
   	angle = angle+math.pi
  end  			
  return angle
end

function GetLinePoint(pos,angle,distance)
	local ret = {x = 0, y = 0, z = 0}
	ret.x = pos.x - distance*math.sin(angle)
	ret.z = pos.z - distance*math.cos(angle)
	return ret
end

function GetSpellShot(name,spellName)
	local spellTable = spells[name]
	if spellTable ~= nil then
		for i=1, #spellTable, 1 do	
			if spellName == spellTable[i].name then
				local ret = spellTable[i]
				return ret
			end
		end
	end
	return nil
end

function SpellShotTarget(unit,spell,target)
	if unit ~= nil and unit.team ~= target.team and spell ~= nil then
		local spellShot = GetSpellShot(unit.name, spell.name)
		if spellShot ~= nil then
			if spellShot.isline then
				local angle = GetAngle(spell.startPos, spell.endPos)
				local d1 = GetDistance(spell.startPos, spell.endPos)
				local d2 = GetDistance(spell.startPos, target)
				if d2 < d1 + spellShot.radius then
					local point = GetLinePoint(spell.startPos, angle, d2)
					local d3 = GetDistance(target, point)
					if d3 <= spellShot.radius then
						local angle = GetAngle(point, target)
						local safePoint = GetLinePoint(point, angle, spellShot.radius*1.2)
						if IsWall(safePoint.x, safePoint.y, safePoint.z) == 1 then
							angle = GetAngle(safePoint, point)
							safePoint = GetLinePoint(safePoint, angle, spellShot.radius*1.2*2)
							if IsWall(safePoint.x, safePoint.y, safePoint.z) == 1 then
								return nil
							end
						end
						local ret = {shot = false, radius = 0, time = 0, shotX = 0, shotZ = 0, shotY = 0, safeX = 0, safeY = 0, safeZ = 0, isline = false}
						ret.shot = true
						ret.radius = spellShot.radius
						ret.time = GetClock()+spellShot.time*1000
						ret.shotX = point.x
						ret.shotY = point.y
						ret.shotZ = point.z
						ret.safeX = safePoint.x
						ret.safeY = safePoint.y
						ret.safeZ = safePoint.z
						ret.isline = true
						return ret
					end
				end
			else
				local d1 = GetDistance(target, spell.endPos)
				if d1 <= spellShot.radius then
					local angle = GetAngle(spell.startPos, spell.endPos)
					local d2 = GetDistance(spell.startPos, target)
					local point = GetLinePoint(spell.startPos, angle, d2)
					angle = GetAngle(point, target)
					local safePoint = GetLinePoint(point, angle, spellShot.radius*1.2)
					if IsWall(safePoint.x, safePoint.y, safePoint.z) == 1 then
						return nil
					end
					local ret = {shot = false, radius = 0, time = 0, shotX = 0, shotZ = 0, shotY = 0, safeX = 0, safeY = 0, safeZ = 0, isline = false}
					ret.shot = true
					ret.radius = spellShot.radius
					ret.time = GetClock()+spellShot.time*1000
					ret.shotX = spell.endPos.x
					ret.shotY = spell.endPos.y
					ret.shotZ = spell.endPos.z
					ret.safeX = safePoint.x
					ret.safeY = safePoint.y
					ret.safeZ = safePoint.z
					ret.isline = false
					return ret
				end
			end
		end
	end
	return nil
end

function CreateBlockAndMoveToXYZ(x, y, z)
    print('CreateBlockAndMoveToXYZ', x, y, z)
    local move_start_time, move_dest, move_pending
    send.block_input(true,500,MakeStateMatch)
    move_start_time = os.clock()
    move_dest = {x=x, y=y, z=z}
    move_pending = true
    MoveToXYZ(move_dest.x, 0, move_dest.z)
    run_once = false
    return function()
        if move_pending then
            printtext('.')
            local waited_too_long = move_start_time + 1 < os.clock()    
            if waited_too_long or GetDistance(move_dest)<75 then
                print('\nremaining distance: '..tostring(GetDistance(move_dest)))
                move_pending = false
                send.block_input(false)
            end
        else
            printtext(' ')
        end
    end
end


function MakeStateMatch(changes)
	for scode,flag in pairs(changes) do    
		print(scode)
		if flag then print('went down') else print('went up') end
			local vk = winapi.map_virtual_key(scode, 3)
			local is_down = winapi.get_async_key_state(vk)
			if flag then -- went down
				if is_down then
					send.wait(60)
					send.key_down(scode)
					send.wait(60)
				else
				end            
			else
			if is_down then
			else
				send.wait(60)
				send.key_up(scode)
				send.wait(60)
			end
		end
	end
end

function OnDraw()
	if KarmaConfig.drawcircles then
		if QRDY == 1 then
			CustomCircle(900,1,2,myHero)
		end
		if myHero.SpellTimeW > 1.0 then
			CustomCircle(650,1,3,myHero)
		elseif myHero.SpellTimeW > ((((16-myHero.SpellLevelW)-(((16-myHero.SpellLevelW)*myHero.cdr)/100))*-1)+2) then
			CustomCircle(800,1,5,myHero)
		end
		if target3 ~= nil then
			CustomCircle(100,10,2,target3)
		end
		if target ~= nil then
			CustomCircle(75,5,5,target)
		end
	end
	cc=cc+1
	if (cc==30) then
		LoadTable()
	end
	if KarmaConfig.drawskillshots == true then
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
			end
	for i=1, #skillshotArray, 1 do
		if os.clock() > (skillshotArray[i].lastshot + skillshotArray[i].time) then
		skillshotArray[i].shot = 0
		end
	end
	if KarmaConfig.killnotes then
		for i = 1, objManager:GetMaxHeroes() do
			local enemy = objManager:GetHero(i)
			if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) then
				local Q = getDmg("Q",enemy,myHero,1)*QRDY
				local QR = (getDmg("Q",enemy,myHero,1)+getDmg("Q",enemy,myHero,2))*QRDY*RRDY
				local W = getDmg("W",enemy,myHero,1)*WRDY/3
				local WR = (getDmg("W",enemy,myHero,1)+getDmg("W",enemy,myHero,2))*WRDY*RRDY/3
				local ER = getDmg("E",enemy,myHero)*ERDY
				if enemy.health < W then
					DrawTextObject("KILL W", enemy, Color.Red)
				elseif enemy.health < Q then
					DrawTextObject("KILL Q", enemy, Color.Red)
				elseif enemy.health < ER then
					DrawTextObject("KILL ER", enemy, Color.Red)
				elseif enemy.health < Q+W then
					DrawTextObject("KILL Q+W", enemy, Color.Red)
				elseif enemy.health < WR then
					DrawTextObject("KILL WR", enemy, Color.Red)
				elseif enemy.health < QR then
					DrawTextObject("KILL QR", enemy, Color.Red)
				elseif enemy.health < QR+W then
					DrawTextObject("KILL QR+W", enemy, Color.Red)
				elseif enemy.health < W+ER then
					DrawTextObject("KILL W+ER", enemy, Color.Red)
				elseif enemy.health < Q+ER then
					DrawTextObject("KILL Q+ER", enemy, Color.Red)
				elseif enemy.health < Q+WR  then
					DrawTextObject("KILL Q+WR", enemy, Color.Red)
				elseif enemy.health < Q+W+ER then
					DrawTextObject("KILL Q+W+ER", enemy, Color.Red)
				end
			end
		end
	end
end

function dodgeaoe(pos1, pos2, radius)
	local calc = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
	local dodgex
	local dodgez
	dodgex = pos2.x + ((radius+100)/calc)*(myHero.x-pos2.x)
	dodgez = pos2.z + ((radius+100)/calc)*(myHero.z-pos2.z)
	if calc < radius and GetCursorX() > xa and GetCursorX() < xb and GetCursorY() > ya and GetCursorY() < yb then
        print("dodgeaoe disabled")
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
	dodgex = x4 + ((radius+100)/calc3)*(myHero.x-x4)
	dodgez = z4 + ((radius+100)/calc3)*(myHero.z-z4)
	if perpendicular < radius and calc1 < calc4 and calc2 < calc4 and GetCursorX() > xa and GetCursorX() < xb and GetCursorY() > ya and GetCursorY() < yb and KarmaConfig.dodgeskillshots == true and not KarmaConfig.QSpell and not KarmaConfig.Wspell and not KarmaConfig.Espell then
		blockAndMove = CreateBlockAndMoveToXYZ(dodgex,0,dodgez)
	end
end

function dodgelinepass(pos1, pos2, radius, maxDist)
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
	dodgex = x4 + ((radius+100)/calc3)*(myHero.x-x4)
	dodgez = z4 + ((radius+100)/calc3)*(myHero.z-z4)
	if perpendicular < radius and calc1 < calc4 and calc2 < calc4 and GetCursorX() > xa and GetCursorX() < xb and GetCursorY() > ya and GetCursorY() < yb and KarmaConfig.dodgeskillshots == true and not KarmaConfig.QSpell and not KarmaConfig.Wspell and not KarmaConfig.Espell then
		blockAndMove = CreateBlockAndMoveToXYZ(dodgex,0,dodgez)
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
		if 1==1 or skillshotplayerObj.name == "Karma" then
			table.insert(skillshotArray,{name= "KarmaQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 1, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
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
							
SetTimerCallback("Karma")
print("\nVal's Karma v"..version.."\n")