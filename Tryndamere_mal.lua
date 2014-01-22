require "Utils"
require 'spell_damage'
print=printtext
printtext("\nTryndamere\n")
printtext("\nBy Malbert\n")
printtext("\nVersion 2.9\n")

local target
local targetnear
local target400
local target600
local ignitedamage
local visEnemiesInRange={}
local checkDie=false
local incomingSpellDmg = 0
local Ulting=false
local Qsafe=true
local UltT=os.clock()
local coordCount=0
local colorCheck = 0
local xx1, zz1, xx2, zz2, xx3, zz3, xx4, zz4
local Ignited=false
local igniteTimer=0
local IgniteEnemyLevel=0

local _registry = {}

--------Spell Stuff
local QRDY=0
local WRDY=0
local ERDY=0
local RRDY=0

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
local enemyinRange

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


local bushQuads = 
{
{x1= 7518.2153320313 ,x2= 7530.71875   ,x3= 7193.9765625   ,x4= 7238.9736328125   ,
z1= 641.78741455078 ,z2= 558.71649169922 ,z3= 536.95721435547 ,z4= 634.78192138672 },
{x1= 8684.6328125   ,x2= 8563.5087890625   ,x3= 8890.91796875   ,x4= 9004.5322265625  ,
z1= 1706.2954101563 ,z2= 1928.1704101563 ,z3= 2054.1772460938 ,z4= 1858.7463378906 },
{x1= 9776.8466796875   ,x2= 9945   ,x3= 10180.98046875   ,x4= 10187.516601563   ,
z1= 2737.759765625 ,z2= 3065 ,z3= 2876.6650390625 ,z4= 2762.7749023438 },
{x1= 11438.2421875   ,x2= 11553.133789063   ,x3= 11757.572265625   ,x4= 11485.76953125   ,
z1= 3640.6740722656 ,z2= 3699.5812988281 ,z3= 3222.41796875 ,z4= 3209.8098144531 },
{x1= 12649.26171875   ,x2= 13259.23828125   ,x3= 13335.918945313   ,x4= 12791.076171875   ,
z1= 1970.8107910156 ,z2= 2894.4050292969 ,z3= 2792.01953125 ,z4= 1813.9447021484 },
{x1= 12555.688476563   ,x2= 11683   ,x3= 11615.383789063   ,x4= 12364.55078125   ,
z1= 1556.9916992188 ,z2= 943 ,z3= 1111.6633300781 ,z4= 1649.1688232422 },
{x1= 7861.2763671875   ,x2= 7854.091796875   ,x3= 7426.771484375   ,x4= 7409.392578125   ,
z1= 3369.6188964844 ,z2= 3234.4265136719   ,z3= 3194.0646972656 ,z4= 3413.5715332031 },
{x1= 6710.6801757813   ,x2= 6755.1572265625   ,x3= 6194.060546875   ,x4= 6213.03515625   ,
z1= 2991.7956542969 ,z2= 2826.5041503906 ,z3= 2823.7023925781 ,z4= 2958.8374023438 },
{x1= 5012.4145507813   ,x2= 4984.19921875   ,x3= 5384.91796875   ,x4= 5419   ,
z1= 3020.1779785156 ,z2= 3262.7741699219 ,z3= 3362.2065429688 ,z4= 3245 },
{x1= 5979.7875976563   ,x2= 6094.2006835938   ,x3= 6261.0043945313   ,x4= 6229.6147460938   ,
z1= 4290.896484375 ,z2= 4586.6694335938 ,z3= 4585.7509765625 ,z4= 4279.9311523438 },
{x1= 7886.6328125   ,x2= 8180.779296875   ,x3= 8319.90625   ,x4= 8226.5224609375   ,
z1= 4577.3540039063 ,z2= 4674.525390625 ,z3= 4254.771484375 ,z4= 4124.6899414063 },
{x1= 8901.3798828125   ,x2= 9078.4716796875   ,x3= 9132.671875   ,x4= 9052.9462890625   ,
z1= 5528.5625 ,z2= 5502.1171875 ,z3= 5309.6049804688 ,z4= 5272.8720703125 },
{x1= 7779.8984375   ,x2= 7546.3256835938   ,x3= 8218.7099609375   ,x4= 8393.126953125   ,
z1= 5858.9873046875 ,z2= 5991.1450195313 ,z3= 6520.40625 ,z4= 6403.1586914063 },
{x1= 8786.6669921875   ,x2= 8956.7236328125   ,x3= 9574.1591796875   ,x4= 9588.744140625   ,
z1= 6199.1416015625 ,z2= 6014.0844726563 ,z3= 6210.6557617188 ,z4= 6625.2192382813 },
{x1= 9482.3154296875   ,x2= 9757.6962890625   ,x3= 9642.1787109375   ,x4= 9487.6123046875   ,
z1= 7167.1137695313 ,z2= 7285.5747070313 ,z3= 7820.716796875 ,z4= 8008.3955078125 },
{x1= 11201.662109375   ,x2= 11508.702148438   ,x3= 11285.108398438   ,x4= 11000.489257813   ,
z1= 7378.1821289063 ,z2= 7130.9248046875 ,z3= 6797.849609375 ,z4= 6842.0517578125 },
{x1= 11884.068359375   ,x2= 12198.336914063   ,x3= 12309.836914063   ,x4= 12212.60546875   ,
z1= 4902.9111328125 ,z2= 5182.681640625 ,z3= 5127.8295898438 ,z4= 4611.4755859375 },
{x1= 13757.692382813   ,x2= 13666.208984375   ,x3= 13648.884765625   ,x4= 13725.844726563   ,
z1= 6500.8217773438 ,z2= 6551.595703125 ,z3= 6887.4052734375 ,z4= 6914.8208007813 },
{x1= 5775.8051757813   ,x2= 6378.6254882813   ,x3= 6524.6083984375   ,x4= 5958.7446289063   ,
z1= 7953.1704101563 ,z2= 8438.578125 ,z3= 8281.349609375 ,z4= 7774.6611328125 },
{x1= 5248.6591796875   ,x2= 5014.2905273438   ,x3= 4341.791015625   ,x4= 4399.9560546875   ,
z1= 8256.0830078125 ,z2= 8476.1513671875 ,z3= 8047.4404296875 ,z4= 7805.1162109375 },
{x1= 4724.806640625   ,x2= 4747.3056640625   ,x3= 4944.66796875   ,x4= 4924.8754882813   ,
z1= 8809.66796875 ,z2= 9027.919921875 ,z3= 9005.638671875 ,z4= 8871.6923828125 },
{x1= 4484.0830078125   ,x2= 4263.8579101563   ,x3= 4365.6435546875   ,x4= 4486.4545898438   ,
z1= 6468.7822265625 ,z2= 7018.5961914063 ,z3=7298.9228515625  ,z4= 7265.052734375 },
{x1= 2745.7309570313   ,x2= 2592.9399414063   ,x3= 2894.337890625   ,x4= 3127.9279785156   ,
z1= 7139.6479492188 ,z2= 7461.1596679688 ,z3= 7687.5766601563 ,z4= 7495.1499023438 },
{x1= 1907.8170166016   ,x2= 1781.8581542969   ,x3= 1830.1352539063   ,x4= 2155.7104492188   ,
z1= 9245.5625 ,z2= 9303.814453125   ,z3= 9774.494140625 ,z4= 9520.2392578125 },
{x1= 2148.7583007813   ,x2= 2257.0495605469   ,x3= 2644.7626953125   ,x4= 2511.1401367188   ,
z1= 11369.637695313 ,z2= 11436.31640625 ,z3= 10981.759765625 ,z4= 10872.884765625 },
{x1= 3792.0959472656   ,x2= 4171.4497070313   ,x3= 4274.431640625   ,x4= 4132.810546875   ,
z1= 11599.807617188 ,z2= 11801.0390625  ,z3= 11694.685546875 ,z4= 11349.4921875 },
{x1= 5029.244140625   ,x2= 5023.0908203125   ,x3= 5435.5146484375   ,x4= 5527.7915039063   ,
z1= 12348.341796875 ,z2= 12555.654296875 ,z3= 12664.2890625 ,z4= 12469.424804688 },
{x1= 6555.6987304688   ,x2= 6575.154296875   ,x3= 6929.9130859375   ,x4= 6941.1059570313   ,
z1= 13916.046875 ,z2= 13825.478515625 ,z3= 13804.478515625 ,z4= 13889.920898438 },
{x1=7319.5483398438  ,x2= 7461.51953125   ,x3= 7871.3984375   ,x4= 7882.5825195313   ,
z1= 11463.884765625 ,z2= 11694.7265625 ,z3= 11622.151367188 ,z4= 11472.288085938 },
{x1= 8587.68359375   ,x2= 8972.79296875   ,x3= 9058.2646484375   ,x4= 8794.5107421875   ,
z1= 11179.747070313 ,z2= 11392.6953125 ,z3= 11199.34765625 ,z4= 11067.290039063 },
{x1= 7963.8247070313   ,x2= 7801.515625   ,x3= 7759.11328125   ,x4= 7957.30859375   ,
z1= 10190.237304688 ,z2= 10171.16796875 ,z3= 9883.2041015625 ,z4= 9838.19921875 },
{x1= 6635.0849609375   ,x2= 6204.42578125   ,x3= 6235.9951171875   ,x4= 6592.0654296875   ,
z1= 11009.173828125 ,z2= 11127.413085938 ,z3= 11248.918945313 ,z4= 11290.568359375 },
{x1= 5788.3930664063   ,x2= 5784.26953125   ,x3= 5912.232421875   ,x4= 6218.4379882813   ,
z1= 10368.354492188 ,z2= 9902.4912109375 ,z3= 9817.9453125 ,z4= 9888.0458984375 },
{x1= 342.44448852539   ,x2= 472.52020263672   ,x3= 494.22247314453   ,x4= 360.47937011719   ,
z1= 7598.6674804688 ,z2= 7642.1611328125 ,z3= 8139.744140625 ,z4= 8159.1171875 },

}
local key=nil
local Oranges = {"Stun_glb", "AlZaharNetherGrasp_tar", "InfiniteDuress_tar", "skarner_ult_tail_tip", "SwapArrow_red", "Global_Taunt", "Global_Fear", "Ahri_Charm_buf", "leBlanc_shackle_tar", "LuxLightBinding_tar", "RunePrison_tar", "DarkBinding_tar", "nassus_wither_tar", "Amumu_SadRobot_Ultwrap", "Amumu_Ultwrap", "maokai_elementalAdvance_root_01", "RengarEMax_tar", "VarusRHitFlash"}
local QSS = {"Stun_glb", "AlZaharNetherGrasp_tar", "InfiniteDuress_tar", "skarner_ult_tail_tip", "SwapArrow_red", "summoner_banish", "Global_Taunt", "mordekaiser_cotg_tar", "Global_Fear", "Ahri_Charm_buf", "leBlanc_shackle_tar", "LuxLightBinding_tar", "Fizz_UltimateMissle_Orbit", "Fizz_UltimateMissle_Orbit_Lobster", "RunePrison_tar", "DarkBinding_tar", "nassus_wither_tar", "Amumu_SadRobot_Ultwrap", "Amumu_Ultwrap", "maokai_elementalAdvance_root_01", "RengarEMax_tar", "VarusRHitFlash"}
local Cleanselist = {"Stun_glb", "summoner_banish", "Global_Taunt", "Global_Fear", "Ahri_Charm_buf", "leBlanc_shackle_tar", "LuxLightBinding_tar", "RunePrison_tar", "DarkBinding_tar", "nassus_wither_tar", "Amumu_SadRobot_Ultwrap", "Amumu_Ultwrap", "maokai_elementalAdvance_root_01", "RengarEMax_tar", "VarusRHitFlash"}


