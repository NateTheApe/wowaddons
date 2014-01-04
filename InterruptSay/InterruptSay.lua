IIT_outputlist = "|c00bfffff emote [] say [] self [] party [] auto |r"
IIT_list = "|c00bfffffinfo [] toggle [] verbose [] allmembers []|r" ..IIT_outputlist
IIT_outputchannel = "|c00bfffffOutput is: |r"
IIT_allmembers = "|c00bfffffAnnounce interrupts from all party members: |r"
InterruptSayDB= {
	intsayonoff = 1,
	INTSAYOUTPUT = 'Say',
	Verbose = 1,
	msg = ("=> I Interrupted That: MobName's [SpellLink]."),
	Allmembersonoff = 0,
}


print("|c00bfffffI Interrupted That -- /iit for more.|r")

local InterruptSay = CreateFrame("Frame")

local function OnEvent(self, event, ...)
	local dispatch = self[event]

	if dispatch then
		dispatch(self, ...)
	end
end

InterruptSay:SetScript("OnEvent", OnEvent)
InterruptSay:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
InterruptSay:RegisterEvent("ADDON_LOADED")

function InterruptSay:ADDON_LOADED(...)
    if not InterruptSayDB.intsayonoff then
		InterruptSayDB.intsayonoff = 1
	end
    if not InterruptSayDB.INTSAYOUTPUT then
		InterruptSayDB.INTSAYOUTPUT = 'Auto'
	end
    if not InterruptSayDB.Verbose then
		InterruptSayDB.Verbose = 1
	end
    if not InterruptSayDB.msg then
		InterruptSayDB.msg = ("=> I Interrupted That: MobName's [SpellLink].")
	end
    if not InterruptSayDB.Allmembersonoff then
		InterruptSayDB.Allmembersonoff = 0
	end
    self:UnregisterEvent("ADDON_LOADED")
    
end

function IIT_verbtog()
	if InterruptSayDB.Verbose==1 then
		InterruptSayDB.Verbose=0
		print("|c00bfffffI Interrupted That - Verbose is off.|r")
	else
		InterruptSayDB.Verbose=1
		print("|c00bfffffI Interrupted That - Verbose is on.|r")
	end
end

function InterruptSay:COMBAT_LOG_EVENT_UNFILTERED(...)
	local inRealParty = GetNumGroupMembers(LE_PARTY_CATEGORY_HOME)>=1
	local inFakeParty = GetNumGroupMembers(LE_PARTY_CATEGORY_INSTANCE)>=1
	local iitinRaid = IsInRaid()
	local aEvent = select(2, ...)
	local aUser = select(5, ...)
	local destName = select(9, ...)
	local spellID = select(15, ...)
	local iitjustfake = "true"
	local iitrealnfake = "true"
	local iitjustreal = "true"
	local iitpartytype
	if InterruptSayDB.intsayonoff==1 then
		if aEvent=="SPELL_INTERRUPT" then
			local ssInInstance, ssinstanceType = IsInInstance();
			if InterruptSayDB.Allmembersonoff==0 and aUser~=UnitName("player") then return end 
			if inRealParty and inFakeParty then
				iitrealnfake = "true"
				iitpartytype = "Mixed"
			else
				iitrealnfake = "false"
			end
			if inRealParty and (not inFakeParty) then
				iitjustreal = "true"
				iitpartytype = "Real"
			else
				iitjustreal = "false"
			end
			if (not inRealParty) and inFakeParty then
				iitjustfake = "true"
				iitpartytype = "Fake"
			else
				iitjustfake = "false"
			end
			if iitjustreal or iitrealnfake then iitpartytype="PARTY" end
			if ssinstanceType == "pvp" then 
				iitinstancetype="BATTLEGROUND";
			else
				iitinstancetype="OTHER";
				if iitinRaid then iitpartytype="RAID" end
			end
			if (UnitInRaid("player")) then
				if not UnitInRaid(aUser) then return end
			else
				if aUser~=UnitName("player") then
				if not UnitInParty(aUser) then return end
				else
				end
			end
			if InterruptSayDB.Verbose~=1 then 
				if aUser~=UnitName("player") then
					intsaymsg = (aUser.." interrupted "..destName.. "'s " ..GetSpellLink(spellID).. ".")
					InterruptSayDB.msg = ("Interrupted MobName's [SpellLink].")
				else
					intsaymsg = ("I interrupted "..destName.. "'s " ..GetSpellLink(spellID).. ".")
					InterruptSayDB.msg = ("Interrupted MobName's [SpellLink].")
				end
			else
				if aUser~=UnitName("player") then
					intsaymsg = ("=> "..aUser.." Interrupted That: "..destName.. "'s " ..GetSpellLink(spellID).. ".")
					InterruptSayDB.msg = ("=> Someone Else Interrupted That: MobName's [SpellLink].")
				else
					intsaymsg = ("=> I Interrupted That: "..destName.. "'s " ..GetSpellLink(spellID).. ".")
					InterruptSayDB.msg = ("=> I Interrupted That: MobName's [SpellLink].")
				end
			end
			if InterruptSayDB.INTSAYOUTPUT=='Emote' then
				if aUser~=UnitName("player") then return end
				SendChatMessage("interrupted "..destName.."'s "..GetSpellLink(spellID)..".", "EMOTE")
			elseif InterruptSayDB.INTSAYOUTPUT=='Self' then
				print(intsaymsg)
			elseif InterruptSayDB.INTSAYOUTPUT=='Say' then
				if ssinstanceType == "pvp" then
					print(intsaymsg)
				else
					SendChatMessage(intsaymsg, "SAY")
				end
			elseif InterruptSayDB.INTSAYOUTPUT=='Auto' then
				if IsInGroup("player") then
					if ssinstanceType == "pvp" then
						SendChatMessage(intsaymsg, "INSTANCE_CHAT")
					else
						if IsInRaid() then
							SendChatMessage(intsaymsg, IsPartyLFG() and "INSTANCE_CHAT" or "RAID")
						else
							if iitjustfake or iitrealnfake then
								SendChatMessage(intsaymsg, IsPartyLFG() and "INSTANCE_CHAT" or "PARTY")
							else
								SendChatMessage(intsaymsg, "PARTY")
							end
						end
					end
				else
					print(intsaymsg)
				end
			elseif InterruptSayDB.INTSAYOUTPUT=='Party' then 
				if IsInGroup("player") then
					if iitjustfake=="true" then
						if ssinstanceType == "pvp" then
							SendChatMessage(intsaymsg, "INSTANCE_CHAT")
						else
							if IsInRaid() then
								SendChatMessage(intsaymsg, IsPartyLFG() and "INSTANCE_CHAT" or "RAID")
							else					
								SendChatMessage(intsaymsg, IsPartyLFG() and "INSTANCE_CHAT" or "PARTY")
							end
						end
					else
						SendChatMessage(intsaymsg, "PARTY")
					end
				else
					print(intsaymsg)
				end
			end
		end
	end
