require "Utils"
require 'spell_damage'
print=printtext
printtext("\nZyra\n")
printtext("\nBy Malbert\n")
printtext("\nVersion 2.3\n")

local target
local target600
local ignitedamage
local Etimer=0
local modcounter=0


	ZyraConfig = scriptConfig('Zyra Config', 'Zyraconfig')
	
	ZyraConfig:addParam('combo', 'Burst Combo', SCRIPT_PARAM_ONKEYDOWN, false, 84)
	ZyraConfig:addParam('ult', 'Ult in Combo', SCRIPT_PARAM_ONKEYTOGGLE, true, 55)
	ZyraConfig:addParam("igniteks", "Ignite KillSteal", SCRIPT_PARAM_ONKEYTOGGLE, true, 119)
	ZyraConfig:permaShow('combo')
	ZyraConfig:permaShow("ult")
	ZyraConfig:permaShow("igniteks")
	
	
function Run()

	target = GetWeakEnemy('MAGIC',1500)
	target600 = GetWeakEnemy('MAGIC',600)

	if IsChatOpen() == 0 and ZyraConfig.combo then combo() end

	if ZyraConfig.igniteks then 
		if myHero.SummonerD == 'SummonerDot' then
			CastHotkey("F3 AUTO 100,INF SPELLD:WEAKENEMY ONESPELLHIT=((player_level*20)+50) RANGE=600 TRUE COOLDOWN TOGGLE")
		elseif myHero.SummonerF == 'SummonerDot' then
			CastHotkey("F3 AUTO 100,INF SPELLF:WEAKENEMY ONESPELLHIT=((player_level*20)+50) RANGE=600 TRUE COOLDOWN TOGGLE")
		else
		end		
	end
	
	
end	


function OnProcessSpell(unit, spell)
end







function OnCreateObj(obj)

	if target~=nil then
	if obj~=nil and ZyraConfig.combo then
	--printtext("\n1 " .. obj.charName .. "")
		if string.find(obj.charName,"Zyra_E_sequence_impact") and GetDistance(myHero, target) < 1300 and Etimer+5<os.clock() then
			Etimer=os.clock()
		elseif string.find(obj.charName,"Zyra_E_sequence_impact") and GetDistance(myHero, target) < 1300 and Etimer+5>os.clock() then
			CastSpellXYZ("W",target.x,0,target.z)	
		end
		
		if string.find(obj.charName,"Zyra_W_cas_02") and GetDistance(myHero, target) < 1300 then

				CastSpellXYZ("Q",target.x,0,target.z)			

		end		
		if string.find(obj.charName,"zyra_Q_cas") and GetDistance(myHero, target) < 1300 then
			if CanUseSpell('W')==1 then
				CastSpellXYZ("W",target.x,0,target.z)			
			end
		end
		if string.find(obj.charName,"seed") and GetDistance(myHero, target) < 1300 and ZyraConfig.ult then
				CastSpellXYZ("R",target.x,0,target.z)	
		end		
		if (string.find(obj.charName,"Zyra_ult_cas_target_center") or (string.find(obj.charName,"seed") and not ZyraConfig.ult)) and GetDistance(myHero, target) < 1300 then
			if GetMEC(550,800,target)~=nil then
				CastSpellXYZ("Q",GetMEC(550,800,target).x,GetMEC(550,800,target).y,GetMEC(550,800,target).z)
			else
				CastSpellXYZ("Q",target.x,target.y,target.z)	
			end		

		end		
		
	end
	
	end
end

function combo()
		if target600~=nil then
			UseAllItems(target)
		end
	if CanUseSpell('E')==1 then CastSpellXYZ("E",mousePos.x,0,mousePos.z) end
	if target~=nil then
	if CanUseSpell('Q')==1 then CastSpellXYZ("Q",target.x,0,target.z) end
	else
	MoveToMouse()
	end


		--if target600~=nil then
			--UseAllItems(target)
		--end
end




function OnDraw()

    if myHero.dead == 0 then
		if CanUseSpell('Q') == 1 then
			--CustomCircle(230,3,2,myHero)
		end	
		if CanUseSpell('R') == 1 then
			--CustomCircle(530,6,6,myHero)
		end
		if CanUseSpell('R') == 1 then
			CustomCircle(800,6,4,myHero)
		end
		if CanUseSpell('Q') == 1 or CanUseSpell('W') == 1 then
			CustomCircle(850,6,1,myHero)
		end
		if CanUseSpell('E') == 1 then
			CustomCircle(1100,6,5,myHero)
		end
    end
	
end



SetTimerCallback("Run")