-- TrinketBar v0.52
-- Written by Killakhan
-- A simple trinket addon to help swapping and monitoring trinkets
-- http://www.wowinterface.com/downloads/author-259436.html

local _, L = ...
local TrinketBar = {}
local addon = TrinketBar
local addonName = "K_TB"
local version = "0.52"
addon.idx = 0

addon.topQueue = nil
addon.bottomQueue = nil
local defaults = {
	locked = false,
	scale = 1,
	orientation = "HORIZONTAL",
	x = -5,
	y = 130,
	hidden = false,
	docking = "right",
	menuScale = 1,
	combatQueue = true,
	wrapRows = 3,
	modifier = "ALT",
	showTooltip = true,
}
local modifierDB = {
	"ALT", 
	"CTRL", 
	"SHIFT", 
	"None", 
}

addon.f = CreateFrame("Frame", "K_TB_MAIN", UIParent)
addon.f:SetScript("OnEvent", function(self, event, ...) 
      if addon[event] then 
         return addon[event](addon, event, ...) 
      end 
end)

-- bindings
BINDING_HEADER_TRINKETBAR = L["TrinketBar"]
_G["BINDING_NAME_CLICK K_TB_TopTrinket:LeftButton"] = L["Top Trinket"]
_G["BINDING_NAME_CLICK K_TB_BottomTrinket:LeftButton"] = L["Bottom Trinket"]

-- register events
addon.f:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
addon.f:RegisterEvent("PLAYER_LOGIN")
addon.f:RegisterEvent("UNIT_INVENTORY_CHANGED")
addon.f:RegisterEvent("ADDON_LOADED")
addon.f:RegisterEvent("MODIFIER_STATE_CHANGED")

-- event functions
function addon:PLAYER_UNGHOST(event)
	if addon.db.combatQueue then
		addon.ChangeTrinkets()
	end
end

function addon:PLAYER_REGEN_ENABLED(event)
	if addon.db.combatQueue and not UnitIsDead("player") then
		addon.ChangeTrinkets()
	end
end

function addon:MODIFIER_STATE_CHANGED(event, key, state)
	if not addon.GetModifier(key) then return end
	-- print("modifier: " .. key, state)
	if (addon.topTrinket:IsMouseOver() or addon.bottomTrinket:IsMouseOver()) and state == 1 then
		addon.Button_OnEnter()
	elseif state == 0 then
		addon.Button_OnLeave()
	end

end

function addon:ADDON_LOADED(event, addon)
	-- print(addon)
	if addon == "TrinketBar" then
		self.InitDB()
		self.CreateConfig()
		self.InitSettings()
		self.UpdateCD()
	end
	self.f:UnregisterEvent("ADDON_LOADED")
end
	
function addon:ACTIONBAR_UPDATE_COOLDOWN(event, ...)
	self.UpdateCD()
end

function addon:PLAYER_LOGIN(event, ...)
	_G[self.topTrinket:GetName().."Icon"]:SetTexture(GetInventoryItemTexture("player", 13))
	_G[self.bottomTrinket:GetName().."Icon"]:SetTexture(GetInventoryItemTexture("player", 14))
	self.UpdateCD()
	self.f:UnregisterEvent("PLAYER_LOGIN")
end

function addon:UNIT_INVENTORY_CHANGED(event, unit)
	if not unit == "player" then return end
	_G[self.topTrinket:GetName().."Icon"]:SetTexture(GetInventoryItemTexture("player", 13))
	_G[self.bottomTrinket:GetName().."Icon"]:SetTexture(GetInventoryItemTexture("player", 14))
	self.UpdateCD()
end

-- other functions
function addon.GetModifier(key)
	local modifier
	if key == "LALT" or key == "RALT" then
		modifier = "ALT"
	elseif key == "LCTRL" or key == "RCTRL" then
		modifier = "CTRL"
	elseif key == "LSHIFT" or key == "RSHIFT" then
		modifier = "SHIFT"
	else
		return false
	end
	
	if addon.db.modifier == modifier then
		return true
	else
		return false
	end
end

function addon.ChangeTrinkets()
	if addon.topQueue == addon.bottomQueue then
		addon.bottomQueue = nil
	end
	if addon.topQueue then
		-- print("changing top trinket")
		EquipItemByName(addon.topQueue, 13)
		addon.topTrinket.queueIcon:Hide()
		addon.topQueue = nil
	end
	if addon.bottomQueue then
		-- print("changing bottom trinket")
		EquipItemByName(addon.bottomQueue, 14)
		addon.bottomTrinket.queueIcon:Hide()
		addon.bottomQueue = nil
	end
end

