-- handle similar translation tables until we have a full set
-- Full translation from Valdesca on CurseForge
--Traduccion hecha por Winderfind (Drakkari) - winderfind@gmail.com

FishingTranslations["esES"] = {
	DESCRIPTION1							= "Realiza un seguimiento de las capturas que has",
	DESCRIPTION2							= "hecho y facilita tu pesca.",

-- Tab labels and tooltips
	LOCATIONS_INFO							= "Muestra info de zona de pesca",
	LOCATIONS_TAB							= "Zona",
	OPTIONS_INFO							= "Establece #NAME# opciones",
	OPTIONS_TAB								= "Opciones",

	ABOUT_TAB								= "Acerca de ",
	WATCHER_TAB								= "Observador",

	POINT									= "Punto",
	POINTS									= "Puntos",

	RAW										= "Crudo",
	FISH									= "Pez",
	RANDOM									= "Aleatorio",

	BOBBER_NAME								= "Corcho",
	--aca irian comandos, y, claro, quedan en ingles.

	OUTFITS									= "Conjuntos",
	ELAPSED									= "Transcurrido",
	TOTAL									= "Total",
	TOTALS									= "Totales",

	SCHOOL									= "Card\195\186men",  -- e.g. 'Oily Blackmouth School'
	FLOATING_WRECKAGE						= "Restos de Naufragio",
	FLOATING_DEBRIS							= "Restos de Goleta",
	ELEM_WATER								= "Agua elemental",
	OIL_SPILL								= "Perdita de Petr\195\179leo",

	GOLD_COIN								= "Moneda de Oro",
	SILVER_COIN								= "Moneda de Plata",
	COPPER_COIN								= "Moneda de Bronce",

	LAGER									= "Cerveza del Capit\195\161n Rumsey",

	--aca irian comandos, y, claro, quedan en ingles.

	NOREALM									= "Reino Desconocido",

	--aca irian comandos, y, claro, quedan en ingles.

	WEEKLY = "semanal",--revisar si es comando o no.
	HOURLY = "por hora",--revisar si es comando o no.

	OFFSET_LABEL_TEXT						= "Recompensa:";

	KEYS_LABEL_TEXT							= "Modificadores:",
	KEYS_NONE_TEXT							= "Ninguno",
	KEYS_SHIFT_TEXT							= "Shift",
	KEYS_CTRL_TEXT							= "Control",
	KEYS_ALT_TEXT							= "Alt",

	SHOWFISHIES								= "Muestra Pez",
	SHOWFISHIES_INFO						= "Muestra historial de pesca por tipo de pez.",

	SHOWLOCATIONS							= "Ubicaciones",
	SHOWLOCATIONS_INFO						= "Muestra hostorial de pesca por zona de pesca.",

	ALLZOMGPETS								= "Incluye todas las mascotas",

-- Option names and tooltips
	CONFIG_SHOWNEWFISHIES_ONOFF				= "Muestra nuevos peces",
	CONFIG_SHOWNEWFISHIES_INFO				= "Muestra un mensaje en el chat cuando la captura es nueva en el \195\161rea actual.",
	CONFIG_FISHWATCH_ONOFF					= "Registro",
	CONFIG_FISHWATCH_INFO					= "Muestra un texto con la captura en el \195\161rea actual.",
	CONFIG_FISHWATCHTIME_ONOFF				= "Mostrar tiempo restante",
	CONFIG_FISHWATCHTIME_INFO				= "Muestra la canntidad de tiempo desde que te equipaste la ca\195\177a.",
	CONFIG_FISHWATCHONLY_ONOFF				= "S\195\179lo cuando pescas",
	CONFIG_FISHWATCHONLY_INFO				= "S\195\179lo muestra capturas en el registro, si est\195\161s pescando actualmente.",
	CONFIG_FISHWATCHSKILL_ONOFF				= "Mostrar habilidad actual",
	CONFIG_FISHWATCHSKILL_INFO				= "Muestra habilidad y mods en el \195\161rea del registro.",
	CONFIG_FISHWATCHZONE_ONOFF				= "Mostrar zona actual",
	CONFIG_FISHWATCHZONE_INFO				= "Muestra la zona actual en el \195\161rea del registro.",
	CONFIG_FISHWATCHPERCENT_ONOFF			= "Mostrar porcentaje de los capturados",
	CONFIG_FISHWATCHPERCENT_INFO			= "Muestra el porcentaje de cada tipo de pez capturado en el registro.",

	CONFIG_EASYCAST_ONOFF					= "Casteo F\195\161cil",
	CONFIG_EASYCAST_INFO					= "Activa el Casteo con Doble-Click-Dcho.",
	CONFIG_AUTOLOOT_ONOFF					= "Auto despojar",
	CONFIG_AUTOLOOT_INFO					= "Si est\195\161 activado, se despojar\195\161 todo mientras pesc\195\161s.",
	CONFIG_USEACTION_ONOFF					= "Usar Acci\195\179n",
	CONFIG_USEACTION_INFO					= "Si est\195\161 activado, #NAME# will look for an action bar button to use for casting.", -- Se necesita traducir
	CONFIG_MOUNTEDCAST_ONOFF				= "Montado",
	CONFIG_MOUNTEDCAST_INFO					= "ISi est\195\161 activado, permite pescar montado.",

	CONFIG_EASYLURES_ONOFF					= "Se\195\177uelo F\195\161cil",
	CONFIG_EASYLURES_INFO 					= "Si est\195\161 activado, se aplicar\195\161 un se\195\177uelo a tu ca\195\177a antes de empezar a pescar siempre que lo necesites.",
	CONFIG_ALWAYSLURE_ONOFF					= "Se\195\177uelo eterno",
	CONFIG_ALWAYSLURE_INFO					= "Si est\195\161 activado, se aplicar\195\161 un se\195\177uelo a tu ca\195\177a siempre que lo necesites.",
	CONFIG_LASTRESORT_ONOFF					= "Se\195\177uelo de \195\186ltimo recurso",
	CONFIG_LASTRESORT_INFO					= "Si est\195\161 activado, agrega el mejor se\195\177uelo posible, a\195\186n si no llega a superar el 100% de chances de pescar.",

	CONFIG_SHOWLOCATIONZONES_ONOFF			= "Mostrar zonas",
	CONFIG_SHOWLOCATIONZONES_INFO			= "Muestra zonas y subzonas.",
	CONFIG_SORTBYPERCENT_ONOFF				= "Mostrar por n\195\186mero de capturas",
	CONFIG_SORTBYPERCENT_INFO				= "Ordena la pantalla con el n\195\186mero de peces capturados y no por el nombre.",
	CONFIG_TOOLTIPS_ONOFF					= "Mostrar info de pesca en tooltips",
	CONFIG_TOOLTIPS_INFO					= "Si est\195\161 activado, informaci\195\179n sobre las pesca del pez se mostrar\195\161 en el tooltip del \195\173tem.",
	CONFIG_ONLYMINE_ONOFF					= "Al equiparse la ca\195\177a...",
	CONFIG_ONLYMINE_INFO					= "Si est\195\161 activado, Casteo F\195\161cil s\195\179lo funcionar\195\161 si llevas la ca\195\177a (p.ej. no despojar\195\161 todo autom\195\161ticamente).",
	CONFIG_TURNOFFPVP_ONOFF					= "Desactivar PVP",
	CONFIG_TURNOFFPVP_INFO					= "Si est\195\161 activado, se desactivar\195\161 tu estado PVP mientras la ca\195\177a est\195\169 equipada.",


	CONFIG_ENHANCESOUNDS_ONOFF				= "Activa sonidos de pesca",
	CONFIG_ENHANCESOUNDS_INFO				= "Maximiza y minimiza el vol\195\186men del ambiente para que se aprecie mejor el sonido cuando se pesca.",

	CONFIG_BGSOUNDS_ONOFF					= "Sonidos de Fondo",
	CONFIG_BGSOUNDS_INFO						= "Si est\195\161 activado, se habilitar\195\161n sonidos cuando WoW est\195\169 minimizado.",
	CONFIG_SPARKLIES_ONOFF					= "Resaltar bancos",
	CONFIG_SPARKLIES_INFO					= "Si est\195\161 activado, los 'brillos' de los bancos de pesca ser\195\161n m\195\161s visibles.",
	CONFIG_MAXSOUND_ONOFF					= "Full Volume",
	CONFIG_MAXSOUND_INFO						= "If enabled, set the sound volume to the maximum while fishing.",--new
	CONFIG_TURNONSOUND_ONOFF				= "Force sound",--new
	CONFIG_TURNONSOUND_INFO					= "If enabled, always turn on sounds while fishing.",--new

	CONFIG_AUTOOPEN_ONOFF					= "Abrir items de Misi\195\179n",
	CONFIG_AUTOOPEN_INFO					= "Si est\195\161 activado, use el doble-Click para abrir los items de misi\195\179n de pesca.",

	CONFIG_FISHINGFLUFF_ONOFF				= "Entretenimiento al pescar",
	CONFIG_FISHINGFLUFF_INFO				= "Activa todos los tipos de entretenimiento mientras pesc\195\161s.",
	CONFIG_FINDFISH_ONOFF					= "Buscar Peces",
	CONFIG_FINDFISH_INFO					= "Act\195\173valo para rastrear autom\195\161ticamente los bancos de peces.",
	CONFIG_DRINKHEAVILY_ONOFF				= "Beber Cerveza",
	CONFIG_DRINKHEAVILY_INFO				= "Si est\195\161 activado, beber\195\161s #LAGER# mientras pesc\195\161s y est\195\169s 'sediento'.",
	CONFIG_FISHINGBUDDY_ONOFF				= "Fishing Buddy",
	CONFIG_FISHINGBUDDY_INFO				= "Bring out that special buddy while you fish.", -- Se necesita traducir

	CONFIG_WATCHBOBBER_ONOFF				= "Ver el Anzuelo",
	CONFIG_WATCHBOBBER_INFO					= "Si est\195\161 activado, #NAME# no castear\195\161 si el cursor est\195\161 sobre el anzuelo.",

	CONFIG_CONTESTS_ONOFF					= "Soporte del Concursos de Pesca",
	CONFIG_CONTESTS_INFO					= "Muestra temporizadores en los Concuros de Pesca.",

	CONFIG_STVTIMER_ONOFF					= "Gran Concurso de Pesca de Tuercespina",
	CONFIG_STVTIMER_INFO					= "Si est\195\161 activado, muestra la cuenta atr\195\161s para el comienzo del Gran Concurso de Pesca de Tuercespina y muestra el tiempo restante.",
	CONFIG_STVPOOLSONLY_ONOFF				= "Casteo s\195\179lo en Estanques",
	CONFIG_STVPOOLSONLY_INFO				= "Si est\195\161 activado, Casteo F\195\161cil estar\195\161 activado s\195\179lo si el cursor est\195\161 sobre un hueco de pesca.", -- Se necesita corregir
	CONFIG_DERBYTIMER_ONOFF					= "Temporizador en Concurso",
	CONFIG_DERBYTIMER_INFO					= "Si est\195\161 activado, muestra un contador cuando comienza el Concurso de Pesca en Kalu'ak mostr\195\161ndo el tiempo restante.",
	CONFIG_SHOWPOOLS_ONOFF					= "Mostrar Estanques",
	CONFIG_SHOWPOOLS_INFO					= "Si est\195\161 activado, los Estanques conocidos se mostrar\195\161n en el minimapa.",

	CONFIG_OUTFITTER_TEXT					= "Bonus equipo habilidad: %s\r\nPuntuaci\195\179n estilo Draznar's: %d ";

	CLICKTOSWITCH_ONOFF						= "Click para cambiar",
	CLICKTOSWITCH_INFO						= "Si est\195\161 activado, Click-Izq Cambia equipos, sino saltar\195\161 la ventana de #NAME#.",

	LEFTCLICKTODRAG							= "Click-Izq para mover",
	RIGHTCLICKFORMENU						= "Click-Dcho para el men\195\186",

	MINIMAPBUTTONPLACEMENT					= "Posici\195\179n del Bot\195\179n",
	MINIMAPBUTTONPLACEMENTTOOLTIP			= "Permite mover el \195\173cono de #NAME# alrededor del minimapa.",
	MINIMAPBUTTONRADIUS						= "Distancia",
	MINIMAPBUTTONRADIUSTOOLTIP				= "Determina qu\195\169 tan lejos del minimapa deber\195\173a estar #NAME#.",
	CONFIG_MINIMAPBUTTON_ONOFF				= "Mostrar \195\173cono en minimapa",
	CONFIG_MINIMAPBUTTON_INFO				= "Muestra el \195\173cono de #NAME# en el minimapa.",

	HIDEINWATCHER							= "Mostrar este pescado en el Registro",

-- messages
	COMPATIBLE_SWITCHER						= "Equipador de Conjuntos incompatible encontrado.",
	TOOMANYFISHERMEN						= "Tienes m\195\161s de un AddOn con Casteo F\195\161cil instalados.",
	FAILEDINIT								= "No inicializ\195\179 correctamente.",
	ADDFISHIEMSG							= "A\195\177adiendo %s a la zona %s.",
	ADDSCHOOLMSG							= "A\195\177adiendo '%s' a la zona %s.",
	NODATAMSG								= "No hay datos de pesca disponibles.",
	CLEANUP_NONEMSG							= "No quedan ajustes ant\195\173guos.",
	CLEANUP_WILLMSG							= "Ajustes ant\195\173guos quedan para |c#GREEN#%s|r: %s.",
	CLEANUP_DONEMSG							= "Borrados ajustes ant\195\173guos para |c#GREEN#%s|r: %s.",
	CLEANUP_NOOLDMSG						= "No hay ajustes ant\195\173guos para jugador |c#GREEN#%s|r.",
	NONEAVAILABLE_MSG						= "No disponible",
	UPDATEDB_MSG							= "Actualizado(s) %d nombre(s) de pez(ces).",

	MINIMUMSKILL							= "Habilidad M\195\173nima: %d",
	NOTLINKABLE								= "<Link Roto>",
	CAUGHTTHISMANY							= "Despojados:",
	CAUGHTTHISTOTAL							= "Total:",
	FISHTYPES								= "Tipos de peces: %d",
	CAUGHT_IN_ZONES							= "Despojados en: %s",

	EXTRAVAGANZA							= "El Gran Concurso de Tuercespina",
	DERBY									= "Competici\195\179n",
	
	TIMETOGO								= "%s comienza en %d:%02d",
	TIMELEFT								= "%s acaba en %d:%02d",
	
	FATLADYSINGS							= "|c#RED#El Gran Concurso de Pesca de Tuercespina finaliz\195\179|r (%d:%02d left)",

	-- Riggle Bassbait yells: We have a winner! NAME is the Master Angler!
	RIGGLE_BASSBAIT							= "^Riggle Anzuelo grita: Tenemos un ganador!\s+(%a+)\s+es el Maestro Pescador!",
	ELDER_CLEARWATER						= "Elder Clearwater grita: (%a)+ ha ganado el concurso de pesca de Kalu'ak!",

	STVZONENAME								= "Vega de Tuercespina",

	TOOLTIP_HINT							= "Consejo:",
	TOOLTIP_HINTSWITCH						= "Click para cambiar el equipo",
	TOOLTIP_HINTTOGGLE						= "Click para mostar la ventana de #NAME#.",

	SWITCH_HELP								= "|c#GREEN#/fb #SWITCH#|r#BRSPCS#Intercambio de conjuntos (si 'OutfitDisplayFrame' u 'Outfitter' est\195\161n instalados)",
	WATCHER_HELP							= "|c#GREEN#/fb #WATCHER#|r [|c#GREEN##WATCHER_LOCK#|r o |c#GREEN##WATCHER_UNLOCK#|r o |c#GREEN##RESET#|r]#BRSPCS#Desbloquea el registro para mover la ventana,#BRSPCS#bloqu\195\169ala para mantenerla y resetear para recargarla.",
	CURRENT_HELP							= "|c#GREEN#/fb #CURRENT# #RESET#|r#BRSPCS#Resetea el registro de peces de la sesi\195\179n actual.",
	UPDATEDB_HELP							= "|c#GREEN#/fb #UPDATEDB# [#FORCE#]|r#BRSPCS#Busca los los peces que se les rompi\195\179 el link.#BRSPCS#An attempt is made to skip 'rare' fish that may disconnect you#BRSPCS#from the server -- use the '#FORCE#' option to override the check.",--falta traducier el resto
	TIMERRESET_HELP							= "|c#GREEN#/fb #TIMER# #RESET#|r#BRSPCS#einicia la ubicaci\195\179n del reloj del 'Gran Concurso de Pesca de Tuercespina', desplaz\195\169ndolo hacia#BRSPCS#el centro de la pantalla.",
	PRE_HELP								= "Puedes usar |c#GREEN#/fishingbuddy|r o |c#GREEN#/fb|r para todos los comandos#BR#|c#GREEN#/fb|r: solamente, abre/cierra la ventana del 'Fishing Buddy'.#BR#|c#GREEN#/fb #HELP#|r: muestra este mensaje.",
	POST_HELP								= "You can bind both the window toggle and the outfit#BR#switch command to keys in the \"Key Bindings\" window.",-- Se necesita traducir

	THANKS									= "\194\161Gracias a todos!",
	
	ROLE_TRANSLATE_ZHTW						= "Traducci\195\179n Chin\195\169s Tradicional",
	ROLE_TRANSLATE_ZHCN						= "Traducci\195\179n Chin\195\169s Simplificado",
	ROLE_TRANSLATE_DEDE						= "Traducci\195\179n Germana",
	ROLE_TRANSLATE_FRFR						= "Traducci\195\179n Francesa",
	ROLE_TRANSLATE_ESES						= "Traducci\195\179n Castellana",
	ROLE_TRANSLATE_KOKR						= "Traducci\195\179n Coreana",
	ROLE_TRANSLATE_RURU						= "Traducci\195\179n Rusa",
	ROLE_HELP_BUGS							= "Errores corregidos y ayuda sobre el c\195\179digo",
	ROLE_HELP_SUGGESTIONS					= "Sugerencias sobre Caracter\195\173sticas",
	ROLE_ADDON_AUTHORS						= "Notas del Autor",
};

FishingTranslations["esMX"] = {
	-- per WindShak, we only need one set of translations now
}

if ( GetLocale() == "esMX" ) then
	for tag,value in pairs(FishingTranslations["esES"]) do
		if ( not FishingTranslations["esMX"][tag] ) then
			FishingTranslations["esMX"][tag] = value;
		end
	end
end
