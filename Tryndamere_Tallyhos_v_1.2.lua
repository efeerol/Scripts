-- Required Libraries
require 'Utils'
require 'uiconfig'

--Variables
local target
local FLEEING = 0
local CHASING = 1
local STATIONARY = 2
local uiconfig = require 'uiconfig'
local timer = 0
local Minion 
local smitedamage

--Menu
CfgTrynd, menu = uiconfig.add_menu('Tryndamere',200)
menu.keydown('Combo','Combo', Keys.Space)
menu.keydown('Farm','Farm', Keys.C)
menu.keytoggle('Jungle','AutoSmite', 200, Keys.X, true)
menu.keytoggle('Hydra','Auto Hydra/Tiamat', 200, Keys.Z, true)
menu.slider('BotRK','Use Bilge/BotRK %', 0, 100, 25, nil, true)
menu.slider('UltHP','Auto Ult %', 0, 100, 25, nil, true)
menu.slider('HealHP','Auto Heal %', 0, 100, 50, nil, true)
menu.slider('IgniteHP','Auto Ignite %', 0, 100, 25, nil, true)
menu.slider('ExhaustHP','Auto Exhaust %', 0, 100, 25, nil, true)
menu.slider('AutoPot','Auto HP Pot %', 0, 100, 75, nil, true)
menu.slider('AutoElixir','Auto Elixir HP %', 0, 100, 75, nil, true)
	menu.permashow('Jungle')
	menu.permashow('Farm')
	
--Main Function
function Main()
Minion = GetLowestHealthEnemyMinion(500)
	Smite()
target = GetWeakEnemy('PHYS', 1500)
	if target ~= nil then
		if CfgTrynd.Combo then Combo() end
		if CfgTrynd.Hydra then Hydra() BotRK() end
	end
	if CfgTrynd.Jungle then Jungle() end
	if CfgTrynd.Farm then LastHit() end
	Draw()
	HealthPot()
	RedElixir()
	TryndQ()
	TryndUlt()
		if Minion ~= nil then
			if GetDistance(myHero,Minion) <= 550 then
				CustomCircle(100,2,1,Minion)
			end
		end
	CustomCircle(500,2,1,myHero)
end

--Combo Func
function Combo()
	if target ~= nil then
		TryndE() 
		TryndW() 
		Ignite() 
		Exhaust() 
		AttackTarget(target) 
		BotRK()
		else MoveToMouse() 
	end
	MoveToMouse()
end
		
--LastHit BETA
function LastHit()
	if Minion ~= nil then
		if Minion.health <= (myHero.addDamage + myHero.baseDamage) then
			AttackTarget(Minion) else
			MoveToMouse()
		end
	end
	MoveToMouse()
end


--GetRange
function GetRange(range)
	if target ~= nil and GetDistance(myHero,target) <= range then
		return true
	end
end

--Draw (Range Circles)
function Draw()
	if 	target ~= nil and GetRange(660) then 
		CustomCircle(100,2,1,target)
	end
end

--Item Usage
function BotRK()
	if target ~= nil then
		if target.health <= target.maxHealth*(CfgTrynd.BotRK / 100) and GetRange(450) then
			UseItemOnTarget(3153, target)
			UseItemOnTarget(3144, target)
		end
	end
end

function Hydra()
	if target ~= nil then
		if GetRange(400) then
			UseItemOnTarget(3074,myHero)
			UseItemOnTarget(3077,myHero)
		end
	end
end


--Consumables
function HealthPot()
	if myHero.health <= myHero.maxHealth*(CfgTrynd.AutoPot / 100) and os.time() > timer + 15 then
		UseItemOnTarget(2003, myHero)
		UseItemOnTarget(2010, myHero)
		timer = os.time()
	end
end

function RedElixir()
	if myHero.health <= myHero.maxHealth*(CfgTrynd.AutoElixir / 100) then
		UseItemOnTarget(2037, myHero)
	end
end

--Summoners
function Ignite()
	if target ~= nil then
		if myHero.SummonerD == 'SummonerDot' then
			if target.health <= target.maxHealth*(CfgTrynd.IgniteHP / 100) and myHero.SpellTimeD > 1.0 then
				CastSummonerIgnite(target)
			end
		end
		if myHero.SummonerF == 'SummonerDot' then
			if target.health <= target.maxHealth*(CfgTrynd.IgniteHP / 100) and myHero.SpellTimeF > 1.0 then
				CastSummonerIgnite(target)
				end
		end
	end
end

function Exhaust()
	if target ~= nil then
		if myHero.SummonerD == 'SummonerExhaust' then
			if target.health <= target.maxHealth*(CfgTrynd.ExhaustHP / 100) and myHero.SpellTimeD > 1.0 then
				CastSummonerExhaust(target)
			end
		end
		if myHero.SummonerF == 'SummonerExhaust' then
			if target.health <= target.maxHealth*(CfgTrynd.ExhaustHP / 100) and myHero.SpellTimeF > 1.0 then
				CastSummonerExhaust(target)
			end
		end
	end
end

--Q Heal
function TryndQ()
	if myHero.SpellTimeQ > 1.0 and myHero.health <= myHero.maxHealth*(CfgTrynd.HealHP / 100) then
		CastSpellTarget('Q', myHero)
	end
end

--E Harass
function TryndE()
target = GetWeakEnemy('PHYS', 1500)
        if target ~= nil then
                if myHero.SpellTimeE > 1.0 and GetDistance(myHero,target) <= 660 then
                        CastSpellXYZ('E',GetFireahead(target,2,20))
                end
        end
end

--Facing Detection by CCONN81
function GetTargetDirection()
    local distanceTarget = GetDistance(target)
    local x1, y1, z1 = GetFireahead(target,2,10)
    local distancePredicted = GetDistance({x = x1, y = y1, z = z1})
    
    return (distanceTarget > distancePredicted and CHASING or (distanceTarget < distancePredicted and FLEEING or STATIONARY))
end

--Slow
function TryndW()
    if target ~= nil then
        if GetTargetDirection() == FLEEING and myHero.SpellTimeW > 1.0 and GetDistance(myHero,target) <= 400 then
            CastSpellTarget('W',target)
        end
    end
end

--AutoUlt
function TryndUlt()
target2 = GetWeakEnemy('PHYS', 2500)
    if target2 ~= nil then
        if myHero.health <= myHero.maxHealth*(CfgTrynd.UltHP / 100) then
            CastSpellTarget('R', myHero)
        end
    end
end

--Jungle SmiteSteal
function Jungle()
        for i = 1, objManager:GetMaxObjects(), 1 do  
            obj = objManager:GetObject(i) 
            if obj ~= nil then 
				if (obj.charName:find("AncientGolem")) or (obj.charName:find("LizardElder")) or (obj.charName:find("Dragon" )) or (obj.charName:find("Worm" ))then
					if GetDistance(myHero,obj) <= 750 and obj.health <= smitedamage then
						CastSpellTarget('F',obj)
                end
            end
        end
	end
end

--Smite
function Smite()
	if myHero.selflevel < 5 then 
		smitedamage = 370+(myHero.selflevel*20) 
	elseif myHero.selflevel > 4 and myHero.selflevel < 10 then
		smitedamage = 330+(myHero.selflevel*30)
	elseif myHero.selflevel > 9 and myHero.selflevel < 15 then
		smitedamage = 240+(myHero.selflevel*40)
	elseif myHero.selflevel > 14 then
		smitedamage = 100+(myHero.selflevel*50)
	end
end

SetTimerCallback('Main')