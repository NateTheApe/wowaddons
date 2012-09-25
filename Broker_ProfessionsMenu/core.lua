--------------------------------------------------------------------------------
-- Broker_ProfessionsMenu                                                     --
-- Author: Sanori/Pathur                                                      --
--------------------------------------------------------------------------------
local _, me = ...                                 --Includes all functions and variables
me.version = "Version: 2.1.4a (13/03/2012)"



--------------------------------------------------------------------------------
-- Events, Libs, Variables                                                    --
--------------------------------------------------------------------------------
--Register Events
me.frame = CreateFrame("FRAME")
me.frame:RegisterEvent("ADDON_LOADED")
me.frame:RegisterEvent("PLAYER_LOGIN")
me.frame:RegisterEvent("PLAYER_LOGOUT")
me.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
me.frame:RegisterEvent("TRADE_SKILL_UPDATE")
me.frame:RegisterEvent("TRADE_SKILL_SHOW")
me.frame:RegisterEvent("TRAINER_SHOW")
me.frame:RegisterEvent("TRAINER_UPDATE")
me.frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
me.frame:RegisterEvent("UNIT_SPELLCAST_FAILED")
me.frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
me.frame:RegisterEvent("LOOT_CLOSED")
me.frame:RegisterEvent("BAG_UPDATE")
me.scantip = CreateFrame( "GameTooltip", "BPM_ScanTip", nil, "GameTooltipTemplate" );
me.scantip:SetOwner( WorldFrame, "ANCHOR_NONE" );
me.scantip:AddFontStrings(
	me.scantip:CreateFontString( "$parentTextLeft1", nil, "GameTooltipText" ),
	me.scantip:CreateFontString( "$parentTextRight1", nil, "GameTooltipText" )
);

me.LDB = LibStub:GetLibrary("LibDataBroker-1.1")	--Data Broker
me.TipHooker = LibStub("LibTipHooker-1.1")			--Tooltip mod

me.quicklauncher = {}										--Quick Launcher
me.sharedcds = {}												--shared cds
me.quicktradeskills = {}									--Quicktradeskills
BPMAutoloot=nil												--Global Variable for Auto Loot Script
local my = UnitName("player")								--player name
me.L={}															--localization



--------------------------------------------------------------------------------
-- Functions                                                                  --
--------------------------------------------------------------------------------
--Localization
--add new locale
function me:NewL(table, locale)
	if (locale and locale~=GetLocale()) then return end
	for k,v in pairs(table) do
		if (locale or (not locale and not me.L[k])) then
			me.L[k] = v
		end
	end
end
--Filter Tradewindows and Tradeskills
function me:GetProfs(sorted)
	local result={}
	--Ignorelist
	local ignore={}
	--Additional
	local additional={--UnitClass("player") create atomaically the correct title
		[53428]=UnitClass("player"),		--Rune Forging
		[1804]=UnitClass("player"),		--Pick Look
	}
	--Professions
	for _,index in pairs({GetProfessions()}) do
		if index then
			local name, texture, rank, maxRank, numSpells, spelloffset, skillLine = GetProfessionInfo(index)
			if numSpells == 1 or numSpells == 2 and not ignore[name] then
				if not IsPassiveSpell(spelloffset+1, BOOKTYPE_PROFESSION) then
					local subname,_ = GetSpellBookItemName(spelloffset+1, BOOKTYPE_PROFESSION)
					if not ignore[subname] then
						if sorted then
							if not result[name] then result[name]={} end
							result[name][subname] = GetSpellBookItemTexture(spelloffset+1, BOOKTYPE_PROFESSION)
						else
							result[subname] = GetSpellBookItemTexture(spelloffset+1, BOOKTYPE_PROFESSION)
						end
					end
				end
				if numSpells == 2 and not IsPassiveSpell(spelloffset+2, BOOKTYPE_PROFESSION) then
					local subname,_ = GetSpellBookItemName(spelloffset+2, BOOKTYPE_PROFESSION)
					if not ignore[subname] then
						if sorted then
							if not result[name] then result[name]={} end
							result[name][subname] = GetSpellBookItemTexture(spelloffset+2, BOOKTYPE_PROFESSION)
						else
							result[subname] = GetSpellBookItemTexture(spelloffset+2, BOOKTYPE_PROFESSION)
						end
					end
				end
			end
		end
	end
	--Additional
	for id,title in pairs(additional) do
		local name,_,icon,_ = GetSpellInfo(id)
		if GetSpellBookItemInfo(name) then
			if sorted then
				if not result[title] then result[title]={} end
				result[title][name] = icon
			else
				result[name] = icon
			end
		end
	end
	return result
