--[[
Mal's Morde
Version 2.7
Hotkey X -> Harass, will use E on enemy in range, will W yourself if enemy in range, will use 
				Q if enemy in range of Autoattack, will ult if it will kill them.
Hotkey T -> Teamfight, will use all abilities if a target is in range of them to sustain your 
				shield, it will always look for the weakest target in 1000 range and will try
				to get into range of them and then use all abilities on them. Sustain enemy
				marked by yellow circle, main enemy marked by deep Pink circle. This will only
				ult the enemy that you have chosen with the Ult Priority cycle. (If killsteal is
				off). If the ult prioritized enemy is within range you will only ult them if they
				are killable with ult by first contact or before it weras off, will also use 
				ignite to insure the kill, if they don't die on contact with ult.
				It will also ult the enemy if you are below 25% hp, but not if then enemy you
				prioritized isn't around! So you may need to manually ult then or change priority
				to Regular.
Toggle 7 -> AutoQ
Toggle 8 -> AutoE
Toggle 9 -> Auto Dodge some skillshots
Cycle 0 -> Who you want to focus with your ult
Toggle "Minus Sign" -> Your ghost pet will automatically attack weakest enemy
In-Game Switch -> Draw E Cone, if target in range, will draw the best placement for your 
					cone depending on enemy champions and minions.
In-Game Switch -> Auto Zhonyas, auto heal and auto barrier, in close situations, does not 
					mean you shouldn't activate manually, this may save you sometimes othertimes 
					you will died 
					because you didn't manually activate it.
In-Game Switch -> Killsteal Combo, will ks with everything, but will only ks with ult if it 
					will kill them on contact
In-Game Switch -> Ignite Killsteal Combos, will do everything of killsteal switch but will 
					also use ult and ignite if they will kill your target at the last second 
					of damage dealt or the first.
In-Game Switch -> Auto Potions will pop at 30% hp if on, this is in case you decide to go 
					5 potions in the beginning since it is a tactic.
In-Game Switch -> Smitesteal, in case you are trolling.


--]]
require 'Utils'
require 'spell_damage'
print=printtext
print("\nMorde\n")
print("\nBy Malbert\n")
print('\nVersion 2.7\n')

local targetult
local target600
local target
local allies={}
local enemies={}
local ignitedamage=0
local startAttackSpeed = 0.694
--------Spell Stuff


local egg = {team = 0, enemy = 0}
local zac = {team = 0, enemy = 0}
local aatrox = {team = 0, enemy = 0}

local cc = 0
local _registry = {}
local skillshotArray = { 
}
local colorcyan = 0x0000FFFF
local coloryellow = 0xFFFFFF00
local colorgreen = 0xFF00FF00
local drawskillshot = true
local playerradius = 150
local skillshotcharexist = false
local dodgeskillshotkey = 74 -- dodge skillshot key J
local show_allies=0

local checkDie=false

local numberOfEnemies=0

local QQclose=0
local QQQclose=0
local WWclose=0
local EEclose=0
local RRclose=0
local RRRclose=0
local RRSclose=0
local AAclose=0
local RR=0
local RRR=0
local RRS=0

local ghostobject=nil
local RWindowTime=0
	 --Q 250  
	 --W 300  3.79, 11.1
	 --E 700 3.19,50
	 --R 850  3.33 MordekaiserChildrenOfTheGrave

local twfx,twfy,twfz
local twfa
			
local tefx,tefy,tefz 
local tefa

local tufx,tufy,tufz 
local tufa

local wUsedAt = 0
local vUsedAt = 0
local timer=os.clock()
local bluePill = nil
local enemyIndex=2
local QRDY=0
local WRDY=0
local ERDY=0
local RRDY=0
local EFA=0

local targetItems={3144,3153,3128,3092,3146}
--Bilgewater,BoTRK,DFG,FrostQueen,Hextech
local aoeItems={3184,3143,3074,3180,3131,3069,3077,3023,3290,3142}
--Entropy,Randuins,Hydra,Odyns,SwordDivine,TalismanAsc,Tiamat,TwinShadows,TwinShadows,YoGBlade
local DFG=3128

MordeConfig = scriptConfig("Morde", "Morde Config")
MordeConfig:addParam("h", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, 88)
MordeConfig:addParam("teamfight", "All In Teamfight", SCRIPT_PARAM_ONKEYDOWN, false, 84)
MordeConfig:addParam("q", "AutoQ", SCRIPT_PARAM_ONKEYTOGGLE, false, 55)
MordeConfig:addParam("e", "AutoE", SCRIPT_PARAM_ONKEYTOGGLE, false, 56)
MordeConfig:addParam("ult", "Ult Priority", SCRIPT_PARAM_NUMERICUPDOWN, 1, 48,1,objManager:GetMaxHeroes()/2+1,1)

