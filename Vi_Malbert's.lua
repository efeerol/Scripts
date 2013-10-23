require 'Utils'
require 'spell_damage'

require 'winapi'
require 'SKeys'
local send = require 'SendInputScheduled'

local metakey = SKeys.Control
print=printtext
printtext("\nVIctory\n")
printtext("\nBy Malbert\n")
printtext("\nVersion 1.3\n")

local QRDY=0
local WRDY=0
local ERDY=0
local RRDY=0

local target
local targetclosest
local targetignite
local herotargetfarthest=nil
local attacking = false
local Range = 0
local timer = 0
local t0_attacking = 0
local attackAnimationDuration = 200
local attacked = false
local RangeAttackE = false
local Passive = true
local trueTheta = nil

local wUsedAt = 0
local vUsedAt = 0
local timerP=0
local bluePill = nil

ViConfig = scriptConfig("Vi", "Vi Config")
ViConfig:addParam("qe", "Q Escape Towards Mouse", SCRIPT_PARAM_ONKEYDOWN, false, 90)
ViConfig:addParam("q", "Harass always Q", SCRIPT_PARAM_ONKEYDOWN, false, 88)
ViConfig:addParam("teamfight", "Fight", SCRIPT_PARAM_ONKEYDOWN, false, 84)
ViConfig:addParam("pe", "Punch E Cone", SCRIPT_PARAM_ONKEYDOWN, false, 87)
ViConfig:addParam("ult", "Ult Initiation", SCRIPT_PARAM_ONKEYDOWN, false, 89)
ViConfig:addParam("p", "Passive Shield Smart Play", SCRIPT_PARAM_ONKEYTOGGLE, true, 189)
ViConfig:addParam("e", "AutoE AA Reset", SCRIPT_PARAM_ONKEYTOGGLE, true, 56)
ViConfig:addParam("draw", "Draw E Cones", SCRIPT_PARAM_ONOFF, true)
ViConfig:addParam("drawR", "Draw Ult Initiation", SCRIPT_PARAM_ONKEYTOGGLE, true,57)
ViConfig:addParam("k", "KillSteal", SCRIPT_PARAM_DOMAINUPDOWN, 1, 48, {"NoUltKS","NoQ/UltKS","IgniteKSOnly","Off"})
ViConfig:addParam('Qdelay', "Q Delay", SCRIPT_PARAM_NUMERICUPDOWN, 1.75, 48,0,10,0.1)
ViConfig:addParam('Rdelay', "R Delay", SCRIPT_PARAM_NUMERICUPDOWN, 1.6, 57,0,10,0.1)
ViConfig:addParam("pots", "Auto Potions", SCRIPT_PARAM_ONOFF, true)
ViConfig:addParam('smite', 'SmiteSteal', SCRIPT_PARAM_ONKEYTOGGLE, false, 55)

ViConfig:permaShow("teamfight")
ViConfig:permaShow("ult")
ViConfig:permaShow("p")
ViConfig:permaShow("e")
ViConfig:permaShow("drawR")
ViConfig:permaShow("k")
ViConfig:permaShow("Qdelay")
ViConfig:permaShow("Rdelay")

function ViRun()

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
	
			 herotargetfarthest=nil
	target = GetWeakEnemy('PHYS',1100,"NEARMOUSE")
	targetclosest = GetWeakEnemy('PHYS',600,"NEARMOUSE")
	targetignite = GetWeakEnemy('TRUE',600)
	
	if target~=nil then		
		local qdelay=ViConfig.Qdelay
		local rdelay=ViConfig.Rdelay
		tqfx,tqfy,tqfz = GetFireahead(target,qdelay,19.2)
		tqfa={x=tqfx,y=tqfy,z=tqfz}
		trfx,trfy,trfz = GetFireahead(target,rdelay,0)
		trfa={x=trfx,y=trfy,z=trfz}
	end
	if targetclosest~=nil then		
		local qdelay=ViConfig.Qdelay
		local rdelay=ViConfig.Rdelay
		tqfxq,tqfyq,tqfzq = GetFireahead(targetclosest,qdelay,19.2)
		tqfaq={x=tqfxq,y=tqfyq,z=tqfzq}
	end

	TimerSet()
	if myHero.dead == 1 then
		timer = 0
	end
	if  timer == 0 then
		Range = 450
	end
	if IsChatOpen()==0 and ViConfig.qe then
		Q()
		moveToCursor()
	end
	if IsChatOpen()==0 and ViConfig.q then harass() end
	if IsChatOpen()==0 and ViConfig.teamfight then teamfight() end
	if IsChatOpen()==0 and ViConfig.pe then punch() end
	if IsChatOpen()==0 and ViConfig.teamfight and ViConfig.ult then ultF() end
	if ViConfig.draw and target~=nil and myHero.dead~=1 and EThru(target)~=nil then
		DrawLineObject(myHero,GetD(EThru(target)),0xFF00FF00,trueTheta,1)
		DrawLineObject(EThru(target),600, 0xFF00FF00,trueTheta-(math.pi/7),1)
		DrawLineObject(EThru(target),600,0xFF00FF00,trueTheta+(math.pi/7),1)
    end
	ignite()
	if ViConfig.k<4 then killsteal() end
	
	if ViConfig.pots then RedElixir() end
	if ViConfig.smite then smitesteal() end
	if ViConfig.e and target~=nil and GetD(target)<275 and attacked==true then
		Espell(target)
		attacked = false
	end
