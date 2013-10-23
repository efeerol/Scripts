--[[
         _____                  ___           ___      _   _            _    
        |_   _|__ __ _ _ __    / _ \ _ _  ___| _ )_  _| |_| |_ ___ _ _ ( )___
          | |/ -_) _` | '  \  | (_) | ' \/ -_) _ \ || |  _|  _/ _ \ ' \|/(_-<
          |_|\___\__,_|_|_|_|  \___/|_||_\___|___/\_,_|\__|\__\___/_||_| /__/
   _   _ _ ___      ___              ___ _                      ___         _      _   
  /_\ | | |_ _|_ _ / _ \ _ _  ___   / __| |_  __ _ _ __  _ __  / __| __ _ _(_)_ __| |_ 
 / _ \| | || || ' \ (_) | ' \/ -_) | (__| ' \/ _` | '  \| '_ \ \__ \/ _| '_| | '_ \  _|
/_/ \_\_|_|___|_||_\___/|_||_\___|  \___|_||_\__,_|_|_|_| .__/ |___/\__|_| |_| .__/\__|
                                                        |_|                  |_|       
--]]
-- Version 3.0 - Utility Update/Overhaul
-- Version 3.1 - Fixed OnProcessSpell for Ward Revealer and other onscreen queues
-- Version 3.2 - Katarina Fix/Improvements

--Currently Supported Champions are - 
--Ahri Credits: IPJ
--Akali
--Brand
--Diana
--DrMundo
--Graves
--Katarina
--Kayle
--Pantheon
--Rengar
--Sejuani Credits: IPJ
--Shen Credits: IPJ
--Talon
--Taric Credits: IPJ
--Tristana
--Volibear
--Xerath
--Yorick Credits: IPJ

--Requirements													
require "Utils"  --Several calls to this for general useability
require "winapi" -- Used for the autolevelspells calls
require "SKeys" --Again, for autolevelspells
local send = require "SendInputScheduled"

--Config Settings
--Mundo
local MundoTooLow = 15     --The point at which it will stop casting spells
local MundoUltHP = 30      --MundoUltHP is the percent of hp that it will cast it's ULT
local MundoWToggled = false

--Kayle
local healPlease = 80      --% HP that Kayle will Auto heal herself
local ultiPlease = 20      --% HP that Kayle will Auto Ult herself

--Shen
--Utilizes auto-shielding pro-sauce.
local saveMeee = 20       --% HP you will ulti to allies.

--Taric
local taricHealMe = 70    --% HP that Taric will Auto heal himself
local taricHealThem = 85  --% HP that Taric will Auto heal team-mates.

--Yorick
--Utilizes auto-respawning pro-sauce.
local ghoulmeh = 15       --% HP you will ulti to allies.

--Local Variables
local lastRDagger = 0
local lastQHit = 0

--For DodgeSkillShots
local cc = 0
local skillshotArray = {}
local colorcyan = 0x0000FFFF
local coloryellow = 0xFFFFFF00
local colorgreen = 0xFF00FF00
local skillshotcharexist = false
local show_allies=0

--AutoLevelSpells
local Q,W,E,R = 'Q','W','E','R'
local metakey = SKeys.Control
local attempts = 0
local lastAttempt = 0

--AutoPot
local iHero = GetSelf()		
local wUsedAt = 0
local vUsedAt = 0
local timer=os.clock()
local bluePill = nil
local target  
local myHero = GetSelf()	
local doAttack = false  
local toggle_timer=os.clock()
local script_loaded=0
local waUsedAt = 0


--Arrays go here
local Summoners =
--Support to call all existing summoner spells
                {
                    Ignite = {Key = nil, Name = 'SummonerDot'},
                    Exhaust = {Key = nil, Name = 'SummonerExhaust'},
                    Heal = {Key = nil, Name = 'SummonerHeal'},
                    Clarity = {Key = nil, Name = 'SummonerMana'},
                    Barrier = {Key = nil, Name = 'SummonerBarrier'},
                    Clairvoyance = {Key = nil, Name = 'SummonerClairvoyance'},
					Cleanse = {Key = nil, Name = 'SummonerBoost'}
                }

local wards = {} --For SmartWard

