require "Utils"
require 'spell_damage'
print=printtext
printtext("\nShopping for Kills with the Kart\n")
printtext("\nBy Malbert\n")
printtext("\nVersion 3.2\n")



local target
local targetE
local miniontarget
local minionDamage = 0
local areaMinions = {}
local miniontargetHealth=0
local minionDamageTimer = 0
local ghosttarget
local lastHitSpot = { x = 0, y = 0, z = 0, single = 0 }
local minions={}
local minionRadius = 100
local spellRadius = 100
local closestArc
local ignitedamage=0
local IGN
local EXH

local Etoggle = false

local LEMIA={}
local LowEnemyRecalling={}

local enemiesAll={}
local QSpot = { x = 0, y = 0, z = 0}

local tqfx,tqfy,tqfz
local tqfa

local Ghost=false
local ghostultTimer=0
local tfdiedtimer=0
local tfdied=false
local textflashtimer=0
local colorCheck = 0
local colorCheck2 = 0


local SpawnturretR={}
local SpawnturretB={}
local TurretsR={}
local TurretsB={}
local allyTurrets={}
local allySpawn={}
local map = nil

local QRDY=0
local WRDY=0
local ERDY=0
local RRDY=0

local CLOCK=0



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

local _registry = {}
local turret = {}
local runeverycc=0

	KarthConfig = scriptConfig('Karth Config', 'KarthConfig')
	KarthConfig:addParam('QDD', 'QwithDoubleDamage', SCRIPT_PARAM_ONKEYDOWN, false, 65)
	KarthConfig:addParam('doingcombo', 'Combo', SCRIPT_PARAM_ONKEYDOWN, false, 88)
	KarthConfig:addParam('teamfight', 'TeamFight', SCRIPT_PARAM_ONKEYDOWN, false, 84)
	KarthConfig:addParam('farm', 'AutoCreepFarm', SCRIPT_PARAM_ONKEYTOGGLE, false, 189)
	KarthConfig:addParam('dfarm', 'DefendFarm', SCRIPT_PARAM_ONKEYTOGGLE, true, 187)
	KarthConfig:addParam('autoQ', 'AutoQ', SCRIPT_PARAM_ONKEYTOGGLE, false, 55)
	KarthConfig:addParam('autoE', 'AutoDefile', SCRIPT_PARAM_ONKEYTOGGLE, false, 56)
	KarthConfig:addParam('autoR', 'AutoSafeULT', SCRIPT_PARAM_ONKEYTOGGLE, false, 57)
	KarthConfig:addParam('deathR', 'UltB4Death', SCRIPT_PARAM_ONKEYTOGGLE, false, 48)
	KarthConfig:addParam('warn', 'EnemyLowWarning', SCRIPT_PARAM_ONOFF, true)
	KarthConfig:addParam('dokillsteal', 'Killsteal', SCRIPT_PARAM_ONOFF, true)
	KarthConfig:permaShow('farm')
	KarthConfig:permaShow('dfarm')
	KarthConfig:permaShow('autoQ')
	KarthConfig:permaShow('autoE')
	KarthConfig:permaShow('autoR')
	KarthConfig:permaShow('deathR')
	KarthConfig:permaShow('dokillsteal')
	

	
function Run()

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
		
	CLOCK=os.clock()
	for i=1, objManager:GetMaxHeroes(), 1 do
		hero = objManager:GetHero(i)
		if hero~=nil and hero.team~=myHero.team and enemiesAll[hero]==nil then
			table.insert(enemiesAll,hero)
		end
	end
	targetE=GetWeakEnemy('MAGIC',475)
	target=GetWeakEnemy('MAGIC',1050)
	if target~=nil then
	
		tqfx,tqfy,tqfz = GetFireahead(target,6,0)
		tqfa={x=tqfx,y=tqfy,z=tqfz}

	end
	
	--igniteExh()
	

	if Ghost==true and (ghosttarget==nil or ghosttarget.dead==1) then
		local th=nil
		for i=1, objManager:GetMaxHeroes(), 1 do
			hero = objManager:GetHero(i)
			local hqfx,hqfy,hqfz
			local hqfa
			hqfx,hqfy,hqfz = GetFireahead(hero,6,0)
			hqfa={x=hqfx,y=hqfy,z=hqfz}
			if hero~=nil and hero.team~=myHero.team and hero.dead~=1 and GetD(hqfa)<975 and (th==nil or th.dead==1) then
				th=hero
			elseif hero~=nil and hero.team~=myHero.team and hero.dead~=1 and GetD(hqfa)<975 and GetD(hero)<GetD(th) then
				th=hero
			end
		end
		ghosttarget=th
	elseif Ghost==false then
		ghosttarget=nil
	end
		
	
	if IsChatOpen()==0 and KarthConfig.QDD and target~=nil then qDoubleDmg(target) elseif IsChatOpen()==0 and KarthConfig.QDD then MoveToMouse() end
	if KarthConfig.autoQ and not KarthConfig.teamfight and not KarthConfig.doingcombo then autoQ() end
	if KarthConfig.warn then LowWarn() end
	if KarthConfig.dokillsteal then killsteal() end
	if not KarthConfig.teamfight and not KarthConfig.deathR and tfdied==true then
		if tfdiedtimer+3<os.clock() and  tfdiedtimer+4>os.clock() then
			deathR()
			tfdied=false
		end
	end
	if KarthConfig.deathR then deathR() end
	if KarthConfig.autoE and not KarthConfig.teamfight and not KarthConfig.doingcombo then autoE() end
	if KarthConfig.autoR and not KarthConfig.doingcombo and not KarthConfig.teamfight then autoR() end
	if KarthConfig.farm and not KarthConfig.doingcombo and not KarthConfig.teamfight then 
		UpdateMinionTable()
		FindBestMinion()
		autofarm() 
	end
	if IsChatOpen()==0 and KarthConfig.doingcombo then harass() end
	if IsChatOpen()==0 and KarthConfig.teamfight then Teamfight() end
	if runeverycc<10 then
				run_every(1,findTurret)
	end
	if myHero.dead==1 then
		Etoggle=false
	end
