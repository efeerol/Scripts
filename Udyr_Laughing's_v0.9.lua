require 'Utils'
require 'spell_damage'
require 'winapi'
require 'SKeys'
local send = require 'SendInputScheduled'

local targetaa
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

function UdyrRun()
	
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
	
    
	AArange = (myHero.range+(GetDistance(GetMinBBox(myHero), GetMaxBBox(myHero))/2))
	targetaa = GetWeakEnemy('PHYS',AArange)
	
	target = GetWeakEnemy('PHYS',600)
	target4 = GetWeakEnemy('MAGIC',500)
	target5 = GetWeakEnemy('TRUE',150)
	target6 = GetWeakEnemy('MAGIC',600)
	minion = GetLowestHealthEnemyMinion(1000)
	targetignite = GetWeakEnemy('TRUE',600)
	if UdyrConfig.combo then combo() end
	if UdyrConfig.combo2 then combo2() end
	if UdyrConfig.combo3 then combo3() end
	if UdyrConfig.combo4 then combo4() end
	if UdyrConfig.Harass then Harass() end
	if UdyrConfig.ignite then ignite() end
	

end

function Main()
	if tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client" then
		if blockAndMove ~= nil then blockAndMove() end
		send.tick()
	end
end

UdyrConfig = scriptConfig("Udyr Config", "Udyrconfg")
UdyrConfig:addParam("combo", "Phoenix (X)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
UdyrConfig:addParam("combo2", "Tiger (Z)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
UdyrConfig:addParam("combo3", "Turtle (C)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
UdyrConfig:addParam("combo4", "Phoenger (K)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))
UdyrConfig:addParam("Harass", "Chase (V)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("V"))
UdyrConfig:addParam("useItems", "Use Items", SCRIPT_PARAM_ONKEYTOGGLE, true, 112)
UdyrConfig:addParam("ignite", "Auto Ignite", SCRIPT_PARAM_ONKEYTOGGLE, true, 113)


UdyrConfig:permaShow("combo")
UdyrConfig:permaShow("combo2")
UdyrConfig:permaShow("combo3")
UdyrConfig:permaShow("combo4")
UdyrConfig:permaShow("Harass")
UdyrConfig:permaShow("useItems")
UdyrConfig:permaShow("ignite")


function combo()
	if targetaa ~= nil then
		if UdyrConfig.useItems then 
			UseAllItems(targetaa) 
		end
						if GetDistance(target) < 450 then
		CastHotkey('AUTO 100,0 ATTACK:WEAKENEMY PATROLSTRAFE=300')
		end
		if RRDY == 1 then
		SpellXYZ(R,RRDY,myHero,targetaa,300,myHero.x,myHero.z)
		end
		if WRDY == 1 and RRDY == 0 then
		SpellXYZ(W,WRDY,myHero,targetaa,300,myHero.x,myHero.z)
		end
		if ERDY == 1 and RRDY == 0 and WRDY == 0 then
		SpellXYZ(E,ERDY,myHero,targetaa,600,myHero.x,myHero.z)
		end
		if QRDY == 1 and RRDY == 0 and WRDY == 0 and ERDY == 0 then
		SpellXYZ(Q,QRDY,myHero,targetaa,300,myHero.x,myHero.z)
		end
	elseif targetaa == nil and UdyrConfig.combo then
		MoveToMouse()
	end
end

function combo2()
	if targetaa ~= nil then
		if UdyrConfig.useItems then 
			UseAllItems(targetaa) 
		end
						if GetDistance(target) < 450 then
		CastHotkey('AUTO 100,0 ATTACK:WEAKENEMY PATROLSTRAFE=300')
		end
		if QRDY == 1 then
		SpellXYZ(Q,QRDY,myHero,targetaa,300,myHero.x,myHero.z)
		end
		if WRDY == 1 and QRDY == 0 then
		SpellXYZ(W,WRDY,myHero,targetaa,300,myHero.x,myHero.z)
		end
		if ERDY == 1 and QRDY == 0 and WRDY == 0 then
		SpellXYZ(E,ERDY,myHero,targetaa,700,myHero.x,myHero.z)
		end
		if RRDY == 1 and QRDY == 0 and WRDY == 0 and ERDY == 0 then
		SpellXYZ(R,RRDY,myHero,targetaa,300,myHero.x,myHero.z)
		end
	elseif targetaa == nil and UdyrConfig.combo2 then
		MoveToMouse()
	end
end

function combo3()
	if targetaa ~= nil then
		if UdyrConfig.useItems then 
			UseAllItems(targetaa) 
		end
								if GetDistance(target) < 450 then
		CastHotkey('AUTO 100,0 ATTACK:WEAKENEMY PATROLSTRAFE=300')
		end
		if WRDY == 1 then
		SpellXYZ(W,WRDY,myHero,targetaa,300,myHero.x,myHero.z)
		end
		if QRDY == 1 and WRDY == 0 then
		SpellXYZ(Q,QRDY,myHero,targetaa,300,myHero.x,myHero.z)
		end
		if ERDY == 1 and WRDY == 0 and QRDY == 0 then
		SpellXYZ(E,ERDY,myHero,targetaa,700,myHero.x,myHero.z)
		end
		if RRDY == 1 and QRDY == 0 and WRDY == 0 and ERDY == 0 then
		SpellXYZ(R,RRDY,myHero,targetaa,300,myHero.x,myHero.z)
		end
	elseif targetaa == nil and UdyrConfig.combo3 then
		MoveToMouse()
	end
end

function combo4()
	if targetaa ~= nil then
		if UdyrConfig.useItems then 
			UseAllItems(targetaa) 
		end
								if GetDistance(target) < 450 then
		CastHotkey('AUTO 100,0 ATTACK:WEAKENEMY PATROLSTRAFE=300')
		end
		if RRDY == 1 then
		SpellXYZ(R,RRDY,myHero,targetaa,300,myHero.x,myHero.z)
		end
		if QRDY == 1 and RRDY == 0 then
		SpellXYZ(Q,QRDY,myHero,targetaa,300,myHero.x,myHero.z)
		end
		if WRDY == 1 and RRDY == 0 and QRDY == 0 then
		SpellXYZ(W,WRDY,myHero,targetaa,300,myHero.x,myHero.z)
		end
		if ERDY == 1 and QRDY == 0 and WRDY == 0 and RRDY == 0 then
		SpellXYZ(E,ERDY,myHero,targetaa,300,myHero.x,myHero.z)
		end
	elseif targetaa == nil and UdyrConfig.combo4 then
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
	if target ~= nil then
SpellXYZ(E,ERDY,myHero,target,600,myHero.x,myHero.z)
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
SetTimerCallback('UdyrRun')