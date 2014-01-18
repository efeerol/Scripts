--[[
    Script: IGER's WardRevealer v2.5
    Author: PedobearIGER and Lua
]]--
require 'Utils'
local uiconfig = require 'uiconfig'
local wards = {}

	WardRevealer, menu = uiconfig.add_menu('WardRevealer Config', 250)
	menu.keytoggle('ShowWardSight', 'Show Ward Sight', Keys.I, true)
	menu.permashow('ShowWardSight')

function OnLoad()
    for i=1, objManager:GetMaxObjects(), 1 do
        local object = objManager:GetObject(i)
        local ward = {}
        ward = GetWardInfo(object,"OnLoad")
        if ward ~= nil then
            table.insert(wards,ward)
        end
    end
    loaded = true
end

function OnTick()
    if loaded == nil then OnLoad() end
    
    for i,ward in ipairs(wards) do
        for j,ward2 in ipairs(wards) do
            if (ward.type == "OnProcessSpell" or ward2.type == "OnProcessSpell") and ward.type ~= ward2.type and GetDistance(ward.pos,ward2.pos) < 100 and math.abs(ward.endTick-ward2.endTick) < 3000 then
                if ward.type == "OnProcessSpell" then table.remove(wards,i)
                elseif ward2.type == "OnProcessSpell" then table.remove(wards,j)
                end
                break
            end
        end
        if ward == nil or GetClock() >= ward.endTick then 
            table.remove(wards,i)
            printtext(ward.name.." removed\n")
        else 
			if ward.team ~= myHero.team then
				DrawCircle(ward.pos.x,ward.pos.y,ward.pos.z,ward.triggerRange,ward.color)
				if WardRevealer.ShowWardSight == true and ward.sight == true then
					DrawCircle(ward.pos.x,ward.pos.y,ward.pos.z,ward.sightRange,ward.color)
					DrawCircle(ward.pos.x,ward.pos.y,ward.pos.z,ward.sightRange-10,ward.color)
				end
			end
            if GetDistance(ward.pos,{x=GetCursorWorldX(),y=GetCursorWorldY(),z=GetCursorWorldZ()}) < ward.triggerRange+30 then
                local wardText = nil
                if ward.type == "OnProcessSpell" then
                    wardText = ward.name.." :  "..math.floor(((ward.endTick-GetClock())/1000)+0.5)+1
                elseif ward.type == "OnCreateObj" then
                    wardText = ward.name.." :  "..math.floor(((ward.endTick-GetClock())/1000)+0.5)
                elseif ward.type == "OnLoad" then
                    wardText = ward.name.." :  "..math.floor(((ward.endTick-GetClock())/1000)+0.5)
                end
                if wardText ~= nil then
					if ward.team == myHero.team then
						textcolors = Color.Olive
					else textcolors = Color.Yellow
					end
                    DrawText(wardText,GetCursorX()-13,GetCursorY()-17,textcolors)
					if WardRevealer.ShowWardSight == false and ward.sight == true and ward.team ~= myHero.team then
						DrawCircle(ward.pos.x,ward.pos.y,ward.pos.z,ward.sightRange,ward.color)
						DrawCircle(ward.pos.x,ward.pos.y,ward.pos.z,ward.sightRange-10,ward.color)
					end
                end
            end
        end
    end
    
end

function OnCreateObj(object)
--	print(object.charName)
    local ward = GetWardInfo(object,"OnCreateObj")
    if ward ~= nil then
        table.insert(wards,ward)
    end
    if object.charName == "empty.troy" then
        for i,ward in ipairs(wards) do
            if GetDistance(ward.pos,object) < 10 then 
                table.remove(wards,i)
            end
        end
    elseif object.charName == "maoki_sapling_detonate.troy" then
        for i,ward in ipairs(wards) do
            if GetDistance(ward.pos,object) < 500 and ward.name == "Sapling" then 
                table.remove(wards,i)
            end
        end
    end
end

