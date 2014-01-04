local AB, _, T = assert(OneRingLib.ext.ActionBook:compatible(1,8), "Requires a compatible ActionBook library version"), ...
local EV, spellFeedback, itemFeedback = T.Evie

do -- spell: player's spellbook, mounts
	local function currentShapeshift()
		local id, n = GetShapeshiftForm()
		if id == 0 then return end
		id, n = GetShapeshiftFormInfo(id)
		return n
	end
	local actionMap, spellMap, companionMap, csidMap = {}, {}, {}, {}
	local companionUpdate do -- maintain companionMap/csidMap
		function companionUpdate(event)
			local changed = false
			for i=1,GetNumCompanions("MOUNT") do
				local crid, cname, sid = GetCompanionInfo("MOUNT", i)
				local sname, srank = GetSpellInfo(sid)
				local rname = (sname .. "(" .. (srank or "") .. ")") -- Paladin/Warlock/Death Knight horses have spell ranks
				changed = changed or (csidMap[sid] == nil)
				csidMap[sid], companionMap[sid], companionMap[sname], companionMap[sname:lower()], companionMap[rname], companionMap[rname:lower()] = 
					i, rname, sid, sid, sid, sid
			end
			if changed then AB:notify("spell") end
			if event == "PLAYER_ENTERING_WORLD" then return "remove" end
		end
		function OneRingLib.xlu.companionSpellCache(sname)
			return companionMap[sname]
		end
		EV.RegisterEvent("COMPANION_LEARNED", companionUpdate)
		EV.RegisterEvent("PLAYER_ENTERING_WORLD", companionUpdate)
	end

	local function SetSpellBookItem(self, id)
		return self:SetSpellBookItem(id, BOOKTYPE_SPELL)
	end
	local function hint(aid, target)
		local n = actionMap[aid]
		if not n then return end
		local csid, time = companionMap[n], GetTime()
		if csid then
			local usable = (not (InCombatLockdown() or IsIndoors())) and not UnitIsDeadOrGhost("player")
			local cdStart, cdLength, cdEnabled = GetSpellCooldown(csid)
			local _, cname, acsid, icon, active = GetCompanionInfo("MOUNT", csidMap[csid])
			if acsid ~= csid then
				companionUpdate()
				_, cname, _, icon, active = GetCompanionInfo("MOUNT", csidMap[csid])
			end
			return usable and cdStart == 0, active and 1 or 0, icon, cname, 0, (cdStart or 0) > 0 and (cdStart+cdLength-time) or 0, cdLength, GameTooltip.SetSpellByID, csid
		end
		local inRange, usable, nomana = IsSpellInRange(n, aid == false and target or "target") ~= 0, IsUsableSpell(n)
		local usable, cooldown, cdLength, enabled = usable and inRange, GetSpellCooldown(n)
		local cdLeft = (cooldown or 0) > 0 and (enabled ~= 0) and (cooldown + cdLength - time) or 0
		local count, charges, maxCharges, chargeStart, chargeDuration = GetSpellCount(n), GetSpellCharges(n)
		local state = ((IsSelectedSpellBookItem(n) or IsCurrentSpell(n) or n == currentShapeshift() or enabled == 0) and 1 or 0) +
									(IsSpellOverlayed(spellMap[n] or 0) and 2 or 0) + (nomana and 8 or 0) + (inRange and 0 or 16) + (charges and charges > 0 and 64 or 0)
		usable = not not (usable and (cooldown == nil or cooldown == 0) or (enabled == 0))
		if charges and maxCharges and charges < maxCharges and cdLeft == 0 then
			cdLeft, cdLength = chargeStart-time + chargeDuration, chargeDuration
		end
		local sbslot = spellMap[n] and FindSpellBookSlotBySpellID(spellMap[n])
		return usable, state, GetSpellTexture(n), n, count <= 1 and charges or count, cdLeft, cdLength, sbslot and SetSpellBookItem or spellMap[n] and GameTooltip.SetSpellByID, sbslot or tonumber((GetSpellLink(n) or ""):match("spell:(%d+)")) or spellMap[n]
	end
	function spellFeedback(sname, target, spellId)
		actionMap[false], spellMap[sname] = sname, spellId or spellMap[sname] or tonumber((GetSpellLink(sname) or ""):match("spell:(%d+)"))
		return hint(false, target)
	end
	
	AB:register("spell", function(id)
		if type(id) ~= "number" then return end
		local action = companionMap[id]
		if not action then
			local s0, r0 = GetSpellInfo(id)
			local o, s, r = pcall(GetSpellInfo, s0, r0)
			if not (o and s and r and s0) then return end
			action = s0
		end
		if not actionMap[action] then
			local aid = AB:create("attribute", hint, "type","spell", "spell",action)
			actionMap[aid], actionMap[action], spellMap[action], spellMap[action:lower()] = action, aid, id, id
		end
		return actionMap[action]
	end, function(id)
		local name2, _, icon2, name, sname, icon = nil, nil, nil, GetSpellInfo(id)
		if name then name2, _, icon2 = GetSpellInfo(name, sname) end
		
		return csidMap[id] and "Mount" or "Spell", name2 or name, icon2 or icon, nil, GameTooltip.SetSpellByID, id
	end)
	EV.RegisterEvent("SPELLS_CHANGED", function() AB:notify("spell") end)
