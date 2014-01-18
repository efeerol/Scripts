--[Created by Valdorian--]
require 'Utils'
require 'winapi'
require 'SKeys'
require 'spell_damage'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local ui = require 'simpleui'
local draw = require 'simpleui_drawing'
local version = '1.0'
local Q,W,E,R = 'Q','W','E','R'
local show_allies = 0
local target,enemy2
local lastAttack = 0
local HavocDamage = 0
local ExecutionerDamage = 0
local True_Attack_Damage_Against_Minions = 0
local Range = myHero.range + GetDistance(GetMinBBox(myHero))
local SORT_CUSTOM = function(a, b) return a.maxHealth and b.maxHealth and a.maxHealth < b.maxHealth end
local Target, M_Target
local TEAM
local warding = 0
local lastLantern = nil
local delay = 0
local random = {x = 0, z = 0}
local TumbleSpot = { x=11575, y=52, z=4650 }
local TumbleSpotBackward = { x=11615, y=52, z=4670 }
local TumbleSpotBackward2 = { x=11685, y=52, z=4700 }
local TumblePoint = { x=11305, y=-62, z=4482 }
local AfterTumle = { x=11220, y=-62, z=4390 }
local Afterwalk = 0
local Afterwalk_stop = 0
local StuckPoint = 0
local StuckCount = 0
local shotFired = false
local timer,dodgetimer = 0,0
local AntiGapcloserWidth = 300
local AntiGapcloserTimer = 300
local AntiGapcloser = {    
	{name= "Pantheon_LeapBash"},
	{name= "Pantheon_Throw"},
	{name= "Pantheon_Heartseeker"},
	{name= "LucianR"}
}

function Main()
	if myHero.name == "Vayne" then
		if VayneConfig.AutoE and IsChatOpen() == 0 then AutoCondemn() end
		if VayneConfig.antigapclose and IsChatOpen() == 0 then AntiGapcloser() end
		if VayneConfig.antilantern then Antilantern() end
		if VayneConfig.overwall and IsChatOpen() == 0 then overwall() end
	end
end
--[Menu]--
VayneConfig, menu = uiconfig.add_menu('Vayne op', 200)
menu.checkbutton('AutoE', 'Auto-Condemn', true)
menu.checkbutton('antigapclose','AntiGapcloser',true)
menu.checkbutton('antilantern','PlayVsThresh',false)
menu.keytoggle('overwall','overwall tumbling',Keys.N,false)

--[Auto-Condemn]--
function AutoCondemn()
local target = GetWeakEnemy('PHYS',550)
if myHero.SpellTimeE>1 and GetSpellLevel('E')>0 and myHero.mana>90 and target~=nil and WillHitWall(target,450)==1 then CastSpellTarget('E',target) end
end
--[antilantern]--
function Antilantern()
if warding ~= 0 and lastLantern ~= nil and GetTickCount() - warding > delay and GetDistance(myHero,lastLantern) <= 650 and FindWards(lastLantern) == false and NearEnemys(lastLantern) ~= nil then
                local NearEnemy = NearEnemys(lastLantern)
                if (NearEnemy.health/NearEnemy.maxHealth*100) < 50 then
                        if GetWardSlot(3362) ~= nil then
                                CastSpellXYZ(GetWardSlot(3362), random.x, 0, random.z)
                        elseif GetWardSlot(2043) ~= nil then
                                CastSpellXYZ(GetWardSlot(2043), random.x, 0, random.z)
                        else
                                print('no wards ._.')
                        end
                end
                lastLantern = nil
                warding = 0
        elseif warding ~= 0 and lastLantern ~= nil and GetTickCount() - warding > 4000 then
                lastLantern = nil
                warding = 0
        end
end
 
function OnCreateObj(object)
        if object.charName == 'ThreshLantern' and object.name == 'ThreshLantern' and object.team ~= myHero.team then
                warding = GetTickCount()
                lastLantern = object
                random.x = object.x + math.random(4,24)
                random.z = object.z + math.random(4,24)
                delay = math.random(250,666)
        end
end
 
