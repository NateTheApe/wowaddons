local max, min, abs, sin, cos = math.max, math.min, math.abs, sin, cos; -- Note: those trig functions want degrees
local ORI_ConfigCache, ORI_OptionDefaults = {}, {ShowCenterIcon=false, ShowCenterCaption=false, ShowCooldowns=false, MultiIndication=true, UseGameTooltip=true, ShowKeys=true,
	MIScale=true, MISpinOnHide=true, GhostMIRings=true, GhostOldDirection=false, XTPointerSpeed=0, XTScaleSpeed=0, XTZoomTime=0.3, XTRotationPeriod=4};

local ORI_cR, ORI_cG, ORI_cB, ORI_caption, ORI_icon, ORI_qHint = {}, {}, {}, {}, {}, {}
local ORI = {}

-- Create the indication UI
local OR_IndicationPos = CreateFrame("Frame", nil, UIParent);
OR_IndicationPos:SetSize(1, 1); OR_IndicationPos:Hide(); OR_IndicationPos:SetPoint("CENTER");
local OR_IndicationFrame, ORI_Circle, ORI_Pointer, ORI_Glow = CreateFrame("Frame", "OneRingIndicator", UIParent);
OR_IndicationFrame:SetSize(128, 128); OR_IndicationFrame:SetFrameStrata("FULLSCREEN"); OR_IndicationFrame:SetPoint("CENTER", OR_IndicationPos);
local makequadtex do -- Spawn indication textures
	local basepath = "Interface\\AddOns\\OPie";
	ORI_Pointer = OR_IndicationFrame:CreateTexture(nil, "ARTWORK");
	ORI_Pointer:SetSize(192, 192); ORI_Pointer:SetPoint("CENTER");
	ORI_Pointer:SetTexture(basepath .. "\\gfx\\pointer.tga");

	local quad, quadPoints, animations = {}, {"BOTTOMRIGHT", "BOTTOMLEFT", "TOPLEFT", "TOPRIGHT"}, {}
	for i=1,4 do
		local f = CreateFrame("Frame", nil, OR_IndicationFrame);
		f:SetSize(32, 32);	f:SetPoint(quadPoints[i], OR_IndicationFrame, "CENTER");
		local g = f:CreateAnimationGroup(); g:SetLooping("REPEAT"); g:SetIgnoreFramerateThrottle(1);
		local a = g:CreateAnimation("Rotation"); a:SetDuration(4); a:SetDegrees(-360);
		a:SetOrigin(quadPoints[i], 0, 0);
		g:Play();
		quad[i], animations[i] = f, a;
	end
	local function quadFunc(f)
		return function (self, ...)
			for i=1,4 do
				local v = self[i];
				v[f](v, ...);
			end
		end
	end
	local quadTemplate = {SetVertexColor=quadFunc("SetVertexColor"), Hide=quadFunc("Hide"), Show=quadFunc("Show"), SetAlpha=quadFunc("SetAlpha")};
	function makequadtex(layer, size, file, parent)
		local group, size = OneRingLib.xlu.copy(quadTemplate), size/2
		for i=1,4 do
			local tex, d, l = (parent or quad[i]):CreateTexture(nil, layer), i > 2, i == 1 or i == 4
			tex:SetTexture(file)
			tex:SetSize(size, size)
			tex:SetTexCoord(l and 0 or 1, l and 1 or 0, d and 1 or 0, d and 0 or 1)
			if parent then
				tex:SetPoint(quadPoints[i], parent, "CENTER")
			else
				tex:SetPoint(quadPoints[i])
			end
			group[i] = tex
		end
		return group
	end
	ORI_Circle = makequadtex("ARTWORK", 64, basepath .. "\\gfx\\circle.tga");
	ORI_Glow = makequadtex("BACKGROUND", 128, basepath .. "\\gfx\\glow.tga");
	function ORI_Circle:SetAnimationPeriod(p)
		local p = max(0.1, p)
		for i=1,4 do animations[i]:SetDuration(p) end
	end
end

local OR_SpellCaption = OR_IndicationFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
	OR_SpellCaption:SetPoint("TOP", OR_IndicationFrame, "CENTER", 0, -20-32); OR_SpellCaption:SetJustifyH("CENTER");
local OR_SpellCD = OR_IndicationFrame:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge");
	OR_SpellCD:SetJustifyH("CENTER"); OR_SpellCD:SetJustifyV("CENTER"); OR_SpellCD:SetPoint("CENTER");
local OR_CenterIndication = CreateFrame("CheckButton", "ORI_CenterContainer", OR_IndicationFrame);
	OR_CenterIndication:SetSize(28, 28); OR_CenterIndication:SetPoint("CENTER"); OR_CenterIndication:EnableMouse(false);
	OR_CenterIndication:SetCheckedTexture(""); OR_CenterIndication:SetHighlightTexture("");
	local OR_SpellIcon = OR_CenterIndication:CreateTexture(nil, "ARTWORK");
	OR_SpellIcon:SetAllPoints(); OR_SpellIcon:SetAlpha(0.8);
	local OR_SpellCount = OR_CenterIndication:CreateFontString(nil, "OVERLAY", "NumberFontNormalLarge");
	OR_SpellCount:SetPoint("BOTTOMRIGHT", -1, 1);
