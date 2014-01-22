require "Utils"
require 'spell_damage'
print=printtext
printtext("\nTime to start Pooping all over League\n")
printtext("\nBy Malbert\n")
printtext("\nVersion 2.0\n")

local target
local targetram
local targetult
local hasSheen = 0
local hasLich = 0
local hasTrinity = 0
local hasIceBorn = 0
local ignitedamage

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


	PoppyConfig = scriptConfig('Poppy Config', 'Poppyconfig')
	PoppyConfig:addParam('slam', 'Harass', SCRIPT_PARAM_ONKEYDOWN, false, 69)
	PoppyConfig:addParam('doingcombo', 'UltCombo', SCRIPT_PARAM_ONKEYDOWN, false, 88)
	PoppyConfig:addParam('teamfight', 'TeamFight', SCRIPT_PARAM_ONKEYDOWN, false, 84)
	PoppyConfig:addParam('farm', 'AutoCreepFarm', SCRIPT_PARAM_ONKEYTOGGLE, false, 67)
	PoppyConfig:addParam('dfarm', 'DefendFarm', SCRIPT_PARAM_ONKEYTOGGLE, false, 32)
	PoppyConfig:addParam('autoQ', 'AutoQ', SCRIPT_PARAM_ONKEYTOGGLE, true, 56)
	PoppyConfig:addParam('autoram', 'AutoWallRam', SCRIPT_PARAM_ONKEYTOGGLE, true, 57)
	PoppyConfig:addParam('dokillsteal', 'Killsteal', SCRIPT_PARAM_ONOFF, true)
	PoppyConfig:addParam('ad', 'Extreme AD Pop?', SCRIPT_PARAM_ONOFF, false)
	PoppyConfig:permaShow('autoQ')
	PoppyConfig:permaShow('farm')
	PoppyConfig:permaShow('autoram')
	PoppyConfig:permaShow('dokillsteal')


function Run()

	if PoppyConfig.ad then
	target = GetWeakEnemy('PHYS',900)
	else
	target = GetWeakEnemy('MAGIC',900)
	end
	targetram = GetWeakEnemy('MAGIC',1200)
	ignite()
	Draw()

	if PoppyConfig.autoQ then autoQattack() end
	if PoppyConfig.slam then slamattack() end
	if PoppyConfig.doingcombo then combo() end
	if PoppyConfig.teamfight then fight() end
	if PoppyConfig.farm then autofarm() end
	if PoppyConfig.autoram then ram() end
	if PoppyConfig.dokillsteal then killsteal() end
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

function ignite()
		if myHero.SummonerD == 'SummonerDot' then
			ignitedamage = ((myHero.selflevel*20)+50)*IsSpellReady('D')
		elseif myHero.SummonerF == 'SummonerDot' then
				ignitedamage = ((myHero.selflevel*20)+50)*IsSpellReady('F')
		else
				ignitedamage=0
		end
end

function slamattack()

	if target ~= nil then
			if CanCastSpell('E') and GetDistance(myHero, target) < 525 then
				CastSpellTarget('E', target)
				AttackTarget(target)
			end
			if CanCastSpell('Q') and GetDistance(myHero, target) < 250 then
				CastSpellTarget('Q', target)
				AttackTarget(target)
			end
			if CanCastSpell('W') and GetDistance(myHero, target) < 250 then
				CastSpellTarget('W', target)
				AttackTarget(target)
			end
			--if GetDistance(myHero, target) < myHero.range then
				AttackTarget(target)
			--end
	end
	
	if target == nil then
		MoveToMouse()
	end
	
end


function combo()

	if target ~= nil then
			UseAllItems(target)
			if CanCastSpell('R') and GetDistance(myHero, target) < 900 then
				CastSpellTarget('R', target)
			end
			if CanCastSpell('E') and GetDistance(myHero, target) < 525 then
				CastSpellTarget('E', target)
				AttackTarget(target)
			end
			if CanCastSpell('Q') and GetDistance(myHero, target) < 250 then
				CastSpellTarget('Q', target)
				AttackTarget(target)
			end
			if CanCastSpell('W') and GetDistance(myHero, target) < 250 then
				CastSpellTarget('W', target)
				AttackTarget(target)
			end

				AttackTarget(target)

	end
	
	if target == nil then
		MoveToMouse()
	end
	
end


