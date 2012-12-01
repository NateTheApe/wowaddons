MageBombTracker = {} 

CombuMBTrackerLSM = LibStub("LibSharedMedia-3.0") 

CombuMBTracker_UpdateInterval = 0.1; -- How often the OnUpdate code will run (in seconds)

local CombuMBTlvb, CombuMBTlvbID, combumbtlbraidcheck, combumbtlbtablerefresh
local combumbtlbrefresh, combumbtlbraidcheck, combumbtlbtablerefresh, combumbtlbgroupsuffix, combumbtlbtargetsuffix, combumbtlbgroupnumber, combumbtrackerenableheight, combumbtrackerenableclean
local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical 
local combupotentialrefresh, comburefreshdone, comburefreshGUID, comburefreshname


function CombuMBTracker_OnLoad() 
                                               
    if select(2, UnitClass("player")) ~= "MAGE" then CombuMBTrackerVarReset() CombuMBTrackerFrame:Hide() return end
        
	CombuMBTrackerFrame:RegisterForDrag("LeftButton")
	CombuMBTrackerFrame:RegisterEvent("PLAYER_LOGIN")
	CombuMBTrackerFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	CombuMBTrackerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
 	CombuMBTrackerFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
 	CombuMBTrackerFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
 
 	CombuMBTrackerLSM.RegisterCallback(MageBombTracker , "LibSharedMedia_Registered", "SharedMedia_Registered") 

	CombuMBTrackerLSM:Register("background","Blizzard Tooltip","Interface\\Tooltips\\UI-Tooltip-Background")
	CombuMBTrackerLSM:Register("border","Blizzard Tooltip","Interface\\Tooltips\\UI-Tooltip-Border")
	CombuMBTrackerLSM:Register("border","ElvUI Border","Interface\\AddOns\\MageBombTracker\\Images\\ElvUIBorder")
	CombuMBTrackerLSM:Register("statusbar","CombuBar","Interface\\AddOns\\MageBombTracker\\Images\\combubarblack")
        
    CombuMBTrackerLanguageCheck()
	CombuMBTrackerTableCopy()
	CombuMBTrackerVarReset()
    CombuMBTrackerBombChecker()
    
end

CombuMBTrackertable = {}
                            
combumbtrackerdefaultsettingstable = {["combumbtrackerlock"] = false,
							["combumbtrackerautohide"] = 1,
							["combumbtrackerscale"] = 1,
							["combumbtrackerrefreshmode"] = true,
							["combumbtrackerchat"] = true,
							["combumbtrackerenable"] = true,
							["combumbtrackertarget"] = true,
							["combumbtrackerflamestrike"] = true,
							["combumbtrackertexturename"] = "CombuBar",
							["combumbtrackerfontname"] = "Friz Quadrata TT",
							["barcolornormal"] = {0,0.5,0.8,1},
							["barcolorwarning"] = {1,0,0,1},
							["textcolornormal"] = {1,1,1,1},
							["textcolorwarning"] = {1,0,0,1},
							["bgcolornormal"] = {0.25,0.25,0.25,1},
							["edgecolornormal"] = {0.67,0.67,0.67,1},
							["bgFile"] = "Blizzard Tooltip",
                        	["tileSize"] = 16,
                        	["edgeFile"] = "Blizzard Tooltip",
                        	["tile"] = true,
                        	["edgeSize"] = 16,
                        	["insets"] = 5,
                            ["language"] = "Default",
							["combumbtrackertimervalue"] = 2,
                            ["direction"] = "downward",
}

function CombuMBTrackerLanguageCheck()

    if combumbtrackersettingstable then 
    
        if combumbtrackersettingstable["language"] == "Francais" or combumbtrackersettingstable["language"] == "Default" and GetLocale() == "frFR" then

            CombuMBTrackerLoc = CombuMBTrackerLocFR
            combumbtrackeroptioninfotable = combumbtrackeroptioninfotableFR
            CombuMBTrackerOptLoc = CombuMBTrackerOptLocFR
            CombuMBTrackerLBposition = CombuMBTrackerLBpositionFR
            CombuMBTrackerAutohideList = CombuMBTrackerAutohideListFR
            CombuMBTrackerLabel = CombuMBTrackerLabelFR
                
--~         elseif combumbtrackersettingstable["language"] == "Deutsch" or combumbtrackersettingstable["language"] == "Default" and GetLocale() == "deDE" then
--~             
--~             CombuMBTrackerLoc = CombuMBTrackerLocDE
--~             combumbtrackeroptioninfotable = combumbtrackeroptioninfotableDE
--~             CombuMBTrackerOptLoc = CombuMBTrackerOptLocDE
--~             CombuMBTrackerLBposition = CombuMBTrackerLBpositionDE
--~             CombuMBTrackerAutohideList = CombuMBTrackerAutohideListDE
--~             CombuMBTrackerLabel = CombuMBTrackerLabelDE
--~             
--~         elseif combumbtrackersettingstable["language"] == "Chinese" or combumbtrackersettingstable["language"] == "Default" and GetLocale() == "zhTW" then
--~             
--~             CombuMBTrackerLoc = CombuMBTrackerLocTW
--~             combumbtrackeroptioninfotable = combumbtrackeroptioninfotableTW
--~             CombuMBTrackerOptLoc = CombuMBTrackerOptLocTW
--~             CombuMBTrackerLBposition = CombuMBTrackerLBpositionTW
--~             CombuMBTrackerAutohideList = CombuMBTrackerAutohideListTW
--~             CombuMBTrackerLabel = CombuMBTrackerLabelTW

        else CombuMBTrackerLoc = CombuMBTrackerLocEN
            combumbtrackeroptioninfotable = combumbtrackeroptioninfotableEN
            CombuMBTrackerOptLoc = CombuMBTrackerOptLocEN
            CombuMBTrackerLBposition = CombuMBTrackerLBpositionEN
            CombuMBTrackerAutohideList = CombuMBTrackerAutohideListEN
            CombuMBTrackerLabel = CombuMBTrackerLabelEN

        end
        
    else CombuMBTrackerLoc = CombuMBTrackerLocEN
        combumbtrackeroptioninfotable = combumbtrackeroptioninfotableEN
        CombuMBTrackerOptLoc = CombuMBTrackerOptLocEN
        CombuMBTrackerLBposition = CombuMBTrackerLBpositionEN
        CombuMBTrackerAutohideList = CombuMBTrackerAutohideListEN
        CombuMBTrackerLabel = CombuMBTrackerLabelEN
        
   end

end

function CombuMBTrackerTableCopy()

	combumbtrackersettingstable = {}
	
	for k,v in pairs(combumbtrackerdefaultsettingstable) do 
		if type(v) == "table" then
			combumbtrackersettingstable[k] = {}
			for i = 1,#v do
				table.insert(combumbtrackersettingstable[k],v[i])
			end
		else combumbtrackersettingstable[k] = v 
		end
	end
    
end

