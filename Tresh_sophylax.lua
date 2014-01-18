require "Utils"
require 'spell_damage'
print=printtext

local thresh = myHero
local soul_count = 0
local last_attack = 0
local target
local targetaa
local lastQ = 0
local comboQ =0

function OnTick()
	target = GetWeakEnemy('PHYS',1100)
	Draw()
	DrawEnemy()
	FindHit()
	
	if IsChatOpen()==0 then
		if ThreshConfig.combo then combo() end
		if ThreshConfig.castq then CastQHook (target) end
		if ThreshConfig.eforw then CastEForward (target) end
		if ThreshConfig.eback then CastEBackward (target) end
	end
	if ThreshConfig.killsteal then KillSteal () end
	if ThreshConfig.farm then LastHit () end
end

	ThreshConfig = scriptConfig("Thresh Config", "Threconf")
	ThreshConfig:addParam("combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	ThreshConfig:addParam("castq", "Q Skillshot", SCRIPT_PARAM_ONKEYDOWN, false, 65)
	ThreshConfig:addParam("eforw", "Forwards E", SCRIPT_PARAM_ONKEYDOWN, false, 88)
	ThreshConfig:addParam("eback", "Backwards E", SCRIPT_PARAM_ONKEYDOWN, false, 67)
	ThreshConfig:addParam("farm", "Auto-Farm", SCRIPT_PARAM_ONKEYDOWN, false, 90)
	ThreshConfig:addParam("stundur", "Combo: Hook Duration", SCRIPT_PARAM_NUMERICUPDOWN, 1.35, 112, 0.75, 1.45, 0.1)
	ThreshConfig:addParam("edirection", "Combo: E Direction", SCRIPT_PARAM_DOMAINUPDOWN, 1, 113, {"Forward","Backward"})
	ThreshConfig:addParam("ultipre", "Combo: Ulti Prediction", SCRIPT_PARAM_ONKEYTOGGLE, false, 114)
	ThreshConfig:addParam("shield", "Auto-Shield", SCRIPT_PARAM_ONKEYTOGGLE, true, 115)
	ThreshConfig:addParam("killsteal", "Killsteal", SCRIPT_PARAM_ONKEYTOGGLE, false, 116)
	ThreshConfig:permaShow("combo")
	ThreshConfig:permaShow("castq")
	ThreshConfig:permaShow("eforw")
	ThreshConfig:permaShow("eback")
	ThreshConfig:permaShow("edirection")
	ThreshConfig:permaShow("shield")

function OnProcessSpell(unit, spell)
	if unit ~= nil and spell ~= nil and spell.target ~= nil then
		if (string.find(spell.name,"threshbasicattack")) ~= nil and unit.team == myHero.team then
			if spell.target.name ~= nil and (string.find(spell.target.name,"Turret")) == nil and (string.find(spell.target.name,"Ward")) == nil then
				last_attack = os.clock()
				targetaa = spell.target
			end
		end
			
		for i=1, objManager:GetMaxHeroes(), 1 do
			hero = objManager:GetHero(i)
			if hero ~= nil then
				if hero.team == myHero.team then
					if spell.target ~= nil and spell.target == hero then
						ShieldAlly(unit, spell, spell.target)
					end
				end
			end
		end
		if spell.name == "ThreshQ" and unit.team == myHero.team then
			lastQ = os.clock()
		end
	end
end

function EPassiveDamage(obj)
	if obj ~= nil then
		if GetSpellLevel("E") > 0 then
			return CalcMagicDamage(obj,(((GetSpellLevel("E")*.3)+.5)*(myHero.baseDamage + myHero.addDamage)*(math.min(os.clock() - last_attack,8)))/8 + soul_count)
		else
			return 0
		end
	end
end

function ShieldAlly(caster, spell, ally)
	if caster ~= nil and spell ~= nil and spell.name ~= nil then
		local slot
		if caster.SpellNameQ == spell.name then slot = "Q"
		elseif caster.SpellNameW == spell.name then slot = "W"
		elseif caster.SpellNameE == spell.name then slot = "E"
		elseif caster.SpellNameR == spell.name then slot = "R"
		elseif string.find(spell.name,"ttack") then slot = "AD"
		end
		if slot ~= nil and ally ~= nil then
			if getDmg(slot,ally,caster) >= ally.health then
				if getDmg(slot,ally,caster) < ally.health + (((myHero.ap * 0.4) + 20 + (GetSpellLevel('W') * 40))*CanUseSpell("W")) then
					if ThreshConfig.shield then 
						CastW (ally)
					end
				end
			end
		end
	end
end

function CastQHook (obj)
	if obj ~= nil and (lastQ + 2) < os.clock() then
	local qx, qy, qz = GetFireahead(obj,2,18)
		if CanCastSpell("Q") and GetDistance(obj) < 1075 and CreepBlock(qx, qy, qz, 90) == 0  then
			CastSpellXYZ("Q", qx, qy, qz)
			lastQ = os.clock()
		end
	end
end

function CastQPull ()
	if (lastQ + 1.5) > os.clock() then
		if CanCastSpell("Q") then
			CastSpellXYZ("Q",myHero.x, myHero.y, myHero.z)
		end
	end
end

function CastW (obj)
	if obj ~= nil and CanCastSpell("W") then
		if GetDistance(obj) < 950 then
			CastSpellXYZ("W", GetFireahead(obj,2,14))
		end
	end
end

function CastComboW ()
	local ally = GetWeakAlly (950)
	if ally ~= nil then
		ShieldPos = GetAllyMEC(300, 950, ally)
		if ShieldPos then
			CastSpellXYZ("W", ShieldPos.x, ShieldPos.y, ShieldPos.z)
		else
			CastSpellXYZ("W", GetFireahead(ally,2,14))
		end
	end
end

function CastEForward (obj)
	if obj ~= nil and CanCastSpell("E") then
		if GetDistance(obj) < 500 then
			CastSpellXYZ("E", GetFireahead(obj,2,0))
		end
	end
end

function CastEBackward (obj)
	if obj ~= nil and CanCastSpell("E") then
		if GetDistance(obj) < 500 then
			qx=myHero.x+(myHero.x-obj.x)
			qy=myHero.y+(myHero.y-obj.y)
			qz=myHero.z+(myHero.z-obj.z)
			CastSpellXYZ("E",qx, qy, qz)
		end
	end
end

function CastUlti ()
	for i=1, objManager:GetMaxHeroes(), 1 do
        hero = objManager:GetHero(i)
        if hero ~= nil then
			if hero.team ~= myHero.team then
				if GetDistance(hero) < 500 and CanCastSpell("R") then
					if ThreshConfig.ultipre == true then
						local rx, ry, rz = GetFireahead(hero,2,0)
						if math.sqrt((rx-myHero.x)^2+(rz-myHero.z)^2) > 350 then
							CastSpellXYZ("R",myHero.x, myHero.y, myHero.z)
						end
					else
						CastSpellXYZ("R",myHero.x, myHero.y, myHero.z)
					end
				end
			end
        end
    end
end

function KillSteal ()
	local kstarget = GetWeakEnemy('MAGIC',myHero.range)
	if kstarget ~= nil then
		local QP = EPassiveDamage(kstarget)
		local AA = getDmg("AD",kstarget,myHero)
		
		if kstarget.health < AA + QP and GetDistance(kstarget) < myHero.range then
			AttackTarget(kstarget)
		end
	end
end

function LastHit ()
	local lasthit = GetLowestHealthEnemyMinion(myHero.range)
	if lasthit ~= nil then
		local QP = EPassiveDamage(lasthit)
		local AA = getDmg("AD",lasthit,myHero)		
		if lasthit.health < AA + QP and GetDistance(lasthit) < myHero.range then
			AttackTarget(lasthit)
			printtext("Hit Target")
		else
			MoveToMouse()
		end
	else
		MoveToMouse()
	end
end

function combo()									
	if target ~= nil then
		UseAllItems(target) 
		
		CastQHook (target)
		
		if (lastQ + ThreshConfig.stundur) < os.clock() then 
			CastQPull ()
			CastComboW()
		end
		
		CastUlti (target)
		
		if ThreshConfig.edirection == 1 then
			CastEForward(target)
		elseif ThreshConfig.edirection == 2 then
			CastEBackward(target)
		end		
		
		if GetDistance(target) < myHero.range then
			AttackTarget(target)
		end
		
		MoveToMouse()
	else
		MoveToMouse()
	end
end

function GetWeakAlly (range)
	local weak_hp = 9999999
	local weak_hero = nil
	for i=1, objManager:GetMaxHeroes(), 1 do
        hero = objManager:GetHero(i)
        if hero ~= nil then
			if hero.team == myHero.team then
				if GetDistance(hero) < range then
					if hero.health < weak_hp then
						weak_hp = hero.health
						weak_hero = hero
					end
				end
			end
        end
    end
	return weak_hero
end

function OnCreateObj(obj)
	if obj and obj ~= nil then
		if obj.charName ~= nil then 
			if (string.find(obj.charName,"Thresh_Soul_Eat_buf.troy")) ~= nil then
				if obj.x == thresh.x and obj.y == thresh.y and obj.z == thresh.z then
					soul_count = soul_count + 1
				end
			end
		end
	end
end

function FindHit()
	if targetaa ~= nil then
		for i = 1, objManager:GetMaxNewObjects(), 1 do
			local object = objManager:GetNewObject(i)
			if object ~=nil and object.charName ~= nil then
				if object.x ~= nil and object.y ~= nil then
					if targetaa.x ~=nil and targetaa.y ~= nil then
						if string.find(object.charName,"globalhit_") ~= nil and GetDistance(targetaa, object) < 100 then
							if (os.clock() - last_attack > .368) and (os.clock() - last_attack < .426) then
								last_attack = os.clock()
							end
						end
					end
				end
            end
        end
    end
end

function GetAllyMEC(radius, range, obj)
    assert(type(radius) == "number" and type(range) == "number" and (obj == nil or obj.team ~= nil), "GetMEC: wrong argument types (expected <number>, <number>, <object> or nil)")
    local points = {}
    for i = 1, objManager:GetMaxHeroes() do
        local object = objManager:GetHero(i)
        if (obj == nil and ValidAlly(object, (range + radius))) or (obj and ValidAlly(object, (range + radius), (obj.team == myHero.team)) and (ValidTargetNear(object, radius * 2, obj) or object.networkID == obj.networkID)) then
            table.insert(points, Vector(object))
        end
    end
    return _CalcSpellPosForGroup(radius, range, points)
end

function ValidAlly(object, distance, allyTeam)
	if distance == nil and allyTeam == nil then
		return (object ~= nil and object.visible == 1 and object.dead == 0 and object.invulnerable == 0)
	end
    local allyTeam = (allyTeam ~= false)
    return object ~= nil and (object.team == myHero.team) == allyTeam and object.visible == 1 and object.dead == 0 and (allyTeam == false or object.invulnerable == 0) and (distance == nil or GetDistance(object) <= distance)
end

function Draw()
	CustomCircle(1075,6,3,myHero)
end

function DrawEnemy()
    if target ~= nil then
        CustomCircle(100,6,2,target)
	end
end

SetTimerCallback("OnTick")