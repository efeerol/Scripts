require 'Utils'
require 'winapi'
require 'SKeys'
require 'spell_damage'
require 'runrunrun'
require 'vals_lib'
local Q,W,E,R = 'Q','W','E','R'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local version = '1.6.3'
local timer = 0

function Karma()
	if IsLolActive() and IsChatOpen()==0 then
		target = GetWeakEnemy('MAGIC',650)
		target2 = GetWeakEnemy('MAGIC',850)
		GetCD()
		
		if KarmaConfig.QSpell then SpellPred(Q,QRDY,myHero,target2,850,1.6,17,1) end	
		if KarmaConfig.Wspell then SpellTarget(W,WRDY,myHero,target,650) end
		if KarmaConfig.Espell then CastHotkey("AUTO 100,0 SPELLE:WEAKALLY RANGE=800 COOLDOWN") end
		if KarmaConfig.Killsteal then run_every((1/10),Killsteal) end
		if KarmaConfig.Killnotes then Killnotes() end
		
		if target2~=nil then
			local root = (750+(myHero.SpellLevelW*250))
			local Qcast = ((1.6*100)+(distXYZ(myHero.x,myHero.z,target2.x,target2.z)/(17/10)))+1500
			local duration = 2000+root-Qcast
			if timer~=0 and QRDY==1 and RRDY==0 then
				SpellPred(Q,QRDY,myHero,target2,850,1.6,17,1,150)
			elseif timer~=0 and GetTickCount()>timer+duration then
				SpellPred(R,RRDY*QRDY,myHero,target2,850,1.6,17,1,150)
				SpellPred(Q,QRDY,myHero,target2,850,1.6,17,1,150)
			end
			if timer~=0 and QRDY==0 and RRDY==0 then
				timer = 0
			end
			if timer~=0 and GetTickCount()>timer+3000 then
				timer=0
			end
			if myHero.dead==1 then
				timer=0
			end
		end
	end
end

	KarmaConfig, menu = uiconfig.add_menu('Karma Config', 200)
    menu.keydown('QSpell', 'QSpell', Keys.Y)
	menu.keydown('Wspell', 'Wspell', Keys.X)
	menu.keydown('Espell', 'Espell', Keys.E)
	menu.checkbutton('AutoRQ', 'Auto-RQ', true)
	menu.checkbutton('drawcircles', 'Draw Circles', true)
	menu.checkbutton('Killsteal', 'Killsteal', true)
	menu.checkbutton('Killnotes', 'Killsteal notifications', true)
	menu.permashow('QSpell')
	menu.permashow('Wspell')
	menu.permashow('Espell')
	
function OnProcessSpell(unit,spell)
	if unit ~= nil and spell ~= nil and unit.charName == myHero.charName and IsLolActive() and IsChatOpen()==0 then
		if spell.name == "KarmaQ" then
			timer2 = 0
			GG = false
		end
		if KarmaConfig.AutoRQ and spell.name == "KarmaSpiritBind" then
			timer = GetTickCount()
		end
	end
end
	
