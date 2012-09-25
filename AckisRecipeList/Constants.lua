-------------------------------------------------------------------------------
-- Constants.lua
-------------------------------------------------------------------------------
-- File date: 2012-01-10T10:23:23Z
-- File hash: 624980b
-- Project hash: de16aef
-- Project version: 2.3.0
-------------------------------------------------------------------------------
-- Please see http://www.wowace.com/addons/arl/ for more information.
-------------------------------------------------------------------------------
-- This source code is released under All Rights Reserved.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Upvalued Lua API
-------------------------------------------------------------------------------
local _G = getfenv(0)

-------------------------------------------------------------------------------
-- AddOn namespace.
-------------------------------------------------------------------------------
local FOLDER_NAME, private = ...
private.addon_name = "Ackis Recipe List"

local LibStub = _G.LibStub
local L		= LibStub("AceLocale-3.0"):GetLocale(private.addon_name)

-------------------------------------------------------------------------------
-- General constants.
-------------------------------------------------------------------------------
private.PLAYER_NAME = _G.UnitName("player")
private.REALM_NAME = _G.GetRealmName()

-------------------------------------------------------------------------------
-- Profession data.
-------------------------------------------------------------------------------
-- Needed for Smelting kludge.
private.MINING_PROFESSION_NAME = _G.GetSpellInfo(2575)

private.PROFESSION_SPELL_IDS = {
	ALCHEMY		= 2259,
	BLACKSMITHING	= 2018,
	COOKING		= 2550,
	ENCHANTING	= 7411,
	ENGINEERING	= 4036,
	FIRSTAID	= 3273,
	INSCRIPTION	= 45357,
	JEWELCRAFTING	= 25229,
	LEATHERWORKING	= 2108,
	RUNEFORGING	= 53428,
	SMELTING	= 2656,
	TAILORING	= 3908,
}

private.LOCALIZED_PROFESSION_NAMES = {}

for name, spell_id in _G.pairs(private.PROFESSION_SPELL_IDS) do
	private.LOCALIZED_PROFESSION_NAMES[name] = _G.GetSpellInfo(spell_id)
end

-- Special case for Runeforging is needed because the French translation is non-conforming.
if _G.GetLocale() == "frFR" then
	private.LOCALIZED_PROFESSION_NAMES.RUNEFORGING = "Runeforger"
end

private.PROFESSION_LABELS = {
	"alchemy",		-- 1
	"blacksmithing",	-- 2
	"cooking",		-- 3
	"enchanting",		-- 4
	"engineering",		-- 5
	"firstaid",		-- 6
	"inscription",		-- 7
	"jewelcrafting",	-- 8
	"leatherworking",	-- 9
	"runeforging",		-- 10
	"smelting",		-- 11
	"tailoring"	,	-- 12
}

private.ORDERED_PROFESSIONS = {
	private.LOCALIZED_PROFESSION_NAMES.ALCHEMY, 		-- 1
	private.LOCALIZED_PROFESSION_NAMES.BLACKSMITHING, 	-- 2
	private.LOCALIZED_PROFESSION_NAMES.COOKING, 		-- 3
	private.LOCALIZED_PROFESSION_NAMES.ENCHANTING,		-- 4
	private.LOCALIZED_PROFESSION_NAMES.ENGINEERING,		-- 5
	private.LOCALIZED_PROFESSION_NAMES.FIRSTAID,		-- 6
	private.LOCALIZED_PROFESSION_NAMES.INSCRIPTION,		-- 7
	private.LOCALIZED_PROFESSION_NAMES.JEWELCRAFTING, 	-- 8
	private.LOCALIZED_PROFESSION_NAMES.LEATHERWORKING, 	-- 9
	private.LOCALIZED_PROFESSION_NAMES.RUNEFORGING,		-- 10
	private.LOCALIZED_PROFESSION_NAMES.SMELTING,		-- 11
	private.LOCALIZED_PROFESSION_NAMES.TAILORING,		-- 12
}

private.PROFESSION_IDS = {}

for index = 1, #private.ORDERED_PROFESSIONS do
	private.PROFESSION_IDS[private.ORDERED_PROFESSIONS[index]] = index
