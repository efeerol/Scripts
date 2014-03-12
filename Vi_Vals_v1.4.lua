require 'Utils'
require 'winapi'
require 'SKeys'
require 'vals_lib'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local Q,W,E,R = 'Q','W','E','R'
local version = '1.4'
local Range, timer = 0,0

	ViSettings, menu = uiconfig.add_menu('Vi Settings', 200)
	menu.checkbutton('useQ', 'UseQ', true)
	menu.checkbutton('aareset', 'Autoattack Reset', true)
	menu.checkbutton('useItems', 'Use Items after AA', true)

function Main()
	if IsLolActive() and myHero.dead==0 then
		target = GetWeakEnemy('PHYS',900)
		targetaa = GetWeakEnemy('PHYS',AArange+100)

		if ViSettings.useQ then
			if myHero.dead==1 then timer=0 end
			if  timer==0 then Range=0 end

			if (GetTickCount()-timer)<1250 and (GetTickCount()-timer)~=0 then Range=250+(((GetTickCount()-timer)/5)*2)
			elseif (GetTickCount()-timer)>1250 and (GetTickCount()-timer)<5000 then Range=725
			elseif (GetTickCount()-timer)>5000 then timer=0 end

			MousePos = Vector(GetCursorWorldX(), GetCursorWorldY(), GetCursorWorldZ())
			HeroPos = Vector(myHero.x, myHero.y, myHero.z)
			QPos = HeroPos+(HeroPos-MousePos)*(-Range/GetDistance(HeroPos, MousePos))
			
			for i = 1, objManager:GetMaxHeroes() do
				local enemy = objManager:GetHero(i)
				if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.dead == 0) then
					if GetDistance(myHero,enemy)<=Range then
						if KeyDown(87) and (IsBetween(myHero,enemy,QPos,125) or GetDistance(QPos,enemy)<=75) then 
							CustomCircleXYZ(125,10,1,mx,enemy.y,mz)
						elseif not KeyDown(87) and IsBetween(myHero,enemy,QPos,75) then 
							CustomCircleXYZ(125,10,1,mx,enemy.y,mz)
							XX,YY,ZZ = GetFireahead(enemy,0,16)
							ClickSpellXYZ('Q',XX,YY,ZZ,0)
						end
					end
				end
			end
		end
	end
end
	
function OnCreateObj(obj)
	if obj ~= nil then
		if string.find(obj.charName,'Vi_Q_Channel_L') ~= nil and GetDistance(obj, myHero) < 100 then timer = GetTickCount() end
		if (string.find(obj.charName,'Vi_q_mis') ~= nil or string.find(obj.charName,'Vi_Q_Expire') ~= nil) and GetDistance(obj, myHero) < 100 then timer = 0 end
		if targetaa~=nil then
			if string.find(obj.charName,"Vi_ArmorShred") ~= nil and GetDistance(myHero,obj)<AArange+50 and ViSettings.aareset then
				if ViSettings.useItems then UseAllItems(targetaa) end
				CastSpellTarget("E",targetaa)
				AttackTarget(targetaa)
			end
			if string.find(obj.charName,"Vi_BasicAttack") ~= nil or string.find(obj.charName,"Vi_Crit") ~= nil and GetDistance(obj)<100 and ViSettings.aareset then
				if ViSettings.useItems then UseAllItems(targetaa) end
				CastSpellTarget("E",targetaa)
				AttackTarget(targetaa)
			end
			if string.find(obj.charName,"Vi_R_Dash") ~= nil then AttackTarget(targetaa) end
		end
	end
end

function Delobj()
	for i = 1, objManager:GetMaxDelObjects(), 1 do
		local object = {objManager:GetDelObject(i)}
		local ret={}
		ret.index=object[1]
		ret.name=object[2]
		ret.charName=object[3]
		ret.x=object[4]
		ret.y=object[5]
		ret.z=object[6]
		if string.find(ret.name,"Vi_q_mis") and targetaa~=nil then
			AttackTarget(targetaa)
		end
	end
end

SetTimerCallback("Main")