require 'Utils'
require 'winapi'
require 'SKeys'
require 'spell_damage'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'
local Q,W,E,R = 'Q','W','E','R'
local version = '1.0'
local MinionsAA = { }
local MinionsQ = { }
local MinionsW = { }
local MinionsE = { }
local MinionsR = { }
local SORT_CUSTOM = function(a, b) return a.maxHealth and b.maxHealth and a.maxHealth < b.maxHealth end

	MainCFG, menu = uiconfig.add_menu('Main Config', 200)
	menu.slider('range', 'Range', 0, 30000, 30000)
	menu.checkbox('AA', '-------------------- AA --------------------', false)
	menu.slider('AAcolor', nil, 1, 5, 1, {'Green','Red','Blue','Pink','Yellow',})
	menu.slider('AAradius', 'Radius', 1, 100, 60)
	menu.slider('AAthickness', 'Thickness', 1, 30, 1)
    menu.checkbox('Q', '-------------------- Q --------------------', false)
	menu.slider('Qcolor', nil, 1, 5, 2, {'Green','Red','Blue','Pink','Yellow',})
	menu.slider('Qradius', 'Radius', 1, 100, 60)
	menu.slider('Qthickness', 'Thickness', 1, 30, 1)
	menu.checkbox('W', '-------------------- W --------------------', false)
	menu.slider('Wcolor', nil, 1, 5, 3, {'Green','Red','Blue','Pink','Yellow',})
	menu.slider('Wradius', 'Radius', 1, 100, 60)
	menu.slider('Wthickness', 'Thickness', 1, 30, 1)
	menu.checkbox('E', '-------------------- E --------------------', false)
	menu.slider('Ecolor', nil, 1, 5, 4, {'Green','Red','Blue','Pink','Yellow',})
	menu.slider('Eradius', 'Radius', 1, 100, 60)
	menu.slider('Ethickness', 'Thickness', 1, 30, 1)
	menu.checkbox('R', '-------------------- R --------------------', false)
	menu.slider('Rcolor', nil, 1, 5, 5, {'Green','Red','Blue','Pink','Yellow',})
	menu.slider('Rradius', 'Radius', 1, 100, 60)
	menu.slider('Rthickness', 'Thickness', 1, 30, 1)
	
function Main()
	if IsLolActive() then
		GetCD()
		MinionsAA = GetEnemyMinions(SORT_CUSTOM)
		MinionsQ = GetEnemyMinions(SORT_CUSTOM)
		MinionsW = GetEnemyMinions(SORT_CUSTOM)
		MinionsE = GetEnemyMinions(SORT_CUSTOM)
		MinionsR = GetEnemyMinions(SORT_CUSTOM)
		for i, minionAA in pairs(MinionsAA) do
			if minionAA~=nil then AAdam = getDmg("AD",minionAA,myHero) end
			if MainCFG.AA and AAdam~=nil and minionAA.health<AAdam then CustomCircleXYZ(MainCFG.AAradius,MainCFG.AAthickness,MainCFG.AAcolor,minionAA) end
		end
		for i, minionQ in pairs(MinionsQ) do
			if minionQ~=nil then Qdam = getDmg("Q",minionQ,myHero) end
			if MainCFG.Q and Qdam~=nil and minionQ.health<Qdam then CustomCircleXYZ(MainCFG.Qradius,MainCFG.Qthickness,MainCFG.Qcolor,minionQ) end
		end
		for i, minionW in pairs(MinionsW) do
			if minionW~=nil then Qdam = getDmg("W",minionW,myHero) end
			if MainCFG.W and Wdam~=nil and minionW.health<Wdam then CustomCircleXYZ(MainCFG.Wradius,MainCFG.Wthickness,MainCFG.Wcolor,minionW) end
		end
		for i, minionE in pairs(MinionsE) do
			if minionE~=nil then Edam = getDmg("E",minionE,myHero) end
			if MainCFG.E and Edam~=nil and minionE.health<Edam then CustomCircleXYZ(MainCFG.Eradius,MainCFG.Ethickness,MainCFG.Ecolor,minionE) end
		end
		for i, minionR in pairs(MinionsR) do
			if minionR~=nil then Rdam = getDmg("R",minionR,myHero) end
			if MainCFG.R and Rdam~=nil and minionR.health<Rdam then CustomCircleXYZ(MainCFG.Rradius,MainCFG.Rthickness,MainCFG.Rcolor,minionR) end
		end
	end
end

function CustomCircleXYZ(radius,thickness,color,target)
        local count = math.floor(thickness/2)
        repeat
			DrawCircleObject(target,radius+count,color)
            count = count-2
        until count == (math.floor(thickness/2)-(math.floor(thickness/2)*2))-2
    if x ~= "" and y ~= "" and z~= "" then
        local count = math.floor(thickness/2)
        repeat
            DrawCircleObject(target,radius+count,color)
            count = count-2
        until count == (math.floor(thickness/2)-(math.floor(thickness/2)*2))-2
    end
end

function GetCD()
	if myHero.SpellTimeQ > 1 and GetSpellLevel('Q') > 0 then QRDY = 1
	else QRDY = 0 end
	if myHero.SpellTimeW > 1 and GetSpellLevel('W') > 0 then WRDY = 1
	else WRDY = 0 end
	if myHero.SpellTimeE > 1 and GetSpellLevel('E') > 0 then ERDY = 1
	else ERDY = 0 end
	if myHero.SpellTimeR > 1 and GetSpellLevel('R') > 0 then RRDY = 1
	else RRDY = 0 end
end

function IsLolActive()
    return tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client"
end

SetTimerCallback('Main')