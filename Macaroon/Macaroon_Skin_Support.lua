--Macaroon, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

local M = Macaroon

local groups, group, msq, SD, pew = {}
local gmatch = string.gmatch

local function createMSQ()

	if (LibStub) then

		msq = LibStub("Masque", true)

		if (msq) then
			msq:Register("Macaroon", M.MSQskinCallback, Macaroon)
		end
	end
end

function M.SkinBar(bar, parent)

	if (not SD.msqskin) then SD.msqskin = {} end

	if (not msq) then createMSQ() end

	if (msq) then

		group = bar.config.name

		if (not SD.msqskin[group] and parent and SD.msqskin[parent.config.name]) then
			SD.msqskin[group] = M.CopyTable(SD.msqskin[parent.config.name])
		elseif (not SD.msqskin[group]) then
			SD.msqskin[group] = {}
		end

		groups[group] = bar

		if (bar.config.buttonList) then

			for state, btnIDs in pairs(bar.config.buttonList) do

				for btnID in gmatch(btnIDs, "[^;]+") do

					button = _G[bar.btnType..btnID]

					if (button and not button.skinset) then

						if (button.bagelement) then

							local btnData = {
								Normal = button.normaltexture,
								Icon = button.icontexture,
								Count = button.count,
							}

							msq:Group("Macaroon", group):AddButton(button.bagelement, btnData)

						elseif (button.menuelement) then

							--local menuRatios = { w = 0.71, h = 0.95 }

							--button.menuelement.icontexture:SetDrawLayer("BACKGROUND")
							--button.menuelement.icontexture:SetTexCoord(-0.1, 1.1, 0.3, 1.07)
							--button.menuelement:SetWidth(button:GetWidth())
							--button.menuelement:SetHeight(button:GetHeight())
							--button.menuelement:SetHitRectInsets(0,0,0,0)

							--local btnData = {
							--	Normal = button.menuelement.normaltexture,
							--}

							--msq:Group("Macaroon", group):AddButton(button.menuelement, btnData)

						elseif (button.config.type == "macro" or
						        button.config.type == "action" or
						        button.config.type == "pet") then

							local btnData = {
								Normal = button.normaltexture,
								Icon = button.iconframeicon,
								Cooldown = button.iconframecooldown,
								HotKey = button.hotkey,
								Count = button.count,
								Name = button.name,
								Border = button.border,
								AutoCast = false,
							}

							msq:Group("Macaroon", group):AddButton(button, btnData)
						end

						button.skinset = true
					end
				end
			end
		end
	end
end

--Callback(arg, Group, SkinID, Gloss, Backdrop, Colors, Fonts).

function M.MSQskinCallback(arg, group, skinID, gloss, backdrop, colors, fonts)

	if (not group) then return end

	if (not SD.msqskin[group]) then SD.msqskin[group] = {} end

	SD.msqskin[group].Skin = skinID
	SD.msqskin[group].Gloss = gloss
	SD.msqskin[group].Backdrop = backdrop
	SD.msqskin[group].Colors = colors

	if (groups[group]) then

		local bar, skin, button = groups[group], msq:GetSkin(skinID)

		if (skin and skin.Normal.Texture ~= "Interface\\Buttons\\UI-Quickslot2") then

			bar.hasAction = false
			bar.noAction = false

		elseif (skin) then

			bar.hasAction = skins[skin].Normal.Texture
			bar.noAction = skins[skin].Normal.EmptyTexture
		end

		if (skin.Shape) then
			bar.msq_skin = skin.Shape:lower()
		end

		for state, btnIDs in pairs(bar.config.buttonList) do

			for btnID in gmatch(btnIDs, "[^;]+") do

				button = _G[bar.btnType..btnID]

				if (button and button.updateData) then
					button.updateData(button, bar, state)
				end
			end
		end
	end

	M.Save()
end

function M.UpdateSkinData()
	if (pew) then

		local bar

		for k,v in pairs(SD.msqskin) do

			bar = M.BarIndexByName[k]

			if (not bar or (bar and not bar.config.skinnable)) then
				SD.msqskin[k] = nil
			end
		end
	end
end

local function controlOnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ... == "Macaroon") then

		SD = MacaroonSavedState

		tinsert(M.UpdateFunctions, M.UpdateSkinData)

	elseif (event == "PLAYER_ENTERING_WORLD" and not pew) then

		pew = true

		M.UpdateSkinData()

	end
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", controlOnEvent)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
