local L, config, _, T, EV = OneRingLib.lang, {}, ...
OneRingLib.ext.config, EV = config, T.Evie
function config.createFrame(name, parent)
	local frame = CreateFrame("Frame", nil, UIParent)
		frame.name, frame.parent = name, parent
	frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLargeLeftTop")
		frame.title:SetPoint("TOPLEFT", 16, -16)
		frame.title:SetText(name)
	frame.version = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmallRight")
		frame.version:SetPoint("TOPRIGHT", -16, -16)
	frame.desc = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmallLeftTop")
		frame.desc:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -8)
		frame.desc:SetWidth(590)
		
	InterfaceOptions_AddCategory(frame)
	frame:Hide()
	return frame
end
do -- ext.config.ui
	local multilineInput do
		local function onNavigate(self, x,y, w,h)
			local scroller = self.scroll
			local occH, occP, y = scroller:GetHeight(), scroller:GetVerticalScroll(), -y
			if occP > y then
				occP = y -- too far
			elseif (occP + occH) < (y+h) then
				occP = y+h-occH -- not far enough
			else
				return
			end
			scroller:SetVerticalScroll(occP)
			local _, mx = scroller.ScrollBar:GetMinMaxValues()
			scroller.ScrollBar:SetMinMaxValues(0, occP < mx and mx or occP)
			scroller.ScrollBar:SetValue(occP)
		end
		local function onClick(self)
			self.input:SetFocus()
		end
		function multilineInput(name, parent, width)
			local scroller = CreateFrame("ScrollFrame", name .. "Scroll", parent, "UIPanelScrollFrameTemplate")
			local input = CreateFrame("Editbox", name, scroller)
			input:SetWidth(width)
			input:SetMultiLine(true)
			input:SetAutoFocus(false)
			input:SetTextInsets(2,4,0,2)
			input:SetFontObject(GameFontHighlight)
			input:SetScript("OnCursorChanged", onNavigate)
			scroller:EnableMouse(1)
			scroller:SetScript("OnMouseDown", onClick)
			scroller:SetScrollChild(input)
			input.scroll, scroller.input = scroller, input
			return input, scroller
		end
	end
	local function lineInput(parent, common, width)
		local input = CreateFrame("EditBox", nil, parent)
		input:SetAutoFocus(nil) input:SetSize(width or 150, 20)
		input:SetFontObject(ChatFontNormal)
		input:SetScript("OnEscapePressed", input.ClearFocus)
		local l, m, r = input:CreateTexture(nil, "BACKGROUND"), input:CreateTexture(nil, "BACKGROUND"), input:CreateTexture(nil, "BACKGROUND")
		l:SetSize(common and 8 or 32, common and 20 or 32) l:SetPoint("LEFT", common and -5 or -10, 0)
		l:SetTexture(common and "Interface\\Common\\Common-Input-Border" or "Interface\\ChatFrame\\UI-ChatInputBorder-Left2")
		r:SetSize(common and 8 or 32, common and 20 or 32) r:SetPoint("RIGHT", common and 0 or 10, 0)
		r:SetTexture(common and "Interface\\Common\\Common-Input-Border" or "Interface\\ChatFrame\\UI-ChatInputBorder-Right2")
		m:SetHeight(common and 20 or 32) m:SetPoint("LEFT", l, "RIGHT") m:SetPoint("RIGHT", r, "LEFT")
		m:SetTexture(common and "Interface\\Common\\Common-Input-Border" or "Interface\\ChatFrame\\UI-ChatInputBorder-Mid2")
		if common then
			l:SetTexCoord(0,1/16, 0,5/8)
			r:SetTexCoord(15/16,1, 0,5/8)
			m:SetTexCoord(1/16,15/16, 0,5/8)
		else
			m:SetHorizTile(true)
		end
		return input
	end
	config.ui = {multilineInput=multilineInput, lineInput=lineInput}
