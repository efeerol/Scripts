--[[
Mal's Morde
Version 2.0
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
print('\nVersion 2.0\n')

local targetult
local targetghost
local target600
local target
local Off={name="Regular"}
local allies={}
local enemies={}
--enemies["Regular"]={unit=Off,number=1}
--[[	for i=1, objManager:GetMaxHeroes(), 1 do
		hero = objManager:GetHero(i)
		if hero~=nil and hero.team~=myHero.team then
			if enemies[hero.name]==nil then
			enemies[hero.name]=hero
			end
		elseif hero~=nil and hero.team==myHero.team then
			if allies[hero.name]==nil then
			allies[hero.name]=hero
			end
		end
	end--]]
local ignitedamage=0
local ZReady=true
local ZCount=false
local zh=false
local ZTimer=0
local startAttackSpeed = 0.694
--------Spell Stuff

local cc = 0
local skillshotArray = { 
}
local colorcyan = 0x0000FFFF
local coloryellow = 0xFFFFFF00
local colorgreen = 0xFF00FF00
local drawskillshot = true
local dodgeskillshot = false
local playerradius = 150
local skillshotcharexist = false
local dodgeskillshotkey = 74 -- dodge skillshot key J
local show_allies=0

local willDie=false
local shield=false

local numberOfEnemies=0
local HPShield=0
local QQclose=0
local QQQclose=0
local WWclose=0
local EEclose=0
local RRclose=0
local RRRclose=0
local RRSclose=0
local AAclose=0
local QQ=0
local QQQ=0
local WW=0
local EE=0
local RR=0
local RRR=0
local RRS=0
local AA=0
local ghostobject=nil
local RWindowTime=0
local Rcd=0
local CDR=0

local twfx,twfy,twfz
local twfa
			
local tefx,tefy,tefz 
local tefa

local twfxW,twfyW,twfzW
local twfaW
			
local tefxE,tefyE,tefzE 
local tefaE

local wUsedAt = 0
local vUsedAt = 0
local timer=os.clock()
local bluePill = nil
local enemyIndex=2


MordeConfig = scriptConfig("Morde", "Morde Config")
MordeConfig:addParam("h", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, 88)
MordeConfig:addParam("teamfight", "All In Teamfight", SCRIPT_PARAM_ONKEYDOWN, false, 84)
MordeConfig:addParam("q", "AutoQ", SCRIPT_PARAM_ONKEYTOGGLE, false, 55)
MordeConfig:addParam("e", "AutoE", SCRIPT_PARAM_ONKEYTOGGLE, false, 56)
MordeConfig:addParam("d", "Auto Dodge", SCRIPT_PARAM_ONKEYTOGGLE, false, 57)
MordeConfig:addParam("ult", "Ult Priority", SCRIPT_PARAM_NUMERICUPDOWN, 1, 48,1,objManager:GetMaxHeroes()/2+1,1)

MordeConfig:addParam("gh", "Auto Ghost Attack", SCRIPT_PARAM_ONKEYTOGGLE, true, 189)
MordeConfig:addParam("eDraw", "Draw E Cone", SCRIPT_PARAM_ONOFF, true)
MordeConfig:addParam("zh", "Zhonyas", SCRIPT_PARAM_ONOFF, false)
MordeConfig:addParam("ks", "KillSteal Combos", SCRIPT_PARAM_ONOFF, true)
MordeConfig:addParam("lks", "Ignite Killsteal Combos", SCRIPT_PARAM_ONOFF, true)
MordeConfig:addParam("pots", "Auto Potions", SCRIPT_PARAM_ONOFF, true)
MordeConfig:addParam("smite", "Smitesteal", SCRIPT_PARAM_ONKEYTOGGLE, false, 119)
MordeConfig:permaShow("teamfight")
MordeConfig:permaShow("q")
MordeConfig:permaShow("e")
MordeConfig:permaShow("d")
MordeConfig:permaShow("ult")
MordeConfig:permaShow("gh")
     
local Rcast=0     
	 --Q 250  
	 --W 300  3.79, 11.1
	 --E 700 3.19,50
	 --R 850  3.33 MordekaiserChildrenOfTheGrave
	 
function Run()
	for i=1, objManager:GetMaxHeroes(), 1 do
					local hero = objManager:GetHero(i)
					if hero~=nil and hero.team~=myHero.team and enemies[hero.name]==nil then
									enemies[hero.name]={unit=hero,number=enemyIndex}
									enemyIndex=enemyIndex+1
					end
	end
	for i=1, objManager:GetMaxHeroes(), 1 do
		hero = objManager:GetHero(i)
		if hero~=nil and hero.team~=myHero.team then
			if enemies[hero.name]==nil then
			enemies[hero.name]={unit=hero,number=enemyIndex}
			enemyIndex=enemyIndex+1
			end
		elseif hero~=nil and hero.team==myHero.team then
			if allies[hero.name]==nil then
			allies[hero.name]=hero
			end
		end
	end
	--print("\n NUM "..numberOfEnemies)
	numberOfEnemies=math.max(numberOfEnemies,objManager:GetMaxHeroes()/2+1)
	willDie=false
	targetult = GetWeakEnemy("MAGIC", 1000)
	target600 = GetWeakEnemy("TRUE", 600)
	target = GetWeakEnemy("MAGIC", 800,"NEARMOUSE")
	
	
	CDR=(135-15*(GetSpellLevel('R')))-(135-15*(GetSpellLevel('R')))*myHero.cdr
	if targetult~=nil then
		
		twfxW,twfyW,twfzW = GetFireahead(targetult,3.79,99)
		twfaW={x=twfx,y=0,z=twfz}
		
		tefxE,tefyE,tefzE = GetFireahead(targetult,0.19,150)
		tefaE={x=tefx,y=0,z=tefz}
		
		QQ = getDmg('Q',targetult,myHero)*CanUseSpell('Q')
		QQQ = getDmg('Q',targetult,myHero,3)*CanUseSpell('Q')
		WW = getDmg('W',targetult,myHero)*CanUseSpell('W')
		EE = getDmg('E',targetult,myHero)*CanUseSpell('E')
		if myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" then
		RR = CalcMagicDamage(targetult,(9.5+2.5*GetSpellLevel('R')+2*(math.floor(myHero.ap/100)))*targetult.maxHealth/100)*CanUseSpell('R')
		RRS = CalcMagicDamage(targetult,(0.95+0.25*GetSpellLevel('R')+0.2*(math.floor(myHero.ap/100)))*targetult.maxHealth/100)*CanUseSpell('R')
		RRR = CalcMagicDamage(targetult,(19+5*GetSpellLevel('R')+4*(math.floor(myHero.ap/100)))*targetult.maxHealth/100)*CanUseSpell('R')
		else
		RR=0
		RRR=0
		RRS=0
		end
		AA = getDmg('AD',targetult,myHero)
		
	end
	if target~=nil then
		
		twfx,twfy,twfz = GetFireahead(target,3.79,99)
		twfa={x=twfx,y=0,z=twfz}
		
		tefx,tefy,tefz = GetFireahead(target,0.19,150)
		tefa={x=tefx,y=0,z=tefz}
		--DrawCircle(tefx,tefy,tefz,7,5)
			
		QQclose = getDmg('Q',target,myHero)*CanUseSpell('Q')
		QQQclose = getDmg('Q',target,myHero,3)*CanUseSpell('Q')
		WWclose = getDmg('W',target,myHero)*CanUseSpell('W')
		EEclose = getDmg('E',target,myHero)*CanUseSpell('E')
		
		if myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" then
		RRclose = CalcMagicDamage(target,(9.5+2.5*GetSpellLevel('R')+2*(math.floor(myHero.ap/100)))*target.maxHealth/100)*CanUseSpell('R')
		RRSclose = CalcMagicDamage(target,(0.95+0.25*GetSpellLevel('R')+0.2*(math.floor(myHero.ap/100)))*target.maxHealth/100)*CanUseSpell('R')
		RRRclose = CalcMagicDamage(target,(19+5*GetSpellLevel('R')+4*(math.floor(myHero.ap/100)))*target.maxHealth/100)*CanUseSpell('R')
		else
		RRclose=0
		RRRclose=0
		RRSclose=0
		end
		AAclose = getDmg('AD',target,myHero)
		
	end
	
	if MordeConfig.ult>1 then
	local tu
	for i, enemy in pairs(enemies) do
		if enemy~=nil and enemy.number==MordeConfig.ult then
			tu=enemy.unit
			--print("\n Target is -> "..tu.name)
			break
		end
	end
	
	
		if myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" then
		RR = CalcMagicDamage(tu,(9.5+2.5*GetSpellLevel('R')+2*(math.floor(myHero.ap/100)))*tu.maxHealth/100)*CanUseSpell('R')
		RRS = CalcMagicDamage(tu,(0.95+0.25*GetSpellLevel('R')+0.2*(math.floor(myHero.ap/100)))*tu.maxHealth/100)*CanUseSpell('R')
		RRR = CalcMagicDamage(tu,(19+5*GetSpellLevel('R')+4*(math.floor(myHero.ap/100)))*tu.maxHealth/100)*CanUseSpell('R')
		else
		RR=0
		RRR=0
		RRS=0
		end
	
	
	end
	
	if MordeConfig.gh then
		for i=0,1600,400 do
			--for j=1,5,1 do
				--print("\nI: "..i)
				--print("\nJ: "..j) ,"BASIC",j
				local num= 800+i
				targetghost=GetWeakEnemy("PHYS",num)
				--if targetghost~=nil then
				--print('\n Target:' .. targetghost.name)
				--end
				if myHero.SpellNameR=="mordekaisercotgguide" and Rcast<os.clock() and targetghost~=nil  and ghostobject~=nil and GetD(ghostobject,targetghost)<600 and not runningAway(targetghost,ghostobject) then
					CastSpellTarget('R',targetghost)
					Rcast=os.clock()+0.5
					--break
				elseif myHero.SpellNameR=="mordekaisercotgguide" and Rcast<os.clock() and targetghost~=nil and ghostobject~=nil and GetD(ghostobject,targetghost)<350 then
					CastSpellTarget('R',targetghost)
					Rcast=os.clock()+0.5
					--break
				elseif myHero.SpellNameR=="mordekaisercotgguide" and Rcast<os.clock() and targetghost~=nil and i==1200 and j==5 then
					CastSpellTarget('R',targetghost)
					Rcast=os.clock()+0.5
					--break
				--elseif targetghost==nil then
					--break
				end
			--end
			if targetghost~=nil and Rcast>os.clock() then
						break
			end
		end
	end
	
	if ZCount==true then
		if ZTimer<os.clock() then
			ZReady=true
			ZCount=false
		end
	end
	
	ignite()
	if MordeConfig.q then autoQ() end
	if MordeConfig.e then autoE() end
	if MordeConfig.d then dodgeskillshot=true else dodgeskillshot=false end
	if MordeConfig.zh then shield=true else shield=false end
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
     

     
function OnProcessSpell(unit,spell)


	if unit.name==myHero.name and unit.team==myHero.team then  
		--print("\nSpellname: "..spell.name)
		--[[if string.find(spell.name,"MordeandraEMissile") ~= nil then --Mordeandra_E_End
			
		elseif string.find(spell.name,"MordeandraQ") ~= nil then --Mordeandra_E_End
			
		elseif string.find(spell.name,"MordeandraW") ~= nil then --Mordeandra_E_End
			--]]
		if string.find(spell.name,"MordekaiserChildrenOfTheGrave") then --Mordeandra_E_End
			RReady=false
			Rcd=os.clock()+CDR
			RWindowTime=os.clock()+10
			
		--elseif string.find(spell.name,"ttack") ~= nil then --Mordeandra_E_End
		--	ATimer=os.clock()+ 0.275/(myHero.attackspeed/(1/startAttackSpeed))
		--
		elseif string.find(spell.name,"ZhonyasHourglass") then
			ZTimer=os.clock()+92.5
			ZCount=true
		end


	elseif (shield==true or dodgeskillshot==true) and unit~=nil then
	local Q
	local W
	local E
	local R
		Q = unit.SpellNameQ
		W = unit.SpellNameW
		E = unit.SpellNameE
		R = unit.SpellNameR
		
	
		local P1 = spell.startPos
		local P2 = spell.endPos
		local calc = (math.floor(math.sqrt((P2.x-unit.x)^2 + (P2.z-unit.z)^2)))
		if shield==true then
		--unit.name~="Worm" and unit.name~="TT_Spiderboss7.1.1" and
		if spell ~= nil and unit.team ~= myHero.team and spell.target~=nil and spell.target.name~=nil and spell.target.name == myHero.name then
			if spell.name == Q then
				--CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
				if spellDmg[unit.name] and getDmg("Q",myHero,unit)~=nil and getDmg("Q",myHero,unit) > myHero.health then
					zhonyas()
					CastSummonerBarrier()
					CastSummonerHeal()
				end
    		
			elseif spell.name == W then
        		--CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
        		if spellDmg[unit.name] and getDmg("W",myHero,unit)~=nil and getDmg("W",myHero,unit) > myHero.health then
					zhonyas()
					CastSummonerBarrier()
					CastSummonerHeal()
				end
    		
			elseif spell.name == E then
   			   -- CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
    			if spellDmg[unit.name] and getDmg("E",myHero,unit)~=nil and getDmg("E",myHero,unit) > myHero.health then
					zhonyas()
					CastSummonerBarrier()
					CastSummonerHeal()
        		end

			elseif spell.name == R then
        		--CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
        		if spellDmg[unit.name] and getDmg("R",myHero,unit)~=nil and getDmg("R",myHero,unit) > myHero.health then
					zhonyas()
					CastSummonerBarrier()
					CastSummonerHeal()
        		end
    		
			elseif string.find(unit.name,"minion") == nil and string.find(unit.name,"Minion_") == nil and (spell.name:find("BasicAttack") or spell.name:find("BasicAttack2") or spell.name:find("BasicaAttack3")  or spell.name:find("ChaosTurretFire")) then
        		--CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
				if (unit.baseDamage + unit.addDamage) > myHero.health then
					--print("\nMN "..unit.name)
					zhonyas()
					CastSummonerBarrier()
					CastSummonerHeal()
				end	
			elseif spell.name:find("BasicAttack") or spell.name:find("BasicAttack2") or spell.name:find("BasicaAttack3")  or spell.name:find("ChaosTurretFire") then
        		if (unit.baseDamage + unit.addDamage) > myHero.health then
        			--CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
					zhonyas()
					CastSummonerBarrier()
					CastSummonerHeal()
				end	
			elseif spell.name:find("Attack") then
        		--CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
        		if 2*(unit.baseDamage + unit.addDamage) > myHero.health then
					zhonyas()
					CastSummonerBarrier()
					CastSummonerHeal()
				end
			
        	end
    
		end
		end
		
		if string.find(unit.name,"Minion_") == nil and string.find(unit.name,"Turret_") == nil then
			if (unit.team ~= myHero.team) and string.find(spell.name,"Basic") == nil then

				if spell.name == Q then
					if shield==true and spellDmg[unit.name] and getDmg("Q",myHero,unit)~=nil and getDmg("Q",myHero,unit) > myHero.health then
						willDie=true
					end
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
					--end
				elseif spell.name == W then
					if shield==true and spellDmg[unit.name] and getDmg("W",myHero,unit)~=nil and getDmg("W",myHero,unit) > myHero.health then
						willDie=true
					end
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
					--end
				elseif spell.name == E then
					if shield==true and spellDmg[unit.name] and getDmg("E",myHero,unit)~=nil and getDmg("E",myHero,unit) > myHero.health then
						willDie=true
					end
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
					--end
				elseif spell.name == R then
					if shield==true and spellDmg[unit.name] and getDmg("R",myHero,unit)~=nil and getDmg("R",myHero,unit) > myHero.health then
						willDie=true
					end
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
					--end
		
				end
		
			end
		end
	end
	
	
end
function OnCreateObj(object)
	if (GetDistance(myHero, object)) < 100 and MordeConfig.pots then
		if string.find(object.charName,"FountainHeal") then
			timer=os.clock()
			bluePill = object
		end
	end
		if string.find(object.charName,"mordekeiser_cotg_ring") and RWindowTime>os.clock() then

			ghostobject=obj
		end
end

function harass()
	if targetult~=nil then
		local tu =targetult
		for i, enemy in pairs(enemies) do
			if enemy.number==MordeConfig.ult and enemy.number ~=1 then
				tu=enemy.unit
				break
			end
		end
		if GetD(targetult)<275 then
			if CanCastSpell('R') and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and tu.health<RR and GetD(tu)<850 then 
				CastSpellTarget('R',tu)
			elseif CanCastSpell('R') and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and tu.health<RRR and ignitedamage>0 and GetD(tu)<850 then
				CastSummonerIgnite(tu)
				CastSpellTarget('R',tu)
			elseif CanCastSpell('Q') then
				CastSpellTarget('Q',myHero)
				AttackTarget(targetult)
			else
				CastSummonerExhaust(targetult)
				UseAllItems(targetult)
				AttackTarget(targetult)
			end
		elseif GetD(targetult)<400 then
			if CanCastSpell('R') and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and tu.health<RR and GetD(tu)<850 then 
				CastSpellTarget('R',tu)
			elseif CanCastSpell('R') and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and tu.health<RRR and ignitedamage>0 and GetD(tu)<850 then
				CastSummonerIgnite(tu)
				CastSpellTarget('R',tu)
			elseif CanCastSpell('W') and allySurroundedMost()~=nil then
				CastSpellTarget('W',allySurroundedMost())
			else
				CastSummonerExhaust(targetult)
				UseAllItems(targetult)
				AttackTarget(targetult)
			end
		elseif GetD(targetult)<600 then
			if CanCastSpell('R') and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and tu.health<RR and GetD(tu)<850 then 
				CastSpellTarget('R',tu)
			elseif CanCastSpell('R') and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and tu.health<RRR and ignitedamage>0 and GetD(tu)<850 then
				CastSummonerIgnite(tu)
				CastSpellTarget('R',tu)
			elseif CanCastSpell('W') and allySurroundedMost()~=nil then
				CastSpellTarget('W',allySurroundedMost())
			else
				CastSummonerExhaust(targetult)
				UseTargetItems(targetult)
				AttackTarget(targetult)
			end
		elseif GetD(targetult)<850 then
			if CanCastSpell('R') and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and tu.health<RR and GetD(tu)<850 then 
				CastSpellTarget('R',tu)
			elseif CanCastSpell('R') and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and tu.health<RRR and ignitedamage>0 and GetD(tu)<850 then
				CastSummonerIgnite(tu)
				CastSpellTarget('R',tu)
			elseif CanCastSpell('W') and allySurroundedMost()~=nil then
				CastSpellTarget('W',allySurroundedMost())
			else
				AttackTarget(targetult)
			end
		end
		if CanCastSpell('W') and GetD(twfaW)<300 then
			CastSpellTarget('W',myHero)
		elseif target~=nil and CanCastSpell('W') and GetD(twfa)<300 then
			CastSpellTarget('W',myHero)
				
		end
		if GetD(tefaE)<665 and CanCastSpell('E') then
				CastSpellXYZ('E',bestE(targetult))
		elseif CanCastSpell('E') and target~=nil and GetD(tefa)<665 then
			CastSpellXYZ('E',bestE(target))
		end
	
		

			MoveToXYZ(targetult.x,targetult.y,targetult.z)

	else
		MoveToMouse()
	end
end


function fight()
	--print('\n' ..myHero.SpellNameR)
	if targetult~=nil then
		local tu =targetult
		for i, enemy in pairs(enemies) do
			if enemy.number==MordeConfig.ult and enemy.number ~=1 then
				tu=enemy.unit
				break
			end
		end
				if GetD(targetult)<275 then
			if CanCastSpell('R') and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and tu.invulnerable~=1 and tu.visible==1 and tu.health<RR and GetD(tu)<850 then 
				CastSpellTarget('R',tu)
			elseif CanCastSpell('R') and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and tu.invulnerable~=1 and tu.visible==1 and tu.health<RRR and ignitedamage>0 and GetD(tu)<850 then
				CastSummonerIgnite(tu)
				CastSpellTarget('R',tu)
			elseif CanCastSpell('Q') then
				CastSpellTarget('Q',myHero)
				AttackTarget(targetult)
			elseif CanCastSpell('R') and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and tu.invulnerable~=1 and tu.visible==1 and myHero.health<25/100*myHero.maxHealth and GetD(tu)<850 then
				CastSummonerIgnite(tu)
				CastSpellTarget('R',tu)
			else
				CastSummonerExhaust(targetult)
				UseAllItems(targetult)
				AttackTarget(targetult)
			end
		elseif GetD(targetult)<400 then
			if CanCastSpell('R') and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and tu.invulnerable~=1 and tu.visible==1 and tu.health<RR and GetD(tu)<850 then 
				CastSpellTarget('R',tu)
			elseif CanCastSpell('R') and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and tu.invulnerable~=1 and tu.visible==1 and tu.health<RRR and ignitedamage>0 and GetD(tu)<850 then
				CastSummonerIgnite(tu)
				CastSpellTarget('R',tu)
			elseif CanCastSpell('W') and allySurroundedMost()~=nil then
				CastSpellTarget('W',allySurroundedMost())
			elseif CanCastSpell('R') and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and tu.invulnerable~=1 and tu.visible==1 and myHero.health<25/100*myHero.maxHealth and GetD(tu)<850 then
				CastSummonerIgnite(tu)
				CastSpellTarget('R',tu)
			else
				CastSummonerExhaust(targetult)
				UseAllItems(targetult)
				AttackTarget(targetult)
			end
		elseif GetD(targetult)<600 then
			if CanCastSpell('R') and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and tu.invulnerable~=1 and tu.visible==1 and tu.health<RR and GetD(tu)<850 then 
				CastSpellTarget('R',tu)
			elseif CanCastSpell('R') and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and tu.invulnerable~=1 and tu.visible==1 and tu.health<RRR and ignitedamage>0 and GetD(tu)<850 then
				CastSummonerIgnite(tu)
				CastSpellTarget('R',tu)
			elseif CanCastSpell('W') and allySurroundedMost()~=nil then
				CastSpellTarget('W',allySurroundedMost())
			elseif CanCastSpell('R') and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and tu.invulnerable~=1 and tu.visible==1 and myHero.health<25/100*myHero.maxHealth and GetD(tu)<850 then
				CastSummonerIgnite(tu)
				CastSpellTarget('R',tu)
			else
				CastSummonerExhaust(targetult)
				UseTargetItems(targetult)
				AttackTarget(targetult)
			end
		elseif GetD(targetult)<850 then
			if CanCastSpell('R') and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and tu.invulnerable~=1 and tu.visible==1 and tu.health<RR and GetD(tu)<850 then 
				CastSpellTarget('R',tu)
			elseif CanCastSpell('R') and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and tu.invulnerable~=1 and tu.visible==1 and ((tu.health<RRR and ignitedamage>0) or (tu.health<RRR-20 and not runningAway(tu))) and GetD(tu)<850 then 
				CastSummonerIgnite(tu)
				CastSpellTarget('R',tu)
			elseif CanCastSpell('W') and allySurroundedMost()~=nil then
				CastSpellTarget('W',allySurroundedMost())
			elseif CanCastSpell('R') and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.dead~=1 and tu.invulnerable~=1 and tu.visible==1 and myHero.health<25/100*myHero.maxHealth and GetD(tu)<850 then
				CastSummonerIgnite(tu)
				CastSpellTarget('R',tu)
			else
				AttackTarget(targetult)
			end
		end
		
		if CanCastSpell('W') and GetD(twfaW)<300 then
			CastSpellTarget('W',myHero)
		elseif target~=nil and CanCastSpell('W') and GetD(twfa)<300 then
			CastSpellTarget('W',myHero)
				
		end
		if GetD(tefaE)<665 and CanCastSpell('E') then
				CastSpellXYZ('E',bestE(targetult))
		elseif CanCastSpell('E') and target~=nil and GetD(tefa)<665 then
			CastSpellXYZ('E',bestE(target))
		end
		
			MoveToXYZ(targetult.x,targetult.y,targetult.z)
	
	else
		MoveToMouse()
	end

end

function autoQ()
	if target~=nil and CanCastSpell('Q') and GetD(target)<250 then
		CastSpellTarget('Q',myHero)
		AttackTarget(target)
	end
end

function autoE()
	if target~=nil and GetD(tefa)<665 and CanCastSpell('E') then
		CastSpellXYZ('E',bestE(target))
	end
end


function zhonyas()
	if GetInventorySlot(3157)~=nil then
		zh=true
		if ZReady==true then 
			k = GetInventorySlot(3157)
			CastSpellTarget(tostring(k),myHero)
		end
	elseif GetInventorySlot(3090)~=nil then
		zh=true
		if ZReady==true then 
			k = GetInventorySlot(3090)
			CastSpellTarget(tostring(k),myHero)
		end
	end
end

function surrounded(self)
	local count=0
	for i=1, objManager:GetMaxHeroes(), 1 do
		hero = objManager:GetHero(i)
		if hero~=nil and hero.team~=myHero.team and hero.visible==1 and GetD(self,hero)<600 then
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
		CastHotkey("AUTO 100,0 SPELLF:SMITESTEAL RANGE=700 TRUE COOLDOWN")
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
	if target~=nil then
		
			if target.health<QQclose+EEclose and GetD(target)<250 then
				CastSpellTarget('Q',myHero)
				AttackTarget(target)
				CastSpellXYZ('E',bestE(target))
			elseif surrounded(myHero)==false and target.health<QQQclose+EEclose and GetD(target)<250 then
				CastSpellTarget('Q',myHero)
				AttackTarget(target)
				CastSpellXYZ('E',bestE(target))
			elseif target.health<EEclose and GetD(tefa)<665 then
				CastSpellXYZ('E',bestE(target))
			end
			
			
			local tu 
			for i, enemy in pairs(enemies) do
			if enemy~=nil and enemy.dead~=1 and enemy.invulnerable~=1 and enemy.visible==1 and enemy.number==MordeConfig.ult then
					tu=enemy.unit
					--print("\n Target is -> "..tu.name)
					break
				end
			end
			
			if tu~=nil then
				
				QQclose = getDmg('Q',tu,myHero)*CanUseSpell('Q')
				QQQclose = getDmg('Q',tu,myHero,3)*CanUseSpell('Q')
				EEclose = getDmg('E',tu,myHero)*CanUseSpell('E')
				if myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" then
				RRclose = CalcMagicDamage(tu,(9.5+2.5*GetSpellLevel('R')+2*(math.floor(myHero.ap/100)))*tu.maxHealth/100)*CanUseSpell('R')
				else
				RRclose=0
				end
				
				if tu.health<QQclose+EEclose+RRclose and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and GetD(tu)<250 then
					CastSpellTarget('Q',myHero)
					AttackTarget(tu)
					CastSpellXYZ('E',bestE(tu))
					CastSpellTarget('R',tu)
				elseif surrounded(myHero)==false and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.health<QQQclose+EEclose+RRclose and GetD(tu)<250 then
					CastSpellTarget('Q',myHero)
					AttackTarget(tu)
					CastSpellXYZ('E',bestE(tu))
					CastSpellTarget('R',tu)
				elseif tu.health<EEclose+RRclose and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and GetD(tefa)<665 then
					CastSpellXYZ('E',bestE(tu))
					CastSpellTarget('R',tu)
				end	
			end
		
		if target600~=nil and target600.health<ignitedamage then
			CastSummonerIgnite(target600)
		end
		
	end
end

function lingeringKS()
	if target~=nil then
		if target.health<QQclose+EEclose and GetD(target)<250 then
			CastSpellTarget('Q',myHero)
			AttackTarget(target)
			CastSpellXYZ('E',bestE(target))
		elseif surrounded(myHero)==false and target.health<QQQclose+EEclose and GetD(target)<250 then
			CastSpellTarget('Q',myHero)
			AttackTarget(target)
			CastSpellXYZ('E',bestE(target))
		elseif target.health<EEclose and GetD(tefa)<665 then
			CastSpellXYZ('E',bestE(target))
		end
		
		
		local tu 
		for i, enemy in pairs(enemies) do
		if enemy~=nil and enemy.dead~=1 and enemy.invulnerable~=1 and enemy.visible==1 and enemy.number==MordeConfig.ult then
				tu=enemy.unit
				--print("\n Target is -> "..tu.name)
				break
			end
		end
		
		
		if tu~=nil then
		
			QQclose = getDmg('Q',tu,myHero)*CanUseSpell('Q')
			QQQclose = getDmg('Q',tu,myHero,3)*CanUseSpell('Q')
			WWclose = getDmg('W',tu,myHero)*CanUseSpell('W')
			EEclose = getDmg('E',tu,myHero)*CanUseSpell('E')
			if myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" then
			RRclose = CalcMagicDamage(tu,(9.5+2.5*GetSpellLevel('R')+2*(math.floor(myHero.ap/100)))*tu.maxHealth/100)*CanUseSpell('R')
			RRSclose = CalcMagicDamage(tu,(0.95+0.25*GetSpellLevel('R')+0.2*(math.floor(myHero.ap/100)))*tu.maxHealth/100)*CanUseSpell('R')
			RRRclose = CalcMagicDamage(tu,(19+5*GetSpellLevel('R')+4*(math.floor(myHero.ap/100)))*tu.maxHealth/100)*CanUseSpell('R')
			else
			RRclose=0
			RRRclose=0
			RRSclose=0
			end
			
			if tu.health<QQclose+EEclose+RRclose and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and GetD(tu)<250 then
				CastSpellTarget('Q',myHero)
				AttackTarget(tu)
				CastSpellXYZ('E',bestE(tu))
				CastSpellTarget('R',tu)
				CastSummonerIgnite(tu)
			elseif surrounded(myHero)==false and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.health<QQQclose+EEclose+RRclose and GetD(tu)<250 then
				CastSpellTarget('Q',myHero)
				AttackTarget(tu)
				CastSpellXYZ('E',bestE(tu))
				CastSpellTarget('R',tu)
				CastSummonerIgnite(tu)
			elseif tu.health<EEclose+RRclose and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and GetD(tefa)<665 then
				CastSpellXYZ('E',bestE(tu))
				CastSpellTarget('R',tu)
			elseif tu.health<QQclose+EEclose+RRRclose and ignitedamage>0 and GetD(tu)<250 then
				CastSpellTarget('Q',myHero)
				AttackTarget(tu)
				CastSpellXYZ('E',bestE(tu))
				CastSpellTarget('R',tu)
				CastSummonerIgnite(tu)
			elseif surrounded(myHero)==false and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and tu.health<QQQclose+EEclose+RRRclose and ignitedamage>0 and GetD(tu)<250 then
				CastSpellTarget('Q',myHero)
				AttackTarget(tu)
				CastSpellXYZ('E',bestE(tu))
				CastSpellTarget('R',tu)
				CastSummonerIgnite(tu)
			elseif tu.health<EEclose+RRRclose and myHero.SpellNameR=="MordekaiserChildrenOfTheGrave" and ignitedamage>0 and GetD(tefa)<665 then
				CastSpellXYZ('E',bestE(tu))
				CastSpellTarget('R',tu)
				CastSummonerIgnite(tu)
			end
		end
		
		if target600~=nil and target600.health<ignitedamage then
			CastSummonerIgnite(target600)
		end
		
	end
end



function bestE(unit)
	local countplus=0
	local countequal=0
	local countminus=0
	local found=false
	local enemy = {x=0,y=0,z=0,name=unit.name,dead=unit.dead}
	enemy.x,enemy.y,enemy.z=GetFireahead(unit,0.19,150)
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
			compareEnemy.x,compareEnemy.y,compareEnemy.z=GetFireahead(hero,0.19,150)
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
			compareEnemy.x,compareEnemy.y,compareEnemy.z=GetFireahead(minion,0.19,150)
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
		if MordeConfig.eDraw and CanCastSpell('E') and target~=nil then
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
		if CanUseSpell('Q')==1 then
			CustomCircle(300,5,3,myHero)
		end
		if CanUseSpell('W')==1 then
			CustomCircle(300,3,2,myHero)
		end

		if CanUseSpell('E')==1 then
			CustomCircle(700,10,1,myHero)
		end
		if CanUseSpell('R')==1 then
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
			RDE = CalcMagicDamage(enemy,(9.5+2.5*GetSpellLevel('R')+2*(math.floor(myHero.ap/100)))*enemy.maxHealth/100)*CanUseSpell('R')
			RRDE = CalcMagicDamage(enemy,(19+5*GetSpellLevel('R')+4*(math.floor(myHero.ap/100)))*enemy.maxHealth/100)*CanUseSpell('R')
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




function dodgeaoe(pos1, pos2, radius)
    local calc = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
	local dodgex
    local dodgez
    dodgex = pos2.x + ((radius+150)/calc)*(myHero.x-pos2.x)
    dodgez = pos2.z + ((radius+150)/calc)*(myHero.z-pos2.z)
	
	
    if calc < radius then
		if willDie==true and MordeCofig.zh and zh==true then
			zhonyas()
			CastSummonerBarrier()
			CastSummonerHeal()
		elseif dodgeskillshot == true then
			MoveToXYZ(dodgex,0,dodgez)
		end
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
		if willDie==true and MordeCofig.zh and zh==true then
			zhonyas()
			CastSummonerBarrier()
			CastSummonerHeal()
		elseif dodgeskillshot == true then
			MoveToXYZ(dodgex,0,dodgez)
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
		if willDie==true and MordeCofig.zh and zh==true then
			zhonyas()
			CastSummonerBarrier()
			CastSummonerHeal()
		elseif dodgeskillshot == true then
			MoveToXYZ(dodgex,0,dodgez)
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


function LoadTable()
--print("table loaded::")
    local iCount=objManager:GetMaxHeroes()
--print(" heros:" .. tostring(iCount))
	iCount=1;
    for i=0, iCount, 1 do
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
		table.insert(skillshotArray,{name= "EnchantedCrystalArrow", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 50000, type = 4, radius = 120, color= colorcyan, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Blitzcrank" then
		table.insert(skillshotArray,{name= "RocketGrabMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 925, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Brand" then
		table.insert(skillshotArray,{name= "BrandBlazeMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 50, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0})
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
		table.insert(skillshotArray,{name= "DravenRCast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 20000, type = 1, radius = 100, color= colorcyan, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
	skillshotcharexist = true
	end
	if 1==1 or myHero.name == "Ezreal" then
		table.insert(skillshotArray,{name= "EzrealEssenceFluxMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 100, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		table.insert(skillshotArray,{name= "EzrealMysticShotMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1100, type = 1, radius = 80, color= colorcyan, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
		table.insert(skillshotArray,{name= "EzrealTrueshotBarrage", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 50000, type = 4, radius = 150, color= colorcyan, time = 4, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
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
		table.insert(skillshotArray,{name= "LuxMaliceCannon", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 3000, type = 1, radius = 80, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
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
		table.insert(skillshotArray,{name= "DarkBindingMissile", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1300, type = 1, radius = 100, color= colorcyan, time = 1.5, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
		table.insert(skillshotArray,{name= "TormentedSoil", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 3, radius = 350, color= coloryellow, time = 1.5, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0  })
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
				if 1==1 or myHero.name == "Syndra" then
						table.insert(skillshotArray,{name= "SyndraQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 800, type = 3, radius = 190, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						table.insert(skillshotArray,{name= "syndrawcast", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 950, type = 3, radius = 210, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						skillshotcharexist = true
				end
				if 1==1 or myHero.name == "Khazix" then
						table.insert(skillshotArray,{name= "KhazixW", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 70, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						table.insert(skillshotArray,{name= "khazixwlong", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1000, type = 1, radius = 400, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						table.insert(skillshotArray,{name= "KhazixE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 600, type = 5, radius = 310, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						table.insert(skillshotArray,{name= "khazixelong", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 5, radius = 310, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						skillshotcharexist = true
				end
				if 1==1 or myHero.name == "Elise" then
						table.insert(skillshotArray,{name= "EliseHumanE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 80, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						skillshotcharexist = true
				end
				if 1==1 or myHero.name == "Zed" then
						table.insert(skillshotArray,{name= "ZedShuriken", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 900, type = 1, radius = 55, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						skillshotcharexist = true
				end
				if 1==1 or myHero.name == "Nami" then
						table.insert(skillshotArray,{name= "NamiQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 875, type = 3, radius = 210, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						table.insert(skillshotArray,{name= "NamiR", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 2750, type = 1, radius = 335, color= coloryellow, time = 3, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						skillshotcharexist = true
				end
				if 1==1 or myHero.name == "Vi" then
						table.insert(skillshotArray,{name= "ViQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 725, type = 1, radius = 65, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						skillshotcharexist = true
				end
				if 1==1 or myHero.name == "Thresh" then
						table.insert(skillshotArray,{name= "ThreshQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1075, type = 1, radius = 70, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						skillshotcharexist = true
				end
				if 1==1 or myHero.name == "Quinn" then
						table.insert(skillshotArray,{name= "QuinnQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1025, type = 1, radius = 150, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						skillshotcharexist = true
				end
				if 1==1 or myHero.name == "Zac" then
						table.insert(skillshotArray,{name= "ZacE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1550, type = 5, radius = 200, color= coloryellow, time = 1, isline = false, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						skillshotcharexist = true
				end
				if 1==1 or myHero.name == "Lissandra" then
						table.insert(skillshotArray,{name= "LissandraQ", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 725, type = 1, radius = 100, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						table.insert(skillshotArray,{name= "LissandraE", shot=0, lastshot = 0, skillshotpoint = {}, maxdistance = 1050, type = 1, radius = 120, color= coloryellow, time = 1, isline = true, p1x =0, p1y =0 , p1z =0 , p2x =0, p2y =0 , p2z =0 })
						skillshotcharexist = true
				end
        --end
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