local addonName, addonTable = ...
local L = {}
addonTable.L = L

L["<Item Link>"] = "<Item Link>"
L["Add item"] = "Add item"
L["Added"] = "Added"
L["Automatically sell junk"] = "Automatically sell junk"
L["Clear"] = "Clear"
L["Clear exceptions"] = "Clear exceptions"
L["Command accepts only itemlinks."] = "Command accepts only itemlinks."
L["Destroyed"] = "Destroyed"
L["Drag item into this window to add/remove it from exception list"] = "Drag item into this window to add/remove it from exception list"
L["Exceptions"] = "Exceptions"
L["Exceptions succesfully cleared."] = "Exceptions succesfully cleared."
L["Gained"] = "Gained"
L["Prints itemlinks to chat, when automatically selling items."] = "Prints itemlinks to chat, when automatically selling items."
L["Remove item"] = "Remove item"
L["Removed"] = "Removed"
L["Removes all exceptions."] = "Removes all exceptions."
L["Sell Junk"] = "Sell Junk"
L["Sell max. 12 items"] = "Sell max. 12 items"
L["Show 'item sold' spam"] = "Show 'item sold' spam"
L["Show gold gained"] = "Show gold gained"
L["Shows gold gained from selling trash."] = "Shows gold gained from selling trash."
L["Sold"] = "Sold"
L["This is failsafe mode. Will sell only 12 items in one pass. In case of an error, all items can be bought back from vendor."] = "This is failsafe mode. Will sell only 12 items in one pass. In case of an error, all items can be bought back from vendor."
L["Toggles the automatic selling of junk when the merchant window is opened."] = "Toggles the automatic selling of junk when the merchant window is opened."
L["copper"] = "copper"
L["gold"] = "gold"
L["silver"] = "silver"


if GetLocale() == "ptBR" then

L["<Item Link>"] = "<Link do Item>"
L["Add item"] = "Adicionar item"
L["Added"] = "Adicionado"
L["Automatically sell junk"] = "Vender lixo automaticamente"
L["Clear"] = "Remover"
L["Clear exceptions"] = "Remover exceções"
L["Command accepts only itemlinks."] = "O Comando aceita somente link dos itens"
L["Destroyed"] = "Destruído"
L["Drag item into this window to add/remove it from exception list"] = "Arraste o item dentro desta janela para adicionar/remover da lista de exceções"
L["Exceptions"] = "Exceções"
L["Exceptions succesfully cleared."] = "exceções removidas com sucesso."
L["Gained"] = "Ganhou"
L["Prints itemlinks to chat, when automatically selling items."] = "Exibir link dos itens no chat, quando vender itens automaticamente."
L["Remove item"] = "Remover item"
L["Removed"] = "Removido"
L["Removes all exceptions."] = "Remove todas as exceções."
L["Sell Junk"] = "Vender Lixo"
L["Sell max. 12 items"] = "Vender no máx. 12 itens"
L["Show 'item sold' spam"] = "Mostrar spam 'item vendido'"
L["Show gold gained"] = "Mostrar ouro ganho"
L["Shows gold gained from selling trash."] = "Mostra o ouro ganho por vender lixo."
L["Sold"] = "Vendido"
L["This is failsafe mode. Will sell only 12 items in one pass. In case of an error, all items can be bought back from vendor."] = "Esse é o modo de segurança. irá vender apenas 12 itens por vez. Em caso de erro, todos os itens podem ser comprados devolta do vendedor."
L["Toggles the automatic selling of junk when the merchant window is opened."] = "Alterna a venda automática de lixo quando a janela do comerciante é aberta."
L["copper"] = "de cobre"
L["gold"] = "de ouro"
L["silver"] = "de prata"


end

if GetLocale() == "frFR" then

