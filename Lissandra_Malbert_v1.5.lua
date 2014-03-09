require "Utils"
require 'spell_damage'
print=printtext
printtext("\nLasagna\n")
printtext("\nBy Malbert\n")
printtext("\nVersion 1.6\n")

local target
local targetescape
local target600
local targetQ
local enemies={}
local ignitedamage
local Passive=true
local Ptimer=os.clock()
local EReady=true
local ETimer=0
local EObject=nil
local ZReady=true
local ZCount=false
local ZTimer=0
--------Spell Stuff
local QRDY=0
local WRDY=0
local ERDY=0
local RRDY=0
local qdelay=0
local qspeed=0

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
local dodgeskillshotkey = 74 -- dodge skillshot key J
local show_allies=0

local willDie=false
local shield=false
local tqfx,tqfy,tqfz
local tqfa
			
local twfx,twfy,twfz
local twfa
			
local tefx,tefy,tefz 
local tefa
			
local trfx,trfy,trfz
local trfa

local tqfxQ,tqfyQ,tqfzQ
local tqfaQ

local DM=0

local QQ
local WW
local EE
local RR
local AA

--turret stuff
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



LissConfig = scriptConfig("Liss", "Liss Config")
LissConfig:addParam("e", "Escape", SCRIPT_PARAM_ONKEYDOWN, false, 65)
LissConfig:addParam("h", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, 88)
LissConfig:addParam("teamfight", "All In Teamfight", SCRIPT_PARAM_ONKEYDOWN, false, 84)
LissConfig:addParam("qm", "QThruMinions", SCRIPT_PARAM_ONKEYTOGGLE, true, 55)
LissConfig:addParam("qmp", "QThruOnlyWithPassive", SCRIPT_PARAM_ONKEYTOGGLE, true, 56)
LissConfig:addParam("autoW", "AutoW", SCRIPT_PARAM_ONKEYTOGGLE, true, 57)
LissConfig:addParam("zh", "Zhonyas/Ult", SCRIPT_PARAM_DOMAINUPDOWN, 2, 48, {"Off","Items Only","Items and Ult"})
LissConfig:addParam("pe4m", "Predict E 4 Teamfight", SCRIPT_PARAM_ONOFF, true)
LissConfig:addParam("ks", "KillSteal", SCRIPT_PARAM_ONOFF, true)
LissConfig:addParam("d", "Auto Dodge", SCRIPT_PARAM_ONOFF, false)
LissConfig:addParam("smite", "Smitesteal", SCRIPT_PARAM_ONKEYTOGGLE, false, 119)
--LissConfig:addParam('Qdelay', "Q Delay", SCRIPT_PARAM_NUMERICUPDOWN, 1.3, 189,0,5,0.1)
LissConfig:addParam('qd', "Q Delay", SCRIPT_PARAM_NUMERICUPDOWN, 1.3, 219,1,8,0.1)
LissConfig:addParam('qs', "Q Speed", SCRIPT_PARAM_NUMERICUPDOWN, 23, 221,16,24,0.2)
LissConfig:permaShow("teamfight")
LissConfig:permaShow("qm")
LissConfig:permaShow("qmp")
LissConfig:permaShow("d")
LissConfig:permaShow("pe4m")
LissConfig:permaShow("ks")
LissConfig:permaShow("zh")
LissConfig:permaShow("smite")
--LissConfig:permaShow("Qdelay")
     
     
	 --Q 825-1075  3.3,23
	 --W 455  1.35
	 --E 1130 3.42,8.45
	 --R 550  1.33
	 
		--local qdelay=1.3
