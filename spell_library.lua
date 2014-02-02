--[[
SPELL LIBRARY
 
Example use: Cast('Q', target)
 
Last modified by Vincent (v23 - 6/18/2013 9:57 AM):
 
    v11 - Cast() does not require champion name, eg. Cast('Q', target)
          The old Cast() is now CastInternal()
          Champion names in the table must be the same as that reported by myHero.name
    v12 - Error message change.
    v13 - Deal with weird names using name_mappings. Other changes.
    v14 - Merged with latest changes. Fixed missing commas.
    v15 - Formatting.
    v16 - CreepBlock(x,y,z) & sync with master (no changes)
    v17 - Made all name keys match lol client names (as in champdb.lua)
    v18 - Champ name keys are now case-insensitive
    v19 - Added more champ configs, added missing fn='s
    v20 - Added remaining 70 champions.
    v21 - Fixed a flaw, added 4 champions.
    v22 - Added missing for 5 more champs
    v23 - Added Aatrox.
--]]
 
--require "Utils" -- utils require is below for test purposes
require "spell_damage"
 
toggles = {
    DianaMoonlight = false,
    -- CastAoeToggles added automatically
}
 
-- allows creation of name aliases
name_mappings = {}
name_mappings["wukong"] = 'monkeyking'
 
spelldata = {}
 
