local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Minimap")

local _G = _G
local pairs = _G.pairs
local select = _G.select

local GetUnitName = _G.GetUnitName
local InCombatLockdown = _G.InCombatLockdown
local Minimap = _G.Minimap
local UnitClass = _G.UnitClass
local hooksecurefunc = _G.hooksecurefunc

-- Create the new minimap tracking dropdown frame and initialize it
local KKUI_MiniMapTrackingDropDown = CreateFrame("Frame", "KKUI_MiniMapTrackingDropDown", _G.UIParent, "UIDropDownMenuTemplate")
KKUI_MiniMapTrackingDropDown:SetID(1)
KKUI_MiniMapTrackingDropDown:SetClampedToScreen(true)
KKUI_MiniMapTrackingDropDown:Hide()
_G.UIDropDownMenu_Initialize(KKUI_MiniMapTrackingDropDown, _G.MiniMapTrackingDropDown_Initialize, "MENU")
KKUI_MiniMapTrackingDropDown.noResize = true

-- Create the minimap micro menu
local menuFrame = CreateFrame("Frame", "KKUI_MinimapRightClickMenu", UIParent, "UIDropDownMenuTemplate")
local micromenu = {
	{
		text = _G.CHARACTER_BUTTON,
		func = function()
			ToggleCharacter("PaperDollFrame")
		end,
	},
	{
		text = _G.SPELLBOOK_ABILITIES_BUTTON,
		func = function()
			if not _G.SpellBookFrame:IsShown() then
				ShowUIPanel(_G.SpellBookFrame)
			else
				HideUIPanel(_G.SpellBookFrame)
			end
		end,
	},
	{
		text = _G.TALENTS_BUTTON,
		func = function()
			if not _G.PlayerTalentFrame then
				_G.TalentFrame_LoadUI()
			end

			local PlayerTalentFrame = _G.PlayerTalentFrame
			if not PlayerTalentFrame:IsShown() then
				ShowUIPanel(PlayerTalentFrame)
			else
				HideUIPanel(PlayerTalentFrame)
			end
		end,
	},
	{
		text = _G.QUEST_LOG,
		func = function()
			ToggleFrame(_G.QuestLogFrame)
		end,
	},
	{ text = _G.CHAT_CHANNELS, func = _G.ToggleChannelFrame },
	{
		text = _G.TIMEMANAGER_TITLE,
		func = function()
			ToggleFrame(_G.TimeManagerFrame)
		end,
	},
	{ text = _G.SOCIAL_BUTTON, func = ToggleFriendsFrame },
	{
		text = _G.MAINMENU_BUTTON,
		func = function()
			if not _G.GameMenuFrame:IsShown() then
				if _G.VideoOptionsFrame:IsShown() then
					_G.VideoOptionsFrameCancel:Click()
				elseif _G.AudioOptionsFrame:IsShown() then
					_G.AudioOptionsFrameCancel:Click()
				elseif _G.InterfaceOptionsFrame:IsShown() then
					_G.InterfaceOptionsFrameCancel:Click()
				end

				CloseMenus()
				CloseAllWindows()
				PlaySound(850) --IG_MAINMENU_OPEN
				ShowUIPanel(_G.GameMenuFrame)
			else
				PlaySound(854) --IG_MAINMENU_QUIT
				HideUIPanel(_G.GameMenuFrame)
				MainMenuMicroButton_SetNormal()
			end
		end,
	},
}

tinsert(micromenu, { text = _G.HELP_BUTTON, func = ToggleHelpFrame })

function Module:CreateStyle()
	local minimapBorder = CreateFrame("Frame", "KKUI_MinimapBorder", Minimap)
	minimapBorder:SetAllPoints(Minimap)
	minimapBorder:SetFrameLevel(Minimap:GetFrameLevel())
	minimapBorder:SetFrameStrata("LOW")
	minimapBorder:CreateBorder()

	local minimapMailPulse = CreateFrame("Frame", nil, Minimap, "BackdropTemplate")
	minimapMailPulse:SetBackdrop({ edgeFile = "Interface\\AddOns\\KkthnxUI\\Media\\Border\\Border_Glow_Overlay", edgeSize = 12 })
	minimapMailPulse:SetPoint("TOPLEFT", minimapBorder, -5, 5)
	minimapMailPulse:SetPoint("BOTTOMRIGHT", minimapBorder, 5, -5)
	minimapMailPulse:SetBackdropBorderColor(1, 1, 0, 0.8)
	minimapMailPulse:Hide()

	local anim = minimapMailPulse:CreateAnimationGroup()
	anim:SetLooping("BOUNCE")
	anim.fader = anim:CreateAnimation("Alpha")
	anim.fader:SetFromAlpha(0.8)
	anim.fader:SetToAlpha(0.2)
	anim.fader:SetDuration(1)
	anim.fader:SetSmoothing("OUT")

	local function updateMinimapBorderAnimation()
		if not InCombatLockdown() then
			if MiniMapMailFrame:IsShown() and not IsInInstance() then
				if not anim:IsPlaying() then
					minimapMailPulse:Show()
					anim:Play()
				end
			else
				if anim and anim:IsPlaying() then
					anim:Stop()
					minimapMailPulse:Hide()
				end
			end
		end
	end
	K:RegisterEvent("PLAYER_REGEN_DISABLED", updateMinimapBorderAnimation)
	K:RegisterEvent("PLAYER_REGEN_ENABLED", updateMinimapBorderAnimation)
	K:RegisterEvent("UPDATE_PENDING_MAIL", updateMinimapBorderAnimation)

	MiniMapMailFrame:HookScript("OnHide", function()
		if InCombatLockdown() then
			return
		end

		if anim and anim:IsPlaying() then
			anim:Stop()
			minimapMailPulse:Hide()
		end
	end)
