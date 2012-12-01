local L, config = OneRingLib.lang, {buttonTemplate = "UIPanelButtonTemplate"}
do -- ext.config
	local function onShowRestore()
		InterfaceOptionsFrame:SetFrameStrata("HIGH");
	end
	local function onShowRefresh(self)
		InterfaceOptionsFrame:SetFrameStrata("HIGH");
		self:refresh();
	end
	function config.createFrame(name, parent, refreshOnShow)
		local frame = CreateFrame("Frame", nil, UIParent);
			frame.name, frame.parent = name, parent; InterfaceOptions_AddCategory(frame); frame:Hide();
		frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
			frame.title:SetPoint("TOPLEFT", 16, -16); frame.title:SetText(name);
		frame.version = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
			frame.version:SetPoint("TOPRIGHT", -16, -16);
		frame.desc = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
			frame.desc:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -8);
			frame.desc:SetPoint("RIGHT", -32, 0);
			frame.desc:SetJustifyV("TOP")
			frame.desc:SetJustifyH("LEFT");
			frame.desc:SetWordWrap(1);
		frame:SetScript("OnShow", refreshOnShow and onShowRefresh or onShowRestore);
		frame:Hide();
		return frame;
	end
	do -- undo
		local undoStack = {};
		function config.unwindUndo()
			local entry;
			for i=#undoStack,1,-1 do
				entry, undoStack[i] = undoStack[i];
				EC_pcall("OPC.Undo", "[" .. entry.key .. "]", entry.func, unpack(entry, 1, entry.n));
			end
		end
		function config.clearUndo()
			table.wipe(undoStack);
		end
		function config.pushUndo(key, func, ...)
			if key ~= "Profile" then
				for i=#undoStack,1,-1 do
					if undoStack[i].key == key then
						return;
					elseif undoStack[i].key == "Profile" then
						break;
					end
				end
			end
			table.insert(undoStack, {key=key, func=func, n=select("#", ...), ...});
		end
	end
	do -- bind
		local unbindMap, activeCaptureButton = {};
		local function MapMouseButton(button)
			if button == "MiddleButton" then return "BUTTON3" end
			if type(button) == "string" and (tonumber(button:match("^Button(%d+)"))) or 1 > 3 then
				return button:upper();
			end
		end
		local function Deactivate(self)
			self:UnlockHighlight(); self:EnableKeyboard(false);
			self:SetScript("OnKeyDown", nil); self:SetScript("OnHide", nil);
			activeCaptureButton = activeCaptureButton ~= self and activeCaptureButton or nil;
			if unbindMap[self:GetParent()] then unbindMap[self:GetParent()]:Disable(); end
			return self
		end
		local function SetBind(self, bind)
			if not (bind and (bind:match("^[LR]?ALT$") or bind:match("^[LR]?CTRL$") or bind:match("^[LR]?SHIFT$"))) then
				Deactivate(self);
				if bind == "ESCAPE" then return; end
				local bind, p = bind and ((IsAltKeyDown() and "ALT-" or "") ..  (IsControlKeyDown() and "CTRL-" or "") .. (IsShiftKeyDown() and "SHIFT-" or "") .. bind), self:GetParent();
				if p and type(p.SetBinding) == "function" then p.SetBinding(self, bind); end
			end
		end
		local function OnClick(self, button)
			if activeCaptureButton then
				local deactivated, mappedButton = Deactivate(activeCaptureButton), MapMouseButton(button);
				if deactivated == self and (mappedButton or button == "RightButton") then SetBind(self, mappedButton); end
				if deactivated == self then return; end
			end
			if IsAltKeyDown() and activeCaptureButton == nil and self:GetParent().OnAltClick then return self:GetParent().OnAltClick(self, button); end
			activeCaptureButton = self;
			self:LockHighlight();	self:EnableKeyboard(true);
			self:SetScript("OnKeyDown", SetBind); self:SetScript("OnHide", Deactivate);
			if unbindMap[self:GetParent()] then unbindMap[self:GetParent()]:Enable(); end
		end
		local function UnbindClick(self)
			if activeCaptureButton and unbindMap[activeCaptureButton:GetParent()] == self then
				local p = activeCaptureButton:GetParent();
				if p and type(p.SetBinding) == "function" then p.SetBinding(activeCaptureButton, false); end
				Deactivate(activeCaptureButton);
			end
		end
		local function IsCapturingBinding(self)
			return activeCaptureButton == self;
		end
		local function bindNameLookup(capture) return _G["KEY_" .. capture]; end
		local function bindFormat(bind)
			return bind and bind ~= "" and bind:gsub("[^%-]+$", bindNameLookup) or L"Not bound";
		end
		config.bindingFormat = bindFormat
		local function SetBindingText(self, bind, pre, post)
			if type(bind) == "string" and bind:match("%b[]") then
				return SetBindingText(self, SecureCmdOptionParse(bind), pre, post or " |cff20ff20[+]|r")
			end
			return self:SetText((pre or "") .. bindFormat(bind) .. (post or ""))
		end
		function config.createBindingButton(name, parent)
			local btn = CreateFrame("Button", name, parent, config.buttonTemplate);
			btn:SetSize(120, 22); btn:RegisterForClicks("AnyUp"); btn:SetScript("OnClick", OnClick);
			btn:SetText(" "); btn:GetFontString():SetMaxLines(1);
			btn.IsCapturingBinding, btn.SetBindingText = IsCapturingBinding, SetBindingText;
			return btn, unbindMap[parent];
		end
		function config.createUnbindButton(name, parent)
			local btn = CreateFrame("Button", name, parent, config.buttonTemplate);
			btn:Disable(); btn:SetSize(120, 22); unbindMap[parent] = btn;
			btn:SetScript("OnClick", UnbindClick);
			return btn;
		end
	end
	OneRingLib.ext.config = config;