local ORMI_Parent = CreateFrame("Frame", "ORI_MIParent", OR_IndicationFrame);
	ORMI_Parent:SetSize(256, 256); ORMI_Parent:SetPoint("CENTER");

local CSL = CreateFrame("ColorSelect")
local function darken(r,g,b, vf, sf)
	CSL:SetColorRGB(r,g,b)
	local h,s,v = CSL:GetColorHSV()
	CSL:SetColorHSV(h, s*(sf or 1), v*(vf or 1))
	return CSL:GetColorRGB()
end

local function ORMI_SetAngle(self, angle, radius)
	self:ClearAllPoints();
	self:SetPoint("CENTER", radius*cos(90+angle), radius*sin(90+angle));
	self.icon:SetAlpha(1)
end
local function ORMI_SetScaleSmoothed(self, scale)
	local old, limit = self:GetScale(), 2^(ORI_ConfigCache.XTScaleSpeed)/GetFramerate();
	self:SetScale(old + min(limit, max(-limit, scale-old)));
end
local function ORMI_AnimateCooldown(self, elapsed)
	local ucd = self.updateCooldown or 0
	if ucd > elapsed then
		self.updateCooldown = ucd - elapsed
		return
	end
	self.updateCooldown = self.updateCooldownStep
	local expire, duration = self.expire or 0, self.duration or 0
	local progress = 1 - (expire - GetTime())/duration
	if progress > 1 or duration == 0 then
		self:Hide()
	else
		progress = progress < 0 and 0 or progress
		local tri, pos, sp, pp = self[9], 1+4*(progress - progress % 0.25), progress % 0.25 >= 0.125, (progress % 0.125) * 8
		if self.pos ~= pos then
			for i=1,4 do
				self[i]:SetShown(i >= pos)
				self[4+i]:SetShown(i > pos or (i == pos and not sp))
				if i > pos then
					self[i]:SetSize(24, 24)
					local L, T = i > 2, i == 1 or i == 4
					self[i]:SetTexCoord(L and 0 or 0.5, L and 0.5 or 1, T and 0 or 0.5, T and 0.5 or 1)
					self[4+i]:SetSize(21, 21)
				end
			end
			tri:ClearAllPoints()
			tri:SetPoint((pos % 4 < 2 and "BOTTOM" or "TOP") .. (pos < 3 and "LEFT" or "RIGHT") , self, "CENTER")
			local iH, iV = pos == 2 or pos == 3, pos > 2
			tri:SetTexCoord(iH and 1 or 0, iH and 0 or 1, iV and 1 or 0, iV and 0 or 1)
			self.pos = pos
		end
		
		local l, r, inv = sp and 21 or (pp * 21), 21 - (sp and pp * 21 or 0), pos == 2 or pos == 4
		tri:SetSize(inv and r or l, inv and l or r)
		
		local chunk, shrink = self[4+pos], 21 - 21*pp
		chunk:SetSize(inv and 21 or shrink, inv and shrink or 21)
		chunk:SetShown(not sp or pp >= 0.99)
		
		local p1, p2, e = sp and 1 or pp, sp and pp or 0, self[pos]
		local p1c, p2c = 24 - 21*p1, 24 - 24*p2
		e:SetSize(inv and p2c or p1c, inv and p1c or p2c)
		if pos == 1 then
			e:SetTexCoord(0.5 + 28/64*p1, 1, 0.5*p2, 0.5)
		elseif pos == 2 then
			e:SetTexCoord(0.5, 1-0.5*p2, 0.5 + 28/64*p1, 1)
		elseif pos == 3 then
			e:SetTexCoord(0, 0.5 - 28/64*p1, 0.5, 1 - 0.5*p2)
		else
			e:SetTexCoord(0.5*p2, 0.5, 0, 0.5 - 28/64*p1)
		end
		if p2 >= 0.99 then e:Hide() end
	end
end
local function ORMI_HideCooldown(self)
	local toExpire = GetTime() - (self.expire or 0)
	self.expire, self.pos = nil
	for i=5,#self do self[i]:Hide() end
	if toExpire < 0.25 and toExpire > -0.1 then
		self.flash:Play()
	end
end
local function ORMI_ShowCooldown(self)
	self[9]:Show()
end
local function ORMI_SetCooldown(self, remain, duration)
	if (duration or 0) <= 0 or (remain or 0) <= 0 then
		self.cd:Hide()
	else
		local expire = GetTime() + remain
		local d = expire - (self.cd.expire or 0)
		if d < -0.05 or d > 0.05 then
			self.cd.duration, self.cd.expire, self.cd.updateCooldownStep, self.cd.updateCooldown = duration, expire, duration/384/self:GetEffectiveScale()
			self.cd:Show()
		end
	end
