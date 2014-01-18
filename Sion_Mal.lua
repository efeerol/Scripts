require "Utils"
require 'spell_damage'
print=printtext
printtext("\nGeneral Sion Sayonara\n")
printtext("\nBy Malbert\n")
printtext("\nVersion 2.1\n")

local target
local hasSheen = 0
local hasLich = 0
local hasTrinity = 0
local hasIceBorn = 0
local WmaxDistance
local WDistance
local MS
local outerwdraw=true
local wpressed=false
local Wrangeindex
local Etoggle = false
local Mhp=myHero.maxHealth	
local ignitedamage
local wbegin=os.clock()
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



	SionConfig = scriptConfig('Sion Config', 'Sionconfig')
	
	SionConfig:addParam('stun', 'StunTheCarry', SCRIPT_PARAM_ONKEYDOWN, false, 65)
	SionConfig:addParam('teamfight', 'AutoTeamFight', SCRIPT_PARAM_ONKEYDOWN, false, 84)
	SionConfig:addParam('farm', 'AutoCreepFarm', SCRIPT_PARAM_ONKEYTOGGLE, false, 57)
	SionConfig:addParam('dfarm', 'DefendFarm', SCRIPT_PARAM_ONKEYTOGGLE, false, 48)
	SionConfig:addParam('autoQ', 'AutoQ', SCRIPT_PARAM_ONKEYTOGGLE, false, 88)
	SionConfig:addParam('drawW', 'DrawWCast', SCRIPT_PARAM_ONOFF, true)
	SionConfig:addParam('dokillsteal', 'Killsteal', SCRIPT_PARAM_ONOFF, true)
	SionConfig:addParam('ap', 'AP Sion?', SCRIPT_PARAM_ONOFF, true)
	SionConfig:permaShow('autoQ')
	SionConfig:permaShow('farm')
	SionConfig:permaShow('teamfight')
	SionConfig:permaShow('dokillsteal')



function Run()
	MS = myHero.movespeed
	WmaxDistance = MS*10 + 550
	WDistance = MS*4 + 550	

	if SionConfig.ap then
	target = GetWeakEnemy('MAGIC',800)
	else
	target = GetWeakEnemy('PHYS',800)
	end
	
	
	if SionConfig.stun then stunrun() end
	if SionConfig.farm then autofarm() end
	if SionConfig.teamfight then fight() end
	if SionConfig.autoQ then autoQattack() end
	if SionConfig.drawW and not SionConfig.farm then drawDistW() end
	if SionConfig.dokillsteal then ignite() killsteal() end
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
		elseif myHero.SummonerD ~= 'SummonerDot' and myHero.SummonerF ~= 'SummonerDot' then
				ignitedamage=0
		end
end

function stunrun()

	if target ~= nil then
			UseAllItems(target)
			if CanCastSpell('Q') and GetDistance(myHero, target) < 550 then
				CastSpellTarget('Q', target)
			end

	end
	
	if target == nil then
		MoveToMouse()
	end
	
end





function OnCreateObj(obj)

	if GetDistance(obj,myHero) <10 then
	--printtext("\n"..obj.charName.."\n")
		if obj.charName:find("DeathsCaress_buf") then
			wpressed=true
			wbegin=os.clock()
			wend=10+os.clock()
			outerwdraw=false
			--WautoX()
		end
		if obj.charName:find("DeathsCaress_nova") then
			wpressed=false
			outerwdraw=true
		end
    end
	
end

function drawDistW()

	if CanCastSpell('W') and outerwdraw==true then
		CustomCircle(WmaxDistance,5,5,myHero)
		CustomCircle(WDistance,5,5,myHero)
		CustomCircle(550,5,2,myHero)
	end

	if wpressed==true then
	
		CustomCircle(550+MS*(wend-os.clock()),4,2,myHero)
		if (550+MS*(wbegin+4-os.clock()))>0 then
			CustomCircle(550+MS*(wbegin+4-os.clock()),4,2,myHero)
		end
		
		if outerwdraw==false and (os.clock()>wend) then
			outerwdraw=true
			wpressed=false
		end
		
	end

end


function WautoX()
--	if Whp+(100+(50*GetSpellLevel("W")))- Whp<50 then
--		CastSpellTarget('W', myHero)
--	end

end

function OnProcessSpell(unit, spell)
if unit.team==myHero.team and GetDistance(unit,myHero)<10 then
--printtext("\n"..spell.name.."\n")

	if spell.name=="Enrage" then
		if Etoggle==false then
			Etoggle=true
		else
			Etoggle=false
		end
	end
end
end

