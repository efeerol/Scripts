--[[Whisper's Nocturne]]
--[[Thank you Val and Megaman for this awesome autoshield]]
require 'Utils'
 
local version = '1.0'
local skillslot = nil
local cc = 0
local skillshotArray = {}
local colorcyan = 0x0000FFFF
local coloryellow = 0xFFFFFF00
local colorgreen = 0xFF00FF00
local skillshotcharexist = false
local show_allies=0

-- Auto Summoner Spells thanks Dasia!
 
local healThreshold = 0.25
local barrierThreshold = 0.25
local manaThreshold = 0.40
 
local smiteTargets = {
  Baron   = { Object = nil, Match = "Worm2.1.1"         },
  Dragon  = { Object = nil, Match = "Dragon6.1.1"       },
  Golem1  = { Object = nil, Match = "AncientGolem1.1.1" },
  Golem2  = { Object = nil, Match = "AncientGolem7.1.1" },
  Lizard1 = { Object = nil, Match = "LizardElder4.1.1"  },
  Lizard2 = { Object = nil, Match = "LizardElder10.1.1" }
}
 
local castTimer = 0
local target = nil
local minions = { }
 
local summonerSpells = {
  Clarity = { Key = nil, Match = "SummonerMana",    Spell = "Clarity" },
  Heal    = { Key = nil, Match = "SummonerHeal",    Spell = "Heal"    },
  Smite   = { Key = nil, Match = "SummonerSmite",   Spell = "Smite"   },
  Cleanse = { Key = nil, Match = "SummonerBoost",   Spell = "Cleanse" },
  Barrier = { Key = nil, Match = "SummonerBarrier", Spell = "Barrier" },
  Exhaust = { Key = nil, Match = "SummonerExhaust", Spell = "Exhaust" },
  Ignite  = { Key = nil, Match = "SummonerDot",     Spell = "Ignite"  }
}
 
local summonerD = nil
local summonerF = nil
 
for s,summoner in pairs(summonerSpells) do
  if myHero.SummonerD == summoner.Match then
    summoner.Key = "D"
    summonerD = s
  elseif myHero.SummonerF == summoner.Match then
    summoner.Key = "F"
    summonerF = s
  end
end
 
printtext("Summonder D=" .. tostring(summonerD) .. "\n")
printtext("Summonder F=" .. tostring(summonerF) .. "\n")
 
if summonerD ~= nil or summonerF ~= nil then
  SumConf = scriptConfig("Summoner Spells", "SumSpells")
  if summonerSpells["Clarity"].Key ~= nil then SumConf:addParam("Clarity", "Auto Clarity", SCRIPT_PARAM_ONOFF, true) end
  if summonerSpells["Heal"].Key ~= nil then SumConf:addParam("Heal", "Auto Heal", SCRIPT_PARAM_ONOFF, true) end
  if summonerSpells["Smite"].Key ~= nil then SumConf:addParam("Smite", "Auto Smite", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("J")) end
  if summonerSpells["Cleanse"].Key ~= nil then SumConf:addParam("Cleanse", "Auto Cleanse", SCRIPT_PARAM_ONOFF, true) end
  if summonerSpells["Barrier"].Key ~= nil then SumConf:addParam("Barrier", "Auto Barrier", SCRIPT_PARAM_ONOFF, true) end
  if summonerSpells["Exhaust"].Key ~= nil then SumConf:addParam("Exhaust", "Auto Exhaust", SCRIPT_PARAM_ONOFF, true) end
  if summonerSpells["Ignite"].Key ~= nil then SumConf:addParam("Ignite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true) end
end
 
function OnTick()
  UpdateTables()
  if (GetClock() - castTimer) >= 100 and myHero.dead ~= 1 then
    castTimer = GetClock()
    if summonerSpells["Clarity"].Key ~= nil and SumConf.Clarity then Clarity() end
    if summonerSpells["Heal"].Key ~= nil  and SumConf.Heal then Heal() end
    if summonerSpells["Smite"].Key ~= nil and SumConf.Smite then Smite() end
    if summonerSpells["Cleanse"].Key ~= nil and SumConf.Cleanse then Cleanse() end
    if summonerSpells["Barrier"].Key ~= nil and SumConf.Barrier then Barrier() end
    if summonerSpells["Exhaust"].Key ~= nil and SumConf.Exhaust then Exhaust() end
    if summonerSpells["Ignite"].Key ~= nil and SumConf.Ignite then Ignite() end
  end
end
 
function OnCreateObj(object)
  if summonerSpells["Smite"].Key ~= nil then
    if object and object ~= nil and object.charName ~= nil then
      if object.charName == smiteTargets.Baron.Match then smiteTargets.Baron.Object = object
      elseif object.charName == smiteTargets.Dragon.Match then smiteTargets.Dragon.Object = object
      elseif object.charName == smiteTargets.Golem1.Match then smiteTargets.Golem1.Object = object
      elseif object.charName == smiteTargets.Golem2.Match then smiteTargets.Golem2.Object = object
      elseif object.charName == smiteTargets.Lizard1.Match then smiteTargets.Lizard1.Object = object
      elseif object.charName == smiteTargets.Lizard2.Match then smiteTargets.Lizard2.Object = object end
    end
  end
end
 
function UpdateTables()
  for i, creep in pairs(smiteTargets) do
    if creep.Object == nil or creep.Object.dead == 1 then
      creep.object = nil
    end
  end
  for i=1, objManager:GetMaxNewObjects(), 1 do
    object = objManager:GetNewObject(i)
    if object and object ~= nil and object.charName ~= nil then
      for t, creep in pairs(smiteTargets) do
        if object.charName == creep.Match then creep.Object = object end
      end
    end
  end
end
 
function Clarity()
  local threshold = math.round(myHero.maxMana * manaThreshold)
  local amount = math.round(myHero.maxMana * 0.4)
  local key = tostring(summonerSpells["Clarity"].Key)
  if myHero.mana <= threshold then
    if IsSpellReady(key) == 1 then
      CastSpellTarget(key, myHero)
    end
  end
end
 
function Heal()
  local threshold = math.round(myHero.maxHealth * healThreshold)
  local amount = 75 + (15 * myHero.selflevel)
  local key = tostring(summonerSpells["Heal"].Key)
  if myHero.health <= threshold then
    if IsSpellReady(key) == 1 then
      CastSpellTarget(key, myHero)
    end
  end
end
 
function Smite()
  local damage = 460 + (30 * myHero.selflevel)
  local key = tostring(summonerSpells["Smite"].Key)
  if IsSpellReady(key) == 1 then
    for i, minion in pairs(smiteTargets) do
      if minion ~= nil and minion.Object ~= nil and GetDistance(minion.Object) <= 650 and minion.Object.health <= damage then
        CastSpellTarget(key, minion.Object)
      end
    end
  end
end
 
function Cleanse()
  local key = tostring(summonerSpells["Cleanse"].Key)
  if summonerSpells["Cleanse"].Key ~= nil and CanCastSpell(summonerSpells["Cleanse"].Key) then
    -- TODO: this one is more tricksy
  end
end
 
function Barrier()
  local threshold = math.round(myHero.maxHealth * barrierThreshold)
  local amount = 95 + (25 * myHero.selflevel)
  local key = tostring(summonerSpells["Barrier"].Key)
  if IsSpellReady(key) == 1 then
    if myHero.health <= threshold then
      CastSpellTarget(key, myHero)
    end
  end
end
 
function Exhaust()
  local key = tostring(summonerSpells["Exhaust"].Key)
  -- TODO
end
 
function Ignite()
  local damage = 50 + (20 * myHero.selflevel)
  local key = tostring(summonerSpells["Ignite"].Key)
  if IsSpellReady(key) == 1 then
    target = GetWeakEnemy("TRUE", 610)
    if target ~= nil and target.health < damage then
      CastSpellTarget(key, target)
    end
  end
end
 
--------------------------------------[[The Amazing Auto Shield]]
SpellNames = {       {name= "deathfiregrasp"},          --Items
                    {name= "bilgewatercutlass"},
                    {name= "HextechGunblade"},
                    {name= "AatroxQ"},                  --Aatrox
                    {name= "AatroxE"},
                    {name= "AatroxR"},
                    {name= "AhriTumble"},               --Ahri
                    {name= "AhriFoxFire"},
                    {name= "AhriSeduce"},
                    {name= "AhriOrbofDeception"},
                    {name= "AkaliMota"},                --Akali
                    {name= "AkaliShadowSwipe"},
                    {name= "AkaliShadowDance"},
                    {name= "Pulverize"},                --Alistar
                    {name= "Headbutt"},
                    {name= "CurseoftheSadMummy"},       --Amumu
                    {name= "BandageToss"},
                    {name= "Tantrum"},
                    {name= "Frostbite"},                --Anivia
                    {name= "FlashFrost"},
                    {name= "FlashFrostSpell"},
                    {name= "Disintegrate"},             --Annie
                    {name= "Incinerate"},
                    {name= "InfernalGuardian"},
                    {name= "Volley"},                   --Ashe
                    {name= "frostarrow"},
                    {name= "PowerFistAttack"},          --Blitzcrank
                    {name= "StaticField"},
                    {name= "RocketGrab"},
                    {name= "RocketGrabMissile"},
                    {name= "BrandFissure"},             --Brand
                    {name= "BrandConflagration"},
                    {name= "BrandWildfire"},
                    {name= "CassiopeiaNoxiousBlast"},   --Cassiopeia
                    {name= "CassiopeiaTwinFang"},
                    {name= "CassiopeiaPetrifyingGaze"},
                    {name= "CaitlynPiltoverPeacemaker"}, --Caitlyn
                    {name= "CaitlynEntrapmentMissile"},
                    {name= "CaitlynAceintheHole"},
                    {name= "CaitlynYordleTrap"},
                    {name= "Rupture"},                  --Chogath
                    {name= "FeralScream"},
                    {name= "Feast"},
                    {name= "PhosphorusBomb"},           --Corki
                    {name= "MissileBarrage"},
                    {name= "MissileBarrageMissile"},
                    {name= "MissileBarrageMissile2"},
                    {name= "DariusAxeGrabCone"},        --Darius
                    {name= "DariusCleave"},
                    {name= "DariusExecute"},
                    {name= "DariusNoxianTacticsONH"},
                    {name= "DariusNoxianTacticsONHAttack"},
                    {name= "DianaArc"},                 --Diana
                    {name= "DianaOrbs"},
                    {name= "DianaTeleport"},
                    {name= "DianaVortex"},
                    {name= "InfectedCleaverMissile"},   --Dr. Mundo
                    {name= "InfectedCleaverMissileCast"},
                    {name= "DravenRCast"},              --Draven
                    {name= "DravenFury"},
                    {name= "DravenDoubleShot"},
                    {name= "EliseHumanQ"},              --Elise
                    {name= "EliseHumanW"},
                    {name= "EliseHumanE"},
                    {name= "EliseSpiderQCast"},
                    {name= "EzrealArcaneShift"},        --Ezreal
                    {name= "EzrealEssenceFlux"},
                    {name= "EzrealEssenceFluxMissile"},
                    {name= "EzrealMysticShot"},
                    {name= "EzrealMysticShotMissile"},
                    {name= "EzrealTrueshotBarrage"},
                    {name= "HateSpike"},                --Evelynn
                    {name= "Ravage"},
                    {name= "Terrify"},                  --FiddleSticks
                    {name= "DrainChannel"},
                    {name= "FiddlesticksDarkWind"},
                    {name= "FioraQ"},                   --Fiora
                    {name= "FioraDance"},
                    {name= "FioraDanceStrike"},
                    {name= "FioraRiposte"},
                    {name= "FizzPiercingStrike"},       --Fizz
                    {name= "FizzMarinerDoom"},
                    {name= "fizzjumptwo"},
                    {name= "fizzjumpbuffer"},
                    {name= "GalioResoluteSmite"},       --Galio
                    {name= "GalioIdolOfDurand"},
                    {name= "Parley"},                   --Gangplank
                    {name= "GarenSlash2"},              --Garen
                    {name= "GarenSlash3"},
                    {name= "GarenJustice"},
                    {name= "GragasExplosiveCask"},      --Gragas
                    {name= "gragasbarrelrolltoggle"},
                    {name= "GravesClusterShot"},        --Graves
                    {name= "GravesChargeShot"},
                    {name= "gravessmokegrenadeboom"},
                    {name= "HextechMicroRockets"},      --HeimerDinger
                    {name= "CH1ConcussionGrenade"},
                    {name= "HecarimRapidSlash"},        --Hecarim
                    {name= "hecarimrampattack"},
                    {name= "HecarimUlt"},
                    {name= "IreliaGatotsu"},            --Irelia
                    {name= "IreliaEquilibriumStrike"},
                    {name= "IreliaTranscendentBlades"},
                    {name= "JarvanIVCataclysm"},        --Jarvan IV
                    {name= "JarvanIVDemacianStandard"},
                    {name= "JarvanIVDragonStrike"},
                    {name= "JarvanIVGoldenAegis"},
                    {name= "jarvanivcataclysmattack"},
                    {name= "SowTheWind"},               --Janna
                    {name= "ReapTheWhirlwind"},
                    {name= "HowlingGale"},
                    {name= "jayceshockblast"},          --Jayce
                    {name= "JayceToTheSkies"},
                    {name= "JayceThunderingBlow"},
                    {name= "JaxLeapStrike"},            --Jax
                    {name= "JaxCounterStrike"},
                    {name= "JaxEmpowerTwo"},
                    {name= "KarmaQ"},                   --Karma
                    {name= "KarmaSpiritBind"},
                    {name= "LayWaste"},                 --Karthus
                    {name= "WallOfPain"},
                    {name= "NullLance"},                --Kassadin
                    {name= "ForcePulse"},
                    {name= "RiftWalk"},
                    {name= "KennenBringTheLight"},      --Kennen
                    {name= "KennenLightningRush"},
                    {name= "KennenMegaProc"},
                    {name= "KennenShurikenHurlMissile1"},
                    {name= "KennenShurikenStorm"},
                    {name= "BouncingBlades"},           --Katarina
                    {name= "ShadowStep"},
                    {name= "DeathLotus"},
                    {name= "JudicatorReckoning"},       --Kayle
                    {name= "KhazixQ"},                  --Khazix
                    {name= "KhazixW"},
                    {name= "KhazixE"},
                    {name= "KogMawCausticSpittle"},     --Kogmaw
                    {name= "KogMawLivingArtillery"},
                    {name= "KogMawVoidOoze"},
                    {name= "KogMawVoidOozeMissile"},
                    {name= "LeblancChaosOrb"},          --Leblanc
                    {name= "LeblancSlide"},
                    {name= "LeblancChaosOrbM"},
                    {name= "LeblancSlideM"},
                    {name= "LeblancSoulShackle"},
                    {name= "LeblancSoulShackleM"},
                    {name= "blindmonkqtwo"},            --Lee Sin
                    {name= "BlindMonkQOne"},
                    {name= "BlindMonkEOne"},
                    {name= "blindmonketwo"},
                    {name= "BlindMonkRKick"},
                    {name= "LeonaShieldOfDaybreakAttack"}, --Leona
                    {name= "LeonaSolarFlare"},
                    {name= "LeonaZenithBladeMissile"},
                    {name= "LissandraQ"},               --Lissandra
                    {name= "LissandraQMissile"},
                    {name= "LissandraW"},
                    {name= "LissandraE"},
                    {name= "LissandraEMissile"},
                    {name= "LissandraR"},
                    {name= "lissandrarenemy"},
                    {name= "LuluWTwo"},                 --Lulu
                    {name= "LuluW"},
                    {name= "LuluE"},
                    {name= "LuluQ"},
                    {name= "LuluQMissile"},
                    {name= "LuluR"},
                    {name= "LuxPrismaticWave"},         --Lux  
                    {name= "LuxLightStrikeKugel"},
                    {name= "LuxMaliceCannonMis"},
                    {name= "LuxMaliceCannon"},
                    {name= "luxlightstriketoggle"},
                    {name= "LuxLightBinding"},
                    {name= "SeismicShard"},             --Malphite
                    {name= "Landslide"},
                    {name= "UFSlash"},
                    {name= "AlZaharCalloftheVoid"},     --Malzahar
                    {name= "AlZaharMaleficVisions"},
                    {name= "AlZaharNetherGrasp"},
                    {name= "MaokaiUnstableGrowth"},     --Maokai
                    {name= "MaokaiTrunkLine"},
                    {name= "MaokaiSapling2"},
                    {name= "MaokaiTrunkLineMissile"},
                    {name= "maokaisapling2boom"},
                    {name= "AlphaStrike"},              --Master Yi
                    {name= "MissFortuneRicochetShot"},  --Miss Fortune
                    {name= "MordekaiserSyphonOfDestruction"}, --Mordekaiser
                    {name= "MordekaiserChildrenOfTheGrave"},
                    {name= "SoulShackles"},             --Morgana
                    {name= "DarkBindingMissile"},
                    {name= "namiqmissile"},             --Nami
                    {name= "NamiW"},
                    {name= "NamiQ"},
                    {name= "NamiRMissile"},
                    {name= "NamiR"},
                    {name= "Wither"},                   --Nasus
                    {name= "NautilusAnchorDrag"},       --Nautilus
                    {name= "NautilusAnchorDragMissile"},
                    {name= "NautilusBackswingAttack"},
                    {name= "NautilusGrandLine"},
                    {name= "NautilusSplashZone"},
                    {name= "NautilusWideswingAttack"},
                    {name= "NautilusRavageStrikeAttack"},
                    {name= "NautilusPiercingGaze"},
                    {name= "Swipe"},                    --Nidalee
                    {name= "NidaleeTakedownAttack"},
                    {name= "JavelinToss"},
                    {name= "Bushwhack"},
                    {name= "Takedown"},
                    {name= "Pounce"},
                    {name= "NocturneUnspeakableHorror"},--Nocturne
                    {name= "NocturneParanoia"},
                    {name= "NocturneParanoia2"},
                    {name= "IceBlast"},                 --Nunu
                    {name= "OlafRecklessStrike"},       --Olaf
                    {name= "OlafAxeThrow"},
                    {name= "OlafAxeThrowCast"},
                    {name= "OrianaDetonateCommand"},    --Orianna
                    {name= "OrianaDissonanceCommand"},
                    {name= "OrianaIzunaCommand"},
                    {name= "OrianaRedactCommand"},
                    {name= "Pantheon_Throw"},           --Pantheon
                    {name= "Pantheon_LeapBash"},
                    {name= "Pantheon_GrandSkyfall_Fall"},
                    {name= "PoppyHeroicCharge"},        --Poppy
                    {name= "PoppyDevastatingBlow"},
                    {name= "PoppyDiplomaticImmunity"},
                    {name= "QuinnQ"},                   --Quinn
                    {name= "QuinnQMissile"},
                    {name= "QuinnE"},
                    {name= "QuinnValorQ"},
                    {name= "QuinnValorE"},
                    {name= "QuinnRFinale"},
                    {name= "PuncturingTaunt"},          --Rammus
                    {name= "PowerBall"},
                    {name= "RengarE"},                  --Rengar
                    {name= "RenektonExecute"},          --Renekton
                    {name= "RenektonCleave"},
                    {name= "RenektonPreExecute"},
                    {name= "renektondice"},
                    {name= "RenektonSliceAndDice"},
                    {name= "RenektonSuperExecute"},
                    {name= "RivenMartyr"},              --Riven
                    {name= "rivenizunablade"},
                    {name= "RivenTriCleave"},
                    {name= "RivenFengShuiEngine"},
                    {name= "RumbleCarpetBomb"},         --Rumble
                    {name= "RumbleCarpetBombDummy"},
                    {name= "RumbleGrenade"},
                    {name= "RumbleGrenadeMissile"},
                    {name= "Overload"},                 --Ryze
                    {name= "RunePrison"},
                    {name= "SpellFlux"},
                    {name= "SejuaniArcticAssault"},     --Sejuani
                    {name= "SejuaniGlacialPrisonStart"},
                    {name= "TwoShivPoison"},            --Shaco
                    {name= "ShacoBoxSpell"},
                    {name= "SpiralBladeMissile"},       --Sivir
                    {name= "ShyvanaDoubleAttackHit"},   --Shyvana
                    {name= "ShyvanaFireballMissile"},
                    {name= "ShyvanaTransformLeap"},
                    {name= "shyvanadoubleattackdragon"},
                    {name= "shyvanafireballdragon2"},
                    {name= "ShenVorpalStar"},           --Shen
                    {name= "ShenShadowDash"},          
                    {name= "Fling"},                    --Singed
                    {name= "CrypticGaze"},              --Sion
                    {name="DeathsCaressFull"},
                    {name= "SkarnerVirulentSlash"},     --Skarner
                    {name= "SkarnerImpale"},
                    {name= "SonaHymnofValor"},          --Sona
                    {name="SonaAriaofPerseveranceAttack"},
                    {name= "SonaSongofDiscordAttack"},
                    {name= "Starcall"},                 --Soraka
                    {name= "Infuse"},
                    {name= "SwainBeam"},                --Swain
                    {name= "SwainShadowGrasp"},
                    {name= "SwainTorment"},
                    {name= "SyndraQ"},                  --Syndra
                    {name= "SyndraR"},
                    {name= "SyndraE"},
                    {name= "syndrawcast"},
                    {name= "MockingShout"},             --Tryndamere
                    {name= "Slash"},   
                    {name= "slashCast"},       
                    {name= "Dazzle"},                   --Taric
                    {name= "Shatter"},
                    {name= "TaricHammerSmash"},
                    {name= "TalonNoxianDiplomacyAttack"},--Talon
                    {name= "TalonCutthroat"},
                    {name= "TalonRake"},
                    {name= "TalonShadowAssault"},
                    {name= "talonrakemissileone"},
                    {name= "BlindingDart"},             --Teemo
                    {name= "BantamTrap"},
                    {name= "RocketJump"},               --Tristana
                    {name= "DetonatingShot"},          
                    {name= "BusterShot"},
                    {name= "TrundleQ"},                 --Trundle
                    {name= "TrundlePain"},
                    {name= "bluecardpreattack"},        --Twisted Fate
                    {name= "redcardpreattack"},
                    {name= "goldcardpreattack"},
                    {name= "WildCards"},
                    {name= "DebilitatingPoison",},      --Twitch
                    {name= "Expunge",},
                    {name= "UdyrBearAttack"},           --Udyr
                    {name= "UrgotPlasmaGrenade"},       --Urgot
                    {name= "UrgotHeatseekingHomeMissile"},
                    {name= "UrgotHeatseekingLineMissile"},
                    {name= "UrgotHeatseekingMissile"},
                    {name= "UrgotPlasmaGrenadeBoom"},
                    {name= "UrgotSwap2"},
                    {name= "VarusQ"},           --Varus
                    {name= "VarusE"},
                    {name= "VarusEMissile"},
                    {name= "VarusR"},
                    {name= "VayneCondemn"},             --Vayne
                    {name= "VayneCondemnMissile"},
                    {name= "VeigarBalefulStrike"},      --Veigar
                    {name= "VeigarPrimordialBurst"},
                    {name= "VeigarEventHorizon"},
                    {name= "VeigarDarkMatter"},
                    {name= "ViQ"},                      --Vi
                    {name= "ViR"},                     
                    {name= "ViktorPowerTransfer"},      --Viktor  
                    {name= "VladimirTransfusion"},      --Vladimir
                    {name= "VladimirTidesofBlood"},
                    {name= "VladimirHemoplague"},
                    {name= "VolibearQAttack"},          --Volibear
                    {name= "VolibearQ"},
                    {name= "VolibearW"},
                    {name="VolibearE"},
                    {name="VolibearR"},
                    {name= "HungeringStrike"},          --Warwick
                    {name="InfiniteDuress"},
                    {name= "MonkeyKingQAttack"},        --Wukong
                    {name= "MonkeyKingNimbus"},
                    {name= "MonkeyKingDecoySwipe"},
                    {name= "MonkeyKingSpinToWin"},
                    {name= "xerathmagechains"},         --Xerath
                    {name= "XerathArcaneBarrage"},
                    {name= "xeratharcanebarragewrapper"},
                    {name= "xeratharcanebarragewrapperext"},
                    {name= "xeratharcanopulsedamage"},
                    {name= "xeratharcanopulsedamageextended"},
                    {name= "xeratharcanopulseextended"},
                    {name= "xerathmagechainsextended"},
                    {name= "XenZhaoSweep"},             --Xin Zhao
                    {name= "XenZhaoThrust3"},
                    {name= "XenZhaoParry"},
                    {name= "XenZhaoComboTarget"},
                    {name= "YorickDecayed"},            --Yorick
                    {name= "YorickRavenous"},
                    {name= "YorickSpectral"},
                    {name= "YorickSummonRavenous"},
                    {name= "yoricksummondecayed"},
                    {name= "ZacQ"},                     --Zac
                    {name= "ZacW"},
                    {name= "ZacE"},
                    {name= "ZacR"},
                    {name= "zedult"},                   --Zed
                    {name= "ZedShuriken"},
                    {name= "ZedPBAOEDummy"},
                    {name= "ZiggsQ"},                   --Ziggs
                    {name= "ZiggsQSpell"},
                    {name= "ZiggsR"},
                    {name= "ZiggsE"},
                    {name= "ziggse2"},
                    {name= "ziggswtoggle"},
                    {name= "ZiggsW"},
                    {name= "TimeBomb"},                 --Zilean
                    {name="TimeWarp"},
                    {name= "ZyraGraspingRoots"},        --Zyra
                    {name= "ZyraQFissure"},
                    {name= "zyrapassivedeathmanager"},          
}
-------------------------------------
function ShieldRun()
        Skillshots()
       
        if ShieldConfig.skillslot == 1 then
                skillslot = "W"
                if myHero.SpellTimeW > 1.0 then
                RDY = true
                else RDY = false
                end
        end 
end
 
        ShieldConfig = scriptConfig("Shield Config", "shieldconfig")
        ShieldConfig:addParam("skillslot", "Skillslot", SCRIPT_PARAM_DOMAINUPDOWN, 1, 97, {"W"})
        ShieldConfig:addParam("drawskillshot", "DrawSkillshot", SCRIPT_PARAM_ONKEYTOGGLE, true, 98)
        ShieldConfig:addParam("AutoShield", "Autoshield", SCRIPT_PARAM_ONKEYTOGGLE, true, 99)
       
function OnProcessSpell(unit,spell)
        for i = 1, objManager:GetMaxHeroes() do
        local enemy = objManager:GetHero(i)
                if enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 then
                        if unit ~= nil and spell ~= nil and unit.name == enemy.name then
                                for _, spells in pairs(SpellNames) do
                                        if spell.name == spells.name and spell.target ~= nil and spell.target.name == myHero.name then
                                                if ShieldConfig.AutoShield and RDY == true then
                                                        CastSpellTarget(skillslot,myHero)
                                                end
                                        end
                                end
--------------end of table spells      
                                if spell.name == "SoulShackles" and GetDistance(spell) < 600 and ShieldConfig.AutoShield then
                                        shieldtick = GetTick()
                                        if GetTick() - shieldtick > 2000 and GetDistance(spell) < 1050 then
                                                CastSpellTarget(skillslot, myHero)
                                        end
                                end
                                if spell.name == "FallenOne" and ShieldConfig.AutoShield then
                                        shieldtick = GetTick()
                                        if GetTick() - shieldtick > 2000 then
                                                CastSpellTarget(skillslot, myHero)
                                        end
                                end
                        end
                end
        end
        ----------- Skillshots ---------------------
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
-------------------------------------------
 
function dodgeaoe(pos1, pos2, radius)
        local calc = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
        local dodgex
        local dodgez
        dodgex = pos2.x + ((radius+150)/calc)*(myHero.x-pos2.x)
        dodgez = pos2.z + ((radius+150)/calc)*(myHero.z-pos2.z)
        if calc < radius then
                if ShieldConfig.AutoShield then
                        if RDY == true then
                                CastSpellXYZ(skillslot,myHero.x,0,myHero.z)
                        end
                end
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
        dodgex = x4 + ((radius+150)/calc3)*(myHero.x-x4)
        dodgez = z4 + ((radius+150)/calc3)*(myHero.z-z4)
        if perpendicular < radius and calc1 < calc4 and calc2 < calc4 then
                if ShieldConfig.AutoShield and RDY == true then
                        CastSpellXYZ(skillslot,myHero.x,0,myHero.z)
                end
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
        dodgex = x4 + ((radius+150)/calc3)*(myHero.x-x4)
        dodgez = z4 + ((radius+150)/calc3)*(myHero.z-z4)
        if perpendicular < radius and calc1 < calc4 and calc2 < calc4 then
                if ShieldConfig.AutoShield then
                        if RDY == true then
                                CastSpellXYZ(skillslot,myHero.x,0,myHero.z)
                        end
                end
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
 
function Skillshots()
        cc=cc+1
        if (cc==30) then
                LoadTable()
        end
        if ShieldConfig.drawskillshot == true then
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
end
 
function LoadTable()
        print("table loaded::")
        table.insert(skillshotArray,{name= "SummonerClairvoyance", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 50000, type = 3, radius = 1300, color= coloryellow, time = 6})
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
            table.insert(skillshotArray,{name= "OlafAxeThrowCast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 2, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
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
                        table.insert(skillshotArray,{name= "WildCards", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1450, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
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
 
SetTimerCallback("ShieldRun")
SetTimerCallback("OnTick")
print("\nWhisper's Nocturne v"..version.."\n")