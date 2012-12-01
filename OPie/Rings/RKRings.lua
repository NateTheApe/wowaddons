local RingKeeper = OneRingLib and OneRingLib.ext and OneRingLib.ext.RingKeeper
if not (RingKeeper and RingKeeper.SetRing) then return end

RingKeeper:SetRing("DruidShift", {
	{c="cc66ff", id=24858, ux="k"}, -- Moonkin
	{c="ff4c4c", id=5487, ux="b"}, -- Bear
	{c="ffff00", id=768, ux="c"}, -- Cat
	{c="33b2ff", id="#rkrequire {{spell:40120/33943/1066/783}}\n/cancelform [noflyable]\n/cast [flyable,outdoors,nocombat,noswimming,nomod][flying] {{spell:40120/33943}}; [swimming] {{spell:1066}}; [nocombat,outdoors,nomod:alt] {{mount:ground}}; [outdoors] {{spell:783}}", ux="f"}, -- Travel
	{c="66BFFF", id=106731, ux="i"}, -- Incarnation
	name="Shapeshifts", hotkey="PRIMARY", limit="DRUID", ux="OPCDS"
});
RingKeeper:SetRing("DruidUtility", {
	{c="117aed", id=29166, ux="i"}, -- innervate
	{c="dd002b", id="/cast [combat][mod] {{spell:20484}}; {{spell:50769}}", ux="r"}, -- rebirth/revive
	{c="fe83f8", id=1126, ux="m"}, -- mark
	{c="e8a50f", id=22812, ux="b"}, -- bark
	{c="9919e5", id="/cast [combat][mod] {{spell:88423/2782}}; {{spell:18960}}", ux="p"}, -- moonglade/cleanse
	{c="99C4FF", id=740, ux="t"}, -- tranq
	name="Utility", hotkey="[noform:1/3] SECONDARY; ALT-SECONDARY", limit="DRUID", ux="OPCDU"
});
RingKeeper:SetRing("DruidFeral", {
	{c="fe1200", id=50334, ux="k"}, -- berserk
	{c="FF6A4D", id="/cast [noform:1] {{spell:5217}}; {{spell:5229/22842}}", ux="e"}, -- enrage/frenzied / tiger's fury
	{c="fe650b", id="/cast [form:1] {{spell:77761}}; {{spell:77764}}", ux="r"}, -- stampeding roar
	{c="fec200", id=106839, ux="s"}, -- skull bash
	{c="fe7b00", id=22812, ux="b"}, -- barkskin
	{c="7300fe", id=61336, ux="i"}, -- survival instincts
	{c="d0170a", id=22842, us="f", skipSpecs=" 103 102 105 DRUID "}, -- frenzied regen
	{c="fe8644", id=102401, ux="c"}, -- feral charge
	{c="66CCFF", id="/cast [nomod,@player][mod,@none] {{spell:5185}}", skipSpecs=" 102 104 105 DRUID ", ux="h"}, -- HT
	name="Feral", hotkey="[form:1/3] SECONDARY; ALT-SECONDARY", limit="DRUID", ux="OPCDF"
});

RingKeeper:SetRing("HunterAspects", {
	{c="35b58e", id=13165, ux="h"}, -- hawk
	{c="ba6802", id=5118, ux="c"}, -- cheetah
	{c="ffb200", id=13159, ux="p"}, -- pack
	{c="96ff14", id=20043, ux="w"}, -- wild
	{c="d16a0d", id=82661, ux="f"}, -- fox
	{c="7dbffb", id=781, ux="d"}, -- disengage
	{c="3de4c6", id=5384, ux="g"}, -- feign
	{c="dab692", id="#rkrequire {{spell:883}}\n/cast [@pet,noexists,nomod] {{spell:883}}; [@pet,dead][@pet,noexists] {{spell:982}}; [@pet,help,nomod] {{spell:136}}; [@pet] {{spell:2641}}", ux="e"},
	name="Aspects", hotkey="PRIMARY", limit="HUNTER", ux="OPCHA"
});
RingKeeper:SetRing("HunterTraps", {
	{c="f37020", id=13813, ux="e"}, -- explosive
	{c="c83b10", id=13795, ux="i"}, -- immolation
	{c="6e65fc", id=1499, ux="f"}, -- freezing
	{c="61c0ff", id=13809, ux="c"}, -- ice
	{c="4ee854", id=34600, ux="s"}, -- snake
	{c="ca0902", id=77769, ux="l"}, -- launcher
	name="Traps", hotkey="ALT-SECONDARY", limit="HUNTER", ux="OPCHT"
});
RingKeeper:SetRing("HunterShots", {
	{c="5c8ce6", id=20736, ux="d"}, -- distract
	{c="d0a3de", id=19801, ux="t"}, -- tranq
	{c="d73240", id=53351, ux="k"}, -- kill
	{c="bf41aa", id=2643, ux="m"}, -- multi
	{c="d81c1a", id=1130, ux="a"}, -- mark
	name="Shots", hotkey="SECONDARY", limit="HUNTER", ux="OPCHS"
});