function Run()

	qdelay=LissConfig.qd
	qspeed=LissConfig.qs
	willDie=false
	target = GetWeakEnemy("MAGIC", 1300)
	targetescape = GetWeakEnemy("MAGIC", 450)
	target600 = GetWeakEnemy("TRUE", 600)
	targetQ = GetWeakEnemy("MAGIC", 1100)

	if target~=nil then
		tqfx,tqfy,tqfz = GetFireahead(target,qdelay,qspeed)
		tqfa={x=tqfx,y=0,z=tqfz}
		
		twfx,twfy,twfz = GetFireahead(target,1.35,99)
		twfa={x=twfx,y=0,z=twfz}
		
		tefx,tefy,tefz = GetFireahead(target,5.42,8.45)
		tefa={x=tefx,y=0,z=tefz}
		
		trfx,trfy,trfz = GetFireahead(target,1.33,99)
		trfa={x=trfx,y=0,z=trfz}
		
		DM=GetD(target,myHero)
		
		QQ = CalcMagicDamage(target,(40+(35*GetSpellLevel('Q'))+65*myHero.ap/100)*QRDY)
		WW = CalcMagicDamage(target,(30+(40*GetSpellLevel('W'))+6*myHero.ap/10)*WRDY)
		EE = CalcMagicDamage(target,(25+(45*GetSpellLevel('E'))+6*myHero.ap/10)*ERDY)
		RR = CalcMagicDamage(target,((150*GetSpellLevel('R'))+7*myHero.ap/10)*RRDY)
		AA = CalcDamage(target,myHero.addDamage+myHero.baseDamage)
		
	end
	if targetQ~=nil then
		
			tqfxQ,tqfyQ,tqfzQ = GetFireahead(targetQ,qdelay,qspeed)
			tqfaQ={x=tqfxQ,y=0,z=tqfzQ}
	end

	if ZCount==true then
		if ZTimer<os.clock() then
			ZReady=true
			ZCount=false
		end
	end
	
	if EReady==false and ETimer+0.2<os.clock() then
		EReady=true
		
	end

	if LissConfig.d then dodgeskillshot=true else dodgeskillshot=false end
	if LissConfig.zh>0 then shield=true else shield=false end
	if LissConfig.ks then ignite() 
	killsteal() 
	end
	if LissConfig.smite then smitesteal() end
	if LissConfig.qm then autoQ() end
	
	if IsChatOpen() == 0 and LissConfig.e then
		if targetescape~=nil and GetD(targetescape)<435 then
			CastSpellTarget('W',myHero)
		end
		if EReady==true and ERDY==1 then 
				CastSpellXYZ('E',mousePos.x,0,mousePos.z)
				EReady=false
		elseif EReady==false and ETimer<os.clock() then
			EReady=true
			CastSpellTarget('E',myHero)	
		else 
			MoveToMouse()
		end
	end
			
	if IsChatOpen() == 0 and LissConfig.teamfight then
		if target~=nil then
			
			if EReady==true and ERDY==1 then 
				if LissConfig.pe4m then
					CastSpellXYZ('E',GetFireahead(target,5.42,8.45))
				else
					CastSpellXYZ('E',mousePos.x,0,mousePos.z)
				end
				EReady=false
			elseif ERDY==1 and EReady==false then
				if (EObject~=nil and runningAway(target) and ETimer<os.clock() and GetD(EObject,target)<GetD(target)) then 
					EObject=nil
					EReady=true
					CastSpellTarget('E',myHero)
				elseif (EObject~=nil and GetD(EObject,myHero)<=DM and GetD(EObject,target)<250) then
					EObject=nil
					EReady=true
					CastSpellTarget('E',myHero)
				elseif (EObject~=nil and GetD(EObject,myHero)>DM and GetD(EObject,target)<600) then	
					EObject=nil
					EReady=true
					CastSpellTarget('E',myHero)
				end
			elseif ERDY==0 then
				if WRDY==1 and GetD(twfa)<435 then
					CastSpellTarget('W',myHero)
				end
				if QRDY==1 and GetD(tqfa)<825 then
					CastSpellXYZ('Q',tqfx,tqfy,tqfz)
				elseif QRDY==1 and GetD(tqfaQ)<1050 and CreepBlock(tqfx,tqfy,tqfz,50)>0 then
					if getLine(tqfaQ,myHero) then
							CastSpellXYZ('Q',tqfxQ,tqfyQ,tqfzQ)--sx,0,sz)
					end
					
				end
				local tsafe=true
				run_every(1,findTurret)
				for _, tur in ipairs(enemyTurrets) do
					if tur~=nil then
						
						if target~=nil and GetD(tur.object,myHero)>tur.range then
							tsafe=true
						elseif target~=nil and GetD(tur.object,myHero)<=tur.range then
							tsafe=false
						else
							tsafe=false
						end
				
						if tsafe==false then
							break
						end
					end
				end	
				if RRDY==1 and GetD(trfa)<550 and surrounded(myHero)==false and (tsafe==true or myHero.health>6*myHero.maxHealth/10) then --targetAlone(target)
					--print("\n1")
					CastSpellTarget('R',target)
				elseif RRDY==1 and GetD(trfa)<450 then
					--print("\n2")
					CastSpellTarget('R',myHero)
				elseif RRDY==1 and GetD(trfa)<550 then
					--print("\n3")
					CastSpellTarget('R',target)
				else
					if GetD(target)<400 then
						CastSummonerExhaust(target)
						UseAllItems(target)
					elseif GetD(target)<600 then
						CastSummonerExhaust(target)
						UseAllItems(target)
					end
					
						AttackTarget(target)
					
				end
				
			end
				

			
		else
			MoveToMouse()
		end
		
		
	end


	if IsChatOpen() == 0 and LissConfig.h then
		harass()
	end

	if LissConfig.autoW and (IsChatOpen()==1 or (IsChatOpen==0 and not LissConfig.teamfight and not LissConfig.h)) then
		if targetescape~=nil then
		local twfex,twfey,twfez = GetFireahead(targetescape,1.35,99)
		local twfea={x=twfex,y=0,z=twfez}
			if GetD(twfea)<=435 then
				CastSpellTarget('W',myHero)
			end
		end
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
        
	        ------------
        if myHero.SpellTimeQ > 1.0 and GetSpellLevel('Q') > 0 then
                QRDY = 1
                else QRDY = 0
        end
        if myHero.SpellTimeW > 1.0 and GetSpellLevel('W') > 0 then
                WRDY = 1
                else WRDY = 0
        end
        if myHero.SpellTimeE > 1.0 and GetSpellLevel('E') > 0 then
                ERDY = 1
                else ERDY = 0
        end
        if myHero.SpellTimeR > 1.0 and GetSpellLevel('R') > 0 then
                RRDY = 1
        else RRDY = 0 end
        --------------------------
