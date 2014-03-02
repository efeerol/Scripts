require "Utils"
require 'spell_damage'
print=printtext
printtext("\nNono U Dead\n")
printtext("\nBy Malbert\n")
printtext("\nVersion 1.8\n")
 
local target
local targetult
local Key
local ignitedamage
local UltT=os.clock()
local RU = false
local minions={}
local miniontarget
local enemiesInUlt={}
local count=0
local UltDmg = 0
local smitedamage=0
local smitekey=nil
local beginningDmg = 0
local added = 0
local allies={}
local allies4W ={"Highest AD"}
local enemies={}
	local Consume=0	
	local CDMG=0
 local allycount=1
 local index=1
local allytarget
 
local junglewho={"Baron, Drag, EBlue", "Baron, Drag, EBlue, ERed", "Baron, Drag, BothBlue", "ALL JUNGLE BUFFS","OFF"}
--[[{ name = Golem, team = 'RED', location = Vector(6140,0,11935) }
{ name = Wraith, team = 'RED', location = Vector(7580,0,9250) }
{ name = GiantWolf, team = 'RED', location = Vector(10651,0,8116) }
{ name = Golem, team = 'BLUE', location = Vector(8216,0,2533) }
{ name = GiantWolf, team = 'BLUE', location = Vector(3373,0,6223) }
{ name = Wraith, team = 'BLUE', location = Vector(6446,0,5214) }--]]
 
local jungle1 = {}
local jungle2 = {}
local jungle3 = {}
local jungle4 = {}
local junglePositionALL = {

{ name = "AncientGolem", team = 300, location = { x = 3632, y = 54, z = 7600} },--'BLUE'
{ name = "AncientGolem", team = 300, location = {x=10386,y=54,z=6811}},--'RED'
{ name = "LizardElder", team = 300, location = { x = 7455, y = 57, z = 3890}},--Blue
{ name = "LizardElder", team = 300, location = { x = 6504, y = 54, z = 10584}},--Red
{ name = "Dragon", team = 300, location = {x=9459,y=-60,z=4193} },
{ name = "Worm", team = 300, location = {x=4600,y=-63,z=10250} },

}


local junglePositionBBlue = {

{ name = "AncientGolem", team = 300, location = { x = 3632, y = 54, z = 7600} },--'BLUE'
{ name = "AncientGolem", team = 300, location = {x=10386,y=54,z=6811}},--'RED'
{ name = "Dragon", team = 300, location = {x=9459,y=-60,z=4193} },
{ name = "Worm", team = 300, location = {x=4600,y=-63,z=10250} },

}


local junglePositionERed = {}


if myteam ==100 then
	junglePositionERed = {
{ name = "AncientGolem", team = 300, location = { x = 3632, y = 54, z = 7600} },--'BLUE'
{ name = "AncientGolem", team = 300, location = {x=10386,y=54,z=6811}},--'RED'
{ name = "LizardElder", team = 300, location = { x = 6504, y = 54, z = 10584}},--Red
{ name = "Dragon", team = 300, location = {x=9459,y=-60,z=4193} },
{ name = "Worm", team = 300, location = {x=4600,y=-63,z=10250} },
}
elseif myteam==200 then
	junglePositionERed = {
{ name = "AncientGolem", team = 300, location = { x = 3632, y = 54, z = 7600} },--'BLUE'
{ name = "AncientGolem", team = 300, location = {x=10386,y=54,z=6811}},--'RED'
{ name = "LizardElder", team = 300, location = { x = 7455, y = 57, z = 3890}},--Blue
{ name = "Dragon", team = 300, location = {x=9459,y=-60,z=4193} },
{ name = "Worm", team = 300, location = {x=4600,y=-63,z=10250} },
}
end


