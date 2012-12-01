local config, L = OneRingLib.ext.config, OneRingLib.lang
local frame = config.createFrame("Bindings", "OPie", true)
local OBC_Profile = CreateFrame("Frame", "OBC_Profile", frame, "UIDropDownMenuTemplate")
	OBC_Profile:SetPoint("TOPLEFT", frame.desc, "BOTTOMLEFT", 0, -8) UIDropDownMenu_SetWidth(OBC_Profile, 200)
	UIDropDownMenu_Initialize(OBC_Profile, OPC_Profile.initialize)
local bindSet = CreateFrame("Frame", "OPC_BindingSet", frame, "UIDropDownMenuTemplate")
	bindSet:SetPoint("LEFT", OBC_Profile, "RIGHT", -16, 0)	UIDropDownMenu_SetWidth(bindSet, 220)

local lRing = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
local lBinding = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	lBinding:SetPoint("TOPLEFT", frame.desc, "BOTTOMLEFT", 0, -45)
	lRing:SetPoint("LEFT", lBinding, "LEFT", 215, 0)
	lBinding:SetWidth(180)
local bindLines = {}
local function mClick(self) frame.showMacroPopup(self:GetParent():GetID()) end
for i=1,20 do
	local bind = config.createBindingButton("OPC_BindKey" .. i, frame)
	local label = bind:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	bind:SetPoint("TOPLEFT", lBinding, "BOTTOMLEFT", 0, 16-20*i)
	bind.macro = CreateFrame("BUTTON", "OPC_BindKeyM" .. i, bind, config.buttonTemplate)
	bind.macro:SetWidth(24) bind.macro:SetPoint("LEFT", bind, "RIGHT", 1, 0)
	bind.macro:SetText("|TInterface\\RaidFrame\\UI-RaidFrame-Arrow:24:24:0:-1|t")
	bind.macro:SetScript("OnClick", mClick)
	bind:SetWidth(180) bind:GetFontString():SetWidth(170)
	label:SetPoint("LEFT", 215, 2)
	bind:SetNormalFontObject(GameFontNormalSmall)
	bind:SetHighlightFontObject(GameFontHighlightSmall)
	bindLines[i], bind.label = bind, label
