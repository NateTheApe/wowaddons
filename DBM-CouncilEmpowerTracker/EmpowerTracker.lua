--Needs to be global, making name somwhat unique
EPIC_empowerTracker = CreateFrame("Frame")

EPIC_empowerTracker.mod = nil
EPIC_empowerTracker.COUNCIL_MOD_ID = "816"
EPIC_empowerTracker.ZONE_ID = 930

EPIC_empowerTracker.empoweredMob = nil
EPIC_empowerTracker.lastEmpoweredMob = nil
EPIC_empowerTracker.healthRemaining = 0
EPIC_empowerTracker.healthToBreak = 0
EPIC_empowerTracker.maxHealth = 0
EPIC_empowerTracker.died = false
EPIC_empowerTracker.dead = 0

EPIC_empowerTracker.debug = false
EPIC_empowerTracker.debugOutput = ""
EPIC_empowerTracker.debugIndex = 0
EPIC_empowerTracker.combatStartFired = false

EPIC_empowerTracker.baseMultipler = (1/4)
EPIC_empowerTracker.extraMultipler = (5/6)

function EPIC_empowerTracker:GetEmpowerHP()
	return math.max(1, math.floor(EPIC_empowerTracker.healthRemaining / EPIC_empowerTracker.healthToBreak * 100))
end

