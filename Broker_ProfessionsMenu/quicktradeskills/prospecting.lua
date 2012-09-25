local _, me = ...                                 --Includes all functions and variables
local spellname,_,icon = GetSpellInfo(31252)

--if not me:GetProfs()[spellname] then return end

me.quicktradeskills.prospecting = {}

me.quicktradeskills.prospecting.name,me.quicktradeskills.prospecting.icon = spellname,icon

me.quicktradeskills.prospecting.func=function()
  local result={}
  for i=0, NUM_BAG_SLOTS do
   for j=1, GetContainerNumSlots(i) do
    if GetContainerItemID(i,j) then
     local texture, itemCount = GetContainerItemInfo(i, j)
     local itemlink = GetContainerItemLink(i,j)
     local itemName,_,_,_,itemMinLevel = GetItemInfo(GetContainerItemID(i,j))
     if me.quicktradeskills.prospecting.minerals[GetContainerItemID(i,j)] and itemCount>=5 then
      result[itemName.."-"..i.."-"..j] = {
       name=itemName.." ("..itemCount..")",
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
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(me.L["possiblereagents"])
        for k,v in pairs(me.quicktradeskills.prospecting.minerals[GetContainerItemID(i,j)]) do
         local name="---"
         local color="ffffffff"
         if GetItemInfo(v) then
          name = select(1,GetItemInfo(v))
          color = select(4,GetItemQualityColor(select(3,GetItemInfo(v))))
         elseif me.quicktradeskills.prospecting.mineralnames[v] then
          name = me.quicktradeskills.prospecting.mineralnames[v]
         end
         GameTooltip:AddLine("|c"..color..name.."|r")
        end
       end
      } 
     end
    end
   end
  end
  return result
end

me.quicktradeskills.prospecting.minerals = {
	[2770]={774,818},
	[2771]={1705,1206,1210,},
	[2772]={1529,3864,1705},
	[3858]={7909,3864,7910},
	[10620]={12800,12361,12364,12799},
	--BC
	[23424]={23117,23077,21929,23112,23107,23079,23440,23439,23436,23441,23438,23437},
	[23425]={24243,23117,23077,21929,23112,23107,23079,23440,23439,23436,23441,23438,23437},
	--WotLK
	[36909]={36917,36923,36932,36929,36926,36920,36921,36924,36930,36918,36933,36927},
	[36912]={36917,36923,36932,36929,36926,36920,36921,36924,36930,36918,36933,36927},
	[36910]={46849,36917,36923,36932,36929,36926,36920,36921,36924,36930,36918,36933,36927,36931,36934,36925,36919,36922,36928},
	--Cata
	[53038]={52181,52177,52180,52178,52182,52179,52194,52190,52193,52195,52192,52191},  --Obsidiumerz
	[52185]={52181,52177,52180,52178,52182,52179,52194,52190,52193,52195,52192,52191},  --Elementiumerz
	[52183]={52327,52181,52177,52180,52178,52182,52179,52194,52190,52193,52195,52192,52191},  --Pyriterz
}

me.quicktradeskills.prospecting.mineralnames = {
	[12364] = "Huge Emerald",
	[12800] = "Azerothian Diamond",
	[12361] = "Blue Sapphire",
	[12799] = "Large Opal",
	[7910] = "Star Ruby",
	[7909] = "Aquamarine",
	[3864] = "Citrine",
	[1529] = "Jade",
	[1705] = "Lesser Moonstone",
	[1206] = "Moss Agate",
	[1210] = "Shadowgem",
	[818] = "Tigerseye",
	[774] = "Malachite",
	--BC
	[24243] = "Adamantite Powder",
	[36917] = "Bloodstone",
	[36920] = "Sun Crystal",
	[36923] = "Chalcedony",
	[36926] = "Shadow Crystal",
	[36929] = "Huge Citrine",
	[36932] = "Dark Jade",
	[21929] = "Flame Spessarite",
	[23077] = "Blood Garnet",
	[23079] = "Deep Peridot",
	[23107] = "Shadow Draenite",
	[23112] = "Golden Draenite",
	[23117] = "Azure Moonstone",
	--WotLK
	[36918] = "Scarlet Ruby",
	[36921] = "Autumn's Glow",
	[36924] = "Sky Sapphire",
	[36927] = "Twilight Opal",
	[36930] = "Monarch Topaz",
	[36933] = "Forest Emerald",
	[23436] = "Living Ruby",
	[23437] = "Talasite",
	[23438] = "Star of Elune",
	[23439] = "Noble Topaz",
	[23440] = "Dawnstone",
	[23441] = "Nightseye",
	[36919] = "Cardinal Ruby",
	[36922] = "King's Amber",
	[36925] = "Majestic Zircon",
	[36928] = "Dreadstone",
	[36931] = "Ametrine",
	[36934] = "Eye of Zul",
	--Cata
	[52327] = "Volatile Earth",
	[52181] = "Hessonite",
	[52177] = "Carnelian",
	[52180] = "Nightstone",
	[52178] = "Zephyrite",
	[52182] = "Jasper",
	[52179] = "Alicite",
	[52194] = "Demonseye",
	[52190] = "Inferno Ruby",
	[52193] = "Ember Topaz",
	[52195] = "Amberjewel",
	[52192] = "Dream Emerald",
	[52191] = "Ocean Sapphire",
}