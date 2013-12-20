require 'Utils'
require 'winapi'
require 'SKeys'
require 'spell_damage'
require 'vals_lib'
require 'runrunrun'
local uiconfig = require 'uiconfig'
local Q,W,E,R = 'Q','W','E','R'
local version = '1.9.2'
local MarkTimer = nil
local ls = nil

function Main()
	if IsLolActive() and IsChatOpen() == 0 then
		GetSpells()
		SetVariables()
		GetMark()
		if ls == nil then LB_Items() end
		QspellOnce()
		EspellOnce()
		IsWall2()
		if LBConf.Combo then Combo() end
		if LBConf.Harass then Harass() end
		if LBSettings.KSNotes then KSNotifications() end
		if LBSettings.ReturnPad then ReturnPad() end
	end
end

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
	menu.checkbutton('KSNotes', 'KSNotes', true)
	menu.checkbutton('ReturnPad', 'Draw ReturnPad', true)
	menu.checkbutton('MouseMove', 'MouseMove', true)
	
	CfgItems, menu = uiconfig.add_menu('LB Items', 250)
	menu.checkbutton('Zhonyas_Hourglass_ONOFF', 'Zhonyas Hourglass', true)
	menu.checkbutton('Wooglets_Witchcap_ONOFF', 'Wooglets Witchcap', true)
	menu.checkbutton('Seraphs_Embrace_ONOFF', 'Seraphs Embrace', true)
	menu.slider('Zhonyas_Hourglass_Value', 'Zhonya Hourglass Value', 0, 100, 15, nil, true)
	menu.slider('Wooglets_Witchcap_Value', 'Wooglets Witchcap Value', 0, 100, 15, nil, true)
	menu.slider('Seraphs_Embrace_Value', 'Seraphs Embrace Value', 0, 100, 15, nil, true)
	
function OnProcessSpell(unit, spell)
	if unit ~= nil and spell ~= nil and unit.charName == myHero.charName then
		if LBConf.Combo or LBConf.Harass then
			if spell.name == 'LeblancChaosOrb' then ls = 'Q1' end
			if spell.name == 'LeblancChaosOrbM' then ls = 'Q2' end
			if spell.name == 'LeblancSlide' then ls = 'W1' end
			if spell.name == 'leblancslidereturn' then ls = 'W2' end
			if spell.name == 'LeblancSoulShackle' then ls = 'E1' end
			if spell.name == 'LeblancSoulShackleM' then ls = 'E2' end
		end
	end
end

function Harass()
	local targeth = GetWeakEnemy('MAGIC',800)
	if targeth~=nil and Q1RDY==1 and W1RDY==1 and W2RDY==0 and ls==nil then
		QWW = true
		Ziel = targeth
	end
	if QWW and ls==nil then
		Qspell()
	elseif 	ls=='Q1' then Wspell()
	elseif 	ls=='W1' then CastSpellXYZ('W',myHero.x,myHero.y,myHero.z)
	elseif 	ls=='W2' then 
		ls = nil
		Ziel = nil
		QWW = false
	end
	if LBSettings.MouseMove then MoveMouse() end
end
			
function QspellOnce()
	run_many_reset(1, QSpell)
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

function EspellOnce()
	run_many_reset(1, ESpell)
end	
	
function ESpell()
	if LBConf.Ekey == true then
		if E1RDY==1 then
			if MarkedEnemy~=nil then
				SpellPredSimple(E,E1RDY,myHero,MarkedEnemy,850,1.6,16,1)
			elseif targetE~=nil then
				if GetDistance(myHero,targetE)<850 then
					SpellPredSimple(E,E1RDY,myHero,targetE,850,1.6,16,1)
				end
			end
		elseif E2RDY==1 then
			if MarkedEnemy~=nil then 
				if GetDistance(myHero,MarkedEnemy)<850 then
					SpellPredSimple(R,E2RDY,myHero,MarkedEnemy,850,1.6,16,1)
				end
			elseif targetE~=nil then
				SpellPredSimple(R,E2RDY,myHero,targetE,850,1.6,16,1)
			end
		end
	end
