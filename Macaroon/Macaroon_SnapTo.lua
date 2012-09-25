﻿--Macaroon, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

--SnapTo code is a modified version of FlyPaper by Tuller

local M = Macaroon

M.SnapTo = {}

local find = string.find
local abs = math.abs

local function frameIsDependentOnFrame(frame, otherFrame)

	if (frame and otherFrame) then

		if (frame == otherFrame) then return true end

		local points = frame:GetNumPoints()

		for i=1,points do
			local parent = select(2, frame:GetPoint(i))
			if (frameIsDependentOnFrame(parent, otherFrame)) then return true end
		end
	end
end

local function canAttach(frame, otherFrame)

	if not(frame and otherFrame) then
		return
	elseif (frame:GetNumPoints() == 0 or otherFrame:GetNumPoints() == 0) then
		return
	elseif (frame:GetWidth() == 0 or frame:GetHeight() == 0 or otherFrame:GetWidth() == 0 or otherFrame:GetHeight() == 0) then
		return
	elseif (frameIsDependentOnFrame(otherFrame, frame)) then
		return
	end

	return true
end


--[[ Attachment Functions ]]--

local function attachToTop(frame, otherFrame, distLeft, distRight, distCenter, offset)

	frame:ClearAllPoints()

	if (distLeft < distCenter and distLeft < distRight) then

		frame:SetPoint("BOTTOMLEFT", otherFrame, "TOPLEFT", 0, offset); return "TL"

	elseif (distRight < distCenter and distRight < distLeft) then

		frame:SetPoint("BOTTOMRIGHT", otherFrame, "TOPRIGHT", 0, offset); return "TR"
	else
		frame:SetPoint("BOTTOM", otherFrame, "TOP", 0, offset); return "TC"
	end
end

local function attachToBottom(frame, otherFrame, distLeft, distRight, distCenter, offset)

	frame:ClearAllPoints()

	if (distLeft < distCenter and distLeft < distRight) then

		frame:SetPoint("TOPLEFT", otherFrame, "BOTTOMLEFT", 0, -offset); return "BL"

	elseif (distRight < distCenter and distRight < distLeft) then

		frame:SetPoint("TOPRIGHT", otherFrame, "BOTTOMRIGHT", 0, -offset); return "BR"

	else
		frame:SetPoint("TOP", otherFrame, "BOTTOM", 0, -offset); return "BC"
	end
end

local function attachToLeft(frame, otherFrame, distTop, distBottom, distCenter, offset)

	frame:ClearAllPoints()

	if (distBottom < distTop and distBottom < distCenter) then

		frame:SetPoint("BOTTOMRIGHT", otherFrame, "BOTTOMLEFT", -offset, 0); return "LB"

	elseif (distTop < distBottom and distTop < distCenter) then

		frame:SetPoint("TOPRIGHT", otherFrame, "TOPLEFT", -offset, 0); return "LT"

	else
		frame:SetPoint("RIGHT", otherFrame, "LEFT", -offset, 0); return "LC"
	end
end

local function attachToRight(frame, otherFrame, distTop, distBottom, distCenter, offset)

	frame:ClearAllPoints()

	if (distBottom < distTop and distBottom < distCenter) then

		frame:SetPoint("BOTTOMLEFT", otherFrame, "BOTTOMRIGHT", offset, 0); return "RB"

	elseif (distTop < distBottom and distTop < distCenter) then

		frame:SetPoint("TOPLEFT", otherFrame, "TOPRIGHT", offset, 0); return "RT"

	else
		frame:SetPoint("LEFT", otherFrame, "RIGHT", offset, 0); return "RC"
	end
end

local function attachToCenter(frame, otherFrame)

	frame:ClearAllPoints()

	frame:SetPoint("CENTER", otherFrame, "CENTER", 0, 0); return "CT"
end


--[[ Usable Functions ]]--


function M.SnapTo.StickToEdge(self)

	local point, x, y, changed = M.GetPosition(self)
	local w, h, rTol = self:GetWidth()/2, self:GetHeight()/2, MacaroonSavedState.snapToTol

	local function calcX(opt)
		if (opt == 1) then if (x <= w+rTol) then x = w; changed = true end
		elseif (opt == 2) then if (x >= -(w+rTol)) then x = -(w); changed = true end
		elseif (opt == 3) then if (abs(x) <= rTol) then x = 0; changed = true end
		end
	end

	local function calcY(opt)
		if (opt == 1) then if (y <= h+rTol) then y = h; changed = true end
		elseif (opt == 2) then if (y >= -(h+rTol)) then y = -(h); changed = true end
		elseif (opt == 3) then if (abs(y) <= rTol) then y = 0; changed = true end
		end
	end

	if (find(point, "CENTER")) then	calcX(3); calcY(3) end
	if (find(point, "LEFT")) then calcX(1); calcY(3) end
	if (find(point, "RIGHT")) then calcX(2); calcY(3) end
	if (find(point, "BOTTOM")) then	calcX(3); calcY(1) end
	if (find(point, "TOP")) then calcX(3); calcY(2) end

	if (changed) then
		self.config.point = point; self.config.x = x; self.config.y = y
		M.SetPosition(self)
	end
