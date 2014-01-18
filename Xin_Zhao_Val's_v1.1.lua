require 'Utils'

local version = '1.1'
local target

function XinDomRun()
	target = GetWeakEnemy('PHYS',600)
	
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
	
	if XinDomConfig.combo then combo() end
end
	
	XinDomConfig = scriptConfig("XinDom Config", "xindomconf")
	XinDomConfig:addParam("combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 88)
	XinDomConfig:addParam("useItems", "Use Items", SCRIPT_PARAM_ONKEYTOGGLE, true, 112)
	XinDomConfig:permaShow("combo")

function combo()	
	if target ~= nil then
		if XinDomConfig.useItems then 
			UseAllItems(target) 
		end		
		if GetDistance(target) > myHero.range+50 and ERDY == 1 then 
			CastSpellTarget("E",target) 
		end
			AttackTarget(target)
		if GetDistance(target) < myHero.range+50 then
			if WRDY == 1 then 
				CastSpellXYZ("W",myHero.x,myHero.y,myHero.z) 
			end
			if QRDY == 1 then 
				CastSpellXYZ("Q",myHero.x,myHero.y,myHero.z) 
			end
		end
	end
	if target == nil and XinDomConfig.combo then MoveToMouse() end
end

function OnDraw()
    if myHero.dead == 0 then CustomCircle(600,6,3,myHero)
		if target ~= nil then CustomCircle(100,4,2,target)
		end
	end
end

SetTimerCallback("XinDomRun")
print("\nVal's Xin Zhao (Dominion Edition) v"..version.."\n")