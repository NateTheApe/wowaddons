local api, MAJ, REV = {}, 1, 6

local function assert(condition, err, ...)
	return (not condition) and error(tostring(err):format(...), 3) or condition
end

local ab, abCallFuncs = CreateFrame("BUTTON", "ActionBookTrigger", nil, "SecureActionButtonTemplate"), {}
ab:RegisterForClicks("AnyUp")
function ab:callCustom(unit, button)
	local t = abCallFuncs[button]
	local ttype = type(t)
	if ttype == "table" then
		t[1](unpack(t,3,t[2]))
	elseif ttype == "function" then
		t()
	end
end

local abSec = CreateFrame("FRAME", "ActionBookSecLib", nil, "SecureHandlerBaseTemplate")
abSec:Execute([[collections, colmetadata, tokens, stackCol, stackIdx, outCount = newtable(), newtable(), newtable(), newtable(), newtable(), newtable()]])
local abSecEnv = GetManagedEnvironment(abSec)
abSec:SetAttribute("collection", [=[-- AB.collection
	local i, ret, root, col, idx, aid = 1, "", tonumber((...)) or 0
	wipe(outCount)
	stackCol[i], stackIdx[i] = root, 1
	while i > 0 do
		col, idx = stackCol[i], stackIdx[i]
		if outCount[col] == nil then outCount[col] = 0 self:CallMethod("notifyCollectionOpen", col) end
		aid, stackIdx[i] = collections[col][idx], idx + 1
		if not aid then
			i = i - 1
		elseif collections[aid] and not outCount[aid] then
			i, stackIdx[i], stackCol[i+1], stackIdx[i+1] = i + 1, idx, aid, 1
		elseif aid and (outCount[aid] or 1) > 0 then
			ret = ret .. "\n" .. col .. " " .. (outCount[col] + 1) .. " " .. aid .. " " .. tokens[col][idx]
			outCount[col] = outCount[col] + 1
		end
	end
	return ret, colmetadata["openAction-" .. root]
]=])
function abSec:notifyCollectionOpen(id)
	api:notify("internal.collection.preopen", id)
end

local DeferAttribute, DeferExecute do -- Combat Lockdown; deferred calls
	local aQueue, eQueue, eqn = {}, {}, 1
	function DeferAttribute(attr, value)
		if not InCombatLockdown() then return ab:SetAttribute(attr, value) end
		aQueue[attr] = value
	end
	function DeferExecute(block)
		if not InCombatLockdown() then return abSec:Execute(block) end
		eQueue[eqn], eqn = block, eqn + 1
	end
	ab:SetScript("OnEvent", function(self, event)
		for k,v in pairs(aQueue) do self:SetAttribute(k, v) aQueue[k] = nil end
		for i=1,eqn-1 do abSec:Execute(eQueue[i]) end eqn = 1
	end)
	ab:RegisterEvent("PLAYER_REGEN_ENABLED")
end
do -- api:uniq()
	local seq, dict, dictLength, prefix = 262143, "qwer1tyui2opas3dfgh4jklz5xcvb6nmQWE7RTYU8IOPA9SDFG0HJKL=ZXCV/BNM", 64
	local function encode(n)
		local ret, d = ""
		repeat
			d = n % dictLength
			ret, n = dict:sub(d+1, d+1) .. ret, (n - d) / dictLength
		until n == 0
		return ret
	end
	function api:uniq()
		if seq > 262142 then
			prefix, seq = "ABu" .. encode(time()*100+(math.floor(GetTime()%1*1000)%100)), 0
		end
		seq = seq + 1
		return prefix .. encode(seq)
	end
end

local handlers, describers, allocatedActions, nextActionId = {}, {}, {}, 42
local allocatedActionType, optData, optStart, optEnd = {}, {}, {}, {}

local createHandlers, updateHandlers = {}, {}
function createHandlers.attribute(id, cnt, name, value, ...)
	if not (type(name) == "string" and value ~= nil) then
		return false, "Invalid attribute name/value pair (%q,%q)", tostring(name), tostring(value)
	end
	DeferAttribute("*" .. name .. "-" .. id, value)
	if cnt == 2 then return true end
	return createHandlers.attribute(id, cnt-2, ...)
