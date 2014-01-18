require "Utils"
require 'spell_damage'
print=printtext
printtext("\nRiding on Riven\n")
printtext("\nBy Malbert\n")
printtext("\nBeta 2.6\n")

local target
local stuntarget
local targetult
local ignitedamage
local Ractive=false
local Rtimer=os.clock()
local Atimer=os.clock()
local threshold=1/4
local Rdamage=0
local Rdamage2=0
local castR=false
local Rtimer=os.clock()
local ufa
local ufax,ufay,ufaz
local ufa2
local ufa2x,ufa2y,ufa2z
local delay=0.001
local Q2ETimer=0
--------Spell Stuff
local QRDY=0
local WRDY=0
local ERDY=0
local RRDY=0
local Qmod=0
local QmodReset=0
local Qspot=nil
local QLayoutSpot=0


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

local autoE=false

     
RivConfig = scriptConfig("Riven", "Riven Config")
RivConfig:addParam("h", "Harass QWQQ EscapeE", SCRIPT_PARAM_ONKEYDOWN, false, 65)
RivConfig:addParam("teamfight", "Teamfight", SCRIPT_PARAM_ONKEYDOWN, false, 84)
RivConfig:addParam("tf2", "EQQWQ Combo", SCRIPT_PARAM_ONKEYDOWN, false, 89)
RivConfig:addParam("c", "Combo No Ult", SCRIPT_PARAM_ONKEYDOWN, false, 88)
RivConfig:addParam("g", "Escape QQQE", SCRIPT_PARAM_ONKEYDOWN, false, 90)
RivConfig:addParam("shield", "AutoShield", SCRIPT_PARAM_ONKEYTOGGLE, true, 117)
RivConfig:addParam("stun", "AutoStun", SCRIPT_PARAM_ONKEYTOGGLE, false, 48)
RivConfig:addParam("ks", " KillSteal", SCRIPT_PARAM_ONOFF, true)
RivConfig:addParam("smite", "Smitesteal", SCRIPT_PARAM_ONKEYTOGGLE, false, 119)
RivConfig:addParam('s', "AA Delay in Combos", SCRIPT_PARAM_NUMERICUPDOWN, 0.4, 118,0,1,0.05)
RivConfig:permaShow("teamfight")
RivConfig:permaShow("ks")
RivConfig:permaShow("smite")
RivConfig:permaShow("shield")
RivConfig:permaShow("stun")
RivConfig:permaShow("s")
     
     
function Run()

		
		delay=RivConfig.s

	targetult = GetWeakEnemy("PHYS", 1000)
	target = GetWeakEnemy("PHYS", 500)
	stuntarget = GetWeakEnemy("PHYS", 265)
	if target~=nil then
		ufax,ufay,ufaz = GetFireahead(target,5,22)
		ufa={x=ufax,y=ufay,z=ufaz}
		if target.health/target.maxHealth<1/4 then
			Rdamage=CalcDamage(target,(120+(120*GetSpellLevel('R'))+1.8*myHero.addDamage))*RRDY
		else
			Rdamage=CalcDamage(target,(40+(40*GetSpellLevel('R'))+.6*myHero.addDamage)+(40+(40*GetSpellLevel('R'))+.6*myHero.addDamage)*(1-target.health/target.maxHealth)*8/300)*RRDY
		end
	else
		Rdamage=0
	end
	if targetult~=nil then
		ufa2x,ufa2y,ufa2z = GetFireahead(targetult,5,22)
		ufa2={x=ufa2x,y=ufa2y,z=ufa2z}
		if targetult.health/targetult.maxHealth<1/4 then
			Rdamage2=CalcDamage(targetult,(120+(120*GetSpellLevel('R'))+1.8*myHero.addDamage))*RRDY
		else
			Rdamage2=CalcDamage(targetult,(40+(40*GetSpellLevel('R'))+.6*myHero.addDamage)+(40+(40*GetSpellLevel('R'))+.6*myHero.addDamage)*(1-targetult.health/targetult.maxHealth)*8/300)*RRDY
		end
	else
		Rdamage=0
	end

	ignite()
	if castR==false and Ractive==true then
		if Rtimer+13.5<os.clock() then
			castR=true
		else
			castR=false
		end
	elseif castR==true and Rtimer+15<os.clock() then
		castR=false
	end

	if RivConfig.ks then killsteal() end
	if RivConfig.smite then smitesteal() end
	if RivConfig.shield and ERDY==1 then 
		autoE=true
	else 
		autoE=false
	end
	
			
	if IsChatOpen() == 0 and RivConfig.teamfight then
		if target~=nil then
			if QRDY==1 and (os.clock()>Atimer or GetD(target)>myHero.range+150) then
				CastSpellXYZ("Q",ufa.x,0,ufa.z)

				if RRDY==1 and Ractive==false then
					CastSpellXYZ("R",myHero.x,0,myHero.z)
					Ractive=true
				end
				if WRDY==1 and Ractive==true and GetD(target)<250 then
					CastSpellXYZ("W",ufa.x,0,ufa.z)
				end

			elseif WRDY==1 and (os.clock()>Atimer) and GetD(target,myHero)<275 then
				CastSpellXYZ("W",myHero.x,0,myHero.z)
			elseif ERDY==1 and (os.clock()>Atimer or GetD(target)>myHero.range+150) then
				CastSpellXYZ("E",ufa.x,0,ufa.z)
			elseif RRDY==1 and Ractive==false and target.dead~=1 and (os.clock()>Atimer) then
				CastSpellXYZ("R",ufa.x,0,ufa.z)
				Ractive=true
			elseif Ractive==true and target.dead~=1 and (target.health<Rdamage or castR==true or myHero.health<15/100*myHero.maxHealth) then --or target.health/target.maxHealth<1/4
				CastSpellXYZ("R",ufa.x,0,ufa.z)
				Ractive=false
			else
				if GetD(target)<400 then
					CastSummonerExhaust(target)
					UseAllItems(target)
				elseif GetD(target)<600 then
					CastSummonerExhaust(target)
					UseTargetItems(target)
				end
				AttackTarget(target)

			end


		elseif targetult~=nil and Ractive==true and GetD(targetult)>600 and GetD(ufa2)<900 then
			if ERDY==1 then
				CastSpellXYZ("E",ufa2.x,0,ufa2.z)
			elseif targetult.dead~=1 then
				CastSpellXYZ("R",ufa2.x,0,ufa2.z)
			end
		elseif targetult~=nil then
			CastSpellXYZ("E",ufa2.x,0,ufa2.z)
			AttackTarget(targetult)
		else
			MoveToMouse()
		end
	end
	if IsChatOpen() == 0 and RivConfig.tf2 then
		TF2()
	end

	if IsChatOpen() == 0 and RivConfig.h then
		harass()
	end
			
			
	if IsChatOpen() == 0 and RivConfig.c then
		combo()
	end
	if IsChatOpen() == 0 and RivConfig.g then
		Escape()
	end
        	        
	if RivConfig.stun and WRDY==1 and stuntarget~=nil and (IsChatOpen() == 1 or IsChatOpen() == 0 and not RivConfig.teamfight and not RivConfig.tf2 and not RivConfig.h and not RivConfig.c and not RivConfig.g)then
		CastSpellTarget('W',myHero)
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
		if Qmod~=0 and QmodReset<os.clock() then
			Qmod=0
			Qspot=nil
		end
		if Qspot~=nil and Qmod~=2 then
			Qspot=nil
		end
