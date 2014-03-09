require 'Utils'
require 'spell_damage'
require 'uiconfig'
require 'winapi'
require 'SKeys'
require 'vals_lib'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local Q,W,E,R = 'Q','W','E','R'
local qx=0
local hero_table = {}
local deconce=0
local zv = Vector(0,0,0)
local qy=0
local qz=0
local rangeQ = 1100 -- Q
local rangeW = 300 -- W
local rangeE = 400 -- E
local rangeR = 600 -- R
local delay = 1.6
local Qspeed = 20
local crying = false
local target
	   Config, menu = uiconfig.add_menu('Amumu WomboCombo 1.0', 200)  
        menu.keydown('teamFight', 'TeamFight', Keys.X, false)
		menu.keydown('useUlt', 'Ult', Keys.A)
		menu.checkbutton('items', 'items in teamfight', true)
		menu.checkbutton('autoHarrass', 'Harrass', true)
		menu.checkbutton('UseR', 'UseR in teamfight', true)
        menu.keytoggle('autoIgnite', 'Auto Ignite', Keys.F5, true)
function main()
GetCD()
if Config.autoIgnite then ignite() end
if Config.teamFight then teamFight() end
if Config.useUlt then CastR() end
if Config.autoHarrass then autoHarrass() end
targetignite = GetWeakEnemy('TRUE',600)
target = GetWeakEnemy('MAGIC',1100)
end
		
function teamFight()
	if Config.teamFight then
		if target ~= nil then 
				SpellPred(Q,QRDY,myHero,target,rangeQ,delay,Qspeed,1)
				end
		if target ~= nil and GetDistance(myHero, target) <= 350 then
		 CastSpellTarget('E',target) end
		end
		if Config.items and target ~= nil then
		UseAllItems(target)
		end
		if target ~= nil and crying == false then 
		SpellTarget(W,WRDY,myHero,target,300)
		end
		if target ~= nil then
for i = 1, objManager:GetMaxHeroes()  do
    	local enemy = objManager:GetHero(i)
		if Config.UseR then
				if (enemy ~= nil and RRDY == 1 and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable == 0 and enemy.dead == 0) then
				CastHotkey("R AUTO 100,0 SPELLR:WEAKENEMY SKILLSHOTSELF")
				end
				end
			end
		end 
		end
		
function CastR()
if (enemy ~= nil and RRDY == 1 and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable == 0 and enemy.dead == 0) then
CastHotkey("R AUTO 100,0 SPELLR:WEAKENEMY SKILLSHOTSELF")
end
end

function autoHarrass()
		if target ~= nil and GetDistance(myHero, target) <= 350 then
		 CastSpellTarget('E',target) end
		end

function ignite()
        local damage = (myHero.selflevel*20)+50
        if targetignite ~= nil then
                if myHero.SummonerD == 'SummonerDot' then
                        if targetignite.health < damage then
                                CastSpellTarget('D',targetignite)
                        end
                end
                if myHero.SummonerF == 'SummonerDot' then
                        if targetignite.health < damage then
                                CastSpellTarget('F',targetignite)
                        end
                end
        end
end		
function CountEnemyHeroInRange(range, object)
    object = object or myHero
    range = range and range * range or myHero.range * myHero.range
    local enemyInRange = 0
    for i = 1, objManager:GetMaxHeroes() do
        local hero = objManager:GetHero(i)
        if (hero~=nil and hero.team~=myHero.team and hero.visible==1 and hero.dead==0) and GetDistance(object, hero) <= range then
            enemyInRange = enemyInRange + 1
        end
    end
    return enemyInRange
end
		
function OnCreateObj(obj)
	if obj.name:find("Despairpool_tar.troy") then
		if GetDistance(obj, myHero)<=70 then
			crying = true
		end
	end
end

function DeleteObj(obj)
		if obj.name:find("Despairpool_tar.troy") then
			if GetDistance(obj, myHero)<=70 then
				crying = false	
			end
		end
	end
SetTimerCallback('main')