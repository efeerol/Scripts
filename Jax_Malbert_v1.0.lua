require "Utils"
require 'spell_damage'

printtext("\nJaxing Off Everywhere\n")
printtext("\nBy Malbert\n")
printtext("\nVersion 1.0\n")

local target
local ESpinning=false
local QRDY=0
local WRDY=0
local ERDY=0
local RRDY=0
local RPASSIVE=0
local Rmod=0
local RmodReset=0
local ETimer=0

local attacks={}
attacks["JaxBasicAttack"]=true
attacks["JaxBasicAttack2"]=true
attacks["JaxBasicAttack3"]=true
attacks["jaxrelentlessattack"]=true
attacks["JaxCritAttack"]=true
local timetoAA=0
local AttackCompleted=0

local www=nil
local wardsuccess=false
local lastWardJump=0
local lastWardObject=nil
local wards = {3340, 3350, 3154, 3361, 3361, 3362, 2044, 2043, 2045, 2049}


local wUsedAt = 0
local vUsedAt = 0
local timer=os.clock()
local bluePill = nil

local targetItems={3144,3153,3128,3092,3146}
--Bilgewater,BoTRK,DFG,FrostQueen,Hextech
local aoeItems={3184,3143,3250,3131,3069,3023,3290,3142}
--Entropy,Randuins,Odyns,SwordDivine,TalismanAsc,TwinShadows,TwinShadows,YoGBlade
local hydraItems={3074,3077}
--Hydra,Tiamat
local shieldItems={3410,3190,3040}
--FaceofMountainLocketIS,Seraph(Arch)
local allyItems={3222}
--MikaelsCrucible,
local cleanseItems={3139,3140}
--MercScimitar,QuickSilver

local egg = {team = 0, enemy = 0}
local zac = {team = 0, enemy = 0}
local aatrox = {team = 0, enemy = 0}
local _registry = {}

JaxConfig = scriptConfig('Mals Jax Config', 'JaxConfig')
JaxConfig:addParam('teamfight', 'AutoTeamFight', SCRIPT_PARAM_ONKEYDOWN, false, 84)
JaxConfig:addParam('harass', 'Harass', SCRIPT_PARAM_ONKEYDOWN, false, 88)
JaxConfig:addParam("ward", "Ward Jump", SCRIPT_PARAM_ONKEYDOWN, false, 90)

JaxConfig:addParam('ult', 'Ult in TF', SCRIPT_PARAM_ONKEYTOGGLE, true, 57)
JaxConfig:addParam('ks', 'Killsteal', SCRIPT_PARAM_ONKEYTOGGLE, true, 48)

JaxConfig:addParam("AAS", "When To AA Again", SCRIPT_PARAM_NUMERICUPDOWN, 0.15,219,0,1,0.05)
JaxConfig:addParam("AC", "When Attack Completed", SCRIPT_PARAM_NUMERICUPDOWN, 0.6,221,0,1,0.05)
JaxConfig:addParam("pots", "Auto Potions", SCRIPT_PARAM_ONOFF, true)
JaxConfig:addParam('smite', 'SmiteSteal', SCRIPT_PARAM_ONOFF, true)
JaxConfig:addParam('nm', 'NearMouse Targetting', SCRIPT_PARAM_ONOFF, true)
JaxConfig:addParam("wardF", "Ward Farthest", SCRIPT_PARAM_ONOFF, true)
JaxConfig:permaShow('ult')
JaxConfig:permaShow('ks')
JaxConfig:permaShow('nm')


