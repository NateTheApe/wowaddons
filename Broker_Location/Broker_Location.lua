--------------------------------------------------------------------------------------------------------
--                                          Localized global                                          --
--------------------------------------------------------------------------------------------------------
local _G = getfenv(0)

--------------------------------------------------------------------------------------------------------
--                                            AceAddon init                                           --
--------------------------------------------------------------------------------------------------------
local MODNAME	= "Broker_Location"
local addon = LibStub("AceAddon-3.0"):NewAddon(MODNAME, "AceTimer-3.0")
_G.Broker_Location = addon

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local LibQTip = LibStub('LibQTip-1.0')
local Tourist = LibStub("LibTourist-3.0")

--------------------------------------------------------------------------------------------------------
--                               Broker_Location variables and defaults                               --
--------------------------------------------------------------------------------------------------------
local subZoneText, zoneText, mapPositionX, mapPositionY
local continent

local tooltip
local currentPath = nil

local profileDB
local DATABASE_DEFAULTS = {
	profile = {
		show_zone = true,
		show_subzone = true,
		show_cords = true,
		cords_decimal_precision = 0,
		show_zonelevel = true,
		show_minimap = false,
		show_recommended = true,
		show_atlasonctrl = false,
	},
}

--------------------------------------------------------------------------------------------------------
--                                  Broker_Location font definitions                                  --
--------------------------------------------------------------------------------------------------------

-- Title Font. 14
local titleFont = CreateFont("titleFont")
titleFont:SetTextColor(1,0.823529,0,1)
titleFont:SetFont(GameTooltipText:GetFont(), 14)

-- Header Font. 12
local headerFont = CreateFont("headerFont")
headerFont:SetTextColor(0.92,0.64,0.37,1)
headerFont:SetFont(GameTooltipHeaderText:GetFont(), 13)

-- Regular Font. 12
local textFont = CreateFont("textFont")
textFont:SetTextColor(1,0.823529,0,1)
textFont:SetFont(GameTooltipText:GetFont(), 12)

--------------------------------------------------------------------------------------------------------
--                                   Broker_Location options panel                                    --
--------------------------------------------------------------------------------------------------------
addon.options = {
	type = "group",
	name = "Broker Location",
	args = {
		general = {
			order = 1,
			type = "group",
			name = "General Settings",
			cmdInline = true,
			args = {
				confdesc = {
					order = 1,
					type = "description",
					name = "LDB plugin that shows recommended zones and zone info.",
				},
				separator1 = {
					order = 2,
					type = "header",
					name = "Display Options",
				},
				show_zone = {
					order = 3,
					type = "toggle",
					width = "full",
					name = "Show main zone name",
					desc = "Toggle to show the main zone name.",
					get = function()
						return profileDB.show_zone
					end,
					set = function(key, value)
						profileDB.show_zone = value
					end,
				},
				show_subzone = {
					order = 4,
					type = "toggle",
					width = "full",
					name = "Show sub zone name",
					desc = "Toggle to show the sub zone name.",
					get = function()
						return profileDB.show_subzone
					end,
					set = function(key, value)
						profileDB.show_subzone = value
					end,
				},
				show_cords = {
					order = 5,
					type = 'toggle',
					name = "Show coordinates",
					desc = "Toggle to show coordinates.",
					get = function()
						return profileDB.show_cords
					end,
					set = function(key, value)
						profileDB.show_cords = value
					end,
				},
				cords_decimal_precision = {
					order = 6,
					type = "range",
					name = "Coordinates decimal precision",
					desc = "Set the number of visible decimals.",
					min = 0, max = 2, step = 1,
					get = function()
						return profileDB.cords_decimal_precision
					end,
					set = function(key, value)
						profileDB.cords_decimal_precision = value
					end,
					disabled = function()
						return not profileDB.show_cords
					end,
				},
				show_zonelevel = {
					order = 7,
					type = 'toggle',
					width = "full",
					name = "Show zone level",
					desc = "Toggle to show the zone level.",
					get = function()
						return profileDB.show_zonelevel
					end,
					set = function(key, value)
						profileDB.show_zonelevel = value
					end,
				},
				show_minimap = {
					order = 8,
					type = 'toggle',
					width = "full",
					name = "Show location above minimap.",
					desc = "Toggle to show the text displayed above the minimap.",
					get = function()
						return profileDB.show_minimap
					end,
					set = function(key, value)
						profileDB.show_minimap = value
						addon:UpdateMinimapZoneTextButton()
					end,
				},
				separator2 = {
					order = 10,
					type = "header",
					name = "Tooltip Options",
				},
				show_recommended = {
					order = 11,
					type = 'toggle',
					width = "full",
					name = "Show recommended zones/instances",
					desc = "Toggle to show the recommended zones/instances.",
					get = function()
						return profileDB.show_recommended
					end,
					set = function(key, value)
						profileDB.show_recommended = value
					end,
				},
				show_atlasonctrl = {
					order = 12,
					type = 'toggle',
					width = "full",
					name = "Show Atlas on Control+Click",
					desc = "Toggle to show Atlas instead of default map when Control Clicking.",
					get = function()
						return profileDB.show_atlasonctrl
					end,
					set = function(key, value)
						profileDB.show_atlasonctrl = value
					end,
				},
			}
		}
	}
}

