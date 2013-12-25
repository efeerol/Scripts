require 'Utils'
require 'winapi'
require 'SKeys'
require 'spell_damage'
require 'vals_lib'
require 'runrunrun'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local Q,W,E,R = 'Q','W','E','R'
local version = '1.9.3 Hit'
local MarkTimer = nil
local target,target2
local ls = nil
local timer,timer2 = 0,0
local Ziel = nil
local QRWE,QRW,QRE,QR,QWE,QE,WE,WQRE,WE,WQ,WQE,WQR,xE,xQ,QWW = false,false,false,false,false,false,false,false,false,false,false,false,false,false,false

function Main()

	if IsLolActive() and IsChatOpen() == 0 then
		GetSpells()
		SetVariables()
		GetMark()
		if LBKeyConf.val==false then LB_Items() end
		QspellOnce()
		EspellOnce()
		Mastery_Damage()
		BaseCheck()
		IsWall2()
		ComboAlwaysOn()
		if LBKeyConf.Combo then Once_Combo() end
		if Ziel==nil then LBKeyConf.Combo=false end
		if LBKeyConf.val==false and LBKeyConf.Harass then Harass() end
		if LBKeyConf.val==false and LBKeyConf.Farm and not InBase then Farm() end
		if LBKeyConf.KSNotes then KSNotifications() end
		if LBSettings.ReturnPad then ReturnPad() end
	end
end

	LBKeyConf, menu = uiconfig.add_menu('LeBlanc Hotkeys', 250)
	menu.keydown('Qkey', 'Q-Key', Keys.X)
	menu.keydown('Ekey', 'E-Key', Keys.Y)
	menu.keytoggle('Combo', 'Combo', Keys.Z, false)
	menu.keydown('Harass', 'Harass', Keys.T)
	menu.keydown('Farm', 'Farm', Keys.LButton)
	menu.keytoggle('KSNotes', 'KS Notes', Keys.F1, false)
	menu.checkbutton('val', 'Dont touch this button!', false)
	menu.checkbutton('switch', 'Dont touch', false)
	menu.permashow('Qkey')
	menu.permashow('Ekey')
	menu.permashow('Combo')
	menu.permashow('Harass')
	menu.permashow('Farm')
	menu.permashow('KSNotes')
	
	LBSettings, menu = uiconfig.add_menu('LeBlanc Settings', 250)
	menu.checkbutton('ReturnPad', 'Draw ReturnPad', true)
	menu.slider('MinimapPos', 'Minimap Position', 1, 2, 2, {"Left","Right"})
	
	CfgMasteries, menu = uiconfig.add_menu('Mastery Settings', 250)
	menu.slider('Butcher_Mastery', 'Butcher', 0, 2, 2, nil, true)
	menu.slider('Havoc_Mastery', 'Havoc', 0, 3, 3, nil, true)
	menu.slider('Brute_Force_Mastery', 'Brute Force', 0, 2, 0, nil, true)
	menu.checkbutton('Spellsword_Mastery', 'Spellsword', true)
	menu.checkbutton('Executioner_Mastery', 'Executioner', true)
	
	CfgItems, menu = uiconfig.add_menu('LB Items', 250)
	menu.checkbutton('Zhonyas_Hourglass_ONOFF', 'Zhonyas Hourglass', true)
	menu.checkbutton('Wooglets_Witchcap_ONOFF', 'Wooglets Witchcap', true)
	menu.checkbutton('Seraphs_Embrace_ONOFF', 'Seraphs Embrace', true)
	menu.slider('Zhonyas_Hourglass_Value', 'Zhonya Hourglass Value', 0, 100, 15, nil, true)
	menu.slider('Wooglets_Witchcap_Value', 'Wooglets Witchcap Value', 0, 100, 15, nil, true)
	menu.slider('Seraphs_Embrace_Value', 'Seraphs Embrace Value', 0, 100, 15, nil, true)

function Harass()
	local targeth = GetWeakEnemy('MAGIC',800)
	if QRWE==false and QRW==false and QRE==false and QR==false and QWE==false and QE==false and WE==false and WQRE==false and WE==false and WQ==false and WQE==false and WQR==false and xE==false and xQ==false and QWW==false then
		if targeth~=nil and Q1RDY==1 and W1RDY==1 and W2RDY==0 and ls== nil then
			QWW = true
			Ziel = targeth
		end
	end
	if QWW then
		if ls==nil then
			Qspell()
		elseif 	ls=='Q1' then Wspell()
		elseif 	ls=='W1' then CastSpellXYZ('W',myHero.x,myHero.y,myHero.z)
		elseif 	ls=='W2' then 
			ls = nil
			Ziel = nil
			QWW = false
		end
	end
	MoveToMouse()
end

function OnCreateObj(obj)
	if obj~=nil then
		if obj.charName == 'leBlanc_slide_impact_self.troy' then
			jump = true
		end
	end
end

function Once_Combo()
	run_many_reset(1, Combo)
end
			
function QspellOnce()
	run_many_reset(1, QSpell)
end

function QSpell()
	if LBKeyConf.Qkey == true then
		local targetQ = GetWeakEnemy('MAGIC',700)
		if Q1RDY==1 then
			if MarkedEnemy~=nil then
				if GetDistance(myHero,MarkedEnemy)<700 then
					CastSpellTarget('Q',MarkedEnemy)
				end
			elseif targetQ~=nil then
				if GetDistance(myHero,targetQ)<700 then
					CastSpellTarget('Q',targetQ)
				end
			end
		elseif Q2RDY==1 then
			if MarkedEnemy~=nil then
				if GetDistance(myHero,MarkedEnemy)<700 then
					CastSpellTarget('R',MarkedEnemy)
				end
			elseif targetQ~=nil then
				if GetDistance(myHero,targetQ)<700 then
					CastSpellTarget('R',targetQ)
				end
			end
		end
	end
	if LBKeyConf.Qkey == false then
		return true
	end
