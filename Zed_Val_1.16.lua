require 'Utils'
require 'winapi'
require 'SKeys'
require 'spell_damage'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local Q,W,E,R = 'Q','W','E','R'
local version = '1.16.1'

---------- CONFIG ----------
local Qdelay = 1.6 -- Q Cast AAdelay (1.5 = 250ms)
local Qspeed = 17 -- Q projectile speed (17 = 1700 units/second)
local Wdelay = 0.1 -- W Cast AAdelay (1.5 = 250ms)
local Wspeed = 24 -- W projectile speed (17 = 1700 units/second)
local AAdelay = 135 -- Attack animation AAdelay
local Harass_Mode = 6 -- Harassmode on gamestart [1=Q, 2=WE, 3=WQ (900 range,2 hits), 4=WQ (1450 range,1 hit), 5=WEQ 6=Q+AutoE]
local skillingOrder = {Zed = {Q,W,E,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},} -- Skillorder for Auto-Level
local Qrange = 800 -- Range of Q-spell
local Wrange = 595 -- Range of W-spell
local Erange = 250 -- Range of E-spell
local Rrange = 625 -- Range of R-spell
local DrawX = 70 -- X coordinate of the 'Harass Mode'-text
local DrawY = 170 -- Y coordinate of the 'Harass Mode'-text
local Color = 0xFF00EE00 -- Color of the 'Harass Mode'-text (default: green)
local ShowRange = 2500
local jumpspotrange = 25
local jumpmouserange = 100

--- ---	--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
-- DON'T CHANGE ANYTHING BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING! --
--- ---	--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
local timer,timer2,ShadowTimer,UltTimer,KStimer = 0,0,0,0,0
local target,ulttarget
local toggle_timer = os.clock()
local _registry = {}
local qx,qy,qz,vst,vse,deconce,pdot,ddot,edot=0,0,0,0,0,0,0,0,0
local hero_table = {}
local zv = Vector(0,0,0)
local amax_heroes = 0
local metakey = SKeys.Control
local attempts = 0
local lastAttempt = 0
local cc = 0
local colorcyan = 0x0000FFFF
local coloryellow = 0xFFFFFF00
local colorgreen = 0xFF00FF00
local skillshotcharexist = false
local skillshotArray = {}
local show_allies = 0
local p = myHero
local jump = false
local Enemies = {}
local EnemyIndex = 1
local HavocDamage = 0
local ExecutionerDamage = 0
local debugmode = false

local JumpSpots = {
	{x =8429 , y = -189, z = 2475},
	{x =8138 , y = -189, z = 3035},
	{x =7879 , y = -189, z = 2275},
	{x =7714 , y = -189, z = 2665},
	{x =9829 , y = -189, z = 3275},
	{x =9317 , y = -189, z = 3658},
	{x =10029 , y = -189, z = 8223},
	{x =10522 , y = -189, z = 8629},
	{x =9579 , y = -189, z = 8873},
	{x =10123 , y = -189, z = 9208},
	{x =8759 , y = -189, z = 9639},
	{x =8875 , y = -189, z = 10218},
	{x =8329 , y = -189, z = 9723},
	{x =8264 , y = -189, z = 10359},
	{x =7979 , y = -189, z = 9523},
	{x =7753 , y = -189, z = 10077},
	{x =5959 , y = -189, z = 9491},
	{x =6300 , y = -189, z = 9864},
	{x =5531 , y = -189, z = 9723},
	{x =5354 , y = -189, z = 10293},
	{x =4257 , y = -189, z = 8867},
	{x =3698 , y = -189, z = 9061},
	{x =3881 , y = -189, z = 8223},
	{x =3348 , y = -189, z = 8575},
	{x =4581 , y = -189, z = 3675},
	{x =4095 , y = -189, z = 3276},
	{x =5731 , y = -189, z = 3025},
	{x =5568 , y = -189, z = 2449},
	{x =6231 , y = -189, z = 2625},
	{x =6023 , y = -189, z = 2261},
	{x =6377 , y = -189, z = 3809},
	{x =6626 , y = -189, z = 3230},
	{x =7529 , y = -189, z = 3775},
	{x =7642 , y = -189, z = 3198},
	{x =9279 , y = -189, z = 5375},
	{x =8705 , y = -189, z = 5523},
	{x =9499 , y = -189, z = 5843},
	{x =9071 , y = -189, z = 6318},
	{x =4443 , y = -189, z = 5833},
	{x =4659 , y = -188, z = 6434},
	{x =4581 , y = -189, z = 5525},
	{x =5176 , y = -189, z = 5467},
	{x =6631 , y = -189, z = 8373},
	{x =7270 , y = -189, z = 8386},
	{x =5631 , y = -189, z = 7073},
	{x =5522 , y = -189, z = 7703},
	{x =8329 , y = -189, z = 5725},
	{x =7756 , y = -189, z = 6007},
	{x =8479 , y = -189, z = 6275},
	{x =8049 , y = -189, z = 6573},
	{x =7069 , y = -189, z = 4447},
	{x =7584 , y = -189, z = 4753},
	{x =5581 , y = -189, z = 5775},
	{x =6184 , y = -189, z = 5972},
	{x =5456 , y = -189, z = 6192},
	{x =5921 , y = -189, z = 6390},
	{x =9179 , y = -189, z = 1525},
	{x =9784 , y = -189, z = 1732},
	{x =10179 , y = -189, z = 2075},
	{x =10537 , y = -189, z = 2604},
	{x =11129 , y = -189, z = 2525},
	{x =11564 , y = -188, z = 2993},
	{x =12379 , y = -189, z = 6773},
	{x =12332 , y = -189, z = 6136},
	{x =12379 , y = -189, z = 7223},
	{x =12198 , y = -189, z = 7835},
	{x =12119 , y = -189, z = 8295},
	{x =11979 , y = -189, z = 8877},
	{x =6945 , y = -194, z = 11493},
	{x =6935 , y = -189, z = 11893},
	{x =6925 , y = -148, z = 10579},
	{x =6939 , y = -189, z = 9942},
	{x =2069 , y = -189, z = 8901},
	{x =1923 , y = -189, z = 8328},
	{x =1731 , y = -189, z = 7823},
	{x =1618 , y = -189, z = 7197},
	{x =1513 , y = -189, z = 6763},
	{x =1526 , y = -189, z = 6142},
	{x =2781 , y = -189, z = 2475},
	{x =2435 , y = -189, z = 3012},
	{x =3681 , y = -189, z = 2049},
	{x =3423 , y = -189, z = 2590},
	{x =4151 , y = -189, z = 1789},
	{x =4771 , y = -189, z = 1633},
			}	