function addon:SetupOptions()
	addon.options.args.profile = AceDBOptions:GetOptionsTable(self.db)
	addon.options.args.profile.order = -2

	AceConfig:RegisterOptionsTable(MODNAME, addon.options, nil)

	self.optionsFrames = {}
	self.optionsFrames.general = AceConfigDialog:AddToBlizOptions(MODNAME, nil, nil, "general")
	self.optionsFrames.profile = AceConfigDialog:AddToBlizOptions(MODNAME, "Profiles", MODNAME, "profile")
end

--------------------------------------------------------------------------------------------------------
--                                        Broker_Location core                                        --
--------------------------------------------------------------------------------------------------------
function addon:OnInitialize()
	self.db = AceDB:New("Broker_LocationDB", DATABASE_DEFAULTS, true)
	if not self.db then
		_G.print("Error: Database not loaded correctly.  Please exit out of WoW and delete Broker_Location.lua found in: \\World of Warcraft\\WTF\\Account\\<Account Name>>\\SavedVariables\\")
	end

	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")

	profileDB = self.db.profile
	self:SetupOptions()

	self:ScheduleTimer("UpdateMinimapZoneTextButton",1)
end

function addon:OnEnable()
	self:ScheduleRepeatingTimer("MainUpdate", 1)
end

-- LDB object
addon.obj = ldb:NewDataObject(MODNAME, {
	type = "data source",
	label = "Location",
	text = "Updating...",
	icon = "Interface\\Icons\\INV_Misc_Map07.png",
	OnClick = function(frame, msg)
		addon:MainUpdate()
		if msg == "LeftButton" then
			if _G.IsShiftKeyDown() then
				local edit_box = _G.ChatEdit_ChooseBoxForSend()
				_G.ChatEdit_ActivateChat(edit_box)
				edit_box:Insert(addon:GetChatText())
			else
				if _G.Atlas_Toggle and _G.IsControlKeyDown() and profileDB.show_atlasonctrl then
					_G.Atlas_Toggle()
				else
					_G.ToggleFrame(_G.WorldMapFrame)
				end
			end
		end
		if msg == "RightButton" then
			addon:ShowConfig()
		end
	end,
})

-- Main update function
function addon:MainUpdate()
	self:UpdateLocationData()
	self.obj.text = self:GetLDBText()
end

--------------------------------------------------------------------------------------------------------
--                                     Broker_Location functions                                      --
--------------------------------------------------------------------------------------------------------

-- Called after profile changed
function addon:OnProfileChanged(event, database, newProfileKey)
	profileDB = database.profile
end

-- Open config window
function addon:ShowConfig()
	_G.InterfaceOptionsFrame_OpenToCategory(self.optionsFrames.profile)
	_G.InterfaceOptionsFrame_OpenToCategory(self.optionsFrames.general)
end

-- Toggle zone info above minimap
function addon:UpdateMinimapZoneTextButton()
	local offset = _G.MinimapBorderTop:GetHeight() * 3/5

	if profileDB.show_minimap and not _G.MinimapBorderTop:IsShown() then
		_G.MinimapBorderTop:Show()
		_G.MinimapZoneTextButton:Show()
		_G.MiniMapWorldMapButton:Show()
		self:CorrectMinimapPosition(-offset)
	elseif not profileDB.show_minimap and _G.MinimapBorderTop:IsShown() then
		_G.MinimapBorderTop:Hide()
		_G.MinimapZoneTextButton:Hide()
		_G.MiniMapWorldMapButton:Hide()
		self:CorrectMinimapPosition(offset)
	end
