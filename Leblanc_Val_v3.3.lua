require 'Utils'
require 'winapi'
require 'SKeys'
require 'vals_lib'
require 'runrunrun'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local version = '3.3'
local cc,ls,dodgetimer = 0,0,0
local Jcoord = {}
local KSN = {}
local HNS = {}

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
	menu.checkbutton('MouseMove', 'MouseMove', false)
	menu.checkbutton('jumphelper', 'JumpHelper', false)
	menu.checkbutton('DrawCircles', 'DrawCircles', true)
	menu.slider('TargetSelector', 'TargetSelector', 1, 3, 2, {'Loose','Soft','Hard'})
	menu.slider('Emultiplier', 'E proc multiplier', 1, 2, 1)
	
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
		CheckItemCD()
		Skillshots()
		Distance()
		SpellSequence()
		Jump()
		ReturnPad()
	end 
end

function SpellSequence()
	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if enemy~=nil and enemy.team~=myHero.team and enemy.visible==1 and enemy.invulnerable==0 and enemy.dead==0 then
			EPos = Vector(enemy.x,0,enemy.z)
			HPos = Vector(myHero.x,0,myHero.z)
			WPos = HPos+(HPos-EPos)*(-600/GetDistance(HPos,EPos))
			EPos = HPos+(HPos-EPos)*(-800/GetDistance(HPos,EPos))
			if IsWall(WPos.x,0,WPos.z)==1 then Wall = 1
			else Wall = 0 end
			if CreepBlock(enemy.x,0,enemy.z,EPos.x,0,EPos.z)==1 then Block = 1
			else Block = 0 end
			
			local effhealth = enemy.health*(1+(((enemy.magicArmor*myHero.magicPenPercent)-myHero.magicPen)/100))
			local xQ = 30+(25*myHero.SpellLevelQ)+(.4*myHero.ap)
			local xW = 45+(40*myHero.SpellLevelW)+(.6*myHero.ap)
			local xE = (15+(25*myHero.SpellLevelE)+(.5*myHero.ap))*LBSettings.Emultiplier
			local xR = (100*myHero.SpellLevelR)+(.65*myHero.ap)
			local xBFT = (enemy.maxHealth*.2)*BFT
			local xDFG = (enemy.maxHealth*.15)*DFG
				
			KSN[1]  = {a=1,b=n,c=1,d=0,e=1,f=n,g=n, B=1,W=1, dist=1, H=(xQ*2)+xE, text='WQE (Long)'}
			KSN[2]  = {a=1,b=n,c=1,d=0,e=n,f=n,g=1, B=0,W=1, dist=1, H=(xQ*2)+(xR*2), text='WQR (Long)'}
			KSN[3]  = {a=1,b=n,c=1,d=0,e=1,f=n,g=1, B=1,W=1, dist=1, H=(xQ*2)+(xR*2)+xE, text='WQRE (Long)'}
			KSN[4]  = {a=1,b=n,c=1,d=0,e=n,f=n,g=1, B=0,W=1, dist=1, H=(((xQ*2)+xR)*1.2*(BFT+DFG))+xBFT+xDFG, text='IWQR (Long)'}
			KSN[5]  = {a=1,b=n,c=1,d=0,e=1,f=n,g=1, B=1,W=1, dist=1, H=(((xQ*2)+(xR*2)+xE)*1.2*(BFT+DFG))+xBFT+xDFG, text='IWQRE (Long)'}
			KSN[6]  = {a=1,b=n,c=n,d=n,e=n,f=n,g=n, B=0,W=0, dist=0, H=xQ, text='Q'}
			KSN[7]  = {a=n,b=n,c=n,d=n,e=1,f=n,g=n, B=1,W=0, dist=0, H=xE, text='E'}
			KSN[8]  = {a=1,b=n,c=1,d=0,e=n,f=n,g=n, B=0,W=1, dist=0, H=(xQ*2)+xW, text='QW'}
			KSN[9]  = {a=1,b=n,c=n,d=n,e=1,f=n,g=n, B=1,W=0, dist=0, H=(xQ*2)+xE, text='QE'}
			KSN[10] = {a=1,b=n,c=1,d=0,e=1,f=n,g=n, B=1,W=1, dist=0, H=(xQ*2)+xW+xE, text='QWE'}
			KSN[11] = {a=1,b=n,c=n,d=n,e=n,f=n,g=1, B=0,W=0, dist=0, H=(xQ*2)+xR, text='QR'}
			KSN[12] = {a=n,b=0,c=n,d=n,e=1,f=1,g=1, B=1,W=0, dist=0, H=(xR*2)+xE, text='RE'}
			KSN[13] = {a=1,b=1,c=0,d=n,e=0,f=n,g=1, B=0,W=0, dist=0, H=(xR*2)+xQ, text='RQ'}
			KSN[14] = {a=0,b=1,c=1,d=0,e=0,f=0,g=1, B=0,W=1, dist=0, H=(xR*2)+xW, text='RW'}
			KSN[15] = {a=0,b=1,c=1,d=0,e=1,f=0,g=1, B=1,W=1, dist=0, H=(xR*2)+xW+xE, text='RWE'}
			KSN[16] = {a=1,b=n,c=n,d=n,e=1,f=n,g=1, B=1,W=0, dist=0, H=(xQ*2)+(xR*2)+xE, text='QRE'}
			KSN[17] = {a=1,b=n,c=1,d=0,e=n,f=n,g=1, B=0,W=1, dist=0, H=(xQ*2)+(xR*2)+xW, text='QRW'}
			KSN[19] = {a=1,b=n,c=1,d=0,e=1,f=n,g=1, B=0,W=0, dist=0, H=(((xQ*2)+xR)*1.2*(BFT+DFG))+xBFT+xDFG, text='QRWE'}
			KSN[18] = {a=1,b=n,c=n,d=n,e=n,f=n,g=1, B=1,W=0, dist=0, H=(((xQ*2)+xR)*1.2*(BFT+DFG))+xBFT+xDFG, text='IQR'}
			KSN[20] = {a=0,b=1,c=0,d=n,e=1,f=0,g=1, B=1,W=0, dist=0, H=(((xR*2)+xE)*1.2*(BFT+DFG))+xBFT+xDFG, text='IRE'}
			KSN[21] = {a=1,b=1,c=0,d=n,e=0,f=n,g=1, B=0,W=0, dist=0, H=(((xR*2)+xQ)*1.2*(BFT+DFG))+xBFT+xDFG, text='IRQ'}
			KSN[22] = {a=0,b=1,c=1,d=0,e=0,f=0,g=1, B=0,W=1, dist=0, H=(((xR*2)+xW)*1.2*(BFT+DFG))+xBFT+xDFG, text='IRW'}
			KSN[23] = {a=0,b=1,c=1,d=0,e=1,f=0,g=1, B=1,W=1, dist=0, H=(((xR*2)+xW+xE)*1.2*(BFT+DFG))+xBFT+xDFG, text='IRWE'}
			KSN[24] = {a=1,b=n,c=n,d=n,e=1,f=n,g=1, B=1,W=0, dist=0, H=(((xQ*2)+(xR*2)+xE)*1.2*(BFT+DFG))+xBFT+xDFG, text='IQRE'}
			KSN[25] = {a=1,b=n,c=1,d=0,e=n,f=n,g=1, B=0,W=1, dist=0, H=(((xQ*2)+(xR*2)+xW)*1.2*(BFT+DFG))+xBFT+xDFG, text='IQRW'}
			KSN[26] = {a=1,b=n,c=1,d=0,e=1,f=n,g=1, B=1,W=1, dist=0, H=(((xQ*2)+(xR*2)+xW+xE)*1.2*(BFT+DFG))+xBFT+xDFG, text='IQRWE'}
			
			for v=1,26 do
				if LBSettings.KSNotes and CD(KSN[v].a,KSN[v].b,KSN[v].c,KSN[v].d,KSN[v].e,KSN[v].f,KSN[v].g) and Mana(KSN[v].a,KSN[v].b,KSN[v].c,KSN[v].d,KSN[v].e,KSN[v].f,KSN[v].g) and effhealth<KSN[v].H and KSN[v].dist==1 and GetDistance(enemy)>700 then
					if (KSN[v].B==1 and Block==1) or (KSN[v].W==1 and Wall==1) then DrawTextObject(KSN[v].text..' KILL',enemy,Color.Red)
					else DrawTextObject(KSN[v].text..' KILL',enemy,Color.Yellow) end
					break
				elseif LBSettings.KSNotes and CD(KSN[v].a,KSN[v].b,KSN[v].c,KSN[v].d,KSN[v].e,KSN[v].f,KSN[v].g) and Mana(KSN[v].a,KSN[v].b,KSN[v].c,KSN[v].d,KSN[v].e,KSN[v].f,KSN[v].g) and effhealth<KSN[v].H and KSN[v].dist==0 then
					if (KSN[v].B==1 and Block==1) or (KSN[v].W==1 and Wall==1) then DrawTextObject(KSN[v].text..' KILL',enemy,Color.Red)
					else DrawTextObject(KSN[v].text..' KILL',enemy,Color.Yellow) end
					break
				end
			end
		end
	end

	if LBConf.Combo and target~=nil then
		EPos = Vector(target.x, target.y, target.z)
		HPos = Vector(myHero.x, myHero.y, myHero.z)
		WPos = HPos+(HPos-EPos)*(-600/GetDistance(HPos, EPos))
		if IsWall(WPos.x,WPos.y,WPos.z)==1 then WallT = 1
		else WallT = 0 end
		if GetDistance(target)<700 then
			if 		CD(1,n,1,0,1,n,1) and Mana(1,n,1,0,1,n,1) and WallT==0 					then Seq(I1,Q1)
			elseif 	CD(0,1,1,0,1,0,1) and Mana(0,1,1,0,1,0,1) and WallT==0 	and ls=='Q1' 	then Q2()
			elseif 	CD(0,0,1,0,1,0,0) and Mana(0,0,1,0,1,0,0) and WallT==0 	and ls=='Q2'	then W1()
			elseif 	CD(0,0,0,1,1,0,0) and Mana(0,0,0,1,1,0,0) and WallT==0 	and ls=='xW' 	then E1() --
			elseif 	CD(1,n,0,n,1,n,1) and Mana(1,n,0,n,1,n,1) 								then Seq(I1,Q1)
			elseif 	CD(0,1,0,n,1,0,1) and Mana(0,1,0,n,1,0,1) 			   	and ls=='Q1' 	then Q2()
			elseif 	CD(0,0,0,n,1,0,0) and Mana(0,0,0,n,1,0,0) 			 	and ls=='Q2' 	then E1() --
			elseif 	CD(1,n,1,0,0,n,1) and Mana(1,n,1,0,0,n,1) and WallT==0 					then Seq(I1,Q1)
			elseif 	CD(0,1,1,0,0,0,1) and Mana(0,1,1,0,0,0,1) and WallT==0 	and ls=='Q1' 	then Q2()
			elseif 	CD(0,0,1,0,0,0,0) and Mana(0,0,1,0,0,0,0) and WallT==0 	and ls=='Q2' 	then W1() --
			elseif 	CD(1,1,0,n,0,n,1) and Mana(1,1,0,n,0,n,1) 								then Seq(I1,Q2)
			elseif 	CD(1,0,0,n,0,0,0) and Mana(1,0,0,n,0,0,0) 				and ls=='Q2' 	then Q1() --
			elseif 	CD(0,1,1,0,1,0,1) and Mana(0,1,1,0,1,0,1) and WallT==0 					then Seq(I1,Q2)
			elseif 	CD(0,1,1,0,1,0,0) and Mana(0,1,1,0,1,0,0) and WallT==0  and ls=='Q2' 	then W1()
			elseif 	CD(0,0,0,1,1,0,0) and Mana(0,0,0,1,1,0,0) and WallT==0 	and ls=='xW' 	then E1() --
			elseif 	CD(0,1,1,0,0,0,1) and Mana(0,1,1,0,0,0,1) and WallT==0 					then Seq(I1,Q2) 
			elseif 	CD(0,0,1,0,0,0,0) and Mana(0,0,1,0,0,0,0) and WallT==0  and ls=='Q2' 	then W1() --
			elseif 	CD(0,1,0,n,1,0,1) and Mana(0,1,0,n,1,0,1) 								then Seq(I1,Q2)
			elseif 	CD(0,0,0,n,1,0,0) and Mana(0,0,0,n,1,0,0) 				and ls=='Q2' 	then E1() --
			elseif 	CD(1,n,0,n,0,n,1) and Mana(1,n,0,n,0,n,1) 								then Seq(I1,Q1)
			elseif 	CD(0,1,0,n,0,0,1) and Mana(0,1,0,n,0,0,1) 				and ls=='Q1' 	then Q2() --
			elseif 	CD(1,0,1,0,1,0,0) and Mana(1,0,1,0,1,0,0) and WallT==0 					then Seq(I1,Q1)
			elseif 	CD(0,0,1,0,1,0,0) and Mana(0,0,1,0,1,0,0) and WallT==0  and ls=='Q1' 	then W1()
			elseif 	CD(0,0,0,1,1,0,0) and Mana(0,0,0,1,1,0,0) and WallT==0  and ls=='xW' 	then E1() --
			elseif	CD(1,0,0,n,1,0,0) and Mana(1,0,0,n,1,0,0) 								then Q1()
			elseif	CD(0,0,0,n,1,0,0) and Mana(0,0,0,n,1,0,0) 				and ls=='Q1' 	then E1() --
			elseif 	CD(1,0,1,0,0,0,0) and Mana(1,0,1,0,0,0,0) and WallT==0 					then Q1()
			elseif 	CD(0,0,1,0,0,0,0) and Mana(0,0,1,0,0,0,0) and WallT==0  and ls=='Q1' 	then W1() --
			elseif 	CD(0,0,0,n,1,0,0) and Mana(0,0,0,n,1,0,0) 								then E1() --
			elseif 	CD(1,0,0,n,0,0,0) and Mana(1,0,0,n,0,0,0) 								then Q1() --
			end
		elseif GetDistance(target)>700 then
			if 		CD(1,n,1,0,1,n,1) and Mana(1,n,1,0,1,n,1) and WallT==0 					then WL()
			elseif 	CD(1,0,0,1,1,0,1) and Mana(1,0,0,1,1,0,1) and WallT==0 	 				then Seq(I1,Q1)
			elseif 	CD(0,1,0,1,1,0,1) and Mana(0,1,0,1,1,0,1) and WallT==0 	and ls=='Q1'	then Q2()
			elseif 	CD(0,0,0,1,1,0,0) and Mana(0,0,0,1,1,0,0) and WallT==0	and ls=='Q2'	then E1() --
			elseif 	CD(1,n,1,0,0,n,1) and Mana(1,n,1,0,0,n,1) and WallT==0 					then WL()
			elseif 	CD(1,0,0,1,0,0,1) and Mana(1,0,0,1,0,0,1) and WallT==0 					then Seq(I1,Q1)
			elseif 	CD(0,1,0,1,0,0,1) and Mana(0,1,0,1,0,0,1) and WallT==0 	and ls=='Q1' 	then Q2() --
			elseif 	CD(1,0,1,0,1,0,0) and Mana(1,n,1,0,1,n,1) and WallT==0 					then WL()
			elseif 	CD(1,0,0,1,1,0,0) and Mana(1,n,1,0,1,n,1) and WallT==0 					then Q1()
			elseif 	CD(0,0,0,1,1,0,0) and Mana(1,n,1,0,1,n,1) and WallT==0 	and ls=='Q1'	then E1() --
			end	
		end
	end
		if LBConf.Harass and target~=nil then
			if 		CD(1,n,1,0,n,n,n) and Mana(1,n,1,0,n,n,n) then Q1()
			elseif	CD(s,n,1,0,n,n,n) and Mana(s,n,1,0,n,n,n) then W1()
			elseif	CD(0,n,s,1,n,n,n) and Mana(0,n,s,1,n,n,n) then W2()
			end
		end
		if LBConf.Qkey and target~=nil then
			if 		CD(1,n,n,n,n,n,n) and Mana(1,n,n,n,n,n,n) then Q1()
			elseif 	CD(0,1,n,n,n,n,1) and Mana(0,1,n,n,n,n,1) then Q2()
			end
		end
		if LBConf.Ekey and target~=nil then
			if 		CD(n,n,n,n,1,n,n) and Mana(n,n,n,n,1,n,n) then E1()
			elseif	CD(n,n,n,n,n,1,1) and Mana(n,n,n,n,n,1,1) then E2()
			end
		end
	
	if myHero.dead == 0 and LBSettings.DrawCircles then
			HNS[1]  = {a=1,b=n,c=1,d=0,e=1,f=n,g=1, text='BURST'}
			HNS[2]  = {a=1,b=n,c=1,d=0,e=0,f=n,g=1, text='QRW'}
			HNS[3]  = {a=1,b=n,c=0,d=n,e=1,f=n,g=1, text='QRE'}
			HNS[4]  = {a=0,b=1,c=1,d=0,e=1,f=0,g=1, text='RWE'}
			HNS[5]  = {a=1,b=1,c=0,d=n,e=0,f=n,g=1, text='RQ'}
			HNS[6]  = {a=0,b=1,c=1,d=0,e=0,f=0,g=1, text='RW'}
			HNS[7]  = {a=0,b=1,c=0,d=n,e=1,f=0,g=1, text='RE'}
			HNS[8]  = {a=1,b=n,c=0,d=n,e=0,f=n,g=1, text='QR'}
			HNS[9]  = {a=1,b=0,c=1,d=0,e=1,f=0,g=0, text='QWE'}
			HNS[10] = {a=1,b=0,c=0,d=n,e=1,f=0,g=0, text='QE'}
			HNS[11] = {a=1,b=0,c=1,d=0,e=0,f=0,g=0, text='QW'}
			HNS[12] = {a=0,b=0,c=0,d=n,e=1,f=0,g=0, text='E'}
			HNS[13] = {a=1,b=0,c=0,d=n,e=0,f=0,g=0, text='Q'}
	
		if target~=nil and GetDistance(target)<700 then CustomCircle(75,3,2,target)
		elseif 	target~=nil and GetDistance(target)>700 then CustomCircle(75,3,5,target) end
		if CD(1,n,n,n,n,n,n) and Mana(1,n,n,n,n,n,n) then CustomCircle(700,1,2,myHero) end
		if CD(1,n,1,0,n,n,n) and Mana(1,n,1,0,n,n,n) then CustomCircle(1200,1,5,myHero) end
		for v=1,13 do
			if CD(HNS[v].a,HNS[v].b,HNS[v].c,HNS[v].d,HNS[v].e,HNS[v].f,HNS[v].g) and Mana(HNS[v].a,HNS[v].b,HNS[v].c,HNS[v].d,HNS[v].e,HNS[v].f,HNS[v].g) then 
				DrawTextObject(HNS[v].text,myHero,Color.Yellow)
				break
			end
		end
	end
	if LBSettings.MouseMove and (LBConf.Combo or LBConf.Harass) and dodgetimer == 0 then MoveToMouse() end
