if not LibStub then return end

local dewdrop = LibStub('Dewdrop-2.0', true)
local icon = LibStub('LibDBIcon-1.0')

local _
local math_floor = math.floor

local CreateFrame = CreateFrame
local GetContainerItemCooldown = GetContainerItemCooldown
local GetContainerItemInfo = GetContainerItemInfo
local GetContainerItemLink = GetContainerItemLink
local GetContainerNumSlots = GetContainerNumSlots
local GetBindLocation = GetBindLocation
local GetInventoryItemCooldown = GetInventoryItemCooldown
local GetInventoryItemLink = GetInventoryItemLink
local GetSpellCooldown = GetSpellCooldown
local GetSpellInfo = GetSpellInfo
local GetSpellBookItemName = GetSpellBookItemName
local SendChatMessage = SendChatMessage
local UnitInRaid = UnitInRaid
local GetNumGroupMembers = GetNumGroupMembers
local IsPlayerSpell = IsPlayerSpell

local addonName, addonTable = ...
local L = addonTable.L
 
-- IDs of items usable for transportation
local items = {
  -- Dalaran rings
  40586, -- Band of the Kirin Tor
  48954, -- Etched Band of the Kirin Tor
  48955, -- Etched Loop of the Kirin Tor
  48956, -- Etched Ring of the Kirin Tor
  48957, -- Etched Signet of the Kirin Tor
  45688, -- Inscribed Band of the Kirin Tor
  45689, -- Inscribed Loop of the Kirin Tor
  45690, -- Inscribed Ring of the Kirin Tor
  45691, -- Inscribed Signet of the Kirin Tor
  44934, -- Loop of the Kirin Tor
  44935, -- Ring of the Kirin Tor
  40585, -- Signet of the Kirin Tor
  51560, -- Runed Band of the Kirin Tor
  51558, -- Runed Loop of the Kirin Tor
  51559, -- Runed Ring of the Kirin Tor
  51557, -- Runed Signet of the Kirin Tor
  -- Engineering Gadgets
  30542, -- Dimensional Ripper - Area 52
  18984, -- Dimensional Ripper - Everlook
  18986, -- Ultrasafe Transporter: Gadgetzan
  30544, -- Ultrasafe Transporter: Toshley's Station
  48933, -- Wormhole Generator: Northrend
  87215, -- Wormhole Generator: Pandaria
  -- Seasonal items
  37863, -- Direbrew's Remote
  21711, -- Lunar Festival Invitation
  -- Miscellaneous
  46874, -- Argent Crusader's Tabard
  32757, -- Blessed Medallion of Karabor
  35230, -- Darnarian's Scroll of Teleportation
  50287, -- Boots of the Bay
  52251, -- Jaina's Locket
  43824, -- The Schools of Arcane Magic - Mastery
  58487, -- Potion of Deepholm
  65274, -- Cloak of Coordination (Horde)
  65360, -- Cloak of Coordination (Alliance)
  63378, -- Hellscream's Reach Tabard
  63379, -- Baradin's Wardens Tabard
  64457, -- The Last Relic of Argus
  63206, -- Wrap of Unity (Alliance)
  63207, -- Wrap of Unity (Horde)
  63352, -- Shroud of Cooperation (Alliance)
  63353  -- Shroud of Cooperation (Horde)
}

-- IDs of items usable instead of hearthstone
local scrolls = {
  64488, -- The Innkeeper's Daughter
  28585, -- Ruby Slippers
  6948,  -- Hearthstone
  44315, -- Scroll of Recall III
  44314, -- Scroll of Recall II
  37118  -- Scroll of Recall
}

obj = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject(addonName, {
  type = 'data source',
  text = L['P'],
  icon = 'Interface\\Icons\\INV_Misc_Rune_06',
})
local obj = obj
local methods	= {}
local portals	= nil
local frame = CreateFrame('frame')

frame:SetScript('OnEvent', function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)
frame:RegisterEvent('PLAYER_LOGIN')
frame:RegisterEvent('SKILL_LINES_CHANGED')


local function pairsByKeys(t)
  local a = {}
  for n in pairs(t) do
    table.insert(a, n)
  end
  table.sort(a)

  local i = 0
  local iter = function ()
    i = i + 1
    if a[i] == nil then
      return nil
    else
      return a[i], t[a[i]]
    end
  end
  return iter
end

function findSpell(spellName)
  local i = 1
  while true do
    local s = GetSpellBookItemName(i, BOOKTYPE_SPELL)
    if not s then
      break
    end

    if s == spellName then
      return i
    end

    i = i + 1
  end