function Run()
	if JaxConfig.nm==true then
		target = GetBestEnemy("PHYS",800,"NEARMOUSE")
	else
		target = GetBestEnemy("PHYS",800)
	end
		www=nil
		for _, ward in pairs(wards) do
			if ward~=nil and GetWardSlot(ward) ~= nil and os.clock() > lastWardJump  then
				
				www=GetWardSlot(ward)
				--print("\nHere1 "..tostring(ward))
				break
				
			end
		end
		if IsChatOpen()==0 and myHero.dead~=1 and JaxConfig.ward and JaxConfig.wardF then ward(mousePos.x,mousePos.y,mousePos.z) 
		elseif IsChatOpen()==0 and myHero.dead~=1 and JaxConfig.ward and JaxConfig.wardF==false then ward() end  
	
		
		if JaxConfig.teamfight and IsChatOpen() == 0 then
			Fight()
		end

		if JaxConfig.harass and IsChatOpen() == 0 then
			Harass()
		end
		
		if JaxConfig.ks then
			Killsteal()
		end
		
		if JaxConfig.smite then smitesteal() end
		if JaxConfig.pots then RedElixir() end
	        ------------
        if myHero.SpellTimeQ > 1.0 and GetSpellLevel('Q') > 0 and (myHero.mana>=(65)) then
                QRDY = 1
                else QRDY = 0
        end
        if myHero.SpellTimeW > 1.0 and GetSpellLevel('W') > 0 and myHero.mana>=(30) then
                WRDY = 1
                else WRDY = 0
        end
        if myHero.SpellTimeE > 1.0 and GetSpellLevel('E') > 0 and myHero.mana>=(65+5*GetSpellLevel('E')) then
                ERDY = 1
                else ERDY = 0
        end
        if myHero.SpellTimeR > 1.0 and GetSpellLevel('R') > 0 and (myHero.mana>=(100)) then
                RRDY = 1
				else RRDY = 0 
		end
        if Rmod > 1 and GetSpellLevel('R') > 0 then
                RPASSIVE = 1
				else RPASSIVE = 0 
		end
        --------------------------
		if Rmod~=0 and RmodReset<=os.clock() then
			Rmod=0
		end
		if ESpinning==true and os.clock()>=ETimer then
			ESpinning=false
		end
end


function QSpell(tt)
CastSpellTarget('Q',tt)
end

function Fight()
	if target~=nil then
		if ESpinning==true then
			if isMoving(target) or GetD(target)>250 then
				MoveToXYZ(GetFireahead(target,2,0))
			end
			if QRDY==1 and GetD(target)>200 then
				CastSpellTarget("Q",target)
			elseif surrounded(myHero)==10 or (target.movespeed>myHero.movespeed and GetD(target)<250) or (surrounded(myHero)==1 and GetD(target)<250) then
				CastSpellTarget("E",myHero)
			end
		end
		if RRDY==1 and JaxConfig.ult and GetD(target)<400 then
			CastSpellTarget("R",myHero)
		elseif WRDY==1 and (GetSpellLevel("R")==0 or Rmod>1 or myHero.health<=(myHero.maxHealth*0.10)) and os.clock()>AttackCompleted and os.clock()<timetoAA and GetD(target)<myHero.range+75 then
			CastSpellTarget("W",myHero)
		elseif GetD(target)<myHero.range+75 then
			AttackT(target)
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
		elseif QRDY==1 and (GetD(target)<650 or (myHero.movespeed>=target.movespeed and GetD(target)<700)) then
			if ERDY==1 and myHero.mana>=(65+5*GetSpellLevel('E'))+65 then
				CastSpellTarget("E",myHero)
			end
			CastSpellTarget("Q",target)
		elseif  GetD(target)<400 then
			AttackT(target)
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
				MoveToMouse()
					if GetInventorySlot(item)~=nil and myHero["SpellTime"..GetInventorySlot(item)]>1.0 then
							CastSpellTarget(tostring(GetInventorySlot(item)),target)
					end
			end
		else 
			MoveToMouse()
		end		
	else
		MoveToMouse()
	end
end

function Harass()
	if target~=nil then
		if QRDY==1 and (GetD(target)<650 or (myHero.movespeed>=target.movespeed and GetD(target)<700)) then
			if WRDY==1 and myHero.mana>=(35)+65 then
				CastSpellTarget("W",myHero)
			end
			CastSpellTarget("Q",target)
			AttackTarget(target)
		else
			MoveToMouse()
		end
	else
		MoveToMouse()
	end
end

function ward(hx,hy,hz)
	if hx~=nil and hy~=nil and hz~=nil then
		
		if QRDY==1 and os.clock() > lastWardJump then
			
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
		
		if QRDY==1 and wardsuccess==true and lastWardObject~=nil and GetD(lastWardObject)<700 then
			run_every(0.2,QSpell, lastWardObject)
		
		end

                if ( QRDY==0 or not gotAWard()) then
                        MoveToMouse()
                end
	else
				--print("\nHere41")
		if QRDY==1 and os.clock() > lastWardJump then
			
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
		
		if QRDY==1 and wardsuccess==true and lastWardObject~=nil and GetD(lastWardObject)<700 then
			run_every(0.2,QSpell, lastWardObject)
		
		end
		if ( QRDY==0 or not gotAWard()) then
			MoveToMouse()
		end
	end
end


 
function smitesteal()
		if myHero.SummonerD == "SummonerSmite" then
			if IsSpellReady('D')==1 then
				CastHotkey("AUTO 100,0 SPELLD:SMITESTEAL RANGE=600 TRUE COOLDOWN")
				return
			end
		elseif myHero.SummonerF == "SummonerSmite" then
			if IsSpellReady('F')==1 then
				CastHotkey("AUTO 100,0 SPELLF:SMITESTEAL RANGE=600 TRUE COOLDOWN")
				return
			end
		end
