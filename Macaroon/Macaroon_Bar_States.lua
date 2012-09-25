--Macaroon, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

Macaroon.ManagedStates = {

	pagedbar = {
		homestate = "pagedbar1",
		states = "[bar:1] homestate; [bar:2] pagedbar2; [bar:3] pagedbar3; [bar:4] pagedbar4; [bar:5] pagedbar5; [bar:6] pagedbar6",
		rangeStart = 2,
		rangeStop = 6,
		printOrder = 1,
	},

	stance = {
		homestate = "stance0",
		states = "[stance:0] homestate; [stance:1] stance1; [stance:2] stance2; [stance:3] stance3; [stance:4] stance4; [stance:5] stance5; [stance:6] stance6; [stance:7] stance7",
		rangeStart = 1,
		rangeStop = 8,
		printOrder = 2,
	},

	companion = {
		homestate = "companion0",
		states = "[vehicleui] vehicle1; [novehicleui,bonusbar:5] possess1; [nopet] homestate; [target=pet,exists,nodead] companion1",
		rangeStart = 2,
		rangeStop = 2,
		printOrder = 3,
	},

	stealth = {
		states = "[nostance:3,stealth] stealth1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		printOrder = 4,
	},

	reaction = {
		states = "[target=target,harm] reaction1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		printOrder = 5,
	},

	combat = {
		states = "[combat] combat1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		printOrder = 6,
	},

	group = {
		states = "[group:raid] group1; [group:party] group2; laststate",
		rangeStart = 1,
		rangeStop = 2,
		printOrder = 7,
	},

	fishing = {
		states = "[worn:fishing pole] fishing1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		printOrder = 8,
	},

	possess = {
		states = "[novehicleui,bonusbar:5] possess1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		printOrder = 9,
	},

	vehicle = {
		states = "[vehicleui] vehicle1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		printOrder = 10,
	},

	alt = {
		states = "[mod:alt] alt1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		printOrder = 11,
	},

	ctrl = {
		states = "[mod:ctrl] ctrl1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		printOrder = 12,
	},

	shift = {
		states = "[mod:shift] shift1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		printOrder = 13,
	},

	custom = {
		states = "",
		rangeStart = 1,
		rangeStop = 1,
		printOrder = 14,
	},
}
