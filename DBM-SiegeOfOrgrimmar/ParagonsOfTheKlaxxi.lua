local mod	= DBM:NewMod(853, "DBM-SiegeOfOrgrimmar", nil, 369)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 10819 $"):sub(12, -3))
mod:SetCreatureID(71152, 71153, 71154, 71155, 71156, 71157, 71158, 71160, 71161)
mod:SetEncounterID(1593)
mod:DisableESCombatDetection()
mod:SetMinSyncRevision(10768)
mod:SetHotfixNoticeRev(10768)
mod:SetZone()
mod:SetUsedIcons(3, 1)
mod:SetBossHPInfoToHighest()

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED",
	"SPELL_PERIODIC_DAMAGE",
	"SPELL_PERIODIC_MISSED",
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"CHAT_MSG_MONSTER_EMOTE",
	"UNIT_DIED"
)

----------------------------------------------------------------------------------------------------------------------------------------
-- A moment of silence to remember Malik the Unscathed, the 10th paragon that perished an honorable death in battle against Shek'zeer --
----------------------------------------------------------------------------------------------------------------------------------------
--All
local warnActivated					= mod:NewTargetAnnounce(118212, 3, 143542)
--Kil'ruk the Wind-Reaver
local warnGouge						= mod:NewTargetAnnounce(143939, 3, nil, mod:IsTank() or mod:IsHealer())--Timing too variable for a CD
local warnDeathFromAbove			= mod:NewTargetAnnounce(142232, 3)
local warnReave						= mod:NewCastAnnounce(148676, 3)
--Xaril the Poisoned-Mind
local warnToxicInjection			= mod:NewSpellAnnounce(142528, 3)
local warnCausticBlood				= mod:NewSpellAnnounce("OptionVersion2", 142315, 4, nil, mod:IsTank())
mod:AddBoolOption("warnToxicCatalyst", true, "announce")
local warnToxicCatalystBlue			= mod:NewCastAnnounce(142725, 4, nil, nil, nil, false)
local warnToxicCatalystRed			= mod:NewCastAnnounce(142726, 4, nil, nil, nil, false)
local warnToxicCatalystYellow		= mod:NewCastAnnounce(142727, 4, nil, nil, nil, false)
local warnToxicCatalystOrange		= mod:NewCastAnnounce(142728, 4, nil, nil, nil, false)--Heroic
local warnToxicCatalystPurple		= mod:NewCastAnnounce(142729, 4, nil, nil, nil, false)--Heroic
local warnToxicCatalystGreen		= mod:NewCastAnnounce(142730, 4, nil, nil, nil, false)--Heroic
--Kaz'tik the Manipulator
local warnMesmerize					= mod:NewTargetAnnounce(142671, 3)
local warnSonicProjection			= mod:NewSpellAnnounce(143765, 3, nil, false)--Spammy, and target scaning didn't work
--Korven the Prime
local warnShieldBash				= mod:NewSpellAnnounce(143974, 3, nil, mod:IsTank() or mod:IsHealer())
local warnEncaseInAmber				= mod:NewTargetAnnounce(142564, 4)
--Iyyokuk the Lucid
local warnDiminish					= mod:NewSpellAnnounce(143666, 4, nil, false)--Spammy, target scanning was iffy
local warnCalculated				= mod:NewTargetAnnounce(144095, 3)--Wild variation on timing noted, 34-130.8 variation (wtf)
local warnInsaneCalculationFire		= mod:NewCastAnnounce(142416, 4)--3 seconds after 144095
--Ka'roz the Locust
local warnFlash						= mod:NewCastAnnounce(143709, 3)--62-70
local warnWhirling					= mod:NewTargetAnnounce("OptionVersion2", 143701, 3, nil, false)--Spammy
local warnHurlAmber					= mod:NewSpellAnnounce(143759, 3)
--Skeer the Bloodseeker
local warnBloodletting				= mod:NewSpellAnnounce(143280, 4)
--Rik'kal the Dissector
local warnInjection					= mod:NewStackAnnounce(143339)
local warnMutate					= mod:NewTargetCountAnnounce(143337, 3)
local warnParasitesLeft				= mod:NewAddsLeftAnnounce("ej8065", 3, 143383, mod:IsTank())
--Hisek the Swarmkeeper
local warnAim						= mod:NewTargetCountAnnounce(142948, 4)--Maybe wrong debuff id, maybe 144759 instead
local warnRapidFire					= mod:NewSpellAnnounce(143243, 3)

