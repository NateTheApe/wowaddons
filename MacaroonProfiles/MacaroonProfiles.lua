--MacaroonProfiles, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

local M = Macaroon

MacaroonProfiles = {}

local CopyTable = M.CopyTable
local ClearTable = M.ClearTable

local numShown, options = 5

function M.ProfilesScrollFrame_OnLoad(self)

	self.offset = 0
	self.scrollbar = _G[self:GetName().."ScrollBar"]
	self.scrollbar.scrollStep = 1
	self.scrollChild = _G[self:GetName().."ScrollChildFrame"]

	self:SetBackdropBorderColor(0.5, 0.5, 0.5)
	self:SetBackdropColor(0,0,0,0.5)

	local button, lastButton, rowButton, count, fontString, script = false, false, false, 0

	for i=1,numShown do

		button = CreateFrame("CheckButton", self:GetName().."Button"..i, self, "MacaroonScrollFrameButtonTemplate")

		button.frame = self
		button.numShown = numShown

		button:SetScript("OnClick",
			function(self)

				if (IsShiftKeyDown() and MacaroonProfileManagerSpecs.currFocus) then
					MacaroonProfileManagerSpecs.currFocus:SetText((self.index:GetText()):match("^[^:]+"))
				end

				local button, buttonIndex, buttonBody
				for i=1,numShown do

					button = _G["MacaroonProfileManagerProfilesScrollFrameButton"..i]

					if (i == self:GetID()) then
						if (self.index:GetText() and strlen(self.index:GetText()) > 1) then
							options.top.nameedit:SetText((self.index:GetText()):match("^[^:]+"))
							options.top.nameedit.text:SetText("")
						else
							options.top.nameedit:SetText("")
							options.top.nameedit.text:SetText(M.Strings.P_NAME_EDIT)
						end

						if (self.note:GetText() and strlen(self.note:GetText()) > 1) then
							options.note.edit:SetText(self.note:GetText())
							options.note.edit.text:SetText("")
						else
							options.note.edit:SetText("")
							options.note.edit.text:SetText(M.Strings.P_NOTE_EDIT)
						end

						options.layout:SetChecked(self.layout)
						options.buttons:SetChecked(self.buttons)
						options.buttondata:SetChecked(self.buttondata)
						options.settings:SetChecked(self.settings)

					else
						button:SetChecked(nil)
					end
				end

			end)

		button:SetScript("OnShow",
			function(self)
				self:SetHeight(self.frame:GetHeight()/self.numShown)
			end)

		fontString = button:CreateFontString(button:GetName().."Index", "ARTWORK", "GameFontNormalLarge");
		fontString:SetPoint("BOTTOMLEFT", button, "LEFT", 5, 0)
		fontString:SetPoint("TOPLEFT", button, "TOPLEFT", 5, -3)
		fontString:SetJustifyV("TOP")
		fontString:SetJustifyH("LEFT")
		button.index = fontString

		fontString = button:CreateFontString(button:GetName().."Note", "ARTWORK", "GameFontNormalSmall");
		fontString:SetPoint("TOPLEFT", button.index, "TOPRIGHT", 15, 3)
		fontString:SetPoint("BOTTOMRIGHT", button, "RIGHT", 0, 0)
		fontString:SetJustifyV("CENTER")
		fontString:SetJustifyH("LEFT")
		fontString:SetTextColor(0.7,0.7,0.7)
		button.note = fontString

		fontString = button:CreateFontString(button:GetName().."Data", "ARTWORK", "GameFontNormalSmall");
		fontString:SetPoint("TOPLEFT", button, "LEFT", 7, 0)
		fontString:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT")
		fontString:SetJustifyV("TOP")
		fontString:SetJustifyH("LEFT")
		fontString:SetTextColor(1,1,1)
		button.data = fontString

		button:SetID(i)
		button:SetFrameLevel(self:GetFrameLevel()+2)
		button:SetNormalTexture("")

		if (not lastButton) then
			button:SetPoint("TOPLEFT",1,-5)
			button:SetPoint("TOPRIGHT",5,-5)
			lastButton = button
		else
			button:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, 0)
			button:SetPoint("TOPRIGHT", lastButton, "BOTTOMRIGHT", 0, 0)
			lastButton = button
		end
	end

	M.ProfilesScrollFrameUpdate()
end