end

function EspellOnce()
	run_many_reset(1, ESpell)
end	
	
function ESpell()
	if LBKeyConf.Ekey == true then
		local targetE = GetWeakEnemy('MAGIC',950)
		if E1RDY==1 then
			if MarkedEnemy~=nil then
				if GetDistance(myHero,MarkedEnemy)<850 then
					if CreepBlock(myHero.x,myHero.y,myHero.z,MarkedEnemy.x,MarkedEnemy.y,MarkedEnemy.z) == 0 then
						CastSpellXYZ('E',GetFireahead(MarkedEnemy,1.6,(157293/10000)))
					end
				end
			elseif targetE~=nil then
				if GetDistance(myHero,targetE)<850 then
					if CreepBlock(myHero.x,myHero.y,myHero.z,targetE.x,targetE.y,targetE.z) == 0 then
						CastSpellXYZ('E',GetFireahead(targetE,1.6,(157293/10000)))
					end
				end
			end
		elseif E2RDY==1 then
			if MarkedEnemy~=nil then 
				if GetDistance(myHero,MarkedEnemy)<850 then
					if CreepBlock(myHero.x,myHero.y,myHero.z,MarkedEnemy.x,MarkedEnemy.y,MarkedEnemy.z) == 0 then
						CastSpellXYZ('R',GetFireahead(MarkedEnemy,1.6,(157293/10000)))
					end
				end
			elseif targetE~=nil then
				if GetDistance(myHero,targetE)<850 then
					if CreepBlock(myHero.x,myHero.y,myHero.z,targetE.x,targetE.y,targetE.z) == 0 then
						CastSpellXYZ('R',GetFireahead(targetE,1.6,(157293/10000)))
					end
				end
			end
		end
	end
end

function SetVariables()
	target = GetWeakEnemy('MAGIC',700)
	target2 = GetWeakEnemy('MAGIC',1150)
	
	if (Q1RDY==0 and W1RDY==0 and E1RDY==0 and RRDY==0) or myHero.dead==1 or (timer~=0 and GetTickCount()-timer>1500) then 
		ls = nil
		Ziel = nil
		timer = 0
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
		QWW = false
		jump = false
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
	if myHero.SpellNameQ == 'LeblancChaosOrb' and myHero.SpellLevelQ >= 1 and myHero.SpellTimeQ >= 1 and myHero.mana >= 40+(myHero.SpellLevelQ*10) then
	Q1RDY = 1
	else Q1RDY = 0
	end
	if myHero.SpellNameR == 'LeblancChaosOrbM' and myHero.SpellLevelR >= 1 and myHero.SpellTimeR >= 1 then
	Q2RDY = 1
	else Q2RDY = 0
	end
	if myHero.SpellNameW == 'LeblancSlide' and myHero.SpellLevelW >= 1 and myHero.SpellTimeW >= 1 and myHero.mana >= 70+(myHero.SpellLevelW*10) then
	W1RDY = 1
	else W1RDY = 0
	end
	if myHero.SpellNameW == 'leblancslidereturn' and myHero.SpellLevelW >= 1 and myHero.SpellTimeW >= 1 then
	W2RDY = 1
	else W2RDY = 0
	end
	if myHero.SpellNameE == 'LeblancSoulShackle' and myHero.SpellLevelE >= 1 and myHero.SpellTimeE >= 1 and myHero.mana >= 80 then
	E1RDY = 1
	else E1RDY = 0
	end
	if myHero.SpellNameR == 'LeblancSoulShackleM' and myHero.SpellLevelR >= 1 and myHero.SpellTimeR >= 1 then
	E2RDY = 1
	else E2RDY = 0
	end
	if myHero.SpellLevelR >= 1 and myHero.SpellTimeR >= 1 then
	RRDY = 1
	else RRDY = 0
	end
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
	if	   Q1RDY==1			 	and W1RDY==1 and W2RDY==0 and E1RDY==1 				and RRDY==1 	and ls==nil		then DrawTextObject('BURST',myHero,Color.Yellow)
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