function NearEnemys(lantern)
    for i = 1, objManager:GetMaxHeroes() do
        local enemy = objManager:GetHero(i)
                if enemy ~= nil and enemy.team ~= enemy.team and GetDistance(enemy,lantern) <= 700 then
                        for i = 1, objManager:GetMaxHeroes() do
                        local enemyTresh = objManager:GetHero(i)
                                if enemyTresh.name == 'Thresh' and enemyTresh.team ~= myHero.team and GetDistance(enemyTresh,lantern) >= 350 then
                                        return enemy
                                end
                        end
                end
    end
        return nil
end
 
function FindWards(lantern)
    for i=1, objManager:GetMaxObjects(), 1 do
        local object = objManager:GetObject(i)
                if object ~= nil and object.team == myHero.team and (object.charName == 'VisionWard' or object.name == 'RelicVisionLantern') and GetDistance(lantern,object) <= 60 then
                        return true
                end
    end
        return false
end
 
function GetWardSlot(item) -- Thanks to fter44
        for i=1,7 do
                if GetInventoryItem(i) == item and myHero["SpellTime"..i] >= 1 then
                        return i
                end
        end
        return nil
end
--[Vayne overwall tumbling]--
function overwall()
if VayneConfig.overwall then
                if Afterwalk==0 and StuckPoint~=GetDistance(TumbleSpot,myHero) then
                        if GetDistance(TumbleSpot,myHero)<1000 and GetDistance(TumbleSpot,myHero)>23 and myHero.y>0 then
                                MoveToXYZ(TumbleSpot.x,TumbleSpot.y,TumbleSpot.z)
                                if GetDistance(TumbleSpot,myHero)<80 then
                                        StuckPoint=GetDistance(TumbleSpot,myHero)
                                else StuckCount = 0
                                end
                        else
                                if GetDistance(TumbleSpot,myHero)>19 and GetDistance(TumbleSpot,myHero)<23 then
                                        StuckPoint=GetDistance(TumbleSpot,myHero)
                                        MoveToXYZ(TumbleSpotBackward.x,TumbleSpotBackward.y,TumbleSpotBackward.z)
                                        --print("Backward")
                                        --print(GetDistance(TumbleSpot,myHero))
                                else
                                        if GetDistance(TumbleSpot,myHero)<19 then DoIt() end
                                end
                        end
                else
                        if Afterwalk ~= 0 and GetClock() > Afterwalk then
                                if Afterwalk_stop==0 then
                                        StopMove()
                                        Afterwalk_stop=1
                                        Afterwalk = GetClock()+250
                                else
                                        MoveToXYZ(AfterTumle.x,AfterTumle.y,AfterTumle.z)
                                        Afterwalk=0
                                end
                        end
                        if StuckPoint==GetDistance(TumbleSpot,myHero) then
                                if StuckCount < 6 then
                                        --print(StuckCount)
                                        StuckCount = StuckCount + 1
                                else
                                        --print("Stuck! Moving backward")
                                        MoveToXYZ(TumbleSpotBackward2.x,TumbleSpotBackward2.y,TumbleSpotBackward2.z)
                                        StuckCount = 0
                                end
                        else StuckCount = 0
                        end
                end
                --print(GetDistance(TumbleSpot,myHero))
        end
        ShowMeAWay()
end
 
function DoIt()
        if CanCastSpell("Q") then
                --print(GetDistance(TumbleSpot,myHero))
                MoveToXYZ(TumbleSpot.x,TumbleSpot.y,TumbleSpot.z)
                CastSpellXYZ("Q", TumblePoint.x, 0, TumblePoint.z)
                Afterwalk = GetClock()+500
                Afterwalk_stop=0
        else
                StuckCount = 0
        end
end
 
