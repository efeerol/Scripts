--[[
=====================
=	GUI Framework   =
=		 by		    =
=	  pro4never	    =
=====================

=======Purpose=======
Simplify the creation of easy to use ingame interfaces
Allow for the standardization (and improvement) of ingame display

=======Version=======
=		0.01		=
=====================
]]--

local Windows = {}
local WindowColors =
{
	Background = 0x99000000,
	TopBar = 0x99483D88,
	MinimizeButton = 0xFFDCDCDC,
	TitleColor = 0xFFD3B38C,
	TextColor = 0xFFA9A9A9
}
local VerticalSpacing = 20
local TextWidth = 8
local SelectedWindow = nil
local PreviousMouse = nil

--[[Create a new ingame Window]]--
function CreateNewWindow(_title,_x,_y,_width,_ownerID)
	printtext("Creating new Window object of title: ".._title.."\n")
	local newWindow = {title = _title, x = _x, y = _y, width = _width, ownerID = _ownerID, drawMode = 1, children={}}
	table.insert(Windows,newWindow)
	return newWindow
end

--[[Insert child into existing ingame Window]]--
function InsertChild(_parent,_key,_value,_ownerID,_color,_onClick)
	printtext("Creating new Child object with key: ".._key.."\n")
	local newChild = {parent = _parent, key = _key, value = _value, ownerID = _ownerID, color = _color or WindowColors.TextColor, OnClick=_onClick}
	table.insert(_parent.children, newChild)
end


--[[Clear all elements created by ownerID (aka script ID)]]--
function RemoveObjectsByID(ownerID)
	for x=#Windows,1,-1 do
		for y=#Windows[x].children,1,-1 do
			if Windows[x].children[y].ownerID == ownerID then
				printtext("Removing child with Key: "..Windows[x].children[y].key.."\n")
				table.remove(Windows[x].children, y)
			end
		end
		if Windows[x].ownerID == ownerID then
			printtext("Removing window with title: "..Windows[x].title.."\n")
			table.remove(Windows, x)
		end
	end
end

function GetMouseState()
	return {x=GetCursorX(), y=GetCursorY()}
end

function WindowContainsMouse(window,mouse)
	return window.x < mouse.x 
	and window.x+window.width > mouse.x 
	and window.y < mouse.y 
	and window.y + 20 + #window.children*VerticalSpacing > mouse.y
end


function GetChildElementClicked(window,mouse)
	return window.children[1+math.floor((mouse.y-window.y-20)/VerticalSpacing)]
end

function GUI_Framework_Tick()
	msg,key,param=GetMessage()
	while msg ~= nil do		
		if key == 1 then
			if #Windows > 0 then
				local mouseState = GetMouseState()
				for i,window in ipairs(Windows) do
					if window.drawMode > 0 and WindowContainsMouse(window,mouseState) then
						--Check for title bar being clicked
						if mouseState.y - window.y < 20 then
							SelectedWindow = window
							PreviousMouse = mouseState
							if mouseState.x - window.x  > window.width - 20  then
								if window.drawMode == 1 then
									window.drawMode = 2
								else
									window.drawMode = 1
								end						
							end
						else
							local childClicked = GetChildElementClicked(window,mouseState)
							if childClicked ~= nil and childClicked.OnClick ~= nil then
								printtext("On Click for window with key: "..childClicked.key.."\n")
								childClicked.OnClick(window, childClicked)
							end
						end
					end
				end
			end
		elseif key == 0 then
			SelectedWindow = nil
		end
        msg,key,param=GetMessage()
    end
	--Draw all existing visual elements
	if #Windows > 0 then
		for x,window in ipairs(Windows) do
			if window.drawMode > 0 then
				if window.drawMode == 1 then				
					if SelectedWindow ~= nil then
						SelectedWindow.x = SelectedWindow.x - (PreviousMouse.x-GetCursorX())
						SelectedWindow.y = SelectedWindow.y - (PreviousMouse.y-GetCursorY())
						PreviousMouse = GetMouseState()
					end
					--Draw Background
					DrawBox(window.x,window.y,window.width,20+(#window.children*VerticalSpacing),WindowColors.Background)
					--Draw Children
					for y=1,#window.children do
						DrawText(window.children[y].key,window.x+2,window.y+(y*VerticalSpacing),window.children[y].color)
						DrawText(window.children[y].value,window.x+window.width-(string.len(window.children[y].value)*TextWidth+10),window.y+(y*VerticalSpacing),window.children[y].color)
					end
				end
				DrawBox(window.x,window.y,window.width,20,WindowColors.TopBar)
				DrawBox(window.x+window.width-20,window.y,20,20,WindowColors.MinimizeButton)
				DrawText(window.title,window.x+10,window.y,WindowColors.TitleColor)
			end
		end	
	end
	
end
HookWnd()
SetTimerCallback("GUI_Framework_Tick")