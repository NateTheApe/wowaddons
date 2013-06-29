-- Scorchio! 2, A multi-mob vulnerability manager
-- Copyright (C) 2008-2009  ennui@bloodhoof-eu, ennuilg@gmail.com
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 3
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <http://www.gnu.org/licenses/>.

-- GLOBALS: LibStub
-- GLOBALS: Scorchio2DB
-- GLOBALS: UIParent
-- GLOBALS: EnableAddOn
-- GLOBALS: LoadAddOn
-- GLOBALS: CreateFrame
-- GLOBALS: INTERFACEOPTIONS_ADDONCATEGORIES
-- GLOBALS: InterfaceOptionsFrame_OpenToCategory
-- GLOBALS: InterfaceOptions_AddCategory
local PlaySoundFile = PlaySoundFile
local InCombatLockdown = InCombatLockdown
local GetTalentInfo = GetTalentInfo
local GetSpellCooldown = GetSpellCooldown
local UnitClass = UnitClass
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitAura = UnitAura
local UnitDebuff = UnitDebuff
local UnitBuff = UnitBuff
local UnitName = UnitName
local UnitIsPlayer = UnitIsPlayer
local GetTime = GetTime
local COMBATLOG_OBJECT_TYPE_PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER
local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE
local pairs = pairs
local unpack = unpack
local tostring = tostring
local geterrorhandler = geterrorhandler
local gsub = gsub
local format = format
local strfind = strfind
local floor = floor
local bit_bor = bit.bor
local bit_band = bit.band

local mobTable
local DB
local Scorchio2
local playerGUID
local lastTargetGUID
local impactTimestamp = 0
local impactLBExpire
local impactIgniteExpire
local impactPyroblastExpire
local impactCombustionExpire
local combatFlag

Scorchio2 = LibStub("AceAddon-3.0"):NewAddon("Scorchio2", "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0", "LibBars-1.0", "LibSink-2.0")
_G.Scorchio2 = Scorchio2
local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Scorchio2")
local SM = LibStub("LibSharedMedia-3.0")
local DBVERSION = 10

-- Constants for mobTable
local MOBNAME = 1
local REFRESHTIME = 2
local EXPIRATIONTIME = 3
local DURATION = 4
local STACK = 5
local CASTS = 6
local TIMER = 7
local BAR = 8

local AFFILIATION = bit_bor(COMBATLOG_OBJECT_AFFILIATION_MINE, COMBATLOG_OBJECT_AFFILIATION_PARTY, COMBATLOG_OBJECT_AFFILIATION_RAID)

-- Hardcoded localizations
L["Pyromaniac"] = GetSpellInfo(132210)
L["Living Bomb"] = GetSpellInfo(44457)
L["Polymorph"] = GetSpellInfo(118)
L["Slow"] = GetSpellInfo(31589)
L["Hot Streak"] = GetSpellInfo(48108)
L["Arcane Missiles"] = GetSpellInfo(5143)
L["Heating Up"] = GetSpellInfo(48107)
L["Arcane Charge"] = GetSpellInfo(36032)
L["Brain Freeze"] = GetSpellInfo(57761)
L["Fingers of Frost"] = GetSpellInfo(44544)
L["Mirror Image"] = GetSpellInfo(55342)
L["Ignite"] = GetSpellInfo(12654)
L["Pyroblast"] = GetSpellInfo(11366)
L["Flamestrike"] = GetSpellInfo(2120)
L["Invocation"] = GetSpellInfo(114003)
L["Nether Tempest"] = GetSpellInfo(114923)
L["Frost Bomb"] = GetSpellInfo(112948)
L["Combustion"] = GetSpellInfo(83853)

-- Register some sounds
SM:Register("sound", "AchievementSound", [[Sound\Spells\AchievmentSound1.wav]])
SM:Register("sound", "Rubber Ducky", [[Sound\Doodad\Goblin_Lottery_Open01.wav]])
SM:Register("sound", "Cartoon FX", [[Sound\Doodad\Goblin_Lottery_Open03.wav]])
SM:Register("sound", "Explosion", [[Sound\Doodad\Hellfire_Raid_FX_Explosion05.wav]])
SM:Register("sound", "Shing!", [[Sound\Doodad\PortcullisActive_Closed.wav]])
SM:Register("sound", "Wham!", [[Sound\Doodad\PVP_Lordaeron_Door_Open.wav]])
SM:Register("sound", "Simon Chime", [[Sound\Doodad\SimonGame_LargeBlueTree.wav]])
SM:Register("sound", "War Drums", [[Sound\Event Sounds\Event_wardrum_ogre.wav]])
SM:Register("sound", "Cheer", [[Sound\Event Sounds\OgreEventCheerUnique.wav]])
SM:Register("sound", "Humm", [[Sound\Spells\SimonGame_Visual_GameStart.wav]])
SM:Register("sound", "Short Circuit", [[Sound\Spells\SimonGame_Visual_BadPress.wav]])
SM:Register("sound", "Fel Portal", [[Sound\Spells\Sunwell_Fel_PortalStand.wav]])
SM:Register("sound", "Fel Nova", [[Sound\Spells\SeepingGaseous_Fel_Nova.wav]])
SM:Register("sound", "Bats", [[Sound\Doodad\BatsFlyAway.wav]])
SM:Register("sound", "Firework", [[Sound\Doodad\G_FireworkBoomGeneral2.wav]])
SM:Register("sound", "Clockwork", [[Sound\Doodad\G_GasTrapOpen.wav]])
SM:Register("sound", "Gong", [[Sound\Doodad\G_GongTroll01.wav]])
SM:Register("sound", "Wisp", [[Sound\Event Sounds\Wisp\WispPissed1.wav]])
SM:Register("sound", "Fog Horn", [[Sound\Doodad\ZeppelinHorn.wav]])
SM:Register("sound", "Error", [[Sound\interface\Error.wav]])
SM:Register("sound", "Drop", [[Sound\interface\DropOnGround.wav]])
SM:Register("sound", "Whisper", [[Sound\interface\igTextPopupPing02.wav]])
SM:Register("sound", "Friend Login", [[Sound\interface\FriendJoin.wav]])
SM:Register("sound", "Socket Clunk", [[Sound\interface\JewelcraftingFinalize.wav]])
SM:Register("sound", "Ping", [[Sound\interface\MapPing.wav]])

-- Spells that might immediately activate a bar, before we get a PLAYER_REGEN_DISABLED event.
-- Needed so that we can briefly act like the mod is in combat, to make it more responsive.
local SPELLIDS = {
	[30451] = true, -- Arcane Blast
	[10] = true, -- Blizzard
	[120] = true, -- Cone of Cold
	[12051] = true, -- Evocation
	[133] = true, -- Fireball
	[2136] = true, -- Fire Blast
	[2120] = true, -- Flamestrike
	[112948] = true, -- Frost Bomb
	[116] = true, -- Frostbolt
	[44614] = true, -- Frostfire Bolt
	[122] = true, -- Frost Nova
	[30455] = true, -- Ice Lance
	[108853] = true, -- Inferno Blast
	[44457] = true, -- Living Bomb
	[55342] = true, -- Mirror Image
	[118] = true, -- Polymorph
	[28271] = true, -- Polymorph: Turtle
	[28272] = true, -- Polymorph: Pig
	[61025] = true, -- Polymorph: Serpent
	[61305] = true, -- Polymorph: Black Cat
	[61721] = true, -- Polymorph: Rabbit
	[61780] = true, -- Polymorph: Turkey
	[2948] = true, -- Scorch
	[31589] = true, -- Slow
	[114923] = true, -- Nether Tempest
	[11129] = true, -- Combustion
}

