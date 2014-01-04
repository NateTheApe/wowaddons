--------------------------------------------------------------------------------
-- Dropdownmenu                                                               --
--------------------------------------------------------------------------------
local _, me = ...                                 --Includes all functions and variables
local my = UnitName("player")--player name



function me.dropdown:ShowMenu(level, value, owner)
	local info = {}
	if not level then return end
	--<<LEVEL 1>>--
	if level == 1 then
		if me:tcount(me:GetProfs(true))>0 then
			for name,v in me:pairsByKeys(me:GetProfs(true)) do
				local title=true
				for subname,icon in pairs(v) do
					if title then
						local id = me:GetSpellID(name)
						local _icon = nil
						if (id) then _icon=select(3,GetSpellInfo(id)) end
						me.dropdown:AddSpell("|cffffd100"..name.."|r", name, _icon, true)
						title=nil
					end
					if (name~=subname) then me.dropdown:AddSpell("  |T"..icon..":16:16:0:0|t "..subname, subname, nil, true) end
					-- Quicktradeskills
					if (me:scanBagForQuickTradeSkillItems(subname, true)) then me.dropdown:AddArrow("  |T"..icon..":16:16:0:0|t |cffff0000"..subname.."|r",subname) end
				end
			end
		end
		me.dropdown:AddLine()                           --list other chars
		info.func = function() me.dropdown:Open(owner, 'children', function() me.dropdown:ShowFavorites(owner) end) end
		me.dropdown:AddFunc("|cffffd100"..me.L["favorites"].."|r",info.func,"Interface\\AddOns\\Broker_ProfessionsMenu\\icons\\fav.tga")
		me.dropdown:AddArrow("|cff00ff00"..me.L["otherchar"].."|r","tradelinks")  -- not supported anymore by patch 5.4
		
		-- me.dropdown:AddFunc("Test",function() me:OpenAltProfFrame("Sanori", 2259) end)
		
		me.dropdown:AddLine()
		me.dropdown:AddArrow(me.L["settings"],"config")
	--<<LEVEL 2>>--
	elseif level == 2 then
		--Settingsmenu
		if value == "config" then
			me.dropdown:AddTitle("Broker_ProfessionsMenu")
			me.dropdown:AddTitle("|cff707070"..me.version.."|r")
			me.dropdown:AddLine()
			me.dropdown:AddArrow(me.L["quicklaunch"],"quicklaunch")
			me.dropdown:AddArrow(me.L["quicklauncher"],"quicklauncher")
			me.dropdown:AddArrow(me.L["tooltips"],"tooltip")
			--Disable trainer frame
			info.func = function(var)
				me.save[my].config.trainerdisabled = var
				print("|cffffd100Broker_ProfessionsMenu:|r","|cffff0000"..me.L["relog"].."|r")
			end
			me.dropdown:AddToggle(me.L["trainerdisabled"], me.save[my].config.trainerdisabled, info.func)
			me.dropdown:AddToggle(me.L["bothfactions"], me.save[my].config.bothfactions, function(var) me.save[my].config.bothfactions=var end)
			me.dropdown:AddLine()
			--Reset CDs
			info.func = function()
				me.save[my].cds={}
				for k,v in pairs(me.save) do
					if v.faction==UnitFactionGroup("player") then
						me.save[k].cds={}
					end
 				end 
				me.secureframe:Hide()
				GameTooltip:Hide()
				me.dropdown:Close(1)
			end
			me.dropdown:AddFunc(me.L["resetcds"], info.func, "Interface\\Icons\\Ability_Rogue_FeignDeath", true)
		--list other chars -- not supported anymore by patch 5.4
		--[[elseif value == "tradelinks" then
			local first=true
			for k,v in me:pairsByKeys(me.save) do
				if (k and k~=UnitName("player") and v.tradelinks and me:tcount(v.tradelinks)>0 and (me.save[my].config.bothfactions or UnitFactionGroup("player")==v.faction)) then
					if (v.class) then
					 	local coords = CLASS_ICON_TCOORDS[v.class]
					 	me.dropdown:AddArrow(k,k,"Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",nil,nil,
							'iconCoordLeft', coords[1],
							'iconCoordRight', coords[2],
							'iconCoordTop', coords[3],
							'iconCoordBottom', coords[4])
					else
						me.dropdown:AddArrow(k,k)
					end
				end
			end]]
		elseif value == "tradelinks" then
			local first=true
			for k,v in me:pairsByKeys(me.save) do
				if (k and k~=UnitName("player") and v.craftableitems and me:tcount(v.craftableitems)>0 and (me.save[my].config.bothfactions or UnitFactionGroup("player")==v.faction)) then
					if (v.class) then
					 	local coords = CLASS_ICON_TCOORDS[v.class]
					 	me.dropdown:AddArrow(k,k,"Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",nil,nil,
							'iconCoordLeft', coords[1],
							'iconCoordRight', coords[2],
							'iconCoordTop', coords[3],
							'iconCoordBottom', coords[4])
					else
						me.dropdown:AddArrow(k,k)
					end
				end
			end
		-- Quicktradeskills
		else
			local quick = me:scanBagForQuickTradeSkillItems(value)
			if (quick) then
				local nomats=true
				for _,v in me:pairsByKeys(quick) do
					nomats=nil
					me.dropdown:AddLine('text',v.name,'icon',v.icon,'func',v.func,'secure',v.action,'tooltipFunc',function(self) v.tooltip(self) end)
				end
				if nomats then me.dropdown:AddTitle(me.L.nomats) end
			end
		end
	--<<LEVEL 3>>--
	elseif level == 3 then
		--default professions
		if value == "quicklaunch" then
			me.dropdown:AddArrow("|cffffd100"..me.L["leftclick"].."|r","left")
			me.dropdown:AddArrow("  + "..me.L["shift"],"shiftleft")
			me.dropdown:AddArrow("  + "..me.L["alt"],"altleft")
			me.dropdown:AddArrow("  + "..me.L["ctrl"],"ctrlleft")
			me.dropdown:AddArrow("|cffffd100"..me.L["rightclick"].."|r","right")
			me.dropdown:AddArrow("  + "..me.L["shift"],"shiftright")
			me.dropdown:AddArrow("  + "..me.L["alt"],"altright")
			me.dropdown:AddArrow("  + "..me.L["ctrl"],"ctrlright")
		--quicklauncher
		elseif value == "quicklauncher" then
			for name,icon in me:pairsByKeys(me:GetProfs()) do
				local id = me:GetSpellID(name)
				if (id) then
					local func = function(checked)
						if (checked) then
							me.save[my].quicklauncher[id] = true
							if (not me.quicklauncher[id]) then me.quicklauncher[id]=me:newlauncher(name,icon) end
						else
							me.save[my].quicklauncher[id]=nil
							print("|cffffd100Broker_ProfessionsMenu:|r","|cffff0000"..me.L["relog"].."|r")
						end
					end
					me.dropdown:AddToggle("|T"..icon..":16:16:0:0|t "..name, me.save[my].quicklauncher[id], func)
				end
			end
		--Tooltips
		elseif value == "tooltip" then
			--Craftable By in item tooltips
			me.dropdown:AddToggle(me.L["ShowIfYouCanCraftThisInItemTooltips"],me.save[my].config.tooltip.ShowIfYouCanCraftThisInItemTooltips,function(var) me.save[my].config.tooltip.ShowIfYouCanCraftThisInItemTooltips=var end)
			--ShowAllTooltips
			me.dropdown:AddToggle(me.L["ShowAllTooltips"],me.save[my].config.tooltip.ShowAllTooltips,function(var) me.save[my].config.tooltip.ShowAllTooltips=var end)
			me.dropdown:AddLine()
			--showskills
			me.dropdown:AddToggle(me.L["professions"],me.save[my].config.tooltip.showskills,function(var) me.save[my].config.tooltip.showskills=var end)
			--showcds
			me.dropdown:AddToggle(me.L["showcds"],me.save[my].config.tooltip.showcds,function(var) me.save[my].config.tooltip.showcds=var end)
			--showbuttons
			me.dropdown:AddToggle(me.L["showbuttons"],me.save[my].config.tooltip.showbuttons,function(var) me.save[my].config.tooltip.showbuttons=var end)
			--hide professions
		--list trades from an other char  -- not supported anymore by patch 5.4!
		--[[else
			for k,v in me:pairsByKeys(me.save[value].tradelinks) do
				local name, _, icon = GetSpellInfo(k)
				info.func = function()
					if IsShiftKeyDown() then
						if (not ChatEdit_InsertLink(v) ) then
							ChatFrame1EditBox:Show();
							ChatEdit_InsertLink(v);
						end
					else
						print("|cff00ff00Broker ProfessionsMenu: "..value..": |r"..v)
					end
				end
				info.tooltipFunc = function()
					local skill,maxskill = strmatch(v,"|Htrade:%x+:%d+:(%d+):(%d+):")
					if (skill == nil) then skill = "?" end
					if (maxskill == nil) then maxskill = "?" end
					local frame = GameTooltip:GetOwner()
					GameTooltip:SetOwner(frame, "ANCHOR_NONE")
					GameTooltip:SetPoint(me:GetTipAnchor2(frame))
					GameTooltip:ClearLines()
					GameTooltip:AddLine(value,0,1,0)
					GameTooltip:AddDoubleLine(name,skill.."/"..maxskill,1,1,0,0,1,0)
					GameTooltip:AddTexture(icon)
					GameTooltip:AddLine(" ")
					GameTooltip:AddLine(me.L["leftclick"]..": |cffffffff"..me.L["linktome"].."|r")
					GameTooltip:AddLine(me.L["shift"].." + "..me.L["leftclick"]..": |cffffffff"..me.L["linktoother"].."|r")
				end
				me.dropdown:AddFunc(name,info.func,icon,nil,info.tooltipFunc)
			end
			me.dropdown:AddLine()
			info.tooltipFunc = function()
				local frame = GameTooltip:GetOwner()
				GameTooltip:SetOwner(frame, "ANCHOR_NONE")
				GameTooltip:SetPoint(me:GetTipAnchor2(frame))
				GameTooltip:ClearLines()
				GameTooltip:AddLine(me.L["deletechartooltip"])
			end
			me.dropdown:AddFunc(DELETE,function() me.save[value]=nil end,nil,true,info.tooltipFunc)]]
		else
			for k,_ in me:pairsByKeys(me.save[value].craftableitems) do
				local name, _, icon = GetSpellInfo(k)
				me.dropdown:AddFunc(name,function() me:OpenAltProfFrame(value, k) end,icon)
			end
			me.dropdown:AddLine()
			info.tooltipFunc = function()
				local frame = GameTooltip:GetOwner()
				GameTooltip:SetOwner(frame, "ANCHOR_NONE")
				GameTooltip:SetPoint(me:GetTipAnchor2(frame))
				GameTooltip:ClearLines()
				GameTooltip:AddLine(me.L["deletechartooltip"])
			end
			me.dropdown:AddFunc(DELETE,function() me.save[value]=nil end,nil,true,info.tooltipFunc)
		end
	--<<LEVEL 4>>--
	elseif level == 4 then
		-- Check, if Menu is min. one time selected
		local disabled = true;
		for k,v in pairs(me.save[my].quicklaunch) do	-- Menu must be asigned min. one times
			if (v=="menu" and k~=value) then
				disabled=false
				break
			end
		end
		-- No Profession
		if (me.save[my].quicklaunch[value] == 0) then info.checked = true else info.checked = nil end
		info.func = function(var) me.save[my].quicklaunch[value] = 0 end
		me.dropdown:AddToggle("---", info.checked, info.func, nil, "disabled", disabled)
		me.dropdown:AddLine()
		-- Open Last Profession Window
		if (me.save[my].quicklaunch[value] == -1) then info.checked = true else info.checked = nil end
		info.func = function(var) me.save[my].quicklaunch[value] = -1 end
		me.dropdown:AddToggle(me.L['openLastProfessionWindow'], info.checked, info.func, nil, "disabled", disabled)
		-- Menu
		if (me.save[my].quicklaunch[value] == "menu") then info.checked = true else info.checked = nil end
		info.func = function(var) me.save[my].quicklaunch[value] = "menu" end
		me.dropdown:AddToggle(me.L["openmenu"], info.checked, info.func, nil, "disabled", disabled)
		-- Favorites
		if (me.save[my].quicklaunch[value] == "fav") then info.checked = true else info.checked = nil end
		info.func = function(var) me.save[my].quicklaunch[value] = "fav" end
		me.dropdown:AddToggle(me.L["showfavorites"], info.checked, info.func, nil, "disabled", disabled)
		-- Select Profession
		me.dropdown:AddLine()
		for k,icon in me:pairsByKeys(me:GetProfs()) do
			info.func = function() me.save[my].quicklaunch[value] = me:GetSpellID(k) end
			local spell = GetSpellInfo(me.save[my].quicklaunch[value])
			if spell == GetSpellInfo(k) then info.checked = true else info.checked = nil end
			me.dropdown:AddToggle("|T"..icon..":18:18:0:0|t "..k, info.checked, info.func, nil, "disabled", disabled)
		end
	end
