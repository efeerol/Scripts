require 'Utils'
require 'winapi'
require 'SKeys'
require 'spell_damage'
require 'vals_lib'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local ui = require 'simpleui'
local draw = require 'simpleui_drawing'
local Q,W,E,R = 'Q','W','E','R'
function Main()
        if myHero.name == "Vayne" then
                if VayneConfig.AutoE and IsChatOpen() == 0 then AutoCondemn() end
        end
		GetCD()
end
--[Menu]--
VayneConfig, menu = uiconfig.add_menu('Auto-Condemn', 200)
menu.checkbutton('AutoE', 'Auto-Condemn', true)
--[Auto-Condemn]--
function AutoCondemn()
local target = GetWeakEnemy('PHYS',550)
    if target ~= nil and WillHitWall(target,540) == 1 then
			CastSpellTarget('E', target)
			end
end
SetTimerCallback("Main")