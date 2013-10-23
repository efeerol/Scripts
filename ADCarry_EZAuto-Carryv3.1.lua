--[[
    ====================================
    |          Auto Carry              |
    |          Version 3.0             |
    |                                  |
    ====================================


    ====================================
    |            Version Log           |
    ====================================


    2.1.1: 6/25 TSM
        - Added LaneClear
        - Added getAdditionalDamage()
    
    3.0:  6/25 Gem and TSM
        - Convention changes and code re-writes, more extensive than we wish to comment on.
   ]]--
   

require "Utils"
require "spell_damage"

p = printtext

local target
local target2
local targetHero
local startAttackSpeed
local projSpeed = 1
local lastAttack = GetTickCount()
local shotFired = false
local range = myHero.range + GetDistance(GetMinBBox(myHero))
local attackDelayOffset = 275
local isMoving = false
local startAttackSpeed = 0.625 

OrbConfig = scriptConfig("AutoCarry", "Orb")
OrbConfig:addParam("AutoCarry", "OrbWalk", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
OrbConfig:addParam("Hybrid", "Hybrid", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
OrbConfig:addParam("Farm", "Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
OrbConfig:addParam("LaneClear", "LaneClear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V")) 
OrbConfig:addParam("Kite", "Kite", SCRIPT_PARAM_ONOFF, true,string.byte("O"))
OrbConfig:addParam("Draw", "Draw Circles", SCRIPT_PARAM_ONOFF, true,string.byte("P"))
OrbConfig:permaShow("AutoCarry")
OrbConfig:permaShow("Hybrid")
OrbConfig:permaShow("Farm")
     
function OnTick()
    targetReset()
    if target and target.dead == 1 then target = nil end
    
    if OrbConfig.AutoCarry and IsChatOpen() == 0 then
        AutoCarry()
    end
   
    if OrbConfig.Hybrid and IsChatOpen() == 0 then
        Hybrid()
    end
                   
    if OrbConfig.Farm and IsChatOpen() == 0 then
        Farm()
    end
    
    if OrbConfig.LaneClear and IsChatOpen() == 0 then
        LaneClear()
    end
           
    if OrbConfig.AutoCarry or OrbConfig.Hybrid or OrbConfig.Farm or OrbConfig.LaneClear then
        moveToCursor()
    end
   
    if OrbConfig.Draw then
        if myHero.dead ~= 1 then
            CustomCircle(trueRange(),2,5,myHero)
        end
    end
end

function OnLoad()
    if GetAAData()[myHero.name] ~= nil then
        if GetAAData()[myHero.name].projSpeed ~= nil then
            projSpeed = GetAAData()[myHero.name].projSpeed
        end
    end
    if GetAAData()[myHero.name] ~= nil then
        if GetAAData()[myHero.name].startAttackSpeed ~= nil then
            startAttackSpeed = GetAAData()[myHero.name].startAttackSpeed
        end
    end
        p("\nTrue Range: "..math.ceil(range).."\nTraditional Range: "..myHero.range)
end

function trueRange()
local trueRangeValue
        if target ~= nil and GetDistance(target) < range then
                trueRangeValue = range -(range-GetDistance(target))
        else
                trueRangeValue = range
        end
        return trueRangeValue
end

function targetReset()
        if not target and not target2 and not targetHero then
        target = nil
        target2 = nil
        targetHero = nil
        end
end

function Action()
        if timeToShoot() then
            attackEnemy(target)
            CustomCircle(100,10,1,target)
        else
            CustomCircle(100,5,2,target)
            if heroCanMove() then moveToCursor() end
        end
end

function attackEnemy(target)
        if ValidTarget(target) then
        AttackTarget(target)
        shotFired = True
        end
end

function GetNextAttackTime()
    return lastAttack + attackDelayOffset / GetAttackSpeed()
end

function GetAttackSpeed()
    return myHero.attackspeed/(1/startAttackSpeed)
end

function timeToShoot()
    if GetTickCount() > GetNextAttackTime() then
    return true
    end
    return false
end

function heroCanMove()
    if shotFired == false or timeToShoot() then
        return true
    end
    return false
end

function moveToCursor() -- Removes derping when mouse is in one position instead of myHero:MoveTo mousePos
    isMoving = true
    local moveSqr = math.sqrt((mousePos.x - myHero.x)^2+(mousePos.z - myHero.z)^2)
    local moveX = myHero.x + 300*((mousePos.x - myHero.x)/moveSqr)
    local moveZ = myHero.z + 300*((mousePos.z - myHero.z)/moveSqr)
    MoveToXYZ(moveX,0,moveZ)
end

function On()
    local HP = (myHero.maxHealth *(.25))
    local HPB = (myHero.maxHealth *(.20))
    if myHero.health < HP and target~=nil and myHero.SummonerF == "SummonerHeal" then
        CastSpellTarget("F",myHero)
    elseif myHero.health < HP and target~=nil and myHero.SummonerD == "SummonerHeal" then
        CastSpellTarget("D",myHero)
    end

    if myHero.health < HPB and target~=nil and myHero.SummonerF == "SummonerBarrier" then
        CastSpellTarget("F",myHero)
    elseif myHero.health < HPB and target~=nil and myHero.SummonerD == "SummonerBarrier" then
        CastSpellTarget("D",myHero)
    end
end    

function OnCreateObj(object)
    if GetAAData()[myHero.name] ~= nil then
        for _, v in pairs(GetAAData()[myHero.name].aaParticles) do
            if string.find(object.charName,v) then
                shotFired = false
                lastAttack = GetTickCount()
            end
        end
    end
end

function OnProcessSpell(obj,spell)
    if obj ~= nil and obj.name == myHero.name then
        if string.find(spell.name,"attack") then                       
            lastAttack = GetTickCount()
        end
    end
end

function GetAAData()
    return {  
        Ahri         = { projSpeed = 1.6, aaParticles = {"Ahri_BasicAttack_mis", "Ahri_BasicAttack_tar"}, aaSpellName = "ahribasicattack", startAttackSpeed = "0.668",  },
        Anivia       = { projSpeed = 1.05, aaParticles = {"cryo_BasicAttack_mis", "cryo_BasicAttack_tar"}, aaSpellName = "aniviabasicattack", startAttackSpeed = "0.625",  },
        Annie        = { projSpeed = 1.0, aaParticles = {"AnnieBasicAttack_tar", "AnnieBasicAttack_tar_frost", "AnnieBasicAttack2_mis", "AnnieBasicAttack3_mis"}, aaSpellName = "anniebasicattack", startAttackSpeed = "0.579",  },
        Ashe         = { projSpeed = 2.0, aaParticles = {"bowmaster"}, aaSpellName = "attack", startAttackSpeed = "0.658" },
        Brand        = { projSpeed = 1.975, aaParticles = {"BrandBasicAttack_cas", "BrandBasicAttack_Frost_tar", "BrandBasicAttack_mis", "BrandBasicAttack_tar", "BrandCritAttack_mis", "BrandCritAttack_tar", "BrandCritAttack_tar"}, aaSpellName = "brandbasicattack", startAttackSpeed = "0.625" },
        Caitlyn      = { projSpeed = 2.5, aaParticles = {"caitlyn_basicAttack_cas", "caitlyn_headshot_tar", "caitlyn_mis_04"}, aaSpellName = "caitlynbasicattack", startAttackSpeed = "0.668" },
        Cassiopeia   = { projSpeed = 1.22, aaParticles = {"CassBasicAttack_mis"}, aaSpellName = "cassiopeiabasicattack", startAttackSpeed = "0.644" },
        Corki        = { projSpeed = 2.0, aaParticles = {"corki_basicAttack_mis", "Corki_crit_mis"}, aaSpellName = "CorkiBasicAttack", startAttackSpeed = "0.658" },
        Draven       = { projSpeed = 1.4, aaParticles = {"Draven_BasicAttack_mis","Draven_Q_mis", "Draven_Q_mis_bloodless", "Draven_Q_mis_shadow", "Draven_Q_mis_shadow_bloodless", "Draven_Qcrit_mis", "Draven_Qcrit_mis_bloodless", "Draven_Qcrit_mis_shadow", "Draven_Qcrit_mis_shadow_bloodless", "Draven_BasicAttack_mis_shadow", "Draven_BasicAttack_mis_shadow_bloodless", "Draven_BasicAttack_mis_bloodless", "Draven_crit_mis", "Draven_crit_mis_shadow_bloodless", "Draven_crit_mis_bloodless", "Draven_crit_mis_shadow", "Draven_Q_mis", "Draven_Qcrit_mis"}, aaSpellName = "dravenbasicattack", startAttackSpeed = "0.679",  },
        Ezreal       = { projSpeed = 2.0, aaParticles = {"Ezreal_basicattack_mis", "Ezreal_critattack_mis"}, aaSpellName = "ezrealbasicattack", startAttackSpeed = "0.625" },
        FiddleSticks = { projSpeed = 1.75, aaParticles = {"FiddleSticks_cas", "FiddleSticks_mis", "FiddleSticksBasicAttack_tar"}, aaSpellName = "fiddlesticksbasicattack", startAttackSpeed = "0.625" },
        Graves       = { projSpeed = 3.0, aaParticles = {"Graves_BasicAttack_mis",}, aaSpellName = "gravesbasicattack", startAttackSpeed = "0.625" },
        Heimerdinger = { projSpeed = 1.4, aaParticles = {"heimerdinger_basicAttack_mis", "heimerdinger_basicAttack_tar"}, aaSpellName = "heimerdingerbasicAttack", startAttackSpeed = "0.625" },
        Janna        = { projSpeed = 1.2, aaParticles = {"JannaBasicAttack_mis", "JannaBasicAttack_tar", "JannaBasicAttackFrost_tar"}, aaSpellName = "jannabasicattack", startAttackSpeed = "0.625" },
        Jayce        = { projSpeed = 2.2, aaParticles = {"Jayce_Range_Basic_mis", "Jayce_Range_Basic_Crit"}, aaSpellName = "jaycebasicattack", startAttackSpeed = "0.658",  },
        Karma        = { projSpeed = nil, aaParticles = {"karma_basicAttack_cas", "karma_basicAttack_mis", "karma_crit_mis"}, aaSpellName = "karmabasicattack", startAttackSpeed = "0.658",  },
        Karthus      = { projSpeed = 1.25, aaParticles = {"LichBasicAttack_cas", "LichBasicAttack_glow", "LichBasicAttack_mis", "LichBasicAttack_tar"}, aaSpellName = "karthusbasicattack", startAttackSpeed = "0.625" },
        Kayle        = { projSpeed = 1.8, aaParticles = {"RighteousFury_nova"}, aaSpellName = "KayleBasicAttack", startAttackSpeed = "0.638",  }, -- Kayle doesn't have a particle when auto attacking without E buff..
        Kennen       = { projSpeed = 1.35, aaParticles = {"KennenBasicAttack_mis"}, aaSpellName = "kennenbasicattack", startAttackSpeed = "0.690" },
        KogMaw       = { projSpeed = 1.8, aaParticles = {"KogMawBasicAttack_mis", "KogMawBioArcaneBarrage_mis"}, aaSpellName = "kogmawbasicattack", startAttackSpeed = "0.665", },
        Leblanc      = { projSpeed = 1.7, aaParticles = {"leBlanc_basicAttack_cas", "leBlancBasicAttack_mis"}, aaSpellName = "leblancbasicattack", startAttackSpeed = "0.625" },
        Lulu         = { projSpeed = 2.5, aaParticles = {"lulu_attack_cas", "LuluBasicAttack", "LuluBasicAttack_tar"}, aaSpellName = "LuluBasicAttack", startAttackSpeed = "0.625" },
        Lux          = { projSpeed = 1.55, aaParticles = {"LuxBasicAttack_mis", "LuxBasicAttack_tar", "LuxBasicAttack01"}, aaSpellName = "luxbasicattack", startAttackSpeed = "0.625" },
        Malzahar     = { projSpeed = 1.5, aaParticles = {"AlzaharBasicAttack_cas", "AlZaharBasicAttack_mis"}, aaSpellName = "malzaharbasicattack", startAttackSpeed = "0.625" },
        MissFortune  = { projSpeed = 2.0, aaParticles = {"missFortune_basicAttack_mis", "missFortune_crit_mis"}, aaSpellName = "missfortunebasicattack", startAttackSpeed = "0.656" },
        Morgana      = { projSpeed = 1.6, aaParticles = {"FallenAngelBasicAttack_mis", "FallenAngelBasicAttack_tar", "FallenAngelBasicAttack2_mis"}, aaSpellName = "Morganabasicattack", startAttackSpeed = "0.579" },
        Nidalee      = { projSpeed = 1.7, aaParticles = {"nidalee_javelin_mis"}, aaSpellName = "nidaleebasicattack", startAttackSpeed = "0.670" },
        Orianna      = { projSpeed = 1.4, aaParticles = {"OrianaBasicAttack_mis", "OrianaBasicAttack_tar"}, aaSpellName = "oriannabasicattack", startAttackSpeed = "0.658" },
        Quinn        = { projSpeed = 1.85, aaParticles = {"Quinn_basicattack_mis", "QuinnValor_BasicAttack_01", "QuinnValor_BasicAttack_02", "QuinnValor_BasicAttack_03", "Quinn_W_mis"}, aaSpellName = "QuinnBasicAttack", startAttackSpeed = "0.668" },  --Quinn's critical attack has the same particle name as his basic attack.
        Ryze         = { projSpeed = 2.4, aaParticles = {"ManaLeach_mis"}, aaSpellName = {"RyzeBasicAttack"}, startAttackSpeed = "0.625" },
        Sivir        = { projSpeed = 1.4, aaParticles = {"sivirbasicattack_mis", "sivirbasicattack2_mis", "SivirRicochetAttack_mis"}, aaSpellName = "sivirbasicattack", startAttackSpeed = "0.658" },
        Sona         = { projSpeed = 1.6, aaParticles = {"SonaBasicAttack_mis", "SonaBasicAttack_tar", "SonaCritAttack_mis", "SonaPowerChord_AriaofPerseverance_mis", "SonaPowerChord_AriaofPerseverance_tar", "SonaPowerChord_HymnofValor_mis", "SonaPowerChord_HymnofValor_tar", "SonaPowerChord_SongOfSelerity_mis", "SonaPowerChord_SongOfSelerity_tar", "SonaPowerChord_mis", "SonaPowerChord_tar"}, aaSpellName = "sonabasicattack", startAttackSpeed = "0.644" },
        Soraka       = { projSpeed = 1.0, aaParticles = {"SorakaBasicAttack_mis", "SorakaBasicAttack_tar"}, aaSpellName = "sorakabasicattack", startAttackSpeed = "0.625" },
        Swain        = { projSpeed = 1.6, aaParticles = {"swain_basicAttack_bird_cas", "swain_basicAttack_cas", "swainBasicAttack_mis"}, aaSpellName = "swainbasicattack", startAttackSpeed = "0.625" },
        Syndra       = { projSpeed = 1.2, aaParticles = {"Syndra_attack_hit", "Syndra_attack_mis"}, aaSpellName = "sorakabasicattack", startAttackSpeed = "0.625",  },
        Teemo        = { projSpeed = 1.3, aaParticles = {"TeemoBasicAttack_mis", "Toxicshot_mis"}, aaSpellName = "teemobasicattack", startAttackSpeed = "0.690" },
        Tristana     = { projSpeed = 2.25, aaParticles = {"TristannaBasicAttack_mis"}, aaSpellName = "tristanabasicattack", startAttackSpeed = "0.656",  },
        TwistedFate  = { projSpeed = 1.5, aaParticles = {"TwistedFateBasicAttack_mis", "TwistedFateStackAttack_mis"}, aaSpellName = "twistedfatebasicattack", startAttackSpeed = "0.651",  },
        Twitch       = { projSpeed = 2.5, aaParticles = {"twitch_basicAttack_mis",--[[ "twitch_punk_sprayandPray_tar", "twitch_sprayandPray_tar",]] "twitch_sprayandPray_mis"}, aaSpellName = "twitchbasicattack", startAttackSpeed = "0.679" },
        Urgot        = { projSpeed = 1.3, aaParticles = {"UrgotBasicAttack_mis"}, aaSpellName = "urgotbasicattack", startAttackSpeed = "0.644" },
        Vayne        = { projSpeed = 2.0, aaParticles = {"vayne_basicAttack_mis", "vayne_critAttack_mis", "vayne_ult_mis" }, aaSpellName = "vaynebasicattack", startAttackSpeed = "0.658",  },
        Varus        = { projSpeed = 2.0, aaParticles = {"Attack"}, aaSpellName = "basic", startAttackSpeed = "0.658",  },
        Veigar       = { projSpeed = 1.05, aaParticles = {"ahri_basicattack_mis"}, aaSpellName = "veigarbasicattack", startAttackSpeed = "0.625" },
        Viktor       = { projSpeed = 2.25, aaParticles = {"ViktorBasicAttack_cas", "ViktorBasicAttack_mis", "ViktorBasicAttack_tar"}, aaSpellName = "viktorbasicattack", startAttackSpeed = "0.625" },
        Vladimir     = { projSpeed = 1.4, aaParticles = {"VladBasicAttack_mis", "VladBasicAttack_mis_bloodless", "VladBasicAttack_tar", "VladBasicAttack_tar_bloodless"}, aaSpellName = "vladimirbasicattack", startAttackSpeed = "0.658" },
        Xerath       = { projSpeed = 1.2, aaParticles = {"XerathBasicAttack_mis", "XerathBasicAttack_tar"}, aaSpellName = "xerathbasicattack", startAttackSpeed = "0.625" },
        Ziggs        = { projSpeed = 1.5, aaParticles = {"ZiggsBasicAttack_mis", "ZiggsPassive_mis"}, aaSpellName = "ziggsbasicattack", startAttackSpeed = "0.656" },
        Zilean       = { projSpeed = 1.25, aaParticles = {"ChronoBasicAttack_mis"}, aaSpellName = "zileanbasicattack" },
        Zyra         = { projSpeed = 1.7, aaParticles = {"Zyra_basicAttack_cas", "Zyra_basicAttack_cas_02", "Zyra_basicAttack_mis", "Zyra_basicAttack_tar", "Zyra_basicAttack_tar_hellvine"}, aaSpellName = "zileanbasicattack", startAttackSpeed = "0.625",  },

    }
end

function getAdditionalDamage() 
    if myHero.name == "Thresh" then
        local attacku = 0.01
        local ticky
        ticky=GetTickCount()
            if GetSpellLevel("E") > 0 then
                if (ticky - lastAttack) > 10000 then
                    attacku = 1
                else
                    attacku = (ticky - lastAttack)/10001
                end
            return
                math.round((((GetSpellLevel("E")*30)+50)/100)*(myHero.addDamage+myHero.baseDamage)*attacku+(myHero.ap))
            end
    end

    if myHero.name == "Orianna" then
        if myHero.selflevel > 15 then
        return math.round( 50 + (myHero.ap * 0.15) )
        elseif myHero.selflevel > 12 then
        return math.round( 42 + (myHero.ap * 0.15) )
        elseif myHero.selflevel > 9 then
        return math.round( 34 + (myHero.ap * 0.15) )
        elseif myHero.selflevel > 6 then
        return math.round( 26 + (myHero.ap * 0.15) )
        elseif myHero.selflevel > 3 then
        return math.round( 18 + (myHero.ap * 0.15) )
        elseif myHero.selflevel > 0 then
        return math.round( 10 + (myHero.ap * 0.15) )
        end
    end
    return 0
end

function AutoCarry()
    CustomCircle(range,2,4,myHero)
    if target2 ~= nil then 
        target = target2 
    else 
        target = GetWeakEnemy("PHYS",range) 
    end
    
    if target ~= nil then
        UseAllItems(target)
        Action()
    else
        moveToCursor()
    end
end

function Hybrid()
    CustomCircle(range,2,4,myHero)
    targetHero = GetWeakEnemy("PHYS",range)

    if targetHero ~= nil then
        target = targetHero
    Action()
    else 
        target = GetLowestHealthEnemyMinion(range) 
    end
        
    if target ~= nil then
        if ( getDmg("AD",target,myHero) + getAdditionalDamage() ) >= target.health then
            Action()
        end
    else
        moveToCursor()
    end
end

function Farm()
    CustomCircle(range,2,4,myHero)
    
    if target2 ~= nil then 
        target = target2 
    end

    if GetLowestHealthEnemyMinion(range) ~= nil then 
        target = GetLowestHealthEnemyMinion(range) 
    end
    
    if target ~= nil then
        if ( getDmg("AD",target,myHero) + getAdditionalDamage() ) >= target.health then
            Action()
        end
    else
        moveToCursor()
    end
end

function LaneClear()
    CustomCircle(range,2,4,myHero)
    tlow=GetLowestHealthEnemyMinion(range) 
    thigh=GetHighestHealthEnemyMinion(range) 

    if target2 ~= nil then 
        target = target2 
    end

    if tlow~= nil then 
        target = tlow
    end

    if thigh ~= nil then     
    target = thigh
    end

    if target ~= nil then 
        Action()
    
    else
    moveToCursor()
    end
end

OnLoad()

if GetAAData()[myHero.name] ~= nil then p("\n\nAuto Carry Loaded: "..myHero.name.."\n") end

SetTimerCallback("OnTick")