end
local function ORMI_SetDominantColor(self, r, g, b)
	r, g, b = r or 0.80, g or 0.80, b or 0.80;
	self.edge:SetVertexColor(darken(r,g,b, 0.80))
	local r2, g2, b2 = darken(r,g,b, 0.20)
	for i=1,4 do
		self.cd[i]:SetVertexColor(r2, g2, b2)
	end
	local r3, g3, b3 = darken(r,g,b, 0.10, 0.50)
	for i=5,9 do
		self.cd[i]:SetVertexColor(r3, g3, b3, 0.85)
	end
	self:GetHighlightTexture():SetVertexColor(r, g, b);
	self:GetCheckedTexture():SetVertexColor(r, g, b);
	self.oglow:SetVertexColor(r, g, b);
	self.text:SetTextColor(r, g, b);
end
local function ORMI_SetIconTexCoord(self, a,b,c,d, e,f,g,h)
	if a and b and c and d and e and f and g and h then
		self.icon:SetTexCoord(a,b,c,d,e,f,g,h)
	elseif a and b and c and d then
		self.icon:SetTexCoord(a,b,c,d)
	end
end
local function ORMI_SetOuterGlow(self, show)
	self.oglow[show and "Show" or "Hide"](self.oglow)
end
local function CreateTexture(parent, path, layer, sublevel, ...)
	local tex = parent:CreateTexture()
	tex:SetDrawLayer(layer, sublevel)
	tex:SetTexture(path)
	tex[... and "SetPoint" or "SetAllPoints"](tex, ...)
	return tex
end
local function ORI_FinishSpawnOPie(e, parent, ghost)
	e.cd = CreateFrame("FRAME", nil, e) e.cd:SetAllPoints()
	e.cd:SetScript("OnShow", ORMI_ShowCooldown) e.cd:SetScript("OnHide", ORMI_HideCooldown)
	if ghost then e:GetCheckedTexture():SetAlpha(0.60) end
	e.SetDominantColor, e.SetCooldown, e.SetIconTexCoord, e.SetOuterGlow = ORMI_SetDominantColor, ORMI_SetCooldown, ORMI_SetIconTexCoord, ORMI_SetOuterGlow
	e.oglow = makequadtex("BACKGROUND", 96, "Interface\\AddOns\\OPie\\gfx\\oglow", e)
	e:GetHighlightTexture():SetBlendMode("BLEND")
	e.icon:SetSize(45, 45)
	e.icon.overlay = CreateTexture(e, "Interface\\MINIMAP\\TRACKING\\OBJECTICONS", "ARTWORK", 1, "BOTTOMLEFT", -4, 4)
	e.icon.overlay:SetSize(28, 28) e.icon.overlay:SetTexCoord(32/256, 64/256, 32/64, 1)
	e.edge = CreateTexture(e, "Interface\\AddOns\\OPie\\gfx\\borderlo", "OVERLAY", 0)
	e.cd[1] = CreateTexture(e.cd, "Interface\\AddOns\\OPie\\gfx\\borderlo", "OVERLAY", 1, "BOTTOMRIGHT", e.cd, "RIGHT")
	e.cd[2] = CreateTexture(e.cd, "Interface\\AddOns\\OPie\\gfx\\borderlo", "OVERLAY", 1, "BOTTOMLEFT", e.cd, "BOTTOM")
	e.cd[3] = CreateTexture(e.cd, "Interface\\AddOns\\OPie\\gfx\\borderlo", "OVERLAY", 1, "TOPLEFT", e.cd, "LEFT")
	e.cd[4] = CreateTexture(e.cd, "Interface\\AddOns\\OPie\\gfx\\borderlo", "OVERLAY", 1, "TOPRIGHT", e.cd, "TOP")
	for i=1,4 do
		local tex, point = e:CreateTexture(), (i % 4 < 2 and "TOP" or "BOTTOM") .. (i < 3 and "RIGHT" or "LEFT")
		tex:SetDrawLayer("ARTWORK", 2)
		tex:SetTexture(1,1,1)
		tex:SetPoint(point, e.cd, "CENTER", (i < 3 and 21 or -21), (i % 4 < 2 and 21 or -21))
		e.cd[4+i] = tex
	end
	e.cd[9] = CreateTexture(e, "Interface\\Addons\\OPie\\gfx\\tri", "ARTWORK", 2)
	e.cd:SetScript("OnUpdate", ORMI_AnimateCooldown)
	e.cdFlash = CreateTexture(e, "Interface\\cooldown\\star4", "OVERLAY", 0, "CENTER", e.icon, "CENTER")
	e.cdFlash:SetSize(60, 60) e.cdFlash:SetBlendMode("ADD") e.cdFlash:SetAlpha(0)
	e.cd.flash = e.cdFlash:CreateAnimationGroup()
	e.cd.flash:SetIgnoreFramerateThrottle(true)
	local rot, a1, a2 = e.cd.flash:CreateAnimation("ROTATION"), e.cd.flash:CreateAnimation("ALPHA"), e.cd.flash:CreateAnimation("ALPHA")
	rot:SetDegrees(-90) rot:SetDuration(0.25)
	a1:SetChange(0.5) a1:SetDuration(1/12)
	a2:SetChange(-0.5) a2:SetDuration(1/6) a2:SetStartDelay(1/12)
	e.count:SetPoint("BOTTOMRIGHT", -4, 4)
	e.oglow:Hide()
