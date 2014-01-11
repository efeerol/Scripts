--[[----------~~~~~~~~~~~~~~++++++++++++++Brautigan's TabTarget++++++++++++++~~~~~~~~~~~~~~--------------

    Allows for "tab-target" style targeting system for LoL.  Unfortunately, "Tab" is hardcoded into LoL for
    something else, so you'll have to go with a different hotkey for it.  Default is F.  Adjust targeting
    range with up-down arrow keys.  Default Range is 1500.

    To include in your script:

                1. requre "tabtarget"
                2. define target in your script: target=_G.target
                3. do not redefine "target" anywhere else in your script

-------------------------------------------------------------------------------------------------------]]--

require 'utils'
local xtarget
local xrange=1500
local enemies = {}
local targets = {}
local initialized, MaxEnemies, expand, x, targetTimer, xtime = 0, 0, 1, 0, 0, 0
local x1, x2, x3, x4 = 20, 15, 10, 5

TabTargetConfig = scriptConfig("             ~~~~++++Brautigan's TabTarget++++~~~~", "testConfig")
TabTargetConfig:addParam("TT", "Use Up/Down Arrows to adjust TabTarget Range", SCRIPT_PARAM_INFO)
TabTargetConfig:addParam("targetit", "Choose Your Target", SCRIPT_PARAM_ONKEYDOWN, false, 70)
TabTargetConfig:addParam("graphic", "Choose Graphics Mode", SCRIPT_PARAM_NUMERICUPDOWN, 1, 96, 1, 3, 1)
TabTargetConfig:permaShow("targetit")

function TabTarget()
    if _G.range == nil then
        yRange=1200
    else
        yRange=_G.range
    end
    if myHero.dead==0 then
        if initialized==0 then
            init()
        end
        CheckTargetStatus()
        if xtarget==nil or xtarget.dead==1 or GetDistance(xtarget)>xrange then
            if myHero.addDamage > myHero.ap then
                local target=GetWeakEnemy('PHYS', yRange)
                _G.target=GetWeakEnemy('PHYS', yRange)
                xtarget=nil
            else
                local target=GetWeakEnemy('MAGIC', yRange)
                _G.target=GetWeakEnemy('MAGIC', yRange)
                xtarget=nil
            end
        else
            local target=xtarget
            _G.target=xtarget
        end
        if TabTargetConfig.targetit then
            TargetSwitch()
        end
    end
end

function OnWndMsg(msg, key)
    if (key==40 and msg == KEY_DOWN) or (key==38 and msg == KEY_DOWN) then
        RangeAdjust()
    end
end


function init()
    if CanCastSpell("Q") or CanCastSpell("W") or CanCastSpell("E") then
        MaxEnemies=objManager:GetMaxHeroes()/2
        if #enemies < MaxEnemies then
            for i=1, objManager:GetMaxHeroes() do
                object = objManager:GetHero(i)
                if object.team ~= myHero.team and #enemies < MaxEnemies then
                    enemy = {object = object, cantarget = false, name=object.name}
                    table.insert(enemies, enemy)
                    initialized=1
                end
            end
        end
    end
end

function CheckTargetStatus()
    for i=1, #enemies do
        local item = enemies[i]
        if ValidTarget(item.object) and GetDistance(item.object) < xrange then
            item.cantarget = true
            if TargetAdd(item) == false then
                table.insert(targets, item)
            end
        else
            item.cantarget=false
            TargetRemove(item)
        end
    end
end

function TargetSwitch()
    if TabTargetConfig.targetit then
        if GetClock()-targetTimer > 0 then
            x=x+1
            if x > #targets then
                x = 1
            end
            if x > #targets or #targets == 0 or x==0 then
                xtarget=nil
            else xtarget=targets[x].object
            end
        targetTimer=GetClock()+350
        end
    end
end

function TargetAdd(targetItem)
    for i=1, #targets do
    local item = targets[i]
        if item.name == targetItem.name then
            return true
        end
    end
    return false
end

function TargetRemove(targetItem)
    for i=1, #targets do
    local item = targets[i]
        if item.name == targetItem.name then
            table.remove(targets, i)
        end
    end
end

