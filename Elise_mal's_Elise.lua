require "Utils"
require 'spell_damage'
print=printtext
printtext("\nElise\n")
printtext("\nBy Malbert\n")
printtext("\nVersion 2.1\n")

local target
local ignitedamage
local spider=false
local spidercount=0
local spiders={}
local nocreep=1

local queenspellsup=1
local SQ = os.clock()
local SW = os.clock()
local SE = os.clock()
local RapT=os.clock()
local JumpT=os.clock()
local Qcd, Wcd, Ecd, REcd, RQcd
local QU,WU,EU,REU = false,false,false
local spiderRappel=1
local spiderJump=1
local target600
local xx,yy,zz
local tefa

local QRDY=0
local WRDY=0
local ERDY=0
local RRDY=0

EliseConfig = scriptConfig("Elise", "Elise Config")
EliseConfig:addParam("h", 'Harass', SCRIPT_PARAM_ONKEYDOWN, false, 88)
EliseConfig:addParam('teamfight', 'TeamFight', SCRIPT_PARAM_ONKEYDOWN, false, 84)
EliseConfig:addParam('hm', 'Harass Mode', SCRIPT_PARAM_DOMAINUPDOWN, 1, 48, {"W>Q","E>W>Q"})
EliseConfig:addParam('dokillsteal', 'Killsteal', SCRIPT_PARAM_ONOFF, false)
EliseConfig:addParam('ik', 'Ignite KS', SCRIPT_PARAM_ONOFF, true)
EliseConfig:addParam('smite', 'SmiteSteal', SCRIPT_PARAM_ONOFF, true)
EliseConfig:addParam('Edelay', "E Speed", SCRIPT_PARAM_NUMERICUPDOWN, 2.6, 187,0,6,0.1)
EliseConfig:permaShow('Edelay')
EliseConfig:permaShow('hm')
EliseConfig:permaShow('ik')
EliseConfig:permaShow('dokillsteal')
--turret stuff

local SpawnturretR={}
local SpawnturretB={}
local TurretsR={}
local TurretsB={}
local enemyTurrets={}
local enemySpawn={}
local map = nil
--printtext("\n" ..GetMap() .. "\n")


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
function Run()
	
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
	
	Qcd = 6 + 6*(myHero.cdr)
	Wcd = 12 + 12*(myHero.cdr)
	Ecd = 15 - (1*GetSpellLevel('E')) + (15 - (1*GetSpellLevel('E')))*(myHero.cdr)
	REcd = 28 - (2*GetSpellLevel('E')) + (28 - (2*GetSpellLevel('E')))*(myHero.cdr)
	RQcd = 6 + 6*(myHero.cdr)
	
	target = GetWeakEnemy("MAGIC", 1200,"NEARMOUSE")
	target600 = GetWeakEnemy("TRUE", 650)
	ignite()
	
	
	if target~=nil then
		local delay = EliseConfig.Edelay
		xx,yy,zz=GetFireahead(target,delay,12.9)
		tefa={x=xx,y=yy,z=zz}
	
	end
	
	checkQueenSpells()
	
	if IsChatOpen() == 0 and EliseConfig.h then harass() end
	if EliseConfig.dokillsteal then killsteal() end
	if IsChatOpen() == 0 and EliseConfig.teamfight then Teamfight() end
	if EliseConfig.smite then smitesteal() end
	if EliseConfig.ik then ik() end
end

function ik()
	if target600~=nil and target600.health<ignitedamage then
		if myHero.SummonerD == 'SummonerDot' then
			if IsSpellReady('D') then CastSpellTarget('D',target600) end
		end
		if myHero.SummonerF == 'SummonerDot' then
			if IsSpellReady('F') then CastSpellTarget('F',target600) end
		end
	end             
end

function smitesteal()
	if myHero.SummonerD == "SummonerSmite" then
		CastHotkey("AUTO 100,0 SPELLD:SMITESTEAL RANGE=600 TRUE COOLDOWN")
		return
	end
	if myHero.SummonerF == "SummonerSmite" then
		CastHotkey("AUTO 100,0 SPELLF:SMITESTEAL RANGE=600 TRUE COOLDOWN")
		return
	end