L["<Item Link>"] = "Lien" -- Needs review
L["Add item"] = "Ajouter l'objet" -- Needs review
L["Added"] = "Ajouté" -- Needs review
L["Automatically sell junk"] = "Vente automatique" -- Needs review
L["Clear"] = "Tout effacer" -- Needs review
L["Clear exceptions"] = "Effacer exceptions" -- Needs review
L["Command accepts only itemlinks."] = "Commande accepte uniquement les liens des items" -- Needs review
L["Destroyed"] = "Détruit" -- Needs review
L["Drag item into this window to add/remove it from exception list"] = "Déplacer l'objet dans la fenêtre pour l'ajouter/supprimer de la liste des exceptions" -- Needs review
L["Exceptions"] = "Exceptions générales" -- Needs review
L["Exceptions succesfully cleared."] = "Exceptions effacé." -- Needs review
L["Gained"] = "Gain" -- Needs review
L["Prints itemlinks to chat, when automatically selling items."] = "Imprime le lien d'un article vers le chat, lors de la vente automatique des objets." -- Needs review
L["Remove item"] = "Supprimer l'objet" -- Needs review
L["Removed"] = "Supprimé" -- Needs review
L["Removes all exceptions."] = "Supprime toutes les exceptions à la liste globale." -- Needs review
L["Sell Junk"] = "Vendre" -- Needs review
L["Sell max. 12 items"] = "Vente max. 12 objets" -- Needs review
L["Show 'item sold' spam"] = "Montre 'les items vendu' " -- Needs review
L["Show gold gained"] = "Montrer les gains" -- Needs review
L["Shows gold gained from selling trash."] = "Montrer les gains sur les monstres" -- Needs review
L["Sold"] = "Vendu" -- Needs review
L["This is failsafe mode. Will sell only 12 items in one pass. In case of an error, all items can be bought back from vendor."] = "Mode sauvegarde. Vendra que 12 objets maximum en une seule fois. En cas d'erreur, les objets pourront être rachetés au marchand." -- Needs review
L["Toggles the automatic selling of junk when the merchant window is opened."] = "Vendre automatiquement les objets gris lorsque la fenêtre du marchand est ouverte" -- Needs review
L["copper"] = "Cuivre" -- Needs review
L["gold"] = "Or" -- Needs review
L["silver"] = "Argent" -- Needs review


end

if GetLocale() == "deDE" then

L["<Item Link>"] = "<Gegenstands-Link>" -- Needs review
L["Add item"] = "Gegenstand hinzufügen:" -- Needs review
L["Added"] = "Hinzugefügt" -- Needs review
L["Automatically sell junk"] = "Ramsch automatisch verkaufen" -- Needs review
L["Clear"] = "Globale löschen" -- Needs review
L["Clear exceptions"] = "Ausnahmelisten löschen" -- Needs review
L["Command accepts only itemlinks."] = "Befehlt akzeptiert nur Gegenstandslinks." -- Needs review
L["Destroyed"] = [=[Gelöscht

Wird ausgegeben, wenn Gegenstände aus dem Inventar gelöscht werden - Gelöscht <gegenstand>]=] -- Needs review
L["Drag item into this window to add/remove it from exception list"] = "Gegenstand in dieses Fenster ziehen, um ihn in der Ausnahmenliste hinzuzufügen oder zu entfernen" -- Needs review
L["Exceptions"] = "Globale Ausnahmen" -- Needs review
L["Exceptions succesfully cleared."] = "Ausnahmen erfolgreich entfernt." -- Needs review
L["Gained"] = "Erlös:" -- Needs review
L["Prints itemlinks to chat, when automatically selling items."] = "Gibt beim automatischen Verkauf von Gegenständen die dazugehörigen Links im Chat-Fenster aus." -- Needs review
L["Remove item"] = "Gegenstand entfernen:" -- Needs review
L["Removed"] = "Entfernt" -- Needs review
L["Removes all exceptions."] = "Entfernt alle globalen Ausnahmen" -- Needs review
L["Sell Junk"] = "Ramsch verk." -- Needs review
L["Sell max. 12 items"] = "Verkaufe max. 12 Gegenstände" -- Needs review
L["Show 'item sold' spam"] = "Zeige \"Gegenstand verkauft\" Mitteilungen an" -- Needs review
L["Show gold gained"] = "Erlös anzeigen" -- Needs review
L["Shows gold gained from selling trash."] = "Zeigt den Erlös vom Ramsch-Verkauf." -- Needs review
L["Sold"] = "Verkauft:" -- Needs review
L["This is failsafe mode. Will sell only 12 items in one pass. In case of an error, all items can be bought back from vendor."] = "Abgesicherter Modus. Es werden nur 12 Gegenstände auf einmal verkauft, sodass diese bei Fehlern noch beim Händler zurückgekauft werden können." -- Needs review
L["Toggles the automatic selling of junk when the merchant window is opened."] = "Schaltet das automatische Verkaufen von Ramsch bei geöffnetem Händler-Fenster ein oder aus." -- Needs review
L["copper"] = "Kupfer" -- Needs review
L["gold"] = "Gold" -- Needs review
L["silver"] = "Silber" -- Needs review