end
     

     
function OnProcessSpell(unit,spell)


	if unit.name==myHero.name and unit.team==myHero.team then  
		--print("\nSpellname: "..spell.name)
		if string.find(spell.name,"LissandraE") ~= nil then --Lissandra_E_End
			Passive=false
			EReady=false
			ETimer=os.clock()+1.2
		elseif string.find(spell.name,"LissandraQ") ~= nil then --Lissandra_E_End
			Passive=false
		elseif string.find(spell.name,"LissandraW") ~= nil then --Lissandra_E_End
			Passive=false
		elseif string.find(spell.name,"LissandraR") ~= nil then --Lissandra_E_End
			Passive=false
		elseif string.find(spell.name,"LissandraBasicAttack") ~= nil or string.find(spell.name,"LissandraCritAttack") ~= nil then --Lissandra_E_End
			ATimer=os.clock()+myHero.attackspeed
		elseif string.find(spell.name,"ZhonyasHourglass") ~= nil then
			ZTimer=os.clock()+92.5
			ZCount=true
		end


	elseif shield==true and unit~=nil then
	local Q
	local W
	local E
	local R
		Q = unit.SpellNameQ
		W = unit.SpellNameW
		E = unit.SpellNameE
		R = unit.SpellNameR
		
	
		local P1 = spell.startPos
		local P2 = spell.endPos
		local calc = (math.floor(math.sqrt((P2.x-unit.x)^2 + (P2.z-unit.z)^2)))
		
		--unit.name~="Worm" and unit.name~="TT_Spiderboss7.1.1" and
		if spell ~= nil and unit.team ~= myHero.team and spell.target~=nil and spell.target.name~=nil and spell.target.name == myHero.name then
			if spell.name == Q then
				--CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
				if spellDmg[unit.name] and getDmg("Q",myHero,unit)~=nil and getDmg("Q",myHero,unit) > myHero.health then
					zhonyas()
					CastSummonerBarrier()
					CastSummonerHeal()
				end
    		
			elseif spell.name == W then
        		--CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
        		if spellDmg[unit.name] and getDmg("W",myHero,unit)~=nil and getDmg("W",myHero,unit) > myHero.health then
					zhonyas()
					CastSummonerBarrier()
					CastSummonerHeal()
				end
    		
			elseif spell.name == E then
   			   -- CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
    			if spellDmg[unit.name] and getDmg("E",myHero,unit)~=nil and getDmg("E",myHero,unit) > myHero.health then
					zhonyas()
					CastSummonerBarrier()
					CastSummonerHeal()
        		end

			elseif spell.name == R then
        		--CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
        		if spellDmg[unit.name] and getDmg("R",myHero,unit)~=nil and getDmg("R",myHero,unit) > myHero.health then
					zhonyas()
					CastSummonerBarrier()
					CastSummonerHeal()
        		end
    		
			elseif string.find(unit.name,"minion") == nil and string.find(unit.name,"Minion_") == nil and (spell.name:find("BasicAttack") or spell.name:find("BasicAttack2") or spell.name:find("BasicaAttack3")  or spell.name:find("ChaosTurretFire")) then
        		--CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
				if (unit.baseDamage + unit.addDamage) > myHero.health then
					--print("\nMN "..unit.name)
					zhonyas()
					CastSummonerBarrier()
					CastSummonerHeal()
				end	
			elseif spell.name:find("BasicAttack") or spell.name:find("BasicAttack2") or spell.name:find("BasicaAttack3")  or spell.name:find("ChaosTurretFire") then
        		if (unit.baseDamage + unit.addDamage) > myHero.health then
        			--CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
					zhonyas()
					CastSummonerBarrier()
					CastSummonerHeal()
				end	
			elseif spell.name:find("Attack") then
        		--CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
        		if 2*(unit.baseDamage + unit.addDamage) > myHero.health then
					zhonyas()
					CastSummonerBarrier()
					CastSummonerHeal()
				end
			
        	end
    
		end
		
		if string.find(unit.name,"Minion_") == nil and string.find(unit.name,"Turret_") == nil then
			if (unit.team ~= myHero.team) and string.find(spell.name,"Basic") == nil then

				if spell.name == Q then
					if spellDmg[unit.name] and getDmg("Q",myHero,unit)~=nil and getDmg("Q",myHero,unit) > myHero.health then
						willDie=true
					end
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
					--end
				elseif spell.name == W then
					if spellDmg[unit.name] and getDmg("W",myHero,unit)~=nil and getDmg("W",myHero,unit) > myHero.health then
						willDie=true
					end
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
					--end
				elseif spell.name == E then
					if spellDmg[unit.name] and getDmg("E",myHero,unit)~=nil and getDmg("E",myHero,unit) > myHero.health then
						willDie=true
					end
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
					--end
				elseif spell.name == R then
					if spellDmg[unit.name] and getDmg("R",myHero,unit)~=nil and getDmg("R",myHero,unit) > myHero.health then
						willDie=true
					end
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
					--end
		
				end
		
			end
		end
	end
	
	