function UseDFGBFT()
	if GetMap() == 0 or GetMap() == 1 then -- Deathfire Grasp
		if GetInventorySlot(3128)==1 then
			if myHero.SpellTime1 >= 1 then
				if Ziel~=nil then UseItemOnTarget(3128, Ziel) end
			end
		elseif GetInventorySlot(3128)==2 then
			if myHero.SpellTime2 >= 1 then
				if Ziel~=nil then UseItemOnTarget(3128, Ziel) end
			end
		elseif GetInventorySlot(3128)==3 then
			if myHero.SpellTime3 >= 1 then
				if Ziel~=nil then UseItemOnTarget(3128, Ziel) end
			end
		elseif GetInventorySlot(3128)==4 then
			if myHero.SpellTime4 >= 1 then				
				if Ziel~=nil then UseItemOnTarget(3128, Ziel) end
			end
		elseif GetInventorySlot(3128)==5 then
			if myHero.SpellTime5 >= 1 then
				if Ziel~=nil then UseItemOnTarget(3128, Ziel) end
			end
		elseif GetInventorySlot(3128)==6 then
			if myHero.SpellTime6 >= 1 then	
				if Ziel~=nil then UseItemOnTarget(3128, Ziel) end
			end
		end
	elseif GetMap() == 2 or GetMap() == 3 then -- DFG
		if GetInventorySlot(3188)==1 then
			if myHero.SpellTime1 >= 1 then
				if Ziel~=nil then UseItemOnTarget(3188, Ziel) end
			end
		elseif GetInventorySlot(3188)==2 then
			if myHero.SpellTime2 >= 1 then
				if Ziel~=nil then UseItemOnTarget(3188, Ziel) end
			end
		elseif GetInventorySlot(3188)==3 then
			if myHero.SpellTime3 >= 1 then
				if Ziel~=nil then UseItemOnTarget(3188, Ziel) end
			end
		elseif GetInventorySlot(3188)==4 then
			if myHero.SpellTime4 >= 1 then				
				if Ziel~=nil then UseItemOnTarget(3188, Ziel) end
			end
		elseif GetInventorySlot(3188)==5 then
			if myHero.SpellTime5 >= 1 then
				if Ziel~=nil then UseItemOnTarget(3188, Ziel) end
			end
		elseif GetInventorySlot(3188)==6 then
			if myHero.SpellTime6 >= 1 then	
				if Ziel~=nil then UseItemOnTarget(3188, Ziel) end
			end
		end
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
			local Qmark = Qdam
			local Wdam = getDmg("W",enemy,myHero)
			local Edam = getDmg("E",enemy,myHero)
			local Emark = Edam
			local QMdam = getDmg("R",enemy,myHero,1)
			local QMmark = QMdam
			local WMdam = getDmg("R",enemy,myHero,2)
			local EMdam = getDmg("R",enemy,myHero,3)
			local EMmark = EMdam
			local DFGdam = getDmg("DFG",enemy,myHero)*DFG
			local BFTdam = getDmg("BLACKFIRE",enemy,myHero)*BFT
			
			-- WQ
			if enemy.health<Qdam and Q1RDY==1 and W1RDY==1 and GetDistance(enemy)>700 then
				if Wall2 == 1 then
					DrawTextObject('WQ (Long) KILL',enemy,Color.Red)
				else
					DrawTextObject('WQ (Long) KILL',enemy,Color.Yellow)
				end
			-- WQE
			elseif enemy.health<Qdam+Qmark+Edam and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 and GetDistance(enemy)>700 then
				EnemyPos = Vector(enemy.x, enemy.y, enemy.z)
				HeroPos = Vector(myHero.x, myHero.y, myHero.z)
				WPos = EnemyPos+(EnemyPos-HeroPos)*(-600/GetDistance(EnemyPos, HeroPos))
				EPos = EnemyPos+(EnemyPos-HeroPos)*(-850/GetDistance(EnemyPos, HeroPos))
				if (GetDistance(myHero,enemy)<1200 and CreepBlock(WPos.x,WPos.y,WPos.z,enemy.x,enemy.y,enemy.z)==1) or (GetDistance(myHero,enemy)>1200 and CreepBlock(EPos.x,EPos.y,EPos.z,enemy.x,enemy.y,enemy.z)==1) or Wall2 == 1 then
					DrawTextObject('WQE (Long) KILL',enemy,Color.Red)
				else
					WPos = nil
					EPos = nil
					DrawTextObject('WQE (Long) KILL',enemy,Color.Yellow)
				end
			-- WQR
			elseif enemy.health<Qdam+Qmark+QMdam+QMmark and Q1RDY==1 and W1RDY==1 and W2RDY==0 and RRDY==1 and GetDistance(enemy)>700 then
				if Wall2 == 1 then
					DrawTextObject('WQR (Long) KILL',enemy,Color.Red)
				else
					DrawTextObject('WQR (Long) KILL',enemy,Color.Yellow)
				end
			-- WQRE
			elseif enemy.health<Qdam+Qmark+QMdam+QMmark+Edam and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 and RRDY==1 and GetDistance(enemy)>700 then
				EnemyPos = Vector(enemy.x, enemy.y, enemy.z)
				HeroPos = Vector(myHero.x, myHero.y, myHero.z)
				WPos = EnemyPos+(EnemyPos-HeroPos)*(-600/GetDistance(EnemyPos, HeroPos))
				EPos = EnemyPos+(EnemyPos-HeroPos)*(-850/GetDistance(EnemyPos, HeroPos))
				if (GetDistance(myHero,enemy)<1200 and CreepBlock(WPos.x,WPos.y,WPos.z,enemy.x,enemy.y,enemy.z)==1) or (GetDistance(myHero,enemy)>1200 and CreepBlock(EPos.x,EPos.y,EPos.z,enemy.x,enemy.y,enemy.z)==1) or Wall2 == 1 then
					DrawTextObject('WQRE (Long) KILL',enemy,Color.Red)
				else
					DrawTextObject('WQRE (Long) KILL',enemy,Color.Yellow)
				end
			-- IWQR
			elseif (enemy.health<((Qdam+Qmark+QMdam+QMmark)+((Qdam+Qmark+QMdam+QMmark)/5)+BFTdam)*BFT or enemy.health<((Qdam+Qmark+QMdam+QMmark)+((Qdam+Qmark+QMdam+QMmark)/5)+DFGdam)*DFG) and Q1RDY==1 and W1RDY==1 and W2RDY==0 and RRDY==1 and GetDistance(enemy)>700 then
				if Wall2 == 1 then
					DrawTextObject('IWQR (Long) KILL',enemy,Color.Red)
				else
					DrawTextObject('IWQR (Long) KILL',enemy,Color.Yellow)
				end
			-- IWQRE
			elseif (enemy.health<((Qdam+Qmark+QMdam+QMmark+Edam)+((Qdam+Qmark+QMdam+QMmark+Edam)/5)+BFTdam)*BFT or enemy.health<((Qdam+Qmark+QMdam+QMmark+Edam)+((Qdam+Qmark+QMdam+QMmark+Edam)/5)+DFGdam)*DFG) and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 and RRDY==1 and GetDistance(enemy)>700 then
				EnemyPos = Vector(enemy.x, enemy.y, enemy.z)
				HeroPos = Vector(myHero.x, myHero.y, myHero.z)
				WPos = EnemyPos+(EnemyPos-HeroPos)*(-600/GetDistance(EnemyPos, HeroPos))
				EPos = EnemyPos+(EnemyPos-HeroPos)*(-850/GetDistance(EnemyPos, HeroPos))
				if (GetDistance(myHero,enemy)<1200 and CreepBlock(WPos.x,WPos.y,WPos.z,enemy.x,enemy.y,enemy.z)==1) or (GetDistance(myHero,enemy)>1200 and CreepBlock(EPos.x,EPos.y,EPos.z,enemy.x,enemy.y,enemy.z)==1) then
					DrawTextObject('IWQRE (Long) KILL',enemy,Color.Red)
				else
					DrawTextObject('IWQRE (Long) KILL',enemy,Color.Yellow)
				end
			-- Q
			elseif enemy.health<Qdam and Q1RDY==1 then
				DrawTextObject('Q KILL',enemy,Color.Yellow)
			-- E
			elseif enemy.health<Edam and E1RDY==1 then
				DrawTextObject('E KILL',enemy,Color.Yellow)
			-- WE
			elseif enemy.health<Wdam+Edam and W1RDY==1 and W2RDY==0 and E1RDY==1 then
				EnemyPos = Vector(enemy.x, enemy.y, enemy.z)
				HeroPos = Vector(myHero.x, myHero.y, myHero.z)
				WPos = EnemyPos+(EnemyPos-HeroPos)*(-600/GetDistance(EnemyPos, HeroPos))
				EPos = EnemyPos+(EnemyPos-HeroPos)*(-850/GetDistance(EnemyPos, HeroPos))
				if (GetDistance(myHero,enemy)<1200 and CreepBlock(WPos.x,WPos.y,WPos.z,enemy.x,enemy.y,enemy.z)==1) or (GetDistance(myHero,enemy)>1200 and CreepBlock(EPos.x,EPos.y,EPos.z,enemy.x,enemy.y,enemy.z)==1) or Wall2 == 1 then
					DrawTextObject('WE (Long) KILL',enemy,Color.Red)
				else
					DrawTextObject('WE (Long) KILL',enemy,Color.Yellow)
				end
			-- QW
			elseif enemy.health<Qdam+Qmark+Wdam and Q1RDY==1 and W1RDY==1 and W2RDY==0 then
				if Wall2 == 1 then
					DrawTextObject('QW KILL',enemy,Color.Red)
				else
					DrawTextObject('QW KILL',enemy,Color.Yellow)
				end
			-- QE
			elseif enemy.health<Qdam+Qmark+Edam and Q1RDY==1 and E1RDY==1 then 
				DrawTextObject('QE KILL',enemy,Color.Yellow)
			-- QWE
			elseif enemy.health<Qdam+Qmark+Wdam+Edam and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 then
				EnemyPos = Vector(enemy.x, enemy.y, enemy.z)
				HeroPos = Vector(myHero.x, myHero.y, myHero.z)
				WPos = EnemyPos+(EnemyPos-HeroPos)*(-600/GetDistance(EnemyPos, HeroPos))
				if CreepBlock(WPos.x,WPos.y,WPos.z,enemy.x,enemy.y,enemy.z)==1 or Wall2 == 1 then
					DrawTextObject('QWE KILL',enemy,Color.Red)
				else
					DrawTextObject('QWE KILL',enemy,Color.Yellow)
				end
			-- QR
			elseif enemy.health<Qdam+Qmark+QMdam and Q1RDY==1 and RRDY==1 then
				DrawTextObject('QR KILL',enemy,Color.Yellow)
			-- QRE
			elseif enemy.health<Qdam+Qmark+QMdam+QMmark+Edam and Q1RDY==1 and E1RDY==1 and RRDY==1 then
				EnemyPos = Vector(enemy.x, enemy.y, enemy.z)
				HeroPos = Vector(myHero.x, myHero.y, myHero.z)
				WPos = EnemyPos+(EnemyPos-HeroPos)*(-600/GetDistance(EnemyPos, HeroPos))
				if CreepBlock(WPos.x,WPos.y,WPos.z,enemy.x,enemy.y,enemy.z)==1 then
					DrawTextObject('QRE KILL',enemy,Color.Red)
				else
					DrawTextObject('QRE KILL',enemy,Color.Yellow)
				end
			-- QRW
			elseif enemy.health<Qdam+Qmark+QMdam+QMmark+Wdam and Q1RDY==1 and W1RDY==1 and W2RDY==0 and RRDY==1 then
				DrawTextObject('QRW KILL',enemy,Color.Yellow)
			-- QRWE
			elseif enemy.health<Qdam+Qmark+QMdam+QMmark+Wdam+Edam and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 and RRDY==1 then
				EnemyPos = Vector(enemy.x, enemy.y, enemy.z)
				HeroPos = Vector(myHero.x, myHero.y, myHero.z)
				WPos = EnemyPos+(EnemyPos-HeroPos)*(-600/GetDistance(EnemyPos, HeroPos))
				if CreepBlock(WPos.x,WPos.y,WPos.z,enemy.x,enemy.y,enemy.z)==1 then
					DrawTextObject('QRWE KILL',enemy,Color.Red)
				else
					DrawTextObject('QRWE KILL',enemy,Color.Yellow)
				end
			-- WWQ
			elseif enemy.health<Qdam and GetDistance(enemy)>1200 and Q1RDY==1 and W1RDY==1 and W2RDY==0 and RRDY==1 then
				DrawTextObject('WWQ (Long) KILL',enemy,Color.Yellow)
			-- IQR
			elseif (enemy.health<((Qdam+Qmark+QMdam)+((Qdam+Qmark+QMdam)/5)+BFTdam)*BFT or enemy.health<((Qdam+Qmark+QMdam)+((Qdam+Qmark+QMdam)/5)+DFGdam)*DFG) and Q1RDY==1 and RRDY==1 then
				DrawTextObject('IQR KILL',enemy,Color.Yellow)
			-- IQRE
			elseif (enemy.health<((Qdam+Qmark+QMdam+QMmark+Edam)+((Qdam+Qmark+QMdam+QMmark+Edam)/5)+BFTdam)*BFT or enemy.health<((Qdam+Qmark+QMdam+QMmark+Edam)+((Qdam+Qmark+QMdam+QMmark+Edam)/5)+DFGdam)*DFG) and Q1RDY==1 and E1RDY==1 and RRDY==1 then
				EnemyPos = Vector(enemy.x, enemy.y, enemy.z)
				HeroPos = Vector(myHero.x, myHero.y, myHero.z)
				WPos = EnemyPos+(EnemyPos-HeroPos)*(-600/GetDistance(EnemyPos, HeroPos))
				if CreepBlock(WPos.x,WPos.y,WPos.z,enemy.x,enemy.y,enemy.z)==1 then
					DrawTextObject('IQRE KILL',enemy,Color.Red)
				else
					DrawTextObject('IQRE KILL',enemy,Color.Yellow)
				end
			-- IQRW
			elseif (enemy.health<((Qdam+Qmark+QMdam+QMmark+Wdam)+((Qdam+Qmark+QMdam+QMmark+Wdam)/5)+BFTdam)*BFT or enemy.health<((Qdam+Qmark+QMdam+QMmark+Wdam)+((Qdam+Qmark+QMdam+QMmark+Wdam)/5)+DFGdam)*DFG) and Q1RDY==1 and W1RDY==1 and W2RDY==0 and RRDY==1 then
				DrawTextObject('IQRW KILL',enemy,Color.Yellow)
			-- IQRWE
			elseif (enemy.health<((Qdam+Qmark+QMdam+QMmark+Wdam+Edam)+((Qdam+Qmark+QMdam+QMmark+Wdam+Edam)/5)+BFTdam)*BFT or enemy.health<((Qdam+Qmark+QMdam+QMmark+Wdam+Edam)+((Qdam+Qmark+QMdam+QMmark+Wdam+Edam)/5)+DFGdam)*DFG) and Q1RDY==1 and W1RDY==1 and W2RDY==0 and E1RDY==1 and RRDY==1 then
				EnemyPos = Vector(enemy.x, enemy.y, enemy.z)
				HeroPos = Vector(myHero.x, myHero.y, myHero.z)
				WPos = EnemyPos+(EnemyPos-HeroPos)*(-600/GetDistance(EnemyPos, HeroPos))
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
	if QRWE==false and QRW==false and QRE==false and QR==false and QWE==false and QE==false and WE==false and WQRE==false and WE==false and WQ==false and WQE==false and WQR==false and xE==false and xQ==false and QWW==false then

		-- QRWE
		if target~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==1 and RRDY==1 and ls==nil then
			QRWE = true
			timer = GetTickCount()
			Ziel = target
		-- QRE
		elseif target~=nil and Q1RDY==1 and W1RDY==0 and E1RDY==1 and RRDY==1 and ls==nil then
			QRE = true
			timer = GetTickCount()
			Ziel = target
		-- QRW
		elseif target~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==0 and RRDY==1 and ls==nil then
			QRW = true
			timer = GetTickCount()
			Ziel = target
		-- QR
		elseif target~=nil 	and Q1RDY==1 and W1RDY==0 and E1RDY==0 and RRDY==1 and ls==nil then
			QR = true
			timer = GetTickCount()
			Ziel = target
		-- QWE
		elseif target~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==1 and RRDY==0 and ls==nil then
			QWE = true
			timer = GetTickCount()
			Ziel = target
		-- QE
		elseif target~=nil and Q1RDY==1 and W1RDY==0 and E1RDY==1 and RRDY==0 and ls==nilm and CreepBlock(target.x,target.y,target.z) == 0 then
			QE = true
			timer = GetTickCount()
			Ziel = target
		-- WE
		elseif target~=nil and Q1RDY==0 and W1RDY==1 and E1RDY==1 and RRDY==0 and ls==nil then
			WE = true
			timer = GetTickCount()
			Ziel = target
		-- WQRE
		elseif target2~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==1 and RRDY==1 and ls==nil and Wall2 == 0 then
			WQRE = true
			timer = GetTickCount()
			Ziel = target2
		-- WQR
		elseif target2~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==0 and RRDY==1 and ls==nil and Wall2 == 0 then 
			WQR = true
			timer = GetTickCount()
			Ziel = target2
		-- WQE
		elseif target2~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==1 and RRDY==0 and ls==nil and Wall2 == 0 then
			WQE = true
			timer = GetTickCount()
			Ziel = target2
		-- WQ
		elseif target2~=nil and Q1RDY==1 and W1RDY==1 and E1RDY==0 and RRDY==0 and ls==nil and Wall2 == 0 then 
			WQ = true
			timer = GetTickCount()
			Ziel = target2
		-- WE
		elseif target2~=nil and Q1RDY==0 and W1RDY==1 and E1RDY==1 and ls==nil and Wall2 == 0 then 
			WE = true
			timer = GetTickCount()
			Ziel = target2
		-- E
		elseif target~=nil and Q1RDY==0 and Q2RDY==0 and W1RDY==0 and E1RDY==1 and ls==nil and CreepBlock(target.x,target.y,target.z) == 0 then
			xE = true
			timer = GetTickCount()
			Ziel = target
		-- Q
		elseif target~=nil and Q1RDY==1 and W1RDY==0 and E1RDY==0 and RRDY==0 and ls==nil then
			xQ = true
			timer = GetTickCount()
			Ziel = target
		end
	end
	if Ziel==nil and ls==nil and timer==0 then
		return true
	end
