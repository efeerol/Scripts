require 'Utils'
require 'spell_damage'
require 'spell_shot'
require 'winapi'
require 'SKeys'
require 'vals_lib'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local Q,W,E,R = 'Q','W','E','R'
local targetq
local targetignite
local timer = os.time()
local spellShot = {shot = false, radius = 0, time = 0, shotX = 0, shotZ = 0, shotY = 0, safeX = 0, safeY = 0, safeZ = 0, isline = false}
local startPos = {x=0, y=0, z=0}
local endPos = {x=0, y=0, z=0}
local shotMe = false
local Counter = {}
local target
local HavocDamage = 0
local ExecutionerDamage = 0
local skillshotArray = {}

        sivir, menu = uiconfig.add_menu('Insane Sivir', 200)
		
        menu.keydown('Autoq','CastQ',Keys.X)      
        menu.checkbutton('Autow', 'AutoW' , true)
        menu.checkbutton('ignite', 'Auto-ignite',false)
		menu.checkbutton('Barrier', 'Auto-Barrier',true)
		menu.checkbutton('killsteal','killsteal',true)
        menu.checkbutton('shielditems', 'shielditems', true)
		
		menu.permashow('Autoq')
		menu.permashow('Barrier')
		menu.permashow('ignite')
		menu.permashow('killsteal')
		
function SivirRun()
targetq = GetWeakEnemy('PHYS',1075)
targetignite = GetWeakEnemy('TRUE',600)
target = nil
		ResetTimer()
		GetCD()
local maxHealth = 9999
		Util__OnTick()
        if sivir.Autoq then Q() end
		if sivir.Autow then W() end
		if sivir.shielditems then shielditems()  end
        if sivir.ignite then ignite() end
		if sivir.Barrier then barrier() end
		if sivir.killsteal then Killsteal() end
end
function Q()
if targetq ~= nil then
CastHotkey("Q AUTO 100,0 SPELLQ:WEAKENEMY RANGE=1075 FIREAHEAD=2,13 CD=1 MAXDIST SAVECURSOR=50")
end
end
function W()
	AArange = (myHero.range+(GetDistance(GetMinBBox(myHero))))
	targetaa = GetWeakEnemy('PHYS',AArange)
	GetCD()
	if GetAA() and WRDY==1 then CastSpellTarget('W',myHero) end
	if targetaa~=nil then CastSpellTarget('W',targetaa) end
end

function E()
		if sivir.AutoShield and CanCastSpell("E")  then
		CastSpellTarget("E",myHero)
	end	
end
function barrier()
		if myHero.SummonerD == 'SummonerBarrier' then
			if myHero.health < myHero.maxHealth*.15 then
				CastSpellTarget('D',myHero)
			end
		end
		if myHero.SummonerF == 'SummonerBarrier' then
			if myHero.health < myHero.maxHealth*.15 then
				CastSpellTarget('F',myHero)
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
function SummonerBarrier()
		if myHero.SummonerD == 'SummonerBarrier' then
			if myHero.health < myHero.maxHealth*.25 then
				CastSpellTarget('D',myHero)
			end
		end
		if myHero.SummonerF == 'SummonerBarrier' then
			if myHero.health < myHero.maxHealth*.25 then
				CastSpellTarget('F',myHero)
			end
		end
end
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
		
function Killsteal()
	if target ~= nil then
		local Qdmg = getDmg("Q",target,myHero)
		if QRDY==1 then
			if target.health < Qdmg then
			CastHotkey("Q AUTO 100,0 SPELLQ:WEAKENEMY RANGE=1075 FIREAHEAD=2,13 CD=1 MAXDIST SAVECURSOR=50")
			end
		end
	end
end

function Qspellpred()
 local Qrange = 1075
 local Qdelay = 3.3
 local Qspeed = 13.3
 local count = 20 -- (Timer)
 if targetq~=nil then
  local FX,FY,FZ = GetFireahead(targetq,Qdelay,Qspeed)
  if distXYZ(myHero.x,myHero.z,FX,FZ)<Qrange then
   table.insert(Counter, myHero)
  end
 end
 if targetq==nil or distXYZ(myHero.x,myHero.z,FX,FZ)>Qrange then
  for i,v in pairs(Counter) do Counter[i] = nil end
 end
 if #Counter>count then
  SpellPred(Q,QRDY,myHero,target4,Qrange,Qdelay,Qspeed,1)
 end
end

function ResetTimer()
	if GetTickCount() - spellShot.time > 0 then
		spellShot.shot = false
		spellShot.time = 0
		shotMe = false
	end
end

function GetAA()
    local AArange = (myHero.range+(GetDistance(GetMinBBox(myHero))))*1.2
    local targetaa = GetWeakEnemy('PHYS',AArange)
    local spells1={}
    local a1={GetCastSpell()}    
    local g1=0
    while (a1~=nil and a1[1] ~= nil and g1<200) do
        local spell1={}
        local startPos1={}
        local endPos1={}
        spell1.unit=a1[1]
        spell1.name=a1[2]
        startPos1.x=a1[3]
        startPos1.y=a1[4]
        startPos1.z=a1[5]
        endPos1.x=a1[6]
        endPos1.y=a1[7]
        endPos1.z=a1[8]
        spell1.target=a1[12]
        spell1.startPos1=startPos1
        spell1.endPos1=endPos1
        table.insert(spells1, spell1)
        a1={GetCastSpell()}
        g1=g1+1
        if (string.find(spell1.name,'Attack') or string.find(spell1.name,'attack')) and (spell1.unit.name == myHero.name) then
            attackstart = true
        end
    end
    for i=1, objManager:GetMaxNewObjects() do
        local obj = objManager:GetNewObject(i)  
        if obj ~= nil then
            if targetaa~=nil and attackstart and string.find(obj.charName,'globalhit') and GetDistance(obj, targetaa) < 50 then
                attackstart = false
                return true
            end
        end
    end
end
SetTimerCallback('SivirRun')