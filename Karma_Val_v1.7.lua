require 'Utils'
require 'winapi'
require 'SKeys'
require 'spell_damage'
local Q,W,E,R = 'Q','W','E','R'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local version = '1.7'
local ls = 0

function Main()
	if IsLolActive() then
		SetVariables()
		if KarmaConfig.AutoRQ then AutoRQ() end
		if KarmaConfig.Killsteal then Killsteal() end
		if KarmaConfig.Killnotes then Killnotes() end
		if KarmaConfig.QSpell then Qspell() end
		if KarmaConfig.Wspell then Wspell() end
		if KarmaConfig.Espell then Espell() end
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

function SetVariables()
	target = GetWeakEnemy('MAGIC',650)
	target2 = GetWeakEnemy('MAGIC',900)
	
	if myHero.SpellTimeQ>1 and GetSpellLevel('Q')>0 and myHero.mana>=(45+(myHero.SpellLevelQ*5)) then
	QRDY = 1
	else QRDY = 0
	end
	if myHero.SpellTimeW>1 and GetSpellLevel('W')>0 and myHero.mana>=(65+(myHero.SpellLevelW*5)) then
	WRDY = 1
	else WRDY = 0
	end
	if myHero.SpellTimeE>1 and GetSpellLevel('E')>0 and myHero.mana>=(50+(myHero.SpellLevelE*10)) then
	ERDY = 1
	else ERDY = 0
	end
	if myHero.SpellTimeR>1 then
	RRDY = 1
	else RRDY = 0
	end
	
	if QRDY==0 or (CCenemy~=nil and CreepBlock(GetFireahead(CCenemy,1.6,17,100))==1) then CCenemy=nil end
	if QRDY==0 or RRDY==0 then ls = 0 end
	if CCenemy~=nil then DrawTextObject("CCenemy", CCenemy, Color.Yellow) end
end

function Qspell()
	SpellPred(Q,QRDY,myHero,target2,900,1.6,17,1,100)
end

function Wspell()
	SpellTarget(W,WRDY,myHero,target,650)
end

function Espell()
	CastHotkey("AUTO 100,0 SPELLE:WEAKALLY RANGE=800 COOLDOWN")
end

function Rspell()
	SpellXYZ(R,RRDY,myHero,myHero,100,myHero.x,myHero.z)
end

function AutoRQ()
	if CCenemy~=nil then
		SpellXYZ(R,QRDY*RRDY,myHero,myHero,100,myHero.x,myHero.z)
		SpellPred(Q,QRDY*ls,myHero,CCenemy,900,1.6,17,1,100)
	end
end

function OnProcessSpell(unit,spell)
	if unit ~= nil and spell ~= nil and unit.team == myHero.team then
		for i = 1, objManager:GetMaxHeroes() do
			local enemy = objManager:GetHero(i)
			if (enemy~=nil and enemy.team~=myHero.team and enemy.visible==1 and enemy.invulnerable==0 and enemy.dead==0 and GetDistance(myHero,enemy)<950 and CreepBlock(GetFireahead(enemy,1.6,17,100))==0) then
				if     unit.name=='Aatrox' 		and spell.name == unit.SpellNameQ and distXYZ(enemy.x,enemy.z,spell.endPos.x,spell.endPos.z)<200 then CCenemy = enemy
				elseif unit.name=='Alistar' 	and spell.name == unit.SpellNameQ and distXYZ(enemy.x,enemy.z,spell.endPos.x,spell.endPos.z)<375 then CCenemy = enemy
				elseif unit.name=='Chogath'		and spell.name == unit.SpellNameR and distXYZ(enemy.x,enemy.z,spell.endPos.x,spell.endPos.z)<850 then CCenemy = enemy
				elseif unit.name=='Darius'		and spell.name == unit.SpellNameE and distXYZ(enemy.x,enemy.z,spell.endPos.x,spell.endPos.z)<475 then CCenemy = enemy
				elseif unit.name=='Diana'		and spell.name == unit.SpellNameE and distXYZ(enemy.x,enemy.z,spell.endPos.x,spell.endPos.z)<250 then CCenemy = enemy
				elseif unit.name=='Galio'		and spell.name == unit.SpellNameR and distXYZ(enemy.x,enemy.z,spell.endPos.x,spell.endPos.z)<600 then CCenemy = enemy
				elseif unit.name=='Karma' 		and spell.name == unit.SpellNameW and spell.target~=nil and spell.target.name == enemy.name then CCenemy = enemy
				elseif unit.name=='Lulu' 		and spell.name == unit.SpellNameW and spell.target~=nil and spell.target.name == enemy.name then CCenemy = enemy
				elseif unit.name=='Malphite' 	and spell.name == unit.SpellNameR and distXYZ(enemy.x,enemy.z,spell.endPos.x,spell.endPos.z)<1000 then CCenemy = enemy
				end
			end
		end
	end
