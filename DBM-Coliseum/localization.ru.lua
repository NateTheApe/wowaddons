﻿if GetLocale() ~= "ruRU" then return end

local L

------------------------
--  Northrend Beasts  --
------------------------
L = DBM:GetModLocalization("NorthrendBeasts")

L:SetGeneralLocalization{
	name = "Чудовища Нордскола"
}

L:SetMiscLocalization{
	Charge		= "^%%s глядит на (%S+) и испускает гортанный вой!",
	CombatStart	= "Из самых глубоких и темных пещер Грозовой Гряды был призван Гормок Пронзающий Бивень! В бой, герои!",
	Phase2		= "Приготовьтесь к схватке с близнецами-чудовищами, Кислотной Утробой и Жуткой Чешуей!",
	Phase3		= "В воздухе повеяло ледяным дыханием следующего бойца: на арену выходит Ледяной Рев! Сражайтесь или погибните, чемпионы!",
	Gormok		= "Гормок Пронзающий Бивень",
	Acidmaw		= "Кислотная Утроба",
	Dreadscale	= "Жуткая Чешуя",
	Icehowl		= "Ледяной Рев"
}

L:SetOptionLocalization{
	WarningSnobold				= "Предупреждение о призыве Снобольда-вассала",
	PingCharge					= "Показать на миникарте место, куда попадает Ледяной Рев, если он избрал вас целью",
	ClearIconsOnIceHowl			= "Снимать все иконки перед Топотом",
	TimerNextBoss				= "Отсчет времени до появления следующего противника",
	TimerEmerge					= "Отсчет времени до появления",
	TimerSubmerge				= "Отсчет времени до зарывания",
	IcehowlArrow				= "Показывать стрелку, когда Ледяной Рев готовится сделать рывок на цель рядом с вами"
}

L:SetTimerLocalization{
	TimerNextBoss		= "Прибытие следующего босса",
	TimerEmerge			= "Появление",
	TimerSubmerge		= "Зарывание"
}

L:SetWarningLocalization{
	WarningSnobold				= "Призыв снобольда-вассала"
}

---------------------
--  Lord Jaraxxus  --
---------------------
L = DBM:GetModLocalization("Jaraxxus")

L:SetGeneralLocalization{
	name = "Лорд Джараксус"
}

L:SetOptionLocalization{
	IncinerateShieldFrame		= "Показать здоровье босса с индикатором здоровья для Испепеления плоти"
}

L:SetMiscLocalization{
	IncinerateTarget	= "Испепеление плоти: %s",
	FirstPull	= "Сейчас великий чернокнижник Вилфред Непопамс призовет вашего нового противника. Готовьтесь к бою!"
}

-------------------------
--  Faction Champions  --
-------------------------
L = DBM:GetModLocalization("Champions")

L:SetGeneralLocalization{
	name = "Чемпионы фракций"
}

L:SetMiscLocalization{
	--Horde NPCS
	Gorgrim				= "Горгрим Темный Раскол <Рыцарь смерти>",	-- 34458
	Birana 				= "Бирана Штормовое Копыто <Друид>",		-- 34451
	Erin				= "Эрин Мглистое Копыто <Друид>",			-- 34459
	Rujkah				= "Руж'ка <Охотница>",						-- 34448
	Ginselle			= "Гинзелль Отразительница Гнили <Маг>",	-- 34449
	Liandra				= "Лиандра Зовущая Солнце <Паладин>",		-- 34445
	Malithas			= "Малитас Сияющий Клинок <Паладин>",		-- 34456
	Caiphus				= "Каифа Неумолимый <Жрец>",				-- 34447
	Vivienne			= "Вивьен Шепот Тьмы <Жрица>",				-- 34441
	Mazdinah			= "Маз'дина <Разбойница>",					-- 34454
	Thrakgar			= "Тракгар <Шаман>",						-- 34444
	Broln				= "Бролн Крепкий Рог <Шаман>",				-- 34455
	Harkzog				= "Харкзог <Чернокнижник>",					-- 34450
	Narrhok				= "Наррок Крушитель Стали <Воин>",			-- 34453
	--Alliance NPCS
	Tyrius				= "Тирий Клинок Сумерек <Рыцарь смерти>",	-- 34461
 	Kavina				= "Кавина Песня Рощи <Друид>",				-- 34460
 	Melador				= "Меладор Дальний Гонец <Друид>",			-- 34469
 	Alyssia 			= "Алисса Лунопард <Охотница>",				-- 34467
 	Noozle				= "Нуззл Чудодей <Маг>",					-- 34468
 	Baelnor 			= "Бельнор Светоносный <Паладин>",			-- 34471
 	Velanaa				= "Веланаа <Паладин>", 						-- 34465
 	Anthar				= "Антар Очистительный Горн <Жрец>",		-- 34466
 	Brienna				= "Бриенна Приход Ночи <Жрица>",			-- 34473
 	Irieth				= "Ириэт Шаг Сквозь Тень <Разбойница>",		-- 34472
 	Saamul				= "Саамул <Шаман>", 						-- 34470
 	Shaabad				= "Шаабад <Шаман>", 						-- 34463
 	Serissa				= "Серисса Мрачная Кропильщица <Чернокнижница>",-- 34474
 	Shocuul				= "Шокул <Воин>",							-- 34475

	AllianceVictory		= "СЛАВА АЛЬЯНСУ!",
	HordeVictory		= "That was just a taste of what the future brings. FOR THE HORDE!",
	YellKill			= "Пустая и горькая победа. После сегодняшних потерь мы стали слабее как целое. Кто еще, кроме Короля-лича, выиграет от подобной глупости? Пали великие воины. И ради чего? Истинная опасность еще впереди – нас ждет битва с  Королем-личом."
}

