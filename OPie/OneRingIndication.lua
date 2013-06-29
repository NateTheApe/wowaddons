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

local ORI_CreateIndicator, ORI_CreateDefaultIndicator do
	local api = {}
	function api:SetIcon(texture)
		self.icon:SetTexture(texture)
		local ofs = (texture:match("^[Ii][Nn][Tt][Ee][Rr][Ff][Aa][Cc][Ee][\\/][Ii][Cc][Oo][Nn][Ss][\\/]") or texture == [[Interface\AddOns\OPie\gfx\opie_ring_icon]]) and (2/64) or (-2/64)
		self.icon:SetTexCoord(ofs, 1-ofs, ofs, 1-ofs)
	end
	function api:SetIconTexCoord(a,b,c,d, e,f,g,h)
		if a and b and c and d then
			if e and f and g and h then
				self.icon:SetTexCoord(a,b,c,d, e,f,g,h)
			else
				self.icon:SetTexCoord(a,b,c,d)
			end
		end
	end
	function api:SetIconVertexColor(r,g,b)
		self.icon:SetVertexColor(r,g,b)
	end
	function api:SetDominantColor(r,g,b)
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
	function api:SetOverlayIcon(texture, w, h, ...)
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
	function api:SetCount(count)
		self.count:SetText(count or "")
	end
	function api:SetBindingText(text)
		self.key:SetText(text or "")
	end
	function api:SetCooldown(remain, duration, usable)
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
	function api:SetCooldownFormattedText(format, ...)
		self.cdText:SetFormattedText(format, ...)
	end
	function api:SetHighlighted(highlight)
		self.hiEdge:SetShown(highlight)
	end
	function api:SetActive(active)
		self.iglow:SetShown(active)
	end
	function api:SetOuterGlow(shown)
		self.oglow:SetShown(shown)
	end
	for f in ("SetPoint SetScale GetScale SetShown SetParent"):gmatch("%a+") do
		api[f] = function(self, ...)
			local w = self[0]
			return w[f](w, ...)
		end
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

				local chunk, shrink = self[4+pos], 21 - 21*pp
				chunk:SetSize((inv and 21 or shrink)*scale, (inv and shrink or 21)*scale)
				chunk:SetShown(not sp or pp >= 0.99)

				local p1, p2, e, p1a, p2a = sp and 1 or pp, sp and pp or 0, self[pos]
				if p1 > 0.9 and p2 < 0.1 then
					p1a = 0.9 + (p1 + p2 - 0.9)/2
					p2a = 1-(1.81 - p1a*p1a)^0.5
				else
					p1a, p2a = p1, p2
				end
				if p2 > 0.1 then
					p2 = 0.14 + (p2 - 0.10)*0.86/0.9
				elseif p2 > 0 then
					p2 = p2 + 0.04
				elseif p1 > 0.96 then
					p1, p2 = 1, p1-0.96
				elseif p1 > 0.75 then
					p1 = p1 + 0.04
				elseif p1 > 0.65 then
					p1 = p1 + (p1 - 0.65)*0.4
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
				if p2 >= 0.99 then e:Hide() end
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
			local cd = cc("SetScale", cc("SetAllPoints", CreateFrame("FRAME", nil, parent)), size/48)
			cc("SetScript", cc("SetScript", cc("SetScript", cd, "OnShow", onShow), "OnHide", onHide), "OnUpdate", onUpdate)
			
			cd.scale, cd.spark = size/48, cc("SetSize", cc("SetTexture", cc("SetDrawLayer", cd:CreateTexture(), "OVERLAY", 2), [[Interface\AddOns\OPie\gfx\spark]]), 24, 24)
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
					(i % 4 < 2 and "TOP" or "BOTTOM") .. (i < 3 and "RIGHT" or "LEFT"), cd, "CENTER", (i < 3 and 21 or -21)*size/48, (i % 4 < 2 and 21 or -21)*size/48)
			end
			cd[9] = cc("SetTexture", cc("SetDrawLayer", parent:CreateTexture(), "ARTWORK", 3), [[Interface\AddOns\OPie\gfx\tri]])
			
			return cd
		end
	end
	
	api = {__index=api}
	function ORI_CreateDefaultIndicator(name, parent, size, ghost)
		local e = cc("SetSize", CreateFrame("Frame", name, parent), size, size)
		return setmetatable({[0]=e,
			edge = cc("SetAllPoints", cc("SetTexture", e:CreateTexture(nil, "OVERLAY"), [[Interface\AddOns\OPie\gfx\borderlo]])),
			hiEdge = cc("SetAllPoints", cc("SetTexture", cc("SetDrawLayer", e:CreateTexture(), "OVERLAY", 1), [[Interface\AddOns\OPie\gfx\borderhi]])),
			oglow = cc("SetShown", CreateQuadTexture(e, "BACKGROUND", size*2, [[Interface\AddOns\OPie\gfx\oglow]]), false),
			iglow = cc("SetAllPoints", cc("SetAlpha", cc("SetTexture", cc("SetDrawLayer", e:CreateTexture(nil), "OVERLAY", -8), [[Interface\AddOns\OPie\gfx\iglow]]), ghost and 0.60 or 1)),
			icon = cc("SetPoint", cc("SetSize", e:CreateTexture(nil, "ARTWORK"), 60*size/64, 60*size/64), "CENTER"),
			overIcon = cc("SetPoint", cc("SetDrawLayer", e:CreateTexture(), "ARTWORK", 1), "BOTTOMLEFT", e, "BOTTOMLEFT", 4, 4),
			count = cc("SetPoint", cc("SetJustifyH", e:CreateFontString(nil, "OVERLAY", "NumberFontNormalLarge"), "RIGHT"), "BOTTOMRIGHT", -4, 4),
			key = cc("SetPoint", cc("SetJustifyH", e:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmallGray"), "RIGHT"), "TOPRIGHT", -1, -4),
			cdText = cc("SetPoint", e:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge"), "CENTER"),
			cd = createCooldown(e, size),
		}, api)
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

local ORI_Slices = setmetatable({}, {__index=function(t, k) return rawset(t,k, ORI_CreateIndicator(nil, ORI_Frame, 48))[k] end})
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
	local ht = [[dÈÿdÈÿdÈÿÿ&dÈÿdÈÿÿÃMğæBdÈÿˆÿMÿğMLWÿMµÿLİÿºæºLyÿLÿÿ¥LÿMÿÃØØØÿóÏÇLÿèLÿ°ÿ&ºŞæÿ€ßÿLóÂ­ÿæºælc	.UtA" 	s>EÿèÑÏ÷JCÖÄb’ –wç¯œ“‹ş¶!$r>ÿÑ+w}º‘JG Œ’Èò˜!‡g">K¹d "ğÅ“¼Î÷1øYÙ5“9–RB„\È—AÜûaš ~–f?ÿÈH¥Ö|ê´tŒrr8“×Éô‰AŞ¿è$B>Ã‘Ìú<»mˆIgÿ¢%‡9¶M•ZB÷<‰]^r$îŠHú!èŸ×ú!”#şwôäz$yğˆB#}StÈõ»øÎS7üò«?üû#ş¢+LOù½r§Î‹°„%¥Ë|\‡}qÏôDù›"Š¼“*zçı?Ÿ$ı½–?Œeò9ìÙÈŒ‘BgÜ™.¨‰>B%ö Mk1MDÆ''ÉK]'YĞ²3è{"ùDYEüû %&zÆ‹üĞtœ‡EQ„ äs—÷ıÄEd~â-Ò!4»(0‰¤ˆÛ•¹	#×{<özC¥Ç:75]×„!ÎëĞJ¿'Á‡­L‰è·ŸóšşÃŸäM¿>IÇúòXçaÅï¡‰bÚ8ÿ)GÓtLä£×C’$ Œkôş_‹s¥ÇOäB"'ÕÎ™2)&‘ÿd-È²HÇ-Q‰İó ’~c’GèÂÂVÄär0„­‡‹ÒŸ¡::ç³ò ^–ÄÿÉô¥ozk,„BDü’%J:Ÿ¿úL?nC˜¿ì‰”WxÅ„+Ïã7~Rb~„‘ë;1‡'wEêïÿä ZG»çù5t=‘¯Ö´?ñEùïzêÿõ?Èº½?A”Ü‘$Ğ½Éûº´ÔŒ“>EŸ(.I>º2lû|?óTŠ–-A,ãüäC¾’Ä~ä/$ı?üçCª·ÉhwØšöGàÏıÎ I6w'ä·ÙU£Hs®ÿËõvÉóÅÖ"ÿ­GKÖxAúÎú0—úƒÈ‘d~s¡„¢?"Ä@‹İ]DÒòDŸdI„éÄ?œ‚úN‚d¹¤ìÃE¦wçà‰‘‚1‰{ÒÂ9;ãD)KøÅÇ ¢â·Ïôı0ç±åı‹‘ö/öIØOî»¿ü¦.E<XóÿÏÿ7“µW#vs×ô6¤–8ôØD‘‹IJŞÉ8òùÈö|ì\_$ÿëú	óÒ« GÎwß."	›¢ŸÔ¿õÿèÛ¦‹-ÇgøÊ®|¿ÈBIvWõ’/r>uŸH+<µüˆ\ND½n :â·œìZ?/ÈèşßÆ|ô‰ÿ°ì+;Øwıkû—&ò@*9ÈÍ(»şƒ¹ë wõÿíô'Î…äÎÉ:uœ¶‡Ñh]e¤²NÉYÈF>n4gşt$ç·HDè‘?g äî¾ó¹q¿ÿÖæ}?¡ ôH²YroìCÖ†ÿ"É¢X!#GÛî	¤äzlÏÜ‚~__Ü„ü“”N„NÓK–y¼ˆ§ĞJcèZ?ù‘øË¥#±Ç "Ïd!ñ&4¿ñqÓøÄè?	ó§ëK¾Ä.)ş~y1oYt²Ä»¬¦ÑrØÇ&$ùÑvN¸ z#ßÄä?ÒÃ“ú~ˆ¯I±ê„Îç$;éüˆÆèbQI¿ÿt{÷]k!føı‰v4\è	ú(G}‡Â~xÅÇF	;9v-”:~†wkÌQ´Vl!MãB|ÿaŞŸ¦ b>çRk’IÿüI§è?şC½Ÿ;Èù­Ÿ‘îâ#é"ó ‘#˜—å úĞ˜­/Å'™\ÎÇ1ÈÑÿØ“ üôçÿ{·7!~,•Ÿi!,ûˆõÿèÃ˜¹ÌŠ%Ù.zPÂ8ÿwNBFÓ 9™~º?ú$Œ"?—ıÕ;ß8‰PûØ‰Mw!ÿô,Ÿ ù†#øyĞHÍÏ"ÿG{ç"ù-+aOŸ"a1ërÑòfIŒjåıÛYÈÛK“şƒÇ(I²=i ~Oãü"‡,!/è„¹š$ä{¥û,öZQC“ô¹Ã¯ç‹È•¼’rÏò}q"óËö.Ò~ë§tN¿üìVşì:(fè´½ÎBÖ9ë;,ÄÆè>)ôÄïã7îãF7ù&ó¡äHË#’K"hÙh'È|D‰ AÒx×l"\Ä_ÿ'şÃ¥ËúPæ¿JÙÊ¢ä#GEúW©ı4|ˆ¿“ó ú(·è{ì‚dü¦Eı&Ùï	ü£I“<V¶&_†²Hå£è :Î•“)ù?ò!‰ùşC‘Éû“³°ä	{‘¯Œ#‰–96{$ÿü°÷9;c¾¹çZóÆQ›>”—”Ïû)Bô|üLkø§ùB‰Øûë"YÉI	3±Ì !Şåş+‰ycè…dÈw ŒYÎD‘kwóDø£?¼ètVs»çsêçÑ‡$æG²tb~I#rû¤r=ÈùrÉ#¥Bÿd#ş”­ rf’)§Şİè?ŞD»úrPw ŸyÒvvx>˜O“8"?#“óùw§äÏ²èùãøÑ]>sş´ K™c²—Jí¡Ìf­%¢QA>…¢‡GùÑù¥tÖˆÈ”B=šÑ‘]£Ê³ïĞ…£$;$rPšzÏ¾rE*»Iä &ND²Q'ÿo]¢‰Æ‘·Îï¥.&^È¥x"N}dÒD3óY.µÉïëã÷±ßCÿC¦ËÂŞ³Èä£¾ˆ¹Ÿ!.O¥ñZuıé$Ÿ¯óAåÈŸ ¯Ütäø¥‘Õºñ¿ÖÉ ”z÷Ÿÿ_ö¿ÄçŠ’QçE~ˆÖyu\»3>H´Ïÿ"â8ÿ $ãıÆ(¬×óv’¶-'Ï‘ <°’,Ÿ&fäüäKˆt­(;'Ÿ_{¾H"±róŸï¬Ğ’-ŸN??ı/û™ÿ¯[Ño§‡Bƒ¬ÿÌOk“ø?åtZdOòB;ä|P³¹?Üu¥¸EçÄÿú\Bïd\wIçKâÃÒH;Ä9$o8¤ñ •^vHwÈÏÕÇN­‘Ë["Ä|ñÿÈ„ın>EÅèB[Ø›hB>Èüî‰GE•‰Öô ÿ–İ¯?q'•Ù'ù)¸ò.a½ŸI×úi[¾ú®+ú†Läùİº3»©Ô/ñ!Ç¾Ä>¯Êw— ä¾‡vÿå÷£ëIëò?JTÆ÷#œT­ë?÷ b¡ÑI	Æ+ÿÖw;‘DwÇĞÿ:Rx¢R{‰¤|õC2”Ùßó¿Ï³§Éîõı)úG2« Cˆ“Åi~±ôşKı?t¤[ÿÚÎ‡YŞJ"?9ÉÄ%r„9÷rQ+ØçI•ítq"Â-	šÒâ3	!ã’ÉAò}” &N–OØ„Uÿ|Vã¢$?ŞÌºQ6YêD.3 	úNr22aïü‘sô$ìc…¯èCCá"cù%È #	'£=büÿJcæLşI½ŸÿEŸª-öF't¾Ë“ç±Ñ/¡‘<zN´‘ßC*Ç­ˆKä°ÿ‰Â#'y1ò8é›şöM' B"ˆÈì§Òv!ÿ_æÃ¥”ş‰¡x[çÿü“ãöôA"Òsd_H°õ úo¯?æt ‡bIô éŠËåË_ĞÇŸ£¾OæDwÖxE	g‹­0!Ğ¿°õ	:Oè÷ÖŠYûşC×IdûŸä¢Ö—eîù?õ¡Ø B?÷!	úø±î¿ÖÄÇòr"ããv	ıú’‡«?F3 OäÏÛì‹¦H½•ÿÜÄ‘\cò~HüH¿£õÓÒ1@ÔÈGÉò«£I'DtƒóîVCÈÅÿD¹×/³ÿ#Ï¡$£#ú#İôé"*Ô‘MßŠôs—¥„ú÷È“š|çÕŠÑi!rÂLë#÷Qs BÒvéúWüé'Üãİß:”œ„ ŸÜÏÏéı~å¦lùî¿°—u]Îl9#‹}Œ'Ñó’)$N‚dBi‘ˆú*ïÖ– şşä îeÿ¡(;¾·ÄîzÔÿNş‡8úIE¦i:Ÿœ ÏÉh‡{BVdB~ç0K>r1ÈzRÏŒü¿²‰ :&B?ÿÿ	ò=|æF	¿Ï7 ÿ)ùD²D !ó¿Wr›Ìì©ôî³‰Îûş/¿?œˆ“²õÙè &Î‚%ÿ<~’'r,şœr"(¤Ş·#ÿzĞÄ¦dC¹‘çùş¿§.!ŞO¾ˆ[D-}~Å¬Ÿ+ri÷¼ç"=ôr	“ı(9ó‘Ä?Ö¸¹z¡9?C½÷û¡hØöú$› ˆ—şïÖH {¤EüçÒ¿ÅÎşœäÇétqÆ|èû>FEgO÷­+cş¶}	<œÈÙC¬Æ’wß—,ÿDm†'7c5Ëø*ºO9-„ }Ö¿£–#õ£ï¯ëÿÑ¢dD±xúNäîªHw"(Çã¦}Ó;ÖJK"W†Gu$¬ï úuhu£ïü£g.%WöäúŞÏ±ß[Î—–+E¾ã²+ ²âè J~³’,ùÿs‘èËÿNÍÛ>¯D?Ü¿T‘K£c¡÷É?ú ‡ úÑd¡,?âÏ¡çFPÂR$YƒÍª×BÇ"÷ô9?GK‰~gO¿wHäOÎäôúYLë*û.ù'6^ş—¢Ht\~îÉ)9ŠÚ:RÎMv^ˆM²‹ù\ñ@™ùŠİõ¹3ëë>_\Éö3 Jÿò8„sEÅ';ÿ¨¹iBçæÑum÷‘„ ıëó‘„ÔIüÆDJï»éƒ‰­é gÒâH„~	õ¹ZQ©ôün³Ö_ —ÑJŸOÎï¯ç§×'¯$ü®ëQN¿õìŸFP˜×î-C°{~R ¯ĞH¹d›£µ¢Hû6ııhwĞ‰ißÈG¥Ø ŸÈµ¹Ç^ŸOÉ„âÂ"‰ªèô‰ û÷’ä±	åˆúHuõäJÿ¦"'È[ï­Ì`"İ3Ğå£i‹ÇO@#ó½Ÿt£ó¡ò@B^ºŸ·ÎH²kâ%X‘':h­–âş_J#¥±7\şCı1s¾v?çb>öYdQÿÈŒÅ,ÿØŒX‡Y.Ì‡£¤˜ş=§òÏèòùìé8„:GıÒsÓù¹Ÿ:^Èÿ:¹Ö¸ü› \ÑòFärHÿòû>BQìú×$å!ù ˆiN>†EĞ¼ ”I?Uº³;ú¶ih	9.ä|•Läw±‹ı>•®¼AõÕŠX…ÇçIèò1sÿÏˆşDYÈ¿’(wØ÷"è;z²tºj!'Š^r:? &fŠ’)úƒ¸„{&æ}$›³®ßŸùô-='#Ÿ?â„ '¾t8ö"ôŸ{Óe²):Å³D[Ï¹?^â–'èÿ„qZ1,º	"Ké!Ø´‘û&x‘ØGæã¹)‘ÑôwïZHóÆëc??ò“Ó&\$¾ÈÉ‰B]÷¿:Ã§ÿ Ã¿ò2üòçİ)µ\æó#"ï£ôŸ×JÑYß!’DÒÿ®<r?ùİŒœ‰ÆïCçşIyâ; 9…ÿègQô1Éeçs²„dQÿÿë²Ú}É&“ıÈä#±÷£ì>•Ÿì9Ñô¡$Ú~ô'OÔÑò2$:O'D	JÏRP q%ÿınÃ)ôşÄ‘b#¤$Îï ‘4>Nb¿¹É"~¹‘zcD~? ûj1$ #²¶"T<×õ‘]#>}ü~O±‡	JĞH'„^ó§è™ĞŸ¡(©äBUÒÓºÄ!+'X‡½ß,Bú»N=ÿ‘îKuÅÄ:ã¯çv\D}? ±ôŒY6‡ıÏb‡ò·§4%,ËC¹ÄÿĞ‡#s A97ü˜\È½g³ˆt}JH²i££ø‘ÑÏØD0ÿ?÷“ä=zCısªtüÿECœèK¸£äúÎu¹î#œ¤”§ïs¿1$ y>•¿g|Xû¬î±)ôì´ßô !&x§çÿŞ”³drûú.|Öö}qcÖ‰èq"öbÏÏßÇìÿğäQ˜EO²?Ïü‘Dş¼Ú3ùîF2	ú(Èı$|Y…ÅÄ5û­ú—8üÏü¹[4/îzRì94M¾F|ï"Oÿ£KşÏßÈÿñ,»D œµ*ÓïyÒÄËî^(ÆtÎÿ£ÿ[:| „¼/ ï!û#´’HGß:¦IÁ%4©òò/??ÖÏÎ®ª\ô}ëy—°öu·Ã²?“(” •}â¿;CÌóŒşâ#.yæO“Q\~ÈÊŒúIR!ßú?¹‹–H{¼Ÿ %~²FßùÎâ1nc‚S+{—ıÇè¢0ô“gfº8äƒŸLÿ'‰=sIÑø¥g´°z¹ˆ*AÎË~LÉ«—cşz¯® 9İ'êqrúM?D¨Â]İÿ¥}?¿Òç%•‘ı„!ø¯è§ÑòE“aJ ‡aDı?_İú½yIåÆDC’GiŞ´9oŠ/3ÍMĞ¿ÍˆYÈyü‘‰$2ŒC«ºèûÒu­$ bÈ–oöa°ïAÒƒ±â³çû¢ÿÄˆg>B1ŸJ‡çbVr-Ÿù?ô!ä&?X·çCÈ‡±ÎCƒá›s«'!‘[“3şR	'óù'KKÇäëK’.GÙ)üŒıÒËudv¯8²_’ô Ÿ?Ò²± fX³§äOÈLÖ]%'¥+t^¶}éC¾”aŞ|½äD‰?½Ï©b1)ü’æD„9'õ‘?‰>„çé2CüŒ¿æDş¤—ÿı	I¿°çÏ{±„#™F?èGßI“èÚ~DÍŒ wÈÏıçaGQ!ÈD“OE.ê!. B‰’:s”¥t™?úÿB"¹'éwØO’¾ CÉ*äa?ji:)LºNÃ¨ûí, ùòd®~»~éÉg3,ÅWT–:óÒöäJX‰-ÓJ,HÄì9şÿ¼ûÿÎE²“C¿S­gıŞœ „Zÿ¢+K.y¢¨&Nş,<şxıß ùÈ„ıÊ?ö,‘;’Dkï½VCĞëL_/şG«/÷°–ıbÏYc"Oı8ùëf“äµ¿ÿÏ+Á>â!)Dô·“ç#ÿ’k‹$â_ŞƒüŸ×ƒ‘‰%%Ğ²9JhüùÖFP”ŸşGÇ÷{Î´ıÿú‚GÿLÉß!¹Ïßèy"ÅlGİ#ÅßBHÇ|˜÷uäÌ\D’ë©;Ÿ¤‰Øí¹Ë›FLöAè…¥û—­$ı$}"‰ı?s¾õ“äGşûí_şr}h'É÷¡î üçƒÉßû‡ŸèGïç:RsÅŸÄúşÈ’‘ÙvM$|d“¿éú‡‘‰ÿIÌ #/óºd9	3¡hBuÿÈ˜KÈŒ|ìAÉbJG }&Ï‘ŒùOÏÿæ?o’ì:PJäÁÿùı×&Vœz/ëgÊ?SıÅ"òiÉÿ‹×;²YşŸu—B2Èû(·(‘şê-( Ìı'ëüŸü~ËıÇMnvè ['ıÿ$ü•"ª~$GÈİÄşÜŠ=iDÏÿÕ‘Póé„#>rMvÿm_çô ›0ïêßúñóê?E^…Í,ëºŸÅ${ÒF}{şW¢ÌúK½ÈE‰"‡[µB-Ø…Éú¥Çë©Õs ù	üJ‡=ÿ„Ró—Ï†#îu,´}Ë ZHG!2OÙo»ÿ9Õ,t£H½ıtÚ©[ÿ7}Cˆ¸¥ò$b´%É\˜z‘:VzGç­	?¢NFMÙ£ïÃ7Ÿ)vR†`Ÿ$Ò‹ıÌBĞÿ¦,rşƒ¸„—ÓŸ£n¡şÉaÏbìÄÿò}>´‘Y.I!z¹İŸñÉ÷$ˆL¾¿±vå‡ç¯Ó¿ì ·H¸¡ÿJµ‘3!Ò—¾ßÑÏò%‹ûdÙ ıú1ñ9¸õ²îâd“JØ;ä–9ù•­²V°è›Ö{ÄÿKôÛñ”ÎD=lGúÄ9ÑÓ²¶'ÿJÄ9.¼~Äı”nK‘ÈGíõıiïİ¥ngôÏåŸctQÑCõ¤ÿÿÒ³£ì_ÎtÅòÿèO×óD~ÈŸè'îx¢ù{£õ‘_î—ôAy#óş>ııèc#TÅªgt=™İ7± =I%ó©7&}dGÑúûÙ¿È“ùÈN}?	=S^Oñ7.g aâ.û?Ïë¯â¶‰IŞµœç!ÖtÌÒí*çJŞw±ÿÌ‹ş~wDÿ@I÷#¤›ú–%„ÿşx‘v r›ÍÓ×Îïxû>šóÿ!ÿÒ2?”ÑhIï_èGœ²F_M÷1¬ÎÄÍçÂI/­‹~?ØèAãÅëDNõËè;‰~²ùô ÿ£µò?üôµ¼ñ>SyñüÜ·°“9É/ıÉ›wo;÷ßGßGİ7b~ÙÈ|sœégÎÿ±,Jº¢Ÿş”çûŸi¢d _Î²M,´Ï'‘õú>·şdÿè¼› {Ö¹'ú>â#çs$Gı(aÿ÷¿î tûò|‹"öäşCŸÔúsëèM>½kş÷ z_U²99Ùƒı?9%÷,Ÿ’f±äıGX‘·çO³şØò&$I&ˆ¡+r>ÈÿK×ø¸‹"~·}øqsÄ—êz°îû“ô§úz*ë¯?">„çT:ÒŸ¢ÿeÎâ9vúÉôkÿOù)Ë¨Bm™~Ä®ÿó÷(Š?÷Nô gİùP‡Aóø»äı§ù/ì{“'ˆM‘%²ßqĞèıìJdz£ñãÙü’¨#æ¶IÄ‹ÿTÑ' Áô¦H‰âF`ßßw’±´˜Dß?–#ÿG•¥ÕÿCÿO¢“:R¿É´üOïèŠ]ôÓ‰×íÙü¥tˆ'Ù8°œ ÑÿòŸüªì#9ıH¹÷|ãÿ¬‹‰ÿªıÒJÿR|[¶ÅıÌ#ÖDm ùÄÌöLÈÿÿúÈ¡OæyÖ1 }ßö|î‰?ô3ÿ‘?ó»·ïÿÿ­cõáGÖÏáÿîŠ~ÿJgÏÅqG?U¥}d«ö'éqÒ|‘é ûÿö?ôü*./}¢ı|Ÿ>ÿSş1c…ıÏ!-÷Pî ÿİöY’ÿâ¾IBÿ§çOÿ7ÇÿÿâÄ%ü?Åˆú?cÿÿş¿¶ä@ü¿ÿúOş~ÿ™©‘Kœnhä–ŒÕ=)œ ’@‰Õ’é’»—ã>ï…ç™@Œá“ñŒá•›•“*˜‹“–d‡’œÉ,<„C‡ñ˜•…²”Ëˆé‹3L‡¼”ö††”Ëœn‹Ü˜õƒë€î›t›h™‘›6ŠŠ<ç„lŒ¸‘5Ë”8”Ší˜¡‘5ó™9„<”–nŒ%‘^”D"ŒaN™û2)ë€[—sv“=‡¤šŠ†ß˜ˆÑ‚¬š¢<„ì•	”Pœ	`›{‡Ší—ê–%˜n’é‘Ï«” ™Şv¨»&‚Ä‹Ü…L•º–Õœ¶&&)%9Q<ç<„‰áì„`Ë›6™‘’¨”Dƒß<ç‡°šk=“˜‹­œ	œ˜ÖŒ…¦“ˆJ„ÊˆÑ›‚€(CT˜–Â–zŒ%–Õšù‹å‘î–%Ñ‰-šŠË–ª(ë…z˜n˜‘j•io-øŠŠ…zˆ?ÿ—`Š=íˆ¯›†=)’é™Pî‚Z¢ç”–œO€(=Œ›Ç›P™äŒ1‡Œ6›*„â’Q›‘Ï=)ƒGÎƒifrŒ™€[—™m“p†	HˆÑŠaŠI–—„T™Şœ Ù„0™™-œÕC˜VšŠ2ˆé”h˜…ı‚pˆ†Çƒ#‰|“|„øœn=Î`”Š‘^•|<ç„¨‰E„x1ë™|èùƒ;“µ‹’Š~«İ—T•¢›D…çšƒ•œÜ˜­‹?‚Zˆs®•4Š%.TÎ˜À<ç™@œò‚òší%q‹?œ‚”‹™û‹›ƒ—sšË’Q’n%hœ¶oŠí™ûL’Ç=ï™×‰p)˜šX€¾‰É1$”˜(é†’‘5‚*•((è†ß_…ƒë‘5•“1*„G˜â…€ú–ÕˆİŒá“S††‚¸;œ˜Ö€[›=Ÿú•p…á›P™…€hœ ‘ÛLÀƒ”–„<¢€¡™a‘¼·6Ä=k’ŠI”¢ˆg„g–ÕµƒÓ›İ=Îƒ±ŒÎ‘îGAÉ˜)„”–¤zy‡¤-‡˜¡™Ş™˜„lŒá†Çñh‚Z–zŒ1™m•’“S“p‰Q=ˆÅˆÿ&?ÿœ’;‹ƒ•4ƒS„•(†ÓD=k“=€[…z„Z†±2”h‘¦šXZ<çˆ¯fŠ–’ˆé™N†¥?ÿ$ñ’ÇœÉ1Ï™‘È€–›š„¨=)(“ÿåÿ˜††Ç—ö'W=–=k=k‹'€•œÂ‰Õ‚¬ƒ¥fî¢ƒ±ürŒ†¥ÂD€‰‘Û•…çŠËí‹Üƒ#’™a>R“È2E÷=kƒiD™Ş"?ÿ…z‡“€(•	…Å‘Š'd™Z‚6Œ•pNœÜ¦€¡œz0“¢‹m‡¤ğ=ïnšL“›<ç˜â„„€Ê˜bª‘˜Vˆ+•]™µ“µˆ¯š!—=‘^>s&ˆší‘"™Á•Ğ‰ˆƒÇ•Q‰ùŒm™Ş«=k>1…¦‰Q‰>÷‹®›óƒÇ—:ƒ;„ƒÓ‡ı›*‘ÏŠ–—Í›D¢™×”)d-w–Õ=kŒ(‰…1ƒuˆX‘†¸L"?“Á<çœg‡ñ’ª‘¦–——±—N——g†n=Î–)È'•¢‚¬”êá<„‡m–„„…ˆ‡Ed†(„â–É$è=kÃ?ÿ”Ş–¶›\„â>1‚ò<ç‡ˆé‡N@•<„•º<„’Q–Œ%+„ÖZˆ	=Î“1”ê&K›š‡m‘K‰|–zË—T'ƒ…¹ó—’‰Q™=)‰Œm—ª–T„Êœ7Œ¬,‹’œƒu‹ş›š.DQh“—ö›Ç”8–1ŒÕŒm›—Y‘¼İ†J»•4›™Š'„Êƒ‚ ”,‹Æ“|Œ=´ˆ2™ûš!‹?I%–˜­1”f‹'N‘‚’(š¢ƒ>÷”h(‹—ê˜œòİ‰ˆ“S•®…(œÉ™=Œ—Æ‰]Lïœz‰d‡ˆ	˜õ?ÿ’;œ—Í%Õ›h=kr8=ï’Çï„Ö„„üó™‡Œµ™Gˆ	“S††‚”™ŒI”,‘¦“i?Ä•Ğ—s/K‡m1'ËŒƒœÕ˜â‡o‘î`”P’»˜8ä•4‹è-‹‹èáéœ7ŠËšk“‹Æˆg†Ó”h€}ä–G€EŸ“§™ô›Ç’ÇyùœòŠ¢ˆÿ…z”öŠá=”Ş‡aƒ˜À`š@‹è‰“1—Í˜b¢‰Eškíšw:'—Í˜O—ŒUœ€¾ˆÿš!=Œ¸/”“¹„H•¢†J™9Œƒä’4†>ƒ¥†ß»Lˆ‰±*=”L|ƒ;—ö–ë’„‘‘"–zdµ˜<=)ƒ”Š=k†b–É=ïÈœÜô/=Š~“µ‚6šw‰áğ˜b‡*‰-’ÿ<ç—‹—ƒS…z’¨ŒÕ1$š¿”×Œa†z€â˜5š–šƒ=Î=Œœ”®²@‰ù‡„œ˜O$5ç—¿”Š=šd“‹?œÜ•|…(<ìØ’nˆ—=ÎEœ•º¦ƒŠÄš@%˜¡‹3†¥ÎŠ®;‰dšŠá˜­El‰|Ã‰ŒU.$’g—Í•ŠËƒÓˆ¯<çÑY˜Àˆİ4—‹²——:?ÿ†V˜u‚ş€âœş‹ş‘¼˜u¹–G›P™Á„Œ-Ç‘‚ˆ£N‚|¶›­;Š¢œÜ›¦‰<’‰í˜0’“|‚p’Î—›»ˆ‹ä–dçœòŒIˆ–1H“Ô’‰p˜‹“Û•iË$ñ†±ñHˆˆé”µ„¨˜u„<,‹Š=’ƒß˜À•º€•€­<„…¹ŒU=)ôf•®‡ı‡ŞšŒ1˜­’Q/+b“›˜¡‡ñœ+‹—g›»†Çœ œ™Š~•p™©–G>µ(‹“®„‡ñ˜b˜‹†ßƒë‡È,‡‰Õ—3‹˜›yá›İƒiœ¸šËš-„Öe‘v‰-‚æ‘š”öœ™(èD›­“øÎ‰p=)‰½†Œş–ª•QIÑ5	ƒ™˜¹‡È‹(›‚Ğ”µ™-’n‹Æ…b8”~¯šá(›İ–ÂŠ~5ìŠí‡‚N›=‰É<,ˆ˜O˜–z‘š>1‰í=‡€>µ™Á‹mŒ”8™“Û„x"š¿ƒë…ÅŠ–„`™…œ¶‡ån€9*“8•]Ë&Ç”µ‘ç…ƒS€­š‹ºŒ¬všË…™Ş.I%(›\vœÉåšË5ˆLŒŠí‰9™œ •Ğ*ŒáœÂvšËŒ™’¯(€Œ=k—’&¨œ ŒI=„‘5š!‹m‹¢“Û€}š¢›ÇZŒ¥›İ–ë‹®”µˆ£n>µ†J‰É‡y‘5›Ç‡›<çˆg”\S‡*‘v=„â„…b“Âš‚*œƒß—'^T…¹Š»‘ˆ=œOŞœz’n„H­›‰íŒ™‘H¸‰9tä‰ù‘‡6Š–İ‡˜…ı†zˆQ*•Ü™…™Á‰ÉÙz…@=Î›šší˜ò›´‚‡È.'›ó>.š¢‰ª•]•®”\ƒ™Lš¸™û€E,è™y…4ƒëC—’"›t‹‚ˆD9+•ˆ=Œú)1‘”Dˆ—†±•ı=Œ‘5e'<çİ”PƒÇ’™Ny„’Ç€‡Zˆœ ;$î›\”ê“ÈY‡B‹U‡B™NŒá@‚ˆ€­›0“TŠ®”Ë€ú™=<„Œ÷+—˜õ™­œ7&L”Ş&$‰áˆ—$›D…Å”h(Y)'<ç1$›óƒG%äùœÜ?ÿ™µ‹=Îš-~ùš*—ê¬€‹mdˆ†(˜ÚŠËš9˜›*y—M.k=ï=ÎœC=œ ‡˜ƒë’„Š‘Û•p‰±…nI”~JIš-ŠŠŠ'<ç=•(‘ŒÕg)d‰ˆˆ	,‰™ŠaŸI.y’¯š¢)ˆ‹šL‡Ş„œÉZ%×…n‹a<çq™ô•’;Š=•º•„•|™m8ˆŒ¥µ•ö˜›të†(‘‘K‹ÆÒ™Z–dš‰ˆS–z…ı™‘™Á™©™©Œ=Mëğ—ª™©ˆ£‰ˆ…b”ê—3•¢)(2…V–ëœ¶"·œ+–Ék@2ƒ/y9“–d•ã˜¡‚Ğ‘jœ7“1––™a0é†’=)‹ºˆ>œ+»œ’¯€g—€E=)œ[–]µ˜‹0ïø”ŠB«…4S‘v›´•ã™N™Á–d…‘‘>µ™Á€Ö…ç™@‘éŒ¸›„0š–†“=“›†>ä–GÑ=ï‚Ä“S‘¦=)šá=†bˆÑ’(Ã’(—F=ï=k–1/.oƒŠ'˜C€î†õ“=E3î›œOî)’nˆ”\ÒY†(ˆ2†(™µ‚|”,å‰0éœCŒIŒ¸˜›ó”o…™…Î•Q‘W™GZ‡-(%“Ùä…Û‘"–d‹a„œË‚N=ŒÑ),%y—Ã‹m•œ	ŠU•Ğ” †’…Lœ[Œƒ˜O‡)u™y,ˆ.G<ç€ˆQ‡å–—˜¶€9‘.‹ˆ—"”µ”®€9ú@˜<‰ùƒ±ˆÅ’İy¸‰d›D’œ‡6•ıŠ®‚ZˆÑ<„•ï)(†>”~9&i“ñ‚B€(œşˆ	ü†(„T…@‹…(Š'›Çšáœ>R=)ŠŠ‰-–14è‚ò„•	€EŠU|÷” ›İŠa=Î€g–÷vŠ–‚‡Bƒ;ˆÿ›»‡ÈÎ<ç‹=Œ.İó˜V†z‘„¾˜îˆéŠŒ1,ï‰ˆ‹›óëf˜Cÿ<„šË'<ç–%‚‡a–÷x`‚¸…Åˆ	Ã4‡ŠšËŠ¢‚‡ŒH–GŒa’4¤‰ˆ…¹=›İ˜â‚6š…=)<„’Ç–z+<„šš–Œa—s“µø‡°•ãŒ÷†õ†zQ(œnÂˆ>Œ‹U€E„=)–‹Ü‘î-'…z&'––Õ’é+)„—:šw‡˜»˜u`›¦—'„âˆ>ËŒƒ‰½–G=–Â—’>”»˜À„¨ƒ±”8‹‰!’‰½š@‚|ˆéáÒ–ªšá=ï‰E’“i„¾‡€˜¹†”hi˜ô”D’œœ[,ˆÿ€g‹›‚œÜ”µ2D—’éˆÑ<„–z‚æ‰ˆ¢˜uŒm’;’„Œ€“Û–ó˜Àv‚Ğ=)„øœCš¢Ÿ‚‡¼‡Ş„=Îš¿Š'ŠËat†ŠœµœC•4„¨…²˜î•ºˆÅ™Á=)b–<…‹®1” –G4ˆQ…ìˆ=—T$÷‚p‹a–‚B’éˆÿ‰9‡N‹ş›Ñ‰!“‚Ä&'„09ÈŠaŠUÇšË‘îœ	“È—öŒ>1ƒSˆQ“›ÇÄ“=•Ü›DŒ=Œ…)	Š—‹3–1…‡*“ˆšL‹¢˜=ï‡¤…ˆ	Š=™=ï”ö•|€Ê“Ûz˜­€­.‹è}l’Q™µŠ®üá(›ó‹?‡ıœ‚ •)+›h€gœ‹ÆŒ«¨—Í˜À›v™Ş™yU•J˜yôˆQ‚Ğ…(€Ö“‘¦˜Ö›‚‘Ï¤?9˜õİšL’`Nn‹®&™-•4ˆs˜C“ÿ(™Z”¢‘j‹ƒœO›{„(•ˆ€óŠá˜â–1?ÿœ›6D-*”¢”~š-W,˜CŠwd›*”,E6$ƒ/š¢œg‡Z”oš¿ˆ¯‚Š®™yŒƒšXœÜší…Û†n…L–¶‚B€9’»š–ô‘‘‚´€‰‚ş?½“S›İ1ÈŒ‹'“Ûô€gr€gŠZ’;ÇLŠáÇ±†ßì„H€[ƒ‹?—g›P’İŠéí†±ŠÄ‡€œC€[”µŠË?ÿ,ı†õ—¸†n>s,ñ•	í=Œ˜‹’İ†š!ˆ	_†V—)î˜=Œøˆs—Í]]
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
local function ORMI_UpdateSlice(indic, selected, tok, usable, state, icon, _, count, cd, cd2, tf, ta, ext)
	state, icon, ext = state or 0, ORI_icon[tok] or icon  or "Interface/Icons/INV_Misc_QuestionMark", not ORI_icon[tok] and ext or nil
	local active, overlay, faded, usableCharge = state % 2 > 0, state % 4 > 1, not usable, usable or (state % 128 >= 64)
	local c, ok, r,g,b = faded and 0.5 or 1
	indic:SetIcon(icon)
	if ext then
		indic:SetIconTexCoord(check(pcall(extractAux, ext, "coord")))
		ok, r,g,b = pcall(extractAux, ext, "color", c)
	end
	indic:SetIconVertexColor(r or c, g or c, b or c)
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
	local _, _, _, ghostCount = OneRingLib:GetOpenRingSlice(slice or 0);
	if (ghostCount or 0) == 0 then return GhostIndication:Deactivate(); end
	local scaleM = ORI_ConfigCache.MIScale and 1.10 or 1;
	local group = GhostIndication:ActivateGroup(slice, ghostCount, 90 - 360/count*(slice-1) - offset, self.radius*scaleM, 1.10);
	for i=2,ghostCount do
		ORMI_UpdateSlice(group[i], false, OneRingLib:GetOpenRingSliceAction(slice, i));
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
				ORMI_UpdateSlice(ORI_Slices[i], si == i, OneRingLib:GetOpenRingSliceAction(i));
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