end


function OnProcessSpell(unit, spell)

	
	if unit.team==myHero.team and GetD(unit,myHero)<10 then
		local s=spell.name

		--printtext("\n".. s .."\n") 
		if (s ~= nil) and string.find(s,"efile") ~= nil then
		--and (not KarthConfig.autoE or not KarthConfig.doingcombo or not KarthConfig.teamfight) 
			
			if Etoggle==false then Etoggle=true
			elseif Etoggle==true then Etoggle=false end
		end
	end
	if unit.team~=myHero.team and unit.selflevel~=nil and unit.selflevel>0 then
	local s=spell.name
		if (s ~= nil) and string.find(s,"Recall") ~= nil then    
			LowEnemyRecalling[unit.name]={timestarted=os.clock()}
			
            end
		end
end
	

function OnCreateObj(obj)

	if GetD(obj,myHero) <10 then
	--printtext("\n"..obj.charName.."\n")
		local s = obj.charName
		if (s ~= nil) and string.find(s,"DeathExplo") ~= nil then
			Ghost=true
			ghostultTimer=os.clock()+2.3
			if KarthConfig.teamfight then
				tfdied=true
				tfdiedtimer=os.clock()
			end
		
		end

    end	
end


--------------CALLBACKS	 START-----------------------------
--[[
function igniteExh()
		if myHero.SummonerD == 'SummonerDot' then
			ignitedamage = ((myHero.selflevel*20)+50)*IsSpellReady('D')
			IGN='D'
		elseif myHero.SummonerF == 'SummonerDot' then
				ignitedamage = ((myHero.selflevel*20)+50)*IsSpellReady('F')
				IGN='F'
		else
				ignitedamage=0
				IGN=nil
		end
		if myHero.SummonerD == 'SummonerExhaust' and IsSpellReady('D')==1 then
			EXH='D'
		elseif myHero.SummonerF == 'SummonerExhaust' and IsSpellReady('F')==1 then
			EXH='F'
		else
			EXH=nil
		end
		
end--]]

function CheckMultiHitMinion(targ)
	local t,t2,t3 = GetFireahead(targ,6,0)
	local targC={x=t,y=t2,z=t3}
    for i,minion in ipairs(minions) do
		local m,m2,m3=GetFireahead(minion,6,0)
		local minionC={x=m,y=m2,z=m3}
        if targ~=nil and minion ~= nil and minion.x~=targ.x and minion.z~=targ.z and minion.team ~= 0 and minion.team ~= myHero.team and GetD(targC, minionC) <= (minionRadius + spellRadius) then
            return true
        end
    end
    return false
end	

function CheckMultiHitMinionFA(targ)
    for i,minion in ipairs(minions) do
		local m,m2,m3=GetFireahead(minion,6,0)
		local minionC={x=m,y=m2,z=m3}
        if targ~=nil and minion ~= nil and minion.x~=targ.x and minion.z~=targ.z and minion.team ~= 0 and minion.team ~= myHero.team and GetD(targ, minionC) <= (minionRadius + spellRadius) then
            return true
        end
    end
    return false
end	

function CheckMultiHitHero(targ)
	local t1,t2,t3=GetFireahead(targ,6,0)
	local targC={x=t1,y=t2,z=t3}
    for i=1, objManager:GetMaxHeroes(), 1 do
		hero = objManager:GetHero(i)
		local h1,h2,h3=GetFireahead(hero,6,0)
		local heroC={x=h1,y=h2,z=h3}
        if hero~=nil and targ~=nil and hero.team ~= 0 and hero.x~=targ.x and hero.z~=targ.z and hero.team ~= myHero.team and GetD(targC, heroC) <= (minionRadius + spellRadius) then
            return true
        end
    end
    return false
end	

function CheckMultiHitHeroFA(targ)
    for i=1, objManager:GetMaxHeroes(), 1 do
		hero = objManager:GetHero(i)
		local h1,h2,h3=GetFireahead(hero,6,0)
		local heroC={x=h1,y=h2,z=h3}
        if hero~=nil and targ~=nil and hero.team ~= 0 and hero.x~=targ.x and hero.z~=targ.z and hero.team ~= myHero.team and GetD(targ, heroC) <= (minionRadius + spellRadius) then
            return true
        end
    end
    return false
end	
	
function runningAway(slowtarget,me)
	if me==nil then
		me=myHero
	end
   local d1 = GetD(slowtarget,me)
   local x, y, z = GetFireahead(slowtarget,5,0)
   local d2 = GetD({x=x, y=y, z=z},me)
   local d3 = GetD({x=x, y=y, z=z},slowtarget)
   local angle = math.acos((d2*d2-d3*d3-d1*d1)/(-2*d3*d1))
   
   return angle%(2*math.pi)>math.pi/2 and angle%(2*math.pi)<math.pi*3/2

end

function UpdateMinionTable()

    if miniontarget ~= nil and (miniontarget.dead == 1 or miniontarget.visible==0 or GetD(miniontarget)>900) then
        miniontarget = nil
    end
    
    for i,minion in ipairs(minions) do 
        if minion.dead == 1 or minion.team == myHero.team or minion == nil or minion.visible==0 or minion.x==nil then
            table.remove(minions,i)
        end
    end
    
    for i=1, objManager:GetMaxNewObjects(), 1 do
        object = objManager:GetNewObject(i)
        if object and object ~= nil and object.team ~= 0 and object.charName ~= nil and object.team ~= myHero.team and object.dead~=1 and object.visible==1 and string.find(object.charName,"inion_") then
            table.insert(minions,object)
        end
    end
end

