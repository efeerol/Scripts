require 'Utils'
require 'winapi'
 
local version = '1.1'
local target
local targetignite
 
-- Auto Summoner Spells thanks Dasia!
 
local healThreshold = 0.25
local barrierThreshold = 0.25
local manaThreshold = 0.40
 
local smiteTargets = {
  Baron   = { Object = nil, Match = "Worm2.1.1"         },
  Dragon  = { Object = nil, Match = "Dragon6.1.1"       },
  Golem1  = { Object = nil, Match = "AncientGolem1.1.1" },
  Golem2  = { Object = nil, Match = "AncientGolem7.1.1" },
  Lizard1 = { Object = nil, Match = "LizardElder4.1.1"  },
  Lizard2 = { Object = nil, Match = "LizardElder10.1.1" }
}
 
local castTimer = 0
local target = nil
local minions = { }
 
local summonerSpells = {
  Clarity = { Key = nil, Match = "SummonerMana",    Spell = "Clarity" },
  Heal    = { Key = nil, Match = "SummonerHeal",    Spell = "Heal"    },
  Smite   = { Key = nil, Match = "SummonerSmite",   Spell = "Smite"   },
  Cleanse = { Key = nil, Match = "SummonerBoost",   Spell = "Cleanse" },
  Barrier = { Key = nil, Match = "SummonerBarrier", Spell = "Barrier" },
  Exhaust = { Key = nil, Match = "SummonerExhaust", Spell = "Exhaust" },
  Ignite  = { Key = nil, Match = "SummonerDot",     Spell = "Ignite"  }
}
 
local summonerD = nil
local summonerF = nil
 
for s,summoner in pairs(summonerSpells) do
  if myHero.SummonerD == summoner.Match then
    summoner.Key = "D"
    summonerD = s
  elseif myHero.SummonerF == summoner.Match then
    summoner.Key = "F"
    summonerF = s
  end
end
 
printtext("Summonder D=" .. tostring(summonerD) .. "\n")
printtext("Summonder F=" .. tostring(summonerF) .. "\n")
 
if summonerD ~= nil or summonerF ~= nil then
  SumConf = scriptConfig("Summoner Spells", "SumSpells")
  if summonerSpells["Clarity"].Key ~= nil then SumConf:addParam("Clarity", "Auto Clarity", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("L")) end
  if summonerSpells["Heal"].Key ~= nil then SumConf:addParam("Heal", "Auto Heal", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte(";")) end
  if summonerSpells["Smite"].Key ~= nil then SumConf:addParam("Smite", "Auto Smite", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("J")) end
  if summonerSpells["Cleanse"].Key ~= nil then SumConf:addParam("Cleanse", "Auto Cleanse", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("'")) end
  if summonerSpells["Barrier"].Key ~= nil then SumConf:addParam("Barrier", "Auto Barrier", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("h")) end
  if summonerSpells["Exhaust"].Key ~= nil then SumConf:addParam("Exhaust", "Auto Exhaust", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("[")) end
  if summonerSpells["Ignite"].Key ~= nil then SumConf:addParam("Ignite", "Auto Ignite", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("]")) end
end
 
function OnTick()
  UpdateTables()
  if (GetClock() - castTimer) >= 100 and myHero.dead ~= 1 then
    castTimer = GetClock()
    if summonerSpells["Clarity"].Key ~= nil and SumConf.Clarity then Clarity() end
    if summonerSpells["Heal"].Key ~= nil  and SumConf.Heal then Heal() end
    if summonerSpells["Smite"].Key ~= nil and SumConf.Smite then Smite() end
    if summonerSpells["Cleanse"].Key ~= nil and SumConf.Cleanse then Cleanse() end
    if summonerSpells["Barrier"].Key ~= nil and SumConf.Barrier then Barrier() end
    if summonerSpells["Exhaust"].Key ~= nil and SumConf.Exhaust then Exhaust() end
    if summonerSpells["Ignite"].Key ~= nil and SumConf.Ignite then Ignite() end
  end
