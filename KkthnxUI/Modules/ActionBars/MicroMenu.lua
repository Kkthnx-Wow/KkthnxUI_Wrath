local K, C = unpack(KkthnxUI)
local Module = K:GetModule("ActionBar")

-- TODO: Add mouseover back

local _G = _G
local table_insert = _G.table.insert
local pairs = _G.pairs
local type = _G.type

local MAINMENU_BUTTON = _G.MAINMENU_BUTTON
local MicroButtonTooltipText = _G.MicroButtonTooltipText
local RegisterStateDriver = _G.RegisterStateDriver

local buttonList = {}

local function onLeaveBar()
	local KKUI_MB = _G.KKUI_MenuBar
	return C["ActionBar"].FadeMicroBar and UIFrameFadeOut(KKUI_MB, 0.2, KKUI_MB:GetAlpha(), 0)
end

local watcher = 0
local function onUpdate(_, elapsed)
	local KKUI_MB = _G.KKUI_MenuBar
	if watcher > 0.1 then
		if not KKUI_MB:IsMouseOver() then
			KKUI_MB.IsMouseOvered = nil
			KKUI_MB:SetScript("OnUpdate", nil)
			onLeaveBar()
		end
		watcher = 0
	else
		watcher = watcher + elapsed
	end
end

local function onEnter()
	local KKUI_MB = _G.KKUI_MenuBar
	if not KKUI_MB.IsMouseOvered then
		KKUI_MB.IsMouseOvered = true
		KKUI_MB:SetScript("OnUpdate", onUpdate)
		UIFrameFadeIn(KKUI_MB, 0.2, KKUI_MB:GetAlpha(), 1)
	end
end

function Module:MicroButton_SetupTexture(icon, texture)
	icon:SetPoint("TOPLEFT", -9, 5)
	icon:SetPoint("BOTTOMRIGHT", 10, -6)
	icon:SetTexture(K.MediaFolder .. "Skins\\" .. texture)
end

local function ResetButtonParent(button, parent)
	if parent ~= button.__owner then
		button:SetParent(button.__owner)
	end
end

local function ResetButtonAnchor(button)
	button:ClearAllPoints()
	button:SetAllPoints()
end

function Module:MicroButton_Create(parent, data)
	local texture, method, tooltip = unpack(data)

	local bu = CreateFrame("Frame", "KKUI_MicroButtons", parent)
	table_insert(buttonList, bu)
	bu:SetSize(20, 20 * 1.4)
	bu:CreateBorder()

	local icon = bu:CreateTexture(nil, "ARTWORK")
	Module:MicroButton_SetupTexture(icon, texture)

	if type(method) == "string" then
		local button = _G[method]
		button:SetHitRectInsets(0, 0, 0, 0)
		button:SetParent(bu)
		button.__owner = bu
		hooksecurefunc(button, "SetParent", ResetButtonParent)
		ResetButtonAnchor(button)
		hooksecurefunc(button, "SetPoint", ResetButtonAnchor)
		button:UnregisterAllEvents()
		button:SetNormalTexture(nil)

		if tooltip then
			K.AddTooltip(button, "ANCHOR_RIGHT", tooltip)
		end

		if C["ActionBar"].FadeMicroBar then
			button:HookScript("OnEnter", onEnter)
		end

		local pushed = button:GetPushedTexture()
		local disabled = button:GetDisabledTexture()
		local highlight = button:GetHighlightTexture()
		local flash = button.Flash

		if pushed then
			pushed:SetColorTexture(1, 0.84, 0, 0.2)
			pushed:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
			pushed:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
		end

		if disabled then
			disabled:SetColorTexture(1, 0, 0, 0.4)
			disabled:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
			disabled:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
		end

		highlight:SetTexture(K.MediaFolder .. "Skins\\HighlightMicroButtonWhite")
		highlight:SetVertexColor(K.r, K.g, K.b)
		highlight:SetPoint("TOPLEFT", button, "TOPLEFT", -22, 18)
		highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 24, -18)

		if flash then
			flash:SetTexture(K.MediaFolder .. "Skins\\HighlightMicroButtonYellow")
			flash:SetPoint("TOPLEFT", button, "TOPLEFT", -22, 18)
			flash:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 24, -18)
		end
	else
		bu:SetScript("OnMouseUp", method)
		K.AddTooltip(bu, "ANCHOR_RIGHT", tooltip)

		local highlight = bu:CreateTexture(nil, "HIGHLIGHT")
		highlight:SetTexture(K.MediaFolder .. "Skins\\HighlightMicroButtonWhite")
		highlight:SetVertexColor(K.r, K.g, K.b)
		highlight:SetPoint("TOPLEFT", bu, "TOPLEFT", -22, 18)
		highlight:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", 24, -18)
	end
end

function Module:CreateMicroMenu()
	if not C["ActionBar"].MicroBar then
		return
	end

	local menubar = CreateFrame("Frame", "KKUI_MenuBar", UIParent)
	menubar:SetSize(280, 20 * 1.4)
	menubar:SetAlpha((C["ActionBar"].FadeMicroBar and not menubar.IsMouseOvered and 0) or 1)
	menubar:EnableMouse(false)
	K.Mover(menubar, "Menubar", "Menubar", { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -4, 4 })

	-- Generate Buttons
	local buttonInfo = {
		{ "CharacterMicroButton", "CharacterMicroButton", MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0") },
		{ "SpellbookMicroButton", "SpellbookMicroButton", MicroButtonTooltipText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK") },
		{ "TalentMicroButton", "TalentMicroButton", MicroButtonTooltipText(TALENTS, "TOGGLETALENTS") },
		{ "AchievementMicroButton", "AchievementMicroButton", MicroButtonTooltipText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT") },
		{ "QuestLogMicroButton", "QuestLogMicroButton", MicroButtonTooltipText(QUESTLOG_BUTTON, "TOGGLEQUESTLOG") },
		{ "GuildMicroButton", "SocialsMicroButton", MicroButtonTooltipText(SOCIAL_BUTTON, "TOGGLESOCIAL") },
		{ "LFDMicroButton", "PVPMicroButton", MicroButtonTooltipText(PLAYER_V_PLAYER, "TOGGLECHARACTER4") },
		{ "LFDMicroButton", "LFGMicroButton", MicroButtonTooltipText(LFG_BUTTON, "TOGGLELFG") },
		{
			"StoreMicroButton",
			function()
				ToggleStoreUI()
			end,
			BLIZZARD_STORE,
		},
		{ "MainMenuMicroButton", "HelpMicroButton", MicroButtonTooltipText(HELP_BUTTON, "TOGGLEHELP") },
		{ "MainMenuMicroButton", "MainMenuMicroButton", MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU") },
	}

	for _, info in pairs(buttonInfo) do
		Module:MicroButton_Create(menubar, info)
	end

	-- Order Positions
	for i = 1, #buttonList do
		if i == 1 then
			buttonList[i]:SetPoint("LEFT")
		else
			buttonList[i]:SetPoint("LEFT", buttonList[i - 1], "RIGHT", 6, 0)
		end
	end

	-- Default elements
	K.HideInterfaceOption(PVPMicroButtonTexture)
	K.HideInterfaceOption(MicroButtonPortrait)
	K.HideInterfaceOption(MainMenuBarDownload)
	K.HideInterfaceOption(HelpOpenWebTicketButton)
	K.HideInterfaceOption(MainMenuBarPerformanceBar)
	MainMenuMicroButton:SetScript("OnUpdate", nil)
end
