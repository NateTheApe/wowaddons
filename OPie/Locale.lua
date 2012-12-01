local L, _, T = {}, ...

-- See http://wow.curseforge.com/addons/opie/localization/

if not next(L) then return end
function T:LocalizeText(k)
	return L[k] or k
end