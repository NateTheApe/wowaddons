--------------------------------------------------------------------------------
-- Broker_ProfessionsMenu                                                     --
-- Author: Sanori/Pathur                                                      --
--------------------------------------------------------------------------------
local _, me = ...                                 --Includes all functions and variables
me.version = "Version: 2.7 (27. May. 2013)"



--------------------------------------------------------------------------------
-- Events, Libs, Variables                                                    --
--------------------------------------------------------------------------------
--<< Register Events >>--
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
--<< Include libs >>--
me.dropdown = LibStub('LibDewdrop-3.0')			--Dropdownmenu
me.LDB = LibStub:GetLibrary("LibDataBroker-1.1")	--Data Broker
me.TipHooker = LibStub("LibTipHooker-1.1")			--Tooltip mod
--<< Init variables and constants >>--
me.quicklauncher = {}										--Quick Launcher
me.sharedcds = {}												--shared cds
BPMAutoloot=nil												--Global Variable for Auto Loot Script
local my = UnitName("player")								--player name
--<< Key short cuts >>--
me.keys = {														--Keys
	{['Key']='left',       ['Button']=me.L.leftclick},
	{['Key']='shiftleft',  ['Button']=me.L.leftclick,  ['Mod']=me.L.shift},
	{['Key']='altleft',    ['Button']=me.L.leftclick,  ['Mod']=me.L.alt},
	{['Key']='ctrlleft',   ['Button']=me.L.leftclick,  ['Mod']=me.L.ctrl},
	{['Key']='right',      ['Button']=me.L.rightclick},
	{['Key']='shiftright', ['Button']=me.L.rightclick, ['Mod']=me.L.shift},
	{['Key']='altright',   ['Button']=me.L.rightclick, ['Mod']=me.L.alt},
	{['Key']='ctrlright',  ['Button']=me.L.rightclick, ['Mod']=me.L.ctrl},
}
function me:KeyDownIndex(button)							--Index der gedrückten Tastenkombination
	local shift = IsShiftKeyDown();
	local ctrl  = IsControlKeyDown();
	local alt   = IsAltKeyDown();
	if (button=='LeftButton' and not shift and not ctrl and not alt) then return 1 end
	if (button=='LeftButton' and shift and not ctrl and not alt) then return 2 end
	if (button=='LeftButton' and not shift and not ctrl and alt) then return 3 end
	if (button=='LeftButton' and not shift and ctrl and not alt) then return 4 end
	if (button=='RightButton' and not shift and not ctrl and not alt) then return 5 end
	if (button=='RightButton' and shift and not ctrl and not alt) then return 6 end
	if (button=='RightButton' and not shift and not ctrl and alt) then return 7 end
	if (button=='RightButton' and not shift and ctrl and not alt) then return 8 end
end



--------------------------------------------------------------------------------
-- Events                                                                     --
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
			lastprofession = 0,
			cds = {},
			tradelinks = {},
			craftableitems = {},
			quicklauncher = {},
			quicklaunch = {
				left = 0,
				shiftleft = 0,
				altleft = 0,
				ctrlleft = 0,
				right = "menu",
				shiftright = "fav",
				altright = 0,
				ctrlright = 0,
			},
			favorites = {},
			faction = "",
			class = "",
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
		me:InitLDB()
		--Create Launchers 
		for k,_ in pairs(me.save[my].quicklauncher) do
			me.quicklauncher[k]=me:newlauncher(k)
		end
		--Modifying Atlasloot Recept Tooltips
		if AtlasLootTooltip then
			AtlasLootTooltip:HookScript("OnTooltipSetSpell", function(self, ...)
				me:modifytooltip(self,select(3,self:GetSpell()))
			end)
		end
		--save players faction and class
		me.save[my].faction = UnitFactionGroup("player")
		me.save[my].class = select(2,UnitClass("player"))
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
			-- Sizing of the original frame
			me.Trainer.OrigFrameSize = TradeSkillFrame:GetHeight()
			hooksecurefunc(TradeSkillFrame, "SetHeight", function(self, size)
				if not me.Trainer.size_changed then
					me.Trainer.OrigFrameSize=size
					me:Trainer_Refresh()
				end
				me.Trainer.size_changed=nil
			end)
		end
		me:ScanTradeSkillFrame()
		--Favorite Button-----------------------------------------------		
		if not me.FavoriteButton then --Call only once
			me.FavoriteButton=true
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
					me.save[my].lastprofession = me.FavoriteButtonProfID	-- Save last opened profession window
					local skillOffset = FauxScrollFrame_GetOffset(TradeSkillListScrollFrame)
					for i=1, TRADE_SKILLS_DISPLAYED do
						--Button Right Click Event
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
							end
						end)
						--
						local skillIndex = i + skillOffset;
						if TradeSkillFilterBar:IsShown() then skillIndex=skillIndex-1 end
						local skillName, skillType, numAvailable, isExpanded, altVerb, numSkillUps = GetTradeSkillInfo(skillIndex)
						_G["TradeSkillSkill"..i].BPM_RecipeID = nil
						if (skillType and skillType ~= "header") then
							local link = GetTradeSkillRecipeLink(skillIndex)
							if link then 
								local recipeid = tonumber(strmatch(link,"enchant:(%d+)"))
								_G["TradeSkillSkill"..i]:SetNormalTexture("Interface\\AddOns\\Broker_ProfessionsMenu\\icons\\fav.tga")
								if me.save[my].favorites[me.FavoriteButtonProfID] and me.save[my].favorites[me.FavoriteButtonProfID][recipeid] then
									_G["TradeSkillSkill"..i]:GetNormalTexture():SetAlpha(1.0)
								else
									_G["TradeSkillSkill"..i]:GetNormalTexture():SetAlpha(0.1)
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
-- Data broker                                                                --
--------------------------------------------------------------------------------

