local _G = _G
local select = _G.select
local pairs = _G.pairs
local ipairs = _G.ipairs
local string = _G.string
local type = _G.type
local error = _G.error
local table = _G.table


function ArkInventory.MenuMainOpen( frame )

	assert( frame, "code error: frame argument is missing" )

	if ArkInventory.Lib.Dewdrop:IsOpen( frame ) then
		
		ArkInventory.Lib.Dewdrop:Close( )
		
	else

		local loc_id = frame:GetParent( ):GetParent( ).ARK_Data.loc_id
		
		local cp = ArkInventory.LocationPlayerInfoGet( loc_id )
	
		local anchorpoints = {
			[ArkInventory.Const.Anchor.TopRight] = ArkInventory.Localise["TOPRIGHT"],
			[ArkInventory.Const.Anchor.BottomRight] = ArkInventory.Localise["BOTTOMRIGHT"],
			[ArkInventory.Const.Anchor.BottomLeft] = ArkInventory.Localise["BOTTOMLEFT"],
			[ArkInventory.Const.Anchor.TopLeft] = ArkInventory.Localise["TOPLEFT"],
		}
		
		local x, p, rp
		x = frame:GetLeft( ) + ( frame:GetRight( ) - frame:GetLeft( ) ) / 2
		if ( x >= ( GetScreenWidth( ) / 2 ) ) then
			p = "TOPRIGHT"
			rp = "TOPLEFT"
		else
			p = "TOPLEFT"
			rp = "TOPRIGHT"
		end
	
		ArkInventory.Lib.Dewdrop:Open( frame,
			"point", p,
			"relativePoint", rp,
			"children", function( level, value )
				
				if level == 1 then
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Const.Program.Name,
						"isTitle", true,
						"textHeight", 14
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Global.Version,
						"notClickable", true
					)

					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["CONFIG"],
						"closeWhenClicked", true,
						"func", function( )
							ArkInventory.Frame_Config_Show( )
						end
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["MENU_ACTION"],
						"hasArrow", true,
						"value", "ACTIONS"
					)
					
					if ( loc_id == ArkInventory.Const.Location.Mount ) or ( loc_id == ArkInventory.Const.Location.Pet ) then
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Global.Location[loc_id].Name,
							"hasArrow", true,
							"value", "INSERT_LOCATION_MENU"
						)
						
					end
					
				end
				
				
				if level == 2 and value then
				
					if value == "ACTIONS" then
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["MENU_ACTION"],
							"isTitle", true,
							"textHeight", 12
						)
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["RELOAD"],
							"tooltipTitle", ArkInventory.Localise["RELOAD"],
							"tooltipText", ArkInventory.Localise["MENU_ACTION_RELOAD_TEXT"],
							--"icon", ArkInventory.Const.Texture.Action.Refresh,
							"closeWhenClicked", true,
							"func", function( )
								ArkInventory.ItemCacheClear( )
								ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
							end
						)
						
					end
			
				end
				
				
				if ( loc_id == ArkInventory.Const.Location.Mount ) then
					ArkInventory.MenuMounts( frame, level, value, 1 )
				end
				
				if ( loc_id == ArkInventory.Const.Location.Pet ) then
					ArkInventory.MenuPets( frame, level, value, 1 )
				end
				
				
				ArkInventory.Lib.Dewdrop:AddLine( )
				
				ArkInventory.Lib.Dewdrop:AddLine(
					"text", ArkInventory.Localise["CLOSE_MENU"],
					"closeWhenClicked", true
				)
				
			end
			
		)
	
	end
	
end

function ArkInventory.MenuBarOpen( frame )
	
	assert( frame, "code error: frame argument is missing" )
	
	if ArkInventory.Lib.Dewdrop:IsOpen( frame ) then

		ArkInventory.Lib.Dewdrop:Close( )
		
	else

		local loc_id = frame.ARK_Data.loc_id
		local bar_id = frame.ARK_Data.bar_id
		local bar_name = ArkInventory.LocationOptionGet( loc_id, "bar", "data", bar_id, "label" ) or ""
		local cp = ArkInventory.LocationPlayerInfoGet( loc_id )
		
		local sid_def = ArkInventory.LocationOptionGet( loc_id, "sort", "default" ) or 9999
		local sid = ArkInventory.LocationOptionGet( loc_id, "bar", "data", bar_id, "sortorder" ) or sid_def
		
		if not ArkInventory.db.global.option.sort.data[sid].used then
			--ArkInventory.OutputWarning( "bar ", bar_id, " in location ", loc_id, " is using an invalid sort method.  resetting it to default" )
			ArkInventory.LocationOptionSet( loc_id, "bar", "data", bar_id, "sortorder", nil )
			sid = sid_def
		end
		
		--ArkInventory.Output( "sid=[", sid, "] default=[", sid_def, "]" )
		
		local x, p, rp
		x = frame:GetLeft( ) + ( frame:GetRight( ) - frame:GetLeft( ) ) / 2
		if ( x >= ( GetScreenWidth( ) / 2 ) ) then
			p = "TOPRIGHT"
			rp = "TOPLEFT"
		else
			p = "TOPLEFT"
			rp = "TOPRIGHT"
		end
	
		local category = {
			["type"] = { "SYSTEM", "CONSUMABLE", "TRADEGOODS", "SKILL", "CLASS", "EMPTY", "CUSTOM", "RULE", },
		}
		
		ArkInventory.Lib.Dewdrop:Open( frame,
			"point", p,
			"relativePoint", rp,
			"children", function( level, value )
			
				if level == 1 then
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( ArkInventory.Localise["MENU_BAR_TITLE"], bar_id ),
						"isTitle", true,
						"textHeight", 12
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( "%s: %s%s%s", ArkInventory.Localise["NAME"], LIGHTYELLOW_FONT_COLOR_CODE, bar_name, FONT_COLOR_CODE_CLOSE ),
						"tooltipTitle", ArkInventory.Localise["NAME"],
						"tooltipText", ArkInventory.Localise["CONFIG_SETTINGS_BARS_NAME_TEXT"],
						"hasArrow", true,
						"hasEditBox", true,
						"editBoxText", bar_name,
						"editBoxFunc", function( v )
							bar_name = string.trim( v )
							ArkInventory.LocationOptionSet( loc_id, "bar", "data", bar_id, "label", bar_name )
							ArkInventory.Frame_Bar_Paint_All( )
						end
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( "%s:", ArkInventory.Localise["SORT_METHOD"] ),
						"isTitle", true
					)
					
					if sid ~= sid_def then
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: %s%s%s", ArkInventory.Localise["CURRENT"], GREEN_FONT_COLOR_CODE, ArkInventory.db.global.option.sort.data[sid].name, FONT_COLOR_CODE_CLOSE ),
							"hasArrow", true,
							"value", "SORT_METHOD"
						)
						
						--ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: %s%s%s", ArkInventory.Localise["DEFAULT"], LIGHTYELLOW_FONT_COLOR_CODE, ArkInventory.db.global.option.sort.data[sid_def].name, FONT_COLOR_CODE_CLOSE ),
							"tooltipTitle", ArkInventory.Localise["MENU_ITEM_DEFAULT_RESET"],
							"tooltipText", ArkInventory.Localise["MENU_BAR_SORTKEY_DEFAULT_RESET_TEXT"],
							"closeWhenClicked", true,
							"func", function( )
								ArkInventory.LocationOptionSet( loc_id, "bar", "data", bar_id, "sortorder", nil )
								ArkInventory.Frame_Main_Generate( loc_id, ArkInventory.Const.Window.Draw.Resort )
							end
						)
						
					else
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: %s%s%s", ArkInventory.Localise["DEFAULT"], LIGHTYELLOW_FONT_COLOR_CODE, ArkInventory.db.global.option.sort.data[sid_def].name, FONT_COLOR_CODE_CLOSE ),
							"hasArrow", true,
							"value", "SORT_METHOD"
						)
						
					end
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( "%s:", ArkInventory.Localise["MENU_BAR_CATEGORY_CURRENT"] ),
						"isTitle", true
					)
					
					local has_entries = false
					for _, v in ipairs( category.type ) do
						if ArkInventory.CategoryBarHasEntries( loc_id, bar_id, v ) then
							has_entries = true
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", ArkInventory.Localise[string.format( "CATEGORY_%s", v )],
								"hasArrow", true,
								"value", string.format( "CATEGORY_CURRENT_%s", v )
							)
						end
					end
					
					if not has_entries then
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["NONE"],
							"disabled", true
						)
					end

					ArkInventory.Lib.Dewdrop:AddLine( )
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( "%s:", ArkInventory.Localise["MENU_BAR_CATEGORY_ASSIGN"] ),
						"isTitle", true
					)
					for _, v in ipairs( category.type ) do
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise[string.format( "CATEGORY_%s", v )],
							"hasArrow", true,
							"value", string.format( "CATEGORY_ASSIGN_%s", v )
						)
					end
					
					if ArkInventory.Global.Options.CategoryMoveLocation == loc_id and ArkInventory.Global.Options.CategoryMoveSource ~= bar_id then
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						local cat = ArkInventory.Global.Category[ArkInventory.Global.Options.CategoryMoveCategory]
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: %s", ArkInventory.Localise["MOVE"], ArkInventory.Localise["COMPLETE"] ),
							"tooltipTitle", string.format( "%s: %s", ArkInventory.Localise["MOVE"], ArkInventory.Localise["COMPLETE"] ),
							"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_MOVE_COMPLETE_TEXT"], string.format( "%s%s%s", LIGHTYELLOW_FONT_COLOR_CODE, cat.fullname, FONT_COLOR_CODE_CLOSE ), ArkInventory.Global.Options.CategoryMoveSource, bar_id ),
							"closeWhenClicked", true,
							"func", function( )
								ArkInventory.CategoryLocationSet( loc_id, cat.id, bar_id )
								ArkInventory.Global.Options.CategoryMoveLocation = nil
								ArkInventory.Global.Options.CategoryMoveSource = nil
								ArkInventory.Global.Options.CategoryMoveCategory = nil
								ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
							end
						)
						
					end
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( "%s:", ArkInventory.Localise["MENU_BAR_OPTIONS"] ),
						"isTitle", true
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["CLEAR"],
						"tooltipTitle", ArkInventory.Localise["CLEAR"],
						"tooltipText", ArkInventory.Localise["MENU_BAR_CLEAR_TEXT"],
						"closeWhenClicked", true,
						"func", function( )
							ArkInventory.Frame_Bar_Clear( loc_id, bar_id )
							ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
						end
					)
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["INSERT"],
						"tooltipTitle", ArkInventory.Localise["INSERT"],
						"tooltipText", ArkInventory.Localise["MENU_BAR_INSERT_TEXT"],
						"closeWhenClicked", true,
						"func", function( )
							ArkInventory.Frame_Bar_Insert( loc_id, bar_id )
							ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
						end
					)
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["REMOVE"],
						"tooltipTitle", ArkInventory.Localise["REMOVE"],
						"tooltipText", ArkInventory.Localise["MENU_BAR_REMOVE_TEXT"],
						"closeWhenClicked", true,
						"func", function( )
							ArkInventory.Frame_Bar_Remove( loc_id, bar_id )
							ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
						end
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["MOVE"],
						"tooltipTitle", ArkInventory.Localise["MOVE"],
						"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_MOVE_START_TEXT"], bar_id ),
						"disabled", ArkInventory.Global.Options.BarMoveLocation == loc_id and ArkInventory.Global.Options.BarMoveSource == bar_id,
						"closeWhenClicked", true,
						"func", function( )
							ArkInventory.Global.Options.BarMoveLocation = loc_id
							ArkInventory.Global.Options.BarMoveSource = bar_id
						end
					)
					
					if ArkInventory.Global.Options.BarMoveLocation == loc_id and ArkInventory.Global.Options.BarMoveSource ~= bar_id then
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: %s", ArkInventory.Localise["MOVE"], ArkInventory.Localise["COMPLETE"] ),
							"tooltipTitle", string.format( "%s: %s", ArkInventory.Localise["MOVE"], ArkInventory.Localise["COMPLETE"] ),
							"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_MOVE_COMPLETE_TEXT"], ArkInventory.Global.Options.BarMoveSource ),
							"closeWhenClicked", true,
							"func", function( )
								ArkInventory.Frame_Bar_Move( loc_id, ArkInventory.Global.Options.BarMoveSource, bar_id )
								ArkInventory.Global.Options.BarMoveLocation = nil
								ArkInventory.Global.Options.BarMoveSource = nil
								ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
							end
						)
					end
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["CLOSE_MENU"],
						"closeWhenClicked", true
					)
					
				end
				
				
				if level == 2 and value then
					
					if value == "SORT_METHOD" then
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["SORT_METHOD"],
							"isTitle", true,
							"textHeight", 12
						)
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						local x = ArkInventory.db.global.option.sort.data
						for k, v in ArkInventory.spairs( x, function(a,b) return x[a].name < x[b].name end ) do
							
							if v.used then
								ArkInventory.Lib.Dewdrop:AddLine(
									"text", v.name,
									"tooltipTitle", ArkInventory.Localise["SORT_METHOD"],
									"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_SORTKEY_TEXT"], v.name ),
									"isRadio", true,
									"checked", k == sid,
									"disabled", k == sid,
									"closeWhenClicked", true,
									"func", function( )
										if k == sid_def then
											ArkInventory.LocationOptionSet( loc_id, "bar", "data", bar_id, "sortorder", nil )
										else
											ArkInventory.LocationOptionSet( loc_id, "bar", "data", bar_id, "sortorder", k )
										end
										ArkInventory.Frame_Main_Generate( loc_id, ArkInventory.Const.Window.Draw.Resort )
									end
								)
							end
							
						end
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["CONFIG"],
							"closeWhenClicked", true,
							"func", function( )
								ArkInventory.Frame_Config_Show( "sorting" )
							end
						)
					
					end
					
					
					if strsub( value, 1, 17 ) == "CATEGORY_CURRENT_" then

						local cat_type = string.match( value, "^CATEGORY_CURRENT_(.+)" )
						
						if cat_type ~= nil then
					
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", ArkInventory.Localise[string.format( "CATEGORY_%s", cat_type )],
								"isTitle", true,
								"textHeight", 12
							)

							ArkInventory.Lib.Dewdrop:AddLine( )
							local has_entries = false
							for _, cat in ArkInventory.spairs( ArkInventory.Global.Category, function(a,b) return ArkInventory.Global.Category[a].fullname < ArkInventory.Global.Category[b].fullname end ) do

								local t = cat.type_code
								local cat_bar, def_bar = ArkInventory.CategoryLocationGet( loc_id, cat.id )
								
								if abs( cat_bar ) == bar_id and not def_bar then
							
									if t == "RULE" then
										local _, cat_code = ArkInventory.CategoryCodeSplit( cat.id )
										if not ArkInventory.db.profile.option.rule[cat_code] then
											t = "DO_NOT_USE" -- don't display disabled rules
										end
									end
						
									if cat_type == t then
		
										local tag_colour = GREEN_FONT_COLOR_CODE
										if cat_bar < 0 then
											tag_colour = RED_FONT_COLOR_CODE
										end
		
										has_entries = true
										ArkInventory.Lib.Dewdrop:AddLine(
											"text", string.format( "%s%s", tag_colour, cat.name ),
											"tooltipTitle", cat.fullname,
											"hasArrow", true,
											"value", string.format( "CATEGORY_CURRENT_OPTION_%s", cat.id )
										)
										
									end
						
								end
	
							end
							
							if not has_entries then
								ArkInventory.Lib.Dewdrop:AddLine(
									"text", ArkInventory.Localise["NONE"],
									"disabled", true
								)
							end
							
						end

					end

					
					if strsub( value, 1, 16 ) == "CATEGORY_ASSIGN_" then
					
						local cat_type = string.match( value, "^CATEGORY_ASSIGN_(.+)" )
				
						if cat_type ~= nil then
					
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", ArkInventory.Localise[string.format( "CATEGORY_%s", cat_type )],
								"isTitle", true,
								"textHeight", 12
							)

							ArkInventory.Lib.Dewdrop:AddLine( )
							for _, cat in ArkInventory.spairs( ArkInventory.Global.Category, function(a,b) return ArkInventory.Global.Category[a].fullname < ArkInventory.Global.Category[b].fullname end ) do

								local t = cat.type_code
								local cat_bar, def_bar = ArkInventory.CategoryLocationGet( loc_id, cat.id )
							
								if abs( cat_bar ) == bar_id and not def_bar then
									t = "DO_NOT_USE" -- change the category so it doesn't display
								end

								if t == "RULE" then
									local _, cat_code = ArkInventory.CategoryCodeSplit( cat.id )
									if not ArkInventory.db.profile.option.rule[cat_code] then
										t = "DO_NOT_USE" -- don't display disabled rules
									end
								end
								
								if cat_type == t then
	
									--local n = string.format( "[%s] %s", cat.id, cat.name )
									local n = cat.name
	
									if not def_bar then
										-- category is assigned to a bar - show the user where
										n = string.format( "%s%s%s [%s]%s", LIGHTYELLOW_FONT_COLOR_CODE, n, GREEN_FONT_COLOR_CODE, cat_bar, FONT_COLOR_CODE_CLOSE )
									end
	
									ArkInventory.Lib.Dewdrop:AddLine(
										"text", n,
										"tooltipTitle", ArkInventory.Localise["CATEGORY"],
										"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_TEXT"], cat.fullname ),
										"func", function( )
											ArkInventory.CategoryLocationSet( loc_id, cat.id, bar_id )
											ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
										end
									)
									
								end
	
							end
							
						end
						
					end

					
				end

				
				if level == 3 and value then
				
					if strsub( value, 1, 24 ) == "CATEGORY_CURRENT_OPTION_" then
					
						local cat_id = string.match( value, "^CATEGORY_CURRENT_OPTION_(.+)" )
				
						if cat_id ~= nil then
					
							local cat = ArkInventory.Global.Category[cat_id]
						
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", cat.fullname,
								"isTitle", true,
								"textHeight", 12
							)

							ArkInventory.Lib.Dewdrop:AddLine( )
							
							local cv = ArkInventory.CategoryLocationGet( loc_id, cat_id )
							local ch = false
							
							if cv < 0 then
								ch = true
								cv = abs( cv )
							end
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", ArkInventory.Localise["MOVE"],
								"tooltipTitle", ArkInventory.Localise["MOVE"],
								"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_MOVE_START_TEXT"], string.format( "%s%s%s", LIGHTYELLOW_FONT_COLOR_CODE, cat.fullname, FONT_COLOR_CODE_CLOSE ) ),
								"disabled", ArkInventory.Global.Options.CategoryMoveLocation == loc_id and ArkInventory.Global.Options.CategoryMoveSource ==  bar_id,
								"closeWhenClicked", true,
								"func", function( )
									ArkInventory.Global.Options.CategoryMoveLocation = loc_id
									ArkInventory.Global.Options.CategoryMoveSource = bar_id
									ArkInventory.Global.Options.CategoryMoveCategory = cat.id
								end
							)
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", ArkInventory.Localise["REMOVE"],
								"tooltipTitle", ArkInventory.Localise["REMOVE"],
								"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_REMOVE_TEXT"], cat.fullname, bar_id ),
								"func", function( )
									ArkInventory.CategoryLocationSet( loc_id, cat_id, nil )
									ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
								end
							)

							ArkInventory.Lib.Dewdrop:AddLine(
								"text", ArkInventory.Localise["HIDE"],
								"tooltipTitle", ArkInventory.Localise["HIDE"],
								"tooltipText", ArkInventory.Localise["MENU_BAR_CATEGORY_HIDDEN_TEXT"],
								"checked", ArkInventory.CategoryHiddenCheck( loc_id, cat_id ),
								"func", function( )
									ArkInventory.CategoryHiddenToggle( loc_id, cat_id )
									ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
								end
							)
					
						end
						
					end

				end
				
			end
		)

	end
	