end
function createHandlers.func(id, cnt, func, ...)
	if type(func) ~= "function" then
		return false, "Callback expected, got %s", type(func)
	end
	DeferAttribute("*type-" .. id, "callCustom")
	abCallFuncs[tostring(id)] = cnt > 1 and {func, cnt+1, ...} or func
	return true
end
function updateHandlers.collection(id, cnt, idList)
	if not (type(idList) == "table") then
		return false, "Expected table specifying collection actions, got %q", type(idList)
	elseif idList.__openAction and not allocatedActions[idList.__openAction] then
		return false, "Collection __openAction key does not specify a valid action"
	end
	local spec, tokens = "", ""
	for i=1,#idList do
		if allocatedActions[idList[idList[i]]] == nil then
			return false, "Collection entry #%d is not an allocated action id", i, tostring(idList[i])
		end
		spec, tokens = spec .. idList[idList[i]] .. ", ", tokens .. ("%q, "):format(idList[i])
	end
	DeferExecute(("local id = %d; collections[id], tokens[id], colmetadata['openAction-' .. id] = newtable(%s nil), newtable(%s nil), %s"):format(id, spec, tokens, type(idList.__openAction) == "number" and idList.__openAction or "nil"))
	return true
end
createHandlers.collection = updateHandlers.collection
local function collectionInfoFunc() end

function api:get(ident, ...)
	assert(type(ident) == "string", "Syntax: actionId = AB:get(identifier, ...)")
	local id = handlers[ident] and handlers[ident](...)
	if allocatedActions[id] then
		return id
	end
end
function api:info(id, ...)
	assert(type(id) == "number", "Syntax: usable, state, icon, caption, count, cdLeft, cdLength, tipFunc, tipArg = AB:info(actionId[, altState, shiftState, ctrlState])")
	if allocatedActions[id] then
		return allocatedActions[id](id, ...)
	end
end
function api:describe(ident, ...)
	assert(type(ident) == "string", "Syntax: typeName, actionName, icon, extico, tipFunc, tipArg = AB:describe(identifier, ...)")
	if describers[ident] then
		return describers[ident](...)
	end
end
function api:button(id)
	assert(type(id) == "number", "Syntax: buttonName, clickButton = AB:button(actionId)")
	return ab:GetName(), id
end
function api:options(ident)
	assert(type(ident) == "string", "Syntax: ... = AB:options(identifier)")
	return unpack(optData, optStart[ident] or 0, optEnd[ident] or -1)
end
function api:actionType(id)
	assert(type(id) == "number", "Syntax: actionType = AB:actionType(actionId)")
	return allocatedActionType[id], abSecEnv.collections[id] and #abSecEnv.collections[id] or nil
end

function api:register(ident, create, describe, opt)
	assert(type(ident) == "string" and type(create) == "function" and type(describe) == "function" and (opt == nil or type(opt) == "table"), "Syntax: AB:register(identifier, createFunc, describeFunc[, {options}])")
	assert(not handlers[ident], "Identifier %q is already registered", atype)
	handlers[ident], describers[ident] = create, describe
	if opt and #opt > 0 then
		local ok
		for i=0,#optData-1 do ok = i for j=1,#opt do if opt[j] ~= optData[i+j] then ok = nil break end end if ok then break end end
		if not ok then ok = #optData for i=1,#opt do optData[ok+i] = opt[i] end end
		optStart[ident], optEnd[ident] = ok+1, ok + #opt
	end
end
function api:create(atype, infoFunc, ...)
	assert(type(atype) == "string" and (type(infoFunc) == "function" or (atype == "collection" and infoFunc == nil)), "Syntax: actionId = AB:create(actionType, infoFunc, ...)")
	assert(createHandlers[atype], "Action type %q is not creatable", atype)
	local id = nextActionId
	nextActionId = nextActionId + 1
	assert(createHandlers[atype](id, select("#", ...), ...))
	allocatedActions[id], allocatedActionType[id] = infoFunc or collectionInfoFunc, atype
	return id
