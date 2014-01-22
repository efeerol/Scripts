require 'Utils'
require 'spell_damage'
print=printtext
print("\nShaco\n")
print("\nBy Malbert\n")
print('\nVersion 1.3\n')

local target
local target600
local targetR
local ignitedamage=0
local enemyInRange=nil

local checkDie=false
 
 local shacocopy=nil
		local RTimer=0
 
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

local boxSpots = {
        { x = 2572,    y = 45.84,  z = 7457},     -- BLUE GOLEM
        { x = 7422,    y = 46.53,  z = 3282},     -- BLUE LIZARD
        { x = 10148,   y = 44.41,  z = 2839},     -- BLUE TRI BUSH
        { x = 6269,    y = 42.51,  z = 4445},     -- BLUE PASS BUSH
        { x = 7406,    y = 43.31,  z = 4995},     -- BLUE RIVER ENTRANCE
        { x = 4325,    y = 44.38,  z = 7241.54},  -- BLUE ROUND BUSH
        { x = 4728,    y = -51.29, z = 8336},     -- BLUE RIVER ROUND BUSH
        { x = 6598,    y = 46.15,  z = 2799},     -- BLUE SPLIT PUSH BUSH
 
        { x = 11500,   y = 45.75,  z = 7095},     -- PURPLE GOLEM
        { x = 6661,    y = 44.46,  z = 11197},    -- PURPLE LIZARD
        { x = 3883,    y = 39.87,  z = 11577},    -- PURPLE TRI BUSH
        { x = 7775,    y = 43.14,  z = 10046.49}, -- PURPLE PASS BUSH
        { x = 6625.47, y = 47.66,  z = 9463},     -- PURPLE RIVER ENTRANCE
        { x = 9720,    y = 45.79,  z = 7210},     -- PURPLE ROUND BUSH
        { x = 9191,    y = -73.46, z = 6004},     -- PURPLE RIVER ROUND BUSH
        { x = 7490,    y = 41,     z = 11681},    -- PURPLE SPLIT PUSH BUSH
 
        { x = 3527.43, y = -74.95, z = 9534.51},  -- NASHOR
        { x = 10473,   y = -73,    z = 5059},     -- DRAGON
}

local tqfx,tqfy,tqfz
local tqfa
			
local twfx,twfy,twfz
local twfa
			
--turret stuff
local tx,tz=0,0
local _registry = {}
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



ShacoConfig = scriptConfig("Shaco", "Shaco Config")
ShacoConfig:addParam("h", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, 88)
ShacoConfig:addParam("teamfight", "All In Teamfight", SCRIPT_PARAM_ONKEYDOWN, false, 84)
ShacoConfig:addParam("e", "Escape", SCRIPT_PARAM_ONKEYDOWN, false, 90)
ShacoConfig:addParam("box", "Smart Box", SCRIPT_PARAM_ONKEYDOWN, false, 65)
ShacoConfig:addParam("smite", "Smitesteal", SCRIPT_PARAM_ONKEYTOGGLE, false, 55)
ShacoConfig:addParam("ult", "Ult Attack", SCRIPT_PARAM_ONKEYTOGGLE, true, 56)
ShacoConfig:addParam("zh", "Zhonyas", SCRIPT_PARAM_ONOFF, true)
ShacoConfig:addParam("ks", "KillSteal", SCRIPT_PARAM_ONOFF, true)
ShacoConfig:addParam('ad', 'AD Shaco?', SCRIPT_PARAM_ONOFF, true)
ShacoConfig:permaShow("teamfight")
ShacoConfig:permaShow("smite")
ShacoConfig:permaShow("ult")
ShacoConfig:permaShow("zh")
ShacoConfig:permaShow("ks")
ShacoConfig:permaShow("ad")
     
     
	 --Q 250  
	 --W 300  3.79, 11.1
	 --E 700 3.19,50
	 --R 2400  3.65,99
	 