end
do -- ext.config.bind
	local unbindMap, activeCaptureButton = {};
	local alternateFrame = CreateFrame("Frame", nil, UIParent) do
		alternateFrame:SetBackdrop({ bgFile="Interface/ChatFrame/ChatFrameBackground", edgeFile="Interface/DialogFrame/UI-DialogBox-Border", tile=true, tileSize=32, edgeSize=32, insets={left=11, right=11, top=12, bottom=10}})
		alternateFrame:SetSize(380, 115)
		alternateFrame:SetBackdropColor(0,0,0, 0.85)
		alternateFrame:EnableMouse()
		alternateFrame:SetScript("OnHide", alternateFrame.Hide)
	 	alternateFrame.caption = alternateFrame:CreateFontString("OVERLAY", nil, "GameFontHighlightSmall")
		alternateFrame.caption:SetPoint("TOPLEFT", 13, -12)
		local input, scroll = config.ui.multilineInput("OPC_AlternateBindInput", alternateFrame, 335)
		alternateFrame.input, alternateFrame.scroll = input, scroll
		scroll:SetPoint("TOPLEFT", 10, -28)
		scroll:SetPoint("BOTTOMRIGHT", -33, 10)
		input:SetMaxBytes(1023)
		input:SetScript("OnEscapePressed", function() alternateFrame:Hide() end)
		input:SetScript("OnChar", function(self, c)
			if c == "\n" then
				local bind = strtrim((self:GetText():gsub("[\r\n]", "")))
				if bind ~= "" then
					alternateFrame.apiFrame.SetBinding(alternateFrame.owner, bind)
				end
				alternateFrame:Hide()
			end
		end)
	end
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
		PlaySound("UChatScrollButton")
		if activeCaptureButton then
			local deactivated, mappedButton = Deactivate(activeCaptureButton), MapMouseButton(button);
			if deactivated == self and (mappedButton or button == "RightButton") then SetBind(self, mappedButton); end
			if deactivated == self then return; end
		end
		if IsAltKeyDown() and activeCaptureButton == nil and self:GetParent().OnBindingAltClick then
			return self:GetParent().OnBindingAltClick(self, button);
		end
		activeCaptureButton = self;
		self:LockHighlight();	self:EnableKeyboard(true);
		self:SetScript("OnKeyDown", SetBind); self:SetScript("OnHide", Deactivate);
		if unbindMap[self:GetParent()] then unbindMap[self:GetParent()]:Enable(); end
	end
	local function UnbindClick(self)
		if activeCaptureButton and unbindMap[activeCaptureButton:GetParent()] == self then
			local p, button = activeCaptureButton:GetParent(), activeCaptureButton;
			if p and type(p.SetBinding) == "function" then p.SetBinding(activeCaptureButton, false); end
			PlaySound("UChatScrollButton")
			Deactivate(button)
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
		if type(bind) == "string" and bind:match("%[.*%]") then
			return SetBindingText(self, SecureCmdOptionParse(bind), pre, post or " |cff20ff20[+]|r")
		end
		return self:SetText((pre or "") .. bindFormat(bind) .. (post or ""))
	end
	local function ToggleAlternateEditor(self, bind, caption)
		if alternateFrame:IsShown() and alternateFrame.owner == self then
			alternateFrame:Hide()
		else
			alternateFrame.apiFrame, alternateFrame.owner = self:GetParent(), self
			alternateFrame.caption:SetText(caption or "")
			alternateFrame.input:SetText(bind or "")
			alternateFrame:SetParent(self)
			alternateFrame:SetFrameLevel(self:GetFrameLevel()+10)
			if self:GetLeft()+(self:GetWidth()-alternateFrame:GetWidth())/2 < self:GetParent():GetLeft() then
				alternateFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -8, 4)
			else
				alternateFrame:SetPoint("TOP", self, "BOTTOM", 0, 4)
			end
			alternateFrame:Show()
			alternateFrame.input:SetFocus()
		end
	end
	function config.createBindingButton(parent)
		local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate");
		btn:SetSize(120, 22); btn:RegisterForClicks("AnyUp"); btn:SetScript("OnClick", OnClick);
		btn:SetText(" "); btn:GetFontString():SetMaxLines(1);
		btn.IsCapturingBinding, btn.SetBindingText = IsCapturingBinding, SetBindingText
		btn.ToggleAlternateEditor = ToggleAlternateEditor
		return btn, unbindMap[parent];
	end
	function config.createUnbindButton(parent)
		local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate");
		btn:Disable(); btn:SetSize(140, 22); unbindMap[parent] = btn;
		btn:SetScript("OnClick", UnbindClick);
		return btn;
	end
