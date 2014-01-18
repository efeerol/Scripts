require "Utils"
printtext("\nStun Detector\n")

local X = 10
local Y = 120
local DetectionRange = 2500
local basicthickness = 10
local radius = 60
local objTable = {}
local allObjects = {}
local objCount0 = objManager:GetMaxObjects()
local found = 0

function StunRun()
StunDraw()
end

function StunDraw()
	local stunChamps = 0
	local amountCC = 0
	for i = 1, objManager:GetMaxHeroes()  do
	local target = objManager:GetHero(i)
		if (target ~= nil and target.team ~= myHero.team and target.visible == 1 and target.dead == 0) and GetDistance(myHero,target) < DetectionRange then
			local targetCC = GetTargetCC("HardCC",target)
			if targetCC > 0 then
				stunChamps = stunChamps+1
				amountCC = amountCC+targetCC
				if target.visible then
					thickness = basicthickness*targetCC
					for j=1, thickness do
						local ycircle = (j*(radius/thickness*2)-radius)
						local r = math.sqrt(radius^2-ycircle^2)
						ycircle = ycircle/1.3
						DrawCircle(target.x, target.y+250+ycircle, target.z, r, 0x00FF00)
					end
				end
			end
		end
	end
	DrawText("Hard CC: "..amountCC, X, Y, 0xFFFFFF00)
	DrawText("CC champions: "..stunChamps, X, Y+15, 0xFFFFFF00)