MordeConfig:addParam("gh", "Auto Ghost Attack", SCRIPT_PARAM_ONKEYTOGGLE, true, 189)
MordeConfig:addParam('efa', "E Fireahead", SCRIPT_PARAM_NUMERICUPDOWN, 3.2, 187,2,10,0.1)
MordeConfig:addParam("eDraw", "Draw E Cone", SCRIPT_PARAM_ONOFF, true)
MordeConfig:addParam("zh", "Zhonyas", SCRIPT_PARAM_ONOFF, false)
MordeConfig:addParam("ks", "KillSteal Combos", SCRIPT_PARAM_ONOFF, true)
MordeConfig:addParam("lks", "Ignite Killsteal Combos", SCRIPT_PARAM_ONOFF, true)
MordeConfig:addParam("pots", "Auto Potions", SCRIPT_PARAM_ONOFF, true)
MordeConfig:addParam("nm", "NearMouse Targeting", SCRIPT_PARAM_ONOFF, true)
MordeConfig:addParam("smite", "Smitesteal", SCRIPT_PARAM_ONKEYTOGGLE, false, 119)
MordeConfig:permaShow("teamfight")
MordeConfig:permaShow("q")
MordeConfig:permaShow("e")
MordeConfig:permaShow("ult")
MordeConfig:permaShow("gh")
     

function Run()
	if cc<40 then cc=cc+1 if cc==30 then LoadTable() end end
	checkDie=false
        if MordeConfig.zh then
                checkDie=true
                if target~=nil and myHero.health<myHero.maxHealth*15/100 then
                        zhonyas()
                end
        else
                checkDie=false
        end
	EFA=MordeConfig.efa

	for i=1, objManager:GetMaxHeroes(), 1 do
		hero = objManager:GetHero(i)
		if hero~=nil and hero.team~=myHero.team and enemies[hero.name]==nil then
			enemies[hero.name]={unit=hero,number=enemyIndex}
			enemyIndex=enemyIndex+1
		elseif hero~=nil and hero.team==myHero.team and allies[hero.name]==nil then
			allies[hero.name]=hero
		end
	end
	--print("\n NUM "..numberOfEnemies)
	numberOfEnemies=math.max(numberOfEnemies,objManager:GetMaxHeroes()/2+1)
	targetult = GetBestEnemy("MAGIC", 900)
	target600 = GetBestEnemy("TRUE", 600)
	if MordeConfig.nm==true then
		target = GetBestEnemy("MAGIC",800,"NEARMOUSE")
	else
		target = GetBestEnemy("MAGIC",800)
	end
	

	if MordeConfig.ult>1 then
	
		local tu
		for i, enemy in pairs(enemies) do
			if enemy~=nil and enemy.dead~=1 and enemy.number==MordeConfig.ult then
				tu=enemy.unit
				--print("\n Target is -> "..tu.name)
				break
			end
		end
		
			tufx,tufy,tufz = GetFireahead(tu,EFA,0)
			tufa={x=tufx,y=0,z=tufz}
		
		if tu~=nil and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" then
			RR = CalcMagicDamage(tu,(9.5+2.5*GetSpellLevel('R')+2*(math.floor(myHero.ap/100)))*tu.maxHealth/100)*RRDY
			RRS = CalcMagicDamage(tu,(0.95+0.25*GetSpellLevel('R')+0.2*(math.floor(myHero.ap/100)))*tu.maxHealth/100)*RRDY
			RRR = CalcMagicDamage(tu,(19+5*GetSpellLevel('R')+4*(math.floor(myHero.ap/100)))*tu.maxHealth/100)*RRDY
			RRclose = CalcMagicDamage(tu,(9.5+2.5*GetSpellLevel('R')+2*(math.floor(myHero.ap/100)))*tu.maxHealth/100)*RRDY
			RRSclose = CalcMagicDamage(tu,(0.95+0.25*GetSpellLevel('R')+0.2*(math.floor(myHero.ap/100)))*tu.maxHealth/100)*RRDY
			RRRclose = CalcMagicDamage(tu,(19+5*GetSpellLevel('R')+4*(math.floor(myHero.ap/100)))*tu.maxHealth/100)*RRDY
		else
			RR=0
			RRR=0
			RRS=0
			RRclose=0
			RRRclose=0
			RRSclose=0
		end
	
	else
		if targetult~=nil then
			
			if myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" then
				RR = CalcMagicDamage(targetult,(9.5+2.5*GetSpellLevel('R')+2*(math.floor(myHero.ap/100)))*targetult.maxHealth/100)*RRDY
				RRS = CalcMagicDamage(targetult,(0.95+0.25*GetSpellLevel('R')+0.2*(math.floor(myHero.ap/100)))*targetult.maxHealth/100)*RRDY
				RRR = CalcMagicDamage(targetult,(19+5*GetSpellLevel('R')+4*(math.floor(myHero.ap/100)))*targetult.maxHealth/100)*RRDY
			else
				RR=0
				RRR=0
				RRS=0
			end
			
		end
		if target~=nil then
			
			
			if myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" then
				RRclose = CalcMagicDamage(target,(9.5+2.5*GetSpellLevel('R')+2*(math.floor(myHero.ap/100)))*target.maxHealth/100)*RRDY
				RRSclose = CalcMagicDamage(target,(0.95+0.25*GetSpellLevel('R')+0.2*(math.floor(myHero.ap/100)))*target.maxHealth/100)*RRDY
				RRRclose = CalcMagicDamage(target,(19+5*GetSpellLevel('R')+4*(math.floor(myHero.ap/100)))*target.maxHealth/100)*RRDY
			else
				RRclose=0
				RRRclose=0
				RRSclose=0
			end
			
		end
	end
	if target~=nil then
	
			twfx,twfy,twfz = GetFireahead(target,3.79,0)
			twfa={x=twfx,y=0,z=twfz}
			
			tefx,tefy,tefz = GetFireahead(target,EFA,0)
			tefa={x=tefx,y=0,z=tefz}
			--DrawCircle(tefx,tefy,tefz,7,5)
				
			QQclose = getDmg('Q',target,myHero)*QRDY
			QQQclose = getDmg('Q',target,myHero,3)*QRDY
			WWclose = getDmg('W',target,myHero)*WRDY
			EEclose = getDmg('E',target,myHero)*ERDY
			AAclose = getDmg('AD',target,myHero)
			
	end

	
	
	
	ignite()
	if MordeConfig.q then autoQ() end
	if MordeConfig.e then autoE() end
	if MordeConfig.ks and not MordeConfig.lks then killsteal() end
	if MordeConfig.lks then lingeringKS() end
	if MordeConfig.pots then RedElixir() end
	if MordeConfig.smite then smitesteal() end
	

			
	if IsChatOpen() == 0 and MordeConfig.teamfight then
		fight()
	end
		
		


	if IsChatOpen() == 0 and MordeConfig.h then
		harass()
	end
	
	if MordeConfig.gh then
		GhostAttack(1125,0.6,"MAGIC","mordekaisercotgguide")
	end
	

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
	
	if drawskillshot == true then
        for i=1, #skillshotArray, 1 do
            if skillshotArray[i].shot == 1 then
                local radius = skillshotArray[i].radius
                local color = skillshotArray[i].color
				if skillshotArray[i].isline == false then
					for number, point in pairs(skillshotArray[i].skillshotpoint) do
						DrawCircle(point.x, point.y, point.z, radius, color)
					end
				else
					startVector = Vector(skillshotArray[i].p1x,skillshotArray[i].p1y,skillshotArray[i].p1z)
					endVector = Vector(skillshotArray[i].p2x,skillshotArray[i].p2y,skillshotArray[i].p2z)
					directionVector = (endVector-startVector):normalized()
					local angle=0
					if (math.abs(directionVector.x)<.00001) then
						if directionVector.z > 0 then angle=90
						elseif directionVector.z < 0 then angle=270
						else angle=0
						end
					else
						local theta = math.deg(math.atan(directionVector.z / directionVector.x))
						if directionVector.x < 0 then theta = theta + 180 end
						if theta < 0 then theta = theta + 360 end
						angle=theta
					end
				angle=((90-angle)*2*math.pi)/360
				DrawLine(startVector.x, startVector.y, startVector.z, GetDistance(startVector, endVector)+170, 1,angle,radius)
				end
            end
        end
    end
	for i=1, #skillshotArray, 1 do 
		if os.clock() > (skillshotArray[i].lastshot + skillshotArray[i].time) then
        	skillshotArray[i].shot = 0
    	end
    end
        
