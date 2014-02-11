require 'Utils'
require 'winapi'
require 'SKeys'
require 'runrunrun'
require 'vals_lib'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local Q,W,E,R = 'Q','W','E','R'
local version = '2.5'
local MarkTimer,ls = nil,nil
local timer,dodgetimer = 0,0
local skillshotArray = {}
local xa,xb,ya,yb,cc = 50/1920*GetScreenX(),1870/1920*GetScreenX(),50/1080*GetScreenY(),1030/1080*GetScreenY(),0
local Damage_Multipicator = 100

	LBConf, menu = uiconfig.add_menu('LeBlanc Hotkeys', 250)
	menu.keydown('Qkey', 'Q-Key', Keys.X)
	menu.keydown('Ekey', 'E-Key', Keys.Y)
	menu.keydown('Combo', 'Combo', Keys.Ziel)
	menu.keydown('Harass', 'Harass', Keys.T)
	menu.permashow('Qkey')
	menu.permashow('Ekey')
	menu.permashow('Combo')
	menu.permashow('Harass')
	
	LBSettings, menu = uiconfig.add_menu('LeBlanc Settings', 250)
	menu.checkbutton('AWB', 'Auto-W-Back', false)
	menu.checkbutton('KSNotes', 'KSNotes', true)
	menu.checkbutton('ReturnPad', 'Draw ReturnPad', true)
	menu.checkbutton('MouseMove', 'MouseMove', true)
	menu.checkbutton('jumphelper', 'JumpHelper', false)
	menu.checkbutton('DrawCircles', 'DrawCircles', true)
	
	DodgeConfig, menu = uiconfig.add_menu('DodgeSkillshot Config', 250)
	menu.checkbutton('DrawSkillShots', 'Draw Skillshots', true)
	menu.checkbutton('DodgeSkillShots', 'Dodge Skillshots', true)
	menu.checkbutton('DodgeSkillShotsAOE', 'Dodge Skillshots for AOE', true)
	menu.slider('BlockSettings', 'Block user input', 1, 2, 1, {'FixBlock','NoBlock'})
	menu.slider('BlockSettingsAOE', 'Block user input for AOE', 1, 2, 2, {'FixBlock','NoBlock'})
	menu.slider('BlockTime', 'Block imput time', 0, 1000, 750)
	menu.permashow('DrawSkillShots')
	menu.permashow('DodgeSkillShots')

function Main()
	if IsLolActive() then
		SetVariables()
		Skillshots()
		GetSpells()
		GetMark()
		Distance()
		Jump()
		QspellOnce()
		EspellOnce()
		ComboAlwaysOn()
		if LBConf.Combo then Combo() end
		if LBConf.Harass and myHero.mana>=(Qm+Wm) then Harass() end
		if LBSettings.KSNotes then KSNotifications() end
		if LBSettings.ReturnPad then ReturnPad() end
		
	end
end

function QSpell()
	if LBConf.Qkey == true then
		if Q1RDY==1 then
			if MarkedEnemy~=nil then
				SpellTarget(Q,Q1RDY,myHero,MarkedEnemy,700)
			elseif target~=nil then
				SpellTarget(Q,Q1RDY,myHero,target,700)
			end
		elseif Q2RDY==1 then
			if MarkedEnemy~=nil then
				SpellTarget(R,Q2RDY,myHero,MarkedEnemy,700)
			elseif target~=nil then
				SpellTarget(R,Q2RDY,myHero,target,700)
			end
		end
	end
	if LBConf.Qkey == false then
		return true
	end
end

function QspellOnce()
	run_many_reset(1, QSpell)
end
	
function ESpell()
	if LBConf.Ekey == true then
		if E1RDY==1 then
			if targetE~=nil then SpellPred(E,E1RDY,myHero,targetE,800,1.5,15,1,125) end
		elseif E2RDY==1 then
			if targetE~=nil then SpellPred(R,E2RDY,myHero,targetE,800,1.5,15,1,125) end
		end
	end
	if LBConf.Ekey == false then
		return true
	end
end

function EspellOnce()
	run_many_reset(1, ESpell)
end

function Harass()
	if target~=nil and Q1RDY==1 and W1RDY==1 and ls==nil and Ziel==nil then
		QWW = true
		Ziel = target
	end
	if QWW and Ziel~=nil then
		if ls==nil then SpellTarget(Q,Q1RDY,myHero,Ziel,700) end
		if 	ls=='Q1' then SpellXYZ(W,W1RDY,myHero,Ziel,800,Ziel.x,Ziel.z) end
		if 	ls=='W1' then SpellXYZ(W,W2RDY,myHero,myHero,1,myHero.x,myHero.z) end
		if 	ls=='W2' then
			ls = nil
			Ziel = nil
			QWW = false
		end
	end
	if LBSettings.MouseMove and dodgetimer==0 then MoveMouse() end
end

function SetVariables()
	target = GetWeakEnemy('MAGIC',700)
	targetE = GetWeakEnemy('MAGIC',800)
	target2 = GetWeakEnemy('MAGIC',1200)
	
	Qm = (myHero.SpellLevelQ*10)+40
	Wm = (myHero.SpellLevelW*10)+70
	Em = 80
	
	if Ziel==nil or (Ziel~=nil and (Ziel.dead==1 or Ziel.invulnerable==1)) or myHero.dead==1 or (timer~=0 and GetTickCount()-timer>500) then
		QRWE,QRE,QRW,QR,QWE,QE,QW,WQRE,WQR,WQE,_E,_Q,QWW = false,false,false,false,false,false,false,false,false,false,false,false,false
		ls,Ziel = nil,nil
		timer = 0
	end

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
	
	send.tick()
	cc=cc+1
	if cc==30 then LoadTable() end
	for i=1, #skillshotArray, 1 do
		if os.clock() > (skillshotArray[i].lastshot + skillshotArray[i].time) then
			skillshotArray[i].shot = 0
		end
	end
	if GetTickCount()-dodgetimer>DodgeConfig.BlockTime then dodgetimer = 0 end
end

function Wspell()
	if Ziel~=nil and W2RDY==0 then
		if GetD(Ziel)<800 then
			EPos = Vector(Ziel.x, Ziel.y, Ziel.z)
			HPos = Vector(myHero.x, myHero.y, myHero.z)
			WPos = EPos+(EPos-HPos)*(-150/GetD(EPos, HPos))
			SpellXYZ(W,W1RDY,myHero,Ziel,800,WPos.x,WPos.z)
		else
			SpellXYZ(W,W1RDY,myHero,Ziel,800,Ziel.x,Ziel.z)
		end
	end
	if W1RDY==1 then
		return true
	end
end

function WLspell()
	if Ziel~=nil and W2RDY==0 then SpellXYZ(W,W1RDY,myHero,Ziel,1300,Ziel.x,Ziel.z) end
	if W1RDY==1 then
		return true
	end
end

