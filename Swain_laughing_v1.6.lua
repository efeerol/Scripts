require 'Utils'
require 'spell_damage'
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
local GG = 0


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

function SwainRun()
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

	

	target = GetWeakEnemy('MAGIC',1000)
	target4 = GetWeakEnemy('MAGIC',900)
	target5 = GetWeakEnemy('MAGIC',1150)
	minion = GetLowestHealthEnemyMinion(1150)
	targetignite = GetWeakEnemy('TRUE',600)
	    if Swain.Combo then Combo() end
		if Swain.AutoR then Auto() end
		if Swain.AutoFarm then AutoFarm() end
		if Swain.Autoharass then Autoharass() end
		if Swain.shielditems then shielditems() end
		if Swain.ignite then ignite() end
		if Swain.Killsteal then Killsteal() end
		
end

function Main()
        if tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client" then
                if blockAndMove ~= nil then blockAndMove() end
                send.tick()
        end
end
 


	Swain, menu = uiconfig.add_menu('Laughings Swain', 200)
	
	menu.keydown('Combo', 'Combo', Keys.X)
	menu.keytoggle('AutoFarm', 'W Farming', Keys.T)
	menu.keytoggle('Autoharass', 'Auto Harass', Keys.F2, true)	
	menu.keytoggle('shielditems', 'Shield Items', Keys.F3, true)
	menu.keytoggle('AutoR', 'Auto Ulti', Keys.F4, true)
	menu.keytoggle('useItems', 'Use Items', Keys.F5, true)
	menu.keytoggle('ignite', 'Ignite', Keys.F6, true)
	menu.keytoggle('Killsteal', 'Killsteal Q E', Keys.F1, true)
	
	menu.permashow('Combo')
	menu.permashow('AutoFarm')
	menu.permashow('shielditems')
	menu.permashow('Autoharass')
	menu.permashow('AutoR')
	menu.permashow('useItems')
	menu.permashow('ignite')
	menu.permashow('Killsteal')
	
	
function shielditems()
if myHero.health < myHero.maxHealth*(20 / 100) then
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

function Wspellpred()
 local Wrange = 900
 local Wdelay = 7
 local Wspeed = 99
 local count = 25 -- (Timer)
 if target~=nil then
  local FX,FY,FZ = GetFireahead(target,Wdelay,Wspeed)
  if distXYZ(myHero.x,myHero.z,FX,FZ)<Wrange then
   table.insert(Counter, myHero)
  end
 end
 if target==nil or distXYZ(myHero.x,myHero.z,FX,FZ)>Wrange then
  for i,v in pairs(Counter) do Counter[i] = nil end
 end
 if #Counter>count then
  SpellPred(W,WRDY,myHero,target,Wrange,Wdelay,Wspeed,0)
 end
end




-------
local autoR = false
local crow = false
	function Auto()
            if myHero.dead == 1 then crow = false end
            if target ~= nil then
                    if crow == false and CanCastSpell("R") and GetDistance(target) < 700 then                     
                            CastSpellTarget("R",myHero)
                            autoR = true   
                    end
                    if crow == true and CanCastSpell("R") and autoR == true and GetDistance(target) > 900 then
                            CastSpellTarget("R",myHero)
                            autoR = false
                    end
            else
                    if crow == true and CanCastSpell("R") and autoR == true then
                            CastSpellTarget("R",myHero)
                            autoR = false
                    end
            end    
    end
     

     
    function OnProcessSpell(unit, spell)
            if unit.team==myHero.team and GetDistance(unit,myHero)<10 then
                    local s=spell.name
                    if (s ~= nil) and string.find(s,"SwainMetamorphism") ~= nil then
                            if crow==false then crow=true
                            elseif crow==true then crow=false end
                    end
            end
    end


-------

function Combo()
	if target ~= nil then
		if Swain.useItems then 
			UseAllItems(target) 
		end

				if GetDistance(target) < 550 then
		CastHotkey('AUTO 100,0 ATTACK:WEAKENEMY PATROLSTRAFE=300')
		end
Wspellpred()
		SpellTarget(E,ERDY,myHero,target,625)
		SpellTarget(Q,QRDY,myHero,target,625)
	elseif target == nil and Swain.Combo then
		MoveToMouse()
	end
end

function Killsteal()
	if target ~= nil then
		local Qdmg = getDmg("Q",target,myHero)
		local Edmg = getDmg("E",target,myHero)
		if QRDY==1 then
			if target.health < Qdmg then
				SpellTarget(Q,QRDY,myHero,target,625)
			end
		end
				if ERDY==1 then
			if target.health < Edmg then
				SpellTarget(E,ERDY,myHero,target,625)
	end
end	
end
end

function Autoharass()
	if target~=nil then
		SpellTarget(E,ERDY,myHero,target,625)
		SpellTarget(Q,QRDY,myHero,target,625)
		Wspellpred()
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
SetTimerCallback('SwainRun')