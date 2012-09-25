--Macaroon, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

--Text substitutions based on Cogwheel's addon MacroTalk
--/flyout command based on Gello's addon "Select"

local M = Macaroon

local	SKIN

if (LibStub) then
	SKIN = LibStub("Masque", true)
end

local match = string.match
local find = string.find
local gsub = string.gsub
local lower = string.lower
local ceil = math.ceil
local strlen = strlen
local tinsert = tinsert
local pairs = _G.pairs

local IsSecureCmd = _G.IsSecureCmd
local UnitClass = _G.UnitClass
local UnitName = _G.UnitName
local UnitLevel = _G.UnitLevel
local UnitSex = _G.UnitSex
local UnitIsPlayer = _G.UnitIsPlayer
local UnitRace = _G.UnitRace
local UnitExists = _G.UnitExists
local UnitCreatureType = _G.UnitCreatureType
local UnitHealth = _G.UnitHealth
local UnitIsDead = _G.UnitIsDead
local UnitMana = _G.UnitMana
local GetRaidTargetIndex = _G.GetRaidTargetIndex
local GetTime = _G.GetTime
local GetContainerNumSlots = _G.GetContainerNumSlots
local GetContainerItemLink = _G.GetContainerItemLink
local GetSpellBookItemName = _G.GetSpellBookItemName
local GetItemInfo = _G.GetItemInfo

local CopyTable = M.CopyTable
local ClearTable = M.ClearTable
local SpellIndex = M.SpellIndex
local CompIndex = M.CompIndex
local GetChildrenAndRegions = M.GetChildrenAndRegions

local tooltipScan, tooltipStrings = MacaroonTooltipScan, {}

local BOOKTYPE_SPELL = BOOKTYPE_SPELL
local BOOKTYPE_PET = BOOKTYPE_PET

local SD, control, pew, verbose, rescan, player, level, pet, ItemCache
local doafter_data, doafterLog, in_data, repeat_data, repeats = {}, {}, {}, {}
local itemTooltips, itemLinks, spellTooltips, companionTooltips = {}, {}, {}, {}
local anchorButtonIndex = {}
local flyoutButtons = {}
local needUpdate = {}

local doafterDetails = {
	damage = { "#", "#overkill", "school", "#resisted", "#blocked", "#absorbed", "critical", "glancing", "crushing" },
	missed = { "#", "#" },
	heal = { "#", "#overheal", "critical" },
	school = { [1]="physical",[2]="holy",[4]="fire",[8]="nature",[16]="frost",[20]="frostfire",[24]="froststorm",[32]="shadow",[40]="shadowstorm",[64]="arcane" },
}

local pointOffset = {
	TOP = {0, 5},
	BOTTOM = {0, -5},
	LEFT = {-5, 0},
	RIGHT = {5, 0},
	CENTER = {0, 0},
}

local units = {
	p = "player",
	t = "target",
	f = "focus",
	tt = "targettarget",
	p1 = "party1",
	p2 = "party2",
	p3 = "party3",
	p4 = "party4",
	pt = "pet",
	mo = "mouseover",
}

local substitutions = {

	c = function(unit)
		local class, aux = UnitClass(unit)
		if (aux and class == UnitName(unit)) then
			return aux:lower()
		elseif (class) then
			return class:lower()
		else
			return "unknown class"
		end
	    end,

	n = function(unit)
		local name = UnitName(unit)

		if (name) then
			return name
		else
			return "unknown"
		end
	    end,

	l = function(unit)
		local level = UnitLevel(unit)

		if (level and level > 0) then
			return tostring(level)
		else
			return "0"
		end
	    end,

	g = function(unit)
		local gender = UnitSex(unit)

		if (UnitExists(unit)) then
			if (gender and gender == 2) then
				return "male"
			elseif (gender and gender == 3) then
				return "female"
			else
				return "unknown"
			end
		else
			return "unknown"
		end
	    end,

	r = function(unit)
		if (UnitIsPlayer(unit)) then
			return UnitRace(unit):lower()
		elseif (UnitExists(unit)) then
			return UnitCreatureType(unit):lower()
		else
			return "unknown"
		end
	    end,

	h = function(unit)
		local health = UnitHealth(unit)

		if (health and health > 0) then
			return tostring(health)
		elseif (UnitIsDead(unit)) then
			return "dead"
		else
			return "0"
		end
	    end,

	m = function(unit)
		local mana = UnitMana(unit)

		if (mana and mana > 0) then
			return tostring(mana)
		else
			return "0"
		end
	    end,

	s = function(unit)
		local index = GetRaidTargetIndex(unit)
		if (index) then
			return "{"..(_G["RAID_TARGET_"..index]):lower().."}"
		else
			return "<no symbol>"
		end
	    end,

	da = function(index)
		local event, data = doafterLog.event
		if (doafterDetails[event] and doafterDetails[event][index]) then
			data = doafterDetails[event][index]
			if (doafterLog[index] and tonumber(doafterLog[index])) then
				data = gsub(data, "#", doafterLog[index].." ")
				if (doafterDetails[data]) then
					data = doafterDetails[data][doafterLog[index]]
				end
			else
				data = doafterLog[index]
			end
		end
		if (data) then
			return data
		else
			return doafterLog[index] or ""
		end
	    end,
}

