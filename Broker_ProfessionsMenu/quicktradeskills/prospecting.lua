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
        GameTooltip:AddLine(me.quicktradeskills.prospecting.minerals[GetContainerItemID(i,j)])	--Add Addon Name
       end
      } 
     end
    end
   end
  end
  return result
end

me.quicktradeskills.prospecting.minerals = {
	[2770]="Classic",
	[2771]="Classic",
	[2772]="Classic",
	[3858]="Classic",
	[10620]="Classic",
	[23424]="Burning Crusade",
	[23425]="Burning Crusade",
	[36909]="Wrath of the Lich King",
	[36912]="Wrath of the Lich King",
	[36910]="Wrath of the Lich King",
	[53038]="Cataclysm",
	[52185]="Cataclysm",
	[52183]="Cataclysm",
	[72092]="Mists of Pandaria",
	[72093]="Mists of Pandaria",
	[72103]="Mists of Pandaria",
	[72094]="Mists of Pandaria",
}