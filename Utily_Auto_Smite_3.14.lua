--[[

	Auto-Smite
	Updated for V3.14

]]--


require 'Utils'
require 'spell_damage'
require 'uiconfig'
require 'winapi'
require 'SKeys'

-- [[ Variables ]] --

local smiteTargets = {
	Baron   = { Object = nil, Match = "Worm12.1.1" },
	Dragon  = { Object = nil, Match = "Dragon6.1.1" },
	AncientGolem1  = { Object = nil, Match = "AncientGolem1.1.1" },
	Golem2  = { Object = nil, Match = "AncientGolem7.1.1" },
	Lizard1 = { Object = nil, Match = "LizardElder4.1.1"  },
	Lizard2 = { Object = nil, Match = "LizardElder10.1.1" }
}

local smitedamage = {390, 410, 430, 450, 480, 510, 540, 570, 600, 640, 680, 720, 760, 800, 850, 900, 950, 1000}

local key

local uiconfig = require 'uiconfig'

-- [[ End of Variables ]] --

-- [[ Script Menu ]] --

CfgSettings, menu = uiconfig.add_menu('AutoSmite', 200)
menu.keytoggle('AutoSmite', 'Auto-Smite', Keys.Z, true)
menu.permashow("AutoSmite")

-- [[ End of Script Menu ]] --

-- [[ Core Functions ]] --

function onTick()
	AutoSmite()
	UpdateTables()
end

function AutoSmite()
	if myHero.SummonerD == 'SummonerSmite' then
		key = "D"
	elseif myHero.SummonerF == 'SummonerSmite' then
		key = "F"
	end

     if key ~= nil then
     	if IsSpellReady(key) == 1 and CfgSettings.AutoSmite then
     		for i, minion in pairs(smiteTargets) do
     			if minion ~= nil and minion.Object ~= nil and GetDistance(minion.Object) <= 650 and minion.Object.health <= smitedamage[myHero.selflevel] then
     				CastSpellTarget(key, minion.Object)
     			end
     		end
     	end
    end
end

function UpdateTables()
	for i, creep in pairs(smiteTargets) do
		if creep.Object == nil or creep.Object.dead == 1 then
			creep.object = nil
		end
	end
	for i=1, objManager:GetMaxNewObjects(), 1 do
		object = objManager:GetNewObject(i)
		if object and object ~= nil and object.charName ~= nil then
			for t, creep in pairs(smiteTargets) do
				if object.charName == creep.Match then creep.Object = object end
			end
		end
	end
end

-- [[ End of Core Functions ]] --

SetTimerCallback("onTick")