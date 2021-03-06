--Lua's Little Card Picker v1.2

require "Utils"
local uiconfig = require 'uiconfig'
local target, WRDY
local NextCard = nil
local PickCard = false
local PickBlock = nil
local Locked = nil
local AARange = myHero.range+(GetDistance(GetMinBBox(myHero)))

TFMenu, tfmenu = uiconfig.add_menu('PickACard Menu')
tfmenu.keydown('TFRed', 'Pick @ Red', Keys.X)
tfmenu.keydown('TFBlue', 'Pick @ Blue', Keys.T)
tfmenu.keydown('TFGold', 'Pick @ Gold', Keys.C)
tfmenu.checkbutton('RangeCircle', 'AA Range Circle', true)
tfmenu.checkbutton('ShowPick', 'Shows Text while Pick a Card', true)
tfmenu.permashow('TFRed')
tfmenu.permashow('TFBlue')
tfmenu.permashow('TFGold')
--				Here Some notes for key binding who uses MouseX1,X2 Keys like me ._.
--				If you want to bind a key to MouseX1 or MouseX2
--					MouseX1 == 5, MouseX2 == 6
--				Change Keys.? to Mouse keycodes
--
--				Example for Blue Card Pick to MouseX1
--				tfmenu.keydown('TFBlue', 'Pick @ Blue', 5)
--
--					Enjoy ._.

function GimmeACard()
	if tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client" and IsChatOpen() == 0 then
		if TFMenu.RangeCircle then
			AARange = myHero.range+(GetDistance(GetMinBBox(myHero)))
			CustomCircle(AARange, 5, 3, myHero)
		end
		if Locked ~= nil and GetTickCount()-Locked > 4500 then Locked = nil end
		if myHero.SpellTimeW > 0.9 and GetSpellLevel('W') > 0 and Locked == nil then WRDY = 1
		else WRDY = 0 end
		if IsChatOpen() == 0 and myHero.dead == 0 then
			if PickBlock ~= nil and GetTickCount()-PickBlock > 1000 then PickBlock = nil end
			if TFMenu.TFBlue and WRDY == 1 then NextCard = 'Blue'
			elseif TFMenu.TFGold and WRDY == 1 then NextCard = 'Gold'
			elseif TFMenu.TFRed and WRDY == 1 then NextCard = 'Red' end
			if WRDY == 1 and NextCard ~= nil and PickBlock == nil and myHero.SpellNameW == 'PickACard' then
				PickBlock = GetTickCount()
				CastSpellTarget('W',myHero)
			end
			if TFMenu.ShowPick and NextCard ~= nil then
				if NextCard ~= 'Gold' then DrawTextObject(NextCard,myHero,Color[NextCard])
				else DrawTextObject(NextCard,myHero,Color.Yellow) end
			end
			if PickCard and Locked == nil then CastSpellTarget('W',myHero) end
		end
	end
end

function OnProcessSpell(unit,spell)
	if spell ~= nil and unit ~= nil and unit.team == myHero.team and unit.name == myHero.name then
		if spell.name == 'PickACard' then PickBlock = GetTickCount()
		elseif NextCard ~= nil and NextCard == 'Blue' and spell.name == 'bluecardlock' then
			Locked = GetTickCount()
			PickCard = false
			NextCard = nil
		elseif NextCard ~= nil and NextCard == 'Gold' and spell.name == 'goldcardlock' then
			Locked = GetTickCount()
			PickCard = false
			NextCard = nil
		elseif NextCard ~= nil and NextCard == 'Red' and spell.name == 'redcardlock' then
			Locked = GetTickCount()
			PickCard = false
			NextCard = nil
		end
	end
end

function OnCreateObj(obj)
	if obj ~= nil and NextCard ~= nil and string.find(obj.charName, NextCard) ~= nil and GetDistance(obj, myHero) < 100 then
		PickCard = true
		CastSpellTarget('W',myHero)
	end
end

SetTimerCallback('GimmeACard')