end

-- Automatically correct minimap position
function addon:CorrectMinimapPosition(offsetY)
	local Jostle = LibStub:GetLibrary("LibJostle-3.0", true)
	local point, relativeTo, relativePoint, xOfs, yOfs = _G.MinimapCluster:GetPoint(1)

	if not _G.MinimapCluster:IsUserPlaced() then -- avoid conflict with other mods
		if not Jostle then
			_G.MinimapCluster:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs + offsetY)
		else
			Jostle:Refresh()
		end
	end
end

-- Update addon variables for location
function addon:UpdateLocationData()
	subZoneText = _G.GetSubZoneText() or ""
	zoneText = _G.GetRealZoneText() or ""
	mapPositionX, mapPositionY = _G.GetPlayerMapPosition("player")
end

-- Create location text for LDB display
function addon:GetLocationText()
	local text = ""

	-- zone and subzone
	if profileDB.show_zone then
		text = zoneText
	end

	if profileDB.show_subzone then
		if (text ~= "") and (subZoneText ~= "") and (subZoneText ~= zoneText) then
			text = text .. ": " .. subZoneText
		elseif (subZoneText ~= "") then
			text = subZoneText
		else
			text = zoneText
		end
	end

	-- coordinates
	if profileDB.show_cords then
		if text ~= "" then
			text = text .. " "
		end
		local p = profileDB.cords_decimal_precision
		text = text .. _G.string.format("(%."..p.."f, %."..p.."f)", mapPositionX * 100, mapPositionY * 100)
	end

	--color text
	local r, g, b = Tourist:GetFactionColor(zoneText)
	if text ~= "" then
		text = _G.string.format("|cff%02x%02x%02x%s|r", r*255, g*255, b*255, text)
	end

	return text
end

-- Create level range text for LDB display
function addon:GetLevelRangeText()
	local low, high = Tourist:GetLevel(zoneText)
	if low > 0 and high > 0 then
		local r, g, b = Tourist:GetLevelColor(zoneText)
		return _G.string.format("|cff%02x%02x%02x[%d-%d]|r", r*255, g*255, b*255, low, high)
	end
	return ""
end

-- Create LDB display text
function addon:GetLDBText()
	local displayLine = self:GetLocationText()

	if profileDB.show_zonelevel then
		local text = self:GetLevelRangeText()
		if text ~= "" then
			if displayLine ~= "" then
				displayLine = displayLine .. " " .. text
			else
				displayLine = text
			end
		end
	end

	return displayLine
end

-- Create location text for chat
function addon:GetChatText()
	local message = ""

	local coords = _G.string.format("%.0f, %.0f", mapPositionX * 100, mapPositionY * 100)

	if zoneText ~= subZoneText then
		message = _G.string.format("%s: %s (%s)", zoneText, subZoneText, coords)
	else
		message = _G.string.format("%s (%s)", zoneText, coords)
	end

	return message
end

-- Return area status: sanctuary, friendly, contested
function addon:GetAreaStatus()
	local text
	local r, g, b = 1, 1, 0

	local pvpType, _, _ = _G.GetZonePVPInfo()
	if (pvpType == "sanctuary") then
		text = "Sanctuary"
		r, g, b = 0.41, 0.8, 0.94
	elseif(pvpType == "arena") then
		text = "Arena"
		r, g, b = 1, 0.1, 0.1
	elseif(pvpType == "friendly") then
		text = "Friendly"
		r, g, b = 0.1, 1, 0.1
	elseif(pvpType == "hostile") then
		text = "Hostile"
		r, g, b = 1, 0.1, 0.1
	elseif(pvpType == "contested") then
		text = "Contested"
		r, g, b = 1, 0.7, 0.1
	elseif(pvpType == "combar") then
		text = "Combat"
		r, g, b = 1, 0.1, 0.1
	else
		text = _G.UNKNOWN or "?"
	end

	return _G.string.format("|cff%02x%02x%02x%s|r", r*255, g*255, b*255, text)
end