end

function SetVariables()
	target = GetWeakEnemy('MAGIC',700)
	target2 = GetWeakEnemy('MAGIC',1150)
	targetE = GetWeakEnemy('MAGIC',850)
	
	if LBConf.Combo == false then
		QRWE = false
		QRW = false
		QRE = false
		QR = false
		QWE = false
		QE = false
		WE = false
		WQRE = false
		WE = false
		WQ = false
		WQE = false
		WQR = false
		xE = false
		xQ = false
	end
	if LBConf.Harass == false then
		QWW = false
	end
	if LBConf.Combo == false and LBConf.Harass == false then
		ls = nil
		Ziel = nil
	end
	
	if GetInventorySlot(3128)==1 and myHero.SpellTime1 >= 1 then BFT = 1
	elseif GetInventorySlot(3128)==2 and myHero.SpellTime2 >= 1 then BFT = 1
	elseif GetInventorySlot(3128)==3 and myHero.SpellTime3 >= 1 then BFT = 1
	elseif GetInventorySlot(3128)==4 and myHero.SpellTime4 >= 1 then BFT = 1
	elseif GetInventorySlot(3128)==5 and myHero.SpellTime5 >= 1 then BFT = 1
	elseif GetInventorySlot(3128)==6 and myHero.SpellTime6 >= 1 then BFT = 1
	else BFT = 0
	end
	
	if GetInventorySlot(3188)==1 and myHero.SpellTime1 >= 1 then DFG = 1
	elseif GetInventorySlot(3188)==2 and myHero.SpellTime2 >= 1 then DFG = 1
	elseif GetInventorySlot(3188)==3 and myHero.SpellTime3 >= 1 then DFG = 1
	elseif GetInventorySlot(3188)==4 and myHero.SpellTime4 >= 1 then DFG = 1
	elseif GetInventorySlot(3188)==5 and myHero.SpellTime5 >= 1 then DFG = 1
	elseif GetInventorySlot(3188)==6 and myHero.SpellTime6 >= 1 then DFG = 1
	else DFG = 0
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
	if myHero.dead == 0 then
		if Q1RDY==1 then
			CustomCircle(700,1,2,myHero)
		end
		if Q1RDY==1 and W1RDY==1 then
			CustomCircle((1150),1,5,myHero)
		end
		if target2~=nil and target==nil and GetDistance(target2)<1150 then
			CustomCircle(100,4,5,target2)
		elseif target~=nil and GetDistance(target)<700 then
			CustomCircle(100,4,2,target)
		end
	end
	if	   Q1RDY==1			 		and W1RDY==1 and W2RDY==0 and E1RDY==1 				and RRDY==1 	and ls==nil		then DrawTextObject('BURST',myHero,Color.Yellow)
	elseif Q1RDY==1 				and W1RDY==1 and W2RDY==0 and E1RDY==0 				and RRDY==1		and ls==nil		then DrawTextObject('QRW / WQR',myHero,Color.Yellow)
	elseif Q1RDY==1 				and W1RDY==0 and W2RDY==0 and E1RDY==1 				and RRDY==1		and ls==nil		then DrawTextObject('QRE',myHero,Color.Yellow)
	elseif Q1RDY==1 				and W1RDY==0 and W2RDY==0 and E1RDY==0 				and RRDY==1		and ls==nil		then DrawTextObject('QR',myHero,Color.Yellow)
	elseif Q1RDY==1 and Q2RDY==0 	and W1RDY==1 and W2RDY==0 and E1RDY==1 and E2RDY==0 and RRDY==0 	and ls==nil 	then DrawTextObject('QWE/WQE',myHero,Color.Yellow)
	elseif Q1RDY==1 and Q2RDY==0 	and W1RDY==0 and W2RDY==0 and E1RDY==1 and E2RDY==0 and RRDY==0 	and ls==nil		then DrawTextObject('QE',myHero,Color.Yellow)
	elseif Q1RDY==0 and Q2RDY==0 	and W1RDY==1 and W2RDY==0 and E1RDY==1 and E2RDY==0 and RRDY==0 	and ls==nil		then DrawTextObject('WE',myHero,Color.Yellow)
	elseif Q1RDY==1 and Q2RDY==0 	and W1RDY==1 and W2RDY==0 and E1RDY==0 and E2RDY==0 and RRDY==0 	and ls==nil		then DrawTextObject('WQ',myHero,Color.Yellow)
	elseif Q1RDY==0 and Q2RDY==0 	and W1RDY==0 and W2RDY==0 and E1RDY==1 and E2RDY==0 and RRDY==0 	and ls==nil		then DrawTextObject('E',myHero,Color.Yellow)
	elseif Q1RDY==1 and Q2RDY==0 	and W1RDY==0 and W2RDY==0 and E1RDY==0 and E2RDY==0 and RRDY==0 	and ls==nil		then DrawTextObject('Q',myHero,Color.Yellow)
	end
