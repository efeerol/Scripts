require 'Utils'
require 'winapi'
require 'SKeys'
require "spell_damage"
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local Q,W,E,R = 'Q','W','E','R'
local version = "1.11"
----------------------------------------------------------------------
local skillshotArray = {}
local show_allies = 0
local xa = 50/1920*GetScreenX()
local xb = 1870/1920*GetScreenX()
local ya = 50/1080*GetScreenY()
local yb = 1030/1080*GetScreenY()
local CounterQ = {}
local Registry = {}
local timer1,timer2,timer3,timer4,timer5,timer6,timer7,timer8 = 0,0,0,0,0,0,0,0
local SphereA,SphereB,SphereC,SphereD,SphereE,SphereF = false,false,false,false,false,false
local SA,SB,SC,SD,SE,SF = 0,0,0,0,0,0
local SAX,SAY,SBX,SBZ,SCX,SCZ,SDX,SDZ,SEX,SEZ,SFX,SFZ = nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
local count = 15
----------------------------------------------------------------------
local targetHero
local range = myHero.range + GetDistance(GetMinBBox(myHero))
local HavocDamage = 0
local ExecutionerDamage = 0
local True_Attack_Damage_Against_Minions = 0
local SORT_CUSTOM = function(a, b) return a.maxHealth and b.maxHealth and a.maxHealth < b.maxHealth end
----------------------------------------------------------------------
local skillingOrder = {Syndra = {Q,W,E,Q,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E}}
----------------------------------------------------------------------
local Target, M_Target
local TEAM
if myHero.team == 100 then
	TEAM = "Blue"
else
	TEAM = "Red"
end
local Syndra = { projSpeed = 1.2, aaParticles = {"Syndra_attack_hit", "Syndra_attack_mis"}, aaSpellName = {"sorakabasicattack"}, startAttackSpeed = "0.625"}
local MinionInfo = { }
MinionInfo[TEAM.."_Minion_Basic"] 		= 	{ aaDelay = 400, projSpeed = 0		}
MinionInfo[TEAM.."_Minion_Caster"] 		=	{ aaDelay = 484, projSpeed = 0.68	}
MinionInfo[TEAM.."_Minion_Wizard"]		=	{ aaDelay = 484, projSpeed = 0.68	}
MinionInfo[TEAM.."_Minion_MechCannon"] 	=	{ aaDelay = 365, projSpeed = 1.18	}
local Minions = { }
local aaDelay = 320
local aaPos = {x = 0, z = 0}
local Ping = 60
local IncomingDamage = { }
local AnimationBeginTimer = 0
local AnimationSpeedTimer = 0.1 * (1 / myHero.attackspeed)
local TimeToAA = os.clock()
local wUsedAt = 0
local vUsedAt = 0
local mUsedAt = 0
local timer = os.clock()
local bluePill = nil
local Enemies = {}
local EnemyIndex = 1
----------------------------------------------------------------------

function Main()
	if IsChatOpen() == 0 and myHero.name == 'Syndra' then
		SphereManager()
		SetVariables()
		Mastery_Damage()
		Syndra_Items()
		if CfgPotions.Red_Elixir_ONOFF then RedElixir() end
		if SyndraHotkeys.PassiveFarm and SyndraConf.DMG_Predict_Farm_ONOFF then
			Farm()
		elseif SyndraHotkeys.PassiveFarm then
			Hybrid()
		end
		if SyndraHotkeys.Stun then Stun() end
		if SyndraHotkeys.Slow then Slow() end
		if SyndraHotkeys.Harass or SyndraHotkeys.AutoHarass then Harass() end
		if SyndraConf.Killsteal then Killsteal() end
		if SyndraConf.autolevel then Autolevel() end
		if SyndraConf.drawskillshots then Skillshots() end
		
	end
end
	
	SyndraHotkeys, menu = uiconfig.add_menu('1) Syndra hotkeys', 250)
	menu.keydown('Harass', 'Harass', Keys.Z)
	menu.keydown('Slow', 'Slow', Keys.X)
	menu.keydown('Stun', 'Stun', Keys.Y)
	menu.keydown('PassiveFarm', 'Farm', Keys.C)
	menu.keytoggle('AutoHarass', 'Auto-Harass', Keys.F1, true)
	menu.permashow('Harass')
	menu.permashow('Slow')
	menu.permashow('Stun')
	menu.permashow('AutoHarass')
	menu.permashow('PassiveFarm')
	
	SyndraConf, menu = uiconfig.add_menu('2) Syndra config', 250)
	menu.checkbutton('Killsteal', 'Killsteal', true)
	menu.checkbutton('autolevel', 'Auto Level', false)
	menu.checkbutton('drawskillshots', 'Draw Skillshots', true)
	menu.checkbutton('dodgeskillshots', 'dodge Skillshots', true)
	menu.checkbutton('RoamHelper_ONOFF', 'Roam Helper', true)
	menu.checkbutton('DMG_Predict_Farm_ONOFF', 'Use Damage Prediction Farming', true)
	menu.permashow('Killsteal')
	
	CfgMasteries, menu = uiconfig.add_menu('4) Syndra Masteries', 250)
	menu.slider('Butcher_Mastery', 'Butcher', 0, 2, 2, nil, true)
	menu.slider('Havoc_Mastery', 'Havoc', 0, 3, 3, nil, true)
	menu.slider('Brute_Force_Mastery', 'Brute Force', 0, 2, 0, nil, true)
	menu.checkbutton('Spellsword_Mastery', 'Spellsword', true)
	menu.checkbutton('Executioner_Mastery', 'Executioner', true)
	
	CfgPotions, menu = uiconfig.add_menu('5) Potions', 250)
	menu.checkbutton('Red_Elixir_ONOFF', 'Master Switch: Potions', true)
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

	CfgItems, menu = uiconfig.add_menu('6) Items', 250)
	menu.checkbutton('Zhonyas_Hourglass_ONOFF', 'Zhonyas Hourglass', true)
	menu.checkbutton('Wooglets_Witchcap_ONOFF', 'Wooglets Witchcap', true)
	menu.checkbutton('Seraphs_Embrace_ONOFF', 'Seraphs Embrace', true)
	menu.slider('Zhonyas_Hourglass_Value', 'Zhonya Hourglass Value', 0, 100, 15, nil, true)
	menu.slider('Wooglets_Witchcap_Value', 'Wooglets Witchcap Value', 0, 100, 15, nil, true)
	menu.slider('Seraphs_Embrace_Value', 'Seraphs Embrace Value', 0, 100, 15, nil, true)

function OnCreateObj(obj)
	if obj~=nil then
		if (GetDistance(myHero, obj)) < 100 then
			if string.find(obj.charName,"FountainHeal") then
				timer=os.clock()
				bluePill = obj
			end
		end
	end
end

