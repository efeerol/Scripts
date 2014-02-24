require 'Utils'
local send = require 'SendInputScheduled'
local version = '1.10'
skillshotArray = {}
local cc = 0
local Q,W,E,R = 'Q','W','E','R'
local metakey = SKeys.Control
local attempts = 0
local lastAttempt = 0


--[[
	---------------
	--- GENERAL ---
	---------------
	
	- Add at the top of your script: 				local Q,W,E,R = 'Q','W','E','R'
	- GetCD() 										Add into your main function to get cooldowns; 
	- QRDY,WRDY,ERDY,RRDY: 							Returns 0 or 1 whether the skill is on cooldown or ready
	- GetAA()										Returns true for each successful autoattack
	- IsLolActive()									Returns true if the LoL-window in the foreground and the chat window is closed
	- IsBuffed(target,name)							Returns true if the target has a buff/debuff. Example: IsBuffed(myHero,'Annie_E_buf')
	- IsBetween(a,b,c,dist)							Returns true if b is in a line between a and c. Example: IsBetween(myHero,minion,target,125)
	
	
	----------------------	
	--- Draw Functions ---
	----------------------
	
	- DrawSphere(radius,thickness,color,x,y,z)		Draw a sphere. Example: DrawSphere(70,25,5,target.x,target.y+300,target.z)
	- CustomCircleXYZ(radius,thickness,color,x,y,z)	Draw a circle at a XYZ-coordinate. Example: CustomCircleXYZ(100,5,1,target.x,target.y,target.z)
	
	----------------------	
	--- Misc Functions ---
	----------------------

	- round(num, idp)								Rounds a number to the given number of decimal places.
	- MoveMouse()									Move your champ to the mouse cursor, prevents derping when mouse is in one position.
	- MoveTarget(target)							Move your champ to the given target, prevents derping when target is in one position.
	- distXYZ(a1,a2,b1,b2)							Distance between two XYZ coordinates, y is always 0
	
	-----------------------
	--- Spell functions ---
	-----------------------
	
	- Spell: 		Can be Q,W,E,R or 'Q','W','E','R'
	- cd: 			Can be QRDY,WRDY,ERDY,RRDY which returns 0/1 or false/true
	- a,b:			Can be myHero, enemy, target, mousePos, object and so on...
	- range:		Requires a number, the maximum range, in which the function is executed
	- x,z:			Can be any x- and z-coordinate, y is always 0
	- delay: 		Cast delay of the skillshot, 1.6 is correct for most champs
	- speed:		Projectile speed of the skillshot, example for Ezreal's Q: 20, set it to 0 for instant casts
	- block:		set it to 1 if the skill can be blocked by creeps, not required, can be also 0 or nil
	- blockradius:	Projectile width, needed for wide range projectiles to prevent collisions with minions, default width is 100?, not required, can be also nil (but not 0)
	
	--------------------------------
	
	---- SPELLTARGET ----
	-- Old function: --
	if target ~= nil and QRDY == 1 and GetDistance(myHero,target) < 900 then CastSpellTarget('Q',target) end
	-- New function: --
	SpellTarget(Q,QRDY,myHero,target,900)
	-------------------
	
	---- SPELLXYZ ----
	-- Old function: --
	if target ~= nil and QRDY == 1 and GetDistance(myHero,target) < 900 then CastSpellXYZ('Q',target.x,target.y,target.z) end
	-- New function: --
	SpellXYZ(Q,QRDY,myHero,target,900,target.x,target.z)
	-------------------
	
	---- SPELLPRED ----
	-------------------
	-- Old function: --
	if target ~= nil and QRDY == 1 and GetDistance(myHero,target) < 900 and CreepBlock(GetFireahead(target,1.6,18)) == 0 then 
	CastSpellXYZ('Q',GetFireahead(target,1.6,18) end
	-- New function --
	SpellPred(Q,QRDY,myHero,target,900,1.6,18)
	-------------------
	
	-- Old function: --
	if target ~= nil and QRDY == 1 and GetDistance(myHero,target) < 900 and CreepBlock(myHero.x,myHero.y,myHero.z,GetFireahead(target,1.6,18)) == 1 then 
	CastSpellXYZ('Q',GetFireahead(target,1.6,18) end
	-- New function --
	SpellPred(Q,QRDY,myHero,target,900,1.6,18,1)
	-------------------
	
	-- Old function: --
	if target ~= nil and QRDY == 1 and GetDistance(myHero,target) < 900 and CreepBlock(myHero.x,myHero.y,myHero.z,GetFireahead(target,1.6,18),150) == 1 then 
	CastSpellXYZ('Q',GetFireahead(target,1.6,18) end
	-- New function --
	SpellPred(Q,QRDY,myHero,target,900,1.6,18,1,150)
	-------------------
	
	(Note: The spelltarget function It also checks the distance between a and b and between a and the predicted coordinates.)
]]	

function SpellTarget(spell,cd,a,b,range)
	if a ~= nil and b ~= nil then
		if (cd == 1 or cd) and GetDistance(a,b) < range then
			CastSpellTarget(spell,b)
		end
	end
end

function SpellXYZ(spell,cd,a,b,range,x,z)
	if a ~= nil and b ~= nil then
		local y = 0
		if (cd == 1 or cd) and x ~= nil and z ~= nil and GetDistance(a,b) < range then
			CastSpellXYZ(spell,x,y,z)
		end
	end
end

function SpellPred(spell,cd,a,b,range,delay,speed,block,blockradius)
	if (cd == 1 or cd) and a ~= nil and b ~= nil and delay ~= nil and speed ~= nil and GetDistance(a,b)<range then
		local FX,FY,FZ = GetFireahead(b,delay,speed)
		if distXYZ(a.x,a.z,FX,FZ)<range then
			if block == 1 and blockradius==nil then
				if CreepBlock(a.x,a.y,a.z,FX,FY,FZ) == 0 then
					CastSpellXYZ(spell,FX,FY,FZ)
				end
			elseif block == 1 and blockradius~=nil then
				if CreepBlock(a.x,a.y,a.z,FX,FY,FZ,blockradius) == 0 then
					CastSpellXYZ(spell,FX,FY,FZ)
				end
			else CastSpellXYZ(spell,FX,FY,FZ)
			end
		end
	end
end

function SpellPredSimple(spell,cd,a,b,range,delay,speed,block)
	if (cd == 1 or cd) and a ~= nil and b ~= nil and delay ~= nil and speed ~= nil and GetDistance(a,b)<range then
		local FX,FY,FZ = GetFireahead(b,delay,speed)
		if block == 1 then
			if CreepBlock(a.x,a.y,a.z,FX,FY,FZ) == 0 then
				CastSpellXYZ(spell,FX,FY,FZ)
			end
		else CastSpellXYZ(spell,FX,FY,FZ)
		end
	end
end

function distXYZ(a1,a2,b1,b2)
	if b1 == nil or b2 == nil then
		b1 = myHero.x
		b2 = myHero.z
	end
	if a2 ~= nil and b2 ~= nil and a1~=nil and b1~=nil then
		a = (b1-a1)
		b = (b2-a2)
		if a~=nil and b~=nil then
			a2=a*a
			b2=b*b
			if a2~=nil and b2~=nil then
				return math.sqrt(a2+b2)
			else
				return 99999
			end
		else
			return 99999
		end
	end
end

--[[targetaa = GetWeakEnemy('PHYS',(myHero.range+(GetDistance(GetMinBBox(myHero)))*1.2))
function GetAA()
	local AArange = (myHero.range+(GetDistance(GetMinBBox(myHero))))*1.2
	local targetaa = GetWeakEnemy('PHYS',AArange)
    local spells1={}
    local a1={GetCastSpell()}    
    local g1=0
    while (a1~=nil and a1[1] ~= nil and g1<200) do
        local spell1={}
        local startPos1={}
        local endPos1={}
        spell1.unit=a1[1]
        spell1.name=a1[2]
        startPos1.x=a1[3]
        startPos1.y=a1[4]
        startPos1.z=a1[5]
        endPos1.x=a1[6]
        endPos1.y=a1[7]
        endPos1.z=a1[8]
        spell1.target=a1[12]
        spell1.startPos1=startPos1
        spell1.endPos1=endPos1
        table.insert(spells1, spell1)
        a1={GetCastSpell()}
        g1=g1+1
		if (string.find(spell1.name,'Attack') or string.find(spell1.name,'attack')) and (spell1.unit.name == myHero.name) then
			attackstart = true
		end
	end
	for i=1, objManager:GetMaxNewObjects() do
		local obj = objManager:GetNewObject(i)  
		if obj ~= nil then
			if targetaa~=nil and attackstart and string.find(obj.charName,'globalhit') and GetDistance(obj, targetaa) < 50 then
				attackstart = false
				return true
			end
		end
	end
end]]

function Bullseye(spellslot,Range)
    local spells2={}
    local a2={GetCastSpell()}    
    local g2=0
    while (a2~=nil and a2[1] ~= nil and g2<200) do
        local spell2={}
        local startPos2={}
        local endPos2={}
        spell2.unit=a2[1]
        spell2.name=a2[2]
        startPos2.x=a2[3]
        startPos2.y=a2[4]
        startPos2.z=a2[5]
        endPos2.x=a2[6]
        endPos2.y=a2[7]
        endPos2.z=a2[8]
        spell2.target=a2[12]
        spell2.startPos2=startPos2
        spell2.endPos=endPos2
        table.insert(spells2, spell2)
        a2={GetCastSpell()}
        g2=g2+1
		if unit ~= nil and spell2 ~= nil and unit.team ~= myHero.team then
			for i = 1, objManager:GetMaxHeroes() do
				local champ = objManager:GetHero(i)
				if (champ ~= nil and champ.visible == 1 and champ.dead == 0) then
				-- Target Gapcloser
					if (spell2.name == 'AkaliShadowDance' or
						spell2.name == 'Headbutt' or
						spell2.name == 'DariusExecute' or
						spell2.name == 'DianaTeleport' or
						spell2.name == 'EliseSpiderQCast' or
						spell2.name == 'FioraQ' or
						spell2.name == 'Urchin Strike' or
						spell2.name == 'IreliaGatotsu' or
						spell2.name == 'JarvanIVCataclysm' or
						spell2.name == 'JaxLeapStrike' or
						spell2.name == 'JayceToTheSkies' or
						spell2.name == 'blindmonkqtwo' or
						spell2.name == 'BlindMonkWOne' or
						spell2.name == 'MaokaiUnstableGrowth' or
						spell2.name == 'AlphaStrike' or
						spell2.name == 'NocturneParanoia' or
						spell2.name == 'Pantheon_LeapBash' or
						spell2.name == 'MonkeyKingNimbus' or
						spell2.name == 'XenZhaoSweep' or
						spell2.name == 'ViR' or
						spell2.name == 'YasuoDashWrapper' or
						spell2.name == 'TalonCutthroat' or
						spell2.name == 'KatarinaE' or
						spell2.name == 'InfiniteDuress') and 
						spell2.target~=nil and spell2.target.name == champ.name and GetDistance(champ)<Range then
						CastSpellXYZ(spellslot,champ.x,0,champ.z)
					end
				end
			end
			-- No target dashes	
			if spell2.name == 'AatroxQ' then range = 650 end
			if spell2.name == 'AhriTumble' then range = 550 end
			if spell2.name == 'CarpetBomb' then range = 800 end
			if spell2.name == 'GragasBodySlam' then range = 600 end
			if spell2.name == 'GravesMove' then range = 425 end
			if spell2.name == 'LucianE' then range = 425 end
			if spell2.name == 'RenektonSliceAndDice' then range = 450 end
			if spell2.name == 'SejuaniArcticAssault' then range = 650 end
			if spell2.name == 'ShenShadowDash' then range = 600 end
			if spell2.name == 'ShyvanaTransformCast' then range = 1000 end
			if spell2.name == 'slashCast' then range = 660 end
			if spell2.name == 'ViQ' then range = 725 end
			if spell2.name == 'FizzJump' then range = 400 end
			if spell2.name == 'HecarimUlt' then range = 1000 end
			if spell2.name == 'KhazixE' then range = 600 end
			if spell2.name == 'khazixelong' then range = 900 end
			if spell2.name == 'LeblancSlide' then range = 600 end
			if spell2.name == 'LeblancSlideM' then range = 600 end
			if spell2.name == 'UFSlash' then range = 1000 end
			if spell2.name == 'Pounce' then range = 375 end
			if spell2.name == 'Deceive' then range = 400 end
			if spell2.name == 'ZacE' and unit.name == 'Zac' then range = (unit.SpellLevelE*100)+1050 end
			if spell2.name == 'VayneTumble' then range = 300 end
			if spell2.name == 'RivenTriCleave' then range = 260 end
			if spell2.name == 'RivenFeint' then range = 325 end
			if spell2.name == 'EzrealArcaneShift' then range = 475 end
			if spell2.name == 'RiftWalk' then range = 700 end
			if spell2.name == 'RocketJump' then range = 900 end
				
			if 	spell2.name == 'AatroxQ' or
				spell2.name == 'AhriTumble' or
				spell2.name == 'CarpetBomb' or
				spell2.name == 'GragasBodySlam' or
				spell2.name == 'GravesMove' or
				spell2.name == 'LucianE' or
				spell2.name == 'RenektonSliceAndDice' or
				spell2.name == 'SejuaniArcticAssault' or
				spell2.name == 'ShenShadowDash' or
				spell2.name == 'ShyvanaTransformCast' or
				spell2.name == 'slashCast' or
				spell2.name == 'ViQ' or
				spell2.name == 'FizzJump' or
				spell2.name == 'HecarimUlt' or
				spell2.name == 'KhazixE' or
				spell2.name == 'khazixelong' or
				spell2.name == 'LeblancSlide' or
				spell2.name == 'LeblancSlideM' or
				spell2.name == 'UFSlash' or
				spell2.name == 'Pounce' or
				spell2.name == 'Deceive' or
				spell2.name == 'ZacE' or
				spell2.name == 'VayneTumble' or
				spell2.name == 'RivenTriCleave' or
				spell2.name == 'RivenFeint' or
				spell2.name == 'EzrealArcaneShift' or
				spell2.name == 'RiftWalk' or
				spell2.name == 'RocketJump' then
				if distXYZ(unit.x,unit.z,spell2.endPos.x,spell2.endPos.z)>range then
					EnemyPos = Vector(unit.x,unit.y,unit.z)
					SpellPos = Vector(spell2.endPos.x,spell2.endPos.y,spell2.endPos.z)
					TruePos = EnemyPos + ( EnemyPos - SpellPos )*(-range/GetDistance(unit, spell2.endPos))
				elseif distXYZ(unit.x,unit.z,spell2.endPos.x,spell2.endPos.z)<range then
					TruePos = spell2.endPos
				end
				timer = 750
				if TruePos~=nil and GetDistance(TruePos)<Range and myHero.SpellTimeQ > 1 and GetTickCount()>timer then CastSpellXYZ(spellslot,TruePos.x,0,TruePos.z) end
			end
				-- Movement stopper
			if (spell2.name == 'katarinar' or
				spell2.name == 'drain' or
				spell2.name == 'crowstorm' or
				spell2.name == 'consume' or
				spell2.name == 'absolutezero' or
				spell2.name == 'rocketgrab' or
				spell2.name == 'staticfield' or
				spell2.name == 'cassiopeiapetrifyinggaze' or
				spell2.name == 'ezrealtrueshotbarrage' or
				spell2.name == 'galioidolofdurand' or
				spell2.name == 'gragasdrunkenrage' or
				spell2.name == 'luxmalicecannon' or
				spell2.name == 'reapthewhirlwind' or
				spell2.name == 'jinxw' or
				spell2.name == 'jinxr' or
				spell2.name == 'missfortunebullettime' or
				spell2.name == 'shenstandunited' or
				spell2.name == 'threshe' or
				spell2.name == 'threshrpenta' or
				spell2.name == 'infiniteduress' or
				spell2.name == 'meditate') and GetDistance(unit)<Range then
				CastSpellXYZ(spellslot,unit.x,0,unit.z)
			end
		end
	end
	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0 and enemy.dead == 0) then
			if (IsBuffed(enemy,'LOC_Stun') or 
				IsBuffed(enemy,'LOC_Suppress') or 
				IsBuffed(enemy,'LOC_Taunt') or 
				IsBuffed(enemy,'LuxLightBinding') or 
				IsBuffed(enemy,'DarkBinding_tar') or 
				IsBuffed(enemy,'RunePrison') or 
				IsBuffed(enemy,'Zyra_E_sequence_root') or 
				IsBuffed(enemy,'monkey_king_ult_unit_tar_02') or 
				IsBuffed(enemy,'xenZiou_ChainAttack_03') or 
				IsBuffed(enemy,'xenZiou_ChainAttack_03') or 
				IsBuffed(enemy,'tempkarma_spiritbindroot_tar')) and 
				GetDistance(enemy)<Range then
				CastSpellXYZ(spellslot,enemy.x,enemy.y,enemy.z)
			end
		end
	end
	for i = 1, objManager:GetMaxHeroes() do
		local ally = objManager:GetHero(i)
		if (ally ~= nil and ally.team == myHero.team and ally.visible == 1 and ally.dead == 0) then
			if (IsBuffed(ally,'CurseBandages')) and
				GetDistance(ally)<Range then
				CastSpellXYZ(spellslot,ally.x,ally.y,ally.z)
			end
		end
	end
end
function CheckItemCD()
	if GetInventorySlot(3188)==1 and myHero.SpellTime1 >= 1 then BFT = 1
	elseif GetInventorySlot(3188)==2 and myHero.SpellTime2 >= 1 then BFT = 1
	elseif GetInventorySlot(3188)==3 and myHero.SpellTime3 >= 1 then BFT = 1
	elseif GetInventorySlot(3188)==4 and myHero.SpellTime4 >= 1 then BFT = 1
	elseif GetInventorySlot(3188)==5 and myHero.SpellTime5 >= 1 then BFT = 1
	elseif GetInventorySlot(3188)==6 and myHero.SpellTime6 >= 1 then BFT = 1
	else BFT = 0
	end

	if GetInventorySlot(3128)==1 and myHero.SpellTime1 >= 1 then DFG = 1
	elseif GetInventorySlot(3128)==2 and myHero.SpellTime2 >= 1 then DFG = 1
	elseif GetInventorySlot(3128)==3 and myHero.SpellTime3 >= 1 then DFG = 1
	elseif GetInventorySlot(3128)==4 and myHero.SpellTime4 >= 1 then DFG = 1
	elseif GetInventorySlot(3128)==5 and myHero.SpellTime5 >= 1 then DFG = 1
	elseif GetInventorySlot(3128)==6 and myHero.SpellTime6 >= 1 then DFG = 1
	else DFG = 0
	end
	
	if GetInventorySlot(3144)==1 and myHero.SpellTime1 >= 1 then BC = 1
	elseif GetInventorySlot(3144)==2 and myHero.SpellTime2 >= 1 then BC = 1
	elseif GetInventorySlot(3144)==3 and myHero.SpellTime3 >= 1 then BC = 1
	elseif GetInventorySlot(3144)==4 and myHero.SpellTime4 >= 1 then BC = 1
	elseif GetInventorySlot(3144)==5 and myHero.SpellTime5 >= 1 then BC = 1
	elseif GetInventorySlot(3144)==6 and myHero.SpellTime6 >= 1 then BC = 1
	else BC = 0
	end
	
	if GetInventorySlot(3146)==1 and myHero.SpellTime1 >= 1 then HG = 1
	elseif GetInventorySlot(3146)==2 and myHero.SpellTime2 >= 1 then HG = 1
	elseif GetInventorySlot(3146)==3 and myHero.SpellTime3 >= 1 then HG = 1
	elseif GetInventorySlot(3146)==4 and myHero.SpellTime4 >= 1 then HG = 1
	elseif GetInventorySlot(3146)==5 and myHero.SpellTime5 >= 1 then HG = 1
	elseif GetInventorySlot(3146)==6 and myHero.SpellTime6 >= 1 then HG = 1
	else HG = 0
	end
end

function IsLolActive()
    return tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client" and IsChatOpen() == 0
end

function DrawSphere(radius,thickness,color,x,y,z)
    for j=1, thickness do
        local ycircle = (j*(radius/thickness*2)-radius)
        local r = math.sqrt(radius^2-ycircle^2)
        ycircle = ycircle/1.3
        DrawCircle(x,y+ycircle,z,r,color)
    end
end

function runningAway(target)
   local d1 = GetDistance(target)
   local x, y, z = GetFireahead(target,2,0)
   local d2 = GetDistance({x=x, y=y, z=z})
   local d3 = GetDistance({x=x, y=y, z=z},target)
   local angle = math.acos((d2*d2-d3*d3-d1*d1)/(-2*d3*d1))
   return angle%(2*math.pi)>math.pi/2 and angle%(2*math.pi)<math.pi*3/2
end

function CustomCircleXYZ(radius,thickness,color,x,y,z)
        local count = math.floor(thickness/2)
        repeat
            DrawCircle(x,y,z,radius+count,color)
            count = count-2
        until count == (math.floor(thickness/2)-(math.floor(thickness/2)*2))-2
    if x ~= "" and y ~= "" and z~= "" then
        local count = math.floor(thickness/2)
        repeat
            DrawCircle(x,y,z,radius+count,color)
            count = count-2
        until count == (math.floor(thickness/2)-(math.floor(thickness/2)*2))-2
    end
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function Round(val, decimal)
	if (decimal) then
		return math.floor( (val * 10 ^ decimal) + 0.5) / (10 ^ decimal)
	else
		return math.floor(val + 0.5)
	end
end

function MoveMouse()
	local moveSqr = math.sqrt((mousePos.x - myHero.x)^2+(mousePos.z - myHero.z)^2)
    local moveX = myHero.x + 300*((mousePos.x - myHero.x)/moveSqr)
    local moveZ = myHero.z + 300*((mousePos.z - myHero.z)/moveSqr)
    MoveToXYZ(moveX,0,moveZ)
end

function MoveTarget(target)
	if target~=nil then
	local moveSqr = math.sqrt((target.x - myHero.x)^2+(target.z - myHero.z)^2)
    local moveX = myHero.x + 300*((target.x - myHero.x)/moveSqr)
    local moveZ = myHero.z + 300*((target.z - myHero.z)/moveSqr)
    MoveToXYZ(moveX,0,moveZ)
	end
end

function IsSheenRdy()
	if ((GetInventorySlot(3025)==1 or GetInventorySlot(3057)==1 or GetInventorySlot(3078)==1 or GetInventorySlot(3100)==1) and myHero.SpellTime1 >= 1) or
	((GetInventorySlot(3025)==2 or GetInventorySlot(3057)==2 or GetInventorySlot(3078)==2 or GetInventorySlot(3100)==2) and myHero.SpellTime2 >= 1) or
	((GetInventorySlot(3025)==3 or GetInventorySlot(3057)==3 or GetInventorySlot(3078)==3 or GetInventorySlot(3100)==3) and myHero.SpellTime3 >= 1) or
	((GetInventorySlot(3025)==4 or GetInventorySlot(3057)==4 or GetInventorySlot(3078)==4 or GetInventorySlot(3100)==4) and myHero.SpellTime4 >= 1) or
	((GetInventorySlot(3025)==5 or GetInventorySlot(3057)==5 or GetInventorySlot(3078)==5 or GetInventorySlot(3100)==5) and myHero.SpellTime5 >= 1) or
	((GetInventorySlot(3025)==6 or GetInventorySlot(3057)==6 or GetInventorySlot(3078)==6 or GetInventorySlot(3100)==6) and myHero.SpellTime6 >= 1) then
	return true
	end
end

function IsBuffed(target,name)
    for i = 1, objManager:GetMaxObjects(), 1 do
        obj = objManager:GetObject(i)
        if obj~=nil and target~=nil and string.find(obj.charName,name) and GetDistance(obj, target) < 100 then
			return true
        end
    end
end

function IsBetween(a,b,c,dist)
	if a~=nil and b~=nil and c~=nil then
		ex = a.x
		ez = a.z
		tx = c.x
		tz = c.z
		dx = ex-tx
		dz = ez-tz
		if dx ~= 0 then
		m = dz/dx
		c = ez-m*ex
		end
		mx = b.x
		mz = b.z
		distanc = (math.abs(mz - m*mx - c))/(math.sqrt(m*m+1))
		if distanc<dist and math.sqrt((tx-ex)*(tx-ex)+(tz-ez)*(tz-ez))>math.sqrt((tx-mx)*(tx-mx)+(tz-mz)*(tz-mz)) then
			return true
		end
	end
end

function MakeStateMatch(changes)
    for scode,flag in pairs(changes) do    
        local vk = winapi.map_virtual_key(scode, 3)
        local is_down = winapi.get_async_key_state(vk)
        if flag then
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

function Skillshots()
	send.tick()
	cc=cc+1
	if cc==30 then LoadTable() end
	for i=1, #skillshotArray, 1 do
		if os.clock() > (skillshotArray[i].lastshot + skillshotArray[i].time) then skillshotArray[i].shot = 0 end
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

function LoadTable()
	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if (enemy ~= nil and enemy.team ~= myHero.team) then
			if enemy.name == 'Ahri' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 880, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			end
			if enemy.name == 'Amumu' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			end
			if enemy.name == 'Anivia' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 90, color= 0x0000FFFF, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			end
			if enemy.name == 'Ashe' then
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 50000, type = 4, radius = 120, color= 0x0000FFFF, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			end
			if enemy.name == 'Blitzcrank' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 120, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			end
			if enemy.name == 'Brand' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 50, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Cassiopeia' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 125, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Caitlyn' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 50, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Corki' then
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1225, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Chogath' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 275, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Diana' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 205, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Draven' then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 125, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 1, radius = 100, color= 0x0000FFFF, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'DrMundo' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Elise' and enemy.range>300 then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Ezreal' then
				if enemy.ap>enemy.addDamage then
					table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
				elseif enemy.ap<enemy.addDamage then
					table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
				end
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 4, radius = 150, color= 0x0000FFFF, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if enemy.name == 'Fizz' then
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1275, type = 2, radius = 100, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Galio' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 905, type = 3, radius = 200, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 120, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Gragas' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 320, color= 0xFFFFFF00, time = 2.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 3, radius = 400, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Graves' then
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 110, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Hecarim' then
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 125, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Heimerdinger' then
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 225, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Janna' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1700, type = 1, radius = 100, color= 0x0000FFFF, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Jayce' and enemy.range>300 then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1500, type = 1, radius = 125, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Jinx' then
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1500, type = 1.5, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 3, radius = 225, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Karma' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Karthus' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 875, type = 3, radius = 75, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Kennen' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 75, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Khazix' then	
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 75, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })	
			end
			if enemy.name == 'KogMaw' then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1115, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2200, type = 3, radius = 200, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Leblanc' then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'LeeSin' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Leona' then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Lissandra' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 725, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Lucian' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= 0x0000FFFF, time = 0.75, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Lulu' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 50, color= 0x0000FFFF, time = 1, isline = true, px =0, py =0 , pz =0, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Lux' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1175, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 300, color= 0xFFFFFF00, time = 2.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 3000, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Malzahar' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 100 , color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 250 , color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Maokai' then
				table.insert(skillshotArray,{name= 'MaokaiTrunkLineMissile', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 350 , color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Morgana' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 100, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Nami' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 875, type = 3, radius = 210, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2750, type = 1, radius = 335, color= 0xFFFFFF00, time = 3, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Nautilus' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Nidalee' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1500, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if enemy.name == 'Olaf' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 2, radius = 100, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Orianna' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 825, type = 3, radius = 150, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if enemy.name == 'Rumble' then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 100, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1700, type = 1, radius = 100, color= 0xFFFFFF00, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if enemy.name == 'Sejuani' then
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1150, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = f, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Shen' then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 2, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if enemy.name == 'Shyvana' then
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Sivir' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Skarner' then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Sona' then
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Swain' then
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 265 , color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Syndra' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 250, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 1, radius = 100, color= 0xFFFFFF00, time = 0.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 210, color= 0x0000FFFF, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Thresh' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 160, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'TwistedFate' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1450, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Urgot' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= 0x0000FFFF, time = 0.8, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 300, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if enemy.name == 'Varus' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1475, type = 1, radius = 50, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Veigar' then
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 225, color= 0xFFFFFF00, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if enemy.name == 'Vi' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 725, type = 1, radius = 75, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Viktor' then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 80, color= 0xFFFFFF00, time = 2})
			end
			if enemy.name == 'Xerath' then
				table.insert(skillshotArray,{name= 'xeratharcanopulse2', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1450, type = 1, radius = 150, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1450, type = 3, radius = 225, color= 0xFFFFFF00, time = 0.8, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= 'xerathrmissilewrapper', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2000+(enemy.SpellLevelR+1200), type = 3, radius = 75, color= 0xFFFFFF00, time = 0.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Yasuo' then
				table.insert(skillshotArray,{name= 'yasuoq3w', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 125, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Zac' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 550, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1550, type = 5, radius = 200, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Zed' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 55, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Ziggs' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 160, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 225 , color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5300, type = 3, radius = 550, color= 0xFFFFFF00, time = 3, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Zyra' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 825, type = 3, radius = 275, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 90, color= 0x0000FFFF, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
		end
	end
end

----------------------------------------------------------------
----------------------------------------------------------------
-- IT'S NECESSARY TO USE A COOLDOWN HANDLING FUNCTION LIKE THIS:

function GetCD()
	if myHero.SpellTimeQ > 1 and GetSpellLevel('Q') > 0 then 
		QRDY = 1
		else QRDY = 0 
	end
	if myHero.SpellTimeW > 1 and GetSpellLevel('W') > 0 then 
		WRDY = 1
		else WRDY = 0 
	end
	if myHero.SpellTimeE > 1 and GetSpellLevel('E') > 0 then 
		ERDY = 1
		else ERDY = 0 
	end
	if myHero.SpellTimeR > 1 and GetSpellLevel('R') > 0 then 
		RRDY = 1
	else RRDY = 0 end
end

function StunDraw()
	local stunChamps = 0
	local amountCC = 0
	for i = 1, objManager:GetMaxHeroes()  do
	local enemie = objManager:GetHero(i)
		if (enemie ~= nil and enemie.team ~= myHero.team and enemie.visible == 1 and enemie.dead == 0) and GetDistance(myHero,enemie) < 2500 then
			local targetCC = GetTargetCC("HardCC",enemie)
			if targetCC > 0 then
				stunChamps = stunChamps+1
				amountCC = amountCC+targetCC
				if enemie.visible then
					thickness = 10*targetCC
					for j=1, thickness do
						local ycircle = (j*(60/thickness*2)-60)
						local r = math.sqrt(60^2-ycircle^2)
						ycircle = ycircle/1.3
						DrawCircle(enemie.x, enemie.y+300+ycircle, enemie.z, r, 0x00FF00)
					end
				end
			end
		end
	end
	--DrawText("Hard CC: "..amountCC, DrawX, DrawY-40, Color.White)
	--DrawText("CC champions: "..stunChamps, DrawX, DrawY-30, Color.White)
end

function GetTargetCC(typeCC,enemie)
	local HardCC, Airborne, Charm, Fear, Taunt, Polymorph, Silence, Stun, Suppression = 0, 0, 0, 0, 0, 0, 0, 0, 0
	local targetName = enemie.name
	local QREADY = enemie.SpellTimeQ > 1
	local WREADY = enemie.SpellTimeW > 1
	local EREADY = enemie.SpellTimeE > 1
	local RREADY = enemie.SpellTimeR > 1
	if targetName == "Aatrox" then
		if QREADY then
			HardCC = HardCC+1
			Airborne = Airborne+1
		end
	elseif targetName == "Ahri" then
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
	elseif targetName == "Anivia" then
		if QREADY then
			HardCC = HardCC+1
			Stun = Stun+1
		end
	elseif targetName == "Annie" then
		if IsBuffed(enemie,'StunReady') and (QREADY or WREADY or RREADY) then
			HardCC = HardCC+1
			Stun = Stun+1
		end
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
		if QREADY and (IsBuffed(myHero,'BrandFireMark') or WREADY or EREADY or RREADY) then
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
		if (QREADY and WREADY and EREADY) or (IsBuffed(myHero,'kennen_mos') and (QREADY or WREADY or EREADY or RREADY)) then
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
			if EREADY then
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
	else return 0 end
end

----------------------------------------------------------------
----------------------------------------------------------------

function GetDistanceSqr(p1, p2)
    assert(p1, "GetDistance: invalid argument: cannot calculate distance to "..type(p1))
    p2 = p2 or myHero
    return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end

function GetD(p1, p2)
    return math.sqrt(GetDistanceSqr(p1, p2))
end

--p1 should be the BBoxed object
function GetDistanceBBox(p1, p2)
    if p2 == nil then p2 = myHero end
    assert(p1 and GetMinBBox(p1) and p2 and GetMinBBox(p2), "GetDistanceBBox: wrong argument types (<object><object> expected for p1, p2)")
    local bbox1 = GetDistance(p1, GetMinBBox(p1))
    return GetDistance(p1, p2) - (bbox1)
end

function ValidTarget(object, distance, enemyTeam)
    local enemyTeam = (enemyTeam ~= false)
    return object ~= nil and object.valid==1 and (object.team ~= myHero.team) == enemyTeam and object.visible==1 and object.dead==0 and (enemyTeam == false or object.invulnerable == 0) and (distance == nil or GetDistanceSqr(object) <= distance * distance)
end

function ValidBBoxTarget(object, distance, enemyTeam)
    local enemyTeam = (enemyTeam ~= false)
    return object ~= nil and object.valid==1 and (object.team ~= myHero.team) == enemyTeam and object.visible==1 and object.dead==0 and (enemyTeam == false or object.invulnerable == 0) and (distance == nil or GetDistanceBBox(object) <= distance)
end

function GetDistance2D(o1, o2)
   local c = "z"
   if o1.z == nil or o2.z == nil then c = "y" end
   return math.sqrt(math.pow(o1.x - o2.x, 2) + math.pow(o1[c] - o2[c], 2))
end