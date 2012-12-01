local api, L, RK, AB, conf = {}, OneRingLib.lang, OneRingLib.ext.RingKeeper, OneRingLib.ext.ActionBook, OneRingLib.ext.config
AB = assert(AB:compatible(1,3), "A compatible version of ActionBook is required")

local function prepEditBoxCancel(self) self.oldValue = self:GetText() end
local function cancelEditBoxInput(self)
	local h = self:GetScript("OnEditFocusLost")
	self:SetText(self.oldValue or self:GetText())
	self:SetScript("OnEditFocusLost", nil)
	self:ClearFocus()
	self:SetScript("OnEditFocusLost", h)
end
local function prepEditBox(self, save)
	if self:IsMultiLine() then
		self:SetScript("OnEscapePressed", self.ClearFocus)
	else
		self:SetScript("OnEditFocusGained", prepEditBoxCancel)
		self:SetScript("OnEscapePressed", cancelEditBoxInput)
		self:SetScript("OnEnterPressed", self.ClearFocus)
	end
	self:SetScript("OnEditFocusLost", save)
end
local function createIconButton(name, parent)
	local f = CreateFrame("CheckButton", name, parent)
	f:SetSize(32,32)
	f:SetNormalTexture(f:CreateTexture())
	f:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square")
	f:SetCheckedTexture("Interface/Buttons/CheckButtonHilight")
	f:SetPushedTexture("Interface/Buttons/UI-Quickslot-Depress")
	f.tex = f:CreateTexture() f.tex:SetAllPoints()
	return f
end
local function SetCursor(tex)
	_G.SetCursor((tex == "Interface\\AddOns\\OPie\\gfx\\icon") and "PICKUP_CURSOR" or tex)
end

local panel = conf.createFrame(L"Custom Rings", "OPie", false)
	panel.version:SetFormattedText("%d.%d", RK:GetVersion())
local ringDropDown = CreateFrame("FRAME", "RKC_RingSelectionDropDown", panel, "UIDropDownMenuTemplate")
	ringDropDown:SetPoint("TOP", panel.desc, "BOTTOM", -75, -10)
	UIDropDownMenu_SetWidth(ringDropDown, 300)
local btnNewRing = CreateFrame("BUTTON", "RKC_CreateNewRing", panel, conf.buttonTemplate)
	btnNewRing:SetPoint("LEFT", ringDropDown, "RIGHT", -5, 2)
	btnNewRing:SetWidth(150)
	btnNewRing:SetScript("OnClick", function()
		local k = "OPIE_NEW_CUSTOM_RING"
		StaticPopupDialogs[k] = StaticPopupDialogs[k] or {
			button1=ACCEPT, button2=CANCEL, hasEditBox=1, maxLetters=255, whileDead=1, timeout=0, hideOnEscape=true,
			OnHide = function(self) self.editBox:SetText("") end,
			OnAccept = function(self) local t = self.editBox:GetText() self.editBox:SetText("") api.createRing(t) end,
			EditBoxOnEnterPressed = function(self) StaticPopupDialogs[k].OnAccept(self:GetParent()) StaticPopup_Hide(k) end
		}
		StaticPopupDialogs[k].text = L"New ring name:"
		StaticPopup_Show(k)
	end)

local function setIcon(self, path, ext, slice)
	if path == nil and type(slice) == "table" and slice[1] == "macrotext" and type(slice[2]) == "string" then
		local _,_,sico = GetSpellInfo(tonumber(slice[2]:match("{{spell:(%d+)")) or 0)
		if sico then path = sico end
	end
	self:SetTexture(path or "Interface/Icons/Inv_Misc_QuestionMark")
	self:SetTexCoord(0,1,0,1)
	if not ext then return end
	if type(ext.iconR) == "number" and type(ext.iconG) == "number" and type(ext.iconB) == "number" then
		self:SetVertexColor(ext.iconR, ext.iconG, ext.iconB)
	end
	if type(ext.iconCoords) == "table" then
		self:SetTexCoord(unpack(ext.iconCoords))
	elseif type(ext.iconCoords) == "function" or type(ext.iconCoords) == "userdata" then
		self:SetTexCoord(ext:iconCoords())
	end
end

local ringContainer, ringDetail, sliceDetail, newSlice

ringContainer = CreateFrame("FRAME", nil, panel) do
	ringContainer:SetPoint("TOP", ringDropDown, "BOTTOM", 75, 0)
	ringContainer:SetPoint("BOTTOM", panel, 0, 10)
	ringContainer:SetPoint("LEFT", panel, 50, 0)
	ringContainer:SetPoint("RIGHT", panel, -10, 0)
	ringContainer:SetBackdrop({edgeFile="Interface/Tooltips/UI-Tooltip-Border", tile=true, edgeSize=8})
	ringContainer:SetBackdropBorderColor(.6, .6, .6, 1)
	do -- up/down arrow buttons: ringContainer.prev and ringContainer.next
		local prev, next = CreateFrame("BUTTON", nil, ringContainer), CreateFrame("BUTTON", nil, ringContainer)
		prev:SetPoint("TOPRIGHT", ringContainer, "TOPLEFT", -2, 0)
		next:SetPoint("BOTTOMRIGHT", ringContainer, "BOTTOMLEFT", -2, 0)
		prev:SetSize(32, 32) next:SetSize(32, 32)
		prev:SetNormalTexture("Interface/ChatFrame/UI-ChatIcon-ScrollUp-Up")
		prev:SetPushedTexture("Interface/ChatFrame/UI-ChatIcon-ScrollUp-Down")
		prev:SetDisabledTexture("Interface/ChatFrame/UI-ChatIcon-ScrollUp-Disabled")
		prev:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight")
		next:SetNormalTexture("Interface/ChatFrame/UI-ChatIcon-ScrollDown-Up")
		next:SetPushedTexture("Interface/ChatFrame/UI-ChatIcon-ScrollDown-Down")
		next:SetDisabledTexture("Interface/ChatFrame/UI-ChatIcon-ScrollDown-Disabled")
		next:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight")
		next:SetID(1) prev:SetID(-1)
		local function handler(self) api.scrollSliceList(self:GetID()) end
		next:SetScript("OnClick", handler) prev:SetScript("OnClick", handler)
		ringContainer.prev, ringContainer.next = prev, next
		local cap = CreateFrame("Frame", nil, ringContainer)
		cap:SetPoint("TOPLEFT", prev, -5, 3) cap:SetPoint("BOTTOMRIGHT", next, 5, -3)
		cap:SetScript("OnMouseWheel", function(self, delta)
			local b = delta == 1 and prev or next
			if b:IsEnabled() then b:Click() end
		end)
	end
	do -- .slices
		ringContainer.slices = {}
		local function onClick(self) api.selectSlice(self:GetID(), self:GetChecked()) end
		local function dragStart(self) self.source = api.resolveSliceOffset(self:GetID()) SetCursor(self.tex:GetTexture()) end
		local function dragStop(self) SetCursor(nil)
			local x, y = GetCursorPosition()
			local scale, l, b, w, h = self:GetEffectiveScale(), self:GetRect()
			local dy, dx = math.floor(-(y / scale - b - h-1)/(h+2)), x / scale - l
			if dx < -2*w or dx > 2*w then return api.deleteSlice(self.source) end
			if dx < -w/2 or dx > 3*w/2 then return end
			local source, dest = self.source, self:GetID() + dy
			if not ringContainer.slices[dest+1] or not ringContainer.slices[dest+1]:IsShown() then return end
			dest = api.resolveSliceOffset(dest)
			if dest ~= source then api.moveSlice(source, dest) end
		end
		for i=0,11 do
			local ico = createIconButton(nil, ringContainer)
			ico:SetPoint("TOP", ringContainer.prev, "BOTTOM", 0, -34*i+2)
			ico:SetID(i) ico:SetScript("OnClick", onClick)
			ico:RegisterForDrag("LeftButton")
			ico:SetScript("OnDragStart", dragStart)
			ico:SetScript("OnDragStop", dragStop)
			ico.check = ico:CreateTexture(nil, "OVERLAY")
			ico.check:SetSize(8,8) ico.check:SetPoint("BOTTOMRIGHT", -1, 1)
			ico.check:SetTexture("Interface/FriendsFrame/StatusIcon-Online")
			ringContainer.slices[i+1] = ico
		end
	end
