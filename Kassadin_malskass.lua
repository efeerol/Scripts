require "Utils"
require 'spell_damage'
print=printtext
printtext("\nA-Void Me\n")
printtext("\nBy Malbert\n")
printtext("\nVersion 1.2\n")

local target
local targetclose
local targetks
local ignitedamage=0
local QRDY=0
local WRDY=0
local ERDY=0
local RRDY=0
local RDIST
local NRDIST
local enemyIndex=1
local enemies={}


KassConfig = scriptConfig("Kass", "Kass Config")
KassConfig:addParam("h", " Harass", SCRIPT_PARAM_ONKEYDOWN, false, 88)
KassConfig:addParam("e", " Escape Harass", SCRIPT_PARAM_ONKEYDOWN, false, 65)
KassConfig:addParam("r", " R Escape", SCRIPT_PARAM_ONKEYDOWN, false, 90)
KassConfig:addParam('teamfight', 'TeamFight', SCRIPT_PARAM_ONKEYDOWN, false, 84)
KassConfig:addParam("mode", "Harass Mode", SCRIPT_PARAM_DOMAINUPDOWN, 1, 187, {"Use Ult","No Ult"})
KassConfig:addParam('distanceR', "R Distance", SCRIPT_PARAM_NUMERICUPDOWN, 500, 57,100,700,50)
KassConfig:addParam('distanceNR', "NR Distance", SCRIPT_PARAM_NUMERICUPDOWN, 600, 48,100,700,50)
KassConfig:addParam('dokillsteal', 'Killsteal', SCRIPT_PARAM_ONOFF, true)
KassConfig:addParam('rks', 'R KS ON/OFF', SCRIPT_PARAM_ONOFF, true)
KassConfig:addParam('nm', 'NearMouse Targetting', SCRIPT_PARAM_ONOFF, true)
KassConfig:permaShow('mode')
KassConfig:permaShow('dokillsteal')
	
function Run()
	
	if KassConfig.nm==true then
		target = GetWeakEnemy("MAGIC", 1400,"NEARMOUSE")
		targetclose = GetWeakEnemy("MAGIC", 700,"NEARMOUSE")
	else
		target = GetWeakEnemy("MAGIC", 1400)
		targetclose = GetWeakEnemy("MAGIC", 700)
	end
	
		targetkslongrange = GetWeakEnemy("MAGIC", 1400)
		targetks = GetWeakEnemy("MAGIC", 700)
		
		
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
			else RRDY = 0 
	end
	
		

	
	--[[for i=1, objManager:GetMaxHeroes(), 1 do
		local hero = objManager:GetHero(i)
		if hero~=nil and hero.team~=myHero.team and hero.name~=nil then
			if enemies[hero.name]==nil then
				enemies[hero.name]={unit=hero,number=enemyIndex}
				enemyIndex=enemyIndex+1
			end
		end
	end--]]
	
	if IsChatOpen() == 0 and KassConfig.h then harass() end
	if IsChatOpen() == 0 and KassConfig.e then escape() end
	if IsChatOpen() == 0 and KassConfig.r then ultEsc() end
	if IsChatOpen() == 0 and KassConfig.teamfight then Teamfight() end
	if KassConfig.dokillsteal then killsteal() end
	ignite()

	
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

function ultEsc()
	if RRDY==1 then
		CastSpellXYZ('R',GetCursorWorldX(),GetCursorWorldY(),GetCursorWorldZ())
	else
		MoveToMouse()
	end
end