end
	
function Seq(a,b)
	if a == I1 or b == I1 then I1() end
	if a == Q1 or b == Q1 then Q1() end
	if a == Q2 or b == Q2 then Q2() end
end

function Mana(a,b,c,d,e,f,g)
	if a == 1 then a = 40+(myHero.SpellLevelQ*10) 
	else a = 0  end
	if c == 1 then c = 70+(myHero.SpellLevelW*10)
	else c = 0  end
	if e == 1 then e = 80
	else e = 0 end
	if myHero.mana > a+c+e then return true end
end
	
function CD(a,b,c,d,e,f,g)
	if myHero.SpellNameQ == 'LeblancChaosOrb' and myHero.SpellLevelQ >= 1 and myHero.SpellTimeQ > 1 then Q1RDY = 1
	else Q1RDY = 0 end
	if myHero.SpellNameR == 'LeblancChaosOrbM' and myHero.SpellLevelR >= 1 and myHero.SpellTimeR > 1 then Q2RDY = 1
	else Q2RDY = 0 end
	if myHero.SpellNameW == 'LeblancSlide' and myHero.SpellLevelW >= 1 and myHero.SpellTimeW > 1 then W1RDY = 1
	else W1RDY = 0 end
	if myHero.SpellNameW == 'leblancslidereturn' and myHero.SpellLevelW >= 1 and myHero.SpellTimeW > 1 then W2RDY = 1
	else W2RDY = 0 end
	if myHero.SpellNameE == 'LeblancSoulShackle' and myHero.SpellLevelE >= 1 and myHero.SpellTimeE > 1 then E1RDY = 1
	else E1RDY = 0 end
	if myHero.SpellNameR == 'LeblancSoulShackleM' and myHero.SpellLevelR >= 1 and myHero.SpellTimeR > 1 then E2RDY = 1
	else E2RDY = 0 end
	if myHero.SpellLevelR >= 1 and myHero.SpellNameR ~= 'leblancslidereturnm' and myHero.SpellTimeR > 1 then RRDY = 1
	else RRDY = 0 end
	if (Q1RDY == a or a == n) and (Q2RDY == b or b == n) and (W1RDY == c or c == n) and (W2RDY == d or d == n) and (E1RDY == e or e == n) and (E2RDY == f or f == n) and (RRDY == g or g == n) then
		return true
	end