end

private.PROFESSION_TEXTURES = {
	"alchemy",	-- 1
	"blacksmith",	-- 2
	"cooking",	-- 3
	"enchant",	-- 4
	"engineer",	-- 5
	"firstaid",	-- 6
	"inscribe",	-- 7
	"jewel",	-- 8
	"leather",	-- 9
	"runeforge",	-- 10
	"smelting",	-- 11
	"tailor",	-- 12
}

-------------------------------------------------------------------------------
-- Item qualities.
-------------------------------------------------------------------------------
private.ITEM_QUALITY_NAMES = {
	[1] = "COMMON",
	[2] = "UNCOMMON",
	[3] = "RARE",
	[4] = "EPIC",
	[5] = "LEGENDARY",
	[6] = "ARTIFACT",
}

private.ITEM_QUALITIES = {}

for index = 1, #private.ITEM_QUALITY_NAMES do
	private.ITEM_QUALITIES[private.ITEM_QUALITY_NAMES[index]] = index
end

-------------------------------------------------------------------------------
-- Game/expansion versions.
-------------------------------------------------------------------------------
private.GAME_VERSION_NAMES = {
	[1] = "ORIG",
	[2] = "TBC",
	[3] = "WOTLK",
	[4] = "CATA",
}

private.GAME_VERSIONS = {}

for index = 1, #private.GAME_VERSION_NAMES do
	private.GAME_VERSIONS[private.GAME_VERSION_NAMES[index]] = index
end

-------------------------------------------------------------------------------
-- Common filter bitfield word 1.
-------------------------------------------------------------------------------
private.COMMON_FLAGS_WORD1 = {
	ALLIANCE	= 0x00000001,	-- 1
	HORDE		= 0x00000002,	-- 2
	TRAINER		= 0x00000004,	-- 3
	VENDOR		= 0x00000008,	-- 4
	INSTANCE	= 0x00000010,	-- 5
	RAID		= 0x00000020,	-- 6
	SEASONAL	= 0x00000040,	-- 7
	QUEST		= 0x00000080,	-- 8
	PVP		= 0x00000100,	-- 9
	WORLD_DROP	= 0x00000200,	-- 10
	MOB_DROP	= 0x00000400,	-- 11
	DISC		= 0x00000800,	-- 12
	RETIRED		= 0x00001000,	-- 13
	IBOE		= 0x00002000,	-- 14
	IBOP		= 0x00004000,	-- 15
	IBOA		= 0x00008000,	-- 16
	RBOE		= 0x00010000,	-- 17
	RBOP		= 0x00020000,	-- 18
	RBOA		= 0x00040000,	-- 19
	DPS		= 0x00080000,	-- 20
	TANK		= 0x00100000,	-- 21
	HEALER		= 0x00200000,	-- 22
	CASTER		= 0x00400000,	-- 23
	ACHIEVEMENT	= 0x00800000,	-- 24
}

-------------------------------------------------------------------------------
-- Class filter bitfield word 1.
-------------------------------------------------------------------------------
private.CLASS_FLAGS_WORD1 = {
	DK	= 0x00000001,	-- 1
	DRUID	= 0x00000002,	-- 2
	HUNTER	= 0x00000004,	-- 3
	MAGE	= 0x00000008,	-- 4
	PALADIN	= 0x00000010,	-- 5
	PRIEST	= 0x00000020,	-- 6
	SHAMAN	= 0x00000040,	-- 7
	ROGUE	= 0x00000080,	-- 8
	WARLOCK	= 0x00000100,	-- 9
	WARRIOR	= 0x00000200,	-- 10
}

