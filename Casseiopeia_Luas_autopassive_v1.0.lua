--[[
											
											
											
				Lua's Cass-i-op-eia AutoPassive
											v1.0
											
											
																	]]--

require 'Utils'
local uiconfig = require 'uiconfig'
local target
local LastSpell = GetTickCount()
local PassiveStacks = 0
local Recall = {Time = 0, X = 0, Y = 0, Z = 0}

function onTick()
	target = GetWeakEnemy('MAGIC', 840)

	if Recall.Time ~= 0 and GetTickCount()-Recall.Time < 8000 then
		if myHero.x ~= Recall.X or myHero.y ~= Recall.Y or myHero.z ~= Recall.Z then
			Recall = {Time = 0, X = 0, Y = 0, Z = 0}
		end
	elseif Recall.Time ~= 0 and GetTickCount()-Recall.Time > 8000 then Recall = {Time = 0, X = 0, Y = 0, Z = 0}
	end

	if PassiveStacks > 0 and myHero.dead == 0 and Recall.Time == 0 and GetTickCount()-LastSpell >= 4650 and GetTickCount()-LastSpell < 5000 then
		if (myHero.mana/myHero.maxMana*100) >= CassioMenu.ManaLimit and CassioMenu.AutoPassive and target == nil then
			if myHero.SpellTimeQ >= 1 and GetSpellLevel('Q') > 0 and GetLowestHealthEnemyMinion(840) ~= nil then
				target = GetLowestHealthEnemyMinion(840)
				CastSpellXYZ('Q',GetFireahead(target,3,99))
			end
		elseif (myHero.mana/myHero.maxMana*100) >= CassioMenu.ManaLimit and CassioMenu.AutoPassive and target ~= nil and myHero.SpellTimeQ >= 1 and GetSpellLevel('Q') > 0 then CastSpellXYZ('Q',GetFireahead(target,3,99))
		elseif GetTickCount()-LastSpell >= 5000 then
			PassiveStacks = 0
		end
	elseif myHero.dead == 1 or GetTickCount()-LastSpell >= 5000 then
		PassiveStacks = 0
	end
end
	
	CassioMenu, cassmenu = uiconfig.add_menu('Cassiopeia Menu')
	cassmenu.checkbutton('AutoPassive', 'Auto-Passive Stacks', true)
	cassmenu.slider('ManaLimit', 'Mana Limit', 5, 90, 30)
	cassmenu.permashow('AutoPassive')

function OnCreateObj(object)
	if object.charName == 'CassDeadlyCadence_buf.troy' and GetTickCount()-LastSpell < 100 then
		if PassiveStacks < 5 then PassiveStacks = PassiveStacks+1 end
		LastSpell = GetTickCount()
	end
end

function OnProcessSpell(unit,spell)
	if unit.team == myHero.team and unit.name == myHero.name and spell.name ~= nil then
		if spell.name == 'CassiopeiaNoxiousBlast' or spell.name == 'CassiopeiaTwinFang' or spell.name == 'CassiopeiaMiasma' or spell.name == 'CassiopeiaPetrifyingGaze' then
			LastSpell = GetTickCount()
		end
		if string.find(spell.name,"Recall") ~= nil then
			Recall.Time = GetTickCount()
			Recall.X,Recall.Y,Recall.Z = myHero.x,myHero.y,myHero.z
		end
	end
end

SetTimerCallback('onTick')