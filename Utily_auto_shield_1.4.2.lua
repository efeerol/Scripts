require 'Utils'
require 'winapi'
require 'SKeys'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local version = '1.4.2'
local Q,W,E,R = 'Q','W','E','R'
local target
local spellShot = {shot = false, radius = 0, time = 0, shotX = 0, shotZ = 0, shotY = 0, safeX = 0, safeY = 0, safeZ = 0, isline = false}
local startPos = {x=0, y=0, z=0}
local endPos = {x=0, y=0, z=0}

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
		{name= "InfectedCleaverMissileCast", radius = 80, time = 1, isline = true},
	},
	Draven = {
		{name= "DravenDoubleShot", radius = 125, time = 1, isline = true},
		{name= "DravenRCast", radius = 100, time = 4, isline = true},
	},
	Elise = {
		{name= "EliseHumanE", radius = 100, time = 1, isline = true},
	},
	Ezreal = {
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
	Soraka = {
		{name= "Starcall", radius = 500, time = 1, isline = false},
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
		{name= "syndrae5", radius = 100, time = 0.5, isline = true},
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

SpellNames = {       
	{name= "deathfiregrasp"},		--Items
	{name= "bilgewatercutlass"},
	{name= "HextechGunblade"},
	{name= "AatroxQ"},			--Aatrox
	{name= "AatroxE"},
	{name= "AatroxR"},
	{name= "AhriTumble"},		--Ahri
	{name= "AhriFoxFire"},
	{name= "AkaliMota"},		--Akali
	{name= "AkaliShadowSwipe"},
	{name= "AkaliShadowDance"},
	{name= "Pulverize"},		--Alistar
	{name= "Headbutt"},
	{name= "CurseoftheSadMummy"},	--Amumu
	{name= "Tantrum"},
	{name= "Frostbite"},		--Anivia
	{name= "FlashFrost"},
	{name= "Disintegrate"},		--Annie
	{name= "Incinerate"},
	{name= "InfernalGuardian"},
	{name= "Volley"},			--Ashe
	{name= "frostarrow"},
	{name= "PowerFistAttack"},		--Blitzcrank
	{name= "StaticField"},
	{name= "RocketGrab"},
	{name= "BrandConflagration"},
	{name= "BrandWildfire"},
	{name= "CassiopeiaTwinFang"},
	{name= "CassiopeiaPetrifyingGaze"},
	{name= "CaitlynAceintheHole"},
	{name= "CaitlynYordleTrap"},
	{name= "FeralScream"},
	{name= "Feast"},
	{name= "PhosphorusBomb"},		--Corki
	{name= "DariusAxeGrabCone"},	--Darius
	{name= "DariusCleave"},
	{name= "DariusExecute"},
	{name= "DariusNoxianTacticsONH"},
	{name= "DariusNoxianTacticsONHAttack"},
	{name= "DianaOrbs"},
	{name= "DianaTeleport"},
	{name= "DianaVortex"},
	{name= "DravenFury"},
	{name= "EliseHumanQ"},		--Elise
	{name= "EliseHumanW"},
	{name= "EliseSpiderQCast"},
	{name= "HateSpike"},		--Evelynn
	{name= "Ravage"},
	{name= "Terrify"},			--FiddleSticks
	{name= "DrainChannel"},
	{name= "FiddlesticksDarkWind"},
	{name= "FioraQ"},			--Fiora
	{name= "FioraDance"},
	{name= "FioraDanceStrike"},
	{name= "FioraRiposte"},
	{name= "FizzPiercingStrike"},	--Fizz
	{name= "fizzjumptwo"},
	{name= "fizzjumpbuffer"},
	{name= "GalioIdolOfDurand"},
	{name= "Parley"},			--Gangplank
	{name= "GarenSlash2"},		--Garen
	{name= "GarenSlash3"},
	{name= "GarenJustice"},
	{name= "gragasbarrelrolltoggle"},
	{name= "GravesClusterShot"},	--Graves
	{name= "gravessmokegrenadeboom"},
	{name= "HextechMicroRockets"},	--HeimerDinger
	{name= "HecarimRapidSlash"},	--Hecarim
	{name= "hecarimrampattack"},
	{name= "HecarimUlt"},
	{name= "IreliaGatotsu"},		--Irelia
	{name= "IreliaEquilibriumStrike"},
	{name= "JarvanIVGoldenAegis"},
	{name= "jarvanivcataclysmattack"},
	{name= "SowTheWind"},		--Janna
	{name= "ReapTheWhirlwind"},
	{name= "jayceshockblast"},		--Jayce
	{name= "JayceToTheSkies"},
	{name= "JayceThunderingBlow"},
	{name= "JaxLeapStrike"},		--Jax
	{name= "JaxCounterStrike"},
	{name= "JaxEmpowerTwo"},
	{name= "KarmaQ"},			--Karma
	{name= "KarmaSpiritBind"},
	{name= "WallOfPain"},
	{name= "NullLance"},		--Kassadin
	{name= "ForcePulse"},
	{name= "KennenBringTheLight"},	--Kennen
	{name= "KennenLightningRush"},
	{name= "KennenMegaProc"},
	{name= "KennenShurikenStorm"},
	{name= "BouncingBlades"},		--Katarina
	{name= "DeathLotus"},
	{name= "JudicatorReckoning"},	--Kayle
	{name= "KhazixQ"},			--Khazix
	{name= "KogMawCausticSpittle"},	--Kogmaw
	{name= "KogMawVoidOoze"},
	{name= "blindmonkqtwo"},		--Lee Sin
	{name= "BlindMonkEOne"},
	{name= "blindmonketwo"},
	{name= "LeonaShieldOfDaybreakAttack"}, --Leona
	{name= "LeonaSolarFlare"},
	{name= "LissandraQ"},		--Lissandra
	{name= "LissandraQMissile"},
	{name= "LissandraW"},
	{name= "LissandraE"},
	{name= "LissandraEMissile"},
	{name= "LissandraR"},
	{name= "lissandrarenemy"},
	{name= "LuluWTwo"},			--Lulu
	{name= "LuluWTwo"},
	{name= "LuluWTwo"},
	{name= "LucianQ"},			--Lucian
	{name= "LucianW"},
	{name= "LuluQMissile"},
	{name= "LuluR"},
	{name= "LuxPrismaticWave"},		--Lux	
	{name= "LuxLightStrikeKugel"},
	{name= "LuxMaliceCannonMis"},
	{name= "LuxMaliceCannon"},
	{name= "luxlightstriketoggle"},
	{name= "SeismicShard"},		--Malphite
	{name= "Landslide"},
	{name= "AlZaharMaleficVisions"},
	{name= "AlZaharNetherGrasp"},
	{name= "MaokaiUnstableGrowth"},	--Maokai
	{name= "MaokaiTrunkLine"},
	{name= "maokaisapling2boom"},
	{name= "AlphaStrike"},		--Master Yi
	{name= "MissFortuneRicochetShot"},  --Miss Fortune
	{name= "MordekaiserSyphonOfDestruction"}, --Mordekaiser
	{name= "MordekaiserChildrenOfTheGrave"},
	{name= "SoulShackles"}, 		--Morgana
	{name= "namiqmissile"},		--Nami
	{name= "NamiW"},
	{name= "NamiQ"},
	{name= "NamiRMissile"},
	{name= "NamiR"},
	{name= "Wither"},			--Nasus
	{name= "NautilusBackswingAttack"},
	{name= "NautilusGrandLine"},
	{name= "NautilusSplashZone"},
	{name= "NautilusWideswingAttack"},
	{name= "NautilusRavageStrikeAttack"},
	{name= "NautilusPiercingGaze"},
	{name= "Swipe"},			--Nidalee
	{name= "NidaleeTakedownAttack"},
	{name= "Bushwhack"},
	{name= "Takedown"},
	{name= "Pounce"},
	{name= "NocturneUnspeakableHorror"},--Nocturne
	{name= "NocturneParanoia"},
	{name= "NocturneParanoia2"},
	{name= "IceBlast"},			--Nunu
	{name= "OlafRecklessStrike"},	--Olaf
	{name= "OrianaDetonateCommand"},	--Orianna
	{name= "OrianaDissonanceCommand"},
	{name= "OrianaRedactCommand"},
	{name= "Pantheon_Throw"},		--Pantheon
	{name= "Pantheon_LeapBash"},
	{name= "Pantheon_GrandSkyfall_Fall"},
	{name= "PoppyHeroicCharge"},	--Poppy
	{name= "PoppyDevastatingBlow"},
	{name= "PoppyDiplomaticImmunity"},
	{name= "QuinnQ"},			--Quinn
	{name= "QuinnE"},
	{name= "QuinnValorQ"},
	{name= "QuinnValorE"},
	{name= "QuinnRFinale"},
	{name= "PuncturingTaunt"},		--Rammus
	{name= "PowerBall"},
	{name= "RengarE"},  		--Rengar
	{name= "RenektonExecute"},		--Renekton
	{name= "RenektonCleave"},
	{name= "RenektonPreExecute"},
	{name= "RenektonSuperExecute"},
	{name= "RivenMartyr"},		--Riven
	{name= "rivenizunablade"},
	{name= "RivenTriCleave"},
	{name= "RivenFengShuiEngine"},
	{name= "RumbleCarpetBomb"},		--Rumble
	{name= "RumbleCarpetBombDummy"},
	{name= "RumbleGrenade"},
	{name= "RumbleGrenadeMissile"},
	{name= "Overload"},			--Ryze
	{name= "RunePrison"},
	{name= "SpellFlux"},
	{name= "SejuaniArcticAssault"},	--Sejuani
	{name= "SejuaniWintersClaw"},
	{name= "TwoShivPoison"},		--Shaco
	{name= "ShacoBoxSpell"},
	{name= "ShyvanaDoubleAttackHit"},	--Shyvana
	{name= "shyvanadoubleattackdragon"},
	{name= "shyvanafireballdragon2"},
	{name= "ShenVorpalStar"},		--Shen
	{name= "Fling"},			--Singed
	{name= "CrypticGaze"},		--Sion
	{name="DeathsCaressFull"},
	{name= "SkarnerVirulentSlash"},	--Skarner
	{name= "SkarnerImpale"},
	{name= "SonaHymnofValor"},		--Sona
	{name="SonaAriaofPerseveranceAttack"},
	{name= "SonaSongofDiscordAttack"},
	{name= "Infuse"},
	{name= "SwainBeam"},		--Swain
	{name= "SwainTorment"},	--Syndra
	{name= "SyndraR"},
	{name= "MockingShout"},		--Tryndamere
	{name= "Dazzle"},			--Taric
	{name= "Shatter"},
	{name= "TaricHammerSmash"},
	{name= "TalonNoxianDiplomacyAttack"},--Talon
	{name= "TalonCutthroat"},
	{name= "TalonRake"},
	{name= "TalonShadowAssault"},
	{name= "talonrakemissileone"},
	{name= "BlindingDart"},		--Teemo
	{name= "BantamTrap"},
	{name= "DetonatingShot"},		
	{name= "BusterShot"},
	{name= "TrundleQ"},			--Trundle
	{name= "TrundlePain"},
	{name= "bluecardpreattack"},	--Twisted Fate
	{name= "redcardpreattack"},
	{name= "goldcardpreattack"},
	{name= "DebilitatingPoison",},      --Twitch
	{name= "Expunge",},
	{name= "UdyrBearAttack"},		--Udyr
	{name= "UrgotSwap2"},
	{name= "VarusE"},
	{name= "VarusEMissile"},
	{name= "VayneCondemn"},		--Vayne
	{name= "VayneCondemnMissile"},
	{name= "VeigarBalefulStrike"},	--Veigar
	{name= "VeigarPrimordialBurst"},
	{name= "VeigarEventHorizon"},
	{name= "ViQ"},			--Vi 
	{name= "ViR"},			
	{name= "ViktorPowerTransfer"},	--Viktor  
	{name= "VladimirTransfusion"},	--Vladimir
	{name= "VladimirTidesofBlood"},
	{name= "VladimirHemoplague"},
	{name= "VolibearQAttack"},		--Volibear
	{name= "VolibearQ"},
	{name= "VolibearW"},
	{name="VolibearE"},
	{name="VolibearR"},
	{name= "HungeringStrike"},		--Warwick
	{name="InfiniteDuress"},
	{name= "MonkeyKingQAttack"},	--Wukong
	{name= "MonkeyKingNimbus"},
	{name= "MonkeyKingDecoySwipe"},
	{name= "MonkeyKingSpinToWin"},
	{name= "XenZhaoSweep"},		--Xin Zhao
	{name= "XenZhaoThrust3"},
	{name= "XenZhaoParry"},
	{name= "XenZhaoComboTarget"},
	{name= "YorickDecayed"},		--Yorick
	{name= "YorickRavenous"},
	{name= "YorickSpectral"},
	{name= "YorickSummonRavenous"},
	{name= "yoricksummondecayed"},
	{name= "ZacQ"},			--Zac
	{name= "ZacW"},
	{name= "ZacE"},
	{name= "ZacR"},
	{name= "zedult"},			--Zed
	{name= "ZedPBAOEDummy"},
	{name= "ZiggsQSpell"},
	{name= "ziggse2"},
	{name= "ziggswtoggle"},
	{name= "TimeBomb"},			--Zilean
	{name="TimeWarp"},
	{name= "zyrapassivedeathmanager"},           
}

function Main()
	if myHero.name == 'Lulu' or myHero.name == 'Janna' or myHero.name == 'Karma' or myHero.name == 'LeeSin' or myHero.name == 'Orianna' or myHero.name == 'Lux' or myHero.name == 'JarvanIV' or myHero.name == 'Nautilus' or myHero.name == 'Rumble' or myHero.name == 'Sion' or myHero.name == 'Shen' or myHero.name == 'Skarner' or myHero.name == 'Urgot' or myHero.name == 'Diana' or myHero.name == 'Riven' or myHero.name == 'Morgana' or myHero.name == 'Sivir' or myHero.name == 'Nocturne' then

		if myHero.name == 'Lulu' then
			slot = 'E'
			stype = 'ally'
			AA = true
			Range = 650
		
		elseif myHero.name == 'Janna' then
			slot = 'E'
			stype = 'all'
			AA = true
			Range = 800
		
		elseif myHero.name == 'Karma' then
			slot = 'E'
			stype = 'all'
			AA = true
			Range = 800
			
		elseif myHero.name == 'LeeSin' then
			slot = 'W'
			stype = 'all'
			AA = true
			Range = 700
			
		elseif myHero.name == 'Orianna' then
			slot = 'E'
			stype = 'all'
			AA = true
			Range = 1100
			
		elseif myHero.name == 'Lux' then
			slot = 'W'
			stype = 'all'
			AA = true
			Range = 1175
			
		elseif myHero.name == 'JarvanIV' then
			slot = 'W'
			stype = 'self'
			AA = true
			Range = 300
			
		elseif myHero.name == 'Nautilus' then
			slot = 'W'
			stype = 'self'
			AA = true
			Range = 100
			
		elseif myHero.name == 'Rumble' then
			slot = 'W'
			stype = 'self'
			AA = true
			Range = 100
			
		elseif myHero.name == 'Sion' then
			slot = 'W'
			stype = 'self'
			AA = true
			Range = 550
			
		elseif myHero.name == 'Shen' then
			slot = 'W'
			stype = 'self'
			AA = true
			Range = 100
		
		elseif myHero.name == 'Skarner' then
			slot = 'W'
			stype = 'self'
			AA = true
			Range = 100
			
		elseif myHero.name == 'Urgot' then
			slot = 'W'
			stype = 'self'
			AA = true
			Range = 100
			
		elseif myHero.name == 'Diana' then
			slot = 'E'
			stype = 'self'
			AA = true
			Range = 200
			
		elseif myHero.name == 'Riven' then
			slot = 'E'
			stype = 'self'
			AA = true
			Range = 325
			
		elseif myHero.name == 'Morgana' then
			slot = 'E'
			stype = 'all'
			AA = false
			Range = 750
			
		elseif myHero.name == 'Sivir' then
			slot = 'E'
			stype = 'self'
			AA = false
			Range = 100
			
		elseif myHero.name == 'Nocturne' then
			slot = 'W'
			stype = 'self'
			AA = false
			Range = 100
			
		else
			slot = nil
			stype = nil
			AA = nil
			Range = nil
		end
		
		if GetTickCount() - spellShot.time > 0 then
			spellShot.shot = false
			spellShot.time = 0
			shotMe = false
		end
		
		GetWeakAlly()
	end
end

	ShieldConfig, menu = uiconfig.add_menu('Shield Menu', 200)
	menu.checkbutton('AutoShield', 'Auto-Shield', true)
	menu.permashow('AutoShield')
	
function OnProcessSpell(unit,spell)
	if myHero.name == 'Lulu' or myHero.name == 'Janna' or myHero.name == 'Karma' or myHero.name == 'LeeSin' or myHero.name == 'Orianna' or myHero.name == 'Lux' or myHero.name == 'JarvanIV' or myHero.name == 'Nautilus' or myHero.name == 'Rumble' or myHero.name == 'Sion' or myHero.name == 'Shen' or myHero.name == 'Skarner' or myHero.name == 'Urgot' or myHero.name == 'Diana' or myHero.name == 'Riven' or myHero.name == 'Morgana' or myHero.name == 'Sivir' or myHero.name == 'Nocturne' then
		if unit ~= nil and spell ~= nil and unit.team ~= myHero.team and IsHero(unit) and not string.find(spell.name,'BasicAttack') and not string.find(spell.name,'CritAttack') and not string.find(spell.name,'minion') and not string.find(spell.name,'Minion') then
			startPos = spell.startPos
			endPos = spell.endPos
			if spell.target ~= nil then
				local targetSpell = spell.target
				if ally ~= nil and ally.charName == targetSpell.charName then
					if stype == 'all' or stype == 'ally' then
						autoShield(ally)
					end
				end
				if myHero.charName == targetSpell.charNamem and stype ~= 'ally' then
					autoShield(myHero)
				end			
			end
			if ally ~= nil then
				local shot = SpellShotTarget(unit, spell, target)
				if shot ~= nil then
					spellShot = shot
					if spellShot.shot then
						if stype == 'all' or stype == 'ally' then
							autoShield(ally)
						end
					end
				end
			end
			local shot = SpellShotTarget(unit, spell, myHero)
			if shot ~= nil then
				spellShot = shot
				if spellShot.shot and stype ~= 'ally' then
					shotMe = true
					autoShield(myHero)	
				end
			end
		end
		if unit ~= nil and spell ~= nil and unit.team ~= myHero.team then
			if string.find(spell.name,'attack') or string.find(spell.name,'Attack') and not string.find(spell.name,'minion') and not string.find(spell.name,'Minion') then
				if ally ~= nil and spell.target~=nil and spell.target.name == ally.name and stype == 'all' or stype == 'ally' and AA == true then
					autoShield(ally)
				elseif spell.target~=nil and spell.target.name == myHero.name and AA == true  and not stype ~= 'ally' then
					autoShield(myHero)
				end
			end
			for _,targeting in pairs(SpellNames) do
				if spell.name == targeting.name then
					if ally ~= nil and spell.target~=nil and spell.target.name == ally.name and stype == 'all' or stype == 'ally' then
						autoShield(ally)
					elseif spell.target~=nil and spell.target.name == myHero.name and stype ~= 'ally' then
						autoShield(myHero)
					end
				end
			end
		end
	end
end

function autoShield(target)
	if ShieldConfig.AutoShield then
		CastSpellTarget(slot,target)
	end
end

function GetWeakAlly()
	local maxHealth = 9999
	ally = nil
	for i=1, objManager:GetMaxHeroes(), 1 do
	local object = objManager:GetHero(i)
		if object ~= nil and object.team == myHero.team and GetDistance(object) < Range and object.charName ~= myHero.charName then
			if object.health < maxHealth then
				maxHealth = object.health
				ally = object;
			end
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
	if unit ~= nil and unit.team ~= myHero.team and spell ~= nil and target~=nil then
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

SetTimerCallback("Main")