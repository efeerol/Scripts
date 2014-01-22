require 'Utils'
require 'winapi'
require 'SKeys'
require 'spell_damage'
require 'vals_lib'
local Q,W,E,R = 'Q','W','E','R'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local version = '0.3.4'
local target
local stacks = 0
local timer = 0
local duration = 5000
local Minions = { }
local SORT_CUSTOM = function(a, b) return a.maxHealth and b.maxHealth and a.maxHealth < b.maxHealth end

function Main()
	target = GetWeakEnemy('PHYS',475)
	AArange = myHero.range+(GetDistance(GetMinBBox(myHero)))
	Minions = GetEnemyMinions(SORT_CUSTOM)
	GetCD()
	GetStacks()
	if YasouHotkeys.AutoR then AutoR() end
	if YasouHotkeys.AutoQ then AutoQ() end
	if YasouHotkeys.AutoQ==false and YasouHotkeys.SemiAutoQ then SemiAutoQ() end 
	if YasouHotkeys.AAreset then AAreset() end
	if YasouHotkeys.AutoFarm or YasouHotkeys.AutoFarmToggle then AutoFarm() end
	if YasouHotkeys.Killsteal then Killsteal() end
end

	YasouHotkeys, menu = uiconfig.add_menu('Yasou hotkeys', 200)
	menu.keydown('SemiAutoQ', 'SemiAutoQ', Keys.Y)
	menu.keydown('AutoFarm', 'AutoFarm', Keys.Z)
	menu.keytoggle('AutoR', 'AutoR', Keys.F1, true)
	menu.keytoggle('AutoQ', 'AutoQ', Keys.F2, false)
	menu.keytoggle('AutoEQ', 'AutoEQ', Keys.F3, true)
	menu.keytoggle('AAreset', 'AAreset', Keys.F4, true)
	menu.keytoggle('AutoFarmToggle', 'AutoFarmToggle', Keys.F5, true)
	menu.keytoggle('UseItems', 'UseItems', Keys.F6, true)
	menu.keytoggle('Killsteal', 'Killsteal', Keys.F7, true)
	menu.permashow('SemiAutoQ')
	menu.permashow('AutoFarm')
	menu.permashow('AutoR')
	menu.permashow('AutoQ')
	menu.permashow('AutoEQ')
	menu.permashow('AAreset')
	menu.permashow('AutoFarmToggle')
	menu.permashow('Killsteal')

function GetStacks()
	if myHero.SpellNameQ == 'YasuoQW' then
		Q1 = 1
		Q2 = 0
		Q3 = 0
	elseif myHero.SpellNameQ == 'yasuoq2w' then
		Q1 = 0
		Q2 = 1
		Q3 = 0
	elseif myHero.SpellNameQ == 'yasuoq3w' then
		Q1 = 0
		Q2 = 0
		Q3 = 1
	end

	for i = 1, objManager:GetMaxNewObjects(), 1 do
	local object = objManager:GetNewObject(i)
		if stacks == 0 then
			if object.charName~=nil and string.find(object.charName,'Yasuo_Base_E_Dash') and GetDistance(myHero, object) < 100 then
				timer = GetTickCount()
				stacks = 1
			end
		elseif stacks == 1 then
			if object.charName~=nil and string.find(object.charName,'Yasuo_Base_E_Dash') and GetDistance(myHero, object) < 100 then
				timer = GetTickCount()
				stacks = 2
			end
		elseif stacks == 2 then
			if object.charName~=nil and string.find(object.charName,'Yasuo_Base_E_Dash') and GetDistance(myHero, object) < 100 then
				timer = GetTickCount()
				stacks = 3
			end
		elseif stacks == 3 then
			if object.charName~=nil and string.find(object.charName,'Yasuo_Base_E_Dash') and GetDistance(myHero, object) < 100 then
				timer = GetTickCount()
				stacks = 4
			end
		elseif stacks == 4 then
			if object.charName~=nil and string.find(object.charName,'Yasuo_Base_E_Dash') and GetDistance(myHero, object) < 100 then
				timer = GetTickCount()
			end
		end
	end
	if myHero.dead==1 or (timer~=0 and GetTickCount()-timer>duration) then
		stacks = 0
		timer = 0
	end
	if target~=nil then
		CustomCircle(100, 2, 2, target)
	end
end

