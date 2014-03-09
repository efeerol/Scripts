require 'Utils'
require 'spell_damage'
require 'uiconfig'
require 'spell_shot'
require 'winapi'
require 'SKeys'
local target
local Rtarget
local Q,W,E,R = 'Q','W','E','R'
local qx=0
local qy=0
local qz=0
local hero_table = {}
local deconce=0
local pdot=0
local ddot=0
local edot=0
local targeth
local zv = Vector(0,0,0)
local amax_heroes = 0
local Counter = {}
local targetIgnite
local timer = os.time()
local spellShot = {shot = false, radius = 0, time = 0, shotX = 0, shotZ = 0, shotY = 0, safeX = 0, safeY = 0, safeZ = 0, isline = false}
local startPos = {x=0, y=0, z=0}
local endPos = {x=0, y=0, z=0}
local shotMe = false
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'

        caitlynn, menu = uiconfig.add_menu('Insane caitlynn', 200)
        menu.keydown('Combo', 'Combo', Keys.X)  
        menu.keytoggle('Autoharass', 'Auto Harass', Keys.F2, false)      
        menu.keytoggle('SafeR', 'Auto-Ult', Keys.F5, true)
        menu.checkbutton('Killsteal', 'Use Killsteals', true)
        menu.checkbutton('Q', 'Q', true)
        menu.checkbutton('E', 'E', true)
        menu.checkbutton('R', 'R', true)
		menu.checkbutton('HeadShotReady', 'Auto-HeadShot', true)
		
		
		function main()
		target = GetWeakEnemy('PHYS',1300)
		Rtarget = GetWeakEnemy('PHYS',1500+(500*myHero.SpellLevelR))
		targeth = GetWeakEnemy('PHYS',750)
		GetCD()
		
		if caitlynn.Combo then Combo() end
		if caitlynn.Killsteal then Killsteal() end
		if caitlynn.HeadShotReady then HeadShotReady() end
		if caitlynn.Autoharass then Autoharass() end
		end
		
		function Combo()
		if target ~= nil then
		Q(target)
		E(target)
		end
		end
		
		function Autoharass()
		if target ~= nil then
		Q(target)
		end
		end
		
		function GetCD()
        if myHero.SpellTimeQ > 1 and GetSpellLevel('Q') > 0 then
                QRDY = 1
                else QRDY = 0
        end
        if myHero.SpellTimeW > 1 and GetSpellLevel('W') > 0 then
                WRDY = 1
                else WRDY = 0
        end
        if myHero.SpellTimeE > 1 and GetSpellLevel('E') > 0 then
                ERDY = 1
                else ERDY = 0
        end
        if myHero.SpellTimeR > 1 and GetSpellLevel('R') > 0 then
                RRDY = 1
        else RRDY = 0 end
end
function HeadShotReady()
    for i = 1, objManager:GetMaxObjects(), 1 do
        obj = objManager:GetObject(i)
        if obj~=nil and targeth~=nil then
			if (obj.charName:find("headshot_rdy_indicator")) and GetDistance(obj, myHero) < 650 then
			AttackTarget(targeth)
            end
        end
    end
end
function R(RTarget)
local range = (1500+(500*myHero.SpellLevelR))
local manacost = 100
	if RTarget ~= nil then
		if GetDistance(myHero, RTarget) <= range and myHero.mana >= manacost then
			CastSpellTarget('R',RTarget)
		end
	end
end
		
function Killsteal() --15 KS Combinations
	for i = 1, objManager:GetMaxHeroes()  do
    	local enemy = objManager:GetHero(i)
    	if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable == 0 and enemy.dead == 0) then
			local qdmg = getDmg("Q",enemy,myHero)
			local wdmg = getDmg("W",enemy,myHero)
    		local edmg = getDmg("E",enemy,myHero)
			local rdmg = getDmg("R",enemy,myHero)-47
			local ignitedmg = (myHero.selflevel*20)+50
			if caitlynn.Q and qdmg > enemy.health and myHero.SpellTimeQ > 1.0 and GetDistance(myHero,enemy) <= 1300 then --Q KS
				Q(enemy)
			end
			if caitlynn.E and edmg > enemy.health and myHero.SpellTimeE > 1.0 and GetDistance(myHero,enemy) <= 1000 then --E KS
				E(enemy)
			end
			if caitlynn.SafeR then
				if caitlynn.R and rdmg > enemy.health and myHero.SpellTimeR > 1.0 and GetDistance(myHero,enemy) <= (1500+(500*myHero.SpellLevelR)) then --R KS --SafeR
					R(enemy)
				end
			else
				if caitlynn.R and rdmg > enemy.health and myHero.SpellTimeR > 1.0 and GetDistance(myHero,enemy) <= (1500+(500*myHero.SpellLevelR)) then --R KS
					R(enemy)
				end
			end
			end
			end
			end