end
		
function Q1()
	if GetDistance(target)<700 then CastSpellTarget('Q',target) end
end

function Q2()
	if GetDistance(target)<700 then CastSpellTarget('R',target) end
end

function xW1()
	if GetDistance(target)<700 and myHero.SpellNameW ~= 'leblancslidereturn' then CastSpellXYZ('W',target.x,target.y,target.z) end
end

function W1()
	run_many_reset(1, xW1)
end

function W2()
	CastSpellXYZ('W',myHero.x,myHero.y,myHero.z)
end

function xWL()
	if GetDistance(target)>700 and GetDistance(target)<distance and myHero.SpellNameW ~= 'leblancslidereturn' then CastSpellXYZ('W',target.x,target.y,target.z) end
end

function WL()
	run_many_reset(1, xWL)
end

function E1()
	local FX,FY,FZ = GetFireahead(target,1.6,15)
	if GetDistance(target)<800 and GetDistance(target)>200 and CreepBlock(FX,FY,FZ) == 0 then CastSpellXYZ('E',FX,FY,FZ)
	elseif GetDistance(target)<200 and CreepBlock(target.x,target.y,target.z) == 0 then CastSpellXYZ('E',target.x,target.y,target.z) end
end

function E2()
	local FX,FY,FZ = GetFireahead(target,1.5,15)
	if GetDistance(target)<800 and CreepBlock(FX,FY,FZ) == 0 then CastSpellXYZ('R',FX,FY,FZ) end