function FindBestMinion()
    if #minions > 0 then
        for i,minion in ipairs(minions) do
            if minion.team ~= 0 and minion.team ~= myHero.team and GetD(minion, myHero) <= 975 then
                if minion~=nil and minion.dead~=1 and minion.visible==1 and (miniontarget == nil or miniontarget.health==nil or (minion.health~=nil and minion.health < miniontarget.health)) then
                    miniontarget = minion
                    miniontargetHealth = minion.health
                    minionDamage = 0
                    minionDamageTimer = CLOCK
                end
            end
        end
    end
	if miniontarget~=nil and (CLOCK - minionDamageTimer) >= 0.1 and miniontarget.health~=nil and miniontargetHealth > miniontarget.health then
		minionDamage = miniontargetHealth - miniontarget.health
		miniontargetHealth = miniontarget.health
		minionDamageTimer = CLOCK
	end
end

function BestSpotMinion()
		local mtfax,mtfay,mtfaz
		local mtfa = {}
		local mfa = {}
		areaMinions={}
		if miniontarget~=nil and miniontarget.visible==1 and miniontarget.dead~=1 then
			mtfax,mtfay,mtfaz=GetFireahead(miniontarget,6,0)
			mtfa = {x=mtfax,y=mtfay,z=mtfaz}
			for i,minion in ipairs(minions) do
				if minion~=nil and minion.dead~=1 and minion.visible==1 and minion.team ~= 0 and minion.team ~= myHero.team and GetD(minion) <900 then
					mfax,mfay,mfaz=GetFireahead(minion,6,0)
					mfa = {x=mfax,y=mfay,z=mfaz}
					if miniontarget~=nil and CheckMultiHitMinion(miniontarget) and GetD(mtfa, mfa) < (minionRadius + spellRadius) and minion.health~=nil and minion.health <= CalcMagicDamage(minion,(20 + (20 * GetSpellLevel('Q')) + (myHero.ap * 0.3))) then

						table.insert(areaMinions, minion)
					end
				end
			end
			
			if #areaMinions > 0 then
				local totalSpace = { x = 0, y = 0, z = 0 }
				table.insert(areaMinions, miniontarget)
				local count = table.getn(areaMinions)
				for j,minion2 in ipairs(areaMinions) do
					mfax2,mfay2,mfaz2=GetFireahead(minion2,6,0)
					totalSpace.x = totalSpace.x + mfax2
					totalSpace.y = totalSpace.y + mfay2
					totalSpace.z = totalSpace.z + mfaz2
				end
				lastHitSpot.x = totalSpace.x / count
				lastHitSpot.y = totalSpace.y / count
				lastHitSpot.z = totalSpace.z / count
				lastHitSpot.single = 0
				
			else
				local spot = { x = 0, y = 0, z = 0 }
				local angle = 0
				local spotFound = false
				for j=0, 360, 10 do
					local rads = angle * (math.pi / 180)
					spot.x,spot.y,spot.z = GetFireahead(miniontarget,6,0)
					spot.x = spot.x + (spellRadius+minionRadius-15) * math.floor(math.cos(rads))
					spot.z = spot.z + (spellRadius+minionRadius-15) * math.floor(math.sin(rads))
					local spotClear = true
					if CheckMultiHitMinionFA(spot)==false and GetD(spot,mtfa)<=(spellRadius+minionRadius-15) then
						lastHitSpot.x = spot.x
						lastHitSpot.y = spot.y
						lastHitSpot.z = spot.z
						lastHitSpot.single = 1
						spotFound = true
						break
					end
					angle = angle - 10
				end
				if spotFound == true then
					
				end
				if spotFound ~= true then
					lastHitSpot.x = mtfax
					lastHitSpot.y = mtfay
					lastHitSpot.z = mtfaz
					lastHitSpot.single = 0
					
				end
			end
				
			if CheckMultiHitMinion(miniontarget)==false then
				lastHitSpot.x = mtfax
				lastHitSpot.y = mtfay
				lastHitSpot.z = mtfaz
				lastHitSpot.single = 1
				
			end
		end
end

------------END OF CALLBACKS--------------------------------

function autofarm()
	local Q = (20 + (20 * GetSpellLevel('Q')) + (myHero.ap * 0.3))+lastHitSpot.single*(20 + (20 * GetSpellLevel('Q')) + (myHero.ap * 0.3))
if KarthConfig.dfarm then
	if target~= nil and GetD(target)<700 then
		local tfax,tfay,tfaz = GetFireahead(target,6,0)
		local QSpot={x=tfax,y=tfay,z=tfaz}
		if CheckMultiHitMinion(target)==false and CheckMultiHitHero(target)==false then
			CastSpellXYZ('Q',QSpot.x,QSpot.y,QSpot.z)
		else	
			local spot = { x = 0, y = 0, z = 0 }
			local angle = 0
			local spotFound = false
			
			local closestD = { x = 0, y = 0, z = 0 }
			local closestDcheck = { x = 0, y = 0, z = 0 }
			local angle1 = 0
			
			for j=0, 360, 10 do
				local rads = angle1 * (math.pi / 180)			
				closestDcheck.x,closestDcheck.y,closestDcheck.z = GetFireahead(target,6,0)
				closestDcheck.x = closestDcheck.x + (spellRadius+minionRadius-15) * math.floor(math.cos(rads))
				closestDcheck.z = closestDcheck.z + (spellRadius+minionRadius-15) * math.floor(math.sin(rads))
				if closestD.x==0 then			
					closestD.x,closestD.y,closestD.z = GetFireahead(target,6,0)
					closestD.x = closestD.x + (spellRadius+minionRadius-15) * math.floor(math.cos(rads))
					closestD.z = closestD.z + (spellRadius+minionRadius-15) * math.floor(math.sin(rads))
					closestArc=j
				elseif closestD~=0 and GetD(closestD,myHero)> GetD(closestDcheck,myHero)then				
					closestD.x,closestD.y,closestD.z = GetFireahead(target,6,0)
					closestD.x = closestD.x + (spellRadius+minionRadius-15) * math.floor(math.cos(rads))
					closestD.z = closestD.z + (spellRadius+minionRadius-15) * math.floor(math.sin(rads))
					closestArc=j
				end
				angle1 = angle1 - 10
			end
			for j=closestArc, closestArc+360, 10 do
				local rads = angle * (math.pi / 180)
				spot.x,spot.y,spot.z = GetFireahead(target,6,0)
				spot.x = spot.x + (spellRadius+minionRadius-15) * math.floor(math.cos(rads))
				spot.z = spot.z + (spellRadius+minionRadius-15) * math.floor(math.sin(rads))
				local spotClear = true
				if CheckMultiHitMinionFA(spot)==false and CheckMultiHitHeroFA(spot)==false and GetD(spot,tfa)<=(spellRadius+minionRadius-15) then				
					QSpot.x = spot.x
					QSpot.y = spot.y
					QSpot.z = spot.z
					spotFound = true
					break
				end
				angle = angle - 10
			end
			
			if spotFound ~= true then
				QSpot.x,QSpot.y,QSpot.z = GetFireahead(target,6,0)
			end
			CastSpellXYZ('Q',QSpot.x,QSpot.y,QSpot.z)
		end
	else
		BestSpotMinion()
		if miniontarget~=nil and miniontarget.health~=nil and miniontarget.health <= CalcMagicDamage(miniontarget,Q) then
			CastSpellXYZ('Q', lastHitSpot.x, lastHitSpot.y, lastHitSpot.z)
		end
	end
