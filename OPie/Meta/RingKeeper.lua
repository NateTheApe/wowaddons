local RingKeeper, assert, copy = {}, OneRingLib.xlu.assert, OneRingLib.xlu.copy
local RK_RingDesc, RK_CollectionIDs, RK_Version, RK_Rev, SV = {}, {}, 2, 36
local unlocked, queue, RK_DeletedRings, RK_FlagStore, sharedCollection = false, {}, {}, {}, {}

local AB = assert(OneRingLib.ext.ActionBook:compatible(1,7), "A compatible version of ActionBook is required")
local ORI = OneRingLib.ext.OPieUI

local RK_ParseMacro, RK_QuantizeMacro, RK_SetMountPreference do
	local castAlias = {[SLASH_CAST1]=1,[SLASH_CAST2]=1,[SLASH_CAST3]=1,[SLASH_CAST4]=1,[SLASH_USE1]=1,[SLASH_USE2]=1,["#show"]=1,["#showtooltip"]=1,["#rkrequire"]=0,[SLASH_CASTSEQUENCE1]=2,[SLASH_CASTSEQUENCE2]=2,[SLASH_CASTRANDOM1]=3,[SLASH_CASTRANDOM2]=3}
	local function replaceSpellID(sidlist, prefix)
		for id in sidlist:gmatch("%d+") do
			local sname, srank = GetSpellInfo(tonumber(id))
			if sname and GetSpellInfo(sname) then
				return prefix .. sname
			end
		end
	end
	local replaceMountTag do
		local gmSid, gmId, gmPref, fmSid, fmId, fmPref
		local req = {127170,123992,127156,123993,127169,127161,127164,127165,127158,113199,127154,129918,139442,124408,132036,25953,26056,26054,26055}
		for i=#req,1,-1 do req[req[i]], req[i] = i <= 15 and 130487 or 1 end
		local function searchList(p, m, t)
			local cv, cs, ci = 0
			for i=1, GetNumCompanions("MOUNT") do
				local _, _, sid, _, _, mtype = GetCompanionInfo("MOUNT", i)
				if mtype % m >= t then
					if req[sid] == nil or IsSpellKnown(req[sid]) then
						if sid == p or not p then
							return sid, i
						elseif mtype % 16 > 7 and cv < 1 then
							cv, cs, ci = 1, sid, i
						else
							cs, ci = sid, i
						end
					end
				end
			end
			return cs, ci
		end
		function replaceMountTag(tag, prefix)
			if tag == "ground" then
				if (gmId == nil or GetCompanionInfo("MOUNT", gmId) ~= gmSid) then
					gmSid, gmId = searchList(gmPref, 32, 16)
				end
				return replaceSpellID(tostring(gmSid), prefix)
			elseif tag == "air" then
				if (fmId == nil or GetCompanionInfo("MOUNT", fmId) ~= fmSid) then
					fmSid, fmId = searchList(fmPref, 4, 2)
				end
				return replaceSpellID(tostring(fmSid), prefix)
			end
			return ""
		end
		function RK_SetMountPreference(groundSpellID, airSpellID)
			if groundSpellID ~= nil then
				gmPref, gmSid, gmId = groundSpellID
			end
			if airSpellID ~= nil then
				fmPref, fmSid, fmId = airSpellID
			end
		end
	end
	local function replaceAlternatives(replaceFunc, args)
		local ret
		for alt in (args .. ","):gmatch("(.-),") do
			local alt2 = replaceFunc(alt)
			if alt == alt2 or (alt2 and alt2:match("%S")) then
				ret = (ret and (ret .. ", ") or "") .. alt2:match("^%s*(.-)%s*$")
			end
		end
		return ret
	end
	local function genLineParser(replaceFunc)
		return function(commandPrefix, command, args)
			local ctype = castAlias[command:lower()]
			if not ctype then return end
			local pos, len, ret = 1, #args
			repeat
				local cstart, cend, vend = pos
				repeat
					local ce, cs = args:match("();", pos) or (len+1), args:match("()%[", pos)
					if cs and cs < ce then
						pos = args:match("%]()", cs)
					else
						cend, vend, pos = pos, ce-1, ce + 1
					end
				until cend or not pos
				if not pos then return end
				local cval = args:sub(cend, vend)
				if ctype < 2 then
					cval = replaceFunc(args:sub(cend, vend))
				else
					local val, reset = args:sub(cend, vend)
					if ctype == 2 then reset, val = val:match("^(%s*reset=%S+%s*)"), val:gsub("^%s*reset=%S+%s*", "") end
					val = replaceAlternatives(replaceFunc, val)
					cval = val and ((reset or "") .. val) or nil
				end
				if cval or ctype == 0 then
					local clause = (cstart < cend and (args:sub(cstart, cend-1):match("^%s*(.-)%s*$") .. " ") or "") .. (cval and cval:match("^%s*(.-)%s*$") or "")
					ret = (ret and (ret .. "; ") or commandPrefix) .. clause
				end
			until not pos or pos > #args
			return ret or ""
		end
	end
	local parseLine, quantizeLine, prepareQuantizer do
		parseLine = genLineParser(function(value)
			local prefix, tkey, tval = value:match("^%s*(!?)%s*{{(%a+):([%a%d/]+)}}%s*$")
			if tkey == "spell" then
				return replaceSpellID(tval, prefix)
			elseif tkey == "mount" then
				return replaceMountTag(tval, prefix)
			end
			return value
		end)
		local spells, scantip = {}, CreateFrame("GameTooltip", "OPieCustomRingTT", nil, "GameTooltipTemplate")
		quantizeLine = genLineParser(function(value)
			local mark, name = value:match("^%s*(!?)(.-)%s*$")
			local sid = spells[name:lower()]
			if not sid and mark == "!" then mark, sid = "", spells[mark .. name:lower()] end
			return sid and (mark .. "{{spell:" .. sid .. "}}") or value
		end)
		function prepareQuantizer(reuse)
			if reuse and next(spells) then return end
			wipe(spells)
			scantip:SetOwner(UIParent, "ANCHOR_NONE")
			for i=1,GetNumCompanions("MOUNT") do
				local _, _, sid = GetCompanionInfo("MOUNT", i)
				local sname = sid and GetSpellInfo(sid)
				if sname then
					spells[sname:lower()] = sid
				end
			end
			for i=1,GetNumTalents() do
				scantip:SetTalent(i)
				local name, rank, id = scantip:GetSpell()
				if id and type(name) == "string" then
					spells[name:lower()] = id
				end
			end
			for i=GetNumSpellTabs()+12,1,-1 do
				local n, _, ofs, c, _, sid = GetSpellTabInfo(i)
				for j=ofs+1,sid == 0 and (ofs+c) or 0 do
					local n, st, id = GetSpellBookItemName(j, "spell"), GetSpellBookItemInfo(j, "spell")
					if type(n) ~= "string" or not id then
					elseif st == "SPELL" or st == "FUTURESPELL" then
						spells[n:lower()] = id
					elseif st == "FLYOUT" then
						for j=1,select(3,GetFlyoutInfo(id)) do
							local sid, _, _, sname = GetFlyoutSlotInfo(id, j)
							if sid and type(sname) == "string" then
								spells[sname:lower()] = sid
							end
						end
					end
				end
			end
		end
	end
	function RK_ParseMacro(macro)
		if type(macro) == "string" and (macro:match("{{spell:[%d/]+}}") or macro:match("{{mount:ground}}") or macro:match("#rkrequire")) then
			macro = ("\n" .. macro):gsub("(\n([#/]%S+) ?)([^\n]*)", parseLine)
			if macro:match("[\n\r]#rkrequire%s*[\n\r]") then return ""; end
		end
		return macro
	end
	function RK_QuantizeMacro(macro, useCache)
		return type(macro) == "string" and (prepareQuantizer(useCache) or true) and ("\n" .. macro):gsub("(\n([#/]%S+) ?)([^\n]*)", quantizeLine):sub(2) or macro
	end