end
do -- ext.config.undo
	local undoStack, undo = {}, {}
	config.undo = undo
	function undo.unwind()
		local entry
		for i=#undoStack,1,-1 do
			entry, undoStack[i] = undoStack[i]
			EV.ProtectedCall(entry.func, unpack(entry, 1, entry.n))
		end
	end
	function undo.search(key)
		for i=#undoStack,1,-1 do
			if undoStack[i].key == key then
				return true
			end
		end
	end
	function undo.push(key, func, ...)
		undoStack[#undoStack + 1] = {key=key, func=func, n=select("#", ...), ...}
	end
	function undo.clear()
		table.wipe(undoStack)
	end
end
do -- ext.config.overlay
	local container, watcher, occupant = CreateFrame("FRAME"), CreateFrame("FRAME") do
		container:EnableMouse() container:EnableKeyboard() container:Hide()
		container:SetPropagateKeyboardInput(true)
		container:SetScript("OnKeyDown", function(self, key)
			if key == "ESCAPE" then self:Hide() end
			self:SetPropagateKeyboardInput(key ~= "ESCAPE")
		end)
		container:SetScript("OnMouseWheel", function() end)
		container.fader = container:CreateTexture(nil, "BACKGROUND")
		container.fader:SetTexture(0,0,0) container.fader:SetAlpha(0.40)
		local corner = container:CreateTexture(nil, "ARTWORK")
		corner:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Corner")
		corner:SetSize(30,30) corner:SetPoint("TOPRIGHT", -5, -6)
		local close = CreateFrame("BUTTON", nil, container, "UIPanelCloseButton")
		close:SetPoint("TOPRIGHT", 0, -1)
		close:SetScript("OnClick", function() container:Hide() end)
		container:SetBackdrop({edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", edgeSize=32, bgFile="Interface\\FrameGeneral\\UI-Background-Rock", tile=true, tileSize=256, insets={left=10,right=10,top=10,bottom=10}})
		container:SetBackdropColor(0.3, 0.4, 0.5)
		watcher:SetScript("OnHide", function() if occupant then container:Hide() PlaySound("igMainMenuClose") occupant:Hide() occupant=nil end end)
	end
	function config.overlay(self, overlayFrame)
		if occupant and occupant ~= overlayFrame then occupant:Hide() end
		local cw, ch = overlayFrame:GetSize()
		local w2, h2 = self:GetSize()
		local w, h, isRefresh = cw + 8, ch + 8, occupant == overlayFrame
		w2, h2, occupant = w2 > w and (w-w2)/2 or 0, h2 > h and (h-h2)/2 or 0
		container:SetSize(w, h+20)
		container:SetHitRectInsets(w2, w2, h2, h2)
		container:SetParent(self)
		container:SetPoint("CENTER")
		container:SetFrameLevel(self:GetFrameLevel()+20)
		container.fader:ClearAllPoints()
		container.fader:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -2)
		container.fader:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 2)
		container:Show()
		overlayFrame:ClearAllPoints()
		overlayFrame:SetParent(container)
		overlayFrame:SetPoint("CENTER")
		overlayFrame:Show()
		watcher:SetParent(overlayFrame)
		watcher:Show()
		CloseDropDownMenus()
		if not isRefresh then PlaySound("igMainMenuOpen") end
		occupant = overlayFrame
	end
	
	local promptFrame = CreateFrame("FRAME") do
		promptFrame:SetSize(400, 130)
		promptFrame.title = promptFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		promptFrame.prompt = promptFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		promptFrame.editBox = config.ui.lineInput(promptFrame, 300)
		promptFrame.accept = CreateFrame("Button", nil, promptFrame, "UIPanelButtonTemplate")
		promptFrame.cancel = CreateFrame("Button", nil, promptFrame, "UIPanelButtonTemplate")
		promptFrame.detail = promptFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		promptFrame.title:SetPoint("TOP")
		promptFrame.prompt:SetPoint("TOP", promptFrame.title, "BOTTOM", 0, -8)
		promptFrame.editBox:SetPoint("TOP", promptFrame.prompt, "BOTTOM", 0, -7)
		promptFrame.detail:SetPoint("TOP", promptFrame.editBox, "BOTTOM", 0, -8)
		promptFrame.prompt:SetWidth(380)
		promptFrame.detail:SetWidth(380)
				
		promptFrame.cancel:SetScript("OnClick", function() promptFrame:Hide() end)
		promptFrame.editBox:SetScript("OnTextChanged", function(self)
			promptFrame.accept:SetEnabled(promptFrame.callback == nil or promptFrame.callback(self, self:GetText() or "", false, promptFrame:GetParent():GetParent()))
		end)
		promptFrame.accept:SetScript("OnClick", function(self)
			local callback, text = promptFrame.callback, promptFrame.editBox:GetText() or ""
			if callback == nil or callback(promptFrame.editBox, text, true, promptFrame:GetParent():GetParent()) then
				promptFrame:Hide()
			end
		end)
		promptFrame.editBox:SetScript("OnEnterPressed", function(self) promptFrame.accept:Click() end)
		promptFrame.editBox:SetScript("OnEscapePressed", function(self) promptFrame.cancel:Click() end)
	end
	function config.prompt(frame, title, prompt, explainText, acceptText, callback, editBoxWidth, cancelText)
		promptFrame.callback = callback
		promptFrame.title:SetText(title or "")
		promptFrame.prompt:SetText(prompt or "")
		promptFrame.detail:SetText(explainText or "")
		promptFrame.editBox:SetText("")
		promptFrame:SetHeight(55 + math.max(20, promptFrame.prompt:GetStringHeight()) + (editBoxWidth ~= false and 30 or 0) + ((explainText or "") ~= "" and 20 or 0))
		config.overlay(frame, promptFrame)
		if editBoxWidth ~= false then
			promptFrame.editBox:Show()
			promptFrame.editBox:SetWidth((editBoxWidth or 0.50) * 380)
			promptFrame.editBox:SetFocus()
		else
			promptFrame.editBox:Hide()
		end
		promptFrame.cancel:ClearAllPoints()
		promptFrame.accept:ClearAllPoints()
		if acceptText ~= false then
			promptFrame.accept:SetText(acceptText or ACCEPT)
			promptFrame.cancel:SetText(cancelText or CANCEL)
			promptFrame.cancel:SetPoint("BOTTOMLEFT", promptFrame, "BOTTOM", 5, 0)
			promptFrame.accept:SetPoint("BOTTOMRIGHT", promptFrame, "BOTTOM", -5, 0)
			promptFrame.accept:Show()
		else
			promptFrame.accept:Hide()
			promptFrame.cancel:SetText(cancelText or OKAY)
			promptFrame.cancel:SetPoint("BOTTOM", 5, 0)
		end
		promptFrame.cancel:SetWidth(math.max(125, 15+promptFrame.cancel:GetFontString():GetStringWidth()))
		promptFrame.accept:SetWidth(math.max(125, 15+promptFrame.accept:GetFontString():GetStringWidth()))
		return promptFrame
	end
	function config.alert(frame, title, message, dissmissText)
		config.prompt(frame, title, message, nil, false, nil, false, dissmissText)
	end
end

function config.undo.saveProfile(noData)
	local undo, name = config.undo, OneRingLib:GetCurrentProfile()
	if noData then
		undo.push("OPieLightProfile#" .. name, OneRingLib.SwitchProfile, OneRingLib, name)
	elseif not undo.search("OPieProfile#" .. name) then
		undo.push("OPieProfile#" .. name, OneRingLib.SwitchProfile, OneRingLib, name, (OneRingLib:ExportProfile(name)))
	end
end

function config.checkSVState(frame)
	if not OneRingLib:GetSVState() then
		config.alert(frame, L"Changes will not be saved", L"World of Warcraft could not load OPie's saved variables due to a lack of memory. Try disabling other addons.\n\nAny changes you make now will not be saved.", L"Understood; edit anyway")
	end
end

local OPC_OptionSets = {
	{ "Behavior",
		{"bool", "RingAtMouse", caption="Center rings at mouse"},
		{"bool", "CenterAction", caption="Quick action at ring center"},
		{"bool", "SliceBinding", caption="Per-slice bindings"},
		{"bool", "ClickActivation", caption="Activate on left click"},
		{"bool", "ClickPriority", caption="Make rings top-most"},
		{"bool", "NoClose", caption="Leave open after use", depOn="ClickActivation", depValue=true, otherwise=false},
		{"bool", "UseDefaultBindings", caption="Use default ring bindings"},
		{"range", "IndicationOffsetX", -500, 500, 50, caption="Move rings right", suffix="(%d)"},
		{"range", "IndicationOffsetY", -300, 300, 50, caption="Move rings down", suffix="(%d)"},
		{"range", "MouseBucket", 5, 1, 1, caption="Scroll wheel sensitivity", stdLabels=true},
		{"range", "RingScale", 0.1, 2, caption="Ring scale", suffix="(%0.1f)"},
	}, { "Appearance",
		{"bool", "MultiIndication", caption="Per-slice icons"},
		{"bool", "GhostMIRings", caption="Nested rings", depOn="MultiIndication", depValue=true, otherwise=false},
		{"bool", "ShowKeys", caption="Per-slice bindings", depOn="SliceBinding", depValue=true, depOn2="MultiIndication", depValue2=true, otherwise=false},
		{"bool", "ShowCenterCaption", caption="Center caption"},
		{"bool", "UseGameTooltip", caption="Show tooltips"},
		{"bool", "ShowCooldowns", caption="Show cooldown numbers"},
		{"bool", "ShowRecharge", caption="Show recharge numbers"},
		{"bool", "HideStanceBar", caption="Hide stance bar", global=true},
	}, { "Animation",
		{"bool", "MIScale", caption="Enlarge selected slice", depOn="MultiIndication", depValue=true, otherwise=false},
		{"bool", "MISpinOnHide", caption="Outward spiral on hide", depOn="MultiIndication", depValue=true, otherwise=false},
		{"range", "XTScaleSpeed", -4, 4, 0.2, caption="Scale animation speed"},
		{"range", "XTPointerSpeed", -4, 4, 0.2, caption="Pointer rotation speed"},
		{"range", "XTZoomTime", 0, 1, 0.1, caption="Zoom-in/out time", suffix="(%.1f sec)"},
		{"range", "XTRotationPeriod", 1, 10, 0.2, caption="Rotation period", suffix="(%.1f sec)"}
	}
};

local frame = config.createFrame("OPie")
	frame.version:SetFormattedText("%s (%d.%d)", OneRingLib:GetVersion())
local OPC_Profile = CreateFrame("Frame", "OPC_Profile", frame, "UIDropDownMenuTemplate");
	OPC_Profile:SetPoint("TOPLEFT", frame, 0, -85); UIDropDownMenu_SetWidth(OPC_Profile, 200);
local OPC_OptionDomain = CreateFrame("Frame", "OPC_OptionDomain", frame, "UIDropDownMenuTemplate");
	OPC_OptionDomain:SetPoint("LEFT", OPC_Profile, "RIGHT");
	UIDropDownMenu_SetWidth(OPC_OptionDomain, 250);

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
	function build.bool(v, ofsY, halfpoint, rowHeight)
		local b = CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate");
		b:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		b.id, b.text, b.desc = v[2], b.Text, v;
		b:SetPoint("TOPLEFT", frame, "TOPLEFT", halfpoint and 315 or 15, ofsY);
		b:SetScript("OnClick", notifyChange); hooksecurefunc(b, "SetEnabled", OnStateChange);
		return b, ofsY - (halfpoint and rowHeight or 0), not halfpoint, halfpoint and 0 or 20;
	end
	function build.range(v, ofsY, halfpoint, rowHeight)
		if halfpoint then ofsY = ofsY - rowHeight; end
		local b = CreateFrame("Slider", "OPC_Slider_" .. v[2], frame, "OptionsSliderTemplate");
		b:SetWidth(175)
		b:SetMinMaxValues(v[3] < v[4] and v[3] or -v[3], v[4] > v[3] and v[4] or -v[4]); b:SetValueStep(v[5] or 0.1); b:SetHitRectInsets(0,0,0,0);
		b.id, b.text, b.hi, b.lo, b.desc = v[2], _G["OPC_Slider_" .. v[2] .. "Text"], _G["OPC_Slider_" .. v[2] .. "High"], _G["OPC_Slider_" .. v[2] .. "Low"], v;
		b.hi:ClearAllPoints(); b.hi:SetPoint("LEFT", b, "RIGHT", 2, 1);
		b.lo:ClearAllPoints(); b.lo:SetPoint("RIGHT", b, "LEFT", -2, 1);
		b.text:ClearAllPoints(); b.text:SetPoint("TOPLEFT", frame, "TOPLEFT", 44, ofsY-7);
		if not v.stdLabels then b.lo:SetText(v[3]); b.hi:SetText(v[4]); end
		b:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -105, ofsY-5);
		b:SetScript("OnValueChanged", notifyChange)
		b:SetObeyStepOnDrag(true)
		return b, ofsY - 20, false, 0;
	end

	local cY, halfpoint, rowHeight = -115, false;
	for i, v in ipairs(OPC_OptionSets) do
		v.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
		v.label:SetPoint("TOP", frame, "TOP", -50, cY-10); v.label:SetJustifyH("LEFT")
		v.label:SetPoint("LEFT", frame, "LEFT", 16, 0)
		cY, halfpoint, rowHeight = cY - 30, false, 0;
		for j=2,#v do
			v[j].widget, cY, halfpoint, rowHeight = build[v[j][1]](v[j], cY, halfpoint, rowHeight);
			OPC_Widgets[v[j][2]], v[j].widget.control = v[j].widget, v[j];
		end
		if halfpoint then cY = cY - rowHeight; end
	end