function SetVariables()
	Qrange = 800
	Wrange = 900
	Qdelay = 5
	Qspeed = 0
	Wdelay = 1.5
	Wspeed = 14 
	
	target = GetWeakEnemy('MAGIC',800)
	targetW = GetWeakEnemy('MAGIC',900)
	
	if target==nil then
		for i,v in pairs(CounterQ) do CounterQ[i] = nil end
	end
	
	if myHero.SpellLevelR == 3 then
		Rrange = 750
	elseif myHero.SpellLevelR ~= 0 and myHero.SpellLevelR ~= 3 then 
		Rrange = 675
	elseif myHero.SpellLevelR == 0 then
		Rrange = 0
	end

	if myHero.SpellTimeQ>1.0 and GetSpellLevel('Q')~=0 and myHero.mana>(30+(myHero.SpellLevelQ*10)) then
	QRDY = 1
	else QRDY = 0
	end
	if myHero.SpellTimeW>1.0 and GetSpellLevel('W')~=0 and myHero.mana>(50+(myHero.SpellLevelW*10)) then
	WRDY = 1
	else WRDY = 0
	end
	if myHero.SpellTimeE>1.0 and GetSpellLevel('E')~=0 and myHero.mana>50 then
	ERDY = 1
	else ERDY = 0
	end
	if myHero.SpellTimeR>1.0 and GetSpellLevel('R')~=0 and myHero.mana>100 then
	RRDY = 1
	else RRDY = 0
	end
end

function Harass()
	if not SyndraHotkeys.Stun and not SyndraHotkeys.Slow then
		if target~=nil then
			
			QX,QY,QZ = GetFireahead(target,Qdelay,Qspeed)
			
			if distXYZ(myHero.x,myHero.z,target.x,target.z)<Qrange and
				distXYZ(myHero.x,myHero.z,QX,QZ)<Qrange and
				distXYZ(target.x,target.z,QX,QZ)<((target.movespeed/1000)*(((Qdelay*100)+100)+(Qspeed*10))) then
				table.insert(CounterQ, target)
			end
			if distXYZ(myHero.x,myHero.z,target.x,target.z)>Qrange or
				distXYZ(myHero.x,myHero.z,QX,QZ)>Qrange or
				distXYZ(target.x,target.z,QX,QZ)>((target.movespeed/1000)*(((Qdelay*100)+100)+(Qspeed*10))) then
				for i,v in pairs(CounterQ) do CounterQ[i] = nil end
			end
			
			if QRDY==1 and distXYZ(myHero.x,myHero.z,target.x,target.z)<Qrange and distXYZ(myHero.x,myHero.z,QX,QZ)<Qrange and 
			distXYZ(target.x,target.z,QX,QZ)<((target.movespeed/1000)*(((Qdelay*100)+100)+(Qspeed*10))) and 
			#CounterQ~=0 and #CounterQ>count then
				CastSpellXYZ('Q',QX,QY,QZ)
			end
		end
	end
end

function Slow()
	if not SyndraHotkeys.Stun then
		if target~=nil then
			
			QX,QY,QZ = GetFireahead(target,Qdelay,Qspeed)
			
			if distXYZ(myHero.x,myHero.z,target.x,target.z)<Qrange and
				distXYZ(myHero.x,myHero.z,QX,QZ)<Qrange and
				distXYZ(target.x,target.z,QX,QZ)<((target.movespeed/1000)*(((Qdelay*100)+100)+(Qspeed*10))) then
				table.insert(CounterQ, target)
			end
			if distXYZ(myHero.x,myHero.z,target.x,target.z)>Qrange or
				distXYZ(myHero.x,myHero.z,QX,QZ)>Qrange or
				distXYZ(target.x,target.z,QX,QZ)>((target.movespeed/1000)*(((Qdelay*100)+100)+(Qspeed*10))) then
				for i,v in pairs(CounterQ) do CounterQ[i] = nil end
			end
			
			if QRDY==1 and distXYZ(myHero.x,myHero.z,target.x,target.z)<Qrange and distXYZ(myHero.x,myHero.z,QX,QZ)<Qrange and 
			distXYZ(target.x,target.z,QX,QZ)<((target.movespeed/1000)*(((Qdelay*100)+100)+(Qspeed*10))) and 
			#CounterQ~=0 and #CounterQ>count then
				CastSpellXYZ('Q',QX,QY,QZ)
			end
		end
		
		if targetW~=nil then
			
			WX,WY,WZ = GetFireahead(targetW,Wdelay,Wspeed)
			
			if WRDY==1 and distXYZ(myHero.x,myHero.z,targetW.x,targetW.z)<Wrange and distXYZ(myHero.x,myHero.z,WX,WZ)<Wrange and 
			distXYZ(targetW.x,targetW.z,WX,WZ)<((targetW.movespeed/1000)*(((Wdelay*100)+100)+(Wspeed*10))) then
				run_W_twice()
			end
		end
	end
end

function Wcast()
	CastSpellXYZ('W',WX,WY,WZ)
end

function delayed_Wcast()
	run_every(0.25,Wcast)
	if WRDY==0 then
		return true
	end
end

function run_W_twice()
	run_many_reset(2, delayed_Wcast)
end

function Stun()
	if not SyndraHotkeys.Slow then
		if target~=nil then
			QX,QY,QZ = GetFireahead(target,Qdelay,Qspeed)
			if distXYZ(myHero.x,myHero.z,target.x,target.z)<Qrange and
				distXYZ(myHero.x,myHero.z,QX,QZ)<Qrange and
				distXYZ(target.x,target.z,QX,QZ)<((target.movespeed/1000)*(((Qdelay*100)+100)+(Qspeed*10))) then
				table.insert(CounterQ, target)
			end
			if distXYZ(myHero.x,myHero.z,target.x,target.z)>Qrange or
				distXYZ(myHero.x,myHero.z,QX,QZ)>Qrange or
				distXYZ(target.x,target.z,QX,QZ)>((target.movespeed/1000)*(((Qdelay*100)+100)+(Qspeed*10))) then
				for i,v in pairs(CounterQ) do CounterQ[i] = nil end
			end
			
			if distXYZ(myHero.x,myHero.z,target.x,target.z)<Qrange and
				distXYZ(myHero.x,myHero.z,QX,QZ)<Qrange and distXYZ(target.x,target.z,QX,QZ)<((target.movespeed/1000)*(((Qdelay*100)+100)+(Qspeed*10))) and 
				#CounterQ~=0 and #CounterQ>count then
				if QRDY==1 and ERDY==1 then
					CastSpellXYZ('Q',QX,QY,QZ)
				end
				if Qcasted and (timer7~=0 and GetTickCount()-timer7<25) then
					CastSpellXYZ('E',QX,QY,QZ)
					Qcasted = false
					timer7 = 0
				end
				--[[
				elseif (SAX~=nil and SAZ~=nil and dist(target.x,target.z,SAX,SAZ)<100) then
					CastSpellXYZ('E',SAX,0,SAZ)
					Qcasted = false
					timer7 = 0
				elseif (SBX~=nil and SBZ~=nil and dist(target.x,target.z,SBX,SBZ)<100) then
					CastSpellXYZ('E',SBX,0,SBZ)
					Qcasted = false
					timer7 = 0
				elseif (SCX~=nil and SCZ~=nil and dist(target.x,target.z,SCX,SCZ)<100) then
					CastSpellXYZ('E',SCX,0,SCZ)
					Qcasted = false
					timer7 = 0
				elseif (SDX~=nil and SDZ~=nil and dist(target.x,target.z,SDX,SDZ)<100) then
					CastSpellXYZ('E',SDX,0,SDZ)
					Qcasted = false
					timer7 = 0
				elseif (SEX~=nil and SEZ~=nil and dist(target.x,target.z,SEX,SEZ)<100) then
					CastSpellXYZ('E',SEX,0,SEZ)
					Qcasted = false
					timer7 = 0
				elseif (SFX~=nil and SFZ~=nil and dist(target.x,target.z,SFX,SFZ)<100) then
					CastSpellXYZ('E',SfX,0,SfZ)
					Qcasted = false
					timer7 = 0
				end]]
			end
		end
	end
