local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local FL = LibStub:GetLibrary("LibFishing-1.0")
local LT = LibStub("LibTourist-3.0")
local Crayon = LibStub("LibCrayon-3.0")

local switchSetting = "ClickToSwitch";
local function MenuInit()
   FishingBuddy.MakeDropDown(FBConstants.CLICKTOSWITCH_ONOFF, switchSetting)
end

local function Do_OnClick(self, button)
	if ( FishingBuddy and FishingBuddy.IsLoaded() ) then
		if ( button == "LeftButton" ) then
			if ( FishingBuddy.IsSwitchClick() ) then
				FishingBuddy.Command(FBConstants.SWITCH)
			else
				FishingBuddy.Command("")
			end
		else
			local menu = FB_Broker_Menu
			if (not menu) then
				menu = CreateFrame("FRAME", "FB_Broker_Menu", self, "UIDropDownMenuTemplate")
			end
			UIDropDownMenu_Initialize(menu, MenuInit, "MENU")
			menu.point = "TOPRIGHT"
			menu.relativePoint = "CENTER"
			ToggleDropDownMenu(1, nil, menu, self, 0, 0)
		end
	end
end

local dataobj = ldb:NewDataObject("Fishing Broker", {
    type = "launcher",
    icon = "Interface\\Icons\\Trade_Fishing",
    OnClick = Do_OnClick,
    tocname = "FB_Broker",
    label = "Skill",
})

dataobj.lastSkillCheck = nil

local f = CreateFrame("frame")
f.dataobj = dataobj

f:RegisterEvent("VARIABLES_LOADED")

function dataobj:OnTooltipShow()
    local hint
    if ( FishingBuddy and FishingBuddy.IsLoaded() ) then
		if ( FishingBuddy.GetSettingBool(switchSetting) ) then
			hint = FBConstants.TOOLTIP_HINTSWITCH
		else
			hint = FBConstants.TOOLTIP_HINTTOGGLE
		end
	else
		local _, fishing = FL:GetFishingSkillInfo()
		hint = CHAT_MSG_SKILL.." ("..fishing..")"
	end
	self:AddLine(Crayon:Green(hint))
end

function dataobj:UpdateSkill()
    local line = FL:GetFishingSkillLine(1)
    local needed
    self.lastSkillCheck, FB_BrokerData.caughtSoFar, needed = FL:GetSkillUpInfo(self.lastSkillCheck)
	if ( needed ) then
		line = line.." ("..FB_BrokerData.caughtSoFar.."/~"..needed..")"
	end
	self.text = line
	self.label = line
end

f:SetScript("OnEvent", function(self, event, ...)
	if ( event == "VARIABLES_LOADED" ) then
		if ( not FB_BrokerData ) then
			FB_BrokerData = {};
			FB_BrokerData.caughtSoFar = 0;
		end
		f:RegisterEvent("SKILL_LINES_CHANGED")
		f:RegisterEvent("ZONE_CHANGED")
		f:RegisterEvent("ZONE_CHANGED_INDOORS")
		f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		f:RegisterEvent("LOOT_CLOSED")

		FL:SetCaughtSoFar(FB_BrokerData.caughtSoFar)
	else
		f.dataobj:UpdateSkill()
	end
end)