----------------------------------
-- Helper function to reset some variables
function CombuMBTrackerVarReset()

   	combumbtlbrefresh = 0
    combumbtrackerenableclean = false
    combumbtrackerenablemax = 0
    combumbtrackerenableheight = 0
    combupotentialrefresh = 0
    comburefreshdone = 0
    
end

--------------------------------
-- Helper function for Sharemedia support
function MageBombTracker:SharedMedia_Registered()
--	print("prut")
    -- do whatever needs to be done to repaint / refont
end

-------------------------------
-- helper function for option panel setup
function MageBombTrackerOptions_OnLoad(panel)
    CombuMBTrackerLanguageCheck()
	panel.name = "MageBombTracker"
	panel.parent = "CombustionHelper"
	InterfaceOptions_AddCategory(panel);
end

-------------------------------
-- lock function for option panel
function CombuMBTrackerlock()

	if CombuMBTrackerlockButton:GetChecked(true) then combumbtrackersettingstable["combumbtrackerlock"] = true 
                                 CombuMBTrackerFrame:EnableMouse(false)
                                 CombuMBTrackerlockButton:SetChecked(true)
                                 if (combumbtrackersettingstable["combumbtrackerchat"]==true) then ChatFrame1:AddMessage(CombuMBTrackerLoc["lockon"]) end
	else combumbtrackersettingstable["combumbtrackerlock"] = false 
         CombuMBTrackerFrame:EnableMouse(true)
         CombuMBTrackerlockButton:SetChecked(false)
         if (combumbtrackersettingstable["combumbtrackerchat"]==true) then ChatFrame1:AddMessage(CombuMBTrackerLoc["lockoff"]) end
	end
end

-------------------------------
-- chat function for option panel
function CombuMBTrackerchat()

	if CombuMBTrackerchatButton:GetChecked(true) then combumbtrackersettingstable["combumbtrackerchat"] = true 
                                 CombuMBTrackerchatButton:SetChecked(true)
                                 ChatFrame1:AddMessage(CombuMBTrackerLoc["reporton"])
	else combumbtrackersettingstable["combumbtrackerchat"] = false 
         CombuMBTrackerchatButton:SetChecked(false)
	end
end

-------------------------------
-- Bombs refresh function for option panel
function CombuMBTrackerrefresh()

	if CombuMBTrackerrefreshButton:GetChecked(true) then combumbtrackersettingstable["combumbtrackerrefreshmode"] = true 
                                                CombuMBTrackerrefreshButton:SetChecked(true)
                                                if (combumbtrackersettingstable["combumbtrackerchat"]==true) then ChatFrame1:AddMessage(CombuMBTrackerLoc["lbon"]) end
	else combumbtrackersettingstable["combumbtrackerrefreshmode"] = false 
         CombuMBTrackerrefreshButton:SetChecked(false)
         if (combumbtrackersettingstable["combumbtrackerchat"]==true) then ChatFrame1:AddMessage(CombuMBTrackerLoc["lboff"]) end
	end
end

-------------------------------
-- Scale function for option panel
function CombuMBTrackerScale (scale)

	CombuMBTrackerFrame:SetScale(scale)
	combumbtrackersettingstable["combumbtrackerscale"] = scale
end

-------------------------------
-- Flamestrike mode function for option panel
function CombuMBTrackerFlamestrike()

	if CombuMBTrackerFlamestrikeButton:GetChecked(true) then combumbtrackersettingstable["combumbtrackerflamestrike"] = true 
                                                 	CombuMBTrackerFlamestrikeButton:SetChecked(true)
                                             		if (combumbtrackersettingstable["combumbtrackerchat"]==true) then ChatFrame1:AddMessage(CombuMBTrackerLoc["fson"]) end
	else combumbtrackersettingstable["combumbtrackerflamestrike"] = false 
         CombuMBTrackerFlamestrikeButton:SetChecked(false)
         if (combumbtrackersettingstable["combumbtrackerchat"]==true) then ChatFrame1:AddMessage(CombuMBTrackerLoc["fsoff"]) end
	end
end

-------------------------------
-- living bomb tracker target mode function for option panel
function CombuMBTrackertarget()

	if CombuMBTrackertargetButton:GetChecked(true) then combumbtrackersettingstable["combumbtrackertarget"] = true 
                                                 CombuMBTrackertargetButton:SetChecked(true)
	else combumbtrackersettingstable["combumbtrackertarget"] = false 
         CombuMBTrackertargetButton:SetChecked(false)
	end
end

-------------------------------
-- Multiple Living Bomb tracker function for option panel
function CombuMBTracker()

	if CombuMBTrackerButton:GetChecked(true) then combumbtrackersettingstable["combumbtrackerenable"] = true 
                                             CombuMBTrackerButton:SetChecked(true)
                                             CombuMBTrackerFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
                                             CombuMBTrackerFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
                                             if (combumbtrackersettingstable["combumbtrackerchat"]==true) then ChatFrame1:AddMessage(CombuMBTrackerLoc["lbtrackon"]) end
	else combumbtrackersettingstable["combumbtrackerenable"] = false 
         CombuMBTrackerButton:SetChecked(false)
         table.wipe(CombuMBTrackertable)
         CombuMBTrackerFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
         CombuMBTrackerFrame:UnregisterEvent("PLAYER_TALENT_UPDATE")
         if (combumbtrackersettingstable["combumbtrackerchat"]==true) then ChatFrame1:AddMessage(CombuMBTrackerLoc["lbtrackoff"]) end
	end
    
    CombuMBTrackerFrameresize()
    
end

function CombuMBTrackerBackdropBuild ()

	if not CombuMBTrackerBackdrop then
	
		CombuMBTrackerBackdrop = {bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
                        tileSize=16,
                        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
                        tile=true,
                        edgeSize=16,
                        insets={
                          top=5,
                          right=5,
                          left=5,
                          bottom=5}}
    end

    if combumbtrackersettingstable then
        CombuMBTrackerBackdrop["bgFile"] = CombuMBTrackerLSM:Fetch("background",combumbtrackersettingstable["bgFile"])
        CombuMBTrackerBackdrop["tileSize"] = combumbtrackersettingstable["tileSize"]
        CombuMBTrackerBackdrop["edgeFile"] = CombuMBTrackerLSM:Fetch("border",combumbtrackersettingstable["edgeFile"])
        CombuMBTrackerBackdrop["tile"] = combumbtrackersettingstable["tile"]
        CombuMBTrackerBackdrop["edgeSize"] = combumbtrackersettingstable["edgeSize"];
        (CombuMBTrackerBackdrop["insets"])["top"] = combumbtrackersettingstable["insets"];
        (CombuMBTrackerBackdrop["insets"])["right"] = combumbtrackersettingstable["insets"];
        (CombuMBTrackerBackdrop["insets"])["left"] = combumbtrackersettingstable["insets"];
        (CombuMBTrackerBackdrop["insets"])["bottom"] = combumbtrackersettingstable["insets"]
    end
    
    CombuMBTrackerBorderFrame:SetBackdrop(CombuMBTrackerBackdrop)
    CombuMBTrackerBorderFrame:SetBackdropColor(unpack(combumbtrackersettingstable["bgcolornormal"]))
    CombuMBTrackerBorderFrame:SetBackdropBorderColor(unpack(combumbtrackersettingstable["edgecolornormal"]))