end

function ComboAlwaysOn()
	if QRWE and Ziel~=nil then
		if		ls==nil  then
			UseDFGBFT()
			Qspell()
		elseif 	ls=='Q1' then Q2spell()
		elseif 	ls=='Q2' then Wspell()
		elseif 	ls=='W1' then Espell()
		elseif	ls=='E1' or (ls=='W1' and CreepBlock(Ziel.x,Ziel.y,Ziel.z)==1) then
			ls = nil
			Ziel = nil
			timer = 0
			QRWE = false
		end
	end
	
	if QRE and Ziel~=nil then
		if		ls==nil  then
			UseDFGBFT()
			Qspell()
		elseif ls=='Q1' then Q2spell()
		elseif ls=='Q2' then Espell()
		elseif	ls=='E1' or (ls=='Q2' and CreepBlock(Ziel.x,Ziel.y,Ziel.z)==1) then
			ls = nil
			Ziel = nil
			timer = 0
			QRE = false
		end
	end
		
	if QRW and Ziel~=nil then
		if		ls==nil  then
			UseDFGBFT()
			Qspell()
		elseif 	ls=='Q1' then Q2spell()
		elseif 	ls=='Q2' then Wspell()
		elseif 	ls=='W1' then
			ls = nil
			Ziel = nil
			timer = 0
			QRW = false
		end
	end
	
	if QR and Ziel~=nil then
		if		ls==nil  then
			UseDFGBFT()
			Qspell()
		elseif 	ls=='Q1' then Q2spell()
		elseif 	ls=='Q2' then
			ls = nil
			Ziel = nil
			timer = 0
			QR = false
		end
	end
	
	if QWE and Ziel~=nil then
		if		ls==nil  then Qspell()
		elseif 	ls=='Q1' then Wspell()
		elseif 	ls=='W1' then Espell()
		elseif	ls=='E1' or (ls=='W1' and CreepBlock(Ziel.x,Ziel.y,Ziel.z)==1) then
			ls = nil
			Ziel = nil
			timer = 0
			QWE = false
		end
	end
	
	if QE and Ziel~=nil then
		if		ls==nil  then Qspell()
		elseif 	ls=='Q1' then Espell()
		elseif 	ls=='E1' then
			ls = nil
			Ziel = nil
			timer = 0
			QE = false
		end
	end
	
	if WE and Ziel~=nil then
		if		ls==nil  then Wspell()
		elseif 	ls=='W1' then Espell()
		elseif	ls=='E1' or (ls=='W1' and CreepBlock(Ziel.x,Ziel.y,Ziel.z)==1) then
			ls = nil
			Ziel = nil
			timer = 0
			WE = false
		end
	end
	
	if WQRE and Ziel~=nil then
		if		ls==nil  then WLspell()
		elseif 	ls=='W1' then 
			UseDFGBFT()
			Qspell()
		elseif 	ls=='Q1' then Q2spell()
		elseif 	ls=='Q2' then Espell()
		elseif	ls=='E1' or (ls=='Q2' and CreepBlock(Ziel.x,Ziel.y,Ziel.z)==1) then
			ls = nil
			Ziel = nil
			timer = 0
			WQRE = false
		end
	end
	
	if WQR and Ziel~=nil then
		if		ls==nil  then WLspell()
		elseif 	ls=='W1' then 
			UseDFGBFT()
			Qspell()
		elseif 	ls=='Q1' then Q2spell()
		elseif 	ls=='Q2' then
			ls = nil
			Ziel = nil
			timer = 0
			WQR = false
		end
	end
	
	if WQE and Ziel~=nil then
		if		ls==nil  then WLspell()
		elseif 	ls=='W1' then 
			UseDFGBFT()
			Qspell()
		elseif 	ls=='Q1' then Espell()
		elseif	ls=='E1' or (ls=='Q1' and CreepBlock(Ziel.x,Ziel.y,Ziel.z)==1) then
			ls = nil
			Ziel = nil
			timer = 0
			WQE = false
		end
	end
	
	if WQ and Ziel~=nil then
		if		ls==nil  then WLspell()
		elseif 	ls=='W1' then Qspell()
		elseif 	ls=='Q1' then
			ls = nil
			Ziel = nil
			timer = 0
			WQ = false
		end
	end
	
	if WE and Ziel~=nil then
		if		ls==nil  then WLspell()
		elseif 	ls=='W1' then Espell()
		elseif	ls=='E1' or (ls=='W1' and CreepBlock(Ziel.x,Ziel.y,Ziel.z)==1) then
			ls = nil
			Ziel = nil
			timer = 0
			WE = false
		end
	end
	
	if xE and Ziel~=nil then
		if		ls==nil  then Espell()
		elseif	ls=='E1' then
			ls = nil
			Ziel = nil
			timer = 0
			xE = false
		end
	end
	
	if xQ and Ziel~=nil then
		if		ls==nil  then Qspell()
		elseif	ls=='Q1' then
			ls = nil
			Ziel = nil
			timer = 0
			xQ = false
		end
	end
	
	if Ziel~=nil then 
		MoveToXYZ(Ziel.x,Ziel.y,Ziel.z)
	end
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
	if Ziel~=nil and jump then
		if GetDistance(myHero,Ziel)<300 and GetDistance(myHero,Ziel)>50 and CreepBlock(Ziel.x,Ziel.y,Ziel.z) == 0 then
			SpellXYZ(E,E1RDY,myHero,Ziel,300,Ziel.x,Ziel.z)
		elseif GetDistance(myHero,Ziel)>300 and GetDistance(myHero,Ziel)<775 then
			SpellPredSimple(E,E1RDY,myHero,Ziel,775,1.6,(157293/10000),1)
		end
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