end

if GetLocale() == "koKR" then

L["<Item Link>"] = "<아이템 링크>" -- Needs review
L["Add item"] = "아이템 추가:" -- Needs review
L["Added"] = "추가되었습니다." -- Needs review
L["Automatically sell junk"] = "회색 아이템을 자동으로 상인에게 파시겠습니까?" -- Needs review
L["Clear"] = "공통 지우기" -- Needs review
L["Clear exceptions"] = "제외 항목 지우기" -- Needs review
-- L["Command accepts only itemlinks."] = ""
L["Destroyed"] = "파괴" -- Needs review
L["Drag item into this window to add/remove it from exception list"] = "이 창에 아이템을 드래그 하면 제외목록으로 부터 추가/삭제됩니다." -- Needs review
L["Exceptions"] = "전체 제외항목" -- Needs review
L["Exceptions succesfully cleared."] = "제외 항목을 성공적으로 지웠습니다." -- Needs review
L["Gained"] = "금액:" -- Needs review
L["Prints itemlinks to chat, when automatically selling items."] = "아이템 판매시 자동으로 채팅창에 아이템을 링크 합니다." -- Needs review
L["Remove item"] = "아이템 제거:" -- Needs review
L["Removed"] = "삭제되었습니다." -- Needs review
L["Removes all exceptions."] = "공통 목록에서 모든 제외 항목을 제거 합니다." -- Needs review
L["Sell Junk"] = "잡템 판매" -- Needs review
L["Sell max. 12 items"] = "최대 12 아이템 판매" -- Needs review
L["Show 'item sold' spam"] = "'아이템 판매' 내용 보기" -- Needs review
L["Show gold gained"] = "골드 획득 표시" -- Needs review
L["Shows gold gained from selling trash."] = "잡템 판패로 골드 획득을 표시 합니다." -- Needs review
L["Sold"] = "판매:" -- Needs review
L["This is failsafe mode. Will sell only 12 items in one pass. In case of an error, all items can be bought back from vendor."] = "이것은 안전 모드입니다. 한번에 오직 12개의 아이템만 판매합니다. 만약 실수로 판매하더라도 해당 갯수 내에서는 상인에게 되살수 있습니다." -- Needs review
L["Toggles the automatic selling of junk when the merchant window is opened."] = "상점 창이 열렸을 때 자동으로 회색 아이템을 판매하는 것을 키거나 끕니다." -- Needs review
L["copper"] = "코퍼" -- Needs review
L["gold"] = "골드" -- Needs review
L["silver"] = "실버" -- Needs review


end

if GetLocale() == "esMX" then

-- L["<Item Link>"] = ""
-- L["Add item"] = ""
-- L["Added"] = ""
-- L["Automatically sell junk"] = ""
-- L["Clear"] = ""
-- L["Clear exceptions"] = ""
-- L["Command accepts only itemlinks."] = ""
-- L["Destroyed"] = ""
-- L["Drag item into this window to add/remove it from exception list"] = ""
-- L["Exceptions"] = ""
-- L["Exceptions succesfully cleared."] = ""
-- L["Gained"] = ""
-- L["Prints itemlinks to chat, when automatically selling items."] = ""
-- L["Remove item"] = ""
-- L["Removed"] = ""
-- L["Removes all exceptions."] = ""
-- L["Sell Junk"] = ""
-- L["Sell max. 12 items"] = ""
-- L["Show 'item sold' spam"] = ""
-- L["Show gold gained"] = ""
-- L["Shows gold gained from selling trash."] = ""
-- L["Sold"] = ""
-- L["This is failsafe mode. Will sell only 12 items in one pass. In case of an error, all items can be bought back from vendor."] = ""
-- L["Toggles the automatic selling of junk when the merchant window is opened."] = ""
-- L["copper"] = ""
-- L["gold"] = ""
-- L["silver"] = ""