function harass()

	if target~=nil then
	local tx,tz
	RDIST=KassConfig.distanceR*target.movespeed/330
	NRDIST=KassConfig.distanceNR*target.movespeed/330
	print("\n"..RDIST)
		print("\n MS "..target.movespeed)
		if KassConfig.mode==1 and RRDY==1 then
		
		local angle
			if ERDY==1 then
				if GetD(target,myHero)<650 then
					CastSpellTarget('Q',target)
					CastSpellXYZ('E',target.x,0,target.z)
				elseif GetD(target,myHero)<1200 then
				
					dist=GetD(target,myHero)
					if not runningAway(target) then
						if target.x==myHero.x then
							tx = target.x
							if target.z>myHero.z then
								tz = target.z-NRDIST
							else
								tz = target.z+NRDIST
							end
						
						elseif target.z==myHero.z then
							tz = target.z
							if target.x>myHero.x then
								tx = target.x-NRDIST
							else
								tx = target.x+NRDIST
							end
						
						elseif target.x>myHero.x then
							angle = math.asin((target.x-myHero.x)/dist)
							zs = NRDIST*math.cos(angle)
							xs = NRDIST*math.sin(angle)
							if target.z>myHero.z then
								tx = target.x-xs
								tz = target.z-zs
							elseif target.z<myHero.z then
								tx = target.x-xs
								tz = target.z+zs
							end
						
						elseif target.x<myHero.x then
							angle = math.asin((myHero.x-target.x)/dist)
							zs = NRDIST*math.cos(angle)
							xs = NRDIST*math.sin(angle)
							if target.z>myHero.z then
								tx = target.x+xs
								tz = target.z-zs
							elseif target.z<myHero.z then
								tx = target.x+xs
								tz = target.z+zs
							end						
						end
					elseif runningAway(target) then	
						if target.x==myHero.x then
							tx = target.x
							if target.z>myHero.z then
								tz = target.z-RDIST
							else
								tz = target.z+RDIST
							end
						
						elseif target.z==myHero.z then
							tz = target.z
							if target.x>myHero.x then
								tx = target.x-RDIST
							else
								tx = target.x+RDIST
							end
						
						elseif target.x>myHero.x then
							angle = math.asin((target.x-myHero.x)/dist)
							zs = RDIST*math.cos(angle)
							xs = RDIST*math.sin(angle)
							if target.z>myHero.z then
								tx = target.x-xs
								tz = target.z-zs
							elseif target.z<myHero.z then
								tx = target.x-xs
								tz = target.z+zs
							end
						
						elseif target.x<myHero.x then
							angle = math.asin((myHero.x-target.x)/dist)
							zs = RDIST*math.cos(angle)
							xs = RDIST*math.sin(angle)
							if target.z>myHero.z then
								tx = target.x+xs
								tz = target.z-zs
							elseif target.z<myHero.z then
								tx = target.x+xs
								tz = target.z+zs
							end						
						end					
					
					end
					CastSpellXYZ('R',tx,0,tz)
					CastSpellTarget('Q',target)
					if GetD(target,myHero)<600 then CastSpellXYZ('E',target.x,0,target.z) end
				end
				
			elseif ERDY==0 and QRDY==1 then
				if GetD(target,myHero)<650 then
					CastSpellTarget('Q',target)
				elseif GetD(target,myHero)<1200 then
				
					dist=GetD(target,myHero)
					
					if not runningAway(target) then
						if target.x==myHero.x then
							tx = target.x
							if target.z>myHero.z then
								tz = target.z-NRDIST
							else
								tz = target.z+NRDIST
							end
						
						elseif target.z==myHero.z then
							tz = target.z
							if target.x>myHero.x then
								tx = target.x-NRDIST
							else
								tx = target.x+NRDIST
							end
						
						elseif target.x>myHero.x then
							angle = math.asin((target.x-myHero.x)/dist)
							zs = NRDIST*math.cos(angle)
							xs = NRDIST*math.sin(angle)
							if target.z>myHero.z then
								tx = target.x-xs
								tz = target.z-zs
							elseif target.z<myHero.z then
								tx = target.x-xs
								tz = target.z+zs
							end
						
						elseif target.x<myHero.x then
							angle = math.asin((myHero.x-target.x)/dist)
							zs = NRDIST*math.cos(angle)
							xs = NRDIST*math.sin(angle)
							if target.z>myHero.z then
								tx = target.x+xs
								tz = target.z-zs
							elseif target.z<myHero.z then
								tx = target.x+xs
								tz = target.z+zs
							end						
						end
					elseif runningAway(target) then	
						if target.x==myHero.x then
							tx = target.x
							if target.z>myHero.z then
								tz = target.z-RDIST
							else
								tz = target.z+RDIST
							end
						
						elseif target.z==myHero.z then
							tz = target.z
							if target.x>myHero.x then
								tx = target.x-RDIST
							else
								tx = target.x+RDIST
							end
						
						elseif target.x>myHero.x then
							angle = math.asin((target.x-myHero.x)/dist)
							zs = RDIST*math.cos(angle)
							xs = RDIST*math.sin(angle)
							if target.z>myHero.z then
								tx = target.x-xs
								tz = target.z-zs
							elseif target.z<myHero.z then
								tx = target.x-xs
								tz = target.z+zs
							end
						
						elseif target.x<myHero.x then
							angle = math.asin((myHero.x-target.x)/dist)
							zs = RDIST*math.cos(angle)
							xs = RDIST*math.sin(angle)
							if target.z>myHero.z then
								tx = target.x+xs
								tz = target.z-zs
							elseif target.z<myHero.z then
								tx = target.x+xs
								tz = target.z+zs
							end						
						end					
					
					end
					CastSpellXYZ('R',tx,0,tz)
					CastSpellTarget('Q',target)
				end
			end

		elseif RRDY==0 or KassConfig.mode==2 then
			if GetD(target,myHero)<600 then
				CastSpellTarget('Q',target)
				CastSpellXYZ('E',target.x,0,target.z)
			elseif GetD(target,myHero)>600 and QRDY==1 then
				CastSpellTarget('Q',target)
				if ERDY==1 then
					MoveToXYZ(target.x,0,target.z)
				end
			end			
		end
	else 
		MoveToMouse()
	end
	
