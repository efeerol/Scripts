require 'Utils'
require 'winapi'
require 'SKeys'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local version = '1.11'
AArange = myHero.range+(GetDistance(GetMinBBox(myHero)))

--[[
	---------------
	--- GENERAL ---
	---------------
	
	- Add at the top of your script: 				local Q,W,E,R = 'Q','W','E','R'
	- GetCD() 										Add into your main function to get cooldowns; 
	- QRDY,WRDY,ERDY,RRDY: 							Returns 0 or 1 whether the skill is on cooldown or ready
	- IsLolActive()									Returns true if the LoL-window in the foreground and the chat window is closed
	- IsBuffed(target,name)							Returns true if the target has a buff/debuff. Example: IsBuffed(myHero,'Annie_E_buf')
	- IsBetween(a,b,c,dist)							Returns true if b is in a line between a and c. Example: IsBetween(myHero,minion,target,125)
	- Bullseye(spellslot,Range)						Cast the spell when an enemy can be hit with it (only work with delayed AOE spells). Example: Bullseye('Q',1000)
	- CheckItemCD()									Return 1 or 0 if an item is ready (DFG = Deathfire, BFT = Blackfire, BC = Bilgewater, HG = Hextech Gunblade)
	- runningAway(target)							Return true or fals if a target is running away from you.
	
	----------------------	
	--- Draw Functions ---
	----------------------
	
	- DrawSphere(radius,thickness,color,x,y,z)		Draw a sphere. Example: DrawSphere(70,25,5,target.x,target.y+300,target.z)
	- CustomCircleXYZ(radius,thickness,color,x,y,z)	Draw a circle at a XYZ-coordinate. Example: CustomCircleXYZ(100,5,1,target.x,target.y,target.z)
	- StunDraw()									Use this in your main function to draw circles over enemies with a hardCC ready. Example : function Main() StunDraw() end
	
	----------------------	
	--- Misc Functions ---
	----------------------

	- round(num, idp)								Rounds a number to the given number of decimal places.
	- MoveMouse()									Move your champ to the mouse cursor, prevents derping when mouse is in one position.
	- MoveTarget(target)							Move your champ to the given target, prevents derping when target is in one position.
	- distXYZ(a1,a2,b1,b2)							Distance between two XYZ coordinates, y is always 0
	- LoadTable()									Table for the Draw-/DodgeSkillshot function. Call it from the lib, so you don't need to paste and update it in every single script.
	- GetDistanceSqr(p1, p2)
	- GetD(p1, p2)
	- GetDistanceBBox(p1, p2)
	- GetDistance2D(o1, o2)							Several functions to get the distance between 2 objects
	- ValidTarget(object, distance, enemyTeam)		Returns true if an enemy in range is vulnerable. Example: ValidTarget(target, 1000)
	- ValidBBoxTarget(object, distance, enemyTeam) 	Same as ValidTarget, but use true ranges. Example: ValidBBoxTarget(target, 1000)
	- AArange										Return your autoattack range

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
end

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