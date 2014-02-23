require "Utils"

print("\nMalbert's")
print("\nWard Jump")
print("\nVersion 1.3")

local _registry = {}
local Champs = {}
Champs["Katarina"]={spell="E",mana=0}
Champs["Jax"]={spell="Q", mana=65}
Champs["LeeSin"]={spell="W", mana=50}
local SRDY=0
local lastWardJump=0
local lastWardObject=nil
local www=nil
local wardsuccess=false
local LeeSin=false
local wards = {3340, 3350, 3154, 3361, 3361, 3362, 2044, 2043, 2045, 2049}
--[[
2043, Vision Ward
2044, Sight Ward
2045, Ruby Sightstone
2049, Sightstone
2050, Explorer's Ward (Removed)
3154, Wriggle's Lantern
3340, Warding Totem (60s/3 max) (lv 0)
3350, Greater Totem (120s/3 max) (lv 9)
3361, Greater Stealth Totem (180s/3 max) (lv 9+purchase)
3362, Graeter Vision Totem (--s/1 max) (lv 9+purchase)
]]--

WardJConfig = scriptConfig("WardJump", "WardJump Hotkey")
WardJConfig:addParam("ward", "Ward Jump", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
WardJConfig:addParam("wardF", "Ward Farthest", SCRIPT_PARAM_ONOFF, true)

function WardRun()
	if Champs[myHero.name] and myHero.dead~=1 then	
		if myHero.name=="LeeSin" then
			LeeSin=true
		else
			LeeSin=false
		end
		if myHero["SpellTime"..Champs[myHero.name].spell] >= 1.0 and GetSpellLevel(Champs[myHero.name].spell) > 0 and myHero.mana>=Champs[myHero.name].mana then
			SRDY = 1
		else 
			SRDY = 0
        end
		www=nil
		for _, ward in pairs(wards) do
			if ward~=nil and GetWardSlot(ward) ~= nil and os.clock() > lastWardJump  then
				
				www=GetWardSlot(ward)
				--print("\nHere1 "..tostring(ward))
				break
				
			end
		end
	if IsChatOpen()==0 and myHero.dead~=1 and WardJConfig.ward and WardJConfig.wardF then ward(mousePos.x,mousePos.y,mousePos.z) 
    elseif IsChatOpen()==0 and myHero.dead~=1 and WardJConfig.ward and WardJConfig.wardF==false then ward() end  
	
			if gotAWard() then
				CustomCircle(600,10,1,myHero)
			end
	end
end


function ward(hx,hy,hz)
	if hx~=nil and hy~=nil and hz~=nil then
		
				--print("\nHere38 "..tostring(WRDY).." "..myHero.SpellNameW.. " "..lastWardJump.." "..os.clock())
		if SRDY==1 and (myHero.SpellNameW=="BlindMonkWOne" or LeeSin==false) and os.clock() > lastWardJump then
			
				--print("\nHere39")
			wardsuccess=false
			--wx,wy,wz=GetFireahead(myHero,5,0)
			
			if www~=nil and os.clock() > lastWardJump then
				--print("\nHere40")
				local x1,y1,z1=getWardSpot(hx,hy,hz)
				--run_every(0.1,castWard, x1,y1,z1)
				CastSpellXYZ(www, x1,y1,z1,0)
				lastWardJump=os.clock()+3
				wardsuccess=true
			end	
		end
		
		if SRDY==1 and (myHero.SpellNameW=="BlindMonkWOne" or LeeSin==false) and wardsuccess==true and lastWardObject~=nil and GetD(lastWardObject)<700 then
			run_every(0.2,JSpell, lastWardObject)
		
		end

                if ( SRDY==0 or myHero.SpellNameW=="blindmonkwtwo" or not gotAWard()) then
                        MoveToMouse()
                end
	else
				--print("\nHere41")
		if SRDY==1 and (myHero.SpellNameW=="BlindMonkWOne" or LeeSin==false) and os.clock() > lastWardJump then
			
				--print("\nHere42")
			wardsuccess=false
			--wx,wy,wz=GetFireahead(myHero,5,0)
			if www~=nil and os.clock() > lastWardJump then
				--print("\nHere43")
				CastSpellXYZ(www, mousePos.x,mousePos.y,mousePos.z,0)
				lastWardJump=os.clock()+3
				wardsuccess=true
			end	
			
		end
		
		if SRDY==1 and (myHero.SpellNameW=="BlindMonkWOne" or LeeSin==false) and wardsuccess==true and lastWardObject~=nil and GetD(lastWardObject)<700 then
			run_every(0.2,JSpell, lastWardObject)
		
		end
		if ( SRDY==0 or myHero.SpellNameW=="blindmonkwtwo" or not gotAWard()) then
			MoveToMouse()
		end
	end
end


function JSpell(tt)
	CastSpellTarget(Champs[myHero.name].spell,tt)
end

function getWardSpot(a,b,c)
	--print("\n
			--print("\nHere37")
	local spot={x=a,y=b,z=c}
	local dist=GetD(spot,myHero)
		if myHero.x==spot.x then
				tx = myHero.x
				if myHero.z>spot.z then
						tz = myHero.z-590
				else
						tz = myHero.z+(590)
				end
	   
		elseif spot.z==myHero.z then
				tz = myHero.z
				if myHero.x>spot.x then
						tx = myHero.x-(590)
				else
						tx = myHero.x+(590)
				end
	   
		elseif myHero.x>spot.x then
				angle = math.asin((myHero.x-spot.x)/dist)
				zs = (590)*math.cos(angle)
				xs = (590)*math.sin(angle)
				if myHero.z>spot.z then
						tx = myHero.x-xs
						tz = myHero.z-zs
				elseif myHero.z<spot.z then
						tx = myHero.x-xs
						tz = myHero.z+zs
				end
	   
		elseif myHero.x<spot.x then
				angle = math.asin((spot.x-myHero.x)/dist)
				zs = (590)*math.cos(angle)
				xs = (590)*math.sin(angle)
				if myHero.z>spot.z then
						tx = myHero.x+xs
						tz = myHero.z-zs
				elseif myHero.z<spot.z then
						tx = myHero.x+xs
						tz = myHero.z+zs
				end 
		end
	return tx,spot.y,tz
end

function gotAWard()

	if myHero.dead~=1 then
		for _, ward in pairs(wards) do
				if GetWardSlot(ward) ~= nil then
						return true
				end
			end
	end
	return false
end

function OnCreateObj(obj)
	--if GetD(obj)<600 then
	--print("\n obj "..obj.charName)
	--end
	
		
	if (WardJConfig.ward) and GetD(obj)<700 and (string.find(obj.charName,"SightWard") or string.find(obj.charName,"VisionWard")) then
		lastWardObject=obj
		lastWardJump = os.clock()+5
	end
end

function GetWardSlot(item)
    if GetInventoryItem(1) == item then
				--print("\nHere2")
                if item == 3154 or item == 3340 or item == 3350 or item == 3361 or item == 3362 then                       
					--print("\nHere3")
						if myHero.SpellTime1 >= 1 then 
							--print("\nHere4")
							return 1
                        else 
							--print("\nHere5")
							return nil end
                else
						print("\nHere6")
                        return 1
                end
    elseif GetInventoryItem(2) == item then
				--print("\nHere7")
                if item == 3154 or item == 3340 or item == 3350 or item == 3361 or item == 3362 then
					--print("\nHere8")
                        if myHero.SpellTime2 >= 1 then 
							--print("\nHere9")
							return 2
                        else 
							--print("\nHere10")
							return nil end
                else
						--print("\nHere11")
                        return 2
                end
    elseif GetInventoryItem(3) == item then
				--print("\nHere12")
                if item == 3154 or item == 3340 or item == 3350 or item == 3361 or item == 3362 then
					--print("\nHere13")
                        if myHero.SpellTime3 >= 1 then 
							--print("\nHere14")
							return 3
                        else 
							--print("\nHere15")
							return nil end
                else
						--print("\nHere16")
                        return 3
                end
    elseif GetInventoryItem(4) == item then
				--print("\nHere17")
                if item == 3154 or item == 3340 or item == 3350 or item == 3361 or item == 3362 then
					--print("\nHere18")
                        if myHero.SpellTime4 >= 1 then 
							--print("\nHere19")
							return 4
                        else 
							--print("\nHere20")
							return nil end
                else
						--print("\nHere21")
                        return 4
                end
    elseif GetInventoryItem(5) == item then
				--print("\nHere22")
                if item == 3154 or item == 3340 or item == 3350 or item == 3361 or item == 3362 then
					--print("\nHere23")
                        if myHero.SpellTime5 >= 1 then 
							--print("\nHere24")
							return 5
                        else 
							--print("\nHere25")
							return nil end
                else
						--print("\nHere26")
                        return 5
                end
    elseif GetInventoryItem(6) == item then
				--print("\nHere27")
                if item == 3154 or item == 3340 or item == 3350 or item == 3361 or item == 3362 then
					--print("\nHere28")
                        if myHero.SpellTime6 >= 1 then 
							--print("\nHere29")
							return 6
                        else 
							--print("\nHere30")
							return nil end
                else
						--print("\nHere31")
                        return 6
                end
    elseif GetInventoryItem(7) == item then
				--print("\nHere32")
                if item == 3154 or item == 3340 or item == 3350 or item == 3361 or item == 3362 then
					--print("\nHere33")
                        if myHero.SpellTime7 >= 1 then 
							--print("\nHere34")
							return 7
                        else 
							--print("\nHere35")
							return nil end
                else
						--print("\nHere36")
                        return 7
                end
    end
    return nil
end

function GetD(p1, p2)
if p2 == nil then p2 = myHero end
if (p1.z == nil or p2.z == nil) and p1.x~=nil and p1.y ~=nil and p2.x~=nil and p2.y~=nil then
px=p1.x-p2.x
py=p1.y-p2.y
if px~=nil and py~=nil then
px2=px*px
py2=py*py
if px2~=nil and py2~=nil then
return math.sqrt(px2+py2)
else
return 99999
end
else
return 99999
end

elseif p1.x~=nil and p1.z ~=nil and p2.x~=nil and p2.z~=nil then
px=p1.x-p2.x
pz=p1.z-p2.z
if px~=nil and pz~=nil then
px2=px*px
pz2=pz*pz
if px2~=nil and pz2~=nil then
return math.sqrt(px2+pz2)
else
return 99999
end
else    
return 99999
end

else
return 99999
end
end

function run_every(interval, fn, ...)
    return internal_run({fn=fn, interval=interval}, ...)
end

function internal_run(t, ...)    
    local fn = t.fn
    local key = t.key or fn
    
    local now = os.clock()
    local data = _registry[key]
       
    if data == nil or t.reset then
        local args = {}
        local n = select('#', ...)
        local v
        for i=1,n do
            v = select(i, ...)
            table.insert(args, v)
        end   
        -- the first t and args are stored in registry        
        data = {count=0, last=0, complete=false, t=t, args=args}
        _registry[key] = data
    end
        
    --assert(data~=nil, 'data==nil')
    --assert(data.count~=nil, 'data.count==nil')
    --assert(now~=nil, 'now==nil')
    --assert(data.t~=nil, 'data.t==nil')
    --assert(data.t.start~=nil, 'data.t.start==nil')
    --assert(data.last~=nil, 'data.last==nil')
    -- run
    local countCheck = (t.count==nil or data.count < t.count)
    local startCheck = (data.t.start==nil or now >= data.t.start)
    local intervalCheck = (t.interval==nil or now-data.last >= t.interval)
    --print('', 'countCheck', tostring(countCheck))
    --print('', 'startCheck', tostring(startCheck))
    --print('', 'intervalCheck', tostring(intervalCheck))
    --print('')
    if not data.complete and countCheck and startCheck and intervalCheck then                
        if t.count ~= nil then -- only increment count if count matters
            data.count = data.count + 1
        end
        data.last = now        
        
        if t._while==nil and t._until==nil then
            return fn(...)
        else
            -- while/until handling
            local signal = t._until ~= nil
            local checker = t._while or t._until
            local result
            if fn == checker then            
                result = fn(...)
                if result == signal then
                    data.complete = true
                end
                return result
            else
                result = checker(...)
                if result == signal then
                    data.complete = true
                else
                    return fn(...)
                end
            end            
        end
    end    
end

SetTimerCallback("WardRun")