end

function ArkInventory.MenuItemOpen( frame )

	assert( frame, "code error: frame argument is missing" )
	
	if ArkInventory.Global.Mode.Edit == false then
		return
	end
	
	if ArkInventory.Lib.Dewdrop:IsOpen( frame ) then
	
		ArkInventory.Lib.Dewdrop:Close( )
		
	else

		local loc_id = frame.ARK_Data.loc_id
		local bag_id = frame.ARK_Data.bag_id
		local blizzard_id = ArkInventory.BagID_Blizzard( loc_id, bag_id )
		local slot_id = frame.ARK_Data.slot_id
		local cp = ArkInventory.LocationPlayerInfoGet( loc_id )
		local i = ArkInventory.Frame_Item_GetDB( frame )
		
		local isEmpty = false
		if not i or i.h == nil then
			isEmpty = true
		end
	
	
		local x, p, rp
		x = frame:GetLeft( ) + ( frame:GetRight( ) - frame:GetLeft( ) ) / 2
		if ( x >= ( GetScreenWidth( ) / 2 ) ) then
			p = "TOPRIGHT"
			rp = "TOPLEFT"
		else
			p = "TOPLEFT"
			rp = "TOPRIGHT"
		end
		
		local ic = select( 5, ArkInventory.GetItemQualityColor( i.q ) )
		local cat0, cat1, cat2 = ArkInventory.ItemCategoryGet( i )
		local bar_id = abs( ArkInventory.CategoryLocationGet( loc_id, cat0 ) )
		
		local categories = { "SYSTEM", "CONSUMABLE", "TRADEGOODS", "SKILL", "CLASS", "EMPTY", "CUSTOM", }
		
		cat0 = ArkInventory.Global.Category[cat0] or cat0
		if type( cat0 ) ~= "table" then
			cat0 = { id = cat0, fullname = string.format( ArkInventory.Localise["CONFIG_CATEGORY_DELETED"], cat0 ) }
		end
		
		if cat1 then
			cat1 = ArkInventory.Global.Category[cat1] or cat1
			if type( cat1 ) ~= "table" then
				cat1 = { id = cat1, fullname = string.format( ArkInventory.Localise["CONFIG_CATEGORY_DELETED"], cat1 ) }
			end
		end
		
		cat2 = ArkInventory.Global.Category[cat2] or cat2
		if type( cat2 ) ~= "table" then
			cat2 = { id = cat2, fullname = string.format( ArkInventory.Localise["CONFIG_CATEGORY_DELETED"], cat2 ) }
		end
		
		ArkInventory.Lib.Dewdrop:Open( frame,
			"point", p,
			"relativePoint", rp,
			"children", function( level, value )
			
				if level == 1 then

					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( "%s:", ArkInventory.Localise["MENU_ITEM_TITLE"] ),
						"isTitle", true,
						"textHeight", 12
					)
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						-- ic
						"text", string.format( "%s: %s%s%s", ArkInventory.Localise["MENU_ITEM_ITEM"], ic, select( 3, ArkInventory.ObjectInfo( i.h ) ) or "", FONT_COLOR_CODE_CLOSE )
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					if cat1 then
					
						-- item has a category, that means it's been specifically assigned away from the default
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: %s%s%s", ArkInventory.Localise["CURRENT"], GREEN_FONT_COLOR_CODE, cat1.fullname, FONT_COLOR_CODE_CLOSE ),
							"notClickable", true
						)
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: %s%s%s", ArkInventory.Localise["DEFAULT"], LIGHTYELLOW_FONT_COLOR_CODE, cat2.fullname, FONT_COLOR_CODE_CLOSE ),
							"tooltipTitle", ArkInventory.Localise["MENU_ITEM_DEFAULT_RESET"],
							"tooltipText", ArkInventory.Localise["MENU_ITEM_DEFAULT_RESET_TEXT"],
							"closeWhenClicked", true,
							"func", function( )
								ArkInventory.ItemCategorySet( i, nil )
								ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
							end
						)
					
					else
					
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: %s%s%s", ArkInventory.Localise["DEFAULT"], LIGHTYELLOW_FONT_COLOR_CODE, cat2.fullname, FONT_COLOR_CODE_CLOSE ),
							"notClickable", true
						)
					
					end
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( "%s:", ArkInventory.Localise["MENU_ITEM_ASSIGN_CHOICES"] ),
						"isTitle", true
					)
					for _, v in ipairs( categories ) do
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise[string.format( "CATEGORY_%s", v )],
							"disabled", isEmpty,
							"hasArrow", true,
							"tooltipTitle", ArkInventory.Localise["MENU_ITEM_ASSIGN_THIS"],
							"tooltipText", ArkInventory.Localise["MENU_ITEM_ASSIGN_THIS_TEXT"],
							"value", string.format( "CATEGORY_ASSIGN_%s", v )
						)
					end
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["MOVE"],
						"tooltipTitle", ArkInventory.Localise["MOVE"],
						"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_MOVE_START_TEXT"], string.format( "%s%s%s", LIGHTYELLOW_FONT_COLOR_CODE, cat0.fullname, FONT_COLOR_CODE_CLOSE ) ),
						"disabled", ArkInventory.Global.Options.CategoryMoveLocation == loc_id and ArkInventory.Global.Options.CategoryMoveSource ==  bar_id,
						"closeWhenClicked", true,
						"func", function( )
							ArkInventory.Global.Options.CategoryMoveLocation = loc_id
							ArkInventory.Global.Options.CategoryMoveSource = bar_id
							ArkInventory.Global.Options.CategoryMoveCategory = cat0.id
						end
					)
					
					if ArkInventory.Global.Options.CategoryMoveLocation == loc_id and ArkInventory.Global.Options.CategoryMoveSource ~= bar_id then
						
						local cat = ArkInventory.Global.Category[ArkInventory.Global.Options.CategoryMoveCategory]
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: %s", ArkInventory.Localise["MOVE"], ArkInventory.Localise["COMPLETE"] ),
							"tooltipTitle", string.format( "%s: %s", ArkInventory.Localise["MOVE"], ArkInventory.Localise["COMPLETE"] ),
							"tooltipText", string.format( ArkInventory.Localise["MENU_BAR_CATEGORY_MOVE_COMPLETE_TEXT"], string.format( "%s%s%s", LIGHTYELLOW_FONT_COLOR_CODE, cat.fullname, FONT_COLOR_CODE_CLOSE ), ArkInventory.Global.Options.CategoryMoveSource, bar_id ),
							"closeWhenClicked", true,
							"func", function( )
								ArkInventory.CategoryLocationSet( loc_id, cat.id, bar_id )
								ArkInventory.Global.Options.CategoryMoveLocation = nil
								ArkInventory.Global.Options.CategoryMoveSource = nil
								ArkInventory.Global.Options.CategoryMoveCategory = nil
								ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
							end
						)
						
					end
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["MENU_ITEM_DEBUG"],
						"hasArrow", true,
						"value", "DEBUG_INFO"
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["CLOSE_MENU"],
						"closeWhenClicked", true
					)
					
				end
				
				
				if level == 2 and value then
				
					if value == "DEBUG_INFO" then
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["MENU_ITEM_DEBUG"],
							"isTitle", true,
							"textHeight", 12
						)
						
						local class, id = ArkInventory.ObjectStringDecode( i.h )
						local bagtype = ArkInventory.Const.Slot.Data[ArkInventory.BagType( blizzard_id )].type
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s (%s)", ArkInventory.Localise["LOCATION"], LIGHTYELLOW_FONT_COLOR_CODE, loc_id, ArkInventory.Global.Location[loc_id].Name ) )
						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s (%s)", ArkInventory.Localise["MENU_ITEM_DEBUG_BAG"], LIGHTYELLOW_FONT_COLOR_CODE, bag_id, blizzard_id ) )
						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s (%s)", ArkInventory.Localise["MENU_ITEM_DEBUG_SLOT"], LIGHTYELLOW_FONT_COLOR_CODE, slot_id, bagtype ) )
						--ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s", "sort key", ArkInventory.ItemSortKeyGenerate( i, bar_id ) ) )
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["CATEGORY_CLASS"], LIGHTYELLOW_FONT_COLOR_CODE, class ) )
						
						if i.h then
							
							local class, ilnk, inam, itxt, irar, ilvl, imin, ityp, isub, icount, iloc = ArkInventory.ObjectInfo( i.h )
							
							iloc = _G[iloc]
							if not iloc then
								iloc = ""
							end

							ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["NAME"], LIGHTYELLOW_FONT_COLOR_CODE, inam ) )
							
							if ( class == "item" ) then
								
								ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ITEM_ACCOUNTBOUND, LIGHTYELLOW_FONT_COLOR_CODE, ( i.ab and YES ) or NO ) )
								
								ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ITEM_SOULBOUND, LIGHTYELLOW_FONT_COLOR_CODE, ( i.sb and YES ) or NO ) )
								
								ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s (%s)", QUALITY, LIGHTYELLOW_FONT_COLOR_CODE, irar, _G[string.format( "ITEM_QUALITY%s_DESC", irar )] ) )
								
								ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_LVL_ITEM"], LIGHTYELLOW_FONT_COLOR_CODE, ilvl ) )
								ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_LVL_USE"], LIGHTYELLOW_FONT_COLOR_CODE, imin ) )
								
								ArkInventory.Lib.Dewdrop:AddLine(
									"text", string.format( "%s: %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_TYPE"], LIGHTYELLOW_FONT_COLOR_CODE, ityp ),
									"hasArrow", true,
									"hasEditBox", true,
									"editBoxText", ityp
								)
								ArkInventory.Lib.Dewdrop:AddLine(
									"text", string.format( "%s: %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_SUBTYPE"], LIGHTYELLOW_FONT_COLOR_CODE, isub ),
									"hasArrow", true,
									"hasEditBox", true,
									"editBoxText", isub
								)
								
								if iloc ~= "" then
									ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_EQUIP"], LIGHTYELLOW_FONT_COLOR_CODE, iloc ) )
								end
								
								ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", AUCTION_STACK_SIZE, LIGHTYELLOW_FONT_COLOR_CODE, icount ) )
								ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["TEXTURE"], LIGHTYELLOW_FONT_COLOR_CODE, itxt ) )
								
								local ifam = GetItemFamily( i.h )
								ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_FAMILY"], LIGHTYELLOW_FONT_COLOR_CODE, ifam ) )
							
							elseif ( class == "battlepet" ) then
								
								ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s (%s)", QUALITY, LIGHTYELLOW_FONT_COLOR_CODE, i.q, _G[string.format( "ITEM_QUALITY%s_DESC", i.q )] ) )
								
								ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_LVL_ITEM"], LIGHTYELLOW_FONT_COLOR_CODE, ilvl ) )
								
								ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s (%s)", ArkInventory.Localise["MENU_ITEM_DEBUG_TYPE"], LIGHTYELLOW_FONT_COLOR_CODE, ityp, ArkInventory.PetJournal.PetTypeName( ityp ) or ArkInventory.Localise["UNKNOWN"] ) )
								
								if i.pid then
									
									ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_PET_ID"], LIGHTYELLOW_FONT_COLOR_CODE, i.pid ) )
									
									local pd = ArkInventory.PetJournal.GetPetInfo( i.pid )
									ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_PET_SPECIES"], LIGHTYELLOW_FONT_COLOR_CODE, pd.sd.speciesID ) )
									
								end
								
							elseif ( class == "spell" ) then
							
								ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_TYPE"], LIGHTYELLOW_FONT_COLOR_CODE, string.lower( i.type ) ) )
								
								ArkInventory.Lib.Dewdrop:AddLine( )
								
								ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["TEXTURE"], LIGHTYELLOW_FONT_COLOR_CODE, itxt ) )
								
							end
							
						end
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_AI_ID_SHORT"], LIGHTYELLOW_FONT_COLOR_CODE, id ),
							"hasArrow", true,
							"hasEditBox", true,
							"editBoxText", id
						)
						
						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["CATEGORY"], LIGHTYELLOW_FONT_COLOR_CODE, cat0.id ) )
						
						local cid = ArkInventory.ObjectIDCacheCategory( i.loc_id, i.bag_id, i.sb, i.h )
						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s (%s): %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_CACHE"], ArkInventory.Localise["CATEGORY"], LIGHTYELLOW_FONT_COLOR_CODE, cid ) )
						
						cid = ArkInventory.ObjectIDCacheRule( i.loc_id, i.bag_id, i.sb, i.h )
						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s (%s): %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_CACHE"], ArkInventory.Localise["RULE"], LIGHTYELLOW_FONT_COLOR_CODE, cid ) )
						
						
						if i.h then
							
							if class == "item" then
								local rid = ArkInventory.ObjectIDInternal( i.h )
								rid = string.match( rid, "^.-%:(.+)" )
								ArkInventory.Lib.Dewdrop:AddLine(
									"text", string.format( "%s: %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_AI_ID_RULE"], LIGHTYELLOW_FONT_COLOR_CODE, rid ),
									"hasArrow", true,
									"hasEditBox", true,
									"editBoxText", rid
								)
							end
							
							ArkInventory.Lib.Dewdrop:AddLine( )
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", ArkInventory.Localise["MENU_ITEM_DEBUG_PT"],
								"hasArrow", true,
								"tooltipTitle", ArkInventory.Localise["MENU_ITEM_DEBUG_PT"],
								"tooltipText", ArkInventory.Localise["MENU_ITEM_DEBUG_PT_TEXT"],
								"value", "DEBUG_INFO_PT"
							)
							
						end
						
					end
					
					if strsub( value, 1, 16 ) == "CATEGORY_ASSIGN_" then
					
						local k = string.match( value, "CATEGORY_ASSIGN_(.+)" )
					
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise[string.format( "CATEGORY_%s", k )],
							"isTitle", true,
							"textHeight", 12
						)
						
						ArkInventory.Lib.Dewdrop:AddLine( )
					
						for _, v in ArkInventory.spairs( ArkInventory.Global.Category, function(a,b) return ArkInventory.Global.Category[a].fullname < ArkInventory.Global.Category[b].fullname end ) do
					
							local t = v.type_code
							if v.id == cat0.id then
								t = "DO_NOT_USE"
							end
							
							--ArkInventory.Output( "id=", cat.id, ", type=[", cat.type, "], value=[", value, "]" )
							if k == t then
								--~~~~
								ArkInventory.Lib.Dewdrop:AddLine(
									"text", v.name,
									"tooltipTitle", "Assign to Category",
									"tooltipText", string.format( "assign this item to %s", v.fullname ), --~~~~ check this
									"closeWhenClicked", true,
									"func", function( )
										ArkInventory.ItemCategorySet( i, v.id )
										ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
									end
								)
							
							end
							
						end
						
						if k == "CUSTOM" then
						
							ArkInventory.Lib.Dewdrop:AddLine( )
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", ArkInventory.Localise["MENU_ITEM_CUSTOM_NEW"],
								"closeWhenClicked", true,
								"func", function( )
									ArkInventory.Frame_Config_Show( "categories", "custom" )
								end
							)
							
						end
						
					end
					
				end
				
				
				if level == 3 and value then
					
					if value == "DEBUG_INFO_PT" then
					
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: ", ArkInventory.Localise["MENU_ITEM_DEBUG_PT_TITLE"] ),
							"isTitle", true,
							"textHeight", 12
						)
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						--local pt_set = ArkInventory.Lib.PeriodicTable:ItemSearch( i.h )
						local pt_set = ArkInventory.PTItemSearch( i.h )
						
						if not pt_set then
						
							ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s%s", LIGHTYELLOW_FONT_COLOR_CODE, ArkInventory.Localise["MENU_ITEM_DEBUG_PT_NONE"] ) )
						
						else
						
							for k, v in pairs( pt_set ) do
								ArkInventory.Lib.Dewdrop:AddLine(
									"text", v,
									"hasArrow", true,
									"hasEditBox", true,
									"editBoxText", v
								)
							end
							
						end
						
					end
				
				end
				
			end
			
		)
		
	end
	
