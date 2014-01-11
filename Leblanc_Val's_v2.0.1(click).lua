require 'Utils'
require 'winapi'
require 'SKeys'
require 'spell_damage'
require 'runrunrun'
require 'vals_lib'
local uiconfig = require 'uiconfig'
local Q,W,E,R = 'Q','W','E','R'
local version = '2.0.1 (Click)'
local MarkTimer = nil
local ls = nil
local timer = 0
local ShowRange = 2500
local jumpspotrange = 50
local jumpmouserange = 75
local Erange = 800
local Edelay = 1.5
local Espeed = 15
local Eradius = 75

	LBConf, menu = uiconfig.add_menu('LeBlanc Hotkeys', 250)
	menu.keydown('Qkey', 'Q-Key', Keys.X)
	menu.keydown('Ekey', 'E-Key', Keys.Y)
	menu.keytoggle('Combo', 'Combo', Keys.Z, false)
	menu.keydown('Harass', 'Harass', Keys.T)
	menu.permashow('Qkey')
	menu.permashow('Ekey')
	menu.permashow('Combo')
	menu.permashow('Harass')
	
	LBSettings, menu = uiconfig.add_menu('LeBlanc Settings', 250)
	menu.checkbutton('AWB', 'Auto-W-Back', false)
	menu.checkbutton('KSNotes', 'KSNotes', true)
	menu.checkbutton('ReturnPad', 'Draw ReturnPad', true)
	menu.checkbutton('jumphelper', 'JumpHelper', false)
	menu.checkbutton('DrawCircles', 'DrawCircles', true)


function Main()
	if IsLolActive() then
		target = GetWeakEnemy('MAGIC',700)
		targetE = GetWeakEnemy('MAGIC',800)
		target2 = GetWeakEnemy('MAGIC',1250)
		SetVariables()
		GetSpells()
		CheckSpells()
		GetMark()
		Jump()
		QspellOnce()
		EspellOnce()
		ComboAlwaysOn()
		if LBConf.Combo then Once_Combo() end
		if Ziel==nil then LBConf.Combo=false end
		if LBConf.Harass then Harass() end
		if LBSettings.KSNotes then KSNotifications() end
		if LBSettings.ReturnPad then ReturnPad() end	
	end
end

function Once_Combo()
	run_many_reset(1, Combo)
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
	if target~=nil and Q1RDY==1 and W1RDY==1 and ls==nil then
		QWW = true
		Ziel = target
	end
	if QWW and ls==nil then SpellTarget(Q,Q1RDY,myHero,Ziel,700)
	elseif 	ls=='Q1' then run_every(1, Wspell)
	elseif 	ls=='W1' then SpellXYZ(W,W2RDY,myHero,myHero,1,myHero.x,myHero.z)
	elseif 	ls=='W2' then
		ls = nil
		Ziel = nil
		QWW = false
	end
	if LBSettings.MouseMove then MoveMouse() end
end

function SetVariables()
	if Ziel==nil or(Ziel~=nil and Ziel.dead==1) or myHero.dead==1 or (LBConf.Combo == false and LBConf.Harass == false) or (timer~=0 and GetTickCount()-timer>800) then
		QRWE,QRE,QRW,QR,QWE,QE,QW,WQRE,WQR,WQE,xE,xQ,QWW = false,false,false,false,false,false,false,false,false,false,false,false,false
		ls,Ziel = nil,nil
		timer = 0
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

function Wspell()
	if Ziel~=nil then
		if GetDistance(Ziel)<800 then
			EnemyPos = Vector(Ziel.x, Ziel.y, Ziel.z)
			HeroPos = Vector(myHero.x, myHero.y, myHero.z)
			WPos = EnemyPos+(EnemyPos-HeroPos)*(-200/GetDistance(EnemyPos, HeroPos))
			SpellXYZ(W,W1RDY,myHero,Ziel,800,WPos.x,WPos.z)
		else
			SpellXYZ(W,W1RDY,myHero,Ziel,800,Ziel.x,Ziel.z)
		end
	end
end

function WLspell()
	if Ziel~=nil then SpellXYZ(W,W1RDY,myHero,Ziel,1300,Ziel.x,Ziel.z) end
end