end
--Modified Version of GetSpellInfo()
function me:GetSpellInfo(spell)
	local name,_,icon,_ = GetSpellInfo(spell)
	if not name then name = "---" end
	if not icon then icon = "Interface\\Icons\\Trade_BlackSmithing" end
	return name, icon
end
--Table Alphabetical Sort Function
function me:pairsByKeys (t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
		table.sort(a, f)
		local i = 0                                    --iterator variable
		local iter = function ()                       --iterator function
		i = i + 1
		if a[i] == nil then
			return nil
		else
			return a[i], t[a[i]]
		end
	end
	return iter
end
--Count of Table Elements
function me:tcount(tab)
	local n = #tab
	if (n == 0) then
		for _ in pairs(tab) do
			n = n + 1
		end
	end
	return n
end
--GetSpellId
function me:GetSpellID(spell)
	if not spell then return end
	local link,_ = GetSpellLink(spell)
	if not link then return end
	return tonumber(strmatch(link,"|Hspell:(%d+)|h"))
end



--------------------------------------------------------------------------------
-- Load/Save Saved Variables                                                  --
--------------------------------------------------------------------------------
me.frame:SetScript("OnEvent", function(self, event, ...)
	local arg1, arg2 = ...
	if event == "ADDON_LOADED" and arg1 == "Broker_ProfessionsMenu" then
		--Default values
		if (Broker_ProfessionsMenu == nil) then Broker_ProfessionsMenu = {} end
		--Copy saves to internal var
		me.save = Broker_ProfessionsMenu[GetCVar("realmName")] or {}
		me.TrainerDB = Broker_ProfessionsMenu["%TrainerDB%"] or {}
		local defaultsave = {						--default save values
			config = {
				exchangeleftright = false,
				bothfactions = false,
				trainerdisabled = false,
				tooltip = {
					showcds = true,
					showskills = true,
					showbuttons = true,
					ShowAllTooltips = true,
					ShowIfYouCanCraftThisInItemTooltips = true,
				},
			},
			cds = {},
			tradelinks = {},
			craftableitems = {},
			quicklauncher = {},
			quicklaunch = {
				left = 0,
				shiftleft = 0,
				altleft = 0,
				ctrlleft = 0,
			},
			favorites = {},
			filter = {},
			faction = "",
		}
		--creates a new save tableb
		local function newsave(tbl, default)
			if (tbl==nil) then return default end		--if tbl is empty, then return default table/value
			if (next(default)==nil) then return tbl end	--if default is empty, then return tbl
			local result = {}
			for k,v in pairs(default) do
				if (tbl[k]==nil or type(v)=='table') then
					result[k] = newsave(tbl[k], v)	--recursive
				else
					result[k] = tbl[k]
				end
			end
			return result
		end
		me.save[my] = newsave(me.save[my], defaultsave)
	elseif event == "PLAYER_LOGIN" then
		--Init LibDataBroker
		me:InitLDB(me:GetSpellInfo(me.save[my].quicklaunch.left))
		--Create Launchers 
		for k,_ in pairs(me.save[my].quicklauncher) do
			me.quicklauncher[k]=me:newlauncher(me:GetSpellInfo(k))
		end
		--Modifying Atlasloot Recept Tooltips
		if AtlasLootTooltip then
			AtlasLootTooltip:HookScript("OnTooltipSetSpell", function(self, ...)
				me:modifytooltip(self,select(3,self:GetSpell()))
			end)
		end
		--save players faction
		me.save[my].faction,_ = UnitFactionGroup("player")
		--clear trainer stuff if module is disabled (save memory)
		if me.save[my].config.trainerdisabled then
			me.notrainer = true
			me.Trainer_Refresh = nil
			self:UnregisterEvent("TRAINER_SHOW")
			self:UnregisterEvent("TRAINER_UPDATE")
		end
	elseif event == "PLAYER_LOGOUT" then
		Broker_ProfessionsMenu[GetCVar("realmName")] = me.save
		Broker_ProfessionsMenu["%TrainerDB%"] = me.TrainerDB
	elseif event == "PLAYER_REGEN_DISABLED" then
		me.secureframe:SetAttribute("*type1", nil)
		me.secureframe:SetAttribute("*type2", nil)
		for _,v in pairs(me.quicklauncher) do
			v.secureframe:SetAttribute("type1", nil)
		end
	elseif event == "TRADE_SKILL_SHOW" then
		--Trainer Data--------------------------------------------------
		if (not me.Trainer and not me.notrainer) then	--Create Scroll List (call only once), create only if trainer module is enabled
			me.libst = LibStub("ScrollingTable")			--include lib
			me.Trainer = me.libst:CreateST({
				{
					["width"] = 20,			--icon
					["align"] = "center",
				},
				{
					["width"]=242,				--name
					["align"]="left",
					["defaultsort"] = "dsc",
				},
				{
					["width"]=32,				--skill
					["align"]="right",
					["sort"] = "desc",
					["sortnext"] = 2,
				},
			},7,18,{["r"] = 0,["g"] = 0.2,["b"] = 1.0,["a"] = 0.3},TradeSkillFrame)
			me.Trainer.frame:SetPoint("TOPLEFT",TradeSkillDetailScrollFrame,"BOTTOMLEFT",-1,0)
			me.Trainer.frame:SetHeight(136)
			local bd = me.Trainer.frame:GetBackdrop()
			bd.bgFile = nil
			me.Trainer.frame:SetBackdrop(bd)
			me.Trainer.frame:Hide()
			me.Trainer:RegisterEvents({
				["OnShow"] = function(rowFrame, cellFrame, data, cols, row, realrow, column, scrollingTable, ...)
					if (not row) then
						cellFrame:Hide()	--hide title line
					end
				end,
				["OnEnter"] = function(rowFrame, cellFrame, data, cols, row, realrow, column, scrollingTable, ...)
					if not data or not row or not data[realrow] or not data[realrow]["cols"][2]["id"] then return end
					GameTooltip:SetOwner(rowFrame, "ANCHOR_NONE")
					GameTooltip:SetPoint("BOTTOMLEFT",rowFrame,"TOPRIGHT")
					GameTooltip:SetSpellByID(data[realrow]["cols"][2]["id"])
					GameTooltip:AddLine(" ")
					GameTooltip:AddLine(data[realrow]["cols"][2]["cost"])
					GameTooltip:Show()
				end,
				["OnLeave"] = function()
					GameTooltip:Hide()
				end,
			})
			--Button
			me.Trainer.showbtn = CreateFrame("Button","BPM_TrainerFrameShow",TradeSkillFrame,"UIPanelButtonTemplate")
			me.Trainer.showbtn:SetWidth(50)
			me.Trainer.showbtn:SetHeight(TradeSkillFilterButton:GetHeight())
			TradeSkillFrameSearchBox:SetWidth(138)
			TradeSkillFilterButton:SetPoint("TOPLEFT",me.Trainer.showbtn,"TOPRIGHT",1,0)
			me.Trainer.showbtn:SetPoint("TOPLEFT",TradeSkillFrameSearchBox,"TOPRIGHT",0,0)
			me.Trainer.showbtn:SetFrameStrata(TradeSkillDetailScrollChildFrame:GetFrameStrata())
			me.Trainer.showbtn:SetFrameLevel(TradeSkillDetailScrollChildFrame:GetFrameLevel()+1)
			me.Trainer.showbtn:SetText(me.L.trainer)
			me.Trainer.showbtn:SetScript("OnClick",function()
				me.Trainer.showframe = not me.Trainer.showframe
				me:Trainer_Refresh()
			end)
			me.Trainer.showbtn:Show()
			me.Trainer.showframe = nil
		end
		me:ScanTradeSkillFrame()
		--Favorite Button-----------------------------------------------		
		if not me.FavoriteButton then --Call only once
			me.FavoriteButton=true
			--Add RightClick Event to TradSkillSkill-Buttons
			for i=1, TRADE_SKILLS_DISPLAYED do
				_G["TradeSkillSkill"..i]:SetScript("OnMouseDown", function(self, button)
					if (button=="RightButton" and me.FavoriteButtonProfID and self.BPM_RecipeID) then
						local data = me.save[my].favorites[me.FavoriteButtonProfID]
						if not data then
							me.save[my].favorites[me.FavoriteButtonProfID] = {}
							data = {}
						end
						if data[self.BPM_RecipeID] then
							data[self.BPM_RecipeID] = nil
							if me:tcount(data) == 0 then data = nil end
								me.save[my].favorites[me.FavoriteButtonProfID] = data
							else
								data[self.BPM_RecipeID] = self.BPM_Type
								me.save[my].favorites[me.FavoriteButtonProfID] = data
							end
						TradeSkillFrame_Update()
						self:GetScript("OnEnter")(self)	
					end
				end)
				_G["TradeSkillSkill"..i]:HookScript("OnEnter", function(self)
					if (me.FavoriteButtonProfID and self.BPM_RecipeID) then
						local skillName = GetTradeSkillInfo(self:GetID())
						GameTooltip:SetOwner(self, "ANCHOR_NONE")
						GameTooltip:SetPoint("TOPLEFT",TradeSkillFrame,"BOTTOMLEFT")
						GameTooltip:ClearLines()
						GameTooltip:AddLine(skillName)
						GameTooltip:AddLine(self.BPM_Tooltip,1,1,1)
						GameTooltip:Show()
					end
				end)
				_G["TradeSkillSkill"..i]:HookScript("OnLeave", function(self) GameTooltip:Hide() end)
			end
			--Hook Update Function
			hooksecurefunc("TradeSkillFrame_Update",function()
				me.FavoriteButtonProfID = nil
				if not IsTradeSkillLinked() then
					me.FavoriteButtonProfID = me:GetSpellID(GetTradeSkillLine())
					if not me.FavoriteButtonProfID then
						if GetTradeSkillLine()==GetSpellInfo(2575) then
							me.FavoriteButtonProfID = 2656	--Verhüttung
						else
							return
						end
					end
					local skillOffset = FauxScrollFrame_GetOffset(TradeSkillListScrollFrame)
					for i=1, TRADE_SKILLS_DISPLAYED do
						local skillIndex = i + skillOffset;
						if TradeSkillFilterBar:IsShown() then skillIndex=skillIndex-1 end
						local skillName, skillType, numAvailable, isExpanded, altVerb, numSkillUps = GetTradeSkillInfo(skillIndex)
						_G["TradeSkillSkill"..i].BPM_RecipeID = nil
						if (skillType and skillType ~= "header") then
							local link = GetTradeSkillRecipeLink(skillIndex)
							if link then 
								local recipeid = tonumber(strmatch(link,"enchant:(%d+)"))
								if me.save[my].favorites[me.FavoriteButtonProfID] and me.save[my].favorites[me.FavoriteButtonProfID][recipeid] then
									_G["TradeSkillSkill"..i].BPM_Tooltip = me.L.rightclick..": "..me.L.removefromfav
									_G["TradeSkillSkill"..i]:SetNormalTexture("Interface\\AddOns\\Broker_ProfessionsMenu\\icons\\fav.tga")
									_G["TradeSkillSkill"..i]:GetNormalTexture():SetAlpha(1.0)
								else
									_G["TradeSkillSkill"..i].BPM_Tooltip = me.L.rightclick..": "..me.L.addtofav
								end
								_G["TradeSkillSkill"..i].BPM_RecipeID = recipeid
								if altVerb then
									_G["TradeSkillSkill"..i].BPM_Type = altVerb
								else
									_G["TradeSkillSkill"..i].BPM_Type = "Create"
								end
							end
						end
					end
					-- Without this lines, the HighlightFrame would sometimes hide the favicon
					if TradeSkillHighlightFrame:IsVisible() then
						local point, relativeFrame, relativePoint, ofsx, ofsy = TradeSkillHighlightFrame:GetPoint()
						TradeSkillHighlightFrame:SetPoint(point, relativeFrame, relativePoint, ofsx+22, ofsy)
						TradeSkillHighlightFrame:SetWidth(TradeSkillHighlightFrame:GetWidth()-22)
					end
					--
				end
			end)
			TradeSkillFrame_Update()
		end
	--Scan Cooldowns--------------------------------------------------------
	elseif event == "TRADE_SKILL_UPDATE" then
		me:ScanTradeSkillFrame()
	--Autoloot and Dropdownmenu Refresh
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
		if arg1=="player" and BPMAutoloot then
			SetCVar('AutoLootDefault', 1)
		end
	elseif event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED" then
		if arg1=="player" and BPMAutoloot then
			BPMAutoloot=nil
			SetCVar('AutoLootDefault', 0)
		end
	elseif event == "LOOT_CLOSED" then
		if BPMAutoloot then
			BPMAutoloot=nil
			SetCVar('AutoLootDefault', 0)
		end
	elseif event == "BAG_UPDATE" then
		if me.dropdown:IsOpen(me.dropdown.parent) then me.dropdown:Refresh(2) end
	--Trainer Data Scan----------------------------------------------------------
	elseif event == "TRAINER_SHOW" then
		me.TrainerServiceTypeFilter = {	--save setting
			available = GetTrainerServiceTypeFilter("available") or 0,
			unavailable= GetTrainerServiceTypeFilter("unavailable") or 0,
			used = GetTrainerServiceTypeFilter("used") or 0,
		}
		SetTrainerServiceTypeFilter("available",1)
		SetTrainerServiceTypeFilter("unavailable",1)
		me.TrainerServiceTypeFilter.ready = true
		SetTrainerServiceTypeFilter("used",1)
	elseif event == "TRAINER_UPDATE" then
		if me.TrainerServiceTypeFilter.ready then
			me.TrainerServiceTypeFilter.ready = false
			if IsTradeskillTrainer() then
				local profid = me:TransProfID(me:GetSpellID(GetTrainerServiceSkillReq(1)))
				if profid then
					me.TrainerDB[profid] = {}
					for i=1, GetNumTrainerServices() do
						me.scantip:ClearLines();
						me.scantip:SetTrainerService(i)
						local id = select(3,me.scantip:GetSpell())
						if id then
							local skill,_ = select(2,GetTrainerServiceSkillReq(i))
							local cost,_ = GetTrainerServiceCost(i)
							me.TrainerDB[profid][id]=strjoin(",",skill,cost)
						end
					end
				end
			end
			SetTrainerServiceTypeFilter("available",me.TrainerServiceTypeFilter.available)	--restore settings
			SetTrainerServiceTypeFilter("unavailable",me.TrainerServiceTypeFilter.unavailable)
			SetTrainerServiceTypeFilter("used",me.TrainerServiceTypeFilter.used)
		end
		ClassTrainerFrame.scrollFrame.scrollBar:SetValue(0)
	end
end)



--------------------------------------------------------------------------------
-- Modifying Tooltips                                                         --
--------------------------------------------------------------------------------
function me:modifytooltip(tooltip,id,isitem)
	if not id or not tooltip or not me.save[my].config.tooltip.ShowIfYouCanCraftThisInItemTooltips then return end
	local chars,prof
	for k,v in pairs(me.save) do
		if v.faction==UnitFactionGroup("player") or me.save[my].config.bothfactions then
			if v.craftableitems then
				for kk,vv in pairs(v.craftableitems) do
					local found
					if isitem then --Get ID of Henchant
						found = strfind(vv,"|%d+,"..id.."|") -- |ECHANT,ITEM|
					else
						found = strfind(vv,"|"..id..",%d+|")
					end
					if found then
						prof,_=GetSpellInfo(kk)
						if me.save[my].config.bothfactions and v.faction=="Horde" then
							if not chars then chars=k.." ("..FACTION_HORDE..")" else chars=chars..", "..k.." ("..FACTION_HORDE..")" end
						elseif me.save[my].config.bothfactions and v.faction=="Alliance" then
							if not chars then chars=k.." ("..FACTION_ALLIANCE..")" else chars=chars..", "..k.." ("..FACTION_ALLIANCE..")" end
						else
							if not chars then chars=k else chars=chars..", "..k end
						end
					end
				end
			end
		end
	end
	if prof then
		tooltip:AddLine(' ')
		tooltip:AddLine(prof..": "..chars,1,0.60,0)
		tooltip:Show()
	end
end
--Modifying Item Tooltips
me.TipHooker:Hook(function(self,...)
	 local itemid = strmatch(select(2,self:GetItem()),"|Hitem:(%d+):")
	 me:modifytooltip(self,itemid,true)
end, "item")
--Modifying Enchant Recept Tooltips
hooksecurefunc(ItemRefTooltip, "SetHyperlink", function(self, ...)
	local arg1,_ = ...
	if select(1,strfind(arg1,"enchant:")) then
		local id=strmatch(arg1,"enchant:(%d+)")
		me:modifytooltip(self,id)
	end
end)



--------------------------------------------------------------------------------
-- Init LibDataBroker (Main Window)                                           --
--------------------------------------------------------------------------------
function me:InitLDB(txt,icon)
	if txt=="---" then txt=me.L.professions end
	--Create Secure Frame Overlay
	me.secureframe = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate");
	me.secureframe.OnMouseUp = function(self,button)
		if InCombatLockdown() then return end
		if me.save[my].config.exchangeleftright then
			self:SetAttribute("*type1", nil)
			self:SetAttribute("*type2", "spell")
		else
			self:SetAttribute("*type2", nil)
			self:SetAttribute("*type1", "spell")
		end
		if IsControlKeyDown() then
			self:SetAttribute("spell", GetSpellInfo(me.save[my].quicklaunch.ctrlleft))
		elseif IsAltKeyDown() then
			self:SetAttribute("spell", GetSpellInfo(me.save[my].quicklaunch.altleft))
		elseif IsShiftKeyDown() then
			self:SetAttribute("spell", GetSpellInfo(me.save[my].quicklaunch.shiftleft))
		else
			self:SetAttribute("spell", GetSpellInfo(me.save[my].quicklaunch.left))
		end
		if button == "RightButton" and not me.save[my].config.exchangeleftright then
			GameTooltip:Hide()
			me.dropdown.parent=self
			if IsShiftKeyDown() then
				me.dropdown:Open(self, 'children', function() me.dropdown:ShowFavorites() end)
			else
				me.dropdown:Open(self, 'children', function(level, value) me.dropdown:ShowMenu(level, value) end)
			end
		elseif button == "LeftButton" and me.save[my].config.exchangeleftright then
			GameTooltip:Hide()
			me.dropdown.parent=self
			if IsShiftKeyDown() then
				me.dropdown:Open(self, 'children', function() me.dropdown:ShowFavorites() end)
			else
				me.dropdown:Open(self, 'children', function(level, value) me.dropdown:ShowMenu(level, value) end)
			end
		end
	end
	--Create LDB
	me.dataobj = me.LDB:NewDataObject("Broker_ProfessionsMenu", {
		type = "data source",
		text = txt,
		icon = icon,
		OnEnter = function(self)
			me:Broker_OnEnter(self,me.secureframe,function(self) me:tooltip(self) end)
		end,
	})
end



--------------------------------------------------------------------------------
-- Creates Launchers                                                          --
--------------------------------------------------------------------------------
function me:newlauncher(spell,icon)
	local launcher = {}
	--secure frame
	launcher.secureframe = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate")
	launcher.secureframe.OnMouseUp = function(self,button)
		if InCombatLockdown() then return end
		self:SetAttribute("type1", "spell")
		self:SetAttribute("spell", spell)
	end
	--Create Dataobject
	launcher.dataobj = me.LDB:NewDataObject("Launcher: "..spell, {
		type = "data source",
		text = spell,
		icon = icon,
		OnEnter = function(self)
			me:Broker_OnEnter(self,launcher.secureframe,function(self)
				local link=GetSpellLink(spell)
				if link then
					self:SetHyperlink(link)
				else
					self:AddLine(spell)
				end
			end)
		end
	})
	return launcher
end



--------------------------------------------------------------------------------
-- Refresh broker icon/text                                                   --
--------------------------------------------------------------------------------
function me:Professions_UpdateInfo(txt,icon)
	if txt=="---" then txt=me.L.professions end
	me.dataobj.text = txt
	me.dataobj.icon = icon
end



--------------------------------------------------------------------------------
-- Error Messages / Other Messages                                            --
--------------------------------------------------------------------------------
function me:Error(txt)
	UIErrorsFrame:AddMessage(txt,1.0,0,0,100,3);
end



--------------------------------------------------------------------------------
-- Secure Frame Stuff                                                         --
--------------------------------------------------------------------------------
function me:Broker_OnEnter(brokerframe,secureframe,tooltipfunc)
	if InCombatLockdown() then return end
	--Hover Events
	secureframe:SetScript("OnEnter",function(self)
		if brokerframe:GetScript("OnEnter") then
			brokerframe:GetScript("OnEnter")(brokerframe)
		end
		if not InCombatLockdown() and tooltipfunc and not self:GetScript("OnUpdate") and brokerframe:IsVisible() and me.save[my].config.tooltip.ShowAllTooltips then
			GameTooltip:SetOwner(self, "ANCHOR_NONE")
			GameTooltip:SetPoint(me:GetTipAnchor(self))
			GameTooltip:ClearLines()
			tooltipfunc(GameTooltip)
			GameTooltip:Show()
		end
	end)
	secureframe:SetScript("OnLeave",function(self)
		GameTooltip:Hide()
		if brokerframe:GetScript("OnLeave") then
			brokerframe:GetScript("OnLeave")(brokerframe)
		end
	end)
	brokerframe:SetScript("OnHide",function()
		if not InCombatLockdown() then
			secureframe:Hide()
		end
	end)
	--Click Events
	secureframe:RegisterForClicks("AnyUp")
	secureframe:SetScript("OnMouseDown",function(self,button,down)
		if self.OnMouseUp and brokerframe:IsVisible() then
			self.OnMouseUp(self,button)
		end
	end)
	--Drag Frame
	secureframe:RegisterForDrag("LeftButton")
	secureframe:SetMovable(true)
	secureframe:SetScript("OnDragStart",function(self)
		if InCombatLockdown() then return end
		if brokerframe:GetScript("OnDragStart") then
			GameTooltip:Hide()
			brokerframe:GetScript("OnDragStart")(brokerframe)
			self:SetScript("OnUpdate", function(self)
				self:SetAllPoints(brokerframe)
				if not IsMouseButtonDown("LeftButton") then
					brokerframe:GetScript("OnDragStop")(brokerframe)
					self:SetScript("OnUpdate",nil)
				end
			end)
			self:Show()
		end
	end)
	--Show Frame
	secureframe:SetFrameStrata(brokerframe:GetFrameStrata())
	secureframe:SetFrameLevel(brokerframe:GetFrameLevel()+1)
	secureframe:SetAllPoints(brokerframe)
	secureframe:Show()
end



--------------------------------------------------------------------------------
-- Trainer Frame                                                              --
--------------------------------------------------------------------------------
function me:Trainer_Refresh()
	if (not me.Trainer or me.save[my].config.trainerdisabled) then return end
	if not IsTradeSkillLinked() and GetNumTradeSkills() and GetTradeSkillListLink() and me.Trainer.showframe then
		local prof,curskill,maxskill = GetTradeSkillLine()
		local profid = me:TransProfID(me:GetSpellID(prof))
		local table={}
		if not profid or not me.TrainerDB[profid] then
			tinsert(table,{["cols"] = {{["value"] = "",},{["value"] = me.L.databaseempty,["color"] = {r=1.0,g=0.81,b=0},},{["value"] = 0,["color"] = {a=0},},},})
			tinsert(table,{["cols"] = {{["value"] = "",},{["value"] = format(me.L.visityourtrainer, prof),["color"] = {r=1.0,g=0.81,b=0},},{["value"] = 1,["color"] = {a=0}},},})
		else
			local profs = {}
			for _,v in pairs({strsplit("|",strsub(gsub(me.save[my].craftableitems[profid],",%d+|",""),2))}) do
				if not GetSpellInfo(v) then return end
				profs[GetSpellInfo(v)]=1
			end
			for name,_ in pairs(me:GetProfs()) do
				if (prof~=name) then profs[name]=1 end
			end
			for skillid,data in pairs(me.TrainerDB[profid]) do
				local reqskill, money = strsplit(",",data)
				reqskill = tonumber(reqskill)
				money = tonumber(money)
				if not profs[GetSpellInfo(skillid)] then --Test, if skill know
					local name,_,icon,_ = GetSpellInfo(skillid)
					local _,maxrank = me:TransProfID(skillid)
					if (not maxrank or maxrank>=maxskill+75) then
						local skillcolor
						if reqskill>curskill then
							skillcolor = {r=1.0,g=0,b=0}
						else
							skillcolor = {r=0,g=1.0,b=0}
						end
						local gold = floor( money / COPPER_PER_GOLD )
						local silver = floor( ( money - ( gold * COPPER_PER_GOLD ) ) / COPPER_PER_SILVER )
						local copper = mod( money, COPPER_PER_SILVER )
						tinsert(table,{
							["cols"] = {
								{["value"] = "|T"..icon..":16:16:0:0|t",},--Spalte 1
								{
									["value"] = name,
									["id"] = skillid,
									["cost"] = format("%s %s %s",format( GOLD_AMOUNT_TEXTURE, gold, 0, 0 ),format( SILVER_AMOUNT_TEXTURE, silver, 0, 0 ),format( COPPER_AMOUNT_TEXTURE, copper, 0, 0 )),
									["color"] = {r=1.0,g=0.81,b=0},
								},
								{["value"] = reqskill,["color"]=skillcolor,},
							},
						})
					end
				end
			end
		end
		if me:tcount(table)==0 then
			tinsert(table,{["cols"] = {{["value"] = "",},{["value"] = me.L.knowallrecipes,},{["value"] = "",},},})
		end
		me.Trainer:SetData(table)
		TradeSkillFrame:SetHeight(560)
		me.Trainer.frame:Show()
	else
		TradeSkillFrame:SetHeight(424)
		me.Trainer.frame:Hide()
	end
end



--------------------------------------------------------------------------------
-- scan for cooldowns end recepts                                             --
--------------------------------------------------------------------------------
function me:ScanTradeSkillFrame()
	if me.Trainer then me.Trainer.showbtn:Disable() end
	if not IsTradeSkillLinked() and GetTradeSkillListLink() then
		local profid, NoSpezi, _profid=me:TransProfID(tonumber(strmatch(GetTradeSkillListLink(),"|Htrade:(%d+)")))
		if NoSpezi then
			me.save[my].tradelinks[profid] = GetTradeSkillListLink()			--Save Trade Link
		else
			me.save[my].tradelinks[_profid] = GetTradeSkillListLink()		--Save Trade Link of spezi
		end
		me.save[my].craftableitems[profid] = ""
		--Remove deleted Profession
		local craftableitems = me.save[my].craftableitems
		local tradelinks = me.save[my].tradelinks
		me.save[my].craftableitems = {}
		me.save[my].tradelinks = {}
		for k,v in pairs(me:GetProfs()) do
			local _NoSpezi, _k
			k, _NoSpezi, _k = me:TransProfID(me:GetSpellID(k))
			if craftableitems[k]~=nil then
				me.save[my].craftableitems[k] = craftableitems[k]
			end
			if _NoSpezi and tradelinks[k]~=nil then
				me.save[my].tradelinks[k] = tradelinks[k]
			elseif not _NoSpezi and tradelinks[_k]~=nil then
				me.save[my].tradelinks[_k] = tradelinks[_k]
			end
		end
		--Scan
		local i=1
		while(GetTradeSkillInfo(i)) do
			local name,skilltype = GetTradeSkillInfo(i)
			if (skilltype~="header") then
				local enchant=GetTradeSkillRecipeLink(i)
				local item=GetTradeSkillItemLink(i)
				local cd=GetTradeSkillCooldown(i)
				if cd then
					if me.sharedcds[name] then name=me.sharedcds[name] end
					me.save[my].cds[name] = time()+floor(cd+0.5)
				end
				if type(enchant)=="string" then
					enchant=strmatch(enchant,"|Henchant:(%d+)")
					if type(item)=="string" then
						item=strmatch(item,"|Hitem:(%d+):")
						if not item then item="0" end
					else
						item="0"
					end
						me.save[my].craftableitems[profid] = me.save[my].craftableitems[profid].."|"..enchant..","..item.."|"
				end
			end
			i=i+1
		end
		--Update Trainer Frame
		if me.Trainer and not me.save[my].config.trainerdisabled then
			me.Trainer.showbtn:Enable()
		end
	end
	if not me.notrainer then me:Trainer_Refresh() end
end



--because me:GetSpellID() returns different Prof.-IDs for different ranks, I need a translation function to return always the same id (rank 1) (for saving, ...)
me.profidtable={	--format {id of rank 1,id2,id3,id4,...,other ids[elixir master, etc.]}   ->   return "id of rank 1", "max skill"
	{2259,3101,3464,11611,28596,51304,80731,28677,28675,28672},
	{2575,2576,3564,10248,29354,50310,74517,2656},
	{4036,4037,4038,12656,30350,51306,82774,20219,20222},
	{45357,45358,45359,45360,45361,45363,86008},
	{25229,25230,28894,28895,28897,51311,73318},
	{2366,2368,3570,11993,28695,50300,74519},
	{8613,8617,7618,10768,32678,50305,74522},
	{2108,3104,3811,10662,32549,51302,81199,10656,10658,10660},
	{2018,3100,3538,9785,29844,51300,76666,9788,9787,17041,17040,17039},
	{3908,3909,3910,12180,26790,51309,75156,26798,26801,26797},
	{7411,7412,7413,13920,28029,51313,74258},
	{7620,7731,7732,18248,33095,51294,88868},
	{78670,88961,89718,89719,89720,89721,89722},
	{3273,3274,7924,10846,27028,45542,74559},
	{2550,3102,3413,18260,33359,51296,88053},
}
function me:TransProfID(profid)
	if not profid then return end
	for _,v in pairs(me.profidtable) do
		for kk,vv in pairs(v) do
			if (vv==profid) then
				local maxrank
				if kk<8 then maxrank=kk*75 end
				return v[1], maxrank, profid
			end
		end
	end
	return profid, nil, profid
end