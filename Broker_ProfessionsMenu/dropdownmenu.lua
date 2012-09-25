--------------------------------------------------------------------------------
-- Dropdownmenu                                                               --
--------------------------------------------------------------------------------
local _, me = ...                                 --Includes all functions and variables
local my = UnitName("player")--player name

--Include Libs
me.dropdown = LibStub('ArkDewdrop-3.0')			--Dropdownmenu



function me.dropdown:ShowMenu(level, value)
	local info = {}
	if not level then return end
	--<<LEVEL 1>>--
	if level == 1 then
		if me:tcount(me:GetProfs(true))>0 then
			for name,v in me:pairsByKeys(me:GetProfs(true)) do
				local title=true
				for subname,icon in pairs(v) do
					if me.save[my].filter[subname]~=true then
						if title then
							me.dropdown:AddTitle(name)
							title=nil
						end
						me.dropdown:AddSpell(subname, subname, icon, true)
					end
				end
			end
		end
		if me:tcount(me.quicktradeskills)>0 then
			local first=true
			for k,v in me:pairsByKeys(me.quicktradeskills) do
				if me:GetProfs()[v.name] then
					if first then me.dropdown:AddLine() end
					first=nil
					me.dropdown:AddArrow("|cffff0000"..v.name.."|r",k,v.icon)
				end
			end
		end
		me.dropdown:AddLine()                           --list other chars
		me.dropdown:AddArrow("|cff00ff00"..me.L["otherchar"].."|r","tradelinks")
		me.dropdown:AddLine()
		me.dropdown:AddArrow(me.L["settings"],"config")
	--<<LEVEL 2>>--
	elseif level == 2 then
		--Settingsmenu
		if value == "config" then
			me.dropdown:AddArrow(me.L["quicklaunch"],"quicklaunch")
			me.dropdown:AddArrow(me.L["quicklauncher"],"quicklauncher")
			me.dropdown:AddArrow(me.L["filter"],"filter")
			me.dropdown:AddArrow(me.L["tooltips"],"tooltip")
			--Disable trainer frame
			info.func = function(var)
				me.save[my].config.trainerdisabled = var
				me:Error(me.L["relog"])
			end
			me.dropdown:AddToggle(me.L["trainerdisabled"], me.save[my].config.trainerdisabled, info.func)
			me.dropdown:AddToggle(me.L["bothfactions"], me.save[my].config.bothfactions, function(var) me.save[my].config.bothfactions=var end)
			me.dropdown:AddToggle(me.L["exchangeleftright"], me.save[my].config.exchangeleftright, function(var) me.save[my].config.exchangeleftright=var end)
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
			me.dropdown:AddLine()
			me.dropdown:AddTitle(me.version)
		--list other chars
		elseif value == "tradelinks" then
			if me.save[my].config.bothfactions or UnitFactionGroup("player")=="Alliance" then
				local first=true
				for k,v in me:pairsByKeys(me.save) do
					if k~=my and v.faction=="Alliance" and v.tradelinks~=nil and me:tcount(v.tradelinks)>0  then
						if first and v.bothfactions then
							first=nil
							me.dropdown:AddTitle(FACTION_ALLIANCE)
						end
						me.dropdown:AddArrow(k,k)
					end
				end
			end
			if me.save[my].config.bothfactions or UnitFactionGroup("player")=="Horde" then
				local first=true
				for k,v in me:pairsByKeys(me.save) do
					if k~=my and v.faction=="Horde" and v.tradelinks~=nil and me:tcount(v.tradelinks)>0  then
						if first and v.bothfactions then
							first=nil
							me.dropdown:AddLine()
							me.dropdown:AddTitle(FACTION_HORDE)
						end
						me.dropdown:AddArrow(k,k)
					end
				end
			end
		--Special
		else
			if me.quicktradeskills[value] then
				local nomats=true
				for _,v in me:pairsByKeys(me.quicktradeskills[value]['func']()) do
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
			local button="leftclick"
			if me.save[my].config.exchangeleftright then button="rightclick" end
			me.dropdown:AddArrow(me.L[button],"left")
			me.dropdown:AddArrow(me.L["shift"].." + "..me.L[button],"shiftleft")
			me.dropdown:AddArrow(me.L["alt"].." + "..me.L[button],"altleft")
			me.dropdown:AddArrow(me.L["ctrl"].." + "..me.L[button],"ctrlleft")
		--quicklauncher
		elseif value == "quicklauncher" then
			me.dropdown:AddArrow(CREATE,"newlauncher")
			me.dropdown:AddArrow(DELETE,"deletelauncher")
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
		elseif value == "filter" then
			for k,_ in me:pairsByKeys(me:GetProfs()) do
				me.dropdown:AddToggle(k,me.save[my].filter[k],function(var) me.save[my].filter[k]=var end)
			end
		--list trades from an other char
		else
			for k,v in me:pairsByKeys(me.save[value].tradelinks) do
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
					local skill,maxskill = strmatch(v,"|Htrade:%d+:(%d+):(%d+):")
					local frame = GameTooltip:GetOwner()
					GameTooltip:SetOwner(frame, "ANCHOR_NONE")
					GameTooltip:SetPoint(me:GetTipAnchor2(frame))
					GameTooltip:ClearLines()
					GameTooltip:AddLine(value,0,1,0)
					GameTooltip:AddDoubleLine(GetSpellInfo(k),skill.."/"..maxskill,1,1,0,0,1,0)
					GameTooltip:AddLine(" ")
					GameTooltip:AddLine(me.L["leftclick"]..": |cffffffff"..me.L["linktome"].."|r")
					GameTooltip:AddLine(me.L["shift"].." + "..me.L["leftclick"]..": |cffffffff"..me.L["linktoother"].."|r")
				end
				me.dropdown:AddFunc(GetSpellInfo(k),info.func,_,_,info.tooltipFunc)
			end
			me.dropdown:AddLine()
			info.tooltipFunc = function()
				local frame = GameTooltip:GetOwner()
				GameTooltip:SetOwner(frame, "ANCHOR_NONE")
				GameTooltip:SetPoint(me:GetTipAnchor2(frame))
				GameTooltip:ClearLines()
				GameTooltip:AddLine(me.L["deletechartooltip"])
			end
			me.dropdown:AddFunc(DELETE,function() me.save[value]=nil end,_,true,info.tooltipFunc)
		end
	--<<LEVEL 4>>--
	elseif level == 4 then
		--New Launcher
		if value == "newlauncher" then
			for k,v in me:pairsByKeys(me:GetProfs()) do
				if not me.quicklauncher[me:GetSpellID(k)] then
					info.func = function()
						me.save[my].quicklauncher[me:GetSpellID(k)] = true
						me.quicklauncher[me:GetSpellID(k)]=me:newlauncher(k,v)
					end
					me.dropdown:AddFunc(k,info.func,v)
				end
			end
		--Delete Launcher
		elseif value == "deletelauncher" then
			for k,_ in me:pairsByKeys(me.save[my].quicklauncher) do
				me.dropdown:AddFunc(select(1,GetSpellInfo(k)),function() me.save[my].quicklauncher[k]=nil; me:Error(me.L["relog"]) end,select(3,GetSpellInfo(k)))
			end
		--Default Profession Menu
		else
			if (me.save[my].quicklaunch[value] == 0) then info.checked = true else info.checked = nil end
			info.func = function(var)
				me.save[my].quicklaunch[value] = 0
				if value=="left" then
					me:Professions_UpdateInfo(me:GetSpellInfo(0))
				end
			end
			me.dropdown:AddToggle("---", info.checked, info.func)
			me.dropdown:AddLine()
			for k,_ in me:pairsByKeys(me:GetProfs()) do
				info.func = function()
					me.save[my].quicklaunch[value] = me:GetSpellID(k)
					if value=="left" then
						me:Professions_UpdateInfo(me:GetSpellInfo(me.save[my].quicklaunch[value]))
					end
				end
				local spell,_ = GetSpellInfo(me.save[my].quicklaunch[value])
				if spell == GetSpellInfo(k) then info.checked = true else info.checked = nil end
				me.dropdown:AddToggle(k, info.checked, info.func)
			end
		end --else
	end