function fight()
	findUlt()
	if target ~= nil and targetult ~= nil then
			UseAllItems(target)
			if CanCastSpell('R') and GetDistance(myHero, targetult) < 900 then
				CastSpellTarget('R', targetult)
			end
			if CanCastSpell('E') and GetDistance(myHero, target) < 525 then
				CastSpellTarget('E', target)
				AttackTarget(target)
			end
			if CanCastSpell('Q') and GetDistance(myHero, target) < 250 then
				CastSpellTarget('Q', target)
				AttackTarget(target)
			end
			if CanCastSpell('W') and GetDistance(myHero, target) < 250 then
				CastSpellTarget('W', target)
				AttackTarget(target)
			end

				AttackTarget(target)

	end

	if target == nil or targetult == nil then
		MoveToMouse()
	end
	
	
end




function findUlt()
	targetult=nil
	for j = 1, objManager:GetMaxHeroes(), 1 do
		local h=objManager:GetHero(j)
		if (h~=nil and h.team~=myHero.team and h.visible==1 and h.invulnerable==0 and (GetDistance(myHero,h)<1000)) then
			if targetult == nil then
				targetult=h
				--printtext("\n" ..targetult.name.."\n")
			else
				--printtext("\n" ..targetult.name.."\n")
				if ((targetult.addDamage+targetult.ap)>(h.addDamage+h.ap)) then
					targetult=h
				end				
				--printtext("\n" ..(h.name).."\n")
			end
		end
	end
	

end



function autoQattack()

    if target ~= nil then
		if CanCastSpell('Q') and GetDistance(myHero, target) < 250 then
			CastSpellTarget('Q', target)
			AttackTarget(target)
		end
    end

end


function ram()

    if targetram ~= nil then
		if WillHitWall(targetram,300) == 1 and (GetDistance(myHero, targetram) < 525) then
			CastSpellTarget("E", targetram)
		end
    end

end


function killsteal()
	if target ~= nil then
		local NQ
		if CanUseSpell('Q')==0 then NQ= 1 else NQ= 0 end
		local AA = getDmg("AD",target,myHero)*(NQ)
		local Q = (getDmg("Q",target,myHero)+(getDmg("SHEEN",target,myHero)*hasSheen)+(getDmg("LICHBANE",target,myHero)*hasLich)+(getDmg("ICEBORN",target,myHero)*hasIceBorn)+(getDmg("TRINITY",target,myHero)*hasTrinity))*CanUseSpell("Q")
		local E	= (getDmg("E",target,myHero,1)+((getDmg("SHEEN",target,myHero)*hasSheen)+(getDmg("LICHBANE",target,myHero)*hasLich)+(getDmg("ICEBORN",target,myHero)*hasIceBorn)+(getDmg("TRINITY",target,myHero)*hasTrinity))*(NQ))*CanUseSpell("E")

		local Eram	= (getDmg("E",target,myHero,3)+((getDmg("SHEEN",target,myHero)*hasSheen)+(getDmg("LICHBANE",target,myHero)*hasLich)+(getDmg("ICEBORN",target,myHero)*hasIceBorn)+(getDmg("TRINITY",target,myHero)*hasTrinity))*(NQ))*CanUseSpell("E")
		
		if target.health < (AA+Q+E+ignitedamage)*CanUseSpell("E") then
			if CanCastSpell('E') and GetDistance(myHero, target) < 525 then
				CastSpellTarget('E', target)
			end
			if GetDistance(myHero, target) < 250 then
				AttackTarget(target)
			end
			if GetDistance(myHero, target) < 250 then
				CastSpellTarget('Q', target)
			end
			if CanCastSpell('R') and targetult~=nil and GetDistance(targetult)<900 and myHero.health<myHero.maxHealth*20/100 then
				CastSpellTarget('R', targetult)
			end
			if myHero.SummonerD == 'SummonerDot' then
				if IsSpellReady('D') and GetDistance(target)<600 then CastSpellTarget('D',target) end
			end
			if myHero.SummonerF == 'SummonerDot' then
				if IsSpellReady('F') and GetDistance(target)<600 then CastSpellTarget('F',target) end
			end
		end
		
		if targetram.health < (Eram+Q+AA+ignitedamage)*CanUseSpell("E") and WillHitWall(targetram,300) == 1 then
			if CanCastSpell('E') and GetDistance(myHero, target) < 525 then
				CastSpellTarget('E', target)
			end
			if GetDistance(myHero, target) < 250 then
				AttackTarget(target)
			end
			if GetDistance(myHero, target) < 250 then
				CastSpellTarget('Q', target)
			end
			if CanCastSpell('R') and targetult~=nil and GetDistance(targetult)<900 and myHero.health<myHero.maxHealth*20/100 then
				CastSpellTarget('R', targetult)
			end	
			if myHero.SummonerD == 'SummonerDot' then
				if IsSpellReady('D') and GetDistance(target)<600 then CastSpellTarget('D',target) end
			end
			if myHero.SummonerF == 'SummonerDot' then
				if IsSpellReady('F') and GetDistance(target)<600 then CastSpellTarget('F',target) end
			end			
		end
		

		if target.health < (Q+ignitedamage+AA) and GetDistance(myHero, target) > 250 then
							CastSpellTarget('W', target)
			if GetDistance(myHero, target) < 250 then

				CastSpellTarget('Q', target)
				CastSpellTarget('W', target)

			if myHero.SummonerD == 'SummonerDot' then
				if IsSpellReady('D') and GetDistance(target)<600 then CastSpellTarget('D',target) end
			end
			if myHero.SummonerF == 'SummonerDot' then
				if IsSpellReady('F') and GetDistance(target)<600 then CastSpellTarget('F',target) end
			end				
				AttackTarget(target)
		end
		end
		
		if target.health < ignitedamage and GetDistance(target)<600 then
			if myHero.SummonerD == 'SummonerDot' then
				if IsSpellReady('D') then CastSpellTarget('D',target) end
			end
			if myHero.SummonerF == 'SummonerDot' then
				if IsSpellReady('F') then CastSpellTarget('F',target) end
			end	
		end			
		
	end