end
do -- item: an item by ID, inventory slot
	local actionMap, itemIdMap, lastSlot = {}, {}, INVSLOT_LAST_EQUIPPED
	local function hint(aid, target)
		local ident, name, link, icon, _ = actionMap[aid]
		if itemIdMap[aid] and itemIdMap[aid] <= lastSlot then
			local invid = GetInventoryItemID("player", itemIdMap[aid])
			if invid == nil then return false, 0, "Interface/Icons/INV_Misc_QuestionMark", "", 0, 0, 0 end
			name, link = GetItemInfo(invid)
			if name then ident = name end
		else
			name, link, _, _, _, _, _, _, _, icon = GetItemInfo(ident)
		end
		local iid, cdStart, cdLen, cdEnabled = (link and tonumber(link:match("item:(%d+)"))) or itemIdMap[aid]
		if iid then cdStart, cdLen, cdEnabled = GetItemCooldown(iid) end
		local inRange = IsItemInRange(ident, aid == false and target or "target") ~= 0
		return (cdLen or 0) == 0 and ((GetItemSpell(ident) == nil) or (IsUsableItem(ident) and inRange)), (IsCurrentItem(ident) and 1 or 0) + (inRange and 0 or 16),
			icon or GetItemIcon(ident), name or ident, GetItemCount(ident, false, true) or 0,
			(cdStart or 0) > 0 and (cdStart - GetTime() + cdLen) or 0, cdLen or 0,
			iid and GameTooltip.SetItemByID, iid
	end
	function itemFeedback(name, target)
		actionMap[false] = name
		return hint(false, target)
	end
	AB:register("item", function(id, byName, forceShow, onlyEquipped)
		if type(id) ~= "number" then return end
		local name = id <= lastSlot and tostring(id) or (byName and GetItemInfo(id) or ("item:" .. id))
		if not forceShow and onlyEquipped and not ((id > lastSlot and IsEquippedItem(name)) or (id <= lastSlot and GetInventoryItemLink("player", id))) then return end
		if not forceShow and GetItemCount(name) == 0 then return end
		if not actionMap[name] then
			local aid = AB:create("attribute", hint, "type","item", "item",name)
			actionMap[name], actionMap[aid], itemIdMap[aid] = aid, name, id
		end
		return actionMap[name]
	end, function(id) return "Item", GetItemInfo(id), GetItemIcon(id), nil, GameTooltip.SetItemByID, tonumber(id) end, {"byName", "forceShow", "onlyEquipped"})
	EV.RegisterEvent("BAG_UPDATE", function() AB:notify("item") end)
