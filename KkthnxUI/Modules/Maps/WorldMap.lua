local K, C = unpack(KkthnxUI)
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
	return owner .. K.MyClassColor .. text
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
	cursorCoords:SetFontObject(K.UIFontOutline)
	cursorCoords:SetSize(200, 16)
	cursorCoords:SetParent(coordsFrame)
	cursorCoords:ClearAllPoints()
	cursorCoords:SetPoint("BOTTOMLEFT", 152, 1)
	cursorCoords:SetTextColor(255 / 255, 204 / 255, 102 / 255)

	-- Create player coordinates frame
	playerCoords = WorldMapFrame.ScrollContainer:CreateFontString(nil, "OVERLAY")
	playerCoords:SetFontObject(K.UIFontOutline)
	playerCoords:SetSize(200, 16)
	playerCoords:SetParent(coordsFrame)
	playerCoords:ClearAllPoints()
	playerCoords:SetPoint("BOTTOMRIGHT", -132, 1)
	playerCoords:SetTextColor(255 / 255, 204 / 255, 102 / 255)

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

	CreateMapCoords()
	CreateMapFader()

	--self:CreateWorldMapReveal()
	--self:CreateWowHeadLinks()
end
