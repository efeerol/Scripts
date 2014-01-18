require "Utils"
local target

LuxConfig = scriptConfig("Luxtastic", "hairyslux")
LuxConfig:addParam("combo", " Combo", SCRIPT_PARAM_ONKEYDOWN, false, 90)
LuxConfig:permaShow("combo")

local eTimer = 0
local jungle = {}
local junglePosition = {

{ name = "AncientGolem", team = TEAM_BLUE, location = { x = 3632, y = 0, z = 7600} },
{ name = "AncientGolem", team = TEAM_RED, location = Vector(10386,0,6811) },
{ name = "Dragon", team = 'NA', location = Vector(9459,0,4193) },
{ name = "BaronNashor", team = 'NA', location = Vector(834,0,305) },

}

function OnTick()
KS()
UpdatejungleTable()
target = GetWeakEnemy("MAGIC", 1200)
	if IsChatOpen() == 0 and LuxConfig.combo then
	if target ~= nil then
			UseAllItems(target)
			if CanCastSpell("Q") and GetDistance(target) < 1100 then
			CastSpellXYZ("Q",mousePos.x,0,mousePos.z) 
			AttackTarget(target) 
			end
	end
	end
end

function OnCreateObj(obj)
	if LuxConfig.combo and target ~= nil then
		if string.find(obj.charName,"LuxLightBinding") and GetDistance(target, obj) < 50 and GetDistance(myHero, target) < 1000 and GetClock() > eTimer then 
			CastSpellTarget("E",target)
			eTimer = GetClock() + 500
		end
		if string.find(obj.charName,"LuxLightStrike") and CanCastSpell("R") then
			CastSpellTarget("R",target)
		end
		if string.find(obj.charName,"LuxMaliceCannon") and CanCastSpell("E") and GetClock() > eTimer then
			CastSpellTarget("E",target)
		end
		
	end
	
end

function UpdatejungleTable()
	for i=1, objManager:GetMaxObjects(), 1 do
		object = objManager:GetObject(i)
			if object ~= nil then
				for i, x in ipairs(junglePosition) do
					if object.name == x.name then 
						if GetDistance(object,x.location) < 800 then
						local name = object.name
						local team = x.team
						 entry = CheckCreep(name,team) 
						if entry == nil then
							creep = { hero = object, name = object.name, team = x.team, death = 0, location = x.location }
							table.insert(jungle,creep)
							else 
							creep = { hero = object, name = object.name, team = x.team, death = 0, location = x.location}
							table.insert(jungle,creep)
						end
					end
				end
			end
		end
	end

end

	function CheckCreep(name,team)
    if #jungle > 0 then
        for i,enemy in ipairs(jungle) do
            if name == enemy.name and team == enemy.team then 
			table.remove(jungle,i)
			return enemy.name
		end
        end
    end
    return nil
end

function KS()
	if #jungle > 0 then
		for i, jungle in pairs(jungle) do
			if jungle.name == ("AncientGolem" or "Dragon" or "Baron") then
				if jungle.hero.dead == 0 and jungle.team ~= myHero.team and GetDistance(jungle.hero) < 3000 then
					if getDmg("R",jungle.hero,myHero) > jungle.hero.health then 
					CustomCircle(100,20,1,jungle.hero)
					CastSpellTarget("R",jungle.hero)
					end
				end

			end
		end
	end
end


SetTimerCallback("OnTick")