end
     

     
function OnProcessSpell(unit,spell)


	if (RivConfig.teamfight or RivConfig.combo) and unit.name==myHero.name and unit.team==myHero.team then  
		if string.find(spell.name,"RivenTriCleave") ~= nil then
			Qmod=(Qmod+1)%3
			QmodReset=os.clock()+3.5
			Atimer=os.clock()+(1/myHero.attackspeed)-(1-delay)/myHero.attackspeed			
		elseif string.find(spell.name,"RivenMartyr") ~= nil then
			Atimer=os.clock()+(1/myHero.attackspeed)-(1-delay)/myHero.attackspeed

		elseif string.find(spell.name,"RivenFeint") ~= nil then
			Atimer=os.clock()+(1/myHero.attackspeed)-(1-delay)/myHero.attackspeed

		elseif string.find(spell.name,"RivenFengShuiEngine") ~= nil then    
			Ractive=true
			Rtimer=os.clock()
			Atimer=os.clock()+(1/myHero.attackspeed)-(1-delay)/myHero.attackspeed
                
		elseif string.find(spell.name,"rivenizunablade") ~= nil then  
			Ractive=false
			castR=false
			Atimer=os.clock()+(1/myHero.attackspeed) -(1-delay)/myHero.attackspeed
		end 
		--[[if string.find(spell.name,"BasicAttack") ~= nil or string.find(spell.name,"CritAttack") ~= nil then  
		--    Atimer=os.clock()+(1/myHero.attackspeed)
		end--]]
	elseif unit.name==myHero.name and unit.team==myHero.team then
		if string.find(spell.name,"RivenFengShuiEngine") ~= nil then    
			Ractive=true
			Rtimer=os.clock()
			Atimer=os.clock()+(1/myHero.attackspeed)-(1-delay)/myHero.attackspeed

		elseif string.find(spell.name,"rivenizunablade") ~= nil then  
			Ractive=false
			castR=false
			Atimer=os.clock()+(1/myHero.attackspeed)-(1-delay)/myHero.attackspeed
		end 

	end
	
	if autoE==true and unit~=nil then
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
				CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
				if spellDmg[unit.name] and getDmg("Q",myHero,unit)~=nil and getDmg("Q",myHero,unit) > myHero.health then
					CastSummonerBarrier()
					CastSummonerHeal()
				end
    		
			elseif spell.name == W then
        		CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
        		if spellDmg[unit.name] and getDmg("W",myHero,unit)~=nil and getDmg("W",myHero,unit) > myHero.health then
					CastSummonerBarrier()
					CastSummonerHeal()
				end
    		
			elseif spell.name == E then
   			    CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
    			if spellDmg[unit.name] and getDmg("E",myHero,unit)~=nil and getDmg("E",myHero,unit) > myHero.health then
					CastSummonerBarrier()
					CastSummonerHeal()
        		end

			elseif spell.name == R then
        		CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
        		if spellDmg[unit.name] and getDmg("R",myHero,unit)~=nil and getDmg("R",myHero,unit) > myHero.health then
					CastSummonerBarrier()
					CastSummonerHeal()
        		end
    		
			elseif string.find(unit.name,"minion") == nil and string.find(unit.name,"Minion_") == nil and (spell.name:find("BasicAttack") or spell.name:find("BasicAttack2") or spell.name:find("BasicaAttack3")  or spell.name:find("ChaosTurretFire")) then
        		CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
				if (unit.baseDamage + unit.addDamage) > myHero.health then
					print("\nMN "..unit.name)
					CastSummonerBarrier()
					CastSummonerHeal()
				end	
			elseif spell.name:find("BasicAttack") or spell.name:find("BasicAttack2") or spell.name:find("BasicaAttack3")  or spell.name:find("ChaosTurretFire") then
        		if (unit.baseDamage + unit.addDamage) > myHero.health then
        			CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
					CastSummonerBarrier()
					CastSummonerHeal()
				end	
			elseif spell.name:find("CritAttack") then
        		CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
        		if 2*(unit.baseDamage + unit.addDamage) > myHero.health then
					CastSummonerBarrier()
					CastSummonerHeal()
				end
        	end
    
		end
		
		if string.find(unit.name,"Minion_") == nil and string.find(unit.name,"Turret_") == nil then
			if (unit.team ~= myHero.team) and string.find(spell.name,"Basic") == nil then

				if spell.name == Q then
					--if spellDmg[unit.name] and getDmg("Q",myHero,unit)~=nil and getDmg("Q",myHero,unit) > myHero.health then
		
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
					--if spellDmg[unit.name] and getDmg("W",myHero,unit)~=nil and getDmg("W",myHero,unit) > myHero.health then
		
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
					--if spellDmg[unit.name] and getDmg("E",myHero,unit)~=nil and getDmg("E",myHero,unit) > myHero.health then
		
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
					--if spellDmg[unit.name] and getDmg("R",myHero,unit)~=nil and getDmg("R",myHero,unit) > myHero.health then
		
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

