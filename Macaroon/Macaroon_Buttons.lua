--Macaroon, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved..

local M = Macaroon

M.Buttons = {}

MacaroonButtonDefaults = {
	config = {
		upClicks = true,
		downClicks = false,
		copyDrag = false,
		muteSFX = false,
		clearerrors= false,
		cooldownAlpha = 1,

		bindText = true,
		bindColor = "1;1;1;1",

		countText = true,
		spellCounts = false,
		countColor = "1;1;1;1",

		macroText = true,
		macroColor = "1;1;1;1",

		cdText = false,
		cdcolor1 = "1;0.82;0;1",
		cdcolor2 = "1;0.1;0.1;1",

		auraText = false,
		auracolor1 = "0;0.82;0;1",
		auracolor2 = "1;0.1;0.1;1",

		auraInd = false,
		buffcolor = "0;0.8;0;1",
		debuffcolor = "0.8;0;0;1",

		rangeInd = true,
		rangecolor = "0.7;0.15;0.15;1",
	}
}

local unitAuras = { player = {}, target = {}, focus = {} }

local chargeTable = {}

local possessInfo = function(index) if (index and M.PossessSpell) then return select(index, UnitBuff("player", M.PossessSpell)) end end

local specialActions = {
	petattack = { "Interface\\Icons\\Ability_GhoulFrenzy", M.Strings.PETATTACK, { 0, 1, 0, 1 }, "/petattack" },
	petfollow = { "Interface\\Icons\\Ability_Tracking", M.Strings.PETFOLLOW, { 0, 1, 0, 1 }, "/petfollow" },
	petstay = { "Interface\\Icons\\Spell_Nature_TimeStop", M.Strings.PETSTAY, { 0, 1, 0, 1 }, "/petstay" },
	petaggressive = { "Interface\\Icons\\Ability_Racial_BloodRage", M.Strings.PETAGGRESSIVE, { 0, 1, 0, 1 }, "/petaggressive" },
	petdefensive = { "Interface\\Icons\\Ability_Defend", M.Strings.PETDEFENSIVE, { 0, 1, 0, 1 }, "/petdefensive" },
	petpassive = { "Interface\\Icons\\Ability_Seal", M.Strings.PETPASSIVE, { 0, 1, 0, 1 }, "/petpassive" },
	vehicleup = { "Interface\\Vehicles\\UI-Vehicles-Button-Pitch-Up", AIM_UP, { 0.21875, 0.765625, 0.234375, 0.78125 }, "/run VehicleAimIncrement()" },
	vehicledown = { "Interface\\Vehicles\\UI-Vehicles-Button-PitchDown-Up", AIM_DOWN, { 0.21875, 0.765625, 0.234375, 0.78125 }, "/run VehicleAimDecrement()"},
	vehicleleave = { "Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up", LEAVE_VEHICLE, { 0.140625, 0.859375, 0.140625, 0.859375 }, "/click VehicleMenuBarLeaveButton"},
	possessaction = { possessInfo, possessInfo, { 0, 1, 0, 1 }, [[ ]] },
	possesscancel = { "Interface\\Icons\\Spell_Shadow_SacrificialShield", CANCEL, { 0, 1, 0, 1 }, "/click PossessButton2" },
}

local alphaTimer, alphaDir, macroDrag, ItemCache, cmdSlash, chargeUpdate, pew, throttle = 0, 0

--local copies of often used globals
local gmatch = string.gmatch
local floor = math.floor
local ceil = math.ceil
local select = _G.select
local tonumber = _G.tonumber
local unpack = _G.unpack
local next = _G.next
local pi, cos, sin = math.pi, cos, sin

local HasAction = _G.HasAction
local GetTime = _G.GetTime
local UnitAura = _G.UnitAura
local UnitMana = _G.UnitMana
local InCombatLockdown = _G.InCombatLockdown
local SecureCmdOptionParse = _G.SecureCmdOptionParse
local QueryCastSequence = _G.QueryCastSequence
local SetCVar = _G.SetCVar
local UIErrorsFrame = _G.UIErrorsFrame

local GetNumShapeshiftForms = _G.GetNumShapeshiftForms
local GetShapeshiftFormInfo = _G.GetShapeshiftFormInfo
local GetContainerNumSlots = _G.GetContainerNumSlots
local GetComboPoints = _G.GetComboPoints

local GetCursorInfo = _G.GetCursorInfo

local GetActionInfo = _G.GetActionInfo
local IsActionInRange = _G.IsActionInRange

local GetSpellCooldown = _G.GetSpellCooldown
local GetSpellTexture = _G.GetSpellTexture
local GetSpellCount = _G.GetSpellCount
local IsCurrentSpell = _G.IsCurrentSpell
local IsAutoRepeatSpell = _G.IsAutoRepeatSpell
local IsAttackSpell = _G.IsAttackSpell
local IsSpellInRange = _G.IsSpellInRange

local GetInventoryItemLink = _G.GetInventoryItemLink
local GetItemCooldown = _G.GetItemCooldown
local GetItemInfo = _G.GetItemInfo
local GetItemCount = _G.GetItemCount
local GetItemIcon = _G.GetItemIcon
local IsCurrentItem = _G.IsCurrentItem
local IsItemInRange = _G.IsItemInRange

local GetPetActionInfo = _G.GetPetActionInfo
local GetPetActionsUsable = _G.GetPetActionsUsable
local GetPetActionSlotUsable = _G.GetPetActionSlotUsable
local GetPetActionCooldown = _G.GetPetActionCooldown

local GetPossessInfo = _G.GetPossessInfo
local GetCompanionCooldown = _G.GetCompanionCooldown

local ShowOverlayGlow = ActionButton_ShowOverlayGlow
local HideOverlayGlow = ActionButton_HideOverlayGlow

local CopyTable = M.CopyTable
local SpellIndex = M.SpellIndex
local CompIndex = M.CompIndex
local GetChildrenAndRegions = M.GetChildrenAndRegions

local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT
local PowerBarColor = CopyTable(PowerBarColor); PowerBarColor[0].r = 0.4; PowerBarColor[0].g = 0.4; PowerBarColor[0].b = 1

local SD, MBD = MacaroonSavedState, MacaroonButtonDefaults
local defaultMBD = CopyTable(MacaroonButtonDefaults)

local tooltipScan = MacaroonTooltipScan
local tooltipScanTextLeft2 = MacaroonTooltipScanTextLeft2

local autoCast = {
	speeds = { 2, 4, 6, 8 },
	timers = { 0, 0, 0, 0 },
	circle = { 0, 22, 44, 66 },
	shines = {},
	r = 0.95,
	g = 0.95,
	b = 0.32,
}

local spellGlows, cooldowns, cdAlphas = {}, {}, {}

local function AutoCastStart(shine, r, g, b)

	autoCast.shines[shine] = shine

	if (not r) then
		r, g, b = autoCast.r, autoCast.g, autoCast.b
	end

	for _,sparkle in pairs(shine.sparkles) do
		sparkle:Show(); sparkle:SetVertexColor(r, g, b)
	end
end

local function AutoCastStop(shine)

	autoCast.shines[shine] = nil

	for _,sparkle in pairs(shine.sparkles) do
		sparkle:Hide()
	end
end

local function controlOnUpdate(self, elapsed)

	for i in next,autoCast.timers do

		autoCast.timers[i] = autoCast.timers[i] + elapsed

		if ( autoCast.timers[i] > autoCast.speeds[i]*4 ) then
			autoCast.timers[i] = 0
		end

	end

	for i in next,autoCast.circle do

		autoCast.circle[i] = autoCast.circle[i] - i

		if ( autoCast.circle[i] < 0 ) then
			autoCast.circle[i] = 359
		end

	end

	for shine in next, autoCast.shines do

		local distance, radius = shine:GetWidth(), shine:GetWidth()/2.7

		for i=1,4 do

			local timer, speed, degree, x, y, position = autoCast.timers[i], autoCast.speeds[i], autoCast.circle[i]

			if ( timer <= speed ) then

				if (shine.shape == "round") then

					x = ((radius)*(4/pi))*(cos(degree)); y = ((radius)*(4/pi))*(sin(degree))
					shine.sparkles[0+i]:SetPoint("CENTER", shine, "CENTER", x, y)

					x = ((radius)*(4/pi))*(cos(degree-90)); y = ((radius)*(4/pi))*(sin(degree-90))
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "CENTER", x, y)

					x = ((radius)*(4/pi))*(cos(degree-180)); y = ((radius)*(4/pi))*(sin(degree-180))
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "CENTER", x, y)

					x = ((radius)*(4/pi))*(cos(degree-270)); y = ((radius)*(4/pi))*(sin(degree-270))
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "CENTER", x, y)

				else

					position = timer/speed*distance

					shine.sparkles[0+i]:SetPoint("CENTER", shine, "TOPLEFT", position, 0)
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "BOTTOMRIGHT", -position, 0)
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "TOPRIGHT", 0, -position)
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "BOTTOMLEFT", 0, position)
				end

			elseif (timer <= speed*2) then

				if (shine.shape == "round") then

					x = ((radius)*(4/pi))*(cos(degree)); y = ((radius)*(4/pi))*(sin(degree))
					shine.sparkles[0+i]:SetPoint("CENTER", shine, "CENTER", x, y)

					x = ((radius)*(4/pi))*(cos(degree+90)); y = ((radius)*(4/pi))*(sin(degree+90))
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "CENTER", x, y)

					x = ((radius)*(4/pi))*(cos(degree+180)); y = ((radius)*(4/pi))*(sin(degree+180))
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "CENTER", x, y)

					x = ((radius)*(4/pi))*(cos(degree+270)); y = ((radius)*(4/pi))*(sin(degree+270))
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "CENTER", x, y)

				else

					position = (timer-speed)/speed*distance

					shine.sparkles[0+i]:SetPoint("CENTER", shine, "TOPRIGHT", 0, -position)
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "BOTTOMLEFT", 0, position)
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "BOTTOMRIGHT", -position, 0)
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "TOPLEFT", position, 0)

				end

			elseif (timer <= speed*3) then

				if (shine.shape == "round") then

					x = ((radius)*(4/pi))*(cos(degree)); y = ((radius)*(4/pi))*(sin(degree))
					shine.sparkles[0+i]:SetPoint("CENTER", shine, "CENTER", x, y)

					x = ((radius)*(4/pi))*(cos(degree+90)); y = ((radius)*(4/pi))*(sin(degree+90))
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "CENTER", x, y)

					x = ((radius)*(4/pi))*(cos(degree+180)); y = ((radius)*(4/pi))*(sin(degree+180))
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "CENTER", x, y)

					x = ((radius)*(4/pi))*(cos(degree+270)); y = ((radius)*(4/pi))*(sin(degree+270))
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "CENTER", x, y)

				else

					position = (timer-speed*2)/speed*distance

					shine.sparkles[0+i]:SetPoint("CENTER", shine, "BOTTOMRIGHT", -position, 0)
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "TOPLEFT", position, 0)
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "BOTTOMLEFT", 0, position)
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "TOPRIGHT", 0, -position)

				end

			else

				if (shine.shape == "round") then

					x = ((radius)*(4/pi))*(cos(degree)); y = ((radius)*(4/pi))*(sin(degree))
					shine.sparkles[0+i]:SetPoint("CENTER", shine, "CENTER", x, y)

					x = ((radius)*(4/pi))*(cos(degree+90)); y = ((radius)*(4/pi))*(sin(degree+90))
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "CENTER", x, y)

					x = ((radius)*(4/pi))*(cos(degree+180)); y = ((radius)*(4/pi))*(sin(degree+180))
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "CENTER", x, y)

					x = ((radius)*(4/pi))*(cos(degree+270)); y = ((radius)*(4/pi))*(sin(degree+270))
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "CENTER", x, y)

				else

					position = (timer-speed*3)/speed*distance

					shine.sparkles[0+i]:SetPoint("CENTER", shine, "BOTTOMLEFT", 0, position)
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "TOPRIGHT", 0, -position)
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "TOPLEFT", position, 0)
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "BOTTOMRIGHT", -position, 0)

				end
			end
		end
	end

	alphaTimer = alphaTimer + elapsed * 2

	if (alphaDir == 1) then
		if (1-alphaTimer <= 0) then
			alphaDir = 0; alphaTimer = 0
		end
	else
		if (alphaTimer >= 1) then
			alphaDir = 1; alphaTimer = 0
		end
	end

	if (macroDrag) then
		SetCursor(macroDrag[7])
	end
end

local function updateNonPet(button)

	AutoCastStop(button.shine)
	button.autocastable:Hide()
	button.autocastenabled = false
end

local function changeButtonType(button)

	if (button.config.type == "macro") then

		M.UpdateFlyout(button)
		button.config.type = "action"
		updateNonPet(button)

	elseif (button.config.type == "action") then

		M.UpdateFlyout(button)
		button.config.type = "pet"

	elseif (button.config.type == "pet") then

		button.config.type = "macro"
		updateNonPet(button)

	else
		button.config.type = "macro"
		updateNonPet(button)
	end

	M.SetButtonType(button)
end