end

function SphereManager()
	if GetTickCount() - timer1 > 6300 then timer1 = 0 end
	if GetTickCount() - timer2 > 6300 then timer2 = 0 end
	if GetTickCount() - timer3 > 6300 then timer3 = 0 end
	if GetTickCount() - timer4 > 6300 then timer4 = 0 end
	if GetTickCount() - timer5 > 6300 then timer5 = 0 end
	if GetTickCount() - timer6 > 6300 then timer6 = 0 end
	if GetTickCount() - timer8 > 6000 then timer8 = 0 end
	
	if timer1 ~= 0 then SphereA = true
	elseif timer1 == 0 then
			SphereA = false
			SA = 0
			SAX = nil
			SAZ = nil
	end
	if timer2 ~= 0 then SphereB = true
	elseif timer2 == 0 then
			SphereB = false
			SB = 0
			SBX = nil
			SBZ = nil
	end
	if timer3 ~= 0 then
			SphereC = true
	elseif timer3 == 0 then
			SphereC = false
			SC = 0
			SCX = nil
			SCZ = nil
	end
   
	if timer4 ~= 0 then SphereD = true
	elseif timer4 == 0 then
			SphereA = false
			SD = 0
			SDX = nil
			SDZ = nil
	end
	if timer5 ~= 0 then SphereE = true
	elseif timer5 == 0 then
			SphereE = false
			SE = 0
			SEX = nil
			SEZ = nil
	end
	if timer6 ~= 0 then SphereF = true
	elseif timer6 == 0 then
			SphereF = false
			SF = 0
			SFX = nil
			SFZ = nil
	end
	if timer8 == 0 then
		LastQX = nil
		LastQZ = nil
	end
end

function OnProcessSpell(unit,spell)
	if unit ~= nil and spell ~= nil and unit.charName == myHero.charName then
		if #CounterQ>count and spell.name == 'SyndraQ' then
			LastQX = spell.endPos.x
			LastQZ = spell.endPos.z
			Qcasted = true
			timer7 = GetTickCount()
			timer8 = GetTickCount()
		end
		if spell.name == 'syndrawcast' then
			LastQX = spell.endPos.x
			LastQZ = spell.endPos.z
			timer8 = GetTickCount()
		end
		if SphereA == false then
			if spell.name == "SyndraQ" then
				timer1 = GetTickCount()
				SAX = spell.endPos.x
				SAZ = spell.endPos.z
			end
		elseif SphereB == false then
			if spell.name == "SyndraQ" then
				timer2 = GetTickCount()
				SBX = spell.endPos.x
				SBZ = spell.endPos.z
			end
		elseif SphereC == false then
			if spell.name == "SyndraQ" then
				timer3 = GetTickCount()
				SCX = spell.endPos.x
				SCZ = spell.endPos.z
			end
		elseif SphereD == false then
			if spell.name == "SyndraQ" then
				timer4 = GetTickCount()
				SDX = spell.endPos.x
				SDZ = spell.endPos.z
			end
		elseif SphereE == false then
			if spell.name == "SyndraQ" then
				timer5 = GetTickCount()
				SEX = spell.endPos.x
				SEZ = spell.endPos.z
			end
		elseif SphereF == false then
			if spell.name == "SyndraQ" then
				timer6 = GetTickCount()
				SFX = spell.endPos.x
				SFZ = spell.endPos.z
			end
		end
	end
	if unit ~= nil and GetDistance(myHero, unit) < 1000 then
		for i, Minion in pairs(Minions) do
			if Minion ~= nil then
				if MinionInfo[unit.charName] ~= nil then
					local m_aaDelay = MinionInfo[unit.charName].aaDelay
					local m_projSpeed = MinionInfo[unit.charName].projSpeed
					
					if spell.target == Minion then
						IncomingDamage[unit.name] = { Source = unit, Target = Minion, Damage = getDmg("AD", Minion, unit), Start = GetTickCount(), aaPos = { x = unit.x, z = unit.z }, aaDelay = m_aaDelay, projSpeed = m_projSpeed }
					end
				end
			end
		end
	end
	if unit.charName == myHero.charName then
		for i, aaSpellName in pairs(Syndra.aaSpellName) do
			if spell.name == aaSpellName then
				AnimationBeginTimer = os.clock()
				TimeToAA = os.clock() + (1 / myHero.attackspeed) - 0.35 * (1 / myHero.attackspeed)
			end
		end
	end
	local P1 = spell.startPos
	local P2 = spell.endPos
	local calc = (math.floor(math.sqrt((P2.x-unit.x)^2 + (P2.z-unit.z)^2)))
	if string.find(unit.name,"Minion_") == nil and string.find(unit.name,"Turret_") == nil then
		if (unit.team ~= myHero.team or (show_allies==1)) and string.find(spell.name,"Basic") == nil then
			for i=1, #skillshotArray, 1 do
				local maxdist
				local dodgeradius
				dodgeradius = skillshotArray[i].radius
				maxdist = skillshotArray[i].maxdistance
				if spell.name == skillshotArray[i].name then
					skillshotArray[i].shot = 1
					skillshotArray[i].lastshot = os.clock()
					if skillshotArray[i].type == 1 then
						skillshotArray[i].p1x = unit.x
						skillshotArray[i].p1y = unit.y
						skillshotArray[i].p1z = unit.z
						skillshotArray[i].p2x = unit.x + (maxdist)/calc*(P2.x-unit.x)
						skillshotArray[i].p2y = P2.y
						skillshotArray[i].p2z = unit.z + (maxdist)/calc*(P2.z-unit.z)
						dodgelinepass(unit, P2, dodgeradius, maxdist)
					elseif skillshotArray[i].type == 2 then
						skillshotArray[i].px = P2.x
						skillshotArray[i].py = P2.y
						skillshotArray[i].pz = P2.z
						dodgelinepoint(unit, P2, dodgeradius)
					elseif skillshotArray[i].type == 3 then
						skillshotArray[i].skillshotpoint = calculateLineaoe(unit, P2, maxdist)
						if skillshotArray[i].name ~= "SummonerClairvoyance" then
							dodgeaoe(unit, P2, dodgeradius)
						end
					elseif skillshotArray[i].type == 4 then
						skillshotArray[i].px = unit.x + (maxdist)/calc*(P2.x-unit.x)
						skillshotArray[i].py = P2.y
						skillshotArray[i].pz = unit.z + (maxdist)/calc*(P2.z-unit.z)
						dodgelinepass(unit, P2, dodgeradius, maxdist)
					elseif skillshotArray[i].type == 5 then
						skillshotArray[i].skillshotpoint = calculateLineaoe2(unit, P2, maxdist)
						dodgeaoe(unit, P2, dodgeradius)
					end
				end
			end
		end
	end
end