function ZedMain()
	if IsChatOpen() == 0 and tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client" and myHero.name == "Zed" then
	SetVariables()
	velocity()
	HarassModes()
	Killsteal()
	Jump1()
	send.tick()

	if ZedKeyConfig.Combo and timer2 == 0 then 
		Combo() 
		jump = false
	end
	if ZedKeyConfig.Escape and timer2 == 0 then Escape() end
	if ZedMiscConfig.ignite then ignite() end
	if ZedMiscConfig.Autolevel and timer2 == 0 then Autolevel() end
	if ZedDrawConfig.drawskillshots then Skillshots() end
	
end
end
	
	ZedKeyConfig, menu = uiconfig.add_menu('Zed Config', 250)
	menu.keydown('Combo', 'Combo', Keys.X)
	menu.keydown('Harass', 'Harass', Keys.Y)
    menu.keydown('Escape', 'Escape', Keys.W)
	menu.keydown('HarassMode', 'Change Harass Mode', Keys.F1)
	menu.permashow('Combo')
	menu.permashow('Harass')
	menu.permashow('Escape')

	ZedMiscConfig, menu = uiconfig.add_menu('Zed Misc Config', 200)
	menu.checkbutton('ignite', 'Auto-Ignite', true)
	menu.checkbutton('execute', 'Killsteal', true)
	menu.checkbutton('useItems', 'Auto Items', true)
	menu.checkbutton('Autolevel', 'Auto Level', false)
	menu.checkbutton('move', 'Movement', true)
	menu.checkbutton('jumphelper', 'JumpHelper', true)
	menu.slider('norcombo', 'Normal Combo', 1, 2, 2, {"Safe","Full"})
	menu.slider('ultcombo', 'Ult Combo', 1, 2, 2, {"Safe","Full"})
	
	ZedDrawConfig, menu = uiconfig.add_menu('Zed Draw Config', 200)
	menu.checkbutton('drawcircles', 'Circles on/off', true)
	menu.checkbutton('drawq', 'Draw Q-range', true)
	menu.checkbutton('draww', 'Draw W-range', true)
	menu.checkbutton('drawe', 'Draw E-range', false)
	menu.checkbutton('drawaa', 'Draw AAdam-range', false)
	menu.checkbutton('drawshadow', 'Draw Circle around Shadow', true)
	menu.checkbutton('drawenemy', 'Draw Circle around target', true)
	menu.checkbutton('drawksnote', 'Draw KS Notifications', true)
	menu.checkbutton('drawskillshots', 'Draw Skillshots', true)

function SetVariables()
	target = GetWeakEnemy('PHYS',1000)
	AArange = (myHero.range+(GetDistance(GetMinBBox(myHero), GetMaxBBox(myHero))/2))+15
	xa = 50/1920*GetScreenX()
	xb = 1870/1920*GetScreenX()
	ya = 50/1080*GetScreenY()
	yb = 1030/1080*GetScreenY()
	
	if GetTickCount() - ShadowTimer > 4000 then
		Shadow,ShadowX,ShadowY,ShadowZ = nil,nil,nil,nil
		ShadowTimer = 0
	end
	if GetTickCount() - timer2 > 500 then
		timer2 = 0
	end	
	if GetTickCount() - UltTimer > 3500 then
		ulttarget = nil
		UltTimer = 0
	end
	if timer ~= 0 then
		if GetTickCount() - timer > ((AAdelay+20)/myHero.attackspeed) then
			MoveToXYZ(myHero.x,0,myHero.z)
			MouseRightClick(GetLastOrder())
			timer = 0
		end
	end
	if GetTickCount() - timer > (((AAdelay+20)/myHero.attackspeed)+20*2) then
		timer = 0
	end
	
	if myHero.SpellTimeQ > 1.0 and GetSpellLevel('Q') ~= 0 and myHero.mana >= (80-(GetSpellLevel('Q')*5)) then QRDY = 1
		else QRDY = 0 end
	if myHero.SpellTimeW > 1.0 and GetSpellLevel('W') ~= 0 and myHero.mana >= (45-(GetSpellLevel('W')*5)) then WRDY = 1
		else WRDY = 0 end
	if myHero.SpellTimeE > 1.0 and GetSpellLevel('E') ~= 0 and myHero.mana >= 50 then ERDY = 1
		else ERDY = 0 end
	if myHero.SpellTimeR > 1.0 and GetSpellLevel('R') ~= 0 then RRDY = 1
		else RRDY = 0 end
	if myHero.SpellNameW == "ZedShadowDash" and myHero.SpellTimeW > 1.0 and GetSpellLevel('W')>0 and myHero.mana >= (45-(GetSpellLevel('W')*5)) then 
		W1RDY = 1
		W2RDY = 0
	else 
		W1RDY = 0 
	end
	if myHero.SpellNameW == "zedw2" then 
		W2RDY = 1
		W1RDY = 0
	else 
		W2RDY = 0 
	end
	for i = 1, objManager:GetMaxHeroes(), 1 do
		Hero = objManager:GetHero(i)
		if Hero ~= nil and Hero.team ~= myHero.team then
			if Enemies[Hero.name] == nil then
				Enemies[Hero.name] = { Unit = Hero, Number = EnemyIndex }
				EnemyIndex = EnemyIndex + 1
			end
		end
	end
end

