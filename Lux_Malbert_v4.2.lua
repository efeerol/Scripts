require "Utils"
require 'spell_damage'
print=printtext
printtext("\nOh Lux\n")
printtext("\nBy Malbert\n")
printtext("\nVersion 4.2\n")
				print("\n Team "..myHero.team .. "\n")
--local target
local escapetarget
local shieldally
local ignitedamage
local targetult
local targetcombo
local Atimer=os.clock()
local Ecast=false
local delay=0.001
local target600

local _registry = {}
local junglewho={"Baron, Drag, EBlue", "Baron, Drag, EBlue, ERed", "Baron, Drag, BothBlue", "ALL JUNGLE BUFFS","OFF"}
local index=1
local egg = {team = 0, enemy = 0}
local zac = {team = 0, enemy = 0}
local aatrox = {team = 0, enemy = 0}
local qDelay=0
local qSpeed=0
			local rList={}
			
LuxConfig = scriptConfig("Luxtastic", "Lux Config")
LuxConfig:addParam("combo", "Q Stun Combo", SCRIPT_PARAM_ONKEYDOWN, false, 88)
LuxConfig:addParam("escape", "Escape Walking", SCRIPT_PARAM_ONKEYDOWN, false, 65)
LuxConfig:addParam("comboBB", "Burst Combo", SCRIPT_PARAM_ONKEYDOWN, false, 84)
LuxConfig:addParam("pq4m", "Predict Q4 Me", SCRIPT_PARAM_ONKEYTOGGLE, true, 55)
LuxConfig:addParam("pe4m", "Auto E Pop", SCRIPT_PARAM_ONKEYTOGGLE, true, 48)
LuxConfig:addParam("ultFinish", "Use Ult with Burst to Finish Only", SCRIPT_PARAM_ONKEYTOGGLE, false, 56)
LuxConfig:addParam("shield", "AutoShield", SCRIPT_PARAM_ONKEYTOGGLE, true, 57)
LuxConfig:addParam("igniteks", " Ignite KillSteal", SCRIPT_PARAM_ONKEYTOGGLE, true, 118)
LuxConfig:addParam("ks", " KillSteal", SCRIPT_PARAM_ONKEYTOGGLE, true, 119)
LuxConfig:addParam("draw", "Draw KillSteals", SCRIPT_PARAM_ONOFF, true)
LuxConfig:addParam("nm", " NearMouse Targetting", SCRIPT_PARAM_ONOFF, true)
LuxConfig:addParam('choosejungle', "Jungle Ult Killstealing", SCRIPT_PARAM_NUMERICUPDOWN, 1, 48,1,5,1)
LuxConfig:addParam('s', "Speed of Burst Combo", SCRIPT_PARAM_NUMERICUPDOWN, 0.05, 117,0,1,0.05)
LuxConfig:addParam('qs', "QSpeed", SCRIPT_PARAM_NUMERICUPDOWN, 11.5, 189,11,14,0.5)
LuxConfig:addParam('qd', "QDelay", SCRIPT_PARAM_NUMERICUPDOWN, 5, 187,2,6,0.2)

LuxConfig:permaShow("comboBB")
LuxConfig:permaShow("pq4m")
LuxConfig:permaShow("pe4m")
LuxConfig:permaShow("ultFinish")
LuxConfig:permaShow("shield")
LuxConfig:permaShow("ks")
LuxConfig:permaShow("nm")
LuxConfig:permaShow("igniteks")

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
 
local autoE=false

--------Spell Stuff
local QRDY=0
local WRDY=0
local ERDY=0
local RRDY=0

local cast=false
local modu=0
local EObject
local eTimer = 0
local EObjecttimer = 0
local myteam = myHero.team
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


local modcounter = 0

