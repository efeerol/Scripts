require "Utils"
require "spell_damage"
require 'winapi'
require 'SKeys'
local send = require 'SendInputScheduled'

local metakey = SKeys.Control
print("\nMalbert's")
print("\nPrivate LeeSin")
print("\nVersion 3.8")
local target
local targeti
local target2
local _registry = {}

local range = myHero.range + GetDistance(GetMinBBox(myHero))
local wards = {3340, 3350, 3154, 3361, 3361, 3362, 2044, 2043, 2045, 2049}
--[[
2043, Vision Ward
2044, Sight Ward
2045, Ruby Sightstone
2049, Sightstone
2050, Explorer's Ward (Removed)
3154, Wriggle's Lantern
3340, Warding Totem (60s/3 max) (lv 0)
3350, Greater Totem (120s/3 max) (lv 9)
3361, Greater Stealth Totem (180s/3 max) (lv 9+purchase)
3362, Graeter Vision Totem (--s/1 max) (lv 9+purchase)
]]--
local eye={unit=nil,x=nil,y=nil,z=nil}
	
	local success=false
	local wardsuccess=false
	local wardx
	local wardy
	local wardz
	local wardNear={}
	local lastWardJump=0
	local wardObject=nil
	local lastWardObject=nil
	local TI
	local startCombo=false
	local PMod=0
	local PTimer=0
	local startHarass=false
	local wardhx,wardhy,wardhz
	local something
	local enemies={}
	local enemyIndex=2
	local wardFound=false
	local TITimer=0
local www=nil
local wUsedAt = 0
local vUsedAt = 0
local timer=os.clock()
local bluePill = nil
local QRDY=0
local WRDY=0
local ERDY=0
local RRDY=0
local targetR=nil

	LeeConfig = scriptConfig("LeeSin", "LeeSin Hotkeys")
