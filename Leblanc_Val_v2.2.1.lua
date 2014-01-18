require 'Utils'
require 'winapi'
require 'SKeys'
require 'spell_damage'
require 'runrunrun'
require 'vals_lib'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local Q,W,E,R = 'Q','W','E','R'
local version = '2.2.1'
local MarkTimer = nil
local ls = nil
local timer = 0
local dodgetimer = 0
local ShowRange = 2500
local jumpspotrange = 50
local jumpmouserange = 75
local Erange = 800
local Edelay = 1.5
local Espeed = 15
local Eradius = 75
local skillshotArray = {}
local xa = 50/1920*GetScreenX()
local xb = 1870/1920*GetScreenX()
local ya = 50/1080*GetScreenY()
local yb = 1030/1080*GetScreenY()
local cc = 0

	LBConf, menu = uiconfig.add_menu('LeBlanc Hotkeys', 250)
	menu.keydown('Qkey', 'Q-Key', Keys.X)
	menu.keydown('Ekey', 'E-Key', Keys.Y)
	menu.keydown('Combo', 'Combo', Keys.Z)
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
		send.tick()
		cc=cc+1
		if cc==30 then LoadTable() end
		for i=1, #skillshotArray, 1 do
			if os.clock() > (skillshotArray[i].lastshot + skillshotArray[i].time) then
				skillshotArray[i].shot = 0
			end
		end
		if GetTickCount()-dodgetimer>DodgeConfig.BlockTime then dodgetimer = 0 end
		Skillshots()
		SetVariables()
		GetSpells()
		CheckSpells()
		GetMark()
		Jump()
		QspellOnce()
		EspellOnce()
		if LBConf.Combo then Combo() end
		if LBConf.Harass then Harass() end
		if LBSettings.KSNotes then KSNotifications() end
		if LBSettings.ReturnPad then ReturnPad() end
	end
end

function QSpell()
	local target = GetWeakEnemy('MAGIC',700)
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
	local targetE = GetWeakEnemy('MAGIC',800)
	if LBConf.Ekey == true then
		if E1RDY==1 then
			if MarkedEnemy~=nil then
				SpellPred(E,E1RDY,myHero,MarkedEnemy,Erange,Edelay,Espeed,1,Eradius)
			elseif targetE~=nil then
				SpellPred(E,E1RDY,myHero,targetE,Erange,Edelay,Espeed,1,Eradius)
			end
		elseif E2RDY==1 then
			if MarkedEnemy~=nil then 
				SpellPred(R,E2RDY,myHero,MarkedEnemy,Erange,Edelay,Espeed,1,Eradius)
			elseif targetE~=nil then
				SpellPred(R,E2RDY,myHero,targetE,Erange,Edelay,Espeed,1,Eradius)
			end
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
	local target = GetWeakEnemy('MAGIC',700)
	if target~=nil and Q1RDY==1 and W1RDY==1 and ls==nil then
		QWW = true
		Ziel = target
		target = nil
	end
	if QWW and Ziel~=nil then
		if ls==nil then SpellTarget(Q,Q1RDY,myHero,Ziel,700) end
		if 	ls=='Q1' then SpellXYZ(W,W1RDY,myHero,Ziel,800,Ziel.x,Ziel.z) end
		if 	ls=='W1' then SpellXYZ(W,W2RDY,myHero,myHero,1,myHero.x,myHero.z) end
		if 	ls=='W2' then
			ls = nil
			Ziel = nil
			QWW = false
			target = GetWeakEnemy('MAGIC',700)
		end
	end
	if LBSettings.MouseMove and dodgetimer==0 then MoveMouse() end
end

function SetVariables()
	if Ziel==nil or (Ziel~=nil and (Ziel.dead==1 or Ziel.invulnerable==1)) or myHero.dead==1 or (LBConf.Combo == false and LBConf.Harass == false) or (timer~=0 and GetTickCount()-timer>750) then
		QRWE,QRE,QRW,QR,QWE,QE,QW,WQRE,WQR,WQE,xE,xQ,QWW = false,false,false,false,false,false,false,false,false,false,false,false,false
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
end

function Wspell()
	if Ziel~=nil and W2RDY==0 then
		if GetDistance(Ziel)<800 then
			EnemyPos = Vector(Ziel.x, Ziel.y, Ziel.z)
			HeroPos = Vector(myHero.x, myHero.y, myHero.z)
			WPos = EnemyPos+(EnemyPos-HeroPos)*(-100/GetDistance(EnemyPos, HeroPos))
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