end


function ArkInventory.MenuBagOpen( frame )

	assert( frame, "code error: frame argument is missing" )

	if ArkInventory.Lib.Dewdrop:IsOpen( frame ) then
	
		ArkInventory.Lib.Dewdrop:Close( )
		
	else

		local loc_id = frame.ARK_Data.loc_id
		local bag_id = frame.ARK_Data.bag_id
		local cp = ArkInventory.LocationPlayerInfoGet( loc_id )
		local player_id = cp.info.player_id
		
		local i = ArkInventory.Frame_Item_GetDB( frame )
		
		local isEmpty = false
		if not i or i.h == nil then
			isEmpty = true
		end

		local bag = cp.location[loc_id].bag[bag_id]
		
		local x, p, rp
		x = frame:GetLeft( ) + ( frame:GetRight( ) - frame:GetLeft( ) ) / 2
		if ( x >= ( GetScreenWidth( ) / 2 ) ) then
			p = "BOTTOMRIGHT" -- TOPRIGHT
			rp = "TOPLEFT" -- BOTTOMLEFT
		else
			p = "BOTTOMLEFT" -- TOPLEFT
			rp = "TOPRIGHT" -- BOTTOMRIGHT
		end
	
		ArkInventory.Lib.Dewdrop:Open( frame,
			"point", p,
			"relativePoint", rp,
			"children", function( level, value )
			
				if level == 1 then

					ArkInventory.Lib.Dewdrop:AddLine(
						--"text", string.upper( string.format( ArkInventory.Localise["MENU_BAG_TITLE"], bag_id ) ),
						"text", ArkInventory.Localise["MENU_BAG_TITLE"],
						"isTitle", true,
						"icon", bag.texture,
						"textHeight", 12
					)
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["MENU_BAG_SHOW"],
						"tooltipTitle", ArkInventory.Localise["MENU_BAG_SHOW"],
						"tooltipText", ArkInventory.Localise["MENU_BAG_SHOW_TEXT"],
						"checked", ArkInventory.db.realm.player.data[player_id].display[loc_id].bag[bag_id],
						"closeWhenClicked", true,
						"func", function( )
							ArkInventory.db.realm.player.data[player_id].display[loc_id].bag[bag_id] = not ArkInventory.db.realm.player.data[player_id].display[loc_id].bag[bag_id]
							ArkInventory.Frame_Main_Generate( loc_id, ArkInventory.Const.Window.Draw.Recalculate )
						end
					)

					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["MENU_BAG_ISOLATE"],
						"tooltipTitle", ArkInventory.Localise["MENU_BAG_ISOLATE"],
						"tooltipText", ArkInventory.Localise["MENU_BAG_ISOLATE_TEXT"],
						"closeWhenClicked", true,
						"func", function( )
							for x in pairs( ArkInventory.Global.Location[loc_id].Bags ) do
								if x == bag_id then
									ArkInventory.db.realm.player.data[player_id].display[loc_id].bag[x] = true
								else
									ArkInventory.db.realm.player.data[player_id].display[loc_id].bag[x] = false
								end
							end
							ArkInventory.Frame_Main_Generate( loc_id, ArkInventory.Const.Window.Draw.Recalculate )
						end
					)

					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["MENU_BAG_SHOWALL"],
						"tooltipTitle", ArkInventory.Localise["MENU_BAG_SHOWALL"],
						"tooltipText", ArkInventory.Localise["MENU_BAG_SHOWALL_TEXT"],
						"closeWhenClicked", true,
						"func", function( )
							for x in pairs( ArkInventory.Global.Location[loc_id].Bags ) do
								ArkInventory.db.realm.player.data[player_id].display[loc_id].bag[x] = true
							end
							ArkInventory.Frame_Main_Generate( loc_id, ArkInventory.Const.Window.Draw.Recalculate )
						end
					)
					
					if not isEmpty then
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["MENU_BAG_EMPTY"],
							"tooltipTitle", ArkInventory.Localise["MENU_BAG_EMPTY"],
							"tooltipText", ArkInventory.Localise["MENU_BAG_EMPTY_TEXT"],
							"closeWhenClicked", true,
							"func", function( )
								ArkInventory.EmptyBag( loc_id, bag_id )
							end
						)
						
					end
						
					
					if ArkInventory.Global.Mode.Edit and not isEmpty then
					
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["MENU_ITEM_DEBUG"],
							"hasArrow", true,
							"value", "DEBUG_INFO"
						)
						
					end
					
				end
					
				if level == 2 and value then
					
					if value == "DEBUG_INFO" then
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["MENU_ITEM_DEBUG"],
							"isTitle", true,
							"textHeight", 12
						)
							
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						local class, ilnk, inam, itxt, irar, ilvl, imin, ityp, isub, icount, iloc = ArkInventory.ObjectInfo( i.h )
						local _, id = ArkInventory.ObjectStringDecode( i.h )
						
						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["NAME"], LIGHTYELLOW_FONT_COLOR_CODE, inam ) )
						
						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s (%s)", ArkInventory.Localise["LOCATION"], LIGHTYELLOW_FONT_COLOR_CODE, loc_id, ArkInventory.Global.Location[loc_id].Name ) )
						
						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["CATEGORY_CLASS"], LIGHTYELLOW_FONT_COLOR_CODE, class ) )

						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s (%s)", QUALITY, LIGHTYELLOW_FONT_COLOR_CODE, irar, _G[string.format( "ITEM_QUALITY%s_DESC", irar )] ) )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_AI_ID_SHORT"], LIGHTYELLOW_FONT_COLOR_CODE, id ),
							"hasArrow", true,
							"hasEditBox", true,
							"editBoxText", id
						)
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_TYPE"], LIGHTYELLOW_FONT_COLOR_CODE, ityp ),
							"hasArrow", true,
							"hasEditBox", true,
							"editBoxText", ityp
						)
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "%s: %s%s", ArkInventory.Localise["MENU_ITEM_DEBUG_SUBTYPE"], LIGHTYELLOW_FONT_COLOR_CODE, isub ),
							"hasArrow", true,
							"hasEditBox", true,
							"editBoxText", isub
						)
						
						ArkInventory.Lib.Dewdrop:AddLine( "text", string.format( "%s: %s%s", ArkInventory.Localise["TEXTURE"], LIGHTYELLOW_FONT_COLOR_CODE, itxt ) )
						
					end

				end

			end
			
		)
		
	end
	
