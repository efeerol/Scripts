-- throttling/scheduling function wrappers
-- v01 - 4/26/2013 3:08:51 PM - tested in lua 5.1 and 5.2
-- v02 - 4/26/2013 6:01:44 PM - reset functionality, while/until, wrote example script
-- v03 - 4/27/2013 12:11:32 PM - rename reset functions from reset_* to *_reset

-- todo: allow optional string keys
    
local _registry = {}

function run_once(fn, ...)
    return run_many(1, fn, ...)
end

function run_many(count, fn, ...)
    return internal_run({fn=fn, count=count}, ...)
end

function run_many_reset(count, fn, ...)
    return internal_run({fn=fn, count=count, reset=true}, ...)
end

function run_every(interval, fn, ...)
    return internal_run({fn=fn, interval=interval}, ...)
end

function run_every_reset(interval, fn, ...)
    return internal_run({fn=fn, interval=interval, reset=true}, ...)
end

function run_later(seconds, fn, ...)
    return internal_run({fn=fn, count=1, start=os.clock()+seconds}, ...)
end

function run_later_reset(seconds, fn, ...)
    return internal_run({fn=fn, count=1, start=os.clock()+seconds, reset=true}, ...)
end

function run_at(clock, fn, ...)
    return internal_run({fn=fn, count=1, start=clock}, ...)
end

function run_at_reset(clock, fn, ...)
    return internal_run({fn=fn, count=1, start=clock, reset=true}, ...)
end

-- run fn until it returns true
function run_until(fn, ...)
    return internal_run({fn=fn, _until=fn})
end

-- run fn as long as it returns true
function run_while(fn, ...)
    return internal_run({fn=fn, _while=fn})
end

-- run fn until untilfn returns true
function run_until2(untilfn, fn, ...)
    return internal_run({fn=fn, _until=untilfn})
end

-- run fn while whilefn returns true
function run_while2(whilefn, fn, ...)
    return internal_run({fn=fn, _while=whilefn})
end

-- resets for while/until
function run_until_reset(fn, ...)
    return internal_run({fn=fn, _until=fn, reset=true})
end

function run_while_reset(fn, ...)
    return internal_run({fn=fn, _while=fn, reset=true})
end

function run_until2_reset(untilfn, fn, ...)
    return internal_run({fn=fn, _until=untilfn, reset=true})
end

function run_while2_reset(whilefn, fn, ...)
    return internal_run({fn=fn, _while=whilefn, reset=true})
end

-- technically optional, but recommended
-- run checks at different places in code, make code more clear
-- key is key or fn
-- if args are passed, then they are used in latest call, else original args are used
function run_check(key, ...)        
    local data = _registry[key]
    if data==nil then
        -- print('attempted run_check with invalid key : '..tostring(key))
        return
    end
    local n = select('#', ...)
    local result
    if n>0 then
        result = internal_run(data.t, ...)
    else
        result = internal_run(data.t, unpack(data.args))
    end
    -- automatic cleanup for count~=nil items (only when using run_check)
    -- and for data.complete items
    if data.count >= data.t.count or data.complete then
        print('autocleanup: '..tostring(key))
        unregister(key)
    end    
    return result
end

function run_check_all(...)
    local n = select('#', ...)
    for k,v in pairs(_registry) do
        data = _registry[k]
        if n>0 then
            internal_run(data.t, ...)
        else
            internal_run(data.t, unpack(data.args))
        end         
    end
end

-- mostly for internal use
function unregister(key)    
    _registry[key] = nil
    print('key unregistered: '..tostring(key))
end

-- fn = the function to run (required)
-- count = how many times to run, nil for infinite (optional, default:nil)
-- start = the time to start runs (optional, default:nil)
-- interval = the seconds between runs (optional, default:nil)
-- key = key to use instead of fn (optional, default:fn)
-- reset = boolean, overwrites existing init data, as if it were the first call (optional, default:nil)
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

--------------------------------------------------------------------------------
-- TESTS -----------------------------------------------------------------------
--------------------------------------------------------------------------------

