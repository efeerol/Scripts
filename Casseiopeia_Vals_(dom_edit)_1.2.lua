require 'Utils'
require 'winapi'
require 'vals_lib'
local Q,W,E,R = 'Q','W','E','R'
local Counter = {}
local count = 10

function Main()
	GetCD()
	Qdelay = 5
	Qspeed = 0
	Range = 850
	target = GetWeakEnemy('MAGIC',850)
	if target~=nil then
		QX,QY,QZ = GetFireahead(target,6,0)
		WX,WY,WZ = GetFireahead(target,1.5,20)
		if distXYZ(myHero.x,myHero.z,target.x,target.z)<Range and distXYZ(myHero.x,myHero.z,QX,QZ)<Range and distXYZ(target.x,target.z,QX,QZ)<((target.movespeed/1000)*(((Qdelay*100)+100)+(Qspeed*10)))/0.75 then table.insert(Counter, target)
		end
		if distXYZ(myHero.x,myHero.z,target.x,target.z)>Range or distXYZ(myHero.x,myHero.z,QX,QZ)>Range or distXYZ(target.x,target.z,QX,QZ)>((target.movespeed/1000)*(((Qdelay*100)+100)+(Qspeed*10)))/0.75 then
			for i,v in pairs(Counter) do Counter[i] = nil end
		end
		if target==nil then
			for i,v in pairs(Counter) do Counter[i] = nil end
		end
		if #Counter~=0 and #Counter>count then SpellPred(Q,QRDY,myHero,target,800,3.25,0) end
		if myHero.SpellTimeQ < 1 and myHero.SpellTimeQ > (1.5+(3*myHero.cdr))*-1 and not DetectPoison() then SpellPred(W,WRDY,myHero,target,800,1.6,20) end
		if DetectPoison() then SpellTarget(E,ERDY,myHero,target,700) end
	end
end

function DetectPoison()
    for i = 1, objManager:GetMaxObjects(), 1 do
        obj = objManager:GetObject(i)
        if obj~=nil and target~=nil and (obj.charName:lower():find("global_poison")) and GetDistance(obj, target) < 100 then
			return true
        end
    end
end

function OnDraw()
	if myHero.dead==0 then
		if QRDY == 1 then 
			CustomCircle(800,1,2,myHero)
		else 
			CustomCircle(800,1,3,myHero)
		end
		if target ~=nil then 
			CustomCircle(75,3,2,target)
		end
	end
end

SetTimerCallback('Main')