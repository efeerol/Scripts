require 'Utils'
require 'spell_damage'
require 'spell_shot'
require 'winapi'
require 'SKeys'
local send = require 'SendInputScheduled'

local uiconfig = require 'uiconfig'
local target
local target2
local target3
local target4
local target5
local target6
local Q,W,E,R = 'Q','W','E','R'
local attacking = false
local t0_attacking = 0
local attackAnimationDuration = 250
local spellShot = {shot = false, radius = 0, time = 0, shotX = 0, shotZ = 0, shotY = 0, safeX = 0, safeY = 0, safeZ = 0, isline = false}
local startPos = {x=0, y=0, z=0}
local endPos = {x=0, y=0, z=0}
local shotMe = false
local Counter = {}
local minion
local targetIgnite
local timer = os.time()

local Summoners =
                {
                    Ignite = {Key = nil, Name = 'SummonerDot'},
                    Exhaust = {Key = nil, Name = 'SummonerExhaust'},
                    Heal = {Key = nil, Name = 'SummonerHeal'},
                    Clarity = {Key = nil, Name = 'SummonerMana'},
                    Barrier = {Key = nil, Name = 'SummonerBarrier'},
                    Clairvoyance = {Key = nil, Name = 'SummonerClairvoyance'},
					Cleanse = {Key = nil, Name = 'SummonerBoost'}
                }
	

local QSS = {"Stun_glb", "AlZaharNetherGrasp_tar", "InfiniteDuress_tar", "skarner_ult_tail_tip", "SwapArrow_red", "summoner_banish", "Global_Taunt", "mordekaiser_cotg_tar", "Global_Fear", "Ahri_Charm_buf", "leBlanc_shackle_tar", "LuxLightBinding_tar", "Fizz_UltimateMissle_Orbit", "Fizz_UltimateMissle_Orbit_Lobster", "RunePrison_tar", "DarkBinding_tar", "nassus_wither_tar", "Amumu_SadRobot_Ultwrap", "Amumu_Ultwrap", "maokai_elementalAdvance_root_01", "RengarEMax_tar", "VarusRHitFlash"}
local Cleanselist = {"Stun_glb", "summoner_banish", "Global_Taunt", "Global_Fear", "Ahri_Charm_buf", "leBlanc_shackle_tar", "LuxLightBinding_tar", "RunePrison_tar", "DarkBinding_tar", "nassus_wither_tar", "Amumu_SadRobot_Ultwrap", "Amumu_Ultwrap", "maokai_elementalAdvance_root_01", "RengarEMax_tar", "VarusRHitFlash"}

function MorganaRun()

	local maxHealth = 9999
	target = nil
	target3 = GetWeakEnemy('Phys',600)
  for i=1, objManager:GetMaxHeroes(), 1 do
		local object = objManager:GetHero(i)
		if object ~= nil and object.team == myHero.team and GetDistance(object) < 800 and object.charName ~= myHero.charName then
			if object.health < maxHealth then
				maxHealth = object.health
				target = object;
			end
		end
	end
	Util__OnTick()
	ResetTimer()
	
	if myHero.SpellTimeQ > 1.0 then
	QRDY = 1
	else QRDY = 0
	end
	if myHero.SpellTimeW > 1.0 then
	WRDY = 1
	else WRDY = 0
	end
	if myHero.SpellTimeE > 1.0 then
	ERDY = 1
	else ERDY = 0
	end
	if myHero.SpellTimeR > 1.0 then
	RRDY = 1
	else RRDY = 0
	end
	


	target4 = GetWeakEnemy('MAGIC',900)
	target5 = GetWeakEnemy('MAGIC',1150)
	minion = GetLowestHealthEnemyMinion(1150)
	targetignite = GetWeakEnemy('TRUE',600)
	    if Morgana.Combo then Combo() end
		if Morgana.AutoFarm then AutoFarm() end
		if Morgana.Autoharass then Autoharass() end
		if Morgana.shielditems then shielditems() end
		if Morgana.ignite then ignite() end
		if Morgana.Killsteal then Killsteal() end
		