end

local function LBFDetect() return LibStub and LibStub("Masque", true) and true; end
local OPC_OptionSets = {
	{ "Behavior",
		{"bool", "RingAtMouse", caption="Center rings at mouse"},
		{"bool", "CenterAction", caption="Quick action at ring center"},
		{"bool", "SliceBinding", caption="Per-slice bindings"},
		{"bool", "ClickActivation", caption="Activate on left click"},
		{"bool", "ClickPriority", caption="Make rings top-most", depOn="ClickActivation", depValue=true, otherwise=false},
		{"bool", "NoClose", caption="Leave open after use", depOn="ClickActivation", depValue=true, otherwise=false},
		{"bool", "UseDefaultBindings", caption="Use default ring bindings"},
		{"range", "MouseBucket", caption="Scroll wheel sensitivity", 5, 1, 1, stdLabels=true},
		{"range", "RingScale", caption="Ring Scale", suffix=" |cffffd500(%0.1f)|r", 0.1, 2},
	}, { "Appearance",
		{"bool", "MultiIndication", caption="Per-slice icons"},
		{"bool", "ShowCenterIcon", caption="Center icon", depOn="MultiIndication", depValue=false, otherwise=false},
		{"bool", "GhostMIRings", caption="Nested rings", depOn="MultiIndication", depValue=true, otherwise=false},
		{"bool", "ShowKeys", caption="Per-slice bindings", depOn="SliceBinding", depValue=true, depOn2="MultiIndication", depValue2=true, otherwise=false},
		{"bool", "ShowCenterCaption", caption="Center caption"},
		{"bool", "ShowCooldowns", caption="Numeric cooldowns"},
		{"bool", "UseGameTooltip", caption="Show tooltips"},
		{"bool", "HideStanceBar", caption="Hide stance bar", global=true},
		{"bool", "UseBF", caption="Use Masque", global=true, req=LBFDetect},
	}, { "Animation",
		{"bool", "MIScale", caption="Enlarge selected slice", depOn="MultiIndication", depValue=true, otherwise=false},
		{"bool", "MISpinOnHide", caption="Outward spiral on hide", depOn="MultiIndication", depValue=true, otherwise=false},
		{"range", "XTScaleSpeed", -4, 4, 0.2, caption="Scale animation speed"},
		{"range", "XTPointerSpeed", -4, 4, 0.2, caption="Pointer rotation speed"},
		{"range", "XTZoomTime", 0, 1, 0.1, caption="Zoom-in/out time", suffix=" |cffffd500(%.1f sec)|r"},
		{"range", "XTRotationPeriod", 1, 10, 0.2, caption="Rotation period", suffix=" |cffffd500(%.1f sec)|r"}
	}
};

local frame = config.createFrame("OPie", nil, true);
	frame.version:SetFormattedText("%s (%d.%d)", OneRingLib:GetVersion());
local OPC_Profile = CreateFrame("Frame", "OPC_Profile", frame, "UIDropDownMenuTemplate");
	OPC_Profile:SetPoint("TOPLEFT", frame.desc, "BOTTOMLEFT", 0, -8); UIDropDownMenu_SetWidth(OPC_Profile, 200);
