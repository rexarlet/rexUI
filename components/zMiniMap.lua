zUI:RegisterComponent("zMiniMap", function () 

--zUI.zMiniMap = CreateFrame("Frame", nil, UIParent);
--zUI.zMiniMap:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE") -- register events to listen to

--zUI.zMiniMap:SetScript( "OnEvent", function() 
	-- do something
--end)

GameTimeFrame:Hide()
if (C.global.darkmode == "1") then
	MinimapBorder:SetTexture("Interface\\AddOns\\rexUI\\img\\MiniMapDark.tga");
else
	MinimapBorder:SetTexture("Interface\\AddOns\\rexUI\\img\\MiniMapLight.tga");
end

MinimapBorderTop:SetTexture("Interface\\AddOns\\rexUI\\img\\MiniMapZoneFlag.tga");
MinimapBorderTop:SetWidth(256);
MinimapBorderTop:SetTexCoord(1, 0, 0, 1)
MinimapBorderTop:ClearAllPoints()
MinimapBorderTop:SetPoint('TOP', Minimap, 0, 23)

if not C.position["zMinimapSquared"] then
	C.position["zMinimapSquared"] = { alpha = 1.0, scale = 1.0 }
end
local minimap_settings = C.position["zMinimapSquared"];

local modZoom = function()
    if not arg1 then return end

	if (arg1 > 0 and Minimap:GetZoom() < 5) then
        Minimap:SetZoom(Minimap:GetZoom() + 1)
    elseif arg1 < 0 and Minimap:GetZoom() > 0 then
        Minimap:SetZoom(Minimap:GetZoom() - 1)
    end
end

local f = CreateFrame('Frame', nil, Minimap)
f:EnableMouse(false)
f:SetPoint('TOPLEFT', Minimap)
f:SetPoint('BOTTOMRIGHT', Minimap)
f:EnableMouseWheel(true)
f:SetScript('OnMouseWheel', modZoom)

for _, v in pairs({
    --MinimapBorderTop,
    MinimapToggleButton,
    MinimapZoomIn,
	MinimapZoomOut
}) do
    v:Hide()
end

MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetPoint('TOPRIGHT', 0, -10)

MinimapZoneText:ClearAllPoints()
MinimapZoneText:SetPoint('TOP', Minimap, 0, 17)
MinimapZoneText:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE')

zUI.zClock = CreateFrame("Button", "zClockButton", Minimap);
zUI.zClock:SetWidth(60);
zUI.zClock:SetHeight(16);
zUI.zClock:SetPoint('BOTTOM', Minimap, -2, -8);

zClockText = zUI.zClock:CreateFontString("zClockText", "OVERLAY");
zClockText:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE');
zClockText:SetTextColor(1, 1, 1);
zClockText:SetPoint('CENTER', zUI.zClock, 'CENTER', 0, 0);

local zdeltaTime = 1;
local clockMode = "LOCAL"; -- "LOCAL" or "SERVER"

local function zClock_UpdateDisplay()
	if clockMode == "SERVER" then
		local sHour, sMin = GetGameTime();
		zClockText:SetText(format("%02d:%02d", sHour, sMin));
	else
		zClockText:SetText(date("%H:%M"));
	end
end

zUI.zClock:SetScript("OnUpdate", function()
	local elapsed = arg1 or 0;
	zdeltaTime = zdeltaTime + elapsed;

	if (zdeltaTime >= 1.0) then
		zClock_UpdateDisplay();
		zdeltaTime = 0;
	end
end);

zUI.zClock:EnableMouse(true);
zUI.zClock:RegisterForClicks("LeftButtonUp", "RightButtonUp");

local function zToggleCalendar()
	local calCmd = SlashCmdList and (SlashCmdList["CALENDAR"] or SlashCmdList["Calendar"] or SlashCmdList["calendar"] or SlashCmdList["TOGGLECALENDAR"]);
	if calCmd then
		calCmd("");
		return;
	end

	if hash_SlashCmdList then
		local calHash = hash_SlashCmdList["/CALENDAR"] or hash_SlashCmdList["/calendar"];
		if calHash then
			calHash("");
			return;
		end
	end

	local editBox = ChatFrameEditBox or (DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.editBox);
	if editBox and ChatEdit_SendText then
		editBox:SetText("/calendar");
		ChatEdit_SendText(editBox, 0);
		return;
	end

	if ToggleCalendar then
		ToggleCalendar();
	elseif Calendar_LoadUI then
		Calendar_LoadUI();
		if ToggleCalendar then
			ToggleCalendar();
		elseif CalendarFrame then
			if CalendarFrame:IsShown() then
				CalendarFrame:Hide();
			else
				CalendarFrame:Show();
			end
		end
	elseif CalendarFrame then
		if CalendarFrame:IsShown() then
			CalendarFrame:Hide();
		else
			CalendarFrame:Show();
		end
	elseif GameTimeFrame_OnClick then
		GameTimeFrame_OnClick(GameTimeFrame or this);
	elseif GameTimeFrame then
		local ok, script = pcall(function() return GameTimeFrame:GetScript("OnClick") end);
		if ok and script then
			script(GameTimeFrame or this);
		elseif GameTimeFrame:IsShown() then
			GameTimeFrame:Hide();
		else
			GameTimeFrame:Show();
		end
	end
end

zUI.zClock:SetScript("OnEnter", function()
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT");
	
	local sHour, sMin = GetGameTime();
	local sTime = format("%02d:%02d", sHour, sMin);
	local lTime = date("%H:%M");
	local dStr = date("%A, %d %B %Y");

	GameTooltip:AddLine("Time & Date Info", 1, 0.82, 0);
	GameTooltip:AddDoubleLine("Local Time:", lTime, 1, 1, 1, 1, 1, 1);
	GameTooltip:AddDoubleLine("Server Time:", sTime, 1, 1, 1, 1, 1, 1);
	GameTooltip:AddDoubleLine("Date:", dStr, 1, 1, 0.8, 1, 1, 0.8);
	GameTooltip:AddLine(" ", 1, 1, 1);
	GameTooltip:AddLine("Left Click: Toggle Local / Server time", 0.7, 0.7, 0.7);
	GameTooltip:AddLine("Right Click: Open Calendar / Clock Window", 0.7, 0.7, 0.7);

	GameTooltip:Show();
end);

zUI.zClock:SetScript("OnLeave", function()
	GameTooltip:Hide();
end);

zUI.zClock:SetScript("OnClick", function()
	if arg1 == "RightButton" then
		zToggleCalendar();
	else
		if clockMode == "LOCAL" then
			clockMode = "SERVER"
		else
			clockMode = "LOCAL"
		end
		zClock_UpdateDisplay();
	end
end);
--zUI.zClock:SetScript("OnShow", function(self)
--	zdeltaTime = 0;
--end)

--SetFont("Fonts\\ARIALN.TTF", 10)

--MinimapZoneText:SetText("How Many Letters Can We Show Here");
--GameTimeFrame:SetScale(.76)
--GameTimeFrame:ClearAllPoints() GameTimeFrame:SetPoint('BOTTOM', 12, 10)
if (C.minimap.square == "1") then
	MinimapBorder:SetTexture(nil);

	zUI.squaredminimap = CreateFrame("Frame", "zMinimapSquared", UIParent);
	if (zUI_config["position"]["zMinimapSquared"]) then
		
		if zUI_config["position"]["zMinimapSquared"]["scale"] then
			zUI.squaredminimap:SetScale(zUI_config["position"]["zMinimapSquared"].scale)
		end
		if zUI_config["position"]["zMinimapSquared"]["xpos"] then
			zUI.squaredminimap:ClearAllPoints()
			zUI.squaredminimap:SetPoint("CENTER",UIParent, "BOTTOMLEFT",zUI_config["position"]["zMinimapSquared"].xpos, zUI_config["position"]["zMinimapSquared"].ypos);
			--zUI.squaredminimap:SetPoint("CENTER",UIParent, "TOPRIGHT",zUI_config["position"]["zMinimapSquared"].xpos, zUI_config["position"]["zMinimapSquared"].ypos);
			--zUI.squaredminimap:SetPoint("BOTTOMLEFT",UIParent,"TOPRIGHT", 0,0);
			--local x,y = zUI.squaredminimap:GetCenter()
		end
	--else
		--zUI.squaredminimap:SetPoint("CENTER", UIParent, -10, -10);
		--zUI.squaredminimap:SetPoint("CENTER", MinimapCluster,"TOP", 9, -92);
	end
	zUI.squaredminimap:SetPoint("TOPRIGHT", UIParent, -10, -10);
	zUI.squaredminimap:SetMovable(true);
	zUI.squaredminimap:EnableMouse(true);
	zUI.squaredminimap:EnableMouseWheel(true);
	zUI.squaredminimap:SetUserPlaced(true);
	zUI.squaredminimap:SetClampedToScreen(true);
	zUI.squaredminimap:SetScript("OnDragStart", function() if IsShiftKeyDown() then this:StartMoving(); end end);
	zUI.squaredminimap:SetScript('OnMouseWheel', modZoom)
    zUI.squaredminimap:SetScript("OnDragStop",  function() 
		this:StopMovingOrSizing(); 

		if not C.position["zMinimapSquared"] then
			C.position["zMinimapSquared"] = {}
		end
		local x,y = this:GetCenter()
		C.position["zMinimapSquared"]["xpos"] = x;
		C.position["zMinimapSquared"]["ypos"] = y;
		this:SetPoint("CENTER",UIParent, "BOTTOMLEFT",x,y);
	end);
    zUI.squaredminimap:RegisterForDrag("LeftButton");
	--zUI.squaredminimap:SetWidth(C.minimap.width)
	zUI.squaredminimap:SetWidth(140);
	zUI.squaredminimap:SetHeight(140);
	zUI.squaredminimap:SetFrameStrata("BACKGROUND");
	zSkin(zUI.squaredminimap, 0);
	zSkinColor(zUI.squaredminimap, 0.3,0.3,0.3);
	--zUI.squaredminimap.backdrop = zUI.loot:CreateTexture(nil, "BACKGROUND")
	--zUI.loot.backdrop:SetTexture(0,0,0,.9)
	--zUI.loot.backdrop:ClearAllPoints()
	--zUI.loot.backdrop:SetAllPoints(zUI.loot)

	Minimap:SetParent(zUI.squaredminimap);
	Minimap:SetPoint("CENTER", zUI.squaredminimap, "CENTER", 1, -1);
	Minimap:SetFrameLevel(1);
	Minimap:SetMaskTexture("Interface\\AddOns\\rexUI\\img\\minimap");
	
	zUI.zClock:SetPoint('BOTTOM', Minimap, 0, 3);
	MinimapZoneText:SetPoint('TOP', Minimap, 0, -2);
	MinimapZoneText:SetDrawLayer("OVERLAY");
	MinimapZoneText:SetNonSpaceWrap(false);
	--MinimapZoneText:SetJustifyH("CENTER");
	MinimapZoneText:SetWidth(120);
	--MinimapZoneText:SetText("ZoneName")
	--MinimapZoneText:SetFrameLevel(2);
	MinimapBorderTop:Hide();
else
	Minimap:SetMaskTexture("Interface\\AddOns\\rexUI\\img\\RoundMask5");
	
end

--local f = CreateFrame('Frame', nil, Minimap)
--f:EnableMouse(false)
--f:SetPoint('TOPLEFT', Minimap)
--f:SetPoint('BOTTOMRIGHT', Minimap)
--f:EnableMouseWheel(true)
--f:SetScript('OnMouseWheel', modZoom)

--for _, v in pairs({ PlayerFrame, TargetFrame, PartyMemberFrame1 }) do
--    v:SetUserPlaced(true) v:SetMovable(true) v:EnableMouse(true)
--    v:SetScript('OnDragStart', function() if IsShiftKeyDown() then this:StartMoving() end end)
--    v:SetScript('OnDragStop',  function() this:StopMovingOrSizing() end)
--    v:RegisterForDrag'LeftButton'
--end

end)