end

local OR_CurrentOptionsDomain

function OPC_AlterOption(widget, option, newval, ...)
	if (...) == "RightButton" then newval = nil; end
	if widget.control[1] == "range" and widget.control[3] > widget.control[4] and type(newval) == "number" then newval = -newval; end
	config.undo.saveProfile()
	OneRingLib:SetOption(option, newval, OR_CurrentOptionsDomain);
	local setval = OneRingLib:GetOption(option, OR_CurrentOptionsDomain);
	if widget:IsObjectType("Slider") then
		local text = L(widget.desc.caption)
		if widget.desc.suffix then
			text = text .. " |cffffd500" .. L(widget.desc.suffix):format(setval) .. "|r"
		end
		widget.text:SetText(text);
		OPC_BlockInput = true; widget:SetValue(setval * (widget.control[3] > widget.control[4] and -1 or 1)); OPC_BlockInput = false;
	elseif setval ~= newval then
		widget:SetChecked(setval and 1 or nil);
	end
	for i,set in ipairs(OPC_OptionSets) do for j=2,#set do local v = set[j]
		if v.depOn == option or v.depOn2 == option then
			local match = OneRingLib:GetOption(v.depOn, OR_CurrentOptionsDomain) == v.depValue and (v.depOn2 == nil or OneRingLib:GetOption(v.depOn2, OR_CurrentOptionsDomain) == v.depValue2);
			v.widget:SetEnabled(match);
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
	info.func, info.arg1, info.text, info.checked, info.minWidth = OPC_OptionDomain.click, nil, L"Defaults for all rings", OR_CurrentOptionsDomain == nil and 1 or nil, self:GetWidth()-40;
	UIDropDownMenu_AddButton(info);
	for i=1,OneRingLib:GetNumRings() do
		local name, key, macro, internal = OneRingLib:GetRingInfo(i);
		if internal == 0 or IsAltKeyDown() then
			info.text, info.arg1, info.checked = (L"Ring: %s"):format("|cffaaffff" .. (name or key) .. "|r"), key, key == OR_CurrentOptionsDomain and 1 or nil;
			UIDropDownMenu_AddButton(info);
		end
	end