end

function OnCreateObj(obj)
	if obj~=nil then
		if obj.charName=='tempkarma_mantraactivate_aura.troy' and GetDistance(obj)<50 then
			ls = 1
		end
		-- Cait E
		-- Elise E
		-- Fizz R (lockon)
		for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
			if (enemy~=nil and enemy.team~=myHero.team and enemy.visible==1 and enemy.invulnerable==0 and enemy.dead==0 and GetDistance(myHero,enemy)<950) then
				if obj.charName=='LOC_Stun.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
				elseif obj.charName=='LOC_Suppress.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
				elseif obj.charName=='LOC_Taunt.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
				elseif obj.charName=='LOC_Stun.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
				elseif obj.charName=='LOC_fear.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
				elseif obj.charName=='Global_Stun.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
				elseif obj.charName=='Ahri_Charm_buf.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
				elseif obj.charName=='CurseBandages.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
				elseif obj.charName=='Powerfist_tar.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
				elseif obj.charName=='JarvanCataclysm_tar.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
				elseif obj.charName=='leBlanc_shackle_tar_blood.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
				elseif obj.charName=='LuxLightBinding.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
				elseif obj.charName=='DarkBinding_tar.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
				elseif obj.charName=='RengarEMax_tar.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
				elseif obj.charName=='RunePrison.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
				elseif obj.charName=='Vi_R_land.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
				elseif obj.charName=='UnstoppableForce_stun.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
				elseif obj.charName=='Zyra_E_sequence_root.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
				elseif obj.charName=='monkey_king_ult_unit_tar_02.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
				elseif obj.charName=='xenZiou_ChainAttack_03.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
				elseif obj.charName=='VarusRHit.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
				end
			end
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
				SpellPred(Q,QRDY,myHero,enemy,850,1.6,17,1,100)
			elseif enemy.health < ERdam then
				SpellTarget(R,RRDY*ERDY,myHero,enemy,600)
				SpellTarget(E,ERDY*ls,myHero,enemy,600)
			elseif enemy.health < Qdam+Wdam then
				SpellTarget(W,WRDY,myHero,enemy,650)
				SpellPred(Q,QRDY,myHero,enemy,850,1.6,17,1,100)
			elseif enemy.health < WRdam then
				SpellTarget(R,RRDY*WRDY,myHero,enemy,650)
				SpellTarget(W,WRDY*ls,myHero,enemy,650)
			elseif enemy.health < QRdam then
				SpellPred(R,RRDY*QRDY,myHero,enemy,850,1.6,17,1,100)
				SpellPred(Q,QRDY*ls,myHero,enemy,850,1.6,17,1,100)
			elseif enemy.health < QRdam+Wdam and CreepBlock(GetFireahead(enemy,1.6,17,100)) == 0 then
				SpellTarget(W,WRDY,myHero,enemy,650)
				SpellPred(R,RRDY*QRDY,myHero,enemy,850,1.6,17,1,100)
				SpellPred(Q,QRDY*ls,myHero,enemy,850,1.6,17,1,100)
			elseif enemy.health < Wdam+ERdam then
				SpellTarget(W,WRDY,myHero,enemy,600)
				SpellTarget(R,RRDY*ERDY,myHero,enemy,600)
				SpellTarget(E,ERDY*ls,myHero,enemy,600)
			elseif enemy.health < Qdam+ERdam and CreepBlock(GetFireahead(enemy,1.6,17,100)) == 0 then
				SpellTarget(R,RRDY*ERDY,myHero,enemy,600)
				SpellTarget(E,ERDY*ls,myHero,enemy,600)
				SpellPred(Q,QRDY,myHero,enemy,850,1.6,17,1,100)
			elseif enemy.health < Qdam+WRdam and CreepBlock(GetFireahead(enemy,1.6,17,100)) == 0 then
				SpellTarget(R,RRDY*WRDY,myHero,enemy,650)
				SpellTarget(W,WRDY*ls,myHero,enemy,650)
				SpellPred(Q,QRDY,myHero,enemy,850,1.6,17,1,100)
			elseif GetDistance(myHero,enemy) < 600 and enemy.health < Qdam+Wdam+ERdam and CreepBlock(GetFireahead(enemy,1.6,17,100)) == 0 then
				SpellTarget(R,RRDY*ERDY,myHero,enemy,600)
				SpellTarget(E,ERDY*ls,myHero,enemy,600)
				SpellTarget(W,WRDY,myHero,enemy,600)
				SpellPred(Q,QRDY,myHero,enemy,850,1.6,17,1,100)
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
				DrawTextObject("KILL W", enemy, Color.Yellow)
			elseif enemy.health < Q then
				DrawTextObject("KILL Q", enemy, Color.Yellow)
			elseif enemy.health < ER then
				DrawTextObject("KILL ER", enemy, Color.Yellow)
			elseif enemy.health < Q+W then
				DrawTextObject("KILL Q+W", enemy, Color.Yellow)
			elseif enemy.health < WR then
				DrawTextObject("KILL WR", enemy, Color.Yellow)
			elseif enemy.health < QR then
				DrawTextObject("KILL QR", enemy, Color.Yellow)
			elseif enemy.health < QR+W then
				DrawTextObject("KILL QR+W", enemy, Color.Yellow)
			elseif enemy.health < W+ER then
				DrawTextObject("KILL W+ER", enemy, Color.Yellow)
			elseif enemy.health < Q+ER then
				DrawTextObject("KILL Q+ER", enemy, Color.Yellow)
			elseif enemy.health < Q+WR  then
				DrawTextObject("KILL Q+WR", enemy, Color.Yellow)
			elseif enemy.health < Q+W+ER then
				DrawTextObject("KILL Q+W+ER", enemy, Color.Yellow)
			end
		end
	end