function Run()

	if ShacoConfig.ad then
	target = GetWeakEnemy("PHYS", 1000)
	targetR = GetWeakEnemy("PHYS", 1500)
	else
	target = GetWeakEnemy("MAGIC", 1000)
	targetR = GetWeakEnemy("MAGIC", 1500)
	end
	target600 = GetWeakEnemy("TRUE", 600)
	enemyInRange= GetWeakEnemy("MAGIC",650)
	checkDie=false
        if ShacoConfig.zh then
                checkDie=true
                if target~=nil and myHero.health<myHero.maxHealth*15/100 then
                        zhonyas()
                end
        else
                checkDie=false
        end
		
		
	if target~=nil then
		tqfx,tqfy,tqfz = GetFireahead(target,2,0)
		tqfa={x=tqfx,y=0,z=tqfz}
		
		twfx,twfy,twfz = GetFireahead(target,2,0)
		twfa={x=twfx,y=0,z=twfz}
		
	end

		if ShacoConfig.ult then
			if targetR~=nil and myHero.SpellNameR=="hallucinateguide" and CanCastSpell('R') and RTimer<os.clock() then
				local targetghost=nil
				for i=0,2000,400 do
					for j=1,5,1 do
						--print("\nI: "..i)
						--print("\nJ: "..j)
						targetghost=GetWeakEnemy("PHYS",800+i,"BASIC",j)
						
						if RTimer<os.clock() and targetghost~=nil  and shacocopy~=nil and GetD(shacocopy,targetghost)<600 and not runningAway(targetghost,shacocopy) then
							CastSpellTarget('R',targetghost)
							RTimer=os.clock()+1
							break
						elseif ghost==true and RTimer<os.clock() and targetghost~=nil and shacocopy~=nil and GetD(shacocopy,targetghost)<350 then
							CastSpellTarget('R',targetghost)
							RTimer=os.clock()+1
							break
						elseif ghost==true and RTimer<os.clock() and targetghost~=nil and i==2000 and j==5 then
							CastSpellTarget('R',targetghost)
							RTimer=os.clock()+1
							break
						elseif targetghost==nil then
							break
						end
					end
					if targetghost~=nil and RTimer>os.clock() then
						break
					end
				end
			end
		end


	
	if ShacoConfig.ks then ignite() 
	killsteal() 
	end
	if ShacoConfig.smite then smitesteal() end
	

	if IsChatOpen() == 0 and ShacoConfig.box then Box() end
			
	if IsChatOpen() == 0 and ShacoConfig.teamfight then
		if target~=nil then
			
					
					if CanCastSpell('R') and myHero.SpellNameR~="hallucinateguide" and (myHero.health<0.4*myHero.maxHealth and surrounded(myHero)) or (myHero.health<0.15*myHero.maxHealth and enemyInRange~=nil) then
						CastSpellTarget('R',myHero)
					end
					if CanCastSpell('E') and GetD(target)<625 then
						CastSpellTarget('E',target)
					end
					if CanCastSpell('W') and GetD(target)<425 then
						CastSpellXYZ('W',twfx,0,twfz)
					end
					if GetD(target)<400 then
						CastSummonerExhaust(target)
						UseAllItems(target)
					elseif GetD(target)<600 then
						CastSummonerExhaust(target)
						UseAllItems(target)
					end
						
					if CanCastSpell('Q') and GetD(target)<650 then
						Q(target)
					end
						AttackTarget(target)		
				

			
		else
			MoveToMouse()
		end
		
		
	end


	if IsChatOpen() == 0 and ShacoConfig.h then
		harass()
	end

	
	
	if drawskillshot == true then
        for i=1, #skillshotArray, 1 do
            if skillshotArray[i].shot == 1 then
                local radius = skillshotArray[i].radius
                local color = skillshotArray[i].color
				if skillshotArray[i].isline == false then
					for number, point in pairs(skillshotArray[i].skillshotpoint) do
						DrawCircle(point.x, point.y, point.z, radius, color)
					end
				else
					startVector = Vector(skillshotArray[i].p1x,skillshotArray[i].p1y,skillshotArray[i].p1z)
					endVector = Vector(skillshotArray[i].p2x,skillshotArray[i].p2y,skillshotArray[i].p2z)
					directionVector = (endVector-startVector):normalized()
					local angle=0
					if (math.abs(directionVector.x)<.00001) then
						if directionVector.z > 0 then angle=90
						elseif directionVector.z < 0 then angle=270
						else angle=0
						end
					else
						local theta = math.deg(math.atan(directionVector.z / directionVector.x))
						if directionVector.x < 0 then theta = theta + 180 end
						if theta < 0 then theta = theta + 360 end
						angle=theta
					end
				angle=((90-angle)*2*math.pi)/360
				DrawLine(startVector.x, startVector.y, startVector.z, GetDistance(startVector, endVector)+170, 1,angle,radius)
				end
            end
        end
    end
	for i=1, #skillshotArray, 1 do 
		if os.clock() > (skillshotArray[i].lastshot + skillshotArray[i].time) then
        	skillshotArray[i].shot = 0
    	end
    end
        
		if ShacoConfig.e and IsChatOpen()==0 then
			if CanCastSpell('Q') then
				CastSpellXYZ('Q',mousePos.x,0,mousePos.z)
			end
			MoveToMouse()
		end
