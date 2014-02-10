require 'Utils'
require 'winapi'
require 'SKeys'
require 'spell_damage'
require 'runrunrun'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local Q,W,E,R = 'Q','W','E','R'
local version = '0.3.3'
----------------------------
local toggle_timer = os.clock()
local locus_timer,dodgetimer = 0,0
local skillshotArray = {}
local xa,xb,ya,yb,cc = 50/1920*GetScreenX(),1870/1920*GetScreenX(),50/1080*GetScreenY(),1030/1080*GetScreenY(),0
local Minions = { }
local MinionsAA = { }
local MinionsQ = { }
local MinionsW = { }
local MinionsE = { }
local SORT_CUSTOM = function(a, b) return a.maxHealth and b.maxHealth and a.maxHealth < b.maxHealth end
---------- CONFIG ----------
local Harass_Mode = 1 -- Harassmode on gamestart [1=Q, 2=WQ, 3=EQ, 4=EWQ, 5=IEWQ
local Combo_Mode = 2 -- Combomode on gamestart [1=EWQR, 2=IEWQR]
local DrawX,DrawY = 70,170 -- X/Y-oordinates of the mode text
local Qrange = 675
local Wrange = 375
local Erange = 700
local Rrange = 550
local basicthickness = 10
local radius = 60
----------------------------

	KeyCFG, menu = uiconfig.add_menu('Hotkey Config', 250)
	menu.keydown('Combo', 'Combo', Keys.X)
	menu.keydown('Harass', 'Harass', Keys.Y)
	menu.keydown('LaneClear', 'LaneClear', Keys.Z)
	
	MainCFG, menu = uiconfig.add_menu('Main Config', 250)
	menu.keydown('HarassMode', 'Change Harass Mode', Keys.F1)
	menu.keydown('ComboMode', 'Change Combo Mode', Keys.F2)
	menu.checkbutton('Killsteal', 'Killsteal', true)
	
	menu.checkbutton('KSNotes', 'Draw KS notes', true)
	menu.checkbutton('MouseMove', 'MouseMove', true)
	menu.checkbutton('StunDraw', 'Draw HardCC', true)
	menu.slider('DetectionRange', 'HardCC Detection Range', 0, 10000, 2500)  
	
	DodgeCFG, menu = uiconfig.add_menu('DodgeSkillshot Config', 250)
	menu.checkbutton('DrawSkillShots', 'Draw Skillshots', true)
	menu.checkbutton('DodgeSkillShots', 'Dodge Skillshots', true)
	menu.checkbutton('DodgeSkillShotsAOE', 'Dodge Skillshots for AOE', true)
	menu.slider('BlockSettings', 'Block user input', 1, 2, 1, {'FixBlock','NoBlock'})
	menu.slider('BlockSettingsAOE', 'Block user input for AOE', 1, 2, 2, {'FixBlock','NoBlock'})
	menu.slider('BlockTime', 'Block imput time', 0, 1000, 750)

function Main()
	if IsLolActive() then
		send.tick()
		GetCD()
		SetVariables()
		CustomCircle(Erange,1,2,myHero)
		HarassModes()
		ComboModes()
		Skillshots()
		if KeyCFG.LaneClear then LaneClear() end
		if MainCFG.StunDraw then StunDraw() end
		if MainCFG.Killsteal then Killsteal() end
		if MainCFG.KSNotes then KSNotes() end
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
	
	cc=cc+1
	if cc==30 then LoadTable() end
	for i=1, #skillshotArray, 1 do
		if os.clock() > (skillshotArray[i].lastshot + skillshotArray[i].time) then
			skillshotArray[i].shot = 0
		end
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
		DrawText('W-Q',DrawX,DrawY,Color.White)
	elseif (Harass_Mode == 3) then
		DrawText('E-Q',DrawX,DrawY,Color.White)
	elseif (Harass_Mode == 4) then
		DrawText('E-W-Q',DrawX,DrawY,Color.White)
	elseif (Harass_Mode == 5) then
		DrawText('I-E-W-Q',DrawX,DrawY,Color.White)
	else
		DrawText("OFF",DrawX,DrawY,Color.White)
		return
	end

	if KeyCFG.Harass and locus==false then
		if Harass_Mode == 1 then Harass_Q()
		elseif Harass_Mode == 2 then Harass_WQ()
		elseif Harass_Mode == 3 then Harass_EQ()
		elseif Harass_Mode == 4 then Harass_EWQ()
		elseif Harass_Mode == 5 then Harass_IEWQ()
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
		DrawText('E-W-Q-R',DrawX,DrawY+30,Color.White)
	elseif (Combo_Mode == 2) then
		DrawText('I-E-W-Q-R',DrawX,DrawY+30,Color.White)
	else
		DrawText("OFF",DrawX,DrawY+30,Color.White)
		return
	end

	if KeyCFG.Combo and locus==false then
		if Combo_Mode == 1 then Combo_EWQR()
		elseif Combo_Mode == 2 then Combo_IEWQR()
		end
		Move()
	end
end

function Harass_Q()
	if target~=nil then
		Qspell(target)
		Attack(target)
	end
end

function Harass_WQ()
	if target~=nil then
		Wspell(target)
		Qspell(target)
		Attack(target)
	end
end

function Harass_EQ()
	if target~=nil then
		Espell(target)
		Qspell(target)
		Attack(target)
	end
end

function Harass_EWQ()
	if target~=nil then
		Espell(target)
		Wspell(target)
		Qspell(target)
		Attack(target)
	end
end

function Harass_IEWQ()
	if target~=nil then
		Ispell(target)
		Espell(target)
		Wspell(target)
		Qspell(target)
		Attack(target)
	end
end
	
function Combo_EWQR()
	if target~=nil then
		Espell(target)
		Wspell(target)
		Qspell(target)
		Rspell(target)
		Attack(target)
	end
end

function Combo_IEWQR()
	if target~=nil then
		Ispell(target)
		Espell(target)
		Wspell(target)
		Qspell(target)
		Rspell(target)
		Attack(target)
	end
end

function LaneClear()
	for i, minion in pairs(Minions) do
		if minion~=nil then
			CustomCircle(75,1,2,minion)
			Qspell(minion)
			Espell(minion)
			Wspell(minion)
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

function IsBuffed(target,name)
    for i = 1, objManager:GetMaxObjects(), 1 do
        obj = objManager:GetObject(i)
        if obj~=nil and target~=nil and string.find(obj.charName,name) and GetDistance(obj, target) < 100 then
			return true
        end
    end
end

function GetCD()
	if myHero.SpellTimeQ > 1 and GetSpellLevel('Q') > 0 then QRDY = 1
	else QRDY = 0 end
	if myHero.SpellTimeW > 1 and GetSpellLevel('W') > 0 then WRDY = 1
	else WRDY = 0 end
	if myHero.SpellTimeE > 1 and GetSpellLevel('E') > 0 then ERDY = 1
	else ERDY = 0 end
	if myHero.SpellTimeR > 1 and GetSpellLevel('R') > 0 then RRDY = 1
	else RRDY = 0 end
end

function OnProcessSpell(unit, spell)
	if unit ~= nil and spell ~= nil and unit.charName == myHero.charName then
		if spell.name == 'KatarinaR' then
			locus = true
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

function Killsteal()
	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if (enemy~=nil and enemy.team~=myHero.team and enemy.visible==1 and enemy.invulnerable==0 and enemy.dead==0) and locus==false then
			local Qdam = ((getDmg('Q',enemy,myHero,1)*QRDY)/100)*95
			local Wdam = ((getDmg('W',enemy,myHero)*WRDY)/100)*95
			local Edam = ((getDmg('E',enemy,myHero)*ERDY)/100)*95
			local Rdam = ((getDmg('R',enemy,myHero,3)*RRDY)/4)*3
			local DFGdam = ((getDmg('DFG',enemy,myHero)*DFG)/100)*95
			local BFTdam = ((getDmg('BLACKFIRE',enemy,myHero)*BFT)/100)*95
			local BCdam = ((getDmg('BWC',enemy,myHero)*BC)/100)*95
			local HGdam = ((getDmg('HXG',enemy,myHero)*HG)/100)*95
			local IGNdam = ((getDmg('IGNITE',enemy,myHero)*IGN)/100)*95
			
			if GetDistance(enemy)<Wrange and enemy.health<Wdam then --W
				Wspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam then --E
				Espell(enemy)
			elseif GetDistance(enemy)<Qrange and enemy.health<Qdam then --Q
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Wdam then --EW
				Espell(enemy)
				Wspell(enemy)
			elseif GetDistance(enemy)<Wrange and enemy.health<Wdam+Qdam then --WQ
				Wspell(enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Qdam then --EQ
				Espell(enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Wdam+Qdam then --EWQ
				Espell(enemy)
				Wspell(enemy)
				Qspell(enemy)
				
			elseif GetDistance(enemy)<Wrange and enemy.health<Wdam+BCdam then --WBC
				Wspell(enemy)
				UseItemOnTarget(3144, enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+BCdam then --EBC
				Espell(enemy)
				UseItemOnTarget(3144, enemy)
			elseif GetDistance(enemy)<450 and enemy.health<Qdam+BCdam then --QBC
				UseItemOnTarget(3144, enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Wdam+BCdam then --EWBC
				Espell(enemy)
				Wspell(enemy)
				UseItemOnTarget(3144, enemy)
			elseif GetDistance(enemy)<Wrange and enemy.health<Wdam+Qdam+BCdam then --WQBC
				Wspell(enemy)
				UseItemOnTarget(3144, enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Qdam+BCdam then --EQBC
				Espell(enemy)
				UseItemOnTarget(3144, enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Wdam+Qdam+BCdam then --EWQBC
				Espell(enemy)
				Wspell(enemy)
				UseItemOnTarget(3144, enemy)
				Qspell(enemy)
				
			elseif GetDistance(enemy)<Wrange and enemy.health<Wdam+HGdam then --WHG
				Wspell(enemy)
				UseItemOnTarget(3146, enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+HGdam then --EHG
				Espell(enemy)
				UseItemOnTarget(3146, enemy)
			elseif GetDistance(enemy)<Qrange and enemy.health<Qdam+HGdam then --QHG
				UseItemOnTarget(3146, enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Wdam+HGdam then --EWHG
				Espell(enemy)
				Wspell(enemy)
				UseItemOnTarget(3146, enemy)
			elseif GetDistance(enemy)<Wrange and enemy.health<Wdam+Qdam+HGdam then --WQHG
				Wspell(enemy)
				UseItemOnTarget(3146, enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Qdam+HGdam then --EQHG
				Espell(enemy)
				UseItemOnTarget(3146, enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Wdam+Qdam+HGdam then --EWQHG
				Espell(enemy)
				Wspell(enemy)
				UseItemOnTarget(3146, enemy)
				Qspell(enemy)
				
			elseif GetDistance(enemy)<Wrange and enemy.health<Wdam+(Wdam/5)+DFGdam then --WDFG
				UseItemOnTarget(3128, enemy)
				Wspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+(Edam/5)+DFGdam then --EDFG
				UseItemOnTarget(3128, enemy)
				Espell(enemy)
			elseif GetDistance(enemy)<Qrange and enemy.health<Qdam+(Qdam/5)+DFGdam then --QDFG
				UseItemOnTarget(3128, enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Wdam+((Edam+Wdam)/5)+DFGdam then --EWDFG
				UseItemOnTarget(3128, enemy)
				Espell(enemy)
				Wspell(enemy)
			elseif GetDistance(enemy)<Wrange and enemy.health<Wdam+Qdam+((Wdam+Qdam)/5)+DFGdam then --WQDFG
				UseItemOnTarget(3128, enemy)
				Wspell(enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Qdam+((Edam+Qdam)/5)+DFGdam then --EQDFG
				UseItemOnTarget(3128, enemy)
				Espell(enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Wdam+Qdam+((Edam+Wdam+Qdam)/5)+DFGdam then --EWQDFG
				UseItemOnTarget(3128, enemy)
				Espell(enemy)
				Wspell(enemy)
				Qspell(enemy)
				
			elseif GetDistance(enemy)<Wrange and enemy.health<Wdam+(Wdam/5)+BFTdam then --WBFT
				UseItemOnTarget(3188, enemy)
				Wspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+(Edam/5)+BFTdam then --EBFT
				UseItemOnTarget(3188, enemy)
				Espell(enemy)
			elseif GetDistance(enemy)<Qrange and enemy.health<Qdam+(Qdam/5)+BFTdam then --QBFT
				UseItemOnTarget(3188, enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Wdam+((Edam+Wdam)/5)+BFTdam then --EWBFT
				UseItemOnTarget(3188, enemy)
				Espell(enemy)
				Wspell(enemy)
			elseif GetDistance(enemy)<Wrange and enemy.health<Wdam+Qdam+((Wdam+Qdam)/5)+BFTdam then --WQBFT
				UseItemOnTarget(3188, enemy)
				Wspell(enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Qdam+((Edam+Qdam)/5)+BFTdam then --EQBFT
				UseItemOnTarget(3188, enemy)
				Espell(enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Wdam+Qdam+((Edam+Wdam+Qdam)/5)+BFTdam then --EWQBFT
				UseItemOnTarget(3188, enemy)
				Espell(enemy)
				Wspell(enemy)
				Qspell(enemy)

			elseif GetDistance(enemy)<Wrange and enemy.health<Wdam+BCdam+((Wdam+BCdam)/5)+DFGdam then --WBCDFG
				UseItemOnTarget(3128, enemy)
				Wspell(enemy)
				UseItemOnTarget(3144, enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+BCdam+((Edam+BCdam)/5)+DFGdam then --EBCDFG
				UseItemOnTarget(3128, enemy)
				Espell(enemy)
				UseItemOnTarget(3144, enemy)
			elseif GetDistance(enemy)<450 and enemy.health<Qdam+BCdam+((Qdam+BCdam)/5)+DFGdam then --QBCDFG
				UseItemOnTarget(3128, enemy)
				UseItemOnTarget(3144, enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Wdam+BCdam+((Edam+Wdam+BCdam)/5)+DFGdam then --EWBCDFG
				UseItemOnTarget(3128, enemy)
				Espell(enemy)
				Wspell(enemy)
				UseItemOnTarget(3144, enemy)
			elseif GetDistance(enemy)<Wrange and enemy.health<Wdam+Qdam+BCdam+((Wdam+Qdam+BCdam)/5)+DFGdam then --WQBCDFG
				UseItemOnTarget(3128, enemy)
				Wspell(enemy)
				UseItemOnTarget(3144, enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Qdam+BCdam+((Edam+Qdam+BCdam)/5)+DFGdam then --EQBCDFG
				UseItemOnTarget(3128, enemy)
				Espell(enemy)
				UseItemOnTarget(3144, enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Wdam+Qdam+BCdam+((Edam+Wdam+Qdam+BCdam)/5)+DFGdam then --EWQBCDFG
				UseItemOnTarget(3128, enemy)
				Espell(enemy)
				Wspell(enemy)
				Qspell(enemy)
				UseItemOnTarget(3144, enemy)
				
			elseif GetDistance(enemy)<Wrange and enemy.health<Wdam+BCdam+((Wdam+BCdam)/5)+BFTdam then --WBCBFT
				UseItemOnTarget(3188, enemy)
				Wspell(enemy)
				UseItemOnTarget(3144, enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+BCdam+((Edam+BCdam)/5)+BFTdam then --EBCBFT
				UseItemOnTarget(3188, enemy)
				Espell(enemy)
				UseItemOnTarget(3144, enemy)
			elseif GetDistance(enemy)<450 and enemy.health<Qdam+BCdam+((Qdam+BCdam)/5)+BFTdam then --QBCBFT
				UseItemOnTarget(3188, enemy)
				UseItemOnTarget(3144, enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Wdam+BCdam+((Edam+Wdam+BCdam)/5)+BFTdam then --EWBCBFT
				UseItemOnTarget(3188, enemy)
				Espell(enemy)
				Wspell(enemy)
				UseItemOnTarget(3144, enemy)
			elseif GetDistance(enemy)<Wrange and enemy.health<Wdam+Qdam+BCdam+((Wdam+Qdam+BCdam)/5)+BFTdam then --WQBCBFT
				UseItemOnTarget(3188, enemy)
				Wspell(enemy)
				UseItemOnTarget(3144, enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Qdam+BCdam+((Edam+Qdam+BCdam)/5)+BFTdam then --EQBCBFT
				UseItemOnTarget(3188, enemy)
				Espell(enemy)
				UseItemOnTarget(3144, enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Wdam+Qdam+BCdam+((Edam+Wdam+Qdam+BCdam)/5)+BFTdam then --EWQBCBFT
				UseItemOnTarget(3188, enemy)
				Espell(enemy)
				Wspell(enemy)
				UseItemOnTarget(3144, enemy)
				Qspell(enemy)
			
			elseif GetDistance(enemy)<Wrange and enemy.health<Wdam+HGdam+((Wdam+HGdam)/5)+DFGdam then --WHGDFG
				UseItemOnTarget(3128, enemy)
				Wspell(enemy)
				UseItemOnTarget(3146, enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+HGdam+((Edam+HGdam)/5)+DFGdam then --EHGDFG
				UseItemOnTarget(3128, enemy)
				Espell(enemy)
				UseItemOnTarget(3146, enemy)
			elseif GetDistance(enemy)<450 and enemy.health<Qdam+HGdam+((Qdam+HGdam)/5)+DFGdam then --QHGDFG
				UseItemOnTarget(3128, enemy)
				UseItemOnTarget(3146, enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Wdam+HGdam+((Edam+Wdam+HGdam)/5)+DFGdam then --EWHGDFG
				UseItemOnTarget(3128, enemy)
				Espell(enemy)
				Wspell(enemy)
				UseItemOnTarget(3146, enemy)
			elseif GetDistance(enemy)<Wrange and enemy.health<Wdam+Qdam+HGdam+((Wdam+Qdam+HGdam)/5)+DFGdam then --WQHGDFG
				UseItemOnTarget(3128, enemy)
				Wspell(enemy)
				UseItemOnTarget(3146, enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Qdam+HGdam+((Edam+Qdam+HGdam)/5)+DFGdam then --EQHGDFG
				UseItemOnTarget(3128, enemy)
				Espell(enemy)
				UseItemOnTarget(3146, enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Wdam+Qdam+HGdam+((Edam+Wdam+Qdam+HGdam)/5)+DFGdam then --EWQHGDFG
				UseItemOnTarget(3128, enemy)
				Espell(enemy)
				Wspell(enemy)
				UseItemOnTarget(3146, enemy)
				Qspell(enemy)
			
			elseif GetDistance(enemy)<Wrange and enemy.health<Wdam+HGdam+((Wdam+HGdam)/5)+BFTdam then --WHGBFT
				UseItemOnTarget(3188, enemy)
				Wspell(enemy)
				UseItemOnTarget(3146, enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+HGdam+((Edam+HGdam)/5)+BFTdam then --EHGBFT
				UseItemOnTarget(3188, enemy)
				Espell(enemy)
				UseItemOnTarget(3146, enemy)
			elseif GetDistance(enemy)<450 and enemy.health<Qdam+HGdam+((Qdam+HGdam)/5)+BFTdam then --QHGBFT
				UseItemOnTarget(3188, enemy)
				UseItemOnTarget(3146, enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Wdam+HGdam+((Edam+Wdam+HGdam)/5)+BFTdam then --EWHGBFT
				UseItemOnTarget(3188, enemy)
				Espell(enemy)
				Wspell(enemy)
				UseItemOnTarget(3146, enemy)
			elseif GetDistance(enemy)<Wrange and enemy.health<Wdam+Qdam+HGdam+((Wdam+Qdam+HGdam)/5)+BFTdam then --WQHGBFT
				UseItemOnTarget(3188, enemy)
				Wspell(enemy)
				UseItemOnTarget(3146, enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Qdam+HGdam+((Edam+Qdam+HGdam)/5)+BFTdam then --EQHGBFT
				UseItemOnTarget(3188, enemy)
				Espell(enemy)
				UseItemOnTarget(3146, enemy)
				Qspell(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<Edam+Wdam+Qdam+HGdam+((Edam+Wdam+Qdam+HGdam)/5)+BFTdam then --EWQHGBFT
				UseItemOnTarget(3188, enemy)
				Espell(enemy)
				UseItemOnTarget(3146, enemy)
				Wspell(enemy)
				Qspell(enemy)
			
			elseif GetDistance(enemy)<Wrange and enemy.health<IGNdam+Wdam then --IGNW
				Wspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam then --IGNE
				Espell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Qrange and enemy.health<IGNdam+Qdam then --IGNQ
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Wdam then --IGNEW
				Espell(enemy)
				CastSummonerIgnite(enemy)
				Wspell(enemy)
			elseif GetDistance(enemy)<Wrange and enemy.health<IGNdam+Wdam+Qdam then --IGNWQ
				Wspell(enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Qdam then --IGNEQ
				Espell(enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Wdam+Qdam then --IGNEWQ
				Espell(enemy)
				Wspell(enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
				
			elseif GetDistance(enemy)<Wrange and enemy.health<IGNdam+Wdam+BCdam then --IGNWBC
				Wspell(enemy)
				UseItemOnTarget(3144, enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+BCdam then --IGNEBC
				Espell(enemy)
				UseItemOnTarget(3144, enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<450 and enemy.health<IGNdam+Qdam+BCdam then --IGNQBC
				UseItemOnTarget(3144, enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Wdam+BCdam then --IGNEWBC
				Espell(enemy)
				Wspell(enemy)
				UseItemOnTarget(3144, enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Wrange and enemy.health<IGNdam+Wdam+Qdam+BCdam then --IGNWQBC
				Wspell(enemy)
				UseItemOnTarget(3144, enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Qdam+BCdam then --IGNEQBC
				Espell(enemy)
				UseItemOnTarget(3144, enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Wdam+Qdam+BCdam then --IGNEWQBC
				Espell(enemy)
				Wspell(enemy)
				UseItemOnTarget(3144, enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
				
			elseif GetDistance(enemy)<Wrange and enemy.health<IGNdam+Wdam+HGdam then --IGNWHG
				Wspell(enemy)
				UseItemOnTarget(3146, enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+HGdam then --IGNEHG
				Espell(enemy)
				UseItemOnTarget(3146, enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Qrange and enemy.health<IGNdam+Qdam+HGdam then --IGNQHG
				UseItemOnTarget(3146, enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Wdam+HGdam then --IGNEWHG
				Espell(enemy)
				Wspell(enemy)
				UseItemOnTarget(3146, enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Wrange and enemy.health<IGNdam+Wdam+Qdam+HGdam then --IGNWQHG
				Wspell(enemy)
				UseItemOnTarget(3146, enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Qdam+HGdam then --IGNEQHG
				Espell(enemy)
				UseItemOnTarget(3146, enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Wdam+Qdam+HGdam then --IGNEWQHG
				Espell(enemy)
				Wspell(enemy)
				UseItemOnTarget(3146, enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
				
			elseif GetDistance(enemy)<Wrange and enemy.health<IGNdam+Wdam+(Wdam/5)+DFGdam then --IGNWDFG
				UseItemOnTarget(3128, enemy)
				Wspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+(Edam/5)+DFGdam then --IGNEDFG
				UseItemOnTarget(3128, enemy)
				Espell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Qrange and enemy.health<IGNdam+Qdam+(Qdam/5)+DFGdam then --IGNQDFG
				UseItemOnTarget(3128, enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Wdam+((Edam+Wdam)/5)+DFGdam then --IGNEWDFG
				UseItemOnTarget(3128, enemy)
				Espell(enemy)
				Wspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Wrange and enemy.health<IGNdam+Wdam+Qdam+((Wdam+Qdam)/5)+DFGdam then --IGNWQDFG
				UseItemOnTarget(3128, enemy)
				Wspell(enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Qdam+((Edam+Qdam)/5)+DFGdam then --IGNEQDFG
				UseItemOnTarget(3128, enemy)
				Espell(enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Wdam+Qdam+((Edam+Wdam+Qdam)/5)+DFGdam then --IGNEWQDFG
				UseItemOnTarget(3128, enemy)
				Espell(enemy)
				Wspell(enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
				
			elseif GetDistance(enemy)<Wrange and enemy.health<IGNdam+Wdam+(Wdam/5)+BFTdam then --IGNWBFT
				UseItemOnTarget(3188, enemy)
				Wspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+(Edam/5)+BFTdam then --IGNEBFT
				UseItemOnTarget(3188, enemy)
				Espell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Qrange and enemy.health<IGNdam+Qdam+(Qdam/5)+BFTdam then --IGNQBFT
				UseItemOnTarget(3188, enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Wdam+((Edam+Wdam)/5)+BFTdam then --IGNEWBFT
				UseItemOnTarget(3188, enemy)
				Espell(enemy)
				Wspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Wrange and enemy.health<IGNdam+Wdam+Qdam+((Wdam+Qdam)/5)+BFTdam then --IGNWQBFT
				UseItemOnTarget(3188, enemy)
				Wspell(enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Qdam+((Edam+Qdam)/5)+BFTdam then --IGNEQBFT
				UseItemOnTarget(3188, enemy)
				Espell(enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Wdam+Qdam+((Edam+Wdam+Qdam)/5)+BFTdam then --IGNEWQBFT
				UseItemOnTarget(3188, enemy)
				Espell(enemy)
				Wspell(enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)

			elseif GetDistance(enemy)<Wrange and enemy.health<IGNdam+Wdam+BCdam+((Wdam+BCdam)/5)+DFGdam then --IGNWBCDFG
				UseItemOnTarget(3128, enemy)
				Wspell(enemy)
				UseItemOnTarget(3144, enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+BCdam+((Edam+BCdam)/5)+DFGdam then --IGNEBCDFG
				UseItemOnTarget(3128, enemy)
				Espell(enemy)
				UseItemOnTarget(3144, enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<450 and enemy.health<IGNdam+Qdam+BCdam+((Qdam+BCdam)/5)+DFGdam then --IGNQBCDFG
				UseItemOnTarget(3128, enemy)
				UseItemOnTarget(3144, enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Wdam+BCdam+((Edam+Wdam+BCdam)/5)+DFGdam then --IGNEWBCDFG
				UseItemOnTarget(3128, enemy)
				Espell(enemy)
				Wspell(enemy)
				UseItemOnTarget(3144, enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Wrange and enemy.health<IGNdam+Wdam+Qdam+BCdam+((Wdam+Qdam+BCdam)/5)+DFGdam then --IGNWQBCDFG
				UseItemOnTarget(3128, enemy)
				Wspell(enemy)
				UseItemOnTarget(3144, enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Qdam+BCdam+((Edam+Qdam+BCdam)/5)+DFGdam then --IGNEQBCDFG
				UseItemOnTarget(3128, enemy)
				Espell(enemy)
				UseItemOnTarget(3144, enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Wdam+Qdam+BCdam+((Edam+Wdam+Qdam+BCdam)/5)+DFGdam then --IGNEWQBCDFG
				UseItemOnTarget(3128, enemy)
				Espell(enemy)
				UseItemOnTarget(3146, enemy)
				Wspell(enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
				
			elseif GetDistance(enemy)<Wrange and enemy.health<IGNdam+Wdam+BCdam+((Wdam+BCdam)/5)+BFTdam then --IGNWBCBFT
				UseItemOnTarget(3188, enemy)
				Wspell(enemy)
				UseItemOnTarget(3144, enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+BCdam+((Edam+BCdam)/5)+BFTdam then --IGNEBCBFT
				UseItemOnTarget(3188, enemy)
				Espell(enemy)
				UseItemOnTarget(3144, enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<450 and enemy.health<IGNdam+Qdam+BCdam+((Qdam+BCdam)/5)+BFTdam then --IGNQBCBFT
				UseItemOnTarget(3188, enemy)
				UseItemOnTarget(3144, enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Wdam+BCdam+((Edam+Wdam+BCdam)/5)+BFTdam then --IGNEWBCBFT
				UseItemOnTarget(3188, enemy)
				Espell(enemy)
				Wspell(enemy)
				UseItemOnTarget(3144, enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Wrange and enemy.health<IGNdam+Wdam+Qdam+BCdam+((Wdam+Qdam+BCdam)/5)+BFTdam then --IGNWQBCBFT
				UseItemOnTarget(3188, enemy)
				Wspell(enemy)
				UseItemOnTarget(3144, enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Qdam+BCdam+((Edam+Qdam+BCdam)/5)+BFTdam then --IGNEQBCBFT
				UseItemOnTarget(3188, enemy)
				Espell(enemy)
				UseItemOnTarget(3144, enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Wdam+Qdam+BCdam+((Edam+Wdam+Qdam+BCdam)/5)+BFTdam then --IGNEWQBCBFT
				UseItemOnTarget(3188, enemy)
				UseItemOnTarget(3144, enemy)
				Espell(enemy)
				Wspell(enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			
			elseif GetDistance(enemy)<Wrange and enemy.health<IGNdam+Wdam+HGdam+((Wdam+HGdam)/5)+DFGdam then --IGNWHGDFG
				UseItemOnTarget(3128, enemy)
				Wspell(enemy)
				UseItemOnTarget(3146, enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+HGdam+((Edam+HGdam)/5)+DFGdam then --IGNEHGDFG
				UseItemOnTarget(3128, enemy)
				Espell(enemy)
				UseItemOnTarget(3146, enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<450 and enemy.health<IGNdam+Qdam+HGdam+((Qdam+HGdam)/5)+DFGdam then --IGNQHGDFG
				UseItemOnTarget(3128, enemy)
				UseItemOnTarget(3146, enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Wdam+HGdam+((Edam+Wdam+HGdam)/5)+DFGdam then --IGNEWHGDFG
				UseItemOnTarget(3128, enemy)
				Espell(enemy)
				Wspell(enemy)
				UseItemOnTarget(3146, enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Wrange and enemy.health<IGNdam+Wdam+Qdam+HGdam+((Wdam+Qdam+HGdam)/5)+DFGdam then --IGNWQHGDFG
				UseItemOnTarget(3128, enemy)
				Wspell(enemy)
				UseItemOnTarget(3146, enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Qdam+HGdam+((Edam+Qdam+HGdam)/5)+DFGdam then --IGNEQHGDFG
				UseItemOnTarget(3128, enemy)
				Espell(enemy)
				UseItemOnTarget(3146, enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Wdam+Qdam+HGdam+((Edam+Wdam+Qdam+HGdam)/5)+DFGdam then --IGNEWQHGDFG
				UseItemOnTarget(3128, enemy)
				Espell(enemy)
				UseItemOnTarget(3146, enemy)
				Wspell(enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			
			elseif GetDistance(enemy)<Wrange and enemy.health<IGNdam+Wdam+HGdam+((Wdam+HGdam)/5)+BFTdam then --IGNWHGBFT
				UseItemOnTarget(3188, enemy)
				Wspell(enemy)
				UseItemOnTarget(3146, enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+HGdam+((Edam+HGdam)/5)+BFTdam then --IGNEHGBFT
				UseItemOnTarget(3188, enemy)
				Espell(enemy)
				UseItemOnTarget(3146, enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<450 and enemy.health<IGNdam+Qdam+HGdam+((Qdam+HGdam)/5)+BFTdam then --IGNQHGBFT
				UseItemOnTarget(3188, enemy)
				UseItemOnTarget(3146, enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Wdam+HGdam+((Edam+Wdam+HGdam)/5)+BFTdam then --IGNEWHGBFT
				UseItemOnTarget(3188, enemy)
				Espell(enemy)
				Wspell(enemy)
				UseItemOnTarget(3146, enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Wrange and enemy.health<IGNdam+Wdam+Qdam+HGdam+((Wdam+Qdam+HGdam)/5)+BFTdam then --IGNWQHGBFT
				UseItemOnTarget(3188, enemy)
				Wspell(enemy)
				UseItemOnTarget(3146, enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Qdam+HGdam+((Edam+Qdam+HGdam)/5)+BFTdam then --IGNEQHGBFT
				UseItemOnTarget(3188, enemy)
				Espell(enemy)
				UseItemOnTarget(3146, enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			elseif GetDistance(enemy)<Erange and enemy.health<IGNdam+Edam+Wdam+Qdam+HGdam+((Edam+Wdam+Qdam+HGdam)/5)+BFTdam then --IGNEWQHGBFT
				UseItemOnTarget(3188, enemy)
				Espell(enemy)
				Wspell(enemy)
				Qspell(enemy)
				CastSummonerIgnite(enemy)
			end
		end
	end
end
			
function KSNotes()
	for i = 1, objManager:GetMaxHeroes() do
		local enemy4 = objManager:GetHero(i)
		if (enemy4~=nil and enemy4.team~=myHero.team and enemy4.visible==1 and enemy4.invulnerable==0 and enemy4.dead==0) and locus==false then
			local Qdam = ((getDmg('Q',enemy4,myHero,1)*QRDY)/100)*95
			local Wdam = ((getDmg('W',enemy4,myHero)*WRDY)/100)*95
			local Edam = ((getDmg('E',enemy4,myHero)*ERDY)/100)*95
			local Rdam = ((getDmg('R',enemy4,myHero,3)*RRDY)/100)*95
			local DFGdam = ((getDmg('DFG',enemy4,myHero)*DFG)/100)*95
			local BFTdam = ((getDmg('BLACKFIRE',enemy4,myHero)*BFT)/100)*95
			local BCdam = ((getDmg('BWC',enemy4,myHero)*BC)/100)*95
			local HGdam = ((getDmg('HXG',enemy4,myHero)*HG)/100)*95
			local IGNdam = ((getDmg('IGNITE',enemy4,myHero)*IGN)/100)*95
			
			if 	((enemy4.health<Wdam) or --W
				(enemy4.health<Edam) or --E
				(enemy4.health<Qdam) or --Q
				(enemy4.health<Edam+Wdam) or --EW
				(enemy4.health<Wdam+Qdam) or --WQ
				(enemy4.health<Edam+Qdam) or --EQ
				(enemy4.health<Edam+Wdam+Qdam) or --EWQ
				(enemy4.health<Wdam+BCdam) or --WBC
				(enemy4.health<Edam+BCdam) or --EBC
				(enemy4.health<Qdam+BCdam) or --QBC
				(enemy4.health<Edam+Wdam+BCdam) or --EWBC
				(enemy4.health<Wdam+Qdam+BCdam) or --WQBC
				(enemy4.health<Edam+Qdam+BCdam) or --EQBC
				(enemy4.health<Edam+Wdam+Qdam+BCdam) or --EWQBC
				(enemy4.health<Wdam+HGdam) or --WHG
				(enemy4.health<Edam+HGdam) or --EHG
				(enemy4.health<Qdam+HGdam) or --QHG
				(enemy4.health<Edam+Wdam+HGdam) or --EWHG
				(enemy4.health<Wdam+Qdam+HGdam) or --WQHG
				(enemy4.health<Edam+Qdam+HGdam) or --EQHG
				(enemy4.health<Edam+Wdam+Qdam+HGdam) or --EWQHG
				(enemy4.health<Wdam+(Wdam/5)+DFGdam) or --WDFG
				(enemy4.health<Edam+(Edam/5)+DFGdam) or --EDFG
				(enemy4.health<Qdam+(Qdam/5)+DFGdam) or --QDFG
				(enemy4.health<Edam+Wdam+((Edam+Wdam)/5)+DFGdam) or --EWDFG
				(enemy4.health<Wdam+Qdam+((Wdam+Qdam)/5)+DFGdam) or --WQDFG
				(enemy4.health<Edam+Qdam+((Edam+Qdam)/5)+DFGdam) or --EQDFG
				(enemy4.health<Edam+Wdam+Qdam+((Edam+Wdam+Qdam)/5)+DFGdam) or --EWQDFG
				(enemy4.health<Wdam+(Wdam/5)+BFTdam) or --WBFT
				(enemy4.health<Edam+(Edam/5)+BFTdam) or --EBFT
				(enemy4.health<Qdam+(Qdam/5)+BFTdam) or --QBFT
				(enemy4.health<Edam+Wdam+((Edam+Wdam)/5)+BFTdam) or --EWBFT
				(enemy4.health<Wdam+Qdam+((Wdam+Qdam)/5)+BFTdam) or --WQBFT
				(enemy4.health<Edam+Qdam+((Edam+Qdam)/5)+BFTdam) or --EQBFT
				(enemy4.health<Edam+Wdam+Qdam+((Edam+Wdam+Qdam)/5)+BFTdam) or --EWQBFT
				(enemy4.health<Wdam+BCdam+((Wdam+BCdam)/5)+DFGdam) or --WBCDFG
				(enemy4.health<Edam+BCdam+((Edam+BCdam)/5)+DFGdam) or --EBCDFG
				(enemy4.health<Qdam+BCdam+((Qdam+BCdam)/5)+DFGdam) or --QBCDFG
				(enemy4.health<Edam+Wdam+BCdam+((Edam+Wdam+BCdam)/5)+DFGdam) or --EWBCDFG
				(enemy4.health<Wdam+Qdam+BCdam+((Wdam+Qdam+BCdam)/5)+DFGdam) or --WQBCDFG
				(enemy4.health<Edam+Qdam+BCdam+((Edam+Qdam+BCdam)/5)+DFGdam) or --EQBCDFG
				(enemy4.health<Edam+Wdam+Qdam+BCdam+((Edam+Wdam+Qdam+BCdam)/5)+DFGdam) or --EWQBCDFG
				(enemy4.health<Wdam+BCdam+((Wdam+BCdam)/5)+BFTdam) or --WBCBFT
				(enemy4.health<Edam+BCdam+((Edam+BCdam)/5)+BFTdam) or --EBCBFT
				(enemy4.health<Qdam+BCdam+((Qdam+BCdam)/5)+BFTdam) or --QBCBFT
				(enemy4.health<Edam+Wdam+BCdam+((Edam+Wdam+BCdam)/5)+BFTdam) or --EWBCBFT
				(enemy4.health<Wdam+Qdam+BCdam+((Wdam+Qdam+BCdam)/5)+BFTdam) or --WQBCBFT
				(enemy4.health<Edam+Qdam+BCdam+((Edam+Qdam+BCdam)/5)+BFTdam) or --EQBCBFT
				(enemy4.health<Edam+Wdam+Qdam+BCdam+((Edam+Wdam+Qdam+BCdam)/5)+BFTdam) or --EWQBCBFT
				(enemy4.health<Wdam+HGdam+((Wdam+HGdam)/5)+DFGdam) or --WHGDFG
				(enemy4.health<Edam+HGdam+((Edam+HGdam)/5)+DFGdam) or --EHGDFG
				(enemy4.health<Qdam+HGdam+((Qdam+HGdam)/5)+DFGdam) or --QHGDFG
				(enemy4.health<Edam+Wdam+HGdam+((Edam+Wdam+HGdam)/5)+DFGdam) or --EWHGDFG
				(enemy4.health<Wdam+Qdam+HGdam+((Wdam+Qdam+HGdam)/5)+DFGdam) or --WQHGDFG
				(enemy4.health<Edam+Qdam+HGdam+((Edam+Qdam+HGdam)/5)+DFGdam) or --EQHGDFG
				(enemy4.health<Edam+Wdam+Qdam+HGdam+((Edam+Wdam+Qdam+HGdam)/5)+DFGdam) or --EWQHGDFG
				(enemy4.health<Wdam+HGdam+((Wdam+HGdam)/5)+BFTdam) or --WHGBFT
				(enemy4.health<Edam+HGdam+((Edam+HGdam)/5)+BFTdam) or --EHGBFT
				(enemy4.health<Qdam+HGdam+((Qdam+HGdam)/5)+BFTdam) or --QHGBFT
				(enemy4.health<Edam+Wdam+HGdam+((Edam+Wdam+HGdam)/5)+BFTdam) or --EWHGBFT
				(enemy4.health<Wdam+Qdam+HGdam+((Wdam+Qdam+HGdam)/5)+BFTdam) or --WQHGBFT
				(enemy4.health<Edam+Qdam+HGdam+((Edam+Qdam+HGdam)/5)+BFTdam) or --EQHGBFT
				(enemy4.health<Edam+Wdam+Qdam+HGdam+((Edam+Wdam+Qdam+HGdam)/5)+BFTdam) or --EWQHGBFT
				(enemy4.health<IGNdam+Wdam) or --IGNW
				(enemy4.health<IGNdam+Edam) or --IGNE
				(enemy4.health<IGNdam+Qdam) or --IGNQ
				(enemy4.health<IGNdam+Edam+Wdam) or --IGNEW
				(enemy4.health<IGNdam+Wdam+Qdam) or --IGNWQ
				(enemy4.health<IGNdam+Edam+Qdam) or --IGNEQ
				(enemy4.health<IGNdam+Edam+Wdam+Qdam) or --IGNEWQ
				(enemy4.health<IGNdam+Wdam+BCdam) or --IGNWBC
				(enemy4.health<IGNdam+Edam+BCdam) or --IGNEBC
				(enemy4.health<IGNdam+Qdam+BCdam) or --IGNQBC
				(enemy4.health<IGNdam+Edam+Wdam+BCdam) or --IGNEWBC
				(enemy4.health<IGNdam+Wdam+Qdam+BCdam) or --IGNWQBC
				(enemy4.health<IGNdam+Edam+Qdam+BCdam) or --IGNEQBC
				(enemy4.health<IGNdam+Edam+Wdam+Qdam+BCdam) or --IGNEWQBC
				(enemy4.health<IGNdam+Wdam+HGdam) or --IGNWHG
				(enemy4.health<IGNdam+Edam+HGdam) or --IGNEHG
				(enemy4.health<IGNdam+Qdam+HGdam) or --IGNQHG
				(enemy4.health<IGNdam+Edam+Wdam+HGdam) or --IGNEWHG
				(enemy4.health<IGNdam+Wdam+Qdam+HGdam) or --IGNWQHG
				(enemy4.health<IGNdam+Edam+Qdam+HGdam) or --IGNEQHG
				(enemy4.health<IGNdam+Edam+Wdam+Qdam+HGdam) or --IGNEWQHG
				(enemy4.health<IGNdam+Wdam+(Wdam/5)+DFGdam) or --IGNWDFG
				(enemy4.health<IGNdam+Edam+(Edam/5)+DFGdam) or --IGNEDFG
				(enemy4.health<IGNdam+Qdam+(Qdam/5)+DFGdam) or --IGNQDFG
				(enemy4.health<IGNdam+Edam+Wdam+((Edam+Wdam)/5)+DFGdam) or --IGNEWDFG
				(enemy4.health<IGNdam+Wdam+Qdam+((Wdam+Qdam)/5)+DFGdam) or --IGNWQDFG
				(enemy4.health<IGNdam+Edam+Qdam+((Edam+Qdam)/5)+DFGdam) or --IGNEQDFG
				(enemy4.health<IGNdam+Edam+Wdam+Qdam+((Edam+Wdam+Qdam)/5)+DFGdam) or --IGNEWQDFG
				(enemy4.health<IGNdam+Wdam+(Wdam/5)+BFTdam) or --IGNWBFT
				(enemy4.health<IGNdam+Edam+(Edam/5)+BFTdam) or --IGNEBFT
				(enemy4.health<IGNdam+Qdam+(Qdam/5)+BFTdam) or --IGNQBFT
				(enemy4.health<IGNdam+Edam+Wdam+((Edam+Wdam)/5)+BFTdam) or --IGNEWBFT
				(enemy4.health<IGNdam+Wdam+Qdam+((Wdam+Qdam)/5)+BFTdam) or --IGNWQBFT
				(enemy4.health<IGNdam+Edam+Qdam+((Edam+Qdam)/5)+BFTdam) or --IGNEQBFT
				(enemy4.health<IGNdam+Edam+Wdam+Qdam+((Edam+Wdam+Qdam)/5)+BFTdam) or --IGNEWQBFT
				(enemy4.health<IGNdam+Wdam+BCdam+((Wdam+BCdam)/5)+DFGdam) or --IGNWBCDFG
				(enemy4.health<IGNdam+Edam+BCdam+((Edam+BCdam)/5)+DFGdam) or --IGNEBCDFG
				(enemy4.health<IGNdam+Qdam+BCdam+((Qdam+BCdam)/5)+DFGdam) or --IGNQBCDFG
				(enemy4.health<IGNdam+Edam+Wdam+BCdam+((Edam+Wdam+BCdam)/5)+DFGdam) or --IGNEWBCDFG
				(enemy4.health<IGNdam+Wdam+Qdam+BCdam+((Wdam+Qdam+BCdam)/5)+DFGdam) or --IGNWQBCDFG
				(enemy4.health<IGNdam+Edam+Qdam+BCdam+((Edam+Qdam+BCdam)/5)+DFGdam) or --IGNEQBCDFG
				(enemy4.health<IGNdam+Edam+Wdam+Qdam+BCdam+((Edam+Wdam+Qdam+BCdam)/5)+DFGdam) or --IGNEWQBCDFG
				(enemy4.health<IGNdam+Wdam+BCdam+((Wdam+BCdam)/5)+BFTdam) or --IGNWBCBFT
				(enemy4.health<IGNdam+Edam+BCdam+((Edam+BCdam)/5)+BFTdam) or --IGNEBCBFT
				(enemy4.health<IGNdam+Qdam+BCdam+((Qdam+BCdam)/5)+BFTdam) or --IGNQBCBFT
				(enemy4.health<IGNdam+Edam+Wdam+BCdam+((Edam+Wdam+BCdam)/5)+BFTdam) or --IGNEWBCBFT
				(enemy4.health<IGNdam+Wdam+Qdam+BCdam+((Wdam+Qdam+BCdam)/5)+BFTdam) or --IGNWQBCBFT
				(enemy4.health<IGNdam+Edam+Qdam+BCdam+((Edam+Qdam+BCdam)/5)+BFTdam) or --IGNEQBCBFT
				(enemy4.health<IGNdam+Edam+Wdam+Qdam+BCdam+((Edam+Wdam+Qdam+BCdam)/5)+BFTdam) or --IGNEWQBCBFT
				(enemy4.health<IGNdam+Wdam+HGdam+((Wdam+HGdam)/5)+DFGdam) or --IGNWHGDFG
				(enemy4.health<IGNdam+Edam+HGdam+((Edam+HGdam)/5)+DFGdam) or --IGNEHGDFG
				(enemy4.health<IGNdam+Qdam+HGdam+((Qdam+HGdam)/5)+DFGdam) or --IGNQHGDFG
				(enemy4.health<IGNdam+Edam+Wdam+HGdam+((Edam+Wdam+HGdam)/5)+DFGdam) or --IGNEWHGDFG
				(enemy4.health<IGNdam+Wdam+Qdam+HGdam+((Wdam+Qdam+HGdam)/5)+DFGdam) or --IGNWQHGDFG
				(enemy4.health<IGNdam+Edam+Qdam+HGdam+((Edam+Qdam+HGdam)/5)+DFGdam) or --IGNEQHGDFG
				(enemy4.health<IGNdam+Edam+Wdam+Qdam+HGdam+((Edam+Wdam+Qdam+HGdam)/5)+DFGdam) or --IGNEWQHGDFG
				(enemy4.health<IGNdam+Wdam+HGdam+((Wdam+HGdam)/5)+BFTdam) or --IGNWHGBFT
				(enemy4.health<IGNdam+Edam+HGdam+((Edam+HGdam)/5)+BFTdam) or --IGNEHGBFT
				(enemy4.health<IGNdam+Qdam+HGdam+((Qdam+HGdam)/5)+BFTdam) or --IGNQHGBFT
				(enemy4.health<IGNdam+Edam+Wdam+HGdam+((Edam+Wdam+HGdam)/5)+BFTdam) or --IGNEWHGBFT
				(enemy4.health<IGNdam+Wdam+Qdam+HGdam+((Wdam+Qdam+HGdam)/5)+BFTdam) or --IGNWQHGBFT
				(enemy4.health<IGNdam+Edam+Qdam+HGdam+((Edam+Qdam+HGdam)/5)+BFTdam) or --IGNEQHGBFT
				(enemy4.health<IGNdam+Edam+Wdam+Qdam+HGdam+((Edam+Wdam+Qdam+HGdam)/5)+BFTdam)) then --IGNEWQHGBFT
				DrawTextObject('KILLSTEAL',enemy4,Color.Yellow)
		--[[elseif 	((GetDistance(enemy4)<Wrange and enemy4.health<Rdam+Wdam) or --RW
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam) or --RE
				(GetDistance(enemy4)<450 and enemy4.health<Rdam+Qdam) or --RQ
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Wdam) or --REW
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+Wdam+Qdam) or --RWQ
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Qdam) or --REQ
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Wdam+Qdam) or --REWQ
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+Wdam+BCdam) or --RWBC
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+BCdam) or --REBC
				(GetDistance(enemy4)<450 and enemy4.health<Rdam+Qdam+BCdam) or --RQBC
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Wdam+BCdam) or --REWBC
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+Wdam+Qdam+BCdam) or --RWQBC
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Qdam+BCdam) or --REQBC
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Wdam+Qdam+BCdam) or --REWQBC
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+Wdam+HGdam) or --RWHG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+HGdam) or --REHG
				(GetDistance(enemy4)<450 and enemy4.health<Rdam+Qdam+HGdam) or --RQHG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Wdam+HGdam) or --REWHG
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+Wdam+Qdam+HGdam) or --RWQHG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Qdam+HGdam) or --REQHG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Wdam+Qdam+HGdam) or --REWQHG
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+Wdam+((Wdam+Rdam+Rdam)/5)+DFGdam) or --RWDFG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+((Edam+Rdam+Rdam)/5)+DFGdam) or --REDFG
				(GetDistance(enemy4)<450 and enemy4.health<Rdam+Qdam+((Qdam+Rdam)/5)+DFGdam) or --RQDFG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Wdam+((Edam+Wdam+Rdam)/5)+DFGdam) or --REWDFG
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+Wdam+Qdam+((Wdam+Qdam+Rdam)/5)+DFGdam) or --RWQDFG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Qdam+((Edam+Qdam+Rdam)/5)+DFGdam) or --REQDFG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Wdam+Qdam+((Edam+Wdam+Qdam+Rdam)/5)+DFGdam) or --REWQDFG
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+Wdam+((Wdam+Rdam+Rdam)/5)+BFTdam) or --RWBFT
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+((Edam+Rdam+Rdam)/5)+BFTdam) or --REBFT
				(GetDistance(enemy4)<450 and enemy4.health<Rdam+Qdam+((Qdam+Rdam+Rdam)/5)+BFTdam) or --RQBFT
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Wdam+((Edam+Wdam+Rdam)/5)+BFTdam) or --REWBFT
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+Wdam+Qdam+((Wdam+Qdam+Rdam)/5)+BFTdam) or --RWQBFT
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Qdam+((Edam+Qdam+Rdam)/5)+BFTdam) or --REQBFT
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Wdam+Qdam+((Edam+Wdam+Qdam+Rdam)/5)+BFTdam) or --REWQBFT
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+Wdam+BCdam+((Wdam+BCdam+Rdam)/5)+DFGdam) or --RWBCDFG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+BCdam+((Edam+BCdam+Rdam)/5)+DFGdam) or --REBCDFG
				(GetDistance(enemy4)<450 and enemy4.health<Rdam+Qdam+BCdam+((Qdam+BCdam+Rdam)/5)+DFGdam) or --RQBCDFG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Wdam+BCdam+((Edam+Wdam+BCdam+Rdam)/5)+DFGdam) or --REWBCDFG
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+Wdam+Qdam+BCdam+((Wdam+Qdam+BCdam+Rdam)/5)+DFGdam) or --RWQBCDFG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Qdam+BCdam+((Edam+Qdam+BCdam+Rdam)/5)+DFGdam) or --REQBCDFG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Wdam+Qdam+BCdam+((Edam+Wdam+Qdam+BCdam+Rdam)/5)+DFGdam) or --REWQBCDFG
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+Wdam+BCdam+((Wdam+BCdam+Rdam)/5)+BFTdam) or --RWBCBFT
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+BCdam+((Edam+BCdam+Rdam)/5)+BFTdam) or --REBCBFT
				(GetDistance(enemy4)<450 and enemy4.health<Rdam+Qdam+BCdam+((Qdam+BCdam+Rdam)/5)+BFTdam) or --RQBCBFT
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Wdam+BCdam+((Edam+Wdam+BCdam+Rdam)/5)+BFTdam) or --REWBCBFT
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+Wdam+Qdam+BCdam+((Wdam+Qdam+BCdam+Rdam)/5)+BFTdam) or --RWQBCBFT
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Qdam+BCdam+((Edam+Qdam+BCdam+Rdam)/5)+BFTdam) or --REQBCBFT
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Wdam+Qdam+BCdam+((Edam+Wdam+Qdam+BCdam+Rdam)/5)+BFTdam) or --REWQBCBFT
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+Wdam+HGdam+((Wdam+HGdam+Rdam)/5)+DFGdam) or --RWHGDFG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+HGdam+((Edam+HGdam+Rdam)/5)+DFGdam) or --REHGDFG
				(GetDistance(enemy4)<450 and enemy4.health<Rdam+Qdam+HGdam+((Qdam+HGdam+Rdam)/5)+DFGdam) or --RQHGDFG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Wdam+HGdam+((Edam+Wdam+HGdam+Rdam)/5)+DFGdam) or --REWHGDFG
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+Wdam+Qdam+HGdam+((Wdam+Qdam+HGdam+Rdam)/5)+DFGdam) or --RWQHGDFG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Qdam+HGdam+((Edam+Qdam+HGdam+Rdam)/5)+DFGdam) or --REQHGDFG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Wdam+Qdam+HGdam+((Edam+Wdam+Qdam+HGdam+Rdam)/5)+DFGdam) or --REWQHGDFG
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+Wdam+HGdam+((Wdam+HGdam+Rdam)/5)+BFTdam) or --RWHGBFT
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+HGdam+((Edam+HGdam+Rdam)/5)+BFTdam) or --REHGBFT
				(GetDistance(enemy4)<450 and enemy4.health<Rdam+Qdam+HGdam+((Qdam+HGdam+Rdam)/5)+BFTdam) or --RQHGBFT
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Wdam+HGdam+((Edam+Wdam+HGdam+Rdam)/5)+BFTdam) or --REWHGBFT
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+Wdam+Qdam+HGdam+((Wdam+Qdam+HGdam+Rdam)/5)+BFTdam) or --RWQHGBFT
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Qdam+HGdam+((Edam+Qdam+HGdam+Rdam)/5)+BFTdam) or --REQHGBFT
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+Edam+Wdam+Qdam+HGdam+((Edam+Wdam+Qdam+HGdam+Rdam)/5)+BFTdam) or --REWQHGBFT
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+IGNdam+Wdam) or --RIGNW
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam) or --RIGNE
				(GetDistance(enemy4)<450 and enemy4.health<Rdam+IGNdam+Qdam) or --RIGNQ
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Wdam) or --RIGNEW
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+IGNdam+Wdam+Qdam) or --RIGNWQ
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Qdam) or --RIGNEQ
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Wdam+Qdam) or --RIGNEWQ
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+IGNdam+Wdam+BCdam) or --RIGNWBC
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+BCdam) or --RIGNEBC
				(GetDistance(enemy4)<450 and enemy4.health<Rdam+IGNdam+Qdam+BCdam) or --RIGNQBC
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Wdam+BCdam) or --RIGNEWBC
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+IGNdam+Wdam+Qdam+BCdam) or --RIGNWQBC
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Qdam+BCdam) or --RIGNEQBC
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Wdam+Qdam+BCdam) or --RIGNEWQBC
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+IGNdam+Wdam+HGdam) or --RIGNWHG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+HGdam) or --RIGNEHG
				(GetDistance(enemy4)<450 and enemy4.health<Rdam+IGNdam+Qdam+HGdam) or --RIGNQHG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Wdam+HGdam) or --RIGNEWHG
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+IGNdam+Wdam+Qdam+HGdam) or --RIGNWQHG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Qdam+HGdam) or --RIGNEQHG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Wdam+Qdam+HGdam) or --RIGNEWQHG
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+IGNdam+Wdam+(Wdam/5)+DFGdam) or --RIGNWDFG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+(Edam/5)+DFGdam) or --RIGNEDFG
				(GetDistance(enemy4)<450 and enemy4.health<Rdam+IGNdam+Qdam+(Qdam/5)+DFGdam) or --RIGNQDFG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Wdam+((Edam+Wdam+Rdam)/5)+DFGdam) or --RIGNEWDFG
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+IGNdam+Wdam+Qdam+((Wdam+Qdam+Rdam)/5)+DFGdam) or --RIGNWQDFG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Qdam+((Edam+Qdam+Rdam)/5)+DFGdam) or --RIGNEQDFG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Wdam+Qdam+((Edam+Wdam+Qdam+Rdam)/5)+DFGdam) or --RIGNEWQDFG
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+IGNdam+Wdam+(Wdam/5)+BFTdam) or --RIGNWBFT
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+(Edam/5)+BFTdam) or --RIGNEBFT
				(GetDistance(enemy4)<450 and enemy4.health<Rdam+IGNdam+Qdam+(Qdam/5)+BFTdam) or --RIGNQBFT
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Wdam+((Edam+Wdam+Rdam)/5)+BFTdam) or --RIGNEWBFT
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+IGNdam+Wdam+Qdam+((Wdam+Qdam+Rdam)/5)+BFTdam) or --RIGNWQBFT
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Qdam+((Edam+Qdam+Rdam)/5)+BFTdam) or --RIGNEQBFT
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Wdam+Qdam+((Edam+Wdam+Qdam+Rdam)/5)+BFTdam) or --RIGNEWQBFT
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+IGNdam+Wdam+BCdam+((Wdam+BCdam+Rdam)/5)+DFGdam) or --RIGNWBCDFG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+BCdam+((Edam+BCdam+Rdam)/5)+DFGdam) or --RIGNEBCDFG
				(GetDistance(enemy4)<450 and enemy4.health<Rdam+IGNdam+Qdam+BCdam+((Qdam+BCdam+Rdam)/5)+DFGdam) or --RIGNQBCDFG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Wdam+BCdam+((Edam+Wdam+BCdam+Rdam)/5)+DFGdam) or --RIGNEWBCDFG
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+IGNdam+Wdam+Qdam+BCdam+((Wdam+Qdam+BCdam+Rdam)/5)+DFGdam) or --RIGNWQBCDFG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Qdam+BCdam+((Edam+Qdam+BCdam+Rdam)/5)+DFGdam) or --RIGNEQBCDFG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Wdam+Qdam+BCdam+((Edam+Wdam+Qdam+BCdam+Rdam)/5)+DFGdam) or --RIGNEWQBCDFG
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+IGNdam+Wdam+BCdam+((Wdam+BCdam+Rdam)/5)+BFTdam) or --RIGNWBCBFT
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+BCdam+((Edam+BCdam+Rdam)/5)+BFTdam) or --RIGNEBCBFT
				(GetDistance(enemy4)<450 and enemy4.health<Rdam+IGNdam+Qdam+BCdam+((Qdam+BCdam+Rdam)/5)+BFTdam) or --RIGNQBCBFT
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Wdam+BCdam+((Edam+Wdam+BCdam+Rdam)/5)+BFTdam) or --RIGNEWBCBFT
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+IGNdam+Wdam+Qdam+BCdam+((Wdam+Qdam+BCdam+Rdam)/5)+BFTdam) or --RIGNWQBCBFT
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Qdam+BCdam+((Edam+Qdam+BCdam+Rdam)/5)+BFTdam) or --RIGNEQBCBFT
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Wdam+Qdam+BCdam+((Edam+Wdam+Qdam+BCdam+Rdam)/5)+BFTdam) or --RIGNEWQBCBFT
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+IGNdam+Wdam+HGdam+((Wdam+HGdam+Rdam)/5)+DFGdam) or --RIGNWHGDFG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+HGdam+((Edam+HGdam+Rdam)/5)+DFGdam) or --RIGNEHGDFG
				(GetDistance(enemy4)<450 and enemy4.health<Rdam+IGNdam+Qdam+HGdam+((Qdam+HGdam+Rdam)/5)+DFGdam) or --RIGNQHGDFG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Wdam+HGdam+((Edam+Wdam+HGdam+Rdam)/5)+DFGdam) or --RIGNEWHGDFG	
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+IGNdam+Wdam+Qdam+HGdam+((Wdam+Qdam+HGdam+Rdam)/5)+DFGdam) or --RIGNWQHGDFG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Qdam+HGdam+((Edam+Qdam+HGdam+Rdam)/5)+DFGdam) or --RIGNEQHGDFG
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Wdam+Qdam+HGdam+((Edam+Wdam+Qdam+HGdam+Rdam)/5)+DFGdam) or --RIGNEWQHGDFG
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+IGNdam+Wdam+HGdam+((Wdam+HGdam+Rdam)/5)+BFTdam) or --RIGNWHGBFT	
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+HGdam+((Edam+HGdam+Rdam)/5)+BFTdam) or --RIGNEHGBFT	
				(GetDistance(enemy4)<450 and enemy4.health<Rdam+IGNdam+Qdam+HGdam+((Qdam+HGdam+Rdam)/5)+BFTdam) or --RIGNQHGBFT
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Wdam+HGdam+((Edam+Wdam+HGdam+Rdam)/5)+BFTdam) or --RIGNEWHGBFT
				(GetDistance(enemy4)<Wrange and enemy4.health<Rdam+IGNdam+Wdam+Qdam+HGdam+((Wdam+Qdam+HGdam+Rdam)/5)+BFTdam) or --RIGNWQHGBFT
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Qdam+HGdam+((Edam+Qdam+HGdam+Rdam)/5)+BFTdam) or --RIGNEQHGBFT
				(GetDistance(enemy4)<Erange and enemy4.health<Rdam+IGNdam+Edam+Wdam+Qdam+HGdam+((Edam+Wdam+Qdam+HGdam+Rdam)/5)+BFTdam)) then --RIGNEWQHGBFT
				DrawTextObject('QWER KILL',enemy4,Color.Red)]]
			end
		end
	end
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

function StunDraw()
	local stunChamps = 0
	local amountCC = 0
	for i = 1, objManager:GetMaxHeroes()  do
	local enemie = objManager:GetHero(i)
		if (enemie ~= nil and enemie.team ~= myHero.team and enemie.visible == 1 and enemie.dead == 0) and GetDistance(myHero,enemie) < MainCFG.DetectionRange then
			local targetCC = GetTargetCC("HardCC",enemie)
			if targetCC > 0 then
				stunChamps = stunChamps+1
				amountCC = amountCC+targetCC
				if enemie.visible then
					thickness = basicthickness*targetCC
					for j=1, thickness do
						local ycircle = (j*(radius/thickness*2)-radius)
						local r = math.sqrt(radius^2-ycircle^2)
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

SetTimerCallback('Main')