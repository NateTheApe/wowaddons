--Macaroon, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

local M = Macaroon

local bindMode, SD = false

local find = string.find
local match = string.match
local lower = string.lower
local gsub = string.gsub

local SpellIndex = M.SpellIndex

local function getModifier()

	local modifier

	if (IsAltKeyDown()) then
		modifier = "ALT-"
	end

	if (IsControlKeyDown()) then
		if (modifier) then
			modifier = modifier.."CTRL-";
		else
			modifier = "CTRL-";
		end
	end

	if (IsShiftKeyDown()) then
		if (modifier) then
			modifier = modifier.."SHIFT-";
		else
			modifier = "SHIFT-";
		end
	end

	return modifier
end

local function getBindkeyList(button)

	if (not button.config) then return M.Strings.KEYBIND_NONE end

	local bindkeys = gsub(button.config.hotKeyText, ":", ", ")

	bindkeys = gsub(bindkeys, "^, ", "")
	bindkeys = gsub(bindkeys, ", $", "")

	if (strlen(bindkeys) < 1) then
		bindkeys = M.Strings.KEYBIND_NONE
	end

	return bindkeys
end

local function setBindframeTooltip(bindFrame, button)

	GameTooltip:SetOwner(bindFrame, "ANCHOR_RIGHT")

	if (bindFrame.bindType == "button") then

		if (button.config.type == "action") then

			local action = button.config.action

			if (action and action ~= "") then
				GameTooltip:SetAction(action)
			else
				GameTooltip:SetText(M.Strings.EMPTY_BUTTON)
			end

		elseif (button.config.type == "macro") then

			local spell, item, link = button.macrospell, button.macroitem

			spell = lower(spell or "")

			if (spell and spell ~= "") then

				if (SpellIndex[spell]) then

					GameTooltip:SetSpellBookItem(SpellIndex[spell][1], SpellIndex[spell][2])

				elseif (type(button.config.macroIcon) == "table") then

					GameTooltip:SetHyperlink("spell:"..button.config.macroIcon[5])
				end

			elseif (item and item ~= "") then

				_, link = GetItemInfo(item)

				if (link) then
					GameTooltip:SetHyperlink(link)
				end
			else
				if (strlen(button.config.macro) > 0) then
					GameTooltip:SetText(button.config.macro)
				else
					GameTooltip:SetText(M.Strings.EMPTY_BUTTON)
				end
			end

		elseif (button.config.type == "pet") then

			local action = button.config.action

			if (button.isToken or not button.UberTooltips) then

				if (button.tooltipName) then
					GameTooltip:SetText(button.tooltipName, 1.0, 1.0, 1.0)

				end

				if ( button.tooltipSubtext ) then
					GameTooltip:AddLine(button.tooltipSubtext, "", 0.5, 0.5, 0.5)
				end
			else

				GameTooltip:SetPetAction(action)
			end

		end

		if (SD.checkButtons[205]) then
			GameTooltip:AddLine(format(M.Strings.KEYBIND_TOOLTIP1, bindFrame.bindType..button.id).."|r", 1.0, 1.0, 1.0)
			GameTooltip:AddLine(format(M.Strings.KEYBIND_TOOLTIP2, bindFrame.bindType, bindFrame.bindType), 1.0, 1.0, 1.0)
		end
		GameTooltip:AddLine(M.Strings.KEYBIND_TOOLTIP3..getBindkeyList(button).."|r")

	elseif (bindFrame.bindType == "spell") then

		if (_G[bindFrame:GetParent():GetName().."IconTexture"]:IsVisible()) then
			local id = SpellBook_GetSpellBookSlot(_G["SpellButton"..bindFrame:GetID()])
			GameTooltip:SetSpellBookItem(id, SpellBookFrame.bookType)
		end

		local button = { config = bindFrame.bindTable[bindFrame[bindFrame.bindType]] }

		if (SD.checkButtons[205]) then
			GameTooltip:AddLine(format(M.Strings.KEYBIND_TOOLTIP1, bindFrame.bindType).."|r", 1.0, 1.0, 1.0)
			GameTooltip:AddLine(format(M.Strings.KEYBIND_TOOLTIP2, bindFrame.bindType, bindFrame.bindType), 1.0, 1.0, 1.0)
		end
		GameTooltip:AddLine(M.Strings.KEYBIND_TOOLTIP3..getBindkeyList(button).."|r")

	elseif (bindFrame.bindType == "macro") then

		local name, _, body, _ = GetMacroInfo(MacroFrame.macroBase + bindFrame:GetID())
		if (name and body) then
			name = "|cffffffff"..name.."|r"
			GameTooltip:AddLine(name.."\n\n"..body)
		end

		local button = { config = bindFrame.bindTable[bindFrame[bindFrame.bindType]] }

		if (SD.checkButtons[205]) then
			GameTooltip:AddLine(format(M.Strings.KEYBIND_TOOLTIP1, bindFrame.bindType).."|r", 1.0, 1.0, 1.0)
			GameTooltip:AddLine(format(M.Strings.KEYBIND_TOOLTIP2, bindFrame.bindType, bindFrame.bindType), 1.0, 1.0, 1.0)
		end
		GameTooltip:AddLine(M.Strings.KEYBIND_TOOLTIP3..getBindkeyList(button).."|r")
	end

	GameTooltip:Show()