end

function OnProcessSpell(unit,spell)
	if unit ~= nil and spell ~= nil and unit.charName == myHero.charName then
		if string.find(spell.name, "ttack") and target ~= nil and spell.target and ERDY == 1 then
			RangeAttackE = true
		end
		if string.find(spell.name, "ViQ") then --ViR
			--timer=GetClock() --Prevents Double Q
		end
	end
end

function OnCreateObj(obj)
	if obj ~= nil then
	--if GetD(obj)< 400 then
	--	print('\nOBJNAME '..obj.charName)
	--end
		if RangeAttackE == true then
		if string.find(obj.charName,"Vi_ArmorShred_Hit_1") ~= nil or string.find(obj.charName,"Vi_ArmorShred_Hit_2") or string.find(obj.charName,"Vi_ArmorShred_hold") ~= nil or string.find(obj.charName,"Vi_ArmorShred") ~= nil and GetD(myHero, object) < 225 then
            attacked = true
        end
		end
		if string.find(obj.charName,'Vi_Q_Channel_L') ~= nil and GetD(obj, myHero) < 100 then
			timer = GetClock()
		end
		if (string.find(obj.charName,'Vi_q_mis') ~= nil or string.find(obj.charName,'Vi_Q_Expire') ~= nil) and GetD(obj, myHero) < 100 then
			timer = 0
		end
		if (string.find(obj.charName,'Vi_Passive_Buff') ~= nil) and GetD(obj)< 100 then
			Passive=false
		end--Vi_Passive_Buff_DeActivate
		if (string.find(obj.charName,'Vi_Passive_BackPack') ~= nil) and GetD(obj)< 100 then
			Passive=true
		end
		if (GetDistance(myHero, obj)) < 100 and ViConfig.pots then
		if string.find(obj.charName,"FountainHeal") then
			timerP=os.clock()
			bluePill = obj
		end
	end
		
	end
end