function CheckSpells()
	if QRWE or QRW or QRE or QR or QWE or QE or QW or xE or xQ or WQRE or WQE or WQR then
		for i = 1, objManager:GetMaxObjects(), 1 do
			obj = objManager:GetObject(i)
			if obj~=nil then
				if obj.charName == 'leBlanc_slide_impact_self.troy' and GetDistance(obj) < 100 and W1 == true then
					ls = 'W1'
					timer = GetTickCount()
				end
			end
		end
	end
end

function OnProcessSpell(unit, spell)
	if unit ~= nil and spell ~= nil and unit.charName == myHero.charName then
		if QRWE or QRW or QRE or QR or QWE or QE or QW or xE or xQ or WQRE or WQE or WQR or QWW then
			if spell.name == 'LeblancChaosOrb' then
				ls = 'Q1'
				timer = GetTickCount()
			end
			if spell.name == 'LeblancChaosOrbM' then
				ls = 'Q2'
				timer = GetTickCount()
			end
			if spell.name == 'LeblancSlide' then
				W1 = true
			else
				W1 = false	
			end
			if spell.name == 'LeblancSoulShackle' then
				ls = 'E1'
				timer = GetTickCount()
			end
			if spell.name == 'ItemBlackfireTorch' or spell.name == 'DeathfireGrasp' then
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
	local target = GetWeakEnemy('MAGIC',700)
	local target2 = GetWeakEnemy('MAGIC',1150)
	if myHero.dead == 0 and LBSettings.DrawCircles then
		if Q1RDY==1 then
			CustomCircle(700,1,2,myHero)
		end
		if Q1RDY==1 and W1RDY==1 then
			CustomCircle(1250,1,5,myHero)
		end
		if target2~=nil and target==nil and Ziel==nil and GetDistance(target2)<1250 then
			CustomCircle(100,4,5,target2)
		elseif target~=nil and GetDistance(target)<700 then
			CustomCircle(100,4,2,target)
		end
		if Ziel~=nil then
			CustomCircle(100,4,1,Ziel)
		end
	end
	if	   Q1RDY==1			 		and W1RDY==1 and W2RDY==0 and E1RDY==1 				and RRDY==1 	and ls==nil		then DrawTextObject('BURST',myHero,Color.Yellow)
	elseif Q1RDY==1 				and W1RDY==1 and W2RDY==0 and E1RDY==0 				and RRDY==1		and ls==nil		then DrawTextObject('QRW',myHero,Color.Yellow)
	elseif Q1RDY==1 				and W1RDY==0 and W2RDY==0 and E1RDY==1 				and RRDY==1		and ls==nil		then DrawTextObject('QRE',myHero,Color.Yellow)
	elseif Q1RDY==1 				and W1RDY==0 and W2RDY==0 and E1RDY==0 				and RRDY==1		and ls==nil		then DrawTextObject('QR',myHero,Color.Yellow)
	elseif Q1RDY==1 and Q2RDY==0 	and W1RDY==1 and W2RDY==0 and E1RDY==1 and E2RDY==0 and RRDY==0 	and ls==nil 	then DrawTextObject('QWE',myHero,Color.Yellow)
	elseif Q1RDY==1 and Q2RDY==0 	and W1RDY==0 and W2RDY==0 and E1RDY==1 and E2RDY==0 and RRDY==0 	and ls==nil		then DrawTextObject('QE',myHero,Color.Yellow)
	elseif Q1RDY==0 and Q2RDY==0 	and W1RDY==1 and W2RDY==0 and E1RDY==1 and E2RDY==0 and RRDY==0 	and ls==nil		then DrawTextObject('WE',myHero,Color.Yellow)
	elseif Q1RDY==1 and Q2RDY==0 	and W1RDY==1 and W2RDY==0 and E1RDY==0 and E2RDY==0 and RRDY==0 	and ls==nil		then DrawTextObject('WQ',myHero,Color.Yellow)
	elseif Q1RDY==0 and Q2RDY==0 	and W1RDY==0 and W2RDY==0 and E1RDY==1 and E2RDY==0 and RRDY==0 	and ls==nil		then DrawTextObject('E',myHero,Color.Yellow)
	elseif Q1RDY==1 and Q2RDY==0 	and W1RDY==0 and W2RDY==0 and E1RDY==0 and E2RDY==0 and RRDY==0 	and ls==nil		then DrawTextObject('Q',myHero,Color.Yellow)
	end
end