end
do -- macro, macrotext: built in macro (by name) or custom macros (by text)
	local castAlias = {[SLASH_CAST1]=0,[SLASH_CAST2]=0,[SLASH_CAST3]=0,[SLASH_CAST4]=0,[SLASH_USE1]=0,[SLASH_USE2]=0,[SLASH_STOPMACRO1]=2,[SLASH_STOPMACRO2]=2,[SLASH_CASTSEQUENCE1]=3,[SLASH_CASTSEQUENCE2]=3,[SLASH_CASTRANDOM1]=4,[SLASH_CASTRANDOM2]=4}
	local function compact(cache, macrotext)
		if type(macrotext) ~= "string" then return "" end
		local macro = "\n" .. macrotext .. "\n"
		local show, gen = macro:match("\n#[Ss][Hh][Oo][Ww]%a*[^%S\n]+([^\n]-)%s-\n") or "", ""
		if show ~= "" then return "\a" .. show end
		for name, args in macro:gmatch("\n(/%S+)[^%S\n]*([^\n]*)") do
			local ctype = castAlias[name] or castAlias[name:lower()]
			if ctype then
				if ctype < 3 then 
					args = ("\a" .. args):gsub("([;%]]%s*)", "%1\a")
				end
				gen = gen .. args:match("^%s*(.-)%s*$") .. "; "
			end
		end
		cache[macrotext] = gen
		return gen
	end
	local compactMacros = setmetatable({}, {__index=compact})
	local fixConditionalModifiers do
		local cache, map, a,s,c = {}
		local function fixModifierClause(open, invert, params, close)
			local al, sh, ct, empty = true, true, true, (open == "[" and close == "]" and "[]") or (open == "[" and open or close)
			if params ~= "" then
				al, sh, ct, params = params:match("alt"), params:match("shift"), params:match("ctrl"), ""
			end
			if ((al and a) or (sh and s) or (ct and c)) then
				return invert == "no" and (open .. "mod,nomod" .. close) or empty
			elseif ((al and a == false) or (sh and s == false) or (ct and c == false)) then
				if al and a ~= false then params = "alt" end
				if sh and s ~= false then params = params .. (params == "" and "" or "/") .. "shift" end
				if ct and c ~= false then params = params .. (params == "" and "" or "/") .. "ctrl" end
				if params == "" then return invert == "no" and empty or (open .. "mod,nomod" .. close) end
				return open .. invert .. "mod:" .. params .. close
			end
		end
		local function fixConditional(whole)
			return whole:gsub("([,%[])%s*(n?o?)modi?f?i?e?r?:?([^,%]]-)%s*([,%]])", fixModifierClause)
		end
		function fixConditionalModifiers(text, alt, shift, ctrl)
			local ident = (alt and "A" or (alt == false and "a" or "-")) .. (shift and "S" or (shift == false and "s" or "-")) .. (ctrl and "C" or (ctrl == false and "c" or "-")) .. text
			if not cache[ident] then
				a, s, c = alt, shift, ctrl
				cache[ident] = text:gsub("%b[]", fixConditional)
			end
			return cache[ident]
		end
	end
	local function hint(text, altState, shiftState, ctrlState)
		if type(text) ~= "string" then return end
		if text == "" then return true, 0, "Interface/Icons/Temp", "Macro", 0, 0, 0 end
		if altState ~= nil or shiftState ~= nil or ctrlState ~= nil then
			text = fixConditionalModifiers(text, altState, shiftState, ctrlState)
		end
		local clause, target = SecureCmdOptionParse(text)
		if not clause or clause == "" then return end
		local cclause, ccount = clause:gsub("\a", "")
		local index, item, spell = 0, cclause, cclause
		if ccount == 0 then
			index, item, spell = QueryCastSequence(clause)
		end
		if item then
			local iname, ilink = GetItemInfo(SecureCmdItemParse(item))
			if ilink then
				return itemFeedback(iname, target)
			end
		end
		return spellFeedback(spell, target)
	end

	local macroMap, macrotextMap = {}, {}
	local function hintMacro(aid, ...)
		local name, icon, m = GetMacroInfo(macroMap[aid])
		m = name and compactMacros[m] or ""
		if m ~= "" then return hint(m, ...) end
		return not not name, 0, icon, name, 0, 0, 0
	end
	local function hintMacrotext(aid, ...)
		return hint(macrotextMap[aid], ...)
	end
	AB:register("macro", function(name, forceShow)
		if type(name) ~= "string" or (not GetMacroInfo(name) and not forceShow) then return end
		if not macroMap[name] then
			local aid = AB:create("attribute", hintMacro, "type","macro", "macro",name)
			macroMap[aid], macroMap[name] = name, aid
		end
		return macroMap[name]
	end, function(name)
		local n, ico = GetMacroInfo(name)
		return "Macro", n or name, ico
	end, {"forceShow"})
	AB:register("macrotext", function(macrotext)
		if type(macrotext) ~= "string" then return end
		if not macrotextMap[macrotext] then
			local aid = AB:create("attribute", hintMacrotext, "type","macro", "macrotext",macrotext)
			macrotextMap[aid], macrotextMap[macrotext] = compactMacros[macrotext], aid
		end
		return macrotextMap[macrotext]
	end, function(macrotext)
		if macrotext == "" then return "Custom Macro", "New Macro", "Interface/Icons/Temp" end
		local _, _, ico = hint(compactMacros[macrotext])
		return "Custom Macro", "", ico
	end)
	EV.RegisterEvent("UPDATE_MACROS", function() AB:notify("macro") end)
	AB:miscaction("macrotext", "")