function OnDraw()
	if myHero.dead == 0 then
		if QRDY == 1 then
			CustomCircle(Qrange,2,2,myHero)
		else
			CustomCircle(Qrange,2,3,myHero)
		end
		if target ~=nil then
			QX,QY,QZ = GetFireahead(target,Qdelay,Qspeed)
			if QRDY==1 and distXYZ(myHero.x,myHero.z,target.x,target.z)<Qrange and 
			distXYZ(myHero.x,myHero.z,QX,QZ)<Qrange and 
			distXYZ(target.x,target.z,QX,QZ)<((target.movespeed/1000)*(((Qdelay*100)+100)+(Qspeed*10))) then
				CustomCircleXYZ(75,10,5,QX,QY,QZ)
			end
		end
		if targetW ~=nil then
			if not SyndraHotkeys.Stun then
				WX,WY,WZ = GetFireahead(targetW,Wdelay,Wspeed)
				if WRDY==1 and distXYZ(myHero.x,myHero.z,targetW.x,targetW.z)<Wrange and distXYZ(myHero.x,myHero.z,WX,WZ)<Wrange and
				 distXYZ(targetW.x,targetW.z,WX,WZ)<((targetW.movespeed/1000)*(((Wdelay*100)+100)+(Wspeed*10))) then
					CustomCircleXYZ(75,10,1,WX,WY,WZ)
				end
			end
		end
		if #CounterQ>0 then
			DrawTextObject('Q: '..#CounterQ,myHero,0xFFFFFFFF)
		else
			DrawTextObject('0',myHero,0xFFFFFFFF)
		end
	end
	if SyndraConf.RoamHelper_ONOFF then
		for i, Enemy in pairs(Enemies) do
			if Enemy ~= nil then
				Hero = Enemy.Unit
			
				local PositionX = (13.3/16) * GetScreenX()
			
				local QDMG = getDmg('Q', Hero, myHero)+(getDmg('Q',Hero,myHero)*(HavocDamage + ExecutionerDamage))
				local WDMG = getDmg('W', Hero, myHero)+(getDmg('W',Hero,myHero)*(HavocDamage + ExecutionerDamage))
				local EDMG = getDmg('E', Hero, myHero)+(getDmg('E',Hero,myHero)*(HavocDamage + ExecutionerDamage))
				local RDMG = getDmg('R', Hero, myHero)+(getDmg('R',Hero,myHero)*(HavocDamage + ExecutionerDamage))
				local Current_Burst
				local Damage
				if myHero.selflevel >= 6 and myHero.SpellTimeR > 1.0 then
					Current_Burst = Round(QDMG + WDMG + EDMG * 3 + RDMG, 0) --Show damage of QWEEER combo if Ult is available
				else
					Current_Burst = Round(QDMG + WDMG + EDMG * 3, 0) --Show damage of QWEEE combo if Ult is not available
				end
				if myHero.SummonerD == 'SummonerDot' and myHero.SpellTimeD > 1.0 or myHero.SummonerF == 'SummonerDot' and myHero.SpellTimeF > 1.0 then
					Current_Burst = Current_Burst + ((myHero.selflevel*20)+50) --If Ignite detected and is not on cooldown add ignite damage to combo damage
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
--[[
Q
W
QW
QE
R
QR
QWR
QRE
QWRE
TQ
TW
TQE
TR
TQR
TQWR
TQRE
TQWRE	

function Killsteal()
	if SAX~=nil then SA = 1
	elseif SAX==nil then SA = 0 end
	if SBX~=nil then SB = 1
	elseif SBX==nil then SB = 0 end
	if SCX~=nil then SC = 1
	elseif SCX==nil then SC = 0 end
	if SDX~=nil then SD = 1
	elseif SDX==nil then SD = 0 end
	if SEX~=nil then SE = 1
	elseif SEX==nil then SE = 0 end
	if SFX~=nil then SF = 1
	elseif SFX==nil then SF = 0 end
	counter = SA+SB+SC+SD+SE+SF+3
	
	if 

	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0 and enemy.dead == 0) then
]]

function Killsteal()
	if SAX~=nil then SA = 1
	elseif SAX==nil then SA = 0 end
	if SBX~=nil then SB = 1
	elseif SBX==nil then SB = 0 end
	if SCX~=nil then SC = 1
	elseif SCX==nil then SC = 0 end
	if SDX~=nil then SD = 1
	elseif SDX==nil then SD = 0 end
	if SEX~=nil then SE = 1
	elseif SEX==nil then SE = 0 end
	if SFX~=nil then SF = 1
	elseif SFX==nil then SF = 0 end
	counter = SA+SB+SC+SD+SE+SF+3

	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0 and enemy.dead == 0) then

			local xQ = getDmg("Q",enemy,myHero)
			local xR = ((getDmg("R",enemy,myHero))*counter)
			local xQR = ((getDmg("R",enemy,myHero))*counter+1)+(xQ*QRDY)
			local Qdam = xQ*QRDY
			local Wdam = getDmg("W",enemy,myHero)*WRDY
			local Edam = getDmg("E",enemy,myHero)*ERDY
			local Rdam = xR*RRDY
			local QRdam = (RRDY*(getDmg("R",enemy,myHero))*counter+1)+(xQ*QRDY)
			
			local Fx,Fy,Fz = GetFireahead(enemy,5,0)
				
			if enemy.health < Qdam then
				SpellPred(Q,QRDY,myHero,enemy,800,5,0,0)
			elseif enemy.health<Rdam then
				SpellTarget(R,RRDY,myHero,enemy,Rrange)
			elseif enemy.health<QRdam and enemy.health>Qdam+Wdam+Edam and GetDistance(myHero,enemy) < Rrange and distXYZ(myHero.x,myHero.z,Fy,Fz)<800 then
				SpellPred(Q,QRDY,myHero,enemy,800,5,0,0)
				SpellTarget(R,RRDY,myHero,enemy,Rrange)
			end
				
			if enemy.health < Qdam then DrawTextObject("Qdam", enemy, 0xFF00EE00)
			elseif enemy.health < Rdam then DrawTextObject("Rdam", enemy, 0xFF00EE00)
			elseif enemy.health < QRdam then DrawTextObject("QRdzam", enemy, 0xFF00EE00)
			end
		end
	end
end

----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------

function SpellTarget(spell,cd,a,b,range)
	if (cd == 1 or cd) and a ~= nil and b ~= nil and GetDistance(a,b) < range then
		CastSpellTarget(spell,b)
	end
end

function SpellXYZ(spell,cd,a,b,range,x,z)
	local y = 0
	if (cd == 1 or cd) and a ~= nil and b ~= nil and x ~= nil and z ~= nil and GetDistance(a,b) < range then
		CastSpellXYZ(spell,x,y,z)
	end
end

function SpellPred(spell,cd,a,b,range,delay,speed,block)
	if (cd == 1 or cd) and a ~= nil and b ~= nil and delay ~= nil and speed ~= nil and GetDistance(a,b) < range then
		if block == 1 then
			if CreepBlock(GetFireahead(b,delay,speed)) == 0 then
				CastSpellXYZ(spell,GetFireahead(b,delay,speed))
			end
		else CastSpellXYZ(spell,GetFireahead(b,delay,speed))
		end
	end
end
	
function distXYZ(a1,a2,b1,b2)
	if b1 == nil or b2 == nil then
		b1 = myHero.x
		b2 = myHero.z
	end
	if a2 ~= nil and b2 ~= nil and a1~=nil and b1~=nil then
		a = (b1-a1)
		b = (b2-a2)
		if a~=nil and b~=nil then
			a2=a*a
			b2=b*b
			if a2~=nil and b2~=nil then
				return math.sqrt(a2+b2)
			else
				return 99999
			end
		else
			return 99999
		end
	end
end