function KSNotifications()	
	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0 and enemy.dead == 0) then	

			EnemyPos = Vector(enemy.x, enemy.y, enemy.z)
			HeroPos = Vector(myHero.x, myHero.y, myHero.z)
			WPos = HeroPos+(HeroPos-EnemyPos)*(-600/GetDistance(HeroPos, EnemyPos))
			EPos = HeroPos+(HeroPos-EnemyPos)*(-800/GetDistance(HeroPos, EnemyPos))
			if IsWall(WPos.x,WPos.y,WPos.z)==1 then
				Wall = 1
			else
				Wall = 0
			end
			if CreepBlock(enemy.x, enemy.y, enemy.z,EPos.x,EPos.y,EPos.z)==1 then
				Block = 1
			else
				Block = 0
			end
			
			local Qdam = getDmg("Q",enemy,myHero)
			local Wdam = getDmg("W",enemy,myHero)
			local Edam = getDmg("E",enemy,myHero)
			local QMdam = getDmg("R",enemy,myHero,1)
			local WMdam = getDmg("R",enemy,myHero,2)
			local EMdam = getDmg("R",enemy,myHero,3)
			local DFGdam = getDmg("DFG",enemy,myHero)*DFG
			local BFTdam = getDmg("BLACKFIRE",enemy,myHero)*BFT
			
			EnemyPos = Vector(enemy.x, enemy.y, enemy.z)
			HeroPos = Vector(myHero.x, myHero.y, myHero.z)
			WPos = EnemyPos+(EnemyPos-HeroPos)*(-600/GetDistance(EnemyPos, HeroPos))
			EPos = EnemyPos+(EnemyPos-HeroPos)*(-900/GetDistance(EnemyPos, HeroPos))
			
--[[WQE]]	if enemy.health<(Qdam*2)+Edam and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 and GetDistance(enemy)>700 then
				if Block==1 or Wall == 1 then
					DrawTextObject('WQE (Long) KILL',enemy,Color.Red)
				else
					DrawTextObject('WQE (Long) KILL',enemy,Color.Yellow)
				end
--[[WQR]]	elseif enemy.health<(Qdam*2)+(QMdam*2) and Q1RDY==1 and W1RDY==1 and W2RDY==0 and RRDY==1 and GetDistance(enemy)>700 then
				if Wall == 1 then
					DrawTextObject('WQR (Long) KILL',enemy,Color.Red)
				else
					DrawTextObject('WQR (Long) KILL',enemy,Color.Yellow)
				end
--[[WQRE]]	elseif enemy.health<(Qdam*2)+(QMdam*2)+Edam and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 and RRDY==1 and GetDistance(enemy)>700 then
				if Block==1 or Wall == 1 then
					DrawTextObject('WQRE (Long) KILL',enemy,Color.Red)
				else
					DrawTextObject('WQRE (Long) KILL',enemy,Color.Yellow)
				end
--[[IWQR]]	elseif (enemy.health<(((Qdam*2)+(QMdam*2))+(((Qdam*2)+(QMdam*2))/5)+BFTdam)*BFT or enemy.health<(((Qdam*2)+(QMdam*2))+(((Qdam*2)+(QMdam*2))/5)+DFGdam)*DFG) and Q1RDY==1 and W1RDY==1 and W2RDY==0 and RRDY==1 and GetDistance(enemy)>700 then			
				if Wall == 1 then
					DrawTextObject('IWQR (Long) KILL',enemy,Color.Red)
				else
					DrawTextObject('IWQR (Long) KILL',enemy,Color.Yellow)
				end
--[[IWQRE]]	elseif (enemy.health<(((Qdam*2)+(QMdam*2)+Edam)+(((Qdam*2)+(QMdam*2)+Edam)/5)+BFTdam)*BFT or enemy.health<(((Qdam*2)+(QMdam*2)+Edam)+(((Qdam*2)+(QMdam*2)+Edam)/5)+DFGdam)*DFG) and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 and RRDY==1 and GetDistance(enemy)>700 then
				
				if Block==1 or Wall == 1 then
					DrawTextObject('IWQRE (Long) KILL',enemy,Color.Red)
				else
					DrawTextObject('IWQRE (Long) KILL',enemy,Color.Yellow)
				end
--[[Q]]		elseif enemy.health<Qdam and Q1RDY==1 then
				DrawTextObject('Q KILL',enemy,Color.Yellow)
--[[E]]		elseif enemy.health<Edam and E1RDY==1 then
				if Block==1 then
					DrawTextObject('E KILL',enemy,Color.Red)
				else
					DrawTextObject('E KILL',enemy,Color.Yellow)
				end
--[[QW]]	elseif enemy.health<(Qdam*2)+Wdam and Q1RDY==1 and W1RDY==1 and W2RDY==0 then
				if Wall == 1 then
					DrawTextObject('QW KILL',enemy,Color.Red)
				else
					DrawTextObject('QW KILL',enemy,Color.Yellow)
				end
--[[QE]]	elseif enemy.health<(Qdam*2)+Edam and Q1RDY==1 and E1RDY==1 then 
				if Block==1 then
					DrawTextObject('QE KILL',enemy,Color.Red)
				else
					DrawTextObject('QE KILL',enemy,Color.Yellow)
				end
