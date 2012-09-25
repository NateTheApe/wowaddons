--MacaroonXtras, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

local M = Macaroon

M.BagBars = {}
M.BagButtons = {}

M.MenuBars = {}
M.MenuButtons = {}

MacaroonXtrasSavedState = {
	freeSlots = 16,
	fix100310 = false,
	scriptProfile = false,
}

local bagElements = {}
local menuElements = {}
local addonData, sortData = {}, {}

local load, pew, pvpFrame

local lower = string.lower
local sort = table.sort
local format = string.format

local GetAddOnInfo = _G.GetAddOnInfo
local GetAddOnMemoryUsage = _G.GetAddOnMemoryUsage
local GetAddOnCPUUsage = _G.GetAddOnCPUUsage
local GetScriptCPUUsage = _G.GetScriptCPUUsage
local UpdateAddOnMemoryUsage = _G.UpdateAddOnMemoryUsage
local UpdateAddOnCPUUsage = _G.UpdateAddOnCPUUsage

local CopyTable = M.CopyTable
local ClearTable = M.ClearTable
local GetChildrenAndRegions = M.GetChildrenAndRegions

local SD = CopyTable(MacaroonXtrasSavedState)
local defaultSD = CopyTable(MacaroonXtrasSavedState)

local function updateData(button, bar, state)

	button.bar = bar
	button.alpha = bar.config.alpha
	button.showGrid = bar.config.showGrid
	button:SetAttribute("showgrid-bar", bar.config.showGrid)
	button.config.showstates = state
	button:SetAttribute("showstates", state)

	button.config.bar = bar:GetID()
	button.config.stored = false

	button:SetFrameStrata(bar.config.buttonStrata)

	button:SetFrameLevel(4)

	if (bar.handler) then
		M.UpdateButtonVisibility(button, bar.handler:GetAttribute("state-current"))
	end
end

local function buttonDefaults(index, button)

	button.config = {
		bar = 0,
		barPos = 0,
		showstates = "",
		laststate = "",
		hotKeys = ":",
		hotKeyText = ":",
		hotKeyLock = false,
		scale = 1,
		XOffset = 0,
		YOffset = 0,
		mouseoverAnchor = false,
		clickAnchor = false,
		anchorDelay = "0.1",
		anchoredBar = "",
	}
end

local function createBagButton(index)

	local button

	if (_G["MacaroonBagButton"..index]) then
		button = _G["MacaroonBagButton"..index]
	else
		button = CreateFrame("CheckButton", "MacaroonBagButton"..index, UIParent, "MacaroonAnchorButtonTemplate")
	end

	local buttonName = button:GetName()
	local objects = GetChildrenAndRegions(button)

	for k,v in pairs(objects) do
		local name = gsub(v, button:GetName(), "")
		button[lower(name)] = _G[v]
	end

	button:SetID(index)
	button.id = index
	button:SetWidth(bagElements[index]:GetWidth()+1)
	button:SetHeight(bagElements[index]:GetHeight()+1)
	button:SetHitRectInsets(button:GetWidth()/2, button:GetWidth()/2, button:GetHeight()/2, button:GetHeight()/2)

	button.editframe:SetPoint("TOPLEFT")
	button.editframe:SetPoint("BOTTOMRIGHT")
	button.editframetype:SetText("bag")

	buttonDefaults(index, button)
	button.bagelement = bagElements[index]

	objects = GetChildrenAndRegions(button.bagelement)

	for k,v in pairs(objects) do
		local name = gsub(v, button.bagelement:GetName(), "")
		button[lower(name)] = _G[v]
	end

	button.bagelement:ClearAllPoints()
	button.bagelement:SetParent(button)
	button.bagelement:Show()
	button.bagelement:SetPoint("CENTER", button, "CENTER")
	button.bagelement:SetScale(1)

	if (index == 5) then
		button.bagelement:SetScript("OnClick", function() if (IsModifiedClick()) then OpenAllBags() else ToggleBackpack() end end)
	else
		button.bagelement:SetScript("OnClick", BagSlotButton_OnClick)
	end

	button.editor = M.XtrasEditor

	button.updateData = updateData
	button.storage = MacaroonButtonStorage

	button.topadj = 1
	button.bottomadj = 1
	button.leftadj = 1
	button.rightadj= 1

	button:SetAttribute("showgrid", 0)
	button:SetAttribute("showstates", "")
	button:SetAttribute("hotkeys", "")
	button:SetAttribute("hasaction", true)
	button:SetAttribute("_childupdate", [[

			self:SetAttribute("stateshown", false)

			for showstate in gmatch(self:GetAttribute("showstates"), "[^;]+") do
				if (message and strfind(message, showstate)) then
					if (self:GetAttribute("hasaction") or self:GetAttribute("showgrid-bar") or self:GetAttribute("editmode")) then
						self:Show()
					end
					self:SetAttribute("stateshown", true)
				end
			end

			if (not self:GetAttribute("stateshown")) then
				self:Hide()
			end
		]] )


	if (not SD.bags) then
		SD.bags = {}
	end

	SD.bags[index] = { button.config }

	M.BagButtons[index] = { button, 1 }

	return button
end

local function createMenuButton(index)

	local button

	if (_G["MacaroonMenuButton"..index]) then
		button = _G["MacaroonMenuButton"..index]
	else
		button = CreateFrame("CheckButton", "MacaroonMenuButton"..index, UIParent, "MacaroonAnchorButtonTemplate")
	end

	local buttonName = button:GetName()
	local objects = GetChildrenAndRegions(button)

	for k,v in pairs(objects) do
		local name = gsub(v, button:GetName(), "")
		button[lower(name)] = _G[v]
	end

	button:SetID(index)
	button.id = index
	button:SetWidth(menuElements[index]:GetWidth()*0.86)
	button:SetHeight(menuElements[index]:GetHeight()/1.65)
	button:SetHitRectInsets(button:GetWidth()/2, button:GetWidth()/2, button:GetHeight()/2, button:GetHeight()/2)

	button.editframe:SetPoint("TOPLEFT", -3, 0)
	button.editframe:SetPoint("BOTTOMRIGHT", 3, 0)
	button.editframetype:SetText("menu")
	button.editframetype:SetTextHeight(8)

	buttonDefaults(index, button)
	button.menuelement = menuElements[index]

	objects = GetChildrenAndRegions(button.menuelement)

	for k,v in pairs(objects) do
		local name = gsub(v, button.menuelement:GetName(), "")
		button[lower(name)] = _G[v]
	end

	button.menuelement.normaltexture = button.menuelement:CreateTexture("$parentNormalTexture", "OVERLAY", "MacaroonCheckButtonTextureTemplate")
	button.menuelement.normaltexture:ClearAllPoints()
	button.menuelement.normaltexture:SetPoint("CENTER", 0, 0)
	button.menuelement.icontexture = button.menuelement:GetNormalTexture()
	button.menuelement:ClearAllPoints()
	button.menuelement:SetParent(button)
	button.menuelement:Show()
	button.menuelement:SetPoint("BOTTOM", button, "BOTTOM", 0, -1)
	button.menuelement:SetHitRectInsets(3, 3, 23, 3)

	button.editor = M.XtrasEditor

	button.updateData = updateData
	button.storage = MacaroonButtonStorage

	button:SetAttribute("showgrid", 0)
	button:SetAttribute("showstates", "")
	button:SetAttribute("hotkeys", "")
	button:SetAttribute("hasaction", true)
	button:SetAttribute("_childupdate", [[

			self:SetAttribute("stateshown", false)

			for showstate in gmatch(self:GetAttribute("showstates"), "[^;]+") do
				if (message and strfind(message, showstate)) then
					if (self:GetAttribute("hasaction") or self:GetAttribute("showgrid-bar") or self:GetAttribute("editmode")) then
						self:Show()
					end
					self:SetAttribute("stateshown", true)
				end
			end

			if (not self:GetAttribute("stateshown")) then
				self:Hide()
			end
		]] )

	if (not SD.menu) then
		SD.menu = {}
	end

	SD.menu[index] = { button.config }

	M.MenuButtons[index] = { button, 1 }

	return button