end

function IsWall2()
	if target2~=nil then
		EnemyPos = Vector(target2.x, target2.y, target2.z)
		HeroPos = Vector(myHero.x, myHero.y, myHero.z)
		WPos = HeroPos+(HeroPos-EnemyPos)*(-600/GetDistance(HeroPos, EnemyPos))
		if IsWall(WPos.x,WPos.y,WPos.z)==1 then
			Wall2 = 1
		elseif IsWall(WPos.x,WPos.y,WPos.z)==0 then
			Wall2 = 0
		end
	else
		Wall2 = 0
	end
end

function KSNotifications()	
	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0 and enemy.dead == 0) then			
			
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
			EPos = EnemyPos+(EnemyPos-HeroPos)*(-850/GetDistance(EnemyPos, HeroPos))
			
--[[WQ]]	if enemy.health<Qdam and Q1RDY==1 and W1RDY==1 and GetDistance(enemy)>700 then
				if Wall2 == 1 then
					DrawTextObject('WQ (Long) KILL',enemy,Color.Red)
				else
					DrawTextObject('WQ (Long) KILL',enemy,Color.Yellow)
				end
--[[WQE]]	elseif enemy.health<(Qdam*2)+Edam and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 and GetDistance(enemy)>700 then
				if (GetDistance(myHero,enemy)<1200 and CreepBlock(WPos.x,WPos.y,WPos.z,enemy.x,enemy.y,enemy.z)==1) or (GetDistance(myHero,enemy)>1200 and CreepBlock(EPos.x,EPos.y,EPos.z,enemy.x,enemy.y,enemy.z)==1) or Wall2 == 1 then
					DrawTextObject('WQE (Long) KILL',enemy,Color.Red)
				else
					DrawTextObject('WQE (Long) KILL',enemy,Color.Yellow)
				end
--[[WQR]]	elseif enemy.health<(Qdam*2)+(QMdam*2) and Q1RDY==1 and W1RDY==1 and W2RDY==0 and RRDY==1 and GetDistance(enemy)>700 then
				if Wall2 == 1 then
					DrawTextObject('WQR (Long) KILL',enemy,Color.Red)
				else
					DrawTextObject('WQR (Long) KILL',enemy,Color.Yellow)
				end
--[[WQRE]]	elseif enemy.health<(Qdam*2)+(QMdam*2)+Edam and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 and RRDY==1 and GetDistance(enemy)>700 then
				if (GetDistance(myHero,enemy)<1200 and CreepBlock(WPos.x,WPos.y,WPos.z,enemy.x,enemy.y,enemy.z)==1) or (GetDistance(myHero,enemy)>1200 and CreepBlock(EPos.x,EPos.y,EPos.z,enemy.x,enemy.y,enemy.z)==1) or Wall2 == 1 then
					DrawTextObject('WQRE (Long) KILL',enemy,Color.Red)
				else
					DrawTextObject('WQRE (Long) KILL',enemy,Color.Yellow)
				end
