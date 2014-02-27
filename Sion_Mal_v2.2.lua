require "Utils"
require 'spell_damage'
print=printtext
printtext("\nGeneral Sion Sayonara\n")
printtext("\nBy Malbert\n")
printtext("\nVersion 2.2\n")

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


local QRDY=0
local WRDY=0
local ERDY=0
local RRDY=0

local DFG=3128
local targetItems={3144,3153,3128,3092,3146}
--Bilgewater,BoTRK,DFG,FrostQueen,Hextech
local aoeItems={3184,3143,3180,3131,3069,3023,3290,3142}
--Entropy,Randuins,Odyns,SwordDivine,TalismanAsc,TwinShadows,TwinShadows,YoGBlade
local hydraItems={3074,3077}

local checkDie=false
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

local egg = {team = 0, enemy = 0}
local zac = {team = 0, enemy = 0}
local aatrox = {team = 0, enemy = 0}

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
	SionConfig:addParam('autoQ', 'AutoQ', SCRIPT_PARAM_ONKEYTOGGLE, false, 56)
	SionConfig:addParam('farm', 'AutoCreepFarm', SCRIPT_PARAM_ONKEYTOGGLE, false, 57)
	SionConfig:addParam('dfarm', 'DefendFarm', SCRIPT_PARAM_ONKEYTOGGLE, false, 48)
	SionConfig:addParam('drawW', 'DrawWCast', SCRIPT_PARAM_ONOFF, true)
	SionConfig:addParam('dokillsteal', 'Killsteal', SCRIPT_PARAM_ONOFF, true)
	SionConfig:addParam('ap', 'AP Sion?', SCRIPT_PARAM_ONOFF, true)
	SionConfig:addParam('zh', 'Zhonyas', SCRIPT_PARAM_ONOFF, true)
	SionConfig:permaShow('autoQ')
	SionConfig:permaShow('farm')
	SionConfig:permaShow('teamfight')
	SionConfig:permaShow('dokillsteal')



function Run()
	MS = myHero.movespeed
	WmaxDistance = MS*10 + 550
	WDistance = MS*4 + 550	
	
	if cc<40 then cc=cc+1 if cc==30 then LoadTable() end end
	
	checkDie=false
	if SionConfig.zh then
		checkDie=true
		if target~=nil and myHero.health<myHero.maxHealth*15/100 then
			zhonyas()
		end
	else
		checkDie=false
	end
	
	if SionConfig.ap then
	target = GetWeakEnemy('MAGIC',800)
	else
	target = GetWeakEnemy('PHYS',800)
	end
	
	
	if SionConfig.stun and IsChatOpen() == 0 then stunrun() end
	if SionConfig.farm then autofarm() end
	if SionConfig.teamfight and IsChatOpen() == 0 then fight() end
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
		        ------------
        if myHero.SpellTimeQ > 1.0 and GetSpellLevel('Q') > 0 and (myHero.mana>=100) then
                QRDY = 1
                else QRDY = 0
        end
        if myHero.SpellTimeW > 1.0 and GetSpellLevel('W') > 0 and myHero.mana>=(60+10*GetSpellLevel('W')) then
                WRDY = 1
                else WRDY = 0
        end
        if myHero.SpellTimeE > 1.0 and GetSpellLevel('E') > 0 then
                ERDY = 1
                else ERDY = 0
        end
        if myHero.SpellTimeR > 1.0 and GetSpellLevel('R') > 0 and (myHero.mana>=(100)) then
                RRDY = 1
        else RRDY = 0 end
        --------------------------
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
			
			if QRDY==1 and GetD(target) < 550 then
				CastSpellTarget('Q', target)
			else MoveToMouse()
			end
			if GetD(target)<400 then
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
					if GetInventorySlot(item)~=nil and myHero["SpellTime"..GetInventorySlot(item)]>1.0 then
						CastSpellTarget(tostring(GetInventorySlot(item)),target)
					end
				end
			end
		
	end
	
	if target == nil then
		MoveToMouse()
	end
	
end


function drawDistW()

	if WRDY==1 and outerwdraw==true then
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


function E()
	CastSpellTarget('E', myHero)
end