function Init()
    spelldata = {  
        aatrox = {
            Q = {fn=CastXYZ, range=650, fireahead={1.65,20}},
            W = {fn=CastTarget, targetself=true},
            E = {fn=CastXYZ, range=1000, fireahead={1,16}},
            R = {fn=CastTarget, targetself=true},
        },	
        ahri = {
            Q = {fn=CastXYZ, range=880, fireahead={2,15}},
            W = {fn=CastTarget, range=800},
            E = {fn=CastXYZ, range=800, fireahead={2,16}, creepblock=true},
            R = {fn=CastXYZ, range=550, mousepos=true},
        },
        akali = {
            Q = {fn=CastTarget, range=600},
            W = {fn=CastTarget, targetself=true},
            E = {fn=CastTarget, range=325},
            R = {fn=CastTarget, range=800},
        },
        alistar = {
            Q = {fn=CastTarget, range=182},
            W = {fn=CastTarget, range=650},
            E = {fn=CastTarget, range=287, targetself=true},
            R = {fn=CastTarget, targetself=true},
        },
        amumu = {
            Q = {fn=CastXYZ, range=1100, fireahead={2,16}, creepblock=true},
            W = {fn=CastAoeToggle, range={400,475}},
            E = {fn=CastTarget, range=200},
            R = {fn=CastMEC, range=550, radius=1100},
        },
        anivia = {
            Q = {fn=CastXYZ, range=1100, fireahead={2,16}, creepblock=true},
            W = {fn=CastTarget, range=1000},
            E = {fn=CastTarget, range=650},
            R = {fn=CastMEC, range=615, radius=400},
        },
        annie = {
            Q = {fn=CastTarget, range=625},
            W = {fn=CastTarget, range=625},
            E = {fn=CastTarget, range=200},
            R = {fn=CastMEC, range=600, radius=230}
        },
        ashe = {
            Q = {fn=CastTarget, targetself=true},
            W = {fn=CastTarget, range=1200, creepblock=true},
            E = {fn=CastXYZ, range=5500},
            R = {fn=CastXYZ, range=1200, fireahead={1,20}},
        },
        blitzcrank = {
            Q = {fn=CastXYZ, range=925, creepblock=true, fireahead={2,16}},
            W = {fn=CastTarget, targetself=true},
            E = {fn=CastTarget, range=200},
            R = {fn=CastTarget, range=550},
        },
        brand = {
            Q = {fn=CastXYZ, range=900, creepblock=true, fireahead={2,16}},
            W = {fn=CastXYZ, range=900, fireahead={3,96}},
            E = {fn=CastTarget, range=625},
            R = {fn=CastTarget, range=750},
        },
        caitlyn = {
            Q = {fn=CastXYZ, range=900, creepblock=true, fireahead={2,16}},
            W = {fn=CastTarget, range=800},
            E = {fn=CastXYZ, range=1000, fireahead={2,32}},
            R = {fn=CastTarget, range=3000},
        },
        cassiopeia = {
            Q = {fn=CastXYZ, range=850, fireahead={6,0}},
            W = {fn=CastXYZ, range=850, fireahead={2.65,25}},
            E = {fn=CastTarget, range=700},
            R = {fn=CastTarget, range=850},
        },
        chogath = {
            Q = {fn=CastXYZ, range=950, fireahead={8.2,0}},
            W = {fn=CastTarget},
            E = {fn=CastTarget, targetself=true},
            R = {fn=CastHot, range=150, hotkey="SPELLR:WEAKMINION RANGE+150 ONESPELLHIT=(125+175*spellr_level+0.7*player_ap) TRUE CD"},
        },
        corki = {
            Q = {fn=CastMEC, range=600, radius=230},
            W = {fn=CastXYZ, range=800, fireahead={2,16}},
            E = {fn=CastTarget, range=600},
            R = {fn=CastXYZ, range=1220, fireahead={2,19}},
        },
        darius = {
            Q = {fn=CastXYZ, range={275,415}, targetself=true},
            W = {fn=CastTarget, targetself=true},
            E = {fn=CastTarget, range=500},
            R = {fn=CastHot, range=475, hotkey="SPELLR:WEAKENEMY CD RANGE=475 HPLESSTHAN=(70+90*spellr_level+(player_ad-50-(63*player_level/18))*75/100) NEAREST"}
        },
        diana = {
            Q = {fn=CastXYZ, range=825, after=function() toggles.DianaMoonlight=1 end},
            W = {fn=CastTarget, range=200},
            E = {fn=CastTarget, range=249},
            R = {fn=CastTarget, range=825, after=function() toggles.DianaMoonlight=0 end, check=function() return toggles.DianaMoonlight == 1 end},
        },
        drmundo = {
            Q = {fn=CastXYZ, range=990, fireahead={2,20}, creepblock=true},
            W = {fn=CastAoeToggle, range={325,400}},
            E = {fn=CastTarget, range=325, targetself=true},
            R = {fn=CastTarget, targetself=true},
        },
        draven = {
            Q = {fn=CastTarget},
            W = {fn=CastTarget},
            E = {fn=CastXYZ},
            R = {fn=CastTarget, range=1000, fireahead={2,20}},
        },
        elise = {
            QMelee = {fn=CastTarget, spellname='EliseSpiderQ'},
            WMelee = {fn=CastTarget, spellname='EliseSpiderW'},
            EMelee = {fn=CastXYZ, spellname='EliseSpiderEInitial', range=1000},
            RMelee = {fn=CastTarget, spellname='EliseRSpider', targetself=true},  
            QRanged = {fn=CastTarget, spellname='EliseHumanQ'},        
            WRanged = {fn=CastTarget, spellname='EliseHumanW'},        
            ERanged = {fn=CastXYZ, spellname='EliseHumanE', range=1000, creepblock=true, fireahead={1.6,13}},        
            RRanged = {fn=CastTarget, spellname='EliseR', range=1000, fireahead={2,20}},        
        },
        evelynn = {
            Q = {fn=CastTarget, range=500},
            W = {fn=CastTarget, range=1000},
            E = {fn=CastTarget, range=225},
            R = {fn=CastMEC, range=650, radius=250}
        },
        ezreal = {
            Q = {fn=CastXYZ, range=1100, creepblock=true, fireahead={2,20}},
            W = {fn=CastXYZ, range=900, fireahead={2,20}},
            E = {fn=CastXYZ, range=550, mousepos=true},
            R = {fn=CastXYZ, range=3000, fireahead={5,2}}
        },
        fiddlesticks = {
            Q = {fn=CastTarget, range=575},
            W = {fn=CastTarget, range=475},
            E = {fn=CastTarget, range=750},
            R = {fn=CastXYZ, range=800, mousepos=true}
        },
        fiora = {
            Q = {fn=CastTarget, range=600},
            W = {fn=CastTarget, targetself=true, range=200},
            E = {fn=CastTarget, targetself=true, range=200},
            R = {fn=CastTarget, range=400}
        },
        fizz = {
            Q = {fn=CastTarget, range=550},
            W = {fn=CastTarget, targetself=true, range=200},
            E = {fn=CastXYZ, mousepos=true, range=800},
            R = {fn=CastTarget, range=400}
        },
        galio = {
            Q = {fn=CastXYZ, range=940, fireahead={2,13}},
            W = {fn=CastTarget, targetself=true, range=200},
            E = {fn=CastXYZ, range=1180, fireahead={2,13}},
            R = {fn=CastTarget, range=600}
        },
        gangplank = {
            Q = {fn=CastTarget, range=625},
            W = {fn=CastTarget, targetself=true},
            E = {fn=CastTarget, targetself=true, range=1200},
            R = {fn=CastTarget, range=3800}
        },
        garen = {
            Q = {fn=CastTarget, targetself=true, range=700},
            W = {fn=CastTarget, targetself=true, range=125},
            E = {fn=CastTarget, range=165},
            R = {fn=CastHot, range=400, hotkey="SPELLR:WEAKENEMY COOLDOWN RANGE=400 ONESPELLHIT=#(175*spellr_level+(target_hpmax-target_hp)/(40-5*spellr_level)*10) LEASTHP"}
        },
        gragas = {
            Q = {fn=CastXYZ, range=1100, fireahead={1,10}},
            W = {fn=CastTarget, targetself=true, range=125},
            E = {fn=CastXYZ, range=600, fireahead={1,9}},
            R = {fn=CastTarget, range=1050}
        },
        graves = {
            Q = {fn=CastXYZ, fireahead={2,20}},
            W = {fn=CastXYZ, fireahead={2,20}},
            E = {fn=CastXYZ, range=550, mousepos=true},
            R = {fn=CastXYZ, fireahead={2,20}},
        },
        hecarim = {
            Q = {fn=CastTarget, range=350},
            W = {fn=CastTarget, targetself=true, range=525},
            E = {fn=CastTarget, targetself=true, range=1000},
            R = {fn=CastTarget, range=1000, fireahead={2,10}},
        },
        heimerdinger = {
            Q = {fn=CastXYZ, range=250, mousepos=true},
            W = {fn=CastTarget, range=1000},
            E = {fn=CastTarget, range=925, fireahead={2,75}},
            R = {fn=CastTarget, targetself=true},
        },
        irelia = {
            Q = {fn=CastTarget, range=650},
            W = {fn=CastTarget, targetself=true},
            E = {fn=CastTarget, range=425},
            R = {fn=CastXYZ, range=1000, fireahead={2,10}},
        },
        janna = {
            Q = {fn=CastXYZ, range=1100},
            W = {fn=CastTarget, range=600},
            E = {fn=CastTarget, range=800},
            R = {fn=CastTarget, targetself=true},
        },
        jarvaniv = {
            Q = {fn=CastXYZ, range=770},
            W = {fn=CastTarget, range=300, targetself=true},
            E = {fn=CastXYZ, range=830},
            R = {fn=CastTarget, range=650},
        },
        jax = {
            Q = {fn=CastXYZ, range=700},
            W = {fn=CastTarget, range=187, targetself=true},
            E = {fn=CastTarget, range=187, targetself=true},
            R = {fn=CastTarget, range=187, targetself=true},
        },
        jayce = {
            QMelee = {fn=CastTarget, spellname='JayceToTheSkies'},
            WMelee = {fn=CastTarget, spellname='JayceStaticField', targetself=true},
            EMelee = {fn=CastTarget, spellname='JayceThunderingBlow', range=1000},
            RMelee = {fn=CastTarget, spellname='JayceStanceHtG', targetself=true},  
            QRanged = {fn=CastXYZ, spellname='EliseHumanE', range=1000, creepblock=true, fireahead={1.6,22}},        
            WRanged = {fn=CastTarget, spellname='jaycehypercharge', targetself=true},        
            ERanged = {fn=CastTarget, spellname='jayceaccelerationgate', targetself=true},        
            RRanged = {fn=CastTarget, spellname='jaycestancegth', targetself=true},        
        },
        karma = {
            Q = {fn=CastXYZ, range=950, fireahead={1.6,22}},
            W = {fn=CastTarget, range=650},
            E = {fn=CastTarget, range=800},
            R = {fn=CastTarget},
        },
        karthus = {
            Q = {fn=CastXYZ, range=875, fireahead={9,99}},
            W = {fn=CastXYZ, range=1000},
            E = {fn=CastAoeToggle, range={325,450}},
            R = {fn=CastTarget, targetself=true},
        },
        kassadin = {
            Q = {fn=CastTarget, range=650},
            W = {fn=CastHot, range=710, hotkey="SPELLW:WEAKENEMY + ATTACK:WEAKENEMY SMARTCAST STRAFE"},
            E = {fn=CastTarget, range=400},
            R = {fn=CastTarget, range=600},
        },
        katarina = {
            Q = {fn=CastTarget, range=675},
            W = {fn=CastTarget, range=375},
            E = {fn=CastTarget, range=700},
            R = {fn=CastTarget, range=550},
        },
        kayle = {
            Q = {fn=CastTarget, range=650},
            W = {fn=CastTarget, range=900},
            E = {fn=CastTarget, targetself=true},
            R = {fn=CastTarget, range=990},
        },
        kennen = {
            Q = {fn=CastXYZ, range=1050, fireahead={2,16}},
            W = {fn=CastTarget, range=800},
            E = {fn=CastTarget, targetself=true, range=1000},
            R = {fn=CastTarget, range=500, targetself=true},
        },
        khazix = {
            Q = {fn=CastTarget, range=325},
            W = {fn=CastXYZ, range=600, creepblock=true, fireahead={1.6,16}},
            E = {fn=CastXYZ, range=600, fireahead={1,16}},
            R = {fn=CastTarget, targetself=true},
        },
        kogmaw = {
            Q = {fn=CastTarget, range=625},
            W = {fn=CastTarget, range=710, targetself=true},
            E = {fn=CastXYZ, range=1000, fireahead={1,40}},
            R = {fn=CastXYZ, range=1000, fireahead={8,99}},
        },
        leblanc = {
            Q = {fn=CastTarget, range=700},
            W = {fn=CastTarget, range=600},
            E = {fn=CastXYZ, range=950, creepblock=true, fireahead={1,16}},
            R = {fn=CastTarget},
        },
        leesin = {
            Q = {fn=CastTarget, range=975, creepblock=true, fireahead={2.6,16}},
            W = {fn=CastTarget, range=700},
            E = {fn=CastMEC, targetself=true, range=350, radius=350},
            R = {fn=CastTarget, range=375},
        },
        leona = {
            Q = {fn=CastTarget, range=700},
            W = {fn=CastTarget, range=700},
            E = {fn=CastXYZ, range=700, fireahead={1.8,32}},
            R = {fn=CastMEC, range=1200, fireahead={5,0}, radius=250},
        },
        lissandra = {
            Q = {fn=CastXYZ, range=725, fireahead={1.6,14}},
            W = {fn=CastTarget, targetself=true, range=500},
            E = {fn=CastXYZ, range=1050, radius=600, fireahead={1.6,14}},
            R = {fn=CastMEC, targetself=true, range=600, fireahead={5,0}, radius=600},
        },
        lulu = {
            Q = {fn=CastXYZ, range=925, fireahead={1.6,14}},
            W = {fn=CastTarget, range=650},
            E = {fn=CastTarget, range=650},
            R = {fn=CastTarget, range=900},
        },
        lux = {
            Q = {fn=CastXYZ, creepblock=true, range=1150, fireahead={1.6,12}},
            W = {fn=CastTarget, targetself=true, range=1000, fireahead={2,14}},
            E = {fn=CastXYZ, range=1100, radius=600, fireahead={1.6,14}},
            R = {fn=CastXYZ, range=3000, fireahead={5,0}},
        },
        malphite = {
            Q = {fn=CastTarget, range=625},
            W = {fn=CastTarget, targetself=true, range=200},
            E = {fn=CastTarget, targetself=true, range=200},
            R = {fn=CastMEC, radius=300, range=1000},
        },
        malzahar = {
            Q = {fn=CastTarget, range=900},
            W = {fn=CastMEC, radius=250, range=800},
            E = {fn=CastTarget, range=650},
            R = {fn=CastTarget, range=700},
        },
        maokai = {
            Q = {fn=CastTarget, range=600},
            W = {fn=CastTarget, range=650},
            E = {fn=CastXYZ, range=1100, fireahead={8,0}},
            R = {fn=CastTarget, range=575},
        },
        masteryi = {
            Q = {fn=CastTarget, range=650},
            W = {fn=CastTarget, targetself=true},
            E = {fn=CastTarget, targetself=true},
            R = {fn=CastTarget, targetself=true},
        },
        missfortune = {
            Q = {fn=CastTarget, range=950},
            W = {fn=CastTarget, targetself=true},
            E = {fn=CastTarget, range=800},
            R = {fn=CastTarget, range=1400},
        },
        monkeyking = {
            Q = {fn=CastTarget, targetself=true},
            W = {fn=CastTarget, targetself=true},
            E = {fn=CastTarget, range=625},
            R = {fn=CastTarget, spellname='MonkeyKingSpinToWin', targetself=true, range=162},
        },
        mordekaiser = {
            Q = {fn=CastTarget, targetself=true},
            W = {fn=CastTarget, range=750},
            E = {fn=CastTarget, range=700},
            R = {fn=CastTarget, range=850},
        },
        morgana = {
            Q = {fn=CastXYZ, range=1300, creepblock=true, fireahead={1,16}},
            W = {fn=CastTarget, range=900},
            E = {fn=CastTarget, range=750},
            R = {fn=CastTarget, range=600},
        },
        nami = {
            Q = {fn=CastXYZ, fireahead={2,16}, range=875},
            W = {fn=CastTarget, targetself=true},
            E = {fn=CastTarget, targetself=true},
            R = {fn=CastXYZ, range=2750},
        },
        nasus = {
            Q = {fn=CastTarget, targetself=true, range=125},
            W = {fn=CastTarget, range=800},
            E = {fn=CastTarget, range=750},
            R = {fn=CastTarget, targetself=true},
        },
        nautilus = {
            Q = {fn=CastXYZ, range=950},
            W = {fn=CastTarget, targetself=true},
            E = {fn=CastTarget, range=600},
            R = {fn=CastTarget, range=850},
        },
        nidalee = {
            Q = {fn=CastXYZ, range=1300, creepblock=true, fireahead={2,13}},
            W = {fn=CastTarget, range=900},
            E = {fn=CastTarget, range=750},
            R = {fn=CastTarget, range=600},
        },
        nocturne = {
            Q = {fn=CastXYZ, range=1200},
            W = {fn=CastTarget, targetself=true},
            E = {fn=CastTarget, range=750},
            R = {fn=CastTarget, range=3500},
        },
        nunu = {
            Q = {fn=CastHot, range=150, hotkey="SPELLQ:WEAKMINION RANGE=150"},
            W = {fn=CastTarget, range=700},
            E = {fn=CastTarget, range=550},
            R = {fn=CastTarget, targetself=true, range=700},
        },
        olaf = {
            Q = {fn=CastXYZ, range=1000, fireahead={2,16}},
            W = {fn=CastTarget, targetself=true, range=150},
            E = {fn=CastTarget, range=150},
            R = {fn=CastTarget, targetself=true},
        },
        orianna = {
            Q = {fn=CastXYZ, range=825, fireahead={1.2,18}},
            W = {fn=CastTarget, targetself=true},
            E = {fn=CastTarget, range=1100},
            R = {fn=CastTarget, targetself=true},
        },
        pantheon = {
            Q = {fn=CastTarget, range=600},
            W = {fn=CastTarget, range=600},
            E = {fn=CastTarget, range=600},
            R = {fn=CastTarget, range=5500},
        },
        poppy = {
            Q = {fn=CastTarget, range=140},
            W = {fn=CastTarget, range=140},
            E = {fn=CastTarget, range=525},
            R = {fn=CastTarget, range=900},
        },
       quinn = {
            Q = {},
            W = {},
            E = {},
            R = {},
        },
        rammus = {
            Q = {fn=CastTarget, targetself=true, range=1500},
            W = {fn=CastTarget, range=400},
            E = {fn=CastTarget, range=325},
            R = {fn=CastTarget, range=300},
        },
        renekton = {
            Q = {fn=CastTarget, targetself=true, range=225},
            W = {fn=CastTarget, targetself=true, range=400},
            E = {fn=CastTarget, range=450},
            R = {fn=CastTarget, range=175},
        },
        rengar = {
            Q = {fn=CastTarget, range=150},
            W = {fn=CastTarget, range=500},
            E = {fn=CastTarget, range=575},
            R = {fn=CastTarget, targetself=true, range=1000},
        },
        riven = {
            Q = {fn=CastTarget, range=260},
            W = {fn=CastTarget, range=125},
            E = {fn=CastTarget, range=325},
            R = {fn=CastTarget, range=900},
        },
        rumble = {
            Q = {fn=CastTarget, range=600},
            W = {fn=CastTarget, range=300},
            E = {fn=CastXYZ, range=825, fireahead={2,15}},
            R = {fn=CastXYZ, range=1700, fireahead={0,15}},
        },
        ryze = {
            Q = {fn=CastTarget, range=650},
            W = {fn=CastTarget, targetself=true, range=680},
            E = {fn=CastTarget, range=675},
            R = {fn=CastTarget, targetself=true, range=680},
        },
        sejuani = {
            Q = {fn=CastTarget, range=650},
            W = {fn=CastAoeToggle, range={325,400}},
            E = {fn=CastTarget, range=1000},
            R = {fn=CastXYZ, fireahead={0,15}, range=1175},
        },
        shaco = {
            Q = {fn=CastXYZ, range=400},
            W = {fn=CastXYZ, range=425},
            E = {fn=CastTarget, range=625},
            R = {},
        },
        shen = {
            Q = {fn=CastTarget, range=475},
            W = {fn=CastTarget, targetself=true, range=150},
            E = {fn=CastXYZ, fireahead={2,12}, range=575},
            R = {fn=CastTarget},
        },
        shyvana = {
            Q = {fn=CastTarget, range=150},
            W = {fn=CastTarget, range=165},
            E = {fn=CastTarget, range=925},
            R = {fn=CastXYZ, range=1000},
        },
        singed = {
            Q = {fn=CastAoeToggle, range={1,400}},
            W = {fn=CastXYZ, range=1000},
            E = {fn=CastTarget, range=125},
            R = {fn=CastTarget, targetself=true},
        },
        sion = {
            Q = {fn=CastTarget, range=550},
            W = {fn=CastTarget, range=550},
            E = {fn=CastAoeToggle, range={1,400}},
            R = {fn=CastTarget, targetself=true},
        },
        sivir = {
            Q = {fn=CastXYZ, fireahead={3.3,13.3}, range=1000},
            W = {fn=CastTarget, targetself=true, range=510},
            E = {fn=CastTarget, targetself=true},
            R = {fn=CastTarget, targetself=true},
        },
        skarner = {
            Q = {fn=CastTarget, targetself=true, range=350},
            W = {fn=CastTarget, targetself=true, range=550},
            E = {fn=CastXYZ, range=600},
            R = {fn=CastTarget, range=350},
        },
        sona = {
            Q = {fn=CastTarget, range=700},
            W = {fn=CastTarget, range=1000},
            E = {fn=CastTarget, range=1000},
            R = {fn=CastXYZ, range=1000},
        },
        soraka = {
            Q = {fn=CastTarget, range=530},
            W = {fn=CastTarget, targetself=true, range=750},
            E = {fn=CastTarget, range=725},
            R = {fn=CastTarget},
        },
        swain = {
            Q = {fn=CastTarget, range=625},
            W = {fn=CastXYZ, fireahead={4,99}, range=800},
            E = {fn=CastTarget, range=625},
            R = {fn=CastAoeToggle, range={1,650}},
        },
        syndra = {
            Q = {fn=CastTarget, range=800},
            W = {},
            E = {fn=CastTarget, range=650},
            R = {fn=CastTarget, range=750},
        },
        talon = {
            Q = {fn=CastTarget, targetself=true},
            W = {fn=CastTarget},
            E = {fn=CastTarget, range=700},
            R = {fn=CastTarget, targetself=true},
        },
        taric = {
            Q = {fn=CastTarget, targetself=true},
            W = {fn=CastTarget, targetself=true, range=200},
            E = {fn=CastTarget, range=625},
            R = {fn=CastTarget, targetself=true, range=200},
        },
        teemo = {
            Q = {fn=CastTarget, range=580},
            W = {fn=CastTarget, targetself=true, range=1000},
            E = {},
            R = {fn=CastXYZ, range=230},
        },
        thresh = {
            Q = {fn=CastXYZ, fireahead={2,18}, creepblock=true, range=1075},
            W = {fn=CastTarget, range=950},
            E = {fn=CastTarget, range=800},
            R = {fn=CastTarget, targetself=true, range=430},
        },
        tristana = {
            Q = {fn=CastTarget, targetself=true},
            W = {fn=CastXYZ, fireahead={2,20}},
            E = {fn=CastTarget},
            R = {fn=CastTarget},
        },
        trundle = {
            Q = {fn=CastTarget, targetself=true, range=125},
            W = {fn=CastXYZ, range=900},
            E = {fn=CastXYZ, fireahead={0,15}, range=1000},
            R = {fn=CastTarget, range=700},
        },
        tryndamere = {
            Q = {fn=CastTarget, targetself=true},
            W = {fn=CastTarget, range=400},
            E = {fn=CastXYZ, range=660},
            R = {fn=CastTarget, targetself=true},
        },
        twistedfate = {
            Q = {fn=CastXYZ, fireahead={1,10}, range=1450},
            W = {},
            E = {},
            R = {},
        },
        twitch = {
            Q = {fn=CastTarget, targetself=true},
            W = {fn=CastXYZ, fireahead={0,15}, range=950},
            E = {fn=CastTarget, targetself=true, range=1200},
            R = {fn=CastTarget, targetself=true},
        },
        udyr = {
            Q = {fn=CastTarget, targetself=true},
            W = {fn=CastTarget, targetself=true},
            E = {fn=CastTarget, targetself=true},
            R = {fn=CastTarget, targetself=true},
        },
        urgot = {
            Q = {fn=CastXYZ, fireahead={1.6,15}, range=1200},
            W = {fn=CastTarget, targetself=true},
            E = {fn=CastXYZ, fireahead={1.6,12}, range=900},
            R = {fn=CastTarget, range=850},
        },
        varus = {
            Q = {fn=CastTarget, range=850},
            W = {},
            E = {fn=CastXYZ, fireahead={1.6,12}, range=925},
            R = {fn=CastTarget, range=1075},
        },
        vayne = {
            Q = {fn=CastXYZ, mousepos=true},
            W = {},
            E = {fn=CastTarget, range=650},
            R = {fn=CastTarget, targetself=true, range=600},
        },
        veigar = {
            Q = {fn=CastTarget, range=650},
            W = {fn=CastMEC, range=900, radius=225},
            E = {fn=CastMEC, range=650, radius=425},
            R = {fn=CastTarget, range=650},
        },
        vi = {
            Q = {},
            W = {},
            E = {fn=CastTarget, targetself=true},
            R = {fn=CastTarget, range=800},
        },
        viktor = {
            Q = {fn=CastTarget, range=600},
            W = {fn=CastMEC, range=625, radius=300},
            E = {fn=CastXYZ, range=540},
            R = {fn=CastMEC, range=700, radius=300},
        },
        vladimir = {
            Q = {fn=CastTarget, range=600},
            W = {fn=CastTarget, targetself=true},
            E = {fn=CastTarget, targetself=true, range=610},
            R = {fn=CastMEC, range=700, radius=350},
        },
        volibear = {
            Q = {fn=CastTarget, range=1300},
            W = {fn=CastTarget, range=400},
            E = {fn=CastTarget, range=425},
            R = {fn=CastTarget, targetself=true},
        },
        warwick = {
            Q = {fn=CastTarget, range=400},
            W = {fn=CastTarget, targetself=true},
            E = {},
            R = {fn=CastTarget, range=700},
        },
        xerath = {
            Q = {fn=CastXYZ, range=1300, fireahead={1,20}},
            W = {},
            E = {fn=CastTarget, range=1000},
            R = {fn=CastXYZ, range=1300, fireahead={1,20}},
        },
        xinzhao = {
            Q = {fn=CastTarget, targetself=true, range=200},
            W = {fn=CastTarget, targetself=true, range=200},
            E = {fn=CastTarget, range=600},
            R = {fn=CastTarget, targetself=true, range=187},
        },
        yorick = {
            Q = {fn=CastTarget, targetself=true, range=200},
            W = {fn=CastTarget, range=600},
            E = {fn=CastTarget, range=550},
            R = {fn=CastTarget},
        },
        zac = {
            Q = {fn=CastXYZ, range=550},
            W = {fn=CastTarget, targetself=true, range=125},
            E = {},
            R = {fn=CastTarget, targetself=true, range=200},
        },
        zed = {
            Q = {fn=CastXYZ, range=900},
            W = {fn=CastXYZ, range=550},
            E = {fn=CastTarget, targetself=true, range=290},
            R = {fn=CastXYZ, range=625},
        },
        ziggs = {
            Q = {fn=CastXYZ, fireahead={0.3,12}, range=850},
            W = {fn=CastXYZ, fireahead={0.3,12}, range=1000},
            E = {fn=CastXYZ, fireahead={0.3,12}, range=900},
            R = {fn=CastXYZ, fireahead={0.3,12}, range=900},
        },
        zilean = {
            Q = {fn=CastTarget, range=700},
            W = {fn=CastTarget, targetself=true},
            E = {fn=CastTarget, targetself=true},
            R = {fn=CastTarget},
        },
        zyra = {
            Q = {fn=CastXYZ, fireahead={4,99}, range=825},
            W = {fn=CastXYZ, fireahead={3,0}, range=825},
            E = {fn=CastXYZ, fireahead={2,12}, range=1100},
            R = {fn=CastMEC, range=700, radius=1100},
        },
    }
