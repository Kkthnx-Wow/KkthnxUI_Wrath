local K, C = unpack(select(2, ...))
local Module = K:NewModule("WorldMap")

local _G = _G
local table_insert = _G.table.insert

local C_Map_GetBestMapForUnit = _G.C_Map.GetBestMapForUnit
local WorldMapFrame = _G.WorldMapFrame

local currentMapID, playerCoords, cursorCoords

local function GetCursorCoords()
	if not WorldMapFrame.ScrollContainer:IsMouseOver() then
		return
	end

	local cursorX, cursorY = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
	if cursorX < 0 or cursorX > 1 or cursorY < 0 or cursorY > 1 then
		return
	end

	return cursorX, cursorY
end

local function CoordsFormat(owner, none)
	local text = none and ": --, --" or ": %.1f, %.1f"
	return owner..K.MyClassColor..text
end

local function GetQuestDifficultyColor(level, playerLevel)
	level = level - (playerLevel or UnitLevel("player"))
	if (level > 4) then
		return K.RGBToHex(K.oUF.colors.reaction[2])
	elseif (level > 2) then
		return K.RGBToHex(K.oUF.colors.reaction[4])
	elseif (level >= -2) then
		return K.RGBToHex(K.oUF.colors.selection[3])
	elseif (level >= -GetQuestGreenRange()) then
		return K.RGBToHex(K.oUF.colors.reaction[5])
	else
		return K.RGBToHex(K.oUF.colors.selection[5])
	end
end