local function autoWriteMacro(self, spell, subName)

	local modifier, modkey = " "

	if (SD.selfCast) then
		modKey = ((SD.selfCast):match("^%a+")):lower(); modifier = modifier.."[@player,mod:"..modKey.."]"
	end

	if (SD.focusCast) then
		modKey = ((SD.focusCast):match("^%a+")):lower(); modifier = modifier.."[@focus,mod:"..modKey.."]"
	end

	if (SD.rightClickTarget) then
		modKey = SD.rightClickTarget; modifier = modifier.."[@"..modKey..",btn:2]"
	end

	if (self.bar and self.bar.config.target) then
		modKey = self.bar.config.target; modifier = modifier.."[@"..modKey.."]"
	end

	if (modKey) then
		modifier = modifier.."[] "
	end

	if (subName and #subName > 0) then
		return "#autowrite\n/cast"..modifier..spell.."("..subName..")"
	else
		return "#autowrite\n/cast"..modifier..spell.."()"
	end
end

local function updateData(button, bar, state)

	button.bar = bar
	button.alpha = bar.config.alpha
	button.showGrid = bar.config.showGrid
	button.dualSpec = bar.config.dualSpec
	button.spellGlow = bar.config.spellGlow
	button.copyDrag = bar.config.copyDrag

	if (button.__MSQ_NormalTexture) then

		button.hasAction = false
		button.noAction = false

		if (button.__MSQ_Shape) then
			button.shape = button.__MSQ_Shape:lower()
		else
			button.shape = "square"
		end

	else
		button.hasAction = "Interface\\Buttons\\UI-Quickslot2"
		button.noAction = "Interface\\Buttons\\UI-Quickslot"
		button.shape = "square"
	end

	button.shine.shape = button.shape

	button.config.bar = bar:GetID()
	button.config.stored = bar.config.stored
	button.config.showstates = state

	button:SetAttribute("showstates", state)
	button:SetAttribute("showgrid-bar", bar.config.showGrid)
	button:SetFrameStrata(bar.config.buttonStrata)
	button:SetFrameLevel(4)
	button.iconframe:SetFrameLevel(2)
	button.iconframecooldown:SetFrameLevel(3)
	button.iconframeaurawatch:SetFrameLevel(3)

	button.scale = button.config.scale * bar.config.scale
	button.copyDrag = button.config.copyDrag
	button.muteSFX = button.config.muteSFX
	button.clearerrors = button.config.clearerrors
	button.spellCounts = button.config.spellCounts
	button.comboCounts = button.config.comboCounts
	button.cdText = button.config.cdText
	button.auraText = button.config.auraText
	button.auraInd = button.config.auraInd
	button.auraWatch = button.auraInd or button.auraText

	if (button.auraInd and button.auraBorder) then
		button.border:Show()
	else
		button.border:Hide()
	end

	button.configAlpha = button.config.alpha

	if (button.config.cooldownAlpha < 1) then
		button.cdAlpha = button.config.cooldownAlpha
	else
		button.cdAlpha = nil
	end

	button.skincolor = { (";"):split(button.config.skincolor) }
	button.hovercolor = { (";"):split(button.config.hovercolor) }
	button.equipcolor = { (";"):split(button.config.equipcolor) }
	button.cdcolor1 = { (";"):split(button.config.cdcolor1) }
	button.cdcolor2 = { (";"):split(button.config.cdcolor2) }
	button.auracolor1 = { (";"):split(button.config.auracolor1) }
	button.auracolor2 = { (";"):split(button.config.auracolor2) }
	button.buffcolor = { (";"):split(button.config.buffcolor) }
	button.debuffcolor = { (";"):split(button.config.debuffcolor) }
	button.manacolor = { 0.5, 0.5, 1.0 }

	if (button.config.bindText) then
		button.hotkey:SetText((button.config.hotKeyText):match("^:([^:]+)") or "")
		button.hotkey:SetTextColor((";"):split(button.config.bindColor))
		button.hotkey:Show()
	else
		button.hotkey:Hide()
	end

	if (button.config.countText) then
		button.count:SetTextColor((";"):split(button.config.countColor))
		button.count:Show()
	else
		button.count:Hide()
	end

	if (button.config.macroText) then
		button.macroname:SetTextColor((";"):split(button.config.macroColor))
		button.macroname:Show()
	else
		button.macroname:Hide()
	end

	if (button.config.rangeInd) then
		button.rangecolor = { (";"):split(button.config.rangecolor) }
	else
		button.rangecolor = { 1, 1, 1, 1 }
	end

	local down, up = "", ""

	if (button.config.downClicks) then
		down = down.."AnyDown"
	end

	if (button.config.upClicks) then
		up = up.."AnyUp"
	end

	button:RegisterForClicks(down, up)

	if (#down + #up < 1) then
		button:SetHitRectInsets(button:GetWidth()/2, button:GetWidth()/2, button:GetHeight()/2, button:GetHeight()/2)
		button.editframe:SetHitRectInsets(0,0,0,0)
		button.hitbox:SetPoint("TOPLEFT", 0, 0)
		button.hitbox:SetPoint("BOTTOMRIGHT", 0, 0)
	else
		button:SetHitRectInsets(button.config.HHitBox, button.config.HHitBox, button.config.VHitBox, button.config.VHitBox)
		button.editframe:SetHitRectInsets(button.config.HHitBox, button.config.HHitBox, button.config.VHitBox, button.config.VHitBox)
		button.hitbox:SetPoint("TOPLEFT", button.config.HHitBox, -button.config.VHitBox)
		button.hitbox:SetPoint("BOTTOMRIGHT", -button.config.HHitBox, button.config.VHitBox)
	end

	if (bar.handler and not button.config.stored) then
		M.UpdateButtonVisibility(button, bar.handler:GetAttribute("state-current"))
	end

	button.updateTexture = true

	M.EditFrames[button] = button.editframe
end

local function buttonDefaults(index, button)

	button.config = {

		bar = 0,
		barPos = 0,
		showstates = "",
		laststate = "",
		stored = true,
		locked = false,

		hotKeys = ":",
		hotKeyText = ":",
		hotKeyLock = false,
		hotKeyPri = false,

		type = "macro",

		action = index,
		petaction = index,

		macro = "",
		macroIcon = 1,
		macroName = "",
		macroNote = "",
		macroUseNote = false,
		macroAuto = false,
		macroRand = false,

		mouseAnchor = false,
		clickAnchor = false,
		anchorDelay = false,
		anchoredBar = false,
		flyoutDock = false,

		upClicks = true,
		downClicks = false,
		copyDrag = false,
		muteSFX = false,
		clearerrors= false,
		cooldownAlpha = 1,

		bindText = true,
		bindColor = "1;1;1;1",

		countText = true,
		spellCounts = false,
		comboCounts = false,
		countColor = "1;1;1;1",

		macroText = true,
		macroColor = "1;1;1;1",

		cdText = false,
		cdcolor1 = "1;0.82;0;1",
		cdcolor2 = "1;0.1;0.1;1",

		auraText = false,
		auracolor1 = "0;0.82;0;1",
		auracolor2 = "1;0.1;0.1;1",

		auraInd = false,
		buffcolor = "0;0.8;0;1",
		debuffcolor = "0.8;0;0;1",

		rangeInd = true,
		rangecolor = "0.7;0.15;0.15;1",

		skincolor = "1;1;1;1",
		hovercolor = "0.1;0.1;1;1",
		equipcolor = "0.1;1;0.1;1",

		scale = 1,
		alpha = 1,
		XOffset = 0,
		YOffset = 0,
		HHitBox = 0,
		VHitBox = 0,

		fix091610 = false,
		fix100310 = false,
		fix112711 = false,

	}

	if (button.config.action > M.maxActionID) then
		while (button.config.action > M.maxActionID) do
			button.config.action = button.config.action - M.maxActionID
		end
	end

	if (button.config.petaction > M.maxPetID) then
		while (button.config.petaction > M.maxPetID) do
			button.config.petaction = button.config.petaction - M.maxPetID
		end
	end
end

local function createButton(index)

	local button

	if (_G["MacaroonButton"..index]) then
		button = _G["MacaroonButton"..index]
		button.macrospell=nil; button.macroitem=nil; button.macroshow=nil
	else
		button = CreateFrame("CheckButton", "MacaroonButton"..index, UIParent, "MacaroonActionButtonTemplate")
	end

	local buttonName, objects = button:GetName(), nil

	button:SetAttribute("showgrid", 0)
	button:SetAttribute("showstates", "homestate")
	button:SetAttribute("hotkeys", "")
	button:SetAttribute("tempid", index)
	button:SetID(0)
	button.id = index

	buttonDefaults(index, button)

	objects = GetChildrenAndRegions(button)

	for k,v in pairs(objects) do
		local name = (v):gsub(button:GetName(), "")
		button[name:lower()] = _G[v]
	end

	button.editor = M.ButtonEditor
	button.bindframe:SetID(index)
	button.bindframe.bindType = "button"
	button.update = function() end
	button.leftclick = changeButtonType
	button.updateData = updateData
	button.storage = MacaroonButtonStorage

	button.clearMacro = function(button)
					button.config.macro = ""
					button.config.macroIcon = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK"
					button.config.macroName = ""
					button.config.macroNote = ""
					button.config.macroUseNote = false
					button.config.macroAuto = false
					button.config.macroRand = false
				  end

	button:SetAttribute("_childupdate", [[

			local self, message = self, message

			self:SetAttribute("stateshown", false)

			if (self:GetAttribute("showstates")) then
				for showstate in gmatch(self:GetAttribute("showstates"), "[^;]+") do
					if (message and strfind(message, showstate)) then

						if (self:GetAttribute("hasaction") or
						    self:GetAttribute("showgrid-bar") or
						    self:GetAttribute("editmode")) then
							self:Show()
						end

						self:SetAttribute("stateshown", true)

						for i=1,select('#',(":"):split(self:GetAttribute("hotkeys"))) do
							self:SetBindingClick(self:GetAttribute("hotkeypri"), select(i,(":"):split(self:GetAttribute("hotkeys"))), self:GetName())
						end

					end
				end
			end

			if (not self:GetAttribute("stateshown")) then
				self:Hide()
				for key in gmatch(self:GetAttribute("hotkeys"), "[^:]+") do
					self:ClearBinding(key)
				end
			end
		]])

	SecureHandler_OnLoad(button)

	if (not SD.buttons) then
		SD.buttons = {}
	end

	if (not SD.buttons[index]) then
		SD.buttons[index] = { CopyTable(button.config), CopyTable(button.config) }
	end

	M.Buttons[index] = { button, 1 }

	updateData(button, button.storage)

	M.SetButtonType(button)

	return button
end

--[[ Button Update Functions ]]--

local function cooldownsOnUpdate(self, elapsed)

	local coolDown, formatted, size

	for cd in next,cooldowns do

		coolDown = floor(cd.duration-(GetTime()-cd.start))
		formatted, size = coolDown, cd.button:GetWidth()*0.45

		if (coolDown < 1) then

			if (coolDown < 0) then

				cooldowns[cd] = nil

				cd.timer:Hide()
				cd.timer:SetText("")
				cd.timerCD = nil
				cd.expirecolor = nil
				cd.cdsize = nil
				cd.active = nil
				cd.expiry = nil

			elseif (coolDown >= 0) then

				cd.timer:SetAlpha(cd.duration-(GetTime()-cd.start))

				if (cd.alphafade) then
					cd:SetAlpha(cd.duration-(GetTime()-cd.start))
				end

			end

		elseif (cd.timer:IsShown() and coolDown ~= cd.timerCD) then

			if (coolDown >= 86400) then
				formatted = ceil(coolDown/86400)
				formatted = formatted.."d"; size = cd.button:GetWidth()*0.3
			elseif (coolDown >= 3600) then
				formatted = ceil(coolDown/3600)
				formatted = formatted.."h"; size = cd.button:GetWidth()*0.3
			elseif (coolDown >= 60) then
				formatted = ceil(coolDown/60)
				formatted = formatted.."m"; size = cd.button:GetWidth()*0.3
			elseif (coolDown < 6) then
				size = cd.button:GetWidth()*0.6
				if (cd.expirecolor) then
					cd.timer:SetTextColor(cd.expirecolor[1], cd.expirecolor[2], cd.expirecolor[3]); cd.expirecolor = nil
					cd.expiry = true
				end
			end

			if (not cd.cdsize or cd.cdsize ~= size) then
				cd.timer:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE"); cd.cdsize = size
			end

			cd.timerCD = coolDown
			cd.timer:SetAlpha(1)
			cd.timer:SetText(formatted)

		end
	end

	for cd in next,cdAlphas do

		coolDown = ceil(cd.duration-(GetTime()-cd.start))

		if (coolDown < 1) then

			cdAlphas[cd] = nil
			cd.button:SetAlpha(cd.button.configAlpha)
			cd.alphaOn = nil

		elseif (not cd.alphaOn) then

			cd.button:SetAlpha(cd.button.cdAlpha)
			cd.alphaOn = true
		end
	end

end

local function setTimer(cd, start, duration, enable, timer, color1, color2, cdAlpha)

	if ( start and start > 0 and duration > 0 and enable > 0) then

		cd:SetAlpha(1)

		CooldownFrame_SetTimer(cd, start, duration, enable)

		if (duration >= SD.timerLimit) then

			cd.duration = duration
			cd.start = start
			cd.active = true

			if (timer) then
				cd.timer:Show()
				if (not cd.expiry) then
					cd.timer:SetTextColor(color1[1], color1[2], color1[3])
				end
				cd.expirecolor = color2
			end

			cooldowns[cd] = true

			if (cdAlpha) then
				cdAlphas[cd] = true
			end
		end
	else
		CooldownFrame_SetTimer(cd, 0, 0, 0)
		cd.duration = 0
	end
end

-- Moonfire: 8921
-- Solar Eclipse: 48517
-- Sunfire: 93402

-- Holy Word: Chastise: 88625
-- Chakra: 14751
-- Chakra: Prayer of Healing: 81206 - 88685
-- Chakra: Renew: 81207 - 88682
-- Chakra: Heal: 81208 - 88684

local morphSpells = {
	[8921] = false,
	[88625] = false,
}

local function updateAuraInfo(unit)

	local index, _, spell, count, duration, timeLeft, caster, spellID = 1

	wipe(unitAuras[unit])

	repeat
		spell, _, _, count, _, duration, timeLeft, caster, _, _, spellID = UnitAura(unit, index, "HELPFUL")

		if (duration and (caster == "player" or caster == "pet")) then
			unitAuras[unit][spell:lower()] = "buff"..":"..duration..":"..timeLeft..":"..count
			unitAuras[unit][spell:lower().."()"] = "buff"..":"..duration..":"..timeLeft..":"..count
		end

		-- temp fix to detect mighty morphing power spells
		    if (spellID == 48517) then morphSpells[8921] = 93402
		elseif (spellID == 81206) then morphSpells[88625] = 88685
		elseif (spellID == 81207) then morphSpells[88625] = 88682
		elseif (spellID == 81208) then morphSpells[88625] = 88684
		end

		index = index + 1

   	until (not spell)

	index = 1

	repeat

		spell, _, _, count, _, duration, timeLeft, caster = UnitAura(unit, index, "HARMFUL")

		if (duration and (caster == "player" or caster == "pet")) then
			unitAuras[unit][spell:lower()] = "debuff"..":"..duration..":"..timeLeft..":"..count
			unitAuras[unit][spell:lower().."()"] = "debuff"..":"..duration..":"..timeLeft..":"..count
		end

		index = index + 1

	until (not spell)
end

local function updateAuraWatch(self, unit, spell)

	if (spell and (unit == self.unit or unit == "player")) then

		if (self.spellID and morphSpells[self.spellID]) then
			spell = GetSpellInfo(morphSpells[self.spellID])
		end

		spell = spell:gsub("%s*%(.+%)", ""):lower()

		if (unitAuras[unit][spell]) then

			local auraType, duration, timeLeft, count = (":"):split(unitAuras[unit][spell])

			duration = tonumber(duration); timeLeft = tonumber(timeLeft)

			if (self.auraInd) then

				self.auraBorder = true

				if (auraType == "buff") then
					self.border:SetVertexColor(self.buffcolor[1], self.buffcolor[2], self.buffcolor[3], 1.0)
				elseif (auraType == "debuff" and unit == "target") then
					self.border:SetVertexColor(self.debuffcolor[1], self.debuffcolor[2], self.debuffcolor[3], 1.0)
				end

				self.border:Show()
			else
				self.border:Hide()
			end

			local color = self.auracolor1

			if (self.auraText) then

				if (auraType == "debuff" and (unit == "target" or (unit == "focus" and UnitIsEnemy("player", "focus")))) then
					color = self.auracolor2
				end

				self.iconframeaurawatch.queueinfo = unit..":"..spell
			end

			if (self.iconframecooldown.timer:IsShown()) then
				self.auraQueue = unit..":"..spell; self.iconframeaurawatch.duration = 0; self.iconframeaurawatch:Hide()
			elseif (self.auraInd or self.auraText) then
				if (self.auraText) then
					setTimer(self.iconframecooldown, 0, 0, 0)
				end
				setTimer(self.iconframeaurawatch, timeLeft-duration, duration, 1, self.auraText, color)
			end

			self.auraWatchUnit = unit

		elseif (self.auraWatchUnit == unit) then

			self.iconframeaurawatch.duration = 0
			self.iconframeaurawatch:Hide()
			self.iconframeaurawatch.timer:SetText("")
			self.border:Hide()
			self.auraBorder = nil
			self.auraWatchUnit = nil
			self.auraTimer = nil
			self.auraQueue = nil
		end
	end
end

local function hasAction(button, data)

	if (data) then

		if (button.config.type == "action") then


			if (HasAction(data)) then
				if (not InCombatLockdown() and data < 121) then
					button:SetAttribute("hasaction", true)
				end
				return true
			else
				if (not InCombatLockdown() and data < 121) then
					button:SetAttribute("hasaction", false)
				end
				return false
			end


		elseif (button.config.type == "macro") then

			if (data and #data>0) then
				if (not InCombatLockdown()) then
					button:SetAttribute("hasaction", true)
				end
				return true
			else
				if (not InCombatLockdown()) then
					button:SetAttribute("hasaction", false)
				end
				return false
			end

		elseif (button.config.type == "pet") then

			local _, _, texture = GetPetActionInfo(data)

			if (GetPetActionSlotUsable(data)) then
				if (not InCombatLockdown()) then
					button:SetAttribute("hasaction", true)
				end

				if (texture) then
					return true
				else
					return false
				end
			else
				if (not InCombatLockdown()) then
					button:SetAttribute("hasaction", true)
				end
				return false
			end
		end
	end
end

local function isActiveShapeshiftSpell(spell)

	local shapeshift, texture, name, isActive = spell:match("^[^(]+")

	if (shapeshift) then
		for i=1, GetNumShapeshiftForms() do
			texture, name, isActive = GetShapeshiftFormInfo(i)
			if (isActive and name:lower() == shapeshift:lower()) then
				return texture
			end
		end
	end
end

--[[ "action" button functions ]]--

local function updateActionButton(self, action)

	local isUsable, notEnoughMana = IsUsableAction(action)

	if (self.editmode) then

		self.iconframeicon:SetVertexColor(0.2, 0.2, 0.2)

	elseif (isUsable) then

		if (IsActionInRange(action, self.unit) == 0) then
			self.iconframeicon:SetVertexColor(self.rangecolor[1], self.rangecolor[2], self.rangecolor[3])
		else
			self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
		end

	elseif (notEnoughMana and self.manacolor) then

		self.iconframeicon:SetVertexColor(self.manacolor[1], self.manacolor[2], self.manacolor[3])

	else
		self.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)
	end
end

local function updateActionIcon(self, hasAction, action)

	self.macroname:SetText(GetActionText(action))

	if (hasAction) then
		self.iconframeicon:SetTexture(GetActionTexture(action))
		self.iconframeicon:Show()
	else
		self.iconframeicon:Hide()
	end
end

local function updateActionState(self, action)

	if (not hasAction(self, action)) then

		self.count:SetText("")

	elseif (action < 121 and GetActionCount(action) and GetActionCount(action) > 1) then

		self.count:SetText(GetActionCount(action))

	elseif (self.spellCounts and self.actionSpell) then

		local spell = self.actionSpell

		if (spell and #spell > 0) then

			local _, _, _, cost, _, powertype = GetSpellInfo(spell)

			if (cost and powertype) then

				local count = floor(UnitMana("player")/cost)

				if (count > 0 and PowerBarColor[powertype]) then
					self.count:SetText(count)
					self.count:SetTextColor(PowerBarColor[powertype].r, PowerBarColor[powertype].g, PowerBarColor[powertype].b)
				else
					self.count:SetText("")
				end
			end
		end

	elseif (self.comboCounts) then

		local count = GetComboPoints("player", "target")

		if (count>0) then
			self.count:SetText(count)
			self.count:SetTextColor(PowerBarColor.RAGE.r, PowerBarColor.RAGE.g, PowerBarColor.RAGE.b)
		else
			self.count:SetText("")
		end

	else
		self.count:SetText("")
	end

	if (IsCurrentAction(action) or IsAutoRepeatAction(action)) then
		self:SetChecked(1)
	else
		self:SetChecked(nil)
	end

	if ((IsAttackAction(action) and IsCurrentAction(action)) or IsAutoRepeatAction(action)) then
		self.mac_flash = true
	else
		self.mac_flash = false
	end
end

local function updateAction_OnEvent(self, action)

	local actionType, actionID = GetActionInfo(action)

	if (actionID) then
		self.actionSpell = GetSpellInfo(actionID)
	else
		self.actionSpell = nil
	end

	if (self.actionSpell and SpellIndex[self.actionSpell:lower()]) then
		self.spellID = SpellIndex[self.actionSpell:lower()][5]
	else
		self.spellID = nil
	end

	if (IsEquippedAction(action)) then

		self.border:SetVertexColor(0, 1.0, 0, 0.5)
		self.border:Show()

	elseif (not self.auraBorder) then

		self.border:Hide()
	end

	if (hasAction(self, action)) then

		if (self.hasAction) then
			self.normaltexture:SetTexture(self.hasAction)
		end

		self.normaltexture:SetVertexColor(1,1,1,1)

		updateActionIcon(self, true, action)
	else

		self.normaltexture:SetVertexColor(1,1,1,0.35)

		if (self.noAction) then
			self.normaltexture:SetTexture(self.noAction)
		end

		updateActionIcon(self, false, action)
	end

	if (actionType == "flyout") then
		self.arrowPoint = "TOP"
		self.arrowX = 0
		self.arrowY = 5
		self.flyoutArrow = self.flyouttop
		self.flyoutArrow:Show()
	else
		self.flyoutArrow = nil
	end

	updateActionState(self, action)

	for k in pairs(unitAuras) do
		updateAuraWatch(self, k, self.actionSpell)
	end

end

local function updateActionCooldown_OnEvent(self, action, update)

	if (hasAction(self, action)) then

		local start, duration, enable = GetActionCooldown(action)

		if (duration and duration >= SD.timerLimit and self.iconframeaurawatch.active) then
			self.auraQueue = self.iconframeaurawatch.queueinfo
			self.iconframeaurawatch.duration = 0
			self.iconframeaurawatch:Hide()
		end

		setTimer(self.iconframecooldown, start, duration, enable, self.cdText, self.cdcolor1, self.cdcolor2, self.cdAlpha)
	end
end

local function actionButton_SetTooltip(self, edit)

	local action = self.action

	self.UpdateTooltip = nil

	if (hasAction(self, action)) then

		GameTooltip:SetAction(action)

		if (not edit) then
			self.UpdateTooltip = actionButton_SetTooltip
		end

	elseif (edit) then

		GameTooltip:SetText(M.Strings.EMPTY_BUTTON)
	end

	if (edit and SD.checkButtons[104]) then
		GameTooltip:AddLine("\n"..M.Strings.BUTTONEDIT_TOOLTIP1..self.id.."|r", 1.0, 1.0, 1.0)
	end

end

local function actionButton_OnUpdate(self, elapsed)

	if (self.mac_flash) then

		self.mac_flashing = true

		if (alphaDir == 1) then
			if ((1-(alphaTimer)) >= 0) then
				self.checkedtexture:SetVertexColor(1, 1, 1, 1)
			end
		elseif (alphaDir == 0) then
			if ((alphaTimer) <= 1) then
				self.checkedtexture:SetVertexColor(0.8, 0, 0, 1)
			end
		end

	elseif (self.mac_flashing) then

		self.checkedtexture:SetVertexColor(1, 1, 1, 1)
		self.mac_flashing = false
	end

	self.elapsed = self.elapsed + elapsed

	if (self.elapsed > SD.throttle) then

		updateActionButton(self, self.action)

		self.elapsed = 0
	end
end

local function actionButton_ShowGrid(button)

	if (not InCombatLockdown()) then

		if (button:GetAttribute("stateshown")) then
			button:Show()
		end
	end
end

local function actionButton_HideGrid(button)

	if (not InCombatLockdown()) then

		if (not button.config.stored and not button:GetAttribute("editmode") and not button:GetParent():GetAttribute("editmode")) then
			if (not button:IsMouseOver() and not hasAction(button ,button.action) and not button.showGrid) then
				button:Hide()
			end
		end
	end
end

local function actionButton_OnEvent(self, event, ...)


	if (event == "ACTIONBAR_UPDATE_COOLDOWN") then

		updateActionCooldown_OnEvent(self, self.action, true)

	elseif (event == "ACTIONBAR_UPDATE_STATE" or event == "CRAFT_SHOW" or event == "CRAFT_CLOSE" or event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE") then

		updateActionState(self, self.action)

	elseif (event == "ACTIONBAR_SLOT_CHANGED") then

		if (self.action) then

			if (select(1,...) ==  0 or select(1,...) ==  self.action) then
				updateAction_OnEvent(self, self.action)
				updateActionCooldown_OnEvent(self, self.action, true)
			end
		end

	elseif (event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW") then

		if (self.spellGlow) then

			local actionType, actionID = GetActionInfo(self.action)

			if (actionType == "spell" and actionID == ...) then

				updateActionCooldown_OnEvent(self, self.action, true)

				if (self.shape == "round") then
					AutoCastStart(self.shine)
				else
					ShowOverlayGlow(self)
				end
			end
		end

	elseif (event == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE") then

		if (self.overlay) then

			local actionType, actionID = GetActionInfo(self.action)

			if (actionType == "spell" and actionID == ...) then

				if (self.shape == "round") then
					AutoCastStop(self.shine)
				else
					HideOverlayGlow(self)
				end
			end
		end

	elseif (event == "ACTIONBAR_SHOWGRID") then

		actionButton_ShowGrid(self); self.hidegrid = true

	elseif (event == "ACTIONBAR_HIDEGRID") then

		if (self.hidegrid) then
			actionButton_HideGrid(self); self.hidegrid = nil
		end

	elseif (event == "UNIT_INVENTORY_CHANGED") then

		if (select(1,...) ==  "player") then
			local hasAction = hasAction(self, self.action)
			updateActionIcon(self, hasAction, self.action)
		end

	elseif (event == "UPDATE_SHAPESHIFT_FORM") then

		local hasAction = hasAction(self, self.action)

		updateActionState(self, self.action)
		updateActionIcon(self, hasAction, self.action)

	elseif (event == "UNIT_AURA") then

		if (unitAuras[...]) then
			updateActionState(self, self.action)
			updateAuraWatch(self, ..., self.actionSpell)
		end

	elseif (event == "UNIT_POWER" and unit == "player") then

		if (self.spellCounts) then
			updateActionState(self, self.action)
		end

	elseif (event == "PLAYER_TARGET_CHANGED") then

		for k in pairs(unitAuras) do
			updateAuraWatch(self, k, self.actionSpell)
		end

	elseif (event == "PLAYER_ENTERING_WORLD") then

		updateAction_OnEvent(self, self.action)
		updateActionCooldown_OnEvent(self, self.action)
		updateActionState(self, self.action)

	elseif (event == "PLAYER_ENTER_COMBAT" or event == "PLAYER_LEAVE_COMBAT") then

		if (IsAttackAction(self.action)) then
			updateActionState(self, self.action)
		end

	elseif (event == "START_AUTOREPEAT_SPELL") then

		if (IsAutoRepeatAction(self.action)) then
			updateActionState(self, self.action)
		end

	elseif (event == "STOP_AUTOREPEAT_SPELL") then

		if (self.mac_flashing and not IsAttackAction(self.action)) then
			updateActionState(self, self.action)
		end

	elseif (event == "UPDATE_BONUS_ACTIONBAR") then

		if (self.action > 120) then
			hasAction(self, self.action)
		end
	end
end

--[[ "pet" button functions ]]--

local function updatePetButton(button, petaction)

	if (button.editmode) then

		button.iconframeicon:SetVertexColor(0.2, 0.2, 0.2)

	elseif (GetPetActionSlotUsable(petaction)) then

		button.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
	else
		button.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)
	end
end

local function updatePetIcon(button, spell, subtext, texture, isToken)

	button.isToken = isToken

	button.macroname:SetText("")
	button.count:SetText("")

	if (texture) then

		if (isToken) then
			button.iconframeicon:SetTexture(_G[texture])
			button.tooltipName = _G[spell]
			button.tooltipSubtext = _G[spell.."_TOOLTIP"]
		else
			button.iconframeicon:SetTexture(texture)
			button.tooltipName = spell
			button.tooltipSubtext = subtext
		end

		button.iconframeicon:Show()

	else
		button.iconframeicon:SetTexture("")
		button.iconframeicon:Hide()
	end
end

local function updatePetState(button, isActive, allowed, enabled)

	if (button.__MSQ_Shape) then
		button.shape = button.__MSQ_Shape:lower()
	else
		button.shape = "square"
	end

	button.shine.shape = button.shape

	if (isActive) then
		button:SetChecked(1)
	else
		button:SetChecked(nil)
	end

	if (allowed) then
		button.autocastable:Show()
	else
		button.autocastable:Hide()
	end

	if (enabled) then

		AutoCastStart(button.shine)
		button.autocastable:Hide()
		button.autocastenabled = true

	else
		AutoCastStop(button.shine)

		if (allowed) then
			button.autocastable:Show()
		end

		button.autocastenabled = false
	end
end

local function updatePetCooldown_OnEvent(self, petaction, update)

	if (hasAction(self, petaction)) then

		local start, duration, enable = GetPetActionCooldown(petaction)

		if (duration and duration >= SD.timerLimit and self.iconframeaurawatch.active) then
			self.auraQueue = self.iconframeaurawatch.queueinfo
			self.iconframeaurawatch.duration = 0
			self.iconframeaurawatch:Hide()
		end

		setTimer(self.iconframecooldown, start, duration, enable, self.cdText, self.cdcolor1, self.cdcolor2, self.cdAlpha)
	end
end

local function updatePet_OnEvent(button)

	local petaction = button.petaction

	local spell, subtext, texture, isToken, isActive, allowed, enabled = GetPetActionInfo(petaction)

	if (isToken) then
		button.actionSpell = _G[spell]
	else
		button.actionSpell = spell
	end

	if (button.actionSpell and SpellIndex[button.actionSpell:lower()]) then
		button.spellID = SpellIndex[button.actionSpell:lower()][5]
	else
		button.spellID = nil
	end

	if (hasAction(button, petaction)) then

		if (button.hasAction) then
			button.normaltexture:SetTexture(button.hasAction)
		end

		button.normaltexture:SetVertexColor(1,1,1,1)

	else

		if (button.noAction) then
			button.normaltexture:SetTexture(button.noAction)
		end

		button.normaltexture:SetVertexColor(1,1,1,0.35)
	end

	updatePetIcon(button, spell, subtext, texture, isToken)
	updatePetState(button, isActive, allowed, enabled)
	updatePetCooldown_OnEvent(button, petaction)

end

local function petButton_SetTooltip(self, edit)

	local petaction = self.petaction

	if (self.isToken) then

		if (self.tooltipName) then
			GameTooltip:SetText(self.tooltipName, 1.0, 1.0, 1.0)

		end

		if (self.tooltipSubtext and self.UberTooltips) then
			GameTooltip:AddLine(self.tooltipSubtext, "", 0.5, 0.5, 0.5)
		end

	elseif (hasAction(self, petaction)) then

		if (self.UberTooltips) then
			GameTooltip:SetPetAction(petaction)
		else
			GameTooltip:SetText(self.actionSpell)
		end

		if (not edit) then
			self.UpdateTooltip = petButton_SetTooltip
		end

	elseif (edit) then

		GameTooltip:SetText(M.Strings.EMPTY_BUTTON)
	end

	if (edit and SD.checkButtons[104]) then
		GameTooltip:AddLine("\n"..M.Strings.BUTTONEDIT_TOOLTIP1..self.id.."|r", 1.0, 1.0, 1.0)
	end

	GameTooltip:Show()

end

local function petButton_OnUpdate(self, elapsed)

	self.elapsed = self.elapsed + elapsed

	if (self.elapsed > SD.throttle) then
		updatePetButton(self, self.petaction)
	end
end

local function petButton_ShowGrid(button)

	if (not InCombatLockdown()) then

		if (button:GetAttribute("stateshown")) then
			button:Show()
		end
	end
end

local function petButton_HideGrid(button)

	if (not InCombatLockdown()) then

		if (not button.config.stored and not button:GetAttribute("editmode") and not button:GetParent():GetAttribute("editmode")) then
			if (not button:IsMouseOver() and not hasAction(button, button.petaction) and not button.showGrid) then
				button:Hide()
			end
		end
	end
end

local function petButton_OnEvent(self, event, ...)

	if (event == "PET_BAR_UPDATE" or
	    event == "PLAYER_CONTROL_LOST" or
	    event == "PLAYER_CONTROL_GAINED" or
	    event == "PLAYER_FARSIGHT_FOCUS_CHANGED" or
	    (event == "UNIT_PET" and select(1,...) ==  "player")) then

		updatePet_OnEvent(self)

	elseif (event == "UNIT_FLAGS" or event == "UNIT_AURA") then

		if (select(1,...) ==  "pet") then
			updatePet_OnEvent(self)
		end

	elseif (event =="PET_BAR_UPDATE_COOLDOWN") then

		updatePetCooldown_OnEvent(self, self.petaction)

	elseif (event =="PET_BAR_SHOWGRID") then

		petButton_ShowGrid(self)

	elseif (event =="PET_BAR_HIDEGRID") then

		petButton_HideGrid(self)

	elseif (event == "PLAYER_ENTERING_WORLD") then

		if (not InCombatLockdown()) then

			local spell = GetPetActionInfo(self.petaction)

			if (spell) then
				self:SetAttribute("*macrotext2", "/petautocasttoggle "..spell)
			end
		end

		updatePet_OnEvent(self)
		updatePetCooldown_OnEvent(self, self.petaction)
	end
end

--[[ "macro" button functions ]]--

local function updateMacroData(self)

	if (self.macroparse) then

		local parse, spell, spellcmd, show, showcmd, cd, cdcmd, aura, auracmd, item, target, _ = self.macroparse

		for cmd, options in gmatch(parse, "(%c%p%a+)(%C+)") do

			--after gmatch, remove unneeded characters
			if (cmd) then cmd = cmd:gsub("^%c+", "") end
			if (options) then options = options:gsub("^%s+", "") end

			--find #show option!
			if (not show and cmd:find("^#show")) then
				show = SecureCmdOptionParse(options); showcmd = cmd
			--sometimes SecureCmdOptionParse will return "" since that is not what we want, keep looking
			elseif (show and #show < 1 and cmd:find("^#show")) then
				show = SecureCmdOptionParse(options); showcmd = cmd
			end

			--find #cdwatch option!
			if (not cd and cmd:find("^#cdwatch")) then
				cd = SecureCmdOptionParse(options); cdcmd = cmd
			elseif (cd and #cd < 1 and cmd:find("^#cdwatch")) then
				cd = SecureCmdOptionParse(options); cdcmd = cmd
			end

			--find #aurawatch option!
			if (not aura and cmd:find("^#aurawatch")) then
				aura = SecureCmdOptionParse(options); auracmd = cmd
			elseif (aura and #aura < 1 and cmd:find("^#aurawatch")) then
				aura = SecureCmdOptionParse(options); auracmd = cmd
			end

			--find the spell!
			if (not spell and cmdSlash[cmd]) then
				spell, target = SecureCmdOptionParse(options); spellcmd = cmd
			elseif (spell and #spell < 1) then
				spell, target = SecureCmdOptionParse(options); spellcmd = cmd
			end
   		end

   		if (spell and spellcmd:find("/castsequence")) then
     			_, item, spell = QueryCastSequence(spell)
     		elseif (spell) then
     		     	if (#spell < 1) then
     				spell = nil
     			elseif(GetItemInfo(spell) or ItemCache[spell]) then
     				item = spell; spell = nil
     			elseif(tonumber(spell) and GetInventoryItemLink("player", spell)) then
     				item = GetInventoryItemLink("player", spell); spell = nil
     			end
     		end

     		self.unit = target or "target"

		if (spell) then
			self.macroitem = nil
			if (spell ~= self.macrospell) then
				spell = spell:gsub("!", ""); self.macrospell = spell
				if (SpellIndex[spell:lower()]) then
					self.spellID = SpellIndex[spell:lower()][5]
				else
					self.spellID = nil
				end
			end
		else
			self.macrospell = nil; self.spellID = nil
		end

		if (show and showcmd:find("#showicon")) then
			if (show ~= self.macroicon) then
     				if(tonumber(show) and GetInventoryItemLink("player", show)) then
     					show = GetInventoryItemLink("player", show)
     				end
				self.macroicon = show; self.macroshow = nil
			end
		elseif (show) then
			if (show ~= self.macroshow) then
     				if(tonumber(show) and GetInventoryItemLink("player", show)) then
     					show = GetInventoryItemLink("player", show)
     				end
				self.macroshow = show; self.macroicon = nil
			end
		else
			self.macroshow = nil; self.macroicon = nil
		end

		if (cd) then
			if (cd ~= self.macrocd) then
     				if(tonumber(aura) and GetInventoryItemLink("player", cd)) then
     					aura = GetInventoryItemLink("player", cd)
     				end
				self.macrocd = aura
			end
		else
			self.macrocd = nil
		end

		if (aura) then
			if (aura ~= self.macroaura) then
     				if(tonumber(aura) and GetInventoryItemLink("player", aura)) then
     					aura = GetInventoryItemLink("player", aura)
     				end
				self.macroaura = aura
			end
		else
			self.macroaura = nil
		end

		if (item) then
			self.macrospell = nil; self.spellID = nil
			if (item ~= self.macroitem) then
				self.macroitem = item
			end
		else
			self.macroitem = nil
		end

		if (parse:find("#macaroon\-")) then
			self.macrospecial = parse:match("\-(%a+)")
			if (self.macrospecial == "possesscancel") then
				M.PossessSpell = nil; self.possessspell = nil
				spellcmd, M.PossessSpell = GetPossessInfo(2)
				self.possessspell = M.PossessSpell
			end
		else
			self.macrospecial = nil; self.possessspell = nil
		end
	end
end

local function setSpellIcon(self, spell)

	local texture

	if (self.config.macroIcon == "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK") then

		spell = (spell):lower()

		if (SpellIndex[spell]) then

			local spell_id = SpellIndex[spell][5]

			if (morphSpells[spell_id]) then
				texture = GetSpellTexture(morphSpells[spell_id])
			elseif spell_id then
				texture = GetSpellTexture(spell_id)
			end

		elseif (CompIndex[spell]) then

			texture = CompIndex[spell][6]

		elseif (spell) then
			texture = GetSpellTexture(spell)
		end

		if (texture) then

			local shapeshift = isActiveShapeshiftSpell(spell)

			if (shapeshift) then
				self.iconframeicon:SetTexture(shapeshift)
			else
				self.iconframeicon:SetTexture(texture)

				--masks icons to be round O.O
				--SetPortraitToTexture(self.iconframeicon, texture)
			end

			self.iconframeicon:Show()
		else
			self.iconframeicon:SetTexture("")
			self.iconframeicon:Hide()
		end
	else
		if (self.config.macroIcon and #self.config.macroIcon > 0) then
			self.iconframeicon:SetTexture(self.config.macroIcon)
			self.iconframeicon:Show()
		else
			self.iconframeicon:SetTexture("")
			self.iconframeicon:Hide()
		end
	end

	return texture
end

local function setItemIcon(self, item)

	local _,texture, link, itemID

	if (IsEquippedItem(item)) then

		self.border:SetVertexColor(0, 1.0, 0, 0.5)
		self.border:Show()

	else
		self.border:Hide()
	end

	if (self.config.macroIcon == "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK") then

		_, link, _, _, _, _, _, _, _, texture = GetItemInfo(item)

		if (link and not ItemCache[item]) then

			_, itemID = (":"):split(link)

			if (itemID) then
				ItemCache[item] = itemID
			end
		end

		if (not texture and ItemCache[item]) then
			texture = GetItemIcon("item:"..ItemCache[item]..":0:0:0:0:0:0:0")
		end

		if (texture) then

			self.iconframeicon:SetTexture(texture)
			self.iconframeicon:Show()
		else

			self.iconframeicon:SetTexture("")
			self.iconframeicon:Hide()
		end
	else

		if (self.config.macroIcon and #self.config.macroIcon > 0) then
			self.iconframeicon:SetTexture(self.config.macroIcon)
			self.iconframeicon:Show()
		else
			self.iconframeicon:SetTexture("")
			self.iconframeicon:Hide()
		end
	end

	return texture
end

local function updateMacroIcon(self)

	self.updateMacroIcon = nil

	local spell, item, show, texture = self.macrospell, self.macroitem, self.macroshow or self.macroicon

	if (type(self.config.macroIcon) ~= "string") then
		self.config.macroIcon = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK"
	end

	if (show and #show>0) then

    		if(GetItemInfo(show) or ItemCache[show]) then
			texture = setItemIcon(self, show)
    		else
			texture = setSpellIcon(self, show)
    		end

	elseif (spell and #spell>0) then

		texture = setSpellIcon(self, spell)

	elseif (item and #item>0) then

		texture = setItemIcon(self, item)

	elseif (self:GetAttribute("macroShow")) then

		show = self:GetAttribute("macroShow")

    		if(GetItemInfo(show) or ItemCache[show]) then
			texture = setItemIcon(self, show)
    		else
			texture = setSpellIcon(self, show)
    		end

	else
		if (#self.config.macro>0) then

			self.iconframeicon:SetTexCoord(0.05,0.95,0.05,0.95)

			if (self.macrospecial and specialActions[self.macrospecial]) then

				if (type(specialActions[self.macrospecial][1]) == "function") then
					texture = specialActions[self.macrospecial][1](3)
				else
					texture = specialActions[self.macrospecial][1]
				end

				self.iconframeicon:SetTexCoord(unpack(specialActions[self.macrospecial][3]))

			end

			self.iconframeicon:SetTexture(texture or "")
			self.iconframeicon:Show()

		else
			self.iconframeicon:SetTexture("")
			self.iconframeicon:Hide()
			self.border:Hide()
		end
	end

	return texture
end

local function setSpellState(self, spell)

	if (GetSpellCount(spell) and  GetSpellCount(spell) > 1) then

		self.count:SetText(GetSpellCount(spell))

	elseif (self.spellCounts) then

		local _, _, _, cost, _, powertype = GetSpellInfo(spell)

		if (cost and powertype) then

			local count = floor(UnitMana("player")/cost)

			if (count > 0 and PowerBarColor[powertype]) then
				self.count:SetText(count)
				self.count:SetTextColor(PowerBarColor[powertype].r, PowerBarColor[powertype].g, PowerBarColor[powertype].b)
			else
				self.count:SetText("")
			end
		end

	elseif (self.config.comboCounts) then

		local count = GetComboPoints("player", "target")

		if (count>0) then
			self.count:SetText(count)
			self.count:SetTextColor(PowerBarColor.RAGE.r, PowerBarColor.RAGE.g, PowerBarColor.RAGE.b)
		else
			self.count:SetText("")
		end

	else
		self.count:SetText("")
	end

	if (CompIndex[spell:lower()]) then

		spell = CompIndex[spell:lower()][5]

		if (IsCurrentSpell(spell) or IsAutoRepeatSpell(spell)) then
			self:SetChecked(1); self.checkedtexture:SetVertexColor(1, 1, 1, 1)
		else
			self:SetChecked(nil)
		end
	else

		if (IsCurrentSpell(spell) or IsAutoRepeatSpell(spell) or isActiveShapeshiftSpell(spell:lower())) then
			self:SetChecked(1); self.checkedtexture:SetVertexColor(1, 1, 1, 1)
		else
			self:SetChecked(nil)
		end
	end

	if ((IsAttackSpell(spell) and IsCurrentSpell(spell)) or IsAutoRepeatSpell(spell)) then
		self.mac_flash = true
	else
		self.mac_flash = false
	end
end

local function setItemState(self, item)

	if (GetItemCount(item,nil,true) and  GetItemCount(item,nil,true) > 1) then
		self.count:SetText(GetItemCount(item,nil,true))
	else
		self.count:SetText("")
	end

	if(IsCurrentItem(item)) then
		self:SetChecked(1); self.checkedtexture:SetVertexColor(1, 1, 1, 1)
	else
		self:SetChecked(nil)
	end
end

local function updateMacroState(self)

	local spell, item, show = self.macrospell, self.macroitem, self.macroshow

	if (self.__MSQ_Shape) then
		self.shape = self.__MSQ_Shape:lower()
	else
		self.shape = "square"
	end

	self.shine.shape = self.shape

	self.macroname:SetText(self.config.macroName)

	if (show and #show>0) then

    		if(GetItemInfo(show) or ItemCache[show]) then
			setItemState(self, show)
    		else
			setSpellState(self, show)
    		end

	elseif (spell and #spell>0) then

		setSpellState(self, spell)

	elseif (item and #item>0) then

		setItemState(self, item)

	elseif (self:GetAttribute("macroShow")) then

		show = self:GetAttribute("macroShow")

    		if(GetItemInfo(show) or ItemCache[show]) then
			setItemState(self, show)
    		else
			setSpellState(self, show)
    		end
	else
		if (self.macrospecial and specialActions[self.macrospecial]) then

		else
			self:SetChecked(nil)
		end

		self.count:SetText("")
	end
end

local function setSpellCooldown(self, spell)

	local start, duration, enable

	spell = (spell):lower()

	if (CompIndex[spell]) then

		local companion, index = CompIndex[spell][1], CompIndex[spell][2]
		start, duration, enable = GetCompanionCooldown(companion, index)

	elseif (SpellIndex[spell]) then

		local spell_id = SpellIndex[spell][5]

		if (morphSpells[spell_id]) then
			start, duration, enable = GetSpellCooldown(morphSpells[spell_id])
		elseif spell_id then
			start, duration, enable = GetSpellCooldown(spell_id)
		end
	end

	if (duration and duration >= SD.timerLimit and self.iconframeaurawatch.active) then
		self.auraQueue = self.iconframeaurawatch.queueinfo
		self.iconframeaurawatch.duration = 0
		self.iconframeaurawatch:Hide()
	end

	setTimer(self.iconframecooldown, start, duration, enable, self.cdText, self.cdcolor1, self.cdcolor2, self.cdAlpha)

end

local function setItemCooldown(self, item)

	local id = ItemCache[item]

	if (id) then

		local start, duration, enable = GetItemCooldown(id)

		if (duration and duration >= SD.timerLimit and self.iconframeaurawatch.active) then
			self.auraQueue = self.iconframeaurawatch.queueinfo
			self.iconframeaurawatch.duration = 0
			self.iconframeaurawatch:Hide()
		end

		setTimer(self.iconframecooldown, start, duration, enable, self.cdText, self.cdcolor1, self.cdcolor2, self.cdAlpha)
	end
end

local function updateMacroCooldown(self, update)

	local spell, item, show = self.macrospell, self.macroitem, self.macrocd or self.macroshow

	if (show and #show>0) then

    		if(GetItemInfo(show) or ItemCache[show]) then
			setItemCooldown(self, show)
    		else
			setSpellCooldown(self, show)
    		end

	elseif (spell and #spell>0) then

		setSpellCooldown(self, spell)

	elseif (item and #item>0) then

		setItemCooldown(self, item)

	end
end

local function updateMacroTimers(self)

	updateMacroCooldown(self)

	for k in pairs(unitAuras) do
		if (self.macroaura) then
			updateAuraWatch(self, k, self.macroaura)
		else
			updateAuraWatch(self, k, self.macrospell)
		end
	end

end

local function updateSpellUsable(self, spell)

	local isUsable, notEnoughMana = IsUsableSpell(spell)

	if (notEnoughMana and self.manacolor) then

		self.iconframeicon:SetVertexColor(self.manacolor[1], self.manacolor[2], self.manacolor[3])

	elseif (isUsable) then

		if (IsSpellInRange(spell, self.unit) == 0) then
			self.iconframeicon:SetVertexColor(self.rangecolor[1], self.rangecolor[2], self.rangecolor[3])
		else
			self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
		end

	else
		if (SpellIndex[(spell):lower()]) then

			self.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)
		else
			self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
		end
	end

end

local function updateItemUsable(self, item)

       local isUsable, notEnoughMana = IsUsableItem(item)

	if (notEnoughMana and self.manacolor) then
		self.iconframeicon:SetVertexColor(self.manacolor[1], self.manacolor[2], self.manacolor[3])
	elseif (isUsable) then
		if (IsItemInRange(spell, self.unit) == 0) then
			self.iconframeicon:SetVertexColor(self.rangecolor[1], self.rangecolor[2], self.rangecolor[3])
		else
			self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
		end
	else
		self.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)
	end
end

local function updateMacroButton(self)

	local spell, item, show = self.macrospell, self.macroitem, self.macroshow

	if (self.editmode) then

		self.iconframeicon:SetVertexColor(0.2, 0.2, 0.2)

	elseif (show and #show>0) then

    		if(GetItemInfo(show) or ItemCache[show]) then
			updateItemUsable(self, show)
    		else
			updateSpellUsable(self, show)
    		end

	elseif (spell and #spell>0) then

		updateSpellUsable(self, spell)

	elseif (item and #item>0) then

		updateItemUsable(self, item)

	else
		self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
	end
end

local function setSpellTooltip(self, spell)

	if (SpellIndex[spell]) then

		local spell_id = SpellIndex[spell][5]

		if (morphSpells[spell_id]) then

			if (self.UberTooltips) then
				GameTooltip:SetHyperlink("spell:"..morphSpells[spell_id])
			else
				local spell = GetSpellInfo(morphSpells[spell_id])
				GameTooltip:SetText(spell, 1, 1, 1)
			end

		elseif (self.UberTooltips) then
			GameTooltip:SetSpellBookItem(SpellIndex[spell][1], SpellIndex[spell][2])
		else
			GameTooltip:SetText(SpellIndex[spell][3], 1, 1, 1)
		end

		self.UpdateTooltip = macroButton_SetTooltip

	elseif (CompIndex[spell]) then

		if (self.UberTooltips) then
			GameTooltip:SetHyperlink("spell:"..CompIndex[spell][5])
		else
			GameTooltip:SetText(CompIndex[spell][4], 1, 1, 1)
		end

		self.UpdateTooltip = nil
	end
end

local function setItemTooltip(self, item)

	local name, link = GetItemInfo(item)

	if (link) then

		if (self.UberTooltips) then
			GameTooltip:SetHyperlink(link)
		else
			GameTooltip:SetText(name, 1, 1, 1)
		end

	elseif (ItemCache[item]) then

		if (self.UberTooltips) then
			GameTooltip:SetHyperlink("item:"..ItemCache[item]..":0:0:0:0:0:0:0")
		else
			GameTooltip:SetText(ItemCache[item], 1, 1, 1)
		end
	end
end

local function macroButton_SetTooltip(self, edit)

	self.UpdateTooltip = nil

	if (self.config.macroUseNote) then

		GameTooltip:SetText(self.config.macroNote)

	else

		local spell, item, show = self.macrospell, self.macroitem, self.macroshow

		if (show and #show>0) then

			if(GetItemInfo(show) or ItemCache[show]) then
				setItemTooltip(self, show)
			else
				setSpellTooltip(self, (show):lower())
			end

		elseif (spell and #spell>0) then

			setSpellTooltip(self, (spell):lower())

		elseif (item and #item>0) then

			setItemTooltip(self, item)

		elseif (self:GetAttribute("macroShow")) then

			show = self:GetAttribute("macroShow")

			if(GetItemInfo(show) or ItemCache[show]) then
				setItemTooltip(self, show)
			else
				setSpellTooltip(self, (show):lower())
			end
		else
			if (self.macrospecial and specialActions[self.macrospecial]) then

				if (type(specialActions[self.macrospecial][1]) == "function") then
					local buff = specialActions[self.macrospecial][1](1)
					if (buff) then
						GameTooltip:SetUnitBuff("player", buff)
					end
				else
					if (self.possessspell) then
						GameTooltip:SetText(specialActions[self.macrospecial][2].." "..self.possessspell, 1, 1, 1)
					else
						GameTooltip:SetText(specialActions[self.macrospecial][2], 1, 1, 1)
					end
				end
			else
				if (#self.config.macroName>0) then
					GameTooltip:SetText(self.config.macroName)
				elseif (edit) then
					GameTooltip:SetText(M.Strings.EMPTY_BUTTON)
				end
			end
		end
	end

	if (edit and SD.checkButtons[104]) then
		GameTooltip:AddLine("\n"..M.Strings.BUTTONEDIT_TOOLTIP1..self.id.."|r", 1.0, 1.0, 1.0)
	end
end

local function updateMacroAll(self, event)

	updateMacroData(self)
	updateMacroIcon(self)
	updateMacroState(self)
	updateMacroTimers(self)

	if (self.updateTexture) then

		local macro = self:GetAttribute("*macrotext*") or self:GetAttribute("*macrotext1")

		if (macro and #macro > 0) then

			self.normaltexture:SetTexture(self.hasAction or "")
			self.normaltexture:SetVertexColor(1,1,1,1)

		else

			if (#self.config.macro>0) then
				self.normaltexture:SetVertexColor(1,1,1,1)
			else
				self.normaltexture:SetVertexColor(1,1,1,0.35)
			end

			self.normaltexture:SetTexture(self.noAction or "")
		end

		self.updateTexture = nil
	end

end

local function macroButton_OnUpdate(self, elapsed)

	if (self.mac_flash) then

		self.mac_flashing = true

		if (alphaDir == 1) then
			if ((1-(alphaTimer)) >= 0) then
				self.checkedtexture:SetVertexColor(1, 1, 1, 1)
			end
		elseif (alphaDir == 0) then
			if ((alphaTimer) <= 1) then
				self.checkedtexture:SetVertexColor(0.8, 0, 0, 1)
			end
		end

	elseif (self.mac_flashing) then

		self.checkedtexture:SetVertexColor(1, 1, 1, 1)
		self.mac_flashing = false
	end

	self.elapsed = self.elapsed + elapsed

	if (self.elapsed > SD.throttle) then
		updateMacroButton(self)
	end

	if (self.auraQueue and not self.iconframecooldown.active) then
		local unit, spell = (":"):split(self.auraQueue)
		if (unit and spell) then
			self.auraQueue = nil
			updateAuraWatch(self, unit, spell)
		end
	end
end

local function macroButton_ShowGrid(button)

	if (not InCombatLockdown()) then

		if (button:GetAttribute("stateshown")) then
			button:Show()
		end
	end

	updateMacroState(button)
end

local function macroButton_HideGrid(button)

	if (not InCombatLockdown()) then

		if (not button.config.stored and not button:GetAttribute("editmode") and not button:GetParent():GetAttribute("editmode")) then
			if (not hasAction(button ,button.config.macro) and not button.showGrid) then
				button:Hide()
			end
		end
	end

	updateMacroState(button)
end

local function updateButtonSpec(button, spec)

	if (pew) then

		local id, bar = button.id, button.bar
		local defaults = M.GetButtonDefaults()

		if (bar.config.dualSpec) then

			M.ClearBindings(button)

			if (SD.buttons[id][spec]) then

				button.config = CopyTable(SD.buttons[id][spec])

			else

				button.clearMacro(button)

			end

			M.UpdateConfig(button, defaults)

			M.ApplyBindings(button)

			M.SetButtonType(button, nil, nil, true)

			button.updateData(button, button.bar, button.config.showstates)
		end
	end
end

--[[
99896		["UNIT_AURA"]
84361		["SPELL_UPDATE_USABLE"]
66734		["BAG_UPDATE"]
51553		["ACTIONBAR_UPDATE_COOLDOWN"]
47187		["ACTIONBAR_UPDATE_STATE"]
31174		["BAG_UPDATE_COOLDOWN"]
20268		["ACTIONBAR_SLOT_CHANGED"]
14754		["UPDATE_MOUSEOVER_UNIT"]
13412		["UNIT_SPELLCAST_SUCCEEDED"]
12742		["UNIT_INVENTORY_CHANGED"]
7818		["UNIT_SPELLCAST_STOP"]
6947		["UNIT_FLAGS"]
4272		["SPELL_ACTIVATION_OVERLAY_GLOW_HIDE"]
4272		["SPELL_ACTIVATION_OVERLAY_GLOW_SHOW"]
3588		["UPDATE_MACRO_BUTTON"]
3124		["PLAYER_TARGET_CHANGED"]
3006		["PET_BAR_UPDATE"]
2530		["PLAYER_ENTERING_WORLD"]
2375		["ACTIONBAR_HIDEGRID"]
2375		["ACTIONBAR_SHOWGRID"]
2350		["UNIT_PET"]
1629		["PLAYER_REGEN_ENABLED"]
1629		["PLAYER_REGEN_DISABLED"]
1423		["MODIFIER_STATE_CHANGED"]
1423		["UNIT_SPELLCAST_INTERRUPTED"]
1250		["TRADE_SKILL_CLOSE"]
812		["UNIT_SPELLCAST_FAILED"]
379		["UPDATE_SHAPESHIFT_FORM"]
161		["PET_BAR_UPDATE_COOLDOWN"]
104		["ITEM_LOCK_CHANGED"]
42		["PLAYER_FARSIGHT_FOCUS_CHANGED"]
--]]

--function Macaroon.MACRO.ACTIONBAR_UPDATE_COOLDOWN(self, event, ...)
--	updateMacroCooldown(self, true)
--send

local function macroButton_OnEvent(self, event, ...)

	local unit, spell = ...

	if (event == "ACTIONBAR_UPDATE_COOLDOWN" or event == "RUNE_POWER_UPDATE") then

		updateMacroTimers(self)

	elseif (event == "ACTIONBAR_UPDATE_STATE" or event == "COMPANION_UPDATE") then

		updateMacroState(self)

	elseif (self.macroitem and (event == "BAG_UPDATE_COOLDOWN" or event == "BAG_UPDATE")) then

		updateMacroState(self)

	elseif (event == "UNIT_AURA" or event == "UPDATE_MOUSEOVER_UNIT") then

		if (unitAuras[...]) then

			if (self.macroaura) then
				updateAuraWatch(self, ..., self.macroaura)
			else
				updateAuraWatch(self, ..., self.macrospell)
			end

			if (... == "player") then
				updateMacroData(self)
				updateMacroIcon(self)
			end
		end

	elseif (event and event:find("UNIT_")) then

		if ((unit == "player" or unit == "pet") and spell and (self.macrospell or self.macrospecial)) then

			updateMacroTimers(self)
		end

	elseif (event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW") then

		if (self.spellGlow and self.spellID and ... == self.spellID) then

			updateMacroTimers(self)

			if (self.shape == "round") then
				AutoCastStart(self.shine)
			else
				ShowOverlayGlow(self)
			end
		end

	elseif (event == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE") then

		if ((self.overlay or self.spellGlow) and self.spellID and ... == self.spellID) then

			if (self.shape == "round") then
				AutoCastStop(self.shine)
			else
				HideOverlayGlow(self)
			end
		end

	elseif (event == "ITEM_LOCK_CHANGED") then

		if (GetCursorInfo()) then
			macroButton_ShowGrid(self)
		else
			macroButton_HideGrid(self)
		end

	elseif (event == "ACTIONBAR_SHOWGRID") then

		macroButton_ShowGrid(self); self.hidegrid = true

	elseif (event == "ACTIONBAR_HIDEGRID") then

		if (self.hidegrid) then
			macroButton_HideGrid(self); self.hidegrid = nil
		end

	elseif (event == "ACTIVE_TALENT_GROUP_CHANGED") then

		if (not MacaroonSpecProfiles.enabled) then

			local spec = select(1,...)

			updateButtonSpec(self, spec)
		end

	elseif (not event:find("UNIT_") and not event:find("BAG_")) then

		updateMacroAll(self)
	end
end

--[[ local button script handlers ]]--

local function button_OnShow(self)

	if (not self.config) then return end

	self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	self:RegisterEvent("ACTIONBAR_UPDATE_STATE")
	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
	self:RegisterEvent("ACTIONBAR_PAGE_CHANGED")

	self:RegisterEvent("RUNE_POWER_UPDATE")
	self:RegisterEvent("RUNE_TYPE_UPDATE")

	self:RegisterEvent("START_AUTOREPEAT_SPELL")
	self:RegisterEvent("STOP_AUTOREPEAT_SPELL")

	self:RegisterEvent("TRADE_SKILL_SHOW")
	self:RegisterEvent("TRADE_SKILL_CLOSE")
	self:RegisterEvent("ARCHAEOLOGY_CLOSED")

	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

	self:RegisterEvent("MODIFIER_STATE_CHANGED")

	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	self:RegisterEvent("UNIT_SPELLCAST_FAILED")
	self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("UNIT_ENTERED_VEHICLE")
	self:RegisterEvent("UNIT_ENTERING_VEHICLE")
	self:RegisterEvent("UNIT_EXITED_VEHICLE")

	if (self.comboCounts) then
		self:RegisterEvent("UNIT_COMBO_POINTS")
	end

	if (self.spellCounts) then
		self:RegisterEvent("UNIT_POWER")
	end

	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("PLAYER_FOCUS_CHANGED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_ENTER_COMBAT")
	self:RegisterEvent("PLAYER_LEAVE_COMBAT")
	self:RegisterEvent("PLAYER_CONTROL_LOST")
	self:RegisterEvent("PLAYER_CONTROL_GAINED")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

	self:RegisterEvent("UNIT_INVENTORY_CHANGED")
	self:RegisterEvent("BAG_UPDATE_COOLDOWN")
	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("COMPANION_UPDATE")
	self:RegisterEvent("PET_STABLE_UPDATE")
	self:RegisterEvent("PET_STABLE_SHOW")

	self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
	self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")

	self.update(self)
end

local function button_OnHide(self)

	self:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	self:UnregisterEvent("ACTIONBAR_UPDATE_STATE")
	self:UnregisterEvent("ACTIONBAR_SLOT_CHANGED")
	self:UnregisterEvent("ACTIONBAR_PAGE_CHANGED")

	self:UnregisterEvent("RUNE_POWER_UPDATE")
	self:UnregisterEvent("RUNE_TYPE_UPDATE")

	self:UnregisterEvent("START_AUTOREPEAT_SPELL")
	self:UnregisterEvent("STOP_AUTOREPEAT_SPELL")

	self:UnregisterEvent("TRADE_SKILL_SHOW")
	self:UnregisterEvent("TRADE_SKILL_CLOSE")
	self:UnregisterEvent("ARCHAEOLOGY_CLOSED")

	self:UnregisterEvent("UPDATE_SHAPESHIFT_FORM")
	self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")

	self:UnregisterEvent("MODIFIER_STATE_CHANGED")

	self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	self:UnregisterEvent("UNIT_SPELLCAST_FAILED")
	self:UnregisterEvent("UNIT_PET")
	self:UnregisterEvent("UNIT_AURA")
	self:UnregisterEvent("UNIT_ENTERED_VEHICLE")
	self:UnregisterEvent("UNIT_ENTERING_VEHICLE")
	self:UnregisterEvent("UNIT_EXITED_VEHICLE")

	self:UnregisterEvent("UNIT_COMBO_POINTS")

	self:UnregisterEvent("UNIT_POWER")

	self:UnregisterEvent("PLAYER_TARGET_CHANGED")
	self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("PLAYER_ENTER_COMBAT")
	self:UnregisterEvent("PLAYER_LEAVE_COMBAT")
	self:UnregisterEvent("PLAYER_CONTROL_LOST")
	self:UnregisterEvent("PLAYER_CONTROL_GAINED")
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")

	self:UnregisterEvent("UNIT_INVENTORY_CHANGED")
	self:UnregisterEvent("BAG_UPDATE_COOLDOWN")
	self:UnregisterEvent("BAG_UPDATE")
	self:UnregisterEvent("COMPANION_UPDATE")
	self:UnregisterEvent("PET_STABLE_UPDATE")
	self:UnregisterEvent("PET_STABLE_SHOW")

	self:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
	self:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")

end

local function button_ShowGrid(bars, edit, bind)

	for k,v in pairs(M.Buttons) do

		if (bars or edit or bind) then
			v[1]:SetAttribute("editmode", true)
		end

		if (v[1].config.type == "action") then
			actionButton_OnEvent(v[1], "ACTIONBAR_SHOWGRID")
		elseif (v[1].config.type == "macro") then
			macroButton_OnEvent(v[1], "ACTIONBAR_SHOWGRID")
		elseif (v[1].config.type == "pet") then
			petButton_OnEvent(v[1], "PET_BAR_SHOWGRID")
		end
	end
end

tinsert(M.ShowGrids, button_ShowGrid)

local function button_HideGrid(bars, edit, bind)

	for k,v in pairs(M.Buttons) do

		if (bars or edit or bind) then
			v[1]:SetAttribute("editmode", false)
		end

		if (v[1].config.type == "action") then
			actionButton_OnEvent(v[1], "ACTIONBAR_HIDEGRID")
		elseif (v[1].config.type == "macro") then
			macroButton_OnEvent(v[1], "ACTIONBAR_HIDEGRID")
		elseif (v[1].config.type == "pet") then
			petButton_OnEvent(v[1], "PET_BAR_HIDEGRID")
		end
	end
end

tinsert(M.HideGrids, button_HideGrid)

local function placeMacro(self, pickup)

	self.config.macro = macroDrag[2]
	self.config.macroIcon = macroDrag[3]
	self.config.macroName = macroDrag[4]
	self.config.macroNote = macroDrag[5]
	self.config.macroUseNote = macroDrag[6]
	self.config.macroAuto = macroDrag[8]
	self.config.macroRand = macroDrag[9]

	if (not self.cursor) then

		M.SetButtonType(self)

		if (macroDrag[1] ~= self) then

			if (macroDrag[1].dragbutton == "RightButton" and macroDrag[1].copyDrag) then

			else
				macroDrag[1].config.macro = ""
				macroDrag[1].config.macroIcon = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK"
				macroDrag[1].config.macroName = ""
				macroDrag[1].config.macroNote = ""
				macroDrag[1].config.macroUseNote = false
				macroDrag[1].config.macroAuto = false
				macroDrag[1].config.macroRand = false
				macroDrag[1].macrospell = nil
				macroDrag[1].macroitem = nil
				macroDrag[1].macroshow = nil
				macroDrag[1].macroicon = nil
				macroDrag[1].macroaura = nil
				macroDrag[1].macrospecial = nil
			end

			M.SetButtonType(macroDrag[1])
		end
	end

	macroDrag = nil

	if (not pickup) then
		ClearCursor(); SetCursor(nil)
	end

	button_HideGrid()
end

local function pickupMacro(self, currmacro)

	if (currmacro) then

		button_ShowGrid()

		macroDrag = { currmacro[1], currmacro[2], currmacro[3], currmacro[4], currmacro[5], currmacro[6], currmacro[7], currmacro[8] }

		SetCursor(currmacro[7])

		return true

	elseif (hasAction(self ,self.config.macro)) then

		button_ShowGrid()

		local texture = self.iconframeicon:GetTexture()

		macroDrag = { self, self.config.macro, self.config.macroIcon, self.config.macroName, self.config.macroNote, self.config.macroUseNote, texture, self.config.macroAuto, self.config.macroRand }

		if (self.dragbutton == "RightButton" and self.copyDrag) then

		else
			self.config.macro = ""
			self.config.macroIcon = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK"
			self.config.macroName = ""
			self.config.macroNote = ""
			self.config.macroUseNote = false
			self.config.macroAuto = false
			self.config.macroRand = false

			self.macrospell = nil
			self.spellID = nil
			self.macroitem = nil
			self.macroshow = nil
			self.macroicon = nil
			self.macroaura = nil
			self.macrospecial = nil
		end

		M.SetButtonType(self)

		SetCursor(macroDrag[7])

		return true
	else

		return false

	end
end

local function placeFlyout(self, action1, action2, hasmacro)

	if (action1 == 0) then
		return
	else

		local count = self.bar[self.bar.config.currentstate].buttonCount
		local columns = self.bar.config.columns or count
		local rows = count/columns

		local point = M.GetPosition(self, UIParent)

		if (columns/rows > 1) then

			if ((point):find("BOTTOM")) then
				point = "b:t:1"
			elseif ((point):find("TOP")) then
				point = "t:b:1"
			elseif ((point):find("RIGHT")) then
				point = "r:l:12"
			elseif ((point):find("LEFT")) then
				point = "l:r:12"
			else
				point = "r:l:12"
			end
		else
			if ((point):find("RIGHT")) then
				point = "r:l:12"
			elseif ((point):find("LEFT")) then
				point = "l:r:12"
			elseif ((point):find("BOTTOM")) then
				point = "b:t:1"
			elseif ((point):find("TOP")) then
				point = "t:b:1"
			else
				point = "r:l:12"
			end
		end

		self.config.macro = "/flyout blizz:"..action1..":l:"..point..":c"
	 	self.config.macroAuto = false
	 	self.config.macroIcon = ""
	end

	self.config.macroName = ""
	self.config.macroNote = ""
	self.config.macroUseNote = false
	self.config.macroRand = false

	if (not self.cursor) then
		M.SetButtonType(self)
	end

	macroDrag = nil

	ClearCursor(); SetCursor(nil)

	button_HideGrid()
end

local function placeCompanion(self, action1, action2, hasmacro)

	if (action1 == 0) then
		return
	else

		local _, _, spellID = GetCompanionInfo(action2, action1)
	 	local name = GetSpellInfo(spellID)

	 	if (name) then

	 		self.config.macro = autoWriteMacro(self, name)
	 		self.config.macroAuto = name
	 	else
	 		self.config.macro = ""
	 		self.config.macroAuto = false
	 	end
	end

	self.config.macroIcon = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK"
	self.config.macroName = ""
	self.config.macroNote = ""
	self.config.macroUseNote = false
	self.config.macroRand = false

	if (not self.cursor) then
		M.SetButtonType(self)
	end

	ClearCursor(); SetCursor(nil)

	button_HideGrid()
end

local function placeSpell(self, action1, action2, hasmacro)

	local _, modifier, spell, subName, texture = " "

	if (action1 == 0) then
		return
	else

	 	_, subName = GetSpellBookItemName(action1, action2)
	 	_, spellID = GetSpellBookItemInfo(action1, action2)

	 	spell = GetSpellInfo(spellID)

	 	self.config.macro = autoWriteMacro(self, spell, subName)
	 	self.config.macroAuto = spell..";"..subName
	 	self.config.macroIcon = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK"
	end

	self.config.macroName = ""
	self.config.macroNote = ""
	self.config.macroUseNote = false
	self.config.macroRand = false

	if (not self.cursor) then
		M.SetButtonType(self)
	end

	macroDrag = nil

	ClearCursor(); SetCursor(nil)

	button_HideGrid()
end

local function placeItem(self, action1, action2, hasmacro)

	local item, link = GetItemInfo(action2)

	if (GetItemSpell(item)) then
		self.config.macro = "/use "..item
	else
		self.config.macro = "/equip "..item
	end

	self.config.macroIcon = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK"
	self.config.macroName = ""
	self.config.macroNote = ""
	self.config.macroUseNote = false
	self.config.macroAuto = false
	self.config.macroRand = false

	if (not self.cursor) then
		M.SetButtonType(self)
	end

	macroDrag = nil

	ClearCursor(); SetCursor(nil)

	button_HideGrid()
end

local function placeBlizzMacro(self, action1, hasmacro)

	local name, icon, body = GetMacroInfo(action1)

	self.config.macro = body
	self.config.macroIcon = ""
	self.config.macroName = name
	self.config.macroNote = ""
	self.config.macroUseNote = false
	self.config.macroAuto = false
	self.config.macroRand = false

	if (not self.cursor) then
		M.SetButtonType(self)
	end

	macroDrag = nil

	ClearCursor(); SetCursor(nil)

	button_HideGrid()
end

local function placeBlizzAction(self)

	self.config.type = "action"

	if (self.config.action == 0) then

		self.config.action = self.id

		if (self.config.action > M.maxActionID) then
			while (self.config.action > M.maxActionID) do
				self.config.action = self.config.action - M.maxActionID
			end
		end
	end

	M.SetButtonType(self, true)

	PlaceAction(self.config.action)

	ClearCursor(); SetCursor(nil)

	if (not self.cursor) then
		M.SetButtonType(self)
	end

	updateAction_OnEvent(self, self.config.action)

	actionButton_SetTooltip(self)
end

local function pickUpButton(self, currmacro)

	local pickup

	if (not self.bar.config.barLock) then
		pickup = true
	elseif (self.bar.config.barLockAlt and IsAltKeyDown()) then
		pickup = true
	elseif (self.bar.config.barLockCtrl and IsControlKeyDown()) then
		pickup = true
	elseif (self.bar.config.barLockShift and IsShiftKeyDown()) then
		pickup = true
	end

	if (pickup or currmacro) then

		if (self.config.type == "action") then

			if (currmacro) then

				pickupMacro(self, currmacro)

			else

				if (self.config.action == 0) then

					self.config.action = self.id

					if (self.config.action > M.maxActionID) then
						while (self.config.action > M.maxActionID) do
							self.config.action = self.config.action - M.maxActionID
						end
					end

					M.SetButtonType(self)
				end

				PickupAction(self.action)
			end

		elseif (self.config.type == "macro") then

			pickupMacro(self, currmacro)

		elseif (self.config.type == "pet") then

			if (currmacro) then

				pickupMacro(self, currmacro)
			else

				if (self.config.petaction == 0) then

					if (self.id > 10) then
						self.config.petaction = 10
					else
						self.config.petaction = self.id
					end

					M.SetButtonType(self)
				end

				PickupPetAction(self.petaction)
			end
		end
	end
end

function M.CreateButton(index)

	local button = createButton(index)

	return button

end

function M.AddButton(command, bar, state)

	local count, table, currBar, currState, button, newButton = tonumber(command), {}

	if (bar) then
		currBar = bar
	else
		currBar = M.CurrentBar
	end

	if (not currBar) then
		MacaroonMessageFrame:AddMessage(M.Strings.NO_BAR_SELECTED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
		return
	end

	if (currBar.config.stored) then
		return
	end

	if (state) then
		currState = state
	else
		currState = currBar.handler:GetAttribute("state-current") or "homestate"
	end

	if (not count or count < 1) then
		count = 1
	end

	for i=1,count do

		newButton = 0

		if (currBar.reverse) then

			for k,v in pairs(currBar.btnTable) do
				if (not v[1].config.locked) then
					if (v[2] == 1 and newButton == 0) then
						newButton = k
					end
					if (v[2] == 1 and k > newButton) then
						newButton = k
					end
				end
			end
		else

			for k,v in pairs(currBar.btnTable) do
				if (not v[1].config.locked) then
					if (v[2] == 1 and newButton == 0) then
						newButton = k
						break
					end
				end
			end
		end

		if (newButton ~= 0) then

			button = _G[currBar.btnType..newButton]

		elseif (currBar.btnNew) then

			button = currBar.btnNew(currBar)

		end

		if (button) then
			currBar.btnSetNew(button, currBar, currState)
			tinsert(table, button)
		end

	end

	currBar.updateBar(currBar, nil, true, true, nil, true)

	return table

end

function M.StoreButton(button, btnTable)

	button:ClearAllPoints()

	button.config.bar = 0
	button.config.barPos = 0
	button.config.scale = 1
	button.config.XOffset = 0
	button.config.YOffset = 0
	button.config.target = "none"
	button.config.stored = true

	button.config.mouseAnchor = false
	button.config.clickAnchor = false
	button.config.anchorDelay = false
	button.config.anchoredBar = false

	if (button.hotkey) then
		M.ClearBindings(button)
	end

	M.UpdateAnchor(button, nil, nil, nil, true)

	button.skinset = false

	button:SetParent(button.storage)

	btnTable[button.id][2] = 1
end

function M.RemoveButton(command, bar, state)

	local count, currBar, button, index, currState, btnID = tonumber(command)

	if (not count or count < 1) then
		count = 1
	end

	if (bar) then
		currBar = bar
	else
		currBar = M.CurrentBar
	end

	if (not currBar) then
		MacaroonMessageFrame:AddMessage(M.Strings.NO_BAR_SELECTED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
		return
	end

	if (state) then
		currState = state
	else
		currState = currBar.handler:GetAttribute("state-current") or "homestate"
	end

	if (currBar.config.buttonList[currState]) then

		for i=1,count do

			if (currBar.reverse) then
				btnID = (currBar.config.buttonList[currState]):match("^%d+")
			else
				btnID = (currBar.config.buttonList[currState]):match("%d+$")
			end

			if (btnID) then

				button = _G[currBar.btnType..btnID]

				M.StoreButton(button, currBar.btnTable)

				if (currBar.reverse) then
					currBar.config.buttonList[currState] = (currBar.config.buttonList[currState]):gsub("^"..btnID.."[;]*", "")
				else
					currBar.config.buttonList[currState] = (currBar.config.buttonList[currState]):gsub("[;]*"..btnID.."$", "")
				end

				currBar.buttonCountChanged = true
			end
		end
	end

	currBar.updateBar(currBar, nil, true, true)

	if (pew and MacaroonButtonStorage:IsVisible()) then M.UpdateButtonStorage() end
end

function M.Button_OnLoad(self)

	self.elapsed = 0
	self.id = 0
	self.dir = 0
	self.alphatimer = 0

	self.spells = ""

	self.mac_flash = false
	self.mac_flashing = false
	self.show_tooltip = false
	self.tooltip_shown = false

	self:RegisterForClicks(SD.registerForClicks)
	self:RegisterForDrag("LeftButton", "RightButton")

	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	self:SetFrameLevel(4)
end

local startDrag

function M.Button_OnDragStart(self, button)

	if (InCombatLockdown() or not self.bar) then
		startDrag = nil; return
	end

	self.drag = nil

	if (not self.bar.config.barLock) then
		self.drag = true
	elseif (self.bar.config.barLockAlt and IsAltKeyDown()) then
		self.drag = true
	elseif (self.bar.config.barLockCtrl and IsControlKeyDown()) then
		self.drag = true
	elseif (self.bar.config.barLockShift and IsShiftKeyDown()) then
		self.drag = true
	end

	if (self.drag) then

		startDrag = true

		self.dragbutton = button

		pickUpButton(self)

		if (macroDrag) then

			PlaySound("igSpellBookSpellIconPickup"); self.sound = true

			if (macroDrag[1] ~= self) then
				self.dragbutton = nil
			end
		else
			self.dragbutton = nil
		end

		self.update(self)

		self.iconframecooldown.duration = 0
		self.iconframecooldown:Hide()
		self.iconframecooldown.timer:SetText("")

		self.iconframeaurawatch.duration = 0
		self.iconframeaurawatch:Hide()
		self.iconframeaurawatch.timer:SetText("")

		self.macrospell = nil
		self.spellID = nil
		self.macroitem = nil
		self.macroshow = nil
		self.macroicon = nil
		self.macroaura = nil
		self.macrospecial = nil

		self.auraQueue = nil

		self.border:Hide()

	else
		startDrag = nil
	end
end

function M.Button_OnDragStop(self)
	self.drag = nil
end

function M.Button_OnReceiveDrag(self, preclick)

	if (InCombatLockdown()) then
		return
	end

	local cursorType, action1, action2 = GetCursorInfo()

	if (self.config.type == "action") then

		if (macroDrag and (macroDrag[1] ~= self or preclick)) then

			self.config.type = "macro"

			if (HasAction(self.config.action)) then
				PickupAction(self.config.action)
				placeMacro(self, true)
			else
				placeMacro(self)
			end

			macroButton_SetTooltip(self)
		else

			if (self.config.action == 0) then

				self.config.action = self.id

				if (self.config.action > M.maxActionID) then
					while (self.config.action > M.maxActionID) do
						self.config.action = self.config.action - M.maxActionID
					end
				end

				M.SetButtonType(self)
			end

			PlaceAction(self.config.action)

			actionButton_SetTooltip(self)

		end

	elseif (self.config.type == "macro") then

		local texture = self.iconframeicon:GetTexture()

		self.currmacro = { self, self.config.macro, self.config.macroIcon, self.config.macroName, self.config.macroNote, self.config.macroUseNote, texture, self.config.macroAuto, self.config.macroRand }

		if  (action1 == 0) then

			-- do nothing for now

		else

			if (macroDrag) then

				placeMacro(self); PlaySound("igSpellBookSpellIconDrop")

			elseif (cursorType == "spell") then

				placeSpell(self, action1, action2, hasAction(self, self.config.macro))

			elseif (cursorType == "item") then

				placeItem(self, action1, action2, hasAction(self, self.config.macro))

			elseif (cursorType == "macro") then

				placeBlizzAction(self)

				--placeBlizzMacro(self, action1, hasAction(self, self.config.macro))

			elseif (cursorType == "companion") then

				placeCompanion(self, action1, action2, hasAction(self, self.config.macro))

			elseif (cursorType == "flyout") then

				placeFlyout(self, action1, action2, hasAction(self, self.config.macro))

			end

			macroButton_SetTooltip(self)
		end

		if (self.currmacro[2] and #self.currmacro[2]>0 and startDrag) then
			pickUpButton(self, self.currmacro)
		end

		wipe(self.currmacro)

	elseif (self.config.type == "pet") then

		if (macroDrag and (macroDrag[1] ~= self or preclick)) then

			self.config.type = "macro"
			placeMacro(self)
			macroButton_SetTooltip(self)

		elseif (cursorType == "spell") then

			self.config.type = "macro"
			placeSpell(self, action1, action2, hasAction(self, self.config.macro))
			macroButton_SetTooltip(self)

		else

			if (self.config.petaction == 0) then

				self.config.petaction = self.id

				if (self.config.petaction > M.maxPetID) then
					while (self.config.petaction > M.maxPetID) do
						self.config.petaction = self.config.petaction - M.maxPetID
					end
				end

				M.SetButtonType(self)
			end

			PickupPetAction(self.petaction)

			petButton_SetTooltip(self)

		end
	end

	self.update(self)

	self.elapsed = 0.2

	startDrag = nil
end

function M.Button_PreClick(self)

	M.ClickedButton = self

	self.cursor = nil

	if (not InCombatLockdown()) then

		local cursorType = GetCursorInfo()

		if (cursorType or macroDrag) then
			self.cursor = true
			startDrag = true
			M.SetButtonType(self, true)
			M.Button_OnReceiveDrag(self, true)
		end
	end

	if (self.muteSFX) then
		SetCVar("Sound_EnableSFX","0")
	end

end

function M.Button_PostClick(self)

	if (self.macrospecial) then
		self:SetChecked(nil)
	end

	if (not InCombatLockdown()) then
		if (self.cursor) then
			self.cursor = nil
			M.SetButtonType(self)
		end
	end

	if (self.muteSFX) then
		SetCVar("Sound_EnableSFX","1")
	end

	if (self.clearerrors) then
		UIErrorsFrame:Clear()
	end

	self.update(self)
end

function M.Button_OnEnter(self, edit)

	if (self.bar) then

		if (self.bar.config.tooltipsCombat and InCombatLockdown()) then
			return
		end

		if (self.bar.config.tooltips) then

			if (self.bar.config.tooltipsEnhanced) then
				self.UberTooltips = true
				GameTooltip_SetDefaultAnchor(GameTooltip, self)
			else
				self.UberTooltips = false
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			end

			if (self.config.type == "action") then

				actionButton_SetTooltip(self, edit)

			elseif (self.config.type == "macro") then

				macroButton_SetTooltip(self, edit)

			elseif (self.config.type == "pet") then

				petButton_SetTooltip(self, edit)
			end

			GameTooltip:Show()
		end
	end

	if (self.flyoutArrow) then

		self.flyoutArrow:SetPoint(self.arrowPoint, self.arrowX/0.625, self.arrowY/0.625)

		if (SD.checkButtons[104]) then
			GameTooltip:AddLine("\n|cff00ff00Flyout:|r Right Click to show, Left Click to use")
			GameTooltip:Show()
		end
	end
end

function M.Button_OnLeave(self)

	self.UpdateTooltip = nil

	GameTooltip:Hide()

	if (self.flyoutArrow) then
		self.flyoutArrow:SetPoint(self.arrowPoint, self.arrowX, self.arrowY)
	end
end

local function buttonReset(button)

	button:SetAttribute("unit", nil)
	button:SetAttribute("useparent-unit", nil)
	button:SetAttribute("type", nil)
	button:SetAttribute("type1", nil)
	button:SetAttribute("type2", nil)
	button:SetAttribute("*action*", nil)
	button:SetAttribute("*macrotext*", nil)
	button:SetAttribute("*action1", nil)
	button:SetAttribute("*macrotext2", nil)

	button:UnregisterEvent("ITEM_LOCK_CHANGED")
	button:UnregisterEvent("UPDATE_BONUS_ACTIONBAR")
	button:UnregisterEvent("ACTIONBAR_SHOWGRID")
	button:UnregisterEvent("ACTIONBAR_HIDEGRID")
	button:UnregisterEvent("PET_BAR_SHOWGRID")
	button:UnregisterEvent("PET_BAR_HIDEGRID")
	button:UnregisterEvent("PET_BAR_UPDATE")
	button:UnregisterEvent("PET_BAR_UPDATE_COOLDOWN")
	button:UnregisterEvent("UNIT_FLAGS")
	button:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

	button.update = function() end

	button.macrospell = nil
	button.spellID = nil
	button.macroitem = nil
	button.macroshow = nil
	button.macroicon = nil
	button.macroaura = nil
	button.macrospecial = nil

end

local buttonUpdates = {
	action = function(button) updateAction_OnEvent(button, button.action) updateActionCooldown_OnEvent(button, button.action, true) end,
	macro = function(button) button.updateTexture = true; updateMacroAll(button) end,
	pet = function(button) updatePet_OnEvent(button, button.config.petaction) updatePetCooldown_OnEvent(button, button.petaction, true) end,
}

function M.SetButtonUpdate(button, type)

	if (buttonUpdates[type]) then
		button.update = buttonUpdates[type]
	end

	if (button.update) then
		button.update(button)
	end

end

function M.SetButtonType(button, kill, initialize, respec)

	if (InCombatLockdown()) then
		return
	end

	buttonReset(button)

	if (kill) then

		button:SetScript("OnEvent", function() end)
		button:SetScript("OnUpdate", function() end)
		button:SetScript("OnAttributeChanged", function() end)
	else

		button:SetScript("OnShow", button_OnShow)
		button:SetScript("OnHide", button_OnHide)

		if (button.config.type == "action") then

			button:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
			button:RegisterEvent("ACTIONBAR_SHOWGRID")
			button:RegisterEvent("ACTIONBAR_HIDEGRID")

			if (pew) then
				M.UpdateFlyout(button)
			end

			button.action = button.config.action

			button:SetAttribute("type", button.config.type)
			button:SetAttribute("*action*", button.action)
			button:SetAttribute("useparent-unit", true)

			button:SetScript("OnEvent", actionButton_OnEvent)
			button:SetScript("OnUpdate", actionButton_OnUpdate)
			button:SetScript("OnAttributeChanged", nil)

			button.editframetype:SetText(button.config.type.."\nid:"..button.action)

			if (initialize) then

				local action = hasAction(button, button.action)

				if (action) then
					actionButton_ShowGrid(button)
				else
					actionButton_HideGrid(button)
				end
			end

			if (button.action > 120) then
				button:SetAttribute("hasaction", true)
			end

		elseif (button.config.type == "macro") then

			button:RegisterEvent("ITEM_LOCK_CHANGED")
			button:RegisterEvent("ACTIONBAR_SHOWGRID")
			button:RegisterEvent("ACTIONBAR_HIDEGRID")
			button:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

			--temp fix
			button.config.macro = button.config.macro:gsub("Rank %d+", "")
			--temp fix

			for k in pairs(specialActions) do
				if ((button.config.macro):find("#"..k)) then
					button.config.macro = (button.config.macro):gsub("#"..k, "#macaroon-"..k)
				end
			end

			if ((button.config.macro):find("#macaroon%-")) then

				button:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")

				button.macrospecial = (button.config.macro):match("#macaroon%-(%a+)")

				if (button.macrospecial and specialActions[button.macrospecial]) then
					button.config.macro = "#macaroon-"..button.macrospecial.."\n"..specialActions[button.macrospecial][4]
				end
			end

			local flyoutOpt = button.config.macro:match("/flyout%s(%C+)")

			if (flyoutOpt and #flyoutOpt>0) then

				if (pew) then
					M.UpdateFlyout(button, flyoutOpt, true)
				end

				if (button.macrospell) then
					button.macroshow = button.macrospell
				end

				if (button.macroitem) then
					button.macroshow = button.macroitem
				end

				button:SetAttribute("macroShow", button.macroshow)
			else
				M.UpdateFlyout(button)
			end

			button.macroparse = button.config.macro

			local macrotext = button.macroparse

			button:SetAttribute("type", button.config.type)
			button:SetAttribute("*macrotext*", macrotext)

			button:SetScript("OnEvent", macroButton_OnEvent)
			button:SetScript("OnUpdate", macroButton_OnUpdate)
			button:SetScript("OnAttributeChanged", function(self, name, value)
											for k in pairs(unitAuras) do
												if (self.macroaura) then
													updateAuraWatch(self, k, self.macroaura)
												else
													updateAuraWatch(self, k, self.macrospell)
												end
											end
									   end)

			if (#button.config.macro>0) then
				button.macroparse = "\n"..button.macroparse.."\n"
				button.macroparse = (button.macroparse):gsub("(%c+)", " %1")
			else
				button.macroparse = nil
			end

			button.editframetype:SetText(button.config.type)

			if (initialize) then

				local macro = hasAction(button, button.config.macro)

				if (macro) then
					macroButton_ShowGrid(button)
				else
					macroButton_HideGrid(button)
				end
			end

		elseif (button.config.type == "pet") then

			--temp fix for existing buttons and adding new petaction key
			if (button.config.petaction == 0 and button.config.barPos > 0) then
				button.config.petaction = button.config.barPos
			end

			button:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
			button:RegisterEvent("PET_BAR_SHOWGRID")
			button:RegisterEvent("PET_BAR_HIDEGRID")
			button:RegisterEvent("PET_BAR_UPDATE")
			button:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
			button:RegisterEvent("UNIT_FLAGS")

			if (pew) then
				M.UpdateFlyout(button)
			end

			button.petaction = button.config.petaction

			button:SetAttribute("type1", button.config.type)
			button:SetAttribute("type2", "macro")
			button:SetAttribute("*action1", button.petaction)

			local spell = GetPetActionInfo(button.petaction)

			if (spell) then
				button:SetAttribute("*macrotext2", "/petautocasttoggle "..spell)
			end

			button:SetAttribute("useparent-unit", false)
			button:SetAttribute("unit", ATTRIBUTE_NOOP)

			button:SetScript("OnEvent", petButton_OnEvent)
			button:SetScript("OnUpdate", petButton_OnUpdate)
			button:SetScript("OnAttributeChanged", nil)

			button.editframetype:SetText(button.config.type.."\nid:"..button.petaction)

			if (initialize) then

				local action = hasAction(button, button.petaction)

				if (action) then
					petButton_ShowGrid(button)
				else
					petButton_HideGrid(button)
				end
			end

		end

		M.SetButtonUpdate(button, button.config.type)

	end

	if (not respec and not initialize) then
		M.Save()
	end
end

function M.UpdateAutoMacros()

	local button, spell, subName

	for k,v in pairs(M.Buttons) do

		button = v[1]

		if (button.config.macroAuto) then

			spell, subName = (";"):split(button.config.macroAuto)
			button.config.macro = autoWriteMacro(button, spell, subName)
			M.SetButtonType(button)

		end
	end
end

function M.UpdateButtonVisibility(button, message)

	if (not message) then return end

	button:SetAttribute("stateshown", false)

	for showstate in gmatch(button:GetAttribute("showstates"), "[^;]+") do

		if ((message):match(showstate)) then

			if (button:GetAttribute("hasaction") or
			    button:GetAttribute("showgrid-bar") or
			    button:GetAttribute("editmode")) then
				button:Show()
			end

			button:SetAttribute("stateshown", true)

			for key in gmatch(button:GetAttribute("hotkeys"), "[^:]+") do
				SetOverrideBindingClick(button, button:GetAttribute("hotkeypri"), key, button:GetName())
			end
		end
	end

	if (not button:GetAttribute("stateshown")) then

		button:Hide()

		for key in gmatch(button:GetAttribute("hotkeys"), "[^:]+") do
			SetOverrideBinding(button, true, key, nil)
		end
	end
end

function M.GetButtonDefaults()

	local defaults = {}

	buttonDefaults(0, defaults)

	return defaults.config
end

function M.AddNewButton(bar)

	local index, made, button = 1, false

	while not made do

		if (not _G[bar.btnType..index] or (_G[bar.btnType..index] and not _G[bar.btnType..index].config)) then
			button = createButton(index)
			M.SetButtonType(button)
			made = true
		end

		index = index + 1
	end

	return button
end

function M.SetNewButton(button, bar, state)

	button.bar = bar
	button.hidegrid = true
	button.config.bar = bar:GetID()
	button.config.stored = false
	button.config.showstates = state
	button:SetAttribute("showstates", state)
	button:SetAttribute("editmode", true)

	button.newButton = true

	for k,v in pairs(MBD.config) do
		button.config[k] = v
	end

	if (button.hotkey) then
		M.ClearBindings(button)
	end

	M.UpdateButtonVisibility(button, state)

	if (not bar.config.buttonList[state] or bar.config.buttonList[state] == "") then
		bar.config.buttonList[state] = tostring(button.id)
	elseif (bar.reverse) then
		bar.config.buttonList[state] = button.id..";"..bar.config.buttonList[state]
	else
		bar.config.buttonList[state] = bar.config.buttonList[state]..";"..button.id
	end

	bar.buttonCountChanged = true

	bar.btnTable[button.id][2] = 0

end

local function checkCursor(self, button)

	if (macroDrag) then

		if (button == "LeftButton" or button == "RightButton") then

			macroDrag = nil; SetCursor(nil)
			for k,v in pairs(M.HideGrids) do
				v()
			end
		else
			SetCursor(macroDrag[7])
		end
	end
end

local function controlOnEvent(self, event, ...)

	if (event:find("UNIT_")) then

		if (unitAuras[select(1,...)]) then
			if (... == "player") then
				for k,v in pairs(morphSpells) do
					morphSpells[k] = false
				end
			end
			updateAuraInfo(select(1,...))
		end

	elseif (event == "PLAYER_TARGET_CHANGED") then

		for k in pairs(unitAuras) do
			updateAuraInfo(k)
		end

	elseif (event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW") then

		spellGlows[...] = true

	elseif (event == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE") then

		spellGlows[...] = nil

	elseif (event == "ADDON_LOADED" and ... == "Macaroon") then

		SD = MacaroonSavedState
		MBD = MacaroonButtonDefaults
		ItemCache = MacaroonItemCache
		throttle = SD.throttle or 0.2

		for k,v in pairs(defaultMBD) do
			if (MBD[k] == nil) then
				MBD[k] = v
			end
		end

		cmdSlash = {
			[SLASH_CAST1] = true,
			[SLASH_CAST2] = true,
			[SLASH_CAST3] = true,
			[SLASH_CAST4] = true,
			[SLASH_CASTRANDOM1] = true,
			[SLASH_CASTRANDOM2] = true,
			[SLASH_CASTSEQUENCE1] = true,
			[SLASH_CASTSEQUENCE2] = true,
			[SLASH_EQUIP1] = true,
			[SLASH_EQUIP2] = true,
			[SLASH_EQUIP3] = true,
			[SLASH_EQUIP4] = true,
			[SLASH_EQUIP_TO_SLOT1] = true,
			[SLASH_EQUIP_TO_SLOT2] = true,
			[SLASH_USE1] = true,
			[SLASH_USE2] = true,
			[SLASH_USERANDOM1] = true,
			[SLASH_USERANDOM2] = true,
			["/cast"] = true,
			["/castrandom"] = true,
			["/castsequence"] = true,
			["/spell"] = true,
			["/equip"] = true,
			["/eq"] = true,
			["/equipslot"] = true,
			["/use"] = true,
			["/userandom"] = true,
		}

		M.EditFrameTooltips.action = M.Button_OnEnter
		M.EditFrameTooltips.macro = M.Button_OnEnter
		M.EditFrameTooltips.pet = M.Button_OnEnter

	elseif (event == "VARIABLES_LOADED") then


	elseif (event == "PLAYER_LOGIN") then

		for k in pairs(unitAuras) do
			updateAuraInfo(k)
		end

		for k,v in pairs(M.Buttons) do
			v[1].update(v[1])
		end

		WorldFrame:HookScript("OnMouseUp", checkCursor)
		WorldFrame:HookScript("OnMouseDown", checkCursor)

	elseif (event == "PLAYER_ENTERING_WORLD" and not pew) then

		pew = true

	elseif (event == "ACTIONBAR_SHOWGRID") then

		startDrag = true

	end
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnUpdate", cooldownsOnUpdate)

frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", controlOnEvent)
frame:SetScript("OnUpdate", controlOnUpdate)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("VARIABLES_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("ACTIONBAR_SHOWGRID")
frame:RegisterEvent("UNIT_AURA")
frame:RegisterEvent("UNIT_SPELLCAST_SENT")
frame:RegisterEvent("UNIT_SPELLCAST_START")
frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
frame:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
frame:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")
