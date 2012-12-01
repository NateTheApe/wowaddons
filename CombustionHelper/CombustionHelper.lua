CombustionHelper = {} 

LibTransition = LibStub("LibTransition-1.0"); 
CombuLSM = LibStub("LibSharedMedia-3.0") 

Combustion_UpdateInterval = 0.1; -- How often the OnUpdate code will run (in seconds)

local lvb, lvbID, ignite, pyro1, comb, impact, combulbtimer, combupyrotimer, combupyrocast, combuclientVersion, combucritpredict, combucrittarget
local LBTime, IgnTime, PyroTime, CombustionUp, combufadeout, ImpactUp, combuimpacttimer
local combupyrogain, combupyrorefresh
local combuignitebank, combuigniteapplied, combuignitevalue, combuignitemunched, combuigndamage, combuignitecount
local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, combucombustiontimestamp, combucombustiondmg, combucombustionprevdmg, combuticks, combuprevticks, combutickdmg, combutickprevdmg, combuprevtargets, combutargets
local combupyrodps, combuhastetick, combucurrenthaste, combuexpectedtickdmg, combustiontime, combuglyph

function Combustion_OnLoad(Frame) 
                                               
    if select(2, UnitClass("player")) ~= "MAGE" then CombustionFrame:Hide() return end
        
	Frame:RegisterForDrag("LeftButton")
	Frame:RegisterEvent("PLAYER_LOGIN")
	Frame:RegisterEvent("PLAYER_TALENT_UPDATE")
	Frame:RegisterEvent("PLAYER_REGEN_DISABLED")
	Frame:RegisterEvent("PLAYER_REGEN_ENABLED")
 	Frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    
 	CombuLSM.RegisterCallback(CombustionHelper , "LibSharedMedia_Registered", "SharedMedia_Registered") 

	CombuLSM:Register("background","Blizzard Tooltip","Interface\\Tooltips\\UI-Tooltip-Background")
	CombuLSM:Register("border","Blizzard Tooltip","Interface\\Tooltips\\UI-Tooltip-Border")
	CombuLSM:Register("border","ElvUI Border","Interface\\AddOns\\CombustionHelper\\Images\\ElvUIBorder")
	CombuLSM:Register("statusbar","CombuBar","Interface\\AddOns\\CombustionHelper\\Images\\combubarblack")
	CombuLSM:Register("sound","CH Volcano","Interface\\AddOns\\CombustionHelper\\Sound\\Volcano.ogg")
    
    LibTransition:Attach(Frame)
    
    CombuClientVersionCheck()
    CombuLanguageCheck()
	CombuTableCopy()
	CombustionVarReset()
        	
end
                            
combudefaultsettingstable = {["combulock"] = false,
							["combuautohide"] = 1,
							["combuimpact"] = true,
							["combuscale"] = 1,
							["combubeforefade"] = 15,
							["combuafterfade"] = 15,
							["combufadeoutspeed"] = 2,
							["combufadeinspeed"] = 2,
							["combuwaitfade"] = 86,
							["combufadealpha"] = 0,
							["combubartimers"] = false,
							["combureport"] = true,
							["combureportvalue"] = 0,
							["combureportthreshold"] = false,
							["combureportpyro"] = true,
							["combutrack"] = true,
							["combuchat"] = true,
							["combubarwidth"] = 24,
							["combutimervalue"] = 2,
							["combuignitereport"] = true,
							["combuignitedelta"] = 0,
							["combureportmunching"] = false,
							["combutexturename"] = "CombuBar",
							["combufontname"] = "Friz Quadrata TT",
							["combusoundname"] = "CombustionHelper Volcano",
							["barcolornormal"] = {0,0.5,0.8,1},
							["barcolorwarning"] = {1,0,0,1},
							["textcolornormal"] = {1,1,1,1},
							["textcolorwarning"] = {1,0,0,1},
							["textcolorvalid"] = {0,1,0,1},
							["buttontexturewarning"] = "Interface\AddOns\CombustionHelper\Images\Combustionoff",
							["buttontexturevalid"] = "Interface\AddOns\CombustionHelper\Images\Combustionon",
							["bgcolornormal"] = {0.25,0.25,0.25,1},
							["bgcolorimpact"] = {1,0.82,0,0.5},
							["bgcolorcombustion"] = {0,0.7,0,0.5},
							["bgcolorwarning"] = {0.7,0,0,0.5},
							["edgecolornormal"] = {0.67,0.67,0.67,1},
							["bgFile"] = "Blizzard Tooltip",
                        	["tileSize"] = 16,
                        	["edgeFile"] = "Blizzard Tooltip",
                        	["tile"] = true,
                        	["edgeSize"] = 16,
                        	["insets"] = 5,
                            ["language"] = "Default",
                            ["thresholdalert"] = true,
							["MageBombTrackerPosition"] = "upside",
                            ["combutickpredict"] = true,
                            ["pyromaniac"] = true,
                            ["hotstreak"] = true,
}

combuhasteplateau = {{0,10},
                            {639,11},
                            {1922,12},
                            {3212,13},
                            {4488,14},
                            {5767,15},
                            {7033,16},
                            {8309,17},
                            {9602,18},
                            {10887,19},
                            {12182,20}}

function CombuClientVersionCheck()
	
    combuclientVersion  = select(4,GetBuildInfo())

	CombuBombChecker ()	
	
	ignite = GetSpellInfo(12654) 
	pyro1 = GetSpellInfo(11366) 
	comb = GetSpellInfo(11129)   
	combudot = GetSpellInfo(83853)
		
end

-------------------------------
--function for bomb type 
function CombuBombChecker ()
		
	if select(2,GetTalentRowSelectionInfo(5)) == 13 then -- nether tempest selected
		
		lvb = GetSpellInfo(114923)
		lvbID = 114923
		
	elseif select(2,GetTalentRowSelectionInfo(5)) == 14 then -- living bomb
		
		lvb = GetSpellInfo(44457)
		lvbID = 44457
		
	elseif select(2,GetTalentRowSelectionInfo(5)) == 15 then -- frost bomb
		
		lvb = GetSpellInfo(113092)
		lvbID = 113092
            
	else lvb = GetSpellInfo(44457)
		 lvbID = 44457
	
	end

end

function CombuLanguageCheck()

    if combusettingstable then 
    
        if combusettingstable["language"] == "Francais" or combusettingstable["language"] == "Default" and GetLocale() == "frFR" then

            CombuLoc = CombuLocFR
            combuoptioninfotable = combuoptioninfotableFR
            CombuOptLoc = CombuOptLocFR
            CombuLBposition = CombuLBpositionFR
            CombuAutohideList = CombuAutohideListFR
            CombuLabel = CombuLabelFR
                
        elseif combusettingstable["language"] == "Deutsch" or combusettingstable["language"] == "Default" and GetLocale() == "deDE" then
            
            CombuLoc = CombuLocDE
            combuoptioninfotable = combuoptioninfotableDE
            CombuOptLoc = CombuOptLocDE
            CombuLBposition = CombuLBpositionDE
            CombuAutohideList = CombuAutohideListDE
            CombuLabel = CombuLabelDE
            
        elseif combusettingstable["language"] == "Chinese" or combusettingstable["language"] == "Default" and GetLocale() == "zhTW" then
            
            CombuLoc = CombuLocTW
            combuoptioninfotable = combuoptioninfotableTW
            CombuOptLoc = CombuOptLocTW
            CombuLBposition = CombuLBpositionTW
            CombuAutohideList = CombuAutohideListTW
            CombuLabel = CombuLabelTW

        else CombuLoc = CombuLocEN
            combuoptioninfotable = combuoptioninfotableEN
            CombuOptLoc = CombuOptLocEN
            CombuLBposition = CombuLBpositionEN
            CombuAutohideList = CombuAutohideListEN
            CombuLabel = CombuLabelEN

        end
    else CombuLoc = CombuLocEN
        combuoptioninfotable = combuoptioninfotableEN
        CombuOptLoc = CombuOptLocEN
        CombuLBposition = CombuLBpositionEN
        CombuAutohideList = CombuAutohideListEN
        CombuLabel = CombuLabelEN
        
   end