----------------------------------------------------------------------------------------------------------------------

local ARAM100X = 935
local ARAM100Z = 1065
local ARAM200X = 11850
local ARAM200Z = 11626
local ARAMdist = 1750

local SR100X = 35
local SR100Z = 275
local SR200X = 13950
local SR200Z = 14200
local SRdist = 1900

local DOM100X = 580
local DOM100Z = 4125
local DOM200X = 13295
local DOM200Z = 4125
local DOMdist = 750

local TT100X = 1060
local TT100Z = 7300
local TT200X = 14355
local TT200Z = 7295
local TTdist = 2050

local MapLX = 0/1920*GetScreenX()
local MapLZ = 1080/1920*GetScreenY()
local MapRX = 1920/1920*GetScreenX()
local MapRZ = 1080/1920*GetScreenY()
local Mapdist = 500

function BaseCheck()
	if LBSettings.MinimapPos == 1 then
		MAPX = MapLX
		MapZ = MapLZ
	elseif  LBSettings.MinimapPos == 2 then
		MAPX = MapRX
		MapZ = MapRZ
	end
	if myHero.team == 100 then
		if GetMap() == 0 then
			XX = ARAM100X
			ZZ = ARAM100Z
			Bdist = ARAMdist
		elseif GetMap() == 1 then
			XX = SR100X
			ZZ = SR100Z
			Bdist = SRdist
		elseif GetMap() == 2 then
			XX = DOM100X
			ZZ = DOM100Z
			Bdist = DOMdist
		elseif GetMap() == 3 then
			XX = TT100X
			ZZ = TT100Z
			Bdist = TTdist
		end
	elseif myHero.team == 200 then
		if GetMap() == 0 then
			XX = ARAM200X
			ZZ = ARAM200Z
			Bdist = ARAMdist
		elseif GetMap() == 1 then
			XX = SR200X
			ZZ = SR200Z
			Bdist = SRdist
		elseif GetMap() == 2 then
			XX = DOM200X
			ZZ = DOM200Z
			Bdist = DOMdist
		elseif GetMap() == 3 then
			XX = TT200X
			ZZ = TT200Z
			Bdist = TTdist
		end
	end

	if distXYZ(XX,ZZ,myHero.x,myHero.z)<Bdist or distXYZ(MAPX,MapZ,GetCursorX(),GetCursorY())<Mapdist then
		InBase = true
	end
	if distXYZ(XX,ZZ,myHero.x,myHero.z)>Bdist and distXYZ(MAPX,MapZ,GetCursorX(),GetCursorY())>Mapdist then
		InBase = false
	end