end
     

local Rcast=0
function GhostAttack(range,delay,dmg_type,name)
	if Rcast<os.clock() and RRDY==1 then
		local divisor=math.floor(math.sqrt(range)/10)
		for i=0,range,range/divisor do
			local num= range/divisor+i
			local targetghost=GetBestEnemy(dmg_type,num)
			if myHero.SpellNameR==name and Rcast<os.clock() and targetghost~=nil  and ghostobject~=nil and ((GetD(ghostobject,targetghost)<600 and not runningAway(targetghost,ghostobject)) or GetD(ghostobject,targetghost)<350 or (num>=range)) then
				CastSpellTarget('R',targetghost)
				Rcast=os.clock()+delay
			end
			if targetghost~=nil and Rcast>=os.clock() then
						break
			end
		end
	end
end

function harass()
	if target~=nil then
		if QRDY==1 and GetD(target)<myHero.range+50 then
			CastSpellTarget("Q",target)
			AttackTarget(target)
		end
		if ERDY==1 and GetD(tefa)<700 then
			CastSpellXYZ('E',bestE(target))
		end
		if WRDY==1 and GetD(twfa)<300 then
			CastSpellTarget("W",myHero)
		elseif WRDY==1 and allySurroundedMost()~=nil then
			CastSpellTarget('W',allySurroundedMost())
		end
		if GetD(target)<500 then
			AttackTarget(target)
		else
			MoveToMouse()
		end
	else
		MoveToMouse()
	end
end


