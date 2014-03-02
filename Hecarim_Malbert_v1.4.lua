require 'Utils'
require 'spell_damage'
print=printtext
print("\nHecarim\n")
print("\nBy Malbert\n")
print('\nVersion 1.4\n')

local target
local targetQ
local targetW
local targetAA
local target600
local ignitedamage
local ETimer=0
local trfx,trfy,trfz
local trfa
local EDamage
local RDamage
local QDamage
local QQDamage

HecConfig = scriptConfig("Hec", "Hec Config")
HecConfig:addParam('teamfight', 'TeamFight', SCRIPT_PARAM_ONKEYDOWN, false, 84)
HecConfig:addParam('q', 'AutoQ', SCRIPT_PARAM_ONKEYTOGGLE, false, 55)
HecConfig:addParam('w', 'AutoW', SCRIPT_PARAM_ONKEYTOGGLE, false, 56)
HecConfig:addParam('e', 'DrawE', SCRIPT_PARAM_ONKEYTOGGLE, true, 57)
HecConfig:addParam('ult', 'Teamfight Ult', SCRIPT_PARAM_ONKEYTOGGLE, true, 48)
HecConfig:addParam('s', 'SmiteSteal', SCRIPT_PARAM_ONKEYTOGGLE, false, 189)
HecConfig:addParam('ik', 'Ignite Killsteal', SCRIPT_PARAM_ONOFF, true)
HecConfig:addParam('dokillsteal', 'Killsteal', SCRIPT_PARAM_ONOFF, true)
HecConfig:permaShow('q')
HecConfig:permaShow('w')
HecConfig:permaShow('e')
HecConfig:permaShow('ult')
HecConfig:permaShow('s')
HecConfig:permaShow('ik')
HecConfig:permaShow('dokillsteal')


function Hecarim()

	targetAA=GetWeakEnemy("PHYS", myHero.range + GetDistance(GetMinBBox(myHero)))
	target=GetWeakEnemy("PHYS", 1200)
	targetQ=GetWeakEnemy("PHYS", 350)
	targetW=GetWeakEnemy("PHYS", 525)
	target600=GetWeakEnemy("TRUE", 600)
	
	if target~=nil then
		if CanCastSpell('R') then
			trfx,trfy,trfz=GetFireahead(target,1.7,15)
			trfa={x=trfx,y=trfy,z=trfz}
		end
		
			tqfx,tqfy,tqfz=GetFireahead(target,1,0)
			tqfa={x=tqfx,y=tqfy,z=tqfz}
		 EDamage=getDmg('E',target,myHero)*CanUseSpell('E')*InRangeE(target)
		 RDamage=getDmg('R',target,myHero,3)*CanUseSpell('R')
		 QDamage=getDmg('Q',target,myHero)*CanUseSpell('Q')
		 if targetQ~=nil then
			tqfxQ,tqfyQ,tqfzQ=GetFireahead(targetQ,1,0)
			tqfaQ={x=tqfxQ,y=tqfyQ,z=tqfzQ}
			QQDamage=getDmg('Q',targetQ,myHero)*CanUseSpell('Q')
		 end
	end

	if IsChatOpen()==0 and HecConfig.teamfight then teamfight() end
	if HecConfig.q then AQ() end
	if HecConfig.w then AW() end
	if HecConfig.e then DrawE() end
	ignite()
	if HecConfig.dokillsteal then killsteal() end
	if HecConfig.s then smitesteal() end
	if HecConfig.ik and not HecConfig.dokillsteal then ik() end

end



function OnProcessSpell(unit,spell)
	if unit.charName==myHero.charName then
		--print("\nSP: "..spell.name)
		if string.find(spell.name, "HecarimRamp") then
			ETimer=os.clock()+4
		end
	end
end


function teamfight()
	if target~=nil then
		AQ(target)
		AW(target)
		if InRangeE(target)==1 then
			CastSpellTarget('E',myHero)
			AttackTarget(target)
		end
		if HecConfig.ult and CanCastSpell('R') then
			if (GetD(target)>350 or myHero.health<myHero.maxHealth*0.25) and GetD(trfa)<1000 then
				CastSpellXYZ('R',trfx,trfy,trfz)
			end
		end
		if GetD(target)<400 then
			CastSummonerExhaust(target)
			UseAllItems(target)
		elseif GetD(target)<600 then
			CastSummonerExhaust(target)
			UseTargetItems(target)
		end
		AttackTarget(target)
	else
		MoveToMouse()
	end
end


