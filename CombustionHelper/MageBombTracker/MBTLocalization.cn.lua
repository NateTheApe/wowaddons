-- translation notice : don't change the keys of tables or it won't work anymore (the text within the [ ]), the color coding part mustn't be changed either (|cff00ffff and |r).

-------------------------------
-- table for chat report settings, no problem changing the text lenght as it's outputted to chat frame
CombuMBTrackerLocCN = {["lockon"] = "|cff00ffff炸弹监控被锁定|r",
			["lockoff"] = "|cff00ffff炸弹监控没有被锁定|r",
			["reporton"] = "|cff00ffff开启炸弹监控状态报告|r",
			["lbon"] = "|cff00ffff开启炸弹刷新模式|r",
			["lboff"] = "|cff00ffff关闭炸弹刷新模式|r",
			["fson"] = "|cff00ffff开启烈焰风暴监控|r",
			["fsoff"] = "|cff00ffff关闭烈焰风暴监控|r",
			["lbtrackon"] = "|cff00ffff开启炸弹监控|r",
			["lbtrackoff"] = "|cff00ffff关闭炸弹监控|r",
			["reset"] = "|cff00ffff重置炸弹监控|r",
			["startup"] = "|cff00ffffMageBombTracker is loaded. Interface Panel -> Addons for Config.|r",
			["lbrefresh"] = "|cffff0000 -- 炸弹施放于 |cffffffff%s |cffff0000过早. --|r",
			["lbmiss"] = "|cffff00ff -- 炸弹施放于 |cffffffff%s |cffff00ff未命中 !! --",
			["lbreport"] = "|cffff0000 -- 战斗中过早施放炸弹 : |cffffffff%d |cffff0000--|r",
			["slashcomm"] = "|cff00ffff打开炸弹监控的配置面板|r",
			}
			

-------------------------------
-- table for option panel localisation, try to stick to the lenght as it could overflow if bigger
CombuMBTrackerOptLocCN = {
	["CombuMBTrackerScaleSlider"] = "尺寸",
	["CombuMBTrackerlockButton"] = "锁定炸弹监控",
	["CombuMBTrackerrefreshButton"] = "过早/丢失活体炸弹警告",
	["CombuMBTrackerchatButton"] = "在聊天框中显示设置信息",
	["CombuMBTrackerButton"] = "启用炸弹监控",
	["CombuMBTrackertargetButton"] = "标记当前目标",
	["CombuMBTrackerAutohideInfo"] = "自动隐藏模式:",
	["CombuMBTrackerFontInfo"] = "文本字体:",
	["CombuMBTrackerBorderInfo"] = "边框材质:",
	["CombuMBTrackerDirectionInfo"] = "扩展方向:",
	["CombuMBTrackerBackgroundInfo"] = "背景材质:",
	["CombuMBTrackerTextureInfo"] = "计时条材质:",
    ["CombuMBTrackerEdgeSizeSlider"] = "边框粗细",
	["CombuMBTrackerresetButton"] = "重置参数",
	["CombuMBTrackerFlamestrikeButton"] = "烈焰风暴监控",
	["CombuMBTrackerTileSizeSlider"] = "纹理大小",
	["CombuMBTrackerTileButton"] = "纹理背景",
	["CombuMBTrackerInsetsSlider"] = "间距",
	["CombuMBTrackerbarcolornormal"] = "计时条色(正常)",
	["CombuMBTrackerbarcolorwarning"] = "计时条色(警告)",
	["CombuMBTrackerbgcolornormal"] = "背景颜色",
	["CombuMBTrackerLanguageInfo"] = "语言:",
	["CombuMBTrackeredgecolornormal"] = "边框颜色",
	["CombuMBtrackerPosition"] = "若要设定多目标活动炸弹监控框架的位置，请从下拉式选单中选择希望将该框架设定于主框架的哪一侧。",
	}
		
-------------------------------
-- table for Living bomb tracker position dropdown
CombuMBTrackerpositionCN = {
   "上方",
   "下方",
   "右方",
   "左方",
   "自由",
	}
		
-------------------------------
-- table for Autohide dropdown
CombuMBTrackerAutohideListCN = {
   "不自动隐藏",
   "脱离战斗时，自动隐藏",
   "没有炸弹时，自动隐藏",
}

-------------------------------
-- table for text within frame, try to stick to the lenght as it could overflow if bigger
CombuMBTrackerLabelCN = {
	["flamestrike"] = "烈焰风暴",
	["blastwave"] = "冲击波",			
	["nobomb"] = "-- 没有炸弹 --",
	}