local function UpdateCoords(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.1 then
		local cursorX, cursorY = GetCursorCoords()
		if cursorX and cursorY then
			cursorCoords:SetFormattedText(CoordsFormat("Cursor"), 100 * cursorX, 100 * cursorY)
		else
			cursorCoords:SetText(CoordsFormat("Cursor", true))
		end

		if not currentMapID then
			playerCoords:SetText(CoordsFormat(PLAYER, true))
		else
			local x, y = K.GetPlayerMapPos(currentMapID)
			if not x or (x == 0 and y == 0) then
				playerCoords:SetText(CoordsFormat(PLAYER, true))
			else
				playerCoords:SetFormattedText(CoordsFormat(PLAYER), 100 * x, 100 * y)
			end
		end

		self.elapsed = 0
	end
end

local function UpdateMapID(self)
	if self:GetMapID() == C_Map_GetBestMapForUnit("player") then
		currentMapID = self:GetMapID()
	else
		currentMapID = nil
	end
end

local function CreateMapCoords()
	if not C["WorldMap"].Coordinates then
		return
	end

	local coordsFrame = CreateFrame("FRAME", nil, WorldMapFrame.ScrollContainer)
	coordsFrame:SetSize(WorldMapFrame:GetWidth(), 17)
	coordsFrame:SetPoint("BOTTOMLEFT", 17)
	coordsFrame:SetPoint("BOTTOMRIGHT", 0)

	coordsFrame.Texture = coordsFrame:CreateTexture(nil, "BACKGROUND")
	coordsFrame.Texture:SetAllPoints()
	coordsFrame.Texture:SetTexture(C["Media"].Textures.BlankTexture)
	coordsFrame.Texture:SetVertexColor(0.04, 0.04, 0.04, 0.5)

	-- Create cursor coordinates frame
	cursorCoords = WorldMapFrame.ScrollContainer:CreateFontString(nil, "OVERLAY")
	cursorCoords:FontTemplate(nil, 13, "OUTLINE")
	cursorCoords:SetSize(200, 16)
	cursorCoords:SetParent(coordsFrame)
	cursorCoords:ClearAllPoints()
	cursorCoords:SetPoint("BOTTOMLEFT", 152, 1)
	cursorCoords:SetTextColor(255/255, 204/255, 102/255)

	-- Create player coordinates frame
	playerCoords = WorldMapFrame.ScrollContainer:CreateFontString(nil, "OVERLAY")
	playerCoords:FontTemplate(nil, 13, "OUTLINE")
	playerCoords:SetSize(200, 16)
	playerCoords:SetParent(coordsFrame)
	playerCoords:ClearAllPoints()
	playerCoords:SetPoint("BOTTOMRIGHT", -132, 1)
	playerCoords:SetTextColor(255/255, 204/255, 102/255)

	hooksecurefunc(WorldMapFrame, "OnFrameSizeChanged", UpdateMapID)
	hooksecurefunc(WorldMapFrame, "OnMapChanged", UpdateMapID)

	local CoordsUpdater = CreateFrame("Frame", nil, WorldMapFrame)
	CoordsUpdater:SetScript("OnUpdate", UpdateCoords)
end

local function UpdateMapScale(self)
	if self.isMaximized and self:GetScale() ~= 1 then
		self:SetScale(1)
	elseif not self.isMaximized and self:GetScale() ~= 0.7 then
		self:SetScale(0.7)
	end
end

local function UpdateMapAnchor(self)
	UpdateMapScale(self)
	if not self.isMaximized then
		K.RestoreMoverFrame(self)
	end
end

local function isMouseOverMap()
	return not WorldMapFrame:IsMouseOver()
end

local function CreateMapFader()
	if C["WorldMap"].FadeWhenMoving then
		PlayerMovementFrameFader.AddDeferredFrame(WorldMapFrame, 0.3, 1, 0.3, isMouseOverMap)
	else
		PlayerMovementFrameFader.RemoveFrame(WorldMapFrame)
	end
end

local function CreateMapPartyDots()
	local WorldMapUnitPin, WorldMapUnitPinSizes
	local partyTexture = "Interface\\OptionsFrame\\VoiceChat-Record" -- Blizzard stopped using atlas API on worldmap dots in 38921

	local function setPinTexture(self)
		self:SetPinTexture("raid", partyTexture)
		self:SetPinTexture("party", partyTexture)
	end

	-- Set group icon textures
	for pin in WorldMapFrame:EnumeratePinsByTemplate("GroupMembersPinTemplate") do
		WorldMapUnitPin = pin
		WorldMapUnitPinSizes = pin.dataProvider:GetUnitPinSizesTable()
		setPinTexture(WorldMapUnitPin)
		hooksecurefunc(WorldMapUnitPin, "UpdateAppearanceData", setPinTexture)
		break
	end

	-- Set party icon size and enable class colors
	WorldMapUnitPinSizes.player = 22
	WorldMapUnitPinSizes.party = 12
	WorldMapUnitPin:SetAppearanceField("party", "useClassColor", true)
	WorldMapUnitPin:SetAppearanceField("raid", "useClassColor", true)
	WorldMapUnitPin:SynchronizePinSizes()
end

local function SetupMapAreaLabel(self)
	self:ClearLabel(MAP_AREA_LABEL_TYPE.AREA_NAME)
	local map = self.dataProvider:GetMap()
	if (map:IsCanvasMouseFocus()) then
		local name, description
		local uiMapID = map:GetMapID()
		local normalizedCursorX, normalizedCursorY = map:GetNormalizedCursorPosition()
		local positionMapInfo = C_Map.GetMapInfoAtPosition(uiMapID, normalizedCursorX, normalizedCursorY)
		if (positionMapInfo and (positionMapInfo.mapID ~= uiMapID)) then
			name = positionMapInfo.name
			local playerMinLevel, playerMaxLevel, playerFaction, playerMinFishing
			if (C.MapZoneData[positionMapInfo.mapID]) then
				playerMinLevel = C.MapZoneData[positionMapInfo.mapID].minLevel
				playerMaxLevel = C.MapZoneData[positionMapInfo.mapID].maxLevel
				playerFaction = C.MapZoneData[positionMapInfo.mapID].faction
			end

			if (playerFaction) then
				local englishFaction = K.Faction
				if (playerFaction == "Alliance") then
					description = string.format(FACTION_CONTROLLED_TERRITORY, FACTION_ALLIANCE)
				elseif (playerFaction == "Horde") then
					description = string.format(FACTION_CONTROLLED_TERRITORY, FACTION_HORDE)
				end

				if (englishFaction == playerFaction) and playerMinFishing then
					description = K.RGBToHex(K.oUF.colors.reaction[5])..description..FONT_COLOR_CODE_CLOSE
				else
					description = K.RGBToHex(K.oUF.colors.reaction[2])..description..FONT_COLOR_CODE_CLOSE
				end
			end

			if (name and playerMinLevel and playerMaxLevel and (playerMinLevel > 0) and (playerMaxLevel > 0)) then
				local playerLevel = K.Level
				local color
				if (playerLevel < playerMinLevel) then
					color = GetQuestDifficultyColor(playerMinLevel, playerLevel)
				elseif (playerLevel > playerMaxLevel) then
					-- subtract 2 from the maxLevel so zones entirely below the player's level won't be yellow
					color = GetQuestDifficultyColor(playerMaxLevel - 2, playerLevel)
				else
					color = K.RGBToHex(K.oUF.colors.reaction[4])
				end

				if (playerMinLevel ~= playerMaxLevel) then
					name = name..color.." ("..playerMinLevel.."-"..playerMaxLevel..")"..FONT_COLOR_CODE_CLOSE
				else
					name = name..color.." ("..playerMaxLevel..")"..FONT_COLOR_CODE_CLOSE
				end
			end
		else
			name = MapUtil.FindBestAreaNameAtMouse(uiMapID, normalizedCursorX, normalizedCursorY)
		end
		if name then
			self:SetLabel(MAP_AREA_LABEL_TYPE.AREA_NAME, name, description)
		end
	end

	self:EvaluateLabels()
end

local function CreateZoneLevels()
	for provider in next, WorldMapFrame.dataProviders do
		if provider.setAreaLabelCallback then
			provider.Label:SetScript("OnUpdate", SetupMapAreaLabel)
		end
	end
end

local function CreateRememberZoom()
	if not C["WorldMap"].RememberZoom then
		return
	end

	-- Store initial pan and zoom settings
	local lastZoomLevel = WorldMapFrame.ScrollContainer:GetCanvasScale()
	local lastHorizontal = WorldMapFrame.ScrollContainer:GetNormalizedHorizontalScroll()
	local lastVertical = WorldMapFrame.ScrollContainer:GetNormalizedVerticalScroll()
	local lastMapID = WorldMapFrame.mapID

	-- Store pan and zoom settings when map is hidden
	WorldMapFrame:HookScript("OnHide", function()
		lastZoomLevel = WorldMapFrame.ScrollContainer:GetCanvasScale()
		lastHorizontal = WorldMapFrame.ScrollContainer:GetNormalizedHorizontalScroll()
		lastVertical = WorldMapFrame.ScrollContainer:GetNormalizedVerticalScroll()
		lastMapID = WorldMapFrame.mapID
	end)

	-- Restore pan and zoom settings when map is shown
	WorldMapFrame:HookScript("OnShow", function()
		if WorldMapFrame.mapID == lastMapID then
			WorldMapFrame.ScrollContainer:InstantPanAndZoom(lastZoomLevel, lastHorizontal, lastVertical)
			WorldMapFrame.ScrollContainer:SetPanTarget(lastHorizontal, lastVertical)
			WorldMapFrame.ScrollContainer:Hide(); WorldMapFrame.ScrollContainer:Show()
		end
	end)
end

local function CreateAutoZoneChange()
	if not C["WorldMap"].AutoZoneChange then
		return
	end

	local constMapZone, constPlayerZone

	-- Store map zone and player zone when map changes
	hooksecurefunc(WorldMapFrame, "OnMapChanged", function()
		constMapZone = WorldMapFrame.mapID
		constPlayerZone = C_Map.GetBestMapForUnit("player")
	end)

	-- If map zone was player zone before zone change, set map zone to player zone after zone change
	local zoneEvent = CreateFrame("FRAME")
	zoneEvent:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	zoneEvent:RegisterEvent("ZONE_CHANGED")
	zoneEvent:RegisterEvent("ZONE_CHANGED_INDOORS")
	zoneEvent:SetScript("OnEvent", function()
		local newMapID = WorldMapFrame.mapID
		local newPlayerZone = C_Map.GetBestMapForUnit("player")
		if newMapID and newMapID > 0 and newPlayerZone and newPlayerZone > 0 and constPlayerZone and constPlayerZone > 0 and newMapID == constPlayerZone then
			if C_Map.MapHasArt(newPlayerZone) then -- Needed for dungeons
				WorldMapFrame:SetMapID(newPlayerZone)
			end
		end
		constPlayerZone = C_Map.GetBestMapForUnit("player")
	end)
end

function Module:OnEnable()
	if not C["WorldMap"].SmallWorldMap then
		return
	end

	if IsAddOnLoaded("Mapster") then
		return
	end

	if IsAddOnLoaded("Leatrix_Maps") then
		return
	end

	-- Fix worldmap cursor when scaling
	WorldMapFrame.ScrollContainer.GetCursorPosition = function(f)
		local x, y = MapCanvasScrollControllerMixin.GetCursorPosition(f)
		local scale = WorldMapFrame:GetScale()
		return x / scale, y / scale
	end

	-- Fix scroll zooming in classic
	WorldMapFrame.ScrollContainer:HookScript("OnMouseWheel", function(self, delta)
		local x, y = self:GetNormalizedCursorPosition()
		local nextZoomOutScale, nextZoomInScale = self:GetCurrentZoomRange()
		if delta == 1 then
			if nextZoomInScale > self:GetCanvasScale() then
				self:InstantPanAndZoom(nextZoomInScale, x, y)
			end
		else
			if nextZoomOutScale < self:GetCanvasScale() then
				self:InstantPanAndZoom(nextZoomOutScale, x, y)
			end
		end
	end)

	K.CreateMoverFrame(WorldMapFrame, nil, true)
	UpdateMapScale(WorldMapFrame)
	WorldMapFrame:HookScript("OnShow", UpdateMapAnchor)

	-- Default elements
	WorldMapFrame.BlackoutFrame:Hide()
	WorldMapFrame:SetFrameStrata("MEDIUM")
	WorldMapFrame.BorderFrame:SetFrameStrata("MEDIUM")
	WorldMapFrame.BorderFrame:SetFrameLevel(1)
	WorldMapFrame:SetAttribute("UIPanelLayout-area", "center")
	WorldMapFrame:SetAttribute("UIPanelLayout-enabled", false)
	WorldMapFrame:SetAttribute("UIPanelLayout-allowOtherPanels", true)
	WorldMapFrame.HandleUserActionToggleSelf = function()
		if WorldMapFrame:IsShown() then
		 	WorldMapFrame:Hide()
		else
			WorldMapFrame:Show()
		end
	end
	table_insert(UISpecialFrames, "WorldMapFrame")

	CreateMapPartyDots()
	CreateMapCoords()
	CreateMapFader()
	CreateZoneLevels()
	CreateRememberZoom()
	CreateAutoZoneChange()

	self:CreateWorldMapReveal()
	self:CreateWowHeadLinks()
end