function EThru(hitme)
	
	local hittingyou=nil
	trueTheta=nil
	if ERDY==1 then
		local minions=GetEnemyMinions(MINION_SORT_HEALTH_ASC)
		for _, minion in ipairs(minions) do
			if minion~=nil and minion.dead~=1 and GetD(minion)<600 and GetD(minion,hitme)<600 and GetD(minion)<GetD(hitme) then
				local xx,yy,zz=minion.x,minion.y,minion.z
				local cursor={x=xx,y=yy,z=zz}
				local dist=zz-myHero.z
				local enemyinTheta=false
				local Theta
				if xx>myHero.x then
					Theta=math.acos(dist/GetD(cursor))
				elseif xx<=myHero.x then
					Theta=-math.acos(dist/GetD(cursor))
				end
				
				local xxx,yyy,zzz=hitme.x,hitme.y,hitme.z
				local cursor2={x=xxx,y=yyy,z=zzz}
				local dist2=zzz-minion.z
				local Theta2
				if xxx>minion.x then
					Theta2=math.acos(dist2/GetD(cursor2))
				elseif xxx<=minion.x then
					Theta2=-math.acos(dist2/GetD(cursor2))
				end
				if Theta2<=Theta+(math.pi/6) and Theta2>=Theta-(math.pi/6) then
					enemyinTheta=true
				end
				
				if hittingyou==nil and enemyinTheta then
					hittingyou=minion
					trueTheta=Theta
				elseif hittingyou~=nil and GetD(minion)<GetD(hittingyou) and enemyinTheta then
					hittingyou=minion
					trueTheta=Theta
				end
			end
		end
		
		for i=1, objManager:GetMaxHeroes(), 1 do
			hero = objManager:GetHero(i)
			if hero~=nil and hero.dead~=1 and hero.team~=myHero.team and hero.name~=hitme.name and GetD(hero)<600 and GetD(hero,hitme)<600 and GetD(hero)<GetD(hitme) then
				local xx,yy,zz=hero.x,hero.y,hero.z
				local cursor={x=xx,y=yy,z=zz}
				local dist=zz-myHero.z
				local enemyinTheta=false
				local Theta
				if xx>myHero.x then
				Theta=math.acos(dist/GetD(cursor))
				elseif xx<=myHero.x then
				Theta=-math.acos(dist/GetD(cursor))
				end
				
				local xxx,yyy,zzz=hitme.x,hitme.y,hitme.z
				local cursor2={x=xxx,y=yyy,z=zzz}
				local dist2=zzz-hero.z
				local Theta2
				if xxx>hero.x then
				Theta2=math.acos(dist2/GetD(cursor2))
				elseif xxx<=hero.x then
				Theta2=-math.acos(dist2/GetD(cursor2))
				end
				if Theta2<=Theta+(math.pi/7) and Theta2>=Theta-(math.pi/7) then
					enemyinTheta=true
				end
				
				if hittingyou==nil and enemyinTheta then
					hittingyou=hero
					trueTheta=Theta
				elseif hittingyou~=nil and GetD(hero)<GetD(hittingyou) and enemyinTheta then
					hittingyou=hero
					trueTheta=Theta
				end
			end
			
		end
	end		
	return hittingyou
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
function killsteal()

	if target~=nil and ViConfig.k==1 then
		local R=getDmg('R', target,myHero)*RRDY
		local QQ=enemyBlock(target)*CalcDamage(target,math.min(40+(60*GetSpellLevel('Q'))+1.4*myHero.addDamage,math.max((20+30*GetSpellLevel('Q')+0.7*myHero.addDamage),(20+30*GetSpellLevel('Q')+0.7*myHero.addDamage)+(20+30*GetSpellLevel('Q')+0.7*myHero.addDamage)*((GetD(tqfa)-450)*1/450))))*QRDY
		local AAE=CalcDamage(target,(15*GetSpellLevel('E')-10+1.15*myHero.addDamage+.7*myHero.ap)*ERDY+myHero.baseDamage+myHero.addDamage)
		local EE=CalcDamage(target,(15*GetSpellLevel('E')-10+1.15*myHero.addDamage+.7*myHero.ap)*ERDY)
		
		if GetD(target)<300 and target.health<AAE then
			Espell(target)
			attacked = false
		elseif GetD(target)<300 and target.health<AAE+ignitedamage then
			Espell(target)
			attacked = false
			if ignitedamage~=nil then
			CastSummonerIgnite(target)
			end
		elseif GetD(target)>300 and GetD(target)<600 and target.health<EE and EThru(target)~=nil then
			E(EThru(target))
		elseif GetD(target)>300 and GetD(target)<600 and target.health<EE+ignitedamage and EThru(target)~=nil then
			E(EThru(target))
			if ignitedamage~=nil then
			CastSummonerIgnite(target)
			end
		elseif GetD(target)>300 and GetD(target)<600 and target.health<EE+ignitedamage and EThru(target)~=nil then
			E(EThru(target))
			Q(target)
			if ignitedamage~=nil then
			CastSummonerIgnite(target)
			end
		elseif GetD(tqfa)>400 and GetD(tqfa)<900 and target.health<QQ+EE+ignitedamage then
			Q(tqfa)
		end
	elseif target~=nil and ViConfig.k==2 then
		local AAE=CalcDamage(target,(15*GetSpellLevel('E')-10+1.15*myHero.addDamage+.7*myHero.ap)*ERDY+myHero.baseDamage+myHero.addDamage)
		local E=CalcDamage(target,(15*GetSpellLevel('E')-10+1.15*myHero.addDamage+.7*myHero.ap)*ERDY)
		
		if GetD(target)<300 and target.health<AAE then
			Espell(target)
			attacked = false
		elseif GetD(target)<300 and target.health<AAE+ignitedamage then
			Espell(target)
			attacked = false
			if ignitedamage~=nil then
			CastSummonerIgnite(target)
			end
		elseif GetD(target)>300 and GetD(target)<600 and target.health<EE and EThru(target)~=nil then
			E(EThru(target))
		elseif GetD(target)>300 and GetD(target)<600 and target.health<EE+ignitedamage and EThru(target)~=nil then
			E(EThru(target))
			if ignitedamage~=nil then
			CastSummonerIgnite(target)
			end
		end
		
	elseif target~=nil and ViConfig.k==3 then
		if target600~=nil and target600.health<ignitedamage then
			CastSummonerIgnite(target600)
		end	
	end