end

function Killsteal()
	if target~=nil then
		local WDMG=getDmg("W",target,myHero)*ERDY
		local QDMG=getDmg("Q",target,myHero)*QRDY
		local RDMG=getDmg("Q",target,myHero)*RPASSIVE
		
		if target.health<(QDMG+WDMG)*QRDY and GetD(target)<700 then
			CastSpellTarget("W",myHero)
			CastSpellTarget("Q",target)
			AttackTarget(target)
		end
	end
end


function AttackT(enemy)
	if enemy~=nil and os.clock()>=timetoAA then
		--MoveToXYZ(myHero.x,myHero.y,myHero.z,0)
		AttackTarget(enemy)
	elseif os.clock()>=AttackCompleted and GetD(enemy)>myHero.range+75 then
		MoveToXYZ(GetFireahead(enemy,3,0))
	end
end

function OnDraw()
	if myHero.dead==0 then
		if QRDY==1 then
			CustomCircle(700,2,3,myHero)
		end
		if ERDY==1 then
			CustomCircle(250,2,4,myHero)		
		end
		if target~=nil then
			CustomCircle(200,4,2,target)		
		end
			if gotAWard() then
				CustomCircle(610,2,1,myHero)
			end
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
							tz = myHero.z-620
					else
							tz = myHero.z+(620)
					end
		   
			elseif spot.z==myHero.z then
					tz = myHero.z
					if myHero.x>spot.x then
							tx = myHero.x-(620)
					else
							tx = myHero.x+(620)
					end
		   
			elseif myHero.x>spot.x then
					angle = math.asin((myHero.x-spot.x)/dist)
					zs = (620)*math.cos(angle)
					xs = (620)*math.sin(angle)
					if myHero.z>spot.z then
							tx = myHero.x-xs
							tz = myHero.z-zs
					elseif myHero.z<spot.z then
							tx = myHero.x-xs
							tz = myHero.z+zs
					end
		   
			elseif myHero.x<spot.x then
					angle = math.asin((spot.x-myHero.x)/dist)
					zs = (620)*math.cos(angle)
					xs = (620)*math.sin(angle)
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


function surrounded(self)
	local count=0
	local inE=0
	for i=1, objManager:GetMaxHeroes(), 1 do
		hero = objManager:GetHero(i)
		if hero~=nil and hero~=self and hero.team~=myHero.team and hero.visible==1 and GetD(self,hero)<600 then
			if GetD(self,hero)<250 then
				inE=inE+1
			end
			count=count+1
			--table.insert(enemies,hero)
		end
	end

	if inE>1 then
		return 10
	else 
		return count
	end
end

function OnProcessSpell(unit, spell)
    if unit.charName==myHero.charName then
        --printtext("\nS "..spell.name.."  " ..os.clock().." Q:"..myHero.SpellNameQ.." W:"..myHero.SpellNameW.." E:"..myHero.SpellNameE.." R:"..myHero.SpellNameR.."\n")    
			
		if attacks[spell.name] then
			AttackCompleted=os.clock()+(JaxConfig.AC/myHero.attackspeed)
			timetoAA = os.clock()+(1-JaxConfig.AAS)*(1/myHero.attackspeed)
			if spell.name=="jaxrelentlessattack" then
			Rmod=0
			else
			Rmod=(Rmod+1)%3
			end
			RmodReset=os.clock()+2.5
		elseif string.find(spell.name,"JaxCounterStrike") then
			if ESpinning==false then
				ETimer=os.clock()+2
				ESpinning=true
			else
				ESpinning=false
			end
		elseif string.find(spell.name,"JaxEmpower") then
			timetoAA=os.clock()
		end
	end
end



function OnCreateObj(obj)
	--if obj~=nil and GetD(obj)<600 then
		--printtext("\nO "..obj.charName.." Oname "..obj.name)
	--end	
	if (JaxConfig.ward) and GetD(obj)<800 and (string.find(obj.charName,"SightWard") or string.find(obj.charName,"VisionWard")) then
		lastWardObject=obj
		lastWardJump = os.clock()+5
	end
	if (GetD(myHero, obj)) < 100 and JaxConfig.pots then
		if string.find(obj.charName,"FountainHeal") then
			timer=os.clock()
			bluePill = obj
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
------------------------------END Spell Callback Stuff


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
SetTimerCallback("Run")