function autofarm()
if GetMap()==1 then
	findTurret()
	local farmrange=800
	local safe = true

		
		
	if SionConfig.dfarm then
				local tsafe=true
		if target~=nil and tsafe==true and GetDistance(target,myHero)<550 then

			if CanCastSpell('Q') then CastSpellTarget('Q', target) end
			if CanCastSpell('W') then CastSpellTarget('W', target) end
			for _,tur in ipairs(enemyTurrets) do
				if tur~=nil then
					if target~=nil and GetDistance(tur.object,target)>tur.range then
						tsafe=true
					elseif target~=nil and GetDistance(tur.object,mtarget)<tur.range then
						tsafe=false
					else
						tsafe=false
					end
				
					if tsafe==false then
						break
					end
				end
			end	
			if CanCastSpell('W') then CastSpellTarget('W', target) end		
			if tsafe==true then AttackTarget(target) end
		elseif tsafe==false or target==nil or (target~=nil and GetDistance(target,myHero)>550) then
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

				local AA = CalcDamage(mtarget,myHero.addDamage+myHero.baseDamage)
				local E = (15+(10*GetSpellLevel("E")))*CanUseSpell('E')
	

			
				local W	= (100+(50*GetSpellLevel('W'))+(myHero.ap*(9/10)))*CanUseSpell('W')

					if GetDistance(mtarget,myHero)>myHero.range+50 then
						MoveToXYZ(mtarget.x,0,mtarget.z)
		
						if mtarget.health<W then
							if wpressed==false then
								CastSpellTarget('W', mtarget)
							end
							if GetDistance(mtarget,myHero)<550 and CanUseSpell("W") and wpressed==true then
								CastSpellTarget('W', mtarget)
								if wpressed==true then wpressed =false end
							end
						end
		
					elseif GetDistance(mtarget,myHero)<=myHero.range+50 and mtarget.health<AA+E then
						if mtarget.health<AA+E then
							AttackTarget(mtarget)	
						end
						if  mtarget.health<W and CanUseSpell("W") then
							CastSpellTarget('W', mtarget)
						end
					end	
				end
			end
	
	
			if safe==false then StopMove() end
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

			local AA = CalcDamage(mtarget,myHero.addDamage+myHero.baseDamage)
			local E = (15+(10*GetSpellLevel("E")))*CanUseSpell('E')
	

			
			local W	= (100+(50*GetSpellLevel('W'))+(myHero.ap*(9/10)))*CanUseSpell('W')

				if GetDistance(mtarget,myHero)>myHero.range+50 then
					MoveToXYZ(mtarget.x,0,mtarget.z)
		
					if mtarget.health<W then
						if wpressed==false then
							CastSpellTarget('W', mtarget)
						end
						if GetDistance(mtarget,myHero)<550 and CanUseSpell("W") and wpressed==true then
							CastSpellTarget('W', mtarget)
							if wpressed==true then wpressed =false end
						end
					end
		
				elseif GetDistance(mtarget,myHero)<=myHero.range+50 and mtarget.health<AA+E then
					if mtarget.health<AA+E then
						AttackTarget(mtarget)	
					end
					if  mtarget.health<W and CanUseSpell("W") then
						CastSpellTarget('W', mtarget)
					end
				end	
			end
		end
	
	
		if safe==false then StopMove() end
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

function fight()
	if target ~= nil  then
			UseAllItems(target)
			if CanCastSpell('R') and GetDistance(myHero, target) < myHero.range+50 then
				CastSpellTarget('R', target)
				AttackTarget(target)
			end
			if CanCastSpell('E') and Etoggle==false and GetDistance(myHero, target) < myHero.range+50 then
				CastSpellTarget('E', target)
				AttackTarget(target)
				Etoggle=true
			end
			if CanCastSpell('Q') and GetDistance(myHero, target) < 550 then
				CastSpellTarget('Q', target)
				AttackTarget(target)
			end
			if CanCastSpell('W') and GetDistance(myHero, target) < 650 then
				CastSpellTarget('W', target)
				AttackTarget(target)
			end
			if GetDistance(myHero, target) < myHero.range+50 then
				AttackTarget(target)
			end
	end

	if target == nil then
	MoveToMouse()
	end
	
end

function autoQattack()

    if target ~= nil then
		if CanCastSpell('Q') and GetDistance(myHero, target) < 550 then
			CastSpellTarget('Q', target)
		end
    end

end

