-- REQUIRED FILES:
-- vals_lib.lua (v1.11+) http://leaguebot.net/forum/Upload/showthread.php?tid=3014
-- yonders installer http://leaguebot.net/forum/Upload/showthread.php?tid=2185

require 'Utils'
require 'winapi'
require 'SKeys'
require 'vals_lib'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local Q,W,E,R = 'Q','W','E','R'
local version = '2.7'

	AkaliConf, menu = uiconfig.add_menu('Akali Hotkeys', 250)
	menu.keydown('Combo', 'Combo', Keys.X)
	menu.keydown('UseW', 'Use W', Keys.W)
	menu.checkbutton('Killsteal', 'Killsteal', true)
	menu.checkbutton('useItems', 'useItems', true)
	menu.checkbutton('Ignite', 'Ignite', false)
	menu.permashow('Combo')
	menu.permashow('UseW')
	menu.permashow('Killsteal')
	menu.permashow('useItems')
	menu.permashow('Ignite')

function Main()
	if IsLolActive() then
		GetCD()
		target = GetWeakEnemy('MAGIC',800)
		if AkaliConf.Combo then Combo() end
		if AkaliConf.Killsteal then Killsteal() end
		if AkaliConf.Ignite then Ignite() end
		if AkaliConf.UseW then UseW() end
	end
end

function Combo()
	if ValidTarget(target,800) then
		if not IsBuffed(target,'markOftheAssasin') then SpellTarget(Q,QRDY,myHero,target,600) end
		SpellTarget(R,RRDY,myHero,target,800)
		if AkaliConf.useItems then UseAllItems(target) end
		SpellXYZ(E,ERDY,myHero,target,325,myHero.x,myHero.z)
		if GetDistance(target)<AArange+50 then AttackTarget(target) end
		if GetDistance(target)<325 then MoveTarget(target) 
		else MoveMouse() end
	else MoveMouse()
	end
end

function UseW()
	SpellXYZ(W,WRDY,myHero,myHero,100,myHero.x,myHero.z)
	StopMove()
end

function Killsteal()
	if ValidTarget(target,800) then
		if IsBuffed(target,'markOftheAssasin') then targetbuff = 1
		else targetbuff = 0 end
		local effhealth = target.health*(1+(((target.magicArmor*myHero.magicPenPercent)-myHero.magicPen)/100))
		if ERDY==0 then AA = (myHero.baseDamage+myHero.addDamage)+((6+(.1666667*myHero.ap))*((myHero.baseDamage+myHero.addDamage)/100))+((20+(myHero.SpellLevelQ*25)+(myHero.ap*.5))*targetbuff)
		else AA = (myHero.baseDamage+myHero.addDamage)+((6+(.1666667*myHero.ap))*((myHero.baseDamage+myHero.addDamage)/100)) end
		local xQ = ((15+(myHero.SpellLevelQ*20)+(myHero.ap*.4))*QRDY)
		local xE = ((5+(myHero.SpellLevelE*25)+(myHero.ap*.3)+((myHero.baseDamage+myHero.addDamage)*.6))+((20+(myHero.SpellLevelQ*25)+(myHero.ap*.5))*targetbuff)*ERDY)
		local xR = ((25+(myHero.SpellLevelR*75)+(myHero.ap*.5))*RRDY)
		if effhealth<(AA+xQ+xE+xR)*RRDY then
			SpellTarget(Q,QRDY,myHero,target,600)
			SpellTarget(R,RRDY,myHero,target,800)
			if AkaliConf.useItems then UseAllItems(target) end
			SpellXYZ(E,ERDY,myHero,target,325,myHero.x,myHero.z)
			if GetDistance(target)<AArange+50 then AttackTarget(target) end
		end
	end
end

function Ignite()
	if (myHero.SummonerD == 'SummonerDot' and myHero.SpellTimeD>1) or (myHero.SummonerF == 'SummonerDot' and myHero.SpellTimeF>1) then IGN = 1
    else IGN = 0 end
	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if (enemy~=nil and enemy.team~=myHero.team and enemy.visible==1 and enemy.invulnerable==0 and enemy.dead==0) and GetDistance(enemy)<600 then
			local IGNdam = (50+(myHero.selflevel*20))*IGN
			if enemy.health<IGNdam then CastSummonerIgnite(enemy) end
		end
	end
end
	
function OnDraw()
    if myHero.dead == 0 then
		if QRDY == 1 then CustomCircle(600,1,3,myHero) end
		if RRDY == 1 then CustomCircle(800,1,2,myHero) end
		if target ~= nil then CustomCircle(100,4,2,target) end	
		for i = 1, objManager:GetMaxHeroes() do
			local enemy = objManager:GetHero(i)
			if (enemy~=nil and enemy.team~=myHero.team and enemy.visible==1 and enemy.invulnerable==0 and enemy.dead==0) then
				if IsBuffed(target,'markOftheAssasin') then targetbuff = 1
				else targetbuff = 0 end
				local effhealth = enemy.health*(1+(((enemy.magicArmor*myHero.magicPenPercent)-myHero.magicPen)/100))
				if ERDY==0 then AA = (myHero.baseDamage+myHero.addDamage)+((6+(.1666667*myHero.ap))*((myHero.baseDamage+myHero.addDamage)/100))+((20+(myHero.SpellLevelQ*25)+(myHero.ap*.5))*targetbuff)
				else AA = (myHero.baseDamage+myHero.addDamage)+((6+(.1666667*myHero.ap))*((myHero.baseDamage+myHero.addDamage)/100)) end
				local xQ = ((15+(myHero.SpellLevelQ*20)+(myHero.ap*.4))*QRDY)
				local xE = ((5+(myHero.SpellLevelE*25)+(myHero.ap*.3)+((myHero.baseDamage+myHero.addDamage)*.6))+((20+(myHero.SpellLevelQ*25)+(myHero.ap*.5))*targetbuff)*ERDY)
				local xR = ((25+(myHero.SpellLevelR*75)+(myHero.ap*.5))*RRDY)
				if effhealth<(AA+xQ+xE+xR)*RRDY then
					CustomCircle(100,4,2,enemy)
					DrawTextObject('KILL',enemy,Color.Yellow)
				end
			end
		end
	end
end

SetTimerCallback('Main')