end
 
function OnCreateObj(object)
  if summonerSpells["Smite"].Key ~= nil then
    if object and object ~= nil and object.charName ~= nil then
      if object.charName == smiteTargets.Baron.Match then smiteTargets.Baron.Object = object
      elseif object.charName == smiteTargets.Dragon.Match then smiteTargets.Dragon.Object = object
      elseif object.charName == smiteTargets.Golem1.Match then smiteTargets.Golem1.Object = object
      elseif object.charName == smiteTargets.Golem2.Match then smiteTargets.Golem2.Object = object
      elseif object.charName == smiteTargets.Lizard1.Match then smiteTargets.Lizard1.Object = object
      elseif object.charName == smiteTargets.Lizard2.Match then smiteTargets.Lizard2.Object = object end
    end
  end
end
 
function UpdateTables()
  for i, creep in pairs(smiteTargets) do
    if creep.Object == nil or creep.Object.dead == 1 then
      creep.object = nil
    end
  end
  for i=1, objManager:GetMaxNewObjects(), 1 do
    object = objManager:GetNewObject(i)
    if object and object ~= nil and object.charName ~= nil then
      for t, creep in pairs(smiteTargets) do
        if object.charName == creep.Match then creep.Object = object end
      end
    end
  end
end
 
function Clarity()
  local threshold = math.round(myHero.maxMana * manaThreshold)
  local amount = math.round(myHero.maxMana * 0.4)
  local key = tostring(summonerSpells["Clarity"].Key)
  if myHero.mana <= threshold then
    if IsSpellReady(key) == 1 then
      CastSpellTarget(key, myHero)
    end
  end
end
 
function Heal()
  local threshold = math.round(myHero.maxHealth * healThreshold)
  local amount = 75 + (15 * myHero.selflevel)
  local key = tostring(summonerSpells["Heal"].Key)
  if myHero.health <= threshold then
    if IsSpellReady(key) == 1 then
      CastSpellTarget(key, myHero)
    end
  end
end
 
function Smite()
  local damage = 460 + (30 * myHero.selflevel)
  local key = tostring(summonerSpells["Smite"].Key)
  if IsSpellReady(key) == 1 then
    for i, minion in pairs(smiteTargets) do
      if minion ~= nil and minion.Object ~= nil and GetDistance(minion.Object) <= 650 and minion.Object.health <= damage then
        CastSpellTarget(key, minion.Object)
      end
    end
  end
end
 
function Cleanse()
  local key = tostring(summonerSpells["Cleanse"].Key)
  if summonerSpells["Cleanse"].Key ~= nil and CanCastSpell(summonerSpells["Cleanse"].Key) then
    -- TODO: this one is more tricksy
  end
end
 
function Barrier()
  local threshold = math.round(myHero.maxHealth * barrierThreshold)
  local amount = 95 + (25 * myHero.selflevel)
  local key = tostring(summonerSpells["Barrier"].Key)
  if IsSpellReady(key) == 1 then
    if myHero.health <= threshold then
      CastSpellTarget(key, myHero)
    end
  end
end
 
function Exhaust()
  local key = tostring(summonerSpells["Exhaust"].Key)
  -- TODO
end
 
function Ignite()
  local damage = 50 + (20 * myHero.selflevel)
  local key = tostring(summonerSpells["Ignite"].Key)
  if IsSpellReady(key) == 1 then
    target = GetWeakEnemy("TRUE", 610)
    if target ~= nil and target.health < damage then
      CastSpellTarget(key, target)
    end
  end
end