--All
local specWarnActivated				= mod:NewSpecialWarningTarget(118212)
local specWarnActivatedVulnerable	= mod:NewSpecialWarning("specWarnActivatedVulnerable", mod:IsTank())--Alternate activate warning to warn a tank not to pick up a specific boss
--Kil'ruk the Wind-Reaver
local specWarnGouge					= mod:NewSpecialWarningYou(143939)
local specWarnGougeOther			= mod:NewSpecialWarningTarget(143939, mod:IsTank() or mod:IsHealer())
local specWarnDeathFromAbove		= mod:NewSpecialWarningYou(142232)
local specWarnDeathFromAboveNear	= mod:NewSpecialWarningClose(142232)
local yellDeathFromAbove			= mod:NewYell(142232)
local specWarnReave					= mod:NewSpecialWarningSpell(148676, nil, nil, nil, 2)--Heroic
--Xaril the Poisoned-Mind
local specWarnCausticBlood			= mod:NewSpecialWarningSpell(142315, mod:IsTank())
local specWarnToxicBlue				= mod:NewSpecialWarningYou(142532)
local specWarnToxicRed				= mod:NewSpecialWarningYou(142533)
local specWarnToxicYellow			= mod:NewSpecialWarningYou(142534)
local specWarnCatalystBlue			= mod:NewSpecialWarningYou(142725, nil, nil, nil, 3)--Only one you don't move away from others for. This one you need to move TO others (although we cannot tell you who since multiple blues go out and you must use multiple stack groups, not just 1.
local specWarnCatalystRed			= mod:NewSpecialWarningMoveAway(142726, nil, nil, nil, 3)
local specWarnCatalystYellow		= mod:NewSpecialWarningMoveAway(142727, nil, nil, nil, 3)
local specWarnCatalystOrange		= mod:NewSpecialWarningMoveAway(142728, nil, nil, nil, 3)--Heroic
local specWarnCatalystPurple		= mod:NewSpecialWarningMoveAway(142729, nil, nil, nil, 3)--Heroic
local specWarnCatalystGreen			= mod:NewSpecialWarningMoveAway(142730, nil, nil, nil, 3)--Heroic
mod:AddBoolOption("yellToxicCatalyst", true, "misc")--And lastly, combine yells
local yellCatalystBlue				= mod:NewYell(142725, nil, nil, false)
local yellCatalystRed				= mod:NewYell(142726, nil, nil, false)
local yellCatalystYellow			= mod:NewYell(142727, nil, nil, false)
local yellCatalystOrange			= mod:NewYell(142728, nil, nil, false)
local yellCatalystPurple			= mod:NewYell(142729, nil, nil, false)
local yellCatalystGreen				= mod:NewYell(142730, nil, nil, false)
--Kaz'tik the Manipulator
local specWarnMesmerize				= mod:NewSpecialWarningYou(142671)
local specWarnMesmerizeOther		= mod:NewSpecialWarningTarget(142671, false)--Person who grabs korven's amber wants this
local yellMesmerize					= mod:NewYell(142671, nil, false)
local specWarnKunchongs				= mod:NewSpecialWarningSwitch("ej8043", mod:IsDps())
--Korven the Prime
local specWarnShieldBash			= mod:NewSpecialWarningSpell("OptionVersion2", 143974, mod:IsTank())
local specWarnShieldBashOther		= mod:NewSpecialWarningTarget(143974, mod:IsTank() or mod:IsHealer())
local specWarnEncaseInAmber			= mod:NewSpecialWarningTarget(142564, mod:IsDps())--Better than switch because on heroic, you don't actually switch to amber, you switch to a NON amber target. Plus switch gives no targetname
--Iyyokuk the Lucid
local specWarnCalculated			= mod:NewSpecialWarningYou(142416)
local yellCalculated				= mod:NewYell(142416, nil, false)
local specWarnInsaneCalculationFire	= mod:NewSpecialWarningSpell(142416, nil, nil, nil, 2)
--Ka'roz the Locust
local specWarnFlash					= mod:NewSpecialWarningSpell(143709, nil, nil, nil, 2)--I realize two abilities on same boss both using same sound is less than ideal, but user can change it now, and 1 or 3 feel appropriate for both of these
local specWarnWhirling				= mod:NewSpecialWarningYou(143701)
local specWarnWhirlingNear			= mod:NewSpecialWarningClose(143701)
local specWarnHurlAmber				= mod:NewSpecialWarningSpell(143759, nil, nil, nil, 2)--I realize two abilities on same boss both using same sound is less than ideal, but user can change it now, and 1 or 3 feel appropriate for both of these
local specWarnCausticAmber			= mod:NewSpecialWarningMove(143735)--Stuff on the ground
--Skeer the Bloodseeker
local specWarnBloodletting			= mod:NewSpecialWarningSwitch(143280, not mod:IsHealer())
--Rik'kal the Dissector
local specWarnMutate				= mod:NewSpecialWarningYou(143337)
local specWarnParasiteFixate		= mod:NewSpecialWarningYou("OptionVersion2", 143358, false)
local specWarnInjection				= mod:NewSpecialWarningSpell(143339, mod:IsTank(), nil, nil, 3)
local specWarnMoreParasites			= mod:NewSpecialWarning("specWarnMoreParasites", mod:IsTank())
--Hisek the Swarmkeeper
local specWarnAim					= mod:NewSpecialWarningYou(142948)
local yellAim						= mod:NewYell(142948)
local specWarnAimOther				= mod:NewSpecialWarningTarget(142948)
local specWarnRapidFire				= mod:NewSpecialWarningSpell(143243, nil, nil, nil, 2)

local timerJumpToCenter				= mod:NewCastTimer(5, 143545)
--Kil'ruk the Wind-Reaver
local timerGouge					= mod:NewTargetTimer(10, 143939, nil, mod:IsTank())
local timerReaveCD					= mod:NewCDTimer(33, 148676)
--Xaril the Poisoned-Mind
local timerToxicCatalystCD			= mod:NewCDTimer(33, "ej8036")
--Kaz'tik the Manipulator
local timerMesmerizeCD				= mod:NewCDTimer(34, 142671)
--Korven the Prime
local timerShieldBash				= mod:NewTargetTimer(6, 143974, nil, mod:IsTank())
local timerShieldBashCD				= mod:NewCDTimer(17, 143974, nil, mod:IsTank())
local timerEncaseInAmber			= mod:NewTargetTimer(10, 142564)
local timerEncaseInAmberCD			= mod:NewCDTimer(30, 142564)--Technically a next timer but we use cd cause it's only cast if someone is low when it comes off 30 second internal cd. VERY important timer for heroic
--Iyyokuk the Lucid
local timerCalculated				= mod:NewBuffFadesTimer(6, 142416)
local timerInsaneCalculationCD		= mod:NewCDTimer(25, 142416)--25 is minimum but variation is wild (25-50 second variation)
--Ka'roz the Locust
local timerFlashCD					= mod:NewCDTimer(62, 143709)
local timerWhirling					= mod:NewBuffFadesTimer(5, 143701, nil, false, nil, nil, nil, nil, nil, 2)
local timerHurlAmberCD				= mod:NewCDTimer(62, 143759)--TODO< verify cd on spell itself. in my logs he died after only casting it once every time.
--Skeer the Bloodseeker
local timerBloodlettingCD			= mod:NewCDTimer(35, 143280)--35-65 variable. most of the time it's around 42 range
--Rik'kal the Dissector
local timerMutate					= mod:NewBuffFadesTimer(20, 143337, nil, false, nil, nil, nil, nil, nil, 2)
local timerMutateCD					= mod:NewCDCountTimer(31.5, 143337)
local timerInjectionCD				= mod:NewNextTimer(9.5, 143339, nil, mod:IsTank())
--Hisek the Swarmkeeper
local timerAim						= mod:NewTargetTimer(5, 142948)--or is it 7, conflicting tooltips
local timerAimCD					= mod:NewCDCountTimer(42, 142948)
local timerRapidFireCD				= mod:NewCDTimer(47, 143243)--Heroic, 47-50 variation

