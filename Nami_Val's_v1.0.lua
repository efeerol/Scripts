require 'Utils'
require 'winapi'
require 'SKeys'
require 'vals_lib'
local Q,W,E,R = 'Q','W','E','R'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local version = '1.0'

function Main()
	if IsLolActive() then
		target = GetWeakEnemy('MAGIC',725)
		GetCD()
		if QRDY == 0 then
			CCenemy = nil
			Slowenemy = nil
		end
		if NamiConfig.AutoQ then Qspell() end
		if NamiConfig.AutoW then Wspell() end
	end
end

	NamiConfig, menu = uiconfig.add_menu('Nami Config', 200)
	menu.checkbutton('AutoQ', 'AutoQ', true)
	menu.checkbutton('AutoW', 'AutoW', true)
	menu.checkbutton('AutoE', 'AutoE', true)
	menu.checkbutton('drawcircles', 'Draw Circles', true)
	menu.permashow('AutoQ')
	menu.permashow('AutoW')
	menu.permashow('AutoE')

function Qspell()
	if CCenemy~=nil then SpellXYZ(Q,QRDY,myHero,CCenemy,875,CCenemy.x,CCenemy.z)
	elseif Slowenemy~=nil then SpellPred(Q,QRDY,myHero,Slowenemy,800,1.6,10)
	end
end

function Wspell()
	if target~=nil then SpellTarget(W,WRDY,myHero,target,725) end
end

function OnProcessSpell(unit,spell)
	if unit ~= nil and spell ~= nil and unit.team == myHero.team then
		if NamiConfig.AutoQ then
			for i = 1, objManager:GetMaxHeroes() do
				local enemy = objManager:GetHero(i)
				if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0 and enemy.dead==0) then
					if GetDistance(enemy)<950 and CreepBlock(GetFireahead(enemy,1.6,17,100))==0 then
						if     unit.name=='Aatrox' 		and spell.name == unit.SpellNameQ and distXYZ(enemy.x,enemy.z,spell.endPos.x,spell.endPos.z)<200 then CCenemy = enemy
						elseif unit.name=='Alistar' 	and spell.name == unit.SpellNameQ and distXYZ(enemy.x,enemy.z,spell.endPos.x,spell.endPos.z)<375 then CCenemy = enemy
						elseif unit.name=='Chogath'		and spell.name == unit.SpellNameR and distXYZ(enemy.x,enemy.z,spell.endPos.x,spell.endPos.z)<850 then CCenemy = enemy
						elseif unit.name=='Darius'		and spell.name == unit.SpellNameE and distXYZ(enemy.x,enemy.z,spell.endPos.x,spell.endPos.z)<475 then CCenemy = enemy
						elseif unit.name=='Diana'		and spell.name == unit.SpellNameE and distXYZ(enemy.x,enemy.z,spell.endPos.x,spell.endPos.z)<250 then CCenemy = enemy
						elseif unit.name=='Galio'		and spell.name == unit.SpellNameR and distXYZ(enemy.x,enemy.z,spell.endPos.x,spell.endPos.z)<600 then CCenemy = enemy
						elseif unit.name=='Lulu' 		and spell.name == unit.SpellNameW and spell.target~=nil and spell.target.name == enemy.name then Slowenemy = enemy
						elseif unit.name=='Malphite' 	and spell.name == unit.SpellNameR and distXYZ(enemy.x,enemy.z,spell.endPos.x,spell.endPos.z)<1000 then CCenemy = enemy
						end
					end
				end
			end
		end
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
				if NamiConfig.AutoQ then
					if (enemy~=nil and GetDistance(enemy)<875) then
						if obj.charName=='LOC_Stun.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
						elseif obj.charName=='LOC_Suppress.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
						elseif obj.charName=='LOC_Taunt.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
						elseif obj.charName=='LOC_Stun.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
						elseif obj.charName=='LOC_fear.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
						elseif obj.charName=='Global_Stun.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
						elseif obj.charName=='Ahri_Charm_buf.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
						elseif obj.charName=='CurseBandages.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
						elseif obj.charName=='Powerfist_tar.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
						elseif obj.charName=='JarvanCataclysm_tar.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
						elseif obj.charName=='leBlanc_shackle_tar_blood.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
						elseif obj.charName=='LuxLightBinding.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
						elseif obj.charName=='DarkBinding_tar.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
						elseif obj.charName=='RengarEMax_tar.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
						elseif obj.charName=='RunePrison.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
						elseif obj.charName=='Vi_R_land.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
						elseif obj.charName=='UnstoppableForce_stun.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
						elseif obj.charName=='Zyra_E_sequence_root.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
						elseif obj.charName=='monkey_king_ult_unit_tar_02.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
						elseif obj.charName=='xenZiou_ChainAttack_03.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
						elseif obj.charName=='VarusRHit.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
						elseif obj.charName=='tempkarma_spiritbindroot_tar.troy' and GetDistance(enemy,obj)<50 then CCenemy = enemy
						end
						if (enemy~=nil and GetDistance(enemy)<800) then
							if obj.charName=='GLOBAL_SLOW.troy' and GetDistance(enemy,obj)<50 then Slowenemy = enemy
							elseif obj.charName=='Global_Slow.troy' and GetDistance(enemy,obj)<50 then Slowenemy = enemy
							end
						end
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

SetTimerCallback("Main")