function Killsteal()
	if target~=nil then
		local AAdam = getDmg("AD",target,myHero)
		local Qdam = (getDmg("Q",target,myHero))*QRDY
		local Edam = (getDmg("E",target,myHero,1))*ERDY -- base damage
		local stackdam = (getDmg("E",target,myHero,2)*stacks)*ERDY -- dam from AP
		local maxdam = (Edam+stackdam+getDmg("E",target,myHero,3))*ERDY
		local Rdam = (getDmg("R",target,myHero))*Q3*RRDY
		
		if target.health<maxdam+Qdam+Edam+Rdam then
			CastSpellTarget('E',target)
			CastSpellXYZ('Q',target.x,target.y,target.z)
			if not YasouHotkeys.AutoR then AutoR() end
		end
	end
end

function AutoFarm()
	for i, Minion in pairs(Minions) do	
		if Minion~=nil then
			local AAdam = getDmg("AD",Minion,myHero)
			local Qdam = getDmg("Q",Minion,myHero)
			local Edam = getDmg("E",Minion,myHero,1) -- base damage
			local stackdam = getDmg("E",Minion,myHero,2)*stacks -- dam from AP
			local maxdam = Edam+stackdam+getDmg("E",Minion,myHero,3)
			
			if Minion.dead==0 and Minion.health<Qdam and Q3==0 and myHero.SpellTimeQ > 1.0 and GetSpellLevel('Q') > 0 then
				CustomCircle(75, 1, 2, Minion)
				if GetDistance(myHero,Minion)<475 then
					CastSpellXYZ('Q',Minion.x,Minion.y,Minion.z)
				end
			elseif Minion.dead==0 and Minion.health<maxdam and myHero.SpellTimeE > 1.0 and GetSpellLevel('E') > 0 then
				CustomCircle(75, 1, 2, Minion)
				if GetDistance(myHero,Minion)<475 then
					CastSpellTarget('E',Minion)
				end
			end
		end
	end
end

function AAreset()
	if target~=nil then
		for i = 1, objManager:GetMaxNewObjects(), 1 do
		local object = objManager:GetNewObject(i)
			if object.charName~=nil and (string.find(object.charName,'Yasuo_base_BA_hit') or string.find(object.charName,'Yasuo_Base_BA_crit_hit')) and GetDistance(object, target) < 100 and GetDistance(myHero,target)<AArange then
				if YasouHotkeys.UseItems then UseAllItems(target) end
				if myHero.SpellTimeQ > 1.0 and GetSpellLevel('Q') > 0 then
					CastSpellXYZ('Q',target.x,target.y,target.z)
				end
			end
		end
	end
end

function AutoQ()
	if target~=nil then
		if myHero.SpellTimeQ > 1.0 and GetSpellLevel('Q') > 0 and Q3 == 0 then
			CastSpellXYZ('Q',target.x,target.y,target.z)
		elseif myHero.SpellTimeQ > 1.0 and GetSpellLevel('Q') > 0 and myHero.SpellTimeE > 1.0 and GetSpellLevel('E') > 0 and Q3 == 1 then
			CastSpellTarget('E',target)
			CastSpellXYZ('Q',target.x,target.y,target.z)
		end
	end
end

function SemiAutoQ()
	if myHero.SpellTimeQ > 1.0 and GetSpellLevel('Q') > 0 then
		if target~=nil and GetDistance(target)<475 then
			CastSpellXYZ('Q',target.x,target.y,target.z)
		elseif target==nil then
			for i, Minion in pairs(Minions) do	
				if Minion~=nil and GetDistance(Minion)<475 then
					CastSpellXYZ('Q',Minion.x,Minion.y,Minion.z)
				end
			end
		end
	end
end

function AutoR()
	for i = 1, objManager:GetMaxNewObjects(), 1 do
		local object = objManager:GetNewObject(i)
		if object~= nil then
			if object.charName == 'Yasuo_base_R_indicator_beam.troy' then
				if myHero.SpellTimeR > 1.0 and GetSpellLevel('R') > 0 then
					CastSpellXYZ('R',myHero.x,myHero.y,myHero.z)
				end
			end
		end
	end
end

function OnProcessSpell(unit, spell)
	if unit ~= nil and spell ~= nil and unit.charName == myHero.charName then
		if YasouHotkeys.AutoEQ then
			for i = 1, objManager:GetMaxHeroes() do
				local enemy = objManager:GetHero(i)
				if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0 and enemy.dead == 0) then
					for i, Minion in pairs(Minions) do	
						if spell.name == 'YasuoDashWrapper' and spell.target and spell.target.name==enemy.name and spell.target.name~=Minion.name then
							if myHero.SpellTimeQ > 1.0 and GetSpellLevel('Q') > 0 then
								CastSpellXYZ('Q',enemy.x,enemy.y,enemy.z)
							end
							if target~=nil and GetDistance(myHero,target)<AArange then
								AttackTarget(target)
							end
						end
					end
				end
			end
		end
	end
end

SetTimerCallback('Main')