--[[QWE]]	elseif enemy.health<(Qdam*2)+Wdam+Edam and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 then
				if Block==1 or Wall == 1 then
					DrawTextObject('QWE KILL',enemy,Color.Red)
				else
					DrawTextObject('QWE KILL',enemy,Color.Yellow)
				end
--[[QR]]	elseif enemy.health<(Qdam*2)+QMdam and Q1RDY==1 and RRDY==1 then
				DrawTextObject('QR KILL',enemy,Color.Yellow)
--[[QRE]]	elseif enemy.health<(Qdam*2)+(QMdam*2)+Edam and Q1RDY==1 and E1RDY==1 and RRDY==1 then
				if Block==1 then
					DrawTextObject('QRE KILL',enemy,Color.Red)
				else
					DrawTextObject('QRE KILL',enemy,Color.Yellow)
				end
--[[QRW]]	elseif enemy.health<(Qdam*2)+(QMdam*2)+Wdam and Q1RDY==1 and W1RDY==1 and W2RDY==0 and RRDY==1 then
				if Wall == 1 then
					DrawTextObject('QRW KILL',enemy,Color.Red)
				else
					DrawTextObject('QRW KILL',enemy,Color.Yellow)
				end
--[[QRWE]]	elseif enemy.health<(Qdam*2)+(QMdam*2)+Wdam+Edam and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 and RRDY==1 then
				if Block==1 or Wall == 1 then
					DrawTextObject('QRWE KILL',enemy,Color.Red)
				else
					DrawTextObject('QRWE KILL',enemy,Color.Yellow)
				end
--[[IQR]]	elseif (enemy.health<(((Qdam*2)+QMdam)+(((Qdam*2)+QMdam)/5)+BFTdam)*BFT or enemy.health<(((Qdam*2)+QMdam)+(((Qdam*2)+QMdam)/5)+DFGdam)*DFG) and Q1RDY==1 and RRDY==1 then
				DrawTextObject('IQR KILL',enemy,Color.Yellow)
--[[IQRE]]	elseif (enemy.health<(((Qdam*2)+(QMdam*2)+Edam)+(((Qdam*2)+(QMdam*2)+Edam)/5)+BFTdam)*BFT or enemy.health<(((Qdam*2)+(QMdam*2)+Edam)+(((Qdam*2)+(QMdam*2)+Edam)/5)+DFGdam)*DFG) and Q1RDY==1 and E1RDY==1 and RRDY==1 then			
				if Block==1 then
					DrawTextObject('IQRE KILL',enemy,Color.Red)
				else
					DrawTextObject('IQRE KILL',enemy,Color.Yellow)
				end
--[[IQRW]]	elseif (enemy.health<(((Qdam*2)+(QMdam*2)+Wdam)+(((Qdam*2)+(QMdam*2)+Wdam)/5)+BFTdam)*BFT or enemy.health<(((Qdam*2)+(QMdam*2)+Wdam)+(((Qdam*2)+(QMdam*2)+Wdam)/5)+DFGdam)*DFG) and Q1RDY==1 and W1RDY==1 and W2RDY==0 and RRDY==1 then
				if Wall == 1 then
					DrawTextObject('IQRW KILL',enemy,Color.Red)
				else
					DrawTextObject('IQRW KILL',enemy,Color.Yellow)
				end
--[[IQRWE]]	elseif (enemy.health<(((Qdam*2)+(QMdam*2)+Wdam+Edam)+(((Qdam*2)+(QMdam*2)+Wdam+Edam)/5)+BFTdam)*BFT or enemy.health<(((Qdam*2)+(QMdam*2)+Wdam+Edam)+(((Qdam*2)+(QMdam*2)+Wdam+Edam)/5)+DFGdam)*DFG) and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 and RRDY==1 then
				if Block==1 or Wall == 1 then
					DrawTextObject('IQRWE KILL',enemy,Color.Red)
				else
					DrawTextObject('IQRWE KILL',enemy,Color.Yellow)
				end
			end
		end
	end
end

