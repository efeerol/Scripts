require 'Utils'
require 'spell_damage'
require 'winapi'
require 'SKeys'

local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local ui = require 'simpleui'
local draw = require 'simpleui_drawing'
local version = '1.0'
local target,targetq,target2
local ball = nil
local qx,qy,qz,vst,vse,deconce,pdot,ddot,edot=0,0,0,0,0,0,0,0,0
local hero_table = {}
local zv = Vector(0,0,0)
local amax_heroes = 0
local spellShot = {shot = false, radius = 0, time = 0, shotX = 0, shotZ = 0, shotY = 0, safeX = 0, safeY = 0, safeZ = 0, isline = false}
local startPos = {x=0, y=0, z=0}
local endPos = {x=0, y=0, z=0}

local ParticleNames = {    
	{charName= "Oriana_Ghost_mis.troy"},
	{charName= "Oriana_Izuna_nova.troy"},
	{charName= "TheDoomBall"},
	{charName= "oriana_ball_glow_green.troy"},
	{charName= "yomu_ring_green.troy"},
	{charName= "Oriana_Ghost_mis_protect.troy"},
	{charName= "OrianaProtectShield.troy"},
	{charName= "Orianna_Ball_Flash_Reverse.troy"}
}

function OriRun()
	if IsChatOpen() == 0 and tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client" and myHero.name == "Orianna" then
	velocity()
	GetWeakAlly()
	SetVariables()
	target2 = GetWeakEnemy('MAGIC',1500)
	targetq = GetWeakEnemy('MAGIC',800)
	if GetTickCount() - spellShot.time > 0 then
		spellShot.shot = false
		spellShot.time = 0
		shotMe = false
	end
	
	if OriConfig.ball and targetq ~= nil then Ball() end
	if OriConfig.AutoW then	AutoW() end
	if OriConfig.Reposition then Reposition() end
	if OriConfig.UseE then UseE() end	
	if OriConfig.UseR then UseR() end	
end
end
	
	OriConfig, menu = uiconfig.add_menu('Ori Config', 200)
	menu.keydown('UseR', 'UseR', Keys.R)
	menu.keydown('UseE', 'UseE', Keys.E)
    menu.keytoggle('ball', 'Ball', Keys.X, false)
	menu.keytoggle('AutoW', 'AutoW', Keys.F1, true)
	menu.keytoggle('Reposition', 'AutoRepositionBall', Keys.F2, true)
	menu.keytoggle('AutoShield', 'AutoShield', Keys.F3, true)
	menu.permashow('UseR')
	menu.permashow('ball')
	menu.permashow('AutoW')
	menu.permashow('Reposition')
	menu.permashow('AutoShield')

function SetVariables()
	if myHero.SpellTimeQ > 1.0 then
	QRDY = 1
	else QRDY = 0
	end
	if myHero.SpellTimeW > 1.0 then
	WRDY = 1
	else WRDY = 0
	end
	if myHero.SpellTimeE > 1.0 then
	ERDY = 1
	else ERDY = 0
	end
	if myHero.SpellTimeR > 1.0 then
	RRDY = 1
	else RRDY = 0
	end
end

function Ball()
	local bq = bestcoords(targetq)
	local vts = hero_table[targetq.name][3]
    if ball ~= nil and QRDY == 1 and GetDistance(myHero, targetq) < 800 and GetDistance(ball, targetq) < 800 then
        if  bq == 1  and vts:len() ~= 0 then
            CastSpellXYZ("Q",qx, qy, qz)
        elseif bq == 1 and vts:len() == 0 then
            CastSpellXYZ("Q",qx, qy, qz)
        end
    elseif QRDY == 1 and GetDistance(myHero, targetq) < 800 and bq == 0 then
		CastSpellXYZ("Q",GetFireahead(targetq,1.6,12))
	end
end

function AutoW()
	if targetq ~= nil then
			if WRDY == 1 and ball ~= nil and GetDistance(ball,targetq) < 200 then
				CastSpellXYZ('W',myHero.x,0,myHero.z)
			end
	end
end

function Reposition()
	if ERDY == 1 and target2 ~= nil and ball ~= nil and GetDistance(ball,target2) > 800 then
		CastSpellXYZ('E',myHero.x,0,myHero.z)
	end
end