TryndConfig = scriptConfig("Trynd Config", "TryndConfig")
TryndConfig:addParam("e", "Escape", SCRIPT_PARAM_ONKEYDOWN, false, 90)
TryndConfig:addParam("teamfight", "Teamfight", SCRIPT_PARAM_ONKEYDOWN, false, 84)
TryndConfig:addParam("rr", "Check To R", SCRIPT_PARAM_ONKEYDOWN, false, 89)
TryndConfig:addParam("smite", "Smitesteal", SCRIPT_PARAM_ONKEYTOGGLE, true, 48)
TryndConfig:addParam("r", "Auto R", SCRIPT_PARAM_ONKEYTOGGLE, true, 57)
TryndConfig:addParam("w", "Auto Slow", SCRIPT_PARAM_ONKEYTOGGLE, true, 56)
TryndConfig:addParam("q", "Auto Q Heal", SCRIPT_PARAM_ONKEYTOGGLE, true, 55)
--TryndConfig:addParam("p", "Pink for Invisible Enemies", SCRIPT_PARAM_ONKEYTOGGLE, false, 119)
TryndConfig:addParam("cleanse", "Cleanse", SCRIPT_PARAM_ONOFF, true)
TryndConfig:addParam("k", "Killsteal", SCRIPT_PARAM_ONOFF, true)
TryndConfig:addParam("draw", "Draw AAs, CRITS", SCRIPT_PARAM_ONOFF, true)
TryndConfig:permaShow("teamfight")
TryndConfig:permaShow("k")
TryndConfig:permaShow("smite")
TryndConfig:permaShow("r")
TryndConfig:permaShow("w")

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
	
	visEnemiesInRange={}
	for i=1, objManager:GetMaxHeroes(), 1 do
                hero = objManager:GetHero(i)
		if hero~=nil and hero.team~=myHero.team and hero.visible==1 and GetD(hero)<400 then
			table.insert(visEnemiesInRange, i)
		end
	end
	
	
	cc=cc+1
	if (cc==30) then
		LoadTable()
	end
	for i=1, #skillshotArray, 1 do 
		if os.clock() > (skillshotArray[i].lastshot + skillshotArray[i].time) then
        	skillshotArray[i].shot = 0
    	end
    end
	
	
	--if IsChatOpen()==0 and TryndConfig.pos then
		--run_every(1,printC)
	--end
	
	target=GetWeakEnemy("PHYS", 700)
	targetnear=GetWeakEnemy("PHYS", 500,"NEARMOUSE")
	enemyinRange=GetWeakEnemy("PHYS", 700)
	
	target400=GetWeakEnemy("PHYS", 400)
	target600=GetWeakEnemy("PHYS", 600)
    	ignite()
	if TryndConfig.smite then smitesteal() end
	if TryndConfig.k then killsteal() end
	checkDie=false
	if TryndConfig.r then AutoR() end
	if TryndConfig.rr and not TryndConfig.r then AutoR() end
	if TryndConfig.p then autoPink() end
	if TryndConfig.w then autoW() end
	if TryndConfig.cleanse then check4Cleanse() end
	checkUlting()
	if TryndConfig.q then autoQ() end
	
	if Ignited==true then
		if TryndConfig.cleanse and key~=nil and Qsafe==true and RRDY==0 and myHero.health<((IgniteEnemyLevel*20)+50)/5*(math.ceil(igniteTimer-os.clock())) then
			CastSpellTarget(key,myHero)
		end
		if igniteTimer<os.clock() then
			Ignited=false
		end
	end
	if IsChatOpen()==0 and TryndConfig.teamfight then
		if target~=nil then
			local Edmg=getDmg('E',target,myHero)*ERDY
			local AAdmg=getDmg('AD',target,myHero)

			if target.health<(Edmg+ignitedamage) and GetD(target)<660 then
				if ERDY==1 then CastSpellXYZ('E',GetFireahead(target,2,13))
				elseif ignitedamage~=0 then CastSummonerIgnite(target)
				AttackTarget(target)
				end
				
			end
	
		
			local tfx,tfy,tfz = GetFireahead(target,2,13)
			local tfa ={x=tfx,y=tfy,z=tfz}
			local tsafe=true
			run_every(1,findTurret)
				for _, tur in ipairs(enemyTurrets) do
					if tur~=nil then
						
						if target~=nil and GetD(tur.object,tfa)>tur.range then
							tsafe=true
						elseif target~=nil and GetD(tur.object,tfa)<=tur.range then
							tsafe=false
						else
							tsafe=false
						end
				
						if tsafe==false then
							break
						end
					end
				end	
			if RRDY==1 then	
				AutoR()
			elseif QRDY==1 then
				autoQ()
			end
			if WRDY==1 then
				autoW()
			end
			if ERDY==1 and GetD(target)>200 and (RRDY==1 or tsafe==true) then 
				CastSpellXYZ("E",GetFireahead(target,2,13)) 
				
			elseif targetnear~=nil then
				AttackTarget(targetnear)
				if GetD(targetnear)<400 then UseAllItems(targetnear) 
				elseif GetD(target)<600 then UseTargetItems(target)
				end
			else
				AttackTarget(target)
				if GetD(target)<600 then UseTargetItems(target)
				end
			end
		else 
			MoveToMouse()
		end
	end
	
	if IsChatOpen()==0 and TryndConfig.e then Escape() end