end

function Main()
        if tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client" then
                if blockAndMove ~= nil then blockAndMove() end
                send.tick()
        end
end
 


	Morgana, menu = uiconfig.add_menu('Laughings Morgana', 200)
	
	menu.keydown('Combo', 'Combo', Keys.X)
	menu.keytoggle('AutoFarm', 'AutoFarm', Keys.T)
	menu.keytoggle('Autoharass', 'Autoharass', Keys.F2, true)	
	menu.keytoggle('shielditems', 'shielditems', Keys.F3, true)
	menu.keytoggle('AutoW', 'AutoW', Keys.F4, true)
	menu.keytoggle('useItems', 'useItems', Keys.F5, true)
	menu.keytoggle('ignite', 'ignite', Keys.F6, true)
	menu.keytoggle('autoShield', 'autoShield', Keys.F7, true)
	menu.keytoggle('Killsteal', 'Killsteal', Keys.Y, true)
	
	menu.permashow('Combo')
	menu.permashow('AutoFarm')
	menu.permashow('shielditems')
	menu.permashow('Autoharass')
	menu.permashow('AutoW')
	menu.permashow('useItems')
	menu.permashow('ignite')
	menu.permashow('autoShield')
	menu.permashow('Killsteal')
	
	
function shielditems()
if myHero.health < myHero.maxHealth*(15 / 100) then
	GetInventorySlot(3157)
	UseItemOnTarget(3157,myHero)
	GetInventorySlot(3040)
	UseItemOnTarget(3040,myHero)	
end
end

function Zhonyas()
	GetInventorySlot(3157)
	UseItemOnTarget(3157,myHero)
end

function SeraphsEmbrace()
	GetInventorySlot(3040)
	UseItemOnTarget(3040,myHero)
	end

function Qspellpred()
 local Qrange = 900
 local Qdelay = 1
 local Qspeed = 12
 local count = 20 -- (Timer)
 if target4~=nil then
  local FX,FY,FZ = GetFireahead(target4,Qdelay,Qspeed)
  if distXYZ(myHero.x,myHero.z,FX,FZ)<Qrange then
   table.insert(Counter, myHero)
  end
 end
 if target4==nil or distXYZ(myHero.x,myHero.z,FX,FZ)>Qrange then
  for i,v in pairs(Counter) do Counter[i] = nil end
 end
 if #Counter>count then
  SpellPred(Q,QRDY,myHero,target4,Qrange,Qdelay,Qspeed,1)
 end
end

function Combo()
	if target4 ~= nil then
		if Morgana.useItems then 
			UseAllItems(target4) 
		end

				if GetDistance(target4) < 450 then
		CastHotkey('AUTO 100,0 ATTACK:WEAKENEMY PATROLSTRAFE=300')
		end
Qspellpred()
SpellTarget(W,WRDY,myHero,target4,900)
	elseif target4 == nil and Morgana.Combo then
		MoveToMouse()
	end
end

function Killsteal()
	if target ~= nil then
		local Wdmg = getDmg("W",target,myHero)
		if WRDY==1 then
			if target.health < Wdmg then
				SpellTarget(W,WRDY,myHero,target,625)
			end
		end
	end
end	

function Autoharass()
	if target4~=nil then
			Qspellpred()
		end
	end

	
function AutoFarm()
	minion = GetLowestHealthEnemyMinion(625)
	if minion ~= nil then
		if minion.health < getDmg('W',minion,myHero) then
			CastSpellTarget("W", minion)
		end
	end
end