end
local ORI_FinishSpawn = ORI_FinishSpawnOPie
local function ORI_SpawnIndicator(name, parent, ghost)
	local e = CreateFrame("CheckButton", name, parent);
	e.icon, e.text, e.count, e.key = e:CreateTexture(nil, "ARTWORK"),
		e:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge"),
		e:CreateFontString(nil, "OVERLAY", "NumberFontNormalLarge"),
		e:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmallGray");
	e.SetAngle, e.SetScaleSmoothed = ORMI_SetAngle, ORMI_SetScaleSmoothed
	e:SetSize(48, 48); e.icon:SetPoint("CENTER");
	e.text:SetPoint("CENTER");
	e.key:SetPoint("TOPRIGHT", -1, -4); e.key:SetJustifyH("RIGHT");
	e:EnableMouse(false);
	e:SetHighlightTexture("Interface\\AddOns\\OPie\\gfx\\borderhi");
	e:SetCheckedTexture("Interface\\AddOns\\OPie\\gfx\\iglow");
	ORI_FinishSpawn(e, parent, ghost)
	return e;
end
local function ORI_RadiusCalc(n, fLength, aLength, min)
	local radius, mLength, astep = min, (fLength+aLength)/2, 360 / n;
	repeat
		local ox, oy, clear = radius, 0, true;
		for i=1,n-1 do
			local nx, ny, sideLength = radius*cos(i*astep), radius*sin(i*astep), (i == 1 or i == n) and mLength or aLength;
			if abs(ox - nx) < sideLength and abs(oy - ny) < sideLength then
				clear, radius = false, radius + 5;
				break;
			end
			ox, oy = nx, ny;
		end
	until clear;
	return radius;
end
local function ORMI_ComputeRadius(n)
	return ORI_RadiusCalc(n, 48, 48, 95);
end
local OR_MICount = 0
local OR_MultiIndicators = setmetatable({}, {__index=function(t, k) OR_MICount = OR_MICount + 1 return rawset(t,k, ORI_SpawnIndicator("ORMI_Container" .. k .. "x" .. OR_MICount, ORMI_Parent))[k]; end});
local ORMI_Radius = setmetatable({[0]=95}, {__index=function(t,k) return rawset(t,k, ORMI_ComputeRadius(k))[k]; end});
local GhostIndication = {};
do -- Ghost Indication widget details
	local spareGPool, spareBPool, currentGroups, allocatedBCount, activeGroup = {}, {}, {}, 0;
	local function freeGroup(g)
		g:Hide(); g.incident, g.count = nil;
		local i = 2 while g[i] do
			spareBPool[g[i]], i, g[i] = 0, i + 1
		end
	end
	local cnt = 1
	local function makeGroup()
		local g = CreateFrame("Frame", nil, ORMI_Parent);
		g:Hide(); g:SetWidth(20); g:SetHeight(20); g:SetScale(0.80);
		return g;
	end
	setmetatable(spareGPool, {__newindex=function(self, k, v) rawset(self, k, v and freeGroup(k) or nil); end});
	local function AnimateHide(self, elapsed)
		local total = ORI_ConfigCache.XTZoomTime;
		self.expire = (self.expire or total) - elapsed;
		if self.expire < 0 then
			self.expire = nil; self:SetScript("OnUpdate", nil); self:Hide();
		else
			self:SetAlpha(self.expire/total);
		end
	end
	local function AnimateShow(self, elapsed)
		local total = ORI_ConfigCache.XTZoomTime/2;
		self.expire = (self.expire or total) - elapsed;
		if self.expire < 0 then
			self.expire = nil; self:SetScript("OnUpdate", nil); self:SetAlpha(1);
		else
			self:SetAlpha(1-self.expire/total);
		end
	end
	function GhostIndication:ActivateGroup(index, count, incidentAngle, mainRadius, mainScale)
		local ret, config = currentGroups[index] or next(spareGPool) or makeGroup(), ORI_ConfigCache;
		currentGroups[index], spareGPool[ret] = ret, nil;
		if not ret:IsShown() then ret:SetScript("OnUpdate", AnimateShow); ret:Show(); end
		if activeGroup ~= ret then GhostIndication:Deactivate(); end
		if ret.incident ~= incidentAngle or ret.count ~= count then
			local radius, angleStep = ORI_RadiusCalc(count, 48*mainScale, 48*0.80, 30)/0.80, 360/count;
			if config.GhostOldDirection then
				angleStep = ((incidentAngle + 90) % 360 >= 180) and -angleStep or angleStep;
			end
			local angle = 90 + incidentAngle + angleStep;
			for i=2,count do
				local cell = ret[i] or next(spareBPool);
				if not cell then
					cell, allocatedBCount = ORI_SpawnIndicator("ORI_Ghost" .. allocatedBCount, ret, true), allocatedBCount + 1;
				end
				cell:ClearAllPoints();
				cell:SetParent(ret); cell:SetAngle(angle, radius); cell:Show();
				spareBPool[cell], ret[i], angle = nil, cell, angle + angleStep;
			end
			ret.incident, ret.count = incidentAngle, count;
			ret:ClearAllPoints();
			ret:SetPoint("CENTER", (mainRadius/0.80+radius)*cos(incidentAngle), (mainRadius/0.80+radius)*sin(incidentAngle));
			ret:Show();
		end
		activeGroup = ret;
		return ret;
	end
	function GhostIndication:Deactivate()
		if activeGroup then
			activeGroup:SetScript("OnUpdate", AnimateHide);
			activeGroup = nil;
		end
	end
	function GhostIndication:Reset()
		for k, v in pairs(currentGroups) do
			currentGroups[k], spareGPool[v] = nil, true;
		end
		activeGroup = nil;
	end
	function GhostIndication:Wipe()
		GhostIndication:Deactivate()
		GhostIndication:Reset()
		table.wipe(spareBPool)
	end
