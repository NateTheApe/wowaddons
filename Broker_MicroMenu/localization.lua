
-- CHANGES TO LOCALIZATION SHOULD BE MADE USING http://www.wowace.com/addons/Broker_MicroMenu/localization/

local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("Broker_MicroMenu", "enUS", true)

if L then
	L["Show FPS"] = true
	L["Show frames per second."] = true
	L["Show World Latency"] = true
	L["Show latency for combat data, data from the people around you (specs, gear, enchants, etc.)."] = true
	L["Show Home Latency"] = true
	L["Show latency for chat data, auction house stuff some addon data, and various other data."] = true
	L["Disable Coloring"] = true
	L["General"] = true
	L["ms"] = true
	L["fps"] = true
	L["Show FPS First"] = true
end

local L = AceLocale:NewLocale("Broker_MicroMenu", "deDE")
if L then 
	
	return
end

local L = AceLocale:NewLocale("Broker_MicroMenu", "frFR")
if L then
	
	return
end

local L = AceLocale:NewLocale("Broker_MicroMenu", "koKR")
if L then
	
	return
end

local L = AceLocale:NewLocale("Broker_MicroMenu", "zhTW")
if L then
	
	return
end

local L = AceLocale:NewLocale("Broker_MicroMenu", "zhCN")
if L then
	L["General"] = "综合" -- Needs review
L["Show Home Latency"] = "显示本地延迟" -- Needs review
L["Show World Latency"] = "显示世界延迟" -- Needs review
L["fps"] = "FPS" -- Needs review
L["ms"] = "毫秒" -- Needs review

	return
end

local L = AceLocale:NewLocale("Broker_MicroMenu", "ruRU")
if L then
	
	return
end

local L = AceLocale:NewLocale("Broker_MicroMenu", "esES")
if L then
	
	return
end

local L = AceLocale:NewLocale("Broker_MicroMenu", "esMX")
if L then
	
	return
end
local L = AceLocale:NewLocale("Broker_MicroMenu", "ptBR")
if L then
	
	return
end