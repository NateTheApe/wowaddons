local RingKeeper = OneRingLib and OneRingLib.ext and OneRingLib.ext.RingKeeper
if not (RingKeeper and RingKeeper.SetRing) then return end

RingKeeper:SetRing("DruidShift", {
	{id="#rkrequire {{spell:40120/33943/1066/783}}\n/cancelform [noflyable]\n/cast [flyable,outdoors,nocombat,noswimming,nomod][flying] {{spell:40120/33943}}; [swimming] {{spell:1066}}; [nocombat,outdoors,nomod:alt] {{mount:ground}}; [outdoors] {{spell:783}}", ux="f"}, -- Travel
	{c="c74cff", id=24858, ux="k"}, -- Moonkin
	{c="fff04d", id=768, ux="c"}, -- Cat
	{c="ff0000", id=5487, ux="b"}, -- Bear
	{id=106731, ux="i"}, -- Incarnation
	{id=110309, ux="s", show="[group]"}, -- Symbiosis
	name="Shapeshifts", hotkey="PRIMARY", limit="DRUID", ux="OPCDS"
});
RingKeeper:SetRing("DruidUtility", {
	{id=29166, ux="i"}, -- innervate
	{id="/cast [combat][mod] {{spell:20484}}; {{spell:50769}}", ux="r"}, -- rebirth/revive
	{id="/cast [help,noraid][@player] {{spell:1126}}", ux="m"}, -- mark
	{id=22812, ux="b"}, -- bark
	{id="/cast [combat][mod] {{spell:88423/2782}}; {{spell:18960}}", ux="p"}, -- moonglade/cleanse
	{id=740, ux="t"}, -- tranq
	name="Utility", hotkey="[noform:1/3] SECONDARY; ALT-SECONDARY", limit="DRUID", ux="OPCDU"
});
RingKeeper:SetRing("DruidFeral", {
	{id=50334, ux="k"}, -- berserk
	{id="/cast [noform:1] {{spell:5217}}; {{spell:5229/22842}}", ux="e"}, -- enrage/frenzied / tiger's fury
	{id="/cast [mod] {{spell:1850}}; [form:1] {{spell:77761}}; {{spell:77764}}", ux="r"}, -- dash / stampeding roar
	{id=106839, ux="s"}, -- skull bash
	{id=22812, ux="b"}, -- barkskin
	{id=61336, ux="i"}, -- survival instincts
	{id=22842, us="f", skipSpecs=" 103 102 105 DRUID "}, -- frenzied regen
	{id=102401, ux="c"}, -- feral charge
	{id="/cast [nomod,@player][mod,@none] {{spell:5185}}", skipSpecs=" 102 104 105 DRUID ", ux="h"}, -- HT
	name="Feral", hotkey="[form:1/3] SECONDARY; ALT-SECONDARY", limit="DRUID", ux="OPCDF"
});

RingKeeper:SetRing("HunterAspects", {
	{id=13165, ux="h"}, -- hawk
	{id=5118, ux="c"}, -- cheetah
	{id=13159, ux="p"}, -- pack
	{id=20043, ux="w"}, -- wild
	{id=82661, ux="f"}, -- fox
	{id=781, ux="d"}, -- disengage
	{id=5384, ux="g"}, -- feign
	{id="#rkrequire {{spell:883}}\n/cast [@pet,noexists,nomod] {{spell:883}}; [@pet,dead][@pet,noexists] {{spell:982}}; [@pet,help,nomod] {{spell:136}}; [@pet] {{spell:2641}}", ux="e"},
	name="Aspects", hotkey="PRIMARY", limit="HUNTER", ux="OPCHA"
});
RingKeeper:SetRing("HunterTraps", {
	{id=13813, ux="e"}, -- explosive
	{id=13795, ux="i"}, -- immolation
	{id=1499, ux="f"}, -- freezing
	{id=13809, ux="c"}, -- ice
	{id=34600, ux="s"}, -- snake
	{id=77769, ux="l"}, -- launcher
	name="Traps", hotkey="ALT-SECONDARY", limit="HUNTER", ux="OPCHT"
});
RingKeeper:SetRing("HunterShots", {
	{id=20736, ux="d"}, -- distract
	{id=19801, ux="t"}, -- tranq
	{id=53351, ux="k"}, -- kill
	{id=2643, ux="m"}, -- multi
	{id=1130, ux="a"}, -- mark
	name="Shots", hotkey="SECONDARY", limit="HUNTER", ux="OPCHS"
});