function RangeAdjust()
    if IsKeyDown(40)==1 then
        DrawTextObject("\n\n\n\n\n Targeting Range = "..xrange, myHero, Color.Cyan)
        CustomCircle(xrange,2, 3, myHero)
        if GetClock()-xtime > 0 and xrange ~= 300 then
            xrange=xrange-25
            xtime=GetClock()+40
        end
    elseif IsKeyDown(38)==1 then
        DrawTextObject("\n\n\n\n\n TargetingRange = "..xrange, myHero, Color.Cyan)
        CustomCircle(xrange,2, 3, myHero)
        if GetClock()-xtime > 0 and xrange ~= 1800 then
            xrange=xrange+25
            xtime=GetClock()+40
        end
    end
end

function OnDraw()
    if ValidTarget(target) then
        if TabTargetConfig.graphic==1 or TabTargetConfig.graphic==3 then
            if expand==1 then
                x1, x2, x3, x4 = x1+2, x2+2, x3+2, x4+2
                CustomCircle(x1,5,3,"",target.x,target.y+300 ,target.z)
                CustomCircle(x2,3,5,"",target.x,target.y+300 ,target.z)
                CustomCircle(x3,2,3,"",target.x,target.y+300 ,target.z)
                CustomCircle(2,2,2,"",target.x,target.y+300 ,target.z)
                if x1==28 then
                  expand=0
                end
            end
            if expand==0 then
                x1, x2, x3, x4 = x1-2, x2-2, x3-2, x4-2
                CustomCircle(x1,5,3,"",target.x,target.y+300 ,target.z)
                CustomCircle(x2,3,5,"",target.x,target.y+300 ,target.z)
                CustomCircle(x3,2,3,"",target.x,target.y+300 ,target.z)
                CustomCircle(2,2,2,"",target.x,target.y+300 ,target.z)
                if x1==20 then
                    expand=1
                end
            end
        end
        if TabTargetConfig.graphic==1 or TabTargetConfig.graphic==2 then
            DrawLine (target.x-100, target.y-150,target.z,  50, 3,1.57, 30)
            DrawLine (target.x-48, target.y-150,target.z,  50, 3,1.57, 30)
            DrawLine (target.x+4, target.y-150,target.z,  50, 3,1.57, 30)
            DrawLine (target.x+56, target.y-150,target.z,  50, 3,1.57, 30)
            if target.SpellLevelQ > 0 and target.SpellTimeQ > -1 then
                if target.SpellTimeQ > 1 then CustomCircle(1,40,2,"",target.x-76,target.y-150 ,target.z)
                elseif target.SpellTimeQ > 0 then CustomCircle(1,30,4,"",target.x-76,target.y-150 ,target.z)
                elseif target.SpellTimeQ > -1 then CustomCircle(1,20,8,"",target.x-76,target.y-150 ,target.z)
                end
            end
             if target.SpellLevelW > 0 and target.SpellTimeW > -1 then
                if target.SpellTimeW > 1 then CustomCircle(1,40,2,"",target.x-25,target.y-150 ,target.z)
                elseif target.SpellTimeW > 0 then CustomCircle(1,30,4,"",target.x-25,target.y-150 ,target.z)
                elseif target.SpellTimeW > -1 then CustomCircle(1,20,8,"",target.x-25,target.y-150 ,target.z)
                end
            end
            if target.SpellLevelE > 0 and target.SpellTimeE > -1 then
                if target.SpellTimeE > 1 then CustomCircle(1,40,2,"",target.x+27,target.y-150 ,target.z)
                elseif target.SpellTimeE > 0 then CustomCircle(1,30,4,"",target.x+27,target.y-150 ,target.z)
                elseif target.SpellTimeE > -1 then CustomCircle(1,20,8,"",target.x+27,target.y-150 ,target.z)
                end
            end
            if target.SpellLevelR > 0 and target.SpellTimeR > -1 then
                if target.SpellTimeR > 1 then CustomCircle(1,40,2,"",target.x+80,target.y-150 ,target.z)
                elseif target.SpellTimeR > 0 then CustomCircle(1,30,4,"",target.x+80,target.y-150 ,target.z)
                elseif target.SpellTimeR > -1 then CustomCircle(1,20,8,"",target.x+80,target.y-150 ,target.z)
                end
            end
        end
    end
end

SetTimerCallback("TabTarget")
