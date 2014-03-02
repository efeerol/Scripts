require "Utils"
require 'spell_damage'

printtext("\nBrand New\n")
printtext("\nBy Malbert\n")
printtext("\nVersion 1.8\n")

local target
local wdelay=6.25
local qdelay=5.5
local qspeed=14.5
local ABlaze={}
local checkFire=false
local tqfax,tqfay,tqfaz
local tqfa={}
local tfax,tfay,tfaz
local tfa={}

local QRDY=0
local WRDY=0
local ERDY=0
local RRDY=0

local targetItems={3144,3153,3128,3092,3146}
--Bilgewater,BoTRK,DFG,FrostQueen,Hextech
local aoeItems={3184,3143,3074,3180,3131,3069,3077,3023,3290,3142}
--Entropy,Randuins,Hydra,Odyns,SwordDivine,TalismanAsc,Tiamat,TwinShadows,TwinShadows,YoGBlade
local shieldItems={3410,3190,3040}
--FaceofMountainLocketIS,Seraph(Arch)
local allyItems={3222}
--MikaelsCrucible,
local cleanseItems={3139,3140}
--MercScimitar,QuickSilver
local DFG=3128

local checkDie=false


local egg = {team = 0, enemy = 0}
local zac = {team = 0, enemy = 0}
local aatrox = {team = 0, enemy = 0}
local cc = 0
local skillshotArray = {}
local colorcyan = 0x0000FFFF
local coloryellow = 0xFFFFFF00
local colorgreen = 0xFF00FF00
local drawskillshot = true
local dodgeskillshot = false
local playerradius = 150
local skillshotcharexist = false
local show_allies=0

local _registry = {}

BrandConfig = scriptConfig('Mals Brand Config', 'BrandConfig')
BrandConfig:addParam('teamfight', 'AutoTeamFight', SCRIPT_PARAM_ONKEYDOWN, false, 84)
BrandConfig:addParam('harass', 'Harass', SCRIPT_PARAM_ONKEYDOWN, false, 88)

BrandConfig:addParam('ult', 'Ult in TF', SCRIPT_PARAM_ONKEYTOGGLE, true, 57)
BrandConfig:addParam('ks', 'Killsteal', SCRIPT_PARAM_ONKEYTOGGLE, true, 48)

BrandConfig:addParam('rt', "R Threshold", SCRIPT_PARAM_NUMERICUPDOWN, 1, 187,0,5,1)
BrandConfig:addParam('wd', "W Delay", SCRIPT_PARAM_NUMERICUPDOWN, 6.25, 189,4,8,0.1)
BrandConfig:addParam('qd', "Q Delay", SCRIPT_PARAM_NUMERICUPDOWN, 5.2, 219,4.5,6.5,0.1)
BrandConfig:addParam('qs', "Q Speed", SCRIPT_PARAM_NUMERICUPDOWN, 15.8, 221,14.5,16.5,0.1)
BrandConfig:addParam('ping', "Ping", SCRIPT_PARAM_NUMERICUPDOWN, 60, 220,0,300,5)

BrandConfig:addParam('zh', 'Zhonyas', SCRIPT_PARAM_ONOFF, true)
BrandConfig:addParam('nm', 'NearMouse Targetting', SCRIPT_PARAM_ONOFF, true)
BrandConfig:permaShow('ult')
BrandConfig:permaShow('ks')
BrandConfig:permaShow('zh')
BrandConfig:permaShow('nm')

--q  5.5-6.5 14.5-15.2-15.5-16.5  BrandBlaze - BrandBlazeMissile 900
--w BrandFissure 900
--e  BrandConflagration 625 
--r  BrandWildFire 750

function Run()
	if BrandConfig.nm==true then
		target = GetBestEnemy("MAGIC",950,"NEARMOUSE")
	else
		target = GetBestEnemy("MAGIC",950)
	end
        if cc<40 then cc=cc+1 if cc==30 then LoadTable() end end
	checkDie=false
        if BrandConfig.zh then
                checkDie=true
                if target~=nil and myHero.health<myHero.maxHealth*15/100 then
                        zhonyas()
                end
        else
                checkDie=false
        end

		wdelay=BrandConfig.wd
		qdelay=BrandConfig.qd
		qspeed=BrandConfig.qs
		
	for i=1, objManager:GetMaxHeroes(), 1 do
		hero = objManager:GetHero(i)
		if hero~=nil and hero.team~=myHero.team then
			if not ABlaze[hero.name] then
				ABlaze[hero.name]={name=hero.name,unit=hero,ABlaze=0,counter=0,enemiesNear=0,enemies4R=0}
				--print("\nAdded: "..ABlaze[hero.name].name)
			--table.insert(enemyInStacks,hero.name)
			end
		end
	end
		
		if target~=nil then
			tfax,tfay,tfaz=GetFireahead(target,wdelay,0)
			tfa={x=tfax,y=tfay,z=tfaz}
			tqfax,tqfay,tqfaz=GetFireahead(target,qdelay,qspeed)
			tqfa={x=tqfax,y=tqfay,z=tqfaz}
		end
		if BrandConfig.teamfight and IsChatOpen() == 0 then
			Fight()
		end

		if BrandConfig.harass and IsChatOpen() == 0 then
			Harass()
		end
		
		if BrandConfig.ks then
			Killsteal()
		end
		
	        ------------
        if myHero.SpellTimeQ > 1.0 and GetSpellLevel('Q') > 0 and (myHero.mana>=(50)) then
                QRDY = 1
                else QRDY = 0
        end
        if myHero.SpellTimeW > 1.0 and GetSpellLevel('W') > 0 and myHero.mana>=(65+5*GetSpellLevel('W')) then
                WRDY = 1
                else WRDY = 0
        end
        if myHero.SpellTimeE > 1.0 and GetSpellLevel('E') > 0 and myHero.mana>=(65+5*GetSpellLevel('E')) then
                ERDY = 1
                else ERDY = 0
        end
        if myHero.SpellTimeR > 1.0 and GetSpellLevel('R') > 0 and (myHero.mana>=(100)) then
                RRDY = 1
        else RRDY = 0 end
        --------------------------
		if checkFire==true or (ERDY==1 and target~=nil) or (RRDY==1 and BrandConfig.ult) then
			checkABlaze()		
		end
end

function checkABlaze()
	local checkCount=0
	for i, enemy in pairs(ABlaze) do
		if enemy~=nil and enemy.unit~=nil and enemy.unit.dead~=1 and enemy.ABlaze>0 then
				--print("\n  Checking\n")
			checkCount=checkCount+1
			if os.clock()>enemy.counter then
				enemy.ABlaze=0
				print("\n  EnemyCooledOff -> "..enemy.name)
				checkCount=checkCount-1			
			end
		end
		enemy.enemiesNear=0
		enemy.enemies4R=0
		for j, enemyC in pairs(ABlaze) do
			if enemyC~=nil and enemyC.unit~=nil and enemyC.name~=enemy.name and enemyC.unit.dead~=1 and enemyC.unit.visible~=0 and IsInvulnerable(enemyC.unit).status~=1 then
				if GetD(enemyC.unit,enemy.unit)<350 then
					enemy.enemiesNear=enemy.enemiesNear+1
					enemy.enemies4R=enemy.enemies4R+1
				elseif GetD(enemyC.unit,enemy.unit)<600 then
					enemy.enemies4R=enemy.enemies4R+1
				end
			end
		end
	end
	if checkCount==0 then
		checkFire=false
	end
end

function Fight()
	if target~=nil then
		
		if QRDY==1 and ABlaze[target.name].ABlaze>0 and GetD(tqfa)<925 and CreepBlock(tqfa.x,tqfa.y,tqfa.z,100) == 0 then
			if GetD(tqfa)<100 then
				CastSpellXYZ("Q",target.x,target.y,target.z,0)
			else
				CastSpellXYZ("Q",tqfax,tqfay,tqfaz,0)
			end
		elseif GetInventorySlot(3128)~=nil and myHero["SpellTime"..GetInventorySlot(3128)]>1.0 and GetD(target)<600 then
			CastSpellTarget(tostring(GetInventorySlot(3128)),target)
		elseif ERDY==1 and (ABlaze[target.name].enemiesNear==0 or ABlaze[target.name].ABlaze>0) and GetD(target)<650 then
			CastSpellTarget("E",target)		
		elseif WRDY==1 and GetD(tfa)<925 then
			local pos=GetMECFA(250,925,target,wdelay,0)
			if pos~=nil and pos.x~=nil then
					CastSpellXYZ("W",pos.x,0,pos.z)
			else
					CastSpellXYZ("W",tfax,tfay,tfaz)
			end
		elseif RRDY==1 and BrandConfig.ult and BrandConfig.rt<=ABlaze[target.name].enemies4R and GetD(target)<775 then
			CastSpellTarget("R",target)
		else
			AttackTarget(target)
		end
	else
		MoveToMouse()
	end