end

function checkQueenSpells()
	if GetSpellLevel('Q')>0 and GetSpellLevel('W')>0 and GetSpellLevel('E')>0 then
		if QU==true and WU==true and EU==true then
			queenspellsup=0
			if os.clock()>SQ+Qcd and os.clock()>SW+Wcd and os.clock()>SE+Ecd then
				QU,WU,EU = false,false,false
				queenspellsup=1
			end
		end
	elseif GetSpellLevel('Q')>0 and GetSpellLevel('W')>0 then
		if QU==true and WU==true then
			queenspellsup=0
			if os.clock()>SQ+Qcd and os.clock()>SW+Wcd then
				QU,WU = false,false
				queenspellsup=1
			end
		end
	elseif GetSpellLevel('Q')>0 and GetSpellLevel('E')>0 then
		if QU==true and EU==true then
			queenspellsup=0
			if os.clock()>SQ+Qcd  and os.clock()>SE+Ecd then
				QU,EU = false,false
				queenspellsup=1
			end
		end
	elseif GetSpellLevel('W')>0 and GetSpellLevel('E')>0 then
		if WU==true and EU==true then
			queenspellsup=0
			if os.clock()>SW+Wcd and os.clock()>SE+Ecd then
				WU,EU = false,false
				queenspellsup=1
			end
		end
	elseif GetSpellLevel('Q')>0 then
		if QU==true then
			queenspellsup=0
			if os.clock()>SQ+Qcd then
				QU = false
				queenspellsup=1
			end
		end
	elseif GetSpellLevel('W')>0 then
		if WU==true then
			queenspellsup=0
			if os.clock()>SW+Wcd then
				WU = false
				queenspellsup=1
			end
		end
	elseif GetSpellLevel('E')>0 then
		if EU==true then
			queenspellsup=0
			if os.clock()>SE+Ecd then
				EU = false
				queenspellsup=1
			end
		end
	
	end

	if GetSpellLevel('E')>0 then
		if REU==true then
			spiderRappel=0
			if os.clock()>RapT+REcd then
				REU = false
				spiderRappel=1
			end
		end
	end
	if GetSpellLevel('Q')>0 then
		--if RQU==true then
		--	spiderJump=0
			--if os.clock()>JumpT+RQcd then
			--	RQU = false
			--	spiderJump=1
		--	end
		--end
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

function harass()
	if target~=nil then
		
		if CreepBlock(xx,yy,zz,100)==1 then
			nocreep=0
		else
			nocreep=1
		end
		if spider==false then
			if EliseConfig.hm==2 and GetD(target)<1050 and ERDY==1 and nocreep==1 then 
				CastSpellXYZ('E',xx,yy,zz) 
			elseif (GetSpellLevel('E')==0 or EliseConfig.hm==1 or ERDY==0 or nocreep==0) and GetD(target)<700 then
				CastSpellTarget('Q',target)
				CastSpellXYZ('W',GetFireahead(target,2,20))
			end
		elseif spider==true then
			if GetD(target)<1050 and RRDY==1 then 
				CastSpellTarget('R',myHero)
				--spider=false
			end
		end
	else
		MoveToMouse()
	end
end