end
local RK_IsRelevantRingDescription, CLASS do
	local name, _ = UnitName("player")
	_, CLASS = UnitClass("player")
	function RK_IsRelevantRingDescription(desc)
		return desc and (desc.limit == nil or desc.limit == name or desc.limit == CLASS)
	end
end
local serialize, unserialize do
	local sigT, sigN = {}
	for i, c in ("01234qwertyuiopasdfghjklzxcvbnm5678QWERTYUIOPASDFGHJKLZXCVBNM9"):gmatch("()(.)") do sigT[i-1], sigT[c], sigN = c, i-1, i end
	local function checksum(s)
		local h = (134217689 * #s) % 17592186044399
		for i=1,#s,4 do
			local a, b, c, d = s:match("(.?)(.?)(.?)(.?)", i)
			a, b, c, d = sigT[a], (sigT[b] or 0) * sigN, (sigT[c] or 0) * sigN^2, (sigT[d] or 0) * sigN^3
			h = (h * 211 + a + b + c + d) % 17592186044399
		end
		return h % 3298534883309
	end
	local function nenc(v, b, rest)
		if b == 0 then return v == 0 and rest or error("numeric overflow") end
		local v1 = v % sigN
		local v2 = (v - v1) / sigN
		return nenc(v2, b - 1, sigT[v1] .. (rest or ""))
	end
	local function cenc(c)
		local b, m = c:byte(), sigN-1
		return sigT[(b - b % m) / m] .. sigT[b % m]
	end
	local function venc(v, t, reg)
		if reg[v] then
			table.insert(t, sigT[1] .. sigT[reg[v]])
		elseif type(v) == "table" then
			local n = math.min(sigN-1, #v)
			for i=n,1,-1 do venc(v[i], t, reg) end
			table.insert(t, sigT[3] .. sigT[n])
			for k,v2 in pairs(v) do
				if not (type(k) == "number" and k >= 1 and k <= n and k % 1 == 0) then
					venc(v2, t, reg)
					venc(k, t, reg)
					table.insert(t, sigT[4])
				end
			end
		elseif type(v) == "number" then
			if v % 1 ~= 0 then error("non-integer value") end
			if v < -1000000 then error("integer underflow") end
			table.insert(t, sigT[5] .. nenc(v + 1000000, 4))
		elseif type(v) == "string" then
			table.insert(t, sigT[6] .. v:gsub("[^a-zA-Z5-8]", cenc) .. "9")
		else
			table.insert(t, sigT[1] .. ((v == true and sigT[1]) or (v == nil and sigT[0]) or sigT[2]))
		end
		return t
	end

	local ops = {"local ops, sigT, sigN, s, r, pri = {}, ...\nlocal cdec, ndec = function(c, l) return string.char(sigT[c]*(sigN-1) + sigT[l]) end, function(s) local r = 0 for i=1,#s do r = r * sigN + sigT[s:sub(i,i)] end return r end",
		"s[d+1], d, pos = r[sigT[pri:sub(pos,pos)]], d + 1, pos + 1", "r[sigT[pri:sub(pos,pos)]], pos = s[d], pos + 1",
		"local t, n = {}, sigT[pri:sub(pos,pos)]\nfor i=1,n do t[i] = s[d-i+1] end\ns[d - n + 1], d, pos = t, d - n + 1, pos + 1", "s[d-2][s[d]], d = s[d-1], d - 2",
		"s[d+1], d, pos = ndec(pri:sub(pos, pos + 3)) - 1000000, d + 1, pos + 4", "d, s[d+1], pos = d + 1, pri:match('^(.-)9()', pos)\ns[d] = s[d]:gsub('([0-4])(.)', cdec)",
		"s[d-1], d = s[d-1]+s[d], d - 1", "s[d-1], d = s[d-1]*s[d], d - 1", "s[d-1], d = s[d-1]/s[d], d - 1", "function ops.bind(...) s, r, pri = ... end\nreturn ops"}
	for i=2,#ops-1 do ops[i] = ("ops[%q] = function(d, pos)\n %s\n return d, pos\nend"):format(sigT[i-1], ops[i]) end
	ops = loadstring(table.concat(ops, "\n"))(sigT, sigN)

	function serialize(t, sign, regGhost)
		local payload = table.concat(venc(t, {}, setmetatable({},regGhost)), "")
		return ((sign .. nenc(checksum(sign .. payload), 7) .. payload):gsub("(.......)", "%1 "):gsub(" ?$", ".", 1))
	end
	function unserialize(s, sign, regGhost)
		local h, pri = s:gsub("[^a-zA-Z0-9.]", ""):match("^" .. sign .. "(.......)([^.]+)")
		if nenc(checksum(sign .. pri), 7) ~= h then return end
	
		local stack, depth, pos, len = {}, 0, 1, #pri
		ops.bind(stack, setmetatable({true, false}, regGhost), pri)
		while pos <= len do
			depth, pos = ops[pri:sub(pos, pos)](depth, pos + 1)
		end
		return depth == 1 and stack[1]
	end
end
local encodeMacro, decodeMacro do
	local function slash_i18n(command, lead)
		if lead == "!" then return "\n!" .. command end
		local key = command:upper()
		if type(hash_ChatTypeInfoList[key]) == "string" and not hash_ChatTypeInfoList[key]:match("!") then
			return "\n!" .. hash_ChatTypeInfoList[key] .. "!" .. command
		elseif type(hash_EmoteTokenList[key]) == "string" and not hash_EmoteTokenList[key]:match("!") then
			return "\n!" .. hash_EmoteTokenList[key] .. "!" .. command
		end
	end
	local function slash_l10n(key, command)
		if key == "" then return "\n!" .. command end
		local k2 = command:upper()
		if hash_ChatTypeInfoList[k2] == key or hash_EmoteTokenList[k2] == key then
		elseif _G["SLASH_" .. key .. 1] then
			return "\n" .. _G["SLASH_" .. key .. 1]
		else
			local i, v = 2, EMOTE1_TOKEN
			while v do
				if v == key then
					return "\n" .. _G["EMOTE" .. (i-1) .. "_CMD1"]
				end
				i, v = i + 1, _G["EMOTE" .. i .. "_TOKEN"]
			end
		end
		return "\n" .. command
	end
	function encodeMacro(m)
		ChatFrame_ImportAllListsToHash()
		return ("\n" .. m):gsub("\n(([/!])%S*)", slash_i18n):sub(2)
	end
	function decodeMacro(m)
		ChatFrame_ImportAllListsToHash()
		return ("\n" .. m):gsub("\n!(.-)!(%S*)", slash_l10n):sub(2)
	end
end

local sReg = {__index={nil, nil, "name", "hotkey", "offset", "noOpportunisticCA", "noPersistentCA", "internal", "limit", "id", "skipSpecs", "caption", "icon", "show"}}
local sRegMap = {__index={}} for k,v in pairs(sReg.__index) do sRegMap.__index[v] = k end

local function pullOptions(e, a, ...)
	if a then return e[a], pullOptions(e, ...) end
end
local function unpackABAction(e, s)
	if e[s] then return e[s], unpackABAction(e, s+1) end
	return pullOptions(e, AB:options(e[1]))
end
local function RK_SyncRing(name, force, tok)
	local desc, changed, cid = RK_RingDesc[name], (force == true), RK_CollectionIDs[name];
	if not RK_IsRelevantRingDescription(desc) then return; end
	tok = tok or AB:lastupdate("*")
	if not force and tok == desc.lastUpdateToken then return end
	desc.lastUpdateToken = tok
	
	local curSpec = " " .. (GetSpecializationInfo(GetSpecialization() or 0) or CLASS) .. " "
	
	for i, e in ipairs(desc) do
		local ident, fc, action = e[1], e.fcSlice and true or nil
		if e.skipSpecs and e.skipSpecs:match(curSpec) then
		elseif ident == "macrotext" then
			local m = RK_ParseMacro(e[2])
			if m:match("%S") then action = AB:get("macrotext", m) end
		elseif type(ident) == "string" then
			action = AB:get(unpackABAction(e, 1))
		end
		e.action, e.fastClick, changed = action, fc, changed or (action ~= e.action) or (e.fastClick ~= fc) or (action and (e.show ~= e._show))
	end
	
	if cid and not changed then return end
	local collection, cn = sharedCollection, 1
	wipe(collection)
	for i, e in ipairs(desc) do
		if e.action then
			collection[e.sliceToken], collection[cn], cn = e.action, e.sliceToken, cn + 1
			collection['__visibility-' .. e.sliceToken], e._show = e.show or nil, e.show
			ORI:SetDisplayOptions(e.sliceToken, e.icon, e.caption, e.r, e.g, e.b)
		end
	end
	if cid then
		AB:update(cid, collection)
	else
		cid = AB:create("collection", nil, collection)
		RK_CollectionIDs[name], RK_CollectionIDs[cid] = cid, name
	end
	desc.action = cid
	OneRingLib:SetRing(name, desc)
end
local function RK_SanitizeDescription(props)
	local uprefix = type(props.ux) == "string" and props.ux
	for i, v in ipairs(props) do
		if v.c and not (v.r and v.g and v.b) then
			local r,g,b = v.c:match("^(%x%x)(%x%x)(%x%x)$");
			if r then
				v.r, v.g, v.b = tonumber(r, 16)/255, tonumber(g, 16)/255, tonumber(b, 16)/255;
			end
			v.c = nil
		end
		local rt, id = v.rtype, v.id
		if (rt == nil or rt == "companion") and type(id) == "number" then
			v[1], v[2] = "spell", id
		elseif rt == nil and type(id) == "string" then
			v[1], v[2] = "macrotext", id
		elseif rt and id then
			v[1], v[2] = rt, id
		end
		v.sliceToken, v.action, v.onlyWhilePresent, v.rtype, v.id = v.sliceToken or (uprefix and type(v.ux) == "string" and (uprefix .. v.ux)) or AB:uniq()
	end
	return props;
end
local function RK_SerializeDescription(props)
	for i, slice in ipairs(props) do
		slice.c = slice.r and slice.g and slice.b and ("%02x%02x%02x"):format(slice.r * 255, slice.g * 255, slice.b * 255) or slice.c or nil
		slice.action, slice.b, slice.g, slice.r, slice.ux, slice.fastClick, slice._show = nil
		if slice[1] == "spell" or slice[1] == "macrotext" then
			slice.id, slice[1], slice[2] = slice[2]
		end
	end
	props.lastUpdateToken, props.ux, props.action = nil
	return props
end
local function RK_SoftSyncAll()
	for k,v in pairs(RK_RingDesc) do
		EC_pcall("RK.Sync", "Ring " .. k, RK_SyncRing, k);
	end
end
local function abPreOpen(_, _, id)
	local k = RK_CollectionIDs[id]
	if k then
		RK_SyncRing(k)
	end
end
local function svInitializer(event, name, sv)
	if event == "LOGOUT" and unlocked then
		for k in pairs(sv) do sv[k] = nil end
		for k, v in pairs(RK_RingDesc) do
			if type(v) == "table" and not RK_DeletedRings[k] and v.save then
				sv[k] = RK_SerializeDescription(v)
			end
		end
		sv.OPieDeletedRings, sv.OPieFlagStore = next(RK_DeletedRings) and RK_DeletedRings, next(RK_FlagStore) and RK_FlagStore

	elseif event == "LOGIN" then
		unlocked = true
		local deleted, flags, mousemap = SV.OPieDeletedRings or RK_DeletedRings, SV.OPieFlagStore or RK_FlagStore
		mousemap, SV.OPieDeletedRings, SV.OPieFlagStore = {PRIMARY=OneRingLib:GetOption("PrimaryButton"), SECONDARY=OneRingLib:GetOption("SecondaryButton")}
		for k,v in pairs(flags) do RK_FlagStore[k] = v end

		for k, v in pairs(queue) do
			if v.hotkey then v.hotkey = v.hotkey:gsub("[^-; ]+", mousemap) end
			if deleted[k] == nil and SV[k] == nil then
				EC_pcall("RingKeeper", k .. ".SetRingQ", RingKeeper.SetRing, RingKeeper, k, v)
				SV[k] = nil
			elseif deleted[k] then
				RK_DeletedRings[k] = true
			end
		end
		local colorFlush = not RK_FlagStore.FlushedDefaultColors
		for k, v in pairs(SV) do
			if colorFlush and type(v) == "table" then
				for k,v in pairs(v) do
					if type(v) == "table" and v.c == "e5ff00" then
						v.c = nil
					end
				end
			end
			EC_pcall("RingKeeper", k .. ".SetRingSV", RingKeeper.SetRing, RingKeeper, k, v)
		end
		RK_FlagStore.FlushedDefaultColors = true
		collectgarbage("collect")
	end
end
local function ringIterator(_, k)
	local nk, v = next(RK_RingDesc, k)
	if not nk then return nil end
	return nk, v.name or nk, RK_CollectionIDs[nk] ~= nil, #v, v.internal, v.limit
end
local function deletedRingIterator(_, k)
	local nk, v = next(RK_DeletedRings, k)
	if not nk then return nil end
	if not queue[nk] or not RK_IsRelevantRingDescription(queue[nk]) then return deletedRingIterator(_, nk) end
	return nk
end

-- Public API
function RingKeeper:GetVersion()
	return RK_Version, RK_Rev
end
function RingKeeper:SetRing(name, desc)
	assert(type(name) == "string" and (type(desc) == "table" or desc == false), "Syntax: RingKeeper:SetRing(name, descTable or false)", 2);
	if not unlocked then
		queue[name] = desc
	elseif desc == false then
		if RK_RingDesc[name] then
			OneRingLib:SetRing(name, nil)
			if RK_CollectionIDs[name] then RK_CollectionIDs[RK_CollectionIDs[name]] = nil end
			RK_DeletedRings[name], RK_RingDesc[name], RK_CollectionIDs[name], SV[name] = queue[name] and true or nil
		end
	else
		RK_RingDesc[name], RK_DeletedRings[name] = RK_SanitizeDescription(copy(desc)), nil
		RK_SyncRing(name, true)
	end
end
function RingKeeper:GetManagedRings()
	return ringIterator, nil, nil
end
function RingKeeper:GetDeletedRings()
	return deletedRingIterator, nil, nil
end
function RingKeeper:GetRingDescription(name, serialize)
	assert(type(name) == "string", 'Syntax: desc = RingKeeper:GetRingDescription("name"[, serialize])', 2)
	local ring = RK_RingDesc[name] and copy(RK_RingDesc[name]) or false
	return serialize and ring and RK_SerializeDescription(ring) or ring
end
function RingKeeper:GetRingInfo(name)
	assert(type(name) == "string", 'Syntax: title, numSlices, isDefault, isOverriden = RingKeeper:GetRingInfo("name")', 2)
	local ring = RK_RingDesc[name]
	return ring and (ring.name or name), ring and #ring, not not queue[name], ring and ring.save
end
function RingKeeper:RestoreDefaults(name)
	if name == nil then
		for k, v in pairs(queue) do
			if RK_IsRelevantRingDescription(v) then
				self:SetRing(k, queue[k])
			end
		end
	elseif queue[name] then
		self:SetRing(name, queue[name])
	end
end
function RingKeeper:GetDefaultDescription(name)
	assert(type(name) == "string", 'Syntax: desc = RingKeeper:GetDefaultDescription("name")', 2)
	return queue[name] and copy(queue[name]) or false
end
function RingKeeper:GenFreeRingName(base, t)
	assert(type(base) == "string" and (t == nil or type(t) == "table"), 'Syntax: name = RingKeeper:GenFreeRingName("base"[, reservedNamesTable])', 2)
	base = base:gsub("[^%a%d]", ""):sub(-10)
	if base:match("^OPie") or not base:match("^%a") then base = "x" .. base end
	local suffix, c = "", 1
	while RK_RingDesc[base .. suffix] or SV[base .. suffix] or (t and t[base .. suffix] ~= nil) or OneRingLib:GetRingInfo(base .. suffix) do
		suffix, c = math.random(2^c), c < 30 and (c + 1) or c
	end
	return base .. suffix
end
function RingKeeper:UnpackABAction(slice)
	if type(slice) == "table" and slice[1] == "macrotext" and type(slice[2]) == "string" then
		local pmt = RK_ParseMacro(slice[2])
		return "macrotext", pmt == "" and slice[2] ~= "" and "#empty" or pmt, unpackABAction(slice, 3)
	else
		return unpackABAction(slice, 1)
	end
end
function RingKeeper:IsRingSliceActive(ring, slice)
	return RK_RingDesc[ring] and RK_RingDesc[ring][slice] and RK_RingDesc[ring][slice].action and true or false
end
function RingKeeper:SoftSync(name)
	assert(type(name) == "string", 'Syntax: RingKeeper:SoftSync("name")')
	EC_pcall("RK.Sync", "Ring " .. name, RK_SyncRing, name);
end
function RingKeeper:GetRingSnapshot(name)
	assert(type(name) == "string", 'Syntax: snapshot = RingKeeper:GetRingSnapshot("name")', 2)
	local ring, first = RK_RingDesc[name] and RK_SerializeDescription(copy(RK_RingDesc[name])) or false, true
	if ring then
		ring.limit, ring.ux, ring.save = type(ring.limit) == "string" and ring.limit:match("[^A-Z]") and "PLAYER" or ring.limit
		for i=1,#ring do
			local v = ring[i]
			if v[1] == nil and type(v.id) == "string" then
				v.id, first = encodeMacro(RK_QuantizeMacro(v.id, not first)), false
			end
			v.sliceToken, v.ux = nil
		end
	end
	return ring and serialize(ring, "oetohH7", sRegMap)
end
function RingKeeper:GetSnapshotRing(snap)
	assert(type(snap) == "string", 'Syntax: desc = RingKeeper:GetSnapshotRing("snapshot")', 2)
	local ok, ret, e2 = pcall(unserialize, snap, "oetohH7", sReg)
	if ok and type(ret) == "table" and type(ret.name) == "string" and #ret > 0 then
		for i=1,#ret do
			local v = ret[i]
			if not v then
				return
			else
				v.caption = type(v.caption) == "string" and caption:gsub("|?|", "||") or nil
				if v[1] == nil and type(v.id) == "string" then
					v.id = decodeMacro(v.id)
				end
			end
		end
		ret.name, ret.quarantineBind, ret.hotkey = ret.name:gsub("|?|", "||"), type(ret.hotkey) == "string" and ret.hotkey or nil
		return ret
	end
end
function RingKeeper:QuantizeMacro(macrotext)
	return RK_QuantizeMacro(macrotext)
end
function RingKeeper:SetMountPreference(groundSpellID, airSpellID)
	RK_SetMountPreference(groundSpellID, airSpellID)
end

OneRingLib.ext.RingKeeper = RingKeeper
SV = OneRingLib:RegisterPVar("RingKeeper", SV, svInitializer)
EC_Register("PLAYER_REGEN_DISABLED", "RingKeeper.CombatSync", RK_SoftSyncAll)
AB:observe("internal.collection.preopen", abPreOpen)