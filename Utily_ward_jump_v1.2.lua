--Lua's Yet Another WardJump v1.2

require "Utils"
local uiconfig = require "uiconfig"
if GetMap() ~= 1 then return end

local SightStone = 0
local RedResetZone = {x=13945, y=185, z=14190}
local BlueResetZone = {x=27, y=185, z=265}
local ResetRange = 600
local lastWard = GetTickCount()
local jumping = true
local ward = nil
local Spot = {x=0, y=0, z=0}
local WardOrders = {3340, 3350, 3154, 3361, 2049, 2045, 2044, 3362, 2043}

local Wards = {3340, 3350, 3154, 3361, 2049, 2045, 2044, 3362, 2043} --Normal ward items order with Totems
local WardsWithoutTotems = {3154, 2049, 2045, 2044, 2043} --Without Totems, use it if you have problems with Totems
--[[
2043, Vision Ward
2044, Sight Ward
2045, Ruby Sightstone
2049, Sightstone
2050, Explorer's Ward (Removed)
3154, Wriggle's Lantern
3340, Warding Totem (60s/3 max) (lv 0)
3350, Greater Totem (120s/3 max) (lv 9)
3361, Greater Stealth Totem (180s/3 max) (lv 9+purchase)
3362, Graeter Vision Totem (--s/1 max) (lv 9+purchase)
]]--

local wardjump = {champ = nil, slot = nil, cost = nil}
local Champs = {
	{name = "Katarina", slot = "E", cost = 0},
	{name = "Jax", slot = "Q", cost = 65},
	{name = "LeeSin", slot = "W", cost = 50}
}
for _, champ in pairs(Champs) do
	if myHero.name == champ.name then
		wardjump.champ = champ.name
		wardjump.slot = champ.slot
		wardjump.cost = champ.cost
		wardjump.hotkey = champ.hotkey
		JumpConfig, menu = uiconfig.add_menu('WardJump')
		menu.keydown('jump', 'WardJump - '..champ.name, Keys.T)
		menu.checkbox('SSCount', 'Shows SightStones Count', true)
		menu.checkbox('SpotCircle', 'Shows Wardjump Spot', true)
		menu.slider('Totems', 'With Totems', 0, 1, 1, {'ON'})
		menu.label('TotemsInfo', 'Turn OFF If Cannot Wardjumping with Totems') 
		menu.permashow('jump')
	end
end
if wardjump.champ == nil then
	print('No More Jumps ._.')
	return
end
function JumpingAround()
	if tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client" and IsChatOpen() == 0 then
--		DrawCircle(RedResetZone.x,RedResetZone.y,RedResetZone.z,ResetRange,3) --Reset Range Circle
--		DrawCircle(BlueResetZone.x,BlueResetZone.y,BlueResetZone.z,ResetRange,3) --Reset Range Circle
		if myHero.team == 100 and myHero.dead == 0 and GetDistance(myHero, BlueResetZone) <= ResetRange then
			if GetInventorySlot(2045) ~= nil then SightStone = 5
			elseif GetInventorySlot(2049) ~= nil then SightStone = 4 end
		elseif myHero.team == 200 and myHero.dead == 0 and GetDistance(myHero, RedResetZone) <= ResetRange and (GetInventorySlot(2045) ~= nil or GetInventorySlot(2049) ~= nil) then
			if GetInventorySlot(2045) ~= nil then SightStone = 5
			elseif GetInventorySlot(2049) ~= nil then SightStone = 4 end
		end
		if ward ~= nil and not jumpng and myHero.SpellNameW ~= "blindmonkwtwo" then CastSpellTarget(wardjump.slot, ward) end
		if JumpConfig.SpotCircle and Spot.x ~= 0 and GetTickCount()-lastWard < 5000 then DrawCircle(Spot.x,Spot.y,Spot.z,150,3) end
		if JumpConfig.jump then WardJump() end
		if JumpConfig.SSCount and (GetInventorySlot(2045) ~= nil or GetInventorySlot(2049) ~= nil) then
			if SightStone > 0 then DrawTextObject("\n\n"..SightStone,myHero,Color.White)
			else DrawTextObject("\n\n"..SightStone,myHero,Color.Red) end
		end
		if myHero.dead == 1 or myHero.mana < wardjump.cost or myHero["SpellTime"..wardjump.slot] < 1 or myHero.SpellNameW == "blindmonkwtwo" or GetTickCount()-lastWard > 5000 then
			ward = nil
			jumping = true
		end
	end
