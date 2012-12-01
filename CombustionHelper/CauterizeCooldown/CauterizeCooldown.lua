CauterizeCooldown = {}
CombuCaut_UpdateInterval = 1; -- How often the OnUpdate code will run (in seconds)

CombuCautLSM = LibStub("LibSharedMedia-3.0") 

local CombuCautClientVersion, CombuCautCD

function CombuCaut_OnLoad(Frame) 
                                               
    if select(2, UnitClass("player")) ~= "MAGE" then CombuCautFrame:Hide() return end
        
	Frame:RegisterForDrag("LeftButton")
 	Frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	Frame:RegisterEvent("PLAYER_ALIVE")
	Frame:RegisterEvent("PLAYER_LOGIN")
	Frame:RegisterEvent("PLAYER_TALENT_UPDATE")

 	CombuCautLSM.RegisterCallback(CauterizeCooldown , "LibSharedMedia_Registered", "SharedMedia_Registered") 
 	
	CombuCautLSM:Register("sound","Cauterize Fireball","Interface\\AddOns\\CauterizeCooldown\\Sound\\Cauterize_fireball.ogg")
	CombuCautLSM:Register("sound","Cauterize Sizzling","Interface\\AddOns\\CauterizeCooldown\\Sound\\Cauterize_sizzling.ogg")
	CombuCautLSM:Register("sound","Cauterize Torch","Interface\\AddOns\\CauterizeCooldown\\Sound\\Cauterize_torch.ogg")
    
    if (CombuCautenablevar == nil) then CombuCautenablevar = true end
    if (CombuCautscalevar == nil) then CombuCautscalevar = 1 end
    if (CombuCautlevelvar == nil) then CombuCautlevelvar = 10 end
    if (CombuCautalphavar == nil) then CombuCautalphavar = 1 end
    if (CombuCautlockvar == nil) then CombuCautlockvar = false end
    if (CombuCautTimevar == nil) then CombuCautTimevar = true end
    if (CombuCauthidevar == nil) then CombuCauthidevar = false end
    if (CombuCautChatRaidvar == nil) then CombuCautChatRaidvar = true end
    if (CombuCautChatSayvar == nil) then CombuCautChatSayvar = true end
    if (CombuCautChatYellvar == nil) then CombuCautChatYellvar = false end
    if (CombuCautChatAltvar == nil) then CombuCautChatAltvar = false end
    if (CombuCautChatAlonevar == nil) then CombuCautChatAlonevar = true end
    if (CombuCautEnableSoundvar == nil) then CombuCautEnableSoundvar = true end
    if (CombuCautSoundName == nil) then CombuCautSoundName = "Cauterize Torch" end
    if (CombuCautAnnouncevar == nil) then CombuCautAnnouncevar = "Cauterizing. Heal me up, please !!" end
    if (CombuCautAnnounceAltvar == nil) then CombuCautAnnounceAltvar = "Cauterizing but got Ice Block ready, don't worry." end

    CombuCautCD = 0
    CombuCautClientVersion = select(4,GetBuildInfo())
          
end

-------------------------------
--------------------------------
-- Helper function for Sharemedia support
function CauterizeCooldown:SharedMedia_Registered()
--	print("prut")
    -- do whatever needs to be done to repaint / refont
end

-- helper function for option panel setup
function CombuCautOptions_OnLoad(panel)
	panel.name = "Cauterize options"
	panel.parent = "CombustionHelper"
	InterfaceOptions_AddCategory(panel);
end

-------------------------------
-- lock function for option panel
function CombuCautlock()

	if CombuCautlockButton:GetChecked(true) then CombuCautlockvar = true 
                                 CombuCautFrame:EnableMouse(false)
                                 CombuCautlockButton:SetChecked(true)
	else CombuCautlockvar = false 
         CombuCautFrame:EnableMouse(true)
         CombuCautlockButton:SetChecked(false)
	end
