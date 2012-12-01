-- translation notice : don't change the keys of tables or it won't work anymore (the text within the [ ]), the color coding part mustn't be changed either (|cff00ffff and |r).

-------------------------------
-- table for chat report settings, no problem changing the text lenght as it's outputted to chat frame
CombuMBTrackerLocEN = {["lockon"] = "|cff00ffffMageBombTracker locked|r",
			["lockoff"] = "|cff00ffffMageBombTracker unlocked|r",
			["reporton"] = "|cff00ffffMageBombTracker status report enabled|r",
			["lbon"] = "|cff00ffffEarly bomb refresh mode enabled|r",
			["lboff"] = "|cff00ffffEarly bomb refresh mode disabled|r",
			["fson"] = "|cff00ffffFlamestrike tracker enabled|r",
			["fsoff"] = "|cff00ffffFlamestrike tracker disabled|r",
			["lbtrackon"] = "|cff00ffffMageBombTracker enabled|r",
			["lbtrackoff"] = "|cff00ffffMageBombTracker disabled|r",
			["reset"] = "|cff00ffffMageBombTracker Savedvariables have been resetted.|r",
			["startup"] = "|cff00ffffMageBombTracker is loaded. Interface Panel -> Addons for Config.|r",
			["lbrefresh"] = "|cffff0000 -- You refreshed your bomb on |cffffffff%s |cffff0000too early. --|r",
			["lbmiss"] = "|cffff00ff -- Bomb cast on |cffffffff%s |cffff00ffmissed !! --",
			["lbreport"] = "|cffff0000 -- Early bomb refresh for this fight : |cffffffff%d |cffff0000--|r",
			["slashcomm"] = "|cff00ffffOpening MageBombTracker config panel|r",
			}
			

-------------------------------
-- table for option panel localisation, try to stick to the lenght as it could overflow if bigger
CombuMBTrackerOptLocEN = {
	["CombuMBTrackerScaleSlider"] = "Size",
	["CombuMBTrackerlockButton"] = "Lock MageBombTracker",
	["CombuMBTrackerrefreshButton"] = "Early/Missed Bomb warning",
	["CombuMBTrackerchatButton"] = "Config messages in chat",
	["CombuMBTrackerButton"] = "Enable MageBombTracker",
	["CombuMBTrackertargetButton"] = "Current target marker",
	["CombuMBTrackerAutohideInfo"] = "AutoHide mode :",
	["CombuMBTrackerFontInfo"] = "Text Font :",
	["CombuMBTrackerBorderInfo"] = "Frame border :",
	["CombuMBTrackerDirectionInfo"] = "Direction :",
	["CombuMBTrackerBackgroundInfo"] = "Background :",
	["CombuMBTrackerTextureInfo"] = "Texture :",
    ["CombuMBTrackerEdgeSizeSlider"] = "Edge Size",
	["CombuMBTrackerresetButton"] = "Reset SavedVariables",
	["CombuMBTrackerFlamestrikeButton"] = "Enable Flamestrike tracker",
	["CombuMBTrackerTileSizeSlider"] = "Tile Size",
	["CombuMBTrackerTileButton"] = "Tile background",
	["CombuMBTrackerInsetsSlider"] = "Bg Insets",
	["CombuMBTrackerbarcolornormal"] = "Bar color (normal)",
	["CombuMBTrackerbarcolorwarning"] = "Bar color (warning)",
	["CombuMBTrackerbgcolornormal"] = "Background color",
	["CombuMBTrackerLanguageInfo"] = "Language :",
	["CombuMBTrackeredgecolornormal"] = "Border color",
	}


-------------------------------
-- table for Autohide dropdown
CombuMBTrackerAutohideListEN = {
   "No Autohide",
   "Autohide out of Combat",
   "Autohide when no bomb",
}

-------------------------------
-- table for text within frame, try to stick to the lenght as it could overflow if bigger
CombuMBTrackerLabelEN = {["flamestrike"] = "Flamestrike",
				["blastwave"] = "Blastwave FS",
				}