function Q(target)
local range = 1300
local manacost = (40 + (10 * myHero.SpellLevelQ))
	if target ~= nil then
		if GetDistance(myHero, target) <= range and myHero.mana >= manacost then
			CastSpellXYZ('Q',GetFireahead(target,2,16))
		end
	end
end
		function E(target)
		local range = 1000
	if target ~= nil then
		if GetDistance(myHero, target) <= range and ERDY == 1 then
			CastSpellXYZ('E',GetFireahead(target,2,32))
		end
	end
end
function declare2darray()
    amax_heroes=objManager:GetMaxHeroes()
    if amax_heroes > 1 then
        for i = 1,amax_heroes, 1 do
            local h=objManager:GetHero(i)
            local name=h.name
            hero_table[name]={}
            hero_table[name][0] = 0
            hero_table[name][1] = zv
            hero_table[name][2] = 0
            hero_table[name][3] = zv
        end
    end
end
function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end


function velocity()
    --print("\ndebugv:\n")
    local max_heroes=objManager:GetMaxHeroes()
    --print("maxheroes: " .. max_heroes .. " || ")
    if max_heroes > amax_heroes then declare2darray() end

    local timedif = 0
    local cordif = Vector(0,0,0)

    for i = 1,max_heroes, 1 do
        local h=objManager:GetHero(i)
        local name=h.name
        if name ~= nil then
            cordif = Vector(h.x,h.y,h.z) - hero_table[name][1]
            hero_table[name][3] = Vector(round(cordif.x/timedif,7),round(cordif.y/timedif,7),round(cordif.z/timedif,7))
            hero_table[name][1]    = Vector(h.x,h.y,h.z)
        end
    end
end
function bestcoords(btarget)
    local x1,y1,z1 = GetFireahead(target,13,1)
    local ve= Vector(x1 - btarget.x,y1 - btarget.y,z1 - btarget.z) -- getfireahead - target
    local nb = btarget.name
    local vvt = hero_table[nb][3]	
    local vst = Vector(btarget.x - myHero.x,btarget.y-myHero.y,btarget.z - myHero.z) -- target - self
    local vse = Vector(x1-myHero.x,y1-myHero.y,z1-myHero.z) -- getfireahead - self
    local speedratio = (btarget.movespeed / vvt:len())
    if vvt:len() ~= 0 then
        local vstn = vst:normalized()
        local vvtn = vvt:normalized()
        local ven = ve:normalized()
        local vsen = vse:normalized()
        ddot = math.abs(vsen:dotP(ven))
        edot = math.abs(vvtn:dotP(ven))
        pdot = math.abs(vstn:dotP(vvtn))    
        if  vst:len() < 1450 and CreepBlock(qx,qy,qz,250) == 0  then
            qx=x1
            qy=y1
            qz=z1
            return 1
        end
    elseif vvt:len() == 0 and vst:len() < 1485 and CreepBlock(qx,qy,qz,250) == 0 then
            qx=btarget.x
            qy=btarget.y
            qz=btarget.z
            return 1
    else
        return 0
    end
    return 0

end
 
function GetGlobalTarget()
        local ultTarget = objManager:GetHero(1)
        for i = 2, objManager:GetMaxHeroes() do
                local t = objManager:GetHero(i)
                if t.health < ultTarget.health and t.team ~= myHero.team and t.visible == 1 and t.dead==0 then
                        ultTarget = t
                end
        end
        if ultTarget.team == myHero.team or ultTarget.visible == 0 or ultTarget.dead == 1 then
                ultTarget = nil
        end
        return ultTarget
end
 
 
 --------------------------------------------------------
       
 
function IsHero(unit)
  for i=1, objManager:GetMaxHeroes(), 1 do
                local object = objManager:GetHero(i)
                if object ~= nil and object.charName == unit.charName then
                        return true
                end
        end
        return false
end
----------------------------------------------------------------------------------------

SetTimerCallback('main')