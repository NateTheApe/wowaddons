local mod	= DBM:NewMod(866, "DBM-SiegeOfOrgrimmar", nil, 369)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 10809 $"):sub(12, -3))
mod:SetCreatureID(72276)
mod:SetEncounterID(1624)
mod:DisableESCombatDetection()
mod:SetMinSyncRevision(10768)
mod:SetHotfixNoticeRev(10768)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"UNIT_DIED",
	"UNIT_SPELLCAST_SUCCEEDED boss1 boss2 boss3 boss4 boss5",--This boss can change boss ID any time you jump into one of tests, because he gets unregistered as boss1 then registered as boss2 when you leave, etc
	"CHAT_MSG_ADDON",
	"GROUP_ROSTER_UPDATE"
)

mod:RegisterEvents(
	"ENCOUNTER_START"
)

local boss = EJ_GetSectionInfo(8216)

mod:SetBossHealthInfo(
	72276, boss
)

--Amalgam of Corruption
local warnUnleashedAnger				= mod:NewSpellAnnounce(145216, 2, nil, mod:IsTank())
local warnBlindHatred					= mod:NewSpellAnnounce(145226, 3)
--Test of Serenity (DPS)
local warnTearReality					= mod:NewCastAnnounce(144482, 3)
--Test of Reliance (Healer)
local warnDishearteningLaugh			= mod:NewSpellAnnounce(146707, 3)
local warnLingeringCorruption			= mod:NewTargetAnnounce(144514, 3)
--Test of Confidence (tank)
local warnTitanicSmash					= mod:NewCastAnnounce(144628, 4)
local warnBurstOfCorruption				= mod:NewCastAnnounce(144654, 3)
local warnHurlCorruption				= mod:NewCastAnnounce(144649, 4)
local warnPiercingCorruption			= mod:NewSpellAnnounce(144657, 3)

--Amalgam of Corruption
local specWarnUnleashedAnger			= mod:NewSpecialWarningSpell(145216, mod:IsTank())
local specWarnBlindHatred				= mod:NewSpecialWarningSpell(145226, nil, nil, nil, 2)
local specWarnManifestation				= mod:NewSpecialWarningSwitch("ej8232", not mod:IsHealer())--Unleashed Manifestation of Corruption
local specWarnManifestationSoon			= mod:NewSpecialWarningSoon("ej8232", not mod:IsHealer(), nil, nil, nil)--WHen the ones die inside they don't spawn right away, there is like a 5 second lag.
--Test of Serenity (DPS)
local specWarnTearReality				= mod:NewSpecialWarningMove(144482)
--Test of Reliance (Healer)
local specWarnDishearteningLaugh		= mod:NewSpecialWarningSpell(146707, false, nil, nil, 2)
local specWarnLingeringCorruption		= mod:NewSpecialWarningDispel(144514)
local specWarnBottomlessPitMove			= mod:NewSpecialWarningMove(146703)
--Test of Confidence (tank)
local specWarnTitanicSmash				= mod:NewSpecialWarningMove(144628)
local specWarnBurstOfCorruption			= mod:NewSpecialWarningSpell(144654, nil, nil, nil, 2)
local specWarnHurlCorruption			= mod:NewSpecialWarningInterrupt(144649, nil, nil, nil, 3)
local specWarnPiercingCorruption		= mod:NewSpecialWarningSpell(144657)

--Amalgam of Corruption
local timerCombatStarts					= mod:NewCombatTimer(25)
local timerUnleashedAngerCD				= mod:NewCDTimer(11, 145216, nil, mod:IsTank())
local timerBlindHatred					= mod:NewBuffActiveTimer(30, 145226, nil, false, nil, nil, nil, nil, nil, 2)
local timerBlindHatredCD				= mod:NewNextTimer(30, 145226)
--All Tests
local timerLookWithin					= mod:NewBuffFadesTimer(60, "ej8220")
--Test of Serenity (DPS)
local timerTearRealityCD				= mod:NewCDTimer(8.5, 144482)--8.5-10sec variation
--Test of Reliance (Healer)
local timerDishearteningLaughCD			= mod:NewNextTimer(12, 146707)
local timerLingeringCorruptionCD		= mod:NewNextTimer(15.5, 144514)
--Test of Confidence (tank)
local timerTitanicSmashCD				= mod:NewCDTimer(14.5, 144628)--14-17sec variation
local timerPiercingCorruptionCD			= mod:NewCDTimer(14, 144657)--14-17sec variation
local timerHurlCorruptionCD				= mod:NewNextTimer(20, 144649)

local berserkTimer						= mod:NewBerserkTimer(418)

local countdownLookWithin				= mod:NewCountdownFades(59, "ej8220")
local countdownLingeringCorruption		= mod:NewCountdown("Alt15.5", 144514)
local countdownHurlCorruption			= mod:NewCountdown("Alt20", 144649)

mod:AddInfoFrameOption("ej8252", false)--May still be buggy but it's needed for heroic.

local corruptionLevel = EJ_GetSectionInfo(8252)
local unleashedAngerCast = 0
local playerInside = false
local previousPower = nil

--May be buggy with two adds spawning at exact same time
--Two different icon functions end up both marking same mob with 8 and 7 and other mob getting no mark.
--Not sure if GUID table will be fast enough to prevent, we shall see!
local function addsDelay()
	specWarnManifestation:Show()
end

local function delayPowerSync()
	mod:RegisterShortTermEvents(
		"UNIT_POWER player"
	)
end

function mod:OnCombatStart(delay)
	playerInside = false
	previousPower = nil
	timerBlindHatredCD:Start(25-delay)
	if self:IsDifficulty("lfr25") then
		berserkTimer:Start(600-delay)
	else
		berserkTimer:Start(-delay)
	end
	if self.Options.InfoFrame then
		DBM.InfoFrame:SetHeader(corruptionLevel)
		DBM.InfoFrame:Show(5, "playerpower", 5, ALTERNATE_POWER_INDEX)
	end