end

function ArkInventory.MenuChangerVaultTabOpen( frame )

	assert( frame, "code error: frame argument is missing" )

	if ArkInventory.Lib.Dewdrop:IsOpen( frame ) then
	
		ArkInventory.Lib.Dewdrop:Close( )
		
	else

		local loc_id = frame.ARK_Data.loc_id
		local bag_id = frame.ARK_Data.bag_id
		local cp = ArkInventory.LocationPlayerInfoGet( loc_id )
		local bag = cp.location[loc_id].bag[bag_id]
		local button = _G[string.format( "%s%s%sWindowBag%s", ArkInventory.Const.Frame.Main.Name, loc_id, ArkInventory.Const.Frame.Changer.Name, bag_id )]

		
		local x, p, rp
		x = frame:GetLeft( ) + ( frame:GetRight( ) - frame:GetLeft( ) ) / 2
		if ( x >= ( GetScreenWidth( ) / 2 ) ) then
			p = "TOPRIGHT"
			rp = "TOPLEFT"
		else
			p = "TOPLEFT"
			rp = "TOPRIGHT"
		end
	
		ArkInventory.Lib.Dewdrop:Open( frame,
			"point", p,
			"relativePoint", rp,
			"children", function( level, value )
			
				if level == 1 then
				
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( "%s: %s", GUILD_BANK, string.format( GUILDBANK_TAB_NUMBER, bag_id ) ),
						"isTitle", true,
						"icon", bag.texture,
						"textHeight", 12
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", bag.name,
						"isTitle", true,
						"textHeight", 12
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					if not ArkInventory.Global.Location[loc_id].isOffline then
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", "request tab data",
							"closeWhenClicked", true,
							"func", function( )
								ArkInventory.ScanVault( )
							end
						)
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
					end
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( "mode: %s", GUILD_BANK ),
						"closeWhenClicked", true,
						"disabled", GuildBankFrame.mode == "bank",
						"func", function( )
							--ArkInventory.Frame_Changer_Vault_Tab_OnClick( button, "LeftButton", "bank" )
							GuildBankFrameTab_OnClick( bag_id, 1 )
							ArkInventory.Frame_Main_Generate( loc_id, ArkInventory.Const.Window.Draw.Recalculate )
						end
					)
					
					if not ArkInventory.Global.Location[loc_id].isOffline then
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "mode: %s", GUILD_BANK_LOG ),
							"closeWhenClicked", true,
							"disabled", GuildBankFrame.mode == "log",
							"func", function( )
								ArkInventory.Frame_Main_DrawStatus( loc_id, ArkInventory.Const.Window.Draw.Recalculate )
								--ArkInventory.Frame_Changer_Vault_Tab_OnClick( button, "LeftButton", "log" )
								GuildBankFrameTab_OnClick( bag_id, 2 )
							end
						)
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "mode: %s", GUILD_BANK_MONEY_LOG ),
							"closeWhenClicked", true,
							"disabled", GuildBankFrame.mode == "moneylog",
							"func", function( )
								ArkInventory.Frame_Main_DrawStatus( loc_id, ArkInventory.Const.Window.Draw.Recalculate )
								--ArkInventory.Frame_Changer_Vault_Tab_OnClick( button, "LeftButton", "moneylog" )
								GuildBankFrameTab_OnClick( bag_id, 3 )
							end
						)
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", string.format( "mode: %s", GUILD_BANK_TAB_INFO ),
							"closeWhenClicked", true,
							"disabled", GuildBankFrame.mode == "tabinfo",
							"func", function( )
								ArkInventory.Frame_Main_DrawStatus( loc_id, ArkInventory.Const.Window.Draw.Recalculate )
								--ArkInventory.Frame_Changer_Vault_Tab_OnClick( button, "LeftButton", "tabinfo" )
								GuildBankFrameTab_OnClick( bag_id, 4 )
							end
						)
						
						if IsGuildLeader( ) then
						
							ArkInventory.Lib.Dewdrop:AddLine( )
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", "change name or icon",
								"closeWhenClicked", true,
								"func", function( )
									SetCurrentGuildBankTab( bag_id )
									GuildBankPopupFrame:Show( )
									GuildBankPopupFrame_Update( bag_id )
								end
							)
							
						end
						
					end
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["CLOSE_MENU"],
						"closeWhenClicked", true
					)
					
				end
			
			end
			
		)
		
	end
	
end