function Run()

	if cc<400 then cc=cc+1 end
        if (cc==30) then
                LoadTable()
        end
	escapetarget=nil
	shieldally=nil
	delay=LuxConfig.s
	qDelay=LuxConfig.qd
	qSpeed=LuxConfig.qs


	if LuxConfig.shield and WRDY==1 then
                autoE=true
        else
                autoE=false
        end
	if LuxConfig.nm then
		targetcombo = GetWeakEnemy("MAGIC", 1300,"NEARMOUSE")
	elseif not LuxConfig.nm then
		targetcombo = GetWeakEnemy("MAGIC", 1300)
	end
targetult = GetWeakEnemy("MAGIC", 3000)
target600 = GetWeakEnemy("TRUE", 600)

	if IsChatOpen() == 0 and LuxConfig.escape then
	------------------------------
		for i=1, objManager:GetMaxHeroes(), 1 do
		local hero = objManager:GetHero(i)
		if hero~=nil and hero.dead~=1 and hero.visible==1 and hero.team~=myHero.team and GetD(hero)<1100 and escapetarget==nil then
			escapetarget=hero
		elseif hero~=nil and hero.dead~=1 and hero.team~=myHero.team and GetD(hero)<1100 and (escapetarget.dead==1 or hero.visible==0 or  GetD(hero)<GetD(escapetarget)) then
			escapetarget=hero
		end
		if hero~=nil and hero.dead~=1 and hero.visible==1 and hero.team==myHero.team and GetD(hero)<1000 and allyshield==nil then
			allyshield=hero
		elseif hero~=nil and hero.dead~=1 and hero.team==myHero.team and GetD(hero)<1000 and (allyshield.dead==1 or hero.visible==0 or hero.health<allyshield.health) then
			allyshield=hero
		end
		end
	-----------------------------------	
		
		if allyshield~=nil and WRDY==1 then
			CastSpellXYZ('W',GetFireahead(allyshield,1,14))
		elseif escapetarget~=nil and WRDY==1 then
			CastSpelltarget('W',GetFireahead(escapetarget,1,14))
		end
		
		if escapetarget~=nil then
			if QRDY==1 then CastSpellXYZ('Q',GetFireahead(escapetarget,qDelay,qSpeed)) end
			if EObjecttimer==0 then
				if ERDY==1 then CastSpellXYZ('E',GetFireahead(escapetarget,3.5,13)) end
			elseif EObjecttimer~=0 and EObjecttimer+3<os.clock() then
				if ERDY==1 then CastSpellXYZ('E',GetFireahead(escapetarget,3.5,13)) end
			end
		end
		--if escapetarget~=nil and EObject~=nil and GetD(escapetarget,EObject)>330 then
		--	if ERDY then CastSpellXYZ('E',GetFireahead(escapetarget,5,12)) end
		--end
		MoveToMouse()
	end	
	
	
	
	if IsChatOpen() == 0 and LuxConfig.combo then
                Combo2()
        end

		
	if LuxConfig.ks then 
		if targetult~=nil then
			local tufax,tufay,tufaz=GetFireahead(targetult,6.5,0)
			local tufa={x=tufax,y=tufay,z=tufaz}
			if IsInvulnerable(targetult).status==0 and GetD(tufa)<3000 and targetult.health<getDmg('R',targetult,myHero)*RRDY then
				CastSpellXYZ('R',GetFireahead(targetult,6.5,0))
			end
		end
	end

	if LuxConfig.igniteks then 
		if myHero.SummonerD == 'SummonerDot' then
				ignitedamage = ((myHero.selflevel*20)+50)*IsSpellReady('D')
		elseif myHero.SummonerF == 'SummonerDot' then
						ignitedamage = ((myHero.selflevel*20)+50)*IsSpellReady('F')
		else
		ignitedamage=0
		end
		if target600~=nil and target600.health<ignitedamage then
			if myHero.SummonerD == 'SummonerDot' then
					if IsSpellReady('D') then CastSpellTarget('D',target600) end
			end
			if myHero.SummonerF == 'SummonerDot' then
					if IsSpellReady('F') then CastSpellTarget('F',target600) end
			end
		end		
	end
	
	if LuxConfig.pe4m and ERDY==1 and myHero.SpellNameE=="luxlightstriketoggle" then 
		if (EObject~=nil and targetcombo~=nil and GetD(EObject,targetcombo)>250) then
			CastSpellTarget("E",targetcombo)
		end
	end
	------------------------------------------------------------T COMBO
	
	if IsChatOpen() == 0 and LuxConfig.comboBB then
		TeamFight()		
	end
	------------
        if myHero.SpellTimeQ > 1.0 and GetSpellLevel('Q') > 0 and myHero.mana>=(40+10*GetSpellLevel('Q')) then
                QRDY = 1
                else QRDY = 0
        end
        if myHero.SpellTimeW > 1.0 and GetSpellLevel('W') > 0 and myHero.mana>=(65) then
                WRDY = 1
                else WRDY = 0
        end
        if myHero.SpellTimeE > 1.0 and GetSpellLevel('E') > 0 and myHero.mana>=(55+15*GetSpellLevel('E')) then
                ERDY = 1
                else ERDY = 0
        end
        if myHero.SpellTimeR > 1.0 and GetSpellLevel('R') > 0 and myHero.mana>=100 then
                RRDY = 1
        else RRDY = 0 end
        --------------------------
		
	if LuxConfig.choosejungle==1 then 
		index=1 
		KS1()
		UpdatejungleTable1()
	elseif LuxConfig.choosejungle==2 then 
		index=2 
		KS2()
		UpdatejungleTable2()
	elseif LuxConfig.choosejungle==3 then 
		index=3 
		KS3()
		UpdatejungleTable3()
	elseif LuxConfig.choosejungle==4 then 
		index=4 
		KS4()
		UpdatejungleTable4()
	elseif LuxConfig.choosejungle==5 then 
		index=5 
	end