function Killsteal()
	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0 and enemy.dead == 0) then
		
				local xAD = (getDmg("AD",enemy,myHero))
				local xRP = (((15*GetSpellLevel('R')+5)/100)*RRDY)
				local xQ1 = (getDmg("Q",enemy,myHero,1)*QRDY)
				local xQ2 = (getDmg("Q",enemy,myHero,3)*QRDY)
				local xQ3 = ((getDmg("Q",enemy,myHero,1)*2)*QRDY)
				local xE = (getDmg("E",enemy,myHero)*ERDY)
				local xR = (xAD*RRDY)
				
				local Qdam = (xQ1*QRDY)
				local Edam = (xE*ERDY)
				local QAAdam = ((xQ1+xAD)*QRDY)
				local EAAdam = ((xE+xAD)*ERDY)
				local EQdam = (((xQ1+xE)*QRDY)*ERDY)
				local EQAAdam = (((xQ1+xE+xAD)*QRDY)*ERDY)
				local WEdam = ((xE*W1RDY)*ERDY)
				local WQ1dam = ((xQ2*W1RDY)*QRDY)
				local WEQdam = ((((xQ2+xE)*W1RDY)*QRDY)*ERDY)
				local WQ2dam = (xQ1*W1RDY)
				local REAAdam = (((xR+xAD+xE+((xAD+xE)*xRP))*RRDY)*ERDY)
				local RQAAdam = (((xR+xAD+xQ2+((xAD+xQ2)*xRP))*RRDY)*QRDY)
				local REQAAdam = ((((xR+xAD+xQ2+xE+((xAD+xQ2+xE)*xRP))*RRDY)*ERDY)*QRDY)
				local RWQAAdam = ((((xR+xAD+xQ3+((xAD+xQ3)*xRP))*W1RDY)*RRDY)*QRDY)
				local RWEQAAdam = (((((xR+xAD+xQ3+xE+((xAD+xQ3+xE)*xRP))*W1RDY)*RRDY)*ERDY)*QRDY)
				
				if debugmode == true then
					if ZedMiscConfig.ultcombo == 1 then
						DrawText("Max. Damage: " .. round(math.max(Qdam,Edam,EQdam,WEdam,WQ1dam,WEQdam,WQ2dam,REAAdam,RQAAdam,REQAAdam),0),DrawX,DrawY-30,0xFFF0FFFF)
					elseif ZedMiscConfig.ultcombo == 2 then
						DrawText("Max. Damage: " .. round(math.max(Qdam,Edam,EQdam,WEdam,WQ1dam,WEQdam,WQ2dam,REAAdam,RQAAdam,REQAAdam,RWQAAdam,RWEQAAdam),0),DrawX,DrawY-30,0xFFF0FFFF)
					end
				end
	
			if ZedMiscConfig.execute then
				if enemy.health < Qdam and GetDistance(myHero,enemy) < Qrange then
					CustomCircle(75,30,5,enemy)
					SpellPred(Q,QRDY,myHero,enemy,Qrange,Qdelay,Qspeed)
					jump = false
				elseif enemy.health < Edam and (GetDistance(myHero,enemy) < Erange or (W2RDY == 1 and Shadow ~= nil and GetDistance(Shadow,enemy) < Erange)) then
					CustomCircle(75,30,5,enemy)
					SpellXYZ(E,ERDY,myHero,enemy,Erange,myHero.x,myHero.z)
					AttackTarget(enemy)
					jump = false
				elseif enemy.health < QAAdam and GetDistance (myHero,enemy) < AArange then
					CustomCircle(75,30,5,enemy)
					SpellPred(Q,QRDY,myHero,enemy,Qrange,Qdelay,Qspeed)
					AttackTarget(enemy)
					jump = false
				elseif enemy.health < EAAdam and GetDistance (myHero,enemy) < AArange then
					CustomCircle(75,30,5,enemy)
					SpellXYZ(E,ERDY,myHero,enemy,Erange,myHero.x,myHero.z)
					AttackTarget(enemy)
					jump = false
				elseif enemy.health < EQdam and (GetDistance(myHero,enemy) < Erange or (W2RDY == 1 and Shadow ~= nil and GetDistance(Shadow,enemy) < Erange)) then
					CustomCircle(75,30,5,enemy)
					SpellXYZ(E,ERDY,myHero,enemy,Erange,myHero.x,myHero.z)
					SpellPred(Q,QRDY,myHero,enemy,Qrange,Qdelay,Qspeed)
					jump = false
				elseif enemy.health < EQAAdam and GetDistance(myHero,enemy) < AArange then
					CustomCircle(75,30,5,enemy)
					SpellXYZ(E,ERDY,myHero,enemy,Erange,myHero.x,myHero.z)
					SpellPred(Q,QRDY,myHero,enemy,Qrange,Qdelay,Qspeed)
					AttackTarget(enemy)
					jump = false
				elseif enemy.health < WEdam and GetDistance(myHero,enemy) > Erange and GetDistance(myHero,enemy) < Wrange+Erange then
					CustomCircle(75,30,5,enemy)
					W_Spell_delayed()
					SpellXYZ(E,ERDY,myHero,enemy,Erange,myHero.x,myHero.z)
					SpellXYZ(E,ERDY,Shadow,enemy,Erange,myHero.x,myHero.z)
					jump = false
				elseif enemy.health < WQ1dam and GetDistance(myHero,enemy) < Qrange then
					CustomCircle(75,30,5,enemy)
					W_Spell_delayed()
					SpellPred(Q,QRDY,myHero,enemy,Qrange,Qdelay,Qspeed)
					jump = false
				elseif enemy.health < WEQdam and GetDistance(myHero,enemy) < Wrange and GetDistance(myHero,enemy) > Erange then
					CustomCircle(75,30,5,enemy)
					W_Spell_delayed()
					SpellXYZ(E,ERDY,myHero,enemy,Erange,myHero.x,myHero.z)
					SpellXYZ(E,ERDY,Shadow,enemy,Erange,myHero.x,myHero.z)
					SpellPred(Q,QRDY,myHero,enemy,Qrange,Qdelay,Qspeed)
					jump = false
				elseif enemy.health < WQ2dam and GetDistance(myHero,enemy) < Qrange+Wrange and GetDistance(myHero,enemy) > Qrange then
					CustomCircle(75,30,5,enemy)
					W_Spell_delayed()
					Prediction_Shadow_enemy()
					jump = false
				elseif (enemy.health < REAAdam or enemy.health < RQAAdam or enemy.health < REQAAdam) and GetDistance(myHero,enemy) < Rrange then
					CustomCircle(75,30,5,enemy)
					DrawTextObject("HOLD COMBO", myHero, 0xFFFFFF00)
					SpellTarget(R,RRDY,myHero,enemy,Rrange)
					jump = false
				elseif ZedMiscConfig.ultcombo == 2 and (enemy.health < RWQAAdam or enemy.health < RWEQAAdam) and GetDistance(myHero,enemy) < Rrange then
					CustomCircle(75,30,5,enemy)
					DrawTextObject("HOLD COMBO", myHero, 0xFFFFFF00)
					SpellTarget(R,RRDY,myHero,enemy,Rrange)
					jump = false
				end
			end
			if ZedDrawConfig.drawksnote then
				if enemy.health < Qdam then DrawTextObject("Q", enemy, 0xFF00EE00)
				elseif enemy.health < Edam then DrawTextObject("E", enemy, 0xFF00EE00)
				elseif enemy.health < EQdam then DrawTextObject("EQ", enemy, 0xFF00EE00)
				elseif enemy.health < WEdam then DrawTextObject("WE", enemy, 0xFF00EE00)
				elseif enemy.health < WQ1dam then DrawTextObject("WQ1", enemy, 0xFF00EE00)
				elseif enemy.health < WEQdam then DrawTextObject("WEQ", enemy, 0xFF00EE00)
				elseif enemy.health < WQ2dam then DrawTextObject("WWQ", enemy, 0xFF00EE00)
				elseif enemy.health < REAAdam then DrawTextObject("REAA", enemy, 0xFF00EE00)
				elseif enemy.health < RQAAdam then DrawTextObject("RQAA", enemy, 0xFF00EE00)
				elseif enemy.health < REQAAdam then DrawTextObject("REQAA", enemy, 0xFF00EE00)
				elseif enemy.health < RWQAAdam and ZedMiscConfig.ultcombo == 2 then DrawTextObject("RWQAA", enemy, 0xFF00EE00)
				elseif enemy.health < RWEQAAdam and ZedMiscConfig.ultcombo == 2 then DrawTextObject("RWEQAA", enemy, 0xFF00EE00)
				end
			end
		end
	end