--<< Main data broker >>--------------------------------------------------------
function me:InitLDB()
	--Create Secure Frame Overlay
	me.secureframe = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate");
	me.secureframe.OnMouseUp = function(self,button)
		if InCombatLockdown() then return end
		self:SetAttribute("*type1", "spell")
		self:SetAttribute("*type2", "spell")
		self:SetAttribute("spell", "")
		local key = me.keys[me:KeyDownIndex(button)]
		if not key then return end
		local id = me.save[my].quicklaunch[key.Key]
		if (id==-1 and me.save[my].lastprofession>0) then
			self:SetAttribute("spell", GetSpellInfo(me.save[my].lastprofession))
		elseif (id=='menu') then
			GameTooltip:Hide()
			me.dropdown:Open(self, 'children', function(level, value) me.dropdown:ShowMenu(level, value, self) end)
		elseif (id=='fav') then
			GameTooltip:Hide()
			me.dropdown:Open(self, 'children', function() me.dropdown:ShowFavorites(self) end)
		elseif (id>0) then
			self:SetAttribute("spell", GetSpellInfo(id))
		end
	end
	--Create LDB
	me.dataobj = me.LDB:NewDataObject("Broker_ProfessionsMenu", {
		type = "data source",
		text = me.L["professions"],
		icon = "Interface\\Icons\\Trade_BlackSmithing",
		OnEnter = function(self)
			me:Broker_OnEnter(self,me.secureframe,function(self) me:tooltip(self) end)
		end,
	})
end

--<< Launchers >>---------------------------------------------------------------
function me:newlauncher(id)
	local spell,_,icon = GetSpellInfo(id)
	if (not spell) then return end
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
-- Secure action frame                                                        --
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
-- Functions                                                                  --
--------------------------------------------------------------------------------

--<< Filter tradewindows and tradeskills >>-------------------------------------
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
			for i=1, numSpells do
				if (not ignore[name] and not IsPassiveSpell(spelloffset+i, BOOKTYPE_PROFESSION)) then
					local subname,_ = GetSpellBookItemName(spelloffset+i, BOOKTYPE_PROFESSION)
					if not ignore[subname] then
						if sorted then
							if not result[name] then result[name]={} end
							result[name][subname] = GetSpellBookItemTexture(spelloffset+i, BOOKTYPE_PROFESSION)
						else
							result[subname] = GetSpellBookItemTexture(spelloffset+i, BOOKTYPE_PROFESSION)
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

--<< Table alphabetical sort function >>----------------------------------------
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

--<< Count of table elements >>-------------------------------------------------
function me:tcount(tab)
	local n = #tab
	if (n == 0) then
		for _ in pairs(tab) do
			n = n + 1
		end
	end
	return n
end

--<< GetSpellId >>--------------------------------------------------------------
function me:GetSpellID(spell)
	if not spell then return end
	local link,_ = GetSpellLink(spell)
	if not link then return end
	return tonumber(strmatch(link,"|Hspell:(%d+)|h"))
end

