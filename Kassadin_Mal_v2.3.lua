require "Utils"
require 'spell_damage'
print=printtext
printtext("\nA-Void Me\n")
printtext("\nBy Malbert\n")
printtext("\nVersion 2.3\n")

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
local heros={}
local EStacks=0
local RiftWalk=0
local RiftTimer=0

KassConfig = scriptConfig("Kass", "Kass Config")
KassConfig:addParam("h", " Harass", SCRIPT_PARAM_ONKEYDOWN, false, 88)
KassConfig:addParam("r", " R Escape", SCRIPT_PARAM_ONKEYDOWN, false, 90)
KassConfig:addParam('teamfight', 'TeamFight', SCRIPT_PARAM_ONKEYDOWN, false, 84)
KassConfig:addParam('dokillsteal', 'Killsteal', SCRIPT_PARAM_ONKEYTOGGLE, true, 56)
KassConfig:addParam("mode", "Harass Mode", SCRIPT_PARAM_DOMAINUPDOWN, 1, 187, {"Use Ult","No Ult"})
KassConfig:addParam('distanceR', "RA Distance", SCRIPT_PARAM_NUMERICUPDOWN, 500, 57,100,700,50)
KassConfig:addParam('distanceNR', "NRA Distance", SCRIPT_PARAM_NUMERICUPDOWN, 700, 48,100,700,50)
KassConfig:addParam('distanceNM', "NM Distance", SCRIPT_PARAM_NUMERICUPDOWN, 650, 189,100,700,50)
KassConfig:addParam('ksnf', 'Killsteal Notifications', SCRIPT_PARAM_ONOFF, true)
KassConfig:addParam('rks', 'R KS ON/OFF', SCRIPT_PARAM_ONOFF, true)
KassConfig:addParam('nm', 'NearMouse Targetting', SCRIPT_PARAM_ONOFF, true)
KassConfig:permaShow('mode')
KassConfig:permaShow('dokillsteal')
KassConfig:permaShow('ksnf')
KassConfig:permaShow('rks')
KassConfig:permaShow('nm')
	
function Run()

	for i=1, objManager:GetMaxHeroes(), 1 do
		local hero = objManager:GetHero(i)
		if hero~=nil and enemies[hero.name]==nil then
			heros[hero.SpellNameQ]=hero
			heros[hero.SpellNameW]=hero
			heros[hero.SpellNameE]=hero
			heros[hero.SpellNameR]=hero
		end
	end
	
	if KassConfig.nm==true then
		target = GetWeakEnemy("MAGIC", 1400,"NEARMOUSE")
		targetclose = GetWeakEnemy("MAGIC", 700,"NEARMOUSE")
	else
		target = GetWeakEnemy("MAGIC", 1400)
		targetclose = GetWeakEnemy("MAGIC", 700)
	end
	
		targetkslongrange = GetWeakEnemy("MAGIC", 1400)
		targetks = GetWeakEnemy("MAGIC", 700)
		
	if RiftWalk>0 and RiftTimer<=os.clock() then
		RiftWalk=0
	end
		
	if myHero.SpellTimeQ > 1.0 and GetSpellLevel('Q') > 0 and myHero.mana>=65+5*(GetSpellLevel("Q")) then
			QRDY = 1
			else QRDY = 0
	end
	if myHero.SpellTimeW > 1.0 and GetSpellLevel('W') > 0 and myHero.mana>=25 then
			WRDY = 1
			else WRDY = 0
	end
	if myHero.SpellTimeE > 1.0 and GetSpellLevel('E') > 0 and EStacks==6 and myHero.mana>=80 then
			ERDY = 1
			else ERDY = 0
	end
	if myHero.SpellTimeR > 1.0 and GetSpellLevel('R') > 0 and myHero.mana>=100+100*(RiftWalk) then
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
	if IsChatOpen() == 0 and KassConfig.r then ultEsc() end
	if IsChatOpen() == 0 and KassConfig.teamfight then Teamfight() end
	if KassConfig.ksnf or KassConfig.dokillsteal then killsteal() end
	ignite()

	
end