end

function CombuTableCopy()

	combusettingstable = {}
	
	for k,v in pairs(combudefaultsettingstable) do 
		if type(v) == "table" then
			combusettingstable[k] = {}
			for i = 1,#v do
				table.insert(combusettingstable[k],v[i])
			end
		else combusettingstable[k] = v 
		end
	end
    
end

function CombuTableNewSettingsCheck()
	    
 	for k,v in pairs(combudefaultsettingstable) do 
         
         if combusettingstable[k] == nil then print(k) combuprut = 1
        
            if type(v) == "table" then

                combusettingstable[k] = {}
                for i = 1,#v do
                    table.insert(combusettingstable[k],v[i])
                end
            else combusettingstable[k] = v   

            end
        end
	end
end

----------------------------------
-- Helper function to reset some variables
function CombustionVarReset()

	combupyrogain = 0 -- variables related to post fight report
   	combupyrorefresh = 0
   	combupyrocast = 0
   	combulbrefresh = 0
   	
   	combuignitebank = 0 -- variables related to ignite
    combuigniteapplied = 0
    combuignitevalue = 0
    combuignitetemp = 0
    combuignitemunched = 0
    combuigndamage = 0
    combuignitecount = 0
    
    combucurrentduration = 0
    combustiontime = 0
    
end

--------------------------------
-- Helper function for Sharemedia support
function CombustionHelper:SharedMedia_Registered()
--	print("prut")
    -- do whatever needs to be done to repaint / refont
end

-------------------------------
-- helper function for option panel setup
function CombustionHelperOptions_OnLoad(panel)
    CombuLanguageCheck()
	panel.name = "CombustionHelper"
	InterfaceOptions_AddCategory(panel);
end

-------------------------------
-- helper function for customisation option panel setup
function CombustionHelperCustomOptions_OnLoad(panel)
    CombuLanguageCheck()
	panel.name = CombuLoc["interfaceGraph"]
	panel.parent = "CombustionHelper"
	InterfaceOptions_AddCategory(panel);
end

-------------------------------
-- lock function for option panel
function Combustionlock()

	if CombulockButton:GetChecked(true) then combusettingstable["combulock"] = true 
                                 CombustionFrame:EnableMouse(false)
                                 CombulockButton:SetChecked(true)
                                 if (combusettingstable["combuchat"]==true) then ChatFrame1:AddMessage(CombuLoc["lockon"]) end
	else combusettingstable["combulock"] = false 
         CombustionFrame:EnableMouse(true)
         CombulockButton:SetChecked(false)
         if (combusettingstable["combuchat"]==true) then ChatFrame1:AddMessage(CombuLoc["lockoff"]) end
	end
end

-------------------------------
-- chat function for option panel
function Combustionchat()

	if CombuchatButton:GetChecked(true) then combusettingstable["combuchat"] = true 
                                 CombuchatButton:SetChecked(true)
                                 ChatFrame1:AddMessage(CombuLoc["reporton"])
	else combusettingstable["combuchat"] = false 
         CombuchatButton:SetChecked(false)
	end
end

-------------------------------
-- pyromaniac function for option panel
function CombustionPyromaniac()

	if CombuPyromaniacButton:GetChecked(true) then combusettingstable["pyromaniac"] = true 
                                 CombuPyromaniacButton:SetChecked(true)
	else combusettingstable["pyromaniac"] = false 
         CombuPyromaniacButton:SetChecked(false)
	end
end

-------------------------------
-- hot streak function for option panel
function CombustionHotstreak()

	if CombuHotStreakButton:GetChecked(true) then combusettingstable["hotstreak"] = true 
                                 CombuHotStreakButton:SetChecked(true)
	else combusettingstable["hotstreak"] = false 
         CombuHotStreakButton:SetChecked(false)
	end
end

function CombustionTickPredict()

	if CombuTickPredictButton:GetChecked(true) then combusettingstable["combutickpredict"] = true 
                                 CombuTickPredictButton:SetChecked(true)
	else combusettingstable["combutickpredict"] = false 
         CombuTickPredictButton:SetChecked(false)
	end
end

-------------------------------
-- threshold sound function for option panel
function CombustionThresholdSound()

	if CombuThresholdSoundButton:GetChecked(true) then combusettingstable["thresholdalert"] = true 
                                 CombuThresholdSoundButton:SetChecked(true)
	else combusettingstable["thresholdalert"] = false 
         CombuThresholdSoundButton:SetChecked(false)
	end
end

-------------------------------
-- threshold function for option panel
function Combustionthreshold()

	if Combureportthreshold:GetChecked(true) then combusettingstable["combureportthreshold"] = true 
                                 Combureportthreshold:SetChecked(true)
	else combusettingstable["combureportthreshold"] = false 
         Combureportthreshold:SetChecked(false)
	end
end

-------------------------------
-- DPS Report function for option panel
function Combustionreport()

	if CombureportButton:GetChecked(true) then combusettingstable["combureport"] = true 
                                             CombureportButton:SetChecked(true)
                                             if (combusettingstable["combuchat"]==true) then ChatFrame1:AddMessage(CombuLoc["dmgreporton"]) end
	else combusettingstable["combureport"] = false 
         CombureportButton:SetChecked(false)
         if (combusettingstable["combuchat"]==true) then ChatFrame1:AddMessage(CombuLoc["dmgreportoff"]) end
	end
end

-------------------------------
-- combustion dot tracker function for option panel
function Combustiontracker()

	if CombutrackerButton:GetChecked(true) then combusettingstable["combutrack"] = true 
                                             CombutrackerButton:SetChecked(true)
                                             if (combusettingstable["combuchat"]==true) then ChatFrame1:AddMessage(CombuLoc["doton"]) end
	else combusettingstable["combutrack"] = false 
         CombutrackerButton:SetChecked(false)
         if (combusettingstable["combuchat"]==true) then ChatFrame1:AddMessage(CombuLoc["dotoff"]) end
	end
end

-------------------------------
-- lb refresh function for option panel
function Combustionrefresh()

	if ComburefreshButton:GetChecked(true) then combusettingstable["comburefreshmode"] = true 
                                                ComburefreshButton:SetChecked(true)
                                                if (combusettingstable["combuchat"]==true) then ChatFrame1:AddMessage(CombuLoc["lbon"]) end
	else combusettingstable["comburefreshmode"] = false 
         ComburefreshButton:SetChecked(false)
         if (combusettingstable["combuchat"]==true) then ChatFrame1:AddMessage(CombuLoc["lboff"]) end
	end
end

-------------------------------
-- pyro refresh function for option panel
function CombustionrefreshPyro()

	if ComburefreshpyroButton:GetChecked(true) then combusettingstable["combureportpyro"] = true 
                                                ComburefreshpyroButton:SetChecked(true)
                                                if (combusettingstable["combuchat"]==true) then ChatFrame1:AddMessage(CombuLoc["pyroon"]) end
	else combusettingstable["combureportpyro"] = false 
         ComburefreshpyroButton:SetChecked(false)
         if (combusettingstable["combuchat"]==true) then ChatFrame1:AddMessage(CombuLoc["pyrooff"]) end
	end