function Combo()
	local target = GetWeakEnemy('MAGIC',700)
	local targetE = GetWeakEnemy('MAGIC',800)
	local target2 = GetWeakEnemy('MAGIC',1100)
	if target2~=nil then
		EnemyPos = Vector(target2.x, target2.y, target2.z)
		HeroPos = Vector(myHero.x, myHero.y, myHero.z)
		WPos = HeroPos+(HeroPos-EnemyPos)*(-600/GetDistance(HeroPos, EnemyPos))
		if IsWall(WPos.x,WPos.y,WPos.z)==1 then
			Wall = 1
		else
			Wall = 0
		end
	elseif target~=nil then
		EnemyPos = Vector(target.x, target.y, target.z)
		HeroPos = Vector(myHero.x, myHero.y, myHero.z)
		WPos = HeroPos+(HeroPos-EnemyPos)*(-600/GetDistance(HeroPos, EnemyPos))
		if IsWall(WPos.x,WPos.y,WPos.z)==1 then
			Wall = 1
		else
			Wall = 0
		end
	end
	if target2~=nil then
		EnemyPos = Vector(target2.x, target2.y, target2.z)
		HeroPos = Vector(myHero.x, myHero.y, myHero.z)
		EPos = HeroPos+(HeroPos-EnemyPos)*(-800/GetDistance(HeroPos, EnemyPos))
		if CreepBlock(target2.x, target2.y, target2.z,EPos.x,EPos.y,EPos.z)==1 then
			Block = 1
		else
			Block = 0
		end
	elseif target~=nil then
		if CreepBlock(target.x, target.y, target.z)==1 then
			Block = 1
		else
			Block = 0
		end
	end

		if ls==nil then
--[[QRWE]]	if target~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==1 and RRDY==1 and Wall==0 and Block==0 then
				QRWE = true
				Ziel = target
				target = nil
--[[QRE]]	elseif target~=nil and Q1RDY==1 and W1RDY==0 and E1RDY==1 and RRDY==1 and Block==0 then
				QRE = true
				Ziel = target
				target = nil
--[[QRW]]	elseif target~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==0 and RRDY==1 and Wall==0 then
				QRW = true
				Ziel = target
				target = nil
--[[QR]]	elseif target~=nil	and Q1RDY==1 and W1RDY==0 and E1RDY==0 and RRDY==1 then
				QR = true
				Ziel = target
				target = nil
--[[QWE]]	elseif target~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==1 and RRDY==0 and Wall==0 then
				QWE = true
				Ziel = target
				target = nil
--[[QE]]	elseif target~=nil and Q1RDY==1 and W1RDY==0 and E1RDY==1 and RRDY==0 and Block==0 then
				QE = true
				Ziel = target
				target = nil
--[[QW]]	elseif target~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==0 and RRDY==0 and  Wall==0 then
				QW = true
				Ziel = target
				target = nil
--[[WQRE]]	elseif target2~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==1 and RRDY==1 and Wall==0 and Block==0 then
				WQRE = true
				Ziel = target2
				target2 = nil
--[[WQR]]	elseif target2~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==0 and RRDY==1 and Wall==0 then
				WQR = true
				Ziel = target2
				target2 = nil
--[[WQE]]	elseif target2~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==1 and RRDY==0 and Wall==0 and Block==0 then
				WQE = true
				Ziel = target2
				target2 = nil
--[[E]]		elseif targetE~=nil and Q1RDY==0 and Q2RDY==0 and W1RDY==0 and E1RDY==1 and Block==0 then
				xE = true
				Ziel = targetE
				targetE = nil
--[[Q]]		elseif target~=nil and Q1RDY==1 and W1RDY==0 and E1RDY==0 and RRDY==0 then
				xQ = true
				Ziel = target
				target = nil
			end
		end
		
--[[QRWE]]	if QRWE and Ziel~=nil then
				if  ls==nil  then UseDFGBFT() end
				if  ((BFT==0 and ls==nil) or ls=='item') then SpellTarget(Q,Q1RDY,myHero,Ziel,700) end
				if 	ls=='Q1' then SpellTarget(R,Q2RDY,myHero,Ziel,700) end
				if 	ls=='Q2' then run_many_reset(1, Wspell) end
				if 	ls=='W1' then Espell() end
				if	ls=='E1' and LBSettings.AWB==false then
					QRWE = false
					target = GetWeakEnemy('MAGIC',700)
				elseif	ls=='E1' and LBSettings.AWB==true then SpellXYZ(W,W2RDY,myHero,myHero,1,myHero.x,myHero.z)
				elseif	ls=='W2' and LBSettings.AWB==true then
					QRWE = false
					target = GetWeakEnemy('MAGIC',700)
				end
--[[QRE]]	elseif QRE and Ziel~=nil then
				if  ls==nil  then UseDFGBFT() end
				if  ((BFT==0 and ls==nil) or ls=='item') then SpellTarget(Q,Q1RDY,myHero,Ziel,700) end
				if ls=='Q1' then SpellTarget(R,Q2RDY,myHero,Ziel,700) end
				if ls=='Q2' then Espell() end
				if	ls=='E1' then
					QRE = false
					target = GetWeakEnemy('MAGIC',700)
				end
