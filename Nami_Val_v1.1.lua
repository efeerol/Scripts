require 'Utils'
require 'winapi'
require 'SKeys'
require 'vals_lib'
local Q,W,E,R = 'Q','W','E','R'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local version = '1.1'

function Main()
	if IsLolActive() then
		target = GetWeakEnemy('MAGIC',725)
		target2 = GetWeakEnemy('MAGIC',875)
		GetCD()
		GetAlly()
		GetEnemy()
		if QRDY == 0 then Slowenemy = nil end
		if NamiConfig.AutoQ then
			Bullseye(Q,850)
			Qspell() 
		end
		if NamiConfig.AutoW then Wspell() end
	end
end

	NamiConfig, menu = uiconfig.add_menu('Nami Config', 200)
	menu.checkbutton('AutoQ', 'AutoQ', true)
	menu.checkbutton('AutoW', 'AutoW', false)
	menu.checkbutton('AutoE', 'AutoE', true)
	menu.checkbutton('drawcircles', 'Draw Circles', true)
	menu.permashow('AutoQ')
	menu.permashow('AutoW')
	menu.permashow('AutoE')
	
function GetAlly()
	ALLY = nil
	for i = 1, objManager:GetMaxHeroes() do
		local ally = objManager:GetHero(i)
		if (ally ~= nil and ally.team == myHero.team and ally.visible == 1 and ally.dead==0) and GetDistance(ally)<725 then
			ALLY = ally
		end
	end
end

function GetEnemy()
	ENEMY = nil
	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0 and enemy.dead==0) and GetDistance(enemy)<725*2 then
			ENEMY = enemy
		end
	end
end

function Qspell()
	if Slowenemy~=nil then SpellPred(Q,QRDY,myHero,Slowenemy,800,1.6,10) end
end

function Wspell()
	if ALLY~=nil and ENEMY~=nil then
		CustomCircle(75,5,3,ALLY)
		CustomCircle(75,5,4,ENEMY)
		if GetDistance(ALLY)<725 and GetDistance(ALLY,ENEMY)<725 then
			SpellTarget(W,WRDY,myHero,ALLY,725)
		end
	end
end

function OnProcessSpell(unit,spell)
	if unit ~= nil and spell ~= nil and unit.team == myHero.team then
		if NamiConfig.AutoE then
			for i = 1, objManager:GetMaxHeroes() do
				local enemy = objManager:GetHero(i)
				if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0 and enemy.dead==0 and
					enemy.name~='Blue_Minion_Basic' and enemy.name~='Blue_Minion_Wizard' and enemy.name~='Blue_Minion_MechCannon' and 
					enemy.name~='Blue_Minion_MechMelee' and enemy.name~='Odin_Blue_Minion_Caster' and enemy.name~='OdinBlueSuperminion' and 
					enemy.name~='Red_Minion_Basic' and enemy.name~='Red_Minion_Wizard' and enemy.name~='Red_Minion_MechCannon' and 
					enemy.name~='Red_Minion_MechMelee' and enemy.name~='Odin_Red_Minion_Caster' and enemy.name~='OdinRedSuperminion') then
					if (string.find(spell.name,'attack') or string.find(spell.name,'Attack')) and spell.target~=nil and spell.target.name == enemy.name and ERDY==1 and GetDistance(unit)<800 then
						CastSpellTarget(E,unit)
					end
				end
			end
		end
	end
end

function OnCreateObj(obj)
	if obj~=nil then
		for i = 1, objManager:GetMaxHeroes() do
			local enemy = objManager:GetHero(i)
			if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0 and enemy.dead==0) then
				if (enemy~=nil and GetDistance(enemy)<800) then
					if obj.charName=='GLOBAL_SLOW.troy' and GetDistance(enemy,obj)<50 then Slowenemy = enemy
					elseif obj.charName=='Global_Slow.troy' and GetDistance(enemy,obj)<50 then Slowenemy = enemy
					end
				end
			end
		end
	end
end

function OnDraw()
	if myHero.dead==0 then
		if NamiConfig.drawcircles then
			if QRDY == 1 then
				CustomCircle(875,1,2,myHero)
			end
			if WRDY==1 then
				CustomCircle(725,1,1,myHero)
			end
			if target ~= nil then
				CustomCircle(75,5,5,target)
			end
		end
	end
end