end

local HavocDamage = 0
local ExecutionerDamage = 0
local True_Attack_Damage_Against_Minions = 0
local Range = myHero.range + GetDistance(GetMinBBox(myHero))
local SORT_CUSTOM = function(a, b) return a.maxHealth and b.maxHealth and a.maxHealth < b.maxHealth end
local Target, M_Target
local TEAM
if myHero.team == 100 then
	TEAM = "Blue"
else
	TEAM = "Red"
end
local MinionInfo = { }
MinionInfo[TEAM.."_Minion_Basic"] 		= 	{ aaDelay = 400, projSpeed = 0		}
MinionInfo[TEAM.."_Minion_Caster"] 		=	{ aaDelay = 484, projSpeed = 0.68	}
MinionInfo[TEAM.."_Minion_Wizard"]		=	{ aaDelay = 484, projSpeed = 0.68	}
MinionInfo[TEAM.."_Minion_MechCannon"] 	=	{ aaDelay = 365, projSpeed = 1.18	}
local Minions = { }
local aaDelay = 0
local aaPos = {x = 0, z = 0}
local Ping = 0
local IncomingDamage = { }
local AnimationBeginTimer = 0
local AnimationSpeedTimer = 0.1 * (1 / myHero.attackspeed)
local TimeToAA = os.clock()

