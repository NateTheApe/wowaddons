--Macaroon, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

local M = Macaroon

local function removeAnchorChild(anchor, flyoutDock)

	local child = anchor.anchoredBar or anchor.flyoutDock and anchor.flyoutDock.handler

	if (child) then

		anchor:UnwrapScript(anchor, "OnEnter")
		anchor:UnwrapScript(anchor, "OnLeave")
		anchor:UnwrapScript(anchor, "OnClick")
		anchor:SetAttribute("click-show", nil)

		child:SetAttribute("timedelay", nil)
		child:SetAttribute("_childupdate-onmouse", nil)
		child:SetAttribute("_childupdate-onclick", nil)

		child:SetAttribute("isAnchorChild", nil)

		child:UnwrapScript(child, "OnShow")
		child:UnwrapScript(child, "OnHide")

		if (not flyoutDock) then
			child:Show()
			child:SetParent(child.oldparent and child.oldparent:GetName() or "UIParent")
			child.oldparent = nil

			if (child.bar and child.bar.updateVisibility) then
				child.bar.updateVisibility(child.bar, child:GetAttribute("state-current"))
			end
		end

		anchor.anchoredBar = nil
	end
end

local function updateAnchorChild(anchor, bar, flyoutDock)

	if (not bar and anchor.config.anchoredBar) then
		bar = M.BarIndexByName[anchor.config.anchoredBar]
	end

	if (bar and bar.handler) then

		local child = bar.handler

		if (not flyoutDock) then
			anchor:SetParent("UIParent")
		end

		if (anchor.anchoredBar or anchor.flyoutDock) then
			removeAnchorChild(anchor, flyoutDock)
		end

		if (anchor.config.clickAnchor) then

			anchor:SetAttribute("click-show", "hide")
			anchor:WrapScript(anchor, "OnClick", [[

							local update = true

							if (self:GetAttribute("flyoutdock")) then
								if (button ~= "RightButton") then update = false end
							end

							if (update) then

								if (self:GetAttribute("click-show") == "hide") then
									self:SetAttribute("click-show", "show")
								else
									self:SetAttribute("click-show", "hide")
								end

								control:ChildUpdate("onclick", self:GetAttribute("click-show"))
							end

							]])

			child:SetAttribute("timedelay", tonumber(anchor.config.anchorDelay) or 0)
			child:SetAttribute("_childupdate-onclick", [[ if (message == "show") then self:Show() else self:Hide() end ]] )

			child:SetAttribute("isBarChild", nil)
			child:SetAttribute("isAnchorChild", true)

			child:SetParent(anchor)

			if (flyoutDock) then

				anchor:SetAttribute("click-show", "show")
				child:WrapScript(child, "OnShow", [[
								if (self:GetAttribute("timedelay")) then
									self:RegisterAutoHide(self:GetAttribute("timedelay"))
								else
									self:UnregisterAutoHide()
								end
				]])
				child:WrapScript(child, "OnHide", [[ self:GetParent():SetAttribute("click-show", "hide") self:UnregisterAutoHide() ]])

				anchor.anchoredBar = nil
			else
				child:Hide()
				anchor.anchoredBar = child
			end


		elseif (anchor.config.mouseAnchor) then

			anchor:WrapScript(anchor, "OnEnter", [[ control:ChildUpdate("onmouse", "enter") ]])
			anchor:WrapScript(anchor, "OnLeave", [[ if (not self:IsUnderMouse(true)) then control:ChildUpdate("onmouse", "leave") end ]])

			child.oldparent = child:GetParent()

			child:SetAttribute("timedelay", tonumber(anchor.config.anchorDelay) or 0)
			child:SetAttribute("_childupdate-onmouse", [[ if (message == "enter") then self:Show() elseif (message == "leave") then self:Hide() end ]] )

			child:SetAttribute("isBarChild", nil)
			child:SetAttribute("isAnchorChild", true)

			child:WrapScript(child, "OnShow", [[
							if (self:GetAttribute("timedelay")) then
								self:RegisterAutoHide(self:GetAttribute("timedelay"))
							else
								self:UnregisterAutoHide()
							end
							]])

			child:WrapScript(child, "OnHide", [[ self:UnregisterAutoHide() ]])

			child:SetParent(anchor)

			if (flyoutDock) then
				anchor.anchoredBar = nil
			else
				child:Hide()
				anchor.anchoredBar = child
			end
		end
	end
end

function M.UpdateAnchor(anchor, bar, flyoutDock, init, stored, remove)

	if (remove) then
		removeAnchorChild(anchor, flyoutDock)
	end

	if (init and not anchor.config.anchoredBar and not anchor.config.flyoutDock) then
		return
	elseif (not anchor.config.anchoredBar and not anchor.config.flyoutDock) then
		removeAnchorChild(anchor, flyoutDock)
	elseif (anchor.config.anchoredBar or anchor.config.flyoutDock) then
		updateAnchorChild(anchor, bar, flyoutDock)
	end
end