RingKeeper:SetRing("MageCombat", {
	{id=45438, ux="i"}, -- block
	{id=12043, ux="p"}, -- pom
	{id=30449, ux="s"}, -- spellsteal
	{id=55342, ux="m"}, -- mirror
	{id=12051, ux="e"}, -- evo
	{id=12042, ux="a"}, -- ap
	name="Combat", limit="MAGE", hotkey="PRIMARY", ux="OPCMC"
})
RingKeeper:SetRing("MageTools", {
	{id=1459, ux="i"}, -- int
	{id=43987, ux="r"}, -- ritual
	{id=42955, ux="f"}, -- food
	{id=759, ux="g"}, -- gem
	{"ring", "MageArmor", onlyNonEmpty=true, ux="a"},
	name="Utility", limit="MAGE", hotkey="SECONDARY", ux="OPCMT"
})
RingKeeper:SetRing("MageArmor", {
	{id=30482, ux="f"}, -- molten
	{id=7302, ux="i"}, -- ice
	{id=6117, mx="a"}, -- mage
	name="Armor spells", limit="MAGE", internal=true, ux="OPCMA"
});
do -- MageTravel
	local m = "/cast [mod] {{spell:%s}}; {{spell:%s}}";
	RingKeeper:SetRing("MageTravel", {
		{id=m:format("132620/132626", "132621/132627"), ux="v"}, -- Vale of Eternal Blossoms
		{id=m:format(53142, 53140), ux="r"}, -- Dalaran
		{id=m:format("35717/33691", 33690), ux="s"}, -- Shattrath
		{id=m:format(10059, 3561), ux="w"}, -- Stormwind
		{id=m:format(11419, 3565), ux="d"}, -- Darnassus
		{id=m:format(11420, 3566), ux="t"}, -- Thunder Bluff
		{id=m:format(11418, 3563), ux="u"}, -- Undercity
		{id=m:format(11416, 3562), ux="i"}, -- Ironforge
		{id=m:format(11417, 3567), ux="o"}, -- Orgrimmar
		{id=m:format(49360, 49359), ux="m"}, -- Theramore
		{id=m:format(49361, 49358), ux="n"}, -- Stonard
		{id=m:format(32267, 32272), ux="l"}, -- Silvermoon
		{id=m:format(32266, 32271), ux="x"}, -- Exodar
		{id=m:format(120146, 120145), ux="a"}, -- Ancient Dalaran
		{id=m:format("88346/88345", "88344/88342"), ux="b"}, -- Tol Barad
	  name="Portals and Teleports", hotkey="ALT-G", limit="MAGE", ux="OPCMP"
	});
end