end

local function bagbarUpdate(bar, state)

	if (not bar[state]) then return end

	if (bar[state].buttonCount == 1) then
		MacaroonBackpackButton:SetScript("OnClick", function() if (ContainerFrame1:IsVisible()) then CloseAllBags() else OpenAllBags() end end)
	else
		MacaroonBackpackButton:SetScript("OnClick", function() if (IsModifiedClick()) then OpenAllBags() else ToggleBackpack() end end)
	end
end

function M.XtrasLoadSavedData(saved, profile)

	if (saved) then

		load = true

		local savedState = CopyTable(saved)
		local newBar, defaults = false

		if (savedState.bagbars) then

			ClearTable(M.BagBars)

			defaults = M.GetBarDefaults()

			for k,v in pairs(savedState.bagbars) do

				local bar = M.CreateBar("bag", true, true, savedState.bagbars[k][1])

				M.UpdateConfig(bar, defaults)

				bar.handler:SetAttribute("state-current", bar.config.currentstate)

				bar.handler:SetAttribute("state-last", bar.config.laststate)

				bar.updateFunc = bagbarUpdate

				bar.reverse = true
			end

			savedState.bagbars = nil

		elseif (not profile) then

			newBar = M.CreateBar("bag", true, true)
		end

		if (savedState.bags) then

			for k,v in pairs(M.BagButtons) do
				M.StoreButton(v[1], M.BagButtons)
			end

			defaults = M.GetXtrasButtonDefaults()

			for k,v in pairs(savedState.bags) do

				local button = createBagButton(k)

				button.config = CopyTable(savedState.bags[k][1])

				--temp fix
				if (button.config.hotKeys) then
					button.config.hotKeys = gsub(button.config.hotKeys, "»", ":")
					button.config.hotKeyText = gsub(button.config.hotKeyText, "»", ":")
				end

				M.UpdateConfig(button, defaults)
			end

			savedState.bags = nil

		elseif (not profile) then

			for k,v in ipairs(bagElements) do
				createBagButton(k)
			end
		end

		if (newBar) then
			M.AddButton(#bagElements, newBar)
		end

		if (newBar) then
			M.Ypos = M.UpdateBarPositions(M.BagBars, true, M.Ypos)
		end

		if (savedState.menubars) then

			ClearTable(M.MenuBars)

			defaults = M.GetBarDefaults()

			for k,v in pairs(savedState.menubars) do

				local bar = M.CreateBar("menu", true, true, savedState.menubars[k][1])

				M.UpdateConfig(bar, defaults)

				bar.config.skinnable = false

				bar.handler:SetAttribute("state-current", bar.config.currentstate)

				bar.handler:SetAttribute("state-last", bar.config.laststate)
			end

			savedState.menubars = nil

		elseif (not profile) then

			newBar = M.CreateBar("menu", true, true)
		end

		if (savedState.menu) then

			for k,v in pairs(M.MenuButtons) do
				M.StoreButton(v[1], M.MenuButtons)
			end

			defaults = M.GetXtrasButtonDefaults()

			for k,v in pairs(savedState.menu) do

				local button = createMenuButton(k)

				button.config = CopyTable(savedState.menu[k][1])

				--temp fix
				if (button.config.hotKeys) then
					button.config.hotKeys = gsub(button.config.hotKeys, "»", ":")
					button.config.hotKeyText = gsub(button.config.hotKeyText, "»", ":")
				end

				M.UpdateConfig(button, defaults)
			end

			savedState.menu = nil

		elseif (not profile) then

			for k,v in ipairs(menuElements) do
				createMenuButton(k)
			end
		end

		if (newBar) then
			M.AddButton(#menuElements, newBar)
		end

		if (newBar) then
			M.Ypos = M.UpdateBarPositions(M.MenuBars, true, M.Ypos)
		end

		for k,v in pairs(savedState) do
			if (SD[k]) then
				SD[k] = v
			end
		end
	end
end

function M.XtrasUpdateElements()

	for k,v in pairs(M.BagBars) do

		v.stateschanged = true

		v.buttonCountChanged = true

		v.updateBar(v, true, true, true, true, true)
	end

	for k,v in pairs(M.BagBars) do

		v.updateBarLink(v)
	end

	for k,v in pairs(M.MenuBars) do

		v.stateschanged = true

		v.buttonCountChanged = true

		v.updateBar(v, true, true, true, true)
	end

	for k,v in pairs(M.MenuBars) do

		v.updateBarLink(v)
	end
end

function M.XtrasSaveCurrentState()

	if (load) then

		if (SD.bagbars) then
			ClearTable(SD.bagbars)
		else
			SD.bagbars = {}
		end

		for k,v in pairs(M.BagBars) do
			SD.bagbars[k] = { v.config }
		end

		if (SD.bags) then
			ClearTable(SD.bags)
		else
			SD.bags = {}
		end

		for k,v in pairs(M.BagButtons) do
			SD.bags[k] = { v[1].config }
		end

		if (SD.menubars) then
			ClearTable(SD.menubars)
		else
			SD.menubars = {}
		end

		for k,v in pairs(M.MenuBars) do
			SD.menubars[k] = { v.config }
		end

		if (SD.menu) then
			ClearTable(SD.menu)
		else
			SD.menu = {}
		end

		for k,v in pairs(M.MenuButtons) do
			SD.menu[k] = { v[1].config }
		end
	end

	return SD, "bagbars;menubars", "bags;menu"
end

function M.BagBarDefaults(index, bar)

	bar.config.name = "Bag Bar "..bar:GetID()
	bar.config.padData.homestate = "3:3"
	bar.config.scale = 1.2

	bar.reverse = true
	bar.updateFunc = bagbarUpdate

	bar.handler:SetAttribute("state-current", bar.config.currentstate)
	bar.handler:SetAttribute("state-last", bar.config.laststate)
end

function M.MenuBarDefaults(index, bar)

	bar.config.name = "Menu Bar "..bar:GetID()
	bar.config.padData.homestate = "2:2"
	bar.config.skinnable = false

	bar.handler:SetAttribute("state-current", bar.config.currentstate)
	bar.handler:SetAttribute("state-last", bar.config.laststate)
end

function M.GetXtrasButtonDefaults()

	local defaults = {}

	buttonDefaults(0, defaults)

	return defaults.config
end

function M.AddXtrasButton(bar)

	if (bar.btnType == "MacaroonBagButton") then

		for k,v in ipairs(bagElements) do
			if (not _G["MacaroonBagButton"..k]) then
				return createBagButton(k)
			end
		end

	elseif (bar.btnType == "MacaroonMenuButton") then

		for k,v in ipairs(menuElements) do
			if (not _G["MacaroonMenuButton"..k]) then
				return createMenuButton(k)
			end
		end
	end
end

function M.SetXtrasButton(button, bar, state)

	button.bar = bar
	button.hidegrid = true
	button.config.bar = bar:GetID()
	button.config.stored = false
	button.config.showstates = state
	button:SetAttribute("showstates", state)
	button:SetAttribute("editmode", true)

	M.UpdateButtonVisibility(button, state)

	if (not bar.config.buttonList[state] or bar.config.buttonList[state] == "") then
		bar.config.buttonList[state] = tostring(button.id)
	elseif (bar.reverse) then
		bar.config.buttonList[state] = button.id..";"..bar.config.buttonList[state]
	else
		bar.config.buttonList[state] = bar.config.buttonList[state]..";"..button.id
	end

	bar.buttonCountChanged = true

	bar.btnTable[button.id][2] = 0

end

local function toggleBag(id)

	if (not InCombatLockdown() and IsOptionFrameOpen()) then

		local size = GetContainerNumSlots(id)
		if (size > 0 or id == KEYRING_CONTAINER) then
			local containerShowing;
			for i=1, NUM_CONTAINER_FRAMES, 1 do
				local frame = _G["ContainerFrame"..i]
				if (frame:IsShown() and frame:GetID() == id) then
					containerShowing = i
					frame:Hide()
				end
			end
			if (not containerShowing) then
				ContainerFrame_GenerateFrame(ContainerFrame_GetOpenFrame(), size, id)
			end
		end
	end
end

local function toggleBackpack()

	if (not InCombatLockdown() and IsOptionFrameOpen()) then

		if (IsBagOpen(0)) then
			for i=1, NUM_CONTAINER_FRAMES, 1 do
				local frame = _G["ContainerFrame"..i]
				if (frame:IsShown()) then
					frame:Hide()
				end
				-- Hide the token bar if closing the backpack
				if (BackpackTokenFrame) then
					BackpackTokenFrame:Hide()
				end
			end
		else
			ToggleBag(0)
			-- If there are tokens watched then show the bar
			if (ManageBackpackTokenFrame) then
				BackpackTokenFrame_Update()
				ManageBackpackTokenFrame()
			end
		end
	end
end

local function containerFrame_OnShow(self)

	local index = abs(self:GetID()-5)

	if (bagElements[index]) then
		bagElements[index]:SetChecked(1)
	end
end

local function containerFrame_OnHide(self)

	local index = abs(self:GetID()-5)

	if (bagElements[index]) then
		bagElements[index]:SetChecked(0)
	end
end

local function updateTabard(button)

	local emblem = select(10, GetGuildLogoInfo())

	if (emblem) then

		if (not button.tabard:IsShown()) then

			button:SetNormalTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Up")
			button:SetPushedTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Down")

			button.tabard:Show()
		end

		SetSmallGuildTabardTextures("player", button.tabard.emblem, button.tabard.background)

	else
		if (button.tabard:IsShown()) then

			button:SetNormalTexture("Interface\\Buttons\\UI-MicroButton-Socials-Up")
			button:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-Socials-Down")
			button:SetDisabledTexture("Interface\\Buttons\\UI-MicroButton-Socials-Disabled")

			button.tabard:Hide()
		end
	end
end

local function updateMicroButtons()

	local playerLevel = UnitLevel("player")

	if (MacaroonCharacterButton and CharacterFrame:IsShown()) then

		MacaroonCharacterButton:SetButtonState("PUSHED", 1)
		M.CharacterButton_SetPushed(MacaroonCharacterButton)

	elseif (MacaroonCharacterButton) then

		MacaroonCharacterButton:SetButtonState("NORMAL")
		M.CharacterButton_SetNormal(MacaroonCharacterButton)
	end

	if (MacaroonSpellbookButton and SpellBookFrame:IsShown()) then

		MacaroonSpellbookButton:SetButtonState("PUSHED", 1)

	elseif (MacaroonSpellbookButton) then

		MacaroonSpellbookButton:SetButtonState("NORMAL")
	end

	if (MacaroonTalentButton and PlayerTalentFrame and PlayerTalentFrame:IsShown()) then

		MacaroonTalentButton:SetButtonState("PUSHED", 1)

	elseif (MacaroonTalentButton) then

		if (playerLevel < SHOW_TALENT_LEVEL) then

			MacaroonTalentButton:GetNormalTexture():SetDesaturated(1)
			MacaroonTalentButton:GetNormalTexture():SetVertexColor(0.5,0.5,0.5)
			MacaroonTalentButton:GetPushedTexture():SetDesaturated(1)
			MacaroonTalentButton:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-Talents-Up")
			MacaroonTalentButton:SetHighlightTexture("")
			MacaroonTalentButton.disabledTooltip = format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_TALENT_LEVEL)

		else
			MacaroonTalentButton:GetNormalTexture():SetDesaturated(nil)
			MacaroonTalentButton:GetNormalTexture():SetVertexColor(1,1,1)
			MacaroonTalentButton:GetPushedTexture():SetDesaturated(nil)
			MacaroonTalentButton:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-Talents-Down")
			MacaroonTalentButton:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight")
			MacaroonTalentButton:SetButtonState("NORMAL")
			MacaroonTalentButton.disabledTooltip = nil
		end

	end

	if (MacaroonQuestLogButton and QuestLogFrame:IsShown()) then

		MacaroonQuestLogButton:SetButtonState("PUSHED", 1)

	elseif (MacaroonQuestLogButton) then

		MacaroonQuestLogButton:SetButtonState("NORMAL")
	end

	if (MacaroonLatencyButton and (GameMenuFrame:IsShown() or InterfaceOptionsFrame:IsShown() or (KeyBindingFrame and KeyBindingFrame:IsShown()) or (MacroFrame and MacroFrame:IsShown()))) then

		MacaroonLatencyButton:SetButtonState("PUSHED", 1)
		M.LatencyButton_SetPushed(MacaroonLatencyButton)

	elseif (MacaroonLatencyButton) then

		MacaroonLatencyButton:SetButtonState("NORMAL")
		M.LatencyButton_SetNormal(MacaroonLatencyButton)
	end

	if (MacaroonPVPButton and pvpFrame:IsShown()) then

		MacaroonPVPButton:SetButtonState("PUSHED", 1)
		M.PVPButton_SetPushed(MacaroonPVPButton)

	elseif (MacaroonPVPButton) then

		if (playerLevel < SHOW_PVP_LEVEL) then

			MacaroonPVPButton:GetNormalTexture():SetDesaturated(1)
			MacaroonPVPButton:GetNormalTexture():SetVertexColor(0.5,0.5,0.5)
			MacaroonPVPButton:GetPushedTexture():SetDesaturated(1)
			MacaroonPVPButton.faction:SetDesaturated(1)
			MacaroonPVPButton.faction:SetVertexColor(0.5,0.5,0.5)
			MacaroonPVPButton:SetPushedTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Up")
			MacaroonPVPButton:SetHighlightTexture("")
			MacaroonPVPButton.disabledTooltip = format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_PVP_LEVEL)

		else
			MacaroonPVPButton:GetNormalTexture():SetDesaturated(nil)
			MacaroonPVPButton:GetNormalTexture():SetVertexColor(1,1,1)
			MacaroonPVPButton:GetPushedTexture():SetDesaturated(nil)
			MacaroonPVPButton.faction:SetDesaturated(nil)
			MacaroonPVPButton.faction:SetVertexColor(1,1,1)
			MacaroonPVPButton:SetPushedTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Down")
			MacaroonPVPButton:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight")
			MacaroonPVPButton:SetButtonState("NORMAL")
			MacaroonPVPButton.disabledTooltip = nil
			M.PVPButton_SetNormal(MacaroonPVPButton)
		end
	end

	if (MacaroonGuildButton and ((GuildFrame and GuildFrame:IsShown()) or (LookingForGuildFrame and LookingForGuildFrame:IsShown()))) then

		MacaroonGuildButton:SetButtonState("PUSHED", 1)
		MacaroonGuildButton.tabard:SetPoint("TOPLEFT", -1, -1)
		MacaroonGuildButton.tabard:SetAlpha(0.5)

	elseif (MacaroonGuildButton) then

		MacaroonGuildButton:GetNormalTexture():SetDesaturated(nil)
		MacaroonGuildButton:GetNormalTexture():SetVertexColor(1,1,1)
		MacaroonGuildButton:GetPushedTexture():SetDesaturated(nil)
		MacaroonGuildButton:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-Socials-Down")
		MacaroonGuildButton:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight")
		MacaroonGuildButton:SetButtonState("NORMAL")
		MacaroonGuildButton.tabard:SetPoint("TOPLEFT", 0, 0)
		MacaroonGuildButton.tabard:SetAlpha(1.0)
		MacaroonGuildButton.disabledTooltip = nil

		if (IsInGuild()) then
			updateTabard(MacaroonGuildButton)
		end
	end

	if (MacaroonLFDButton and LFDParentFrame and LFDParentFrame:IsShown())  then

		MacaroonLFDButton:SetButtonState("PUSHED", 1)

	elseif (MacaroonLFDButton) then

		if (playerLevel < SHOW_LFD_LEVEL) then

			MacaroonLFDButton:GetNormalTexture():SetDesaturated(1)
			MacaroonLFDButton:GetNormalTexture():SetVertexColor(0.5,0.5,0.5)
			MacaroonLFDButton:GetPushedTexture():SetDesaturated(1)
			MacaroonLFDButton:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-LFG-Up")
			MacaroonLFDButton:SetHighlightTexture("")
			MacaroonLFDButton.disabledTooltip = format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_LFD_LEVEL)

		else
			MacaroonLFDButton:GetNormalTexture():SetDesaturated(nil)
			MacaroonLFDButton:GetNormalTexture():SetVertexColor(1,1,1)
			MacaroonLFDButton:GetPushedTexture():SetDesaturated(nil)
			MacaroonLFDButton:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-LFG-Down")
			MacaroonLFDButton:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight")
			MacaroonLFDButton:SetButtonState("NORMAL")
			MacaroonLFDButton.disabledTooltip = nil
		end

	end

	if (MacaroonEJButton and EncounterJournal and EncounterJournal:IsShown())  then

		MacaroonEJButton:SetButtonState("PUSHED", 1)

	elseif (MacaroonEJButton) then

		MacaroonEJButton:GetNormalTexture():SetDesaturated(nil)
		MacaroonEJButton:GetNormalTexture():SetVertexColor(1,1,1)
		MacaroonEJButton:GetPushedTexture():SetDesaturated(nil)
		MacaroonEJButton:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-EJ-Down")
		MacaroonEJButton:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight")
		MacaroonEJButton:SetButtonState("NORMAL")
		MacaroonEJButton.disabledTooltip = nil

	end

	if (MacaroonRaidButton and RaidFrame and RaidFrame:IsShown() and FriendsFrame and FriendsFrame:IsShown())  then

		MacaroonRaidButton:SetButtonState("PUSHED", 1)

	elseif (MacaroonRaidButton) then

		MacaroonRaidButton:GetNormalTexture():SetDesaturated(nil)
		MacaroonRaidButton:GetNormalTexture():SetVertexColor(1,1,1)
		MacaroonRaidButton:GetPushedTexture():SetDesaturated(nil)
		MacaroonRaidButton:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-Raid-Down")
		MacaroonRaidButton:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight")
		MacaroonRaidButton:SetButtonState("NORMAL")
		MacaroonRaidButton.disabledTooltip = nil

	end

	if (MacaroonHelpButton and HelpFrame:IsShown()) then

		MacaroonHelpButton:SetButtonState("PUSHED", 1)

	elseif (MacaroonHelpButton) then

		MacaroonHelpButton:SetButtonState("NORMAL")
	end

	if (MacaroonAchievementButton and AchievementFrame and AchievementFrame:IsShown()) then

		MacaroonAchievementButton:SetButtonState("PUSHED", 1)

	elseif (MacaroonAchievementButton) then

		if ((HasCompletedAnyAchievement() or IsInGuild()) and CanShowAchievementUI()) then

			MacaroonAchievementButton:GetNormalTexture():SetDesaturated(nil)
			MacaroonAchievementButton:GetNormalTexture():SetVertexColor(1,1,1)
			MacaroonAchievementButton:GetPushedTexture():SetDesaturated(nil)
			MacaroonAchievementButton:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-Achievement-Down")
			MacaroonAchievementButton:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight")
			MacaroonAchievementButton:SetButtonState("NORMAL")
			MacaroonAchievementButton.disabledTooltip = nil

		else

			MacaroonAchievementButton:GetNormalTexture():SetDesaturated(1)
			MacaroonAchievementButton:GetNormalTexture():SetVertexColor(0.5,0.5,0.5)
			MacaroonAchievementButton:GetPushedTexture():SetDesaturated(1)
			MacaroonAchievementButton:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-Achievement-Up")
			MacaroonAchievementButton:SetHighlightTexture("")
			MacaroonAchievementButton.disabledTooltip = "Feature becomes available after you earn your first achievement"

		end
	end