end

function TeamFight()
	if targetcombo~=nil then
		if QRDY==1 then
			tcx,tcy,tcz = GetFireahead(targetcombo,qDelay,qSpeed)
			tc={x=tcx,y=tcy,z=tcz}
		end
		if QRDY==1 and LuxConfig.pq4m and (os.clock()>Atimer)  and GetD(tc)>100 and GetD(tc)<1200 then
			CastSpellXYZ("Q",tcx,tcy,tcz)
		elseif QRDY==1 and LuxConfig.pq4m and (os.clock()>Atimer) and GetD(tc)<=100 then
		CastSpellXYZ("Q",targetcombo.x,targetcombo.y,targetcombo.z)
		elseif QRDY==1 and not LuxConfig.pq4m and (os.clock()>Atimer) then
			CastSpellXYZ("Q",mousePos.x,0,mousePos.z)
		elseif ERDY==1 and myHero.SpellNameE=="LuxLightStrikeKugel" then
			local x1,y1,z1=GetFireahead(targetcombo,4.5,13)
			run_every(0.3,castE,x1,y1,z1)
		elseif not LuxConfig.ultFinish and RRDY==1 and targetcombo.dead~=1 and IsInvulnerable(targetcombo).status==0 then
			CastSpellXYZ("R",GetFireahead(targetcombo,6.5,0))
		elseif ERDY==1 and myHero.SpellNameE=="luxlightstriketoggle" and (os.clock()>Atimer or (EObject~=nil and GetD(EObject,targetcombo)>250)) then	
			CastSpellTarget("E",targetcombo)
		else
			if GetD(targetcombo)<400 then
				CastSummonerExhaust(targetcombo)
				UseAllItems(targetcombo)
			elseif GetD(targetcombo)<600 then
				CastSummonerExhaust(targetcombo)
				UseAllItems(targetcombo)
			end
			AttackTarget(targetcombo)

		end
	else
		MoveToMouse()
	end