end


function moveToCursor()
        if myHero.dead~=1 then
                local moveSqr = math.sqrt((mousePos.x - myHero.x)^2+(mousePos.z - myHero.z)^2)
                local moveX = myHero.x + 300*((mousePos.x - myHero.x)/moveSqr)
                local moveZ = myHero.z + 300*((mousePos.z - myHero.z)/moveSqr)
				MoveToXYZ(moveX,0,moveZ)
        end

end
function moveToObject(O)
        if myHero.dead~=1 then
                local moveSqr = math.sqrt((O.x - myHero.x)^2+(O.z - myHero.z)^2)
                local moveX = myHero.x + 300*((O.x - myHero.x)/moveSqr)
                local moveZ = myHero.z + 300*((O.z - myHero.z)/moveSqr)
				MoveToXYZ(moveX,0,moveZ)
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

function teamfight()
	if target~=nil then
		if GetD(tqfa)<900 and runningAway(target) and enemyBlock(target) then
			Q(tqfa)
		elseif Passive==true and QRDY==1 and myHero.health<0.25 and GetD(tqfa)<400 then
			Q(tqfa)
		elseif QRDY==1 and myHero.health<0.20 and GetD(tqfa)<500 then
			Q(tqfa)
		elseif timer>0 and QRDY==1 then
			Q(tqfa)
		end
	if GetD(target)<600 then
		if GetD(target)<300 then
			Espell(target)
			attacked = false
			CastSummonerExhaust(target)
			UseAllItems(target)
			AttackTarget(target)
		elseif GetD(target)<400 then
			Espell(target)
			attacked = false
			CastSummonerExhaust(target)
			UseAllItems(target)
			AttackTarget(target)
		
		elseif GetD(target)<600 then
			Espell(target)
			attacked = false
			CastSummonerExhaust(target)
			UseTargetItems(target)
			AttackTarget(target)
		end
	elseif targetclosest~=nil then
		if GetD(targetclosest)<300 then
			Espell(target)
			attacked = false
			UseAllItems(target)
			AttackTarget(target)
			if QRDY==1 and myHero.health<0.20 and GetD(tqfaq)<500 then
				Q(tqfaq)
			end
		elseif GetD(targetclosest)<400 then
			UseAllItems(target)
			AttackTarget(target)
			if QRDY==1 and myHero.health<0.20 and GetD(tqfaq)<500 then
				Q(tqfaq)
			end
		elseif GetD(targetclosest)<600 then
			UseTargetItems(target)
			AttackTarget(target)
			if QRDY==1 and myHero.health<0.20 and GetD(tqfaq)<500 then
				Q(tqfaq)
			elseif timer>0 and QRDY==1 then
				Q(tqfaq)
			end
		end
	end
		
		
		
	else
		moveToCursor()
	end
end

function harass()
	if target~=nil then
		if GetD(tqfa)<900 then
			Q(tqfa)
		end
	if GetD(target)<600 then
		if GetD(target)<300 then
			Espell(target)
			attacked = false
			UseAllItems(target)
			AttackTarget(target)
		elseif GetD(target)<400 then
			Espell(target)
			attacked = false
			UseAllItems(target)
			AttackTarget(target)
		
		elseif GetD(target)<600 then
			Espell(target)
			attacked = false
			UseTargetItems(target)
			AttackTarget(target)
		end

	end
		
	else
		moveToCursor()
	end

end

function punch()
	if target~=nil and EThru(target)~=nil then
		if GetD(EThru(target))<300 then
			E(EThru(target))
		else
			moveToObject(EThru(target))
		end
	else
		moveToCursor()
	end
end

