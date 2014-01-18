require 'Utils'
require 'winapi'
require 'SKeys'
require 'spell_damage'
require 'vals_lib'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local Q,W,E,R = 'Q','W','E','R'
local version = '1.3.1'
local target, targetaa
local attacked
local Range, timer = 0,0
local Minions = { }
local SORT_CUSTOM = function(a, b) return a.maxHealth and b.maxHealth and a.maxHealth < b.maxHealth end

function ViRun()
	if IsLolActive() and IsChatOpen() == 0 then
	AArange = myHero.range+(GetDistance(GetMinBBox(myHero)))
	target = GetWeakEnemy('PHYS',900)
	targetaa = GetWeakEnemy('PHYS',AArange)
	Minions = GetEnemyMinions(SORT_CUSTOM)
	--if ViSettings.ExtendedE then ExtendedE() end
	
	if myHero.SpellTimeQ > 0 and GetSpellLevel('Q') > 0 then 
		QRDY = 1
		else QRDY = 0 
	end
	if myHero.SpellTimeW > 0 and GetSpellLevel('W') > 0 then 
		WRDY = 1
		else WRDY = 0 
	end
	if myHero.SpellTimeE > 0 and GetSpellLevel('E') > 0 then 
		ERDY = 1
		else ERDY = 0 
	end
	if myHero.SpellTimeR > 0 and GetSpellLevel('R') > 0 then 
		RRDY = 1
	else RRDY = 0 end
	
	if ViSettings.drawQ then
		if myHero.dead == 1 then
			timer = 0
		end
		if  timer == 0 then
			Range = 0
		end

		if (GetTickCount() - timer) < 1250 and (GetTickCount() - timer) ~= 0 then
			Range = 250 + (((GetTickCount() - timer) / 5) * 2)
		elseif (GetTickCount() - timer) > 1250 and (GetTickCount() - timer) < 5000 then
			Range = 725
		elseif (GetTickCount() - timer) > 5000 then
			timer = 0
		end

		MousePos = Vector(GetCursorWorldX(), GetCursorWorldY(), GetCursorWorldZ())
		HeroPos = Vector(myHero.x, myHero.y, myHero.z)
		QPos = HeroPos+(HeroPos-MousePos)*(-Range/GetDistance(HeroPos, MousePos))
		
		for i = 1, objManager:GetMaxHeroes() do
			local enemy = objManager:GetHero(i)
			if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.dead == 0) then
		
				if GetDistance(myHero,enemy)<=Range then
					ex = myHero.x
					ez = myHero.z
					tx = QPos.x
					tz = QPos.z
					dx = ex-tx
					dz = ez-tz
					if dx ~= 0 then
					m = dz/dx
					c = ez-m*ex
					end
					mx = enemy.x
					mz = enemy.z
					distanc = (math.abs(mz - m*mx - c))/(math.sqrt(m*m+1))
					if IsKeyDown(87)==1 and ((distanc<125 and math.sqrt((tx-ex)*(tx-ex)+(tz-ez)*(tz-ez))>math.sqrt((tx-mx)*(tx-mx)+(tz-mz)*(tz-mz))) or GetDistance(QPos,enemy)<=75) then
						CustomCircleXYZ(125,10,1,mx,enemy.y,mz)
					elseif IsKeyDown(87)==0 and (distanc<75 and math.sqrt((tx-ex)*(tx-ex)+(tz-ez)*(tz-ez))>math.sqrt((tx-mx)*(tx-mx)+(tz-mz)*(tz-mz))) then
						CustomCircleXYZ(125,10,1,mx,enemy.y,mz)
						XX,YY,ZZ = GetFireahead(enemy, 0, 16)
						ClickSpellXYZ('Q',XX,YY,ZZ,0)
					end
				end
			end
		end
	end
end
end

	ViSettings, menu = uiconfig.add_menu('Vi Settings', 200)
	menu.checkbutton('drawQ', 'Draw Q', true)
	menu.checkbutton('aareset', 'Autoattack Reset', true)
	menu.checkbutton('useItems', 'Use Items after AA', true)
	--menu.checkbutton('ExtendedE', 'ExtendedE', false)
	
function ExtendedE()
	for i, Minion in pairs(Minions) do	
		if Minion~=nil and target ~= nil and GetDistance(myHero,target) < 550 and GetDistance(myHero,Minion) < AA and ERDY == 1 then
			ex = myHero.x
			ez = myHero.z
			tx = target.x
			tz = target.z
			dx = ex - tx
			dz = ez - tz
			if dx ~= 0 then
			m = dz/dx
			c = ez - m*ex
			end
			mx = Minion.x
			mz = Minion.z
			distanc = (math.abs(mz - m*mx - c))/(math.sqrt(m*m+1))
			if distanc < 50 and math.sqrt((tx - ex)*(tx - ex) + (tz - ez)*(tz - ez)) > math.sqrt((tx - mx)*(tx - mx) + (tz - mz)*(tz - mz)) then
				CastSpellTarget('E',Minion)
				AttackTarget(Minion)
			end
		end
	end
end
	
function OnCreateObj(obj)
	if obj ~= nil then
		if string.find(obj.charName,'Vi_Q_Channel_L') ~= nil and GetDistance(obj, myHero) < 100 then
			timer = GetTickCount()
		end
		if (string.find(obj.charName,'Vi_q_mis') ~= nil or string.find(obj.charName,'Vi_Q_Expire') ~= nil) and GetDistance(obj, myHero) < 100 then
			timer = 0
		end
		if string.find(obj.charName,"Vi_ArmorShred") ~= nil and GetDistance(myHero,obj)<AArange+50 and ViSettings.aareset and targetaa~=nil then
			if ViSettings.useItems then UseAllItems(targetaa) end
			CastSpellTarget("E",targetaa)
			AttackTarget(targetaa)
		end
		if string.find(obj.charName,"Vi_BasicAttack") ~= nil or string.find(obj.charName,"Vi_Crit") ~= nil and GetDistance(obj)<100 and ViSettings.aareset and targetaa~=nil then
			if ViSettings.useItems then UseAllItems(targetaa) end
			if targetaa~=nil then CastSpellTarget("E",targetaa) end
			if targetaa~=nil then AttackTarget(targetaa) end
		end
		if string.find(obj.charName,"Vi_R_Dash") ~= nil and targetaa~=nil then
			AttackTarget(targetaa)
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

SetTimerCallback("ViRun")