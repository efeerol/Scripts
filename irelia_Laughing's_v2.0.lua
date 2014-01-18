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

 
local jungle1 = {}
local junglePositionALL = {
 
{ name = "GreatWraith", team = 300, location = { x = 1684, y = 55, z = 8207} },
{ name = "GreatWraith", team = 300, location = { x = 12337, y = 55, z = 6263} },

{ name = "GiantWolf", team = 300, location = { x = 3374, y = 56, z = 6223} },
{ name = "Wolf", team = 300, location = { x = 3519,y = 55,z = 6247} },
{ name = "Wolf", team = 300, location = { x = 3309, y = 55, z = 6410} },

{ name = "YoungLizard", team = 300, location = { x = 3453, y = 55, z = 7589} },
{ name = "YoungLizard", team = 300, location = { x = 3553,y = 54,z = 7799} },
{ name = "AncientGolem", team = 300, location = { x = 3633, y = 54, z = 7599} },

{ name = "LesserWraith", team = 300, location = { x = 6583, y = 53, z = 5108} },
{ name = "Wraith", team = 300, location = { x = 6446, y = 56, z = 5215} },
{ name = "LesserWraith", team = 300, location = { x = 6654, y = 59, z = 5278} },
{ name = "LesserWraith", team = 300, location = { x = 6496, y = 61, z = 5365} },

{ name = "YoungLizard", team = 300, location = { x = 7461, y = 57, z = 3710} },
{ name = "YoungLizard", team = 300, location = { x = 7238,y = 58,z = 3890} },
{ name = "LizardElder", team = 300, location = { x = 7456, y = 57, z = 3890} },

{ name = "Golem", team = 300, location = { x = 8217,y = 54,z = 2534} },
{ name = "SmallGolem", team = 300, location = { x = 7917, y = 54, z = 2534} },

{ name = "GiantWolf", team = 300, location = { x = 10652, y = 64, z = 8116} },
{ name = "Wolf", team = 300, location = { x = 10680,y = 65,z = 7997} },
{ name = "Wolf", team = 300, location = { x = 10436, y = 66, z = 8136} },

{ name = "YoungLizard", team = 300, location = { x = 10587, y = 55, z = 6831} },
{ name = "YoungLizard", team = 300, location = { x = 10527,y = 55,z = 6601} },
{ name = "AncientGolem", team = 300, location = { x = 10387, y = 55, z = 6811} },

{ name = "YoungLizard", team = 300, location = { x = 6504, y = 55, z = 10785} },
{ name = "YoungLizard", team = 300, location = { x = 6704,y = 55,z = 10585} },
{ name = "LizardElder", team = 300, location = { x = 6504, y = 55, z = 10585} },

{ name = "LesserWraith", team = 300, location = { x = 7450, y = 55, z = 9350} },
{ name = "Wraith", team = 300, location = { x = 7580, y = 55, z = 9250} },
{ name = "LesserWraith", team = 300, location = { x = 7480, y = 56, z = 9091} },
{ name = "LesserWraith", team = 300, location = { x = 7350, y = 56, z = 9230} },

{ name = "Golem", team = 300, location = { x = 6140,y = 40,z = 11935} },
{ name = "SmallGolem", team = 300, location = { x = 5846, y = 40, z = 11915} },

{ name = "Dragon", team = 300, location = { x = 9460,y = -61,z = 4193} },
{ name = "Worm", team = 300, location = { x = 4600,y = -63,z = 10250} },
 
}