RingKeeper:SetRing("PaladinAuras", {
	{"ring", "PaladinSeal", onlyNonEmpty=true, ux="e"},
	{"ring", "PaladinBlessing", onlyNonEmpty=true, ux="b"},
	{id=25780, ux="f"}, -- righteous fury
	name="Paladin Buffs", hotkey="PRIMARY", limit="PALADIN", ux="OPCPA"
});
RingKeeper:SetRing("PaladinSeal", {
	{id=20154, ux="r"}, -- righteousness
	{id=31801, ux="t"}, -- truth
	{c="902020", id=20164, ux="j"}, -- justice
	{id=20165, ux="i"}, -- insight
	name="Seals", limit="PALADIN", internal=true, ux="OPCPS"
});
RingKeeper:SetRing("PaladinBlessing", {
	{id=20217, ux="k"}, -- kings
	{id=19740, ux="m"}, -- might
	name="Blessings", limit="PALADIN", internal=true, ux="OPCPB"
});
RingKeeper:SetRing("PaladinTools", {
	{id=853, ux="h"}, -- hammer
	{id=85673, ux="g"}, -- glory
	{c="ed8f1b", id=498, ux="p"}, -- divine protection
	{id=54428, ux="l"}, -- divine plea
	{id=31884, ux="a"}, -- avenging wrath
	{id=1022, ux="t"}, -- hand of protection
	{id=1044, ux="f"}, -- hand of freedom
	{id=1038, ux="s"}, -- hand of salvation
	{id=62124, ux="r"}, -- hand of reckoning
	{id=26573, ux="c"}, -- consecration
	name="Utility", limit="PALADIN", hotkey="SECONDARY", ux="OPCPT"
});
RingKeeper:SetRing("ShamanWeapons", {
	{id=8232, ux="w"}, -- windfury
	{id=8024, ux="f"}, -- flametongue
	{id=8017, ux="r"}, -- rockbiter
	{id=8033, ux="b"}, -- frostbrand
	{id=51730, ux="e"}, -- earthliving
	name="Weapon Buffs", hotkey="PRIMARY", limit="SHAMAN", ux="OPCSW"
});
RingKeeper:SetRing("WarlockDemons", {
	{id=30146, ux="f"}, -- felguard
	{id=697, ux="v"}, -- void
	{id=688, ux="i"}, -- imp
	{id=712, ux="s"}, -- succubus
	{id=691, ux="h"}, -- felhunter
	name="Warlock Demons", limit="WARLOCK", hotkey="PRIMARY", ux="OPCLD"
});
RingKeeper:SetRing("WarlockStones", {
	{id=6201, ux="h"}, -- health
	{id=693, ux="s"}, -- soul
	{id=29893, ux="r"}, -- ritual
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

RingKeeper:SetRing("CommonTrades", {
	{id="/cast {{spell:3908/51309}}", ux="t"}, -- tailoring
	{id="/cast {{spell:2108/51302}}", ux="l"}, -- leatherworking
	{id="/cast {{spell:2018/51300}}", ux="b"}, -- blacksmithing
	{id="/cast [mod] {{spell:31252}}; {{spell:25229/51311}};", ux="j"}, -- jewelcrafting/prospecting
	{id="/cast [mod] {{spell:13262}}; {{spell:7411/51313}}", ux="e"}, -- enchanting/disenchanting
	{id="/cast {{spell:2259/51304}}", ux="a"}, -- alchemy
	{id="/cast [mod] {{spell:818}}; {{spell:2550/51296}}", ux="c"}, -- cooking/campfire
	{id="/cast [mod] {{spell:51005}}; {{spell:45357/45363}}", ux="i"}, -- inscription/milling
	{id="/cast {{spell:3273/45542}}", ux="f"}, -- first aid
	{id="/cast {{spell:4036/51306}}", ux="g"}, -- engineering
	{id="/cast [mod] {{spell:80451}}; {{spell:78670/89722}}", ux="r"},
	{id=53428, ux="u"}, -- runeforging
	{id=2656, ux="m"}, -- smelting
	name="Trade Skills", hotkey="ALT-T", ux="OPCCT"
});
RingKeeper:SetRing("WorldMarkers", {
	{"worldmark", 1, ux="b"}, -- blue
	{"worldmark", 2, ux="g"}, -- green
	{"worldmark", 3, ux="p"}, -- purple
	{"worldmark", 4, ux="r"}, -- red
	{"worldmark", 5, ux="y"}, -- yellow
	{"worldmark", 6, c="ccd8e5", ux="c"}, -- clear
	name="World Markers", hotkey="ALT-Y", ux="OPCWM"
});
RingKeeper:SetRing("RaidSymbols", {
	{"raidmark", 1, ux="y"}, -- yellow star
	{"raidmark", 2, ux="o"}, -- orange circle
	{"raidmark", 3, ux="p"}, -- purple diamond
	{"raidmark", 4, ux="g"}, -- green triangle
	{"raidmark", 5, ux="s"}, -- silver moon
	{"raidmark", 6, ux="b"}, -- blue square
	{"raidmark", 7, ux="r"}, -- red cross
	{"raidmark", 8, ux="w"}, -- white skull
	name="Target Markers", hotkey="ALT-R", ux="OPCRS"
});