else
	BestSpotMinion()
	if miniontarget~=nil and miniontarget.health~=nil and miniontarget.health <= CalcMagicDamage(miniontarget,Q) then
		CastSpellXYZ('Q', lastHitSpot.x, lastHitSpot.y, lastHitSpot.z)
	end
end		
end


function qDoubleDmg(tar)
	if tar~=nil and tar.dead~=1 and GetD(tar)<920 then
			--CastSpellXYZ('Q',GetFireahead(tar,6,0))
		if CheckMultiHitMinion(tar)==false and CheckMultiHitHero(tar)==false and QRDY==1 then
			CastSpellXYZ('Q',GetFireahead(tar,6,0))

		else	
			
			local QSpot = { x = 0, y = 0, z = 0}
			local spot = { x = 0, y = 0, z = 0 }
			local angle = 0
			local spotFound = false
			
			local closestD = { x = 0, y = 0, z = 0 }
			local closestDcheck = { x = 0, y = 0, z = 0 }
			local angle1 = 0
			
			for j=0, 360, 10 do
				local rads = angle1 * (math.pi / 180)			
				closestDcheck.x,closestDcheck.y,closestDcheck.z = GetFireahead(tar,6,0)
				closestDcheck.x = closestDcheck.x + (spellRadius+minionRadius-15) * math.floor(math.cos(rads))
				closestDcheck.z = closestDcheck.z + (spellRadius+minionRadius-15) * math.floor(math.sin(rads))
				if closestD.x==0 then			
					closestD.x,closestD.y,closestD.z = GetFireahead(tar,6,0)
					closestD.x = closestD.x + (spellRadius+minionRadius-15) * math.floor(math.cos(rads))
					closestD.z = closestD.z + (spellRadius+minionRadius-15) * math.floor(math.sin(rads))
					closestArc=j
				elseif closestD~=0 and GetD(closestD,myHero)> GetD(closestDcheck,myHero)then				
					closestD.x,closestD.y,closestD.z = GetFireahead(tar,6,0)
					closestD.x = closestD.x + (spellRadius+minionRadius-15) * math.floor(math.cos(rads))
					closestD.z = closestD.z + (spellRadius+minionRadius-15) * math.floor(math.sin(rads))
					closestArc=j
				end
				angle1 = angle1 - 10
			end
			for j=closestArc, closestArc+360, 10 do
				local rads = angle * (math.pi / 180)
				spot.x,spot.y,spot.z = GetFireahead(tar,6,0)
				spot.x = spot.x + (spellRadius+minionRadius-15) * math.floor(math.cos(rads))
				spot.z = spot.z + (spellRadius+minionRadius-15) * math.floor(math.sin(rads))
				local spotClear = true
				if CheckMultiHitMinionFA(spot)==false and CheckMultiHitHeroFA(spot)==false and GetD(spot,tfa)<=(spellRadius+minionRadius-10) then				
					QSpot.x = spot.x
					QSpot.y = spot.y
					QSpot.z = spot.z
					spotFound = true
					--print("\n2 "..QSpot.x .."\n")
					break
				end
				angle = angle - 10
			end
			
			if spotFound ~= true and CheckMultiHitHero(tar)==false then
				QSpot.x,QSpot.y,QSpot.z = GetFireahead(tar,6,0)
				
				--print("\n3 "..QSpot.x .."\n")
			elseif spotFound~=true and CheckMultiHitHero(tar)==true then
				local tfax,tfay,tfaz=GetFireahead(tar,6,0)
				local tfa={x=tfax,y=tfay,z=tfaz}
				local areaHeroes={}
				for i=1, objManager:GetMaxHeroes(), 1 do
					hero = objManager:GetHero(i)
					if hero ~= nil and hero~=tar and hero.team ~= myHero.team then
						local hfax,hfay,hfaz=GetFireahead(hero,6,0)
						local hfa={x=hfax,y=hfay,z=hfaz}
						if GetD(hfa, tfa) <= (minionRadius + spellRadius) then
							table.insert(areaHeroes, hero)
						end
					end
				end
				
				
				--print("\n4 "..QSpot.x .."\n")
				local totalSpace = { x = 0, y = 0, z = 0 }
				table.insert(areaHeroes, tar)
				local count = table.getn(areaHeroes)
				for i,hero in ipairs(areaHeroes) do
					if hero~=nil then
						local FA1,FA2,FA3 = GetFireahead(hero,6,0)
						totalSpace.x = totalSpace.x + FA1
						totalSpace.y = totalSpace.y + FA2
						totalSpace.z = totalSpace.z + FA3
					end
				end
				QSpot.x = totalSpace.x / count
				QSpot.y = totalSpace.y / count
				QSpot.z = totalSpace.z / count

				--print("\n5 "..QSpot.x .."\n")
			else
				QSpot.x,QSpot.y,QSpot.z = GetFireahead(tar,6,0)
			end
			if QRDY==1 then
				CastSpellXYZ('Q',QSpot.x,QSpot.y,QSpot.z)
			end
			--print("\n6 "..QSpot.x .."\n")
		end
	
	end