RingKeeper:SetRing("MageCombat", {
	{c="82d1ff", id=45438, ux="i"}, -- block
	{c="fffab2", id=12043, ux="p"}, -- pom
	{c="3c5eff", id=30449, ux="s"}, -- spellsteal
	{c="2fa4ff", id=55342, ux="m"}, -- mirror
	{c="de99ff", id=12051, ux="e"}, -- evo
	{c="1c88ff", id=12042, ux="a"}, -- ap
	name="Combat", limit="MAGE", hotkey="PRIMARY", ux="OPCMC"
})
RingKeeper:SetRing("MageTools", {
	{c="55b3ff", id=1459, ux="i"}, -- int
	{c="b55eff", id=43987, ux="r"}, -- ritual
	{c="ff9332", id=42955, ux="f"}, -- food
	{c="bd4bff", id=759, ux="g"}, -- gem
	{"ring", "MageArmor", onlyNonEmpty=true, ux="a"},
	name="Utility", limit="MAGE", hotkey="SECONDARY", ux="OPCMT"
})
RingKeeper:SetRing("MageArmor", {
	{c="f97200", id=30482, ux="f"}, -- molten
	{c="3377ff", id=7302, ux="i"}, -- ice
	{c="7fe5e5", id=6117, mx="a"}, -- mage
	name="Armor spells", limit="MAGE", internal=true, ux="OPCMA"
});
do -- MageTravel
	local m = "/cast [mod] {{spell:%s}}; {{spell:%s}}";
	RingKeeper:SetRing("MageTravel", {
		{c="77e0c4", id=m:format("132620/132626", "132621/132627"), ux="v"}, -- Vale of Eternal Blossoms
		{c="64bbce", id=m:format(53142, 53140), ux="r"}, -- Dalaran
		{c="77e0c4", id=m:format("35717/33691", 33690), ux="s"}, -- Shattrath
		{c="8cb73d", id=m:format(10059, 3561), ux="w"}, -- Stormwind
		{c="a826e0", id=m:format(11419, 3565), ux="d"}, -- Darnassus
		{c="70a5b2", id=m:format(11420, 3566), ux="t"}, -- Thunder Bluff
		{c="77e51e", id=m:format(11418, 3563), ux="u"}, -- Undercity
		{c="68a8d1", id=m:format(11416, 3562), ux="i"}, -- Ironforge
		{c="e87c21", id=m:format(11417, 3567), ux="o"}, -- Orgrimmar
		{c="426ba5", id=m:format(49360, 49359), ux="m"}, -- Theramore
		{c="72721e", id=m:format(49361, 49358), ux="n"}, -- Stonard
		{c="7cc6f9", id=m:format(32267, 32272), ux="l"}, -- Silvermoon
		{c="e89bd1", id=m:format(32266, 32271), ux="x"}, -- Exodar
		{c="64bbce", id=m:format(120146, 120145), ux="a"}, -- Ancient Dalaran
		{c="c33716", id=m:format("88346/88345", "88344/88342"), ux="b"}, -- Tol Barad
	  name="Portals and Teleports", hotkey="ALT-G", limit="MAGE", ux="OPCMP"
	});
end

