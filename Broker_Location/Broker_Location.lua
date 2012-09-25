-------------------------------------------------------------------------------
-- Upvalued Lua globals.
-------------------------------------------------------------------------------
local _G = getfenv(0)

local string = _G.string

local tourist = LibStub("LibTourist-3.0")
local tablet = AceLibrary("Tablet-2.0")
local frame = CreateFrame("Frame", "Broker_Location")

local dataobj = LibStub("LibDataBroker-1.1"):NewDataObject("Broker_Location", {
	type	= "data source",
	icon	= "Interface\\Icons\\INV_Misc_Map07.png",
	label	= "Location",
	text	= "Updating..."
})

local elapsed = 0
local subZoneText, zoneText, pvpType, isArena, _
local table_insert = table.insert

-------------------------------------------------------------------------------
-- Options table
-------------------------------------------------------------------------------
local options = {
	name = "Broker_Location",
	type = "group",
	args = {
		confdesc = {
			order = 1,
			type = "description",
			name = "LDB plugin that shows recommended zones and zone info.\n",
			cmdHidden = true
		},
		displayheader = {
			order = 2,
			type = "header",
			name = "Display Options",
		},
		show_zone = {
			type = 'toggle', width = "full",
			name = "Show Main Zone name",
			desc = "Show or hide the main Zone name.",
			order = 3,
			get = function() return Broker_LocationDB.show_zone end,
			set = function(_,v)	Broker_LocationDB.show_zone = v end,
		},
		show_subzone = {
			type = 'toggle', width = "full",
			name = "Show sub Zone name",
			desc = "Show or hide the sub Zone name.",
			order = 4,
			get = function() return Broker_LocationDB.show_subzone end,
			set = function(_,v)	Broker_LocationDB.show_subzone = v end,
		},
		show_cords = {
			type = 'toggle', width = "full",
			name = "Show Coordinates",
			desc = "Show or hide Coordinates.",
			order = 5,
			get = function() return Broker_LocationDB.show_cords end,
			set = function(_,v)	Broker_LocationDB.show_cords = v end,
		},
		show_zonelevel = {
			type = 'toggle', width = "full",
			name = "Show Zone level",
			desc = "Show or hide the zone level.",
			order = 6,
			get = function() return Broker_LocationDB.show_zonelevel end,
			set = function(_,v)	Broker_LocationDB.show_zonelevel = v end,
		},
		show_minimap = {
			type = 'toggle', width = "full",
			name = "Show location above minimap.",
			desc = "Show or hide the text displayed above the minimap.",
			order = 7,
			get = function() return Broker_LocationDB.show_minimap end,
			set = function(_,v)
				Broker_LocationDB.show_minimap = v
				frame:updateMinimapZoneTextButton()
			end,
		},
		tooltipheader = {
			order = 10,
			type = "header",
			name = "Tooltip Options",
		},
		show_recommended = {
			type = 'toggle', width = "full",
			name = "Show recommended zones/instances",
			desc = "Show or hide the recommended zones/instances.",
			order = 11,
			get = function() return Broker_LocationDB.show_recommended end,
			set = function(_,v)	Broker_LocationDB.show_recommended = v end,
		},
		show_atlasonctrl = {
			type = 'toggle', width = "full",
			name = "Show Atlas on Control+Click",
			desc = "Show Atlas map instead of default when Control Clicking.",
			order = 12,
			get = function() return Broker_LocationDB.show_atlasonctrl end,
			set = function(_,v)	Broker_LocationDB.show_atlasonctrl = v end,
		},
	}
}

LibStub("AceConfig-3.0"):RegisterOptionsTable("Broker_Location", options)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Broker_Location")

--------------------------------------------------------------------------------------------------------
-- event handlers
--------------------------------------------------------------------------------------------------------
function frame:PLAYER_LOGIN()
	if not Broker_LocationDB then
	-- initialize default configuration
		Broker_LocationDB = {
			show_zone = true,
			show_subzone = true,
			show_cords = true,
			show_zonelevel = true,
			show_minimap = false,
			show_recommended = true,
			show_atlasonctrl = false
		}
	end
	frame:updateMinimapZoneTextButton()
