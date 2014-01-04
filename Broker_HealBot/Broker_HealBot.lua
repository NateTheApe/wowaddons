local addonName, vars = ...
local L = vars.L
local LaddonName = L[addonName]
local LHB = L["HealBot"]
Broker_HealBot = vars
local addon = vars
local _G = getfenv(0)
local defaults = { 
  HideMinimap = true,
  DebugEnabled = false,
}
local settings = defaults
local LDB, LDBo
vars.svnrev = {}
vars.svnrev["Broker_HealBot.lua"] = tonumber(("$Revision: 44 $"):match("%d+"))


local function chatMsg(msg)
     DEFAULT_CHAT_FRAME:AddMessage(LaddonName..": "..msg)
end
local function debug(msg)
  if settings.DebugEnabled then
     chatMsg(msg)
  end
end

local frame = CreateFrame("Button", addonName.."HiddenFrame", UIParent)
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");

local function OnEvent(frame, event, name, ...)
  if event == "ADDON_LOADED" and name == addonName then
     debug("ADDON_LOADED: "..name)
     addon:setupLDB()
     addon:SetupVersion()
     Broker_HealBotDB = Broker_HealBotDB or {}
     if not Broker_HealBotDB.settings then
         Broker_HealBotDB.settings = {}
         for k,v in pairs(defaults) do
           Broker_HealBotDB.settings[k] = v
         end
     end
     settings = Broker_HealBotDB.settings
     settings.loaded = true
     if (LDBo) then
       addon:HideMinimap()
     end
  elseif event == "ADDON_LOADED" then
     debug("ADDON_LOADED: "..name)
     addon:setupLDB()
  elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
     debug("ACTIVE_TALENT_GROUP_CHANGED")
     addon:ResetHB()
  end
end
frame:SetScript("OnEvent", OnEvent);

SLASH_BROKERHEALBOT1 = L["/bhb"]
SlashCmdList["BROKERHEALBOT"] = function(msg)
        local cmd = msg:lower()
        if cmd == L["minimap"] then
          chatMsg(LHB.." "..L["minimap toggled"])
          settings.HideMinimap = not settings.HideMinimap
          addon:HideMinimap()
        elseif cmd == L["debug"] then
          chatMsg(L["debug toggled"])
          settings.DebugEnabled = not settings.DebugEnabled
        else
          chatMsg(LaddonName.." "..addon.version)
          chatMsg(SLASH_BROKERHEALBOT1.." [ "..L["minimap"].." | "..L["debug"].." ]")
        end
end

function addon:SetupVersion()
   local svnrev = 0
   local T_svnrev = vars.svnrev
   T_svnrev["X-Build"] = tonumber((GetAddOnMetadata(addonName, "X-Build") or ""):match("%d+"))
   T_svnrev["X-Revision"] = tonumber((GetAddOnMetadata(addonName, "X-Revision") or ""):match("%d+"))
   for _,v in pairs(T_svnrev) do -- determine highest file revision
     if v and v > svnrev then
       svnrev = v
     end
   end
   addon.revision = svnrev

   T_svnrev["X-Curse-Packaged-Version"] = GetAddOnMetadata(addonName, "X-Curse-Packaged-Version")
   T_svnrev["Version"] = GetAddOnMetadata(addonName, "Version")
   addon.version = T_svnrev["X-Curse-Packaged-Version"] or T_svnrev["Version"] or "@"
   if string.find(addon.version, "@") then -- dev copy uses "@.project-version.@"
      addon.version = "r"..svnrev
   end
end

function addon:ResetHB()
       debug("HB reset")
       if HealBot_AddChat and HEALBOT_CHAT_ADDONID and HEALBOT_CHAT_SOFTRELOAD then
         HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_CHAT_SOFTRELOAD)
       end
       if HealBot_SetResetFlag then
         HealBot_SetResetFlag("SOFT");
       else
         chatMsg("ERROR: Reset failed!")
       end
       if InCombatLockdown() then
         chatMsg(LHB.." "..L["reset requested (in combat)"])
       end
end

function addon:HideMinimap()
   if not _G.HealBot_Globals.ButtonShown or
      not _G.HealBot_MMButton_Init then return end
   if ( settings.HideMinimap ) then
      -- hide healbot's regular icon
      _G.HealBot_Options_ShowMinimapButton:SetChecked(false);
      _G.HealBot_Globals.ButtonShown = 0;
      debug("minimap hidden")
   else
      -- show it
      _G.HealBot_Options_ShowMinimapButton:SetChecked(true);
      _G.HealBot_Globals.ButtonShown = 1;
      debug("minimap shown")
   end
   _G.HealBot_MMButton_Init();
end