function autofarm()
if GetMap()==1 then
	findTurret()
	local farmrange=800
	local safe = true

		
		
	if SionConfig.dfarm then
				local tsafe=true
		if target~=nil and tsafe==true and GetD(target,myHero)<550 then

			if QRDY==1 then CastSpellTarget('Q', target) end
			if WRDY==1 then CastSpellTarget('W', target) end
			for _,tur in ipairs(enemyTurrets) do
				if tur~=nil then
					if target~=nil and GetD(tur.object,target)>tur.range then
						tsafe=true
					elseif target~=nil and GetD(tur.object,mtarget)<tur.range then
						tsafe=false
					else
						tsafe=false
					end
				
					if tsafe==false then
						break
					end
				end
			end	
			if WRDY==1 then CastSpellTarget('W', target) end		
			if tsafe==true then AttackTarget(target) end
		elseif tsafe==false or target==nil or (target~=nil and GetD(target,myHero)>550) then
			if safe==true then
				for _,tur in ipairs(enemyTurrets) do
				if tur~=nil then
					mtarget=GetLowestHealthEnemyMinion(farmrange)
		
					if mtarget~=nil and GetD(tur.object,mtarget)>tur.range then
						safe=true
					elseif mtarget~=nil and GetD(tur.object,mtarget)<tur.range and farmrange>0 then
						while ((GetD(tur.object,mtarget)<tur.range) and (farmrange>0) and mtarget~=nil) do
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
				local E = (15+(10*GetSpellLevel("E")))*ERDY
	

			
				local W	= (100+(50*GetSpellLevel('W'))+(myHero.ap*(9/10)))*WRDY

					if GetD(mtarget,myHero)>myHero.range+50 then
						MoveToXYZ(mtarget.x,0,mtarget.z)
		
						if mtarget.health<W then
							if wpressed==false then
								CastSpellTarget('W', mtarget)
							end
							if GetD(mtarget,myHero)<550 and WRDY==1 and wpressed==true then
								CastSpellTarget('W', mtarget)
								if wpressed==true then wpressed =false end
							end
						end
		
					elseif GetD(mtarget,myHero)<=myHero.range+50 and mtarget.health<AA+E then
						if mtarget.health<AA+E then
							AttackTarget(mtarget)	
						end
						if  mtarget.health<W and WRDY==1 then
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
		
				if mtarget~=nil and GetD(tur.object,mtarget)>tur.range then
					safe=true
				elseif mtarget~=nil and GetD(tur.object,mtarget)<tur.range and farmrange>0 then
					while ((GetD(tur.object,mtarget)<tur.range) and (farmrange>0) and mtarget~=nil) do
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
			local E = (15+(10*GetSpellLevel("E")))*ERDY
	

			
			local W	= (100+(50*GetSpellLevel('W'))+(myHero.ap*(9/10)))*WRDY

				if GetD(mtarget,myHero)>myHero.range+50 then
					MoveToXYZ(mtarget.x,0,mtarget.z)
		
					if mtarget.health<W then
						if wpressed==false then
							CastSpellTarget('W', mtarget)
						end
						if GetD(mtarget,myHero)<550 and WRDY==1 and wpressed==true then
							CastSpellTarget('W', mtarget)
							if wpressed==true then wpressed =false end
						end
					end
		
				elseif GetD(mtarget,myHero)<=myHero.range+50 and mtarget.health<AA+E then
					if mtarget.health<AA+E then
						AttackTarget(mtarget)	
					end
					if  mtarget.health<W and WRDY==1 then
						CastSpellTarget('W', mtarget)
					end
				end	
			end
		end
	
	
		if safe==false then StopMove() end
	end
end	
end