function EPIC_empowerTracker:CombatLogHandler(event, timestamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
	if event == "ZONE_CHANGED_NEW_AREA" then
		EPIC_empowerTracker:ZONE_CHANGED_NEW_AREA()
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		if EPIC_empowerTracker.empoweredMob ~= nil and EPIC_empowerTracker.empoweredMob == destGUID then
			local healthChange = 0
			if subEvent == "SPELL_HEAL" then
				healthChange = select( 4, ...)
			elseif subEvent == "SPELL_DAMAGE" then
				healthChange = -select( 4, ...)
			elseif subEvent == "RANGED_DAMAGE" then
				healthChange = -select( 4, ...)
			elseif subEvent == "SWING_DAMAGE" then
				healthChange = -select( 1, ...)
			elseif subEvent == "SPELL_PERIODIC_DAMAGE" then
				healthChange = -select( 3, ...)
			elseif subEvent == "SPELL_BUILDING_DAMAGE" then
				healthChange = -select( 3, ...)
			elseif subEvent == "ENVIRONMENTAL_DAMAGE" then
				healthChange = -select( 2, ...)
			end
			
			EPIC_empowerTracker.healthRemaining = EPIC_empowerTracker.healthRemaining + healthChange
		end
	end
end

function EPIC_empowerTracker:AttachToDBM()
	for i, v in ipairs(DBM.Mods) do
		if v.id == EPIC_empowerTracker.COUNCIL_MOD_ID then
			EPIC_empowerTracker.mod = v;
		end
	end
	
	if EPIC_empowerTracker.mod ~= nil then
		EPIC_empowerTracker.mod:AddBoolOption("HealthFrame", true)
		
		EPIC_empowerTracker.mod:SetBossHealthInfo(69078, "Sul the Sandcrawler",
												  69132, "High Prestess Mar'li",
												  69134, "Frost King Malakk",
												  69131, "Kazra'jin")
		
		EPIC_empowerTracker.mod.OLD_OnCombatStart = EPIC_empowerTracker.mod.OnCombatStart
		EPIC_empowerTracker.mod.OLD_OnCombatEnd = EPIC_empowerTracker.mod.OnCombatEnd
		EPIC_empowerTracker.mod.OLD_SPELL_AURA_APPLIED = EPIC_empowerTracker.mod.SPELL_AURA_APPLIED
		EPIC_empowerTracker.mod.OLD_SPELL_AURA_REMOVED = EPIC_empowerTracker.mod.SPELL_AURA_REMOVED
		EPIC_empowerTracker.mod.OLD_UNIT_DIED = EPIC_empowerTracker.mod.UNIT_DIED
		
		EPIC_empowerTracker.mod.OnCombatStart = EPIC_empowerTracker.OnCombatStart
		EPIC_empowerTracker.mod.OnCombatEnd = EPIC_empowerTracker.OnCombatEnd
		EPIC_empowerTracker.mod.SPELL_AURA_APPLIED = EPIC_empowerTracker.SPELL_AURA_APPLIED
		EPIC_empowerTracker.mod.SPELL_AURA_REMOVED = EPIC_empowerTracker.SPELL_AURA_REMOVED
		EPIC_empowerTracker.mod.UNIT_DIED = EPIC_empowerTracker.UNIT_DIED
		
		EPIC_empowerTracker:UnregisterEvent("ZONE_CHANGED_NEW_AREA");
	else
		print("Could not attach to DBM's Council of Elders mod. If you are sure the DBM addon is loaded please contact this addon's creator.")
	end
end

function EPIC_empowerTracker:OnCombatStart(delay)
	EPIC_empowerTracker.combatStartFired = true

	if EPIC_empowerTracker.debug then
		EPIC_empowerTracker:DebugMessage("\n\n")
	else
		EPIC_empowerTracker.debugOutput = ""
		EPIC_empowerTracker.debugIndex = 0
	end
	EPIC_empowerTracker:DebugMessage("Health Break Log for " .. DBM:GetCurrentInstanceDifficulty())
	
	EPIC_empowerTracker.mod:OLD_OnCombatStart(delay)
end

function EPIC_empowerTracker:OnCombatEnd()
	EPIC_empowerTracker.mod:OLD_OnCombatEnd()
	
	if EPIC_empowerTracker.debug then
		if EPIC_empowerTracker.combatStartFired ~= true then
			EPIC_empowerTracker.debugOutput = "StartCombat was not triggered\nHealth Break Log for " .. DBM:GetCurrentInstanceDifficulty() .. EPIC_empowerTracker.debugOutput
		end
		print(EPIC_empowerTracker.debugOutput:sub(EPIC_empowerTracker.debugIndex))
		EPIC_empowerTracker.debugIndex = EPIC_empowerTracker.debugOutput:len() + 1
	end
end

function EPIC_empowerTracker:PrintDebug(msg)
	print(EPIC_empowerTracker.debugOutput)
end

function EPIC_empowerTracker:CopyDebug(msg)
	
end

function EPIC_empowerTracker:ClearDebug(msg)
	EPIC_empowerTracker.debugOutput = ""
	EPIC_empowerTracker.debugIndex = 0
end

function EPIC_empowerTracker:DebugMessage(msg)
	EPIC_empowerTracker.debugOutput = EPIC_empowerTracker.debugOutput .. msg
end
	
function EPIC_empowerTracker:ShowEmpowerHealthBar(self, mob, name)
	EPIC_empowerTracker:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	
	if EPIC_empowerTracker.maxHealth == 0 then
		EPIC_empowerTracker.maxHealth = UnitHealthMax("boss2") -- they all have the same health pool but boss2 makes sure that we don't see a loa, cause it might appear in boss1
		EPIC_empowerTracker.healthToBreak = EPIC_empowerTracker.maxHealth * EPIC_empowerTracker.baseMultipler * EPIC_empowerTracker.extraMultipler
	end
	
	EPIC_empowerTracker.empoweredMob = mob
	EPIC_empowerTracker.empoweredMobName = name
	EPIC_empowerTracker.healthRemaining = EPIC_empowerTracker.healthToBreak
	EPIC_empowerTracker.died = false
	
	DBM.BossHealth:RemoveBoss(EPIC_empowerTracker.GetEmpowerHP)
	DBM.BossHealth:AddBoss(EPIC_empowerTracker.GetEmpowerHP, "Empowerment")
end
	
function EPIC_empowerTracker:HideEmpowerHealthBar()
	DBM.BossHealth:RemoveBoss(EPIC_empowerTracker.GetEmpowerHP)
	EPIC_empowerTracker:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	
	if EPIC_empowerTracker.empoweredMob ~= nil then
		EPIC_empowerTracker:DebugMessage("\n" .. EPIC_empowerTracker.empoweredMobName .. ": ")
		if EPIC_empowerTracker.dead < 3 then
			EPIC_empowerTracker:DebugMessage(EPIC_empowerTracker.healthRemaining .. "/")
			EPIC_empowerTracker:DebugMessage(EPIC_empowerTracker.maxHealth .. " ")
			EPIC_empowerTracker:DebugMessage(100*(EPIC_empowerTracker.healthToBreak-EPIC_empowerTracker.healthRemaining)/EPIC_empowerTracker.maxHealth)
			EPIC_empowerTracker:DebugMessage("% (" .. EPIC_empowerTracker.healthToBreak .. ")")
		
			if EPIC_empowerTracker.died then
				EPIC_empowerTracker:DebugMessage(" Died before breaking")
			end
		else
			EPIC_empowerTracker:DebugMessage("Is the last mob, doesn't break")
		end
		
		EPIC_empowerTracker.lastEmpoweredMob = EPIC_empowerTracker.empoweredMob
		EPIC_empowerTracker.empoweredMob = nil
		EPIC_empowerTracker.died = false
	end
end

function EPIC_empowerTracker:ClearDead()
	EPIC_empowerTracker.died = false
end

function EPIC_empowerTracker:UNIT_DIED(args)
	if EPIC_empowerTracker.empoweredMob == args.destGUID then
		EPIC_empowerTracker.died = false
	elseif EPIC_empowerTracker.lastEmpoweredMob == args.destGUID then--Combatlog events out of order sometimes
		DBM:Schedule(1, EPIC_empowerTracker.ClearDead)
		EPIC_empowerTracker:DebugMessage(" May have Died before breaking")
	end
	
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 69078 or cid == 69132 or cid == 69131 or cid == 69134 then
		EPIC_empowerTracker.dead = EPIC_empowerTracker.dead + 1
		if EPIC_empowerTracker.dead == 3 then
			EPIC_empowerTracker:HideEmpowerHealthBar()
		end
	end
	
	EPIC_empowerTracker.mod:OLD_UNIT_DIED(args)
end

function EPIC_empowerTracker:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(136442) and EPIC_empowerTracker.dead < 3 then --Possessed
		EPIC_empowerTracker:HideEmpowerHealthBar()
	end
	EPIC_empowerTracker.mod:OLD_SPELL_AURA_REMOVED(args)
end

function EPIC_empowerTracker:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(136442) and EPIC_empowerTracker.dead < 3 then --Possessed and isn't the last one (last one doesn't end empower)
		EPIC_empowerTracker:ShowEmpowerHealthBar(EPIC_empowerTracker, args.destGUID, args.destName);
	end
	EPIC_empowerTracker.mod:OLD_SPELL_AURA_APPLIED(args)
