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
-- GLOBALS: PlaySoundFile
-- GLOBALS: INTERFACEOPTIONS_ADDONCATEGORIES
-- GLOBALS: InterfaceAddOnsList_Update
-- GLOBALS: tremove
-- GLOBALS: unpack
-- GLOBALS: pairs
-- GLOBALS: format

local Scorchio2 = Scorchio2
-- LC[] is the L[] from the core mod. We don't call it L[] in Options, because I found it error-prone.
-- This way FindGlobals will catch accidental uses of L[].
local LC = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Scorchio2")
local LO = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Scorchio2_Options")
local SM = LibStub("LibSharedMedia-3.0")

local DB
local T
local VULNDATA

-- helper for looking up sounds
local function GetSMIndex(t, value)
	for k, v in pairs(SM:List(t)) do
	if v == value then
		return k
		end
	end
	return nil
end

function Scorchio2:InitOptions(l_DB, l_T, l_VULNDATA)
	Scorchio2.InitOptions = nil

	DB = l_DB
	T = l_T
	VULNDATA = l_VULNDATA

	-- Big Init!
	local options = {
		type = 'group',
		name = "Options",
		args = {
			anchoroptions = {
				type = 'group',
				name = LO["Anchor Options"],
				args = {
					heading = {
						type = 'header',
						name = "Presets",
						order = 100,
					},
					gap = {
						type = 'description',
						name = "\n" .. LO["These presets only store anchor and alpha information. If you want to save an entire configuration (including bar colours, warning sounds, etc.) use the Profiles feature."] .. "\n",
						width = "full",
						order = 101,
					},
					modern = {
						type = 'execute',
						name = LO["Modern Anchors"],
						order = 105,
						func = function()
							for k = 1,#VULNDATA do
								if VULNDATA[k].self then
									DB.profile.baroptions[T[k]].targetanchor = "buffs"
									DB.profile.baroptions[T[k]].nontargetanchor = "buffs"
									DB.profile.baroptions[T[k]].targetalpha = 1.0
									DB.profile.baroptions[T[k]].nontargetalpha = 1.0
								else
									DB.profile.baroptions[T[k]].targetanchor = "targeted"
									DB.profile.baroptions[T[k]].nontargetanchor = "nontargeted"
									DB.profile.baroptions[T[k]].targetalpha = 1.0
									DB.profile.baroptions[T[k]].nontargetalpha = 1.0
								end
							end
							Scorchio2:Print("Loaded 'Modern Anchors' Preset")
						end
					},
					moderndesc = {
						type = 'description',
						name = LO["(Three anchors: Targeted, Non-Targeted and Buffs. All alphas 1.0.)"],
						order = 107
					},
					gaptwo = {
						type = 'description',
						name = '\n',
						width = "full",
						order = 109,
					},
					classic = {
						type = 'execute',
						name = LO["Classic Anchors"],
						order = 110,
						func = function()
							for k = 1,#VULNDATA do
								if VULNDATA[k].self then
									DB.profile.baroptions[T[k]].targetanchor = "targeted"
									DB.profile.baroptions[T[k]].nontargetanchor = "targeted"
									DB.profile.baroptions[T[k]].targetalpha = 1.0
									DB.profile.baroptions[T[k]].nontargetalpha = 1.0
								else
									DB.profile.baroptions[T[k]].targetanchor = "targeted"
									DB.profile.baroptions[T[k]].nontargetanchor = "targeted"
									DB.profile.baroptions[T[k]].targetalpha = 1.0
									DB.profile.baroptions[T[k]].nontargetalpha = 0.2
								end
							end
							Scorchio2:Print("Loaded 'Classic Anchors' Preset")
						end
					},
					classicdesc = {
						type = 'description',
						name = LO["(One anchor: Targeted. Bars of non-targeted mobs are dimmed.)"],
						order = 112
					},
					gapthree = {
						type = 'description',
						name = '\n',
						width = "full",
						order = 114,
					},
					targetonly = {
						type = 'execute',
						name = LO["My Target Only"],
						order = 115,
						func = function()
							for k = 1,#VULNDATA do
								if VULNDATA[k].self then
									DB.profile.baroptions[T[k]].targetanchor = "buffs"
									DB.profile.baroptions[T[k]].nontargetanchor = "buffs"
									DB.profile.baroptions[T[k]].targetalpha = 1.0
									DB.profile.baroptions[T[k]].nontargetalpha = 1.0
								else
									DB.profile.baroptions[T[k]].targetanchor = "targeted"
									DB.profile.baroptions[T[k]].nontargetanchor = "none"
									DB.profile.baroptions[T[k]].targetalpha = 1.0
									DB.profile.baroptions[T[k]].nontargetalpha = 1.0
								end
							end
							Scorchio2:Print("Loaded 'My Target Only' Preset")
						end
					},
					targetonlydesc = {
						type = 'description',
						name = LO["(Two anchors: Targeted and Buffs. Only show debuffs on my target.)"],
						order = 117
					},
					gapfour = {
						type = 'description',
						name = '\n',
						width = "full",
						order = 119,
					},
					customsave = {
						type = 'execute',
						name = LO["Save Custom"],
						desc = LO["(Saves your current configuration.)"],
						order = 120,
						func = function()
							for k = 1,#VULNDATA do
								DB.profile.custom_anchors[k] = {
									DB.profile.baroptions[T[k]].targetanchor,
									DB.profile.baroptions[T[k]].nontargetanchor,
									DB.profile.baroptions[T[k]].targetalpha,
									DB.profile.baroptions[T[k]].nontargetalpha
								}
							end
							Scorchio2:Print(LO["Saved 'Custom Anchors' Preset"])
						end
					},
					custom = {
						type = 'execute',
						name = LO["Restore Custom"],
						desc = LO["(Restores your saved configuration.)"],
						order = 121,
						disabled = function()
							return not DB.profile.custom_anchors
						end,
						func = function()
							for k = 1,#VULNDATA do
								DB.profile.baroptions[T[k]].targetanchor,
									DB.profile.baroptions[T[k]].nontargetanchor,
									DB.profile.baroptions[T[k]].targetalpha,
									DB.profile.baroptions[T[k]].nontargetalpha = unpack(DB.profile.custom_anchors[k])
							end
							Scorchio2:Print(LO["Restored 'Custom Anchors' Preset"])
						end
					},
					customdesc = {
						type = 'description',
						name = LO["(Saves your current configuration, or restores a saved one.)"],
						order = 124
					},
					gapfive = {
						type = 'description',
						name = '\n',
						width = "full",
						order = 125,
					},
					resetbars = {
						type = 'execute',
						name = LO["Reset Anchors"],
						desc = LO["Reset bars to their default positions on the screen"],
						order = 130,
						func = function()
							DB.profile.anchoroptions.targeted.position = {
								pr = "CENTER",
								p = "CENTER",
								py = -300,
								px = 0
							}
							DB.profile.anchoroptions.nontargeted.position = {
								pr = "LEFT",
								p = "LEFT",
								py = -230,
								px = 150
							}
							DB.profile.anchoroptions.buffs.position = {
								pr = "CENTER",
								p = "CENTER",
								py = 0,
								px = 0
							}
							Scorchio2:UpdateAnchors()
						end
					},
					resetdesc = {
						type = 'description',
						name = LO["Reset bars to their default positions on the screen"],
						order = 131
					},
					targeted = {
						type = 'group',
						name = LO["Targeted"],
						desc = LO["Targeted"],
						order = 200,
						-- args defined later
					},
					nontargeted = {
						type = 'group',
						name = LO["Non-Targeted"],
						desc = LO["Non-Targeted"],
						order = 210,
						-- args defined later
					},
					buffs = {
						type = 'group',
						name = LO["Buffs"],
						desc = LO["Buffs"],
						order = 220,
						-- args defined later
					},
				},
			},
			baroptions = {
				type = 'group',
				name = "Bar Options",
				disabled = function(info)
					local myname, myparent = info[#info], info[#info-1]
					if myname == "baroptions" or myparent == "baroptions" then
						return false
					else
						return not DB.profile.baroptions[myparent].track
					end
				end,
				get = function(info)
					local member = info[#info-1]
					local setting = info[#info]
					return DB.profile.baroptions[member][setting]
				end,
				args = {
					-- filled in later
				},
			},
			output = Scorchio2:GetSinkAce3OptionsDataTable(),
		},
	}
	Scorchio2:InitAnchorOptions(options.args.anchoroptions.args)
	Scorchio2:InitBarOptions(options.args.baroptions.args)

	options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(DB)
	-- Remove any Scorchio2 stub in the interface options, before adding the real one
	local categories = INTERFACEOPTIONS_ADDONCATEGORIES
	for i = 1,#categories do
		if categories[i].name == "Scorchio2" then
			tremove(categories, i)
			break
		end
	end
	InterfaceAddOnsList_Update()
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Scorchio2", options)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Scorchio2", "Scorchio2")
	Scorchio2.options_table = options
end

function Scorchio2:InitAnchorOptions(anchoroptions_args)
	Scorchio2.InitAnchorOptions = nil

	local function generic_get(info)
		local member = info[#info-1]
		local setting = info[#info]
		return DB.profile.anchoroptions[member][setting]
	end
	local function generic_set_and_update_anchors(info, v)
		local member = info[#info-1]
		local setting = info[#info]
		DB.profile.anchoroptions[member][setting] = v
		Scorchio2:UpdateAnchors()
	end

	local function generic_get_font(info)
		local member = info[#info-1]
		local setting = info[#info]
		return GetSMIndex("font", DB.profile.anchoroptions[member][setting])
	end
	local function generic_set_font(info, v)
		local member = info[#info-1]
		local setting = info[#info]
		DB.profile.anchoroptions[member][setting] = SM:List("font")[v]
		Scorchio2:UpdateAnchors()
	end

	local function generic_get_statusbar(info)
		local member = info[#info-1]
		local setting = info[#info]
		return GetSMIndex("statusbar", DB.profile.anchoroptions[member][setting])
	end
	local function generic_set_statusbar(info, v)
		local member = info[#info-1]
		local setting = info[#info]
		DB.profile.anchoroptions[member][setting] = SM:List("statusbar")[v]
		Scorchio2:UpdateAnchors()
	end


	local generic_args = {
		toggle = {
			type = 'execute',
			name = LO["Toggle Anchor"],
			desc = LO["Shows/Hides the draggable anchor"],
			func = function(info)
				local anchorname = info[#info-1]
				Scorchio2:ToggleAnchors(anchorname)
			end,
		},
		test = {
			type = 'execute',
			name = LO["Test"],
			desc = LO["Shows test bars"],
			func = function(info)
				local anchorname = info[#info-1]
				Scorchio2:RunTest(anchorname)
			end,
		},
		width = {
			type = 'range',
			name = LO["Width"],
			desc = LO["Change the width of the bars"],
			order = 120,
			set = generic_set_and_update_anchors,
			min = 24,
			max = 512,
			step = 8,
		},
		height = {
			type = 'range',
			name = LO["Height"],
			desc = LO["Change the height of the bars"],
			order = 121,
			set = generic_set_and_update_anchors,
			min = 6,
			max = 64,
			step = 2,
		},
		scale = {
			type = 'range',
			name = LO["Scale"],
			desc = LO["Change the scale of the bars"],
			order = 122,
			min = 0.5,
			max = 2,
			set = generic_set_and_update_anchors,
		},
		maxbars = {
			type = 'range',
			name = LO["Max Bars"],
			desc = LO["Maximum number of bars to show at any one time. Set to 0 to show all bars."],
			order = 123,
			min = 0,
			max = 10,
			step = 1,
			set = generic_set_and_update_anchors,
		},
		orientation = {
			type = 'select',
			name = LO["Orientation"],
			desc = LO["Change which way the bars run"],
			order = 124,
			values = { [1]=LO["Left to Right"], [3]=LO["Right to Left"] },
			set = generic_set_and_update_anchors,
		},
		growth = {
			type = 'toggle',
			name = LO["Grow Up"],
			desc = LO["If checked, bars will stack above the anchor, not below"],
			order = 125,
			set = generic_set_and_update_anchors,
		},
		font = {
			type = 'select',
			name = LO["Font"],
			desc = LO["Set the bar font"],
			order = 126,
			values = SM:List("font"),
			get = generic_get_font,
			set = generic_set_font,
		},
		fontsize = {
			type = 'range',
			name = LO["Font Size"],
			desc = LO["Change the font size"],
			order = 127,
			min = 7,
			max = 24,
			step = 1,
			set = generic_set_and_update_anchors,
		},
		texture = {
			type = 'select',
			name = LO["Texture"],
			desc = LO["Change the texture of the bars"],
			order = 128,
			values = SM:List("statusbar"),
			get = generic_get_statusbar,
			set = generic_set_statusbar,
		},
	}

	anchoroptions_args.targeted.get = generic_get
	anchoroptions_args.targeted.args = generic_args

	anchoroptions_args.nontargeted.get = generic_get
	anchoroptions_args.nontargeted.args = generic_args

	anchoroptions_args.buffs.get = generic_get
	anchoroptions_args.buffs.args = generic_args
end

function Scorchio2:InitBarOptions(baroptions_args)
	Scorchio2.InitBarOptions = nil

	local Scorchio2 = self
	local bar_args = baroptions_args

	-- basic generics
	local function generic_set(info, v)
		local member = info[#info-1]
		local setting = info[#info]
		DB.profile.baroptions[member][setting] = v
	end
	local function generic_set_and_update_anchors(info, v)
		local member = info[#info-1]
		local setting = info[#info]
		DB.profile.baroptions[member][setting] = v
		Scorchio2:UpdateAnchors()
	end

	-- generics for colors
	local function generic_get_color(info)
		local member = info[#info-1]
		local setting = info[#info]
		return unpack(DB.profile.baroptions[member][setting])
	end
	local function generic_set_color(info, r, g, b)
		local member = info[#info-1]
		local setting = info[#info]
		DB.profile.baroptions[member][setting] = {r, g, b}
		Scorchio2:UpdateAnchors()
	end

	-- generics for procs, which set target and nontarget properties together
	local function generic_set_proc_anchors(info, v)
		local member = info[#info-1]
		DB.profile.baroptions[member].targetanchor = v
		DB.profile.baroptions[member].nontargetanchor = v
		Scorchio2:UpdateAnchors()
	end
	local function generic_set_proc_alphas(info, v)
		local member = info[#info-1]
		DB.profile.baroptions[member].targetalpha = v
		DB.profile.baroptions[member].nontargetalpha = v
		Scorchio2:UpdateAnchors()
	end

	-- generics for sounds
	local function generic_disabled_sound(info)
		return not DB.profile.baroptions[info[#info-1]].soundson or not DB.profile.baroptions[info[#info-1]].track
	end
	local function generic_get_sound(info)
		local member = info[#info-1]
		local setting = info[#info]
		return GetSMIndex("sound", DB.profile.baroptions[member][setting])
	end
	local function generic_set_sound(info, v)
		local member = info[#info-1]
		local setting = info[#info]
		DB.profile.baroptions[member][setting] = SM:List("sound")[v]
		PlaySoundFile(SM:Fetch("sound", DB.profile.baroptions[member][setting]), "Master")
	end

	-- for text that uses %s to refer to the bar name
	local function parameterized_text(desc)
		return function(info)
			local l_barname = bar_args[info[#info-1]].name
			return format(desc, l_barname)
		end
	end
	local function parameterized_text_debuff(desc)
		return function(info)
			local l_barname = bar_args[info[#info-1]].name
			return format(desc, l_barname) .. " " .. LO["$s will be replaced by the spell stack. $m will be replaced by the mob name. Everything else will remain as-is."]
		end
	end

	local track = { -- 10
		type = 'toggle',
		name = parameterized_text(LO["Track %s"]),
		order = 10,
		width = "full",
		disabled = false,
		set = generic_set_and_update_anchors,
	}
	local show = { -- 20
		type = 'toggle',
		name = LO["Show Bars"],
		desc = parameterized_text(LO["Show bars for %s"]),
		order = 20,
		set = generic_set_and_update_anchors,
	}
	local clearooc = { -- 30
		type = 'toggle',
		name = LO["Hide OOC"],
		desc = LO["Fade bars when out of combat"],
		order = 30,
		set = generic_set,
	}
	local bar_debuff = { -- 40
		type = 'input',
		name = LO["Bar Text"],
		desc = parameterized_text_debuff(LO["Enter text to appear on %s bars."]),
		order = 40,
		width = "full",
		set = generic_set_and_update_anchors,
	}
	local bar_proc = { -- 40
		type = 'input',
		name = LO["Bar Text"],
		desc = parameterized_text(LO["Enter text to appear on %s bars."]),
		order = 40,
		width = "full",
		set = generic_set_and_update_anchors,
	}
	local fg = { -- 50
		type = 'color',
		name = LO["Bar Colour"],
		desc = LO["Change bar colour"],
		order = 50,
		get = generic_get_color,
		set = generic_set_color,
		hasAlpha = false
	}
	local bg = { -- 60
		type = 'color',
		name = LO["Background Colour"],
		desc = LO["Change background colour"],
		order = 60,
		get = generic_get_color,
		set = generic_set_color,
		hasAlpha = false
	}
	local targetanchor_debuff = { -- 70
		type = 'select',
		name = LO["Target Anchor"],
		desc = parameterized_text(LO["Anchor used when %s is on your target"]),
		order = 70,
		values = { ["targeted"]=LO["Targeted"], ["nontargeted"]=LO["Non-Targeted"], ["buffs"]=LO["Buffs"], ["none"]=LO["None"] },
		set = generic_set_and_update_anchors,
	}
	local targetanchor_proc = { -- 70
		type = 'select',
		name = LO["Anchor"],
		desc = parameterized_text(LO["Anchor used for %s bar"]),
		order = 70,
		values = { ["targeted"]=LO["Targeted"], ["nontargeted"]=LO["Non-Targeted"], ["buffs"]=LO["Buffs"], ["none"]=LO["None"] },
		set = generic_set_proc_anchors,
	}
	local nontargetanchor = { -- 80
		type = 'select',
		name = LO["Non-Target Anchor"],
		desc = parameterized_text(LO["Anchor used when %s is on something NOT your target"]),
		order = 80,
		values = { ["targeted"]=LO["Targeted"], ["nontargeted"]=LO["Non-Targeted"], ["buffs"]=LO["Buffs"], ["none"]=LO["None"] },
		set = generic_set_and_update_anchors,
	}
	local targetalpha_debuff = { -- 90
		type = 'range',
		name = LO["Target Alpha"],
		desc = LO["Alpha applied to Target bar"],
		order = 90,
		set = generic_set_and_update_anchors,
		min = 0,
		max = 1,
		step = 0.1,
	}
	local targetalpha_proc = { -- 90
		type = 'range',
		name = LO["Alpha"],
		desc = LO["Alpha applied to bar"],
		order = 90,
		set = generic_set_proc_alphas,
		min = 0,
		max = 1,
		step = 0.1,
	}
	local nontargetalpha = { -- 100
		type = 'range',
		name = LO["Non-Target Alpha"],
		desc = LO["Alpha applied to Non-Target bars"],
		order = 100,
		set = generic_set_and_update_anchors,
		min = 0,
		max = 1,
		step = 0.1,
	}
	local showproc = { -- 100
		type = 'toggle',
		name = LO["Show Proc"],
		desc = parameterized_text(LO["Show message when %s procs"]),
		order = 100,
		width = "full",
		set = generic_set_and_update_anchors,
	}
	local apply = { -- 105
		type = 'input',
		name = LO["Proc Text"],
		desc = parameterized_text(LO["Enter message to appear when %s procs"]),
		order = 105,
		width = "full",
		set = generic_set,
	}
	local showwarning = { -- 110
		type = 'toggle',
		name = LO["Show Warnings"],
		desc = LO["Show warning when spell is about to expire"],
		order = 110,
		width = "full",
		set = generic_set_and_update_anchors,
	}
	local telltale = { -- 115
		type = 'toggle',
		name = LO["Show Who Broke It"],
		desc = parameterized_text(LO["Show message when someone breaks %s early"]),
		order = 115,
		width = "full",
		set = generic_set_and_update_anchors,
	}
	-- 120 is warningtime, created separately in each instance, by GenericBarOption()
	local warning_debuff = { -- 130
		type = 'input',
		name = LO["Warning Text"],
		desc = parameterized_text_debuff(LO["Enter warning to appear when %s will fade."]),
		order = 130,
		width = "full",
		set = generic_set,
	}
	local warning_proc = { -- 130
		type = 'input',
		name = LO["Warning Text"],
		desc = parameterized_text(LO["Enter warning to appear when %s will fade."]),
		order = 130,
		width = "full",
		set = generic_set,
	}
	local showexpire = { -- 140
		type = 'toggle',
		name = LO["Show Expired Notices"],
		desc = LO["Show notice when spell expires"],
		order = 140,
		width = "full",
		set = generic_set_and_update_anchors,
	}
	local message_debuff = { -- 150
		type = 'input',
		name = LO["Expired Text"],
		desc = parameterized_text_debuff(LO["Enter warning to appear when %s expires."]),
		order = 150,
		width = "full",
		set = generic_set,
	}
	local message_proc = { -- 150
		type = 'input',
		name = LO["Expired Text"],
		desc = parameterized_text(LO["Enter warning to appear when %s expires."]),
		order = 150,
		width = "full",
		set = generic_set,
	}
	local message_cooldown = { -- 150
		type = 'input',
		name = LO["Ready Text"],
		desc = parameterized_text(LO["Enter message to appear when %s is ready."]),
		order = 150,
		width = "full",
		set = generic_set,
	}
	local soundson = { -- 160
		type = 'toggle',
		name = LO["Toggle Sounds"],
		desc = parameterized_text(LO["Enable/Disable sounds for %s"]),
		order = 160,
		width = "full",
		set = generic_set,
	}
	local procsound = { -- 165
		type = 'select',
		name = LO["Proc Sound"],
		desc = parameterized_text(LO["Change the sound played when %s procs."]),
		order = 165,
		values = SM:List("sound"),
		disabled = generic_disabled_sound,
		get = generic_get_sound,
		set = generic_set_sound,
	}
	local warningsound = { -- 170
		type = 'select',
		name = LO["Warning Sound"],
		desc = LO["Change the sound played when warning time is reached"],
		order = 170,
		values = SM:List("sound"),
		disabled = generic_disabled_sound,
		get = generic_get_sound,
		set = generic_set_sound,
	}
	local expiredsound = { -- 180
		type = 'select',
		name = LO["Expired Sound"],
		desc = parameterized_text(LO["Change the sound played when %s expires."]),
		order = 180,
		values = SM:List("sound"),
		disabled = generic_disabled_sound,
		get = generic_get_sound,
		set = generic_set_sound,
	}

	local function GenericBarOption(barname, minWarningtime, maxWarningtime)
		local warningtime = { -- 120
			type = 'range',
			name = LO["Warning Time"],
			desc = format(LO["Warning Time for %s"], barname),
			order = 120,
			width = "full",
			set = generic_set_and_update_anchors,
			min = minWarningtime,
			max = maxWarningtime,
			step = 1,
		}
		local t = {
			type = 'group',
			name = barname,
			desc = barname,
			args = {
				track = track,
				show = show,
				clearooc = clearooc,
				fg = fg,
				bg = bg,
				showwarning = showwarning,
				warningtime = warningtime,
				showexpire = showexpire,
				soundson = soundson,
				warningsound = warningsound,
				expiredsound = expiredsound,
			},
		}
		return t
	end

	local function DebuffBarOption(...)
		local t = GenericBarOption(...)
		t.args.bar = bar_debuff
		t.args.targetanchor = targetanchor_debuff
		t.args.nontargetanchor = nontargetanchor
		t.args.targetalpha = targetalpha_debuff
		t.args.nontargetalpha = nontargetalpha
		t.args.warning = warning_debuff
		t.args.message = message_debuff
		return t
	end

	local function ProcBarOption(...)
		local t = GenericBarOption(...)
		t.args.bar = bar_proc
		t.args.targetanchor = targetanchor_proc
		t.args.targetalpha = targetalpha_proc
		t.args.showproc = showproc
		t.args.apply = apply
		t.args.warning = warning_proc
		t.args.message = message_proc
		t.args.procsound = procsound
		return t
	end

	local function MinimalProcBarOption(barname)
		local t = {
			type = 'group',
			name = barname,
			desc = barname,
			args = {
				track = track,
				show = show,
				clearooc = clearooc,
				bar = bar_proc,
				fg = fg,
				bg = bg,
				targetanchor = targetanchor_proc,
				targetalpha = targetalpha_proc,
			},
		}
		return t
	end

	local function CooldownBarOption(...)
		local t = MinimalProcBarOption(...)
		-- Expiration doesn't work yet, because it's currently tied to LostVuln.
		-- t.args.showexpire = showexpire
		-- t.args.message = message_cooldown
		return t
	end

	local function MinimalDebuffBarOption(barname)
		local t = {
			type = 'group',
			name = barname,
			desc = barname,
			args = {
				track = track,
				show = show,
				clearooc = clearooc,
				bar = bar_debuff,
				fg = fg,
				bg = bg,
				targetanchor = targetanchor_debuff,
				nontargetanchor = nontargetanchor,
				targetalpha = targetalpha_debuff,
				nontargetalpha = nontargetalpha,
			},
		}
		return t
	end

	-- Summons are like procs, but they aren't random so we don't want on-proc notifications.
	local function SummonBarOption(...)
		local t = ProcBarOption(...)
		t.args.snowproc = nil
		t.args.apply = nil
		t.args.procsound = nil
		return t
	end

	-- "Passive" debuffs are ones outside our control, TTW and 8% spell damage.
	local function PassiveDebuffBarOption(...)
		local t = DebuffBarOption(...)
		t.args.showwarning = nil
		t.args.warningtime = nil
		t.args.warning = nil
		t.args.warningsound = nil
		return t
	end

	bar_args.a = DebuffBarOption(LC["Pyromaniac"], 0, 15)
	bar_args.c = DebuffBarOption(LC["Living Bomb"], 0, 12)
	bar_args.d = DebuffBarOption(LC["Polymorph"], 0, 12)
	bar_args.e = DebuffBarOption(LC["Slow"], 0, 12)
	bar_args.f = ProcBarOption(LC["Hot Streak"], 0, 15)
	bar_args.g = ProcBarOption(LC["Arcane Missiles"], 0, 15)
	bar_args.h = ProcBarOption(LC["Heating Up"], 0, 10)
	bar_args.i = MinimalProcBarOption(LC["Arcane Charge"])
	bar_args.j = ProcBarOption(LC["Brain Freeze"], 0, 15)
	bar_args.k = ProcBarOption(LC["Fingers of Frost"], 0, 15)
	bar_args.m = SummonBarOption(LC["Water Elemental"], 0, 30)
	bar_args.n = SummonBarOption(LC["Mirror Image"], 0, 30)
	bar_args.p = PassiveDebuffBarOption(LC["8% Spell Damage"])
	bar_args.q = DebuffBarOption(LC["Frostfire Bolt"], 0, 12)
	bar_args.t = MinimalDebuffBarOption(LC["Ignite"])
	bar_args.u = MinimalDebuffBarOption(LC["Pyroblast"])
	bar_args.v = MinimalProcBarOption(LC["Flamestrike"])
	bar_args.w = ProcBarOption(LC["Invocation"], 0, 40)
	bar_args.x = DebuffBarOption(LC["Nether Tempest"], 0, 12)
	bar_args.y = CooldownBarOption(LC["Frost Bomb"])

	bar_args.d.args.telltale = telltale
end
