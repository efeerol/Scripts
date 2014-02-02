require 'Utils'
require 'spell_damage'
require 'spell_shot'
require 'winapi'
require 'SKeys'
require 'vals_lib'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local Q,W,E,R = 'Q','W','E','R'
local targetq
local t0_attacking = 0
local shotMe = false
local minion
local target
local target2
local targetHero
local startAttackSpeed
local projSpeed = 1
local MinionInfo = { }
local Minions = { }
local aaDelay = 0
local aaPos = {x = 0, z = 0}
local Ping = 0
local IncomingDamage = { }
local AnimationBeginTimer = 0
local AnimationSpeedTimer = 0.1 * (1 / myHero.attackspeed)
local TimeToAA = os.clock()
local lastAttack = GetTickCount()
local shotFired = false
local range = myHero.range + GetDistance(GetMinBBox(myHero))
local attackDelayOffset = 275
local isMoving = false
local startAttackSpeed = 0.625 
local targetIgnite
local timer = os.time()
local skillslot = nil
local True_Attack_Damage_Against_Minions = 0
local Range = myHero.range + GetDistance(GetMinBBox(myHero))
local SORT_CUSTOM = function(a, b) return a.maxHealth and b.maxHealth and a.maxHealth < b.maxHealth end
local Target, M_Target
local show_allies=0
local spellShot = {shot = false, radius = 0, time = 0, shotX = 0, shotZ = 0, shotY = 0, safeX = 0, safeY = 0, safeZ = 0, isline = false}
local startPos = {x=0, y=0, z=0}
local endPos = {x=0, y=0, z=0}
local shotMe = false

        sivir, menu = uiconfig.add_menu('Insane Sivir', 200)
		
        menu.checkbutton('Autoq', 'AutoQ', true)      
        menu.checkbutton('Autow', 'AutoW' , true)
		menu.checkbutton('AutoShield', 'AutoShield', true)
        menu.checkbutton('ignite', 'Auto-ignite',false)
		menu.checkbutton('Barrier', 'Auto-Barrier',true)
        menu.checkbutton('shielditems', 'shielditems', true)
		
		menu.permashow('Autoq')
		menu.permashow('Barrier')
		menu.permashow('ignite')
		
function SivirRun()
targetq = GetWeakEnemy('PHYS',1075)
targetignite = GetWeakEnemy('TRUE',600)
		GetWeakAlly()
		ResetTimer()
		GetCD()
local maxHealth = 9999
		Util__OnTick()
        if sivir.Autoq then Q() end
		if sivir.Autow then W() end
		if sivir.shielditems then shielditems()  end
        if sivir.ignite then ignite() end
end
function Q()
if targetq ~= nil then
CastHotkey("Q AUTO 100,0 SPELLQ:WEAKENEMY RANGE=1075 FIREAHEAD=2,13 CD=1 MAXDIST SAVECURSOR=50")
end
end
function W()
	AArange = (myHero.range+(GetDistance(GetMinBBox(myHero))))
	targetaa = GetWeakEnemy('PHYS',AArange)
	GetCD()
	if GetAA() and WRDY==1 then CastSpellTarget('W',myHero) end
	if targetaa~=nil then CastSpellTarget('W',targetaa) end
end