end

-- returns true, if player has item with given ID in inventory or bags and it's not on cooldown
local function hasItem(itemID)
  local item, found, id
  -- scan inventory
  for slotId = 1, 19 do
    item = GetInventoryItemLink('player', slotId)
    if item then
      found, _, id = item:find('^|c%x+|Hitem:(%d+):.+')
      if found and tonumber(id) == itemID then
        if GetInventoryItemCooldown('player', slotId) ~= 0 then
          return false
        else
          return true
        end
      end
    end
  end
  -- scan bags
  for bag = 0, 4 do
    for slot = 1, GetContainerNumSlots(bag) do
      item = GetContainerItemLink(bag, slot)
      if item then
        found, _, id = item:find('^|c%x+|Hitem:(%d+):.+')
        if found and tonumber(id) == itemID then
          if GetContainerItemCooldown(bag, slot) ~= 0 then
            return false
          else
            return true
          end
        end
      end
    end
  end

  return false
end

local function getReagentCount(name)
  local count = 0
  for bag = 0, 4 do
    for slot = 1, GetContainerNumSlots(bag) do
      local item = GetContainerItemLink(bag, slot)
      if item then
        if item:find(name) then
          local _, itemCount = GetContainerItemInfo(bag, slot)
          count = count + itemCount
        end
      end
    end
  end

  return count
end

local function SetupSpells()
  local spells = {
    Alliance = {
      {3561, 'TP_RUNE'},   -- TP:Stormwind
      {3562, 'TP_RUNE'},   -- TP:Ironforge
      {3565, 'TP_RUNE'},   -- TP:Darnassus
      {32271, 'TP_RUNE'},  -- TP:Exodar
      {49359, 'TP_RUNE'},  -- TP:Theramore
      {33690, 'TP_RUNE'},  -- TP:Shattrath
      {53140, 'TP_RUNE'},  -- TP:Dalaran
      {88342, 'TP_RUNE'},  -- TP:Tol Barad
      {132621, 'TP_RUNE'}, -- TP:Vale of Eternal Blossoms
      {120145, 'TP_RUNE'}, -- TP:Ancient Dalaran
      {10059, 'P_RUNE'},   -- P:Stormwind
      {11416, 'P_RUNE'},   -- P:Ironforge
      {11419, 'P_RUNE'},   -- P:Darnassus
      {32266, 'P_RUNE'},   -- P:Exodar
      {49360, 'P_RUNE'},   -- P:Theramore
      {33691, 'P_RUNE'},   -- P:Shattrath
      {53142, 'P_RUNE'},   -- P:Dalaran
      {88345, 'P_RUNE'},   -- P:Tol Barad
      {132620, 'P_RUNE'},  -- P:Vale of Eternal Blossoms
      {120146, 'P_RUNE'}   -- P:Ancient Dalaran
    },
    Horde = {
      {3563, 'TP_RUNE'},   -- TP:Undercity
      {3566, 'TP_RUNE'},   -- TP:Thunder Bluff
      {3567, 'TP_RUNE'},   -- TP:Orgrimmar
      {32272, 'TP_RUNE'},  -- TP:Silvermoon
      {49358, 'TP_RUNE'},  -- TP:Stonard
      {35715, 'TP_RUNE'},  -- TP:Shattrath
      {53140, 'TP_RUNE'},  -- TP:Dalaran
      {88344, 'TP_RUNE'},  -- TP:Tol Barad
      {132627, 'TP_RUNE'}, -- TP:Vale of Eternal Blossoms
      {11418, 'P_RUNE'},   -- P:Undercity
      {11420, 'P_RUNE'},   -- P:Thunder Bluff
      {11417, 'P_RUNE'},   -- P:Orgrimmar
      {32267, 'P_RUNE'},   -- P:Silvermoon
      {49361, 'P_RUNE'},   -- P:Stonard
      {35717, 'P_RUNE'},   -- P:Shattrath
      {53142, 'P_RUNE'},   -- P:Dalaran
      {88346, 'P_RUNE'},   -- P:Tol Barad
      {132626, 'P_RUNE'}   -- P:Vale of Eternal Blossoms
    }
  }

  local _, class = UnitClass('player')
  if class == 'MAGE' then
    portals = spells[select(1, UnitFactionGroup('player'))]
  elseif class == 'DEATHKNIGHT' then
    portals = {
      {50977, 'TRUE'} -- Death Gate
    }
  elseif class == 'DRUID' then
    portals = {
      {18960, 'TRUE'} -- TP:Moonglade
    }
  elseif class == 'SHAMAN' then
    portals = {
      {556, 'TRUE'} -- Astral Recall
    }
  else
    portals = {}
  end

  spells = nil
