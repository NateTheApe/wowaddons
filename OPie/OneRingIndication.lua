local ORI_ConfigCache, max, min, abs, sin, cos, atan2 = {}, math.max, math.min, math.abs, sin, cos, atan2

local function cc(m, f, ...)
	f[m](f, ...)
	return f
end
local darken do
	local CSL = CreateFrame("ColorSelect")
	function darken(r,g,b, vf, sf)
		CSL:SetColorRGB(r,g,b)
		local h,s,v = CSL:GetColorHSV()
		CSL:SetColorHSV(h, s*(sf or 1), v*(vf or 1))
		return CSL:GetColorRGB()
	end
end
local function shortBindName(bind)
	local a, s, c, k = bind:match("ALT%-"), bind:match("SHIFT%-"), bind:match("CTRL%-"), bind:match("[^-]*.$"):gsub("^(.).-(%d+)$","%1%2");
	return (a and "A" or "") .. (s and "S" or "") .. (c and "C" or "") .. k;
end
local function cooldownFormat(cd)
	if cd == 0 or not cd then return "" end
	local f, n, unit = cd > 10 and "%d%s" or "%.1f", cd, ""
	if n > 86400 then n, unit = ceil(n/86400), "d"
	elseif n > 3600 then n, unit = ceil(n/3600), "h"
	elseif n > 60 then n, unit = ceil(n/60), "m"
	elseif n > 10 then n = ceil(n) end
	return f, n, unit
end

local ORI_Frame = cc("SetFrameStrata", cc("SetSize", CreateFrame("Frame", nil, UIParent), 128, 128), "FULLSCREEN")
ORI_Frame.anchor = cc("SetPoint", cc("SetSize", CreateFrame("Frame", nil, UIParent), 1, 1), "CENTER")
ORI_Frame:SetPoint("CENTER", ORI_Frame.anchor)
local ORI_SetRotationPeriod, CreateQuadTexture do
	local function qf(f)
		return function (self, ...)
			for i=1,4 do
				local v = self[i];
				v[f](v, ...);
			end
		end
	end
	local quad, animations, quadPoints, quadTemplate = {}, {}, {"BOTTOMRIGHT", "BOTTOMLEFT", "TOPLEFT", "TOPRIGHT"}, {__index={SetVertexColor=qf("SetVertexColor"), SetAlpha=qf("SetAlpha"), SetShown=qf("SetShown")}}
	for i=1,4 do
		quad[i] = cc("SetPoint", cc("SetSize", CreateFrame("Frame", nil, ORI_Frame), 32, 32), quadPoints[i], ORI_Frame, "CENTER");
		local g = cc("SetLooping", cc("SetIgnoreFramerateThrottle", quad[i]:CreateAnimationGroup(), 1), "REPEAT");
		animations[i] = cc("SetOrigin", cc("SetDegrees", cc("SetDuration", g:CreateAnimation("Rotation"), 4), -360), quadPoints[i], 0, 0);
		g:Play();
	end
	function CreateQuadTexture(parent, layer, size, file)
		local group, size = setmetatable({}, quadTemplate), size/2
		for i=1,4 do
			local tex, d, l = cc("SetSize", cc("SetTexture", (parent or quad[i]):CreateTexture(nil, layer), file), size, size), i > 2, 2 > i or i > 3
			tex:SetTexCoord(l and 0 or 1, l and 1 or 0, d and 1 or 0, d and 0 or 1)
			group[i] = cc("SetPoint", tex, quadPoints[i], parent or quad[i], parent and "CENTER" or quadPoints[i])
		end
		return group
	end
	function ORI_SetRotationPeriod(p)
		local p = max(0.1, p)
		for i=1,4 do animations[i]:SetDuration(p) end
	end