end
			
-------------------------------
-- Helper function for frame resizing
function CombuMBTrackerFrameresize()
	
	if combumbtrackersettingstable["combumbtrackerenable"] == true and select(2, UnitClass("player")) == "MAGE" then
		 CombuMBTrackerFrame:Show() --print("show")
	else CombuMBTrackerFrame:Hide() --print("hide")
	end

	if combumbtrackerenablemax and combumbtrackerenablemax > 0 then 
		
		for i = 1,combumbtrackerenablemax do 

			if _G["CombuMBTrack"..i] then
				
				_G["CombuMBTrack"..i.."InfoText"]:SetWidth(CombuMBTrackerFrame:GetWidth()-41)
				_G["CombuMBTrack"..i.."InfoText"]:SetFont(CombuMBTrackerLSM:Fetch("font",combumbtrackersettingstable["combumbtrackerfontname"]), select(2,_G["CombuMBTrack"..i.."InfoText"]:GetFont()))
				_G["CombuMBTrack"..i.."InfoTimer"]:SetFont(CombuMBTrackerLSM:Fetch("font",combumbtrackersettingstable["combumbtrackerfontname"]), select(2,_G["CombuMBTrack"..i.."InfoTimer"]:GetFont()))
				_G["CombuMBTrack"..i.."Bar"]:SetWidth(CombuMBTrackerFrame:GetWidth()-12)
				_G["CombuMBTrack"..i.."Bar"]:SetMinMaxValues(0,100)
				_G["CombuMBTrack"..i.."Bar"]:SetStatusBarTexture(CombuMBTrackerLSM:Fetch("statusbar",combumbtrackersettingstable["combumbtrackertexturename"]))
                
    		end
    	end 
    end

	CombuMBTrackerBackdropBuild ()
    CombuMBTrackerFrame:SetFrameLevel(CombuMBTrackerBorderFrame:GetFrameLevel())
    CombuMBTrackerBorderFrame:SetFrameLevel(CombuMBTrackerFrame:GetFrameLevel())
    
    CombuMBTrackerAutohide()
    
    if CombustionFrame then CombustionFrameresize() end

end

function CombuMBTrackerreset ()

	CombuMBTrackerFrame:ClearAllPoints()
	CombuMBTrackerFrame:SetPoint("CENTER", UIParent, "CENTER" ,0,0)
	CombuMBTrackerFrame:SetScale(1)
	
	CombuMBTrackerTableCopy()
	
	ChatFrame1:AddMessage(CombuMBTrackerLoc["reset"])
	CombuMBTrackerFrameresize()
	CombuMBTrackerlock ()
	combusettingstable["MageBombTrackerPosition"] = "free"
	
end
	
function CombuMBTrackerColorPicker(r, g, b, a)

    --print(r, g, b, a)
    --print(combumbtrackercolorinstance,unpack(combumbtrackersettingstable[combumbtrackercolorinstance]))

    ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = (a ~= nil), a;
    ColorPickerFrame.previousValues = {r,g,b,a};
    ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = CombuMBTrackerColorCallback, CombuMBTrackerColorCallback, CombuMBTrackerColorCallback;
    ColorPickerFrame:SetColorRGB(r,g,b);
    ColorPickerFrame:Hide(); -- Need to run the OnShow handler.
    ColorPickerFrame:Show();
    
end

function CombuMBTrackerColorCallback(restore)

	local newR, newG, newB, newA;
	
	if restore then
		newR, newG, newB, newA = unpack(restore);
	else newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
	end
	 
	(combumbtrackersettingstable[combumbtrackercolorinstance])[1], (combumbtrackersettingstable[combumbtrackercolorinstance])[2], (combumbtrackersettingstable[combumbtrackercolorinstance])[3], (combumbtrackersettingstable[combumbtrackercolorinstance])[4] = newR, newG, newB, newA;
	_G["CombuMBTracker"..combumbtrackercolorinstance.."SwatchTexture"]:SetVertexColor(unpack(combumbtrackersettingstable[combumbtrackercolorinstance]))
    
    CombuMBTrackerFrameresize()

end