end

local function UpdateSpells()
  if not portals then
    SetupSpells()
  end

  if portals then
    for _,unTransSpell in ipairs(portals) do

      if IsPlayerSpell(unTransSpell[1]) then
        local spell, _, spellIcon = GetSpellInfo(unTransSpell[1])
        local spellid = findSpell(spell)

        if spellid then
          methods[spell] = {
            spellid = spellid,
            text = spell,
            spellIcon = spellIcon,
            isPortal = unTransSpell[2] == 'P_RUNE',
            secure = {
              type = 'spell',
              spell = spell
            }
          }
        end
      end
    end
  end
end

local function UpdateIcon(icon)
  obj.icon = icon
end

local function GetHearthCooldown()
  local cooldown, startTime, duration

  for _, item in pairs(scrolls) do
    if GetItemCount(item) > 0 then
      startTime, duration = GetItemCooldown(item)
      cooldown = duration - (GetTime() - startTime)
      if cooldown >= 60 then
        cooldown = math_floor( cooldown / 60 )
        cooldown = cooldown..' '..L['MIN']
      elseif cooldown <= 0 then
        cooldown = L['READY']
      else
        cooldown = math_floor(cooldown)..' '..L['SEC']
      end
      return cooldown
    end
  end

  return L['N/A']
end

local function GetItemCooldowns( )
  local cooldown, startTime, duration, cooldowns = nil, nil, nil, nil

  for _, item in pairs(items) do
    if GetItemCount( item ) > 0 then
      startTime, duration = GetItemCooldown(item)
      cooldown = duration - (GetTime() - startTime)
      if cooldown >= 60 then
        cooldown = math_floor(cooldown / 60)
        cooldown = cooldown..' '..L['MIN']
      elseif cooldown <= 0 then
        cooldown = L['READY']
      else
        cooldown = math_floor(cooldown)..' '..L['SEC']
      end
      local name = GetItemInfo(item)
      if cooldowns == nil then
        cooldowns = {}
      end
      cooldowns[name] = cooldown
    end
  end

  return cooldowns
end