function CheckSpells()
	if QRWE or QRW or QRE or QR or QWE or QE or QW or xE or xQ or WQRE or WQE or WQR or QWW then
		for i = 1, objManager:GetMaxObjects(), 1 do
			obj = objManager:GetObject(i)
			if obj~=nil then
				if obj.charName == 'leBlanc_ChaosOrb_mis.troy' and GetDistance(obj) < 200 and Q1 == true then
					ls = 'Q1'
					timer = GetTickCount()
				end
				if obj.charName == 'leBlanc_ChaosOrb_mis_ult.troy' and GetDistance(obj) < 200 and Q2 == true then
					ls = 'Q2'
					timer = GetTickCount()
				end
				if obj.charName == 'leBlanc_slide_impact_self.troy' and GetDistance(obj) < 100 and W1 == true then
					ls = 'W1'
					timer = GetTickCount()
				end
				if obj.charName == 'Leblanc_displacement_blink_return_trigger.troy' and GetDistance(obj) < 100 and W2 == true then
					ls = 'W2'
					timer = GetTickCount()
				end
			end
		end
		for i = 1, objManager:GetMaxDelObjects(), 1 do
			local object = {objManager:GetDelObject(i)}
			local ret={}
			ret.index=object[1]
			ret.name=object[2]
			ret.charName=object[3]
			ret.x=object[4]
			ret.y=object[5]
			ret.z=object[6]
			if ret~=nil then
				if ret.charName == 'leBlanc_shackle_mis.troy' and GetDistance(ret) < 950 and E1 == true then
					ls = 'E1'
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
				Q1 = true
			else
				Q1 = false	
			end
			if spell.name == 'LeblancChaosOrbM' then
				Q2 = true
			else
				Q2 = false	
			end
			if spell.name == 'LeblancSlide' then
				W1 = true
			else
				W1 = false	
			end
			if spell.name == 'leblancslidereturn' then
				W2 = true
			else
				W2 = false	
			end
			if spell.name == 'LeblancSoulShackle' then
				E1 = true
			else
				E1 = false	
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
		if Q1RDY==1 then
			CustomCircle(700,1,2,myHero)
		end
		if Q1RDY==1 and W1RDY==1 then
			CustomCircle(1250,1,5,myHero)
		end
		if target2~=nil and target==nil and GetDistance(target2)<1250 then
			CustomCircle(100,4,5,target2)
		elseif target~=nil and GetDistance(target)<700 then
			CustomCircle(100,4,2,target)
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
--[[QRWE]]	if target~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==1 and RRDY==1 and Wall==0 and Block==0 then QRWE = true
--[[QRE]]	elseif target~=nil and Q1RDY==1 and W1RDY==0 and E1RDY==1 and RRDY==1 and Block==0 then QRE = true
--[[QRW]]	elseif target~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==0 and RRDY==1 and Wall==0 then QRW = true
--[[QR]]	elseif target~=nil 	and Q1RDY==1 and W1RDY==0 and E1RDY==0 and RRDY==1 then QR = true
--[[QWE]]	elseif target~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==1 and RRDY==0 and Wall==0 then QWE = true
--[[QE]]	elseif target~=nil and Q1RDY==1 and W1RDY==0 and E1RDY==1 and RRDY==0 and Block==0 then QE = true
--[[QW]]	elseif target~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==0 and RRDY==0 and  Wall==0 then QW = true
--[[WQRE]]	elseif target2~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==1 and RRDY==1 and Wall==0 and Block==0 then WQRE = true
--[[WQR]]	elseif target2~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==0 and RRDY==1 and Wall==0 then WQR = true
--[[WQE]]	elseif target2~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==1 and RRDY==0 and Wall==0 and Block==0 then WQE = true
--[[E]]		elseif targetE~=nil and Q1RDY==0 and Q2RDY==0 and W1RDY==0 and E1RDY==1 and Block==0 then xE = true
--[[Q]]		elseif target~=nil and Q1RDY==1 and W1RDY==0 and E1RDY==0 and RRDY==0 then xQ = true
			end
		end
	if QRWE or QRW or QRE or QR or QWE or QE or QW or xE or xQ then Ziel = target
	elseif WQRE or WQE or WQR then  Ziel = target2
	end
	
	if Ziel==nil and ls==nil and timer==0 then
		return true
	end
end

function ComboAlwaysOn()
--[[QRWE]]	if QRWE and Ziel~=nil then
				if		ls==nil  then
					UseDFGBFT()
					SpellTarget(Q,Q1RDY,myHero,Ziel,700)
				elseif 	ls=='Q1' then SpellTarget(R,Q2RDY,myHero,Ziel,700)
				elseif 	ls=='Q2' then run_every(1, Wspell)
				elseif 	ls=='W1' then Espell()
				elseif	ls=='E1' and LBSettings.AWB==false then QRWE = false
				elseif	ls=='E1' and LBSettings.AWB==true then SpellXYZ(W,W2RDY,myHero,myHero,1,myHero.x,myHero.z)
				elseif	ls=='W2' and LBSettings.AWB==true then QRWE = false
				end