function Killsteal()
	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0 and enemy.dead==0 and GetDistance(myHero,enemy)<850) then
			local Qdam = getDmg("Q",enemy,myHero,1)*QRDY
			local QRdam = (getDmg("Q",enemy,myHero,1)+getDmg("Q",enemy,myHero,2))*QRDY*RRDY
			local Wdam = getDmg("W",enemy,myHero,1)*WRDY/3
			local WRdam = (getDmg("W",enemy,myHero,1)+getDmg("W",enemy,myHero,2))*WRDY*RRDY/3
			local ERdam = getDmg("E",enemy,myHero)*ERDY
			
			if enemy.health < Wdam then
				SpellTarget(W,WRDY,myHero,enemy,650)
			elseif enemy.health < Qdam then
				SpellPred(Q,QRDY,myHero,enemy,850,1.6,17,1,150)
			elseif enemy.health < ERdam then
				SpellTarget(R,RRDY,myHero,enemy,600)
				SpellTarget(E,ERDY,myHero,enemy,600)
			elseif enemy.health < Qdam+Wdam then
				SpellTarget(W,WRDY,myHero,enemy,650)
				SpellPred(Q,QRDY,myHero,enemy,850,1.6,17,1,150)
			elseif enemy.health < WRdam then
				SpellTarget(R,RRDY,myHero,enemy,650)
				SpellTarget(W,WRDY,myHero,enemy,650)
			elseif enemy.health < QRdam then
				SpellPred(R,RRDY,myHero,enemy,850,1.6,17,1,150)
				SpellPred(Q,QRDY,myHero,enemy,850,1.6,17,1,150)
				CastSpellXYZ('Q',GetFireahead(enemy,1.6,17))
			elseif enemy.health < QRdam+Wdam and CreepBlock(GetFireahead(enemy,1.6,17,150)) == 0 then
				SpellTarget(W,WRDY,myHero,enemy,650)
				SpellPred(R,RRDY,myHero,enemy,850,1.6,17,1,150)
				SpellPred(Q,QRDY,myHero,enemy,850,1.6,17,1,150)
			elseif enemy.health < Wdam+ERdam then
				SpellTarget(W,WRDY,myHero,enemy,600)
				SpellTarget(R,RRDY,myHero,enemy,600)
				SpellTarget(E,ERDY,myHero,enemy,600)
			elseif enemy.health < Qdam+ERdam and CreepBlock(GetFireahead(enemy,1.6,17,150)) == 0 then
				SpellTarget(R,RRDY,myHero,enemy,600)
				SpellTarget(E,ERDY,myHero,enemy,600)
				SpellPred(Q,QRDY,myHero,enemy,850,1.6,17,1,150)
			elseif enemy.health < Qdam+WRdam and CreepBlock(GetFireahead(enemy,1.6,17,150)) == 0 then
				SpellTarget(R,RRDY,myHero,enemy,650)
				SpellTarget(W,WRDY,myHero,enemy,650)
				SpellPred(Q,QRDY,myHero,enemy,850,1.6,17,1,150)
			elseif GetDistance(myHero,enemy) < 600 and enemy.health < Qdam+Wdam+ERdam and CreepBlock(GetFireahead(enemy,1.6,17,150)) == 0 then
				SpellTarget(R,RRDY,myHero,enemy,600)
				SpellTarget(E,ERDY,myHero,enemy,600)
				SpellTarget(W,WRDY,myHero,enemy,600)
				SpellPred(Q,QRDY,myHero,enemy,850,1.6,17,1,150)
			end
		end
	end
end

function Killnotes()
	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0 and enemy.dead==0) then
			local Q = getDmg("Q",enemy,myHero,1)*QRDY
			local QR = (getDmg("Q",enemy,myHero,1)+getDmg("Q",enemy,myHero,2))*QRDY*RRDY
			local W = getDmg("W",enemy,myHero,1)*WRDY/3
			local WR = (getDmg("W",enemy,myHero,1)+getDmg("W",enemy,myHero,2))*WRDY*RRDY/3
			local ER = getDmg("E",enemy,myHero)*ERDY
			if enemy.health < W then
				DrawTextObject("KILL W", enemy, Color.Red)
			elseif enemy.health < Q then
				DrawTextObject("KILL Q", enemy, Color.Red)
			elseif enemy.health < ER then
				DrawTextObject("KILL ER", enemy, Color.Red)
			elseif enemy.health < Q+W then
				DrawTextObject("KILL Q+W", enemy, Color.Red)
			elseif enemy.health < WR then
				DrawTextObject("KILL WR", enemy, Color.Red)
			elseif enemy.health < QR then
				DrawTextObject("KILL QR", enemy, Color.Red)
			elseif enemy.health < QR+W then
				DrawTextObject("KILL QR+W", enemy, Color.Red)
			elseif enemy.health < W+ER then
				DrawTextObject("KILL W+ER", enemy, Color.Red)
			elseif enemy.health < Q+ER then
				DrawTextObject("KILL Q+ER", enemy, Color.Red)
			elseif enemy.health < Q+WR  then
				DrawTextObject("KILL Q+WR", enemy, Color.Red)
			elseif enemy.health < Q+W+ER then
				DrawTextObject("KILL Q+W+ER", enemy, Color.Red)
			end
		end
	end
end

function OnDraw()
	if myHero.dead==0 and IsLolActive() and IsChatOpen()==0 then
		if KarmaConfig.drawcircles then
			if QRDY == 1 then
				CustomCircle(900,1,2,myHero)
			end
			if myHero.SpellTimeW > 1.0 then
				CustomCircle(650,1,3,myHero)
			elseif myHero.SpellTimeW > ((((16-myHero.SpellLevelW)-(((16-myHero.SpellLevelW)*myHero.cdr)/100))*-1)+2) then
				CustomCircle(800,1,5,myHero)
			end
			if target2 ~= nil then
				CustomCircle(100,10,2,target2)
			end
			if target ~= nil then
				CustomCircle(75,5,5,target)
			end
		end
	end
end
							
SetTimerCallback("Karma")
print("\nVal's Karma v"..version.."\n")