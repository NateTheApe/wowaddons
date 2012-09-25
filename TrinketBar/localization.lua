local _, L = ...
local locale = GetLocale()

if locale == "deDE_" then -- German translation
	
elseif locale == "esES" or locale == "esMX" then -- Spanish translation
	L["Top Trinket"] = "Trinket Primer"
	L["Bottom Trinket"] = "Trinket Segundo"
	L["Drag me!"] = "¡Arrastrarme!"
	L["TrinketBar Config"] = "TrinketBar Configuración"
	L["TrinketBar"] = "TrinketBar"
	L["Locked"] = "Bloqueado"
	L["Click to lock/unlock frames"] = "Haga clic para bloquear y desbloquear las celdas"
	L["Hide Addon"] = "Esconder Celda"
	L["Click to hide/show the main Bars"] = "Haga clic para mostrar/esconder las celdas"
	L["Trinket Queueing"] = "Trinket Colas"
	L["Click to toggle Trinket Queueing"] = "Haga clic para activar Trinket Colas"
	L["Show Tooltip"] = "Mostrar tooltip"
	L["Click to toggle tooltip display"] = "Haga clic para mostrar tooltip"
	L["Horizontal"] = "Horizontal"
	L["Click to set Horizontal orientation"] = "Haga clic para establecer la orientación Horizontal"
	L["Vertical"] = "Vertical"
	L["Click to set Vertical orientation"] = "Haga clic para establecer la orientación Vertical"
	L["Bar Orientation:"] = "Bar Orientación:"
	L["Menu Toggle Key:"] = "Menú Activar clave:"
	L["Bar Scale: "] = "Bar Escala: "
	L["Drag to set Main Bar Scale"] = "Arrastre para ajustar la escala bar principal"
	L["Smaller"] = "Más Pequeño"
	L["Larger"] = "Más Grande"
	L["Menu Scale: "] = "Menú Escala: "
	L["Drag to set Menu Scale"] = "Arrastre para ajustar el Menú Escala"
	L["Wrap menu at rows: "] = "Envuelva menú en filas: "
	L["Sets how many rows before a new line is displayed"] = "Establece el número de filas antes de una nueva línea se muestra"
	L["Key Bindings"] = "Teclado"
	L["Reset Position"] = "Restablecer posición"
	L["Usage:"] = "Uso:"
	L["Hold down" ] = "Mantenga presionada la tecla "
	L["while mouseover to open the menu."] = "mientras mouseover para abrir el menú."
	L["Click Left Mousebutton to equip a trinket in the top slot."] = "Haga clic en botón izquierdo del ratón para equipar una trinket en la ranura primera."
	L["Click Right Mousebutton to equip a trinket in the bottom slot."] = "Haga clic en botón derecho del ratón para equipar una baratija en la ranura segunda."
	L["type /tb for slash commands"] = "tipo /tb para los comandos"
	L["Bars Unlocked"] = "Bar Desbloqueado"
	L["Bars Locked"] = "Bar Bloqueado"
	L["Position Reset"] = "Posición Inicial" 
	L["Bars Shown"] = "Bar Mostrado"
	L["Bars Hidden"] = "Bar Escondido"
	L["<command>"] = "<comando>"
	L["Locks/Unlocks Bar"] = "Bloquea/Desbloquea Bar"
	L["Hide/Show Bar"] = "Esconder/Mostrar Bar"
	L["Resets Bar Position"] = "Restablece el posición del Bar"
	L["Opens up Interface Options"] = "Abre opciones de la interfaz"
	L["Help"] = "Ayuda"
