local _, me = ...                                 --Includes all functions and variables
local spellname,_,icon = GetSpellInfo(13262)

--if not me:GetProfs()[spellname] then return end

me.quicktradeskills.disenchant = {}

me.quicktradeskills.disenchant.name,me.quicktradeskills.disenchant.icon = spellname,icon

me.quicktradeskills.disenchant.func = function()
  local result={}
  for i=0, NUM_BAG_SLOTS do
   for j=1, GetContainerNumSlots(i) do
    if GetContainerItemID(i,j) then
     local texture, itemCount, _, quality, _ = GetContainerItemInfo(i, j)
     local itemlink = GetContainerItemLink(i,j)
     local _,_,_,_,itemMinLevel,itemType,itemSubType = GetItemInfo(GetContainerItemID(i,j))
     if (itemType==ENCHSLOT_WEAPON or itemType==ARMOR) and (quality>1 and quality<5) then
      result[quality.."-"..strmatch(itemlink,"|h%[(.+)%]|h").."-"..i.."-"..j] = {
       name="|c"..select(4,GetItemQualityColor(quality))..strmatch(itemlink,"|h%[(.+)%]|h").."|r",
       icon=texture,
       action={["type1"]="macro",macrotext="/script if(GetCVar('AutoLootDefault')=='0') then BPMAutoloot=true end\n/cast "..spellname.."\n/use "..i.." "..j},
       tooltip=function()
        self = GameTooltip:GetOwner()
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:SetPoint(me:GetTipAnchor2(self))
        GameTooltip:ClearLines()
        GameTooltip:SetHyperlink(itemlink)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(me.L["leftclick"]..": "..spellname..me.L["autoloot"],0,1,0)
        local first=true
        for k,v in pairs(me.quicktradeskills.disenchant.enchantlist[itemType][quality]) do
         if itemMinLevel>=v.low and itemMinLevel<=v.hight then
          if first then
           GameTooltip:AddLine(" ")
           GameTooltip:AddLine(me.L["possiblereagents"])
          end
          first=nil
          local name="---"
          local color="ffffffff"
          if GetItemInfo(k) then
           name = select(1,GetItemInfo(k))
           color = select(4,GetItemQualityColor(select(3,GetItemInfo(k))))
          elseif me.quicktradeskills.disenchant.defaultname[k] then
           name = me.quicktradeskills.disenchant.defaultname[k]
          end
          if v.only then
           GameTooltip:AddLine("|c"..color..name.."|r ("..v.only..")")
          else
           GameTooltip:AddLine("|c"..color..name.."|r")
          end
          if GetItemInfo(k) then
           GameTooltip:AddTexture(strmatch(select(10,GetItemInfo(k)),"^(.+)"))
          end
         end
        end
       end
      }
     end
    end
   end
  end
  return result
end



