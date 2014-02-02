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
local qx=0
local qy=0
local qz=0
local hero_table = {}
local deconce=0
local pdot=0
local ddot=0
local edot=0
local script_loaded=1
local zv = Vector(0,0,0)
local amax_heroes = 0
local targetq
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
 
function NidaleeRun()
if IsChatOpen() == 0 then
     targetq = GetWeakEnemy('PHYS',1500)
        local maxHealth = 9999
        target = nil
        target3 = GetWeakEnemy('MAGIC',1500)
        if myHero.SpellTimeQ > 1.0 then
        QRDY = 1
        else QRDY = 0
		
        end
		Util__OnTick()
		velocity()
 
        target4 = GetWeakEnemy('MAGIC',1500)
        target5 = GetWeakEnemy('MAGIC',1500)
        targetignite = GetWeakEnemy('TRUE',600)
        if nidalee.Autoharass then Autoharass() end
        if nidalee.shielditems then shielditems()  end
        if nidalee.ignite then ignite() end
		if nidalee.useItems then useItems() end
end
end
 
function Main()
        if tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client" then
                if blockAndMove ~= nil then blockAndMove() end
                send.tick()
        end
end
 
 
 
        nidalee, menu = uiconfig.add_menu('Insane nidalee', 200)
       
        menu.keytoggle('Autoharass', 'NeverMissQ', Keys.F2, true)      
        menu.keytoggle('useItems', 'useItems', Keys.F5, true)
        menu.keytoggle('ignite', 'ignite', Keys.F6, true)
        menu.keytoggle('shielditems', 'shielditems', Keys.F3, true)
       
        menu.permashow('Autoharass')
        menu.permashow('useItems')
        menu.permashow('ignite')
        menu.permashow('shielditems')
       
       
function shielditems()
if myHero.health < myHero.maxHealth*(15 / 100) then
        GetInventorySlot(3157)
        UseItemOnTarget(3157,myHero)
        GetInventorySlot(3040)
        UseItemOnTarget(3040,myHero)   
end
end

function useItems()
        AttackRange = 225
    if target ~= nil then
        local htdistance = GetDistance(myHero, target)
        if htdistance < 400 then -- IR
            UseItemOnTarget(3144, target) -- Bilgewater Cutlass
            UseItemOnTarget(3143, target) -- Randuin's Omen
        end
        if htdistance < 700 then -- IR
            UseItemOnTarget(3146, target) -- Hextech Gunblade
        end
        if htdistance < 500 then -- IR
            UseItemOnTarget(3153, target) -- Blade of the Ruined King
        end
        if htdistance < 750 then -- IR
            UseItemOnTarget(3128, target) -- Deathfire Grasp
        end
        if htdistance < 525 then -- IR
            UseItemOnTarget(3180, target) -- Odyn's Veil
        end
        if htdistance < AttackRange+10 then -- AR
            UseItemOnTarget(3184, target) -- Entropy
            UseItemOnTarget(3074, target) -- Ravenous Hydra
            UseItemOnTarget(3131, target) -- Sword of the Divine
            UseItemOnTarget(3142, target) -- Youmuu's Ghostblade
        end
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
       
function Autoharass()
        if target4~=nil and  myHero.range > 200 then
                        Qspellpred()
                end
        end
function Qspellpred()
local Qrange = 1500
local Qdelay = 1.56
local Qspeed = 12.82
local FX,FY,FZ = GetFireahead(target4,Qdelay,Qspeed)
local bq = bestcoords(target4)
local vts = hero_table[targetq.name][3]
if target4~=nil then 
  if distXYZ(myHero.x,myHero.z,FX,FZ)<Qrange then
   table.insert(Counter, myHero)
   end
   if target4==nil or distXYZ(myHero.x,myHero.z,FX,FZ)>Qrange then
for i,v in pairs(Counter) do Counter[i] = nil end
if target4 ~= nil and vts:len() ~= 0 and bq == 1 and CreepBlock(qx,qy,qz,25) == 0 then
SpellPred(Q,QRDY,myHero,target4,1500,2,11,1)
elseif target4 ~= nil and vts:len() ~= 0  then
SpellPred(Q,QRDY,myHero,target4,1500,3,11,1)
end 
elseif target4 ~= nil and CreepBlock(qx,qy,qz,50) == 0  then
SpellPred(Q,QRDY,myHero,target4,1500,1,14,1)
end
end
end
function declare2darray()
    amax_heroes=objManager:GetMaxHeroes()
    if amax_heroes > 1 then
        for i = 1,amax_heroes, 1 do
            local h=objManager:GetHero(i)
            local name=h.name
            hero_table[name]={}
            hero_table[name][0] = 0
            hero_table[name][1] = zv
            hero_table[name][2] = 0
            hero_table[name][3] = zv
        end
    end
end
function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end


function velocity()
    --print("\ndebugv:\n")
    local max_heroes=objManager:GetMaxHeroes()
    --print("maxheroes: " .. max_heroes .. " || ")
    if max_heroes > amax_heroes then declare2darray() end

    local timedif = 0
    local cordif = Vector(0,0,0)

    for i = 1,max_heroes, 1 do
        local h=objManager:GetHero(i)
        local name=h.name
        if name ~= nil then
            cordif = Vector(h.x,h.y,h.z) - hero_table[name][1]
            hero_table[name][3] = Vector(round(cordif.x/timedif,7),round(cordif.y/timedif,7),round(cordif.z/timedif,7))
            hero_table[name][1]    = Vector(h.x,h.y,h.z)
        end
    end
end
function bestcoords(btarget)
    local x1,y1,z1 = GetFireahead(target4,13,1)
    local ve= Vector(x1 - btarget.x,y1 - btarget.y,z1 - btarget.z) -- getfireahead - target
    local nb = btarget.name
    local vvt = hero_table[nb][3]	
    local vst = Vector(btarget.x - myHero.x,btarget.y-myHero.y,btarget.z - myHero.z) -- target - self
    local vse = Vector(x1-myHero.x,y1-myHero.y,z1-myHero.z) -- getfireahead - self
    local speedratio = (btarget.movespeed / vvt:len())
    if vvt:len() ~= 0 then
        local vstn = vst:normalized()
        local vvtn = vvt:normalized()
        local ven = ve:normalized()
        local vsen = vse:normalized()
        ddot = math.abs(vsen:dotP(ven))
        edot = math.abs(vvtn:dotP(ven))
        pdot = math.abs(vstn:dotP(vvtn))    
        if  vst:len() < 1450 and CreepBlock(qx,qy,qz,250) == 0  then
            qx=x1
            qy=y1
            qz=z1
            return 1
        end
    elseif vvt:len() == 0 and vst:len() < 1485 and CreepBlock(qx,qy,qz,250) == 0 then
            qx=btarget.x
            qy=btarget.y
            qz=btarget.z
            return 1
    else
        return 0
    end
    return 0

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
       
 
function IsHero(unit)
  for i=1, objManager:GetMaxHeroes(), 1 do
                local object = objManager:GetHero(i)
                if object ~= nil and object.charName == unit.charName then
                        return true
                end
        end
        return false
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
 
SetTimerCallback('Main')
SetTimerCallback('NidaleeRun')