end




function Draw()
    if myHero.dead == 0 then
		if CanUseSpell('Q') == 1 then
			CustomCircle(250,4,2,myHero)
		end
		if CanUseSpell('R') == 1 then
			CustomCircle(900,6,3,myHero)
		end

					local perimetercheckx
					local perimetercheckz							
		for i = 1, objManager:GetMaxHeroes(), 1 do
        	local obj = objManager:GetHero(i)
			if obj~=nil and obj.team~=myHero.team and GetDistance(obj,myHero)<2000 then
				for j=0, 11, 1 do
					perimetercheckx = 300*(math.cos(j*math.pi/6))+obj.x
					perimetercheckz = 300*(math.sin(j*math.pi/6))+obj.z
					--printtext("\nx " .. perimetercheckx .. "")
					--printtext("\nz " .. perimetercheckz .. "")
					--printtext("\nX " .. obj.x .. "")
					--printtext("\nY " .. obj.y .. "")
					--printtext("\nZ " .. obj.z .. "\n")
					if IsWall(perimetercheckx,obj.y,perimetercheckz)==1 then
						CustomCircle(300,2,5,obj)
									if WillHitWall(obj,300) == 1 then
										CustomCircle(300,6,3,obj)
									end
						break
					end
				end
			end
		end
		if targetram ~= nil then
			if WillHitWall(targetram,300) == 1 then
				CustomCircle(300,6,1,targetram)
			end
		end	
    end
end