function ArkInventory.MenuChangerVaultActionOpen( frame )
	
	assert( frame, "code error: frame argument is missing" )

	if ArkInventory.Lib.Dewdrop:IsOpen( frame ) then
	
		ArkInventory.Lib.Dewdrop:Close( )
		
	else

		local loc_id = ArkInventory.Const.Location.Vault
		local cp = ArkInventory.LocationPlayerInfoGet( loc_id )
		local bag_id = GetCurrentGuildBankTab( )
		local bag = cp.location[loc_id].bag[bag_id]
		
		local x, p, rp
		x = frame:GetLeft( ) + ( frame:GetRight( ) - frame:GetLeft( ) ) / 2
		if ( x >= ( GetScreenWidth( ) / 2 ) ) then
			p = "TOPRIGHT"
			rp = "TOPLEFT"
		else
			p = "TOPLEFT"
			rp = "TOPRIGHT"
		end
	
		ArkInventory.Lib.Dewdrop:Open( frame,
			"point", p,
			"relativePoint", rp,
			"children", function( level, value )
				
				local ok = false
				local amount = 0
				local tt = ""
				
				if level == 1 then
				
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", GUILD_BANK,
						"icon", ArkInventory.Global.Location[loc_id].Texture,
						"isTitle", true,
						"textHeight", 12
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", DEPOSIT,
						"closeWhenClicked", true,
						"func", function( )
							PlaySound( "igMainMenuOption" )
							StaticPopup_Hide( "GUILDBANK_WITHDRAW" )
							if StaticPopup_Visible( "GUILDBANK_DEPOSIT") then
								StaticPopup_Hide( "GUILDBANK_DEPOSIT" )
							else
								StaticPopup_Show( "GUILDBANK_DEPOSIT" )
							end
						end
					)
					
					
					ok = false
					amount = 0
					tt = ""
					
					amount = GetGuildBankWithdrawMoney( )
					if amount >= 0 then
						
						if ( ( not CanGuildBankRepair( ) and not CanWithdrawGuildBankMoney( ) ) or ( CanGuildBankRepair( ) and not CanWithdrawGuildBankMoney( ) ) ) then
							amount = 0
						else
							amount = min( amount, GetGuildBankMoney( ) )
						end
						
						if amount > 0 then
							ok = true
						end
						
					else
						
						amount = 0
						
					end
					
					if amount > 0 then
						tt = string.format( "%s %s", GUILDBANK_AVAILABLE_MONEY, ArkInventory.MoneyText( amount ) )
					end
					
					if ok and ( not CanWithdrawGuildBankMoney( ) ) then
						tt = string.format( "%s%s (%s)", tt, REPAIR_ITEMS )
					end
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", WITHDRAW,
						"tooltipTitle", WITHDRAW,
						"tooltipText", tt,
						"closeWhenClicked", true,
						"disabled", not ok,
						"func", function( )
							PlaySound( "igMainMenuOption" )
							StaticPopup_Hide( "GUILDBANK_DEPOSIT" )
							if StaticPopup_Visible( "GUILDBANK_WITHDRAW" ) then
								StaticPopup_Hide( "GUILDBANK_WITHDRAW" )
							else
								StaticPopup_Show( "GUILDBANK_WITHDRAW" )
							end
						end
					)
					
					
					ok = nil
					amount = 0
					tt = ""
					
					if IsGuildLeader( ) then
						
						local numSlots = GetNumGuildBankTabs( )
						amount = GetGuildBankTabCost( )
						
						if not amount or numSlots >= 6 then
							
							amount = 0
							
						else
							
							if GetMoney( ) >= amount then
								ok = true
							else
								ok = false
							end
							
						end
						
					end
					
					if amount > 0 then
						tt = string.format( "%s%s", COSTS_LABEL, ArkInventory.MoneyText( amount ) )
					end
					
					if ok ~= nil then
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", BANKSLOTPURCHASE,
							"tooltipTitle", BANKSLOTPURCHASE,
							"tooltipText", tt,
							"closeWhenClicked", true,
							"disabled", not ok,
							"func", function( )
								PlaySound( "igMainMenuOption" )
								StaticPopup_Show( "CONFIRM_BUY_GUILDBANK_TAB" )
							end
						)
					end
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					
					
					
					
					
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( "%s: %s", string.format( GUILDBANK_TAB_NUMBER, bag_id ), bag.name ),
						"isTitle", true,
						"icon", bag.texture,
						"textHeight", 12
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( "%s: %s", DISPLAY, GUILD_BANK ),
						"closeWhenClicked", true,
						"disabled", GuildBankFrame.mode == "bank",
						"func", function( )
							--ArkInventory.Frame_Changer_Vault_Tab_OnClick( button, "LeftButton", "bank" )
							GuildBankFrameTab_OnClick( bag_id, 1 )
							ArkInventory.Frame_Main_Generate( loc_id, ArkInventory.Const.Window.Draw.Recalculate )
						end
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( "%s: %s", DISPLAY, GUILD_BANK_LOG ),
						"closeWhenClicked", true,
						"disabled", GuildBankFrame.mode == "log",
						"func", function( )
							ArkInventory.Frame_Main_DrawStatus( loc_id, ArkInventory.Const.Window.Draw.Recalculate )
							--ArkInventory.Frame_Changer_Vault_Tab_OnClick( button, "LeftButton", "log" )
							GuildBankFrameTab_OnClick( bag_id, 2 )
						end
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( "%s: %s", DISPLAY, GUILD_BANK_MONEY_LOG ),
						"closeWhenClicked", true,
						"disabled", GuildBankFrame.mode == "moneylog",
						"func", function( )
							ArkInventory.Frame_Main_DrawStatus( loc_id, ArkInventory.Const.Window.Draw.Recalculate )
							--ArkInventory.Frame_Changer_Vault_Tab_OnClick( button, "LeftButton", "moneylog" )
							GuildBankFrameTab_OnClick( bag_id, 3 )
						end
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( "%s: %s", DISPLAY, GUILD_BANK_TAB_INFO ),
						"closeWhenClicked", true,
						"disabled", GuildBankFrame.mode == "tabinfo",
						"func", function( )
							ArkInventory.Frame_Main_DrawStatus( loc_id, ArkInventory.Const.Window.Draw.Recalculate )
							--ArkInventory.Frame_Changer_Vault_Tab_OnClick( button, "LeftButton", "tabinfo" )
							GuildBankFrameTab_OnClick( bag_id, 4 )
						end
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					if IsGuildLeader( ) then
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", "change name or icon",
							"closeWhenClicked", true,
							"func", function( )
								SetCurrentGuildBankTab( bag_id )
								GuildBankPopupFrame:Show( )
								GuildBankPopupFrame_Update( bag_id )
							end
						)
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
					end
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", "rescan data",
						"closeWhenClicked", true,
						"func", function( )
							ArkInventory.ScanVault( )
						end
					)
						
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["CLOSE_MENU"],
						"closeWhenClicked", true
					)
					
				end
			
			end
			
		)
		
	end
	
end


function ArkInventory.MenuSwitchLocation( frame, level, value, offset )
	
	assert( frame, "code error: frame argument is missing" )
	
	ArkInventory.Lib.Dewdrop:AddLine(
		"text", ArkInventory.Localise["MENU_LOCATION_SWITCH"],
		"isTitle", true,
		"textHeight", 12
	)
	
	if level == offset + 1 then
	
		for set_id, loc in ArkInventory.spairs( ArkInventory.Global.Location ) do
			if ArkInventory.Global.Location[set_id].canView then
				ArkInventory.Lib.Dewdrop:AddLine(
					"text", loc.Name,
					"tooltipTitle", loc.Name,
					"tooltipText", string.format( ArkInventory.Localise["MENU_LOCATION_SWITCH_TEXT"], loc.Name ),
					"icon", loc.Texture,
					"closeWhenClicked", true,
					"func", function( )
						ArkInventory.Frame_Main_Toggle( set_id )
					end
				)
			end
		end
		
	end
	
end

function ArkInventory.MenuSwitchLocationOpen( frame )

	assert( frame, "code error: frame argument is missing" )

	if ArkInventory.Lib.Dewdrop:IsOpen( frame ) then
	
		ArkInventory.Lib.Dewdrop:Close( )
	
	else

		local x, p, rp
		x = frame:GetLeft( ) + ( frame:GetRight( ) - frame:GetLeft( ) ) / 2
		if ( x >= ( GetScreenWidth( ) / 2 ) ) then
			p = "TOPRIGHT"
			rp = "BOTTOMLEFT"
		else
			p = "TOPLEFT"
			rp = "BOTTOMRIGHT"
		end
	
		ArkInventory.Lib.Dewdrop:Open( frame,
			"point", p,
			"relativePoint", rp,
			"children", function( level, value )
			
				ArkInventory.MenuSwitchLocation( frame, level, value, 0 )
				
				if level == 1 then
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["CLOSE_MENU"],
						"closeWhenClicked", true
					)
					
				end
				
			end
		)

	end
	
end

function ArkInventory.MenuSwitchCharacter( frame, level, value, offset )
	
	assert( frame, "code error: frame argument is missing" )
	
	local loc_id = frame:GetParent( ):GetParent( ).ARK_Data.loc_id
	local cp = ArkInventory.LocationPlayerInfoGet( loc_id )
	
	if level == offset + 1 then
	
		ArkInventory.Lib.Dewdrop:AddLine(
			"text", ArkInventory.Localise["MENU_CHARACTER_SWITCH"],
			"isTitle", true,
			"textHeight", 12
		)
		
		local fc = 0
			
			local count = 0
			
			for n, tp in ArkInventory.spairs( ArkInventory.db.realm.player.data, function( a, b ) return a < b end ) do
				
				local show = true
				
				if ( loc_id == ArkInventory.Const.Location.Vault ) and ( tp.info.class ~= "GUILD" ) then
					show = false
				end
				
				if ( loc_id == ArkInventory.Const.Location.Pet ) and ( tp.info.class ~= "ACCOUNT" ) then
					show = false
				end
				
				if ( loc_id == ArkInventory.Const.Location.Mount ) and ( tp.info.class ~= "ACCOUNT" ) then
					show = false
				end
				
				if not tp or tp.location[loc_id].slot_count == 0 then
					show = false
				end
				
				if show then
					
					count = count + 1
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.DisplayName4( tp.info ),
						--"tooltipTitle", "",
						--"tooltipText", "",
						"hasArrow", true,
						"isRadio", true,
						"checked", cp.info.player_id == tp.info.player_id,
						--"notClickable", cp.info.player_id == tp.info.player_id,
						"closeWhenClicked", true,
						"func", function( )
							ArkInventory.Frame_Main_Show( loc_id, tp.info.player_id )
						end,
						"value", string.format( "SWITCH_CHARACTER_SWITCH_%s", tp.info.player_id )
					)
					
				end
				
			end
			
			
			if count == 0 then
			
				ArkInventory.Lib.Dewdrop:AddLine(
					"text", "no data availale",
					"disabled", true
				)
				
			end
			
		end
	
	if level == offset + 2 and value then

		local player_id = string.match( value, "^SWITCH_CHARACTER_SWITCH_(.+)" )
		
		local tp = ArkInventory.PlayerInfoGet( player_id )
		
		ArkInventory.Lib.Dewdrop:AddLine(
			"text", ArkInventory.DisplayName4( tp.info ),
			"isTitle", true,
			"textHeight", 12
		)
		
		ArkInventory.Lib.Dewdrop:AddLine( )
		
		if loc_id ~= ArkInventory.Const.Location.Vault then
			ArkInventory.Lib.Dewdrop:AddLine(
				"text", string.format( ArkInventory.Localise["MENU_CHARACTER_SWITCH_ERASE"], ArkInventory.Global.Location[loc_id].Name ),
				"tooltipTitle", string.format( ArkInventory.Localise["MENU_CHARACTER_SWITCH_ERASE"], ArkInventory.Global.Location[loc_id].Name ),
				"tooltipText", string.format( "%s%s", RED_FONT_COLOR_CODE, string.format( ArkInventory.Localise["MENU_CHARACTER_SWITCH_ERASE_TEXT"], ArkInventory.Global.Location[loc_id].Name, ArkInventory.DisplayName1( tp.info ) ) ),
				"closeWhenClicked", true,
				"func", function( )
					ArkInventory.Frame_Main_Hide( loc_id )
					ArkInventory.EraseSavedData( tp.info.player_id, loc_id )
				end
			)
		end
		
		ArkInventory.Lib.Dewdrop:AddLine(
			"text", string.format( ArkInventory.Localise["MENU_CHARACTER_SWITCH_ERASE"], ArkInventory.Localise["ALL"] ),
			"tooltipTitle", string.format( ArkInventory.Localise["MENU_CHARACTER_SWITCH_ERASE"], ArkInventory.Localise["ALL"] ),
			"tooltipText", string.format( "%s%s", RED_FONT_COLOR_CODE, string.format( ArkInventory.Localise["MENU_CHARACTER_SWITCH_ERASE_TEXT"], ArkInventory.Localise["ALL"], ArkInventory.DisplayName1( tp.info ) ) ),
			"closeWhenClicked", true,
			"func", function( )
				ArkInventory.Frame_Main_Hide( )
				ArkInventory.EraseSavedData( tp.info.player_id )
			end
		)
	
	end

end

function ArkInventory.MenuSwitchCharacterOpen( frame )
	
	assert( frame, "code error: frame argument is missing" )
	
	if ArkInventory.Lib.Dewdrop:IsOpen( frame ) then
		
		ArkInventory.Lib.Dewdrop:Close( )
		
	else
		
		local x, p, rp
		x = frame:GetLeft( ) + ( frame:GetRight( ) - frame:GetLeft( ) ) / 2
		if ( x >= ( GetScreenWidth( ) / 2 ) ) then
			p = "TOPRIGHT"
			rp = "BOTTOMLEFT"
		else
			p = "TOPLEFT"
			rp = "BOTTOMRIGHT"
		end
		
		ArkInventory.Lib.Dewdrop:Open( frame,
			"point", p,
			"relativePoint", rp,
			"children", function( level, value )
				
				ArkInventory.MenuSwitchCharacter( frame, level, value, 0 )
				
				if level == 1 then
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["CLOSE_MENU"],
						"closeWhenClicked", true
					)
					
				end
				
			end
			
		)
		
	end
	