end

--function printC()
--	coordCount=coordCount+1
--	printtext("\nPos  "..coordCount.."  " ..myHero.x .. "  "..myHero.y .. "  "..myHero.z)
--end

------------------------------------------------------ Check If In Spell Stuff

function dodgeaoe(pos1, pos2, radius)
    local calc = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
    if calc < radius then
		
        			if RRDY==1 then
					CastSpellTarget("R",myHero)
        			elseif Qsafe==true then 
					CastSpellTarget("Q",myHero)
					CastSummonerBarrier()
					CastSummonerHeal()
    				end
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
	
        			if RRDY==1 then
					CastSpellTarget("R",myHero)
        			elseif Qsafe==true then 
					CastSpellTarget("Q",myHero)
					CastSummonerBarrier()
					CastSummonerHeal()
    				end
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
		
        			if RRDY==1 then
					CastSpellTarget("R",myHero)
        			elseif Qsafe==true then 
					CastSpellTarget("Q",myHero)
					CastSummonerBarrier()
					CastSummonerHeal()
    				end
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



function OnProcessSpell(unit,spell)
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
	local checkInSpell=false
		if unit.team~=myHero.team and string.find(spell.name,"SummonerDot") and spell.target~=nil and spell.target.name==myHero.name then
			igniteTimer=os.clock()+5
			IgniteEnemyLevel=unit.selflevel
			Ignited=true
		end
		if checkDie==true and unit~= nil and unit.name~="Worm" and spell ~= nil and unit.team ~= myHero.team and spell.target~=nil and spell.target.name~=nil and spell.target.name == myHero.name then
			--print("\nI: " .. spell.target.name .. "  S " .. spell.name .. "\n Q " .. Q.. "  W " .. W .. "  E " .. E .. "  R " .. R)
			--print("\nB: " .. unit.name)
    		if spell.name == Q then
    			if spellDmg[unit.name] and spellDmg[unit.name]~=nil and getDmg("Q",myHero,unit)~=nil and getDmg("Q",myHero,unit) > myHero.health then
        			if RRDY==1 then
					CastSpellTarget("R",myHero)
        			elseif Qsafe==true then 
					CastSpellTarget("Q",myHero)
					CastSummonerBarrier()
					CastSummonerHeal()
    				end
			end
    		
			elseif spell.name == W then
				
        		if spellDmg[unit.name] and spellDmg[unit.name]~=nil and getDmg("W",myHero,unit)~=nil and getDmg("W",myHero,unit) > myHero.health then
        			if RRDY==1 then
					CastSpellTarget("R",myHero)
        			elseif Qsafe==true then 
					CastSpellTarget("Q",myHero)
					CastSummonerBarrier()
					CastSummonerHeal()
    				end
				end
    		
		elseif spell.name == E then
    			if spellDmg[unit.name] and spellDmg[unit.name]~=nil and getDmg("E",myHero,unit)~=nil and getDmg("E",myHero,unit) > myHero.health then
   			     	if RRDY==1 then
					CastSpellTarget("R",myHero)
        			elseif Qsafe==true then 
					CastSpellTarget("Q",myHero)
					CastSummonerBarrier()
					CastSummonerHeal()
    				end
        		end

		elseif spell.name == R then
        		if spellDmg[unit.name] and spellDmg[unit.name]~=nil and getDmg("R",myHero,unit)~=nil and getDmg("R",myHero,unit) > myHero.health then
        			if RRDY==1 then
					CastSpellTarget("R",myHero)
        			elseif Qsafe==true then 
					CastSpellTarget("Q",myHero)
					CastSummonerBarrier()
					CastSummonerHeal()
    				end
        		end
    		
		elseif spell.name:find("BasicAttack") or spell.name:find("BasicAttack2") or spell.name:find("BasicaAttack3")  or spell.name:find("ChaosTurretFire") then
        		if (unit.baseDamage + unit.addDamage) > myHero.health then
        			if RRDY==1 then
					CastSpellTarget("R",myHero)
        			elseif Qsafe==true then
					CastSpellTarget("Q",myHero)
					CastSummonerBarrier()
					CastSummonerHeal()
    				end
				end	
		elseif spell.name:find("CritAttack") then
        		if 2*(unit.baseDamage + unit.addDamage) > myHero.health then
        			if RRDY==1 then
					CastSpellTarget("R",myHero)
        			elseif Qsafe==true then
					CastSpellTarget("Q",myHero)
					CastSummonerBarrier()
					CastSummonerHeal()
    				end
				end
        	end
    
	end   
	
	
	if unit~=nil and spell~=nil and GetD(unit)<600 then
		if spell.target~=nil and spell.target.name~=nil then
		end
	end
	if unit.charName==myHero.charName and spell~=nil then
			--print("\nI: " .. unit.name .. " " .. spell.name)
		if spell.name:find("UndyingRage") then
			Ulting=true
			Qsafe=false
			UltT=os.clock()
		end
	end
    
	
	if checkDie==true then
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

