local Evie, next, _, T = {}, next, ...

local _xpcall do
	local args, unpack, xpcall, select, argc, pfunc = {}, unpack, xpcall, select
	local function call() return pfunc(unpack(args, 1, argc)) end
	local function throw(...) return geterrorhandler()(...) end
	function _xpcall(func, ...)
		pfunc, argc, args[1], args[2], args[3] = func, select("#", ...), ...
		for i=4, argc, 4 do
			args[i], args[i + 1], args[i + 2], args[i + 3] = select(i, ...)
		end
		return xpcall(call, throw)
	end
end

local frame, listeners, locked = CreateFrame("FRAME"), {}, {}

local function Register(event, func)
	if type(event) ~= "string" or type(func) ~= "function" then
		error('Syntax: RegisterEvent("event", handlerFunction)', 2)
	end
	local lock = locked[event]
	if lock == true then
		locked[event] = {[func] = 1}
	elseif lock then
		lock[func] = 1
	else
		frame:RegisterEvent(event)
		listeners[event] = listeners[event] or {}
		listeners[event][func] = 1
	end
end
local function Unregister(event, func)
	local list, lock = listeners[event], locked[event]
	if list and list[func] then
		list[func] = nil
		if not next(list) then
			listeners[event] = nil
			frame:UnregisterEvent(event)
		end
	end
	if lock and lock ~= true then
		lock[func] = nil
	end
end
local function RaiseEvent(_, event, ...)
	if listeners[event] then
		local lock = locked[event]
		locked[event] = lock or true
		for kf in next, listeners[event] do
			local ok, remove = _xpcall(kf, event, ...)
			if ok and remove == "remove" then
				Unregister(event, kf)
			end
		end
		if not lock then
			lock, locked[event] = locked[event]
			if lock ~= true then
				for kf in next, lock do
					Register(event, kf)
				end
			end
		end
	end
end
function Evie.RaiseEvent(event, ...)
	return RaiseEvent(nil, event, ...)
end
function Evie.CreateTimer(interval, func, start)
	local ag = WorldFrame:CreateAnimationGroup()
	ag:SetLooping("REPEAT")
	local ani = ag:CreateAnimation()
	ani:SetDuration(interval)
	ani:SetScript("OnFinished", func)
	if start ~= false then ag:Play() end
	return ag
end

frame:SetScript("OnEvent", RaiseEvent)
T.Evie, Evie.RegisterEvent, Evie.UnregisterEvent, Evie.ProtectedCall = Evie, Register, Unregister, _xpcall