--[[IWQR]]	elseif (enemy.health<(((Qdam*2)+(QMdam*2))+(((Qdam*2)+(QMdam*2))/5)+BFTdam)*BFT or enemy.health<(((Qdam*2)+(QMdam*2))+(((Qdam*2)+(QMdam*2))/5)+DFGdam)*DFG) and Q1RDY==1 and W1RDY==1 and W2RDY==0 and RRDY==1 and GetDistance(enemy)>700 then
				if Wall2 == 1 then
					DrawTextObject('IWQR (Long) KILL',enemy,Color.Red)
				else
					DrawTextObject('IWQR (Long) KILL',enemy,Color.Yellow)
				end
--[[IWQRE]]	elseif (enemy.health<(((Qdam*2)+(QMdam*2)+Edam)+(((Qdam*2)+(QMdam*2)+Edam)/5)+BFTdam)*BFT or enemy.health<(((Qdam*2)+(QMdam*2)+Edam)+(((Qdam*2)+(QMdam*2)+Edam)/5)+DFGdam)*DFG) and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 and RRDY==1 and GetDistance(enemy)>700 then
				if (GetDistance(myHero,enemy)<1200 and CreepBlock(WPos.x,WPos.y,WPos.z,enemy.x,enemy.y,enemy.z)==1) or (GetDistance(myHero,enemy)>1200 and CreepBlock(EPos.x,EPos.y,EPos.z,enemy.x,enemy.y,enemy.z)==1) then
					DrawTextObject('IWQRE (Long) KILL',enemy,Color.Red)
				else
					DrawTextObject('IWQRE (Long) KILL',enemy,Color.Yellow)
				end
--[[Q]]		elseif enemy.health<Qdam and Q1RDY==1 then
				DrawTextObject('Q KILL',enemy,Color.Yellow)
--[[E]]		elseif enemy.health<Edam and E1RDY==1 then
				DrawTextObject('E KILL',enemy,Color.Yellow)
--[[WE]]	elseif enemy.health<Wdam+Edam and W1RDY==1 and W2RDY==0 and E1RDY==1 then
				if (GetDistance(myHero,enemy)<1200 and CreepBlock(WPos.x,WPos.y,WPos.z,enemy.x,enemy.y,enemy.z)==1) or (GetDistance(myHero,enemy)>1200 and CreepBlock(EPos.x,EPos.y,EPos.z,enemy.x,enemy.y,enemy.z)==1) or Wall2 == 1 then
					DrawTextObject('WE (Long) KILL',enemy,Color.Red)
				else
					DrawTextObject('WE (Long) KILL',enemy,Color.Yellow)
				end
--[[QW]]	elseif enemy.health<(Qdam*2)+Wdam and Q1RDY==1 and W1RDY==1 and W2RDY==0 then
				if Wall2 == 1 then
					DrawTextObject('QW KILL',enemy,Color.Red)
				else
					DrawTextObject('QW KILL',enemy,Color.Yellow)
				end
--[[QE]]	elseif enemy.health<(Qdam*2)+Edam and Q1RDY==1 and E1RDY==1 then 
				DrawTextObject('QE KILL',enemy,Color.Yellow)
--[[QWE]]	elseif enemy.health<(Qdam*2)+Wdam+Edam and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 then
				if CreepBlock(WPos.x,WPos.y,WPos.z,enemy.x,enemy.y,enemy.z)==1 or Wall2 == 1 then
					DrawTextObject('QWE KILL',enemy,Color.Red)
				else
					DrawTextObject('QWE KILL',enemy,Color.Yellow)
				end
--[[QR]]	elseif enemy.health<(Qdam*2)+QMdam and Q1RDY==1 and RRDY==1 then
				DrawTextObject('QR KILL',enemy,Color.Yellow)
--[[QRE]]	elseif enemy.health<(Qdam*2)+(QMdam*2)+Edam and Q1RDY==1 and E1RDY==1 and RRDY==1 then
				if CreepBlock(WPos.x,WPos.y,WPos.z,enemy.x,enemy.y,enemy.z)==1 then
					DrawTextObject('QRE KILL',enemy,Color.Red)
				else
					DrawTextObject('QRE KILL',enemy,Color.Yellow)
				end