function addon:setupLDB()
  if LDB then
    return
  end
  if AceLibrary and AceLibrary:HasInstance("LibDataBroker-1.1") then
    LDB = AceLibrary("LibDataBroker-1.1")
  elseif LibStub then
    LDB = LibStub:GetLibrary("LibDataBroker-1.1",true)
  end
  if LDB then
    LDBo = LDB:NewDataObject(LaddonName, {
        type = "data source",
        label = LHB,
	text = _G.Healbot_Config_Skins.Current_Skin or LaddonName,
        icon = "Interface\\AddOns\\Broker_HealBot\\icon",
        OnClick = function(self, button)
                if button == "LeftButton" then
                   if ( IsShiftKeyDown() ) then
		       addon:ResetHB()
                   else
  		       debug("skin menu")
        	       if addon.tooltip and addon.tooltip:IsVisible() then
        	         addon.tooltip:Hide()
        	       end
        	       ToggleDropDownMenu(1, nil, addon.DropDownMenu, self, 0, 0)
                   end
                elseif button == "RightButton" then
                   if ( IsShiftKeyDown() ) then                
  		       debug("HB toggle")
		       if HealBot_SlashCmd then
		          HealBot_SlashCmd("t")
		       else -- old healbots
		          local curval = HealBot_Config.DisableHealBot
                          HealBot_Options_ToggleHealBot(1-curval)
		       end
		       if InCombatLockdown() then
		          chatMsg(LHB.." "..L["toggle requested (in combat)"])
		       end
		   else
                       debug("HB options")
                       HealBot_ToggleOptions();		   
		   end
		else

                end
        end,
        OnTooltipShow = function(tooltip)
                addon.tooltip = tooltip
                if tooltip and tooltip.AddLine then
                   tooltip:SetText(LaddonName.." "..addon.version)
		   if Healbot_Config_Skins and Healbot_Config_Skins.Current_Skin then
                     tooltip:AddLine("|cffffffff"..L["Current Skin"]..": "..Healbot_Config_Skins.Current_Skin.."|r")
		     LDBo.text = Healbot_Config_Skins.Current_Skin or LaddonName
		   end
                   tooltip:AddLine("|cffff8040"..L["Left Click"].."|r "..L["to choose HealBot skin"])
                   tooltip:AddLine("|cffff8040"..L["Right Click"].."|r "..L["to open HealBot options"])
                   tooltip:AddLine("|cffff8040"..L["Shift Left Click"].."|r "..L["to reset HealBot"])
                   tooltip:AddLine("|cffff8040"..L["Shift Right Click"].."|r "..L["to toggle HealBot"])
                   tooltip:Show()
                end
        end,
     })
     debug("LDB created!")
     if (settings.loaded) then
       addon:HideMinimap()
     end
  end 
  if LDBo and HealBot_Options_Set_Current_Skin then
    hooksecurefunc("HealBot_Options_Set_Current_Skin", 
        function(s) LDBo.text = (s or Healbot_Config_Skins.Current_Skin or LDBo.text) end) 
  end
  if LDBo and HealBot_Options_SetSkins then
    hooksecurefunc("HealBot_Options_SetSkins", 
        function() LDBo.text = (Healbot_Config_Skins.Current_Skin or LDBo.text) end) 
  end
end

addon.DropDownMenu = CreateFrame("Frame", addonName.."_DropDownMenu")
addon.DropDownMenu.displayMode = "MENU"
addon.DropDownMenu.onHide = function(...)
        MenuParent = nil
        MenuItem = nil
end

local menuinfo = {}
addon.DropDownMenu.initialize = function(self, level)
        if not level then return end
        wipe(menuinfo)
        if level == 1 then
                -- Create the title of the menu
                menuinfo.isTitle = 1
                menuinfo.text = LHB.." "..L["skins"]..":"
                menuinfo.notCheckable = 1
                UIDropDownMenu_AddButton(menuinfo, level)

                menuinfo.disabled     = nil
                menuinfo.isTitle      = nil
                menuinfo.notCheckable = nil

                local skins = _G.Healbot_Config_Skins.Skins
                local curskin = _G.Healbot_Config_Skins.Current_Skin
                for _,s in pairs(skins) do
                        menuinfo.text = s
                        menuinfo.arg1 = s
                        menuinfo.func = function(button, arg1)
                                HealBot_Options_Set_Current_Skin(s)
        		        if InCombatLockdown() then
        		           chatMsg(LHB.." "..L["skin change requested (in combat)"])
        		        else
                                   chatMsg(LHB.." "..L["skin set to"]..": "..s)        		       
        		        end                                
                        end
                        menuinfo.checked = (s == curskin)
                        UIDropDownMenu_AddButton(menuinfo, level)
                end

                -- Close menu item
                menuinfo.text         = CLOSE
                menuinfo.func         = function() CloseDropDownMenus() end
                menuinfo.checked      = nil
                menuinfo.notCheckable = 1
                UIDropDownMenu_AddButton(menuinfo, level)
        end
end