RingKeeper:SetRing("PaladinAuras", {
	{"ring", "PaladinSeal", onlyNonEmpty=true, ux="e"},
	{"ring", "PaladinBlessing", onlyNonEmpty=true, ux="b"},
	{c="eb8129", id=25780, ux="f"}, -- righteous fury
	name="Paladin Buffs", hotkey="PRIMARY", limit="PALADIN", ux="OPCPA"
});
RingKeeper:SetRing("PaladinSeal", {
	{c="2aa5e8", id=20154, ux="r"}, -- righteousness
	{c="fff697", id=31801, ux="t"}, -- truth
	{c="860106", id=20164, ux="j"}, -- justice
	{c="d9b084", id=20165, ux="i"}, -- insight
	name="Seals", limit="PALADIN", internal=true, ux="OPCPS"
});
RingKeeper:SetRing("PaladinBlessing", {
	{c="6E49E6", id=20217, ux="k"}, -- kings
	{c="dab13b", id=19740, ux="m"}, -- might
	name="Blessings", limit="PALADIN", internal=true, ux="OPCPB"
});
RingKeeper:SetRing("PaladinTools", {
	{c="E67E9D", id=853, ux="h"}, -- hammer
	{c="fcdb70", id=85673, ux="g"}, -- glory
	{c="ed8f1b", id=498, ux="p"}, -- divine protection
	{c="ffea4e", id=54428, ux="l"}, -- divine plea
	{c="ff1c5c", id=31884, ux="a"}, -- avenging wrath
	{c="5A55F2", id=1022, ux="t"}, -- hand of protection
	{c="be2c13", id=1044, ux="f"}, -- hand of freedom
	{c="e9d68a", id=1038, ux="s"}, -- hand of salvation
	{c="E6CC7E", id=62124, ux="r"}, -- hand of reckoning
	{c="d47c12", id=26573, ux="c"}, -- consecration
	name="Utility", limit="PALADIN", hotkey="SECONDARY", ux="OPCPT"
});
RingKeeper:SetRing("ShamanWeapons", {
	{c="B8DEE6", id=8232, ux="w"}, -- windfury
	{c="D94141", id=8024, ux="f"}, -- flametongue
	{c="D9AC52", id=8017, ux="r"}, -- rockbiter
	{c="52ACD9", id=8033, ux="b"}, -- frostbrand
	{c="52D988", id=51730, ux="e"}, -- earthliving
	name="Weapon Buffs", hotkey="PRIMARY", limit="SHAMAN", ux="OPCSW"
});
RingKeeper:SetRing("WarlockDemons", {
	{c="ec3923", id=30146, ux="f"}, -- felguard
	{c="771ed8", id=697, ux="v"}, -- void
	{c="f7380f", id=688, ux="i"}, -- imp
	{c="ff33b2", id=712, ux="s"}, -- succubus
	{c="1966cc", id=691, ux="h"}, -- felhunter
	name="Warlock Demons", limit="WARLOCK", hotkey="PRIMARY", ux="OPCLD"
});
RingKeeper:SetRing("WarlockStones", {
	{c="66ff0c", id=6201, ux="h"}, -- health
	{c="b20ce5", id=693, ux="s"}, -- soul
	{c="d872ff", id=29893, ux="r"}, -- ritual
	name="Stones", hotkey="SECONDARY", limit="WARLOCK", ux="OPCLS"
});

RingKeeper:SetRing("WarriorStances", {
	{c="ff4c4c", id=2457, ux="a"},
	{c="4c4cff", id=71, ux="d"},
	{c="ffcc4c", id=2458, ux="e"},
	name="Stances", hotkey="PRIMARY", limit="WARRIOR", ux="OPCWS"
});

RingKeeper:SetRing("DeathKnightPresence", {
	{c="52ff5a", id="/cast [help,dead] {{spell:61999}}; [nopet,nomounted][@pet,dead] {{spell:46584}}; [@pet,nodead,exists][nomod] {{spell:47541}}; [mod] {{spell:48743}}", ux="p"}, -- ghoul
	{c="e54c19", id=48263, ux="b"}, -- blood
	{c="1999e5", id=48266, ux="f"}, -- frost
	{c="4ce519", id=48265, ux="u"}, -- unholy
	{c="a93ae8", id=50977, ux="g"}, -- gate
	{c="E8C682", id="/cast [flyable,outdoors][flying] {{spell:54729}}; {{spell:48778}}", ux="m"},
	{c="63eaff", id=3714, ux="o"}, -- path of frost
	name="Presences", hotkey="PRIMARY", limit="DEATHKNIGHT", ux="OPCDP"
});
RingKeeper:SetRing("DKCombat", {
	{c="fff4b2", id=57330, ux="h"}, -- horn
	{c="5891ea", id=48792, ux="f"}, -- fortitude
	{c="bcf800", id=48707, ux="s"}, -- shell
	{c="3d63cc", id=51052, ux="z"}, -- Zone
	{c="b7d271", id=49222, ux="i"}, -- shield
	{c="b31500", id=55233, ux="b"}, -- blood
	{c="aef1ff", id=51271, ux="p"}, -- pillar of frost
	{c="d0d0d0", id=49039, ux="l"}, -- lich
	name="Combat", hotkey="SECONDARY", limit="DEATHKNIGHT", ux="OPCDC"
});