end

--------------------------------------------------------------------------------------------------------
-- Broker_Location functions
--------------------------------------------------------------------------------------------------------
function frame:updateMinimapZoneTextButton()
	if Broker_LocationDB.show_minimap then
		MinimapBorderTop:Show()
		MinimapZoneTextButton:Show()
		MiniMapWorldMapButton:Show()
	else
		MinimapBorderTop:Hide()
		MinimapZoneTextButton:Hide()
		MiniMapWorldMapButton:Hide()
	end
	--MinimapCluster:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT") --conflicts with other map mods
end

local function update_Broker()
	subZoneText = GetSubZoneText() or ""
	zoneText = GetRealZoneText() or ""

	local displayLine = ""

	-- zone and subzone
	if Broker_LocationDB.show_zone then
		displayLine = zoneText
	end

	if Broker_LocationDB.show_subzone then
		if (displayLine ~= "") and (subZoneText ~= "") and (subZoneText ~= zoneText) then
			displayLine = displayLine .. ": " .. subZoneText
		elseif (subZoneText ~= "") then
			displayLine = subZoneText
		else
			displayLine = zoneText
		end
	end

	-- co-ords
	if Broker_LocationDB.show_cords then
		local x, y = GetPlayerMapPosition("player")
		if x ~= 0 and y ~= 0 then
			if displayLine ~= "" then
				displayLine = displayLine .. " "
			end
			displayLine = displayLine .. string.format("(%.0f, %.0f)", x * 100, y * 100)
		end
	end

	local r, g, b = tourist:GetFactionColor(zoneText)
	if displayLine ~= "" then
		displayLine = string.format("|cff%02x%02x%02x%s|r", r*255, g*255, b*255, displayLine)
	end

	-- level range
	if Broker_LocationDB.show_zonelevel then
		local low, high = tourist:GetLevel(zoneText)
		if low > 0 and high > 0 then
			if displayLine ~= "" then
				displayLine = displayLine .. " "
			end

			r, g, b = tourist:GetLevelColor(zoneText)
			displayLine = displayLine .. string.format("|cff%02x%02x%02x[%d-%d]|r", r*255, g*255, b*255, low, high)
		end
	end

	dataobj.text = displayLine
end

local currentPath = nil
function dataobj:SetCurrentPath(zone)
	if currentPath == zone then
		currentPath = nil
	else
		currentPath = zone
	end
end