local berserkTimer					= mod:NewBerserkTimer(720)

local countdownEncaseInAmber		= mod:NewCountdown(30, 142564)--Probably switch to secondary countdown if one of his other abilities proves to have priority
local countdownInjection			= mod:NewCountdown("Alt9.5", 143339, mod:IsTank())

mod:AddRangeFrameOption("6/5/3")
mod:AddSetIconOption("SetIconOnAim", 142948, false)
mod:AddSetIconOption("SetIconOnMesmerize", 142671, false)
mod:AddBoolOption("AimArrow", false)

local activatedTargets = {}--A table, for the 3 on pull
local activeBossGUIDS = {}
local UnitDebuff = UnitDebuff
local GetSpellInfo = GetSpellInfo
local calculatedShape = nil
local calculatedNumber = nil
local calculatedColor = nil
local mathNumber = 100
local calculatingDude = EJ_GetSectionInfo(8012)
local readyToFight = GetSpellInfo(143542)
local mutateCount = 0
local aimCount = 0
local parasitesActive = 0
local aimActive = false
local mutateActive = false
local toxicInjection = false--Workaround blizzard bug

local function warnActivatedTargets(vulnerable)
	if #activatedTargets > 1 then
		warnActivated:Show(table.concat(activatedTargets, "<, >"))
		specWarnActivated:Show(table.concat(activatedTargets, ", "))
	else
		warnActivated:Show(activatedTargets[1])
		if vulnerable and mod:IsTank() then
			specWarnActivatedVulnerable:Show(activatedTargets[1])
		else
			specWarnActivated:Show(activatedTargets[1])
		end
	end
	table.wipe(activatedTargets)
end

local function showRangeFrame()
	DBM.RangeCheck:Show(3)
	mutateActive = true
end

local function hideRangeFrame()
	DBM.RangeCheck:Hide()
end

--Another pre target scan (ie targets player BEFORE cast like iron qon)
local function DFAScan()
	for i = 1, 5 do
		local unitID = "boss"..i
		if UnitExists(unitID) and mod:GetCIDFromGUID(UnitGUID(unitID)) == 71161 then
			if UnitExists(unitID.."target") and not mod:IsTanking(unitID.."target", unitID) then
				mod:Unschedule(DFAScan)
				local targetname = DBM:GetUnitFullName(unitID.."target")
				warnDeathFromAbove:Show(targetname)
				if UnitIsUnit(unitID.."target", "player") then
					specWarnDeathFromAbove:Show()
					yellDeathFromAbove:Yell()
				else
					local x, y = GetPlayerMapPosition(unitID.."target")
					if x == 0 and y == 0 then
						SetMapToCurrentZone()
						x, y = GetPlayerMapPosition(unitID.."target")
					end
					local inRange = DBM.RangeCheck:GetDistance("player", x, y)
					if inRange and inRange < 6 then
						specWarnDeathFromAboveNear:Show(targetname)
					end
				end
			else
				mod:Schedule(0.25, DFAScan)
			end
			return--If we found the boss before hitting 5, want to fire this return to break checking other bosses needlessly
		end
	end
end

