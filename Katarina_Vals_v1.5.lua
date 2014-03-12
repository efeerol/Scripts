require 'Utils'
require 'winapi'
require 'SKeys'
require 'vals_lib'
require 'runrunrun'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local Q,W,E,R = 'Q','W','E','R'
local version = '1.5'
----------------------------
local toggle_timer = os.clock()
local cc,locus_timer,dodgetimer = 0,0,0
local skillshotArray = {}
local KSK = {}
local Minions = {}
local SORT_CUSTOM = function(a, b) return a.maxHealth and b.maxHealth and a.maxHealth < b.maxHealth end
local Enemies = {}
local EnemyIndex = 1
local skillshotArray = {}
local xa,xb,ya,yb = 50/1920*GetScreenX(),1870/1920*GetScreenX(),50/1080*GetScreenY(),1030/1080*GetScreenY()
---------- CONFIG ----------
local Harass_Mode = 3 -- Harassmode on gamestart [1=Q, 2=EQ, 3=EQW, 4=IEQW]
local Combo_Mode = 2 -- Combomode on gamestart [1=EQWR, 2=IEQWR]
local DrawX,DrawY = 70,170 -- X/Y-oordinates of the mode text
local Qrange = 675
local Wrange = 350
local Erange = 700
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
	menu.checkbutton('RoamHelper', 'RoamHelper', true)
	menu.checkbutton('DrawCircles', 'DrawCircles', true)
	menu.checkbutton('MouseMove', 'MouseMove', true)
	menu.checkbutton('StunDraw', 'Draw HardCC', true)
	menu.checkbutton('AutoZonyas', 'AutoZonyas', true)
	menu.slider('Zhonyas_Hourglass_Value', 'Zhonya Hourglass Value', 0, 100, 15, nil, true)
	
	DodgeCFG, menu = uiconfig.add_menu('3.) DodgeSkillshot Config', 250)
	menu.checkbutton('DrawSkillShots', 'Draw Skillshots', true)
	menu.checkbutton('DodgeSkillShots', 'Dodge Skillshots', true)
	menu.checkbutton('DodgeSkillShotsAOE', 'Dodge Skillshots for AOE', true)
	menu.slider('BlockSettings', 'Block user input', 1, 2, 1, {'FixBlock','NoBlock'})
	menu.slider('BlockSettingsAOE', 'Block user input for AOE', 1, 2, 2, {'FixBlock','NoBlock'})
	menu.slider('BlockTime', 'Block imput time', 0, 1000, 750)
	
function Main()
	if IsLolActive() then
		GetCD()
		SetVariables()
		CheckItemCD()
		Killsteal()
		HarassModes()
		ComboModes()
		Skillshots()
		Items()
		send.tick()
		cc=cc+1
		if cc==30 then LoadTable() end
		for i=1, #skillshotArray, 1 do
			if os.clock() > (skillshotArray[i].lastshot + skillshotArray[i].time) then
				skillshotArray[i].shot = 0
			end
		end
		if KeyCFG.LaneClear then LaneClear() end
		if MainCFG.StunDraw then StunDraw() end
		if MainCFG.DrawCircles then CustomCircle(Erange,1,2,myHero) end
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
	
	target = GetWeakEnemy('MAGIC',700,'NEARMOUSE')
	targetaa = GetWeakEnemy('MAGIC',myHero.range+(GetDistance(GetMinBBox(myHero)))+50)
	Minions = GetEnemyMinions(SORT_CUSTOM)
end 	
		
function HarassModes()
	DrawText('Harass Mode:',DrawX,DrawY-10,Color.White)
	if (MainCFG.HarassMode and os.clock() - toggle_timer>.15) then
		toggle_timer = os.clock()
		Harass_Mode = ((Harass_Mode+1)%5)
	end
	if (Harass_Mode == 1) then
		DrawText('Q',DrawX,DrawY,Color.White)
	elseif (Harass_Mode == 2) then
		DrawText('E-Q',DrawX,DrawY,Color.White)
	elseif (Harass_Mode == 3) then
		DrawText('E-Q-W',DrawX,DrawY,Color.White)
	elseif (Harass_Mode == 4) then
		DrawText('I-E-Q-W',DrawX,DrawY,Color.White)
	else
		DrawText("OFF",DrawX,DrawY,Color.White)
		return
	end
	if KeyCFG.Harass and locus==false then
		if Harass_Mode == 1 then Seq('_Q','_A',nil,nil,nil,nil,target)
		elseif Harass_Mode == 2 then Seq('_E','_Q','_A',nil,nil,nil,target)
		elseif Harass_Mode == 3 then Seq('_E','_Q','_W','_A',nil,nil,target)
		elseif Harass_Mode == 4 then Seq('_I','_E','_Q','_W','_A',nil,target)
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
		DrawText('E-Q-W-R',DrawX,DrawY+30,Color.White)
	elseif (Combo_Mode == 2) then
		DrawText('I-E-Q-W-R',DrawX,DrawY+30,Color.White)
	else
		DrawText("OFF",DrawX,DrawY+30,Color.White)
		return
	end
	if KeyCFG.Combo and locus==false then
		if Combo_Mode == 1 then Seq('_E','_Q','_W','_R','_A',nil,target)
		elseif Combo_Mode == 2 then Seq('_I','_E','_Q','_W','_R','_A',target)
		end
		Move()
	end
