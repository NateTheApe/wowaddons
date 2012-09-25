do

	local M = Macaroon

	local strings = {

		P_INVALID_NAME =  {
			enUS = "Invalid profile name",
			deDE = "Invalid profile name",
			esES = "Invalid profile name",
			esMX = "Invalid profile name",
			frFR = "Invalid profile name",
			koKR = "Invalid profile name",
			nlNL = "Invalid profile name",
			ruRU = "Invalid profile name",
			zhCN = "Invalid profile name",
			zhTW = "Invalid profile name",
		},

		P_NAME_EDIT = {
			enUS = "Click here to edit Name",
			deDE = "Click here to edit Name",
			esES = "Click here to edit Name",
			esMX = "Click here to edit Name",
			frFR = "Click here to edit Name",
			koKR = "Click here to edit Name",
			nlNL = "Click here to edit Name",
			ruRU = "Click here to edit Name",
			zhCN = "Click here to edit Name",
			zhTW = "Click here to edit Name",
		},

		P_NOTE_EDIT = {
			enUS = "Click here to edit notes",
			deDE = "Click here to edit notes",
			esES = "Click here to edit notes",
			esMX = "Click here to edit notes",
			frFR = "Click here to edit notes",
			koKR = "Click here to edit notes",
			nlNL = "Click here to edit notes",
			ruRU = "Click here to edit notes",
			zhCN = "Click here to edit notes",
			zhTW = "Click here to edit notes",
		},

		P_SAVE = {
			enUS = "Save",
			deDE = "Save",
			esES = "Save",
			esMX = "Save",
			frFR = "Save",
			koKR = "Save",
			nlNL = "Save",
			ruRU = "Save",
			zhCN = "Save",
			zhTW = "Save",
		},

		P_SAVE_CONFIRM = {
			enUS = "Overwrite Profile |cffffffff%s|r ?",
			deDE = "Overwrite Profile |cffffffff%s|r ?",
			esES = "Overwrite Profile |cffffffff%s|r ?",
			esMX = "Overwrite Profile |cffffffff%s|r ?",
			frFR = "Overwrite Profile |cffffffff%s|r ?",
			koKR = "Overwrite Profile |cffffffff%s|r ?",
			nlNL = "Overwrite Profile |cffffffff%s|r ?",
			ruRU = "Overwrite Profile |cffffffff%s|r ?",
			zhCN = "Overwrite Profile |cffffffff%s|r ?",
			zhTW = "Overwrite Profile |cffffffff%s|r ?",
		},

		P_LOAD ={
			enUS = "Load",
			deDE = "Load",
			esES = "Load",
			esMX = "Load",
			frFR = "Load",
			koKR = "Load",
			nlNL = "Load",
			ruRU = "Load",
			zhCN = "Load",
			zhTW = "Load",
		},

		P_LOAD_CONFIRM = {
			enUS = "Load Profile |cffffffff%s|r ?",
			deDE = "Load Profile |cffffffff%s|r ?",
			esES = "Load Profile |cffffffff%s|r ?",
			esMX = "Load Profile |cffffffff%s|r ?",
			frFR = "Load Profile |cffffffff%s|r ?",
			koKR = "Load Profile |cffffffff%s|r ?",
			nlNL = "Load Profile |cffffffff%s|r ?",
			ruRU = "Load Profile |cffffffff%s|r ?",
			zhCN = "Load Profile |cffffffff%s|r ?",
			zhTW = "Load Profile |cffffffff%s|r ?",
		},

		P_DELETE = {
			enUS = "Delete",
			deDE = "Delete",
			esES = "Delete",
			esMX = "Delete",
			frFR = "Delete",
			koKR = "Delete",
			nlNL = "Delete",
			ruRU = "Delete",
			zhCN = "Delete",
			zhTW = "Delete",
		},

		P_DELETE_CONFIRM ={
			enUS = "Delete Profile |cffffffff%s|r ?",
			deDE = "Delete Profile |cffffffff%s|r ?",
			esES = "Delete Profile |cffffffff%s|r ?",
			esMX = "Delete Profile |cffffffff%s|r ?",
			frFR = "Delete Profile |cffffffff%s|r ?",
			koKR = "Delete Profile |cffffffff%s|r ?",
			nlNL = "Delete Profile |cffffffff%s|r ?",
			ruRU = "Delete Profile |cffffffff%s|r ?",
			zhCN = "Delete Profile |cffffffff%s|r ?",
			zhTW = "Delete Profile |cffffffff%s|r ?",
		},

		P_LAYOUT = {
			enUS = "Bar Layout",
			deDE = "Bar Layout",
			esES = "Bar Layout",
			esMX = "Bar Layout",
			frFR = "Bar Layout",
			koKR = "Bar Layout",
			nlNL = "Bar Layout",
			ruRU = "Bar Layout",
			zhCN = "Bar Layout",
			zhTW = "Bar Layout",
		},

		P_BUTTONS = {
			enUS = "Button Layout",
			deDE = "Button Layout",
			esES = "Button Layout",
			esMX = "Button Layout",
			frFR = "Button Layout",
			koKR = "Button Layout",
			nlNL = "Button Layout",
			ruRU = "Button Layout",
			zhCN = "Button Layout",
			zhTW = "Button Layout",
		},

		P_BUTTONDATA ={
			enUS = "Button Data",
			deDE = "Button Data",
			esES = "Button Data",
			esMX = "Button Data",
			frFR = "Button Data",
			koKR = "Button Data",
			nlNL = "Button Data",
			ruRU = "Button Data",
			zhCN = "Button Data",
			zhTW = "Button Data",
		},

		P_SETTINGS = {
			enUS = "Settings",
			deDE = "Settings",
			esES = "Settings",
			esMX = "Settings",
			frFR = "Settings",
			koKR = "Settings",
			nlNL = "Settings",
			ruRU = "Settings",
			zhCN = "Settings",
			zhTW = "Settings",
		},

		P_NOTHINGTOSAVE = {
			enUS = "Nothing selected to save",
			deDE = "Nothing selected to save",
			esES = "Nothing selected to save",
			esMX = "Nothing selected to save",
			frFR = "Nothing selected to save",
			koKR = "Nothing selected to save",
			nlNL = "Nothing selected to save",
			ruRU = "Nothing selected to save",
			zhCN = "Nothing selected to save",
			zhTW = "Nothing selected to save",
		},

		P_NOPROFILES = {
			enUS = "No Saved Profiles",
			deDE = "No Saved Profiles",
			esES = "No Saved Profiles",
			esMX = "No Saved Profiles",
			frFR = "No Saved Profiles",
			koKR = "No Saved Profiles",
			nlNL = "No Saved Profiles",
			ruRU = "No Saved Profiles",
			zhCN = "No Saved Profiles",
			zhTW = "No Saved Profiles",
		},

		P_USEPROFILES = {
			enUS = "Enable profile switching upon spec change",
			deDE = "Enable profile switching upon spec change",
			esES = "Enable profile switching upon spec change",
			esMX = "Enable profile switching upon spec change",
			frFR = "Enable profile switching upon spec change",
			koKR = "Enable profile switching upon spec change",
			nlNL = "Enable profile switching upon spec change",
			ruRU = "Enable profile switching upon spec change",
			zhCN = "Enable profile switching upon spec change",
			zhTW = "Enable profile switching upon spec change",
		},

		P_SPEC1_EDIT = {
			enUS = "Primary Talent Spec Profile",
			deDE = "Primary Talent Spec Profile",
			esES = "Primary Talent Spec Profile",
			esMX = "Primary Talent Spec Profile",
			frFR = "Primary Talent Spec Profile",
			koKR = "Primary Talent Spec Profile",
			nlNL = "Primary Talent Spec Profile",
			ruRU = "Primary Talent Spec Profile",
			zhCN = "Primary Talent Spec Profile",
			zhTW = "Primary Talent Spec Profile",
		},

		P_SPEC2_EDIT ={
			enUS = "Secondary Talent Spec Profile",
			deDE = "Secondary Talent Spec Profile",
			esES = "Secondary Talent Spec Profile",
			esMX = "Secondary Talent Spec Profile",
			frFR = "Secondary Talent Spec Profile",
			koKR = "Secondary Talent Spec Profile",
			nlNL = "Secondary Talent Spec Profile",
			ruRU = "Secondary Talent Spec Profile",
			zhCN = "Secondary Talent Spec Profile",
			zhTW = "Secondary Talent Spec Profile",
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