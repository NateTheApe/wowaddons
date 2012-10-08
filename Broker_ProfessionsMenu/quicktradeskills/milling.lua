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
        GameTooltip:AddLine(me.quicktradeskills.milling.herbs[GetContainerItemID(i,j)])	--Add Addon Name
       end
      }
     end
    end
   end
  end
  return result
end

me.quicktradeskills.milling.herbs = {
	[2447]  = "Classic",						--Friedensblume
	[765]   = "Classic",						--Silberblatt
	[2449]  = "Classic",						--Erdwurzel
	[785]   = "Classic",						--Maguskönigskraut
	[2452]  = "Classic",						--Flitzdistel
	[2450]  = "Classic",						--Wilddornrose
	[3820]  = "Classic",						--Würgetang
	[2453]  = "Classic",						--Beulengras
	[3369]  = "Classic",						--Grabmoos
	[3355]  = "Classic",						--Wildstahlblume
	[3356]  = "Classic",						--Königsblut
	[3357]  = "Classic",						--Lebenswurz
	[3818]  = "Classic",						--Blassblatt
	[3821]  = "Classic",						--Golddorn
	[3358]  = "Classic",						--Khadgars Schnurrbart
	[3819]  = "Classic",						--Winterbiss
	[4625]  = "Classic",						--Feuerblüte
	[8831]  = "Classic",						--Lila Lotus
	[8836]  = "Classic",						--Arthas' Tränen
	[8838]  = "Classic",						--Sonnengras
	[8845]  = "Classic",						--Geisterpilz
	[8839]  = "Classic",						--Blindkraut
	[8846]  = "Classic",						--Gromsblut
	[13464] = "Classic",						--Goldener Sansam
	[13463] = "Classic",						--Traumblatt
	[13465] = "Classic",						--Bergsilbersalbei
	[13466] = "Classic",						--Pestblüte
	[13467] = "Classic",						--Eiskappe
	[22789] = "Burning Crusade",			--Terozapfen
	[22786] = "Burning Crusade",			--Traumwinde
	[22785] = "Burning Crusade",			--Teufelsgras
	[22787] = "Burning Crusade",			--Zottelkappe
	[22790] = "Burning Crusade",			--Urflechte
	[22793] = "Burning Crusade",			--Manadistel
	[22792] = "Burning Crusade",			--Alptraumranke
	[22791] = "Wrath of the Lich King",	--Netherblüte
	[37921] = "Wrath of the Lich King",	--Brennnessel
	[36907] = "Wrath of the Lich King",	--Talandras Rose
	[36904] = "Wrath of the Lich King",	--Tigerlilie
	[36901] = "Wrath of the Lich King",	--Goldklee
	[36903] = "Wrath of the Lich King",	--Schlangenzunge
	[36906] = "Wrath of the Lich King",	--Eisdorn
	[36905] = "Wrath of the Lich King",	--Lichblüte
	[52983] = "Cataclysm",					--Aschenblüte
	[52984] = "Cataclysm",					--Sturmwinde
	[52985] = "Cataclysm",					--Azsharas Schleier
	[52986] = "Cataclysm",					--Herzblüte
	[52987] = "Cataclysm",					--Schattenjasmin
	[52988] = "Cataclysm",					--Gertenrohr
	[52989] = "Cataclysm",					--Deathspore Pod
	[79011] = "Mists of Pandaria",		--Narrenkappe
	[79010] = "Mists of Pandaria",		--Schneelilie
	[72235] = "Mists of Pandaria",		--Seidenkraut
	[72234] = "Mists of Pandaria",		--Teepflanze
	[72237] = "Mists of Pandaria",		--Regenmohn
}