function ShowMeAWay()
    if VayneConfig.overwall then
                if GetDistance(TumbleSpot,myHero)<1000 and GetDistance(TumbleSpot,myHero)>30 and myHero.y>0 then
                        DrawCircle(TumbleSpot.x, TumbleSpot.y, TumbleSpot.z, 150, 0x02)
                        DrawCircle(TumbleSpot.x, TumbleSpot.y, TumbleSpot.z, 153, 0x02)
                else
                        if GetDistance(TumbleSpot,myHero)>1000 or myHero.y<0 then
                                DrawCircle(TumbleSpot.x, TumbleSpot.y, TumbleSpot.z, 150, 0x000099)
                                DrawCircle(TumbleSpot.x, TumbleSpot.y, TumbleSpot.z, 153, 0x000099)
                        else
                                DrawCircle(TumbleSpot.x, TumbleSpot.y, TumbleSpot.z, 150, 0x02)
                                DrawCircle(TumbleSpot.x, TumbleSpot.y, TumbleSpot.z, 153, 0x02)
                        end
                end
        else
                        DrawCircle(TumbleSpot.x, TumbleSpot.y, TumbleSpot.z, 150, 0x000099)
                        DrawCircle(TumbleSpot.x, TumbleSpot.y, TumbleSpot.z, 153, 0x000099)
        end
end
--[AntiGapcloser]--
function AntiGapcloser()
	if VayneConfig.antigapclose then
		for i = 1, objManager:GetMaxHeroes() do
			local enemy = objManager:GetHero(i)
			if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.dead == 0) then
				if unit ~= nil and unit.name == enemy.name then
					if ERDY == 1 and 
						spell.name == 'AatroxQ' or 				-- AAtrox,Q
						spell.name == 'AkaliShadowDance' or 	-- Akali,R
						spell.name == 'Headbutt' or 			-- Alistar,W
						spell.name == 'BandageToss' or 			-- Amumu,Q
						spell.name == 'RocketGrab' or 			-- BlitzCrank,Q
						spell.name == 'DariusAxeGrabCone' or 	-- Darius,E
						spell.name == 'DianaTeleport' or 		-- Diana,R
						spell.name == 'FioraQ' or 				-- Fiora,Q
						spell.name == 'FizzPiercingStrike' or 	-- Fizz,Q
						spell.name == 'GragasBodySlam' or 		-- Gragas,E
						spell.name == 'HecarimUlt' or 			-- Heracim,R
						spell.name == 'IreliaGatotsu' or 		-- Irelia,Q
						spell.name == 'JarvanIVDragonStrike' or -- Jarvan,Q
						spell.name == 'JarvanIVCataclysm' or 	-- Jarvan,R
						spell.name == 'JaxLeapStrike' or 		-- Jax,Q
						spell.name == 'JayceToTheSkies' or 		-- Jayce,Q
						spell.name == 'RiftWalk' or 			-- Kassadin,R
						spell.name == 'KatarinaE' or 			-- Katarina,E
						spell.name == 'KhazixE' or 				-- Khazix,E
						spell.name == 'khazixelong' or 			-- Khazix,E
						spell.name == 'LeblancSlide' or 		-- LeBlanc,W
						spell.name == 'blindmonkqtwo' or 		-- Leesin,Q
						spell.name == 'LeonaZenithBlade' or 	-- Leona,E
						spell.name == 'UFSlash' or 				-- Malphite,R
						spell.name == 'MaokaiSapling2' or 		-- Maokai,E
						spell.name == 'AlphaStrike' or 			-- Masteryi,Q
						spell.name == 'NautilusAnchorDrag' or	-- Nautilus,Q
						spell.name == 'Pantheon_LeapBash' or 	-- Pantheon,W
						spell.name == 'PoppyHeroicCharge' or 	-- Poppy,E
						spell.name == 'PuncturingTaunt' or 		-- Rammus,E
						spell.name == 'RivenFeint' or 			-- Riven,E
						spell.name == 'ShenShadowDash' or 		-- Shen,E
						spell.name == 'ShyvanaTransformCast' or -- Shyvana,R
						spell.name == 'TalonCutthroat' or 		-- Talon,E
						spell.name == 'RocketJump' or 			-- Tristana,W
						spell.name == 'ViQ' or					-- Vi,Q
						spell.name == 'MonkeyKingNimbus' or 	-- Wukong,E
						spell.name == 'XenZhaoSweep' or 		-- Xinzhao,E
						spell.name == 'ZacE' or 				-- Zac,E
						spell.name == 'ZedShadowDash' or 		-- Zed,W
						spell.name == 'zedult' then 			-- Zed,R
						if GetDistance(spell.endPos,myHero)<AntiGapcloserWidth then
							SpellTarget(E,ERDY,myHero,enemy,800)
						end
					end
				end
			end
		end
	end
end


SetTimerCallback("Main")