end
     

     

function OnProcessSpell(unit, spell)
        if unit.charName==myHero.charName then
        --printtext("\nS "..spell.name.."  " ..os.clock().."\n")        
        
 
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
                                                zhonyas()
                                                CastSummonerBarrier()
                                                CastSummonerHeal()
                                        end
                               
                                elseif spell.name == W then
                                        if spellDmg[unit.name] and getDmg("W",myHero,unit)~=nil and getDmg("W",myHero,unit) > myHero.health then
                                                zhonyas()
                                                CastSummonerBarrier()
                                                CastSummonerHeal()
                                        end
                               
                                elseif spell.name == E then
                                        if spellDmg[unit.name] and getDmg("E",myHero,unit)~=nil and getDmg("E",myHero,unit) > myHero.health then
                                                zhonyas()
                                                CastSummonerBarrier()
                                                CastSummonerHeal()
                                        end
 
                                elseif spell.name == R then
                                        if spellDmg[unit.name] and getDmg("R",myHero,unit)~=nil and getDmg("R",myHero,unit) > myHero.health then
                                                zhonyas()
                                                CastSummonerBarrier()
                                                CastSummonerHeal()
                                        end
                               
                                elseif spell.name:find("BasicAttack") or spell.name:find("BasicAttack2") or spell.name:find("BasicaAttack3")  or spell.name:find("ChaosTurretFire") then
                                        if (unit.baseDamage + unit.addDamage) > myHero.health then
                                                zhonyas()
                                                CastSummonerBarrier()
                                                CastSummonerHeal()
                                        end    
                                elseif spell.name:find("CritAttack") then
                                        if 2*(unit.baseDamage + unit.addDamage) > myHero.health then
                                                zhonyas()
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
 
function zhonyas()
        if GetInventorySlot(3157)~=nil then
                k = GetInventorySlot(3157)
                CastSpellTarget(tostring(k),myHero)
        elseif GetInventorySlot(3090)~=nil then
                k = GetInventorySlot(3090)
                CastSpellTarget(tostring(k),myHero)
        end
end
 
 
 function OnCreateObj(obj)
 
	if obj~=nil and string.find(obj.name,"ShacoCopy") and obj.team==myHero.team then
		shacocopy=obj
	end
 
 end
 ------------------------------------------------------ Check If In Spell Stuff
 
function dodgeaoe(pos1, pos2, radius)
    local calc = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
    if calc < radius then
               
                                zhonyas()
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
       
                                zhonyas()
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
               
                                zhonyas()
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


function harass()
	if target~=nil then
		if GetD(target)<425 and CanCastSpell('W') then
			CastSpellXYZ('W',twfx,0,twfz)
		end
		if GetD(target)<625 and CanCastSpell('E') then
			CastSpellTarget('E',target)
		end
		AttackTarget(target)
	else
		MoveToMouse()
	end

end



function Box()
	if GetSpellLevel("W")>0 and CanCastSpell("W") then
		for i,location in pairs(boxSpots) do
			if location ~=nil and location.x~=nil then
				local mouse={x=mousePos.x,y=0,z=mousePos.z}
				local loc={x=location.x,y=0,z=location.z}
				if GetD(loc,mouse)<300 then
					DrawCircle(location.x,0,location.z,300,1)
					DrawCircle(location.x,0,location.z,25,1)
				else
					DrawCircle(location.x,0,location.z,300,2)
					DrawCircle(location.x,0,location.z,25,2)
				end
				if GetD(loc)<425 and CanCastSpell("W") then
					CastSpellXYZ("W",location.x,0,location.z)
				end
			end
		end
	end
	MoveToMouse()
end


function smitesteal()
if myHero.SummonerD == "SummonerSmite" then
CastHotkey("AUTO 100,0 SPELLF:SMITESTEAL RANGE=700 TRUE COOLDOWN")
return
end
if myHero.SummonerF == "SummonerSmite" then
CastHotkey("AUTO 100,0 SPELLF:SMITESTEAL RANGE=700 TRUE COOLDOWN")
return
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