function JarvanRun()
    if IsChatOpen() == 0 and tostring(winapi.get_foreground_window()) == "League of Legends (TM) Client" then
        
        target = GetWeakEnemy('Phys',800)
        targetignite = GetWeakEnemy('TRUE',600)
       
        if myHero.SpellTimeQ > 1.0 then
        QRDY = 1
        else QRDY = 0
        end
        if myHero.SpellTimeW > 1.0 then
        WRDY = 1
        else WRDY = 0
        end
        if myHero.SpellTimeE > 1.0 then
        ERDY = 1
        else ERDY = 0
        end
        if myHero.SpellTimeR > 1.0 then
        RRDY = 1
        else RRDY = 0
        end
       
    if JarvanConfig.castQ then castQ() end
        if JarvanConfig.EQTarget then EQTarget() end
        if JarvanConfig.UltCombo then UltCombo() end
        if JarvanConfig.EscapeJump then EscapeJump() end
        if JarvanConfig.useItems then useItems() end
        if JarvanConfig.ignite then ignite() end
        if JarvanConfig.movement and (JarvanConfig.castQ or JarvanConfig.UltCombo or JarvanConfig.EQTarget)  and not target then MoveToMouse() end
    end
end
 
        JarvanConfig = scriptConfig("Jarvan Config", "jarvanconfig")
        JarvanConfig:addParam("castQ", "Use Q to poke", SCRIPT_PARAM_ONKEYDOWN, false, 89)
        JarvanConfig:addParam("EQTarget", "Use EQ to target", SCRIPT_PARAM_ONKEYDOWN, false, 88)
        JarvanConfig:addParam("UltCombo", "Ult on Enemy", SCRIPT_PARAM_ONKEYDOWN, false, 82)
        JarvanConfig:addParam("EscapeJump", "EQ Escape to cursor", SCRIPT_PARAM_ONKEYDOWN, false, 84)
        JarvanConfig:addParam("useItems", "Use Items", SCRIPT_PARAM_ONKEYTOGGLE, true, 112)
        JarvanConfig:addParam("movement", "Move To Mouse", SCRIPT_PARAM_ONKEYTOGGLE, true, 89)
 
function castQ()
        if target ~= nil and GetDistance(myHero, target) < 750 and QRDY == 1 then
                CastSpellXYZ("Q",target.x,target.y,target.z)
        end
end
 
function EscapeJump()
        local pos = getPosCursor()
        if QRDY == 1 and ERDY == 1 then
                CastSpellXYZ("E",GetCursorWorldX(), GetCursorWorldY(), GetCursorWorldZ())
        end
        if QRDY == 1 then
                CastSpellXYZ("Q", pos.x, 0, pos.z)
        end
end
 
function EQTarget()
        if target ~= nil then
                local pos = getPosTarget()
                if QRDY == 1 and ERDY == 1 and GetDistance(myHero, target) < 800 then
                        CastSpellXYZ("E",pos.x, 0, pos.z)
                end
                if QRDY == 1 then
                        CastSpellXYZ("Q", pos.x, 0, pos.z)
                end
                if IsAttackReady() and GetDistance(target) < 200 then AttackTarget(target) end
        end
end
 
function UltCombo()
        if target ~= nil and RRDY == 1 and GetDistance(myHero, target) < 650 then
                CastSpellTarget("R",target)
        end
end
 
function getPosCursor()
        local MousePos = Vector(GetCursorWorldX(), GetCursorWorldY(), GetCursorWorldZ())
        local HeroPos = Vector(myHero.x, myHero.y, myHero.z)
        return HeroPos + ( HeroPos - MousePos )*(-800/GetDistance(HeroPos, MousePos))
end
 
function getPosTarget()
        local EnemyPos = Vector(target.x, target.y, target.z)
        local HeroPos = Vector(myHero.x, myHero.y, myHero.z)
        return HeroPos + ( HeroPos - EnemyPos )*(((GetDistance(HeroPos, EnemyPos)+100)*(-1))/GetDistance(HeroPos, EnemyPos))
end
 
function useItems()
        if target ~= nil then
                UseAllItems(target)
        end
end   
 
SetTimerCallback("OnTick")
SetTimerCallback("JarvanRun")
print("\nVal's Jarvan (Whisper Revision) v"..version.."\n")