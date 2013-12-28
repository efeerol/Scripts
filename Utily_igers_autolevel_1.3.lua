require 'Utils'
require 'winapi'
require 'SKeys'
local send = require 'SendInputScheduled'
local uiconfig = require 'uiconfig'

local version = "1.3"
local Q,W,E,R = 'Q','W','E','R'
local metakey = SKeys.Control
local attempts = 0
local lastAttempt = 0

local skillingOrder = {
    ----------------1 2 3 4 5 6 7 8 9 101112131415161718
    Ahri         = {Q,E,Q,W,Q,R,Q,W,Q,W,R,W,W,E,E,R,W,W},
    Akali        = {Q,W,Q,E,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Alistar      = {Q,E,W,Q,E,R,Q,E,Q,E,R,Q,E,W,W,R,W,W},
    Amumu        = {W,E,E,Q,E,R,E,Q,E,Q,R,Q,Q,W,W,R,W,W},
    Anivia       = {Q,E,Q,E,E,R,E,W,E,W,R,Q,Q,Q,W,R,W,W},
    Annie        = {W,Q,Q,E,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Ashe         = {W,E,W,Q,W,R,W,Q,W,Q,R,Q,Q,E,E,R,E,E},
    Blitzcrank   = {Q,E,W,E,W,R,E,W,E,W,R,E,W,Q,Q,R,Q,Q},
    Brand        = {W,E,W,Q,W,R,W,E,W,E,R,E,E,Q,Q,R,Q,Q},
    Caitlyn      = {W,Q,Q,E,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Cassiopeia   = {Q,E,Q,W,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Chogath      = {Q,E,W,W,W,R,W,E,W,E,R,E,E,Q,Q,R,Q,Q},
    Corki        = {Q,W,Q,E,Q,R,Q,E,Q,E,R,E,W,E,W,R,W,W},
    Diana        = {W,Q,W,E,Q,R,Q,Q,Q,W,R,W,W,E,E,R,E,E},
    DrMundo      = {W,Q,E,W,W,R,W,E,W,E,R,E,E,Q,Q,R,Q,Q},
    Elise        = {E,W,Q,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Evelynn      = {Q,E,Q,W,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Ezreal       = {Q,E,W,W,W,R,W,Q,W,Q,R,Q,Q,E,E,R,E,E},
    FiddleSticks = {E,W,W,Q,W,R,W,Q,W,Q,R,Q,Q,E,E,R,E,E},
    Fizz         = {E,Q,W,Q,W,R,Q,Q,Q,W,R,W,W,E,E,R,E,E},
    Galio        = {Q,W,Q,E,Q,R,Q,W,Q,W,R,E,E,W,W,R,E,E},
    Gangplank    = {Q,W,Q,E,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Garen        = {Q,W,E,E,E,R,E,Q,E,Q,R,Q,Q,W,W,R,W,W},
    Gragas       = {Q,E,W,Q,Q,R,Q,W,Q,W,R,W,E,W,E,R,E,E},
    Graves       = {Q,E,Q,W,Q,R,Q,W,Q,E,R,E,E,E,W,R,W,W},
    Hecarim      = {Q,W,Q,E,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Heimerdinger = {Q,W,W,Q,Q,R,E,W,W,W,R,Q,Q,E,E,R,Q,Q},
    Irelia       = {E,Q,W,W,W,R,W,E,W,E,R,Q,Q,E,Q,R,E,Q},
    Janna        = {E,Q,E,W,E,R,E,W,E,W,Q,W,W,Q,Q,Q,R,R},
    JarvanIV     = {Q,E,Q,W,Q,R,Q,E,W,Q,R,E,E,E,W,R,W,W},
    Jax          = {E,W,Q,W,W,R,W,E,W,E,R,Q,E,Q,Q,R,E,Q},
    Jayce        = {Q,E,Q,W,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Karma        = {Q,W,E,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Karthus      = {Q,E,W,Q,Q,R,Q,Q,E,E,R,E,E,W,W,R,W,W},
    Kassadin     = {Q,W,Q,E,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Katarina     = {Q,E,W,W,W,R,W,E,W,Q,R,Q,Q,Q,E,R,E,E},
    Kayle        = {E,W,E,Q,E,R,E,W,E,W,R,W,W,Q,Q,R,Q,Q},
    Kennen       = {Q,E,W,W,W,R,W,Q,W,Q,R,Q,Q,E,E,R,E,E},
    Khazix       = {E,W,Q,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    KogMaw       = {W,E,W,Q,W,R,W,Q,W,Q,R,Q,Q,E,E,R,E,E},
    Leblanc      = {Q,W,E,Q,Q,R,Q,W,Q,W,R,W,E,W,E,R,E,E},
    LeeSin       = {E,Q,W,Q,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Leona        = {Q,E,W,W,W,R,W,E,W,E,R,E,E,Q,Q,R,Q,Q},
    Lissandra    = {E,W,Q,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Lulu         = {E,W,Q,E,E,R,E,W,E,W,R,W,W,Q,Q,R,Q,Q},
    Lux          = {E,Q,E,W,E,R,E,Q,E,Q,R,Q,Q,W,W,R,W,W},
    Malphite     = {Q,E,Q,W,Q,R,Q,E,Q,E,R,E,W,E,W,R,W,W},
    Malzahar     = {Q,E,E,W,E,R,Q,E,Q,E,R,W,Q,W,Q,R,W,W},
    Maokai       = {E,Q,W,E,E,R,E,W,E,W,R,W,W,Q,Q,R,Q,Q},
    MasterYi     = {E,Q,E,Q,E,R,E,Q,E,Q,R,Q,W,W,W,R,W,W},
    MissFortune  = {Q,E,Q,W,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    MonkeyKing   = {E,Q,W,Q,Q,R,E,Q,E,Q,R,E,E,W,W,R,W,W},
    Mordekaiser  = {E,Q,E,W,E,R,E,Q,E,Q,R,Q,Q,W,W,R,W,W},
    Morgana      = {Q,W,W,E,W,R,W,Q,W,Q,R,Q,Q,E,E,R,E,E},
    Nami         = {E,W,Q,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Nasus        = {Q,W,Q,E,Q,R,Q,W,Q,W,R,W,E,W,E,R,E,E},
    Nautilus     = {W,E,W,Q,W,R,W,E,W,E,R,E,E,Q,Q,R,Q,Q},
    Nidalee      = {W,E,Q,E,Q,R,E,W,E,Q,R,E,Q,Q,W,R,W,W},
    Nocturne     = {Q,W,Q,E,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Nunu         = {E,Q,E,W,Q,R,E,Q,E,Q,R,Q,E,W,W,R,W,W},
    Olaf         = {Q,E,Q,W,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Orianna      = {Q,E,W,Q,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Pantheon     = {Q,W,E,Q,Q,R,Q,E,Q,E,R,E,W,E,W,R,W,W},
    Poppy        = {E,W,Q,Q,Q,R,Q,W,Q,W,W,W,E,E,E,E,R,R},
    Quinn        = {E,W,Q,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Rammus       = {Q,W,E,E,E,R,E,W,E,W,R,W,W,Q,Q,R,Q,Q},
    Renekton     = {W,Q,E,Q,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Rengar       = {Q,E,W,Q,Q,R,W,Q,Q,W,R,W,W,E,E,R,E,E},
    Riven        = {Q,W,E,W,W,R,W,E,W,E,R,E,E,Q,Q,R,Q,Q},
    Rumble       = {E,Q,Q,W,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Ryze         = {Q,W,Q,E,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Sejuani      = {W,Q,E,E,W,R,E,W,E,E,R,W,Q,W,Q,R,Q,Q},
    Shaco        = {W,E,Q,E,E,R,E,W,E,W,R,W,W,Q,Q,R,Q,Q},
    Shen         = {Q,W,E,Q,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Shyvana      = {W,Q,W,E,W,R,W,E,W,E,R,E,Q,E,Q,R,Q,Q},
    Singed       = {Q,E,Q,E,Q,R,Q,W,Q,W,R,E,W,E,W,R,W,E},
    Sion         = {Q,E,E,W,E,R,E,Q,E,Q,R,Q,Q,W,W,R,W,W},
    Sivir        = {Q,E,Q,W,Q,R,Q,W,Q,W,R,W,E,W,E,R,E,E},
    Skarner      = {Q,W,Q,W,Q,R,Q,W,Q,W,R,W,E,E,E,R,E,E},
    Sona         = {Q,W,E,Q,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Soraka       = {W,E,W,E,W,R,W,E,W,E,R,E,Q,Q,Q,R,Q,Q},
    Swain        = {W,E,E,Q,E,R,E,Q,E,Q,R,Q,Q,W,W,R,W,W},
    Syndra       = {E,W,Q,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Talon        = {W,E,Q,W,W,R,W,Q,W,Q,R,Q,Q,E,E,R,E,E},
    Taric        = {E,W,Q,W,W,R,Q,W,W,Q,R,Q,Q,E,E,R,E,E},
    Teemo        = {Q,E,W,E,Q,R,E,E,E,Q,R,W,W,Q,W,R,W,Q},
    Thresh       = {E,W,Q,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Tristana     = {E,W,W,E,W,R,W,Q,W,Q,R,Q,Q,Q,E,R,E,E},
    Trundle      = {Q,W,Q,E,Q,R,Q,W,Q,E,R,W,E,W,E,R,W,E},
    Tryndamere   = {E,Q,W,Q,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    TwistedFate  = {W,Q,Q,E,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Twitch       = {Q,E,E,W,E,R,E,Q,E,Q,R,Q,Q,W,W,Q,W,W},
    Udyr         = {R,W,E,R,R,W,R,W,R,W,W,Q,E,E,E,E,Q,Q},
    Urgot        = {E,Q,Q,W,Q,R,Q,W,Q,E,R,W,E,W,E,R,W,E},
    Varus        = {Q,W,E,Q,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Vayne        = {Q,E,W,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Veigar       = {Q,E,Q,W,Q,R,W,W,W,W,R,E,Q,Q,E,R,E,E},
    Vi           = {E,W,Q,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Viktor       = {E,W,E,Q,E,R,E,Q,E,Q,R,Q,W,Q,W,R,W,W},
    Vladimir     = {Q,W,Q,E,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Volibear     = {W,E,W,Q,W,R,E,W,Q,W,R,E,Q,E,Q,R,E,Q},
    Warwick      = {W,Q,Q,W,Q,R,Q,E,Q,E,R,E,E,E,W,R,W,W},
    Xerath       = {Q,E,Q,W,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    XinZhao      = {Q,E,Q,W,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Yorick       = {W,E,Q,E,E,R,E,W,E,Q,R,W,Q,W,Q,R,W,Q},
    Zac          = {E,W,Q,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Zed          = {E,W,Q,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Ziggs        = {Q,W,E,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
    Zilean       = {Q,W,Q,E,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E},
    Zyra         = {E,W,Q,Q,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W},
}
	AutoLevel, menu = uiconfig.add_menu('AutoLevel', 250)
	menu.checkbutton('Autolevel', 'Autolevel', true)
	menu.permashow('Autolevel')

function Level_Spell(letter)  
     if letter == Q then send.key_press(0x69)
     elseif letter == W then send.key_press(0x6a)
     elseif letter == E then send.key_press(0x6b)
     elseif letter == R then send.key_press(0x6c) end
end

function IsLolActive()
    return tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client"
end

function Main()
    if AutoLevel.Autolevel and IsLolActive() and IsChatOpen() == 0 then
        if myHero.name == 'Karma' or myHero.name == 'Jayce' then
            spellLevelSum = (GetSpellLevel(Q) + GetSpellLevel(W) + GetSpellLevel(E) + GetSpellLevel(R))-1
        else spellLevelSum = GetSpellLevel(Q) + GetSpellLevel(W) + GetSpellLevel(E) + GetSpellLevel(R)
        end
        if attempts <= 10 or (attempts > 10 and GetTickCount() > lastAttempt+1500) then
            if spellLevelSum < myHero.selflevel then
                if lastSpellLevelSum ~= spellLevelSum then attempts = 0 end
                letter = skillingOrder[myHero.name][spellLevelSum+1]
                Level_Spell(letter, spellLevelSum)
                attempts = attempts+1
                lastAttempt = GetTickCount()
                lastSpellLevelSum = spellLevelSum
            else
                attempts = 0
            end
        end
    end
    send.tick()
end

SetTimerCallback("Main")