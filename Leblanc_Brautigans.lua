--[[----------------~~~~~~~~~~~~~++++++++++Brautigan's Leblanc++++++++++~~~~~~~~~~~~~~-------------------------
    Ctrl+H: Set a home for your clone
    Numpad - : Toggle Cooldown Circles
    Z: Combo with distortion return
    X: Combo without distortion return

    Notes:  CloneMove: At the beginning of a game or anytime afterwards, set a home for your clone by hovering
            mouse over minimap and pressing CTRL+H.  Afterward when your clone spawns, it will automatically
            run towards that point.  Point is marked on the screen with a blue "H"

            Cooldown Circle tracks Q cooldown and rang.  Inner ring is normal range, outer ring is
            potential range after using W.  Changes color depending on whether ult is up.

--------------------------------------------------------------------------------------------------------------]]--

require "winapi"
require "sendinput"
require 'utils'
local send = require 'sendinputscheduled'
local Return=0
local returnready=0
local lastcastQ=0
local wTime=0
local clone = {}
local clones = {}
local CloneSay = math.random(11)
local CloneHome = 0
local cloneX = GetCursorX()
local cloneY = GetCursorY()
local clonecheck = 0

Brautigans_LeblancConfig = scriptConfig("       ~~~+++Brautigan's Leblanc+++~~~", 'Brautigans_LeblancConfig' )
Brautigans_LeblancConfig:addParam('DoReturn', '                            Get back:', SCRIPT_PARAM_ONKEYDOWN, false, 90)
Brautigans_LeblancConfig:addParam('NoReturn', '                        Stay with it:', SCRIPT_PARAM_ONKEYDOWN, false, 88)
Brautigans_LeblancConfig:addParam('circles', '    CirclesOn/Off (default "numpad-"):', SCRIPT_PARAM_ONKEYTOGGLE, true, 109)


function LeblancRun()
    CloneSearch()
    target = GetWeakEnemy('MAGIC',1300)
    if CloneHome == 0 then
        cloneX = GetCursorX()
        cloneY = GetCursorY()
    end
    if Brautigans_LeblancConfig.circles then
        DoCircles()
    end
    if IsKeyDown(17)==1 and IsKeyDown(72)==1 then
        cloneX = GetCursorX()
        cloneY = GetCursorY()
        CloneHome=1
        DrawText("Choose a new home anytime!", GetScreenX()/2-125, GetScreenY()/2-175, Color.Purple)
    end
    if myHero.SpellTimeW < 0 then
        returnready=0
    end
    if Brautigans_LeblancConfig.DoReturn then
        Return = 1
        Combo()
    elseif Brautigans_LeblancConfig.NoReturn then
        Return = 0
        Combo()
    end
end


function Combo()
    if ValidTarget(target) then
        if  CanCastSpell("R") then
            UseTargetItems(target)
        end
        if returnready==1 then
            Q()
            R()
            E()
            W()
        else
            Q()
            R()
            W()
            E()
        end
    AutoIgnite()
    MoveToMouse()
    end
end

function Q()
    if  CanCastSpell("Q") and ValidTarget(target) and GetDistance(target) < 700 then
        CastSpellTarget("Q", target)
        CloneSay = math.random(11)
        if CanCastSpell("E") or CanCastSpell("R") then
            wTime = GetClock()+250
        end
    end
end

function W()
    if Return==0 then
        if CanCastSpell("W") and returnready == 0 and ValidTarget(target) then
            if GetDistance(target) < 700 then
                CastSpellTarget("W", target)
            elseif GetDistance(target) < 1200 and (CanCastSpell("E") or CanCastSpell("Q") or CanCastSpell("R"))then
                CastSpellTarget("W", target)
            end
        end
    elseif Return==1 and (GetClock()-wTime>0) then
        if CanCastSpell("W") and ValidTarget(target) then
            if GetDistance(target) < 700 then
                CastSpellTarget("W", target)
            elseif GetDistance(target) < 1300 and (CanCastSpell("E") or CanCastSpell("Q") or CanCastSpell("R"))then
                CastSpellTarget("W", target)
            end
        elseif CanCastSpell("W") and returnready == 1 and not ValidTarget(target) then
            CastSpellTarget("W", myHero)
        end
    end
end

function E()
    if  CanCastSpell("E") and ValidTarget(target) and GetDistance(target) < 850 and
    CreepBlock(target.x, target.y, target.z, 200) == 0 then
        wTime = GetClock()+200*((850-GetDistance(target))/850)
        CastSpellXYZ("E",GetFireahead(target,1,19))
        if CanCastSpell("Q") then
            wTime = wTime + 250
        end
    end