function fight()
	--print('\n' ..myHero.SpellNameR)
	if target~=nil then
		if GetInventorySlot(3128)~=nil and myHero["SpellTime"..GetInventorySlot(3128)]>1.0 and GetD(target)<600 then
			CastSpellTarget(tostring(GetInventorySlot(3128)),target)
		end
		local tu =targetult
		for i, enemy in pairs(enemies) do
			if enemy.number==MordeConfig.ult and enemy.number ~=1 then
				tu=enemy.unit
				break
			end
		end
		if GetD(tu)<850 then
			if RRDY==1 and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and IsInvulnerable(tu).status==0 and tu.visible==1 and tu.health<RR then 
				CastSpellTarget('R',tu)
			elseif RRDY==1 and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and tu.invulnerable~=1 and IsInvulnerable(tu).status==0 and ((tu.health<RRR and ignitedamage>0)) and GetD(tu)<600  then 
				CastSummonerIgnite(tu)
				CastSpellTarget('R',tu)
			elseif RRDY==1 and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and IsInvulnerable(tu).status==0 and tu.visible==1 and myHero.health<25/100*myHero.maxHealth then
				CastSummonerIgnite(tu)
				CastSpellTarget('R',tu)
			end
		end
		
		
		if QRDY==1 and GetD(target)<myHero.range+50 then
			CastSpellTarget("Q",target)
			AttackTarget(target)
		end
		if ERDY==1 and GetD(tefa)<700 then
			CastSpellXYZ('E',bestE(target))
		end
		if WRDY==1 and GetD(twfa)<300 then
			CastSpellTarget("W",myHero)
		elseif WRDY==1 and allySurroundedMost()~=nil then
			CastSpellTarget('W',allySurroundedMost())
		end
		if  GetD(target)<400 then
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
		AttackTarget(target)
		
	elseif targetult~=nil then
		local tu =targetult
		for i, enemy in pairs(enemies) do
			if enemy.number==MordeConfig.ult and enemy.number ~=1 then
				tu=enemy.unit
				break
			end
		end
				
		if GetD(tu)<850 then
			if RRDY==1 and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and IsInvulnerable(tu).status==0 and tu.visible==1 and tu.health<RR then 
				CastSpellTarget('R',tu)
			elseif RRDY==1 and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and IsInvulnerable(tu).status==0 and tu.visible==1 and ((tu.health<RRR and ignitedamage>0)) and GetD(tu)<600 then 
				CastSummonerIgnite(tu)
				CastSpellTarget('R',tu)
			elseif WRDY==1 and allySurroundedMost()~=nil then
				CastSpellTarget('W',allySurroundedMost())
			elseif RRDY==1 and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and IsInvulnerable(tu).status==0 and tu.visible==1 and myHero.health<25/100*myHero.maxHealth then
				CastSummonerIgnite(tu)
				CastSpellTarget('R',tu)
			else
				MoveToMouse()
			end
		else
			MoveToMouse()
		end
	else
		MoveToMouse()
	end

end

function autoQ()
	if target~=nil and QRDY==1 and GetD(target)<myHero.range+50 then
		CastSpellTarget('Q',myHero)
		AttackTarget(target)
	end
end

function autoE()
	if target~=nil and ERDY==1 and GetD(tefa)<700 then
		CastSpellXYZ('E',bestE(target))
	end
end


function surrounded(self)
	local count=0
	for i=1, objManager:GetMaxHeroes(), 1 do
		hero = objManager:GetHero(i)
		if hero~=nil and hero~=self and hero.team~=myHero.team and hero.visible==1 and GetD(self,hero)<600 then
			count=count+1
			--table.insert(enemies,hero)
		end
	end
	local enemyMinions = GetEnemyMinions(MINION_SORT_HEALTH_ASC)
 
    for _, minion in pairs(enemyMinions) do
		if minion~=nil and minion.visible==1 and GetD(self,minion)<600 then
			count=count+1
			--table.insert(enemies,hero)
		end
	end
	if count>1 then
		return true
	elseif count==1 then
		return false
	else 
		return nil
	end
end


function allySurroundedMost()
	local unit=nil
	local previousCount=0
	local presentCount=0
	for i, ally in pairs(allies) do
		if ally~=nil and ally.dead~=1 and GetD(ally)<750 then
			presentCount=0
			for j, enemy in pairs(enemies) do
				if enemy~=nil and enemy.dead~=1 and GetD(ally,enemy)<525 then
					presentCount=presentCount+1
				end
			end
			if presentCount>previousCount then
				previousCount=presentCount
				unit=ally
			end
		end
	end
	return unit
			

end


function smitesteal()
	if myHero.SummonerD == "SummonerSmite" then
		CastHotkey("AUTO 100,0 SPELLD:SMITESTEAL RANGE=700 TRUE COOLDOWN")
	elseif myHero.SummonerF == "SummonerSmite" then
		CastHotkey("AUTO 100,0 SPELLF:SMITESTEAL RANGE=700 TRUE COOLDOWN")		
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


