if not Recount then return end
local L_Recount = LibStub("AceLocale-3.0"):GetLocale("Recount")

LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Recount", {
	type = "launcher",
	label = "Recount",
	OnClick = function(_, msg)
		if msg == "LeftButton" then
			if Recount.MainWindow:IsVisible() then
				Recount.MainWindow:Hide()
			else
				Recount.MainWindow:Show()
				Recount:RefreshMainWindow()
			end
		elseif msg == "RightButton" then
			if not Recount.ConfigWindow or not Recount.ConfigWindow:IsVisible() then
				Recount:ShowConfig()
			else
				Recount.ConfigWindow:Hide()
			end
		end
	end,
	icon = "Interface\\AddOns\\Broker_Recount\\icon",
	OnTooltipShow = function(tooltip)
		if not tooltip or not tooltip.AddLine then return end
		tooltip:AddLine("Recount")
		tooltip:AddLine("|cffffff00" .. L_Recount["Click|r to toggle the Recount window"])
		tooltip:AddLine("|cffffff00" .. L_Recount["Right-click|r to open the options menu"])
	end,
})
