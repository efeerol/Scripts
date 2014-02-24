require 'Utils'
require 'winapi'
require 'SKeys'
require 'spell_damage'
require 'vals_lib'
require 'runrunrun'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local Q,W,E,R = 'Q','W','E','R'
local version = '1.0'
----------------------------
local skillingOrder = {SR = {Q,E,W,Q,E,R,E,Q,Q,E,R,E,Q,W,W,R,W,W}, DOM = {Q,W,E,W,W,R,W,Q,W,Q,R,Q,Q,E,E,R,E,E},}
----------------------------
local wUsedAt,vUsedAt = 0,0
local timer = os.clock()
local bluePill = nil
local metakey = SKeys.Control
local attempts = 0
local lastAttempt = 0
----------------------------
local toggle_timer = os.clock()
local cc,locus_timer,dodgetimer = 0,0,0
local skillshotArray = {}
local KSK = {}
local Minions = {}
local MinionsAA = {}
local MinionsQ = {}
local MinionsW = {}
local MinionsE = {}
local SORT_CUSTOM = function(a, b) return a.maxHealth and b.maxHealth and a.maxHealth < b.maxHealth end
---------- CONFIG ----------
local Harass_Mode = 1 -- Harassmode on gamestart [1=Q, 2=QW, 3=QE, 4=QEW, 5=IQEW
local Combo_Mode = 2 -- Combomode on gamestart [1=QEWR, 2=QEWR]
local DrawX,DrawY = 70,170 -- X/Y-oordinates of the mode text
local Qrange = 675
local Wrange = 350
local Erange = 675
local Rrange = 550
----------------------------

	KeyCFG, menu = uiconfig.add_menu('1.) Hotkey Config', 250)
	menu.keydown('Combo', 'Combo', Keys.X)
	menu.keydown('Harass', 'Harass', Keys.Y)
	menu.keydown('LaneClear', 'LaneClear', Keys.Z)

	MainCFG, menu = uiconfig.add_menu('2.) Main Config', 250)
	menu.keydown('HarassMode', 'Change Harass Mode', Keys.F1)
	menu.keydown('ComboMode', 'Change Combo Mode', Keys.F2)
	menu.checkbutton('Killsteal', 'Killsteal', true)
	menu.checkbutton('KSNotes', 'Draw KS notes', true)
	menu.checkbutton('MouseMove', 'MouseMove', true)
	menu.checkbutton('StunDraw', 'Draw HardCC', true)
	menu.checkbutton('AutoLevel', 'AutoLevel', false)
	menu.checkbutton('AutoZonyas', 'AutoZonyas', true)
	menu.slider('Zhonyas_Hourglass_Value', 'Zhonya Hourglass Value', 0, 100, 15, nil, true)
	
	DodgeCFG, menu = uiconfig.add_menu('3.) DodgeSkillshot Config', 250)
	menu.checkbutton('DrawSkillShots', 'Draw Skillshots', true)
	menu.checkbutton('DodgeSkillShots', 'Dodge Skillshots', true)
	menu.checkbutton('DodgeSkillShotsAOE', 'Dodge Skillshots for AOE', true)
	menu.slider('BlockSettings', 'Block user input', 1, 2, 1, {'FixBlock','NoBlock'})
	menu.slider('BlockSettingsAOE', 'Block user input for AOE', 1, 2, 2, {'FixBlock','NoBlock'})
	menu.slider('BlockTime', 'Block imput time', 0, 1000, 750)
	
	CfgPotions, menu = uiconfig.add_menu('4.) Potions', 250)
	menu.checkbutton('RedElixir', 'Master Switch: Potions', true)
	menu.checkbutton('Health_Potion_ONOFF', 'Health Potions', true)
	menu.checkbutton('Chrystalline_Flask_ONOFF', 'Chrystalline Flask', true)
	menu.checkbutton('Elixir_of_Fortitude_ONOFF', 'Elixir of Fortitude', true)
	menu.checkbutton('Biscuit_ONOFF', 'Biscuit', true)
	menu.slider('Health_Potion_Value', 'Health Potion Value', 0, 100, 75, nil, true)
	menu.slider('Chrystalline_Flask_Value', 'Chrystalline Flask Value', 0, 100, 75, nil, true)
	menu.slider('Elixir_of_Fortitude_Value', 'Elixir of Fortitude Value', 0, 100, 30, nil, true)
	menu.slider('Biscuit_Value', 'Biscuit Value', 0, 100, 60, nil, true)

function Main()
	if IsLolActive() then
		send.tick()
		GetCD()
		SetVariables()
		CheckItemCD()
		CustomCircle(Erange,1,2,myHero)
		HarassModes()
		ComboModes()
		Skillshots()
		Killsteal()
		Items()
		if KeyCFG.LaneClear then LaneClear() end
		if MainCFG.StunDraw then StunDraw() end
		if MainCFG.AutoLevel then AutoLevel() end
		if CfgPotions.RedElixir then RedElixir() end
	end
end

function SetVariables()
	if GetTickCount()>locus_timer+500 then locus = false end
	if GetTickCount()-dodgetimer>DodgeCFG.BlockTime then dodgetimer = 0 end

	for i = 1, objManager:GetMaxNewObjects(), 1 do
		local obj = objManager:GetNewObject(i)
		if obj.charName~=nil and GetDistance(obj)<350 and obj.charName=='katarina_deathLotus_mis.troy' then
			locus = true
			locus_timer = GetTickCount()
		end
	end
	
	if BFT == 1 or DFG == 1 or BC == 1 or HG == 1 then IRDY = 1
	else IRDY = 0 end
	if (myHero.SummonerD == 'SummonerDot' and myHero.SpellTimeD>1) or (myHero.SummonerF == 'SummonerDot' and myHero.SpellTimeF>1) then IGN = 1
	else IGN = 0 end
	
	target = GetWeakEnemy('MAGIC',700)
	targetaa = GetWeakEnemy('MAGIC',myHero.range+(GetDistance(GetMinBBox(myHero))))
	Minions = GetEnemyMinions(SORT_CUSTOM)
	MinionsAA = GetEnemyMinions(SORT_CUSTOM)
	MinionsQ = GetEnemyMinions(SORT_CUSTOM)
	MinionsW = GetEnemyMinions(SORT_CUSTOM)
	MinionsE = GetEnemyMinions(SORT_CUSTOM)
end 	
		
function HarassModes()
	DrawText('Harass Mode:',DrawX,DrawY-10,Color.White)
	if (MainCFG.HarassMode and os.clock() - toggle_timer>.15) then
		toggle_timer = os.clock()
		Harass_Mode = ((Harass_Mode+1)%6)
	end
	if (Harass_Mode == 1) then
		DrawText('Q',DrawX,DrawY,Color.White)
	elseif (Harass_Mode == 2) then
		DrawText('Q-W',DrawX,DrawY,Color.White)
	elseif (Harass_Mode == 3) then
		DrawText('Q-E',DrawX,DrawY,Color.White)
	elseif (Harass_Mode == 4) then
		DrawText('Q-E-W',DrawX,DrawY,Color.White)
	elseif (Harass_Mode == 5) then
		DrawText('I-Q-E-W',DrawX,DrawY,Color.White)
	else
		DrawText("OFF",DrawX,DrawY,Color.White)
		return
	end

	if KeyCFG.Harass and locus==false then
		if Harass_Mode == 1 then Seq('_Q','_A',nil,nil,nil,nil,target)
		elseif Harass_Mode == 2 then Seq('_Q','_W','_A',nil,nil,nil,target)
		elseif Harass_Mode == 3 then Seq('_Q','_E','_A',nil,nil,nil,target)
		elseif Harass_Mode == 4 then Seq('_Q','_E','_W','_A',nil,nil,target)
		elseif Harass_Mode == 5 then Seq('_I','_Q','_E','_W','_A',nil,target)
		end
		Move()
	end
end

function ComboModes()
	DrawText('Combo Mode:',DrawX,DrawY+20,Color.White)
	if (MainCFG.ComboMode and os.clock() - toggle_timer>.15) then
		toggle_timer = os.clock()
		Combo_Mode = ((Combo_Mode+1)%3)
	end
	if (Combo_Mode == 1) then
		DrawText('Q-E-W-R',DrawX,DrawY+30,Color.White)
	elseif (Combo_Mode == 2) then
		DrawText('I-Q-E-W-R',DrawX,DrawY+30,Color.White)
	else
		DrawText("OFF",DrawX,DrawY+30,Color.White)
		return
	end

	if KeyCFG.Combo and locus==false then
		if Combo_Mode == 1 then Seq('_Q','_E','_W','_R','_A',nil,target)
		elseif Combo_Mode == 2 then Seq('_I','_Q','_E','_W','_R','_A',target)
		end
		Move()
	end
end

function LaneClear()
	for i, minion in pairs(Minions) do
		if minion~=nil then
			CustomCircle(75,1,2,minion)
			Seq('_Q','_E','_W',nil,nil,nil,minion)
		end
	end
	Move()
end

function Qspell(target)
	if locus==false then SpellTarget(Q,QRDY,myHero,target,Qrange) end
end

function Wspell(target)
	if locus==false then SpellXYZ(W,WRDY,myHero,target,Wrange,myHero.x,myHero.z) end
end

function Espell(target)
	if locus==false then SpellTarget(E,ERDY,myHero,target,Erange) end
end

function Rspell(target)
    if RRDY==1 then
        if QRDY+WRDY+ERDY==0 then
            CastSpellTarget("R",target)
            locus = true
        end
    end
if target==nil or GetDistance(target)>Rrange then
	locus = false
end
end

function RspellKS(target)
    if RRDY==1 then
		CastSpellTarget("R",target)
		locus = true
    end
if target==nil or GetDistance(target)>Rrange  then
	locus = false
end
end

function Ispell(target)
	if locus==false and QRDY*WRDY*ERDY==1 then
		if BC == 1 and target~=nil then UseItemOnTarget(3144, target)
		elseif HG == 1 and target~=nil then UseItemOnTarget(3146, target)
		elseif BFT == 1 and target~=nil and GetDistance(target)<Erange then UseItemOnTarget(3188, target)
		elseif DFG == 1 and target~=nil and GetDistance(target)<Erange then UseItemOnTarget(3128, target)
		end
	end
end

function Attack(target)
	if locus==false and targetaa~=nil and IsBuffed(target,'katarina_daggered') or IsBuffed(target,'katarina_xmas_daggered.troy') then
		AttackTarget(target)
	end
end

function Move()
	if locus==false and dodgetimer==0 and MainCFG.MouseMove then MoveToMouse() end
end

function Killsteal()
	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if (enemy~=nil and enemy.team~=myHero.team and enemy.visible==1 and enemy.invulnerable==0 and enemy.dead==0) and locus==false then
			local xQ = (35+(myHero.SpellLevelQ*25)+(myHero.ap*.45))*QRDY
			local xW = (15+(myHero.SpellLevelW*35)+(myHero.ap*.25)+(myHero.addDamage*.6))*WRDY
			local xE = (35+(myHero.SpellLevelE*25)+(myHero.ap*.4))*ERDY
			local xR = (225+(myHero.SpellLevelR*175)+(myHero.ap*2.5)+(myHero.addDamage*3.75))*RRDY
			local xDFG = (enemy.maxHealth*.15)*DFG
			local xBFT = (enemy.maxHealth*.2)*BFT
			local xBC = 100*BC
			local xHG = (150+(myHero.ap*.4))*HG
			local xIGN = (50+(myHero.selflevel*20))*IGN
			local effhealth = (enemy.health-xIGN)*(1+(((enemy.magicArmor*myHero.magicPenPercent)-myHero.magicPen)/100))
			
			KSK[1]   = {range=Wrange, A='_W', B=nil, C=nil, D=nil, E=nil, F=nil, dam=xW} --W
			KSK[2]   = {range=Wrange, A='_E', B=nil, C=nil, D=nil, E=nil, F=nil, dam=xE} --E
			KSK[3]   = {range=Qrange, A='_Q', B=nil, C=nil, D=nil, E=nil, F=nil, dam=xQ} --Q
			KSK[4]   = {range=Erange, A='_E', B='_W', C=nil, D=nil, E=nil, F=nil, dam=xE+xW} --EW
			KSK[5]   = {range=Wrange, A='_W', B='_Q', C=nil, D=nil, E=nil, F=nil, dam=xW+xQ} --WQ
			KSK[6]   = {range=Erange, A='_E', B='_Q', C=nil, D=nil, E=nil, F=nil, dam=xE+xQ} --EQ
			KSK[7]   = {range=Erange, A='_E', B='_W', C='_Q', D=nil, E=nil, F=nil, dam=xE+xW+xQ} --EWQ
			KSK[8]   = {range=Wrange, A='_BC', B='_W', C=nil, D=nil, E=nil, F=nil, dam=xW+xBC} --WBC
			KSK[9]   = {range=Erange, A='_BC', B='_E', C=nil, D=nil, E=nil, F=nil, dam=xE+xBC} --EBC
			KSK[10]  = {range=450, A='_BC', B='_Q', C=nil, D=nil, E=nil, F=nil, dam=xQ+xBC} --QBC
			KSK[11]  = {range=Erange, A='_E', B='_W', C='_BC', D=nil, E=nil, F=nil, dam=xE+xW+xBC} --EWBC
			KSK[12]  = {range=Wrange, A='_W', B='_BC', C='_Q', D=nil, E=nil, F=nil, dam=xW+xQ+xBC} --WQBC
			KSK[13]  = {range=Erange, A='_E', B='_BC', C='_Q', D=nil, E=nil, F=nil, dam=xE+xQ+xBC} --EQBC
			KSK[14]  = {range=Erange, A='_E', B='_W', C='_BC', D='_Q', E=nil, F=nil, dam=xE+xW+xQ+xBC} --EWQBC
			KSK[15]  = {range=Wrange, A='_W', B='_HG', C=nil, D=nil, E=nil, F=nil, dam=xW+xHG} --WHG
			KSK[16]  = {range=Erange, A='_E', B='_HG', C=nil, D=nil, E=nil, F=nil, dam=xE+xHG} --EHG
			KSK[17]  = {range=Qrange, A='_HG', B='_Q', C=nil, D=nil, E=nil, F=nil, dam=xQ+xHG} --QHG
			KSK[18]  = {range=Erange, A='_E', B='_W', C='_HG', D=nil, E=nil, F=nil, dam=xE+xW+xHG} --EWHG
			KSK[19]  = {range=Wrange, A='_W', B='_HG', C='_Q', D=nil, E=nil, F=nil, dam=xW+xQ+xHG} --WQHG
			KSK[20]  = {range=Erange, A='_E', B='_HG', C='_Q', D=nil, E=nil, F=nil, dam=xE+xQ+xHG} --EQHG
			KSK[21]  = {range=Erange, A='_E', B='_W', C='_HG', D='_Q', E=nil, F=nil, dam=xE+xW+xQ+xHG} --EWQHG
			KSK[22]  = {range=Wrange, A='_DFG', B='_E', C='_W', D=nil, E=nil, F=nil, dam=((xW*1.2)+xDFG)*DFG} --WDFG
			KSK[23]  = {range=Erange, A='_DFG', B='_E', C=nil, D=nil, E=nil, F=nil, dam=((xE*1.2)+xDFG)*DFG} --EDFG
			KSK[24]  = {range=Qrange, A='_DFG', B='_Q', C=nil, D=nil, E=nil, F=nil, dam=((xQ*1.2)+xDFG)*DFG} --QDFG
			KSK[25]  = {range=Erange, A='_DFG', B='_E', C='_W', D=nil, E=nil, F=nil, dam=((xE+xW*1.2)+xDFG)*DFG} --EWDFG
			KSK[26]  = {range=Wrange, A='_DFG', B='_W', C='_Q', D=nil, E=nil, F=nil, dam=((xW+xQ*1.2)+xDFG)*DFG} --WQDFG
			KSK[27]  = {range=Erange, A='_DFG', B='_E', C='_Q', D=nil, E=nil, F=nil, dam=((xE+xQ*1.2)+xDFG)*DFG} --EQDFG
			KSK[28]  = {range=Erange, A='_DFG', B='_E', C='_W', D='_Q', E=nil, F=nil, dam=((xE+xW+xQ*1.2)+xDFG)*DFG} --EWQDFG
			KSK[29]  = {range=Wrange, A='_BFT', B='_W', C=nil, D=nil, E=nil, F=nil, dam=((xW*1.2)+xBFT)*BFT} --WBFT
			KSK[30]  = {range=Erange, A='_BFT', B='_E', C=nil, D=nil, E=nil, F=nil, dam=((xE*1.2)+xBFT)*BFT} --EBFT
			KSK[31]  = {range=Qrange, A='_BFT', B='_Q', C=nil, D=nil, E=nil, F=nil, dam=((xQ*1.2)+xBFT)*BFT } --QBFT
			KSK[32]  = {range=Erange, A='_BFT', B='_E', C='_W', D=nil, E=nil, F=nil, dam=((xE+xW*1.2)+xBFT)} --EWBFT
			KSK[33]  = {range=Wrange, A='_BFT', B='_W', C='_Q', D=nil, E=nil, F=nil, dam=((xW+xQ*1.2)+xBFT)*BFT} --WQBFT
			KSK[34]  = {range=Erange, A='_BFT', B='_E', C='_Q', D=nil, E=nil, F=nil, dam=((xE+xQ*1.2)+xBFT)*BFT} --EQBFT
			KSK[35]  = {range=Erange, A='_BFT', B='_E', C='_W', D='_Q', E=nil, F=nil, dam=((xE+xW+xQ*1.2)+xBFT)*BFT} --EWQBFT
			KSK[36]  = {range=Wrange, A='_DFG', B='_W', C='_BC', D=nil, E=nil, F=nil, dam=((xW+xBC*1.2)+xDFG)*DFG} --WBCDFG
			KSK[37]  = {range=Erange, A='_DFG', B='_E', C='_BC', D=nil, E=nil, F=nil, dam=((xE+xBC*1.2)+xDFG)*DFG} --EBCDFG
			KSK[38]  = {range=450, A='_DFG', B='_BC', C='_Q', D=nil, E=nil, F=nil, dam=((xQ+xBC*1.2)+xDFG)*DFG} --QBCDFG
			KSK[39]  = {range=Erange, A='_DFG', B='_E', C='_W', D='_BC', E=nil, F=nil, dam=((xE+xW+xBC*1.2)+xDFG)*DFG} --EWBCDFG
			KSK[40]  = {range=Wrange, A='_DFG', B='_W', C='_BC', D='_Q', E=nil, F=nil, dam=((xW+xQ+xBC*1.2)+xDFG)*DFG} --WQBCDFG
			KSK[41]  = {range=Erange, A='_DFG', B='_E', C='_BC', D='_Q', E=nil, F=nil, dam=((xE+xQ+xBC*1.2)+xDFG)*DFG} --EQBCDFG
			KSK[42]  = {range=Erange, A='_DFG', B='_E', C='_W', D='_Q', E='_BC', F=nil, dam=((xE+xW+xQ+xBC*1.2)+xDFG)*DFG} --EWQBCDFG
			KSK[43]  = {range=Wrange, A='_BFT', B='_W', C='_BC', D=nil, E=nil, F=nil, dam=((xW+xBC*1.2)+xBFT)*BFT} --WBCBFT
			KSK[44]  = {range=Erange, A='_BFT', B='_E', C='_BC', D=nil, E=nil, F=nil, dam=((xE+xBC*1.2)+xBFT)*BFT} --EBCBFT
			KSK[45]  = {range=450, A='_BFT', B='_BC', C='_Q', D=nil, E=nil, F=nil, dam=((xQ+xBC*1.2)+xBFT)*BFT} --QBCBFT
			KSK[46]  = {range=Erange, A='_BFT', B='_E', C='_W', D='_BC', E=nil, F=nil, dam=((xE+xW+xBC*1.2)+xBFT)*BFT} --EWBCBFT
			KSK[47]  = {range=Wrange, A='_BFT', B='_W', C='_BC', D='_Q', E=nil, F=nil, dam=((xW+xQ+xBC*1.2)+xBFT)*BFT} --WQBCBFT
			KSK[48]  = {range=Erange, A='_BFT', B='_E', C='_BC', D='_Q', E=nil, F=nil, dam=((xE+xQ+xBC*1.2)+xBFT)*BFT} --EQBCBFT
			KSK[49]  = {range=Erange, A='_BFT', B='_E', C='_W', D='_BC', E='_Q', F=nil, dam=((xE+xW+xQ+xBC*1.2)+xBFT)*BFT} --EWQBCBFT
			KSK[50]  = {range=Wrange, A='_DFG', B='_W', C='_HG', D=nil, E=nil, F=nil, dam=((xW+xHG*1.2)+xDFG)*DFG} --WHGDFG
			KSK[51]  = {range=Erange, A='_DFG', B='_E', C='_HG', D=nil, E=nil, F=nil, dam=((xE+xHG*1.2)+xDFG)*DFG} --EHGDFG
			KSK[52]  = {range=450, A='_DFG', B='_HG', C='_Q', D=nil, E=nil, F=nil, dam=((xQ+xHG*1.2)+xDFG)*DFG} --QHGDFG
			KSK[53]  = {range=Erange, A='_DFG', B='_E', C='_W', D='_HG', E=nil, F=nil, dam=((xE+xW+xHG*1.2)+xDFG)*DFG} --EWHGDFG
			KSK[54]  = {range=Wrange, A='_DFG', B='_W', C='_HG', D='_Q', E=nil, F=nil, dam=((xW+xQ+xHG*1.2)+xDFG)*DFG} --WQHGDFG
			KSK[55]  = {range=Erange, A='_DFG', B='_E', C='_HG', D='_Q', E=nil, F=nil, dam=((xE+xQ+xHG*1.2)+xDFG)*DFG} --EQHGDFG
			KSK[56]  = {range=Erange, A='_DFG', B='_E', C='_W', D='_HG', E='_Q', F=nil, dam=((xE+xW+xQ+xHG*1.2)+xDFG)*DFG} --EWQHGDFG
			KSK[57]  = {range=Wrange, A='_BFT', B='_W', C='_HG', D=nil, E=nil, F=nil, dam=((xW+xHG*1.2)+xBFT)*BFT} --WHGBFT
			KSK[58]  = {range=Erange, A='_BFT', B='_E', C='_HG', D=nil, E=nil, F=nil, dam=((xE+xHG*1.2)+xBFT)*BFT} --EHGBFT
			KSK[59]  = {range=450, A='_BFT', B='_HG', C='_Q', D=nil, E=nil, F=nil, dam=((xQ+xHG*1.2)+xBFT)*BFT} --QHGBFT
			KSK[60]  = {range=Erange, A='_BFT', B='_E', C='_W', D='_HG', E=nil, F=nil, dam=((xE+xW+xHG*1.2)+xBFT)*BFT} --EWHGBFT
			KSK[61]  = {range=Wrange, A='_BFT', B='_W', C='_HG', D='_Q', E=nil, F=nil, dam=((xW+xQ+xHG*1.2)+xBFT)*BFT} --WQHGBFT
			KSK[62]  = {range=Erange, A='_BFT', B='_E', C='_HG', D='_Q', E=nil, F=nil, dam=((xE+xQ+xHG*1.2)+xBFT)*BFT} --EQHGBFT
			KSK[63]  = {range=Erange, A='_BFT', B='_E', C='_HG', D='_W', E='_Q', F=nil, dam=((xE+xW+xQ+xHG*1.2)+xBFT)*BFT} --EWQHGBFT
			KSK[64]  = {range=Wrange, A='_W', B='_IGN', C=nil, D=nil, E=nil, F=nil, dam=IGN*xW} --IGNW
			KSK[65]  = {range=Erange, A='_E', B='_IGN', C=nil, D=nil, E=nil, F=nil, dam=IGN*xE} --IGNE
			KSK[66]  = {range=Qrange, A='_Q', B='_IGN', C=nil, D=nil, E=nil, F=nil, dam=IGN*xQ} --IGNQ
			KSK[67]  = {range=Erange, A='_E', B='_IGN', C='_W', D=nil, E=nil, F=nil, dam=IGN*(xE+xW)} --IGNEW
			KSK[68]  = {range=Wrange, A='_W', B='_Q', C='_IGN', D=nil, E=nil, F=nil, dam=IGN*(xW+xQ)} --IGNWQ
			KSK[69]  = {range=Erange, A='_E', B='_Q', C='_IGN', D=nil, E=nil, F=nil, dam=IGN*(xE+xQ)} --IGNEQ
			KSK[70]  = {range=Erange, A='_E', B='_W', C='_Q', D='_IGN', E=nil, F=nil, dam=IGN*(xE+xW+xQ)} --IGNEWQ
			KSK[71]  = {range=Wrange, A='_W', B='_BC', C='_IGN', D=nil, E=nil, F=nil, dam=IGN*(xW+xBC)} --IGNWBC
			KSK[72]  = {range=Erange, A='_E', B='_BC', C='_IGN', D=nil, E=nil, F=nil, dam=IGN*(xE+xBC)} --IGNEBC
			KSK[73]  = {range=450, A='_BC', B='_Q', C='_IGN', D=nil, E=nil, F=nil, dam=IGN*(xQ+xBC)} --IGNQBC
			KSK[74]  = {range=Erange, A='_E', B='_W', C='_BC', D='_IGN', E=nil, F=nil, dam=IGN*(xE+xW+xBC)} --IGNEWBC
			KSK[75]  = {range=Wrange, A='_W', B='_BC', C='_Q', D='_IGN', E=nil, F=nil, dam=IGN*(xW+xQ+xBC)} --IGNWQBC
			KSK[76]  = {range=Erange, A='_E', B='_BC', C='_Q', D='_IGN', E=nil, F=nil, dam=IGN*(xE+xQ+xBC)} --IGNEQBC
			KSK[77]  = {range=Erange, A='_E', B='_W', C='_BC', D='_Q', E='_IGN', F=nil, dam=IGN*(xE+xW+xQ+xBC)} --IGNEWQBC
			KSK[78]  = {range=Wrange, A='_W', B='_HG', C='_IGN', D=nil, E=nil, F=nil, dam=IGN*(xW+xHG)} --IGNWHG
			KSK[79]  = {range=Erange, A='_E', B='_HG', C='_IGN', D=nil, E=nil, F=nil, dam=IGN*(xE+xHG)} --IGNEHG
			KSK[80]  = {range=Qrange, A='_HG', B='_Q', C='_IGN', D=nil, E=nil, F=nil, dam=IGN*(xQ+xHG)} --IGNQHG
			KSK[81]  = {range=Erange, A='_E', B='_W', C='_HG', D='_IGN', E=nil, F=nil, dam=IGN*(xE+xW+xHG)} --IGNEWHG
			KSK[82]  = {range=Wrange, A='_W', B='_HG', C='_Q', D='_IGN', E=nil, F=nil, dam=IGN*(xW+xQ+xHG)} --IGNWQHG
			KSK[83]  = {range=Erange, A='_E', B='_HG', C='_Q', D='_IGN', E=nil, F=nil, dam=IGN*(xE+xQ+xHG)} --IGNEQHG
			KSK[84]  = {range=Erange, A='_E', B='_W', C='_HG', D='_Q', E='_IGN', F=nil, dam=IGN*(xE+xW+xQ+xHG)} --IGNEWQHG
			KSK[85]  = {range=Wrange, A='_DFG', B='_W', C='_IGN', D=nil, E=nil, F=nil, dam=((IGN*(xW*1.2)+xDFG))*DFG} --IGNWDFG
			KSK[86]  = {range=Erange, A='_DFG', B='_E', C='_IGN', D=nil, E=nil, F=nil, dam=((IGN*(xE*1.2)+xDFG))*DFG} --IGNEDFG
			KSK[87]  = {range=Qrange, A='_DFG', B='_Q', C='_IGN', D=nil, E=nil, F=nil, dam=((IGN*(xQ*1.2)+xDFG))*DFG} --IGNQDFG
			KSK[88]  = {range=Erange, A='_DFG', B='_E', C='_W', D='_IGN', E=nil, F=nil, dam=((IGN*(xE+xW*1.2)+xDFG))*DFG} --IGNEWDFG
			KSK[89]  = {range=Wrange, A='_DFG', B='_W', C='_Q', D='_IGN', E=nil, F=nil, dam=((IGN*(xW+xQ*1.2)+xDFG))*DFG} --IGNWQDFG
			KSK[90]  = {range=Erange, A='_DFG', B='_E', C='_Q', D='_IGN', E=nil, F=nil, dam=((IGN*(xE+xQ*1.2)+xDFG))*DFG} --IGNEQDFG
			KSK[91]  = {range=Erange, A='_DFG', B='_E', C='_W', D='_Q', E='_IGN', F=nil, dam=((IGN*(xE+xW+xQ*1.2)+xDFG))*DFG} --IGNEWQDFG
			KSK[92]  = {range=Wrange, A='_BFT', B='_W', C='_IGN', D=nil, E=nil, F=nil, dam=((IGN*(xW*1.2)+xBFT))*BFT} --IGNWBFT
			KSK[93]  = {range=Erange, A='_BFT', B='_E', C='_IGN', D=nil, E=nil, F=nil, dam=((IGN*(xE*1.2)+xBFT))*BFT} --IGNEBFT
			KSK[94]  = {range=Qrange, A='_BFT', B='_Q', C='_IGN', D=nil, E=nil, F=nil, dam=((IGN*(xQ*1.2)+xBFT))*BFT} --IGNQBFT
			KSK[95]  = {range=Erange, A='_BFT', B='_E', C='_W', D='_IGN', E=nil, F=nil, dam=((IGN*(xE+xW*1.2)+xBFT))*BFT} --IGNEWBFT
			KSK[96]  = {range=Wrange, A='_BFT', B='_W', C='_Q', D='_IGN', E=nil, F=nil, dam=((IGN*(xW+xQ*1.2)+xBFT))*BFT} --IGNWQBFT
			KSK[97]  = {range=Erange, A='_BFT', B='_E', C='_Q', D='_IGN', E=nil, F=nil, dam=((IGN*(xE+xQ*1.2)+xBFT))*BFT} --IGNEQBFT
			KSK[98]  = {range=Erange, A='_BFT', B='_E', C='_W', D='_Q', E='_IGN', F=nil, dam=((IGN*(xE+xW+xQ*1.2)+xBFT))*BFT} --IGNEWQBFT
			KSK[99]  = {range=Wrange, A='_DFG', B='_W', C='_BC', D='_IGN', E=nil, F=nil, dam=((IGN*(xW+xBC*1.2)+xDFG))*DFG} --IGNWBCDFG
			KSK[100] = {range=Erange, A='_DFG', B='_E', C='_BC', D='_IGN', E=nil, F=nil, dam=((IGN*(xE+xBC*1.2)+xDFG))*DFG} --IGNEBCDFG
			KSK[101] = {range=450, A='_DFG', B='_BC', C='_Q', D='_IGN', E=nil, F=nil, dam=((IGN*(xQ+xBC*1.2)+xDFG))*DFG} --IGNQBCDFG
			KSK[102] = {range=Erange, A='_DFG', B='_E', C='_W', D='_BC', E='_IGN', F=nil, dam=((IGN*(xE+xW+xBC*1.2)+xDFG))*DFG} --IGNEWBCDFG
			KSK[103] = {range=Wrange, A='_DFG', B='_W', C='_BC', D='_Q', E='_IGN', F=nil, dam=((IGN*(xW+xQ+xBC*1.2)+xDFG))*DFG} --IGNWQBCDFG
			KSK[104] = {range=Erange, A='_DFG', B='_E', C='_BC', D='_Q', E='_IGN', F=nil, dam=((IGN*(xE+xQ+xBC*1.2)+xDFG))*DFG} --IGNEQBCDFG
			KSK[105] = {range=Erange, A='_DFG', B='_E', C='_BC', D='_W', E='_Q', F='_IGN', dam=((IGN*(xE+xW+xQ+xBC*1.2)+xDFG))*DFG} --IGNEWQBCDFG
			KSK[106] = {range=Wrange, A='_BFT', B='_W', C='_BC', D='_IGN', E=nil, F=nil, dam=((IGN*(xW+xBC*1.2)+xBFT)*BFT)} --IGNWBCBFT
			KSK[107] = {range=Erange, A='_BFT', B='_E', C='_BC', D='_IGN', E=nil, F=nil, dam=((IGN*(xE+xBC*1.2)+xBFT)*BFT)} --IGNEBCBFT
			KSK[108] = {range=450, A='_BFT', B='_BC', C='_Q', D='_IGN', E=nil, F=nil, dam=((IGN*(xQ+xBC*1.2)+xBFT))*BFT} --IGNQBCBFT
			KSK[109] = {range=Erange, A='_BFT', B='_E', C='_W', D='_BC', E='_IGN', F=nil, dam=((IGN*(xE+xW+xBC*1.2)+xBFT))*BFT} --IGNEWBCBFT
			KSK[110] = {range=Wrange, A='_BFT', B='_W', C='_BC', D='_Q', E='_IGN', F=nil, dam=((IGN*(xW+xQ+xBC*1.2)+xBFT))*BFT} --IGNWQBCBFT
			KSK[111] = {range=Erange, A='_BFT', B='_E', C='_BC', D='_Q', E='_IGN', F=nil, dam=((IGN*(xE+xQ+xBC*1.2)+xBFT))*BFT} --IGNEQBCBFT
			KSK[112] = {range=Erange, A='_BFT', B='_BC', C='_E', D='_W', E='_Q', F='_IGN', dam=((IGN*(xE+xW+xQ+xBC*1.2)+xBFT))*BFT} --IGNEWQBCBFT
			KSK[113] = {range=Wrange, A='_DFG', B='_W', C='_HG', D='_IGN', E=nil, F=nil, dam=((IGN*(xW+xHG*1.2)+xDFG))*DFG} --IGNWHGDFG
			KSK[114] = {range=Erange, A='_DFG', B='_E', C='_HG', D='_IGN', E=nil, F=nil, dam=((IGN*(xE+xHG*1.2)+xDFG))*DFG} --IGNEHGDFG
			KSK[115] = {range=450, A='_DFG', B='_HG', C='_Q', D='_IGN', E=nil, F=nil, dam=((IGN*(xQ+xHG*1.2)+xDFG))*DFG} --IGNQHGDFG
			KSK[116] = {range=Erange, A='_DFG', B='_E', C='_W', D='_HG', E='_IGN', F=nil, dam=((IGN*(xE+xW+xHG*1.2)+xDFG))*DFG} --IGNEWHGDFG
			KSK[117] = {range=Wrange, A='_DFG', B='_W', C='_HG', D='_Q', E='_IGN', F=nil, dam=((IGN*(xW+xQ+xHG*1.2)+xDFG))*DFG} --IGNWQHGDFG
			KSK[118] = {range=Erange, A='_DFG', B='_E', C='_HG', D='_Q', E='_IGN', F=nil, dam=((IGN*(xE+xQ+xHG*1.2)+xDFG))*DFG} --IGNEQHGDFG
			KSK[119] = {range=Erange, A='_DFG', B='_E', C='_HG', D='_W', E='_Q', F='_IGN', dam=((IGN*(xE+xW+xQ+xHG*1.2)+xDFG))*DFG} --IGNEWQHGDFG
			KSK[120] = {range=Wrange, A='_BFT', B=nil, C=nil, D=nil, E=nil, F=nil, dam=((IGN*(xW+xHG*1.2)+xBFT))*BFT} --IGNWHGBFT
			KSK[121] = {range=Erange, A='_BFT', B='_E', C='_HG', D='_IGN', E=nil, F=nil, dam=((IGN*(xE+xHG*1.2)+xBFT))*BFT} --IGNEHGBFT
			KSK[122] = {range=450, A='_BFT', B='_HG', C='_Q', D='_IGN', E=nil, F=nil, dam=((IGN*(xQ+xHG*1.2)+xBFT))*BFT} --IGNQHGBFT
			KSK[123] = {range=Erange, A='_BFT', B='_E', C='_W', D='_HG', E='_IGN', F=nil, dam=((IGN*(xE+xW+xHG*1.2)+xBFT))*BFT} --IGNEWHGBFT
			KSK[124] = {range=Wrange, A='_BFT', B='_W', C='_HG', D='_Q', E='_IGN', F=nil, dam=((IGN*(xW+xQ+xHG*1.2)+xBFT))*BFT} --IGNWQHGBFT
			KSK[125] = {range=Erange, A='_BFT', B='_E', C='_HG', D='_Q', E='_IGN', F=nil, dam=((IGN*(xE+xQ+xHG*1.2)+xBFT))*BFT} --IGNEQHGBFT
			KSK[126] = {range=Erange, A='_BFT', B='_E', C='_HG', D='_W', E='_Q', F='_IGN', dam=((IGN*(xE+xW+xQ+xHG*1.2)+xBFT))*BFT} --IGNEWQHGBFT
			
			for v=1,126 do
				if MainCFG.Killsteal and GetDistance(enemy)<KSK[v].range and effhealth<KSK[v].dam then Seq(KSK[v].A,KSK[v].B,KSK[v].C,KSK[v].D,KSK[v].E,KSK[v].F,enemy) end
			end
			for v=1,126 do
				if MainCFG.KSNotes and effhealth<KSK[v].dam then DrawTextObject('KILLSTEAL',enemy,Color.Yellow) end
			end
		end
	end
end

function Seq(a,b,c,d,e,f,target)
	if target~=nil then
		if a~=nil and a == '_Q' then Qspell(target)
		elseif a~=nil and a == '_W' then Wspell(target)
		elseif a~=nil and a == '_E' then Espell(target)
		elseif a~=nil and a == '_R' then Rspell(target)
		elseif a~=nil and a == '_I' then Ispell(target)
		elseif a~=nil and a == '_BC' then UseItemOnTarget(3144, target)
		elseif a~=nil and a == '_HG' then UseItemOnTarget(3146, target)
		elseif a~=nil and a == '_DFG' then UseItemOnTarget(3128, target)
		elseif a~=nil and a == '_BFT' then UseItemOnTarget(3188, target)
		elseif a~=nil and a == '_IGN' then CastSummonerIgnite(target)
		end
		if b~=nil and b == '_Q' then Qspell(target)
		elseif b~=nil and b == '_W' then Wspell(target)
		elseif b~=nil and b == '_E' then Espell(target)
		elseif b~=nil and b == '_R' then Rspell(target)
		elseif b~=nil and b == '_I' then Ispell(target)
		elseif b~=nil and b == '_BC' then UseItemOnTarget(3144, target)
		elseif b~=nil and b == '_HG' then UseItemOnTarget(3146, target)
		elseif b~=nil and b == '_DFG' then UseItemOnTarget(3128, target)
		elseif b~=nil and b == '_BFT' then UseItemOnTarget(3188, target)
		elseif b~=nil and b == '_IGN' then CastSummonerIgnite(target)
		end
		if c~=nil and c == '_Q' then Qspell(target)
		elseif c~=nil and c == '_W' then Wspell(target)
		elseif c~=nil and c == '_E' then Espell(target)
		elseif c~=nil and c == '_R' then Rspell(target)
		elseif c~=nil and c == '_I' then Ispell(target)
		elseif c~=nil and c == '_BC' then UseItemOnTarget(3144, target)
		elseif c~=nil and c == '_HG' then UseItemOnTarget(3146, target)
		elseif c~=nil and c == '_DFG' then UseItemOnTarget(3128, target)
		elseif c~=nil and c == '_BFT' then UseItemOnTarget(3188, target)
		elseif c~=nil and c == '_IGN' then CastSummonerIgnite(target)
		end
		if d~=nil and d == '_Q' then Qspell(target)
		elseif d~=nil and d == '_W' then Wspell(target)
		elseif d~=nil and d == '_E' then Espell(target)
		elseif d~=nil and d == '_R' then Rspell(target)
		elseif d~=nil and d == '_I' then Ispell(target)
		elseif d~=nil and d == '_BC' then UseItemOnTarget(3144, target)
		elseif d~=nil and d == '_HG' then UseItemOnTarget(3146, target)
		elseif d~=nil and d == '_DFG' then UseItemOnTarget(3128, target)
		elseif d~=nil and d == '_BFT' then UseItemOnTarget(3188, target)
		elseif d~=nil and d == '_IGN' then CastSummonerIgnite(target)
		end
		if e~=nil and e == '_Q' then Qspell(target)
		elseif e~=nil and e == '_W' then Wspell(target)
		elseif e~=nil and e == '_E' then Espell(target)
		elseif e~=nil and e == '_R' then Rspell(target)
		elseif e~=nil and e == '_I' then Ispell(target)
		elseif e~=nil and e == '_BC' then UseItemOnTarget(3144, target)
		elseif e~=nil and e == '_HG' then UseItemOnTarget(3146, target)
		elseif e~=nil and e == '_DFG' then UseItemOnTarget(3128, target)
		elseif e~=nil and e == '_BFT' then UseItemOnTarget(3188, target)
		elseif e~=nil and e == '_IGN' then CastSummonerIgnite(target)
		end
		if f~=nil and f == '_Q' then Qspell(target)
		elseif f~=nil and f == '_W' then Wspell(target)
		elseif f~=nil and f == '_E' then Espell(target)
		elseif f~=nil and f == '_R' then Rspell(target)
		elseif f~=nil and f == '_I' then Ispell(target)
		elseif f~=nil and f == '_BC' then UseItemOnTarget(3144, target)
		elseif f~=nil and f == '_HG' then UseItemOnTarget(3146, target)
		elseif f~=nil and f == '_DFG' then UseItemOnTarget(3128, target)
		elseif f~=nil and f == '_BFT' then UseItemOnTarget(3188, target)
		elseif f~=nil and f == '_IGN' then CastSummonerIgnite(target)
		end
	end
end

function OnProcessSpell(unit, spell)
	if unit ~= nil and spell ~= nil and unit.charName == myHero.charName then
		if spell.name == 'KatarinaR' then locus = true end
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

function dodgeaoe(pos1, pos2, radius)
	local calc = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
	local dodgex = pos2.x + ((radius+50)/calc)*(myHero.x-pos2.x)
	local dodgez = pos2.z + ((radius+50)/calc)*(myHero.z-pos2.z)
	if calc < radius and DodgeCFG.DodgeSkillShotsAOE == true and GetCursorX() > xa and GetCursorX() < xb and GetCursorY() > ya and GetCursorY() < yb and locus==false then
		if DodgeCFG.BlockSettings == 1 and KeyCFG.Combo == false and KeyCFG.Harass == false then
			dodgetimer = GetTickCount()
			send.block_input(true,DodgeCFG.BlockTime)
			MoveToXYZ(dodgex,0,dodgez)
		elseif DodgeCFG.BlockSettings == 2 or KeyCFG.Combo or KeyCFG.Harass then
			dodgetimer = GetTickCount()
			MoveToXYZ(dodgex,0,dodgez)
		end
	end
end

function dodgelinepoint(pos1, pos2, radius)
	local calc1 = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
	local calc2 = (math.floor(math.sqrt((pos1.x-myHero.x)^2 + (pos1.z-myHero.z)^2)))
	local calc4 = (math.floor(math.sqrt((pos1.x-pos2.x)^2 + (pos1.z-pos2.z)^2)))
	local perpendicular = (math.floor((math.abs((pos2.x-pos1.x)*(pos1.z-myHero.z)-(pos1.x-myHero.x)*(pos2.z-pos1.z)))/(math.sqrt((pos2.x-pos1.x)^2 + (pos2.z-pos1.z)^2))))
	local k = ((pos2.z-pos1.z)*(myHero.x-pos1.x) - (pos2.x-pos1.x)*(myHero.z-pos1.z)) / ((pos2.z-pos1.z)^2 + (pos2.x-pos1.x)^2)
	local x4 = myHero.x - k * (pos2.z-pos1.z)
	local z4 = myHero.z + k * (pos2.x-pos1.x)
	local calc3 = (math.floor(math.sqrt((x4-myHero.x)^2 + (z4-myHero.z)^2)))
	local dodgex = x4 + ((radius+100)/calc3)*(myHero.x-x4)
	local dodgez = z4 + ((radius+100)/calc3)*(myHero.z-z4)
	if perpendicular < radius and calc1 < calc4 and calc2 < calc4 and DodgeCFG.DodgeSkillShots == true and GetCursorX() > xa and GetCursorX() < xb and GetCursorY() > ya and GetCursorY() < yb and locus==false then
		if DodgeCFG.BlockSettings == 1 and KeyCFG.Combo == false and KeyCFG.Harass == false then
			dodgetimer = GetTickCount()
			send.block_input(true,DodgeCFG.BlockTime)
			MoveToXYZ(dodgex,0,dodgez)
		elseif DodgeCFG.BlockSettings == 2 or KeyCFG.Combo or KeyCFG.Harass then
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
	local calc4 = (math.floor(math.sqrt((pos1.x-pm2x)^2 + (pos1.z-pm2z)^2)))
	local perpendicular = (math.floor((math.abs((pm2x-pos1.x)*(pos1.z-myHero.z)-(pos1.x-myHero.x)*(pm2z-pos1.z)))/(math.sqrt((pm2x-pos1.x)^2 + (pm2z-pos1.z)^2))))
	local k = ((pm2z-pos1.z)*(myHero.x-pos1.x) - (pm2x-pos1.x)*(myHero.z-pos1.z)) / ((pm2z-pos1.z)^2 + (pm2x-pos1.x)^2)
	local x4 = myHero.x - k * (pm2z-pos1.z)
	local z4 = myHero.z + k * (pm2x-pos1.x)
	local calc3 = (math.floor(math.sqrt((x4-myHero.x)^2 + (z4-myHero.z)^2)))
	local dodgex = x4 + ((radius+100)/calc3)*(myHero.x-x4)
	local dodgez = z4 + ((radius+100)/calc3)*(myHero.z-z4)
	if perpendicular < radius and calc1 < calc4 and calc2 < calc4 and DodgeCFG.DodgeSkillShots == true and GetCursorX() > xa and GetCursorX() < xb and GetCursorY() > ya and GetCursorY() < yb and locus==false then
		if DodgeCFG.BlockSettings == 1 and KeyCFG.Combo == false and KeyCFG.Harass == false then
			dodgetimer = GetTickCount()
			send.block_input(true,DodgeCFG.BlockTime)
			MoveToXYZ(dodgex,0,dodgez)
		elseif DodgeCFG.BlockSettings == 2 or KeyCFG.Combo or KeyCFG.Harass then
			dodgetimer = GetTickCount()
			MoveToXYZ(dodgex,0,dodgez)
		end
	end
end

function AutoLevel()
	local spellLevelSum = myHero.SpellLevelQ + myHero.SpellLevelW + myHero.SpellLevelE + myHero.SpellLevelR
	if attempts <= 10 or (attempts > 10 and GetTickCount() > lastAttempt+1500) then
		if spellLevelSum < myHero.selflevel then
			if lastSpellLevelSum ~= spellLevelSum then attempts = 0 end
			if GetMap() == 1 or GetMap() == 3 then letter = skillingOrder["SR"][spellLevelSum+1] end
			if GetMap() == 0 or GetMap() == 2 then letter = skillingOrder["DOM"][spellLevelSum+1] end
			Level_Spell(letter, spellLevelSum)
			attempts = attempts+1
			lastAttempt = GetTickCount()
			lastSpellLevelSum = spellLevelSum
		else
			attempts = 0
		end
	end
end
 
function Level_Spell(letter)  
     if letter == Q then send.key_press(0x69)
     elseif letter == W then send.key_press(0x6a)
     elseif letter == E then send.key_press(0x6b)
     elseif letter == R then send.key_press(0x6c) end
end

function RedElixir()
	if IsBuffed(myHero,'FountainHeal') then
		timer=os.clock()
		bluePill = object
	end
	if bluePill == nil then
		if myHero.health < myHero.maxHealth * (CfgPotions.Health_Potion_Value / 100) and GetClock() > wUsedAt + 15000 then
			UseItemOnTarget(2003,myHero)
			wUsedAt = GetClock()
		elseif myHero.health < myHero.maxHealth * (CfgPotions.Chrystalline_Flask_Value / 100) and GetClock() > vUsedAt + 10000 then 
			UseItemOnTarget(2041,myHero)
			vUsedAt = GetClock()
		elseif myHero.health < myHero.maxHealth * (CfgPotions.Biscuit_Value / 100) then
			UseItemOnTarget(2009,myHero)
		elseif myHero.health < myHero.maxHealth * (CfgPotions.Elixir_of_Fortitude_Value / 100) then
			UseItemOnTarget(2037,myHero)
		end
	end
	if (os.clock() < timer + 5000) then
		bluePill = nil 
	end
end

function Items()
	print(myHero.InventorySlot3)
	if locus == false and MainCFG.AutoZonyas and myHero.health < myHero.maxHealth*(MainCFG.Zhonyas_Hourglass_Value/100) then 
		UseItemOnTarget(3157,myHero)
		UseItemOnTarget(3090,myHero)
	end
end

SetTimerCallback('Main')