end

-------------------------------
-- enable function for option panel
function CombuCautEnable()

	if CombuCautEnableButton:GetChecked(true) then 
		CombuCautenablevar = true 
        CombuCautEnableButton:SetChecked(true)
        CombuCautFrame:Show()
 		CombuCautFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		CombuCautFrame:RegisterEvent("PLAYER_TALENT_UPDATE")

	else CombuCautenablevar = false 
         CombuCautEnableButton:SetChecked(false)
         CombuCautFrame:Hide()
 		 CombuCautFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		 CombuCautFrame:UnregisterEvent("PLAYER_TALENT_UPDATE")
	end
end


-------------------------------
-- hide function for option panel
function CombuCautHide()

	if CombuCautHideButton:GetChecked(true) then CombuCauthidevar = true 
                                 CombuCautHideButton:SetChecked(true)
	else CombuCauthidevar = false 
         CombuCautHideButton:SetChecked(false)
        if CombuCautenablevar == true then
            CombuCautFrame:Show()
        end
	end
end

-------------------------------
-- Timer function for option panel
function CombuCautTimer()

	if CombuCautTimerButton:GetChecked(true) then CombuCautTimevar = true 
                                 CombuCautTimerButton:SetChecked(true)
	else CombuCautTimevar = false 
         CombuCautTimerButton:SetChecked(false)
	end
end