---------------------
--  Val'kyr Twins  --
---------------------
L = DBM:GetModLocalization("ValkTwins")

L:SetGeneralLocalization{
	name = "Валь'киры-близнецы"
}

L:SetTimerLocalization{
	TimerSpecialSpell	= "Следующая спец-способность"	
}

L:SetWarningLocalization{
	WarnSpecialSpellSoon		= "Скоро спец-способность",
	SpecWarnSpecial				= "Смена цвета",
	SpecWarnSwitchTarget		= "Смена цели",
	SpecWarnKickNow				= "Прерывание",
	WarningTouchDebuff			= "Отрицательный эффект на |3-5(>%s<)",
	WarningPoweroftheTwins		= "Сила близнецов - больше исцеления на |3-3(>%s<)",
	SpecWarnPoweroftheTwins		= "Сила близнецов"
}

L:SetMiscLocalization{
	YellPull	= "Во имя темного повелителя. Во имя Короля-лича. Вы. Умрете.",
	Fjola		= "Фьола Погибель Света",
	Eydis		= "Эйдис Погибель Тьмы"
}

L:SetOptionLocalization{
	TimerSpecialSpell			= "Отсчет времени до перезарядки спец-способности",
	WarnSpecialSpellSoon		= "Предупреждение о следующуюей спец-способность",
	SpecWarnSpecial				= "Спец-предупреждение для смены цветов",
	SpecWarnSwitchTarget		= "Спец-предупреждение для других, когда босс читает заклинание",
	SpecWarnKickNow				= "Спец-предупреждение, когда вы должы прервать заклинание",
	SpecialWarnOnDebuff			= "Спец-предупреждение, когда отрицательный эффект",
	SetIconOnDebuffTarget		= "Установить метку на получившего отрицательный эффект (героический режим)",
	WarningTouchDebuff			= "Объявлять цели, получившие отрицательный эффект",
	WarningPoweroftheTwins		= "Объявлять цель под воздействем Силы близнецов",
	SpecWarnPoweroftheTwins		= "Спец-предупреждение, когда на вас Сила близнецов"
}

-----------------
--  Anub'arak  --
-----------------
L = DBM:GetModLocalization("Anub'arak_Coliseum")

L:SetGeneralLocalization{
	name 					= "Ануб'арак"
}

L:SetTimerLocalization{
	TimerEmerge				= "Появление через",
	TimerSubmerge			= "Зарывание через",
	timerAdds				= "Призыв помощников через"
}

L:SetWarningLocalization{
	WarnEmerge				= "Ануб'арак появляется",
	WarnEmergeSoon			= "Появление через 10 сек",
	WarnSubmerge			= "Ануб'арак зарывается",
	WarnSubmergeSoon		= "Зарывание через 10 сек",
	specWarnSubmergeSoon	= "Зарывание через 10 сек!",
	warnAdds				= "Новые помощники"
}

L:SetMiscLocalization{
	YellPull			= "Это место станет вашей могилой!",
	Emerge				= "вылезает на поверхность!",
	Burrow				= "зарывается в землю!",
	PcoldIconSet		= "Метка холода {rt%d} установлена на: %s",
	PcoldIconRemoved	= "Метка холода снята с: %s"
}

L:SetOptionLocalization{
	WarnEmerge				= "Предупреждение о появлении",
	WarnEmergeSoon			= "Предупреждать заранее о появлении",
	WarnSubmerge			= "Предупреждение о зарывании",
	WarnSubmergeSoon		= "Предупреждать заранее о зарывании",
	specWarnSubmergeSoon	= "Спец-предупреждение о скором зарывании",
	warnAdds				= "Предупреждение о призыве помощников",
	timerAdds				= "Отсчет времени до призыва помощников",
	TimerEmerge				= "Отсчет времени до появления",
	TimerSubmerge			= "Отсчет времени до зарывания",
	AnnouncePColdIcons		= "Объявлять метки целей заклинания $spell:68510 в рейд-чат<br/>(требуются права лидера или помощника)",
	AnnouncePColdIconsRemoved	= "Объявлять также о снятии меток с целей заклинания $spell:68510<br/>(требуется предыдущая опция)"
}