end

function mod:OnCombatEnd()
	self:UnregisterShortTermEvents()
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 145216 then
		unleashedAngerCast = unleashedAngerCast + 1
		warnUnleashedAnger:Show(unleashedAngerCast)
		specWarnUnleashedAnger:Show()
		if unleashedAngerCast < 3 then
			timerUnleashedAngerCD:Start(nil, unleashedAngerCast+1)
		end
	elseif args.spellId == 144482 then
		warnTearReality:Show()
		specWarnTearReality:Show()
		timerTearRealityCD:Start()
	elseif args.spellId == 144654 then
		warnBurstOfCorruption:Show()
		specWarnBurstOfCorruption:Show()
	elseif args.spellId == 144628 then
		warnTitanicSmash:Show()
		specWarnTitanicSmash:Show()
		timerTitanicSmashCD:Start()
	elseif args.spellId == 144649 then
		warnHurlCorruption:Show()
		specWarnHurlCorruption:Show(args.sourceName)
		timerHurlCorruptionCD:Start()
		countdownHurlCorruption:Start()
	elseif args.spellId == 144657 then
		warnPiercingCorruption:Show()
		specWarnPiercingCorruption:Show()
		timerPiercingCorruptionCD:Start()
	elseif args.spellId == 146707 then
		warnDishearteningLaugh:Show()
		specWarnDishearteningLaugh:Show()
		timerDishearteningLaughCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 144514 then
		warnLingeringCorruption:Show(args.destName)
		specWarnLingeringCorruption:Show(args.destName)
		timerLingeringCorruptionCD:Start()
		countdownLingeringCorruption:Start()
	elseif args.spellId == 145226 then
		self:SendSync("BlindHatred")
	elseif args:IsSpellID(144849, 144850, 144851) and args:IsPlayer() then--Look Within
		playerInside = true
		timerLookWithin:Start()
		countdownLookWithin:Start()
	elseif args.spellId == 146703 and args:IsPlayer() and self:AntiSpam(3, 2) then
		specWarnBottomlessPitMove:Show()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(144849, 144850, 144851) and args:IsPlayer() then--Look Within
		playerInside = false
		timerTearRealityCD:Cancel()
		timerLingeringCorruptionCD:Cancel()
		countdownLingeringCorruption:Cancel()
		timerDishearteningLaughCD:Cancel()
		timerTitanicSmashCD:Cancel()
		timerHurlCorruptionCD:Cancel()
		countdownHurlCorruption:Cancel()
		timerPiercingCorruptionCD:Cancel()
		timerLookWithin:Cancel()
		countdownLookWithin:Cancel()
	elseif args.spellId == 145226 then
		self:SendSync("BlindHatredEnded")
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 71977 then--Manifestation of Corruption (Dps Test)
		timerTearRealityCD:Cancel()
		self:SendSync("ManifestationDied")
	elseif cid == 72001 then--Greater Corruption (Healer Test)
		timerLingeringCorruptionCD:Cancel()
		countdownLingeringCorruption:Cancel()
		timerDishearteningLaughCD:Cancel()
	elseif cid == 72051 then--Titanic Corruption (Tank Test)
		timerTitanicSmashCD:Cancel()
		timerHurlCorruptionCD:Cancel()
		countdownHurlCorruption:Cancel()
		timerPiercingCorruptionCD:Cancel()
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, _, _, spellId)
	if spellId == 145769 and self:AntiSpam(1) then--Unleash Corruption
		self:Schedule(5, addsDelay, GetTime())
	end
end

function mod:ENCOUNTER_START(id)
	if id == 1624 then
		self:SendSync("prepull")
	end
end

function mod:OnSync(msg, guid)
	if msg == "BlindHatred" then
		warnBlindHatred:Show()
		if not playerInside then
			specWarnBlindHatred:Show()
		end
		timerBlindHatred:Start()
	elseif msg == "BlindHatredEnded" then
		timerBlindHatredCD:Start()
		unleashedAngerCast = 0
	elseif msg == "prepull" then
		timerCombatStarts:Start()
	elseif msg == "ManifestationDied" and not playerInside and self:AntiSpam(1) then
		specWarnManifestationSoon:Show()
		if not self:IsDifficulty("lfr25") then
			self:Schedule(5, addsDelay, GetTime())
		end
	end
end

function mod:CHAT_MSG_ADDON(prefix, message, channel, sender)
	--Because core already registers BigWigs prefix with server, shouldn't need it here
	if prefix == "BigWigs" and message then
		local bwPrefix, bwMsg = message:match("^(%u-):(.+)")
		if bwMsg == "InsideBigAddDeath" and not playerInside and self:AntiSpam(1) then
			specWarnManifestationSoon:Show()
			if not self:IsDifficulty("lfr25") then
				self:Schedule(5, addsDelay, GetTime())
			end
		end
	end
end

--Make sure we send Bigwigs altPower syncs so DBM users aren't yelled at by raid leaders for not installing BW
function mod:UNIT_POWER(uId)
	local currentPower = UnitPower("player", 10)
	if not previousPower or (previousPower ~= currentPower) then
		previousPower = currentPower
		SendAddonMessage("BigWigs", "T:".."BWPower "..currentPower, IsInGroup(2) and "INSTANCE_CHAT" or "RAID")
	end
end

function mod:GROUP_ROSTER_UPDATE(uId)
	local currentPower = UnitPower("player", 10)
	SendAddonMessage("BigWigs", "T:".."BWPower "..currentPower, IsInGroup(2) and "INSTANCE_CHAT" or "RAID")
end