local JPKS={}
if myteam ==100 then
	JPKS = {

{ name = "AncientGolem", team = 300, location = {x=10386,y=54,z=6811}},
{ name = "LizardElder", team = 300, location = { x = 6504, y = 54, z = 10584}},
{ name = "Dragon", team = 300, location = {x=9459,y=-60,z=4193} },
{ name = "Worm", team = 300, location = {x=4600,y=-63,z=10250} },

}
elseif myteam==200 then
	JPKS = {

{ name = "AncientGolem", team = 300, location = { x = 3632, y = 54, z = 7600}},
{ name = "LizardElder", team = 300, location = { x = 6504, y = 54, z = 10584}},
{ name = "Dragon", team = 300, location = {x=9459,y=-60,z=4193} },
{ name = "Worm", team = 300, location = {x=4600,y=-63,z=10250} },

}
end
 
 
 
 
NunuConfig = scriptConfig("Nunu", "Nunu Config")
NunuConfig:addParam("h", " Harass", SCRIPT_PARAM_ONKEYDOWN, false, 88)
NunuConfig:addParam('teamfight', 'TeamFight', SCRIPT_PARAM_ONKEYDOWN, false, 84)
NunuConfig:addParam('w', 'Auto W Ally', SCRIPT_PARAM_ONKEYTOGGLE, false, 56)
NunuConfig:addParam('chooseW', 'Choose W Ally', SCRIPT_PARAM_NUMERICUPDOWN, 1,57,1,objManager:GetMaxHeroes()/2,1)
NunuConfig:addParam('autoR', 'Auto R Explode', SCRIPT_PARAM_ONKEYTOGGLE, true, 48)
NunuConfig:addParam('consume', 'Minion Consume Circles', SCRIPT_PARAM_ONOFF, true)
NunuConfig:addParam('smite', 'SmiteSteal', SCRIPT_PARAM_ONOFF, true)
NunuConfig:addParam('dokillsteal', 'Killsteal', SCRIPT_PARAM_ONOFF, false)
NunuConfig:addParam('choosejungle', "Jungling", SCRIPT_PARAM_NUMERICUPDOWN, 1, 189,1,5,1)
NunuConfig:permaShow('dokillsteal')
 
function Run()
	   
	   
		target = GetWeakEnemy("MAGIC", 700)
		targetult = GetWeakEnemy("MAGIC", 900)
		ignite()
	   for i=1, objManager:GetMaxHeroes(), 1 do
				hero = objManager:GetHero(i)
				if hero~=nil and hero.team==myHero.team and allies[hero.name]==nil and hero.charName~=myHero.charName then
						allies[hero.name]={unit=hero,number=allycount}
						allycount=allycount+1
				elseif hero~=nil and hero.team~=myHero.team and enemies[hero.name]==nil then
						enemies[hero.name]=hero
				end
		end
		Consume=(25+45*GetSpellLevel('Q')+myHero.ap*75/100)*CanUseSpell('Q')
		CDMG=(250+150*GetSpellLevel('Q'))*CanUseSpell('Q')
		if RU==true then
				if added==0 then
			   
						UltDmg=46.875+31.25*GetSpellLevel('R')+(31+1/4)/100*myHero.ap
						beginningDmg=46.875+31.25*GetSpellLevel('R')+(31+1/4)/100*myHero.ap
						added=added+1
						--printtext("\n1 "..UltDmg)
			   
				elseif UltT+3-os.clock()<2+1/3 and added ==1 then
						UltDmg=UltDmg+beginningDmg
						added=added+1
						--printtext("\n2 "..UltDmg)
				elseif UltT+3-os.clock()<2 and added ==2 then
						UltDmg=UltDmg+beginningDmg
						added=added+1
						--printtext("\n3 "..UltDmg)
				elseif UltT+3-os.clock()<1+2/3 and added ==3 then
						UltDmg=UltDmg+beginningDmg
						added=added+1
						--printtext("\n4 "..UltDmg)
				elseif UltT+3-os.clock()<1+1/3 and added ==4 then
						UltDmg=UltDmg+beginningDmg
						added=added+1
						--printtext("\n5 "..UltDmg)
				elseif UltT+3-os.clock()<1 and added ==5 then
						UltDmg=UltDmg+beginningDmg
						added=added+1
						--printtext("\n6 "..UltDmg)
				elseif UltT+3-os.clock()<2/3 and added ==6 then
						UltDmg=UltDmg+beginningDmg
						added=added+1
						--printtext("\n7 "..UltDmg)
				elseif UltT+3-os.clock()<1/3 and added ==7 then
						UltDmg=UltDmg+beginningDmg
						added=added+1
						--printtext("\n8 "..UltDmg)
				end
	   
		end
	   
		UpdateMinionTable()
		if IsChatOpen() == 0 and NunuConfig.h then harass() end
		if NunuConfig.dokillsteal then killsteal() end
	   
		if IsChatOpen() == 0 and NunuConfig.teamfight then Chase() end
	   
		if NunuConfig.w then autoW() end
	   
		if NunuConfig.autoR then
		AutoRExplode()
		end
		if NunuConfig.smite then smitesteal() end
	    if NunuConfig.choosejungle==1 then
                index=1
                KS1()
                UpdatejungleTable1()
        elseif NunuConfig.choosejungle==2 then
                index=2
                KS2()
                UpdatejungleTable2()
        elseif NunuConfig.choosejungle==3 then
                index=3
                KS3()
                UpdatejungleTable3()
        elseif NunuConfig.choosejungle==4 then
                index=4
                KS4()
                UpdatejungleTable4()
        elseif NunuConfig.choosejungle==5 then
                index=5
        end
