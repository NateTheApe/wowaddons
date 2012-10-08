local RingKeeper, assert, copy = {}, OneRingLib.xlu.assert, OneRingLib.xlu.copy
local RK_RingDesc, RK_CollectionIDs, RK_Version, RK_Rev, SV = {}, {}, 2, 33
local unlocked, queue, RK_DeletedRings, RK_SharedCollection = false, {}, {}, {}

local AB = assert(OneRingLib.ext.ActionBook:compatible(1,5), "A compatible version of ActionBook is required")
local ORI = OneRingLib.ext.OPieUI

local RK_ParseMacro do -- Macro parser
	local castAlias = {[SLASH_CAST1]=true,[SLASH_CAST2]=true,[SLASH_CAST3]=true,[SLASH_CAST4]=true,[SLASH_USE1]=true,[SLASH_USE2]=true,[SLASH_CASTSEQUENCE1]=true,[SLASH_CASTSEQUENCE2]=true,[SLASH_CASTRANDOM1]=true,[SLASH_CASTRANDOM2]=true}
	local gmSid, gmId = nil
	local function RK_MacroSpellIDReplace(sidlist)
		for id in sidlist:gmatch("%d+") do
			local sname, srank = GetSpellInfo(tonumber(id))
			local sname2, srank2 = GetSpellInfo(sname or -1)
			if sname and sname2 then
				return sname
			end
		end
		return ""
	end
	local function RK_RemoveEmptyClauses(clause)
		return clause:gsub("%b[]", ""):match("^%s*;?$") and "" or nil;
	end
	local function RK_MacroLineParse(prefix, command, args)
		if command == "#show" or command == "#showtooltip" or castAlias[command:lower()] then
			args = args:gsub("[^;]+;?", RK_RemoveEmptyClauses);
			return args:match("%S") and prefix .. args or "";
		end
	end
	local function mountReplace()
		if gmId == nil or select(3, GetCompanionInfo("MOUNT", gmId)) ~= gmSid then
			for i=1,GetNumCompanions("MOUNT") do
				local cid, cn, sid, ico, iss, mtype = GetCompanionInfo("MOUNT", i)
				if mtype % 16 > 7 and mtype % 2 == 1 then
					gmSid, gmId = sid, i
					break
				end
			end
		end
		return RK_MacroSpellIDReplace(tostring(gmSid))
	end
	function RK_ParseMacro(mtext)
		local text = "\n" .. mtext:gsub("{{spell:([%d/]+)}}", RK_MacroSpellIDReplace):gsub("{{mount:ground}}", mountReplace);
		text = text:gsub("(\n([#/]%S+) ?)([^\n]*)", RK_MacroLineParse):gsub("[%s;]*\n", "\n"):gsub("[%s;]*$", "");
		if text:match("[\n\r]#rkrequire%s*[\n\r]") then return ""; end
		local req = (text:match("[\n\r]#rkrequire %s*([^\n\r]+)") or ""):match("^(%S.-)%s*$");
		if req and not (GetSpellInfo(req) or OneRingLib.xlu.companionSpellCache(req)) then return ""; end
		return (text:gsub("\n#rkrequire[^\n]*", ""):gsub("^\n+", ""));
	end
end
local RK_IsRelevantRingDescription, CLASS do
	local name, _ = UnitName("player")
	_, CLASS = UnitClass("player")
	function RK_IsRelevantRingDescription(desc)
		return desc and (desc.limit == nil or desc.limit == name or desc.limit == CLASS)
	end
end

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
		e.action, e.fastClick, changed = action, fc, changed or (action ~= e.action) or (e.fastClick ~= fc)
	end
	
	if cid and not changed then return end
	local collection, cn = RK_SharedCollection, 1
	wipe(collection)
	for i, e in ipairs(desc) do
		if e.action then
			collection[e.sliceToken], collection[cn], cn = e.action, e.sliceToken, cn + 1
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
	props.limit, props.limitToChar, props.class = props.limit or props.limitToChar or props.class
	local uprefix = props.ux
	for i, v in ipairs(props) do
		if v.c and not (v.r and v.g and v.b) then
			local r,g,b = v.c:match("^(%x%x)(%x%x)(%x%x)$");
			if r then
				v.r, v.g, v.b = tonumber(r, 16)/255, tonumber(g, 16)/255, tonumber(b, 16)/255;
			end
		end
		local rt, id = v.rtype, v.id
		if (rt == nil or rt == "companion") and type(id) == "number" then
			v[1], v[2] = "spell", id
		elseif rt == nil and type(id) == "string" then
			v[1], v[2] = "macrotext", id
		elseif rt and id then
			v[1], v[2] = rt, id
		end
		v.sliceToken, v.action, v.onlyWhilePresent, v.rtype, v.id = v.sliceToken or (uprefix and v.ux and (uprefix .. v.ux)) or AB:uniq()
	end
	return props;