end
local ORI_Circle = CreateQuadTexture(nil, "ARTWORK", 64, [[Interface\AddOns\OPie\gfx\circle]])
local ORI_Glow = CreateQuadTexture(nil, "BACKGROUND", 128, [[Interface\AddOns\OPie\gfx\glow]])
local ORI_Pointer = cc("SetTexture", cc("SetPoint", cc("SetSize", ORI_Frame:CreateTexture(nil, "ARTWORK"), 192, 192), "CENTER"), [[Interface\AddOns\OPie\gfx\pointer]])
local ORI_CenterCaption = cc("SetPoint", ORI_Frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall"), "TOP", ORI_Frame, "CENTER", 0, -52)
local ORI_CenterCooldownText = cc("SetPoint", ORI_Frame:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge"), "CENTER")

local ORI_CreateIndicator, ORI_CreateDefaultIndicator, ORI_IndicatorAPI do
	ORI_IndicatorAPI = {SetPoint=0, SetScale=0, GetScale=0, SetShown=0, SetParent=0}
	for k,v in pairs(ORI_IndicatorAPI) do
		ORI_IndicatorAPI[k] = function(self, ...)
			local w = self[v]
			return w[k](w, ...)
		end
	end
	function ORI_IndicatorAPI:SetIcon(texture)
		self.icon:SetTexture(texture)
		local ofs = (texture:match("^[Ii][Nn][Tt][Ee][Rr][Ff][Aa][Cc][Ee][\\/][Ii][Cc][Oo][Nn][Ss][\\/]") or texture == [[Interface\AddOns\OPie\gfx\opie_ring_icon]]) and (2.5/64) or (-2/64)
		self.icon:SetTexCoord(ofs, 1-ofs, ofs, 1-ofs)
	end
	function ORI_IndicatorAPI:SetIconTexCoord(a,b,c,d, e,f,g,h)
		if a and b and c and d then
			if e and f and g and h then
				self.icon:SetTexCoord(a,b,c,d, e,f,g,h)
			else
				self.icon:SetTexCoord(a,b,c,d)
			end
		end
	end
	function ORI_IndicatorAPI:SetIconVertexColor(r,g,b)
		self.icon:SetVertexColor(r,g,b)
	end
	function ORI_IndicatorAPI:SetUsable(usable, usableCharge, cd, nomana, norange)
		local state = usable and 0 or (norange and 1 or (nomana and 2 or 3))
		if self.ustate == state then return end
		self.ustate = state
		if not usable and (nomana or norange) then
			self.ribbon:Show()
			if norange then
				self.ribbon:SetVertexColor(1, 0.20, 0.15)
			else
				self.ribbon:SetVertexColor(0.15, 0.75, 1)
			end
			self.veil:SetAlpha(0)
		else
			self.ribbon:Hide()
			self.veil:SetAlpha(usable and 0 or 0.40)
		end
	end
	function ORI_IndicatorAPI:SetDominantColor(r,g,b)
		r, g, b = r or 1, g or 1, b or 0.6
		local cd, r2, g2, b2 = self.cd, darken(r,g,b, 0.20)
		local r3, g3, b3 = darken(r,g,b, 0.10, 0.50)
		self.hiEdge:SetVertexColor(r, g, b)
		self.iglow:SetVertexColor(r, g, b)
		self.oglow:SetVertexColor(r, g, b)
		self.edge:SetVertexColor(darken(r,g,b, 0.80))
		self.cdText:SetTextColor(r, g, b)		
		cd.spark:SetVertexColor(r, g, b)
		for i=1,4 do
			cd[i]:SetVertexColor(r2, g2, b2)
			cd[i+4]:SetVertexColor(r3, g3, b3)
		end
		cd[9]:SetVertexColor(r3, g3, b3)
	end
	function ORI_IndicatorAPI:SetOverlayIcon(texture, w, h, ...)
		if not texture then
			self.overIcon:Hide()
		else
			self.overIcon:Show()
			self.overIcon:SetTexture(texture)
			self.overIcon:SetSize(w, h)
			if ... then
				self.overIcon:SetTexCoord(...)
			end
		end
	end
	function ORI_IndicatorAPI:SetCount(count)
		self.count:SetText(count or "")
	end
	function ORI_IndicatorAPI:SetBindingText(text)
		self.key:SetText(text or "")
	end
	function ORI_IndicatorAPI:SetCooldown(remain, duration, usable)
		if (duration or 0) <= 0 or (remain or 0) <= 0 then
			self.cd:Hide()
		else
			local expire, usable, cd = GetTime() + remain, not not usable, self.cd
			local d = expire - (cd.expire or 0)
			if d < -0.05 or d > 0.05 then
				cd.duration, cd.expire, cd.updateCooldownStep, cd.updateCooldown = duration, expire, duration/1536/self[0]:GetEffectiveScale()
				cd:Show()
			end
			if cd.usable ~= usable then
				cd.usable = usable
				for i=1,4 do cd[i]:SetAlpha(usable and 0.45 or 1) end
				for i=5,9 do cd[i]:SetAlpha(usable and 0.25 or 0.85) end
				cd.spark:SetShown(usable)
			end
		end
	end
	function ORI_IndicatorAPI:SetCooldownFormattedText(format, ...)
		self.cdText:SetFormattedText(format, ...)
	end
	function ORI_IndicatorAPI:SetHighlighted(highlight)
		self.hiEdge:SetShown(highlight)
	end
	function ORI_IndicatorAPI:SetActive(active)
		self.iglow:SetShown(active)
	end
	function ORI_IndicatorAPI:SetOuterGlow(shown)
		self.oglow:SetShown(shown)
	end
	local createCooldown do
		local function onUpdate(self, elapsed)
			local ucd, expire, time = self.updateCooldown or 0, self.expire or 0, GetTime()
			if ucd > elapsed and time < expire then
				self.updateCooldown = ucd - elapsed
				return
			end
			self.updateCooldown = self.updateCooldownStep
			local duration = self.duration or 0
			local progress = 1 - (expire - time)/duration
			if progress > 1 or duration == 0 then
				self:Hide()
			else
				progress = progress < 0 and 0 or progress
				local tri, pos, sp, pp, scale = self[9], 1+4*(progress - progress % 0.25), progress % 0.25 >= 0.125, (progress % 0.125) * 8, self.scale
				if self.pos ~= pos then
					for i=1,4 do
						self[i]:SetShown(i >= pos)
						self[4+i]:SetShown(i > pos or (i == pos and not sp))
						if i > pos then
							self[i]:SetSize(24, 24)
							local L, T = i > 2, i == 1 or i == 4
							self[i]:SetTexCoord(L and 0 or 0.5, L and 0.5 or 1, T and 0 or 0.5, T and 0.5 or 1)
							self[4+i]:SetSize(21*scale, 21*scale)
						end
					end
					tri:ClearAllPoints()
					tri:SetPoint((pos % 4 < 2 and "BOTTOM" or "TOP") .. (pos < 3 and "LEFT" or "RIGHT") , self, "CENTER")
					local iH, iV = pos == 2 or pos == 3, pos > 2
					tri:SetTexCoord(iH and 1 or 0, iH and 0 or 1, iV and 1 or 0, iV and 0 or 1)
					self.pos = pos
				end

				local l, r, inv = sp and 21 or (pp * 21), 21 - (sp and pp * 21 or 0), pos == 2 or pos == 4
				l, r = l > 0 and l or 0.00000001, r > 0 and r or 0.00000001
				tri:SetSize((inv and r or l)*scale, (inv and l or r)*scale)

				local chunk, shrunk = self[4+pos], 21 - 21*pp
				chunk:SetSize((inv and 21 or shrunk)*scale, (inv and shrunk or 21)*scale)
				chunk:SetShown(not sp or pp >= 0.9999)

				local p1, p2, e, p1a, p2a = sp and 1 or pp, sp and pp or 0, self[pos]
				if p1 > 0.9 and p2 < 0.1 then
					p1a = 0.9 + (p1 + p2 - 0.9)/2
					p2a = 1-(1.81 - p1a*p1a)^0.5
				else
					p1a, p2a = p1, p2
				end
				if p2 > 0.5 then
				elseif p2 > 0.06 then
					p2 = 0.20 + (p2 - 0.06)*30/44
				elseif p1 > 0.96 then
					p1, p2 = 1, (p2 + p1 - 0.96) * 2
				elseif p1 > 0.56 then
					p1 = p1 + (p1 - 0.56)*0.1
				end
				local p1c, p2c = 24 - 21*p1, 24 - 24*p2
				e:SetSize(inv and p2c or p1c, inv and p1c or p2c)
				if pos == 1 then
					e:SetTexCoord(0.5 + 28/64*p1, 1, 0.5*p2, 0.5)
					self.spark:SetPoint("CENTER", self, "TOP", 22.5 * p1a, -22.5*p2a-1.5)
				elseif pos == 2 then
					e:SetTexCoord(0.5, 1-0.5*p2, 0.5 + 28/64*p1, 1)
					self.spark:SetPoint("CENTER", self, "RIGHT", -22.5*p2a-1.5, -22.5*p1a)
				elseif pos == 3 then
					e:SetTexCoord(0, 0.5 - 28/64*p1, 0.5, 1 - 0.5*p2)
					self.spark:SetPoint("CENTER", self, "BOTTOM", -22.5 * p1a, 1.5+22.5*p2a)
				else
					e:SetTexCoord(0.5*p2, 0.5, 0, 0.5 - 28/64*p1)
					self.spark:SetPoint("CENTER", self, "LEFT", 1.5+22.5*p2a, 22.5*p1a)
				end
				if p2 >= 0.9999 then e:Hide() end
			end
		end
		local function onHide(self)
			local toExpire = GetTime() - (self.expire or 0)
			self.expire, self.pos = nil
			for i=5,9 do self[i]:Hide() end
			if -0.1 < toExpire and toExpire < 0.25 then
				self.flashAG:Play()
			end
			self:Hide()
		end
		local function onShow(self)
			self[9]:Show()
		end
		function createCooldown(parent, size)
			local cd, scale = cc("SetScale", cc("SetAllPoints", CreateFrame("FRAME", nil, parent)), size/48), size * 87/4032
			cc("SetScript", cc("SetScript", cc("SetScript", cd, "OnShow", onShow), "OnHide", onHide), "OnUpdate", onUpdate)
			
			cd.scale, cd.spark = scale, cc("SetSize", cc("SetTexture", cc("SetDrawLayer", cd:CreateTexture(), "OVERLAY", 2), [[Interface\AddOns\OPie\gfx\spark]]), 24, 24)
			local sparkAG = cc("SetIgnoreFramerateThrottle", cc("SetLooping", cd.spark:CreateAnimationGroup(), "REPEAT"), true)
			cc("SetDuration", cc("SetDegrees", sparkAG:CreateAnimation("Rotation"), 90), 1/3)
			sparkAG:Play()
			
			cd.flash = cc("SetPoint", cc("SetBlendMode", cc("SetTexture", parent:CreateTexture(nil, "OVERLAY"), [[Interface\cooldown\star4]]), "ADD"), "CENTER")
			cc("SetAlpha", cc("SetSize", cd.flash, 60*size/64, 60*size/64), 0)
			cd.flashAG = cc("SetIgnoreFramerateThrottle", cd.flash:CreateAnimationGroup(), true)
			cc("SetDuration", cc("SetDegrees", cd.flashAG:CreateAnimation("ROTATION"), -90), 1/2)
			cc("SetDuration", cc("SetChange", cd.flashAG:CreateAnimation("ALPHA"), 0.7), 1/8)
			cc("SetDuration", cc("SetStartDelay", cc("SetChange", cd.flashAG:CreateAnimation("ALPHA"), -0.7), 1/8), 3/8)
			
			cd[1] = cc("SetPoint", cc("SetTexture", cd:CreateTexture(nil, "ARTWORK"), [[Interface\AddOns\OPie\gfx\borderlo]]), "BOTTOMRIGHT", cd, "RIGHT")
			cd[2] = cc("SetPoint", cc("SetTexture", cd:CreateTexture(nil, "ARTWORK"), [[Interface\AddOns\OPie\gfx\borderlo]]), "BOTTOMLEFT", cd, "BOTTOM")
			cd[3] = cc("SetPoint", cc("SetTexture", cd:CreateTexture(nil, "ARTWORK"), [[Interface\AddOns\OPie\gfx\borderlo]]), "TOPLEFT", cd, "LEFT")
			cd[4] = cc("SetPoint", cc("SetTexture", cd:CreateTexture(nil, "ARTWORK"), [[Interface\AddOns\OPie\gfx\borderlo]]), "TOPRIGHT", cd, "TOP")
			for i=1,4 do
				cd[4+i] = cc("SetPoint", cc("SetTexture", cc("SetDrawLayer", parent:CreateTexture(), "ARTWORK", 3), 1,1,1),
					(i % 4 < 2 and "TOP" or "BOTTOM") .. (i < 3 and "RIGHT" or "LEFT"), cd, "CENTER", (i < 3 and 21 or -21)*scale, (i % 4 < 2 and 21 or -21)*scale)
			end
			cd[9] = cc("SetTexture", cc("SetDrawLayer", parent:CreateTexture(), "ARTWORK", 3), [[Interface\AddOns\OPie\gfx\tri]])
			
			return cd
		end
	end
	
	local apimeta = {__index=ORI_IndicatorAPI}
	function ORI_CreateDefaultIndicator(name, parent, size, nested)
		local e = cc("SetSize", CreateFrame("Frame", name, parent), size, size)
		return setmetatable({[0]=e,
			edge = cc("SetAllPoints", cc("SetTexture", e:CreateTexture(nil, "OVERLAY"), [[Interface\AddOns\OPie\gfx\borderlo]])),
			hiEdge = cc("SetAllPoints", cc("SetTexture", cc("SetDrawLayer", e:CreateTexture(), "OVERLAY", 1), [[Interface\AddOns\OPie\gfx\borderhi]])),
			oglow = cc("SetShown", CreateQuadTexture(e, "BACKGROUND", size*2, [[Interface\AddOns\OPie\gfx\oglow]]), false),
			iglow = cc("SetAllPoints", cc("SetAlpha", cc("SetTexture", cc("SetDrawLayer", e:CreateTexture(nil), "ARTWORK", 1), [[Interface\AddOns\OPie\gfx\iglow]]), nested and 0.60 or 1)),
			icon = cc("SetPoint", cc("SetSize", e:CreateTexture(nil, "ARTWORK"), 60*size/64, 60*size/64), "CENTER"),
			veil = cc("SetTexture", cc("SetPoint", cc("SetSize", cc("SetDrawLayer", e:CreateTexture(), "ARTWORK", 2), 60*size/64, 60*size/64), "CENTER"), 0, 0, 0),
			ribbon = cc("SetShown", cc("SetTexture", cc("SetAllPoints", cc("SetDrawLayer", e:CreateTexture(), "ARTWORK", 2)), [[Interface\AddOns\OPie\gfx\ribbon]]), false),
			overIcon = cc("SetPoint", cc("SetDrawLayer", e:CreateTexture(), "ARTWORK", 3), "BOTTOMLEFT", e, "BOTTOMLEFT", 4, 4),
			count = cc("SetPoint", cc("SetJustifyH", e:CreateFontString(nil, "OVERLAY", "NumberFontNormalLarge"), "RIGHT"), "BOTTOMRIGHT", -4, 4),
			key = cc("SetPoint", cc("SetJustifyH", e:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmallGray"), "RIGHT"), "TOPRIGHT", -1, -4),
			cdText = cc("SetPoint", e:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge"), "CENTER"),
			cd = createCooldown(e, size),
		}, apimeta)
	end
end

local function SetAngle(self, angle, radius)
	self:SetPoint("CENTER", radius*cos(90+angle), radius*cos(angle))
end
local function SetScaleSmoothed(self, scale, speed)
	local old, limit = self:GetScale(), speed/GetFramerate();
	self:SetScale(old + min(limit, max(-limit, scale-old)));
end
local function CalculateRingRadius(n, fLength, aLength, min, baseAngle)
	if n < 2 then return min end
	local radius, mLength, astep = max(min, (fLength + aLength * (n-1))/6.2831853071796), (fLength+aLength)/2, 360 / n
	repeat
		local ox, oy, clear, angle, i = radius*cos(baseAngle), radius*sin(baseAngle), true, baseAngle + astep, 1
		while clear and i <= n do
			local nx, ny, sideLength = radius*cos(angle), radius*sin(angle), (i == 1 or i == n) and mLength or aLength
			if abs(ox - nx) < sideLength and abs(oy - ny) < sideLength then
				radius, clear = radius + 5
			end
			ox, oy, angle, i = nx, ny, angle + astep, i + 1
		end
	until clear
	return radius
end

local ORI_Slices = setmetatable({}, {__index=function(t, k)
	local v = ORI_CreateIndicator(nil, ORI_Frame, 48)
	t[k] = v
	return v
end})
local GhostIndication = {} do
	local spareGroups, spareSlices, currentGroups, activeGroup = {}, {}, {};
	local function freeGroup(g)
		g:Hide()
		for i=2,g.count or 0 do
			g[i]:SetShown(false)
			spareSlices[g[i]], g[i] = g[i]
		end
		spareGroups[g], g.incident, g.count = g
	end
	local function createGroup()
		return cc("SetScale", cc("SetSize", CreateFrame("Frame", nil, ORI_Frame), 1, 1), 0.80)
	end
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
		local ret, config = currentGroups[index] or next(spareGroups) or createGroup(), ORI_ConfigCache;
		currentGroups[index], spareGroups[ret] = ret;
		if not ret:IsShown() then ret:SetScript("OnUpdate", AnimateShow); ret:Show(); end
		if activeGroup ~= ret then GhostIndication:Deactivate(); end
		if ret.incident ~= incidentAngle or ret.count ~= count then
			local radius, angleStep = CalculateRingRadius(count, 48*mainScale, 48*0.80, 30, incidentAngle-180)/0.80, 360/count;
			local angle = 90 + incidentAngle + angleStep;
			for i=2,count do
				local cell = ret[i] or next(spareSlices) or ORI_CreateIndicator(nil, ret, 48, true)
				cell:SetParent(ret); SetAngle(cell, angle, radius); cell:SetShown(true);
				ret[i], angle, spareSlices[cell] = cell, angle + angleStep;
			end
			ret.incident, ret.count = incidentAngle, count;
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
			freeGroup(v)
			currentGroups[k] = nil
		end
		activeGroup = nil
	end
	function GhostIndication:Wipe()
		GhostIndication:Reset()
		wipe(spareSlices)
	end
end

local lhc, lhcPal do
	local ht = [[dÈÿdÈÿdÈÿÿ&dÈÿdÈÿÿÃMğæBdÈÿˆÿMÿğMLWÿMµÿLİÿºæºLyÿLÿÿ¥LÿMÿÃØØØÿóÏÇLÿèLÿ°ÿ&ºŞæÿ€ßÂ­ÿÿLóæºæ4)ÊD.BY _Ñk}çüHxÆ_qî—¦d™:õ¦ËC¾´}ùÎE›®ÿÖd–Oâ!Ö4"()A§(#¾z½d{æEî \zOæÑAş•£éCã«Uè_æˆ¥ìH:ârßŸÉùUl{ÎŸ	td‰áÇ#Ür3ègİ<Ÿ >O­wşÃêkÇÙéÔ#¿ï|A'÷Å+ü¾ì-!Üäÿë%}ÿÃ¢r0îtw')#µ­Ìr>–O‚$<˜&ÖÍ>©Edâé,ÿÏëôöÈ#>ƒÉÏüò“Ôÿtby]‹ùşw£ìIşûÿçÓçø wÑKëv¾wÆl›“ù¡ìAD¯éñ¦.'¢Iı8c¦GúşÿŸÿr0¿²dîGôûó?ßGKşD'Oäèı §ĞËèdÜ}=i_ÒˆıÿOîÑß GæŸÆGùİõ¢_y–}D“³éV²^DiÿÑ,+8ÓùËˆJÒD2/K‘Tÿtÿ79"üGé<øC“úI‡ÿ=zš1.C"‚%lcåùq ÕN·2rsö.~şô%,»“VPë8JÙ-üŸûœ¶}_şõúg:ÿÿ¡ÿ:H‡d§¡'À{>—şïBĞæ~d-ÿĞ’%"Ğw½ì!»Lƒ'¿¦K:èÂ,ŒKı¾‚/ûÜW'Òn ?şI½·÷?×ç%ÿº92K¾û¹$üÏôĞˆct1h §ĞOÍˆJ„Ş‡³˜ÇEß|Hƒ»Ÿ)^Pv3äYí*1rÒ’;ÿ^rÙ¤Ÿ,ùü‡<äü¢ŸÑ~=)9"Ş…“JúE? ÿì‡eäyÈw±FQúıÓÿâèı5ù/©¾?OÒ„#ÿ 	Içö‡ÓD8‘&u“è[(ïı’Ôe$të&wQôÙ%4,×Ğt"ë#ßgÉägğ³“úûÈŠÇé;¢—Ç8#”çî:Ó_±äN¢‚.„G×òœ;”ˆMó±úMÿ„Oè,²iÇî?Ùô].ØI?#9r8äY*ÍÇ OÈ¿ñGÓ-hÿÉV¬ò"Ø—»óu{a(ß4N y>ò`ÿB~—=ß9äEè#ê¥Ç »O­,!ˆ“g!"”¬ÿ:%#üë>$NB~DûĞœ1èqÿBL›ş(CıÎyäa“	!İÈ¯õ‰Â9Šÿõ­$wÿó“î¹F}ø'şt’ç8|îE±É[ÈŒ|ˆ™–Q‹v3ô}3Ò„'ÙF?òuİå¿ôŠ>„''L¿ó®¯Ã$ë8‘îO¢$:NÏüó1±şä¡Ä‰æÿ¤÷ûëòaŸçõòF__«‡õßa-ÿ¤ üôÿéú>Œ=ßÿïtEùıİ$Ğõ¯Ñòì‰İ4“é8GşC¹ë·ñô~Uvê»}gwÒÉÿ_ù÷WŸøš>OåA,tJŸ2"Rÿ¡2É×DÇç #Î‚qÏ¯Îz~3üĞ‹ãôúIş.K.úèò&w¢gôgòüXµı	C±ÃŸl B'ş¿ÿ$z=	bñ'ı‹ïóÍ$ùüU:eõ¯y>âE÷ûsÑ$÷ÿrÑ/NßIÎ¶,”8ûúD'óvcSŸéù&ó°öI?OşÏdHô=è%#«cç_Èïır ù#c¥Ôúãÿ»H>â¼Ÿt÷½ AÎ÷|ï#ÿÇÿaé3ÿuİ¢$Oâ³(éØÍ½ £Äç{¸“ı?ëë&K_zí[ó)úd‰&_'Ğõş6	;ì·¡ù	šéÿŞO¥ß u~³ëùÓ÷ÌñšúNrßò&Î'ú0‹}ÇCÜ­ä ÿŞß°ù“÷"Ÿ:>ï¹ÒGØéÆ.qÖìç=“$ŒÿÓÿ‘|™ĞI¹\'ò‹¤wŸès¿ÿü„$¦‰FQ8_İ?ÙŸ#ôıŠÈ“õ[OıŒüøÇña%D-’åÎÁı"Éÿı.\Pâ}9z1O¬ÿ’÷9”Jt‘‹‹ÿOı' 9Iÿö1gGÏ¿ïCçZß‘Èç­nKšÙ&%$E’óÊOa”“ée8Ëî9$?'Ñ£¿ï#tı"P¶ë.zú~+¾#„I"…Ô÷z.ˆ£ä yÖ½uëÏ’9ËÿÈr3çºŸÿ›{&	şOògĞ™},Z>O²(\PÄ%è!	‡% s¢…¥dúqô-s"^´¥Äû«T ä cKè$]ÃÎ+äŸs×ëä­ÿçKĞ”-‡›âGK©¯âuº¨ù†)Y/şn@¡õé'İØ²qI7Ÿ±?·©Ø›=d2N¾u¿èÉ‡œ‹ [¿%¹h#ìxÇçGÑ?ï_“ã4Äë 'İùõñ?ô¬ˆD’L¼“&}hœcù&Ÿ“Bi+ C¾ù#ù'èŠ,‡dİô¥g;İ„ÛéJÆYä_İ?ıh9&w!ŒÿĞ‰İ?ÕÙ"~Œ8ûÎ¹×d‰ò,‡ùÿgÊ‡J)rhˆbëôÆ?ÍC‰Tò y?#“ÿŠ~·}‡"+I?ìAÿÿ¯ÿ	ÖÿŸ¹ù'4¢¤^û¾ù|ñŠÿ_¹‡8ú,‹å„JdÅÅwÓoş$û>tëùï­ïrØ†ìb‘Ë|Ÿ<ÇıEª–KÿLV¹ÿq8_ÿÿ³òwìHıˆşÈ”­ßšPï¥?Ò—E×rœ!îïüèŒIóÜ‹yßÏÿÿ&÷òE‹oİ„]ôWGM;øâEÉ'ÎvK÷ ;şò1y)­._éåÉ;9•¼‰ú“çI'³üˆúKI\ƒ’Ç8É"FäûˆÅ½ï³ñÂôuı+KOœ‡brƒ§ñbÈ´®Ÿ8;ÖF]aÏIâÈt„ò/'ÿ÷8é ­ˆò}(#’¸İÇÿ—;RœÜˆ¼Ÿ ú"I%‰#Ù¯ûy:³üŸÃ#ô}r@ÏĞ·|ìşî£ñC6ˆ¤òcş·I”yÎE°‡ C¿?ÿkœf„×'uw¢i#˜O"¿ Y%_½$ûòóÓÿü’£üœˆgèŠ.Iş†8ä û‘ëBw<‰q(›%4’ÓÔ zÿÿ­‡BŞ‚‹”ĞwÌŸ;Î‚$è8qÉ‘Œ˜ï½ÜùÉÏĞø|©û}gÿÒD#ÿYÎÄ¡ÄeHÄ2#0÷~‹ûÿ_Ú$>^„BßÿÆ¤YñD¢?r^•°‹/_c­Û_GÉı'üc? îvÙ÷­Ó8'ÉvGò#É/§ñüİÿ×ò<¤D±dyş´>HF×2|‰_ØF.–ŸJ ”²EËì³şÉQk Êò!²ö%¹óÍCÿ³ëCÒÄ-1[³úé~¢ó½=&I!dµ¢”-Ö¢Èt:¿Oÿ÷,‘ DIûáÏOÿø¡î?õ“è#ÎvoóÿØÿ³äDˆM1Ô~hD1ŸbçºhGí9/A#˜—ÿ{1<9Ÿ×¶~+C„"›:{ÿ, ±>vòGÈOËòu~ô Œ#’•ëˆrNÂ}Ü<lÃ¾Î%_Ï÷š$BKçù	ƒ+’õ¤òIõòKrèsı¤‹@Æúo#Ëì)AD.ˆ¹ç¿şî¼èú°Ÿ»æEıiúÎ³Ÿÿ•BHÄ¡d\’s½gNw#Î!³½7 ùĞFQú\Eüô"ÜôáyyO¥"ÉOœ‰úÓ$alšÎDl rbä}èùÇ~/:ø¢_9Ü}„Šöh±†>ôšVÇ~Dhâ1o%'ĞÂ‰'Ö‡Øì ŒX¶}qÑcşD%±ÿ²Kv˜ôiú™|‰¼úw’ OåG“ä"1ü°ë:>‰i•ØÏ¬Œ rOöÿûD?ÿ¬æÏïŒ»§Ä•Ïä›,äd~s¡.û#§ş¨8ş£_!ÿ="¶~_JOOõür8ïü—²#ë?ÿùòÓû­×£&M¦„Zÿ„|Œ êìÍ1_ÓõõÿŞÄ¥Ñ'â—}ÿk9é}lGÈtÍÑÏä¹É:!Ÿñßü¿Š^ÒB	(‘?\uH†$çAüÄrÖš ëk”Y;-'gƒÿ,Ö:*MıË CÑõ.Âè’-$û?9ˆ9Îw<çgÿó¹ú'kä–Ñ÷|ï [’´}Ë"ŸÉ	½#¬ˆœô [G“!óô!vY(çï;Üí³KKĞÄ}i!îD|úC$‚|ŸMSüÿ„gø³Ùä@|äQ18ºÿ¸ÿ—âÄ<òOÏú]Jhï§ÿ#ÒäÿBöW­İw-qF?T°²>O­2 "´|‰ûD®Otqó°ègÈ½¤ÿ "sR[ÿ¿Ï°ˆsØëOüHƒÉ¸Jè†âIkœ×';çŠ>CÛñJuÕ2úÒÄ_ yÑ±o&H²$çq›?çZO‘Ö¢Ğ´D‰KBEÉ>³±i’È¸¿ñÅœ‰3ç=÷oÿJïtçßÂR†!ÖqÑÆoŒ9?5Şé™ÿôEÉGÜ³¹òC‰÷}Ó¡	ûÑzşD“ ‹Ïıxúîˆåô<´•Å$KÑøĞŸ:>ŒléY?ı3Ğ¹ùı	û>E¯ìJÿŞ'™	Ršùş¦Œ‰ÿò9ñZÉ¿ëçúğu­çÉsĞ„=á>„2+wŞñZ\sı‘ rå2gì¶RÒc"¢ÿwÜt“ñûÿ¤–!ş¾n:ŒÉÒtı³âw?îGe8[ò'øßÈÄ¦´b	ö>÷ÏÖ{ECÎ´9ë"$|üäJX†&Sgä÷ÅË"Í,!{çş°î8JH·ñ#“÷E“¿/¤ëe>ÿz0¡ŠPB=lûâ—¿ë DYó¤‡~pÆ'ìŠt;ûDäD¥ÿ<ƒ ŸÚĞ²è—Ùó¡y%\‡Óèœ®|Uß úÉôüîÁçGºG\’ˆä‘$Q6/ÿæ<I}	<°D®ˆ’X³ ÿIÎÂH‘'Ğ¶.„šHã£çb:ƒ£¤Yó3ı4 LÙ',úÿÏ/¥‡B†şªk‚)c÷é zĞÊ¬Ÿ{t¡A>äKîŒ÷üì qOÚ;tPÏˆ:?Cßïb~ı¥Ä<Y¹hÌrïœ„ ÊÈºıo«¨ò!“!D!îN&w‘ aÓ²i<Ñ÷§èDVŒ‰ÏMbˆÍ“?Îä±8âÒtü‘ÿûó ˆcCÖ5"Ã¤äGÙCéşãÇ_Må¿¸rV´UîJ‚#÷ $È’~LBÿÏDE.tº,•Îä£ë&'ÉäŸ "ùIç9öyÿùåö9	Ğ· ä?Ñ‰M	r~‚8:şÇ,‘úÇÉ1gâ•¸‡?ĞµØìÿÜ½>3ó§û‰Ñå°ğGØ¶&sO[û8äØ!³¡+ ÉîÈœøaÙò§ŞF!v'İÿ“éù>D8ñ?çô^®ÁÓ÷Ç!Dı,8ÑõÇó9É“ñ!ÖB8ŸüVD÷è"Od=^~ò~:~_\%@9”èböu=PuÈıbHD}–ı·~§ùîpúÑ_hBúŞ_;¿_ÄŸk"í?òùÒç³öZÈwè’	÷ÿ8ËëÜÍÏı\_·ÎšhûŸö"Y}¾VyÍÈé1ÈuœHşÈŠ]u‘gwÖy±šOUåi[å*CuŸäšóÉd ›ô-/û¬D"†’	Å¦_ úï²[$KâÏº¨OÎBç‘İÿ¹8ÚØÿ±9Òïı)%)}éaã$Sç[ÿ¹èzJ’dû#ñ#ö&=ºFe‘s‘÷ìùFøF>Cî,ùÜ‡£ÿY"¸¥ü£¢ŠŸ:ÿs‘/“]ÑòJq:Ù7}$y:÷[ë.Œäw²? —Q—½wÏ)ı‡%\uÈÿ_ær}‘9¹ïAåÓ³ï…ş™ûq Çßò-Ä’fF-Nr=1Atÿı<ÿAÿe­îùò|és"ÃáE¢ô½ùLüŸ¯â‡$„bdùÒ8É>uÄ‹<˜çÉßŠÑ$Kk{’Ÿ§ïAĞÇÿòù:C‘súØÏ±Ì8wÖÉ£ìúGœî[ñ—,N¾”úÿ2õGş¶JgwÉ…ş‰]rovfÏœÿaÿôLçßF?K?µÅñ8GÜt·Gşzg\Ïù”˜†d‰'Ñô±u‰>‡%ì—ÈG-ñD]ù’¼£4“èLnziË@a%Táî üX‹­bX³“äM‡’ù	ò t¾Cı‡óŒÿGâÄé%Ÿ»´dHÛŒ?ÿÿÏÌ«İx‘‹B?¥»çr/ô‘q8J”¿ÿ"~¿Å?YÙ•»óÁÈ™%o‹ „±#%7œ”˜â.ÄCùÓ¬¥˜%·É“õ+#¾úÈsúİd¸ä8“Ïÿ¸õ'È•Ïç:ÿü‘gírUiïæGÌ‰‹	Ù[>† Œê?xìYJfˆ<ã¨¯ø¡çw~é“ØCıNÓô8 9);²6_Èù|ˆwÏv3ÿ!â„½'‰ô9ÒºÖ²#1eI/×_ 'Ø¿üèZPGÓó#ÿ÷ÅÄâãŞ‹ Ã×ô=2\P†?ì<Ü¯ä:*‰íksÏdE‹#E»‡ú*ırÿ¿¡gKE’”úOe»çu}??ÖyÉä;#­s8aÑÿ±n£	7“ï}*²8ïzHä ‡E‡,ôgŞÄ-ŸY¥åÿ&¥DU!¸óÿ:&†=ùKÑ$¥„%H²} VùçÿÏó¡ÿùã?ıÿJÎÂeÄ#ªÏ»çÿÉòUÈÑÒD&äÒ$D¿ç'ßrcÃÈŸqöæ}ß?ç$ôıjä¡o géóİI>E)’ıy" „ ü~òUÖÖ²:lù‡±(»¾˜Å Š&º,rPxHÿ·~t¡ˆ<êOüÿ8ï×óİŸ&â#è£|ÊggÉs¢ìüÉ¸çr·ŸIÿ¥”%^ìò;ô²Rık7Jq!÷wÑø’L‘˜»ï—×"eß(BH}ÿ_ÑôEÌú´H„"g+#èGÈƒ²õı>‡’N Ğó¹ÖÚ)Ğ’c"EŸÿú¶Eç¹&Ÿı›bVI}Œú”\Ÿs0÷!Ìr_òHîB~ë¸ï”¥C —©Ü’}dz>œú’"“úiEÿ$dI£èwÓôD?Ø‚PÏş™Æd!Î•K>zÍÌCˆï¸÷ûóÕ$«œ”²«8×Ùş§è¡îÄ‘;B7OÒC°?ôÇôš‹­ÿüzÉ	ùt¼÷8û·ó¢ÿı-$‘„ûÓRÿ&?õ¯çdoáyÿuÉîúÈº|œ%ÜDhBÈŒSé{·ù?/‘– ">yÿìüïíû¯»øšd¸¦ı@6‘ˆÒÿ%ÿÿ’k‰ş™1±ŒßGäw§$ÂùI‰ÿç‚;ï8‰É}šŞä“©šùÉ?\¹#ä£¿_¤îÿĞOÓÿA}¦\bîâ%5f"t}, ‰w×e¡ùĞˆ?Óõ£Ú8:äŸÛîùÏ£ë]tOÇy0ôıtXöOgİw$‹wÙR2H ;	G=q>‚1q¯4ù#	mwÿ) —şäıÒäìúœD]ıíŒFkô>Rw×T¹s‘Âh’ÿé5ßñµ"ìÙÛGÿ¢}h¤SóÚvYÉdZVÅ38êSdF¿ÿ×†=ÕyÈ²bg¡>Æ}ÌA:¯ç[Üç!‰zò/öw×óïK/˜£ëŠÿ÷GóA>õ,'Q›3zoô?è'í4¿çBGmŒ×Bi— J*ÿı1;Bî"X¹~q%?÷|ÿµD/D÷ÎOÑÿ­?c‰½g>˜·ç;ªt¤äüR·&: :XOÿ6wÖ²~GrÒâ$ˆz#úÑç'í÷sî%iÿ±ôCr&,säô8„ aÖ¦O¿şˆÇîuNFLäßÿ$¬›Ç~œÏõÍh|–¶%ËúzÉidê£"&õŸ$ ^E£(;œxœ‹r/ûı„sâÏñ8=3ò„²şäd:nMKÏÿÊÈ'ìê¡?I?sò+”—ı|’8J]ü­dŠb„ÆÇbEË_tşÇ;qÖD}6Øv_JHøÿ±í ñû%ÿñ•~•§äAYæD"oEØôãÿJÑÿØç¯Şå¦?DnMè ÿÎ³¥ÕÿÈè“?ÿ1×;GÖ‡‘Rç9Ï/ı‹¿Oı$GĞB¤úù±‡yâ¸ÿäùÿü¡÷8I–‰…êşÿ’ş’Iw;?eıŸK/³î<O9N¿ÿ­ÑYĞIR5KÑõ ‹!ÈïzşDIé gr%İ›ÿšÈûr|çgÿO¥?Et¹¯Ïî#ˆïÙ'qO‘zæó¡	"Dş± YİŸŸ3º÷Î‰9êóâ['è¿²5I?b}kÁ.}|û:Ø–Œ™İ2)ªÒ¿ın{œI}ŸAœ’yÎƒ‘î"]‚|„"ã_°Ÿd¾~ş'c$çıÄ "H„EÄ_ÜI_ÿ#y0Ÿ¡•ÿÿš>´'éşB9èéñü?ïıÿ3î—âyü‡Z>ˆØŸ üØ{0ÿ±.GŸ¿BÒ“¡g[ş‡'É BÿH¹÷£{-tyØvYn}ĞËÅ‡b¹ ŸYyçM]:ÿ"dOßÿ ›ìş”Ît}Èı§>½óü;WèCşI!Ğ²FKIĞC‘A…‘„_ÿö?ó 9ÓšÊˆ÷äôìæ(ïüÿ9İ?§çŒd”=GÙôŸÿr>“»ëK‰÷,œ[>„Mß$×S­D—š¹[>ì°çú1R%ˆı—Ò_ ú ”c$#ÙûÏÌÎ÷-ñD]¡ç_ä“½ñ{5÷ÉGÖ‡|Ÿ BHM»s–g„Ò2AÉ´-ñúßÿÅo!×D’öúo³õûÈ¿ş_\Ov'>ÉV|ÿú_»ò §ãgš¿ı?aöˆı„%uËëf¾˜®Î8Ê1ÛçùØãı‡ûŸ‘úó‘.Šî¿¡Ôrz~®Yß¨ıÑ ÿşuĞ‘úIÿÜ‰cß³ëÉ>—¤–L–ãÍìÏÈœ“ò²?/ıgü\ÏıÏ¡Èƒ’ö“ˆÏÊ§ 9ÿÇèŸåÿ.‰&GœÿúY$¢Ÿ;ŞO­t“E’?Båı¤ˆû³ô‘[r|¢tèŸûtEYèúü=çY÷øÇK:Qõ'Ùû-?üvN±„Ø¹œ û§?óÿ"c¯ì?ßı@ç>V„%'úÎï¥ïZPOË<ú>y>Ä8yÒ†8’úYÿ¢Sÿãó­)û‰÷UïûˆE¯îr~Ï°ŸüØHÏÿJ&>DFO³îBÿÿÌé I?ËÿZş…¯îf3ùf[ÒhK(D•ZœÿDé'ÎŸÿì;,E‘‹!>Ïıo ÿÎB,çGÓÔÿëÿëjËÉ½‡#äşI„ÑÄ ©>“ÓçNf¥šP„3ìÛÉşy>‰0‹GÏò2Çúÿ‹b&ë&¿?–‡°‘ÿ²Qd¾Ê.¬ûwÒ?ÖG¢_'îs’Ÿ8’?%¢2ÿ4~H;‘ùÿ§Ùÿ®_CÎÏÇ_’só(]üUÉ{>w=„gVs£ëGş‹ç aå·şŸYĞÏÉ:>ƒÉt“²tIÄ#¾óÈÿfÈæMo?Ésÿì ’ßò~?9	Å¹t$QõıÏçów¦9b4Ïüÿ%Xˆ:>LºÑ—ÏúŸòYş…ı.'È„"ŒIş’=ÏÈ‡|~"÷} ¹x»‹?ÊZ¤b¿jœy?–ì×â³‹:(ÿù ıƒı™ûñlsÖG}ßŠoC ä YöñIîÿ¡çÛÈ‰ºÓ±…÷øfxzÿwßöIóbÿÿ£ÿJsıÍ'Òt]ïa>Ç}3ûÿ÷Iëû¸×óüşÛdÿÖœÿäúW’äf>D¿õwß/§ÿzÑ%“çuÅ?tjşÑô(I"š¤ÿYş—Ûë›#ù¡‘ú$GÒ?£ˆ›¹Œ«¿$ÿîÄ¦ŸÿĞHÿ)?édcè‘ÎÈı(:Îôüç"$ÄgÁ?WEÇÿşo™ÿ?ş¡í“ô¢¿’(8üQ.3ş;ş˜Ê¨$™ÿüŸ_ş‚ÿgÑÿ­?ú/ÓèçÓ}¹ÒüüÿÿóşÇ´ÿçóû¦ã£ñ8üïó¡ß»ñúö‘?÷ÿÿ<ô&?Z/ùÏÿŸşuÚŸ;>ÿïëÿÿsÿöı7ÿ¯ÿ€4:Œ›šç”™şšPN.Ÿ¨‹İ“çƒÂ…bè)•‘[’F‹&ı>Ö=p‰Ÿ?€}“¦š d‡ƒ˜œ8”ü˜JŠ&œÎ<„‚„)—}€°’Ü‹¥ı°„—6€#\‹3Ìš,€[Ÿ¶¥•G<ç‘€z.”Š‡Â—6–7Œ±šƒ†KŠ¤€°”m›à“à–‹7“sš,ƒWfè€Á•ºšŠ‡2E‘º‚Å‰ŠãˆÎ†Äy“¦.„š©˜°1=ÎŒ›˜š“ŒØ‡ğ‹šŠ›‡‡^›¹•º-/…Ÿ^Ï—gŒÂ›“‚â‡’q˜ƒ)˜?ÿ‚â•®Dé‹»-–·=Ÿ`‹—‚6m˜’FÉ„©—g‹Ç|œ¬‘ßˆá‡2ä‡ğ‚¯›à<„”=ŒÆq–·°‘†Œ•â5™€4Ÿš‡ ™?€“–Ü–‹˜ıœ–†ü…b‘€†ğØ›à¤’Ü‚B“]…·<çq†Ú›à›t‚„¬‰+œ–‰ä’·”W–”›†€)è”<„Ö&˜œƒŸ¡œş†K„JšIœ7–‹Š¤&,œ7%$”œ–‚¯…Ù›ŸëˆáŒ[—÷‰§ˆáƒ±“ç‹™?œòœşˆ÷c—6—¢“¦‚6Šã„ã‡j”š•6†Œ<çŸx™›à>Ö•È‡^ˆÕŠµ>µ”¸È—¸”İ˜9ˆ¢˜‚‘ºP—÷˜6hˆÕˆ¢‚ŸÎ“s™D%”›>µ™y²™ÖÆ”›ˆ÷™˜^‹3b(›ö)ç&§™‘’ÜŸ‰”¸<çšÆˆK7Œ±™€ƒócœ7›¹’œ\<„’^™?”ü„J‚œò’·šr™°—Îœ75’·”0™r—%œ\'	™™k€}ŠYr®€Á†3Šã†K’«…@Š&—g‘Ğœ\”¬˜ñ˜ê‘[€Ÿ„×?ÿ‚›H•âˆK„o$‹=)ÔŒÂœr‹,y‚›Ÿ)„Jè–›¹‹ @ä‚ó‘ŒÆ“ ş˜È—–V˜Ş—g†Ú‘€	äl‡&$‡œ˜š‘¤Æ=Œ‰Ì‰y'’qŠe=Œ“]…•›‡AŠµ“ …4›’qÒŒ+‚X˜ŒM€Û62`èâ‹î—%ƒÂ?ÿ’†¢&ï‹ œ½5‡Ÿ†tˆ¢—}‹Ç?ZœÕ=)šÔ›Y‚u™?Ò[h8ˆ‘õ‡jŒ™Ù‹ú–ŸÎz…‰™€ƒó•ÿ›œ–‘Œ—¸Ğœ7™€ºŸÎ—[ë…Èˆ&›¦(ôáŠfg™z‘€“š÷—¢œ7†cºœƒ‚Š<è‰1.‚ÑŒØƒÂ“¦™˜ì™°Ÿ’Ÿˆté°èŠ‡–J•ÿX˜J=‰ÀœJšÍ0‰‹»P‰c—}óœæ›e’•GÖ\†'Õ‹’8‹¥IÑ˜=k%”?ZÕš°‘+€€E‘™˜˜ñŸÎ•]‰äG€Şè“¦†'b§‰Ö“]`”0‡€–ã›“›¦“…«€ûŒÂš,›ö……Vš=Ÿ‘[•*–‹‰+€[>µi …‘CŸ”›<éM(Ÿl?ÿ˜Š˜Ÿ.jd‹kš=‡‘˜[C°aé“ :PŒzŸR’·—[‚Ñ„€ŞŸ¶1–xÍèœÎœÕŒ‚6„o’j™?5g=Æ›¹<„,”Ÿ>Rœ™™Ù”ä>1=Îè†3‡‘‹3…@T‹›‡“ç©“ç<çé‚X–„š°'šPú=Œ•‰ƒÂƒWŸó°“ŠËĞŠ¤‚BŸ¶5„Ë§m+h’Ü‡™Ù“„ã€‡2’·“ =Î„Joˆ›–V˜‚èŸ¡”WX‚£‹3“ §šrŒg‡ğIŸ`=Î€Ÿ¶Ÿ¨ŸY‹İ•‰š‹™’c¸Fm?ÿœÕ™?/ƒmÉŸŠµŒœ–mŸl%–&‹Dé©›ÏŸ?–g˜°™?”m‰ğ…s Š‡ÖŠô›2‘ĞŠ–7‡Ø>µ‘Ğd‘ —}7°œæ”ü€=k‹k™®ƒ ›¹™¿Š˜—}Œ›Ÿ€#.Ÿ–&–‹ˆ&–·œş¬‘¤‚•s™?ˆŠ™%ŸÇ‹Ç‘•6‚u<çƒm™¿—ÎUî•ÿ„ãšP€l“/—¢‘¤y‚€	œ¬„Ÿ‰‡ØŒ›‚ ˆáˆtß%é—[?9²‘[F’«—}Í˜È‰ğ˜Ş€#^€°…Èšfšî”mâä’\…ş°Šµèl–gŠH&`•ÛŒz³\Ÿ`8“š›z°ŒT‘õƒƒŒ[è§•]š°†Œ°¸‘‹Çë™ÙŸ‰…Ù™Ù“š=–gŠH„{(ë%(‡Œ7„ã‹D‰cBr‡€…s›Ï›ey°Œît‡8•‰„©–°—„–°™ÙÆ€…Ùó²’Ÿ–Ÿ.–<„˜[>µš—%‘…•§ˆ&ƒ5%Äq™?†Ä’·‡‹¥=ŸÇ•GŠô=)’Ÿ‘+•s†W…·°@“‰Àt‰ğœÕ€šf(Š’“Bˆ¢…s<„€l˜9:¤‚X–‹ŒsŠ¤†üIyó™‘–&’›r‰ğ”F•*šP€[ƒ›¹‰+ƒŒÂ‹»=k—ƒK¬ŸÎUq›¦&©ìy„{Ÿ¯…s$ó•‰‚¯–·°†c‘[èœ½—ë…V=g…ƒm›e‘Ğ…‡jƒ)<ç‚’”W ˜q›2‚óì†‡H–‹”ƒ.$”˜ñ‹™÷ì‘™˜‡ğˆt˜•®—Î‚i”¸‹™‚ Ÿx%•—ßœœ0šŠ•sè…·“EŠË…È‹3„¿ ‰)ÇPB<„ˆU„“E‹ú™Ù‡ğ“ n‰:™˜ÏŠHŠ‡˜°•ÛˆtŠe–‹œ\‹)š,–Tî)‰…•‡2˜9œœ˜[”0ƒK’1‹D:‚Ñƒ§=h:€“‹Z’ÜŠ&‘º=Œ‚i€Í“ Ÿx’q“Ù€°Ò)è˜[ƒÂ],Š{°’?'š°š°€û‰Ì–œ7‹D˜ÁZ‡ğœò°\Ò`›2?ó˜[ë›e•‰” §ƒÂ„‘ˆŸlœ7?ÿ•GÆ•Ô‡ß“ Œ”‚¯)ŸR%‰™ş‡ÂšÛ“ ˜q‹’‡H€lƒó?ÿ:‘Ğ“]cT˜š›à–‹‰ğ˜‹8è‹…«šÛ–V‹Ç˜J”¸€•È$‰ğ—6\‘º‘Ğƒ5™‰´“çƒó¸a€4’Ü”m“‰ù‡,è“¦‡>1•ÿ•]•œŸÇm5	œş…@ó•s‰c‹›2°›&^–ã—6<„›Ï—%?ÿ‰Øy‘J‘[€Ÿ›Ï•‰ˆ\ŸÎ ŸúJ˜J‰Aˆ\”ƒ€4”0²ŠËˆh‘[:‘Œ>Ru;€†3ƒ±‰A–ô“‰˜JŒØˆŠJ%Ö–ãÌ‰ğ”Š˜‚œ¬˜ıŒŸl%â7[˜JšP€E‰Òlšî“›•‰€Eƒ5Ÿ¶TŸx˜q€Í›Y˜ıA¸oŸ¯Æ‚Hp‹•ÿnc<„‘7'•®ŒØšç‘Ğ™dŒÂ'>sì<„F•GqÕá”ä†³ŒØˆt‰ŠH‘¤†Ä†t•s€Ÿ‰™®(‹šîŸ?Pä„Ë:<„€Íè 0Œú 4ìßŒ+ŸK€„>’Fß>1Ò‰´Œî„ãóI†–ã’\’?ƒÂ‚i‰W…‰º‹¥‰À‹„ã€ûMT›{–ãŸÎ†ğ‘‡Hc™¿x‚â	—¢™˜‘“s?ÿŠ&È‰A’”¸’·“s‹‡°—}z†cœ7ƒ5…‘J”¸Šôë—¸…Ùâ—6Œ7”¬ZD‡ˆ÷Ÿx0‡”¸‘…ş•*†Ú‚ó‘[%˜2Q€—6•‹ó›{Œ›œ½†Ú…Š&”ü”0”ä“°›¹‚ ’Fœş”õ€ïƒç”¸$‘œ7q™‰%l™Ëˆ÷„J’Ÿ†Œš‹Z˜ƒm–ô™Ò“s–7Ÿ‘7ˆt‰WŠ&÷>R<„%š°—}’·œ\ˆtœæˆá>1A‘Ğ’q…AŠµŒ[tä‘‡€Ÿ‰è‚óš›\a“š‰+‘Jšršf˜‰+9Ì‘[Ÿ.†³q^]›Ï‚B†³šŠ‹ú—Î—}†€‡^š¢›B‰ÀŸÇ…P—Ò‡j(‡Hˆ¢’*“]„©›ö)—¸ß§’Ü“ Ÿ.–V$‹™€’‡=Ì…@šIŸ‘Ğ›¹ˆÕ˜9‹¥€E‰A€E‹Z@ô\•‰%‚“ŸKš©Ÿ‡€@ë›à…Ù–ô Ÿš›¹ù•‰šîˆ¢”›€û”ƒ<ç>R‰c4è‰A(‡‰i%yŒØ—6ƒWŸ•‰…@ŸŒ7†Kš”W‚óˆˆ¢‹kŸú‡„{—gŸ‚¯9–˜…•€Ş†D–=ŸÈ‡j—¢™®˜ÈŸÎ†¢=”ŠHé‹ˆK„¿–‹‰=ŒŸ‰=)èŸ`—¸†¢5–&œş$›‡HšP˜Èƒm>1‰“¦îŸÎşŸó›“š”¬—}—¢“Ù‚Ñ9$Ğ”Š€“çŸlg”¸‰Øœ&›Fc›Yˆ\“¦†Ú–ôˆh‚ ‰yœ0‘¬<„—ß”F-h˜šŒ%î„×šr‘ŒN+”š—[z=ïŒî<ç‡ğ(\‡™˜ƒ—ßƒ“sˆÇœ„‘Y˜Á“œ¬–x—6>s™º„JA‘J5oW°y‘¤‰?1›ƒWƒÂ)Æ„(‹,˜(Ÿú>÷œJ“¦[œˆ…Ùºœ„ãÌ<„.œÕ˜(‡ğ…4“¦’˜(“¦—÷’c„JÖƒ ëA‚B–gc‚B†W‰‰–CŒgß‘Ğ%„“œƒƒ“E˜šÆŒ’“•Gˆ÷‰:…‰c’«’Flœ\–ô˜Ş€ûš,‚âŠ“E•â5–·‚5˜q*i€Í=k†Ú%‚ó€4–·§™y™d‰ÌX›¦“Vš°™®zœ¬—ë“ 7…b’Ü€°Œ†œr[²›H–·†3ƒÂ†'…Ù˜š“ç”†“]XÆ›à”W—gœˆŠ’‡“ËŸÎ˜È‡äœr.‘Ğœ7‡‡2††ÄŠË[œ–‡&“Ò”ä™™y§„©„ã”0>s›H‹İ™—%–xß•‹İœ½8˜ê‹kâ™èÆ˜‹ZP‘ƒƒ–J›e„(–gT‘“çŠ{‰yŠ›HÒJœ„(†Œ€Ÿ%<ç•®‘º‚óœ–šŠ‡‰+‡™?•óëŒz*ëˆ&Š×–„Še‰yë,ƒÂ‹ŠY™›2m‰ğ<„„©‡äƒç‚–·„{ŸÎ:š˜(@”m‰ğ“V€#A(‡j=ÎšrÖ•%U‘†ü†Ä”F…Ù•óœŸŸYÛŒú„.h%ä›e˜°ˆ¢’·…«ššîŸú‘[ŒBšÛ&U=)‡&Œ…Ÿ<ç–·‚Å™€œò•Á•6„>„™?•-œ½–Ü‹kM3tŒ7=)š,•â“]Ç†'†ˆ&›²”¸šî§Œ›ƒƒ›ö.g‘[Š<Ÿ¯™?§ƒ]€}’—Î”İc›ö•â”ü«Š‡‘Œ€}–&™Ù(è›HŸ.‘õˆ0ï‚ó•]“‰•ó³Ÿ™Ù‹>µœ7Š×œr›“çŒ±ˆ&•]”Fpˆ•s‡Â›&è÷’«‰cŸ…şšî—šr—¢]]
	local byte, cr, k2, a3, b3, m3, sp = string.byte, {}
	for i=1,byte(ht,1) do cr[3*i-2], cr[3*i-1], cr[3*i] = byte(ht, 3*i-1, 3*i+1) end
	for i=1,#cr do cr[i] = cr[i] > 1 and (cr[i]/255) or 0 end
	local function r16(p) local a,b = byte(ht, p, p+1) return a*256 + b end	
	k2, m3, a3, b3, sp, lhcPal = r16(#cr+2), r16(#cr+4), r16(#cr+6), r16(#cr+8), #cr + 10, cr

	local function get(s)
		local h, l, a, a2, b, c, d, e, f, o, m = 8388593, #s
		for i=1, l+1, 2 do
			a, b = byte(s, i, i+1)
			h = (h * 4093 + (a or l) * k2 + (b or l) * 65521) % 268435399
		end
		m = -2 * (((h * a3 + b3) % 2147483629) % m3 + 1)
		a, b = byte(ht, m, m + 1)
		if a < 128 then
			return ((h * (a - a % 4) / 4) % 2147483629 % 2 > 0 and (b % 32) or ((a % 4) * 8 + (b - b % 32) / 32)) * 3 - 2
		else
			o = sp + a*256 + b - 32769
			m, a = byte(ht, o, o + 1)
			a = (h * (m * 256 + a) + m) % 2147483629 % m
			a, a2 = (a - a % 8)*5/8, a % 8
			b, c, d, e, f = byte(ht, o+a+2, o+a+6)
			a = b * 4294967296 + c * 16777216 + d * 65536 + e * 256 + f
			return ((a - a % 32^a2) / 32^a2 % 32) * 3 - 2
		end
	end
	lhc = setmetatable({}, {__index=function(t, s)
		local i = type(s) == "string" and get(s:match("[^/\\]*$"):lower():gsub("%.blp$", ""))
		if s then t[s] = cr[i] and i or -3 end
		return i
	end})
end

local ORI, ORI_cR, ORI_cG, ORI_cB, ORI_caption, ORI_icon, ORI_qHint = {}, {}, {}, {}, {}, {}, {}
local function ORI_SliceColor(token, icon)
	if ORI_cR[token] then return ORI_cR[token], ORI_cG[token], ORI_cB[token] end
	local li = lhc[icon] or -3
	return lhcPal[li] or 0.70, lhcPal[li+1] or 1, lhcPal[li+2] or 0.6
end
local function extractAux(ext, v)
	if not ext then
	elseif v == "coord" and type(ext.iconCoords) == "table" then
		return unpack(ext.iconCoords)
	elseif v == "coord" then
		return ext.iconCoords()
	elseif v == "color" and type(ext.iconR) == "number" and type(ext.iconG) == "number" and type(ext.iconB) == "number" then
		return ext.iconR, ext.iconG, ext.iconB
	end
end
local function check(ok, ...)
	if ok then return ... end
end
local function ORI_UpdateCenterIndication(self, si, osi)
	local tok, usable, state, icon, caption, count, cd, cd2, tipFunc, tipArg, ext = OneRingLib:GetOpenRingSliceAction(si);
	caption = ORI_caption[tok] or caption
	ORI_CenterCooldownText:SetFormattedText(cooldownFormat(tok and ORI_ConfigCache[usable and "ShowRecharge" or "ShowCooldowns"] and cd or 0));
	ORI_CenterCaption:SetText(tok and ORI_ConfigCache.ShowCenterCaption and caption or "");
		
	if tok then
		local r,g,b = ORI_SliceColor(tok, ORI_icon[tok] or icon or "INV_Misc_QuestionMark")
		ORI_Pointer:SetVertexColor(r,g,b, 0.9);
		ORI_Circle:SetVertexColor(r,g,b, 0.9);
		ORI_Glow:SetVertexColor(r,g,b);
		ORI_CenterCaption:SetTextColor(r,g,b);
		ORI_CenterCooldownText:SetTextColor(r,g,b);
	elseif si ~= osi then
		ORI_Pointer:SetVertexColor(1,1,1, 0.1);
		ORI_Circle:SetVertexColor(1,1,1, 0.3);
		ORI_Glow:SetVertexColor(0.75,0.75,0.75);
	end

	if ORI_ConfigCache.UseGameTooltip then
		if tipFunc and tipArg then
			GameTooltip_SetDefaultAnchor(GameTooltip, ORI_Frame)
			tipFunc(GameTooltip, tipArg)
			GameTooltip:Show()
		elseif caption and caption ~= "" then
			GameTooltip_SetDefaultAnchor(GameTooltip, ORI_Frame)
			GameTooltip:AddLine(caption)
			GameTooltip:Show()
		elseif GameTooltip:IsOwned(ORI_Frame) then
			GameTooltip:Hide()
		end
	end

	local gAnim, gEnd, oIG, time, usable = self.gAnim, self.gEnd, self.oldIsGlowing, GetTime(), not not usable
	if usable ~= oIG then
		gAnim, gEnd = usable and "in" or "out",  time + 0.3 - (gEnd and gEnd > time and (gEnd-time) or 0);
		self.oldIsGlowing, self.gAnim, self.gEnd = usable, gAnim, gEnd;
		ORI_Glow:SetShown(true);
	end
	if gAnim and gEnd <= time or oIG == nil then
		self.gAnim, self.gEnd = nil, nil;
		ORI_Glow:SetShown(usable);
		ORI_Glow:SetAlpha(0.75);
	elseif gAnim then
		local pg = (gEnd-time)/0.3*0.75;
		ORI_Glow:SetAlpha(usable and (0.75 - pg) or pg);
	end
	self.oldSlice = si
end
local function ORI_UpdateSlice(indic, selected, tok, usable, state, icon, _, count, cd, cd2, tf, ta, ext)
	state, icon, ext = state or 0, ORI_icon[tok] or icon  or "Interface/Icons/INV_Misc_QuestionMark", not ORI_icon[tok] and ext or nil
	local active, overlay, faded, usableCharge, ok, r,g,b = state % 2 > 0, state % 4 > 1, not usable, usable or (state % 128 >= 64)
	indic:SetIcon(icon)
	if ext then
		indic:SetIconTexCoord(check(pcall(extractAux, ext, "coord")))
		ok, r,g,b = pcall(extractAux, ext, "color", c)
	end
	indic:SetUsable(usable, usableCharge, cd and cd > 0, state % 16 > 7, state % 32 > 15)
	indic:SetIconVertexColor(ok and r or 1, g or 1, g or 1)
	indic:SetDominantColor(ORI_SliceColor(tok, icon))
	indic:SetOuterGlow(overlay)
	indic:SetOverlayIcon((ORI_qHint[tok] or ((state or 0) % 64 >= 32)) and "Interface\\MINIMAP\\TRACKING\\OBJECTICONS", 21, 28, 40/256, 64/256, 32/64, 1)
	indic:SetCooldown(cd, cd2, usableCharge)
	indic:SetCooldownFormattedText(cooldownFormat(ORI_ConfigCache[usableCharge and "ShowRecharge" or "ShowCooldowns"] and cd or 0))
	indic:SetCount((count or 0) > 0 and count)
	indic:SetActive(active)
	indic:SetHighlighted(selected and not faded)
end
local function ORI_GhostUpdate(self, slice)
	local count, offset = self.count, self.offset;
	local _, _, _, nestedCount = OneRingLib:GetOpenRingSlice(slice or 0);
	if (nestedCount or 0) == 0 then return GhostIndication:Deactivate(); end
	local scaleM = ORI_ConfigCache.MIScale and 1.10 or 1;
	local group = GhostIndication:ActivateGroup(slice, nestedCount, 90 - 360/count*(slice-1) - offset, self.radius*scaleM, 1.10);
	for i=2,nestedCount do
		ORI_UpdateSlice(group[i], false, OneRingLib:GetOpenRingSliceAction(slice, i));
	end
end
local function ORI_Update(self, elapsed)
	local time, config, count, offset = GetTime(), ORI_ConfigCache, self.count, self.offset

	local scale, l, b, w, h = self:GetEffectiveScale(), self:GetRect();
	local x, y = GetCursorPosition();
	local dx, dy = (x / scale) - (l + w / 2), (y / scale) - (b + h / 2);
	local radius2 = dx*dx+dy*dy;

	local angle, isInFastClick = atan2(dy, dx) % 360, config.CenterAction and radius2 <= 400 and self.fastClickSlice > 0 and self.fastClickSlice <= self.count;
	if isInFastClick then
		angle = (offset + 90 - (self.fastClickSlice-1)*360/count) % 360;
	end

	local oangle = (not isInFastClick) and self.angle or angle;
	local adiff, arate = min((angle-oangle) % 360, (oangle-angle) % 360);
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
	ORI_Pointer:SetRotation(self.angle/180*3.1415926535898 - 90/180*3.1415926535898);

	local si = isInFastClick and self.fastClickSlice or (count <= 0 and 0) or (radius2 < 1600 and 0) or
		(floor(((atan2(dx, dy) - offset) * count/360 + 0.5) % count) + 1)
	ORI_UpdateCenterIndication(self, si, self.oldSlice);

	if config.MultiIndication and count > 0 then
		local cmState, mut = (IsShiftKeyDown() and 1 or 0) + (IsControlKeyDown() and 2 or 0) + (IsAltKeyDown() and 4 or 0), self.schedMultiUpdate or 0;
		if self.omState ~= cmState or mut >= 0  then
			self.omState, self.schedMultiUpdate = cmState, -0.05;
			for i=1,count do
				ORI_UpdateSlice(ORI_Slices[i], si == i, OneRingLib:GetOpenRingSliceAction(i));
			end
			if config.GhostMIRings then
				ORI_GhostUpdate(self, si);
			end
		else
			self.schedMultiUpdate = mut + elapsed;
		end

		for i=1,config.MIScale and count or 0 do
			SetScaleSmoothed(ORI_Slices[i], i == si and 1.10 or 1, 2^ORI_ConfigCache.XTScaleSpeed)
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
	local delta = max(0, self.eleft/ORI_ConfigCache.XTZoomTime);
	if delta == 0 then return self:Hide(), self:SetScript("OnUpdate", nil); end
	if ORI_ConfigCache.MultiIndication and ORI_ConfigCache.MISpinOnHide then
		local count = self.count;
		if count > 0 then
			local baseAngle, angleStep, radius, prog = 45 - self.offset + 45*delta, 360/count, self.radius, (1-delta)*150*max(0.5, min(1, GetFramerate()/60));
			for i=1,count do
				ORI_Slices[i]:SetPoint("CENTER", cos(baseAngle)*radius + cos(baseAngle-90)*prog, sin(baseAngle)*radius + sin(baseAngle-90)*prog);
				baseAngle = baseAngle - angleStep;
			end
		end
		self:SetScale(ORI_ConfigCache.RingScale*(1.75 - .75*delta));
	else
		self:SetScale(ORI_ConfigCache.RingScale*delta);
	end
	self:SetAlpha(delta);
end
ORI_Frame:SetScript("OnHide", function(self)
	if self:IsShown() and self:GetScript("OnUpdate") == ORI_ZoomOut then
		self:SetScript("OnUpdate", nil)
		self:Hide()
	end
end)

function ORI:Show(ringName, fcSlice, fastOpen)
	local frame, config, _ = ORI_Frame, ORI_ConfigCache;
	_, frame.count, frame.offset = OneRingLib:GetOpenRing(config);
	frame.radius = CalculateRingRadius(frame.count or 3, 48, 48, 95, 90-(frame.offset or 0))
	frame:SetScript("OnUpdate", ORI_ZoomIn);
	frame.eleft, frame.fastClickSlice, frame.oldSlice, frame.angle, frame.omState, frame.oldIsGlowing = config.XTZoomTime * (fastOpen and 0.5 or 1), fcSlice or 0, -1;
	ORI_SetRotationPeriod(config.XTRotationPeriod)
	MouselookStop();
	GhostIndication:Reset();

	local astep, radius = frame.count == 0 and 0 or -360/frame.count, frame.radius;
	for i=1,config.MultiIndication and frame.count or 0 do
		local indic, _, _, sliceBind  = ORI_Slices[i], OneRingLib:GetOpenRingSlice(i);
		indic:SetBindingText(config.ShowKeys and sliceBind and shortBindName(sliceBind));
		SetAngle(indic, (i - 1) * astep - frame.offset, radius);
		indic:SetShown(true)
		indic:SetScale(1)
	end
	for i=config.MultiIndication and (frame.count+1) or 1, #ORI_Slices do
		ORI_Slices[i]:SetShown(false)
	end

	config.RingScale = max(0.1, config.RingScale);
	frame:SetScale(config.RingScale); frame.anchor:SetScale(config.RingScale);
	if config.RingAtMouse then
		local es, cx, cy = frame:GetEffectiveScale(), GetCursorPosition()
		frame.anchor:SetPoint("CENTER", nil, "BOTTOMLEFT", (cx + config.IndicationOffsetX)/es, (cy - config.IndicationOffsetY)/es);
	else
		local es = frame:GetEffectiveScale()
		frame.anchor:SetPoint("CENTER", nil, "CENTER", config.IndicationOffsetX/es, -config.IndicationOffsetY/es);
	end
	frame:Show();

	ORI_Update(frame, 0);
end
function ORI:Hide()
	ORI_Frame:SetScript("OnUpdate", ORI_ZoomOut);
	ORI_Frame.eleft = ORI_ConfigCache.XTZoomTime;
	GhostIndication:Deactivate();
	if GameTooltip:IsOwned(ORI_Frame) then
		GameTooltip:Hide()
	end
end
function ORI:SetDisplayOptions(token, icon, caption, r,g,b)
	if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" then r,g,b = nil end
	ORI_cR[token], ORI_cG[token], ORI_cB[token], ORI_caption[token], ORI_icon[token] = r,g,b, caption, icon
end
function ORI:SetQuestHint(sliceToken, hint)
	ORI_qHint[sliceToken] = hint or nil
end
function ORI:GetTexColor(icon)
	return ORI_SliceColor(nil, icon)
end
function ORI:SetIndicatorConstructor(func)
	if func then
		local s = func(nil, ORI_Frame, 48)
		for k,v in pairs(ORI_IndicatorAPI) do
			local tk, te = type(s[k]), type(v)
			if tk ~= te then
				return error(("Expected %s for indicator key %q, got %s."):format(te, k, tk), 2)
			end
		end
	end
	ORI_CreateIndicator = func or ORI_CreateDefaultIndicator
	GhostIndication:Wipe()
	for k,v in pairs(ORI_Slices) do
		ORI_Slices[k] = nil
		v:SetShown(false)
	end
	ORI_Frame:Hide()
end

OneRingLib.ext.OPieUI = ORI
ORI:SetIndicatorConstructor(ORI_CreateDefaultIndicator)
OneRingLib:SetAnimator(ORI)
for k,v in pairs({ShowCenterCaption=false, ShowCooldowns=false, ShowRecharge=false, MultiIndication=true, UseGameTooltip=true, ShowKeys=true,
	MIScale=true, MISpinOnHide=true, GhostMIRings=true, XTPointerSpeed=0, XTScaleSpeed=0, XTZoomTime=0.3, XTRotationPeriod=4}) do
	OneRingLib:RegisterOption(k,v)
end