function checkUlting()
	if GetSpellLevel('R')>0 then
		if Ulting==true then
			if Qsafe==false and os.clock()>UltT+4 then
				Qsafe=true
			end
			if os.clock()>UltT+5 then
				Ulting=false
			end
		end
	end
end

function check4Cleanse()
    if myHero.SummonerD == 'SummonerBoost' and IsSpellReady('D')==1 then
        key='D'
    elseif myHero.SummonerF == 'SummonerBoost' and IsSpellReady('F')==1 then
        key='F'
    else
        key=nil
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

function smitesteal()
	if myHero.SummonerD == "SummonerSmite" then
		CastHotkey("AUTO 100,0 SPELLF:SMITESTEAL RANGE=800 TRUE COOLDOWN")
		return
	end
	if myHero.SummonerF == "SummonerSmite" then
		CastHotkey("AUTO 100,0 SPELLF:SMITESTEAL RANGE=800 TRUE COOLDOWN")
		return
	end
end

function autoQ()
	  if QRDY==1 and enemyinRange~=nil and RRDY==0 and Qsafe==true then
      if myHero.health < ((myHero.maxHealth*30)/100) then 
			CastSpellTarget("Q",myHero)
		end
	end
end

function autoW()
	if target~=nil then
	if WRDY==1 and (runningAway(target)) then

		CastSpellTarget("W",myHero)
	elseif WRDY==1 and (target.baseDamage+target.addDamage) > (myHero.baseDamage+myHero.addDamage) and GetD(target)<450 then
		CastSpellTarget("W",myHero)
	end
	end