end

function M.ButtonBind(off)

	if (InCombatLockdown()) then
		return
	end

	if (not off) then
		M.ObjectEdit(true)
		M.RaiseButtons(true)
	end

	if (not bindMode and off) then
		return
	end

	if (bindMode or off) then

		bindMode = false

		for k,v in pairs(M.Buttons) do

			v[1].bindframe:Hide()
			v[1].bindframe:SetFrameStrata("LOW")

			v[1].editmode = false
		end

		if (not off) then

			for k,v in pairs(M.BarIndex) do
				v.updateBarTarget(v)
				v.updateBarLink(v)
				v.updateBarHidden(v)
			end

			for k,v in pairs(M.HideGrids) do
				v(nil, nil, true)
			end
		end

		M.Save()

		collectgarbage()

	else

		bindMode = true

		for k,v in pairs(M.Buttons) do

			v[1].bindframe:Show()
			v[1].bindframe:SetFrameStrata(v[1].bar:GetFrameStrata())
			v[1].bindframe:SetFrameLevel(v[1].bar:GetFrameLevel()+4)

			v[1].editmode = true
		end

		if (not off) then

			for k,v in pairs(M.BarIndex) do
				v.updateBarHidden(v, true)
				v.updateBarTarget(v, true)
			end

			for k,v in pairs(M.ShowGrids) do
				v(nil, nil, true)
			end
		end
	end
end

function M.BindFrame_OnLoad(self)

	self:EnableMouseWheel(true)
	self:RegisterForClicks("AnyUp")
	self:RegisterForClicks("AnyDown")
	self:Hide()
	self:SetFrameLevel(6)
	self.action = "action"

	self.select:SetPoint("TOPLEFT", self:GetParent(), "TOPLEFT")
	self.select:SetPoint("BOTTOMRIGHT", self:GetParent(), "BOTTOMRIGHT")

end

function M.BindFrame_OnClick(self, action, down, button)

	if (action == "LeftButton") then

		if (self.bindType == "spell") then



		elseif (self.bindType == "macro") then



		elseif (self.bindType == "button") then

			if (button.config.hotKeyLock) then
				button.config.hotKeyLock = false
			else
				button.config.hotKeyLock = true
			end
		end

		M.BindFrame_OnShow(self, button)

		return
	end

	if (action == "RightButton") then

		if (self.bindType == "spell") then



		elseif (self.bindType == "macro") then



		elseif (self.bindType == "button") then

			if (button.config.hotKeyPri) then
				button.config.hotKeyPri = false
			else
				button.config.hotKeyPri = true
			end

			M.ApplyBindings(button)
		end

		M.BindFrame_OnShow(self, button)

		return
	end

	local modifier, key = getModifier()

	if (action == "MiddleButton") then
		key = "Button3"
	else
		key = action
	end

	if (modifier) then
		key = modifier..key
	end

	M.ProcessBinding(self, key, button)

end

function M.BindFrame_OnShow(self, button)

	if (self.bindType == "spell") then



	elseif (self.bindType == "macro") then



	elseif (self.bindType == "button") then

		local priority = ""

		if (button.config.hotKeyPri) then
			priority = "|cff00ff00"..M.Strings.BINDFRAME_PRIORITY.."|r\n"
		end

		if (button.config.hotKeyLock) then
			self.type:SetText(priority.."|cfff00000"..M.Strings.BINDFRAME_LOCKED.."|r")
		else
			self.type:SetText(priority.."|cffffffff"..M.Strings.BINDFRAME_BIND.."|r")
		end
	end
