-- translation notice : don't change the keys of tables or it won't work anymore (the text within the [ ]), the color coding part mustn't be changed either (|cff00ffff and |r).

-------------------------------
-- table for chat report settings, no problem changing the text lenght as it's outputted to chat frame
CombuMBTrackerLocFR = {["lockon"] = "|cff00ffffMageBombTracker verrouillé|r",
			["lockoff"] = "|cff00ffffMageBombTracker déverrouillé|r",
			["reporton"] = "|cff00ffffRapport MageBombTracker actif|r",
			["lbon"] = "|cff00ffffAlertes bombes actives|r",
			["lboff"] = "|cff00ffffAlertes bombes inactives|r",
			["fson"] = "|cff00ffffMode Choc de flamme actif|r",
			["fsoff"] = "|cff00ffffMode Choc de flamme inactif|r",
			["lbtrackon"] = "|cff00ffffMageBombTracker actif|r",
			["lbtrackoff"] = "|cff00ffffMageBombTracker inactif|r",
			["reset"] = "|cff00ffffMageBombTracker Savedvariables remis � zero.|r",
			["startup"] = "|cff00ffffMageBombTracker est actif. Interface -> Addons pour Config.|r",
			["lbrefresh"] = "|cffff0000 -- Vouz avez rafraichi votre sur |cffffffff%s |cffff0000trop tot. --|r",
			["lbmiss"] = "|cffff00ff -- Bombe lancée sur |cffffffff%s |cffff00ff a raté !! --",
			["lbreport"] = "|cffff0000 -- Bombes rafraichies pour ce combat : |cffffffff%d |cffff0000--|r",
			["slashcomm"] = "|cff00ffffConfiguration de MageBombTracker|r",
			}
			

-------------------------------
-- table for option panel localisation, try to stick to the lenght as it could overflow if bigger
CombuMBTrackerOptLocFR = {
	["CombuMBTrackerScaleSlider"] = "Taille",
	["CombuMBTrackerlockButton"] = "Verrouille MageBombTracker",
	["CombuMBTrackerrefreshButton"] = "Alertes sur bombes",
	["CombuMBTrackerchatButton"] = "Messages de configuration",
	["CombuMBTrackerButton"] = "Active MageBombTracker",
	["CombuMBTrackertargetButton"] = "Marqueur de cible actuelle",
	["CombuMBTrackerAutohideInfo"] = "Masquage :",
	["CombuMBTrackerFontInfo"] = "Police de caractere :",
	["CombuMBTrackerBorderInfo"] = "Bordure de fenetre :",
	["CombuMBTrackerDirectionInfo"] = "Direction :",
	["CombuMBTrackerBackgroundInfo"] = "Fond de fenetre :",
	["CombuMBTrackerTextureInfo"] = "Texture :",
    ["CombuMBTrackerEdgeSizeSlider"] = "Taille de bordure",
	["CombuMBTrackerresetButton"] = "Reset des reglages",
	["CombuMBTrackerFlamestrikeButton"] = "Choc de flamme",
	["CombuMBTrackerTileSizeSlider"] = "Taille des tuiles",
	["CombuMBTrackerTileButton"] = "Tuillage du fond",
	["CombuMBTrackerInsetsSlider"] = "Retrait du fond",
	["CombuMBTrackerbarcolornormal"] = "Couleur des barres (normal)",
	["CombuMBTrackerbarcolorwarning"] = "Couleur des barres (alerte)",
	["CombuMBTrackerbgcolornormal"] = "Couleur du fond",
	["CombuMBTrackerLanguageInfo"] = "Language :",
	["CombuMBTrackeredgecolornormal"] = "Couleur des bordures",
	}


-------------------------------
-- table for Autohide dropdown
CombuMBTrackerAutohideListFR = {
   "Pas de masquage",
   "Masquage hors combat",
   "Masquage sans bombe active",
}

-------------------------------
-- table for text within frame, try to stick to the lenght as it could overflow if bigger
CombuMBTrackerLabelFR = {["flamestrike"] = "Choc de flamme",
				["blastwave"] = "Vague d'explosion",
				["nobomb"] = "-- no bomb --",
				}