end
do -- battlepet (pet id)
	local petAction, actionPet, tipIdt, tipLvt = {}, {}, {}, {}
	local function tip(self, id)
		local sid, cname, lvl, xp, mxp, _, _, name, icon, ptype, _, _, _, _, cb = C_PetJournal.GetPetInfoByPetID(id)
		if not sid then return false end
		local hp, mhp, ap, spd, rarity = C_PetJournal.GetPetStats(id)
		local qc, nc, icof = ITEM_QUALITY_COLORS[rarity-1], HIGHLIGHT_FONT_COLOR, "|TInterface\\PetBattles\\PetBattle-StatIcons:0:0:0:0:32:32:%d:%d:%d:%d|t %s"
		self:AddLine(cname or name, qc.r, qc.g, qc.b)
		if cb then
			self:AddLine(UNIT_TYPE_LEVEL_TEMPLATE:format(lvl, _G["BATTLE_PET_NAME_".. ptype]), nc.r, nc.g, nc.b)
			self:AddLine(icof:format(0, 16, 0, 16, ap) .. "   " .. icof:format(0, 16, 16, 32, spd) .. "   " .. icof:format(16,32,16,32, hp < mhp and (hp .. "/" .. mhp) or hp), nc.r, nc.g, nc.b)
		end
	end
	local function hint(id)
		local pid = actionPet[id]
		local sid, cn, _, _, _, _, _, n, tex = C_PetJournal.GetPetInfoByPetID(pid)
		local cooldown, duration, enabled = C_PetJournal.GetPetCooldownByGUID(pid)
		local cdLeft = (cooldown or 0) > 0 and (enabled ~= 0) and (cooldown + duration - GetTime())
		return sid and not cdLeft, C_PetJournal.GetSummonedPetGUID() == pid and 1 or 0, tex, cn or n or "", 0, cdLeft or 0, duration or 0, tip, pid
	end
	local function create(pid)
		if type(pid) == "number" then return create(("0x%016X"):format(pid)) end
		if not C_PetJournal.GetPetInfoByPetID(pid) then return end
		pid = pid:gsub("%x", string.upper)
		if not petAction[pid] then
			petAction[pid] = AB:create("func", hint, C_PetJournal.SummonPetByGUID, pid)
			actionPet[petAction[pid]] = pid
		end
		return petAction[pid]
	end
	local function describe(pid)
		if type(pid) == "number" then return describe(("0x%016X"):format(pid)) end
		local _, cn, lvl, _, _, _, _, n, tex = C_PetJournal.GetPetInfoByPetID(pid)
		if (cn or n) and ((lvl or 0) > 1) then cn = "[" .. lvl .. "] " .. (cn or n) end
		return "Battle Pet", cn or n or ("#" .. tostring(pid)), tex, nil, tip, pid
	end
	AB:register("battlepet", create, describe)
