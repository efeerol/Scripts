require "Utils"
require "spell_damage"
print("\nMalbert's")
print("\nOil and Veigar")
print("\nVersion 2.5")

local target
local targetrange
local targetminion
local target600
local closestEnemy
local checkDie=false
 
local lastAttack=0
local startAttackSpeed = 0.6249
local shotFired = false
local shotFired2 = false
local range = myHero.range + GetDistance(GetMinBBox(myHero))
local attackDelayOffset = 0.08--0.275
local isMoving = false
local moveX
local moveZ

local enemies={}

local twfx,twfy,twfz
local twfa={x=0,y=0,z=0}

local egg = {team = 0, enemy = 0}
local zac = {team = 0, enemy = 0}
local aatrox = {team = 0, enemy = 0}
local cc = 0
local skillshotArray = {
}
local colorcyan = 0x0000FFFF
local coloryellow = 0xFFFFFF00
local colorgreen = 0xFF00FF00
local drawskillshot = true
local dodgeskillshot = false
local playerradius = 150
local skillshotcharexist = false
local show_allies=0
local QRDY=0
local WRDY=0
local ERDY=0
local RRDY=0
local WTimer=0
local DFG=3128

VeigConfig = scriptConfig("Veigar", "Vinegar Hotkeys")
VeigConfig:addParam("e", "Stun and Run", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))--Z
VeigConfig:addParam("h", "Harass Walk", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))--T
VeigConfig:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))--T
VeigConfig:addParam("f", "Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))--C
VeigConfig:addParam("pf", "Protect when Farming", SCRIPT_PARAM_ONKEYTOGGLE, true,55)
VeigConfig:addParam("nm", "NEARMOUSE Targetting", SCRIPT_PARAM_ONKEYTOGGLE, false,56)
VeigConfig:addParam("OS", "Always W Combo", SCRIPT_PARAM_ONKEYTOGGLE, false,57)
VeigConfig:addParam("spm", "Stun Placement", SCRIPT_PARAM_NUMERICUPDOWN, 1, 48,0.8,1.5,0.01)
VeigConfig:addParam("sfa", "Stun Fireahead", SCRIPT_PARAM_NUMERICUPDOWN, 3, 189,1,4,0.1)
VeigConfig:addParam("AW", "Auto W Stunned Enemy", SCRIPT_PARAM_ONOFF, false)
VeigConfig:addParam("ult", "Ult On/Off", SCRIPT_PARAM_ONOFF, false)
VeigConfig:addParam("zh", "Zhonyas", SCRIPT_PARAM_ONOFF, true)
VeigConfig:addParam("ks", "KillSteal", SCRIPT_PARAM_ONOFF, true)
VeigConfig:permaShow("pf")
VeigConfig:permaShow("nm")
VeigConfig:permaShow("ult")
VeigConfig:permaShow("OS")
VeigConfig:permaShow("AW")
VeigConfig:permaShow("zh")
VeigConfig:permaShow("ks")


function VeigRun()
	if cc<40 then cc=cc+1 if cc==30 then LoadTable() end end
	if VeigConfig.nm then
		target = GetBestEnemy("MAGIC",750,"NEARMOUSE")
	else
		target = GetBestEnemy("MAGIC",750)
	end
	target600 = GetBestEnemy("TRUE",600)
	targetrange=GetBestEnemy("MAGIC",650)
	
	closestEnemy=nil
	for i=1, objManager:GetMaxHeroes(), 1 do
		local hero = objManager:GetHero(i)
		if hero~=nil and hero.team~=myHero.team and hero.visible==1 and hero.dead~=1 and GetD(hero)<650 and (closestEnemy==nil or (closestEnemy.dead~=nil and closestEnemy.dead==1)) then
			closestEnemy=hero
		elseif hero~=nil and hero.team~=myHero.team and hero.visible==1 and hero.dead~=1 and GetD(hero)<650 and closestEnemy~=nil and GetD(hero)<GetD(closestEnemy) then
			closestEnemy=hero
		end
		if hero~=nil and hero.team~=myHero.team then
			if not enemies[hero.name] then
				enemies[hero.name]={unit=hero,stunned=0,stunTimer=0}
			elseif enemies[hero.name] and enemies[hero.name].stunned==1 and enemies[hero.name].stunTimer<os.clock() then
				enemies[hero.name].stunned=0
			end
		end
	end
	checkDie=false
        if VeigConfig.zh then
                checkDie=true
                if target~=nil and myHero.health<myHero.maxHealth*15/100 then
                        zhonyas()
                end
        else
                checkDie=false
        end
		
	if target~=nil then
	
		twfx,twfy,twfz=GetFireahead(target,11,0)
		twfa={x=twfx,y=twfy,z=twfz}
	
	end
	if IsChatOpen()==0 and VeigConfig.Combo then C() end
	if IsChatOpen()==0 and VeigConfig.h then Harass() end
	if IsChatOpen()==0 and VeigConfig.e then Stun() end
	
	if IsChatOpen() == 0 and VeigConfig.f and VeigConfig.pf then
                farm2()
        elseif IsChatOpen() == 0 and VeigConfig.f and not VeigConfig.pf then
                farm()
        end
	
	--ignite()
	if VeigConfig.ks then
		killsteal()
	end
	if myHero.dead~=1 then
                local moveSqr = math.sqrt((mousePos.x - myHero.x)^2+(mousePos.z - myHero.z)^2)
                moveX = myHero.x + 300*((mousePos.x - myHero.x)/moveSqr)
                moveZ = myHero.z + 300*((mousePos.z - myHero.z)/moveSqr)
        end
		
			------------
	if myHero.SpellTimeQ > 1.0 and GetSpellLevel("Q") > 0 and myHero.mana>=55+5*GetSpellLevel("Q") then
                QRDY = 1
                else QRDY = 0
        end
        if myHero.SpellTimeW > 1.0 and GetSpellLevel("W") > 0 and myHero.mana>=60+10*GetSpellLevel("W") then
                WRDY = 1
                else WRDY = 0
        end
        if myHero.SpellTimeE > 1.0 and GetSpellLevel("E") > 0  and myHero.mana>=70+10*GetSpellLevel("E") then
                ERDY = 1
                else ERDY = 0
        end
        if myHero.SpellTimeR > 1.0 and GetSpellLevel("R") > 0  and myHero.mana>=75+25*GetSpellLevel("R") then
                RRDY = 1
        else RRDY = 0 end
	--------------------------
end

function checkStunned(targ)
	if WRDY==1 and targ~=nil then
		if enemies[targ.name]~=nil and enemies[targ.name].unit.dead~=1 and enemies[targ.name].unit.visible==1 and enemies[targ.name].stunned==1 then
					--print("\n  Checking\n")
			return true
			
		end
	end
	return false
	
end


function OnProcessSpell(unit, spell)
        if unit.charName==myHero.charName then
        --printtext("\nS "..spell.name.."  " ..os.clock().."\n")        
        local s=spell.name
        if (s ~= nil) then
            if string.find(s,"VeigarBalefulStrike") ~= nil then    
				shotFired2=false
                        end
		    if string.find(s,"VeigarDarkMatter") ~= nil then    
				WTimer=os.clock()
			end
        end
 
        elseif myHero.dead~=1 then
                local Q
                local W
                local E
                local R
                if unit~= nil then
                        Q = unit.SpellNameQ
                        W = unit.SpellNameW
                        E = unit.SpellNameE
                        R = unit.SpellNameR
                end
                if checkDie==true then
                        if unit~= nil and unit.name~="Worm" and spell ~= nil and unit.team ~= myHero.team and spell.target~=nil and spell.target.name~=nil and spell.target.name == myHero.name then
                                --print("\nI: " .. spell.target.name .. "  S " .. spell.name .. "\n Q " .. Q.. "  W " .. W .. "  E " .. E .. "  R " .. R)
                                --print("\nB: " .. unit.name)
                                if spell.name == Q then
                                        if spellDmg[unit.name] and getDmg("Q",myHero,unit)~=nil and getDmg("Q",myHero,unit) > myHero.health then
                                                zhonyas()
                                                --CastSummonerBarrier()
                                                --CastSummonerHeal()
                                        end
                               
                                elseif spell.name == W then
                                        if spellDmg[unit.name] and getDmg("W",myHero,unit)~=nil and getDmg("W",myHero,unit) > myHero.health then
                                                zhonyas()
                                               -- CastSummonerBarrier()
                                               -- CastSummonerHeal()
                                        end
                               
                                elseif spell.name == E then
                                        if spellDmg[unit.name] and getDmg("E",myHero,unit)~=nil and getDmg("E",myHero,unit) > myHero.health then
                                                zhonyas()
                                               -- CastSummonerBarrier()
                                               -- CastSummonerHeal()
                                        end
 
                                elseif spell.name == R then
                                        if spellDmg[unit.name] and getDmg("R",myHero,unit)~=nil and getDmg("R",myHero,unit) > myHero.health then
                                                zhonyas()
                                               -- CastSummonerBarrier()
                                               -- CastSummonerHeal()
                                        end
                               
                                elseif spell.name:find("BasicAttack") or spell.name:find("BasicAttack2") or spell.name:find("BasicaAttack3")  or spell.name:find("ChaosTurretFire") then
                                        if (unit.baseDamage + unit.addDamage) > myHero.health then
                                                zhonyas()
                                              --  CastSummonerBarrier()
                                               -- CastSummonerHeal()
                                        end    
                                elseif spell.name:find("CritAttack") then
                                        if 2*(unit.baseDamage + unit.addDamage) > myHero.health then
                                                zhonyas()
                                               -- CastSummonerBarrier()
                                               -- CastSummonerHeal()
                                        end
                                end
   
                        end
       
                        local P1 = spell.startPos
                        local P2 = spell.endPos
                        local calc = (math.floor(math.sqrt((P2.x-unit.x)^2 + (P2.z-unit.z)^2)))
                        if string.find(unit.name,"Minion_") == nil and string.find(unit.name,"Turret_") == nil then
                                if (unit.team ~= myHero.team or (show_allies==1)) and string.find(spell.name,"Basic") == nil then
 
                                        if spell.name == Q then
                                                if spellDmg[unit.name] and getDmg("Q",myHero,unit)~=nil and getDmg("Q",myHero,unit) > myHero.health then
                                               
                                                        for i=1, #skillshotArray, 1 do
                                                                local maxdist
                                                                local dodgeradius
                                                                dodgeradius = skillshotArray[i].radius
                                                                maxdist = skillshotArray[i].maxdistance
                                                                if spell.name == skillshotArray[i].name then
                                                                        skillshotArray[i].shot = 1
                                                                        skillshotArray[i].lastshot = os.clock()
                                                                        if skillshotArray[i].type == 1 then
                                                                                                                                skillshotArray[i].p1x = unit.x
                                                                                                                                skillshotArray[i].p1y = unit.y
                                                                                                                                skillshotArray[i].p1z = unit.z
                                                                                                                                skillshotArray[i].p2x = unit.x + (maxdist)/calc*(P2.x-unit.x)
                                                                                                                                skillshotArray[i].p2y = P2.y
                                                                                                                                skillshotArray[i].p2z = unit.z + (maxdist)/calc*(P2.z-unit.z)
                                                                                dodgelinepass(unit, P2, dodgeradius, maxdist)
                                                                        elseif skillshotArray[i].type == 2 then
                                                                                skillshotArray[i].px = P2.x
                                                                                                                                skillshotArray[i].py = P2.y
                                                                                                                                skillshotArray[i].pz = P2.z
                                                                                dodgelinepoint(unit, P2, dodgeradius)
                                                                        elseif skillshotArray[i].type == 3 then
                                                                                skillshotArray[i].skillshotpoint = calculateLineaoe(unit, P2, maxdist)
                                                                                if skillshotArray[i].name ~= "SummonerClairvoyance" then
                                                                                        dodgeaoe(unit, P2, dodgeradius)
                                                                                end
                                                                        elseif skillshotArray[i].type == 4 then
                                                                                                                                skillshotArray[i].px = unit.x + (maxdist)/calc*(P2.x-unit.x)
                                                                                                                                skillshotArray[i].py = P2.y
                                                                                                                                skillshotArray[i].pz = unit.z + (maxdist)/calc*(P2.z-unit.z)
                                                                                dodgelinepass(unit, P2, dodgeradius, maxdist)
                                                                        elseif skillshotArray[i].type == 5 then
                                                                                skillshotArray[i].skillshotpoint = calculateLineaoe2(unit, P2, maxdist)
                                                                                dodgeaoe(unit, P2, dodgeradius)
                                                                        end
                                                                end
                                                        end
                                                end
                                                elseif spell.name == W then
                                                if spellDmg[unit.name] and getDmg("W",myHero,unit)~=nil and getDmg("W",myHero,unit) > myHero.health then
                                               
                                                        for i=1, #skillshotArray, 1 do
                                                                local maxdist
                                                                local dodgeradius
                                                                dodgeradius = skillshotArray[i].radius
                                                                maxdist = skillshotArray[i].maxdistance
                                                                if spell.name == skillshotArray[i].name then
                                                                        skillshotArray[i].shot = 1
                                                                        skillshotArray[i].lastshot = os.clock()
                                                                        if skillshotArray[i].type == 1 then
                                                                                                                                skillshotArray[i].p1x = unit.x
                                                                                                                                skillshotArray[i].p1y = unit.y
                                                                                                                                skillshotArray[i].p1z = unit.z
                                                                                                                                skillshotArray[i].p2x = unit.x + (maxdist)/calc*(P2.x-unit.x)
                                                                                                                                skillshotArray[i].p2y = P2.y
                                                                                                                                skillshotArray[i].p2z = unit.z + (maxdist)/calc*(P2.z-unit.z)
                                                                                dodgelinepass(unit, P2, dodgeradius, maxdist)
                                                                        elseif skillshotArray[i].type == 2 then
                                                                                skillshotArray[i].px = P2.x
                                                                                                                                skillshotArray[i].py = P2.y
                                                                                                                                skillshotArray[i].pz = P2.z
                                                                                dodgelinepoint(unit, P2, dodgeradius)
                                                                        elseif skillshotArray[i].type == 3 then
                                                                                skillshotArray[i].skillshotpoint = calculateLineaoe(unit, P2, maxdist)
                                                                                if skillshotArray[i].name ~= "SummonerClairvoyance" then
                                                                                        dodgeaoe(unit, P2, dodgeradius)
                                                                                end
                                                                        elseif skillshotArray[i].type == 4 then
                                                                                                                                skillshotArray[i].px = unit.x + (maxdist)/calc*(P2.x-unit.x)
                                                                                                                                skillshotArray[i].py = P2.y
                                                                                                                                skillshotArray[i].pz = unit.z + (maxdist)/calc*(P2.z-unit.z)
                                                                                dodgelinepass(unit, P2, dodgeradius, maxdist)
                                                                        elseif skillshotArray[i].type == 5 then
                                                                                skillshotArray[i].skillshotpoint = calculateLineaoe2(unit, P2, maxdist)
                                                                                dodgeaoe(unit, P2, dodgeradius)
                                                                        end
                                                                end
                                                        end
                                                end
                                                elseif spell.name == E then
                                                if spellDmg[unit.name] and getDmg("E",myHero,unit)~=nil and getDmg("E",myHero,unit) > myHero.health then
                                               
                                                        for i=1, #skillshotArray, 1 do
                                                                local maxdist
                                                                local dodgeradius
                                                                dodgeradius = skillshotArray[i].radius
                                                                maxdist = skillshotArray[i].maxdistance
                                                                if spell.name == skillshotArray[i].name then
                                                                        skillshotArray[i].shot = 1
                                                                        skillshotArray[i].lastshot = os.clock()
                                                                        if skillshotArray[i].type == 1 then
                                                                                                                                skillshotArray[i].p1x = unit.x
                                                                                                                                skillshotArray[i].p1y = unit.y
                                                                                                                                skillshotArray[i].p1z = unit.z
                                                                                                                                skillshotArray[i].p2x = unit.x + (maxdist)/calc*(P2.x-unit.x)
                                                                                                                                skillshotArray[i].p2y = P2.y
                                                                                                                                skillshotArray[i].p2z = unit.z + (maxdist)/calc*(P2.z-unit.z)
                                                                                dodgelinepass(unit, P2, dodgeradius, maxdist)
                                                                        elseif skillshotArray[i].type == 2 then
                                                                                skillshotArray[i].px = P2.x
                                                                                                                                skillshotArray[i].py = P2.y
                                                                                                                                skillshotArray[i].pz = P2.z
                                                                                dodgelinepoint(unit, P2, dodgeradius)
                                                                        elseif skillshotArray[i].type == 3 then
                                                                                skillshotArray[i].skillshotpoint = calculateLineaoe(unit, P2, maxdist)
                                                                                if skillshotArray[i].name ~= "SummonerClairvoyance" then
                                                                                        dodgeaoe(unit, P2, dodgeradius)
                                                                                end
                                                                        elseif skillshotArray[i].type == 4 then
                                                                                                                                skillshotArray[i].px = unit.x + (maxdist)/calc*(P2.x-unit.x)
                                                                                                                                skillshotArray[i].py = P2.y
                                                                                                                                skillshotArray[i].pz = unit.z + (maxdist)/calc*(P2.z-unit.z)
                                                                                dodgelinepass(unit, P2, dodgeradius, maxdist)
                                                                        elseif skillshotArray[i].type == 5 then
                                                                                skillshotArray[i].skillshotpoint = calculateLineaoe2(unit, P2, maxdist)
                                                                                dodgeaoe(unit, P2, dodgeradius)
                                                                        end
                                                                end
                                                        end
                                                end
                                                elseif spell.name == R then
                                                if spellDmg[unit.name] and getDmg("R",myHero,unit)~=nil and getDmg("R",myHero,unit) > myHero.health then
                                               
                                                        for i=1, #skillshotArray, 1 do
                                                                local maxdist
                                                                local dodgeradius
                                                                dodgeradius = skillshotArray[i].radius
                                                                maxdist = skillshotArray[i].maxdistance
                                                                if spell.name == skillshotArray[i].name then
                                                                        skillshotArray[i].shot = 1
                                                                        skillshotArray[i].lastshot = os.clock()
                                                                        if skillshotArray[i].type == 1 then
                                                                                                                                skillshotArray[i].p1x = unit.x
                                                                                                                                skillshotArray[i].p1y = unit.y
                                                                                                                                skillshotArray[i].p1z = unit.z
                                                                                                                                skillshotArray[i].p2x = unit.x + (maxdist)/calc*(P2.x-unit.x)
                                                                                                                                skillshotArray[i].p2y = P2.y
                                                                                                                                skillshotArray[i].p2z = unit.z + (maxdist)/calc*(P2.z-unit.z)
                                                                                dodgelinepass(unit, P2, dodgeradius, maxdist)
                                                                        elseif skillshotArray[i].type == 2 then
                                                                                skillshotArray[i].px = P2.x
                                                                                                                                skillshotArray[i].py = P2.y
                                                                                                                                skillshotArray[i].pz = P2.z
                                                                                dodgelinepoint(unit, P2, dodgeradius)
                                                                        elseif skillshotArray[i].type == 3 then
                                                                                skillshotArray[i].skillshotpoint = calculateLineaoe(unit, P2, maxdist)
                                                                                if skillshotArray[i].name ~= "SummonerClairvoyance" then
                                                                                        dodgeaoe(unit, P2, dodgeradius)
                                                                                end
                                                                        elseif skillshotArray[i].type == 4 then
                                                                                                                                skillshotArray[i].px = unit.x + (maxdist)/calc*(P2.x-unit.x)
                                                                                                                                skillshotArray[i].py = P2.y
                                                                                                                                skillshotArray[i].pz = unit.z + (maxdist)/calc*(P2.z-unit.z)
                                                                                dodgelinepass(unit, P2, dodgeradius, maxdist)
                                                                        elseif skillshotArray[i].type == 5 then
                                                                                skillshotArray[i].skillshotpoint = calculateLineaoe2(unit, P2, maxdist)
                                                                                dodgeaoe(unit, P2, dodgeradius)
                                                                        end
                                                                end
                                                        end
                                                end
                                               
                                        end
                               
                                end
                        end
                end
        end
 
end
 
function zhonyas()
        if GetInventorySlot(3157)~=nil then
                k = GetInventorySlot(3157)
                CastSpellTarget(tostring(k),myHero)
        elseif GetInventorySlot(3090)~=nil then
                k = GetInventorySlot(3090)
                CastSpellTarget(tostring(k),myHero)
        end
end
 
 ------------------------------------------------------ Check If In Spell Stuff
 
function dodgeaoe(pos1, pos2, radius)
    local calc = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
    if calc < radius then
               
                                zhonyas()
                                      --  CastSummonerBarrier()
                                      --  CastSummonerHeal()
    end
end

function dodgelinepoint(pos1, pos2, radius)
    local calc1 = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
    local calc2 = (math.floor(math.sqrt((pos1.x-myHero.x)^2 + (pos1.z-myHero.z)^2)))
    local calc4 = (math.floor(math.sqrt((pos1.x-pos2.x)^2 + (pos1.z-pos2.z)^2)))
    local calc3
    local perpendicular
    local k
    local x4
    local z4
    perpendicular = (math.floor((math.abs((pos2.x-pos1.x)*(pos1.z-myHero.z)-(pos1.x-myHero.x)*(pos2.z-pos1.z)))/(math.sqrt((pos2.x-pos1.x)^2 + (pos2.z-pos1.z)^2))))
    k = ((pos2.z-pos1.z)*(myHero.x-pos1.x) - (pos2.x-pos1.x)*(myHero.z-pos1.z)) / ((pos2.z-pos1.z)^2 + (pos2.x-pos1.x)^2)
        x4 = myHero.x - k * (pos2.z-pos1.z)
        z4 = myHero.z + k * (pos2.x-pos1.x)
        calc3 = (math.floor(math.sqrt((x4-myHero.x)^2 + (z4-myHero.z)^2)))
    if perpendicular < radius and calc1 < calc4 and calc2 < calc4 then
       
                                zhonyas()
                                     --   CastSummonerBarrier()
                                     --   CastSummonerHeal()
    end
end
 
function dodgelinepass(pos1, pos2, radius, maxDist)
        local pm2x = pos1.x + (maxDist)/(math.floor(math.sqrt((pos1.x-pos2.x)^2 + (pos1.z-pos2.z)^2)))*(pos2.x-pos1.x)
    local pm2z = pos1.z + (maxDist)/(math.floor(math.sqrt((pos1.x-pos2.x)^2 + (pos1.z-pos2.z)^2)))*(pos2.z-pos1.z)
    local calc1 = (math.floor(math.sqrt((pm2x-myHero.x)^2 + (pm2z-myHero.z)^2)))
    local calc2 = (math.floor(math.sqrt((pos1.x-myHero.x)^2 + (pos1.z-myHero.z)^2)))
    local calc3
    local calc4 = (math.floor(math.sqrt((pos1.x-pm2x)^2 + (pos1.z-pm2z)^2)))
    local perpendicular
    local k
    local x4
    local z4
    perpendicular = (math.floor((math.abs((pm2x-pos1.x)*(pos1.z-myHero.z)-(pos1.x-myHero.x)*(pm2z-pos1.z)))/(math.sqrt((pm2x-pos1.x)^2 + (pm2z-pos1.z)^2))))
    k = ((pm2z-pos1.z)*(myHero.x-pos1.x) - (pm2x-pos1.x)*(myHero.z-pos1.z)) / ((pm2z-pos1.z)^2 + (pm2x-pos1.x)^2)
        x4 = myHero.x - k * (pm2z-pos1.z)
        z4 = myHero.z + k * (pm2x-pos1.x)
        calc3 = (math.floor(math.sqrt((x4-myHero.x)^2 + (z4-myHero.z)^2)))
    if perpendicular < radius and calc1 < calc4 and calc2 < calc4 then
               
                                zhonyas()
                                     --   CastSummonerBarrier()
                                     --   CastSummonerHeal()
    end
end
 
function calculateLineaoe(pos1, pos2, maxDist)
    local line = {}
    local point = {}
    point.x = pos2.x
    point.y = pos2.y
    point.z = pos2.z
    table.insert(line, point)
    return line
end
 
function calculateLineaoe2(pos1, pos2, maxDist)
        local calc = (math.floor(math.sqrt((pos2.x-pos1.x)^2 + (pos2.z-pos1.z)^2)))
    local line = {}
    local point = {}
    if calc < maxDist then
    point.x = pos2.x
    point.y = pos2.y
    point.z = pos2.z
    table.insert(line, point)
    else
    point.x = pos1.x + maxDist/calc*(pos2.x-pos1.x)
        point.z = pos1.z + maxDist/calc*(pos2.z-pos1.z)
        point.y = pos2.y
        table.insert(line, point)
        end
    return line
end
 
function calculateLinepoint(pos1, pos2, spacing, maxDist)
        local line = {}
        local point1 = {}
        point1.x = pos1.x
  point1.y = pos1.y
  point1.z = pos1.z
        local point2 = {}
        point1.x = pos2.x
  point1.y = pos2.y
  point1.z = pos2.z
                                table.insert(line, point2)
        table.insert(line, point1)
    return line
end
 
------------------------------END Spell Callback Stuff
 

--[[function ignite()
	if myHero.SummonerD == "SummonerDot" then
			ignitedamage = ((myHero.selflevel*20)+50)*IsSpellReady("D")
	elseif myHero.SummonerF == "SummonerDot" then
					ignitedamage = ((myHero.selflevel*20)+50)*IsSpellReady("F")
	else
			ignitedamage=0
	end
end--]]

function C()
	if target~=nil then
		if GetD(target)<650 and RRDY==1 and VeigConfig.ks and target.health<getDmg("R",target,myHero)*RRDY and target.health>=getDmg("AD",target,myHero) and target.health>=getDmg("Q",target,myHero)*QRDY then
			CastSpellTarget("R",target)
		end
		
		
		if ERDY==1 and GetD(target)<850 then
			E(target)
		elseif WRDY==1 and GetD(target)<850 and checkStunned(target)==true then
			local pos=GetMEC(110,900,target)
			if pos~=nil and pos.x~=nil then
				CastSpellXYZ("W",pos.x,0,pos.z)
			else
				CastSpellXYZ("W",GetFireahead(target,2,0))
			end
		end
		if GetInventorySlot(3128)~=nil and myHero["SpellTime"..GetInventorySlot(3128)]>1.0 and GetD(target)<600 then
            CastSpellTarget(tostring(GetInventorySlot(3128)),target)
		end
		if QRDY==1 and GetD(target)<650 then
			CastSpellTarget("Q",target)
		elseif RRDY==1 and VeigConfig.ult and GetD(target)<650 then
			CastSpellTarget("R",target)
		end
		if WRDY==1 and VeigConfig.OS and GetD(twfa)<900 then
			CastSpellXYZ("W",twfx,0,twfz)
		else
			AttackTarget(target)
		end
	else
		MoveToMouse()
		
	end
end

function E(enemy)
	if enemy~=nil then
	local var=VeigConfig.spm
	local fa=VeigConfig.sfa
	local tfx,tfy,tfz=GetFireahead(enemy,fa,0)
	local targf = {x=tfx,y=tfy,z=tfz}
	local dist=GetD(targf,myHero)
			if tfx==myHero.x then
					tx = tfx
					if tfz>myHero.z then
							tz = tfz-340*var
					else
							tz = tfz+(340*var)
					end
		   
			elseif tfz==myHero.z then
					tz = tfz
					if tfx>myHero.x then
							tx = tfx-(340*var)
					else
							tx = tfx+(340*var)
					end
		   
			elseif tfx>myHero.x then
					angle = math.asin((tfx-myHero.x)/dist)
					zs = (340*var)*math.cos(angle)
					xs = (340*var)*math.sin(angle)
					if tfz>myHero.z then
							tx = tfx-xs
							tz = tfz-zs
					elseif tfz<myHero.z then
							tx = tfx-xs
							tz = tfz+zs
					end
		   
			elseif tfx<myHero.x then
					angle = math.asin((myHero.x-tfx)/dist)
					zs = (340*var)*math.cos(angle)
					xs = (340*var)*math.sin(angle)
					if tfz>myHero.z then
							tx = tfx+xs
							tz = tfz-zs
					elseif tfz<myHero.z then
							tx = tfx+xs
							tz = tfz+zs
					end 
			end
			CastSpellXYZ("E",tx,tfy,tz)
	end
end

function multipleStun(self)
        local count=0
        for i=1, objManager:GetMaxHeroes(), 1 do
                hero = objManager:GetHero(i)
                if hero~=nil and hero.team~=myHero.team and hero.visible==1 and GetD(self,hero)<420 then
                        count=count+1
                        --table.insert(enemies,hero)
                end
        end
        if count>1 then
                return true
        elseif count==1 then
                return false
        else
                return nil
        end
end

function Stun()
	if closestEnemy~=nil and ERDY==1 then
		if multipleStun(closestEnemy)==true then
			local pos=GetMEC(212,650,closestEnemy)
			if pos~=nil and pos.x~=nil then
			CastSpellXYZ("E", pos.x,0,pos.z)
			else
			E(closestEnemy)
			end
		else
			E(closestEnemy)
		end
		MoveToMouse()
	else
		MoveToMouse()
	end

end

function Harass()
	CustomCircle(range,2,4,myHero)
	if target~=nil then
		
		if GetD(target)<850 and ERDY==1 and WRDY==1 then
			local pos=GetMEC(110,900,target)
			if pos~=nil and pos.x~=nil then
				CastSpellXYZ("W",pos.x,0,pos.z)
			else
				CastSpellXYZ("W",GetFireahead(target,2,0))
			end
		end
		if GetD(target)<850 and ERDY==1 and WTimer+2>os.clock() then
			E(target)
		end
                Action2(target)
                Action(target)
			AttackTarget(target)
		
	else
		MoveToMouse()
	end
end


function farm()
        CustomCircle(range,2,4,myHero)
        if GetLowestHealthEnemyMinion(range) ~= nil then
        targetminion = GetLowestHealthEnemyMinion(range) end
        if targetminion ~= nil and targetminion.dead==0 then
                        if getDmg("Q",targetminion,myHero)*QRDY>=targetminion.health then
                                Action2(targetminion)
                        end
                        if getDmg("AD",targetminion,myHero)>=targetminion.health then
                                Action(targetminion)
                        end
                        MoveToMouse()
                else
                        MoveToMouse()
                end
 
end
 
 
function farm2()
        CustomCircle(range,2,4,myHero)
                       
        if targetrange ~= nil then
				if QRDY==1 then CastSpellTarget("Q",targetrange) end
                Action(targetrange)
        else targetminion = GetLowestHealthEnemyMinion(range)
        end
        if targetminion ~= nil and targetminion.dead==0 then
				if getDmg("Q",targetminion,myHero)*QRDY>=targetminion.health then
						Action2(targetminion)
				end
				if getDmg("AD",targetminion,myHero)>=targetminion.health then
						Action(targetminion)
				end
                MoveToMouse()
        else
                MoveToMouse()
        end
 
end

------------------------------------Orb
function Action(ttt)
        if timeToShoot() then
            attackEnemy(ttt)
                        CustomCircle(100,10,1,ttt)
        else
                        CustomCircle(100,5,2,ttt)
            if heroCanMove() then MoveToMouse() end
        end
end
 
function attackEnemy(yyy)
        if ValidTarget(yyy) then
        AttackTarget(yyy)
        shotFired = true
        end
end
 
function GetNextAttackTime()
return lastAttack + 275 / GetAttackSpeed()
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
 

function isMoving(unitM)
	local mx,my,mz=GetFireahead(unitM,5,0)
	if math.abs(mx-unitM.x)<20 and math.abs(mz-unitM.z)<20 then
		return false
	else
		return true
	end
end

function Action2(ttt)
        if QRDY==1 then
            attackEnemy2(ttt)
                        CustomCircle(100,10,1,ttt)
        else
                        CustomCircle(100,5,2,ttt)
            if heroCanMove2() then MoveToMouse() end
        end
end
 
function attackEnemy2(yyy)
        if ValidTarget(yyy) then
        CastSpellTarget("Q",yyy)
        shotFired2 = true
        end
end
 
function heroCanMove2()
    if shotFired2 == false or QRDY==1 then
        return true
    end
    return false
end

---------------------------------------END of ORB
function runningAway(slowtarget)
   local d1 = GetD(slowtarget)
   local x, y, z = GetFireahead(slowtarget,5,0)
   local d2 = GetD({x=x, y=y, z=z})
   local d3 = GetD({x=x, y=y, z=z},slowtarget)
   local angle = math.acos((d2*d2-d3*d3-d1*d1)/(-2*d3*d1))
   
   return angle%(2*math.pi)>math.pi/2 and angle%(2*math.pi)<math.pi*3/2
 
end

function killsteal()
	if targetrange~=nil then
		local RR=getDmg("R",targetrange,myHero)*RRDY
		local QQ=getDmg("Q",targetrange,myHero)*QRDY
		local WW=getDmg("W",targetrange,myHero)*WRDY
		
		
		if targetrange.health<QQ then
			CastSpellTarget("Q",targetrange)
		
		elseif targetrange.health<(QQ+WW)*ERDY then
			local pos=GetMEC(110,900,targetrange)
			if pos~=nil and pos.x~=nil then
				CastSpellXYZ("W",pos.x,0,pos.z)
			else
				CastSpellXYZ("W",GetFireahead(targetrange,1,0))
			end
			E(targetrange)			
			CastSpellTarget("Q",targetrange)
			
		elseif targetrange.health<QQ+RR then
			CastSpellTarget("Q",targetrange)
			CastSpellTarget("R",targetrange)
			
		end
	end

end


function OnCreateObj(obj)
	if obj~=nil and obj.x~=nil and GetD(obj)<250 and (string.find(obj.charName,"permission_basicAttack_mis")or  string.find(obj.charName,"permission_critAttack_mis")  or  string.find(obj.charName,"permission_Shadowbolt_mis")) then
			shotFired = false
			shotFired2 = false
			lastAttack = GetTickCount()
	end
	if obj~=nil and obj.x~=nil and GetD(obj)<900 and (string.find(obj.charName,"LOC_Stun") or string.find(obj.charName,"LOC_Suppress") or string.find(obj.charName,"LOC_Taunt") or string.find(obj.charName,"LOC_fear") or string.find(obj.charName,"Global_Stun") or string.find(obj.charName,"Ahri_Charm_buf") or string.find(obj.charName,"CurseBandages") or string.find(obj.charName,"CurseBandages") or string.find(obj.charName,"leBlanc_shackle_tar_blood") or string.find(obj.charName,"LuxLightBinding") or string.find(obj.charName,"DarkBinding_tar") or string.find(obj.charName,"RunePrison") or string.find(obj.charName,"UnstoppableForce_stun") or string.find(obj.charName,"VarusRHit") or string.find(obj.charName,"Zyra_E_sequence_root") or string.find(obj.charName,"Stun_glb") or string.find(obj.charName,"Global_Fear") or string.find(obj.charName,"AlZaharNetherGrasp_tar") or string.find(obj.charName,"Global_Taunt") or string.find(obj.charName,"LuxLightBinding_tar") or string.find(obj.charName,"leBlanc_shackle_tar") or string.find(obj.charName,"RunePrison_tar") or string.find(obj.charName,"InfiniteDuress_tar") or string.find(obj.charName,"DarkBinding_tar") or string.find(obj.charName,"Amumu_SadRobot_Ultwrap") or string.find(obj.charName,"Amumu_Ultwrap") or string.find(obj.charName,"maokai_elementalAdvance_root_01") or string.find(obj.charName,"RengarEMax_tar") or string.find(obj.charName,"Fizz_UltimateMissle_Orbit") or string.find(obj.charName,"Fizz_UltimateMissle_Orbit_Lobster") or string.find(obj.charName,"VarusRHitFlash")) then
		--print("\nName "..obj.charName)
		for i, enemy in pairs(enemies) do
			if enemy~=nil and enemy.unit~=nil and enemy.unit.dead~=1 and math.abs(enemy.unit.x-obj.x)<50 and math.abs(enemy.unit.z-obj.z)<50 then
					--print("\n  Checking\n")
					if WRDY==1 and (VeigConfig.AW or ((VeigConfig.h or VeigConfig.Combo) and target~=nil and enemy.name==target.name)) and GetD(enemy)<850 then
						local pos=GetMEC(110,900,enemy)
						if pos~=nil and pos.x~=nil then
							CastSpellXYZ("W",pos.x,0,pos.z)
						else
							CastSpellXYZ("W",GetFireahead(enemy,2,0))
						end
					end					
					enemy.stunned=1
					enemy.stunTimer=os.clock()+2
			end
		end
	end
	if obj.charName == 'EggTimer.troy' then
		for i= 1,objManager:GetMaxHeroes(),1 do
			local hero=objManager:GetHero(i)
			if hero.name == 'Anivia' and GetDistance(obj, hero) < 10 then
				if hero.team == myHero.team then egg = {team = GetTickCount(), enemy = egg.enemy}
				else egg = {team = egg.team, enemy = GetTickCount()} end
				break
			end
		end
	elseif obj.charName == 'Aatrox_Passive_Death_Activate.troy' then
		for i= 1,objManager:GetMaxHeroes(),1 do
			local hero=objManager:GetHero(i)
			if hero.name == 'Aatrox' and GetDistance(obj, hero) < 10 then
				if hero.team == myHero.team then aatrox = {team = GetTickCount(), enemy = aatrox.enemy}
				else aatrox = {team = aatrox.team, enemy = GetTickCount()} end
				break
			end
		end
	elseif obj.charName == 'ZacPassiveExplosion.troy' then
		for i= 1,objManager:GetMaxHeroes(),1 do
			local hero=objManager:GetHero(i)
			if hero.name == 'Zac' and GetDistance(obj, hero) < 10 then
				if hero.team == myHero.team then zac = {team = GetTickCount(), enemy = zac.enemy}
				else zac = {team = zac.team, enemy = GetTickCount()} end
				break
			end
		end
	end

end

function OnDraw()
	if myHero.dead~=1 then
		if QRDY==1  then
			CustomCircle(645,15,1,myHero)
		end
		if  ERDY==1  then
			CustomCircle(650,15,3,myHero)
		end
		if RRDY==1 then
			CustomCircle(655,15,2,myHero)
		end
		if WRDY==1 then
			CustomCircle(1000,15,2,myHero)
		end
		
		if target~=nil then
			CustomCircle(120,15,5,target)
		end
		
		if VeigConfig.f and targetrange~=nil then
			CustomCircle(GetD(targetrange),4,5,myHero)
		elseif VeigConfig.f and targetminion~=nil then
			CustomCircle(GetD(targetminion),4,5,myHero)
		end
	end
end



function GetD(p1, p2)
if p2 == nil then p2 = myHero end
if (p1.z == nil or p2.z == nil) and p1.x~=nil and p1.y ~=nil and p2.x~=nil and p2.y~=nil then
px=p1.x-p2.x
py=p1.y-p2.y
if px~=nil and py~=nil then
px2=px*px
py2=py*py
if px2~=nil and py2~=nil then
return math.sqrt(px2+py2)
else
return 99999
end
else
return 99999
end

elseif p1.x~=nil and p1.z ~=nil and p2.x~=nil and p2.z~=nil then
px=p1.x-p2.x
pz=p1.z-p2.z
if px~=nil and pz~=nil then
px2=px*px
pz2=pz*pz
if px2~=nil and pz2~=nil then
return math.sqrt(px2+pz2)
else
return 99999
end
else    
return 99999
end

else
return 99999
end
end

function LoadTable()
        --print("table loaded::")
                local iCount=objManager:GetMaxHeroes()
        --print(" heros:" .. tostring(iCount))
                        iCount=1;
                for i=0, iCount, 1 do
                        skillshotplayerObj=objManager:GetHero(i)
                        if skillshotplayerObj.name == "Ahri" then
                table.insert(skillshotArray,{name= "AhriOrbofDeception", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 880, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                table.insert(skillshotArray,{name= "AhriSeduce", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Amumu" then
                table.insert(skillshotArray,{name= "BandageToss", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Anivia" then
                table.insert(skillshotArray,{name= "FlashFrostSpell", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 90, color= colorcyan, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Ashe" then
                table.insert(skillshotArray,{name= "EnchantedCrystalArrow", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 50000, type = 4, radius = 120, color= colorcyan, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Blitzcrank" then
                table.insert(skillshotArray,{name= "RocketGrabMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Brand" then
                table.insert(skillshotArray,{name= "BrandBlazeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 50, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                table.insert(skillshotArray,{name= "BrandFissure", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Cassiopeia" then
                table.insert(skillshotArray,{name= "CassiopeiaMiasma", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 175, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "CassiopeiaNoxiousBlast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 75, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Caitlyn" then
                table.insert(skillshotArray,{name= "CaitlynEntrapmentMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 50, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "CaitlynPiltoverPeacemaker", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Corki" then
                table.insert(skillshotArray,{name= "MissileBarrageMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1225, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "MissileBarrageMissile2", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1225, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "CarpetBomb", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 2, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Chogath" then
                table.insert(skillshotArray,{name= "Rupture", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 275, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "DrMundo" then
                table.insert(skillshotArray,{name= "InfectedCleaverMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Heimerdinger" then
                table.insert(skillshotArray,{name= "CH1ConcussionGrenade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 225, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Draven" then
                table.insert(skillshotArray,{name= "DravenDoubleShot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 125, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= "DravenRCast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 20000, type = 1, radius = 100, color= colorcyan, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Ezreal" then
                table.insert(skillshotArray,{name= "EzrealEssenceFluxMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= "EzrealMysticShotMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= "EzrealTrueshotBarrage", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 50000, type = 4, radius = 150, color= colorcyan, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= "EzrealArcaneShift", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 475, type = 5, radius = 100, color= colorgreen, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Fizz" then
                table.insert(skillshotArray,{name= "FizzMarinerDoom", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1275, type = 2, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "FiddleSticks" then
                table.insert(skillshotArray,{name= "Crowstorm", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 600, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Karthus" then
                table.insert(skillshotArray,{name= "LayWaste", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 875, type = 3, radius = 150, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Galio" then
                table.insert(skillshotArray,{name= "GalioResoluteSmite", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 905, type = 3, radius = 200, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "GalioRighteousGust", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 120, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Graves" then
                table.insert(skillshotArray,{name= "GravesChargeShot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 110, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "GravesClusterShot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 750, type = 1, radius = 50, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "GravesSmokeGrenade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 3, radius = 275, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Gragas" then
                table.insert(skillshotArray,{name= "GragasBarrelRoll", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 320, color= coloryellow, time = 2.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "GragasBodySlam", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 2, radius = 60, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "GragasExplosiveCask", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 3, radius = 400, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Irelia" then
                table.insert(skillshotArray,{name= "IreliaTranscendentBlades", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 80, color= colorcyan, time = 0.8, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Janna" then
                table.insert(skillshotArray,{name= "HowlingGale", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1700, type = 1, radius = 100, color= colorcyan, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "JarvanIV" then
                table.insert(skillshotArray,{name= "JarvanIVDemacianStandard", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 830, type = 3, radius = 150, color= coloryellow, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "JarvanIVDragonStrike", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 770, type = 1, radius = 70, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "JarvanIVCataclysm", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 3, radius = 300, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Kassadin" then
                table.insert(skillshotArray,{name= "RiftWalk", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 5, radius = 150, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Katarina" then
                table.insert(skillshotArray,{name= "ShadowStep", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 3, radius = 75, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Kennen" then
                table.insert(skillshotArray,{name= "KennenShurikenHurlMissile1", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 75, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "KogMaw" then
                table.insert(skillshotArray,{name= "KogMawVoidOozeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1115, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "KogMawLivingArtillery", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2200, type = 3, radius = 200, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Leblanc" then
                table.insert(skillshotArray,{name= "LeblancSoulShackle", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "LeblancSoulShackleM", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "LeblancSlide", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "LeblancSlideM", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= "leblancslidereturn", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 50, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= "leblancslidereturnm", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 50, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "LeeSin" then
                table.insert(skillshotArray,{name= "BlindMonkQOne", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "BlindMonkRKick", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Leona" then
                table.insert(skillshotArray,{name= "LeonaZenithBladeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Lux" then
                table.insert(skillshotArray,{name= "LuxLightBinding", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1175, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "LuxLightStrikeKugel", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 300, color= coloryellow, time = 2.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "LuxMaliceCannon", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 3000, type = 1, radius = 80, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Lulu" then
                table.insert(skillshotArray,{name= "LuluQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 50, color= colorcyan, time = 1, isline = true, px =0, py =0 , pz =0, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Maokai" then
                table.insert(skillshotArray,{name= "MaokaiTrunkLineMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "MaokaiSapling2", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 350 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Malphite" then
                table.insert(skillshotArray,{name= "UFSlash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 325, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Malzahar" then
                table.insert(skillshotArray,{name= "AlZaharCalloftheVoid", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 100 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "AlZaharNullZone", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 250 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "MissFortune" then
                table.insert(skillshotArray,{name= "MissFortuneScattershot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 400, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Morgana" then
                table.insert(skillshotArray,{name= "DarkBindingMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "TormentedSoil", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 350, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Nautilus" then
                table.insert(skillshotArray,{name= "NautilusAnchorDrag", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 1, radius = 80, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Nidalee" then
                table.insert(skillshotArray,{name= "JavelinToss", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1500, type = 1, radius = 80, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Nocturne" then
                table.insert(skillshotArray,{name= "NocturneDuskbringer", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 80, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Olaf" then
                table.insert(skillshotArray,{name= "OlafAxeThrow", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 2, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Orianna" then
                table.insert(skillshotArray,{name= "OrianaIzunaCommand", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 825, type = 3, radius = 150, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Renekton" then
                table.insert(skillshotArray,{name= "RenektonSliceAndDice", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 450, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= "renektondice", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 450, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Rumble" then
                table.insert(skillshotArray,{name= "RumbleGrenadeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= "RumbleCarpetBomb", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1700, type = 1, radius = 100, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Sivir" then
                table.insert(skillshotArray,{name= "SpiralBlade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Singed" then
                table.insert(skillshotArray,{name= "MegaAdhesive", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 350, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Shen" then
                table.insert(skillshotArray,{name= "ShenShadowDash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 2, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Shaco" then
                table.insert(skillshotArray,{name= "Deceive", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 500, type = 5, radius = 100, color= colorgreen, time = 3.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Shyvana" then
                table.insert(skillshotArray,{name= "ShyvanaTransformLeap", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 80, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "ShyvanaFireballMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Skarner" then
                table.insert(skillshotArray,{name= "SkarnerFracture", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Sona" then
                table.insert(skillshotArray,{name= "SonaCrescendo", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Sejuani" then
                table.insert(skillshotArray,{name= "SejuaniGlacialPrison", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1150, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Swain" then
                table.insert(skillshotArray,{name= "SwainShadowGrasp", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 265 , color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Tryndamere" then
                table.insert(skillshotArray,{name= "Slash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 2, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Tristana" then
                table.insert(skillshotArray,{name= "RocketJump", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 200, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "TwistedFate" then
                table.insert(skillshotArray,{name= "WildCards", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1450, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Urgot" then
                table.insert(skillshotArray,{name= "UrgotHeatseekingLineMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= colorcyan, time = 0.8, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "UrgotPlasmaGrenade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 300, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Vayne" then
                table.insert(skillshotArray,{name= "VayneTumble", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 250, type = 3, radius = 100, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Varus" then
                --table.insert(skillshotArray,{name= "VarusQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1475, type = 1, radius = 50, color= coloryellow, time = 1})
                table.insert(skillshotArray,{name= "VarusR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 80, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Veigar" then
                table.insert(skillshotArray,{name= "VeigarDarkMatter", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 225, color= coloryellow, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Viktor" then
                --table.insert(skillshotArray,{name= "ViktorDeathRay", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 80, color= coloryellow, time = 2})
            end
            if skillshotplayerObj.name == "Xerath" then
                table.insert(skillshotArray,{name= "xeratharcanopulsedamage", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "xeratharcanopulsedamageextended", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= "xeratharcanebarragewrapper", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "xeratharcanebarragewrapperext", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Ziggs" then
                table.insert(skillshotArray,{name= "ZiggsQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 160, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= "ZiggsW", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 225 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= "ZiggsE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "ZiggsR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5300, type = 3, radius = 550, color= coloryellow, time = 3, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Zyra" then
                table.insert(skillshotArray,{name= "ZyraQFissure", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 825, type = 3, radius = 275, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "ZyraGraspingRoots", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 90, color= colorcyan, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if skillshotplayerObj.name == "Diana" then
                table.insert(skillshotArray,{name= "DianaArc", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 205, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
                        if skillshotplayerObj.name == "Syndra" then
                                        table.insert(skillshotArray,{name= "SyndraQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 190, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                        table.insert(skillshotArray,{name= "syndrawcast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 210, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                        skillshotcharexist = true
                        end
                        if skillshotplayerObj.name == "Khazix" then
                                        table.insert(skillshotArray,{name= "KhazixW", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 70, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                        table.insert(skillshotArray,{name= "khazixwlong", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 400, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                        table.insert(skillshotArray,{name= "KhazixE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 5, radius = 310, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                        table.insert(skillshotArray,{name= "khazixelong", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 5, radius = 310, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                        skillshotcharexist = true
                        end
                        if skillshotplayerObj.name == "Elise" then
                                        table.insert(skillshotArray,{name= "EliseHumanE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 80, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                        skillshotcharexist = true
                        end
                        if skillshotplayerObj.name == "Zed" then
                                        table.insert(skillshotArray,{name= "ZedShuriken", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 55, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                        skillshotcharexist = true
                        end
                        if skillshotplayerObj.name == "Nami" then
                                        table.insert(skillshotArray,{name= "NamiQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 875, type = 3, radius = 210, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                        table.insert(skillshotArray,{name= "NamiR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2750, type = 1, radius = 335, color= coloryellow, time = 3, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                        skillshotcharexist = true
                        end
                        if skillshotplayerObj.name == "Vi" then
                                        table.insert(skillshotArray,{name= "ViQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 725, type = 1, radius = 65, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                        skillshotcharexist = true
                        end
                        if skillshotplayerObj.name == "Thresh" then
                                        table.insert(skillshotArray,{name= "ThreshQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 70, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                        skillshotcharexist = true
                        end
                        if skillshotplayerObj.name == "Quinn" then
                                        table.insert(skillshotArray,{name= "QuinnQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1025, type = 1, radius = 150, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                        skillshotcharexist = true
                        end
                        if skillshotplayerObj.name == "Zac" then
                                        table.insert(skillshotArray,{name= "ZacE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1550, type = 5, radius = 200, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                        skillshotcharexist = true
                        end
                        if skillshotplayerObj.name == "Lissandra" then
                                        table.insert(skillshotArray,{name= "LissandraQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 725, type = 1, radius = 100, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                        table.insert(skillshotArray,{name= "LissandraE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 120, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                        skillshotcharexist = true
                        end
                end
end

require "Utils"
require 'spell_damage'
print=printtext
printtext("\nMaster JedYi\n")
printtext("\nBy Malbert\n")
printtext("\nVersion 5.6\n")

local target
local hasSheen = 0
local hasLich = 0
local hasTrinity = 0
local hasIceBorn = 0
local CLOCKM=os.clock()
local CLOCKU=os.clock()
local CLOCKT=os.clock()
local CLOCKF=os.clock()
local Wheal
local hpmarker
local ignitedamage
local mtarget
local ulting=false

local _registry = {}

--------Spell Stuff
local QRDY=0
local WRDY=0
local ERDY=0
local RRDY=0

local targetItems={3144,3153,3128,3092,3146}
--Bilgewater,BoTRK,DFG,FrostQueen,Hextech
local aoeItems={3184,3143,3180,3131,3069,3023,3290,3142}
--Entropy,Randuins,Odyns,SwordDivine,TalismanAsc,TwinShadows,TwinShadows,YoGBlade
local hydraItems={3074,3077}
--Hydra,Tiamat
 
 
local egg = {team = 0, enemy = 0}
local zac = {team = 0, enemy = 0}
local aatrox = {team = 0, enemy = 0}
local cc = 0
local skillshotArray = { 
}
local colorcyan = 0x0000FFFF
local coloryellow = 0xFFFFFF00
local colorgreen = 0xFF00FF00
local drawskillshot = false
local playerradius = 150
local skillshotcharexist = false
local dodgeskillshotkey = 74 -- dodge skillshot key J
local show_allies=0
local enemyinRange
local checkDie=false

--turret stuff

local SpawnturretR={}
local SpawnturretB={}
local TurretsR={}
local TurretsB={}
local enemyTurrets={}
local enemySpawn={}
local map = nil
printtext("\n" ..GetMap() .. "\n")


    if GetMap()==1 then 

        map = "SummonersRift"
		SpawnturretR = {"Turret_ChaosTurretShrine_A"}
		SpawnturretB = {"Turret_OrderTurretShrine_A"}
		TurretsR = {"Turret_T1_C_01_A","Turret_T1_C_02_A","Turret_T1_C_03_A","Turret_T1_C_04_A","Turret_T1_C_05_A","Turret_T1_C_06_A","Turret_T1_C_07_A","Turret_T1_L_02_A","Turret_T1_L_03_A","Turret_T1_R_02_A","Turret_T1_R_03_A"}
		TurretsB = {"Turret_T2_C_01_A","Turret_T2_C_02_A","Turret_T2_C_03_A","Turret_T2_C_04_A","Turret_T2_C_05_A","Turret_T2_L_01_A","Turret_T2_L_02_A","Turret_T2_L_03_A","Turret_T2_R_01_A","Turret_T2_R_02_A","Turret_T2_R_03_A"}

    elseif GetMap()==2 then
        map = "CrystalScar"
		SpawnturretR = {"Turret_ChaosTurretShrine_A","Turret_ChaosTurretShrine1_A"}
		SpawnturretB = {"Turret_OrderTurretShrine_A","Turret_OrderTurretShrine1_A"}
		TurretsR = {"OdinNeutralGuardian"}
		TurretsB = {"OdinNeutralGuardian"}
        
    elseif GetMap()==3 then
        map = "TwistedTreeline"
		SpawnturretR = {"Turret_ChaosTurretShrine_A"}
		SpawnturretB = {"Turret_OrderTurretShrine_A"}
		TurretsR = {"Turret_T1_R_02_A","Turret_T1_C_07_A","Turret_T1_C_06_A","Turret_T1_C_01_A","Turret_T1_L_02_A"}
		TurretsB = {"Turret_T2_L_01_A","Turret_T2_C_01_A","Turret_T2_L_02_A","Turret_T2_R_01_A","Turret_T2_R_02_A"}
        
    elseif GetMap()==0 then

	map = "ProvingGrounds" 
		SpawnturretR = {"Turret_ChaosTurretShrine_A"}
		SpawnturretB = {"Turret_OrderTurretShrine_A"}
		TurretsR = {"Turret_T1_C_07_A","Turret_T1_C_08_A","Turret_T1_C_09_A","Turret_T1_C_010_A"}
		TurretsB = {"Turret_T2_L_01_A","Turret_T2_L_02_A","Turret_T2_L_03_A","Turret_T2_L_04_A"}
	end

local turret = {}



	YiConfig = scriptConfig('Yi Config', 'Yiconfig')
	YiConfig:addParam('teamfight', 'AutoTeamFight', SCRIPT_PARAM_ONKEYDOWN, false, 84)
	YiConfig:addParam('fight', 'No Ult Fight', SCRIPT_PARAM_ONKEYDOWN, false, 88)
	YiConfig:addParam('move', 'Move To Cursor', SCRIPT_PARAM_ONKEYDOWN, false, 65)
	YiConfig:addParam('autoQ', 'AutoQ', SCRIPT_PARAM_ONKEYTOGGLE, false, 55)
	YiConfig:addParam('autoW', 'AutoWHeal', SCRIPT_PARAM_ONKEYTOGGLE, true, 56)
	YiConfig:addParam('autoE', 'AutoE', SCRIPT_PARAM_ONKEYTOGGLE, true, 57)
	YiConfig:addParam('autoQMrange', 'AutoQminionrange', SCRIPT_PARAM_ONKEYTOGGLE, false, 48)
	YiConfig:addParam("smite", "Smitesteal", SCRIPT_PARAM_ONKEYTOGGLE, true, 118)
	YiConfig:addParam('farm', 'AutoCreepFarm', SCRIPT_PARAM_ONKEYTOGGLE, false, 119)
	YiConfig:addParam('drawQ', 'DrawQsOnEnemies', SCRIPT_PARAM_ONOFF, true)
	YiConfig:addParam('autoQM3', 'AutoQminion3orLess', SCRIPT_PARAM_ONOFF, false)
	YiConfig:addParam('hTF', 'Use Heal In Combos', SCRIPT_PARAM_ONOFF, true)
	YiConfig:addParam('dokillsteal', 'Killsteal', SCRIPT_PARAM_ONOFF, true)
	YiConfig:permaShow('farm')
	YiConfig:permaShow('teamfight')
	YiConfig:permaShow('autoQ')
	YiConfig:permaShow('autoQMrange')
	YiConfig:permaShow('autoW')




function Run()
	        ------------
        if myHero.SpellTimeQ > 1.0 and GetSpellLevel('Q') > 0 and myHero.mana>=(60+10*GetSpellLevel('Q')) then
                QRDY = 1
                else QRDY = 0
        end
        if myHero.SpellTimeW > 1.0 and GetSpellLevel('W') > 0 and myHero.mana>=50 then
                WRDY = 1
                else WRDY = 0
        end
        if myHero.SpellTimeE > 1.0 and GetSpellLevel('E') > 0 then
                ERDY = 1
                else ERDY = 0
        end
        if myHero.SpellTimeR > 1.0 and GetSpellLevel('R') > 0 and myHero.mana>=100 then
                RRDY = 1
        else RRDY = 0 end
        --------------------------
	
	if cc<40 then cc=cc+1 end
	if (cc==30) then
		LoadTable()
	end
	for i=1, #skillshotArray, 1 do 
		if os.clock() > (skillshotArray[i].lastshot + skillshotArray[i].time) then
        	skillshotArray[i].shot = 0
    	end
    end
	
	
	target = GetBestEnemy('PHYS',700)
	targetQharass = GetBestEnemy('PHYS',1200)
	local w1 = (10+(20*GetSpellLevel('W'))+(myHero.ap*0.3))
	local w2 = w1*2
	local w3 = w1*3
	Wheal = (4*w1+w1*(1-myHero.health/myHero.maxHealth)+w1*(1-(myHero.health+w1)/myHero.maxHealth)+w1*(1-(myHero.health+w2)/myHero.maxHealth)+w1*(1-(myHero.health+w3)/myHero.maxHealth))*WRDY
	hpmarker = ((myHero.health+Wheal)/myHero.maxHealth) *39/160*GetScreenX()
	
	
	enemyInRange = GetBestEnemy('PHYS',800)

	ignite()
	
	if YiConfig.farm and not isMed() then autofarm() end
        if YiConfig.smite then smitesteal() end
	if IsChatOpen()==0 and YiConfig.teamfight then fight() end
	if IsChatOpen()==0 and YiConfig.fight then fightNoUlt() end
	if IsChatOpen()==0 and YiConfig.move then Move() end
	if YiConfig.autoE and not isMed() then autoEattack() end
	if YiConfig.autoW and not YiConfig.teamfight and not YiConfig.fight then autohealW() end
	if YiConfig.autoQ then autoQ() end
	if YiConfig.autoQMrange then autoQM() end
	if YiConfig.dokillsteal then killsteal() end
	if GetInventorySlot(3057)~=nil then 
	hasSheen = 1 
	else
	hasSheen = 0
	end
	if GetInventorySlot(3100)~=nil then 
	hasLich = 1 
	else
	hasLich = 0
	end
	if GetInventorySlot(3025)~=nil then 
	hasIceBorn = 1 
	else
	hasIceBorn = 0
	end
	if GetInventorySlot(3087)~=nil then 
	hasTrinity = 1 
	else
	hasTrinity = 0
	end
end

function OnCreateObj(obj)

		if obj ~= nil and GetD(obj,myHero)<10 then

		local s =obj.charName
            if s~=nil and string.find(s,"teleportarrive") ~= nil then    
                if (obj.x == myHero.x) and (obj.z == myHero.z) then
				CLOCKF=os.clock()
				--printtext("\n"..CLOCKF.."\n")   
                end
			end 
   
		end
		if obj.charName == 'EggTimer.troy' then
            for i= 1,objManager:GetMaxHeroes(),1 do
                local hero=objManager:GetHero(i)
                if hero.name == 'Anivia' and GetDistance(obj, hero) < 10 then
                    if hero.team == myHero.team then egg = {team = GetTickCount(), enemy = egg.enemy}
                    else egg = {team = egg.team, enemy = GetTickCount()} end
                    break
                end
            end
        elseif obj.charName == 'Aatrox_Passive_Death_Activate.troy' then
            for i= 1,objManager:GetMaxHeroes(),1 do
                local hero=objManager:GetHero(i)
                if hero.name == 'Aatrox' and GetDistance(obj, hero) < 10 then
                    if hero.team == myHero.team then aatrox = {team = GetTickCount(), enemy = aatrox.enemy}
                    else aatrox = {team = aatrox.team, enemy = GetTickCount()} end
                    break
                end
            end
        elseif obj.charName == 'ZacPassiveExplosion.troy' then
            for i= 1,objManager:GetMaxHeroes(),1 do
                local hero=objManager:GetHero(i)
                if hero.name == 'Zac' and GetDistance(obj, hero) < 10 then
                    if hero.team == myHero.team then zac = {team = GetTickCount(), enemy = zac.enemy}
                    else zac = {team = zac.team, enemy = GetTickCount()} end
                    break
                end
            end
        end
	end


function OnProcessSpell(unit, spell)

	if unit.team==myHero.team and unit.name ==myHero.name then
	--printtext("\nS "..spell.name.."\n")        
		local s=spell.name
        if (s ~= nil) then
            if string.find(s,"Meditate") ~= nil then    
           
				CLOCKM=os.clock()
				--printtext("\n"..CLOCKM.."\n")   
                
			
            elseif string.find(s,"Highlander") ~= nil then    
                

				--printtext("\n"..CLOCKM.."\n")   
                
			
			elseif string.find(s,"Recall") ~= nil then    
             
				CLOCKT=os.clock()
				--printtext("\n"..CLOCKT.."\n")   
                
			end
        end

	else
local Q
local W
local E
local R
	if unit~= nil then
		Q = unit.SpellNameQ
		W = unit.SpellNameW
		E = unit.SpellNameE
		R = unit.SpellNameR
	end
		if checkDie==true then
			if unit~= nil and unit.name~="Worm" and spell ~= nil and unit.team ~= myHero.team and spell.target~=nil and spell.target.name~=nil and spell.target.name == myHero.name then
			--print("\nI: " .. spell.target.name .. "  S " .. spell.name .. "\n Q " .. Q.. "  W " .. W .. "  E " .. E .. "  R " .. R)
			--print("\nB: " .. unit.name)
    		if spell.name == Q then
				if spellDmg[unit.name] and getDmg("Q",myHero,unit)~=nil and getDmg("Q",myHero,unit) > myHero.health then
					CastSummonerBarrier()
					CastSummonerHeal()
				end
    		
			elseif spell.name == W then
        		if spellDmg[unit.name] and getDmg("W",myHero,unit)~=nil and getDmg("W",myHero,unit) > myHero.health then
					CastSummonerBarrier()
					CastSummonerHeal()
				end
    		
			elseif spell.name == E then
    			if spellDmg[unit.name] and getDmg("E",myHero,unit)~=nil and getDmg("E",myHero,unit) > myHero.health then
					CastSummonerBarrier()
					CastSummonerHeal()
        		end

			elseif spell.name == R then
        		if spellDmg[unit.name] and getDmg("R",myHero,unit)~=nil and getDmg("R",myHero,unit) > myHero.health then
					CastSummonerBarrier()
					CastSummonerHeal()
        		end
    		
			elseif spell.name:find("BasicAttack") or spell.name:find("BasicAttack2") or spell.name:find("BasicaAttack3")  or spell.name:find("ChaosTurretFire") then
        		if (unit.baseDamage + unit.addDamage) > myHero.health then
					CastSummonerBarrier()
					CastSummonerHeal()
				end	
			elseif spell.name:find("CritAttack") then
        		if 2*(unit.baseDamage + unit.addDamage) > myHero.health then
					CastSummonerBarrier()
					CastSummonerHeal()
				end
        	end
    
		end


	

		local P1 = spell.startPos
		local P2 = spell.endPos
		local calc = (math.floor(math.sqrt((P2.x-unit.x)^2 + (P2.z-unit.z)^2)))
    if string.find(unit.name,"Minion_") == nil and string.find(unit.name,"Turret_") == nil then
        if (unit.team ~= myHero.team or (show_allies==1)) and string.find(spell.name,"Basic") == nil then

		if spell.name == Q then
    	if spellDmg[unit.name] and getDmg("Q",myHero,unit)~=nil and getDmg("Q",myHero,unit) > myHero.health then
		
            for i=1, #skillshotArray, 1 do
            local maxdist
            local dodgeradius
            dodgeradius = skillshotArray[i].radius
            maxdist = skillshotArray[i].maxdistance
                if spell.name == skillshotArray[i].name then
                    skillshotArray[i].shot = 1
                    skillshotArray[i].lastshot = os.clock()
                    if skillshotArray[i].type == 1 then
												skillshotArray[i].p1x = unit.x
												skillshotArray[i].p1y = unit.y
												skillshotArray[i].p1z = unit.z 
												skillshotArray[i].p2x = unit.x + (maxdist)/calc*(P2.x-unit.x)
												skillshotArray[i].p2y = P2.y
												skillshotArray[i].p2z = unit.z + (maxdist)/calc*(P2.z-unit.z)
                        dodgelinepass(unit, P2, dodgeradius, maxdist)
                    elseif skillshotArray[i].type == 2 then
                        skillshotArray[i].px = P2.x
												skillshotArray[i].py = P2.y
												skillshotArray[i].pz = P2.z
                        dodgelinepoint(unit, P2, dodgeradius)
                    elseif skillshotArray[i].type == 3 then
                        skillshotArray[i].skillshotpoint = calculateLineaoe(unit, P2, maxdist)
                        if skillshotArray[i].name ~= "SummonerClairvoyance" then
                            dodgeaoe(unit, P2, dodgeradius)
                        end
                    elseif skillshotArray[i].type == 4 then
												skillshotArray[i].px = unit.x + (maxdist)/calc*(P2.x-unit.x)
												skillshotArray[i].py = P2.y
												skillshotArray[i].pz = unit.z + (maxdist)/calc*(P2.z-unit.z)
                        dodgelinepass(unit, P2, dodgeradius, maxdist)
                    elseif skillshotArray[i].type == 5 then
                        skillshotArray[i].skillshotpoint = calculateLineaoe2(unit, P2, maxdist)
                        dodgeaoe(unit, P2, dodgeradius)
                    end
                end
            end
        end
		elseif spell.name == W then
    	if spellDmg[unit.name] and getDmg("W",myHero,unit)~=nil and getDmg("W",myHero,unit) > myHero.health then
		
            for i=1, #skillshotArray, 1 do
            local maxdist
            local dodgeradius
            dodgeradius = skillshotArray[i].radius
            maxdist = skillshotArray[i].maxdistance
                if spell.name == skillshotArray[i].name then
                    skillshotArray[i].shot = 1
                    skillshotArray[i].lastshot = os.clock()
                    if skillshotArray[i].type == 1 then
												skillshotArray[i].p1x = unit.x
												skillshotArray[i].p1y = unit.y
												skillshotArray[i].p1z = unit.z 
												skillshotArray[i].p2x = unit.x + (maxdist)/calc*(P2.x-unit.x)
												skillshotArray[i].p2y = P2.y
												skillshotArray[i].p2z = unit.z + (maxdist)/calc*(P2.z-unit.z)
                        dodgelinepass(unit, P2, dodgeradius, maxdist)
                    elseif skillshotArray[i].type == 2 then
                        skillshotArray[i].px = P2.x
												skillshotArray[i].py = P2.y
												skillshotArray[i].pz = P2.z
                        dodgelinepoint(unit, P2, dodgeradius)
                    elseif skillshotArray[i].type == 3 then
                        skillshotArray[i].skillshotpoint = calculateLineaoe(unit, P2, maxdist)
                        if skillshotArray[i].name ~= "SummonerClairvoyance" then
                            dodgeaoe(unit, P2, dodgeradius)
                        end
                    elseif skillshotArray[i].type == 4 then
												skillshotArray[i].px = unit.x + (maxdist)/calc*(P2.x-unit.x)
												skillshotArray[i].py = P2.y
												skillshotArray[i].pz = unit.z + (maxdist)/calc*(P2.z-unit.z)
                        dodgelinepass(unit, P2, dodgeradius, maxdist)
                    elseif skillshotArray[i].type == 5 then
                        skillshotArray[i].skillshotpoint = calculateLineaoe2(unit, P2, maxdist)
                        dodgeaoe(unit, P2, dodgeradius)
                    end
                end
            end
        end
		elseif spell.name == E then
    	if spellDmg[unit.name] and getDmg("E",myHero,unit)~=nil and getDmg("E",myHero,unit) > myHero.health then
		
            for i=1, #skillshotArray, 1 do
            local maxdist
            local dodgeradius
            dodgeradius = skillshotArray[i].radius
            maxdist = skillshotArray[i].maxdistance
                if spell.name == skillshotArray[i].name then
                    skillshotArray[i].shot = 1
                    skillshotArray[i].lastshot = os.clock()
                    if skillshotArray[i].type == 1 then
												skillshotArray[i].p1x = unit.x
												skillshotArray[i].p1y = unit.y
												skillshotArray[i].p1z = unit.z 
												skillshotArray[i].p2x = unit.x + (maxdist)/calc*(P2.x-unit.x)
												skillshotArray[i].p2y = P2.y
												skillshotArray[i].p2z = unit.z + (maxdist)/calc*(P2.z-unit.z)
                        dodgelinepass(unit, P2, dodgeradius, maxdist)
                    elseif skillshotArray[i].type == 2 then
                        skillshotArray[i].px = P2.x
												skillshotArray[i].py = P2.y
												skillshotArray[i].pz = P2.z
                        dodgelinepoint(unit, P2, dodgeradius)
                    elseif skillshotArray[i].type == 3 then
                        skillshotArray[i].skillshotpoint = calculateLineaoe(unit, P2, maxdist)
                        if skillshotArray[i].name ~= "SummonerClairvoyance" then
                            dodgeaoe(unit, P2, dodgeradius)
                        end
                    elseif skillshotArray[i].type == 4 then
												skillshotArray[i].px = unit.x + (maxdist)/calc*(P2.x-unit.x)
												skillshotArray[i].py = P2.y
												skillshotArray[i].pz = unit.z + (maxdist)/calc*(P2.z-unit.z)
                        dodgelinepass(unit, P2, dodgeradius, maxdist)
                    elseif skillshotArray[i].type == 5 then
                        skillshotArray[i].skillshotpoint = calculateLineaoe2(unit, P2, maxdist)
                        dodgeaoe(unit, P2, dodgeradius)
                    end
                end
            end
        end
		elseif spell.name == R then
    	if spellDmg[unit.name] and getDmg("R",myHero,unit)~=nil and getDmg("R",myHero,unit) > myHero.health then
		
            for i=1, #skillshotArray, 1 do
            local maxdist
            local dodgeradius
            dodgeradius = skillshotArray[i].radius
            maxdist = skillshotArray[i].maxdistance
                if spell.name == skillshotArray[i].name then
                    skillshotArray[i].shot = 1
                    skillshotArray[i].lastshot = os.clock()
                    if skillshotArray[i].type == 1 then
												skillshotArray[i].p1x = unit.x
												skillshotArray[i].p1y = unit.y
												skillshotArray[i].p1z = unit.z 
												skillshotArray[i].p2x = unit.x + (maxdist)/calc*(P2.x-unit.x)
												skillshotArray[i].p2y = P2.y
												skillshotArray[i].p2z = unit.z + (maxdist)/calc*(P2.z-unit.z)
                        dodgelinepass(unit, P2, dodgeradius, maxdist)
                    elseif skillshotArray[i].type == 2 then
                        skillshotArray[i].px = P2.x
												skillshotArray[i].py = P2.y
												skillshotArray[i].pz = P2.z
                        dodgelinepoint(unit, P2, dodgeradius)
                    elseif skillshotArray[i].type == 3 then
                        skillshotArray[i].skillshotpoint = calculateLineaoe(unit, P2, maxdist)
                        if skillshotArray[i].name ~= "SummonerClairvoyance" then
                            dodgeaoe(unit, P2, dodgeradius)
                        end
                    elseif skillshotArray[i].type == 4 then
												skillshotArray[i].px = unit.x + (maxdist)/calc*(P2.x-unit.x)
												skillshotArray[i].py = P2.y
												skillshotArray[i].pz = unit.z + (maxdist)/calc*(P2.z-unit.z)
                        dodgelinepass(unit, P2, dodgeradius, maxdist)
                    elseif skillshotArray[i].type == 5 then
                        skillshotArray[i].skillshotpoint = calculateLineaoe2(unit, P2, maxdist)
                        dodgeaoe(unit, P2, dodgeradius)
                    end
                end
            end
        end
		
		end
		
		end
    end
	end
	end

end



function isMed()
	if CLOCKM~=nil then
		if os.clock()>CLOCKM+4 then
		return false
		else
		return true
		end
	end
end

function smitesteal()
        if myHero.SummonerD == "SummonerSmite" then
                CastHotkey("AUTO 100,0 SPELLD:SMITESTEAL RANGE=700 TRUE COOLDOWN")
                return
        end
        if myHero.SummonerF == "SummonerSmite" then
                CastHotkey("AUTO 100,0 SPELLF:SMITESTEAL RANGE=700 TRUE COOLDOWN")
                return
        end
end

function Move()
	if not isMed() then MoveToMouse() end
end


function autofarm()

mtarget=GetLowestHealthEnemyMinion(700)

if mtarget~=nil and myHero.dead==0 and not isMed() then
local AA = CalcDamage(mtarget,myHero.addDamage+myHero.baseDamage)
local Q = CalcDamage(mtarget,(40+(60*GetSpellLevel('Q'))+myHero.baseDamage+myHero.addDamage)*QRDY)
local tsafe=true

			local tfx,tfy,tfz = GetFireahead(mtarget,2,13)
			local tfa ={x=tfx,y=tfy,z=tfz}
			run_every(1,findTurret)
				for _, tur in ipairs(enemyTurrets) do
					if tur~=nil then
						
						if mtarget~=nil and GetD(tur.object,tfa)>tur.range then
							tsafe=true
						elseif mtarget~=nil and GetD(tur.object,tfa)<=tur.range then
							tsafe=false
							break
						else
							tsafe=false
							break
						end
					end
				end				

	if GetD(mtarget,myHero)>myHero.range+50 then
		MoveToXYZ(mtarget.x,0,mtarget.z)
			if GetD(mtarget,myHero)<600 and mtarget.health<Q and QRDY==1 then
				CastSpellTarget('Q', mtarget)
			end
		
	elseif  GetD(mtarget,myHero)<=myHero.range+50 and mtarget.health<Q and QRDY==1 then
			CastSpellTarget('Q', mtarget)	
			
	elseif GetD(mtarget,myHero)<=myHero.range+50 and mtarget.health<AA then
			AttackTarget(mtarget)	

		
		
	--elseif GetD(mtarget,myHero)<=myHero.range+50 and mtarget.health>AA then
	--	StopMove()
	end	

end
end
------------------------------------------------------ Check If In Spell Stuff

function dodgeaoe(pos1, pos2, radius)
    local calc = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
    if calc < radius then
					CastSummonerBarrier()
					CastSummonerHeal()
    end
end

function dodgelinepoint(pos1, pos2, radius)
    local calc1 = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
    local calc2 = (math.floor(math.sqrt((pos1.x-myHero.x)^2 + (pos1.z-myHero.z)^2)))
    local calc4 = (math.floor(math.sqrt((pos1.x-pos2.x)^2 + (pos1.z-pos2.z)^2)))
    local calc3
    local perpendicular
    local k 
    local x4
    local z4
    perpendicular = (math.floor((math.abs((pos2.x-pos1.x)*(pos1.z-myHero.z)-(pos1.x-myHero.x)*(pos2.z-pos1.z)))/(math.sqrt((pos2.x-pos1.x)^2 + (pos2.z-pos1.z)^2))))
    k = ((pos2.z-pos1.z)*(myHero.x-pos1.x) - (pos2.x-pos1.x)*(myHero.z-pos1.z)) / ((pos2.z-pos1.z)^2 + (pos2.x-pos1.x)^2)
	x4 = myHero.x - k * (pos2.z-pos1.z)
	z4 = myHero.z + k * (pos2.x-pos1.x)
	calc3 = (math.floor(math.sqrt((x4-myHero.x)^2 + (z4-myHero.z)^2)))
    if perpendicular < radius and calc1 < calc4 and calc2 < calc4 then
	
					CastSummonerBarrier()
					CastSummonerHeal()
    end
end

function dodgelinepass(pos1, pos2, radius, maxDist)
	local pm2x = pos1.x + (maxDist)/(math.floor(math.sqrt((pos1.x-pos2.x)^2 + (pos1.z-pos2.z)^2)))*(pos2.x-pos1.x)
    local pm2z = pos1.z + (maxDist)/(math.floor(math.sqrt((pos1.x-pos2.x)^2 + (pos1.z-pos2.z)^2)))*(pos2.z-pos1.z)
    local calc1 = (math.floor(math.sqrt((pm2x-myHero.x)^2 + (pm2z-myHero.z)^2)))
    local calc2 = (math.floor(math.sqrt((pos1.x-myHero.x)^2 + (pos1.z-myHero.z)^2)))
    local calc3
    local calc4 = (math.floor(math.sqrt((pos1.x-pm2x)^2 + (pos1.z-pm2z)^2)))
    local perpendicular
    local k 
    local x4
    local z4
    perpendicular = (math.floor((math.abs((pm2x-pos1.x)*(pos1.z-myHero.z)-(pos1.x-myHero.x)*(pm2z-pos1.z)))/(math.sqrt((pm2x-pos1.x)^2 + (pm2z-pos1.z)^2))))
    k = ((pm2z-pos1.z)*(myHero.x-pos1.x) - (pm2x-pos1.x)*(myHero.z-pos1.z)) / ((pm2z-pos1.z)^2 + (pm2x-pos1.x)^2)
	x4 = myHero.x - k * (pm2z-pos1.z)
	z4 = myHero.z + k * (pm2x-pos1.x)
	calc3 = (math.floor(math.sqrt((x4-myHero.x)^2 + (z4-myHero.z)^2)))
    if perpendicular < radius and calc1 < calc4 and calc2 < calc4 then
		
					CastSummonerBarrier()
					CastSummonerHeal()
    end
end

function calculateLineaoe(pos1, pos2, maxDist)
    local line = {}
    local point = {}
    point.x = pos2.x
    point.y = pos2.y
    point.z = pos2.z
    table.insert(line, point)
    return line
end

function calculateLineaoe2(pos1, pos2, maxDist)
	local calc = (math.floor(math.sqrt((pos2.x-pos1.x)^2 + (pos2.z-pos1.z)^2)))
    local line = {}
    local point = {}
    if calc < maxDist then
    point.x = pos2.x
    point.y = pos2.y
    point.z = pos2.z
    table.insert(line, point)
    else
    point.x = pos1.x + maxDist/calc*(pos2.x-pos1.x)
	point.z = pos1.z + maxDist/calc*(pos2.z-pos1.z)
	point.y = pos2.y
	table.insert(line, point)
	end
    return line
end

function calculateLinepoint(pos1, pos2, spacing, maxDist)
	local line = {}
	local point1 = {}
	point1.x = pos1.x
  point1.y = pos1.y
  point1.z = pos1.z
	local point2 = {}
	point1.x = pos2.x
  point1.y = pos2.y
  point1.z = pos2.z
				table.insert(line, point2)
        table.insert(line, point1)
    return line
end

------------------------------END Spell Callback Stuff
function IsMoving(slowtarget)
   local x, y, z = GetFireahead(slowtarget,1,99)
   local d = GetD({x=x, y=y, z=z},slowtarget)
   return d > 0 
end



function fight()
	if target ~= nil  then
		if  GetD(target)<400 then
				for _, item in pairs(hydraItems) do
						if GetInventorySlot(item)~=nil and myHero["SpellTime"..GetInventorySlot(item)]>1.0 then
								CastSpellTarget(tostring(GetInventorySlot(item)),target)
						end
				end
				for _, item in pairs(aoeItems) do
						if GetInventorySlot(item)~=nil and myHero["SpellTime"..GetInventorySlot(item)]>1.0 then
								CastSpellTarget(tostring(GetInventorySlot(item)),target)
						end
				end
				for _, item in pairs(targetItems) do
						if GetInventorySlot(item)~=nil and myHero["SpellTime"..GetInventorySlot(item)]>1.0 then
								CastSpellTarget(tostring(GetInventorySlot(item)),target)
						end
				end
		elseif GetD(target)<600 then
				for _, item in pairs(targetItems) do
						if GetInventorySlot(item)~=nil and myHero["SpellTime"..GetInventorySlot(item)]>1.0 then
								CastSpellTarget(tostring(GetInventorySlot(item)),target)
						end
				end
		end
			if RRDY==1 and not isMed() then
				CastSpellTarget('R', target)
				AttackTarget(target)
			
			
			elseif ERDY==1 and GetD(myHero, target) < myHero.range+150 and not isMed() then
				CastSpellTarget('E', target)
				AttackTarget(target)
			
			
			elseif QRDY==1 and GetD(myHero, target) < 600 and not isMed() then
				CastSpellTarget('Q', target)
				AttackTarget(target)
			
			
			elseif WRDY==1 and YiConfig.hTF and myHero.health<myHero.maxHealth*25/100 and QRDY==0 then
				CastSpellTarget('W', myHero)
			
			
			elseif not isMed() then
				AttackTarget(target)
				
				
			--[[elseif GetD(myHero, target) <= myHero.range+250 and not isMed() then
				AttackTarget(target)
				
			elseif GetD(target)>myHero.range+250 and not isMed() then
				MoveToMouse()--]]
			end
	

	elseif target == nil then
	if not isMed() then MoveToMouse() end
	end
	
	
end

function fightNoUlt()
	if target ~= nil  then
			if GetD(target)<400 then
				UseAllItems(target)
				CastSummonerExhaust(target)
			end
			if ERDY==1 and GetD(myHero, target) < myHero.range+150 and not isMed() then
				CastSpellTarget('E', target)
				AttackTarget(target)
			
			
			elseif QRDY==1 and GetD(myHero, target) < 600 and not isMed() then
				CastSpellTarget('Q', target)
				AttackTarget(target)
			
			
			elseif WRDY==1 and YiConfig.hTF and myHero.health<myHero.maxHealth*25/100 and QRDY==0 then
				CastSpellTarget('W', myHero)
			
			
			elseif not isMed() then
				AttackTarget(target)
				
				
			--[[elseif GetD(myHero, target) <= myHero.range+250 and not isMed() then
				AttackTarget(target)
				
			elseif GetD(target)>myHero.range+250 and not isMed() then
				MoveToMouse()--]]
			end
	

	elseif target == nil then
	if not isMed() then MoveToMouse() end
	end
	
	
end

function autoQ()

    if target ~= nil then
		if QRDY==1 and GetD(myHero, target) < 600 and not isMed() then
			CastSpellTarget('Q', target)
		end
    end

end

function autoQM()

	local enemyMinions = GetEnemyMinions(MINION_SORT_HEALTH_ASC)

	local mhtarget

	local tsafe=true
	if YiConfig.autoQM3==false then
		if targetQharass~=nil then
		for _, minion in pairs(enemyMinions) do
			if minion~=nil then
				local tfx,tfy,tfz = GetFireahead(minion,2,13)
				local tfa ={x=tfx,y=tfy,z=tfz}
				run_every(1,findTurret)
				for _, tur in ipairs(enemyTurrets) do
					if tur~=nil then
						
						if minion~=nil and GetD(tur.object,tfa)>tur.range then
							tsafe=true
						elseif minion~=nil and GetD(tur.object,tfa)<=tur.range then
							tsafe=false
							break
						else
							tsafe=false
							break
						end
					end
				end	
		
		
		
				if mhtarget==nil and tsafe==true and 75<GetD(minion,targetQharass) and GetD(minion,targetQharass)<650 then
					mhtarget=minion
				elseif mhtarget~=nil and tsafe==true and 75<GetD(minion,targetQharass) and GetD(minion,targetQharass)<650 and GetD(minion,myHero)<GetD(mhtarget,myHero)  then
					mhtarget=minion
				end
			end
		end
		end
	elseif YiConfig.autoQM3==true then
		local minioncount=0
		if targetQharass~=nil then
		for _, minion in pairs(enemyMinions) do
			if minion~=nil then
				if GetD(minion)<1200 then
					minioncount=minioncount+1
				end
				local tfx,tfy,tfz = GetFireahead(minion,2,13)
				local tfa ={x=tfx,y=tfy,z=tfz}
				run_every(1,findTurret)
				for _, tur in ipairs(enemyTurrets) do
					if tur~=nil then
						
						if minion~=nil and GetD(tur.object,tfa)>tur.range then
							tsafe=true
						elseif minion~=nil and GetD(tur.object,tfa)<=tur.range then
							tsafe=false
							break
						else
							tsafe=false
							break
						end
					end
				end	
		
		
		
				if mhtarget==nil and minioncount<4 and tsafe==true and 75<GetD(minion,targetQharass) and GetD(minion,targetQharass)<650 then
					mhtarget=minion
				elseif mhtarget~=nil and minioncount<4 and tsafe==true and 75<GetD(minion,targetQharass) and GetD(minion,targetQharass)<650 and GetD(minion,myHero)<GetD(mhtarget,myHero)  then
					mhtarget=minion
				elseif minioncount>=4 then
					mhtarget=nil
					break
				end
			end
		end
		end
	end

				
		if mhtarget~=nil and targetQharass~=nil and tsafe==true then
			if QRDY==1 and GetD(myHero, mhtarget) < 600 and GetD(myHero, mhtarget) < GetD(myHero,targetQharass) and not isMed() then
				CastSpellTarget('Q', mhtarget)
			end
		end
end


function autoEattack()

    if target ~= nil then
		if ERDY==1 and GetD(myHero, target) < myHero.range+100 and not isMed() then
			CastSpellTarget('E', target)
		end
    end

end

function autohealW()

		if WRDY==1 and (not IsMoving(myHero) or YiConfig.move or YiConfig.teamfight or YiConfig.fight) and myHero.health<myHero.maxHealth*20/100 and os.clock()>CLOCKT+9 and os.clock()>CLOCKF+3 then
			CastSpellTarget('W', myHero)
		end


end



function killsteal()
	if target ~= nil then
		local EEd = CalcDamage(target,(myHero.addDamage+myHero.baseDamage)*(5+(2*GetSpellLevel('E')))/100)*ERDY
		local Ed	= (5+(5*GetSpellLevel('E'))+(myHero.addDamage+myHero.baseDamage)*(7.5+(2.5*GetSpellLevel('E')))/100)*ERDY
		local AA = getDmg("AD",target,myHero)+(getDmg("SHEEN",target,myHero)*hasSheen)+(getDmg("LICHBANE",target,myHero)*hasLich)+(getDmg("ICEBORN",target,myHero)*hasIceBorn)+(getDmg("TRINITY",target,myHero)*hasTrinity)
		local Q = CalcDamage(target,(-5+(35*GetSpellLevel('Q'))+myHero.baseDamage+myHero.addDamage)*QRDY)
		

			if target.health<Q+AA+Ed+ignitedamage and not isMed() then	
				if QRDY==1 then 
					CastSpellTarget('Q', target) 
				elseif myHero.SummonerD == 'SummonerDot' then
					if IsSpellReady('D') and GetD(target)<600 then CastSpellTarget('D',target) end
				
				elseif myHero.SummonerF == 'SummonerDot' then
					if IsSpellReady('F') and GetD(target)<600 then CastSpellTarget('F',target) end
				elseif not isMed() and GetD(target)<280 then
					AttackTarget(target)
				end
			elseif target.health<Q+AA+EEd+ignitedamage and not isMed() then	
				if QRDY==1 then CastSpellTarget('Q', target) 
				elseif ERDY==1 then CastSpellTarget('E', target)
					AttackTarget(target)
				elseif myHero.SummonerD == 'SummonerDot' then
					if IsSpellReady('D') and GetD(target)<600 then CastSpellTarget('D',target) end
				
				elseif myHero.SummonerF == 'SummonerDot' then
					if IsSpellReady('F') and GetD(target)<600 then CastSpellTarget('F',target) end
				elseif not isMed() and GetD(target)<280 then
					AttackTarget(target)
				end
			end
		
	end
end

function ignite()
		if myHero.SummonerD == 'SummonerDot' then
			ignitedamage = ((myHero.selflevel*20)+50)*IsSpellReady('D')
		elseif myHero.SummonerF == 'SummonerDot' then
				ignitedamage = ((myHero.selflevel*20)+50)*IsSpellReady('F')
		else
				ignitedamage=0
		end
end


function OnDraw()

	
    if myHero.dead == 0 then
		if QRDY == 1 then
			CustomCircle(600,3,2,myHero)
			CustomCircle(1250,3,1,myHero)
		end	
		if hpmarker~=nil then
			if WRDY == 1 and hpmarker<39/160*GetScreenX() then
				DrawBox(GetScreenX()-98/160*GetScreenX()+hpmarker,GetScreenY()-43/900*GetScreenY(),8,17,Color.Red)
			end	
		
			if WRDY == 1 and hpmarker>=39/160*GetScreenX() then
				DrawBox(GetScreenX()-59/160*GetScreenX(),GetScreenY()-43/900*GetScreenY(),8,17,Color.DeepPink)
			end	
		end

		if GetSpellLevel('Q')>0 then
			for i=1, objManager:GetMaxHeroes(), 1 do
				object = objManager:GetHero(i)
				if object ~= nil and object.team ~= myHero.team and GetD(object,myHero)<1600 and YiConfig.drawQ then	
					DrawTextObject("\n\n"..(math.floor(object.health/CalcDamage(object,(-5+(35*GetSpellLevel('Q'))+myHero.baseDamage+myHero.addDamage))))+1 .." Q's",object,Color.White)
				end
			end
		end	
		
	end
	
end

function LoadTable()
--print("table loaded::")
    local iCount=objManager:GetMaxHeroes()
--print(" heros:" .. tostring(iCount))
	iCount=1;
    for i=0, iCount, 1 do
		if 1==1 or myHero.name == "Thresh" then
			table.insert(skillshotArray,{name= "ThreshQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "ThreshQInternal", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or myHero.name == "Quinn" then
                table.insert(skillshotArray,{name= "QuinnQMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1025, type = 1, radius = 40, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
        end
		if 1==1 or myHero.name == "Syndra" then
				table.insert(skillshotArray,{name= "SyndraQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 200, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= "SyndraE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 1, radius = 100, color= coloryellow, time = 0.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				table.insert(skillshotArray,{name= "syndrawcast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 200, color= colorcyan, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
				skillshotcharexist = true
			end
		if 1==1 or myHero.name == "Khazix" then
			table.insert(skillshotArray,{name= "KhazixE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 3, radius = 200, color= colorcyan, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "KhazixW", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 120, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "khazixwlong", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "khazixelong", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 200, color= colorcyan, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or myHero.name == "Elise" then
			table.insert(skillshotArray,{name= "EliseHumanE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
		if 1==1 or myHero.name == "Zed" then
			table.insert(skillshotArray,{name= "ZedShuriken", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 100, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "ZedShadowDash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 550, type = 3, radius = 150, color= colorcyan, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			table.insert(skillshotArray,{name= "zedw2", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 550, type = 3, radius = 150, color= colorcyan, time = 0.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
			skillshotcharexist = true
		end
            if 1==1 or myHero.name == "Ahri" then
                table.insert(skillshotArray,{name= "AhriOrbofDeception", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 880, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                table.insert(skillshotArray,{name= "AhriSeduce", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Amumu" then
                table.insert(skillshotArray,{name= "BandageToss", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Anivia" then
                table.insert(skillshotArray,{name= "FlashFrostSpell", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 90, color= colorcyan, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Ashe" then
                table.insert(skillshotArray,{name= "EnchantedCrystalArrow", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 3000, type = 4, radius = 120, color= colorcyan, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Blitzcrank" then
                table.insert(skillshotArray,{name= "RocketGrabMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Brand" then
                table.insert(skillshotArray,{name= "BrandBlazeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 70, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                table.insert(skillshotArray,{name= "BrandFissure", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Cassiopeia" then
                table.insert(skillshotArray,{name= "CassiopeiaMiasma", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 175, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "CassiopeiaNoxiousBlast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 75, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Caitlyn" then
                table.insert(skillshotArray,{name= "CaitlynEntrapmentMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 50, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "CaitlynPiltoverPeacemaker", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Corki" then
                table.insert(skillshotArray,{name= "MissileBarrageMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1225, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "MissileBarrageMissile2", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1225, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "CarpetBomb", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 2, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Chogath" then
                table.insert(skillshotArray,{name= "Rupture", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 275, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "DrMundo" then
                table.insert(skillshotArray,{name= "InfectedCleaverMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Heimerdinger" then
                table.insert(skillshotArray,{name= "CH1ConcussionGrenade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 225, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Draven" then
                table.insert(skillshotArray,{name= "DravenDoubleShot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 125, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= "DravenRCast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 3000, type = 1, radius = 100, color= colorcyan, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Ezreal" then
                table.insert(skillshotArray,{name= "EzrealEssenceFluxMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= "EzrealMysticShotMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= "EzrealTrueshotBarrage", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 3000, type = 4, radius = 150, color= colorcyan, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= "EzrealArcaneShift", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 475, type = 5, radius = 100, color= colorgreen, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Fizz" then
                table.insert(skillshotArray,{name= "FizzMarinerDoom", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1275, type = 2, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "FiddleSticks" then
                table.insert(skillshotArray,{name= "Crowstorm", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 600, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Karthus" then
                table.insert(skillshotArray,{name= "LayWaste", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 875, type = 3, radius = 150, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Galio" then
                table.insert(skillshotArray,{name= "GalioResoluteSmite", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 905, type = 3, radius = 200, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "GalioRighteousGust", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 120, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Graves" then
                table.insert(skillshotArray,{name= "GravesChargeShot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 110, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "GravesClusterShot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 750, type = 1, radius = 50, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "GravesSmokeGrenade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 3, radius = 275, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Gragas" then
                table.insert(skillshotArray,{name= "GragasBarrelRoll", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 320, color= coloryellow, time = 2.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "GragasBodySlam", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 2, radius = 60, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "GragasExplosiveCask", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 3, radius = 400, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Irelia" then
                table.insert(skillshotArray,{name= "IreliaTranscendentBlades", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 80, color= colorcyan, time = 0.8, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Janna" then
                table.insert(skillshotArray,{name= "HowlingGale", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1700, type = 1, radius = 100, color= colorcyan, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "JarvanIV" then
                table.insert(skillshotArray,{name= "JarvanIVDemacianStandard", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 830, type = 3, radius = 150, color= coloryellow, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "JarvanIVDragonStrike", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 770, type = 1, radius = 70, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "JarvanIVCataclysm", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 3, radius = 300, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Kassadin" then
                table.insert(skillshotArray,{name= "RiftWalk", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 5, radius = 150, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Katarina" then
                table.insert(skillshotArray,{name= "ShadowStep", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 3, radius = 75, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Kennen" then
                table.insert(skillshotArray,{name= "KennenShurikenHurlMissile1", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 75, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "KogMaw" then
                table.insert(skillshotArray,{name= "KogMawVoidOozeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1115, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "KogMawLivingArtillery", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2200, type = 3, radius = 200, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Leblanc" then
                table.insert(skillshotArray,{name= "LeblancSoulShackle", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "LeblancSoulShackleM", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "LeblancSlide", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "LeblancSlideM", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= "leblancslidereturn", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 50, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= "leblancslidereturnm", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 50, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "LeeSin" then
                table.insert(skillshotArray,{name= "BlindMonkQOne", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "BlindMonkRKick", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Leona" then
                table.insert(skillshotArray,{name= "LeonaZenithBladeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Lux" then
                table.insert(skillshotArray,{name= "LuxLightBinding", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1175, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "LuxLightStrikeKugel", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 300, color= coloryellow, time = 2.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "LuxMaliceCannon", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 3000, type = 1, radius = 180, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Lulu" then
                table.insert(skillshotArray,{name= "LuluQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 50, color= colorcyan, time = 1, isline = true, px =0, py =0 , pz =0, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Maokai" then
                table.insert(skillshotArray,{name= "MaokaiTrunkLineMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "MaokaiSapling2", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 350 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Malphite" then
                table.insert(skillshotArray,{name= "UFSlash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 325, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Malzahar" then
                table.insert(skillshotArray,{name= "AlZaharCalloftheVoid", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 100 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "AlZaharNullZone", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 250 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "MissFortune" then
                table.insert(skillshotArray,{name= "MissFortuneScattershot", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 400, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Morgana" then
                table.insert(skillshotArray,{name= "DarkBindingMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 90, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "TormentedSoil", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 300, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Nautilus" then
                table.insert(skillshotArray,{name= "NautilusAnchorDrag", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 1, radius = 80, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Nidalee" then
                table.insert(skillshotArray,{name= "JavelinToss", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1500, type = 1, radius = 80, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Nocturne" then
                table.insert(skillshotArray,{name= "NocturneDuskbringer", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 80, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Olaf" then
                table.insert(skillshotArray,{name= "OlafAxeThrow", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 2, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Orianna" then
                table.insert(skillshotArray,{name= "OrianaIzunaCommand", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 825, type = 3, radius = 150, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Renekton" then
                table.insert(skillshotArray,{name= "RenektonSliceAndDice", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 450, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= "renektondice", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 450, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Rumble" then
                table.insert(skillshotArray,{name= "RumbleGrenadeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= "RumbleCarpetBomb", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1700, type = 1, radius = 100, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Sivir" then
                table.insert(skillshotArray,{name= "SpiralBlade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Singed" then
                table.insert(skillshotArray,{name= "MegaAdhesive", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 350, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Shen" then
                table.insert(skillshotArray,{name= "ShenShadowDash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 2, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Shaco" then
                table.insert(skillshotArray,{name= "Deceive", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 500, type = 5, radius = 100, color= colorgreen, time = 3.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Shyvana" then
                table.insert(skillshotArray,{name= "ShyvanaTransformLeap", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 80, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "ShyvanaFireballMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Skarner" then
                table.insert(skillshotArray,{name= "SkarnerFracture", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Sona" then
                table.insert(skillshotArray,{name= "SonaCrescendo", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Sejuani" then
                table.insert(skillshotArray,{name= "SejuaniGlacialPrison", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1150, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Swain" then
                table.insert(skillshotArray,{name= "SwainShadowGrasp", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 265 , color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Tryndamere" then
                table.insert(skillshotArray,{name= "Slash", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 2, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Tristana" then
                table.insert(skillshotArray,{name= "RocketJump", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 200, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "TwistedFate" then
                table.insert(skillshotArray,{name= "WildCards", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1450, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Urgot" then
                table.insert(skillshotArray,{name= "UrgotHeatseekingLineMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= colorcyan, time = 0.8, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "UrgotPlasmaGrenade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 300, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Vayne" then
                table.insert(skillshotArray,{name= "VayneTumble", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 250, type = 3, radius = 100, color= colorgreen, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Varus" then
                --table.insert(skillshotArray,{name= "VarusQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1475, type = 1, radius = 50, color= coloryellow, time = 1})
                table.insert(skillshotArray,{name= "VarusR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 80, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Veigar" then
                table.insert(skillshotArray,{name= "VeigarDarkMatter", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 225, color= coloryellow, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Viktor" then
                --table.insert(skillshotArray,{name= "ViktorDeathRay", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 80, color= coloryellow, time = 2})
            end
            if 1==1 or myHero.name == "Xerath" then
                table.insert(skillshotArray,{name= "xeratharcanopulsedamage", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "xeratharcanopulsedamageextended", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= "xeratharcanebarragewrapper", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "xeratharcanebarragewrapperext", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Ziggs" then
                table.insert(skillshotArray,{name= "ZiggsQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 160, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= "ZiggsW", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 225 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                table.insert(skillshotArray,{name= "ZiggsE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "ZiggsR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5300, type = 3, radius = 550, color= coloryellow, time = 3, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Zyra" then
                table.insert(skillshotArray,{name= "ZyraQFissure", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 825, type = 3, radius = 275, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "ZyraGraspingRoots", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 90, color= colorcyan, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
            if 1==1 or myHero.name == "Diana" then
                table.insert(skillshotArray,{name= "DianaArc", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 205, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
            skillshotcharexist = true
            end
        --end
    end
end








function findTurret()
enemyTurrets={}
for i=1, objManager:GetMaxObjects(), 1 do
    local object = objManager:GetObject(i)
    if map == "SummonersRift" then
        if object ~= nil  and object.charName ~= nil then
			if myHero.team==200 then
				for i,tower in ipairs(SpawnturretR) do
					if object.charName == tower then
						turret = {range=1600,color=2,object=object}
						table.insert(enemySpawn,turret) 
					end
				end
				for i,tower in ipairs(TurretsR) do
					if object.charName == tower then
						turret = {range=1020,color=2,object=object}
						table.insert(enemyTurrets,turret) 

					end
				end								
			end
			if myHero.team==100 then			
				for i,tower in ipairs(SpawnturretB) do
					if object.charName == tower then
						turret = {range=1600,color=3,object=object}
						table.insert(enemySpawn,turret) 

					end
				end

				for i,tower in ipairs(TurretsB) do
					if object.charName == tower then
						turret = {range=1020,color=3,object=object}
						table.insert(enemyTurrets,turret) 

					end
				end
			end
        end
		
--[[    elseif map == "ProvingGrounds" then
        if object ~= nil and object.charName ~= nil then
			if myHero.team==200 then
				for i,tower in ipairs(SpawnturretR) do
					if object.charName == tower then
						turret = {range=1300,color=2,object=object}
						table.insert(enemySpawn,turret) 

					end
				end

				for i,tower in ipairs(TurretsR) do
					if object.charName == tower then
						turret = {range=1020,color=2,object=object}
						table.insert(enemyTurrets,turret) 

					end
				end
			end
			if myHero.team==100 then	
				for i,tower in ipairs(SpawnturretB) do
					if object.charName == tower then
						turret = {range=1300,color=3,object=object}
						table.insert(enemySpawn,turret) 

					end
				end
				for i,tower in ipairs(TurretsB) do
					if object.charName == tower then
						turret = {range=1020,color=3,object=object}
						table.insert(enemyTurrets,turret) 

					end
				end
			end
        end
    elseif map == "CrystalScar" then
        if object ~= nil and object.charName ~= nil then
			if myHero.team==200 then	
				for i,tower in ipairs(SpawnturretR) do
					if object.charName == tower then
						turret = {range=1820,color=2,object=object}
						table.insert(enemySpawn,turret) 

					end
				end
				for i,tower in ipairs(TurretsR) do
					if object.charName == tower then
						turret = {range=750,color=5,object=object}
						table.insert(enemyTurrets,turret) 

					end
				end		
			end	
			if myHero.team==100 then
				for i,tower in ipairs(SpawnturretB) do
					if object.charName == tower then
						turret = {range=1820,color=3,object=object}
						table.insert(enemySpawn,turret) 

					end
				end
				for i,tower in ipairs(TurretsB) do
					if object.charName == tower then
						turret = {range=750,color=5,object=object}
						table.insert(enemyTurrets,turret) 

					end
				end
			end
        end
    elseif map == "TwistedTreeline" then
        if object and object ~= nil and object.charName ~= nil then
			if myHero.team==200 then
				for i,tower in ipairs(SpawnturretR) do
					if object.charName == tower then
						turret = {range=1550,color=2,object=object}
						table.insert(enemySpawn,turret) 

					end
				end            
				for i,tower in ipairs(TurretsR) do
					if object.charName == tower then
						turret = {range=1020,color=2,object=object}
						table.insert(enemyTurrets,turret) 

					end
				end
			end	
			if myHero.team==100 then
				for i,tower in ipairs(SpawnturretB) do
					if object.charName == tower then
						turret = {range=1550,color=3,object=object}
						table.insert(enemySpawn,turret) 

					end
				end

				for i,tower in ipairs(TurretsB) do
					if object.charName == tower then
						turret = {range=1020,color=3,object=object}
						table.insert(enemyTurrets,turret) 

					end
				end
			end
        end--]]
    end
end

end



function GetD(p1, p2)
        if p2 == nil then p2 = myHero end
    if (p1.z == nil or p2.z == nil) and p1.x~=nil and p1.y ~=nil and p2.x~=nil and p2.y~=nil then
        px=p1.x-p2.x
        py=p1.y-p2.y
        if px~=nil and py~=nil then
            px2=px*px
            py2=py*py
            if px2~=nil and py2~=nil then
                return math.sqrt(px2+py2)
            else
                return 99999
            end
        else
            return 99999
        end
 
    elseif p1.x~=nil and p1.z ~=nil and p2.x~=nil and p2.z~=nil then
        px=p1.x-p2.x
        pz=p1.z-p2.z
        if px~=nil and pz~=nil then
            px2=px*px
            pz2=pz*pz
            if px2~=nil and pz2~=nil then
                return math.sqrt(px2+pz2)
            else
                return 99999
            end
        else    
            return 99999
        end
 
    else
                return 99999
    end
end

            --------------------------------------------W usage for PinkWards
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
function GetTeamSize()
    return math.floor(objManager:GetMaxHeroes()/2)
end
 
 
function GetBestEnemy(damage_type, range, tag)
    if tag == nil then tag = "BASIC" end
	local QDMG=0
	local WDMG=0
	local EDMG=0
	local RDMG=0
	local ADMG=0
    local enemy, prospect
    for i=1,GetTeamSize() do    
        prospect = GetWeakEnemy(damage_type, range, tag, i)
        if prospect == nil then
            -- pass        
        else
			if spellDmg[myHero.name] then
				if QRDY==1 and getDmg("Q",prospect,myHero)~=nil then
					QDMG=getDmg("Q",prospect,myHero)
				else
					QDMG=0
				end
				if WRDY==1 and getDmg("W",prospect,myHero)~=nil then
					WDMG=getDmg("W",prospect,myHero)
				else
					WDMG=0
				end
				if ERDY==1 and getDmg("E",prospect,myHero)~=nil then
					EDMG=getDmg("E",prospect,myHero)
				else
					EDMG=0
				end
				if RRDY==1 and getDmg("R",prospect,myHero)~=nil then
					RDMG=getDmg("R",prospect,myHero)
				else
					RDMG=0
				end
				if getDmg("AD",prospect,myHero)~=nil then
					ADMG=getDmg("AD",prospect,myHero)
				else
					ADMG=0
				end
			
			end
			
			local invul=IsInvulnerable(prospect).status
            if invul==1 or (invul==4 and QDMG+WDMG+EDMG+RDMG+ADMG>prospect.health) then
                local msg = "*** target invulnerable, cycling ***"
                print(msg)
                DrawTextObject(msg,myHero,0xFFFF0000)
            else
                enemy = prospect
                break -- <-------- *** important ***
            end
        end
    end
    -- we should return nil if everyone is invuln, same as the original api when no enemies are in range
    --if target == nil then
    --    target = GetWeakEnemy(damage_type, range, tag)
    --end
    return enemy
end

local StatusReturn={}
function IsInvulnerable(target)
        if target ~= nil and target.dead == 0 then
                if target.invulnerable == 1 then return {status = 1, name = nil, amount = nil, type = nil}
                else 
					StatusReturn=run_every(0.3,getStatus,target)
					if StatusReturn~=nil then
						return	StatusReturn
					end
                end
        end
        return {status = 0, name = nil, amount = nil, type = nil}
end

function getStatus(target)
	StatusReturn=nil
	for i=1, objManager:GetMaxObjects(), 1 do
			local object = objManager:GetObject(i)
			if object ~= nil then
					if string.find(object.charName,"eyeforaneye") ~= nil and GetDistance(target,object) <= 20 then return {status = 1, name = 'Intervention', amount = 0, type = 'ALL'}
					elseif string.find(object.charName,"nickoftime") ~= nil and GetDistance(target,object) <= 20 then return {status = 4, name = 'Chrono Shift', amount = 0, type = 'REVIVE'}
					elseif target.name == 'Poppy' and string.find(object.charName,"DiplomaticImmunity_tar") ~= nil and GetDistance(myHero,object) > 20 then
							for i=1, objManager:GetMaxObjects(), 1 do
									local diObject = objManager:GetObject(i)
									if diObject ~= nil and string.find(diObject.charName,"DiplomaticImmunity_buf") ~= nil and GetDistance(target,diObject) <= 20 then return {status = 1, name = 'Diplomatic Immunity', amount = 0, type = 'ALL'} end
							end
					elseif target.name == 'Vladimir' and string.find(object.charName,"VladSanguinePool_buf") ~= nil and GetDistance(myHero,object) <= 20 then return {status = 1, name = 'Sanguine Pool', amount = 0, type = 'ALL'}
--                                      elseif string.find(object.charName,"Summoner_Barrier") ~= nil and GetDistance(target,object) <= 20 then return 2--, 'NONE'
					elseif (string.find(object.charName,"Global_Spellimmunity") ~= nil or string.find(object.charName,"Morgana_Blackthorn_Blackshield") ~= nil) and GetDistance(target,object) <= 20 then
							local amount = 0
							for i= 1,objManager:GetMaxHeroes(),1 do
									local hero=objManager:GetHero(i)
									if hero.team == target.team and hero.name == 'Morgana' then
											amount = 30+(65*hero.SpellLevelE)+(hero.ap*0.7)
											return {status = 2, name = 'Black Shield', amount = amount, type = 'MAGIC'}
									end
							end
					elseif string.find(object.charName,"bansheesveil_buf") ~= nil and GetDistance(target,object) <= 20 then return {status = 2, name = 'Banshees Veil', amount = 0, type = 'SPELL'}
					elseif target.name == 'Sivir' and string.find(object.charName,"Sivir_Base_E_shield") ~= nil and GetDistance(target,object) <= 20 then return {status = 2, name = 'Spell Shield', amount = 0, type = 'SPELL'}
					elseif target.name == 'Nocturne' and string.find(object.charName,"nocturne_shroudofDarkness_shield") ~= nil and GetDistance(target,object) <= 20 then return {status = 2, name = 'Shroud of Darkness', amount = 0, type = 'SPELL'}
					elseif target.name == 'Tryndamere' and string.find(object.charName,"UndyingRage_buf") ~= nil and GetDistance(target,object) <= 20 then return {status = 4, name = 'Undying Rage', amount = 0, type = 'NONE'}
					elseif string.find(object.charName,"rebirthready") ~= nil and GetDistance(target,object) <= 20 then return {status = 3, name = 'Guardian Angel', amount = 0, type = 'REVIVE'}
					elseif target.name == 'Anivia' then
							if target.team == myHero.team then
									if GetTickCount()-egg.allied.time > 240000 or egg.allied.time == 0 then return {status = 3, name = 'Egg', amount = 0, type = 'REVIVE'}
									else return {status = 0, name = nil, amount = nil, type = nil} end
							else
									if GetTickCount()-egg.enemy.time > 240000 or egg.enemy.time == 0 then return {status = 3, name = 'Egg', amount = 0, type = 'REVIVE'}
									else return {status = 0, name = nil, amount = nil, type = nil} end
							end
					elseif target.name == 'Aatrox' then
							if target.team == myHero.team then
									if GetTickCount()-aatrox.allied.time > 225000 or aatrox.allied.time == 0 then return {status = 3, name = 'Aatrox', amount = 0, type = 'REVIVE'}
									else return {status = 0, name = nil, amount = nil, type = nil}
									end
							elseif target.team ~= myHero.team then
									if GetTickCount()-aatrox.enemy.time > 225000 or aatrox.enemy.time == 0 then return {status = 3, name = 'Aatrox', amount = 0, type = 'REVIVE'}
									else return {status = 0, name = nil, amount = nil, type = nil}
									end
							end
					elseif target.name == 'Zac' then
							if target.team == myHero.team then
									if GetTickCount()-zac.allied.time > 300000 or zac.allied.time == 0 then return {status = 3, name = 'Zac', amount = 0, type = 'REVIVE'}
									else return {status = 0, name = nil, amount = nil, type = nil}
									end
							elseif target.team ~= myHero.team then
									if GetTickCount()-zac.enemy > 300000 or zac.enemy.time == 0 then return {status = 3, name = 'Zac', amount = 0, type = 'REVIVE'}
									else return {status = 0, name = nil, amount = nil, type = nil}
									end
							end
--                                      elseif string.find(object.charName,"GLOBAL_Item_FoM_Shield") ~= nil and GetDistance(target,object) <= 30 then return 2--, 'NONE'
--                                      elseif target.name == 'Nautilus' and string.find(object.charName,"Nautilus_W_shield_cas") ~= nil and GetDistance(target,object) <= 20 then return 2--, 'NONE'
					end
			end
	end
end


SetTimerCallback("Run")
SetTimerCallback("VeigRun")