end


function escape()

	if target~=nil then
	local tx,tz
		if RRDY==1 then
			if ERDY==1 then
				if GetD(target,myHero)<1200 then
				
					dist=GetD(target,myHero)
					
					if not runningAway(target) then
						if target.x==myHero.x then
							tx = target.x
							if target.z>myHero.z then
								tz = target.z-600
							else
								tz = target.z+600
							end
						
						elseif target.z==myHero.z then
							tz = target.z
							if target.x>myHero.x then
								tx = target.x-600
							else
								tx = target.x+600
							end
						
						elseif target.x>myHero.x then
							angle = math.asin((target.x-myHero.x)/dist)
							zs = 600*math.cos(angle)
							xs = 600*math.sin(angle)
							if target.z>myHero.z then
								tx = target.x-xs
								tz = target.z-zs
							elseif target.z<myHero.z then
								tx = target.x-xs
								tz = target.z+zs
							end
						
						elseif target.x<myHero.x then
							angle = math.asin((myHero.x-target.x)/dist)
							zs = 600*math.cos(angle)
							xs = 600*math.sin(angle)
							if target.z>myHero.z then
								tx = target.x+xs
								tz = target.z-zs
							elseif target.z<myHero.z then
								tx = target.x+xs
								tz = target.z+zs
							end						
						end
					elseif runningAway(target) then	
						if target.x==myHero.x then
							tx = target.x
							if target.z>myHero.z then
								tz = target.z-500
							else
								tz = target.z+500
							end
						
						elseif target.z==myHero.z then
							tz = target.z
							if target.x>myHero.x then
								tx = target.x-500
							else
								tx = target.x+500
							end
						
						elseif target.x>myHero.x then
							angle = math.asin((target.x-myHero.x)/dist)
							zs = 500*math.cos(angle)
							xs = 500*math.sin(angle)
							if target.z>myHero.z then
								tx = target.x-xs
								tz = target.z-zs
							elseif target.z<myHero.z then
								tx = target.x-xs
								tz = target.z+zs
							end
						
						elseif target.x<myHero.x then
							angle = math.asin((myHero.x-target.x)/dist)
							zs = 500*math.cos(angle)
							xs = 500*math.sin(angle)
							if target.z>myHero.z then
								tx = target.x+xs
								tz = target.z-zs
							elseif target.z<myHero.z then
								tx = target.x+xs
								tz = target.z+zs
							end						
						end					
					
					end
					CastSpellXYZ('R',tx,0,tz)
					CastSpellTarget('Q',target)
					if GetD(target,myHero)<630 then CastSpellXYZ('E',target.x,0,target.z) end
				end
				
			elseif ERDY==0 and QRDY==1 then
				if GetD(target,myHero)<1200 then
				
					dist=GetD(target,myHero)
					
					if not runningAway(target) then
						if target.x==myHero.x then
							tx = target.x
							if target.z>myHero.z then
								tz = target.z-600
							else
								tz = target.z+600
							end
						
						elseif target.z==myHero.z then
							tz = target.z
							if target.x>myHero.x then
								tx = target.x-600
							else
								tx = target.x+600
							end
						
						elseif target.x>myHero.x then
							angle = math.asin((target.x-myHero.x)/dist)
							zs = 600*math.cos(angle)
							xs = 600*math.sin(angle)
							if target.z>myHero.z then
								tx = target.x-xs
								tz = target.z-zs
							elseif target.z<myHero.z then
								tx = target.x-xs
								tz = target.z+zs
							end
						
						elseif target.x<myHero.x then
							angle = math.asin((myHero.x-target.x)/dist)
							zs = 600*math.cos(angle)
							xs = 600*math.sin(angle)
							if target.z>myHero.z then
								tx = target.x+xs
								tz = target.z-zs
							elseif target.z<myHero.z then
								tx = target.x+xs
								tz = target.z+zs
							end						
						end
					elseif runningAway(target) then	
						if target.x==myHero.x then
							tx = target.x
							if target.z>myHero.z then
								tz = target.z-500
							else
								tz = target.z+500
							end
						
						elseif target.z==myHero.z then
							tz = target.z
							if target.x>myHero.x then
								tx = target.x-500
							else
								tx = target.x+500
							end
						
						elseif target.x>myHero.x then
							angle = math.asin((target.x-myHero.x)/dist)
							zs = 500*math.cos(angle)
							xs = 500*math.sin(angle)
							if target.z>myHero.z then
								tx = target.x-xs
								tz = target.z-zs
							elseif target.z<myHero.z then
								tx = target.x-xs
								tz = target.z+zs
							end
						
						elseif target.x<myHero.x then
							angle = math.asin((myHero.x-target.x)/dist)
							zs = 500*math.cos(angle)
							xs = 500*math.sin(angle)
							if target.z>myHero.z then
								tx = target.x+xs
								tz = target.z-zs
							elseif target.z<myHero.z then
								tx = target.x+xs
								tz = target.z+zs
							end						
						end					
					
					end
					CastSpellXYZ('R',tx,0,tz)
					CastSpellTarget('Q',target)
				end
			end

		elseif RRDY==0 then
			if GetD(target,myHero)<650 then
				CastSpellTarget('Q',target)
				CastSpellXYZ('E',target.x,0,target.z)
			elseif GetD(target,myHero)>650 and QRDY==1 then
				CastSpellTarget('Q',target)
				if ERDY==1 then
					MoveToXYZ(target.x,0,target.z)
				end
			end			
		end
	else 
		MoveToMouse()
	end
	
