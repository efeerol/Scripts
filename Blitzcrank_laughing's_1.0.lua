require 'Utils'
require 'spell_damage'
require 'winapi'
require 'SKeys'
local send = require 'SendInputScheduled'

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

function BlitzRun()
	
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
	target5 = GetWeakEnemy('TRUE',150)
	target6 = GetWeakEnemy('MAGIC',600)
	minion = GetLowestHealthEnemyMinion(1000)
	targetignite = GetWeakEnemy('TRUE',600)
	if BlitzConfig.combo then combo() end
	if BlitzConfig.Harass then Harass() end
	if BlitzConfig.ignite then ignite() end

end

function Main()
	if tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client" then
		if blockAndMove ~= nil then blockAndMove() end
		send.tick()
	end
end

BlitzConfig = scriptConfig("Blitz Config", "Blitzconfg")
BlitzConfig:addParam("combo", "Combo (X)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
BlitzConfig:addParam("Harass", "Harass (Z)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("Z"))

BlitzConfig:addParam("useItems", "Use Items", SCRIPT_PARAM_ONKEYTOGGLE, true, 112)
BlitzConfig:addParam("ignite", "Auto Ignite", SCRIPT_PARAM_ONKEYTOGGLE, true, 113)


BlitzConfig:permaShow("combo")
BlitzConfig:permaShow("Harass")
BlitzConfig:permaShow("useItems")
BlitzConfig:permaShow("ignite")

CleanseConfig = scriptConfig("Cleanse Config", "CleanseMenu")
CleanseConfig:addParam("cleanse", "Use QSS and Cleanse?", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("V"))
CleanseConfig:addParam("cleansespell", "Cleanse Summoner on D", SCRIPT_PARAM_ONOFF, true)

function combo()
	if target4 ~= nil then
		if BlitzConfig.useItems then 
			UseAllItems(target4) 
		end
        SpellPred(Q,QRDY,myHero,target4,900,1,19,1)
		SpellTarget(E,ERDY,myHero,target6,325)
		SpellXYZ(R,RRDY,myHero,target5,600,myHero.x,myHero.z)
		SpellXYZ(W,WRDY,myHero,target6,325,myHero.x,myHero.z)
	elseif target4 == nil and BlitzConfig.combo then
		MoveToMouse()
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

function Harass()	
	if target4 ~= nil then
		SpellPred(Q,QRDY,myHero,target4,900,1,19,1)
		SpellXYZ(E,ERDY,myHero,target6,325,myHero.x,myHero.z)
		SpellXYZ(R,RRDY,myHero,target5,600,myHero.x,myHero.z)
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
	
function CreateBlockAndMoveToXYZ(x, y, z)
    print('CreateBlockAndMoveToXYZ', x, y, z)
    local move_start_time, move_dest, move_pending
    send.block_input(true,750,MakeStateMatch)
    move_start_time = os.clock()
    move_dest = {x=x, y=y, z=z}
    move_pending = true
    MoveToXYZ(move_dest.x, 0, move_dest.z)
    run_once = false
    return function()
        if move_pending then
            printtext('.')
            local waited_too_long = move_start_time + 1 < os.clock()    
            if waited_too_long or GetDistance(move_dest)<75 then
                print('\nremaining distance: '..tostring(GetDistance(move_dest)))
                move_pending = false
                send.block_input(false)
            end
        else
            printtext(' ')
        end
    end
end
 
function MakeStateMatch(changes)
    for scode,flag in pairs(changes) do    
        print(scode)
        if flag then print('went down') else print('went up') end
        local vk = winapi.map_virtual_key(scode, 3)
        local is_down = winapi.get_async_key_state(vk)
        if flag then -- went down
            if is_down then
                send.wait(60)
                send.key_down(scode)
                send.wait(60)
            else
                -- up before, up after, down during, we don't care
            end            
        else -- went up
            if is_down then
                -- down before, down after, up during, we don't care
            else
                send.wait(60)
                send.key_up(scode)
                send.wait(60)
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

SetTimerCallback('Main')
SetTimerCallback('BlitzRun')