function OnProcessSpell(unit, spell)
	if unit ~= nil and spell ~= nil and unit.charName == myHero.charName then
		if QRWE or QRW or QRE or QR or QWE or QE or QW or _E or _Q or WQRE or WQE or WQR or QWW then
			if spell.name == 'LeblancChaosOrb' then
				ls = 'Q1' 
				timer = GetTickCount()
			end
			if spell.name == 'LeblancChaosOrbM' then 
				ls = 'Q2'
				timer = GetTickCount()
			end
			if spell.name == 'LeblancSlide' then
				ls = 'W1'
				timer = GetTickCount()
			end
			if spell.name == 'LeblancSoulShackle' then
				ls = 'E1'
				timer = GetTickCount()
			end
			if spell.name == 'ItemBlackfireTorch' then
				ls = 'item'
				timer = GetTickCount()
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

function GetSpells()
	if myHero.SpellNameQ == 'LeblancChaosOrb' and myHero.SpellLevelQ >= 1 and myHero.SpellTimeQ >= 1 and myHero.mana >= 40+(myHero.SpellLevelQ*10) then Q1RDY = 1
	else Q1RDY = 0 end
	if myHero.SpellNameR == 'LeblancChaosOrbM' and myHero.SpellLevelR >= 1 and myHero.SpellTimeR >= 1 then Q2RDY = 1
	else Q2RDY = 0 end
	if myHero.SpellNameW == 'LeblancSlide' and myHero.SpellLevelW >= 1 and myHero.SpellTimeW >= 1 and myHero.mana >= 70+(myHero.SpellLevelW*10) then W1RDY = 1
	else W1RDY = 0 end
	if myHero.SpellNameW == 'leblancslidereturn' and myHero.SpellLevelW >= 1 and myHero.SpellTimeW >= 1 then W2RDY = 1
	else W2RDY = 0 end
	if myHero.SpellNameE == 'LeblancSoulShackle' and myHero.SpellLevelE >= 1 and myHero.SpellTimeE >= 1 and myHero.mana >= 80 then E1RDY = 1
	else E1RDY = 0 end
	if myHero.SpellNameR == 'LeblancSoulShackleM' and myHero.SpellLevelR >= 1 and myHero.SpellTimeR >= 1 then E2RDY = 1
	else E2RDY = 0 end
	if myHero.SpellLevelR >= 1 and myHero.SpellTimeR >= 1 then RRDY = 1
	else RRDY = 0 end
end

function OnDraw()
	if myHero.dead == 0 and LBSettings.DrawCircles then
		if Q1RDY==1 then CustomCircle(700,1,2,myHero) end
		if Q1RDY==1 and W1RDY==1 then CustomCircle(1200,1,5,myHero) end
		if target2~=nil and target==nil and Ziel==nil and GetD(target2)<1200 then CustomCircle(100,4,5,target2)
		elseif target~=nil and GetD(target)<700 then CustomCircle(100,4,2,target) end
		if Ziel~=nil then CustomCircle(75,30,2,Ziel) end	
		if	   Q1RDY==1 and W1RDY==1 and E1RDY==1 and RRDY==1 and myHero.mana>=(Qm+Wm+Em) 	and ls==nil then DrawTextObject('BURST',myHero,Color.Yellow)
		elseif Q1RDY==1 and W1RDY==1 and E1RDY==0 and RRDY==1 and myHero.mana>=(Qm+Wm) 		and ls==nil then DrawTextObject('QRW',myHero,Color.Yellow)
		elseif Q1RDY==1 and W1RDY==0 and E1RDY==1 and RRDY==1 and myHero.mana>=(Qm+Em) 		and ls==nil then DrawTextObject('QRE',myHero,Color.Yellow)
		elseif Q1RDY==1 and W1RDY==0 and E1RDY==0 and RRDY==1 							and ls==nil then DrawTextObject('QR',myHero,Color.Yellow)
		elseif Q1RDY==1 and W1RDY==1 and E1RDY==1 and RRDY==0 and myHero.mana>=(Qm+Wm+Em) 	and ls==nil then DrawTextObject('QWE',myHero,Color.Yellow)
		elseif Q1RDY==1 and W1RDY==0 and E1RDY==1 and RRDY==0 and myHero.mana>=(Qm+Em)		and ls==nil then DrawTextObject('QE',myHero,Color.Yellow)
		elseif Q1RDY==1 and W1RDY==1 and E1RDY==0 and RRDY==0 and myHero.mana>=(Qm+Wm)		and ls==nil then DrawTextObject('QW',myHero,Color.Yellow)
		elseif Q1RDY==0 and W1RDY==0 and E1RDY==1 and RRDY==0 							and ls==nil then DrawTextObject('E',myHero,Color.Yellow)
		elseif Q1RDY==1 and W1RDY==0 and E1RDY==0 and RRDY==0 							and ls==nil then DrawTextObject('Q',myHero,Color.Yellow)
		end
	end
end

function KSNotifications()	
	for i = 1, objManager:GetMaxHeroes() do
		local e = objManager:GetHero(i)
		if (e~=nil and e.team~=myHero.team and e.visible==1 and e.invulnerable==0 and e.dead==0) and Ziel==nil then	
		
			EPos = Vector(e.x,0,e.z)
			HPos = Vector(myHero.x,0,myHero.z)
			WPos = HPos+(HPos-EPos)*(-600/GetD(HPos,EPos))
			EPos = HPos+(HPos-EPos)*(-800/GetD(HPos,EPos))
			
			if IsWall(WPos.x,0,WPos.z)==1 then Wall = 1
			else Wall = 0 end
			if CreepBlock(e.x,0,e.z,EPos.x,0,EPos.z)==1 then Block = 1
			else Block = 0 end
			
			local effhealth = e.health*(1+(((e.magicArmor*myHero.magicPenPercent)-myHero.magicPen)/100))
			local xQ = (((30+(25*myHero.SpellLevelQ))+(.4*myHero.ap)))
			local xQ2 = xQ*2
			local xW = (((45+(40*myHero.SpellLevelW))+(.6*myHero.ap)))
			local xE = ((((15+(25*myHero.SpellLevelE))+(.5*myHero.ap))*2))
			local xR = (((100*myHero.SpellLevelR)+(.65*myHero.ap)))
			local xR2 = xR*2
			local xBFT = ((e.maxHealth*.2)*BFT)
			local xDFG = ((e.maxHealth*.15)*DFG)
		
--[[WQE]]	if effhealth<xQ2+xE and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 and GetD(e)>700 then
				if Block==1 or Wall == 1 then 
					DrawTextObject('WQE (Long) KILL',e,Color.Red)
				else 
					DrawTextObject('WQE (Long) KILL',e,Color.Yellow) 
				end
--[[WQR]]	elseif effhealth<xQ2+xR2 and Q1RDY==1 and W1RDY==1 and W2RDY==0 and RRDY==1 and GetD(e)>700 then
				if Wall == 1 then 
					DrawTextObject('WQR (Long) KILL',e,Color.Red)
				else 
					DrawTextObject('WQR (Long) KILL',e,Color.Yellow) 
				end
--[[WQRE]]	elseif effhealth<xQ2+xR2+xE and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 and RRDY==1 and GetD(e)>700 then
				if Block==1 or Wall == 1 then 
					DrawTextObject('WQRE (Long) KILL',e,Color.Red)
				else 
					DrawTextObject('WQRE (Long) KILL',e,Color.Yellow)
				end
