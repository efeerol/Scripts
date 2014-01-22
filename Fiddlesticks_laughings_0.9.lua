require 'Utils'
require 'spell_damage'
require 'winapi'
require 'SKeys'
local send = require 'SendInputScheduled'

local target
local target4
local target5
local target6
local target7
local Q,W,E,R = 'Q','W','E','R'
local minion
local targetIgnite
local drained = false
local _registry = {}

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

function FiddleRun()
        drain()
	
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
	
	if drained == true then
		DrawText("drain == true",70,170,0xFFF0FFFF)
	else 
		DrawText("drain == false",70,170,0xFFF0FFFF)
	end

	target4 = GetWeakEnemy('MAGIC',750)
	target5 = GetWeakEnemy('MAGIC',475)
	target6 = GetWeakEnemy('MAGIC',575)
	target7 = GetWeakEnemy('MAGIC',800)
	minion = GetLowestHealthEnemyMinion(1000)
	targetignite = GetWeakEnemy('TRUE',600)
	
	if FiddleConfig.combo then combo() end
	if FiddleConfig.ULTI then ULTI() end
	if FiddleConfig.Harass then Harass() end
	if FiddleConfig.EHarass then EHarass() end
	if FiddleConfig.ignite then ignite() end
    if FiddleConfig.PushFarm then PushFarm() end
end

function Main()
	if tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client" then
		if blockAndMove ~= nil then blockAndMove() end
		send.tick()
	end
end

FiddleConfig = scriptConfig("Fiddle Config", "Fiddleconfg")
FiddleConfig:addParam("combo", "Combo (X)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
FiddleConfig:addParam("ULTI", "ULTI (A)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
FiddleConfig:addParam("Harass", "Harass (Z)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("Z"))
FiddleConfig:addParam("EHarass", "E Harass (T)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("T"))
FiddleConfig:addParam("PushFarm", "Push Farm (C)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("C"))
FiddleConfig:addParam("useItems", "Use Items", SCRIPT_PARAM_ONKEYTOGGLE, true, 112)
FiddleConfig:addParam("ignite", "Auto Ignite", SCRIPT_PARAM_ONKEYTOGGLE, true, 113)

FiddleConfig:permaShow("PushFarm")
FiddleConfig:permaShow("combo")
FiddleConfig:permaShow("Harass")
FiddleConfig:permaShow("EHarass")
FiddleConfig:permaShow("useItems")
FiddleConfig:permaShow("ignite")

CleanseConfig = scriptConfig("Cleanse Config", "CleanseMenu")
CleanseConfig:addParam("cleanse", "Use QSS and Cleanse?", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("V"))
CleanseConfig:addParam("cleansespell", "Cleanse Summoner on D", SCRIPT_PARAM_ONOFF, true)

function combo()
	if target4~=nil then
		if FiddleConfig.useItems then 
			UseAllItems(target4) 
		end
		if drained == false then
			SpellTarget(E,ERDY,myHero,target4,750)
			SpellTarget(Q,QRDY,myHero,target6,575)
			delayed_Wspell()
		end
	end
	if target5 == nil and FiddleConfig.combo then
		if not drained then
			MoveToMouse()
		end
	end
end

function Wspell()
	SpellTarget(W,WRDY,myHero,target5,475)
end

function delayed_Wspell()
	run_every(0.2,Wspell)
end

function ULTI()
    if target7 ~=nil then
	if drained == false then
	SpellXYZ(R,RRDY,myHero,target7,800,target7.x,target7.z)
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

function Harass()	
	if target5 ~= nil or target6 ~= nil or target4 then
	if drained == false then
		SpellTarget(E,ERDY,myHero,target4,750)
        SpellTarget(Q,QRDY,myHero,target6,575)
		SpellTarget(W,WRDY,myHero,target5,475)
	end
end
end

function EHarass()	
	if target4 ~= nil then
	if drained == false then
		SpellTarget(E,ERDY,myHero,target4,750)
	end
end
end

function PushFarm()
	if minion ~= nil then
	if drained == false then
		autoFarm()	
	end
end
end

function autoFarm()
	if minion ~= nil then
		local E = getDmg("E",minion,myHero)
		if minion.health < E*ERDY and GetDistance(myHero, minion) < 750 then
			CastSpellTarget('E', minion)
	end
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
	
function drain()

    for i = 1, objManager:GetMaxNewObjects(), 1 do
        local object = objManager:GetNewObject(i)
        if object.charName~=nil and GetDistance(myHero,object) < 100 and object.charName=="Fearmonger_cas.troy" then
            drained=true
        end
		if object.charName~=nil then
			if (string.find(object.charName, "LOC_Stun") or string.find(object.charName, "LOC_Suppress") or string.find(object.charName, "LOC_Taunt") or string.find(object.charName, "CurseBandages") or string.find(object.charName, "Vi_R_land") or string.find(object.charName, "leBlanc_shackle_tar_blood") or string.find(object.charName, "RengarEMax_tar") or string.find(object.charName, "tempkarma_spiritbindroot_tar")) and GetDistance(object,myHero) < 100 then
				drained=false
			end
		end
    end

    for i = 1, objManager:GetMaxDelObjects(), 1 do
        local object = {objManager:GetDelObject(i)}
        local ret={}
        ret.index=object[1]
        ret.name=object[2]
        ret.charName=object[3]
        ret.x=object[4]
        ret.y=object[5]
        ret.z=object[6]
        if ret.charName=="Fearmonger_cas.troy" or ret.charName=="Drain.troy" or ret.charName=="AnotherParticle" or ret.charName=="AnotherParticle" then
            drained=false
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

function run_every(interval, fn, ...)
    return internal_run({fn=fn, interval=interval}, ...)
end

function internal_run(t, ...)    
    local fn = t.fn
    local key = t.key or fn
    local now = os.clock()
    local data = _registry[key]  
    if data == nil or t.reset then
        local args = {}
        local n = select('#', ...)
        local v
        for i=1,n do
            v = select(i, ...)
            table.insert(args, v)
        end        
        data = {count=0, last=0, complete=false, t=t, args=args}
        _registry[key] = data
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

SetTimerCallback('Main')
SetTimerCallback('FiddleRun')