end	
	
	
function harass()
	if target~=nil and target.dead~=1 then
		if QRDY==1 and GetD(target)<870 then
			qDoubleDmg(target)
		end
		
		if WRDY==1 and GetD(target) <1000 and runningAway(target) then
			CastSpellXYZ('W',GetFireahead(target,6,0))
		end
		
		if ERDY==1 and Etoggle==false and GetD(target)<475 then
			CastSpellTarget('E',target)
			--Etoggle=true
		end
		
		if ERDY==1 and Etoggle==true and GetD(target)>475 then
			CastSpellTarget('E',target)
			--Etoggle=false
		end
		
		if GetD(target)<600 then
			UseAllItems(target)
		end
		
		if GetD(target)<500 then
			AttackTarget(target)
		end
		
	else
		MoveToMouse()
		if ERDY==1 and Etoggle==true and Ghost==false then
			CastSpellTarget('E',myHero)
			--Etoggle=false
		end
	end
end
	
	
function Teamfight()

	local enemiesInsideE={}
	local numberEnemies=0
	if Ghost==false then
	for i,hero in pairs(enemiesAll) do
		if hero~=nil and hero.dead~=1 and hero.team~=myHero.team and hero.visible==1 and enemiesInsideE[hero.name]==nil and GetD(hero)<425 then
			numberEnemies=numberEnemies+1
			enemiesInsideE[hero.name]=hero
		elseif hero~=nil and enemiesInsideE[hero.name]~=nil and (hero.dead==1 or GetD(hero)>425) then
			numberEnemies=numberEnemies-1
			enemiesInsideE[hero.name]=nil
		end
	end
	end
	
	
	if target~=nil then
		if RRDY==1 then
			local enemyList ={}
			local enemiesInList=0
			local save4L8R = {}
			local enemiesSaved=0
			local safe2R=true
		
			--for i=1, objManager:GetMaxHeroes(), 1 do
			--	hero = objManager:GetHero(i)
				
			for i,hero in ipairs(enemiesAll) do
				
				
				local R = getDmg('R',hero,myHero)*RRDY
				if hero~=nil and hero.dead~=1 and hero.team~=myHero.team and hero.health+10+hero.selflevel<R then
					save4L8R[hero.name]=hero
					enemiesSaved=enemiesSaved+1
				elseif hero~=nil and save4L8R[hero.name]~=nil and (hero.dead==1) then
					save4L8R[hero.name]=nil
					enemiesSaved=enemiesSaved-1
				elseif hero~=nil and hero.dead~=1 and hero.team~=myHero.team then
					enemyList[hero.name]=hero
					enemiesInList=enemiesInList+1
				elseif hero~=nil and enemyList[hero.name]~=nil and (hero.dead==1 or hero.visible==0 or GetD(hero,myHero)>975) then
					enemyList[hero.name]=nil
					enemiesInList=enemiesInList-1
				end
				
			end
			
			
			for i=1, objManager:GetMaxHeroes(), 1 do
				hero = objManager:GetHero(i)
				if hero~=nil and hero.dead~=1 and hero.team~=myHero.team and Ghost==false and GetD(hero)<1200 then
					safe2R =false
					break
				end
			end
			
			
			if enemiesSaved>0 and enemiesInList==0 and safe2R==true then
				CastSpellTarget('R',myHero)
			
			
			elseif enemiesSaved>0 and enemiesInList==0 and safe2R==false then
				for i,herocheckD in pairs(enemiesAll) do
					if herocheckD~=nil and herocheckD.dead~=1 and herocheckD.visible==1 and herocheckD.team~=myHero.team and Ghost==false and GetD(herocheckD)<1300  then
						for i,tower in ipairs(allySpawn) do
							MoveToXYZ(tower.object.x,tower.object.y,tower.object.z)
							safe2R=false
							stop=true
							break
						end
					
					else
						stop=true
						if stop==true then
							StopMove()
							stop=false
						end											
						safe2R=true											
					end
				end
				if safe2R==true then
					CastSpellTarget('R',myHero)
				end
				
			
		
			elseif enemiesSaved>0 and enemiesInList>0 then
				local Qd
				local QdCompare
				for i,enemy in pairs(enemyList) do
					if enemy~=nil and enemy.dead~=1 then
						if QdCompare==nil and GetD(enemy)<1000 then
							target=enemy
							QdCompare=(target.health)/(CalcMagicDamage(target,2*(20 + (20 * GetSpellLevel('Q')) + (myHero.ap * 0.3))))
						elseif GetD(enemy)<1000 then
							Qd=(enemy.health)/(CalcMagicDamage(enemy,2*(20 + (20 * GetSpellLevel('Q')) + (myHero.ap * 0.3))))
							if QdCompare>Qd then
								QdCompare=nil
								target=enemy
							end
						end
				
					end
				end
			
				--if EXH~=nil then
				--	CastSpellTarget('EXH',target)
				--end
				UseAllItems(target)
				if QRDY==1 and Ghost==false and GetD(target) <870 then
					qDoubleDmg(target)
				elseif Ghost==true and ghosttarget~=nil then
					qDoubleDmg(ghosttarget)
				end
		
				if WRDY==1 and Ghost==false and GetD(target) <1000 then
					CastSpellXYZ('W',GetFireahead(target,6,0))
				elseif Ghost==true and ghosttarget~=nil then
					CastSpellXYZ('W',GetFireahead(ghosttarget,6,0))
				end
		
				if ERDY==1 and Etoggle==false and Ghost==false and (GetD(target)<475 or numberEnemies>0) then
					CastSpellTarget('E',target)
					--Etoggle=true
				elseif Ghost==true and Etoggle==false and ghosttarget~=nil then
					CastSpellTarget('E',ghosttarget)
				end
		
				if ERDY==1 and Etoggle==true and Ghost==false and GetD(target)>475 and numberEnemies==0 then
					CastSpellTarget('E',target)
					MoveToXYZ(GetFireahead(target,1,0))
					--Etoggle=false
				end
		
				if Ghost==false and  GetD(target)<600 then
					UseAllItems(target)
				elseif Ghost==true and ghosttarget~=nil then
					UseAllItems(ghosttarget)
				end
			
				if Ghost==false and GetD(target)<500 then
					AttackTarget(target)
				end

				if Ghost==true then
					if ghosttarget~=nil then
					CastSpellXYZ('W',GetFireahead(ghosttarget,6,0))
					qDoubleDmg(ghosttarget)
					end
					deathR()
					if ghostultTimer<os.clock() then
						if RRDY==1 then CastSpellTarget('R',myHero) end
						Ghost=false
					end
				end
			
			elseif enemiesSaved==0 then
			
				--if EXH~=nil then
				--	CastSpellTarget('EXH',target)
				--end
				UseAllItems(target)		
				if QRDY==1 and Ghost==false and GetD(target) <870 then
					qDoubleDmg(target)
				elseif Ghost==true and ghosttarget~=nil then
					qDoubleDmg(ghosttarget)
				end
		
				if WRDY==1 and Ghost==false and GetD(target) <1000 then
					CastSpellXYZ('W',GetFireahead(target,6,0))
				elseif Ghost==true and ghosttarget~=nil then
					CastSpellXYZ('W',GetFireahead(ghosttarget,6,0))
				end
		
				if ERDY==1 and Etoggle==false and Ghost==false and (GetD(target)<475 or numberEnemies>0) then
					CastSpellTarget('E',target)
					--Etoggle=true
				elseif Ghost==true and ghosttarget~=nil and Etoggle==false then
					CastSpellTarget('E',ghosttarget)
				end
			
				if ERDY==1 and Etoggle==true and Ghost==false and GetD(target)>475 and numberEnemies==0 then
					CastSpellTarget('E',target)
					MoveToXYZ(GetFireahead(target,1,0))
					--Etoggle=false
				end
		
				if Ghost==false and GetD(target)<600 then
					UseAllItems(target)
				elseif Ghost==true and ghosttarget~=nil then
					UseAllItems(ghosttarget)
				end
			
				if Ghost==false and GetD(target)<500 then
					AttackTarget(target)
				end
				
				if Ghost==true then
					if ghosttarget~=nil then
					CastSpellXYZ('W',GetFireahead(ghosttarget,6,0))
					qDoubleDmg(ghosttarget)
					end
					deathR()
					if ghostultTimer<os.clock() then
						if RRDY==1 then CastSpellTarget('R',myHero) end
						Ghost=false
					end
				end
			end
			
			if Ghost==true then
			
					if ghosttarget~=nil then
					CastSpellXYZ('W',GetFireahead(ghosttarget,6,0))
					qDoubleDmg(ghosttarget)
					end
			
				if ghostultTimer<os.clock() then
					if RRDY==1 then CastSpellTarget('R',myHero) end
					Ghost=false
				end
			end
		else
				--if EXH~=nil then
				--	CastSpellTarget('EXH',target)
				--end
				
			if QRDY==1 and Ghost==false and GetD(target) <970 then
				qDoubleDmg(target)
			elseif Ghost==true and ghosttarget~=nil then
				qDoubleDmg(ghosttarget)
			end
		
			if WRDY==1 and Ghost==false and GetD(target) <1000 then
				CastSpellXYZ('W',GetFireahead(target,6,0))
			elseif Ghost==true and ghosttarget~=nil then
				CastSpellXYZ('W',GetFireahead(ghosttarget,6,0))
			end
		
			if ERDY==1 and Etoggle==false and Ghost==false and (GetD(target)<475 or numberEnemies>0) then
				CastSpellTarget('E',target)
				--Etoggle=true
			elseif Ghost==true and ghosttarget~=nil and Etoggle==false then
				CastSpellTarget('E',ghosttarget)
			end
			
			if ERDY==1 and Etoggle==true and Ghost==false and GetD(target)>475 and numberEnemies==0 then
				CastSpellTarget('E',target)
					MoveToXYZ(GetFireahead(target,1,0))
				--Etoggle=false
			end
		
			if Ghost==false and GetD(target)<600 then
				UseAllItems(target)
			elseif Ghost==true and ghosttarget~=nil then
				UseAllItems(ghosttarget)
			end
			
			if Ghost==false and GetD(target)<500 then
				AttackTarget(target)
			end
				if Ghost==true then
					if ghosttarget~=nil then
					CastSpellXYZ('W',GetFireahead(ghosttarget,6,0))
					qDoubleDmg(ghosttarget)
					end
					deathR()
					if ghostultTimer<os.clock() then
						if RRDY==1 then CastSpellTarget('R',myHero) end
						Ghost=false
					end
				end
		end
	else
		MoveToMouse()
		
		if ERDY==1 and Etoggle==true and Ghost==false then
				CastSpellTarget('E',myHero)
				--Etoggle=false
		end
		
		if Ghost==true then
					if ghosttarget~=nil then
					CastSpellXYZ('W',GetFireahead(ghosttarget,6,0))
					qDoubleDmg(ghosttarget)
					end
			if ghostultTimer<os.clock() then
				if RRDY==1 then CastSpellTarget('R',myHero) end
				Ghost=false
			end
		end
		
	end