end
function api:update(id, ...)
	assert(type(id) == "number", "Syntax: AB:update(actionId, ...)")
	assert(allocatedActionType[id], "Action %d does not exist", id)
	assert(updateHandlers[allocatedActionType[id]], "Action type %q is not updatable", allocatedActionType[id])
	assert(updateHandlers[allocatedActionType[id]](id, select("#", ...), ...))
end

local categories, categoryProps, catBase = {}, {name={},entries={},entry={}}, newproxy(true)
do -- catBase
	local mt = getmetatable(catBase)
	function mt:__index(k)
		if categoryProps[k] then return categoryProps[k][self] end
	end
	function mt:__len()
		return categoryProps.entries[self]()
	end
	function mt:__call(v)
		return categoryProps.entry[self](v)
	end
end
do -- api:miscaction(...)
	local data, last, cat = {}, {[0]=0}, newproxy(catBase)
	categories[0], categoryProps.name[cat], categoryProps.entries[cat], categoryProps.entry[cat] = cat, "Miscellaneous",
		function() return #last end, function(id) return unpack(data, (last[id-1] or 0)+1, last[id] or -1) end
	local function set(n, i, v, ...)
		return n > 0 and rawset(data, i, v) and set(n-1, i+1, ...) or (i-1)
	end
	function api:miscaction(ident, ...)
		assert(type(ident) == "string", "Syntax: AB:miscaction(ident, ...)")
		last[#last+1] = set(1 + select("#", ...), last[#last]+1, ident, ...)
	end
end
api.categories = newproxy(true) do
	local mt = getmetatable(api.categories)
	function mt:__len()
		return #categories + (#categories[0] == 0 and 0 or 1)
	end
	function mt:__index(k)
		return categories[k] or (k == #categories+1 and #categories[0] > 0 and categories[0]) or nil
	end
	function mt:__call(_, i)
		i = (i or 0) + 1
		local v = self[i]
		return v and i, v
	end
end
function api:category(name, numFunc, getFunc)
	assert(type(name) == "string" and type(numFunc) == "function" and type(getFunc) == "function", "Syntax: id = AB:category(name, countFunc, entryFunc)")
	local count = numFunc()
	assert(type(count) == "number" and count >= 0, "countFunc must return a non-negative number")
	local obj, p = newproxy(catBase), categoryProps
	p.name[obj], p.entries[obj], p.entry[obj], categories[#categories+1] = name, numFunc, getFunc, obj
	return #categories
end

local notifyCount, observers, notifyFunc, notifySelf, notifyIdent, notifyArg = 1, {["*"]={}, ["internal.collection.preopen"] = {}}
local function invokenotify()
	notifyFunc(notifySelf, notifyIdent, notifyArg)
end
function api:notify(ident, data)
	assert(type(ident) == "string", "Syntax: AB:notify(identifier[, data])")
	assert(handlers[ident] or observers[ident] ~= nil, "Identifier %q is not registered", ident)
	notifyCount = (notifyCount + 1) % 4503599627370495
	local erf = geterrorhandler()
	for i=1,ident == "*" or not observers[ident] and 1 or 2 do
		for k,v in pairs(observers[i == 1 and "*" or ident]) do
			notifyFunc, notifySelf, notifyIdent, notifyArg = k, v, ident, data
			xpcall(invokenotify, erf)
		end
	end
end
function api:observe(ident, callback, selfarg)
	assert(type(ident) == "string" and type(callback) == "function", "Syntax: AB:observe(identifier, callbackFunc, callbackSelfArg)")
	assert(ident == "*" or handlers[ident] or observers[ident], "Identifier %q is not registered", ident)
	if observers[ident] == nil then observers[ident] = {} end
	observers[ident][callback] = selfarg == nil and true or selfarg
end
function api:lastupdate(ident)
	assert(type(ident) == "string", "Syntax: token = AB:lastupdate(identifier)")
	assert(ident == "*" or handlers[ident], "Identifier %q is not registered", ident)
	return notifyCount
end

function api:seclib()
	return abSec
end

function api:compatible(maj, rev)
	return maj == MAJ and rev <= REV and self, MAJ, REV
end

OneRingLib.ext.ActionBook = api