-- based on buttonsmite by yonderboi
-- default toggle key is N

--local ui = require 'simpleui'

local default_button_value = true -- default state of buttons
local smite_range = 625
local track = {} -- { key:{object=<unit>, button_value=<bool>, started=<time> }, ... }
local smite_name = 'SummonerSmite'
local smitedamage = {390, 410, 430, 450, 480, 510, 540, 570, 600, 640, 680, 720, 760, 800, 850, 900, 950, 1000}

local prefixes = { 'Worm', 'Dragon', 'AncientGolem', 'LizardElder' }

require 'winapi'

function is_alive(o)
    return o.dead == 0 and o.health > 0
end

function is_valid(o)
    return o.valid == 1
end

--UI
local uiconfig = require 'uiconfig'
CfgSettings, menu = uiconfig.add_menu('AutoSmite', 200)
menu.keytoggle('AutoSmite', 'Auto-Smite', Keys.N, true)
menu.permashow("AutoSmite")


function smite(o)
    --print('buttonsmiting @', os.clock())
    local key
    if myHero.SummonerD == smite_name then
        key = 'D'
    elseif myHero.SummonerF == smite_name then
        key = 'F'
    end
    if key ~= nil then
        CastSpellTarget(key, o)
    end
end

function smite_damage()
    return smitedamage[myHero.selflevel]
end

function smite_kills(o)
    return o.health <= smite_damage()
end

local key
if myHero.SummonerD == 'SummonerSmite' then
        key = "D"
    elseif myHero.SummonerF == 'SummonerSmite' then
        key = "F"
    end

function smite_available()      
    return IsSpellReady(key)
end

--================================
--Smite %
-- iger's: /forum/Upload/showthread.php?tid=1739
function screen_position(unit)
    if unit == nil then return nil end
    local x, y, z = unit.x, unit.y, unit.z
    if x ~= nil and y ~= nil and z ~= nil then
        xScreen = GetScreenX()/2+(x-GetWorldX())
        yScreen = GetScreenY()/2-(z-GetWorldY())-y
        --adjust by percent--
        xScreen = xScreen-((xScreen-GetScreenX()/2)/100*30)
        yScreen = yScreen-((yScreen-GetScreenY()/2)/100*30)
        return xScreen, yScreen
    end
end

local win = winapi.find_window(nil,'League of Legends (TM) Client')
local dc = win:get_dc()
--w:release_dc(dc)

local _text_dim_lookup = {}
function text_dim(s, default_x, default_y)    
    if dc == nil or dc == 0 then
        return default_x, default_y
    else
        local cache = _text_dim_lookup[s]
        if cache == nil then
            local x, y = winapi.get_text_extent_point(dc, s, #s)
            _text_dim_lookup[s] = {x,y}
            return x, y
        else
            return cache[1], cache[2]
        end
    end
end

function draw_info(o)
    
    for key,t in pairs(track) do
        local o = t.object        
        local x, y = screen_position(o)
        if x~=nil and y~= nil then
            y = y + 80 --draw under the monster
            if is_valid(o) and is_alive(o) then
               
                local lime = 0xFF00FF00  
                local color2 = 0xFF00FF00            

                local currHp = calc_curr(o)
                local smiteHp = calc_smiteHp(o)
                if currHp > smiteHp then
                    color2 = 0xFFFFD700 --GOLD
                else
                    color2 = 0xFFFF0000 --RED
                end
                currHp = math.floor(currHp + 0.5)
                smiteHp = math.floor(smiteHp + 0.5)

                DrawText(currHp .. "%",x + 25,y,lime)
                DrawText(smiteHp .. "%",x - 25,y,color2)               
               
            end
        end
    end
end

function calc_curr(o)
return o.health / o.maxHealth * 100
end

function calc_smiteHp(o)
return smite_damage() / o.maxHealth * 100
end

--================================
function in_smite_range(o)
    local distance = GetDistance(o)
    return distance <= smite_range   
end

function get_key(o)
    return tostring(o.id)..','..o.name..','..o.charName
end

function start_tracking(o)
    local key = get_key(o)
    track[key] = {object=o, button_value=default_button_value, started=os.clock()}
end

function starts_with(s, sub)
    return s:sub(1,string.len(sub))==sub
end

function is_boss(o)
    if o ~= nil and is_valid(o) and o.name ~= nil and o.charName ~= nil then
        for i=1,#prefixes do
            local prefix = prefixes[i]
            -- name is the short thing, charName is name+numbers
            if starts_with(o.name, prefix) then
                return true
            end
        end
    end
    return false
end

function buttonsmite_tick()
    for key,t in pairs(track) do
        local o = t.object
        local still_valid = false
        if is_boss(o) and is_alive(o) then
            --assert(type(o.valid)=='number', 'expecting o.valid to be a number')
            --assert(type(o.dead)=='number', 'expecting o.dead to be a number')
            local current_key = get_key(o)
            if key == current_key then
                still_valid = true
            end
        end
        if still_valid then
            if smite_available() and CfgSettings.AutoSmite
            and smite_kills(o) and in_smite_range(o) then
                smite(o)
            end
        else
            track[key] = nil
        end
    end 
     assert(draw_info~=nil, 'draw_info is nil')
    draw_info(o)
end

function OnCreateObj(o)
    if is_boss(o) then
        start_tracking(o)
    end
end

for i=1,objManager:GetMaxObjects() do OnCreateObj(objManager:GetObject(i)) end

SetTimerCallback('buttonsmite_tick')