end


function Teamfight()
	if target~=nil then
		if QRDY==1 and GetD(target)<650 then
			CastSpellTarget('Q',target)
		elseif ERDY==1 and GetD(target)<600 then
			 CastSpellXYZ('E',target.x,0,target.z)
		elseif RRDY==1 and GetD(target)<=700 then
			CastSpellXYZ('R',target.x,0,target.z) 
		elseif WRDY==1 and GetD(target)<250 then
			CastSpellTarget('W',myHero) 
			AttackTarget(target)
		else
			
			if GetD(target)<400 then
				UseAllItems(target)
			elseif GetD(target)<600 then
				UseTargetItems(target)
			end		
		AttackTarget(target)
		end
		
		if RRDY==1 and GetD(target)>700 then
		
			if targetclose~=nil then
				if RRDY==1 then CastSpellXYZ('R',targetclose.x,0,targetclose.z) end
				if QRDY==1 then CastSpellTarget('Q',targetclose) end
				if ERDY==1 and GetD(targetclose)<600 then
					  CastSpellXYZ('E',targetclose.x,0,targetclose.z)
				end
			end
		end
	else
		MoveToMouse()
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
	

function killsteal()
	if targetks~=nil and targetks.dead~=1 then
	
		local Q = getDmg("Q",targetks,myHero)*QRDY
		local E = getDmg("E",targetks,myHero)*ERDY
		local W = getDmg("W",targetks,myHero)*WRDY
		local R = getDmg("R",targetks,myHero)*RRDY
		local AA = getDmg("AD",targetks,myHero)
		
	
		if targetks.health<(Q+E+W+R+AA+ignitedamage)*RRDY and GetD(targetks)<720 then
			if RRDY==1 then CastSpellXYZ('R',targetks.x,0,targetks.z) end
			if QRDY==1 then CastSpellTarget('Q',targetks) end
			if ERDY==1 then CastSpellXYZ('E',targetks.x,0,targetks.z) end
			if WRDY==1 then CastSpellTarget('W',myHero) end
			AttackTarget(targetks)
			if ignitedamage~=0 then CastSummonerIgnite(targetks) end
		elseif targetkslongrange~=nil then
			local QQ = getDmg("Q",targetkslongrange,myHero)*QRDY
			local EE = getDmg("E",targetkslongrange,myHero)*ERDY
			local WW = getDmg("W",targetkslongrange,myHero)*WRDY
			local RR = getDmg("R",targetkslongrange,myHero)*RRDY
			local AAA = getDmg("AD",targetkslongrange,myHero)
			if targetkslongrange.health<(Q+E+ignitedamage)*RRDY and GetD(targetkslongrange)<1300 then
				local tx,tz
				if ERDY==1 then
					if GetD(targetkslongrange,myHero)<1200 then
				
						dist=GetD(targetkslongrange,myHero)
						
						if not runningAway(targetkslongrange) then
							if targetkslongrange.x==myHero.x then
								tx = targetkslongrange.x
								if targetkslongrange.z>myHero.z then
									tz = targetkslongrange.z-600
								else
									tz = targetkslongrange.z+600
								end
							
							elseif targetkslongrange.z==myHero.z then
								tz = targetkslongrange.z
								if targetkslongrange.x>myHero.x then
									tx = targetkslongrange.x-600
								else
									tx = targetkslongrange.x+600
								end
							
							elseif targetkslongrange.x>myHero.x then
								angle = math.asin((targetkslongrange.x-myHero.x)/dist)
								zs = 600*math.cos(angle)
								xs = 600*math.sin(angle)
								if targetkslongrange.z>myHero.z then
									tx = targetkslongrange.x-xs
									tz = targetkslongrange.z-zs
								elseif targetkslongrange.z<myHero.z then
									tx = targetkslongrange.x-xs
									tz = targetkslongrange.z+zs
								end
							
							elseif targetkslongrange.x<myHero.x then
								angle = math.asin((myHero.x-targetkslongrange.x)/dist)
								zs = 600*math.cos(angle)
								xs = 600*math.sin(angle)
								if targetkslongrange.z>myHero.z then
									tx = targetkslongrange.x+xs
									tz = targetkslongrange.z-zs
								elseif targetkslongrange.z<myHero.z then
									tx = targetkslongrange.x+xs
									tz = targetkslongrange.z+zs
								end						
							end
						elseif runningAway(targetkslongrange) then	
							if targetkslongrange.x==myHero.x then
								tx = targetkslongrange.x
								if targetkslongrange.z>myHero.z then
									tz = targetkslongrange.z-500
								else
									tz = targetkslongrange.z+500
								end
							
							elseif targetkslongrange.z==myHero.z then
								tz = targetkslongrange.z
								if targetkslongrange.x>myHero.x then
									tx = targetkslongrange.x-500
								else
									tx = targetkslongrange.x+500
								end
							
							elseif targetkslongrange.x>myHero.x then
								angle = math.asin((targetkslongrange.x-myHero.x)/dist)
								zs = 500*math.cos(angle)
								xs = 500*math.sin(angle)
								if targetkslongrange.z>myHero.z then
									tx = targetkslongrange.x-xs
									tz = targetkslongrange.z-zs
								elseif targetkslongrange.z<myHero.z then
									tx = targetkslongrange.x-xs
									tz = targetkslongrange.z+zs
								end
							
							elseif targetkslongrange.x<myHero.x then
								angle = math.asin((myHero.x-targetkslongrange.x)/dist)
								zs = 500*math.cos(angle)
								xs = 500*math.sin(angle)
								if targetkslongrange.z>myHero.z then
									tx = targetkslongrange.x+xs
									tz = targetkslongrange.z-zs
								elseif targetkslongrange.z<myHero.z then
									tx = targetkslongrange.x+xs
									tz = targetkslongrange.z+zs
								end						
							end					
						
						end
						CastSpellXYZ('R',tx,0,tz)
					end
					
				elseif ERDY==0 and QRDY==1 then
					if GetD(targetkslongrange,myHero)<1200 then
					
						dist=GetD(targetkslongrange,myHero)
						
						if not runningAway(targetkslongrange) then
							if targetkslongrange.x==myHero.x then
								tx = targetkslongrange.x
								if targetkslongrange.z>myHero.z then
									tz = targetkslongrange.z-600
								else
									tz = targetkslongrange.z+600
								end
							
							elseif targetkslongrange.z==myHero.z then
								tz = targetkslongrange.z
								if targetkslongrange.x>myHero.x then
									tx = targetkslongrange.x-600
								else
									tx = targetkslongrange.x+600
								end
							
							elseif targetkslongrange.x>myHero.x then
								angle = math.asin((targetkslongrange.x-myHero.x)/dist)
								zs = 600*math.cos(angle)
								xs = 600*math.sin(angle)
								if targetkslongrange.z>myHero.z then
									tx = targetkslongrange.x-xs
									tz = targetkslongrange.z-zs
								elseif targetkslongrange.z<myHero.z then
									tx = targetkslongrange.x-xs
									tz = targetkslongrange.z+zs
								end
							
							elseif targetkslongrange.x<myHero.x then
								angle = math.asin((myHero.x-targetkslongrange.x)/dist)
								zs = 600*math.cos(angle)
								xs = 600*math.sin(angle)
								if targetkslongrange.z>myHero.z then
									tx = targetkslongrange.x+xs
									tz = targetkslongrange.z-zs
								elseif targetkslongrange.z<myHero.z then
									tx = targetkslongrange.x+xs
									tz = targetkslongrange.z+zs
								end						
							end
						elseif runningAway(targetkslongrange) then	
							if targetkslongrange.x==myHero.x then
								tx = targetkslongrange.x
								if targetkslongrange.z>myHero.z then
									tz = targetkslongrange.z-500
								else
									tz = targetkslongrange.z+500
								end
							
							elseif targetkslongrange.z==myHero.z then
								tz = targetkslongrange.z
								if targetkslongrange.x>myHero.x then
									tx = targetkslongrange.x-500
								else
									tx = targetkslongrange.x+500
								end
							
							elseif targetkslongrange.x>myHero.x then
								angle = math.asin((targetkslongrange.x-myHero.x)/dist)
								zs = 500*math.cos(angle)
								xs = 500*math.sin(angle)
								if targetkslongrange.z>myHero.z then
									tx = targetkslongrange.x-xs
									tz = targetkslongrange.z-zs
								elseif targetkslongrange.z<myHero.z then
									tx = targetkslongrange.x-xs
									tz = targetkslongrange.z+zs
								end
							
							elseif targetkslongrange.x<myHero.x then
								angle = math.asin((myHero.x-targetkslongrange.x)/dist)
								zs = 500*math.cos(angle)
								xs = 500*math.sin(angle)
								if targetkslongrange.z>myHero.z then
									tx = targetkslongrange.x+xs
									tz = targetkslongrange.z-zs
								elseif targetkslongrange.z<myHero.z then
									tx = targetkslongrange.x+xs
									tz = targetkslongrange.z+zs
								end						
							end					
						
						end
					CastSpellXYZ('R',tx,0,tz)
					end
				end
			end
		end
		
		if targetks.health<Q+E+ignitedamage and GetD(targetks)<600 then
			if QRDY==1 then CastSpellTarget('Q',targetks) end
			if ERDY==1 then CastSpellXYZ('E',targetks.x,0,targetks.z) end
			if ignitedamage~=0 then CastSummonerIgnite(targetks) end
		end
		if targetks.health<Q+E+ignitedamage+AA and GetD(targetks)<250 then
			if QRDY==1 then CastSpellTarget('Q',targetks) end
			if ERDY==1 then CastSpellXYZ('E',targetks.x,0,targetks.z) end
			if ignitedamage~=0 then CastSummonerIgnite(targetks) end
			AttackTarget(targetks)
		end
		
	elseif targetkslongrange~=nil then
		local Q = getDmg("Q",targetkslongrange,myHero)*QRDY
		local E = getDmg("E",targetkslongrange,myHero)*ERDY
		local W = getDmg("W",targetkslongrange,myHero)*WRDY
		local R = getDmg("R",targetkslongrange,myHero)*RRDY
		local AA = getDmg("AD",targetkslongrange,myHero)
		local tx,tz
			if targetkslongrange.health<(Q+E+ignitedamage)*RRDY and GetD(targetkslongrange)<1300 then
				if ERDY==1 then
				if GetD(targetkslongrange,myHero)<1200 then
				
					dist=GetD(targetkslongrange,myHero)
					
					if not runningAway(targetkslongrange) then
						if targetkslongrange.x==myHero.x then
							tx = targetkslongrange.x
							if targetkslongrange.z>myHero.z then
								tz = targetkslongrange.z-600
							else
								tz = targetkslongrange.z+600
							end
						
						elseif targetkslongrange.z==myHero.z then
							tz = targetkslongrange.z
							if targetkslongrange.x>myHero.x then
								tx = targetkslongrange.x-600
							else
								tx = targetkslongrange.x+600
							end
						
						elseif targetkslongrange.x>myHero.x then
							angle = math.asin((targetkslongrange.x-myHero.x)/dist)
							zs = 600*math.cos(angle)
							xs = 600*math.sin(angle)
							if targetkslongrange.z>myHero.z then
								tx = targetkslongrange.x-xs
								tz = targetkslongrange.z-zs
							elseif targetkslongrange.z<myHero.z then
								tx = targetkslongrange.x-xs
								tz = targetkslongrange.z+zs
							end
						
						elseif targetkslongrange.x<myHero.x then
							angle = math.asin((myHero.x-targetkslongrange.x)/dist)
							zs = 600*math.cos(angle)
							xs = 600*math.sin(angle)
							if targetkslongrange.z>myHero.z then
								tx = targetkslongrange.x+xs
								tz = targetkslongrange.z-zs
							elseif targetkslongrange.z<myHero.z then
								tx = targetkslongrange.x+xs
								tz = targetkslongrange.z+zs
							end						
						end
					elseif runningAway(targetkslongrange) then	
						if targetkslongrange.x==myHero.x then
							tx = targetkslongrange.x
							if targetkslongrange.z>myHero.z then
								tz = targetkslongrange.z-500
							else
								tz = targetkslongrange.z+500
							end
						
						elseif targetkslongrange.z==myHero.z then
							tz = targetkslongrange.z
							if targetkslongrange.x>myHero.x then
								tx = targetkslongrange.x-500
							else
								tx = targetkslongrange.x+500
							end
						
						elseif targetkslongrange.x>myHero.x then
							angle = math.asin((targetkslongrange.x-myHero.x)/dist)
							zs = 500*math.cos(angle)
							xs = 500*math.sin(angle)
							if targetkslongrange.z>myHero.z then
								tx = targetkslongrange.x-xs
								tz = targetkslongrange.z-zs
							elseif targetkslongrange.z<myHero.z then
								tx = targetkslongrange.x-xs
								tz = targetkslongrange.z+zs
							end
						
						elseif targetkslongrange.x<myHero.x then
							angle = math.asin((myHero.x-targetkslongrange.x)/dist)
							zs = 500*math.cos(angle)
							xs = 500*math.sin(angle)
							if targetkslongrange.z>myHero.z then
								tx = targetkslongrange.x+xs
								tz = targetkslongrange.z-zs
							elseif targetkslongrange.z<myHero.z then
								tx = targetkslongrange.x+xs
								tz = targetkslongrange.z+zs
							end						
						end					
					
					end
					CastSpellXYZ('R',tx,0,tz)
				end
				
			elseif ERDY==0 and QRDY==1 then
				if GetD(targetkslongrange,myHero)<1200 then
				
					dist=GetD(targetkslongrange,myHero)
					
					if not runningAway(targetkslongrange) then
						if targetkslongrange.x==myHero.x then
							tx = targetkslongrange.x
							if targetkslongrange.z>myHero.z then
								tz = targetkslongrange.z-600
							else
								tz = targetkslongrange.z+600
							end
						
						elseif targetkslongrange.z==myHero.z then
							tz = targetkslongrange.z
							if targetkslongrange.x>myHero.x then
								tx = targetkslongrange.x-600
							else
								tx = targetkslongrange.x+600
							end
						
						elseif targetkslongrange.x>myHero.x then
							angle = math.asin((targetkslongrange.x-myHero.x)/dist)
							zs = 600*math.cos(angle)
							xs = 600*math.sin(angle)
							if targetkslongrange.z>myHero.z then
								tx = targetkslongrange.x-xs
								tz = targetkslongrange.z-zs
							elseif targetkslongrange.z<myHero.z then
								tx = targetkslongrange.x-xs
								tz = targetkslongrange.z+zs
							end
						
						elseif targetkslongrange.x<myHero.x then
							angle = math.asin((myHero.x-targetkslongrange.x)/dist)
							zs = 600*math.cos(angle)
							xs = 600*math.sin(angle)
							if targetkslongrange.z>myHero.z then
								tx = targetkslongrange.x+xs
								tz = targetkslongrange.z-zs
							elseif targetkslongrange.z<myHero.z then
								tx = targetkslongrange.x+xs
								tz = targetkslongrange.z+zs
							end						
						end
					elseif runningAway(targetkslongrange) then	
						if targetkslongrange.x==myHero.x then
							tx = targetkslongrange.x
							if targetkslongrange.z>myHero.z then
								tz = targetkslongrange.z-500
							else
								tz = targetkslongrange.z+500
							end
						
						elseif targetkslongrange.z==myHero.z then
							tz = targetkslongrange.z
							if targetkslongrange.x>myHero.x then
								tx = targetkslongrange.x-500
							else
								tx = targetkslongrange.x+500
							end
						
						elseif targetkslongrange.x>myHero.x then
							angle = math.asin((targetkslongrange.x-myHero.x)/dist)
							zs = 500*math.cos(angle)
							xs = 500*math.sin(angle)
							if targetkslongrange.z>myHero.z then
								tx = targetkslongrange.x-xs
								tz = targetkslongrange.z-zs
							elseif targetkslongrange.z<myHero.z then
								tx = targetkslongrange.x-xs
								tz = targetkslongrange.z+zs
							end
						
						elseif targetkslongrange.x<myHero.x then
							angle = math.asin((myHero.x-targetkslongrange.x)/dist)
							zs = 500*math.cos(angle)
							xs = 500*math.sin(angle)
							if targetkslongrange.z>myHero.z then
								tx = targetkslongrange.x+xs
								tz = targetkslongrange.z-zs
							elseif targetkslongrange.z<myHero.z then
								tx = targetkslongrange.x+xs
								tz = targetkslongrange.z+zs
							end						
						end					
					
					end
					CastSpellXYZ('R',tx,0,tz)
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

function OnDraw()
		CustomCircle(655,8,3,myHero)
		if RRDY==1 and ERDY==1 then
			CustomCircle(1300,5,5,myHero)
		elseif RRDY==1 and ERDY==0 then
			CustomCircle(1350,5,5,myHero)			
		end
		
	if target~=nil then
		CustomCircle(100,4,2,target)
	end
end	
	

SetTimerCallback("Run")