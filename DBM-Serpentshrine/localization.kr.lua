if GetLocale() ~= "koKR" then return end
local L

---------------------------
--  Hydross the Unstable --
---------------------------
L = DBM:GetModLocalization("Hydross")

L:SetGeneralLocalization{
	name = "불안정한 히드로스"
}

L:SetWarningLocalization{
	WarnMark 		= "%s : %s",
	WarnPhase		= "%s 단계",
	SpecWarnMark	= "%s : %s",
}

L:SetTimerLocalization{
	TimerMark	= "다음 %s : %s"
}

L:SetOptionLocalization{
	WarnMark		= "징표 알림 보기",
	WarnPhase		= "단계 변환 알림 보기",
	SpecWarnMark	= "징표 피해가 100%를 넘을 경우 특수 경고 보기",
	TimerMark		= "다음 징표 바 표시",
	RangeFrame		= "거리 창 보기"
}

L:SetMiscLocalization{
	Frost	= "냉기",
	Nature	= "자연"
}

-----------------------
--  The Lurker Below --
-----------------------
L = DBM:GetModLocalization("LurkerBelow")

L:SetGeneralLocalization{
	name = "심연의 잠복꾼"
}

L:SetWarningLocalization{
	WarnSubmerge		= "잠수",
	WarnSubmergeSoon	= "10초 후 잠수",
	WarnEmerge			= "재등장",
	WarnEmergeSoon		= "10초 후 재등장"
}

L:SetTimerLocalization{
	TimerSubmerge		= "다음 잠수",
	TimerEmerge			= "다음 재등장"
}

L:SetOptionLocalization{
	WarnSubmerge		= "잠수 알림 보기",
	WarnSubmergeSoon	= "잠수 사전 알림 보기",
	WarnEmerge			= "재등장 알림 보기",
	WarnEmergeSoon		= "재등장 사전 알림 보기",
	TimerSubmerge		= "다음 잠수 바 표시",
	TimerEmerge			= "다음 재등장 바 표시"
}

L:SetMiscLocalization{
	Spout	= "%s|1이;가; 깊은 숨을 쉽니다!"
}

--------------------------
--  Leotheras the Blind --
--------------------------
L = DBM:GetModLocalization("Leotheras")

L:SetGeneralLocalization{
	name = "눈먼 레오테라스"
}

L:SetWarningLocalization{
	WarnPhase		= "%s 단계",
	WarnPhaseSoon	= "5초 후 %s 단계"
}

L:SetTimerLocalization{
	TimerPhase	= "다음 %s 단계"
}

L:SetOptionLocalization{
	WarnPhase		= "단계 변환 알림 보기",
	WarnPhaseSoon	= "단계 변환 사전 알림 보기",
	TimerPhase		= "다음 단계 변환 바 표시",
	DemonIcon		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(37676)
}

L:SetMiscLocalization{
	Human		= "인간",
	Demon		= "악마",
	YellDemon	= "꺼져라, 엘프 꼬맹이. 지금부터는 내가 주인이다!",
	YellPhase2	= "안 돼... 안 돼! 무슨 짓이냐? 내가 주인이야! 내 말 듣지 못해? 나란 말이야! 내가... 으아악! 놈을 억누를 수... 없...어."
}

-----------------------------
--  Fathom-Lord Karathress --
-----------------------------
L = DBM:GetModLocalization("Fathomlord")

L:SetGeneralLocalization{
	name = "심연의 군주 카라드레스"
}

L:SetWarningLocalization{
}

L:SetTimerLocalization{
}

L:SetOptionLocalization{
}

L:SetMiscLocalization{
	YellPull	= "경비병! 여기 침입자들이 있다...",
	Caribdis	= "심연의 경비병 카리브디스",
	Tidalvess	= "심연의 경비병 타이달베스",
	Sharkkis	= "심연의 경비병 샤르키스"
}

--------------------------
--  Morogrim Tidewalker --
--------------------------
L = DBM:GetModLocalization("Tidewalker")

L:SetGeneralLocalization{
	name = "겅둥파도 모로그림"
}

L:SetWarningLocalization{
	WarnMurlocs		= "멀록 소환",
	SpecWarnMurlocs	= "멀록 소환!",
}

L:SetTimerLocalization{
	TimerMurlocs	= "다음 멀록 소환"
}

L:SetOptionLocalization{
	WarnMurlocs		= "멀록 소환 알림 보기",
	SpecWarnMurlocs	= "멀록 소환 특수 경고 보기",
	TimerMurlocs	= "다음 멀록 소환 바 표시",
	GraveIcon		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(38049)
}

L:SetMiscLocalization{
}

-----------------
--  Lady Vashj --
-----------------
L = DBM:GetModLocalization("Vashj")

L:SetGeneralLocalization{
	name = "여군주 바쉬"
}

L:SetWarningLocalization{
	WarnElemental			= "곧 오염된 정령 등장 (%s)",
	WarnStrider				= "곧 포자손 등장 (%s)",
	WarnNaga				= "곧 나가 등장 (%s)",
	WarnShield				= "보호막 %d/4 남음",
	WarnLoot				= "오염된 핵: >%s<",
	SpecWarnElemental		= "오염된 정령 - 대상 전환!"
}

L:SetTimerLocalization{
	TimerElementalActive	= "오염된 정령 활성화",
	TimerElemental			= "오염된 정령 가능 (%d)",
	TimerStrider			= "다음 포자손 (%d)",
	TimerNaga				= "다음 나가 (%d)"
}

L:SetOptionLocalization{
	WarnElemental			= "오염된 정령 등장 사전 알림 보기",
	WarnStrider				= "포자손 등장 사전 알림 보기",
	WarnNaga				= "나가 등장 사전 알림 보기",
	WarnShield				= "보호막 사라짐 알림 보기",
	WarnLoot				= "오염된 핵 획득 대상 알림 보기",
	TimerElementalActive	= "오염된 정령 활성화 시간 바 표시",
	TimerElemental			= "오염된 정령 대기시간 바 표시",
	TimerStrider			= "다음 포자손 바 표시",
	TimerNaga				= "다음 나가 바 표시",
	SpecWarnElemental		= "오염된 정령 등장 특수 경고 보기",
	RangeFrame				= "거리 창 보기",
	ChargeIcon				= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(38280),
	AutoChangeLootToFFA		= "2 단계에서 전리품 획득 설정 자동으로 변경"
}

L:SetMiscLocalization{
	DBM_VASHJ_YELL_PHASE2	= "때가 왔다! 한 놈도 살려두지 마라!",
	LootMsg					= "([^%s]+).*Hitem:(%d+)"
}