function killsteal()
	if targetult~=nil then
		local tu
		for i, enemy in pairs(enemies) do
		if enemy~=nil and enemy.dead~=1 and IsInvulnerable(enemy).status==0 and enemy.visible==1 and enemy.number~=1 and enemy.number==MordeConfig.ult then
				tu=enemy.unit
				--print("\n Target is -> "..tu.name)
				break
			end
		end
		if tu~=nil then
			if tu.health<RR then
				CastSpellTarget("R",tu)
			end
		elseif MordeConfig.ult==1 and targetult.health<RR then
			CastSpellTarget("R",targetult)
		end
		
		if target~=nil then
			
			if tu~=nil then
				
				if target.health<QQclose+EEclose and GetD(target)<myHero.range+50 then
					CastSpellTarget('Q',myHero)
					AttackTarget(target)
					CastSpellXYZ('E',bestE(target))
				elseif surrounded(myHero)==false and target.health<QQQclose+EEclose and GetD(target)<myHero.range+50 then
					CastSpellTarget('Q',myHero)
					AttackTarget(target)
					CastSpellXYZ('E',bestE(target))
				elseif target.health<EEclose and GetD(tefa)<700 then
					CastSpellXYZ('E',bestE(target))
				end
				local QQtu = getDmg('Q',tu,myHero)*QRDY
				local QQQtu = getDmg('Q',tu,myHero,3)*QRDY
				local EEtu = getDmg('E',tu,myHero)*ERDY--[[
				if myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" then
				RRclose = CalcMagicDamage(tu,(9.5+2.5*GetSpellLevel('R')+2*(math.floor(myHero.ap/100)))*tu.maxHealth/100)*RRDY
				RRSclose = CalcMagicDamage(tu,(0.95+0.25*GetSpellLevel('R')+0.2*(math.floor(myHero.ap/100)))*tu.maxHealth/100)*RRDY
				RRRclose = CalcMagicDamage(tu,(19+5*GetSpellLevel('R')+4*(math.floor(myHero.ap/100)))*tu.maxHealth/100)*RRDY
				else
				RRclose=0
				RRRclose=0
				RRSclose=0
				end--]]
				
				if tu.health<QQtu+EEtu+RRclose and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and GetD(tu)<myHero.range+50 then
					CastSpellTarget('Q',myHero)
					AttackTarget(tu)
					CastSpellXYZ('E',bestE(tu))
					CastSpellTarget('R',tu)
					CastSummonerIgnite(tu)
				elseif surrounded(myHero)==false and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.health<QQQtu+EEtu+RRclose and GetD(tu)<myHero.range+50 then
					CastSpellTarget('Q',myHero)
					AttackTarget(tu)
					CastSpellXYZ('E',bestE(tu))
					CastSpellTarget('R',tu)
					CastSummonerIgnite(tu)
				elseif tu.health<EEtu+RRclose and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and GetD(tufa)<700 then
					CastSpellXYZ('E',bestE(tu))
					CastSpellTarget('R',tu)
				end
			else
				if target.health<QQclose+EEclose+RRclose and GetD(target)<myHero.range+50 then
					CastSpellTarget('Q',myHero)
					AttackTarget(target)
					CastSpellXYZ('E',bestE(target))
					if MordeConfig.ult==1 then
						CastSpellTarget('R',target)
					end
				elseif surrounded(myHero)==false and target.health<QQQclose+EEclose+RRclose and GetD(target)<myHero.range+50 then
					CastSpellTarget('Q',myHero)
					AttackTarget(target)
					CastSpellXYZ('E',bestE(target))
					if MordeConfig.ult==1 then
						CastSpellTarget('R',target)
					end
				elseif target.health<EEclose+RRclose and GetD(tefa)<700 then
					CastSpellXYZ('E',bestE(target))
					if MordeConfig.ult==1 then
						CastSpellTarget('R',target)
					end
				end
			end
			
			if target600~=nil and target600.health<ignitedamage then
				CastSummonerIgnite(target600)
			end
			
		end
	end
end