local function getSubs(origWord)

	local postPunc = origWord:match("%p+$")

	if (postPunc) then
		postPunc = gsub(postPunc, "%+$", "")
	end

	verbose = match(origWord, "+%p*$")

	local word = gsub(origWord, "%p+$", "")
	local info, unit, cmd, doafter

	for i=1,select("#",(":"):split(word:lower())) do

		cmd = select(i, (":"):split(word:lower()))

		if (find(cmd, "%%")) then

			unit = match(cmd, "%a+"); unit = units[unit]

			if (not unit) then
				doafter = match(cmd, "da")
				if (not doafter) then
					unit = units.t; cmd = match(cmd, "%a+")
				end
			end
		end

		if (doafter and cmd and substitutions[doafter]) then

			cmd = tonumber(cmd)

			if (cmd) then

				local data = substitutions[doafter](cmd)

				if (info and data and data ~= "") then
					info = info.." "..data
				elseif (data and data ~= "") then
					info = data
				end
			end

		elseif (unit and UnitExists(unit) and cmd and substitutions[cmd]) then

			local data = substitutions[cmd](unit)

			if (info and data and data ~= "") then
				info = info.." "..data
			elseif (data and data ~= "") then
				info = data
			end

		else
			info = origWord
		end
	end

	if (doafter and (not info or info == "")) then
		if (verbose) then
			info = "<no data>"
		else
			info = ""
		end
	end

	if (postPunc and info) then
		info = info..postPunc
	elseif (postPunc) then
		info = postPunc
	end

	if (not info or #info < 1) then
		return origWord
	else
		return info
	end
end

local function chatEdit_ParseText(editBox, send)

	-- disabled for now
	if (true) then return end

	local text = editBox:GetText()
	local command = text:match("^(/%S+)")

	if (command and IsSecureCmd(command)) then
		return
	end

	text = text:gsub("%%%S+%s", function(word) word = getSubs(word) if (word) then return word.." " end end)
	text = text:gsub("%s+", " ")

	editBox:SetText(text)

end

local function command_doafter(opt)

	local options = gsub(opt, "%s*,%s*", ","); doafter_data[options] = true

end

local function command_in(options)

	options = gsub(options, "%s*,%s*", ",")

	local index = MacaroonControl.elapsed

	in_data[index] = { (":"):split(options) }

	in_data[index][1] = tonumber(in_data[index][1])

	if (not in_data[index][1]) then
		in_data[index] = nil
	end

end

local function command_repeat(options)

	options = gsub(options, "%s*,%s*", ",")

	local index = MacaroonControl.elapsed

	repeat_data[index] = { (":"):split(options) }

	repeat_data[index][1] = tonumber(repeat_data[index][1])
	repeat_data[index][2] = tonumber(repeat_data[index][2])
	repeat_data[index][4] = 0

	if (not repeat_data[index][1]) then
		repeat_data[index] = nil
	end

	repeats = true
end

local function slashHandler(msg)
	repeats = nil
end

local function updateDockData(handler)

	local dock, bar = handler.bar, handler.bar.parent.bar

	if (dock and bar) then
		dock.config.tooltips = bar.config.tooltips
		dock.config.tooltipsEnhanced = bar.config.tooltipsEnhanced
		dock.config.tooltipsCombat = bar.config.tooltipsCombat
	end
end

local function createFlyoutDock(index, parent)

	if (_G["MacaroonFlyoutDock"..index]) then
		return _G["MacaroonFlyoutDock"..index]
	end

	local dock = CreateFrame("Button", "MacaroonFlyoutDock"..index, UIParent, "MacaroonBarTemplate")

	dock:SetID(index)
	dock:SetWidth(36)
	dock:SetHeight(36)
	dock:SetPoint("CENTER")
	dock:SetScript("OnClick", nil)
	dock:SetScript("OnKeyDown", nil)
	dock:SetScript("OnKeyUp", nil)
	dock:SetScript("OnDragStart", nil)
	dock:SetScript("OnDragStop", nil)
	dock:SetScript("OnEnter", nil)
	dock:SetScript("OnLeave", nil)
	dock:SetScript("OnUpdate", nil)
	dock:SetScript("OnMouseWheel", nil)
	dock:SetScript("OnShow", nil)
	dock:SetScript("OnHide", nil)

	dock.config = M.GetBarDefaults()
	dock.config.name = "Flyout Bar for Button "..index

	dock.handler = CreateFrame("Frame", "MacaroonFlyoutHandler"..index, UIParent, "SecureHandlerStateTemplate")
	dock.handler:SetAttribute("state-current", "homestate")
	dock.handler:SetAttribute("state-last", "homestate")
	dock.handler:SetAttribute("showstates", "homestate")
	dock.handler:SetScript("OnShow", updateDockData)
	dock.handler.bar = dock
	dock.handler:SetAllPoints(dock)
	dock.handler.elapsed = 0

	dock.homestate = {}
	dock.btnType = "MacaroonFlyoutButton"
	dock.btnTable = parent.flyoutButtons
	dock.hasAction = "Interface\\Buttons\\UI-Quickslot2"
	dock.noAction = "Interface\\Buttons\\UI-Quickslot"
	dock.homestate.buttonCount = 0
	dock.updateBar = function() end
	dock.parent = parent

	dock:Hide()

	return dock
end

local function updateData(button, bar, state)

	button.bar = bar
	button.alpha = bar.config.alpha

	button.config.showstates = state
	button:SetAttribute("showstates", state)

	if (button.__MSQ_NormalTexture) then

		button.hasAction = false
		button.noAction = false

		if (button.__MSQ_Shape) then
			button.shape = button.__MSQ_Shape:lower()
		else
			button.shape = "square"
		end

	else
		button.hasAction = "Interface\\Buttons\\UI-Quickslot2"
		button.noAction = "Interface\\Buttons\\UI-Quickslot"
		button.shape = "square"
	end

	button.shine.shape = button.shape

	button.config.bar = bar:GetID()
	button.config.stored = false

	button:SetFrameStrata("TOOLTIP")

	button:RegisterForClicks("AnyUp")

	button:SetFrameLevel(4)
	button.iconframe:SetFrameLevel(2)
	button.iconframecooldown:SetFrameLevel(3)
	button.iconframeaurawatch:SetFrameLevel(3)

	if (button.parent) then
		button.rangecolor = button.parent.rangecolor
	else
		button.rangecolor = { 1, 0, 0, 1}
	end

	button.updateTexture = true

end

local function buttonDefaults(index, button)

	button.config = {

		bar = 0,
		barPos = 0,
		hotKeys = ":",
		hotKeyText = ":",
		hotKeyLock = false,
		locked = false,

		type = "macro",

		macro = "",
		macroIcon = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK",
		macroName = "",
		macroNote = "",
		macroUseNote = false,
		macroAuto = false,
		macroRand = false,

		scale = 1,
		alpha = 1,
		XOffset = 0,
		YOffset = 0,
	}

end

local function button_PostClick(self,button,down)

	self.macroBtn.config.macro = self:GetAttribute("newMacro")
	self.macroBtn.config.macroIcon = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK"
	self.macroBtn.macroparse = self:GetAttribute("newMacro")
	self.macroBtn.update(self.macroBtn)

	M.Save()
end

local function resetButton(button)

	flyoutButtons[button.id][2] = 0

	button.config.bar = 0
	button.config.barPos = 0
	button.config.hotKeys = ":"
	button.config.hotKeyText = ":"
	button.config.hotKeyLock = false
	button.config.locked = false
	button.config.type = "macro"
	button.config.macro = ""
	button.config.macroIcon = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK"
	button.config.macroName = ""
	button.config.macroNote = ""
	button.config.macroUseNote = false
	button.config.macroAuto = false
	button.config.macroRand = false
	button.config.scale = 1
	button.config.XOffset = 0
	button.config.YOffset = 0

	button.macrospell=nil
	button.macroitem=nil
	button.macroshow=nil

	button.macroBtn = nil
	button.opt = nil

	button.parent = nil
	button.dock = nil

	button:SetAttribute("macroShow", nil)
	button:SetAttribute("*macrotext1", nil)
	button:SetAttribute("anchorMacro", nil)
	button:SetAttribute("options", nil)
	button:SetAttribute("postCmds", nil)

	button:ClearAllPoints()
	button:SetPoint("BOTTOMLEFT", 50, -50)
	button:SetParent("UIParent")
	button:Hide()

end

local function getFlyoutButton(parent, dock)

	local index, button = 1

	for k,v in pairs(parent.flyoutButtons) do
		if (v[2] == 0) then
			flyoutButtons[k][2] = 1
			v[2] = 1
			return v[1]
		end
	end

	for k,v in pairs(flyoutButtons) do
		if (v[2] == 0) then
			parent.flyoutButtons[k] = { v[1], 1 }
			v[2] = 1
			return v[1]
		end
		if (k >= index) then
			index = k + 1
		end
	end

	if (_G["MacaroonFlyoutButton"..index]) then
		button = _G["MacaroonFlyoutButton"..index]
	else
		button = CreateFrame("CheckButton", "MacaroonFlyoutButton"..index, UIParent, "MacaroonActionButtonTemplate")
	end

	button:SetID(0)
	button.id = index
	button.parent = parent
	button.dock = dock

	buttonDefaults(index, button)

	objects = GetChildrenAndRegions(button)

	for k,v in pairs(objects) do
		local name = gsub(v, button:GetName(), "")
		button[name:lower()] = _G[v]
	end

	button.bindframe:SetID(index)
	button.bindframe.bindType = "button"

	button.update = function() end
	button.updateData = updateData

	SecureHandler_OnLoad(button)

	parent.flyoutButtons[index] = { button, 1 }
	flyoutButtons[index] = { button, 1 }

	button:SetAttribute("type1", "macro")
	button:SetAttribute("*macrotext1", "")
	button:SetScript("PostClick", button_PostClick)
	button:SetScript("OnShow", parent:GetScript("OnShow"))
	button:SetScript("OnHide", parent:GetScript("OnHide"))
	button:SetScript("OnEvent", parent:GetScript("OnEvent"))
	button:SetScript("OnUpdate", parent:GetScript("OnUpdate"))
	button:SetScript("OnDragStop", nil)
	button:SetScript("OnDragStart", nil)
	button:SetScript("OnReceiveDrag", nil)
	button:WrapScript(button, "OnClick", [[

			local button = self:GetParent():GetParent()

			self:SetAttribute("newMacro", self:GetAttribute("anchorMacro").."\n/stopmacro [nobtn:2]\n/flyout "..self:GetAttribute("options")..self:GetAttribute("postCmds"))
			button:SetAttribute("macroUpdate", true)
			button:SetAttribute("*macrotext*", self:GetAttribute("newMacro"))
			button:SetAttribute("macroShow", self:GetAttribute("macroShow"))

			self:GetParent():Hide()
	]])

	M.SetButtonUpdate(button, "macro")

	updateData(button, dock, "homestate")

	return button
end

local function getItemFromLink(results, link, cmds)

	local item = GetItemInfo(link)
	local keys, found, mandatory, optional, excluded = { (","):split(cmds[2]:lower()) }, 0, 0, 0

	if (item) then

		if (not ItemCache[item]) then

			local _, itemID = strsplit(":", link)

			if (itemID) then
				ItemCache[item] = itemID
			end
		end

		for _,ckey in pairs(keys) do

			local cmd, key = match(ckey, "(%p*)(%P+)")

			if (cmd ~= "#") then

				if (not cmd or #cmd < 1) then
					mandatory = mandatory + 1
				elseif (cmd == "~") then
					optional = 1
				end

				if (key and item:lower():find(key)) then

   					if (cmd == "!") then
						excluded = true
   					else
   						found = found + 1
   					end
				end
			end
		end

		if (found >= (mandatory+optional) and not excluded) then
			results["i;"..item] = cmds
		end
	end
end

local function getItemFromTooltip(results, link, cmds)

	local name = GetItemInfo(link)
	local keys, found, mandatory, excluded = { (","):split(cmds[2]:lower()) }, 0, 0

	if (name and not ItemCache[name]) then

		local _, itemID = strsplit(":", link)

		if (itemID) then
			ItemCache[name] = itemID
		end
	end

	if (name and itemTooltips[name:lower()]) then

		local keys, found, mandatory, optional, excluded = { (","):split(cmds[2]:lower()) }, 0, 0, 0

		for _, ckey in pairs(keys) do

			local cmd, key = match(ckey, "(%p*)(%P+)")

			if (cmd ~= "#") then

				if (not cmd or #cmd < 1) then
					mandatory = mandatory + 1
				elseif (cmd == "~") then
					optional = 1
				end

				if (key and find(itemTooltips[name:lower()], "[%s%p]+"..key.."[%s%p]+")) then

   					if (cmd == "!") then
						excluded = true
   					else
   						found = found + 1
   					end
				end
			end
		end

		if (found >= (mandatory+optional) and not excluded) then
			results["i;"..name] = cmds
		end
	end
end

local function getItemData(cmds, results, tooltip)

	local link

	for i=0,4 do

		for j=1,GetContainerNumSlots(i) do

			link = GetContainerItemLink(i,j)

			if (link) then

				if (tooltip and tooltip == "+") then
					getItemFromTooltip(results, link, cmds)
				else
					getItemFromLink(results, link, cmds)
				end
			end
		end
	end

	for i=0,19 do

		link = GetInventoryItemLink("player",i)

		if (link) then

			if (tooltip and tooltip == "+") then
				getItemFromTooltip(results, link, cmds)
			else
				getItemFromLink(results, link, cmds)
			end
		end
	end

	return results
end

local function getSpellFromName(results, spell, cmds)

	local keys, found, mandatory, optional, excluded = { (","):split(cmds[2]:lower()) }, 0, 0, 0

	for _, ckey in pairs(keys) do

		local cmd, key = (ckey):match("(%p*)(%P+)")

		if (not cmd or #cmd < 1) then
			mandatory = mandatory + 1
		elseif (cmd == "~") then
			optional = 1
		end

   		if (key and spell:lower():find(key)) then

   			if (cmd == "!") then
				excluded = true
   			else
   				found = found + 1
   			end
   		end
   	end

	if (found >= (mandatory+optional) and not excluded) then
		results["s;"..spell] = cmds
	end
end

local function getSpellFromTooltip(results, spell, cmds)

	if (spellTooltips[spell:lower()]) then

		local keys, found, mandatory, optional, excluded  = { (","):split(cmds[2]:lower()) }, 0, 0, 0

		for _, ckey in pairs(keys) do

			local cmd, key = (ckey):match("(%p*)(%P+)")

			if (not cmd or #cmd < 1) then
				mandatory = mandatory + 1
			elseif (cmd == "~") then
				optional = 1
			end

			if (key and (spellTooltips[spell:lower()]):find(key)) then

   				if (cmd == "!") then
					excluded = true
   				else
   					found = found + 1
   				end
			end
		end

		if (found >= (mandatory+optional) and not excluded) then
			results["s;"..spell] = cmds
		end
	end
end

-- 1=index, 2=BOOKTYPE_SPELL, 3=spell, 4=subName, 5=spellID, 6=spellType, 7=spellLvl, 8=isPassive

local function getSpellData(cmds, results, tooltip)

	local i, spell = 1

	for k,v in pairs(M.SpellIndex) do

		if (type(k) == "string" and not k:find("%(") and v[6] ~= "FLYOUT" and v[7] <= level and not v[8]) then

			if (v[4] and #v[4] > 0) then
				spell = v[3].."("..v[4]..")"
			else
				spell = v[3]
			end

			if (tooltip and tooltip == "+") then
				getSpellFromTooltip(results, spell, cmds)
			else
				getSpellFromName(results, spell, cmds)
			end
		end
	end

	return results
end

local function getCompanionFromName(results, name, cmds, keys, mode)

	local keys, found, mandatory, optional, excluded = { (","):split(cmds[2]:lower()) }, 0, 0, 0

	for _, ckey in pairs(keys) do

		local cmd, key = (ckey):match("(%p*)(%P+)")

		if (cmd ~= "#") then

			if (not cmd or #cmd < 1) then
				mandatory = mandatory + 1
			elseif (cmd == "~") then
				optional = 1
			end

   			if (key and name:lower():find(key)) then

   				if (cmd == "!") then
					excluded = true
   				else
   					found = found + 1
   				end
   			end
   		end
   	end

	if (found >= (mandatory+optional) and not excluded) then
		results["c;"..name] = cmds
	end
end

local function getCompanionFromTooltip(results, name, cmds, keys, mode)

	if (companionTooltips[name:lower()]) then

		local keys, found, mandatory, optional, excluded = { (","):split(cmds[2]:lower()) }, 0, 0, 0

		for _, ckey in pairs(keys) do

			local cmd, key = match(ckey, "(%p*)(%P+)")

			if (cmd ~= "#") then

				if (not cmd or #cmd < 1) then
					mandatory = mandatory + 1
				elseif (cmd == "~") then
					optional = 1
				end

				if (key and find(companionTooltips[name:lower()], "[%s%p]+"..key.."[%s%p]+")) then

   					if (cmd == "!") then
						excluded = true
   					else
   						found = found + 1
   					end
				end
			end
		end

		if (found >= (mandatory+optional) and not excluded) then
			results["c;"..name] = cmds
		end
	end
end

local function getCompanionData(cmds, results, tooltip)

	local keys, mode, _, name, spellID = { (","):split(cmds[2]:lower()) }

	for _,key in pairs(keys) do

		if (("#CRITTER"):find(key:upper()) or ("#MOUNT"):find(key:upper())) then
			mode = key:gsub("#",""):upper()
		end
	end

	if (mode) then

		for i=1,GetNumCompanions(mode) do

			_, _, spellID = GetCompanionInfo(mode, i)

			if (spellID) then

				name = GetSpellInfo(spellID)

				if (name) then

					if (tooltip and tooltip == "+") then
						getCompanionFromTooltip(results, name, cmds, keys)
					else
						getCompanionFromName(results, name, cmds, keys)
					end
				end
			end
		end
	else
		for i=1,GetNumCompanions("CRITTER") do

			_, _, spellID = GetCompanionInfo("CRITTER", i)

			if (spellID) then

				name = GetSpellInfo(spellID)

				if (name) then

					if (tooltip and tooltip == "+") then
						getCompanionFromTooltip(results, name, cmds, keys)
					else
						getCompanionFromName(results, name, cmds, keys)
					end
				end
			end
		end

		for i=1,GetNumCompanions("MOUNT") do

			_, _, spellID = GetCompanionInfo("MOUNT", i)

			if (spellID) then

				name = GetSpellInfo(spellID)

				if (name) then

					if (tooltip and tooltip == "+") then
						getCompanionFromTooltip(results, name, cmds, keys)
					else
						getCompanionFromName(results, name, cmds, keys)
					end
				end
			end
		end
	end

	return results
end

local function getFlyoutData(cmds, results)

	local visible, spellID, spell, petIndex, petName
	local _, _, numSlots, isKnown = GetFlyoutInfo(cmds[2])

	for i=1, numSlots do

		visible = true

		spellID, isKnown = GetFlyoutSlotInfo(cmds[2], i)
		petIndex, petName = GetCallPetSpellInfo(spellID)

		if (petIndex and (not petName or petName == "")) then
			visible = false
		end

		if (isKnown and visible) then

			spell, subName = GetSpellInfo(spellID)

			if (subName and #subName > 0) then
				spell = spell.."("..subName..")"
			end

			results["b;"..spell] = cmds
		end
	end

	return results
end

local function getDataList(button, options)

	local cmds, results = { (":"):split(options) }, {}

	cmds[1] = cmds[1]:gsub("%s*,%s*", ",")
	cmds[2] = cmds[2]:gsub("%s*,%s*", ",")

	local types = { (","):split(cmds[1]:lower()) }

	button.flyoutType = cmds[1]

	for _, getTypes in pairs(types) do

		local getType, tooltip = (getTypes):match("(%P+)(%p*)")

		if (getType:find("^b")) then

			return getFlyoutData(cmds, results)

		elseif (getType:find("^i")) then

			getItemData(cmds, results, tooltip)

		elseif (getType:find("^s")) then

			getSpellData(cmds, results, tooltip)

		elseif (getType:find("^c")) then

			getCompanionData(cmds, results, tooltip)

		end
	end

	return results
end

local function command_flyout(options)

	if (InCombatLockdown()) then
		return
	end

	local button = M.ClickedButton

	if (button) then
		if (not button.options or button.options ~= options) then
			M.UpdateFlyout(button, options)
		end
	end
end

local function initializeFlyoutButtons()

	local options

	for k,v in pairs(M.Buttons) do

		options = match(v[1].config.macro, "/flyout%s(%C+)")

		if (options) then
			M.UpdateFlyout(v[1], options, true)
		end
	end
end

local function updateFlyoutButtons(self, elapsed)

	self.button = tremove(needUpdate)

	if (self.button) then
		self.button.UpdateFlyout(self.button, self.button.options, true)
	else
		self:Hide()
	end
end

local flyoutButtonUpdater = CreateFrame("Frame", nil, UIParent)
	flyoutButtonUpdater:SetScript("OnUpdate", updateFlyoutButtons)
	flyoutButtonUpdater:Hide()

local function linkScanOnUpdate(self, elapsed)

	self.link = itemLinks[self.index]

	if (self.link) then

		local name = GetItemInfo(self.link)

		if (name) then

			local tooltip, text = " "

			tooltipScan:SetOwner(control,"ANCHOR_NONE")
			tooltipScan:SetHyperlink(self.link)

			for i,string in ipairs(tooltipStrings) do
				text = string:GetText()
				if (text) then
					tooltip = tooltip..text..","
				end
			end

			itemTooltips[name:lower()] = tooltip:lower()
		end
	end

	self.index = next(itemLinks, self.index)

	if not (self.index) then
		self:Hide(); flyoutButtonUpdater:Show()
	end
end

local itemScanner = CreateFrame("Frame", nil, UIParent)
	itemScanner:SetScript("OnUpdate", linkScanOnUpdate)
	itemScanner:Hide()

local function updateItemTooltips()

	ClearTable(itemTooltips); ClearTable(itemLinks)

	local link, name, tooltip

	for i=0,4 do

		for j=1,GetContainerNumSlots(i) do

			link = GetContainerItemLink(i,j)

			if (link) then
				tinsert(itemLinks, link)
			end
		end
	end

	for i=0,19 do

		link = GetInventoryItemLink("player",i)

		if (link) then
			tinsert(itemLinks, link)
		end
	end

	itemScanner.index = next(itemLinks)

	itemScanner:Show()
end

local function updateSpellTooltips()

	ClearTable(spellTooltips)

	tooltipScan:SetOwner(control,"ANCHOR_NONE")

	local i, tooltip, spell, spellType, text = 1, ""

	repeat
		spell = GetSpellBookItemName(i, BOOKTYPE_SPELL); spellType = GetSpellBookItemInfo(i, BOOKTYPE_SPELL)

		if (spell and spellType ~= "FLYOUT") then
			tooltip = " "
			tooltipScan:SetSpellBookItem(i, BOOKTYPE_SPELL)
			for i,string in ipairs(tooltipStrings) do
				text = string:GetText()
				if (text) then
					tooltip = tooltip..text..","
				end
			end
			spellTooltips[spell:lower()] = tooltip:lower()
   		end

   		i = i + 1

   	until (not spell)

	i = 1

	repeat
		spell = GetSpellBookItemName(i, BOOKTYPE_PET); spellType = GetSpellBookItemInfo(i, BOOKTYPE_PET)

		if (spell and spellType ~= "FLYOUT") then

			tooltip = " "
			tooltipScan:SetSpellBookItem(i, BOOKTYPE_PET)
			for i,string in ipairs(tooltipStrings) do
				text = string:GetText()
				if (text) then
					tooltip = tooltip..text..","
				end
			end
			spellTooltips[spell:lower()] = tooltip:lower()
   		end

   		i = i + 1

   	until (not spell)

end

local function updateCompanionTooltips()

	ClearTable(companionTooltips)

	tooltipScan:SetOwner(control,"ANCHOR_NONE")

	local _, name, spellID, tooltip, text

	for i=1,GetNumCompanions("CRITTER") do

		_, name, spellID = GetCompanionInfo("CRITTER", i)

		if (name) then

			tooltip = " "
			tooltipScan:SetHyperlink("spell:"..spellID)
			for i,string in ipairs(tooltipStrings) do
				text = string:GetText()
				if (text) then
					tooltip = tooltip..text..","
				end
			end
			companionTooltips[name:lower()] = tooltip:lower()
		end
	end

	for i=1,GetNumCompanions("MOUNT") do

		_, name, spellID = GetCompanionInfo("MOUNT", i)

		if (name) then

			tooltip = " "
			tooltipScan:SetHyperlink("spell:"..spellID)
			for i,string in ipairs(tooltipStrings) do
				text = string:GetText()
				if (text) then
					tooltip = tooltip..text..","
				end
			end

			--fixes for inconsistancy in creature name vs actual spell to summon
			name = gsub(name, "Drake Mount", "Drake")
			name = gsub(name, "Thalassian Warhorse", "Summon Warhorse")

			companionTooltips[name:lower()] = tooltip:lower()
		end
	end
end

local editbox = CreateFrame("Editbox", "MacaroonExtensionsEditbox", UIParent); editbox:Hide()

local function setAnchor(button, mode)

	if (mode and mode == "mouse") then
		button.config.mouseAnchor = true
		button.config.clickAnchor = false
	else
		button.config.mouseAnchor = false
		button.config.clickAnchor = true
	end
	button.config.anchorDelay = 0.5

	M.UpdateAnchor(button, button.flyoutDock, true)
end

local function keySort(list)

	local array, i = {}, 0

	for n in pairs(list) do
		tinsert(array, n)
	end

	table.sort(array)

	local sorter = function()

		i = i + 1

		if (array[i] == nil) then
			return nil
		else
			return array[i], list[array[i]]
		end
	end

	return sorter
end

function M.UpdateFlyout(button, options, init)

	if (InCombatLockdown()) then return end

	local mode

	if (not options) then

		button.arrowPoint = nil
		button.arrowX = nil
		button.arrowY = nil
		button.flyoutArrow = nil

		button.flyouttop:Hide()
		button.flyoutbottom:Hide()
		button.flyoutleft:Hide()
		button.flyoutright:Hide()

		if (button.flyoutDock) then
			button.flyoutDock.handler:Hide()
			M.UpdateAnchor(button, nil, true, nil, nil, true)
			SD.bfskin[button.flyoutDock.config.name] = nil
		end

		button.options = nil
		button.lastOptions = nil
		button.flyoutDock = nil
		button.mode = nil
		button.flyoutType = nil
		button.cmds = nil

		button.config.clickAnchor = false
		button.config.mouseAnchor = false
		button.config.anchorDelay = false
		button.config.flyoutDock = false
		button.config.anchoredBar = false
		button:SetAttribute("flyoutdock", nil)
		button:SetAttribute("macroShow", nil)

		if (button.bar) then
			button.bar.watchframes = nil
		end

		if (button.flyoutButtons) then
			for k,v in pairs(button.flyoutButtons) do
				resetButton(v[1]); button.flyoutButtons[k] = nil
			end
		end

		anchorButtonIndex[button:GetName()] = nil

		return
	else
		button.options = options
	end

	local show = false

	if (not button.flyoutDock) then

		button.flyoutButtons = {}
		button.flyoutDock = createFlyoutDock(button.id, button)

		button.config.flyoutDock = button.flyoutDock.config.name

		button:SetAttribute("flyoutdock", true)

		if (button.bar) then
			local skin, name = button.bar.config.name, button.flyoutDock.config.name
			if (SD.bfskin and SD.bfskin[skin]) then
				if (not SD.bfskin[name]) then
					SD.bfskin[name] = CopyTable(SD.bfskin[skin])
				end
			end
		end

		button.mode = match(options, ":(%a*)$")

		setAnchor(button, button.mode)

		button.flyoutDock.handler:Show()

		anchorButtonIndex[button:GetName()] = button

		button.flyoutType = match(options, "^%a%a*")

		button.UpdateFlyout = M.UpdateFlyout

		show = true
	end

	if (button.bar and button.bar.handler) then

		local objects = GetChildrenAndRegions(button.bar.handler)

		for k,v in pairs(objects) do
			local name = gsub(v, button:GetName(), "")
			if ((name:lower()):find("flyouthandler")) then
				if (button.bar.watchframes) then
					button.bar.watchframes[name:lower()] = _G[v]
				else
					button.bar.watchframes = {}
					button.bar.watchframes[name:lower()] = _G[v]
				end
			end
		end
	end

	if (init) then
		button.flyoutDock.handler:Show()
	end

	if (options and button.flyoutDock.handler:IsVisible()) then

		local count, list, btn, slot, macrotext, pointA, pointB, hideArrow, shape, columns, pad, diff, prefix, found = 0, ""
		local postCmds = button.config.macro:match("/flyout%s%C+(%c.+)") or ""
		local anchorPostCmds = postCmds:gsub("#", "/")

		button.cmds = { (":"):split(options) }
		button.cmds[0] = button.cmds[2]:match("#[^,]+")
		button.cmds[1] = button.cmds[1]:gsub("%s*,%s*", ",")
		button.cmds[2] = button.cmds[2]:gsub("%s*,%s*", ",")
		button.postCmds = postCmds

		for k,v in pairs(button.flyoutButtons) do
			v[2] = 0; resetButton(v[1])
		end

		local scannedData = getDataList(button, options)

		if (scannedData) then

			table.sort(scannedData)

			for k,v in keySort(scannedData) do

				btn = getFlyoutButton(button, button.flyoutDock)

				btn.macroBtn = button
				btn.hasAction = button.flyoutDock.hasAction
				btn.noAction = button.flyoutDock.noAction
				btn.updateTexture = true

				btn:Show()

				local source, data = (";"):split(k)

				if (source == "s" or source =="b") then

					if (data:find("%(")) then
						btn.macroshow = data
					else
						btn.macroshow = data.."()"
					end

					btn:SetAttribute("prefix", "/cast ")

					prefix = "/cast "

				elseif (source == "c") then

					if (data:find("%(")) then
						btn.macroshow = data
					else
						btn.macroshow = data.."()"
					end

					btn:SetAttribute("prefix", "/use ")

					prefix = "/use "

				elseif (source == "i") then

					if (button.cmds[0] and button.cmds[0]:find("#%d+")) then
						slot = button.cmds[0]:match("%d+").." "
					end

					btn.macroshow = data

					btn:SetAttribute("prefix", "/use ")

					if (slot) then
						btn:SetAttribute("slot", slot.." ")
					end

					if (IsEquippableItem(data)) then
						if (slot) then
							prefix = "/equipslot "
							btn:SetAttribute("slot", slot.." ")
						else
							prefix = "/equip "
						end
					else
						prefix = btn:GetAttribute("prefix")
					end
				end

				btn.opt = ""

				for _,opt in ipairs(v) do
					btn.opt = btn.opt..opt..":"
				end

				btn.opt = btn.opt:gsub(":+$", "")

				if (slot) then
					btn:SetAttribute("macroShow", btn:GetAttribute("slot"))
					btn:SetAttribute("*macrotext1", prefix.."[nobtn:2] "..btn:GetAttribute("slot")..btn.macroshow..anchorPostCmds)
					btn:SetAttribute("anchorMacro", "#showtooltip "..btn:GetAttribute("slot").."\n"..btn:GetAttribute("prefix").."[nobtn:2] "..btn:GetAttribute("slot")..anchorPostCmds)
				else
					btn:SetAttribute("macroShow", btn.macroshow)
					btn:SetAttribute("*macrotext1", prefix.."[nobtn:2] "..btn.macroshow..anchorPostCmds)
					btn:SetAttribute("anchorMacro", "#showtooltip "..btn.macroshow.."\n"..btn:GetAttribute("prefix").."[nobtn:2] "..btn.macroshow..anchorPostCmds)
				end
				btn:SetAttribute("options", btn.opt)
				btn:SetAttribute("postCmds", postCmds)

				list = list..btn.id..";"

				if (init and not macrotext) then
					macrotext = btn:GetAttribute("anchorMacro").."\n/stopmacro [nobtn:2]\n/flyout "..btn:GetAttribute("options")..btn:GetAttribute("postCmds")
				end

				if (SKIN) then

					local btnData = {	Normal = btn.normaltexture, Icon = btn.iconframeicon, Cooldown = btn.iconframecooldown, HotKey = btn.hotkey, Count = btn.count, Name = btn.name, Border = btn.border, AutoCast = false }

					SKIN:Group("Macaroon", button.flyoutDock.config.name):AddButton(btn, btnData)

				end
			end
		end

		if (not button.config.macro:find("%[nobtn:2%]") and init and macrotext) then
			button.config.macro = macrotext
		end

		for k,v in pairs(button.flyoutButtons) do
			if (v[2] == 0) then
				resetButton(v[1])
				button.flyoutButtons[k] = nil
			else
				count = count + 1
			end
		end

		button.flyoutDock:SetWidth(36)
		button.flyoutDock:SetHeight(36)
		button.flyoutDock:ClearAllPoints()
		button.flyoutDock:SetPoint("CENTER")
		button.flyoutDock:SetScale(button.scale or button:GetScale())
		button.flyoutDock.config.buttonList.homestate = list
		button.flyoutDock.homestate.buttonCount = count
		button.flyoutDock.buttonCountChanged = true
		button.flyoutDock.lastButton = button

		if (button.cmds[3] and find(button.cmds[3]:lower(), "^c")) then shape = 2 else shape = 1 end
		if (button.cmds[4]) then pointA = button.cmds[4]:match("%a+"):upper() if (M.Points[pointA]) then pointA = M.Points[pointA] end end
		if (button.cmds[5]) then pointB = button.cmds[5]:upper() if (M.Points[pointB]) then pointB = M.Points[pointB] end end
		if (button.cmds[6] and tonumber(button.cmds[6])) then
			if (shape == 1) then
				columns = tonumber(button.cmds[6])
			elseif (shape == 2) then
				pad = tonumber(button.cmds[6])
			end
		end
		if (button.cmds[7] and find(button.cmds[7]:lower(), "^m")) then button.mode = "mouse" else button.mode = "click" end
		if (button.cmds[8] and find(button.cmds[8]:lower(), "^h")) then hideArrow = true end
		if (shape) then button.flyoutDock.config.shape = shape else button.flyoutDock.config.shape = 1 end
		if (columns) then button.flyoutDock.config.columns = columns else button.flyoutDock.config.columns = 6 end
		if (pad) then button.flyoutDock.config.padData.homestate = pad..":"..pad else button.flyoutDock.config.padData.homestate = "0:0" end

		setAnchor(button, button.mode)

		M.UpdateShape(button.flyoutDock, nil, nil, true)
		M.UpdateBarSize(button.flyoutDock)

		button.flyoutDock:ClearAllPoints()

		button.flyouttop:Hide()
		button.flyoutbottom:Hide()
		button.flyoutleft:Hide()
		button.flyoutright:Hide()

		if (pointA and pointB) then
			button.flyoutDock:SetPoint(pointA, button, pointB, 0, 0)
			if (not hideArrow) then
				button.arrowPoint = pointB:gsub("^(TOP)(%a+)", "%2")
				button.arrowPoint = button.arrowPoint:gsub("^(BOTTOM)(%a+)", "%2")
				button.arrowX = pointOffset[button.arrowPoint][1]
				button.arrowY = pointOffset[button.arrowPoint][2]
				button.flyoutArrow = button["flyout"..button.arrowPoint:lower()]
				if (button.flyoutArrow) then
					button.flyoutArrow:Show()
				end
			end
		else
			button.flyoutDock:SetPoint("RIGHT", button, "LEFT", 0, 0)
			if (not hideArrow) then
				button.arrowPoint = "LEFT"
				button.arrowX = pointOffset["LEFT"][1]
				button.arrowY = pointOffset["LEFT"][2]
				button.flyoutArrow = button.flyoutleft
				button.flyoutArrow:Show()
				if (button.flyoutArrow) then
					button.flyoutArrow:Show()
				end
			end
		end

		if (init) then
			button.flyoutDock.handler:Hide()
		elseif (show) then
			button.flyoutDock.handler:Show()
		end
	end
end

local function control_OnUpdate(self, elapsed)

	for k,v in pairs(in_data) do

		if (k+v[1] < self.elapsed) then

			local command = v[2]:match("^(/%S+)")

			if (command and IsSecureCmd(command)) then

				print(command.." is a secure command and cannot be used with /in")

			elseif (v[2] and #v[2] > 0) then

				editbox:SetText(v[2]); ChatEdit_SendText(editbox)
			end

			in_data[k] = nil
		end
	end

	for k,v in pairs(repeat_data) do

		if (k+v[1] < self.elapsed) then

			if (repeats) then

				local command = v[3]:match("^(/%S+)")

				if (command and IsSecureCmd(command)) then

					print(command.." is a secure command and cannot be used with /repeat")

				elseif (v[3] and #v[3] > 0) then

					editbox:SetText(v[3]); ChatEdit_SendText(editbox)
				end

				v[4] = v[4] + 1

				if (v[2] > 0 and v[4] >= v[2]) then
					repeat_data[k] = nil
				else
					repeat_data[self.elapsed] = CopyTable(repeat_data[k]); repeat_data[k] = nil
				end

				self.elapsed = self.elapsed + elapsed
			else
				repeat_data[k] = nil
			end
		end
	end
end

local extensions = {
	["/doafter"] = command_doafter,
	["/in"] = command_in,
	["/repeat"] = command_repeat,
	["/flyout"] = command_flyout,
}

local function controlOnEvent(self, event, ...)

	local unit = ...

	if (event == "EXECUTE_CHAT_LINE") then

		local command, options = match(..., "(/%a+)%s(.+)")

		if (extensions[command]) then extensions[command](options) end

	elseif (event == "BAG_UPDATE" or event =="PLAYER_INVENTORY_CHANGED" ) then

		updateItemTooltips()

		local add

		for k,v in pairs(anchorButtonIndex) do

			add = true

			if (v.flyoutType:find("^i")) then
				for _,btn in pairs(needUpdate) do
					if (btn == v) then
						add = false
					end
				end

				if (add) then
					--tinsert(needUpdate, v)
				end
			end
		end

	elseif (event == "COMBAT_LOG_EVENT_UNFILTERED" and select(4, ...) == player) then

		local timestamp, currevent, srcGUID, name, srcFlags, dstGUID, dstName, dstFlags, spellID, currspell = select(1, ...)
		local watchspell, watchevent, watchaction

		currevent = match(currevent, "_(%a+)$"):lower()

		for k,v in pairs(doafter_data) do

			watchspell, watchevent, watchaction = (":"):split(k)

			if (watchspell and currspell) then

				watchspell = lower(watchspell); currspell = lower(currspell); watchevent = lower(watchevent)

 				if (currspell == watchspell and currevent == watchevent) then

					local command = watchaction:match("^(/%S+)")

					if (command and IsSecureCmd(command)) then

						print(command.." is a secure command and cannot be used with /doafter")

					elseif (watchaction and #watchaction > 0) then

						watchaction = gsub(k, watchspell..":", "")
						watchaction = gsub(watchaction, watchevent..":", "")
						doafterLog = { event = watchevent, select(12, ...) }

						editbox:SetText(watchaction); ChatEdit_SendText(editbox)
					end

					doafter_data[k] = nil
				end
			end
		end

	elseif (event == "SKILL_LINES_CHANGED" or event == "LEARNED_SPELL_IN_TAB" or event == "CHARACTER_POINTS_CHANGED") then

		updateSpellTooltips()

		local add

		for k,v in pairs(anchorButtonIndex) do

			add = true

			if (v.flyoutType:find("^s")) then
				for _,btn in pairs(needUpdate) do
					if (btn == v) then
						add = false
					end
				end

				if (add) then
					tinsert(needUpdate, v)
				end
			end
		end

		if (not itemScanner:IsVisible()) then
			flyoutButtonUpdater:Show()
		end

	elseif (event == "COMPANION_LEARNED" or event == "COMPANION_UPDATE") then

		updateCompanionTooltips()

		local add

		for k,v in pairs(anchorButtonIndex) do

			add = true

			if (v.flyoutType:find("^c")) then
				for _,btn in pairs(needUpdate) do
					if (btn == v) then
						add = false
					end
				end

				if (add) then
					tinsert(needUpdate, v)
				end
			end
		end

		if (not itemScanner:IsVisible()) then
			flyoutButtonUpdater:Show()
		end

	elseif (event == "ADDON_LOADED" and ... == "Macaroon") then

		SD = MacaroonSavedState

		ItemCache = MacaroonItemCache

		M.Extensions = extensions

		SlashCmdList["MACAROONEXT"] = slashHandler
		SLASH_MACAROONEXT1 = "/killrepeats"

		SlashCmdList["MACAROONEXTIN"] = command_in
		SLASH_MACAROONEXTIN1 = "/in"

		SlashCmdList["MACAROONEXTREP"] = command_repeat
		SLASH_MACAROONEXTREP1 = "/repeat"

		local OrigSendChatMessage = SendChatMessage
		SendChatMessage = function(msg, ...) msg = msg:gsub("%%%S+", function(word) return getSubs(word) end) msg = msg:gsub("%s+", " ") OrigSendChatMessage(msg, ...) end

		hooksecurefunc("ChatEdit_ParseText", chatEdit_ParseText)
		hooksecurefunc(Macaroon, "Button_OnDragStart", function(self) if (self.drag and self.flyoutDock) then M.UpdateFlyout(self) end end)
		hooksecurefunc(Macaroon, "Button_OnReceiveDrag", function(self) local flyoutOpt = self.config.macro:match("/flyout%s(%C+)") if (flyoutOpt and #flyoutOpt>0) then M.UpdateFlyout(self, flyoutOpt, true) end end)

		local strings = { tooltipScan:GetRegions() }

		for k,v in pairs(strings) do
			if (v:GetObjectType() == "FontString") then
				tinsert(tooltipStrings, v)
			end
		end

	elseif (event == "PLAYER_LOGIN") then

		player = UnitName("player")
		level = UnitLevel("player")

		updateItemTooltips(true)
		updateSpellTooltips()
		updateCompanionTooltips()

		initializeFlyoutButtons()

		if (_G["SLASH_IN1"]) then
			_G["SLASH_IN1"] = "/acein"
		end

	elseif (event == "PLAYER_ENTERING_WORLD" and not pew) then

		pew = true

	elseif (event == "UNIT_LEVEL" and ... == "player") then

		level = UnitLevel("player")
	end
end

control = CreateFrame("Frame", nil, UIParent)
control:SetScript("OnEvent", controlOnEvent)
control:SetScript("OnUpdate", control_OnUpdate)
control:RegisterEvent("ADDON_LOADED")
control:RegisterEvent("PLAYER_LOGIN")
control:RegisterEvent("PLAYER_ENTERING_WORLD")
control:RegisterEvent("EXECUTE_CHAT_LINE")
control:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
control:RegisterEvent("BAG_UPDATE")
control:RegisterEvent("PLAYER_INVENTORY_CHANGED")
control:RegisterEvent("COMPANION_LEARNED")
control:RegisterEvent("SKILL_LINES_CHANGED")
control:RegisterEvent("LEARNED_SPELL_IN_TAB")
control:RegisterEvent("CHARACTER_POINTS_CHANGED")
control:RegisterEvent("UNIT_LEVEL")

--[[

/doafter command -

	This command allows for the execution of an unsecure chat line after a specified event for a given spell

		Format -

			/doafter <spell>:<spell event>:<unsecure command line>

		Example -

			/doafter flash heal:success:/say Flash Heal has been cast

		List of available events and associated data -

			damage - 1:amount, 2:overkill, 3:school, 4:resisted, 5:blocked, 6:absorbed, 7:critical, 8:glancing, 9:crushing
			missed - 1:misstype, 2:amount missed
			heal - 1:amount, 2:overheal, 3:critical
			energize
			drain
			leech
			interrupt
			stolen
			start
			success
			failed
			instakill
			create
			summon
			resurrect

/in command -

	This command allows for the execution of an unsecure chat line after the specified amount of time

		Format -

			/in <wait time>:<unsecure command line>

		Example -

			/in 5:/say It has been 5 seconds!


/repeat command-

	This command allows for the execution of an unsecure chat line at repeated intervals for the specified number of times.

		Format -

			/repeat <interval>:<count>:<unsecure command line>

		Example -

			/repeat 5:3:/g Be careful not to spam!


/flyout command -

	This command allows for the creation of a popup menu of items/spells for flyoution to be used by the macro button

		Format -

			/flyout <types>:<keys>:<shape>:<attach point>:<relative point>:<columns|radius>:<click|mouse>

			/flyout s+,i+:teleport,!drake:linear:top:bottom:1:click

		Examples -

			/flyout item:quest item:linear:right:left:6:mouse

			/flyout item+:quest item:circular:center:center:15:click

			/flyout companion:mount:linear:right:left:6

			Most options may be abbreviated -

			/flyout i+:quest item:c:c:c:15:c

		Types:

			item
			spell
			companion

			add + to scan the type's tooltip instead of the type's data

		Keys:

			Comma deliminate as many keys as you want (ex: "quest item,use")

			The "companion" type must have "critter" or "mount" in the key list

			! before a key excludes that key

			~ before a key makes the key optional

		Shapes:

			linear
			circular

		Points:

			left
			right
			top
			bottom
			topleft
			topright
			bottomleft
			bottomright
			center



Substitutions -

	Targets - returns the name of the specificed target

		%p = "player",
		%t = "target",
		%f = "focus",
		%tt = "targettarget",
		%p1 = "party1",
		%p2 = "party2",
		%p3 = "party3",
		%p4 = "party4",
		%pt = "pet",
		%mo = "mouseover",

	Modifiers - returns additional information about the specified target or "target" if not specified

		c = class
		n = name
		l = level
		g = gender
		r = race
		h = health
		m = mana
		rt = raid target

		+ = verbose feedback

	Examples -

		%f:n:c:l - returns the name, class and level of your focus target. If the information does not exist, nothing is returned.

		%f:n:c:l+ - same as above, but if the information does not exist, feedack is given on what information does not exist.

		%tt - returns the name of your target's target.

	Notes -

		Multiple subsititutions may be included on the same line -

		%f:n:c:l

		is the same as

		%f:n %f:c+ %f:l

		but allows for the feedback to be unique for each returned datum.
]]--