end
function GetTargetCC(typeCC,target)
	local HardCC, Airborne, Charm, Fear, Taunt, Polymorph, Silence, Stun, Suppression = 0, 0, 0, 0, 0, 0, 0, 0, 0
	local SoftCC, Blind, Entangle, Slow, Snare, Wall = 0, 0, 0, 0, 0, 0
	local targetName = target.name
	local QREADY = target.SpellTimeQ > 1
	local WREADY = target.SpellTimeW > 1
	local EREADY = target.SpellTimeE > 1
	local RREADY = target.SpellTimeR > 1
	if targetName == "Ahri" then
		if EREADY then
			HardCC = HardCC+1
			Charm = Charm+1
		end
	elseif targetName == "Akali" then
		if WREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
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
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if WREADY then
			SoftCC = SoftCC+1
			Wall = Wall+1
		end
		if RREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Ashe" then
		if QREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if RREADY then
			HardCC = HardCC+1
			Stun = Stun+1
			SoftCC = SoftCC+1
			Slow = Slow+1
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
		if RREADY then
			HardCC = HardCC+1
			Silence = Silence+1
		end
	elseif targetName == "Brand" then
		if QREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "Caitlyn" then
		if WREADY then
			SoftCC = SoftCC+1
			Snare = Snare+1
		end
		if EREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Cassiopeia" then
		if WREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if RREADY then
			HardCC = HardCC+1
			Stun = Stun+1
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Chogath" then
		if QREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if WREADY then
			HardCC = HardCC+1
			Silence = Silence+1
		end
	elseif targetName == "Darius" then
		if WREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1			
		end
		if EREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Diana" then
		if EREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "DrMundo" then
		if QREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Draven" then
		if EREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Elise" then
		if EREADY and target.range > 300 then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "Evelynn" then
		if RREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1			
		end
	elseif targetName == "FiddleSticks" then
		if QREADY then
			HardCC = HardCC+1
			Fear = Fear+1
		end
		if EREADY then
			HardCC = HardCC+1
			Silence = Silence+1
		end
	elseif targetName == "Fizz" then
		if EREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1	
		end
		if RREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Galio" then
		if QREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1			
		end
		if RREADY then
			HardCC = HardCC+1
			Taunt = Taunt+1			
		end
	elseif targetName == "Gangplank" then
		SoftCC = SoftCC+1
		Slow = Slow+1	
		if RREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1	
		end
	elseif targetName == "Garen" then
		if QREADY then
			HardCC = HardCC+1
			Silence = Silence+1			
		end
	elseif targetName == "Gragas" then
		if EREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1			
		end
		if RREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1		
		end
	elseif targetName == "Graves" then
		if WREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1			
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
			SoftCC = SoftCC+1
			Blind = Blind+1
		end
		if RREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Irelia" then
		if EREADY then
			if (target.health/target.maxHealth) <= (myHero.health/myHero.maxHealth) then
				HardCC = HardCC+1
				Stun = Stun+1
			else
				SoftCC = SoftCC+1
				Slow = Slow+1
			end			
		end
	elseif targetName == "Janna" then
		if QREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
		if WREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
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
		if WREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if RREADY then
			SoftCC = SoftCC+1
			Wall = Wall+1
		end
	elseif targetName == "Jax" then
		if EREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "Jayce" then
		if QREADY and target.range < 300 then
			SoftCC = SoftCC+1
			Slow = Slow+1			
		end
		if EREADY and target.range < 300 then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Karma" then
		if WREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Karthus" then
		if WREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Kassadin" then
		if QREADY then
			HardCC = HardCC+1
			Silence = Silence+1
		end
		if EREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Kayle" then
		if QREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
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
	elseif targetName == "Khazix" then
		SoftCC = SoftCC+1
		Slow = Slow+1
	elseif targetName == "KogMaw" then
		if EREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "LeBlanc" then
		if QREADY and (WREADY or EREADY or RREADY) then
			HardCC = HardCC+1
			Silence = Silence+1
		end
		if EREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
			Snare = Snare+1
		end
	elseif targetName == "LeeSin" then
		if EREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if RREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Leona" then
		if QREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
		if EREADY then
			SoftCC = SoftCC+1
			Snare = Snare+1
		end
		if RREADY then
			HardCC = HardCC+1
			Stun = Stun+1
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Lulu" then
		if QREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if WREADY then
			HardCC = HardCC+1
			Polymorph = Polymorph+1
		end
		if RREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Lux" then
		if QREADY then
			SoftCC = SoftCC+1
			Snare = Snare+1
		end
		if EREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Malphite" then
		if QREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
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
	elseif targetName == "Maokai" then
		if QREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if WREADY then
			SoftCC = SoftCC+1
			Snare = Snare+1
		end
	elseif targetName == "MissFortune" then
		if EREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Morgana" then
		if QREADY then
			SoftCC = SoftCC+1
			Snare = Snare+1
		end
		if RREADY then
			HardCC = HardCC+1
			Stun = Stun+1
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Nami" then
		if QREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
		if EREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if RREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Nasus" then
		if WREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Nautilus" then
		HardCC = HardCC+1
		Stun = Stun+1
		if QREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
		if EREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
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
	elseif targetName == "Nunu" then
		if EREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if RREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Olaf" then
		if QREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Orianna" then
		if WREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if RREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Pantheon" then
		if WREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
		if RREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Poppy" then
		if EREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
			Stun = Stun+1
		end
	elseif targetName == "Rammus" then
		if QREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
			SoftCC = SoftCC+1
			Slow = Slow+1
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
	elseif targetName == "Rengar" then
		if EREADY then
			SoftCC = SoftCC+1
			if myHero.mana == 5 then
				Snare = Snare+1
				Slow = Slow+1
			else
				Slow = Slow+1
			end
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
	elseif targetName == "Rumble" then
		if EREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if RREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Ryze" then
		if WREADY then
			SoftCC = SoftCC+1
			Snare = Snare+1
		end
	elseif targetName == "Sejuani" then
		SoftCC = SoftCC+1
		Slow = Slow+1
		if QREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if EREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if RREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "Shaco" then
		if WREADY then
			HardCC = HardCC+1
			Fear = Fear+1
		end
		if EREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
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
		if WREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
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
		if QREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if RREADY then
			HardCC = HardCC+1
			Suppression = Suppression+1
		end
		if passive then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if RREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "Soraka" then
		if EREADY then
			HardCC = HardCC+1
			Silence = Silence+1
		end
	elseif targetName == "Swain" then
		if QREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if WREADY then
			SoftCC = SoftCC+1
			Snare = Snare+1
		end
	elseif targetName == "Syndra" then
		if WREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if EREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Talon" then
		if WREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if EREADY then
			HardCC = HardCC+1
			Silence = Silence+1
		end
	elseif targetName == "Taric" then
		if EREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "Teemo" then
		if QREADY then
			SoftCC = SoftCC+1
			Blind = Blind+1
		end
		if RREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Thresh" then
		if QREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
		if EREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if RREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Tristana" then
		if WREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if RREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Trundle" then
		if EREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
			Wall = Wall+1
		end
	elseif targetName == "Tryndamere" then
		if WREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1			
		end
	elseif targetName == "Twitch" then
		if WREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Udyr" then---------
		if EREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "Urgot" then
		if WREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if RREADY then
			HardCC = HardCC+1
			Suppression = Suppression+1
		end
	elseif targetName == "Varus" then
		if EREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if RREADY then
			SoftCC = SoftCC+1
			Snare = Snare+1
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
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if RREADY then
			HardCC = HardCC+1
			Silence = Silence+1
		end
	elseif targetName == "Vladimir" then
		if WREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Volibear" then
		if QREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
		if EREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
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
		if EREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if RREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Yorick" then
		if WREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Zed" then
		if EREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Ziggs" then
		if WREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
		if EREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Zilean" then
		if EREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
	elseif targetName == "Zyra" then
		if WREADY and EREADY then
			SoftCC = SoftCC+1
			Slow = Slow+1
		end
		if EREADY then
			SoftCC = SoftCC+1
			Snare = Snare+1
		end
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