function autofarm()
if GetMap()==1 then
	findTurret()
	local farmrange=800
	local safe = true

		
		
	if PoppyConfig.dfarm then
				local tsafe=true
		if target~=nil and tsafe==true and GetDistance(target,myHero)<250 then

			if CanCastSpell('Q') then CastSpellTarget('Q', target) end
			if CanCastSpell('W') then CastSpellTarget('W', target) end
			for _,tur in ipairs(enemyTurrets) do
				if tur~=nil then
					if target~=nil and GetDistance(tur.object,target)>tur.range then
						tsafe=true
					elseif target~=nil and GetDistance(tur.object,target)<tur.range then
						tsafe=false
					else
						tsafe=false
					end
				
					if tsafe==false then
						break
					end
				end
			end		
			if tsafe==true then AttackTarget(target) end
		elseif tsafe==false or target==nil or (target~=nil and GetDistance(target,myHero)>250) then
			if safe==true then
				for _,tur in ipairs(enemyTurrets) do
				if tur~=nil then
					mtarget=GetLowestHealthEnemyMinion(farmrange)
		
					if mtarget~=nil and GetDistance(tur.object,mtarget)>tur.range then
						safe=true
					elseif mtarget~=nil and GetDistance(tur.object,mtarget)<tur.range and farmrange>0 then
						while ((GetDistance(tur.object,mtarget)<tur.range) and (farmrange>0) and mtarget~=nil) do
							farmrange=farmrange-50		
							mtarget=GetLowestHealthEnemyMinion(farmrange)
						end
						if (farmrange==0 or mtarget==nil) then
							safe=false
						else
							safe=true
						end
					else
						safe=false
					end
					if safe==false then
						break
					end
				end
				end
				if mtarget~=nil then

				local W	= (10+(5*GetSpellLevel('W')))*CanUseSpell('W')
				local AA = CalcDamage(mtarget,myHero.addDamage+myHero.baseDamage)+W
				local QT 
				if 8/100*mtarget.maxHealth > 75*GetSpellLevel("Q") then QT= 75*GetSpellLevel("Q") else QT= 8/100*mtarget.maxHealth end
				local Q = CalcMagicDamage(mtarget,(20*GetSpellLevel("Q"))+(myHero.addDamage+myHero.baseDamage)+(6/10*myHero.ap)+(QT)+(getDmg("SHEEN",mtarget,myHero)*hasSheen)+(getDmg("LICHBANE",mtarget,myHero)*hasLich)+(getDmg("ICEBORN",mtarget,myHero)*hasIceBorn)+(getDmg("TRINITY",mtarget,myHero)*hasTrinity))*CanUseSpell('Q')
	

			

					if GetDistance(mtarget,myHero)>myHero.range+100 then
						MoveToXYZ(mtarget.x,0,mtarget.z)
		
					elseif GetDistance(mtarget,myHero)<=myHero.range+100 and mtarget.health<AA+Q then
						CastSpellTarget('W', mtarget)
						CastSpellTarget('Q', mtarget)
						AttackTarget(mtarget)	
					end
				end
			end
	
	
			if safe==false and mtarget~=nil then StopMove() 
			end
		end	
	else
		if safe==true then
		for _,tur in ipairs(enemyTurrets) do
			if tur~=nil then
				mtarget=GetLowestHealthEnemyMinion(farmrange)
		
				if mtarget~=nil and GetDistance(tur.object,mtarget)>tur.range then
					safe=true
				elseif mtarget~=nil and GetDistance(tur.object,mtarget)<tur.range and farmrange>0 then
					while ((GetDistance(tur.object,mtarget)<tur.range) and (farmrange>0) and mtarget~=nil) do
						farmrange=farmrange-50		
						mtarget=GetLowestHealthEnemyMinion(farmrange)
					end
					if (farmrange==0 or mtarget==nil) then
						safe=false
					else
						safe=true
					end
				else
					safe=false
				end
				if safe==false then
				break
				end
			end
		end
				if mtarget~=nil then

				local W	= (10+(5*GetSpellLevel('W')))*CanUseSpell('W')
				local AA = CalcDamage(mtarget,myHero.addDamage+myHero.baseDamage)+W
				local QT 
				if 8/100*mtarget.maxHealth > 75*GetSpellLevel("Q") then QT= 75*GetSpellLevel("Q") else QT= 8/100*mtarget.maxHealth end
				local Q = CalcMagicDamage(mtarget,(20*GetSpellLevel("Q"))+(myHero.addDamage+myHero.baseDamage)+(6/10*myHero.ap)+(QT)+(getDmg("SHEEN",mtarget,myHero)*hasSheen)+(getDmg("LICHBANE",mtarget,myHero)*hasLich)+(getDmg("ICEBORN",mtarget,myHero)*hasIceBorn)+(getDmg("TRINITY",mtarget,myHero)*hasTrinity))*CanUseSpell('Q')
	

			

					if GetDistance(mtarget,myHero)>myHero.range+100 then
						MoveToXYZ(mtarget.x,0,mtarget.z)
		
					elseif GetDistance(mtarget,myHero)<=myHero.range+100 and mtarget.health<AA+Q then
						CastSpellTarget('W', mtarget)
						CastSpellTarget('Q', mtarget)
						AttackTarget(mtarget)	
					end
				end
			end
	
	
		if safe==false and mtarget~=nil then StopMove() 
		end
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
		

    end
end

end


SetTimerCallback("Run")