function Main()
	if IsChatOpen() == 0 and IsLolActive() then
		SetVariables()
		if Irelia.Combo then Combo() end
		if Irelia.Combo2 then Combo2() end
		if Irelia.jungle then UpdatejungleTable1() KS1() end
		if Irelia.AutoFarm then AutoFarm() end
		if Irelia.Killsteal then Killsteal() end
		if Irelia.Autoharass then Autoharass() end
		if Irelia.AutoUlt then Ulti() end
		if Irelia.ignite then ignite() end
		

	end
	end
		
	Irelia, menu = uiconfig.add_menu('Laughings Irelia', 200)
	menu.keydown('Combo', 'Combo', Keys.X)
	menu.keydown('Combo2', 'Combo Ulti', Keys.Z)
	menu.keytoggle('AutoFarm', 'AutoFarm', Keys.T)
	menu.keytoggle('jungle', 'jungle', Keys.Y)
	menu.keytoggle('AutoUlt', 'Ulti', Keys.C)
	menu.keytoggle('Killsteal', 'Killsteal', Keys.F1, true)
	menu.keytoggle('Autoharass', 'Autoharass', Keys.F2, true)	
	menu.keytoggle('AutoCleanse', 'AutoCleanse', Keys.F4, true)
	menu.keytoggle('useItems', 'useItems', Keys.F5, true)
	menu.keytoggle('ignite', 'ignite', Keys.F6, true)
	menu.permashow('Combo')
	menu.permashow('Combo2')
	menu.permashow('AutoUlt')
	menu.permashow('AutoFarm')
	menu.permashow('jungle')
	menu.permashow('Killsteal')
	menu.permashow('Autoharass')
	menu.permashow('AutoCleanse')
	menu.permashow('useItems')
	menu.permashow('ignite')

function SetVariables()
	target = GetWeakEnemy("PHYS", 1000)
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


---------------------------ENEMY BLUE
function UpdatejungleTable1()
        for i=1, objManager:GetMaxObjects(), 1 do
                object = objManager:GetObject(i)
                        if object ~= nil then
                        if GetDistance(object)<500 then
                                --print("\n Name "..object.name .. "\n")
                               -- print("\n Team "..object.team .. "\n")
                               -- print("\n x "..object.x .. "\n")
                              --  print("\n y "..object.y .. "\n")
                              --  print("\n z "..object.z .. "\n")
                                end
                                for k, x in ipairs(junglePositionALL) do
                                        if object.name == x.name then
                                                if GetDistance(object,x.location) < 1000 then
                                                local name = object.name
                                                local team = x.team
												local xxx = object.x
												local y = object.y
												local z = object.z
                                                 CheckCreep1(name,team,xxx,y,z)
                                               
                                                creep = { hero = object, name = object.name, team = x.team, death = 0, location = x.location }
                                                table.insert(jungle1,creep)
                                               
                                        end
                                end
                        end
                end
        end
 
end
 
function CheckCreep1(name,team,x,y,z)
    if #jungle1 > 0 then
        for i=1,#jungle1, 1 do
            if name == jungle1[i].name and team == jungle1[i].team and x == jungle1[i].x and y == jungle1[i].y and z == jungle1[i].z then
                        table.remove(jungle1,i)
                        break
                        end
        end
    end
end
 