end

function LaneClear()
	for i, minion in pairs(Minions) do
		if minion~=nil then
			CustomCircle(75,1,2,minion)
			if GetDistance(minion,mousePos)<200 then Seq('_Q','_E','_W',nil,nil,nil,minion) end
		end
	end
	Move()
end

function Qspell(target)
	SpellTarget(Q,QRDY,myHero,target,Qrange)
end

function Wspell(target)
	SpellXYZ(W,WRDY,myHero,target,Wrange,myHero.x,myHero.z)
end

function Espell(target)
	SpellTarget(E,ERDY,myHero,target,Qrange)
end

function Rspell()
	run_many_reset(1,Rspell2)
	if CountEnemyHeroInRange(Rrange) == 0 then
		locus = false
	end
end

function Rspell2()
	if target~=nil then
		local xQ = (35+(myHero.SpellLevelQ*25)+(myHero.ap*.45))*QRDY
		local xW = (15+(myHero.SpellLevelW*35)+(myHero.ap*.25)+(myHero.addDamage*.6))*WRDY
		local xE = (35+(myHero.SpellLevelE*25)+(myHero.ap*.4))*ERDY
		local effhealtht = target.health*(1+(((target.magicArmor*myHero.magicPenPercent)-myHero.magicPen)/100))
		if RRDY==1 and QRDY+WRDY+ERDY==0 and effhealtht>xQ+xW+xE then 
			CastSpellTarget("R",target)
			locus = true
		end
	end
	if RRDY==1 then return true end
end

function CountEnemyHeroInRange(range, object)
    object = object or myHero
    range = range and range * range or myHero.range * myHero.range
    local enemyInRange = 0
    for i = 1, objManager:GetMaxHeroes() do
        local hero = objManager:GetHero(i)
        if (hero~=nil and hero.team~=myHero.team and hero.dead==0) and GetDistance(object, hero) <= range then
            enemyInRange = enemyInRange + 1
        end
    end
    return enemyInRange
end

function Ispell(target)
	if locus==false and QRDY*WRDY*ERDY==1 and GetDistance(target)<700 then
		if BC == 1 and target~=nil then UseItemOnTarget(3144, target)
		elseif HG == 1 and target~=nil then UseItemOnTarget(3146, target)
		elseif BFT == 1 and target~=nil and GetDistance(target)<Erange then UseItemOnTarget(3188, target)
		elseif DFG == 1 and target~=nil and GetDistance(target)<Erange then UseItemOnTarget(3128, target)
		end
	end
end

function Attack(target)
	if locus==false and targetaa~=nil then AttackTarget(target) end
end

function Move()
	if locus==false and dodgetimer==0 and MainCFG.MouseMove then MoveToMouse() end
end