end
 
function Msg(...)
    if _console_mode then
        print(...)
    else
        local n = select('#', ...)
        local t = {}
        for i=1,n do
            local v = select(i, ...)
            table.insert(t, tostring(v))
            table.insert(t, '\t')
        end
        table.insert(t, '\n')
        local s = table.concat(t, '')
        print(s)
    end    
end
 
function GetInternalName(name)
    name = name:lower()
    local mapped = name_mappings[name]
    if mapped == nil then
        return name
    else
        return mapped
    end
end
 
function Cast(...)
    Msg('', 'Cast', DebugArgs(...))
    local champ = GetInternalName(myHero.name)
    CastInternal(champ, ...)
end
 
function CastInternal(...)
    Msg('', 'CastInternal', DebugArgs(...))
    local n = select('#', ...)
    if n<2 then
        Msg('\nCastInternal requires at least two args, champ and spell name')
        return
    end
    local champ = select(1, ...)
    local spell = select(2, ...)    
    if spelldata[champ] == nil then
        Msg('\nChamp was not found in spelldata: '..champ)
        return
    end
    if spelldata[champ][spell] == nil then
        Msg(string.format('\nSpell was not found in spelldata: champ=%s spell=%s', champ, spell))
        return
    end
    local data = spelldata[champ][spell]
    for k,v in pairs(data) do
        Msg('', '', k, v)
    end
    if data.fn == nil then        
        Msg(string.format('Spell data undefined for champ=%s, spell=%s', champ, spell))
    else
        data.fn(...)
    end