function OnProcessSpell(unit,spell)

	
	
	if unit~=nil and unit.name==myHero.name and spell~=nil and string.find(spell.name,"ForcePulse") then
		EStacks=0
	elseif unit~=nil and heros[spell.name] and GetD(unit)<1750 then  
		EStacks=math.max(EStacks,(EStacks+1)%7)
	end
	
	if unit~=nil and unit.name==myHero.name and spell~=nil and string.find(spell.name,"RiftWalk") then
		RiftWalk=RiftWalk+1
		RiftTimer=os.clock()+8
	end

end

function ignite()
		if myHero.SummonerD == 'SummonerDot' and targetks~=nil and GetD(targetks)<600 then
			ignitedamage = ((myHero.selflevel*20)+50)*IsSpellReady('D')
		elseif myHero.SummonerF == 'SummonerDot' and targetks~=nil and GetD(targetks)<600 then
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

function GetUltSpot(enemy)
	if enemy~=nil and GetD(enemy)<1200 then
		local RDIST=KassConfig.distanceR*340/enemy.movespeed
		local NRDIST=KassConfig.distanceNR*enemy.movespeed/340
		local NMDIST=KassConfig.distanceNM
		local angle
		local dist=GetD(enemy,myHero)
		local tx,tz
		local t={}
		if not isMoving(enemy) then
			if enemy.x==myHero.x then
				tx = enemy.x
				if enemy.z>myHero.z then
					tz = enemy.z-NMDIST
				else
					tz = enemy.z+NMDIST
				end
			
			elseif enemy.z==myHero.z then
				tz = enemy.z
				if enemy.x>myHero.x then
					tx = enemy.x-NMDIST
				else
					tx = enemy.x+NMDIST
				end
			
			elseif enemy.x>myHero.x then
				angle = math.asin((enemy.x-myHero.x)/dist)
				zs = NRDIST*math.cos(angle)
				xs = NRDIST*math.sin(angle)
				if enemy.z>myHero.z then
					tx = enemy.x-xs
					tz = enemy.z-zs
				elseif enemy.z<myHero.z then
					tx = enemy.x-xs
					tz = enemy.z+zs
				end
			
			elseif enemy.x<myHero.x then
				angle = math.asin((myHero.x-enemy.x)/dist)
				zs = NRDIST*math.cos(angle)
				xs = NRDIST*math.sin(angle)
				if enemy.z>myHero.z then
					tx = enemy.x+xs
					tz = enemy.z-zs
				elseif enemy.z<myHero.z then
					tx = enemy.x+xs
					tz = enemy.z+zs
				end						
			end
		elseif not runningAway(enemy) then
			if enemy.x==myHero.x then
				tx = enemy.x
				if enemy.z>myHero.z then
					tz = enemy.z-NRDIST
				else
					tz = enemy.z+NRDIST
				end
			
			elseif enemy.z==myHero.z then
				tz = enemy.z
				if enemy.x>myHero.x then
					tx = enemy.x-NRDIST
				else
					tx = enemy.x+NRDIST
				end
			
			elseif enemy.x>myHero.x then
				angle = math.asin((enemy.x-myHero.x)/dist)
				zs = NRDIST*math.cos(angle)
				xs = NRDIST*math.sin(angle)
				if enemy.z>myHero.z then
					tx = enemy.x-xs
					tz = enemy.z-zs
				elseif enemy.z<myHero.z then
					tx = enemy.x-xs
					tz = enemy.z+zs
				end
			
			elseif enemy.x<myHero.x then
				angle = math.asin((myHero.x-enemy.x)/dist)
				zs = NRDIST*math.cos(angle)
				xs = NRDIST*math.sin(angle)
				if enemy.z>myHero.z then
					tx = enemy.x+xs
					tz = enemy.z-zs
				elseif enemy.z<myHero.z then
					tx = enemy.x+xs
					tz = enemy.z+zs
				end						
			end
		elseif runningAway(enemy) then	
			if enemy.x==myHero.x then
				tx = enemy.x
				if enemy.z>myHero.z then
					tz = enemy.z-RDIST
				else
					tz = enemy.z+RDIST
				end
			
			elseif enemy.z==myHero.z then
				tz = enemy.z
				if enemy.x>myHero.x then
					tx = enemy.x-RDIST
				else
					tx = enemy.x+RDIST
				end
			
			elseif enemy.x>myHero.x then
				angle = math.asin((enemy.x-myHero.x)/dist)
				zs = RDIST*math.cos(angle)
				xs = RDIST*math.sin(angle)
				if enemy.z>myHero.z then
					tx = enemy.x-xs
					tz = enemy.z-zs
				elseif enemy.z<myHero.z then
					tx = enemy.x-xs
					tz = enemy.z+zs
				end
			
			elseif enemy.x<myHero.x then
				angle = math.asin((myHero.x-enemy.x)/dist)
				zs = RDIST*math.cos(angle)
				xs = RDIST*math.sin(angle)
				if enemy.z>myHero.z then
					tx = enemy.x+xs
					tz = enemy.z-zs
				elseif enemy.z<myHero.z then
					tx = enemy.x+xs
					tz = enemy.z+zs
				end						
			end					
		
		end
		t={x=tx,y=0,z=tz}
		return t
	end