end



function IIT_toggleon()
	if InterruptSayDB.intsayonoff==1 then
		InterruptSayDB.intsayonoff=0
		print("|c00bfffffI Interrupted That is now off.|r")
	else
		InterruptSayDB.intsayonoff=1
		print("|c00bfffffI Interrupted That is now on.|r")
	end
end

function IIT_allmemberstog()
	if InterruptSayDB.Allmembersonoff==1 then
		InterruptSayDB.Allmembersonoff=0
		print("|c00bfffffI Interrupted That - All Members is off.|r")
	else
		InterruptSayDB.Allmembersonoff=1
		print("|c00bfffffI Interrupted That - All Members is on.|r")
	end
end

SLASH_IIT1="/iit"
SlashCmdList["IIT"] =
	function(msg)
		local a1 = gsub(msg, "%s*([^%s]+).*", "%1");
		local a2 = gsub(msg, "%s*([^%s]+)%s*(.*)", "%2");
	if (a1 == "") then print(IIT_list) end
	if (a1 == "info") or (a1 == "Info") or (a1 == "INFO") then print(IIT_list)
		if InterruptSayDB.intsayonoff~=1 then 
			print("|c00bfffffI Interrupted That is off.|r") 
		else 
			print(IIT_outputchannel, InterruptSayDB.INTSAYOUTPUT) 
			if InterruptSayDB.Allmembersonoff==1 then
				print(IIT_allmembers.." On")
			else
				print(IIT_allmembers.." Off")
			end
		end
		if InterruptSayDB.INTSAYOUTPUT~="Emote" then
			if InterruptSayDB.Verbose~=1 then
				print("|c00bfffffVerbose is: |rOFF")
			else print("|c00bfffffVerbose is: |rON")
			end 
		end
	end
	if (a1 == "toggle") then IIT_toggleon() end
    if (a1 == "Say") or (a1 == "say") or (a1 == "SAY") then
		InterruptSayDB.INTSAYOUTPUT = 'Say' print(IIT_outputchannel, InterruptSayDB.INTSAYOUTPUT)
    elseif (a1 == "Self") or (a1 == "self") or (a1 == "SELF") then 
		InterruptSayDB.INTSAYOUTPUT = 'Self' print(IIT_outputchannel, InterruptSayDB.INTSAYOUTPUT)
    elseif (a1 == "Auto") or (a1 == "auto") or (a1 == "AUTO") then 
		InterruptSayDB.INTSAYOUTPUT = 'Auto' print(IIT_outputchannel, InterruptSayDB.INTSAYOUTPUT) 
    elseif (a1 == "Party") or (a1 == "party") or (a1 == "PARTY") then 
		InterruptSayDB.INTSAYOUTPUT = 'Party' print(IIT_outputchannel, InterruptSayDB.INTSAYOUTPUT) 
    elseif (a1 == "Emote") or (a1 == "emote") or (a1 == "EMOTE") then 
		InterruptSayDB.INTSAYOUTPUT = 'Emote' 
		InterruptSayDB.msg = (UnitName("player").." interrupted MobName's [SpellLink]")
		print(IIT_outputchannel, InterruptSayDB.INTSAYOUTPUT) 
    end
	if (a1 == "verbose") then 
		if InterruptSayDB.INTSAYOUTPUT=='Emote' then 
			print("|c00bfffffEmote doesn't have a verbose output. Change to toggle. :)|r") 
		else 
			IIT_verbtog()
		end
	end
	if (a1 == "allmembers") or (a1 == "Allmembers") or (a1 == "ALLMEMBERS") then IIT_allmemberstog() end
	if (a1 == "msg") then 
		print("|c00bfffff"..InterruptSayDB.msg)
    end
end   