end
local function OPC_Profile_NewCallback(self, text, apply, frame)
	local name = text:match("^%s*(.-)%s*$")
	if name == "" or OneRingLib:ProfileExists(name) then 
		if apply then self.editBox:SetText("") end
		return false
	elseif apply then
		config.undo.saveProfile(true)
		OneRingLib:SwitchProfile(name, true)
		if not config.undo.search("OPieProfile#" .. name) then
			config.undo.push("OPieProfile#" .. name, OneRingLib.DeleteProfile, OneRingLib, name)
		end
		frame.refresh("profile")
	end
	return true
end
function OPC_Profile:switch(arg1, frame)
	config.undo.saveProfile(true)
	OneRingLib:SwitchProfile(arg1)
	frame.refresh("profile")
end
function OPC_Profile:new(_, frame)
	config.prompt(frame, L"Create a New Profile", L"New profile name:", L"Profiles save options and ring bindings.", L"Create Profile", OPC_Profile_NewCallback)
end
function OPC_Profile:delete(_, frame)
	config.undo.saveProfile()
	OneRingLib:DeleteProfile(OneRingLib:GetCurrentProfile())
	frame.refresh("profile")
end
function OPC_Profile:initialize()
	local info = UIDropDownMenu_CreateInfo();
	info.func, info.arg2 = OPC_Profile.switch, self:GetParent();
	for ident, isActive in OneRingLib.Profiles do
		info.text, info.arg1, info.checked = ident, ident, isActive or nil;
		UIDropDownMenu_AddButton(info);
	end
	info.text, info.disabled, info.checked, info.notCheckable, info.justifyH = "", true, nil, true, "CENTER"; UIDropDownMenu_AddButton(info);
	info.text, info.disabled, info.minWidth, info.func = L"Create a new profile", false, self:GetWidth()-40, OPC_Profile.new; UIDropDownMenu_AddButton(info);
	info.text, info.func = OneRingLib:GetCurrentProfile() ~= "default" and L"Delete current profile" or L"Restore default settings", OPC_Profile.delete; UIDropDownMenu_AddButton(info);
