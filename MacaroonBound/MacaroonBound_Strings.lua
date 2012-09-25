do

	local M = Macaroon

	local strings = {

		BOUND_SPELL_KEYBIND =  {
			enUS = "Enable Spell Binding Mode",
			deDE = "Enable Spell Binding Mode",
			esES = "Enable Spell Binding Mode",
			esMX = "Enable Spell Binding Mode",
			frFR = "Enable Spell Binding Mode",
			koKR = "Enable Spell Binding Mode",
			nlNL = "Enable Spell Binding Mode",
			ruRU = "Enable Spell Binding Mode",
			zhCN = "Enable Spell Binding Mode",
			zhTW = "Enable Spell Binding Mode",
		},

		BOUND_TOGGLE_SPELL_KEYBIND = {
			enUS = "Toggle Spell Binding Mode",
			deDE = "Toggle Spell Binding Mode",
			esES = "Toggle Spell Binding Mode",
			esMX = "Toggle Spell Binding Mode",
			frFR = "Toggle Spell Binding Mode",
			koKR = "Toggle Spell Binding Mode",
			nlNL = "Toggle Spell Binding Mode",
			ruRU = "Toggle Spell Binding Mode",
			zhCN = "Toggle Spell Binding Mode",
			zhTW = "Toggle Spell Binding Mode",
		},

		BOUND_MACRO_KEYBIND = {
			enUS = "Enable Macro Binding Mode",
			deDE = "Enable Macro Binding Mode",
			esES = "Enable Macro Binding Mode",
			esMX = "Enable Macro Binding Mode",
			frFR = "Enable Macro Binding Mode",
			koKR = "Enable Macro Binding Mode",
			nlNL = "Enable Macro Binding Mode",
			ruRU = "Enable Macro Binding Mode",
			zhCN = "Enable Macro Binding Mode",
			zhTW = "Enable Macro Binding Mode",
		},

		BOUND_TOGGLE_MACRO_KEYBIND = {
			enUS = "Toggle Macro Binding Mode",
			deDE = "Toggle Macro Binding Mode",
			esES = "Toggle Macro Binding Mode",
			esMX = "Toggle Macro Binding Mode",
			frFR = "Toggle Macro Binding Mode",
			koKR = "Toggle Macro Binding Mode",
			nlNL = "Toggle Macro Binding Mode",
			ruRU = "Toggle Macro Binding Mode",
			zhCN = "Toggle Macro Binding Mode",
			zhTW = "Toggle Macro Binding Mode",
		},
	}

	local locale = GetLocale()

	for str,value in pairs(strings) do
		if (type(strings[str]) == "table") then
			if (strings[str][locale]) then
				M.Strings[str] = strings[str][locale]
			else
				M.Strings[str] = strings[str]["enUS"]
			end
		else
			M.Strings[str] = strings[str]
		end
	end
end