end

function Module:ReskinRegions()
	-- QueueStatus Button
	if MiniMapBattlefieldFrame then
		MiniMapBattlefieldFrame:ClearAllPoints()
		MiniMapBattlefieldFrame:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", -2, -2)
		MiniMapBattlefieldBorder:Hide()
		MiniMapBattlefieldIcon:SetAlpha(0)
		BattlegroundShine:SetTexture(nil)

		local queueIcon = Minimap:CreateTexture(nil, "ARTWORK")
		queueIcon:SetPoint("CENTER", MiniMapBattlefieldFrame)
		queueIcon:SetSize(50, 50)
		queueIcon:SetTexture("Interface\\Minimap\\Raid_Icon")
		queueIcon:Hide()

		local queueIconAnimation = queueIcon:CreateAnimationGroup()
		queueIconAnimation:SetLooping("REPEAT")
		queueIconAnimation.rotation = queueIconAnimation:CreateAnimation("Rotation")
		queueIconAnimation.rotation:SetDuration(6)
		queueIconAnimation.rotation:SetDegrees(360)

		hooksecurefunc("BattlefieldFrame_UpdateStatus", function()
			queueIcon:SetShown(MiniMapBattlefieldFrame:IsShown())

			queueIconAnimation:Play()
			for i = 1, MAX_BATTLEFIELD_QUEUES do
				local status = GetBattlefieldStatus(i)
				if status == "confirm" then
					queueIconAnimation:Stop()
					break
				end
			end
		end)
	end

	-- Tracking icon
	if MiniMapTracking then
		MiniMapTracking:SetScale(0.9)
		MiniMapTracking:ClearAllPoints()
		MiniMapTracking:SetPoint("BOTTOMRIGHT", Minimap, -4, 4)
		MiniMapTracking:SetFrameLevel(Minimap:GetFrameLevel() + 4)
		MiniMapTrackingIcon:SetTexCoord(unpack(K.TexCoords))
		MiniMapTrackingButtonBorder:Hide()
		MiniMapTrackingBackground:Hide()
	end

	-- Mail icon
	if MiniMapMailFrame then
		MiniMapMailFrame:ClearAllPoints()
		if C["DataText"].Time then
			MiniMapMailFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 12)
		else
			MiniMapMailFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, -2)
		end
		MiniMapMailIcon:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\DataText\\mail.blp")
		MiniMapMailIcon:SetSize(28, 28)
		MiniMapMailFrame:SetHitRectInsets(11, 2, 13, 7)
		MiniMapMailIcon:SetVertexColor(unpack(C["DataText"].IconColor))
		MiniMapMailIcon:SetAlpha(0.9)
	end
end

function Module:CreatePing()
	local pingFrame = CreateFrame("Frame", nil, Minimap)
	pingFrame:SetAllPoints()
	pingFrame.text = K.CreateFontString(pingFrame, 12, "", "OUTLINE", false, "TOP", 0, -4)

	local pingAnimation = pingFrame:CreateAnimationGroup()

	pingAnimation:SetScript("OnPlay", function()
		pingFrame:SetAlpha(1)
	end)

	pingAnimation:SetScript("OnFinished", function()
		pingFrame:SetAlpha(0)
	end)

	pingAnimation.fader = pingAnimation:CreateAnimation("Alpha")
	pingAnimation.fader:SetFromAlpha(1)
	pingAnimation.fader:SetToAlpha(0)
	pingAnimation.fader:SetDuration(3)
	pingAnimation.fader:SetSmoothing("OUT")
	pingAnimation.fader:SetStartDelay(3)

	K:RegisterEvent("MINIMAP_PING", function(_, unit)
		if unit == "player" then -- Do show ourself. -.-
			return
		end

		local class = select(2, UnitClass(unit))
		local r, g, b = K.ColorClass(class)
		local name = GetUnitName(unit)

		pingAnimation:Stop()
		pingFrame.text:SetText(name)
		pingFrame.text:SetTextColor(r, g, b)
		pingAnimation:Play()
	end)
end

function Module:UpdateMinimapScale()
	local size = C["Minimap"].Size
	Minimap:SetSize(size, size)
	Minimap.mover:SetSize(size, size)
end

function Module:HideMinimapClock()
	if TimeManagerClockButton then
		TimeManagerClockButton:SetParent(K.UIFrameHider)
		TimeManagerClockButton:UnregisterAllEvents()
	end
end

