-- Scorchio! 2, A multi-mob vulnerability manager
-- Copyright (C) 2008-2009  ennui@bloodhoof-eu, ennuilg@gmail.com
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 3
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <http://www.gnu.org/licenses/>.

-- GLOBALS: pairs

-- Upgrading the database is in the Options UI, because the logic here could grow very large, especially
-- if it starts including old defaults tables.
function Scorchio2:UpgradeDatabase(sv, DBVERSION)
	-- TODO: upgrade functions should be nil'd at some point. Probably by InitOptions though.
	local oldVersion = sv.dbversion or 0
	if oldVersion < 1 then
		-- Version 1 cleaned up unused Winter's Chill and Arcane Blast options.
		for _,prof in pairs(sv.profiles or {}) do
			-- Winter's Chill removed
			if prof.baroptions then
				prof.baroptions.b = nil
			end
			-- Many Arcane Blast options removed
			if prof.baroptions and prof.baroptions.i then
				local i = prof.baroptions.i
				i.message = nil
				i.warning = nil
				i.showwarning = nil
				i.showexpire = nil
				i.warningtime = nil
				i.soundson = nil
				i.procsound = nil
				i.warningsound = nil
				i.expiredsound = nil
			end
		end
	end
	if oldVersion < 2 then
		-- Version 2 cleans up anchoroptions and baroptions, so that all children have similar semenatics. This
		-- will let us use AceDB's inheritence features in the new defaults table.
		for _,prof in pairs(sv.profiles or {}) do
			-- Very old versions stored the anchor data in baroptions, back when there was only a single anchor.
			-- It's totally unused now and should be stripped from SVs.
			if prof.baroptions then
				for k,_ in pairs(prof.baroptions) do
					-- Remove any key with length > 1. The exact list of keys, if anyone cares, can be found in
					-- v1.0.4's defaults table. But this works just as well and is clearer.
					if #k > 1 then
						prof.baroptions[k] = nil
					end
				end
			end
			-- Move "custom anchors" setting out of anchoroptions, since it's nothing like anchoroptions' other children.
			if prof.anchoroptions then
				prof.custom_anchors = prof.anchoroptions.custom
				prof.anchoroptions.custom = nil
			end
		end
	end
	if oldVersion < 3 then
		-- Adding settings for Nether Tempest and Frost Bomb, based on Living Bomb
		for _,prof in pairs(sv.profiles or {}) do
			if prof.baroptions and prof.baroptions.c then
				-- We have special settings for Living Bomb. Copy them over.
				prof.baroptions.x = {} -- Nether Tempest
				prof.baroptions.y = {} -- Frost Bomb
				for i,j in pairs(prof.baroptions.c) do
					prof.baroptions.x[i] = j
					prof.baroptions.y[i] = j
					-- Make sure Frost Bomb doesn't get warningtime > 5
					if prof.baroptions.y.warningtime and prof.baroptions.y.warningtime > 5 then
						prof.baroptions.y.warningtime = 5
					end
				end
			end
		end
	end
	if oldVersion < 4 then
		-- Removing settings for spells removed in patch 5.0.
		for _,prof in pairs(sv.profiles or {}) do
			if prof.baroptions then
				prof.baroptions.a = nil -- Critical Mass
				prof.baroptions.h = nil -- Clearcasting
				prof.baroptions.l = nil -- Shadow Mastery
				prof.baroptions.o = nil -- Torment the Weak
				prof.baroptions.r = nil -- Impact
				prof.baroptions.s = nil -- Improved Polymorph
				prof.baroptions.w = nil -- Improved Flamestrike
			end
		end
	end
	if oldVersion < 5 then
		-- Heating Up is new. Try to make it default like Pyroblast!.
		for _,prof in pairs(sv.profiles or {}) do
			if prof.baroptions and prof.baroptions.f then
				prof.baroptions.h = {} -- Heating Up
				local pyro = prof.baroptions.f
				local heatingup = prof.baroptions.h
				for i,j in pairs(pyro) do
					heatingup[i] = j
				end
				-- Remove settings that might be odd if copied.
				heatingup.apply = nil
				heatingup.message = nil
				heatingup.warning = nil
				heatingup.bar = nil
				heatingup.fg = nil
				heatingup.bg = nil
			end
		end
	end
	if oldVersion < 6 then
		-- Pyromaniac is new. Try to make it default like Living Bomb.
		for _,prof in pairs(sv.profiles or {}) do
			if prof.baroptions and prof.baroptions.c then
				prof.baroptions.a = {} -- Pyromaniac
				local livingbomb = prof.baroptions.c
				local pryomaniac = prof.baroptions.a
				for i,j in pairs(livingbomb) do
					pryomaniac[i] = j
				end
				-- Remove settings that might be odd if copied.
				pryomaniac.message = nil
				pryomaniac.warning = nil
				pryomaniac.bar = nil
				pryomaniac.fg = nil
				pryomaniac.bg = nil
			end
		end
	end
	if oldVersion < 7 then
		-- Frost Bomb changed from debuff to cooldown.
		for _,prof in pairs(sv.profiles or {}) do
			if prof.baroptions and prof.baroptions.y then
				local frostbomb = prof.baroptions.y
				frostbomb.warning = nil
				frostbomb.warningtime = nil
				frostbomb.warningsound = nil
				frostbomb.showwarning = nil
				frostbomb.clearooc = nil
				local FoF = prof.baroptions.k -- Copy anchors from Fingers of Frost.
				if FoF and FoF.nontargetanchor then
					frostbomb.nontargetanchor = FoF.nontargetanchor
					frostbomb.targetanchor = FoF.nontargetanchor -- Copy nontargetanchor to both. They're the same anyway.
				else
					frostbomb.nontargetanchor = nil
					frostbomb.targetanchor = nil
				end
			end
		end
	end
	if oldVersion < 8 then
		-- Invocation is new. Try to make it default like Pyroblast!.
		for _,prof in pairs(sv.profiles or {}) do
			if prof.baroptions and prof.baroptions.f then
				prof.baroptions.w = {} -- Invocation
				local pyro = prof.baroptions.f
				local invocation = prof.baroptions.w
				for i,j in pairs(pyro) do
					invocation[i] = j
				end
				-- Remove settings that might be odd if copied.
				invocation.apply = nil
				invocation.message = nil
				invocation.warning = nil
				invocation.bar = nil
				invocation.fg = nil
				invocation.bg = nil
				-- Tracking to its default (on) so the user learns about the new feature.
				invocation.track = nil
				invocation.show = nil
				-- Don't copy clear-OOC; Invocation is long and unlike Pyroblast! in this.
				invocation.clearooc = nil
			end
		end
	end
	if oldVersion < DBVERSION then
		sv.dbversion = DBVERSION
	end
end