--[[QRW]]	elseif enemy.health<(Qdam*2)+(QMdam*2)+Wdam and Q1RDY==1 and W1RDY==1 and W2RDY==0 and RRDY==1 then
				DrawTextObject('QRW KILL',enemy,Color.Yellow)
--[[QRWE]]	elseif enemy.health<(Qdam*2)+(QMdam*2)+Wdam+Edam and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 and RRDY==1 then
				if CreepBlock(WPos.x,WPos.y,WPos.z,enemy.x,enemy.y,enemy.z)==1 then
					DrawTextObject('QRWE KILL',enemy,Color.Red)
				else
					DrawTextObject('QRWE KILL',enemy,Color.Yellow)
				end
--[[IQR]]	elseif (enemy.health<(((Qdam*2)+QMdam)+(((Qdam*2)+QMdam)/5)+BFTdam)*BFT or enemy.health<(((Qdam*2)+QMdam)+(((Qdam*2)+QMdam)/5)+DFGdam)*DFG) and Q1RDY==1 and RRDY==1 then
				DrawTextObject('IQR KILL',enemy,Color.Yellow)
--[[IQRE]]	elseif (enemy.health<(((Qdam*2)+(QMdam*2)+Edam)+(((Qdam*2)+(QMdam*2)+Edam)/5)+BFTdam)*BFT or enemy.health<(((Qdam*2)+(QMdam*2)+Edam)+(((Qdam*2)+(QMdam*2)+Edam)/5)+DFGdam)*DFG) and Q1RDY==1 and E1RDY==1 and RRDY==1 then
				if CreepBlock(WPos.x,WPos.y,WPos.z,enemy.x,enemy.y,enemy.z)==1 then
					DrawTextObject('IQRE KILL',enemy,Color.Red)
				else
					DrawTextObject('IQRE KILL',enemy,Color.Yellow)
				end
--[[IQRW]]	elseif (enemy.health<(((Qdam*2)+(QMdam*2)+Wdam)+(((Qdam*2)+(QMdam*2)+Wdam)/5)+BFTdam)*BFT or enemy.health<(((Qdam*2)+(QMdam*2)+Wdam)+(((Qdam*2)+(QMdam*2)+Wdam)/5)+DFGdam)*DFG) and Q1RDY==1 and W1RDY==1 and W2RDY==0 and RRDY==1 then
				DrawTextObject('IQRW KILL',enemy,Color.Yellow)
--[[IQRWE]]	elseif (enemy.health<(((Qdam*2)+(QMdam*2)+Wdam+Edam)+(((Qdam*2)+(QMdam*2)+Wdam+Edam)/5)+BFTdam)*BFT or enemy.health<(((Qdam*2)+(QMdam*2)+Wdam+Edam)+(((Qdam*2)+(QMdam*2)+Wdam+Edam)/5)+DFGdam)*DFG) and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 and RRDY==1 then
				if CreepBlock(WPos.x,WPos.y,WPos.z,enemy.x,enemy.y,enemy.z)==1 then
					DrawTextObject('IQRWE KILL',enemy,Color.Red)
				else
					DrawTextObject('IQRWE KILL',enemy,Color.Yellow)
				end
			end
		end
	end
end

function Combo()
		if ls==nil then