end

function Combo()
	local targetaa = GetWeakEnemy('PHYS',(myHero.range+(GetDistance(GetMinBBox(myHero), GetMaxBBox(myHero))/2)+15))
	if ulttarget ~= nil then
		if ZedMiscConfig.ultcombo == 1 then
			SpellPred(Q,QRDY,myHero,ulttarget,Qrange,Qdelay,Qspeed)
			SpellXYZ(E,ERDY,myHero,ulttarget,Erange,myHero.x,myHero.z)
			SpellXYZ(E,ERDY,Shadow,ulttarget,Erange,myHero.x,myHero.z)
		elseif ZedMiscConfig.ultcombo == 2 then
			if GetTickCount() - UltTimer > 520 then
				WSpecial_delayed()
				if (W2RDY == 1 or WRDY == 0) then
					SpellPred(Q,QRDY,myHero,ulttarget,Qrange,Qdelay,Qspeed)
				end	
				SpellXYZ(E,ERDY,myHero,ulttarget,Erange,myHero.x,myHero.z)
				SpellXYZ(E,ERDY,Shadow,ulttarget,Erange,myHero.x,myHero.z)
				if (W2RDY == 1 or WRDY == 0) and GetDistance(ulttarget)>AArange and (Shadow ~= nil and GetDistance(Shadow,ulttarget)<Erange) then
					CastSpellXYZ('W',myHero.x,0,myHero.z)
				end
			end
		end
	elseif target ~= nil then
		if ZedMiscConfig.norcombo == 1 then
			SpellPred(Q,QRDY,myHero,target,Qrange,Qdelay,Qspeed)
			SpellXYZ(E,ERDY,myHero,target,Erange,myHero.x,myHero.z)
			SpellXYZ(E,ERDY,Shadow,target,Erange,myHero.x,myHero.z)
		elseif ZedMiscConfig.norcombo == 2 then
			if QRDY == 1 and W1RDY == 1 and GetDistance(target)<Qrange and GetDistance(target)>AArange+50  then 
				W_Spell_delayed()
			end
			if ERDY == 1 and W1RDY == 1 and GetDistance(target)>Erange and GetDistance(target)<Wrange+Erange and GetDistance(target)>AArange+50 then
				W_Spell_delayed()
			end
			if W1RDY == 1 and QRDY == 0 and GetDistance(target)<Wrange and GetDistance(target)>AArange+50 then
				W_Spell_delayed()
			end
			if (W2RDY == 1 or WRDY == 0) and QRDY == 1 then
				SpellPred(Q,QRDY,myHero,target,Qrange,Qdelay,Qspeed)
			end	
			SpellXYZ(E,ERDY,myHero,target,Erange,myHero.x,myHero.z)
			SpellXYZ(E,ERDY,Shadow,target,Erange,myHero.x,myHero.z)
			if W2RDY == 1 and Shadow ~= nil and (QRDY == 0 or GetDistance(target)>Qrange) and GetDistance(target)>AArange and GetDistance(Shadow,target)<Erange then
				SpellXYZ(W,W2RDY,Shadow,target,AArange,myHero.x,myHero.z)
			end
		end
		
		-----------------------------
	end
	if targetaa ~= nil then
		if ZedMiscConfig.useItems then
			UseAllItems(targetaa)
		end
		AttackTarget(targetaa)
	end
	if ZedMiscConfig.move and timer == 0 then
		if ulttarget == nil or target == nil then
			MoveToMouse()
		elseif ulttarget ~= nil then
			MoveToXYZ(ulttarget.x,0,ulttarget.z)
		elseif target ~= nil then
			 MoveToXYZ(target.x,0,target.z)
		end
	end
end

function Harass1() -- Q
	SpellPred(Q,QRDY,myHero,target,Qrange,Qdelay,Qspeed)
end

function Harass2() -- W-E
	if target ~= nil then
		if ERDY == 1 and GetDistance(target) < (Wrange+Erange) and GetDistance(target) > Erange then
			W2_Spell_delayed()
		end
		SpellXYZ(E,ERDY,myHero,target,Erange,myHero.x,myHero.z)
		SpellXYZ(E,ERDY,Shadow,target,Erange,myHero.x,myHero.z)
	end
end

function Harass3() --  -- W-Q (900 range)
	if target ~= nil then
		if QRDY == 1 and GetDistance(target) < Qrange then
			W2_Spell_delayed()
		end
		if W2RDY == 1 or WRDY == 0 then
			SpellPred(Q,QRDY,myHero,target,Qrange,Qdelay,Qspeed)
		end
	end
end

function Harass4() -- W-Q (1450 range)
local target2 = GetWeakEnemy('PHYS',(Qrange+Wrange))
	if QRDY == 1 and GetDistance(target2) < Qrange+Wrange then
		W_Spell_delayed_target2()
	end
	if (W2RDY == 1 and QRDY == 1) and GetDistance(target2) < Qrange+Wrange then
		Prediction_Shadow_target2()
	end
end

function Harass5() -- W-E-Q
	if target ~= nil then
		if QRDY == 1 and W1RDY == 1 and GetDistance(target)<Qrange then 
			W_Spell_delayed()
		end
		if ERDY == 1 and W1RDY == 1 and GetDistance(target)>Erange and GetDistance(target)<Wrange+Erange then
			W_Spell_delayed()
		end
		if W1RDY == 1 and QRDY == 0 and GetDistance(target)<Wrange and GetDistance(target)>AArange then
			W_Spell_delayed()
		end
		if (W2RDY == 1 or WRDY == 0) and QRDY == 1 then
			SpellPred(Q,QRDY,myHero,target,Qrange,Qdelay,Qspeed)
		end	
		SpellXYZ(E,ERDY,myHero,target,Erange,myHero.x,myHero.z)
		SpellXYZ(E,ERDY,Shadow,target,Erange,myHero.x,myHero.z)
	end
end

function Escape()	
	local MousePos = Vector(mousePos)
	local HeroPos = Vector(myHero.x,0,myHero.z)
	local ShadowPos = HeroPos+(HeroPos-MousePos )*(-Wrange+100)
	SpellXYZ(W,W1RDY,myHero,myHero,1,ShadowPos.x,ShadowPos.z)
	SpellXYZ(W,W2RDY,myHero,Shadow,1200,myHero.x,myHero.z)
	MoveToMouse()
end