end
 
function CastXYZ(champ, spell, target)
    Msg('', 'CastXYZ', champ, spell, target)
    local data = spelldata[champ][spell]
    local x, y, z
    if data.fireahead ~= nil then
        x, y, z = GetFireahead(target, data.fireahead[1], data.fireahead[2])
    elseif data.mousepos == true then
        x, y, z = mousePos.x,0,mousePos.z
    elseif data.targetself == true then
        x, y, z = myHero.x, myHero.y, myHero.z
    -- else use target x, y, z
    else
        x, y, z = target.x, target.y, target.z
    end
    local withinRange = IsWithinRange(data, target)
    local validSpellName = IsValidSpellName(spell, data)
    if CanCastSpell(spell) and ValidTarget(target) and withinRange and validSpellName and (data.check == nil or data.check()) then
        if data.creepblock and CreepBlock(x,y,z) == 0 then
            CastSpellXYZ(spell,x,y,z)
            if data.after ~= nil then
                data.after()
            end
        end
    end
end
 
function CastTarget(champ, spell, target)
    Msg('', 'CastTarget', champ, spell, target)
    local data = spelldata[champ][spell]
    local withinRange = IsWithinRange(data, target)
    local validSpellName = IsValidSpellName(spell, data)
    if CanCastSpell(spell) and ValidTarget(target) and withinRange and validSpellName and (data.check == nil or data.check()) then
        if data.targetself then
            CastSpellTarget(spell,myHero)
        else
            CastSpellTarget(spell,target)
        end
        if data.after ~= nil then
            data.after()
        end
    end