function OnCreateObj(obj)
if Morgana.AutoW and target4~=nil then
if (string.find(obj.charName,"LOC_Stun")~=nil or string.find(obj.charName,"summoner_banish") or string.find(obj.charName,"AlZaharNetherGrasp_tar")~=nil or string.find(obj.charName,"InfiniteDuress_tar")~=nil or string.find(obj.charName,"skarner_ult_tail_tip")~=nil or string.find(obj.charName,"SwapArrow_red")~=nil or string.find(obj.charName,"Global_Taunt")~=nil or string.find(obj.charName,"Global_Fear")~=nil or string.find(obj.charName,"Ahri_Charm_buf")~=nil or string.find(obj.charName,"leBlanc_shackle_tar")~=nil or string.find(obj.charName,"LuxLightBinding_tar")~=nil or string.find(obj.charName,"RunePrison_tar")~=nil or string.find(obj.charName,"DarkBinding_tar")~=nil or string.find(obj.charName,"nassus_wither_tar")~=nil or string.find(obj.charName,"Amumu_SadRobot_Ultwrap")~=nil or string.find(obj.charName,"Amumu_Ultwrap")~=nil or string.find(obj.charName,"maokai_elementalAdvance_root_01")~=nil or string.find(obj.charName,"RengarEMax_tar")~=nil or string.find(obj.charName,"VarusRHitFlash")~=nil) and GetDistance(target4,obj)<100 then
SpellTarget(W,WRDY,myHero,target4,900)
end
end
end



function GetGlobalTarget()
	local ultTarget = objManager:GetHero(1)
	for i = 2, objManager:GetMaxHeroes() do
		local t = objManager:GetHero(i)
		if t.health < ultTarget.health and t.team ~= myHero.team and t.visible == 1 and t.dead==0 then
			ultTarget = t
		end
	end
	if ultTarget.team == myHero.team or ultTarget.visible == 0 or ultTarget.dead == 1 then
		ultTarget = nil
	end
	return ultTarget
end


function ignite()
	local damage = (myHero.selflevel*20)+50
	if targetignite ~= nil then
		if myHero.SummonerD == 'SummonerDot' then
			if targetignite.health < damage then
				CastSpellTarget('D',targetignite)
			end
		end
		if myHero.SummonerF == 'SummonerDot' then
			if targetignite.health < damage then
				CastSpellTarget('F',targetignite)
			end
		end
	end
end

 --------------------------------------------------------
 
 

function ResetTimer()
	if GetTickCount() - spellShot.time > 0 then
		spellShot.shot = false
		spellShot.time = 0
		shotMe = false
	end
end

function IsHero(unit)
  for i=1, objManager:GetMaxHeroes(), 1 do
		local object = objManager:GetHero(i)
		if object ~= nil and object.charName == unit.charName then
			return true
		end
	end
	return false
end



function autoShield(target)
	if Morgana.autoShield and CanCastSpell("E") then
		CastSpellTarget("E",target)
	end	
	t0_attacking = GetClock()+attackAnimationDuration
end



function OnProcessSpell(unit, spell)
	if unit ~= nil and spell ~= nil and unit.team ~= myHero.team and IsHero(unit) then
		startPos = spell.startPos
		endPos = spell.endPos
		if spell.target ~= nil then
			local targetSpell = spell.target
			if target ~= nil and target.charName == targetSpell.charName then
				target2 = unit
				autoShield(target)
			end
			if myHero.charName == targetSpell.charName then
				target2 = unit
				autoShield(myHero)
			end			
		end
		if target ~= nil then
			local shot = SpellShotTarget(unit, spell, target)
			if shot ~= nil then
				spellShot = shot
				if spellShot.shot then
					target2 = unit
					autoShield(target)	
				end
			end
		end
		local shot = SpellShotTarget(unit, spell, myHero)
		if shot ~= nil then
			spellShot = shot
			if spellShot.shot then
				shotMe = true
				target2 = unit
				autoShield(myHero)	
			end
		end
	end
	if unit ~= nil and spell ~= nil and string.find(spell.name,"HowlingGale") and unit.charName == myHero.charName and attacking then
		attacking = false
		CastSpellTarget("Q",myHero)
	end
end
-----------------------------------------------------------------------------------------
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


SetTimerCallback('Main')
SetTimerCallback('MorganaRun')