end

function Harass()
	if target~=nil then
		
		if WRDY==1 and GetD(tfa)<925 then
			local pos=GetMECFA(250,925,target,wdelay,0)
			if pos~=nil and pos.x~=nil then
					CastSpellXYZ("W",pos.x,0,pos.z)
			else
					CastSpellXYZ("W",tfax,tfay,tfaz)
			end
		elseif QRDY==1 and GetD(tqfa)<925 and CreepBlock(tqfa.x,tqfa.y,tqfa.z,100) == 0 then
			if GetD(tqfa)<100 then
				CastSpellXYZ("Q",target.x,target.y,target.z,0)
			else
				CastSpellXYZ("Q",tqfax,tqfay,tqfaz,0)
			end
		elseif ERDY==1 and GetD(target)<650 then
			CastSpellTarget("E",target)		
		else
			MoveToMouse()
		end
	else
		MoveToMouse()
	end
	
end

function Killsteal()
	if target~=nil then
		local EDMG=getDmg("E",target,myHero)*ERDY
		local RDMG=getDmg("R",target,myHero)*RRDY
		local QDMG=getDmg("Q",target,myHero)*QRDY*((CreepBlock(tqfa.x,tqfa.y,tqfa.z,90)+1)%2)
		
		if target.health<EDMG+RDMG and GetD(target)<625 then
			CastSpellTarget("E",target)
			CastSpellTarget("R",target)
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

function OnDraw()
	if myHero.dead==0 then
		if QRDY==1 or WRDY==1 then
			CustomCircle(900,2,3,myHero)
		end
		if RRDY==1 then
			CustomCircle(750,2,2,myHero)		
		end
		if ERDY==1 then
			CustomCircle(625,2,4,myHero)		
		end
	end
end

function OnCreateObj(obj)
	--if obj~=nil and GetD(obj)<600 then
		--printtext("\nO "..obj.charName.." Oname "..obj.name)
	--end
	if obj~=nil and string.find(obj.charName,"BrandFireMark") then
		for i, enemy in pairs(ABlaze) do
			if enemy~=nil and enemy.unit~=nil and enemy.unit.dead~=1 and GetD(obj,enemy.unit)<10 then
				print("Added -> "..enemy.name)
				enemy.ABlaze=1
				enemy.counter=os.clock()+4
				checkFire=true
				break
			end
		end
	
        elseif obj.charName == 'EggTimer.troy' then
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
        if unit.charName==myHero.charName then
       -- printtext("\nS "..spell.name.."  " ..os.clock().." Q:"..myHero.SpellNameQ.." W:"..myHero.SpellNameW.." E:"..myHero.SpellNameE.." R:"..myHero.SpellNameR.."\n")    
			if string.find(spell.name,"XerathLocusOfPower2") then
				
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
        if GetInventorySlot(3157)~=nil and myHero["SpellTime"..GetInventorySlot(3157)]>1.0 then
                k = GetInventorySlot(3157)
                CastSpellTarget(tostring(k),myHero)
        elseif GetInventorySlot(3090)~=nil and myHero["SpellTime"..GetInventorySlot(3090)]>1.0 then
                k = GetInventorySlot(3090)
                CastSpellTarget(tostring(k),myHero)
        end
end
--[[
 _______   ______   .__   __.  __.___________.   .___________. ______    __    __    ______  __    __    
|       \ /  __  \  |  \ |  | (_ |           |   |           |/  __  \  |  |  |  |  /      ||  |  |  |   
|  .--.  |  |  |  | |   \|  |  |/`---|  |----`   `---|  |----|  |  |  | |  |  |  | |  ,----'|  |__|  |   
|  |  |  |  |  |  | |  . `  |        |  |            |  |    |  |  |  | |  |  |  | |  |     |   __   |   
|  '--'  |  `--'  | |  |\   |        |  |            |  |    |  `--'  | |  `--'  | |  `----.|  |  |  |   
|_______/ \______/  |__| \__|        |__|            |__|     \______/   \______/   \______||__|  |__|   
     ___      .__   __. ____    ____ .___________.__    __   __  .__   __.   _______                     
    /   \     |  \ |  | \   \  /   / |           |  |  |  | |  | |  \ |  |  /  _____|                    
   /  ^  \    |   \|  |  \   \/   /  `---|  |----|  |__|  | |  | |   \|  | |  |  __                      
  /  /_\  \   |  . `  |   \_    _/       |  |    |   __   | |  | |  . `  | |  | |_ |                     
 /  _____  \  |  |\   |     |  |         |  |    |  |  |  | |  | |  |\   | |  |__| |                     
/__/     \__\ |__| \__|     |__|         |__|    |__|  |__| |__| |__| \__|  \______|                     
.______    _______  __        ______   ____    __    ____    .___________.__    __   __       _______.   
|   _  \  |   ____||  |      /  __  \  \   \  /  \  /   /    |           |  |  |  | |  |     /       |   
|  |_)  | |  |__   |  |     |  |  |  |  \   \/    \/   /     `---|  |----|  |__|  | |  |    |   (----`   
|   _  <  |   __|  |  |     |  |  |  |   \            /          |  |    |   __   | |  |     \   \       
|  |_)  | |  |____ |  `----.|  `--'  |    \    /\    /           |  |    |  |  |  | |  | .----)   |      
|______/  |_______||_______| \______/      \__/  \__/            |__|    |__|  |__| |__| |_______/       
 __       __  .__   __.  _______                                                                         
|  |     |  | |  \ |  | |   ____|                                                                        
|  |     |  | |   \|  | |  |__                                                                           
|  |     |  | |  . `  | |   __|                                                                          
|  `----.|  | |  |\   | |  |____                                                                         
|_______||__| |__| \__| |_______|                                                                        
                                                                                                         

 --]]------------------------------------------------------ Check If In Spell Stuff
 
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

function runningAway(slowtarget)
   local d1 = GetD(slowtarget)
   local x, y, z = GetFireahead(slowtarget,5,0)
   local d2 = GetD({x=x, y=y, z=z})
   local d3 = GetD({x=x, y=y, z=z},slowtarget)
   local angle = math.acos((d2*d2-d3*d3-d1*d1)/(-2*d3*d1))
   
   return angle%(2*math.pi)>math.pi/2 and angle%(2*math.pi)<math.pi*3/2
 
end

function isMoving(unitM)
        local mx,my,mz=GetFireahead(unitM,5,0)
        if math.abs(mx-unitM.x)<20 and math.abs(mz-unitM.z)<20 then
                return false
        else
                return true
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


function GetMECFA(radius, range, target, pdelay, pspeed)
    assert(type(radius) == "number" and type(range) == "number" and (target == nil or target.team ~= nil), "GetMEC: wrong argument types (expected <number>, <number>, <object> or nil)")
    local points = {}
    for i = 1, objManager:GetMaxHeroes() do
        local object = objManager:GetHero(i)
        if (target == nil and ValidTarget(object, (range + radius))) or (target and ValidTarget(object, (range + radius), (target.team ~= myHero.team)) and (ValidTargetNear(object, radius * 2, target) or object.networkID == target.networkID)) then
            local cx,cy,cz=GetFireahead(object,pdelay,pspeed)
			local coordinates={x=cx,y=cy,z=cz}
			table.insert(points, Vector(coordinates))
        end
    end
    return _CalcSpellPosForGroup(radius, range, points)
end