end

if GetLocale() == "ruRU" then

L["<Item Link>"] = "<Прямая ссылка на предмет>"
L["Add item"] = "Добавить предмет:"
L["Added"] = "Добавлено"
L["Automatically sell junk"] = "Продавать \"хлам\" автоматически"
L["Clear"] = "Очистить список исключений"
L["Clear exceptions"] = "Очистить исключения"
L["Command accepts only itemlinks."] = "Принимаются только прямые ссылки на предметы."
L["Destroyed"] = "Уничтожено"
L["Drag item into this window to add/remove it from exception list"] = "Перетащите предмет в это окошко, чтобы добавить или удалить его из списка исключений"
L["Exceptions"] = "Общие исключения"
L["Exceptions succesfully cleared."] = "Исключения успешно очищены."
L["Gained"] = "Выручка:"
L["Prints itemlinks to chat, when automatically selling items."] = "Выводит прямые ссылки на предметы в чат во время автоматической продажи предметов."
L["Remove item"] = "Убрать предмет"
L["Removed"] = "Убрано"
L["Removes all exceptions."] = "Убирает все исключения из общего списка."
L["Sell Junk"] = "Продать хлам"
L["Sell max. 12 items"] = "Продавать не более 12 предметов"
L["Show 'item sold' spam"] = "Показывать сообщения \"предмет продан\""
L["Show gold gained"] = "Показывать выручку"
L["Shows gold gained from selling trash."] = "Показывает выручку с продажи мусора."
L["Sold"] = "Продано: "
L["This is failsafe mode. Will sell only 12 items in one pass. In case of an error, all items can be bought back from vendor."] = "Безопасный режим. Продает не более 12 предметов.  В случае ошибки, любой из предметов может быть выкуплен у продавца обратно."
L["Toggles the automatic selling of junk when the merchant window is opened."] = "Включить или отключить автоматическую продажу мусора при открытии окна торговли."
L["copper"] = "медных"
L["gold"] = "золотых"
L["silver"] = "серебряных"


end

if GetLocale() == "zhCN" then

L["<Item Link>"] = "<物品链接>" -- Needs review
L["Add item"] = "添加物品：" -- Needs review
L["Added"] = "已添加" -- Needs review
L["Automatically sell junk"] = "自动贩卖垃圾" -- Needs review
L["Clear"] = "清除全局" -- Needs review
L["Clear exceptions"] = "清除例外" -- Needs review
L["Command accepts only itemlinks."] = "命令只接受物品链接." -- Needs review
L["Destroyed"] = "已摧毁" -- Needs review
L["Drag item into this window to add/remove it from exception list"] = "拖动物品到这个窗口来添加/删除例外物品" -- Needs review
L["Exceptions"] = "全局例外" -- Needs review
L["Exceptions succesfully cleared."] = "例外列表成功的清除." -- Needs review
L["Gained"] = "获得:" -- Needs review
L["Prints itemlinks to chat, when automatically selling items."] = "当自动出售物品后，在聊天框中显示物品出售的详情信息选项。" -- Needs review
L["Remove item"] = "移除物品：" -- Needs review
L["Removed"] = "已移除" -- Needs review
L["Removes all exceptions."] = "移除所有的全局例外列表." -- Needs review
L["Sell Junk"] = "卖垃圾" -- Needs review
L["Sell max. 12 items"] = "出售最多12件物品." -- Needs review
L["Show 'item sold' spam"] = "显示物品出售的详情信息" -- Needs review
L["Show gold gained"] = "显示获得金币" -- Needs review
L["Shows gold gained from selling trash."] = "显示出售垃圾获得的金币." -- Needs review
L["Sold"] = "售出: " -- Needs review
L["This is failsafe mode. Will sell only 12 items in one pass. In case of an error, all items can be bought back from vendor."] = "这是安全模式.一次将只出售12件物品.可以重新买回错误出售的所有物品." -- Needs review
L["Toggles the automatic selling of junk when the merchant window is opened."] = "与商人交易时自动贩卖包裹中的垃圾物品" -- Needs review
L["copper"] = "铜" -- Needs review
L["gold"] = "金" -- Needs review
L["silver"] = "银" -- Needs review


end