-- Bar settings in the DB are referenced by these 1-letter codes.
local BAR_PYROMANIC = "a"
-- Winter's Chill, removed
local BAR_LIVING_BOMB = "c"
local BAR_POLYMORPH = "d"
local BAR_SLOW = "e"
local BAR_HOT_STREAK = "f"
local BAR_ARCANE_MISSILES = "g"
local BAR_HEATING_UP = "h"
local BAR_ARCANE_CHARGE = "i"
local BAR_BRAIN_FREEZE = "j"
local BAR_FINGERS_OF_FROST = "k"
-- Shadow Mastery, removed
-- Water Elemental, removed
local BAR_MIRROR_IMAGE = "n"
-- Torment the Weak, removed
local BAR_8_PERCENT_SPELL_DAMAGE = "p"
-- Frostfire Bolt, removed
-- Impact, removed
-- Improved Polymorph, removed
local BAR_IGNITE = "t"
local BAR_PYROBLAST = "u"
local BAR_FLAMESTRIKE = "v"
local BAR_INVOCATION = "w"
local BAR_NETHER_TEMPEST = "x"
local BAR_FROST_BOMB = "y"
local BAR_COMBUSTION = "z"

-- When deleting or inserting anything in this array, you must update a couple UpdateTable() calls
-- pertaining to Flamestrike and Frost Bomb, since they have no spellID to reference. Appending 
-- causes no problems.
local VULNDATA = {
	{ -- Pyromaniac
		bar = BAR_PYROMANIC,
		spellid = 132210,
		self = false,
		durationpve = 15,
		durationpvp = 15,
		maxstacks = 1,
		unique = false,
		valid = COMBATLOG_OBJECT_AFFILIATION_MINE,
	},
	{ -- Living Bomb
		bar = BAR_LIVING_BOMB,
		spellid = 44457,
		self = false,
		durationpve = 12,
		durationpvp = 12,
		maxstacks = 1,
		unique = false,
		valid = COMBATLOG_OBJECT_AFFILIATION_MINE,
	},
	{ -- Polymorph
		bar = BAR_POLYMORPH,
		spellid = {
			118,
			28271, -- Polymorph: Turtle
			28272, -- Polymorph: Pig
			61025, -- Polymorph: Serpent
			61305, -- Polymorph: Black Cat
			61721, -- Polymorph: Rabbit
			61780, -- Polymorph: Turkey
		},
		self = false,
		durationpve = 50,
		durationpvp = 8,
		maxstacks = 1,
		unique = true,
		valid = 4294967295,
	},
	{ -- Slow
		bar = BAR_SLOW,
		spellid = 31589,
		self = false,
		durationpve = 15,
		durationpvp = 8,
		maxstacks = 1,
		unique = true,
		valid = 4294967295,
	},
	{ -- Hot Streak
		bar = BAR_HOT_STREAK,
		spellid = 48108,
		self = true,
		durationpve = 15,
		durationpvp = 15,
		maxstacks = 1,
		unique = true,
		valid = COMBATLOG_OBJECT_AFFILIATION_MINE,
	},
	{ -- Arcane Missiles
		bar = BAR_ARCANE_MISSILES,
		spellid = 79683,
		self = true,
		durationpve = 20,
		durationpvp = 20,
		maxstacks = 2,
		unique = true,
		valid = COMBATLOG_OBJECT_AFFILIATION_MINE,
	},
	{ -- Heating Up
		bar = BAR_HEATING_UP,
		spellid = 48107,
		self = true,
		durationpve = 10,
		durationpvp = 10,
		maxstacks = 1,
		unique = true,
		valid = COMBATLOG_OBJECT_AFFILIATION_MINE,
	},
	{ -- Arcane Charge
		bar = BAR_ARCANE_CHARGE,
		spellid = 36032,
		self = true,
		durationpve = 10,
		durationpvp = 10,
		maxstacks = 4,
		unique = true,
		valid = COMBATLOG_OBJECT_AFFILIATION_MINE,
	},
	{ -- Brain Freeze
		bar = BAR_BRAIN_FREEZE,
		spellid = 57761,
		self = true,
		durationpve = 15,
		durationpvp = 15,
		maxstacks = 1,
		unique = true,
		valid = COMBATLOG_OBJECT_AFFILIATION_MINE,
	},
	{ -- Fingers of Frost
		bar = BAR_FINGERS_OF_FROST,
		spellid = 44544,
		self = true,
		durationpve = 15,
		durationpvp = 15,
		maxstacks = 2,
		unique = true,
		valid = COMBATLOG_OBJECT_AFFILIATION_MINE,
	},
	{  -- Mirror Image
		bar = BAR_MIRROR_IMAGE,
		spellid = 55342,
		self = true,
		durationpve = 30,
		durationpvp = 30,
		maxstacks = 1,
		unique = true,
		valid = COMBATLOG_OBJECT_AFFILIATION_MINE,
	},
	{  -- Curse of Elements
		bar = BAR_8_PERCENT_SPELL_DAMAGE,
		spellid = 1490,
		self = false,
		durationpve = 300,
		durationpvp = 120,
		maxstacks = 1,
		unique = false,
		valid = 4294967295,
	},
	{  -- Master Poisoner
		bar = BAR_8_PERCENT_SPELL_DAMAGE,
		spellid = 93068,
		self = false,
		durationpve = 15,
		durationpvp = 15,
		maxstacks = 1,
		unique = false,
		valid = 4294967295,
	},
	{  -- Lightning Breath
		bar = BAR_8_PERCENT_SPELL_DAMAGE,
		spellid = 24844,
		self = false,
		durationpve = 45,
		durationpvp = 45,
		maxstacks = 1,
		unique = false,
		valid = 4294967295,
	},
	{  -- Fire Breath
		bar = BAR_8_PERCENT_SPELL_DAMAGE,
		spellid = 34889,
		self = false,
		durationpve = 45,
		durationpvp = 45,
		maxstacks = 1,
		unique = false,
		valid = 4294967295,
	},
	{ -- Ignite
		bar = BAR_IGNITE,
		spellid = 12654,
		self = false,
		durationpve = 4,
		durationpvp = 4,
		maxstacks = 1,
		unique = false,
		valid = COMBATLOG_OBJECT_AFFILIATION_MINE,
	},
	{ -- Pyroblast
		bar = BAR_PYROBLAST,
		spellid = 11366,
		self = false,
		durationpve = 18,
		durationpvp = 18,
		maxstacks = 1,
		unique = false,
		valid = COMBATLOG_OBJECT_AFFILIATION_MINE,
	},
	{ -- Flamestrike
		bar = BAR_FLAMESTRIKE,
		-- tracking done by time since cast success, not auras
		self = false,
		durationpve = 8,
		durationpvp = 8,
		maxstacks = 1,
		unique = true,
		valid = 4294967295,
	},
	{ -- Invocation
		bar = BAR_INVOCATION,
		spellid = 116257,
		self = true,
		durationpve = 40,
		durationpvp = 40,
		maxstacks = 1,
		unique = true,
		valid = COMBATLOG_OBJECT_AFFILIATION_MINE,
	},
	{ -- Nether Tempest
		bar = BAR_NETHER_TEMPEST,
		spellid = 114923,
		self = false,
		durationpve = 12,
		durationpvp = 12,
		maxstacks = 1,
		unique = false,
		valid = COMBATLOG_OBJECT_AFFILIATION_MINE,
	},
	{ -- Frost Bomb
		bar = BAR_FROST_BOMB,
		-- tracking done by time since cast success, not auras
		self = false,
		durationpve = 10, -- actual duration of bar will depend on haste (dealt with elsewhere)
		durationpvp = 10, 
		maxstacks = 1,
		unique = false,
		valid = COMBATLOG_OBJECT_AFFILIATION_MINE,
	},
	{ -- Combustion
		bar = BAR_COMBUSTION,
		spellid = 83853,
		self = false,
		durationpve = 10, -- Glyph will double it, that will be automatically detected
		durationpvp = 10,
		maxstacks = 1,
		unique = false,
		valid = COMBATLOG_OBJECT_AFFILIATION_MINE,
	},
}

local T = {} -- maps VULNDATA # to baroptions key. Each baroptions can have many VULNDATA referencing it.
local VULNERABILITIES = {} -- maps spellID to VULNDATA #. Each VULNDATA can have many spellids referencing it.
for i = 1,#VULNDATA do
	T[i] = VULNDATA[i].bar

	local spellid = VULNDATA[i].spellid
	if type(spellid) == "number" then
		VULNERABILITIES[spellid] = i
	elseif type(spellid) == "table" then
		for j = 1,#spellid do
			VULNERABILITIES[spellid[j]] = i
		end
	end