end


function autoQ()
	if target~=nil and GetD(tqfa)<850 then
		qDoubleDmg(target)
	
	--elseif target~=nil and GetD(tqfa)>=700 and GetD(tqfa)>875 then
		--if QRDY==1 then CastSpellTarget('Q',target) end
	end
end

function autoE()
	if targetE~=nil then
		if ERDY==1 and Etoggle==false then
			CastSpellTarget('E',myHero)
			--Etoggle=true
		end
	elseif target~=nil then
		
		if ERDY==1 and Etoggle==true and GetD(target,myHero)>=475 then
			CastSpellTarget('E',myHero)
			--Etoggle=false
		end
	

	end
end

function autoR() ------------------------------------------------------------------------------------------------------
	if RRDY==1 and myHero.mana>125+(25)*myHero.SpellLevelR then
	findMIA()
	local safe=true
	local stop=false
	for i=1, objManager:GetMaxHeroes(), 1 do
		hero = objManager:GetHero(i)
		local allies={}
		local R = getDmg("R",hero,myHero)*RRDY
		local LE 
		if hero~=nil and hero.dead~=1 and LEMIA[hero.name]~=nil then LE=LEMIA[hero.name] end
		local LER 
		if hero~=nil and hero.dead~=1 and LowEnemyRecalling[hero.name]~=nil and LowEnemyRecalling[hero.name].timestarted~=nil then LER=LowEnemyRecalling[hero.name] end
		if hero~=nil and hero.dead~=1 and hero.team~=myHero.team and hero.health+4+(hero.selflevel/2)<R and (hero.visible==1 or (LE~=nil and LE.missing==true)) then			
			
			for j=1, objManager:GetMaxHeroes(), 1 do
				herocheckD = objManager:GetHero(j)
				if herocheckD~=nil and herocheckD.dead~=1 and herocheckD.visible==1 and herocheckD.team~=myHero.team and Ghost==false then
					if GetD(herocheckD,myHero)<1200 then
						for i,tower in ipairs(allySpawn) do				
							MoveToXYZ(tower.object.x,tower.object.y,tower.object.z)
							safe=false
							stop=true
							break
						end					
					else
						--stop=true
						if stop==true then
							StopMove()
							stop=false
						end					
						safe=true						
					end					
				end	
				if herocheckD~=nil and (herocheckD.dead==1 or herocheckD.visible==0) and herocheckD.team~=myHero.team and Ghost==false then
						if stop==true then
							StopMove()
							stop=false
						end					
						safe=true
				end
				if herocheckD~=nil and herocheckD.dead~=1 and herocheckD.team==myHero.team and allies[herocheckD.name]==nil and herocheckD.name~=myHero.name then
					allies[herocheckD.name]=herocheckD
				elseif herocheckD~=nil and herocheckD.team==myHero.team and herocheckD.name~=myHero.name and allies[herocheckD.name]~=nil and (herocheckD.dead==1) then
					allies[herocheckD.name]=nil
				end
			end
					
			local allyInRange=false
			for j,ally in pairs(allies) do 
				if ally~=nil and ally.dead~=1 and GetD(ally,hero)<800 then
					allyInRange=true
					break
				end		
			end
			if (allyInRange==false and hero.visible==1) or (LE~=nil and LE.missing==true and hero.health+10+hero.selflevel<R) or (LER~=nil and os.clock()<LER.timestarted+3) and safe==true then
				CastSpellTarget('R',myHero)
				break
			end
		end
	end
	end
