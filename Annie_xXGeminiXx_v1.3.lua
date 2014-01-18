--Annie v1.3 by xXGeminiXx

require "Utils"

local myHero = GetSelf()
local target
local Stun = 0
local IgniteDMG = 25+(20*myHero.selflevel)

if myHero.name == "Annie" then

function Run()
    target = GetWeakEnemy('MAGIC',650,"NEARMOUSE")
	CustomCircle(625,2,3,myHero)
	
	if Stun == 0 then
		FindNewObjects()   
	end
	SmiteSteal()
	if AnnieConfig.Combo then
		if target ~= nil then
			
			UseAllItems(target)
			AutoIgnite()
			CastUlt() -- Need to add detection of tibbers so that we don't keep hitting R and cancelling Tibber's autoattacks
			AnnieQ()
			AnnieW()
			AttackTarget(target)
		end
		if target == nil then 
			MoveToMouse()
		end
	end
	
	if AnnieConfig.Harass and AnnieConfig.WasteStun then
		if target ~= nil then
			AnnieQ()
			AnnieW()
		end
		if target == nil then 
			MoveToMouse()
		end
	end

	if AnnieConfig.Harass and AnnieConfig.WasteStun == false then
		if target ~= nil then
			if Stun == 0 then
				AnnieQ()
				AnnieW()
			end
		end
		if target == nil then 
			MoveToMouse()
		end
	end

	if AnnieConfig.QFarm and target == nil then
		if AnnieConfig.WasteStun then
			QFarm()
		end
	end
	
	if AnnieConfig.QFarm and target == nil then
		if AnnieConfig.WasteStun == false then
			if Stun == 0 then
				QFarm()
			end
		end
	end
end
end

function QFarm()
    if IsSpellReady("Q") then
		CastHotkey("SPELLQ:WEAKMINION RANGE=650 ONESPELLHIT=((spellq_level*40)+85+(player_ap*7/10))")
		Stun=0
	end
end

function AnnieQ()
	if GetDistance(myHero, target) < 650 and IsSpellReady("Q") then 
		CastSpellTarget("Q", target) 
		Stun=0
	end
end

function AnnieW()
	if GetDistance(myHero, target) < 625 and IsSpellReady("W") then 
		CastSpellTarget("W", target) 
		Stun=0
	end
end

function AnnieE()
--I'll add this eventually as well
end

function SmiteSteal()
	if AnnieConfig.SmiteSteal then
		DrawText("Malbert so silly.", 10, 125, Color.Pink)
	end
end

function AutoIgnite()
    local target = GetWeakEnemy('TRUE', 600)
    local IgniteDMG = 50+(20*myHero.selflevel)

    if target ~= nil and myHero.SummonerD == "SummonerDot" and target.visible and target.dead ~= 1 and target.invulnerable ~= 1 and target.health < IgniteDMG then
        if IsSpellReady("D") == 1 then
            CastSpellTarget("D",target)
        end
    end

    if target ~= nil and myHero.SummonerF == "SummonerDot" and target.visible and target.dead ~= 1 and target.invulnerable ~= 1 and target.health < IgniteDMG then
        if IsSpellReady("F") == 1 then
            CastSpellTarget("F",target)
        end
    end

end

function CastUlt()
	if CanCastSpell("R") then
		ultPos = GetMEC(290, 600, target)
			if ultPos then
				CastSpellXYZ("R", ultPos.x, ultPos.y, ultPos.z)
				Stun=0
			else
				CastSpellTarget("R", target)
				Stun=0
			end
	end
end

function FindNewObjects()
    for i = 1, objManager:GetMaxNewObjects(), 1 do
        local object = objManager:GetNewObject(i)
        local s=object.charName
        if (s ~= nil) then
            if string.find(s,"StunReady") and GetDistance(object) < 200  ~= nil then    
                Stun = 1
            end
        end
    end
end

AnnieConfig = scriptConfig("Annie Config", "AnnieConfig")
if myHero.name == "Annie" then
	AnnieConfig:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	AnnieConfig:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
	AnnieConfig:addParam("QFarm", "QFarm", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("V"))
	AnnieConfig:addParam("WasteStun", "WasteStun", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("B"))
	AnnieConfig:addParam("SmiteSteal", "SmiteSteal", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("N"))
	
	AnnieConfig:permaShow("WasteStun")
	AnnieConfig:permaShow("QFarm")
end

SetTimerCallback("Run")