--<<END LEVEL>>--
end --function()



function me.dropdown:ShowFavorites()
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
						GameTooltip:AddDoubleLine(me.L["leftclick"],"|cffffffff"..CREATE.."|r")
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
					print(format(me.L.deletedfromfavorite,GetSpellLink(vv.id)))
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
							me.dropdown:Open(me.dropdown.parent, 'children', function() me.dropdown:ShowFavorites() end)--Reopen Dropdownmenu
							break
						end
					end
				end
			end
			me.dropdown:AddFunc(kk,func,vv.icon,_,vv.tooltip)
		end
	end
	if first then me.dropdown:AddTitle(me.L.nofavorites) end
end



--dropdown wrapper functions
--create a toggle (use func(var) to save you var)
function me.dropdown:AddToggle(name, var, func, tooltipfunc)
	local lfunc = function()
		var = not var
		if func then func(var) end
	end
	local checked = false
 	if var then checked=true end
 	if not tooltipfunc then tooltipfunc=function() return end end
	me.dropdown:AddLine('text',name,'func',lfunc,'checked',checked,'tooltipFunc',tooltipfunc)
end
--create a button
function me.dropdown:AddFunc(name, func, icon, closewhenclicked, tooltipfunc)
	if closewhenclicked==nil then closewhenclicked=false end
	if not tooltipfunc then tooltipfunc=function() return end end
	me.dropdown:AddLine('text',name,'icon',icon,'func',func,'tooltipFunc',tooltipfunc,'closeWhenClicked',closewhenclicked)
end
function me.dropdown:AddSpell(name, spell, icon, closewhenclicked, tooltipfunc)
	if closewhenclicked==nil then closewhenclicked=false end
	if not tooltipfunc then tooltipfunc=function() return end end
	me.dropdown:AddLine('text',name,'icon',icon,'secure',{type1='spell',spell=spell},'tooltipFunc',tooltipfunc,'closeWhenClicked',closewhenclicked)
end
--create a submenu
function me.dropdown:AddArrow(name,value,icon,tooltipfunc)
	if not tooltipfunc then tooltipfunc=function() return end end
	me.dropdown:AddLine('hasArrow',true,'text',name,'icon',icon,'value',value,'tooltipFunc',tooltipfunc)
end
--add title line
function me.dropdown:AddTitle(name, icon)
	me.dropdown:AddLine('isTitle',true,'text',name,'icon',icon)
end