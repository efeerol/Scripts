require "Utils"

ShieldConfig = scriptConfig("Shieldbot", "Shieldcombo")
ShieldConfig:addParam("shield", "Use Autoshield", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("J"))
ShieldConfig:addParam("print", "Print to txt file", SCRIPT_PARAM_ONOFF, true)

--These are the heroes that can shield
local shields = { 
{charName = "Janna", blockTypes={"Stun","Slow","Silence","Damage"}, target = {"Self","Ally"}, shieldKey = "E", range=800},
{charName = "Nocturne", blockTypes={"Stun","Slow","Silence","Damage"}, target = {"Self"}, shieldKey = "W", range = 10},
{charName = "Morgana", blockTypes={"Stun","Slow","Silence","Damage","Fear"}, target = {"Self","Ally"}, shieldKey = "E" range = 750},
{charName = "Sivir", blockTypes={"Stun","Slow","Silence","Damage","Fear"}, target = {"Self"}, shieldKey = "E" range = 10},
}

local spells = {
{charName = "Taric", spellName = "TaricStun", spellType = "Stun"},
{charName = "Taric", spellName = "TaricStun", spellType = "Stun"},
{charName = "Taric", spellName = "TaricStun", spellType = "Stun"},
{charName = "Taric", spellName = "TaricStun", spellType = "Stun"},
{charName = "Taric", spellName = "TaricStun", spellType = "Stun"},
{charName = "Taric", spellName = "TaricStun", spellType = "Stun"},
}

--This checks for whether we are a champ that can use a shield
local shieldInfo = nil
for _, shield in pairs(shields) do
    if myHero.name == shield.charName then
    shieldInfo = shield
    end
end



function OnProcessSpell(object,spell)
if ShieldConfig.shield then
--This will print a list of spells used by everyone over the course of a game
if ShieldConfig.print then
if spell.target ~= nil then
f = io.open("./spelltarget.txt", "a")
f:write("charName = '"..object.charName.."' spellName = '"..spell.name.."' spellType = XXXX\n")
f:close() end
else 
f = io.open("./spellNontarget.txt", "a")
f:write("charName = '"..object.charName.."' spellName = '"..spell.name.."' spellType = 'Skillshot'\n")
f:close()
end

end
end