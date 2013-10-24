require 'Utils'
require 'spell_damage'
require 'winapi'
require 'SKeys'
local send = require 'SendInputScheduled'

local Cougar
local target
local target4
local target5
local target6
local Q,W,E,R = 'Q','W','E','R'
local minion
local targetIgnite

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
DetectCougar()
	
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
    
	target = GetWeakEnemy ('MAGIC',900)
	target4 = GetWeakEnemy('MAGIC',1500)
	target5 = GetWeakEnemy('MAGIC',900)
	target6 = GetWeakEnemy('MAGIC',600)
	minion = GetLowestHealthEnemyMinion(400)
	targetignite = GetWeakEnemy('TRUE',600)
	if NidaleeConfig.combo and Cougar == false then combo() end
	if NidaleeConfig.combo and Cougar == true then combo2() end
	if NidaleeConfig.Harass then Harass() end
	if NidaleeConfig.ignite then ignite() end
	if NidaleeConfig.PushFarm then PushFarm() end
	if NidaleeConfig.ESCAPE then ESCAPE() end
	if NidaleeConfig.autojav then autojav() end
	if NidaleeConfig.autoheal then autoheal() end

end

function Main()
	if tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client" then
		if blockAndMove ~= nil then blockAndMove() end
		send.tick()
	end
end

NidaleeConfig = scriptConfig("Nidalee Config", "Nidaleeconfg")
NidaleeConfig:addParam("combo", "Combo (X)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
NidaleeConfig:addParam("ESCAPE", "ESCAPE and CHASE (V)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
NidaleeConfig:addParam("Harass", "Auto Trap (Z)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("Z"))
NidaleeConfig:addParam("PushFarm", "Push Farm (C)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("C"))
NidaleeConfig:addParam("autojav", "Auto Jav (T)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("T"))
NidaleeConfig:addParam("autoheal", "Auto Heal (Y)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("Y"))

NidaleeConfig:addParam("useItems", "Use Items", SCRIPT_PARAM_ONKEYTOGGLE, true, 112)
NidaleeConfig:addParam("ignite", "Auto Ignite", SCRIPT_PARAM_ONKEYTOGGLE, true, 113)


NidaleeConfig:permaShow("combo")
NidaleeConfig:permaShow("Harass")
NidaleeConfig:permaShow("useItems")
NidaleeConfig:permaShow("ignite")
NidaleeConfig:permaShow("PushFarm")
NidaleeConfig:permaShow("ESCAPE")
NidaleeConfig:permaShow("autojav")
NidaleeConfig:permaShow("autoheal")

CleanseConfig = scriptConfig("Cleanse Config", "CleanseMenu")
CleanseConfig:addParam("cleanse", "Use QSS and Cleanse?", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("V"))
CleanseConfig:addParam("cleansespell", "Cleanse Summoner on D", SCRIPT_PARAM_ONOFF, true)

function combo()
	if target ~= nil or target4 ~= nil or target5 ~= nil then
		if NidaleeConfig.useItems then 
		if target ~= nil then
			UseAllItems(target) 
			end
		

		end
		if target ~= nil then
						if GetDistance(target) < 880 then
		CastHotkey('AUTO 100,0 ATTACK:WEAKENEMY PATROLSTRAFE')
		end
		end
		
		SpellPred(Q,QRDY,myHero,target4,1500,1,14,1)
		SpellTarget(E,ERDY,myHero,myHero,900)
		SpellPred(W,WRDY,myHero,target5,900,1,20,0)
	elseif target == nil and NidaleeConfig.combo then
                MoveToMouse()
				else
				MoveToMouse()
				
        end
				if target6 ~= nil then
		if GetDistance(target6) < 400 then
		SpellXYZ(R,RRDY,myHero,myHero,500,myHero.x,myHero.z)
		end
		end
		end

	


function combo2()
	if target ~= nil then

		if NidaleeConfig.useItems then 
			UseAllItems(target) 
		end
		if target ~= nil then
						if GetDistance(target) < 300 then
		CastHotkey('AUTO 100,0 ATTACK:WEAKENEMY')
		end
		end

		SpellXYZ(E,ERDY,myHero,target,300,myHero.x,myHero.z)
		SpellXYZ(W,WRDY,myHero,myHero,500,mousePos.x,mousePos.z)
		SpellXYZ(Q,QRDY,myHero,target,300,myHero.x,myHero.z)
	elseif target == nil then

                MoveToMouse()
								else
				MoveToMouse()
        end
		if target6 ~= nil then
						if GetDistance(target6) > 400 then
		SpellXYZ(R,RRDY,myHero,myHero,500,myHero.x,myHero.z)
		end
		end
		end




function autojav()
	if target4 ~= nil then
	if Cougar == false then
SpellPred(Q,QRDY,myHero,target4,1500,1,14,1)
	end
end
end

function autoheal()
if myHero.health < myHero.maxHealth*(60 / 100) and Cougar == false then
SpellTarget(E,ERDY,myHero,myHero,900)
end
end


function ESCAPE()
if myHero~= nil then
if Cougar == false then
SpellXYZ(R,RRDY,myHero,myHero,500,myHero.x,myHero.z)
end
SpellXYZ(W,WRDY,myHero,myHero,900,mousePos.x,mousePos.z)
MoveToMouse()
end
end


function ignite()
CastHotkey("AUTO 100,INF SPELLF:WEAKENEMY IGNITEKILL RANGE=550 TRUE CD")
end

function Harass()	
	if target ~= nil then
	if Cougar == false then
SpellPred(W,WRDY,myHero,target,900,1,20,0)
	end
end
end

function PushFarm()
	if minion ~= nil then
autoFarm()	
end
end

	
function autoFarm()
	if minion ~= nil then
	if Cougar == true then
	local W = getDmg("W",minion,myHero)
		if minion.health < W*WRDY and GetDistance(myHero, minion) < 400 then
			CastSpellTarget('W',minion)
			end
end
end
end


function DetectCougar()
        if myHero.range < 200 then
            DrawText("Meow Form",10,40,0xFF00EE00);
            Cougar = true
        else
            DrawText("Not Meow Form",10,40,0xFF00EE00);
            Cougar = false
    end
end


function OnLoad()
    for i=1, objManager:GetMaxObjects(), 1 do
        local object = objManager:GetObject(i)
        local ward = {}
        ward = GetWardInfo(object,"OnLoad")
        if ward ~= nil then
            table.insert(wards,ward)
        end
    end
    loaded = true
end
	
function OnCreateObj(object)
	if CleanseConfig.cleanse then
		if listContains(QSS, object.charName) and (GetDistance(myHero, object)) < 100 then
			GetInventorySlot(3139)
			UseItemOnTarget(3139, myHero)
			GetInventorySlot(3140)
			UseItemOnTarget(3140, myHero)
		end
		if listContains(Cleanselist, object.charName) and CleanseConfig.cleansespell then
			CastSummonerCleanse()
		end		
	end
end

function listContains(list, particleName)
	for _, particle in pairs(list) do
		if particleName:find(particle) then return true end
	end
	return false
end

function CastSummonerCleanse()
    if Summoners.Cleanse.Key ~= nil then
        CastSpellTarget(Summoners.Cleanse.Key, myHero)
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

SetTimerCallback('Main')
SetTimerCallback('NidaleeRun')