end

function M.CharacterButton_OnLoad(self)

	self.portrait = _G[self:GetName().."Portrait"]
	SetPortraitTexture(self.portrait, "player")

	self:SetNormalTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Up")
	self:SetPushedTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Down")
	self:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight")
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	self:RegisterEvent("UPDATE_BINDINGS")
	self.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0")
	self.newbieText = NEWBIE_TOOLTIP_CHARACTER

	menuElements[#menuElements+1] = self
end

function M.CharacterButton_OnMouseDown(self)

	if (self.down) then
		self.down = nil
		ToggleCharacter("PaperDollFrame")
		return
	end
	M.CharacterButton_SetPushed(self)
	self.down = 1
end

function M.CharacterButton_OnMouseUp(self)

	if (self.down) then
		self.down = nil
		if (self:IsMouseOver()) then
			ToggleCharacter("PaperDollFrame")
		else
			updateMicroButtons()
		end
		return
	end
	if (self:GetButtonState() == "NORMAL") then
		M.CharacterButton_SetPushed(self)
		self.down = 1
	else
		M.CharacterButton_SetNormal(self)
		self.down = 1
	end
end

function M.CharacterButton_OnEvent(self, event, ...)

	if (event == "UNIT_PORTRAIT_UPDATE") then

		if (... == "player") then
			SetPortraitTexture(self.portrait, ...)
		end

	elseif (event == "UPDATE_BINDINGS") then

		self.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0")
	end
end

function M.CharacterButton_SetPushed(self)
	self.portrait:SetTexCoord(0.2666, 0.8666, 0, 0.8333)
	self.portrait:SetAlpha(0.5)
end

function M.CharacterButton_SetNormal(self)
	self.portrait:SetTexCoord(0.2, 0.8, 0.0666, 0.9)
	self.portrait:SetAlpha(1.0)
end

function M.SpellbookButton_OnLoad(self)

	self:SetAttribute("type", "macro")
	self:SetAttribute("*macrotext*", "/click SpellbookMicroButton")
	self:RegisterEvent("UPDATE_BINDINGS")

	LoadMicroButtonTextures(self, "Spellbook")
	menuElements[#menuElements+1] = self
end

function M.SpellbookButton_OnClick(self)
	if (not InCombatLockdown()) then
		ToggleSpellBook(BOOKTYPE_SPELL)
	end
end

function M.SpellbookButton_OnEnter(self)
	self.tooltipText = MicroButtonTooltipText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK")
	GameTooltip_AddNewbieTip(self, self.tooltipText, 1.0, 1.0, 1.0, NEWBIE_TOOLTIP_SPELLBOOK)
end

function M.SpellbookButton_OnEvent(self, event, ...)
	self.tooltipText = MicroButtonTooltipText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK")
end

function M.TalentButton_OnLoad(self)

	LoadMicroButtonTextures(self, "Talents")

	self:SetAttribute("type", "macro")
	self:SetAttribute("*macrotext*", "/click TalentMicroButton")

	self.tooltipText = MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS")
	self.newbieText = NEWBIE_TOOLTIP_TALENTS
	self:RegisterEvent("PLAYER_LEVEL_UP")
	self:RegisterEvent("UPDATE_BINDINGS")
	self:RegisterEvent("UNIT_LEVEL")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	self:HookScript("OnEnter", function(self) if (self.disabledTooltip) then GameTooltip:AddLine(self.disabledTooltip, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true) GameTooltip:Show() end end)

	menuElements[#menuElements+1] = self
end

function M.TalentButton_OnEvent(self, event, ...)

	if (event == "PLAYER_LEVEL_UP") then

		UpdateMicroButtons()

		if (not CharacterFrame:IsShown()) then
			SetButtonPulse(self, 60, 1)
		end

	elseif (event == "UNIT_LEVEL" or event == "PLAYER_ENTERING_WORLD") then

		UpdateMicroButtons()

	elseif (event == "UPDATE_BINDINGS") then

		self.tooltipText =  MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS")
	end
end

function M.AchievementButton_OnLoad(self)
	LoadMicroButtonTextures(self, "Achievement")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UPDATE_BINDINGS")

	menuElements[#menuElements+1] = self
end

function M.AchievementButton_OnEvent(self, event, ...)

	if (event == "PLAYER_ENTERING_WORLD") then
		AchievementMicroButton_OnEvent(self, event, ...)
	elseif (event == "UPDATE_BINDINGS") then
		self.tooltipText =  MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS")
	end
end

function M.AchievementButton_OnClick(self)
	ToggleAchievementFrame()
end

function M.AchievementButton_OnEnter(self)
	self.tooltipText = MicroButtonTooltipText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT")
	GameTooltip_AddNewbieTip(self, self.tooltipText, 1.0, 1.0, 1.0, NEWBIE_TOOLTIP_ACHIEVEMENT)
	if (self.disabledTooltip) then
		GameTooltip:AddLine("\n"..self.disabledTooltip, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true)
	end
	GameTooltip:Show()
end

function M.QuestLogButton_OnLoad(self)
	LoadMicroButtonTextures(self, "Quest")
	self.tooltipText = MicroButtonTooltipText(QUESTLOG_BUTTON, "TOGGLEQUESTLOG")
	self.newbieText = NEWBIE_TOOLTIP_QUESTLOG

	menuElements[#menuElements+1] = self
end

function M.QuestLogButton_OnEvent(self, event, ...)
	self.tooltipText = MicroButtonTooltipText(QUESTLOG_BUTTON, "TOGGLEQUESTLOG")
end

function M.QuestLogButton_OnClick(self)
	ToggleFrame(QuestLogFrame)
end

--		MacaroonGuildButton.tabard:SetPoint("TOPLEFT", -1, -1) MacaroonGuildButton.tabard:SetAlpha(0.5)

function M.GuildButton_OnLoad(self)

	self:SetAttribute("type", "macro")
	self:SetAttribute("*macrotext*", "/click GuildMicroButton")
	self:SetScript("OnMouseDown", function(self) self.tabard:SetPoint("TOPLEFT", -1, -1) self.tabard:SetAlpha(0.5) end)
	self:RegisterEvent("UPDATE_BINDINGS")
	self:RegisterEvent("PLAYER_GUILD_UPDATE")

	LoadMicroButtonTextures(self, "Socials")
	self.tooltipText = MicroButtonTooltipText(GUILD, "TOGGLEGUILDTAB")
	self.newbieText = NEWBIE_TOOLTIP_GUILDTAB

	self:HookScript("OnEnter", function(self) if (self.disabledTooltip) then GameTooltip:AddLine(self.disabledTooltip, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true) GameTooltip:Show() end end)

	updateTabard(self)

	menuElements[#menuElements+1] = self
end

function M.GuildButton_OnEvent(self, event, ...)
	if (event == "UPDATE_BINDINGS") then
		self.tooltipText = MicroButtonTooltipText(GUILD, "TOGGLEGUILDTAB")
	elseif (event == "PLAYER_GUILD_UPDATE") then
		UpdateMicroButtons()
	end
end

function M.PVPButton_OnLoad(self)

	self:RegisterEvent("UPDATE_BINDINGS")
	self:SetNormalTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Up")
	self:SetPushedTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Down")
	self:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight")
	self.faction = _G[self:GetName().."Faction"]

	local factionGroup = UnitFactionGroup("player")

	if (factionGroup) then
		self.factionGroup = factionGroup
		self.faction:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..self.factionGroup)
	end

	self.tooltipText = MicroButtonTooltipText(PLAYER_V_PLAYER, "TOGGLECHARACTER4")
	self.newbieText = NEWBIE_TOOLTIP_PVP

	self:HookScript("OnEnter", function(self) if (self.disabledTooltip) then GameTooltip:AddLine(self.disabledTooltip, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true) GameTooltip:Show() end end)

	menuElements[#menuElements+1] = self
end

function M.PVPButton_OnEvent(self, event, ...)
	self.tooltipText = MicroButtonTooltipText(PLAYER_V_PLAYER, "TOGGLECHARACTER4")
	self.newbieText = NEWBIE_TOOLTIP_PVP
end

function M.PVPButton_OnMouseDown(self)

	if (self.disabledTooltip) then
		self.faction:SetVertexColor(1,1,1)
		return
	end

	if (self.down) then
		self.down = nil
		if (pvpFrame) then
			ToggleFrame(pvpFrame)
		end
		return
	end

	M.PVPButton_SetPushed(self)

	self.down = 1
end

function M.PVPButton_OnMouseUp(self)

	if (self.disabledTooltip) then
		self.faction:SetVertexColor(0.5,0.5,0.5)
		return
	end

	if (self.down) then
		self.down = nil
		if (self:IsMouseOver() and pvpFrame) then
			ToggleFrame(pvpFrame)
		else
			updateMicroButtons()
		end
		return
	end

	if (self:GetButtonState() == "NORMAL") then
		M.PVPButton_SetPushed(self)
	else
		M.PVPButton_SetNormal(self)
	end

	self.down = 1
end

function M.PVPButton_SetPushed(self)
	self.faction:SetPoint("TOP", self, "TOP", 5, -31)
	self.faction:SetAlpha(0.5)
end

function M.PVPButton_SetNormal(self)
	self.faction:SetPoint("TOP", self, "TOP", 6, -30)
	self.faction:SetAlpha(1.0)
end

function M.LFDButton_OnLoad(self)

	self:RegisterEvent("UPDATE_BINDINGS")
	self.tooltipText = MicroButtonTooltipText(DUNGEONS_BUTTON, "TOGGLELFGPARENT")
	self.newbieText = NEWBIE_TOOLTIP_LFGPARENT

	LoadMicroButtonTextures(self, "LFG")

	self:HookScript("OnEnter", function(self) if (self.disabledTooltip) then GameTooltip:AddLine(self.disabledTooltip, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true) GameTooltip:Show() end end)

	menuElements[#menuElements+1] = self
end

function M.LFDButton_OnEvent(self, event, ...)
	self.tooltipText = MicroButtonTooltipText(DUNGEONS_BUTTON, "TOGGLELFGPARENT")
	self.newbieText = NEWBIE_TOOLTIP_LFGPARENT
end

function M.LFDButton_OnClick(self)

	if (self.disabledTooltip) then
		return
	end

	if (ToggleLFDParentFrame) then
		ToggleLFDParentFrame()
	elseif (ToggleLFDParentFrame) then
		ToggleLFDParentFrame()
	end
end

function M.EJButton_OnLoad(self)

	self:RegisterEvent("UPDATE_BINDINGS")
	self.tooltipText = MicroButtonTooltipText(ENCOUNTER_JOURNAL, "TOGGLEENCOUNTERJOURNAL")
	self.newbieText = NEWBIE_TOOLTIP_ENCOUNTER_JOURNAL

	LoadMicroButtonTextures(self, "EJ")

	self:HookScript("OnEnter", function(self) if (self.disabledTooltip) then GameTooltip:AddLine(self.disabledTooltip, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true) GameTooltip:Show() end end)

	menuElements[#menuElements+1] = self

end

function M.EJButton_OnEvent(self, event, ...)

	self.tooltipText = MicroButtonTooltipText(ENCOUNTER_JOURNAL, "TOGGLEENCOUNTERJOURNAL")
	self.newbieText = NEWBIE_TOOLTIP_ENCOUNTER_JOURNAL

end

function M.EJButton_OnClick(self)

	if (self.disabledTooltip) then
		return
	end

	if (not EncounterJournal) then
		EncounterJournal_LoadUI()
	end

	if (EncounterJournal) then
		ToggleFrame(EncounterJournal)
	end
end

function M.RaidButton_OnLoad(self)

	self:RegisterEvent("UPDATE_BINDINGS")
	self.tooltipText = MicroButtonTooltipText(RAID, "TOGGLERAIDTAB")
	self.newbieText = NEWBIE_TOOLTIP_RAID

	LoadMicroButtonTextures(self, "Raid")

	self:HookScript("OnEnter", function(self) if (self.disabledTooltip) then GameTooltip:AddLine(self.disabledTooltip, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true) GameTooltip:Show() end end)

	menuElements[#menuElements+1] = self

end

function M.RaidButton_OnEvent(self, event, ...)

	self.tooltipText = MicroButtonTooltipText(RAID, "TOGGLERAIDTAB")
	self.newbieText = NEWBIE_TOOLTIP_RAID

end

function M.RaidButton_OnClick(self)

	ToggleRaidFrame()
end

function M.HelpButton_OnLoad(self)
	LoadMicroButtonTextures(self, "Help")
	self.tooltipText = HELP_BUTTON
	self.newbieText = NEWBIE_TOOLTIP_HELP

	menuElements[#menuElements+1] = self
end

function M.HelpButton_OnClick(self)
	ToggleHelpFrame()
end

function M.LatencyButton_OnLoad(self)

	self.hover = nil
	self.elapsed = 0
	self.overlay = _G[self:GetName().."Overlay"]
	self.overlay:SetWidth(self:GetWidth()+1)
	self.overlay:SetHeight(self:GetHeight())
	self.tooltipText = MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU")
	self.newbieText = NEWBIE_TOOLTIP_MAINMENU
	self:RegisterForClicks("LeftButtonDown", "RightButtonDown", "LeftButtonUp", "RightButtonUp")
	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("UPDATE_BINDINGS")

	menuElements[#menuElements+1] = self

end

function M.LatencyButton_OnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ...=="MacaroonXtras") then
		self.lastStart = 0
		if (SD) then
			self.enabled = SD.scriptProfile
		end
		GameMenuFrame:HookScript("OnShow", M.LatencyButton_SetPushed)
		GameMenuFrame:HookScript("OnHide", M.LatencyButton_SetNormal)
	end

	self.tooltipText = MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU")
end

function M.LatencyButton_OnClick(self, button, down)

	if (button == "RightButton") then

		if (IsShiftKeyDown()) then

			if (SD.scriptProfile) then

				SetCVar("scriptProfile", "0")
				SD.scriptProfile = false
			else

				SetCVar("scriptProfile", "1")
				SD.scriptProfile = true

			end

			ReloadUI()

		end

		if (not down) then

			if (self.alt_tooltip) then
				self.alt_tooltip = false
			else
				self.alt_tooltip = true
			end

			M.LatencyButton_SetNormal()
		else
			M.LatencyButton_SetPushed()
		end

		M.LatencyButton_OnEnter(self)

	elseif (IsShiftKeyDown()) then

		ReloadUI()

	else

		if (self.down) then
			self.down = nil;
			if (not GameMenuFrame:IsShown()) then
				CloseMenus()
				CloseAllWindows()
				PlaySound("igMainMenuOpen")
				ShowUIPanel(GameMenuFrame)
			else
				PlaySound("igMainMenuQuit")
				HideUIPanel(GameMenuFrame)
				M.LatencyButton_SetNormal()
			end
			if (InterfaceOptionsFrame:IsShown()) then
				InterfaceOptionsFrameCancel:Click()
			end
			return;
		end
		if (self:GetButtonState() == "NORMAL") then
			M.LatencyButton_SetPushed()
			self.down = 1;
		else

			self.down = 1;
		end
	end
end

function M.LatencyButton_OnUpdate(self, elapsed)

	self.elapsed = self.elapsed + elapsed

	if (self.elapsed > 2.5) then

		local r, g, rgbValue
		local bandwidthIn, bandwidthOut, latency = GetNetStats()

		if (latency <= 1000) then
			rgbValue = math.floor((latency/1000)*100)
		else
			rgbValue = 100
		end

		if (rgbValue < 50) then
			r=rgbValue/50; g=1-(rgbValue/100)
		else
			r=1; g=abs((rgbValue/100)-1)
		end

		self.overlay:SetVertexColor(r, g, 0)

		if (self.hover) then
			M.LatencyButton_OnEnter(self)
		end

		if (self.enabled) then

			UpdateAddOnCPUUsage()
			UpdateAddOnMemoryUsage()

			self.lastUsage = self.currUsage or 0

			self.currUsage = GetScriptCPUUsage()

			self.usage = self.currUsage - self.lastUsage
		end

		self.elapsed = 0
	end
end

function M.LatencyButton_OnEnter(self)

	self.hover = 1

	if (self.alt_tooltip and not MacaroonXtrasTooltip.wasShown) then

		M.LatencyButton_AltOnEnter(self)
		MacaroonXtrasTooltip:AddLine("\nLatency Button by LedMirage of MirageUI")
		GameTooltip:Hide()
		MacaroonXtrasTooltip:Show()

	elseif (self:IsMouseOver()) then

		MainMenuBarPerformanceBarFrame_OnEnter(self)
		GameTooltip:AddLine("\nLatency Button by LedMirage of MirageUI")
		MacaroonXtrasTooltip:Hide()
		GameTooltip:Show()
	end
end

function M.LatencyButton_AltOnEnter(self)

	if (not MacaroonXtrasTooltip:IsVisible()) then
		MacaroonXtrasTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
	end

	if (self.enabled) then

		MacaroonXtrasTooltip:SetText("Script Profiling is |cff00ff00Enabled|r", 1, 1, 1)
		MacaroonXtrasTooltip:AddLine("(Shift-RightClick to Disable)", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
		MacaroonXtrasTooltip:AddLine("\n|cfff00000Warning:|r Script Profiling Affects Game Performance\n", 1, 1, 1, 1)

		for i=1, GetNumAddOns() do

			local name,_,_,enabled = GetAddOnInfo(i)

			if (not addonData[i]) then
				addonData[i] = { name = name, enabled = enabled	}
			end

			local addon = addonData[i]

			addon.currMem = GetAddOnMemoryUsage(i)

			if (not addon.maxMem or addon.maxMem < addon.currMem) then
				addon.maxMem = addon.currMem
			end

			local currCPU = GetAddOnCPUUsage(i)

			if (addon.lastUsage) then

				addon.currCPU = (currCPU - addon.lastUsage)/2.5

				if (not addon.maxCPU or addon.maxCPU < addon.currCPU) then
					addon.maxCPU = addon.currCPU
				end
			else
				addon.currCPU = currCPU
			end

			if (self.usage > 0) then
				addon.percentCPU = addon.currCPU/self.usage * 100
			else
				addon.percentCPU = 0
			end

			addon.lastUsage = currCPU

			addon.avgCPU = currCPU / self.lastStart
		end

		if (self.usage) then
			MacaroonXtrasTooltip:AddLine("|cffffffff("..format("%.2f",(self.usage) / 2.5).."ms)|r Total Script CPU Time\n", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
		end

		ClearTable(sortData)

		for i,v in ipairs(addonData) do

			if (addonData[i].enabled) then

				local addLine = ""

				if (addonData[i].currCPU and addonData[i].currCPU > 0) then

					addLine = addLine..format("%.2f", addonData[i].currCPU).."ms/"..format("%.1f", addonData[i].percentCPU).."%)|r "

					local num = tonumber(addLine:match("^%d+"))

					if (num and num < 10) then
						addLine = "0"..addLine
					end

					if (addonData[i].name) then
						addLine = "|cffffffff("..addLine..addonData[i].name.." "
					end

					tinsert(sortData, addLine)
				end
			end
		end

		sort(sortData, function(a,b) return a>b end)

		for i,v in ipairs(sortData) do
			MacaroonXtrasTooltip:AddLine(v, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
		end
	else

		MacaroonXtrasTooltip:SetText("Script Profiling is |cfff00000Disabled|r", 1, 1, 1)
		MacaroonXtrasTooltip:AddLine("(Shift-RightClick to Enable)", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
		MacaroonXtrasTooltip:AddLine("\n|cfff00000Warning:|r Script Profiling Affects Game Performance\n", 1, 1, 1, 1)
	end
end

function M.LatencyButton_OnLeave(self)

	if (GameTooltip:IsVisible()) then
		self.hover = nil
		GameTooltip:Hide()
	end
end

function M.LatencyButton_SetPushed()
	MacaroonLatencyButtonOverlay:SetPoint("CENTER", MacaroonLatencyButton, "CENTER", -1, -2)
end

function M.LatencyButton_SetNormal()
	MacaroonLatencyButtonOverlay:SetPoint("CENTER", MacaroonLatencyButton, "CENTER", 0, -0.5)
end

local function updateFreeSlots(self)

	local totalSlots, totalFree, freeSlots, bagFamily = 0, 0

	for i=BACKPACK_CONTAINER, NUM_BAG_SLOTS do

		freeSlots, bagFamily = GetContainerNumFreeSlots(i)

		if (bagFamily == 0) then

			totalSlots = totalSlots + GetContainerNumSlots(i)
			totalFree = totalFree + freeSlots
		end
	end

	local rgbValue, r, g = math.floor((totalFree/SD.freeSlots)*100)

	if (rgbValue > 49) then
		r=(1-(rgbValue/100))+(1-(rgbValue/100))
		g=(rgbValue/100)+((1-(rgbValue/100))/2)
	else
		r=1; g=(rgbValue/100)*1.5
	end

	self.freeSlots = totalFree

	self.count:SetText(format("%s", totalFree))
	self.count:SetTextColor(r, g, 0)
end

function M.MacaroonBackpackButton_OnLoad(self)

	self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("CVAR_UPDATE")
	self:RegisterEvent("BAG_UPDATE")

	self.icon:SetTexture("Interface\\Buttons\\Button-Backpack-Up")
	--self.BlizzBP = MainMenuBarBackpackButton

	self.count = _G[self:GetName().."Count2"]
	self.icon = _G[self:GetName().."IconTexture"]
end

function M.MacaroonBackpackButton_OnReceiveDrag(self, button)

	if (not PutItemInBackpack()) then
		ToggleBackpack()
	end

	local isVisible

	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local frame = _G["ContainerFrame"..i]

		if (frame:GetID()==0 and frame:IsShown()) then
			isVisible = 1; break
		end
	end

	self:SetChecked(isVisible)
end

function M.MacaroonBackpackButton_OnEnter(self)

	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetText(BACKPACK_TOOLTIP, 1.0, 1.0, 1.0)

	local keyBinding = GetBindingKey("TOGGLEBACKPACK")

	if (keyBinding) then
		GameTooltip:AppendText(" "..NORMAL_FONT_COLOR_CODE.."("..keyBinding..")"..FONT_COLOR_CODE_CLOSE)
	end

	GameTooltip:AddLine(format(NUM_FREE_SLOTS, (self.freeSlots or 0)))

	GameTooltip:Show()
end

function M.MacaroonBackpackButton_OnLeave(self)
	GameTooltip:Hide()
end

function M.MacaroonBackpackButton_OnEvent(self, event, ...)

	if (event == "BAG_UPDATE") then

		if (... >= BACKPACK_CONTAINER and ... <= NUM_BAG_SLOTS) then
			updateFreeSlots(self)
		end

	elseif (event == "PLAYER_ENTERING_WORLD") then

		if (MacaroonMainMenuSlider4) then

			if (GetCVar("displayFreeBagSlots") == "1") then
				self.count:Show()
				MacaroonMainMenuSlider4:Enable()
				MacaroonMainMenuSlider4.text2:SetTextColor(1.0, 0.82, 0)
				MacaroonMainMenuSliderEdit4:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
				MacaroonMainMenuSliderEdit4:SetTextColor(1,1,1)
			else
				self.count:Hide()
				MacaroonMainMenuSlider4:Disable()
				MacaroonMainMenuSlider4.text2:SetTextColor(0.5,0.5,0.5)
				MacaroonMainMenuSliderEdit4:SetScript("OnEditFocusGained", function(self) self:ClearFocus() end)
				MacaroonMainMenuSliderEdit4:SetTextColor(0.5,0.5,0.5)
			end
		end

		updateFreeSlots(self)

		self.icon:SetTexture([[Interface\Buttons\Button-Backpack-Up]])

	elseif (event == "CVAR_UPDATE") then

		if (select(1,...) == "DISPLAY_FREE_BAG_SLOTS") then

			if (select(2,...) == "1") then
				self.count:Show()
				MacaroonMainMenuSlider4:Enable()
				MacaroonMainMenuSlider4.text2:SetTextColor(1.0, 0.82, 0)
			else
				self.count:Hide()
				MacaroonMainMenuSlider4:Disable()
				MacaroonMainMenuSlider4.text2:SetTextColor(0.5,0.5,0.5)
			end
		end
	end
end

function M.XtrasSetSaved()

	SD = MacaroonXtrasSavedState

	return SD
end

function M.XtrasButtonStorage_BuildOptions(self)

	local regions, dock, lock = { BankFramePurchaseInfo:GetRegions() }

	for k,v in pairs(regions) do
		if (v:GetObjectType() == "FontString") then
			if (v:GetText() == BANKSLOTPURCHASE_LABEL) then
				v:SetText("")
			end
		end
	end

	for i=1,2 do

		dock = CreateFrame("Frame", self:GetParent():GetName().."XtrasDock"..i, self, "MacaroonDockTemplate")

		dock:SetID(i)
		dock:SetFrameLevel(self:GetParent():GetFrameLevel()+2)
		dock:SetHeight(50)
		dock:SetScale(0.75)
		dock:Show()

		dock.config = M.GetBarDefaults()

		if (i==1) then
			dock.config.padData = { homestate = "2.5:0" }
			dock.reverse = true
			dock.updateFunc = bagbarUpdate
		else
			dock.config.padData = { homestate = "1:0" }
		end

		dock.config.barStrata = "TOOLTIP"
		dock.config.buttonStrata = "DIALOG"
		dock.config.showGrid = true
		dock.handler = dock
		dock.homestate = {}
		dock.hasAction = "Interface\\Buttons\\UI-Quickslot2"
		dock.noAction = "Interface\\Buttons\\UI-Quickslot"
		dock.parent = self

		dock.updateBar = function() end

		if (i==1) then
			dock.btnType = "MacaroonBagButton"
			dock:SetWidth(190)
			dock:SetPoint("LEFT", 10, 0)
			dock:RegisterEvent("BANKFRAME_OPENED")
			dock:RegisterEvent("BANKFRAME_CLOSED")
			dock:SetScript("OnEvent", function(self, event, ...)
				if (event == "BANKFRAME_CLOSED") then
					self:SetParent(dock.parent)
					self:ClearAllPoints()
					self:SetPoint("LEFT", 10, 0)
					M.XtrasUpdateButtonStorage()
					self:Show()
					self:SetScale(0.75)
				else
					if (BankFrame:IsVisible()) then
						self:SetParent("BankFrame")
						self:ClearAllPoints()
						self:SetPoint("BOTTOM", -8, 146)
						M.XtrasUpdateButtonStorage()
						self:Show()
						self:SetScale(1)
					end
				end
			end)
		else
			dock.btnType = "MacaroonMenuButton"
			dock:SetWidth(290)
			dock.config.columns = 11
			dock:SetPoint("RIGHT", -10, 0)
		end
	end
end

function M.XtrasUpdateButtonStorage()

	local count, list, dock = 0, ""

	for index,button in ipairs(M.BagButtons) do

		if (button[2] == 1) then
			button[1]:Show()
			list = list..button[1].id..";"
			count = count + 1
		end

	end

	dock = MacaroonButtonStorageXtrasDock1

	if (dock) then

		dock.config.buttonList.homestate = list
		dock.homestate.buttonCount = count

		M.UpdateShape(dock, true)
	end

	count, list = 0, ""

	for index,button in ipairs(M.MenuButtons) do

		if (button[2] == 1) then
			button[1]:Show()
			list = list..button[1].id..";"
			count = count + 1
		end

	end

	dock = MacaroonButtonStorageXtrasDock2

	if (dock) then

		dock.config.buttonList.homestate = list
		dock.homestate.buttonCount = count

		M.UpdateShape(dock, true, true)
	end

end

function M.XtrasEditor_OnLoad(self)
	self:RegisterEvent("ADDON_LOADED")
	M.XtrasEditor = self
	M.XtrasEditor.height = 300
end

function M.XtrasEditor_OnEvent(self)

	M.ObjectEdit_AddPanel(self, "alert")

	self.buttons = {}

	alertsEditor = self

end

local function xtrasDataUpdate(editor, object)

	if (not editor:IsVisible()) then
		return
	end

end

local function controlOnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ... == "MacaroonXtras") then

		if (PVPParentFrame) then
			pvpFrame = PVPParentFrame
		elseif (PVPFrame) then
			pvpFrame = PVPFrame
		end

		M.XtrasSetSaved()

		for k,v in pairs(defaultSD) do
			if (SD[k] == nil) then
				SD[k] = v
			end
		end

		bagElements[5] = MacaroonBackpackButton
		bagElements[4] = Macaroon_Bag0Slot
		bagElements[3] = Macaroon_Bag1Slot
		bagElements[2] = Macaroon_Bag2Slot
		bagElements[1] = Macaroon_Bag3Slot

		for k,v in pairs(bagElements) do
			v:SetWidth(32)
			v:SetHeight(32)
			v:GetNormalTexture():SetWidth(55)
			v:GetNormalTexture():SetHeight(55)
			v:GetNormalTexture():SetPoint("CENTER",0,0)
			_G[v:GetName().."IconTexture"]:ClearAllPoints()
			_G[v:GetName().."IconTexture"]:SetPoint("TOPLEFT", -1, 1)
			_G[v:GetName().."IconTexture"]:SetPoint("BOTTOMRIGHT")
		end

		hooksecurefunc("UpdateMicroButtons", updateMicroButtons)
		hooksecurefunc("ContainerFrame_OnShow", containerFrame_OnShow)
		hooksecurefunc("ContainerFrame_OnHide", containerFrame_OnHide)
		hooksecurefunc("ToggleBag", toggleBag)
		hooksecurefunc("ToggleBackpack", toggleBackpack)
		hooksecurefunc(Macaroon, "UpdateButtonStorage", M.XtrasUpdateButtonStorage)

		for i=1,13 do
			local frame = _G["ContainerFrame"..i]
			frame:HookScript("OnShow", containerFrame_OnShow)
			frame:HookScript("OnHide", containerFrame_OnHide)
		end

		local frame = CreateFrame("Slider", "$parentSlider4", MacaroonMainMenu, "MacaroonSliderTemplate1")
		frame:SetID(4)
		frame:SetWidth(335)
		frame:SetMinMaxValues(1, 4)
		frame.onshow_func = function(self)

			self:SetValue(SD.freeSlots)

			if (self.editbox) then
				self.editbox:SetText(format("%.0f",SD.freeSlots))
			end

			local totalSlots, bagFamily, _ = 0

			for i=BACKPACK_CONTAINER, NUM_BAG_SLOTS do
				_, bagFamily = GetContainerNumFreeSlots(i)
				if (bagFamily == 0) then
					totalSlots = totalSlots + GetContainerNumSlots(i)
				end
			end

			self:SetMinMaxValues(0,totalSlots)
		end

		frame.onvaluechanged_func = function(self)
			SD.freeSlots = floor(self:GetValue())
			if (self.editbox) then
				self.editbox:SetText(format("%.0f",SD.freeSlots))
			end
			if (M.MacaroonBackpackButton_OnEvent) then
				M.MacaroonBackpackButton_OnEvent(MacaroonBackpackButton, "PLAYER_ENTERING_WORLD")
			end
		end

		frame:SetPoint("TOP", MacaroonMainMenuSlider3, "BOTTOM", 0, -10)

		frame = CreateFrame("EditBox", "$parentSliderEdit4", MacaroonMainMenu, "MacaroonEditBoxTemplate3")
		frame:SetID(4)
		frame:SetPoint("LEFT", MacaroonMainMenuSlider4, "RIGHT", 1, 0)
		frame.slider = MacaroonMainMenuSlider4
		frame:SetScript("OnTabPressed", function(self) local num = tonumber(self:GetText())/200  if(num) then self.slider:SetValue(num) end self:ClearFocus() end)
		frame:SetScript("OnEnterPressed", function(self) local num = tonumber(self:GetText())/200  if(num) then self.slider:SetValue(num) end self:ClearFocus() end)

		MacaroonMainMenuSlider4.editbox = frame

		MacaroonMainMenuSliderBorder:SetHeight(125)

		M.ModuleIndex = M.ModuleIndex + 1

		M.CreateBarTypes.bag = {
			[1] = "Bagbars",
			[2] = SD,
			[3] = M.BagBars,
			[4] = M.BagButtons,
			[5] = "MacaroonBagButton",
			[6] = M.AddXtrasButton,
			[7] = M.SetXtrasButton,
			[8] = M.GetXtrasButtonDefaults,
			[9] = M.BagBarDefaults,
			[10] = "Bag Button",
			[11] = M.ModuleIndex.."Bag Bar"
		}

		M.ModuleIndex = M.ModuleIndex + 1

		M.CreateBarTypes.menu = {
			[1] = "Menubars",
			[2] = SD,
			[3] = M.MenuBars,
			[4] = M.MenuButtons,
			[5] = "MacaroonMenuButton",
			[6] = M.AddXtrasButton,
			[7] = M.SetXtrasButton,
			[8] = M.GetXtrasButtonDefaults,
			[9] = M.MenuBarDefaults,
			[10] = "Menu Button",
			[11] = M.ModuleIndex.."Menu Bar"
		}

		M.StatesToSave.xtras = M.XtrasSaveCurrentState
		M.SavedDataLoad.xtras = M.XtrasLoadSavedData
		M.SavedDataUpdate.xtras = M.XtrasUpdateElements
		M.SetSavedVars.xtras = M.XtrasSetSaved

		M.XtrasLoadSavedData(SD)

	elseif (event == "PLAYER_LOGIN") then

		M.XtrasUpdateButtonStorage()

	elseif (event == "PLAYER_ENTERING_WORLD" and not pew) then

		tinsert(M.ObjectDataUpdates, { M.XtrasEditor, xtrasDataUpdate })

		pew = true
	end
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", controlOnEvent)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