--<<END LEVEL>>--
end --function()



function me.dropdown:ShowFavorites(owner)
	local first=true
	for profid,v in pairs(me.save[my].favorites) do
		local prof,_ = GetSpellInfo(profid)
		if not first then me.dropdown:AddLine() end
		first=nil
		me.dropdown:AddTitle(prof)
		local table = {}
		for recipeid,type in pairs(v) do
			local name,_,icon =GetSpellInfo(recipeid)
			table[name] = {
				id = recipeid,
				icon = icon,
				type = type,
				tooltip=function()
					local frame = GameTooltip:GetOwner()
					GameTooltip:SetOwner(frame, "ANCHOR_NONE")
					GameTooltip:SetPoint(me:GetTipAnchor2(frame))
					GameTooltip:ClearLines()
					GameTooltip:SetHyperlink("|cffffffff|Henchant:"..tostring(recipeid).."|h["..name.."]|h|r")
					GameTooltip:AddLine(' ')
					--Cooldowns
					local duration=me.save[my].cds[name]
					if me.P.SharedCDs[recipeid] then
						duration=me.save[my].cds[me.P.SharedCDs[recipeid]]
					end
					if duration then
						duration = difftime(duration,time())
						if duration > 0 then
							GameTooltip:AddDoubleLine(COOLDOWN_REMAINING,SecondsToTime(duration),1,0,0,1,0,0)
							GameTooltip:AddLine(' ')
						end
					end
					if type=="Create" then
						GameTooltip:AddDoubleLine(me.L["leftclick"],"|cffffffff"..CREATE_PROFESSION.."|r")
						GameTooltip:AddDoubleLine(me.L["shift"].." + "..me.L["leftclick"],"|cffffffff"..CREATE_ALL.."|r")
					else
						GameTooltip:AddDoubleLine(me.L["leftclick"],"|cffffffff"..type.."|r")
					end
					GameTooltip:AddDoubleLine(me.L["alt"].." + "..me.L["leftclick"],"|cffffffff"..DELETE.."|r")
				end,
			}
		end
		for kk,vv in me:pairsByKeys(table) do
			local func = function()
				if IsAltKeyDown() then --Delete Favorite
					local data = me.save[my].favorites[profid]
					data[vv.id] = nil
					if me:tcount(data) == 0 then
						data = nil
					end
					me.save[my].favorites[profid] = data
					if TradeSkillFrame:IsVisible() then
						TradeSkillFrame_Update()
					end
				else --Craft Item
					CloseTradeSkill()
					CastSpellByName(prof)
					for i=1, GetNumTradeSkills() do
						local skillname,skilltype,numAvailable,isExpanded,_ = GetTradeSkillInfo(i)
						if skilltype=='header' and not isExpanded then
							ExpandTradeSkillSubClass(i)
						elseif skillname==kk then
							local num = 1
							if IsShiftKeyDown() and vv.type=="Create" then
								num = numAvailable
							end
							TradeSkillFrame_SetSelection(i)
							TradeSkillFrame_Update()
							TradeSkillInputBox:SetNumber(num)
							DoTradeSkill(i, num)
							TradeSkillInputBox:ClearFocus()
							me.dropdown:Open(owner, 'children', function() me.dropdown:ShowFavorites(owner) end)--Reopen Dropdownmenu
							break
						end
					end
				end
			end
			me.dropdown:AddFunc(kk,func,vv.icon,nil,vv.tooltip)
		end
	end
	if first then me.dropdown:AddTitle(me.L.nofavorites) end