--[[IWQR]]	elseif effhealth<((xQ2+xR)*1.2*(BFT+DFG))+xBFT+xDFG and Q1RDY==1 and W1RDY==1 and W2RDY==0 and RRDY==1 and GetD(e)>700 then
				if 
					Wall == 1 then DrawTextObject('IWQR (Long) KILL',e,Color.Red)
				else 
					DrawTextObject('IWQR (Long) KILL',e,Color.Yellow) 
				end
--[[IWQRE]]	elseif effhealth<((xQ2+xR2+xE)*1.2*(BFT+DFG))+xBFT+xDFG and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 and RRDY==1 and GetD(e)>700 then
				if Block==1 or Wall == 1 then 
					DrawTextObject('IWQRE (Long) KILL',e,Color.Red)
				else 
					DrawTextObject('IWQRE (Long) KILL',e,Color.Yellow) 
				end			
--[[Q]]		elseif effhealth<xQ and Q1RDY==1 then 
					DrawTextObject('Q KILL',e,Color.Yellow)
--[[E]]		elseif effhealth<xE and E1RDY==1 then 
				if Block==1 then 
					DrawTextObject('E KILL',e,Color.Red)
				else 
					DrawTextObject('E KILL',e,Color.Yellow) 
				end
--[[QW]]	elseif myHero.mana>=(Qm+Wm) and effhealth<xQ2+xW and Q1RDY==1 and W1RDY==1 and W2RDY==0 then
				if Wall == 1 then 
					DrawTextObject('QW KILL',e,Color.Red)
				else 
					DrawTextObject('QW KILL',e,Color.Yellow) 
				end
--[[QE]]	elseif myHero.mana>=(Qm+Em) and effhealth<xQ2+xE and Q1RDY==1 and E1RDY==1 then 
				if Block==1 then 
					DrawTextObject('QE KILL',e,Color.Red)
				else 
					DrawTextObject('QE KILL',e,Color.Yellow) 
				end
--[[QWE]]	elseif myHero.mana>=(Qm+Wm+Em) and effhealth<xQ2+xW+xE and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 then
				if Block==1 or Wall == 1 then 
					DrawTextObject('QWE KILL',e,Color.Red)
				else 
					DrawTextObject('QWE KILL',e,Color.Yellow) 
				end
--[[QR]]	elseif effhealth<xQ2+xR and Q1RDY==1 and RRDY==1 then 
					DrawTextObject('QR KILL',e,Color.Yellow)
--[[QRE]]	elseif myHero.mana>=(Qm+Em) and effhealth<xQ2+xR2+xE and Q1RDY==1 and E1RDY==1 and RRDY==1 then
				if Block==1 then 
					DrawTextObject('QRE KILL',e,Color.Red)
				else 
					DrawTextObject('QRE KILL',e,Color.Yellow) end
--[[QRW]]	elseif myHero.mana>=(Qm+Wm) and effhealth<xQ2+xR2+xW and Q1RDY==1 and W1RDY==1 and W2RDY==0 and RRDY==1 then
				if Wall == 1 then 
					DrawTextObject('QRW KILL',e,Color.Red)
				else 
					DrawTextObject('QRW KILL',e,Color.Yellow) 
				end
--[[QRWE]]	elseif myHero.mana>=(Qm+Wm+Em) and effhealth<xQ2+xR2+xW+xE and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 and RRDY==1 then
				if Block==1 or Wall == 1 then 
					DrawTextObject('QRWE KILL',e,Color.Red)
				else 
					DrawTextObject('QRWE KILL',e,Color.Yellow) 
				end
--[[IQR]]	elseif effhealth<((xQ2+xR)*1.2*(BFT+DFG))+xBFT+xDFG and Q1RDY==1 and RRDY==1 then
					DrawTextObject('IQR KILL',e,Color.Yellow) 
--[[IQRE]]	elseif myHero.mana>=(Qm+Em) and effhealth<((xQ2+xR2+xE)*1.2*(BFT+DFG))+xBFT+xDFG and Q1RDY==1 and E1RDY==1 and RRDY==1 then			
				if Block==1 then 
					DrawTextObject('IQRE KILL',e,Color.Red)
				else 
					DrawTextObject('IQRE KILL',e,Color.Yellow) 
				end
--[[IQRW]]	elseif myHero.mana>=(Qm+Wm) and effhealth<((xQ2+xR2+xW)*1.2*(BFT+DFG))+xBFT+xDFG and Q1RDY==1 and W1RDY==1 and W2RDY==0 and RRDY==1 then
				if Wall == 1 then 
					DrawTextObject('IQRW KILL',e,Color.Red)
				else 
					DrawTextObject('IQRW KILL',e,Color.Yellow) 
				end
--[[IQRWE]]	elseif myHero.mana>=(Qm+Wm+Em) and effhealth<((xQ2+xR2+xW+xE)*1.2*(BFT+DFG))+xBFT+xDFG and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 and RRDY==1 then
				if Block==1 or Wall == 1 then 
					DrawTextObject('IQRWE KILL',e,Color.Red)
				else 
					DrawTextObject('IQRWE KILL',e,Color.Yellow) 
				end
			end
		end
	end
end

function Distance()
	if target2~=nil and runningAway(target2) then distance = 1300-(384+((target2.movespeed/1000)*(384)))
	else distance = 1150 end
	return distance
end

function runningAway(slowtarget)
   local d1 = GetD(slowtarget)
   local x, y, z = GetFireahead(slowtarget,2,0)
   local d2 = GetD({x=x, y=y, z=z})
   local d3 = GetD({x=x, y=y, z=z},slowtarget)
   local angle = math.acos((d2*d2-d3*d3-d1*d1)/(-2*d3*d1))
   return angle%(2*math.pi)>math.pi/2 and angle%(2*math.pi)<math.pi*3/2
end