function KS1()
        if #jungle1 > 0 then
                for i, creep in pairs(jungle1) do
                        if creep.name == "AncientGolem" or creep.name == "GreatWraith" or creep.name == "Dragon" or creep.name == "Worm" or creep.name == "LizardElder" or creep.name == "YoungLizard" or creep.name == "SmallGolem" or creep.name == "GiantWolf" or creep.name == "Wolf" or creep.name == "Wraith" or creep.name == "LesserWraith" or creep.name == "Golem" then
								--print('\nInfo '..creep.hero.dead .. ' '..creep.hero.visible.. ' '..GetDistance(creep.hero))
								if creep.hero.dead == 0 and GetDistance(creep.hero) <= 650 then --and creep.team ~= myteam
                                        if getDmg('Q',creep.hero,myHero)+myHero.baseDamage+myHero.addDamage > creep.hero.health then                                
                                        --cfa={x=creep
						
										
                                        --CustomCircle(30,5,5,creep.hero)
                                        CastSpellTarget('Q',creep.hero)
                                        else
                                        --CustomCircle(30,5,3,creep.hero)
                                        end
                                end
                                if creep.hero.dead == 0 and GetDistance(creep.hero) > 650 then --and creep.team ~= myteam
                                        --CustomCircle(30,5,1,creep.hero)
                                        if getDmg('Q',creep.hero,myHero)+myHero.baseDamage+myHero.addDamage > creep.hero.health then                                
                                        --cfa={x=creep
                                        --CustomCircle(30,5,2,creep.hero)
                                        end
                                end
 
                        end
                end
        end
end

function Combo()
	if target ~= nil then
		if Irelia.useItems then 
			UseAllItems(target) 
		end

				if GetDistance(target) < 450 then
		CastHotkey('AUTO 100,0 ATTACK:WEAKENEMY PATROLSTRAFE=300')
		end
		SpellXYZ(W,WRDY,myHero,target,400,myHero.x,myHero.z)
        SpellTarget(E,ERDY,myHero,target,425)
		SpellTarget(Q,QRDY,myHero,target,650)
	elseif target == nil and Irelia.Combo then
		MoveToMouse()
	end
end

function Combo2()
	if target ~= nil then
		if Irelia.useItems then 
			UseAllItems(target) 
		end
	
				if GetDistance(target) < 750 then
		CastHotkey('AUTO 100,0 ATTACK:WEAKENEMY PATROLSTRAFE=300')
		end
		SpellXYZ(W,WRDY,myHero,target,400,myHero.x,myHero.z)
        SpellTarget(E,ERDY,myHero,target,425)
		SpellTarget(Q,QRDY,myHero,target,650)
SpellPred(R,RRDY,myHero,target,1000,1.6,20,0)
	elseif target == nil and Irelia.Combo2 then
		MoveToMouse()
	end
end

function Ulti()
        if target ~= nil then   
				SpellPred(R,RRDY,myHero,target,1000,1.6,20,0)
end
end
	
function Killsteal()
	if target ~= nil then
		local dmg = getDmg("Q",target,myHero)
		if QRDY==1 then
			if target.health < dmg then
				SpellTarget(Q,QRDY,myHero,target,650)
			end
		end
	end
end	

function Autoharass()
	if target~=nil then
			SpellTarget(Q,QRDY,myHero,target,650)
			SpellTarget(E,ERDY,myHero,target,425)
		end
	end

	
function AutoFarm()
	minion = GetLowestHealthEnemyMinion(650)
	if minion ~= nil then
		if minion.health < getDmg('Q',minion,myHero)+myHero.baseDamage+myHero.addDamage then
			CastSpellTarget("Q", minion)
		end
	end
end


    function OnCreateObj(obj)
            if Irelia.AutoCleanse then
                    if (string.find(obj.charName,"LOC_Stun")~=nil or string.find(obj.charName,"summoner_banish") or string.find(obj.charName,"AlZaharNetherGrasp_tar")~=nil or string.find(obj.charName,"InfiniteDuress_tar")~=nil or string.find(obj.charName,"skarner_ult_tail_tip")~=nil or string.find(obj.charName,"SwapArrow_red")~=nil or string.find(obj.charName,"Global_Taunt")~=nil or string.find(obj.charName,"Global_Fear")~=nil or string.find(obj.charName,"Ahri_Charm_buf")~=nil or string.find(obj.charName,"leBlanc_shackle_tar")~=nil or string.find(obj.charName,"LuxLightBinding_tar")~=nil or string.find(obj.charName,"RunePrison_tar")~=nil or string.find(obj.charName,"DarkBinding_tar")~=nil or string.find(obj.charName,"nassus_wither_tar")~=nil or string.find(obj.charName,"Amumu_SadRobot_Ultwrap")~=nil or string.find(obj.charName,"Amumu_Ultwrap")~=nil or string.find(obj.charName,"maokai_elementalAdvance_root_01")~=nil or string.find(obj.charName,"RengarEMax_tar")~=nil or string.find(obj.charName,"VarusRHitFlash")~=nil) and GetDistance(myHero,obj)<100 then
if GetInventorySlot(3139) ~= nil then
    UseItemOnTarget(3139, myHero)
   elseif GetInventorySlot(3140) ~= nil  then
    UseItemOnTarget(3140, myHero)   
   end
  end
 end
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