function OnProcessSpell(unit,spell)
    if unit ~= nil and spell ~= nil and IsHero(unit) then
        --printtext("\n"..spell.name)
        if spell.name == "SightWard" then
            local ward = {name="Sight Ward", team=unit.team, color=1, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+180000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
            table.insert(wards,ward)
        elseif spell.name == "VisionWard" then
            local ward = {name="Vision Ward", team=unit.team, color=4, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+300000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
            table.insert(wards,ward)
        elseif spell.name == "wrigglelantern" then
            local ward = {name="Wriggle's Lantern", team=unit.team, color=1, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+180000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
            table.insert(wards,ward)
        elseif spell.name == "ItemMiniWard" then
            local ward = {name="Explorer's Ward", team=unit.team, color=3, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+60000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
            table.insert(wards,ward)
        elseif spell.name == "ItemGhostWard" then
            local ward = {name="Ghost Ward", team=unit.team, color=1, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+180000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
            table.insert(wards,ward)
        elseif spell.name == "JackInTheBox" then
            local ward = {name="Jack In The Box", team=unit.team, color=2, sightRange=690, sight=true, triggerRange=300, endTick=GetClock()+60000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
            table.insert(wards,ward)
        elseif spell.name == "BantamTrap" then
            local ward = {name="Mushroom", team=unit.team, color=5, sightRange=405, sight=true, triggerRange=160, endTick=GetClock()+600000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
            table.insert(wards,ward)
        elseif spell.name == "RelicSmallLantern" then
            local ward = {name="Small Relic Lantern", team=unit.team, color=3, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+60000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
            table.insert(wards,ward)
        elseif spell.name == "RelicLantern" then
            local ward = {name="Relic Lantern", team=unit.team, color=3, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+120000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
            table.insert(wards,ward)
        elseif spell.name == "RelicGreaterLantern" then
            local ward = {name="Greater Relic Lantern", team=unit.team, color=1, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+180000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
            table.insert(wards,ward)
        elseif spell.name == "RelicVisionLantern" then
            local ward = {name="Relic Vision Lantern", team=unit.team, color=4, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+300000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
            table.insert(wards,ward)
        elseif spell.name == "Bushwhack" then
            local ward = {name="Bushwhack", team=unit.team, color=5, sightRange=90, sight=false, triggerRange=90, endTick=GetClock()+240000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
            table.insert(wards,ward)
        elseif spell.name == "ZyraSeed" then
            local ward = {name="Seed", team=unit.team, color=5, sightRange=350, sight=true, triggerRange=90, endTick=GetClock()+30000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
            table.insert(wards,ward)
        elseif spell.name == "CaitlynYordleTrap" then
            local ward = {name="Cupcake Yordle Trap", team=unit.team, color=5, sightRange=90, sight=false, triggerRange=90, endTick=GetClock()+30000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
            table.insert(wards,ward)
        else
            return
        end
    end
end

function GetWardInfo(object,type)
    if object ~= nil then
        if object.charName == "SightWard" then
			if object.name == "YellowTrinket" then
				return {name="Small Relic Lantern", team=object.team, color=3, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+object.mana*1000, type=type, pos={x=object.x,y=object.y,z=object.z}}
			elseif object.name == "YellowTrinketUpgrade" then
				return {name="Relic Lantern", team=object.team, color=3, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+object.mana*1000, type=type, pos={x=object.x,y=object.y,z=object.z}}
--			elseif object.name == "RelicGreaterLantern" then
--				return {name="Greater Relic Lantern", team=object.team, color=1, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+object.mana*1000, type=type, pos={x=object.x,y=object.y,z=object.z}}
--			elseif object.name == "RelicVisionLantern" then
--				return {name="Relic Vision Lantern", team=object.team, color=4, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+300000, type=type, pos={x=object.x,y=object.y,z=object.z}}
			else
				return {name="Sight Ward", team=object.team, color=1, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+object.mana*1000, type=type, pos={x=object.x,y=object.y,z=object.z}}
			end
        elseif object.charName == "VisionWard" then
			if object.name == "VisionWard" then
				return {name="Vision Ward", team=object.team, color=4, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+300000, type=type, pos={x=object.x,y=object.y,z=object.z}}
			elseif object.name == "SightWard" then
				if object.maxMana == 180 then
					return {name="Explorer's or Ghost Ward", team=object.team, color=1, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+object.mana*1000, type=type, pos={x=object.x,y=object.y,z=object.z}}
				elseif object.maxMana == 60 then
					return {name="Explorer's Ward", team=object.team, color=3, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+object.mana*1000, type=type, pos={x=object.x,y=object.y,z=object.z}}
				else
					return {name="Explorer's or Ghost Ward", team=object.team, color=1, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+object.mana*1000, type=type, pos={x=object.x,y=object.y,z=object.z}}
				end
			end
        elseif object.charName == "Jack In The Box" and object.name == "ShacoBox" then
            return {name="Jack In The Box", team=object.team, color=2, sightRange=690, sight=true, triggerRange=300, endTick=GetClock()+object.mana*1000, type=type, pos={x=object.x,y=object.y,z=object.z}}
        elseif object.charName == "Noxious Trap" and object.name == "TeemoMushroom" then
            return {name="Mushroom", team=object.team, color=5, sightRange=405, sight=true, triggerRange=160, endTick=GetClock()+object.mana*1000, type=type, pos={x=object.x,y=object.y,z=object.z}}
        elseif object.charName == "nidalee_trap_team_id_red.troy" then
            return {name="Bushwhack", team=TEAM_ENEMY, color=5, sightRange=90, sight=false, triggerRange=90, endTick=GetClock()+240000, type=type, pos={x=object.x,y=object.y,z=object.z}}
        elseif object.charName == "maokai_sapling_team_id_red.troy" then
            return {name="Sapling", team=TEAM_ENEMY, color=5, sightRange=650, sight=true, triggerRange=500, endTick=GetClock()+35000, type=type, pos={x=object.x,y=object.y,z=object.z}}
        elseif object.charName == "Zyra_seed_indicator_team_red.troy" then
            return {name="Seed", team=TEAM_ENEMY, color=5, sightRange=350, sight=true, triggerRange=90, endTick=GetClock()+30000, type=type, pos={x=object.x,y=object.y,z=object.z}}
        elseif object.charName == "caitlyn_yordleTrap_idle_red.troy" then
            return {name="Cupcake Yordle Trap", team=TEAM_ENEMY, team=myHero.team, color=5, sightRange=90, sight=false, triggerRange=90, endTick=GetClock()+240000, type=type, pos={x=object.x,y=object.y,z=object.z}}
        elseif object.charName == "nidalee_trap_team_id_green.troy" then
            return {name="Bushwhack", team=myHero.team, color=5, sightRange=90, sight=false, triggerRange=90, endTick=GetClock()+240000, type=type, pos={x=object.x,y=object.y,z=object.z}}
        elseif object.charName == "maokai_sapling_team_id_green.troy" then
            return {name="Sapling", team=myHero.team, color=5, sightRange=650, sight=true, triggerRange=500, endTick=GetClock()+35000, type=type, pos={x=object.x,y=object.y,z=object.z}}
        elseif object.charName == "Zyra_seed_indicator_team_green.troy" then
            return {name="Seed", team=myHero.team, color=5, sightRange=350, sight=true, triggerRange=90, endTick=GetClock()+30000, type=type, pos={x=object.x,y=object.y,z=object.z}}
        elseif object.charName == "caitlyn_yordleTrap_idle_green.troy" then
            return {name="Cupcake Yordle Trap", team=myHero.team, color=5, sightRange=90, sight=false, triggerRange=90, endTick=GetClock()+240000, type=type, pos={x=object.x,y=object.y,z=object.z}}
        end
    end
    return nil
end

function IsHero(unit)
    for i=1, objManager:GetMaxHeroes(), 1 do
        local hero = objManager:GetHero(i)
        if hero ~= nil and unit.team == hero.team and unit.charName == hero.charName then return true end
    end
end

SetTimerCallback("OnTick")