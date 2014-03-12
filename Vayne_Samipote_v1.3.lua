require 'Utils'
require 'winapi'
require 'SKeys'
require 'spell_damage'
require 'vals_lib'
local target
local wall
local InsideTheWall = false
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local ui = require 'simpleui'
local draw = require 'simpleui_drawing'
local Q,W,E,R = 'Q','W','E','R'
function Main()
        if myHero.name == "Vayne" then
                if VayneConfig.AutoE and IsChatOpen() == 0 then AutoCondemn() end
        end
		GetCD()
end
--[Menu]--
VayneConfig, menu = uiconfig.add_menu('Auto-Condemn', 200)
menu.checkbutton('AutoE', 'Auto-Condemn', true)
--[Auto-Condemn]--
function AutoCondemn()
for i = 1, objManager:GetMaxHeroes()  do
    	local enemy = objManager:GetHero(i)
		if (enemy ~= nil and ERDY == 1 and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable == 0 and enemy.dead == 0 and GetDistance(myHero, enemy) <= 715) then
		local enemyPosition = Vector(enemy.x,enemy.y,enemy.z)
		local checks = math.ceil(425/65)
		local checkDistance = 425/checks
		if enemy.x > 0 and enemy.z > 0 then
		 for k=1, checks, 1 do
		 local checksPos = enemyPosition + (Vector(enemyPosition) - myHero):normalized()*(checkDistance*k)
          if IsWall(checksPos.x, checksPos.y, checksPos.z) == 1 then
          InsideTheWall = true
		  else
		  InsideTheWall = false
           end
		   end
if InsideTheWall == true then CastSpellTarget('E', enemy) end
end
end
end
end
		   		
SetTimerCallback("Main")