end
 
 
function smitesteal()
		if myHero.SummonerD == "SummonerSmite" then
			if IsSpellReady('D')==1 then
				if myHero.selflevel<=4 then
					smitedamage = 390+(20*myHero.selflevel)
				elseif myHero.selflevel<=9 then
					smitedamage = 450+(30*(myHero.selflevel-4))
				elseif myHero.selflevel<=14 then
					smitedamage = 600+(40*(myHero.selflevel-9))
				else
					smitedamage = 800+(50*(myHero.selflevel-14))
				end
				smitekey="D"
			else
				smitedamage=0
				smitekey="D"
			end
				CastHotkey("AUTO 100,0 SPELLD:SMITESTEAL RANGE=600 TRUE COOLDOWN")
				return
		elseif myHero.SummonerF == "SummonerSmite" then
			if IsSpellReady('F')==1 then
				if myHero.selflevel<=4 then
					smitedamage = 390+(20*myHero.selflevel)
				elseif myHero.selflevel<=9 then
					smitedamage = 450+(30*(myHero.selflevel-4))
				elseif myHero.selflevel<=14 then
					smitedamage = 600+(40*(myHero.selflevel-9))
				else
					smitedamage = 800+(50*(myHero.selflevel-14))
				end
				smitekey="F"
			else
				smitedamage=0
				smitekey="F"
			end
				CastHotkey("AUTO 100,0 SPELLF:SMITESTEAL RANGE=600 TRUE COOLDOWN")
				return
		else
			
				smitedamage=0
		end
end
 
function ignite()
				if myHero.SummonerD == "SummonerDot" then
						Key="D"
						ignitedamage = ((myHero.selflevel*20)+50)*CanUseSpell('D')
				elseif myHero.SummonerF == "SummonerDot" then
								ignitedamage = ((myHero.selflevel*20)+50)*CanUseSpell('F')
								Key="F"
				else
								ignitedamage=0
				end
end
 
function harass()
		if target~=nil then
				if CanUseSpell('E')==1 then CastSpellTarget('E',target) end
		else
				MoveToMouse()
		end