--[[QRWE]]	if target~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==1 and RRDY==1 then QRWE = true
--[[QRE]]	elseif target~=nil and Q1RDY==1 and W1RDY==0 and E1RDY==1 and RRDY==1 then QRE = true
--[[QRW]]	elseif target~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==0 and RRDY==1 then QRW = true
--[[QR]]	elseif target~=nil 	and Q1RDY==1 and W1RDY==0 and E1RDY==0 and RRDY==1 then QR = true
--[[QWE]]	elseif target~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==1 and RRDY==0 then QWE = true
--[[QE]]	elseif target~=nil and Q1RDY==1 and W1RDY==0 and E1RDY==1 and RRDY==0 and ls==nilm and CreepBlock(target.x,target.y,target.z) == 0 then QE = true
--[[WE]]	elseif target~=nil and Q1RDY==0 and W1RDY==1 and E1RDY==1 and RRDY==0 then WE = true
--[[WQRE]]	elseif target2~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==1 and RRDY==1 and Wall2 == 0 then WQRE = true
--[[WQR]]	elseif target2~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==0 and RRDY==1 and Wall2 == 0 then WQR = true
--[[WQE]]	elseif target2~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==1 and RRDY==0 and Wall2 == 0 then WQE = true
--[[WQ]]	elseif target2~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==0 and RRDY==0 and Wall2 == 0 then WQ = true
--[[WE]]	elseif target2~=nil and Q1RDY==0 and W1RDY==1 and E1RDY==1 and Wall2 == 0 then  WE = true
--[[E]]		elseif target~=nil and Q1RDY==0 and Q2RDY==0 and W1RDY==0 and E1RDY==1 and CreepBlock(target.x,target.y,target.z) == 0 then xE = true
--[[Q]]		elseif target~=nil and Q1RDY==1 and W1RDY==0 and E1RDY==0 and RRDY==0 then xQ = true
			end
		end
	if QRWE or QRW or QRE or QR or QWE or QE or xE or xQ then Ziel = target
	elseif WE or WQRE or WE or WQ or WQE or WQR then  Ziel = target2
	end
	
--[[QRWE]]	if QRWE and Ziel~=nil then
				if		ls==nil  then
					UseDFGBFT()
					Qspell()
				elseif 	ls=='Q1' then Q2spell()
				elseif 	ls=='Q2' then Wspell()
				elseif 	ls=='W1' then Espell()
				elseif	ls=='E1' or (ls=='W1' and CreepBlock(Ziel.x,Ziel.y,Ziel.z)==1) then QRWE = false
				end
--[[QRE]]	elseif QRE and Ziel~=nil then
				if		ls==nil  then
					UseDFGBFT()
					Qspell()
				elseif ls=='Q1' then Q2spell()
				elseif ls=='Q2' then Espell()
				elseif	ls=='E1' or (ls=='Q2' and CreepBlock(Ziel.x,Ziel.y,Ziel.z)==1) then QRE = false
				end
--[[QRW]]	elseif QRW and Ziel~=nil then
				if		ls==nil  then
					UseDFGBFT()
					Qspell()
				elseif 	ls=='Q1' then Q2spell()
				elseif 	ls=='Q2' then Wspell()
				elseif 	ls=='W1' then QRW = false
				end
--[[QR]]	elseif QR and Ziel~=nil then
				if		ls==nil  then
					UseDFGBFT()
					Qspell()
				elseif 	ls=='Q1' then Q2spell()
				elseif 	ls=='Q2' then QR = false
				end
--[[QWE]]	elseif QWE and Ziel~=nil then
				if		ls==nil  then Qspell()
				elseif 	ls=='Q1' then Wspell()
				elseif 	ls=='W1' then Espell()
				elseif	ls=='E1' or (ls=='W1' and CreepBlock(Ziel.x,Ziel.y,Ziel.z)==1) then QWE = false
				end
--[[QE]]	elseif QE and Ziel~=nil then
				if		ls==nil  then Qspell()
				elseif 	ls=='Q1' then Espell()
				elseif 	ls=='E1' then QE = false
				end
--[[WE]]	elseif WE and Ziel~=nil then
				if		ls==nil  then Wspell()
				elseif 	ls=='W1' then Espell()
				elseif	ls=='E1' or (ls=='W1' and CreepBlock(Ziel.x,Ziel.y,Ziel.z)==1) then WE = false
				end
--[[WQRE]]	elseif WQRE and Ziel~=nil then
				if		ls==nil  then WLspell()
				elseif 	ls=='W1' then 
					UseDFGBFT()
					Qspell()
				elseif 	ls=='Q1' then Q2spell()
				elseif 	ls=='Q2' then Espell()
				elseif	ls=='E1' or (ls=='Q2' and CreepBlock(Ziel.x,Ziel.y,Ziel.z)==1) then WQRE = false
				end
--[[WQR]]	elseif WQR and Ziel~=nil then
				if		ls==nil  then WLspell()
				elseif 	ls=='W1' then 
					UseDFGBFT()
					Qspell()
				elseif 	ls=='Q1' then Q2spell()
				elseif 	ls=='Q2' then WQR = false
				end