end
ringDetail = CreateFrame("Frame", nil, ringContainer) do
	ringDetail:SetAllPoints()
	ringDetail.name = CreateFrame("EditBox", nil, ringDetail)
	ringDetail.name:SetHeight(20) ringDetail.name:SetPoint("TOPLEFT", 7, -7) ringDetail.name:SetPoint("TOPRIGHT", -7, -7) ringDetail.name:SetFontObject(GameFontNormalLarge) ringDetail.name:SetAutoFocus(false)
	prepEditBox(ringDetail.name, function(self) api.setRingProperty("name", self:GetText()) end)
	local tex = ringDetail.name:CreateTexture() tex:SetPoint("BOTTOMLEFT", 0, -2) tex:SetPoint("BOTTOMRIGHT", 0, -2) tex:SetHeight(1) tex:SetTexture(1,0.82,0,0.5)
	ringDetail.scope = CreateFrame("Frame", "RKC_RingScopeDropDown", ringDetail, "UIDropDownMenuTemplate")
	ringDetail.scope:SetPoint("TOPLEFT", 250, -37) UIDropDownMenu_SetWidth(ringDetail.scope, 200)
	ringDetail.scopeLabel = ringDetail.scope:CreateFontString(nil, "OVERLAY", "GameFontHighlight")	
	ringDetail.scopeLabel:SetJustifyH("LEFT") ringDetail.scopeLabel:SetWidth(235) ringDetail.scopeLabel:SetPoint("RIGHT", ringDetail.scope, "LEFT", -5, 0)
	ringDetail.binding = conf.createBindingButton("RKC_DefaultRingBinding", ringDetail)
	ringDetail.binding:SetPoint("TOPLEFT", 265, -72) ringDetail.binding:SetWidth(220)
	function ringDetail:SetBinding(bind) return api.setRingProperty("hotkey", bind) end
	ringDetail.binding.label = ringDetail.scope:CreateFontString(nil, "OVERLAY", "GameFontHighlight")	
	ringDetail.binding.label:SetJustifyH("LEFT") ringDetail.binding.label:SetWidth(250) ringDetail.binding.label:SetPoint("RIGHT", ringDetail.binding, "LEFT", -5, 0)
	ringDetail.binding:SetScript("OnEnter", function(self) if self.tooltipText then GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -self:GetWidth(), 0); GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, 1); end end)
	ringDetail.binding:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	ringDetail.rotation = CreateFrame("Slider", "RKC_RingRotation", ringDetail, "OptionsSliderTemplate")
	ringDetail.rotation:SetPoint("TOPLEFT", 265, -102) ringDetail.rotation:SetWidth(220) ringDetail.rotation:SetMinMaxValues(0, 345) ringDetail.rotation:SetValueStep(15)
	ringDetail.rotation:SetScript("OnValueChanged", function(self, value) ringDetail.rotationLabel:SetFormattedText(L"Ring Rotation %s(%d\194\176)|r:", "|cffffd500", value) api.setRingProperty("offset", value) end)
	RKC_RingRotationLow:SetText("0\194\176") RKC_RingRotationHigh:SetText("345\194\176")
	ringDetail.rotationLabel = ringDetail.scope:CreateFontString(nil, "OVERLAY", "GameFontHighlight")	
	ringDetail.rotationLabel:SetJustifyH("LEFT") ringDetail.rotationLabel:SetWidth(250) ringDetail.rotationLabel:SetPoint("RIGHT", ringDetail.rotation, "LEFT", -5, 0)
	ringDetail.opportunistCA = CreateFrame("CheckButton", nil, ringDetail, "InterfaceOptionsCheckButtonTemplate")
	ringDetail.opportunistCA:SetPoint("TOPLEFT", ringDetail.rotation, "BOTTOMLEFT", 0, -10)
	ringDetail.opportunistCA:SetScript("OnClick", function(self) api.setRingProperty("noOpportunisticCA", (not self:GetChecked()) or nil) api.setRingProperty("noPersistentCA", (not self:GetChecked()) or nil) end)
	ringDetail.hiddenRing = CreateFrame("CheckButton", nil, ringDetail, "InterfaceOptionsCheckButtonTemplate")
	ringDetail.hiddenRing:SetPoint("TOPLEFT", ringDetail.opportunistCA, "BOTTOMLEFT", 0, 2)
	ringDetail.hiddenRing:SetScript("OnClick", function(self) api.setRingProperty("internal", self:GetChecked() and true or nil) end)

	ringDetail.optionsLabel = ringDetail:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	ringDetail.optionsLabel:SetPoint("LEFT", ringDetail.opportunistCA, "LEFT", -255, 0)
	ringDetail.remove = CreateFrame("Button", nil, ringDetail, "UIPanelButtonGrayTemplate")
	ringDetail.remove:SetSize(120, 22) ringDetail.remove:SetPoint("BOTTOMRIGHT", -10, 10)
	ringDetail.remove:SetScript("OnClick", function() api.deleteRing() end)
	ringDetail.restore = CreateFrame("Button", nil, ringDetail, "UIPanelButtonGrayTemplate")
	ringDetail.restore:SetSize(120, 22) ringDetail.restore:SetPoint("RIGHT", ringDetail.remove, "LEFT", -10, 0)
	ringDetail.restore:SetScript("OnClick", function() api.restoreDefault() end)

	ringDetail.newSlice = CreateFrame("Button", nil, ringDetail) do
		local b,ico = ringDetail.newSlice, ringDetail.newSlice:CreateTexture(nil, "ARTWORK")
		b:SetSize(24,24) b:SetPoint("TOPLEFT", ringDetail.optionsLabel, "BOTTOMLEFT", 0, -35) ico:SetAllPoints() b:SetHitRectInsets(0, -100, 0, 0)
		ico:SetTexture("Interface/GuildBankFrame/UI-GuildBankFrame-NewTab")
		b:SetNormalTexture(b:CreateTexture())
		b:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square")
		b:SetPushedTexture("Interface/Buttons/UI-Quickslot-Depress")
		b:SetNormalFontObject(GameFontHighlight) b:SetHighlightFontObject(GameFontGreen) b:SetPushedTextOffset(1, 0)
		b:SetText(" ") b:GetFontString():ClearAllPoints() b:GetFontString():SetPoint("LEFT", b, "RIGHT", 6, 0)
		b:SetScript("OnClick", function() ringDetail:Hide() newSlice:Show() end)
	end
	ringDetail:Hide()