function fight()
	if target ~= nil  then
		if RRDY==1 and GetD(target) < myHero.range+50 then
				CastSpellTarget('R', target)
				AttackTarget(target)
		elseif ERDY==1 and Etoggle==false and GetD(target) < myHero.range+50 then
				run_every(0.2,E)
				AttackTarget(target)		
		elseif GetInventorySlot(3128)~=nil and myHero["SpellTime"..GetInventorySlot(3128)]>1.0 and GetD(target)<600 then
			CastSpellTarget(tostring(GetInventorySlot(3128)),target)
		elseif QRDY==1 and GetD(target) < 550 then
				CastSpellTarget('Q', target)
				AttackTarget(target)
		elseif WRDY==1 and GetD(target) < 750 and myHero.SpellNameW=="DeathsCaressFull" then
				CastSpellTarget('W', myHero)
				AttackTarget(target)
		elseif WRDY==1 and GetD(target) < 550 and myHero.SpellNameW=="deathscaress" then
				CastSpellTarget('W', myHero)
				AttackTarget(target)
		elseif GetD(target) < myHero.range+75 then
			AttackTarget(target)
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

		else
			MoveToMouse()
			if GetD(target)<400 then
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
					if GetInventorySlot(item)~=nil and myHero["SpellTime"..GetInventorySlot(item)]>1.0 then
						CastSpellTarget(tostring(GetInventorySlot(item)),target)
					end
				end
			end
		end

	else
		MoveToMouse()
	end
	
end

function autoQattack()

    if target ~= nil then
		if QRDY==1 and GetD(target) < 550 then
			CastSpellTarget('Q', target)
		end
    end

end

function killsteal()
	if target ~= nil then
		local E = CalcDamage(target,(15+(10*GetSpellLevel("E")))*ERDY)
		local AA = getDmg("AD",target,myHero)+(getDmg("SHEEN",target,myHero)*hasSheen)+(getDmg("LICHBANE",target,myHero)*hasLich)+(getDmg("ICEBORN",target,myHero)*hasIceBorn)+(getDmg("TRINITY",target,myHero)*hasTrinity)+E
		local Q = (getDmg("Q",target,myHero))*QRDY
		local W	= getDmg("W",target,myHero)*WRDY

		if target.health < (W+Q+AA+ignitedamage)*QRDY and GetD(target) < myHero.range+100 then
		
			CustomCircle(650,6,5,myHero)
				CastSpellTarget('W', target)
				CastSpellTarget('Q', target)
			
			if (myHero.maxHealth*25/100)<myHero.health and GetD(myHero, target) < myHero.range+100 then
				CastSpellTarget('R', myHero)
			end
			if myHero.SummonerD == 'SummonerDot' then
				if IsSpellReady('D')==1 then CastSpellTarget('D',target) end
			elseif myHero.SummonerF == 'SummonerDot' then
				if IsSpellReady('F')==1 then CastSpellTarget('F',target) end
			end	
			if GetD(myHero, target) < myHero.range+100 then
				AttackTarget(target)
			end
			if CanCastSpell('E') and GetD(myHero, target) < myHero.range+100 and Etoggle==false then
				run_every(0.2,E)
			end
		elseif target.health < W+AA+ignitedamage and GetD(target) < myHero.range+100 then
		
			CustomCircle(650,6,5,myHero)
				CastSpellTarget('W', target)
			
			if (myHero.maxHealth*25/100)<myHero.health and GetD(myHero, target) < myHero.range+100 then
				CastSpellTarget('R', myHero)
			end
			if myHero.SummonerD == 'SummonerDot' then
				if IsSpellReady('D')==1 then CastSpellTarget('D',target) end
			elseif myHero.SummonerF == 'SummonerDot' then
				if IsSpellReady('F')==1 then CastSpellTarget('F',target) end
			end	
			if GetD(myHero, target) < myHero.range+100 then
				AttackTarget(target)
			end
			if CanCastSpell('E') and GetD(myHero, target) < myHero.range+100 and Etoggle==false then
				run_every(0.2,E)
			end
		elseif target.health < (Q+W+ignitedamage)*QRDY and GetD(target)<550 then
			CustomCircle(650,6,5,myHero)
				CastSpellTarget('W', target)
				CastSpellTarget('Q', target)
			if CanCastSpell('E') and GetD(target) < myHero.range+100 and Etoggle==false then
				run_every(0.2,E)
			end
			if myHero.SummonerD == 'SummonerDot' then
				if IsSpellReady('D')==1 then CastSpellTarget('D',target) end
			elseif myHero.SummonerF == 'SummonerDot' then
				if IsSpellReady('F')==1 then CastSpellTarget('F',target) end
			end	
			if (myHero.maxHealth*20/100)<myHero.health and GetD(myHero, target) < myHero.range+100 then
				CastSpellTarget('R', myHero)
			end
		elseif target.health < (W+ignitedamage) and GetD(target)<550 then
			CustomCircle(650,6,5,myHero)
				CastSpellTarget('W', target)
			if CanCastSpell('E') and GetD(target) < myHero.range+100 and Etoggle==false then
				run_every(0.2,E)
			end
			if myHero.SummonerD == 'SummonerDot' then
				if IsSpellReady('D')==1 then CastSpellTarget('D',target) end
			elseif myHero.SummonerF == 'SummonerDot' then
				if IsSpellReady('F')==1 then CastSpellTarget('F',target) end
			end	
			if (myHero.maxHealth*20/100)<myHero.health and GetD(myHero, target) < myHero.range+100 then
				CastSpellTarget('R', myHero)
			end
		end	
	end
	