end

-- Utility Functions
local function Colours(pack, alpha)
	local r, g, b = unpack(pack)
	return r, g, b, alpha
end
Scorchio2.Colours = Colours

local function SubTokens( inputText, mobName, spellCount)
	if mobName ~= nil then
		inputText = gsub(inputText, "$m", tostring(mobName))
	end
	if spellCount ~= nil then
		inputText = gsub(inputText, "$s", tostring(spellCount))
	end
	return inputText
end
Scorchio2.SubTokens = SubTokens

-- Defaults and Options Tables
local defaults = {
	profile = {
		custom_anchors = {
		},
		anchoroptions = {
			targeted = {
				position = {
					pr = "CENTER",
					p = "CENTER",
					py = -300,
					px = 0
					},
				growth = true,
				orientation = 1,
				scale = 1.0,
				fadetime = -1,
				flash = false,
				flashtime = 6,
				iconshow = true,
				iconside = "LEFT",
				raidiconshow = false,
				raidiconpos = -10,
				texture = "Blizzard",
				width = 200,
				height = 18,
				maxbars = 0,
				font = "Arial Narrow",
				fontsize = 12
			},
			nontargeted = {
				position = {
					pr = "LEFT",
					p = "LEFT",
					py = -230,
					px = 150
					},
				growth = true,
				orientation = 1,
				scale = 1.0,
				fadetime = -1,
				flash = false,
				flashtime = 6,
				iconshow = true,
				iconside = "LEFT",
				raidiconshow = false,
				raidiconpos = -10,
				texture = "Blizzard",
				width = 200,
				height = 18,
				maxbars = 0,
				font = "Arial Narrow",
				fontsize = 12
			},
			buffs = {
				position = {
					pr = "CENTER",
					p = "CENTER",
					py = 0,
					px = 0
					},
				growth = true,
				orientation = 1,
				scale = 1.0,
				fadetime = -1,
				flash = false,
				flashtime = 6,
				iconshow = true,
				iconside = "LEFT",
				raidiconshow = false,
				raidiconpos = -10,
				texture = "Blizzard",
				width = 200,
				height = 18,
				maxbars = 0,
				font = "Arial Narrow",
				fontsize = 12
			},
		},
		baroptions = {
			a = { -- Pyromaniac
				message = format(L["%s Faded on $m"], L["Pyromaniac"]),
				warning = format(L["Recast %s on $m!"], L["Pyromaniac"]),
				track = true,
				show = true,
				showproc = false,
				showwarning = true,
				showexpire = true,
				warningtime = 6,
				soundson = true,
				bar = "$m",
				warningsound = "Bell",
				expiredsound = "Info",
				fg = { 1, 0.55, 0.2 },
				bg = { 0.2, 0.2, 0.2 },
				nontargetanchor = "nontargeted",
				targetanchor = "targeted",
				nontargetalpha = 1.0,
				targetalpha = 1.0,
				clearooc = true,
				icon = "Interface\\Icons\\Spell_Fire_Burnout"
			},
			b = { -- Winter's Chill, unused
			},
			c = { -- Living Bomb
				message = format(L["%s Exploded on $m"], L["Living Bomb"]),
				warning = format(L["$m Is About To Blow!"], L["Living Bomb"]),
				track = true,
				show = true,
				showproc = false,
				showwarning = true,
				showexpire = true,
				warningtime = 0,
				soundson = true,
				bar = "$m",
				warningsound = "Bell",
				expiredsound = "Info",
				fg = { 1, 0, 0 },
				bg = { 0.2, 0.2, 0.2 },
				nontargetanchor = "nontargeted",
				targetanchor = "targeted",
				nontargetalpha = 1.0,
				targetalpha = 1.0,
				clearooc = true,
				icon = "Interface\\Icons\\Ability_Mage_LivingBomb"
			},
			d = { -- Polymorph
				message = format(L["%s Broken on $m"], L["Polymorph"]),
				warning = format(L["Resheep $m!"], L["Polymorph"]),
				track = true,
				show = true,
				showproc = false,
				showwarning = true,
				showexpire = true,
				telltale = true,
				warningtime = 6,
				soundson = true,
				bar = "$m",
				warningsound = "Bell",
				expiredsound = "Info",
				fg = { 1, 0, 0.5 },
				bg = { 0.2, 0.2, 0.2 },
				nontargetanchor = "nontargeted",
				targetanchor = "targeted",
				nontargetalpha = 1.0,
				targetalpha = 1.0,
				clearooc = true,
				icon = "Interface\\Icons\\Spell_Nature_Polymorph"
			},
			e = { -- Slow
				message = format(L["%s Faded on $m"], L["Slow"]),
				warning = format(L["Recast %s on $m!"], L["Slow"]),
				track = true,
				show = true,
				showproc = false,
				showwarning = true,
				showexpire = true,
				warningtime = 6,
				soundson = true,
				bar = "$m",
				warningsound = "Bell",
				expiredsound = "Info",
				fg = { 0, 0, 0.5 },
				bg = { 0.2, 0.2, 0.2 },
				nontargetanchor = "nontargeted",
				targetanchor = "targeted",
				nontargetalpha = 1.0,
				targetalpha = 1.0,
				clearooc = true,
				icon = "Interface\\Icons\\Spell_Nature_Slow"
			},
			f = { -- Hot Streak
				apply = format(L["%s!"], L["Hot Streak"]),
				message = format(L["%s Faded"], L["Hot Streak"]),
				warning = format(L["Use %s Soon!"], L["Hot Streak"]),
				track = true,
				show = true,
				showproc = true,
				showwarning = true,
				showexpire = true,
				warningtime = 3,
				soundson = true,
				bar = L["Hot Streak"],
				procsound = "Ping",
				warningsound = "Bell",
				expiredsound = "Info",
				fg = { 1, 0.2, 0 },
				bg = { 0.2, 0.2, 0.2 },
				nontargetanchor = "buffs",
				targetanchor = "buffs",
				nontargetalpha = 1.0,
				targetalpha = 1.0,
				clearooc = false,
				icon = "Interface\\Icons\\Ability_Mage_HotStreak"
			},
			g = { -- Arcane Missiles
				apply = format(L["%s!"], L["Arcane Missiles"]),
				message = format(L["%s Faded"], L["Arcane Missiles"]),
				warning = format(L["Use %s Soon!"], L["Arcane Missiles"]),
				track = true,
				show = true,
				showproc = true,
				showwarning = true,
				showexpire = true,
				warningtime = 5,
				soundson = true,
				bar = format(L["$sx %s"], L["Arcane Missiles"]),
				procsound = "Ping",
				warningsound = "Bell",
				expiredsound = "Info",
				fg = { 0.4, 0.8, 1 },
				bg = { 0.2, 0.2, 0.2 },
				nontargetanchor = "buffs",
				targetanchor = "buffs",
				nontargetalpha = 1.0,
				targetalpha = 1.0,
				clearooc = false,
				icon = "Interface\\Icons\\Spell_Arcane_Arcane04"
			},
			h = { -- Heating Up
				apply = format(L["%s!"], L["Heating Up"]),
				message = format(L["%s Faded"], L["Heating Up"]),
				warning = format(L["Use %s Soon!"], L["Heating Up"]),
				track = true,
				show = true,
				showproc = true,
				showwarning = true,
				showexpire = true,
				warningtime = 3,
				soundson = true,
				bar = L["Heating Up"],
				procsound = "Ping",
				warningsound = "Bell",
				expiredsound = "Info",
				fg = { 0, 1, 0 },
				bg = { 0.2, 0.2, 0.2 },
				nontargetanchor = "buffs",
				targetanchor = "buffs",
				nontargetalpha = 1.0,
				targetalpha = 1.0,
				clearooc = false,
				icon = "Interface\\Icons\\Ability_Mage_HotStreak"
			},
			i = { -- Arcane Charge
				message = "",
				warning = "",
				track = true,
				show = true,
				showproc = false,
				showwarning = false,
				showexpire = false,
				warningtime = 5,
				soundson = false,
				bar = format(L["$sx %s"], L["Arcane Charge"]),
				procsound = "None",
				warningsound = "None",
				expiredsound = "None",
				fg = { 1, 0.8, 0.4 },
				bg = { 0.2, 0.2, 0.2 },
				nontargetanchor = "buffs",
				targetanchor = "buffs",
				nontargetalpha = 1.0,
				targetalpha = 1.0,
				clearooc = false,
				icon = "Interface\\Icons\\Spell_Arcane_Arcane01"
			},
			j = { -- Brain Freeze
				apply = format(L["%s!"], L["Brain Freeze"]),
				message = format(L["%s Faded"], L["Brain Freeze"]),
				warning = format(L["Use %s Soon!"], L["Brain Freeze"]),
				track = true,
				show = true,
				showproc = true,
				showwarning = true,
				showexpire = true,
				warningtime = 5,
				soundson = true,
				bar = L["Brain Freeze"],
				procsound = "Ping",
				warningsound = "Bell",
				expiredsound = "Info",
				fg = { 0.2, 0.4, 1 },
				bg = { 0.2, 0.2, 0.2 },
				nontargetanchor = "buffs",
				targetanchor = "buffs",
				nontargetalpha = 1.0,
				targetalpha = 1.0,
				clearooc = false,
				icon = "Interface\\Icons\\Ability_Mage_BrainFreeze"
			},
			k = { -- Fingers of Frost
				apply = format(L["%s!"], L["Fingers of Frost"]),
				message = format(L["%s Faded"], L["Fingers of Frost"]),
				warning = format(L["Use %s Soon!"], L["Fingers of Frost"]),
				track = true,
				show = true,
				showproc = true,
				showwarning = true,
				showexpire = true,
				warningtime = 5,
				soundson = true,
				bar = format("$sx %s", L["Fingers of Frost"]),
				procsound = "Ping",
				warningsound = "Bell",
				expiredsound = "Info",
				fg = { 0.2, 0.2, 1 },
				bg = { 0.2, 0.2, 0.2 },
				nontargetanchor = "buffs",
				targetanchor = "buffs",
				nontargetalpha = 1.0,
				targetalpha = 1.0,
				clearooc = false,
				icon = "Interface\\Icons\\Ability_Mage_Wintersgrasp"
			},
			l = { -- Shadow Mastery, removed
			},
			m = { -- Water Elemental, removed
			},
			n = { -- Mirror Image
				message = format(L["%s: Full Threat Restored"], L["Mirror Image"]),
				warning = format(L["%s: Threat Reduction Fading!"], L["Mirror Image"]),
				track = true,
				show = true,
				showwarning = true,
				showexpire = true,
				warningtime = 5,
				soundson = true,
				bar = L["Mirror Image"],
				warningsound = "Bell",
				expiredsound = "Info",
				fg = { 0.2, 1, 0 },
				bg = { 0.2, 0.2, 0.2 },
				nontargetanchor = "buffs",
				targetanchor = "buffs",
				nontargetalpha = 1.0,
				targetalpha = 1.0,
				clearooc = false,
				icon = "Interface\\Icons\\Spell_Magic_LesserInvisibilty"
			},
			o = { -- Torment the Weak, removed
			},
			p = { -- 5% Spell Damage
				message = format(L["%s Faded on $m"], L["8% Spell Damage"]),
				warning = "",
				track = true,
				show = true,
				showwarning = false,
				showexpire = true,
				warningtime = 0,
				soundson = true,
				bar = L["8% Spell Damage"],
				warningsound = "None",
				expiredsound = "Info",
				fg = { 0, 0, 0 },
				bg = { 0.2, 0.2, 0.2 },
				nontargetanchor = "nontargeted",
				targetanchor = "targeted",
				nontargetalpha = 1.0,
				targetalpha = 1.0,
				clearooc = true,
				icon = "Interface\\Icons\\INV_Enchant_EssenceMagicLarge"
			},
			q = { -- Frostfire Bolt, removed
			},
			r = { -- Impact, removed
			},
			s = { -- Improved Polymorph, removed
			},
			t = { -- Ignite
				message = "",
				warning = "",
				track = true,
				show = true,
				showproc = false,
				showwarning = false,
				showexpire = false,
				warningtime = 5,
				soundson = false,
				bar = "$m",
				procsound = "None",
				warningsound = "None",
				expiredsound = "None",
				fg = { 0.95, 0.95, 0.95 },
				bg = { 0.2, 0.2, 0.2 },
				nontargetanchor = "none",
				targetanchor = "targeted",
				nontargetalpha = 1.0,
				targetalpha = 1.0,
				clearooc = true,
				icon = "Interface\\Icons\\Spell_Fire_Incinerate"
			},
			u = { -- Pyroblast
				message = "",
				warning = "",
				track = true,
				show = true,
				showproc = false,
				showwarning = false,
				showexpire = false,
				warningtime = 5,
				soundson = false,
				bar = "$m",
				procsound = "None",
				warningsound = "None",
				expiredsound = "None",
				fg = { 0.75, 0.7, 1 },
				bg = { 0.2, 0.2, 0.2 },
				nontargetanchor = "none",
				targetanchor = "targeted",
				nontargetalpha = 1.0,
				targetalpha = 1.0,
				clearooc = true,
				icon = "Interface\\Icons\\Spell_Fire_Fireball02"
			},
			v = { -- Flamestrike
				message = "",
				warning = "",
				track = true,
				show = true,
				showproc = false,
				showwarning = false,
				showexpire = false,
				warningtime = 5,
				soundson = false,
				bar = L["Flamestrike"],
				procsound = "None",
				warningsound = "None",
				expiredsound = "None",
				fg = { 1, 0.06666666666666667, 0 },
				bg = { 0.2, 0.2, 0.2 },
				nontargetanchor = "buffs",
				targetanchor = "buffs",
				nontargetalpha = 1.0,
				targetalpha = 1.0,
				clearooc = true,
				icon = "Interface\\Icons\\Spell_Fire_SelfDestruct"
			},
			w = { -- Invocation
				apply = format(L["%s!"], L["Invocation"]),
				message = format(L["%s Faded"], L["Invocation"]),
				warning = format(L["Use %s Soon!"], L["Invocation"]),
				track = true,
				show = true,
				showproc = true,
				showwarning = true,
				showexpire = true,
				warningtime = 3,
				soundson = true,
				bar = L["Invocation"],
				procsound = "Ping",
				warningsound = "Bell",
				expiredsound = "Info",
				fg = { 1, 0.5, 1 },
				bg = { 0.2, 0.2, 0.2 },
				nontargetanchor = "buffs",
				targetanchor = "buffs",
				nontargetalpha = 1.0,
				targetalpha = 1.0,
				clearooc = false,
				icon = "Interface\\Icons\\Spell_Arcane_Arcane03"
			},
			x = { -- Nether Tempest
				message = format(L["%s Exploded on $m"], L["Nether Tempest"]),
				warning = format(L["$m Is About To Blow!"], L["Nether Tempest"]),
				track = true,
				show = true,
				showproc = false,
				showwarning = true,
				showexpire = true,
				warningtime = 0,
				soundson = true,
				bar = "$m",
				warningsound = "Bell",
				expiredsound = "Info",
				fg = { 1, 0, 0 },
				bg = { 0.2, 0.2, 0.2 },
				nontargetanchor = "nontargeted",
				targetanchor = "targeted",
				nontargetalpha = 1.0,
				targetalpha = 1.0,
				clearooc = true,
				icon = "Interface\\Icons\\Spell_Mage_NetherTempest"
			},
			y = { -- Frost Bomb
				message = "",
				warning = "",
				track = true,
				show = true,
				showproc = false,
				showwarning = false,
				showexpire = false,
				warningtime = 0,
				soundson = false,
				bar = L["Frost Bomb"],
				procsound = "None",
				warningsound = "None",
				expiredsound = "Info",
				fg = { 0.15, 0.75, 0.95 },
				bg = { 0.2, 0.2, 0.2 },
				nontargetanchor = "buffs",
				targetanchor = "buffs",
				nontargetalpha = 1.0,
				targetalpha = 1.0,
				clearooc = false,
				icon = "Interface\\Icons\\Spell_Mage_FrostBomb"
			},
			z = { -- Combustion
				message = "",
				warning = "",
				track = true,
				show = true,
				showproc = false,
				showwarning = false,
				showexpire = false,
				warningtime = 5,
				soundson = false,
				bar = "$m",
				procsound = "None",
				warningsound = "None",
				expiredsound = "None",
				fg = { 1, 0.06666666666666667, 0 },
				bg = { 0.2, 0.2, 0.2 },
				nontargetanchor = "none",
				targetanchor = "targeted",
				nontargetalpha = 1.0,
				targetalpha = 1.0,
				clearooc = true,
				icon = "Interface\\Icons\\Spell_Fire_SealOfFire"
			},
		},
		sinkoptions = { },
		debug = {
			duplicates = false,
			sync = false,
			mob = false,
			code = false,
			timers = false,
			log = false
		},
	},
}