end

function I1()
	if target~=nil then
		if BFT == 1 then UseItemOnTarget(3188, target)
		elseif DFG == 1 then UseItemOnTarget(3128, target) end
	end
end

function SetVariables()
	if LBSettings.TargetSelector == 1 then target = GetWeakEnemy('MAGIC',1200)
	elseif LBSettings.TargetSelector == 2 then target = GetWeakEnemy('MAGIC',1200,'NEARMOUSE')
	elseif LBSettings.TargetSelector == 3 then target = GetWeakEnemy('MAGIC',1200,'ONLYNEARMOUSE') end
	if GetTickCount()-dodgetimer>DodgeConfig.BlockTime then dodgetimer = 0 end
end

function ReturnPad()
	if LBSettings.ReturnPad then 
		for i = 1, objManager:GetMaxObjects(), 1 do
			obj = objManager:GetObject(i)
			if obj~=nil and obj.charName == 'Leblanc_displacement_blink_indicator.troy' then DrawSphere(85,30,5,obj.x,obj.y,obj.z) end
			if obj~=nil and obj.charName == 'Leblanc_displacement_blink_indicator_ult.troy' then DrawSphere(85,30,4,obj.x,obj.y,obj.z) end
		end
	end
end

function Distance()
	if target~=nil and runningAway(target) then distance = 1300-((target.movespeed/1000)*(450))
	else distance = 1200 end
	return distance