function killsteal()
	if target ~= nil then
		local E = CalcDamage(target,(15+(10*GetSpellLevel("E")))*CanUseSpell("E"))
		local AA = getDmg("AD",target,myHero)+(getDmg("SHEEN",target,myHero)*hasSheen)+(getDmg("LICHBANE",target,myHero)*hasLich)+(getDmg("ICEBORN",target,myHero)*hasIceBorn)+(getDmg("TRINITY",target,myHero)*hasTrinity)+E
		local Q = (getDmg("Q",target,myHero))*CanUseSpell("Q")
		local W	= getDmg("W",target,myHero)*CanUseSpell("W")
		
		--[[if target.health < (AA+Q+ignitedamage)*CanUseSpell("Q") then
			if CanCastSpell('E') and GetDistance(myHero, target) < myHero.range+50 and Etoggle==false then
				CastSpellTarget('E', target)
			end
			if GetDistance(myHero, target) < myHero.range+50 then
				AttackTarget(target)
			end
			if GetDistance(myHero, target) < 550 then
				CastSpellTarget('Q', target)
			end			
			if myHero.SummonerD == 'SummonerDot' then
				if CanCastSpell('D') then CastSpellTarget('D',target) end
			end
			if myHero.SummonerF == 'SummonerDot' then
				if CanCastSpell('F') then CastSpellTarget('F',target) end
			end				
			if (myHero.maxHealth*20/100)<myHero.health and GetDistance(myHero, target) < myHero.range+50 then
				CastSpellTarget('R', myHero)
			end
		end--]]

		if target.health < (Q+W+ignitedamage)*CanUseSpell("Q") then
			CustomCircle(650,6,5,myHero)
			if CanCastSpell('W') and GetDistance(myHero, target) < 650 then
				CastSpellTarget('W', target)
			end
			if GetDistance(myHero, target) < 650 then
				CastSpellTarget('Q', target)
			end
			if GetDistance(myHero, target) < myHero.range+100 then
				AttackTarget(target)
			end
			if CanCastSpell('E') and GetDistance(myHero, target) < myHero.range+100 and Etoggle==false then
				CastSpellTarget('E', target)
			end
			if myHero.SummonerD == 'SummonerDot' then
				if IsSpellReady('D') then CastSpellTarget('D',target) end
			end
			if myHero.SummonerF == 'SummonerDot' then
				if IsSpellReady('F') then CastSpellTarget('F',target) end
			end	
			if (myHero.maxHealth*20/100)<myHero.health and GetDistance(myHero, target) < myHero.range+100 then
				CastSpellTarget('R', myHero)
			end
		end
		
		if target.health < (W+Q+AA+ignitedamage)*CanUseSpell("Q") then
		
			CustomCircle(650,6,5,myHero)
			if CanCastSpell('W') and GetDistance(myHero, target) < 650 then
				CastSpellTarget('W', target)
			end
			if GetDistance(myHero, target) < 650 then
				CastSpellTarget('Q', target)
			end
			if (myHero.maxHealth*25/100)<myHero.health and GetDistance(myHero, target) < myHero.range+100 then
				CastSpellTarget('R', myHero)
			end
			if myHero.SummonerD == 'SummonerDot' then
				if IsSpellReady('D') then CastSpellTarget('D',target) end
			end
			if myHero.SummonerF == 'SummonerDot' then
				if IsSpellReady('F') then CastSpellTarget('F',target) end
			end	
			if GetDistance(myHero, target) < myHero.range+100 then
				AttackTarget(target)
			end
			if CanCastSpell('E') and GetDistance(myHero, target) < myHero.range+100 and Etoggle==false then
				CastSpellTarget('E', target)
			end
		end

		--[[if target.health < (Q+ignitedamage) then
			if GetDistance(myHero, target) < 550 then
				CastSpellTarget('Q', target)
			end
			if myHero.SummonerD == 'SummonerDot' then
				if IsSpellReady('D') then CastSpellTarget('D',target) end
			end
			if myHero.SummonerF == 'SummonerDot' then
				if IsSpellReady('F') then CastSpellTarget('F',target) end
			end	
		end	--]]		
		if target.health < (W+ignitedamage) and GetDistance(myHero, target) < 550 then

				CastSpellTarget('W', target)

			if myHero.SummonerD == 'SummonerDot' then
				if IsSpellReady('D') then CastSpellTarget('D',target) end
			end
			if myHero.SummonerF == 'SummonerDot' then
				if IsSpellReady('F') then CastSpellTarget('F',target) end
			end	
			if (myHero.maxHealth*25/100)<myHero.health and GetDistance(myHero, target) < myHero.range+100 then
				CastSpellTarget('R', myHero)
				AttackTarget(target)				
			end
		end
	end
	
end

function OnDraw()

    if myHero.dead == 0 then
		if CanUseSpell('Q') == 1 then
			CustomCircle(550,3,2,myHero)
		end	
		if CanUseSpell('W') == 1 then
			CustomCircle(550,6,6,myHero)
		end
    end
	
end





SetTimerCallback("Run")