function addon.Button_OnEnter()
   addon.idx = 0
   for bag = 0, 4 do
      for slot = 1, GetContainerNumSlots(bag) do
         local item = GetContainerItemLink(bag, slot)
         if item and select(9, GetItemInfo(item)) == "INVTYPE_TRINKET" then
            addon.idx = addon.idx + 1
            --print(idx, item .. select(10, GetItemInfo(item)))
            addon.CreatePopupButton(addon.idx, item, bag, slot)
         end
      end
   end
end

function addon.Button_OnLeave()
   -- print("hiding")
   for i = 1, addon.idx do
      local button = _G["TrinketBarPopupButton"..i]
      if button then
         button:Hide()
      end
   end
end

function addon.CreatePopupButton(idx, itemID, bag, slot)
	local buttonName = "TrinketBarPopupButton"..idx
	local button = _G[buttonName]
	if not button then
		button = CreateFrame("Button", buttonName, UIParent, "ActionButtonTemplate")
		button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		button:SetScript("OnClick",function(self, button, down) 
			if InCombatLockdown() then 
				if addon.db.combatQueue then
					local texture = select(10, GetItemInfo(self.ID))
					if button == "LeftButton" then
						addon.topTrinket.queueIcon:Show()
						addon.topTrinket.queueIcon:SetTexture(texture)
						addon.topQueue = self.ID
					elseif button == "RightButton" then
						addon.bottomTrinket.queueIcon:Show()
						addon.bottomTrinket.queueIcon:SetTexture(texture)
						addon.bottomQueue = self.ID
					end
					
				end
				-- print("|c00FFFFAATrinketBar: |rCannot change trinkets while in Combat")
			else
				if button == "LeftButton" then
					EquipItemByName(self.ID, 13)
				elseif button == "RightButton" then
					EquipItemByName(self.ID, 14)
				end
			end
			addon.Button_OnLeave()
		end)
		button:SetScript("OnEnter", function(self)
			GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
			GameTooltip:SetBagItem(button.bag, button.slot)
			if addon.db.showTooltip then 
				GameTooltip:Show()
			else
				GameTooltip:Hide()
			end
			if addon.db.modifier == "None" then
				addon.Button_OnEnter()
			end
		end)
		button:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
			if addon.db.modifier == "None" then
				addon.Button_OnLeave()
			end
		end)
		-- print("created: " .. button:GetName())
	end
	CooldownFrame_SetTimer(_G[buttonName.."Cooldown"], GetContainerItemCooldown(bag, slot))
	_G[buttonName.."Icon"]:SetTexture(select(10, GetItemInfo(itemID)))
	button:SetFrameStrata("DIALOG")
	button.bag = bag
	button.slot = slot
	button.ID = itemID
	button:ClearAllPoints()
	button:SetScale(addon.db.menuScale)
	button:Show()
	addon.DockMenu(idx, button)
end	

function addon.DockMenu(idx, button)
	local rows = addon.db.wrapRows
	local point, relPoint, pointB, relPointB, parent
	local frame = addon.topTrinket

	local width = GetScreenWidth()/2
	local height = GetScreenHeight()/2
	
	local topLeft = frame:GetLeft() < width and frame:GetBottom() > height
	local topRight = frame:GetLeft() > width and frame:GetBottom() > height
	local bottomLeft = frame:GetLeft() < width and frame:GetBottom() < height
	local bottomRight = frame:GetLeft() > width and frame:GetBottom() < height
	
	if topLeft then 
		if addon.db.orientation == "HORIZONTAL" then
			parent = addon.topTrinket
			point = "TOP"; relPoint = "BOTTOM"; pointB = "TOPLEFT"; relPointB = "TOPRIGHT"
		else
			parent = addon.bottomTrinket
			point = "TOP"; relPoint = "BOTTOM"; pointB = "TOPLEFT"; relPointB = "TOPRIGHT"
		end
	elseif topRight then
		parent = addon.bottomTrinket
		point = "TOP"; relPoint = "BOTTOM"; pointB = "TOPRIGHT"; relPointB = "TOPLEFT"
	elseif bottomLeft then
		parent = addon.topTrinket
		point = "BOTTOM"; relPoint = "TOP"; pointB = "BOTTOMLEFT"; relPointB = "BOTTOMRIGHT"
	elseif bottomRight then
		if addon.db.orientation == "HORIZONTAL" then
			parent = addon.bottomTrinket
			point = "BOTTOM"; relPoint = "TOP"; pointB = "BOTTOMRIGHT"; relPointB = "BOTTOMLEFT"
		else
			parent = addon.topTrinket
			point = "BOTTOM"; relPoint = "TOP"; pointB = "BOTTOMRIGHT"; relPointB = "BOTTOMLEFT"
		end
	else
		parent = addon.topTrinket
		point = "BOTTOM"; relPoint = "TOP"; pointB = "BOTTOMLEFT"; relPointB = "BOTTOMRIGHT"
	end
	
	if idx == 1 then
		button:SetPoint(point, parent, relPoint, 0, 0)
	elseif idx%rows == 1 then -- thanks to contrebasse
		button:SetPoint(pointB, _G["TrinketBarPopupButton"..(idx - rows)], relPointB)   
	else
		button:SetPoint(point, _G["TrinketBarPopupButton"..(idx - 1)], relPoint)   
	end