function killsteal()
	if target~=nil then
		local EDMG = getDmg('E',target,myHero)*CanUseSpell('E')
		local AA = getDmg('AD',target,myHero)
		
		if target.health<AA+EDMG and GetD(target)<250 then
			CastSpellTarget('E',target)
			AttackTarget(target)
		end
		if target.health<EDMG and GetD(target)<625 then
			CastSpellTarget('E',target)
		end
		if target.health<(AA)*CanUseSpell('Q') and GetD(target)>275 and GetD(target)<450 and target.health>EDMG then
			local tsafe=true
                                run_every(1,findTurret)
                                for _, tur in ipairs(enemyTurrets) do
                                        if tur~=nil then
                                               
                                                if target~=nil and GetD(tur.object,target)>tur.range then
                                                        tsafe=true
                                                elseif target~=nil and GetD(tur.object,target)<=tur.range then
                                                        tsafe=false
                                                else
                                                        tsafe=false
                                                end
                               
                                                if tsafe==false then
                                                        break
                                                end
                                        end
                                end   
			if tsafe==true then  
			CastSpellXYZ('Q',tqfx,0,tqfz)
			end
		end
		
		if target600~=nil and target600.health<ignitedamage and ignitedamage~=0 then
			CastSummonerIgnite(target600)
		end
		
	end
end

function runningAway(slowtarget)
   local d1 = GetD(slowtarget)
   local x, y, z = GetFireahead(slowtarget,2,0)
   local d2 = GetD({x=x, y=y, z=z})
   local d3 = GetD({x=x, y=y, z=z},slowtarget)
   local angle = math.acos((d2*d2-d3*d3-d1*d1)/(-2*d3*d1))
   
   return angle%(2*math.pi)>math.pi/2 and angle%(2*math.pi)<math.pi*3/2
 
end

function isMoving(unitM)
	local mx,my,mz=GetFireahead(unitM,5,0)
	if mx==unitM.x and mz==unitM.z then
		return false
	else
		return true
	end

end

