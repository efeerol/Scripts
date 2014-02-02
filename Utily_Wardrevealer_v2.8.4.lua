--[[
    Script: IGER's WardRevealer v2.8.4
    Author: PedobearIGER and Lua
]]--
require 'Utils'
local uiconfig = require 'uiconfig'
local wards = {}

	WardRevealer, menu = uiconfig.add_menu('WardRevealer Config', 250)
	menu.keytoggle('ShowWardSight', 'Show Ward Sight', Keys.I, true)
	menu.checkbutton('ZyraSeedSight', 'Show Zyra Seeds Sight', true)
	menu.slider('BuffRange', 'Buff Range', 1, 4, 1, {'ALL', 'Alied Only', 'Enemy Only', 'OFF'})
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
		local triggerRange = ward.triggerRange
		if ward.name ~= "Demacia Flag" then
			if ward.team ~= myHero.team then DrawCircle(ward.pos.x,ward.pos.y,ward.pos.z,triggerRange,ward.color) end
		elseif ward.team == myHero.team and WardRevealer.BuffRange <= 2 then
			DrawCircle(ward.pos.x,ward.pos.y,ward.pos.z,triggerRange,3)
		elseif ward.team ~= myHero.team and WardRevealer.BuffRange ~= 2 and WardRevealer.BuffRange ~= 4 then
			DrawCircle(ward.pos.x,ward.pos.y,ward.pos.z,triggerRange,ward.color)
		end
		if WardRevealer.ShowWardSight == true and ward.sight == true and myHero.team ~= ward.team then
			DrawCircle(ward.pos.x,ward.pos.y,ward.pos.z,ward.sightRange,ward.color)
			DrawCircle(ward.pos.x,ward.pos.y,ward.pos.z,ward.sightRange-10,ward.color)
		end
		if triggerRange > 120 then triggerRange = 120 end
		if GetDistance(ward.pos,{x=GetCursorWorldX(),y=GetCursorWorldY(),z=GetCursorWorldZ()}) < triggerRange+30 then
        	        local wardText = nil
        	        if ward.type == "OnProcessSpell" then
				wardText = ward.name.."  ("..math.floor(((ward.endTick-GetClock())/1000)+0.5)+1
			elseif ward.type == "OnCreateObj" then
				wardText = ward.name.."  ("..math.floor(((ward.endTick-GetClock())/1000)+0.5)
			elseif ward.type == "OnLoad" then
 				wardText = ward.name.."  ("..math.floor(((ward.endTick-GetClock())/1000)+0.5)
			end
			wardText = wardText..")"
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
    elseif object.charName == "nidalee_bushwhack_trigger_01.troy" or object.charName == "nidalee_bushwhack_trigger_02.troy" then
        for i,ward in ipairs(wards) do
            if GetDistance(ward.pos,object) < 40 and ward.name == "Bushwhack" then 
                table.remove(wards,i)
            end
        end
    elseif object.charName == "caitlyn_yordleTrap_trigger_01.troy" or object.charName == "caitlyn_yordleTrap_trigger_02.troy" then
        for i,ward in ipairs(wards) do
            if GetDistance(ward.pos,object) < 40 and ward.name == "Cupcake Yordle Trap" then 
                table.remove(wards,i)
            end
        end
    elseif object.charName == "ShroomMine.troy" then
        for i,ward in ipairs(wards) do
            if GetDistance(ward.pos,object) < 40 and ward.name == "Mushroom" then 
                table.remove(wards,i)
            end
        end
    elseif object.charName == "Zyra_w_seedTrap_trigger.troy" then
        for i,ward in ipairs(wards) do
            if GetDistance(ward.pos,object) < 40 and ward.name == "Seed" then 
                table.remove(wards,i)
            end
        end
    elseif object.charName == "maoki_sapling_detonate.troy" then
        for i,ward in ipairs(wards) do
            if GetDistance(ward.pos,object) < 650 and ward.name == "Sapling" then 
                table.remove(wards,i)
            end
        end
    end
end

