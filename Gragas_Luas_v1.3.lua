--Lua's DrukenBarrelRoll v1.3

require 'Utils'
require 'spell_damage'
require 'IsInvulnerable'
local uiconfig = require 'uiconfig'
if myHero.name ~= 'Gragas' then return end

local RDY, Boom, Barrel, QDMG, RDMG, QRDMG, Check, Hp = false, GetTickCount(), nil, nil, nil, nil, nil, nil
local BarrelSpot = {x=0, y=0, z=0}

Gragas, gragas = uiconfig.add_menu('DrukenBarrelRoll')
gragas.keytoggle('QR', 'DrukenBarrelRoll', Keys.F1, true)
gragas.checkbox('DrawCircle', 'Draw Circle that Killable Enemys', true)
gragas.permashow('QR')

function DrunkenRoll()
	if Gragas.QR and Barrel ~= nil and myHero.dead == 0 and myHero.SpellNameQ == 'gragasbarrelrolltoggle' then
		local RMana = 75+(GetSpellLevel('R')*25)
		if myHero.mana >= RMana and RMana ~= 75 and myHero.SpellTimeR >= 1 then RDY = true
		else RDY = false end
		for i= 1,objManager:GetMaxHeroes(),1 do
			local enemy=objManager:GetHero(i)
			if enemy.team ~= myHero.team and enemy.visible == 1 and enemy.dead == 0 and GetDistance(BarrelSpot, enemy) <= 280 and CheckStatus(enemy) then
				QDMG = getDmg('Q', enemy, myHero)
				if RDY then RDMG = getDmg('R', enemy, myHero)
				else RDMG = 0 end
				QRDMG = QDMG+RDMG
				check = IsInvulnerable(enemy)
				if check.name ~= 'Black Shield' then Hp = enemy.health
				else Hp = enemy.health+check.amount end
				if Hp < QDMG then CastSpellTarget('Q', myHero)
				elseif Hp < QRDMG and GetDistance(myHero, Barrel) < 1100 then
					CastSpellXYZ('R', BarrelSpot.x, 0, BarrelSpot.z)
					Boom = GetTickCount()
				end
			end
		end
		if GetTickCount()-Boom < 200 then CastSpellTarget('Q', myHero) end
	end
	if Gragas.DrawCircle then
		for i= 1,objManager:GetMaxHeroes(),1 do
			local enemy=objManager:GetHero(i)
			if enemy.team ~= myHero.team and enemy.visible == 1 and enemy.dead == 0 then
				QDMG = getDmg('Q', enemy, myHero)
				if RDY then RDMG = getDmg('R', enemy, myHero)
				else RDMG = 0 end
				QRDMG = QDMG+RDMG
				check = IsInvulnerable(enemy)
				if check.name ~= 'Black Shield' then Hp = enemy.health
				else Hp = enemy.health+check.amount end
				if Hp < QDMG then CustomCircle(150,5,2,enemy)
				elseif Hp < RDMG then CustomCircle(150,5,5,enemy)
				elseif Hp < QRDMG then CustomCircle(150,5,4,enemy) end
			end
		end
	end
end

function OnCreateObj(object)
	if object ~= nil then
		if string.find(object.charName, 'barrelroll_mis') ~= nil and GetDistance(myHero, object) < 50 then Barrel = object
		elseif string.find(object.charName, 'barrelfoam') ~= nil and GetDistance(BarrelSpot, object) < 10 then
			Barrel = object
			BarrelSpot.x, BarrelSpot.y, BarrelSpot.z = object.x, object.y, object.z
		elseif string.find(object.charName, 'barrelboom') ~= nil and GetDistance(BarrelSpot, object) < 10 then Barrel = nil end
	end
end

function OnProcessSpell(unit, spell)
	if unit ~= nil and spell ~= nil and unit.team == myHero.team and unit.name == myHero.name then
		if spell.name == 'GragasBarrelRoll' then BarrelSpot = spell.endPos
		elseif spell.name == 'gragasbarrelrolltoggle' then Barrel = nil end
	end
end

function CheckStatus(target)
	if target ~= nil then
		local var = IsInvulnerable(target)
		if var.status == 0 then return true
		elseif var.status == 1 and var.name ~= 'Chrono Shift' and var.name ~= 'Undying Rage' then return true
		elseif var.status == 1 then return false
		elseif var.name == 'Black Shield' then return true
		elseif var.status == 2 then return false
		elseif var.status == 3 then return false
		end
		return true
	else return false
	end
end

SetTimerCallback('DrunkenRoll')