end

function addon.InitDB()
	if not TrinketBarDB then
		TrinketBarDB = {}
	end
	addon.db = addon.CopyDefaults(defaults, TrinketBarDB)
end

function addon.CopyDefaults(src, dst)
	if not src then return { } end
	if not dst then dst = { } end
	for k, v in pairs(src) do
		if type(v) == "table" then
			dst[k] = addon.CopyDefaults(v, dst[k])
		elseif type(v) ~= type(dst[k]) then
			dst[k] = v
		end
	end
	return dst
end

function addon.InitSettings()
	-- print("loaded " .. addon.db.x, addon.db.y)
	addon.anchor:ClearAllPoints()
	addon.anchor:SetPoint("BOTTOM", UIParent, "BOTTOM", addon.db.x, addon.db.y)
	addon.SetOrientation(addon.db.orientation)
	addon.SetScale(addon.db.scale)
	addon.checkbox1:SetChecked(addon.db.locked)
	addon.checkbox2:SetChecked(addon.GetCheckedOrientation("HORIZONTAL"))
	addon.checkbox3:SetChecked(addon.GetCheckedOrientation("VERTICAL"))
	addon.checkbox4:SetChecked(addon.db.hidden)
	addon.checkbox5:SetChecked(addon.db.combatQueue)
	addon.slider1:SetValue(addon.db.scale)
	addon.checkbox6:SetChecked(addon.db.showTooltip)
	
	if addon.db.combatQueue then
		addon.f:RegisterEvent("PLAYER_REGEN_ENABLED")
		addon.f:RegisterEvent("PLAYER_UNGHOST")
	end
	
	if addon.db.hidden then
		addon.HideAll()
	else	
		addon.ShowAll()
	end
	if addon.db.locked or addon.db.hidden then
		addon.anchor:Hide()
	else
		addon.anchor:Show()
	end
	UIDropDownMenu_SetText(addon.dropdown1, addon.db.modifier)
end

function addon.SetScale(value)
	addon.topTrinket:SetScale(value)
	addon.bottomTrinket:SetScale(value)
end

function addon.SetMenuScale(value)
	for i = 1, addon.idx do
		local buttonName = _G["TrinketBarPopupButton"..i]
		if buttonName then
			buttonName:SetScale(value)
		end
	end
end

function addon.SetOrientation(orintation)
	if orintation == "HORIZONTAL" then
		addon.bottomTrinket:ClearAllPoints()
		addon.bottomTrinket:SetPoint("LEFT", addon.topTrinket, "RIGHT", 5, 0)
		-- print(addon.bottomTrinket:GetPoint())
	else
		addon.bottomTrinket:ClearAllPoints()
		addon.bottomTrinket:SetPoint("TOPLEFT", addon.topTrinket, "BOTTOMLEFT", 0, -5)
		-- print(addon.bottomTrinket:GetPoint())
	end
end

function addon.GetCheckedOrientation(orintation)
	if orintation == addon.db.orientation then
		return true
	else
		return false
	end
end

function addon.UpdateCD()
   CooldownFrame_SetTimer(_G[addon.topTrinket:GetName().."Cooldown"], GetInventoryItemCooldown("player", 13))
   CooldownFrame_SetTimer(_G[addon.bottomTrinket:GetName().."Cooldown"], GetInventoryItemCooldown("player", 14))
end