--[[QRW]]	elseif QRW and Ziel~=nil then
				if  ls==nil  then UseDFGBFT() end
				if  ((BFT==0 and ls==nil) or ls=='item') then SpellTarget(Q,Q1RDY,myHero,Ziel,700) end
				if 	ls=='Q1' then SpellTarget(R,Q2RDY,myHero,Ziel,700) end
				if 	ls=='Q2' then run_many_reset(1, Wspell) end
				if 	ls=='W1' and LBSettings.AWB==false then
					QRW = false
					target = GetWeakEnemy('MAGIC',700)
				elseif 	ls=='W1' and LBSettings.AWB==true then SpellXYZ(W,W2RDY,myHero,myHero,1,myHero.x,myHero.z)
				elseif	ls=='W2' and LBSettings.AWB==true then
					QWE = false
					target = GetWeakEnemy('MAGIC',700)
				end
--[[QR]]	elseif QR and Ziel~=nil then
				if  ls==nil  then UseDFGBFT() end
				if  ((BFT==0 and ls==nil) or ls=='item') then SpellTarget(Q,Q1RDY,myHero,Ziel,700) end
				if 	ls=='Q1' then SpellTarget(R,Q2RDY,myHero,Ziel,700) end
				if 	ls=='Q2' then
					QR = false
					target = GetWeakEnemy('MAGIC',700)
				end
--[[QWE]]	elseif QWE and Ziel~=nil then
				if		ls==nil  then SpellTarget(Q,Q1RDY,myHero,Ziel,700) end
				if 	ls=='Q1' then run_many_reset(1, Wspell) end
				if 	ls=='W1' then Espell() end
				if	ls=='E1' and LBSettings.AWB==false then
					QWE = false
					target = GetWeakEnemy('MAGIC',700)
				elseif	ls=='E1' and LBSettings.AWB==true then SpellXYZ(W,W2RDY,myHero,myHero,1,myHero.x,myHero.z)
				elseif	ls=='W2' and LBSettings.AWB==true then
					QWE = false
					target = GetWeakEnemy('MAGIC',700)
				end
--[[QE]]	elseif QE and Ziel~=nil then
				if		ls==nil  then SpellTarget(Q,Q1RDY,myHero,Ziel,700) end
				if 	ls=='Q1' then Espell() end
				if 	ls=='E1' then
					QE = false
					target = GetWeakEnemy('MAGIC',700)
				end
--[[QW]]	elseif QW and Ziel~=nil then
				if		ls==nil  then SpellTarget(Q,Q1RDY,myHero,Ziel,700) end
				if 	ls=='Q1' then run_many_reset(1, Wspell) end
				if	ls=='W1' and LBSettings.AWB==false then
					QW = false
					target = GetWeakEnemy('MAGIC',700)
				elseif	ls=='W1' and LBSettings.AWB==true then SpellXYZ(W,W2RDY,myHero,myHero,1,myHero.x,myHero.z)
				elseif	ls=='W2' and LBSettings.AWB==true then
					QW = false
					target = GetWeakEnemy('MAGIC',700)
				end
--[[WQRE]]	elseif WQRE and Ziel~=nil then
				if	ls==nil  then run_many_reset(1, WLspell) end
				if 	ls=='W1' then UseDFGBFT() end
				if  ((BFT==0 and ls=='W1') or ls=='item') then SpellTarget(Q,Q1RDY,myHero,Ziel,700) end
				if 	ls=='Q1' then SpellTarget(R,Q2RDY,myHero,Ziel,700) end
				if 	ls=='Q2' then Espell() end
				if	ls=='E1' then
					WQRE = false
					target2 = GetWeakEnemy('MAGIC',1150)
				end
--[[WQR]]	elseif WQR and Ziel~=nil then
				if		ls==nil  then run_many_reset(1, WLspell) end
				if 	ls=='W1' then UseDFGBFT() end
				if  ((BFT==0 and ls=='W1') or ls=='item') then SpellTarget(Q,Q1RDY,myHero,Ziel,700) end
				if 	ls=='Q1' then SpellTarget(R,Q2RDY,myHero,Ziel,700) end
				if 	ls=='Q2' then
					WQR = false
					target2 = GetWeakEnemy('MAGIC',1150)
				end
--[[WQE]]	elseif WQE and Ziel~=nil then
				if		ls==nil  then run_many_reset(1, WLspell) end
				if 	ls=='W1' then UseDFGBFT() end
				if  ((BFT==0 and ls=='W1') or ls=='item') then SpellTarget(Q,Q1RDY,myHero,Ziel,700) end
				if 	ls=='Q1' then Espell() end
				if	ls=='E1' then
					WQE = false
					target2 = GetWeakEnemy('MAGIC',1150)
				end