local test=false
if test then
    
    local function brutesleep(n)
      local t0 = os.clock()
      while os.clock() - t0 <= n do end
    end
    
    local all_tests = false
    
    local start
    
    if all_tests then
        local f1 = function(...) print(...) end
        for i=0,10 do        
            run_once(f1, "running once")
            --brutesleep(0.2)
        end

        local f2 = function(...) print(...) end
        for i=0,10 do        
            run_many(2, f2, "running two times", i)
            --brutesleep(0.2)
        end
    
        local f3 = function(...) print(...) end
        local start = os.clock()
        while os.clock() - start < 4 do
            --brutesleep(0.2)
            run_every(1, f3, "running every second", os.clock())
        end
    
        local f4 = function(...) print(...) end
        local f5 = function(...) print(...) end
        start = os.clock()
        print('function will run in 3 seconds...')
        while os.clock() - start < 7 do
            --brutesleep(0.2)
            run_later(3, f4, "run once after 3 seconds")
            run_every(1, f5, _registry[f4].t.start, os.clock())
        end
        
        local f4b = function(...) print(...) end
        local f5b = function(...) print(...) end
        start = os.clock()
        local at = start+3
        print('function will run @ '..tostring(at))
        while os.clock() - start < 9 do
            --brutesleep(0.2)
            run_at(at, f4b, "run @ completed @ "..tostring(os.clock()))
            run_every(1, f5b, _registry[f4b].t.start, os.clock())
        end

    end
       
    if all_tests then     
        local f6 = function(...) print(...) end
        start = os.clock()
        run_later(1.5, f6, "run this in 1.5 seconds, but this arg isn't seen")
        local i = 0
        print('function will run when we check it late..')
        while os.clock() - start <= 3 do
            brutesleep(1)
            i = i + 1
            print(i)
        end    
        run_later(42, f6, "finally checked, latest args are used, first param is not, it's meaningless")
    end
    
    -- to make this less confusing, i introduce run_check
    if all_tests then
        local f7 = function(...) print(...) end
        start = os.clock()
        run_later(1.5, f7, "run this in 1.5 seconds, once checked, these are original args")
        local i = 0
        print('-')
        print('function will run when we check it late... using original args')
        while os.clock() - start <= 2 do
            brutesleep(1)
            i = i + 1
            print(i)
        end    
        run_check(f7)
    end
    
    -- you can also use latest args with run_check
    if all_tests then
        local f8 = function(...) print(...) end
        start = os.clock()
        run_later(1.5, f8, "this arg wont matter")
        local i = 0
        print('-')
        print('function will run when we check it late... using new args')
        while os.clock() - start <= 2 do
            brutesleep(1)
            i = i + 1
            print(i)
        end    
        run_check(f8, "these are the new args")
    end
    
    -- test that cleanup does not occur with non check calls
    local f9
    if all_tests then
        f9 = function(...) print(...) end
        start = os.clock()
        run_later(1.5, f9, "non-check cleanup check a")
        local i = 0
        print('-')
        print('function will run when we check it late...')
        while os.clock() - start <= 2 do
            brutesleep(1)
            i = i + 1
            print(i)
        end    
        run_later(1.5, f9, "non-check cleanup check b [GOOD]")
        run_later(1.5, f9, "non-check cleanup check c")
    end    
    if all_tests then
        run_later(1.5, f9, "non-check cleanup check d") -- no error
    end
    
    -- cleanup occurs on check_calls where count~=nil
    local f10
    if all_tests then
        f10 = function(...) print(...) end
        start = os.clock()
        run_later(1.5, f10, "check cleanup a")
        local i = 0
        print('-')
        print('function will run when we check it late...')
        while os.clock() - start <= 2 do
            brutesleep(1)
            i = i + 1
            print(i)
        end    
        run_later(1.5, f10, "check cleanup b [GOOD]")
        run_later(1.5, f10, "check cleanup c")
    end 
    if all_tests then   
        run_later(1.5, f10, "check cleanup d")
        assert(_registry[f10] ~= nil)
        run_check(f10, "check cleanup e")
        if (_registry[f10] == nil) then
            print('cleanup test passed')
        else
            print('cleanup test FAILED')
        end
    end
    
    -- test return values
    if all_tests then
        print('-')
        local f11 = function(msg,x,y) print(msg); return x+y end        
        print("test return values in 2 seconds")
        run_later(2, f11, 'function completed', 4, 9)
        start = os.clock()
        while os.clock() - start <= 2 do
            brutesleep(0.2)
            result = run_check(f11)
            if result ~= nil then
                print('result : '..tostring(result))
            end
        end            
    end
        
    if all_tests then
        print('- check all -')
        run_check_all()
    end
    
    if all_tests then
        print('run until function returns true...')
        local derp = 0
        function derp4(x) print(derp); derp = derp + 1; return derp == 4; end
        for i=0,10 do
            run_until(derp4, i)
        end
        print('run while function returns true...')
        function derp8(x) print(derp); derp = derp + 1; return derp < 8; end
        for i=0,10 do
            run_while(derp8, i)
        end
    end
    
    if all_tests then        
        print('run fn until fn2 returns true...')        
        local herp = 0
        function printherp4() print('*'..tostring(herp)..'*') end
        function herp4(x) herp = herp + 1; return herp == 4; end
        for i=0,10 do
            run_until2(herp4, printherp4, i)
        end
        print('run fn while fn2 returns true...')
        function printherp8() print('*'..tostring(herp)..'*') end
        function herp8(x) herp = herp + 1; return herp < 8; end
        for i=0,10 do
            run_while2(herp8, printherp8, i)
        end
    end
     
end