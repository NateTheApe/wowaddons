--MacaroonBound, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

local M = Macaroon

MacaroonBoundSavedState = {}

local spellBind, macroBind, SD, pew = false, false

local match = string.match

local CopyTable = M.CopyTable
local ClearTable = M.ClearTable

local function UpdateSpellBindFrames()

	if (SpellBookFrame:IsVisible()) then

		if (SpellBookFrame.bookType == BOOKTYPE_PROFESSION) then
			return
		end

		local spellBtn, hotkey, icon, texture, bindFrame, bound, spellid, slotType, spell, subName, spellLvl, isPassive

		for i=1,12 do

			spellBtn = _G["SpellButton"..i]
			hotkey = _G["SpellButton"..i.."HotKey"]
			icon = _G["SpellButton"..i.."IconTexture"]

			hasTexture = icon:GetTexture()
			hotkey:SetText()

			bindFrame = _G["MacaroonSpellBinder"..i]
			bindFrame.spell = nil
			bindFrame.bindTable = SD.spells

			spellid, slotType = SpellBook_GetSpellBookSlot(spellBtn)

			if (spellid) then
				spell, subName = GetSpellBookItemName(spellid, SpellBookFrame.bookType)
				spellLvl = GetSpellAvailableLevel(spellid, SpellBookFrame.bookType)
				texture = GetSpellBookItemTexture(spellid, SpellBookFrame.bookType)
				isPassive = IsPassiveSpell(spellid, SpellBookFrame.bookType)
			end

			if (spell and not isPassive and spellLvl <= UnitLevel("player") and slotType and slotType ~= "FUTURESPELL") then

				if (subName and #subName > 0) then
					spell = spell.."("..subName..")"
				else
					spell = spell
				end

				bindFrame.spell = spell

				if (SD.spells) then
					bound = SD.spells[spell]
				end

				if (bound) then
					hotkey:SetText(match(bound.hotKeyText, "^:([^:]+)") or "")
				end

				if (spellBind) then
					bindFrame:Show(); icon:SetVertexColor(0.2, 0.2, 0.2)
				end

			else
				bindFrame:Hide(); icon:SetVertexColor(1, 1, 1)
			end
		end
	end
end

function M.SpellBinder_OnLoad(self)

	local bindFrame

	self:RegisterEvent("SPELLS_CHANGED")
	self:RegisterEvent("UPDATE_BINDINGS"				)
	self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	self:RegisterEvent("CRAFT_SHOW")
	self:RegisterEvent("CRAFT_CLOSE")
	self:RegisterEvent("TRADE_SKILL_SHOW")
	self:RegisterEvent("TRADE_SKILL_CLOSE")
	self:RegisterEvent("PET_BAR_UPDATE")

	--hooksecurefunc("SpellBookFrame_UpdatePages", UpdateSpellBindFrames)
	hooksecurefunc("SpellBookFrame_UpdateSpells", UpdateSpellBindFrames)

	for i=1,12 do

		bindFrame = CreateFrame("Button", "MacaroonSpellBinder"..i, _G["SpellButton"..i], "MacaroonBindFrameTemplate")
		bindFrame.bindType = "spell"

		bindFrame:SetID(i)
		bindFrame:SetPoint("TOPLEFT", _G["SpellButton"..i], "TOPLEFT", 0 ,0)
		bindFrame:SetPoint("BOTTOMRIGHT", _G["SpellButton"..i], "BOTTOMRIGHT", 0 ,0)
		bindFrame:SetFrameLevel(_G["SpellButton"..i]:GetFrameLevel()+1)

		_G["SpellButton"..i]:CreateFontString("$parentHotKey", "ARTWORK", "NumberFontNormalSmall")
		_G["SpellButton"..i.."HotKey"]:SetPoint("TOPRIGHT", -1, -5)
	end
end

function M.SpellBinder_OnEvent(self, event, ...)

	if ( event == "SPELLS_CHANGED" or "UPDATE_BINDINGS") then
		UpdateSpellBindFrames()
	end
end

function M.SpellBinder_OnClick(self, button, silent)

	if (spellBind) then

		spellBind = false
		self:SetButtonState("NORMAL")

		if (not silent) then PlaySound("igMainMenuOptionCheckBoxOff") end

		for i=1,12 do
			_G["MacaroonSpellBinder"..i]:Hide()
			_G["SpellButton"..i.."IconTexture"]:SetVertexColor(1, 1, 1)
		end
	else
		spellBind = true
		self:SetButtonState("PUSHED", 1)

		if (not silent) then PlaySound("igMainMenuOptionCheckBoxOn") end

		UpdateSpellBindFrames()

	end
end

function M.SpellBinder_OnShow(self)

end

function M.SpellBinder_OnHide(self)
	spellBind = true
	M.SpellBinder_OnClick(self, nil, true)
end

local function macroBinder_Update()

	if (MacroFrame and not InCombatLockdown()) then

		local name, body, hotkey, bindFrame, bound

		for i=1,36 do

			hotkey = _G["MacroButton"..i.."HotKey"]
			bindFrame = _G["MacaroonMacroBinder"..i]
			bindFrame.macro = nil
			bindFrame.bindTable = SD.macros

			if (hotkey) then

				hotkey:SetText()

				macro, _, body, _ = GetMacroInfo(MacroFrame.macroBase + i)

				bindFrame.macro = macro

				if (SD.macros) then
					bound = SD.macros[macro]
				end

				if (bound) then
					hotkey:SetText(match(bound.hotKeyText, "^:([^:]+)") or "")
				end
			end
		end
	end
end

local function macroBinderAddonLoaded(addon)

	if (addon == "Blizzard_MacroUI" and not InCombatLockdown()) then

		hooksecurefunc("MacroFrame_Show", macroBinder_Update)
		hooksecurefunc("MacroFrame_Update", macroBinder_Update)

		local bindFrame

		MacaroonMacroBinderKeyBind:SetParent("MacroFrame")
		MacaroonMacroBinderKeyBind:SetPoint("TOPLEFT", "MacroFrame", "TOPLEFT", 98, -31)
		MacaroonMacroBinderKeyBind:Show()

		for i=1,36 do

			bindFrame = _G["MacaroonMacroBinder"..i]
			bindFrame:SetID(i)
			bindFrame:SetParent("MacroButton"..i)
			bindFrame:SetPoint("TOPLEFT", _G["MacroButton"..i], "TOPLEFT", 0 ,0)
			bindFrame:SetPoint("BOTTOMRIGHT", _G["MacroButton"..i], "BOTTOMRIGHT", 0 ,0)
			bindFrame:SetFrameLevel(_G["MacroButton"..i]:GetFrameLevel()+1)

			_G["MacroButton"..i]:CreateFontString("$parentHotKey", "ARTWORK", "NumberFontNormalSmall")
			_G["MacroButton"..i.."HotKey"]:SetPoint("TOPRIGHT", -1, -5)
		end
	end

end

function M.MacroBinder_OnLoad(self)

	local bindFrame

	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("UPDATE_BINDINGS")

	for i=1,36 do
		bindFrame = CreateFrame("Button", "MacaroonMacroBinder"..i, self, "MacaroonBindFrameTemplate")
		bindFrame.bindType = "macro"
		bindFrame:Hide()
	end
end

function M.MacroBinder_OnEvent(self, event, ...)

	if (event == "ADDON_LOADED") then
		macroBinderAddonLoaded(...)
	end

	macroBinder_Update()
end

function M.MacroBinder_OnClick(self, button, silent)

	if (macroBind) then

		macroBind = false
		self:SetButtonState("NORMAL")

		if (not silent) then PlaySound("igMainMenuOptionCheckBoxOff") end

		for i=1,36 do
			_G["MacaroonMacroBinder"..i]:Hide()
		end
	else
		macroBind = true
		self:SetButtonState("PUSHED", 1)

		if (not silent) then PlaySound("igMainMenuOptionCheckBoxOn") end

		for i=1,36 do
			_G["MacaroonMacroBinder"..i]:Show()
		end
	end
end

function M.MacroBinder_OnShow(self)

end

function M.MacroBinder_OnHide(self)
	macroBind = true;	M.MacroBinder_OnClick(self, nil, true)
end

function M.BoundLoadSavedData(saved)

	if (saved) then

		local savedState = CopyTable(saved)

		if (savedState.spells) then

			for spell,_ in pairs(savedState.spells) do
				M.ApplySpellBindings(spell)
			end
		end

		if (savedState.macros) then

			for macro,_ in pairs(savedState.macros) do
				M.ApplyMacroBindings(macro)
			end
		end
	end
end

function M.BoundSaveCurrentState()

	return SD, nil, "spells;macros"
end

function M.BoundUpdateElements()

	--empty func
end

function M.BoundSetSaved()

	SD = MacaroonBoundSavedState

	return SD
end

local function controlOnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ... == "MacaroonBound") then

		M.BoundSetSaved()

		if (not SD.spells) then
			SD.spells = {}
		end

		if (not SD.macros) then
			SD.macros = {}
		end

		M.StatesToSave.bound = M.BoundSaveCurrentState
		M.SavedDataLoad.bound = M.BoundLoadSavedData
		M.SavedDataUpdate.bound = M.BoundUpdateElements
		M.SetSavedVars.bound = M.BoundSetSaved

		M.BoundLoadSavedData(SD)

	elseif (event == "PLAYER_ENTERING_WORLD" and not pew) then

		pew = true
	end
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", controlOnEvent)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