function TF2()
	if target~=nil then
		if ERDY==1 and (os.clock()>Atimer or GetD(target)>myHero.range+150) then
			CastSpellXYZ("E",ufa.x,0,ufa.z)
		elseif QRDY==1 and (os.clock()>Atimer or GetD(target)>myHero.range+150) and Qmod<2 then
			
			if Ractive==false and RRDY==1 then
				CastSpellXYZ("R",myHero.x,0,myHero.z)
				Ractive=true
			end
			CastSpellXYZ("Q",ufa.x,0,ufa.z)

		elseif WRDY==1 and (os.clock()>Atimer) and GetD(target,myHero)<275 then
		
			if not runningAway(target) then
				local tx,tz=0,0
				local qx,qy,qz=GetFireahead(target,2,0)
				Qspot={x=qx,y=qy,z=qz}
				local dist=GetD(Qspot,target)
				if target.x==Qspot.x then
						tx = Qspot.x
						if target.z>Qspot.z then
								tz = target.z+dist
						else
								tz = target.z-dist
						end
			   
				elseif Qspot.z==target.z then
						tz = target.z
						if target.x>Qspot.x then
								tx = target.x+(dist)
						else
								tx = target.x-(dist)
						end
			   
				elseif target.x>Qspot.x then
						angle = math.asin((target.x+Qspot.x)/dist)
						zs = (dist)*math.cos(angle)
						xs = (dist)*math.sin(angle)
						if target.z>Qspot.z then
								tx = target.x+xs
								tz = target.z+zs
						elseif target.z<Qspot.z then
								tx = target.x+xs
								tz = target.z-zs
						end
			   
				elseif target.x<Qspot.x then
						angle = math.asin((Qspot.x+target.x)/dist)
						zs = (dist)*math.cos(angle)
						xs = (dist)*math.sin(angle)
						if target.z>Qspot.z then
								tx = target.x-xs
								tz = target.z+zs
						elseif target.z<Qspot.z then
								tx = target.x-xs
								tz = target.z-zs
						end 
				end
				Qspot={x=tx,y=qy,z=tz}
			else
				local qx,qy,qz=GetFireahead(target,2,0)
				Qspot={x=qx,y=qy,z=qz}
			end
			
			CastSpellXYZ("W",myHero.x,0,myHero.z)
		elseif RRDY==1 and Ractive==false and target.dead~=1 then
			CastSpellXYZ("R",ufa.x,0,ufa.z)
			Ractive=true
		elseif Ractive==true and target.dead~=1 and (target.health<Rdamage  or castR==true or myHero.health<15/100*myHero.maxHealth) then --or target.health/target.maxHealth<1/4
			CastSpellXYZ("R",ufa.x,0,ufa.z)
			Ractive=false
		else
			if GetD(target)<400 then
				CastSummonerExhaust(target)
				UseAllItems(target)
			elseif GetD(target)<600 then
				CastSummonerExhaust(target)
				UseTargetItems(target)
			end
			if Qmod==2 and Qspot==nil then				
				AttackTarget(target)
			elseif Qmod==2 and Qspot~=nil and GetD(Qspot)>50 then
				MoveToXYZ(Qspot.x,0,Qspot.z)
			elseif Qmod==2 and Qspot~=nil and GetD(Qspot)<=50 then
				CastSpellXYZ("Q",ufa.x,0,ufa.z)
			else
				AttackTarget(target)
			end
		end


	elseif targetult~=nil and Ractive==true and GetD(targetult)>600 and GetD(ufa2)<900 then
		if ERDY==1 then
			CastSpellXYZ("E",ufa2.x,0,ufa2.z)
		elseif targetult.dead~=1 then
			CastSpellXYZ("R",ufa2.x,0,ufa2.z)
		end
	elseif targetult~=nil then
		CastSpellXYZ("E",ufa2.x,0,ufa2.z)
		AttackTarget(targetult)
	else
		MoveToMouse()
	end

