require "Utils"

ShacoConfig = scriptConfig("NeeD Shaco", "needshaco")
ShacoConfig:addParam("active", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
ShacoConfig:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
ShacoConfig:addParam("steal", "E Steal", SCRIPT_PARAM_ONOFF, false)
ShacoConfig:addParam("movement", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)
ShacoConfig:addParam("harassMode", "Harass Mode", SCRIPT_PARAM_DOMAINUPDOWN, 2, string.byte("T"), {"E","E+Q"})
ShacoConfig:addParam("useItems", "Use Items", SCRIPT_PARAM_ONOFF, true)
ShacoConfig:addParam("drawCircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
ShacoConfig:addParam("autoAttack", "Auto Attack After Combo", SCRIPT_PARAM_ONOFF, true)
ShacoConfig:permaShow("active")
ShacoConfig:permaShow("harass")
ShacoConfig:permaShow("harassMode")


local target

function Run()
	Util__OnTick()
    target = GetWeakEnemy('PHYS',655)
	if ShacoConfig.steal and target ~= nil then ESteal() end
    if ShacoConfig.active then
        if target ~= nil then
		if ShacoConfig.useItems then UseAllItems(target) end
                if GetDistance(target) < 625 then
                    castE(target)
                end
                if GetDistance(target) < 625 then
                    castQ(target) 
					AttackTarget(target)
                end
                if GetDistance(target) < 200 then
				if not CanCastSpell("Q") and not CanCastSpell("E") then
                    CastSpellTarget("R", target)
                end
            end
        end
			if target == nil and ShacoConfig.movement then
				MoveToMouse()
			elseif target ~= nil then
				if ShacoConfig.autoAttack then
					AttackTarget(target)
				elseif ShacoConfig.movement then
					MoveToMouse()
				end
			end
        end
 
	
	if ShacoConfig.harass then
		if ShacoConfig.movement then
			MoveToMouse()
		end
		if target ~= nil then
			if GetDistance(target) < 625 then
				castE(target) 
			end
			if ShacoConfig.harassMode > 1 and GetDistance(target) < 625 then
				castQ(target) 
				AttackTarget(target)
			end
		end
	end
end

function castQ(target)
    if CanCastSpell("Q") then
        CastSpellXYZ("Q", target.x, target.y, target.z)
    end
end


function castE(target)
    if CanCastSpell("E") then
        CastSpellTarget("E",target)
    end
end

function ESteal()
	if target ~= nil then
			for i = 1, objManager:GetMaxHeroes()  do
			local enemy = objManager:GetHero(i)
			if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) then
				local edmg = CanUseSpell("E")*(40*GetSpellLevel("E")+1*myHero.ap+1*myHero.baseDamage)
				if enemy.health < edmg and GetDistance(target) < 625 then
                    castE(target)
                end
			end
		end
	end
end


function OnDraw()
    if ShacoConfig.drawCircles then
		CustomCircle(625,4,3,myHero)
		if target ~= nil then
			CustomCircle(100,4,1,target)
		end
		for i = 1, objManager:GetMaxHeroes()  do
			local enemy = objManager:GetHero(i)
			if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) then
				local qdmg = CanUseSpell("Q")*(.20*GetSpellLevel("Q")+.20*myHero.baseDamage)
				local edmg = CanUseSpell("E")*(40*GetSpellLevel("E")+1*myHero.ap+1*myHero.baseDamage)
				if enemy.health < (qdmg+edmg) then 
					CustomCircle(100,4,2,enemy)
					DrawTextObject("Murder Him!!!", enemy, Color.Red)					
				end
			end
		end
	end
end

SetTimerCallback("Run")
printtext("\nNeeD Shaco")