end
 
-- annie r, corki q
function CastMEC(champ, spell, target)
    Msg('', 'CastMEC', champ, spell, target)
    local data = spelldata[champ][spell]
    local radius = data.radius
    local range = data.range
 
    if CanCastSpell(spell) and ValidTarget(target) then
        local pos = GetMEC(radius, range, target)
        if pos then
            CastSpellXYZ("R", pos.x, 0, pos.z)
        else
            CastSpellTarget("R", target)
        end
    end
end
 
-- cho r, darius r, kass w
function CastHot(champ, spell, target, text)
    Msg('', 'CastHot', champ, spell, target, text)
    local data = spelldata[champ][spell]
    if ValidTarget(target) and (data.range==nil or GetDistance(myHero,target) < data.range) then
        CastHotkey(data.hotkey)
    end
end
 
-- amumu w, mundo w
-- not sure about the original logic, forces toggle to stay on if target is in range
-- maybe allow user to decide what to do, with param or whatever
--   turn on if target (default)
--   turn on if no target (ForceOn)
--   turn off if no target (default)
--   turn off if target (ForceOff)
-- uses range={low,high} and a toggle
function CastAoeToggle(champ, spell, target)
    Msg('', 'CastAoeToggle', champ, spell, target)
    local data = spelldata[champ][spell]
    local key = champ .. spell
    if toggles[key] == nil then
        toggles[key] = false
    end
    local low, high = 0, 0
    if type(data.range)=='table' then
        low = data.range[1]
        high = data.range[2]
    elseif data.range~=nil then
        low, high = data.range, data.range    
    end
    local dist = GetDistance(target)
    if CanCastSpell(spell) then
        if toggles[key] then
            -- toggle off, but only when out of range (forces it to stay on...)
            if dist > high then
                CastSpellTarget("W",myHero)
                toggles[key] = false
            end
        else
            if dist < low then
                CastSpellTarget("W",myHero)
                toggles[key] = true
            end
        end
    end
 