--[[WQE]]	elseif WQE and Ziel~=nil then
				if		ls==nil  then WLspell()
				elseif 	ls=='W1' then 
					UseDFGBFT()
					Qspell()
				elseif 	ls=='Q1' then Espell()
				elseif	ls=='E1' or (ls=='Q1' and CreepBlock(Ziel.x,Ziel.y,Ziel.z)==1) then WQE = false
				end
--[[WQ]]	elseif WQ and Ziel~=nil then
				if		ls==nil  then WLspell()
				elseif 	ls=='W1' then Qspell()
				elseif 	ls=='Q1' then WQ = false
				end
--[[WE]]	elseif WE and Ziel~=nil then
				if		ls==nil  then WLspell()
				elseif 	ls=='W1' then Espell()
				elseif	ls=='E1' or (ls=='W1' and CreepBlock(Ziel.x,Ziel.y,Ziel.z)==1) then WE = false
				end
--[[xE]]	elseif xE and Ziel~=nil then
				if		ls==nil  then Espell()
				elseif	ls=='E1' then xE = false
				end
--[[xQ]]	elseif xQ and Ziel~=nil then
				if		ls==nil  then Qspell()
				elseif	ls=='Q1' then xQ = false 
				end
			end
	if QRWE==false and QRW==false and QRE==false and QR==false and QWE==false and QE==false and WE==false and WQRE==false and WE==false and WQ==false and WQE==false and WQR==false and xE==false and xQ==false then
		ls = nil
		Ziel = nil
	end
	if LBSettings.MouseMove then MoveMouse() end
end
	
function Qspell()
	if Ziel~=nil then SpellTarget(Q,Q1RDY,myHero,Ziel,700) end
end

function Q2spell()
	if Ziel~=nil then SpellTarget(R,Q2RDY,myHero,Ziel,700) end
end
			
function Wspell()
	run_many_reset(1,Wspell2)
end

function Wspell2()
	if Ziel~=nil then SpellXYZ(W,W1RDY,myHero,Ziel,800,Ziel.x,Ziel.z) end
	if W1RDY==1 then
		return true
	end
end

function WLspell()
	if Ziel~=nil then run_many_reset(1,WLspell2) end
end

function WLspell2()
	if Ziel~=nil then SpellXYZ(W,W1RDY,myHero,Ziel,1150,Ziel.x,Ziel.z) end
	if W1RDY==1 then
		return true
	end
end

function Espell()
	if Ziel~=nil then
		if GetDistance(myHero,Ziel)<300 and GetDistance(myHero,Ziel)>50 and CreepBlock(Ziel.x,Ziel.y,Ziel.z) == 0 then
			SpellXYZ(E,E1RDY,myHero,Ziel,300,Ziel.x,Ziel.z)
		elseif GetDistance(myHero,Ziel)>300 and GetDistance(myHero,Ziel)<850 then
			SpellPredSimple(E,E1RDY,myHero,Ziel,850,1.6,(157293/10000),1)
		end
	end
end

-- This is a small variant of the same function at the bottom of the script.
-- Should work too, is cleaner, but not tested yet.
function UseDFGBFT()
	if BFT == 1 and Ziel~=nil then UseItemOnTarget(3128, Ziel)
	elseif DFG == 1 and Ziel~=nil then UseItemOnTarget(3188, Ziel)
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

function LB_Items()
	if CfgItems.Zhonyas_Hourglass_ONOFF then
		if myHero.health < myHero.maxHealth*(CfgItems.Zhonyas_Hourglass_Value / 100) then
			GetInventorySlot(3157)
			UseItemOnTarget(3157,myHero)
		end
	end
	if CfgItems.Wooglets_Witchcap_ONOFF then
		GetInventorySlot(3090)
		UseItemOnTarget(3090,myHero)
	end
	if CfgItems.Seraphs_Embrace_ONOFF then
		GetInventorySlot(3040)
		UseItemOnTarget(3040,myHero)
	end
end

SetTimerCallback('Main')