--[[xE]]	elseif xE and Ziel~=nil then
				if		ls==nil  then Espell() end
				if	ls=='E1' then
					xE = false
					targetE = GetWeakEnemy('MAGIC',800)
				end
--[[xQ]]	elseif xQ and Ziel~=nil then
				if		ls==nil  then SpellTarget(Q,Q1RDY,myHero,Ziel,700) end
				if	ls=='Q1' then
					xQ = false 
					target = GetWeakEnemy('MAGIC',700)
				end
			end
	if (QRWE==false and QRE==false and QRW==false and QR==false and QWE==false and QE==false and QW==false and WQRE==false and WQR==false and WQE==false and xE==false and xQ==false) then
		ls = nil
		Ziel = nil
	end
	if LBSettings.MouseMove and dodgetimer == 0 then 
		if Ziel~=nil then
			MoveTarget(Ziel)
		else
			MoveMouse()
		end
	end
end

function Espell()
	if Ziel~=nil then
		if GetDistance(Ziel)<250 then
			SpellXYZ(E,E1RDY,myHero,Ziel,250,Ziel.x,Ziel.z)
		else
			SpellPred(E,E1RDY,myHero,Ziel,Erange,Edelay,Espeed,1,Eradius)
		end
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
        if obj~=nil then
			if obj.charName == 'Leblanc_displacement_blink_indicator.troy' then
				DrawSphere(85,30,5,obj.x,obj.y,obj.z)
			end
			if obj.charName == 'Leblanc_displacement_blink_indicator_ult.troy' then
				DrawSphere(85,30,4,obj.x,obj.y,obj.z)
			end
		end
	end
end

function GetMark()
	for i = 1, objManager:GetMaxNewObjects(), 1 do
		obj = objManager:GetNewObject(i)
		for i = 1, objManager:GetMaxHeroes() do
			local enemy = objManager:GetHero(i)
			if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0 and enemy.dead == 0) then
				if obj~=nil and enemy~=nil then
					if string.find(obj.charName,'leBlanc_chaosOrb_impact_small') and GetDistance(obj, enemy) < 50 then
						MarkedEnemy = enemy
						MarkTimer = GetTickCount()
					end
				end
				if obj~=nil and MarkedEnemy~=nil then
					if 	string.find(obj.charName,'leBlanc_shackle_mis') or 
						string.find(obj.charName,'leBlanc_slide_impact_unit') or 
						string.find(obj.charName,'leBlanc_shackle_target_idle') and 
						GetDistance(obj, MarkedEnemy) < 50 then
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