--[[QRE]]	elseif QRE and Ziel~=nil then
				if		ls==nil  then
					UseDFGBFT()
					SpellTarget(Q,Q1RDY,myHero,Ziel,700)
				elseif ls=='Q1' then SpellTarget(R,Q2RDY,myHero,Ziel,700)
				elseif ls=='Q2' then Espell()
				elseif	ls=='E1' then QRE = false
				end
--[[QRW]]	elseif QRW and Ziel~=nil then
				if		ls==nil  then
					UseDFGBFT()
					SpellTarget(Q,Q1RDY,myHero,Ziel,700)
				elseif 	ls=='Q1' then SpellTarget(R,Q2RDY,myHero,Ziel,700)
				elseif 	ls=='Q2' then run_every(1, Wspell)
				elseif 	ls=='W1' and LBSettings.AWB==false then QRW = false
				elseif 	ls=='W1' and LBSettings.AWB==true then SpellXYZ(W,W2RDY,myHero,myHero,1,myHero.x,myHero.z)
				elseif	ls=='W2' and LBSettings.AWB==true then QWE = false
				end
--[[QR]]	elseif QR and Ziel~=nil then
				if		ls==nil  then
					UseDFGBFT()
					SpellTarget(Q,Q1RDY,myHero,Ziel,700)
				elseif 	ls=='Q1' then SpellTarget(R,Q2RDY,myHero,Ziel,700)
				elseif 	ls=='Q2' then QR = false
				end
--[[QWE]]	elseif QWE and Ziel~=nil then
				if		ls==nil  then SpellTarget(Q,Q1RDY,myHero,Ziel,700)
				elseif 	ls=='Q1' then run_every(1, Wspell)
				elseif 	ls=='W1' then Espell()
				elseif	ls=='E1' and LBSettings.AWB==false then QWE = false
				elseif	ls=='E1' and LBSettings.AWB==true then SpellXYZ(W,W2RDY,myHero,myHero,1,myHero.x,myHero.z)
				elseif	ls=='W2' and LBSettings.AWB==true then QWE = false
				end
--[[QE]]	elseif QE and Ziel~=nil then
				if		ls==nil  then SpellTarget(Q,Q1RDY,myHero,Ziel,700)
				elseif 	ls=='Q1' then Espell()
				elseif 	ls=='E1' then QE = false
				end
--[[QW]]	elseif QW and Ziel~=nil then
				if		ls==nil  then SpellTarget(Q,Q1RDY,myHero,Ziel,700)
				elseif 	ls=='Q1' then run_every(1, Wspell)
				elseif	ls=='W1' and LBSettings.AWB==false then QW = false
				elseif	ls=='W1' and LBSettings.AWB==true then SpellXYZ(W,W2RDY,myHero,myHero,1,myHero.x,myHero.z)
				elseif	ls=='W2' and LBSettings.AWB==true then QW = false
				end
--[[WQRE]]	elseif WQRE and Ziel~=nil then
				if		ls==nil  then run_every(1, WLspell)
				elseif 	ls=='W1' then 
					UseDFGBFT()
					SpellTarget(Q,Q1RDY,myHero,Ziel,700)
				elseif 	ls=='Q1' then SpellTarget(R,Q2RDY,myHero,Ziel,700)
				elseif 	ls=='Q2' then Espell()
				elseif	ls=='E1' then WQRE = false
				end
--[[WQR]]	elseif WQR and Ziel~=nil then
				if		ls==nil  then run_every(1, WLspell)
				elseif 	ls=='W1' then 
					UseDFGBFT()
					SpellTarget(Q,Q1RDY,myHero,Ziel,700)
				elseif 	ls=='Q1' then SpellTarget(R,Q2RDY,myHero,Ziel,700)
				elseif 	ls=='Q2' then WQR = false
				end
--[[WQE]]	elseif WQE and Ziel~=nil then
				if		ls==nil  then run_every(1, WLspell)
				elseif 	ls=='W1' then 
					UseDFGBFT()
					SpellTarget(Q,Q1RDY,myHero,Ziel,700)
				elseif 	ls=='Q1' then Espell()
				elseif	ls=='E1' then WQE = false
				end
--[[xE]]	elseif xE and Ziel~=nil then
				if		ls==nil  then Espell()
				elseif	ls=='E1' then xE = false
				end
--[[xQ]]	elseif xQ and Ziel~=nil then
				if		ls==nil  then SpellTarget(Q,Q1RDY,myHero,Ziel,700)
				elseif	ls=='Q1' then xQ = false 
				end
			end
	if QRWE==false and QRE==false and QRW==false and QR==false and QWE==false and QE==false and QW==false and WQRE==false and WQR==false and WQE==false and xE==false and xQ==false then
		ls = nil
		Ziel = nil
	end
	if Ziel~=nil then
		MoveTarget(Ziel)
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

SetTimerCallback('Main')