function HarassModes()
	DrawText("Harass Mode:",DrawX,DrawY-10,0xFFF0FFFF)
	if (ZedKeyConfig.HarassMode and os.clock() - toggle_timer>0.3) then
		toggle_timer = os.clock()
		Harass_Mode = ((Harass_Mode+1)%7)
	end
	if (Harass_Mode == 1) then
		DrawText("Q",DrawX,DrawY,0xFFF0FFFF)
	elseif (Harass_Mode == 2) then
		DrawText("W-E",DrawX,DrawY,0xFFF0FFFF)
	elseif (Harass_Mode == 3) then
		DrawText("W-Q (900 range)",DrawX,DrawY,0xFFF0FFFF)
	elseif (Harass_Mode == 4) then
		DrawText("W-Q (1450 range)",DrawX,DrawY,0xFFF0FFFF)
	elseif (Harass_Mode == 5) then
		DrawText("W-E-Q",DrawX,DrawY,0xFFF0FFFF)
	elseif (Harass_Mode == 6) then
		DrawText("Q+Auto-E",DrawX,DrawY,0xFFF0FFFF)
	else
		DrawText("OFF",DrawX,DrawY,0xFFF0FFFF)
		return
	end
	
	if ZedKeyConfig.Harass then
		if Harass_Mode == 1 then Harass1()
		elseif Harass_Mode == 2 then Harass2()
		elseif Harass_Mode == 3 then Harass3()
		elseif Harass_Mode == 4 then Harass4()
		elseif Harass_Mode == 5 then Harass5()
		elseif Harass_Mode == 6 then Harass1()
		end
	end
	if Harass_Mode == 6 then
		if GetSpellLevel('E') > 1 then
			SpellXYZ(E,ERDY,myHero,target,Erange,myHero.x,myHero.z)
			SpellXYZ(E,ERDY,Shadow,target,Erange,myHero.x,myHero.z)
		end
	end
end

function W_Spell()
	if target ~= nil and W1RDY == 1 then CastSpellXYZ('W',GetFireahead(target,Wdelay,Wspeed)) end
	if enemy ~= nil and W1RDY == 1 then CastSpellXYZ('W',GetFireahead(enemy,Wdelay,Wspeed)) end
end

function W2_Spell()
	SpellPred(W,W1RDY,myHero,target,(Wrange+Erange),Wdelay,Wspeed)
end

function W_Spell_target2()
	local target2 = GetWeakEnemy('PHYS',(Qrange+Wrange))
	SpellPred(W,W1RDY,myHero,target2,(Qrange+Wrange),Wdelay,Wspeed)
end

function WSpecial()
	if ulttarget ~= nil then CastSpellXYZ('W',GetFireahead(ulttarget,Wdelay,Wspeed)) end
end

function WSpecial_delayed()
	run_every(0.2,W_Spell)
end

function W_Spell_delayed()
	run_every(8,W_Spell)
end

function W2_Spell_delayed()
	run_every(8,W2_Spell)
end

function W_Spell_delayed_target2()
	run_every(8,W_Spell_target2)
end

function OnDraw()
	if myHero.dead == 0 then
		if ZedDrawConfig.drawcircles then
			if ZedDrawConfig.drawq then
				if QRDY == 1 then
					CustomCircle(Qrange,2,2,myHero)
				else
					CustomCircle(Qrange,2,3,myHero)
				end
			end
			
			if ZedDrawConfig.draww then
				if W1RDY == 1 then
					CustomCircle(Wrange,1,3,myHero)
				end
			end
			
			if ZedDrawConfig.drawe then
				if ERDY == 1 then
					CustomCircle(Erange,1,1,myHero)
				end
			end
			
			if ZedDrawConfig.drawshadow then
				if Shadow ~= nil and ERDY == 1 then
					CustomCircle(Erange,3,2,Shadow)
				elseif Shadow ~= nil and ERDY == 0 then
					CustomCircle(75,5,1,Shadow)
				end
			end
			
			if ZedDrawConfig.drawaa then
				CustomCircle(AArange,1,2,myHero)
			end
			
			if ZedDrawConfig.drawenemy then
				if target ~= nil then
					CustomCircle(100,4,2,target)
				end
			end
		end
		for _, JumpSpot in pairs(JumpSpots) do
			if ZedMiscConfig.jumphelper and GetMap() == 2 then
				if GetDistance(JumpSpot,myHero) <= ShowRange then
					if GetDistance(JumpSpot,mousePos) <= jumpmouserange then
						DrawCircle(JumpSpot.x, JumpSpot.y, JumpSpot.z, jumpmouserange, 0xFFFF0000)
					else DrawCircle(JumpSpot.x, JumpSpot.y, JumpSpot.z, jumpmouserange, 0xFFFF8000)
					end
				end
			end
		end
		if myHero.mana<math.min((QRDY*(80-(GetSpellLevel('Q')*5))),(ERDY*50)) then
			DrawTextObject("LOW ENERGY", myHero, 0xFFFF8000)
		end
	end
	for i, Enemy in pairs(Enemies) do
		if Enemy ~= nil then
			Hero = Enemy.Unit
			local PositionX = (13.3/16) * GetScreenX()
			local QDMG = getDmg('Q', Hero, myHero)+(getDmg('Q',Hero,myHero)*(HavocDamage + ExecutionerDamage))
			local WDMG = getDmg('W', Hero, myHero)+(getDmg('W',Hero,myHero)*(HavocDamage + ExecutionerDamage))
			local EDMG = getDmg('E', Hero, myHero)+(getDmg('E',Hero,myHero)*(HavocDamage + ExecutionerDamage))
			local RDMG = getDmg('R', Hero, myHero)+(getDmg('R',Hero,myHero)*(HavocDamage + ExecutionerDamage))
			local Current_Burst
			local Damage
			if myHero.selflevel >= 6 and myHero.SpellTimeR > 1.0 then
				Current_Burst = Round(WDMG + EDMG + RDMG, 0) --Show damage of WER combo if Ult is available
			else
				Current_Burst = Round(WDMG + EDMG, 0) --Show damage of WE combo if Ult is not available
			end
			if myHero.SummonerD == 'SummonerDot' and myHero.SpellTimeD > 1.0 or myHero.SummonerF == 'SummonerDot' and myHero.SpellTimeF > 1.0 then
				Current_Burst = Current_Burst + ((myHero.selflevel*20)+50) --If Ignite detected and is not on cooldown add ignite damage to combo damage
			end
			Damage = Current_Burst	
			DrawText("Champion: "..Hero.name, PositionX, ((15/900) * GetScreenY()) * Enemy.Number + ((53/90) * GetScreenY()), 0xFF87CEFA)	
			if Hero.visible == 1 and Hero.dead ~= 1 then
				if Damage < Hero.health then
					DrawText("DMG "..Damage, PositionX + 150, ((15/900) * GetScreenY()) * Enemy.Number + ((53/90) * GetScreenY()), 0xFFFFFF00)
				elseif Damage > Hero.health then
					DrawText("Killable!", PositionX + 150, ((15/900) * GetScreenY()) * Enemy.Number + ((53/90) * GetScreenY()), 0xFFFF0000)
				end
			end		
			if Hero.visible == 0 and Hero.dead ~= 1 then
				DrawText("MIA", PositionX + 150, ((15/900) * GetScreenY()) * Enemy.Number + ((53/90) * GetScreenY()), 0xFFFF8000)
			elseif Hero.dead == 1 then
				DrawText("Dead", PositionX + 150, ((15/900) * GetScreenY()) * Enemy.Number + ((53/90) * GetScreenY()), 0xFF32CD32)
			end
		end
	end