function lingeringKS()
	if targetult~=nil then
		local tu
		for i, enemy in pairs(enemies) do
		if enemy~=nil and enemy.dead~=1 and IsInvulnerable(enemy).status==0 and enemy.visible==1 and enemy.number~=1 and enemy.number==MordeConfig.ult then
				tu=enemy.unit
				--print("\n Target is -> "..tu.name)
				break
			end
		end
		if tu~=nil then
			if tu.health<RR then
				CastSpellTarget("R",tu)
			end
		elseif MordeConfig.ult==1 and targetult.health<RR then
			CastSpellTarget("R",targetult)
		end
		
		if target~=nil then
			
			if tu~=nil then
				
				if target.health<QQclose+EEclose and GetD(target)<myHero.range+50 then
					CastSpellTarget('Q',myHero)
					AttackTarget(target)
					CastSpellXYZ('E',bestE(target))
				elseif surrounded(myHero)==false and target.health<QQQclose+EEclose and GetD(target)<myHero.range+50 then
					CastSpellTarget('Q',myHero)
					AttackTarget(target)
					CastSpellXYZ('E',bestE(target))
				elseif target.health<EEclose and GetD(tefa)<700 then
					CastSpellXYZ('E',bestE(target))
				end
				local QQtu = getDmg('Q',tu,myHero)*QRDY
				local QQQtu = getDmg('Q',tu,myHero,3)*QRDY
				local EEtu = getDmg('E',tu,myHero)*ERDY--[[
				if myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" then
				RRclose = CalcMagicDamage(tu,(9.5+2.5*GetSpellLevel('R')+2*(math.floor(myHero.ap/100)))*tu.maxHealth/100)*RRDY
				RRSclose = CalcMagicDamage(tu,(0.95+0.25*GetSpellLevel('R')+0.2*(math.floor(myHero.ap/100)))*tu.maxHealth/100)*RRDY
				RRRclose = CalcMagicDamage(tu,(19+5*GetSpellLevel('R')+4*(math.floor(myHero.ap/100)))*tu.maxHealth/100)*RRDY
				else
				RRclose=0
				RRRclose=0
				RRSclose=0
				end--]]
				
				if tu.health<QQtu+EEtu+RRclose and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and GetD(tu)<myHero.range+50 then
					CastSpellTarget('Q',myHero)
					AttackTarget(tu)
					CastSpellXYZ('E',bestE(tu))
					CastSpellTarget('R',tu)
					CastSummonerIgnite(tu)
				elseif surrounded(myHero)==false and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.health<QQQtu+EEtu+RRclose and GetD(tu)<myHero.range+50 then
					CastSpellTarget('Q',myHero)
					AttackTarget(tu)
					CastSpellXYZ('E',bestE(tu))
					CastSpellTarget('R',tu)
					CastSummonerIgnite(tu)
				elseif tu.health<EEtu+RRclose and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and GetD(tufa)<700 then
					CastSpellXYZ('E',bestE(tu))
					CastSpellTarget('R',tu)
				elseif tu.health<QQtu+EEtu+RRRclose and ignitedamage>0 and GetD(tu)<myHero.range+50 then
					CastSpellTarget('Q',myHero)
					AttackTarget(tu)
					CastSpellXYZ('E',bestE(tu))
					CastSpellTarget('R',tu)
					CastSummonerIgnite(tu)
				elseif surrounded(myHero)==false and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.health<QQQtu+EEtu+RRRclose and ignitedamage>0 and GetD(tu)<myHero.range+50 then
					CastSpellTarget('Q',myHero)
					AttackTarget(tu)
					CastSpellXYZ('E',bestE(tu))
					CastSpellTarget('R',tu)
					CastSummonerIgnite(tu)
				elseif tu.health<EEtu+RRRclose and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and ignitedamage>0 and GetD(tu)<600 then
					CastSpellXYZ('E',bestE(tu))
					CastSpellTarget('R',tu)
					CastSummonerIgnite(tu)
				end
			else
				if target.health<QQclose+EEclose+RRclose and GetD(target)<myHero.range+50 then
					CastSpellTarget('Q',myHero)
					AttackTarget(target)
					CastSpellXYZ('E',bestE(target))
					if MordeConfig.ult==1 then
						CastSpellTarget('R',target)
					end
				elseif surrounded(myHero)==false and target.health<QQQclose+EEclose+RRclose and GetD(target)<myHero.range+50 then
					CastSpellTarget('Q',myHero)
					AttackTarget(target)
					CastSpellXYZ('E',bestE(target))
					if MordeConfig.ult==1 then
						CastSpellTarget('R',target)
					end
				elseif target.health<EEclose+RRclose and GetD(tefa)<700 then
					CastSpellXYZ('E',bestE(target))
					if MordeConfig.ult==1 then
						CastSpellTarget('R',target)
					end
				elseif target.health<QQclose+EEclose+RRRclose and ignitedamage>0 and GetD(target)<myHero.range+50 then
					CastSpellTarget('Q',myHero)
					AttackTarget(target)
					CastSpellXYZ('E',bestE(target))
					if MordeConfig.ult==1 then
						CastSpellTarget('R',target)
						CastSummonerIgnite(target)
					end
				elseif surrounded(myHero)==false and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and target.health<QQQclose+EEclose+RRRclose and ignitedamage>0 and GetD(target)<myHero.range+50 then
					CastSpellTarget('Q',myHero)
					AttackTarget(target)
					CastSpellXYZ('E',bestE(target))
					if MordeConfig.ult==1 then
						CastSpellTarget('R',target)
						CastSummonerIgnite(target)
					end
				elseif target.health<EEclose+RRRclose and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and ignitedamage>0 and GetD(target)<600 then
					CastSpellXYZ('E',bestE(target))
					if MordeConfig.ult==1 then
						CastSpellTarget('R',target)
						CastSummonerIgnite(target)
					end
				end
			end
			
			if target600~=nil and target600.health<ignitedamage then
				CastSummonerIgnite(target600)
			end
			
		end
	end
end