RingKeeper:SetRing("ChalPaths", {
	{id=131204, c="0cff8d", ux="j"},
	{id=131205, c="d99d44", ux="br"},
	{id=131206, c="ffde00", ux="sp"},
	{id=131222, c="CC6729", ux="mk"},
	{id=131225, c="8d6bff", ux="ss"},
	{id=131231, c="ff4c20", ux="cb"},
	{id=131229, c="b7d9ff", ux="sm"},
	{id=131232, c="0090ff", ux="n"},
	{id=131228, c="D4E2FF", ux="b"},
	name="Challenger's Paths", ux="OPCCGP"
});

RingKeeper:SetRing("CommonTrades", {
	{c="d8d1ad", id="/cast {{spell:3908/51309}}", ux="t"}, -- tailoring
	{c="b57f49", id="/cast {{spell:2108/51302}}", ux="l"}, -- leatherworking
	{c="f4aa0f", id="/cast {{spell:2018/51300}}", ux="b"}, -- blacksmithing
	{c="3319e5", id="/cast [mod] {{spell:31252}}; {{spell:25229/51311}};", ux="j"}, -- jewelcrafting/prospecting
	{c="f4ef28", id="/cast [mod] {{spell:13262}}; {{spell:7411/51313}}", ux="e"}, -- enchanting/disenchanting
	{c="11ba9b", id="/cast {{spell:2259/51304}}", ux="a"}, -- alchemy
	{c="c13f0f", id="/cast [mod] {{spell:818}}; {{spell:2550/51296}}", ux="c"}, -- cooking/campfire
	{c="85de60", id="/cast [mod] {{spell:51005}}; {{spell:45357/45363}}", ux="i"}, -- inscription/milling
	{c="bf2626", id="/cast {{spell:3273/45542}}", ux="f"}, -- first aid
	{c="e6b725", id="/cast {{spell:4036/51306}}", ux="g"}, -- engineering
	{c="ffce4d", id="/cast [mod] {{spell:80451}}; {{spell:78670/89722}}", ux="r"},
	{c="335dcb", id=53428, ux="u"}, -- runeforging
	{c="ffac3d", id=2656, ux="m"}, -- smelting
	name="Trade Skills", hotkey="ALT-T", ux="OPCCT"
});
RingKeeper:SetRing("WorldMarkers", {
	{"worldmark", 1, c="3333ff", ux="b"}, -- blue
	{"worldmark", 2, c="33ff33", ux="g"}, -- green
	{"worldmark", 3, c="ff4cff", ux="p"}, -- purple
	{"worldmark", 4, c="ff1919", ux="r"}, -- red
	{"worldmark", 5, c="ffff00", ux="y"}, -- yellow
	{"worldmark", 6, c="ccd8e5", ux="c"}, -- clear
	name="World Markers", hotkey="ALT-Y", ux="OPCWM"
});
RingKeeper:SetRing("RaidSymbols", {
	{"raidmark", 1, c="ffff00", ux="y"}, -- yellow star
	{"raidmark", 2, c="ff7f0c", ux="o"}, -- orange circle
	{"raidmark", 3, c="ff4cff", ux="p"}, -- purple diamond
	{"raidmark", 4, c="33ff33", ux="g"}, -- green triangle
	{"raidmark", 5, c="a5d6ff", ux="s"}, -- silver moon
	{"raidmark", 6, c="3333ff", ux="b"}, -- blue square
	{"raidmark", 7, c="ff1919", ux="r"}, -- red cross
	{"raidmark", 8, c="bcb299", ux="w"}, -- white skull
	name="Target Markers", hotkey="ALT-R", ux="OPCRS"
});