end

function Round(val, decimal)
	if (decimal) then
		return math.floor( (val * 10 ^ decimal) + 0.5) / (10 ^ decimal)
	else
		return math.floor(val + 0.5)
	end
end

function Prediction_Shadow_target2()
	local target2 = GetWeakEnemy('PHYS',(Qrange+Wrange))
	if target2 ~= nil then
		local bq = bestcoords(target2)
		local vts = hero_table[target2.name][3]
		if Shadow ~= nil and (W2RDY == 1 and QRDY == 1) and GetDistance(Shadow, target2) < Qrange then
			if  bq == 1  and vts:len() ~= 0 then
				CastSpellXYZ('Q',qx, qy, qz)
			elseif bq == 1 and vts:len() == 0 then
				CastSpellXYZ('Q',qx, qy, qz)
			end
		end
	end
end

function Prediction_Shadow_enemy()
	if enemy ~= nil then
		local bq = bestcoords(enemy)
		local vts = hero_table[enemy.name][3]
		if Shadow ~= nil and GetDistance(Shadow, enemy) < Qrange then
			if  bq == 1  and vts:len() ~= 0 then
				CastSpellXYZ('Q',qx, qy, qz)
			elseif bq == 1 and vts:len() == 0 then
				CastSpellXYZ('Q',qx, qy, qz)
			end
		end
	end
end

function bestcoords(btarget)
	if Shadow ~= nil then
		local x1,y1,z1 = GetFireahead(btarget,Qdelay,Qspeed)
		local ve= Vector(x1 - btarget.x,y1 - btarget.y,z1 - btarget.z) -- getfireahead - target
		local nb = btarget.name
		local vvt = hero_table[nb][3] -- velocity vector of target
		if Shadow.x ~= nil then
			vst = Vector(btarget.x - Shadow.x,btarget.y-Shadow.y,btarget.z - Shadow.z) -- target - Shadow
			vse = Vector(x1-Shadow.x,y1-Shadow.y,z1-Shadow.z) -- getfireahead - Shadow
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
		elseif Shadow ~= nil and vvt:len() == 0 and vst:len() < 1485 then
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

function OnCreateObj(obj)
	if obj ~= nil then
		if obj.charName == "Shadow" and GetDistance(myHero,obj) < 550 then
			Shadow = obj
		end
		if obj.charName == "Zed_CloneDeath.troy" and GetDistance(myHero,obj) < 550 then
			Shadow = nil
		end
	end
end

function OnProcessSpell(unit,spell)
	local targetult = GetWeakEnemy('PHYS',Rrange)
	local targetaa = GetWeakEnemy('PHYS',(myHero.range+(GetDistance(GetMinBBox(myHero), GetMaxBBox(myHero))/2)+15))
    if unit ~= nil and spell ~= nil and unit.charName == myHero.charName then
 		if spell.name == "ZedShadowDash" then
			ShadowTimer = GetTickCount()
			ShadowX = spell.endPos.x
			ShadowY = spell.endPos.y
			ShadowZ = spell.endPos.z
		end
		if spell.name == "zedw2" then
			ShadowX = myHero.x
			ShadowY = myHero.y
			ShadowZ = myHero.z
		end
		if targetaa ~= nil then
			if (spell.name == "ZedBasicAttack" or spell.name == "ZedBasicAttack2" or spell.name == "ZedCritAttack") and spell.target ~= nil and spell.target.name == targetaa.name and ZedKeyConfig.Combo then
				timer = GetTickCount()
				jump = false
			end
		end
		if targetult ~= nil then
			if spell.name == "zedult" and spell.target ~= nil and spell.target.name == targetult.name then
				ulttarget = targetult
				UltTimer = GetTickCount()
				jump = false
			end
		end
	end
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
	dodgex = x4 + ((radius+75)/calc3)*(myHero.x-x4)
	dodgez = z4 + ((radius+75)/calc3)*(myHero.z-z4)
	if perpendicular < radius and calc1 < calc4 and calc2 < calc4 and GetCursorX() > xa and GetCursorX() < xb and GetCursorY() > ya and GetCursorY() < yb then
		timer2 = GetTickCount()
		if not ZedKeyConfig.Combo and GetCursorX() > xa and GetCursorX() < xb and GetCursorY() > ya and GetCursorY() < yb then send.block_input(true,500) end
        MoveToXYZ(dodgex,0,dodgez)
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
	dodgex = x4 + ((radius+75)/calc3)*(myHero.x-x4)
	dodgez = z4 + ((radius+75)/calc3)*(myHero.z-z4)
	if perpendicular < radius and calc1 < calc4 and calc2 < calc4  and GetCursorX() > xa and GetCursorX() < xb and GetCursorY() > ya and GetCursorY() < yb then
		timer2 = GetTickCount()
		if not ZedKeyConfig.Combo and GetCursorX() > xa and GetCursorX() < xb and GetCursorY() > ya and GetCursorY() < yb then send.block_input(true,500) end
        MoveToXYZ(dodgex,0,dodgez)
	end
end

function Autolevel()
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
	send.tick()
end

function Skillshots()
	cc=cc+1
	if (cc==30) then
		LoadTable()
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
	for i=1, #skillshotArray, 1 do
		if os.clock() > (skillshotArray[i].lastshot + skillshotArray[i].time) then
		skillshotArray[i].shot = 0
		end
	end
end

function SpellTarget(spell,cd,a,b,range)
	if cd == 1 and a ~= nil and b ~= nil and GetDistance(a,b) < range then
		CastSpellTarget(spell,b)
	end
end

function SpellXYZ(spell,cd,a,b,range,x,z)
	local y = 0
	if cd == 1 and a ~= nil and b ~= nil and x ~= nil and z ~= nil and GetDistance(a,b) < range then
		CastSpellXYZ(spell,x,y,z)
	end
end

function SpellPred(spell,cd,a,b,range,delay,speed)
	if cd == 1 and a ~= nil and b ~= nil and delay ~= nil and speed ~= nil and GetDistance(a,b) < range then
		CastSpellXYZ(spell,GetFireahead(b,delay,speed))
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

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function Level_Spell(letter)  
     if letter == Q then send.key_press(0x69)
     elseif letter == W then send.key_press(0x6a)
     elseif letter == E then send.key_press(0x6b)
     elseif letter == R then send.key_press(0x6c) end