end
local btnUnbind = config.createUnbindButton("OPC_Unbind", frame)
	btnUnbind:SetPoint("TOP", bindLines[#bindLines], "BOTTOM", 0, -3)
local btnUp = CreateFrame("Button", "OPC_SUp", frame, "UIPanelScrollUpButtonTemplate")
	btnUp:SetPoint("RIGHT", btnUnbind, "LEFT", -10)
local btnDown = CreateFrame("Button", "OPC_SDown", frame, "UIPanelScrollDownButtonTemplate")
	btnDown:SetPoint("LEFT", btnUnbind, "RIGHT", 10)
local cap = CreateFrame("Frame", nil, frame)
	cap:SetPoint("TOP", OBC_Profile, "BOTTOM", 0, 0)
	cap:SetPoint("LEFT", 5, 0)
	cap:SetPoint("RIGHT", -10, 0)
	cap:SetPoint("BOTTOM", btnUnbind, "TOP", 0, 2)
	cap:SetScript("OnMouseWheel", function(self, delta)
		local b = delta == 1 and btnUp or btnDown
		if b:IsEnabled() and not btnUnbind:IsEnabled() then b:Click() end
	end)

local alternateFrame = CreateFrame("Frame", nil, frame)
	alternateFrame:SetBackdrop({ bgFile = "Interface/ChatFrame/ChatFrameBackground", edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
		tile = true, tileSize = 32, edgeSize = 32, insets = { left = 11, right = 11, top = 12, bottom = 10 }
	})
	alternateFrame:SetWidth(350) alternateFrame:SetHeight(115)
	alternateFrame:SetBackdropColor(0,0,0, 0.85)
	alternateFrame:EnableMouse()
	frame:SetScript("OnHide", function() alternateFrame:Hide() end)
local conditionalBindingCaption = alternateFrame:CreateFontString("OVERLAY", nil, "GameFontHighlightSmall")
	conditionalBindingCaption:SetPoint("TOPLEFT", 13, -12)
local scroller = CreateFrame("ScrollFrame", "OPC_BindInputScroll", alternateFrame, "UIPanelScrollFrameTemplate")
	scroller:SetPoint("TOPLEFT", 10, -28)
	scroller:SetPoint("BOTTOMRIGHT", -33, 10)
local txtAlternateInput = CreateFrame("Editbox", "OPC_BindInput", scroller)
	txtAlternateInput:SetMaxBytes(1023) txtAlternateInput:SetMultiLine(true)
	txtAlternateInput:SetWidth(305) txtAlternateInput:SetAutoFocus(false)
	txtAlternateInput:SetTextInsets(2, 0,0,0)
	txtAlternateInput:SetFontObject(GameFontHighlight)
	txtAlternateInput:SetScript("OnEscapePressed", function(s) alternateFrame:Hide() end)
	scroller:SetScrollChild(txtAlternateInput)
	alternateFrame:SetScript("OnMouseDown", function() txtAlternateInput:SetFocus() end)
	txtAlternateInput.bar = _G["OPC_BindInputScrollScrollBar"]
	do -- Macro text box scrolling
		local occH, occP -- Height, Pos
		txtAlternateInput:SetScript("OnCursorChanged", function(s, x,y,w,h)
			occH, occP, y = scroller:GetHeight(), scroller:GetVerticalScroll(), -y
			if occP > y then occP = y -- too far
			elseif (occP + occH) < (y+h) then occP = y+h-occH -- not far enough
			else return end -- is fine
			scroller:SetVerticalScroll(occP)
			local _, mx = s.bar:GetMinMaxValues()
			s.bar:SetMinMaxValues(0, occP < mx and mx or occP)
			s.bar:SetValue(occP)
		end)
	end
	txtAlternateInput:SetScript("OnChar", function(s, c)
		if c == "\n" then
			local bind = strtrim((s:GetText():gsub("[\r\n]", "")))
			if bind ~= "" then
				frame.SetBinding(alternateFrame, bind)
			end
			alternateFrame:Hide()
		end
	end)
StaticPopupDialogs.OBC_MACRO = {button2=OKAY, hasEditBox=1, editBoxWidth=260, whileDead=1, timeout = 0, hideOnEscape=true}

local ringBindings = {map={}, name="Ring Bindings", caption="Ring"}
function ringBindings:refresh()
	local pos, map = 1, self.map
	for i=1,OneRingLib:GetNumRings() do
		local _, key, _, internal = OneRingLib:GetRingInfo(i)
		if internal == 0 or IsAltKeyDown() then
			map[pos], pos = key, pos + 1
		end
	end
	for i=#map,pos,-1 do
		map[i] = nil
	end
	self.count = #map
end
function ringBindings:get(id)
	local name, key, macro, internal = OneRingLib:GetRingInfo(self.map[id])
	local bind, isOverride, isActive, cBind, enabled = OneRingLib:GetRingBinding(key)
	return bind, name or key or "?", enabled and ((cBind and isActive == false and (isOverride and "|cffFA2800" or "|cffa0a0a0")) or (isOverride and "|cffffffff") or "") or "|cffa0a0a0"
end
function ringBindings:set(id, key)
	id = self.map[id]
	local okey, over = OneRingLib:GetRingBinding(id)
	config.pushUndo("Bind" .. id, OneRingLib.SetRingBinding, OneRingLib, id, over and okey or nil)
	OneRingLib:SetRingBinding(id, key)
end
function ringBindings:arrow(id)
	local name, key, macro = OneRingLib:GetRingInfo(self.map[id])
	StaticPopupDialogs.OBC_MACRO.text = (L"Use the following command to open %s ring in macros:"):format("|cffFFD029" .. (name or key) .. "|r")
	local dialog = StaticPopup_Show("OBC_MACRO")
	dialog.editBox:SetText(macro)
	dialog.editBox:HighlightText(0, #macro)
end
function ringBindings:default()
	OneRingLib:ResetRingBindings()
end
function ringBindings:altClick() -- self is the binding button
	local id = self:GetID()
	if alternateFrame:IsShown() and alternateFrame:GetID() == id then
		alternateFrame:Hide()
	else
		alternateFrame:SetID(id)
		alternateFrame:SetFrameStrata("DIALOG")
		alternateFrame:ClearAllPoints()
		alternateFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -10, 5)
		txtAlternateInput:SetText(OneRingLib:GetRingBinding(ringBindings.map[id]) or "")
		alternateFrame:Show()
		txtAlternateInput:SetFocus()
	end
end

local sysBindings = {count=5, name="Other Bindings", caption="Action",
	options={"PrimaryButton", "SecondaryButton", "OpenNestedRingButton", "ScrollNestedRingUpButton", "ScrollNestedRingDownButton"},
	optionNames={"Primary default binding button", "Secondary default binding button", "Open nested ring", "Scroll nested nested ring (up)", "Scroll nested ring (down)"}}
function sysBindings:get(id)
	local value, setting = OneRingLib:GetOption(self.options[id])
	return value, self.optionNames[id], setting and "|cffffffff" or nil
end
function sysBindings:set(id, bind)
	local _, setting = OneRingLib:GetOption(self.options[id])
	config.pushUndo(self.options[id], OneRingLib.SetOption, OneRingLib, self.options[id], setting)
	OneRingLib:SetOption(self.options[id], bind == false and "" or bind)
end
function sysBindings:default()
	for k,v in pairs(self.options) do
		OneRingLib:SetOption(v, nil)
	end
end

local subBindings = {count=0, name="Slice Bindings", caption="Slice", t={}}
function subBindings:refresh(scope)
	self.scope, self.nameSuffix = scope, scope and (" (|cffaaffff" ..  (OneRingLib:GetRingInfo(scope or 1) or "") .. "|r)") or (" (" .. L"Defaults" .. ")")
	local t, ni = self.t, 1
	for s in OneRingLib:GetOption("SliceBindingString", scope):gmatch("%S+") do
		t[ni], ni = s, ni + 1
	end
	for i=#t,ni,-1 do t[i] = nil end
	subBindings.count = ni
end
function subBindings:get(id)
	return self.t[id] == "false" and "" or self.t[id], "Slice #" .. id
end
function subBindings:set(id, bind)
	if bind == nil then
		local i, s, s2 = 1, select(self.scope == nil and 5 or 4, OneRingLib:GetOption("SliceBindingString", self.scope))
		for f in (s or s2):gmatch("%S+") do
			if i == id then bind = f break end
			i = i + 1
		end
	end

	local t, bind = self.t, bind or "false"
	if bind ~= "false" then
		for i=1,#t do
			if t[i] == bind then
				t[i] = "false"
			end
		end
	end
	t[id] = bind
	for j=#t,1,-1 do if t[j] == "false" then t[j] = nil else break end end
	self.count = #t+1
	local _, old, ring, global, default = OneRingLib:GetOption("SliceBindingString", self.scope)
	config.pushUndo("SliceBindingString#" .. (self.scope or ""), OneRingLib.SetOption, OneRingLib, "SliceBindingString", self.scope, old)
	local v = table.concat(t, " ")
	if self.scope == nil and v == default then v = nil
	elseif self.scope ~= nil and v == (global or default) then v = nil end
	OneRingLib:SetOption("SliceBindingString", self.scope, v)
end
function subBindings:scopes(info, level, checked)
	info.arg1, info.arg2, info.text, info.checked = self, nil, L"Defaults for all rings", checked and self.scope == nil
	UIDropDownMenu_AddButton(info, level)
	for i=1,OneRingLib:GetNumRings() do
		local name, key, _, internal = OneRingLib:GetRingInfo(i)
		if internal < 2 then
			info.text, info.arg2, info.checked = L("Ring: %s"):format("|cffaaffff" .. (name or key) .. "|r"), key, checked and key == self.scope
			UIDropDownMenu_AddButton(info, level)
		end
	end
end
function subBindings:default()
	OneRingLib:SetOption("SliceBindingString", nil)
	if self.scope then OneRingLib:SetOption("SliceBindingString", self.scope, nil) end
end


local currentOwner, currentBase, bindingTypes = ringBindings,0, {ringBindings, subBindings, sysBindings}
local function updatePanelContent()
	local m, arrowShowHide = currentOwner.count, bindLines[1].macro[currentOwner.arrow and "Show" or "Hide"]
	for i=1,#bindLines do
		local j, e = currentBase+i, bindLines[i]
		if j > m then
			e:Hide()
		else
			local binding, text, prefix = currentOwner:get(j)
			e.label:SetText(text)
			arrowShowHide(e.macro)
			e:SetBindingText(binding, prefix)
			e:SetID(j) e:Show()
		end
	end
	btnDown[#bindLines + currentBase < m and "Enable" or "Disable"](btnDown)
	btnUp[currentBase > 0 and "Enable" or "Disable"](btnUp)
	lRing:SetText(L(currentOwner.caption or "Action"))
	frame.OnAltClick = currentOwner.altClick
	UIDropDownMenu_SetText(bindSet, L(currentOwner.name) .. (currentOwner.nameSuffix or ""))
end
function frame.SetBinding(buttonOrId, binding)
	local id = type(buttonOrId) == "number" and buttonOrId or buttonOrId:GetID()
	currentOwner:set(id, binding)
	updatePanelContent()
end
function frame.showMacroPopup(id)
	return currentOwner:arrow(id)
end
local function scroll(self)
	currentBase = math.max(0, currentBase + (self == btnDown and 1 or -1))
	updatePanelContent()
end
btnDown:SetScript("OnClick", scroll) btnUp:SetScript("OnClick", scroll)

function bindSet:initialize(level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	info.func, info.minWidth = bindSet.set, level == 1 and (bindSet:GetWidth()-40) or nil
	if level == 2 and menuList then
		return menuList:scopes(info, level, menuList == currentOwner)
	end
	for _, v in ipairs(bindingTypes) do
		info.text, info.arg1, info.checked, info.hasArrow, info.menuList = L(v.name), v, v == currentOwner, v.scopes, v.scopes and v
		UIDropDownMenu_AddButton(info, level)
	end
end
function bindSet:set(owner, scope)
	currentOwner, currentBase = owner, 0
	if owner.refresh then owner:refresh(scope) end
	updatePanelContent()
	CloseDropDownMenus()
end

function frame.localize()
	frame.title:SetText(L"Ring Bindings")
	frame.desc:SetText(L"Customize OPie key bindings below. |cffa0a0a0Gray|r and |cffFA2800red|r bindings conflict with others and are not currently active." .. "\n" ..
		(L"Alt+Left Click on a button to set a conditional binding, indicated by %s."):format("|cff4CFF40[+]|r"))
	lBinding:SetText(L"Binding")
	btnUnbind:SetText(L"Unbind")
	conditionalBindingCaption:SetText((L"F.ex. %s. Press ENTER to save."):format("|cff4CFF40[combat] ALT-C; CTRL-F|r"))
	UIDropDownMenu_SetText(OBC_Profile, L"Profile" .. ": " .. OneRingLib:GetCurrentProfile())
end
function frame.refresh()
	for _, v in pairs(bindingTypes) do
		if v.refresh then v:refresh() end
	end
	frame.localize()
	updatePanelContent()
end
function frame.default()
	for _, v in pairs(bindingTypes) do
		if v.default then v:default() end
	end
end
function frame.okay()
	currentOwner, currentBase = ringBindings,0
end
frame.cancel = frame.okay

local function open()
	InterfaceOptionsFrame_OpenToCategory(frame)
end
config.AddSlashSuffix(open, "bind", "binding", "bindings")