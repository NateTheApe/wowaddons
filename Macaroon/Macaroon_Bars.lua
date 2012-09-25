--Macaroon, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

local M = Macaroon

M.BarIndex = {}

M.BarIndexByName = {}

M.ButtonBars = {}

M.CreateBarTypes = {}

local	SKIN

if (LibStub) then
	SKIN = LibStub("Masque", true)
end

local autoHideIndex, alphaupIndex, anchorIndex, dockIndex = {}, {}, {}, {}

local SD, ManagedStates, pew, shared, load

local stratas = { "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "TOOLTIP" }

local alphaUps = {
	M.Strings.ALPHAUP_NONE,
	M.Strings.ALPHAUP_MOUSEOVER,
	M.Strings.ALPHAUP_BATTLE,
	M.Strings.ALPHAUP_BATTLEMOUSE,
	M.Strings.ALPHAUP_RETREAT,
	M.Strings.ALPHAUP_RETREATMOUSE,
}

local notSharedButtonData = {
	action = true,
	spell = true,
	type = true,
	macro = true,
	macroIcon = true,
	macroName = true,
	macroNote = true,
	macroUseNote = true,
	macroAuto = true,
	macroRand = true,
	upClicks = true,
	downClicks = true,
	spellCounts = true,
	comboCounts = true,
}

local tooltipTable = {}

local gsub = string.gsub
local find = string.find
local match = string.match
local gmatch = string.gmatch
local format = string.format
local lower = string.lower
local upper = string.upper
local floor = math.floor
local ceil = math.ceil
local mod = mod

local InCombatLockdown = _G.InCombatLockdown

local CopyTable = M.CopyTable
local ClearTable = M.ClearTable

local function IsMouseOverSelfOrWatchFrame(frame)

	if (frame:IsMouseOver()) then
		return true
	end

	if (frame.watchframes) then
		for k,v in pairs(frame.watchframes) do
			if (v:IsMouseOver() and v:IsVisible()) then
				return true
			end
		end
	end

	return false
end

local function controlOnUpdate(self, elapsed)

	for k,v in pairs(autoHideIndex) do
		if (v~=nil) then

			if (k:IsShown()) then
				v:SetAlpha(1)
			else

				if (IsMouseOverSelfOrWatchFrame(k)) then
					if (v:GetAlpha() < k.alpha) then
						if (v:GetAlpha()+v.fadeSpeed <= 1) then
							v:SetAlpha(v:GetAlpha()+v.fadeSpeed)
						else
							v:SetAlpha(1)
						end
					else
						k.vis = 1;
					end
				end

				if (not IsMouseOverSelfOrWatchFrame(k)) then
					if (v:GetAlpha() > 0) then
						if (v:GetAlpha()-v.fadeSpeed >= 0) then
							v:SetAlpha(v:GetAlpha()-v.fadeSpeed)
						else
							v:SetAlpha(0)
						end
					else
						k.vis = 0;
					end
				end
			end
		end
	end

	for k,v in pairs(alphaupIndex) do
		if (v~=nil) then
			if (k.alphaUp == alphaUps[3] or k.alphaUp == alphaUps[4]) then

				if (InCombatLockdown()) then

					if (v:GetAlpha() < 1) then
						if (v:GetAlpha()+v.fadeSpeed <= 1) then
							v:SetAlpha(v:GetAlpha()+v.fadeSpeed)
						else
							v:SetAlpha(1)
						end
					else
						k.vis = 1;
					end

				else
					if (k.alphaUp == alphaUps[4]) then

						if (IsMouseOverSelfOrWatchFrame(k)) then
							if (v:GetAlpha() < 1) then
								if (v:GetAlpha()+v.fadeSpeed <= 1) then
									v:SetAlpha(v:GetAlpha()+v.fadeSpeed)
								else
									v:SetAlpha(1)
								end
							else
								k.vis = 1;
							end
						else
							if (v:GetAlpha() > k.alpha) then
								if (v:GetAlpha()-v.fadeSpeed >= 0) then
									v:SetAlpha(v:GetAlpha()-v.fadeSpeed)
								else
									v:SetAlpha(k.alpha)
								end
							else
								k.vis = 0;
							end
						end
					else
						if (v:GetAlpha() > k.alpha) then
							if (v:GetAlpha()-v.fadeSpeed >= 0) then
								v:SetAlpha(v:GetAlpha()-v.fadeSpeed)
							else
								v:SetAlpha(k.alpha)
							end
						else
							k.vis = 0;
						end
					end
				end

			elseif (k.alphaUp == alphaUps[5] or k.alphaUp == alphaUps[6]) then

				if (not InCombatLockdown()) then

					if (v:GetAlpha() < 1) then
						if (v:GetAlpha()+v.fadeSpeed <= 1) then
							v:SetAlpha(v:GetAlpha()+v.fadeSpeed)
						else
							v:SetAlpha(1)
						end
					else
						k.vis = 1;
					end

				else
					if (k.alphaUp == alphaUps[6]) then

						if (IsMouseOverSelfOrWatchFrame(k)) then
							if (v:GetAlpha() < 1) then
								if (v:GetAlpha()+v.fadeSpeed <= 1) then
									v:SetAlpha(v:GetAlpha()+v.fadeSpeed)
								else
									v:SetAlpha(1)
								end
							else
								k.vis = 1;
							end
						else
							if (v:GetAlpha() > k.alpha) then
								if (v:GetAlpha()-v.fadeSpeed >= 0) then
									v:SetAlpha(v:GetAlpha()-v.fadeSpeed)
								else
									v:SetAlpha(k.alpha)
								end
							else
								k.vis = 0;
							end
						end
					else
						if (v:GetAlpha() > k.alpha) then
							if (v:GetAlpha()-v.fadeSpeed >= 0) then
								v:SetAlpha(v:GetAlpha()-v.fadeSpeed)
							else
								v:SetAlpha(k.alpha)
							end
						else
							k.vis = 0;
						end
					end
				end

			elseif (k.alphaUp == alphaUps[2]) then

				if (IsMouseOverSelfOrWatchFrame(k)) then
					if (v:GetAlpha() < 1) then
						if (v:GetAlpha()+v.fadeSpeed <= 1) then
							v:SetAlpha(v:GetAlpha()+v.fadeSpeed)
						else
							v:SetAlpha(1)
						end
					else
						k.vis = 1;
					end
				else
					if (v:GetAlpha() > k.alpha) then
						if (v:GetAlpha()-v.fadeSpeed >= 0) then
							v:SetAlpha(v:GetAlpha()-v.fadeSpeed)
						else
							v:SetAlpha(k.alpha)
						end
					else
						k.vis = 0;
					end
				end
			end
		end
	end
end

local function createAnchor(bar)

	local index = #anchorIndex + 1
	local anchor = CreateFrame("Frame", nil, bar)

	anchor:SetID(index)
	anchor:SetWidth(2)
	anchor:SetHeight(2)
	anchor:SetMovable(true)
	anchor:SetToplevel(false)

	anchorIndex[index] = { anchor, 0 }

	return anchor
end

local function getAnchor(bar, state)

	if (bar[state] and bar[state].anchor) then
		return bar[state].anchor
	end

	local anchor

	for k,v in pairs(anchorIndex) do
		if (v[2] == 1) then
			anchor = v[1]
		end
	end

	if (not anchor) then
		anchor = createAnchor(bar)
	end

	anchorIndex[anchor:GetID()][2] = 0

	anchor:SetPoint("CENTER", bar, "CENTER", 0, 0)

	bar[state].anchor = anchor

	return anchor
end

local function setDefaultPosition(bar, y)

	local barHeight = 40

	if (not y) then	y = 90 end

	bar:SetUserPlaced(false)
	bar:ClearAllPoints()
	bar:SetPoint("CENTER", "UIParent", "BOTTOM", 0, y)
	bar.config.point, bar.config.x, bar.config.y = M.GetPosition(bar)
	bar:SetUserPlaced(true)

	y = y + barHeight

	return y
end

local function setPosition(bar)

	if (bar.config.snapToPoint and bar.config.snapToFrame) then
		M.SnapTo.StickToPoint(bar, _G[bar.config.snapToFrame], bar.config.snapToPoint, bar.config.snapToPad, bar.config.snapToPad)
	else
		M.SetPosition(bar)
	end
end

local function round(num, idp)

      local mult = 10^(idp or 0)
      return math.floor(num * mult + 0.5) / mult

end

local function updateVisibility(bar, message)

	if (not message) then return end

	if (bar.handler:GetAttribute("isBarChild")) then

		bar.handler:SetAttribute("stateshown", false)

		for showstate in gmatch(bar.handler:GetAttribute("showstates"), "[^;]+") do
			if (message and strfind(message, showstate)) then
				bar.handler:Show()
				bar.handler:SetAttribute("stateshown", true)
			end
		end

		if (not bar.handler:GetAttribute("stateshown")) then
			bar.handler:Hide()
		end
	end
end

local function updateShape(bar, storage, menu, dock)

	if (not bar or not bar.config) then return end

	if (bar.config.buttonList) then

		local width, height, xOffset, yOffset, padH, padV, arcStart, arcLength = 0, 0, 0, 0
		local shape, x, y, button, btnScale, count, last, hide = bar.config.shape

		bar:SetClampedToScreen(false)

		-- clear out old pad data
		for state, data in pairs(bar.config.padData) do
			if (not bar.config.buttonList[state]) then
				bar.config.padData[state] = nil
			end
		end

		for state, btnIDs in pairs(bar.config.buttonList) do

			local first, pos, count, cAdjust, rAdjust = false, 1, bar[state].buttonCount, 0.5, 1
			local origCol, rows, columns, placed, anchor = bar.config.columns

			if (not origCol) then
				origCol = count; rows = 1
			else
				rows = (round(ceil(count/bar.config.columns), 1)/2)+0.5
			end

			if (storage or dock) then
				anchor = bar
			else
				anchor = bar[state].anchor or getAnchor(bar, state)

			end

			if (not bar.config.padData[state]) then
				bar.config.padData[state] = "0:0"
			end

			padH, padV = (":"):split(bar.config.padData[state])
			padH = tonumber(padH)-1; padV = tonumber(padV)-1

			for btnID in gmatch(btnIDs, "[^;]+") do

				button = _G[bar.btnType..btnID]

				if (button) then

					if (bar.handler:GetParent() == button) then
						button:SetParent("UIParent")
					else
						button:SetParent(bar.handler)
					end

					if (storage and bar.locked) then
						button.config.locked = bar.locked
					else
						button.config.locked = false
					end

					button:ClearAllPoints(); button:SetClampedToScreen(false)

					width = button:GetWidth(); height = button:GetHeight()
					xOffset = button.config.XOffset; yOffset = button.config.YOffset
					btnScale = button.config.scale

					if (count > origCol and mod(count, origCol)~=0 and rAdjust == 1) then
						columns = (mod(count, origCol))/2
					elseif (origCol >= count) then
						columns = count/2
					else
						columns = origCol/2
					end

					if (shape == 2) then

						if (not bar.config.arcData[state]) then
							bar.config.arcData[state] = "0:359"
						end

						arcStart, arcLength = (":"):split(bar.config.arcData[state])
						arcStart = tonumber(arcStart); arcLength = tonumber(arcLength)

						if (not placed) then
							placed = arcStart
						end

						x = ((width+padH)*(count/math.pi))*(cos(placed)) / btnScale
						y = ((width+padV)*(count/math.pi))*(sin(placed)) / btnScale

						button:SetPoint("CENTER", anchor, "CENTER", x + xOffset, y + yOffset)

						placed = placed - (arcLength/count)

					elseif (shape == 3) then

						if (not bar.config.arcData[state]) then
							bar.config.arcData[state] = "0:359"
						end

						arcStart, arcLength = (":"):split(bar.config.arcData[state])
						arcStart = tonumber(arcStart); arcLength = tonumber(arcLength)

						if (not placed) then

							placed = arcStart

							button:SetPoint("CENTER", anchor, "CENTER", xOffset, yOffset)

							placed = placed - (arcLength/count)

						else

							x = ((width+padH)*(count/math.pi))*(cos(placed)) / btnScale
							y = ((width+padV)*(count/math.pi))*(sin(placed)) / btnScale

							button:SetPoint("CENTER", anchor, "CENTER", x + xOffset, y + yOffset)

							placed = placed - (arcLength/(count-1))
						end
					else

						--clear out old arc data
						if (bar.config.arcData[state]) then
							bar.config.arcData[state] = nil
						end

						if (not placed) then
							placed = 0
						end

						x = -(width + padH) * (columns-cAdjust) / btnScale
						y = (height + padV) * (rows-rAdjust) / btnScale

						button:SetPoint("CENTER", anchor, "CENTER", x + xOffset, y + yOffset)

						placed = placed + 1; cAdjust = cAdjust + 1

						if (placed >= columns*2) then
							placed = 0
							cAdjust = 0.5
							rAdjust = rAdjust + 1
						end

					end

					if (SKIN and bar.objtype == "Button") then

						local btnData = {	Normal = button.normaltexture, Icon = button.iconframeicon, Cooldown = button.iconframecooldown, HotKey = button.hotkey, Count = button.count, Name = button.name, Border = button.border, AutoCast = false }

						SKIN:Group("Macaroon", bar.config.name):AddButton(button, btnData)

					end

					button.updateData(button, bar, state)

					if (not storage and not dock) then
						bar.btnTable[button.id][2] = 0
					end

					button.config.barPos = pos; pos = pos + 1

					button:SetScale(bar.config.scale * btnScale)

					if (button.config.alpha) then
						button:SetAlpha(button.config.alpha)
					end

					if (button.newButton) then

						local set

						if (bar.config.companion and state == "companion1") then

							button.config.type = "pet"
							button.config.action = button.config.barPos
							set = true

						elseif (bar.config.possess and state == "possess1") then

							if (button.config.barPos == 11) then
								button.config.type = "macro"
								button.config.macro = "#macaroon-possesscancel"
							elseif (button.config.barPos == 12) then
								button.config.type = "macro"
								button.config.macro = "#macaroon-possessaction"
							else
								button.config.type = "action"
								button.config.action = button.config.barPos+120
							end

							set = true

						elseif (bar.config.vehicle and state == "vehicle1") then

							if (button.config.barPos == 7) then
								button.config.type = "macro"
								button.config.macro = "#macaroon-vehicleleave"
							elseif (button.config.barPos == 8) then
								button.config.type = "macro"
								button.config.macro = "#macaroon-vehicleup"
							elseif (button.config.barPos == 9) then
								button.config.type = "macro"
								button.config.macro = "#macaroon-vehicledown"
							else
								button.config.type = "action"
								button.config.action = button.config.barPos+120
							end

							set = true
						end

						if (set) then
							M.SetButtonType(button)
						end

						button.newButton = nil
					end
				end
			end

			if (not storage) then

				bar[state].buttonCount = 0

				bar[state].top = nil; bar[state].bottom = nil; bar[state].left = nil; bar[state].right = nil

				for btnID in gmatch(btnIDs, "[^;]+") do

					button = _G[bar.btnType..btnID]

					if (button and not button.anchoredBar) then

						local btnTop, btnBottom, btnLeft, btnRight = button:GetTop(), button:GetBottom(), button:GetLeft(), button:GetRight()
						local scale = button.config.scale

						bar[state].buttonCount = bar[state].buttonCount + 1

						if (bar[state].top) then
							if (btnTop*scale > bar[state].top) then bar[state].top = btnTop*scale end
						else bar[state].top = btnTop*scale end

						if (bar[state].bottom) then
							if (btnBottom*scale < bar[state].bottom) then bar[state].bottom = btnBottom*scale end
						else bar[state].bottom = btnBottom*scale end

						if (bar[state].left) then
							if (btnLeft*scale < bar[state].left) then bar[state].left = btnLeft*scale end
						else bar[state].left = btnLeft*scale end

						if (bar[state].right) then
							if (btnRight*scale > bar[state].right) then bar[state].right = btnRight*scale end
						else bar[state].right = btnRight*scale end
					end
				end

				if (not dock) then

					if (not bar[state].xOffset) then bar[state].xOffset = 0 end
					if (not bar[state].yOffset) then bar[state].yOffset = 0 end

					if (bar[state].top and bar[state].bottom and bar[state].left and bar[state].right) then

						local scale = bar.config.scale

						local width, height = ((bar[state].right-bar[state].left)/2)*scale, ((bar[state].top-bar[state].bottom)/2)*scale
						local x, y = bar:GetCenter()
						local top, bottom, left, right = bar[state].top-((y+height)/scale), bar[state].bottom-((y-height)/scale), bar[state].left-((x-width)/scale), bar[state].right-((x+width)/scale)

						bar[state].xOffset = bar[state].xOffset - ( ((left+right)/2)*scale )
						bar[state].yOffset = bar[state].yOffset - ( ((top+bottom)/2)*scale )

					end

					anchor:SetPoint("CENTER", bar, "CENTER", bar[state].xOffset, bar[state].yOffset)
				end
			end

			for btnID in gmatch(btnIDs, "[^;]+") do
				button = _G[bar.btnType..btnID]
				if (button) then
					button:SetClampedToScreen(true)
					button:SetClampRectInsets(3,-3,-3,3)
				end
			end
		end

		bar:SetClampedToScreen(true)
		bar:SetClampRectInsets(10,-10,-10,10)
	end
end

local function updateBarSize(bar)

	local currState, lastState = bar.handler:GetAttribute("state-current"), bar.handler:GetAttribute("state-last")

	-- Code added by Dwargh to prevent horizontal displacement follows.

	local rows0, rows1, rowsPerBar = 0, 1, 1

	if (not bar.config.padData[currState]) then
		bar.config.padData[currState] = "0:0"
	end

	local padH, padV = (":"):split(bar.config.padData[currState])

	padV = tonumber(padV)

	-- Code added by Dwargh to prevent horizontal displacement ends.

	if (bar[currState]) then

		-- Code added by Dwargh to prevent horizontal displacement follows.

		if not bar.config.columns == false then
			rows0 = string.format("%.0f", (bar[currState].buttonCount/bar.config.columns))
			rows1 = string.format("%.1f", (bar[currState].buttonCount/bar.config.columns))
		end
		if  rows1 > rows0 and rowsPerBar == 1 then
			rowsPerBar = rows0+1
		else
			rowsPerBar = rows0
		end
		if (bar[currState].buttonCount > 0) then

			if (rowsPerBar == 0 and bar[lastState]) then
				rowsPerBar = (bar[lastState].buttonCount/bar.config.columns)
				bar.config.y = (((36+padV)*bar.config.scale)/2-((36+padV)*rowsPerBar*bar.config.scale)/2)
			end
		end

		-- Code added by Dwargh to prevent horizontal displacement ends.

		if (bar[currState].buttonCount and bar[currState].buttonCount > 0 and bar[currState].right) then
			bar:SetWidth((bar[currState].right-bar[currState].left)*bar.config.scale)
			bar:SetHeight((bar[currState].top-bar[currState].bottom)*bar.config.scale)
		-- Code added by Dwargh to prevent horizontal displacement follows.
		elseif (bar[lastState] and bar[lastState].buttonCount > 0) then
			bar:SetWidth((bar[lastState].right-bar[lastState].left)*bar.config.scale)
			bar:SetHeight((bar[lastState].top-bar[lastState].bottom)*bar.config.scale)
		-- Code added by Dwargh to prevent horizontal displacement ends.
		else
			bar:SetWidth(195)
			bar:SetHeight(36*bar.config.scale)
		end
	end
end

local function updateBarLink(bar)

	local handler = bar.handler

	if (bar.config.barLink and bar.config.showstates) then

		local parentBar = M.BarIndexByName[bar.config.barLink]

		if (parentBar) then

			local parent = parentBar.handler

			if (parent and parent:GetParent() ~= handler) then

				handler:SetParent(parent:GetName())
				handler:SetAttribute("isBarChild", true)

				for k,v in pairs(M.Strings.STATES) do

					if (v == bar.config.showstates) then

						local state = k

						for kk,vv in pairs(ManagedStates) do
							if (k == vv.homestate) then
								state = "homestate"
							end
						end

						handler:SetAttribute("showstates", state)
					end
				end

				bar.updateVisibility(bar, parent:GetAttribute("state-current"))
			end
		end

	elseif (not bar.config.barLink and not bar.config.showstates) then

		handler:SetParent("UIParent")
		handler:SetAttribute("isBarChild", "nil")

		handler:SetAttribute("showstates", "homestate")

		bar.updateVisibility(bar, "homestate")
	end
end

local function updateBarTarget(bar, show)

	if (show or bar:IsVisible()) then

		bar.handler:SetAttribute("unit", nil)
		UnregisterUnitWatch(bar.handler)
	else

		local target = bar.config.target

		if (target and not bar.editmode) then
			bar.handler:SetAttribute("unit", target)
			RegisterUnitWatch(bar.handler)
		else
			bar.handler:SetAttribute("unit", nil)
			UnregisterUnitWatch(bar.handler)
		end
	end
end

local function updateBarHidden(bar, show, hide)

	local isAnchorChild = bar.handler:GetAttribute("isAnchorChild")

	if (not hide and not isAnchorChild and (show or bar:IsVisible())) then

		bar.handler:Show()
	else
		if (bar.config.hidden) then
			bar.handler:Hide()
		elseif (not bar.config.barLink and not isAnchorChild) then
			bar.handler:Show()
		end
	end
end

local function addStates(bar, handler, state, conditions)

	if (state and conditions) then

		if (bar.config.target) then
			conditions = gsub(conditions, "target=%P+", "target="..bar.config.target)
		end

		if (ManagedStates[state]) then
			RegisterStateDriver(handler, state, conditions)
		end

		if (ManagedStates[state].homestate) then
			handler:SetAttribute("handler-homestate", ManagedStates[state].homestate)
		end

		bar[state] = { registered = true }

		bar.updateBar(bar)
	end
end

local function clearStates(bar, handler, state, start, stop)

	local clearState

	if (state == "homestate") then

		if (bar[state] and bar[state].buttonCount and bar[state].buttonCount > 0) then
			M.RemoveButton(bar[state].buttonCount, bar, state)
		end

	elseif (state) then

		for i=start,stop do
			clearState = state..i
			if (bar[clearState] and bar[clearState].buttonCount and bar[clearState].buttonCount > 0) then
				M.RemoveButton(bar[clearState].buttonCount, bar, clearState)
			end
		end

		if (ManagedStates[state].homestate) then
			handler:SetAttribute("handler-homestate", nil)
		end

		handler:SetAttribute("state-"..state, nil)

		UnregisterStateDriver(handler, state)

		bar[state] = { registered = false }

		bar.config.arcData[state] = nil
		bar.config.padData[state] = nil
	end

	handler:SetAttribute("state-current", "homestate")
	handler:SetAttribute("state-last", "homestate")

	bar.updateBar(bar, nil, true, true)
end

local function updateBarSelfFocusCast(handler)

	local modifier

	handler:SetAttribute("alt-unit*", nil)
	handler:SetAttribute("ctrl-unit*", nil)
	handler:SetAttribute("shift-unit*", nil)

	if (SD.selfCast) then
		modifier = lower(match(SD.selfCast, "^%a+"))
		handler:SetAttribute(modifier.."-unit*", "player")
	end

	if (SD.focusCast) then
		modifier = lower(match(SD.focusCast, "^%a+"))
		handler:SetAttribute(modifier.."-unit*", "focus")
	end
end

local function updateRightCast(handler)

	handler:SetAttribute("alt-unit2", nil)
	handler:SetAttribute("ctrl-unit2", nil)
	handler:SetAttribute("shift-unit2", nil)
	handler:SetAttribute("unit2", nil)

	if (SD.rightClickTarget) then
		handler:SetAttribute("alt-unit2", SD.rightClickTarget)
		handler:SetAttribute("ctrl-unit2", SD.rightClickTarget)
		handler:SetAttribute("shift-unit2", SD.rightClickTarget)
		handler:SetAttribute("unit2", SD.rightClickTarget)
	end
end

local function buildStateMap(bar, remapState)

	local statemap, state, map, remap, homestate = "", gsub(remapState, "pagedbar", "bar")

	for states in gmatch(bar.config.remap, "[^;]+") do

		map, remap = (":"):split(states)

		if (not homestate) then
			statemap = statemap.."["..state..":"..map.."] homestate; "
			homestate = true
		else
			local newstate = remapState..remap

			if (ManagedStates[remapState] and
			    ManagedStates[remapState].homestate and
			    ManagedStates[remapState].homestate == newstate) then
				statemap = statemap.."["..state..":"..map.."] homestate; "
			else
				statemap = statemap.."["..state..":"..map.."] "..newstate.."; "
			end
		end

		if (map == "1" and bar.config.prowl and remapState == "stance") then
			statemap = statemap.."[stance:2/3,stealth] stance8; "
		end
	end

	statemap = gsub(statemap, "; $", "")

	return statemap
end

local function updateBarRemap(bar)

	local map, remap

	if (bar.config and bar.config.remap) then

		for i=1,GetNumShapeshiftForms() do

			if (not find(bar.config.remap, i..":%d+")) then

				if (strlen(bar.config.remap) < 1) then
					bar.config.remap = i..":"..i
				else
					bar.config.remap = bar.config.remap..";"..i..":"..i
				end
			end

		end
	end
end

local function updateBarOptions(bar)

	local handler, currState, data, start, stop = bar.handler

	if (bar.config.autoHide) then
		autoHideIndex[bar] = handler; handler.fadeSpeed = bar.config.fadeSpeed
	else
		autoHideIndex[bar] = nil
	end

	if (bar.config.alphaUp == M.Strings.ALPHAUP_NONE) then
		alphaupIndex[bar] = nil
	else
		alphaupIndex[bar] = handler; handler.fadeSpeed = bar.config.fadeSpeed
	end

	if (not bar.config.snapTo) then
		for k,v in pairs(M.BarIndex) do
			if (v.config.snapToFrame == bar:GetName()) then
				v.config.snapToFrame = false
				v.config.snapToPoint = false
				v.config.point, v.config.x, v.config.y = M.GetPosition(v)
				M.SetPosition(v)
			end
		end
	end

	updateBarRemap(bar)

	if (bar.stateschanged) then

		for state, values in pairs(ManagedStates) do

			if (bar.config[state]) then

				if (not bar[state] or not bar[state].registered) then

					local statemap

					if (bar.config.remap) then
						if (state == "pagedbar" or state == "stance") then
							statemap = buildStateMap(bar, state)
						end
					end

					if (state == "custom" and bar.config.custom) then

						addStates(bar, handler, state, bar.config.custom)

					elseif (statemap) then

						addStates(bar, handler, state, statemap)

					else
						addStates(bar, handler, state, values.states)

					end
				end

			elseif (bar[state] and bar[state].registered) then

				if (state == "custom" and bar.config.customRange) then

					local start = tonumber(match(bar.config.customRange, "^%d+"))
					local stop = tonumber(match(bar.config.customRange, "%d+$"))

					if (start and stop and bar[state] and bar[state].registered) then
						clearStates(bar, handler, state, start, stop)
					end

				else

					clearStates(bar, handler, state, values.rangeStart, values.rangeStop)

				end
			else

				for index, btnIDs in pairs(bar.config.buttonList) do

					local name = index:match("%a+")

					if (name and not bar.config[name]) then

						local count = 0

						for btnID in gmatch(btnIDs, "[^;]+") do
							count = count + 1
						end

						M.RemoveButton(count, bar, index)

						bar.config.buttonList[index] = nil
					end
				end
			end
		end
	end

	updateBarSelfFocusCast(handler)

	updateRightCast(handler)

	updateBarLink(bar)

	updateBarTarget(bar)

	bar.stateschanged = nil

	handler:SetAlpha(bar.config.alpha)

	bar:SetFrameStrata(bar.config.barStrata)
end

local function updateBarDualSpec(bar, spec)

	local data = bar.savedData

	if (spec and data and data.buttons) then

		local defaults = bar.btnDefaults()

		for k,v in pairs(bar.btnTable) do

			local button = v[1]

			if (button and bar == button.bar) then

				M.ClearBindings(button)

				if (not data.buttons[k][spec] and bar.config.dualSpec) then

					button.clearMacro(button)

					if (spec ~= 1 and data.buttons[k][1]) then
						button.config.hotKeys = data.buttons[k][1].hotKeys
						button.config.hotKeyText = data.buttons[k][1].hotKeyText
						button.config.hotKeyLock = data.buttons[k][1].hotKeyLock
						button.config.hotKeyPri = data.buttons[k][1].hotKeyPri
					end

					data.buttons[k][spec] = CopyTable(button.config)

					--print("change 1:"..k.." spec:"..spec)

				elseif (data.buttons[k][spec] and bar.config.dualSpec) then

					button.config = CopyTable(data.buttons[k][spec])

					--print("change 2:"..k.." spec:"..spec)
				else

					button.config = CopyTable(data.buttons[k][1])

					--print("change 3:"..k.." spec:"..spec)
				end

				M.UpdateConfig(button, defaults)

				M.ApplyBindings(button)

				M.SetButtonType(button, nil, nil, true)

				button.updateData(button, button.bar, button.config.showstates)
			end
		end
	end
end

local function updateBar(bar, options, shape, size, pos)

	bar.elapsed = 0; bar.alpha = bar.config.alpha; bar.alphaUp = bar.config.alphaUp

	if (options) then updateBarOptions(bar) end

	if (bar.config.buttonList) then

		for state, btnIDs in pairs(bar.config.buttonList) do

			if (not bar[state]) then
				bar[state] = {}
			end

			bar[state].buttonCount = 0

			for btnID in gmatch(btnIDs, "[^;]+") do
				bar[state].buttonCount = bar[state].buttonCount + 1
			end
		end
	end

	if (not bar.config.barLink and not bar.handler:GetAttribute("isAnchorChild")) then
		bar.handler:SetParent("UIParent")
	end

	if (shape) then updateShape(bar) end

	if (size) then updateBarSize(bar) end

	if (pos) then setPosition(bar) end

	updateBarHidden(bar)

	local state = bar.handler:GetAttribute("state-current")

	if (not state or strlen(state) < 1) then
		bar.handler:SetAttribute("state-current", "homestate")
	end

	bar.text:SetText(M.GetBarStateText(bar, state, true))

	if (bar.updateFunc) then bar.updateFunc(bar, bar.handler:GetAttribute("state-current")) end

	if (GameTooltip:IsVisible() and bar:IsVisible() and bar:IsMouseOver()) then
		M.Bar_OnEnter(bar)
	end

	M.Save()

end

local function barDefaults(index, bar)

	bar.config = {

		name = "Bar "..index,
		origID = index,

		scale = 1,
		alpha = 1,
		alphaUp = "none",
		fadeSpeed = 0.5,
		buttonStrata = "LOW",
		barStrata = "MEDIUM",
		autoHide = false,
		showGrid = false,
		hidden = false,
		dualSpec = false,
		shape = 1,
		skinnable = true,

		snapTo = false,
		snapToPad = 0,
		snapToPoint = false,
		snapToFrame = false,

		columns = false,

		padData = {},
		arcData = {},

		barLock = false,
		barLockAlt = false,
		barLockCtrl = false,
		barLockShift = false,

		tooltips = true,
		tooltipsEnhanced = true,
		tooltipsCombat = false,

		spellGlow = true,
		copyDrag = false,

		currentstate = "homestate",
		laststate = "homestate",

		barLink = false,
		showstates = "",

		point = "BOTTOM",
		x = 0,
		y = 190,

		target = false,

		homestate = true,
		pagedbar = false,
		stance = false,
		prowl = false,
		stealth = false,
		reaction = false,
		combat = false,
		group = false,
		companion = false,
		fishing = false,
		possess = false,
		vehicle = false,
		alt = false,
		ctrl = false,
		shift = false,

		custom = false,
		customRange = false,
		customNames = false,

		remap = false,

		stored = false,

		hotKeys = "",
		hotKeyText = "",
		hotKeysShown = true,

		buttonList = {
			homestate = "",
		},

		fix101810 = false
	}

	bar.elapsed = 3
end

local function createHandler(bar, barType)

	local handler = CreateFrame("Frame", "Macaroon"..barType.."Handler"..bar:GetID(), UIParent, "SecureHandlerStateTemplate")

	handler:SetAttribute("_onstate-pagedbar", [[

				self:SetAttribute("state-current", self:GetAttribute("state-pagedbar"))

				if (not self:GetAttribute("state-current")) then
					self:SetAttribute("state-current", "homestate")
				end

				control:ChildUpdate("pagedbar", self:GetAttribute("state-current"))

				self:SetAttribute("state-last", self:GetAttribute("state-pagedbar"))

				if (not self:GetAttribute("state-last")) then
					self:SetAttribute("state-last", "homestate")
				end
				]])
	handler:SetAttribute("_onstate-stance", [[

				self:SetAttribute("state-current", self:GetAttribute("state-stance"))

				if (not self:GetAttribute("state-current")) then
					self:SetAttribute("state-current", "homestate")
				end

				control:ChildUpdate("stance", self:GetAttribute("state-current"))

				self:SetAttribute("state-last", self:GetAttribute("state-stance"))

				if (not self:GetAttribute("state-last")) then
					self:SetAttribute("state-last", "homestate")
				end
				]])
	handler:SetAttribute("_onstate-companion", [[

				self:SetAttribute("state-current", self:GetAttribute("state-companion"))

				if (not self:GetAttribute("state-current")) then
					self:SetAttribute("state-current", "homestate")
				end

				control:ChildUpdate("companion", self:GetAttribute("state-current"))

				self:SetAttribute("state-last", self:GetAttribute("state-companion"))

				if (not self:GetAttribute("state-last")) then
					self:SetAttribute("state-last", "homestate")
				end

				]])
	handler:SetAttribute("_onstate-stealth", [[

				if (self:GetAttribute("state-stealth") and strfind(self:GetAttribute("state-stealth"), "laststate") and self:GetAttribute("state-pagedbar")) then

					self:SetAttribute("state-current", self:GetAttribute("state-pagedbar"))
					control:ChildUpdate("stealth", self:GetAttribute("state-current"))
					self:SetAttribute("state-last", self:GetAttribute("state-pagedbar"))

				elseif (self:GetAttribute("state-stealth") and strfind(self:GetAttribute("state-stealth"), "laststate") and self:GetAttribute("state-stance")) then

					self:SetAttribute("state-current", self:GetAttribute("state-stance"))
					control:ChildUpdate("stealth", self:GetAttribute("state-current"))
					self:SetAttribute("state-last", self:GetAttribute("state-stance"))

				elseif (self:GetAttribute("state-stealth") and strfind(self:GetAttribute("state-stealth"), "laststate")) then

					self:SetAttribute("state-current", "homestate")
					control:ChildUpdate("stealth", self:GetAttribute("state-current"))
					self:SetAttribute("state-last", "homestate")
				else
					self:SetAttribute("state-current", self:GetAttribute("state-stealth"))
					control:ChildUpdate("stealth", self:GetAttribute("state-current"))
					self:SetAttribute("state-last", self:GetAttribute("state-stealth"))
				end
				]])
	handler:SetAttribute("_onstate-reaction", [[

				if (self:GetAttribute("state-reaction") and strfind(self:GetAttribute("state-reaction"), "laststate")) then
					self:SetAttribute("state-current", self:GetAttribute("state-last"))
					control:ChildUpdate("reaction", self:GetAttribute("state-current"))
				else
					if (not self:GetAttribute("state-last")) then
						self:SetAttribute("state-last", self:GetAttribute("state-current"))
					end
					self:SetAttribute("state-current", self:GetAttribute("state-reaction"))
					control:ChildUpdate("reaction", self:GetAttribute("state-current"))
				end
				]])
	handler:SetAttribute("_onstate-combat", [[

				if (self:GetAttribute("state-combat") and strfind(self:GetAttribute("state-combat"), "laststate")) then
					self:SetAttribute("state-current", self:GetAttribute("state-last"))
					control:ChildUpdate("combat", self:GetAttribute("state-current"))
				else
					if (not self:GetAttribute("state-last")) then
						self:SetAttribute("state-last", self:GetAttribute("state-current"))
					end
					self:SetAttribute("state-current", self:GetAttribute("state-combat"))
					control:ChildUpdate("combat", self:GetAttribute("state-current"))
				end
				]])
	handler:SetAttribute("_onstate-group", [[

				if (self:GetAttribute("state-group") and strfind(self:GetAttribute("state-group"), "laststate")) then
					self:SetAttribute("state-current", self:GetAttribute("state-last"))
					control:ChildUpdate("group", self:GetAttribute("state-current"))
				else
					if (not self:GetAttribute("state-last")) then
						self:SetAttribute("state-last", self:GetAttribute("state-current"))
					end
					self:SetAttribute("state-current", self:GetAttribute("state-group"))
					control:ChildUpdate("group", self:GetAttribute("state-current"))
				end
				]])

	handler:SetAttribute("_onstate-fishing", [[

				if (self:GetAttribute("state-fishing") and strfind(self:GetAttribute("state-fishing"), "laststate")) then
					self:SetAttribute("state-current", self:GetAttribute("state-last"))
					control:ChildUpdate("fishing", self:GetAttribute("state-current"))

				else
					if (not self:GetAttribute("state-last")) then
						self:SetAttribute("state-last", self:GetAttribute("state-current"))
					end
					self:SetAttribute("state-current", self:GetAttribute("state-fishing"))
					control:ChildUpdate("fishing", self:GetAttribute("state-current"))
				end

				]])

	handler:SetAttribute("_onstate-possess", [[

				if (self:GetAttribute("state-possess") and strfind(self:GetAttribute("state-possess"), "laststate")) then
					self:SetAttribute("state-current", self:GetAttribute("state-last"))
					control:ChildUpdate("possess", self:GetAttribute("state-current"))

				else

					if (not self:GetAttribute("state-last")) then
						self:SetAttribute("state-last", self:GetAttribute("state-current"))
					end

					self:SetAttribute("state-current", self:GetAttribute("state-possess"))
					control:ChildUpdate("possess", self:GetAttribute("state-current"))
				end

				]])
	handler:SetAttribute("_onstate-vehicle", [[

				if (self:GetAttribute("state-vehicle") and strfind(self:GetAttribute("state-vehicle"), "laststate")) then
					self:SetAttribute("state-current", self:GetAttribute("state-last"))
					control:ChildUpdate("vehicle", self:GetAttribute("state-current"))

				else
					if (not self:GetAttribute("state-last")) then
						self:SetAttribute("state-last", self:GetAttribute("state-current"))
					end
					self:SetAttribute("state-current", self:GetAttribute("state-vehicle"))
					control:ChildUpdate("vehicle", self:GetAttribute("state-current"))
				end

				]])
	handler:SetAttribute("_onstate-alt", [[

				if (self:GetAttribute("state-alt") and strfind(self:GetAttribute("state-alt"), "laststate")) then
					self:SetAttribute("state-current", self:GetAttribute("state-last"))
					control:ChildUpdate("alt", self:GetAttribute("state-current") or "homestate")
					self:SetAttribute("state-last", nil)
				else
					if (not self:GetAttribute("state-last")) then
						self:SetAttribute("state-last", self:GetAttribute("state-current"))
					end
					self:SetAttribute("state-current", self:GetAttribute("state-alt"))
					control:ChildUpdate("alt", self:GetAttribute("state-current"))
				end
				]])

	handler:SetAttribute("_onstate-ctrl", [[

				if (self:GetAttribute("state-ctrl") and strfind(self:GetAttribute("state-ctrl"), "laststate")) then
					self:SetAttribute("state-current", self:GetAttribute("state-last"))
					control:ChildUpdate("ctrl", self:GetAttribute("state-current") or "homestate")
					self:SetAttribute("state-last", nil)
				else
					if (not self:GetAttribute("state-last")) then
						self:SetAttribute("state-last", self:GetAttribute("state-current"))
					end
					self:SetAttribute("state-current", self:GetAttribute("state-ctrl"))
					control:ChildUpdate("ctrl", self:GetAttribute("state-current"))
				end
				]])

	handler:SetAttribute("_onstate-shift", [[

				if (self:GetAttribute("state-shift") and strfind(self:GetAttribute("state-shift"), "laststate")) then
					self:SetAttribute("state-current", self:GetAttribute("state-last"))
					control:ChildUpdate("shift", self:GetAttribute("state-current") or "homestate")
					self:SetAttribute("state-last", nil)
				else
					if (not self:GetAttribute("state-last")) then
						self:SetAttribute("state-last", self:GetAttribute("state-current"))
					end
					self:SetAttribute("state-current", self:GetAttribute("state-shift"))
					control:ChildUpdate("shift", self:GetAttribute("state-current"))
				end
				]])

	handler:SetAttribute("_onstate-custom", [[

				self:SetAttribute("state-last", self:GetAttribute("state-current"))
				self:SetAttribute("state-current", self:GetAttribute("state-custom"))
				control:ChildUpdate("custom", self:GetAttribute("state-current"))
				]])

	handler:SetAttribute("_onstate-homestate", [[	]])

	handler:SetAttribute("_onstate-laststate", [[	]])

	handler:SetAttribute("_onshow", [[control:ChildUpdate("onshow", self:GetAttribute("state-current"))]])

	handler:SetAttribute("_childupdate", [[

			if (self:GetAttribute("isBarChild")) then

				self:SetAttribute("stateshown", false)

				if (self:GetAttribute("showstates")) then
					for showstate in gmatch(self:GetAttribute("showstates"), "[^;]+") do
						if (message and strfind(message, showstate)) then
							self:Show()
							self:SetAttribute("stateshown", true)
						end
					end
				end

				if (not self:GetAttribute("stateshown")) then
					self:Hide()
				end
			end
		]] )

	handler:SetAttribute("state-current", "homestate")
	handler:SetAttribute("state-last", "homestate")
	handler:SetAttribute("showstates", "homestate")

	handler:HookScript("OnAttributeChanged",

			function(self,name,value)

				if (self:GetAttribute("state-current")) then
					self.bar.config.currentstate = self:GetAttribute("state-current")
				else
					self.bar.config.currentstate = "homestate"
				end

				if (self:GetAttribute("state-last")) then
					self.bar.config.laststate = self:GetAttribute("state-last")
				else
					self.bar.config.laststate = "homestate"
				end

				if (self.bar:IsVisible()) then

					if (not InCombatLockdown()) then

						if (not self:GetAttribute("state-current")) then
							self:SetAttribute("state-current", "homestate")
						end

						if (not self:GetAttribute("state-last")) then
							self:SetAttribute("state-last", "homestate")
						end

						updateBar(self.bar, nil, nil, true)
					end
				end
			end)

	handler.bar = bar

	handler:SetAllPoints(bar)

	return handler
end

local function createBar(index, barType, savedData, barTable, modifiedDefaults, btnTable, btnType, btnNew, btnSetNew, btnDefaults)

	local bar

	if (_G["Macaroon"..barType..index]) then
		bar = _G["Macaroon"..barType..index]

		for state, btnIDs in pairs(bar.config.buttonList) do
			ClearTable(bar[state])
		end
	else
	 	bar = CreateFrame("Button", "Macaroon"..barType..index, UIParent, "MacaroonBarTemplate")
	end

	bar:SetID(index)

	bar.handler = createHandler(bar, barType)

	barDefaults(index, bar)

	if (modifiedDefaults) then
		modifiedDefaults(index, bar)
	end

	bar:SetPoint(bar.config.point, bar.config.x, bar.config.y)
	bar.config.point, bar.config.x, bar.config.y = M.GetPosition(bar)

	bar.updateBar = updateBar
	bar.updateBarLink = updateBarLink
	bar.updateBarHidden = updateBarHidden
	bar.updateBarTarget = updateBarTarget
	bar.updateVisibility = updateVisibility
	bar.updateBarDualSpec = updateBarDualSpec

	bar.hasAction = "Interface\\Buttons\\UI-Quickslot2"
	bar.noAction = "Interface\\Buttons\\UI-Quickslot"

	bar.savedData = savedData
	bar.barTable = barTable
	bar.btnTable = btnTable
	bar.btnType = btnType
	bar.btnNew = btnNew
	bar.btnSetNew = btnSetNew
	bar.btnDefaults = btnDefaults

	if (not savedData[barType:lower()]) then
		savedData[barType:lower()] = {}
	end

	savedData[barType:lower()][index] = { bar.config }

	barTable[index] = bar

	M.BarIndex[bar:GetName()] = bar

	bar.updateBar(bar)

	return bar
end

local function dockLock(button)

	if (button) then

		local dock = button.dock

		if (dock and dock:GetID() > 0) then

			if (button:GetChecked()) then
				dock.locked = dock:GetID()
			else
				dock.locked = false
			end

			M.UpdateShape(dock, true)
		end
	end
end

local function findNextDock(last)

	for k,v in ipairs(dockIndex) do
		if (not v[1].locked and k > last) then
			return k
		end
	end

	if (last >= #dockIndex) then
		return #dockIndex+1
	else
		return #dockIndex
	end
end

function M.LoadConfig(bar, config)

	local table = CopyTable(config)

	M.BarIndexByName[table.name] = bar

	M.Save()

	return table
end

function M.DeleteBar(frame)

	local bar = frame

	if (not bar) then
		bar = M.CurrentBar
	end

	if (bar) then

		bar.handler:SetAttribute("state-current", "homestate")
		bar.handler:SetAttribute("state-last", "homestate")
		bar.handler:SetAttribute("showstates", "homestate")

		clearStates(bar, bar.handler, "homestate")

		for state, values in pairs(ManagedStates) do

			if (bar.config[state] and bar[state] and bar[state].registered) then

				if (state == "custom" and bar.config.customRange) then

					local start = tonumber(match(bar.config.customRange, "^%d+"))
					local stop = tonumber(match(bar.config.customRange, "%d+$"))

					if (start and stop and bar[state] and bar[state].registered) then
						clearStates(bar, bar.handler, state, start, stop)
					end

				else
					clearStates(bar, bar.handler, state, values.rangeStart, values.rangeStop)
				end

			end

			if (bar[state]) then
				M.ReleaseAnchor(bar, state); bar[state] = nil
			end
		end

		bar:SetWidth(36)
		bar:SetHeight(36)
		bar:ClearAllPoints()
		bar:SetPoint("CENTER")
		bar:Hide()

		bar.barTable[bar:GetID()] = nil

		M.BarIndex[bar:GetName()] = nil
		M.BarIndexByName[bar.config.name] = nil

		M.Save()
	end
end

-- 1=Bar Type, 2=Saved Data, 3=Bar Table, 4=Button Table, 5=Button Prefix, 6=Add Button, 7=Bar Defaults, 8=Button Defaults, 9=Bar Create Msg, 10=Button Type }

function M.CreateBar(msg, load, modifiedDefaults, config)

	local index, barType, savedData, barTable, btnTable, btnType, btnNew, btnSetNew, btnDefaults

	if (M.CreateBarTypes[msg]) then

		barType = M.CreateBarTypes[msg][1]
		savedData = M.CreateBarTypes[msg][2]
		barTable = M.CreateBarTypes[msg][3]
		btnTable = M.CreateBarTypes[msg][4]
		btnType = M.CreateBarTypes[msg][5]
		btnNew = M.CreateBarTypes[msg][6]
		btnSetNew = M.CreateBarTypes[msg][7]
		btnDefaults = M.CreateBarTypes[msg][8]

		if (modifiedDefaults) then modifiedDefaults = M.CreateBarTypes[msg][9] end

	else
		local data, index, high = {}, 1, 0

		for k,v in pairs(M.CreateBarTypes) do

			index = tonumber(v[11]:match("%d+"))
			barType = v[11]:gsub("%d+","")

			if (index  and barType) then
				data[index] = { k, barType }
				if (index > high) then high = index end
			end
		end

		for i=1,high do if (not data[i]) then data[i] = 0 end end

		print("Usage: /mac create <type>\n")
		print("     Types -\n")

		for k,v in ipairs(data) do
			print("       |cff00ff00"..v[1].."|r: "..v[2])
		end

		return
	end

	index = #barTable + 1

	if (not index) then index = 1 end

	local bar = createBar(index, barType, savedData, barTable, modifiedDefaults, btnTable, btnType, btnNew, btnSetNew, btnDefaults)

	bar.bartype = msg
	bar.objtype = M.CreateBarTypes[msg][10]
	bar:SetWidth(195)
	bar:SetHeight(36*bar.config.scale)

	if (not load) then
		M.ChangeBar(bar)
		M.ConfigBars(nil, true)
	end

	if (config) then
		bar.config = M.LoadConfig(bar, config)
	else
		bar.config = M.LoadConfig(bar, bar.config)
	end

	return bar
end

function M.CreateNewBar(msg)
	local bar = M.CreateBar(msg, nil, true)
end

function M.AutohideBar(command, gui, checked)

	local bar = M.CurrentBar

	if (bar) then

		local toggle = bar.config.autoHide

		if (toggle) then
			bar.config.autoHide = false
			bar.handler:SetAlpha(1)
		else
			bar.config.autoHide = true
		end

		bar.updateBar(bar, true)
	else
		MacaroonMessageFrame:AddMessage(M.Strings.NO_BAR_SELECTED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
	end

end

function M.ShowgridSet(command, gui)

	local bar = M.CurrentBar

	if (bar) then

		local toggle = bar.config.showGrid

		if (toggle) then
			bar.config.showGrid = false

			if (not gui) then
				MacaroonMessageFrame:AddMessage(M.Strings.BAR_SHOWGRID_DISABLED..M.CurrentBar.config.name, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
			end
		else
			bar.config.showGrid = true

			if (not gui) then
				MacaroonMessageFrame:AddMessage(M.Strings.BAR_SHOWGRID_ENABLED..M.CurrentBar.config.name, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
			end
		end

		bar.updateBar(bar, nil, true)
	else
		MacaroonMessageFrame:AddMessage(M.Strings.NO_BAR_SELECTED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
	end
end

function M.SnapToBar(command, gui)

	local bar = M.CurrentBar

	if (bar) then

		local toggle = bar.config.snapTo

		if (toggle) then
			bar.config.snapTo = false
			bar.config.snapToPoint = false
			bar.config.snapToFrame = false
			bar:SetUserPlaced(true)
			bar.config.point, bar.config.x, bar.config.y = M.GetPosition(bar)
			M.SetPosition(bar)

			if (not gui) then
				MacaroonMessageFrame:AddMessage(M.Strings.BAR_SNAPTO_DISABLED..M.CurrentBar.config.name, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
			end
		else
			bar.config.snapTo = true

			if (not gui) then
				MacaroonMessageFrame:AddMessage(M.Strings.BAR_SNAPTO_ENABLED..M.CurrentBar.config.name, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
			end
		end

		bar.updateBar(bar, true)
	else
		MacaroonMessageFrame:AddMessage(M.Strings.NO_BAR_SELECTED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
	end
end

function M.HideBar(command, gui)

	if (InCombatLockdown()) then return end

	local bar

	if (command) then

		bar = M.BarIndexByName[command]

		if (not bar) then
			MacaroonMessageFrame:AddMessage(M.Strings.INVALID_CHOICE, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
			return
		end
	else
		bar = M.CurrentBar
	end

	if (bar) then

		local toggle = bar.config.hidden

		if (toggle) then
			bar.config.hidden = false
			if (bar.selected) then
				bar:SetBackdropColor(0,0,1,0.4)
			else
				bar:SetBackdropColor(0,0,0,0.2)
			end
			if (not command and not gui) then
				MacaroonMessageFrame:AddMessage(M.Strings.BAR_HIDDEN_DISABLED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
			end
		else
			bar.config.hidden = true
			if (bar.selected) then
				bar:SetBackdropColor(1,0,0,0.4)
			else
				bar:SetBackdropColor(0.75,0,0,0.2)
			end
			if (not command and not gui) then
				MacaroonMessageFrame:AddMessage(M.Strings.BAR_HIDDEN_ENABLED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
			end
		end

		bar.updateBar(bar, true)
	else
		MacaroonMessageFrame:AddMessage(M.Strings.NO_BAR_SELECTED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
	end
end

function M.DualSpec(command, gui)

	local bar = M.CurrentBar

	if (bar) then

		local toggle = bar.config.dualSpec

		if (toggle) then
			bar.config.dualSpec = false

			if (not gui) then
				MacaroonMessageFrame:AddMessage(M.Strings.BAR_DUALSPEC_DISABLED..M.CurrentBar.config.name, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
			end
		else
			bar.config.dualSpec = true

			if (not gui) then
				MacaroonMessageFrame:AddMessage(M.Strings.BAR_DUALSPEC_ENABLED..M.CurrentBar.config.name, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
			end
		end

		bar.updateBarDualSpec(bar, GetActiveTalentGroup())

	else
		MacaroonMessageFrame:AddMessage(M.Strings.NO_BAR_SELECTED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
	end
end

function M.ScaleBar(scale)

	local bar = M.CurrentBar

	if (bar) then

		bar.config.scale = scale
		bar.updateBar(bar, true, true, true)
	else
		MacaroonMessageFrame:AddMessage(M.Strings.NO_BAR_SELECTED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
	end
end

function M.ShapeBar(command)

	local bar = M.CurrentBar

	if (bar) then

		if (not command) then
			DEFAULT_CHAT_FRAME:AddMessage(M.Strings.BAR_SHAPES)
		else

			local shape = tonumber(command)

			if (shape) then
				bar.config.shape = shape
				bar.updateBar(bar, true, true, true)
			else
				MacaroonMessageFrame:AddMessage(M.Strings.INVALID_CHOICE, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
			end
		end
	else
		MacaroonMessageFrame:AddMessage(M.Strings.NO_BAR_SELECTED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
	end
end

function M.NameBar(name, gui)

	local bar = M.CurrentBar

	if (gui) then
		bar = gui
	end

	if (bar) then

		if (name) then

			if (M.BarIndexByName[name] and M.BarIndexByName[name] ~= bar) then

				if (gui) then
					return false
				else
					MacaroonMessageFrame:AddMessage(M.Strings.NAMING_CONFLICT, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
				end

			else

				M.BarIndexByName[bar.config.name] = nil
				M.BarIndexByName[name] = bar

				bar.config.name = name

				bar.updateBar(bar)

				return true
			end
		else
			MacaroonMessageFrame:AddMessage(M.Strings.INVALID_CHOICE, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
		end
	else
		MacaroonMessageFrame:AddMessage(M.Strings.NO_BAR_SELECTED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
	end

	return false
end

function M.StrataSet(command)

	local bar = M.CurrentBar

	if (bar) then

		if (not command) then
			DEFAULT_CHAT_FRAME:AddMessage(M.Strings.BAR_STRATAS)
		else

			local strata = tonumber(command)

			if (strata and strata>0 and strata<#stratas) then

				bar.config.buttonStrata = stratas[strata]
				bar.config.barStrata = stratas[strata+1]
				bar.updateBar(bar, true, true)
			else
				MacaroonMessageFrame:AddMessage(M.Strings.INVALID_CHOICE, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
			end
		end
	else
		MacaroonMessageFrame:AddMessage(M.Strings.NO_BAR_SELECTED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
	end
end

function M.AlphaSet(command)

	local bar = M.CurrentBar

	if (bar) then

		if (not command) then
			DEFAULT_CHAT_FRAME:AddMessage(M.Strings.BAR_ALPHA)
		else

			local alpha = tonumber(command)

			if (alpha and alpha>=0 and alpha<=1) then

				bar.config.alpha = alpha
				bar.updateBar(bar, true)
			else
				MacaroonMessageFrame:AddMessage(M.Strings.INVALID_CHOICE, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
			end
		end
	else
		MacaroonMessageFrame:AddMessage(M.Strings.NO_BAR_SELECTED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
	end

end

function M.AlphaUpSet(command)

	local bar = M.CurrentBar

	if (bar) then

		if (not command) then

			local text = ""

			for k,v in ipairs(alphaUps) do
				text = text.."\n"..k.."="..v
			end

			DEFAULT_CHAT_FRAME:AddMessage(text)
		else

			local alphaUp = tonumber(command)

			if (alphaUp and alphaUp>0 and alphaUp<#alphaUps+1) then

				bar.config.alphaUp = alphaUps[alphaUp]
				bar.updateBar(bar, true)
			else
				MacaroonMessageFrame:AddMessage(M.Strings.INVALID_CHOICE, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
			end
		end
	else
		MacaroonMessageFrame:AddMessage(M.Strings.NO_BAR_SELECTED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
	end

end

function M.ArcStartSet(command)

	local bar = M.CurrentBar

	if (bar) then

		if (not command) then
			DEFAULT_CHAT_FRAME:AddMessage(M.Strings.BAR_ARCSTART)
		else

			local start = tonumber(command)

			if (start and start>=0 and start<=359) then

				local state = bar.handler:GetAttribute("state-current")

				if (not bar.config.arcData[state]) then
					bar.config.arcData[state] = "0:359"
				end

				local arcStart, arcLength = (":"):split(bar.config.arcData[state])

				arcLength = tonumber(arcLength)

				bar.config.arcData[state] = start..":"..arcLength
				bar.updateBar(bar, nil, true, true)
			else
				MacaroonMessageFrame:AddMessage(M.Strings.INVALID_CHOICE, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
			end
		end
	else
		MacaroonMessageFrame:AddMessage(M.Strings.NO_BAR_SELECTED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
	end
end

function M.ArcLengthSet(command)

	local bar = M.CurrentBar

	if (bar) then

		if (not command) then
			DEFAULT_CHAT_FRAME:AddMessage(M.Strings.BAR_ARCLENGTH)
		else

			local length = tonumber(command)

			if (length and length>=0 and length<=359) then

				local state = bar.handler:GetAttribute("state-current")

				if (not bar.config.arcData[state]) then
					bar.config.arcData[state] = "0:359"
				end

				local arcStart, arcLength = (":"):split(bar.config.arcData[state])

				arcStart = tonumber(arcStart)

				bar.config.arcData[state] = arcStart..":"..length
				bar.updateBar(bar, nil, true, true)
			else
				MacaroonMessageFrame:AddMessage(M.Strings.INVALID_CHOICE, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
			end
		end
	else
		MacaroonMessageFrame:AddMessage(M.Strings.NO_BAR_SELECTED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
	end
end

function M.ColumnsSet(command)

	local bar = M.CurrentBar

	if (bar) then

		if (not command) then
			DEFAULT_CHAT_FRAME:AddMessage(M.Strings.BAR_COLUMNS)
		else

			local columns = tonumber(command)

			if (columns and columns>0) then

				bar.config.columns = columns
				bar.updateBar(bar, nil, true, true)
			else
				bar.config.columns = false
				bar.updateBar(bar, nil, true, true)
			end
		end
	else
		MacaroonMessageFrame:AddMessage(M.Strings.NO_BAR_SELECTED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
	end

end

function M.PadHSet(command)

	local bar = M.CurrentBar

	if (bar) then

		if (not command) then
			DEFAULT_CHAT_FRAME:AddMessage(M.Strings.BAR_PADH)
		else

			local new_padh = tonumber(command)

			if (new_padh) then

				local state = bar.handler:GetAttribute("state-current")

				if (not bar.config.padData[state]) then
					bar.config.padData[state] = "0:0"
				end

				local padH, padV = (":"):split(bar.config.padData[state])

				padV = tonumber(padV)

				bar.config.padData[state] = new_padh..":"..padV
				bar.updateBar(bar, nil, true, true)
			else
				MacaroonMessageFrame:AddMessage(M.Strings.INVALID_CHOICE, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
			end
		end
	else
		MacaroonMessageFrame:AddMessage(M.Strings.NO_BAR_SELECTED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
	end

end

function M.PadVSet(command)

	local bar = M.CurrentBar

	if (bar) then

		if (not command) then
			DEFAULT_CHAT_FRAME:AddMessage(M.Strings.BAR_PADV)
		else

			local new_padv = tonumber(command)

			if (new_padv) then

				local state = bar.handler:GetAttribute("state-current")

				if (not bar.config.padData[state]) then
					bar.config.padData[state] = "0:0"
				end

				local padH, padV = (":"):split(bar.config.padData[state])

				padH = tonumber(padH)

				bar.config.padData[state] = padH..":"..new_padv
				bar.updateBar(bar, nil, true, true)
			else
				MacaroonMessageFrame:AddMessage(M.Strings.INVALID_CHOICE, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
			end
		end
	else
		MacaroonMessageFrame:AddMessage(M.Strings.NO_BAR_SELECTED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
	end

end

function M.PadHVSet(command)

	local bar = M.CurrentBar

	if (bar) then

		if (not command) then
			DEFAULT_CHAT_FRAME:AddMessage(M.Strings.BAR_PADHV)
		else

			local padhv = tonumber(command)

			if (padhv) then

				local state = bar.handler:GetAttribute("state-current")

				if (not bar.config.padData[state]) then
					bar.config.padData[state] = "0:0"
				end

				local padH, padV = (":"):split(bar.config.padData[state])

				padH = tonumber(padH); padV = tonumber(padV)

				bar.config.padData[state] = (padH+padhv)..":"..(padV+padhv)
				bar.updateBar(bar, nil, true, true)
			else
				MacaroonMessageFrame:AddMessage(M.Strings.INVALID_CHOICE, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
			end
		end
	else
		MacaroonMessageFrame:AddMessage(M.Strings.NO_BAR_SELECTED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
	end

end

function M.XAxisSet(x)

	local bar = M.CurrentBar

	if (bar) then

		bar.config.x = x

		M.SetPosition(bar)

		bar.config.point, bar.config.x, bar.config.y = M.GetPosition(bar)

		bar.message:Show()
		bar.messagebg:Show()
	else
		MacaroonMessageFrame:AddMessage(M.Strings.NO_BAR_SELECTED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
	end

end

function M.YAxisSet(y)

	local bar = M.CurrentBar

	if (bar) then

		bar.config.y = y

		M.SetPosition(bar)

		bar.config.point, bar.config.x, bar.config.y = M.GetPosition(bar)

		bar.message:Show()
		bar.messagebg:Show()
	else
		MacaroonMessageFrame:AddMessage(M.Strings.NO_BAR_SELECTED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
	end

end

function M.SetBarStates(msg, gui, silent)

	local bar = M.CurrentBar

	if (bar) then

		if (not msg) then
			if (not silent) then
				M.PrintStateList()
				return
			end
		end

		local state = match(msg, "^%S+")
		local command = gsub(msg, state, ""); command = gsub(command, "^%s+", "")

		if (not ManagedStates[state]) then
			if (not silent) then
				M.PrintStateList()
				return
			end
		end

		if (bar.config[state] and not gui) then

			bar.config[state] = false

		elseif (not gui) then

			bar.config[state] = true
		end

		if (state == "pagedbar") then

			bar.config.stance = false
			bar.config.companion = false

			if (bar.config.pagedbar) then
				bar.config.remap = ""
				for i=1,6 do
					bar.config.remap = bar.config.remap..i..":"..i..";"
				end
				bar.config.remap = gsub(bar.config.remap, ";$", "")
			else
				bar.config.remap = false
			end
		end

		if (state == "stance") then

			bar.config.pagedbar = false

			if (not bar.config.stance and bar.config.prowl) then
				bar.config.prowl = false
			end

			bar.config.companion = false

			if (bar.config.stance) then

				local start = tonumber(match(M.ManagedStates.stance.homestate, "%d+"))

				if (start) then

					bar.config.remap = ""

					for i=start,7 do
						bar.config.remap = bar.config.remap..i..":"..i..";"
					end

					bar.config.remap = gsub(bar.config.remap, ";$", "")

					if (UnitClass("player") == M.Strings.ROGUE) then
						bar.config.remap = gsub(bar.config.remap, "2:2", "2:1")
						bar.config.remap = gsub(bar.config.remap, "3:3", "3:2")
					end

					if (UnitClass("player") == M.Strings.WARLOCK) then
						bar.config.remap = gsub(bar.config.remap, "2:2", "2:1")
					end
				end
			else
				bar.config.remap = false
			end
		end

		if (state == "custom") then

			if (bar.config.custom) then

				local count, newstates = 0, ""

				bar.config.customNames = {}

				for states in gmatch(command, "[^;]+") do

					bar.config.customRange = "1;"..count

					if (count == 0) then
						newstates = states.." homestate; "
						bar.config.customNames["homestate"] = states
					else
						newstates = newstates..states.." custom"..count.."; "
						bar.config.customNames["custom"..count] = states
					end

					count = count + 1
				end

				bar.config.custom = newstates or ""

			else
				bar.config.customNames = false
				bar.config.customRange = false
			end
		end

		if (state == "companion") then
			bar.config.pagedbar = false
			bar.config.stance = false
		end

		if (state == "control") then
			bar.config.possess = false
			bar.config.vehicle = false
		end

		if (state == "possess" or state == "vehicle") then
			bar.config.control = false
		end

		bar.stateschanged = true

		bar.updateBar(bar, true)

	elseif (not silent) then

		MacaroonMessageFrame:AddMessage(M.Strings.NO_BAR_SELECTED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)

	end

end

function M.PrintStateList()

	local data, list = {}

	for k,v in pairs(ManagedStates) do
		data[v.printOrder] = k
	end

	for k,v in ipairs(data) do

		if (not list) then
			list = "\n|cff00ff00Valid states:|r "..v
		else
			list = list..", "..v
		end
	end

	DEFAULT_CHAT_FRAME:AddMessage(list..M.Strings.CUSTOM_OPTION)
end

function M.GetPosition(frame, oFrame)

	local relFrame, point

	if (oFrame) then
		relFrame = oFrame
	else
		relFrame = frame:GetParent()
	end

	local s = frame:GetScale()
	local w, h = relFrame:GetWidth()/s, relFrame:GetHeight()/s
	local x, y = frame:GetCenter()
	local vert = (y>h/1.5) and "TOP" or (y>h/3) and "CENTER" or "BOTTOM"
	local horz = (x>w/1.5) and "RIGHT" or (x>w/3) and "CENTER" or "LEFT"

	if (vert == "CENTER") then
		point = horz
	elseif (horz == "CENTER") then
		point = vert
	else
		point = vert..horz
	end

	if (find(vert, "CENTER")) then y = y - h/2 end
	if (find(horz, "CENTER")) then x = x - w/2 end
	if (find(point, "RIGHT")) then x = x - w end
	if (find(point, "TOP")) then y = y - h end

	return point, x, y
end

function M.SetPosition(frame)

	if (frame.config.snapToPoint and frame.config.snapToFrame) then
		M.SnapTo.StickToPoint(frame, _G[frame.config.snapToFrame], frame.config.snapToPoint, frame.config.snapToPad, frame.config.snapToPad)
	else

		local point, x, y = frame.config.point, frame.config.x, frame.config.y

		frame:SetUserPlaced(false)
		frame:ClearAllPoints()
		frame:SetPoint("CENTER", "UIParent", point, x, y)
		frame:SetUserPlaced(true)

		if (frame.message) then
			frame.message:SetText(point:lower().."     x: "..format("%0.2f", x).."     y: "..format("%0.2f", y))
			frame.messagebg:SetWidth(frame.message:GetWidth()*1.05)
			frame.messagebg:SetHeight(frame.message:GetHeight()*1.1)
		end

		frame.posSet = true
	end
end

function M.UpdateBarPositions(table, reset, y)

	if (reset) then

		for k,bar in pairs(table) do
			y = setDefaultPosition(bar, y)
		end
	else
		for k,bar in pairs(table) do
			setPosition(bar)
		end
	end

	return y
end

function M.GetBarStateText(bar, state, addName)

	local text, name = "", ""

	if (addName) then
		name = bar.config.name.." - "
	end

	if (state) then

		if (bar.config.custom and bar.config.customNames and bar.config.customNames[state]) then

			text = name..bar.config.customNames[state]

		elseif(M.Strings.STATES[state]) then

			if (state == "homestate") then

				if (bar.pagedbar and bar.pagedbar.registered) then

					text = name..M.Strings.STATES.pagedbar1

				elseif (bar.stance and bar.stance.registered) then

					if (UnitClass("player") == M.Strings.WARRIOR) then

						local stanceState = M.Strings.STATES.stance1 or M.Strings.STATES[state]

						if (stanceState) then
							text = name..stanceState
						else
							text = name
						end
					else
						local stanceState = M.Strings.STATES.stance0 or M.Strings.STATES[state]

						if (stanceState) then
							text = name..stanceState
						else
							text = name
						end
					end

				elseif (bar.companion and bar.companion.registered) then

					text = name..M.Strings.STATES.companion0

				else
					text = name..M.Strings.STATES[state]
				end

			else

				text = name..M.Strings.STATES[state]
			end
		else
			text = name..state.."(not indexed - oops)"
		end

	else
		text = name.."(unidentified - oops)"
	end

	return text
end

function M.UpdateConfig(element, defaults)

	-- Add new vars
	for key,value in pairs(defaults) do

		if (element.config[key] == nil) then

			if (element.config[lower(key)] ~= nil) then

				element.config[key] = element.config[lower(key)]
				element.config[lower(key)] = nil
			else
				element.config[key] = value
			end
		end
	end
	-- Add new vars

	-- Var fixes

		---none

	-- Var fixes

	-- Kill old vars
	for key,value in pairs(element.config) do
		if (defaults[key] == nil) then
			element.config[key] = nil
		end
	end
	-- Kill old vars
end

function M.GetBarDefaults()

	local defaults = {}

	barDefaults(0, defaults)

	return defaults.config
end

function M.LoadSavedData(saved)

	if (saved) then

		load = true

		local data = CopyTable(saved)
		local defaultConfig

		if (data.bars) then

			ClearTable(M.ButtonBars)

			defaultConfig = M.GetBarDefaults()

			for k,v in pairs(data.bars) do

				local bar = M.CreateBar("bar", true, nil, data.bars[k][1])

				M.UpdateConfig(bar, defaultConfig)

				bar.handler:SetAttribute("state-current", bar.config.currentstate or "homestate")

				bar.handler:SetAttribute("state-last", bar.config.laststate or "homestate")

				if (not bar.config.fix101810) then

					if (bar.config.stance and (UnitClass("player") == M.Strings.ROGUE or UnitClass("player") == M.Strings.WARLOCK)) then

						local start = tonumber(match(M.ManagedStates.stance.homestate, "%d+"))

						if (start) then

							bar.config.remap = ""

							for i=start,7 do
								bar.config.remap = bar.config.remap..i..":"..i..";"
							end

							bar.config.remap = gsub(bar.config.remap, ";$", "")

							if (UnitClass("player") == M.Strings.ROGUE) then
								bar.config.remap = gsub(bar.config.remap, "2:2", "2:1")
								bar.config.remap = gsub(bar.config.remap, "3:3", "3:2")
							end

							if (UnitClass("player") == M.Strings.WARLOCK) then
								bar.config.remap = gsub(bar.config.remap, "2:2", "2:1")
							end
						end
					end

					bar.config.fix101810 = true
				end
			end

			data.bars = nil
		end

		if (data.buttons) then

			local spec = MacaroonSpecProfiles.LastSpec

			for k,v in pairs(M.Buttons) do
				M.StoreButton(v[1], M.Buttons)
			end

			defaultConfig = M.GetButtonDefaults()

			for k,v in pairs(data.buttons) do

				local button = M.CreateButton(k)

				button.config = CopyTable(data.buttons[k][spec] or data.buttons[k][1])

				button.config.stored = true

				M.UpdateConfig(button, defaultConfig)

				-- 09/16/2010 fix for upclicks being set to false making buttons non-responsive. Also tests the new fix system.
				if (not button.config.fix091610) then
					button.config.upClicks = true; button.config.fix091610 = true
				end

				--10/03/2010 change the /select command to /flyout
				if (not button.config.fix100310) then
					if (button.config.macro) then
						button.config.macro = button.config.macro:gsub("/select", "/flyout")
					end
					button.config.fix100310 = true
				end

				--11/27/2011 change to macro icons
				if (not button.config.fix112711) then
					if (button.config.macroIcon and type(button.config.macroIcon) == "number") then
						button.config.macroIcon = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK"
					end
					button.config.fix112711 = true
				end

			end

			data.buttons = nil
		end

		for k,v in pairs(data) do
			if (SD[k]) then
				SD[k] = v
			end
		end
	end
end

function M.UpdateElements()

	for k,v in pairs(M.Buttons) do

		M.ApplyBindings(v[1])

		M.SetButtonType(v[1], nil, true)

	end

	for k,v in pairs(M.ButtonBars) do

		v.stateschanged = true

		v.buttonCountChanged = true

		v.updateBar(v, true, true, true, true, true)
	end

	for k,v in pairs(M.ButtonBars) do

		v.updateBarTarget(v)

		v.updateBarLink(v)

		v.updateBarHidden(v, nil, true)
	end

	for k,v in pairs(M.Buttons) do

		M.UpdateAnchor(v[1], nil, nil, true)

	end
end

function M.SaveCurrentState()

	if (load) then

		local spec = GetActiveTalentGroup()

		if (SD.bars) then
			ClearTable(SD.bars)
		else
			SD.bars = {}
		end

		for k,v in pairs(M.ButtonBars) do
			SD.bars[k] = { v.config }
		end

		if (not SD.buttons) then
			SD.buttons = {}
		end

		for k,v in pairs(M.Buttons) do

			if (not SD.buttons[k]) then
				SD.buttons[k] = {}
			end

			if (v[1].dualSpec) then
				SD.buttons[k][spec] = CopyTable(v[1].config)
			else
				SD.buttons[k][1] = CopyTable(v[1].config)

				local index = 2

				while (SD.buttons[k][index]) do
					SD.buttons[k][index] = nil
					index = index + 1
				end
			end

			SD.buttons[k][0] = v[1].dualSpec
		end
	end

	return SD, "bars", "buttons"
end

function M.ButtonStorage_BuildOptions(self)

	local dock, lock, lastDock, count, yOffset

	if (IsAddOnLoaded("MacaroonXtras")) then
		count = 10; yOffset = -4
		self.ButtonBorder:SetPoint("BOTTOMLEFT", -10, 95)
		self.OptionsBorder:SetPoint("BOTTOMLEFT", -10, 55)
	else
		count = 12; yOffset = -3
		self.ButtonBorder:SetPoint("BOTTOMLEFT", -10, 48)
		self.OptionsBorder:SetPoint("BOTTOMLEFT", -10, 10)
	end

	self.text = self:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	self.text:SetPoint("TOPLEFT", self, "TOPLEFT", 20, -11)
	self.text:SetPoint("TOPRIGHT", self, "TOPRIGHT", -20, -11)
	self.text:SetJustifyH("LEFT")

	self.lock = self:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	self.lock:SetPoint("TOPRIGHT", self, "TOPRIGHT", -20, -11)
	self.lock:SetJustifyH("RIGHT")
	self.lock:SetText(M.Strings.LOCKROW)

	for i=1,count do

		dock = CreateFrame("Frame", self:GetName().."Dock"..i, self, "MacaroonDockTemplate")
		lock = CreateFrame("CheckButton", self:GetName().."Lock"..i, self, "MacaroonOptionCBTemplate")

		lock:SetPoint("LEFT", dock, "RIGHT", 30, 0)
		lock:SetWidth(22)
		lock:SetHeight(22)
		lock:SetID(900+i)
		lock.dock = dock

		dockIndex[i] = { dock, lock, "", 0 }

		dock:SetID(i)
		dock:SetFrameLevel(self:GetParent():GetFrameLevel()+2)
		dock:SetWidth(435)
		dock:SetHeight(38)
		dock:SetScale(0.68)
		dock:Show()

		dock.config = M.GetBarDefaults()
		dock.config.padH = 1
		dock.config.barStrata = "TOOLTIP"
		dock.config.buttonStrata = "DIALOG"
		dock.config.showGrid = true
		dock.config.stored = true
		dock.handler = dock
		dock.homestate = {}
		dock.btnType = "MacaroonButton"
		dock.hasAction = "Interface\\Buttons\\UI-Quickslot2"
		dock.noAction = "Interface\\Buttons\\UI-Quickslot"
		dock.locked = false
		dock.homestate.buttonCount = 0

		dock.updateBar = function() end

		if (not lastDock) then
			dock:SetPoint("TOPLEFT", self.ButtonBorder, "TOPLEFT", 50, -16)
			lastDock = dock
		else
			dock:SetPoint("TOPLEFT", lastDock, "BOTTOMLEFT", 0, yOffset)
			lastDock = dock
		end

		lock:SetChecked(SD.checkButtons[lock:GetID()])
		M.CheckbuttonOptions[lock:GetID()] = function(self) dockLock(self) end

		dockLock(lock)
	end

end

function M.UpdateButtonStorage()

	if (not MacaroonButtonStorage:IsVisible()) then return end

	local num, count, maxcount = 0, 0, 0

	for k,v in pairs(dockIndex) do
		dockIndex[k][3] = ""; dockIndex[k][4] = 0
	end

	num = findNextDock(num); if (num <=0) then num = 1 end

	for index, button in pairs(M.Buttons) do

		locked = button[1].config.locked

		if (locked and dockIndex[locked] and button[2] == 1) then

			count = count + 1

			button[1]:Show()

			dockIndex[locked][3] = dockIndex[locked][3]..button[1].id..";"
			dockIndex[locked][4] = dockIndex[locked][4] + 1

		elseif (dockIndex[num] and not dockIndex[num][1].locked and button[2] == 1) then

			count = count + 1

			button[1]:Show()

			dockIndex[num][3] = dockIndex[num][3]..button[1].id..";"
			dockIndex[num][4] = dockIndex[num][4] + 1

			if (dockIndex[num][4] >= 12) then
				num = findNextDock(num)
			end

		elseif (button[2] == 1) then

			button[1]:Hide(); count = count + 1
		end
	end

	for k,v in ipairs(dockIndex) do

		if (v[1].locked) then
			maxcount = maxcount + v[4]
		else
			maxcount = maxcount + 12
		end

		v[1].config.buttonList.homestate = dockIndex[k][3]
		v[1].homestate.buttonCount = dockIndex[k][4]

		if (k <= num or v[1].locked) then
			if (v[4] > 0 or v[1].locked) then
				dockIndex[k][2]:Show()
			else
				dockIndex[k][2]:Hide()
			end
		else
			dockIndex[k][2]:Hide()
		end

		updateShape(v[1], true)
	end

	local overflow = count - maxcount

	if (overflow > 0) then
		MacaroonButtonStorage.text:SetText(M.Strings.STORED_BUTTONS.." |cffffffff"..count.."|r      |cfff00000"..M.Strings.OVERFLOW.."|r |cffffffff"..overflow.."|r")
	else
		MacaroonButtonStorage.text:SetText(M.Strings.STORED_BUTTONS.." |cffffffff"..count.."|r")
	end

end

function M.BarsSetSaved()

	SD = MacaroonSavedState

	return SD
end

function M.ReleaseAnchor(bar, state)

	local anchor = bar[state].anchor

	if (anchor) then
		anchorIndex[anchor:GetID()][2] = 1
		anchor:ClearAllPoints()
		bar[state].anchor = nil
	end
end

M.UpdateShape = updateShape
M.UpdateBarSize = updateBarSize

local function controlOnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ... == "Macaroon") then

		ManagedStates = M.ManagedStates

		M.BarsSetSaved()

		M.ModuleIndex = M.ModuleIndex + 1

		M.CreateBarTypes.bar = {
			[1] = "Bars",
			[2] = SD,
			[3] = M.ButtonBars,
			[4] = M.Buttons,
			[5] = "MacaroonButton",
			[6] = M.AddNewButton,
			[7] = M.SetNewButton,
			[8] = M.GetButtonDefaults,
			[9] = nil, --modified bar defaults
			[10] = "Button",
			[11] = M.ModuleIndex.."Standard bar",
		}

		M.StatesToSave.bars = M.SaveCurrentState
		M.SavedDataLoad.bars = M.LoadSavedData
		M.SavedDataUpdate.bars = M.UpdateElements
		M.SetSavedVars.bars = M.BarsSetSaved

		M.LoadSavedData(SD)

	elseif (event == "PLAYER_LOGIN") then

	elseif (event == "PLAYER_ENTERING_WORLD" and not pew) then

		pew = true; self.elapsed = 0

	end
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", controlOnEvent)
frame:SetScript("OnUpdate", controlOnUpdate)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame.elapsed = 0