local function ShowHearthstone()
  local bindLoc = GetBindLocation()
  local secure, text, icon, name

  for _, itemID in ipairs(scrolls) do
    if hasItem(itemID) then
      name, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
      text = L['INN']..' '..bindLoc
      secure = {
        type = 'item',
        item = name
      }
      break
    end
  end

  if secure ~= nil then
    dewdrop:AddLine(
      'text', text,
      'secure', secure,
      'icon', icon,
      'func', function() UpdateIcon(icon) end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine()
  end
end

local function ShowOtherItems()
  local i = 0

  for _, itemID in ipairs(items) do
    if hasItem(itemID) then
      local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
      local secure = {
        type = 'item',
        item = name
      }

      dewdrop:AddLine(
        'text', name,
        'secure', secure,
        'icon', icon,
        'func', function() UpdateIcon(icon) end,
        'closeWhenClicked', true
      )
      i = i + 1
    end
  end
  if i > 0 then
    dewdrop:AddLine()
  end
end

local function ToggleMinimap()
  local hide = not PortalsDB.minimap.hide
  PortalsDB.minimap.hide = hide
  if hide then
    icon:Hide('Broker_Portals')
  else
    icon:Show('Broker_Portals')
  end
end

local function UpdateMenu(level, value)
  if level == 1 then
    dewdrop:AddLine(
      'text', 	'Broker_Portals',
      'isTitle', 	true
    )

    methods = {}
    UpdateSpells()
    dewdrop:AddLine()
    local chatType = (UnitInRaid("player") and "RAID") or (GetNumGroupMembers() > 0 and "PARTY") or nil
    local announce = PortalsDB.announce
    for k,v in pairsByKeys(methods) do
      if v.secure and GetSpellCooldown(v.text) == 0 then
        dewdrop:AddLine(
          'text', v.text,
          'secure',	v.secure,
          'icon', v.spellIcon,
          'func', function()
              UpdateIcon(v.spellIcon)
              if announce and v.isPortal and chatType then
                SendChatMessage(L['ANNOUNCEMENT'] .. ' ' .. v.text, chatType)
              end
            end,
          'closeWhenClicked', true
        )
      end
    end

    dewdrop:AddLine()

    ShowHearthstone()

    if PortalsDB.showItems then
      ShowOtherItems()
    end

    dewdrop:AddLine(
      'text', L['OPTIONS'],
      'hasArrow', true,
      'value', 'options'
    )

    dewdrop:AddLine(
      'text', CLOSE,
      'tooltipTitle', CLOSE,
      'tooltipText', CLOSE_DESC,
      'closeWhenClicked', true
    )
  elseif level == 2 and value == 'options' then
    dewdrop:AddLine(
      'text', L['SHOW_ITEMS'],
      'checked', PortalsDB.showItems,
      'func', function() PortalsDB.showItems = not PortalsDB.showItems end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine(
      'text', L['SHOW_ITEM_COOLDOWNS'],
      'checked', PortalsDB.showItemCooldowns,
      'func', function() PortalsDB.showItemCooldowns = not PortalsDB.showItemCooldowns end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine(
      'text', L['ATT_MINIMAP'],
      'checked', not PortalsDB.minimap.hide,
      'func', function() ToggleMinimap() end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine(
      'text', L['ANNOUNCE'],
      'checked', PortalsDB.announce,
      'func', function() PortalsDB.announce = not PortalsDB.announce end,
      'closeWhenClicked', true
    )
  end
end

function frame:PLAYER_LOGIN()
  -- PortalsDB.minimap is there for smooth upgrade of SVs from old version
  if (not PortalsDB) or (PortalsDB.version == nil) then
    PortalsDB = {}
    PortalsDB.minimap = {}
    PortalsDB.minimap.hide = false
    PortalsDB.showItems = true
    PortalsDB.showItemCooldowns = true
    PortalsDB.announce = false
    PortalsDB.version = 4
  end

  -- upgrade from versions
  if PortalsDB.version == 3 then
    PortalsDB.announce = false
    PortalsDB.version = 4
  elseif PortalsDB.version == 2 then
    PortalsDB.showItemCooldowns = true
    PortalsDB.announce = false
    PortalsDB.version = 4
  elseif PortalsDB.version < 2 then
    PortalsDB.showItems = true
    PortalsDB.showItemCooldowns = true
    PortalsDB.announce = false
    PortalsDB.version = 4
  end

  if icon then
    icon:Register('Broker_Portals', obj, PortalsDB.minimap)
  end

  self:UnregisterEvent('PLAYER_LOGIN')
end

function frame:SKILL_LINES_CHANGED()
  UpdateSpells()
end

-- All credit for this func goes to Tekkub and his picoGuild!
local function GetTipAnchor(frame)
    local x, y = frame:GetCenter()
    if not x or not y then return 'TOPLEFT', 'BOTTOMLEFT' end
    local hhalf = (x > UIParent:GetWidth() * 2 / 3) and 'RIGHT' or (x < UIParent:GetWidth() / 3) and 'LEFT' or ''
    local vhalf = (y > UIParent:GetHeight() / 2) and 'TOP' or 'BOTTOM'
    return vhalf..hhalf, frame, (vhalf == 'TOP' and 'BOTTOM' or 'TOP')..hhalf
end

function obj.OnClick(self, button)
  GameTooltip:Hide()
  if button == 'RightButton' then
    dewdrop:Open(self, 'children', function(level, value) UpdateMenu(level, value) end)
  end
end

function obj.OnLeave()
  GameTooltip:Hide()
end

function obj.OnEnter(self)
   GameTooltip:SetOwner(self, 'ANCHOR_NONE')
  GameTooltip:SetPoint(GetTipAnchor(self))
  GameTooltip:ClearLines()

  GameTooltip:AddLine('Broker Portals')
  GameTooltip:AddDoubleLine(L['RCLICK'], L['SEE_SPELLS'], 0.9, 0.6, 0.2, 0.2, 1, 0.2)
  GameTooltip:AddLine(' ')
  GameTooltip:AddDoubleLine(L['HEARTHSTONE']..': '..GetBindLocation(), GetHearthCooldown(), 0.9, 0.6, 0.2, 0.2, 1, 0.2)

  if PortalsDB.showItemCooldowns then
    local cooldowns = GetItemCooldowns()
    if cooldowns ~= nil then
      GameTooltip:AddLine(' ')
      for name, cooldown in pairs( cooldowns ) do
        GameTooltip:AddDoubleLine(name, cooldown, 0.9, 0.6, 0.2, 0.2, 1, 0.2)
      end
    end
  end

  GameTooltip:Show()
end

-- slashcommand definition
SlashCmdList['BROKER_PORTALS'] = function() ToggleMinimap() end
SLASH_BROKER_PORTALS1 =  '/portals'