-------------------------------------------------------------------------------
-- Reputation filter bitfield word 1.
-------------------------------------------------------------------------------
private.REP_FLAGS_WORD1 = {
	ARGENTDAWN		= 0x00000001,	-- 1
	CENARION_CIRCLE		= 0x00000002,	-- 2
	THORIUM_BROTHERHOOD	= 0x00000004,	-- 3
	TIMBERMAW_HOLD		= 0x00000008,	-- 4
	ZANDALAR		= 0x00000010,	-- 5
	ALDOR			= 0x00000020,	-- 6
	ASHTONGUE		= 0x00000040,	-- 7
	CENARION_EXPEDITION	= 0x00000080,	-- 8
	HELLFIRE		= 0x00000100,	-- 9
	CONSORTIUM		= 0x00000200,	-- 10
	KOT			= 0x00000400,	-- 11
	LOWERCITY		= 0x00000800,	-- 12
	NAGRAND			= 0x00001000,	-- 13
	SCALE_SANDS		= 0x00002000,	-- 14
	SCRYER			= 0x00004000,	-- 15
	SHATAR			= 0x00008000,	-- 16
	SHATTEREDSUN		= 0x00010000,	-- 17
	SPOREGGAR		= 0x00020000,	-- 18
	VIOLETEYE		= 0x00040000,	-- 19
	ARGENTCRUSADE		= 0x00080000,	-- 20
	FRENZYHEART		= 0x00100000,	-- 21
	EBONBLADE		= 0x00200000,	-- 22
	KIRINTOR		= 0x00400000,	-- 23
	HODIR			= 0x00800000,	-- 24
	KALUAK			= 0x01000000,	-- 25
	ORACLES			= 0x02000000,	-- 26
	WYRMREST		= 0x04000000,	-- 27
	WRATHCOMMON1		= 0x08000000,	-- 28
	WRATHCOMMON2		= 0x10000000,	-- 29
	WRATHCOMMON3		= 0x20000000,	-- 30
	WRATHCOMMON4		= 0x40000000,	-- 31
	WRATHCOMMON5		= 0x80000000,	-- 32
}

-------------------------------------------------------------------------------
-- Reputation filter bitfield word 2.
-------------------------------------------------------------------------------
private.REP_FLAGS_WORD2 = {
	ASHEN_VERDICT		= 0x00000001,	-- 1
	CATACOMMON1		= 0x00000002,	-- 2
	CATACOMMON2		= 0x00000004,	-- 3
	GUARDIANS		= 0x00000008,	-- 4
	RAMKAHEN		= 0x00000010,	-- 5
	EARTHEN_RING		= 0x00000020,	-- 6
	THERAZANE		= 0x00000040,	-- 7
}

-------------------------------------------------------------------------------
-- Item filter bitfield word 1.
-------------------------------------------------------------------------------
private.ITEM_FLAGS_WORD1 = {
	--	UNUSED	= 0x00000001 -- 1
}

private.FLAG_WORDS = {
	private.COMMON_FLAGS_WORD1,
	private.CLASS_FLAGS_WORD1,
	private.REP_FLAGS_WORD1,
	private.REP_FLAGS_WORD2,
	private.ITEM_FLAGS_WORD1,
}

-- Member names within a recipe's flags table.
private.FLAG_MEMBERS = {
	"common1",
	"class1",
	"reputation1",
	"reputation2",
	"item1",
}

private.FILTER_STRINGS = {}