end

local function GetSelectedSlice(x, y, slices, offset)
	if slices == 0 then return 0; end
	local radius, segAngle = (x*x + y*y)^0.5, 360 / slices;
	if radius < 40 or slices <= 0 then return 0; end
	local angle = (math.deg(math.atan2(x, y)) + segAngle/2 - offset) % 360;
	return floor(angle / segAngle) + 1;
end

local function ORI_SliceColor(token)
	return ORI_cR[token] or 0.5, ORI_cG[token] or 0.5, ORI_cB[token] or 0.5
end
local function shortBindName(bind)
	if not bind then return "" end
	local a, s, c, k = bind:match("ALT%-"), bind:match("SHIFT%-"), bind:match("CTRL%-"), bind:match("[^-]*.$"):gsub("^(.).-(%d+)$","%1%2");
	return (a and "A" or "") .. (s and "S" or "") .. (c and "C" or "") .. k;
end
local function ORI_CooldownFormat(cd)
	if cd == 0 or not cd then return ""; end
	local f, n, unit = cd > 10 and "%d%s" or "%.1f", cd, "";
	if n > 86400 then n, unit = ceil(n/86400), "d";
	elseif n > 3600 then n, unit = ceil(n/3600), "h";
	elseif n > 60 then n, unit = ceil(n/60), "m";
	elseif n > 10 then n = ceil(n); end
	return f, n, unit;
end
local function extractAux(ext, v)
	if v == "color" and type(ext.iconR) == "number" and type(ext.iconG) == "number" and type(ext.iconB) == "number" then
		return ext.iconR, ext.iconG, ext.iconB;
	elseif v == "coord" and type(ext.iconCoords) == "table" then
		return unpack(ext.iconCoords);
	elseif v == "coord" and type(ext.iconCoords) == "function" or type(ext.iconCoords) == "userdata" then
		return ext:iconCoords();
	end
end
local function applyCoords(l, r, t, b, ok, s, ...)
	if type(ok) ~= "boolean" and ok ~= nil then
		return applyCoords(l, r, t, b, pcall(extractAux, ok, "coord"))
	elseif ok == true and s then
		return s, ...
	else
		return l, r, t, b
	end