function CustomCircleXYZ(radius,thickness,color,x,y,z)
        local count = math.floor(thickness/2)
        repeat
            DrawCircle(x,y,z,radius+count,color)
            count = count-2
        until count == (math.floor(thickness/2)-(math.floor(thickness/2)*2))-2
    if x ~= "" and y ~= "" and z~= "" then
        local count = math.floor(thickness/2)
        repeat
            DrawCircle(x,y,z,radius+count,color)
            count = count-2
        until count == (math.floor(thickness/2)-(math.floor(thickness/2)*2))-2
    end
end

function run_every(interval, fn, ...)
    return internal_run({fn=fn, interval=interval}, ...)
end

function run_many_reset(count, fn, ...)
    return internal_run({fn=fn, count=count, reset=true}, ...)
end

function internal_run(t, ...)    
	local fn = t.fn
	local key = t.key or fn
	local now = os.clock()
	local data = Registry[key]
	if data == nil or t.reset then
		local args = {}
		local n = select('#', ...)
		local v
		for i=1,n do
			v = select(i, ...)
			table.insert(args, v)
		end       
		data = {count=0, last=0, complete=false, t=t, args=args}
		Registry[key] = data
	end
	local countCheck = (t.count==nil or data.count < t.count)
	local startCheck = (data.t.start==nil or now >= data.t.start)
	local intervalCheck = (t.interval==nil or now-data.last >= t.interval)
	if not data.complete and countCheck and startCheck and intervalCheck then                
		if t.count ~= nil then
			data.count = data.count + 1
		end
		data.last = now        
		if t._while==nil and t._until==nil then
			return fn(...)
		else
			local signal = t._until ~= nil
			local checker = t._while or t._until
			local result
			if fn == checker then            
				result = fn(...)
				if result == signal then
					data.complete = true
				end
				return result
			else
				result = checker(...)
				if result == signal then
					data.complete = true
				else
					return fn(...)
				end
			end            
		end
	end    
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

local metakey = SKeys.Control
local attempts = 0
local lastAttempt = 0

function Level_Spell(letter)  
     if letter == Q then send.key_press(0x69)
     elseif letter == W then send.key_press(0x6a)
     elseif letter == E then send.key_press(0x6b)
     elseif letter == R then send.key_press(0x6c) end
end

function Autolevel()
	local spellLevelSum = GetSpellLevel(Q) + GetSpellLevel(W) + GetSpellLevel(E) + GetSpellLevel(R)
	if attempts <= 10 or (attempts > 10 and GetTickCount() > lastAttempt+1500) then
		if spellLevelSum < myHero.selflevel then
			if lastSpellLevelSum ~= spellLevelSum then attempts = 0 end
			letter = skillingOrder[myHero.name][spellLevelSum+1]
			Level_Spell(letter, spellLevelSum)
			attempts = attempts+1
			lastAttempt = GetTickCount()
			lastSpellLevelSum = spellLevelSum
		else
			attempts = 0
		end
	end
	send.tick()
end

local cc = 0
local colorcyan = 0x0000FFFF
local coloryellow = 0xFFFFFF00
local colorgreen = 0xFF00FF00
local skillshotcharexist = false

function Skillshots()
	cc=cc+1
	if (cc==30) then
		LoadTable()
	end
	for i=1, #skillshotArray, 1 do
		if skillshotArray[i].shot == 1 then
			local radius = skillshotArray[i].radius
			local color = skillshotArray[i].color
			if skillshotArray[i].isline == false then
				for number, point in pairs(skillshotArray[i].skillshotpoint) do
					DrawCircle(point.x, point.y, point.z, radius, color)
				end
			else
				startVector = Vector(skillshotArray[i].p1x,skillshotArray[i].p1y,skillshotArray[i].p1z)
				endVector = Vector(skillshotArray[i].p2x,skillshotArray[i].p2y,skillshotArray[i].p2z)
				directionVector = (endVector-startVector):normalized()
				local angle=0
				if (math.abs(directionVector.x)<.00001) then
					if directionVector.z > 0 then angle=90
					elseif directionVector.z < 0 then angle=270
					else angle=0
					end
				else
					local theta = math.deg(math.atan(directionVector.z / directionVector.x))
					if directionVector.x < 0 then theta = theta + 180 end
						if theta < 0 then theta = theta + 360 end
							angle=theta
						end
							angle=((90-angle)*2*math.pi)/360
							DrawLine(startVector.x, startVector.y, startVector.z, GetDistance(startVector, endVector)+170, 1,angle,radius)
					end
				end
			end
	for i=1, #skillshotArray, 1 do
		if os.clock() > (skillshotArray[i].lastshot + skillshotArray[i].time) then
		skillshotArray[i].shot = 0
		end
	end
end

function dodgeaoe(pos1, pos2, radius)
	local calc = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
	local dodgex
	local dodgez
	dodgex = pos2.x + ((radius+50)/calc)*(myHero.x-pos2.x)
	dodgez = pos2.z + ((radius+50)/calc)*(myHero.z-pos2.z)
	if SyndraConf.dodgeskillshots and calc < radius then
		 MoveToXYZ(dodgex,0,dodgez)
	end
end

function dodgelinepoint(pos1, pos2, radius)
	local calc1 = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
	local calc2 = (math.floor(math.sqrt((pos1.x-myHero.x)^2 + (pos1.z-myHero.z)^2)))
	local calc4 = (math.floor(math.sqrt((pos1.x-pos2.x)^2 + (pos1.z-pos2.z)^2)))
	local calc3
	local perpendicular
	local k
	local x4
	local z4
	local dodgex
	local dodgez
	perpendicular = (math.floor((math.abs((pos2.x-pos1.x)*(pos1.z-myHero.z)-(pos1.x-myHero.x)*(pos2.z-pos1.z)))/(math.sqrt((pos2.x-pos1.x)^2 + (pos2.z-pos1.z)^2))))
	k = ((pos2.z-pos1.z)*(myHero.x-pos1.x) - (pos2.x-pos1.x)*(myHero.z-pos1.z)) / ((pos2.z-pos1.z)^2 + (pos2.x-pos1.x)^2)
	x4 = myHero.x - k * (pos2.z-pos1.z)
	z4 = myHero.z + k * (pos2.x-pos1.x)
	calc3 = (math.floor(math.sqrt((x4-myHero.x)^2 + (z4-myHero.z)^2)))
	dodgex = x4 + ((radius+75)/calc3)*(myHero.x-x4)
	dodgez = z4 + ((radius+75)/calc3)*(myHero.z-z4)
	if perpendicular < radius and calc1 < calc4 and calc2 < calc4  and GetCursorX() > xa and GetCursorX() < xb and GetCursorY() > ya and GetCursorY() < yb then
		if SyndraConf.dodgeskillshots and SyndraHotkeys.Slow == false and SyndraHotkeys.Stun == false and SyndraHotkeys.Harass == false then send.block_input(true,750) end
        MoveToXYZ(dodgex,0,dodgez)
	end
end

