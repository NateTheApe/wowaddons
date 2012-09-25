-- Minimap Button Handling

FishingBuddy.Minimap = {};

-- Taken from MobileMinimapButtons, per wowwiki
local MinimapShapes = {
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

function UpdateButtonPosition(frame, position, radius, rounding)
	if not radius then radius = 80 end
	if not rounding then rounding = 10 end
	local angle = math.rad(position) -- determine position on your own
	local x = math.sin(angle)
	local y = math.cos(angle)
	local q = 1;
	if x < 0 then
		q = q + 1;	-- lower
	end
	if y > 0 then
		q = q + 2;	-- right
	end
	local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
	local quadTable = MinimapShapes[minimapShape];
	if quadTable[q] then
		x = x*radius;
		y = y*radius;
	else
		local diagRadius = math.sqrt(2*(radius)^2)-rounding
		x = math.max(-radius, math.min(x*diagRadius, radius))
		y = math.max(-radius, math.min(y*diagRadius, radius))
	end
	frame:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

FishingBuddy.Minimap.Button_OnLoad = function(self)
	self:SetFrameLevel(self:GetFrameLevel()+1)
end

FishingBuddy.Minimap.Button_OnClick = function(self, button, down)
	if ( button == "RightButton" ) then
		if ( IsAltKeyDown() ) then
			ToggleFishingBuddyFrame("FishingOptionsFrame");
		else
			-- Toggle menu
			local menu = getglobal("FishingBuddyMinimapMenu");
			UIDropDownMenu_Initialize(menu, FishingBuddy.Minimap.Menu_Initialize, "MENU");
			menu.point = "TOPRIGHT";
			menu.relativePoint = "CENTER";
			ToggleDropDownMenu(1, nil, menu, "FishingBuddyMinimapButton", 0, 0);
		end
	elseif ( FishingBuddy.IsSwitchClick("MinimapClickToSwitch") ) then
		FishingBuddy.Command(FBConstants.SWITCH);
	else
		FishingBuddy.Command("");
	end
end

local dragradius;
local function BeingDragged()
	-- Thanks to Gello for this code
	local xpos,ypos = GetCursorPosition();
	local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom();

	xpos = xmin-xpos/UIParent:GetScale()+dragradius;
	ypos = ypos/UIParent:GetScale()-ymin-dragradius;

	local ang = math.deg(math.atan2(ypos,xpos));
	if ( ang < 0 ) then
		ang = ang + 360;
	end
	FishingBuddy.SetSetting("MinimapButtonPosition", ang-90);
	FishingBuddyMinimapButton_MoveButton();
end

local function Button_OnDragStart(self, button)
	dragradius = FishingBuddy.GetSetting("MinimapButtonRadius");
	self:SetScript("OnUpdate", BeingDragged);
end

local function Button_OnDragStop(self, button)
	self:SetScript("OnUpdate", nil);
end

FishingBuddy.Minimap.Button_OnEnter = function(self)
	if ( GameTooltip.fbmmbfinished ) then
		return;
	end
	GameTooltip.fbmmbfinished = 1;
	GameTooltip:SetOwner(FishingBuddyMinimapFrame, "ANCHOR_LEFT");
	GameTooltip:AddLine(FBConstants.NAME);
	local text = FishingBuddy.TooltipBody("MinimapClickToSwitch");
	GameTooltip:AddLine(text,.8,.8,.8,1);
	GameTooltip:Show();
end

FishingBuddy.Minimap.Button_OnLeave = function(self)
	GameTooltip:Hide();
	GameTooltip.fbmmbfinished = nil;
end

FishingBuddyMinimapButton_MoveButton = function()
	if ( FishingBuddy.IsLoaded() ) then
		local position = FishingBuddy.GetSetting("MinimapButtonPosition");
		local radius = FishingBuddy.GetSetting("MinimapButtonRadius");
		UpdateButtonPosition(FishingBuddyMinimapFrame, position, radius);
	end
end

local function UpdateMinimap()
	FishingBuddyMinimapButton_MoveButton();
	if ( FishingBuddy.GetSettingBool("MinimapButtonVisible") and
		  Minimap:IsVisible() ) then
		FishingBuddyMinimapButton:EnableMouse(true);
		FishingBuddyMinimapButton:Show();
		FishingBuddyMinimapFrame:Show();
	else
		FishingBuddyMinimapButton:EnableMouse(false);
		FishingBuddyMinimapButton:Hide();
		FishingBuddyMinimapFrame:Hide();
	end
	if ( FishingBuddy.GetSettingBool("MinimapMoveable") ) then
		FishingBuddyMinimapButton:SetScript("OnDragStart", Button_OnDragStart);
		FishingBuddyMinimapButton:SetScript("OnDragStop", Button_OnDragStop);
		FishingBuddyMinimapButton:RegisterForDrag("LeftButton");
	else
		FishingBuddyMinimapButton:SetScript("OnDragStart", nil);
		FishingBuddyMinimapButton:SetScript("OnDragStop", nil);
		FishingBuddyMinimapButton:RegisterForDrag();
	end
	
end

function FishingBuddy_ToggleMinimap()
	if ( FishingBuddy.SavedToggleMinimap ) then
		FishingBuddy.SavedToggleMinimap();
	end
	UpdateMinimap();
end

FishingBuddy.Minimap.Menu_Initialize = function()
	FishingBuddy.MakeDropDown(FBConstants.CLICKTOSWITCH_ONOFF, "MinimapClickToSwitch");
end

local sliders = {
	{ ["name"] = "MinimapPosSlider",
	  ["format"] = FBConstants.MINIMAPBUTTONPLACEMENT.." - %d\194\176",
	  ["min"] = 0,
	  ["max"] = 360,
	  ["rightextra"] = 32,
	  ["setting"] = "MinimapButtonPosition",
		["action"] = FishingBuddyMinimapButton_MoveButton,
	},
	{ ["name"] = "MinimapRadSlider",
	  ["format"] = FBConstants.MINIMAPBUTTONRADIUS.." - %d",
	  ["min"] = 70,
	  ["max"] = 150,
	  ["rightextra"] = 32,
	  ["setting"] = "MinimapButtonRadius",
		["action"] = FishingBuddyMinimapButton_MoveButton,
	},
};

local MinimapOptions = {
	["MinimapButtonVisible"] = {
		["text"] = FBConstants.CONFIG_MINIMAPBUTTON_ONOFF,
		["tooltip"] = FBConstants.CONFIG_MINIMAPBUTTON_INFO,
		["v"] = 1,
		["default"] = 1, },
	["MinimapClickToSwitch"] = {
		["text"] = FBConstants.CLICKTOSWITCH_ONOFF,
		["tooltip"] = FBConstants.CLICKTOSWITCH_INFO,
		["v"] = 1,
		["default"] = 0,
		["deps"] = { ["MinimapButtonVisible"] = "d", },
	},
	["MinimapMoveable"] = {
		["text"] = FBConstants.CONFIG_MINIMAPMOVE_ONOFF,
		["tooltip"] = FBConstants.CONFIG_MINIMAPMOVE_INFO,
		["v"] = 1,
		["default"] = 1,
		["deps"] = { ["MinimapButtonVisible"] = "d", }, },
	["MinimapPosSlider"] = {
		["tooltip"] = FBConstants.MINIMAPBUTTONPLACEMENTTOOLTIP,
		["deps"] = { ["MinimapButtonVisible"] = "d", },
		["button"] = "FishingBuddyOption_MinimapPosSlider",
		["margin"] = { 12, 16 }, },
	["MinimapRadSlider"] = {
		["tooltip"] = FBConstants.MINIMAPBUTTONRADIUSTOOLTIP,
		["deps"] = { ["MinimapButtonVisible"] = "d", ["MinimapPosSlider"] = "i", },
		["button"] = "FishingBuddyOption_MinimapRadSlider",
		["margin"] = { 12, 16 }, },
};

local MinimapEvents = {};
MinimapEvents["VARIABLES_LOADED"] = function()
	UpdateMinimap();
end

MinimapEvents[FBConstants.OPT_UPDATE_EVT] = function()
	UpdateMinimap();
end

FishingBuddy.Minimap.OnLoad = function(self)
	FishingBuddyMinimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	FishingBuddy.API.RegisterHandlers(MinimapEvents);

	for _,info in ipairs(sliders) do
		info.name = "FishingBuddyOption_"..info.name;
		FishingBuddy.Slider_Create(info);
	end
	FishingBuddy.OptionsFrame.HandleOptions(MINIMAP_LABEL, "Interface\\Icons\\INV_Misc_Map02", MinimapOptions);
end
