-- ###################################################################################################### --
-- #                                                                                                    # --
-- #                                         	 Val's WardJump											# --
-- #                                                                                                    # --
-- ###################################################################################################### --

require "Utils"
printtext("\nVal's WardJump\n")

local lastWard = 0
local Champs = {
	{name = "Katarina", slot = "E"},
	{name = "Jax", slot = "Q"},
	{name = "LeeSin", slot = "W"}
}
local Wards = {2044, 2049, 2045, 2043, 3154}

function JumpRun()
	if IsChatOpen() == 0 and JumpConfig.jump then jump() end
end

function OnCreateObj(obj)
	if IsChatOpen() == 0 and obj ~= nil then
		if GetTickCount() - lastWard < 3000 and string.find(obj.name, "Ward") ~= nil or string.find(obj.name, "WriggleLantern") ~= nil or string.find(obj.name, "Sightstone") ~= nil then
			for _, champ in pairs(Champs) do
				if myHero.name == champ.name then CastSpellTarget(champ.slot, obj) end
			end
		end
	end
end

function jump()
	for _, champ in pairs(Champs) do
		if myHero.name == champ.name then
			for _, ward in pairs(Wards) do
				if CanCastSpell(champ.slot) and GetInventorySlot(ward) ~= nil and GetTickCount() - lastWard > 3000 then
					local pos = getWardPos()
					UseItemLocation(ward, pos.x, 0, pos.z)
					lastWard = GetTickCount()
				end
			end
		end
	end
end

function getWardPos()
	local MousePos = Vector(mousePos.x, mousePos.y, mousePos.z)
	local HeroPos = Vector(myHero.x, myHero.y, myHero.z)
	return HeroPos + ( HeroPos - MousePos )*(-600/GetDistance(HeroPos, MousePos))
end

JumpConfig = scriptConfig('WardJump Config', 'jumpconfig')
JumpConfig:addParam('jump', 'WardJump', SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
JumpConfig:permaShow('jump')

SetTimerCallback('JumpRun')