local OPC_OptionDomain = CreateFrame("Frame", "OPC_OptionDomain", frame, "UIDropDownMenuTemplate");
	OPC_OptionDomain:SetPoint("LEFT", OPC_Profile, "RIGHT", 0, 0);	UIDropDownMenu_SetWidth(OPC_OptionDomain, 220);

local OPC_Widgets, OPC_AlterOption, OPC_BlockInput = {};
do -- Widget construction
	local build = {};
	local function notifyChange(self, ...)
		if not OPC_BlockInput then
			OPC_AlterOption(self, self.id, self:IsObjectType("Slider") and self:GetValue() or (not not self:GetChecked()), ...);
		end
	end
	local function OnStateChange(self)
		local a = self:IsEnabled() == 1 and 1 or 0.6;
		self.text:SetVertexColor(a,a,a);
	end
	function build.bool(v, rel, ofsY, halfpoint, rowHeight)
		local b = CreateFrame("CheckButton", "OPC_Option_" .. v[2], frame, "InterfaceOptionsCheckButtonTemplate");
		b:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		b.id, b.text, b.desc = v[2], b.Text, v;
		b:SetPoint("TOPLEFT", rel, "BOTTOMLEFT", halfpoint and 300 or 5, ofsY);
		b:SetScript("OnClick", notifyChange); hooksecurefunc(b, "Enable", OnStateChange); hooksecurefunc(b, "Disable", OnStateChange);
		return b, ofsY - (halfpoint and rowHeight or 0), not halfpoint, halfpoint and 0 or 20;
	end
	function build.range(v, rel, ofsY, halfpoint, rowHeight)
		if halfpoint then ofsY = ofsY - rowHeight; end
		local b = CreateFrame("Slider", "OPC_Slider_" .. v[2], frame, "OptionsSliderTemplate");
		b:SetMinMaxValues(v[3] < v[4] and v[3] or -v[3], v[4] > v[3] and v[4] or -v[4]); b:SetValueStep(v[5] or 0.1); b:SetHitRectInsets(0,0,0,0);
		b.id, b.text, b.hi, b.lo, b.desc = v[2], _G["OPC_Slider_" .. v[2] .. "Text"], _G["OPC_Slider_" .. v[2] .. "High"], _G["OPC_Slider_" .. v[2] .. "Low"], v;
		b.hi:ClearAllPoints(); b.hi:SetPoint("LEFT", b, "RIGHT", 2, 1);
		b.lo:ClearAllPoints(); b.lo:SetPoint("RIGHT", b, "LEFT", -2, 1);
		b.text:ClearAllPoints(); b.text:SetPoint("TOPLEFT", rel, "BOTTOMLEFT", 33, ofsY-7);
		if not v.stdLabels then b.lo:SetText(v[3]); b.hi:SetText(v[4]); end
		b:SetPoint("TOPRIGHT", rel, "BOTTOMRIGHT", -103, ofsY-5);
		b:SetScript("OnValueChanged", notifyChange)
		return b, ofsY - 20, false, 0;
	end

	local cRel, cY, halfpoint, rowHeight = frame.desc, -35, false;
	for i, v in ipairs(OPC_OptionSets) do
		v.label = frame:CreateFontString("OPC_Section" .. i, "OVERLAY", "GameFontNormalLarge");
		v.label:SetPoint("TOP", cRel, "BOTTOM", -50, cY-10); v.label:SetJustifyH("LEFT")
		v.label:SetPoint("LEFT", frame, "LEFT", 15, 0)
		cY, halfpoint, rowHeight = cY - 30, false, 0;
		for j=2,#v do
			v[j].widget, cY, halfpoint, rowHeight = build[v[j][1]](v[j], cRel, cY, halfpoint, rowHeight);
			OPC_Widgets[v[j][2]], v[j].widget.control = v[j].widget, v[j];
		end
		if halfpoint then cY = cY - rowHeight; end
	end
end

local OR_DeletedProfiles, OR_CurrentOptionsDomain = {};