end
sliceDetail = CreateFrame("Frame", nil, ringContainer) do
	sliceDetail:SetAllPoints()
	sliceDetail.desc = sliceDetail:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	sliceDetail.desc:SetPoint("TOPLEFT", 7, -9) sliceDetail.desc:SetPoint("TOPRIGHT", -7, -7) sliceDetail.desc:SetJustifyH("LEFT")
	sliceDetail.skipSpecs = CreateFrame("Frame", "RKC_SkipSpecDropdown", sliceDetail, "UIDropDownMenuTemplate") do
		local s = sliceDetail.skipSpecs
		s:SetPoint("TOPLEFT", 198, -27); UIDropDownMenu_SetWidth(s, 250)
		s.label = s:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		s.label:SetPoint("LEFT", -191, 1)
	end
	sliceDetail.caption = CreateFrame("EditBox", "RKC_SliceCaptionEditBox", sliceDetail, "InputBoxTemplate") do
		local c = sliceDetail.caption
		c:SetAutoFocus(false) c:SetSize(260, 20)
		c:SetPoint("TOPLEFT", 220, -27-31)
		c.label = sliceDetail.caption:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		c.label:SetPoint("LEFT", -213, 0)
		prepEditBox(c, function(self) api.setSliceProperty("caption", self:GetText()) end)
	end
	sliceDetail.color = CreateFrame("EditBox", "RKC_SliceColorPickerEditBox", sliceDetail, "InputBoxTemplate") do
		local c = sliceDetail.color
		c:SetPoint("TOPLEFT", sliceDetail.caption, "BOTTOMLEFT", 0, -1)
		c:SetSize(80, 22) c:SetAutoFocus(false) c:SetTextInsets(22, 0, 0, 0) c:SetMaxBytes(8)
		prepEditBox(c, function(self)
			local r,g,b = self:GetText():match("(%x%x)(%x%x)(%x%x)")
			if not r then return self:SetText(self.oldValue) end
			api.setSliceProperty("color", tonumber(r,16)/255, tonumber(g,16)/255, tonumber(b,16)/255)
		end)
		c.label = sliceDetail.color:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		c.label:SetPoint("LEFT", -213, -1)
		c.button = CreateFrame("Button", nil, c)
		local b = sliceDetail.color.button
		b:SetSize(14, 14) b:SetPoint("LEFT")
		b.bg = sliceDetail.color.button:CreateTexture(nil, "BACKGROUND")
		b.bg:SetSize(12, 12) b.bg:SetPoint("CENTER") b.bg:SetTexture(1,1,1)
		b:SetNormalTexture("Interface/ChatFrame/ChatFrameColorSwatch") local ctex = b:GetNormalTexture()
		b:SetScript("OnEnter", function(self) self.bg:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b) end)
		b:SetScript("OnLeave", function(self) self.bg:SetVertexColor(1, 1, 1) end)
		b:SetScript("OnShow", b:GetScript("OnLeave"))
		local function update(v)
			if ColorPickerFrame:IsShown() or v then return end
			api.setSliceProperty("color", ColorPickerFrame:GetColorRGB())
		end
		b:SetScript("OnClick", function(self)
			local cp = ColorPickerFrame
			cp.previousValues, cp.hasOpacity, cp.func, cp.cancelFunc = true
			cp:SetColorRGB(ctex:GetVertexColor()) cp:Show()
			cp.func, cp.cancelFunc = update, update
		end)
		local ceil = math.ceil
		function c:SetColor(r,g,b)
			c:SetText(("%02X%02X%02X"):format(ceil((r or 0)*255),ceil((g or 0)*255),ceil((b or 0)*255)))
			ctex:SetVertexColor(r or 0,g or 0,b or 0)
		end
	end	
	sliceDetail.icon = CreateFrame("Button", nil, sliceDetail) do
		local f = sliceDetail.icon
		f:SetHitRectInsets(0,-280,0,0) f:SetSize(18, 18) f:SetPoint("TOPLEFT", sliceDetail.color, "BOTTOMLEFT", -4, -2)
		f:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square")
		f:SetNormalFontObject(GameFontHighlightSmall) f:SetHighlightFontObject(GameFontGreenSmall) f:SetPushedTextOffset(3/4, -3/4)
		f:SetText(" ") f:GetFontString():ClearAllPoints() f:GetFontString():SetPoint("LEFT", f, "RIGHT", 4, 0)
		f.icon = f:CreateTexture() f.icon:SetAllPoints()
		f.label = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		f.label:SetPoint("LEFT", -208, 0)
		
		local frame = CreateFrame("Frame", nil, UIParent)
		frame:SetBackdrop({bgFile = "Interface/ChatFrame/ChatFrameBackground", edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
			tile = true, tileSize = 32, edgeSize = 32, insets = { left = 11, right = 11, top = 12, bottom = 10 }})
		frame:SetWidth(554) frame:SetHeight(22+34*6) frame:SetPoint("TOPLEFT", f, "TOPLEFT", -212, -18) frame:SetFrameStrata("DIALOG")
		frame:SetBackdropColor(0,0,0, 0.85) frame:EnableMouse() frame:Hide()
		f:SetScript("OnClick", function() frame[frame:IsShown() and "Hide" or "Show"](frame) end)
		f:SetScript("OnHide", function() frame:Hide() end)
		local icons, selectedIcon = {}
		local function onClick(self)
			if selectedIcon then selectedIcon:SetChecked(nil) end
			api.setSliceProperty("icon", self:GetChecked() and self.tex:GetTexture() or nil)
			selectedIcon = self:GetChecked() and self or nil
		end
		for i=0,89 do
			local j = createIconButton(nil, frame)
			j:SetID(i) j:SetPoint("TOPLEFT", (i % 15)*34+12, -12 - 34*math.floor(i / 15))
			j:SetScript("OnClick", onClick)
			icons[i] = j
		end
		local icontex = {}
		local slider = CreateFrame("Slider", "RKC_IconSelectionSlider", frame, "UIPanelScrollBarTrimTemplate")
			slider:SetPoint("TOPRIGHT",-11, -26) slider:SetPoint("BOTTOMRIGHT", -11, 25)
			slider:SetValueStep(15) slider.scrollStep = 45
			slider:SetScript("OnValueChanged", function(self, value)
				selectedIcon = nil
				for i=0,#icons do
					local tex = "Interface/Icons/" .. icontex[i+value]
					icons[i].tex:SetTexture(tex)
					icons[i]:SetChecked(f.selection == tex)
					selectedIcon = f.selection == tex and icons[i] or selectedIcon
				end
			end)
		frame:SetScript("OnShow", function(self)
			icontex = GetMacroIcons()
			GetMacroItemIcons(icontex)
			slider:SetMinMaxValues(1, #icontex-#icons-1)
			slider:SetValue(1)
		end)
		frame:SetScript("OnMouseWheel", function(self, delta)
			slider:SetValue(slider:GetValue()-delta*15)
		end)
		function f:SetIcon(ico, forced, ext, slice)
			setIcon(self.icon, forced or ico, ext, slice)
			self.selection = forced
			self:SetText(forced and L"Customized icon" or L"Based on slice action")
			if frame:IsShown() then slider:GetScript("OnValueChanged")(slider, slider:GetValue()) end
		end
		function f:HidePanel()
			frame:Hide()
		end
	end
	sliceDetail.optionBoxes = {} do
		local function update(self)
			return api.setSliceProperty(self.prop, self:GetChecked() and true or nil)
		end
		for i=1,4 do
			local e = CreateFrame("CheckButton", nil, sliceDetail, "InterfaceOptionsCheckButtonTemplate")
			e:SetHitRectInsets(0, -200, 0, 0) e:SetScript("OnClick", update)
			if i > 1 then e:SetPoint("TOPLEFT", sliceDetail.optionBoxes[i-1], "BOTTOMLEFT", 0, 5) end
			sliceDetail.optionBoxes[i] = e
		end
		sliceDetail.optionBoxes[1]:SetPoint("TOPLEFT", sliceDetail.icon, "BOTTOMLEFT", -4, 0)
		sliceDetail.optionBoxes.label = sliceDetail:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		sliceDetail.optionBoxes.label:SetPoint("LEFT", sliceDetail.optionBoxes[1], "LEFT", -204, 1)
	end
	
	do -- .macrotext
		local eb = CreateFrame("EditBox")
		eb:SetWidth(517) eb:SetMultiLine(true) eb:SetAutoFocus(false) eb:SetFontObject(GameFontHighlight)
		prepEditBox(eb, function(self) api.setSliceProperty("macrotext", (self:GetText():gsub("|c%x+|Hrkspell:([%d/]+)|h.-|h|r", "{{spell:%1}}"))) end)
		local bg = CreateFrame("Frame", nil, sliceDetail)
		bg:SetBackdrop({edgeFile="Interface/Tooltips/UI-Tooltip-Border", bgFile="Interface/DialogFrame/UI-DialogBox-Background-Dark", tile=true, edgeSize=16, trileSize=16, insets={left=4,right=4,bottom=4,top=4}})
		bg:SetBackdropBorderColor(0.7,0.7,0.7) bg:SetBackdropColor(0,0,0,0.7)
		local scroll = CreateFrame("ScrollFrame", "RKC_MacroScrollFrame", bg, "UIPanelScrollFrameTemplate")
		scroll:SetSize(520, 280) scroll:SetPoint("TOPLEFT", sliceDetail.optionBoxes.label, "BOTTOMLEFT", 3, -10) scroll:SetScrollChild(eb)
		bg:SetPoint("TOPLEFT", scroll, "TOPLEFT", -5, 4)
		bg:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", 26, -4)
		scroll:SetScript("OnMouseDown", function() eb:SetFocus() end)
		do -- cursor scrolling
			local bar = scroll.ScrollBar
			eb:SetScript("OnCursorChanged", function(self, x, y, w, h)
				local height, offset, y = scroll:GetHeight(), scroll:GetVerticalScroll(), -y
				if offset > y then offset = y -- cursor is above visibile region
				elseif (height + offset) < (y+h) then offset = y + h - height -- cursor extends below visible region
				else return end
				local _, mx = bar:GetMinMaxValues()
				bar:SetMinMaxValues(0, mx < offset and offset or mx)
				bar:SetValue(offset)
			end)
		end
		local function decodeSpellLink(sid)
			local compound
			for id in sid:gmatch("%d+") do
				local link, name, rank = GetSpellLink(tonumber(id)), GetSpellInfo(tonumber(id))
				if rank ~= "" then rank = " (" .. rank .. ")" end
				compound = (compound and (compound .. " / ") or "") .. (link and link:match("%[.-%]"):gsub("%]$", rank .. "]") or id)
			end
			return "|cff71d5ff|Hrkspell:" .. sid .. "|h" .. compound .. "|h|r"
		end
		function bg:SetMacro(macrotext)
			eb:SetText(((macrotext or ""):gsub("{{spell:([%d/]+)}}", decodeSpellLink)))
		end
		sliceDetail.macrotext, bg.editBox, bg.scrollFrame = bg, eb, scroll
		do -- Hook linking
			local old = ChatEdit_InsertLink
			function ChatEdit_InsertLink(link, ...)
				if GetCurrentKeyBoardFocus() == eb then
					local isEmpty = eb:GetText() == ""
					if link:match("item:") then
						eb:Insert((isEmpty and (GetItemSpell(link) and SLASH_USE1 or SLASH_EQUIP1) or "") .. " " .. GetItemInfo(link))
					elseif link:match("spell:") and not IsPassiveSpell(tonumber(link:match("spell:(%d+)"))) then
						eb:Insert((isEmpty and SLASH_CAST1 or "") .. " " .. decodeSpellLink(link:match("spell:(%d+)")))
					else
						eb:Insert(link:match("|h%[?(.-[^%]])%]?|h"))
					end
					return true
				else
					return old(link, ...)
				end
			end
		end
	end
	sliceDetail.remove = CreateFrame("Button", nil, sliceDetail, "UIPanelButtonGrayTemplate")
	sliceDetail.remove:SetSize(120, 22) sliceDetail.remove:SetPoint("BOTTOMRIGHT", -10, 10)
	sliceDetail.remove:SetScript("OnClick", function() api.deleteSlice() end)
end
newSlice = CreateFrame("Frame", nil, ringContainer) do
	newSlice:SetAllPoints()
	newSlice:Hide()
	newSlice.slider = CreateFrame("Slider", "RKC_NewSliceCategorySlider", newSlice, "UIPanelScrollBarTrimTemplate") do
		local s = newSlice.slider
		s:SetPoint("TOPLEFT", 162, -19)
		s:SetPoint("BOTTOMLEFT", 162, 17)
		s:SetMinMaxValues(0, 20)
		s:SetValueStep(1)
		s.scrollStep = 5
		s.Up, s.Down = RKC_NewSliceCategorySliderScrollUpButton, RKC_NewSliceCategorySliderScrollDownButton
		local cap = CreateFrame("Frame", nil, newSlice)
		cap:SetPoint("TOPLEFT")
		cap:SetPoint("BOTTOMRIGHT", s, "BOTTOMRIGHT")
		cap:SetScript("OnMouseWheel", function(self, delta)
			s:SetValue(s:GetValue()-delta)
		end)
	end
	
	local cats, actions, searchCat, selectCategory, selectedCategory, selectedCategoryId, selectedCategorySize = {}, {}, newproxy(true)
	do -- search API
		local mt, store, marks, count, s2, m2, c2 = getmetatable(searchCat), {}, {[0]=0}, 0, {}, {[0]=0}, 0
		function mt:__len()
			return count
		end
		function mt:__call(id)
			if id < 0 or id > count then return end
			return unpack(store, marks[id-1]+1, marks[id] or -1)
		end
		local function insert(id, n, a, ...)
			if n <= 0 then return id-1 end
			s2[id] = a
			return insert(id+1,n-1, ...)
		end
		local function matchAction(q, ...)
			local cname, aname = AB:describe(...)
			if type(aname) ~= "string" then return end
			aname = aname:match("|") and aname:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|T.-|t", ""):lower() or aname:lower()
			if aname:match(q) then
				local id = insert(m2[c2]+1, select("#", ...), ...)
				c2, m2[c2+1] = c2 + 1, id
			end
		end
		mt.__index = {search=function(self, query, source)
			c2, query = 0, query:lower():gsub("[%-%[%]()*+?%%]", "%%%1"):gsub("%s+", "%%s+")
			if source then
				for i=1,#source do
					pcall(matchAction, query, source(i))
				end
			else
				for _, c in AB.categories do
					for i=1,#c do
						pcall(matchAction, query, c(i))
					end
				end
			end
			store, marks, count, s2, m2, c2 = s2, m2, c2, store, marks, count
		end}
	end
	do -- newSlice.search
		local s = CreateFrame("EditBox", "RKC_NewSliceCategorySearch", newSlice, "InputBoxTemplate")
		s:SetSize(153, 22) s:SetPoint("TOPLEFT", 7, -1) s:SetTextInsets(16, 0, 0, 0)
		s:SetAutoFocus(false) s:SetScript("OnEscapePressed", s.ClearFocus)
		local i = s:CreateTexture(nil, "OVERLAY")
		i:SetSize(14, 14) i:SetPoint("LEFT", 0, -1)
		i:SetTexture("Interface/Common/UI-Searchbox-Icon")
		local l, tip = s:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall"), CreateFrame("GameTooltip", "RKC_SearchTip", newSlice, "GameTooltipTemplate")
		l:SetPoint("LEFT", 16, 0)
		s:SetScript("OnEditFocusGained", function(s)
			l:Hide()
			i:SetVertexColor(0.90, 0.90, 0.90)
			tip:SetFrameStrata("TOOLTIP")
			tip:SetOwner(s, "ANCHOR_BOTTOM")
			tip:AddLine(L"Press |cffffffffEnter|r to search")
			tip:AddLine(L"|cffffffffCtrl+Enter|r to search within current results", nil, nil, nil, true)
			tip:AddLine(L"|cffffffffEscape|r to cancel", true)
			tip:Show()
		end)
		s:SetScript("OnEditFocusLost", function(s) 
			l[s:GetText():gsub("%s", "") ~= "" and "Hide" or "Show"](l)
			i:SetVertexColor(0.75, 0.75, 0.75)
			tip:Hide()
		end)
		s:SetScript("OnEnterPressed", function(s)
			s:ClearFocus()
			if s:GetText():match("%S") then
				searchCat:search(s:GetText(), IsControlKeyDown() and selectedCategory or nil)
				selectCategory(-1)
			end
		end)
		newSlice.search, s.ico, s.label = s, i, l
	end
	
	local catbg = newSlice:CreateTexture(nil, "BACKGROUND")
	catbg:SetPoint("TOPLEFT", 2, -2) catbg:SetPoint("RIGHT", newSlice, "RIGHT", -2, 0) catbg:SetPoint("BOTTOM", 0, 2)
	catbg:SetTexture(0,0,0,0.65)
	local function onClick(self) selectCategory(self:GetID()+newSlice.slider:GetValue()) end
	for i=1,22 do
		local b = CreateFrame("Button", nil, newSlice)
		b:SetSize(159, 20) b:SetID(i)
		b:SetNormalTexture("Interface/AchievementFrame/UI-Achievement-Category-Background")
		b:SetHighlightTexture("Interface/AchievementFrame/UI-Achievement-Category-Highlight")
		b:GetNormalTexture():SetTexCoord(7/256, 162/256, 5/32, 24/32)
		b:GetHighlightTexture():SetTexCoord(7/256, 163/256, 5/32, 24/32)
		b:GetNormalTexture():SetVertexColor(0.6, 0.6, 0.6)
		b:SetNormalFontObject(GameFontHighlight)
		b:SetPushedTextOffset(0,0)
		b:SetText(" ") b:GetFontString():SetPoint("CENTER", 0, 1)
		b:SetScript("OnClick", onClick)
		cats[i] = b
		if i > 1 then cats[i]:SetPoint("TOP", cats[i-1], "BOTTOM") end
	end
	cats[1]:SetPoint("TOPLEFT", 2, -22)

	newSlice.desc = newSlice:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	newSlice.desc:SetPoint("TOPLEFT", newSlice.slider, "TOPRIGHT", 2, 10)
	newSlice.desc:SetPoint("RIGHT", -24, 0)
	newSlice.desc:SetHeight(26)
	newSlice.desc:SetJustifyV("TOP") newSlice.desc:SetJustifyH("CENTER")
	
	newSlice.close = CreateFrame("Button", "RKC_CloseNewSliceBrowser", newSlice, "UIPanelCloseButton")
	newSlice.close:SetPoint("TOPRIGHT", 3, 4)
	newSlice.close:SetSize(30, 30)
	newSlice.close:SetScript("OnClick", function(self) self:GetParent():Hide() ringDetail:Show() end)
	local b = newSlice.close:CreateTexture(nil, "BACKGROUND", "UI-Frame-TopCornerRight")
	b:SetTexCoord(90/128, 113/128, 2/128, 25/128)
	b:SetPoint("TOPLEFT", 4, -5) b:SetPoint("BOTTOMRIGHT", -5, 4)
	b:SetVertexColor(0.6,0.6,0.6)
	
	newSlice.slider2 = CreateFrame("Slider", "RKC_NewSliceActionSlider", newSlice, "UIPanelScrollBarTrimTemplate") do
		local s = newSlice.slider2
		s:SetPoint("TOPRIGHT", -2, -38)
		s:SetPoint("BOTTOMRIGHT", -2, 16)
		s:SetMinMaxValues(0, 20)
		s:SetValueStep(1)
		s.scrollStep = 4
		s.Up, s.Down = RKC_NewSliceActionSliderScrollUpButton, RKC_NewSliceActionSliderScrollDownButton
		local cap = CreateFrame("Frame", nil, newSlice)
		cap:SetPoint("TOPRIGHT")
		cap:SetPoint("BOTTOMLEFT", newSlice.slider, "BOTTOMRIGHT")
		cap:SetScript("OnMouseWheel", function(self, delta)
			s:SetValue(s:GetValue()-delta)
		end)
	end

	local function onClick(self)
		api.addSlice(nil, selectedCategory(self:GetID() + newSlice.slider2:GetValue()*2))
	end
	local function onDragStart(self) SetCursor(self.ico:GetTexture()) end
	local function onDragStop(self)
		SetCursor(nil)
		local e, x, y = ringContainer.slices[1], GetCursorPosition()
		if not e:GetLeft() then e = ringContainer.prev end
		local scale, l, b, w, h = e:GetEffectiveScale(), e:GetRect()
		local dy, dx = math.floor(-(y / scale - b - h-1)/(h+2)+0.5), x / scale - l
		if dx < -w/2 or dx > 3*w/2 then return end
		if dy < -1 or dy > (#ringContainer.slices+1) then return end
		api.addSlice(dy, selectedCategory(self:GetID() + newSlice.slider2:GetValue()*2))		
	end
	local function onEnter(self)
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
		if type(self.tipFunc) == "function" then
			EC_pcall("OPie", "ABTip", self.tipFunc, GameTooltip, self.tipFuncArg)
		else
			GameTooltip:AddLine(self.name:GetText())
		end
		GameTooltip:Show()
	end
	local function onLeave(self)
		GameTooltip:Hide()
	end
	for i=1,24 do
		local f = CreateFrame("Button", nil, newSlice)
		f:SetSize(176, 34) f:SetPoint("TOPLEFT", newSlice.desc, "BOTTOMLEFT", 178*(1 - i % 2), -math.floor((i-1)/2)*36+3)
		f:RegisterForDrag("LeftButton")
		actions[i] = f
		f:SetID(i)
		f:SetScript("OnDragStart", onDragStart)
		f:SetScript("OnDragStop", onDragStop)
		f:SetScript("OnDoubleClick", onClick)
		f:SetScript("OnEnter", onEnter)
		f:SetScript("OnLeave", onLeave)
		f.ico = f:CreateTexture(nil, "ARTWORK")
		f.ico:SetSize(32,32) f.ico:SetPoint("LEFT", 1, 0)
		f.name = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		f.name:SetPoint("TOPLEFT", f.ico, "TOPRIGHT", 3, -2)
		f.name:SetPoint("RIGHT", -2, 0)
		f.name:SetJustifyH("LEFT")
		f.sub = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		f.sub:SetPoint("TOPLEFT", f.name, "BOTTOMLEFT", 0, -2)
		f.sub:SetPoint("RIGHT", -2, 0)
		f.sub:SetJustifyH("LEFT")
		f:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square")
		f:GetHighlightTexture():SetAllPoints(f.ico)
	end

	local function syncActions()
		local slider = newSlice.slider2
		local base, _, maxV = slider:GetValue()*2, slider:GetMinMaxValues()
		newSlice.slider2.Up[base == 0 and "Disable" or "Enable"](newSlice.slider2.Up)
		newSlice.slider2.Down[base == maxV*2 and "Disable" or "Enable"](newSlice.slider2.Down)
		for i=1,#actions do
			local e = actions[i]
			if i + base <= selectedCategorySize then
				local stype, sname, sicon, extico, tipfunc, tiparg = AB:describe(selectedCategory(i+base))
				pcall(setIcon, e.ico, sicon, extico)
				e.tipFunc, e.tipFuncArg = tipfunc, tiparg
				e.name:SetText(sname)
				e.sub:SetText(stype)
				e:Show()
			else
				e:Hide()
			end
		end
	end
	local function syncCats(base)
		local slider = newSlice.slider
		slider.Up[base == 0 and "Disable" or "Enable"](slider.Up)
		slider.Down[base == select(2,slider:GetMinMaxValues()) and "Disable" or "Enable"](slider.Down)
		for i=1,#cats do
			local e, category = cats[i], AB.categories[i+base]
			e[category and "Show" or "Hide"](e)
			e[i+base == selectedCategoryId and "LockHighlight" or "UnlockHighlight"](e)
			e:SetText(category and category.name or "")
		end
		if selectedCategoryId == -1 then
			newSlice.search.ico:SetVertexColor(0.3, 1, 0)
		else
			newSlice.search.ico:SetVertexColor(0.75, 0.75, 0.75)			
		end
	end
	function selectCategory(id)
		selectedCategoryId, selectedCategory = id, id == -1 and searchCat or AB.categories[id]
		selectedCategorySize = #selectedCategory
		if id ~= -1 then
			newSlice.search:SetText("")
			newSlice.search.label:Show()
		end
		syncCats(newSlice.slider:GetValue())
		newSlice.slider2:SetMinMaxValues(0, math.max(0, math.ceil((selectedCategorySize - #actions)/2)))
		newSlice.slider2:SetValue(0)
		syncActions()
		newSlice.search:ClearFocus()
	end
	newSlice.slider:SetScript("OnValueChanged", function(self, value) syncCats(value) end)
	newSlice.slider2:SetScript("OnValueChanged", syncActions)
	newSlice:SetScript("OnShow", function(self)
		selectCategory(1)
		self.slider:SetMinMaxValues(0, math.max(0, #AB.categories - #cats))
		self.slider:SetValue(0)
	end)
end

local PLAYER_CLASS, PLAYER_CLASS_UC, PLAYER_CLASS_COLOR_HEX = UnitClass("player") do
	local c = RAID_CLASS_COLORS[PLAYER_CLASS_UC] or RAID_CLASS_COLORS.PRIEST
	PLAYER_CLASS_COLOR_HEX = ("%02x%02x%02x"):format(c.r*255, c.g*255, c.b*255)
end

local function getSliceInfo(slice)
	return AB:describe(RK:UnpackABAction(slice))
end

local pendingRingData, cancelRingData, ringNameMap, ringOrderMap, ringNames, currentRing, currentRingName, sliceBaseIndex, currentSliceIndex = {}, {}, {}, {}
local sortPrefixes = {[0]="|cff25bdff|TInterface/FriendsFrame/UI-Toast-FriendOnlineIcon:14:14:0:1:32:32:8:24:8:24:30:190:255|t "}
function api.initRingsList()
	ringNames = {hidden={}}
	for name, dname, active, slices, internal, limit in RK:GetManagedRings() do
		if active then
			table.insert(internal and ringNames.hidden or ringNames, name)
			ringNameMap[name], ringOrderMap[name] = dname, limit and (limit:match("[^A-Z]") and 0 or 2)
		end
	end
	local x1,x2,y1,y2 = unpack(CLASS_ICON_TCOORDS[PLAYER_CLASS_UC])
	sortPrefixes[2] = ("|cff%s|TInterface/GLUES/CHARACTERCREATE/UI-CharacterCreate-Classes:14:14:0:1:256:256:%d:%d:%d:%d|t "):format(PLAYER_CLASS_COLOR_HEX, x1*256+6,x2*256-6,y1*256+6,y2*256-6)
end
local function sortNames(a,b)
	local oa, ob, na, nb = ringOrderMap[a] or 5, ringOrderMap[b] or 5, ringNameMap[a] or "", ringNameMap[b] or ""
	return oa < ob or (oa == ob and na < nb) or false
end
function ringDropDown:initialize(level)
	local info = UIDropDownMenu_CreateInfo()
	info.func, info.minWidth = api.selectRing, level == 1 and 310 or nil
	if not ringNames then api.initRingsList() end
	local t = level == 2 and ringNames.hidden or ringNames
	table.sort(t, sortNames)
	for i=1,#t do
		if pendingRingData[t[i]] ~= false then
			info.arg1, info.checked, info.text = t[i], currentRingName == t[i], (sortPrefixes[ringOrderMap[t[i]]] or "") .. (pendingRingData[t[i]] and pendingRingData[t[i]].name or ringNameMap[t[i]])
			UIDropDownMenu_AddButton(info, level)
		end
	end
	t, info.hasArrow, info.notCheckable, info.fontObject, info.text, info.func, info.checked = t.hidden, 1, 1, GameFontNormalSmall, L"Hidden rings"
	for i=1,t and #t or 0 do
		if pendingRingData[t[i]] ~= false then
			UIDropDownMenu_AddButton(info)
			break
		end
	end
end
function api.createRing(name)
	local kn = name:gsub("%s", "")
	if kn == "" then return end
	if not ringNames then api.initRingsList() end
	local iname = RK:GenFreeRingName(kn, pendingRingData)
	pendingRingData[iname], ringNameMap[iname], ringOrderMap[iname] = {name=name, limit=UnitName("player")}, name, 0
	table.insert(ringNames, 1, iname)
	api:selectRing(iname)
end
function api.selectRing(_, name)
	CloseDropDownMenus()
	ringDetail:Hide()
	sliceDetail:Hide()
	newSlice:Hide()
	local desc = pendingRingData[name] or RK:GetRingDescription(name)
	currentRing, currentRingName = nil
	if not desc then return end
	UIDropDownMenu_SetText(ringDropDown, desc.name or name)
	ringDetail.rotation:SetValue(desc.offset or 0)
	ringDetail.name:SetText(desc.name or name)
	ringDetail.binding:SetBindingText(desc.hotkey)
	ringDetail.hiddenRing:SetChecked(desc.internal)
	ringDetail.opportunistCA:SetChecked(not desc.noOpportunisticCA)
	local qaBroken, dbBroken = not OneRingLib:GetOption("CenterAction", name), not OneRingLib:GetOption("UseDefaultBindings", name)
	ringDetail.opportunistCA.Text:SetText(L"Pre-select a quick action slice" .. (qaBroken and (RED_FONT_COLOR_CODE .. " (" .. L"Disabled" .. ")|r") or ""))
	ringDetail.opportunistCA.tooltipText = qaBroken and (L"You must enable the %s option for this ring in OPie options to use quick actions."):format("|cffffffff" .. L"Quick action at ring center" .. "|r") or nil
	ringDetail.binding.label:SetText(L"Default ring binding:" .. (dbBroken and (RED_FONT_COLOR_CODE .. " (" .. L"Disabled" .. ")|r") or ""))
	ringDetail.binding.tooltipText = dbBroken and (L"When the %s option is disabled, ring bindings can only be changed in the Bindings panel."):format("|cffffffff" .. L"Use default ring bindings" .. "|r") or nil		
	currentRing, currentRingName, sliceBaseIndex, currentSliceIndex = desc, name, 1
	ringDetail:Show()
	ringDetail.scope:text()
	api.updateRingLine()
	ringContainer:Show()
end
function api.updateRingLine()
	ringContainer.prev[sliceBaseIndex == 1 and "Disable" or "Enable"](ringContainer.prev)
	ringContainer.next:Disable()
	for i=sliceBaseIndex,#currentRing do
		local e = ringContainer.slices[i-sliceBaseIndex+1]
		if not e then ringContainer.next:Enable() break end
		local stype, sname, sicon, icoext = getSliceInfo(currentRing[i])
		pcall(setIcon, e.tex, currentRing[i].icon or sicon, icoext, currentRing[i])
		e.check[currentRing[i].action and "Show" or "Hide"](e.check)
		e:SetChecked(currentSliceIndex == i)
		e:Show()
	end
	for i=#currentRing+sliceBaseIndex,#ringContainer.slices do
		ringContainer.slices[i]:Hide()
	end
end
function api.scrollSliceList(dir)
	sliceBaseIndex = math.max(1,sliceBaseIndex + dir)
	api.updateRingLine()
end
function api.resolveSliceOffset(id)
	return sliceBaseIndex + id
end
function sliceDetail.skipSpecs:set(id)
	api.setSliceProperty("skipSpecs", id)
end
function sliceDetail.skipSpecs:text(skipSpecs)
	local text, u = "", skipSpecs and GetNumSpecializations() or 0
	for i=1, u do
		local id, name, desc, icon = GetSpecializationInfo(i)
		if not skipSpecs:match(" " .. id .. " ") then
			text, u = text .. (text == "" and "" or ", ") .. name, u - 1
		end
	end
	if not skipSpecs:match(" " .. PLAYER_CLASS_UC .. " ") then
		text, u = text .. (text == "" and "" or ", ") .. L"Unspecialized", u - 1
	end
	if u < 0 then
		text = (L"All %s characters"):format("|cff" .. PLAYER_CLASS_COLOR_HEX .. PLAYER_CLASS .. "|r")
	elseif text == "" then
		text = (L"No %s characters"):format("|cff" .. PLAYER_CLASS_COLOR_HEX .. PLAYER_CLASS .. "|r")
	else
		text = (L"Only %s"):format("|cff" .. PLAYER_CLASS_COLOR_HEX .. text .. "|r")
	end
	UIDropDownMenu_SetText(self, text)
end
function sliceDetail.skipSpecs:initialize(level)
	local info, skip = UIDropDownMenu_CreateInfo(), currentRing[currentSliceIndex].skipSpecs or ""
	info.func, info.isNotRadio, info.minWidth = self.set, true, self:GetWidth()-40
	info.text, info.arg1, info.checked = (L"Unspecialized %s characters"):format("|cff" .. PLAYER_CLASS_COLOR_HEX .. PLAYER_CLASS .. "|r"), PLAYER_CLASS_UC, not skip:match(" " .. PLAYER_CLASS_UC .. " ")
	UIDropDownMenu_AddButton(info)
	for i=1, GetNumSpecializations() do
		local id, name, desc, icon = GetSpecializationInfo(i)
		info.text, info.arg1, info.checked = "|T" .. icon .. ":16:16:0:0:64:64:4:60:4:60|t " .. name, id, not skip:match(" " .. id .. " ")
		UIDropDownMenu_AddButton(info)
	end
end
function ringDetail.scope:initialize(level)
	local name, info = UnitName("player"), UIDropDownMenu_CreateInfo()
	info.func, info.minWidth, info.text, info.checked = self.set, self:GetWidth()-40, L"All characters", currentRing.limit == nil
	UIDropDownMenu_AddButton(info)
	info.text, info.checked, info.arg1 = (L"All %s characters"):format("|cff" .. PLAYER_CLASS_COLOR_HEX .. PLAYER_CLASS .. "|r"), currentRing.limit == PLAYER_CLASS_UC, PLAYER_CLASS_UC
	UIDropDownMenu_AddButton(info)
	info.text, info.checked, info.arg1 = (L"Only %s"):format("|cff" .. PLAYER_CLASS_COLOR_HEX .. name .. "|r"), currentRing.limit == name, name
	UIDropDownMenu_AddButton(info)
end
function ringDetail.scope:set(arg1)
	api.setRingProperty("limit", arg1)
end
function ringDetail.scope:text()
	local name = UnitName("player")
	UIDropDownMenu_SetText(self,
		currentRing.limit == nil and L"All characters" or
		currentRing.limit == PLAYER_CLASS_UC and (L"All %s characters"):format("|cff" .. PLAYER_CLASS_COLOR_HEX .. PLAYER_CLASS .. "|r") or
		currentRing.limit == name and  (L"Only %s"):format("|cff" .. PLAYER_CLASS_COLOR_HEX .. name .. "|r")
	)
end
function api.setRingProperty(name, value)
	if not currentRing then return end
	if currentRing[name] ~= value then pendingRingData[currentRingName] = currentRing end
	currentRing[name] = value
	if name == "limit" then
		ringDetail.scope:text()
		ringOrderMap[currentRingName] = value ~= nil and (value:match("[^A-Z]") and 0 or 2) or nil
	elseif name == "hotkey" then
		ringDetail.binding:SetBindingText(value)
	elseif name == "internal" then
		local source, dest = value and ringNames or ringNames.hidden, value and ringNames.hidden or ringNames
		for i=1,#source do if source[i] == currentRingName then
			table.remove(source, i)
			break
		end end
		table.insert(dest, currentRingName)
	end
end
function api.setSliceProperty(prop, value, ...)
	local slice = assert(currentRing[currentSliceIndex], "Setting a slice property on an unknown slice")
	local changed = false
	if prop == "color" then
		local r,g,b = value, ...
		changed = not (r == slice.r and g == slice.g and b == slice.b)
		slice.r, slice.g, slice.b = r,g,b
		sliceDetail.color:SetColor(r,g,b)
	elseif prop == "icon" then
		slice.icon, changed = value, slice.icon ~= value
		local _, _, ico, icoext = getSliceInfo(currentRing[currentSliceIndex])
		sliceDetail.icon:SetIcon(ico, value, icoext, currentRing[currentSliceIndex])
		api.updateRingLine()
	elseif prop == "macrotext" then
		slice[2], changed = value, slice[2] ~= value
	elseif prop == "skipSpecs" then
		local ss, specChunk, n = slice.skipSpecs or "", " " .. value .. " "
		ss, n = ss:gsub(specChunk, " ")
		if n == 0 then ss = ss:gsub(" ?$", specChunk) end
		slice[prop], changed = ss ~= " " and ss or nil, true
		sliceDetail.skipSpecs:text(ss)
	else
		slice[prop], changed = value, slice[prop] ~= value
	end
	if changed then pendingRingData[currentRingName] = currentRing end
end
local knownProps = {fcSlice="Allow as quick action", byName="Also use items with the same name", forceShow="Always show this slice", onlyEquipped="Only show when equipped", clickUsingRightButton="Simulate a right-click"}
function api.configureOptions(id, desc, a, ...)
	if not a then return id end
	local b = sliceDetail.optionBoxes[id]
	if not b then return id end
	if knownProps[a] then
		b.prop, id = a, id + 1
		b:SetChecked(desc[a])
		b.Text:SetText(L(knownProps[a]))
		b:Show()
	end
	b.tooltipText = nil
	if a == "fcSlice" and not OneRingLib:GetOption("CenterAction", currentRingName) then
		b.Text:SetText(b.Text:GetText() .. RED_FONT_COLOR_CODE .. " (" .. L"Disabled" .. ")|r")
		b.tooltipText = (L"You must enable the %s option for this ring in OPie options to use quick actions."):format("|cffffffff" .. L"Quick action at ring center" .. "|r")
	end
	return api.configureOptions(id, desc, ...)
end
function api.selectSlice(offset, select)
	if not select then
		currentSliceIndex = nil
		return sliceDetail:Hide(), ringDetail:Show()
	end
	ringDetail:Hide() newSlice:Hide() sliceDetail:Hide()
	local old, id = ringContainer.slices[(currentSliceIndex or 0) + 1 - sliceBaseIndex], sliceBaseIndex + offset
	local desc = currentRing[id]
	if old then old:SetChecked(nil) end
	currentSliceIndex = nil
	if not desc then return ringDetail:Show() end
	
	local stype, sname, sicon, icoext = getSliceInfo(desc)
	if sname ~= "" then
		sliceDetail.desc:SetFormattedText("%s: |cffffffff%s|r", stype or "?", sname or "?")
	else
		sliceDetail.desc:SetText(stype or "?")
	end
	sliceDetail.icon:HidePanel()
	sliceDetail.icon:SetIcon(sicon, desc.icon, icoext, desc)
	sliceDetail.color:SetColor(desc.r, desc.g, desc.b)
	sliceDetail.caption:SetText(desc.caption or "")
	sliceDetail.skipSpecs:text(desc.skipSpecs or "")
	if desc[1] == "macrotext" then
		sliceDetail.macrotext:SetMacro(desc[2])
		sliceDetail.macrotext:Show()
	else
		sliceDetail.macrotext:Hide()
	end
	for i=api.configureOptions(1, desc, "fcSlice", AB:options(desc[1])),#sliceDetail.optionBoxes do
		sliceDetail.optionBoxes[i]:Hide()
	end
	sliceDetail:Show()
	currentSliceIndex = id
end
function api.moveSlice(source, dest)
	if not (currentRing and currentRing[source] and currentRing[dest]) then return end
	currentRing[source], currentRing[dest] = currentRing[dest], currentRing[source]
	pendingRingData[currentRingName] = currentRing
	if currentSliceIndex == source then currentSliceIndex = dest end
	api.updateRingLine()
end
function api.deleteSlice(id)
	if id == nil then id = currentSliceIndex end
	if id and currentRing and currentRing[id] then
		table.remove(currentRing, id)
		if sliceBaseIndex == id and sliceBaseIndex > 1 then
			sliceBaseIndex = sliceBaseIndex - 1
		end
		if id == currentSliceIndex then
			currentSliceIndex = nil
			sliceDetail:Hide()
			ringDetail:Show()
		end
		api.updateRingLine()
		pendingRingData[currentRingName] = currentRing
	end
end
function api.deleteRing()
	if currentRing then
		ringContainer:Hide()
		pendingRingData[currentRingName], currentRing, currentRingName = false, nil
		UIDropDownMenu_SetText(ringDropDown, L"Select a ring to modify")
	end
end
function api.restoreDefault()
	if currentRingName then
		local _, _, isDefaultAvailable, isDefaultOverriden = RK:GetRingInfo(currentRingName)
		if isDefaultAvailable and isDefaultOverriden then
			RK:RestoreDefaults(currentRingName)
			cancelRingData[currentRingName], pendingRingData[currentRingName] = currentRing, nil
		elseif (isDefaultAvailable or isDefaultOverriden) then
			pendingRingData[currentRingName] = nil
		end
		api.selectRing(nil, currentRingName)
	end
end
function api.addSlice(pos, ...)
	pos = math.max(1, math.min(#currentRing+1, pos and (pos + sliceBaseIndex) or (#currentRing+1)))
	table.insert(currentRing, pos, {r=0.90,g=1,b=0,...})
	pendingRingData[currentRingName] = currentRing
	if pos < sliceBaseIndex then sliceBaseIndex = pos end
	api.updateRingLine()
end
ringDetail:SetScript("OnShow", function()
	local _,_, isDefaultAvailable, isDefaultOverriden = RK:GetRingInfo(currentRingName)
	ringDetail.restore:SetText(isDefaultAvailable and L"Restore default" or L"Undo changes")
	ringDetail.restore:SetShown((isDefaultAvailable and (isDefaultOverriden or pendingRingData[currentRingName])) or (pendingRingData[currentRingName] and isDefaultOverriden))
end)

function panel:refresh()
	btnNewRing:SetText(L"Create New Ring")
	panel.desc:SetText(L"Customize OPie by modifying existing rings, or creating your own.")
	UIDropDownMenu_SetText(ringDropDown, L"Select a ring to modify")
	ringDetail.scopeLabel:SetText(L"Make this ring available to:")
	ringDetail.rotationLabel:SetText(L"Ring Rotation:")
	ringDetail.hiddenRing.Text:SetText(L"Hide this ring")
	sliceDetail.color.label:SetText(L"Color:")
	sliceDetail.caption.label:SetText(L"Caption:")
	sliceDetail.icon.label:SetText(L"Icon:")
	sliceDetail.optionBoxes.label:SetText(L"Options:")
	ringDetail.optionsLabel:SetText(L"Options:")
	sliceDetail.remove:SetText(L"Delete slice")
	ringDetail.restore:SetText(L"Restore default")
	ringDetail.remove:SetText(L"Delete ring")
	ringDetail.newSlice:SetText(L"Add a new slice")
	newSlice.desc:SetText(L"Double click an action to add it to the ring.")
	newSlice.search.label:SetText(L"Search")
	sliceDetail.skipSpecs.label:SetText("Show for:")
	
	currentRingName, currentRing, currentSliceIndex, ringNames = nil
	ringContainer:Hide()
	ringDetail:Hide()
	sliceDetail:Hide()
	newSlice:Hide()
end
function panel:okay()
	ringContainer:Hide()
	for k,v in pairs(pendingRingData) do
		if v then v.save = true end
		RK:SetRing(k, v)
		pendingRingData[k] = nil
	end
	table.wipe(cancelRingData)
end
function panel:cancel()
	table.wipe(pendingRingData)
	for k, v in pairs(cancelRingData) do
		RK:SetRing(k, v)
	end
	table.wipe(cancelRingData)
end
function panel:default()
	RK:RestoreDefaults()
	table.wipe(cancelRingData)
	table.wipe(pendingRingData)
end
local function prot(f)
	return function() xpcall(f, geterrorhandler()) end
end
panel.okay, panel.cancel, panel.default = prot(panel.okay), prot(panel.cancel), prot(panel.default)

local function addProp(self, key, text)
	knownProps[key] = text
end
OneRingLib.ext.CustomRingsConfig = {addProperty=addProp}

SLASH_OPIE_CUSTOM_RINGS1 = "/rk"
function SlashCmdList.OPIE_CUSTOM_RINGS(args)
	if not panel:IsVisible() then
		InterfaceOptionsFrame_OpenToCategory(panel)
	end
end
conf.AddSlashSuffix(SlashCmdList.OPIE_CUSTOM_RINGS, "custom", "rings")