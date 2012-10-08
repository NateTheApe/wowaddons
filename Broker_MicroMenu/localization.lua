
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
	L["Disable Coloring"] = "禁用著色" -- Needs review
L["ms"] = "毫秒" -- Needs review
L["Show FPS First"] = "優先顯示FPS" -- Needs review
L["Show Home Latency"] = "顯示本地延遲" -- Needs review
L["Show World Latency"] = "顯示世界延遲" -- Needs review

	return
end

local L = AceLocale:NewLocale("Broker_MicroMenu", "zhCN")
if L then
	L["Disable Coloring"] = "禁止着色" -- Needs review
L["fps"] = "FPS" -- Needs review
L["General"] = "综合" -- Needs review
L["ms"] = "毫秒" -- Needs review
L["Show FPS First"] = "首先显示FPS" -- Needs review
L["Show Home Latency"] = "显示本地延迟" -- Needs review
L["Show latency for combat data, data from the people around you (specs, gear, enchants, etc.)."] = "显示战斗数据的延迟, 来自周围人的数据（天赋，装备，副本，等。。。）" -- Needs review
L["Show World Latency"] = "显示世界延迟" -- Needs review

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
	L["Disable Coloring"] = "Desabilitar cores" -- Needs review
L["fps"] = "fps" -- Needs review
L["General"] = "Geral" -- Needs review
L["ms"] = "ms" -- Needs review
L["Show FPS First"] = "Mostrar FPS primeiro" -- Needs review
L["Show Home Latency"] = "Mostrar latência Local" -- Needs review
L["Show latency for chat data, auction house stuff some addon data, and various other data."] = "Mostrar latência para dados de chat, coisas da casa de leilões, alguns dados de addons e outros dados." -- Needs review
L["Show latency for combat data, data from the people around you (specs, gear, enchants, etc.)."] = "Mostrar latência para dados de combate, dados de pessoas ao seu redor (especs, equipamento, encantamentos etc.)" -- Needs review
L["Show World Latency"] = "Mostrar latência Global" -- Needs review

	return
end