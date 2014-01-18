require "utils"
require "spell_damage"
	
local target

SyndraConfig = scriptConfig("Syndrabot", "Syndracombo")
SyndraConfig:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
SyndraConfig:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
SyndraConfig:addParam("movement", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)
SyndraConfig:addParam("QSteal", "Killsteal", SCRIPT_PARAM_ONOFF, true)
SyndraConfig:addParam("Draw", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
SyndraConfig:permaShow("Combo")
SyndraConfig:permaShow("Harass")

function SyndraRun()
	DrawText("SO MUCH POWA!", 105, 25, Color.Green)
	target = GetWeakEnemy('Magic',800)
	if SyndraConfig.Draw then OnDraw()
	end
	if SyndraConfig.QSteal then QSteal()
	end
	if SyndraConfig.movement and (SyndraConfig.Harass or SyndraConfig.Combo) and not target then
	MoveToMouse()
	end	
	
	if SyndraConfig.Harass then
		target = GetWeakEnemy('Magic',800)
		if target ~= nil then
		CustomCircle(100,4,1,target)	
		if CanCastSpell("Q") then CastSpellXYZ('Q',GetFireahead(target,2,16)) end
		if CanCastSpell("E") then CastSpellXYZ('E',GetFireahead(target,2,16)) end
		end
end
end

function OnCreateObj(obj)
	if SyndraConfig.Combo then														
		if target ~= nil then	
			CustomCircle(100,4,1,target)
			UseTargetItems(target)
			CastSummonerIgnite(target)
			if CanCastSpell("Q") then CastSpellXYZ('Q',GetFireahead(target,2,16)) end
			if CanCastSpell("E") then CastSpellXYZ('E',GetFireahead(target,2,16)) end
			if CanCastSpell("R") then CastSpellTarget("R",target) end
				if obj ~= nil then
					if string.find(obj.charName, "Syndra_DarkSphere") ~= nil then
					CastSpellXYZ("W",obj.x,0,obj.z)
					end
					if CanCastSpell("W") then CastSpellXYZ('W', GetFireahead(target,2,20)) end
					
				
    end
end
end
end

function QSteal()
	CastHotkey("SPELLQ:WEAKENEMY ONESPELLHIT=((spellq_level*40)+40+((player_ap*7)/10))")
end

function OnDraw()
		CustomCircle(800,4,3,myHero)
		target = GetWeakEnemy('MAGIC',800)
		if target ~= nil and GetDistance(myHero, target) < 800 then
			CustomCircle(100,4,1,target)
			end	
		for i = 1, objManager:GetMaxHeroes()  do
			local enemy = objManager:GetHero(i)
			if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) then
				local qdmg = getDmg("Q",enemy,myHero)*CanUseSpell("Q") 
				local wdmg = getDmg("W",enemy,myHero)*CanUseSpell("W")
				local edmg = getDmg("E",enemy,myHero)*CanUseSpell("E")
				local rdmg = getDmg("R",enemy,myHero)*CanUseSpell("R")
				if enemy.health < (qdmg+wdmg+edmg+rdmg) then 
					CustomCircle(200,4,3,enemy)	
				end
				if enemy.health < (qdmg+edmg) then    
					CustomCircle(150,4,2,enemy)	
				end	

		end
	end
end

SetTimerCallback("SyndraRun")