end

function R()
    if  CanCastSpell("R") and lastcastQ==1 and ValidTarget(target) and GetDistance(target) < 700  then
        CastSpellTarget("R", target)
        wTime = GetClock()+250
    end
end

function AutoIgnite()
    local IgniteDMG = 50+(20*myHero.selflevel)
    if myHero.SummonerD == "SummonerDot" and ValidTarget(target) < IgniteDMG then
        if IsSpellReady("D") == 1 then
            CastSpellTarget("D",target)
        end
    elseif myHero.SummonerF == "SummonerDot" and ValidTarget(target) and target.health < IgniteDMG then
        if IsSpellReady("F") == 1 then
            CastSpellTarget("F",target)
        end
    end
end

function CloneSearch()
    if GetClock()-clonecheck > 0 then
        for i = 1, objManager:GetMaxNewObjects(), 1 do
            local obj = objManager:GetNewObject(i)
            if obj ~= nil then
                if obj.charName ~= nil then
                    if (string.find(obj.charName,"LeblancImage")) ~= nil then
                        myX=GetCursorX()
                        myY=GetCursorY()
                        send.block_input(true)
                        send.wait (60)
                        send.mouse_move(cloneX, cloneY)
                        send.wait (60)
                        send.key_down(0x38)
                        send.wait (60)
                        send.mouse_up('right')
                        send.wait (60)
                        send.mouse_down('right')
                        send.wait (60)
                        send.mouse_up('right')
                        send.wait (60)
                        send.key_up(0x38)
                        send.wait (60)
                        send.mouse_move(myX, myY)
                        send.wait (60)
                        send.block_input(false)
                        clonecheck = GetClock()+60000
                    end
                end
            end
        end
    end
    send.tick()
end

function OnProcessSpell(myHero, spell)
    if spell.name=="LeblancChaosOrb" then
        lastcastQ=1
    elseif spell.name=="LeblancSoulShackle" then
        lastcastQ=0
    elseif spell.name=="LeblancSlide" then
        wTime=GetClock()
        lastcastQ=0
        returnready=1
    elseif spell.name=="leblancslidereturn" then
        returnready=0
    end
end

function OnCreateObj()
    if objManager:GetNewObject(1) then
        for i=1, objManager:GetMaxNewObjects(), 1 do
            local object = objManager:GetNewObject(i)
            if object ~= nil then
                if object ~= hero then
                    if object.name == "Leblanc" then
                        clone = {object = object,tick = GetClock(),duration = 8000,}
                        table.insert(clones, clone)
                    end
                end
            end
        end
    end
end

CloneText = {"LB Clone Home!", "Have fun, Cya!", "LOL, they're attacking me!", "Oooh, look!  A rose!",
            "Hello. Goodbye.", "You actually enjoy this?", "WTF??", "Do I look like a punching bag?",
            "Fuck this.", "uh.. I'll be going now", "Confucious say: GTFO", "Bye, bitch..."}

function OnDraw()
    DrawText("H", cloneX, cloneY, Color.Cyan)
    if CloneHome==0 then
        DrawText("Make a Home for your Clone! \n \n With Mouse Over Minimap, \n".."             Press CTRL+H",
        GetScreenX()/2-125, GetScreenY()/2-175, Color.Cyan)
    end
    if #clones > 0 then
        for i, clone in ipairs(clones) do
            DrawTextObject(CloneText[CloneSay],clone.object,Color.Cyan)
            if GetClock() > (clone.tick+clone.duration) then table.remove(clones,i)
            end
        end
    end
end

function DoCircles()
    local xcolor=2
    if CanCastSpell ("R") then
        xcolor=4
    else
        xcolor=2
    end
    if myHero.dead == 0 then
        if GetSpellLevel("Q") > 0 then
            if  myHero.SpellTimeQ < -1 then
                CustomCircle(700/(-myHero.SpellTimeQ*-myHero.SpellTimeQ),2,xcolor,myHero)
            end
            if  myHero.SpellTimeQ > -1 then
                CustomCircle(700,2,xcolor,myHero)
                if GetSpellLevel("W") > 0 then
                    if myHero.SpellTimeW > -1 and (returnready==0 or CanCastSpell("R")) then
                        CustomCircle(1300,2,xcolor,myHero)
                    end
                end
            end
        end
    end
end

SetTimerCallback("LeblancRun")