end
 
 
function autoW()
		if CanUseSpell('W')==1 then
 
		if NunuConfig.chooseW==1 then
				for i,ally4W in pairs(allies) do
						if ally4W~=nil and ally4W.unit.dead~=1 then
								if (allytarget==nil or allytarget.dead==1 or GetD(allytarget)>=700) and GetD(ally4W.unit)<700 then
										allytarget=ally4W.unit
								elseif allytarget~=nil and allytarget.dead~=1 and GetD(ally4W.unit)<700 and allytarget.baseDamage+allytarget.addDamage<ally4W.unit.baseDamage+ally4W.unit.addDamage then
										allytarget=ally4W.unit
								end
						end
				end
		elseif NunuConfig.chooseW==2 then
				for i,ally4W in pairs(allies) do
						if ally4W~=nil and ally4W.unit.dead~=1 and ally4W.number==1 then
							if GetD(ally4W.unit)<800 then
								allytarget=ally4W.unit
								break
							else
								for j,allyW in pairs(allies) do
									if allyW~=nil and allyW.unit.dead~=1 then
											if (allytarget==nil or allytarget.dead==1 or GetD(allytarget)>=700) and GetD(allyW.unit)<700 then
													allytarget=allyW.unit
											elseif allytarget~=nil and allytarget.dead~=1 and GetD(allyW.unit)<700 and allytarget.baseDamage+allytarget.addDamage<allyW.unit.baseDamage+allyW.unit.addDamage then
													allytarget=allyW.unit
											end
									end
								end
							end
							break
						end
				end
		elseif NunuConfig.chooseW==3 then
				for i,ally4W in pairs(allies) do
						if ally4W~=nil and ally4W.unit.dead~=1 and ally4W.number==2 then
							if GetD(ally4W.unit)<800 then
								allytarget=ally4W.unit
								break
							else
								for j,allyW in pairs(allies) do
									if allyW~=nil and allyW.unit.dead~=1 then
											if (allytarget==nil or allytarget.dead==1 or GetD(allytarget)>=700) and GetD(allyW.unit)<700 then
													allytarget=allyW.unit
											elseif allytarget~=nil and allytarget.dead~=1 and GetD(allyW.unit)<700 and allytarget.baseDamage+allytarget.addDamage<allyW.unit.baseDamage+allyW.unit.addDamage then
													allytarget=allyW.unit
											end
									end
								end
							end
							break
						end
				end
		elseif NunuConfig.chooseW==4 then
				for i,ally4W in pairs(allies) do
						if ally4W~=nil and ally4W.unit.dead~=1 and ally4W.number==3 then
							if GetD(ally4W.unit)<800 then
								allytarget=ally4W.unit
								break
							else
								for j,allyW in pairs(allies) do
									if allyW~=nil and allyW.unit.dead~=1 then
											if (allytarget==nil or allytarget.dead==1 or GetD(allytarget)>=700) and GetD(allyW.unit)<700 then
													allytarget=allyW.unit
											elseif allytarget~=nil and allytarget.dead~=1 and GetD(allyW.unit)<700 and allytarget.baseDamage+allytarget.addDamage<allyW.unit.baseDamage+allyW.unit.addDamage then
													allytarget=allyW.unit
											end
									end
								end
							end
							break
						end
				end
		elseif NunuConfig.chooseW==5 then
				for i,ally4W in pairs(allies) do
						if ally4W~=nil and ally4W.unit.dead~=1 and ally4W.number==4 then
							if GetD(ally4W.unit)<800 then
								allytarget=ally4W.unit
								break
							else
								for j,allyW in pairs(allies) do
									if allyW~=nil and allyW.unit.dead~=1 then
											if (allytarget==nil or allytarget.dead==1 or GetD(allytarget)>=700) and GetD(allyW.unit)<700 then
													allytarget=allyW.unit
											elseif allytarget~=nil and allytarget.dead~=1 and GetD(allyW.unit)<700 and allytarget.baseDamage+allytarget.addDamage<allyW.unit.baseDamage+allyW.unit.addDamage then
													allytarget=allyW.unit
											end
									end
								end
							end
							break
						end
				end
		end
	   
		if allytarget~=nil and allytarget.dead~=1 and GetD(allytarget)<700 then
				for j,EIR in pairs(enemies) do
						if EIR~=nil and EIR.dead~=1 then
								if allytarget~=nil and allytarget.dead~=1 and GetD(allytarget,EIR)<850 then
										CastSpellTarget('W',allytarget)
										break
								end
						end
				end
		end
	   
		end