end

function combo()
if target~=nil then
if QRDY==1 and (os.clock()>Atimer or GetD(target)>myHero.range+150) then
CastSpellXYZ("Q",ufa.x,0,ufa.z)
if WRDY==1 and Ractive==true and GetD(target)<250 then
CastSpellXYZ("W",ufa.x,0,ufa.z)
end
elseif WRDY==1 and (os.clock()>Atimer) and GetD(target,myHero)<280 then
CastSpellXYZ("W",myHero.x,0,myHero.z)
elseif ERDY==1 and (os.clock()>Atimer or GetD(target)>myHero.range+150) then
CastSpellXYZ("E",ufa.x,0,ufa.z)
else
if GetD(target)<600 then
CastSummonerExhaust(target)
UseTargetItems(target)
elseif GetD(target)<400 then
CastSummonerExhaust(target)
UseTargetItems(target)
UseSelfItems(target)
end
AttackTarget(target)
end
elseif targetult~=nil then
if ERDY==1 then CastSpellXYZ("E",ufa2.x,0,ufa2.z)
elseif QRDY==1 then CastSpellXYZ("Q",ufa2.x,0,ufa2.z) 
else AttackTarget(targetult) end
else
MoveToMouse()
end  
end

function harass()
	if targetult~=nil then
	local mx,my=0,0
		if QRDY==1 and GetD(ufa2)<600 then
			Q2ETimer=os.clock()+1
			
			ClickSpellXYZ("Q",ufa2.x,0,ufa2.z,0)
			CastSpellXYZ("Q",ufa2.x,0,ufa2.z)
		elseif WRDY==1 and GetD(targetult)<275 then
			
			CastSpellTarget("W",myHero)
		elseif QRDY==0 and ERDY==1 and Q2ETimer<os.clock() then
			local xspot=0
			local zspot=0
			local xdist=0
			local zdist=0
			xdist=myHero.x- ufa2.x
				xspot=myHero.x+1.1*xdist	
				
			zdist=myHero.z-ufa2.z
				zspot=myHero.z+ 1.1*zdist
				
			
			
			
			ClickSpellXYZ("E",xspot,0,zspot,0)
			CastSpellXYZ("E",xspot,0,zspot)
		else
			MoveToMouse()
		end
	else
		MoveToMouse()
	end