local skillingOrder = {
--For AutoLevelSpells
    ----------------1 2 3 4 5 6 7 8 9 101112131415161718
    Ahri         = {Q,E,Q,W,Q,R,Q,W,Q,W,R,W,W,E,E,R,W,W},
    Akali        = {Q,W,Q,E,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Alistar      = {Q,E,W,Q,E,R,Q,E,Q,E,R,Q,E,W,W,R,W,W},
    Amumu        = {W,E,E,Q,E,R,E,Q,E,Q,R,Q,Q,W,W,R,W,W},
    Anivia       = {Q,E,Q,E,E,R,E,W,E,W,R,Q,Q,Q,W,R,W,W},
    Annie        = {W,Q,E,Q,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Ashe         = {W,E,Q,W,W,R,W,Q,W,Q,R,Q,Q,E,E,R,E,E},
    Blitzcrank   = {Q,E,W,E,W,R,E,W,E,W,R,E,W,Q,Q,R,Q,Q},
    Brand        = {W,E,Q,W,W,R,W,E,W,E,R,E,E,Q,Q,R,Q,Q},
    Caitlyn      = {W,Q,Q,E,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Cassiopeia   = {Q,E,Q,W,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Chogath      = {Q,E,W,W,W,R,W,E,W,E,R,E,E,Q,Q,R,Q,Q},
    Corki        = {Q,W,Q,E,Q,R,Q,E,Q,E,R,E,W,E,W,R,W,W},
    Diana        = {W,Q,W,E,Q,R,Q,Q,Q,W,R,W,W,E,E,R,E,E},
    DrMundo      = {W,Q,E,W,W,R,W,E,W,E,R,E,E,Q,Q,R,Q,Q},
    Elise        = {E,W,Q,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Evelynn      = {Q,E,Q,W,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Ezreal 		 = {Q,E,Q,Q,W,R,Q,E,Q,W,R,E,E,E,W,R,W,W},
    FiddleSticks = {E,Q,W,W,W,R,W,Q,W,Q,R,Q,Q,E,E,R,E,E},
    Fizz         = {E,Q,W,Q,W,R,Q,Q,Q,W,R,W,W,E,E,R,E,E},
    Galio        = {Q,W,Q,E,Q,R,Q,W,Q,W,R,E,E,W,W,R,E,E},
    Gangplank    = {Q,W,Q,E,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Garen        = {Q,E,E,W,E,R,E,Q,E,Q,R,Q,Q,W,W,R,W,W},
    Gragas       = {Q,E,W,Q,Q,R,Q,W,Q,W,R,W,E,W,E,R,E,E},
    Graves       = {Q,E,Q,W,Q,R,Q,W,Q,E,R,E,E,E,W,R,W,W},
    Hecarim      = {W,Q,Q,E,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Heimerdinger = {Q,W,W,Q,Q,R,E,W,W,W,R,Q,Q,E,E,R,Q,Q},
    Irelia       = {E,Q,W,W,W,R,W,E,W,E,R,Q,Q,E,Q,R,E,Q},
    Janna        = {Q,W,E,Q,Q,R,Q,W,Q,W,W,E,W,E,E,Q,E,Q},
    JarvanIV     = {Q,E,Q,W,Q,R,Q,E,W,Q,R,E,E,E,W,R,W,W},
    Jax          = {E,W,Q,W,W,R,W,E,W,E,R,Q,E,Q,Q,R,E,Q},
    Jayce        = {Q,E,Q,W,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Karma        = {Q,E,Q,W,E,Q,E,Q,E,Q,E,Q,E,W,W,W,W,W},
    Karthus      = {Q,E,W,Q,Q,R,Q,Q,E,E,R,E,E,W,W,R,W,W},
    Kassadin     = {Q,W,Q,E,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Katarina     = {Q,E,W,W,W,R,W,E,W,Q,R,Q,Q,Q,E,R,E,E},
    Kayle        = {E,Q,E,W,E,R,E,W,E,W,R,W,W,Q,Q,R,Q,Q},
    Kennen       = {Q,E,W,W,W,R,W,Q,W,Q,R,Q,Q,E,E,R,E,E},
    Khazix       = {E,W,Q,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    KogMaw       = {W,E,W,Q,W,R,W,Q,W,Q,R,Q,Q,E,E,R,E,E},
    Leblanc      = {Q,W,E,Q,Q,R,Q,W,Q,W,R,W,E,W,E,R,E,E},
    LeeSin       = {E,Q,W,Q,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Leona        = {E,Q,W,W,W,R,W,E,W,E,R,E,E,Q,Q,R,Q,Q},
    Lissandra    = {E,W,Q,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Lulu         = {E,W,Q,E,E,R,E,W,E,W,R,W,W,Q,Q,R,Q,Q},
    Lux          = {E,Q,E,W,E,R,E,Q,E,Q,R,Q,Q,W,W,R,W,W},
    Malphite     = {W,E,Q,E,E,R,E,Q,E,Q,R,Q,Q,W,W,R,W,W},
    Malzahar     = {Q,E,E,W,E,R,E,Q,E,Q,R,Q,Q,W,W,R,W,W},
    Maokai       = {E,Q,W,E,E,R,E,W,E,W,R,W,W,Q,Q,R,Q,Q},
    MasterYi     = {Q,W,E,Q,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    MissFortune  = {Q,W,Q,E,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    MonkeyKing   = {E,Q,W,Q,Q,R,E,Q,E,Q,R,E,E,W,W,R,W,W},
    Mordekaiser  = {E,Q,E,W,E,R,E,Q,E,Q,R,Q,Q,W,W,R,W,W},
    Morgana      = {Q,W,W,E,W,R,W,Q,W,Q,R,Q,Q,E,E,R,E,E},
    Nami         = {E,W,Q,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Nasus        = {Q,W,Q,E,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Nautilus     = {W,E,W,Q,W,R,W,E,W,E,R,E,E,Q,Q,R,Q,Q},
    Nidalee      = {W,E,Q,E,Q,R,Q,E,Q,Q,R,E,E,W,W,R,W,W},
    Nocturne     = {Q,W,Q,E,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Nunu         = {Q,W,Q,E,Q,R,Q,E,Q,E,R,E,W,E,W,R,W,W},
    Olaf         = {Q,W,Q,E,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Orianna      = {Q,E,W,Q,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Pantheon     = {Q,W,E,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Poppy        = {E,W,Q,Q,Q,R,Q,W,Q,W,W,W,E,E,E,E,R,R},
    Quinn        = {E,W,Q,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Rammus       = {Q,W,E,E,E,R,E,W,E,W,R,W,W,Q,Q,R,Q,Q},
    Renekton     = {W,Q,E,Q,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Rengar       = {Q,E,W,Q,Q,R,W,Q,Q,W,R,W,W,E,E,R,E,E},
    Riven        = {Q,W,E,W,W,R,W,E,W,E,R,E,E,Q,Q,R,Q,Q},
    Rumble       = {E,Q,Q,W,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Ryze         = {Q,W,Q,E,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Sejuani      = {W,Q,E,W,W,R,W,E,W,E,R,E,E,Q,Q,R,Q,Q},
    Shaco        = {W,Q,E,E,E,R,E,W,E,W,R,W,W,Q,Q,R,Q,Q},
    Shen         = {Q,W,E,Q,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Shyvana      = {W,Q,W,E,W,R,W,E,W,E,R,E,Q,E,Q,R,Q,Q},
    Singed       = {Q,E,Q,W,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Sion         = {W,Q,W,E,W,Q,W,Q,W,Q,Q,R,R,E,E,R,E,E},
    Sivir        = {Q,W,E,Q,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Skarner      = {Q,W,Q,W,Q,R,Q,W,Q,W,R,W,E,E,E,R,E,E},
    Sona         = {Q,W,E,Q,W,R,Q,W,Q,W,R,Q,W,E,E,R,E,E},
    Soraka       = {W,E,Q,W,E,R,E,W,E,E,R,W,W,Q,Q,R,Q,Q},
    Swain        = {W,E,Q,W,W,R,W,E,W,E,R,E,E,Q,Q,R,Q,Q},
    Syndra       = {E,W,Q,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Talon        = {W,E,Q,W,W,R,W,Q,W,Q,R,Q,Q,E,E,R,E,E},
    Taric        = {E,Q,W,W,W,R,W,Q,W,Q,R,Q,Q,E,E,R,E,E},
    Teemo        = {E,Q,E,W,E,R,E,Q,E,Q,R,Q,Q,W,W,R,W,W},
    Thresh       = {E,W,Q,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Tristana     = {E,W,E,W,E,R,E,Q,E,Q,R,Q,Q,Q,W,R,W,W},
    Trundle      = {Q,W,Q,E,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Tryndamere   = {Q,E,W,Q,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    TwistedFate  = {W,Q,E,Q,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Twitch       = {E,Q,E,W,E,R,E,Q,E,Q,R,Q,Q,W,W,R,W,W},
    Udyr         = {R,W,E,R,R,W,R,W,R,W,W,E,E,E,E,Q,Q,Q},
    Urgot        = {Q,E,Q,W,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Varus        = {Q,W,E,Q,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Vayne        = {Q,E,W,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Veigar       = {Q,E,W,Q,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Vi           = {E,W,Q,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Viktor       = {E,W,E,Q,E,R,E,Q,E,Q,R,Q,W,Q,W,R,W,W},
    Vladimir     = {Q,W,Q,E,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Volibear     = {Q,E,W,Q,E,R,E,E,W,E,R,W,W,Q,Q,R,Q,Q},
    Warwick      = {Q,W,Q,E,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Xerath       = {Q,E,Q,W,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    XinZhao      = {Q,W,E,E,Q,R,Q,Q,Q,E,R,E,E,W,W,R,W,W},
    Yorick       = {W,E,Q,E,E,R,E,Q,E,Q,R,Q,Q,W,W,R,W,W},
    Zac          = {E,W,Q,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Zed          = {E,W,Q,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Ziggs        = {Q,W,E,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Zilean       = {Q,W,Q,E,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Zyra         = {E,W,Q,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
}

--Cleanse detection arrays
local Oranges = {"Stun_glb", "AlZaharNetherGrasp_tar", "InfiniteDuress_tar", "skarner_ult_tail_tip", "SwapArrow_red", "Global_Taunt", "Global_Fear", "Ahri_Charm_buf", "leBlanc_shackle_tar", "LuxLightBinding_tar", "RunePrison_tar", "DarkBinding_tar", "nassus_wither_tar", "Amumu_SadRobot_Ultwrap", "Amumu_Ultwrap", "maokai_elementalAdvance_root_01", "RengarEMax_tar", "VarusRHitFlash"}
local QSS = {"Stun_glb", "AlZaharNetherGrasp_tar", "InfiniteDuress_tar", "skarner_ult_tail_tip", "SwapArrow_red", "summoner_banish", "Global_Taunt", "mordekaiser_cotg_tar", "Global_Fear", "Ahri_Charm_buf", "leBlanc_shackle_tar", "LuxLightBinding_tar", "Fizz_UltimateMissle_Orbit", "Fizz_UltimateMissle_Orbit_Lobster", "RunePrison_tar", "DarkBinding_tar", "nassus_wither_tar", "Amumu_SadRobot_Ultwrap", "Amumu_Ultwrap", "maokai_elementalAdvance_root_01", "RengarEMax_tar", "VarusRHitFlash"}
local Cleanselist = {"Stun_glb", "summoner_banish", "Global_Taunt", "Global_Fear", "Ahri_Charm_buf", "leBlanc_shackle_tar", "LuxLightBinding_tar", "RunePrison_tar", "DarkBinding_tar", "nassus_wither_tar", "Amumu_SadRobot_Ultwrap", "Amumu_Ultwrap", "maokai_elementalAdvance_root_01", "RengarEMax_tar", "VarusRHitFlash"}

local ChampList = {"Ahri", "Akali", "Brand", "Diana", "DrMundo", "Gragas", "Graves", "Katarina", "Kayle", "Leblanc", "Pantheon", "Rengar", "Sejuani", "Shen", "Talon", "Taric", "Tristana", "Volibear", "Xerath", "Yorick"}

---[[
if ChampList[myHero.name] == nil then
	function OnTick()
		UtilityFunction()
	end
end
--]]

--[[
if myHero.name ~= "Ahri" or "Akali" or "Brand" or "Diana" or "DrMundo" or "Graves" or "Katarina" or "Kayle" or "Pantheon" or "Rengar" or "Sejuani" or "Shen" or "Talon" or "Taric" or "Tristana" or "Volibear" or "Xerath" or "Yorick" then 
	function OnTick()
		UtilityFunction()
	end
end
]]
 
--Begin Champion Selection and Rotation scripts
if myHero.name == "Ahri" then
	function OnTick()
		AhriDraw()
		UtilityFunction()
		DrawText("Flame On!", 105, 25, Color.Green)
		target = GetWeakEnemy('MAGIC',975,"NEARMOUSE")
		if AIOConfig.AhriCombo then
			if target == nil then
				MoveToMouse()
			end
			if target ~= nil then	
				DrawText("Rapemode ENGAGED", 125, 40, Color.Red)
				DrawSphere(50,25,3,target.x,target.y+300,target.z)
				UtilityFunction()
				AhriQ(target)
				AhriR(target)
				AhriE(target)
				AhriW(target)
				AttackTarget(target)
			end
		end	
		if AIOConfig.AhriHarass then 
			if target == nil then
				MoveToMouse() 	
			end			
			if target ~= nil then	
				DrawSphere(50,25,3,target.x,target.y+300,target.z)
				UseAllItems(target)
				AhriE(target)
				AhriW(target)
				AhriQ(target)
				AttackTarget(target)
			end
		end	
	end
end

if myHero.name == "Akali" then
	function OnTick()
		AkaliDraw()
		UtilityFunction()
		DrawText("Team OneButton's Akali", 105, 25, Color.Green)						
		target = GetWeakEnemy('MAGIC',800,"NEARMOUSE")
		if AIOConfig.AkaliCombo then	
			if target == nil then
				MoveToMouse() 	
			end			
			if target ~= nil then	
				DrawText("Rapemode ENGAGED", 125, 40, Color.Red)
				CustomCircle(100,5,2,target)
				DrawSphere(50,25,3,target.x,target.y+300,target.z)
				UseAllItems(target)
				AttackTarget(target)
					if GetDistance(myHero, target) < 600 then 	
						AkaliQ(target)
					end		
					if GetDistance(myHero, target) < 800 then	
						AkaliR(target)
					end	
					if GetDistance(myHero, target) < 325 then 	
						AkaliE(target)
					end	
			end
		end		
	end
end

if myHero.name == "Brand" then
	local targetbuff = 0
	function OnTick()
		BrandDraw()
		UtilityFunction()
		DrawText("Team OneButton's Brand", 105, 25, Color.Green)					
		target = GetWeakEnemy('MAGIC',900,"NEARMOUSE")
		if AIOConfig.BrandCombo then 
			if target == nil then
				MoveToMouse() 	
			end			
			if target ~= nil then	
				DrawText("Rapemode ENGAGED", 125, 40, Color.Red)
				DrawSphere(50,25,3,target.x,target.y+300,target.z)
				UseAllItems(target)
				BrandE(target)
				BrandW(target)
				BrandQ(target)
				BrandR(target)
				AttackTarget(target)
			end
		end	
		if AIOConfig.BrandHarass then 
			if target == nil then
				MoveToMouse() 	
			end			
			if target ~= nil then	
				DrawSphere(50,25,3,target.x,target.y+300,target.z)
				UseAllItems(target)
				BrandE(target)
				BrandW(target)
				BrandQ(target)
				AttackTarget(target)
			end
		end	
	end
end

if myHero.name == "Diana" then
	function OnTick()
	UtilityFunction()
	local Moonlight = 0
	DianaDraw()
	DrawText("xXGeminiXx's OneButton Diana", 105, 25, Color.Green)
	target = GetWeakEnemy('MAGIC',830,"NEARMOUSE")  
		if AIOConfig.DianaCombo then		
			if target == nil then
				MoveToMouse() 	
			end		
			if target ~= nil then
				DrawText("Rapemode ENGAGED", 125, 40, Color.Red)
				CustomCircle(100,5,2,target)
				DrawSphere(50,25,3,target.x,target.y+300,target.z)
				UseAllItems(target)
				DianaQ(target) 
				DianaW(target)
				DianaE(target)
				DianaR(target)
				AttackTarget(target)
			end
		end
		if AIOConfig.DianaHarass then		
			if target == nil then
				MoveToMouse() 	
			end		
			if target ~= nil then
				CustomCircle(100,5,2,target)
				DrawSphere(50,25,3,target.x,target.y+300,target.z)
				UseAllItems(target)
				DianaQ(target) 
				AttackTarget(target)
			end
		end
	end
end

if myHero.name == "DrMundo" then
	function OnTick()
	UtilityFunction()
	local percent = ((myHero.health / myHero.maxHealth)*100)
	MundoDraw()	
	DrawText("Team OneButton's Mundo", 105, 25, Color.Green)
	--DrawText("HP" .. percent, 105, 50, Color.Red)						
	target = GetWeakEnemy('MAGIC',1000,"NEARMOUSE")
		if AIOConfig.MundoCombo then 
			if target == nil then
				MoveToMouse() 	
			end			
			if target ~= nil then	
				DrawText("Rapemode ENGAGED", 125, 40, Color.Red)
				CustomCircle(100,5,2,target)
				DrawSphere(50,25,3,target.x,target.y+300,target.z)
				AttackTarget(target)
				UseAllItems(target)
					if percent >= MundoTooLow then
						MundoQ(target) 
						MundoW(target) 
						MundoE(target) 
						else
						DrawText("HP BELOW " .. MundoTooLow .. "%", 165, 80, Color.Red)
						end
			else
				MundoWToggled = false
			end 
		end
		if percent <= MundoUltHP then
			MundoR(target)
		end	
	end
end

if myHero.name == "Graves" then
	function OnTick()
	DrawText("Boom headshot!", 105, 25, Color.Green) 		
	GravesDraw()
	UtilityFunction()	
	target = GetWeakEnemy('PHYS',900,"NEARMOUSE")
		if AIOConfig.GravesCombo then	
			if target == nil then
				MoveToMouse() 	
			end		
			if target ~= nil then			
				DrawSphere(50,25,3,target.x,target.y+300,target.z)			
				DrawText("Rapemode ENGAGED", 125, 40, Color.Red)
				UseAllItems(target)
			end
				if GetDistance(myHero, target) < 900 then 	
					GravesQ()
				end	
				if GetDistance(myHero, target) < 900 then 	
					GravesW()
				end						
				if GetDistance(myHero, target) < 900 then	
					GravesR()
				end	
				if ValidTarget(target) then 
				AttackTarget(target)
				end
		end
		if AIOConfig.GravesHarass then	
			if target == nil then
				MoveToMouse() 	
			end		
			if target ~= nil then			
				DrawSphere(50,25,3,target.x,target.y+300,target.z)			
				UseAllItems(target)
				end
				if GetDistance(myHero, target) < 900 then 	
					GravesQ()
				end	
				if GetDistance(myHero, target) < 900 then 	
					GravesW()
				end						
				if ValidTarget(target) then 
				AttackTarget(target)
				end
		end
	end
end

if myHero.name == "Katarina" then
    function OnTick()
		UtilityFunction()
		FindNewObjects()
		checkSpinning()
		KatarinaDraw()
		DrawText("Team OneButton's Katarina", 105, 25, Color.Green)
		target = GetWeakEnemy('MAGIC',730,"NEARMOUSE")
        if AIOConfig.KatCombo then    
			if target == nil then
                if not spinning then MoveToMouse() end
			end                
			if target ~= nil then 
				DrawText("Rapemode ENGAGED", 125, 40, Color.Red)
				CustomCircle(100,5,2,target)
				DrawSphere(50,25,3,target.x,target.y+300,target.z)
				UseAllItems(target)
				if GetDistance(myHero, target) < 675 then      
					KatQ(target)
					doingCombo = true
				end            
				if GetDistance(myHero, target) < 375 then      
				KatW(target)
				doingCombo = true
				end    
				if GetDistance(myHero, target) < 700 then      
					KatE(target)
					doingCombo = true
				end    
				if GetDistance(myHero, target) < 275 then      
					KatR(target)
					doingCombo = true
				end    
			end
           end            
       end
	doingCombo = false
end

if myHero.name == "Kayle" then
	function OnTick()
	UtilityFunction()
	local script_loaded=1
	target = GetWeakEnemy('MAGIC',650)
	HP()
	Ultibot()
	DrawCircleObject(myHero, 650, 0x02)
	DrawText("Kaylebot v0.2 Loaded",5,40,0xFF00EE00);
	DrawText("AutoUlt v0.2 Activated",5,80,0xFF00EE00);
		if AIOConfig.KayleCombo then
			if target == nil then
				MoveToMouse() 	
			end
			if target ~= nil then
				DrawText("RAPEMODE ENGAGED",5,55,0xFFFF0000)
				CustomCircle(100,5,2,target)
				UseAllItems(target)
				DrawSphere(50,25,3,target.x,target.y+300,target.z)
					if GetDistance(myHero, target) < 650 then 
						CastSpellTarget("Q",target) 
					end
					if GetDistance(myHero, target) < 650 then 
						CastSpellTarget("E", myHero) 
					end
				AttackTarget(target)
			end
		end		
	end
end

if myHero.name == "Pantheon" then
	function OnTick()
	local etimer = 0
	DrawText("THIS.. IS.. SPARTA!!", 105, 25, Color.Green)
	PanthDraw()
	UtilityFunction()
	target = GetWeakEnemy('PHYS',600)
		if AIOConfig.PantheonCombo then
			if target == nil then
				if GetTickCount() > etimer then	
					MoveToMouse()
				end
			end
				if target ~= nil then		
				DrawSphere(50,25,3,target.x,target.y+300,target.z)
				DrawText("Rapemode ENGAGED", 125, 40, Color.Red)
				AttackTarget(target)
				UseAllItems(target)
					if GetTickCount() > etimer and GetDistance(myHero, target) < 600 then 
						CastSpellTarget("Q",target)
					end
					if GetDistance(myHero, target) < 600 then 	
						PanthW()
					end		
					if GetDistance(myHero, target) < 600 then	
						PanthE()
					end
				end
		end
	end
end

if myHero.name == "Rengar" then
	function OnTick()
	RengarDraw()
	UtilityFunction()
	DrawText("Leap Frog", 105, 25, Color.Green)					
	target = GetWeakEnemy('PHYS',780,"NEARMOUSE")
		if AIOConfig.RengarCombo then	
			if target == nil then
				MoveToMouse() 	
			end
			if target ~= nil then	
				DrawText("Rapemode ENGAGED", 125, 40, Color.Red)
				CustomCircle(100,5,2,target)
				DrawSphere(50,25,3,target.x,target.y+300,target.z)
				AttackTarget(target)
				UseAllItems(target)
					if GetDistance(myHero, target) < 600 then
						RengarQ()
					end
					if GetDistance(myHero, target) < 575 then
						RengarE()
					end	
					if GetDistance(myHero, target) < 500 then
						RengarW()
					end
				end
			end
		if AIOConfig.RengarHarass then	
			if target == nil then
				MoveToMouse() 	
			end
			if target ~= nil then	
				CustomCircle(100,5,2,target)
				DrawSphere(50,25,3,target.x,target.y+300,target.z)
				UseAllItems(target)
				AttackTarget(target)
					if GetDistance(myHero, target) < 575 then
						RengarE()
					end	
					if GetDistance(myHero, target) < 500 then
						RengarW()
					end
			end
		end
	end        
end

if myHero.name == "Sejuani" then
	function OnTick()
	UtilityFunction()
	local script_loaded=1
	target = GetWeakEnemy('MAGIC',1175)
	DrawText("Yippee Kiyay Mother#!$*@&",5,40,0xFF00EE00);
	DrawText("Let's get Freezy!",5,80,0xFF00EE00);
	SejuaniDraw()
		if AIOConfig.SejuaniCombo then
			if target == nil then
				MoveToMouse() 	
			end
			if target ~= nil then
				DrawText("RAPEMODE ENGAGED",5,55,0xFFFF0000)
				CustomCircle(100,5,2,target)
				UseAllItems(target)
				DrawSphere(50,25,3,target.x,target.y+300,target.z)
					if GetDistance(myHero, target) < 1175 then 
						CastHotkey("AUTO 100,0 SPELLR:WEAKENEMY RANGE=1175 FIREAHEAD=2,16 MAXDIST NOSHOW CD") 
					end
					if GetDistance(myHero, target) < 650 then 
						CastSpellXYZ("Q",GetFireahead(target,1,15)) 
					end
					if GetDistance(myHero, target) < 350 then 
						CastSpellTarget("W", myHero) 
					end
					if GetDistance(myHero, target) < 1000 and CanUseSpell("E") then 
						CastSpellTarget("E", myHero) 
					end
				AttackTarget(target)
			end
		end	
			if AIOConfig.SejuaniHarrass then
			if target == nil then
				MoveToMouse() 	
			end
			if target ~= nil then
				DrawText("RAPEMODE ENGAGED",5,55,0xFFFF0000)
				CustomCircle(100,5,2,target)
				UseAllItems(target)
				DrawSphere(50,25,3,target.x,target.y+300,target.z)
					if GetDistance(myHero, target) < 650 then 
						CastSpellXYZ("Q",GetFireahead(target,1,15)) 
					end
					if GetDistance(myHero, target) < 350 then 
						CastSpellTarget("W", myHero) 
					end
					if GetDistance(myHero, target) < 1000 and CanUseSpell("E") then 
						CastSpellTarget("E", myHero) 
					end
				AttackTarget(target)
			end
		end	
	end
end

if myHero.name == "Shen" then
	function OnTick()
	UtilityFunction()
	local script_loaded=1
	target = GetWeakEnemy('MAGIC',575)
	SaveThemAll()
	DrawCircleObject(myHero, 575, 0x02)
	DrawCircleObject(myHero, 475, 0x02)
	DrawText("COME AT ME BRO!",5,40,0xFF00EE00);
	DrawText("AutoUlt Activated",5,80,0xFF00EE00);
		if AIOConfig.ShenCombo then
			if target == nil then
				MoveToMouse() 	
			end
			if target ~= nil then
				DrawText("RAPEMODE ENGAGED",5,55,0xFFFF0000)
				CustomCircle(100,5,2,target)
				UseAllItems(target)
				DrawSphere(50,25,3,target.x,target.y+300,target.z)
					if GetDistance(myHero, target) < 475 then 
						CastSpellTarget("Q",target) 
					end
					if GetDistance(myHero, target) < 575 then 
						ShenE() 
					end
					if GetDistance(myHero, target) < 350 then 
						CastSpellTarget("W", myHero) 
					end
				AttackTarget(target)
			end
		end		
	end
end

if myHero.name == "Talon" then
	function OnTick()
	TalonDraw()
	UtilityFunction()
	DrawText("Do the Chickens have large Talons?", 105, 25, Color.Green)
	target = GetWeakEnemy('PHYS',700,"NEARMOUSE")  
			if AIOConfig.TalonCombo then
				if target == nil or not doAttack then
					MoveToMouse()
				if target ~= nil then
				DrawText("Rapemode ENGAGED", 125, 40, Color.Red)
				CustomCircle(100,5,2,target)
				DrawSphere(50,25,3,target.x,target.y+300,target.z)
				UseAllItems(target)
				if GetDistance(myHero, target) < 700 then
					TalonE(target)
				end    
				TalonQ(target)
				AttackTarget(target)                                   
				if GetDistance(myHero, target) < 595 then      
					TalonW(target)
				end    
				TalonR(target)
				AttackTarget(target)
			end
			end
		end
			if AIOConfig.TalonHarass then
				if target == nil or not doAttack then
					MoveToMouse()
				if target ~= nil then
				CustomCircle(100,5,2,target)
				DrawSphere(50,25,3,target.x,target.y+300,target.z)
				UseAllItems(target)
				AttackTarget(target)                                   
				if GetDistance(myHero, target) < 595 then      
					TalonW(target)
				end    
				AttackTarget(target)
			end
			end
		end		
	end
end

if myHero.name == "Taric" then
	function OnTick()
	UtilityFunction()
	local script_loaded=1
	target = GetWeakEnemy('MAGIC',625)
	taricQspam()
	TaricDraw()
	DrawText("I AM NOT...FUCKING...GAY!",5,40,0xFF00EE00);
	DrawText("ICanHazHeals v4.20 Loaded",5,80,0xFF00EE00);
		if AIOConfig.TaricCombo then
			if target == nil then
				MoveToMouse() 	
			end
			if target ~= nil then
				DrawText("RAPEMODE ENGAGED",5,55,0xFFFF0000)
				CustomCircle(100,5,2,target)
				UseAllItems(target)
				DrawSphere(50,25,3,target.x,target.y+300,target.z)
					if GetDistance(myHero, target) < 350 then 
						CastSpellTarget("E",target) 
					end
					if GetDistance(myHero, target) < 200 then 
						CastSpellTarget("W", myHero) 
					end
					if GetDistance(myHero, target) < 200 then 
						CastSpellTarget("R", myHero) 
					end
				AttackTarget(target)
			end
		end	
		if AIOConfig.TaricHarass then
				if target == nil or not doAttack then
					MoveToMouse()
				if target ~= nil then
				CustomCircle(100,5,2,target)
				DrawSphere(50,25,3,target.x,target.y+300,target.z)
				UseAllItems(target)
				AttackTarget(target)                                   
				if GetDistance(myHero, target) < 625 then 
						CastSpellTarget("E",target)
				end    
				AttackTarget(target)
			end
			end
		end		
	end
end

if myHero.name == "Tristana" then
	function OnTick()
	TristDraw()
	UtilityFunction()
	DrawText("Wanna see the fireworks?", 105, 25, Color.Green)					
	target = GetWeakEnemy('MAGIC',900,"NEARMOUSE")
		if AIOConfig.TristanaCombo then 
			if target == nil or not doAttack then
				MoveToMouse() 		
			if target ~= nil then	
			DrawSphere(50,25,3,target.x,target.y+300,target.z)
			DrawText("Rapemode ENGAGED", 125, 40, Color.Red)
			UseAllItems(target)
			if GetDistance(myHero, target) < 900 then 	
				TristW()
			end	
			if GetDistance(myHero, target) < 900 then 	
				TristE()
			end						
			if GetDistance(myHero, target) < 900 then	
				TristR()
			end		
		AttackTarget(target)
		end
			end
		end   
		if AIOConfig.TristanaHarass then 
			if target == nil or not doAttack then
				MoveToMouse() 		
			if target ~= nil then	
			DrawSphere(50,25,3,target.x,target.y+300,target.z)
			UseAllItems(target)
			if GetDistance(myHero, target) < 900 then 	
				TristW()
			end	
			if GetDistance(myHero, target) < 900 then 	
				TristE()
			end						
		AttackTarget(target)
		end
			end
		end 		
	end
end

if myHero.name == "Volibear" then
	function OnTick()
	VoliDraw()
	DrawText("Rolling Thunder", 105, 25, Color.Green)					
	target = GetWeakEnemy('PHYS',1500,"NEARMOUSE")
		if AIOConfig.VolibearCombo then		
			if target == nil or not doAttack then
				MoveToMouse() 		
				if target ~= nil then	
				DrawText("Rapemode ENGAGED", 125, 40, Color.Red)
				UseAllItems(target)
				DrawSphere(50,25,3,target.x,target.y+300,target.z)
					if GetDistance(myHero, target) < 1500 then
						VoliQ()
					end	
					if GetDistance(myHero, target) < 900 then
						VoliR()
					end
					if GetDistance(myHero, target) < 425 then
						VoliE()
					end	
					if GetDistance(myHero, target) < 400 then
						VoliW()
					end
				AttackTarget(target)
					end
				end        		
				end
			if AIOConfig.VolibearHarass then		
			if target == nil or not doAttack then
				MoveToMouse() 		
				if target ~= nil then	
				DrawText("Rapemode ENGAGED", 125, 40, Color.Red)
				DrawSphere(50,25,3,target.x,target.y+300,target.z)
				UseAllItems(target)
					if GetDistance(myHero, target) < 1500 then
						VoliQ()
					end	
					if GetDistance(myHero, target) < 425 then
						VoliE()
					end	
					if GetDistance(myHero, target) < 400 then
						VoliW()
					end
				AttackTarget(target)
			end
		end        		
	end
end
end

if myHero.name == "Xerath" then
	function OnTick()
	XerathDraw()
	UtilityFunction()
	DrawText("I AM the arcane!", 105, 25, Color.Green)					
	target = GetWeakEnemy('MAGIC',1300,"NEARMOUSE")
		if AIOConfig.XerathCombo then
			if target == nil or not doAttack then
					MoveToMouse() 		
				if target ~= nil then	
					UseAllItems(target)
					DrawText("Rapemode ENGAGED", 125, 40, Color.Red)
					CustomCircle(100,4,1,target)
					DrawSphere(50,25,3,target.x,target.y+300,target.z)
				if GetDistance(myHero, target) < 1000 then 	
					XerathE()
				end	
				if GetDistance(myHero, target) < 1300 then 	
					XerathQ()
				end						
				if GetDistance(myHero, target) < 1300 then	
					XerathR()
				end	
				if ValidTarget(target) then 
					AttackTarget(target)
				end
			end
		end
		end
		if AIOConfig.XerathHarass then
			if target == nil or not doAttack then
					MoveToMouse() 		
				if target ~= nil then	
					UtilityFunction()
					CustomCircle(100,4,1,target)
					DrawSphere(50,25,3,target.x,target.y+300,target.z)
				end
				if GetDistance(myHero, target) < 1000 then 	
					XerathE()
				end	
				if GetDistance(myHero, target) < 1300 then 	
					XerathQ()
				end						
				if ValidTarget(target) then 
					AttackTarget(target)
				end
			end
		end        
	end
end

if myHero.name == "Gragas" then
	function OnTick()
	GragasDraw()	
	UtilityFunction()	
	target = GetWeakEnemy("Magic", 600, "NEARMOUSE")
		if AIOConfig.GragasCombo then
			if target == nil then
					MoveToMouse() 
			end					
				if target ~= nil then	
					DrawText("Rapemode ENGAGED", 125, 40, Color.Red)
					CustomCircle(100,4,1,target)
					DrawSphere(50,25,3,target.x,target.y+300,target.z)
					UseAllItems(target)
					if CanCastSpell("Q") and ValidTarget(target) then CastSpellXYZ('Q',GetFireahead(target,1,10)) end
					if CanCastSpell("E") and ValidTarget(target) then CastSpellXYZ('E',GetFireahead(target,1,10)) end
					if CanCastSpell("R") and ValidTarget(target) then CastSpellTarget('R',target) end
					if ValidTarget(target) then 
					AttackTarget(target)
				end
			end
		end
		if AIOConfig.GragasHarass then
			if target == nil then
					MoveToMouse() 		
				if target ~= nil then	
					UseAllItems(target)
					DrawSphere(50,25,3,target.x,target.y+300,target.z)
					CustomCircle(100,4,1,target)
					if CanCastSpell("Q") and ValidTarget(target) then CastSpellXYZ('Q',GetFireahead(target,1,10)) end
					if CanCastSpell("E") and ValidTarget(target) then CastSpellXYZ('E',GetFireahead(target,1,10)) end			
				if ValidTarget(target) then 
					AttackTarget(target)
				end
				end
			end
		end        
	end
end

if myHero.name == "Yorick" then
	function OnTick()
	local script_loaded=1
	target = GetWeakEnemy('MAGIC',600)
	YouShallLive()
	UtilityFunction()
	DrawCircleObject(myHero, 600, 0x02)
	DrawCircleObject(myHero, 550, 0x02)
	DrawCircleObject(myHero, 150, 0x02)
	DrawText("Shovel: Check! Ghouls: Check! GG!",5,40,0xFF00EE00);
	DrawText("AutoUlt Activated",5,80,0xFF00EE00);
		if AIOConfig.YorickCombo then
			if target == nil then
				MoveToMouse() 	
			end
			if target ~= nil then
				DrawText("RAPEMODE ENGAGED",5,55,0xFFFF0000)
				CustomCircle(100,5,2,target)
				UseAllItems(target)
				DrawSphere(50,25,3,target.x,target.y+300,target.z)
					if GetDistance(myHero, target) < 600 then 
						CastSpellTarget("E",target) 
					end
					if GetDistance(myHero, target) < 550 then 
						YorickW() 
					end
					if GetDistance(myHero, target) < 300 then 
						CastSpellXYZ("Q",myHero.x,myHero.y,myHero.z)
					end
					
				AttackTarget(target)
			end
		end		
	end
end

if myHero.name == "Leblanc" then
	function OnTick()
		LeBlancDraw()	
		UtilityFunction()
		target = GetWeakEnemy("Magic", 600, "NEARMOUSE")
		if AIOConfig.LeBlancCombo then
			if target == nil then
					MoveToMouse() 	
			end
				if target ~= nil then	
					DrawText("Rapemode ENGAGED", 125, 40, Color.Red)
					DrawSphere(50,25,3,target.x,target.y+300,target.z)
					CustomCircle(100,4,1,target)
					UseAllItems(target)
					if GetDistance(myHero, target) < 700 then leblancQ(target) end		
					if GetDistance(myHero, target) < 700 then leblancR(target) end	
					if GetDistance(myHero, target) < 600 then leblancW(target) end
					if GetDistance(myHero, target) < 100 and GetDistance(myHero, target) > 10 then 	leblancE(target) end	
					if ValidTarget(target) then 
					AttackTarget(target)
				end
			end
		end
		if AIOConfig.LeBlancHarass then
			if target == nil then
					MoveToMouse() 
				end					
				if target ~= nil then	
					UseAllItems(target)
					DrawSphere(50,25,3,target.x,target.y+300,target.z)
					CustomCircle(100,4,1,target)
					if GetDistance(myHero, target) < 700 then leblancQ(target) end
					if GetDistance(myHero, target) < 600 then leblancW(target) end			
				if ValidTarget(target) then 
					AttackTarget(target)
				end
				end
			end
	end
end    
--End Champion scripts

--Champion Specific Functions    
--Leblanc functions
function leblancQ(target)	
	if target ~= nil and ValidTarget(target) and IsSpellReady("Q") and GetSpellLevel("Q") > 0 then
		CastSpellTarget("Q", target) 
		lastSpell = "Q"
	end
end

function leblancW(target)
	if target ~= nil and ValidTarget(target) and  IsSpellReady("Q") == 0 and not ultReady() and IsSpellReady("W") and GetSpellLevel("W") > 0 and GetClock() > wUsedAt + 4000 then
		CastSpellTarget("W", target) 	
		lastSpell = "W"	
		wUsedAt = GetClock()
	end
end

function leblancE(target)
	if target ~= nil and ValidTarget(target) and not ultReady() and IsSpellReady("E") and GetSpellLevel("E") > 0 then
		CastSpellXYZ("E", target.x, target.y, target.z) 
		lastSpell = "E"	
	end
end

function leblancR(target)	
	if target ~= nil and ValidTarget(target) and lastSpell == "Q" and IsSpellReady("Q") == 0 and ultReady() then
		CastSpellTarget("R", target) 
		lastSpell = "R"	
	end
end

function ultReady()
	if GetSpellLevel("R") == 0 or IsSpellReady("R") == 0 then return false else return true end
end

function LeBlancDraw()
	CustomCircle(600,2,3,myHero)
end
--End LeBlanc Functions

--Gragass Functions
function GragasDraw()
	CustomCircle(600,2,3,myHero)
end
--End Gragass Functions

--Dianas Functions
function DianaQ(target)
        if target ~= nil and GetDistance(myHero, target) < 825 then  
                CastSpellXYZ('Q',GetFireahead(target,2,18))
        end
end
 
function DianaW(target)
        if IsSpellReady("W") == 1 and GetDistance(myHero, target) < 200 then
                CastSpellTarget("W",myHero)
        end
end
 
function DianaE(target)
        if IsSpellReady("E") and GetDistance(myHero, target) < 249 then
                CastSpellTarget("E",myHero)
        end
end
 
function DianaR(target)
        if IsSpellReady("R") == 1 and GetDistance(myHero, target) < 825 and Moonlight == 1 then
                CastSpellTarget("R",target)                                    
        end
end
 
function DianaDraw()
        CustomCircle(700,2,3,myHero)
end  
--End of Diana functions

--Ahri Functions
function AhriQ(target)
	if target ~= nil and GetDistance(myHero, target) < 800 then
		CastSpellXYZ('Q',GetFireahead(target,1,17))
	end
end

function AhriW(target)
	if target ~= nil and GetDistance(myHero, target) < 800 then
		CastSpellTarget('W',myHero)
	end
end
function AhriE(target)
	if target ~= nil then 
		local xx,yy,zz = GetFireahead(target,1.6,13)
		if CreepBlock(xx,yy,zz,100)==1 then
			nocreep=0
		else
			nocreep=1
		end
		if target ~= nil and GetDistance(myHero, target) < 975 and CanUseSpell('E')==1 and nocreep==1 then 
		CastSpellXYZ('E',GetFireahead(target,1.6,13))
		end
	end
end
function AhriR(target)
	if target ~= nil and GetDistance(myHero, target) < 950 then
		CastHotkey('SPELLR:WEAKENEMY RANGE=900 OVERSHOOT=-450 FIREAHEAD=1,20')
	end
end
function AhriDraw()
	CustomCircle(975,4,2,myHero)
	CustomCircle(880,3,3,myHero)
	CustomCircle(450,4,1,myHero)
end
--End Ahri Functions

--Akalis Functions
function AkaliQ(target)
	if IsSpellReady("Q") == 1 then
		CastSpellTarget("Q",target)
		lastQ = GetTickCount()
	end
end

function AkaliW(target)
--not used currently
	if IsSpellReady("W") == 1 then
		CastSpellTarget("W",target)
	end
end

function AkaliE(target)
	if IsSpellReady("E") == 1 then
		if IsSpellReady("Q") == 0 then
			CastSpellTarget("E",target)
		end
	end
end

function AkaliR(target)
	if IsSpellReady("R") == 1 then
		CastSpellTarget("R",target)					
	end
end

function AkaliDraw()
	CustomCircle(800,2,3,myHero)
end
--End Akali Functions

--DrMundo Functions
function MundoQ(target)
--Shortened Q distance a tad to ensure hit due to projectile speed+movespeed
	if target ~= nil and GetDistance(myHero, target) < 990 and CreepBlock(myHero.x,myHero.y,myHero.z,GetFireahead(target,2,20)) == 0 then
		CastSpellXYZ('Q',GetFireahead(target,2,20))
	end
end

function MundoW(target)
--Cast W on self if it's ready, it's not toggled, and they're close enough to burn
	if IsSpellReady("W") == 1 and MundoWToggled == false and GetDistance(myHero, target) < 325 then
		CastSpellTarget("W",myHero)
		MundoWToggled = true
	end
--Cast W on self (to toggle off) if the spell is ready, it's on, and they're not close enough to burn.
	if IsSpellReady("W") == 1 and MundoWToggled == true and GetDistance(myHero, target) > 400 then
		CastSpellTarget("W",myHero)
		MundoWToggled = false
	end
end

function MundoE(target)
	if IsSpellReady("E") == 1 and GetDistance(myHero, target) > 325 then
		CastSpellTarget("E",myHero)
	end
end

function MundoR(target)
	if IsSpellReady("R") == 1 then
		CastSpellTarget("R",myHero)					
	end
end

function MundoDraw()
	CustomCircle(1000,2,3,myHero)
end
--End DrMundo Functions

--Graves Functions
function GravesQ()
	if ValidTarget(target) and CanCastSpell("Q") then
		CastSpellXYZ('Q',GetFireahead(target,2,20))
	end
end

function GravesW()
	if CanCastSpell("W") then
		CastSpellXYZ("W",GetFireahead(target,2,20))
	end
end

function GravesR()
	if CanCastSpell("R") then
		CastSpellXYZ('R',GetFireahead(target,2,20))
	end
end	

function GravesDraw()
	CustomCircle(900,2,3,myHero)
end
--End Graves Functions

--Katarina's Functions
function checkSpinning()
        if GetTick() > lastRDagger + 250 then
                spinning = false
        end
end
 
function FindNewObjects()
        for i = 1, objManager:GetMaxNewObjects(), 1 do
                local object = objManager:GetNewObject(i)
                local s=object.charName
                if (s ~= nil) then
                        if (string.find(s,"katarina_daggered") ~= nil) then
                                lastQHit = GetTick()
                        elseif (string.find(s,"katarina_deathLotus_mis.troy") ~= nil) then
                                spinning = true
                                lastRDagger = GetTick()
                        end
                end
        end
end
 
function KatQ(target)
        if IsSpellReady("Q") == 1 and not spinning then
                CastSpellTarget("Q",target)
                lastQ = GetTick()
        end
end
 
function KatW(target)
        if IsSpellReady("W") == 1 and not spinning then
                if (GetTick() - lastQ > 650 or GetTick() - lastQHit < 650) and IsSpellReady("Q") == 0 then
                        CastSpellTarget("W",target)
                end
        end
end
 
function KatE(target)
        if IsSpellReady("E") and not spinning then
                CastSpellTarget("E",target)
        end
end
 
function KatR(target)  
        if IsSpellReady("R") == 1 then
                if IsSpellReady("Q") == 0 and IsSpellReady("W") == 0 and IsSpellReady("E") == 0 then
                        CastSpellTarget("R", target)
                        spinning = true
                end
        end
end
 
function KatarinaDraw()
        CustomCircle(725,2,3,myHero)
end
--End Kat Functions

--Kayle Functions
function HP()
local percent = ((myHero.health / myHero.maxHealth)*100)
local healMe = healPlease
	if IsSpellReady("W") and percent <= healMe then CastSpellTarget("W",myHero) end
end

function Ultibot()
    CLOCK=os.clock()
    local key=112;
    local UltiMe = ultiPlease
    local percent = ((myHero.health / myHero.maxHealth)*100)
    
	if CLOCK-toggle_timer>0.2 then
		toggle_timer=CLOCK
		script_loaded= ((script_loaded+1)%2)
	end
		if (script_loaded==1) then
			if (CLOCK-toggle_timer<1) then
				--DrawText("Press F1 to toggle",5,90,0xFF00EE00);
			end
		else
           -- DrawText("SAVEMEBOT unloaded",5,80,0xFFFFFF00);
            return
        end
		if CanUseSpell("R") and percent <= UltiMe then 
			CastSpellTarget("R",myHero) 
		end
end
--End Kayle Functions

--Rengar Functions
function RengarE()
	if CanCastSpell("E") then
		CastSpellTarget('E',target)
	end
end

function RengarW()
	if CanCastSpell("W")then
		CastSpellTarget("W",target)
	end
end

function RengarQ()
	if CanCastSpell("Q")then
		CastSpellTarget("Q",target)
	end
end

function RengarR()
	if CanCastSpell("R")then
		CastSpellTarget("R",myHero)
	end
end	

function RengarDraw()
	CustomCircle(780,4,3,myHero)
end
--End Rengar Functions

--Sejuani Functions
function SejuaniDraw()
	CustomCircle(1175,4,2,myHero)
	CustomCircle(650,3,3,myHero)
	CustomCircle(350,4,1,myHero)
end
--End Sejuani Functions

--Shen Functions
function ShenE()
	if CanCastSpell("E") then
		CastSpellXYZ('E',GetFireahead(target,2,14))
	end
end
function SaveThemAll()
    for i = 1, objManager:GetMaxHeroes() do
        local ally = objManager:GetHero(i)
		local percent2 = ((ally.health / ally.maxHealth)*100)
    CLOCK=os.clock()
    local key=112;
    local savethemall = saveMeee
    
	if CLOCK-toggle_timer>0.2 then
		toggle_timer=CLOCK
		script_loaded= ((script_loaded+1)%2)
	end
		if (script_loaded==1) then
			if (CLOCK-toggle_timer<1) then
				--DrawText("Press F1 to toggle",5,90,0xFF00EE00);
			end
		else
           -- DrawText("SAVEMEBOT unloaded",5,80,0xFFFFFF00);
            return
        end
		if CanUseSpell("R") and percent2 <= savethemall and ally.team == myHero.team then 
			CastSpellTarget("R",ally) 
		end
                
    end
end
--End Shen Functions

--Tristana Functions
function TristW()
	if CanCastSpell("W") then
		CastSpellXYZ('W',GetFireahead(target,2,12))
	end
end
function TristE()
	if CanCastSpell("E") then
		CastSpellTarget("E",target)
	end
end

function TristR()
	if CanCastSpell("R") then
		CastSpellTarget("R",target)	
	end
end	

function TristDraw()
	CustomCircle(800,2,3,myHero)
end
--End Tristana Functions

--Volibear Functions
function VoliE()
	if CanCastSpell("E") then
		CastSpellXYZ('E',GetFireahead(target,2,20))
	end
end

function VoliQ()
	if CanCastSpell("Q") then
		CastSpellTarget("Q",target)
	end
end

function VoliW()
	if CanCastSpell("W")then
		CastSpellTarget("W",target)
	end
end	

function VoliR()
	if CanCastSpell("R")then
		CastSpellTarget("R",myHero)
	end
end	

function VoliDraw()
	CustomCircle(425,2,3,myHero)
end
--End Volibear Functions

--Xerath Functions
function XerathQ()
	if ValidTarget(target) and CanCastSpell("Q") then
		CastSpellXYZ('Q',GetFireahead(target,1,25))
	end
end

function XerathE()
	if ValidTarget(target) and CanCastSpell("E") then
		CastSpellTarget("E",target)
	end
end

function XerathR()
	if ValidTarget(target) and IsSpellReady("R") == 1 then CastSpellXYZ('R',GetFireahead(target,1,20))
	end
end	

function XerathDraw()
	CustomCircle(600,2,3,myHero)
	CustomCircle(1000,3,3,myHero)
	CustomCircle(1300,4,3,myHero)
end
--End Xerath Functions

--Taric Functions
function taricQspam()
    for i = 1, objManager:GetMaxHeroes() do
        local ally = objManager:GetHero(i)
		local percent3 = ((ally.health / ally.maxHealth)*100)
		local myhp = ((myHero.health / myHero.maxHealth)*100)
		local key=112;
		CLOCK=os.clock()
		local healMe = taricHealMe
		local healThem = taricHealThem
		
    
	if CLOCK-toggle_timer>0.2 then
		toggle_timer=CLOCK
		script_loaded= ((script_loaded+1)%2)
	end
		if (script_loaded==1) then
			if (CLOCK-toggle_timer<1) then
				--DrawText("Press F1 to toggle",5,90,0xFF00EE00);
			end
		else
           -- DrawText("SAVEMEBOT unloaded",5,80,0xFFFFFF00);
            return
        end
		if CanUseSpell("Q") and percent3 <= healThem and ally.team == myHero.team and GetDistance(myHero, ally) <= 750 then 
			CastSpellTarget("Q",ally) 
		end
		if CanUseSpell("Q") and myhp <= healMe then 
			CastSpellTarget("Q",myHero)
		end
                
    end
end

function TaricDraw()
	CustomCircle(200,2,3,myHero)
	CustomCircle(350,3,3,myHero)
	CustomCircle(650,4,3,myHero)
	CustomCircle(750,5,3,myHero)
end

--End Taric Functions

--Brand Functions
function BrandQ(target)
	if target ~= nil and GetDistance(myHero, target) < 900 and targetbuff == 1 then
		CastSpellXYZ('Q',GetFireahead(target,2,16))
			targetbuff = 0
	end
end

function BrandW(target)
	if IsSpellReady("W") and target ~= nil and GetDistance(myHero, target) < 900 then
		CastSpellXYZ('W',GetFireahead(target,3,96))
	end
end

function BrandE(target)
	if IsSpellReady("E") and target ~= nil and GetDistance(myHero, target) < 625 then
		CastSpellTarget("E",target)
	end
end

function BrandR(target)
	if IsSpellReady("R") and target ~= nil and GetDistance(myHero, target) < 750 then
		CastSpellTarget("R",target)					
	end
end

function BrandDraw()
	if myHero.dead == 0 then
		CustomCircle(600,2,3,myHero)
			if target ~= nil then
			CustomCircle(100, 5, 2, target)
		end
	end
end
--End Brand Functions

--Panth Functions
function PanthE()
        target = GetWeakEnemy("PHYS", 600, "NEARMOUSE")
        if target ~= nil then
			AttackTarget(target)
				if CanCastSpell("E") then CastSpellXYZ('E',GetFireahead(target,2,20))
				etimer = GetTickCount() + 825
				end
        end
end

function PanthW()
	if CanCastSpell("W") then
		CastSpellTarget("W",target)
	end
end

--function PanthQ()
--	if target ~= nil and IsSpellReady("Q") then
--		CastSpellTarget("Q",target)	
--	end
--end	

function PanthDraw()
	CustomCircle(600,2,3,myHero)
end

--End Panth Functions

--Talon Functions
function TalonQ(target)
        if target ~= nil and IsSpellReady("Q") then  
                CastSpellTarget("Q",myHero)  
        end
end
 
function TalonW(target)
        if IsSpellReady("W") == 1 then
                CastSpellTarget("W",target)
        end
end
 
function TalonE(target)
        if target ~= nil and GetDistance(myHero, target) < 700 then
                CastSpellTarget('E',target)
        end
end
 
function TalonR(target)
        if IsSpellReady("R") == 1 then
                CastSpellTarget("R",myHero)                                    
        end
end
 
function TalonDraw()
        CustomCircle(600,2,3,myHero) 
end  
--End Talon Functions

--Yorick Functions
function YorickW()
	if CanCastSpell("W") then
		CastSpellXYZ('W',GetFireahead(target,5,0))
	end
end
function YouShallLive()
    for i = 1, objManager:GetMaxHeroes() do
        local ally = objManager:GetHero(i)
		local percent3 = ((ally.health / ally.maxHealth)*100)
		local myhp = ((myHero.health / myHero.maxHealth)*100)
		local key=112;
		CLOCK=os.clock()
		local ghoulthemall = ghoulmeh
		
    
	if CLOCK-toggle_timer>0.2 then
		toggle_timer=CLOCK
		script_loaded= ((script_loaded+1)%2)
	end
		if (script_loaded==1) then
			if (CLOCK-toggle_timer<1) then
				--DrawText("Press F1 to toggle",5,90,0xFF00EE00);
			end
		else
           -- DrawText("SAVEMEBOT unloaded",5,80,0xFFFFFF00);
            return
        end
		if CanUseSpell("R") and percent3 <= ghoulthemall and ally.team == myHero.team and GetDistance(myHero, ally) <= 900 then 
			CastSpellTarget("R",ally) 
		end
		if CanUseSpell("R") and myhp <= ghoulthemall then 
			CastSpellXYZ("R",myHero.x,myHero.y,myHero.z)
		end
               
    end
end
--End Yorick Functions

--Utility Functions
function OnProcessSpell(obj,spell)
	if obj ~= nil and obj.name == myHero.name then
		if string.find(spell.name,"dr_mundo_burning_agony") then
			MundoWToggled = true
		end
	end
	local P1 = spell.startPos
	local P2 = spell.endPos
	local calc = (math.floor(math.sqrt((P2.x-obj.x)^2 + (P2.z-obj.z)^2)))
	
    if obj ~= nil and spell ~= nil and IsHero(obj) then
        printtext("\n"..spell.name)
        if spell.name == "SightWard" then
            local ward = {name="Sight Ward", color=1, sightRange=1350, triggerRange=70, endTick=GetClock()+180000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
            table.insert(wards,ward)
        elseif spell.name == "VisionWard" then
            local ward = {name="Vision Ward", color=4, sightRange=1350, triggerRange=70, endTick=GetClock()+180000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
            table.insert(wards,ward)
        elseif spell.name == "wrigglelantern" then
            local ward = {name="Wriggle's Lantern", color=1, sightRange=1350, triggerRange=70, endTick=GetClock()+180000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
            table.insert(wards,ward)
        elseif spell.name == "ItemMiniWard" then
            local ward = {name="Explorer's Ward", color=3, sightRange=1350, triggerRange=70, endTick=GetClock()+60000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
            table.insert(wards,ward)
        elseif spell.name == "ItemGhostWard" then
            local ward = {name="Ghost Ward", color=1, sightRange=1350, triggerRange=70, endTick=GetClock()+180000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
            table.insert(wards,ward)
        elseif spell.name == "JackInTheBox" then
            local ward = {name="Shaco Box", color=2, sightRange=690, triggerRange=300, endTick=GetClock()+60000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
            table.insert(wards,ward)
        elseif spell.name == "BantamTrap" then
            local ward = {name="Shroom", color=5, sightRange=405, triggerRange=160, endTick=GetClock()+600000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
            table.insert(wards,ward)
        else
            return
        end
    end

	if string.find(obj.name,"Minion_") == nil and string.find(obj.name,"Turret_") == nil then
		if (obj.team ~= myHero.team or (show_allies==1)) and string.find(spell.name,"Basic") == nil then
			for i=1, #skillshotArray, 1 do
				local maxdist
				local dodgeradius
				dodgeradius = skillshotArray[i].radius
				maxdist = skillshotArray[i].maxdistance
				if spell.name == skillshotArray[i].name then
					skillshotArray[i].shot = 1
					skillshotArray[i].lastshot = os.clock()
					if skillshotArray[i].type == 1 then
						skillshotArray[i].p1x = obj.x
						skillshotArray[i].p1y = obj.y
						skillshotArray[i].p1z = obj.z
						skillshotArray[i].p2x = obj.x + (maxdist)/calc*(P2.x-obj.x)
						skillshotArray[i].p2y = P2.y
						skillshotArray[i].p2z = obj.z + (maxdist)/calc*(P2.z-obj.z)
						dodgelinepass(obj, P2, dodgeradius, maxdist)
					elseif skillshotArray[i].type == 2 then
						skillshotArray[i].px = P2.x
						skillshotArray[i].py = P2.y
						skillshotArray[i].pz = P2.z
						dodgelinepoint(obj, P2, dodgeradius)
					elseif skillshotArray[i].type == 3 then
						skillshotArray[i].skillshotpoint = calculateLineaoe(obj, P2, maxdist)
						if skillshotArray[i].name ~= "SummonerClairvoyance" then
							dodgeaoe(obj, P2, dodgeradius)
						end
					elseif skillshotArray[i].type == 4 then
						skillshotArray[i].px = obj.x + (maxdist)/calc*(P2.x-obj.x)
						skillshotArray[i].py = P2.y
						skillshotArray[i].pz = obj.z + (maxdist)/calc*(P2.z-obj.z)
						dodgelinepass(obj, P2, dodgeradius, maxdist)
					elseif skillshotArray[i].type == 5 then
						skillshotArray[i].skillshotpoint = calculateLineaoe2(obj, P2, maxdist)
						dodgeaoe(obj, P2, dodgeradius)
					end
				end
			end
		end
	end
end	

function OnCreateObj(object)
	if (GetDistance(myHero, object)) < 100 and PotConfig.Potion then
		if string.find(object.charName,"FountainHeal") then
			timer=os.clock()
			bluePill = object
		end
	end
	
    local ward = GetWardInfo(object,"OnCreateObj")
    if ward ~= nil then
        table.insert(wards,ward)
    end
    if object.charName == "empty.troy" then 
        for i,ward in ipairs(wards) do
            if GetDistance(ward.pos,object) < 10 then 
                table.remove(wards,i)
            end
        end
    end 

	if CleanseConfig.cleanse then
		if listContains(QSS, object.charName) and (GetDistance(myHero, object)) < 100 then
			GetInventorySlot(3139)
			UseItemOnTarget(3139, myHero)
			GetInventorySlot(3140)
			UseItemOnTarget(3140, myHero)
		end
	
		if listContains(Oranges, object.charName) and CleanseConfig.Gangplank and CanCastSpell("W") then
			CastSpellTarget("W", myHero)
		end
	
		if listContains(Oranges, object.charName) and CleanseConfig.Olaf and CanCastSpell("R") then
			CastSpellTarget("R", myHero)
		end
	
		if listContains(Cleanselist, object.charName) and CleanseConfig.cleansespell then
			CastSummonerCleanse()
		end		
	end
	
	if target ~= nil then
		if object ~= nil then
			if string.find(object.charName,'BrandFireMark') ~= nil then
				targetbuff = 1
			end
			if string.find(object.charName,'Diana_Q_moonlight') ~= nil then
				Moonlight = 1
			end
		end
	end
end

function OnDraw()
	if PotConfig.Potion then
		DrawText("Potion Active", 120, 50, 0xFF00EE00)
	end
	if CleanseConfig.cleanse then
		DrawText("Cleanse On", 120, 60, 0xFF00EE00)
	end
end

function OnLoad()
    for i=1, objManager:GetMaxObjects(), 1 do
        local object = objManager:GetObject(i)
        local ward = {}
        ward = GetWardInfo(object,"OnLoad")
        if ward ~= nil then
            table.insert(wards,ward)
        end
    end
    loaded = true
end

function DrawSphere(radius,thickness,color,x,y,z)
    for j=1, thickness do
        local ycircle = (j*(radius/thickness*2)-radius)
        local r = math.sqrt(radius^2-ycircle^2)
        ycircle = ycircle/1.3
        DrawCircle(x,y+ycircle,z,r,color)
    end
end
for _, Summoner in pairs(Summoners) do
    if myHero.SummonerD == Summoner.Name then
        Summoner.Key = "D"
    elseif myHero.SummonerF == Summoner.Name then
        Summoner.Key = "F"
    end
end

function listContains(list, particleName)
	for _, particle in pairs(list) do
		if particleName:find(particle) then return true end
	end
	return false
end

function WardReveal()
    if loaded == nil then OnLoad() end
    
    for i,ward in ipairs(wards) do
        for j,ward2 in ipairs(wards) do
            if (ward.type == "OnProcessSpell" or ward2.type == "OnProcessSpell") and ward.type ~= ward2.type and GetDistance(ward.pos,ward2.pos) < 100 and math.abs(ward.endTick-ward2.endTick) < 3000 then
                if ward.type == "OnProcessSpell" then table.remove(wards,i)
                elseif ward2.type == "OnProcessSpell" then table.remove(wards,j)
                end
                break
            end
        end
        if ward == nil or GetClock() >= ward.endTick then 
            table.remove(wards,i)
            printtext(ward.name.." removed\n")
        else 
            DrawCircle(ward.pos.x,ward.pos.y,ward.pos.z,ward.triggerRange,ward.color)
            if IsKeyDown(18) == 1 then DrawCircle(ward.pos.x,ward.pos.y,ward.pos.z,ward.sightRange,ward.color) end
            if GetDistance(ward.pos,{x=GetCursorWorldX(),y=GetCursorWorldY(),z=GetCursorWorldZ()}) < 100 then
                local wardText = nil
                if ward.type == "OnProcessSpell" then
                    wardText = ward.name..": "..math.floor(((ward.endTick-GetClock())/1000)+0.5)+1
                elseif ward.type == "OnCreateObj" then
                    wardText = ward.name..": "..math.floor(((ward.endTick-GetClock())/1000)+0.5)
                elseif ward.type == "OnLoad" then
                    wardText = ward.name..": "..math.floor(((ward.endTick-GetClock())/1000)+0.5)
                end
                if wardText ~= nil then
                    DrawText(wardText,GetCursorX()-13,GetCursorY()-17,0xFFFFFFFF)
                end
            end
        end
    end
    
end

function GetWardInfo(object,type)
    if object ~= nil then
        if object.charName == "SightWard" and object.name == "SightWard" then
            return {name="Sight Ward", color=1, sightRange=1350, triggerRange=70, endTick=GetClock()+object.mana*1000, type=type, pos={x=object.x,y=object.y,z=object.z}}
        elseif object.charName == "VisionWard" and object.name == "VisionWard" then
            return {name="Vision Ward", color=4, sightRange=1350, triggerRange=70, endTick=GetClock()+object.mana*1000, type=type, pos={x=object.x,y=object.y,z=object.z}}
        elseif object.charName == "VisionWard" and object.name == "SightWard" then
            if object.maxMana == 180 then
                return {name="Explorer's or Ghost Ward", color=1, sightRange=1350, triggerRange=70, endTick=GetClock()+object.mana*1000, type=type, pos={x=object.x,y=object.y,z=object.z}}
            elseif object.maxMana == 60 then
                return {name="Explorer's Ward", color=3, sightRange=1350, triggerRange=70, endTick=GetClock()+object.mana*1000, type=type, pos={x=object.x,y=object.y,z=object.z}}
            else
                return {name="Explorer's or Ghost Ward", color=1, sightRange=1350, triggerRange=70, endTick=GetClock()+object.mana*1000, type=type, pos={x=object.x,y=object.y,z=object.z}}
            end
        elseif object.charName == "Jack In The Box" then
            return {name="Shaco Box", color=2, sightRange=690, triggerRange=300, endTick=GetClock()+object.mana*1000, type=type, pos={x=object.x,y=object.y,z=object.z}}
        elseif object.charName == "Noxious Trap" then
            return {name="Shroom", color=5, sightRange=405, triggerRange=160, endTick=GetClock()+object.mana*1000, type=type, pos={x=object.x,y=object.y,z=object.z}}
        end
    end
    return nil
end

function IsHero(obj)
    for i=1, objManager:GetMaxHeroes(), 1 do
        local hero = objManager:GetHero(i)
        if hero ~= nil and obj.team == hero.team and obj.charName == hero.charName then return true end
    end
end

function CastSummonerCleanse()
    if Summoners.Cleanse.Key ~= nil then
        CastSpellTarget(Summoners.Cleanse.Key, myHero)
    end
end

function zh()
	if GetInventorySlot(3157)~=nil then 
		k = GetInventorySlot(3157)
		CastSpellTarget(tostring(k),myHero)
	elseif GetInventorySlot(3090)~=nil then 
		k = GetInventorySlot(3090)
		CastSpellTarget(tostring(k),myHero)
	end
end

function Zhonyas()
	if ItemConfig.zh then 
		if target~=nil and myHero.health<myHero.maxHealth*15/100 then
			zh()
		end
	end
end

function se()
	if GetInventorySlot(3040)~=nil then 
		k = GetInventorySlot(3040)
		CastSpellTarget(tostring(k),myHero)
	end
end

function SeraphsEmbrace()
	if ItemConfig.se then 
		if target~=nil and myHero.health<myHero.maxHealth*15/100 then
			se()
		end
	end
end

function HealBarrier()
	if HealConfig.On then On() end
end
    
function On()
		local HP = (myHero.maxHealth *(.25))
		local HPB = (myHero.maxHealth *(.20))
		if myHero.health < HP and target~=nil and myHero.SummonerF == "SummonerHeal" then
				CastSpellTarget("F",myHero)
 
		elseif myHero.health < HP and target~=nil and myHero.SummonerD == "SummonerHeal" then
				CastSpellTarget("D",myHero)
		end
	   
		if myHero.health < HPB and target~=nil and myHero.SummonerF == "SummonerBarrier" then
				CastSpellTarget("F",myHero)
		elseif myHero.health < HPB and target~=nil and myHero.SummonerD == "SummonerBarrier" then
				CastSpellTarget("D",myHero)
		end
end    

function usePotion()
	GetInventorySlot(2003)
	UseItemOnTarget(2003,iHero)
end

function useFlask()
	GetInventorySlot(2041)
	UseItemOnTarget(2041,iHero)
end

function useBiscuit()
	GetInventorySlot(2009)
	UseItemOnTarget(2009,iHero)
end

function useElixir()
	GetInventorySlot(2037)
	UseItemOnTarget(2037,iHero)
end

function GetTick()
	return GetClock()
end

function RedElixir()
	if PotConfig.Potion and bluePill == nil then
		if iHero.health < iHero.maxHealth * PotConfig.PotionValue and PotConfig.HpPotion and GetClock() > wUsedAt + 15000 then
			usePotion()
			wUsedAt = GetTick()
		elseif iHero.health < iHero.maxHealth * PotConfig.FlaskValue and PotConfig.Flask and GetClock() > vUsedAt + 10000 then 
			useFlask()
			vUsedAt = GetTick()
		elseif iHero.health < iHero.maxHealth * PotConfig.BiscuitValue and PotConfig.Biscuit then
			useBiscuit()
		elseif iHero.health < iHero.maxHealth * PotConfig.ElixirValue and PotConfig.Elixir then
			useElixir()
		end
	end
	if (os.clock() < timer + 5000) then
		bluePill = nil 
	end
end

function Level_Spell(letter)  
     if letter == Q then send.key_press(0x69)
     elseif letter == W then send.key_press(0x6a)
     elseif letter == E then send.key_press(0x6b)
     elseif letter == R then send.key_press(0x6c) end
end

function IsLolActive()
    return tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client"
end

function Dodge()
	if IsLolActive() then
		Skillshots()
			if blockAndMove ~= nil then blockAndMove() end
		send.tick()
	end
end

function CreateBlockAndMoveToXYZ(x, y, z)
    print('CreateBlockAndMoveToXYZ', x, y, z)
    local move_start_time, move_dest, move_pending
    send.block_input(true,1000,MakeStateMatch)
    move_start_time = os.clock()
    move_dest = {x=x, y=y, z=z}
    move_pending = true
    MoveToXYZ(move_dest.x, 0, move_dest.z)
    run_once = false
    return function()
        if move_pending then
            printtext('.')
            local waited_too_long = move_start_time + 1 < os.clock()    
            if waited_too_long or GetDistance(move_dest)<50 then
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
                -- up before, up after, down during, we don't care
            end            
        else -- went up
            if is_down then
                -- down before, down after, up during, we don't care
            else
                send.wait(60)
                send.key_up(scode)
                send.wait(60)
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
	dodgex = pos2.x + ((radius+100)/calc)*(myHero.x-pos2.x)
	dodgez = pos2.z + ((radius+100)/calc)*(myHero.z-pos2.z)
	if calc < radius and DodgeConfig.dodgeskillshot == true then
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
	dodgex = x4 + ((radius+100)/calc3)*(myHero.x-x4)
	dodgez = z4 + ((radius+100)/calc3)*(myHero.z-z4)
	if perpendicular < radius and calc1 < calc4 and calc2 < calc4 and DodgeConfig.dodgeskillshot == true then
		blockAndMove = CreateBlockAndMoveToXYZ(dodgex,0,dodgez)
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
	dodgex = x4 + ((radius+100)/calc3)*(myHero.x-x4)
	dodgez = z4 + ((radius+100)/calc3)*(myHero.z-z4)
	if perpendicular < radius and calc1 < calc4 and calc2 < calc4 and DodgeConfig.dodgeskillshot == true then
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

function Skillshots()
	cc=cc+1
	if (cc==30) then
		LoadTable()
	end
	if DodgeConfig.drawskillshot == true then
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

function AutoLevelSpells()
    if IGERsLvlSpells.autoLevelSpells and IsLolActive() and IsChatOpen() == 0 then
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
    end
    send.tick()
end

if myHero.name == "Olaf" then
	CleanseConfig:addParam("Olaf", "Olaf", SCRIPT_PARAM_ONOFF, true)
end
if myHero.name == "Gangplank" then
	CleanseConfig:addParam("Gangplank", "Gangplank", SCRIPT_PARAM_ONOFF, true) 
end	

function potion() --Thank you kyuuketsuuki for this, you're an amazing scripter.
	if AIOConfig.Potion and bluePill == nil then
		if iHero.health < iHero.maxHealth * AIOConfig.PotionValue and AIOConfig.HpPotion and GetClock() > waUsedAt + 15000 then
			usePotion()
			waUsedAt = GetTick()
		elseif iHero.health < iHero.maxHealth * AIOConfig.FlaskValue and AIOConfig.Flask and GetClock() > vUsedAt + 10000 then 
			useFlask()
			vUsedAt = GetTick()
		elseif iHero.health < iHero.maxHealth * AIOConfig.BiscuitValue and AIOConfig.Biscuit then
			useBiscuit()
		end
	end
	if (os.clock() < timer + 5000) then
		bluePill = nil 
	end
end

function UtilityFunction()
	AutoLevelSpells()
	RedElixir()
	HealBarrier()
	Zhonyas()
	SeraphsEmbrace()
	Dodge()
	WardReveal()
end

function Killsteals()
	if myHero.name == "Akali" and AIOConfig.KSteal then
	CastHotkey("SPELLR:WEAKENEMY ONESPELLHIT=((spellr_level*75)+25+((player_ap*5)/10))")
	end
	if myHero.name == "Brand" and AIOConfig.KSteal then
	CastHotkey("SPELLE:WEAKENEMY ONESPELLHIT=((spelle_level*35)+35+((player_ap*55)/100))")
	end
	if myHero.name == "Diana" and AIOConfig.KSteal then
	CastHotkey("SPELLR:WEAKENEMY ONESPELLHIT=((spellr_level*60)+40+((player_ap*6)/10))")
	end
	if myHero.name == "DrMundo" and AIOConfig.KSteal then
	CastHotkey("SPELLQ:WEAKENEMY ONESPELLHIT=#(((spellq_level*50)+30)>((target_hp*((spellq_level*3)/100))+((target_hp*12)/100))")
	end
	if myHero.name == "Gragas" and AIOConfig.KSteal then
	CastHotkey("SPELLE:WEAKENEMY ONESPELLHIT=((spelle_level*40)+40+((player_ap*5)/10)+((player_ad*66/100))")
	end
	if myHero.name == "Graves" and AIOConfig.KSteal then
	CastHotkey("SPELLQ:WEAKENEMY ONESPELLHIT=((spellq_level*35)+25+((player_ad*8)/10))")
	end
	if myHero.name == "Katarina" and AIOConfig.KSteal and not spinning then
        if lastHotkey == 3 then
                CastHotkey("SPELLE:WEAKENEMY ONESPELLHIT=#((spellq_ready)*(((spellq_level*30)+30+((player_ap*45)/100))-1)+(spelle_ready)*(((spelle_level*25)+15+((player_ap*4)/10))-1)+(spellw_ready)*(((spellw_level*35)+5+((player_ap*25)/100)+((player_ad*6)/10))-1)+(spell4_ready)*(((target_hpmax*15)/100)-1)+(spell3_ready)*(300+((player_ap*4)/10))) RANGE=700 NOSHOW")
                lastHotkey = 1
                return
        elseif lastHotkey == 1 then
                CastHotkey("SPELLW:WEAKENEMY ONESPELLHIT=#((spellq_ready)*(((spellq_level*30)+30+((player_ap*45)/100))-1)+(spelle_ready)*(((spelle_level*25)+15+((player_ap*4)/10))-1)+(spellw_ready)*(((spellw_level*35)+5+((player_ap*25)/100)+((player_ad*6)/10))-1)+(spell4_ready)*(((target_hpmax*15)/100)-1)+(spell3_ready)*(300+((player_ap*4)/10))) RANGE=375 NOSHOW")
                lastHotkey = 2
                return
        elseif lastHotkey == 2 then
                CastHotkey("SPELLQ:WEAKENEMY ONESPELLHIT=#((spellq_ready)*(((spellq_level*30)+30+((player_ap*45)/100))-1)+(spelle_ready)*(((spelle_level*25)+15+((player_ap*4)/10))-1)+(spellw_ready)*(((spellw_level*35)+5+((player_ap*25)/100)+((player_ad*6)/10))-1)+(spell4_ready)*(((target_hpmax*15)/100)-1)+(spell3_ready)*(300+((player_ap*4)/10))) RANGE=675 NOSHOW")
                lastHotkey = 3
                return
        end
        end

	if myHero.name == "Kayle" and AIOConfig.KSteal then
	CastHotkey("SPELLQ:WEAKENEMY ONESPELLHIT=((spellq_level*50)+10+player_ap+player_bonusad)")
	end
	if myHero.name == "Leblanc" and AIOConfig.KSteal then
	CastHotkey("SPELLQ:WEAKENEMY ONESPELLHIT=((spellq_level*40)+30+((player_ap*60)/100))")
	end
	if myHero.name == "Pantheon" and AIOConfig.KSteal then
	CastHotkey("SPELLQ:WEAKENEMY ONESPELLHIT=((spellq_level*40)+25+((player_bonusad*14)/10))")
	end
	if myHero.name == "Rengar" and AIOConfig.KSteal then
	CastHotkey("SPELLE:WEAKENEMY ONESPELLHIT=((spelle_level*45)+10+((player_bonusad*7)/10))")
	end
	if myHero.name == "Talon" and AIOConfig.KSteal then
	CastHotkey("SPELLW:WEAKENEMY ONESPELLHIT=((spellw_level*50)+10+((player_bonusad*12)/10))")
	end
	if myHero.name == "Tristana" and AIOConfig.KSteal then
	CastHotkey("SPELLR:WEAKENEMY ONESPELLHIT=((spellr_level*100)+200+((player_ap*15)/10))")
	end
	if myHero.name == "Volibear" and AIOConfig.KSteal then
	CastHotkey("SPELLW:WEAKENEMY COOLDOWN RANGE=400 ONESPELLHIT=#((35+45*spellw_level+(player_hpmax-440-(1548*player_level/18))*15/100)*(2-target_hp/target_hpmax)) PHYSICAL LEASTHP")
	end
	if myHero.name == "Xerath" and AIOConfig.KSteal then
	CastHotkey("SPELLQ:WEAKENEMY ONESPELLHIT=((spellq_level*40)+35+((player_ap*6)/10))")
	end
end
--End functions

--Begin Champ Specific Menu Configs
AIOConfig = scriptConfig("AIO Collective", "AIOConfig")
if myHero.name == "Ahri" then
	AIOConfig:addParam("AhriCombo", "Ahri Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	AIOConfig:addParam("AhriHarass", "Ahri Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
end
if myHero.name == "Akali" then
	AIOConfig:addParam("AkaliCombo", "Akali Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
end
if myHero.name == "Brand" then
	AIOConfig:addParam("BrandCombo", "Brand Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	AIOConfig:addParam("BrandHarass", "Brand Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
end
if myHero.name == "Diana" then
	AIOConfig:addParam("DianaCombo", "Diana Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	AIOConfig:addParam("DianaHarass", "Diana Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
end
if myHero.name == "DrMundo" then
	AIOConfig:addParam("MundoCombo", "Mundo Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
end
if myHero.name == "Gragas" then
	AIOConfig:addParam("GragasCombo", "Gragas Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	AIOConfig:addParam("GragasHarass", "Gragas Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
end
if myHero.name == "Graves" then
	AIOConfig:addParam("GravesCombo", "Graves Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	AIOConfig:addParam("GravesHarass", "Graves Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
end
if myHero.name == "Katarina" then
        AIOConfig:addParam("KatCombo", "Kat Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
end
if myHero.name == "Kayle" then
	AIOConfig:addParam("KayleCombo", "Kayle Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
end
if myHero.name == "Leblanc" then
	AIOConfig:addParam("LeBlancCombo", "LeBlanc Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	AIOConfig:addParam("LeBlancHarass", "LeBlanc Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
end
if myHero.name == "Pantheon" then
	AIOConfig:addParam("PantheonCombo", "Pantheon Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
end
if myHero.name == "Rengar" then
	AIOConfig:addParam("RengarCombo", "Rengar Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	AIOConfig:addParam("RengarHarass", "Rengar Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
end
if myHero.name == "Sejuani" then
	AIOConfig:addParam("SejuaniCombo", "Sejuani Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	AIOConfig:addParam("SejuaniHarrass", "Sejuani Harrass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
end
if myHero.name == "Shen" then
	AIOConfig:addParam("ShenCombo", "Shen Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
end
if myHero.name == "Talon" then
	AIOConfig:addParam("TalonCombo", "Talon Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	AIOConfig:addParam("TalonHarass", "Talon Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
end
if myHero.name == "Taric" then
	AIOConfig:addParam("TaricCombo", "Taric Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	AIOConfig:addParam("TaricHarass", "Taric Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
end
if myHero.name == "Tristana" then
	AIOConfig:addParam("TristanaCombo", "Tristana Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	AIOConfig:addParam("TristanaHarass", "Tristana Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
end
if myHero.name == "Volibear" then
	AIOConfig:addParam("VolibearCombo", "Volibear Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	AIOConfig:addParam("VolibearHarass", "Volibear Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
end
if myHero.name == "Xerath" then
	AIOConfig:addParam("XerathCombo", "Xerath Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	AIOConfig:addParam("XerathHarass", "Xerath Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
end
if myHero.name == "Yorick" then
	AIOConfig:addParam("YorickCombo", "Yorick Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
end
--End Champ Specific menu options

--Begin Generic menus
AIOConfig:addParam("KSteal", "Killsteal", SCRIPT_PARAM_ONOFF, true)

DodgeConfig = scriptConfig("Dodge Config", "Dodgeconf")
DodgeConfig:addParam("drawskillshot", "Draw Skillshots", SCRIPT_PARAM_ONOFF, true)
DodgeConfig:addParam("dodgeskillshot", "Dodge (and block input)", SCRIPT_PARAM_ONOFF, true)

IGERsLvlSpells = scriptConfig("IGERsAutoLevelSpells","IGERs AutoLevelSpells")
IGERsLvlSpells:addParam("autoLevelSpells", "[Default: Num2]AutoLevelSpells", SCRIPT_PARAM_ONKEYTOGGLE, true, 98)

PotConfig = scriptConfig("AutoPot Config", "Pot")
PotConfig:addParam("Potion", "Script Toggle", SCRIPT_PARAM_ONKEYTOGGLE, true, 117)
PotConfig:addParam("HpPotion", "Potion Toggle", SCRIPT_PARAM_ONOFF, true)
PotConfig:addParam("Flask", "Flask Toggle", SCRIPT_PARAM_ONOFF, true)
PotConfig:addParam("Biscuit", "Biscuit Toggle", SCRIPT_PARAM_ONOFF, true)
PotConfig:addParam("Elixir", "Elixir Toggle", SCRIPT_PARAM_ONOFF, true)
PotConfig:addParam("PotionValue", "Potion Trigger HP", SCRIPT_PARAM_NUMERICUPDOWN, 0.75, 103, 0, 1, .1)
PotConfig:addParam("FlaskValue", "Flask Trigger HP", SCRIPT_PARAM_NUMERICUPDOWN, 0.74, 100, 0, 1, .1)
PotConfig:addParam("BiscuitValue", "Biscuit Trigger HP", SCRIPT_PARAM_NUMERICUPDOWN, 0.60, 97, 0, 1, .1)
PotConfig:addParam("ElixirValue", "Elixir Trigger HP", SCRIPT_PARAM_NUMERICUPDOWN, 0.30, 96, 0, 1, .1)

HealConfig = scriptConfig("AutoHealBarrier Config", "HealBarconf")
HealConfig:addParam("On", "Auto Heal & Barrier", SCRIPT_PARAM_ONKEYTOGGLE, true, 48)

CleanseConfig = scriptConfig("Cleanse Config", "CleanseMenu")
CleanseConfig:addParam("cleanse", "Use QSS and Cleanse?", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("C"))
CleanseConfig:addParam("cleansespell", "Use Cleanse Summoner?", SCRIPT_PARAM_ONOFF, true)

ItemConfig = scriptConfig("Item Config", "Item")
ItemConfig:addParam('zh', 'Zhonyas', SCRIPT_PARAM_ONOFF, true)
ItemConfig:addParam('se', 'Seraphs Embrace', SCRIPT_PARAM_ONOFF, true)

SetTimerCallback("OnTick")
SetTimerCallback("potion")