function Combo()
	for i = 1, objManager:GetMaxHeroes() do
		local e = objManager:GetHero(i)
		if (e~=nil and e.team~=myHero.team and e.visible==1 and e.invulnerable==0 and e.dead==0) then	

			EPos = Vector(e.x,0,e.z)
			HPos = Vector(myHero.x,0,myHero.z)
			WPos = HPos+(HPos-EPos)*(-600/GetD(HPos,EPos))
			EPos = HPos+(HPos-EPos)*(-800/GetD(HPos,EPos))
			if IsWall(WPos.x,0,WPos.z)==1 then Wall = 1
			else Wall = 0 end
			if CreepBlock(e.x,0,e.z,EPos.x,0,EPos.z)==1 then Block = 1
			else Block = 0 end
			
			local effhealth = e.health*(1+(((e.magicArmor*myHero.magicPenPercent)-myHero.magicPen)/100))
			local xQ = (((30+(25*myHero.SpellLevelQ))+(.4*myHero.ap)))
			local xQ2 = xQ*2
			local xW = (((45+(40*myHero.SpellLevelW))+(.6*myHero.ap)))
			local xE = ((((15+(25*myHero.SpellLevelE))+(.5*myHero.ap))*2))
			local xR = (((100*myHero.SpellLevelR)+(.65*myHero.ap)))
			local xR2 = xR*2
			local xBFT = ((e.maxHealth*.2)*BFT)
			local xDFG = ((e.maxHealth*.15)*DFG)
			
			EPos = Vector(e.x,0,e.z)
			HPos = Vector(myHero.x,0,myHero.z)
			WPos = EPos+(EPos-HPos)*(-600/GetD(EPos,HPos))
			EPos = EPos+(EPos-HPos)*(-900/GetD(EPos,HPos))
			
			if target2~=nil then
				EPos = Vector(target2.x, target2.y, target2.z)
				HPos = Vector(myHero.x, myHero.y, myHero.z)
				WPos = HPos+(HPos-EPos)*(-600/GetD(HPos, EPos))
				if IsWall(WPos.x,WPos.y,WPos.z)==1 then WallT = 1
				else WallT = 0 end
			elseif target~=nil then
				EPos = Vector(target.x, target.y, target.z)
				HPos = Vector(myHero.x, myHero.y, myHero.z)
				WPos = HPos+(HPos-EPos)*(-600/GetD(HPos, EPos))
				if IsWall(WPos.x,WPos.y,WPos.z)==1 then WallT = 1
				else WallT = 0 end
			end
			if target2~=nil then
				EPos = Vector(target2.x, target2.y, target2.z)
				HPos = Vector(myHero.x, myHero.y, myHero.z)
				EPos = HPos+(HPos-EPos)*(-800/GetD(HPos, EPos))
				if CreepBlock(target2.x, target2.y, target2.z,EPos.x,EPos.y,EPos.z)==1 then BlockT = 1
				else BlockT = 0 end
			elseif target~=nil then
				if CreepBlock(target.x, target.y, target.z)==1 then BlockT = 1
				else BlockT = 0 end
			end

			if ls==nil and Ziel==nil then
				if GetD(e)<675 and effhealth<xQ and Q1RDY==1 then 
					_Q = true
					Ziel = e
				elseif GetD(e)<675 and effhealth<xW and W1RDY==1 then 
					CastSpellXYZ('W',e.x,0,e.z)
				elseif GetD(e)<675 and effhealth<xE and E1RDY==1 and Block==0 then 
					_E = true
					Ziel = e
				elseif GetD(e)<675 and myHero.mana>=(Qm+Wm) and effhealth<xQ2+xW and Q1RDY==1 and W1RDY==1 and W2RDY==0 and Wall==0 then 
					QW = true
					Ziel = e
				elseif GetD(e)<675 and myHero.mana>=(Qm+Em) and effhealth<xQ2+xE and Q1RDY==1 and E1RDY==1 and Block==0 then 
					QE = true
					Ziel = e
				elseif GetD(e)<675 and (effhealth<xQ2+xR or effhealth<((xQ2+xR)*1.2*(BFT+DFG))+xBFT+xDFG) and Q1RDY==1 and RRDY==1 then 
					QR = true
					Ziel = e
				elseif GetD(e)<675 and myHero.mana>=(Qm+Wm) and (effhealth<xQ2+xR2+xW or effhealth<((xQ2+xR2+xW)*1.2*(BFT+DFG))+xBFT+xDFG) and Q1RDY==1 and W1RDY==1 and W2RDY==0 and RRDY==1 and Wall==0 then 
					QRW = true
					Ziel = e
				elseif GetD(e)<675 and myHero.mana>=(Qm+Wm+Em) and effhealth<xQ2+xW+xE and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 and Block==0 and Wall==0 then 
					QWE = true
					Ziel = e
				elseif GetD(e)<675 and myHero.mana>=(Qm+Em) and (effhealth<xQ2+xR2+xE or effhealth<((xQ2+xR2+xE)*1.2*(BFT+DFG))+xBFT+xDFG) and Q1RDY==1 and E1RDY==1 and RRDY==1 and  Block==0 then 
					QRE = true
					Ziel = e
				elseif GetD(e)<675 and myHero.mana>=(Qm+Wm+Em) and (effhealth<xQ2+xR2+xW+xE or effhealth<((xQ2+xR2+xW+xE)*1.2*(BFT+DFG))+xBFT+xDFG) and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 and RRDY==1 and Block==0 and Wall==0 then 
					QRWE = true
					Ziel = e
				elseif GetD(e)<1200 and myHero.mana>=(Qm+Wm+Em) and effhealth<xQ2+xE and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 and Block==0 and Wall==0 then 
					WQE = true
					Ziel = e
				elseif GetD(e)<1200 and myHero.mana>=(Qm+Wm) and (effhealth<xQ2+xR2 or effhealth<((xQ2+xR)*1.2*(BFT+DFG))+xBFT+xDFG) and Q1RDY==1 and W1RDY==1 and W2RDY==0 and RRDY==1 and  Wall==0 then 
					WQR = true
					Ziel = e
				elseif GetD(e)<1200 and myHero.mana>=(Qm+Wm+Em) and (effhealth<xQ2+xR2+xE or effhealth<((xQ2+xR2+xE)*1.2*(BFT+DFG))+xBFT+xDFG) and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 and RRDY==1 and Block==0 and Wall==0 then 
					WQRE = true
					Ziel = e
				elseif target~=nil and myHero.mana>=(Qm+Wm+Em) and Q1RDY==1 and W1RDY==1 and E1RDY==1 and RRDY==1 and WallT==0 and BlockT==0 then 
					QRWE = true
					Ziel = target
				elseif target~=nil and myHero.mana>=(Qm+Em) and Q1RDY==1 and W1RDY==0 and E1RDY==1 and RRDY==1 and BlockT==0 then 
					QRE = true
					Ziel = target
				elseif target~=nil and myHero.mana>=(Qm+Wm) and Q1RDY==1 and W1RDY==1 and E1RDY==0 and RRDY==1 and WallT==0 then 
					QRW = true
					Ziel = target
				elseif target~=nil and Q1RDY==1 and W1RDY==0 and E1RDY==0 and RRDY==1 then QR = true
					Ziel = target
				elseif target~=nil and myHero.mana>=(Qm+Wm+Em) and Q1RDY==1 and W1RDY==1 and E1RDY==1 and RRDY==0 and WallT==0 then 
					QWE = true
					Ziel = target
				elseif target~=nil and myHero.mana>=(Qm+Em) and Q1RDY==1 and W1RDY==0 and E1RDY==1 and RRDY==0 and BlockT==0 then 
					QE = true
					Ziel = target
				elseif target~=nil and myHero.mana>=(Qm+Wm) and Q1RDY==1 and W1RDY==1 and E1RDY==0 and RRDY==0 and WallT==0 then 
					QW = true
					Ziel = target
				elseif target2~=nil and myHero.mana>=(Qm+Wm+Em) and GetD(target2)<distance and Q1RDY==1 and W1RDY==1 and E1RDY==1 and RRDY==1 and WallT==0 and BlockT==0 then 
					WQRE = true
					Ziel = target2
				elseif target2~=nil and myHero.mana>=(Qm+Wm) and GetD(target2)<distance and Q1RDY==1 and W1RDY==1 and E1RDY==0 and RRDY==1 and WallT==0 then 
					WQR = true
					Ziel = target2
				elseif target2~=nil and myHero.mana>=(Qm+Wm+Em) and GetD(target2)<distance and Q1RDY==1 and W1RDY==1 and E1RDY==1 and RRDY==0 and WallT==0 and BlockT==0 then 
					WQE = true
					Ziel = target2
				elseif targetE~=nil and Q1RDY==0 and Q2RDY==0 and W1RDY==0 and E1RDY==1 and BlockT==0 then 	
					_E = true
					Ziel = targetE
				elseif target~=nil and Q1RDY==1 and W1RDY==0 and E1RDY==0 and RRDY==0 then _Q = true
					Ziel = target
				end
			end
			if LBSettings.MouseMove and dodgetimer == 0 then
				if Ziel==nil then MoveMouse() end
			end
		end
	end