-- elseif locale == "frFR" then -- -- French translation
elseif locale == "koKR" then -- Korean translation by hellguard
	L["Top Trinket"] = "상단 장신구(우측)"
	L["Bottom Trinket"] = "하단 장신구(좌측)"
	L["Drag me!"] = "드래그로 이동!"
	L["TrinketBar Config"] = "TrinketBar 설정"
	L["TrinketBar"] = "TrinketBar"
	L["Locked"] = "잠금"
	L["Click to lock/unlock frames"] = "장신구바 위치 잠그고 풀기 전환"
	L["Hide Addon"] = "장신구 버튼 숨김"
	L["Click to hide/show the main Bars"] = "장신구바를 보이고 숨기기 전환"
	L["Trinket Queueing"] = "장신구 교체"
	L["Click to toggle Trinket Queueing"] = "장신구 교체 기능을 전환 합니다."
	L["Show Tooltip"] = "툴팁 보이기"
	L["Click to toggle tooltip display"] = "장신구 바에 툴팁 보이고 숨기기 전환"
	L["Horizontal"] = "수평 정렬"
	L["Click to set Horizontal orientation"] = "장신구 바를 수평으로 정렬합니다."
	L["Vertical"] = "수직 정렬"
	L["Click to set Vertical orientation"] = "장신구 바를 수직으로 정렬합니다."
	L["Bar Orientation:"] = "바 위치설정:"
	L["Menu Toggle Key:"] = "교체 장신구 전환키 설정:"
	L["Bar Scale: "] = "장신구 바 크기: "
	L["Drag to set Main Bar Scale"] = "슬라이드바의 기준점을 마우스로 이동시켜 장신구 바의 크기를 조절합니다."
	L["Smaller"] = "작게"
	L["Larger"] = "크게"
	L["Menu Scale: "] = "대체 장신구 버튼 크기: "
	L["Drag to set Menu Scale"] = "슬라이드바의 기준점을 마우스로 이동시켜 대체 장신구 버튼의 크기를 조절합니다."
	L["Wrap menu at rows: "] = "열당 대체 장신구 표시 수: "
	L["Sets how many rows before a new line is displayed"] = "한열에 표시할 대체 장신구의 수를 지정합니다."
	L["Key Bindings"] = "단축키 설정"
	L["Reset Position"] = "위치 초기화"
	L["Usage:"] = "사용법:"
	L["Hold down" ] = "" -- ommit (because different order of Korean)
	L["while mouseover to open the menu."] = "키를 누른체로 대체 장신구 버튼에 마우스를 가져가면 장신구 버튼이 펼쳐집니다."
	L["Click Left Mousebutton to equip a trinket in the top slot."] = "이때 마우스 왼쪽 클릭을 하면 장신구 버튼의 위쪽(또는 오른쪽)으로 교체 장비하게되며"
	L["Click Right Mousebutton to equip a trinket in the bottom slot."] = "마우스 오른 클릭을 하면 장신구 버튼의 아래쪽(또는 왼쪽)으로 교체 장비되어 집니다."
	L["type /tb for slash commands"] = "대화창에 '/tb'명령어를 사용하여 설정창을 엽니다."
	L["Bars Unlocked"] = "장신구 바의 이동이 가능합니다."
	L["Bars Locked"] = "장신구 바의 이동이 불가합니다."
	L["Position Reset"] = "장신구바의 위치를 초기화 합니다."
	L["Bars Shown"] = "장신구바를 보여줍니다."
	L["Bars Hidden"] = "장신구바를 숨깁니다."
	L["<command>"] = "<명령어>"
	L["Locks/Unlocks Bar"] = "장신구 버튼 이동 잠금/해제"
	L["Hide/Show Bar"] = "장신구 버튼 보이기/숨기기"
	L["Resets Bar Position"] = "장신구 버튼 위치 초기화"
	L["Opens up Interface Options"] = "인터페이스 설정창 열기"
	L["Help"] = "도움말"
-- elseif locale == "ruRU" then -- Russian translation
elseif locale == "zhTW" then -- Traditional Chinese translation by oldriver
	L["Top Trinket"] = "上方飾品"
    L["Bottom Trinket"] = "下方飾品"
    L["Drag me!"] = "拖動我!"
    L["TrinketBar Config"] = "飾品條設定"
    L["TrinketBar"] = "飾品條"
    L["Locked"] = "已鎖定位置"
    L["Click to lock/unlock frames"] = "點一下 鎖動/解鎖 框架"
    L["Hide Addon"] = "隱藏插件"
    L["Click to hide/show the main Bars"] = "點一下 隱藏/顯示 飾品條"
    L["Trinket Queueing"] = "依序使用飾品"
    L["Click to toggle Trinket Queueing"] = "點一下切換飾品序列"
    L["Show Tooltip"] = "顯示訊息提示"
    L["Click to toggle tooltip display"] = "點一下切換訊息提示顯示"
    L["Horizontal"] = "橫向"
    L["Click to set Horizontal orientation"] = "點一下切換橫向排列"
    L["Vertical"] = "直向"
    L["Click to set Vertical orientation"] = "點一下切換直向排列"
    L["Bar Orientation:"] = "飾品條選項:"
    L["Menu Toggle Key:"] = "開起選單按鍵:"
    L["Bar Scale: "] = "飾品條比例: "
    L["Drag to set Main Bar Scale"] = "拖動好縮放飾品條比例"
    L["Smaller"] = "較小"
    L["Larger"] = "較大"
    L["Menu Scale: "] = "選單比例: "
    L["Drag to set Menu Scale"] = "拖動好縮放選單比例"
    L["Wrap menu at rows: "] = "跳出選單的行數: "
    L["Sets how many rows before a new line is displayed"] = "在新的一行顯示前先設定行數"
    L["Key Bindings"] = "熱鍵"
    L["Reset Position"] = "重設位置"
    L["Usage:"] = "使用:"
    L["Hold down" ] = "停止"
    L["while mouseover to open the menu."] = "當滑鼠移置上方時顯示選單."
    L["Click Left Mousebutton to equip a trinket in the top slot."] = "點左鍵將飾品裝備到上方欄位."
    L["Click Right Mousebutton to equip a trinket in the bottom slot."] = "點右鍵將飾品裝備到下方欄位."
    L["type /tb for slash commands"] = "輸入 /tb 以獲得更多指定"
    L["Bars Unlocked"] = "飾品條未鎖定"
    L["Bars Locked"] = "飾品條已鎖定"
    L["Position Reset"] = "重新設定位置"
    L["Bars Shown"] = "顯示飾品條"
    L["Bars Hidden"] = "隱藏飾品條"
    L["<command>"] = "<指令>"
    L["Locks/Unlocks Bar"] = "鎖定/解鎖飾品條"
    L["Hide/Show Bar"] = "隱藏/顯示飾品條"
    L["Resets Bar Position"] = "還原飾品條選項"
    L["Opens up Interface Options"] = "開起介面設定"
    L["Help"] = "幫助"