function AQ(enemy)
	if enemy==nil then
		if targetQ~=nil and CanCastSpell('Q') and GetD(tqfaQ)<350 then
			CastSpellTarget('Q',myHero)
		end
	else
		if enemy~=nil and CanCastSpell('Q') and GetD(tqfa)<350 then
			CastSpellTarget('Q',myHero)
		end
	end
end


function AW(enemy)
	if enemy==nil or myHero.health<myHero.maxHealth*0.25 then
		if targetW~=nil and CanCastSpell('W') then
			CastSpellTarget('W',myHero)
		end
	else
		if enemy~=nil and CanCastSpell('W') and myHero.health<myHero.maxHealth*0.85 and GetD(enemy)<525 then
			CastSpellTarget('W',myHero)
		end
	end
end

function InRangeE(unit)
	if unit~=nil and CanCastSpell('E') and GetD(unit)>350 and GetD(unit)<4*(myHero.movespeed) then
		return 1
	else
		return 0
	end
end

function DrawE()
	if CanCastSpell('E') then
		CustomCircle(4*(myHero.movespeed+myHero.movespeed*0.25),10,3,myHero)
	elseif ETimer>os.clock() then
		CustomCircle((ETimer-os.clock())*(myHero.movespeed),10,2,myHero)
	end
end

function killsteal()
	if target~=nil then
		
		if target.health<QDamage+ignitedamage and GetD(tqfa)<350 then
			CastSpellTarget('Q',myHero)
			AttackTarget(target)
		elseif target.health<EDamage+QDamage and GetD(tqfa)<350 then
			AttackTarget(target)
			CastSpellTarget('E',myHero)
			AttackTarget(target)
		elseif target.health<(EDamage+QDamage)*CanUseSpell('E') and (HecConfig.teamfight or not surrounded(target)) then
			AttackTarget(target)
			CastSpellTarget('E',myHero)
			AttackTarget(target)
		elseif target.health<(RDamage+QDamage)*CanUseSpell('R') and GetD(trfa)<1000 and (HecConfig.teamfight or not surrounded(target)) then
				CastSpellXYZ('R',trfx,trfy,trfz)	
				AttackTarget(target)	
		elseif target.health<QDamage+ignitedamage and GetD(tqfa)<350 then
			if ignitedamage~=0 then
				CastSummonerIgnite(target)
			end
			CastSpellTarget('Q',myHero)
			AttackTarget(target)
		elseif target.health<EDamage+QDamage+ignitedamage and GetD(tqfa)<350 then
			if ignitedamage~=0 then
				CastSummonerIgnite(target)
			end
			AttackTarget(target)
			CastSpellTarget('E',myHero)
			AttackTarget(target)
		elseif target.health<(EDamage+QDamage+ignitedamage)*CanUseSpell('E') and (HecConfig.teamfight or not surrounded(target)) then
			if ignitedamage~=0 then
				CastSummonerIgnite(target)
			end
			AttackTarget(target)
			CastSpellTarget('E',myHero)
			AttackTarget(target)
		elseif target.health<(RDamage+QDamage+ignitedamage)*CanUseSpell('R') and GetD(trfa)<1000 and (HecConfig.teamfight or not surrounded(target)) then
			if ignitedamage~=0 then
				CastSummonerIgnite(target)
			end
				CastSpellXYZ('R',trfx,trfy,trfz)	
				AttackTarget(target)	
		end
		
		if targetQ~=nil and GetD(tqfaQ)<350 and targetQ.health<QQDamage then
			CastSpellTarget('Q',myHero)
		elseif targetQ~=nil and GetD(tqfaQ)<350 and targetQ.health<QQDamage+ignitedamage then
			if ignitedamage~=0 then
				CastSummonerIgnite(target)
			end
			CastSpellTarget('Q',myHero)
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

	if count>1 then
		return true
	elseif count==1 then
		return false
	else 
		return nil
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

function OnDraw()

	if myHero.dead==0 then
		if CanCastSpell('Q') then
			CustomCircle(350,5,1,myHero)
		end
		if CanCastSpell('W') then
			CustomCircle(525,5,4,myHero)
		end
	end
	
	if target~=nil then	
		CustomCircle(150,2,5,target)	
		if target.health<EDamage+QDamage then
			DrawSphere(40,25,3,target.x,target.y+300,target.z)
		elseif target.health<(RDamage+QDamage)*CanUseSpell('R') then
			DrawSphere(40,25,2,target.x,target.y+300,target.z)
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



SetTimerCallback('Hecarim')