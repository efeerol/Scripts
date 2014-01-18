require 'Utils'
require 'winapi'
local uiconfig = require 'uiconfig'
local version = '1.0'
local DomCap = false
local TeleportTimer = 0

function Main()
	if IsLolActive() then
		SetVariables()
		if RengarConfig.AutoW and WRDY==1 and target2~=nil and GetDistance(target2)<450 and DomCap==false then CastSpellTarget('W',target2) end
		if RengarConfig.AutoE and ERDY==1 and target2~=nil and DomCap==false then CastSpellTarget('E',target2) end
	end
end

	RengarConfig, menu = uiconfig.add_menu('Rengar Config', 200)
	menu.checkbutton('AutoQ', 'AutoQ', true)
	menu.checkbutton('AutoW', 'AutoW', true)
	menu.checkbutton('AutoE', 'AutoE', true)
	menu.checkbutton('AutoItems', 'AutoItems', true)
	menu.permashow('AutoQ')
	menu.permashow('AutoW')
	menu.permashow('AutoE')
	menu.permashow('AutoItems')
	
function SetVariables()
	target = GetWeakEnemy('PHYS',myHero.range+(GetDistance(GetMinBBox(myHero)))+50)
	target2 = GetWeakEnemy('PHYS',575)
	if myHero.SpellTimeQ > 1.0 and GetSpellLevel('Q')>0 then QRDY = 1
	else QRDY = 0 end
	if myHero.SpellTimeW > 1.0 and GetSpellLevel('W')>0 and myHero.mana < 5 then WRDY = 1
	else WRDY = 0 end
	if myHero.SpellTimeE > 1.0 and GetSpellLevel('E')>0 and myHero.mana < 5 then ERDY = 1
	else ERDY = 0 end
	if DomCap == true and TeleportTimer ~= 0 and GetTickCount() - TeleportTimer > 5000 then
		DomCap = false
		TeleportTimer = 0
	end
end

function OnProcessSpell(unit,spell)
    if unit ~= nil and spell ~= nil and unit.charName == myHero.charName then
 		if (spell.name == 'RengarBasicAttack' or spell.name == 'RengarBasicAttack2' or spell.name == 'RengarBasicAttack3' or spell.name == 'RengarCritAttack' or spell.name == 'RengarQ') and target~=nil and spell.target then
			if RengarConfig.AutoItems then UseAllItems(target) end
			if QRDY == 1 and RengarConfig.AutoQ then CastSpellTarget('Q',target) end
		end
	end
end

function OnCreateObj(obj)
	if obj ~= nil then
		if string.find(obj.charName, 'OdinCaptureBeam') and GetDistance(obj,myHero) < 50 then
			DomCap = true
		end
		if string.find(obj.charName, 'TeleportHome_shortImproved') and GetDistance(obj,myHero) < 50 then
			DomCap = true
			TeleportTimer = GetTickCount()
		end
		if string.find(obj.charName, 'OdinCaptureCancel') and GetDistance(obj,myHero) < 50 then
			DomCap = false
		end
		if string.find(obj.charName, 'teleportarrive') and GetDistance(obj,myHero) < 50 then
			DomCap = false
		end
	end
end

function IsLolActive()
    return tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client" and IsChatOpen() == 0
end

SetTimerCallback('Main')