end


function deathR()
	if Ghost==true then
		if RRDY==1 then
			if ghostultTimer<os.clock() then
					CastSpellTarget('R',myHero) 
					Ghost=false
				
			end
		end
		if ghostultTimer<os.clock() then
			Ghost=false
		end
	end
end

function LowWarn()
	local lowEnemies={}
	local lowEnemy=false
	for i=1, objManager:GetMaxHeroes(), 1 do
		hero = objManager:GetHero(i)
		local R = getDmg("R",hero,myHero)
        if hero~=nil and hero.team~=myHero.team and hero.dead~=1 and lowEnemies[hero.name]==nil and hero.health<R then
			lowEnemies[hero.name]=hero
			lowEnemy=true	
		end
	end
	if lowEnemy==true then
		local positionText = 10
		local multipleenemiesCheck = 0
		local textColor
		
		if colorCheck<19 then
			textColor = Color.White
		elseif colorCheck>=19 then
			textColor = Color.Red
		end
		
		local textColor2
		if colorCheck2<19 then
			textColor2 = Color.Red
		elseif colorCheck2>=19 then
			textColor2 = Color.White
		end
		
		local LE =nil
		
		
		--textflashtimer=os.clock()
		for i,enemy in pairs(lowEnemies) do 
			if enemy~=nil and enemy.dead~=1 and LEMIA[enemy.name]~=nil then LE=LEMIA[enemy.name] end
			if enemy~=nil and enemy.dead~=1 and multipleenemiesCheck==0 and (enemy.visible==1 or (LEMIA[enemy.name]~=nil and LE.missing==true))then
				DrawText("LOW ENEMY: "..enemy.name .. "", 800, positionText, textColor)
				
				positionText=positionText+13
				multipleenemiesCheck = (multipleenemiesCheck+1)%2
			elseif enemy~=nil and enemy.dead~=1 and multipleenemiesCheck==1 and (enemy.visible==1 or (LEMIA[enemy.name]~=nil and LE.missing==true)) then
				DrawText("LOW ENEMY: "..enemy.name .. "", 800, positionText, textColor2)

				positionText=positionText+13
				multipleenemiesCheck = (multipleenemiesCheck+1)%2			
			end
		end	
		
			colorCheck = (colorCheck+1)%40
			colorCheck2 = (colorCheck2+1)%40
		
	end
end

function OnDraw()
		CustomCircle(975,6,4,myHero)
		CustomCircle(525,8,1,myHero)
		
	if target~=nil and ghost==false then
		CustomCircle(100,4,2,target)
	elseif ghosttarget~=nil then
		CustomCircle(100,4,2,ghosttarget)
	end
		
    if KarthConfig.farm == true then
        DrawText("Auto Farm: On", 100, 30, 0xFF00FF00)
		if target==nil or (target~= nil and GetD(target)>700) or KarthConfig.dfarm == false then
            for i,minion in ipairs(minions) do 
				if minion~=nil then
					if minion~=nil and minion ~= miniontarget and minion.dead~=1  then
						CustomCircle(minionRadius, 2,3,minion)
					elseif miniontarget ~= nil and minion == miniontarget and miniontarget.dead~=1 then
						CustomCircle(minionRadius, 5,2,miniontarget)
						DrawCircle(lastHitSpot.x, lastHitSpot.y, lastHitSpot.z, spellRadius, 5)
					end
				end
            end
		end
		if target~= nil and GetD(target)<700 and KarthConfig.dfarm == true and target.dead~=1 then
			CustomCircle(minionRadius, 5,3,target)
			DrawCircle(QSpot.x, QSpot.y, QSpot.z, spellRadius, 2)
		end
    else
        DrawText("Auto Farm: Off", 100, 30, 0xFFFF0000)
    end
    