end
local function ORI_UpdateCenterIndication(self, si, osi)
	local config, count, offset, isUpdated, time = ORI_ConfigCache, self.count, self.offset, si ~= osi, GetTime();
	local sliceExists = OneRingLib:GetOpenRingSlice(si);
	local tok, usable, state, icon, caption, count, cd, cd2, tipFunc, tipArg, ext = OneRingLib:GetOpenRingSliceAction(si);
	local active = (state or 0) % 2 > 0
	if sliceExists then
		local r,g,b = ORI_SliceColor(tok)
		ORI_Pointer:SetVertexColor(r,g,b, 0.9);
		ORI_Circle:SetVertexColor(r,g,b, 0.9);
		ORI_Glow:SetVertexColor(r,g,b);
		OR_SpellCaption:SetTextColor(r,g,b);
		OR_SpellCD:SetTextColor(r,g,b);
	elseif isUpdated then
		ORI_Pointer:SetVertexColor(1,1,1,0.1);
		ORI_Circle:SetVertexColor(1,1,1,0.3);
		ORI_Glow:SetVertexColor(0.75,0.75,0.75);
		GameTooltip:Hide();
	end
	caption = ORI_caption[tok] or caption
	icon, ext = ORI_icon[tok] or icon, not ORI_icon[tok] and ext or nil

	if sliceExists then
		OR_SpellIcon:SetTexture(icon);
		if icon then
			OR_SpellIcon:SetTexCoord(applyCoords(0.08, 0.92, 0.08, 0.92, ext))
			local ok, r,g,b = pcall(extractAux, ext, "color");
			if ok and r then
				OR_SpellIcon:SetVertexColor(r,g,b);
			end
		end
		if config.UseGameTooltip and tipFunc and tipArg then
			GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
			tipFunc(GameTooltip, tipArg);
			GameTooltip:Show();
		elseif config.UseGameTooltip then
			if caption and caption ~= "" then
				GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
				GameTooltip:AddLine(caption)
				GameTooltip:Show()
			else
				GameTooltip:Hide()
			end
		end
		OR_CenterIndication:SetChecked(active and 1 or nil);
	end
	OR_CenterIndication[sliceExists and icon and config.ShowCenterIcon and (not config.MultiIndication) and "Show" or "Hide"](OR_CenterIndication);
	OR_SpellCD:SetFormattedText(ORI_CooldownFormat(sliceExists and config.ShowCooldowns and cd or 0));
	OR_SpellCaption:SetText(sliceExists and config.ShowCenterCaption and caption or "");
	OR_SpellCount:SetText(sliceExists and icount and icount > 0 and icount or "");

	usable = usable == true;
	local gAnim, gEnd, oIG = self.gAnim, self.gEnd, self.oldIsGlowing;
	if usable ~= oIG then
		gAnim, gEnd = usable and "in" or "out",  time + 0.3 - (gEnd and gEnd > time and (gEnd-time) or 0);
		self.oldIsGlowing, self.gAnim, self.gEnd = usable, gAnim, gEnd;
		ORI_Glow:Show();
	end
	if (gAnim and gEnd <= time) or oIG == nil then
		self.gAnim, self.gEnd = nil, nil;
		ORI_Glow[gAnim == "in" and "Show" or "Hide"](ORI_Glow);
		ORI_Glow:SetAlpha(0.75);
	elseif gAnim then
		local pg = (gEnd-time)/0.3*0.75;
		ORI_Glow:SetAlpha(gAnim == "out" and (pg) or (0.75 - pg));
	end
	self.oldSlice = si;
	return sliceExists;
end
local function ORMI_UpdateSlice(indic, selected, tok, usable, state, icon, _, count, cd, cd2, tf, ta, ext)
	state, icon, ext = state or 0, ORI_icon[tok] or icon, not ORI_icon[tok] and ext or nil
	local active, overlay = state % 2 > 0, state % 4 > 1
	local config = ORI_ConfigCache
	local faded = (cd or 0) > 0 or not usable
	indic.icon:SetTexture(icon or "Interface/Icons/INV_Misc_QuestionMark")
	local tex = indic.icon:GetTexture()
	local ofs = (tex:match("^[Ii][Nn][Tt][Ee][Rr][Ff][Aa][Cc][Ee][\\/][Ii][Cc][Oo][Nn][Ss][\\/]") or tex:match("^Interface[\\/]AddOns[\\/]OPie")) and (2/64) or (-2/64)
	indic:SetIconTexCoord(applyCoords(ofs, 1-ofs, ofs, 1-ofs, ext))
	indic:SetOuterGlow(overlay and true or false)
	local c, ok, r,g,b = faded and 0.5 or 1, pcall(extractAux, ext, "color")
	if ok and r then
		r,g,b = r*c, g*c, b*c
	else
		r,g,b = c,c,c
	end
	indic:SetDominantColor(ORI_SliceColor(tok))
	indic.icon:SetVertexColor(r,g,b)
	local qover = indic.icon.overlay
	if qover then
		qover:SetShown(ORI_qHint[tok] or ((state or 0) % 64 >= 32))
	end
	indic:SetCooldown(cd, cd2)
	indic.text:SetFormattedText(ORI_CooldownFormat(config.ShowCooldowns and cd or 0))
	indic.count:SetText(count and count > 0 and count or "")
	indic:SetEnabled(not faded)
	indic:SetChecked(active and 1 or nil)
	indic[selected and not faded and "LockHighlight" or "UnlockHighlight"](indic)