-- Add-on Functions
function Scorchio2:OnInitialize()
	Scorchio2DB = Scorchio2DB or { dbversion = DBVERSION }
	if Scorchio2DB.dbversion ~= DBVERSION then
		-- Two things go on here. First, we have to load the Options to get the logic for upgrading databases.
		-- Second, because we loaded the options, we're responsible for calling :InitOptions.
		EnableAddOn("Scorchio2_Options")
		LoadAddOn("Scorchio2_Options")
		self:UpgradeDatabase(Scorchio2DB, DBVERSION)
		DB = LibStub("AceDB-3.0"):New("Scorchio2DB", defaults, true)
		Scorchio2:InitOptions(DB, T, VULNDATA)
	else
		DB = LibStub("AceDB-3.0"):New("Scorchio2DB", defaults, true)
	end
	Scorchio2.db = DB

	do
		local function LoadOptions()
			if Scorchio2.options_table then return end
			EnableAddOn("Scorchio2_Options")
			LoadAddOn("Scorchio2_Options")
			Scorchio2:InitOptions(DB, T, VULNDATA)
		end

		-- Command-line stubs for opening options.
		local function OpenOptions()
			LoadOptions()
			LibStub("AceConfigDialog-3.0"):Open("Scorchio2")
		end
		Scorchio2:RegisterChatCommand("scorchio", OpenOptions)
		Scorchio2:RegisterChatCommand("scorchio2", OpenOptions)

		-- UI stub for opening options, but only if we need it.
		-- Options might have already loaded for the DB upgrade.
		if not Scorchio2.options_table then
			local dummyOptionsFrame = CreateFrame("Frame")
			dummyOptionsFrame.name = "Scorchio2"
			dummyOptionsFrame:Hide()
			dummyOptionsFrame:SetScript("OnShow", function(frame)
				frame:SetScript("OnShow", nil)
				frame:Hide()
				LoadOptions()
				InterfaceOptionsFrame_OpenToCategory("Scorchio2")
			end)
			InterfaceOptions_AddCategory(dummyOptionsFrame, "Scorchio2")
		end
	end

	Scorchio2:SetSinkStorage(DB.profile.sinkoptions)

	DB.RegisterCallback(Scorchio2, "OnProfileCopied", "UpdateAnchors")
	DB.RegisterCallback(Scorchio2, "OnProfileReset", "UpdateAnchors")

	SM.RegisterCallback(Scorchio2, "LibSharedMedia_Registered", "UpdateAnchors")
	SM.RegisterCallback(Scorchio2, "LibSharedMedia_SetGlobal", "UpdateAnchors")

	Scorchio2:CreateAnchor("targeted")
	Scorchio2:CreateAnchor("nontargeted")
	Scorchio2:CreateAnchor("buffs")

	playerGUID = UnitGUID("player")
	lastTargetGUID = "0"
	mobTable = { }
	Scorchio2.mobTable = mobTable
	combatFlag = false