if GetLocale() == "esES" then

L["<Item Link>"] = "<Enlace Objeto>"
L["Add item"] = "Añadir objeto"
L["Added"] = "Añadido"
L["Automatically sell junk"] = "Vender basura automáticamente"
L["Clear"] = "Borrar"
L["Clear exceptions"] = "Borrar excepciones"
L["Command accepts only itemlinks."] = "El comando sólo acepta enlaces de objetos."
L["Destroyed"] = "Destruído"
L["Drag item into this window to add/remove it from exception list"] = "Arrastra un objeto a esta ventana para añadirlo/eliminarlo de la lista de excepciones"
L["Exceptions"] = "Excepciones"
L["Exceptions succesfully cleared."] = "Excepciones borradas correctamente."
L["Gained"] = "Recibido"
L["Prints itemlinks to chat, when automatically selling items."] = "Muestra los enlaces a los objetos en el chat, cuando son vendidos automáticamente."
L["Remove item"] = "Eliminar objeto"
L["Removed"] = "Eliminado"
L["Removes all exceptions."] = "Borra todas las excepciones."
L["Sell Junk"] = "Vender Basura"
L["Sell max. 12 items"] = "Vender máx. 12 objetos"
L["Show 'item sold' spam"] = "Mostrar spam de 'objeto vendido'"
L["Show gold gained"] = "Mostrar oro ganado"
L["Shows gold gained from selling trash."] = "Muestra el oro que recibes al vender la basura."
L["Sold"] = "Vendido"
L["This is failsafe mode. Will sell only 12 items in one pass. In case of an error, all items can be bought back from vendor."] = "Éste es el modo a prueba de fallos. Venderá sólo 12 artículos de una sola vez. En caso de equivocación, todos los artículos se pueden volver a comprar de nuevo al vendedor."
L["Toggles the automatic selling of junk when the merchant window is opened."] = "Vender automáticamente la basura cuando la ventana de un vendedor está abierta."
L["copper"] = "cobre"
L["gold"] = "oro"
L["silver"] = "plata"


end

if GetLocale() == "zhTW" then

L["<Item Link>"] = "<物品鏈結>" -- Needs review
L["Add item"] = "新增物品" -- Needs review
L["Added"] = "已新增" -- Needs review
L["Automatically sell junk"] = "自動販賣" -- Needs review
L["Clear"] = "清除全局例外" -- Needs review
L["Clear exceptions"] = "清除例外" -- Needs review
L["Command accepts only itemlinks."] = "命令僅允許物品鏈接" -- Needs review
L["Destroyed"] = "已摧毀" -- Needs review
L["Drag item into this window to add/remove it from exception list"] = "拖動物品到這個視窗來新增/移除例外物品" -- Needs review
L["Exceptions"] = "共同列外物品" -- Needs review
L["Exceptions succesfully cleared."] = "例外成功清除" -- Needs review
L["Gained"] = "獲得:" -- Needs review
L["Prints itemlinks to chat, when automatically selling items."] = "自動售出物品時將物品鏈接發送至聊天窗口" -- Needs review
L["Remove item"] = "移除物品:" -- Needs review
L["Removed"] = "已移除" -- Needs review
L["Removes all exceptions."] = "將全局列表中的所有例外移除" -- Needs review
L["Sell Junk"] = "賣垃圾" -- Needs review
L["Sell max. 12 items"] = "每次只販售最多12樣物品" -- Needs review
L["Show 'item sold' spam"] = "顯示“物品已售出”信息" -- Needs review
L["Show gold gained"] = "顯示金錢獲得" -- Needs review
L["Shows gold gained from selling trash."] = "顯示販售垃圾所獲得的金額" -- Needs review
L["Sold"] = "售出: " -- Needs review
L["This is failsafe mode. Will sell only 12 items in one pass. In case of an error, all items can be bought back from vendor."] = "這是個安全模式。每次只販售最多12樣物品。當設定錯誤時可以從商人處買回所有物品" -- Needs review
L["Toggles the automatic selling of junk when the merchant window is opened."] = "與商人交易時自動販賣包裹中的垃圾物品" -- Needs review
L["copper"] = "銅" -- Needs review
L["gold"] = "金" -- Needs review
L["silver"] = "銀" -- Needs review


end