end

function OnCreateObj(obj)
	if obj~=nil and GetD(obj)<200 then
	--print("\nSpell: "..obj.charName)
	end
	if obj~=nil and string.find(obj.charName,"Lissandra_E_Missile") ~= nil and GetD(obj)<200 then
		EObject=obj
		--print("\nDone")
		
	elseif obj~=nil and string.find(obj.charName,"Lissandra_Passive_Start") ~= nil and GetD(obj)<100 then
		Passive=true
		--print("\nDoneP") 
	elseif obj~=nil and string.find(obj.charName,"Lissandra_E_Arrival") ~= nil and GetD(obj)<200 then -- Lissandra_E_Departure
		EReady=true
		--print("\nDoneD")
	end


end


function harass()
	if target~=nil then
	
		
		if WRDY==1 and GetD(target)<450 then
			CastSpellXYZ('W',GetFireahead(target,1.35,99))
		elseif QRDY==1 and GetD(tqfa)<800 then
			CastSpellXYZ('Q',tqfx,tqfy,tqfz)
		elseif QRDY==1 and GetD(tqfaQ)<1050 and CreepBlock(tqfxQ,tqfyQ,tqfzQ,50)>0 then
			if getLine(tqfaQ,myHero) then
				CastSpellXYZ('Q',tqfxQ,tqfyQ,tqfzQ)--sx,0,sz)
			end
		elseif EReady==true and ERDY==1 and GetD(target)<1100 then
			CastSpellXYZ('E',GetFireahead(target,3.42,8.45))	
		else
			MoveToMouse()
		end
	else
		MoveToMouse()
	end