end
 
 
function Chase()
	   
		if target~=nil then
				UseAllItems(target)
				if CanUseSpell('E')==1 then CastSpellTarget('E',target) end
				if CanUseSpell('W')==1 then CastSpellTarget('W',myHero) end
				AttackTarget(target)
		else
				MoveToMouse()
		end
end
 
 
function AutoRExplode()
if RU==true then
		for i=1, objManager:GetMaxHeroes(), 1 do
				hero = objManager:GetHero(i)
				if hero~=nil and hero.team~=myHero.team and enemiesInUlt[hero.name]==nil and hero.visible==1 and GetD(hero,myHero)<625 then
					enemiesInUlt[hero.name]=hero
					count=count+1
				end
						--[[local check = false
						for i,enemy in pairs(enemiesInUlt) do
								if enemy~=nil and enemy.name == hero.name then
										check =true
										break
								end
						end
						if hero~=nil and hero.team~=myHero.team and check==false and GetD(hero,myHero)<650 then
								table.insert(enemiesInUlt,hero)
								count=count+1
								--print("\nC1 " .. count)
					   
						end  --]]  
				--end
		end
	if count > 0 then
		for i,enemy in pairs(enemiesInUlt) do
				if enemy~=nil and enemy.dead~=1 and GetD(enemy)<650 and enemy.visible==1 then
						--print("\nC2 " .. count)
						local d1 = GetD(enemy)
						local x, y, z = GetFireahead(enemy,5,0)
						local d2 = GetD({x=x, y=y, z=z})
						local d3 = GetD({x=x, y=y, z=z},enemy)
						local angle = math.acos((d2*d2-d3*d3-d1*d1)/(-2*d3*d1))

						runningAway = angle%(2*math.pi)>math.pi/2 and angle%(2*math.pi)<math.pi*3/2
						if (GetD(enemy)>540 or enemy.visible==0) and runningAway and enemy.health<CalcMagicDamage(enemy,UltDmg) then
								--print("\nMM")
								MoveToXYZ(targetult.x,0,targetult.z)
								--print("\nM2")
								break
						elseif (GetD(enemy)>540 or enemy.visible==0) and runningAway and count==1 then
								--print("\nDD")
								MoveToXYZ(targetult.x,0,targetult.z)
								--print("\nD2")
								break
						end
				elseif enemy==nil or enemy.dead==1 or GetD(enemy)>=650 or enemy.visible==0 then
						enemiesInUlt[hero.name]=nil
						count=count-1
						--print("\nC3 " .. count)
				end
		end
		end
end
end
 
 
function OnProcessSpell(unit,spell)
		if unit.charName==myHero.charName then
			   
				--printtext("\nCD ".. spell.name .."\n")
 
				if spell.name:find("AbsoluteZero") then
						UltT=os.clock()
						UltDmg = 0
						added = 0
						count=0
						enemiesInUlt={}
						RU=true
						--printtext("\nB "..UltT)
					   
				end
	   
		end
 
end
 
function OnCreateObj(obj)
 
		if obj~=nil and GetD(obj,myHero) <100 then
		--printtext("\n1"..obj.charName.."\n")
		--printtext("\n1"..obj.name.."\n")
 
				if obj.charName:find("AbsoluteZero_nova") then
						RU=false
						--printtext("\nE "..os.clock())
				end
	end