local function CheckBosses(ignoreRTF)
	local vulnerable = false
	for i = 1, 5 do
		local unitID = "boss"..i
		local unitGUID = UnitGUID(unitID)
		--Only 3 bosses activate on pull, however now the inactive or (next boss to activate) also fires IEEU. As such, we have to filter that boss by scaning for readytofight. Works well though.
		if UnitExists(unitID) and not activeBossGUIDS[unitGUID] and not UnitBuff(unitID, readyToFight) then
			activeBossGUIDS[unitGUID] = true
			activatedTargets[#activatedTargets + 1] = UnitName(unitID)
			--Activation Controller
			local cid = mod:GetCIDFromGUID(unitGUID)
			if cid == 71152 then--Skeer the Bloodseeker
				timerBloodlettingCD:Start(5)--5-6
				if UnitDebuff("player", GetSpellInfo(143279)) then vulnerable = true end
			elseif cid == 71158 then--Rik'kal the Dissector
				timerInjectionCD:Start(8)
				countdownInjection:Start(8)
				timerMutateCD:Start(23, 1)
				if UnitDebuff("player", GetSpellInfo(143275)) then vulnerable = true end
			elseif cid == 71153 then--Hisek the Swarmkeeper
				timerAimCD:Start(35, 1)--Might be 35-37 with unitdebuff filter
				if mod:IsDifficulty("heroic10", "heroic25") then
					timerRapidFireCD:Start(47.5)--47-50 with unitdebuff filter
				end
			elseif cid == 71161 then--Kil'ruk the Wind-Reaver
				if mod:IsDifficulty("heroic10", "heroic25") then
					timerReaveCD:Start(38.5)
				end
				mod:Schedule(23, DFAScan)--Not a large sample size, data shows it happen 29-30 seconds after IEEU fires on two different pulls. Although 2 is a poor sample
				if UnitDebuff("player", GetSpellInfo(142929)) then vulnerable = true end
			elseif cid == 71157 then--Xaril the Poisoned-Mind
				timerToxicCatalystCD:Start(19.5)--May need tweaking by about a sec or two. Need some transcriptors
				if UnitDebuff("player", GetSpellInfo(142931)) then vulnerable = true end
			elseif cid == 71156 then--Kaz'tik the Manipulator
--				timerMesmerizeCD:Start(20)--Need transcriptor log. Seems WILDLY variable though and probably not useful
			elseif cid == 71155 then--Korven the Prime
				timerShieldBashCD:Start(19)--20seconds from REAL IEEU
			elseif cid == 71160 then--Iyyokuk the Lucid
				timerInsaneCalculationCD:Start()
			elseif cid == 71154 then--Ka'roz the Locust
				timerFlashCD:Start(14)--In final LFR test, he didn't cast this for 20 seconds. TODO check this change
				timerHurlAmberCD:Start(44)
			end
		end
	end
	if #activatedTargets >= 1 then
		warnActivatedTargets(vulnerable)--Down here so we can send tank vulnerable status
	end
end

function mod:OnCombatStart(delay)
	table.wipe(activeBossGUIDS)
	table.wipe(activatedTargets)
	calculatedShape = nil
	calculatedNumber = nil
	calculatedColor = nil
	mutateCount = 0
	aimCount = 0
	parasitesActive = 0
	aimActive = false
	mutateActive = false
	toxicInjection = false
	self:RegisterShortTermEvents(
		"INSTANCE_ENCOUNTER_ENGAGE_UNIT"--We register here to make sure we wipe variables on pull
	)
	timerJumpToCenter:Start(-delay)
	berserkTimer:Start(-delay)
	if self:IsDifficulty("normal10", "heroic10") then--Increaased number of people, decrease likelyhood of chat yell so it levels out
		mathNumber = 100
	else
		mathNumber = 250--0.4% chance per person in 25 man, LFR, Flex
	end
end

function mod:OnCombatEnd()
	self:UnregisterShortTermEvents()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
	if self.Options.AimArrow then
		DBM.Arrow:Hide()
	end
end

--"<13.6 19:16:29> [UNIT_SPELLCAST_SUCCEEDED] Iyyokuk the Lucid [[boss2:Jump to Center::0:143545]]", -- [95]
--^don't let above fool you, not all of the paragons fire this spell!!! that is why we MUST use IEEU
function mod:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
	self:Unschedule(CheckBosses)
	self:Schedule(1, CheckBosses)--Delay check to make sure we run function only once on pull
end

local function delayedCatalyst(spellID)
	toxicInjection = true--we won't need work around anymore since you'll get injections from the catalysts cast
	local debuffFound = false
	if spellID == 142725 then
		if UnitDebuff("player", GetSpellInfo(142532)) then
			debuffFound = true
			specWarnCatalystBlue:Show()
			if mod.Options.yellToxicCatalyst then
				yellCatalystBlue:Yell()
			end
		end
	elseif spellID == 142726 then
		if UnitDebuff("player", GetSpellInfo(142533)) then
			debuffFound = true
			specWarnCatalystRed:Show()
			if mod.Options.yellToxicCatalyst then
				yellCatalystRed:Yell()
			end
		end
	elseif spellID == 142727 then
		if UnitDebuff("player", GetSpellInfo(142534)) then
			debuffFound = true
			specWarnCatalystYellow:Show()
			if mod.Options.yellToxicCatalyst then
				yellCatalystYellow:Yell()
			end
		end
	elseif spellID == 142728 then
		if UnitDebuff("player", GetSpellInfo(142533)) or UnitDebuff("player", GetSpellInfo(142534)) then--Red or Yellow
			debuffFound = true
			specWarnCatalystOrange:Show()
			if mod.Options.yellToxicCatalyst then
				yellCatalystOrange:Yell()
			end
		end
	elseif spellID == 142729 then
		if UnitDebuff("player", GetSpellInfo(142533)) or UnitDebuff("player", GetSpellInfo(142532)) then--Red or Blue
			debuffFound = true
			specWarnCatalystPurple:Show()
			if mod.Options.yellToxicCatalyst then
				yellCatalystPurple:Yell()
			end
		end
	elseif spellID == 142730 then
		if UnitDebuff("player", GetSpellInfo(142534)) or UnitDebuff("player", GetSpellInfo(142532)) then--Yellow or Blue
			debuffFound = true
			specWarnCatalystGreen:Show()
			if mod.Options.yellToxicCatalyst then
				yellCatalystGreen:Yell()
			end
		end
	end
	if not debuffFound and not UnitIsDeadOrGhost("player") then--You didn't have a debuff yet, check again.
		mod:Schedule(0.2, delayedCatalyst, spellID)
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 142725 then
		timerToxicCatalystCD:Start()
		if self.Options.warnToxicCatalyst then
			warnToxicCatalystBlue:Show()
		end
		--Work around blizzard bug. Sometimes he doesn't cast injection, causing you to not have a color assignment until 0.5 after this SPELL_CAST_START event.
		if not toxicInjection then
			self:Schedule(0.2, delayedCatalyst, args.spellId)
		else
			delayedCatalyst(args.spellId)
		end
	elseif args.spellId == 142726 then
		timerToxicCatalystCD:Start()
		if self.Options.warnToxicCatalyst then
			warnToxicCatalystRed:Show()
		end
		--Work around blizzard bug. Sometimes he doesn't cast injection, causing you to not have a color assignment until 0.5 after this SPELL_CAST_START event.
		if not toxicInjection then
			self:Schedule(0.2, delayedCatalyst, args.spellId)
		else
			delayedCatalyst(args.spellId)
		end
	elseif args.spellId == 142727 then
		timerToxicCatalystCD:Start()
		if self.Options.warnToxicCatalyst then
			warnToxicCatalystYellow:Show()
		end
		--Work around blizzard bug. Sometimes he doesn't cast injection, causing you to not have a color assignment until 0.5 after this SPELL_CAST_START event.
		if not toxicInjection then
			self:Schedule(0.2, delayedCatalyst, args.spellId)
		else
			delayedCatalyst(args.spellId)
		end
	elseif args.spellId == 142728 then
		timerToxicCatalystCD:Start()
		if self.Options.warnToxicCatalyst then
			warnToxicCatalystOrange:Show()
		end
		--Work around blizzard bug. Sometimes he doesn't cast injection, causing you to not have a color assignment until 0.5 after this SPELL_CAST_START event.
		if not toxicInjection then
			self:Schedule(0.2, delayedCatalyst, args.spellId)
		else
			delayedCatalyst(args.spellId)
		end
	elseif args.spellId == 142729 then
		timerToxicCatalystCD:Start()
		if self.Options.warnToxicCatalyst then
			warnToxicCatalystPurple:Show()
		end
		--Work around blizzard bug. Sometimes he doesn't cast injection, causing you to not have a color assignment until 0.5 after this SPELL_CAST_START event.
		if not toxicInjection then
			self:Schedule(0.2, delayedCatalyst, args.spellId)
		else
			delayedCatalyst(args.spellId)
		end
	elseif args.spellId == 142730 then
		timerToxicCatalystCD:Start()
		if self.Options.warnToxicCatalyst then
			warnToxicCatalystGreen:Show()
		end
		--Work around blizzard bug. Sometimes he doesn't cast injection, causing you to not have a color assignment until 0.5 after this SPELL_CAST_START event.
		if not toxicInjection then
			self:Schedule(0.2, delayedCatalyst, args.spellId)
		else
			delayedCatalyst(args.spellId)
		end
	elseif args.spellId == 143765 then
		warnSonicProjection:Show()
	elseif args.spellId == 143666 then
		warnDiminish:Show()
	elseif args.spellId == 142416 then
		warnInsaneCalculationFire:Show()
		specWarnInsaneCalculationFire:Show()
	elseif args.spellId == 143709 then
		warnFlash:Show()
		specWarnFlash:Show()
		timerFlashCD:Start()
		if self.Options.RangeFrame then
			DBM.RangeCheck:Show(6)--Range assumed, spell tooltips not informative enough
			self:Schedule(5, hideRangeFrame)
		end
	elseif args.spellId == 143280 then
		warnBloodletting:Show()
		specWarnBloodletting:Show()
		timerBloodlettingCD:Start()
	elseif args.spellId == 143974 then
		warnShieldBash:Show()
		specWarnShieldBash:Show()
		timerShieldBashCD:Start()
	elseif args.spellId == 142315 then
		for i = 1, 5 do
			local bossUnitID = "boss"..i
			if UnitExists(bossUnitID) and UnitGUID(bossUnitID) == args.sourceGUID and UnitDetailedThreatSituation("player", bossUnitID) then--We are highest threat target
				warnCausticBlood:Show()
				specWarnCausticBlood:Show()--So show tank warning
				break
			end
		end
	elseif args.spellId == 143243 then
		warnRapidFire:Show()
		specWarnRapidFire:Show()
		timerRapidFireCD:Start()
	elseif args.spellId == 143339 then
		for i = 1, 5 do
			local bossUnitID = "boss"..i
			if UnitExists(bossUnitID) and UnitGUID(bossUnitID) == args.sourceGUID and UnitDetailedThreatSituation("player", bossUnitID) then
				local elapsed, total = timerMutateCD:GetTime(mutateCount+1)
				local remaining = total - elapsed
				if self:IsDifficulty("heroic10", "heroic25") and (remaining < 20) and (parasitesActive < 3) and not UnitDebuff("player", GetSpellInfo(143339)) then--We need more parasites to spawn with this attack
					specWarnMoreParasites:Show()
				else--We want to block attack and not spawn anything
					specWarnInjection:Show()
				end
				timerInjectionCD:Start()
				countdownInjection:Cancel()--Sometimes boss stutter casts so need to do this
				countdownInjection:Start()
				break
			end
		end
	elseif args.spellId == 148676 then
		warnReave:Show()
		specWarnReave:Show()
		timerReaveCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 142528 then
		toxicInjection = true
		warnToxicInjection:Show()
		timerToxicCatalystCD:Start(20)
	elseif args.spellId == 142232 then
		self:Unschedule(DFAScan)
		self:Schedule(17, DFAScan)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 143339 then
		local amount = args.amount or 1
		warnInjection:Show(args.destName, amount)
	elseif args.spellId == 142532 and args:IsPlayer() then
		specWarnToxicBlue:Show()
	elseif args.spellId == 142533 and args:IsPlayer() then
		specWarnToxicRed:Show()
	elseif args.spellId == 142534 and args:IsPlayer() then
		specWarnToxicYellow:Show()
--[[	elseif args.spellId == 142547 and args:IsPlayer() then
		specWarnToxicOrange:Show()
	elseif args.spellId == 142548 and args:IsPlayer() then
		specWarnToxicPurple:Show()
	elseif args.spellId == 142549 and args:IsPlayer() then
		specWarnToxicGreen:Show()--]]
	elseif args.spellId == 142671 then
		warnMesmerize:Show(args.destName)
		timerMesmerizeCD:Start()
		if args.IsPlayer() then
			specWarnMesmerize:Show()
			yellMesmerize:Yell()
		else
			specWarnMesmerizeOther:Show(args.destName)
			specWarnKunchongs:Show()
		end
		if self.Options.SetIconOnMesmerize then
			self:SetIcon(args.destName, 1)
		end
	elseif args.spellId == 142564 then
		warnEncaseInAmber:Show(args.destName)
		specWarnEncaseInAmber:Show(args.destName)
		timerEncaseInAmber:Start(args.destName)
		timerEncaseInAmberCD:Start()
		if self:IsDifficulty("heroic10", "heroic25") then
			countdownEncaseInAmber:Start()
		end
	elseif args.spellId == 143939 then
		warnGouge:Show(args.destName)
		timerGouge:Start(args.destName)
		if args.IsPlayer() then
			specWarnGouge:Show()
		else
			specWarnGougeOther:Show(args.destName)
		end
	elseif args.spellId == 143974 then
		timerShieldBash:Start(args.destName)
		for i = 1, 5 do
			local bossUnitID = "boss"..i
			if UnitExists(bossUnitID) and UnitGUID(bossUnitID) == args.sourceGUID and not UnitDetailedThreatSituation("player", bossUnitID) then--We are not highest threat target
				specWarnShieldBashOther:Show(args.destName)--So warn AGAIN
				break
			end
		end
	elseif args.spellId == 143701 then
		warnWhirling:CombinedShow(0.5, args.destName)
		if args.IsPlayer() then
			specWarnWhirling:Show()
			timerWhirling:Start()
		else
			local uId = DBM:GetRaidUnitId(args.destName)
			if uId then
				local x, y = GetPlayerMapPosition(uId)
				if x == 0 and y == 0 then
					SetMapToCurrentZone()
					x, y = GetPlayerMapPosition(uId)
				end
				local inRange = DBM.RangeCheck:GetDistance("player", x, y)
				if inRange and inRange < 6 then
					specWarnWhirlingNear:Show(args.destName)
				end
			end
		end
	elseif args.spellId == 143759 then
		warnHurlAmber:Show()
		specWarnHurlAmber:Show()
		timerHurlAmberCD:Start()
	elseif args.spellId == 143337 then
		if self:AntiSpam(2, 3) then
			mutateCount = mutateCount + 1
			timerMutateCD:Start(nil, mutateCount+1)
			if self.Options.RangeFrame then
				mutateActive = false
				if not aimActive then
					DBM.RangeCheck:Hide()--Hide it if aim isn't active, otherwise, delay hide call until hide is called by SPELL_AURA_REMOVED for aim
				end
				self:Schedule(26.5, showRangeFrame)--Show about 5 seconds before mutate cast
			end
		end
		warnMutate:CombinedShow(0.5, mutateCount, args.destName)
		if args.IsPlayer() then
			specWarnMutate:Show()
			timerMutate:Start()
		end
	elseif args.spellId == 143358 and args.IsPlayer() then
		specWarnParasiteFixate:Show()
	elseif args.spellId == 142948 then
		aimCount = aimCount + 1
		aimActive = true
		warnAim:Show(aimCount, args.destName)
		timerAim:Start(args.destName)
		timerAimCD:Start(nil, aimCount+1)
		if args.IsPlayer() then
			specWarnAim:Show()
			yellAim:Yell()
		else
			specWarnAimOther:Show(args.destName)
		end
		if self.Options.RangeFrame then
			if self:IsDifficulty("normal25", "heroic25") then
				DBM.RangeCheck:Show(3)
			else
				DBM.RangeCheck:Show(5)
			end
		end
		if self.Options.SetIconOnAim then
			self:SetIcon(args.destName, 3)
		end
		if self.Options.AimArrow then
			DBM.Arrow:ShowRunTo(args.destName, 3, 3, 5)
		end
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 142564 then
		timerEncaseInAmber:Cancel(args.destName)
	elseif args.spellId == 143939 then
		timerGouge:Cancel(args.destName)
	elseif args.spellId == 143974 then
		timerShieldBash:Cancel(args.destName)
	elseif args.spellId == 143700 and self.Options.RangeFrame and not mutateActive and not aimActive then
		DBM.RangeCheck:Hide()
	elseif args.spellId == 142948 then
		aimActive = false
		if self.Options.RangeFrame then
			if not mutateActive then--Don't call hide because frame is needed by mutate and will be hiden after that.
				DBM.RangeCheck:Hide()
			end
		end
		if self.Options.SetIconOnAim then
			self:SetIcon(args.destName, 0)
		end
	elseif args.spellId == 143339 then
		parasitesActive = parasitesActive + 8
	elseif args.spellId == 142671 and self.Options.SetIconOnMesmerize then
		self:SetIcon(args.destName, 0)
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
	if spellId == 143735 and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then
		specWarnCausticAmber:Show()
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

local FlavorTable = {
	[71161] = L.KilrukFlavor,--Kil'ruk the Wind-Reaver
	[71157] = L.XarilFlavor,--Xaril the Poisoned-Mind
	[71156] = L.KaztikFlavor,--Kaz'tik the Manipulator
	[71155] = L.KorvenFlavor2,--Korven the Prime
	[71160] = L.IyyokukFlavor,--Iyyokuk the Lucid
	[71154] = L.KarozFlavor,--Ka'roz the Locust
	[71152] = L.SkeerFlavor,--Skeer the Bloodseeker
	[71158] = L.RikkalFlavor,--Rik'kal the Dissector
	[71153] = L.hisekFlavor--Hisek the Swarmkeeper
}

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 71161 then--Kil'ruk the Wind-Reaver
		self:Unschedule(DFAScan)
		timerReaveCD:Cancel()
	elseif cid == 71157 then--Xaril the Poisoned-Mind
		timerToxicCatalystCD:Cancel()
	elseif cid == 71155 then--Korven the Prime
		timerShieldBashCD:Cancel()
		timerEncaseInAmberCD:Cancel()
		countdownEncaseInAmber:Cancel()
	elseif cid == 71160 then--Iyyokuk the Lucid
		timerInsaneCalculationCD:Cancel()
	elseif cid == 71154 then--Ka'roz the Locust
		timerFlashCD:Cancel()
		timerHurlAmberCD:Cancel()
	elseif cid == 71152 then--Skeer the Bloodseeker
		timerBloodlettingCD:Cancel()
	elseif cid == 71158 then--Rik'kal the Dissector
		timerMutateCD:Cancel()
		timerInjectionCD:Cancel()
		countdownInjection:Cancel()
		self:Unschedule(showRangeFrame)
	elseif cid == 71153 then--Hisek the Swarmkeeper
		timerAimCD:Cancel()
		timerRapidFireCD:Cancel()
	elseif cid == 71578 then--Amber Parasite
		parasitesActive = parasitesActive - 1
		warnParasitesLeft:Show(parasitesActive)
	elseif cid == 71156 then--Kaz'tik the Manipulator
		timerMesmerizeCD:Cancel()
	end

	if FlavorTable[cid] then
		local x = math.random(1, mathNumber)
		if x == 50 then--1% chance yay
			SendChatMessage(FlavorTable[cid], "SAY")
		end
	end
end

------------------
--Normal Only
--143605 Red Sword
--143606 Purple Sword
--143607 Blue Sword
--143608 Green Sword
--143609 Yellow Sword

--143610 Red Drum
--143611 Purple Drum
--143612 Blue Drum
--143613 Green Drum
--143614 Yellow Drum

--143615 Red Bomb
--143616 Purple Bomb
--143617 Blue Bomb
--143618 Green Bomb
--143619 Yellow Bomb
----------------------
--25man Only
--143620 Red Mantid
--143621 Purple Mantid
--143622 Blue Mantid
--143623 Green Mantid
--143624 Yellow Mantid

--143627 Red Staff
--143628 Purple Staff
--143629 Blue Staff
--143630 Green Staff
--143631 Yellow Staff

local RedDebuffs = {GetSpellInfo(143605), GetSpellInfo(143610), GetSpellInfo(143615), GetSpellInfo(143620), (GetSpellInfo(143627))}
local PurpleDebuffs = {GetSpellInfo(143606), GetSpellInfo(143611), GetSpellInfo(143616), GetSpellInfo(143621), (GetSpellInfo(143628))}
local BlueDebuffs = {GetSpellInfo(143607), GetSpellInfo(143612), GetSpellInfo(143617), GetSpellInfo(143622), (GetSpellInfo(143629))}
local GreenDebuffs = {GetSpellInfo(143608), GetSpellInfo(143613), GetSpellInfo(143618), GetSpellInfo(143623), (GetSpellInfo(143630))}
local YellowDebuffs = {GetSpellInfo(143610), GetSpellInfo(143614), GetSpellInfo(143619), GetSpellInfo(143624), (GetSpellInfo(143631))}

local SwordDebuffs = {GetSpellInfo(143605), GetSpellInfo(143606), GetSpellInfo(143607), GetSpellInfo(143608), (GetSpellInfo(143609))}
local DrumDebuffs = {GetSpellInfo(143610), GetSpellInfo(143611), GetSpellInfo(143612), GetSpellInfo(143613), (GetSpellInfo(143614))}
local BombDebuffs = {GetSpellInfo(143615), GetSpellInfo(143616), GetSpellInfo(143617), GetSpellInfo(143618), (GetSpellInfo(143619))}
local MantidDebuffs = {GetSpellInfo(143620), GetSpellInfo(143621), GetSpellInfo(143622), GetSpellInfo(143623), (GetSpellInfo(143624))}
local StaffDebuffs = {GetSpellInfo(143627), GetSpellInfo(143628), GetSpellInfo(143629), GetSpellInfo(143630), (GetSpellInfo(143631))}

local AllDebuffs = {
GetSpellInfo(143605), GetSpellInfo(143606), GetSpellInfo(143607), GetSpellInfo(143608), GetSpellInfo(143609),
GetSpellInfo(143610), GetSpellInfo(143611), GetSpellInfo(143612), GetSpellInfo(143613), GetSpellInfo(143614),
GetSpellInfo(143615), GetSpellInfo(143616), GetSpellInfo(143617), GetSpellInfo(143618), GetSpellInfo(143619),
GetSpellInfo(143620), GetSpellInfo(143621), GetSpellInfo(143622), GetSpellInfo(143623), GetSpellInfo(143624),
GetSpellInfo(143627), GetSpellInfo(143628), GetSpellInfo(143629), GetSpellInfo(143630), (GetSpellInfo(143631))
}

--[[
"<32.1 20:15:38> [CHAT_MSG_MONSTER_EMOTE] CHAT_MSG_MONSTER_EMOTE#Iyyokuk begins choosing criteria from Daltin!#Iyyokuk the Lucid###Daltin##0#0##0#846#nil#0#false#false", -- [2547]
"<32.1 20:15:38> [CHAT_MSG_RAID_BOSS_EMOTE] CHAT_MSG_RAID_BOSS_EMOTE#Iyyokuk selects: Sword |TInterface\\Icons\\ABILITY_IYYOKUK_SWORD_white.BLP:20|t!#Iyyokuk the Lucid###Iyyokuk the Luci
--]]
function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)--This emote comes second, so we have to parse things backwards by delaying CHAT_MSG_MONSTER_EMOTE event until this data is complete
	if self:AntiSpam(3, 1) then
		calculatedShape = nil
		calculatedNumber = nil
		calculatedColor = nil
	end
	--UPDATE. Seems now colors and shapes can avoid localizing with icons and color codes
	--Still need to localize 5 numbers in 10 languages so 50 localizations instead of 150
	if msg:find("FFFF0000") then
		calculatedColor = "Red"
	elseif msg:find("FFFF00FF") then
		calculatedColor = "Purple"
	elseif msg:find("FF0000FF") then
		calculatedColor = "Blue"
	elseif msg:find("FF00FF00") then
		calculatedColor = "Green"
	elseif msg:find("FFFFFF00") then
		calculatedColor = "Yellow"
	elseif msg:find("ABILITY_IYYOKUK_SWORD") then
		calculatedShape = "Sword"
	elseif msg:find("ABILITY_IYYOKUK_DRUM") then
		calculatedShape = "Drum"
	elseif msg:find("ABILITY_IYYOKUK_BOMB") then
		calculatedShape = "Bomb"
	elseif msg:find("ABILITY_IYYOKUK_MANTID") then
		calculatedShape = "Mantid"
	elseif msg:find("ABILITY_IYYOKUK_STAFF") then
		calculatedShape = "Staff"
	elseif msg:find(L.one) then
		calculatedNumber = 0--1 stacks actually return as 0 in checks
	elseif msg:find(L.two) then
		calculatedNumber = 2
	elseif msg:find(L.three) then
		calculatedNumber = 3
	elseif msg:find(L.four) then
		calculatedNumber = 4
	elseif msg:find(L.five) then
		calculatedNumber = 5
	end