else -- English defaults
	L["Top Trinket"] = "Top Trinket"
	L["Bottom Trinket"] = "Bottom Trinket"
	L["Drag me!"] = "Drag me!"
	L["TrinketBar Config"] = "TrinketBar Config"
	L["TrinketBar"] = "TrinketBar"
	L["Locked"] = "Locked"
	L["Click to lock/unlock frames"] = "Click to lock/unlock frames"
	L["Hide Addon"] = "Hide Addon"
	L["Click to hide/show the main Bars"] = "Click to hide/show the main Bars"
	L["Trinket Queueing"] = "Trinket Queueing"
	L["Click to toggle Trinket Queueing"] = "Click to toggle Trinket Queueing"
	L["Show Tooltip"] = "Show Tooltip"
	L["Click to toggle tooltip display"] = "Click to toggle tooltip display"
	L["Horizontal"] = "Horizontal"
	L["Click to set Horizontal orientation"] = "Click to set Horizontal orientation"
	L["Vertical"] = "Vertical"
	L["Click to set Vertical orientation"] = "Click to set Vertical orientation"
	L["Bar Orientation:"] = "Bar Orientation:"
	L["Menu Toggle Key:"] = "Menu Toggle Key:"
	L["Bar Scale: "] = "Bar Scale: "
	L["Drag to set Main Bar Scale"] = "Drag to set Main Bar Scale"
	L["Smaller"] = "Smaller"
	L["Larger"] = "Larger"
	L["Menu Scale: "] = "Menu Scale: "
	L["Drag to set Menu Scale"] = "Drag to set Menu Scale"
	L["Wrap menu at rows: "] = "Wrap menu at rows: "
	L["Sets how many rows before a new line is displayed"] = "Sets how many rows before a new line is displayed"
	L["Key Bindings"] = "Key Bindings"
	L["Reset Position"] = "Reset Position"
	L["Usage:"] = "Usage:"
	L["Hold down" ] = "Hold down "
	L["while mouseover to open the menu."] = "while mouseover to open the menu."
	L["Click Left Mousebutton to equip a trinket in the top slot."] = "Click Left Mousebutton to equip a trinket in the top slot."
	L["Click Right Mousebutton to equip a trinket in the bottom slot."] = "Click Right Mousebutton to equip a trinket in the bottom slot."
	L["type /tb for slash commands"] = "type /tb for slash commands"
	L["Bars Unlocked"] = "Bars Unlocked"
	L["Bars Locked"] = "Bars Locked"
	L["Position Reset"] = "Position Reset" 
	L["Bars Shown"] = "Bars Shown"
	L["Bars Hidden"] = "Bars Hidden"
	L["<command>"] = "<command>"
	L["Locks/Unlocks Bar"] = "Locks/Unlocks Bar"
	L["Hide/Show Bar"] = "Hide/Show Bar"
	L["Resets Bar Position"] = "Resets Bar Position"
	L["Opens up Interface Options"] = "Opens up Interface Options"
	L["Help"] = "Help"
end