end

function M.SnapTo.Stick(frame, otherFrame, tolerance, xOff, yOff)

	local xOff, yOff = xOff or 0, yOff or 0

	if (not canAttach(frame, otherFrame)) then return end

	local left, right, top, bottom = frame:GetLeft(), frame:GetRight(), frame:GetTop(), frame:GetBottom()
	local centerX, centerY = frame:GetCenter()

	if (left and right and top and bottom and centerX) then

		local oScale = otherFrame:GetScale()

		left = left/oScale; right = right/oScale; top = top/oScale; bottom = bottom/oScale

		centerX = centerX/oScale; centerY = centerY/oScale

	else return end


	local oLeft, oRight, oTop, oBottom = otherFrame:GetLeft(), otherFrame:GetRight(), otherFrame:GetTop(), otherFrame:GetBottom()
	local oCenterX, oCenterY = otherFrame:GetCenter()

	if (oLeft and oRight and oTop and oBottom and oCenterX) then

		local scale = frame:GetScale()

		oLeft = oLeft/scale; oRight = oRight/scale; oTop = oTop/scale; oBottom = oBottom/scale

		oCenterX = oCenterX/scale; oCenterY = oCenterY/scale

	else return end

	if ((oLeft - tolerance <= left and oRight + tolerance >= right) or (left - tolerance <= oLeft and right + tolerance >= oRight)) then

		local distCenter, distLeft, distRight = abs(oCenterX - centerX), abs(oLeft - left), abs(right - oRight)

		if (abs(oTop - bottom) <= tolerance) then
			return attachToTop(frame, otherFrame, distLeft, distRight, distCenter, yOff)
		elseif abs(oBottom - top) <= tolerance then
			return attachToBottom(frame, otherFrame, distLeft, distRight, distCenter, yOff)
		end
	end

	if ((oTop + tolerance >= top and oBottom - tolerance <= bottom) or (top + tolerance >= oTop and bottom - tolerance <= oBottom)) then

		local distCenter, distTop, distBottom = abs(oCenterY - centerY), abs(oTop - top), abs(oBottom - bottom)

		if (abs(oLeft - right) <= tolerance) then
			return attachToLeft(frame, otherFrame, distTop, distBottom, distCenter, xOff)
		end

		if (abs(oRight - left) <= tolerance) then
			return attachToRight(frame, otherFrame, distTop, distBottom, distCenter, xOff)
		end
	end

	if (oCenterX > centerX - tolerance/2 and oCenterX < centerX + tolerance/2 and oCenterY > centerY - tolerance/2 and oCenterY < centerY + tolerance/2) then
		return attachToCenter(frame, otherFrame)
	end
end

function M.SnapTo.StickToPoint(frame, otherFrame, point, xOff, yOff)

	local xOff, yOff = xOff or 0, yOff or 0

	if (not (point and canAttach(frame, otherFrame))) then return end

	frame:ClearAllPoints()

	if (point == "TL") then
		frame:SetPoint("BOTTOMLEFT", otherFrame, "TOPLEFT", 0, yOff); return point
	elseif (point == "TC") then
		frame:SetPoint("BOTTOM", otherFrame, "TOP", 0, yOff); return point
	elseif (point == "TR") then
		frame:SetPoint("BOTTOMRIGHT", otherFrame, "TOPRIGHT", 0, yOff);	return point
	end

	if (point == "BL") then
		frame:SetPoint("TOPLEFT", otherFrame, "BOTTOMLEFT", 0, -yOff); return point
	elseif (point == "BC") then
		frame:SetPoint("TOP", otherFrame, "BOTTOM", 0, -yOff); return point
	elseif (point == "BR") then
		frame:SetPoint("TOPRIGHT", otherFrame, "BOTTOMRIGHT", 0, -yOff); return point
	end

	if (point == "LB") then
		frame:SetPoint("BOTTOMRIGHT", otherFrame, "BOTTOMLEFT", -xOff, 0); return point
	elseif (point == "LC") then
		frame:SetPoint("RIGHT", otherFrame, "LEFT", -xOff, 0); return point
	elseif (point == "LT") then
		frame:SetPoint("TOPRIGHT", otherFrame, "TOPLEFT", -xOff, 0); return point
	end

	if (point == "RB") then
		frame:SetPoint("BOTTOMLEFT", otherFrame, "BOTTOMRIGHT", xOff, 0); return point
	elseif (point == "RC") then
		frame:SetPoint("LEFT", otherFrame, "RIGHT", xOff, 0); return point
	elseif (point == "RT") then
		frame:SetPoint("TOPLEFT", otherFrame, "TOPRIGHT", xOff, 0); return point
	end

	if (point == "CT") then
		frame:SetPoint("CENTER", otherFrame, "CENTER", 0, 0); return point
	end
end