end

local function delayMonsterEmote(target)
	--Because now the raid boss emotes fire AFTER this and we need them first
	warnCalculated:Show(target)
	timerCalculated:Start()
	timerInsaneCalculationCD:Start()
	if target == UnitName("player") then
		specWarnCalculated:Show()
		if not mod:IsDifficulty("lfr25") then
			yellCalculated:Yell()
		end
	else--it's not us, so now lets check activated criteria for target based on previous emotes
		local criteriaMatched = false--Now to start checking matches.
		if calculatedColor == "Red" then
			for _, spellname in ipairs(RedDebuffs) do
				local _, _, _, count = UnitDebuff("player", spellname)
				if count then--Found
					criteriaMatched = true
					break
				end
			end
		elseif calculatedColor == "Purple" then
			for _, spellname in ipairs(PurpleDebuffs) do
				local _, _, _, count = UnitDebuff("player", spellname)
				if count then--Found
					criteriaMatched = true
					break
				end
			end
		elseif calculatedColor == "Blue" then
			for _, spellname in ipairs(BlueDebuffs) do
				local _, _, _, count = UnitDebuff("player", spellname)
				if count then--Found
					criteriaMatched = true
					break
				end
			end
		elseif calculatedColor == "Green" then
			for _, spellname in ipairs(GreenDebuffs) do
				local _, _, _, count = UnitDebuff("player", spellname)
				if count then--Found
					criteriaMatched = true
					break
				end
			end
		elseif calculatedColor == "Yellow" then
			for _, spellname in ipairs(YellowDebuffs) do
				local _, _, _, count = UnitDebuff("player", spellname)
				if count then--Found
					criteriaMatched = true
					break
				end
			end
		elseif calculatedShape == "Sword" then
			for _, spellname in ipairs(SwordDebuffs) do
				local _, _, _, count = UnitDebuff("player", spellname)
				if count then--Found
					criteriaMatched = true
					break
				end
			end
		elseif calculatedShape == "Drum" then
			for _, spellname in ipairs(DrumDebuffs) do
				local _, _, _, count = UnitDebuff("player", spellname)
				if count then--Found
					criteriaMatched = true
					break
				end
			end
		elseif calculatedShape == "Bomb" then
			for _, spellname in ipairs(BombDebuffs) do
				local _, _, _, count = UnitDebuff("player", spellname)
				if count then--Found
					criteriaMatched = true
					break
				end
			end
		elseif calculatedShape == "Mantid" then
			for _, spellname in ipairs(MantidDebuffs) do
				local _, _, _, count = UnitDebuff("player", spellname)
				if count then--Found
					criteriaMatched = true
					break
				end
			end
		elseif calculatedShape == "Staff" then
			for _, spellname in ipairs(StaffDebuffs) do
				local _, _, _, count = UnitDebuff("player", spellname)
				if count then--Found
					criteriaMatched = true
					break
				end
			end
		elseif calculatedNumber then
			for _, spellname in ipairs(AllDebuffs) do
				local _, _, _, count = UnitDebuff("player", spellname)
				if count then--Found
					if count == calculatedNumber then
						criteriaMatched = true
					end
					break
				end
			end
		end
		if criteriaMatched then
			specWarnCalculated:Show()
			if not mod:IsDifficulty("lfr25") then
				yellCalculated:Yell()
			end
		end
	end
end

function mod:CHAT_MSG_MONSTER_EMOTE(msg, npc, _, _, target)
	local targetname = DBM:GetUnitFullName(target)
	if npc == calculatingDude then
		self:Unschedule(delayMonsterEmote)
		self:Schedule(0.2, delayMonsterEmote, targetname)
	end
end
