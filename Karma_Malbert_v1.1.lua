require "Utils"
require 'spell_damage'
print=printtext
printtext("\nKarma\n")
printtext("\nBy Malbert\n")
printtext("\nVersion 1.1\n")

local targetQ=nil
local targetItems=nil
local ignitedamage=0
local QRDY=0
local WRDY=0
local ERDY=0
local RRDY=0

local dd=0.9
local ps=15.3

KarmaConfig = scriptConfig("Karma", "Karma Config")
KarmaConfig:addParam("q", " RQ Mouse", SCRIPT_PARAM_ONKEYDOWN, false, 65)
KarmaConfig:addParam("e", " E Self", SCRIPT_PARAM_ONKEYDOWN, false, 89)
KarmaConfig:addParam("tf", "Teamfight", SCRIPT_PARAM_ONKEYDOWN, false, 84)
	
function Run()

	
	targetQ = GetWeakEnemy("MAGIC", 950)
	targetItems = GetWeakEnemy("MAGIC", 600)
		
		
	if myHero.SpellTimeQ > 1.0 and GetSpellLevel('Q') > 0 then
			QRDY = 1
			else QRDY = 0
	end
	if myHero.SpellTimeW > 1.0 and GetSpellLevel('W') > 0 then
			WRDY = 1
			else WRDY = 0
	end
	if myHero.SpellTimeE > 1.0 and GetSpellLevel('E') > 0 and EStacks==6 then
			ERDY = 1
			else ERDY = 0
	end
	if myHero.SpellTimeR > 1.0 and GetSpellLevel('R') > 0 then
			RRDY = 1
			else RRDY = 0 
	end
	
		

	
	--[[for i=1, objManager:GetMaxHeroes(), 1 do
		local hero = objManager:GetHero(i)
		if hero~=nil and hero.team~=myHero.team and hero.name~=nil then
			if enemies[hero.name]==nil then
				enemies[hero.name]={unit=hero,number=enemyIndex}
				enemyIndex=enemyIndex+1
			end
		end
	end--]]
	
	if IsChatOpen() == 0 and KarmaConfig.q then RQ() end
	if IsChatOpen() == 0 and KarmaConfig.e then E(myHero) end
	if IsChatOpen() == 0 and KarmaConfig.tf then TF() end

	
end

function TF()
	if targetQ~=nil then
		if targetItems~=nil and targetItems.name==targetQ.name then
			UseAllItems(targetItems)
		end
		if RRDY==1 then
			if (myHero.health/myHero.maxHealth)<0.3 and WRDY==1 then
				CastSpellTarget('R',myHero)
			elseif QRDY==1 then
				CastSpellTarget('R',myHero)
			end
		else
			if myHero.health/myHero.maxHealth<0.3 and WRDY==1 then
				CastSpellTarget('W',targetQ)
			elseif QRDY==1 then
				CastSpellXYZ('Q',GetFireahead(targetQ,dd,ps))
			elseif WRDY==1 and QRDY==0 then
				CastSpellTarget('W',targetQ)
			end
			
		end
		AttackTarget(targetQ)
	else
		MoveToMouse()
	end
end

function RQ()
	if RRDY==1 and QRDY==1 then
		CastSpellTarget('R',myHero)
		CastSpellXYZ('Q',mousePos.x,0,mousePos.z)
	elseif RRDY==0 and QRDY==1 then
		CastSpellXYZ('Q',mousePos.x,0,mousePos.z)
	end
end

function E(ally)
	if ally~=nil and ally.dead==0 and GetD(ally)<800 then
		CastSpellTarget('E',ally)
	end
	MoveToMouse()
end

function runningAway(slowtarget)
   local d1 = GetD(slowtarget)
   local x, y, z = GetFireahead(slowtarget,2,0)
   local d2 = GetD({x=x, y=y, z=z})
   local d3 = GetD({x=x, y=y, z=z},slowtarget)
   local angle = math.acos((d2*d2-d3*d3-d1*d1)/(-2*d3*d1))
   
   return angle%(2*math.pi)>math.pi/2 and angle%(2*math.pi)<math.pi*3/2
 
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
		if QRDY==1 then
			CustomCircle(950,5,5,myHero)
		end
		if WRDY==1 then
			CustomCircle(650,5,2,myHero)			
		end
		if ERDY==1 then
			CustomCircle(800,5,3,myHero)			
		end
		
end	
	

SetTimerCallback("Run")