end

function ComboAlwaysOn()	
	if QRWE and Ziel~=nil then
		if 	ls==nil  then UseDFGBFT() end
		if	((BFT==0 and ls==nil) or ls=='item') then SpellTarget(Q,Q1RDY,myHero,Ziel,700) end
		if 	ls=='Q1' then SpellTarget(R,Q2RDY,myHero,Ziel,700) end
		if 	ls=='Q2' then run_many_reset(1, Wspell) end
		if 	ls=='W1' then Espell() end
		if	ls=='E1' and LBSettings.AWB==false then QRWE = false end
		if	ls=='E1' and LBSettings.AWB==true then SpellXYZ(W,W2RDY,myHero,myHero,1,myHero.x,myHero.z) end
		if	ls=='W2' and LBSettings.AWB==true then QRWE = false end
	elseif QRE and Ziel~=nil then
		if  ls==nil  then UseDFGBFT() end
		if  ((BFT==0 and ls==nil) or ls=='item') then SpellTarget(Q,Q1RDY,myHero,Ziel,700) end
		if 	ls=='Q1' then SpellTarget(R,Q2RDY,myHero,Ziel,700) end
		if 	ls=='Q2' then Espell() end
		if	ls=='E1' then QRE = false end
	elseif QRW and Ziel~=nil then
		if  ls==nil  then UseDFGBFT() end
		if  ((BFT==0 and ls==nil) or ls=='item') then SpellTarget(Q,Q1RDY,myHero,Ziel,700) end
		if 	ls=='Q1' then SpellTarget(R,Q2RDY,myHero,Ziel,700) end
		if 	ls=='Q2' then run_many_reset(1, Wspell) end
		if 	ls=='W1' and LBSettings.AWB==false then QRW = false end
		if 	ls=='W1' and LBSettings.AWB==true then SpellXYZ(W,W2RDY,myHero,myHero,1,myHero.x,myHero.z) end
		if	ls=='W2' and LBSettings.AWB==true then QWE = false end
	elseif QR and Ziel~=nil then
		if 	ls==nil  then UseDFGBFT() end
		if  ((BFT==0 and ls==nil) or ls=='item') then SpellTarget(Q,Q1RDY,myHero,Ziel,700) end
		if 	ls=='Q1' then SpellTarget(R,Q2RDY,myHero,Ziel,700) end
		if 	ls=='Q2' then QR = false end
	elseif QWE and Ziel~=nil then
		if	ls==nil  then SpellTarget(Q,Q1RDY,myHero,Ziel,700) end
		if 	ls=='Q1' then run_many_reset(1, Wspell) end
		if 	ls=='W1' then Espell() end
		if	ls=='E1' and LBSettings.AWB==false then QWE = false end
		if	ls=='E1' and LBSettings.AWB==true then SpellXYZ(W,W2RDY,myHero,myHero,1,myHero.x,myHero.z) end
		if	ls=='W2' and LBSettings.AWB==true then QWE = false end
	elseif QE and Ziel~=nil then
		if	ls==nil  then SpellTarget(Q,Q1RDY,myHero,Ziel,700) end
		if 	ls=='Q1' then Espell() end
		if 	ls=='E1' then QE = false end
	elseif QW and Ziel~=nil then
		if	ls==nil  then SpellTarget(Q,Q1RDY,myHero,Ziel,700) end
		if 	ls=='Q1' then run_many_reset(1, Wspell) end
		if	ls=='W1' and LBSettings.AWB==false then QW = false end
		if	ls=='W1' and LBSettings.AWB==true then SpellXYZ(W,W2RDY,myHero,myHero,1,myHero.x,myHero.z) end
		if	ls=='W2' and LBSettings.AWB==true then QW = false end
	elseif WQRE and Ziel~=nil then
		if	ls==nil  then run_many_reset(1, WLspell) end
		if 	ls=='W1' then UseDFGBFT() end
		if  ((BFT==0 and ls=='W1') or ls=='item') then SpellTarget(Q,Q1RDY,myHero,Ziel,700) end
		if 	ls=='Q1' then SpellTarget(R,Q2RDY,myHero,Ziel,700) end
		if 	ls=='Q2' then Espell() end
		if	ls=='E1' then WQRE = false end
	elseif WQR and Ziel~=nil then
		if	ls==nil  then run_many_reset(1, WLspell) end
		if 	ls=='W1' then UseDFGBFT() end
		if  ((BFT==0 and ls=='W1') or ls=='item') then SpellTarget(Q,Q1RDY,myHero,Ziel,700) end
		if 	ls=='Q1' then SpellTarget(R,Q2RDY,myHero,Ziel,700) end
		if 	ls=='Q2' then WQR = false end
	elseif WQE and Ziel~=nil then
		if	ls==nil  then run_many_reset(1, WLspell) end
		if 	ls=='W1' then UseDFGBFT() end
		if  ((BFT==0 and ls=='W1') or ls=='item') then SpellTarget(Q,Q1RDY,myHero,Ziel,700) end
		if 	ls=='Q1' then Espell() end
		if	ls=='E1' then WQE = false end
	elseif _E and Ziel~=nil then
		if		ls==nil  then Espell() end
		if	ls=='E1' then _E = false end
	elseif _Q and Ziel~=nil then
		if	ls==nil  then SpellTarget(Q,Q1RDY,myHero,Ziel,700) end
		if	ls=='Q1' then _Q = false end
	end
	if (QRWE==false and QRE==false and QRW==false and QR==false and QWE==false and QE==false and QW==false and WQRE==false and WQR==false and WQE==false and _E==false and _Q==false and QWW==false) then
		ls = nil
		Ziel = nil
	end
	if dodgetimer == 0 then
		if Ziel~=nil then MoveToXYZ(Ziel.x,Ziel.y,Ziel.z) end
	end
end

function Espell()
	for i = 1, objManager:GetMaxObjects(), 1 do
		obj = objManager:GetObject(i)
		if Ziel~=nil and obj~=nil and obj.charName == 'leBlanc_slide_impact_self.troy' and GetD(obj) < 100 then SpellPredSimple(E,E1RDY,myHero,Ziel,800,1.5,15,1,125) end
	end
end

function UseDFGBFT()
	if BFT == 1 and Ziel~=nil then UseItemOnTarget(3188, Ziel)
	elseif DFG == 1 and Ziel~=nil then UseItemOnTarget(3128, Ziel)
	end
end

