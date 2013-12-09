require 'Utils'
require 'winapi'
require 'SKeys'
require 'spell_damage'
local Q,W,E,R = 'Q','W','E','R'
local uiconfig = require 'uiconfig'
local version = '1.0'
local target
local minion
local attackDelay = 300
local lastAttack = GetTickCount()
local CleanseList = {"Stun_glb", "AlZaharNetherGrasp_tar", "InfiniteDuress_tar", "skarner_ult_tail_tip", "SwapArrow_red", "Global_Taunt", "Global_Fear", "Ahri_Charm_buf", "leBlanc_shackle_tar", "LuxLightBinding_tar", "RunePrison_tar", "DarkBinding_tar", "nassus_wither_tar", "Amumu_SadRobot_Ultwrap", "Amumu_Ultwrap", "maokai_elementalAdvance_root_01", "RengarEMax_tar", "VarusRHitFlash"}

function Main()
	if IsLolActive() then
		SetVariables()
		if GPMenu.Combo then Combo() end
		if GPMenu.Combo2 then Combo2() end
		if GPMenu.AutoFarm then AutoFarm() end
		if GPMenu.Killsteal then Killsteal() end
		if GPMenu.Autoharass then Autoharass() end
		if GPMenu.AutoUlt then AutoUlt() end
		if GPMenu.ignite then ignite() end
		if not GPMenu.AutoFarm then Combo() end
		if not GPMenu.AutoFarm then Combo2() end
	end
	end
		
	GPMenu, menu = uiconfig.add_menu('Laughings Gangplank', 200)
	menu.keydown('Combo', 'Combo', Keys.X)
	menu.keydown('Combo2', 'Combo Ulti', Keys.Z)
	menu.keytoggle('AutoFarm', 'AutoFarm', Keys.T)
	menu.keytoggle('Killsteal', 'Killsteal', Keys.F1, true)
	menu.keytoggle('Autoharass', 'Autoharass', Keys.F2, true)	
	menu.keytoggle('AutoUlt', 'AutoUlt', Keys.F3)
	menu.keytoggle('AutoCleanse', 'AutoCleanse', Keys.F4, true)
	menu.keytoggle('useItems', 'useItems', Keys.F5, true)
	menu.keytoggle('ignite', 'ignite', Keys.F6, true)
	menu.permashow('Combo')
	menu.permashow('Combo2')
	menu.permashow('AutoFarm')
	menu.permashow('Killsteal')
	menu.permashow('Autoharass')
	menu.permashow('AutoUlt')
	menu.permashow('AutoCleanse')
	menu.permashow('useItems')
	menu.permashow('ignite')

function SetVariables()
	target = GetWeakEnemy("PHYS", 625)
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
		if GPMenu.useItems then 
			UseAllItems(target) 
		end

				if GetDistance(target) < 450 then
		CastHotkey('AUTO 100,0 ATTACK:WEAKENEMY PATROLSTRAFE=300')
		end
		SpellXYZ(E,ERDY,myHero,target,600,myHero.x,myHero.z)
		SpellTarget(Q,QRDY,myHero,target,625)
	elseif target == nil and GPMenu.Combo then
		MoveToMouse()
	end
end

function Combo2()
	if target ~= nil then
		if GPMenu.useItems then 
			UseAllItems(target) 
		end
	
				if GetDistance(target) < 750 then
		CastHotkey('AUTO 100,0 ATTACK:WEAKENEMY PATROLSTRAFE=300')
		end
		SpellXYZ(E,ERDY,myHero,target,600,myHero.x,myHero.z)
		SpellTarget(Q,QRDY,myHero,target,625)
				if RRDY == 1 and GetDistance(myHero, target) < 1000 then
					ultPos = GetMEC(600, 1000, target)
				if ultPos then
					CastSpellXYZ('R', ultPos.x, 0, ultPos.z)
  end
  end
	elseif target == nil and GPMenu.Combo2 then
		MoveToMouse()
	end
end


	
function Killsteal()
	if target ~= nil then
		local dmg = getDmg("Q",target,myHero)
		if QRDY==1 then
			if target.health < dmg then
				SpellTarget(Q,QRDY,myHero,target,625)
			end
		end
	end
end	

function Autoharass()
	if target~=nil then
			SpellTarget(Q,QRDY,myHero,target,625)
		end
	end

	
function AutoFarm()
	minion = GetLowestHealthEnemyMinion(625)
	if minion ~= nil then
		if minion.health < getDmg('Q',minion,myHero)+myHero.baseDamage+myHero.addDamage then
			CastSpellTarget("Q", minion)
		end
	end
end

function AutoUlt()
	if RRDY==1 then
		if target ~= nil then
			local ballDmg = getDmg("R",target,myHero)
			if target.health < ballDmg * 2 then				
				targetLoc = GetMEC(600, 9999999, target)
				if targetLoc ~= nil then
					CastSpellXYZ('R',targetLoc.x,targetLoc.y,targetLoc.z)
				end
			end
		end
	end	
end

    function OnCreateObj(obj)
            if GPMenu.AutoCleanse then
                    if (string.find(obj.charName,"LOC_Stun")~=nil or string.find(obj.charName,"summoner_banish") or string.find(obj.charName,"AlZaharNetherGrasp_tar")~=nil or string.find(obj.charName,"InfiniteDuress_tar")~=nil or string.find(obj.charName,"skarner_ult_tail_tip")~=nil or string.find(obj.charName,"SwapArrow_red")~=nil or string.find(obj.charName,"Global_Taunt")~=nil or string.find(obj.charName,"Global_Fear")~=nil or string.find(obj.charName,"Ahri_Charm_buf")~=nil or string.find(obj.charName,"leBlanc_shackle_tar")~=nil or string.find(obj.charName,"LuxLightBinding_tar")~=nil or string.find(obj.charName,"RunePrison_tar")~=nil or string.find(obj.charName,"DarkBinding_tar")~=nil or string.find(obj.charName,"nassus_wither_tar")~=nil or string.find(obj.charName,"Amumu_SadRobot_Ultwrap")~=nil or string.find(obj.charName,"Amumu_Ultwrap")~=nil or string.find(obj.charName,"maokai_elementalAdvance_root_01")~=nil or string.find(obj.charName,"RengarEMax_tar")~=nil or string.find(obj.charName,"VarusRHitFlash")~=nil) and GetDistance(myHero,obj)<100 then
 if WRDY==1 then
    CastSpellTarget("W", myHero)
   elseif GetInventorySlot(3139) ~= nil then
    UseItemOnTarget(3139, myHero)
   elseif GetInventorySlot(3140) ~= nil  then
    UseItemOnTarget(3140, myHero)   
   end
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

function GetSheenBonusPercentage()
	local boost = 1	
	if GetInventorySlot(3057) ~= nil then
		boost = 2
	elseif GetInventorySlot(3025) ~= nil then
		boost = 2.25
	elseif GetInventorySlot(3087) ~= nil then
		boost = 2.5
	end
	return boost
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