function GetAAData()
    return {Leblanc = { projSpeed = 1.7, aaParticles = {"leBlanc_basicAttack_cas", "leBlancBasicAttack_mis"}, aaSpellName = {"leblancbasicattack"}, startAttackSpeed = "0.625" },}
end

function OnProcessSpell(unit, spell)
	if unit ~= nil and GetDistance(myHero, unit) < 1000 then
		for i, Minion in pairs(Minions) do
			if Minion ~= nil then
				if MinionInfo[unit.charName] ~= nil then
					local m_aaDelay = MinionInfo[unit.charName].aaDelay
					local m_projSpeed = MinionInfo[unit.charName].projSpeed
					
					if spell.target == Minion then
						IncomingDamage[unit.name] = { Source = unit, Target = Minion, Damage = getDmg("AD", Minion, unit), Start = GetTickCount(), aaPos = { x = unit.x, z = unit.z }, aaDelay = m_aaDelay, projSpeed = m_projSpeed }
					end
				end
			end
		end
	end
	if unit.charName == myHero.charName then
		for i, aaSpellName in pairs(GetAAData()[myHero.name].aaSpellName) do
			if spell.name == aaSpellName then
				AnimationBeginTimer = os.clock()
				TimeToAA = os.clock() + (1 / myHero.attackspeed) - 0.35 * (1 / myHero.attackspeed)
			end
		end
	end
	if unit ~= nil and spell ~= nil and unit.charName == myHero.charName then
		if LBKeyConf.Combo or  LBKeyConf.Harass or QRWE or QRW or QRE or QR or QWE or QE or WE or WQRE or WE or WQ or WQE or WQR or xE or xQ or QWW then
			if spell.name == 'LeblancChaosOrb' then ls = 'Q1' end
			if spell.name == 'LeblancChaosOrbM' then ls = 'Q2' end
			if spell.name == 'LeblancSlide' then ls = 'W1' end
			if spell.name == 'leblancslidereturn' then ls = 'W2' end
			if spell.name == 'LeblancSoulShackle' then ls = 'E1' end
			if spell.name == 'LeblancSoulShackleM' then ls = 'E2' end
		end
	end