--<< TrainerFrame: Refresh function >-------------------------------------------
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
					if icon and name then
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
		end
		if me:tcount(table)==0 then
			tinsert(table,{["cols"] = {{["value"] = "",},{["value"] = me.L.knowallrecipes,},{["value"] = "",},},})
		end
		me.Trainer:SetData(table)
		--TradeSkillFrame:SetHeight(560)
		me.Trainer.size_changed=true
		TradeSkillFrame:SetHeight(me.Trainer.OrigFrameSize+me.Trainer.frame:GetHeight())
		me.Trainer.frame:Show()
	else
		--TradeSkillFrame:SetHeight(424)
		me.Trainer.size_changed=true
		TradeSkillFrame:SetHeight(me.Trainer.OrigFrameSize)
		me.Trainer.frame:Hide()
	end
end

--<< TradeSkillFrame: Scan for cooldowns end recepts >>-------------------------
function me:ScanTradeSkillFrame()
	if me.Trainer then me.Trainer.showbtn:Disable() end
	if not IsTradeSkillLinked() and GetTradeSkillListLink() then
		local profid, NoSpezi, _profid=me:TransProfID(tonumber(strmatch(GetTradeSkillListLink(),"|Htrade:%x+:(%d+)")))
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
					if (enchant) then me.save[my].craftableitems[profid] = me.save[my].craftableitems[profid].."|"..enchant..","..item.."|" end
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

--<< Translate profession id to the id of rank one (for save purpos) >>---------
me.profidtable={	--format {id of rank 1,id2,id3,id4,...,other ids[elixir master, etc.]}   ->   return "id of rank 1", "max skill"
	{2259,3101,3464,11611,28596,51304,80731,105206,28677,28675,28672}, 	--Alchemy
	{2575,2576,3564,10248,29354,50310,74517,2656},
	{4036,4037,4038,12656,30350,51306,82774,20219,20222},
	{45357,45358,45359,45360,45361,45363,86008,110417},						--Inscription
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
				if kk<9 then maxrank=kk*75 end	--Bei MotP gibt es 9 Ränke
				return v[1], maxrank, profid
			end
		end
	end
	return profid, nil, profid
end

--<< Quicktradeskill scan function >>-------------------------------------------
-- List of all aviable quick trade skills and their localized name (for scanning of the tooltip)
local skills = {
	[GetSpellInfo(13262)] = ITEM_DISENCHANT_ANY_SKILL,
	[GetSpellInfo(51005)] = ITEM_MILLABLE,
	[GetSpellInfo(31252)] = ITEM_PROSPECTABLE,
}
-- Scanfuntion
function me:scanBagForQuickTradeSkillItems(skillname, onlyAviableCheck)
	if (not (skillname and skills[skillname])) then return end
	if (onlyAviableCheck) then return true end
	local result={}
	for i=0, NUM_BAG_SLOTS do
		for j=1, GetContainerNumSlots(i) do
			if GetContainerItemID(i,j) then
				local texture, itemCount, _, quality, _ = GetContainerItemInfo(i, j)
				local itemName,_,_,_,itemMinLevel,itemType,itemSubType = GetItemInfo(GetContainerItemID(i,j))
				-- Check
				local add = false
				if (skills[skillname] == ITEM_DISENCHANT_ANY_SKILL) then --Disenchant
					if ((itemType==ENCHSLOT_WEAPON or itemType==ARMOR) and quality>1 and quality<5) then add = true end
				else -- Scan Tooltip
					me.scantip:SetBagItem(i,j)
					for i=1, me.scantip:NumLines() do
						if (_G["BPM_ScanTipTextLeft"..i] and _G["BPM_ScanTipTextLeft"..i]:GetText()==skills[skillname] and itemCount>=5) then
							add = true
							break
						end
					end
				end
				-- Create Entry
				if (add) then
					if (itemCount>1) then itemCount = " ("..itemCount..")" else itemCount="" end
					result[quality.."-"..itemName.."-"..i.."-"..j] = {
						name="|c"..select(4,GetItemQualityColor(quality))..itemName..itemCount.."|r",
						icon=texture,
						action={
							["type1"]="macro",
							["macrotext"]="/script if(GetCVar('AutoLootDefault')=='0') then BPMAutoloot=true end\n/cast "..skillname.."\n/use "..i.." "..j
						},
						tooltip=function()
							self = GameTooltip:GetOwner()
							GameTooltip:SetOwner(self, "ANCHOR_NONE")
							GameTooltip:SetPoint(me:GetTipAnchor2(self))
							GameTooltip:SetBagItem(i,j)
							GameTooltip:AddLine(" ")
							GameTooltip:AddLine(me.L["leftclick"]..": "..skillname..me.L["autoloot"],0,1,0)
						end,
					}
				end
			end
		end
	end
	return result
end