end
local function ORI_GhostUpdate(self, slice)
	local config, count, offset = ORI_ConfigCache, self.count, self.offset;
	local _, _, _, ghostCount = OneRingLib:GetOpenRingSlice(slice or 0);
	if (ghostCount or 0) == 0 then return GhostIndication:Deactivate(); end
	local scaleM = config.MIScale and 1.10 or 1;
	local group = GhostIndication:ActivateGroup(slice, ghostCount, 90 - 360/count*(slice-1) - offset, ORMI_Radius[count]*scaleM, 1.10);
	for i=2,ghostCount do
		ORMI_UpdateSlice(group[i], false, OneRingLib:GetOpenRingSliceAction(slice, i));
	end
end
local function pround(n, precision, half)
	local remainder = n % precision;
	return remainder >= half and (n - remainder + precision) or (n - remainder);
end
local function ORI_Update(self, elapsed)
	local time, config, count, offset = GetTime(), ORI_ConfigCache, self.count, self.offset

	local scale, l, b, w, h = self:GetEffectiveScale(), self:GetRect();
	local x, y = GetCursorPosition();
	local dx, dy = (x / scale) - (l + w / 2), (y / scale) - (b + h / 2);
	dx, dy = pround(dx, 0.005, 0.0025), pround(dy, 0.005, 0.0025);
	local radius = (dx*dx+dy*dy)^0.5;

	-- Calculate pointer location
	local angle, isInFastClick = (math.deg(math.atan2(dx, dy)) -180) % 360, config.CenterAction and radius <= 20 and self.fastClickSlice > 0 and self.fastClickSlice <= self.count;
	if isInFastClick then
		angle = (offset + (self.fastClickSlice-1)*360/count - 180) % 360;
	end

	local oangle = (not isInFastClick) and self.angle or angle;
	local adiff, arate = min((angle-oangle) % 360, (oangle-angle) % 360), 180;
	if adiff > 60 then
		arate = 420 + 120*sin(min(90, adiff-60));
	elseif adiff > 15 then
		arate = 180 + 240*sin(min(90, max((adiff-15)*2, 0)));
	else
		arate = 20 + 160*sin(min(90, adiff*6));
	end
	local abound, arotDirection = arate/GetFramerate(), ((oangle - angle) % 360 < (angle - oangle) % 360) and -1 or 1;
	abound = abound * 2^config.XTPointerSpeed;
	self.angle = (adiff < abound) and angle or (oangle + arotDirection * abound) % 360;
	ORI_Pointer:SetRotation((1-self.angle/180)*3.1415926535898);

	-- What is selected?
	local si, osi = isInFastClick and self.fastClickSlice or GetSelectedSlice(dx, dy, count, offset), self.oldSlice;
	local sliceExists = ORI_UpdateCenterIndication(self, si, osi);

	-- Multiple indication
	if config.MultiIndication and count > 0 then
		local cmState, mut = (IsShiftKeyDown() and 1 or 0) + (IsControlKeyDown() and 2 or 0) + (IsAltKeyDown() and 4 or 0), self.schedMultiUpdate or 0;
		if self.omState ~= cmState or mut >= 0  then
			self.omState, self.schedMultiUpdate = cmState, -0.05;
			for i=1,count do
				ORMI_UpdateSlice(OR_MultiIndicators[i], si == i, OneRingLib:GetOpenRingSliceAction(i));
			end
			if config.GhostMIRings then
				ORI_GhostUpdate(self, si);
			end
		else
			self.schedMultiUpdate = mut + elapsed;
		end

		for i=1,config.MIScale and count or 0 do
			OR_MultiIndicators[i]:SetScaleSmoothed(i == si and 1.10 or 1)
		end
	end
end
local function ORI_ZoomIn(self, elapsed)
	self.eleft = self.eleft - elapsed;
	local delta, config = max(0, self.eleft/ORI_ConfigCache.XTZoomTime), ORI_ConfigCache;
	if delta == 0 then self:SetScript("OnUpdate", ORI_Update); end
	self:SetScale(config.RingScale/max(0.2,cos(65*delta))); self:SetAlpha(1-delta);
	return ORI_Update(self, elapsed);
end
local function ORI_ZoomOut(self, elapsed)
	self.eleft = self.eleft - elapsed;
	local delta, config = max(0, self.eleft/ORI_ConfigCache.XTZoomTime), ORI_ConfigCache;
	if delta == 0 then return self:Hide(), self:SetScript("OnUpdate", nil); end
	if config.MultiIndication and config.MISpinOnHide then
		local count = self.count;
		if count > 0 then
			local baseAngle, angleStep, radius, prog = 45 - self.offset + 45*delta, 360/count, ORMI_Radius[count], (1-delta)*150*max(0.5, min(1, GetFramerate()/60));
			for i=1,count do
				OR_MultiIndicators[i]:SetPoint("CENTER", cos(baseAngle)*radius + cos(baseAngle-90)*prog, sin(baseAngle)*radius + sin(baseAngle-90)*prog);
				baseAngle = baseAngle - angleStep;
			end
		end
		self:SetScale(config.RingScale*(1.75 - .75*delta));
	else
		self:SetScale(config.RingScale*delta);
	end
	self:SetAlpha(delta);