function LoadTable()
        for i = 1, objManager:GetMaxHeroes() do
                local enemy = objManager:GetHero(i)
                if (enemy ~= nil and enemy.team ~= myHero.team) then
                        if enemy.name == 'Aatrox' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 3, radius = 225, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 125, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                        end
                        if enemy.name == 'Ahri' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 880, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                        end
                        if enemy.name == 'Alistar' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 50, type = 3, radius = 200, color= 0x0000FFFF, time = 0.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                        end
                        if enemy.name == 'Amumu' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                        end
                        if enemy.name == 'Anivia' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 90, color= 0x0000FFFF, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                        end
                        if enemy.name == 'Annie' then
                                table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 3, radius = 300, color= 0x0000FFFF, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                        end
                        if enemy.name == 'Ashe' then
                                table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 50000, type = 4, radius = 120, color= 0x0000FFFF, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                        end
                        if enemy.name == 'Blitzcrank' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 120, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                        end
                        if enemy.name == 'Brand' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 50, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
                                table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Cassiopeia' then
                                table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 175, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 125, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Caitlyn' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 50, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Corki' then
                                table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1225, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 2, radius = 150, color= 0x0000FFFF, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Chogath' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 275, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Darius' then
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 540, type = 1, radius = 125, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Diana' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 205, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Draven' then
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 125, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                                table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 1, radius = 100, color= 0x0000FFFF, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'DrMundo' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Elise' and enemy.range>300 then
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Ezreal' then
                                table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                                table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 4, radius = 150, color= 0x0000FFFF, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                        end
                        if enemy.name == 'FiddleSticks' then
                                table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 600, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                        end
                        if enemy.name == 'Fizz' then
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 400, type = 3, radius = 300, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })                         
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 550, type = 1, radius = 100, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1275, type = 2, radius = 100, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Galio' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 905, type = 3, radius = 200, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 120, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Gragas' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 320, color= 0xFFFFFF00, time = 2.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 2, radius = 60, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 3, radius = 400, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Graves' then
                                table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 110, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 750, type = 1, radius = 50, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 3, radius = 275, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Hecarim' then
                                table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 125, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Heimerdinger' then
                                table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 225, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        --[[if enemy.name == 'Irelia' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 80, color= 0x0000FFFF, time = 0.8, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end]]
                        if enemy.name == 'Janna' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1700, type = 1, radius = 100, color= 0x0000FFFF, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'JarvanIV' then
                                table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 830, type = 3, radius = 150, color= 0xFFFFFF00, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 770, type = 1, radius = 70, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Jayce' and enemy.range>300 then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1500, type = 1, radius = 125, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Jinx' then
                                table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1500, type = 1.5, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5000, type = 3, radius = 225, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Karma' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Karthus' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 875, type = 3, radius = 150, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Kassadin' then
                                table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 5, radius = 150, color= 0xFF00FF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Kennen' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 75, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Khazix' then 
                                table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 75, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })    
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 310, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'KogMaw' then
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1115, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2200, type = 3, radius = 200, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Leblanc' then
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 3, radius = 250, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'LeeSin' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 975, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Leona' then
                                table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 160, color= 0x0000FFFF, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Lissandra' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 725, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 120, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Lucian' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= 0x0000FFFF, time = 0.75, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Lulu' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 50, color= 0x0000FFFF, time = 1, isline = true, px =0, py =0 , pz =0, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Lux' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1175, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 300, color= 0xFFFFFF00, time = 2.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 3000, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Malphite' then
                                table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 325, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Malzahar' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 100 , color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 250 , color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Maokai' then
                                table.insert(skillshotArray,{name= 'MaokaiTrunkLineMissile', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 3, radius = 350 , color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'MissFortune' then
                                table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 400, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                        end
                        if enemy.name == 'Morgana' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 100, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 350, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                        end
                        if enemy.name == 'Nami' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 875, type = 3, radius = 210, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2750, type = 1, radius = 335, color= 0xFFFFFF00, time = 3, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Nautilus' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Nidalee' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1500, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                        end
                        if enemy.name == 'Nocturne' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1200, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                        end
                        if enemy.name == 'Olaf' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 2, radius = 100, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Orianna' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 825, type = 3, radius = 150, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                        end
                        if enemy.name == 'Quinn' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1025, type = 1, radius = 150, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Renekton' then
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 450, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                        end
                        if enemy.name == 'Rumble' then
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 100, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                                table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1700, type = 1, radius = 100, color= 0xFFFFFF00, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                        end
                        if enemy.name == 'Sejuani' then
                                table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1150, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = f, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Shen' then
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 2, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                        end
                        if enemy.name == 'Shyvana' then
                                table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Sivir' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Skarner' then
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Sona' then
                                table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 150, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Swain' then
                                table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 265 , color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Syndra' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 250, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 650, type = 1, radius = 100, color= 0xFFFFFF00, time = 0.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 210, color= 0x0000FFFF, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Thresh' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 160, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Tristana' then
                                table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 200, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Tryndamere' then
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 2, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'TwistedFate' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1450, type = 1, radius = 100, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Urgot' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 80, color= 0x0000FFFF, time = 0.8, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 300, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                        end
                        if enemy.name == 'Varus' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1475, type = 1, radius = 50, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 80, color= 0x0000FFFF, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Veigar' then
                                table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 225, color= 0xFFFFFF00, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                        end
                        if enemy.name == 'Vi' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 725, type = 1, radius = 75, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Viktor' then
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 700, type = 1, radius = 80, color= 0xFFFFFF00, time = 2})
                        end
                        if enemy.name == 'Xerath' then
                                table.insert(skillshotArray,{name= 'xeratharcanopulsedamage', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= 'xeratharcanopulsedamageextended', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 80, color= 0x0000FFFF, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                                table.insert(skillshotArray,{name= 'xeratharcanebarragewrapper', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= 'xeratharcanebarragewrapperext', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 3, radius = 250, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                        end
                        if enemy.name == 'Yasuo' then
                                table.insert(skillshotArray,{name= 'YasuoQW', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 475, type = 1, radius = 75, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= 'yasuoq2w', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 475, type = 1, radius = 75, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= 'yasuoq3w', shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 125, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Zac' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 550, type = 1, radius = 100, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1550, type = 5, radius = 200, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Zed' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 55, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Ziggs' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 850, type = 3, radius = 160, color= 0xFFFFFF00, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                                table.insert(skillshotArray,{name= enemy.SpellNameW, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 225 , color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 250, color= 0xFFFFFF00, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameR, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 5300, type = 3, radius = 550, color= 0xFFFFFF00, time = 3, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                        if enemy.name == 'Zyra' then
                                table.insert(skillshotArray,{name= enemy.SpellNameQ, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 825, type = 3, radius = 275, color= 0xFFFFFF00, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                                table.insert(skillshotArray,{name= enemy.SpellNameE, shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 90, color= 0x0000FFFF, time = 2, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                        end
                end
        end
end


---------------------------------------------viTouch



Point = class()
Line = class()
Circle = class ()
Polygon = class()
LineSegment = class()
class 'Point' -- {
    function Point:__init(x, y)
 
        self.x = x
        self.y = y
 
        self.points = {self}
    end
 
    function Point:__type()
        return "Point"
    end
 
    function Point:__eq(spatialObject)
        return spatialObject:__type() == "Point" and self.x == spatialObject.x and self.y == spatialObject.y
    end
 
    function Point:__unm()
        return Point(-self.x, -self.y)
    end
 
    function Point:__add(p)
        return Point(self.x + p.x, self.y + p.y)
    end
 
    function Point:__sub(p)
        return Point(self.x - p.x, self.y - p.y)
    end
 
    function Point:__mul(p)
        if type(p) == "number" then
            return Point(self.x * p, self.y * p)
        else
            return Point(self.x * p.x, self.y * p.y)
        end
    end
 
    function Point:tostring()
        return "Point(" .. tostring(self.x) .. ", " .. tostring(self.y) .. ")"
    end
 
    function Point:__div(p)
        if type(p) == "number" then
            return Point(self.x / p, self.y / p)
        else
            return Point(self.x / p.x, self.y / p.y)
        end
    end
 
    function Point:between(point1, point2)
        local normal = Line(point1, point2):normal()
 
        return Line(point1, point1 + normal):side(self) ~= Line(point2, point2 + normal):side(self)
    end
 
    function Point:len()
        return math.sqrt(self.x * self.x + self.y * self.y)
    end
 
    function Point:normalize()
        len = self:len()
 
        self.x = self.x / len
        self.y = self.y / len
 
        return self
    end
 
    function Point:clone()
        return Point(self.x, self.y)
    end
 
    function Point:normalized()
        local a = self:clone()
        a:normalize()
        return a
    end
 
    function Point:getPoints()
        return self.points
    end
 
    function Point:getLineSegments()
        return {}
    end
 
    function Point:perpendicularFoot(line)
        local distanceFromLine = line:distance(self)
        local normalVector = line:normal():normalized()
 
        local footOfPerpendicular = self + normalVector * distanceFromLine
        if line:distance(footOfPerpendicular) > distanceFromLine then
            footOfPerpendicular = self - normalVector * distanceFromLine
        end
 
        return footOfPerpendicular
    end
 
    function Point:contains(spatialObject)
        if spatialObject:__type() == "Line" then
            return false
        elseif spatialObject:__type() == "Circle" then
            return spatialObject.point == self and spatialObject.radius == 0
        else
        for i, point in ipairs(spatialObject:getPoints()) do
            if point ~= self then
                return false
            end
        end
    end
 
        return true
    end
 
    function Point:polar()
        if math.close(self.x, 0) then
            if self.y > 0 then return 90
            elseif self.y < 0 then return 270
            else return 0
            end
        else
            local theta = math.deg(math.atan(self.y / self.x))
            if self.x < 0 then theta = theta + 180 end
            if theta < 0 then theta = theta + 360 end
            return theta
        end
    end
 
    function Point:insideOf(spatialObject)
        return spatialObject.contains(self)
    end
 
    function Point:distance(spatialObject)
        if spatialObject:__type() == "Point" then
            return math.sqrt((self.x - spatialObject.x)^2 + (self.y - spatialObject.y)^2)
        elseif spatialObject:__type() == "Line" then
            denominator = (spatialObject.points[2].x - spatialObject.points[1].x)
            if denominator == 0 then
                return math.abs(self.x - spatialObject.points[2].x)
            end
 
            m = (spatialObject.points[2].y - spatialObject.points[1].y) / denominator
 
            return math.abs((m * self.x - self.y + (spatialObject.points[1].y - m * spatialObject.points[1].x)) / math.sqrt(m * m + 1))
        elseif spatialObject:__type() == "Circle" then
            return self:distance(spatialObject.point) - spatialObject.radius
        elseif spatialObject:__type() == "LineSegment" then
            local t = ((self.x - spatialObject.points[1].x) * (spatialObject.points[2].x - spatialObject.points[1].x) + (self.y - spatialObject.points[1].y) * (spatialObject.points[2].y - spatialObject.points[1].y)) / ((spatialObject.points[2].x - spatialObject.points[1].x)^2 + (spatialObject.points[2].y - spatialObject.points[1].y)^2)
 
            if t <= 0.0 then
                return self:distance(spatialObject.points[1])
            elseif t >= 1.0 then
                return self:distance(spatialObject.points[2])
            else
                return self:distance(Line(spatialObject.points[1], spatialObject.points[2]))
            end
        else
            local minDistance = nil
 
            for i, lineSegment in ipairs(spatialObject:getLineSegments()) do
                if minDistance == nil then
                    minDistance = self:distance(lineSegment)
                else
                    minDistance = math.min(minDistance, self:distance(lineSegment))
                end
            end
 
            return minDistance
        end
    end
-- }
 
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
 
class 'Line' -- {
    function Line:__init(point1, point2)
 
        self.points = {point1, point2}
    end
 
    function Line:__type()
        return "Line"
    end
 
    function Line:__eq(spatialObject)
        return spatialObject:__type() == "Line" and self:distance(spatialObject) == 0
    end
 
    function Line:getPoints()
        return self.points
    end
 
    function Line:getLineSegments()
        return {}
    end
 
    function Line:direction()
        return self.points[2] - self.points[1]
    end
 
    function Line:normal()
        return Point(- self.points[2].y + self.points[1].y, self.points[2].x - self.points[1].x)
    end
 
    function Line:perpendicularFoot(point)
        return point:perpendicularFoot(self)
    end
 
    function Line:side(spatialObject)
        leftPoints = 0
        rightPoints = 0
        onPoints = 0
        for i, point in ipairs(spatialObject:getPoints()) do
            local result = ((self.points[2].x - self.points[1].x) * (point.y - self.points[1].y) - (self.points[2].y - self.points[1].y) * (point.x - self.points[1].x))
 
            if result < 0 then
                leftPoints = leftPoints + 1
            elseif result > 0 then
                rightPoints = rightPoints + 1
            else
                onPoints = onPoints + 1
            end
        end
 
        if leftPoints ~= 0 and rightPoints == 0 and onPoints == 0 then
            return -1
        elseif leftPoints == 0 and rightPoints ~= 0 and onPoints == 0 then
            return 1
        else
            return 0
        end
    end
 
    function Line:contains(spatialObject)
        if spatialObject:__type() == "Point" then
            return spatialObject:distance(self) == 0
        elseif spatialObject:__type() == "Line" then
            return self.points[1]:distance(spatialObject) == 0 and self.points[2]:distance(spatialObject) == 0
        elseif spatialObject:__type() == "Circle" then
            return spatialObject.point:distance(self) == 0 and spatialObject.radius == 0
        elseif spatialObject:__type() == "LineSegment" then
            return spatialObject.points[1]:distance(self) == 0 and spatialObject.points[2]:distance(self) == 0
        else
        for i, point in ipairs(spatialObject:getPoints()) do
            if point:distance(self) ~= 0 then
                return false
            end
            end
 
            return true
        end
 
        return false
    end
 
    function Line:insideOf(spatialObject)
        return spatialObject:contains(self)
    end
 
    function Line:distance(spatialObject)
        if spatialObject:__type() == "Circle" then
            return spatialObject.point:distance(self) - spatialObject.radius
        elseif spatialObject:__type() == "Line" then
            distance1 = self.points[1]:distance(spatialObject)
            distance2 = self.points[2]:distance(spatialObject)
            if distance1 ~= distance2 then
                return 0
            else
                return distance1
            end
        else
            local minDistance = nil
            for i, point in ipairs(spatialObject:getPoints()) do
                distance = point:distance(self)
                if minDistance == nil or distance <= minDistance then
                    minDistance = distance
                end
            end
 
            return minDistance
        end
    end
-- }
 
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
 
class 'Circle' -- {
    function Circle:__init(point, radius)
 
        self.point = point
        self.radius = radius
 
        self.points = {self.point}
    end
 
    function Circle:__type()
        return "Circle"
    end
 
    function Circle:__eq(spatialObject)
        return spatialObject:__type() == "Circle" and (self.point == spatialObject.point and self.radius == spatialObject.radius)
    end
 
    function Circle:getPoints()
        return self.points
    end
 
    function Circle:getLineSegments()
        return {}
    end
 
    function Circle:contains(spatialObject)
        if spatialObject:__type() == "Line" then
            return false
        elseif spatialObject:__type() == "Circle" then
            return self.radius >= spatialObject.radius + self.point:distance(spatialObject.point)
        else
            for i, point in ipairs(spatialObject:getPoints()) do
                if self.point:distance(point) >= self.radius then
                    return false
                end
            end
 
            return true
        end
    end
 
    function Circle:insideOf(spatialObject)
        return spatialObject:contains(self)
    end
 
    function Circle:distance(spatialObject)
        return self.point:distance(spatialObject) - self.radius
    end
 
    function Circle:intersectionPoints(spatialObject)
        local result = {}
 
        dx = self.point.x - spatialObject.point.x
        dy = self.point.y - spatialObject.point.y
        dist = math.sqrt(dx * dx + dy * dy)
 
        if dist > self.radius + spatialObject.radius then
            return result
        elseif dist < math.abs(self.radius - spatialObject.radius) then
            return result
        elseif (dist == 0) and (self.radius == spatialObject.radius) then
            return result
        else
            a = (self.radius * self.radius - spatialObject.radius * spatialObject.radius + dist * dist) / (2 * dist)
            h = math.sqrt(self.radius * self.radius - a * a)
 
            cx2 = self.point.x + a * (spatialObject.point.x - self.point.x) / dist
            cy2 = self.point.y + a * (spatialObject.point.y - self.point.y) / dist
 
            intersectionx1 = cx2 + h * (spatialObject.point.y - self.point.y) / dist
            intersectiony1 = cy2 - h * (spatialObject.point.x - self.point.x) / dist
            intersectionx2 = cx2 - h * (spatialObject.point.y - self.point.y) / dist
            intersectiony2 = cy2 + h * (spatialObject.point.x - self.point.x) / dist
 
            table.insert(result, Point(intersectionx1, intersectiony1))
 
            if intersectionx1 ~= intersectionx2 or intersectiony1 ~= intersectiony2 then
                table.insert(result, Point(intersectionx2, intersectiony2))
            end
        end
 
        return result
    end
 
    function Circle:tostring()
        return "Circle(Point(" .. self.point.x .. ", " .. self.point.y .. "), " .. self.radius .. ")"
    end
-- }
 
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
 
class 'LineSegment' -- {
    function LineSegment:__init(point1, point2)
 
        self.points = {point1, point2}
    end
 
    function LineSegment:__type()
        return "LineSegment"
    end
 
    function LineSegment:__eq(spatialObject)
        return spatialObject:__type() == "LineSegment" and ((self.points[1] == spatialObject.points[1] and self.points[2] == spatialObject.points[2]) or (self.points[2] == spatialObject.points[1] and self.points[1] == spatialObject.points[2]))
    end
 
    function LineSegment:getPoints()
        return self.points
    end
 
    function LineSegment:getLineSegments()
        return {self}
    end
 
    function LineSegment:direction()
        return self.points[2] - self.points[1]
    end
 
    function LineSegment:len()
        return (self.points[1] - self.points[2]):len()
    end
 
    function LineSegment:contains(spatialObject)
        if spatialObject:__type() == "Point" then
            return spatialObject:distance(self) == 0
        elseif spatialObject:__type() == "Line" then
            return false
        elseif spatialObject:__type() == "Circle" then
            return spatialObject.point:distance(self) == 0 and spatialObject.radius == 0
        elseif spatialObject:__type() == "LineSegment" then
            return spatialObject.points[1]:distance(self) == 0 and spatialObject.points[2]:distance(self) == 0
        else
        for i, point in ipairs(spatialObject:getPoints()) do
            if point:distance(self) ~= 0 then
                return false
            end
            end
 
            return true
        end
 
        return false
    end
 
    function LineSegment:insideOf(spatialObject)
        return spatialObject:contains(self)
    end
 
    function LineSegment:distance(spatialObject)
        if spatialObject:__type() == "Circle" then
            return spatialObject.point:distance(self) - spatialObject.radius
        elseif spatialObject:__type() == "Line" then
            return math.min(self.points[1]:distance(spatialObject), self.points[2]:distance(spatialObject))
        else
            local minDistance = nil
            for i, point in ipairs(spatialObject:getPoints()) do
                distance = point:distance(self)
                if minDistance == nil or distance <= minDistance then
                    minDistance = distance
                end
            end
 
            return minDistance
        end
    end
 
    function LineSegment:intersects(spatialObject)
        return #self:intersectionPoints(spatialObject) >= 1
    end
 
    function LineSegment:intersectionPoints(spatialObject)
        if spatialObject:__type()  == "LineSegment" then
            d = (spatialObject.points[2].y - spatialObject.points[1].y) * (self.points[2].x - self.points[1].x) - (spatialObject.points[2].x - spatialObject.points[1].x) * (self.points[2].y - self.points[1].y)
 
            if d ~= 0 then
                ua = ((spatialObject.points[2].x - spatialObject.points[1].x) * (self.points[1].y - spatialObject.points[1].y) - (spatialObject.points[2].y - spatialObject.points[1].y) * (self.points[1].x - spatialObject.points[1].x)) / d
                ub = ((self.points[2].x - self.points[1].x) * (self.points[1].y - spatialObject.points[1].y) - (self.points[2].y - self.points[1].y) * (self.points[1].x - spatialObject.points[1].x)) / d
 
                if ua >= 0 and ua <= 1 and ub >= 0 and ub <= 1 then
                    return {Point (self.points[1].x + (ua * (self.points[2].x - self.points[1].x)), self.points[1].y + (ua * (self.points[2].y - self.points[1].y)))}
                end
            end
        end
 
        return {}
    end
 
    function LineSegment:draw(color, width)
        drawLine(self, color or 0XFF00FF00, width or 4)
    end
-- }
 
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
 
class 'Polygon' -- {
    function Polygon:__init(...)
 
        self.points = {...}
    end
 
    function Polygon:__type()
        return "Polygon"
    end
 
    function Polygon:__eq(spatialObject)
        return spatialObject:__type() == "Polygon" -- TODO
    end
 
    function Polygon:getPoints()
        return self.points
    end
 
    function Polygon:addPoint(point)
        table.insert(self.points, point)
        self.lineSegments = nil
        self.triangles = nil
    end
 
    function Polygon:getLineSegments()
        if self.lineSegments == nil then
            self.lineSegments = {}
            for i = 1, #self.points, 1 do
                table.insert(self.lineSegments, LineSegment(self.points[i], self.points[(i % #self.points) + 1]))
            end
        end
 
        return self.lineSegments
    end
 
    function Polygon:contains(spatialObject)
        if spatialObject:__type() == "Line" then
            return false
        elseif #self.points == 3 then
            for i, point in ipairs(spatialObject:getPoints()) do
                corner1DotCorner2 = ((point.y - self.points[1].y) * (self.points[2].x - self.points[1].x)) - ((point.x - self.points[1].x) * (self.points[2].y - self.points[1].y))
                corner2DotCorner3 = ((point.y - self.points[2].y) * (self.points[3].x - self.points[2].x)) - ((point.x - self.points[2].x) * (self.points[3].y - self.points[2].y))
                corner3DotCorner1 = ((point.y - self.points[3].y) * (self.points[1].x - self.points[3].x)) - ((point.x - self.points[3].x) * (self.points[1].y - self.points[3].y))
 
                if not (corner1DotCorner2 * corner2DotCorner3 >= 0 and corner2DotCorner3 * corner3DotCorner1 >= 0) then
                    return false
                end
            end
 
            if spatialObject:__type() == "Circle" then
                for i, lineSegment in ipairs(self:getLineSegments()) do
                    if spatialObject.point:distance(lineSegment) <= 0 then
                        return false
                    end
                end
            end
 
            return true
        else
            for i, point in ipairs(spatialObject:getPoints()) do
                inTriangles = false
                for j, triangle in ipairs(self:triangulate()) do
                    if triangle:contains(point) then
                        inTriangles = true
                        break
                    end
                end
                if not inTriangles then
                    return false
                end
            end
 
            return true
        end
    end
 
    function Polygon:insideOf(spatialObject)
        return spatialObject.contains(self)
    end
 
    function Polygon:direction()
        if self.directionValue == nil then
            local rightMostPoint = nil
            local rightMostPointIndex = nil
            for i, point in ipairs(self.points) do
                if rightMostPoint == nil or point.x >= rightMostPoint.x then
                    rightMostPoint = point
                    rightMostPointIndex = i
                end
            end
 
            rightMostPointPredecessor = self.points[(rightMostPointIndex - 1 - 1) % #self.points + 1]
            rightMostPointSuccessor   = self.points[(rightMostPointIndex + 1 - 1) % #self.points + 1]
 
            z = (rightMostPoint.x - rightMostPointPredecessor.x) * (rightMostPointSuccessor.y - rightMostPoint.y) - (rightMostPoint.y - rightMostPointPredecessor.y) * (rightMostPointSuccessor.x - rightMostPoint.x)
            if z > 0 then
                self.directionValue = 1
            elseif z < 0 then
                self.directionValue = -1
            else
                self.directionValue = 0
            end
        end
 
        return self.directionValue
    end
 
    function Polygon:triangulate()
        if self.triangles == nil then
            self.triangles = {}
 
            if #self.points > 3 then
                tempPoints = {}
                for i, point in ipairs(self.points) do
                    table.insert(tempPoints, point)
                end
       
                triangleFound = true
                while #tempPoints > 3 and triangleFound do
                    triangleFound = false
                    for i, point in ipairs(tempPoints) do
                        point1Index = (i - 1 - 1) % #tempPoints + 1
                        point2Index = (i + 1 - 1) % #tempPoints + 1
 
                        point1 = tempPoints[point1Index]
                        point2 = tempPoints[point2Index]
 
                        if ((((point1.x - point.x) * (point2.y - point.y) - (point1.y - point.y) * (point2.x - point.x))) * self:direction()) < 0 then
                            triangleCandidate = Polygon(point1, point, point2)
 
                            anotherPointInTriangleFound = false
                            for q = 1, #tempPoints, 1 do
                                if q ~= i and q ~= point1Index and q ~= point2Index and triangleCandidate:contains(tempPoints[q]) then
                                    anotherPointInTriangleFound = true
                                    break
                                end
                            end
 
                            if not anotherPointInTriangleFound then
                                table.insert(self.triangles, triangleCandidate)
                                table.remove(tempPoints, i)
                                i = i - 1
 
                                triangleFound = true
                            end
                        end
                    end
                end
 
                if #tempPoints == 3 then
                    table.insert(self.triangles, Polygon(tempPoints[1], tempPoints[2], tempPoints[3]))
                end
            elseif #self.points == 3 then
                table.insert(self.triangles, self)
            end
        end
 
        return self.triangles
    end
 
    function Polygon:intersects(spatialObject)
        for i, lineSegment1 in ipairs(self:getLineSegments()) do
            for j, lineSegment2 in ipairs(spatialObject:getLineSegments()) do
                if lineSegment1:intersects(lineSegment2) then
                    return true
                end
            end
        end
 
        return false
    end
 
    function Polygon:distance(spatialObject)
        local minDistance = nil
        for i, lineSegment in ipairs(self:getLineSegment()) do
            distance = point:distance(self)
            if minDistance == nil or distance <= minDistance then
                minDistance = distance
            end
        end
 
        return minDistance
    end
 
    function Polygon:tostring()
        local result = "Polygon("
 
        for i, point in ipairs(self.points) do
            if i == 1 then
                result = result .. point:tostring()
            else
                result = result .. ", " .. point:tostring()
            end
        end
 
        return result .. ")"
    end
 
    function Polygon:draw(color, width)
        for i, lineSegment in ipairs(self:getLineSegments()) do
            lineSegment:draw(color, width)
        end
    end

	
	
	
	
	
	
	----------------------------------------------
	
	
	
	
	
	local data = {}
local lines = {}
 
local default_confidence_required = 10
local default_velocity_look_back = 20
local default_predict_look_back = 10
 
local ping = 30
 
local debugmode = false
function math.close(a,b)
    if (math.abs(a-b)<.02) then return true end
    return false
end
local function get_target_key(target)
    return tostring(target.id)
end
 
local function Data(vector)
    return {vector=vector, time=os.clock()}
end
 
local function reset(key, first)
    data[key] = {first}
end
 
local function add(key, v)
    local t = data[key]
    if t == nil then
        reset(key, v)
    else
        table.insert(t, v)
    end    
end
 
local function get_i(key, i)
    local t = data[key]
    if t ~= nil and #t >= i then
        return t[i]
    end
end
 
local function get_start(key)
    return get_i(key, 1)
end
 
local function get_end(key)
    local t = data[key]
    if t ~= nil and #t > 0 then
        return t[#t]
    end
end
 
local function get_deltas(first, last)
    local dtime = last.time - first.time
    local dvec = last.vector - first.vector
    return dtime, dvec, dvec_norm
end
 
local function within_limits(key, curr)
    local function print() end
    local t = data[key]
    local n = #t
    assert(n >= 2)
    local first = get_start(key)
    local last = get_end(key)
    -- existing deltas
    local dtime, dvec = get_deltas(first, last)
    assert(dtime > 0) -- or use 0 vecs
    local dvec_norm = dvec / dtime
    print('existing change per second', dvec_norm)
    -- new deltas
    -- measuring vs first doesn't work, it makes itself accurate?
    -- when you go back too far... there is too much freedom
    -- when you dont go back far enough there is too little freedom
    local back_count = math.min(10, n)
    -- bugs in lb or quirks in lol
    -- if you set 1 waypoint far away, some ticks your pos change will be 0, and some ticks it will be double
    -- maybe going back further helps handle that
    -- maybe don't end on such 0 or double boundaries... are they always matched?
    -- they are not always matched
    -- increase back_count to deal with these, while also increasing their freedom (decreasing confidence)
    local back = get_i(key, n-back_count+1)
    local dtime_curr, dvec_curr = get_deltas(back, curr)
    assert(dtime_curr > 0) -- or use 0 vecs
    local dvec_norm_curr = dvec_curr / dtime_curr
    print('new change per second', dvec_norm_curr)
    -- now the curr delta needs to be within x% of existing delta
    -- todo: ease limits when n is low
    -- when n is under 10, then percent change allowed is increased
    local percent = 0.05 -- +/- percent change allowed per second
    if n == 10 then percent = percent * 1.2 end
    if n == 9 then percent = percent * 1.4 end
    if n == 8 then percent = percent * 1.6 end
    if n == 7 then percent = percent * 1.8 end
    if n == 6 then percent = percent * 2.0 end
    if n == 5 then percent = percent * 2.2 end
    if n == 4 then percent = percent * 2.4 end
    if n == 3 then percent = percent * 2.6 end
    if n == 2 then percent = percent * 2.8 end
    local limit = dvec_norm * percent
    local bot = dvec_norm - limit
    local top = dvec_norm + limit
    print('bot', bot)
    print('top', top)
    print('within?', dvec_norm_curr >= bot and dvec_norm_curr <= top)
    return dvec_norm_curr >= bot and dvec_norm_curr <= top
end
 
local function confidence(key)
    if data[key] == nil then return 0 end
    return #data[key]
end
 
local function predict(key, seconds)
    local n = #data[key]
    local back_count = math.min(default_predict_look_back, n)
    local back = get_i(key, n-back_count+1)
    --
    local last = get_end(key)
    local dtime, dvec = get_deltas(back, last)
    local dvec_norm = dvec / dtime
    local dpredict = last.vector + dvec_norm * seconds
    return dpredict
end
 
-- todo: look_back param... if nil then back_count = n
local function get_velocity(key)
    local n = #data[key]
    local back_count = math.min(default_velocity_look_back, n)
    local back = get_i(key, n-back_count+1)
    --
    local last = get_end(key)
    local dtime, dvec = get_deltas(back, last)
    local dvec_norm = dvec / dtime
    return dvec_norm -- so similar to predict, just make predict return it?
end
 
local function acceptable(key, curr)
    local first = get_start(key)
    local second = get_i(key, 2)
    if first == nil or second == nil then
        return true
    else
        if within_limits(key, curr) then
            return true
        else
            return false
        end
    end
end
 
local function handle_data(key, curr)
    if acceptable(key, curr) then
        add(key, curr)
    else
        reset(key, curr)
    end
end
 
local function handle_hero(hero, key)
    if not hero.visible then return end
    local key = get_target_key(hero)
    local curr_vector = Vector()
    curr_vector.x = hero.x
    curr_vector.y = hero.z
    local curr = Data(curr_vector)    
    handle_data(key, curr)    
end
 
 
local function rad2deg(radians)
    return math.deg(radians)
end
 
-- return the position to aim for in order to hit target with projectile moving at projectile_speed
local function get_target_position(origin_vpos, projectile_speed, target_vpos, target_velocity)
    local function print() end
    assert(VectorType(origin_vpos))
    assert(VectorType(target_vpos))
    assert(VectorType(target_velocity))
    local A = Vector()
    A.x, A.y = 0, 0
    assert(VectorType(A))
    -- rotate B and B velocity so AB is vertical
    local B = target_vpos - origin_vpos
    assert(VectorType(B))
    local original_angle = math.atan2(B.x, B.z)
    print('original_angle', rad2deg(original_angle))
    print('B before rotateY', B)
    B:rotateYaxis(-original_angle)
    print('B after rotateY', B)
    --assert(B.x == 0, B.x)
   
    B_velocity = target_velocity
    B_velocity:rotateYaxis(-original_angle)
   
    -- http://stackoverflow.com/questions/2248876/2d-game-fire-at-a-moving-target-by-predicting-intersection-of-projectile-and-u    
    local Bx  = B_velocity.x  
    local Vx = Bx  
    local Vz = math.sqrt(projectile_speed^2 - Bx^2)        
    -- http://stackoverflow.com/questions/3441782/how-to-calculate-the-angle-of-a-vector-from-the-vertical
    local angle = math.atan2(Vz, Vx) - math.pi/2
    print('angle',rad2deg(angle))
   
    -- make aim vector from angle and length
    local length = 20000
    local aim = Vector()
    aim.x = math.sin(angle)*length
    aim.z = -math.cos(angle)*length
   
    if true then
        table.insert(lines, string.format('original_angle: %d', rad2deg(original_angle)))
        table.insert(lines, string.format('angle: %d', rad2deg(angle)))
        if debugmode then DrawLineObject(myHero,1000,0xff00ffff,angle+original_angle,2) end
    end
   
    -- find the intersect
    local A2 = A+aim
    local B2 = B + B_velocity * 20000
    local intersect = VectorIntersection(A, A2, B, B2)
    if intersect == nil then
        if math.close(target_velocity:len(), 0) then
            return target_vpos
        else
            return intersect
        end
    end
   
    print('intersect', intersect)
    intersect.z = intersect.y
    intersect.y = 0
   
    intersect:rotateYaxis(original_angle)
    print('intersect rotated back to reality', intersect)
   
    return origin_vpos + intersect
end
 
function GetFyreahead(target, delay, projectile_speed, range, confidence_required, startunit)
    if startunit == nil then startunit = myHero end
    if confidence_required == nil then
        confidence_required = default_confidence_required
    end
    if confidence_required <= 1 then
        confidence_required = 1
    end
    if range == nil then range = math.huge end
    local key = get_target_key(target)
    local conf = confidence(key)
    if conf < confidence_required then
        return nil
    end
 
    delay = delay / 10 + ping / 1000
    projectile_speed = projectile_speed * 100
   
    local origin_vpos = Vector()
    local self_key = get_target_key(startunit)
    local self_ping_pos = predict(self_key, ping / 1000)
    origin_vpos.x, origin_vpos.z = self_ping_pos.x, self_ping_pos.y
   
    local target_velocity = Vector()
    local vel = get_velocity(key)
    target_velocity.x, target_velocity.z = vel.x, vel.z
 
    local target_vpos = Vector()
    local delay_pos = predict(key, delay)
    target_vpos.x, target_vpos.z = delay_pos.x, delay_pos.y
 
    local aim_at = get_target_position(origin_vpos, projectile_speed, target_vpos, target_velocity)
    if aim_at == nil or GetD(aim_at) > range then return end
   
    return aim_at.x, aim_at.y, aim_at.z, conf
end
 
local function lb_tick()
    local heroes = {}
    for i = 1, objManager:GetMaxCreatures() do
        local hero = objManager:GetCreature(i)
        if hero.visible and (string.find(hero.name, "Minion") == nil or GetD(hero) < 2000) then
            table.insert(heroes, hero)
    end
    end
    for i,hero in ipairs(heroes) do
        handle_hero(hero)
    end
end

	
	
	------------------------------------------------------------------------
	
	
	
	
	
	
Collision = class()
    UNIT_ALL = 1
    UNIT_ENEMY = 2
    UNIT_ALLY = 3
 
 
    function Collision:__init(sRange, projSpeed, sDelay, sWidth,ping)
        if ping == nil then ping = 30 end
        self.ping = ping
        self.sRange = sRange
        self.projSpeed = projSpeed
        self.sDelay = sDelay
        self.sWidth = sWidth/2
    end
 
    function Collision:GetMinionCollision(pStart, pEnd, mode)
        local fireahead = nil
        if mode == nil then mode = UNIT_ENEMY end
        local miniontable = {}
        for i = 1, objManager:GetMaxCreatures() do
            local minion = objManager:GetCreature(i)
            if string.find(minion.name, "Minion") ~= nil then
            if (mode == UNIT_ENEMY or mode == UNIT_ALL) and minion.valid == 1 and minion.team ~= myHero.team then
                table.insert(miniontable, minion)
            elseif (mode == UNIT_ALLY or mode == UNIT_ALL) and minion.valid == 1 and minion.team == myHero.team then
                table.insert(miniontable, minion)
            end
            end
            end
 
        local distance =  GetD(pStart, pEnd)
        local mCollision = {}
 
        if distance > self.sRange then
            distance = self.sRange
        end
        local V = Vector(pEnd) - Vector(pStart)
        local k = V:normalized()
        local P = V:perpendicular2():normalized()
 
        local t,i,u = k:unpack()
        local x,y,z = P:unpack()
 
        local startLeftX = pStart.x + (x *self.sWidth)
        local startLeftY = pStart.y + (y *self.sWidth)
        local startLeftZ = pStart.z + (z *self.sWidth)
        local endLeftX = pStart.x + (x * self.sWidth) + (t * distance)
        local endLeftY = pStart.y + (y * self.sWidth) + (i * distance)
        local endLeftZ = pStart.z + (z * self.sWidth) + (u * distance)
       
        local startRightX = pStart.x - (x * self.sWidth)
        local startRightY = pStart.y - (y * self.sWidth)
        local startRightZ = pStart.z - (z * self.sWidth)
        local endRightX = pStart.x - (x * self.sWidth) + (t * distance)
        local endRightY = pStart.y - (y * self.sWidth) + (i * distance)
        local endRightZ = pStart.z - (z * self.sWidth)+ (u * distance)
 
        local startLeft = WorldToScreen(startLeftX, startLeftY, startLeftZ)
        local endLeft = WorldToScreen(endLeftX, endLeftY, endLeftZ)
        local startRight = WorldToScreen(startRightX, startRightY, startRightZ)
        local endRight = WorldToScreen(endRightX, endRightY, endRightZ)
       
        local poly = Polygon(startLeft, endLeft, startRight, endRight)
         for i, minion in ipairs(miniontable) do
            if minion ~= nil and minion.dead == 0 and minion.valid == 1 then
                if GetD(pStart, minion) < distance then
                    local pos, t, vec = nil
                    if GetFyreahead(minion, self.sDelay, self.projSpeed, self.sRange, 5, 36, pStart) ~= nil then
                    pos, t, vec = Vector(GetFyreahead(minion, self.sDelay, self.projSpeed, self.sRange, 5, self.ping , pStart))
                    end
                    local lineSegmentLeft = LineSegment(Point(startLeftX,startLeftZ), Point(endLeftX, endLeftZ))
                    local lineSegmentRight = LineSegment(Point(startRightX,startRightZ), Point(endRightX, endRightZ))
                    local toPoint
                    if pos ~= nil then
                        toPoint = WorldToScreen(pos.x, minion.y, pos.z)
                    else
                        toPoint = WorldToScreen(minion.x, minion.y, minion.z)
                    end
 
 
                    if poly:contains(toPoint) then
                        table.insert(mCollision, minion)
                    else
                        if pos ~= nil then
                            distance1 = Point(pos.x, pos.z):distance(lineSegmentLeft)
                            distance2 = Point(pos.x, pos.z):distance(lineSegmentRight)
                        else
                            distance1 = Point(minion.x, minion.z):distance(lineSegmentLeft)
                            distance2 = Point(minion.x, minion.z):distance(lineSegmentRight)
                        end
                        if (distance1 < (getMinionHitbox(minion)*2) or distance2 < (getMinionHitbox(minion) *2)) then
                            table.insert(mCollision, minion)
                        end
                    end
                end
            end
        end
        if #mCollision > 0 then return true, mCollision else return false, mCollision end
    end
 
    function Collision:GetHeroCollision(pStart, pEnd, mode)
        if mode == nil then mode = UNIT_ENEMY end
        local heros = {}
        for i = 1, objManager:GetMaxHeroes() do
            local hero = objManager:GetHero(i)
            if (mode == UNIT_ENEMY or mode == UNIT_ALL) and hero.team ~= myHero.team then
                table.insert(heros, hero)
            elseif (mode == UNIT_ALLY or mode == UNIT_ALL) and hero.team == myHero.team and hero.charName ~= myHero.charName then
                table.insert(heros, hero)
            end
        end
 
        local distance =  GetD(pStart, pEnd)
        local hCollision = {}
 
        if distance > self.sRange then
            distance = self.sRange
        end
 
        local V = Vector(pEnd) - Vector(pStart)
        local k = V:normalized()
        local P = V:perpendicular2():normalized()
 
        local t,i,u = k:unpack()
        local x,y,z = P:unpack()
 
        local startLeftX = pStart.x + (x *self.sWidth)
        local startLeftY = pStart.y + (y *self.sWidth)
        local startLeftZ = pStart.z + (z *self.sWidth)
        local endLeftX = pStart.x + (x * self.sWidth) + (t * distance)
        local endLeftY = pStart.y + (y * self.sWidth) + (i * distance)
        local endLeftZ = pStart.z + (z * self.sWidth) + (u * distance)
       
        local startRightX = pStart.x - (x * self.sWidth)
        local startRightY = pStart.y - (y * self.sWidth)
        local startRightZ = pStart.z - (z * self.sWidth)
        local endRightX = pStart.x - (x * self.sWidth) + (t * distance)
        local endRightY = pStart.y - (y * self.sWidth) + (i * distance)
        local endRightZ = pStart.z - (z * self.sWidth)+ (u * distance)
 
        local startLeft = WorldToScreen(startLeftX, startLeftY, startLeftZ)
        local endLeft = WorldToScreen(endLeftX, endLeftY, endLeftZ)
        local startRight = WorldToScreen(startRightX, startRightY, startRightZ)
        local endRight = WorldToScreen(endRightX, endRightY, endRightZ)
 
        local poly = Polygon(startLeft, endLeft, startRight, endRight)
 
        for i, hero in ipairs(heros) do
            if hero ~= nil and hero.dead == 0 and hero.valid == 1 then
                if GetD(pStart, hero) < distance then
                    local pos, t, vec = nil
                    if GetFyreahead(hero, self.sDelay, self.projSpeed, self.sRange, 5, 36, pStart) ~= nil then
                    pos, t, vec = Vector(GetFyreahead(hero, self.sDelay, self.projSpeed, self.sRange, 5, self.ping, pStart))
                    end
                    local lineSegmentLeft = LineSegment(Point(startLeftX,startLeftZ), Point(endLeftX, endLeftZ))
                    local lineSegmentRight = LineSegment(Point(startRightX,startRightZ), Point(endRightX, endRightZ))
                    local toPoint
                    if pos ~= nil then
                        toPoint = WorldToScreen(pos.x, hero.y, pos.z)
                    else
                        toPoint = WorldToScreen(hero.x, hero.y, hero.z)
                    end
 
 
                    if poly:contains(toPoint) then
                        table.insert(hCollision, hero)
                    else
                        if pos ~= nil then
                            distance1 = Point(pos.x, pos.z):distance(lineSegmentLeft)
                            distance2 = Point(pos.x, pos.z):distance(lineSegmentRight)
                        else
                            distance1 = Point(hero.x, hero.z):distance(lineSegmentLeft)
                            distance2 = Point(hero.x, hero.z):distance(lineSegmentRight)
                        end
                        if (distance1 < (getHitBoxRadius(hero)*2) or distance2 < (getHitBoxRadius(hero) *2)) then
                            table.insert(hCollision, hero)
                        end
                    end
                end
            end
        end
        if #hCollision > 0 then return true, hCollision else return false, hCollision end
    end
 
    function Collision:GetCollision(pStart, pEnd, mode)
        if mode == nil then mode = UNIT_ENEMY end
        local b , minions = self:GetMinionCollision(pStart, pEnd, mode)
        local t , heros = self:GetHeroCollision(pStart, pEnd, mode)
 
        if not b then return t, heros end
        if not t then return b, minions end
 
        local all = {}
 
        for index, hero in pairs(heros) do
            table.insert(all, hero)
        end
 
        for index, minion in pairs(minions) do
            table.insert(all, minion)
        end
 
        return true, all
    end
 
 
        function Collision:DrawCollision(pStart, pEnd, mode)
       
        local distance =  GetD(pStart, pEnd)
 
        if distance > self.sRange then
            distance = self.sRange
        end
 
        local V = Vector(pEnd) - Vector(pStart)
        local k = V:normalized()
        local P = V:perpendicular2():normalized()
 
        local t,i,u = k:unpack()
        local x,y,z = P:unpack()
 
        local startLeftX = pStart.x + (x *self.sWidth)
        local startLeftY = pStart.y + (y *self.sWidth)
        local startLeftZ = pStart.z + (z *self.sWidth)
        local endLeftX = pStart.x + (x * self.sWidth) + (t * distance)
        local endLeftY = pStart.y + (y * self.sWidth) + (i * distance)
        local endLeftZ = pStart.z + (z * self.sWidth) + (u * distance)
       
        local startRightX = pStart.x - (x * self.sWidth)
        local startRightY = pStart.y - (y * self.sWidth)
        local startRightZ = pStart.z - (z * self.sWidth)
        local endRightX = pStart.x - (x * self.sWidth) + (t * distance)
        local endRightY = pStart.y - (y * self.sWidth) + (i * distance)
        local endRightZ = pStart.z - (z * self.sWidth)+ (u * distance)
 
        local startLeft = WorldToScreen(startLeftX, startLeftY, startLeftZ)
        local endLeft = WorldToScreen(endLeftX, endLeftY, endLeftZ)
        local startRight = WorldToScreen(startRightX, startRightY, startRightZ)
        local endRight = WorldToScreen(endRightX, endRightY, endRightZ)
        local colliton, objects = self:GetCollision(pStart, pEnd, mode)
 
        for i, object in pairs(objects) do
            if string.find(object.name, "Minion") then
            CustomCircleXYZ(getMinionHitbox(object)*2, 1, 1, object.x, object.y, object.z)
            else CustomCircleXYZ(getHitBoxRadius(object)*2, 1, 1, object.x, object.y, object.z)
        end
    end
end
function getMinionHitbox(target)
if string.find(target.name, "Wizard") ~= nil then return 40
elseif string.find(target.name, "MechMelee") ~= nil then return 57
elseif string.find(target.name, "Basic") ~= nil then return 40
elseif string.find(target.name, "caster") ~= nil then return 40
elseif string.find(target.name, "basic") ~= nil then return 40
elseif string.find(target.name, "Caster") ~= nil then return 40
elseif string.find(target.name, "MechCannon") ~= nil then return 57
elseif string.find(target.name, "Super") ~= nil then return 47
else return GetD(GetMaxBBox(target), GetMinBBox(target))/4
end
end
function getHitBoxRadius(target)
        return GetD(GetMaxBBox(target), GetMinBBox(target))/4
    end
 
function CustomCircleXYZ(radius,thickness,color,x,y,z)
        local count = math.floor(thickness/2)
        repeat
            DrawCircle(x,y,z,radius+count,color)
            count = count-2
        until count == (math.floor(thickness/2)-(math.floor(thickness/2)*2))-2
    if x ~= "" and y ~= "" and z~= "" then
        local count = math.floor(thickness/2)
        repeat
            DrawCircle(x,y,z,radius+count,color)
            count = count-2
        until count == (math.floor(thickness/2)-(math.floor(thickness/2)*2))-2
    end
end
 
function WorldToScreen(a, b, c)
        local mem = {}
        local phi=math.pi*17/90 -- 34 degrees found on google http://na.leagueoflegends.com/board/showthread.php?t=9747
        local theta=3*math.pi/2
        local rho=1770/(math.cos(phi)) --Distance from Eye to center of screen with y=0 (Riot coordinates) value
 
    local cameraX, cameraY, cameraZ = GetWorldX(),1770 , rho*math.sin(phi)*math.sin(theta)+GetWorldY()
    local beta, gamma = 9 * math.pi / 180, 50 * math.pi / 180
    local object = {x=a-cameraX,y=b-cameraY,z=c-cameraZ}
    if mem.camHeigth ~= cameraY or not mem.P2 then
        mem.camHeigth = cameraY
        local P3_5 = { x=0, y=object.y, z=math.tan(beta) * math.abs(object.y) }
        local P1_5 = {x= 0, y=object.y, z=math.tan(beta + gamma) * math.abs(object.y) }
                P1_5.x = P1_5.x * (math.sqrt(P3_5.x * P3_5.x + (P3_5.y and (P3_5.y * P3_5.y) or 0) + P3_5.z * P3_5.z)) / (math.sqrt(P1_5.x * P1_5.x + (P1_5.y and (P1_5.y * P1_5.y) or 0) + P1_5.z * P1_5.z))
        P1_5.y = P1_5.y * (math.sqrt(P3_5.x * P3_5.x + (P3_5.y and (P3_5.y * P3_5.y) or 0) + P3_5.z * P3_5.z)) / (math.sqrt(P1_5.x * P1_5.x + (P1_5.y and (P1_5.y * P1_5.y) or 0) + P1_5.z * P1_5.z))
        P1_5.z = P1_5.z * (math.sqrt(P3_5.x * P3_5.x + (P3_5.y and (P3_5.y * P3_5.y) or 0) + P3_5.z * P3_5.z)) / (math.sqrt(P1_5.x * P1_5.x + (P1_5.y and (P1_5.y * P1_5.y) or 0) + P1_5.z * P1_5.z))
        mem.absHeight = math.sqrt((P1_5.z - P3_5.z) ^ 2 + (P1_5.y - P3_5.y) ^ 2)
        mem.absWidth = mem.absHeight * GetScreenX() / GetScreenY()
        mem.P3 = {x=P3_5.x - mem.absWidth / 2,y=P3_5.y-  0,z=P3_5.z-  0 }
        mem.P2 = {x=P1_5.x+ mem.absWidth / 2,  y=P1_5.y,z=P1_5.z }
                mem.n1={x=mem.P2.x-P3_5.x,y=mem.P2.y-P3_5.y,z=mem.P2.z-P3_5.z}        
                mem.n2={x=mem.P3.x-P3_5.x,y=mem.P3.y-P3_5.y,z=mem.P3.z-P3_5.z}
               
        mem.n = { x= mem.n2.z*mem.n1.y - mem.n2.y*mem.n1.z, y= mem.n2.x*mem.n1.z - mem.n2.z*mem.n1.x, z=mem.n2.y*mem.n1.x - mem.n2.x*mem.n1.y}
    end
    object.x = object.x * (mem.n.x * mem.P2.x + mem.n.y * mem.P2.y + mem.n.z * mem.P2.z) / (mem.n.x * object.x + mem.n.y * object.y + mem.n.z * object.z)
    object.y = object.y * (mem.n.x * mem.P2.x + mem.n.y * mem.P2.y + mem.n.z * mem.P2.z) / (mem.n.x * object.x + mem.n.y * object.y + mem.n.z * object.z)
    object.z = object.z * (mem.n.x * mem.P2.x + mem.n.y * mem.P2.y + mem.n.z * mem.P2.z) / (mem.n.x * object.x + mem.n.y * object.y + mem.n.z * object.z)
    local curHeight = math.sqrt((mem.P2.z - object.z) ^ 2 + (mem.P2.y - object.y) ^ 2) * ((mem.P2.z - object.z) / math.abs(mem.P2.z - object.z))
    local curWidth = object.x - mem.P3.x
    local x2D = GetScreenX() * curWidth / mem.absWidth --yonder's move_mouse x
    local y2D = GetScreenY() * curHeight / mem.absHeight --yonder's move_mouse y
    local onscreen = x2D <= GetScreenX() and x2D >= -GetScreenX() and y2D >= -50 and y2D <= GetScreenY() + 50
        local XX=65536/GetScreenX()*x2D --MoveMouse x
        local YY=65536/GetScreenY()*y2D --MoveMouse y
    return Point(XX, YY)
end
	
	
	
	
	
	
	
	
SetTimerCallback("Run")