end

function Jump()
	Jcoord[1] = {ax = 9617, az = 6104, bx = 9279, bz = 6425}
	Jcoord[2] = {ax = 7995, az = 6583, bx = 8429, bz = 6175}
	Jcoord[3] = {ax = 7753, az = 5897, bx = 8329, bz = 5725}
	Jcoord[4] = {ax = 6109, az = 5565, bx = 5581, bz = 5687}
	Jcoord[5] = {ax = 5111, az = 5386, bx = 4605, bz = 5501}
	Jcoord[6] = {ax = 6481, az = 4295, bx = 6143, bz = 4667}
	Jcoord[7] = {ax = 7535, az = 3771, bx = 7529, bz = 3175}
	Jcoord[8] = {ax = 6717, az = 3229, bx = 6781, bz = 3825}
	Jcoord[9] = {ax = 1645, az = 8813, bx = 1731, bz = 8273}
	Jcoord[10] = {ax = 3780, az = 9213, bx = 4267, bz = 8873}
	Jcoord[11] = {ax = 5368, az = 9673, bx = 5094, bz = 10138}
	Jcoord[12] = {ax = 6191, az = 10031, bx = 5881, bz = 9523}
	Jcoord[13] = {ax = 6949, az = 11887,  bx = 6947, bz = 11479}
	Jcoord[14] = {ax = 6771, az = 10569, bx = 6635, bz = 10081}
	Jcoord[15] = {ax = 7127, az = 10561, bx = 7229, bz = 10073}
	Jcoord[16] = {ax = 7776, az = 10075, bx = 8115, bz = 9583}
	Jcoord[17] = {ax = 8690, az = 10255, bx = 8613, bz = 9679}
	Jcoord[18] = {ax = 9579, az = 8923, bx = 9869, bz = 9405}
	Jcoord[19] = {ax = 12186, az = 6703, bx = 12179, bz = 6119}
	Jcoord[20] = {ax = 9191, az = 3468, bx = 9677, bz = 3181}
	Jcoord[21] = {ax = 9777, az = 3859, bx = 9879, bz = 3325}
	Jcoord[22] = {ax = 11282, az = 3094, bx = 10979, bz = 2675}
	Jcoord[23] = {ax = 10470, az = 2174, bx = 10195, bz = 2559}
	Jcoord[24] = {ax = 9525, az = 1483, bx = 9329, bz = 1925}
	Jcoord[25] = {ax = 8123, az = 2917, bx = 8479, bz = 2475}
	Jcoord[26] = {ax = 7785, az = 2751, bx = 8009, bz = 2295}
	Jcoord[27] = {ax = 5911, az = 2893, bx = 5731, bz = 2375}
	Jcoord[28] = {ax = 4408, az = 1402, bx = 4467, bz = 1985}
	Jcoord[29] = {ax = 3384, az = 2221, bx = 3831, bz = 2475}
	Jcoord[30] = {ax = 2856, az = 2637, bx = 2631, bz = 3125}
	
    if LBSettings.jumphelper and GetMap() == 2 then
		if (KeyDown(2) or LBConf.Combo or LBConf.Harass) then jump2 = false end
		for n=1,30 do
			if distXYZ(Jcoord[n].ax,Jcoord[n].az,mousePos.x,mousePos.z)<=75 then DrawCircle(Jcoord[n].ax, -188, Jcoord[n].az, 75, 0xFFFF0000)
			elseif distXYZ(Jcoord[n].ax,Jcoord[n].az,myHero.x,myHero.z)<=2500 then DrawCircle(Jcoord[n].ax, -188, Jcoord[n].az, 75, 0xFFFF8000)
			end
			if distXYZ(Jcoord[n].bx,Jcoord[n].bz,mousePos.x,mousePos.z)<=75 then DrawCircle(Jcoord[n].bx, -188, Jcoord[n].bz, 75, 0xFFFF0000)
			elseif distXYZ(Jcoord[n].bx,Jcoord[n].bz,myHero.x,myHero.z)<=2500 then DrawCircle(Jcoord[n].bx, -188, Jcoord[n].bz, 75, 0xFFFF8000)
			end
			if KeyDown(1) and distXYZ(Jcoord[n].ax,Jcoord[n].az,mousePos.x,mousePos.z)<=75 then 
				MoveToXYZ(Jcoord[n].ax,0,Jcoord[n].az)
				jump2 = true
			end
			if KeyDown(1) and distXYZ(Jcoord[n].bx,Jcoord[n].bz,mousePos.x,mousePos.z)<=75 then 
				MoveToXYZ(Jcoord[n].bx,0,Jcoord[n].bz)
				jump2 = true
			end
			if jump2 == true and W1RDY == 1 then
				if distXYZ(Jcoord[n].ax,Jcoord[n].az,myHero.x,myHero.z)<50 then CastSpellXYZ('W',Jcoord[n].bx,-189,Jcoord[n].bz)
				elseif distXYZ(Jcoord[n].bx,Jcoord[n].bz,myHero.x,myHero.z)<50 then CastSpellXYZ('W',Jcoord[n].ax,-189,Jcoord[n].az)
				end
			end
		end
	end
