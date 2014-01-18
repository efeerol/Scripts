--[[
Vincent - 12:59 PM 6/14/2013
1.0 - Released.
1.1 - Added AutoQ Minions
1.2 - Fixed MTM
1.3 - Fixed GetMEC
1.4 - Added Harass
1.5 - Added Killsteal Function
1.6 - Added AutoHarass
1.7 - Added BetaAutoPool
--]]
require "spell_lib"
require "utils"

local percent = ((myHero.health / myHero.maxHealth)*100)
local VladPoolHP = 40      --The percentage of health when vlad will auto pool executions
local maxrange = 700
local ChampConfigName = myHero.name..'Config'
 
function OnTick()
    target = GetWeakEnemy('MAGIC', maxrange)
    OnDraw()
    if VladConfig.Combo then
        if target ~= nil then
		        UseTargetItems(target)
				AttackTarget(target)
                Cast("R", target)
                Cast("E", target)
                Cast("Q", target)
                end
    end
	if VladConfig.Harass then
        if target ~= nil then
		        AttackTarget(target)
                Cast("Q", target)
                Cast("E", target)
                end
    end
	if VladConfig.autoHarass then
        if target ~= nil then
                Cast("E", target)
                Cast("Q", target)
                end
    end
    if VladConfig.movement and (VladConfig.Combo or VladConfig.Harass or VladConfig.autoFarm) and target == nil then
        MoveToMouse()
    end
	if VladConfig.autoFarm and CanCastSpell("Q") then
        local myQ = math.floor(((GetSpellLevel("Q")-1)*35) + 90 + (myHero.ap * .6))
        local minion = GetLowestHealthEnemyMinion(600)
            if minion then
            DrawCircle(minion.x, minion.y, minion.z, 100, Color.Red) end
            if minion ~= nil and minion.health <= CalcMagicDamage(minion, myQ) then
            CastSpellTarget("Q", minion)
            end
    end
end

function ks()
	target = GetWeakEnemy('MAGIC', maxrange)
	if VladConfig.ks then
        if target ~= nil then
		CastHotkey("SPELLQ:WEAKENEMY ONESPELLHIT=((spellq_level*35)+55+((player_ap*6)/10))")
		end
	end
end

function OnDraw()
        CustomCircle(maxrange,5,2,myHero)
        for i = 1, objManager:GetMaxHeroes()  do
            local enemy = objManager:GetHero(i)
                if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) then
                    local Q = getDmg("Q",enemy,myHero)*IsSpellReady("Q")
                    local E = getDmg("E",enemy,myHero)*IsSpellReady("E")
                    local R = getDmg("R",enemy,myHero)*IsSpellReady("R")
                        if enemy.health<Q+E+R then
                        CustomCircle(100,5,2,enemy)
                        DrawTextObject("FINISH HIM!!!", enemy, Color.Red)                                
                        end
                end
        end
end

--### AutoW EXP ###---

function OnProcessSpell(unit,spell)
    for i = 1, objManager:GetMaxHeroes() do
        local enemy = objManager:GetHero(i)
            if enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 then
                if unit ~= nil and spell ~= nil and unit.name == enemy.name then
					if spell.target ~= nil and spell.target.name == myHero.name and VladConfig.autoW and percent <= VladPoolHP then
                        if (string.find(spell.name,"darius_R") ~= nil or string.find(spell.name,"garen_damacianJustice") ~= nil) and CanUseSpell("W") then
                            CastSpellTarget("W", myHero)
                        end
                    end
                end
            end
    end
end
 
VladConfig = scriptConfig(myHero.name.."Config", myHero.name.."Config")
VladConfig:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
VladConfig:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
VladConfig:addParam("autoFarm", "Auto Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
VladConfig:addParam("autoHarass", "Auto Harass", SCRIPT_PARAM_ONOFF, true, string.byte("K"))
VladConfig:addParam("autoW", "Auto W", SCRIPT_PARAM_ONOFF, true)
VladConfig:addParam("ks", "Q Killsteal", SCRIPT_PARAM_ONOFF, true)
VladConfig:addParam("movement", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)
VladConfig:permaShow("Combo")
VladConfig:permaShow("Harass")
VladConfig:permaShow("autoFarm")
 
SetTimerCallback("OnTick")