end

function M.BindFrame_OnMouseWheel(self, delta, button)

	local modifier, key, action = getModifier()

	if (delta > 0) then
		key = "MOUSEWHEELUP"
		action = "MousewheelUp"
	else
		key = "MOUSEWHEELDOWN"
		action = "MousewheelDown"
	end

	if (modifier) then
		key = modifier..key
	end

	M.ProcessBinding(self, key, button)

end

function M.BindFrame_OnKeyDown(self, key, button)

	if (find(key,"ALT") or find(key,"SHIFT") or find(key,"CTRL") or find(key, "PRINTSCREEN")) then
		return
	end

	local modifier = getModifier()

	if (modifier) then
		key = modifier..key
	end

	M.ProcessBinding(self, key, button)
end

function M.BindFrame_OnEnter(self, button)

	self.select:Show()
	setBindframeTooltip(self, button)
end

function M.BindFrame_OnLeave(self, button)

	self.select:Hide()
	self.UpdateTooltip = nil
	GameTooltip:Hide()
end

function M.BindFrame_OnUpdate(self, elapsed)

	if (self:IsMouseOver()) then
		self:EnableKeyboard(true)
	else
		self:EnableKeyboard(false)
	end
end

function M.ProcessBinding(self, key, button)

	if (self[self.bindType]) then

		if (not self.bindTable[self[self.bindType]]) then
			self.bindTable[self[self.bindType]] = { hotKeys = ":", hotKeyText = ":", hotKeyLock = false }
		end

		button = { config = self.bindTable[self[self.bindType]] }
	end

	if (button and button.config and button.config.hotKeyLock) then
		MacaroonMessageFrame:AddMessage(M.Strings.BINDINGS_LOCKED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
		return
	end

	if (key == "ESCAPE") then

		if (self.bindType == "spell") then

			M.ClearSpellBinding(self[self.bindType])

		elseif (self.bindType == "macro") then

			M.ClearMacroBinding(self[self.bindType])

		elseif (self.bindType == "button") then

			local found

			for index,btn in pairs(M.Buttons) do

				if (button ~= btn[1] and not btn[1].config.hotKeyLock) then

					found = false

					if (btn[1]:GetAttribute("showstates")) then

						for showstate in gmatch(btn[1]:GetAttribute("showstates"), "[^;]+") do

							if (find(button:GetAttribute("showstates"), showstate)) then

								found = true
							end
						end

						if (not found and button.config.barPos == btn[1].config.barPos) then
							M.ClearBindings(btn[1])
						end
					end
				end
			end

			M.ClearBindings(button)
		end

	elseif (key) then

		for index,btn in pairs(M.Buttons) do

			if (button ~= btn[1] and not btn[1].config.hotKeyLock) then

				if (button.bar ~= btn[1].bar) then

					gsub(btn[1].config.hotKeys, "[^:]+", function(binding)

						if (key == binding) then

							M.ClearBindings(btn[1], binding)
							M.ApplyBindings(btn[1])
						end

					end)

				else
					for showstate in gmatch(btn[1]:GetAttribute("showstates"), "[^;]+") do

						if (find(button:GetAttribute("showstates"), showstate)) then

							gsub(btn[1].config.hotKeys, "[^:]+", function(binding)

								if (key == binding) then

									M.ClearBindings(btn[1], binding)
									M.ApplyBindings(btn[1])
								end
							end)
						else
							if (button.config.barPos == btn[1].config.barPos) then
								M.SetBinding(btn[1], key)
							end
						end
					end
				end
			end
		end

		if (MacaroonBoundSavedState) then

			for k,v in pairs(MacaroonBoundSavedState.spells) do

				gsub(v.hotKeys, "[^:]+", function(binding)
					if (key == binding) then
						M.ClearSpellBinding(k, binding)
					end
				end)
			end

			for k,v in pairs(MacaroonBoundSavedState.macros) do

				gsub(v.hotKeys, "[^:]+", function(binding)
					if (key == binding) then
						M.ClearMacroBinding(k, binding)
					end
				end)
			end
		end

		if (self.bindType == "spell") then

			M.SetSpellBinding(self[self.bindType], key)

		elseif (self.bindType == "macro") then

			M.SetMacroBinding(self[self.bindType], key)

		elseif (self.bindType == "button") then

			M.SetBinding(button, key)
		end
	end

	if (self:IsVisible()) then
		setBindframeTooltip(self, button)
	end
end

function M.SetBinding(button, key)

	local found = false

	gsub(button.config.hotKeys, "[^:]+", function(binding) if(binding == key) then found = true end end)

	if (not found) then

		local keytext = M.GetKeyText(key)

		button.config.hotKeys = button.config.hotKeys..key..":"
		button.config.hotKeyText = button.config.hotKeyText..keytext..":"
	end

	M.ApplyBindings(button)
end

function M.SetSpellBinding(spell, key)

	local bound, found = MacaroonBoundSavedState.spells[spell]

	if (bound) then
		gsub(bound.hotKeys, "[^:]+", function(binding) if(binding == key) then found = true end end)
	end

	if (not found and bound) then

		local keytext = M.GetKeyText(key)

		bound.hotKeys = bound.hotKeys..key..":"
		bound.hotKeyText = bound.hotKeyText..keytext..":"
	end

	M.ApplySpellBindings(spell)
end

function M.SetMacroBinding(macro, key)

	local bound, found = MacaroonBoundSavedState.macros[macro]

	if (bound) then
		gsub(bound.hotKeys, "[^:]+", function(binding) if(binding == key) then found = true end end)
	end

	if (not found and bound) then

		local keytext = M.GetKeyText(key)

		bound.hotKeys = bound.hotKeys..key..":"
		bound.hotKeyText = bound.hotKeyText..keytext..":"
	end

	M.ApplyMacroBindings(macro)
end

function M.ClearBindings(button, key)

	if (key) then

		SetOverrideBinding(button, true, key, nil)

		local newkey = gsub(key, "%-", "%%-")

		button.config.hotKeys = gsub(button.config.hotKeys, newkey..":", "")

		local keytext = M.GetKeyText(key)

		button.config.hotKeyText = gsub(button.config.hotKeyText, keytext..":", "")

	else
		local bindkey = "CLICK "..button:GetName()..":LeftButton"

		while (GetBindingKey(bindkey)) do

			SetBinding(GetBindingKey(bindkey), nil)

		end

		ClearOverrideBindings(button)

		button.config.hotKeys = ":"

		button.config.hotKeyText = ":"
	end

	M.ApplyBindings(button)
end

function M.ClearSpellBinding(spell, key)

	local bound = MacaroonBoundSavedState.spells[spell]

	if (key and bound) then

		SetOverrideBinding(MacaroonSpellBinder, true, key, nil)

		local newkey = gsub(key, "%-", "%%-")

		bound.hotKeys = gsub(bound.hotKeys, newkey..":", "")

		local keytext = M.GetKeyText(key)

		bound.hotKeyText = gsub(bound.hotKeyText, keytext..":", "")

	elseif (bound) then

		local bindkey = "SPELL "..spell

		while (GetBindingKey(bindkey)) do

			SetBinding(GetBindingKey(bindkey), nil)

		end

		gsub(bound.hotKeys, "[^:]+", function(key) SetOverrideBinding(MacaroonSpellBinder, true, key, nil) end)

		bound.hotKeys = ":"

		bound.hotKeyText = ":"
	end

	M.ApplySpellBindings(spell)
end

function M.ClearMacroBinding(macro, key)

	local bound = MacaroonBoundSavedState.macros[macro]

	if (key and bound) then

		SetOverrideBinding(MacaroonMacroBinder, true, key, nil)

		local newkey = gsub(key, "%-", "%%-")

		bound.hotKeys = gsub(bound.hotKeys, newkey..":", "")

		local keytext = M.GetKeyText(key)

		bound.hotKeyText = gsub(bound.hotKeyText, keytext..":", "")

	elseif (bound) then

		local bindkey = "MACRO "..macro

		while (GetBindingKey(bindkey)) do

			SetBinding(GetBindingKey(bindkey), nil)

		end

		gsub(bound.hotKeys, "[^:]+", function(key) SetOverrideBinding(MacaroonMacroBinder, true, key, nil) end)

		bound.hotKeys = ":"

		bound.hotKeyText = ":"
	end

	M.ApplyMacroBindings(macro)
end

function M.ApplyBindings(button)

	button:SetAttribute("hotkeypri", button.config.hotKeyPri)

	if (button:IsShown() or button.config.stored) then
		gsub(button.config.hotKeys, "[^:]+", function(key) SetOverrideBindingClick(button, button.config.hotKeyPri, key, button:GetName()) end)
	end

	button:SetAttribute("hotkeys", button.config.hotKeys)

	button.hotkey:SetText(match(button.config.hotKeyText, "^:([^:]+)") or "")

	if (button.config.bindText) then
		button.hotkey:Show()
	else
		button.hotkey:Hide()
	end

	if (GetCurrentBindingSet() > 0 and GetCurrentBindingSet() < 3) then SaveBindings(GetCurrentBindingSet()) end
end

function M.ApplySpellBindings(spell)

	local bound = MacaroonBoundSavedState.spells[spell]

	if (bound) then
		gsub(bound.hotKeys, "[^:]+", function(key) SetOverrideBindingSpell(MacaroonSpellBinder, false, key, spell) end)
	end

	M.SpellBinder_OnEvent(nil, "UPDATE_BINDINGS")

	if (GetCurrentBindingSet() > 0 and GetCurrentBindingSet() < 3) then SaveBindings(GetCurrentBindingSet()) end
end

function M.ApplyMacroBindings(macro)

	local bound = MacaroonBoundSavedState.macros[macro]

	if (bound) then
		gsub(bound.hotKeys, "[^:]+", function(key) SetOverrideBindingMacro(MacaroonMacroBinder, false, key, macro) end)
	end

	M.MacroBinder_OnEvent()

	if (GetCurrentBindingSet() > 0 and GetCurrentBindingSet() < 3) then SaveBindings(GetCurrentBindingSet()) end
end


function M.GetKeyText(key)

	local keytext

	if (find(key, "Button")) then

		keytext = gsub(key,"([Bb][Uu][Tt][Tt][Oo][Nn])(%d+)","m%2")

	elseif (find(key, "NUMPAD")) then

		keytext = gsub(key,"NUMPAD","n")
		keytext = gsub(keytext,"DIVIDE","/")
		keytext = gsub(keytext,"MULTIPLY","*")
		keytext = gsub(keytext,"MINUS","-")
		keytext = gsub(keytext,"PLUS","+")
		keytext = gsub(keytext,"DECIMAL",".")

	elseif (find(key, "MOUSEWHEEL")) then

		keytext = gsub(key,"MOUSEWHEEL","mw")
		keytext = gsub(keytext,"UP","U")
		keytext = gsub(keytext,"DOWN","D")
	else
		keytext = key
	end

	keytext = gsub(keytext,"ALT%-","a")
	keytext = gsub(keytext,"CTRL%-","c")
	keytext = gsub(keytext,"SHIFT%-","s")
	keytext = gsub(keytext,"INSERT","Ins")
	keytext = gsub(keytext,"DELETE","Del")
	keytext = gsub(keytext,"HOME","Home")
	keytext = gsub(keytext,"END","End")
	keytext = gsub(keytext,"PAGEUP","PgUp")
	keytext = gsub(keytext,"PAGEDOWN","PgDn")
	keytext = gsub(keytext,"BACKSPACE","Bksp")


	return keytext
end

local function controlOnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ... == "Macaroon") then

		SD = MacaroonSavedState

	elseif (event == "ACTIONBAR_SHOWGRID") then

		if (bindMode) then
			for k,v in pairs(M.Buttons) do
				if (v[1].bindframe:IsVisible()) then
					v[1].editmode = nil
					v[1].bindframe.showgrid = true
					v[1].bindframe:Hide()
				end
			end
		end

	elseif (event == "ACTIONBAR_HIDEGRID") then

		if (bindMode) then
			for k,v in pairs(M.Buttons) do
				if (v[1].bindframe.showgrid) then
					v[1].bindframe:Show()
					v[1].bindframe.showgrid = nil
					v[1].editmode = true
				end
			end
		end
	end
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", controlOnEvent)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("ACTIONBAR_SHOWGRID")
frame:RegisterEvent("ACTIONBAR_HIDEGRID")