end

function ArkInventory.MenuLDBBagsOpen( frame )

	assert( frame, "code error: frame argument is missing" )

	if ArkInventory.Lib.Dewdrop:IsOpen( frame ) then
	
		ArkInventory.Lib.Dewdrop:Close( )
	
	else

		local x, p, rp
		x = frame:GetBottom( ) + ( frame:GetTop( ) - frame:GetBottom( ) ) / 2
		if ( x >= ( GetScreenHeight( ) / 2 ) ) then
			p = "TOPLEFT"
			rp = "BOTTOMLEFT"
		else
			p = "BOTTOMLEFT"
			rp = "TOPLEFT"
		end
	
		ArkInventory.Lib.Dewdrop:Open( frame,
			"point", p,
			"relativePoint", rp,
			"children", function( level, value )
				
				if level == 1 then
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Const.Program.Name,
						"isTitle", true,
						"textHeight", 14
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Global.Version,
						"notClickable", true
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["CONFIG"],
						"closeWhenClicked", true,
						"func", function( )
							ArkInventory.Frame_Config_Show( )
						end
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["MENU_ACTION"],
						"hasArrow", true,
						"value", "ACTIONS"
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["MENU_LOCATION_SWITCH"],
						"hasArrow", true,
						"value", "LOCATION"
					)
						
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["FONT"],
						"hasArrow", true,
						"value", "FONT"
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["LDB"],
						"hasArrow", true,
						"value", "LDB"
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["CLOSE_MENU"],
						"closeWhenClicked", true
					)
					
				end
				
				
				if level == 2 and value then
				
					if value == "LOCATION" then
						ArkInventory.MenuSwitchLocation( frame, level, value, 1 )
					end
					
					if value == "FONT" then
					
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["FONT"],
							"isTitle", true,
							"textHeight", 12
						)
						
						for _, fontName in pairs( ArkInventory.Lib.SharedMedia:List( "font" ) ) do
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", fontName,
								"tooltipTitle", ArkInventory.Localise["FONT"],
								"tooltipText", string.format( ArkInventory.Localise["CONFIG_SYSTEM_FONT_TEXT"], fontName ),
								"checked", fontName == ArkInventory.db.profile.option.font.name,
								"func", function( )
									ArkInventory.MediaSetFontAll( fontName )
								end
							)
						end
						
					end
					
					if value == "ACTIONS" then
					
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["MENU_ACTION"],
							"isTitle", true,
							"textHeight", 12
						)
						
						for k, v in pairs( ArkInventory.Const.Actions ) do
							if v.LDB then
								ArkInventory.Lib.Dewdrop:AddLine(
									"text", v.Name,
									"closeWhenClicked", true,
									"icon", v.Texture,
									"func", v.Scripts.OnClick
								)
							end
						end
						
					end
					
					if value == "LDB" then
					
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["LDB"],
							"isTitle", true,
							"textHeight", 12
						)
						
						ArkInventory.Lib.Dewdrop:AddLine( )
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["LDB_BAGS_COLOUR_USE"],
							"tooltipTitle", ArkInventory.Localise["LDB_BAGS_COLOUR_USE"],
							"tooltipText", ArkInventory.Localise["LDB_BAGS_COLOUR_USE_TEXT"],
							"checked", ArkInventory.db.char.option.ldb.bags.colour,
							"func", function( )
								ArkInventory.db.char.option.ldb.bags.colour = not ArkInventory.db.char.option.ldb.bags.colour
								ArkInventory.LDB.Bags:Update( )
							end
						)
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["LDB_BAGS_STYLE"],
							"tooltipTitle", ArkInventory.Localise["LDB_BAGS_STYLE"],
							"tooltipText", ArkInventory.Localise["LDB_BAGS_STYLE_TEXT"],
							"checked", ArkInventory.db.char.option.ldb.bags.full,
							"func", function( )
								ArkInventory.db.char.option.ldb.bags.full = not ArkInventory.db.char.option.ldb.bags.full
								ArkInventory.LDB.Bags:Update( )
							end
						)
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["LDB_BAGS_INCLUDE_TYPE"],
							"tooltipTitle", ArkInventory.Localise["LDB_BAGS_INCLUDE_TYPE"],
							"tooltipText", ArkInventory.Localise["LDB_BAGS_INCLUDE_TYPE_TEXT"],
							"checked", ArkInventory.db.char.option.ldb.bags.includetype,
							"func", function( )
								ArkInventory.db.char.option.ldb.bags.includetype = not ArkInventory.db.char.option.ldb.bags.includetype
								ArkInventory.LDB.Bags:Update( )
							end
						)
						
					end
					
					
				end
				
			end
			
		)
	
	end
	
end

function ArkInventory.MenuLDBTrackingCurrencyOpen( frame )

	assert( frame, "code error: frame argument is missing" )

	if ArkInventory.Lib.Dewdrop:IsOpen( frame ) then
	
		ArkInventory.Lib.Dewdrop:Close( )
	
	else

		local x, p, rp
		x = frame:GetBottom( ) + ( frame:GetTop( ) - frame:GetBottom( ) ) / 2
		if ( x >= ( GetScreenHeight( ) / 2 ) ) then
			p = "TOPLEFT"
			rp = "BOTTOMLEFT"
		else
			p = "BOTTOMLEFT"
			rp = "TOPLEFT"
		end
	
		ArkInventory.Lib.Dewdrop:Open( frame,
			"point", p,
			"relativePoint", rp,
			"children", function( level, value )
				
				if level == 1 then
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.LDB.Tracking_Currency.name,
						"isTitle", true,
						"textHeight", 14
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Global.Version,
						"notClickable", true
					)
					
					-- expand all token headers
					local numTokenTypes = GetCurrencyListSize( )
	
					if numTokenTypes > 0 then
						
						for j = numTokenTypes, 1, -1 do
							local name, isHeader, isExpanded = GetCurrencyListInfo( j )
							if isHeader and not isExpanded then
								ExpandCurrencyList( j, 1 )
							end
						end
						
						local numTokenTypes = GetCurrencyListSize( )
						
						for j = 1, numTokenTypes do
							
							local name, isHeader, isExpanded, isUnused, isWatched, count, icon = GetCurrencyListInfo( j )
							
							if isHeader then
								
								ArkInventory.Lib.Dewdrop:AddLine( )
								ArkInventory.Lib.Dewdrop:AddLine(
									"text", name,
									"isTitle", true
								)
								
							else
								
								local h = GetCurrencyListLink( j )
								local class, id = ArkInventory.ObjectStringDecode( h )
								
								local checked = ArkInventory.db.char.option.ldb.tracking.currency.tracked[id]
								
								local t1 = name
								local t2 = ArkInventory.Localise["CLICK_TO_SELECT"]
								if checked then
									t1 = string.format( "%s%s", GREEN_FONT_COLOR_CODE, name )
									t2 = ArkInventory.Localise["CLICK_TO_DESELECT"]
								end
								
								ArkInventory.Lib.Dewdrop:AddLine(
									"icon", icon,
									"text", t1,
									"tooltipTitle", name,
									"tooltipText", t2,
									"checked", checked,
									"func", function( )
										ArkInventory.db.char.option.ldb.tracking.currency.tracked[id] = not ArkInventory.db.char.option.ldb.tracking.currency.tracked[id]
										ArkInventory.LDB.Tracking_Currency:Update( )
									end
								)
								
							end
							
						end
						
					end
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["CLOSE_MENU"],
						"closeWhenClicked", true
					)
					
				end
				
			end
			
		)
	
	end
	
end

function ArkInventory.MenuLDBTrackingItemOpen( frame )

	assert( frame, "code error: frame argument is missing" )

	if ArkInventory.Lib.Dewdrop:IsOpen( frame ) then
	
		ArkInventory.Lib.Dewdrop:Close( )
	
	else

		local x, p, rp
		x = frame:GetBottom( ) + ( frame:GetTop( ) - frame:GetBottom( ) ) / 2
		if ( x >= ( GetScreenHeight( ) / 2 ) ) then
			p = "TOPLEFT"
			rp = "BOTTOMLEFT"
		else
			p = "BOTTOMLEFT"
			rp = "TOPLEFT"
		end
	
		ArkInventory.Lib.Dewdrop:Open( frame,
			"point", p,
			"relativePoint", rp,
			"children", function( level, value )
				
				if level == 1 then
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.LDB.Tracking_Item.name,
						"isTitle", true,
						"textHeight", 14
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Global.Version,
						"notClickable", true
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					local numTokenTypes = 0
					
					for k in ArkInventory.spairs( ArkInventory.db.global.option.tracking.items )  do
						
						numTokenTypes = numTokenTypes + 1
						
						local count = GetItemCount( k )
						local name, _, _, _, _, _, _, _, _, icon = GetItemInfo( k )
						
						if k == 6265 then
							-- soul shards
							count = UnitPower( "player", 7 ) or 0
						end
						
						local checked = ArkInventory.db.char.option.ldb.tracking.item.tracked[k]
						local t1 = name
						local t2 = ArkInventory.Localise["CLICK_TO_SELECT"]
						
						if checked then
							t1 = string.format( "%s%s", GREEN_FONT_COLOR_CODE, name )
							t2 = ArkInventory.Localise["CLICK_TO_DESELECT"]
						end
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"icon", icon,
							"text", t1,
							"tooltipTitle", name,
							"tooltipText", t2,
							"checked", checked,
							"hasArrow", true,
							"func", function( )
								ArkInventory.db.char.option.ldb.tracking.item.tracked[k] = not ArkInventory.db.char.option.ldb.tracking.item.tracked[k]
								ArkInventory.LDB.Tracking_Item:Update( )
							end,
							"value", k
						)
						
					end
					
					if numTokenTypes == 0 then
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", ArkInventory.Localise["NONE"],
							"disabled", true
						)
						
					end
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["CLOSE_MENU"],
						"closeWhenClicked", true
					)
					
				end
				
				
				if level == 2 and value and value > 0 then
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", string.format( "%s%s%s", RED_FONT_COLOR_CODE, ArkInventory.Localise["REMOVE"], FONT_COLOR_CODE_CLOSE ),
						"tooltipTitle", ArkInventory.Localise["REMOVE"],
						--"tooltipText", "",
						"func", function( )
							ArkInventory.db.global.option.tracking.items[value] = nil
							ArkInventory.db.char.option.ldb.tracking.item.tracked[value] = false
							ArkInventory.LDB.Tracking_Item:Update( )
						end
					)

				end
				
			end
			
		)
	
	end
	
end

function ArkInventory.MenuMounts( frame, level, value, offset )

	assert( frame, "code error: frame argument is missing" )
	
	
	if ( level == offset + 1 ) and ( ( offset == 0 ) or ( value and ( value == "INSERT_LOCATION_MENU" ) ) ) then
		
--		ArkInventory.Lib.Dewdrop:AddLine(
--			"text", ArkInventory.Global.Location[ArkInventory.Const.Location.Mount].Name,
--			"isTitle", true,
--			"textHeight", 14
--		)
		
		local tooltiptext = ""
		local skill = ArkInventory.LDB.Mounts.RidingSkill( )
		
		if skill == 0 then
			tooltiptext = string.format( "%s%s", RED_FONT_COLOR_CODE, SPELL_FAILED_LOW_CASTLEVEL )
		else
			tooltiptext = ""
		end
		ArkInventory.Lib.Dewdrop:AddLine(
			"text", ArkInventory.Localise["LDB_MOUNTS_TYPE_L"],
			"tooltipTitle", ArkInventory.Localise["LDB_MOUNTS_TYPE_L"],
			"tooltipText", tooltiptext,
			"hasArrow", true,
			"disabled", skill == 0,
			"value", "l"
		)
		
		if skill < 225 then
			tooltiptext = string.format( "%s%s", RED_FONT_COLOR_CODE, SPELL_FAILED_LOW_CASTLEVEL )
		else
			tooltiptext = ""
		end
		ArkInventory.Lib.Dewdrop:AddLine(
			"text", ArkInventory.Localise["LDB_MOUNTS_TYPE_A"],
			"tooltipTitle", ArkInventory.Localise["LDB_MOUNTS_TYPE_A"],
			"tooltipText", tooltiptext,
			"hasArrow", true,
			"disabled", skill < 225,
			"value", "a"
		)
		
		if skill == 0 then
			tooltiptext = string.format( "%s%s", RED_FONT_COLOR_CODE, SPELL_FAILED_LOW_CASTLEVEL )
		else
			tooltiptext = ""
		end
		ArkInventory.Lib.Dewdrop:AddLine(
			"text", ArkInventory.Localise["LDB_MOUNTS_TYPE_U"],
			"tooltipTitle", ArkInventory.Localise["LDB_MOUNTS_TYPE_U"],
			"tooltipText", tooltiptext,
			"hasArrow", true,
			"disabled", skill == 0,
			"value", "u"
		)
		