function UseR()
	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) then
			if RRDY == 1 and ball ~= nil and GetDistance(ball,enemy) < 250 then
				CastSpellXYZ('R',myHero.x,0,myHero.z)
			end
		end
	end
end

function UseE()
	CastHotkey("AUTO 100,0 SPELLE:WEAKALLY RANGE=800 COOLDOWN")
end
		
function declare2darray()
    amax_heroes=objManager:GetMaxHeroes()
    if amax_heroes > 1 then
        for i = 1,amax_heroes, 1 do
            local h=objManager:GetHero(i)
            local name=h.name
            hero_table[name]={}
            hero_table[name][0] = 0
            hero_table[name][1] = zv
            hero_table[name][2] = 0
            hero_table[name][3] = zv
        end
    end
end

function velocity()
    local max_heroes=objManager:GetMaxHeroes()
    if max_heroes > amax_heroes then declare2darray() end
    local timedif = 0
    local cordif = Vector(0,0,0)   
    for i = 1,max_heroes, 1 do
        local h=objManager:GetHero(i)
        local name=h.name
        if hero_table[name] ~= nil then
            timedif = GetClock() - hero_table[name][0]
            cordif = Vector(h.x,h.y,h.z) - hero_table[name][1]
            hero_table[name][3] = Vector(round(cordif.x/timedif,7),round(cordif.y/timedif,7),round(cordif.z/timedif,7))
            hero_table[name][0]    = GetClock()
            hero_table[name][1]    = Vector(h.x,h.y,h.z)
        end
    end
end

function bestcoords(btarget)
	if ball ~= nil then
		local x1,y1,z1 = GetFireahead(btarget,1.6,12)
		local ve= Vector(x1 - btarget.x,y1 - btarget.y,z1 - btarget.z) -- getfireahead - target
		local nb = btarget.name
		local vvt = hero_table[nb][3] -- velocity vector of target
		if ball.x ~= nil then
			vst = Vector(btarget.x - ball.x,btarget.y-ball.y,btarget.z - ball.z) -- target - ball
			vse = Vector(x1-ball.x,y1-ball.y,z1-ball.z) -- getfireahead - ball
		elseif ball.x == nil then
			vst = Vector(btarget.x - myHero.x,btarget.y-myHero.y,btarget.z - myHero.z) -- target - ball
			vse = Vector(x1-myHero.x,y1-myHero.y,z1-myHero.z) -- getfireahead - ball
		end
		local speedratio = (btarget.movespeed / vvt:len())
		if vvt:len() ~= 0 then
			local vstn = vst:normalized()
			local vvtn = vvt:normalized()
			local ven = ve:normalized()
			local vsen = vse:normalized()
			ddot = math.abs(vsen:dotP(ven))
			edot = math.abs(vvtn:dotP(ven))
			pdot = math.abs(vstn:dotP(vvtn))    
			if (pdot > 0.75 and ddot > 0.75 and edot > 0.95 and vst:len() < 1450) then
				qx=x1
				qy=y1
				qz=z1
				return 1
			end
		elseif ball ~= nil and vvt:len() == 0 and vst:len() < 1485 then
				qx=btarget.x
				qy=btarget.y
				qz=btarget.z
				return 1
		else
			return 0
		end
	end
	return 0
end

function OnCreateObj(object)
	if object ~= nil then       
		for _, particle in pairs(ParticleNames) do
			if object.charName == particle.charName then
				ball = object
			end
		end
	end
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function OnDraw()
	if ball ~= nil then
		CustomCircle(250,10,2,ball)
	end
	if ball == nil then
		CustomCircle(250,10,2,myHero)
	end
		CustomCircle(800,1,2,myHero)
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

function OnProcessSpell(unit,spell)
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
end

function autoShield(target)
	if ERDY == 1 then
		CastSpellTarget("E",target)
	end
end

function GetWeakAlly()
	local maxHealth = 9999
	target = nil
	for i=1, objManager:GetMaxHeroes(), 1 do
	local object = objManager:GetHero(i)
		if object ~= nil and object.team == myHero.team and GetDistance(object) < 1100 and object.charName ~= myHero.charName then
			if object.health < maxHealth then
				maxHealth = object.health
				target = object;
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

SetTimerCallback("OriRun")
print("\nVal's Ori v"..version.."\n")