function dataobj:updateTooltip()
	local show_recommended_zones = true  -- Future config
	local cat = tablet:AddCategory(
		'columns', 2,
		'child_textR', 1,
		'child_textG', 1,
		'child_textB', 0,
		'child_text2R', 1,
		'child_text2G', 1,
		'child_text2B', 1
	)

	cat:AddLine(
		'text', "Zone:",
		'text2', zoneText
	)

	if subZoneText ~= zoneText then
		cat:AddLine(
			'text', "Subzone:",
			'text2', subZoneText
		)
	end

	local text
	local r, g, b = 1, 1, 0
	pvpType, _, _ = GetZonePVPInfo()
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
		r, g, b = 1, 0.7, 0.10
	else
		text = UNKNOWN or "?"
	end

	cat:AddLine(
		'text', "Status:",
		'text2', text,
		'text2R', r,
		'text2G', g,
		'text2B', b
	)

	local x, y = GetPlayerMapPosition("player")
	if x > 0 and y > 0 then
		cat:AddLine(
			'text', "Coordinates:",
			'text2', string.format("%.0f, %.0f", x*100, y*100)
		)
	end

	local continent = tourist:GetContinent(zoneText)
	cat:AddLine(
		'text', "Continent:",
		'text2', continent,
		'text2R', 0,
		'text2G', 1,
		'text2B', 0
	)

	local low, high = tourist:GetLevel(zoneText)
	if low >= 1 and high >= 1 then
		local r, g, b = tourist:GetLevelColor(zoneText)
		cat:AddLine(
			'text', "Level range:",
			'text2', low == high and low or string.format("%d-%d", low, high),
			'text2R', r,
			'text2G', g,
			'text2B', b
		)
	end

	local minFish = tourist:GetFishingLevel(zoneText)
	if minFish then
		local r,g,b = 1,0,0
			local _, _, _, fishSkill = GetProfessions()
			if fishSkill ~= nil then
				local skillName, _, skillRank = GetProfessionInfo(fishSkill)
				if minFish < skillRank then
					r,g,b = 0,1,0
				end
			end
		cat:AddLine(
			'text', "Fishing:",
			'text2', minFish,
			'text2R', r,
			'text2G', g,
			'text2B', b
		)
	end

	if tourist:DoesZoneHaveInstances(zoneText) then
		cat = tablet:AddCategory(
			'columns', 2,
			'text', "Instances",
			'child_textR', 1,
			'child_textG', 1,
			'child_textB', 0
		)

		for instance in tourist:IterateZoneInstances(zoneText) do
			local low, high = tourist:GetLevel(instance)
			local r, g, b = tourist:GetLevelColor(instance)
			cat:AddLine(
				'text', instance,
				'text2', low == high and low or string.format("%d-%d", low, high),
				'text2R', r,
				'text2G', g,
				'text2B', b
			)
		end
	end

	if Broker_LocationDB.show_recommended then
		cat = tablet:AddCategory(
			'columns', 3,
			'text', "Recommended zones"
		)

		for zone in tourist:IterateRecommendedZones() do
			local low, high = tourist:GetLevel(zone)
			local r1, g1, b1 = tourist:GetFactionColor(zone)
			local r2, g2, b2 = tourist:GetLevelColor(zone)
			local zContinent = tourist:GetContinent(zone)
			cat:AddLine(
				'text', zone,
				'textR', r1,
				'textG', g1,
				'textB', b1,
				'text2', low == high and low or string.format("%d-%d", low, high),
				'text2R', r2,
				'text2G', g2,
				'text2B', b2,
				'text3', zContinent,
				'text3R', continent == zContinent and 0 or 1,
				'text3G', 1,
				'text3B', 0,
				'arg1', self,
				'func', "SetCurrentPath",
				'arg2', zone
			)
			if zone == currentPath then
				local c = cat:AddCategory(
					'text', string.format("    Walk path from %s to %s:", zoneText, zone),
					'hideBlankLine', true
				)
				local found = false
				for z in tourist:IteratePath(zoneText, zone) do
					found = true
					local low, high = tourist:GetLevel(z)
					local r1, g1, b1 = tourist:GetFactionColor(z)
					local r2, g2, b2 = tourist:GetLevelColor(z)
					local zContinent = tourist:GetContinent(z)
					c:AddLine(
						'text', "    " .. (z == currentPath and z or z .. " ->"),
						'textR', r1,
						'textG', g1,
						'textB', b1,
						'text2', low == 0 and "" or low == high and low or string.format("%d-%d", low, high),
						'text2R', r2,
						'text2G', g2,
						'text2B', b2,
						'text3', zContinent == UNKNOWN and "" or zContinent,
						'text3R', continent == zContinent and 0 or 1,
						'text3G', 1,
						'text3B', 0
					)
				end
				if not found then
					c:AddLine(
						'text', "    No path found"
					)
				end
			end
		end

		if tourist:HasRecommendedInstances() then
			cat = tablet:AddCategory(
				'columns', 4,
				'text', "Recommended instances",
				'child_text3R', 1,
				'child_text3G', 1,
				'child_text3B', 0,
				'child_text4R', 1,
				'child_text4G', 1,
				'child_text4B', 0
			)

			for instance in tourist:IterateRecommendedInstances() do
				local low, high = tourist:GetLevel(instance)
				local r1, g1, b1 = tourist:GetFactionColor(instance)
				local r2, g2, b2 = tourist:GetLevelColor(instance)
				local groupSize = tourist:GetInstanceGroupSize(instance)
				cat:AddLine(
					'text', instance,
					'textR', r1,
					'textG', g1,
					'textB', b1,
					'text2', low == high and low or string.format("%d-%d", low, high),
					'text2R', r2,
					'text2G', g2,
					'text2B', b2,
					'text3', groupSize > 0 and string.format("%d-man", groupSize) or "",
					'text4', tourist:GetInstanceZone(instance),
					'arg1', self,
					'func', "SetCurrentPath",
					'arg2', instance
				)

				if instance == currentPath then
					local c = cat:AddCategory(
						'text', string.format("    Walk path from %s to %s:", zoneText, instance),
						'hideBlankLine', true
					)
					local found = false
					for z in tourist:IteratePath(zoneText, instance) do
						found = true
						local low, high = tourist:GetLevel(z)
						local r1, g1, b1 = tourist:GetFactionColor(z)
						local r2, g2, b2 = tourist:GetLevelColor(z)
						local zContinent = tourist:GetContinent(z)
						c:AddLine(
							'text', "    " .. (z == currentPath and z or z .. " ->"),
							'textR', r1,
							'textG', g1,
							'textB', b1,
							'text2', low == 0 and "" or low == high and low or string.format("%d-%d", low, high),
							'text2R', r2,
							'text2G', g2,
							'text2B', b2,
							'text3', zContinent == UNKNOWN and "" or zContinent,
							'text3R', continent == zContinent and 0 or 1,
							'text3G', 1,
							'text3B', 0
						)
					end
					if not found then
						c:AddLine(
							'text', "    No path found"
						)
					end
				end
			end
		end
	end

	local hint = "|cffeda55fClick|r to open map" .. ". " ..
		"|cffeda55fShift-Click|r to insert position into chat edit box"

	if  Broker_LocationDB.show_atlasonctrl and Atlas_Toggle then
		hint = hint .. ". " .. "|cffeda55fControl-Click|r to open Atlas"
	end

	hint = hint .. "."

	tablet:SetHint(hint)
	tablet:SetTitle("Broker_Location")