--[[
		ArkInventory.Lib.Dewdrop:AddLine( )
		
		ArkInventory.Lib.Dewdrop:AddLine(
			"text", "cancel auras",
			"TooltipTitle", "cancel auras",
			"tooltipText", "attempt to cancel specific auras before mounting",
			"hasArrow", true,
			"value", "aura"
		)
]]--
		
		ArkInventory.Lib.Dewdrop:AddLine( )
		
		ArkInventory.Lib.Dewdrop:AddLine(
			"text", ArkInventory.Localise["CONFIG"],
			"closeWhenClicked", true,
			"func", function( )
				ArkInventory.Frame_Config_Show( "ldb", "mounts" )
			end
		)
		
	end
	
	
	if ( level == 2 + offset ) and value then
		
		if value == "aura" then
		
			ArkInventory.Lib.Dewdrop:AddLine(
				"text", "cancel aura",
				"isTitle", true,
				"textHeight", 14
			)
			
			ArkInventory.Lib.Dewdrop:AddLine( )
			
			local count = 0
			
			for spellId in pairs( ArkInventory.db.global.option.ldb.mounts.aura ) do
				
				count = count + 1
				
				local text = GetSpellInfo( spellId )
				local checked = ArkInventory.db.char.option.ldb.mounts.aura[spellId]
				local icon = ""
				
				if checked then
					icon = ArkInventory.Const.Texture.Yes 
					text = string.format( "%s%s [%s]%s", GREEN_FONT_COLOR_CODE, text, spellId, FONT_COLOR_CODE_CLOSE )
				end
				
				ArkInventory.Lib.Dewdrop:AddLine(
					"icon",  icon,
					"text", text,
					"func", function( )
						ArkInventory.db.char.option.ldb.mounts.aura[spellId] = not ArkInventory.db.char.option.ldb.mounts.aura[spellId]
					end
				)
			end
			
			if count > 0 then
				ArkInventory.Lib.Dewdrop:AddLine( )
			end
			
			ArkInventory.Lib.Dewdrop:AddLine(
				"text", "add aura",
				"tooltipTitle", "add aura",
				"tooltipText", "enter the spell id for the aura you want cancelled before mounting.\n\nimportant: shapeshift forms can only be cancelled by the user",
				"hasArrow", true,
				"hasEditBox", true,
				"editBoxText", "",
				"editBoxFunc", function( v )
					local spellId = tonumber( v )
					ArkInventory.db.global.option.ldb.mounts.aura[spellId] = true
					ArkInventory.db.char.option.ldb.mounts.aura[spellId] = true
				end
			)
			
		else
		
			local companionType = "MOUNT"
			local mountType = value
			local header = ArkInventory.Localise[string.upper( string.format( "LDB_MOUNTS_TYPE_%s", mountType ) )]
			local selected = ArkInventory.db.char.option.ldb.mounts[mountType].selected
			
			ArkInventory.Lib.Dewdrop:AddLine(
				"text", header,
				"isTitle", true,
				"textHeight", 14
			)
			
			local n = GetNumCompanions( companionType )
			
			ArkInventory.Lib.Dewdrop:AddLine( )
			
			local companionCount = 0
			
			for companionIndex = 1, n do
				
				local companionID, companionName, companionSpellID, texture, active = GetCompanionInfo( companionType, companionIndex )
				local companionData = ArkInventory.Global.Companion.MOUNT[companionSpellID]
				
				if companionData.mt == mountType then
					
					companionCount = companionCount + 1
					
					local text = companionName
					local tooltipText = ""
					local icon = ""
					
					if selected[companionSpellID] == true then
						icon = ArkInventory.Const.Texture.Yes
						text = string.format( "%s%s%s", GREEN_FONT_COLOR_CODE, companionName, FONT_COLOR_CODE_CLOSE )
					elseif selected[companionSpellID] == false then
						icon = ArkInventory.Const.Texture.No
						text = string.format( "%s%s%s", RED_FONT_COLOR_CODE, companionName, FONT_COLOR_CODE_CLOSE )
					end
					
					if ( companionData and companionData.r ) then
						
						if companionData.r.zone then
							tooltipText = ArkInventory.Localise["LDB_COMPANION_RESTRICTED_ZONE"]
						elseif companionData.r.item then
							tooltipText = ArkInventory.Localise["LDB_COMPANION_RESTRICTED_ITEM"]
						elseif companionData.r.event then
							tooltipText = ArkInventory.Localise["LDB_COMPANION_RESTRICTED_EVENT"]
						else
							tooltipText = ArkInventory.Localise["LDB_COMPANION_RESTRICTED_UNKNOWN"]
						end
						
						tooltipText = string.format( ArkInventory.Localise["LDB_COMPANION_RESTRICTED"], ORANGE_FONT_COLOR_CODE, tooltipText )
						
					end
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"icon", icon,
						"text", text,
						"disabled", not companionData.usable[mountType],
						"tooltipTitle", companionName,
						"tooltipText", tooltipText,
						"hasArrow", true,
						"value", string.format( "%s:%s:%s", companionType, mountType, companionIndex )
					)
					
				end
				
			end
		
			if companionCount > 0 then
				
				ArkInventory.Lib.Dewdrop:AddLine( )
				
				local companionName = ArkInventory.Localise["RANDOM"]
				local tooltipText = ArkInventory.Localise["CLICK_TO_SELECT"]
				local selected = ArkInventory.db.char.option.ldb.mounts[mountType].selected
				
				local allrandom = ( ArkInventory.LDB.Companion.GetSelectedCount( selected ) == 0 )
				if allrandom then
					companionName = string.format( "%s%s%s", GREEN_FONT_COLOR_CODE, companionName, FONT_COLOR_CODE_CLOSE )
					tooltipText = nil
				end
				
				ArkInventory.Lib.Dewdrop:AddLine(
					"text", companionName,
					"tooltipTitle", companionName,
					"tooltipText", tooltipText,
					"checked", allrandom,
					"notClickable", allrandom,
					"func", function( )
						for k, v in pairs( selected ) do
							if v == true then
								selected[k] = nil
							end
						end
						ArkInventory.LDB.Mounts:Update( )
					end
				)
				
				if mountType == "a" then
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["LDB_MOUNTS_FLYING_DISMOUNT"],
						"tooltipTitle", ArkInventory.Localise["LDB_MOUNTS_FLYING_DISMOUNT"],
						"tooltipText", ArkInventory.Localise["LDB_MOUNTS_FLYING_DISMOUNT_TEXT"],
						"checked", ArkInventory.db.char.option.ldb.mounts.a.dismount,
						"func", function( )
							ArkInventory.db.char.option.ldb.mounts.a.dismount = not ArkInventory.db.char.option.ldb.mounts.a.dismount
						end
					)
					
				end
				
			end
			
			if companionCount == 0 then
				
				ArkInventory.Lib.Dewdrop:AddLine(
					"text", ArkInventory.Localise["LDB_COMPANION_NONE"],
					"disabled", true
				)
				
			end
			
		end
		
	end
	
	if ( level == 3 + offset ) and value then
		
		if value == "aura" then
			
		else
			
			local companionType, mountType, companionIndex = string.match( value, "^(.-):(.-):(.-)$" )
			companionIndex = tonumber( companionIndex )
			
			local companionID, companionName, companionSpellID, texture, active = GetCompanionInfo( companionType, companionIndex )
			
			local selected = ArkInventory.db.char.option.ldb.mounts[mountType].selected
			
			ArkInventory.Lib.Dewdrop:AddLine(
				"text", companionName,
				"isTitle", true,
				"textHeight", 14
			)
			
			ArkInventory.Lib.Dewdrop:AddLine( )
			
			ArkInventory.Lib.Dewdrop:AddLine(
				"text", string.format( "%s%s%s", GREEN_FONT_COLOR_CODE, ArkInventory.Localise["CLICK_TO_SELECT"], FONT_COLOR_CODE_CLOSE ),
				"tooltipTitle", companionName,
				"tooltipText", string.format( ArkInventory.Localise["LDB_COMPANION_SELECT"], companionName ),
				"checked", selected[companionSpellID] == true,
				"disabled", selected[companionSpellID] == true,
				"isRadio", true,
				"func", function( )
					selected[companionSpellID] = true
					ArkInventory.LDB.Mounts:Update( )
				end
			)
	
			ArkInventory.Lib.Dewdrop:AddLine(
				"text", string.format( "%s%s%s", RED_FONT_COLOR_CODE, ArkInventory.Localise["CLICK_TO_IGNORE"], FONT_COLOR_CODE_CLOSE ),
				"tooltipTitle", companionName,
				"tooltipText", string.format( ArkInventory.Localise["LDB_COMPANION_IGNORE"], companionName ),
				"checked", selected[companionSpellID] == false,
				"disabled", selected[companionSpellID] == false,
				"isRadio", true,
				"func", function( )
					selected[companionSpellID] = false
					ArkInventory.LDB.Mounts:Update( )
				end
			)
	
			if selected[companionSpellID] ~= nil then
				ArkInventory.Lib.Dewdrop:AddLine(
					"text", string.format( "%s%s%s", HIGHLIGHT_FONT_COLOR_CODE, ArkInventory.Localise["CLICK_TO_DESELECT"], FONT_COLOR_CODE_CLOSE ),
					"tooltipTitle", companionName,
					"tooltipText", string.format( ArkInventory.Localise["LDB_COMPANION_DESELECT"], companionName ),
					"checked", selected[companionSpellID] == nil,
					"disabled", selected[companionSpellID] == nil,
					"isRadio", true,
					"func", function( )
						selected[companionSpellID] = nil
						ArkInventory.LDB.Mounts:Update( )
					end
				)
			end
			
			ArkInventory.Lib.Dewdrop:AddLine( )
			
			ArkInventory.Lib.Dewdrop:AddLine(
				"text", ArkInventory.Localise["LDB_MOUNTS_SUMMON"],
				"tooltipTitle", companionName,
				"tooltipText", ArkInventory.Localise["LDB_MOUNTS_SUMMON"],
				"func", function( )
					CallCompanion( companionType, companionIndex )
				end
			)
			
		end
		
	end

end

function ArkInventory.MenuLDBMountsOpen( frame )
	
	assert( frame, "code error: frame argument is missing" )

	if ArkInventory.Lib.Dewdrop:IsOpen( frame ) then
	
		ArkInventory.Lib.Dewdrop:Close( )
	
	else
		
		local x, p, rp
		x = frame:GetLeft( ) + ( frame:GetRight( ) - frame:GetLeft( ) ) / 2
		if ( x >= ( GetScreenWidth( ) / 2 ) ) then
			p = "TOPRIGHT"
			rp = "BOTTOMLEFT"
		else
			p = "TOPLEFT"
			rp = "BOTTOMRIGHT"
		end
	
		ArkInventory.Lib.Dewdrop:Open( frame,
			"point", p,
			"relativePoint", rp,
			"children", function( level, value )
				
				if ( level == 1 ) then
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.LDB.Mounts.name,
						"isTitle", true,
						"textHeight", 14
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Global.Version,
						"notClickable", true
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
				
				end
				
				ArkInventory.MenuMounts( frame, level, value, 0 )
				
				if level == 1 then
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["CLOSE_MENU"],
						"closeWhenClicked", true
					)
					
				end
				
			end
		)

	end
	
end