end

function EPIC_empowerTracker:ZONE_CHANGED_NEW_AREA() --This code near exact with slight modification of DBM's load on demand code
	if EPIC_empowerTracker.mod ~= nil then
		--We are already attached and don't care, shouldn't happen anyways
		EPIC_empowerTracker:UnregisterEvent("ZONE_CHANGED_NEW_AREA");
		return
	end
	
	--Work around for the zone ID/area updating slow because the world map doesn't always have correct information on zone change
	--unless we apsolutely make sure we force it to right zone before asking for info.
	if WorldMapFrame:IsVisible() and not IsInInstance() then --World map is open and we're not in an instance, (such as flying from zone to zone doing archaeology)
		local C, Z = GetCurrentMapContinent(), GetCurrentMapZone()--Save current map settings.
		SetMapToCurrentZone()--Force to right zone
		LastZoneMapID = GetCurrentMapAreaID() or -1 --Set accurate zone area id into cache
		LastZoneText = GetRealZoneText() or "" --Do same with zone name.
		local C2, Z2 = GetCurrentMapContinent(), GetCurrentMapZone()--Get right info after we set map to right place.
		if C2 ~= C or Z2 ~= Z then
			SetMapZoom(C, Z)--Restore old map settings if they differed to what they were prior to forcing mapchange and user has map open.
		end
	else--Map isn't open, no reason to save/restore settings, just make sure the information is correct and that's it.
		SetMapToCurrentZone()
		LastZoneMapID = GetCurrentMapAreaID() --Set accurate zone area id into cache
		LastZoneText = GetRealZoneText() --Do same with zone name.
	end
	
	if LastZoneMapID == EPIC_empowerTracker.ZONE_ID then
		DBM:Schedule(10, EPIC_empowerTracker.AttachToDBM)
	end
end

SLASH_EMPOWERTRACKER1 = "/empt"
SLASH_EMPOWERTRACKER2 = "/empowertracker"
SlashCmdList["EMPOWERTRACKER"] = function(msg)
	if msg == "debug on" then
		EPIC_empowerTracker.debug = true
		print("Debuging Enabled")
	elseif msg == "debug off" then
		EPIC_empowerTracker.debug = false
		print("Debuging Disabled")
	elseif msg == "debug print" then
		EPIC_empowerTracker:PrintDebug()
	elseif msg == "debug copy" then
		EPIC_empowerTracker:CopyDebug()
	elseif msg == "debug clear" then
		EPIC_empowerTracker:ClearDebug()
	elseif msg == "mods" then
		print("Health Modifiers: " .. EPIC_empowerTracker.baseMultipler .. " * " .. EPIC_empowerTracker.extraMultipler .. " = " .. EPIC_empowerTracker.baseMultipler*EPIC_empowerTracker.extraMultipler)
	elseif msg:sub(1,7) == "set base" then
		EPIC_empowerTracker.baseMultipler = tonumber(msg:sub(9))
	elseif msg:sub(1,8) == "set extra" then
		EPIC_empowerTracker.extraMultipler = tonumber(msg:sub(10))
	else
		print("Unknown option")
	end
end

EPIC_empowerTracker:SetScript("OnEvent", EPIC_empowerTracker.CombatLogHandler)
EPIC_empowerTracker:RegisterEvent("ZONE_CHANGED_NEW_AREA")
EPIC_empowerTracker:ZONE_CHANGED_NEW_AREA()