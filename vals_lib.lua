require 'Utils'
local version = '1.5'
--[[
	---------------
	--- GENERAL ---
	---------------
	
	- Add at the top of your script: 				local Q,W,E,R = 'Q','W','E','R'
	- GetCD() 										Add into your main function to get cooldowns; 
	- QRDY,WRDY,ERDY,RRDY: 							Returns 0 or 1 whether the skill is on cooldown or ready
	- GetAA()										Returns true for each successful autoattack (only for melee champs)
	- IsLolActive()									Returns true if the LoL-window in the foreground and the chat window is closed
	- IsSheenRdy()									Returns true if Sheen, Trinity Force, Iceborn Gauntlet, Lichbane passive is ready
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
		if distXYZ(a.x,a.z,FX,FZ)<range and distXYZ(b.x,b.z,FX,FZ)<((b.movespeed/1000)*(((delay*100)+100)+((speed/10)/GetDistance(a,b)))) then
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

--targetaa = GetWeakEnemy('PHYS',(myHero.range+(GetDistance(GetMinBBox(myHero)))*1.2))
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
        spell1.endPo1s=endPos1
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

----------------------------------------------------------------
----------------------------------------------------------------
-- IT'S NECESSARY TO USE A COOLDOWN HANDLING FUNCTION LIKE THIS:

function GetCD()
	if myHero.SpellTimeQ > 0 and GetSpellLevel('Q') > 0 then 
		QRDY = 1
		else QRDY = 0 
	end
	if myHero.SpellTimeW > 0 and GetSpellLevel('W') > 0 then 
		WRDY = 1
		else WRDY = 0 
	end
	if myHero.SpellTimeE > 0 and GetSpellLevel('E') > 0 then 
		ERDY = 1
		else ERDY = 0 
	end
	if myHero.SpellTimeR > 0 and GetSpellLevel('R') > 0 then 
		RRDY = 1
	else RRDY = 0 end
end