end

function Scorchio2:OnEnable()
	Scorchio2:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	Scorchio2:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "SpecialChecks")
	Scorchio2:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", "SpecialChecks")
	Scorchio2:RegisterEvent("UNIT_AURA", "SpecialChecks")
	Scorchio2:RegisterEvent("PLAYER_ENTERING_WORLD")
	Scorchio2:RegisterEvent("PLAYER_REGEN_ENABLED")
	Scorchio2:RegisterEvent("PLAYER_REGEN_DISABLED")
	Scorchio2:RegisterEvent("PLAYER_TARGET_CHANGED")
end

function Scorchio2:OnDisable()
	Scorchio2:UnregisterAllEvents()
end

-- Bar and Anchor Functions
function Scorchio2:CreateAnchor(anchor)
	Scorchio2[anchor] = Scorchio2:NewBarGroup(anchor, nil, DB.profile.anchoroptions[anchor].width, DB.profile.anchoroptions[anchor].height)
	Scorchio2[anchor]:ClearAllPoints()

	Scorchio2[anchor].id = anchor
	Scorchio2[anchor].RegisterCallback(Scorchio2, "AnchorClicked", "AnchorClicked")
	Scorchio2[anchor]:HideAnchor()
	Scorchio2[anchor]:SetSortFunction(Scorchio2.SortBars)
	Scorchio2:UpdateAnchor(anchor)
end

function Scorchio2:FadeBar(tableEntry)
	local bar = tableEntry[BAR]
	if bar then
		tableEntry[BAR] = nil
		if bar:GetAlpha() == 1 and not bar:IsFading() then
			bar:Fade(0.5)
		end
	end
end

function Scorchio2:RunTest(anchor)
	if anchor == "buffs" then
		Scorchio2:UpdateTable("Test1", "Pyroblast!", VULNERABILITIES[48108], GetTime(), 1, nil, nil, anchor)
		Scorchio2:UpdateTable("Test2", "Arcane Missiles!", VULNERABILITIES[79683], GetTime(), 1, nil, nil, anchor)
	else
		Scorchio2:UpdateTable("Test1", "Test Mob 1", VULNERABILITIES[132210], GetTime(), 1, nil, nil, anchor)
		Scorchio2:UpdateTable("Test2", "Test Mob 2", VULNERABILITIES[44457], GetTime(), 1, nil, nil, anchor)
		Scorchio2:UpdateTable("Test3", "Test Mob 3", VULNERABILITIES[118], GetTime(), 1, nil, nil, anchor)
		Scorchio2:UpdateTable("Test4", "Test Mob 4", VULNERABILITIES[31589], GetTime(), 1, nil, nil, anchor)
	end
end

function Scorchio2:AnchorClicked(callback, group, button)
	Scorchio2:SavePosition(group.id)
	if button == "RightButton" then
		group:HideAnchor()
		group:Lock()
	end
end
function Scorchio2:ToggleAnchors(anchor)
	if Scorchio2[anchor].button:IsVisible() then
		Scorchio2[anchor]:HideAnchor()
		Scorchio2[anchor]:Lock()
	else
		Scorchio2[anchor]:ShowAnchor()
		Scorchio2[anchor]:Unlock()
	end
end

function Scorchio2:SavePosition(anchor)
	local p,_,pr,px,py = Scorchio2[anchor]:GetPoint()
	DB.profile.anchoroptions[anchor].position.p = p
	DB.profile.anchoroptions[anchor].position.pr = pr
	DB.profile.anchoroptions[anchor].position.px = px
	DB.profile.anchoroptions[anchor].position.py = py
end