end

function AutoR()
	if RRDY==1 then
		if myHero.health < ((myHero.maxHealth*20)/100) and enemyinRange~=nil then 
			CastSpellTarget("R",myHero)
		end
	end
	checkDie=true
end

function OnCreateObj(object)
    if TryndConfig.cleanse and Qsafe==true then
        if listContains(QSS, object.charName) and (GetDistance(myHero, object)) < 100 then
            GetInventorySlot(3139)
            UseItemOnTarget(3139, myHero)
            GetInventorySlot(3140)
            UseItemOnTarget(3140, myHero)
        end
    
        if listContains(Cleanselist, object.charName) and key~=nil then
            CastSpellTarget(key,myHero)
        end        
    end
end

function listContains(list, particleName)
        for _, particle in pairs(list) do
                if particleName:find(particle) then return true end
        end
        return false
end

function Escape()
	if ERDY==1 then
		CastSpellXYZ('E',mousePos.x,mousePos.y,mousePos.z)
	end
	if target400~=nil then
		UseAllItems(target400)
	elseif target600~=nil then
		UseTargetItems(target600)
	end
	MoveToMouse()
end

--[[
function insideBush(champ)
	if champ~=nil then
		local xt = champ.x
		local zt = champ.z
		local a, b, c, d
		for i, coors in ipairs(bushQuads) do
			xx1 = coors.x1
			zz1 = coors.z1
			xx2 = coors.x2
			zz2 = coors.z2
			xx3 = coors.x3
			zz3 = coors.z3
			xx4 = coors.x4
			zz4 = coors.z4
			a = (xx1 - xt) * (zz2 - zt) - (xx2 - xt) * (zz1 - zt)
			b = (xx2 - xt) * (zz3 - zt) - (xx3 - xt) * (zz2 - zt)
			c = (xx3 - xt) * (zz4 - zt) - (xx4 - xt) * (zz3 - zt)
			d = (xx4 - xt) * (zz1 - zt) - (xx1 - xt) * (zz4 - zt)
			if (((a>0 and b>0) or (a<0 and b<0) or (a==0 and b==0)) and ((b>0 and c>0) or (b<0 and c<0) or (b==0 and c==0)) and ((c>0 and d>0) or (c<0 and d<0) or (c==0 and d==0))) then
				return true
			end
		end
	end
	return false
end

function outOfRangeofOthers(champion)
	if champion~=nil then
		local x1, z1, x2, z2, x3, z3, x4, z4, a, b, c, d
		local bushX,bushZ
		local bushRange
		for i, coors in ipairs(bushQuads) do
			x1 = coors.x1
			z1 = coors.z1
			x2 = coors.x2
			z2 = coors.z2
			x3 = coors.x3
			z3 = coors.z3
			x4 = coors.x4
			z4 = coors.z4
			bushX=(x1+x2+x3+x4)/4
			bushZ=(z1+z2+z3+z4)/4
			local cBush = {x=bushX,y=0,z=bushZ}
			local c1,c2,c3,c4 = {x=x1,y=0,z=z1},{x=x2,y=0,z=z2},{x=x3,y=0,z=z3},{x=x4,y=0,z=z4}
			bushRange=GetD(cBush,c1)
			if GetD(cBush,c2)>bushRange then
				bushRange=GetD(cBush,c2)
			end
			if GetD(cBush,c3)>bushRange then
				bushRange=GetD(cBush,c3)
			end
			if GetD(cBush,c4)>bushRange then
				bushRange=GetD(cBush,c4)
			end
			
			if x1~=xx1 and x2~=xx2 and x3~=xx3 and x4~=xx4 and z1~=zz1 and z2~=zz2 and z3~=zz3 and z4~=zz4 and GetD(cBush,champion)<400+bushRange then
				return false
			end
		end
	end
	return true
end

function outOfRangeofBush(champion)
	if champion~=nil then
		local x1, z1, x2, z2, x3, z3, x4, z4, a, b, c, d
		local bushX,bushZ
		local bushRange
		for i, coors in ipairs(bushQuads) do
			x1 = coors.x1
			z1 = coors.z1
			x2 = coors.x2
			z2 = coors.z2
			x3 = coors.x3
			z3 = coors.z3
			x4 = coors.x4
			z4 = coors.z4
			bushX=(x1+x2+x3+x4)/4
			bushZ=(z1+z2+z3+z4)/4
			local cBush = {x=bushX,y=0,z=bushZ}
			local c1,c2,c3,c4 = {x=x1,y=0,z=z1},{x=x2,y=0,z=z2},{x=x3,y=0,z=z3},{x=x4,y=0,z=z4}
			bushRange=GetD(cBush,c1)
			if GetD(cBush,c2)>bushRange then
				bushRange=GetD(cBush,c2)
			end
			if GetD(cBush,c3)>bushRange then
				bushRange=GetD(cBush,c3)
			end
			if GetD(cBush,c4)>bushRange then
				bushRange=GetD(cBush,c4)
			end
			
			if GetD(cBush,champion)<400+bushRange then
				return false
			end
		end
	end
	return true
end
--]]
function OnDraw()
	if myHero.dead~=1 then
		CustomCircle(400,4,3,myHero)

		for i=1, objManager:GetMaxHeroes(), 1 do
                        local object = objManager:GetHero(i)
                        if object ~= nil and object.team ~= myHero.team and object.visible==1 and GetD(object,myHero)<1600 and TryndConfig.draw then   
                                DrawTextObject("\n\n"..(math.floor(object.health/getDmg("AD",object,myHero)))+1 .." AAs",object,Color.White)
				DrawTextObject("\n\n\n"..(math.floor(object.health/(2*getDmg("AD",object,myHero))))+1 .." CRITS",object,Color.Red)
                        end
                end

	end
	
	if target ~=nil and target.dead~=1 then
	CustomCircle(150,4,5,target)
	
	end