function OPC_AlterOption(widget, option, newval, ...)
	if (...) == "RightButton" then newval = nil; end
	if widget.control[1] == "range" and widget.control[3] > widget.control[4] and type(newval) == "number" then newval = -newval; end
	local _, setting = OneRingLib:GetOption(option, OR_CurrentOptionsDomain);
	OneRingLib:SetOption(option, newval, OR_CurrentOptionsDomain);
	local key = ("Option%s:%s"):format(OR_CurrentOptionsDomain and ("." .. OR_CurrentOptionsDomain) or "#G", option);
	config.pushUndo(key, OneRingLib.SetOption, OneRingLib, option, setting, OR_CurrentOptionsDomain);
	local setval = OneRingLib:GetOption(option, OR_CurrentOptionsDomain);
	if widget:IsObjectType("Slider") then
		widget.text:SetText(L(widget.desc.caption) .. (widget.desc.suffix or ""):format(setval));
		OPC_BlockInput = true; widget:SetValue(setval * (widget.control[3] > widget.control[4] and -1 or 1)); OPC_BlockInput = false;
	elseif setval ~= newval then
		widget:SetChecked(setval and 1 or nil);
	end
	for i,set in ipairs(OPC_OptionSets) do for j=2,#set do local v = set[j]
		if v.depOn == option or v.depOn2 == option then
			local match = OneRingLib:GetOption(v.depOn, OR_CurrentOptionsDomain) == v.depValue and (v.depOn2 == nil or OneRingLib:GetOption(v.depOn2, OR_CurrentOptionsDomain) == v.depValue2);
			v.widget[match and "Enable" or "Disable"](v.widget);
			if match then
				v.widget:SetChecked(OneRingLib:GetOption(v[2], OR_CurrentOptionsDomain) or nil);
			else
				v.widget:SetChecked(v.otherwise or nil);
			end
		end
	end end
end
function OPC_OptionDomain:click(ringName)
	OR_CurrentOptionsDomain = ringName
	frame.refresh()
end
function OPC_OptionDomain:initialize()
	local info = UIDropDownMenu_CreateInfo();
	info.func, info.arg1, info.text, info.checked = OPC_OptionDomain.click, nil, L"Defaults for all rings", OR_CurrentOptionsDomain == nil and 1 or nil;
	UIDropDownMenu_AddButton(info);
	for i=1,OneRingLib:GetNumRings() do
		local name, key, macro, internal = OneRingLib:GetRingInfo(i);
		if internal == 0 or IsAltKeyDown() then
			info.text, info.arg1, info.checked = (L"Ring: %s"):format("|cffaaffff" .. (name or key) .. "|r"), key, key == OR_CurrentOptionsDomain and 1 or nil;
			UIDropDownMenu_AddButton(info);
		end
	end
end
local function OPC_Profile_AddNew(self)
	local name, frame = self.editBox:GetText():match("^%s*(.-)%s*$"), StaticPopupDialogs["ORC_PNAME"].userData; self.editBox:SetText("");
	if name == "" or OneRingLib:ProfileExists(kn) then return; end
	StaticPopup_Hide("ORC_PNAME");
	OneRingLib:SwitchProfile(name, true);
	config.pushUndo("ProfileCreate", OneRingLib.DeleteProfile, OneRingLib, name);
	config.pushUndo("Profile", OneRingLib.SwitchProfile, OneRingLib, (OneRingLib:GetCurrentProfile()));
	frame.refresh("profile")
end
function OPC_Profile:switch(arg1, frame)
	config.pushUndo("Profile", OneRingLib.SwitchProfile, OneRingLib, (OneRingLib:GetCurrentProfile()));
	OneRingLib:SwitchProfile(arg1);
	frame.refresh("profile");
end
function OPC_Profile:new(_, frame)
	StaticPopupDialogs["ORC_PNAME"] = StaticPopupDialogs["ORC_PNAME"] or {button1=TEXT(ACCEPT), button2=TEXT(CANCEL), hasEditBox=1, maxLetters=80, whileDead=1, timeout=0, hideOnEscape=true, OnHide = function(self) self.editBox:SetText(""); end, OnAccept=OPC_Profile_AddNew, EditBoxOnEnterPressed=function(self) OPC_Profile_AddNew(self:GetParent()); end};
	StaticPopupDialogs["ORC_PNAME"].userData, StaticPopupDialogs["ORC_PNAME"].text = frame, L"New profile name:";
	StaticPopup_Show("ORC_PNAME");
end
function OPC_Profile:delete(_, frame)
	OR_DeletedProfiles[OneRingLib:GetCurrentProfile()] = true;
	OPC_Profile.switch(self, "default", frame);