function Scorchio2:UpdateAnchor(anchor)
	Scorchio2[anchor]:SetTexture(SM:Fetch("statusbar", DB.profile.anchoroptions[anchor].texture))
	Scorchio2[anchor]:SetFont(SM:Fetch("font", DB.profile.anchoroptions[anchor].font), DB.profile.anchoroptions[anchor].fontsize)
	Scorchio2[anchor]:SetWidth(DB.profile.anchoroptions[anchor].width)
	Scorchio2[anchor]:SetHeight(DB.profile.anchoroptions[anchor].height)
	Scorchio2[anchor]:SetScale(DB.profile.anchoroptions[anchor].scale)
	Scorchio2[anchor]:ReverseGrowth(DB.profile.anchoroptions[anchor].growth)
	Scorchio2[anchor]:SetOrientation(DB.profile.anchoroptions[anchor].orientation)
	if DB.profile.anchoroptions[anchor].maxbars == 0 then
		Scorchio2[anchor]:SetMaxBars(nil)
	else
		Scorchio2[anchor]:SetMaxBars(DB.profile.anchoroptions[anchor].maxbars)
	end
	Scorchio2[anchor]:SetFlashPeriod(0)

	if DB.profile.anchoroptions[anchor].flash then
		Scorchio2[anchor]:SetFlashPeriod(DB.profile.anchoroptions[anchor].flashtime)
	end

	if not DB.profile.anchoroptions[anchor].position then DB.profile.anchoroptions[anchor].position = {} end
	if DB.profile.anchoroptions[anchor].position.p
	and DB.profile.anchoroptions[anchor].position.pr
	and DB.profile.anchoroptions[anchor].position.px
	and DB.profile.anchoroptions[anchor].position.py then
		Scorchio2[anchor]:ClearAllPoints()
		Scorchio2[anchor]:SetPoint(DB.profile.anchoroptions[anchor].position.p, UIParent, DB.profile.anchoroptions[anchor].position.pr, DB.profile.anchoroptions[anchor].position.px, DB.profile.anchoroptions[anchor].position.py)
		else
			Scorchio2[anchor]:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		end
end

function Scorchio2:UpdateAnchors()
	Scorchio2:UpdateAnchor("targeted")
	Scorchio2:UpdateAnchor("nontargeted")
	Scorchio2:UpdateAnchor("buffs")
end

function Scorchio2.SortBars(a, b)
	if a.isTimer ~= b.isTimer then
		return a.isTimer
	end

	if a.maxValue == b.maxValue then
		if a.value == b.value then
			return a.name > b.name
		else
			return a.value > b.value
		end
	else
		return a.maxValue > b.maxValue
	end
end


-- Event Handling Functions


function Scorchio2:inCombat()
	if combatFlag then return true end
	if InCombatLockdown("player") then return true end
	return false
end

function Scorchio2:COMBAT_LOG_EVENT_UNFILTERED(_, _, event, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...)
	local _, _, prefix, suffix = strfind(event, "(.-)_(.+)")

	local timeStamp = GetTime()

	if (prefix == "SPELL") then
		local spellID, spellName, spellSchool, spellAuraType, spellCount, fvApplied
		local spellCount = -1
		local spellID = ...
		local isPlayer = false
		if bit_band(dstFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == COMBATLOG_OBJECT_TYPE_PLAYER then
			isPlayer = true
		end

		if (suffix == "CAST_START") then
			if Scorchio2:inCombat() then return end
			if SPELLIDS[spellID] and bit_band(srcFlags, AFFILIATION) ~= 0 then
				Scorchio2:PLAYER_REGEN_DISABLED()
			end
		elseif (suffix == "CAST_FAILED") then
			if InCombatLockdown("player") then return end
			Scorchio2:PLAYER_REGEN_ENABLED()
		elseif (suffix == "CAST_SUCCESS") then
			if (spellID == 2136 or spellID == 108853) and mobTable[dstGUID] then
				-- Fire Blast or Inferno Blast.
				impactTimestamp = timeStamp
				impactLBExpire = mobTable[dstGUID].c and mobTable[dstGUID].c[EXPIRATIONTIME] or nil
				impactIgniteExpire = mobTable[dstGUID].t and mobTable[dstGUID].t[EXPIRATIONTIME] or nil
				impactPyroblastExpire = mobTable[dstGUID].u and mobTable[dstGUID].u[EXPIRATIONTIME] or nil
				impactCombustionExpire = mobTable[dstGUID].z and mobTable[dstGUID].z[EXPIRATIONTIME] or nil
			end
		elseif (suffix == "DAMAGE") then
			if spellID == 2120 and bit_band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) ~= 0 and DB.profile.baroptions.v.track then
				-- Flamestrike
				Scorchio2:UpdateTable(srcGUID, srcName, 18, timeStamp, 1, true, 8)
			end
		elseif (suffix == "AURA_REMOVED") then
			spellCount = -1
			local spellID = ...
			Scorchio2:CheckVuln(spellID, spellCount, timeStamp, dstGUID, dstName, isPlayer, srcFlags, dstFlags, srcGUID)
		elseif (suffix == "SUMMON") then
			if spellID == 58833 and bit_band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) ~= 0 and DB.profile.baroptions.n.track then
				Scorchio2:UpdateTable(srcGUID, srcName, VULNERABILITIES[55342], timeStamp, 1, true, 30)
			end
		elseif (suffix == "AURA_APPLIED") then
			-- For the aura checks, we need to check the player himself even if not in combat, for procs.  Using the SPELLIDS table 
			-- could have worked for the most part, by making CAST_SUCCESS also trigger PLAYER_REGEN_DISABLED, and adding Barrage etc
			-- to the SPELLIDS list...but it would have never worked for pet Freeze (auras are applied before it casts/hits). So we do this.
			if (not Scorchio2:inCombat()) and (dstGUID ~= playerGUID) then return end
			spellCount = 1
			local spellID = ...
			Scorchio2:CheckVuln(spellID, spellCount, timeStamp, dstGUID, dstName, isPlayer, srcFlags, dstFlags, srcGUID)
		elseif (suffix == "AURA_APPLIED_DOSE") then
			if (not Scorchio2:inCombat()) and (dstGUID ~= playerGUID) then return end
			local spellID,_,_,_,spellCount = ...
			Scorchio2:CheckVuln(spellID, spellCount, timeStamp, dstGUID, dstName, isPlayer, srcFlags, dstFlags, srcGUID)
		elseif (suffix == "AURA_REFRESH") then
			if (not Scorchio2:inCombat()) and (dstGUID ~= playerGUID) then return end
			local spellID = ...
			Scorchio2:CheckVuln(spellID, nil, timeStamp, dstGUID, dstName, isPlayer, srcFlags, dstFlags, srcGUID)
		elseif (suffix == "AURA_REMOVED_DOSE") then
			if (not Scorchio2:inCombat()) and (dstGUID ~= playerGUID) then return end
			local spellID,_,_,_,spellCount = ...
			Scorchio2:CheckVuln(spellID, spellCount, timeStamp, dstGUID, dstName, isPlayer, srcFlags, dstFlags, srcGUID)
		elseif (suffix == "AURA_BROKEN_SPELL") then
			if not Scorchio2:inCombat() then return end
			local _,_,_,_,spellCount = ...
			Scorchio2:AuraBroken(dstGUID, srcName, spellCount)
		elseif (suffix == "AURA_BROKEN") then
			if not Scorchio2:inCombat() then return end
			Scorchio2:AuraBroken(dstGUID, srcName, L["Hitting It!"])
		end
	elseif (prefix == "UNIT") then
		if dstName ~= nil and mobTable[dstGUID] ~= nil then
			Scorchio2:MobDies(dstGUID, dstName)
		end
	end
end

function Scorchio2:SPELL_UPDATE_COOLDOWN()
	-- Frost Bomb cooldown.
	local cdStart, cdLength = GetSpellCooldown(112948)
	if cdStart > 0 then
		self:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
		local now = GetTime()
		Scorchio2:UpdateTable(playerGUID, "", 21, now, 1, true, cdLength - (now - cdStart))
	end
end

function Scorchio2:SpecialChecks(event, unitid, _, _, _, spellID)
	if unitid == "player" then
		-- UNIT_AURA trigging ScanAuras() is used to handle several things, such as to capture a 
		-- refresh of Arcane Charge and some other buff-based procs while they're at max stacks, 
		-- and also because of Alter Time.
		if event == "UNIT_AURA" then
			Scorchio2:ScanAuras("player")
		elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" and SPELLIDS[spellID] then
			if not self:inCombat() then
				self:PLAYER_REGEN_DISABLED()
			end
		elseif event == "UNIT_SPELLCAST_SUCCEEDED" and spellID == 112948 then
			-- This is Frost Bomb. We need to wait for a further event though.
			self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
		end
	end
