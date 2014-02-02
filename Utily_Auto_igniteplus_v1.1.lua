--[[
--AutoIgnitePlus v1.1 by Lua

----Option
------F1: Enable/Disable the script
------Auto Ignite Guardian Angel?: default is Enabled
------Auto Ignite Egg?: Ignite Anivia even Eggnivia passive is on! default is Disabled
------Auto Ignite Aatrox?: Ignite Aatrox even Rebirth passive is on! default is Disabled
------Auto Ignite Zac?: Ignite Zac even Rebirth passive is on! default is Disabled

----Features
List is on IgniteTarget lib
]]--
require 'Utils'
require 'IgniteTarget' --Download it from http://leaguebot.net/forum/Upload/showthread.php?tid=3164
local uiconfig = require 'uiconfig' --http://leaguebot.net/forum/Upload/showthread.php?tid=2153
local target
local Key = nil
local lastCheck = {name = nil, time = GetTickCount()}

	IgnitePlus, burnmenu = uiconfig.add_menu('AutoIgnitePlus Menu')
	burnmenu.keytoggle('AutoIgnite', 'Auto Ignite', Keys.F1, true)
	burnmenu.checkbutton('BurnGA', 'Ignite Guardian Angel', true)
	burnmenu.checkbutton('BurnEgg', 'Ignite Anivia even Eggnivia passive', false)
	burnmenu.checkbutton('BurnAatrox', 'Ignite Aatrox even Rebirth passive', false)
	burnmenu.checkbutton('BurnZac', 'Ignite Zac even Rebirth passive', false)
	burnmenu.permashow('AutoIgnite')

if myHero.SummonerD == 'SummonerDot' then Key = 'D'
elseif myHero.SummonerF == 'SummonerDot' then Key = 'F'
else
	print('Nope ._.')
	return
end

function OnTick()
	target = GetWeakEnemy('TRUE',650)
	if target ~= nil and Key ~= nil and IgnitePlus.AutoIgnite then
		IgniteTarget(target, Key, IgnitePlus.BurnGA, IgnitePlus.BurnEgg, IgnitePlus.BurnAatrox, IgnitePlus.BurnZac)
	end
end

SetTimerCallback('OnTick')