end

	

function autoQ()
	if targetQ~=nil and QRDY==1 then
		if Passive==true then
			if GetD(tqfaQ)<800 and CreepBlock(tqfxQ,tqfyQ,tqfzQ,50)==0 then
					CastSpellXYZ('Q',tqfxQ,tqfyQ,tqfzQ)
			elseif GetD(tqfaQ)<800 and CreepBlock(tqfxQ,tqfyQ,tqfzQ,50)>0 then
					if getLine(tqfaQ,myHero) then
							CastSpellXYZ('Q',tqfxQ,tqfyQ,tqfzQ)--sx,0,sz)
					end
			elseif GetD(tqfaQ)<1000 and CreepBlock(tqfxQ,tqfyQ,tqfzQ,50)>0 then
					if getLine(tqfaQ,myHero) then
							CastSpellXYZ('Q',tqfxQ,tqfyQ,tqfzQ)--sx,0,sz)
					end
			end
		elseif Passive==false and not LissConfig.qmp then
			if GetD(tqfaQ)<800 and CreepBlock(tqfxQ,tqfyQ,tqfzQ,50)==0 then
					CastSpellXYZ('Q',GetFireahead(targetQ,qdelay,qspeed))
			elseif GetD(tqfaQ)<800 and CreepBlock(tqfxQ,tqfyQ,tqfzQ,50)>0 then
					if getLine(tqfaQ,myHero) then
							CastSpellXYZ('Q',sx,0,sz)
					end
			elseif GetD(tqfaQ)<1000 and CreepBlock(tqfxQ,tqfyQ,tqfzQ,50)>0 then
					if getLine(tqfaQ,myHero) then
							CastSpellXYZ('Q',tqfxQ,tqfyQ,tqfzQ)--sx,0,sz)
					end
			end
		end
	 
	 
	end
 
end
     
function getLine(object,obj)
	local dist=GetD(object,obj)
	local tz,tx
	local mhtarget=nil
	for i = 20,dist,20 do
		if object.x==obj.x then
						tx = object.x
						if object.z>obj.z then
							tz = object.z-i
						else
							tz = object.z+i
						end
   
		elseif object.z==obj.z then
						tz = object.z
						if object.x>obj.x then
										tx = object.x-i
						else
										tx = object.x+i
						end
   
		elseif object.x>obj.x then
						angle = math.asin((object.x-obj.x)/dist)
						zs = i*math.cos(angle)
						xs = i*math.sin(angle)
						if object.z>obj.z then
										tx = object.x-xs
										tz = object.z-zs
						elseif object.z<obj.z then
										tx = object.x-xs
										tz = object.z+zs
						end
   
		elseif object.x<obj.x then
						angle = math.asin((obj.x-object.x)/dist)
						zs = i*math.cos(angle)
						xs = i*math.sin(angle)
						if object.z>obj.z then
										tx = object.x+xs
										tz = object.z-zs
						elseif object.z<obj.z then
										tx = object.x+xs
										tz = object.z+zs
						end                                            
		end
		local txyz={x=tx,y=0,z=tz}	
		local enemyMinions = GetEnemyMinions(MINION_SORT_HEALTH_ASC)

		for _, minion in pairs(enemyMinions) do
			if minion~=nil then
				local tfx,tfy,tfz = GetFireahead(minion,qdelay,qspeed)
				local tfa ={x=tfx,y=tfy,z=tfz}
				if GetD(txyz,tfa)<100 then
					if GetD(tfa,object)>235 then
							wontWork=true
							break
					elseif GetD(tfa,obj)<800 then
							mhtarget=tfa
					end
				end
			end
		end
		if wontWork==true then
				break
		end
	end
	
	if mhtarget==nil or wontWork==true then
		return false
	else
		sx=mhtarget.x
		sz=mhtarget.z
		return true
	end