function GetWeakAlly()
	local maxHealth = 9999
	target = nil
	for i=1, objManager:GetMaxHeroes(), 1 do
		local object = objManager:GetHero(i)
		if object ~= nil and object.team == myHero.team and GetDistance(object) < 800 and object.charName ~= myHero.charName then
			if object.health < maxHealth then
				maxHealth = object.health
				target = object
			end
		end
	end
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
		{name= "ShadowStep", radius = 75, time = 1, isline = false},
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
		--{name= "VarusQ", radius = 50, time = 1, isline = true},
		{name= "VarusR", radius = 80, time = 1.5, isline = true},
	},
	Veigar = {
		{name= "VeigarDarkMatter", radius = 225, time = 2, isline = false},
	},
	Viktor = {
		--{name= "ViktorDeathRay", radius = 80, time = 2, isline = true},
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

function OnProcessSpell(unit,spell)
	if unit ~= nil and spell ~= nil and unit.team ~= myHero.team and IsHero(unit) then
		startPos = spell.startPos
		endPos = spell.endPos
		if spell.target ~= nil then
			local targetSpell = spell.target
			if myHero.charName == targetSpell.charName then
				target2 = unit
				autoShield(myHero)
			end			
		end
		local shot = SpellShotTarget(unit, spell, myHero)
		if shot ~= nil then
			spellShot = shot
			if spellShot.shot then
				shotMe = true
				target2 = unit
				autoShield(myHero)	
			end
		end
	end
	if unit ~= nil and spell ~= nil and unit.team ~= myHero.team then
		if 	(unit.name == 'Akali' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'Akali' and spell.name ==  unit.SpellNameR) or
			(unit.name == 'Alistar' and spell.name ==  unit.SpellNameW) or
			(unit.name == 'Anivia' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'Annie' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'Brand' and spell.name ==  unit.SpellNameW) or
			(unit.name == 'Brand' and spell.name ==  unit.SpellNameR) or
			(unit.name == 'Caitlyn' and spell.name ==  unit.SpellNameR) or
			(unit.name == 'Cassiopeia' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'Chogath' and spell.name ==  unit.SpellNameR) or
			(unit.name == 'Darius' and spell.name ==  unit.SpellNameR) or
			(unit.name == 'Diana' and spell.name ==  unit.SpellNameR) or
			(unit.name == 'Elise' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'Evelynn' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'Evelynn' and spell.name ==  unit.SpellNameW) or
			(unit.name == 'FiddleSticks' and spell.name ==  unit.SpellNameW) or
			(unit.name == 'FiddleSticks' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'Fiora' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'Fiora' and spell.name ==  unit.SpellNameR) or
			(unit.name == 'Gangplank' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'Garen' and spell.name ==  unit.SpellNameR) or
			(unit.name == 'Irelia' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'Irelia' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'Janna' and spell.name ==  unit.SpellNameW) or
			(unit.name == 'Jarvan' and spell.name ==  unit.SpellNameR) or
			(unit.name == 'Jax' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'Karma' and spell.name ==  unit.SpellNameW) or
			(unit.name == 'Kassadin' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'Katarina' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'Katarina' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'Kayle' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'Khazix' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'Kogmaw' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'Leblanc' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'LeeSin' and spell.name ==  unit.SpellNameR) or
			(unit.name == 'Lulu' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'Malphite' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'Malzahar' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'Malzahar' and spell.name ==  unit.SpellNameR) or
			(unit.name == 'Maokai' and spell.name ==  unit.SpellNameW) or
			(unit.name == 'MasterYi' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'MissFortune' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'Mordekaiser' and spell.name ==  unit.SpellNameR) or
			(unit.name == 'Nami' and spell.name ==  unit.SpellNameW) or
			(unit.name == 'Nautilus' and spell.name ==  unit.SpellNameR) or
			(unit.name == 'Nocturne' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'Nocturne' and spell.name ==  unit.SpellNameR) or
			(unit.name == 'Nunu' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'Olaf' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'Pantheon' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'Pantheon' and spell.name ==  unit.SpellNameW) or
			(unit.name == 'Poppy' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'Rammus' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'Rengar' and spell.name ==  unit.SpellNameW) or
			(unit.name == 'Ryze' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'Ryze' and spell.name ==  unit.SpellNameW) or
			(unit.name == 'Ryze' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'Shaco' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'Shen' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'Singed' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'Sion' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'Skarner' and spell.name ==  unit.SpellNameR) or
			(unit.name == 'Soraka' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'Swain' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'Syndra' and spell.name ==  unit.SpellNameR) or
			(unit.name == 'Talon' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'Taric' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'Teemo' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'Tristana' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'Tristana' and spell.name ==  unit.SpellNameR) or
			(unit.name == 'Trundle' and spell.name ==  unit.SpellNameR) or
			(unit.name == 'Vayne' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'Veigar' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'Veigar' and spell.name ==  unit.SpellNameR) or
			(unit.name == 'Vi' and spell.name ==  unit.SpellNameR) or
			(unit.name == 'Victor' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'Vladimir' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'Volibaer' and spell.name ==  unit.SpellNameW) or
			(unit.name == 'Warwick' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'Warwick' and spell.name ==  unit.SpellNameR) or
			(unit.name == 'MonkeyKing' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'Xerath' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'XinZhao' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'Yasuo' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'Yasuo' and spell.name ==  unit.SpellNameR) or
			(unit.name == 'Yorick' and spell.name ==  unit.SpellNameE) or
			(unit.name == 'Zed' and spell.name ==  unit.SpellNameR) or
			(unit.name == 'Zilean' and spell.name ==  unit.SpellNameQ) or
			(unit.name == 'Jayce' and spell.name == 'JayceToTheSkies') or 
			(unit.name == 'Jayce' and spell.name == 'JayceThunderingBlow') or 
			(unit.name == 'Leblanc' and spell.name == 'LeblancChaosOrbM') or 
			(unit.name == 'LeeSin' and spell.name == 'blindmonkqtwo') then
			if spell.target~=nil and spell.target.name == myHero.name then
				autoShield(myHero)
			end
		end
	end
end

function ResetTimer()
	if GetTickCount() - spellShot.time > 0 then
		spellShot.shot = false
		spellShot.time = 0
		shotMe = false
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

function autoShield(target)
	if sivir.AutoShield and ERDY==1 then
		CastSpellTarget("E",target)
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

function barrier()
		if myHero.SummonerD == 'SummonerBarrier' then
			if myHero.health < myHero.maxHealth*.23 then
				CastSpellTarget('D',myHero)
			end
		end
		if myHero.SummonerF == 'SummonerBarrier' then
			if myHero.health < myHero.maxHealth*.23 then
				CastSpellTarget('F',myHero)
			end
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
function SummonerBarrier()
		if myHero.SummonerD == 'SummonerBarrier' then
			if myHero.health < myHero.maxHealth*.25 then
				CastSpellTarget('D',myHero)
			end
		end
		if myHero.SummonerF == 'SummonerBarrier' then
			if myHero.health < myHero.maxHealth*.25 then
				CastSpellTarget('F',myHero)
			end
		end
end
function shielditems()
if myHero.health < myHero.maxHealth*(15 / 100) then
        GetInventorySlot(3157)
        UseItemOnTarget(3157,myHero)
        GetInventorySlot(3040)
        UseItemOnTarget(3040,myHero)   
end
end
function Zhonyas()
        GetInventorySlot(3157)
        UseItemOnTarget(3157,myHero)
end
 
function SeraphsEmbrace()
        GetInventorySlot(3040)
        UseItemOnTarget(3040,myHero)
        end
 
function OnProcessSpell(unit, spell)
        if unit ~= nil and GetDistance(myHero, unit) < 1000 then
                for i, Minion in pairs(Minions) do
                        if Minion ~= nil then
                                if MinionInfo[unit.charName] ~= nil then
                                        local m_aaDelay = MinionInfo[unit.charName].aaDelay
                                        local m_projSpeed = MinionInfo[unit.charName].projSpeed
                                       
                                        if spell.target == Minion then
                                                IncomingDamage[unit.name] = { Source = unit, Target = Minion, Damage = getDmg("AD", Minion, unit), Start = GetTickCount(), aaPos = { x = unit.x, z = unit.z }, aaDelay = m_aaDelay, projSpeed = m_projSpeed }
                                        end
                                end
                        end
                end
        end
        if unit.charName == myHero.charName then
                for i, aaSpellName in pairs(GetAAData()[myHero.name].aaSpellName) do
                        if spell.name == aaSpellName then
                                AnimationBeginTimer = os.clock()
                                TimeToAA = os.clock() + (1 / myHero.attackspeed) - 0.35 * (1 / myHero.attackspeed)
                        end
                end
        end
end
 
function GetAAData()
    return {  
        Ahri         = { projSpeed = 1.6, aaParticles = {"Ahri_BasicAttack_mis", "Ahri_BasicAttack_tar"}, aaSpellName = {"ahribasicattack"}, startAttackSpeed = "0.668",  },
        Anivia       = { projSpeed = 1.05, aaParticles = {"cryo_BasicAttack_mis", "cryo_BasicAttack_tar"}, aaSpellName = {"aniviabasicattack"}, startAttackSpeed = "0.625",  },
        Annie        = { projSpeed = 1.0, aaParticles = {"AnnieBasicAttack_tar", "AnnieBasicAttack_tar_frost", "AnnieBasicAttack2_mis", "AnnieBasicAttack3_mis"}, aaSpellName = {"anniebasicattack"}, startAttackSpeed = "0.579",  },
        Ashe         = { projSpeed = 2.0, aaParticles = {"bowmaster"}, aaSpellName = {"attack"}, startAttackSpeed = "0.658" },
        Brand        = { projSpeed = 1.975, aaParticles = {"BrandBasicAttack_cas", "BrandBasicAttack_Frost_tar", "BrandBasicAttack_mis", "BrandBasicAttack_tar", "BrandCritAttack_mis", "BrandCritAttack_tar", "BrandCritAttack_tar"}, aaSpellName = {"brandbasicattack"}, startAttackSpeed = "0.625" },
        Caitlyn      = { projSpeed = 2.5, aaParticles = {"caitlyn_basicAttack_cas", "caitlyn_headshot_tar", "caitlyn_mis_04"}, aaSpellName = {"caitlynbasicattack"}, startAttackSpeed = "0.668" },
        Cassiopeia   = { projSpeed = 1.22, aaParticles = {"CassBasicAttack_mis"}, aaSpellName = {"cassiopeiabasicattack"}, startAttackSpeed = "0.644" },
        Corki        = { projSpeed = 2.0, aaParticles = {"corki_basicAttack_mis", "Corki_crit_mis"}, aaSpellName = {"CorkiBasicAttack"}, startAttackSpeed = "0.658" },
        Draven       = { projSpeed = 1.4, aaParticles = {"Draven_BasicAttack_mis","Draven_Q_mis", "Draven_Q_mis_bloodless", "Draven_Q_mis_shadow", "Draven_Q_mis_shadow_bloodless", "Draven_Qcrit_mis", "Draven_Qcrit_mis_bloodless", "Draven_Qcrit_mis_shadow", "Draven_Qcrit_mis_shadow_bloodless", "Draven_BasicAttack_mis_shadow", "Draven_BasicAttack_mis_shadow_bloodless", "Draven_BasicAttack_mis_bloodless", "Draven_crit_mis", "Draven_crit_mis_shadow_bloodless", "Draven_crit_mis_bloodless", "Draven_crit_mis_shadow", "Draven_Q_mis", "Draven_Qcrit_mis"}, aaSpellName = {"dravenbasicattack"}, startAttackSpeed = "0.679",  },
        Ezreal       = { projSpeed = 2.0, aaParticles = {"Ezreal_basicattack_mis", "Ezreal_critattack_mis"}, aaSpellName = {"ezrealbasicattack"}, startAttackSpeed = "0.625" },
        FiddleSticks = { projSpeed = 1.75, aaParticles = {"FiddleSticks_cas", "FiddleSticks_mis", "FiddleSticksBasicAttack_tar"}, aaSpellName = {"fiddlesticksbasicattack"}, startAttackSpeed = "0.625" },
        Graves       = { projSpeed = 3.0, aaParticles = {"Graves_BasicAttack_mis",}, aaSpellName = {"gravesbasicattack"}, startAttackSpeed = "0.625" },
        Heimerdinger = { projSpeed = 1.4, aaParticles = {"heimerdinger_basicAttack_mis", "heimerdinger_basicAttack_tar"}, aaSpellName = {"heimerdingerbasicAttack"}, startAttackSpeed = "0.625" },
        Janna        = { projSpeed = 1.2, aaParticles = {"JannaBasicAttack_mis", "JannaBasicAttack_tar", "JannaBasicAttackFrost_tar"}, aaSpellName = {"jannabasicattack"}, startAttackSpeed = "0.625" },
        Jayce        = { projSpeed = 2.2, aaParticles = {"Jayce_Range_Basic_mis", "Jayce_Range_Basic_Crit"}, aaSpellName = {"jaycebasicattack"}, startAttackSpeed = "0.658",  },
        Karma        = { projSpeed = nil, aaParticles = {"karma_basicAttack_cas", "karma_basicAttack_mis", "karma_crit_mis"}, aaSpellName = {"karmabasicattack"}, startAttackSpeed = "0.658",  },
        Karthus      = { projSpeed = 1.25, aaParticles = {"LichBasicAttack_cas", "LichBasicAttack_glow", "LichBasicAttack_mis", "LichBasicAttack_tar"}, aaSpellName = {"karthusbasicattack"}, startAttackSpeed = "0.625" },
        Kayle        = { projSpeed = 1.8, aaParticles = {"RighteousFury_nova"}, aaSpellName = {"KayleBasicAttack"}, startAttackSpeed = "0.638",  }, -- Kayle doesn't have a particle when auto attacking without E buff..
        Kennen       = { projSpeed = 1.35, aaParticles = {"KennenBasicAttack_mis"}, aaSpellName = {"kennenbasicattack"}, startAttackSpeed = "0.690" },
        KogMaw       = { projSpeed = 1.8, aaParticles = {"KogMawBasicAttack_mis", "KogMawBioArcaneBarrage_mis"}, aaSpellName = {"kogmawbasicattack"}, startAttackSpeed = "0.665", },
        Leblanc      = { projSpeed = 1.7, aaParticles = {"leBlanc_basicAttack_cas", "leBlancBasicAttack_mis"}, aaSpellName = {"leblancbasicattack"}, startAttackSpeed = "0.625" },
        Lulu         = { projSpeed = 2.5, aaParticles = {"lulu_attack_cas", "LuluBasicAttack", "LuluBasicAttack_tar"}, aaSpellName = {"LuluBasicAttack"}, startAttackSpeed = "0.625" },
        Lux          = { projSpeed = 1.55, aaParticles = {"LuxBasicAttack_mis", "LuxBasicAttack_tar", "LuxBasicAttack01"}, aaSpellName = {"luxbasicattack"}, startAttackSpeed = "0.625" },
        Malzahar     = { projSpeed = 1.5, aaParticles = {"AlzaharBasicAttack_cas", "AlZaharBasicAttack_mis"}, aaSpellName = {"malzaharbasicattack"}, startAttackSpeed = "0.625" },
        MissFortune  = { projSpeed = 2.0, aaParticles = {"missFortune_basicAttack_mis", "missFortune_crit_mis"}, aaSpellName = {"missfortunebasicattack"}, startAttackSpeed = "0.656" },
        Morgana      = { projSpeed = 1.6, aaParticles = {"FallenAngelBasicAttack_mis", "FallenAngelBasicAttack_tar", "FallenAngelBasicAttack2_mis"}, aaSpellName = {"Morganabasicattack"}, startAttackSpeed = "0.579" },
        Nidalee      = { projSpeed = 1.7, aaParticles = {"nidalee_javelin_mis"}, aaSpellName = {"nidaleebasicattack"}, startAttackSpeed = "0.670" },
        Orianna      = { projSpeed = 1.4, aaParticles = {"OrianaBasicAttack_mis", "OrianaBasicAttack_tar"}, aaSpellName = {"oriannabasicattack"}, startAttackSpeed = "0.658" },
        Quinn        = { projSpeed = 1.85, aaParticles = {"Quinn_basicattack_mis", "QuinnValor_BasicAttack_01", "QuinnValor_BasicAttack_02", "QuinnValor_BasicAttack_03", "Quinn_W_mis"}, aaSpellName = {"QuinnBasicAttack"}, startAttackSpeed = "0.668" },  --Quinn's critical attack has the same particle name as his basic attack.
        Ryze         = { projSpeed = 2.4, aaParticles = {"ManaLeach_mis"}, aaSpellName = {"RyzeBasicAttack"}, startAttackSpeed = "0.625" },
        Sivir        = { projSpeed = 1.4, aaParticles = {"sivirbasicattack_mis", "sivirbasicattack2_mis", "SivirRicochetAttack_mis"}, aaSpellName = {"sivirbasicattack"}, startAttackSpeed = "0.658" },
        Sona         = { projSpeed = 1.6, aaParticles = {"SonaBasicAttack_mis", "SonaBasicAttack_tar", "SonaCritAttack_mis", "SonaPowerChord_AriaofPerseverance_mis", "SonaPowerChord_AriaofPerseverance_tar", "SonaPowerChord_HymnofValor_mis", "SonaPowerChord_HymnofValor_tar", "SonaPowerChord_SongOfSelerity_mis", "SonaPowerChord_SongOfSelerity_tar", "SonaPowerChord_mis", "SonaPowerChord_tar"}, aaSpellName = {"sonabasicattack"}, startAttackSpeed = "0.644" },
        Soraka       = { projSpeed = 1.0, aaParticles = {"SorakaBasicAttack_mis", "SorakaBasicAttack_tar"}, aaSpellName = {"sorakabasicattack"}, startAttackSpeed = "0.625" },
        Swain        = { projSpeed = 1.6, aaParticles = {"swain_basicAttack_bird_cas", "swain_basicAttack_cas", "swainBasicAttack_mis"}, aaSpellName = {"swainbasicattack"}, startAttackSpeed = "0.625" },
        Syndra       = { projSpeed = 1.2, aaParticles = {"Syndra_attack_hit", "Syndra_attack_mis"}, aaSpellName = {"sorakabasicattack"}, startAttackSpeed = "0.625",  },
        Teemo        = { projSpeed = 1.3, aaParticles = {"TeemoBasicAttack_mis", "Toxicshot_mis"}, aaSpellName = {"teemobasicattack"}, startAttackSpeed = "0.690" },
        Tristana     = { projSpeed = 2.25, aaParticles = {"TristannaBasicAttack_mis"}, aaSpellName = {"tristanabasicattack"}, startAttackSpeed = "0.656",  },
        TwistedFate  = { projSpeed = 1.5, aaParticles = {"TwistedFateBasicAttack_mis", "TwistedFateStackAttack_mis"}, aaSpellName = {"twistedfatebasicattack"}, startAttackSpeed = "0.651",  },
        Twitch       = { projSpeed = 2.5, aaParticles = {"twitch_basicAttack_mis",--[[ "twitch_punk_sprayandPray_tar", "twitch_sprayandPray_tar",]] "twitch_sprayandPray_mis"}, aaSpellName = {"twitchbasicattack"}, startAttackSpeed = "0.679" },
        Urgot        = { projSpeed = 1.3, aaParticles = {"UrgotBasicAttack_mis"}, aaSpellName = {"urgotbasicattack"}, startAttackSpeed = "0.644" },
        Vayne        = { projSpeed = 2.0, aaParticles = {"vayne_basicAttack_mis", "vayne_critAttack_mis", "vayne_ult_mis" }, aaSpellName = {"vaynebasicattack"}, startAttackSpeed = "0.658",  },
        Varus        = { projSpeed = 2.0, aaParticles = {"Attack"}, aaSpellName = "basic", startAttackSpeed = "0.658",  },
        Veigar       = { projSpeed = 1.05, aaParticles = {"ahri_basicattack_mis"}, aaSpellName = {"veigarbasicattack"}, startAttackSpeed = "0.625" },
        Viktor       = { projSpeed = 2.25, aaParticles = {"ViktorBasicAttack_cas", "ViktorBasicAttack_mis", "ViktorBasicAttack_tar"}, aaSpellName = {"viktorbasicattack"}, startAttackSpeed = "0.625" },
        Vladimir     = { projSpeed = 1.4, aaParticles = {"VladBasicAttack_mis", "VladBasicAttack_mis_bloodless", "VladBasicAttack_tar", "VladBasicAttack_tar_bloodless"}, aaSpellName = {"vladimirbasicattack"}, startAttackSpeed = "0.658" },
        Xerath       = { projSpeed = 1.2, aaParticles = {"XerathBasicAttack_mis", "XerathBasicAttack_tar"}, aaSpellName = {"xerathbasicattack"}, startAttackSpeed = "0.625" },
        Ziggs        = { projSpeed = 1.5, aaParticles = {"ZiggsBasicAttack_mis", "ZiggsPassive_mis"}, aaSpellName = {"ziggsbasicattack"}, startAttackSpeed = "0.656" },
        Zilean       = { projSpeed = 1.25, aaParticles = {"ChronoBasicAttack_mis"}, aaSpellName = {"zileanbasicattack" },
        Zyra         = { projSpeed = 1.7, aaParticles = {"Zyra_basicAttack_cas", "Zyra_basicAttack_cas_02", "Zyra_basicAttack_mis", "Zyra_basicAttack_tar", "Zyra_basicAttack_tar_hellvine"}, aaSpellName = {"zileanbasicattack"}, startAttackSpeed = "0.625",  },
    }}
end

SetTimerCallback('SivirRun')