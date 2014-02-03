require 'Utils'
require 'winapi'
require 'SKeys'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local version = '1.1'
local _registry = {}

function Main()
	if IsChatOpen() == 0 and tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client" then
		delayed_MainPick()
		delayed_BluePick()
		delayed_RedPick()
		delayed_GoldPick()
	end
end

function MainPick()
	if (TFConfig.blue or TFConfig.red or TFConfig.gold) and myHero.SpellTimeW > 1.0 and myHero.SpellNameW == "PickACard" then CastSpellXYZ('W',myHero.x,0,myHero.z) end
end

function BluePick()
	if TFConfig.blue and myHero.SpellNameW == "bluecardlock" then CastSpellXYZ('W',myHero.x,0,myHero.z) end
end

function RedPick()
	if TFConfig.red and myHero.SpellNameW == "redcardlock" then CastSpellXYZ('W',myHero.x,0,myHero.z) end
end

function GoldPick()
	if TFConfig.gold and myHero.SpellNameW == "goldcardlock" then CastSpellXYZ('W',myHero.x,0,myHero.z) end
end

function delayed_MainPick()
	run_every(0.1,MainPick)
end

function delayed_BluePick()
	run_every(0.1,BluePick)
end

function delayed_RedPick()
	run_every(0.1,RedPick)
end

function delayed_GoldPick()
	run_every(0.1,GoldPick)
end
	
	TFConfig, menu = uiconfig.add_menu('TF Config', 200)
	menu.keydown('blue', 'Blue Card', Keys.X)
	menu.keydown('red', 'Red Card', Keys.Y)
	menu.keydown('gold', 'Gold Card', Keys.Z)
	menu.permashow('blue')
	menu.permashow('red')
	menu.permashow('gold')

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
print("\nTF CardPicker (by Val) v"..version.."\n")