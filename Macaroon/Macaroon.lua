--Macaroon, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

Macaroon = {
	SlashCommands = {},
	SlashHelp = {},
	SpellIndex = {},
	IconIndex = { [1] = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK" },
	CompIndex = {},
	ShowGrids = {},
	HideGrids = {},
	Panels = {},
	StatesToSave = {},
	SavedDataLoad = {},
	SavedDataUpdate = {},
	SetSavedVars = {},
	UpdateFunctions = {},
	Ypos = 90,
	maxActionID = 132,
	maxPetID = 10,
	ModuleIndex = 0,
}

MacaroonSavedState = {
	buttonLoc = { -0.85, -111.45 },
	buttonRadius = 87.5,
	firstRun = true,
	checkButtons = {
		[101] = 1,
		[102] = 1,
		[103] = 1,
		[104] = 1,
		[105] = 1,
		[106] = 1,
		[107] = 1,
	},
	bfskin = {},
	msqskin = {},
	bagOffsetX = 0,
	bagOffsetY = 70,
	bagScale = 1,
	selfCast = false,
	focusCast = false,
	rightClickTarget = false,
	panelScale = 1,
	throttle = 0.2,
	timerLimit = 4,
	snapToTol = 28,
	EditorWidth = 775,
	EditorHeight = 440,
	debug = {},
	fix100310 = false,
}

MacaroonSpecProfiles = {
	currSpec = 1,
	enabled = false,
	[1] = "",
	[2] = "",
}

MacaroonMacroMaster = {}

MacaroonMacroVault = {
	["Main Vault"] = {},
}

MacaroonItemCache = {}

local M = Macaroon

M.Points = { R = "RIGHT", L = "LEFT", T = "TOP", B = "BOTTOM", TL = "TOPLEFT", TR = "TOPRIGHT", BL = "BOTTOMLEFT", BR = "BOTTOMRIGHT", C = "CENTER" }

local opDepList, opDep = { "BarKeep", "Bartender4", "Dominos", "MagnetButtons", "nMainbar", "rActionBarStyler", "Orbs", "StellarBars", "Tukui", "XBar" }, false

local level, specialStringsUpdated, pew
local format = string.format

local handler = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")

function M.ClearTable(table)
	if (table) then
		for k in pairs(table) do
			table[k] = nil
		end
	end
end

function M.CopyTable(table)

	if (table == nil) then
		return
	end

	if (type(table) ~= "table") then
		return
	end

	local data = {}

	for k, v in pairs(table) do
		if (type(v) == "table") then
			data[k] = M.CopyTable(v)
		else
			data[k] = v
		end
	end

	return data
end

function M.GetChildrenAndRegions(frame)

	if (frame == nil) then
		return
	end

	local data, childData = {}, {}
	local children, regions = { frame:GetChildren() }, { frame:GetRegions() }

	for k,v in pairs(children) do
		tinsert(data, v:GetName())
		childData = M.GetChildrenAndRegions(v)
		for key,value in pairs(childData) do
			tinsert(data, value)
		end
	end

	for k,v in pairs(regions) do
		tinsert(data, v:GetName())
	end

	return data
end

local defaultSD = M.CopyTable(MacaroonSavedState)
local defaultSP = M.CopyTable(MacaroonSpecProfiles)
local defaultMV = M.CopyTable(MacaroonMacroVault)
local SD = M.CopyTable(MacaroonSavedState)

-- "()" indexes added because the Blizzard macro parser uses that to determine the difference of a spell versus a usable item if the two happen to have the same name.
-- I forgot this fact and removed using "()" and it made some macros not represent the right spell /sigh. This note is here so I do not forget again :P

local tempIconTable = {}

local function updateSpellIndex()

	wipe(M.SpellIndex)

	local i, spell, subName, altName, spellID, spellType, spellLvl, isPassive, icon, cost, powerType, _ = 1

	repeat
		spell, subName = GetSpellBookItemName(i, BOOKTYPE_SPELL)
		spellType, spellID = GetSpellBookItemInfo(i, BOOKTYPE_SPELL)
		spellLvl = GetSpellAvailableLevel(i, BOOKTYPE_SPELL)
		icon = GetSpellBookItemTexture(i, BOOKTYPE_SPELL)
		isPassive = IsPassiveSpell(i, BOOKTYPE_SPELL)

		if (spell and spellType ~= "FUTURESPELL") then

			altName, _, _, cost, _, powerType = GetSpellInfo(spellID)

			if (subName and #subName > 0) then
				M.SpellIndex[(spell.."("..subName..")"):lower()] = { i, BOOKTYPE_SPELL, spell, subName, spellID, spellType, spellLvl, isPassive, icon, cost, powerType }
			else
				M.SpellIndex[(spell):lower()] = { i, BOOKTYPE_SPELL, spell, nil, spellID, spellType, spellLvl, isPassive, icon, cost, powerType }
				M.SpellIndex[(spell):lower().."()"] = { i, BOOKTYPE_SPELL, spell, nil, spellID, spellType, spellLvl, isPassive, icon, cost, powerType }
			end

			if (altName and altName ~= spell) then

				if (subName and #subName > 0) then
					M.SpellIndex[(altName.."("..subName..")"):lower()] = { i, BOOKTYPE_SPELL, spell, subName, spellID, spellType, spellLvl, isPassive, icon, cost, powerType }
				else
					M.SpellIndex[(altName):lower()] = { i, BOOKTYPE_SPELL, spell, nil, spellID, spellType, spellLvl, isPassive, icon, cost, powerType }
					M.SpellIndex[(altName):lower().."()"] = { i, BOOKTYPE_SPELL, spell, nil, spellID, spellType, spellLvl, isPassive, icon, cost, powerType }
				end
			end

			if (spellID) then
				M.SpellIndex[spellID] = { i, BOOKTYPE_SPELL, spell, nil, spellID, spellType, spellLvl, isPassive, icon, cost, powerType }
			end

	   		if (icon and not tempIconTable[icon:upper()]) then
	   			M.IconIndex[#M.IconIndex+1] = icon:upper()
	   			tempIconTable[icon:upper()] = true
	   		end
   		end

   		i = i + 1

   	until (not spell)

	i = 1

	repeat
		spell, subName = GetSpellBookItemName(i, BOOKTYPE_PET)
		spellType, spellID = GetSpellBookItemInfo(i, BOOKTYPE_PET)
		spellLvl = GetSpellAvailableLevel(i, BOOKTYPE_PET)
		icon = GetSpellBookItemTexture(i, BOOKTYPE_PET)
		isPassive = IsPassiveSpell(i, BOOKTYPE_PET)

		if (spell and spellType ~= "FUTURESPELL") then

			_, _, icon, cost, _, powerType = GetSpellInfo(spell)

			if (subName and #subName > 0) then
				M.SpellIndex[(spell.."("..subName..")"):lower()] = { i, BOOKTYPE_PET, spell, subName, spellID, spellType, spellLvl, isPassive, icon, cost, powerType }
			else
				M.SpellIndex[(spell):lower()] = { i, BOOKTYPE_PET, spell, nil, spellID, spellType, spellLvl, isPassive, icon, cost, powerType }
				M.SpellIndex[(spell):lower().."()"] = { i, BOOKTYPE_SPELL, spell, nil, spellID, spellType, spellLvl, isPassive, icon, cost, powerType }
			end

			if (spellID) then
				M.SpellIndex[spellID] = { i, BOOKTYPE_PET, spell, nil, spellID, spellType, spellLvl, isPassive, icon, cost, powerType }
			end

	   		if (icon and not tempIconTable[icon:upper()]) then
	   			M.IconIndex[#M.IconIndex+1] = icon:upper()
	   			tempIconTable[icon:upper()] = true
	   		end

   		end

   		i = i + 1

   	until (not spell)

	-- a lot of work to associate the Call Pet spell with the pet's name so that tooltips work on Call Pet spells. /sigh
	local _, _, numSlots, isKnown = GetFlyoutInfo(9)
	local petIndex, petName

	for i=1, numSlots do

		spellID, isKnown = GetFlyoutSlotInfo(9, i)
		petIndex, petName = GetCallPetSpellInfo(spellID)

		if (isKnown and petIndex and petName and #petName > 0) then

			spell = GetSpellInfo(spellID)

			for k,v in pairs(M.SpellIndex) do
				if ((v[3]):find(petName.."$")) then
					M.SpellIndex[(spell):lower()] = { v[1], v[2], v[3], v[4], spellID, v[6], v[7], v[8], v[9], v[10], v[11] }
					M.SpellIndex[(spell):lower().."()"] = { v[1], v[2], v[3], v[4], spellID, v[6], v[7], v[8], v[9], v[10], v[11] }
					M.SpellIndex[spellID] = { v[1], v[2], v[3], v[4], spellID, v[6], v[7], v[8], v[9], v[10], v[11] }
				end
			end
		end
	end

	-- maybe a temp fix to get the Sunfire spell to show for balance druids
	if (M.class == "DRUID") then
		local spell, _, icon, cost, _, powerType = GetSpellInfo(93402)
		if (M.SpellIndex[8921]) then
			M.SpellIndex[(spell):lower()] = { M.SpellIndex[8921][1], M.SpellIndex[8921][2], spell, nil, 93402, "SPELL", M.SpellIndex[8921][7], nil, icon, cost, powerType}
			M.SpellIndex[(spell):lower().."()"] = { M.SpellIndex[8921][1], M.SpellIndex[8921][2], spell, nil, 93402, "SPELL", M.SpellIndex[8921][7], nil, icon, cost, powerType }
			M.SpellIndex[93402] = { M.SpellIndex[8921][1], M.SpellIndex[8921][2], spell, nil, 93402, "SPELL", M.SpellIndex[8921][7], nil, icon, cost, powerType }
		end
	end
end

M.UpdateSpells = updateSpellIndex

local function updateCompanionData()

	local creatureID, creatureName, spellID, icon, spell

	for i=1,GetNumCompanions("CRITTER") do

		creatureID, creatureName, spellID, icon = GetCompanionInfo("CRITTER", i)

		if (spellID) then

			spell = GetSpellInfo(spellID)

			if (spell) then

				M.CompIndex[spell:lower()] = { "CRITTER", i, creatureID, creatureName, spellID, icon }
				M.CompIndex[spell:lower().."()"] = { "CRITTER", i, creatureID, creatureName, spellID, icon }
				M.CompIndex[spellID] = { "CRITTER", i, creatureID, creatureName, spellID, icon }

		   		if (icon and not tempIconTable[icon:upper()]) then
		   			M.IconIndex[#M.IconIndex+1] = icon:upper()
		   			tempIconTable[icon:upper()] = true
		   		end
			end
		end
	end

	for i=1,GetNumCompanions("MOUNT") do

		creatureID, creatureName, spellID, icon = GetCompanionInfo("MOUNT", i)

		if (spellID) then

			spell = GetSpellInfo(spellID)

			if (spell) then

				M.CompIndex[spell:lower()] = { "MOUNT", i, creatureID, creatureName, spellID, icon }
				M.CompIndex[spell:lower().."()"] = { "MOUNT", i, creatureID, creatureName, spellID, icon }
				M.CompIndex[spellID] = { "MOUNT", i, creatureID, creatureName, spellID, icon }

		   		if (icon and not tempIconTable[icon:upper()]) then
		   			M.IconIndex[#M.IconIndex+1] = icon:upper()
		   			tempIconTable[icon:upper()] = true
		   		end
			end
		end
	end
end

local tempIconIndex = {}

local function updateIconIndex()

	local icon

	wipe(tempIconIndex)

	GetMacroIcons(tempIconIndex)
	--GetMacroItemIcons(tempIconIndex)

	for k,v in ipairs(tempIconIndex) do

		icon = "INTERFACE\\ICONS\\"..v:upper()

   		if (icon and not tempIconTable[icon:upper()]) then
   			M.IconIndex[#M.IconIndex+1] = icon:upper()
   			tempIconTable[icon:upper()] = true
   		end
   	end

   	wipe(tempIconIndex)
end

local function updateShapeshiftStrings()

	if (UnitClass("player") == M.Strings.DRUID or
	    UnitClass("player") == M.Strings.PRIEST or
	    UnitClass("player") == M.Strings.ROGUE or
	    UnitClass("player") == M.Strings.WARRIOR or
	    UnitClass("player") == M.Strings.WARLOCK) then

		local _, name

		for i=1,GetNumShapeshiftForms() do

			_, name = GetShapeshiftFormInfo(i)

			if (name) then
				M.Strings.STATES["stance"..i] = name
			end
		end

		if (not specialStringsUpdated) then

			if (UnitClass("player") == M.Strings.DRUID) then

				local origString, index, nextString = M.Strings.DRUID_PROWL, 1

				while (M.Strings["BARSTATE_"..index]) do
					index = index + 1
				end

				M.Strings.STATES.stance0 = M.Strings.DRUID_STANCE0
				M.Strings.STATES.stance8 = M.Strings.DRUID_PROWL

				index = 4

				while (M.Strings["BARSTATE_"..index]) do

					nextString = M.Strings["BARSTATE_"..index]

					M.Strings["BARSTATE_"..index] = origString

					origString = nextString

					index = index + 1
				end

				M.Strings["BARSTATE_"..index] = origString

			elseif (UnitClass("player") == M.Strings.PRIEST) then

				M.Strings.STATES.stance0 = M.Strings.PRIEST_HEALER

			elseif (UnitClass("player") == M.Strings.ROGUE) then

				M.ManagedStates.stance.states = M.ManagedStates.stance.states:gsub("%[stance:1%]", "[stance:1/2]")
				M.Strings.STATES.stance0 = M.Strings.ROGUE_ATTACK

			elseif (UnitClass("player") == M.Strings.WARLOCK) then

				M.Strings.STATES.stance0 = M.Strings.WARLOCK_CASTER

			elseif (UnitClass("player") == M.Strings.WARRIOR) then

				M.Strings.STATES.stance0 = nil
				M.ManagedStates.stance.homestate = "stance1"
			end

			specialStringsUpdated = true
		end
	else

		M.Strings.BARSTATE_2 = "exclude"
		M.Strings.STATES.stance0 = nil
	end
end

local function printSlashHelp()

	DEFAULT_CHAT_FRAME:AddMessage(M.Strings.SLASH_HINT1)
	DEFAULT_CHAT_FRAME:AddMessage(M.Strings.SLASH_HINT2)

	for k,v in ipairs(M.SlashHelp) do
		DEFAULT_CHAT_FRAME:AddMessage(v)
	end
end

local function slashHandler(msg)

	local commands = {}

	if ((not msg) or (strlen(msg) <= 0)) then

		printSlashHelp()

		return
	end

	(msg):gsub("(%S+)", function(cmd) tinsert(commands, cmd) end)

	if (M.SlashCommands[commands[1]]) then

		local command

		for k,v in ipairs(commands) do
			if (k ~= 1) then
				if (not command) then
					command = v
				else
					command = command.." "..v
				end
			end
		end

		if (commands) then
			M.SlashCommands[commands[1]][2](command)
		end
	else
		printSlashHelp()
	end

end

local function macUpdateContainerFrameAnchors()

	if (SD.checkButtons[106]) then

		if (not SD.bagScale) then
			SD.bagScale = 1
		end

		local frame, xOffset, yOffset, screenHeight, freeScreenHeight, leftMostPoint, column;
		local screenWidth = GetScreenWidth()
		local bagScale = 1;
		local leftLimit = 0;

		if ( BankFrame:IsShown() ) then
			leftLimit = BankFrame:GetRight() - 25;
		end

		if (SD.bagScale == 1) then

			while ( bagScale > CONTAINER_SCALE ) do
				screenHeight = GetScreenHeight() / bagScale;
				-- Adjust the start anchor for bags depending on the multibars
				xOffset = CONTAINER_OFFSET_X / bagScale;
				yOffset = CONTAINER_OFFSET_Y / bagScale;
				-- freeScreenHeight determines when to start a new column of bags
				freeScreenHeight = screenHeight - yOffset;
				leftMostPoint = screenWidth - xOffset;
				column = 1;
				local frameHeight;
				for index, frameName in ipairs(ContainerFrame1.bags) do
					frameHeight = _G[frameName]:GetHeight()
					if ( freeScreenHeight < frameHeight ) then
						-- Start a new column
						column = column + 1;
						leftMostPoint = screenWidth - ( column * CONTAINER_WIDTH * bagScale ) - xOffset;
						freeScreenHeight = screenHeight - yOffset;
					end
					freeScreenHeight = freeScreenHeight - frameHeight - VISIBLE_CONTAINER_SPACING;
				end
				if ( leftMostPoint < leftLimit ) then
					bagScale = bagScale - 0.01;
				else
					break;
				end
			end

			if ( bagScale < CONTAINER_SCALE ) then
				bagScale = CONTAINER_SCALE;
			end
		else
			bagScale = SD.bagScale
		end

		screenHeight = GetScreenHeight() / bagScale;
		xOffset = SD.bagOffsetX / bagScale;
		yOffset = SD.bagOffsetY / bagScale;
		freeScreenHeight = screenHeight - yOffset;
		column = 0;

		for index, frameName in ipairs(ContainerFrame1.bags) do
			frame = _G[frameName]
			frame:SetScale(bagScale)
			frame:ClearAllPoints()
			if ( index == 1 ) then
				-- First bag
				frame:SetPoint("BOTTOMRIGHT", frame:GetParent(), "BOTTOMRIGHT", -xOffset, yOffset )
			elseif ( freeScreenHeight < frame:GetHeight() ) then
				-- Start a new column
				column = column + 1;
				freeScreenHeight = screenHeight - yOffset;
				frame:SetPoint("BOTTOMRIGHT", frame:GetParent(), "BOTTOMRIGHT", -(column * CONTAINER_WIDTH) - xOffset, yOffset )
			else
				-- Anchor to the previous bag
				frame:SetPoint("BOTTOMRIGHT", ContainerFrame1.bags[index - 1], "TOPRIGHT", 0, CONTAINER_SPACING)
			end
			freeScreenHeight = freeScreenHeight - frame:GetHeight() - VISIBLE_CONTAINER_SPACING;
		end
	end
end

M.CheckbuttonOptions = {
	[101] = function(self)

			if (opDep) then

				SD.checkButtons[self:GetID()] = nil

				self:SetChecked(nil)
				self:Disable()
				self.text:SetTextColor(0.5,0.5,0.5)

			elseif (SD.checkButtons[self:GetID()]) then

				if (self.point) then
					MainMenuBar:SetPoint(unpack(self.point))
				else
					MainMenuBar:SetPoint("BOTTOM", 0, 0)
				end


				MainMenuBar_OnLoad(MainMenuBar)
				MainMenuBar:Show()

				MainMenuBar_OnLoad(MainMenuBarArtFrame)

				if (GetNumShapeshiftForms() > 0) then
					ShapeshiftBar_OnLoad(ShapeshiftBarFrame)
				else
					ShapeshiftBarFrame:UnregisterAllEvents()
				end

				BonusActionBar_OnLoad(BonusActionBarFrame)

				PossessBar_OnLoad(PossessBarFrame)

				M.CheckbuttonOptions[102](MacaroonMainMenuCheck102)

			else

				self.point = { MainMenuBar:GetPoint() }

				MainMenuBar:SetPoint("BOTTOM", 0, -200)
				MainMenuBar:UnregisterAllEvents()
				MainMenuBar:Hide()

				MainMenuBarArtFrame:UnregisterEvent("BAG_UPDATE");
				MainMenuBarArtFrame:UnregisterEvent("ACTIONBAR_PAGE_CHANGED");

				ShapeshiftBarFrame:UnregisterAllEvents()
				ShapeshiftBarFrame:Hide()

				BonusActionBarFrame:UnregisterAllEvents()
				BonusActionBarFrame:Hide()

				PossessBarFrame:UnregisterAllEvents()
				PossessBarFrame:Hide()

				RegisterStateDriver(MainMenuBar, "visibility", "hide")
				RegisterStateDriver(ShapeshiftBarFrame, "visibility", "hide")
				RegisterStateDriver(PossessBarFrame, "visibility", "hide")

				M.CheckbuttonOptions[102](MacaroonMainMenuCheck102)

			end

		end,
	[102] = function(self)

			if (opDep) then

				SD.checkButtons[self:GetID()] = nil

				self:SetChecked(nil)
				self:Disable()
				self.text:SetTextColor(0.5,0.5,0.5)

			elseif (SD.checkButtons[self:GetID()]) then

				local button
				for i=1, VEHICLE_MAX_ACTIONBUTTONS do
					button = _G["VehicleMenuBarActionButton"..i]
					handler:WrapScript(button, "OnShow", [[
						local key = GetBindingKey("ACTIONBUTTON"..self:GetID())
						if (key) then
							self:SetBindingClick(true, key, self:GetName())
						end
					]])
					handler:WrapScript(button, "OnHide", [[
						local key = GetBindingKey("ACTIONBUTTON"..self:GetID())
						if (key) then
							self:ClearBinding(key)
						end
					]])
				end

				MainMenuBarArtFrame:RegisterEvent("UNIT_ENTERING_VEHICLE")
				MainMenuBarArtFrame:RegisterEvent("UNIT_ENTERED_VEHICLE")
				MainMenuBarArtFrame:RegisterEvent("UNIT_EXITING_VEHICLE")
				MainMenuBarArtFrame:RegisterEvent("UNIT_EXITED_VEHICLE")
				MainMenuBarArtFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

			else

				local button
				for i=1, VEHICLE_MAX_ACTIONBUTTONS do
					button = _G["VehicleMenuBarActionButton"..i]
					handler:UnwrapScript(button, "OnShow")
					handler:UnwrapScript(button, "OnHide")
				end

				MainMenuBarArtFrame:UnregisterEvent("UNIT_ENTERING_VEHICLE")
				MainMenuBarArtFrame:UnregisterEvent("UNIT_ENTERED_VEHICLE")
				MainMenuBarArtFrame:UnregisterEvent("UNIT_EXITING_VEHICLE")
				MainMenuBarArtFrame:UnregisterEvent("UNIT_EXITED_VEHICLE")
				MainMenuBarArtFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
			end
	end,
	[105] = function(self)
			if (SD.checkButtons[self:GetID()]) then
				MacaroonMinimapButton:Show()
			else
				MacaroonMinimapButton:Hide()
			end
	end,
	[106] = function(self)
			if (self:GetChecked()) then
				MacaroonMainMenuSlider1:Enable()
				MacaroonMainMenuSlider1.text2:SetTextColor(1.0,0.82,0.0)
				MacaroonMainMenuSliderEdit1:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
				MacaroonMainMenuSliderEdit1:SetTextColor(1,1,1)
				MacaroonMainMenuSlider2:Enable()
				MacaroonMainMenuSlider2.text2:SetTextColor(1.0,0.82,0.0)
				MacaroonMainMenuSliderEdit2:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
				MacaroonMainMenuSliderEdit2:SetTextColor(1,1,1)
				MacaroonMainMenuSlider3:Enable()
				MacaroonMainMenuSlider3.text2:SetTextColor(1.0,0.82,0.0)
				MacaroonMainMenuSliderEdit3:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
				MacaroonMainMenuSliderEdit3:SetTextColor(1,1,1)
			else
				MacaroonMainMenuSlider1:Disable()
				MacaroonMainMenuSlider1.text2:SetTextColor(0.5,0.5,0.5)
				MacaroonMainMenuSliderEdit1:SetScript("OnEditFocusGained", function(self) self:ClearFocus() end)
				MacaroonMainMenuSliderEdit1:SetTextColor(0.5,0.5,0.5)
				MacaroonMainMenuSlider2:Disable()
				MacaroonMainMenuSlider2.text2:SetTextColor(0.5,0.5,0.5)
				MacaroonMainMenuSliderEdit2:SetScript("OnEditFocusGained", function(self) self:ClearFocus() end)
				MacaroonMainMenuSliderEdit2:SetTextColor(0.5,0.5,0.5)
				MacaroonMainMenuSlider3:Disable()
				MacaroonMainMenuSlider3.text2:SetTextColor(0.5,0.5,0.5)
				MacaroonMainMenuSliderEdit3:SetScript("OnEditFocusGained", function(self) self:ClearFocus() end)
				MacaroonMainMenuSliderEdit3:SetTextColor(0.5,0.5,0.5)
			end

			updateContainerFrameAnchors()
	end,
}

local sliderMinMax = {
	[1] = { min = 0, max = GetScreenWidth()-ContainerFrame1:GetWidth()*ContainerFrame1:GetEffectiveScale() },
	[2] = { min = 0, max = GetScreenHeight()-ContainerFrame1:GetHeight()*ContainerFrame1:GetEffectiveScale() },
	[3] = { min = 0.2, max = 2 },
}

local sliderOnShow = {
	[1] = function(self)
			if (SD.checkButtons[106]) then
				self:Enable()
				self.text2:SetTextColor(1.0,0.82,0.0)
				self:SetValue(SD.bagOffsetX)
				if (self.editbox) then
					self.editbox:SetText(format("%.1f",SD.bagOffsetX))
				end
			else
				self:SetValue(SD.bagOffsetX)
				self.text2:SetTextColor(0.5,0.5,0.5)
				self:Disable()
			end
	end,
	[2] = function(self)
			if (SD.checkButtons[106]) then
				self:Enable()
				self.text2:SetTextColor(1.0,0.82,0.0)
				self:SetValue(SD.bagOffsetY)
				if (self.editbox) then
					self.editbox:SetText(format("%.1f",SD.bagOffsetY))
				end
			else
				self:SetValue(SD.bagOffsetY)
				self.text2:SetTextColor(0.5,0.5,0.5)
				self:Disable()
			end
	end,
	[3] = function(self)
			if (SD.checkButtons[106]) then
				self:Enable()
				self.text2:SetTextColor(1.0,0.82,0.0)
				self:SetValue(SD.bagScale)
				if (self.editbox) then
					self.editbox:SetText(format("%.1f",SD.bagScale))
				end
			else
				self:SetValue(SD.bagScale)
				self.text2:SetTextColor(0.5,0.5,0.5)
				self:Disable()
			end
	end,
}

local sliderOnValueChanged = {
	[1] = function(self)
			SD.bagOffsetX = self:GetValue()
			if (self.editbox) then
				self.editbox:SetText(format("%.1f",SD.bagOffsetX))
			end
			updateContainerFrameAnchors()
	end,
	[2] = function(self)
			SD.bagOffsetY = self:GetValue()
			if (self.editbox) then
				self.editbox:SetText(format("%.1f",SD.bagOffsetY))
			end
			updateContainerFrameAnchors()
	end,
	[3] = function(self)
			SD.bagScale = self:GetValue()
			if (self.editbox) then
				self.editbox:SetText(format("%.1f",SD.bagScale))
			end
			updateContainerFrameAnchors()
	end,
}

function M.OpenMainMenu()
	if (MacaroonMainMenu:IsVisible()) then
		InterfaceOptionsFrameOkay_OnClick()
	else
		InterfaceOptionsFrame_OpenToCategory(MacaroonMainMenu)
	end
end

function M.OpenStorage()
	if (MacaroonButtonStorage:IsVisible()) then
		InterfaceOptionsFrameOkay_OnClick()
	else
		InterfaceOptionsFrame_OpenToCategory(MacaroonButtonStorage)
	end
end

function M.OpenProfiles()

	if (IsAddOnLoaded("MacaroonProfiles")) then
		if (MacaroonProfileManager:IsVisible()) then
			InterfaceOptionsFrameOkay_OnClick()
		else
			InterfaceOptionsFrame_OpenToCategory(MacaroonMainMenu)
			InterfaceOptionsFrame_OpenToCategory(MacaroonProfileManager)
			M.ProfilesScrollFrameUpdate()
		end
	else
		LoadAddOn("MacaroonProfiles")

		if (M.ProfilesScrollFrameUpdate) then
			InterfaceOptionsFrame_OpenToCategory(MacaroonMainMenu)
			InterfaceOptionsFrame_OpenToCategory(MacaroonProfileManager)
			M.ProfilesScrollFrameUpdate()
		end
	end
end

function M.SetTimerLimit(msg)

	local limit = tonumber(msg:match("%d+"))

	if (limit and limit > 0) then
		SD.timerLimit = limit
		print("Timer limit set to "..SD.timerLimit.." seconds")
	else
		print("Invalid timer limit")
	end

end

function M.BarLock()

	local lock

	for k,v in pairs(M.BarIndex) do
		if (not lock) then
			lock = v.config.barLock
		end
	end

	if (lock) then
		for k,v in pairs(M.BarIndex) do
			v.config.barLock = false
		end
		PlaySound("igMainMenuOptionCheckBoxOff")
		MacaroonMessageFrame:AddMessage(M.Strings.ALL_BARS_UNLOCKED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
	else
		for k,v in pairs(M.BarIndex) do
			v.config.barLock = true
		end
		PlaySound("igMainMenuOptionCheckBoxOn")
		MacaroonMessageFrame:AddMessage(M.Strings.ALL_BARS_LOCKED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
	end

	M.BarEditorUpdateData(MacaroonBarEditor)

end

function M.LoadFromProfile(name)

	if (not IsAddOnLoaded("MacaroonProfiles")) then
		LoadAddOn("MacaroonProfiles")
		M.ProfilesScrollFrameUpdate()
	end

	M.LoadProfile(name)
end

function M.EditBox_PopUpInitialize(popupFrame, data)

	popupFrame.func = M.PopUp_Update
	popupFrame.data = data

	M.PopUp_Update(popupFrame)
end

function M.PopUp_Update(popupFrame)

	local data, columns, optionText = popupFrame.data, 1
	local count, height, width, widthMult, option, lastOption, lastAnchor = 1,0, popupFrame:GetParent():GetWidth(), 1, nil, nil, nil

	if (popupFrame.options) then
		for k,v in pairs(popupFrame.options) do
			v:Hide()
		end
	end

	popupFrame.array = {}

	if (not data) then
		return
	end

	for k,v in pairs(data) do

		if (type(v) == "string") then
			popupFrame.array[count] = k..","..v
		else
			popupFrame.array[count] = k
		end

		count = count + 1
	end

	table.sort(popupFrame.array)

	count = 1

	columns = (math.ceil(#popupFrame.array/20)) or 1

	for i=1,#popupFrame.array do

		popupFrame.array[i] = gsub(popupFrame.array[i], "%s+", " ")
		popupFrame.array[i] = gsub(popupFrame.array[i], "^%s+", "")

		if (not popupFrame.options[i]) then
			option = CreateFrame("Button", popupFrame:GetName().."Option"..i, popupFrame, "MacaroonButtonTemplate3")
			option:SetHeight(14)

			popupFrame.options[i] = option
		else
			option = _G[popupFrame:GetName().."Option"..i]
			popupFrame.options[i] = option
		end

		optionText = _G[option:GetName().."Text"]

		optionText:SetText(popupFrame.array[i]:match("^[^,]+"))

		option.value = popupFrame.array[i]:match("[^,]+$")

		if (optionText:GetWidth()+20 > width and optionText:GetWidth()+20 < 250) then
			width = _G[option:GetName().."Text"]:GetWidth() + 20
		end

		option:ClearAllPoints()

		if (count == 1) then
			if (lastAnchor) then
				option:SetPoint("LEFT", lastAnchor, "RIGHT", 0, 0)
				lastOption = option
				lastAnchor = option

			else
				option:SetPoint("TOPLEFT", popupFrame, "TOPLEFT", 0, -5)
				lastOption = option
				lastAnchor = option
			end
		else
			option:SetPoint("TOP", lastOption, "BOTTOM", 0, -1)
			lastOption = option
		end

		if (widthMult == 1) then
			height = height + 15
		end

		count = count + 1

		if (count > math.ceil(#popupFrame.array/columns) and widthMult < columns and columns > 1) then
			widthMult = widthMult + 1
			count = 1
		end

		option:Show()
	end

	if (popupFrame.options) then
		for k,v in pairs(popupFrame.options) do
			v:SetWidth(width)
		end
	end

	popupFrame:SetWidth(width * widthMult)

	if (popupFrame:GetParent():GetHeight() > height + 10) then
		popupFrame:SetHeight(popupFrame:GetParent():GetHeight())
	else
		popupFrame:SetHeight(height + 10)
	end
end

local function selfCast_OnTextChanged(self)

	if (not self.show) then

		if (self:GetText() == "-none-") then
			SD.selfCast = false
		else
			SD.selfCast = self:GetText()

			for k,v in pairs(M.BarIndex) do
				v.updateBar(v, true)
			end
		end

		M.UpdateAutoMacros()
	end

	self.show = nil

end

local function selfCast_OnShow(self)

	self.onshow = true

	if (SD.selfCast) then
		self:SetText(SD.selfCast)
	else
		self:SetText("-none-")
	end

	local data = {
		["-none-"] = false,
		["Alt Cast"] = "alt",
		["Ctrl Cast"] = "ctrl",
		["Shift Cast"] = "shift",
	}

	M.EditBox_PopUpInitialize(self.popup, data)

	self.show = true

	self:SetScript("OnTextChanged", selfCast_OnTextChanged)
end

local function focusCast_OnTextChanged(self)

	if (not self.show) then

		if (self:GetText() == "-none-") then
			SD.focusCast = false
		else
			SD.focusCast = self:GetText()

			for k,v in pairs(M.BarIndex) do
				v.updateBar(v, true)
			end
		end

		M.UpdateAutoMacros()
	end

	self.show = nil

end

local function focusCast_OnShow(self)

	self.onshow = true

	if (SD.focusCast) then
		self:SetText(SD.focusCast)
	else
		self:SetText("-none-")
	end

	local data = {
		["-none-"] = false,
		["Alt Cast"] = "alt",
		["Ctrl Cast"] = "ctrl",
		["Shift Cast"] = "shift",
	}

	M.EditBox_PopUpInitialize(self.popup, data)

	self.show = true

	self:SetScript("OnTextChanged", focusCast_OnTextChanged)
end

local function rightClick_OnTextChanged(self)

	if (not self.show) then

		if (self:GetText() == "-none-") then

			SD.rightClickTarget = false

		else
			if (self.value) then
				SD.rightClickTarget = self.value
			end

			for k,v in pairs(M.BarIndex) do
				v.updateBar(v, true)
			end
		end

		M.UpdateAutoMacros()
	end

	self.show = nil

end

local function rightClick_OnShow(self)

	local data = {
		["-none-"] = false,
		["Self"] = "player",
		["Pet"] = "pet",
		["Target"] = "target",
		["Target of Target"] = "targettarget",
		["Focus"] = "focus",
		["Target of Focus"] = "focustarget",
	}

	if (SD.rightClickTarget) then

		for k,v in pairs(data) do
			if (v==SD.rightClickTarget) then
				self:SetText(k)
			end
		end
	else
		self:SetText("-none-")
	end

	M.EditBox_PopUpInitialize(self.popup, data)

	self.show = true

	self:SetScript("OnTextChanged", rightClick_OnTextChanged)
end

function M.MacaroonMainMenu_BuildOptions(self)

	local index, frame, lastFrame, anchorF = 1

	frame = CreateFrame("EditBox", "$parentSelfCast", self, "MacaroonEditBoxTemplate1")
	frame:SetWidth(105)
	frame:SetHeight(25)
	frame:SetTextInsets(7,3,0,0)
	frame.text:SetText("Self Cast Option:")
	frame:SetPoint("BOTTOMLEFT", "$parentDropdownBorder", "BOTTOMLEFT", 10, 10)
	frame:SetScript("OnShow", selfCast_OnShow)
	frame:SetScript("OnHide", function(self) self:SetScript("OnTextChanged", nil) end)
	frame:SetScript("OnEvent", selfCast_OnShow)
	self.selfcast = frame

	frame = CreateFrame("EditBox", "$parentFocusCast", self, "MacaroonEditBoxTemplate1")
	frame:SetWidth(105)
	frame:SetHeight(25)
	frame:SetTextInsets(7,3,0,0)
	frame.text:SetText("Focus Cast Option:")
	frame:SetPoint("LEFT", "$parentSelfCast", "RIGHT", 21, 0)
	frame:SetScript("OnShow", focusCast_OnShow)
	frame:SetScript("OnHide", function(self) self:SetScript("OnTextChanged", nil) end)
	frame:SetScript("OnEvent", focusCast_OnShow)
	self.focuscast = frame

	frame = CreateFrame("EditBox", "$parentRightClick", self, "MacaroonEditBoxTemplate1")
	frame:SetWidth(105)
	frame:SetHeight(25)
	frame:SetTextInsets(7,3,0,0)
	frame.text:SetText("Right Click Target:")
	frame:SetPoint("LEFT", "$parentFocusCast", "RIGHT", 21, 0)
	frame:SetScript("OnShow", rightClick_OnShow)
	frame:SetScript("OnHide", function(self) self:SetScript("OnTextChanged", nil) end)
	frame:SetScript("OnEvent", rightClick_OnShow)
	self.rightclick = frame

	local top, bottom , _, yOffset, yOfs

	frame = _G[self:GetName().."CheckbuttonBorder"]

	for i=1,frame:GetNumPoints() do
		_, _, _, _, yOfs = frame:GetPoint(i)

		if (not top or yOfs > top) then
			top = abs(yOfs)
		end

		if (not bottom or yOfs < bottom) then
			bottom = abs(yOfs)
		end
	end

	local checkOrder = { "101", "102", "103", "104", "105", "106", "108", "107" }
	local newCol = ceil(#checkOrder/2) + 1

	while (M.Strings["CHECK_"..index+100]) do

		frame = CreateFrame("CheckButton", "$parentCheck"..index+100, self, "MacaroonOptionCBTemplateLarge")
		frame:SetID(index+100)

		frame.text:SetText(M.Strings["CHECK_"..index+100])

		if (not IsAddOnLoaded("Align") and index == 7) then
			frame:Hide(); newCol = ceil((#checkOrder-1)/2) + 1
		end

		index = index + 1
	end

	self.chkBorder:SetHeight(((newCol-1)*28)+20)

	for k,v in ipairs(checkOrder) do

		if (v == "") then
			frame = nil
		else
			frame = _G[self:GetName().."Check"..v]
		end

		if (frame) then

			if (k == 1) then
				frame:SetPoint("TOPLEFT", "$parentCheckbuttonBorder", "TOPLEFT", 10, -10)
				anchorF = frame; lastFrame = frame
			elseif (k == newCol) then
				frame:SetPoint("LEFT", anchorF, "RIGHT", 170, 0)
				anchorF = frame; lastFrame = frame
			else
				frame:SetPoint("TOP", lastFrame, "BOTTOM", 0, -5)
				lastFrame = frame
			end
		end
	end

	index = 1

	while (M.Strings["SLIDER_"..index]) do

		if (index < 4) then

			frame = CreateFrame("Slider", "$parentSlider"..index, self, "MacaroonSliderTemplate1")
			frame:SetID(index)
			frame:SetWidth(335)
			frame:SetMinMaxValues(sliderMinMax[index].min, sliderMinMax[index].max)
			frame.onshow_func = sliderOnShow[index]
			frame.onvaluechanged_func = sliderOnValueChanged[index]

			if (index == 4) then
				frame:Disable()
				frame.text2:SetTextColor(0.5,0.5,0.5)
			end

			if (index == 1) then
				frame:SetPoint("TOPLEFT", "$parentSliderBorder", "TOPLEFT", 10, -18)
				lastFrame = frame
			else
				frame:SetPoint("TOP", lastFrame, "BOTTOM", 0, -10)
				lastFrame = frame
			end

			frame = CreateFrame("EditBox", "$parentSliderEdit"..index, self, "MacaroonEditBoxTemplate3")
			frame:SetID(index)
			frame:SetPoint("LEFT", lastFrame, "RIGHT", 1, 0)
			frame.slider = lastFrame
			frame:SetScript("OnTabPressed", function(self) local num = tonumber(self:GetText())/200  if(num) then self.slider:SetValue(num) end self:ClearFocus() end)
			frame:SetScript("OnEnterPressed", function(self) local num = tonumber(self:GetText())/200  if(num) then self.slider:SetValue(num) end self:ClearFocus() end)

			lastFrame.editbox = frame

		end

		index = index + 1
	end
end

function M.CheckButtonOptions_OnClick(self)

	if ( self:GetChecked() ) then
		PlaySound("igMainMenuOptionCheckBoxOn")
	else
		PlaySound("igMainMenuOptionCheckBoxOff")
	end

	SD.checkButtons[self:GetID()] = self:GetChecked()

	if (M.CheckbuttonOptions[self:GetID()]) then
		M.CheckbuttonOptions[self:GetID()](self)
	end
end

function M.CheckButtonOptions_OnShow(self)

	if (SD) then
		self:SetChecked(SD.checkButtons[self:GetID()])
	end
end

function M.RadioButtonOptions_OnClick(self, button)

	if ( self:GetChecked() ) then
		PlaySound("igMainMenuOptionCheckBoxOn")
	else
		PlaySound("igMainMenuOptionCheckBoxOff")
	end

	if (self.onclick_func) then
		self.onclick_func(self, button)
	end
end

function M.RadioButtonOptions_OnShow(self)

	if (self.onshow_func) then
		self.onshow_func(self)
	end
end

function M.AdjustOptionButton_OnClick(self, button, down)

	if (self.toggle_func) then

		PlaySound("igMainMenuOptionCheckBoxOn")

		if (down) then
			self:GetPushedTexture():SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
			self:GetHighlightTexture():SetTexture("")
			self.text:SetPoint("LEFT", 16, -2)
			self.textR:SetPoint("TOPRIGHT", -20, -2)
			self.textR:SetPoint("BOTTOMRIGHT", -20, -2)
		else
			self:GetPushedTexture():SetTexture("")
			self:GetHighlightTexture():SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
			self.text:SetPoint("LEFT", 18, 0)
			self.textR:SetPoint("TOPRIGHT", -18, 0)
			self.textR:SetPoint("BOTTOMRIGHT", -18, 0)
			self.toggle_func(self)
		end

	elseif (not down) then

		if ( self:GetChecked() ) then
			PlaySound("igMainMenuOptionCheckBoxOn")
			self:GetHighlightTexture():SetTexture("")
			self.add:Show()
			self.sub:Show()
		else
			PlaySound("igMainMenuOptionCheckBoxOff")
			self:GetHighlightTexture():SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
			self.add:Hide()
			self.sub:Hide()
		end

		if (self.onclick_func) then
			self.onclick_func(self, button, down)
		end

	elseif (self:GetChecked()) then
		self:SetChecked(nil)
	else
		self:SetChecked(1)
	end

	self.elapsed = 0

end

function M.AdjustOptionButton_OnShow(self)

	self:GetHighlightTexture():SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
	self:GetPushedTexture():SetTexture("")
	self:GetHighlightTexture():SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
	self.text:SetPoint("LEFT", 18, 0)
	self.textR:SetPoint("TOPRIGHT", -18, 0)
	self.textR:SetPoint("BOTTOMRIGHT", -18, 0)
	self:SetChecked(nil)
	self.add:Hide()
	self.sub:Hide()
	self.elapsed = 0

	if (self.onshow_func) then
		self.onshow_func(self)
	end
end

function M.AdjustOptionButton_OnUpdate(self, elapsed)

	self.elapsed = self.elapsed + elapsed
	self.focus = GetMouseFocus()

	if (self.focus ~= self and self.focus ~= self.add and self.focus ~= self.sub) then
		if (self.elapsed > self.limit and self:GetChecked()) then
			M.AdjustOptionButton_OnShow(self)
		end
	end
end

function M.AdjustOptionButtonAdd_OnClick(self, button, down, parent)

	PlaySound("igMiniMapZoomIn")

	if (self.onclick_func) then
		self.onclick_func(self, button, down, parent)
	end

	parent.elapsed = 0

end

function M.AdjustOptionButtonSubtract_OnClick(self, button, down, parent)

	PlaySound("igMiniMapZoomIn")

	if (self.onclick_func) then
		self.onclick_func(self, button, down, parent)
	end

	parent.elapsed = 0
end

function M.AdjustOptionButtonAddSub_OnUpdate(self, elapsed, parent)

	if (self.onupdate_func) then
		self.onupdate_func(self,elapsed)
	end

	if (GetMouseFocus() == self) then
		parent.elapsed = 0
	end

end

function M.SliderOptions_OnShow(self)

end

function M.SliderOptions_OnValueChanged(self, value)

end

--From wowwiki.com
local minimapShapes = {

	-- quadrant booleans (same order as SetTexCoord)
	-- {upper-left, lower-left, upper-right, lower-right}
	-- true = rounded, false = squared

	["ROUND"] 			= {true, true, true, true},
	["SQUARE"] 			= {false, false, false, false},
	["CORNER-TOPLEFT"] 		= {true, false, false, false},
	["CORNER-TOPRIGHT"] 		= {false, false, true, false},
	["CORNER-BOTTOMLEFT"] 		= {false, true, false, false},
	["CORNER-BOTTOMRIGHT"]	 	= {false, false, false, true},
	["SIDE-LEFT"] 			= {true, true, false, false},
	["SIDE-RIGHT"] 			= {false, false, true, true},
	["SIDE-TOP"] 			= {true, false, true, false},
	["SIDE-BOTTOM"] 		= {false, true, false, true},
	["TRICORNER-TOPLEFT"] 		= {true, true, true, false},
	["TRICORNER-TOPRIGHT"] 		= {true, false, true, true},
	["TRICORNER-BOTTOMLEFT"] 	= {true, true, false, true},
	["TRICORNER-BOTTOMRIGHT"] 	= {false, true, true, true},
}

function M.DragFrame_OnUpdate(x, y)

	local pos, quad, round, radius = nil, nil, nil, SD.buttonRadius - MacaroonMinimapButton:GetWidth()/math.pi
	local sqRad = sqrt(2*(radius)^2)

	local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom()

	local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
	local quadTable = minimapShapes[minimapShape]

	local xpos, ypos = x, y

	if (not xpos or not ypos) then
		xpos, ypos = GetCursorPosition()
	end

	xpos = xmin - xpos / Minimap:GetEffectiveScale() + radius
	ypos = ypos / Minimap:GetEffectiveScale() - ymin - radius

	pos = math.deg(math.atan2(ypos,xpos))

	xpos = cos(pos)
	ypos = sin(pos)

	if (xpos > 0 and ypos > 0) then
		quad = 1 --topleft
	elseif (xpos > 0 and ypos < 0) then
		quad = 2 --bottomleft
	elseif (xpos < 0 and ypos > 0) then
		quad = 3 --topright
	elseif (xpos < 0 and ypos < 0) then
		quad = 4 --bottomright
	end

	round = quadTable[quad]

	if (round) then
		xpos = xpos * radius
		ypos = ypos * radius
	else
		xpos = max(-radius, min(xpos * sqRad, radius))
		ypos = max(-radius, min(ypos * sqRad, radius))
	end

	MacaroonMinimapButton:SetPoint("TOPLEFT", "Minimap", "TOPLEFT", 52-xpos, ypos-55)

	SD.buttonLoc = { 52-xpos, ypos-55 }
end

function M.MinimapButton_OnLoad(self)

	local data, index = {}, 1

	while (M.Strings["MINIMAP_ACTION_"..index]) do
		data[M.Strings["MINIMAP_ACTION_"..index]] = tostring(index)
		index = index + 1
	end

	self:RegisterForClicks("AnyUp")
	self:RegisterForDrag("LeftButton")
	self:RegisterEvent("PLAYER_LOGIN")
	self.elapsed = 0
	self.x = 0
	self.y = 0
	self.count = 1
	self.angle = 0
	self.popup = _G[self:GetName().."PopUp"]
	self.icon = _G[self:GetName().."Icon"]
	--self.icon:SetTexCoord(self.x, self.x+0.125, self.y, self.y+0.25)
	self:SetFrameStrata(MinimapCluster:GetFrameStrata())
	self:SetFrameLevel(MinimapCluster:GetFrameLevel()+3)

	M.EditBox_PopUpInitialize(self.popup, data)
end

function M.MinimapButton_OnEvent(self)

	M.MinimapButton_OnDragStop(self)

end

function M.MinimapButton_OnDragStart(self)

	self:LockHighlight()
	self:StartMoving()
	MacaroonMinimapButtonDragFrame:Show()
end

function M.MinimapButton_OnDragStop(self)

	self:UnlockHighlight()
	self:StopMovingOrSizing()
	self:SetUserPlaced(false)
	self:ClearAllPoints()
	if (SD and SD.buttonLoc) then
		self:SetPoint("TOPLEFT", "Minimap","TOPLEFT", SD.buttonLoc[1], SD.buttonLoc[2])
	end
	MacaroonMinimapButtonDragFrame:Hide()
end

function M.MinimapButton_OnShow(self)

	if (SD) then
		M.MinimapButton_OnDragStop(self)
	end
end

function M.MinimapButton_OnHide(self)

	self:UnlockHighlight()
	MacaroonMinimapButtonDragFrame:Hide()
end

function M.MinimapButton_OnEnter(self)

	local status

	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)

	GameTooltip:SetText(M.Strings.MINIMAP_TOOLTIP0)

	GameTooltip:AddLine(M.Strings.MINIMAP_TOOLTIP1)

	local lock

	for k,v in pairs(M.BarIndex) do
		if (not lock) then
			lock = v.config.barLock
		end
	end

	if (lock) then
		GameTooltip:AddLine(M.Strings.MINIMAP_TOOLTIP2.."|cff00ff00"..M.Strings.BARTOOLTIP_1.."|r")
	else
		GameTooltip:AddLine(M.Strings.MINIMAP_TOOLTIP2.."|cfff00000"..M.Strings.BARTOOLTIP_2.."|r")
	end

	GameTooltip:Show()
end

function M.MinimapButton_OnLeave(self)

	GameTooltip:Hide()
end

function M.MinimapButton_OnClick(self, button)

	PlaySound("igChatScrollDown")

	if (InCombatLockdown()) then return end

	if (button == "RightButton") then

		if (self.popup:IsVisible()) then
			self.popup:Hide()
		elseif (self.popup.data) then
			self.popup:Show()
		end

	elseif (IsShiftKeyDown()) then

		M.ButtonBind()

	elseif (IsAltKeyDown()) then

		M.ObjectEdit()

	elseif (IsControlKeyDown()) then

		M.RaiseButtons()

	else
		M.ConfigBars()
	end
end

function M.MinimapMenuClose()
	MacaroonMinimapButton.popup:Hide()
end

function M.OptionsSlider_OnShow(self)

	self.text2:SetText(M.Strings["SLIDER_"..self:GetID()])

	if (self.onshow_func) then
		self.onshow_func(self)
	end
end

function M.OptionsSlider_OnValueChanged(self, value)

	if (self.onvaluechanged_func) then
		self.onvaluechanged_func(self, value)
	end
end

function M.PanelMover_OnDragStart(self)

	MacaroonPanelMover:Show()
	MacaroonPanelMover:ClearAllPoints()
	MacaroonPanelMover:SetUserPlaced(true)
	MacaroonPanelMover:StartMoving()
end

function M.PanelMover_OnDragStop(self)

	MacaroonPanelMover:Hide()
	MacaroonPanelMover:StopMovingOrSizing()
end

function M.StorageCreateButton()

	PlaySound("gsTitleOptionExit")

	local button = M.AddNewButton(MacaroonButtonStorage)
	M.StoreButton(button, M.Buttons)
	M.UpdateButtonStorage()

end

function M.StorageDeleteButton()

	PlaySound("gsTitleOptionExit")

	local lastButton, found = 0

	for k,v in pairs(M.Buttons) do
		if (not v[1].config.locked) then
			if (v[2] == 1) then
				if (k > lastButton) then
					lastButton = k; found = true
				end
			end
		end
	end

	if (found) then

		M.Buttons[lastButton] = nil
		SD.buttons[lastButton] = nil

		lastButton = _G["MacaroonButton"..lastButton]
		lastButton.config = nil

		lastButton:ClearAllPoints()
		lastButton:SetParent("UIParent")
		lastButton:Hide()
		lastButton:UnregisterAllEvents()

		M.Save()

		M.UpdateButtonStorage()
	end
end

function M.Inititialize()

	for k,v in pairs(M.SavedDataUpdate) do v() end

	M.Save(); collectgarbage()
end

local function buttonsSetSaved()

	SD = MacaroonSavedState
end

local events = {}

local firstevent = false

function M.Control_OnEvent(self, event, ...)

	--if (not MacaroonSavedState.debug.events) then MacaroonSavedState.debug.events = {}
	--elseif (not firstevent) then M.ClearTable(MacaroonSavedState.debug.events) firstevent = true end
	--tinsert(MacaroonSavedState.debug.events, { event, GetActiveTalentGroup() })

	M.CurrEvent = event

	if (event == "ADDON_LOADED" and ... == "Macaroon") then

		for k,v in pairs(opDepList) do
			if (IsAddOnLoaded(v)) then
				opDep = true
			end
		end

		buttonsSetSaved()

		for k,v in pairs(defaultSD) do
			if (SD[k] == nil) then
				SD[k] = v
			end
		end

		for k,v in pairs(defaultSP) do

			if (MacaroonSpecProfiles[k] == nil) then
				MacaroonSpecProfiles[k] = v
			end
		end

		for k,v in pairs(defaultMV) do

			if (MacaroonMacroVault[k] == nil) then
				MacaroonMacroVault[k] = v
			end
		end

		--temp

		MacaroonMacroVault.vault = nil

		local realm, char, index

		for k,v in pairs(MacaroonMacroMaster) do

			realm, char, index = (":"):split(k)

			if (realm and realm ~= "vault") then

				if (not MacaroonMacroVault[realm]) then
					MacaroonMacroVault[realm] = {}
				end

				if (char) then

					if (not MacaroonMacroVault[realm][char]) then
						MacaroonMacroVault[realm][char] = {}
					end

					if (index and not MacaroonMacroVault[realm][char]["3.x Macro: Button "..index]) then
						MacaroonMacroVault[realm][char]["3.x Macro: Button "..index] = CopyTable(v)
					end
				end
			end
		end

		for realm in next,MacaroonMacroVault do
			for character in next, MacaroonMacroVault[realm] do
				for macro in next, MacaroonMacroVault[realm][character] do
					if (#MacaroonMacroVault[realm][character][macro][1] < 1) then
						MacaroonMacroVault[realm][character][macro] = nil
					end
				end
			end
		end

		MacaroonMacroMaster = nil

		--temp

		updateShapeshiftStrings()

		if (UnitClass("player") == M.Strings.SHAMAN) then
			M.maxActionID = 144
		end

	elseif (event == "VARIABLES_LOADED") then

		local index, button, texture = 1

		SlashCmdList["MACAROON"] = slashHandler
		SLASH_MACAROON1 = M.Strings.SLASH1
		SLASH_MACAROON2 = M.Strings.SLASH2

		while (M.Strings["SLASH_COMMAND_"..index]) do

			local command = M.Strings["SLASH_COMMAND_"..index]
			local desc = M.Strings["SLASH_COMMAND_"..index.."_DESC"]
			local func = Macaroon[M.Strings["SLASH_COMMAND_"..index.."_FUNC"]]

			M.SlashCommands[command] = { desc, func }
			M.SlashHelp[index] = "       |cff00ff00"..command.."|r: "..desc
			index = index + 1
		end

		hooksecurefunc("updateContainerFrameAnchors", macUpdateContainerFrameAnchors)

		--because for some silly reason the Ace3 "BetterBlizzOptions" library changes the strata
		--this puts it back where Blizz put it
		InterfaceOptionsFrame:SetFrameStrata("HIGH")

	elseif (event == "PLAYER_LOGIN") then

		for k,v in pairs(M.CheckbuttonOptions) do
			local checkButton = _G["MacaroonMainMenuCheck"..k]
			if (checkButton) then v(checkButton) end
		end

		updateSpellIndex()
		updateCompanionData()
		updateIconIndex()

		M.Inititialize()
		M.UpdateButtonStorage()

	elseif (event == "PLAYER_ENTERING_WORLD" and not pew) then

		M.Save(); collectgarbage(); pew = true

	elseif (event == "PLAYER_TALENT_UPDATE") then

		MacaroonSpecProfiles.LastSpec = GetActiveTalentGroup()

	elseif (event == "ACTIVE_TALENT_GROUP_CHANGED") then

		updateSpellIndex()
		updateShapeshiftStrings()

		local spec = select(1,...)

		if (MacaroonSpecProfiles.enabled) then
			pew = false; M.LoadFromProfile(MacaroonSpecProfiles[spec])
		else

			--for k,v in pairs(M.ShowGrids) do v() end

			--for k,v in pairs(M.BarIndex) do
			--	if (v.updateBarDualSpec and v.config.dualSpec) then
			--		v.updateBarDualSpec(v, spec)
			--	end
			--end

			--for k,v in pairs(M.HideGrids) do v() end
		end

		if (IsAddOnLoaded("MacaroonProfiles")) then
			M.ProfilesScrollFrameUpdate()
		end

		M.Save()

	elseif (event == "SKILL_LINES_CHANGED") then

		updateSpellIndex(true)
		updateShapeshiftStrings()

	elseif (event == "LEARNED_SPELL_IN_TAB" or event == "CHARACTER_POINTS_CHANGED") then

		updateSpellIndex()
		updateShapeshiftStrings()

	elseif (event == "PET_UI_CLOSE" or event == "COMPANION_LEARNED" or event == "COMPANION_UPDATE") then

		updateCompanionData()

	elseif (event == "PLAYER_LOGOUT" or event == "PLAYER_LEAVING_WORLD") then

		MacaroonSpecProfiles.LastSpec = GetActiveTalentGroup()

		for k,v in pairs(M.StatesToSave) do v() end

	end
end

function M.Save()

	MacaroonControl.save = true
	MacaroonControl.elapsed = 0

	for k,v in pairs(M.UpdateFunctions) do
		v()
	end
end

local function control_OnUpdate(self, elapsed)

	self.elapsed = self.elapsed + elapsed

	if (self.save and self.elapsed > SD.throttle) then
		for k,v in pairs(M.StatesToSave) do v() end
		self.save = nil; 	self.elapsed = 0;
		if (not self.init or self.init < 2) then
			if (not self.init) then
				self.init = 1
			else
				self.init = self.init + 1
			end
			collectgarbage()
		end
	end
end

local frame = CreateFrame("Frame", "MacaroonControl", UIParent)

frame.elapsed = 0
frame:SetScript("OnEvent", M.Control_OnEvent)
frame:SetScript("OnUpdate", control_OnUpdate)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("VARIABLES_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_LEAVING_WORLD")
frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
frame:RegisterEvent("SKILL_LINES_CHANGED")
frame:RegisterEvent("CHARACTER_POINTS_CHANGED")
frame:RegisterEvent("LEARNED_SPELL_IN_TAB")
frame:RegisterEvent("CURSOR_UPDATE")
frame:RegisterEvent("PET_UI_CLOSE")
frame:RegisterEvent("COMPANION_LEARNED")
frame:RegisterEvent("COMPANION_UPDATE")
--frame:RegisterAllEvents()

frame = CreateFrame("GameTooltip", "MacaroonTooltipScan", UIParent, "GameTooltipTemplate")
frame:SetOwner(UIParent, "ANCHOR_NONE")
frame:SetFrameStrata("TOOLTIP")
frame:Hide()
