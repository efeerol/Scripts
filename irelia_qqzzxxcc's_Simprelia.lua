-- ###################################################################################################### --
-- #                                                                                                    # --
-- #                                           qqzzxxcc's Simprelia										# --
-- #                                  (based on Val's Akali script which is)							# --
-- #                                    (based on Sida`s Katarina script)								# --
-- #                                                                                                    # --
-- ###################################################################################################### --

require "basic_functions"
print=printtext
printtext("\nqqzzxxcc's Simprelia\n")	
		
local farmkey = 88
local allies = {}
local enemies = {}
local hotkey = GetScriptKey()
local myHero = GetSelf()
local target
local farmmode = 0


function Run()	
	
	local key = IsKeyDown(hotkey) 	
 
	target = GetWeakEnemy('PHYS',650,"NEARMOUSE")
	if target ~= nil then killSteal() end
	if key ~= 0 then 
		
		if target ~= nil then
			useItems() 
		
			if GetDistance(myHero, target) < 125 and IsSpellReady("W") == 1 then
				castW(target)
			end	
			
			if GetDistance(myHero, target) < 425 and IsSpellReady("E") == 1 and myHero.hp<target.hp then 	
				castE(target)
			end	

			if GetDistance(myHero, target) < 870 and GetDistance(myHero, target) > 650 then 	
				castR(target)
			end	
			
			if GetDistance(myHero, target) < 425 and GetDistance(myHero, target) > 125 and IsSpellReady("Q") == 0 then 	
				castE(target)
			end		
			
			if GetDistance(myHero, target) > 425 and IsSpellReady("Q") == 0 and IsSpellReady("E") == 0 then 	
				castR(target)
			end	
			
			if GetDistance(myHero, target) < 650 and GetDistance(myHero, target) > 200  then
				castQ(target)
			end
			AttackTarget(target)
		end
		if target == nil then
			MoveToXYZ(GetCursorWorldX(), GetCursorWorldY(), GetCursorWorldZ())
		end
	end
	farmcheck()
	
end

function castQ(target)
	if IsSpellReady("Q") == 1 then								
	CastSpellTarget("Q", target) 						
	end
end

function castW(target)
	if IsSpellReady("W") == 1 then
	CastSpellTarget("W", target) 						
	end
end

function castE(target)
	if IsSpellReady("E") == 1 then
	CastSpellTarget("E", target) 						
	end
end

function castR(target)
	CastHotkey("AUTO 1500,6000 SPELLR:WEAKENEMY RANGE=940 FIREAHEAD=2,16 CD")
end
		
function killSteal()
		CastHotkey("SPELLQ:WEAKENEMY ONESPELLHIT=#((spellq_level*30)-10+player_ad) RANGE=650 COOLDOWN NOSHOW")
		return
	end

function useItems()
	if target ~= nil then
		if GetDistance(myHero, target) < 750 then
			useItem(3128)
		end
		if GetDistance(myHero, target) < 700 then
			useItem(3146)
		end
		if GetDistance(myHero, target) < 400 then
			useItem(3144)
		end
	end
end

function useItem(item)
	if GetInventoryItem(1) == item then 
		CastSpellTarget("1", target)
	elseif GetInventoryItem(2) == item then 
		CastSpellTarget("2", target)
	elseif GetInventoryItem(3) == item then 
		CastSpellTarget("3", target)
	elseif GetInventoryItem(4) == item then 
		CastSpellTarget("4", target)
	elseif GetInventoryItem(5) == item then 
		CastSpellTarget("5", target)
	elseif GetInventoryItem(6) == item then 
		CastSpellTarget("6", target)
	end
end

SetTimerCallback("Run")

local toggleclock=os.clock()
function farmcheck()
	CLOCK=os.clock()
	if (IsKeyDown(farmkey)~=0 and farmkey~=0 and CLOCK-toggleclock>1.2) then
		toggleclock=CLOCK
        farmmode= ((farmmode+1)%2)
    end
	if (farmmode==1) then
        DrawText("Farmmode: ON",10,60,0xFF00EE00);
		CastHotkey("AUTO 100,0 SPELLQ:WEAKMINION RANGE=650 ONEHIT=((spellq_level*30)-10) PHYSICAL CD");
        if (CLOCK-toggleclock<6) then
            DrawText("Press key again to toggle",10,45,0xFF00EE00);
        end
	else 
		farmmode=0
		DrawText("Farmmode: OFF",10,60,0xFF00EE00);
		return
	end
end