end

function zhonyas()
	if GetInventorySlot(3157)~=nil and ZReady==true then 
		k = GetInventorySlot(3157)
		CastSpellTarget(tostring(k),myHero)
	elseif GetInventorySlot(3090)~=nil and ZReady==true then 
		k = GetInventorySlot(3090)
		CastSpellTarget(tostring(k),myHero)
	elseif LissConfig.zh==3 and RRDY==1 then
		CastSpellTarget('R',myHero)
	end
end

function surrounded(self)
	local count=0
	for i=1, objManager:GetMaxHeroes(), 1 do
		hero = objManager:GetHero(i)
		if hero~=nil and hero.team~=myHero.team and hero.visible==1 and GetD(self,hero)<550 then
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

function targetAlone(enemy)
	for i=1, objManager:GetMaxHeroes(), 1 do
		hero = objManager:GetHero(i)
		if hero~=nil and hero.team~=myHero.team and hero.name~=enemy.name and hero.visible==1 and GetD(enemy,hero)<700 then
			return false
			--table.insert(enemies,hero)
		end
	end
	return true
end

function runningAway(slowtarget)
   local d1 = GetD(slowtarget)
   local x, y, z = GetFireahead(slowtarget,2,99)
   local d2 = GetD({x=x, y=y, z=z})
   local d3 = GetD({x=x, y=y, z=z},slowtarget)
   local angle = math.acos((d2*d2-d3*d3-d1*d1)/(-2*d3*d1))
   
   return angle%(2*math.pi)>math.pi/2 and angle%(2*math.pi)<math.pi*3/2

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
		if targetAlone(target)==false then
			if target.health<QQ+WW+AA and GetD(target)<400 then
			
				if WRDY==1 then
					CastSpellTarget('W',myHero)
				elseif QRDY==1 then
					CastSpellXYZ('Q',tqfx,tqfy,tqfz)
				elseif target.health<AA then
					AttackTarget(target)
				end		
			elseif target.health<(QQ+WW+RR+AA)*RRDY and GetD(target)<400 and targetAlone(target) then

				if RRDY==1 then
					CastSpellTarget('R',myHero)
				end
				if QRDY==1 then
					CastSpellXYZ('Q',tqfx,tqfy,tqfz)
				elseif WRDY==1 then
					CastSpellTarget('W',myHero)
				elseif target.health<AA then
					AttackTarget(target)
				end		
			elseif target.health<QQ+WW+AA and GetD(target)<400 and targetAlone(target) then
				
				if WRDY==1 then
					CastSpellTarget('W',myHero)
				elseif QRDY==1 then
					CastSpellXYZ('Q',tqfx,tqfy,tqfz)
				elseif target.health<AA then
					AttackTarget(target)
				end
			elseif target.health<(QQ+WW+RR+AA+ignitedamage)*RRDY and GetD(target)<400 and targetAlone(target) then
				if RRDY==1 then
					CastSpellTarget('R',target)
				end
				if QRDY==1 then
					CastSpellXYZ('Q',tqfx,tqfy,tqfz)
				elseif WRDY==1 then
					CastSpellTarget('W',myHero)
				elseif ignitedamage>0 then
					CastSummonerIgnite(target)
				elseif target.health<AA then
					AttackTarget(target)
				end		
			elseif target.health<QQ+WW+AA+ignitedamage and GetD(target)<400 and targetAlone(target) then
				
				if WRDY==1 then
					CastSpellTarget('W',myHero)
				elseif QRDY==1 then
					CastSpellXYZ('Q',tqfx,tqfy,tqfz)
				elseif ignitedamage>0 then
					CastSummonerIgnite(target)
				elseif target.health<AA then
					AttackTarget(target)
				end
			
			elseif target.health<QQ+ignitedamage and GetD(target)<600 then
				if QRDY==1 then
					CastSpellXYZ('Q',tqfx,tqfy,tqfz)
				elseif ignitedamage>0 then
					CastSummonerIgnite(target)
				end				
			end
		elseif targetAlone(target) then
			if target.health<QQ+WW+EE+AA and GetD(target)<400 then
			
				if WRDY==1 then
					CastSpellTarget('W',myHero)
				elseif ERDY==1 and EReady==true then
					CastSpellXYZ('E',GetFireahead(target,5.42,8.45))
					EReady=false
				elseif QRDY==1 then
					CastSpellXYZ('Q',tqfx,tqfy,tqfz)
				elseif target.health<AA then
					AttackTarget(target)
				end		
			elseif target.health<(QQ+WW+RR+EE+AA)*RRDY and GetD(target)<400 and targetAlone(target) then

				if RRDY==1 then
					CastSpellTarget('R',target)
				end
				if ERDY==1 and EReady==true then
					CastSpellXYZ('E',GetFireahead(target,5.42,8.45))
					EReady=false
				elseif QRDY==1 then
					CastSpellXYZ('Q',tqfx,tqfy,tqfz)
				elseif WRDY==1 then
					CastSpellTarget('W',myHero)
				elseif target.health<AA then
					AttackTarget(target)
				end		
			elseif target.health<QQ+WW+EE+AA and GetD(target)<400 and targetAlone(target) then
				
				if WRDY==1 then
					CastSpellTarget('W',myHero)
				elseif ERDY==1 and EReady==true then
					CastSpellXYZ('E',GetFireahead(target,5.42,8.45))
					EReady=false
				elseif QRDY==1 then
					CastSpellXYZ('Q',tqfx,tqfy,tqfz)
				elseif target.health<AA then
					AttackTarget(target)
				end
			elseif target.health<(QQ+WW+RR+EE+AA+ignitedamage)*RRDY and GetD(target)<400 and targetAlone(target) then
				if RRDY==1 then
					CastSpellTarget('R',target)
				end
				if ERDY==1 and EReady==true then
					CastSpellXYZ('E',GetFireahead(target,5.42,8.45))
					EReady=false
				elseif QRDY==1 then
					CastSpellXYZ('Q',tqfx,tqfy,tqfz)
				elseif WRDY==1 then
					CastSpellTarget('W',myHero)
				elseif ignitedamage>0 then
					CastSummonerIgnite(target)
				elseif target.health<AA then
					AttackTarget(target)
				end		
			elseif target.health<QQ+WW+EE+AA+ignitedamage and GetD(target)<400 and targetAlone(target) then
				
				if WRDY==1 then
					CastSpellTarget('W',myHero)
				elseif ERDY==1 and EReady==true then
					CastSpellXYZ('E',GetFireahead(target,5.42,8.45))
					EReady=false
				elseif QRDY==1 then
					CastSpellXYZ('Q',tqfx,tqfy,tqfz)
				elseif ignitedamage>0 then
					CastSummonerIgnite(target)
				elseif target.health<AA then
					AttackTarget(target)
				end
			elseif target.health<QQ+ignitedamage and GetD(target)<600 then
				if QRDY==1 then
					CastSpellXYZ('Q',tqfx,tqfy,tqfz)
				elseif ignitedamage>0 then
					CastSummonerIgnite(target)
				end				
			end
		end
		
		if target600~=nil and target600.health<ignitedamage then
			CastSummonerIgnite(target600)
		end
		
	end
