require 'Utils'

local version = '2.2'
local target
local targetauto
local targetignite
local RangeAttack = false
local hero_table = {}
local hero_table_timer = {}

function Urgot2Run()
	target = GetWeakEnemy('PHYS',1000)
	targetignite = GetWeakEnemy('TRUE',600)
	
	if myHero.SpellTimeQ > 1.0 then
	QRDY = 1
	else QRDY = 0
	end
	if myHero.SpellTimeW > 1.0 then
	WRDY = 1
	else WRDY = 0
	end
	if myHero.SpellTimeE > 1.0 then
	ERDY = 1
	else ERDY = 0
	end
	if myHero.SpellTimeR > 1.0 then
	RRDY = 1
	else RRDY = 0
	end
	
	Artillery()
	
	if UrgotConfig.useQ then useQ() end
	if UrgotConfig.combo then combo() end
	if UrgotConfig.ignite then ignite() end
	
	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) then
			return enemy
		end
	end

end

	UrgotConfig = scriptConfig("Urgot Config", "urgot2config")
	UrgotConfig:addParam("combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 88)
	UrgotConfig:addParam("useQ", "Use Q", SCRIPT_PARAM_ONKEYDOWN, false, 89)
	UrgotConfig:addParam("useW", "AutoW", SCRIPT_PARAM_ONKEYTOGGLE, true, 112) -- F1
	UrgotConfig:addParam("AutoQafterAA", "Auto Q after AA", SCRIPT_PARAM_ONKEYTOGGLE, true, 113) -- F2
	UrgotConfig:addParam("useItems", "Use Items", SCRIPT_PARAM_ONKEYTOGGLE, true, 114) -- F3
 	UrgotConfig:addParam("ignite", "Auto Ignite", SCRIPT_PARAM_ONKEYTOGGLE, true, 115) -- F4
	UrgotConfig:addParam("EProjSpeed", "E Projectile Speed", SCRIPT_PARAM_NUMERICUPDOWN, 12, 116, 0, 20, 1) -- F5
	UrgotConfig:permaShow("useQ")
	UrgotConfig:permaShow("useW")
	UrgotConfig:permaShow("AutoQafterAA")
	UrgotConfig:permaShow("useItems")
	UrgotConfig:permaShow("ignite")
	UrgotConfig:permaShow("EProjSpeed")
	
function OnProcessSpell(unit,spell)
	if unit ~= nil and spell ~= nil and unit.charName == myHero.charName then
		if (spell.name == "UrgotBasicAttack" or spell.name == "UrgotBasicAttack2" or spell.name == "UrgotCritAttack") and target ~= nil and spell.target and UrgotConfig.AutoQafterAA and QRDY == 1 then
			RangeAttack = true
		end
end

function OnCreateObj(obj)
	if obj ~= nil and target ~= nil and UrgotConfig.AutoQafterAA then
		if string.find(obj.charName, "UrgotBasicAttack_mis") ~= nil and GetDistance(myHero, obj) < 200 and RangeAttack == true and CreepBlock(myHero.x,myHero.y,myHero.z,GetFireahead(target,1.6,15)) == 0 then
				CastSpellXYZ('Q',GetFireahead(target,1.6,15))
				RangeAttack = false
			end
		end
	end
end

function combo()
	if target ~= nil then
		if UrgotConfig.useItems then 
			UseAllItems(target)
		end
		if GetDistance(myHero, target) < 900 and UrgotConfig.EProjSpeed ~= 0 and ERDY == 1 then
			CastSpellXYZ('E',GetFireahead(target,1.6,UrgotConfig.EProjSpeed))
		end
		if GetDistance(myHero, target) < 900 and QRDY == 1 then
			CastSpellXYZ('Q',GetFireahead(target,1.6,15))
		end
	end
	if target == nil then
		MoveToMouse()
	else
		AttackTarget(target)
	end
end

function useQ()
	if target ~= nil and GetDistance(myHero, target) < 1000 and CreepBlock(myHero.x,myHero.y,myHero.z,GetFireahead(target,1.6,15)) == 0 then
		CastSpellXYZ('Q',GetFireahead(target,1.6,15))
	end
end

function ignite()
	local damage = (myHero.selflevel*20)+50
	if targetignite ~= nil then
		if myHero.SummonerD == 'SummonerDot' then
			if targetignite.health < damage then
				CastSpellTarget('D',targetignite)
			end
		end
		if myHero.SummonerF == 'SummonerDot' then
			if targetignite.health < damage then
				CastSpellTarget('F',targetignite)
			end
		end
	end
end

function OnDraw()
	if QRDY == 1 then
		CustomCircle(900,6,3,myHero)
	end
	if QRDY == 0 then
		CustomCircle(425,6,3,myHero)
	end
	if target ~= nil then
		CustomCircle(100,4,2,target)
	end	
end

function Artillery()
	for i = 1,objManager:GetMaxNewObjects(), 1 do
		local object = objManager:GetNewObject(i)
		if object.charName ~= nil then
			if string.find(object.charName,"UrgotCorrosiveDebuff_buf") ~= nil then
				for j = 1, objManager:GetMaxHeroes(), 1 do
					local h=objManager:GetHero(j)
					if (GetDistance(h,object)<10) then
						local name=h.charName
						hero_table[name] = string.find(object.charName,"UrgotCorrosiveDebuff_buf")
						hero_table_timer[name] = os.clock()
					end
				end
			end
		end
	end
	for i= 1,objManager:GetMaxHeroes(),1 do
		local h=objManager:GetHero(i)
		if (h.team ~= myHero.team and h.visible==1 and h.invulnerable==0) then
			local name=h.charName
			local stacks=hero_table[name]
			if (stacks==nil or os.clock()-hero_table_timer[name]>5) then
				stacks=0
			end
			if stacks==1 then
				CustomCircle(1200,6,2,myHero)
				for j=1, 10 do
					local ycircle = (j*(60/10*2)-60)
					local r = math.sqrt(60^2-ycircle^2)
					ycircle = ycircle/1.3
					DrawCircle(h.x, h.y+250+ycircle, h.z, r, 2)
				end
				if (GetDistance(myHero,h)<1200) then
					if UrgotConfig.useW then CastSpellXYZ('W',myHero.x,myHero.y,myHero.z) end
					CastSpellXYZ('Q',h.x,h.y,h.z)
					break
				end
			end
		end
	end
end

SetTimerCallback('Urgot2Run')
print("\nVal's Urgot v"..version.."\n")