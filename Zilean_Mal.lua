require "Utils"
require 'spell_damage'
print=printtext
printtext("\nZilean, an Old Fart\n")
printtext("\nBy Malbert\n")
printtext("\nVersion 4.6\n")


local target
local targetQharass
local startedQWQ=false
local ignitedamage
local Qdmgperlvl=0
local Off={name="Most AP and AD"}
local enemyult={Off}
	for i=1, objManager:GetMaxHeroes(), 1 do
		hero = objManager:GetHero(i)
		if hero~=nil and hero.team==myHero.team then
			table.insert(enemyult,hero)
		end
	end
	
local index = 1
local mhtarget

	ZilConfig = scriptConfig('Zil Config', 'Zilconfig')
	ZilConfig:addParam('teamfight', 'AutoTeamFight', SCRIPT_PARAM_ONKEYDOWN, false, 84)
	ZilConfig:addParam('qwq', 'QWQ Combo', SCRIPT_PARAM_ONKEYDOWN, false, 65)
	ZilConfig:addParam('Eself', 'EscapeESelf', SCRIPT_PARAM_ONKEYDOWN, false, 88)
	ZilConfig:addParam('autoQ', 'AutoQ', SCRIPT_PARAM_ONKEYTOGGLE, false, 56)
	ZilConfig:addParam('autoR', 'AutoR', SCRIPT_PARAM_ONKEYTOGGLE, true, 57)
	ZilConfig:addParam('chooseult', "Prioritize Ally to Ult", SCRIPT_PARAM_NUMERICUPDOWN, 1, 48,1,objManager:GetMaxHeroes()/2+1,1)
	ZilConfig:addParam('autoQMrange', 'AutoQLowMinionEnemyInR', SCRIPT_PARAM_ONKEYTOGGLE, true, 119)
	ZilConfig:addParam('dokillsteal', 'Killsteal', SCRIPT_PARAM_ONOFF, false)
	ZilConfig:permaShow('teamfight')
	ZilConfig:permaShow('autoQ')
	ZilConfig:permaShow('chooseult')
	ZilConfig:permaShow('autoQMrange')
	
function Run()





	target = GetWeakEnemy('MAGIC',1100,"NEARMOUSE")
	targetQharass = GetWeakEnemy('MAGIC',1200,"NEARMOUSE")
	ignite()
	
	----Qminion stuff
	local enemyMinions = GetEnemyMinions(MINION_SORT_HEALTH_ASC)
	if targetQharass~=nil and CanUseSpell('Q')==1 and CanUseSpell('W')==1 and startedQWQ==false then		
		for _, minion in pairs(enemyMinions) do
			if minion~=nil then QMD = CalcMagicDamage(minion, Qdmgperlvl) end
			if minion~=nil then
			if type(mhtarget) ~= "number" and mhtarget==nil and minion.health<QMD and GetDistance(minion,myHero)<750 and GetDistance(minion,targetQharass)<290 then
				mhtarget=minion
			elseif mhtarget~=nil and minion.health~=nil and minion.health<QMD and GetDistance(minion,myHero)<750 and GetDistance(minion,targetQharass)<290 and GetDistance(minion,targetQharass)<GetDistance(mhtarget,targetQharass)  then
				mhtarget=minion
			end
			end
		end
	end
	if ZilConfig.autoQMrange then 	
		if mhtarget~=nil and targetQharass~=nil and (myHero.mana>(50+2*(55+15*GetSpellLevel('Q'))) or startedQWQ==true) then
			if GetSpellLevel('Q')>0 and GetSpellLevel('W')>0 and (CanUseSpell('Q')==1 or CanUseSpell('W')==1) and GetDistance(mhtarget, myHero) < 740 then
				startedQWQ=true
				CastSpellTarget('Q',mhtarget)
				CastSpellTarget('W',mhtarget)
				CastSpellTarget('Q',mhtarget)
				
			end
		end 
	end
	
	if (not CanCastSpell('Q') and not CanCastSpell('W')) or mhtarget==nil or mhtarget.dead==1 then
		startedQWQ=false
	end
	
	
	
	
	if GetSpellLevel('Q')==1 then
		Qdmgperlvl=(90+myHero.ap*9/10)*CanUseSpell('Q')
	elseif GetSpellLevel('Q')==2 then
		Qdmgperlvl=(145+myHero.ap*9/10)*CanUseSpell('Q')
	elseif GetSpellLevel('Q')==3 then
		Qdmgperlvl=(200+myHero.ap*9/10)*CanUseSpell('Q')
	elseif GetSpellLevel('Q')==4 then
		Qdmgperlvl=(260+myHero.ap*9/10)*CanUseSpell('Q')
	elseif GetSpellLevel('Q')==5 then
		Qdmgperlvl=(320+myHero.ap*9/10)*CanUseSpell('Q')
	else
		Qdmgperlvl=0
	end
	if ZilConfig.chooseult==1 then index=1 end
	if ZilConfig.chooseult==2 then index=2 end
	if ZilConfig.chooseult==3 then index=3 end
	if ZilConfig.chooseult==4 then index=4 end
	if ZilConfig.chooseult==5 then index=5 end
	if ZilConfig.chooseult==6 then index=6 end

	if IsChatOpen()==0 and ZilConfig.teamfight then teamfight() end
	if IsChatOpen()==0 and ZilConfig.qwq then Q(target) end
	if ZilConfig.autoQ then autoQ() end
	if IsChatOpen()==0 and ZilConfig.Eself then Eself() end
	if ZilConfig.autoR then autoR() end
	if ZilConfig.dokillsteal then killsteal() end
	
end