-- Create fish skill text
function addon:FormatFishSkillText(minFish)
	local _, _, _, fishSkill = _G.GetProfessions()
	local r,g,b = 1,0,0
	if fishSkill ~= nil then
		local _, _, skillRank = _G.GetProfessionInfo(fishSkill)
		if minFish < skillRank then
			r,g,b = 0,1,0
		elseif minFish == skillRank then
			r,g,b = 1,1,0
		end
	end

	return _G.string.format("|cff%02x%02x%02x%d|r", r*255, g*255, b*255, minFish)
end

-- Handle click on a recommendation entry
function addon:Entry_OnMouseUp(info, button)
	if currentPath == info then
		currentPath = nil
	else
		currentPath = info
	end
	addon.obj.OnEnter()
end

-- Show path to recommended zone
function addon:AddPathTooltip(zone)
	local line

	tooltip:AddSeparator()
	line = tooltip:AddLine()
	tooltip:SetCell(line, 1, _G.string.format("    Walk path from %s to %s:", zoneText, zone), "LEFT", 0)

	local found = false
	for z in Tourist:IteratePath(zoneText, zone) do
		found = true
		local low, high = Tourist:GetLevel(z)
		local r1, g1, b1 = Tourist:GetFactionColor(z)
		local r2, g2, b2 = Tourist:GetLevelColor(z)
		local zContinent = Tourist:GetContinent(z)

		local t1 = "    " .. (z == currentPath and z or z .. " ->")
		local t2 = low == 0 and " " or low == high and low or _G.string.format("%d-%d", low, high)
		local t3 = zContinent == _G.UNKNOWN and "" or zContinent
		line = tooltip:AddLine(
			_G.string.format("|cff%02x%02x%02x%s|r", r1*255, g1*255, b1*255, t1),
			_G.string.format("|cff%02x%02x%02x%s|r", r2*255, g2*255, b2*255, t2))
		tooltip:SetCell(line, 3, _G.string.format("|cff%02xff00%s|r", continent == zContinent and 0 or 255, t3), "LEFT", 2)
	end
	if not found then
		line = tooltip:AddLine()
		tooltip:SetCell(line, 1,"    No path found.", "LEFT", 0)
	end
	tooltip:AddSeparator()
end