end
 
 
function killsteal()
		if target~=nil and target.dead~=1 then
			   
				local E = getDmg("E",target,myHero)*CanUseSpell('E')
				local AA = getDmg("AD",target,myHero)
			   
				if target.health<(E+ignitedamage) and GetD(target)<620 and RU==false then
						if CanUseSpell('E')==1 then CastSpellTarget('E',target) end
 
						AttackTarget(target)
						if ignitedamage~=0 then CastSpellTarget(Key, target) end
				end
				if target.health<(E+ignitedamage) and GetD(target)<620 then
						if CanUseSpell('E')==1 and RU==false then CastSpellTarget('E',target) end
						if RU==false then AttackTarget(target) end
						if ignitedamage~=0 then CastSpellTarget(Key, target) end
				end    
 
		end
end
 
function UpdateMinionTable()
 
	if miniontarget ~= nil and miniontarget.dead == 1 then
		miniontarget = nil
	end
   
	for i,minion in ipairs(minions) do
		if minion.dead == 1 or minion.team == myHero.team or minion == nil or not minion then
			table.remove(minions,i)
				end
						if NunuConfig.consume and GetSpellLevel('Q')>0 and minion.dead~=1 and GetD(minion)<2000 and minion.health<(CDMG) then            
								CustomCircle(50,5,5,minion)
								if RU==false and minion.dead~=1 and GetD(minion)<250 and CanUseSpell('Q')==1 and myHero.health<myHero.maxHealth-(Consume) then
										CastSpellTarget('Q',minion)
								end
						end
	   
	end
   
	for i=1, objManager:GetMaxNewObjects(), 1 do
		object = objManager:GetNewObject(i)
		if object and object ~= nil and object.team ~= 0 and object.charName ~= nil and object.team ~= myHero.team and object.dead~=1 and string.find(object.charName,"Minion_") then
			table.insert(minions,object)
					   
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
	if myHero.dead~=1 then
	local positionText=(15/900)*GetScreenY()
		if NunuConfig.chooseW==1 then
			DrawText("Ally Priority W: Highest AD", 1/16*GetScreenX(), positionText, Color.Red)
		else
			DrawText("Ally Priority W: Highest AD", 1/16*GetScreenX(), positionText, Color.SkyBlue)
		end
		
	for i, ally in pairs(allies) do
		--[[if index == MordeConfig.ult and index==1 and enemy~=nil then
			DrawText("Priority Ult: ".. enemy.name .. "", 1/16*GetScreenX(), positionText*index, Color.Coral)
			index=index+1
		end--]]
		
		if ally~=nil and ally.number+1 == NunuConfig.chooseW then
			DrawText("Ally Priority W: ".. ally.unit.name .. "", 1/16*GetScreenX(), positionText*(ally.number+1), Color.Red)
					
		elseif ally~=nil and ally.number+1~=NunuConfig.chooseW then
			DrawText("Ally Priority W: ".. ally.unit.name .. "", 1/16*GetScreenX(), positionText*(ally.number+1), Color.SkyBlue)
			
		end
	end
	end
	if myHero.dead~=1 then
	 local positionText=(15/900)*GetScreenY()
                for i = 1, 5, 1 do
                        if i ==index and junglewho[i]~=nil then
                                DrawText("Jungle KS: ".. junglewho[index] .. "", 3/16*GetScreenX(), positionText*i, Color.LightBlue)
                        elseif i~=index and junglewho[i]~=nil then
                                DrawText("Jungle KS: ".. junglewho[i] .. "", 3/16*GetScreenX(), positionText*i, Color.White)
                        end
                end
	end


			if CanUseSpell('R')==1 then
			end
   
			if CanUseSpell('E')==1 and RU==false then
					CustomCircle(620,5,4,myHero)   
			end
					CustomCircle(540,5,2,myHero)   
					CustomCircle(650,5,3,myHero)
					if RU==true then
					CustomCircle(625,70,2,myHero)
					end
		   
		   
	if target~=nil then
			CustomCircle(100,4,5,target)
	end
end    