end


function killsteal()
	if target~=nil and target.dead~=1 then
		local ksSpot = {x=0,y=0,z=0,single=0}
		local DQ = getDmg("Q",target,myHero)*QRDY
		local Q = getDmg("Q",target,myHero)*QRDY/2
		local E = getDmg("E",target,myHero)*ERDY
		
		if target.health<Q+E+ignitedamage and GetD(target)<475 then
			if QRDY==1 then CastSpellXYZ('Q',GetFireahead(target,6,0)) end
			if ERDY==1 and Etoggle==false then CastSpellTarget('E',target) end
			if ignitedamage~=0 then CastSpellTarget(IGN,target) end
		end
		
		if target.health<Q and GetD(tqfa)<870 then
			if QRDY==1 then CastSpellXYZ('Q',GetFireahead(target,6,0)) end
		end
		
		if target.health<DQ and GetD(tqfa)<870 then
			qDoubleDmg(target)
		end
		
		if target.health<Q+ignitedamage and GetD(tqfa)<600 then
			if QRDY==1 then CastSpellXYZ('Q',GetFireahead(target,6,0)) end
			if ignitedamage~=0 then CastSpellTarget(IGN,target) end
		end
		
		if target.health<DQ+ignitedamage and GetD(target)<600 then
			if QRDY==1 then qDoubleDmg(target) end
			if ignitedamage~=0 then CastSpellTarget(IGN,target) end
		end
		
		if target.health<DQ+E+ignitedamage and GetD(target)<475 then
			if QRDY==1 then qDoubleDmg(target) end
			if ERDY==1 and Etoggle==false then CastSpellTarget('E',target) end
			if ignitedamage~=0 then CastSpellTarget(IGN,target) end		
		end
	
	end
end


function findMIA()
	
	for k=1, objManager:GetMaxHeroes(), 1 do
		local object = objManager:GetHero(k)
		if object.team ~= myHero.team and object.dead == 0 then
			if not LEMIA[object.name] then 
				LEMIA[object.name] = {missing = true, lastVisible = 0, object = object} 
			end
			local enemy = LEMIA[object.name]
			if object.visible == 1 then
				enemy.missing = false
				enemy.lastVisible = os.clock()
				
			elseif (os.clock() > LEMIA[object.name].lastVisible+2) and (os.clock() < LEMIA[object.name].lastVisible + 8) then
				enemy.missing = true
			else 
				enemy.missing = false
			end	
			
		end
	end
	
end
	
function findTurret()
	runeverycc=runeverycc+1	
	allyTurrets={}
	allySpawn={}
	
	for i=1, objManager:GetMaxObjects(), 1 do
		local object = objManager:GetObject(i)
		if map == "SummonersRift" then
			if object ~= nil  and object.charName ~= nil then
				if myHero.team==200 then
					for i,tower in ipairs(SpawnturretR) do
						if object.charName == tower then
							turret = {range=1600,color=2,object=object}
							table.insert(allySpawn,turret) 
						end
					end
					for i,tower in ipairs(TurretsR) do
						if object.charName == tower then
							turret = {range=1020,color=2,object=object}
							table.insert(allyTurrets,turret) 

						end
					end								
				end
				if myHero.team==100 then			
					for i,tower in ipairs(SpawnturretB) do
						if object.charName == tower then
							turret = {range=1600,color=3,object=object}
							table.insert(allySpawn,turret) 

						end
					end

					for i,tower in ipairs(TurretsB) do
						if object.charName == tower then
							turret = {range=1020,color=3,object=object}
							table.insert(allyTurrets,turret) 

						end
					end
				end
			end
			
		elseif map == "ProvingGrounds" then
			if object ~= nil and object.charName ~= nil then
				if myHero.team==200 then
					for i,tower in ipairs(SpawnturretR) do
						if object.charName == tower then
							turret = {range=1300,color=2,object=object}
							table.insert(allySpawn,turret) 

						end
					end

					for i,tower in ipairs(TurretsR) do
						if object.charName == tower then
							turret = {range=1020,color=2,object=object}
							table.insert(allyTurrets,turret) 

						end
					end
				end
				if myHero.team==100 then	
					for i,tower in ipairs(SpawnturretB) do
						if object.charName == tower then
							turret = {range=1300,color=3,object=object}
							table.insert(allySpawn,turret) 

						end
					end
					for i,tower in ipairs(TurretsB) do
						if object.charName == tower then
							turret = {range=1020,color=3,object=object}
							table.insert(allyTurrets,turret) 

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
							table.insert(allySpawn,turret) 

						end
					end
					for i,tower in ipairs(TurretsR) do
						if object.charName == tower then
							turret = {range=750,color=5,object=object}
							table.insert(allyTurrets,turret) 

						end
					end		
				end	
				if myHero.team==100 then
					for i,tower in ipairs(SpawnturretB) do
						if object.charName == tower then
							turret = {range=1820,color=3,object=object}
							table.insert(allySpawn,turret) 

						end
					end
					for i,tower in ipairs(TurretsB) do
						if object.charName == tower then
							turret = {range=750,color=5,object=object}
							table.insert(allyTurrets,turret) 

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
							table.insert(allySpawn,turret) 

						end
					end            
					for i,tower in ipairs(TurretsR) do
						if object.charName == tower then
							turret = {range=1020,color=2,object=object}
							table.insert(allyTurrets,turret) 

						end
					end
				end	
				if myHero.team==100 then
					for i,tower in ipairs(SpawnturretB) do
						if object.charName == tower then
							turret = {range=1550,color=3,object=object}
							table.insert(allySpawn,turret) 

						end
					end

					for i,tower in ipairs(TurretsB) do
						if object.charName == tower then
							turret = {range=1020,color=3,object=object}
							table.insert(allyTurrets,turret) 

						end
					end
				end
			end
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