function bestE(unit)
	local countplus=0
	local countequal=0
	local countminus=0
	local found=false
	local enemy = {x=0,y=0,z=0,name=unit.name,dead=unit.dead}
	enemy.x,enemy.y,enemy.z=GetFireahead(unit,EFA,0)
	local Ex,Ey,Ez
	local Theta
	local zz=enemy.z-myHero.z
	if enemy.x>=myHero.x then
		Theta=math.acos(zz/GetD(enemy))
	elseif enemy.x<myHero.x then
		Theta=-math.acos(zz/GetD(enemy))
	end
	
	for i=1, objManager:GetMaxHeroes(), 1 do
		hero = objManager:GetHero(i)
		if hero~=nil and hero.dead~=1 then
			local compareEnemy = {x=0,y=0,z=0,name=hero.name,dead=hero.dead}
			compareEnemy.x,compareEnemy.y,compareEnemy.z=GetFireahead(hero,EFA,0)
			if hero.team~=myHero.team and hero.visible==1 and GetD(compareEnemy)<665 then
			
				local HTheta=0
				local Hzz=compareEnemy.z-myHero.z
				if compareEnemy.x>=myHero.x then
					HTheta=math.acos(Hzz/GetD(compareEnemy))
				elseif compareEnemy.x<myHero.x then
					HTheta=-math.acos(Hzz/GetD(compareEnemy))
				end
				
				if Theta+math.pi/7>=HTheta and Theta-math.pi/7<HTheta then
					countequal=countequal+1
					found=true
				end
				if Theta+2*math.pi/7>=HTheta and Theta<HTheta then
					countplus=countplus+1
					found=true
				end
				if Theta>=HTheta and Theta-2*math.pi/7<HTheta then
					countminus=countminus+1
					found=true				
				end
				
			end
		end
	end
	
	
	if found==true then
		if (countequal>countminus or countequal==countminus) and (countequal>countplus or countequal==countplus) then
			Ex,Ey,Ez=enemy.x,enemy.y,enemy.z
			return Ex,Ey,Ez
		elseif countplus>countequal and (countplus>countminus or countplus==countminus) then
			Ez=GetD(enemy)*math.cos(Theta+math.pi/7.2)
			Ey=enemy.y
			Ex=GetD(enemy)*math.sin(Theta+math.pi/7.2)
			return Ex,Ey,Ez
		elseif countminus>countequal and countminus>countplus then
			Ez=GetD(enemy)*math.cos(Theta-math.pi/7.2)
			Ey=enemy.y
			Ex=GetD(enemy)*math.sin(Theta-math.pi/7.2)
			return Ex,Ey,Ez
		end
	end
	local enemyMinions = GetEnemyMinions(MINION_SORT_HEALTH_ASC)

	for _, minion in pairs(enemyMinions) do
		if minion~=nil and minion.dead~=1 then
			local compareEnemy = {x=0,y=0,z=0,name=minion.name,dead=minion.dead}
			compareEnemy.x,compareEnemy.y,compareEnemy.z=GetFireahead(minion,EFA,0)
			if minion.visible==1 and GetD(compareEnemy)<665 then
				
				local MTheta=0
				local Mzz=compareEnemy.z-myHero.z
				if compareEnemy.x>=myHero.x then
					MTheta=math.acos(Mzz/GetD(compareEnemy))
				elseif compareEnemy.x<myHero.x then
					MTheta=-math.acos(Mzz/GetD(compareEnemy))
				end
				
				if Theta+math.pi/7>=MTheta and Theta-math.pi/7<MTheta then
					countequal=countequal+1
					found=true
				end
				if Theta+2*math.pi/7>=MTheta and Theta<MTheta then
					countplus=countplus+1
					found=true
				end
				if Theta>=MTheta and Theta-2*math.pi/7<MTheta then
					countminus=countminus+1
					found=true				
				end
			end
		end
	end
	if found==true then
		if (countequal>countminus or countequal==countminus) and (countequal>countplus or countequal==countplus) then
			Ex,Ey,Ez=enemy.x,enemy.y,enemy.z
			return Ex,Ey,Ez
		elseif countplus>countequal and (countplus>countminus or countplus==countminus) then
			Ez=GetD(enemy)*math.cos(Theta+math.pi/7.2)
			Ey=enemy.y
			Ex=GetD(enemy)*math.sin(Theta+math.pi/7.2)
			return Ex,Ey,Ez
		elseif countminus>countequal and countminus>countplus then
			Ez=GetD(enemy)*math.cos(Theta-math.pi/7.2)
			Ey=enemy.y
			Ex=GetD(enemy)*math.sin(Theta-math.pi/7.2)
			return Ex,Ey,Ez
		end
		return Ex,Ey,Ez
	else
		Ex,Ey,Ez=enemy.x,enemy.y,enemy.z
		return Ex,Ey,Ez		
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


function OnDraw()

	if myHero.dead~=1 then
		if MordeConfig.eDraw and ERDY==1 and target~=nil then
			local xx,yy,zz=bestE(target)
			local cursor={x=xx,y=yy,z=zz}
			local dist=zz-myHero.z
			
			local Theta
			if xx>=myHero.x then
			Theta=math.acos(dist/GetD(cursor))
			elseif xx<myHero.x then
			Theta=-math.acos(dist/GetD(cursor))
			end
			DrawLineObject(myHero,700,0xFF00FF00,Theta-(math.pi/7),1)
			DrawLineObject(myHero,700,0xFF00FF00,Theta+(math.pi/7),1)
		end
		if QRDY==1 then
			CustomCircle(300,5,3,myHero)
		end
		if WRDY==1 then
			CustomCircle(300,3,2,myHero)
		end

		if ERDY==1 then
			CustomCircle(700,10,1,myHero)
		end
		if RRDY==1 then
			CustomCircle(2400,10,4,myHero)
		end
	end
	--numberOfEnemies
	local positionText=(15/900)*GetScreenY()
		if MordeConfig.ult==1 then
			DrawText("Priority Ult: Regular Target", 1/16*GetScreenX(), positionText, Color.Coral)
		else		
			DrawText("Priority Ult: Regular Target", 1/16*GetScreenX(), positionText, Color.White)
		end
		for i, enemy in pairs(enemies) do
			--[[if index == MordeConfig.ult and index==1 and enemy~=nil then
				DrawText("Priority Ult: ".. enemy.name .. "", 1/16*GetScreenX(), positionText*index, Color.Coral)
				index=index+1
			end--]]
			if enemy~=nil and enemy.number == MordeConfig.ult then
				DrawText("Priority Ult: ".. enemy.unit.name .. "", 1/16*GetScreenX(), positionText*enemy.number, Color.Coral)
		
			elseif enemy~=nil and enemy.number~=MordeConfig.ult then
				DrawText("Priority Ult: ".. enemy.unit.name .. "", 1/16*GetScreenX(), positionText*enemy.number, Color.White)
				
			end
		end
	
	if target~=nil then
		CustomCircle(100,10,5,target)
	end
	if targetult~=nil then
		CustomCircle(100,5,4,targetult)
	end
	
	for i, enemy in pairs(enemies) do
		if enemy~=nil and enemy.invulnerable~=1 and enemy.visible==1 and enemy.dead~=1 then
			if myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" then
			RDE = CalcMagicDamage(enemy,(9.5+2.5*GetSpellLevel('R')+2*(math.floor(myHero.ap/100)))*enemy.maxHealth/100)*RRDY
			RRDE = CalcMagicDamage(enemy,(19+5*GetSpellLevel('R')+4*(math.floor(myHero.ap/100)))*enemy.maxHealth/100)*RRDY
			else
			RDE=0
			RRDE=0
			end
			if enemy.health<RDE then
				DrawSphere(40,25,2,enemy.x,enemy.y+300,enemy.z)
			end
		end
	end