function ArkInventory.MenuPets( frame, level, value, offset )
	
	assert( frame, "code error: frame argument is missing" )
	
	local selected = ArkInventory.db.char.option.ldb.pets.selected
	
	--ArkInventory.Output( level, " / ", offset, " / ", value )
	
	if ( level == offset + 1 ) and ( ( offset == 0 ) or ( value and ( value == "INSERT_LOCATION_MENU" ) ) ) then
		
		local n = ArkInventory.PetJournal.NumPets( )
		
		if n > 0 then
			
			for i = 1, C_PetJournal.GetNumPetTypes( ) do
				ArkInventory.Lib.Dewdrop:AddLine(
					"text", ArkInventory.PetJournal.PetTypeName( i ),
					"hasArrow", true,
					"value", string.format( "PETTYPE_%s", i )
				)
			end
			
			ArkInventory.Lib.Dewdrop:AddLine( )
			
			local companionName = ArkInventory.Localise["RANDOM"]
			local tooltipText = ArkInventory.Localise["CLICK_TO_SELECT"]
			
			local checked = ( ArkInventory.LDB.Companion.GetSelectedCount( selected ) == 0 )
			if checked then
				companionName = string.format( "%s%s", GREEN_FONT_COLOR_CODE, companionName )
				tooltipText = nil
			end
				
			ArkInventory.Lib.Dewdrop:AddLine(
				"text", companionName,
				"tooltipTitle", companionName,
				"tooltipText", tooltipText,
				"checked", checked,
				"notClickable", checked,
				"func", function( )
					for k, v in pairs( selected ) do
						if v == true then
							selected[k] = nil
						end
					end
					ArkInventory.LDB.Pets:Update( )
				end
			)
			
		end
		
		if n == 0 then
			
			ArkInventory.Lib.Dewdrop:AddLine(
				"text", ArkInventory.Localise["LDB_COMPANION_NONE"],
				"disabled", true
			)
			
		end
		
	end
	
	if ( level == offset + 2 ) and value then
		
		local petType0 = string.match( value, "^PETTYPE_(.+)$" )
		
		if petType0 then
			
			petType0 = tonumber( petType0 )
			
			for petID, pd in ArkInventory.PetJournal.IteratePetIDs( ) do
				
				if ( pd.sd.petType == petType0 ) then
					
					local name = pd.sd.name
					
					if pd.customName and pd.customName ~= "" then
						name = string.format( "%s (%s)", name, pd.customName )
					end
					
					--companionCount = companionCount + 1
					
					local text = name
					local tooltipText = ""
					local icon = ""
					
					if selected[petID] == true then
						icon = ArkInventory.Const.Texture.Yes
						text = string.format( "%s%s|r", GREEN_FONT_COLOR_CODE, name )
					elseif selected[petID] == false then
						icon = ArkInventory.Const.Texture.No
						text = string.format( "%s%s|r", RED_FONT_COLOR_CODE, name )
					else
						-- nil
					end
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"icon", icon,
						"text", text,
						"tooltipTitle", name,
						"tooltipText", tooltipText,
						"hasArrow", true,
						"value", string.format( "PETID_%s", petID )
					)
				
				end
				
			end
		
		end
		
	end
		
	if ( level == offset + 3 ) and value then
		
		local petID = string.match( value, "^PETID_(.+)$" )
		
		if petID then
			
			local pd = ArkInventory.PetJournal.GetPetInfo( petID )
			
			local selected = ArkInventory.db.char.option.ldb.pets.selected
			
			ArkInventory.Lib.Dewdrop:AddLine(
				"text", pd.fullName,
				"isTitle", true,
				"textHeight", 14
			)
			
			ArkInventory.Lib.Dewdrop:AddLine( )
			
			ArkInventory.Lib.Dewdrop:AddLine(
				"text", string.format( "%s%s%s", GREEN_FONT_COLOR_CODE, ArkInventory.Localise["CLICK_TO_SELECT"], FONT_COLOR_CODE_CLOSE ),
				"tooltipTitle", pd.fullName,
				"tooltipText", string.format( ArkInventory.Localise["LDB_COMPANION_SELECT"], pd.fullName ),
				"checked", selected[petID] == true,
				"disabled", selected[petID] == true,
				"isRadio", true,
				"func", function( )
					selected[petID] = true
					ArkInventory.LDB.Pets:Update( )
				end
			)
	
			ArkInventory.Lib.Dewdrop:AddLine(
				"text", string.format( "%s%s%s", RED_FONT_COLOR_CODE, ArkInventory.Localise["CLICK_TO_IGNORE"], FONT_COLOR_CODE_CLOSE ),
				"tooltipTitle", pd.fullName,
				"tooltipText", string.format( ArkInventory.Localise["LDB_COMPANION_IGNORE"], pd.fullName ),
				"checked", selected[petID] == false,
				"disabled", selected[petID] == false,
				"isRadio", true,
				"func", function( )
					selected[petID] = false
					ArkInventory.LDB.Pets:Update( )
				end
			)
			
			if selected[petID] ~= nil then
				ArkInventory.Lib.Dewdrop:AddLine(
					"text", string.format( "%s%s%s", HIGHLIGHT_FONT_COLOR_CODE, ArkInventory.Localise["CLICK_TO_DESELECT"], FONT_COLOR_CODE_CLOSE ),
					"tooltipTitle", pd.fullName,
					"tooltipText", string.format( ArkInventory.Localise["LDB_COMPANION_DESELECT"], pd.fullName ),
					"isRadio", true,
					"func", function( )
						selected[petID] = nil
						ArkInventory.LDB.Pets:Update( )
					end
				)
			end
			
			ArkInventory.Lib.Dewdrop:AddLine( )
			
			local txt = BATTLE_PET_SUMMON
			local activeID = C_PetJournal.GetSummonedPetGUID( )
			if activeID and activeID == petID then
				txt = PET_ACTION_DISMISS
			end
			
			ArkInventory.Lib.Dewdrop:AddLine(
				"text", txt,
				"tooltipTitle", pd.fullName,
				"tooltipText", BATTLE_PETS_SUMMON_TOOLTIP,
				"disabled", not C_PetJournal.PetIsSummonable( petID ),
				"func", function( )
					C_PetJournal.SummonPetByGUID( petID )
				end
			)
			
		end
		
	end
	
end

function ArkInventory.MenuLDBPetsOpen( frame )
	
	assert( frame, "code error: frame argument is missing" )
	
	if ArkInventory.Lib.Dewdrop:IsOpen( frame ) then
		
		ArkInventory.Lib.Dewdrop:Close( )
		
	else
		
		local x, p, rp
		x = frame:GetLeft( ) + ( frame:GetRight( ) - frame:GetLeft( ) ) / 2
		if ( x >= ( GetScreenWidth( ) / 2 ) ) then
			p = "TOPRIGHT"
			rp = "BOTTOMLEFT"
		else
			p = "TOPLEFT"
			rp = "BOTTOMRIGHT"
		end
		
		ArkInventory.Lib.Dewdrop:Open( frame,
			"point", p,
			"relativePoint", rp,
			"children", function( level, value )
				
				if ( level == 1 ) then
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.LDB.Pets.name,
						"isTitle", true,
						"textHeight", 14
					)
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Global.Version,
						"notClickable", true
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
				
				end
				
				ArkInventory.MenuPets( frame, level, value, 0 )
				
				if level == 1 then
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", ArkInventory.Localise["CLOSE_MENU"],
						"closeWhenClicked", true
					)
					
				end
				
			end
		)

	end
	
end

function ArkInventory.MenuBattlePet( frame, petID )
	
	assert( frame, "code error: frame argument is missing" )
	assert( petID, "code error: petID argument is missing" )

	if ArkInventory.Lib.Dewdrop:IsOpen( frame ) then
	
		ArkInventory.Lib.Dewdrop:Close( )
	
	else

		local x, p, rp
		x = frame:GetLeft( ) + ( frame:GetRight( ) - frame:GetLeft( ) ) / 2
		if ( x >= ( GetScreenWidth( ) / 2 ) ) then
			p = "TOPRIGHT"
			rp = "BOTTOMLEFT"
		else
			p = "TOPLEFT"
			rp = "BOTTOMRIGHT"
		end
		
		ArkInventory.Lib.Dewdrop:Open( frame,
			"point", p,
			"relativePoint", rp,
			"children", function( level, value )
				
				local pd = ArkInventory.PetJournal.GetPetInfo( petID )
				
				--ArkInventory.Output( petID )
				
				if pd then
					
					--ArkInventory.Output( pd.fullName, " / ", pd.rarity, " / ", pd.link )

				if ( level == 1 ) then
					
					--name = string.format( "%s%s|r", select( 5, ArkInventory.GetItemQualityColor( pd.rarity ) ), pd.fullName )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", pd.fullName,
						"isTitle", true,
						"icon", pd.sd.icon,
						"textHeight", 14
					)
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					local isRevoked = C_PetJournal.PetIsRevoked( petID )
					local isLockedForConvert = C_PetJournal.PetIsLockedForConvert( petID )
					
					if ( not isRevoked ) and ( not isLockedForConvert ) then
						
						local txt = BATTLE_PET_SUMMON
						if ( C_PetJournal.GetSummonedPetGUID( ) == petID ) then
							txt = PET_DISMISS
						end
						
						-- summon / dismiss
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", txt,
							"disabled", not C_PetJournal.PetIsSummonable( petID ),
							"closeWhenClicked", true,
							"func", function( info )
								C_PetJournal.SummonPetByGUID( petID )
							end
						)
						
						-- rename
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", BATTLE_PET_RENAME,
							"disabled", not C_PetJournal.IsJournalUnlocked( ),
							"closeWhenClicked", true,
							"func", function( info )
								ArkInventory.Lib.StaticDialog:Spawn( "BATTLE_PET_RENAME", petID )
							end
						)
						
						-- enable / disable favourite
						if pd.favorite then
							txt = BATTLE_PET_UNFAVORITE
						else
							txt = BATTLE_PET_FAVORITE
						end
						
						ArkInventory.Lib.Dewdrop:AddLine(
							"text", txt,
							"disabled", not C_PetJournal.IsJournalUnlocked( ),
							"closeWhenClicked", true,
							"func", function( info )
								if pd.favorite then
									C_PetJournal.SetFavorite( petID, 0 )
								else
									C_PetJournal.SetFavorite( petID, 1 )
								end
							end
						)
						
						-- release
						if C_PetJournal.PetCanBeReleased( petID ) then
							
							txt = nil
							if C_PetBattles.IsInBattle( ) then
								txt2 = "in battle"
							elseif C_PetJournal.PetIsSlotted( petID ) then
								txt = "slotted"
							end
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", BATTLE_PET_RELEASE,
								"tooltipTitle", BATTLE_PET_RELEASE,
								"tooltipText", txt,
								"disabled", C_PetBattles.IsInBattle( ) or C_PetJournal.PetIsSlotted( petID ),
								"closeWhenClicked", true,
								"func", function( info )
									ArkInventory.Lib.StaticDialog:Spawn( "BATTLE_PET_RELEASE", petID )
								end
							)
						end
						
						-- cage
						if C_PetJournal.PetIsTradable( petID ) then
							
							txt = BATTLE_PET_PUT_IN_CAGE
							
							if C_PetJournal.PetIsSlotted( petID ) then
								txt = BATTLE_PET_PUT_IN_CAGE_SLOTTED
							elseif C_PetJournal.PetIsHurt( petID ) then
								txt = BATTLE_PET_PUT_IN_CAGE_HEALTH
							end
							
							ArkInventory.Lib.Dewdrop:AddLine(
								"text", txt,
								"disabled", C_PetJournal.PetIsSlotted( petID ) or C_PetJournal.PetIsHurt( petID ),
								"closeWhenClicked", true,
								"func", function( info )
									ArkInventory.Lib.StaticDialog:Spawn( "BATTLE_PET_PUT_IN_CAGE", petID )
								end
							)
						end
						
					end
					
				end
				
				else
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", "pet data not found",
						"tooltipTitle", "error",
						"tooltipText", "pet data not found",
						"disabled", true
					)

				end
				
				if ( level == 1 ) then
					
					ArkInventory.Lib.Dewdrop:AddLine( )
					
					ArkInventory.Lib.Dewdrop:AddLine(
						"text", CANCEL,
						"closeWhenClicked", true
					)
					
				end
				
			end
		)

	end
	
end