me.quicktradeskills.disenchant.enchantlist = {
	[ARMOR] = {
		[2] = {
			[10940] = {low=1,hight=20},
			[11083] = {low=21,hight=30},
			[11137] = {low=31,hight=40},
			[11176] = {low=41,hight=50},
			[16204] = {low=51,hight=60},
			[22445] = {low=57,hight=70,only="BC"},
			[34054] = {low=67,hight=80,only="WotLk"},
			[52555] = {low=79,hight=85,only="Cata"},
		},
		[3] = {
			[10978] = {low=1,hight=20},
			[11084] = {low=21,hight=25},
			[11138] = {low=26,hight=30},
			[11139] = {low=31,hight=35},
			[11177] = {low=36,hight=40},
			[11178] = {low=41,hight=45},
			[14343] = {low=46,hight=50},
			[14344] = {low=51,hight=60},
			[22448] = {low=60,hight=64,only="BC"},
			[22449] = {low=65,hight=70,only="BC"},
			[34053] = {low=69,hight=77,only="WotLk"},
			[34052] = {low=75,hight=80,only="WotLk"},
			[52720] = {low=79,hight=83,only="Cata"},
			[52721] = {low=82,hight=85,only="Cata"},
		},
		[4] = {
			[20725] = {low=51,hight=60},
			[22450] = {low=70,hight=70,only="BC"},
			[34057] = {low=80,hight=80,only="WotLk"},
			[52722] = {low=85,hight=85,only="Cata"},
		},
	},
	[ENCHSLOT_WEAPON] = {
		[2] = {
			[10938] = {low=1,hight=10},
			[10939] = {low=11,hight=15},
			[10998] = {low=16,hight=20},
			[11082] = {low=21,hight=25},
			[11134] = {low=26,hight=30},
			[11135] = {low=31,hight=35},
			[11174] = {low=36,hight=40},
			[11175] = {low=41,hight=45},
			[16202] = {low=46,hight=50},
			[16203] = {low=51,hight=60},
			[22447] = {low=59,hight=63,only="BC"},
			[22446] = {low=64,hight=70,only="BC"},
			[34056] = {low=67,hight=72,only="WotLk"},
			[34055] = {low=73,hight=80,only="WotLk"},
			[52718] = {low=79,hight=83,only="Cata"},
			[52719] = {low=82,hight=85,only="Cata"},
		},
		[3] = {
			[10978] = {low=1,hight=20},
			[11084] = {low=21,hight=25},
			[11138] = {low=26,hight=30},
			[11139] = {low=31,hight=35},
			[11177] = {low=36,hight=40},
			[11178] = {low=41,hight=45},
			[14343] = {low=46,hight=50},
			[14344] = {low=51,hight=60},
			[22448] = {low=60,hight=64,only="BC"},
			[22449] = {low=65,hight=70,only="BC"},
			[34053] = {low=69,hight=77,only="WotLk"},
			[34052] = {low=75,hight=80,only="WotLk"},
			[52720] = {low=79,hight=83,only="Cata"},
			[52721] = {low=82,hight=85,only="Cata"},
		},
		[4] = {
			[20725] = {low=51,hight=60},
			[22450] = {low=70,hight=70,only="BC"},
			[34057] = {low=80,hight=80,only="WotLk"},
			[52722] = {low=85,hight=85,only="Cata"},
		},
	},
}



me.quicktradeskills.disenchant.defaultname = {
	--Dust
	[10940] = "Strange Dust",
	[11083] = "Soul Dust",
	[11137] = "Vision Dust",
	[11176] = "Dream Dust",
	[16204] = "Illusion Dust",
	[22445] = "Arcane Dust",
	[34054] = "Infinite Dust",
	[52555] = "Hypnotic Dust",
	--Essence
	[10938] = "Lesser Magic Essence",
	[10939] = "Greater Magic Essence",
	[10998] = "Lesser Astral Essence",
	[11082] = "Greater Astral Essence",
	[11134] = "Lesser Mystic Essence",
	[11135] = "Greater Mystic Essence",
	[11174] = "Lesser Nether Essence",
	[11175] = "Greater Nether Essence",
	[16202] = "Lesser Eternal Essence",
	[16203] = "Greater Eternal Essence",
	[22447] = "Lesser Planar Essence",
	[22446] = "Greater Planar Essence",
	[34056] = "Lesser Cosmic Essence",
	[34055] = "Greater Cosmic Essence",
	[52718] = "Lesser Celestial Essence",
	[52719] = "Greater Celestial Essence",
	--Shard
	[10978] = "Small Glimmering Shard",
	[11084] = "Large Glimmering Shard",
	[11138] = "Small Glowing Shard",
	[11139] = "Large Glowing Shard",
	[11177] = "Small Radiant Shard",
	[11178] = "Large Radiant Shard",
	[14343] = "Small Brilliant Shard",
	[14344] = "Large Brilliant Shard",
	[22448] = "Small Prismatic Shard",
	[22449] = "Large Prismatic Shard",
	[34053] = "Small Dream Shard",
	[34052] = "Dream Shard",
	[52720] = "Small Heavenly Shard",
	[52721] = "Heavenly Shard",
	--Cristals
	[20725] = "Nexus Crystal",
	[22450] = "Void Crystal",
	[34057] = "Abyss Crystal",
	[52722] = "Maelstrom Crystal",
}