end
function frame.refresh()
	OPC_BlockInput = true;
	frame.desc:SetText(L"Customize OPie's appearance and behavior. Right clicking a checkbox restores it to its default state." .. "\n" .. L"Profiles activate automatically when you switch between your primary and secondary specializations.");
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
			local text = L(v.caption)
			if v.suffix then
				text = text .. " |cffffd500" .. L(v.suffix):format(v.widget:GetValue()) .. "|r"
			end
			v.widget.text:SetText(text);
		elseif opttype == "bool" then
			v.widget:SetChecked(OneRingLib:GetOption(option, OR_CurrentOptionsDomain) or nil);
			v.widget.text:SetText(L(v.caption))
		end
		if v.depOn then
			local match = OneRingLib:GetOption(v.depOn, OR_CurrentOptionsDomain) == v.depValue and (v.depOn2 == nil or OneRingLib:GetOption(v.depOn2, OR_CurrentOptionsDomain) == v.depValue2);
			v.widget:SetEnabled(match);
			if not match then v.widget:SetChecked(v.otherwise or nil); end
		end
		v.widget:SetShown(not v.global or OR_CurrentOptionsDomain == nil)
	end end
	OPC_BlockInput = false;
	config.checkSVState(frame)
end
function frame.cancel()
	config.undo.unwind()
	OR_CurrentOptionsDomain = nil
end
function frame.default()
	config.undo.saveProfile()
	OneRingLib:ResetOptions(true)
	frame.refresh()
end
function frame.okay()
	config.undo.clear()
	OR_CurrentOptionsDomain = nil
end
frame:SetScript("OnShow", frame.refresh)

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
		InterfaceOptionsFrame_OpenToCategory(frame)
		InterfaceOptionsFrame_OpenToCategory(frame)
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