end

function OnCreateObj(obj)
	if obj ~= nil and not jumping and string.find(obj.charName, "Ward") ~= nil and myHero.SpellNameW ~= "blindmonkwtwo" then
		Spot.x = 0
		ward = obj
		CastSpellTarget(wardjump.slot, obj)
	end
end

function WardJump()
	if myHero["SpellTime"..wardjump.slot] >= 1 and GetSpellLevel(wardjump.slot) > 0 and myHero.mana >= wardjump.cost and myHero.SpellNameW ~= "blindmonkwtwo" then
	if JumpConfig.Totems == 1 then WardOrders = Wards
	else WardOrders = WardsWithoutTotems end
		for _, ward in ipairs(WardOrders) do
			local wardSlot = GetWardSlot(ward)
			 if GetTickCount()-lastWard > 1000 and ward ~= 2045 and ward ~= 2049 and wardSlot ~= nil then
			--	print("Ward: "..ward, os.clock())
				CastSpellXYZ(wardSlot, mousePos.x, 0, mousePos.z)
				Spot.x, Spot.y, Spot.z = mousePos.x, mousePos.y, mousePos.z
				jumping = false
				lastWard = GetTickCount()
			elseif SightStone > 0 and GetTickCount()-lastWard > 1000 and wardSlot ~= nil and (ward == 2045 or ward == 2049) then
			--	print("SightStone: "..ward, os.clock())
				CastSpellXYZ(wardSlot, mousePos.x, 0, mousePos.z)
				Spot.x, Spot.y, Spot.z = mousePos.x, mousePos.y, mousePos.z
				jumping = false
				lastWard = GetTickCount()
			end
		end
		if jumping then DrawTextObject('\nNO WARDS',myHero,Color.SkyBlue) end
	elseif GetSpellLevel(wardjump.slot) == 0 then DrawTextObject('\nNO SPELL',myHero,Color.SkyBlue)
	elseif GetTickCount()-lastWard > 1500 and (myHero["SpellTime"..wardjump.slot] < 1 or myHero.SpellNameW == "blindmonkwtwo") then DrawTextObject('\nON COOLDOWN',myHero,Color.SkyBlue)
	elseif myHero.mana < wardjump.cost then DrawTextObject('\nNO MANA',myHero,Color.SkyBlue)
	end
end

function OnProcessSpell(unit, spell)
	--ItemGhostWard --Sightstone
	--VisionWard
	--ItemGhostWard --RubySighstone
	--RelicSmallLantern --Relic Lantern
	--RelicGreaterLantern --9lv normal ward
	--RelicVisionLantern --9lv vision ward
	--wrigglelantern --Lantern
	if unit ~= nil and spell ~= nil and unit.team == myHero.team and unit.name == myHero.name then
		if spell.name == myHero["SpellName"..wardjump.slot] and not jumping and ward ~= nil then
			jumping = true
			ward = nil
		elseif spell.name == 'ItemGhostWard' then
			SightStone = SightStone-1
			if SightStone < 0 then SightStone = 0 end
		end
	end
end

function GetWardSlot(item)
	for i=1,7 do
		if GetInventoryItem(i) == item and myHero["SpellTime"..i] >= 1 then
			return tostring(i)
		end
	end
	return nil
end

SetTimerCallback('JumpingAround')