-- Addon Minimap Button Collector Component for rexUI
zUI:RegisterComponent("zMinimapBag", function ()
	zUI.zMinimapBag = CreateFrame("Frame", "zMinimapBagBar", UIParent);
	local bag = zUI.zMinimapBag;
	
	bag:SetFrameStrata("HIGH");
	bag:SetClampedToScreen(true);
	bag:Hide();
	
	if zSkin then
		zSkin(bag, 0);
		if zSkinColor then
			zSkinColor(bag, 0.2, 0.2, 0.2, 0.9);
		end
	end

	local ignoreFrames = {
		["Minimap"] = true,
		["MinimapCluster"] = true,
		["MinimapBorder"] = true,
		["MinimapBorderTop"] = true,
		["MinimapZoneText"] = true,
		["MinimapZoneTextButton"] = true,
		["MinimapToggleButton"] = true,
		["MinimapZoomIn"] = true,
		["MinimapZoomOut"] = true,
		["MinimapBackdrop"] = true,
		["MiniMapTrackingFrame"] = true,
		["MiniMapTracking"] = true,
		["MiniMapTrackingButton"] = true,
		["MiniMapTrackingBorder"] = true,
		["MiniMapMailFrame"] = true,
		["MiniMapMailIcon"] = true,
		["MiniMapMailBorder"] = true,
		["MiniMapBattlefieldFrame"] = true,
		["MiniMapBattlefieldIcon"] = true,
		["MiniMapBattlefieldBorder"] = true,
		["MiniMapMeetingStoneFrame"] = true,
		["MiniMapPing"] = true,
		["GameTimeFrame"] = true,
		["TimeManagerMinimapButton"] = true,
		["TimeManagerClockButton"] = true,
		["FeedbackUIButton"] = true,
		["MinimapVoiceChatFrame"] = true,
		["MiniMapWorldMapButton"] = true,
		["GuildInstanceDifficulty"] = true,
		["MiniMapLFGFrame"] = true,
		["MiniMapRecordingButton"] = true,
		["MinimapPlayerModel"] = true,
		["BookOfTracksFrame"] = true,
		["GatherNote"] = true,
		["FishingExtravaganzaMini"] = true,
		["MiniNotePOI"] = true,
		["RecipeRadarMinimapIcon"] = true,
		["FWGMinimapPOI"] = true,
		["MBB_MinimapButtonFrame"] = true,
		["QuestieNote"] = true,
		["MetaMap"] = true,
		["LootLinkMinimapButton"] = true,
		["pfMiniMapPin"] = true,
		["Clock"] = true,
		["Timer"] = true,
		["zMiniMapButtonFrame"] = true,
		["zMiniMapButton"] = true,
		["zClockButton"] = true,
		["zClockText"] = true,
		["zMinimapSquared"] = true,
		["zMinimapBagBar"] = true,
	};

	local ignoreSubstrings = {
		"note", "poi", "pin", "model", "arrow", "marker", "ping"
	};

	local gatheredButtons = {};

	local function IsMinimapButton(frame)
		if not frame or not frame.GetName or not frame.IsObjectType then return false end

		local name = frame:GetName();
		if not name or name == "" then return false end

		if ignoreFrames[name] then return false end

		local lowerName = string.lower(name);
		for _, sub in ipairs(ignoreSubstrings) do
			if string.find(lowerName, sub) then
				return false;
			end
		end

		local isButton = frame:IsObjectType("Button") or frame:IsObjectType("Frame");
		if not isButton then return false end

		local parent = frame:GetParent();
		local parentName = parent and parent:GetName();
		local isMinimapParent = (parent == Minimap or parent == MinimapCluster or parentName == "Minimap" or parentName == "MinimapCluster");

		if isMinimapParent then
			return true;
		end

		if (string.find(lowerName, "minimap") or string.find(lowerName, "libdbicon") or string.find(lowerName, "mbb")) then
			return true;
		end

		return false;
	end

	function zUI:GatherMinimapButtons()
		local children = { Minimap:GetChildren() };
		if MinimapCluster then
			local mcChildren = { MinimapCluster:GetChildren() };
			for _, child in ipairs(mcChildren) do
				table.insert(children, child);
			end
		end

		for _, child in ipairs(children) do
			if IsMinimapButton(child) then
				local alreadyAdded = false;
				for _, b in ipairs(gatheredButtons) do
					if b == child then
						alreadyAdded = true;
						break;
					end
				end
				if not alreadyAdded then
					table.insert(gatheredButtons, child);
				end
			end
		end

		local iconSize = 24;
		local padding = 6;
		local spacing = 4;
		local count = 0;

		for _, btn in ipairs(gatheredButtons) do
			if btn and btn.SetParent then
				local w = btn:GetWidth() or 0;
				local h = btn:GetHeight() or 0;
				if btn:IsShown() and w > 0 and h > 0 then
					btn:SetParent(bag);
					btn:ClearAllPoints();
					btn:SetPoint("LEFT", bag, "LEFT", padding + count * (iconSize + spacing), 0);
					btn:SetWidth(iconSize);
					btn:SetHeight(iconSize);
					btn:Show();
					count = count + 1;
				end
			end
		end

		if count > 0 then
			local totalWidth = (padding * 2) + (count * iconSize) + ((count - 1) * spacing);
			local totalHeight = iconSize + (padding * 2);
			bag:SetWidth(totalWidth);
			bag:SetHeight(totalHeight);
		else
			bag:SetWidth(100);
			bag:SetHeight(iconSize + (padding * 2));
		end
	end

	function zUI:ToggleMinimapBag()
		if bag:IsShown() then
			bag:Hide();
		else
			zUI:GatherMinimapButtons();
			local refFrame = zMiniMapButtonFrame or Minimap;
			bag:ClearAllPoints();
			if refFrame then
				bag:SetPoint("TOPRIGHT", refFrame, "BOTTOMRIGHT", 0, -4);
			else
				bag:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
			end
			bag:Show();
		end
	end

	bag:RegisterEvent("PLAYER_ENTERING_WORLD");
	bag:RegisterEvent("ADDON_LOADED");
	bag:SetScript("OnEvent", function()
		zUI:GatherMinimapButtons();
	end);
end);