end

-------------------------------
-- impact function for option panel
function Combustionimpact()

	if CombuimpactButton:GetChecked(true) then combusettingstable["combuimpact"] = true 
                                               CombuimpactButton:SetChecked(true)
                                               if (combusettingstable["combuchat"]==true) then ChatFrame1:AddMessage(CombuLoc["impacton"]) end
	else combusettingstable["combuimpact"] = false 
         CombuimpactButton:SetChecked(false)
         if (combusettingstable["combuchat"]==true) then ChatFrame1:AddMessage(CombuLoc["impactoff"]) end
	end
end

-------------------------------
-- Scale function for option panel
function CombustionScale (scale)

	CombustionFrame:SetScale(scale)
	combusettingstable["combuscale"] = scale
end

-------------------------------
-- Bar timer function for option panel
function Combustionbar()

	if CombuBarButton:GetChecked(true) then combusettingstable["combubartimers"] = true 
                                            CombuBarButton:SetChecked(true)
                                            if (combusettingstable["combuchat"]==true) then ChatFrame1:AddMessage(CombuLoc["baron"]) end
	else combusettingstable["combubartimers"] = false 
         CombuBarButton:SetChecked(false)
         if (combusettingstable["combuchat"]==true) then ChatFrame1:AddMessage(CombuLoc["baroff"]) end
	end
    CombustionFrameresize()
end

-------------------------------
-- 
function CombustionMunching()

	if CombuMunchingButton:GetChecked(true) then combusettingstable["combureportmunching"] = true 
                                                 CombuMunchingButton:SetChecked(true)
                                             	 if (combusettingstable["combuchat"]==true) then ChatFrame1:AddMessage(CombuLoc["munchon"]) end
	else combusettingstable["combureportmunching"] = false 
         CombuMunchingButton:SetChecked(false)
         if (combusettingstable["combuchat"]==true) then ChatFrame1:AddMessage(CombuLoc["munchoff"]) end
	end
end

combuwidgetlist = {
	
	bars = {"Pyrobar","Ignbar","LBbar","Combubar"},
	text = {"LBLabel","IgniteLabel","PyroLabel","LBTextFrameLabel","IgnTextFrameLabel","PyroTextFrameLabel","StatusTextFrameLabel"},
}

