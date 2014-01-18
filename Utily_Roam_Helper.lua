require 'Utils'
require 'spell_damage'
require 'uiconfig'
require 'winapi'
require 'SKeys'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'

local Enemies = {}
local EnemyIndex = 1
local HavocDamage = 0
local ExecutionerDamage = 0

function Main()
end

	RoamSettings, menu = uiconfig.add_menu('RoamHelper Settings', 200)
	menu.checkbutton('RoamHelper', 'Roam Helper', true)
	menu.permashow('RoamHelper')
	
for i = 1, objManager:GetMaxHeroes(), 1 do
	Hero = objManager:GetHero(i)
	if Hero ~= nil and Hero.team ~= myHero.team then
		if Enemies[Hero.name] == nil then
			Enemies[Hero.name] = { Unit = Hero, Number = EnemyIndex }
			EnemyIndex = EnemyIndex + 1
		end
	end
end

function OnDraw()
	if RoamSettings.RoamHelper then
		for i, Enemy in pairs(Enemies) do
			if Enemy ~= nil then
				Hero = Enemy.Unit	
				local PositionX = (13.3/16) * GetScreenX()
				local QDMG = getDmg('Q', Hero, myHero)+(getDmg('Q',Hero,myHero))
				local WDMG = getDmg('W', Hero, myHero)+(getDmg('W',Hero,myHero))
				local EDMG = getDmg('E', Hero, myHero)+(getDmg('E',Hero,myHero))
				local RDMG = getDmg('R', Hero, myHero)+(getDmg('R',Hero,myHero))
				local Current_Burst
				local Damage
				if myHero.selflevel >= 6 and myHero.SpellTimeR > 1.0 then
					Current_Burst = Round(QDMG + WDMG + EDMG + RDMG, 0) --Show damage of QWEEER combo if Ult is available
				else
					Current_Burst = Round(QDMG + WDMG + EDMG, 0) --Show damage of QWEEE combo if Ult is not available
				end
				Damage = Current_Burst
				DrawText("Champion: "..Hero.name, PositionX, ((15/900) * GetScreenY()) * Enemy.Number + ((53/90) * GetScreenY()), Color.SkyBlue)
				if Hero.visible == 1 and Hero.dead ~= 1 then
					if Damage < Hero.health then
						DrawText("DMG "..Damage, PositionX + 150, ((15/900) * GetScreenY()) * Enemy.Number + ((53/90) * GetScreenY()), Color.Yellow)
					elseif Damage > Hero.health then
						DrawText("Killable!", PositionX + 150, ((15/900) * GetScreenY()) * Enemy.Number + ((53/90) * GetScreenY()), Color.Red)
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

function Round(val, decimal)
	if (decimal) then
		return math.floor( (val * 10 ^ decimal) + 0.5) / (10 ^ decimal)
	else
		return math.floor(val + 0.5)
	end
end

SetTimerCallback("Main")