end


function OnDraw()

	if myHero.dead~=1 then
		CustomCircle(1050,3,3,myHero)
		if QRDY==1 then
			CustomCircle(800,3,3,myHero)
		end
		if WRDY==1 then
			CustomCircle(455,3,2,myHero)
		end

		if ERDY==1 then
			CustomCircle(1130,10,1,myHero)
		end
		if RRDY==1 then
			CustomCircle(550,10,4,myHero)
		end
	end
	if target~=nil then
		CustomCircle(100,3,5,target)
		DrawCircle(tqfx,tqfy,tqfz,150,4)
	end
end



function dodgeaoe(pos1, pos2, radius)
    local calc = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
	local dodgex
    local dodgez
    dodgex = pos2.x + ((radius+150)/calc)*(myHero.x-pos2.x)
    dodgez = pos2.z + ((radius+150)/calc)*(myHero.z-pos2.z)
	
	
    if calc < radius then
		if willDie==true then
			zhonyas()
			CastSummonerBarrier()
			CastSummonerHeal()
		elseif dodgeskillshot == true then
			MoveToXYZ(dodgex,0,dodgez)
		end
        			--CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
					
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
    local dodgex
    local dodgez
    perpendicular = (math.floor((math.abs((pos2.x-pos1.x)*(pos1.z-myHero.z)-(pos1.x-myHero.x)*(pos2.z-pos1.z)))/(math.sqrt((pos2.x-pos1.x)^2 + (pos2.z-pos1.z)^2))))
    k = ((pos2.z-pos1.z)*(myHero.x-pos1.x) - (pos2.x-pos1.x)*(myHero.z-pos1.z)) / ((pos2.z-pos1.z)^2 + (pos2.x-pos1.x)^2)
	x4 = myHero.x - k * (pos2.z-pos1.z)
	z4 = myHero.z + k * (pos2.x-pos1.x)
	calc3 = (math.floor(math.sqrt((x4-myHero.x)^2 + (z4-myHero.z)^2)))
	dodgex = x4 + ((radius+150)/calc3)*(myHero.x-x4)
    dodgez = z4 + ((radius+150)/calc3)*(myHero.z-z4)
    if perpendicular < radius and calc1 < calc4 and calc2 < calc4 then
		if willDie==true then
			zhonyas()
			CastSummonerBarrier()
			CastSummonerHeal()
		elseif dodgeskillshot == true then
			MoveToXYZ(dodgex,0,dodgez)
		end
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
    local dodgex
    local dodgez
    perpendicular = (math.floor((math.abs((pm2x-pos1.x)*(pos1.z-myHero.z)-(pos1.x-myHero.x)*(pm2z-pos1.z)))/(math.sqrt((pm2x-pos1.x)^2 + (pm2z-pos1.z)^2))))
    k = ((pm2z-pos1.z)*(myHero.x-pos1.x) - (pm2x-pos1.x)*(myHero.z-pos1.z)) / ((pm2z-pos1.z)^2 + (pm2x-pos1.x)^2)
	x4 = myHero.x - k * (pm2z-pos1.z)
	z4 = myHero.z + k * (pm2x-pos1.x)
	calc3 = (math.floor(math.sqrt((x4-myHero.x)^2 + (z4-myHero.z)^2)))
	dodgex = x4 + ((radius+150)/calc3)*(myHero.x-x4)
    dodgez = z4 + ((radius+150)/calc3)*(myHero.z-z4)
    if perpendicular < radius and calc1 < calc4 and calc2 < calc4 then
		if willDie==true then
			zhonyas()
			CastSummonerBarrier()
			CastSummonerHeal()
		elseif dodgeskillshot == true then
			MoveToXYZ(dodgex,0,dodgez)
		end
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
                table.insert(skillshotArray,{name= "MissileBarrageMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1235, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
                table.insert(skillshotArray,{name= "MissileBarrageMissile2", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1235, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
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
                table.insert(skillshotArray,{name= "CH1ConcussionGrenade", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 235, color= coloryellow, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
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
                table.insert(skillshotArray,{name= "KogMawLivingArtillery", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2300, type = 3, radius = 200, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
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
                table.insert(skillshotArray,{name= "VeigarDarkMatter", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 235, color= coloryellow, time = 2, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
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
                table.insert(skillshotArray,{name= "ZiggsW", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 3, radius = 235 , color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
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