function Bullseye(spellslot,Range)
    local spells2={}
    local a2={GetCastSpell()}    
    local g2=0
    while (a2~=nil and a2[1] ~= nil and g2<200) do
        local spell2={}
        local startPos2={}
        local endPos2={}
        spell2.unit=a2[1]
        spell2.name=a2[2]
        startPos2.x=a2[3]
        startPos2.y=a2[4]
        startPos2.z=a2[5]
        endPos2.x=a2[6]
        endPos2.y=a2[7]
        endPos2.z=a2[8]
        spell2.target=a2[12]
        spell2.startPos2=startPos2
        spell2.endPos=endPos2
        table.insert(spells2, spell2)
        a2={GetCastSpell()}
        g2=g2+1
		if unit ~= nil and spell2 ~= nil and unit.team ~= myHero.team then
			for i = 1, objManager:GetMaxHeroes() do
				local champ = objManager:GetHero(i)
				if (champ ~= nil and champ.visible == 1 and champ.dead == 0) then
				-- Target Gapcloser
					if (spell2.name == 'AkaliShadowDance' or
						spell2.name == 'Headbutt' or
						spell2.name == 'DariusExecute' or
						spell2.name == 'DianaTeleport' or
						spell2.name == 'EliseSpiderQCast' or
						spell2.name == 'FioraQ' or
						spell2.name == 'Urchin Strike' or
						spell2.name == 'IreliaGatotsu' or
						spell2.name == 'JarvanIVCataclysm' or
						spell2.name == 'JaxLeapStrike' or
						spell2.name == 'JayceToTheSkies' or
						spell2.name == 'blindmonkqtwo' or
						spell2.name == 'BlindMonkWOne' or
						spell2.name == 'MaokaiUnstableGrowth' or
						spell2.name == 'AlphaStrike' or
						spell2.name == 'NocturneParanoia' or
						spell2.name == 'Pantheon_LeapBash' or
						spell2.name == 'MonkeyKingNimbus' or
						spell2.name == 'XenZhaoSweep' or
						spell2.name == 'ViR' or
						spell2.name == 'YasuoDashWrapper' or
						spell2.name == 'TalonCutthroat' or
						spell2.name == 'KatarinaE' or
						spell2.name == 'InfiniteDuress') and 
						spell2.target~=nil and spell2.target.name == champ.name and GetDistance(champ)<Range then
						CastSpellXYZ(spellslot,champ.x,0,champ.z)
					end
				end
			end
			-- No target dashes	
			if spell2.name == 'AatroxQ' then range = 650 end
			if spell2.name == 'AhriTumble' then range = 550 end
			if spell2.name == 'CarpetBomb' then range = 800 end
			if spell2.name == 'GragasBodySlam' then range = 600 end
			if spell2.name == 'GravesMove' then range = 425 end
			if spell2.name == 'LucianE' then range = 425 end
			if spell2.name == 'RenektonSliceAndDice' then range = 450 end
			if spell2.name == 'SejuaniArcticAssault' then range = 650 end
			if spell2.name == 'ShenShadowDash' then range = 600 end
			if spell2.name == 'ShyvanaTransformCast' then range = 1000 end
			if spell2.name == 'slashCast' then range = 660 end
			if spell2.name == 'ViQ' then range = 725 end
			if spell2.name == 'FizzJump' then range = 400 end
			if spell2.name == 'HecarimUlt' then range = 1000 end
			if spell2.name == 'KhazixE' then range = 600 end
			if spell2.name == 'khazixelong' then range = 900 end
			if spell2.name == 'LeblancSlide' then range = 600 end
			if spell2.name == 'LeblancSlideM' then range = 600 end
			if spell2.name == 'UFSlash' then range = 1000 end
			if spell2.name == 'Pounce' then range = 375 end
			if spell2.name == 'Deceive' then range = 400 end
			if spell2.name == 'ZacE' and unit.name == 'Zac' then range = (unit.SpellLevelE*100)+1050 end
			if spell2.name == 'VayneTumble' then range = 300 end
			if spell2.name == 'RivenTriCleave' then range = 260 end
			if spell2.name == 'RivenFeint' then range = 325 end
			if spell2.name == 'EzrealArcaneShift' then range = 475 end
			if spell2.name == 'RiftWalk' then range = 700 end
			if spell2.name == 'RocketJump' then range = 900 end
				
			if 	spell2.name == 'AatroxQ' or
				spell2.name == 'AhriTumble' or
				spell2.name == 'CarpetBomb' or
				spell2.name == 'GragasBodySlam' or
				spell2.name == 'GravesMove' or
				spell2.name == 'LucianE' or
				spell2.name == 'RenektonSliceAndDice' or
				spell2.name == 'SejuaniArcticAssault' or
				spell2.name == 'ShenShadowDash' or
				spell2.name == 'ShyvanaTransformCast' or
				spell2.name == 'slashCast' or
				spell2.name == 'ViQ' or
				spell2.name == 'FizzJump' or
				spell2.name == 'HecarimUlt' or
				spell2.name == 'KhazixE' or
				spell2.name == 'khazixelong' or
				spell2.name == 'LeblancSlide' or
				spell2.name == 'LeblancSlideM' or
				spell2.name == 'UFSlash' or
				spell2.name == 'Pounce' or
				spell2.name == 'Deceive' or
				spell2.name == 'ZacE' or
				spell2.name == 'VayneTumble' or
				spell2.name == 'RivenTriCleave' or
				spell2.name == 'RivenFeint' or
				spell2.name == 'EzrealArcaneShift' or
				spell2.name == 'RiftWalk' or
				spell2.name == 'RocketJump' then
				if distXYZ(unit.x,unit.z,spell2.endPos.x,spell2.endPos.z)>range then
					EnemyPos = Vector(unit.x,unit.y,unit.z)
					SpellPos = Vector(spell2.endPos.x,spell2.endPos.y,spell2.endPos.z)
					TruePos = EnemyPos + ( EnemyPos - SpellPos )*(-range/GetDistance(unit, spell2.endPos))
				elseif distXYZ(unit.x,unit.z,spell2.endPos.x,spell2.endPos.z)<range then
					TruePos = spell2.endPos
				end
				timer = 750
				if TruePos~=nil and GetDistance(TruePos)<Range and myHero.SpellTimeQ > 1 and GetTickCount()>timer then CastSpellXYZ(spellslot,TruePos.x,0,TruePos.z) end
			end
				-- Movement stopper
			if (spell2.name == 'katarinar' or
				spell2.name == 'drain' or
				spell2.name == 'crowstorm' or
				spell2.name == 'consume' or
				spell2.name == 'absolutezero' or
				spell2.name == 'rocketgrab' or
				spell2.name == 'staticfield' or
				spell2.name == 'cassiopeiapetrifyinggaze' or
				spell2.name == 'ezrealtrueshotbarrage' or
				spell2.name == 'galioidolofdurand' or
				spell2.name == 'gragasdrunkenrage' or
				spell2.name == 'luxmalicecannon' or
				spell2.name == 'reapthewhirlwind' or
				spell2.name == 'jinxw' or
				spell2.name == 'jinxr' or
				spell2.name == 'missfortunebullettime' or
				spell2.name == 'shenstandunited' or
				spell2.name == 'threshe' or
				spell2.name == 'threshrpenta' or
				spell2.name == 'infiniteduress' or
				spell2.name == 'meditate') and GetDistance(unit)<Range then
				CastSpellXYZ(spellslot,unit.x,0,unit.z)
			end
		end
	end
	for i = 1, objManager:GetMaxHeroes() do
		local enemy = objManager:GetHero(i)
		if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0 and enemy.dead == 0) then
			if (IsBuffed(enemy,'LOC_Stun') or 
				IsBuffed(enemy,'LOC_Suppress') or 
				IsBuffed(enemy,'LOC_Taunt') or 
				IsBuffed(enemy,'LuxLightBinding') or 
				IsBuffed(enemy,'DarkBinding_tar') or 
				IsBuffed(enemy,'RunePrison') or 
				IsBuffed(enemy,'Zyra_E_sequence_root') or 
				IsBuffed(enemy,'monkey_king_ult_unit_tar_02') or 
				IsBuffed(enemy,'xenZiou_ChainAttack_03') or 
				IsBuffed(enemy,'xenZiou_ChainAttack_03') or 
				IsBuffed(enemy,'tempkarma_spiritbindroot_tar')) and 
				GetDistance(enemy)<Range then
				CastSpellXYZ(spellslot,enemy.x,enemy.y,enemy.z)
			end
		end
	end
	for i = 1, objManager:GetMaxHeroes() do
		local ally = objManager:GetHero(i)
		if (ally ~= nil and ally.team == myHero.team and ally.visible == 1 and ally.dead == 0) then
			if (IsBuffed(ally,'CurseBandages')) and
				GetDistance(ally)<Range then
				CastSpellXYZ(spellslot,ally.x,ally.y,ally.z)
			end
		end
	end
end

SetTimerCallback("Main")