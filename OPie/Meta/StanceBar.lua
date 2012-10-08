local frame = ShapeshiftBarFrame or StanceBarFrame
local keeper, parent, pendingValue = CreateFrame("Frame"), frame:GetParent();
keeper:Hide();

local function SetStanceBarVisibility(option, hidden, id)
	if hidden == nil then hidden = true; end
	if id ~= nil then return false; end
	if InCombatLockdown() then
		pendingValue = hidden;
	else
		frame:SetParent(hidden and keeper or parent);
		if hidden == false and frame:IsShown() then frame:Show(); end
		pendingValue = nil;
	end
end

OneRingLib:RegisterOption("HideStanceBar", false, SetStanceBarVisibility);
EC_Register("PLAYER_REGEN_ENABLED", "OPie.StanceBar.Combat", function(event)
	if pendingValue ~= nil then
		SetStanceBarVisibility("HideStanceBar", pendingValue);
	end
end);