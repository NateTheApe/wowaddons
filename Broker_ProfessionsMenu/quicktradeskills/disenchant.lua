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
       end
      }
     end
    end
   end
  end
  return result
end