function Teamfight()
	if target~=nil then
		local tsafe=true
		enemyTurrets={}
		findTurret()
			for _, tur in ipairs(enemyTurrets) do
				if tur~=nil then
					if target~=nil and GetD(tur.object,target)>tur.range then
						tsafe=true
					elseif target~=nil and GetD(tur.object,target)<=tur.range then
						tsafe=false
					else
						tsafe=false
					end
				
					if tsafe==false then
						break
					end
				end
			end	
		if CreepBlock(xx,yy,zz,100)==1 then
			nocreep=0
		else
			nocreep=1
		end
		
		if spider==false then
				
			if GetD(target)<700 and QRDY==1 then 
				CastSpellTarget('Q',target) 
			end
			if GetD(target)<950 and WRDY==1 then CastSpellXYZ('W',GetFireahead(target,2,20)) end
			if GetD(target)<1050 and ERDY==1 and nocreep==1 then 
				CastSpellXYZ('E',xx,yy,zz)		
			end
			if GetD(target)<1100 and GetD(target)>900 and runningAway(target) and spiderRappel==1 then
				CastSpellTarget('R',myHero) 
				--spider=true
			end
			if GetD(target)<700 and QRDY==0 and WRDY==0 and (ERDY==0 or (nocreep==0 and IsMoving(target)==false)) and RRDY==1 then 
				CastSpellTarget('R',myHero) 
				--spider=true
			elseif GetD(target)<1100 and spiderRappel==1 and QRDY==0 and WRDY==0 and (ERDY==0 or (nocreep==0 and IsMoving(target)==false)) and RRDY==1 then 
				CastSpellTarget('R',myHero) 
				--spider=true
			else			
				AttackTarget(target)
			end
			if GetD(target)<600 then UseAllItems(target) end
		elseif spider==true then
		
			if GetD(target)<600 then UseAllItems(target) end
			if GetD(target)<475 and QRDY==1 then 
				CastSpellTarget('Q',target) 
				CastSpellTarget('W',target)
				AttackTarget(target)
			end	
			if GetD(target)>500 then
				if tsafe==true then CastSpellTarget('E',target) end
				AttackTarget(target)
			elseif GetD(target)>300 and QRDY==0 then
				if tsafe==true then CastSpellTarget('E',target) end
				AttackTarget(target)
			elseif QRDY==0 then
				CastSpellTarget('W',target)
				AttackTarget(target)
			end
			
			if GetD(target)<700 and (QRDY==0 and WRDY==0 and ERDY==0 and spidercount<2 and RRDY==1) or (RRDY==1 and queenspellsup==1 and (myHero.health<3/10*myHero.maxHealth or (GetD(target)>480 and QRDY==0 and ERDY==0))) then 
				CastSpellTarget('R',myHero) 
				--spider=false
			end
		
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

function IsMoving(slowtarget)
   local x, y, z = GetFireahead(slowtarget,5,0)
   local d = GetD({x=x, y=y, z=z},slowtarget)
   return d > 0 
end

function OnProcessSpell(unit,spell)
	if unit.name==myHero.name and myHero.team==unit.team then
		
		--EliseR
		--EliseRSpider
		--EliseSpiderEInitial
		if spell.name:find("EliseHumanQ") then
			SQ=os.clock()
			QU=true
		elseif spell.name:find("EliseHumanW") then
			SW=os.clock()
			WU=true
		elseif spell.name:find("EliseHumanE") then
			SE=os.clock()
			EU=true
		elseif spell.name:find("elisespidere") then
			RapT=os.clock()
			REU=true
		elseif spell.name:find("EliseSpiderQCast") then
			JumpT=os.clock()
			RQU=true
		elseif spell.name:find("EliseRSpider") then
			spider=false
		elseif spell.name:find("EliseR") then
			spider=true
		end
		--if spider then sp=1
		--else sp = 0
		--end
		--printtext("\nCD ".. spell.name .."SP: "..sp.."\n")
	
	end
	if myHero.SpellNameR=="EliseRSpider" then
		spider=true
	else
		spider=false
	end

end

function OnCreateObj(obj)
for i, sp in ipairs(spiders) do
	if sp==nil or sp.dead==1 then
		spidercount=spidercount-1
		table.remove(spiders,i)
	end
--printtext("\nsp"..spidercount.."\n")
end


	if GetD(obj,myHero) <400 then
	--printtext("\n"..obj.charName.."\n")
		if obj.charName:find("Spiderling") then
			spidercount=spidercount+1
			table.insert(spiders,obj)
		end
		
		--[[if obj.charName:find("Elise_human_transform") then
			spider=false
		end
		if obj.charName:find("Elise_spider_transform") then
			spider=true
		end--]]
    end
	
	--[[if GetD(obj,myHero) <700 and EliseConfig.h and target~=nil then
		--printtext("\nS"..obj.charName.."\n")
		if obj.charName:find("Elise_human_E_tar") then
			if WRDY==1 then CastSpellXYZ('W',GetFireahead(target,2,20)) end
		end
		if obj.charName:find("VolatileSpiderling") then
			if QRDY==1 then CastSpellTarget('Q',target) end
		end
	end--]]
	
	