function Q(enemy)
	local dist= GetD(enemy)
	local eqfx,eqfy,eqfz=GetFireahead(enemy,2,0)
	if GetD(enemy)<420 and not runningAway(enemy) then
		if isMoving(enemy) then
			if enemy.x==myHero.x then
					tx = enemy.x
					if enemy.z>myHero.z then
							tz = enemy.z-(-0.3*enemy.movespeed)
					else
							tz = enemy.z+(-0.3*enemy.movespeed)
					end
		   
			elseif enemy.z==myHero.z then
					tz = enemy.z
					if enemy.x>myHero.x then
							tx = enemy.x-(-0.3*enemy.movespeed)
					else
							tx = enemy.x+(-0.3*enemy.movespeed)
					end
		   
			elseif enemy.x>myHero.x then
					angle = math.asin((enemy.x-myHero.x)/dist)
					zs = (-0.3*enemy.movespeed)*math.cos(angle)
					xs = (-0.3*enemy.movespeed)*math.sin(angle)
					if enemy.z>myHero.z then
							tx = enemy.x-xs
							tz = enemy.z-zs
					elseif enemy.z<myHero.z then
							tx = enemy.x-xs
							tz = enemy.z+zs
					end
		   
			elseif enemy.x<myHero.x then
					angle = math.asin((myHero.x-enemy.x)/dist)
					zs = (-0.3*enemy.movespeed)*math.cos(angle)
					xs = (-0.3*enemy.movespeed)*math.sin(angle)
					if enemy.z>myHero.z then
							tx = enemy.x+xs
							tz = enemy.z-zs
					elseif enemy.z<myHero.z then
							tx = enemy.x+xs
							tz = enemy.z+zs
					end 
			end
		elseif not isMoving(enemy) then
			if enemy.x==myHero.x then
					tx = enemy.x
					if enemy.z>myHero.z then
							tz = enemy.z-(100)
					else
							tz = enemy.z+(100)
					end
		   
			elseif enemy.z==myHero.z then
					tz = enemy.z
					if enemy.x>myHero.x then
							tx = enemy.x-(100)
					else
							tx = enemy.x+(100)
					end
		   
			elseif enemy.x>myHero.x then
					angle = math.asin((enemy.x-myHero.x)/dist)
					zs = (-100)*math.cos(angle)
					xs = (-100)*math.sin(angle)
					if enemy.z>myHero.z then
							tx = enemy.x-xs
							tz = enemy.z-zs
					elseif enemy.z<myHero.z then
							tx = enemy.x-xs
							tz = enemy.z+zs
					end
		   
			elseif enemy.x<myHero.x then
					angle = math.asin((myHero.x-enemy.x)/dist)
					zs = (-100)*math.cos(angle)
					xs = (-100)*math.sin(angle)
					if enemy.z>myHero.z then
							tx = enemy.x+xs
							tz = enemy.z-zs
					elseif enemy.z<myHero.z then
							tx = enemy.x+xs
							tz = enemy.z+zs
					end 
			end
		
		end
			CastSpellXYZ('Q',tx,0,tz)
	elseif GetD(enemy)>=420 and not runningAway(enemy) then
	elseif GetD(enemy)<420 and  runningAway(enemy) then
		if isMoving(enemy) then
			if enemy.x==myHero.x then
					tx = enemy.x
					if enemy.z>myHero.z then
							tz = enemy.z-(0.3*enemy.movespeed)
					else
							tz = enemy.z+(0.3*enemy.movespeed)
					end
		   
			elseif enemy.z==myHero.z then
					tz = enemy.z
					if enemy.x>myHero.x then
							tx = enemy.x-(0.3*enemy.movespeed)
					else
							tx = enemy.x+(0.3*enemy.movespeed)
					end
		   
			elseif enemy.x>myHero.x then
					angle = math.asin((enemy.x-myHero.x)/dist)
					zs = (0.3*enemy.movespeed)*math.cos(angle)
					xs = (0.3*enemy.movespeed)*math.sin(angle)
					if enemy.z>myHero.z then
							tx = enemy.x-xs
							tz = enemy.z-zs
					elseif enemy.z<myHero.z then
							tx = enemy.x-xs
							tz = enemy.z+zs
					end
		   
			elseif enemy.x<myHero.x then
					angle = math.asin((myHero.x-enemy.x)/dist)
					zs = (0.3*enemy.movespeed)*math.cos(angle)
					xs = (0.3*enemy.movespeed)*math.sin(angle)
					if enemy.z>myHero.z then
							tx = enemy.x+xs
							tz = enemy.z-zs
					elseif enemy.z<myHero.z then
							tx = enemy.x+xs
							tz = enemy.z+zs
					end 
			end
		elseif not isMoving(enemy) then
			if enemy.x==myHero.x then
					tx = enemy.x
					if enemy.z>myHero.z then
							tz = enemy.z-(100)
					else
							tz = enemy.z+(100)
					end
		   
			elseif enemy.z==myHero.z then
					tz = enemy.z
					if enemy.x>myHero.x then
							tx = enemy.x-(100)
					else
							tx = enemy.x+(100)
					end
		   
			elseif enemy.x>myHero.x then
					angle = math.asin((enemy.x-myHero.x)/dist)
					zs = (100)*math.cos(angle)
					xs = (100)*math.sin(angle)
					if enemy.z>myHero.z then
							tx = enemy.x-xs
							tz = enemy.z-zs
					elseif enemy.z<myHero.z then
							tx = enemy.x-xs
							tz = enemy.z+zs
					end
		   
			elseif enemy.x<myHero.x then
					angle = math.asin((myHero.x-enemy.x)/dist)
					zs = (100)*math.cos(angle)
					xs = (100)*math.sin(angle)
					if enemy.z>myHero.z then
							tx = enemy.x+xs
							tz = enemy.z-zs
					elseif enemy.z<myHero.z then
							tx = enemy.x+xs
							tz = enemy.z+zs
					end 
			end
		
		end
			CastSpellXYZ('Q',tx,0,tz)
	elseif GetD(enemy)>=420 and  runningAway(enemy) then
		CastSpellXYZ("Q",eqfx,0,eqfz)
		
	end
end


function OnDraw()

	if myHero.dead~=1 then
		if CanUseSpell('Q')==1 then
			CustomCircle(400,3,3,myHero)
		end
		if CanUseSpell('W')==1 then
			CustomCircle(425,3,2,myHero)
		end

		if CanUseSpell('E')==1 then
			CustomCircle(625,10,1,myHero)
		end
		if CanUseSpell('R')==1 then
			CustomCircle(2400,10,4,myHero)
		end
	end
	if target~=nil then
		CustomCircle(100,3,5,target)
		
		local EDMG = getDmg('E',target,myHero)*CanUseSpell('E')
		local AA = getDmg('AD',target,myHero)
		if target.health<EDMG+AA then
			CustomCircle(100,10,2,target)
		end
	end
end




function surrounded(self)
	local count=0
	for i=1, objManager:GetMaxHeroes(), 1 do
		hero = objManager:GetHero(i)
		if hero~=nil and hero.team~=myHero.team and hero.visible==1 and GetD(self,hero)<650 then
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
                table.insert(skillshotArray,{name= "DravenRTimer", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 20000, type = 1, radius = 100, color= colorcyan, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
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



function findTurret()

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

SetTimerCallback("Run")