function Q(enemy)
		tx=mousePos.x
		ty=mousePos.y
		tz=mousePos.z
		if enemy~=nil and QRDY==1 then
			
			if GetD(enemy)<900 and timer==0 then
			--print("\nH5")
				send.key_press(0x74)
			--print("\nH5")
			elseif GetD(enemy)<900 and GetD(enemy)<=math.min(900,450+ ((GetClock() - timer)  * 0.36)) then
			
			--print("\nH6")
				ClickSpellXYZ('Q',enemy.x,enemy.y,enemy.z,0)
				send.key_press(0x74)
			end
		
		elseif enemy==nil and QRDY==1 then
			if timer==0 then
			--print("\nH5")
				send.key_press(0x74)
			elseif timer+1250  <=GetClock() then
			
			--print("\nH7")
				ClickSpellXYZ('M',GetCursorWorldX(),GetCursorWorldY(),GetCursorWorldZ(),0)
				send.key_press(0x74)
			end
		end
		
	 send.tick() 
	end

function Espell(target)
	AttackTarget(target)
    if attacked == true and GetD(myHero, target) < 225 then    
        CastSpellTarget("E", target)
    end
end

function E(target)
	if ERDY==1 then
		CastSpellTarget('E',myHero)
		
	end
	attacked=false
		AttackTarget(target)
end

function R(enemy)
	if RRDY==1 then
		CastSpellTarget('R',enemy)
	end
end

function ultI()
	if herotargetfarthest~=nil then
		R(herotargetfarthest)
	end
end

function ultF()
	if target~=nil then
		R(target)
	end
end

function TimerSet()
	if (GetClock() - timer) < 5000 then
		Range = math.min(900,450+ ((GetClock() - timer)  * 0.36))
	elseif (GetClock() - timer) > 5000 then
		timer = 0
		Range = 450
	end
end

function OnDraw()
	if myHero.dead~=1 then
		CustomCircle(900,3,2,myHero)
	if target~=nil and RRDY==1 then
		local R=getDmg('R', target,myHero)
		if target.health<R then
			DrawSphere(40,25,2,target.x,target.y+300,target.z)
		end
	end
	if QRDY==1 then
		if Range < 850 then
			CustomCircle(Range,6,3,myHero)
		elseif Range >= 850 then
			CustomCircle(Range,10,2,myHero)
		end
	end
	
	if RRDY==1 and ViConfig.drawR then
		local enemyToDrawTo=nil
		local tx=0
		local tz=0
		-----Option draw to Target
		if target~=nil then
			for j=1, objManager:GetMaxHeroes(), 1 do
				herotarget = objManager:GetHero(j)	
				if herotarget~=nil and herotarget.team~=myHero.team and (herotargetfarthest==nil or herotargetfarthest.dead==1 or herotargetfarthest.visible==0 or herotargetfarthest.invulnerable==1) and herotarget.visible==1 --[[and herotarget.invulnerable==0--]] and herotarget.dead~=1 and GetD(herotarget)<1100 then
					herotargetfarthest=herotarget
				elseif herotarget~=nil and herotarget.team~=myHero.team and herotargetfarthest~=nil and herotarget.visible==1 --[[and herotarget.invulnerable==0--]] and GetD(herotarget)<1100 and herotarget.dead~=1 and GetD(herotarget)>GetD(herotargetfarthest) then
					herotargetfarthest=herotarget
				end
			end	
			if herotargetfarthest~=nil then
			local xx2,yy2,zz2=herotargetfarthest.x,herotargetfarthest.y,herotargetfarthest.z
			local cursor2={x=xx2,y=yy2,z=zz2}
			local d2=zz2-myHero.z
			local Theta2
			if xx2>myHero.x then
				Theta2=math.acos(d2/GetD(cursor2))
			elseif xx2<=myHero.x then
				Theta2=-math.acos(d2/GetD(cursor2))
			end
			local dist=GetD(herotargetfarthest)
						DrawLineObject(myHero,GetD(herotargetfarthest),0xFF00FF00,Theta2,1)
						CustomCircle(150,10,4,herotargetfarthest)
			for i=1, objManager:GetMaxHeroes(), 1 do
				hero = objManager:GetHero(i)	
				if hero~=nil and hero.team~=myHero.team and hero.name~=herotargetfarthest.name and hero.visible==1 and hero.invulnerable==0 and GetD(hero)<dist then
					local xx,yy,zz=hero.x,hero.y,hero.z
					local cursor={x=xx,y=yy,z=zz}
					local d1=zz-myHero.z
					local Theta
					local lineL
					if xx>myHero.x then
						Theta=math.acos(d1/GetD(cursor))
					elseif xx<=myHero.x then
						Theta=-math.acos(d1/GetD(cursor))
					end
					if Theta2>=Theta then
						lineL=math.sin(Theta2-Theta)*GetD(hero)
					elseif Theta2<Theta then
						lineL=math.sin(Theta-Theta2)*GetD(hero)
					end
					
					local length=math.sqrt(GetD(hero)*GetD(hero)-lineL*lineL)
					if herotargetfarthest.x==myHero.x then
						tx = myHero.x
						if herotargetfarthest.z>myHero.z then
								tz = myHero.z+length
						else
								tz = myHero.z-length
						end
                                               
					elseif herotargetfarthest.z==myHero.z then
							tz = herotargetfarthest.z
							if herotargetfarthest.x>myHero.x then
									tx = myHero.x+length
							else
									tx = myHero.x-length
							end
				   
					elseif herotargetfarthest.x>myHero.x then
							angle = math.asin((herotargetfarthest.x-myHero.x)/dist)
							zs = length*math.cos(angle)
							xs = length*math.sin(angle)
							if herotargetfarthest.z>myHero.z then
									tx = myHero.x+xs
									tz = myHero.z+zs
							elseif herotargetfarthest.z<myHero.z then
									tx = myHero.x+xs
									tz = myHero.z-zs
							end
				   
					elseif herotargetfarthest.x<myHero.x then
						angle = math.asin((myHero.x-herotargetfarthest.x)/dist)
						zs = length*math.cos(angle)
						xs = length*math.sin(angle)
						if herotargetfarthest.z>myHero.z then
								tx = myHero.x-xs
								tz = myHero.z+zs
						elseif herotargetfarthest.z<myHero.z then
								tx = myHero.x-xs
								tz = myHero.z-zs
						end
					end
					if Theta2>=Theta then
						DrawLine(tx,herotargetfarthest.y,tz,lineL,0xFF00FF00,Theta2+math.pi/2,1)
						--print('Drawn '..tx.. " "..tz)
					elseif Theta2<Theta then
						DrawLine(tx,herotargetfarthest.y,tz,lineL,0xFF00FF00,Theta2-math.pi/2,1)
						--print('Drawn2 '..tx.. " "..tz)
					end
					if lineL<150 then
						CustomCircle(100,10,2,hero)
					else
						CustomCircle(100,10,1,hero)
					end
				end
			end
			end
		end
	end
	
	if IsChatOpen()==0 and ViConfig.ult and ViConfig.drawR and not ViConfig.teamfight then ultI() 
	elseif IsChatOpen()==0 and ViConfig.ult then ultF() end
	end
