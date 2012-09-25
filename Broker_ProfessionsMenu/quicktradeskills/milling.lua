local _, me = ...                                 --Includes all functions and variables
local spellname,_,icon = GetSpellInfo(51005)

--if not me:GetProfs()[spellname] then return end

me.quicktradeskills.milling = {}

me.quicktradeskills.milling.name,me.quicktradeskills.milling.icon = spellname,icon

me.quicktradeskills.milling.func=function()
  local result={}
  for i=0, NUM_BAG_SLOTS do
   for j=1, GetContainerNumSlots(i) do
    if GetContainerItemID(i,j) then
     local texture, itemCount = GetContainerItemInfo(i, j)
     local itemlink = GetContainerItemLink(i,j)
     local itemName,_,_,_,itemMinLevel = GetItemInfo(GetContainerItemID(i,j))
     if me.quicktradeskills.milling.herbs[GetContainerItemID(i,j)] and itemCount>=5 then
      result[itemName.."-"..i.."-"..j] = {
       name=itemName.." ("..itemCount..")",
       icon=texture,
       action={["type1"]="macro",macrotext="/script if(GetCVar('AutoLootDefault')=='0') then BPMAutoloot=true end\n/cast ".. spellname.."\n/use "..i.." "..j},
       tooltip=function()
        self = GameTooltip:GetOwner()
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:SetPoint(me:GetTipAnchor2(self))
        GameTooltip:ClearLines()
        GameTooltip:SetHyperlink(itemlink)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(me.L["leftclick"]..": ".. spellname..me.L["autoloot"],0,1,0)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(me.L["possiblereagents"])
        for k,v in pairs(me.quicktradeskills.milling.herbs[GetContainerItemID(i,j)]) do
         local name="---"
         local color="ffffffff"
         if GetItemInfo(v) then
          name = select(1,GetItemInfo(v))
          color = select(4,GetItemQualityColor(select(3,GetItemInfo(v))))
         elseif me.quicktradeskills.milling.pigmentnames[v] then
          name = me.quicktradeskills.milling.pigmentnames[v]
         end
         GameTooltip:AddLine("|c"..color..name.."|r")
         if GetItemInfo(v) then
          GameTooltip:AddTexture(strmatch(select(10,GetItemInfo(v)),"^(.+)"))
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

me.quicktradeskills.milling.herbs = {
	[2447]  = {39151},     --Friedensblume
	[765]   = {39151},     --Silberblatt
	[2449]  = {39151},     --Erdwurzel
	[785]   = {39334,43103},   --Maguskönigskraut
	[2452]  = {39334,43103},   --Flitzdistel
	[2450]  = {39334,43103},   --Wilddornrose
	[3820]  = {39334,43103},   --Würgetang
	[2453]  = {39334,43103},   --Beulengras
	[3369]  = {39338,43104},   --Grabmoos
	[3355]  = {39338,43104},   --Wildstahlblume
	[3356]  = {39338,43104},   --Königsblut
	[3357]  = {39338,43104},   --Lebenswurz
	[3818]  = {39339,43105},   --Blassblatt
	[3821]  = {39339,43105},   --Golddorn
	[3358]  = {39339,43105},   --Khadgars Schnurrbart
	[3819]  = {39339,43105},   --Winterbiss
	[4625]  = {39340,43106},   --Feuerblüte
	[8831]  = {39340,43106},   --Lila Lotus
	[8836]  = {39340,43106},   --Arthas' Tränen
	[8838]  = {39340,43106},   --Sonnengras
	[8845]  = {39340,43106},   --Geisterpilz
	[8839]  = {39340,43106},   --Blindkraut
	[8846]  = {39340,43106},   --Gromsblut
	[13464] = {39341,43107}, --Goldener Sansam
	[13463] = {39341,43107}, --Traumblatt
	[13465] = {39341,43107}, --Bergsilbersalbei
	[13466] = {39341,43107}, --Pestblüte
	[13467] = {39341,43107}, --Eiskappe
	--BC
	[22789] = {39342,43108}, --Terozapfen
	[22786] = {39342,43108}, --Traumwinde
	[22785] = {39342,43108}, --Teufelsgras
	[22787] = {39342,43108}, --Zottelkappe
	[22790] = {39342,43108}, --Urflechte
	[22793] = {39342,43108}, --Manadistel
	[22792] = {39342,43108}, --Alptraumranke
	--WotLK
	[22791] = {39342,43108}, --Netherblüte
	[37921] = {39343,43109}, --Brennnessel
	[36907] = {39343,43109}, --Talandras Rose
	[36904] = {39343,43109}, --Tigerlilie
	[36901] = {39343,43109}, --Goldklee
	[36903] = {39343,43109}, --Schlangenzunge
	[36906] = {39343,43109}, --Eisdorn
	[36905] = {39343,43109}, --Lichblüte
	--Cata
	[52983] = {61979,61980}, --Aschenblüte
	[52984] = {61979,61980}, --Sturmwinde
	[52985] = {61979,61980}, --Azsharas Schleier
	[52986] = {61979,61980}, --Herzblüte
	[52987] = {61979,61980}, --Schattenjasmin
	[52988] = {61979,61980}, --Gertenrohr
	[52989] = {61979,61980}, --Deathspore Pod
}

me.quicktradeskills.milling.pigmentnames = {--if GetItemInfo returns nil
	[39341] = "Silvery Pigment",
	[39340] = "Violet Pigment",
	[39339] = "Emerald Pigment",
	[39338] = "Golden Pigment",
	[39334] = "Dusky Pigment",
	[39151] = "Alabaster Pigment",
	[43107] = "Sapphire Pigment",
	[43106] = "Ruby Pigment",
	[43105] = "Indigo Pigment",
	[43104] = "Burnt Pigment",
	[43103] = "Verdant Pigment",
	--BC
	[39342] = "Nether Pigment",
	[43108] = "Ebon Pigment",
	--WotLK
	[39343] = "Azure Pigment",
	[43109] = "Icy Pigment",
	--Cata
	[61979] = "Ashen Pigment",
	[61980] = "Burning Embers",
}