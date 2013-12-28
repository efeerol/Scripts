require 'Utils'
require 'winapi'
require 'SKeys'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'

local wUsedAt = 0
local vUsedAt = 0
local mUsedAt = 0
local timer = os.clock()
local bluePill = nil
local version = '1.1'

function Main()
	if CfgPotions.AutoPotions then RedElixir() end
end

	CfgPotions, menu = uiconfig.add_menu('Potions', 200)
	menu.checkbutton('AutoPotions', 'Master Switch: Potions', true)
	menu.checkbutton('Health_Potion_ONOFF', 'Health Potions', true)
	menu.checkbutton('Mana_Potion_ONOFF', 'Mana Potions', true)
	menu.checkbutton('Chrystalline_Flask_ONOFF', 'Chrystalline Flask', true)
	menu.checkbutton('Elixir_of_Fortitude_ONOFF', 'Elixir of Fortitude', true)
	menu.checkbutton('Biscuit_ONOFF', 'Biscuit', true)
	menu.slider('Health_Potion_Value', 'Health Potion Value', 0, 100, 75, nil, true)
	menu.slider('Mana_Potion_Value', 'Mana Potion Value', 0, 100, 75, nil, true)
	menu.slider('Chrystalline_Flask_Value', 'Chrystalline Flask Value', 0, 100, 75, nil, true)
	menu.slider('Elixir_of_Fortitude_Value', 'Elixir of Fortitude Value', 0, 100, 30, nil, true)
	menu.slider('Biscuit_Value', 'Biscuit Value', 0, 100, 60, nil, true)
	menu.permashow('AutoPotions')
	
	
function RedElixir()
	if bluePill == nil then
		if myHero.health < myHero.maxHealth * (CfgPotions.Health_Potion_Value / 100) and GetClock() > wUsedAt + 15000 then
			usePotion()
			useBiscuit()
			wUsedAt = GetTick()
		elseif myHero.health < myHero.maxHealth * (CfgPotions.Chrystalline_Flask_Value / 100) and GetClock() > vUsedAt + 10000 then 
			useFlask()
			vUsedAt = GetTick()
		elseif myHero.health < myHero.maxHealth * (CfgPotions.Biscuit_Value / 100) then
			useBiscuit()
		elseif myHero.health < myHero.maxHealth * (CfgPotions.Elixir_of_Fortitude_Value / 100) then
			useElixir()
		end
		if myHero.mana < myHero.maxMana * (CfgPotions.Mana_Potion_Value / 100) and GetClock() > mUsedAt + 15000 then
			useManaPot()
			mUsedAt = GetTick()
		end
	end
	if (os.clock() < timer + 5000) then
		bluePill = nil 
	end
end
function OnCreateObj(object)
	if (GetDistance(myHero, object)) < 100 then
		if string.find(object.charName,"FountainHeal") then
			timer=os.clock()
			bluePill = object
		end
	end
end
function usePotion()
	GetInventorySlot(2003)
	UseItemOnTarget(2003,myHero)
end
function useBiscuit()
	GetInventorySlot(2009)
	UseItemOnTarget(2009,myHero)
end
function useFlask()
	GetInventorySlot(2041)
	UseItemOnTarget(2041,myHero)
end
function useBiscuit()
	GetInventorySlot(2009)
	UseItemOnTarget(2009,myHero)
end
function useElixir()
	GetInventorySlot(2037)
	UseItemOnTarget(2037,myHero)
end
function useManaPot()
	GetInventorySlot(2004)
	UseItemOnTarget(2004,myHero)
end
function GetTick()
	return GetClock()
end

SetTimerCallback("Main")