end

function Scorchio2:PLAYER_ENTERING_WORLD()
	playerGUID = UnitGUID("player")
end

function Scorchio2:PLAYER_REGEN_ENABLED()
	combatFlag = false
	for k, v in pairs(mobTable) do
		for kk = 1,#T do
			if DB.profile.baroptions[T[kk]].clearooc then
				if mobTable[k][T[kk]] then
					self:FadeBar(mobTable[k][T[kk]])
					if mobTable[k][T[kk]][TIMER] then
						Scorchio2:CancelTimer(mobTable[k][T[kk]][TIMER], true)
						mobTable[k][T[kk]][TIMER] = nil
					end
					mobTable[k][T[kk]] = nil
				end
			end
		end
	end
	lastTargetGUID = "0"
end

function Scorchio2:PLAYER_REGEN_DISABLED()
	combatFlag = true
	Scorchio2:ScanAuras("target")
end

function Scorchio2:PLAYER_TARGET_CHANGED()
	if mobTable[lastTargetGUID] then
		for k = 1,#T do
			if mobTable[lastTargetGUID][T[k]] then
				if mobTable[lastTargetGUID][T[k]][BAR] then
					self:FadeBar(mobTable[lastTargetGUID][T[k]])
					Scorchio2:UpdateTable(lastTargetGUID, mobTable[lastTargetGUID][T[k]][MOBNAME], k, GetTime(), mobTable[lastTargetGUID][T[k]][STACK], false, mobTable[lastTargetGUID][T[k]][EXPIRATIONTIME]-GetTime(),DB.profile.baroptions[T[k]].nontargetanchor, DB.profile.baroptions[T[k]].nontargetalpha)
				end
			end
		end
	end
	if UnitExists("target") then
		lastTargetGUID = UnitGUID("target")
		for k = 1,#T do
			if mobTable[lastTargetGUID] then
				if mobTable[lastTargetGUID][T[k]] then
					if mobTable[lastTargetGUID][T[k]][BAR] then
						self:FadeBar(mobTable[lastTargetGUID][T[k]])
						Scorchio2:UpdateTable(lastTargetGUID, mobTable[lastTargetGUID][T[k]][MOBNAME], k, GetTime(), mobTable[lastTargetGUID][T[k]][STACK], false, mobTable[lastTargetGUID][T[k]][EXPIRATIONTIME]-GetTime(),DB.profile.baroptions[T[k]].targetanchor, DB.profile.baroptions[T[k]].targetalpha)
					end
				end
			end
		end
		Scorchio2:ScanAuras("target")
	else
		lastTargetGUID = "0"
	end
end

-- mobTable Handling Functions
function Scorchio2:MobDies(dstGUID, dstName)
	for k = 1,#T do
		if mobTable[dstGUID][T[k]] then
			self:FadeBar(mobTable[dstGUID][T[k]])
			if mobTable[dstGUID][T[k]][TIMER] then
				Scorchio2:CancelTimer(mobTable[dstGUID][T[k]][TIMER], true)
				mobTable[dstGUID][T[k]][TIMER] = nil
			end
		end
	end
	mobTable[dstGUID] = nil
--~     raidIconTable[self:GetGUID(fullMobName)] = nil
--~     self:UnregisterEnniBarWithGroup(fullMobName,SB)
--~     self:UnregisterEnniBar(fullMobName)
end

function Scorchio2:CheckVuln(spellID, spellCount, timeStamp, dstGUID, dstName, isPlayer, srcFlags, dstFlags, srcGUID)
	local k = VULNERABILITIES[spellID]
	if k then
		if VULNDATA[k].self then
			if dstGUID == playerGUID and bit_band(dstFlags, VULNDATA[k].valid) ~= 0 and DB.profile.baroptions[T[k]].track then
				Scorchio2:UpdateTable(dstGUID, dstName, k, timeStamp, spellCount, isPlayer)
				Scorchio2:ScanAuras("player")
			end
		else
			if bit_band(srcFlags, VULNDATA[k].valid) ~= 0 and DB.profile.baroptions[T[k]].track then
				Scorchio2:UpdateTable(dstGUID, dstName, k, timeStamp, spellCount, isPlayer)
				if dstGUID == UnitGUID("target") then
					Scorchio2:ScanAuras("target")
				elseif dstGUID == UnitGUID("mouseover") then
					Scorchio2:ScanAuras("mouseover")
				elseif dstGUID == UnitGUID("focus") then
					Scorchio2:ScanAuras("focus")
				end
			end
		end
	end
end


function Scorchio2:AuraBroken(dstGUID, srcName, cause)
	if dstGUID then
		if mobTable[dstGUID] then
			if mobTable[dstGUID][T[4]] and DB.profile.baroptions.d.telltale then
				local telltale = format(L["%s Broken on $m by $n"], L["Polymorph"])
				telltale = telltale:gsub("$m", tostring(mobTable[dstGUID][T[4]][MOBNAME]))
				telltale = telltale:gsub("$n", srcName)
				telltale = telltale .. " (" .. tostring(cause) .. ")"
				Scorchio2:Pour(telltale, 1, 1, 1)
				Scorchio2:Print(telltale)
			end
		end
	end
end

function Scorchio2:LostVuln(dstGUID, vulnKey)
	self:FadeBar(mobTable[dstGUID][T[vulnKey]])
	if mobTable[dstGUID][T[vulnKey]][TIMER] then
		Scorchio2:CancelTimer(mobTable[dstGUID][T[vulnKey]][TIMER], true)
		mobTable[dstGUID][T[vulnKey]][TIMER] = nil
	end

	if Scorchio2:inCombat() or not DB.profile.baroptions[T[vulnKey]].clearooc then
		if GetTime() - mobTable[dstGUID][T[vulnKey]][REFRESHTIME] > ( mobTable[dstGUID][T[vulnKey]][DURATION] - 0.25 ) then
			if DB.profile.baroptions[T[vulnKey]].soundson then
				PlaySoundFile(SM:Fetch("sound", DB.profile.baroptions[T[vulnKey]].expiredsound), "Master")
			end
			if DB.profile.baroptions[T[vulnKey]].showexpire then
				Scorchio2:Pour(SubTokens(DB.profile.baroptions[T[vulnKey]].message, mobTable[dstGUID][T[vulnKey]][MOBNAME]), 1, 0, 0)
			end
		end
	end

	mobTable[dstGUID][T[vulnKey]] = nil
end

function Scorchio2:TimerComplete(info)
	local dstGUID, vulnKey = info[1], info[2]
	local timerTime = GetTime()
	if mobTable[dstGUID][T[vulnKey]] then
		if floor((timerTime - mobTable[dstGUID][T[vulnKey]][REFRESHTIME]) + 0.5) >= (mobTable[dstGUID][T[vulnKey]][DURATION] - DB.profile.baroptions[T[vulnKey]].warningtime) then
			if DB.profile.baroptions[T[vulnKey]].soundson then
				PlaySoundFile(SM:Fetch("sound", DB.profile.baroptions[T[vulnKey]].warningsound), "Master")
			end
			Scorchio2:Pour(SubTokens(DB.profile.baroptions[T[vulnKey]].warning, mobTable[dstGUID][T[vulnKey]][MOBNAME]), 1, 0.647, 0)
		end
	end
end