end

function Combo2()
	if targetcombo ~= nil then
		if QRDY==1 and GetD(targetcombo) < 1100 then
			CastSpellXYZ("Q",mousePos.x,0,mousePos.z)
		end
		if myHero.SpellNameE=="luxlightstriketoggle" and (eTimer<os.clock() or (EObject~=nil and GetD(EObject,targetcombo)>250)) then						
			CastSpellTarget("E",targetcombo)
		end
		UseAllItems(targetcombo)
	else
			MoveToMouse()
	end
end

function castE(u,v,w)
	CastSpellXYZ("E",u,v,w)
end

function OnCreateObj(obj)
	if obj~=nil then
	
		if string.find(obj.charName,"LuxLightstrike_tar_green") and myHero.SpellNameE=="luxlightstriketoggle" then
						--[[modu=(modu+1)%2
						if modu==1 then
						EObjecttimer=os.clock()
						end                            
						if modu==0 then--]]
						EObject=obj
					   -- end
		end

		if LuxConfig.combo and targetcombo ~= nil then
			
					if string.find(obj.charName,"LuxLightBinding") and GetD(targetcombo, obj) < 10 and GetD(myHero, targetcombo) < 1300 and os.clock() > eTimer then
							AttackTarget(targetcombo)
							CastSpellTarget("E",targetcombo)
							eTimer = os.clock() + 5
							AttackTarget(targetcombo)
					end
					if  string.find(obj.charName,"LuxLightstrike") and RRDY==1 then
							CastSpellXYZ("R",targetcombo.x,0,targetcombo.z)
							AttackTarget(targetcombo)
					end
					--if string.find(obj.charName,"Global_Silence") then
						   
					--end
					if string.find(obj.charName,"LuxMaliceCannon") and ERDY==1 then
							AttackTarget(targetcombo)
							CastSpellTarget("E",targetcombo)
							AttackTarget(targetcombo)
					end
					if string.find(obj.charName,"LuxBlitz_nova") then
							AttackTarget(targetcombo)
							EObject=nil
							EObjecttimer=0
					end
				   
			
		elseif (LuxConfig.comboBB) and GetD(obj)<1000 then
		--printtext("\nOName " .. obj.charName .. " Oteam " .. obj.team .. " MTeam "..myHero.team)
			if string.find(obj.charName,"LuxBlitz_nova") then
				Atimer=os.clock()+(1/myHero.attackspeed+0.1)-delay/myHero.attackspeed
				Ecast=false
				EObject=nil
				 EObjecttimer=0
			end
			
		elseif EObject~=nil and string.find(obj.charName,"LuxBlitz_nova") and GetD(obj,EObject)<300 then
				EObject=nil
				 EObjecttimer=0
	   -- elseif GetD(obj)<1000 then      
			--printtext("\n" .. obj.charName .. " T "..os.clock().." PLACE "..obj.x)
		end
	
	
		if obj.charName == 'EggTimer.troy' then
				for i= 1,objManager:GetMaxHeroes(),1 do
						local hero=objManager:GetHero(i)
						if hero.name == 'Anivia' and GetDistance(obj, hero) < 10 then
								if hero.team == myHero.team then egg = {team = GetTickCount(), enemy = egg.enemy}
								else egg = {team = egg.team, enemy = GetTickCount()} end
						end
				end
		elseif obj.charName == 'Aatrox_Passive_Death_Activate.troy' then
				for i= 1,objManager:GetMaxHeroes(),1 do
						local hero=objManager:GetHero(i)
						if hero.name == 'Aatrox' and GetDistance(obj, hero) < 10 then
								if hero.team == myHero.team then aatrox = {team = GetTickCount(), enemy = aatrox.enemy}
								else aatrox = {team = aatrox.team, enemy = GetTickCount()} end
						end
				end
		elseif obj.charName == 'ZacPassiveExplosion.troy' then
				for i= 1,objManager:GetMaxHeroes(),1 do
						local hero=objManager:GetHero(i)
						if hero.name == 'Zac' and GetDistance(obj, hero) < 10 then
								if hero.team == myHero.team then zac = {team = GetTickCount(), enemy = zac.enemy}
								else zac = {team = zac.team, enemy = GetTickCount()} end
						end
				end
		end
		
	end