function Killsteal()
	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if (enemy~=nil and enemy.team~=myHero.team) then
			if Enemies[enemy.name] == nil then
				Enemies[enemy.name] = { Unit = enemy, Number = EnemyIndex }
				EnemyIndex = EnemyIndex + 1
			end
			if (enemy.visible==1 and enemy.invulnerable==0 and enemy.dead==0) then
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
				if Harass_Mode == 1 then damageH = xQ
				elseif Harass_Mode == 2 then damageH = xQ+xW
				elseif Harass_Mode == 3 or Harass_Mode == 6 then damageH = xQ+xE
				elseif Harass_Mode == 4 or Harass_Mode == 7 then damageH = xQ+xW+xE
				elseif Harass_Mode == 5 or Harass_Mode == 8 then damageH = (xQ+xW+xE+xDFG+xBFT+xBC+xHG)+(((xQ+xW+xE+xBC+xHG)/5)*(DFG+BFT))
				else damageH = 0
				end
				if Combo_Mode == 1 or Combo_Mode == 2 then damageC = xQ+xW+xE+xR
				elseif Combo_Mode == 3 or Combo_Mode == 4 then damageC = (xQ+xW+xE+xR+xDFG+xBFT+xBC+xHG)+(((xQ+xW+xE+xR+xBC+xHG)/5)*(DFG+BFT))
				else damageC = 0
				end
				local effdamageH = damageH*(100/(100+((enemy.magicArmor*myHero.magicPenPercent)-myHero.magicPen)))
				local effdamageC = damageC*(100/(100+((enemy.magicArmor*myHero.magicPenPercent)-myHero.magicPen)))
				
				KSK[1]   = {range=Wrange, A='_W', B=nil, C=nil, D=nil, E=nil, F=nil, ls='*W', var=false, dam=xW} --W
				KSK[2]   = {range=Wrange, A='_E', B=nil, C=nil, D=nil, E=nil, F=nil, var=false, dam=xE} --E
				KSK[3]   = {range=Qrange, A='_Q', B=nil, C=nil, D=nil, E=nil, F=nil, var=false, dam=xQ} --Q
				KSK[4]   = {range=Erange, A='_E', B='_W', C=nil, D=nil, E=nil, F=nil, var=false, dam=xE+xW} --EW
				KSK[5]   = {range=Wrange, A='_W', B='_Q', C=nil, D=nil, E=nil, F=nil, var=false, dam=xW+xQ} --WQ
				KSK[6]   = {range=Erange, A='_E', B='_Q', C=nil, D=nil, E=nil, F=nil, var=false, dam=xE+xQ} --EQ
				KSK[7]   = {range=Erange, A='_E', B='_W', C='_Q', D=nil, E=nil, F=nil, var=false, dam=xE+xW+xQ} --EWQ
				KSK[8]   = {range=Wrange, A='_BC', B='_W', C=nil, D=nil, E=nil, F=nil, var=false, dam=xW+xBC} --WBC
				KSK[9]   = {range=Erange, A='_BC', B='_E', C=nil, D=nil, E=nil, F=nil, var=false, dam=xE+xBC} --EBC
				KSK[10]  = {range=450, A='_BC', B='_Q', C=nil, D=nil, E=nil, F=nil, var=false, dam=xQ+xBC} --QBC
				KSK[11]  = {range=Erange, A='_E', B='_W', C='_BC', D=nil, E=nil, F=nil, var=false, dam=xE+xW+xBC} --EWBC
				KSK[12]  = {range=Wrange, A='_W', B='_BC', C='_Q', D=nil, E=nil, F=nil, var=false, dam=xW+xQ+xBC} --WQBC
				KSK[13]  = {range=Erange, A='_E', B='_BC', C='_Q', D=nil, E=nil, F=nil, var=false, dam=xE+xQ+xBC} --EQBC
				KSK[14]  = {range=Erange, A='_E', B='_W', C='_BC', D='_Q', E=nil, F=nil, var=false, dam=xE+xW+xQ+xBC} --EWQBC
				KSK[15]  = {range=Wrange, A='_W', B='_HG', C=nil, D=nil, E=nil, F=nil, var=false, dam=xW+xHG} --WHG
				KSK[16]  = {range=Erange, A='_E', B='_HG', C=nil, D=nil, E=nil, F=nil, var=false, dam=xE+xHG} --EHG
				KSK[17]  = {range=Qrange, A='_HG', B='_Q', C=nil, D=nil, E=nil, F=nil, var=false, dam=xQ+xHG} --QHG
				KSK[18]  = {range=Erange, A='_E', B='_W', C='_HG', D=nil, E=nil, F=nil, var=false, dam=xE+xW+xHG} --EWHG
				KSK[19]  = {range=Wrange, A='_W', B='_HG', C='_Q', D=nil, E=nil, F=nil, var=false, dam=xW+xQ+xHG} --WQHG
				KSK[20]  = {range=Erange, A='_E', B='_HG', C='_Q', D=nil, E=nil, F=nil, var=false, dam=xE+xQ+xHG} --EQHG
				KSK[21]  = {range=Erange, A='_E', B='_W', C='_HG', D='_Q', E=nil, F=nil, var=false, dam=xE+xW+xQ+xHG} --EWQHG
				KSK[22]  = {range=Wrange, A='_DFG', B='_E', C='_W', D=nil, E=nil, F=nil, var=false, dam=((xW*1.2)+xDFG)*DFG} --WDFG
				KSK[23]  = {range=Erange, A='_DFG', B='_E', C=nil, D=nil, E=nil, F=nil, var=false, dam=((xE*1.2)+xDFG)*DFG} --EDFG
				KSK[24]  = {range=Qrange, A='_DFG', B='_Q', C=nil, D=nil, E=nil, F=nil, var=false, dam=((xQ*1.2)+xDFG)*DFG} --QDFG
				KSK[25]  = {range=Erange, A='_DFG', B='_E', C='_W', D=nil, E=nil, F=nil, var=false, dam=((xE+xW*1.2)+xDFG)*DFG} --EWDFG
				KSK[26]  = {range=Wrange, A='_DFG', B='_W', C='_Q', D=nil, E=nil, F=nil, var=false, dam=((xW+xQ*1.2)+xDFG)*DFG} --WQDFG
				KSK[27]  = {range=Erange, A='_DFG', B='_E', C='_Q', D=nil, E=nil, F=nil, var=false, dam=((xE+xQ*1.2)+xDFG)*DFG} --EQDFG
				KSK[28]  = {range=Erange, A='_DFG', B='_E', C='_W', D='_Q', E=nil, F=nil, var=false, dam=((xE+xW+xQ*1.2)+xDFG)*DFG} --EWQDFG
				KSK[29]  = {range=Wrange, A='_BFT', B='_W', C=nil, D=nil, E=nil, F=nil, var=false, dam=((xW*1.2)+xBFT)*BFT} --WBFT
				KSK[30]  = {range=Erange, A='_BFT', B='_E', C=nil, D=nil, E=nil, F=nil, var=false, dam=((xE*1.2)+xBFT)*BFT} --EBFT
				KSK[31]  = {range=Qrange, A='_BFT', B='_Q', C=nil, D=nil, E=nil, F=nil, var=false, dam=((xQ*1.2)+xBFT)*BFT } --QBFT
				KSK[32]  = {range=Erange, A='_BFT', B='_E', C='_W', D=nil, E=nil, F=nil, var=false, dam=((xE+xW*1.2)+xBFT)} --EWBFT
				KSK[33]  = {range=Wrange, A='_BFT', B='_W', C='_Q', D=nil, E=nil, F=nil, var=false, dam=((xW+xQ*1.2)+xBFT)*BFT} --WQBFT
				KSK[34]  = {range=Erange, A='_BFT', B='_E', C='_Q', D=nil, E=nil, F=nil, var=false, dam=((xE+xQ*1.2)+xBFT)*BFT} --EQBFT
				KSK[35]  = {range=Erange, A='_BFT', B='_E', C='_W', D='_Q', E=nil, F=nil, var=false, dam=((xE+xW+xQ*1.2)+xBFT)*BFT} --EWQBFT
				KSK[36]  = {range=Wrange, A='_DFG', B='_W', C='_BC', D=nil, E=nil, F=nil, var=false, dam=((xW+xBC*1.2)+xDFG)*DFG} --WBCDFG
				KSK[37]  = {range=Erange, A='_DFG', B='_E', C='_BC', D=nil, E=nil, F=nil, var=false, dam=((xE+xBC*1.2)+xDFG)*DFG} --EBCDFG
				KSK[38]  = {range=450, A='_DFG', B='_BC', C='_Q', D=nil, E=nil, F=nil, var=false, dam=((xQ+xBC*1.2)+xDFG)*DFG} --QBCDFG
				KSK[39]  = {range=Erange, A='_DFG', B='_E', C='_W', D='_BC', E=nil, F=nil, var=false, dam=((xE+xW+xBC*1.2)+xDFG)*DFG} --EWBCDFG
				KSK[40]  = {range=Wrange, A='_DFG', B='_W', C='_BC', D='_Q', E=nil, F=nil, var=false, dam=((xW+xQ+xBC*1.2)+xDFG)*DFG} --WQBCDFG
				KSK[41]  = {range=Erange, A='_DFG', B='_E', C='_BC', D='_Q', E=nil, F=nil, var=false, dam=((xE+xQ+xBC*1.2)+xDFG)*DFG} --EQBCDFG
				KSK[42]  = {range=Erange, A='_DFG', B='_E', C='_W', D='_Q', E='_BC', F=nil, var=false, dam=((xE+xW+xQ+xBC*1.2)+xDFG)*DFG} --EWQBCDFG
				KSK[43]  = {range=Wrange, A='_BFT', B='_W', C='_BC', D=nil, E=nil, F=nil, var=false, dam=((xW+xBC*1.2)+xBFT)*BFT} --WBCBFT
				KSK[44]  = {range=Erange, A='_BFT', B='_E', C='_BC', D=nil, E=nil, F=nil, var=false, dam=((xE+xBC*1.2)+xBFT)*BFT} --EBCBFT
				KSK[45]  = {range=450, A='_BFT', B='_BC', C='_Q', D=nil, E=nil, F=nil, var=false, dam=((xQ+xBC*1.2)+xBFT)*BFT} --QBCBFT
				KSK[46]  = {range=Erange, A='_BFT', B='_E', C='_W', D='_BC', E=nil, F=nil, var=false, dam=((xE+xW+xBC*1.2)+xBFT)*BFT} --EWBCBFT
				KSK[47]  = {range=Wrange, A='_BFT', B='_W', C='_BC', D='_Q', E=nil, F=nil, var=false, dam=((xW+xQ+xBC*1.2)+xBFT)*BFT} --WQBCBFT
				KSK[48]  = {range=Erange, A='_BFT', B='_E', C='_BC', D='_Q', E=nil, F=nil, var=false, dam=((xE+xQ+xBC*1.2)+xBFT)*BFT} --EQBCBFT
				KSK[49]  = {range=Erange, A='_BFT', B='_E', C='_W', D='_BC', E='_Q', F=nil, var=false, dam=((xE+xW+xQ+xBC*1.2)+xBFT)*BFT} --EWQBCBFT
				KSK[50]  = {range=Wrange, A='_DFG', B='_W', C='_HG', D=nil, E=nil, F=nil, var=false, dam=((xW+xHG*1.2)+xDFG)*DFG} --WHGDFG
				KSK[51]  = {range=Erange, A='_DFG', B='_E', C='_HG', D=nil, E=nil, F=nil, var=false, dam=((xE+xHG*1.2)+xDFG)*DFG} --EHGDFG
				KSK[52]  = {range=450, A='_DFG', B='_HG', C='_Q', D=nil, E=nil, F=nil, var=false, dam=((xQ+xHG*1.2)+xDFG)*DFG} --QHGDFG
				KSK[53]  = {range=Erange, A='_DFG', B='_E', C='_W', D='_HG', E=nil, F=nil, var=false, dam=((xE+xW+xHG*1.2)+xDFG)*DFG} --EWHGDFG
				KSK[54]  = {range=Wrange, A='_DFG', B='_W', C='_HG', D='_Q', E=nil, F=nil, var=false, dam=((xW+xQ+xHG*1.2)+xDFG)*DFG} --WQHGDFG
				KSK[55]  = {range=Erange, A='_DFG', B='_E', C='_HG', D='_Q', E=nil, F=nil, var=false, dam=((xE+xQ+xHG*1.2)+xDFG)*DFG} --EQHGDFG
				KSK[56]  = {range=Erange, A='_DFG', B='_E', C='_W', D='_HG', E='_Q', F=nil, var=false, dam=((xE+xW+xQ+xHG*1.2)+xDFG)*DFG} --EWQHGDFG
				KSK[57]  = {range=Wrange, A='_BFT', B='_W', C='_HG', D=nil, E=nil, F=nil, var=false, dam=((xW+xHG*1.2)+xBFT)*BFT} --WHGBFT
				KSK[58]  = {range=Erange, A='_BFT', B='_E', C='_HG', D=nil, E=nil, F=nil, var=false, dam=((xE+xHG*1.2)+xBFT)*BFT} --EHGBFT
				KSK[59]  = {range=450, A='_BFT', B='_HG', C='_Q', D=nil, E=nil, F=nil, var=false, dam=((xQ+xHG*1.2)+xBFT)*BFT} --QHGBFT
				KSK[60]  = {range=Erange, A='_BFT', B='_E', C='_W', D='_HG', E=nil, F=nil, var=false, dam=((xE+xW+xHG*1.2)+xBFT)*BFT} --EWHGBFT
				KSK[61]  = {range=Wrange, A='_BFT', B='_W', C='_HG', D='_Q', E=nil, F=nil, var=false, dam=((xW+xQ+xHG*1.2)+xBFT)*BFT} --WQHGBFT
				KSK[62]  = {range=Erange, A='_BFT', B='_E', C='_HG', D='_Q', E=nil, F=nil, var=false, dam=((xE+xQ+xHG*1.2)+xBFT)*BFT} --EQHGBFT
				KSK[63]  = {range=Erange, A='_BFT', B='_E', C='_HG', D='_W', E='_Q', F=nil, var=false, dam=((xE+xW+xQ+xHG*1.2)+xBFT)*BFT} --EWQHGBFT
				KSK[64]  = {range=Wrange, A='_W', B='_IGN', C=nil, D=nil, E=nil, F=nil, var=false, dam=IGN*xW} --IGNW
				KSK[65]  = {range=Erange, A='_E', B='_IGN', C=nil, D=nil, E=nil, F=nil, var=false, dam=IGN*xE} --IGNE
				KSK[66]  = {range=Qrange, A='_Q', B='_IGN', C=nil, D=nil, E=nil, F=nil, var=false, dam=IGN*xQ} --IGNQ
				KSK[67]  = {range=Erange, A='_E', B='_IGN', C='_W', D=nil, E=nil, F=nil, var=false, dam=IGN*(xE+xW)} --IGNEW
				KSK[68]  = {range=Wrange, A='_W', B='_Q', C='_IGN', D=nil, E=nil, F=nil, var=false, dam=IGN*(xW+xQ)} --IGNWQ
				KSK[69]  = {range=Erange, A='_E', B='_Q', C='_IGN', D=nil, E=nil, F=nil, var=false, dam=IGN*(xE+xQ)} --IGNEQ
				KSK[70]  = {range=Erange, A='_E', B='_W', C='_Q', D='_IGN', E=nil, F=nil, var=false, dam=IGN*(xE+xW+xQ)} --IGNEWQ
				KSK[71]  = {range=Wrange, A='_W', B='_BC', C='_IGN', D=nil, E=nil, F=nil, var=false, dam=IGN*(xW+xBC)} --IGNWBC
				KSK[72]  = {range=Erange, A='_E', B='_BC', C='_IGN', D=nil, E=nil, F=nil, var=false, dam=IGN*(xE+xBC)} --IGNEBC
				KSK[73]  = {range=450, A='_BC', B='_Q', C='_IGN', D=nil, E=nil, F=nil, var=false, dam=IGN*(xQ+xBC)} --IGNQBC
				KSK[74]  = {range=Erange, A='_E', B='_W', C='_BC', D='_IGN', E=nil, F=nil, var=false, dam=IGN*(xE+xW+xBC)} --IGNEWBC
				KSK[75]  = {range=Wrange, A='_W', B='_BC', C='_Q', D='_IGN', E=nil, F=nil, var=false, dam=IGN*(xW+xQ+xBC)} --IGNWQBC
				KSK[76]  = {range=Erange, A='_E', B='_BC', C='_Q', D='_IGN', E=nil, F=nil, var=false, dam=IGN*(xE+xQ+xBC)} --IGNEQBC
				KSK[77]  = {range=Erange, A='_E', B='_W', C='_BC', D='_Q', E='_IGN', F=nil, var=false, dam=IGN*(xE+xW+xQ+xBC)} --IGNEWQBC
				KSK[78]  = {range=Wrange, A='_W', B='_HG', C='_IGN', D=nil, E=nil, F=nil, var=false, dam=IGN*(xW+xHG)} --IGNWHG
				KSK[79]  = {range=Erange, A='_E', B='_HG', C='_IGN', D=nil, E=nil, F=nil, var=false, dam=IGN*(xE+xHG)} --IGNEHG
				KSK[80]  = {range=Qrange, A='_HG', B='_Q', C='_IGN', D=nil, E=nil, F=nil, var=false, dam=IGN*(xQ+xHG)} --IGNQHG
				KSK[81]  = {range=Erange, A='_E', B='_W', C='_HG', D='_IGN', E=nil, F=nil, var=false, dam=IGN*(xE+xW+xHG)} --IGNEWHG
				KSK[82]  = {range=Wrange, A='_W', B='_HG', C='_Q', D='_IGN', E=nil, F=nil, var=false, dam=IGN*(xW+xQ+xHG)} --IGNWQHG
				KSK[83]  = {range=Erange, A='_E', B='_HG', C='_Q', D='_IGN', E=nil, F=nil, var=false, dam=IGN*(xE+xQ+xHG)} --IGNEQHG
				KSK[84]  = {range=Erange, A='_E', B='_W', C='_HG', D='_Q', E='_IGN', F=nil, var=false, dam=IGN*(xE+xW+xQ+xHG)} --IGNEWQHG
				KSK[85]  = {range=Wrange, A='_DFG', B='_W', C='_IGN', D=nil, E=nil, F=nil, var=false, dam=((IGN*(xW*1.2)+xDFG))*DFG} --IGNWDFG
				KSK[86]  = {range=Erange, A='_DFG', B='_E', C='_IGN', D=nil, E=nil, F=nil, var=false, dam=((IGN*(xE*1.2)+xDFG))*DFG} --IGNEDFG
				KSK[87]  = {range=Qrange, A='_DFG', B='_Q', C='_IGN', D=nil, E=nil, F=nil, var=false, dam=((IGN*(xQ*1.2)+xDFG))*DFG} --IGNQDFG
				KSK[88]  = {range=Erange, A='_DFG', B='_E', C='_W', D='_IGN', E=nil, F=nil, var=false, dam=((IGN*(xE+xW*1.2)+xDFG))*DFG} --IGNEWDFG
				KSK[89]  = {range=Wrange, A='_DFG', B='_W', C='_Q', D='_IGN', E=nil, F=nil, var=false, dam=((IGN*(xW+xQ*1.2)+xDFG))*DFG} --IGNWQDFG
				KSK[90]  = {range=Erange, A='_DFG', B='_E', C='_Q', D='_IGN', E=nil, F=nil, var=false, dam=((IGN*(xE+xQ*1.2)+xDFG))*DFG} --IGNEQDFG
				KSK[91]  = {range=Erange, A='_DFG', B='_E', C='_W', D='_Q', E='_IGN', F=nil, var=false, dam=((IGN*(xE+xW+xQ*1.2)+xDFG))*DFG} --IGNEWQDFG
				KSK[92]  = {range=Wrange, A='_BFT', B='_W', C='_IGN', D=nil, E=nil, F=nil, var=false, dam=((IGN*(xW*1.2)+xBFT))*BFT} --IGNWBFT
				KSK[93]  = {range=Erange, A='_BFT', B='_E', C='_IGN', D=nil, E=nil, F=nil, var=false, dam=((IGN*(xE*1.2)+xBFT))*BFT} --IGNEBFT
				KSK[94]  = {range=Qrange, A='_BFT', B='_Q', C='_IGN', D=nil, E=nil, F=nil, var=false, dam=((IGN*(xQ*1.2)+xBFT))*BFT} --IGNQBFT
				KSK[95]  = {range=Erange, A='_BFT', B='_E', C='_W', D='_IGN', E=nil, F=nil, var=false, dam=((IGN*(xE+xW*1.2)+xBFT))*BFT} --IGNEWBFT
				KSK[96]  = {range=Wrange, A='_BFT', B='_W', C='_Q', D='_IGN', E=nil, F=nil, var=false, dam=((IGN*(xW+xQ*1.2)+xBFT))*BFT} --IGNWQBFT
				KSK[97]  = {range=Erange, A='_BFT', B='_E', C='_Q', D='_IGN', E=nil, F=nil, var=false, dam=((IGN*(xE+xQ*1.2)+xBFT))*BFT} --IGNEQBFT
				KSK[98]  = {range=Erange, A='_BFT', B='_E', C='_W', D='_Q', E='_IGN', F=nil, var=false, dam=((IGN*(xE+xW+xQ*1.2)+xBFT))*BFT} --IGNEWQBFT
				KSK[99]  = {range=Wrange, A='_DFG', B='_W', C='_BC', D='_IGN', E=nil, F=nil, var=false, dam=((IGN*(xW+xBC*1.2)+xDFG))*DFG} --IGNWBCDFG
				KSK[100] = {range=Erange, A='_DFG', B='_E', C='_BC', D='_IGN', E=nil, F=nil, var=false, dam=((IGN*(xE+xBC*1.2)+xDFG))*DFG} --IGNEBCDFG
				KSK[101] = {range=450, A='_DFG', B='_BC', C='_Q', D='_IGN', E=nil, F=nil, var=false, dam=((IGN*(xQ+xBC*1.2)+xDFG))*DFG} --IGNQBCDFG
				KSK[102] = {range=Erange, A='_DFG', B='_E', C='_W', D='_BC', E='_IGN', F=nil, var=false, dam=((IGN*(xE+xW+xBC*1.2)+xDFG))*DFG} --IGNEWBCDFG
				KSK[103] = {range=Wrange, A='_DFG', B='_W', C='_BC', D='_Q', E='_IGN', F=nil, var=false, dam=((IGN*(xW+xQ+xBC*1.2)+xDFG))*DFG} --IGNWQBCDFG
				KSK[104] = {range=Erange, A='_DFG', B='_E', C='_BC', D='_Q', E='_IGN', F=nil, var=false, dam=((IGN*(xE+xQ+xBC*1.2)+xDFG))*DFG} --IGNEQBCDFG
				KSK[105] = {range=Erange, A='_DFG', B='_E', C='_BC', D='_W', E='_Q', F='_IGN', var=false, dam=((IGN*(xE+xW+xQ+xBC*1.2)+xDFG))*DFG} --IGNEWQBCDFG
				KSK[106] = {range=Wrange, A='_BFT', B='_W', C='_BC', D='_IGN', E=nil, F=nil, var=false, dam=((IGN*(xW+xBC*1.2)+xBFT)*BFT)} --IGNWBCBFT
				KSK[107] = {range=Erange, A='_BFT', B='_E', C='_BC', D='_IGN', E=nil, F=nil, var=false, dam=((IGN*(xE+xBC*1.2)+xBFT)*BFT)} --IGNEBCBFT
				KSK[108] = {range=450, A='_BFT', B='_BC', C='_Q', D='_IGN', E=nil, F=nil, var=false, dam=((IGN*(xQ+xBC*1.2)+xBFT))*BFT} --IGNQBCBFT
				KSK[109] = {range=Erange, A='_BFT', B='_E', C='_W', D='_BC', E='_IGN', F=nil, var=false, dam=((IGN*(xE+xW+xBC*1.2)+xBFT))*BFT} --IGNEWBCBFT
				KSK[110] = {range=Wrange, A='_BFT', B='_W', C='_BC', D='_Q', E='_IGN', F=nil, var=false, dam=((IGN*(xW+xQ+xBC*1.2)+xBFT))*BFT} --IGNWQBCBFT
				KSK[111] = {range=Erange, A='_BFT', B='_E', C='_BC', D='_Q', E='_IGN', F=nil, var=false, dam=((IGN*(xE+xQ+xBC*1.2)+xBFT))*BFT} --IGNEQBCBFT
				KSK[112] = {range=Erange, A='_BFT', B='_BC', C='_E', D='_W', E='_Q', F='_IGN', var=false, dam=((IGN*(xE+xW+xQ+xBC*1.2)+xBFT))*BFT} --IGNEWQBCBFT
				KSK[113] = {range=Wrange, A='_DFG', B='_W', C='_HG', D='_IGN', E=nil, F=nil, var=false, dam=((IGN*(xW+xHG*1.2)+xDFG))*DFG} --IGNWHGDFG
				KSK[114] = {range=Erange, A='_DFG', B='_E', C='_HG', D='_IGN', E=nil, F=nil, var=false, dam=((IGN*(xE+xHG*1.2)+xDFG))*DFG} --IGNEHGDFG
				KSK[115] = {range=450, A='_DFG', B='_HG', C='_Q', D='_IGN', E=nil, F=nil, var=false, dam=((IGN*(xQ+xHG*1.2)+xDFG))*DFG} --IGNQHGDFG
				KSK[116] = {range=Erange, A='_DFG', B='_E', C='_W', D='_HG', E='_IGN', F=nil, var=false, dam=((IGN*(xE+xW+xHG*1.2)+xDFG))*DFG} --IGNEWHGDFG
				KSK[117] = {range=Wrange, A='_DFG', B='_W', C='_HG', D='_Q', E='_IGN', F=nil, var=false, dam=((IGN*(xW+xQ+xHG*1.2)+xDFG))*DFG} --IGNWQHGDFG
				KSK[118] = {range=Erange, A='_DFG', B='_E', C='_HG', D='_Q', E='_IGN', F=nil, var=false, dam=((IGN*(xE+xQ+xHG*1.2)+xDFG))*DFG} --IGNEQHGDFG
				KSK[119] = {range=Erange, A='_DFG', B='_E', C='_HG', D='_W', E='_Q', F='_IGN', var=false, dam=((IGN*(xE+xW+xQ+xHG*1.2)+xDFG))*DFG} --IGNEWQHGDFG
				KSK[120] = {range=Wrange, A='_BFT', B=nil, C=nil, D=nil, E=nil, F=nil, var=false, dam=((IGN*(xW+xHG*1.2)+xBFT))*BFT} --IGNWHGBFT
				KSK[121] = {range=Erange, A='_BFT', B='_E', C='_HG', D='_IGN', E=nil, F=nil, var=false, dam=((IGN*(xE+xHG*1.2)+xBFT))*BFT} --IGNEHGBFT
				KSK[122] = {range=450, A='_BFT', B='_HG', C='_Q', D='_IGN', E=nil, F=nil, var=false, dam=((IGN*(xQ+xHG*1.2)+xBFT))*BFT} --IGNQHGBFT
				KSK[123] = {range=Erange, A='_BFT', B='_E', C='_W', D='_HG', E='_IGN', F=nil, var=false, dam=((IGN*(xE+xW+xHG*1.2)+xBFT))*BFT} --IGNEWHGBFT
				KSK[124] = {range=Wrange, A='_BFT', B='_W', C='_HG', D='_Q', E='_IGN', F=nil, var=false, dam=((IGN*(xW+xQ+xHG*1.2)+xBFT))*BFT} --IGNWQHGBFT
				KSK[125] = {range=Erange, A='_BFT', B='_E', C='_HG', D='_Q', E='_IGN', F=nil, var=false, dam=((IGN*(xE+xQ+xHG*1.2)+xBFT))*BFT} --IGNEQHGBFT
				KSK[126] = {range=Erange, A='_BFT', B='_E', C='_HG', D='_W', E='_Q', F='_IGN', var=false, dam=((IGN*(xE+xW+xQ+xHG*1.2)+xBFT))*BFT} --IGNEWQHGBFT
				
				for v=1,126 do
					if GetDistance(enemy)<KSK[v].range and effhealth<KSK[v].dam and MainCFG.Killsteal then KSK[v].var = true end
					if KSK[v].var then 
						Seq(KSK[v].A,KSK[v].B,KSK[v].C,KSK[v].D,KSK[v].E,KSK[v].F,enemy) 
						if enemy.dead==1 or myHero.dead==1 or GetDistance(enemy)>KSK[v].range then KSK[v].var = false end
					end
				end
				for v=1,126 do
					if MainCFG.KSNotes then
						if effhealth<KSK[v].dam then DrawTextObject('KILLSTEAL',enemy,Color.Yellow) end
					end
				end

				if MainCFG.RoamHelper then
					for i, Enemy in pairs(Enemies) do
						if Enemy ~= nil then
							Hero = Enemy.Unit	
							local PositionX = (13.3/16) * GetScreenX()
							local Current_Burst
							local Damage
							local effhealthH = (Hero.health-xIGN)*(1+(((Hero.magicArmor*myHero.magicPenPercent)-myHero.magicPen)/100))
							Current_Burst = Round((xQ+xW+xE+xIGN+BC+HG)+(((xQ+xW+xE+xIGN+BC+HG)/5)*DFG)+(((xQ+xW+xE+xIGN+BC+HG)/5)*BFT)+xDFG+xBFT, 0)
							Current_BurstR = Round((xQ+xW+xE+xR+xIGN+BC+HG)+(((xQ+xW+xE+xR+xIGN+BC+HG)/5)*DFG)+(((xQ+xW+xE+xR+xIGN+BC+HG)/5)*BFT)+xDFG+xBFT, 0)
							Damage = Current_Burst
							DamageR = Current_BurstR
							DrawText("Champion: "..Hero.name, PositionX, ((15/900) * GetScreenY()) * Enemy.Number + ((53/90) * GetScreenY()), Color.SkyBlue)
							if Hero.visible == 1 and Hero.dead ~= 1 then
								if Damage > effhealthH then
									DrawText("KILLABLE", PositionX + 150, ((15/900) * GetScreenY()) * Enemy.Number + ((53/90) * GetScreenY()), Color.Red)	
								elseif DamageR > effhealthH then
									DrawText("KILLABLE (ULT)", PositionX + 150, ((15/900) * GetScreenY()) * Enemy.Number + ((53/90) * GetScreenY()), Color.Red)
								else
									if ((damageH~=0 and damageC==0) or damageH==damageC) then 
										DrawText(math.min(100,Round(damageH*100/Hero.health,0))..'%', PositionX + 150, ((15/900) * GetScreenY()) * Enemy.Number + ((53/90) * GetScreenY()), Color.Yellow)
									elseif damageH~=0 and damageC~=0 and damageH~=damageC then 
										DrawText(math.min(100,Round(damageH*100/Hero.health,0))..'%', PositionX + 150, ((15/900) * GetScreenY()) * Enemy.Number + ((53/90) * GetScreenY()), Color.Yellow)
										DrawText(math.min(100,Round(damageC*100/Hero.health,0))..'%', PositionX + 185, ((15/900) * GetScreenY()) * Enemy.Number + ((53/90) * GetScreenY()), Color.Yellow)
									end
								end
							end
							if Hero.visible == 0 and Hero.dead ~= 1 then
								DrawText("MIA", PositionX + 150, ((15/900) * GetScreenY()) * Enemy.Number + ((53/90) * GetScreenY()), Color.Orange)
							elseif Hero.dead == 1 then
								DrawText("Dead", PositionX + 150, ((15/900) * GetScreenY()) * Enemy.Number + ((53/90) * GetScreenY()), Color.Green)
							end
						end
					end
				end
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
		elseif a~=nil and a == '_A' then Attack(target)
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
		elseif b~=nil and b == '_A' then Attack(target)
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
		elseif c~=nil and c == '_A' then Attack(target)
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
		elseif d~=nil and d == '_A' then Attack(target)
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
		elseif e~=nil and e == '_A' then Attack(target)
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
		elseif f~=nil and f == '_A' then Attack(target)
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

function Items()
	if locus == false and MainCFG.AutoZonyas and myHero.health < myHero.maxHealth*(MainCFG.Zhonyas_Hourglass_Value/100) then 
		UseItemOnTarget(3157,myHero)
		UseItemOnTarget(3090,myHero)
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
	if DodgeCFG.DrawSkillShots == true then
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
			if enemy.name == 'Velkoz' then
				table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 225, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
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

SetTimerCallback('Main')