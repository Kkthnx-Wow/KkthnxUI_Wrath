local K, C = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")

local _G = _G
local assert = _G.assert

local CharacterMicroButton = _G.CharacterMicroButton
local CreateFrame = _G.CreateFrame
local MICRO_BUTTONS = _G.MICRO_BUTTONS
local MainMenuBarPerformanceBar = _G.MainMenuBarPerformanceBar
local MicroButtonPortrait = _G.MicroButtonPortrait
local UIParent = _G.UIParent
local hooksecurefunc = _G.hooksecurefunc

local microBar

local function onLeaveBar()
	if C["ActionBar"].FadeMicroBar then
		UIFrameFadeOut(microBar, 0.5, microBar:GetAlpha(), 0)
	end
end

local watcher = 0
local function onUpdate(self, elapsed)
	if watcher > 0.1 then
		if not self:IsMouseOver() then
			self.IsMouseOvered = nil
			self:SetScript("OnUpdate", nil)
			onLeaveBar()
		end
		watcher = 0
	else
		watcher = watcher + elapsed
	end
end

local function onEnter(button)
	if button.backdrop and button:IsEnabled() then
		if C["General"].ColorTextures then
			button.backdrop.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
		else
			button.backdrop.KKUI_Border:SetVertexColor(1, 1, 0)
		end
	end

	if C["ActionBar"].FadeMicroBar and not microBar.IsMouseOvered then
		microBar.IsMouseOvered = true
		microBar:SetScript("OnUpdate", onUpdate)
		UIFrameFadeIn(microBar, 0.2, microBar:GetAlpha(), 1)
	end
end

local function onLeave(button)
	if button.backdrop and button:IsEnabled() then
		if C["General"].ColorTextures then
			button.backdrop.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
		else
			button.backdrop.KKUI_Border:SetVertexColor(1, 1, 1)
		end
	end
end

local function HandleMicroButtons(button)
	assert(button, "Invalid micro button name.")

	local pushed = button:GetPushedTexture()
	local normal = button:GetNormalTexture()
	local disabled = button:GetDisabledTexture()

	local f = CreateFrame("Frame", nil, button)
	f:SetFrameLevel(button:GetFrameLevel())
	f:CreateBorder()
	f:SetAllPoints(button)
	button.backdrop = f

	button:SetParent(microBar)
	button:GetHighlightTexture():Kill()
	button:HookScript("OnEnter", onEnter)
	button:HookScript("OnLeave", onLeave)
	button:SetHitRectInsets(0, 0, 0, 0)

	if button.Flash then
		button.Flash:SetAllPoints(button)
		button.Flash:SetTexture()
	end

	pushed:SetTexCoord(0.17, 0.87, 0.5, 0.908)
	pushed:SetAllPoints(button)

	normal:SetTexCoord(0.17, 0.87, 0.5, 0.908)
	normal:SetAllPoints(button)

	if disabled then
		disabled:SetTexCoord(0.17, 0.87, 0.5, 0.908)
		disabled:SetAllPoints(button)
	end
end

local function UpdateMicroButtonsParent()
	for _, x in pairs(MICRO_BUTTONS) do
		_G[x]:SetParent(microBar)
	end
end

local function UpdateMicroPositionDimensions()
	if not microBar then
		return
	end

	local prevButton = microBar
	local offset = 4
	local spacing = offset + 2

	for i = 1, #_G.MICRO_BUTTONS do
		local button = _G[_G.MICRO_BUTTONS[i]]
		button:SetSize(20, 20 * 1.4)
		button:ClearAllPoints()

		if prevButton == microBar then
			button:SetPoint("TOPLEFT", prevButton, "TOPLEFT", offset, -offset)
		else
			button:SetPoint("LEFT", prevButton, "RIGHT", spacing, 0)
		end

		prevButton = button
	end

	if C["ActionBar"].FadeMicroBar and not microBar:IsMouseOver() then
		microBar:SetAlpha(0)
	else
		microBar:SetAlpha(1)
	end
end

local function UpdateMicroButtons()
	UpdateMicroPositionDimensions()
end

function Module:CreateMicroMenu()
	if not C["ActionBar"].MicroBar then
		return
	end

	microBar = microBar or CreateFrame("Frame", "KKUI_MicroBar", UIParent)
	microBar:SetSize(210, 20 * 1.8)
	microBar:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
	microBar:EnableMouse(false)

	for _, x in pairs(MICRO_BUTTONS) do
		HandleMicroButtons(_G[x])
	end

	MicroButtonPortrait:SetAllPoints(CharacterMicroButton.backdrop)

	hooksecurefunc("UpdateMicroButtonsParent", UpdateMicroButtonsParent)
	hooksecurefunc("MoveMicroButtons", UpdateMicroPositionDimensions)
	hooksecurefunc("UpdateMicroButtons", UpdateMicroButtons)

	UpdateMicroButtonsParent()
	UpdateMicroPositionDimensions()

	-- Default elements
	_G.MainMenuBar.slideOut:GetAnimations():SetOffset(0,0)
	MainMenuBarPerformanceBar:SetAlpha(0)
	MainMenuBarPerformanceBar:SetScale(.00001)

	K.Mover(microBar, "MicroBar", "MicroBar", {"BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0})
end