end


function OnProcessSpell(unit,spell)
--printtext("\nS "..spell.name.."  " ..os.clock().." E "..myHero.SpellNameE.."\n")  

	if unit.name==myHero.name and unit.team==myHero.team then  
		if string.find(spell.name,"LuxLightBinding") ~= nil then
			Atimer=os.clock()+(1/myHero.attackspeed+0.1)-delay/myHero.attackspeed
		elseif string.find(spell.name,"LuxLightStrikeKugel") ~= nil then
			Ecast=true
		elseif string.find(spell.name,"luxlightstriketoggle") ~= nil then
			Atimer=os.clock()+(1/myHero.attackspeed+0.1)-delay/myHero.attackspeed
			Ecast=false
			EObject=nil
		elseif string.find(spell.name,"LuxMaliceCannon") ~= nil then
			Atimer=os.clock()+(1/myHero.attackspeed+0.1)-delay/myHero.attackspeed

                
		end 
		
	elseif autoE==true and unit~=nil then
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
               
                --unit.name~="Worm" and unit.name~="TT_Spiderboss7.1.1" and
                if spell ~= nil and unit.team ~= myHero.team and spell.target~=nil and spell.target.name~=nil and spell.target.name == myHero.name then
                        if spell.name == Q then
                                CastSpellXYZ("W",GetCursorWorldX(),0,GetCursorWorldZ())
                                if spellDmg[unit.name] and getDmg("Q",myHero,unit)~=nil and getDmg("Q",myHero,unit) > myHero.health then
                                        CastSummonerBarrier()
                                        CastSummonerHeal()
                                end
               
                        elseif spell.name == W then
                        CastSpellXYZ("W",GetCursorWorldX(),0,GetCursorWorldZ())
                        if spellDmg[unit.name] and getDmg("W",myHero,unit)~=nil and getDmg("W",myHero,unit) > myHero.health then
                                        CastSummonerBarrier()
                                        CastSummonerHeal()
                                end
               
                        elseif spell.name == E then
                            CastSpellXYZ("W",GetCursorWorldX(),0,GetCursorWorldZ())
                        if spellDmg[unit.name] and getDmg("E",myHero,unit)~=nil and getDmg("E",myHero,unit) > myHero.health then
                                        CastSummonerBarrier()
                                        CastSummonerHeal()
                        end
 
                        elseif spell.name == R then
                        CastSpellXYZ("W",GetCursorWorldX(),0,GetCursorWorldZ())
                        if spellDmg[unit.name] and getDmg("R",myHero,unit)~=nil and getDmg("R",myHero,unit) > myHero.health then
                                        CastSummonerBarrier()
                                        CastSummonerHeal()
                        end
               
                        elseif string.find(unit.name,"minion") == nil and string.find(unit.name,"Minion_") == nil and (spell.name:find("BasicAttack") or spell.name:find("BasicAttack2") or spell.name:find("BasicaAttack3")  or spell.name:find("ChaosTurretFire")) then
                        CastSpellXYZ("W",GetCursorWorldX(),0,GetCursorWorldZ())
                                if (unit.baseDamage + unit.addDamage) > myHero.health then
                                        --print("\nMN "..unit.name)
                                        CastSummonerBarrier()
                                        CastSummonerHeal()
                                end    
                        elseif spell.name:find("BasicAttack") or spell.name:find("BasicAttack2") or spell.name:find("BasicaAttack3")  or spell.name:find("ChaosTurretFire") then
                        if (unit.baseDamage + unit.addDamage) > myHero.health then
                                CastSpellXYZ("W",GetCursorWorldX(),0,GetCursorWorldZ())
                                        CastSummonerBarrier()
                                        CastSummonerHeal()
                                end    
                        elseif spell.name:find("CritAttack") then
                        CastSpellXYZ("W",GetCursorWorldX(),0,GetCursorWorldZ())
                        if 2*(unit.baseDamage + unit.addDamage) > myHero.health then
                                        CastSummonerBarrier()
                                        CastSummonerHeal()
                                end
                end
   
                end
               
                if string.find(unit.name,"Minion_") == nil and string.find(unit.name,"Turret_") == nil then
                        if (unit.team ~= myHero.team) and string.find(spell.name,"Basic") == nil then
 
                                if spell.name == Q then
                                        --if spellDmg[unit.name] and getDmg("Q",myHero,unit)~=nil and getDmg("Q",myHero,unit) > myHero.health then
               
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
                                        --if spellDmg[unit.name] and getDmg("W",myHero,unit)~=nil and getDmg("W",myHero,unit) > myHero.health then
               
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
                                        --if spellDmg[unit.name] and getDmg("E",myHero,unit)~=nil and getDmg("E",myHero,unit) > myHero.health then
               
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
                                        --if spellDmg[unit.name] and getDmg("R",myHero,unit)~=nil and getDmg("R",myHero,unit) > myHero.health then
               
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

