-- buttonsmite
--
-- this script autosmites, but gives you a checkbutton under bosses to disable/enable autosmiting it
-- so you can do other things
--
-- v01 - 5/28/2013 5:33:02 PM - initial release, requires simpleui files, developed on utils 2+
-- v02 - 5/31/2013 2:20:50 PM - mostly meaningless changes, tested with latest simpleui
-- v03 - 6/5/2013 7:41:58 PM - something might not have been working, science!
-- v04 - 6/24/2013 5:33:49 PM - changes, add close option to buttons after 1 minute
-- v05 - 6/28/2013 10:56:33 PM - center button text using high technology
-- v06 - 2/1/2014 11:40:00 AM - fixed smite damage
--
-- todo: dont draw prev button under current?
--
local ui = require 'simpleui'
local draw = require 'simpleui_drawing'
local Rectangle = draw.Rectangle
local get_centered_offsets = draw.get_centered_offsets

local default_button_value = true -- default state of buttons
local smite_range = 625 -- increase this?
local track = {} -- { key:{object=<unit>, button_value=<bool>, started=<time> }, ... }
local smite_name = 'SummonerSmite'
local smitedamage = {390, 410, 430, 450, 480, 510, 540, 570, 600, 640, 680, 720, 760, 800, 850, 900, 950, 1000}

local prefixes = { 'Worm', 'Dragon', 'AncientGolem', 'LizardElder' }

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

function is_alive(o)
    return o.dead == 0 and o.health > 0
end

function is_valid(o)
    return o.valid == 1
end

require 'winapi'
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

function do_ui()
    
    for key,t in pairs(track) do
        local o = t.object
        local changed
        local x, y = screen_position(o)
        if x~=nil and y~= nil then
            y = y + 80 -- draw under, just so it's not in the way too much
            if is_valid(o) and is_alive(o) then
                local txt = 'AutoSmite'
                local tx, ty
                local pad = 16
                local tx, ty = text_dim(txt, 80, 40)
                local rect1 = Rectangle(x, y, tx+pad, ty+pad)
                local ox, oy = get_centered_offsets(rect1, Rectangle(nil, nil, tx, ty))
                changed, t.button_value = ui.checkbutton('buttonsmite checkbutton:'..key, txt, rect1, t.button_value, ox, oy)
                -- cannot detect death in fog of war, remains valid and alive, even though it's gone
                -- show close button 1 minutes after started
                if t.started+1*60 < os.clock() then
                    txt = 'X'
                    tx, ty = text_dim(txt, 20, 40)
                    local rect2 = Rectangle(x+rect1.Width, y, tx+pad, ty+pad)
                    local ox, oy = get_centered_offsets(rect2, Rectangle(nil, nil, tx, ty))                    
                    if ui.button('buttonsmite closebutton:'..key, txt, rect2, ox, oy) then
                        track[key] = nil
                    end
                end
            end
        end
    end
end

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

function smite_available()
    return true -- todo: use smite cooldown, doesnt matter though
end

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
            if smite_available() and t.button_value
            and smite_kills(o) and in_smite_range(o) then
                smite(o)
            end
        else
            track[key] = nil
        end
    end
    assert(do_ui~=nil, 'do_ui is nil')
    ui.tick(do_ui)
end

function OnCreateObj(o)
    if is_boss(o) then
        start_tracking(o)
    end
end

for i=1,objManager:GetMaxObjects() do OnCreateObj(objManager:GetObject(i)) end

SetTimerCallback('buttonsmite_tick')