end

function ignite()
	local targetignite = GetWeakEnemy('TRUE',600)
	local damage = (myHero.selflevel*20)+50
	if targetignite ~= nil then
		if myHero.SummonerD == "SummonerDot" then
			if targetignite.health < damage then
				CastSpellTarget("D",targetignite)
			end
		end
		if myHero.SummonerF == "SummonerDot" then
			if targetignite.health < damage then
				CastSpellTarget("F",targetignite)
			end
		end
	end
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

function run_every(interval, fn, ...)
    return internal_run({fn=fn, interval=interval}, ...)
end

function internal_run(t, ...)    
    local fn = t.fn
    local key = t.key or fn
    local now = os.clock()
    local data = _registry[key]  
    if data == nil or t.reset then
        local args = {}
        local n = select('#', ...)
        local v
        for i=1,n do
            v = select(i, ...)
            table.insert(args, v)
        end        
        data = {count=0, last=0, complete=false, t=t, args=args}
        _registry[key] = data
    end      
    local countCheck = (t.count==nil or data.count < t.count)
    local startCheck = (data.t.start==nil or now >= data.t.start)
    local intervalCheck = (t.interval==nil or now-data.last >= t.interval)
    if not data.complete and countCheck and startCheck and intervalCheck then                
        if t.count ~= nil then
            data.count = data.count + 1
        end
        data.last = now          
        if t._while==nil and t._until==nil then
            return fn(...)
        else
            local signal = t._until ~= nil
            local checker = t._while or t._until
            local result
            if fn == checker then            
                result = fn(...)
                if result == signal then
                    data.complete = true
                end
                return result
            else
                result = checker(...)
                if result == signal then
                    data.complete = true
                else
                    return fn(...)
                end
            end            
        end
    end    
end