function dodgelinepass(pos1, pos2, radius, maxDist)
	local pm2x = pos1.x + (maxDist)/(math.floor(math.sqrt((pos1.x-pos2.x)^2 + (pos1.z-pos2.z)^2)))*(pos2.x-pos1.x)
	local pm2z = pos1.z + (maxDist)/(math.floor(math.sqrt((pos1.x-pos2.x)^2 + (pos1.z-pos2.z)^2)))*(pos2.z-pos1.z)
	local calc1 = (math.floor(math.sqrt((pm2x-myHero.x)^2 + (pm2z-myHero.z)^2)))
	local calc2 = (math.floor(math.sqrt((pos1.x-myHero.x)^2 + (pos1.z-myHero.z)^2)))
	local calc3
	local calc4 = (math.floor(math.sqrt((pos1.x-pm2x)^2 + (pos1.z-pm2z)^2)))
	local perpendicular
	local k
	local x4
	local z4
	local dodgex
	local dodgez
	perpendicular = (math.floor((math.abs((pm2x-pos1.x)*(pos1.z-myHero.z)-(pos1.x-myHero.x)*(pm2z-pos1.z)))/(math.sqrt((pm2x-pos1.x)^2 + (pm2z-pos1.z)^2))))
	k = ((pm2z-pos1.z)*(myHero.x-pos1.x) - (pm2x-pos1.x)*(myHero.z-pos1.z)) / ((pm2z-pos1.z)^2 + (pm2x-pos1.x)^2)
	x4 = myHero.x - k * (pm2z-pos1.z)
	z4 = myHero.z + k * (pm2x-pos1.x)
	calc3 = (math.floor(math.sqrt((x4-myHero.x)^2 + (z4-myHero.z)^2)))
	dodgex = x4 + ((radius+75)/calc3)*(myHero.x-x4)
	dodgez = z4 + ((radius+75)/calc3)*(myHero.z-z4)
	if perpendicular < radius and calc1 < calc4 and calc2 < calc4  and GetCursorX() > xa and GetCursorX() < xb and GetCursorY() > ya and GetCursorY() < yb then
		if SyndraConf.dodgeskillshots and SyndraHotkeys.Slow == false and SyndraHotkeys.Stun == false and SyndraHotkeys.Harass == false then send.block_input(true,750) end
        MoveToXYZ(dodgex,0,dodgez)
	end
end

function calculateLinepass(pos1, pos2, spacing, maxDist)
	local calc = (math.floor(math.sqrt((pos2.x-pos1.x)^2 + (pos2.z-pos1.z)^2)))
	local line = {}
	local point1 = {}
	point1.x = pos1.x
	point1.y = pos1.y
	point1.z = pos1.z
	local point2 = {}
	point1.x = pos1.x + (maxDist)/calc*(pos2.x-pos1.x)
	point1.y = pos2.y
	point1.z = pos1.z + (maxDist)/calc*(pos2.z-pos1.z)
	table.insert(line, point2)
	table.insert(line, point1)
	return line
end

function calculateLineaoe(pos1, pos2, maxDist)
	local line = {}
	local point = {}
	point.x = pos2.x
	point.y = pos2.y
	point.z = pos2.z
	table.insert(line, point)
	return line
end

function calculateLineaoe2(pos1, pos2, maxDist)
	local calc = (math.floor(math.sqrt((pos2.x-pos1.x)^2 + (pos2.z-pos1.z)^2)))
	local line = {}
	local point = {}
		if calc < maxDist then
		point.x = pos2.x
		point.y = pos2.y
		point.z = pos2.z
		table.insert(line, point)
	else
		point.x = pos1.x + maxDist/calc*(pos2.x-pos1.x)
		point.z = pos1.z + maxDist/calc*(pos2.z-pos1.z)
		point.y = pos2.y
		table.insert(line, point)
	end
	return line
end

function calculateLinepoint(pos1, pos2, spacing, maxDist)
	local line = {}
	local point1 = {}
	point1.x = pos1.x
	point1.y = pos1.y
	point1.z = pos1.z
	local point2 = {}
	point1.x = pos2.x
	point1.y = pos2.y
	point1.z = pos2.z
	table.insert(line, point2)
	table.insert(line, point1)
	return line
end

function table_print (tt, indent, done)
	done = done or {}
	indent = indent or 0
	if type(tt) == "table" then
		local sb = {}
		for key, value in pairs (tt) do
			table.insert(sb, string.rep (" ", indent)) -- indent it
			if type (value) == "table" and not done [value] then
				done [value] = true
				table.insert(sb, "{\n");
				table.insert(sb, table_print (value, indent + 2, done))
				table.insert(sb, string.rep (" ", indent)) -- indent it
				table.insert(sb, "}\n");
			elseif "number" == type(key) then
				table.insert(sb, string.format("\"%s\"\n", tostring(value)))
			else
				table.insert(sb, string.format(
				"%s = \"%s\"\n", tostring (key), tostring(value)))
			end
		end
		return table.concat(sb)
	else
	return tt .. "\n"
	end
end