function dodgeaoe(pos1, pos2, radius)
    local calc = (math.floor(math.sqrt((pos2.x-myHero.x)^2 + (pos2.z-myHero.z)^2)))
    if calc < radius then
               
                                CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
                                        CastSummonerBarrier()
                                        CastSummonerHeal()
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
       
                                CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
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
    perpendicular = (math.floor((math.abs((pm2x-pos1.x)*(pos1.z-myHero.z)-(pos1.x-myHero.x)*(pm2z-pos1.z)))/(math.sqrt((pm2x-pos1.x)^2 + (pm2z-pos1.z)^2))))
    k = ((pm2z-pos1.z)*(myHero.x-pos1.x) - (pm2x-pos1.x)*(myHero.z-pos1.z)) / ((pm2z-pos1.z)^2 + (pm2x-pos1.x)^2)
        x4 = myHero.x - k * (pm2z-pos1.z)
        z4 = myHero.z + k * (pm2x-pos1.x)
        calc3 = (math.floor(math.sqrt((x4-myHero.x)^2 + (z4-myHero.z)^2)))
    if perpendicular < radius and calc1 < calc4 and calc2 < calc4 then
               
                               
                                        CastSpellXYZ("E",GetCursorWorldX(),0,GetCursorWorldZ())
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

---------------------------ENEMY BLUE
function UpdatejungleTable1()
	for i=1, objManager:GetMaxObjects(), 1 do
		object = objManager:GetObject(i)
			if object ~= nil then
			if GetD(object)<500 then
				--print("\n Name "..object.name .. "\n")
				--print("\n Team "..object.team .. "\n")
				--print("\n x "..object.x .. "\n")
				--print("\n y "..object.y .. "\n")
				--print("\n z "..object.z .. "\n")
				end
				for k, x in ipairs(JPKS) do
					if object.name == x.name then 
						if GetD(object,x.location) < 600 then
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
				if creep.hero.dead == 0 and creep.hero.visible==1 and GetD(creep.hero) < 3000 then --and creep.team ~= myteam
					if getDmg("R",creep.hero,myHero) > creep.hero.health then 				
					--cfa={x=creep
					CustomCircle(100,20,5,creep.hero)
					CastSpellXYZ('R',GetFireahead(creep.hero,6.5,0))
					else
					CustomCircle(100,20,3,creep.hero)
					end
				end
				if creep.hero.dead == 0 and creep.hero.visible==1 and GetD(creep.hero) > 3000 then --and creep.team ~= myteam
					CustomCircle(100,20,1,creep.hero)
					if getDmg("R",creep.hero,myHero) > creep.hero.health then 				
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
						if GetD(object,x.location) < 600 then
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
				if creep.hero.dead == 0 and creep.hero.visible==1 and GetD(creep.hero) < 3000 then --and creep.team ~= myteam
					
					if getDmg("R",creep.hero,myHero) > creep.hero.health then 				
					CustomCircle(100,20,5,creep.hero)
					CastSpellXYZ('R',GetFireahead(creep.hero,6.5,0))
					else
					CustomCircle(100,20,3,creep.hero)
					end
				end
				if creep.hero.dead == 0 and creep.hero.visible==1 and GetD(creep.hero) > 3000 then --and creep.team ~= myteam
					CustomCircle(100,20,1,creep.hero)
					if getDmg("R",creep.hero,myHero) > creep.hero.health then 				
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
						if GetD(object,x.location) < 600 then
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
				if creep.hero.dead == 0 and creep.hero.visible==1 and GetD(creep.hero) < 3000 then --and creep.team ~= myteam
					if getDmg("R",creep.hero,myHero) > creep.hero.health then 				
					CustomCircle(100,20,5,creep.hero)
					CastSpellXYZ('R',GetFireahead(creep.hero,6.5,0))
					else
					CustomCircle(100,20,3,creep.hero)
					end
				end
				if creep.hero.dead == 0 and creep.hero.visible==1 and GetD(creep.hero) > 3000 then --and creep.team ~= myteam
					CustomCircle(100,20,1,creep.hero)
					if getDmg("R",creep.hero,myHero) > creep.hero.health then 				
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
						if GetD(object,x.location) < 600 then
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
				if creep.hero.dead == 0 and creep.hero.visible==1 and GetD(creep.hero) < 3000 then --and creep.team ~= myteam
					if getDmg("R",creep.hero,myHero) > creep.hero.health then 				
					CustomCircle(100,20,5,creep.hero)
					CastSpellXYZ('R',GetFireahead(creep.hero,6,0))
					else
					CustomCircle(100,20,3,creep.hero)
					end
				end
				if creep.hero.dead == 0 and creep.hero.visible==1 and GetD(creep.hero) > 3000 then --and creep.team ~= myteam
					CustomCircle(100,20,1,creep.hero)
					if getDmg("R",creep.hero,myHero) > creep.hero.health then 				
					CustomCircle(100,20,2,creep.hero)
					end
				end

			end
		end
	end
end
----------------------------END OF THE JUNGLE



function OnDraw()
	if myHero.dead==0 then
		positionText=15
		for i = 1, 5, 1 do
			if i ==index and junglewho[i]~=nil then
				DrawText("Jungle Ult KS: ".. junglewho[index] .. "", 100, positionText*i, Color.LightBlue)
			elseif i~=index and junglewho[i]~=nil then
				DrawText("Jungle Ult KS: ".. junglewho[i] .. "", 100, positionText*i, Color.White)
			end
		end
		if targetcombo~=nil then
			CustomCircle(150,3,2,targetcombo)
		end
		if targetult~=nil then
			CustomCircle(150,10,2,targetult)
		end
		if LuxConfig.draw and RRDY==1 then
			for i=1, objManager:GetMaxHeroes(), 1 do			
				local hero = objManager:GetHero(i)
				if hero~=nil and hero.dead~=1 and hero.visible==1 and hero.team~=myHero.team and GetD(hero)<3500 and IsInvulnerable(hero).status==0 then
					local tufax,tufay,tufaz=GetFireahead(hero,6.5,0)
					local tufa={x=tufax,y=tufay,z=tufaz}
					if GetD(tufa)<3000 and hero.health<getDmg('R',hero,myHero)*RRDY then
						local xx2,yy2,zz2=tufa.x,tufa.y,tufa.z
						local cursor2={x=xx2,y=yy2,z=zz2}
						local d2=zz2-myHero.z
						local Theta2
						if xx2>myHero.x then
							Theta2=math.acos(d2/GetD(cursor2))
						elseif xx2<=myHero.x then
							Theta2=-math.acos(d2/GetD(cursor2))
						end
						local dist=GetD(tufa)
						rList[hero.name]={obj=hero,distance=dist,angle=Theta2}
						local rLine=0
						for i, other in pairs(rList) do
							if other~=nil and other.obj.dead==0 and IsInvulnerable(other.obj).status==0 and other.obj.visible==1 and other.name~=hero.name then
								local oufax,oufay,oufaz=GetFireahead(other.obj,6.5,0)
								local oufa={x=oufax,y=oufay,z=oufaz}
								local odist=GetD(oufa)
								if odist<3000 and math.abs(Theta2-other.angle)*math.max(odist,dist)<=200 then
									rLine=rLine+1
								end
							end
						end
						if rLine>0 then --0xFF00FF00
							DrawLineObject(myHero,400,2,Theta2,150)
							CustomCircle(150,10,4,hero)
						else
							DrawLineObject(myHero,400,1,Theta2,150)
							CustomCircle(150,10,4,hero)
						end
					end
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
                                        if string.find(object.charName,"eyeforaneye") ~= nil and GetDistance(target,object) <= 20 then return {status = 3, name = 'Intervention', amount = 0, type = 'ALL'}
                                        elseif string.find(object.charName,"nickoftime") ~= nil and GetDistance(target,object) <= 20 then return {status = 1, name = 'Chrono Shift', amount = 0, type = 'REVIVE'}
                                        elseif target.name == 'Poppy' and string.find(object.charName,"DiplomaticImmunity_tar") ~= nil and GetDistance(myHero,object) > 20 then
                                                for i=1, objManager:GetMaxObjects(), 1 do
                                                        local diObject = objManager:GetObject(i)
                                                        if diObject ~= nil and string.find(diObject.charName,"DiplomaticImmunity_buf") ~= nil and GetDistance(target,diObject) <= 20 then return {status = 3, name = 'Diplomatic Immunity', amount = 0, type = 'ALL'} end
                                                end
                                        elseif target.name == 'Vladimir' and string.find(object.charName,"VladSanguinePool_buf") ~= nil and GetDistance(myHero,object) <= 20 then return {status = 3, name = 'Sanguine Pool', amount = 0, type = 'ALL'}
--                                      elseif string.find(object.charName,"Summoner_Barrier") ~= nil and GetDistance(target,object) <= 20 then return 2--, 'NONE'
                                        elseif string.find(object.charName,"Global_Spellimmunity") ~= nil or string.find(object.charName,"Morgana_Blackthorn_Blackshield") ~= nil and GetDistance(target,object) <= 20 then
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
                                        elseif target.name == 'Tryndamere' and string.find(object.charName,"UndyingRage_buf") ~= nil and GetDistance(target,object) <= 20 then return {status = 1, name = 'Undying Rage', amount = 0, type = 'NONE'}
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
--                                      elseif string.find(object.charName,"GLOBAL_Item_FoM_Shield") ~= nil and GetDistance(target,object) <= 30 then return 2--, 'NONE'
                                        elseif string.find(object.charName,"rebirthready") ~= nil and GetDistance(target,object) <= 20 then return {status = 1, name = 'Guardian Angel', amount = 0, type = 'REVIVE'}
--                                      elseif target.name == 'Nautilus' and string.find(object.charName,"Nautilus_W_shield_cas") ~= nil and GetDistance(target,object) <= 20 then return 2--, 'NONE'
                                        end
                                end
                        end
                end
        end
        return {status = 0, name = nil, amount = nil, type = nil}
end



SetTimerCallback("Run")