function OnProcessSpell(unit,spell)
	--printtext("\n"..spell.name)
    if unit ~= nil and spell ~= nil and IsHero(unit) and unit.team ~= myHero.team then
        if spell.name == "SightWard" then
            local ward = {name="Sight Ward", team=unit.team, color=1, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+180000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
            table.insert(wards,ward)
        elseif spell.name == "VisionWard" then
            local ward = {name="Vision Ward", team=unit.team, color=4, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+300000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
            table.insert(wards,ward)
        elseif spell.name == "wrigglelantern" then
            local ward = {name="Wriggle's Lantern", team=unit.team, color=1, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+180000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
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
            local seedsight = true
            if WardRevealer.ZyraSeedSight == false then seedsight = false end
            local ward = {name="Seed", team=unit.team, color=5, sightRange=350, sight=seedsight, triggerRange=90, endTick=GetClock()+30000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
            table.insert(wards,ward)
        elseif spell.name == "CaitlynYordleTrap" then
            local ward = {name="Cupcake Yordle Trap", team=unit.team, color=5, sightRange=90, sight=false, triggerRange=90, endTick=GetClock()+30000, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
            table.insert(wards,ward)
        elseif spell.name == "JarvanIVDemacianStandard" then
            local ward = {name="Demacia Flag", team=unit.team, color=5, sightRange=580, sight=true, triggerRange=1020, endTick=GetClock()+8500, type="OnProcessSpell", pos={x=spell.endPos.x,y=spell.endPos.y,z=spell.endPos.z}}
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
			elseif object.name == "RelicGreaterLantern" then
				return {name="Greater Relic Lantern", team=object.team, color=1, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+object.mana*1000, type=type, pos={x=object.x,y=object.y,z=object.z}}
			elseif object.name == "RelicVisionLantern" then
				return {name="Relic Vision Lantern", team=object.team, color=4, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+object.mana*1000, type=type, pos={x=object.x,y=object.y,z=object.z}}
			else
				return {name="Sight Ward", team=object.team, color=1, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+object.mana*1000, type=type, pos={x=object.x,y=object.y,z=object.z}}
			end
        elseif object.charName == "VisionWard" then
			if object.name == "SightWard" then
				return {name="Sight Ward", team=object.team, color=1, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+object.mana*1000, type=type, pos={x=object.x,y=object.y,z=object.z}}
			else
				return {name="Vision Ward", team=object.team, color=4, sightRange=1350, sight=true, triggerRange=70, endTick=GetClock()+300000, type=type, pos={x=object.x,y=object.y,z=object.z}}
			end
        elseif object.charName == "Jack In The Box" and object.name == "ShacoBox" then
            return {name="Jack In The Box", team=object.team, color=2, sightRange=690, sight=true, triggerRange=300, endTick=GetClock()+object.mana*1000, type=type, pos={x=object.x,y=object.y,z=object.z}}
        elseif object.charName == "Noxious Trap" then
			if object.name == "TeemoMushroom" then
				return {name="Mushroom", team=object.team, color=5, sightRange=405, sight=true, triggerRange=160, endTick=GetClock()+object.mana*1000, type=type, pos={x=object.x,y=object.y,z=object.z}}
			elseif object.name == "Nidalee_Spear" then
				return {name="Bushwhack", team=object.team, color=5, sightRange=90, sight=false, triggerRange=90, endTick=GetClock()+240000, type=type, pos={x=object.x,y=object.y,z=object.z}}
			end
        elseif object.charName == "DoABarrelRoll" and object.name == "MaokaiSproutling" then
            return {name="Sapling", team=object.team, color=5, sightRange=650, sight=true, triggerRange=500, endTick=GetClock()+35000, type=type, pos={x=object.x,y=object.y,z=object.z}}
        elseif object.charName == "Seed" and object.name == "ZyraSeed" then
            local seedsight = true
            if WardRevealer.ZyraSeedSight == false then seedsight = false end
            return {name="Seed", team=object.team, color=5, sightRange=350, sight=seedsight, triggerRange=90, endTick=GetClock()+30000, type=type, pos={x=object.x,y=object.y,z=object.z}}
        elseif object.charName == "Cupcake Trap" and object.name == "CaitlynTrap" then
           return {name="Cupcake Yordle Trap", team=object.team, color=5, sightRange=90, sight=false, triggerRange=90, endTick=GetClock()+240000, type=type, pos={x=object.x,y=object.y,z=object.z}}
        elseif object.charName == "Beacon" and object.name == "JarvanIVStandard" then
            return {name="Demacia Flag", team=object.team, color=5, sightRange=580, sight=true, triggerRange=1020, endTick=GetClock()+8000, type=type, pos={x=object.x,y=object.y,z=object.z}}
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