function teamfight()
	if target~=nil and GetDistance(target,myHero)<700 then
		UseAllItems(target)
		CastSpellTarget('Q',target)
		CastSpellTarget('E',target)
		autoR()
		CastSpellTarget('W',target)
		CastSpellTarget('Q',target)
		AttackTarget(target)
	else
		MoveToMouse()
	end
end

function Q(tar)
	if tar~=nil and GetDistance(tar)<700 then
		CastSpellTarget('Q',tar)
		CastSpellTarget('W',tar)
		CastSpellTarget('Q',tar)
	else
		MoveToMouse()
	end
end

function autoQ()
	if target~=nil and GetDistance(target)<700 then
		CastSpellTarget('Q',target)
		CastSpellTarget('W',target)
		CastSpellTarget('Q',target)
	end
end

function Eself()
		CastSpellTarget('E',myHero)
		MoveToMouse()
end

function autoR()
	local enemies={}
	local allies={}
	local allytarget=nil
	for i=1, objManager:GetMaxHeroes(), 1 do
		hero = objManager:GetHero(i)
		if hero~=nil and hero.team==myHero.team and hero.dead~=1 and GetDistance(hero,myHero)<780 then
			table.insert(allies,hero)
		elseif hero~=nil and hero.team~=myHero.team and hero.dead~=1 then
			table.insert(enemies,hero)
		end
	end

	for i,ally4R in ipairs(allies) do
		if ally4R~=nil and ally4R.dead~=1 then
			for j,EIR in ipairs(enemies) do
				if EIR~=nil and EIR.dead~=1 then
					if ally4R~=nil and ally4R.dead~=1 and (allytarget==nil or allytarget.dead==0) and ((ally4R.health<(2/10*hero.maxHealth) and GetDistance(ally4R,EIR)<650) or (ally4R.health<(1/10*hero.maxHealth) and GetDistance(ally4R,EIR)<750)) then
						allytarget=ally4R
					elseif ally4R~=nil and ally4R.dead~=1  and allytarget~=nil and allytarget.dead~=1 and ((ally4R.health<(2/10*hero.maxHealth) and GetDistance(ally4R,EIR)<650) or (ally4R.health<(1/10*hero.maxHealth) and GetDistance(ally4R,EIR)<750)) and allytarget.ap+allytarget.addDamage+allytarget.baseDamage<ally4R.ap+ally4R.addDamage+ally4R.baseDamage then
						allytarget=ally4R	
					end
				end
			end
		end
	end
	if index~=1 then
		for j,EIR in ipairs(enemies) do
			if EIR~=nil and EIR.dead~=1 then
				if enemyult[index]~=nil and enemyult[index].dead~=1 and ((enemyult[index].health<(2/10*enemyult[index].maxHealth) and GetDistance(enemyult[index],EIR)<650) or (enemyult[index].health<(1/10*enemyult[index].maxHealth) and GetDistance(enemyult[index],EIR)<750)) then
					allytarget=enemyult[index]
				end
			end
		end
	end
	
	if allytarget~=nil and allytarget.dead~=1 and CanUseSpell('R')==1 then
		CastSpellTarget('R',allytarget)
	end
end





function ignite()
		if myHero.SummonerD == 'SummonerDot' then
			ignitedamage = ((myHero.selflevel*20)+50)*CanUseSpell('D')
		elseif myHero.SummonerF == 'SummonerDot' then
				ignitedamage = ((myHero.selflevel*20)+50)*CanUseSpell('F')
		else
				ignitedamage=0
		end
end

function killsteal()
	if target~=nil and target.dead~=1 then
		local Q = CalcMagicDamage(target,Qdmgperlvl)
		local AA = getDmg("AD",target,myHero)
		if target.health<(Q+AA+Q+ignitedamage)*CanUseSpell('W') and GetDistance(myHero, target) < 700 then
			CastSpellTarget('Q',target)	
			CastSpellTarget('W',target)
			CastSpellTarget('Q',target)	
			CastSpellTarget('E',target)	
			AttackTarget(target)
			if ignitedamage~=0 then CastSummonerIgnite(target) end
		end
		if target.health<(Q+AA+ignitedamage) and GetDistance(myHero, target) < 700 then
			CastSpellTarget('Q',target)
			AttackTarget(target)
			if ignitedamage~=0 then CastSummonerIgnite(target) end
		end

	end
end

function OnDraw()
    if myHero.dead == 0 then
		local QWQmarker = ((50+2*(55+15*GetSpellLevel('Q')))/myHero.maxMana) *(0.24375)*GetScreenX()
		local positionText=(15/900)*GetScreenY()
		for i = 1, objManager:GetMaxHeroes()/2+1, 1 do
			if i ==index and enemyult[i]~=nil then
				DrawText("Priority Ult: ".. enemyult[i].name .. "", 1/16*GetScreenX(), positionText*i, Color.Coral)
			elseif i~=index and enemyult[i]~=nil then
				DrawText("Priority Ult: ".. enemyult[i].name .. "", 1/16*GetScreenX(), positionText*i, Color.White)
			end
		end
		
		if CanUseSpell('Q') == 1 then
			CustomCircle(700,3,3,myHero)
			if CanUseSpell('W')==1 then
				CustomCircle(1030,3,1,myHero)
			end
		end
		if targetQharass~=nil and targetQharass.dead~=1 then
				CustomCircle(290,6,2,targetQharass)
		end
		if QWQmarker~=nil then
			if CanUseSpell('Q') == 1 or CanUseSpell('W') == 1 then
				DrawBox(GetScreenX()-(0.6125)*GetScreenX()+QWQmarker,GetScreenY()-(25/900)*GetScreenY(),8,17,Color.Blue)
			end	
	
		end
	end
end



SetTimerCallback("Run")