end

function OnDraw()

    if myHero.dead == 0 then
		if QRDY == 1 then
			CustomCircle(550,3,2,myHero)
		end	
		if WRDY == 1 then
			CustomCircle(550,6,6,myHero)
		end
    end
	
end

function OnCreateObj(obj)

	if GetD(obj,myHero) <10 then
	--printtext("\n"..obj.charName.."\n")
		if obj.charName:find("DeathsCaress_buf") then
			wpressed=true
			wbegin=os.clock()
			wend=10+os.clock()
			outerwdraw=false
		end
		if obj.charName:find("DeathsCaress_nova") then
			wpressed=false
			outerwdraw=true
		end
    end
	
end


function OnProcessSpell(unit, spell)
	if unit.charName==myHero.charName then
		--printtext("\n"..spell.name.."\n")

		if string.find(spell.name,"Enrage") then
			if Etoggle==false then
				Etoggle=true
			else
				Etoggle=false
			end
		elseif string.find(spell.name,"deathscaress") then
		
		elseif string.find(spell.name,"DeathsCaressFull") then
		
		end
	elseif myHero.dead~=nil then
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
 
 ------------------------------------------------------ Check If In Spell Stuff
 
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
 
function IsInvulnerable(target)
        if target ~= nil and target.dead == 0 then
                if target.invulnerable == 1 then return {status = 3, name = nil, amount = nil, type = nil}
                else for i=1, objManager:GetMaxObjects(), 1 do
                                local object = objManager:GetObject(i)
                                if object ~= nil then
                                        if string.find(object.charName,"eyeforaneye") ~= nil and GetD(target,object) <= 20 then return {status = 3, name = 'Intervention', amount = 0, type = 'ALL'}
                                        elseif string.find(object.charName,"nickoftime") ~= nil and GetD(target,object) <= 20 then return {status = 1, name = 'Chrono Shift', amount = 0, type = 'REVIVE'}
                                        elseif target.name == 'Poppy' and string.find(object.charName,"DiplomaticImmunity_tar") ~= nil and GetD(myHero,object) > 20 then
                                                for i=1, objManager:GetMaxObjects(), 1 do
                                                        local diObject = objManager:GetObject(i)
                                                        if diObject ~= nil and string.find(diObject.charName,"DiplomaticImmunity_buf") ~= nil and GetD(target,diObject) <= 20 then return {status = 3, name = 'Diplomatic Immunity', amount = 0, type = 'ALL'} end
                                                end
                                        elseif target.name == 'Vladimir' and string.find(object.charName,"VladSanguinePool_buf") ~= nil and GetD(myHero,object) <= 20 then return {status = 3, name = 'Sanguine Pool', amount = 0, type = 'ALL'}
