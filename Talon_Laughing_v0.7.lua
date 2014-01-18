require 'Utils'
require 'winapi'
require 'SKeys'
require 'spell_damage'
local Q,W,E,R = 'Q','W','E','R'
local uiconfig = require 'uiconfig'
local version = '1.0'
local target
local minion
local CleanseList = {"Stun_glb", "AlZaharNetherGrasp_tar", "InfiniteDuress_tar", "skarner_ult_tail_tip", "SwapArrow_red", "Global_Taunt", "Global_Fear", "Ahri_Charm_buf", "leBlanc_shackle_tar", "LuxLightBinding_tar", "RunePrison_tar", "DarkBinding_tar", "nassus_wither_tar", "Amumu_SadRobot_Ultwrap", "Amumu_Ultwrap", "maokai_elementalAdvance_root_01", "RengarEMax_tar", "VarusRHitFlash"}



function Main()
	if IsChatOpen() == 0 and IsLolActive() then
		SetVariables()
		if Talon.Combo then Combo() end
		if Talon.Combo2 then Combo2() end
		if Talon.AutoFarm then AutoFarm() end
		if Talon.Killsteal then Killsteal() end
		if Talon.Autoharass then Autoharass() end
		if Talon.AutoUlt then AutoUlt() end
		if Talon.ignite then ignite() end
		if Talon.AutoFarm then AutoFarm() end
	end
	end
		
	Talon, menu = uiconfig.add_menu('Laughings Talon', 200)
	menu.keydown('Combo', 'Combo', Keys.X)
	menu.keydown('Combo2', 'Combo Ulti', Keys.Z)
	menu.keytoggle('AutoFarm', 'Auto Farm', Keys.T)
	menu.keytoggle('Killsteal', 'Killsteal', Keys.F1, true)
	menu.keytoggle('AutoUlt', 'Ult at low health', Keys.F2, true)
	menu.keytoggle('Autoharass', 'Auto Harass', Keys.F3, true)	
	menu.keytoggle('AutoCleanse', 'Auto QSS', Keys.F4, true)
	menu.keytoggle('useItems', 'useItems', Keys.F5, true)
	menu.keytoggle('ignite', 'ignite', Keys.F6, true)
	menu.permashow('Combo')
	menu.permashow('Combo2')
	menu.permashow('AutoFarm')
	menu.permashow('Killsteal')
	menu.permashow('AutoUlt')
	menu.permashow('Autoharass')
	menu.permashow('AutoCleanse')
	menu.permashow('useItems')
	menu.permashow('ignite')

function SetVariables()
	target = GetWeakEnemy("PHYS", 700)
	targetignite = GetWeakEnemy('TRUE',600)
	
	if myHero.SpellTimeQ > 1.0 and GetSpellLevel('Q')~=0 then QRDY = 1
	else QRDY = 0 end
	if myHero.SpellTimeW > 1.0 and GetSpellLevel('W')~=0 then WRDY = 1
	else WRDY = 0 end
	if myHero.SpellTimeE > 1.0 and GetSpellLevel('E')~=0 then ERDY = 1
	else ERDY = 0 end
	if myHero.SpellTimeR > 1.0 and GetSpellLevel('R')~=0 then RRDY = 1
	else RRDY = 0 end
end	



function Combo()
	if target ~= nil then
		if Talon.useItems then 
			UseAllItems(target) 
		end

				if GetDistance(target) < 450 then
		CastHotkey('AUTO 100,0 ATTACK:WEAKENEMY PATROLSTRAFE=300')
		end
		SpellTarget(W,WRDY,myHero,target,575)
		SpellTarget(E,ERDY,myHero,target,700)
		SpellTarget(Q,QRDY,myHero,target,625)
	elseif target == nil and Talon.Combo then
		MoveToMouse()
	end
end

function Combo2()
	if target ~= nil then
		if Talon.useItems then 
			UseAllItems(target) 
		end
	
				if GetDistance(target) < 750 then
		CastHotkey('AUTO 100,0 ATTACK:WEAKENEMY PATROLSTRAFE=300')
		end
		SpellTarget(W,WRDY,myHero,target,575)
		SpellTarget(E,ERDY,myHero,target,700)
		SpellTarget(Q,QRDY,myHero,target,625)
		SpellTarget(R,RRDY,myHero,myHero,500)
	elseif target == nil and Talon.Combo2 then
		MoveToMouse()
	end
end

function AutoUlt()
if target ~= nil then
if myHero.health < myHero.maxHealth*(15 / 100) then
SpellTarget(R,RRDY,myHero,myHero,500)
end
end
end

	
function Killsteal()
	if target ~= nil then
		local dmg = getDmg("W",target,myHero)
		if WRDY==1 then
			if target.health < dmg then
				SpellTarget(W,WRDY,myHero,target,575)
			end
		end
	end
end	

function Autoharass()
	if target~=nil then
			SpellTarget(W,WRDY,myHero,target,575)
		end
	end

	
function AutoFarm()
	minion = GetLowestHealthEnemyMinion(600)
	if minion ~= nil then
		if minion.health < getDmg('W',minion,myHero) then
			CastSpellTarget("W", minion)
		end
	end
end


    function OnCreateObj(obj)
            if Talon.AutoCleanse then
                    if (string.find(obj.charName,"LOC_Stun")~=nil or string.find(obj.charName,"summoner_banish") or string.find(obj.charName,"AlZaharNetherGrasp_tar")~=nil or string.find(obj.charName,"InfiniteDuress_tar")~=nil or string.find(obj.charName,"skarner_ult_tail_tip")~=nil or string.find(obj.charName,"SwapArrow_red")~=nil or string.find(obj.charName,"Global_Taunt")~=nil or string.find(obj.charName,"Global_Fear")~=nil or string.find(obj.charName,"Ahri_Charm_buf")~=nil or string.find(obj.charName,"leBlanc_shackle_tar")~=nil or string.find(obj.charName,"LuxLightBinding_tar")~=nil or string.find(obj.charName,"RunePrison_tar")~=nil or string.find(obj.charName,"DarkBinding_tar")~=nil or string.find(obj.charName,"nassus_wither_tar")~=nil or string.find(obj.charName,"Amumu_SadRobot_Ultwrap")~=nil or string.find(obj.charName,"Amumu_Ultwrap")~=nil or string.find(obj.charName,"maokai_elementalAdvance_root_01")~=nil or string.find(obj.charName,"RengarEMax_tar")~=nil or string.find(obj.charName,"VarusRHitFlash")~=nil) and GetDistance(myHero,obj)<100 then
if GetInventorySlot(3139) ~= nil then
    UseItemOnTarget(3139, myHero)
   elseif GetInventorySlot(3140) ~= nil  then
    UseItemOnTarget(3140, myHero)   
   end
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

function IsLolActive()
    return tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client"
end

SetTimerCallback("Main")