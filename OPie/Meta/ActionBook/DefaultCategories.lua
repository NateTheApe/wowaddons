local AB = assert(OneRingLib.ext.ActionBook:compatible(1,2), "Requires a compatible ActionBook library version")

do -- spellbook
	local spells, mark = {}, {}
	local function search()
		local ni, i, st, sid, ok = 1, 1
		for i=1,select(3,GetSpellTabInfo(3)) do
			i, ok, st, sid = i + 1, pcall(GetSpellBookItemInfo, i, "spell")
			if st == "SPELL" and not IsPassiveSpell(sid) and ((mark[sid] or ni) >= ni or spells[mark[sid]] ~= sid) then
				spells[ni], mark[sid], ni = sid, ni, ni + 1
			end
		end
		for i=#spells,ni,-1 do
			spells[i] = nil
		end
		return ni-1
	end
	AB:category("Abilities", search, function(id) return "spell", spells[id] end)
end
do -- Items
	local items, seen = {}, {}
	local function search()
		local i = 1
		for bag=0,4 do
			for slot=1,GetContainerNumSlots(bag) do
				local iid = GetContainerItemID(bag, slot)
				if iid and GetItemSpell(iid) and (seen[iid] or i) >= i then
					items[i], seen[iid], i = iid, i, i+1
				end
			end
		end
		for slot=INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
			if GetItemSpell(GetInventoryItemLink("player", slot)) then
				items[i], i = GetInventoryItemID("player", slot), i + 1
			end
		end
		for j=#items,i,-1 do
			items[j] = nil
		end
		return i-1
	end
	AB:category("Items", search, function(id) return "item",items[id] end)
end
do -- Battle pets
	local pets, running, sourceFilters, typeFilters, flagFilters, search = {}, false, {}, {}, {[LE_PET_JOURNAL_FLAG_COLLECTED]=1, [LE_PET_JOURNAL_FLAG_FAVORITES]=1, [LE_PET_JOURNAL_FLAG_NOT_COLLECTED]=1}, ""
	hooksecurefunc(C_PetJournal, "SetSearchFilter", function(filter) search = filter end)
	hooksecurefunc(C_PetJournal, "ClearSearchFilter", function() if not running then search = "" end end)
	local function queryAndCount()
		assert(not running, "Battle pets enumerator is not reentrant")
		running = true
		for i=1, C_PetJournal.GetNumPetSources() do
			sourceFilters[i] = not C_PetJournal.IsPetSourceFiltered(i)
		end
		C_PetJournal.AddAllPetSourcesFilter()
		
		for i=1, C_PetJournal.GetNumPetTypes() do
			typeFilters[i] = not C_PetJournal.IsPetTypeFiltered(i)
		end
		C_PetJournal.AddAllPetTypesFilter()
		
		-- There's no API to retrieve the filter, so rely on hooks
		C_PetJournal.ClearSearchFilter()
		
		for k in pairs(flagFilters) do
			flagFilters[k] = not C_PetJournal.IsFlagFiltered(k)
		end
		C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_COLLECTED, true)
		C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_FAVORITES, false)
		C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_NOT_COLLECTED, false)
		
		local isWild, ni = true, 1 -- Because apparently, there are wild pets. Nobody has seen any, though
		repeat
			for i=1,C_PetJournal.GetNumPets(isWild) do
				pets[ni], ni = C_PetJournal.GetPetInfoByIndex(i, isWild), ni + 1
			end
			isWild = not isWild
		until isWild
		for j=ni,#pets do pets[j] = nil end
		
		for k, v in pairs(flagFilters) do
			C_PetJournal.SetFlagFilter(k, v)
		end
		for i=1,#typeFilters do
			C_PetJournal.SetPetTypeFilter(i, typeFilters[i])
		end
		for i=1,#sourceFilters do
			C_PetJournal.SetPetSourceFilter(i, sourceFilters[i])
		end		
		C_PetJournal.SetSearchFilter(search)
		
		running = false
		
		return #pets
	end
	AB:category("Battle pets", queryAndCount, function(id) return "battlepet", pets[id] end)	
end
AB:category("Mounts", function() return GetNumCompanions("MOUNT") end, function(id)
	return "spell", (select(3, GetCompanionInfo("MOUNT", id)))
end)
AB:category("Macros", function() local a,b = GetNumMacros() return a+b+1 end, function(id)
	if id == 1 then return "macrotext", "" end
	id = id - 1
	local g, p = GetNumMacros()
	if id > 0 and id <= g then
		return "macro", (GetMacroInfo(id))
	elseif id > g and id <= (g+p) then
		return "macro", (GetMacroInfo(id-g+36))
	end
end)
AB:category("Equipment sets", function() return GetNumEquipmentSets() end, function(id)
	return "equipmentset", (GetEquipmentSetInfo(id))
end)
AB:category("Raid markers", function() return 14 end, function(id) return id <= 8 and "raidmark" or "worldmark", id <= 8 and id or (id - 8) end)