--                                      elseif string.find(object.charName,"Summoner_Barrier") ~= nil and GetD(target,object) <= 20 then return 2--, 'NONE'
                                        elseif string.find(object.charName,"Global_Spellimmunity") ~= nil or string.find(object.charName,"Morgana_Blackthorn_Blackshield") ~= nil and GetD(target,object) <= 20 then
                                                local amount = 0
                                                for i= 1,objManager:GetMaxHeroes(),1 do
                                                        local hero=objManager:GetHero(i)
                                                        if hero.team == target.team and hero.name == 'Morgana' then
                                                                amount = 30+(65*hero.SpellLevelE)+(hero.ap*0.7)
                                                                return {status = 2, name = 'Black Shield', amount = amount, type = 'MAGIC'}
                                                        end
                                                end
                                        elseif string.find(object.charName,"bansheesveil_buf") ~= nil and GetD(target,object) <= 20 then return {status = 2, name = 'Banshees Veil', amount = 0, type = 'SPELL'}
                                        elseif target.name == 'Sivir' and string.find(object.charName,"Sivir_Base_E_shield") ~= nil and GetD(target,object) <= 20 then return {status = 2, name = 'Spell Shield', amount = 0, type = 'SPELL'}
                                        elseif target.name == 'Nocturne' and string.find(object.charName,"nocturne_shroudofDarkness_shield") ~= nil and GetD(target,object) <= 20 then return {status = 2, name = 'Shroud of Darkness', amount = 0, type = 'SPELL'}
                                        elseif target.name == 'Tryndamere' and string.find(object.charName,"UndyingRage_buf") ~= nil and GetD(target,object) <= 20 then return {status = 1, name = 'Undying Rage', amount = 0, type = 'NONE'}
                                        elseif target.name == 'Anivia' then
                                                if target.team == myHero.team then
                                                        if egg.team ~= 0 and GetTickCount()-egg.team > 240000 or egg.team == 0 then return {status = 1, name = 'Egg', amount = 0, type = 'REVIVE'}
                                                        else return {status = 0, name = nil, amount = nil, type = nil}
                                                        end
                                                elseif target.team ~= myHero.team then
                                                        if egg.enemy ~= 0 and GetTickCount()-egg.enemy > 240000 or egg.enemy == 0 then return {status = 1, name = 'Egg', amount = 0, type = 'REVIVE'}
                                                        else return {status = 0, name = nil, amount = nil, type = nil}
                                                        end
                                                end
                                        elseif target.name == 'Aatrox' then
                                                if target.team == myHero.team then
                                                        if aatrox.team ~= 0 and GetTickCount()-aatrox.team > 225000 or aatrox.team == 0 then return {status = 1, name = 'Aatrox', amount = 0, type = 'REVIVE'}
                                                        else return {status = 0, name = nil, amount = nil, type = nil}
                                                        end
                                                elseif target.team ~= myHero.team then
                                                        if aatrox.enemy ~= 0 and GetTickCount()-aatrox.enemy > 225000 or aatrox.enemy == 0 then return {status = 1, name = 'Aatrox', amount = 0, type = 'REVIVE'}
                                                        else return {status = 0, name = nil, amount = nil, type = nil}
                                                        end
                                                end
                                        elseif target.name == 'Zac' then
                                                if target.team == myHero.team then
                                                        if zac.team ~= 0 and GetTickCount()-zac.team > 300000 or zac.team == 0 then return {status = 1, name = 'Zac', amount = 0, type = 'REVIVE'}
                                                        else return {status = 0, name = nil, amount = nil, type = nil}
                                                        end
                                                elseif target.team ~= myHero.team then
                                                        if zac.enemy ~= 0 and GetTickCount()-zac.enemy > 300000 or zac.enemy == 0 then return {status = 1, name = 'Zac', amount = 0, type = 'REVIVE'}
                                                        else return {status = 0, name = nil, amount = nil, type = nil}
                                                        end
                                                end
--                                      elseif string.find(object.charName,"GLOBAL_Item_FoM_Shield") ~= nil and GetD(target,object) <= 30 then return 2--, 'NONE'
                                        elseif string.find(object.charName,"rebirthready") ~= nil and GetD(target,object) <= 20 then return {status = 1, name = 'Guardian Angel', amount = 0, type = 'REVIVE'}
--                                      elseif target.name == 'Nautilus' and string.find(object.charName,"Nautilus_W_shield_cas") ~= nil and GetD(target,object) <= 20 then return 2--, 'NONE'
                                        end
                                end
                        end
                end
        end
        return {status = 0, name = nil, amount = nil, type = nil}
end


function GetTeamSize()
    return math.floor(objManager:GetMaxHeroes()/2)
end
 
function GetBestEnemy(damage_type, range, tag)
    if tag == nil then tag = "BASIC" end
    local enemy, prospect
    for i=1,GetTeamSize() do    
        prospect = GetWeakEnemy(damage_type, range, tag, i)
        if prospect == nil then
            -- pass        
        else
            if IsInvulnerable(prospect).status==3 then
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