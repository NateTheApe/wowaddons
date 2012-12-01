--Shared CDs (can also be used to rename cds)
local _, me = ...                                 --Includes all functions and variables

me.P={}
me.P.SharedCDs = {
	--<<ALCHEMY>>--
	--MOP
	[114780] = me.L["transmute"], --Transmute: Living Steel
	--Cata
	[80244] = me.L["transmute"], --Transmute: Pyrium Bar
	[78866] = me.L["transmute"], --Transmute: Living Elements
	--WotLk
	[66659] = me.L["transmute"], --Transmute: Cardinal Ruby
	[66660] = me.L["transmute"], --Transmute: King's Amber
	[66663] = me.L["transmute"], --Transmute: Majestic Zircon
	[66658] = me.L["transmute"], --Transmute: Ametrine
	[66662] = me.L["transmute"], --Transmute: Dreadstone
	[66664] = me.L["transmute"], --Transmute: Eye of Zul
	[53781] = me.L["transmute"], --Transmute: Eternal Earth to Air
	[53782] = me.L["transmute"],
	[53775] = me.L["transmute"],
	[53774] = me.L["transmute"],
	[53773] = me.L["transmute"],
	[53771] = me.L["transmute"],
	[53777] = me.L["transmute"],
	[53776] = me.L["transmute"],
	[53779] = me.L["transmute"],
	[53780] = me.L["transmute"],
	[53784] = me.L["transmute"],
	[53783] = me.L["transmute"],
	--BC
	[28585] = me.L["transmute"], --Transmute: Primal Earth to Life
	[28583] = me.L["transmute"],
	[28584] = me.L["transmute"],
	[28582] = me.L["transmute"],
	[28580] = me.L["transmute"],
	[28581] = me.L["transmute"],
	[28567] = me.L["transmute"],
	[28568] = me.L["transmute"],
	[28566] = me.L["transmute"],
	[28569] = me.L["transmute"],
	--Classic 
	[11479] = me.L["transmute"], --Transmute: Iron to Gold
	[11480] = me.L["transmute"], --Transmute: Mithril to Truesilver
	--<<Juwelcrafting>>--
	[131593] = me.L["pandaria_research"],
	[131695] = me.L["pandaria_research"],
	[131690] = me.L["pandaria_research"],
	[131688] = me.L["pandaria_research"],
	[131691] = me.L["pandaria_research"],
	[131686] = me.L["pandaria_research"],
}

for id, name in pairs(me.P.SharedCDs) do
	if GetSpellInfo(id) then 			--check if spell exists
		me.sharedcds[GetSpellInfo(id)] = name
	end
end