end
 
function IsWithinRange(data, target)
    if data.range == nil then
        return true
    else
        local dist = GetDistance(target)
        if type(data.range)=='table' then -- darius q
            local low = data.range[1]
            local high = data.range[1]
            return dist > low and dist < high
        else
            return dist < data.range
        end
    end
end
 
function IsValidSpellName(spell, data)
    if data.spellname==nil then
        return true
    else
        local spell_letter = spell:sub(1,1)
        local spellname = GetSpellName(myHero, spell_letter)
        if spellname==data.spellname then
            return true
        else
            return false
        end
    end
end
 
function GetSpellName(unit, spell)
    if spell=='Q' then
        return unit.SpellNameQ
    elseif spell=='W' then
        return unit.SpellNameW
    elseif spell=='E' then
        return unit.SpellNameE
    elseif spell=='R' then
        return unit.SpellNameR
    end
end
 
function DebugArgs(...)
    local n = select('#', ...)
    local s = ''
    local v
    for i=1,n do
        v = select(i, ...)
        if v == nil then v = 'nil' end
        s = s .. tostring(v) .. ', '
    end
    return s
end
 
-- self test -------------------------------------------------------------------
 
_console_mode = CanUseSpell==nil
if not _console_mode then
    require "Utils"
    Init()
else
    function file_exists(name)
       local f=io.open(name,'r')
       if f~=nil then io.close(f) return true else return false end
    end
 
    function GetDistance() return 1 end
    function GetMEC() return {center={x=1,y=2,z=3}} end
    function CastSpellTarget() Msg('','CastSpellTarget') end
    function CastSpellXYZ() Msg('','CastSpellXYZ') end
    function CastHotkey() Msg('','CastHotkey') end
    function GetFireahead() Msg('','GetFireahead') end    
    function CanCastSpell() return true end
    function CreepBlock() return false end
    function ValidTarget() return true end
    local target = {x=0,y=0,z=0}
    mousePos = {x=0,y=0,z=0}
    myHero = {x=0,y=0,z=0, SpellNameQ='a', SpellNameW='b', SpellNameQ='c', SpellNameQ='d'}
    Init()
 
    local champs = {}
    for champ,spells in pairs(spelldata) do        
        table.insert(champs, champ)
    end
    table.sort(champs)
   
    for i,champ in ipairs(champs) do
        spells = spelldata[champ]
        for spell,data in pairs(spells) do
            Msg(champ, spell)
            CastInternal(champ, spell, target)
        end
    end
   
    Msg('---------------------------')
    Msg('test helpful error messages')
    CastInternal()
    CastInternal('Foo')
    CastInternal('Foo','Bar')
    CastInternal('ahri','Bar')
   
    -- test wukong name mapping
    Msg("Wukong name test")
    Msg(GetInternalName("Wukong"))
   
    Msg('---------------------------')
   
    -- test keys using champdb
    if true and file_exists('champdb.lua') then
        require 'champdb'
        for name,champ in pairs(champdb) do
            name = name:lower()
            if spelldata[name]==nil then
                Msg('*** Expected champ in spelldata by name: ', name)
            end
        end
    end
   
    -- make sure keys are lowercase
    for name,data in pairs(spelldata) do
        if name~=name:lower() then
            Msg('*** Expected all lowercase champ key: ', name)
        end
    end
   
    Msg('*tests complete*')
end