function LoadTable()
	print("table loaded::")
	local iCount=objManager:GetMaxHeroes()
	print(" heros:" .. tostring(iCount))
	iCount=1;
	for i=0, iCount, 1 do
		local skillshotplayerObj = GetSelf();
		print(" name:" .. skillshotplayerObj.name);
		if 1==1 or skillshotplayerObj.name == "Ahri" then
			table.insert(skillshotArray,{name= "AhriOrbofDeception", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 880, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			table.insert(skillshotArray,{name= "AhriSeduce", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Amumu" then
			table.insert(skillshotArray,{name= "BandageToss", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Anivia" then
			table.insert(skillshotArray,{name= "FlashFrostSpell", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 90, color= colorcyan, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Ashe" then
			table.insert(skillshotArray,{name= "EnchantedCrystalArrow", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 50000, type = 4, radius = 120, color= colorcyan, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Blitzcrank" then
			table.insert(skillshotArray,{name= "RocketGrabMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 200, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Brand" then
			table.insert(skillshotArray,{name= "BrandBlazeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 50, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
			table.insert(skillshotArray,{name= "BrandFissure", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Cassiopeia" then
			table.insert(skillshotArray,{name= "CassiopeiaMiasma", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 175, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "CassiopeiaNoxiousBlast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 75, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Caitlyn" then
			table.insert(skillshotArray,{name= "CaitlynEntrapmentMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 50, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "CaitlynPiltoverPeacemaker", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Corki" then
			table.insert(skillshotArray,{name= "MissileBarrageMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1225, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "MissileBarrageMissile2", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1225, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "CarpetBomb", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 2, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Chogath" then
			table.insert(skillshotArray,{name= "Rupture", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 275, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Diana" then
			table.insert(skillshotArray,{name= "DianaArc", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 205, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Draven" then
			table.insert(skillshotArray,{name= "DravenDoubleShot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 125, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "DravenRCast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 1, radius = 100, color= colorcyan, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "DrMundo" then
			table.insert(skillshotArray,{name= "InfectedCleaverMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Elise" then
			table.insert(skillshotArray,{name= "EliseHumanE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Ezreal" then
			table.insert(skillshotArray,{name= "EzrealEssenceFluxMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "EzrealMysticShotMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "EzrealTrueshotBarrage", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 4, radius = 150, color= colorcyan, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "EzrealArcaneShift", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 475, type = 5, radius = 100, color= colorgreen, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "FiddleSticks" then
			table.insert(skillshotArray,{name= "Crowstorm", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 600, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Fizz" then
			table.insert(skillshotArray,{name= "FizzMarinerDoom", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1275, type = 2, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Galio" then
			table.insert(skillshotArray,{name= "GalioResoluteSmite", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 905, type = 3, radius = 200, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "GalioRighteousGust", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 120, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Gragas" then
			table.insert(skillshotArray,{name= "GragasBarrelRoll", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 320, color= coloryellow, time = 2.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "GragasBodySlam", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 2, radius = 60, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "GragasExplosiveCask", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 3, radius = 400, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Graves" then
			table.insert(skillshotArray,{name= "GravesChargeShot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 110, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "GravesClusterShot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 750, type = 1, radius = 50, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "GravesSmokeGrenade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 3, radius = 275, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Heimerdinger" then
			table.insert(skillshotArray,{name= "CH1ConcussionGrenade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 225, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Irelia" then
			table.insert(skillshotArray,{name= "IreliaTranscendentBlades", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 80, color= colorcyan, time = 0.8, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Janna" then
			table.insert(skillshotArray,{name= "HowlingGale", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1700, type = 1, radius = 100, color= colorcyan, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "JarvanIV" then
			table.insert(skillshotArray,{name= "JarvanIVDemacianStandard", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 830, type = 3, radius = 150, color= coloryellow, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "JarvanIVDragonStrike", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 770, type = 1, radius = 70, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "JarvanIVCataclysm", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 3, radius = 300, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Jayce" then
			table.insert(skillshotArray,{name= "jayceshockblast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		
		if 1==1 or skillshotplayerObj.name == "Jinx" then
			table.insert(skillshotArray,{name= "JinxQCrit ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 100, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "JinxWMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1500, type = 1.5, radius = 100, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "JinxRWrapper", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 3, radius = 225, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Karma" then
			--table.insert(skillshotArray,{name= "KarmaQ ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 1, radius = 100, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "KarmaQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 350, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Karthus" then
			table.insert(skillshotArray,{name= "LayWaste", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 875, type = 3, radius = 150, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Kassadin" then
			table.insert(skillshotArray,{name= "RiftWalk", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 5, radius = 150, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Katarina" then
			table.insert(skillshotArray,{name= "ShadowStep", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 3, radius = 75, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Kennen" then
			table.insert(skillshotArray,{name= "KennenShurikenHurlMissile1", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 75, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Khazix" then
			table.insert(skillshotArray,{name= "KhazixE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 5, radius = 310, color= coloryello, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "KhazixW", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 70, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "khazixwlong", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 400, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "khazixelong", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 310, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "KogMaw" then
			table.insert(skillshotArray,{name= "KogMawVoidOozeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1115, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "KogMawLivingArtillery", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2200, type = 3, radius = 200, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Leblanc" then
			table.insert(skillshotArray,{name= "LeblancSoulShackle", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "LeblancSoulShackleM", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "LeblancSlide", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "LeblancSlideM", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "leblancslidereturn", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 50, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "leblancslidereturnm", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 50, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "LeeSin" then
			table.insert(skillshotArray,{name= "BlindMonkQOne", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "BlindMonkRKick", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Leona" then
			table.insert(skillshotArray,{name= "LeonaZenithBladeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 160, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Lissandra" then
			table.insert(skillshotArray,{name= "LissandraQMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 725, type = 1, radius = 100, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "LissandraEMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 120, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Lucian" then
			table.insert(skillshotArray,{name= "LucianQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= colorcyan, time = 0.75, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "LucianW", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "LucianR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1400, type = 1, radius = 250, color= colorcyan, time = 3, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Lulu" then
			table.insert(skillshotArray,{name= "LuluQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 50, color= colorcyan, time = 1, isline = true, px =0, py =0 , pz =0, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Lux" then
			table.insert(skillshotArray,{name= "LuxLightBinding", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1175, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "LuxLightStrikeKugel", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 300, color= coloryellow, time = 2.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "LuxMaliceCannon", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 3000, type = 1, radius = 80, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Malphite" then
			table.insert(skillshotArray,{name= "UFSlash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 325, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Malzahar" then
			table.insert(skillshotArray,{name= "AlZaharCalloftheVoid", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 100 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "AlZaharNullZone", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 250 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Maokai" then
			table.insert(skillshotArray,{name= "MaokaiTrunkLineMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "MaokaiSapling2", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 350 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "MissFortune" then
			table.insert(skillshotArray,{name= "MissFortuneScattershot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 400, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Morgana" then
			table.insert(skillshotArray,{name= "DarkBindingMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "TormentedSoil", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 350, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Nami" then
			table.insert(skillshotArray,{name= "NamiQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 875, type = 3, radius = 210, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "NamiR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2750, type = 1, radius = 335, color= coloryellow, time = 3, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Nautilus" then
			table.insert(skillshotArray,{name= "NautilusAnchorDrag", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 1, radius = 80, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Nidalee" then
			table.insert(skillshotArray,{name= "JavelinToss", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1500, type = 1, radius = 80, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Nocturne" then
			table.insert(skillshotArray,{name= "NocturneDuskbringer", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 80, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Olaf" then
			table.insert(skillshotArray,{name= "OlafAxeThrow", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 2, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Orianna" then
			table.insert(skillshotArray,{name= "OrianaIzunaCommand", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 825, type = 3, radius = 150, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Quinn" then
			table.insert(skillshotArray,{name= "QuinnQMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1025, type = 1, radius = 150, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Renekton" then
			table.insert(skillshotArray,{name= "RenektonSliceAndDice", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 450, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "renektondice", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 450, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Rumble" then
			table.insert(skillshotArray,{name= "RumbleGrenadeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "RumbleCarpetBomb", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1700, type = 1, radius = 100, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Sejuani" then
			table.insert(skillshotArray,{name= "SejuaniGlacialPrison", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1150, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Shaco" then
			table.insert(skillshotArray,{name= "Deceive", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 500, type = 5, radius = 100, color= colorgreen, time = 3.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Shen" then
			table.insert(skillshotArray,{name= "ShenShadowDash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 2, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Shyvana" then
			table.insert(skillshotArray,{name= "ShyvanaTransformLeap", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 80, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "ShyvanaFireballMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Singed" then
			table.insert(skillshotArray,{name= "MegaAdhesive", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 350, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Sivir" then
			table.insert(skillshotArray,{name= "SivirQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Skarner" then
			table.insert(skillshotArray,{name= "SkarnerFracture", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Sona" then
			table.insert(skillshotArray,{name= "SonaCrescendo", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Swain" then
			table.insert(skillshotArray,{name= "SwainShadowGrasp", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 265 , color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Syndra" then
			table.insert(skillshotArray,{name= "SyndraQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 190, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "syndrae5", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 1, radius = 100, color= coloryellow, time = 0.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "SyndraW", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 210, color= colorcyan, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Thresh" then
			table.insert(skillshotArray,{name= "ThreshQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 160, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Tristana" then
			table.insert(skillshotArray,{name= "RocketJump", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 200, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Tryndamere" then
			table.insert(skillshotArray,{name= "Slash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 2, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "TwistedFate" then
			table.insert(skillshotArray,{name= "WildCards", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1450, type = 1, radius = 80, color= colorcyan, time = 5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Urgot" then
			table.insert(skillshotArray,{name= "UrgotHeatseekingLineMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= colorcyan, time = 0.8, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "UrgotPlasmaGrenade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 300, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Varus" then
			table.insert(skillshotArray,{name= "VarusQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1475, type = 1, radius = 50, color= coloryellow, time = 1})
			table.insert(skillshotArray,{name= "VarusR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 80, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Vayne" then
			table.insert(skillshotArray,{name= "VayneTumble", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 250, type = 3, radius = 100, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Veigar" then
			table.insert(skillshotArray,{name= "VeigarDarkMatter", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 225, color= coloryellow, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Vi" then
			table.insert(skillshotArray,{name= "ViQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 725, type = 1, radius = 65, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Viktor" then
			table.insert(skillshotArray,{name= "ViktorDeathRay", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 80, color= coloryellow, time = 2})
		end
		if 1==1 or skillshotplayerObj.name == "Xerath" then
			table.insert(skillshotArray,{name= "xeratharcanopulsedamage", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "xeratharcanopulsedamageextended", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "xeratharcanebarragewrapper", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "xeratharcanebarragewrapperext", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Zac" then
			table.insert(skillshotArray,{name= "ZacQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 550, type = 1, radius = 100, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "ZacE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1550, type = 5, radius = 200, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Zed" then
			table.insert(skillshotArray,{name= "ZedShuriken", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 55, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "ZedShadowDash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 550, type = 3, radius = 150, color= colorcyan, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "zedw2", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 550, type = 3, radius = 150, color= colorcyan, time = 0.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Ziggs" then
			table.insert(skillshotArray,{name= "ZiggsQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 160, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "ZiggsW", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 225 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
			table.insert(skillshotArray,{name= "ZiggsE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "ZiggsR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5300, type = 3, radius = 550, color= coloryellow, time = 3, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
		if 1==1 or skillshotplayerObj.name == "Zyra" then
			table.insert(skillshotArray,{name= "ZyraQFissure", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 825, type = 3, radius = 275, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "ZyraGraspingRoots", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 90, color= colorcyan, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		skillshotcharexist = true
		end
    end
end

----------[[Utility Functions]]
for i = 1, objManager:GetMaxHeroes(), 1 do
	Hero = objManager:GetHero(i)
	if Hero ~= nil and Hero.team ~= myHero.team then
		if Enemies[Hero.name] == nil then
			Enemies[Hero.name] = { Unit = Hero, Number = EnemyIndex }
			EnemyIndex = EnemyIndex + 1
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

function Syndra_Items()
	if CfgItems.Zhonyas_Hourglass_ONOFF then
		if myHero.health < myHero.maxHealth*(CfgItems.Zhonyas_Hourglass_Value / 100) then
			useZhonyas()
		end
	end
	if CfgItems.Wooglets_Witchcap_ONOFF then
		if myHero.health < myHero.maxHealth*(CfgItems.Wooglets_Witchcap_Value / 100) then
			useWoogletsWitchcap()
		end
	end
	if CfgItems.Seraphs_Embrace_ONOFF then
		if myHero.health <= (CfgItems.Seraphs_Embrace_Value / 100) then
			useSeraphsEmbrace()
		end
	end
end
function useZhonyas()
	GetInventorySlot(3157)
	UseItemOnTarget(3157,myHero)
end
function useWoogletsWitchcap()
	GetInventorySlot(3090)
	UseItemOnTarget(3090,myHero)
end
function useSeraphsEmbrace()
	GetInventorySlot(3040)
	UseItemOnTarget(3040,myHero)
end

function Mastery_Damage()
	local Mast_ButcherDMG = 0
	local Mast_BruteForceDMG = 0
	local Mast_SpellswordDMG = 0
	if CfgMasteries.Butcher_Mastery > 0 then
		Mast_ButcherDMG = CfgMasteries.Butcher_Mastery
	end
	if CfgMasteries.Brute_Force_Mastery then
		if CfgMasteries.Brute_Force_Mastery == 1 then
			Mast_BruteForceDMG = 1.5
		end
		if CfgMasteries.Brute_Force_Mastery == 2 then
			Mast_BruteForceDMG = 3
		end
	end
	if CfgMasteries.Spellsword_Mastery then
		Mast_SpellswordDMG = myHero.ap * .05
	end
	if CfgMasteries.Havoc_Mastery then
		if CfgMasteries.Havoc_Mastery == 1 then
			HavocDamage = 0.0067
		end
		if CfgMasteries.Havoc_Mastery == 2 then
			HavocDamage = 0.0133
		end
		if CfgMasteries.Havoc_Mastery == 3 then
			HavocDamage = 0.02
		end
	end
	if CfgMasteries.Executioner_Mastery then
		ExecutionerDamage = .05
	end
	True_Attack_Damage_Against_Minions = (myHero.baseDamage + myHero.addDamage + Mast_BruteForceDMG + Mast_SpellswordDMG)+((myHero.baseDamage + myHero.addDamage + Mast_BruteForceDMG + Mast_SpellswordDMG)*(HavocDamage + ExecutionerDamage))
end
----------[[End of Utility Functions]]

----------[[Farming Functions]]
function Farm()
	CustomCircle(myHero.range+(GetDistance(GetMinBBox(myHero))),1,4,myHero)
	Minions = GetEnemyMinions(SORT_CUSTOM)
	AnimationSpeedTimer = 0.76 * (1 / myHero.attackspeed)
	
	for i, Minion in pairs(Minions) do
		if Minion ~= nil then
			local PredictedDamage = 0
			local aaTime = Ping + aaDelay + ( GetDistance(myHero, Minion) / Syndra.projSpeed )
			
			for k, DMG in pairs(IncomingDamage) do
				if DMG ~= nil then
					if (DMG.Source == nil or DMG.Source.dead or DMG.Target == nil or DMG.Target.dead) or (DMG.Source.x ~= DMG.aaPos.x or DMG.Source.z ~= DMG.aaPos.z) then
						IncomingDamage[k] = nil
					elseif Minion == DMG.Target then
						DMG.aaTime = (DMG.projSpeed == 0 and (DMG.aaDelay) or (DMG.aaDelay + GetDistance(DMG.Source, Minion) / DMG.projSpeed))
						if GetTickCount() >= (DMG.Start + DMG.aaTime) then
							IncomingDamage[k] = nil
						elseif GetTickCount() + aaTime > (DMG.Start + DMG.aaTime) then
							PredictedDamage = PredictedDamage + DMG.Damage
						end
					end
				end
			end
				
			if Minion.dead == 0 and Minion.health - PredictedDamage <= True_Attack_Damage_Against_Minions and Minion.health - PredictedDamage > 0 and GetDistance(Minion, myHero) < range then
				if os.clock() > TimeToAA then AttackTarget(Minion)
				CustomCircle(100, 1, 2, Minion)
				end
			end
		end
	end
	if os.clock() > (AnimationBeginTimer + AnimationSpeedTimer) then MoveToMouse() end
end

function Hybrid()		-----> Hybrid function changed to prioritze last hits over champions
    targetHero = GetWeakEnemy("MAGIC",800)
	tlow = GetLowestHealthEnemyMinion(range)
    
	if tlow ~= nil and tlow.health <= True_Attack_Damage_Against_Minions then
		target = tlow
	elseif targetHero ~= nil then
        target = targetHero
		Harass()
    else 
        target = GetLowestHealthEnemyMinion(range) 
    end
        
    if target ~= nil then
        if True_Attack_Damage_Against_Minions >= target.health then
            AttackTarget(target)
		end
	end
end
----------[[End of Farming Functions]]

----------[[Integrated RED ELIXIR]]
function RedElixir()
	if bluePill == nil then
		if myHero.health < myHero.maxHealth * (CfgPotions.Health_Potion_Value / 100) and GetClock() > wUsedAt + 15000 then
			usePotion()
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

function usePotion()
	GetInventorySlot(2003)
	UseItemOnTarget(2003,myHero)
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
----------[[End of Integrated Red Elixir]]

SetTimerCallback("Main")