end


function killsteal()
	if target~=nil and target.dead~=1 then
		
		local Q
		local QM
		local W
		local AA = getDmg("AD",target,myHero)
		local xx2,yy2,zz2=GetFireahead(target,2,20)
		if CreepBlock(xx2,yy2,zz2,100)==1 then
			nocreep=0
		else
			nocreep=1
		end
		
		if spider==false then
			Q = getDmg("Q",target,myHero)*QRDY
			QM = getDmg("QM",target,myHero)*RRDY
			W = getDmg("W",target,myHero)*WRDY*nocreep
		else
			Q = getDmg("Q",target,myHero)*RRDY*queenspellsup
			QM = getDmg("QM",target,myHero)*QRDY
			W = getDmg("W",target,myHero)*RRDY*nocreep*queenspellsup
		end
		if target.health<(Q+W+AA+ignitedamage+QM) and GetD(target)<630 and spider==false then
			if QRDY==1 then CastSpellTarget('Q',target) end
			if WRDY==1 and nocreep==1 then CastSpellXYZ('W',GetFireahead(target,2,20)) end
			if RRDY==1 then CastSpellTarget('R',myHero) end
			if ERDY==1 then CastSpellTarget('E',target) end
			if QRDY==1 then CastSpellTarget('Q',target) end
			AttackTarget(target)
			if ignitedamage~=0 then CastSummonerIgnite(target) end
		end
		if target.health<(Q+W+AA+ignitedamage+QM) and GetD(target)<475 and spider==true then
			if QRDY==1 then CastSpellTarget('Q',target) end
			AttackTarget(target)
			if RRDY==1 then CastSpellTarget('R',myHero) end
			if QRDY==1 then CastSpellTarget('Q',target) end
			if WRDY==1 and nocreep==1 then CastSpellXYZ('W',GetFireahead(target,2,20)) end
			AttackTarget(target)
			if ignitedamage~=0 then CastSummonerIgnite(target) end
		end
		
		
		if target.health<(Q+W+AA+ignitedamage+QM)*spiderRappel and GetD(target)>475 and spider==true then
			if ERDY==1 then CastSpellTarget('E',target) end
			if QRDY==1 then CastSpellTarget('Q',target) end
			AttackTarget(target)
			if RRDY==1 then CastSpellTarget('R',myHero) end
			if QRDY==1 then CastSpellTarget('Q',target) end
			if WRDY==1 then CastSpellXYZ('W',GetFireahead(target,2,20)) end
			AttackTarget(target)
			if ignitedamage~=0 then CastSummonerIgnite(target) end
		end
		
		if target.health<Q+W+ignitedamage and GetD(target)<630 and spider==false then
			if QRDY==1 then CastSpellTarget('Q',target) end
			if WRDY==1 then CastSpellXYZ('W',GetFireahead(target,2,20)) end
			if ignitedamage~=0 then CastSummonerIgnite(target) end
		end
		
				if target.health<(QM+ignitedamage)*spiderRappel and GetD(target)>630 and spider==false then
			if RRDY==1 then CastSpellTarget('R',myHero) end
			if ERDY==1 then CastSpellTarget('E',target) end
			if QRDY==1 then CastSpellTarget('Q',target) end
			if ignitedamage~=0 then CastSummonerIgnite(target) end
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

		if QRDY==1 and spider==true then
			CustomCircle(475,5,2,myHero)	
		elseif QRDY==1 and spider==false then
			CustomCircle(630,5,2,myHero)		
		end
		
		if ERDY==1 then
			CustomCircle(1080,5,Color.Blue,myHero)	
		end
		
		if WRDY==1 and spider==false then
			CustomCircle(950,5,4,myHero)	
		end
		
	if target~=nil then
		CustomCircle(100,4,5,target)
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

SetTimerCallback("Run")