end



--dropdown wrapper functions
--create a toggle (use func(var) to save you var)
function me.dropdown:AddToggle(name, var, func, tooltipfunc, ...)
	local lfunc = function()
		var = not var
		if func then func(var) end
	end
	local checked = false
 	if var then checked=true end
 	if not tooltipfunc then tooltipfunc=function() return end end
	me.dropdown:AddLine('text',name,'func',lfunc,'checked',checked,'tooltipFunc',tooltipfunc,...)
end
--create a button
function me.dropdown:AddFunc(name, func, icon, closewhenclicked, tooltipfunc, ...)
	if closewhenclicked==nil then closewhenclicked=false end
	if not tooltipfunc then tooltipfunc=function() return end end
	me.dropdown:AddLine('text',name,'icon',icon,'func',func,'tooltipFunc',tooltipfunc,'closeWhenClicked',closewhenclicked,...)
end
function me.dropdown:AddSpell(name, spell, icon, closewhenclicked, tooltipfunc, ...)
	if closewhenclicked==nil then closewhenclicked=false end
	if not tooltipfunc then tooltipfunc=function() return end end
	me.dropdown:AddLine('text',name,'icon',icon,'secure',{type1='spell',spell=spell},'tooltipFunc',tooltipfunc,'closeWhenClicked',closewhenclicked,...)
end
--create a submenu
function me.dropdown:AddArrow(name, value, icon, tooltipfunc, func, ...)
	if not tooltipfunc then tooltipfunc=function() return end end
	me.dropdown:AddLine('hasArrow',true,'text',name,'icon',icon,'value',value,'tooltipFunc',tooltipfunc,...)
end
--add title line
function me.dropdown:AddTitle(name, icon, ...)
	me.dropdown:AddLine('isTitle',true,'text',name,'icon',icon,...)
end