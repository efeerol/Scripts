require 'Utils'
require 'winapi'
require 'SKeys'
require 'spell_damage'
require 'runrunrun'
require 'vals_lib'
local uiconfig = require 'uiconfig'
local Q,W,E,R = 'Q','W','E','R'
local version = '1.1'
local MarkTimer = nil
local timer = 0

function Main()
	if IsLolActive() and IsChatOpen() == 0 then
		GetCD()
		GetMark()
		Timer()
		AArange = myHero.range+(GetDistance(GetMinBBox(myHero))+50)
		target = GetWeakEnemy('MAGIC',830)
		targetaa = GetWeakEnemy('MAGIC',AArange)
		if DianaConfig.Qspell then Qspell() end
		if DianaConfig.Combo then Combo() end
		if DianaConfig.Killsteal then Killsteal() end
	end
end

	DianaConfig, menu = uiconfig.add_menu('Diana Config', 200)
	menu.keydown('Qspell', 'Qspell', Keys.Y)
	menu.keydown('Combo', 'Combo', Keys.X)
	menu.checkbutton('Killsteal', 'Killsteal', true)
	menu.permashow('Qspell')
	menu.permashow('Combo')
	menu.permashow('Killsteal')

function Combo()
	if target~=nil and WRDY == 0 and GetDistance(target)>AArange then SpellXYZ(E,ERDY,myHero,target,450,myHero.x,myHero.z) end
	Qspell()
	delayed_Rspell()
	if targetaa~=nil then
		AttackTarget(targetaa)
		if attacked then SpellXYZ(W,WRDY,myHero,targetaa,AArange,targetaa.x,targetaa.z) end
		UseAllItems(targetaa) 
	end
	if target~=nil then MoveTarget(target)
	else MoveMouse()
	end
end

function Rspell()
	if MarkedEnemy~=nil then SpellTarget(R,RRDY,myHero,MarkedEnemy,825) end
end

function delayed_Rspell()
	run_every(1,Rspell)
end

function Qspell()
	if target~=nil then
		XX,YY,ZZ = GetFireahead(target, 1.6, 16)
		if GetDistance(target)<680 then
			EnemyPos = Vector(XX,YY,ZZ)
			HeroPos = Vector(myHero.x, myHero.y, myHero.z)
			QPos = HeroPos+(HeroPos-EnemyPos)*(-(GetDistance(target)+150)/GetDistance(HeroPos, EnemyPos))
			SpellXYZ(Q,QRDY,myHero,target,830,QPos.x,QPos.z)
		else SpellXYZ(Q,QRDY,myHero,target,775,XX,ZZ)
		end
	end
end

function Killsteal()
	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0 and enemy.dead == 0) then
			local Rdam = getDmg("R",enemy,myHero)*RRDY
			if enemy.health < Rdam then
				DrawSphere(50,20,5,enemy.x,enemy.y+300,enemy.z)
				SpellTarget(R,RRDY,myHero,enemy,825)
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
					if string.find(obj.charName,'Diana_Q_moonlight_champ') and GetDistance(obj, enemy) < 50 then
						MarkedEnemy = enemy
						MarkTimer = GetTickCount()
					end
				end
				if obj~=nil and MarkedEnemy~=nil then
					 for i = 1, objManager:GetMaxDelObjects(), 1 do
                        local object = {objManager:GetDelObject(i)}
                        local ret={}
                        ret.index=object[1]
                        ret.name=object[2]
                        ret.charName=object[3]
                        ret.x=object[4]
                        ret.y=object[5]
                        ret.z=object[6]
                        if ret.charName~=nil and string.find(ret.charName,'Diana_Q_moonlight_champ.troy') and GetDistance(obj, MarkedEnemy) < 50 then
							MarkedEnemy = nil
							MarkTimer = nil
						end
					end
				end
			end
			if MarkTimer~=nil and MarkedEnemy~=nil and GetTickCount()-MarkTimer>3000 then
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

function OnProcessSpell(unit, spell)
	if unit ~= nil and spell ~= nil and unit.charName == myHero.charName then
		if spell.name == "DianaBasicAttack" then
			AA1 = true
			AA2 = false
			AA3 = false
		elseif spell.name == "DianaBasicAttack2" then
			AA1 = false
			AA2 = true
			AA3 = false
		elseif spell.name == "DianaBasicAttack3" then
			AA1 = false
			AA2 = false
			AA3 = true
		else
			AA1 = false
			AA2 = false
			AA3 = false
		end
		if spell.name == "DianaBasicAttack" or spell.name == "DianaBasicAttack2" or spell.name == "DianaBasicAttack3" and targetaa~=nil and spell.target.name == targetaa.name then
			attacked = true
		else
			attacked = false
		end
		if spell.name == "DianaBasicAttack" or spell.name == "DianaBasicAttack2" or spell.name == "DianaBasicAttack3" then
			timer = GetTickCount()
		end
	end
end

function Timer()
	if timer~=0 and GetTickCount()-timer>3500 then
		AA1 = false
		AA2 = false
		AA3 = false
		timer = 0
	end
	if timer == 0 or myHero.dead==1 then
		AA1 = false
		AA2 = false
		AA3 = false
		timer = 0
	end
end

function OnDraw()
	if myHero.dead==0 then
		if QRDY == 1 then CustomCircle(830,1,2,myHero)
		else CustomCircle(830,1,3,myHero)
		end
		if target~=nil then CustomCircle(75,3,2,target) end
		if AA1 then DrawTextObject("1", myHero, Color.Yellow)
		elseif AA2 then DrawTextObject("2", myHero, Color.Red)
		else DrawTextObject("0", myHero, Color.Green)
		end
	end
end

SetTimerCallback('Main')