require 'Utils'
require 'winapi'
require 'SKeys'
local send = require 'SendInputScheduled'
local version = '1.0'
local targetaa

function UdyrRun()
    if IsChatOpen() == 0 and tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client" then
    
    AArange = (myHero.range+(GetDistance(GetMinBBox(myHero), GetMaxBBox(myHero))/2))
    
    targetaa = GetWeakEnemy('PHYS',AArange)
        
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
        
    if UdyrConfig.Attack then  
        if targetaa ~= nil then
    UseAllItems(targetaa)

            if RRDY == 1 then
                CastSpellXYZ('R',myHero.x, 0, myHero.z)
            end
            if WRDY == 1 and RRDY == 0 then
                CastSpellXYZ('W',myHero.x, 0, myHero.z)
            end
            if ERDY == 1 and RRDY == 0 and WRDY == 0 then
                CastSpellXYZ('E',myHero.x, 0, myHero.z)
            end
            if QRDY == 1 and RRDY == 0 and WRDY == 0 and ERDY == 0 then
                CastSpellXYZ('Q',myHero.x, 0, myHero.z)
            end
        end
    end

end
end

    UdyrConfig = scriptConfig("Udyr Config", "Udyr")
    UdyrConfig:addParam("Attack", "Attack" , SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
    UdyrConfig:permaShow("Attack")
    
    
SetTimerCallback("UdyrRun")
print("\nUdyr v"..version.."\n")