end
function DrawSphere(radius,thickness,color,x,y,z)
    for j=1, thickness do
        local ycircle = (j*(radius/thickness*2)-radius)
        local r = math.sqrt(radius^2-ycircle^2)
        ycircle = ycircle/1.3
        DrawCircle(x,y+ycircle,z,r,color)
    end
end


------------------------------------Pots

function RedElixir()
	if bluePill == nil then
		if myHero.health < 4/10*myHero.maxHealth and os.clock() > wUsedAt + 15 then
			usePotion()
			wUsedAt = os.clock()
		end
		if myHero.health < 5/10*myHero.maxHealth and os.clock() > vUsedAt + 10 then 
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


     
function OnProcessSpell(unit,spell)


	if unit.name==myHero.name and unit.team==myHero.team then  
		--print("\nSpellname: "..spell.name)
		--[[if string.find(spell.name,"MordeandraEMissile") ~= nil then --Mordeandra_E_End
			
		elseif string.find(spell.name,"MordeandraQ") ~= nil then --Mordeandra_E_End
			
		elseif string.find(spell.name,"MordeandraW") ~= nil then --Mordeandra_E_End
			--]]
		if string.find(spell.name,"MordekaiserChildrenOfTheGrave") then --Mordeandra_E_End
			RWindowTime=os.clock()+10
			
		--elseif string.find(spell.name,"ttack") ~= nil then --Mordeandra_E_End
		--	ATimer=os.clock()+ 0.275/(myHero.attackspeed/(1/startAttackSpeed))
		--
		end


	elseif myHero.dead~=1 then
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

function OnCreateObj(obj)
	if (GetDistance(myHero, obj)) < 100 and MordeConfig.pots then
		if string.find(obj.charName,"FountainHeal") then
			timer=os.clock()
			bluePill = obj
		end
	end
		if string.find(obj.charName,"mordekeiser_cotg_ring") and RWindowTime>os.clock() then

			ghostobject=obj
	elseif obj.charName == 'EggTimer.troy' then
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


function dodgeaoe(pos1, pos2, radius)
    local calc = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
	local dodgex
    local dodgez
    dodgex = pos2.x + ((radius+150)/calc)*(myHero.x-pos2.x)
    dodgez = pos2.z + ((radius+150)/calc)*(myHero.z-pos2.z)
	
	
    if calc < radius then
			zhonyas()
			CastSummonerBarrier()
			CastSummonerHeal()
        			--CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
					
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
    local dodgex
    local dodgez
    perpendicular = (math.floor((math.abs((pos2.x-pos1.x)*(pos1.z-myHero.z)-(pos1.x-myHero.x)*(pos2.z-pos1.z)))/(math.sqrt((pos2.x-pos1.x)^2 + (pos2.z-pos1.z)^2))))
    k = ((pos2.z-pos1.z)*(myHero.x-pos1.x) - (pos2.x-pos1.x)*(myHero.z-pos1.z)) / ((pos2.z-pos1.z)^2 + (pos2.x-pos1.x)^2)
	x4 = myHero.x - k * (pos2.z-pos1.z)
	z4 = myHero.z + k * (pos2.x-pos1.x)
	calc3 = (math.floor(math.sqrt((x4-myHero.x)^2 + (z4-myHero.z)^2)))
	dodgex = x4 + ((radius+150)/calc3)*(myHero.x-x4)
    dodgez = z4 + ((radius+150)/calc3)*(myHero.z-z4)
    if perpendicular < radius and calc1 < calc4 and calc2 < calc4 then
			zhonyas()
			CastSummonerBarrier()
			CastSummonerHeal()
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
    local dodgex
    local dodgez
    perpendicular = (math.floor((math.abs((pm2x-pos1.x)*(pos1.z-myHero.z)-(pos1.x-myHero.x)*(pm2z-pos1.z)))/(math.sqrt((pm2x-pos1.x)^2 + (pm2z-pos1.z)^2))))
    k = ((pm2z-pos1.z)*(myHero.x-pos1.x) - (pm2x-pos1.x)*(myHero.z-pos1.z)) / ((pm2z-pos1.z)^2 + (pm2x-pos1.x)^2)
	x4 = myHero.x - k * (pm2z-pos1.z)
	z4 = myHero.z + k * (pm2x-pos1.x)
	calc3 = (math.floor(math.sqrt((x4-myHero.x)^2 + (z4-myHero.z)^2)))
	dodgex = x4 + ((radius+150)/calc3)*(myHero.x-x4)
    dodgez = z4 + ((radius+150)/calc3)*(myHero.z-z4)
    if perpendicular < radius and calc1 < calc4 and calc2 < calc4 then
			zhonyas()
			CastSummonerBarrier()
			CastSummonerHeal()
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