end

function harass()

	if target~=nil then
	--print("\n"..RDIST)
		--print("\n MS "..target.movespeed)
		if KassConfig.mode==1 and RRDY==1 then
		
			if ERDY==1 then
				if GetD(target,myHero)<700 then
					if QRDY==1 then
					CastSpellTarget('Q',target)
					end
					if ERDY==1 then
					CastSpellXYZ('E',target.x,0,target.z)
					end
					MoveToMouse()
				elseif GetD(target,myHero)<1200 then
				
					
					local t = GetUltSpot(target)
					CastSpellXYZ('R',t.x,0,t.z)
					if QRDY==1 then
					CastSpellTarget('Q',target)
					end
					if ERDY==1 and GetD(target,myHero)<700 then CastSpellXYZ('E',target.x,0,target.z) end
					MoveToMouse()
				end
				
			elseif ERDY==0 and QRDY==1 then
				if GetD(target,myHero)<700 then
					CastSpellTarget('Q',target)
					MoveToMouse()
				elseif GetD(target,myHero)<1200 then
				
					local t = GetUltSpot(target)
					CastSpellXYZ('R',t.x,0,t.z)
					CastSpellTarget('Q',target)
					MoveToMouse()
				end
			else 
				MoveToMouse()
			end

		elseif RRDY==0 or KassConfig.mode==2 then
			if GetD(target,myHero)<700 then
				if QRDY==1 then
					CastSpellTarget('Q',target)
				end
				if ERDY==1 then
					CastSpellXYZ('E',target.x,0,target.z)
				end
					MoveToMouse()
				
			elseif GetD(target,myHero)>=700 and QRDY==1 and GetD(target)<750 then
				CastSpellTarget('Q',target)
				if ERDY==1 then
					MoveToXYZ(target.x,0,target.z)
				else
					MoveToMouse()
				end
			else
				MoveToMouse()
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
		elseif ERDY==1 and GetD(target)<650 then
			 CastSpellXYZ('E',target.x,0,target.z)
		elseif RRDY==1 and GetD(target)<=700 then
			CastSpellXYZ('R',target.x,0,target.z) 
		elseif WRDY==1 and GetD(target)<275 then
			CastSpellTarget('W',myHero) 
			AttackTarget(target)
		end
		if GetD(target)<700 then
			
			if GetD(target)<400 then
				UseAllItems(target)
			elseif GetD(target)<600 then
				UseTargetItems(target)
			end		
			AttackTarget(target)
		elseif RRDY==0 and GetD(target)>=700 and targetclose==nil then
			MoveToMouse()
		elseif RRDY==1 and GetD(target)>=700 and targetclose~=nil then
			if RRDY==1 then CastSpellXYZ('R',targetclose.x,0,targetclose.z) end
			if QRDY==1 then CastSpellTarget('Q',targetclose) end
			if ERDY==1 and GetD(targetclose)<650 then
				  CastSpellXYZ('E',targetclose.x,0,targetclose.z)
			end
			MoveToMouse()
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

function isMoving(unitM)
        local mx,my,mz=GetFireahead(unitM,5,0)
        if math.abs(mx-unitM.x)<20 and math.abs(mz-unitM.z)<20 then
                return false
        else
                return true
        end
end
	