local JumpSpots = {
{x = 2856, y = -188, z = 2637},
{x = 2631, y = -188, z = 3125},
{x = 3384, y = -189, z = 2221},
{x = 3831, y = -189, z = 2475},
{x = 4408, y = -189, z = 1402},
{x = 4467, y = -189, z = 1985},
{x = 5107, y = -189, z = 3207},
{x = 5081, y = -189, z = 2625},
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
{x = 12000, y = -189, z = 7743},
{x = 12129, y = -189, z = 7173},
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
{x = 5308, y = -189, z = 10244},
{x = 5431, y = -189, z = 9673},
{x = 3780, y = -189, z = 9213},
{x = 4267, y = -189, z = 8873},
{x = 3303, y = -189, z = 8628},
{x = 3701, y = -189, z = 8203},
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
{x = 7243, y = -189, z = 8329},
{x = 6681, y = -189, z = 8323},
{x = 7545, y = -189, z = 7359},
{x = 7400, y = -189, z = 7933},
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
	local a5x,a5z = 7545,7359
	local b5x,b5z = 7400,7933
	local a9x,a9z = 7243,8329
	local b9x,b9z = 6681,8323
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
	local a15x,a15z = 3303,8628
	local b15x,b15z = 3701,8203
	local a16x,a16z = 3780,9213
	local b16x,b16z = 4267,8873
	local a17x,a17z = 5308,10244
	local b17x,b17z = 5431,9673
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
	local a25x,a25z = 12000,7743
	local b25x,b25z = 12129,7173
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
	local a35x,a35z = 5107,3207
	local b35x,b35z = 5081,2625
	local a36x,a36z = 4408,1402
	local b36x,b36z = 4467,1985
	local a37x,a37z = 3384,2221
	local b37x,b37z = 3831,2475
	local a38x,a38z = 2856,2637
	local b38x,b38z = 2631,3125
		
	for _, JumpSpot in pairs(JumpSpots) do
		if LBSettings.jumphelper and GetMap() == 2 then
			if GetDistance(JumpSpot,myHero) <= ShowRange then
				if GetDistance(JumpSpot,mousePos) <= jumpmouserange then
					DrawCircle(JumpSpot.x, JumpSpot.y, JumpSpot.z, jumpmouserange, 0xFFFF0000)
				else DrawCircle(JumpSpot.x, JumpSpot.y, JumpSpot.z, jumpmouserange, 0xFFFF8000)
				end
			end
		end
	end
       
	for _, JumpSpot in pairs(JumpSpots) do
		if GetDistance(JumpSpot,mousePos) <= jumpmouserange and KeyDown(1) and LBSettings.jumphelper and GetMap() == 2 then
			MoveToXYZ(JumpSpot.x,JumpSpot.y,JumpSpot.z)
			jump2 = true
		end
	end
       
	if (KeyDown(2) or LBConf.Combo) and LBSettings.jumphelper then
		jump2 = false
	end
       
	if jump2 == true and LBSettings.jumphelper and W1RDY == 1 and GetMap() == 2 then
		local p = myHero
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
					DrawLine(startVector.x, startVector.y, startVector.z, GetDistance(startVector, endVector)+170, 1,angle,radius)
				end
			end
		end
	end
end

function LoadTable()
	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if (enemy ~= nil and enemy.team ~= myHero.team) then
			if enemy.name == 'Aatrox' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 3, radius = 225, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 125, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			end
			if enemy.name == 'Ahri' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 880, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			end
			if enemy.name == 'Alistar' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 50, type = 3, radius = 200, color= 0x0000FFFF, time = 0.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			end
			if enemy.name == 'Amumu' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			end
			if enemy.name == 'Anivia' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 90, color= 0x0000FFFF, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			end
			if enemy.name == 'Annie' then
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 3, radius = 300, color= 0x0000FFFF, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
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
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 175, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 125, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Caitlyn' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 50, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Corki' then
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1225, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 2, radius = 150, color= 0x0000FFFF, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Chogath' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 275, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Darius' then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 540, type = 1, radius = 125, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Diana' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 205, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Draven' then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 125, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 1, radius = 100, color= 0x0000FFFF, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'DrMundo' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Elise' and enemy.range>300 then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Ezreal' then
				table.insert(skillshotArray,{name= enemy.SpellNameWe, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 4, radius = 150, color= 0x0000FFFF, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if enemy.name == 'FiddleSticks' then
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 600, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if enemy.name == 'Fizz' then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 400, type = 3, radius = 300, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })				
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 550, type = 1, radius = 100, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1275, type = 2, radius = 100, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Galio' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 905, type = 3, radius = 200, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 120, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Gragas' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 320, color= 0xFFFFFF00, time = 2.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 2, radius = 60, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 3, radius = 400, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Graves' then
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 110, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 750, type = 1, radius = 50, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 3, radius = 275, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Hecarim' then
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 125, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Heimerdinger' then
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 225, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			--[[if enemy.name == 'Irelia' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 80, color= 0x0000FFFF, time = 0.8, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end]]
			if enemy.name == 'Janna' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1700, type = 1, radius = 100, color= 0x0000FFFF, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'JarvanIV' then
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 830, type = 3, radius = 150, color= 0xFFFFFF00, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 770, type = 1, radius = 70, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Jayce' and enemy.range>300 then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1500, type = 1, radius = 125, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Jinx' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1500, type = 1.5, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 3, radius = 225, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Karma' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Karthus' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 875, type = 3, radius = 150, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Kassadin' then
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 5, radius = 150, color= 0xFF00FF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Kennen' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 75, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Khazix' then	
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 75, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })	
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 310, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'KogMaw' then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1115, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2200, type = 3, radius = 200, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Leblanc' then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 3, radius = 250, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'LeeSin' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Leona' then
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 160, color= 0x0000FFFF, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Lissandra' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 725, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 120, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
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
			if enemy.name == 'Malphite' then
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 325, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Malzahar' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 100 , color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 250 , color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Maokai' then
				table.insert(skillshotArray,{name= 'MaokaiTrunkLineMissile', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 350 , color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'MissFortune' then
				table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 400, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if enemy.name == 'Morgana' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 100, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 350, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
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
			if enemy.name == 'Nocturne' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if enemy.name == 'Olaf' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 2, radius = 100, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Orianna' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 825, type = 3, radius = 150, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			end
			if enemy.name == 'Quinn' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1025, type = 1, radius = 150, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Renekton' then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 450, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
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
			if enemy.name == 'Tristana' then
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 200, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			end
			if enemy.name == 'Tryndamere' then
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 2, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
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
				table.insert(skillshotArray,{name= 'xeratharcanopulsedamage', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= 'xeratharcanopulsedamageextended', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
				table.insert(skillshotArray,{name= 'xeratharcanebarragewrapper', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= 'xeratharcanebarragewrapperext', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 3, radius = 250, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
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

SetTimerCallback('Main')