function ReturnPad()
	for i = 1, objManager:GetMaxObjects(), 1 do
        obj = objManager:GetObject(i)
		if obj~=nil and obj.charName == 'Leblanc_displacement_blink_indicator.troy' then DrawSphere(85,30,5,obj.x,obj.y,obj.z) end
		if obj~=nil and obj.charName == 'Leblanc_displacement_blink_indicator_ult.troy' then DrawSphere(85,30,4,obj.x,obj.y,obj.z) end
	end
end

function GetMark()
	for i = 1, objManager:GetMaxNewObjects(), 1 do
		obj = objManager:GetNewObject(i)
		for i = 1, objManager:GetMaxHeroes() do
			local e = objManager:GetHero(i)
			if (e ~= nil and e.team ~= myHero.team and e.visible == 1 and e.invulnerable==0 and e.dead == 0) then
				if obj~=nil and e~=nil then
					if string.find(obj.charName,'leBlanc_chaosOrb_impact_small') and GetD(obj, e) < 50 then
						MarkedEnemy = e
						MarkTimer = GetTickCount()
					end
				end
				if obj~=nil and MarkedEnemy~=nil then
					if 	string.find(obj.charName,'leBlanc_shackle_mis') or 
						string.find(obj.charName,'leBlanc_slide_impact_unit') or 
						string.find(obj.charName,'leBlanc_shackle_target_idle') and 
						GetD(obj, MarkedEnemy) < 50 then
						MarkedEnemy = nil
						MarkTimer = nil
					end
				end
			end
			if MarkTimer~=nil and MarkedEnemy~=nil and GetTickCount()-MarkTimer>3500 then
				MarkedEnemy = nil
				MarkTimer = nil
			end
			if MarkedEnemy~=nil and MarkTimer~=nil and MarkedEnemy.dead == 1 then
				MarkedEnemy = nil
				MarkTimer = nil
			end
		end
	end
end

function GetD(p1, p2)
if p2 == nil then p2 = myHero end
	if (p1.z == nil or p2.z == nil) and p1.x~=nil and p1.y ~=nil and p2.x~=nil and p2.y~=nil then
		px=p1.x-p2.x
		py=p1.y-p2.y
		if px~=nil and py~=nil then
			px2=px*px
			py2=py*py
			if px2~=nil and py2~=nil then
				return math.sqrt(px2+py2)
			else
				return 99999
			end
		else
			return 99999
		end
		elseif p1.x~=nil and p1.z ~=nil and p2.x~=nil and p2.z~=nil then
			px=p1.x-p2.x
			pz=p1.z-p2.z
			if px~=nil and pz~=nil then
				px2=px*px
				pz2=pz*pz
				if px2~=nil and pz2~=nil then
					return math.sqrt(px2+pz2)
				else
					return 99999
				end
			else    
				return 99999
			end
		else
		return 99999
	end
end

local JumpSpots = {
{x = 2856, y = -188, z = 2637},
{x = 2631, y = -188, z = 3125},
{x = 3384, y = -189, z = 2221},
{x = 3831, y = -189, z = 2475},
{x = 4408, y = -189, z = 1402},
{x = 4467, y = -189, z = 1985},
{x = 5911, y = -189, z = 2893},
{x = 5731, y = -189, z = 2375},
{x = 7785, y = -189, z = 2751},
{x = 8009, y = -189, z = 2295},
{x = 8123, y = -189, z = 2917},
{x = 8479, y = -189, z = 2475},
{x = 9525, y = -189, z = 1483},
{x = 9329, y = -189, z = 1925},
{x = 10470, y = -189, z = 2174},
{x = 10195, y = -189, z = 2559},
{x = 11282, y = -189, z = 3094},
{x = 10979, y = -189, z = 2675},
{x = 9777, y = -189, z = 3859},
{x = 9879, y = -189, z = 3325},
{x = 9191, y = -189, z = 3468},
{x = 9677, y = -189, z = 3181},
{x = 12186, y = -189, z = 6703},
{x = 12179, y = -189, z = 6119},
{x = 9579, y = -189, z = 8923},
{x = 9869, y = -189, z = 9405},
{x = 8690, y = -189, z = 10255},
{x = 8613, y = -189, z = 9679},
{x = 7776, y = -189, z = 10075},
{x = 8115, y = -189, z = 9583},
{x = 7127, y = -148, z = 10561},
{x = 7229, y = -189, z = 10073},
{x = 6771, y = -148, z = 10569},
{x = 6635, y = -189, z = 10081},
{x = 6949, y = -189, z = 11887},
{x = 6947, y = -190, z = 11479},
{x = 6191, y = -189, z = 10031},
{x = 5881, y = -189, z = 9523},
{x = 5368, y = -189, z = 9673},
{x = 5094, y = -189, z = 10138},
{x = 3780, y = -189, z = 9213},
{x = 4267, y = -189, z = 8873},
{x = 1645, y = -189, z = 8813},
{x = 1731, y = -189, z = 8273},
{x = 6717, y = -189, z = 3229},
{x = 6781, y = -189, z = 3825},
{x = 7535, y = -189, z = 3771},
{x = 7529, y = -189, z = 3175},
{x = 6481, y = -189, z = 4295},
{x = 6143, y = -189, z = 4667},
{x = 5111, y = -189, z = 5386},
{x = 4605, y = -189, z = 5501},
{x = 6109, y = -189, z = 5565},
{x = 5581, y = -189, z = 5687},
{x = 7753, y = -189, z = 5897},
{x = 8329, y = -189, z = 5725},
{x = 7995, y = -189, z = 6583},
{x = 8429, y = -189, z = 6175},
{x = 9617, y = -190, z = 6104},
{x = 9279, y = -188, z = 6425},
                        }