end
function OPC_Profile:initialize()
	local info = UIDropDownMenu_CreateInfo();
	info.func, info.arg2 = OPC_Profile.switch, self:GetParent();
	for ident, isActive in OneRingLib.Profiles do
		if not OR_DeletedProfiles[ident] then
			info.text, info.arg1, info.checked = ident, ident, isActive or nil;
			UIDropDownMenu_AddButton(info);
		end
	end
	info.text, info.disabled, info.checked, info.notCheckable, info.justifyH = "", true, nil, true, "CENTER"; UIDropDownMenu_AddButton(info);
	info.text, info.disabled, info.minWidth, info.func = L"Create a new profile", false, 200, OPC_Profile.new; UIDropDownMenu_AddButton(info);
	if OneRingLib:GetCurrentProfile() ~= "default" then
		info.text, info.func = L"Delete current profile", OPC_Profile.delete; UIDropDownMenu_AddButton(info);
	end
end
function frame.refresh()
	OPC_BlockInput = true;
	frame.desc:SetText(L"Customize indication options; right click on a checkbox to set to default (or global) value." .. "\n" .. L"OPie profiles allow you to save these settings and bindings on a per-specialization basis.");
	for i, v in pairs(OPC_OptionSets) do
		v.label:SetText(L(v[1]));
		for j=2,#v do
			v[j].widget.text:SetText(L(v.caption));
		end
	end
	local label = L"Defaults for all rings";
	if OR_CurrentOptionsDomain then
		local name, key = OneRingLib:GetRingInfo(OR_CurrentOptionsDomain);
		label = (L"Ring: %s"):format("|cffaaffff" .. (name or key) .."|r");
	end
	UIDropDownMenu_SetText(OPC_OptionDomain, label);
	UIDropDownMenu_SetText(OPC_Profile, L"Profile" .. ": " .. OneRingLib:GetCurrentProfile());
	for i, set in pairs(OPC_OptionSets) do for j=2,#set do
		local v, opttype, option = set[j], set[j][1], set[j][2];
		if opttype == "range" then
			v.widget:SetValue(OneRingLib:GetOption(option) * (v[3] < v[4] and 1 or -1));
			v.widget.text:SetText(v.caption .. (v.suffix or ""):format(v.widget:GetValue()));
		elseif opttype == "bool" then
			v.widget:SetChecked(OneRingLib:GetOption(option, OR_CurrentOptionsDomain) or nil);
			v.widget.text:SetText(L(v.caption))
		end
		if v.depOn then
			local match = OneRingLib:GetOption(v.depOn, OR_CurrentOptionsDomain) == v.depValue and (v.depOn2 == nil or OneRingLib:GetOption(v.depOn2, OR_CurrentOptionsDomain) == v.depValue2);
			v.widget[match and "Enable" or "Disable"](v.widget)
			if not match then v.widget:SetChecked(v.otherwise or nil); end
		end
		v.widget:SetShown(not v.global or OR_CurrentOptionsDomain == nil)
		if v.req then
			local ok, res = pcall(v.req)
			v.widget:SetShown(ok and res)
		end
	end end
	OPC_BlockInput = false;
end
function frame.cancel()
	table.wipe(OR_DeletedProfiles);
	config.unwindUndo();
	OR_CurrentOptionsDomain = nil
end
function frame.default()
	OneRingLib:ResetOptions(true);
	frame.okay(); -- Unfortunately, there's no going back
end
function frame.okay()
	config.clearUndo();
	for k in pairs(OR_DeletedProfiles) do
		OR_DeletedProfiles[k] = nil;
		OneRingLib:DeleteProfile(k);
	end
	OR_CurrentOptionsDomain = nil
end

local slashExtensions = {}
local function addSuffix(func, word, ...)
	if word then
		slashExtensions[word:lower()] = func
		addSuffix(func, ...)
	end
end
config.AddSlashSuffix = addSuffix

SLASH_OPIE1, SLASH_OPIE2 = "/opie", "/op";
SlashCmdList["OPIE"] = function(args, ...)
	local ext = slashExtensions[(args:match("%S+") or ""):lower()]
	if ext then
		ext(args, ...)
	elseif not frame:IsVisible() then
		InterfaceOptionsFrame_OpenToCategory(frame);
		if frame.collapsed then
			for i, button in pairs(InterfaceOptionsFrameAddOns.buttons) do
				if (type(button) == "table" and button.element == frame) then
					OptionsListButtonToggle_OnClick(button.toggle);
					break
				end
			end
		end
	end
end