end


function Mastery_Damage()
	local Mast_ButcherDMG = 0
	local Mast_BruteForceDMG = 0
	local Mast_SpellswordDMG = 0
	if CfgMasteries.Butcher_Mastery > 0 then
		Mast_ButcherDMG = CfgMasteries.Butcher_Mastery
	end
	if CfgMasteries.Brute_Force_Mastery then
		if CfgMasteries.Brute_Force_Mastery == 1 then
			Mast_BruteForceDMG = 1.5
		end
		if CfgMasteries.Brute_Force_Mastery == 2 then
			Mast_BruteForceDMG = 3
		end
	end
	if CfgMasteries.Spellsword_Mastery then
		Mast_SpellswordDMG = myHero.ap * .05
	end
	if CfgMasteries.Havoc_Mastery then
		if CfgMasteries.Havoc_Mastery == 1 then
			HavocDamage = 0.0067
		end
		if CfgMasteries.Havoc_Mastery == 2 then
			HavocDamage = 0.0133
		end
		if CfgMasteries.Havoc_Mastery == 3 then
			HavocDamage = 0.02
		end
	end
	if CfgMasteries.Executioner_Mastery then
		ExecutionerDamage = .05
	end
	True_Attack_Damage_Against_Minions = (myHero.baseDamage + myHero.addDamage + Mast_BruteForceDMG + Mast_SpellswordDMG)+((myHero.baseDamage + myHero.addDamage + Mast_BruteForceDMG + Mast_SpellswordDMG)*(HavocDamage + ExecutionerDamage))
end

function Farm()
		if IsKeyDown(Keys.ControlKey)==0 and IsKeyDown(Keys.ShiftKey)==0 and IsKeyDown(Keys.A)==0 and IsKeyDown(Keys.A)==0 and IsKeyDown(Keys.Alt)==0 then
		Minions = GetEnemyMinions(SORT_CUSTOM)
		AnimationSpeedTimer = 0.1 * (1 / myHero.attackspeed)
		
		for i, Minion in pairs(Minions) do
			if Minion ~= nil then
				local PredictedDamage = 0
				local aaTime = Ping + aaDelay + ( GetDistance(myHero, Minion) / GetAAData()[myHero.name].projSpeed )
				
				for k, DMG in pairs(IncomingDamage) do
					if DMG ~= nil then
						if (DMG.Source == nil or DMG.Source.dead or DMG.Target == nil or DMG.Target.dead) or (DMG.Source.x ~= DMG.aaPos.x or DMG.Source.z ~= DMG.aaPos.z) then
							IncomingDamage[k] = nil
						elseif Minion == DMG.Target then
							DMG.aaTime = (DMG.projSpeed == 0 and (DMG.aaDelay) or (DMG.aaDelay + GetDistance(DMG.Source, Minion) / DMG.projSpeed))
							if GetTickCount() >= (DMG.Start + DMG.aaTime) then
								IncomingDamage[k] = nil
							elseif GetTickCount() + aaTime > (DMG.Start + DMG.aaTime) then
								PredictedDamage = PredictedDamage + DMG.Damage
							end
						end
					end
				end
					
				if Minion.dead == 0 and Minion.health - PredictedDamage <= True_Attack_Damage_Against_Minions and Minion.health - PredictedDamage > 0 and GetDistance(Minion, myHero) < Range then
					if os.clock() > TimeToAA then AttackTarget(Minion)
						CustomCircle(100, 1, 2, Minion)
					end
				end
			end
		end
		if os.clock() > (AnimationBeginTimer + AnimationSpeedTimer) then MoveToMouse() end
		CustomCircle(Range, 1, 4, myHero)
	end
end

function LB_Items()
	if CfgItems.Zhonyas_Hourglass_ONOFF then
		if myHero.health < myHero.maxHealth*(CfgItems.Zhonyas_Hourglass_Value / 100) then
			useZhonyas()
		end
	end
	if CfgItems.Wooglets_Witchcap_ONOFF then
		if myHero.health < myHero.maxHealth*(CfgItems.Wooglets_Witchcap_Value / 100) then
			useWoogletsWitchcap()
		end
	end
	if CfgItems.Seraphs_Embrace_ONOFF then
		if myHero.health <= (CfgItems.Seraphs_Embrace_Value / 100) then
			useSeraphsEmbrace()
		end
	end
end
function useZhonyas()
	GetInventorySlot(3157)
	UseItemOnTarget(3157,myHero)
end
function useWoogletsWitchcap()
	GetInventorySlot(3090)
	UseItemOnTarget(3090,myHero)
end
function useSeraphsEmbrace()
	GetInventorySlot(3040)
	UseItemOnTarget(3040,myHero)
end

SetTimerCallback('Main')