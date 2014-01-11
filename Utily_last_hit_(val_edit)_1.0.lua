require 'Utils'
require 'winapi'
require 'SKeys'
require 'spell_damage'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local version = '1.0'

local HavocDamage = 0
local ExecutionerDamage = 0
local True_Attack_Damage_Against_Minions = 0
local Range = myHero.range + GetDistance(GetMinBBox(myHero))
local SORT_CUSTOM = function(a, b) return a.maxHealth and b.maxHealth and a.maxHealth < b.maxHealth end
local Target, M_Target
local TEAM
if myHero.team == 100 then
	TEAM = "Blue"
else
	TEAM = "Red"
end
local MinionInfo = { }
MinionInfo[TEAM.."_Minion_Basic"] 		= 	{ aaDelay = 400, projSpeed = 0		}
MinionInfo[TEAM.."_Minion_Caster"] 		=	{ aaDelay = 484, projSpeed = 0.68	}
MinionInfo[TEAM.."_Minion_Wizard"]		=	{ aaDelay = 484, projSpeed = 0.68	}
MinionInfo[TEAM.."_Minion_MechCannon"] 	=	{ aaDelay = 365, projSpeed = 1.18	}
local Minions = { }
local aaDelay = 0
local aaPos = {x = 0, z = 0}
local Ping = 0
local IncomingDamage = { }
local AnimationBeginTimer = 0
local AnimationSpeedTimer = 0.1 * (1 / myHero.attackspeed)
local TimeToAA = os.clock()

function Main()
	Mastery_Damage()
	if CfgControls.PassiveFarm then Farm() end
end

	CfgControls, menu = uiconfig.add_menu('Farming Controls', 200)
	menu.keydown('PassiveFarm', 'Farm', Keys.C)
	menu.permashow('PassiveFarm')
	
	CfgMasteries, menu = uiconfig.add_menu('Mastery Settings', 200)
	menu.slider('Butcher_Mastery', 'Butcher', 0, 2, 2, nil, true)
	menu.slider('Havoc_Mastery', 'Havoc', 0, 3, 3, nil, true)
	menu.slider('Brute_Force_Mastery', 'Brute Force', 0, 2, 0, nil, true)
	menu.checkbutton('Spellsword_Mastery', 'Spellsword', true)
	menu.checkbutton('Executioner_Mastery', 'Executioner', true)
	
function Mastery_Damage()
	local Mast_ButcherDMG = 0
	local Mast_BruteForceDMG = 0
	local Mast_SpellswordDMG = 0
	if CfgMasteries.Butcher_Mastery > 0 then
		Mast_ButcherDMG = CfgMasteries.Butcher_Mastery
	end
	if CfgMasteries.Brute_Force_Mastery then
		if CfgMasteries.Brute_Force_Mastery == 1 then
			Mast_BruteForceDMG = 1.5
		end
		if CfgMasteries.Brute_Force_Mastery == 2 then
			Mast_BruteForceDMG = 3
		end
	end
	if CfgMasteries.Spellsword_Mastery then
		Mast_SpellswordDMG = myHero.ap * .05
	end
	if CfgMasteries.Havoc_Mastery then
		if CfgMasteries.Havoc_Mastery == 1 then
			HavocDamage = 0.0067
		end
		if CfgMasteries.Havoc_Mastery == 2 then
			HavocDamage = 0.0133
		end
		if CfgMasteries.Havoc_Mastery == 3 then
			HavocDamage = 0.02
		end
	end
	if CfgMasteries.Executioner_Mastery then
		ExecutionerDamage = .05
	end
	True_Attack_Damage_Against_Minions = (myHero.baseDamage + myHero.addDamage + Mast_BruteForceDMG + Mast_SpellswordDMG)+((myHero.baseDamage + myHero.addDamage + Mast_BruteForceDMG + Mast_SpellswordDMG)*(HavocDamage + ExecutionerDamage))
end

function Farm()
	Minions = GetEnemyMinions(SORT_CUSTOM)
	AnimationSpeedTimer = 0.085 * (1 / myHero.attackspeed)
	
	for i, Minion in pairs(Minions) do
		if Minion ~= nil then
			local PredictedDamage = 0
			local aaTime = Ping + aaDelay + ( GetDistance(myHero, Minion) / GetAAData()[myHero.name].projSpeed )
			
			for k, DMG in pairs(IncomingDamage) do
				if DMG ~= nil then
					if (DMG.Source == nil or DMG.Source.dead or DMG.Target == nil or DMG.Target.dead) or (DMG.Source.x ~= DMG.aaPos.x or DMG.Source.z ~= DMG.aaPos.z) then
						IncomingDamage[k] = nil
					elseif Minion == DMG.Target then
						DMG.aaTime = (DMG.projSpeed == 0 and (DMG.aaDelay) or (DMG.aaDelay + GetDistance(DMG.Source, Minion) / DMG.projSpeed))
						if GetTickCount() >= (DMG.Start + DMG.aaTime) then
							IncomingDamage[k] = nil
						elseif GetTickCount() + aaTime > (DMG.Start + DMG.aaTime) then
							PredictedDamage = PredictedDamage + DMG.Damage
						end
					end
				end
			end
				
			if Minion.dead == 0 and Minion.health - PredictedDamage <= True_Attack_Damage_Against_Minions and Minion.health - PredictedDamage > 0 and GetDistance(Minion, myHero) < Range then
				if os.clock() > TimeToAA then AttackTarget(Minion)
					CustomCircle(100, 1, 2, Minion)
				end
			end
		end
	end
	if os.clock() > (AnimationBeginTimer + AnimationSpeedTimer) then MoveMouse() end
	CustomCircle(Range, 1, 4, myHero)
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

function MoveMouse()
	local moveSqr = math.sqrt((mousePos.x - myHero.x)^2+(mousePos.z - myHero.z)^2)
	local moveX = myHero.x + 300*((mousePos.x - myHero.x)/moveSqr)
	local moveZ = myHero.z + 300*((mousePos.z - myHero.z)/moveSqr)
	MoveToXYZ(moveX,0,moveZ)
end

SetTimerCallback('Main')