end

function dodgeaoe(pos1, pos2, radius)
	local xa,xb,ya,yb,cc = 50/1920*GetScreenX(),1870/1920*GetScreenX(),50/1080*GetScreenY(),1030/1080*GetScreenY()
	local calc = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
	local dodgex = pos2.x + ((radius+50)/calc)*(myHero.x-pos2.x)
	local dodgez = pos2.z + ((radius+50)/calc)*(myHero.z-pos2.z)
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
	local xa,xb,ya,yb,cc = 50/1920*GetScreenX(),1870/1920*GetScreenX(),50/1080*GetScreenY(),1030/1080*GetScreenY()
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
	local xa,xb,ya,yb,cc = 50/1920*GetScreenX(),1870/1920*GetScreenX(),50/1080*GetScreenY(),1030/1080*GetScreenY()
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
	if perpendicular < radius and calc1 < calc4 and calc2 < calc4 and DodgeConfig.DodgeSkillShots == true and GetCursorX() > xa and GetCursorX() < xb and GetCursorY() > ya and GetCursorY() < yb then
		if DodgeConfig.BlockSettings == 1 and LBConf.Combo == false and LBConf.Harass == false then
			dodgetimer = GetTickCount()
			send.block_input(true,DodgeConfig.BlockTime)
			MoveToXYZ(dodgex,0,dodgez)
		elseif DodgeConfig.BlockSettings == 2 then
			dodgetimer = GetTickCount()
			MoveToXYZ(dodgex,0,dodgez)
		end
	end
end

function Skillshots()
	send.tick()
	cc=cc+1
	if cc==30 then LoadTable() end
	for i=1, #skillshotArray, 1 do
		if os.clock() > (skillshotArray[i].lastshot + skillshotArray[i].time) then skillshotArray[i].shot = 0 end
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
end

function OnProcessSpell(unit, spell)
	if unit ~= nil and spell ~= nil and unit.charName == myHero.charName then
		if spell.name == 'LeblancChaosOrb' then ls = 'Q1' end
		if spell.name == 'LeblancChaosOrbM' then ls = 'Q2' end
			if spell.name == 'LeblancSlide' then ls = 'xW' end
		if spell.name == 'LeblancSoulShackle' then ls = 'E1' end
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

SetTimerCallback('Main')