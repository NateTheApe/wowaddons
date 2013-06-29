local AB = assert(OneRingLib.ext.ActionBook:compatible(1,5), "Requires a compatible version of ActionBook")
local ORI = OneRingLib.ext.OPieUI

local function generateColor(c, n)
	local hue, v, s = (15+(c-1)*360/n) % 360, 1, 0.85
	local h, f = floor(hue/60) % 6, (hue/60) % 1
	local p, q, t = v - v*s, v - v*f*s, v - v*s + v*f*s

	if h == 0 then return v, t, p;
	elseif h == 1 then return q, v, p;
	elseif h == 2 then return p, v, t;
	elseif h == 3 then return p, q, v;
	elseif h == 4 then return t, p, v;
	elseif h == 5 then return v, p, q;
	end
end

do -- OPieTrinkets
	OneRingLib:SetRing("OPieTrinkets", {
		action=AB:create("collection", nil, { "OPieBundleTrinket0", "OPieBundleTrinket1",
			OPieBundleTrinket0 = AB:get("item", (GetInventorySlotInfo("Trinket0Slot")), false, true),
			OPieBundleTrinket1 = AB:get("item", (GetInventorySlotInfo("Trinket1Slot")), false, true),
		}), name="Trinkets"
	});
end
do -- OPieTracker
	local collectionData, map = {}, {}
	local function setTracking(id)
		SetTracking(id, not select(3, GetTrackingInfo(id)));
	end
	local function hint(aid)
		local name, tex, on, typ = GetTrackingInfo(map[aid]);
		return not not name, on and 1 or 0, tex, name, 0,0,0
	end
	local trackerActions = setmetatable({}, {__index=function(t, k)
		t[k] = AB:create("func", hint, setTracking, k)
		map[t[k]] = k
		return t[k]
	end})
	local function preClick(selfId, _, updatedId)
		if selfId ~= updatedId then return end
		local n = GetNumTrackingTypes()
		if n ~= #collectionData then
			for i=1,n do
				local token = "OPieBundleTracker" .. i
				collectionData[i], collectionData[token] = token, trackerActions[i]
				ORI:SetDisplayOptions(token, nil, nil, generateColor(i,n))
			end
			for i=n+1,#collectionData do
				collectionData[i] = nil
			end
			AB:update(selfId, collectionData)
		end
	end
	local col = AB:create("collection", nil, collectionData)
	OneRingLib:SetRing("OPieTracking", {name="Minimap Tracking", hotkey="ALT-F", action=col})
	AB:observe("internal.collection.preopen", preClick, col)
	EC_Register("PLAYER_ENTERING_WORLD", "OPie.AutoTrackerInit", function() return "remove", preClick(col, nil, col) end)
end
do -- OPieAutoQuest
	local whitelist, questItems, collection, inring, colId, ctok, current, changed = {[33634]=true, [35797]=true, [37888]=true, [37860]=true, [37859]=true, [37815]=true, [46847]=true, [47030]=true, [39213]=true, [42986]=true, [49278]=true, [86425]={31332, 31333, 31334, 31335, 31336, 31337}, [87214]={31752}, [90006]=true, [86536]=true, [86534]=true, [97268]=true}, {[30148]="72986 72985"}, {}, {}
	local function scanQuests(i)
		for i=i or 1,GetNumQuestLogEntries() do
			local _, _, _, _, isHeader, isCollapsed, isComplete, _, qid = GetQuestLogTitle(i)
			if isHeader and isCollapsed then
				ExpandQuestHeader(i)
				return scanQuests(i+1), CollapseQuestHeader(i)
			elseif questItems[qid] and not isComplete then
				for id in questItems[qid]:gmatch("%d+") do
					local act = AB:get("item", tonumber(id))
					if act then
						local tok = "OpieBundleQuest" .. id
						if not inring[tok] then
							collection[#collection+1], collection[tok], changed = tok, act, true
						end
						inring[tok] = current
						break
					end
				end
			end
		end
	end
	local function syncRing(_, _, upId)
		if upId ~= colId then return end
		changed, current = false, ((ctok or 0) + 1) % 2;

		-- Search quest log
		for i=1,GetNumQuestLogEntries() do
			local link, icon, charges, showWhenComplete = GetQuestLogSpecialItemInfo(i);
			if link and (showWhenComplete or not select(7, GetQuestLogTitle(i))) then
				local iid = tonumber(link:match("item:(%d+)"))
				local tok = "OPieBundleQuest" .. iid
				if not inring[tok] then
					collection[#collection+1], collection[tok], changed = tok, AB:get("item", iid), true
				end
				inring[tok] = current
			end
		end

		-- Search bags
		for bag=0,4 do
			for slot=1,GetContainerNumSlots(bag) do
				local iid = GetContainerItemID(bag, slot);
				local isQuest, startQuestId, isQuestActive = GetContainerItemQuestInfo(bag, slot);
				isQuest = iid and ((isQuest and GetItemSpell(iid)) or (whitelist[iid] == true) or (startQuestId and not isQuestActive and not IsQuestFlaggedCompleted(startQuestId)));
				if not isQuest and type(whitelist[iid]) == "table" then
					isQuest = true
					for _, qid in pairs(whitelist[iid]) do
						if IsQuestFlaggedCompleted(qid) then
							isQuest = false
						end
					end
				end
				if isQuest then
					local tok = "OPieBundleQuest" .. iid
					if not inring[tok] then
						collection[#collection+1], collection[tok], changed = tok, AB:get("item", iid), true
					end
					ORI:SetQuestHint(tok, startQuestId and not isQuestActive)
					inring[tok] = current
				end
			end
		end

		-- Check whether any of our quest items are equipped... Hi, Egan's Blaster.
		for i=0,19 do
			local tok = "OPieBundleQuest" .. (GetInventoryItemID("player", i) or 0)
			if inring[tok] then inring[tok] = current end
		end
		
		-- Additional quest-based whitelist
		scanQuests()

		-- Drop any items in the ring we haven't found.
		local freePos, oldCount = 1, #collection
		for i=1, oldCount do
			local v = collection[i]
			collection[freePos], freePos, collection[v], inring[v] = collection[i], freePos + (inring[v] == current and 1 or 0), (inring[v] == current and collection[v] or nil), inring[v] == current and current or nil
		end
		for i=oldCount,freePos,-1 do collection[i] = nil end
		ctok = current
		
		if changed or freePos <= oldCount then
			AB:update(colId, collection)
		end
	end
	colId = AB:create("collection", nil, collection)
	OneRingLib:SetRing("OPieAutoQuest", {name="Quest Items", hotkey="ALT-Q", action=colId})
	AB:observe("internal.collection.preopen", syncRing)
	EC_Register("PLAYER_REGEN_DISABLED", "OPie.AutoQuest", function() syncRing(nil, nil, colId) end);
end