end
local function combatSoftSyncAll()
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
		for k in pairs(sv) do sv[k] = nil; end

		for k, v in pairs(RK_RingDesc) do
			if type(v) == "table" and not RK_DeletedRings[k] and v.save then
				for i, v2 in ipairs(v) do
					v2.c = ("%02x%02x%02x"):format((v2.r or 0) * 255, (v2.g or 0) * 255, (v2.b or 0) * 255);
					v2.action, v2.b, v2.g, v2.r, v2.ux, v2.fastClick = nil
					if v2[1] == "spell" or v2[1] == "macrotext" then
						v2.id, v2[1], v2[2] = v2[2]
					end
				end
				sv[k], v.lastUpdateToken, v.ux, v.action = v;
			end
		end
		sv.OPieDeletedRings = next(RK_DeletedRings) and RK_DeletedRings
	elseif event == "LOGIN" then
		unlocked = true;
		local deleted, mousemap = SV.OPieDeletedRings or RK_DeletedRings, {PRIMARY=OneRingLib:GetOption("PrimaryButton"), SECONDARY=OneRingLib:GetOption("SecondaryButton")};
		SV.OPieDeletedRings = nil

		for k, v in pairs(queue) do
			if v.hotkey then v.hotkey = v.hotkey:gsub("[^-; ]+", mousemap); end
			if deleted[k] == nil and SV[k] == nil then
				EC_pcall("RingKeeper", k .. ".SetRingQ", RingKeeper.SetRing, RingKeeper, k, v);
				SV[k] = nil;
			elseif deleted[k] then
				RK_DeletedRings[k] = true;
			end
		end
		for k, v in pairs(SV) do
			EC_pcall("RingKeeper", k .. ".SetRingSV", RingKeeper.SetRing, RingKeeper, k, v);
		end
		collectgarbage("collect");
	end
end
local function ringIterator(_, k)
	local nk, v = next(RK_RingDesc, k)
	if not nk then return nil end
	return nk, v.name or nk, RK_CollectionIDs[nk] ~= nil, #v, v.internal, v.limit
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
function RingKeeper:GetRingDescription(name)
	assert(type(name) == "string", "Syntax: descTable = RingKeeper:GetRingDescription(name)", 2);
	local ring = assert(RK_RingDesc[name], "Ring %q is not described.", 2, name);
	return copy(ring);
end
function RingKeeper:GetRingInfo(name)
	assert(type(name) == "string", 'Syntax: title, numSlices, isDefault, isOverriden = RingKeeper:GetRingInfo("name")', 2)
	local ring = RK_RingDesc[name]
	return ring and (ring.name or name), ring and #ring, not not queue[name], ring and ring.save
end
function RingKeeper:RestoreDefaults(limitName)
	for k, v in pairs(queue) do
		if (limitName == nil and RK_IsRelevantRingDescription(v)) or limitName == k then
			-- Do not reset rings that cannot be "seen".
			self:SetRing(k, queue[k]);
		end
	end
end
function RingKeeper:GenFreeRingName(base, t)
	assert(type(base) == "string" and (t == nil or type(t) == "table"), 'Syntax: name = RingKeeper:GenFreeRingName("base"[, reservedNamesTable])', 2);
	base = base:gsub("[^%a%d]", "");
	if base:match("^OPie") or base:match("^%A") then base = "x" .. base; end
	local ap, c = "", 1;
	while RK_RingDesc[base .. ap] or SV[base .. ap] or (t and t[base .. ap] ~= nil) do ap, c = math.random(2^c), c+1; end
	return base .. ap;
end
function RingKeeper:UnpackABAction(slice)
	if type(slice) == "table" and slice[1] == "macrotext" and type(slice[2]) == "string" then
		local pmt = RK_ParseMacro(slice[2])
		return "macrotext", pmt == "" and slice[2] ~= "" and "#empty" or pmt, unpackABAction(slice, 3)
	else
		return unpackABAction(slice, 1)
	end
end

OneRingLib.ext.RingKeeper = RingKeeper
SV = OneRingLib:RegisterPVar("RingKeeper", SV, svInitializer)
EC_Register("PLAYER_REGEN_DISABLED", "RingKeeper.CombatSync", combatSoftSyncAll)
AB:observe("internal.collection.preopen", abPreOpen)