for index = 1, #private.FLAG_WORDS do
	for flag_name in _G.pairs(private.FLAG_WORDS[index]) do
		private.FILTER_STRINGS[#private.FILTER_STRINGS + 1] = flag_name
	end
end

private.FILTER_IDS = {}

for index = 1, #private.FILTER_STRINGS do
	private.FILTER_IDS[private.FILTER_STRINGS[index]] = index
end

-------------------------------------------------------------------------------
-- Item filter types.
-------------------------------------------------------------------------------
private.ITEM_FILTER_TYPES = {
	-------------------------------------------------------------------------------
	-- Alchemy
	-------------------------------------------------------------------------------
	ALCHEMY_CAULDRON = true,
	ALCHEMY_ELIXIR = true,
	ALCHEMY_FLASK = true,
	ALCHEMY_MISC = true,
	ALCHEMY_OIL = true,
	ALCHEMY_POTION = true,
	ALCHEMY_TRANSMUTE = true,
	ALCHEMY_TRINKET = true,
	-------------------------------------------------------------------------------
	-- Blacksmithing
	-------------------------------------------------------------------------------
	BLACKSMITHING_CHEST = true,
	BLACKSMITHING_DAGGER = true,
	BLACKSMITHING_FEET = true,
	BLACKSMITHING_HANDS = true,
	BLACKSMITHING_HEAD = true,
	BLACKSMITHING_ITEM_ENHANCEMENT = true,
	BLACKSMITHING_LEGS = true,
	BLACKSMITHING_MATERIALS = true,
	BLACKSMITHING_ONE_HAND_AXE = true,
	BLACKSMITHING_ONE_HAND_MACE = true,
	BLACKSMITHING_ONE_HAND_SWORD = true,
	BLACKSMITHING_POLEARM = true,
	BLACKSMITHING_ROD = true,
	BLACKSMITHING_SHIELD = true,
	BLACKSMITHING_SHOULDER = true,
	BLACKSMITHING_SKELETON_KEY = true,
	BLACKSMITHING_THROWN = true,
	BLACKSMITHING_TWO_HAND_AXE = true,
	BLACKSMITHING_TWO_HAND_MACE = true,
	BLACKSMITHING_TWO_HAND_SWORD = true,
	BLACKSMITHING_WAIST = true,
	BLACKSMITHING_WRIST = true,
	-------------------------------------------------------------------------------
	-- Enchanting
	-------------------------------------------------------------------------------
	ENCHANTING_BOOTS = true,
	ENCHANTING_BRACER = true,
	ENCHANTING_CHEST = true,
	ENCHANTING_CLOAK = true,
	ENCHANTING_GLOVES = true,
	ENCHANTING_RING = true,
	ENCHANTING_SHIELD = true,
	ENCHANTING_WEAPON = true,
	ENCHANTING_2H_WEAPON = true,
	ENCHANTING_STAFF = true,
	ENCHANTING_OIL = true,
	ENCHANTING_ROD = true,
	ENCHANTING_WAND = true,
	ENCHANTING_MISC = true,
	-------------------------------------------------------------------------------
	-- Engineering
	-------------------------------------------------------------------------------
	ENGINEERING_BACK = true,
	ENGINEERING_BAG = true,
	ENGINEERING_BOW = true,
	ENGINEERING_CREATED_ITEM = true,
	ENGINEERING_CROSSBOW = true,
	ENGINEERING_FEET = true,
	ENGINEERING_GUN = true,
	ENGINEERING_HEAD = true,
	ENGINEERING_ITEM_ENHANCEMENT = true,
	ENGINEERING_MAIN_HAND = true,
	ENGINEERING_MATERIALS = true,
	ENGINEERING_MOUNT = true,
	ENGINEERING_NECK = true,
	ENGINEERING_PET = true,
	ENGINEERING_SHIELD = true,
	ENGINEERING_TRINKET = true,
	-------------------------------------------------------------------------------
	-- Inscription
	-------------------------------------------------------------------------------
	INSCRIPTION_CREATED_ITEM = true,
	INSCRIPTION_ITEM_ENHANCEMENT = true,
	INSCRIPTION_MAJOR_GLYPH = true,
	INSCRIPTION_MATERIALS = true,
	INSCRIPTION_MINOR_GLYPH = true,
	INSCRIPTION_OFF_HAND = true,
	INSCRIPTION_PRIME_GLYPH = true,
	INSCRIPTION_RELIC = true,
	INSCRIPTION_SCROLL = true,
	-------------------------------------------------------------------------------
	-- Jewelcrafting
	-------------------------------------------------------------------------------
	JEWELCRAFTING_CREATED_ITEM = true,
	JEWELCRAFTING_FIST_WEAPON = true,
	JEWELCRAFTING_HEAD = true,
	JEWELCRAFTING_MATERIALS = true,
	JEWELCRAFTING_NECK = true,
	JEWELCRAFTING_RING = true,
	JEWELCRAFTING_TRINKET = true,
	JEWELCRAFTING_GEM_BLUE = true,
	JEWELCRAFTING_GEM_GREEN = true,
	JEWELCRAFTING_GEM_META = true,
	JEWELCRAFTING_GEM_ORANGE = true,
	JEWELCRAFTING_GEM_PRISMATIC = true,
	JEWELCRAFTING_GEM_PURPLE = true,
	JEWELCRAFTING_GEM_RED = true,
	JEWELCRAFTING_GEM_YELLOW = true,
	-------------------------------------------------------------------------------
	-- Leatherworking
	-------------------------------------------------------------------------------
	LEATHERWORKING_BACK = true,
	LEATHERWORKING_BAG = true,
	LEATHERWORKING_CHEST = true,
	LEATHERWORKING_CREATED_ITEM = true,
	LEATHERWORKING_FEET = true,
	LEATHERWORKING_HANDS = true,
	LEATHERWORKING_HEAD = true,
	LEATHERWORKING_ITEM_ENHANCEMENT = true,
	LEATHERWORKING_LEGS = true,
	LEATHERWORKING_MATERIALS = true,
	LEATHERWORKING_SHIELD = true,
	LEATHERWORKING_SHOULDER = true,
	LEATHERWORKING_THROWN = true,
	LEATHERWORKING_WAIST = true,
	LEATHERWORKING_WRIST = true,
	-------------------------------------------------------------------------------
	-- Tailoring
	-------------------------------------------------------------------------------
	TAILORING_BACK = true,
	TAILORING_BAG = true,
	TAILORING_CHEST = true,
	TAILORING_FEET = true,
	TAILORING_HANDS = true,
	TAILORING_HEAD = true,
	TAILORING_ITEM_ENHANCEMENT = true,
	TAILORING_LEGS = true,
	TAILORING_MATERIALS = true,
	TAILORING_MISC = true,
	TAILORING_SHIRT = true,
	TAILORING_SHOULDER = true,
	TAILORING_WAIST = true,
	TAILORING_WRIST = true,
}

-------------------------------------------------------------------------------
-- Acquire types.
-------------------------------------------------------------------------------
private.ACQUIRE_NAMES = {
	[1]	= L["Trainer"],
	[2]	= L["Vendor"],
	[3]	= L["Mob Drop"],
	[4]	= L["Quest"],
	[5]	= _G.GetCategoryInfo(155),
	[6]	= _G.REPUTATION,
	[7]	= L["World Drop"],
	[8]	= _G.ACHIEVEMENTS,
	[9]	= L["Discovery"],
	[10]	= _G.MISCELLANEOUS,
}

private.ACQUIRE_STRINGS = {
	[1]	= "TRAINER",
	[2]	= "VENDOR",
	[3]	= "MOB_DROP",
	[4]	= "QUEST",
	[5]	= "SEASONAL",
	[6]	= "REPUTATION",
	[7]	= "WORLD_DROP",
	[8]	= "ACHIEVEMENT",
	[9]	= "DISCOVERY",
	[10]	= "CUSTOM",
}

private.ACQUIRE_TYPES = {}

for index = 1, #private.ACQUIRE_STRINGS do
	private.ACQUIRE_TYPES[private.ACQUIRE_STRINGS[index]] = index
end

-------------------------------------------------------------------------------
-- Reputation levels.
-------------------------------------------------------------------------------
private.REP_LEVEL_STRINGS = {
	[1]	= "FRIENDLY",
	[2]	= "HONORED",
	[3]	= "REVERED",
	[4]	= "EXALTED",
}

private.REP_LEVELS = {}

for index = 1, #private.REP_LEVEL_STRINGS do
	private.REP_LEVELS[private.REP_LEVEL_STRINGS[index]] = index
end

-------------------------------------------------------------------------------
-- Factions.
-------------------------------------------------------------------------------
private.FACTION_STRINGS = {
	[59]	= "THORIUM_BROTHERHOOD",
	[270]	= "ZANDALAR",
	[529]	= "ARGENTDAWN",
	[576]	= "TIMBERMAW_HOLD",
	[589]	= "WINTERSPRING",
	[609]	= "CENARION_CIRCLE",
	[932]	= "ALDOR",
	[933]	= "CONSORTIUM",
	[934]	= "SCRYER",
	[935]	= "SHATAR",
	[941]	= "MAGHAR",
	[942]	= "CENARION_EXPEDITION",
	[946]	= "HONOR_HOLD",
	[947]	= "THRALLMAR",
	[967]	= "VIOLETEYE",
	[970]	= "SPOREGGAR",
	[978]	= "KURENAI",
	[989]	= "KEEPERS_OF_TIME",
	[990]	= "SCALE_OF_SANDS",
	[1011]	= "LOWERCITY",
	[1012]	= "ASHTONGUE",
	[1037]	= "ALLIANCE_VANGUARD",
	[1052]	= "HORDE_EXPEDITION",
	[1073]	= "KALUAK",
	[1077]	= "SHATTEREDSUN",
	[1090]	= "KIRINTOR",
	[1091]	= "WYRMREST",
	[1098]	= "EBONBLADE",
	[1104]	= "FRENZYHEART",
	[1105]	= "ORACLES",
	[1106]	= "ARGENTCRUSADE",
	[1119]	= "HODIR",
	[1156]	= "ASHEN_VERDICT",
	[1135]	= "EARTHEN_RING",
	[1158]	= "GUARDIANS",
	[1171]	= "THERAZANE",
	[1172]	= "DRAGONMAW",
	[1173]	= "RAMKAHEN",
	[1174]	= "WILDHAMMER",
	[1177]	= "WARDENS",
	[1178]	= "HELLSCREAM",
}

private.FACTION_IDS = {}

for id, name in _G.pairs(private.FACTION_STRINGS) do
	private.FACTION_IDS[name] = id
end

-------------------------------------------------------------------------------
-- Colors.
-------------------------------------------------------------------------------
local function RGBtoHEX(r, g, b)
	return ("%02x%02x%02x"):format(r * 255, g * 255, b * 255)
end

local function GetColorsFromTable(dict)
	return dict.r, dict.g, dict.b
end

private.REPUTATION_COLORS = {
	["exalted"]	= RGBtoHEX(GetColorsFromTable(_G.FACTION_BAR_COLORS[8])),
	["revered"]	= RGBtoHEX(GetColorsFromTable(_G.FACTION_BAR_COLORS[7])),
	["honored"]	= RGBtoHEX(GetColorsFromTable(_G.FACTION_BAR_COLORS[6])),
	["friendly"]	= RGBtoHEX(GetColorsFromTable(_G.FACTION_BAR_COLORS[5])),
	["neutral"]	= RGBtoHEX(GetColorsFromTable(_G.FACTION_BAR_COLORS[4])),
	["unfriendly"]	= RGBtoHEX(GetColorsFromTable(_G.FACTION_BAR_COLORS[3])),
	["hostile"]	= RGBtoHEX(GetColorsFromTable(_G.FACTION_BAR_COLORS[2])),
	["hated"]	= RGBtoHEX(GetColorsFromTable(_G.FACTION_BAR_COLORS[1])),
}

-- Recipe difficulty colors.
private.DIFFICULTY_COLORS = {
	["trivial"]	= "808080",
	["easy"]	= "40bf40",
	["medium"]	= "ffff00",
	["optimal"]	= "ff8040",
	["impossible"]	= "ff0000",
}

private.BASIC_COLORS = {
	["grey"]	= "666666",
	["white"]	= "ffffff",
	["yellow"]	= "ffff00",
	["normal"]	= "ffd100",
}

-- Colors used in tooltips and the recipe list.
private.CATEGORY_COLORS = {
	-- Acquire type colors
	["achievement"]	= "faeb98",
	["custom"]	= "73b7ff",
	["discovery"]	= "ff9500",
	["mobdrop"]	= "962626",
	["quest"]	= "dbdb2c",
	["reputation"]	= "855a99",
	["seasonal"]	= "80590e",
	["trainer"]	= "c98e26",
	["vendor"]	= "aad372",

	-- Miscellaneous
	["coords"]	= "d1ce6f",
	["location"]	= "ffecc1",
	["repname"]	= "6a9ad9",

}

-- Listing of recipes which overwrite other recipes when you learn them.
-- For example, when you learn Darkglow Embroidery Rank 2 (75175),
-- you no longer know Darkglow Embroidery Rank 1 (55769)

private.SPELL_OVERWRITE_MAP = {
	-------------------------------------------------------------------------------
	-- Tailoring
	-------------------------------------------------------------------------------
	[75175] = 55769,	[75172] = 55642,	[75178] = 55777,
	[75154] = 56034,	[75155] = 56039,
}