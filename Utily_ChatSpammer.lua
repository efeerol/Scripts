require 'utils'
require 'skeys'
local send = require 'SendInputScheduled' -- v09+
local message=""
local delay=50

local _registry = {}
local Version=1.4
local lastSpam=0

SpamConfig = scriptConfig("Spam", "Spam Config")
SpamConfig:addParam("sh", "Spam Hotkey", SCRIPT_PARAM_ONKEYTOGGLE, false, 35)
SpamConfig:addParam("st", "Spam Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, 36) --Home
SpamConfig:addParam('delay', "Spam Delay", SCRIPT_PARAM_NUMERICUPDOWN, 50, 187,50,3000,50)
SpamConfig:addParam("mess", "Spam Message", SCRIPT_PARAM_DOMAINUPDOWN, 1, 189, {"Lag","Best","Bee"})

function spamRun()

	delay=SpamConfig.delay
	if SpamConfig.st then spam()
	elseif SpamConfig.sh then spam() 
	elseif IsChatOpen()==1 and lastSpam>os.clock() then closechat() end
	
	send.tick()
end

function spam()
	if IsChatOpen()==0 then
		openchat()
		lastSpam=os.clock()+1.5
	end
	---------("Leave "/all " in spam string to send to all chat
	---------("12345678901234567890123456789012345678901234567
	---------("   Max Length for string below Is About Here \/
	if SpamConfig.mess==1 then
		send_spam("/all laglaglag")
	elseif SpamConfig.mess==2 then
		send_spam("/all I'm the best")
	elseif SpamConfig.mess==3 then
		send_spam("/all I HATE YOU BEE!")
	end
	closechat()
end

function openchat()
    --print('opening_chat')
    send.key_press(0x1c)
    send.wait(delay) -- needed, 100 
end
	
	
function closechat()
    --print('closing_chat')
    send.key_press(0x1c)
    send.wait(delay) -- needed, 100 
end


function send_spam(s)
    --print('sending_spam')
    send.text(s)
    send.wait(delay+delay) -- needed, not 100, 200
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
        -- the first t and args are stored in registry        
        data = {count=0, last=0, complete=false, t=t, args=args}
        _registry[key] = data
    end
        
    --assert(data~=nil, 'data==nil')
    --assert(data.count~=nil, 'data.count==nil')
    --assert(now~=nil, 'now==nil')
    --assert(data.t~=nil, 'data.t==nil')
    --assert(data.t.start~=nil, 'data.t.start==nil')
    --assert(data.last~=nil, 'data.last==nil')
    -- run
    local countCheck = (t.count==nil or data.count < t.count)
    local startCheck = (data.t.start==nil or now >= data.t.start)
    local intervalCheck = (t.interval==nil or now-data.last >= t.interval)
    --print('', 'countCheck', tostring(countCheck))
    --print('', 'startCheck', tostring(startCheck))
    --print('', 'intervalCheck', tostring(intervalCheck))
    --print('')
    if not data.complete and countCheck and startCheck and intervalCheck then                
        if t.count ~= nil then -- only increment count if count matters
            data.count = data.count + 1
        end
        data.last = now        
        
        if t._while==nil and t._until==nil then
            return fn(...)
        else
            -- while/until handling
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

SetTimerCallback('spamRun')