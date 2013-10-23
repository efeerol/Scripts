require "Utils"
require "spell_damage"

local target
local targetignite 
local qrange = 875
local wrange = 550
local erange = 275

ZedConfig = scriptConfig("Zedbot", "Zedcombo")
ZedConfig:addParam("AllinCombo", "AllinCombo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
ZedConfig:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
ZedConfig:addParam("useQ", "useQ", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Q"))
ZedConfig:addParam("escape", "escape", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
ZedConfig:addParam("killsteal", "killsteal", SCRIPT_PARAM_ONOFF, true)
ZedConfig:addParam("movement", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)
ZedConfig:addParam("autoattack", "AutoAttacks in combo", SCRIPT_PARAM_ONOFF, true)
ZedConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
ZedConfig:addParam('ignite', 'Auto Ignite', SCRIPT_PARAM_ONKEYTOGGLE, true, 118)

function OnTick()
target = GetWeakEnemy("PHYS", qrange, "NEARMOUSE")
targetignite = GetWeakEnemy('TRUE',600)
if IsChatOpen() == 0 then

if target ~= nil then
	CustomCircle(50,10,1,target)
	CustomCircle(50,5,2,target)
end

if ZedConfig.ignite then ignite() end

if ZedConfig.escape then
	if CanCastSpell("W") then CastSpellXYZ("W",mousePos.x,mousePos.y,mousePos.z) end
	MoveToMouse()
end

if ZedConfig.useQ then
	if CanCastSpell("Q") and target ~= nil then 
	CastSpellXYZ("Q",GetFireahead(target,2,16)) end
end
if ZedConfig.AllinCombo then
	if target ~= nil then
	
	local qdmg = getDmg("Q",target,myHero)
	local edmg = getDmg("E",target,myHero)
	
	if CanCastSpell("R") and myHero.SpellNameR == "zedult" and (edmg+qdmg)< target.health then 
		CastSpellTarget("R",target)		
	end
	UseAllItems(target)
	if CanCastSpell("W") and CanCastSpell("E") and myHero.SpellNameW == "ZedShadowDash" and GetDistance(target) < wrange and GetDistance(target) > erange then
		CastSpellXYZ("W",GetFireahead(target,2,2000)) 
	end
	if CanCastSpell("E") and myHero.SpellNameW == "zedw2" then CastSpellTarget("E",myHero) end
	if CanCastSpell("E") and myHero.SpellNameR == "ZedR2 " then CastSpellTarget("E",myHero) end
	if CanCastSpell("E") and GetDistance(target) < erange then CastSpellTarget("E",target) end
	if CanCastSpell("Q") then CastSpellXYZ("Q",GetFireahead(target,2,16)) end
	if IsAttackReady() and ZedConfig.autoattack then AttackTarget(target) end
	end
end

if ZedConfig.Combo then
	if target ~= nil then
	
	local qdmg = getDmg("Q",target,myHero)
	local edmg = getDmg("E",target,myHero)
	
	if CanCastSpell("R") and myHero.SpellNameR == "zedult" and (edmg+qdmg)< target.health then 
		CastSpellTarget("R",target) 
	end
	UseAllItems(target)
	if CanCastSpell("E") and GetDistance(target) < erange then CastSpellTarget("E",target) end
	if CanCastSpell("E") and myHero.SpellNameR == "ZedR2 " then CastSpellTarget("E",myHero) end
	if CanCastSpell("Q") then CastSpellXYZ("Q",GetFireahead(target,2,16)) end
	if IsAttackReady() and ZedConfig.autoattack then AttackTarget(target) end
	end
end


if ZedConfig.movement and (ZedConfig.AllinCombo or ZedConfig.Combo) and not target then
MoveToMouse()
end	
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
if ZedConfig.drawcircles and myHero.dead == 0 then
	CustomCircle(900,1,3,myHero) --Q
	CustomCircle(625,5,2,myHero) --R
	CustomCircle(290,10,1,myHero) --E


for i = 1, objManager:GetMaxHeroes()  do
			local enemy = objManager:GetHero(i)
			if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.dead == 0 and enemy.invulnerable==0) then
				local pdmg = getDmg("P",enemy,myHero) 
				local qdmg = getDmg("Q",enemy,myHero)*CanUseSpell("Q") 
				local wdmg = getDmg("W",enemy,myHero)*CanUseSpell("W")
				local edmg = getDmg("E",enemy,myHero)*CanUseSpell("E")
				local rdmg = getDmg("R",enemy,myHero)*CanUseSpell("R")
				local aadmg = getDmg("AD",enemy,myHero)
				
					if enemy.health < (qdmg+wdmg+edmg+rdmg+pdmg+(aadmg*3)) then
						CustomCircle(10,10,4,enemy)
					end
					
					if enemy.health < qdmg and CanCastSpell("Q") and ZedConfig.killsteal and GetDistance(enemy) < qrange then
						CastSpellXYZ("Q",GetFireahead(enemy,2,16))
					end
					
					if enemy.health < edmg and CanCastSpell("E") and ZedConfig.killsteal and GetDistance(enemy) < erange then
						CastSpellXYZ("E",myHero.x,myHero.y,myHero.z)
					end

					
				end
			end	
	
	
	
	end
end
SetTimerCallback("OnTick")