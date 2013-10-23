require "Utils"
require "spell_damage"

local version = '1.0'
local target
local target2

function OnTick()
	target = GetWeakEnemy("PHYS", 975, "NEARMOUSE")
    target2 = GetWeakEnemy('TRUE',600)
    
    if LeeConfig.Combo then Combo() end    
    if LeeConfig.smite then Smite() end
	if LeeConfig.ignite then ignite() end
    if LeeConfig.movement and ( LeeConfig.Combo ) then MoveToMouse() end      
end

LeeConfig = scriptConfig("KillerLee", "Combo")
LeeConfig:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))--T
LeeConfig:addParam("smite", "Smitesteal", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("f3")) --f3
LeeConfig:addParam("ignite", "Ignite", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("f4")) --f3
LeeConfig:addParam("movement", "movement", SCRIPT_PARAM_ONOFF, true)
LeeConfig:addParam("killsteal", "killsteal", SCRIPT_PARAM_ONOFF, true)
LeeConfig:addParam("circles", "Circles", SCRIPT_PARAM_ONOFF, true)
LeeConfig:permaShow("smite")
LeeConfig:permaShow("ignite")
LeeConfig:permaShow("killsteal")

function ignite()
	local damage = (myHero.selflevel*20)+50
	if target2 ~= nil then
		if myHero.SummonerD == "SummonerDot" then
			if target2.health < damage then
				CastSpellTarget("D",target2)
			end
		end
		if myHero.SummonerF == "SummonerDot" then
			if target2.health < damage then
				CastSpellTarget("F",target2)
			end
		end
	end
end

function Combo()
    if target ~= nil then
        CustomCircle(100,4,1,target)
        if ignitekey and CanCastSpell(ignitekey) then 
			CastSpellTarget(ignitekey,target) 
		end
       if myHero.SpellNameQ == "BlindMonkQOne" and CanCastSpell("Q") and CreepBlock(target.x,target.y,target.z) == 0 then CastSpellXYZ('Q',GetFireahead(target,1.6,18)) printtext("\nQ1") end

        if CanCastSpell("E") and GetDistance(target) < 400 then 
			CastSpellXYZ('E',myHero.x,myHero.y,myHero.z) printtext("\nE") 
		end
        if myHero.SpellNameQ == "blindmonkqtwo" and CanCastSpell("R") then 
			CastSpellTarget("R",target) printtext("\nR") 
		end
        UseAllItems(target)
        if myHero.SpellNameQ == "blindmonkqtwo" and GetDistance(target) > 200 and CanCastSpell("Q") then 
			CastSpellTarget("Q",target)  
		end   
        if IsAttackReady() then 
			AttackTarget(target) 
		end
        if myHero.SpellNameQ == "blindmonkqtwo" and CanCastSpell("Q") then 
			CastSpellTarget("Q",target)  
		end
    end
end

function Smite()
    if myHero.SummonerD == "SummonerSmite" then
        CastHotkey("AUTO 100,0 SPELLD:SMITESTEAL RANGE=600 TRUE COOLDOWN")
        return
    end
    if myHero.SummonerF == "SummonerSmite" then
        CastHotkey("AUTO 100,0 SPELLF:SMITESTEAL RANGE=600 TRUE COOLDOWN")
        return
    end
    
    for i=1, objManager:GetMaxObjects(), 1 do
        local object = objManager:GetObject(i)
        if object ~= nil and object.name ~= nil and (string.find(object.name,"Dragon") or string.find(object.name,"Baron")) then
            if GetDistance(object,myHero) < 1200 then
                local damage = 460+(30*myHero.selflevel)
                if object.health <= damage then
                    CustomCircle(100,10,7,object)
                end
            end
        end
    end
end

function OnDraw()
    if LeeConfig.circles then
        CustomCircle(975,10,5,myHero) --Q    
        CustomCircle(375,10,5,myHero) --R
        CustomCircle(700,10,5,myHero) --W          
        if target ~= nil then
			CustomCircle(50,5,2,target) 
		end
        for i = 1, objManager:GetMaxHeroes()  do
            local enemy = objManager:GetHero(i)
            if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) then
                local qdmg = getDmg("Q",enemy,myHero,2)*CanUseSpell("Q")
                local edmg = getDmg("E",enemy,myHero)*CanUseSpell("E")
                local rdmg = getDmg("R",enemy,myHero)*CanUseSpell("R")
                           
                if LeeConfig.killsteal then                    
                    if GetDistance(enemy) < 300 then
                        if qdmg >= enemy.health and myHero.SpellNameQ == "2ndq" then CastSpellTarget("Q",enemy) end
                        if rdmg >= enemy.health then CastSpellTarget("R",enemy) end
                        if edmg >= enemy.health then CastSpellTarget("E",enemy) end
                    end
                end
            end    
        end
    end
end

SetTimerCallback("OnTick")
print("\nLeesin the jungle adc apc tank offtank support assassin your father champion v "..version.."\n")