function killsteal()
	if targetks~=nil and targetks.dead~=1 then
	
		local Q = getDmg("Q",targetks,myHero)*QRDY
		local E = getDmg("E",targetks,myHero)*ERDY
		local W = getDmg("W",targetks,myHero)*WRDY
		local R = getDmg("R",targetks,myHero)*RRDY
		local AA = getDmg("AD",targetks,myHero)
		
		if targetks.health<(Q+E+W+R+AA+ignitedamage)*RRDY and GetD(targetks)<720 then
			if KassConfig.ksnf then 
				CustomCircle(200,50,3,targetks)
			end
			if KassConfig.dokillsteal and KassConfig.rks then
				if RRDY==1 then CastSpellXYZ('R',targetks.x,0,targetks.z) end
				if QRDY==1 then CastSpellTarget('Q',targetks) end
				if ERDY==1 then CastSpellXYZ('E',targetks.x,0,targetks.z) end
				if WRDY==1 then CastSpellTarget('W',myHero) end
				AttackTarget(targetks)
				if ignitedamage~=0 then CastSummonerIgnite(targetks) end
			end
		elseif targetks.health<(Q+E+W+R+AA+ignitedamage) and GetD(targetks)<280 then
			if KassConfig.ksnf then 
				CustomCircle(200,50,4,targetks)
			end
			if KassConfig.dokillsteal then
				if RRDY==1 then CastSpellXYZ('R',targetks.x,0,targetks.z) end
				if QRDY==1 then CastSpellTarget('Q',targetks) end
				if ERDY==1 then CastSpellXYZ('E',targetks.x,0,targetks.z) end
				if WRDY==1 then CastSpellTarget('W',myHero) end
				AttackTarget(targetks)
				if ignitedamage~=0 then CastSummonerIgnite(targetks) end
			end
		elseif targetkslongrange~=nil then
			local QQ = getDmg("Q",targetkslongrange,myHero)*QRDY
			local EE = getDmg("E",targetkslongrange,myHero)*ERDY
			local WW = getDmg("W",targetkslongrange,myHero)*WRDY
			local RR = getDmg("R",targetkslongrange,myHero)*RRDY
			local AAA = getDmg("AD",targetkslongrange,myHero)
			if targetkslongrange.health<(Q+E+ignitedamage)*RRDY and GetD(targetkslongrange)<1200 then
				if KassConfig.ksnf then 
					CustomCircle(200,50,3,targetkslongrange)
				end
				if KassConfig.dokillsteal and KassConfig.rks then
					if GetD(targetkslongrange,myHero)<1200 then
						local t = GetUltSpot(targetkslongrange)
						CastSpellXYZ('R',t.x,0,t.z)
					end
				end
			end
		end
		
		if targetks.health<Q+E+ignitedamage and GetD(targetks)<650 then
			if KassConfig.ksnf then 
				CustomCircle(200,50,4,targetks)
			end
			if KassConfig.dokillsteal then
				if QRDY==1 then CastSpellTarget('Q',targetks) end
				if ERDY==1 then CastSpellXYZ('E',targetks.x,0,targetks.z) end
				if ignitedamage~=0 then CastSummonerIgnite(targetks) end
			end
		end
		if targetks.health<Q+E+ignitedamage+AA and GetD(targetks)<280 then
			if KassConfig.ksnf then 
				CustomCircle(200,50,4,targetks)
			end
			if KassConfig.dokillsteal then
				if QRDY==1 then CastSpellTarget('Q',targetks) end
				if ERDY==1 then CastSpellXYZ('E',targetks.x,0,targetks.z) end
				if ignitedamage~=0 then CastSummonerIgnite(targetks) end
				if WRDY==1 then CastSpellTarget('W',myHero) end
				AttackTarget(targetks)
			end
		end
		
	elseif targetkslongrange~=nil and targetkslongrange.dead~=1 then
		local Q = getDmg("Q",targetkslongrange,myHero)*QRDY
		local E = getDmg("E",targetkslongrange,myHero)*ERDY
		local R = getDmg("R",targetkslongrange,myHero)*RRDY
		if targetkslongrange.health<(Q+E+ignitedamage)*RRDY and GetD(targetkslongrange)<1300 then
			if KassConfig.ksnf then 
				CustomCircle(200,50,3,targetkslongrange)
			end
			if KassConfig.dokillsteal and KassConfig.rks then
				local t = GetUltSpot(targetkslongrange)
				CastSpellXYZ('R',t.x,0,t.z)
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