end

function enemyBlock(targetenemy)
	if targetenemy~=nil then
	DT=GetD(targetenemy)
		local xx2,yy2,zz2=targetenemy.x,targetenemy.y,targetenemy.z
		local cursor2={x=xx2,y=yy2,z=zz2}
		local d2=zz2-myHero.z
		local Theta2
		if xx2>myHero.x then
			Theta2=math.acos(d2/GetD(cursor2))
		elseif xx2<=myHero.x then
			Theta2=-math.acos(d2/GetD(cursor2))
		end
		for i=1, objManager:GetMaxHeroes(), 1 do
			hero = objManager:GetHero(i)
			if hero~=nil and hero.team~=myHero.team and hero.name~=targetenemy.name and hero.visible==1 and hero.invulnerable==0 and GetD(hero)<DT then
				local xx,yy,zz=hero.x,hero.y,hero.z
				local cursor={x=xx,y=yy,z=zz}
				local d1=zz-myHero.z
				local Theta
				local lineL
				if xx>myHero.x then
					Theta=math.acos(d1/GetD(cursor))
				elseif xx<=myHero.x then
					Theta=-math.acos(d1/GetD(cursor))
				end
				if Theta2>=Theta then
					lineL=math.sin(Theta2-Theta)*GetD(hero)
				elseif Theta2<Theta then
					lineL=math.sin(Theta-Theta2)*GetD(hero)
				end
				if lineL<175 then
					return 0
				end
			end
		end
	end
	return 1
			
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

function RedElixir()
	if bluePill == nil then
		if myHero.health < 45/100*myHero.maxHealth and GetClock() > wUsedAt + 15000 then
			usePotion()
			wUsedAt = os.clock()
		elseif myHero.health < 5/10*myHero.maxHealth and GetClock() > vUsedAt + 10000 then 
			useFlask()
			vUsedAt = os.clock()
		elseif myHero.health < 35/100*myHero.maxHealth then
			useElixir()
		end
	end
	if (os.clock() < timerP + 5000) then
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

SetTimerCallback("ViRun")