function addon.ShowToolTip(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
	GameTooltip:SetInventoryItem("player", self:GetID())
	if addon.db.showTooltip then
		GameTooltip:Show()	
	else
		GameTooltip:Hide()	
	end
end

function addon.HideAll()
	-- print("hide all")
	addon.anchor:Hide()
	addon.topTrinket:Hide()
	addon.bottomTrinket:Hide()
	addon.f:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	addon.f:UnregisterEvent("PLAYER_LOGIN")
	addon.f:UnregisterEvent("UNIT_INVENTORY_CHANGED")
	addon.f:UnregisterEvent("MODIFIER_STATE_CHANGED")
end

function addon.ShowAll()
	-- print("show all")
	_G[addon.topTrinket:GetName().."Icon"]:SetTexture(GetInventoryItemTexture("player", 13))
	_G[addon.bottomTrinket:GetName().."Icon"]:SetTexture(GetInventoryItemTexture("player", 14))
	addon.UpdateCD()
	addon.topTrinket:Show()
	addon.bottomTrinket:Show()
	addon.f:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	addon.f:RegisterEvent("UNIT_INVENTORY_CHANGED")
	addon.f:RegisterEvent("MODIFIER_STATE_CHANGED")
	if not addon.db.locked then
		addon.anchor:Show()
	end
end


-- frames
addon.anchor = CreateFrame("Frame", addonName.."anchor", UIParent)
addon.anchor:SetPoint("BOTTOM", UIParent, "BOTTOM")
addon.anchor:SetHeight("30")
addon.anchor:SetWidth("90")
addon.anchor:SetBackdrop( {
	bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
	edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
addon.anchor:SetBackdropColor(0, 0, 0, 1)
addon.anchor:SetBackdropBorderColor(1, 1, 1, 1)
addon.anchor:SetMovable(true)
addon.anchor:EnableMouse(true)
addon.anchor:RegisterForDrag("LeftButton")
addon.anchor:Show()
addon.anchor:SetFrameStrata("MEDIUM")
addon.anchor:SetScript("OnMouseDown", function(self, button)
	self:StartMoving() 
end)
addon.anchor:SetScript("OnMouseUp", function(self, button)
	self:StopMovingOrSizing()
	local _, _, _, x_pos, y_pos = self:GetPoint()
	TrinketBarDB.x = x_pos
	TrinketBarDB.y = y_pos
	-- print(TrinketBarDB.x)
	-- print(TrinketBarDB.y)
	-- print("top: " .. string.format("%.1f", addon.topTrinket:GetTop()-GetScreenHeight()) .. 
	-- " left: " .. string.format("%.1f", addon.topTrinket:GetLeft()) .. 
	-- " right: " .. string.format("%.1f", addon.topTrinket:GetRight()-GetScreenWidth()) .. 
	-- " bottom: " .. string.format("%.1f", addon.topTrinket:GetBottom()))

end)

addon.anchor.text = addon.anchor:CreateFontString(nil, "BORDER", "GameFontNormal")
addon.anchor.text:SetPoint("CENTER", addon.anchor, "CENTER", 0, 2)
addon.anchor.text:SetText(L["Drag me!"])
addon.anchor.text:SetTextColor(1, 1, 0, 1)

addon.topTrinket = CreateFrame("Button", addonName.."_TopTrinket", UIParent, "SecureActionButtonTemplate, ActionButtonTemplate")
addon.topTrinket:SetPoint("TOPLEFT", addon.anchor, "BOTTOMLEFT", 6, -5)
addon.topTrinket:SetScale(0.9)
addon.topTrinket:SetAttribute("type", "item")
addon.topTrinket:SetAttribute("slot", 13)
addon.topTrinket:SetID(13)
addon.topTrinket:SetFrameStrata("MEDIUM")
addon.topTrinket:SetScript("OnEnter", function(self) 
	addon.ShowToolTip(self)
	-- print(addon.db.modifier)
	if addon.db.modifier == "None" then
		addon.Button_OnEnter()
	end
end)
addon.topTrinket:SetScript("OnLeave", function(self) 
	GameTooltip:Hide() 
	if addon.db.modifier == "None" then
		addon.Button_OnLeave()
	end
end)

addon.topTrinket.queueIcon = addon.topTrinket:CreateTexture(addonName.."topQueueIcon", "ARTWORK")
addon.topTrinket.queueIcon:SetPoint("TOPRIGHT", addon.topTrinket, "TOPRIGHT", 0, 0)
addon.topTrinket.queueIcon:SetHeight(addon.topTrinket:GetHeight()/2)
addon.topTrinket.queueIcon:SetWidth(addon.topTrinket:GetWidth()/2)
addon.topTrinket.queueIcon:Hide()

addon.bottomTrinket = CreateFrame("Button", addonName.."_BottomTrinket", UIParent, "SecureActionButtonTemplate, ActionButtonTemplate")
addon.bottomTrinket:SetPoint("LEFT", addon.topTrinket, "RIGHT", 5, 0)
addon.bottomTrinket:SetScale(0.9)
addon.bottomTrinket:SetAttribute("type", "item")
addon.bottomTrinket:SetAttribute("slot", 14)
addon.bottomTrinket:SetID(14)
addon.bottomTrinket:SetFrameStrata("MEDIUM")
addon.bottomTrinket:SetScript("OnEnter", function(self) 
	addon.ShowToolTip(self)
	-- print(addon.db.modifier)
	if addon.db.modifier == "None" then
		addon.Button_OnEnter()
	end
end)
addon.bottomTrinket:SetScript("OnLeave", function(self) 
	GameTooltip:Hide() 
	if addon.db.modifier == "None" then
		addon.Button_OnLeave()
	end
end)

addon.bottomTrinket.queueIcon = addon.bottomTrinket:CreateTexture(addonName.."bottomQueueIcon", "ARTWORK")
addon.bottomTrinket.queueIcon:SetPoint("TOPRIGHT", addon.bottomTrinket, "TOPRIGHT", 0, 0)
addon.bottomTrinket.queueIcon:SetHeight(addon.bottomTrinket:GetHeight()/2)
addon.bottomTrinket.queueIcon:SetWidth(addon.bottomTrinket:GetWidth()/2)
addon.bottomTrinket.queueIcon:Hide()

-- config frames
function addon.CreateConfig()
	addon.panel = CreateFrame("Frame", addonName.."panel", UIParent)
	addon.panel.name = "TrinketBar"
	InterfaceOptions_AddCategory(addon.panel)

	addon.title = addon.panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	addon.title:SetPoint("TOPLEFT", 16, -16)
	addon.title:SetText(L["TrinketBar Config"])

	addon.subtitle = addon.panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	addon.subtitle:SetPoint("TOPLEFT", addon.title, "BOTTOMLEFT", 0, -8)
	addon.subtitle:SetNonSpaceWrap(true)
	addon.subtitle:SetText("v"..version)
	addon.subtitle:SetTextColor(1, 1, 1, 0.5)

	addon.checkbox1 = CreateFrame("CheckButton", addonName.."checkbox1", addon.panel, "ChatConfigCheckButtonTemplate")
	addon.checkbox1:SetPoint("TOPLEFT", addon.subtitle, "BOTTOMLEFT", -5, -20)
	_G[addon.checkbox1:GetName().."Text"]:SetText(L["Locked"])
	_G[addon.checkbox1:GetName().."Text"]:SetPoint("LEFT", addon.checkbox1, "RIGHT", 3, 2)
	addon.checkbox1.tooltip = L["Click to lock/unlock frames"]
	addon.checkbox1:SetChecked(addon.db.locked)
	addon.checkbox1:SetScript("OnClick", function(self, button, down)
		if addon.checkbox1:GetChecked() then
			TrinketBarDB.locked = true
			addon.anchor:Hide()
		else
			TrinketBarDB.locked = false
			addon.anchor:Show()
		end
	end)
	
	addon.checkbox4 = CreateFrame("CheckButton", addonName.."checkbox4", addon.panel, "ChatConfigCheckButtonTemplate")
	addon.checkbox4:SetPoint("TOPLEFT", addon.checkbox1, "BOTTOMLEFT", 0, -2)
	_G[addon.checkbox4:GetName().."Text"]:SetText(L["Hide Addon"])
	_G[addon.checkbox4:GetName().."Text"]:SetPoint("LEFT", addon.checkbox4, "RIGHT", 3, 2)
	addon.checkbox4.tooltip = L["Click to hide/show the main Bars"]
	addon.checkbox4:SetChecked(addon.db.hidden)
	addon.checkbox4:SetScript("OnClick", function(self, button, down)
		if addon.checkbox4:GetChecked() then
			TrinketBarDB.hidden = true
			addon.HideAll()
		else
			TrinketBarDB.hidden = false
			addon.ShowAll()
		end
	end)
	
	addon.checkbox5 = CreateFrame("CheckButton", addonName.."checkbox5", addon.panel, "ChatConfigCheckButtonTemplate")
	addon.checkbox5:SetPoint("TOPLEFT", addon.checkbox4, "BOTTOMLEFT", 0, -2)
	_G[addon.checkbox5:GetName().."Text"]:SetText(L["Trinket Queueing"])
	_G[addon.checkbox5:GetName().."Text"]:SetPoint("LEFT", addon.checkbox5, "RIGHT", 3, 2)
	addon.checkbox5.tooltip = L["Click to toggle Trinket Queueing"]
	addon.checkbox5:SetChecked(addon.db.combatQueue)
	addon.checkbox5:SetScript("OnClick", function(self, button, down)
		if addon.checkbox5:GetChecked() then
			TrinketBarDB.combatQueue = true
			addon.db.combatQueue = true
			addon.f:RegisterEvent("PLAYER_REGEN_ENABLED")
			addon.f:RegisterEvent("PLAYER_UNGHOST")
		else
			TrinketBarDB.combatQueue = false
			addon.db.combatQueue = false
			addon.topQueue = nil
			addon.bottomQueue = nil
			addon.f:UnregisterEvent("PLAYER_REGEN_ENABLED")
			addon.f:UnregisterEvent("PLAYER_UNGHOST")
		end
	end)
	
	addon.checkbox6 = CreateFrame("CheckButton", addonName.."checkbox6", addon.panel, "ChatConfigCheckButtonTemplate")
	addon.checkbox6:SetPoint("TOPLEFT", addon.checkbox5, "BOTTOMLEFT", 0, -2)
	_G[addon.checkbox6:GetName().."Text"]:SetText(L["Show Tooltip"])
	_G[addon.checkbox6:GetName().."Text"]:SetPoint("LEFT", addon.checkbox6, "RIGHT", 3, 2)
	addon.checkbox6.tooltip = L["Click to toggle tooltip display"]
	addon.checkbox6:SetChecked(addon.db.showTooltip)
	addon.checkbox6:SetScript("OnClick", function(self, button, down)
		if addon.checkbox6:GetChecked() then
			addon.db.showTooltip = true
			TrinketBarDB.showTooltip = true
		else
			addon.db.showTooltip = false
			TrinketBarDB.showTooltip = false
		end
	end)
	
	addon.checkbox2 = CreateFrame("CheckButton", addonName.."checkbox2", addon.panel, "ChatConfigCheckButtonTemplate")
	addon.checkbox2:SetPoint("TOPLEFT", addon.checkbox6, "BOTTOMLEFT", 0, -40)
	_G[addon.checkbox2:GetName().."Text"]:SetText(L["Horizontal"])
	_G[addon.checkbox2:GetName().."Text"]:SetPoint("LEFT", addon.checkbox2, "RIGHT", 3, 2)
	addon.checkbox2.tooltip = L["Click to set Horizontal orientation"]
	addon.checkbox2:SetChecked(addon.GetCheckedOrientation("HORIZONTAL"))
	addon.checkbox2:SetScript("OnClick", function(self, button, down)
		if addon.checkbox2:GetChecked() then
			TrinketBarDB.orientation = "HORIZONTAL"
			addon.checkbox3:SetChecked(false)
		else
			TrinketBarDB.orientation = "VERTICAL"
			addon.checkbox3:SetChecked(true)
		end
		addon.SetOrientation(TrinketBarDB.orientation)
	end)
	
	addon.checkbox3 = CreateFrame("CheckButton", addonName.."checkbox3", addon.panel, "ChatConfigCheckButtonTemplate")
	addon.checkbox3:SetPoint("TOPLEFT", addon.checkbox2, "BOTTOMLEFT", 0, -2)
	_G[addon.checkbox3:GetName().."Text"]:SetText(L["Vertical"])
	_G[addon.checkbox3:GetName().."Text"]:SetPoint("LEFT", addon.checkbox3, "RIGHT", 3, 2)
	addon.checkbox3.tooltip = L["Click to set Vertical orientation"]
	addon.checkbox3:SetChecked(addon.GetCheckedOrientation("VERTICAL"))
	addon.checkbox3:SetScript("OnClick", function(self, button, down)
		if addon.checkbox3:GetChecked() then
			TrinketBarDB.orientation = "VERTICAL"
			addon.checkbox2:SetChecked(false)
		else
			TrinketBarDB.orientation = "HORIZONTAL"
			addon.checkbox2:SetChecked(true)
		end
		addon.SetOrientation(TrinketBarDB.orientation)
	end)	
	
	addon.subtitle2 = addon.panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	addon.subtitle2:SetPoint("BOTTOMLEFT", addon.checkbox2, "TOPLEFT", 0, 10)
	addon.subtitle2:SetNonSpaceWrap(true)
	addon.subtitle2:SetText("|c00FFFFAA"..L["Bar Orientation:"])
	
	addon.dropdown1 = CreateFrame("Frame", addonName.."dropdown1", addon.panel, "UIDropDownMenuTemplate")
	addon.dropdown1:SetPoint("TOPLEFT", addon.checkbox3, "BOTTOMLEFT", -15, -30)
	addon.dropdown1:SetWidth(50)
	addon.dropdown1.font = addon.dropdown1:CreateFontString(addonName.."dropdownFont", "ARTWORK", "GameFontNormal")
	addon.dropdown1.font:SetPoint("BOTTOMLEFT", addon.dropdown1, "TOPLEFT", 20, 0)
	addon.dropdown1.font:SetText("|c00FFFFAA"..L["Menu Toggle Key:"])
	_G[addon.dropdown1:GetName().."Button"]:SetScript("OnClick", function(self, button, down)
		  ToggleDropDownMenu(1, nil, addon.dropdown1, self:GetName(), -100 ,0)
	end)

	local info = {}
	function addon.dropdown1.initialize(self, level)
	   if not level then return end
	   wipe(info)
	   if level == 1 then
		  addon.CreateMenu(info)
	   end
	end
	function addon.OnClickFunc(button, arg1, arg2, checked)
	   addon.db.modifier = arg1
	   TrinketBarDB.modifier = arg1
	   -- print(addon.db.modifier)
	   UIDropDownMenu_SetText(addon.dropdown1, arg1)
	end    
	function addon.CreateMenu(info)
	   for idx, value in pairs(modifierDB) do
		  info.text = value
		  info.isTitle = nil
		  info.notCheckable = nil
		  info.func = addon.OnClickFunc
		  info.arg1 = value
		  info.checked = addon.isCurrent(value)
		  UIDropDownMenu_AddButton(info)
	   end
	end 
	function addon.isCurrent(current)
	   if addon.db.modifier == current then
		  return true
	   else
		  return false
	   end
	end
	
	addon.slider1 = CreateFrame("Slider", addonName.."slider1", addon.panel, "OptionsSliderTemplate")
	addon.slider1:SetPoint("LEFT", addon.checkbox1, "RIGHT", 170, 0)
	_G[addon.slider1:GetName().."Text"]:SetText("|c00FFFFAA"..L["Bar Scale: "] .. string.format("%.1f", addon.db.scale))
	_G[addon.slider1:GetName().."Text"]:SetPoint("BOTTOMLEFT", addon.slider1, "TOPLEFT")
	addon.slider1.tooltipText = L["Drag to set Main Bar Scale"]
	_G[addon.slider1:GetName().."Low"]:SetText(L["Smaller"])
	_G[addon.slider1:GetName().."High"]:SetText(L["Larger"])
	addon.slider1:SetWidth(155)
	addon.slider1:SetMinMaxValues(0.1, 3)
	addon.slider1:SetValue(addon.db.scale)
	addon.slider1:SetValueStep(0.1)
	addon.slider1:SetScript("OnValueChanged", function(self, value)
		TrinketBarDB.scale = value
		addon.SetScale(value)
		_G[addon.slider1:GetName().."Text"]:SetText("|c00FFFFAA"..L["Bar Scale: "] .. string.format("%.1f", value))
	end)
	
	addon.slider2 = CreateFrame("Slider", addonName.."slider2", addon.panel, "OptionsSliderTemplate")
	addon.slider2:SetPoint("TOPLEFT", addon.slider1, "BOTTOMLEFT", 0, -30)
	_G[addon.slider2:GetName().."Text"]:SetText("|c00FFFFAA"..L["Menu Scale: "] .. string.format("%.1f", addon.db.menuScale))
	_G[addon.slider2:GetName().."Text"]:SetPoint("BOTTOMLEFT", addon.slider2, "TOPLEFT")
	addon.slider2.tooltipText = L["Drag to set Menu Scale"]
	_G[addon.slider2:GetName().."Low"]:SetText(L["Smaller"])
	_G[addon.slider2:GetName().."High"]:SetText(L["Larger"])
	addon.slider2:SetWidth(155)
	addon.slider2:SetMinMaxValues(0.1, 3)
	addon.slider2:SetValue(addon.db.menuScale)
	addon.slider2:SetValueStep(0.1)
	addon.slider2:SetScript("OnValueChanged", function(self, value)
		TrinketBarDB.menuScale = value
		addon.SetMenuScale(value)
		_G[addon.slider2:GetName().."Text"]:SetText("|c00FFFFAA"..L["Menu Scale: "] .. string.format("%.1f", value))
	end)
	
	addon.slider3 = CreateFrame("Slider", addonName.."slider3", addon.panel, "OptionsSliderTemplate")
	addon.slider3:SetPoint("TOPLEFT", addon.slider2, "BOTTOMLEFT", 0, -40)
	_G[addon.slider3:GetName().."Text"]:SetText("|c00FFFFAA"..L["Wrap menu at rows: "] .. addon.db.wrapRows)
	_G[addon.slider3:GetName().."Text"]:SetPoint("BOTTOMLEFT", addon.slider3, "TOPLEFT")
	addon.slider3.tooltipText = L["Sets how many rows before a new line is displayed"]
	_G[addon.slider3:GetName().."Low"]:SetText("1")
	_G[addon.slider3:GetName().."High"]:SetText("5")
	addon.slider3:SetWidth(155)
	addon.slider3:SetMinMaxValues(1, 5)
	addon.slider3:SetValue(addon.db.wrapRows)
	addon.slider3:SetValueStep(1)
	addon.slider3:SetScript("OnValueChanged", function(self, value)
		TrinketBarDB.wrapRows = value
		_G[addon.slider3:GetName().."Text"]:SetText("|c00FFFFAA"..L["Wrap menu at rows: "] .. addon.db.wrapRows)
	end)
	
	addon.keyButton = CreateFrame("Button", addonName.."keyButton", addon.panel, "UIPanelButtonTemplate")
	addon.keyButton:SetPoint("TOPLEFT", addon.slider3, "BOTTOMLEFT", 30, -40)
	addon.keyButton:SetHeight(30)
	addon.keyButton:SetWidth(100)
	addon.keyButton:SetText(L["Key Bindings"])
	addon.keyButton:SetScript("OnClick", function (self, button, down)
		KeyBindingFrame_LoadUI()
		KeyBindingFrame.mode = 1
		ShowUIPanel(KeyBindingFrame)
	end)

	addon.resetButton = CreateFrame("Button", addonName.."resetButton", addon.panel, "UIPanelButtonTemplate")
	addon.resetButton:SetPoint("TOP", addon.keyButton, "BOTTOM", 0, -20)
	addon.resetButton:SetHeight(30)
	addon.resetButton:SetWidth(130)
	addon.resetButton:SetText(L["Reset Position"])
	addon.resetButton:SetScript("OnClick", function (self, button, down)
		addon.anchor:ClearAllPoints()
		addon.anchor:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	end)	
	function addon.HelpText()
		local helpText = "|c00FFFFAA"..L["Usage:"].."\n" .. 
		L["Hold down" ]..addon.db.modifier.." ".. L["while mouseover to open the menu."].."\n" .. 
		L["Click Left Mousebutton to equip a trinket in the top slot."].."\n" .. 
		L["Click Right Mousebutton to equip a trinket in the bottom slot."].."\n" ..
		L["type /tb for slash commands"]
		DEFAULT_CHAT_FRAME:AddMessage(helpText)
	end
	addon.helpButton = CreateFrame("Button", addonName.."helpButton", addon.panel, "UIPanelButtonTemplate")
	addon.helpButton:SetPoint("CENTER", addon.panel, "BOTTOM", 0, 40)
	addon.helpButton:SetHeight(30)
	addon.helpButton:SetWidth(80)
	addon.helpButton:SetNormalTexture(nil)
	addon.helpButton:SetPushedTexture(nil)
	addon.helpButton:SetText(L["Help"])
	addon.helpButton:SetScript("OnClick", function (self, button, down)
		addon.HelpText()
	end)
	
end

-- slash commands
SlashCmdList["TB"] = function(msg)
	if msg == "lock" then
		if addon.db.locked then
			addon.db.locked = false
			addon.anchor:Show()
			DEFAULT_CHAT_FRAME:AddMessage("|c00FFFFAA"..L["TrinketBar"]..": |r"..L["Bars Unlocked"])
		else
			addon.db.locked = true
			addon.anchor:Hide()
			DEFAULT_CHAT_FRAME:AddMessage("|c00FFFFAA"..L["TrinketBar"]..": |r"..L["Bars Locked"])
		end
	addon.checkbox1:SetChecked(addon.db.locked)
	elseif msg == "reset" then
		addon.anchor:ClearAllPoints()
		addon.anchor:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		DEFAULT_CHAT_FRAME:AddMessage("|c00FFFFAA"..L["TrinketBar"]..": |r"..L["Position Reset"])
	elseif msg == "hide" then
		if addon.db.hidden then
			addon.ShowAll()
			addon.db.hidden = false
			DEFAULT_CHAT_FRAME:AddMessage("|c00FFFFAA"..L["TrinketBar"]..": |r"..L["Bars Shown"])
		else
			addon.HideAll()		
			addon.db.hidden = true
			DEFAULT_CHAT_FRAME:AddMessage("|c00FFFFAA"..L["TrinketBar"]..": |r"..L["Bars Hidden"])
		end
	addon.checkbox4:SetChecked(addon.db.hidden)
	elseif msg == "options" then
		InterfaceOptionsFrame_OpenToCategory(K_TBpanel)
	else
		local helpText = "|c00FFFFAA"..L["TrinketBar"]..": |r"..L["Usage:"].." /tb "..L["<command>"].."\n" ..
		"|c00FFFFAAlock |r- "..L["Locks/Unlocks Bar"].."\n" ..
		"|c00FFFFAAhide |r- "..L["Hide/Show Bar"].."\n" ..
		"|c00FFFFAAreset |r- "..L["Resets Bar Position"].."\n" ..
		"|c00FFFFAAoptions |r- "..L["Opens up Interface Options"].."\n"
		DEFAULT_CHAT_FRAME:AddMessage(helpText)
	end
end
SLASH_TB1 = "/tb"