function M.ProfilesScrollFrameUpdate()

	local frame = MacaroonProfileManagerProfilesScrollFrame
	local dataOffset, count, data, button, text, datum = FauxScrollFrame_GetOffset(frame), 1, {}

	for k,v in pairs(MacaroonProfiles) do
		data[count] = k; count = count + 1
	end

	table.sort(data)

	for i=1,numShown do

		button = _G["MacaroonProfileManagerProfilesScrollFrameButton"..i]
		button:SetChecked(nil)
		button.tooltip = nil
		button.layout = nil
		button.buttons = nil
		button.buttondata = nil
		button.settings = nil

		button:SetHeight((frame:GetHeight()/numShown)-2)

		count = dataOffset + i

		if (data[count]) then

			text = data[count]

			if (MacaroonProfiles[data[count]].layout or MacaroonProfiles[data[count]].buttons or MacaroonProfiles[data[count]].buttondata or MacaroonProfiles[data[count]].settings) then

				datum = ""

				if (MacaroonProfiles[data[count]].layout) then
					datum = datum.."*"..M.Strings.P_LAYOUT.."  "
					button.layout = 1
				end

				if (MacaroonProfiles[data[count]].buttons) then
					datum = datum.."*"..M.Strings.P_BUTTONS.."  "
					button.buttons = 1
				end

				if (MacaroonProfiles[data[count]].buttondata) then
					datum = datum.."*"..M.Strings.P_BUTTONDATA.."  "
					button.buttondata = 1
				end

				if (MacaroonProfiles[data[count]].settings) then
					datum = datum.."*"..M.Strings.P_SETTINGS.."  "
					button.settings = 1
				end
			end

			button.index:SetText(text)
			button.note:SetText(MacaroonProfiles[data[count]].note or "")
			button.data:SetText(datum or "")
			button:Enable()
			button:Show()
		else

			if (i==1) then
				button.index:SetText(M.Strings.P_NOPROFILES)
				button.note:SetText("")
				button.data:SetText("")
				button:Disable()
			else
				button:Hide()
			end
		end
	end

	FauxScrollFrame_Update(frame, #data, numShown, 1)

	frame:Show()

	if (#data < 6) then
		frame.scrollbar:Hide()
	else
		frame.scrollbar:Show()
	end
end

function M.SaveProfile(name, update)

	PlaySound("gsTitleOptionOK")

	local origData, data, layout, buttons, settings, updateData
	local saveLayout, saveButtons, saveSettings

	if (strlen(name) < 1) then
		MacaroonMessageFrame:AddMessage(M.Strings.P_INVALID_NAME, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
		return
	end

	if (update) then

		if (not MacaroonProfiles[name]) then
			MacaroonMessageFrame:AddMessage(M.Strings.P_INVALID_NAME, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
			return
		end

		updateData = CopyTable(MacaroonProfiles[name])
	else
		saveLayout = options.layout:GetChecked()
		saveButtons = options.buttons:GetChecked()
		saveButtondata = options.buttondata:GetChecked()
		saveSettings = options.settings:GetChecked()
	end

	if (not saveLayout and not saveButtons and not saveButtondata and not saveSettings) then
		MacaroonMessageFrame:AddMessage(M.Strings.P_NOTHINGTOSAVE, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
		return
	end

	if (MacaroonProfiles[name]) then
		ClearTable(MacaroonProfiles[name])
	else
		MacaroonProfiles[name] = {}
	end

	for k,v in pairs(M.StatesToSave) do

		origData, layout, buttons = v()

		data = CopyTable(origData)

		local bars, btns = {}, {}

		if (layout) then
			for i=1,select('#',(";"):split(layout)) do
				local barsplit = select(i,(";"):split(layout))
				bars[barsplit] = true
			end
		end

		if (buttons) then
			for i=1,select('#',(";"):split(buttons)) do
				local btnsplit = select(i,(";"):split(buttons))
				btns[btnsplit] = true
			end
		end

		if (not saveLayout and layout) then

			for k,v in pairs(bars) do
				data[k] = nil
			end
		end

		if (not saveButtons and not saveButtondata and buttons) then

			for k,v in pairs(btns) do
				data[k] = nil
			end

			for k,v in pairs(bars) do
				if (data[k]) then
					for kk,vv in pairs(data[k]) do
						for key,value in pairs(data[k][kk][1].buttonList) do
							data[k][kk][1].buttonList[key] = ""
						end
					end
				end
			end
		end

		if (not saveButtondata and buttons) then

			for k,v in pairs(btns) do
				if (data[k]) then
					for kk,vv in pairs(data[k]) do
						ClearTable(data[k][kk][1])
						ClearTable(data[k][kk][2])
					end
				end
			end
		end

		local protected = {}

		for k,v in pairs(bars) do
			if (data[k]) then protected[k] = true end
		end

		for k,v in pairs(btns) do
			if (data[k]) then protected[k] = true end
		end

		if (not saveSettings) then
			for k,v in pairs(data) do
				if (not protected[k]) then
					data[k] = nil
				end
			end
		end

		MacaroonProfiles[name][k] = CopyTable(data)
	end

	if (update) then

		MacaroonProfiles[name].note = updateData.note
		MacaroonProfiles[name].layout = updateData.layout
		MacaroonProfiles[name].buttons = updateData.buttons
		MacaroonProfiles[name].buttondata = updateData.buttondata
		MacaroonProfiles[name].settings = updateData.settings

	else

		MacaroonProfiles[name].note = options.note.edit:GetText() or ""
		MacaroonProfiles[name].layout = saveLayout
		MacaroonProfiles[name].buttons = saveButtons
		MacaroonProfiles[name].buttondata = saveButtondata
		MacaroonProfiles[name].settings = saveSettings

		options.top.nameedit:ClearFocus()
		options.top.nameedit:ClearFocus()

		M.ProfilesScrollFrameUpdate()
	end
end

function M.LoadProfile(name)

	PlaySound("gsTitleOptionOK")

	if (not MacaroonProfiles[name]) then
		MacaroonMessageFrame:AddMessage(M.Strings.P_INVALID_NAME, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
		return
	end

	local data

	M.Ypos = 90

	if (MacaroonProfiles[name].layout) then
		for k,v in pairs(M.BarIndex) do
			M.DeleteBar(v)
		end
	end

	if (MacaroonProfiles[name].buttons or MacaroonProfiles[name].buttondata) then
		for k,v in pairs(M.Buttons) do
			M.ClearBindings(v[1]); M.UpdateFlyout(v[1])
		end
	end

	for k,v in pairs(M.SavedDataLoad) do
		data = CopyTable(MacaroonProfiles[name][k])
		v(data, true)
	end

	if (MacaroonProfiles[name].settings) then
		for k,v in pairs(M.CheckbuttonOptions) do
			v(_G["MacaroonMainMenuCheck"..k])
		end
	end

	options.top.nameedit:ClearFocus()
	options.top.nameedit:ClearFocus()

	M.ProfilesScrollFrameUpdate()

	M.Control_OnEvent(nil, "PLAYER_LOGIN")

end

function M.DeleteProfile(name)

	PlaySound("gsTitleOptionOK")

	if (strlen(name) < 1 or not MacaroonProfiles[name]) then
		MacaroonMessageFrame:AddMessage(M.Strings.P_INVALID_NAME, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
		return
	end

	options.top.nameedit:SetText("")
	options.top.nameedit:ClearFocus()
	options.top.nameedit.text:SetText(M.Strings.P_NAME_EDIT)

	options.note.edit:SetText("")
	options.note.edit:ClearFocus()
	options.note.edit.text:SetText(M.Strings.P_NOTE_EDIT)

	options.layout:SetChecked(nil)
	options.buttons:SetChecked(nil)
	options.buttondata:SetChecked(nil)
	options.settings:SetChecked(nil)

	MacaroonProfiles[name] = nil

	M.ProfilesScrollFrameUpdate()

end

function Macaroon.Profiles_ConfirmAction(self)

	local profile, confirm = self.namedit:GetText()

	if (self.save) then

		if (MacaroonProfiles[profile]) then
			confirm = true
		else
			self.func(profile)
		end

	elseif ((self.load or self.delete) and profile and #profile > 0) then
		confirm = true
	end

	if (confirm) then
		options.top:Hide()
		options.confirm:Show()
		options.confirm.profile = profile
		options.confirm.func = self.func
		options.confirm.title:SetText(format(self.confirm, profile))
	end

end

function Macaroon.Profiles_ConfirmYes(self)

	options.top:Show()
	options.confirm:Hide()

	if (options.confirm.func and options.confirm.profile) then
		options.confirm.func(options.confirm.profile)
	end

	options.confirm.func = nil; options.confirm.profile = nil
end

function Macaroon.Profiles_ConfirmNo(self)

	options.top:Show()
	options.confirm:Hide()

end

local function controlOnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ... == "MacaroonProfiles") then

		options = MacaroonProfileManagerOptions

	end
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", controlOnEvent)
frame:RegisterEvent("ADDON_LOADED")