LeeConfig:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))--T
LeeConfig:addParam("initiate", "InSec Ult Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
LeeConfig:addParam("harass", "Harass Jump", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
LeeConfig:addParam("ward", "Ward Jump", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
LeeConfig:addParam("smite", "Smitesteal", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("7")) 
LeeConfig:addParam("ultLow", "Ult When Low", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("8")) 
LeeConfig:addParam("ultKS", "Ult KS", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("9")) 
LeeConfig:addParam("ultC", "Stylish Ult in Combo", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("0")) 
LeeConfig:addParam("PU", "Prioritize InSec", SCRIPT_PARAM_NUMERICUPDOWN, 1,189,1,objManager:GetMaxHeroes()/2+1,1)-- "-" objManager:GetMaxHeroes()/2+1
LeeConfig:addParam("iskey", "What to Insec To", SCRIPT_PARAM_DOMAINUPDOWN, 1, 187, {"Inventory Wards","Minions & Placed Wards","Both"})

LeeConfig:addParam('distanceR', "RA Distance", SCRIPT_PARAM_NUMERICUPDOWN, 350, 219,100,700,50)
LeeConfig:addParam('distanceNR', "NRA Distance", SCRIPT_PARAM_NUMERICUPDOWN, 450, 221,100,700,50)
LeeConfig:addParam('distanceNM', "NM Distance", SCRIPT_PARAM_NUMERICUPDOWN, 400, 191,100,700,50)
LeeConfig:addParam("wardH", "Harass Can Use Ward", SCRIPT_PARAM_ONOFF, false) 
LeeConfig:addParam("wardF", "Ward Farthest", SCRIPT_PARAM_ONOFF, true)
LeeConfig:addParam("mqi", "Manual Q Insec", SCRIPT_PARAM_ONOFF, true)
LeeConfig:addParam("pots", "Auto Potions", SCRIPT_PARAM_ONOFF, true)
LeeConfig:addParam("ignite", "Ignite KS", SCRIPT_PARAM_ONOFF, true)
LeeConfig:addParam("movement", "movement", SCRIPT_PARAM_ONOFF, true)
LeeConfig:addParam("circles", "Circles", SCRIPT_PARAM_ONOFF, true)
LeeConfig:permaShow("smite")
LeeConfig:permaShow("ultLow")
LeeConfig:permaShow("ultKS")
LeeConfig:permaShow("ultC")
LeeConfig:permaShow("ignite")
	
function LeeRun()

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


	target = GetWeakEnemy("PHYS", 975, "NEARMOUSE")
    target2 = GetWeakEnemy('TRUE',600)
	targetR = GetWeakEnemy('PHYS',400)
	
	for i=1, objManager:GetMaxHeroes(), 1 do
		hero = objManager:GetHero(i)
		if hero~=nil and hero.team~=myHero.team and hero.name~="" then
			if enemies[hero.name]==nil then
				enemies[hero.name]={unit=hero,number=enemyIndex}
				enemyIndex=enemyIndex+1
			end
		end
	end
		
	targeti =nil--GetWeakEnemy("PHYS", 975)
	if RRDY==1 then
		findtargeti()
    end

	www=nil
		for _, ward in pairs(wards) do
			if ward~=nil and GetWardSlot(ward) ~= nil and os.clock() > lastWardJump  then
				
				www=GetWardSlot(ward)
				--print("\nHere1 "..tostring(ward))
				break
				
			end
		end
		
	if LeeConfig.ultKS and targetR~=nil then
		local rdmg= getDmg('R',targetR,myHero)*RRDY
		local edmg = getDmg("E",targetR,myHero)*ERDY
		if targetR.health<rdmg and ((targetR.health>getDmg("AD",targetR,myHero)+edmg or GetD(targetR)>200 or myHero.health<myHero.maxHealth*0.20)) then
			CastSpellTarget('R',targetR)
		end
	end
	
    if IsChatOpen()==0 and LeeConfig.Combo then Combo() end    
    if IsChatOpen()==0 and LeeConfig.harass then Harass() end    
    if IsChatOpen()==0 and LeeConfig.initiate then initiate() end  
    if IsChatOpen()==0 and myHero.dead~=1 and LeeConfig.ward and LeeConfig.wardF then ward(mousePos.x,mousePos.y,mousePos.z) 
    elseif IsChatOpen()==0 and myHero.dead~=1 and LeeConfig.ward and LeeConfig.wardF==false then ward() end  
	if LeeConfig.mqi then 
		if (TI==nil or TI.dead==1 or TITimer<os.clock()) and eye~=nil and eye.x~=nil and myHero.SpellNameQ == "blindmonkqtwo" and targeti~=nil then
			local TIHolder=nil
			for i = 1, objManager:GetMaxHeroes()  do
            local enemy = objManager:GetHero(i)
				if enemy~=nil and enemy.team~=myHero.team and enemy.dead==0 and enemy.visible==1 and (TIHolder==nil or TIHolder.dead==1 or TIHolder.visible==0) and eye~=nil and GetD(enemy)<2000 then
					TIHolder=enemy
				elseif enemy~=nil and enemy.team~=myHero.team and enemy.dead==0 and enemy.visible==1 and TIHolder~=nil and TIHolder.dead==0 and TIHolder.visible==1 and eye~=nil and GetD(enemy,eye)<GetD(TIHolder,eye) then
					TIHolder=enemy				
				end
			end
			if TIHolder~=nil then 
				TI=TIHolder
				TITimer=os.clock()+5
				startCombo=false
				wardFound=false
				success=false
			end
		end
	end  
    if LeeConfig.smite then Smite() end
	if LeeConfig.ignite then ignite() end
	if LeeConfig.ultLow then ultSave() end
	if LeeConfig.pots then RedElixir() end
end

function findtargeti()
	if LeeConfig.PU==1 then
		for j=1, objManager:GetMaxHeroes(), 1 do
			herotarget = objManager:GetHero(j) 
			if herotarget~=nil and herotarget.team~=myHero.team and herotarget.dead~=1 and herotarget.visible==1 and herotarget.invulnerable==0 and (targeti==nil or targeti.dead==1) and GetD(herotarget)<975 then
				targeti=herotarget
			elseif herotarget~=nil and herotarget.team~=myHero.team and herotarget.dead~=1 and herotarget.visible==1 and herotarget.invulnerable==0 and GetD(herotarget)<975 and herotarget.addDamage+herotarget.baseDamage>targeti.addDamage+targeti.baseDamage then
				targeti=herotarget
			end
		end
	elseif LeeConfig.PU>1 then
		
		for i, enemy in pairs(enemies) do
			if enemy~=nil and enemy.unit~=nil and enemy.unit.dead~=1 and enemy.unit.invulnerable==0 and enemy.unit.visible==1 and enemy.unit.x~=nil and enemy.number==LeeConfig.PU and myHero.dead~=1 and GetD(enemy.unit)<975 then
				targeti=enemy.unit
			end
		end
	end
end

function ignite()
	local damage = (myHero.selflevel*20)+50
	if target2 ~= nil then
		if myHero.SummonerD == "SummonerDot" then
			if target2.health < damage then
				CastSpellTarget("D",target2)
			end
		end
		if myHero.SummonerF == "SummonerDot" then
			if target2.health < damage then
				CastSpellTarget("F",target2)
			end
		end
	end
end

function Combo()
    if target ~= nil then
        CustomCircle(100,4,1,target)
		
        if myHero.SpellNameQ == "BlindMonkQOne" and QRDY==1 and CreepBlock(target.x,target.y,target.z) == 0 and (PMod>2 or PTimer<os.clock()) then 
			CastSpellXYZ('Q',GetFireahead(target,2.4,16)) 
			--printtext("\nQ1") 
		elseif myHero.SpellNameQ == "blindmonkqtwo" and RRDY==1 and LeeConfig.ultC and GetD(target)<400 and eye~=nil and eye.unit~=nil and eye.unit.x~=nil and GetD(eye.unit,target)<100 then 
			CastSpellTarget("R",target) --printtext("\nR") 
		elseif myHero.SpellNameQ == "blindmonkqtwo" and QRDY==1 and (PMod>2 or PTimer<os.clock() or GetD(target) > 350 or LeeConfig.ultC) and eye~=nil and eye.unit~=nil and eye.unit.x~=nil and GetD(eye.unit,target)<50 then 
			CastSpellTarget("Q",target)  
		end
        if ERDY==1 and myHero.SpellNameE == "BlindMonkEOne" and GetD(target) < 380 and (PMod>2 or PTimer<os.clock() or GetD(target) > 350-35) then 
			CastSpellXYZ('E',myHero.x,myHero.y,myHero.z) --printtext("\nE") 
		elseif ERDY==1 and myHero.SpellNameE == "blindmonketwo" and (PMod>2 or PTimer<os.clock() or GetD(target) > 350 ) then 
			CastSpellXYZ('E',myHero.x,myHero.y,myHero.z) --printtext("\nE") 
		elseif myHero.SpellNameW == "BlindMonkWOne" and WRDY==1 and GetD(target) < 350 and (PMod>2 or PTimer<os.clock()) then 
			run_every(0.2,WSpell,myHero)  
		end
		if myHero.SpellNameW == "blindmonkwtwo" and WRDY==1 and GetD(target) < 350 and (PMod>2  or PTimer<os.clock()) then 
			run_every(0.2,WSpell,myHero)  
		end
		if RRDY==1 then
			local rdmg = getDmg("R",target,myHero)*RRDY
			local edmg = getDmg("E",target,myHero)*ERDY
			if GetD(target)<400 and target.health<rdmg and (target.health>getDmg("AD",target,myHero)+edmg or myHero.health<myHero.maxHealth*0.20) and LeeConfig.ultKS then
				CastSpellTarget('R',target)
			end
		end
        if IsAttackReady() then 
			AttackTarget(target) 
		elseif LeeConfig.movement then
			local xx,yy,zz=GetFireahead(target,2,0)
			MoveToXYZ(xx,yy,zz)
		end
		if GetD(target)<400 then
			CastSummonerExhaust(target)
			UseAllItems(target)
		elseif GetD(target)<600 then
			CastSummonerExhaust(target)
			UseTargetItems(target)
		end
		
	else
		MoveToMouse()
    end
end
function WSpell(tt)
CastSpellTarget('W',tt)
end

function ultSave()
	if RRDY==1 and myHero.health<myHero.maxHealth*0.20 then
		local kicktarget=nil
		for j=1, objManager:GetMaxHeroes(), 1 do
			herotarget = objManager:GetHero(j) 
			if herotarget~=nil and herotarget.team~=myHero.team and GetD(herotarget)<400 and (kicktarget==nil or kicktarget.dead==1) then
				kicktarget=herotarget
			elseif herotarget~=nil and herotarget.team~=myHero.team and GetD(herotarget)<400 and GetD(herotarget)<GetD(kicktarget) then
				kicktarget=herotarget
			end
		end
		if kicktarget~=nil then
			CastSpellTarget('R',kicktarget)
		end
	end
end

function ward(hx,hy,hz)
	if hx~=nil and hy~=nil and hz~=nil then
		
				--print("\nHere38 "..tostring(WRDY).." "..myHero.SpellNameW.. " "..lastWardJump.." "..os.clock())
		if WRDY==1 and myHero.SpellNameW=="BlindMonkWOne" and os.clock() > lastWardJump then
			
				--print("\nHere39")
			wardsuccess=false
			--wx,wy,wz=GetFireahead(myHero,5,0)
			
			if www~=nil and os.clock() > lastWardJump then
				--print("\nHere40")
				local wx,wy,wz=getWardSpot(hx,hy,hz)
				CastSpellXYZ(www,wx,wy,wz,0)
				lastWardJump=os.clock()+3
				wardsuccess=true
			end	
		end
		
		if WRDY==1 and myHero.SpellNameW=="BlindMonkWOne" and wardsuccess==true and lastWardObject~=nil and GetD(lastWardObject)<700 then
			run_every(0.2,WSpell, lastWardObject)
		
		end

                if ( WRDY==0 or myHero.SpellNameW=="blindmonkwtwo" or not gotAWard()) then
                        MoveToMouse()
                end
	else
				--print("\nHere41")
		if WRDY==1 and myHero.SpellNameW=="BlindMonkWOne" and os.clock() > lastWardJump then
			
				--print("\nHere42")
			wardsuccess=false
			--wx,wy,wz=GetFireahead(myHero,5,0)
			if www~=nil and os.clock() > lastWardJump then
				--print("\nHere43")
				CastSpellXYZ(www, mousePos.x,mousePos.y,mousePos.z,0)
				lastWardJump=os.clock()+3
				wardsuccess=true
			end	
			
		end
		
		if WRDY==1 and myHero.SpellNameW=="BlindMonkWOne" and wardsuccess==true and lastWardObject~=nil and GetD(lastWardObject)<700 then
			run_every(0.2,WSpell, lastWardObject)
		
		end
		if ( WRDY==0 or myHero.SpellNameW=="blindmonkwtwo" or not gotAWard()) then
			MoveToMouse()
		end
	end
end

function Harass()
	if target~=nil and WRDY==1 then
		if myHero.SpellNameQ == "BlindMonkQOne" and QRDY==1 and (somethingNear(target)~=nil or gotAWard()) then
			startHarass=false
			CastSpellXYZ('Q',GetFireahead(target,2.4,16))
		end
		if myHero.SpellNameQ == "blindmonkqtwo" and QRDY==1 and WRDY==1 and myHero.SpellNameW=="BlindMonkWOne" and eye~=nil and eye.unit~=nil and eye.unit.x~=nil then
			if GetD(eye.unit,target)<50 and somethingNear(target)~=nil then
				something=somethingNear(target)
				startHarass=true
				--
				CastSpellTarget('Q',myHero)
			elseif GetD(eye.unit,target)<50 and LeeConfig.wardH and gotAWard() then
				wardhx,wardhy,wardhz=getWardHarassSpot()
				startHarass=true
				--CastSpellTarget('E',myHero)
				CastSpellTarget('Q',myHero)
			end
		end
		if startHarass==true and  QRDY==0 and WRDY==1 and myHero.SpellNameW=="BlindMonkWOne" and something~=nil and something.dead~=1 then
			if ERDY==1 then CastSpellTarget('E',myHero) end
			run_every(0.2,WSpell, something)
		elseif startHarass==true and  QRDY==0 and WRDY==1 and myHero.SpellNameW=="BlindMonkWOne" and (LeeConfig.wardH and gotAWard()) then
			ward(wardhx,wardhy,wardhz)
			if ERDY==1 then CastSpellTarget('E',myHero) end
			if WRDY==1 and myHero.SpellNameW=="BlindMonkWOne" and wardsuccess==true and lastWardObject~=nil and GetD(lastWardObject)<700 then
				run_every(0.2,WSpell, lastWardObject)
			end
		end
		
	else
		something=nil
		MoveToMouse()
	end
end

function getWardHarassSpot()
	if QRDY==1 then
		local dist=GetD(target,myHero)
			if target.x==myHero.x then
					tx = target.x
					if target.z>myHero.z then
							tz = target.z-450
					else
							tz = target.z+(450)
					end
		   
			elseif target.z==myHero.z then
					tz = target.z
					if target.x>myHero.x then
							tx = target.x-(450)
					else
							tx = target.x+(450)
					end
		   
			elseif target.x>myHero.x then
					angle = math.asin((target.x-myHero.x)/dist)
					zs = (450)*math.cos(angle)
					xs = (450)*math.sin(angle)
					if target.z>myHero.z then
							tx = target.x-xs
							tz = target.z-zs
					elseif target.z<myHero.z then
							tx = target.x-xs
							tz = target.z+zs
					end
		   
			elseif target.x<myHero.x then
					angle = math.asin((myHero.x-target.x)/dist)
					zs = (450)*math.cos(angle)
					xs = (450)*math.sin(angle)
					if target.z>myHero.z then
							tx = target.x+xs
							tz = target.z-zs
					elseif target.z<myHero.z then
							tx = target.x+xs
							tz = target.z+zs
					end 
			end
		return tx,target.y,tz
	end
end

function getWardSpot(a,b,c)
	--print("\n
				--print("\nHere37")
		local spot={x=a,y=b,z=c}
		local dist=GetD(spot,myHero)
			if myHero.x==spot.x then
					tx = myHero.x
					if myHero.z>spot.z then
							tz = myHero.z-590
					else
							tz = myHero.z+(590)
					end
		   
			elseif spot.z==myHero.z then
					tz = myHero.z
					if myHero.x>spot.x then
							tx = myHero.x-(590)
					else
							tx = myHero.x+(590)
					end
		   
			elseif myHero.x>spot.x then
					angle = math.asin((myHero.x-spot.x)/dist)
					zs = (590)*math.cos(angle)
					xs = (590)*math.sin(angle)
					if myHero.z>spot.z then
							tx = myHero.x-xs
							tz = myHero.z-zs
					elseif myHero.z<spot.z then
							tx = myHero.x-xs
							tz = myHero.z+zs
					end
		   
			elseif myHero.x<spot.x then
					angle = math.asin((spot.x-myHero.x)/dist)
					zs = (590)*math.cos(angle)
					xs = (590)*math.sin(angle)
					if myHero.z>spot.z then
							tx = myHero.x+xs
							tz = myHero.z-zs
					elseif myHero.z<spot.z then
							tx = myHero.x+xs
							tz = myHero.z+zs
					end 
			end
		return tx,spot.y,tz
	end

function somethingNear(enemy)
	local rturn=nil
	if WRDY==1 and myHero.SpellNameW == "BlindMonkWOne" then
	if enemy~=nil then
		for i=1, objManager:GetMaxObjects(), 1 do
			local object = objManager:GetObject(i)
			if object~=nil and object.x~=nil and object.dead~=1 and object.visible==1 and object.invulnerable==0 and (rturn==nil or (rturn.dead~=nil and rturn.dead==1)) and ((string.find(object.charName,"inion") and object.team==myHero.team) or string.find(object.charName,"SightWard") or string.find(object.charName,"VisionWard")) and GetD(object,enemy)<650 and GetD(object)<GetD(enemy) and nearAngle(enemy,object) then
				rturn=object
			elseif object~=nil and object.x~=nil and object.dead~=1 and object.visible==1 and object.invulnerable==0 and rturn~=nil and rturn.x~=nil and ((string.find(object.charName,"inion") and object.team==myHero.team) or string.find(object.charName,"SightWard") or string.find(object.charName,"VisionWard")) and GetD(object,enemy)<650 and GetD(object)<GetD(enemy) and nearAngle(enemy,object) and GetD(rturn)>GetD(object) then
				rturn=object
			end
		end
		
	end
	end
		return rturn
end

function initiate()
	if (targeti~=nil or TI~=nil) and RRDY==1 then
		if myHero.SpellNameQ == "BlindMonkQOne" and QRDY==1 and targeti~=nil and CreepBlock(targeti.x, targeti.y, targeti.z) == 0 then --and CreepBlock(targeti.x,targeti.y,targeti.z) == 0 then
			TI=targeti
			startCombo=false
			wardFound=false
			success=false
			CastSpellXYZ('Q',GetFireahead(targeti,2.4,16))
			--CastSpellXYZ('Q',GetFireahead(targeti,1.6,18)) 
			--CastSpellXYZ('Q',mousePos.x,mousePos.y,mousePos.z) 
			--print("\nQ1") 
			TITimer=os.clock()+5
		end
		if TI~=nil and TI.x~=nil and myHero.SpellNameQ == "blindmonkqtwo" and QRDY==1 and startCombo==false and eye~=nil and eye.unit~=nil and eye.unit.x~=nil then
			--print("\nQ2") 
			if GetD(eye.unit,TI)<225 then
			--print("\nQ3") 
				if LeeConfig.iskey>1 and findWard()~=nil then
				--print("\nQ4") 
					success=true
					startCombo=false
					wardObject=findWard()
					lastWardJump = os.clock()+5
					wardFound=true
					CastSpellTarget('Q',myHero)
				elseif (LeeConfig.iskey==1 or LeeConfig.iskey==3) and gotAWard() then
					--print("\nQ5") 
					startCombo=true
					CastSpellTarget('Q',myHero)
				end
			end
		end
		if startCombo==true and wardz==nil and TI~=nil and GetD(TI)<250 and QRDY==0 then
		--print("\nQ6")
			inSec(TI)
		elseif WRDY==1 and myHero.SpellNameW=="BlindMonkWOne" and QRDY==0 and os.clock() > lastWardJump and startCombo==true and wardz~=nil and TI~=nil and TI.x~=nil then						
			--print("\nQ9")
			if www~=nil then
				--print("\nQ10")
				CastSpellXYZ(www, wardx,wardy,wardz,0)
				success=true
				wardFound=true
				lastWardJump=os.clock()+5
				wardx=nil
				wardy=nil
				wardz=nil
				startCombo=false
			end	
			--if wardFound==false then
				--findWard()
			--end
		end
		if WRDY==1 and myHero.SpellNameW=="BlindMonkWOne" and QRDY==0 and success==true and lastWardJump>os.clock() and wardObject~=nil and GetD(wardObject)<600 then
			run_every(0.2,WSpell, wardObject)
		end
		if TI~=nil and TI.x~=nil and RRDY==1 and (myHero.SpellNameW=="blindmonkwtwo" or WRDY==0) then
			CastSpellTarget('R',TI)
		--elseif  RRDY==0 then
			--success=false
		end
	else
		MoveToMouse()
	end
end

function findWard()
--print("\nQ7")
		local wO=nil
	if TI~=nil and TI.x~=nil then
		local check=false
		for i=1, objManager:GetMaxObjects(), 1 do
			local object = objManager:GetObject(i)
			if object~=nil and object.x~=nil and object.dead~=1 and object.visible==1 and object.invulnerable==0 and (wO==nil or (wO.dead~=nil and wO.dead==1)) and object.team==myHero.team and ((string.find(object.charName,"inion")) or string.find(object.charName,"SightWard") or string.find(object.charName,"VisionWard")) and TI~=nil and TI.x~=nil and ((GetD(object,TI)>0.15*TI.movespeed and not runningAway(TI) and isMoving(TI))  or (GetD(object,TI)>0.4*TI.movespeed and not isMoving(TI)) or (GetD(object,TI)>1.5*TI.movespeed and runningAway(TI) and isMoving(TI))) and GetD(object,TI)<600 and GetD(TI)<GetD(object) and nearAngle(TI,object) then
				wO=object
			elseif object~=nil and object.x~=nil and object.dead~=1 and object.visible==1 and object.invulnerable==0 and wO~=nil and wO.x~=nil and object.team==myHero.team and ((string.find(object.charName,"inion")) or string.find(object.charName,"SightWard") or string.find(object.charName,"VisionWard")) and TI~=nil and TI.x~=nil and ((GetD(object,TI)>0.15*TI.movespeed and not runningAway(TI) and isMoving(TI))  or (GetD(object,TI)>0.4*TI.movespeed and not isMoving(TI)) or (GetD(object,TI)>1.5*TI.movespeed and runningAway(TI) and isMoving(TI))) and GetD(object,TI)<600 and GetD(TI)<GetD(object) and nearAngle(TI,object) and GetD(wO,TI)>GetD(object,TI) then
				wO=object
			end
		end
	end
	return wO
end

function inSec(enemy)
	if WRDY==1 then
	--print("\nQ8")
		if enemy~=nil then
			local RDIST=LeeConfig.distanceR*340/enemy.movespeed
			local NRDIST=LeeConfig.distanceNR*enemy.movespeed/340
			local NMDIST=LeeConfig.distanceNM
			local angle
			local dist=GetD(enemy,myHero)
			local tx,tz
			if not isMoving(enemy) then
				if enemy.x==myHero.x then
					tx = enemy.x
					if enemy.z>myHero.z then
						tz = enemy.z+NMDIST
					else
						tz = enemy.z-NMDIST
					end
				
				elseif enemy.z==myHero.z then
					tz = enemy.z
					if enemy.x>myHero.x then
						tx = enemy.x+NMDIST
					else
						tx = enemy.x-NMDIST
					end
				
				elseif enemy.x>myHero.x then
					angle = math.asin((enemy.x-myHero.x)/dist)
					zs = NRDIST*math.cos(angle)
					xs = NRDIST*math.sin(angle)
					if enemy.z>myHero.z then
						tx = enemy.x+xs
						tz = enemy.z+zs
					elseif enemy.z<myHero.z then
						tx = enemy.x+xs
						tz = enemy.z-zs
					end
				
				elseif enemy.x<myHero.x then
					angle = math.asin((myHero.x-enemy.x)/dist)
					zs = NRDIST*math.cos(angle)
					xs = NRDIST*math.sin(angle)
					if enemy.z>myHero.z then
						tx = enemy.x-xs
						tz = enemy.z+zs
					elseif enemy.z<myHero.z then
						tx = enemy.x-xs
						tz = enemy.z-zs
					end						
				end
			elseif not runningAway(enemy) then
				if enemy.x==myHero.x then
					tx = enemy.x
					if enemy.z>myHero.z then
						tz = enemy.z+NRDIST
					else
						tz = enemy.z-NRDIST
					end
				
				elseif enemy.z==myHero.z then
					tz = enemy.z
					if enemy.x>myHero.x then
						tx = enemy.x+NRDIST
					else
						tx = enemy.x-NRDIST
					end
				
				elseif enemy.x>myHero.x then
					angle = math.asin((enemy.x-myHero.x)/dist)
					zs = NRDIST*math.cos(angle)
					xs = NRDIST*math.sin(angle)
					if enemy.z>myHero.z then
						tx = enemy.x+xs
						tz = enemy.z+zs
					elseif enemy.z<myHero.z then
						tx = enemy.x+xs
						tz = enemy.z-zs
					end
				
				elseif enemy.x<myHero.x then
					angle = math.asin((myHero.x-enemy.x)/dist)
					zs = NRDIST*math.cos(angle)
					xs = NRDIST*math.sin(angle)
					if enemy.z>myHero.z then
						tx = enemy.x-xs
						tz = enemy.z+zs
					elseif enemy.z<myHero.z then
						tx = enemy.x-xs
						tz = enemy.z-zs
					end						
				end
			elseif runningAway(enemy) then	
				if enemy.x==myHero.x then
					tx = enemy.x
					if enemy.z>myHero.z then
						tz = enemy.z+RDIST
					else
						tz = enemy.z-RDIST
					end
				
				elseif enemy.z==myHero.z then
					tz = enemy.z
					if enemy.x>myHero.x then
						tx = enemy.x+RDIST
					else
						tx = enemy.x-RDIST
					end
				
				elseif enemy.x>myHero.x then
					angle = math.asin((enemy.x-myHero.x)/dist)
					zs = RDIST*math.cos(angle)
					xs = RDIST*math.sin(angle)
					if enemy.z>myHero.z then
						tx = enemy.x+xs
						tz = enemy.z+zs
					elseif enemy.z<myHero.z then
						tx = enemy.x+xs
						tz = enemy.z-zs
					end
				
				elseif enemy.x<myHero.x then
					angle = math.asin((myHero.x-enemy.x)/dist)
					zs = RDIST*math.cos(angle)
					xs = RDIST*math.sin(angle)
					if enemy.z>myHero.z then
						tx = enemy.x-xs
						tz = enemy.z+zs
					elseif enemy.z<myHero.z then
						tx = enemy.x-xs
						tz = enemy.z-zs
					end						
				end					
			
			end
		
		wardx=tx
		wardy=enemy.y
		wardz=tz
		wardNear={x=wardx,y=wardy,z=wardz}
		end
	end
end

function gotAWard()

	if myHero.dead~=1 then
		for _, ward in pairs(wards) do
				if GetWardSlot(ward) ~= nil then
						return true
				end
			end
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

function Smite()
    if myHero.SummonerD == "SummonerSmite" then
        CastHotkey("AUTO 100,0 SPELLD:SMITESTEAL RANGE=700 TRUE COOLDOWN")
        return
    end
    if myHero.SummonerF == "SummonerSmite" then
        CastHotkey("AUTO 100,0 SPELLF:SMITESTEAL RANGE=700 TRUE COOLDOWN")
        return
    end
    
    for i=1, objManager:GetMaxObjects(), 1 do
        local object = objManager:GetObject(i)
        if object ~= nil and object.name ~= nil and (string.find(object.name,"Dragon") or string.find(object.name,"Worm")) then
            if GetD(object,myHero) < 1200 then
                local damage = 460+(30*myHero.selflevel)
                if object.health <= damage then
                    CustomCircle(100,10,7,object)
                end
            end
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

function OnCreateObj(obj)
	if GetD(obj)<600 then
	--print("\n obj "..obj.charName)
	end
	if string.find(obj.charName,"blindMonk_Q_tar_indicator") and myHero.SpellNameQ == "blindmonkqtwo" then
		eye.unit=obj
		eye.x=obj.x
		eye.y=obj.y
		eye.z=obj.z
	end
	
	if LeeConfig.initiate and GetD(obj)<800 and (string.find(obj.charName,"SightWard") or string.find(obj.charName,"VisionWard")) then
		wardObject=obj		
		lastWardJump = os.clock()+5
	elseif (LeeConfig.ward or LeeConfig.harass) and GetD(obj)<800 and (string.find(obj.charName,"SightWard") or string.find(obj.charName,"VisionWard")) then
		lastWardObject=obj
		lastWardJump = os.clock()+5
	end
	if (GetD(myHero, obj)) < 100 and LeeConfig.pots then
		if string.find(obj.charName,"FountainHeal") then
			timer=os.clock()
			bluePill = obj
		end
	end
end

function OnProcessSpell(unit,spell)
	if unit.charName==myHero.charName then
		--print("\nSP: "..spell.name)
		--if string.find(spell.name,"BlindMonkRKick") then
			--success=false

		if string.find(spell.name,"BlindMonkQ") and LeeConfig.Combo then
			PTimer=os.clock()+math.min(1.5,2/myHero.attackspeed)
			PMod=0
		elseif string.find(spell.name,"BlindMonkW") and LeeConfig.Combo then
			PTimer=os.clock()+math.min(1.5,2/myHero.attackspeed)
			PMod=0
		elseif string.find(spell.name,"BlindMonkE") and LeeConfig.Combo then
			PTimer=os.clock()+math.min(1.5,2/myHero.attackspeed)
			PMod=0
		elseif string.find(spell.name,"blindmonk") and LeeConfig.Combo then
			PTimer=os.clock()+math.min(1.5,2/myHero.attackspeed)
			PMod=0
		elseif string.find(spell.name,"ttack") and LeeConfig.Combo then
			PMod=PMod+1
		end
	end
end

function OnDraw()
	if myHero.dead~=1 then
    if LeeConfig.circles then
        CustomCircle(975,10,5,myHero) --Q    
        CustomCircle(375,10,5,myHero) --R
        CustomCircle(700,10,5,myHero) --W   
			if gotAWard() then
				CustomCircle(650,10,1,myHero)
			end
        if target ~= nil then
			CustomCircle(50,5,2,target) 
			
			if something~=nil and something.dead~=1 then 
				CustomCircle(100,20,4,something)
			elseif somethingNear(target)~=nil then
				CustomCircle(100,20,4,somethingNear(target))
			end
		end
        for i = 1, objManager:GetMaxHeroes()  do
            local enemy = objManager:GetHero(i)
            if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) then
                local qdmg = getDmg("Q",enemy,myHero,3)*QRDY
                local edmg = getDmg("E",enemy,myHero)*ERDY
                local rdmg = getDmg("R",enemy,myHero)*RRDY
                           
                             
                    if GetD(enemy) < 1600 then
                        if qdmg+rdmg+edmg > enemy.health then 
							CustomCircle(95,10,2,enemy)
							CustomCircle(100,10,5,enemy)
							CustomCircle(105,10,1,enemy)
						end
                        
                    end
                
            end
        end
		if TI~=nil and TI.x~=nil and GetD(TI)<1000 and RRDY==1 and LeeConfig.iskey==3 then
			if (nearWard() or gotAWard()) then
				CustomCircle(30,60,3,TI)
			end
		elseif TI~=nil and TI.x~=nil and GetD(TI)<1000 and RRDY==1 and LeeConfig.iskey==1 then
			if (gotAWard()) then
				CustomCircle(30,60,3,TI)
			end
		elseif TI~=nil and TI.x~=nil and GetD(TI)<1000 and RRDY==1 and LeeConfig.iskey==2 then
			if (nearWard()) then
				CustomCircle(30,60,3,TI)
			end		
		elseif targeti~=nil and RRDY==1 and LeeConfig.iskey==3 then
			if (nearWard() or gotAWard()) then
				CustomCircle(30,60,3,targeti)
			end
		elseif targeti~=nil and RRDY==1 and LeeConfig.iskey==1 then
			if (gotAWard()) then
				CustomCircle(30,60,3,targeti)
			end
		elseif targeti~=nil and RRDY==1 and LeeConfig.iskey==2 then
			if (nearWard()) then
				CustomCircle(30,60,3,targeti)
			end
		end
    end
		local positionText=(15/900)*GetScreenY()
			if LeeConfig.PU==1 then
				DrawText("Priority InSec: Highest AD", 1/16*GetScreenX(), positionText, Color.SkyBlue)
			elseif LeeConfig.PU~=1 then
				DrawText("Priority InSec: Highest AD", 1/16*GetScreenX(), positionText, Color.Orange)
			end
		for i, enemy in pairs(enemies) do
			if enemy~=nil and enemy.number == LeeConfig.PU then
				DrawText("Priority InSec: ".. enemy.unit.name .. "", 1/16*GetScreenX(), positionText*enemy.number, Color.SkyBlue)
		
			elseif enemy~=nil and enemy.number~=LeeConfig.PU then
				DrawText("Priority InSec: ".. enemy.unit.name .. "", 1/16*GetScreenX(), positionText*enemy.number, Color.Orange)
				
			end
		end
		
	end
end

function nearWard()
	local ok=false
	if targeti~=nil and targeti.x~=nil and myHero.dead~=1 and GetD(targeti)<1000 then
		local mt=wardObject

			if mt~=nil and mt.dead~=nil and mt.dead~=1 and TI~=nil and TI.dead~=nil and TI.dead~=1 and nearAngle(mt,TI) then
				CustomCircle(100,20,3,mt)
				ok=true
			elseif mt~=nil and mt.dead~=nil and mt.dead~=1 and nearAngle(mt,targeti) then
				CustomCircle(100,20,3,mt)
				ok=true
			end
	end
	
		if ok==true then
		return true
		else
		return false
		end
end


function nearAngle(unit1,unit2)
	if myHero.dead~=1 and unit1.z~=nil and unit2.z~=nil then
	local Theta=0
	local zz=unit1.z-myHero.z
	if unit1.x>=myHero.x then
		Theta=math.acos(zz/GetD(unit1))
	elseif unit1.x<myHero.x then
		Theta=-math.acos(zz/GetD(unit1))
	end
	
	local HTheta=0
	local Hzz=unit2.z-myHero.z
	if unit2.x>=myHero.x then
		HTheta=math.acos(Hzz/GetD(unit2))
	elseif unit2.x<myHero.x then
		HTheta=-math.acos(Hzz/GetD(unit2))
	end
	if HTheta>=Theta and HTheta-Theta<=2*math.pi/10 then
		return true
	elseif HTheta<Theta and Theta-HTheta<=2*math.pi/10 then
		return true
	end
	end
	return false
end
------------------------------------Pots

function RedElixir()
	if bluePill == nil then
		if myHero.health < 4/10*myHero.maxHealth and os.clock() > wUsedAt + 15 then
			usePotion()
			wUsedAt = os.clock()
		end
		if myHero.health < 0.5*myHero.maxHealth and os.clock() > vUsedAt + 10 then 
			useFlask()
			vUsedAt = os.clock()
		end
		if myHero.health < 3/10*myHero.maxHealth then
			useElixir()
		end
	end
	if (os.clock() < timer + 5) then
		bluePill = nil 
	end
end


function usePotion()
	GetInventorySlot(2003)
	UseItemOnTarget(2003,myHero)
end

function useFlask()
	GetInventorySlot(2041)
	UseItemOnTarget(2041,myHero)
end


function useElixir()
	GetInventorySlot(2037)
	UseItemOnTarget(2037,myHero)
end

function GetWardSlot(item)
    if GetInventoryItem(1) == item then
				--print("\nHere2")
                if item == 3154 or item == 3340 or item == 3350 or item == 3361 or item == 3362 then                       
					--print("\nHere3")
						if myHero.SpellTime1 >= 1 then 
							--print("\nHere4")
							return 1
                        else 
							--print("\nHere5")
							return nil end
                else
						--print("\nHere6")
                        return 1
                end
    elseif GetInventoryItem(2) == item then
				--print("\nHere7")
                if item == 3154 or item == 3340 or item == 3350 or item == 3361 or item == 3362 then
					--print("\nHere8")
                        if myHero.SpellTime2 >= 1 then 
							--print("\nHere9")
							return 2
                        else 
							--print("\nHere10")
							return nil end
                else
						--print("\nHere11")
                        return 2
                end
    elseif GetInventoryItem(3) == item then
				--print("\nHere12")
                if item == 3154 or item == 3340 or item == 3350 or item == 3361 or item == 3362 then
					--print("\nHere13")
                        if myHero.SpellTime3 >= 1 then 
							--print("\nHere14")
							return 3
                        else 
							--print("\nHere15")
							return nil end
                else
						--print("\nHere16")
                        return 3
                end
    elseif GetInventoryItem(4) == item then
				--print("\nHere17")
                if item == 3154 or item == 3340 or item == 3350 or item == 3361 or item == 3362 then
					--print("\nHere18")
                        if myHero.SpellTime4 >= 1 then 
							--print("\nHere19")
							return 4
                        else 
							--print("\nHere20")
							return nil end
                else
						--print("\nHere21")
                        return 4
                end
    elseif GetInventoryItem(5) == item then
				--print("\nHere22")
                if item == 3154 or item == 3340 or item == 3350 or item == 3361 or item == 3362 then
					--print("\nHere23")
                        if myHero.SpellTime5 >= 1 then 
							--print("\nHere24")
							return 5
                        else 
							--print("\nHere25")
							return nil end
                else
						--print("\nHere26")
                        return 5
                end
    elseif GetInventoryItem(6) == item then
				--print("\nHere27")
                if item == 3154 or item == 3340 or item == 3350 or item == 3361 or item == 3362 then
					--print("\nHere28")
                        if myHero.SpellTime6 >= 1 then 
							--print("\nHere29")
							return 6
                        else 
							--print("\nHere30")
							return nil end
                else
						--print("\nHere31")
                        return 6
                end
    elseif GetInventoryItem(7) == item then
				--print("\nHere32")
                if item == 3154 or item == 3340 or item == 3350 or item == 3361 or item == 3362 then
					--print("\nHere33")
                        if myHero.SpellTime7 >= 1 then 
							--print("\nHere34")
							return 7
                        else 
							--print("\nHere35")
							return nil end
                else
						--print("\nHere36")
                        return 7
                end
    end
    return nil
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
SetTimerCallback("LeeRun")