function CombuBackdropBuild ()

	if not CombuBackdrop then
	
		CombuBackdrop = {bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
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

    if combusettingstable then
        CombuBackdrop["bgFile"] = CombuLSM:Fetch("background",combusettingstable["bgFile"])
        CombuBackdrop["tileSize"] = combusettingstable["tileSize"]
        CombuBackdrop["edgeFile"] = CombuLSM:Fetch("border",combusettingstable["edgeFile"])
        CombuBackdrop["tile"] = combusettingstable["tile"]
        CombuBackdrop["edgeSize"] = combusettingstable["edgeSize"];
        (CombuBackdrop["insets"])["top"] = combusettingstable["insets"];
        (CombuBackdrop["insets"])["right"] = combusettingstable["insets"];
        (CombuBackdrop["insets"])["left"] = combusettingstable["insets"];
        (CombuBackdrop["insets"])["bottom"] = combusettingstable["insets"]
    end
    
    CombustionFrame:SetBackdrop(CombuBackdrop)
    CombustionFrame:SetBackdropColor(unpack(combusettingstable["bgcolornormal"]))
    CombustionFrame:SetBackdropBorderColor(unpack(combusettingstable["edgecolornormal"]))

end
			
-------------------------------
-- Helper function for frame resizing
function CombustionFrameresize()
	
    CombustionFrame:SetHeight(48)

	if (combusettingstable["combubartimers"] == true) 
	then CombustionFrame:SetWidth(98+combusettingstable["combubarwidth"]+6)
		 CombustionTextFrame:SetWidth(98+combusettingstable["combubarwidth"]+6)
		 LBTextFrameLabel:SetWidth(28+combusettingstable["combubarwidth"]+2)
		 LBTextFrameLabel:SetJustifyH("RIGHT")
		 PyroTextFrameLabel:SetWidth(28+combusettingstable["combubarwidth"]+2)
		 PyroTextFrameLabel:SetJustifyH("RIGHT")
		 IgnTextFrameLabel:SetWidth(28+combusettingstable["combubarwidth"]+2)
		 IgnTextFrameLabel:SetJustifyH("RIGHT")
         Combubar:SetWidth(92+combusettingstable["combubarwidth"])
	else CombustionFrame:SetWidth(98)
         CombustionTextFrame:SetWidth(98)
		 LBTextFrameLabel:SetWidth(28)
		 LBbar:Hide()
		 LBTextFrameLabel:SetJustifyH("LEFT")
		 PyroTextFrameLabel:SetWidth(28)
		 Pyrobar:Hide()
		 PyroTextFrameLabel:SetJustifyH("LEFT")
		 Ignbar:Hide()
		 IgnTextFrameLabel:SetWidth(28)
		 IgnTextFrameLabel:SetJustifyH("LEFT")
         Combubar:SetWidth(83)
	end
    
    Combubar:SetMinMaxValues(0,100)
	LBbar:SetMinMaxValues(0,100)
	LBbar:SetWidth(28+combusettingstable["combubarwidth"])
	Ignbar:SetMinMaxValues(0,100)
	Ignbar:SetWidth(28+combusettingstable["combubarwidth"])
	Pyrobar:SetMinMaxValues(0,100)
	Pyrobar:SetWidth(28+combusettingstable["combubarwidth"])
	
    CombuMBTrackerFrame:ClearAllPoints()

    if (combusettingstable["MageBombTrackerPosition"] == "free") --or IsSpellKnown(11129) == false
        then CombuMBTrackerFrame:EnableMouse(true) --print(5)
    elseif (combusettingstable["MageBombTrackerPosition"] == "upside")
        then CombuMBTrackerFrame:SetPoint("BOTTOM",CombustionFrame,"TOP",0,-6) --print(1)
             combumbtrackersettingstable["direction"] = "upward"
             CombuMBTrackerFrame:EnableMouse(false)
    elseif (combusettingstable["MageBombTrackerPosition"] == "downside")
        then CombuMBTrackerFrame:SetPoint("TOP",CombustionFrame,"BOTTOM",0,6) --print(2)
             combumbtrackersettingstable["direction"] = "downward"
             CombuMBTrackerFrame:EnableMouse(false)
    elseif (combusettingstable["MageBombTrackerPosition"] == "rightside")
        then CombuMBTrackerFrame:SetPoint("TOPLEFT",CombustionFrame,"TOPRIGHT",-6,0) --print(3)
             combumbtrackersettingstable["direction"] = "downward"
             CombuMBTrackerFrame:EnableMouse(false)
    elseif (combusettingstable["MageBombTrackerPosition"] == "leftside")
        then CombuMBTrackerFrame:SetPoint("TOPRIGHT",CombustionFrame,"TOPLEFT",6,0) --print(4)
             combumbtrackersettingstable["direction"] = "downward"
             CombuMBTrackerFrame:EnableMouse(false)
    end

    for i = 1,#combuwidgetlist["bars"] do _G[(combuwidgetlist["bars"])[i]]:SetStatusBarTexture(CombuLSM:Fetch("statusbar",combusettingstable["combutexturename"])) end
    for i = 1,#combuwidgetlist["text"] do 	_G[(combuwidgetlist["text"])[i]]:SetFont(CombuLSM:Fetch("font",combusettingstable["combufontname"]),select(2,_G[(combuwidgetlist["text"])[i]]:GetFont())) end   
    
    CombuMBTrackerBorderFrame:SetFrameLevel((CombustionFrame:GetFrameLevel())-1)
         
	CombuBackdropBuild ()
    
end

function Combustionreset ()

        table.wipe(LibTransition.tQueue) table.wipe(LibTransition.cQueue)
		CombustionFrame:FadeIn(combusettingstable["combufadeinspeed"])
        CombustionFrame:ClearAllPoints()
        CombustionFrame:SetPoint("CENTER", UIParent, "CENTER" ,0,0)
        CombustionFrame:SetScale(1)
        
        CombuTableCopy()
		
        ChatFrame1:AddMessage(CombuLoc["reset"])
        CombustionFrameresize()
        Combustionlock ()

end

function CombuColorPicker(r, g, b, a)

    ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = (a ~= nil), a;
    ColorPickerFrame.previousValues = {r,g,b,a};
    ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = CombuColorCallback, CombuColorCallback, CombuColorCallback;
    ColorPickerFrame:SetColorRGB(r,g,b);
    ColorPickerFrame:Hide(); -- Need to run the OnShow handler.
    ColorPickerFrame:Show();
    
end
	
function CombuColorCallback(restore)

    local newR, newG, newB, newA
    
    if restore then
        newR, newG, newB, newA = unpack(restore);
    else newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
    end
 
    (combusettingstable[combucolorinstance])[1], (combusettingstable[combucolorinstance])[2], (combusettingstable[combucolorinstance])[3], (combusettingstable[combucolorinstance])[4] = newR, newG, newB, newA;
    _G["Combu"..combucolorinstance.."SwatchTexture"]:SetVertexColor(unpack(combusettingstable[combucolorinstance]))
    
end

function CombuSavedVariablesConvert ()

	for k,v in pairs(combudefaultsettingstable) do -- fill the combusettingstable with missing info from default table
		if combusettingstable[k] == nil then 
			if type(v) == "table" then
				combusettingstable[k] = {}
				for i = 1,#v do
					table.insert(combusettingstable[k],v[i])
				end
			else combusettingstable[k] = v 
			end
		end
	end

end

local CombuCritMeta = {
	34220, -- burning crusade
	41285, -- wrath of the lich king
	52291, -- cataclysm
    68780
};

function CombuCreateTextureList(dropdown, settings)

    combutexturesettings = settings
    combutexturedropdown = dropdown
    
    CombuTextureList = {} for k in pairs(CombuLSM:HashTable("statusbar")) do tinsert(CombuTextureList,k) end
    
    CombuTextureBorderFrame:Show()
    CombuTextureBorderFrame:ClearAllPoints()
    CombuTextureFrame:SetHeight(#CombuTextureList*20)
    CombuTextureBorderFrame:SetPoint("CENTER",dropdown,"CENTER",0,0-(CombuTextureFrame:GetHeight()/4))
    CombuTextureBorderFrame:SetParent(dropdown)
    CombuTextureBorderFrame:SetFrameLevel(_G[dropdown:GetName().."Button"]:GetFrameLevel()+1)
    CombuTextureBorderFrame:SetScale(1.3)
    
    for i = 1,#CombuTextureList do
        
        CreateFrame("button", "CombuTexture"..i, CombuTextureFrame, "CombuTextureTemplate")
        
        if i == 1 then
            CombuTexture1:ClearAllPoints()
            CombuTexture1:SetPoint("TOP",CombuTextureFrame,"TOP",0,0)
        else _G["CombuTexture"..i]:ClearAllPoints()
             _G["CombuTexture"..i]:SetPoint("TOP",_G["CombuTexture"..i-1],"BOTTOM",0,0)
        end
        
        _G["CombuTexture"..i.."Bar"]:SetTexture(CombuLSM:Fetch("statusbar",CombuTextureList[i]))
        _G["CombuTexture"..i.."Bar"]:SetVertexColor(unpack(combusettingstable["barcolornormal"]))
        _G["CombuTexture"..i.."Text"]:SetText(CombuTextureList[i])
        
        if (CombuTextureList[i]) == combusettingstable[settings] then
            _G["CombuTexture"..i.."Text"]:SetTextColor(1,0.8,0.2,1)
        else _G["CombuTexture"..i.."Text"]:SetTextColor(1,1,1,1)
        end
        
    end
    
end
            
function CombuCreateFontList()

    CombuFontList = {} for k in pairs(CombuLSM:HashTable("font")) do tinsert(CombuFontList,k) end
    
    CombuFontBorderFrame:Show()
    CombuFontBorderFrame:ClearAllPoints()
    CombuFontFrame:SetHeight(#CombuFontList*15)
    CombuFontBorderFrame:SetPoint("CENTER",CombuFontDropDown,"CENTER",0,0-(CombuFontFrame:GetHeight()/4))
    CombuFontBorderFrame:SetParent(CombuFontDropDown)
    CombuFontBorderFrame:SetFrameLevel(CombuFontDropDownButton:GetFrameLevel()+1)
    CombuFontBorderFrame:SetScale(1.3)
 
    for i = 1,#CombuFontList do
    
        CreateFrame("button", "CombuFont"..i, CombuFontFrame, "CombuFontTemplate")
        
        if i == 1 then
            CombuFont1:ClearAllPoints()
            CombuFont1:SetPoint("TOP",CombuFontFrame,"TOP",0,0)
        else _G["CombuFont"..i]:ClearAllPoints()
             _G["CombuFont"..i]:SetPoint("TOP",_G["CombuFont"..i-1],"BOTTOM",0,0)
        end
        
        _G["CombuFont"..i.."Bar"]:SetTexture(CombuLSM:Fetch("statusbar",combusettingstable["combutexturename"]))
        _G["CombuFont"..i.."Bar"]:SetVertexColor(unpack(combusettingstable["barcolornormal"]))
        _G["CombuFont"..i.."Text"]:SetText(CombuFontList[i])
        _G["CombuFont"..i.."Text"]:SetFont(CombuLSM:Fetch("font",CombuFontList[i]),9)
        
        if CombuFontList[i] == combusettingstable["combufontname"] then
            _G["CombuFont"..i.."Text"]:SetTextColor(1,0.8,0.2,1)
        else _G["CombuFont"..i.."Text"]:SetTextColor(1,1,1,1)
        end
    
    end
    
end

function CombuCreateSoundList()

    CombuSoundList = {} for k in pairs(CombuLSM:HashTable("sound")) do tinsert(CombuSoundList,k) end
    
    CombuSoundBorderFrame:Show()
    CombuSoundBorderFrame:ClearAllPoints()
    CombuSoundFrame:SetHeight(#CombuSoundList*15)
    CombuSoundBorderFrame:SetPoint("CENTER",CombuSoundDropDown,"CENTER",0,0-(CombuSoundFrame:GetHeight()/4))
    CombuSoundBorderFrame:SetParent(CombuSoundDropDown)
    CombuSoundBorderFrame:SetFrameLevel(CombuSoundDropDownButton:GetFrameLevel()+1)
    CombuSoundBorderFrame:SetScale(1.3)
 
    for i = 1,#CombuSoundList do
    
        CreateFrame("button", "CombuSound"..i, CombuSoundFrame, "CombuSoundTemplate")
        _G["CombuSound"..i]:SetID(i)
        
        if i == 1 then
            CombuSound1:ClearAllPoints()
            CombuSound1:SetPoint("TOP",CombuSoundFrame,"TOP",0,0)
        else _G["CombuSound"..i]:ClearAllPoints()
             _G["CombuSound"..i]:SetPoint("TOP",_G["CombuSound"..i-1],"BOTTOM",0,0)
        end
        
        _G["CombuSound"..i.."Text"]:SetText(CombuSoundList[i])
        
        if CombuSoundList[i] == combusettingstable["combusoundname"] then
            _G["CombuSound"..i.."Text"]:SetTextColor(1,0.8,0.2,1)
        else _G["CombuSound"..i.."Text"]:SetTextColor(1,1,1,1)
        end
    
    end
    
end

function CombuCreateBorderList()

    CombuBorderList = {} for k in pairs(CombuLSM:HashTable("border")) do tinsert(CombuBorderList,k) end
       
    CombuEdgeBorderFrame:Show()
    CombuEdgeBorderFrame:ClearAllPoints()
    CombuEdgeFrame:SetHeight(#CombuBorderList*32)
    CombuEdgeBorderFrame:SetPoint("CENTER",CombuBorderDropDown,"CENTER",0,0-(CombuEdgeFrame:GetHeight()/4))
    CombuEdgeBorderFrame:SetParent(CombuBorderDropDown)
    CombuEdgeBorderFrame:SetFrameLevel(CombuBorderDropDownButton:GetFrameLevel()+1)
    CombuEdgeBorderFrame:SetScale(1.3)
    
    for i = 1,#CombuBorderList do
    
        CreateFrame("button", "CombuBorder"..i, CombuEdgeFrame, "CombuEdgeTemplate")
        
        if i == 1 then
            CombuBorder1:ClearAllPoints()
            CombuBorder1:SetPoint("TOP",CombuEdgeFrame,"TOP",0,0)
        else _G["CombuBorder"..i]:ClearAllPoints()
             _G["CombuBorder"..i]:SetPoint("TOP",_G["CombuBorder"..i-1],"BOTTOM",0,0)
        end
        
        _G["CombuBorder"..i.."Bar"]:SetTexture(CombuLSM:Fetch("border",CombuBorderList[i]))
        _G["CombuBorder"..i.."Bar"]:SetVertexColor(unpack(combusettingstable["edgecolornormal"]))
        _G["CombuBorder"..i.."Text"]:SetText(CombuBorderList[i])
        
        if CombuBorderList[i] == combuBorder then
            _G["CombuBorder"..i.."Text"]:SetTextColor(1,0.8,0.2,1)
        else _G["CombuBorder"..i.."Text"]:SetTextColor(1,1,1,1)
        end
    
    end
    
end

function CombuCreateBackgroundList()

    CombuBackgroundList = {} for k in pairs(CombuLSM:HashTable("background")) do tinsert(CombuBackgroundList,k) end
     
    CombuBgBorderFrame:Show()
    CombuBgBorderFrame:ClearAllPoints()
    CombuBgFrame:SetHeight(#CombuBackgroundList*30)
    CombuBgBorderFrame:SetPoint("CENTER",CombuBackgroundDropDown,"CENTER",0,0-(CombuBgFrame:GetHeight()/4))
    CombuBgBorderFrame:SetParent(CombuBackgroundDropDown)
    CombuBgBorderFrame:SetFrameLevel(CombuBackgroundDropDownButton:GetFrameLevel()+1)
    CombuBgBorderFrame:SetScale(1.3)
    
    for i = 1,#CombuBackgroundList do
    
        CreateFrame("button", "CombuBackground"..i, CombuBgFrame, "CombuBgTemplate")
        
        if i == 1 then
            CombuBackground1:ClearAllPoints()
            CombuBackground1:SetPoint("TOP",CombuBgFrame,"TOP",0,0)
        else _G["CombuBackground"..i]:ClearAllPoints()
             _G["CombuBackground"..i]:SetPoint("TOP",_G["CombuBackground"..i-1],"BOTTOM",0,0)
        end
        
        _G["CombuBackground"..i.."Bar"]:SetTexture(CombuLSM:Fetch("background",CombuBackgroundList[i]))
        _G["CombuBackground"..i.."Text"]:SetText(CombuBackgroundList[i])
        
        if CombuBackgroundList[i] == combuBackground then
            _G["CombuBackground"..i.."Text"]:SetTextColor(1,0.8,0.2,1)
        else _G["CombuBackground"..i.."Text"]:SetTextColor(1,1,1,1)
        end
    
    end
    
end
 
-------------------------------------
-- Autohide function
function CombustionAutohide()

	local combucombat = UnitAffectingCombat("player")
    local a5,b5,c5 = GetSpellCooldown(comb)
	
 	if (a5 == nil) then
	elseif combusettingstable["combuautohide"] == 1 and combufaded == true then -- condition when autohide is disabled
    --print(1)
		combufaded = false
        table.wipe(LibTransition.tQueue) table.wipe(LibTransition.cQueue) -- stop the Libtransition queue
		CombustionFrame:FadeIn(combusettingstable["combufadeinspeed"])
        
	elseif combucombat == nil and combufaded == false and combusettingstable["combuautohide"] ~= 1 then -- condition when not in combat and CH is visible
    --print(2)
		combufaded = true
		CombustionFrame:FadeOut(combusettingstable["combufadeoutspeed"])
        
	elseif combusettingstable["combuautohide"] == 2 and combucombat == 1 and combufaded == true then -- condition when in combat
    --print(3)
		combufaded = false
        table.wipe(LibTransition.tQueue) table.wipe(LibTransition.cQueue)
		CombustionFrame:FadeIn(combusettingstable["combufadeinspeed"])
        
	elseif combusettingstable["combuautohide"] == 3 and combucombat == 1 and combufaded == true and ((a5 + b5 - GetTime()) <= (combusettingstable["combuafterfade"] + combusettingstable["combufadeinspeed"])) then -- condition when in combat and CB is up
    --print(4)
		combufaded = false
        table.wipe(LibTransition.tQueue) table.wipe(LibTransition.cQueue)
		CombustionFrame:FadeIn(combusettingstable["combufadeinspeed"])
        
	elseif combusettingstable["combuautohide"] == 3 and combucombat == 1 and combufaded == false and ((a5 + b5 - GetTime()) >= (combusettingstable["combuafterfade"] + combusettingstable["combufadeinspeed"])) and ((a5 + b5 - GetTime()) <= (b5 - combusettingstable["combubeforefade"])) then -- condition when in combat and CB is in cd
    --print(5)
		combufaded = true
		CombustionFrame:FadeOut(combusettingstable["combufadeoutspeed"],combusettingstable["combufadealpha"])
        CombustionFrame:Wait((a5 + b5 - GetTime())-combusettingstable["combufadeinspeed"]-combusettingstable["combuafterfade"])
        CombustionFrame:FadeIn(combusettingstable["combufadeinspeed"])
		StatusTextFrameLabel:SetText(CombuLabel["autohide"])
        
        if (combusettingstable["combuchat"]==true) then ChatFrame1:AddMessage(format(CombuLoc["autohidemess"], (a5 + b5 - GetTime())-combusettingstable["combufadeinspeed"]-combusettingstable["combuafterfade"]))
        end
    end
    
end

-----------------------------------
-- Ignite managing function
local function CombustionIgnite(event, spellId, spellSchool, amount, critical, destGUID)

	local a2,b2,c2,d2,e2,f2,g2,h2,i2,j2,k2 = UnitAura("target", ignite, nil, "PLAYER HARMFUL")
    
	if (k2==12654) then 
	combuignitetimer = (-1*(GetTime()-g2))
	else combuignitetimer = 0
	end
	
    if (event == "SPELL_DAMAGE") and ((spellSchool == 4) or (spellSchool == 20)) and ((spellId == 133) or (spellId == 44614) or (spellId == 2948) or (spellId == 11366) or (spellId == 108853)) then

        combuigniteamount = ceil(amount / (100/GetMasteryEffect()))
		combuignitevalue = combuignitevalue + combuigniteamount

        combucrittarget = destGUID

	elseif (event == "SPELL_PERIODIC_DAMAGE") and (spellId == 12654) then
                            
	    combuigniteapplied = combuigniteapplied + amount
                            
	elseif (combucrittarget ~= UnitGUID("target")) or (UnitGUID("target") == nil) or ((event == "SPELL_AURA_REMOVED") and (spellId == 12654)) then
		IgniteLabel:SetText(format(CombuLabel["ignite"]))
		combuigndamage = 0
	end
    
    
    if (combusettingstable["combureport"] == true) and select(14, UnitDebuff("target",GetSpellInfo(12654),nil,"PLAYER")) then 
        combuigndamage = select(14, UnitDebuff("target",GetSpellInfo(12654),nil,"PLAYER"))
        IgniteLabel:SetText(format(CombuLabel["dmgwhite0"], combuigndamage))
    else combuigndamage = 0
    end

	if (combuignitetimer >= combusettingstable["combutimervalue"]) and (combuignitetimer ~= 0) then -- condition when timer is with more than 2 seconds left
		IgnTextFrameLabel:SetText(format("|cff00ff00%.1f|r",combuignitetimer))
		IgniteButton:SetTexture("Interface\\AddOns\\CombustionHelper\\Images\\Combustionon")
		IgnTime = 1
	elseif (combuignitetimer <= combusettingstable["combutimervalue"]) and (combuignitetimer ~= 0) then -- condition when timer is with less than 2 seconds left
		IgnTextFrameLabel:SetText(format("|cffff0000%.1f|r",combuignitetimer))
		IgniteButton:SetTexture("Interface\\AddOns\\CombustionHelper\\Images\\Combustionon")
		IgnTime = 0
	else IgnTextFrameLabel:SetText(format(CombuLabel["ignshort"]))
		IgniteButton:SetTexture("Interface\\AddOns\\CombustionHelper\\Images\\Combustionoff") -- Text in red
		IgnTime = 0
	end
		
	if (combusettingstable["combubartimers"] == true) then
		if (k2==12654) and (combuignitetimer <= combusettingstable["combutimervalue"]) then 
			Ignbar:Show()
			Ignbar:SetValue(100*((g2-GetTime())/f2))
			Ignbar:SetStatusBarColor(unpack(combusettingstable["barcolorwarning"]))
		elseif (k2==12654) then 
			Ignbar:Show()
			Ignbar:SetValue(100*((g2-GetTime())/f2))
			Ignbar:SetStatusBarColor(unpack(combusettingstable["barcolornormal"]))
		else Ignbar:Hide()
		end
	end
		
end

function CombustionPredict()

	if select(1,UnitAura("target",pyro1,nil,"HARMFUL")) then
		
		combupyrodps = 112.333 + (0.12 * GetSpellBonusDamage(3))
	
	else combupyrodps = 0
	end

	if combuigndamage > 0 then
	
		combuigndps = (combuigndamage/2)
	
	else combuigndps = 0
	
	end
	
	combuexpectedtickdmg = combupyrodps + combuigndps
	
--	((0.12 * GetSpellBonusDamage(3)) + 112.333 + (combuigndamage/2))
	
    combucurrenthaste = UnitSpellHaste("player") * 128.05701
	
	for i = 2,#combuhasteplateau do
		
		if combucurrenthaste < (combuhasteplateau[i])[1] then
			combuhastetick = (combuhasteplateau[i-1])[2]
			break
		end
	end
    
	if combuglyph == 1 then

        combuhastetick = combuhastetick *2
    
    end
    
	combustiontime = GetTime()
	
--	print(format("Tick : %.0f x %0.f",combuexpectedtickdmg,combuhastetick))
	return format("Tick : %.0f x %0.f",combuexpectedtickdmg,combuhastetick)
		
end

function CombuGlyphCheck ()

    for i = 1, NUM_GLYPH_SLOTS do 
     
        local en, g, l, spellid, ic = GetGlyphSocketInfo(i);
        
        if spellid == 56368 then 
            
            combuglyph = 1
            break
            
        else combuglyph = 0
        end
        
    end
    
end

-------------------------------------------------------------------------------------------------------	
-------------------------------------------------------------------------------------------------------	
-------------------------------- ON_EVENT FUNCTION ----------------------------------------------------

function Combustion_OnEvent(self, event, ...)

    if (event == "PLAYER_LOGIN") then
    	
    	CombuSavedVariablesConvert ()
    	CombuClientVersionCheck()
        CombuGlyphCheck ()
               
	    if (CombustionFrame:GetFrameLevel() == 0) then
	        CombustionFrame:SetFrameLevel(1) -- fix when frame is at FrameLevel 0
	    end
	    
	    if (combusettingstable["combuchat"]==true) then ChatFrame1:AddMessage(CombuLoc["startup"]) end
    
-------------------------------
--Combustion spell check on startup    
        local a6 = IsSpellKnown(11129) -- check if combustion is in the spellbook
                
        if (a6 == false) 
	        then combufaded = true
	        	 CombustionFrame:FadeOut(combusettingstable["combufadeoutspeed"],combusettingstable["combufadealpha"])
	             combutalent = false
        elseif (a6 == true) 
	        then combufaded = false
	        	 CombustionFrame:FadeIn(combusettingstable["combufadeinspeed"])
	             combutalent = true
        end
        
-------------------------------
--Frame lock check on startup
        if (combusettingstable["combulock"] == false) 
	 		then CombustionFrame:EnableMouse(true)
        elseif (combusettingstable["combulock"] == true) 
	    	then CombustionFrame:EnableMouse(false)
        end	
               	
        CombuLanguageCheck()
	    CombustionScale (combusettingstable["combuscale"]) -- Scale check on startup
	    CombustionFrameresize() -- Combustion Frame size check on startup    

    end
	
-------------------------------
--Combustion spell check      
    if (event == "PLAYER_TALENT_UPDATE") then
    	
    	CombuClientVersionCheck()
        CombuGlyphCheck ()
      
        local a6 = IsSpellKnown(11129) -- check if combustion is in the spellbook
            
        if (a6 == false) and (combutalent == true) then
        		combufaded = true
                CombustionFrame:FadeOut(combusettingstable["combufadeoutspeed"],combusettingstable["combufadealpha"])
                combutalent = false
                if (combusettingstable["combuchat"]==true) then ChatFrame1:AddMessage(CombuLoc["combuon"]) end
        elseif (a6 == true) and (combutalent == false) then
        		combufaded = false
                CombustionFrame:FadeIn(combusettingstable["combufadeinspeed"])
                combutalent = true
                if (combusettingstable["combuchat"]==true) then ChatFrame1:AddMessage(CombuLoc["combuoff"]) end
                CombustionFrameresize()
        end
                
    end
        
-------------------------------
--Combat log events checks
    if (event=="COMBAT_LOG_EVENT_UNFILTERED") then

    	timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical = select(1, ...)
            
            if (sourceName == UnitName("player")) then --print(spellId,event)
            
---------------------------------
-- Ignite prediction part                
                if (destGUID == UnitGUID("target")) then --print(timestamp,event,sourceName,spellName,destName,amount)
                    CombustionIgnite( event, spellId, spellSchool, amount, critical, destGUID)
                end

-------------------------------------------
-- report event check 
				if (combusettingstable["combureport"] == true) and (destGUID == UnitGUID("target")) then
					if (spellId == lvbID) and (event == "SPELL_PERIODIC_DAMAGE") then -- LB damage
						if (critical == 1) and (combumeta == true) then 
							combulbdamage = amount/2,03
						elseif (critical == 1) and (combumeta == false) then 
							combulbdamage = amount/2
						else combulbdamage = amount
						end
						LBLabel:SetText(format(CombuLabel["dmgwhite0"], combulbdamage))
					elseif ((spellId == 11366) and (event == "SPELL_PERIODIC_DAMAGE")) or ((spellId == 92315) and (event == "SPELL_PERIODIC_DAMAGE")) then -- pyroblast damage
						if (critical == 1) and (combumeta == true) then 
							combupyrodamage = amount/2,03
						elseif (critical == 1) and (combumeta == false) then 
							combupyrodamage = amount/2
						else combupyrodamage = amount
						end
						PyroLabel:SetText(format(CombuLabel["dmgwhite0"], combupyrodamage))
					end
				end
                
-------------------------------------------
-- Pyroblast buff report 
                if (combusettingstable["combureportpyro"] == true) then --if (spellId == 48108) or (spellId == 11366) then print(spellId, event) end
                --	if (spellId == 48108) and (event == "SPELL_AURA_APPLIED")
	            --        then combupyrogain = combupyrogain + 1
	            --    else
                    if (spellId == 48108) and (event == "SPELL_AURA_REFRESH")
	                    then combupyrorefresh = combupyrorefresh + 1  
	                    	print(format(CombuLoc["pyrorefresh"]))
				--	elseif (spellId == 11366) then print(11366, event)--and (event == "SPELL_CAST_START"))  
	                    --then combupyrocast = combupyrocast + 1
	                end
	            end
	            
-------------------------------------------
-- Combustion damage report
	
				if spellId == 83853 then --print(event,spellId)
					if event == "SPELL_PERIODIC_DAMAGE" then 
						combucombustiondmg = combucombustiondmg + amount
                        combuticks = combuticks + 1
                        if not critical then 
                            combutickdmg = amount
                        end 
                        --print(combuticks, combucombustiondmg)
					end 
                    if not combutargetstable[destGUID] then
                        combutargetstable[destGUID] = 1
                        combutargets = combutargets + 1
                    end
				elseif spellId == 11129 then
					if event == "SPELL_CAST_SUCCESS" then --print(event,spellId)
						combucombustionprevdmg = combucombustiondmg
						combucombustiondmg = 0
						combutimestamp = GetTime()
                        combuprevticks = combuticks
                        combuticks = 0
                        combutickprevdmg = combutickdmg
                        combutickdmg = 0
                        combuprevtargets = combutargets
                        combutargets = 0
                        combutargetstable = {}
                                                
                    elseif event == "SPELL_DAMAGE" then --print(event,spellId)
						combucombustiondmg = combucombustiondmg + amount
					end
				end
	            
	            
            end
            
    end
                
-------------------------------------------
-- Start and End of fight events 
    if (event == "PLAYER_REGEN_DISABLED") then 
    	
    	local gem1, gem2, gem3 = GetInventoryItemGems(1)
        
		if CombuCritMeta[gem1] or CombuCritMeta[gem2] or CombuCritMeta[gem3] 
			then combumeta = true
		else combumeta = false
		end  
		
        CombustionVarReset()
        CombustionAutohide()
        
		combucombustiondmg = 0
		combuticks = 0
		combutickdmg = 0
		combutargets = 0
		combutargetstable = {}
		    
    elseif (event == "PLAYER_REGEN_ENABLED") then 
    
    	if (combusettingstable["combureportmunching"] == true) and (combuignitevalue ~= 0) and GetSpecialization() == 2 then 
            print(format(CombuLoc["ignrep"],combuignitevalue,combuigniteapplied,format("%.0f / %.0f%%",combuignitevalue-combuigniteapplied,(combuignitevalue-combuigniteapplied)/combuignitevalue*100)))
        end
    	    
        if (combusettingstable["combureportpyro"] == true) and (combupyrorefresh ~= 0) then
            print(format(CombuLoc["pyroreport"],combupyrorefresh))
        end

		CombustionVarReset()
		        
		IgniteLabel:SetText(format(CombuLabel["ignite"]))
        
    end

end
	
	
-------------------------------------------------------------------------------------------------------	
-------------------------------------------------------------------------------------------------------	
-------------------------------- ON_UPDATE FUNCTION ----------------------------------------------------

function Combustion_OnUpdate(self, elapsed)
    self.TimeSinceLastUpdate = (self.TimeSinceLastUpdate or 0) + elapsed;
 
		if (self.TimeSinceLastUpdate > Combustion_UpdateInterval) then
            local time = GetTime()   
            
-------------------------------
--Living Bomb part
            local a,b,c,d,e,f,g,h,i,j,k = UnitAura("target", lvb, nil, "PLAYER HARMFUL")		
            
            if (k==lvbID) then 
                combulbtimer = (-1*(time-g))
            else combulbtimer = 0
                combulbdamage = 0
            end
            
            if (combulbtimer >= combusettingstable["combutimervalue"]) and (combulbtimer ~= 0) then -- condition when timer is with more than 2 seconds left
                LBTextFrameLabel:SetText(format("|cff00ff00%.1f|r",combulbtimer))
                LBButton:SetTexture("Interface\\AddOns\\CombustionHelper\\Images\\Combustionon")
                LBTime = 1
            elseif (combulbtimer <= combusettingstable["combutimervalue"]) and (combulbtimer ~= 0) then -- condition when timer is with less than 2 seconds left
                LBTextFrameLabel:SetText(format("|cffff0000%.1f|r",combulbtimer))
                LBButton:SetTexture("Interface\\AddOns\\CombustionHelper\\Images\\Combustionon")
                LBTime = 0
            else LBTextFrameLabel:SetText(format(CombuLabel["lbshort"])) 
                LBButton:SetTexture("Interface\\AddOns\\CombustionHelper\\Images\\Combustionoff") -- Text in red
                LBLabel:SetText(CombuLabel["lb"])
                LBTime = 0
            end
                
            if (combusettingstable["combubartimers"] == true) and (k==lvbID) and (combulbtimer <= combusettingstable["combutimervalue"]) then
                LBbar:Show()
                LBbar:SetValue(100*((g-GetTime())/f))
                LBbar:SetStatusBarColor(unpack(combusettingstable["barcolorwarning"]))
            elseif (combusettingstable["combubartimers"] == true) and (k==lvbID) then 
                LBbar:Show()
                LBbar:SetValue(100*((g-GetTime())/f))
                LBbar:SetStatusBarColor(unpack(combusettingstable["barcolornormal"]))
            else LBbar:Hide()
            end

--------------------------------
--Ignite part

            CombustionIgnite()
			
--------------------------------
--Pyroblast part
            local a3,b3,c3,d3,e3,f3,g3,h3,i3,j3,k3 = UnitAura("target", pyro1, nil, "PLAYER HARMFUL")		
                        
            if (k3==11366) then 
                combupyrotimer = (-1*(time-g3))
            else combupyrotimer = 0
                combupyrodamage = 0
            end
            
            if (combupyrotimer >= combusettingstable["combutimervalue"]) and (combupyrotimer ~= 0) then -- condition when timer is with more than 2 seconds left
                PyroTextFrameLabel:SetText(format("|cff00ff00%.1f|r",combupyrotimer))
                PyroButton:SetTexture("Interface\\AddOns\\CombustionHelper\\Images\\Combustionon")
                PyroTime = 1
            elseif (combupyrotimer <= combusettingstable["combutimervalue"]) and (combupyrotimer ~= 0) then -- condition when timer is with less than 2 seconds left
                PyroTextFrameLabel:SetText(format("|cffff0000%.1f|r",combupyrotimer))
                PyroButton:SetTexture("Interface\\AddOns\\CombustionHelper\\Images\\Combustionon")
                PyroTime = 0
            else PyroTextFrameLabel:SetText(format(CombuLabel["pyroshort"]))
                PyroButton:SetTexture("Interface\\AddOns\\CombustionHelper\\Images\\Combustionoff") -- Text in red
                PyroLabel:SetText(format(CombuLabel["pyroblast"]))
                PyroTime = 0
            end
                            
            if (combusettingstable["combubartimers"] == true) and (k3==11366) and (combupyrotimer <= combusettingstable["combutimervalue"]) then 
                Pyrobar:Show()
                Pyrobar:SetValue(100*((g3-GetTime())/f3))
                Pyrobar:SetStatusBarColor(unpack(combusettingstable["barcolorwarning"]))
            elseif (combusettingstable["combubartimers"] == true) and (k3==11366) then 
                Pyrobar:Show()
                Pyrobar:SetValue(100*((g3-GetTime())/f3))
                Pyrobar:SetStatusBarColor(unpack(combusettingstable["barcolornormal"]))
            else Pyrobar:Hide()
            end
		
--------------------------------
--Combustion/impact part
            local a5,b5,c5 = GetSpellCooldown(comb)
                    
            if (b5 == nil) then
            elseif (InCombatLockdown() == 1) and (b5<=2) and combusettingstable["combutickpredict"] == true then -- Combustion damage predicter
            
                 StatusTextFrameLabel:SetText(CombustionPredict())
                 CombustionUp = 1
                 
            elseif (b5<=2) and (combusettingstable["combureport"] == true) and (InCombatLockdown() == 1) then 
            
                CombustionUp = 1
                combufadeout = false
                combuchatautohide = 0 
                if (combusettingstable["combureportvalue"] <= combuigndamage) and combusettingstable["combureportthreshold"] then
                    StatusTextFrameLabel:SetText(format(CombuLabel["ignCBgreen"], combuigndamage))
                else StatusTextFrameLabel:SetText(format(CombuLabel["ignCBred"], combuigndamage))
                end
                
            elseif (b5<=2) then -- condition when combustion cd is up, taking gcd in account
            
                StatusTextFrameLabel:SetText(CombuLabel["combup"])
                CombustionUp = 1
                combufadeout = false
                combuchatautohide = 0
                
            else 
            
				if b5 > 2 and combustiontime + 5 > GetTime() then
				elseif ((a5 + b5 - time)>=60) and (combufadeout == false) then -- timer for combustion in minutes
					StatusTextFrameLabel:SetText(format(CombuLabel["combmin"],(a5 + b5 - time) / 60,(a5 + b5 - time) % 60 ))  
					CombustionUp = 0
				elseif ((a5 + b5 - time)<=60) then 
					StatusTextFrameLabel:SetText(format(CombuLabel["combsec"],(a5 + b5 - time)))  -- timer for combustion in seconds
					CombustionUp = 0	
				end
				
			end

--------------------------------
-- Combustion on target tracking
    if (combusettingstable["combutrack"]==true) then
            
            local a11,b11,c11,d11,e11,f11,g11,h11,i11,j11,k11 = UnitAura("target", combudot, nil, "PLAYER HARMFUL")
			
			if f11 and combucurrentduration == 0 then combucurrentduration = f11 end
			
			if (k11==83853) then combudottimer = (-1*(time-g11))
			else combudottimer = 0
			end

			if (k11==83853) and (combudottimer <= combusettingstable["combutimervalue"])
				then Combubar:Show()
                 Combubar:SetValue(100*((g11-GetTime())/f11))
                 Combubar:SetStatusBarColor(unpack(combusettingstable["barcolorwarning"]))
			elseif (k11==83853)
				then Combubar:Show()
                 Combubar:SetValue(100*((g11-GetTime())/f11))
                 Combubar:SetStatusBarColor(unpack(combusettingstable["barcolornormal"]))
            else Combubar:Hide()
			end
			
			if combutimestamp and GetTime() >= (combutimestamp + combucurrentduration + 2) then
				if combucombustionprevdmg == 0 then
					print(format(CombuLoc["combureport1"],combucombustiondmg,combuticks,combutickdmg,combutargets))
					combutimestamp = nil
				else print(format(CombuLoc["combureport1"],combucombustiondmg,combuticks,combutickdmg,combutargets))
                    print(format(CombuLoc["combureport2"],combucombustionprevdmg,combuprevticks,combutickprevdmg,combuprevtargets))
					combutimestamp = nil
				end
			end
    end
    
--------------------------------
-- Background/border colors settings

    if (combusettingstable["pyromaniac"] == true) and UnitDebuff("target", GetSpellInfo(132210)) == nil and InCombatLockdown() and (UnitIsEnemy("player","target")) then
        
        CombustionFrame:SetBackdropColor(unpack(combusettingstable["bgcolorwarning"]))
        
    elseif (combusettingstable["combureportthreshold"] == true) and (CombustionUp == 1) and (combusettingstable["combureportvalue"] <= combuigndamage) and (combusettingstable["combureportvalue"] ~= 0) then
        
        CombustionFrame:SetBackdropColor(unpack(combusettingstable["bgcolorcombustion"])) --Green background for frame when threshold is met and combustion are up
        CombustionFrame:SetBackdropBorderColor(unpack(combusettingstable["bgcolorcombustion"]))
        
        if combusettingstable["thresholdalert"] == true then
            PlaySoundFile(CombuLSM:Fetch("sound",combusettingstable["combusoundname"]))
        end
                 
    elseif (IgnTime == 1) and (PyroTime == 1) and (CombustionUp == 1) and (combusettingstable["combureportthreshold"] == false) then
    
        CombustionFrame:SetBackdropColor(unpack(combusettingstable["bgcolorcombustion"])) --Green bg for frame when dots and combustion are up
        CombustionFrame:SetBackdropBorderColor(unpack(combusettingstable["bgcolorcombustion"]))
             
    elseif  (combusettingstable["hotstreak"] == true) and UnitAura("player", GetSpellInfo(48107)) and select(2,GetSpellCooldown(GetSpellInfo(108853))) < 2 then
    
        CombustionFrame:SetBackdropColor(unpack(combusettingstable["bgcolorimpact"]))
        CombustionFrame:SetBackdropBorderColor(unpack(combusettingstable["bgcolorimpact"]))
        
    else CombustionFrame:SetBackdropColor(unpack(combusettingstable["bgcolornormal"]))
         CombustionFrame:SetBackdropBorderColor(unpack(combusettingstable["edgecolornormal"]))
    end
    
--------------------------------
 -- autohide part 
 
    CombustionAutohide()
    
--------------------------------
    self.TimeSinceLastUpdate = 0

    end    
end


SLASH_COMBUCONFIG1 = "/combustionhelper"

SlashCmdList["COMBUCONFIG"] = function(msg)

	if msg == "" or  msg == "help" or  msg == "?" or msg == "config" then
		 InterfaceOptionsFrame_OpenToCategory("CombustionHelper")
		 if (combusettingstable["combuchat"]==true) then print(format(CombuLoc["slashcomm"])) end
	else
		 InterfaceOptionsFrame_OpenToCategory("CombustionHelper")
		 if (combusettingstable["combuchat"]==true) then print(format(CombuLoc["slashcomm"])) end
	end

end