end
do -- equipmentset: an equipment set, by name
	local setMap = {}
	local function hint(aid)
		local name = setMap[aid]
		local icon, _, active, total, equipped, available = GetEquipmentSetInfoByName(name)
		return total == equipped or (available > 0), active and 1 or 0, "interface/icons/" .. icon, name, nil, 0, 0, GameTooltip.SetEquipmentSet, name
	end
	AB:register("equipmentset", function(name)
		if type(name) ~= "string" or not GetEquipmentSetInfoByName(name) then return end
		if not setMap[name] then
			setMap[name] = AB:create("attribute", hint, "type","macro", "macrotext", (SLASH_EQUIP_SET1 or "/equipset") .. " " .. name)
			setMap[setMap[name]] = name
		end
		return setMap[name]
	end, function(name)
		return "Equipment Set", name, "Interface/Icons/" .. (GetEquipmentSetInfoByName(tostring(name)) or "INV_Misc_QuestionMark"), nil, GameTooltip.SetEquipmentSet, name
	end)
end
do -- raidmark
	local rmap, map = {}, {}
	local function click(id)
		if GetRaidTargetIndex("target") == id then id = 0 end
		SetRaidTarget("target", id)
	end
	local function hint(aid)
		local i = map[aid]
		return (not IsInRaid() or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and not (UnitIsEnemy("player", "target") and UnitIsPlayer("target")),
			GetRaidTargetIndex("target") == i and 1 or 0, "Interface/TargetingFrame/UI-RaidTargetingIcon_" .. i, _G["RAID_TARGET_" .. i], 0, 0, 0
	end
	for i=1,8 do
		rmap[i] = AB:create("func", hint, click, i)
		map[rmap[i]] = i
	end
	AB:register("raidmark", function(id) return rmap[id] end, function(id) return "Raid Marker", _G["RAID_TARGET_" .. id], "Interface/TargetingFrame/UI-RaidTargetingIcon_" .. id end)
end
do -- worldmarker
	local map, rmap, icons = {}, {}, {"Interface/Icons/INV_Misc_QirajiCrystal_04","Interface/Icons/INV_Misc_QirajiCrystal_03",
		"Interface/Icons/INV_Misc_QirajiCrystal_05","Interface/Icons/INV_Misc_QirajiCrystal_02",
		"Interface/Icons/INV_Misc_QirajiCrystal_01","Interface/Icons/INV_Misc_PunchCards_White"}
	local function hinter(id)
		local i = map[id]
		return not not (IsInGroup() and (not IsInRaid() or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") or IsEveryoneAssistant())), i < 6 and IsRaidMarkerActive(i) and 1 or 0, icons[i], i == 6 and REMOVE_WORLD_MARKERS or _G["WORLD_MARKER" .. i], 0, 0, 0
	end
	for i=1,5 do
		rmap[i] = AB:create("attribute", hinter, "type","worldmarker", "action","toggle", "marker",i)
		map[rmap[i]] = i
	end
	rmap[6] = AB:create("attribute", hinter, "type","macro", "macrotext",SLASH_CLEAR_WORLD_MARKER1 .. " " .. ALL)
	map[rmap[6]] = 6
	AB:register("worldmark", function(id) return rmap[id] end, function(id) return "Raid World Marker", id == 6 and REMOVE_WORLD_MARKERS or _G["WORLD_MARKER" .. id], icons[id] end)
end
do -- opie.databroker.launcher
	local nameMap, LDB = {}
	local function checkLDB()
		LDB = LibStub and LibStub:GetLibrary("LibDataBroker-1.1", 1)
	end
	local function call(obj, btn)
		obj:OnClick(btn)
	end
	local function describe(name)
		local obj = (LDB or checkLDB() or LDB) and LDB:GetDataObjectByName(name);
		return "Launcher", obj and obj.label or name, obj and obj.icon or "Interface/Icons/INV_Misc_QuestionMark", obj
	end
	local function hint(id)
		local obj = nameMap[id]
		if not obj then return end
		return true, 0, obj.icon, obj.label or obj.text or name, 0,0,0, obj.OnTooltipShow, nil, obj
	end
	local function create(name, rightClick)
		if type(name) ~= "string" or not (LDB or checkLDB() or LDB) then return end
		local pname = name .. "#" .. (rightClick and "R" or "L") 
		if not nameMap[pname] then
			local obj = LDB:GetDataObjectByName(name)
			if not obj then return end
			nameMap[pname] = AB:create("func", hint, call, obj, rightClick and "RightButton" or "LeftButton")
			nameMap[nameMap[pname]] = obj
		end
		return nameMap[pname]
	end
	AB:register("opie.databroker.launcher", create, describe, {"clickUsingRightButton"})
end
do -- extrabutton: extra action bar button 1
	local slot = GetExtraBarIndex()*12 - 11
	local function hint()
		if not HasExtraActionBar() then
			return false, 0, "Interface/Icons/temp", "", 0, 0, 0
		end
		local at, aid = GetActionInfo(slot)
		local inRange, usable, nomana = IsActionInRange(slot) ~= 0, IsUsableAction(slot)
		local usable, cooldown, cdLength, enabled = usable and inRange, GetActionCooldown(slot)
		local cdLeft = (cooldown or 0) > 0 and (enabled ~= 0) and (cooldown + cdLength - GetTime()) or 0
		local count, charges, maxCharges = GetActionCount(slot), GetActionCharges(slot)
		local state = ((IsCurrentAction(slot) or enabled == 0) and 1 or 0) +
		              (at == "spell" and IsSpellOverlayed(aid) and 2 or 0) +
		              (nomana and 8 or 0) + (inRange and 0 or 16) + (charges and charges > 0 and 64 or 0)
		usable = not not (usable and ((cooldown == nil or cooldown == 0) or (enabled == 0) or (charges > 0)))
		return usable, state, GetActionTexture(slot), GetActionText(slot) or (at == "spell" and GetSpellInfo(aid)), count <= 1 and charges or count, cdLeft, cdLength, GameTooltip.SetAction, slot
	end
	local aid = AB:create("conditional", hint, "[extrabar]", "attribute", "type","action", "action",slot)
	local aid2 = AB:create("attribute", hint, "type","action", "action",slot)
	AB:register("extrabutton", function(id, forceShow)
		return id == 1 and (forceShow and aid2 or aid) or nil
	end, function(id)
		local name, tex = "Extra Action Button", "Interface/Icons/Temp"
		if HasExtraActionBar() then 
			local at, aid = GetActionInfo(slot)
			name, tex = GetActionText(slot) or (at == "spell" and GetSpellInfo(aid)) or name, GetActionTexture(slot) or tex
		end
		return "Extra Action Button", name, tex
	end, {"forceShow"})
	AB:miscaction("extrabutton", 1)
end
do -- petspell: pet spellbook
	local spellID, actionID = {}, {}
	local actionInfo = { {"Interface\\Icons\\Spell_Nature_TimeStop", "PET_ACTION_WAIT"}, {"Interface\\Icons\\Ability_Hunter_Pet_Goto", "PET_ACTION_MOVE_TO", 1}, {"Interface\\Icons\\Ability_Tracking", "PET_ACTION_FOLLOW"}, {"Interface\\Icons\\Ability_GhoulFrenzy", "PET_ACTION_ATTACK"},
		{"Interface\\Icons\\Ability_Defend", "PET_MODE_DEFENSIVE"}, {"Interface\\Icons\\Ability_Hunter_Pet_Assist", "PET_MODE_ASSIST"}, {"Interface\\Icons\\Ability_Seal", "PET_MODE_PASSIVE"} }
	local reqSpell do
		local _, class = UnitClass("player")
		reqSpell = class == "HUNTER" and 93321 or class == "WARLOCK" and 93375
		reqSpell = reqSpell and ("FindSpellBookSlotBySpellID(" .. reqSpell .. ", false) and ") or ""
	end
	local function petTip(self, slot)
		return self:SetSpellBookItem(slot, "pet")
	end
	local function hint(id)
		local sid = spellID[id]
		if not sid then
		elseif sid < 0 and sid > -8 then
			local info, slot = actionInfo[-sid]
			local ico, name, slot = info[1], info[2], info[3]
			if GetSpellBookItemTexture(slot or 0, "pet") ~= ico then
				slot = nil
				for i=1,HasPetSpells() or 0 do
					if GetSpellBookItemTexture(i, "pet") == ico and GetSpellBookItemInfo(i, "pet") == "PETACTION" then
						info[3], slot = i, i
						break
					end
				end
			end
			return not not slot, slot and IsSelectedSpellBookItem(slot, "pet") and 1 or 0, ico, _G[name] or (slot and GetSpellBookItemName(i, "pet")) or "", 0, 0, 0, slot and petTip or nil, slot
		else
			return spellFeedback(sid, nil, sid)
		end
	end
	local function create(id)
		if type(id) == "number" and id > 0 and not actionID[id] then
			local aid = AB:create("conditional", hint, "-- \nreturn " .. reqSpell .. "FindSpellBookSlotBySpellID(" .. id .. ", true) or nil", "attribute", "type","spell", "spell",id)
			actionID[id], spellID[aid] = aid, id
		end
		return actionID[id]
	end
	local function describe(id)
		if type(id) ~= "number" then
			local aid = actionID[id]
			if not aid then return end
			local _, _, icon, name, _, _, _, tipf, tipa = hint(aid)
			local _, st = GetSpellBookItemName(tipa or 0, "pet")
			return st or "Pet Ability", name, icon, nil, tipf, tipa
		end
		local name, _, icon = GetSpellInfo(id)
		return "Pet Ability", name, icon, nil, GameTooltip.SetSpellByID, id
	end
	local cnd = "[@pet,help,novehicleui]"
	if reqSpell ~= "" then
		cnd = ("-- \nreturn %s SecureCmdOptionParse(%q)"):format(reqSpell, cnd)
	end
	actionID.stay = AB:create("conditional", hint, cnd, "attribute", "type","macro", "macrotext",SLASH_PET_STAY1)
	actionID.move = AB:create("conditional", hint, cnd, "attribute", "type","macro", "macrotext",SLASH_PET_MOVE_TO1)
	actionID.follow = AB:create("conditional", hint, cnd, "attribute", "type","macro", "macrotext",SLASH_PET_FOLLOW1)
	actionID.attack = AB:create("conditional", hint, cnd, "attribute", "type","macro", "macrotext",SLASH_PET_ATTACK1)
	actionID.defend = AB:create("conditional", hint, cnd, "attribute", "type","macro", "macrotext",SLASH_PET_DEFENSIVE1)
	actionID.assist = AB:create("conditional", hint, cnd, "attribute", "type","macro", "macrotext",SLASH_PET_ASSIST1)
	actionID.passive = AB:create("conditional", hint, cnd, "attribute", "type","macro", "macrotext",SLASH_PET_PASSIVE1)
	spellID[actionID.stay], spellID[actionID.move], spellID[actionID.follow], spellID[actionID.attack] = -1, -2, -3, -4
	spellID[actionID.defend], spellID[actionID.assist], spellID[actionID.passive] = -5, -6, -7
	AB:register("petspell", create, describe)
end