end

function OnDraw()
	if myHero.dead==0 then
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

	
function SpellPred(spell,cd,a,b,range,delay,speed,block,blockradius)
	if (cd == 1 or cd) and a ~= nil and b ~= nil and delay ~= nil and speed ~= nil and GetDistance(a,b)<range then
		local FX,FY,FZ = GetFireahead(b,delay,speed)
		if distXYZ(a.x,a.z,b.x,b.z)<range and distXYZ(a.x,a.z,FX,FZ)<range then
			if block == 1 and blockradius==nil then
				if CreepBlock(a.x,a.y,a.z,FX,FY,FZ) == 0 then
					CastSpellXYZ(spell,FX,FY,FZ)
				end
			elseif block == 1 and blockradius~=nil then
				if CreepBlock(a.x,a.y,a.z,FX,FY,FZ,blockradius) == 0 then
					CastSpellXYZ(spell,FX,FY,FZ)
				end
			else CastSpellXYZ(spell,FX,FY,FZ)
			end
		end
	end
end

function distXYZ(a1,a2,b1,b2)
	if b1 == nil or b2 == nil then
		b1 = myHero.x
		b2 = myHero.z
	end
	if a2 ~= nil and b2 ~= nil and a1~=nil and b1~=nil then
		a = (b1-a1)
		b = (b2-a2)
		if a~=nil and b~=nil then
			a2=a*a
			b2=b*b
			if a2~=nil and b2~=nil then
				return math.sqrt(a2+b2)
			else
				return 99999
			end
		else
			return 99999
		end
	end
end

function IsLolActive()
    return tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client" and IsChatOpen() == 0
end

SetTimerCallback("Main")