-------------------------------
-- Sound List function
function CombuCautCreateSoundList()

    CombuCautSoundList = {} for k in pairs(CombuCautLSM:HashTable("sound")) do tinsert(CombuCautSoundList,k) end
    
    CombuCautSoundBorderFrame:Show()
    CombuCautSoundBorderFrame:ClearAllPoints()
    CombuCautSoundFrame:SetHeight(#CombuCautSoundList*15)
    CombuCautSoundBorderFrame:SetPoint("CENTER",CombuCautSoundDropDown,"CENTER",0,0-(CombuCautSoundFrame:GetHeight()/4))
    CombuCautSoundBorderFrame:SetParent(CombuCautSoundDropDown)
    CombuCautSoundBorderFrame:SetFrameLevel(CombuCautSoundDropDownButton:GetFrameLevel()+1)
    CombuCautSoundBorderFrame:SetScale(1.3)
 
    for i = 1,#CombuCautSoundList do
    
        CreateFrame("button", "CombuCautSound"..i, CombuCautSoundFrame, "CombuCautSoundTemplate")
        _G["CombuCautSound"..i]:SetID(i)
        
        if i == 1 then
            CombuCautSound1:ClearAllPoints()
            CombuCautSound1:SetPoint("TOP",CombuCautSoundFrame,"TOP",0,0)
        else _G["CombuCautSound"..i]:ClearAllPoints()
             _G["CombuCautSound"..i]:SetPoint("TOP",_G["CombuCautSound"..i-1],"BOTTOM",0,0)
        end
        
        _G["CombuCautSound"..i.."Text"]:SetText(CombuCautSoundList[i])
        
        if CombuCautSoundList[i] == CombuCautSoundName then
            _G["CombuCautSound"..i.."Text"]:SetTextColor(1,0.8,0.2,1)
        else _G["CombuCautSound"..i.."Text"]:SetTextColor(1,1,1,1)
        end
    
    end
    
end

-------------------------------
-- party/raid chat function for option panel
function CombuCautChatRaid()

	if CombuCautAnnounceRaidButton:GetChecked(true) then CombuCautChatRaidvar = true 
                                 CombuCautAnnounceRaidButton:SetChecked(true)
	else CombuCautChatRaidvar = false 
         CombuCautAnnounceRaidButton:SetChecked(false)
	end
end

-------------------------------
-- vicinity chat function for option panel
function CombuCautChatSay()

	if CombuCautAnnounceSayButton:GetChecked(true) then CombuCautChatSayvar = true 
                                 CombuCautAnnounceSayButton:SetChecked(true)
	else CombuCautChatSayvar = false 
         CombuCautAnnounceSayButton:SetChecked(false)
	end
end

-------------------------------
-- yell chat function for option panel
function CombuCautChatYell()

	if CombuCautAnnounceYellButton:GetChecked(true) then CombuCautChatYellvar = true 
                                 CombuCautAnnounceYellButton:SetChecked(true)
	else CombuCautChatYellvar = false 
         CombuCautAnnounceYellButton:SetChecked(false)
	end
end

-------------------------------
-- Alt chat function for option panel
function CombuCautChatAlt()

	if CombuCautAnnounceAltButton:GetChecked(true) then CombuCautChatAltvar = true 
                                 CombuCautAnnounceAltButton:SetChecked(true)
	else CombuCautChatAltvar = false 
         CombuCautAnnounceAltButton:SetChecked(false)
	end
end

-------------------------------
-- Alone chat function for option panel
function CombuCautChatAlone()

	if CombuCautChatAloneButton:GetChecked(true) then CombuCautChatAlonevar = true 
                                 CombuCautChatAloneButton:SetChecked(true)
	else CombuCautChatAlonevar = false 
         CombuCautChatAloneButton:SetChecked(false)
	end
end

-------------------------------
-- Frame resize function
function CombuCautFrameResize()

    CombuCautFrame:SetScale(CombuCautscalevar)
    CombuCautFrame:SetAlpha(CombuCautalphavar)
    CombuCautFrame:SetFrameLevel(CombuCautlevelvar)
    CombuCautTimerText:SetFont("Fonts\\FRIZQT__.TTF", 25*CombuCautFrame:GetScale())
        
end

-------------------------------
-- Sound function for option panel
function CombuCautSound()

	if CombuCautSoundButton:GetChecked(true) then CombuCautEnableSoundvar = true 
                                 CombuCautSoundButton:SetChecked(true)
	else CombuCautEnableSoundvar = false 
         CombuCautSoundButton:SetChecked(false)
	end
end

-------------------------------
-- Reset savedvariables function
function CombuCautreset()

    CombuCautenablevar = true
    CombuCautlockvar = false
    CombuCautlockButton:SetChecked(false)
    CombuCautalphavar = 1
    CombuCautscalevar = 1 
    CombuCautlevelvar = 10
    CombuCauthidevar = false
    CombuCautTimevar = true
    CombuCautChatRaidvar = true
    CombuCautChatSayvar = true
    CombuCautChatYellvar = false
    CombuCautChatAlonevar = true
    CombuCautEnableSoundvar = true
    CombuCautSoundName = "Cauterize Torch"
    CombuCautAnnouncevar = "Cauterizing. Heal me up, please !!"
	CombuCautAnnounceAltvar = "Cauterizing but got Ice Block ready, don't worry."
	CombuCautChatAltvar = false
    CombuCautFrameResize()
    CombuCautFrame:ClearAllPoints() 
    CombuCautFrame:SetPoint("CENTER",UIParent,"CENTER",0,0)
    CombuCautFrame:Show()
    CombuCautlock()
    
end

-------------------------------------------------------------------------------------------------------	
-------------------------------------------------------------------------------------------------------	
-------------------------------- ON_EVENT FUNCTION ----------------------------------------------------

function CombuCaut_OnEvent(self, event, ...)
        
    if (event == "PLAYER_LOGIN") then
        
     	if CombuCautenablevar == true then
            CombuCautFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        else CombuCautFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        end
        
        CombuCautFrameResize()

        if (CombuCautlockvar == true) then 
            CombuCautFrame:EnableMouse(false)
        else CombuCautFrame:EnableMouse(true)
        end
        
        CreateFrame("Cooldown","CombuCautCooldown",CombuCautFrame)
		CombuCautCooldown:SetAllPoints(CombuCautFrame)
        CombuCautCooldown.noCooldownCount = true
        CombuCautTextFrame:SetFrameLevel(CombuCautCooldown:GetFrameLevel() + 1)
                   
    end
    
    if (event == "PLAYER_ALIVE") or (event == "PLAYER_TALENT_UPDATE") then
        
        if not CombuCautCooldown then
        
            CreateFrame("Cooldown","CombuCautCooldown",CombuCautFrame)
            CombuCautCooldown:SetAllPoints(CombuCautFrame)
            CombuCautCooldown.noCooldownCount = true
            CombuCautTextFrame:SetFrameLevel(CombuCautCooldown:GetFrameLevel() + 1)
            
        end 
        
        if CombuCautClientVersion >= 50001 then
    	
    		if CombuCautenablevar == true and UnitDebuff("player",select(1,GetSpellInfo(87024))) then
				CombuCautFrame:Show()
				CombuCautCooldown:SetCooldown(GetTime()- (120 - floor(select(7,UnitDebuff("player",select(1,GetSpellInfo(87024)))) - GetTime())), 120)
				CombuCautCD = 1
			else CombuCautFrame:Hide()
			end
			
    	else
    	
			if (GetPrimaryTalentTree() == 2) and select(5,GetTalentInfo(2,8)) ~= 0 and CombuCautenablevar == true then
				CombuCautFrame:Show()
			else CombuCautFrame:Hide()
			end
			
			if CombuCautCD > 0 then
				CombuCautCooldown:SetCooldown(GetTime() - (60 - CombuCautCD), 60)
			end
		end
        
     end
    
    if (event == "COMBAT_LOG_EVENT_UNFILTERED") then

    	local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical = select(1, ...)    
        
        if (sourceName == UnitName("player")) and (spellId == 87023) and (event == "SPELL_AURA_APPLIED") then -- CombuCauterize cooldown 
            CombuCautFrame:Show()
            
            if CombuCautClientVersion >= 50001 then
            	CombuCautCooldown:SetCooldown(GetTime()- (120 - floor(select(7,UnitDebuff("player",select(1,GetSpellInfo(87024)))) - GetTime())), 120)
            	CombuCautCD = 1
            else	CombuCautCooldown:SetCooldown(GetTime(),60)
            		CombuCautCD = 60

            end
            
            if CombuCautEnableSoundvar == true then
            	PlaySoundFile(CombuCautLSM:Fetch("sound",CautSoundName))
            end
            
            if CombuCautClientVersion >= 50001 then
                
                if CombuCautChatAlonevar == true and GetNumSubgroupMembers() == 0 then
                
                else 
                    
                    if CombuCautChatAltvar == true and select(2,GetSpellCooldown(45438)) == 0 then
                    
                        if CombuCautChatRaidvar == true then 
                            if IsInRaid() then 
                                SendChatMessage(CombuCautAnnounceAltvar, "RAID")
                            elseif GetNumSubgroupMembers() ~= 0 then 
                                SendChatMessage(CombuCautAnnounceAltvar, "PARTY")
                            end
                        end
                        if CombuCautChatSayvar == true then 
                            SendChatMessage(CombuCautAnnounceAltvar, "SAY")
                        end
                        if CombuCautChatYellvar == true then 
                            SendChatMessage(CombuCautAnnounceAltvar, "YELL")
                        end
                        
                    else
                    
                        if CombuCautChatRaidvar == true then 
                            if IsInRaid() then 
                                SendChatMessage(CombuCautAnnouncevar, "RAID")
                            elseif GetNumSubgroupMembers() ~= 0 then 
                                SendChatMessage(CombuCautAnnouncevar, "PARTY")
                            end
                        end
                        if CombuCautChatSayvar == true then 
                            SendChatMessage(CombuCautAnnouncevar, "SAY")
                        end
                        if CombuCautChatYellvar == true then 
                            SendChatMessage(CombuCautAnnouncevar, "YELL")
                        end
                        
                    end
                    
                end
                
            else
                
                if CombuCautChatAlonevar == true and GetNumPartyMembers() == 0 then
                    
                else 
                    
                    if CombuCautChatAltvar == true and select(2,GetSpellCooldown(45438)) == 0 then
                        
                        if CombuCautChatRaidvar == true then 
                            if GetNumRaidMembers() ~= 0 then 
                                SendChatMessage(CombuCautAnnounceAltvar, "RAID")
                            elseif GetNumPartyMembers() ~= 0 then 
                                SendChatMessage(CombuCautAnnounceAltvar, "PARTY")
                            end
                        end
                        if CombuCautChatSayvar == true then 
                            SendChatMessage(CombuCautAnnounceAltvar, "SAY")
                        end
                        if CombuCautChatYellvar == true then 
                            SendChatMessage(CombuCautAnnounceAltvar, "YELL")
                        end
                        
                    else
                    
                        if CombuCautChatRaidvar == true then 
                            if GetNumRaidMembers() ~= 0 then 
                                SendChatMessage(CombuCautAnnouncevar, "RAID")
                            elseif GetNumPartyMembers() ~= 0 then 
                                SendChatMessage(CombuCautAnnouncevar, "PARTY")
                            end
                        end
                        if CombuCautChatSayvar == true then 
                            SendChatMessage(CombuCautAnnouncevar, "SAY")
                        end
                        if CombuCautChatYellvar == true then 
                            SendChatMessage(CombuCautAnnouncevar, "YELL")
                        end
                        
                    end
                    
                end
                
            end
			
        end
	end
    
end

-------------------------------------------------------------------------------------------------------	
-------------------------------------------------------------------------------------------------------	
-------------------------------- ON_Update FUNCTION ----------------------------------------------------

function CombuCaut_OnUpdate(self, elapsed)
    self.CombuCautTimeSinceLastUpdate = (self.CombuCautTimeSinceLastUpdate or 0) + elapsed;
    
    if CombuCautClientVersion >= 50001 then
    
        if UnitDebuff("player",select(1,GetSpellInfo(87024))) then
        	
        	if CombuCautTimevar == true then
                CombuCautTimerText:SetText(format("|cffffff00%.0f|r",floor(select(7,UnitDebuff("player",select(1,GetSpellInfo(87024)))) - GetTime()))) 
    		else CombuCautTimerText:SetText("")
    		end
    	
    	else CombuCautCD = 0 
		
			CombuCautTimerText:SetText("")
			
			if CombuCauthidevar == true then
				CombuCautFrame:Hide()
			elseif CombuCautenablevar == true then
				CombuCautFrame:Show()
			end
    	end

	else
	
    	if CombuCautCD > 0 then
        
        	CombuCautCD = CombuCautCD - 1
        
			if CombuCautTimevar == true then
				CombuCautTimerText:SetText(format("|cffffff00%.0f|r",CombuCautCD)) 
			else CombuCautTimerText:SetText("")
			end
			
		else CombuCautCD = 0 
		
			CombuCautTimerText:SetText("")
			
			if CombuCauthidevar == true then
				CombuCautFrame:Hide()
			elseif CombuCautenablevar == true then
				CombuCautFrame:Show()
			end
		end
        
    end
    
    self.CombuCautTimeSinceLastUpdate = 0

end


--~ SLASH_CombuCautCONFIG1 = "/cauterize"

--~ SlashCmdList["CombuCautCONFIG"] = function(msg)

--~ 	if msg == "" or  msg == "help" or  msg == "?" or msg == "config" then
--~ 		 InterfaceOptionsFrame_OpenToCategory("Cauterize Options")
--~ 	else
--~ 		 InterfaceOptionsFrame_OpenToCategory("Cauterize Options")
--~ 	end

--~ end

