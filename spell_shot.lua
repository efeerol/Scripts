--[[
    Spell Shot Library 1.2 by Chad Chen        
    			
    			This script is modified from lopht's skillshots.  		
                    
    -------------------------------------------------------
            Usage:
            
            			require "spell_shot"
            			
            			function OnProcessSpell(unit,spell)
            				local spellShot = SpellShotTarget(unit, spell, myHero)
            				if spellShot ~= nil and spellShot.shot then
            					--When shot is true, this spell will hit target.
            				end
            			end
--]]

require 'Utils'

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