function Jump()
	local a1x,a1z = 9617,6104
	local b1x,b1z = 9279,6425
	local a2x,a2z = 7995,6583
	local b2x,b2z = 8429,6175
	local a3x,a3z = 7753,5897
	local b3x,b3z = 8329,5725
	local a4x,a4z = 6109,5565
	local b4x,b4z = 5581,5687
	local a10x,a10z = 5111,5386
	local b10x,b10z = 4605,5501
	local a11x,a11z = 6481,4295
	local b11x,b11z = 6143,4667
	local a12x,a12z = 7535,3771
	local b12x,b12z = 7529,3175
	local a13x,a13z = 6717,3229
	local b13x,b13z = 6781,3825
	local a14x,a14z = 1645,8813
	local b14x,b14z = 1731,8273
	local a16x,a16z = 3780,9213
	local b16x,b16z = 4267,8873
	local a17x,a17z = 5368,9673
	local b17x,b17z = 5094,10138
	local a18x,a18z = 6191,10031
	local b18x,b18z = 5881,9523
	local a19x,a19z = 6949,11887
	local b19x,b19z = 6947,11479
	local a20x,a20z = 6771,10569
	local b20x,b20z = 6635,10081
	local a21x,a21z = 7127,10561
	local b21x,b21z = 7229,10073
	local a22x,a22z = 7776,10075
	local b22x,b22z = 8115,9583
	local a23x,a23z = 8690,10255
	local b23x,b23z = 8613,9679
	local a24x,a24z = 9579,8923
	local b24x,b24z = 9869,9405
	local a26x,a26z = 12186,6703
	local b26x,b26z = 12179,6119
	local a27x,a27z = 9191,3468
	local b27x,b27z = 9677,3181
	local a28x,a28z = 9777,3859
	local b28x,b28z = 9879,3325
	local a29x,a29z = 11282,3094
	local b29x,b29z = 10979,2675
	local a30x,a30z = 10470,2174
	local b30x,b30z = 10195,2559
	local a31x,a31z = 9525,1483
	local b31x,b31z = 9329,1925
	local a32x,a32z = 8123,2917
	local b32x,b32z = 8479,2475
	local a33x,a33z = 7785,2751
	local b33x,b33z = 8009,2295
	local a34x,a34z = 5911,2893
	local b34x,b34z = 5731,2375
	local a36x,a36z = 4408,1402
	local b36x,b36z = 4467,1985
	local a37x,a37z = 3384,2221
	local b37x,b37z = 3831,2475
	local a38x,a38z = 2856,2637
	local b38x,b38z = 2631,3125
		
	for _, JumpSpot in pairs(JumpSpots) do
		if LBSettings.jumphelper and GetMap() == 2 then
			if GetD(JumpSpot,myHero) <= 2500 then
				if GetD(JumpSpot,mousePos) <= 75 then
					DrawCircle(JumpSpot.x, JumpSpot.y, JumpSpot.z, 75, 0xFFFF0000)
				else DrawCircle(JumpSpot.x, JumpSpot.y, JumpSpot.z, 75, 0xFFFF8000)
				end
			end
		end
	end
       
	for _, JumpSpot in pairs(JumpSpots) do
		if GetD(JumpSpot,mousePos) <= 75 and KeyDown(1) and LBSettings.jumphelper and GetMap() == 2 then
			MoveToXYZ(JumpSpot.x,JumpSpot.y,JumpSpot.z)
			jump2 = true
		end
	end
       
	if (KeyDown(2) or LBConf.Combo) and LBSettings.jumphelper then
		jump2 = false
	end
       
	if jump2 == true and LBSettings.jumphelper and W1RDY == 1 and GetMap() == 2 then
		if distXYZ(a1x,a1z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b1x,-189,b1z)
		elseif distXYZ(b1x,b1z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a1x,-189,a1z)
		elseif distXYZ(a2x,a2z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b2x,-189,b2z)
		elseif distXYZ(b2x,b2z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a2x,-189,a2z)
		elseif distXYZ(a3x,a3z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b3x,-189,b3z)
		elseif distXYZ(b3x,b3z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a3x,-189,a3z)
		elseif distXYZ(a4x,a4z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b4x,-189,b4z)
		elseif distXYZ(b4x,b4z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a4x,-189,a4z)
		elseif distXYZ(a10x,a10z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b10x,-189,b10z)
		elseif distXYZ(b10x,b10z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a10x,-189,a10z)
		elseif distXYZ(a11x,a11z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b11x,-189,b11z)
		elseif distXYZ(b11x,b11z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a11x,-189,a11z)
		elseif distXYZ(a12x,a12z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b12x,-189,b12z)
		elseif distXYZ(b12x,b12z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a12x,-189,a12z)
		elseif distXYZ(a13x,a13z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b13x,-189,b13z)
		elseif distXYZ(b13x,b13z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a13x,-189,a13z)
		elseif distXYZ(a14x,a14z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b14x,-189,b14z)
		elseif distXYZ(b14x,b14z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a14x,-189,a14z)
		elseif distXYZ(a16x,a16z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b16x,-189,b16z)
		elseif distXYZ(b16x,b16z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a16x,-189,a16z)
		elseif distXYZ(a17x,a17z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b17x,-189,b17z)
		elseif distXYZ(b17x,b17z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a17x,-189,a17z)
		elseif distXYZ(a18x,a18z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b18x,-189,b18z)
		elseif distXYZ(b18x,b18z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a18x,-189,a18z)
		elseif distXYZ(a19x,a19z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b19x,-189,b19z)
		elseif distXYZ(b19x,b19z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a19x,-189,a19z)
		elseif distXYZ(a20x,a20z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b20x,-189,b20z)
		elseif distXYZ(b20x,b20z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a20x,-189,a20z)
		elseif distXYZ(a21x,a21z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b21x,-189,b21z)
		elseif distXYZ(b21x,b21z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a21x,-189,a21z)
		elseif distXYZ(a22x,a22z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b22x,-189,b22z)
		elseif distXYZ(b22x,b22z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a22x,-189,a22z)
		elseif distXYZ(a23x,a23z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b23x,-189,b23z)
		elseif distXYZ(b23x,b23z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a23x,-189,a23z)
		elseif distXYZ(a24x,a24z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b24x,-189,b24z)
		elseif distXYZ(b24x,b24z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a24x,-189,a24z)
		elseif distXYZ(a26x,a26z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b26x,-189,b26z)
		elseif distXYZ(b26x,b26z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a26x,-189,a26z)
		elseif distXYZ(a27x,a27z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b27x,-189,b27z)
		elseif distXYZ(b27x,b27z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a27x,-189,a27z)
		elseif distXYZ(a28x,a28z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b28x,-189,b28z)
		elseif distXYZ(b28x,b28z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a28x,-189,a28z)
		elseif distXYZ(a29x,a29z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b29x,-189,b29z)
		elseif distXYZ(b29x,b29z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a29x,-189,a29z)
		elseif distXYZ(a30x,a30z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b30x,-189,b30z)
		elseif distXYZ(b30x,b30z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a30x,-189,a30z)
		elseif distXYZ(a31x,a31z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b31x,-189,b31z)
		elseif distXYZ(b31x,b31z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a31x,-189,a31z)
		elseif distXYZ(a32x,a32z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b32x,-189,b32z)
		elseif distXYZ(b32x,b32z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a32x,-189,a32z)
		elseif distXYZ(a33x,a33z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b33x,-189,b33z)
		elseif distXYZ(b33x,b33z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a33x,-189,a33z)
		elseif distXYZ(a34x,a34z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b34x,-189,b34z)
		elseif distXYZ(b34x,b34z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a34x,-189,a34z)
		elseif distXYZ(a36x,a36z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b36x,-189,b36z)
		elseif distXYZ(b36x,b36z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a36x,-189,a36z)
		elseif distXYZ(a37x,a37z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b37x,-189,b37z)
		elseif distXYZ(b37x,b37z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a37x,-189,a37z)
		elseif distXYZ(a38x,a38z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',b38x,-189,b38z)
		elseif distXYZ(b38x,b38z,myHero.x,myHero.z)<50 then CastSpellXYZ('W',a38x,-189,a38z)
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

function dodgeaoe(pos1, pos2, radius)
	local calc = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
	local dodgex
	local dodgez
	dodgex = pos2.x + ((radius+50)/calc)*(myHero.x-pos2.x)
	dodgez = pos2.z + ((radius+50)/calc)*(myHero.z-pos2.z)
	if calc < radius and DodgeConfig.DodgeSkillShotsAOE == true and GetCursorX() > xa and GetCursorX() < xb and GetCursorY() > ya and GetCursorY() < yb then
		if DodgeConfig.BlockSettingsAOE == 1 and LBConf.Combo == false and LBConf.Harass == false then
			dodgetimer = GetTickCount()
			send.block_input(true,DodgeConfig.BlockTime)
			MoveToXYZ(dodgex,0,dodgez)
		elseif DodgeConfig.BlockSettingsAOE == 2 or LBConf.Combo or LBConf.Harass then
			dodgetimer = GetTickCount()
			MoveToXYZ(dodgex,0,dodgez)
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
	dodgex = x4 + ((radius+100)/calc3)*(myHero.x-x4)
	dodgez = z4 + ((radius+100)/calc3)*(myHero.z-z4)
	if perpendicular < radius and calc1 < calc4 and calc2 < calc4 and DodgeConfig.DodgeSkillShots == true and GetCursorX() > xa and GetCursorX() < xb and GetCursorY() > ya and GetCursorY() < yb then
		if DodgeConfig.BlockSettings == 1  and LBConf.Combo == false and LBConf.Harass == false then
			dodgetimer = GetTickCount()
			send.block_input(true,DodgeConfig.BlockTime)
			MoveToXYZ(dodgex,0,dodgez)
		elseif DodgeConfig.BlockSettings == 2 or LBConf.Combo or LBConf.Harass then
			dodgetimer = GetTickCount()
			MoveToXYZ(dodgex,0,dodgez)
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
	dodgex = x4 + ((radius+100)/calc3)*(myHero.x-x4)
	dodgez = z4 + ((radius+100)/calc3)*(myHero.z-z4)
	if perpendicular < radius and calc1 < calc4 and calc2 < calc4 and DodgeConfig.DodgeSkillShots == true and GetCursorX() > xa and GetCursorX() < xb and GetCursorY() > ya and GetCursorY() < yb then
		if DodgeConfig.BlockSettings == 1  and LBConf.Combo == false and LBConf.Harass == false then
			dodgetimer = GetTickCount()
			send.block_input(true,DodgeConfig.BlockTime)
			MoveToXYZ(dodgex,0,dodgez)
		elseif DodgeConfig.BlockSettings == 2 then
			dodgetimer = GetTickCount()
			MoveToXYZ(dodgex,0,dodgez)
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

function Skillshots()
	if DodgeConfig.DrawSkillShots == true then
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
					DrawLine(startVector.x, startVector.y, startVector.z, GetD(startVector, endVector)+170, 1,angle,radius)
				end
			end
		end
	end
end

function LoadTable()
	for i = 1, objManager:GetMaxHeroes() do
		local e = objManager:GetHero(i)
		if (e ~= nil and e.team ~= myHero.team) then
			if e.name == 'Ahri' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 880, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
				table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			end
			if e.name == 'Amumu' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			end
			if e.name == 'Anivia' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 90, color= 0x0000FFFF, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			end
			if e.name == 'Ashe' then
				table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 50000, type = 4, radius = 120, color= 0x0000FFFF, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			end
			if e.name == 'Blitzcrank' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 120, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			end
			if e.name == 'Brand' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 50, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
				table.insert(skillshotArray,{name= e.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Cassiopeia' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 125, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Caitlyn' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 50, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Corki' then
				table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1225, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Chogath' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 275, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Diana' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 205, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Draven' then
				table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 125, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
				table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 1, radius = 100, color= 0x0000FFFF, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'DrMundo' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Elise' and e.range>300 then
				table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Ezreal' then
				if e.ap>e.addDamage then
					table.insert(skillshotArray,{name= e.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
				elseif e.ap<e.addDamage then
					table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
				end
				table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 4, radius = 150, color= 0x0000FFFF, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if e.name == 'Fizz' then
				table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1275, type = 2, radius = 100, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Galio' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 905, type = 3, radius = 200, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 120, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Gragas' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 320, color= 0xFFFFFF00, time = 2.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 3, radius = 400, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Graves' then
				table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 110, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Hecarim' then
				table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 125, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Heimerdinger' then
				table.insert(skillshotArray,{name= e.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 225, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Janna' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1700, type = 1, radius = 100, color= 0x0000FFFF, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Jayce' and e.range>300 then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1500, type = 1, radius = 125, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Jinx' then
				table.insert(skillshotArray,{name= e.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1500, type = 1.5, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 3, radius = 225, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Karma' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Karthus' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 875, type = 3, radius = 75, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Kennen' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 75, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Khazix' then	
				table.insert(skillshotArray,{name= e.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 75, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })	
			end
			if e.name == 'KogMaw' then
				table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1115, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2200, type = 3, radius = 200, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Leblanc' then
				table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'LeeSin' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Leona' then
				table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Lissandra' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 725, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Lucian' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= 0x0000FFFF, time = 0.75, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= e.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Lulu' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 50, color= 0x0000FFFF, time = 1, isline = true, px =0, py =0 , pz =0, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Lux' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1175, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 300, color= 0xFFFFFF00, time = 2.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 3000, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Malzahar' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 100 , color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= e.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 250 , color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Maokai' then
				table.insert(skillshotArray,{name= 'MaokaiTrunkLineMissile', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 350 , color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Morgana' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 100, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Nami' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 875, type = 3, radius = 210, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2750, type = 1, radius = 335, color= 0xFFFFFF00, time = 3, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Nautilus' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Nidalee' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1500, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if e.name == 'Olaf' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 2, radius = 100, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Orianna' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 825, type = 3, radius = 150, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if e.name == 'Rumble' then
				table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 100, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
				table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1700, type = 1, radius = 100, color= 0xFFFFFF00, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if e.name == 'Sejuani' then
				table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1150, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = f, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Shen' then
				table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 2, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if e.name == 'Shyvana' then
				table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Sivir' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Skarner' then
				table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Sona' then
				table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Swain' then
				table.insert(skillshotArray,{name= e.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 265 , color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Syndra' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 250, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 1, radius = 100, color= 0xFFFFFF00, time = 0.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= e.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 210, color= 0x0000FFFF, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Thresh' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 160, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'TwistedFate' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1450, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Urgot' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= 0x0000FFFF, time = 0.8, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 300, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if e.name == 'Varus' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1475, type = 1, radius = 50, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Veigar' then
				table.insert(skillshotArray,{name= e.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 225, color= 0xFFFFFF00, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if e.name == 'Vi' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 725, type = 1, radius = 75, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Viktor' then
				table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 80, color= 0xFFFFFF00, time = 2})
			end
			if e.name == 'Xerath' then
				table.insert(skillshotArray,{name= 'xeratharcanopulsedamage', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= 'xeratharcanopulsedamageextended', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
				table.insert(skillshotArray,{name= 'xeratharcanebarragewrapper', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= 'xeratharcanebarragewrapperext', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 3, radius = 250, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if e.name == 'Yasuo' then
				table.insert(skillshotArray,{name= 'yasuoq3w', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 125, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Zac' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 550, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1550, type = 5, radius = 200, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Zed' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 55, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Ziggs' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 160, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
				table.insert(skillshotArray,{name= e.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 225 , color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
				table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= e.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5300, type = 3, radius = 550, color= 0xFFFFFF00, time = 3, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if e.name == 'Zyra' then
				table.insert(skillshotArray,{name= e.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 825, type = 3, radius = 275, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= e.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 90, color= 0x0000FFFF, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
		end
	end
end

SetTimerCallback('Main')