end


function runningAway(slowtarget)

   local d1 = GetD(slowtarget)
   local x, y, z = GetFireahead(slowtarget,1,99)
   local d2 = GetD({x=x, y=y, z=z})
   local d3 = GetD({x=x, y=y, z=z},slowtarget)
   local angle = math.acos((d2*d2-d3*d3-d1*d1)/(-2*d3*d1))
   
   return (angle%(2*math.pi)>math.pi/2 and angle%(2*math.pi)<math.pi*3/2)

end

function killsteal()
	if target~=nil then
		local Edmg=getDmg('E',target,myHero)*ERDY
		local AAdmg=getDmg('AD',target,myHero)

		if target.health<(Edmg+ignitedamage) and GetD(target)<660 then
			if ERDY==1 then CastSpellXYZ('E',GetFireahead(target,2,13)) end
			AttackTarget(target)
			if ignitedamage~=0 then CastSummonerIgnite(target) end
		end
	
	end
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

            --------------------------------------------W usage for PinkWards
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

--[[
function autoPink()
	if (insideBush(myHero) and outOfRangeofOthers(myHero)) or outOfRangeofBush(myHero) then
		if #visEnemiesInRange==0 then
			print("\nN "..#visEnemiesInRange)
			if WRDY==1 then
				run_every(1,pink)
			end	
      	end
	elseif not (insideBush(myHero) and outOfRangeofOthers(myHero)) and not outOfRangeofBush(myHero) then	
		if #visEnemiesInRange==0 then
			print("\nN "..#visEnemiesInRange)
			if WRDY==1 then
				local textColor
				if colorCheck<190 then
					textColor = Color.SkyBlue
				elseif colorCheck>=190 then
					textColor = Color.Red
				end
				DrawText("ENEMY IN NEARBY BUSH ", 800, 100, textColor)
				colorCheck = (colorCheck+1)%400
			end	
      	end
	end
end

function pink()
	UseItemLocation(2043, myHero.x, myHero.y, myHero.z)
end
--]]

SetTimerCallback("Run")