--------------------------------------------------------------------------------------------------------
--                                      Broker_Location tooltip                                       --
--------------------------------------------------------------------------------------------------------
function addon.obj.OnEnter(self)
	local line

	if LibQTip:IsAcquired(MODNAME) then
		tooltip:Clear()
	else
		tooltip = LibQTip:Acquire(MODNAME, 4)

		tooltip:SetHeaderFont(headerFont)
		tooltip:SetFont(textFont)

		tooltip:SmartAnchorTo(self)

		tooltip:SetAutoHideDelay(0.1, self)
	end

	-- title
	line = tooltip:AddLine()
	tooltip:SetCell(line, 1, MODNAME.." ".._G.GetAddOnMetadata(MODNAME, "Version"), titleFont, "CENTER", 0)
	tooltip:AddLine(" ")

	-- general info
	line = tooltip:AddLine("Zone:")
	tooltip:SetCell(line, 2, zoneText, "LEFT", 3)
	line = tooltip:AddLine("Subzone:")
	tooltip:SetCell(line, 2, subZoneText, "LEFT", 3)
	line = tooltip:AddLine("Status:")
	tooltip:SetCell(line, 2, addon:GetAreaStatus(), "LEFT", 3)
	line = tooltip:AddLine("Coordinates:")
	tooltip:SetCell(line, 2, _G.string.format("%.0f, %.0f", mapPositionX * 100, mapPositionY * 100), "LEFT", 3)

	continent = Tourist:GetContinent(zoneText)
	line = tooltip:AddLine("Continent:")
	tooltip:SetCell(line, 2, continent, "LEFT", 3)

	local lvl = addon:GetLevelRangeText()
	if lvl ~= "" then
		line = tooltip:AddLine("Level range:")
		tooltip:SetCell(line, 2, lvl, "LEFT", 3)
	end

	local minFish = Tourist:GetFishingLevel(zoneText)
	if minFish then
		line = tooltip:AddLine("Fishing:")
		tooltip:SetCell(line, 2, addon:FormatFishSkillText(minFish), "LEFT", 3)
	end

	-- instances
	if Tourist:DoesZoneHaveInstances(zoneText) then
		tooltip:AddLine(" ")
		line = tooltip:AddHeader()
		tooltip:SetCell(line, 1, "Instances:", "LEFT", 0)

		tooltip:AddSeparator()
		for instance in Tourist:IterateZoneInstances(zoneText) do
			local low, high = Tourist:GetLevel(instance)
			local r, g, b = Tourist:GetLevelColor(instance)
			local groupSize = Tourist:GetInstanceGroupSize(instance)
			tooltip:AddLine(instance,
					_G.string.format("|cff%02x%02x%02x%d-%d|r", r*255, g*255, b*255, low, high),
					groupSize > 0 and _G.string.format("%d-man", groupSize) or "")
		end
		tooltip:AddSeparator()
	end

	if profileDB.show_recommended then
		-- recommended zones
		tooltip:AddLine(" ")
		line = tooltip:AddHeader()
		tooltip:SetCell(line, 1, "Recommended zones:", "LEFT", 0)

		tooltip:AddSeparator()
		local zone
		for zone in Tourist:IterateRecommendedZones() do
			local low, high = Tourist:GetLevel(zone)
			local r1, g1, b1 = Tourist:GetFactionColor(zone)
			local r2, g2, b2 = Tourist:GetLevelColor(zone)
			local zContinent = Tourist:GetContinent(zone)
			line = tooltip:AddLine(
					_G.string.format("|cff%02x%02x%02x%s|r", r1*255, g1*255, b1*255, zone),
					_G.string.format("|cff%02x%02x%02x%d-%d|r", r2*255, g2*255, b2*255, low, high))
			tooltip:SetCell(line, 3, _G.string.format("|cff%02xff00%s|r", continent == zContinent and 0 or 255, zContinent), "LEFT", 2)
			tooltip:SetLineScript(line, "OnMouseUp", addon.Entry_OnMouseUp, zone)

			-- show path
			if zone == currentPath then
				addon:AddPathTooltip(zone)
			end
		end
		tooltip:AddSeparator()

		-- recommended instances
		if Tourist:HasRecommendedInstances() then
			tooltip:AddLine(" ")
			line = tooltip:AddHeader()
			tooltip:SetCell(line, 1, "Recommended instances:", "LEFT", 0)

			tooltip:AddSeparator()
			local instance
			for instance in Tourist:IterateRecommendedInstances() do
				local low, high = Tourist:GetLevel(instance)
				local r1, g1, b1 = Tourist:GetFactionColor(instance)
				local r2, g2, b2 = Tourist:GetLevelColor(instance)
				local groupSize = Tourist:GetInstanceGroupSize(instance)
				line = tooltip:AddLine(
						_G.string.format("|cff%02x%02x%02x%s|r", r1*255, g1*255, b1*255, instance),
						_G.string.format("|cff%02x%02x%02x%d-%d|r", r2*255, g2*255, b2*255, low, high),
						groupSize > 0 and _G.string.format("%d-man", groupSize) or "",
						Tourist:GetInstanceZone(instance))
				tooltip:SetLineScript(line, "OnMouseUp", addon.Entry_OnMouseUp, instance)

				-- show path
				if instance == currentPath then
					addon:AddPathTooltip(instance)
				end
			end
			tooltip:AddSeparator()
		end
	end

	-- shortcut hints
	tooltip:AddLine(" ")
	line = tooltip:AddLine()
	tooltip:SetCell(line, 1, "|cffeda55fClick|r to open map.", "LEFT", 0)
	line = tooltip:AddLine()
	tooltip:SetCell(line, 1, "|cffeda55fRight-Click|r to open the options menu.", "LEFT", 0)
	line = tooltip:AddLine()
	tooltip:SetCell(line, 1, "|cffeda55fShift-Click|r to insert position into chat edit box.", "LEFT", 0)
	if  profileDB.show_recommended then
		line = tooltip:AddLine()
		tooltip:SetCell(line, 1, "|cffeda55fClick on recommended item|r to see walk path to it.", "LEFT", 0)
	end
	if  profileDB.show_atlasonctrl and _G.Atlas_Toggle then
		line = tooltip:AddLine()
		tooltip:SetCell(line, 1, "|cffeda55fControl-Click|r to open Atlas.", "LEFT", 0)
	end

	tooltip:Show()
end

function addon.obj.OnLeave() end
