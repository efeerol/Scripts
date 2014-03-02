-- ###################################################################################################### --
-- #                                                                                                    # --
-- #                                           Val's Twitch											    # --
-- #                                                                                                    # --
-- ###################################################################################################### --

require "Utils"
printtext("\nVal's Twitch\n")
	
-------------------------------------------------------------------------------------------------------------
------------------------------------------------- CONFIG ----------------------------------------------------

local hotkey = 89 -- Y -- Hotkey for W, change this to your favorite hotkey (Virtual Key List: http://tinyurl.com/3o99xo2)
local aarange = 1	-- Set this to 0 to deactivate autoattack range circle
local ultrange = 1	-- Set this to 0 to deactivate the expanded autoattack range circle during ult
local Wrange = 1	-- Set this to 0 to deactivate W range circle
local useW = 1		-- Set this to 0 to deactivate W (this deactivate the hotkey!)
local usescript = 1 -- Set this to 0 to deactivate the whole script except for auto Expunge

--------------------------------------------------- END ------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
		
local version = "1.2"
local myHero = GetSelf()	
local target	
local ultactive = false
local timer = os.clock()


function TwitchRun()
	if usescript == 1 then
	
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
	
	CLOCK = os.clock()
	FindNewObjects()
	DrawW()
	DrawAA()
	DrawULT()
	key = IsKeyDown(hotkey)
	
	target = GetWeakEnemy('PHYS',950)
	
		if key == 1 and useW == 1 and WRDY == 1 then									
--			if target ~= nil then	
			CastHotkey("SPELLW:WEAKENEMY RANGE=950 FIREAHEAD=2,14 PHYSICAL")
			printtext("\nW casted\n")
			end
		end
	end
--end

function DrawAA()
	if aarange == 1 and ultactive == false then
		DrawCircleObject(myHero, 550, 2)
	end
end

function DrawW()
	if Wrange == 1 then
		DrawCircleObject(myHero, 950, 1)
	end
end

function DrawULT()
	if ultrange == 1 and ultactive == true then
		DrawCircleObject(myHero, 850, 5)
	end
end

function FindNewObjects()
	for i = 1, objManager:GetMaxNewObjects(), 1 do
		local object = objManager:GetNewObject(i)
		local s=object.charName
		if (s ~= nil) then
			if string.find(s,"twitch_ambush_buf_02") ~= nil and GetDistance(myHero, object) < 100 then  	
				ultactive = true
				timer = CLOCK
				if target ~= nil then
					AttackTarget(target)
				end
			end
			if (CLOCK-timer>7) then
				ultactive = false
			end
		end
	end
end

local script_loaded=1
local hero_table = {}
local hero_table_timer = {}
local toggle_timer=os.clock()
local poison_object="twitch_poison_counter_0"
local poison_len=string.len(poison_object)
local cast_e_timer=0
function sample_CallBackTwitch()
    CLOCK=os.clock()
    local spelle_level=GetSpellLevel('E')
    if (CLOCK-cast_e_timer<.3) then
        return
    end
    local p=GetSelf()
    local key=112;
    local max_new_objects=objManager:GetMaxNewObjects()
    local max_heroes=objManager:GetMaxHeroes()
    local player_team=p.team
    local twitch_e_base=30+spelle_level*10
	local damageperstack=10+spelle_level*5+p.ap*.2+p.addDamage*.25
	
	if (IsKeyDown(key)~=0 and CLOCK-toggle_timer>1.2 and key~=0) then
        toggle_timer=CLOCK
        script_loaded= ((script_loaded+1)%2)
    end
    if (script_loaded==1) then
        DrawText("Auto Expunge loaded",10,40,0xFF00EE00);
        if (CLOCK-toggle_timer<6) then
            DrawText("Press key again to toggle",10,50,0xFF00EE00);
        end
    else
        DrawText("Auto Expunge unloaded",10,40,0xFFFFFF00);
        return
    end
    for i = 1,max_new_objects, 1 do
        local object = objManager:GetNewObject(i)
        local s=object.charName
        if (s ~= nil) then
        local chk=string.find(s,"twitch_poison_counter_")
        if (chk ~= nil) then
            chk=chk+poison_len
            local counter=string.sub(s,chk,chk)
            for j = 1, max_heroes, 1 do
                local h=objManager:GetHero(j)
                if (GetDistance(h,object)<100) then
                    local name=h.charName
                    hero_table[name]=tonumber(counter)
                    hero_table_timer[name]=CLOCK					
--                    print("\nhero:" .. h.name .. " x:" .. h.x .. " z:" .. h.z .. " counter:" .. counter)
                end
            end
        end
        end
    end
    for i= 1,max_heroes,1 do
        local h=objManager:GetHero(i)
        if (h.team ~= player_team and h.visible==1 and h.invulnerable==0) then
            local name=h.charName
            local stacks=hero_table[name]
			
					if stacks==6 then
						for i = 1,max_new_objects, 1 do
					local object = objManager:GetNewObject(i)
					local s=object.charName
						if (s ~= nil) then
							if string.find(s,"twitch_basicAttack_mis") or string.find(s,"twitch_sprayandPray_mis") and (GetDistance(h,object)<100) then
					hero_table_timer[name]=CLOCK
					end
				end
			end  
		end
		 if (stacks==nil or CLOCK-hero_table_timer[name]>5.5) then
                stacks=0
            end
			local effhealth = h.health*((100+((h.armor-((h.armor*p.armorPenPercent)/100))-p.armorPen))/100)
            local damage=twitch_e_base+(stacks*damageperstack)
            if (effhealth<damage and spelle_level>0) then
                print("\ntarget:" .. h.name .. " damage:" .. damage .. " effhp:" .. effhealth)
                if (GetDistance(p,h)<1200) then
                    CastSpellTarget('E',h)
                    cast_e_timer=CLOCK
                    break
                end
            end
        end
    end
end
SetTimerCallback("TwitchRun")
SetTimerCallback("sample_CallBackTwitch")
print("\nAuto Expunge loaded\n")