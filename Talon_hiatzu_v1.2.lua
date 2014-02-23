require 'Utils'
require 'winapi'
require 'SKeys'
require 'spell_damage'

local version = '1.2'
local uiconfig = require 'uiconfig'
local target
local target2

    TalonConfig, menu = uiconfig.add_menu('Talon Hotkeys', 200)
        menu.keydown('Combo', 'Combo', Keys.X)
        menu.keydown('Harass', 'Harass', Keys.Z)
        menu.checkbutton('Circles', 'Circles', true)
        menu.permashow('Combo')
        menu.permashow('Harass')


function Run()	
	target = GetWeakEnemy('PHYS',700,"NEARMOUSE")  
    target2 = GetWeakEnemy('PHYS',595,"NEARMOUSE")
    
        if myHero.SpellTimeQ > 1.0 and CanUseSpell("Q") == 1 then
        QRDY = true
        else QRDY = false
        end
 
        if myHero.SpellTimeW > 1.0 and CanUseSpell("W") == 1 then
        WRDY = true
        else WRDY = false
        end
 
        if myHero.SpellTimeE > 1.0 and CanUseSpell("E") == 1 then
        ERDY = true
        else ERDY = false
        end
 
        if myHero.SpellTimeR > 1.0 and CanUseSpell("R") == 1 then
        RRDY = true
        else RRDY = false
        end
    
    if TalonConfig.Circles then TalonDraw() end
    if TalonConfig.Combo then Combo() end
    if TalonConfig.Harass then Harass() end
end		

function Combo()
    if target ~= nil then
        CustomCircle(100,5,2,target)
        if GetDistance(myHero, target) < 595 then      
            TalonW()
        end      
            TalonE()
            TalonQ()                                 
            TalonR()
            AttackTarget(target)
    end
    if target == nil then moveToMouse() end        
end

function Harass()
    if target2 ~= nil then
		CustomCircle(100,5,2,target2)                                
		TalonWH()
		AttackTarget(target2)
    end
    if target2 == nil then moveToMouse() end
end
     
    
function TalonDraw()
        CustomCircle(700,2,3,myHero) 
end

function TalonQ()
    if QRDY == true then    
        CastSpellTarget("Q", target)
    end
end

function TalonW()
    if WRDY == true then
        CastSpellTarget("W", target)
    end
end

function TalonWH()
    if WRDY == true then
        CastSpellTarget("W", target2)
    end
end
 
function TalonE()
    if ERDY == true then
        CastSpellTarget("E", target)
    end
end
 
function TalonR()
    if RRDY == true then
        CastSpellTarget("R", myHero)
    end
end

function killSteal()
	CastHotkey("SPELLW:WEAKENEMY ONESPELLHIT=((spellw_level*50)+10+((player_bonusad*12)/10))")
end

function moveToMouse()
        MoveToXYZ(GetCursorWorldX(), GetCursorWorldY(), GetCursorWorldZ())
end

    
SetTimerCallback("Run")