function CombuMBTrackerCreateTextureList(dropdown, settings)

    combumbtrackertexturesettings = settings
    combumbtrackertexturedropdown = dropdown
    
    CombuMBTrackerTextureList = {} for k in pairs(CombuMBTrackerLSM:HashTable("statusbar")) do tinsert(CombuMBTrackerTextureList,k) end
    
    CombuMBTrackerTextureBorderFrame:Show()
    CombuMBTrackerTextureBorderFrame:ClearAllPoints()
    CombuMBTrackerTextureFrame:SetHeight(#CombuMBTrackerTextureList*20)
    CombuMBTrackerTextureBorderFrame:SetPoint("CENTER",dropdown,"CENTER",0,0-(CombuMBTrackerTextureFrame:GetHeight()/4))
    CombuMBTrackerTextureBorderFrame:SetParent(dropdown)
    CombuMBTrackerTextureBorderFrame:SetFrameLevel(_G[dropdown:GetName().."Button"]:GetFrameLevel()+1)
    CombuMBTrackerTextureBorderFrame:SetScale(1.3)
    
    for i = 1,#CombuMBTrackerTextureList do
    
        CreateFrame("button", "CombuMBTrackerTexture"..i, CombuMBTrackerTextureFrame, "CombuMBTrackerTextureTemplate")
        
        if i == 1 then
            CombuMBTrackerTexture1:ClearAllPoints()
            CombuMBTrackerTexture1:SetPoint("TOP",CombuMBTrackerTextureFrame,"TOP",0,0)
        else _G["CombuMBTrackerTexture"..i]:ClearAllPoints()
             _G["CombuMBTrackerTexture"..i]:SetPoint("TOP",_G["CombuMBTrackerTexture"..i-1],"BOTTOM",0,0)
        end
        
        _G["CombuMBTrackerTexture"..i.."Bar"]:SetTexture(CombuMBTrackerLSM:Fetch("statusbar",CombuMBTrackerTextureList[i]))
        _G["CombuMBTrackerTexture"..i.."Bar"]:SetVertexColor(unpack(combumbtrackersettingstable["barcolornormal"]))
        _G["CombuMBTrackerTexture"..i.."Text"]:SetText(CombuMBTrackerTextureList[i])
        
        if (CombuMBTrackerTextureList[i]) == combumbtrackersettingstable[settings] then
            _G["CombuMBTrackerTexture"..i.."Text"]:SetTextColor(1,0.8,0.2,1)
        else _G["CombuMBTrackerTexture"..i.."Text"]:SetTextColor(1,1,1,1)
        end
    
    end
    
end
            
function CombuMBTrackerCreateFontList()

    CombuMBTrackerFontList = {} for k in pairs(CombuMBTrackerLSM:HashTable("font")) do tinsert(CombuMBTrackerFontList,k) end
    
    CombuMBTrackerFontBorderFrame:Show()
    CombuMBTrackerFontBorderFrame:ClearAllPoints()
    CombuMBTrackerFontFrame:SetHeight(#CombuMBTrackerFontList*15)
    CombuMBTrackerFontBorderFrame:SetPoint("CENTER",CombuMBTrackerFontDropDown,"CENTER",0,0-(CombuMBTrackerFontFrame:GetHeight()/4))
    CombuMBTrackerFontBorderFrame:SetParent(CombuMBTrackerFontDropDown)
    CombuMBTrackerFontBorderFrame:SetFrameLevel(CombuMBTrackerFontDropDownButton:GetFrameLevel()+1)
    CombuMBTrackerFontBorderFrame:SetScale(1.3)
 
    for i = 1,#CombuMBTrackerFontList do
    
        CreateFrame("button", "CombuMBTrackerFont"..i, CombuMBTrackerFontFrame, "CombuMBTrackerFontTemplate")
        
        if i == 1 then
            CombuMBTrackerFont1:ClearAllPoints()
            CombuMBTrackerFont1:SetPoint("TOP",CombuMBTrackerFontFrame,"TOP",0,0)
        else _G["CombuMBTrackerFont"..i]:ClearAllPoints()
             _G["CombuMBTrackerFont"..i]:SetPoint("TOP",_G["CombuMBTrackerFont"..i-1],"BOTTOM",0,0)
        end
        
        _G["CombuMBTrackerFont"..i.."Bar"]:SetTexture(CombuMBTrackerLSM:Fetch("statusbar",combumbtrackersettingstable["combumbtrackertexturename"]))
        _G["CombuMBTrackerFont"..i.."Bar"]:SetVertexColor(unpack(combumbtrackersettingstable["barcolornormal"]))
        _G["CombuMBTrackerFont"..i.."Text"]:SetText(CombuMBTrackerFontList[i])
        _G["CombuMBTrackerFont"..i.."Text"]:SetFont(CombuMBTrackerLSM:Fetch("font",CombuMBTrackerFontList[i]),9)
        
        if CombuMBTrackerFontList[i] == combumbtrackersettingstable["combumbtrackerfontname"] then
            _G["CombuMBTrackerFont"..i.."Text"]:SetTextColor(1,0.8,0.2,1)
        else _G["CombuMBTrackerFont"..i.."Text"]:SetTextColor(1,1,1,1)
        end
    
    end
    
end

function CombuMBTrackerCreateSoundList()

    CombuMBTrackerSoundList = {} for k in pairs(CombuMBTrackerLSM:HashTable("sound")) do tinsert(CombuMBTrackerSoundList,k) end
    
    CombuMBTrackerSoundBorderFrame:Show()
    CombuMBTrackerSoundBorderFrame:ClearAllPoints()
    CombuMBTrackerSoundFrame:SetHeight(#CombuMBTrackerSoundList*15)
    CombuMBTrackerSoundBorderFrame:SetPoint("CENTER",CombuMBTrackerSoundDropDown,"CENTER",0,0-(CombuMBTrackerSoundFrame:GetHeight()/4))
    CombuMBTrackerSoundBorderFrame:SetParent(CombuMBTrackerSoundDropDown)
    CombuMBTrackerSoundBorderFrame:SetFrameLevel(CombuMBTrackerSoundDropDownButton:GetFrameLevel()+1)
    CombuMBTrackerSoundBorderFrame:SetScale(1.3)
 
    for i = 1,#CombuMBTrackerSoundList do
    
        CreateFrame("button", "CombuMBTrackerSound"..i, CombuMBTrackerSoundFrame, "CombuMBTrackerSoundTemplate")
        _G["CombuMBTrackerSound"..i]:SetID(i)
        
        if i == 1 then
            CombuMBTrackerSound1:ClearAllPoints()
            CombuMBTrackerSound1:SetPoint("TOP",CombuMBTrackerSoundFrame,"TOP",0,0)
        else _G["CombuMBTrackerSound"..i]:ClearAllPoints()
             _G["CombuMBTrackerSound"..i]:SetPoint("TOP",_G["CombuMBTrackerSound"..i-1],"BOTTOM",0,0)
        end
        
        _G["CombuMBTrackerSound"..i.."Text"]:SetText(CombuMBTrackerSoundList[i])
        
        if CombuMBTrackerSoundList[i] == combumbtrackersettingstable["combumbtrackersoundname"] then
            _G["CombuMBTrackerSound"..i.."Text"]:SetTextColor(1,0.8,0.2,1)
        else _G["CombuMBTrackerSound"..i.."Text"]:SetTextColor(1,1,1,1)
        end
    
    end
    
end

function CombuMBTrackerCreateBorderList()

    CombuMBTrackerBorderList = {} for k in pairs(CombuMBTrackerLSM:HashTable("border")) do tinsert(CombuMBTrackerBorderList,k) end
       
    CombuMBTrackerEdgeBorderFrame:Show()
    CombuMBTrackerEdgeBorderFrame:ClearAllPoints()
    CombuMBTrackerEdgeFrame:SetHeight(#CombuMBTrackerBorderList*32)
    CombuMBTrackerEdgeBorderFrame:SetPoint("CENTER",CombuMBTrackerBorderDropDown,"CENTER",0,0-(CombuMBTrackerEdgeFrame:GetHeight()/4))
    CombuMBTrackerEdgeBorderFrame:SetParent(CombuMBTrackerBorderDropDown)
    CombuMBTrackerEdgeBorderFrame:SetFrameLevel(CombuMBTrackerBorderDropDownButton:GetFrameLevel()+1)
    CombuMBTrackerEdgeBorderFrame:SetScale(1.3)
    
    for i = 1,#CombuMBTrackerBorderList do
    
        CreateFrame("button", "CombuMBTrackerBorder"..i, CombuMBTrackerEdgeFrame, "CombuMBTrackerEdgeTemplate")
        
        if i == 1 then
            CombuMBTrackerBorder1:ClearAllPoints()
            CombuMBTrackerBorder1:SetPoint("TOP",CombuMBTrackerEdgeFrame,"TOP",0,0)
        else _G["CombuMBTrackerBorder"..i]:ClearAllPoints()
             _G["CombuMBTrackerBorder"..i]:SetPoint("TOP",_G["CombuMBTrackerBorder"..i-1],"BOTTOM",0,0)
        end
        
        _G["CombuMBTrackerBorder"..i.."Bar"]:SetTexture(CombuMBTrackerLSM:Fetch("border",CombuMBTrackerBorderList[i]))
        _G["CombuMBTrackerBorder"..i.."Bar"]:SetVertexColor(unpack(combumbtrackersettingstable["edgecolornormal"]))
        _G["CombuMBTrackerBorder"..i.."Text"]:SetText(CombuMBTrackerBorderList[i])
        
        if CombuMBTrackerBorderList[i] == combumbtrackerBorder then
            _G["CombuMBTrackerBorder"..i.."Text"]:SetTextColor(1,0.8,0.2,1)
        else _G["CombuMBTrackerBorder"..i.."Text"]:SetTextColor(1,1,1,1)
        end
    
    end
    
end

function CombuMBTrackerCreateBackgroundList()

    CombuMBTrackerBackgroundList = {} for k in pairs(CombuMBTrackerLSM:HashTable("background")) do tinsert(CombuMBTrackerBackgroundList,k) end
     
    CombuMBTrackerBgBorderFrame:Show()
    CombuMBTrackerBgBorderFrame:ClearAllPoints()
    CombuMBTrackerBgFrame:SetHeight(#CombuMBTrackerBackgroundList*30)
    CombuMBTrackerBgBorderFrame:SetPoint("CENTER",CombuMBTrackerBackgroundDropDown,"CENTER",0,0-(CombuMBTrackerBgFrame:GetHeight()/4))
    CombuMBTrackerBgBorderFrame:SetParent(CombuMBTrackerBackgroundDropDown)
    CombuMBTrackerBgBorderFrame:SetFrameLevel(CombuMBTrackerBackgroundDropDownButton:GetFrameLevel()+1)
    CombuMBTrackerBgBorderFrame:SetScale(1.3)
    
    for i = 1,#CombuMBTrackerBackgroundList do
    
        CreateFrame("button", "CombuMBTrackerBackground"..i, CombuMBTrackerBgFrame, "CombuMBTrackerBgTemplate")
        
        if i == 1 then
            CombuMBTrackerBackground1:ClearAllPoints()
            CombuMBTrackerBackground1:SetPoint("TOP",CombuMBTrackerBgFrame,"TOP",0,0)
        else _G["CombuMBTrackerBackground"..i]:ClearAllPoints()
             _G["CombuMBTrackerBackground"..i]:SetPoint("TOP",_G["CombuMBTrackerBackground"..i-1],"BOTTOM",0,0)
        end
        
        _G["CombuMBTrackerBackground"..i.."Bar"]:SetTexture(CombuMBTrackerLSM:Fetch("background",CombuMBTrackerBackgroundList[i]))
        _G["CombuMBTrackerBackground"..i.."Text"]:SetText(CombuMBTrackerBackgroundList[i])
        
        if CombuMBTrackerBackgroundList[i] == combumbtrackerBackground then
            _G["CombuMBTrackerBackground"..i.."Text"]:SetTextColor(1,0.8,0.2,1)
        else _G["CombuMBTrackerBackground"..i.."Text"]:SetTextColor(1,1,1,1)
        end
    
    end
    
end

function CombuMBTrackerCreateBombRow (row,create)

    if row and not _G["CombuMBTrack"..row] then
        CreateFrame("frame", "CombuMBTrack"..row, CombuMBTrackerFrame, "CombuMBTrackTemplate")
        _G["CombuMBTrack"..row.."Bar"]:SetMinMaxValues(0,100)
        CombuMBTrackerFrameresize()
    end
	
    if not create then 
    
        for i = 1, combumbtrackerenablemax do
        
            if _G["CombuMBTrack"..i] then
            
                if combumbtrackersettingstable["direction"] == "downward" then --print("down")
            
                    if i == 1 then
                        CombuMBTrack1:ClearAllPoints()
                        CombuMBTrack1:SetPoint("TOP",CombuMBTrackerFrame,"TOP",0,-6)
                    else _G["CombuMBTrack"..i]:ClearAllPoints()
                        _G["CombuMBTrack"..i]:SetPoint("TOP",_G["CombuMBTrack"..i-1],"BOTTOM",0,0)
                    end
                    
                    CombuMBTrackerBorderFrame:ClearAllPoints()
                    CombuMBTrackerBorderFrame:SetPoint("TOP",CombuMBTrackerFrame,"TOP",0,0)
                    
                elseif combumbtrackersettingstable["direction"] == "upward" then --print("up")
            
                    if i == 1 then
                        CombuMBTrack1:ClearAllPoints()
                        CombuMBTrack1:SetPoint("BOTTOM",CombuMBTrackerFrame,"BOTTOM",0,6)
                    else _G["CombuMBTrack"..i]:ClearAllPoints()
                        _G["CombuMBTrack"..i]:SetPoint("BOTTOM",_G["CombuMBTrack"..i-1],"TOP",0,0)
                    end
            
                    CombuMBTrackerBorderFrame:ClearAllPoints()
                    CombuMBTrackerBorderFrame:SetPoint("BOTTOM",CombuMBTrackerFrame,"BOTTOM",0,0)
                    
                end
            
            else CombuMBTrackerCreateBombRow (i,1)
            end
        end
	
	end
	    
end

-------------------------------
--function for bomb type 
function CombuMBTrackerBombChecker ()
		
	if select(2,GetTalentRowSelectionInfo(5)) == 13 then -- nether tempest selected
		
		CombuMBTlvb = GetSpellInfo(114923)
		CombuMBTlvbID = 114923
		
	elseif select(2,GetTalentRowSelectionInfo(5)) == 14 then -- living bomb
		
		CombuMBTlvb = GetSpellInfo(44457)
		CombuMBTlvbID = 44457
		
	elseif select(2,GetTalentRowSelectionInfo(5)) == 15 then -- frost bomb
		
		CombuMBTlvb = GetSpellInfo(112948)
		CombuMBTlvbID = 112948
	
	else CombuMBTlvb = GetSpellInfo(44457)
		 CombuMBTlvbID = 44457
	
	end

    --print(CombuMBTlvb,CombuMBTlvbID)
end

-------------------------------
--Helper function for living bomb tracking expiration time collecting
local function CombuMBTrackerLBauratracker(targetguid, targetname, eventgettime)

	combumbtlbraidcheck = 0
	combumbtlbtablerefresh = 0
    combumbtlbgroupsuffix = nil
    combumbtlbtargetsuffix = nil
    
    if select(4,GetBuildInfo()) >= 50001 then 
    	
    	if GetNumSubgroupMembers() > 5 then
    	    combumbtlbgroupsuffix = "raid"
        	combumbtlbgroupnumber = GetNumSubgroupMembers()
    	elseif GetNumSubgroupMembers() > 0 then
        	combumbtlbgroupsuffix = "party"
            combumbtlbgroupnumber = GetNumSubgroupMembers()
    	end
    	
    else
    	
		if (GetNumRaidMembers() ~= 0) 
			then combumbtlbgroupsuffix = "raid"
				 combumbtlbgroupnumber = GetNumRaidMembers()
		elseif (GetNumPartyMembers() ~= 0)
			then combumbtlbgroupsuffix = "party"
				 combumbtlbgroupnumber = GetNumPartyMembers()
		end
	end
    
    if (UnitGUID("target") == targetguid)
        then combumbtlbtargetsuffix = "target"
    elseif (UnitGUID("mouseover") == targetguid)
        then combumbtlbtargetsuffix = "mouseover"
    elseif (UnitGUID("focus") == targetguid)
        then combumbtlbtargetsuffix = "focus"
    end
    
    if CombuMBTlvbID == 112948 then
    
        table.insert(CombuMBTrackertable, {targetguid, targetname, select(1,GetSpellCooldown(CombuMBTlvb)) + select(2,GetSpellCooldown(CombuMBTlvb)), select(2,GetSpellCooldown(CombuMBTlvb)), GetRaidTargetIndex(combumbtlbtargetsuffix)})
        
    else
    
        if combumbtrackerimpacttimer and ((combumbtrackerimpacttimer + 1) >= GetTime())
            then local a12,b12,c12,d12,e12,f12,g12,h12,i12,j12,k12 = UnitAura("target", CombuMBTlvb, nil, "PLAYER HARMFUL") --print(1)------------
                 for z = 1, #CombuMBTrackertable do
                 
                    if ((CombuMBTrackertable[z])[1] == targetguid) 
                        then (CombuMBTrackertable[z])[3] = g12;
                             (CombuMBTrackertable[z])[4] = f12;
                             (CombuMBTrackertable[z])[5] = nil
                             combumbtlbtablerefresh = 1
                             break
                    end 
                 end
                 
                 if (combumbtlbtablerefresh == 1) then
                 else table.insert(CombuMBTrackertable, {targetguid, targetname, g12, f12})
                 end
                 
                 combumbtlbraidcheck = 1
            
        elseif combumbtlbtargetsuffix and (UnitGUID(combumbtlbtargetsuffix) == targetguid)
            then local a12,b12,c12,d12,e12,f12,g12,h12,i12,j12,k12 = UnitAura(combumbtlbtargetsuffix, CombuMBTlvb, nil, "PLAYER HARMFUL") --print(2)------------
                 for z = 1, #CombuMBTrackertable do
                 
                    if ((CombuMBTrackertable[z])[1] == targetguid) 
                        then (CombuMBTrackertable[z])[3] = g12;
                             (CombuMBTrackertable[z])[4] = f12;
                             (CombuMBTrackertable[z])[5] = GetRaidTargetIndex(combumbtlbtargetsuffix)
                             combumbtlbtablerefresh = 1
                             break
                    end 
                 end
                 
                 if (combumbtlbtablerefresh == 1) then
                 else table.insert(CombuMBTrackertable, {targetguid, targetname, g12, f12, GetRaidTargetIndex(combumbtlbtargetsuffix)})
                 end
                 
                 combumbtlbraidcheck = 1
            
        elseif combumbtlbgroupsuffix then --print(3)------------
            for i = 1, combumbtlbgroupnumber do -- first we check if a raid or party members target the bomb's target to have an accurate expiration time with UnitAura
                
                if (UnitGUID(combumbtlbgroupsuffix..i.."-target") == targetguid) 
                    then local a12,b12,c12,d12,e12,f12,g12,h12,i12,j12,k12 = UnitAura(combumbtlbgroupsuffix..i.."-target", CombuMBTlvb, nil, "PLAYER HARMFUL")
                         
                         for z = 1, #CombuMBTrackertable do
                         
                            if ((CombuMBTrackertable[z])[1] == targetguid) 
                                then (CombuMBTrackertable[z])[3] = g12;
                                     (CombuMBTrackertable[z])[4] = f12;
                                     (CombuMBTrackertable[z])[5] = GetRaidTargetIndex(combumbtlbgroupsuffix..i.."-target")
                                     combumbtlbtablerefresh = 1
                                     break
                            end 
                         end
                         
                         if (combumbtlbtablerefresh == 1) then
                         else table.insert(CombuMBTrackertable, {targetguid, targetname, g12, f12, GetRaidTargetIndex(combumbtlbgroupsuffix..i.."-target")})
                         end
                         
                         combumbtlbraidcheck = 1
                    
                end
            end
        end
        
        if (combumbtlbraidcheck == 0) -- info with UnitAura have been collected, skipping this part.
            then for z = 1, #CombuMBTrackertable do -- no raid members targetting the bomb target so using GetTime from event fired and 12 secs as duration
                     
                    if ((CombuMBTrackertable[z])[1] == targetguid) 
                        then if CombuMBTlvbID == 112948 then
                                (CombuMBTrackertable[z])[3] = select(1,GetSpellCooldown(CombuMBTlvb)) + select(2,GetSpellCooldown(CombuMBTlvb))
                             else (CombuMBTrackertable[z])[3] = (eventgettime + 12)
                             end

                             if CombuMBTlvbID == 112948 then
                                (CombuMBTrackertable[z])[4] = select(2,GetSpellCooldown(CombuMBTlvb))
                             else (CombuMBTrackertable[z])[4] = 12;
                             end
                             (CombuMBTrackertable[z])[5] = nil
                             combumbtlbtablerefresh = 1
                             break
                    end 
                 end
                         
                 if (combumbtlbtablerefresh == 1) then
                 else table.insert(CombuMBTrackertable, {targetguid, targetname, (eventgettime + 12), 12, nil})
                 end
        end
        
        for i = #CombuMBTrackertable,1,-1 do
            if CombuMBTrackertable[i] and (((CombuMBTrackertable[i])[1] == 2120) or ((CombuMBTrackertable[i])[1] == 88148)) then 
                table.insert(CombuMBTrackertable,{(CombuMBTrackertable[i])[1],(CombuMBTrackertable[i])[2],(CombuMBTrackertable[i])[3],(CombuMBTrackertable[i])[4]});
                table.remove(CombuMBTrackertable,i);
            end
        end
    end
end

local function CombuMBTrackerUpdate()
    
    if #CombuMBTrackertable == 0 and combumbtrackerenablemax == 0 then --print(1)

        combumbtrackerenablemax = 1
        CombuMBTrackerCreateBombRow (1)
        
    elseif #CombuMBTrackertable == 0 and combumbtrackerenableclean == false and combumbtrackerenablemax ~= 0 then  --print(2)

	    for i = 1,combumbtrackerenablemax do 
            
           	if not _G["CombuMBTrack"..i] then
                CombuMBTrackerCreateBombRow (i)
            end

    		_G["CombuMBTrack"..i.."InfoText"]:SetText("")
            _G["CombuMBTrack"..i.."InfoTimer"]:SetText("")
            _G["CombuMBTrack"..i.."Bar"]:Hide()
            _G["CombuMBTrack"..i.."InfoTarget"]:SetTexture("")                
            _G["CombuMBTrack"..i.."InfoSymbol"]:SetTexture("")
        end

   		CombuMBTrack1InfoText:SetText("-- no bomb --")
        combumbtrackerenableheight = 9
        combumbtrackerenableclean = true
        
    elseif #CombuMBTrackertable ~= 0 then --print(3)
    	
    	combumbtrackerenableclean = false
    	combumbtrackerenableheight = 0
    	
    	if #CombuMBTrackertable > combumbtrackerenablemax then
    		combumbtrackerenablemax = #CombuMBTrackertable
    	end
    	
    	for i = 1, combumbtrackerenablemax do 
            
           	if not _G["CombuMBTrack"..i] then
                CombuMBTrackerCreateBombRow (i)
            end
            
			if CombuMBTrackertable[i] and (CombuMBTrackertable[i])[3] and ((CombuMBTrackertable[i])[3] + 2) <= GetTime() 
				then table.remove(CombuMBTrackertable,i)
			end
		
			if (#CombuMBTrackertable == 1) and (UnitGUID("target") == (CombuMBTrackertable[1])[1]) and (combumbtrackersettingstable["combumbtlbtarget"] == false)
				then _G["CombuMBTrack"..i.."InfoText"]:SetText("")
					 _G["CombuMBTrack"..i.."InfoTimer"]:SetText("")
					 _G["CombuMBTrack"..i.."Bar"]:Hide()
					 _G["CombuMBTrack"..i.."InfoTarget"]:Hide()
					 _G["CombuMBTrack"..i.."InfoSymbol"]:Hide()
					 CombuMBTrackerFrame:Hide() --print("1")
			elseif CombuMBTrackertable[i] and (CombuMBTrackertable[i])[3]
				then _G["CombuMBTrack"..i.."InfoText"]:SetText((CombuMBTrackertable[i])[2])
					 combumbtlbtimer = (-1*(GetTime()-(CombuMBTrackertable[i])[3]))
					 
					 if (CombuMBTrackertable[i])[4] and (combumbtlbtimer >= combumbtrackersettingstable["combumbtrackertimervalue"]) then -- condition when timer is with more than 2 seconds left
						 _G["CombuMBTrack"..i.."InfoTimer"]:SetText(format("|cff00ff00%.1f|r",combumbtlbtimer))
						 _G["CombuMBTrack"..i.."Bar"]:Show()
						 _G["CombuMBTrack"..i.."Bar"]:SetValue(100*(combumbtlbtimer/(CombuMBTrackertable[i])[4]))
						 _G["CombuMBTrack"..i.."Bar"]:SetStatusBarColor((combumbtrackersettingstable["barcolornormal"])[1],(combumbtrackersettingstable["barcolornormal"])[2],(combumbtrackersettingstable["barcolornormal"])[3],(combumbtrackersettingstable["barcolornormal"])[4])
					 elseif (CombuMBTrackertable[i])[4] and (combumbtlbtimer <= combumbtrackersettingstable["combumbtrackertimervalue"]) and (combumbtlbtimer >= 0) then -- condition when timer is with less than 2 seconds left
						 _G["CombuMBTrack"..i.."InfoTimer"]:SetText(format("|cffff0000%.1f|r",combumbtlbtimer))
						 _G["CombuMBTrack"..i.."Bar"]:Show()
						 _G["CombuMBTrack"..i.."Bar"]:SetValue(100*(combumbtlbtimer/(CombuMBTrackertable[i])[4]))
						 _G["CombuMBTrack"..i.."Bar"]:SetStatusBarColor(unpack(combumbtrackersettingstable["barcolorwarning"]))
					 elseif (combumbtlbtimer <= 0) then
						 table.remove(CombuMBTrackertable,i)
					 end
					 
					 if CombuMBTrackertable[i] and (CombuMBTrackertable[i])[5] then 
						_G["CombuMBTrack"..i.."InfoSymbol"]:SetTexture("Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_"..(CombuMBTrackertable[i])[5])
					 else _G["CombuMBTrack"..i.."InfoSymbol"]:SetTexture("")
					 end
					 
					 if CombuMBTrackertable[i] and (UnitGUID("target") == (CombuMBTrackertable[i])[1]) and combumbtrackersettingstable["combumbtrackertarget"] == true then
						_G["CombuMBTrack"..i.."InfoTarget"]:SetTexture("Interface\\AddOns\\MageBombTracker\\Images\\Combustion_target")
					 else _G["CombuMBTrack"..i.."InfoTarget"]:SetTexture("")
					 end
					 
					 combumbtrackerenableheight = combumbtrackerenableheight + 9
					 
			else 
				 _G["CombuMBTrack"..i.."InfoText"]:SetText("")
				 _G["CombuMBTrack"..i.."InfoTimer"]:SetText("")
				 _G["CombuMBTrack"..i.."Bar"]:Hide()
				 _G["CombuMBTrack"..i.."InfoTarget"]:SetTexture("")
				 _G["CombuMBTrack"..i.."InfoSymbol"]:SetTexture("")
			end
		end
    end

    CombuMBTrackerBorderFrame:SetHeight(combumbtrackerenableheight + 11)
    
end
 
-------------------------------------
-- Autohide function
function CombuMBTrackerAutohide()

	local combumbtrackercombat = UnitAffectingCombat("player")
	
    if combumbtrackersettingstable["combumbtrackerenable"] == true and select(2, UnitClass("player")) == "MAGE" then
        
        if combumbtrackersettingstable["combumbtrackerautohide"] == 1 then -- condition when autohide is disabled
            
            CombuMBTrackerFrame:Show()
            
        elseif combumbtrackercombat == nil and combumbtrackersettingstable["combumbtrackerautohide"] ~= 1 then -- condition when not in combat
            
            CombuMBTrackerFrame:Hide()
            
        elseif #CombuMBTrackertable == 0 and combumbtrackersettingstable["combumbtrackerautohide"] == 3 then -- condition when no bomb present
            
            CombuMBTrackerFrame:Hide()
        
        elseif combumbtrackercombat == 1 then -- condition when in combat
            
            CombuMBTrackerFrame:Show()
            
        end
        
    else CombuMBTrackerFrame:Hide()
        
    end
    
end


-------------------------------------------------------------------------------------------------------	
-------------------------------------------------------------------------------------------------------	
-------------------------------- ON_EVENT FUNCTION ----------------------------------------------------

function CombuMBTracker_OnEvent(self, event, ...)

    if (event == "PLAYER_LOGIN") then
    	               
	    if (CombuMBTrackerFrame:GetFrameLevel() == 0) then
	        CombuMBTrackerFrame:SetFrameLevel(1) -- fix when frame is at FrameLevel 0
	    end
	        
-------------------------------
--Frame lock check on startup
        if (combumbtrackersettingstable["combumbtrackerlock"] == false) 
	 		then CombuMBTrackerFrame:EnableMouse(true)
        elseif (combumbtrackersettingstable["combumbtrackerlock"] == true) 
	    	then CombuMBTrackerFrame:EnableMouse(false)
        end	
        
        CombuMBTrackerLanguageCheck()
	    CombuMBTrackerScale (combumbtrackersettingstable["combumbtrackerscale"]) -- Scale check on startup
	    CombuMBTrackerFrameresize() 

    elseif (event == "PLAYER_TALENT_UPDATE") then
        
        CombuMBTrackerBombChecker ()
  	    --CombuMBTrackerFrameresize() 

-------------------------------
--Combat log events checks
    elseif (event=="COMBAT_LOG_EVENT_UNFILTERED") then

    	timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical = select(1, ...)
            
            if (sourceName == UnitName("player")) and combumbtrackersettingstable["combumbtrackerenable"] == true then --if spellId == 44457 or spellId == 44461 then print(spellId,event) end
                
				-------------------------------------------
				-- Living Bomb early refresh 
                if (combumbtrackersettingstable["combumbtrackerrefreshmode"] == true) then --print(spellId,event,amount)
                    
                    
                    if (event == "SPELL_AURA_REFRESH") and (spellId == CombuMBTlvbID) then 
                    
                        combumbtlbrefresh = combumbtlbrefresh + 1 
                        combupotentialrefresh = GetTime()
                        comburefreshdone = 0
                        comburefreshGUID = destGUID
                        comburefreshname = destName
                                                
                        if spellId == 114923 then
                            
                            for i = 1,#CombuMBTrackertable do --print((MBTrackertable[i])[3] - GetTime())
                                
                                if CombuMBTrackertable[i] and ((CombuMBTrackertable[i])[1] == destGUID) and (CombuMBTrackertable[i])[3] - GetTime() < 1 then
                                    
                                    combupotentialrefresh = 0
                                    combumbtlbrefresh = combumbtlbrefresh - 1 
                                    break
                                    
                                end
                            end
                        end
                    
                    elseif (event == "SPELL_MISSED") and (spellId == CombuMBTlvbID) then 
                    
                        PlaySoundFile("Sound\\Spells\\SimonGame_Visual_BadPress.wav")
                        print(format(CombuMBTrackerLoc["lbmiss"],destName))
                        
                    elseif (spellId == 44461) and comburefreshGUID == destGUID then
                    
                        if abs(combupotentialrefresh - GetTime()) < 0.5 then 
                        
                            combupotentialrefresh = 0
                            combumbtlbrefresh = combumbtlbrefresh - 1 

                        end
                    end
                end

				-------------------------------------------
				-- Living Bomb tracking 
                if (combumbtrackersettingstable["combumbtrackerenable"] == true) and (spellId == CombuMBTlvbID) then 
                	if (event == "SPELL_AURA_APPLIED") or (event == "SPELL_AURA_REFRESH") 
                		then CombuMBTrackerLBauratracker(destGUID, destName, GetTime())
                             CombuMBTrackerAutohide()
                			--print(destGUID, destName, GetTime())--------------------debug
                	elseif (event == "SPELL_AURA_REMOVED") and spellId ~= 112948 then
                		for i = 1,#CombuMBTrackertable do
                 
							if CombuMBTrackertable[i] and ((CombuMBTrackertable[i])[1] == destGUID) 
                 				then table.remove(CombuMBTrackertable,i)
                                    break
                 		 	end
                            
                 		end
                        
                        CombuMBTrackerAutohide()
                	end
                end
                
                -- Impact and inferno blast manager for bomb tracking
                if (spellId == 2136) or (spellId == 108853) and (event == "SPELL_CAST_SUCCESS") -- successful impact cast
                    then combumbtrackerimpacttimer = GetTime()
                elseif (spellId == 2136) or (spellId == 108853) and (event == "SPELL_MISSED")
                    then combumbtrackerimpacttimer = nil
                end

				-------------------------------------------
				-- FlameStrike tracking 
			    if  (combumbtrackersettingstable["combumbtrackerflamestrike"] == true) or (spellId == 2120) and (spellId == 88148) then 
			    	if (event == "SPELL_DAMAGE") or (event == "SPELL_CAST_SUCCESS")
						then combumbtlbtablerefresh = 0
							 for z = 1, #CombuMBTrackertable do
			               
					    		 if ((CombuMBTrackertable[z])[1] == spellId) 
					            	then (CombuMBTrackertable[z])[3] = (GetTime() + 8);
					                     (CombuMBTrackertable[z])[4] = 8;
					                     (CombuMBTrackertable[z])[5] = nil
					                     combumbtlbtablerefresh = 1
					                     break
					             end 
					         end
			                   
					         if (combumbtlbtablerefresh == 1) then
					         elseif (spellId == 2120) 
					         	then table.insert(CombuMBTrackertable, {spellId, CombuMBTrackerLabel["flamestrike"], (GetTime() + 8), 8, nil})
					         elseif (spellId == 88148) 
					         	then table.insert(CombuMBTrackertable, {spellId, CombuMBTrackerLabel["blastwave"], (GetTime() + 8), 8, nil})
					         end
					end
				end
						
            end
                
-------------------------------------------
-- Start and End of fight events 
    elseif (event == "PLAYER_REGEN_DISABLED") then 
    	
        CombuMBTrackerAutohide()
        		    
    elseif (event == "PLAYER_REGEN_ENABLED") then 
    	    
    	if (combumbtlbrefresh >= 1) then
        	print(format(CombuMBTrackerLoc["lbreport"],combumbtlbrefresh))
        	combumbtlbrefresh = 0
        end
    		        
        table.wipe(CombuMBTrackertable) -- cleaning multiple Bomb tracker table when leaving combat
        CombuMBTrackerAutohide()
            
-------------------------------------------
-- talent change             
    elseif event == "PLAYER_TALENT_UPDATE" then
        
    	CombuMBTrackerBombChecker()
        
    end

end
	




	
-------------------------------------------------------------------------------------------------------	
-------------------------------------------------------------------------------------------------------	
-------------------------------- ON_UPDATE FUNCTION ----------------------------------------------------

function CombuMBTracker_OnUpdate(self, elapsed)
    self.TimeSinceLastUpdate = (self.TimeSinceLastUpdate or 0) + elapsed;
 
		if (self.TimeSinceLastUpdate > CombuMBTracker_UpdateInterval) then
            local time = GetTime()   
            
--------------------------------
-- multiple Living Bomb tracking
    		if (combumbtrackersettingstable["combumbtrackerenable"] == true) or (combumbtrackersettingstable["combumbtrackerflamestrike"] == true) then
    			CombuMBTrackerUpdate()
    		end
            
            if (combumbtrackersettingstable["combumbtrackerrefreshmode"] == true) and InCombatLockdown () then
            
                if abs(combupotentialrefresh + 1.6 - GetTime()) < 0.8 and comburefreshdone == 0 then
                    
                    print(format(CombuMBTrackerLoc["lbrefresh"],comburefreshname))
                    comburefreshdone = 1
                end
            
            end


    		self.TimeSinceLastUpdate = 0

    end    
end


--~ SLASH_COMBUMBTRACKERCONFIG1 = "/MageBombTracker"

--~ SlashCmdList["COMBUMBTRACKERCONFIG"] = function(msg)

--~ 	if msg == "" or  msg == "help" or  msg == "?" or msg == "config" then
--~ 		 InterfaceOptionsFrame_OpenToCategory("MageBombTracker")
--~ 		 if (combumbtrackersettingstable["combumbtrackerchat"]==true) then print(format(CombuMBTrackerLoc["slashcomm"])) end
--~ 	else
--~ 		 InterfaceOptionsFrame_OpenToCategory("MageBombTracker")
--~ 		 if (combumbtrackersettingstable["combumbtrackerchat"]==true) then print(format(CombuMBTrackerLoc["slashcomm"])) end
--~ 	end

--~ end