function Scorchio2:ScanAuras(unitID)
	if not UnitExists(unitID) then return end
	-- Don't return if not in combat and the unit is the player, because Alter Time doesn't trigger combat
	-- and it can change the stacks/duration on Arcane Charge and buff-based procs even while no longer
	-- in combat.
	if (unitID ~= "player") and (not Scorchio2:inCombat()) then return end
	local dstGUID = UnitGUID(unitID)
	local dstName = UnitName(unitID)
	local isPlayer = UnitIsPlayer(unitID)
	if isPlayer == nil then isPlayer = false end
	
	-- If the unit is the player, we need to scan him for any updates to buff-based procs because of Alter Time, 
	-- although this same logic also handles some other previously broken situations (such as refreshing an AM
	-- 2-stack before using it).  No need to ever check buffs on any other units, though.
	if (unitID == "player") then
		for i = 1, 40 do
			local _, _, icon, count, _, _, expirationTime, unitCaster, _, _, spellID = UnitBuff(unitID, i)
			if icon == nil then break end
			local isVuln = VULNERABILITIES[spellID]
			if isVuln and DB.profile.baroptions[T[isVuln]].track then
				if (VULNDATA[isVuln].valid == COMBATLOG_OBJECT_AFFILIATION_MINE and unitCaster == "player") or VULNDATA[isVuln].valid ~= COMBATLOG_OBJECT_AFFILIATION_MINE then
					local now = GetTime()
					Scorchio2:UpdateTable(dstGUID, dstName, isVuln, now, count, isPlayer, expirationTime - now)
				end
			end
		end
	end
	
	for i = 1, 40 do
		local _, _, icon, count, _, _, expirationTime, unitCaster, _, _, spellID = UnitDebuff(unitID, i)
		if icon == nil then break end
		local isVuln = VULNERABILITIES[spellID]
		if isVuln and DB.profile.baroptions[T[isVuln]].track then
			if (VULNDATA[isVuln].valid == COMBATLOG_OBJECT_AFFILIATION_MINE and unitCaster == "player") or VULNDATA[isVuln].valid ~= COMBATLOG_OBJECT_AFFILIATION_MINE then
				local now = GetTime()
				Scorchio2:UpdateTable(dstGUID, dstName, isVuln, now, count, isPlayer, expirationTime - now)
			end
		end
	end
end

function Scorchio2:UpdateTable(dstGUID, dstName, vulnKey, timeStamp, spellCount, isPlayer, timeToRun, anchor, alpha)
	if timeToRun and (timeToRun < 0) then
		-- This happens with Frost Bomb, since the vuln never gets cleared.
		return
	end
	
	if mobTable[dstGUID] == nil then
		mobTable[dstGUID] = { }
	end
	if mobTable[dstGUID][T[vulnKey]] == nil then
		mobTable[dstGUID][T[vulnKey]] = {dstName, timeStamp, 0, 0, 0, nil }
		if DB.profile.baroptions[T[vulnKey]].soundson then
			PlaySoundFile(SM:Fetch("sound", DB.profile.baroptions[T[vulnKey]].procsound), "Master")
		end
		if DB.profile.baroptions[T[vulnKey]].showproc then
			Scorchio2:Pour(DB.profile.baroptions[T[vulnKey]].apply, 1, 0, 0)
		end
	end

	if anchor == nil then
		if tostring(dstGUID) == UnitGUID("target") then
			lastTargetGUID = dstGUID
			anchor = DB.profile.baroptions[T[vulnKey]].targetanchor
			alpha = DB.profile.baroptions[T[vulnKey]].targetalpha
		else
			anchor = DB.profile.baroptions[T[vulnKey]].nontargetanchor
			alpha = DB.profile.baroptions[T[vulnKey]].nontargetalpha
		end
	end

	if spellCount == nil then spellCount = mobTable[dstGUID][T[vulnKey]][STACK] + 1 end
	if spellCount > VULNDATA[vulnKey].maxstacks then spellCount = VULNDATA[vulnKey].maxstacks end
	if spellCount < 0 then
		Scorchio2:LostVuln(dstGUID, vulnKey)
	else
		local warningTime = DB.profile.baroptions[T[vulnKey]].warningtime
		local icon = DB.profile.baroptions[T[vulnKey]].icon
		local now = GetTime()
		local save_expiration_time = false
		local duration
		if isPlayer == true then
			duration = VULNDATA[vulnKey].durationpvp
		else
			duration = VULNDATA[vulnKey].durationpve
		end

		-- Maintain time left on proc for Fingers of Frost / Arcane Missiles which can stack to 2 but don't refresh time when using 1
		if (VULNDATA[vulnKey].spellid == 79683 or VULNDATA[vulnKey].spellid == 44544) then
			save_expiration_time = (mobTable[dstGUID][T[vulnKey]][STACK] == spellCount + 1)
		end

		mobTable[dstGUID][T[vulnKey]][STACK] = spellCount
		mobTable[dstGUID][T[vulnKey]][REFRESHTIME] = timeStamp

		if timeToRun == nil then
			timeToRun = duration - (now - timeStamp)
			if (now - impactTimestamp < 1.0) then
				if vulnKey == VULNERABILITIES[44457] and impactLBExpire then
					timeToRun = impactLBExpire - timeStamp
				end
				if vulnKey == VULNERABILITIES[12654] and impactIgniteExpire then
					timeToRun = impactIgniteExpire - timeStamp
				end
				if vulnKey == VULNERABILITIES[11366] and impactPyroblastExpire then
					timeToRun = impactPyroblastExpire - timeStamp
				end
				if vulnKey == VULNERABILITIES[83853] and impactCombustionExpire then
					timeToRun = impactCombustionExpire - timeStamp
				end
			end
		end
		mobTable[dstGUID][T[vulnKey]][DURATION] = timeToRun
		if save_expiration_time then
			timeToRun = mobTable[dstGUID][T[vulnKey]][EXPIRATIONTIME] - now
		else
			mobTable[dstGUID][T[vulnKey]][EXPIRATIONTIME] = timeStamp + timeToRun
		end
		if mobTable[dstGUID][T[vulnKey]][BAR] then
			local bar = mobTable[dstGUID][T[vulnKey]][BAR]
			local overrun = bar.value - timeToRun
			if overrun > 0 and timeToRun > 0 and not save_expiration_time then
				bar:SetValue(timeToRun, bar.maxValue - overrun)
				return
			end
		end

		if DB.profile.baroptions[T[vulnKey]].show and anchor ~= "none" then
			if VULNDATA[vulnKey].unique then
				for k, v in pairs(mobTable) do
					if mobTable[k][T[vulnKey]] then
						self:FadeBar(mobTable[k][T[vulnKey]])
						if mobTable[k][T[vulnKey]][TIMER] then
							Scorchio2:CancelTimer(mobTable[k][T[vulnKey]][TIMER], true)
							mobTable[k][T[vulnKey]][TIMER] = nil
						end
					end
				end
			end

			local barText = SubTokens(DB.profile.baroptions[T[vulnKey]].bar, dstName, spellCount)

			local newBar = Scorchio2[anchor]:NewTimerBar(tostring(dstGUID .. "_" .. T[vulnKey]), barText, timeToRun, duration, icon, 0)
			mobTable[dstGUID][T[vulnKey]][BAR] = newBar
			local newAlpha = newBar:GetAlpha()
			if newAlpha < 1 then
				geterrorhandler()("new bar with alpha < 1: "..newAlpha)
				local debug = false
				--[===[@debug@
				debug = true
				--@end-debug@]===]
				if debug then
					-- Make the error more obvious, with this obnoxious sound.
					PlaySoundFile(SM:Fetch("sound", "Short Circuit"), "Master")
				else
					-- No need to bother the user with incorrect behavior; giving the Lua error was enough.
					newBar:SetAlpha(1)
				end
			end

			mobTable[dstGUID][T[vulnKey]][BAR].texture:SetVertexColor(Colours(DB.profile.baroptions[T[vulnKey]].fg, alpha))
			mobTable[dstGUID][T[vulnKey]][BAR].bgtexture:SetVertexColor(Colours(DB.profile.baroptions[T[vulnKey]].bg, alpha))
		end

		if warningTime > 0 and DB.profile.baroptions[T[vulnKey]].showwarning then
			if mobTable[dstGUID][T[vulnKey]][TIMER] ~= nil then
				Scorchio2:CancelTimer(mobTable[dstGUID][T[vulnKey]][TIMER], true)
				mobTable[dstGUID][T[vulnKey]][TIMER] = nil
			end
			mobTable[dstGUID][T[vulnKey]][TIMER] = Scorchio2:ScheduleTimer("TimerComplete", (timeToRun - warningTime), { dstGUID , vulnKey })
		end
	end
end

