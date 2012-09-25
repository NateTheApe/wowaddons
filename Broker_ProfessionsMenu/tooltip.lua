--------------------------------------------------------------------------------
-- Tooltip                                                                    --
--------------------------------------------------------------------------------
local _, me = ...                                 --Includes all functions and variables
local my = UnitName("player")--player name

--(All credit for this func goes to Tekkub and his picoGuild!)
function me:GetTipAnchor(frame)                   --although used with dropdownmenu
	local x, y = frame:GetCenter()
	if not x or not y then return 'TOPLEFT', 'BOTTOMLEFT' end
	local hhalf = (x > UIParent:GetWidth() * 2 / 3) and 'RIGHT' or (x < UIParent:GetWidth() / 3) and 'LEFT' or ''
	local vhalf = (y > UIParent:GetHeight() / 2) and 'TOP' or 'BOTTOM'
	return vhalf..hhalf, frame, (vhalf == 'TOP' and 'BOTTOM' or 'TOP')..hhalf
end
function me:GetTipAnchor2(frame)
	local x, y = frame:GetCenter()
	local hhalf = (x > UIParent:GetWidth() / 2) and 'RIGHT' or (x < UIParent:GetWidth() / 2) and 'LEFT' or ''
	local vhalf = (y > UIParent:GetHeight() / 2) and 'TOP' or 'BOTTOM'
	return vhalf..hhalf, frame, (vhalf == 'TOP' and 'BOTTOM' or 'TOP')..(hhalf == 'RIGHT' and 'LEFT' or 'Right')
end
--Main Tooltip
function me:tooltip(tooltip)
	tooltip:AddLine("Broker ProfessionsMenu")
	if (me:tcount({GetProfessions()})>0 and me.save[my].config.tooltip.showskills) then
		tooltip:AddLine(" ")
		tooltip:AddLine(me.L["professions"])
		for _,index in pairs({GetProfessions()}) do
			if index then
				local name, texture, rank, maxRank, numSpells, spelloffset, skillLine = GetProfessionInfo(index)
				tooltip:AddDoubleLine(name,rank.."/"..maxRank,1,1,1,0,1,0)
				tooltip:AddTexture(texture)
			end
		end
		--Pick Look
		local name,_,icon,_ = GetSpellInfo(1804)
		if GetSpellBookItemInfo(name) then
			tooltip:AddDoubleLine(name,UnitLevel("player")*5,1,1,1,0,1,0)
			tooltip:AddTexture(icon)
		end
	end
	--Cooldowns
	if (me.save[my].config.tooltip.showcds == true) then
		local jj = nil
		local duration = 0
		if me.save[my].config.bothfactions or UnitFactionGroup("player")=="Alliance" then
			jj = nil
			tooltip:AddLine(" ")
			tooltip:AddLine(me.L["cds"].." ("..FACTION_ALLIANCE..")")
			if UnitFactionGroup("player")=="Alliance" then
				for k,v in me:pairsByKeys(me.save[my].cds) do
					duration = difftime(v,time())
					if duration>0 then
						jj=true
						tooltip:AddDoubleLine("|cff00ff00"..k.."|r",SecondsToTime(duration),1,1,1,1,0,0)
					end
				end
			end
			for k,v in me:pairsByKeys(me.save) do
				if k~=my and v.faction=="Alliance" and v.cds~=nil then
					for kk,vv in me:pairsByKeys(v.cds) do
						duration = difftime(vv,time())
						if duration>0 then
							jj=true
							tooltip:AddDoubleLine("["..k.."] "..kk,SecondsToTime(duration),1,1,1,1,0,0)
						end
					end
				end
			end
			if not jj then
				tooltip:AddLine(me.L["nocds"],0,1,0)
			end
		end
		--
		if me.save[my].config.bothfactions or UnitFactionGroup("player")=="Horde" then
			jj = nil
			tooltip:AddLine(" ")
			tooltip:AddLine(me.L["cds"].." ("..FACTION_HORDE..")")
			if UnitFactionGroup("player")=="Horde" then
				for k,v in me:pairsByKeys(me.save[my].cds) do
					duration = difftime(v,time())
					if duration>0 then
						jj=true
						tooltip:AddDoubleLine("|cff00ff00"..k.."|r",SecondsToTime(duration),1,1,1,1,0,0)
					end
				end
			end
			for k,v in me:pairsByKeys(me.save) do
				if k~=UnitName("player") and v.faction=="Horde" and v.cds~=nil then
					for kk,vv in me:pairsByKeys(v.cds) do
						duration = difftime(vv,time())
						if duration>0 then
							jj=true
							tooltip:AddDoubleLine("["..k.."] "..kk,SecondsToTime(duration),1,1,1,1,0,0)
						end
					end
				end
			end
			if not jj then
				tooltip:AddLine(me.L["nocds"],0,1,0)
			end
		end
		--
	end
	--Infos
	if (me.save[my].config.tooltip.showbuttons == true) then
		tooltip:AddLine(" ")
		local button
		if me.save[my].config.exchangeleftright then button="rightclick" else button="leftclick" end
		if me.save[my].quicklaunch.left~=0 then
			tooltip:AddDoubleLine(me.L[button],"|cffffffff"..GetSpellInfo(me.save[my].quicklaunch.left).."|r")
		end
		if me.save[my].quicklaunch.shiftleft~=0 then
			tooltip:AddDoubleLine(me.L["shift"].." + "..me.L[button],"|cffffffff"..GetSpellInfo(me.save[my].quicklaunch.shiftleft).."|r")
		end
		if me.save[my].quicklaunch.ctrlleft~=0 then
			tooltip:AddDoubleLine(me.L["ctrl"].." + "..me.L[button],"|cffffffff"..GetSpellInfo(me.save[my].quicklaunch.ctrlleft).."|r")
		end
		if me.save[my].quicklaunch.altleft~=0 then
			tooltip:AddDoubleLine(me.L["alt"].." + "..me.L[button],"|cffffffff"..GetSpellInfo(me.save[my].quicklaunch.altleft).."|r")
		end
		if me.save[my].config.exchangeleftright then button="leftclick" else button="rightclick" end
		tooltip:AddDoubleLine(me.L[button],"|cffffffff"..me.L["openmenu"].."|r")
		tooltip:AddDoubleLine(me.L["shift"].." + "..me.L[button],"|cffffffff"..me.L["showfavorites"].."|r")
	end
end