end

function dataobj:OnClick(button)
	if button == "LeftButton" then
		if IsShiftKeyDown() then
			local edit_box = _G.ChatEdit_ChooseBoxForSend()
			local x, y = GetPlayerMapPosition("player")
			local message
			local coords = string.format("%.0f, %.0f", x * 100, y * 100)
				if zoneText ~= subZoneText then
					message = string.format("%s: %s (%s)", zoneText, subZoneText, coords)
				else
					message = string.format("%s (%s)", zoneText, coords)
				end
			_G.ChatEdit_ActivateChat(edit_box)
			edit_box:Insert(message)
		else
			if Atlas_Toggle and IsControlKeyDown() and Broker_LocationDB.show_atlasonctrl then
				Atlas_Toggle()
			else
				ToggleFrame(WorldMapFrame)
			end
		end
	end
	if button == "RightButton" then
			InterfaceOptionsFrame_OpenToCategory("Broker_Location")
	end
end

local function registertip(tip)
	if not tablet:IsRegistered(tip) then
		tablet:Register(tip,
			'children', function() dataobj:updateTooltip() end,
			'clickable', true,
			'point', function(frame)
				if frame:GetTop() > GetScreenHeight() / 2 then
					local x = frame:GetCenter()
					if x < GetScreenWidth() / 3 then
								return "TOPLEFT", "BOTTOMLEFT"
						elseif x < GetScreenWidth() * 2 / 3 then
								return "TOP", "BOTTOM"
						else
								return "TOPRIGHT", "BOTTOMRIGHT"
						end
					else
						local x = frame:GetCenter()
						if x < GetScreenWidth() / 3 then
								return "BOTTOMLEFT", "TOPLEFT"
						elseif x < GetScreenWidth() * 2 / 3 then
								return "BOTTOM", "TOP"
						else
								return "BOTTOMRIGHT", "TOPRIGHT"
						end
					end
				end,
			'dontHook', true
		)
	end

end

function dataobj.OnLeave(self) end
function dataobj.OnEnter(self)
	registertip(self)
	tablet:Open(self)
end

frame:SetScript("OnUpdate",
	function (self, el)
		elapsed = elapsed + el
		if (elapsed >= 1) then
			elapsed = 0
			update_Broker()
		end
	end
)

frame:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)
frame:RegisterEvent("PLAYER_LOGIN")