---------------------------ENEMY BLUE
function UpdatejungleTable1()
	for i=1, objManager:GetMaxObjects(), 1 do
		object = objManager:GetObject(i)
			if object ~= nil then
			if GetDistance(object)<500 then
				--print("\n Name "..object.name .. "\n")
				--print("\n Team "..object.team .. "\n")
				--print("\n x "..object.x .. "\n")
				--print("\n y "..object.y .. "\n")
				--print("\n z "..object.z .. "\n")
				end
				for k, x in ipairs(JPKS) do
					if object.name == x.name then 
						if GetDistance(object,x.location) < 1000 then
						local name = object.name
						local team = x.team
						 CheckCreep1(name,team) 
						
						creep = { hero = object, name = object.name, team = x.team, death = 0, location = x.location }
						table.insert(jungle1,creep)
						
					end
				end
			end
		end
	end

end

function CheckCreep1(name,team)
    if #jungle1 > 0 then
        for i=1,#jungle1, 1 do
            if name == jungle1[i].name and team == jungle1[i].team then 
			table.remove(jungle1,i)
			break
			end
        end
    end
end

function KS1()
	if #jungle1 > 0 then
		for i, creep in pairs(jungle1) do
			if creep.name == "AncientGolem" or creep.name == "Dragon" or creep.name == "Worm" then
				if creep.hero.dead == 0 and creep.hero.visible==1 and GetDistance(creep.hero) <= 300 then --and creep.team ~= myteam
					if (CDMG+smitedamage > creep.hero.health and NunuConfig.smite) or CDMG > creep.hero.health then 				
					--cfa={x=creep
					CustomCircle(100,20,5,creep.hero)
					CastSpellTarget('Q',creep.hero)
					else
					CustomCircle(100,20,3,creep.hero)
					end
				end
				if creep.hero.dead == 0 and creep.hero.visible==1 and GetDistance(creep.hero) > 300 then --and creep.team ~= myteam
					CustomCircle(100,20,1,creep.hero)
					if (CDMG+smitedamage > creep.hero.health and NunuConfig.smite) or CDMG > creep.hero.health then 				
					--cfa={x=creep
					CustomCircle(100,20,2,creep.hero)
					end
				end

			end
		end
	end
end
----------------------------ENEMY RED TOO
function UpdatejungleTable2()
	for i=1, objManager:GetMaxObjects(), 1 do
		object = objManager:GetObject(i)
			if object ~= nil then
				for k, x in ipairs(junglePositionERed) do
					if object.name == x.name then 
						if GetDistance(object,x.location) < 1000 then
						local name = object.name
						local team = x.team
						CheckCreep2(name,team) 
							creep = { hero = object, name = object.name, team = x.team, death = 0, location = x.location }
							table.insert(jungle2,creep)

					end
				end
			end
		end
	end

end

function CheckCreep2(name,team)
    if #jungle2 > 0 then
        for i=1,#jungle2, 1 do
            if name == jungle2[i].name and team == jungle2[i].team then 
			table.remove(jungle2,i)
			break
		end
        end
    end
end

function KS2()
	if #jungle2 > 0 then
		for i, creep in pairs(jungle2) do
			if creep.name == "AncientGolem" or creep.name == "Dragon" or creep.name == "Worm" or creep.name == "LizardElder" then
				if creep.hero.dead == 0 and creep.hero.visible==1 and GetDistance(creep.hero) <= 300 then --and creep.team ~= myteam
					
					if (CDMG+smitedamage > creep.hero.health and NunuConfig.smite) or CDMG > creep.hero.health then 				
					CustomCircle(100,20,5,creep.hero)
					CastSpellTarget('Q',creep.hero)
					else
					CustomCircle(100,20,3,creep.hero)
					end
				end
				if creep.hero.dead == 0 and creep.hero.visible==1 and GetDistance(creep.hero) > 300 then --and creep.team ~= myteam
					CustomCircle(100,20,1,creep.hero)
					if (CDMG+smitedamage > creep.hero.health and NunuConfig.smite) or CDMG > creep.hero.health then 				
					--cfa={x=creep
					CustomCircle(100,20,2,creep.hero)
					end
				end

			end
		end
	end
end
--------------------------BOTH BLUE
function UpdatejungleTable3()
	for i=1, objManager:GetMaxObjects(), 1 do
		object = objManager:GetObject(i)
			if object ~= nil then
				for k, x in ipairs(junglePositionBBlue) do
					if object.name == x.name then 
						if GetDistance(object,x.location) < 1000 then
						local name = object.name
						local team = x.team
						CheckCreep3(name,team) 

							creep = { hero = object, name = object.name, team = x.team, death = 0, location = x.location}
							table.insert(jungle3,creep)
						
					end
				end
			end
		end
	end

end

function CheckCreep3(name,team)
    if #jungle3 > 0 then
        for i=1,#jungle3, 1 do
            if name == jungle3[i].name and team == jungle3[i].team then 
			table.remove(jungle3,i)
			break
		end
        end
    end
end

function KS3()
	if #jungle3 > 0 then
		for i, creep in pairs(jungle3) do
			if creep.name == "AncientGolem" or creep.name == "Dragon" or creep.name == "Worm" then
				if creep.hero.dead == 0 and creep.hero.visible==1 and GetDistance(creep.hero) <= 300 then --and creep.team ~= myteam
					if (CDMG+smitedamage > creep.hero.health and NunuConfig.smite) or CDMG > creep.hero.health then 				
					CustomCircle(100,20,5,creep.hero)
					CastSpellTarget('Q',creep.hero)
					else
					CustomCircle(100,20,3,creep.hero)
					end
				end
				if creep.hero.dead == 0 and creep.hero.visible==1 and GetDistance(creep.hero) > 300 then --and creep.team ~= myteam
					CustomCircle(100,20,1,creep.hero)
					if (CDMG+smitedamage > creep.hero.health and NunuConfig.smite) or CDMG > creep.hero.health then 				
					--cfa={x=creep
					CustomCircle(100,20,2,creep.hero)
					end
				end

			end
		end
	end
end
----------------------------ALL BUFFS
function UpdatejungleTable4()
	for i=1, objManager:GetMaxObjects(), 1 do
		object = objManager:GetObject(i)
			if object ~= nil then
				for k, x in ipairs(junglePositionALL) do
					if object.name == x.name then 
						if GetDistance(object,x.location) < 1000 then
						local name = object.name
						local team = x.team
						
						 CheckCreep4(name,team) 

							creep = { hero = object, name = object.name, team = x.team, death = 0, location = x.location }
							table.insert(jungle4,creep)

					end
				end
			end
		end
	end

end

function CheckCreep4(name,team)
    if #jungle4 > 0 then
        for i=1,#jungle4, 1 do
            if name == jungle4[i].name and team == jungle4[i].team then 
			table.remove(jungle4,i)
			break
		end
        end
    end
end

function KS4()
	if #jungle4 > 0 then
		for i, creep in pairs(jungle4) do
			if creep.name == "AncientGolem" or creep.name == "Dragon" or creep.name == "Worm" or creep.name == "LizardElder" then
				if creep.hero.dead == 0 and creep.hero.visible==1 and GetDistance(creep.hero) <= 300 then --and creep.team ~= myteam
					if (NunuConfig.smite and CDMG+smitedamage > creep.hero.health) or CDMG > creep.hero.health then 				
					CustomCircle(100,20,5,creep.hero)
					CastSpellTarget('Q',creep.hero)
					else
					CustomCircle(100,20,3,creep.hero)
					end
				end
				if creep.hero.dead == 0 and creep.hero.visible==1 and GetDistance(creep.hero) > 300 then --and creep.team ~= myteam
					CustomCircle(100,20,1,creep.hero)
					if (CDMG+smitedamage > creep.hero.health and NunuConfig.smite) or CDMG > creep.hero.health then 				
					CustomCircle(100,20,2,creep.hero)
					end
				end

			end
		end
	end
end
----------------------------END OF THE JUNGLE
 
SetTimerCallback("Run")