function dodgeaoe(pos1, pos2, radius)
	local calc = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
	local dodgex
	local dodgez
	dodgex = pos2.x + ((radius+50)/calc)*(myHero.x-pos2.x)
	dodgez = pos2.z + ((radius+50)/calc)*(myHero.z-pos2.z)
	if calc < radius then
		MoveToXYZ(dodgex,0,dodgez)
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
			table.insert(skillshotArray,{name= "LuxLightBinding", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1175, type = 1, radius = 225, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
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
			table.insert(skillshotArray,{name= "WildCards", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1450, type = 1, radius = 150, color= colorcyan, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
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
			table.insert(skillshotArray,{name= "VarusQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1475, type = 1, radius = 50, color= coloryellow, time = 1})
			table.insert(skillshotArray,{name= "VarusR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 150, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Veigar" then
			table.insert(skillshotArray,{name= "VeigarDarkMatter", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 225, color= coloryellow, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Viktor" then
			table.insert(skillshotArray,{name= "ViktorDeathRay", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 150, color= coloryellow, time = 2})
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

function Jump1()
	local a1x,a1z = 8429,2475
	local b1x,b1z = 8138,3035
	local a2x,a2z = 7879,2275
	local b2x,b2z = 7714,2665
	local a3x,a3z = 9829,3275
	local b3x,b3z = 9317,3658
	local a4x,a4z = 10029,8223
	local b4x,b4z = 10522,8629
	local a5x,a5z = 9579,8873
	local b5x,b5z = 10123,9208
	local a9x,a9z = 9179,1525
	local b9x,b9z = 9784,1732
	local a10x,a10z = 7979,9523
	local b10x,b10z = 7753,10077
	local a11x,a11z = 5959,9491
	local b11x,b11z = 6300,9864
	local a12x,a12z = 5531,9723
	local b12x,b12z = 5354,10293
	local a13x,a13z = 4257,8867
	local b13x,b13z = 3698,9061
	local a14x,a14z = 3881,8223
	local b14x,b14z = 3348,8575
	local a15x,a15z = 4581,3675
	local b15x,b15z = 4095,3276
	local a16x,a16z = 5731,3025
	local b16x,b16z = 5568,2449
	local a17x,a17z = 6231,2625
	local b17x,b17z = 6023,2261
	local a18x,a18z = 6377,3809
	local b18x,b18z = 6626,3230
	local a19x,a19z = 7529,3775
	local b19x,b19z = 7642,3198
	local a20x,a20z = 9279,5375
	local b20x,b20z = 8705,5523
	local a21x,a21z = 9499,5843
	local b21x,b21z = 9071,6318
	local a22x,a22z = 4443,5833
	local b22x,b22z = 4659,6434
	local a23x,a23z = 4581,5525
	local b23x,b23z = 5176,5467
	local a24x,a24z = 6631,8373
	local b24x,b24z = 7270,8386
	local a25x,a25z = 5631,7073
	local b25x,b25z = 5522,7703
	local a26x,a26z = 8329,5725
	local b26x,b26z = 7756,6007
	local a27x,a27z = 8479,6275
	local b27x,b27z = 8049,6573
	local a28x,a28z = 7069,4447
	local b28x,b28z = 7584,4753
	local a29x,a29z = 5581,5775
	local b29x,b29z = 6184,5972
	local a30x,a30z = 5456,6192
	local b30x,b30z = 5921,6390
	local a31x,a31z = 8759,9639
	local b31x,b31z = 8875,10218
	local a32x,a32z = 8329,9723
	local b32x,b32z = 8264,10359
	local a33x,a33z = 10179,2075
	local b33x,b33z = 10537,2604
	local a34x,a34z = 11129,2525
	local b34x,b34z = 11564,2993
	local a35x,a35z = 12379,6773
	local b35x,b35z = 12332,6136
	local a36x,a36z = 12379,7223
	local b36x,b36z = 12198,7835
	local a37x,a37z = 12119,8295
	local b37x,b37z = 11979,8877
	local a38x,a38z = 6945,11493
	local b38x,b38z = 6935,11893
	local a39x,a39z = 6925,10579
	local b39x,b39z = 6939,9942
	local a40x,a40z = 2069,8901
	local b40x,b40z = 1923,8328
	local a41x,a41z = 1731,7823
	local b41x,b41z = 1618,7197
	local a42x,a42z = 1513,6763
	local b42x,b42z = 1526,6142
	local a43x,a43z = 2781,2475
	local b43x,b43z = 2435,3012
	local a44x,a44z = 3681,2049
	local b44x,b44z = 3423,2590
	local a45x,a45z = 4151,1789
	local b45x,b45z = 4771,1633
	
	for _, JumpSpot in pairs(JumpSpots) do
		if GetDistance(JumpSpot,mousePos) <= jumpmouserange and KeyDown(1) and ZedMiscConfig.jumphelper and GetMap() == 2 then
			MoveToXYZ(JumpSpot.x,JumpSpot.y,JumpSpot.z)
			jump = true
		end
	end
	
	if KeyDown(2) and ZedMiscConfig.jumphelper then
		jump = false
	end
	
	if jump == true and ZedMiscConfig.jumphelper and W1RDY == 1 and GetMap() == 2 then
		if distXYZ(a1x,a1z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b1x,-189,b1z)
		elseif distXYZ(b1x,b1z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a1x,-189,a1z)
		elseif distXYZ(a2x,a2z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b2x,-189,b2z)
		elseif distXYZ(b2x,b2z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a2x,-189,a2z)
		elseif distXYZ(a3x,a3z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b3x,-189,b3z)
		elseif distXYZ(b3x,b3z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a3x,-189,a3z)
		elseif distXYZ(a4x,a4z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b4x,-189,b4z)
		elseif distXYZ(b4x,b4z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a4x,-189,a4z)
		elseif distXYZ(a5x,a5z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b5x,-189,b5z)
		elseif distXYZ(b5x,b5z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a5x,-189,a5z)
		elseif distXYZ(a9x,a9z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b9x,-189,b9z)
		elseif distXYZ(b9x,b9z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a9x,-189,a9z)
		elseif distXYZ(a10x,a10z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b10x,-189,b10z)
		elseif distXYZ(b10x,b10z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a10x,-189,a10z)
		elseif distXYZ(a11x,a11z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b11x,-189,b11z)
		elseif distXYZ(b11x,b11z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a11x,-189,a11z)
		elseif distXYZ(a12x,a12z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b12x,-189,b12z)
		elseif distXYZ(b12x,b12z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a12x,-189,a12z)
		elseif distXYZ(a13x,a13z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b13x,-189,b13z)
		elseif distXYZ(b13x,b13z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a13x,-189,a13z)
		elseif distXYZ(a14x,a14z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b14x,-189,b14z)
		elseif distXYZ(b14x,b14z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a14x,-189,a14z)
		elseif distXYZ(a15x,a15z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b15x,-189,b15z)
		elseif distXYZ(b15x,b15z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a15x,-189,a15z)
		elseif distXYZ(a16x,a16z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b16x,-189,b16z)
		elseif distXYZ(b16x,b16z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a16x,-189,a16z)
		elseif distXYZ(a17x,a17z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b17x,-189,b17z)
		elseif distXYZ(b17x,b17z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a17x,-189,a17z)
		elseif distXYZ(a18x,a18z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b18x,-189,b18z)
		elseif distXYZ(b18x,b18z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a18x,-189,a18z)
		elseif distXYZ(a19x,a19z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b19x,-189,b19z)
		elseif distXYZ(b19x,b19z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a19x,-189,a19z)
		elseif distXYZ(a20x,a20z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b20x,-189,b20z)
		elseif distXYZ(b20x,b20z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a20x,-189,a20z)
		elseif distXYZ(a21x,a21z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b21x,-189,b21z)
		elseif distXYZ(b21x,b21z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a21x,-189,a21z)
		elseif distXYZ(a22x,a22z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b22x,-189,b22z)
		elseif distXYZ(b22x,b22z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a22x,-189,a22z)
		elseif distXYZ(a23x,a23z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b23x,-189,b23z)
		elseif distXYZ(b23x,b23z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a23x,-189,a23z)
		elseif distXYZ(a24x,a24z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b24x,-189,b24z)
		elseif distXYZ(b24x,b24z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a24x,-189,a24z)
		elseif distXYZ(a25x,a25z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b25x,-189,b25z)
		elseif distXYZ(b25x,b25z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a25x,-189,a25z)
		elseif distXYZ(a26x,a26z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b26x,-189,b26z)
		elseif distXYZ(b26x,b26z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a26x,-189,a26z)
		elseif distXYZ(a27x,a27z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b27x,-189,b27z)
		elseif distXYZ(b27x,b27z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a27x,-189,a27z)
		elseif distXYZ(a28x,a28z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b28x,-189,b28z)
		elseif distXYZ(b28x,b28z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a28x,-189,a28z)
		elseif distXYZ(a29x,a29z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b29x,-189,b29z)
		elseif distXYZ(b29x,b29z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a29x,-189,a29z)
		elseif distXYZ(a30x,a30z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b30x,-189,b30z)
		elseif distXYZ(b30x,b30z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a30x,-189,a30z)
		elseif distXYZ(a31x,a31z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b31x,-189,b31z)	
		elseif distXYZ(b31x,b31z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a31x,-189,a31z)
		elseif distXYZ(a32x,a32z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b32x,-189,b32z)
		elseif distXYZ(b32x,b32z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a32x,-189,a32z)
		elseif distXYZ(a33x,a33z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b33x,-189,b33z)	
		elseif distXYZ(b33x,b33z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a33x,-189,a33z)
		elseif distXYZ(a34x,a34z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b34x,-189,b34z)		
		elseif distXYZ(b34x,b34z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a34x,-189,a34z)	
		elseif distXYZ(a35x,a35z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b35x,-189,b35z)		
		elseif distXYZ(b35x,b35z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a35x,-189,a35z)	
		elseif distXYZ(a36x,a36z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b36x,-189,b36z)		
		elseif distXYZ(b36x,b36z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a36x,-189,a36z)		
		elseif distXYZ(a37x,a37z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b37x,-189,b37z)			
		elseif distXYZ(b37x,b37z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a37x,-189,a37z)	
		elseif distXYZ(a38x,a38z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b38x,-189,b38z)		
		elseif distXYZ(b38x,b38z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a38x,-189,a38z)	
		elseif distXYZ(a39x,a39z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b39x,-189,b39z)	
		elseif distXYZ(b39x,b39z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a39x,-189,a39z)		
		elseif distXYZ(a40x,a40z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b40x,-189,b40z)		
		elseif distXYZ(b40x,b40z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a40x,-189,a40z)
		elseif distXYZ(a41x,a41z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b41x,-189,b41z)		
		elseif distXYZ(b41x,b41z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a41x,-189,a41z)	
		elseif distXYZ(a42x,a42z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b42x,-189,b42z)		
		elseif distXYZ(b42x,b42z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a42x,-189,a42z)
		elseif distXYZ(a43x,a43z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b43x,-189,b43z)		
		elseif distXYZ(b43x,b43z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a43x,-189,a43z)	
		elseif distXYZ(a44x,a44z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b44x,-189,b44z)	
		elseif distXYZ(b44x,b44z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a44x,-189,a44z)		
		elseif distXYZ(a45x,a45z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',b45x,-189,b45z)		
		elseif distXYZ(b45x,b45z,p.x,p.z)<jumpspotrange then
			CastSpellXYZ('W',a45x,-189,a45z)
		end
	end
end

SetTimerCallback("ZedMain")
print("\nVal's Zed v"..version.."\n")