function Module:Minimap_OnMouseWheel(zoom)
	if zoom > 0 then
		Minimap_ZoomIn()
	else
		Minimap_ZoomOut()
	end
end

function Module:Minimap_OnMouseUp(btn)
	_G.HideDropDownMenu(1, nil, KKUI_MiniMapTrackingDropDown)
	menuFrame:Hide()

	local position = Minimap.mover:GetPoint()
	if btn == "MiddleButton" or (btn == "RightButton" and IsShiftKeyDown()) then
		if InCombatLockdown() then
			_G.UIErrorsFrame:AddMessage(K.InfoColor .. _G.ERR_NOT_IN_COMBAT)
			return
		end

		if position:match("LEFT") then
			EasyMenu(micromenu, menuFrame, "cursor", 0, 0, "MENU")
		else
			EasyMenu(micromenu, menuFrame, "cursor", -160, 0, "MENU")
		end
	elseif btn == "RightButton" then
		if position:match("LEFT") then
			ToggleDropDownMenu(1, nil, KKUI_MiniMapTrackingDropDown, "cursor", 0, 0, "MENU", 2)
		else
			ToggleDropDownMenu(1, nil, KKUI_MiniMapTrackingDropDown, "cursor", -160, 0, "MENU", 2)
		end
	else
		_G.Minimap_OnClick(self)
	end
end

function Module:UpdateBlipTexture()
	Minimap:SetBlipTexture(C["Minimap"].BlipTexture.Value)
end

local function UpdateDifficultyFlag()
	local frame = _G["KKUI_MinimapDifficulty"]
	local _, instanceType, difficulty, _, _, _, _, _, instanceGroupSize = GetInstanceInfo()
	local _, _, isHeroic, _, displayHeroic = GetDifficultyInfo(difficulty)
	if instanceType == "raid" or isHeroic or displayHeroic then
		if isHeroic or displayHeroic then
			frame.tex:SetTexCoord(0, 0.25, 0.0703125, 0.4296875)
		else
			frame.tex:SetTexCoord(0, 0.25, 0.5703125, 0.9296875)
		end
		frame.text:SetText(instanceGroupSize)
		frame:Show()
	else
		frame:Hide()
	end
end

function Module:MinimapDifficulty()
	if _G.MiniMapInstanceDifficulty then -- hide flag if blizz makes its own
		return
	end

	local frame = CreateFrame("Frame", "KKUI_MinimapDifficulty", Minimap)
	frame:SetSize(38, 46)
	frame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
	frame:SetScale(0.9)

	local tex = frame:CreateTexture(nil, "ARTWORK")
	tex:SetTexture("Interface\\Minimap\\UI-DungeonDifficulty-Button")
	tex:SetPoint("CENTER")
	tex:SetSize(64, 46)
	tex:SetTexCoord(0, 0.25, 0.0703125, 0.4140625)
	frame.tex = tex

	frame.text = K.CreateFontString(frame, 12, "", "", false, "CENTER", 1, -8)

	K:RegisterEvent("GROUP_ROSTER_UPDATE", UpdateDifficultyFlag)
	K:RegisterEvent("UPDATE_INSTANCE_INFO", UpdateDifficultyFlag)
	K:RegisterEvent("INSTANCE_GROUP_SIZE_CHANGED", UpdateDifficultyFlag)
end

function Module:OnEnable()
	if not C["Minimap"].Enable then
		return
	end

	-- Shape and Position
	Minimap:SetFrameLevel(10)
	Minimap:SetMaskTexture(C["Media"].Textures.BlankTexture)
	DropDownList1:SetClampedToScreen(true)

	local minimapMover = K.Mover(Minimap, "Minimap", "Minimap", { "TOPRIGHT", UIParent, "TOPRIGHT", -4, -4 })
	Minimap:ClearAllPoints()
	Minimap:SetPoint("TOPRIGHT", minimapMover)
	Minimap.mover = minimapMover

	self:HideMinimapClock()
	self:UpdateBlipTexture()
	self:UpdateMinimapScale()

	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", Module.Minimap_OnMouseWheel)
	Minimap:SetScript("OnMouseUp", Module.Minimap_OnMouseUp)

	-- Hide Blizz
	local frames = {
		"MinimapBorderTop",
		"MinimapNorthTag",
		"MinimapBorder",
		"MinimapZoneTextButton",
		"MinimapZoomOut",
		"MinimapZoomIn",
		"MiniMapWorldMapButton",
		"MiniMapMailBorder",
		"MinimapToggleButton",
		"GameTimeFrame",
	}

	for _, v in pairs(frames) do
		K.HideInterfaceOption(_G[v])
	end

	MinimapCluster:EnableMouse(false)

	-- Add Elements
	self:CreatePing()
	self:CreateStyle()
	self:CreateRecycleBin()
	self:ReskinRegions()
	self:MinimapDifficulty()

	if LibDBIcon10_TownsfolkTracker then
		LibDBIcon10_TownsfolkTracker:DisableDrawLayer("OVERLAY")
		LibDBIcon10_TownsfolkTracker:DisableDrawLayer("BACKGROUND")
	end
end