end
OR_IndicationFrame:SetScript("OnHide", function(self)
	if self:IsShown() and self:GetScript("OnUpdate") == ORI_ZoomOut then
		self:SetScript("OnUpdate", nil)
		self:Hide()
	end
end)
-- Animator Interface
function ORI:Show(ringName, fcSlice, fastOpen)
	local frame, config, _ = OR_IndicationFrame, ORI_ConfigCache;

	-- Copy ring configuration to indication frame.
	_, frame.count, frame.offset = OneRingLib:GetOpenRing(config);

	-- Zoom in to the ring's indication option
	frame:SetScript("OnUpdate", ORI_ZoomIn);
	frame.eleft, frame.fastClickSlice = config.XTZoomTime * (fastOpen and 0.5 or 1), fcSlice or 0;
	ORI_Circle:SetAnimationPeriod(config.XTRotationPeriod)
	MouselookStop();

	-- Show/Hide multiple indication icons as required
	local useMultipleIndication, astep, radius = config.MultiIndication, frame.count == 0 and 0 or -360/frame.count, ORMI_Radius[frame.count];
	for i=1,(useMultipleIndication and frame.count or 0) do
		local indic, _, tok, sliceBind  = OR_MultiIndicators[i], OneRingLib:GetOpenRingSlice(i);
		indic.key:SetText(config.ShowKeys and sliceBind and shortBindName(sliceBind) or "");
		indic:SetAngle((i - 1) * astep - frame.offset, radius);
		indic:Show(); indic:UnlockHighlight();
	end
	for i=(useMultipleIndication and (frame.count+1) or 1),#OR_MultiIndicators do
		OR_MultiIndicators[i]:Hide();
	end
	for i, v in ipairs(OR_MultiIndicators) do v:SetAlpha(1); v:SetScale(1); end
	ORMI_Parent:SetAlpha(1); ORMI_Parent:SetScale(1);

	-- Show the indication frame
	config.RingScale = max(0.1, config.RingScale);
	frame:SetScale(config.RingScale); OR_IndicationPos:SetScale(frame:GetScale());
	if config.RingAtMouse then
		local es, cx, cy = frame:GetEffectiveScale(), GetCursorPosition()
		OR_IndicationPos:SetPoint("CENTER", nil, "BOTTOMLEFT", cx/es+ config.IndicationOffsetX, cy/es - config.IndicationOffsetY);
	else
		OR_IndicationPos:SetPoint("CENTER", nil, "CENTER", config.IndicationOffsetX, -config.IndicationOffsetY);
	end
	frame:Show();

	-- And reset all visual indication elements
	frame.oldSlice, frame.angle, frame.omState, frame.oldIsGlowing = -1;
	GhostIndication:Reset();
	ORI_Update(frame, 0);
end
function ORI:Hide()
	OR_IndicationFrame:SetScript("OnUpdate", ORI_ZoomOut);
	OR_IndicationFrame.eleft = ORI_ConfigCache.XTZoomTime;
	GhostIndication:Deactivate();
	GameTooltip:Hide();
end
function ORI:SetDisplayOptions(sliceToken, icon, caption, r,g,b)
	ORI_cR[sliceToken], ORI_cG[sliceToken], ORI_cB[sliceToken] = r,g,b
	ORI_caption[sliceToken], ORI_icon[sliceToken] = caption, icon
end
function ORI:SetQuestHint(sliceToken, hint)
	ORI_qHint[sliceToken] = hint
end
OR_IndicationFrame:Hide();

OneRingLib.ext.OPieUI = ORI
OneRingLib:SetAnimator(ORI);
for k,v in pairs(ORI_OptionDefaults) do
	OneRingLib:RegisterOption(k,v);
end

local group, noop = false, function() end
local function MasqueGroup()
	local Masque = LibStub and LibStub("Masque", 1)
	if Masque then group = Masque:Group("OPie") end
	return group
end
local function FinishMasque(e, parent, ghost)
	e.SetDominantColor, e.SetCooldown, e.SetIconTexCoord, e.SetOuterGlow = noop, noop, noop, noop
	pcall(group.AddButton, group, e, {Icon=e.icon, Count=e.count, HotKey=e.key});
end
OneRingLib:RegisterOption("UseBF", false, function(_, val)
	if val and MasqueGroup() then
		group:AddButton(OR_CenterIndication, {Icon=OR_SpellIcon, Count=OR_SpellCount});
		ORI_FinishSpawn = FinishMasque
	elseif not val and group then
		group:Delete()
		ORI_FinishSpawn, group = ORI_FinishSpawnOPie
	else
		return
	end
	-- Everything the Masque light touches... must be purged.
	for k,v in pairs(OR_MultiIndicators) do
		OR_MultiIndicators[k] = nil
		v:Hide()
	end
	GhostIndication:Wipe()
end)