end


function Escape()
	if ERDY==1  then
		print('\nE  '..myHero.SpellTimeE..'  '..myHero.SpellNameE)
		CastSpellXYZ("E",mousePos.x,0,mousePos.z)
	elseif ERDY==0 and QRDY==1 then
		print('\n'..myHero.SpellTimeQ..'  '..myHero.SpellNameQ)
		CastSpellXYZ("Q",mousePos.x,0,mousePos.z)
	else
		MoveToMouse()
	end  
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
	if targetult~=nil then
		local W = getDmg('W',targetult,myHero)*WRDY
		if targetult.health<W+Rdamage2+ignitedamage and GetD(targetult)<275 and targetult.dead~=1 then
			CastSpellXYZ("W",ufa2.x,0,ufa2.z)
			CastSpellXYZ("R",ufa2.x,0,ufa2.z)
			if ignitedamage~=0 then CastSummonerIgnite(targetult) end
		elseif targetult.health<(W+Rdamage2+ignitedamage)*ERDY and GetD(ufa2)<550 and targetult.dead~=1 then
			CastSpellXYZ("E",ufa2.x,0,ufa2.z)
		elseif targetult.health<Rdamage2+ignitedamage and GetD(targetult)<600 and targetult.dead~=1 then
			CastSpellXYZ("R",ufa2.x,0,ufa2.z)
			if ignitedamage~=0 then CastSummonerIgnite(targetult) end
		elseif targetult.health<Rdamage2 and GetD(ufa2)<900 and targetult.dead~=1 then
			CastSpellXYZ("R",ufa2.x,0,ufa2.z)
		end
	end
end


function OnDraw()

	if myHero.dead~=1 then
		if QRDY==1 then
			CustomCircle(300,3,3,myHero)
		end
		if WRDY==1 then
			CustomCircle(275,3,2,myHero)
		end

		if RRDY==1 then
			CustomCircle(950,10,1,myHero)
		end
	end
	if target~=nil then
		CustomCircle(100,3,5,target)
	end
	if targetult~=nil then
		CustomCircle(100,3,4,targetult)
		
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

function dodgeaoe(pos1, pos2, radius)
    local calc = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
    if calc < radius then
		
        			CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
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
	
        			CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
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
		
        			
					CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
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