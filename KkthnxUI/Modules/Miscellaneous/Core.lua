local K, C, L = unpack(KkthnxUI)
local Module = K:NewModule("Miscellaneous")

local _G = _G
local select = _G.select
local string_match = _G.string.match
local tonumber = _G.tonumber

local BNToastFrame = _G.BNToastFrame
local C_BattleNet_GetGameAccountInfoByGUID = _G.C_BattleNet.GetGameAccountInfoByGUID
local C_FriendList_IsFriend = _G.C_FriendList.IsFriend
local C_Timer_After = _G.C_Timer.After
local CreateFrame = _G.CreateFrame
local FRIEND = _G.FRIEND
local GUILD = _G.GUILD
local GetItemInfo = _G.GetItemInfo
local GetItemQualityColor = _G.GetItemQualityColor
local GetMerchantItemLink = _G.GetMerchantItemLink
local GetMerchantItemMaxStack = _G.GetMerchantItemMaxStack
local GetSpellInfo = _G.GetSpellInfo
local InCombatLockdown = _G.InCombatLockdown
local IsAltKeyDown = _G.IsAltKeyDown
local IsGuildMember = _G.IsGuildMember
local NO = _G.NO
local PlaySound = _G.PlaySound
local StaticPopupDialogs = _G.StaticPopupDialogs
local StaticPopup_Show = _G.StaticPopup_Show
local UIParent = _G.UIParent
local UnitGUID = _G.UnitGUID
local YES = _G.YES
local hooksecurefunc = _G.hooksecurefunc

local KKUI_MISC_LIST = {}

function Module:RegisterMisc(name, func)
	if not KKUI_MISC_LIST[name] then
		KKUI_MISC_LIST[name] = func
	end
end

function Module:OnEnable()
	for name, func in next, KKUI_MISC_LIST do
		if name and type(func) == "function" then
			func()
		end
	end

	Module:CreateBlockStrangerInvites()
	Module:CreateBossEmote()
	Module:CreateDurabilityFrameMove()
	Module:CreateErrorFrameToggle()
	Module:CreateGUIGameMenuButton()
	Module:CreateMinimapButtonToggle()
	Module:CreateObjectiveSizeUpdate()
	Module:CreatePetHappiness()
	Module:CreateQuestSizeUpdate()
	Module:CreateTaxiDismount()
	Module:CreateTicketStatusFrameMove()
	Module:CreateTradeTargetInfo()
	Module:UpdateMaxCameraZoom()
	C_Timer_After(0, Module.UpdateMaxCameraZoom)

	-- TESTING CMD : /run BNToastFrame:AddToast(BN_TOAST_TYPE_ONLINE, 1)
	if not BNToastFrame.mover then -- text, value, anchor, width, height, isAuraWatch, postDrag
		BNToastFrame.mover = K.Mover(BNToastFrame, "BNToastFrame", "BNToastFrame", { "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 4, 171 }, BNToastFrame:GetWidth(), BNToastFrame:GetHeight())
	else
		BNToastFrame.mover:SetSize(BNToastFrame:GetWidth(), BNToastFrame:GetHeight()) -- 49 -- Rounded default size?
	end
	hooksecurefunc(BNToastFrame, "SetPoint", Module.PostBNToastMove)

	-- Unregister talent event
	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
		hooksecurefunc("TalentFrame_LoadUI", function()
			PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		end)
	end

	-- Auto chatBubbles
	if C["Misc"].AutoBubbles then
		local function updateBubble()
			local name, instType = GetInstanceInfo()
			if name and instType == "raid" then
				SetCVar("chatBubbles", 1)
			else
				SetCVar("chatBubbles", 0)
			end
		end
		K:RegisterEvent("PLAYER_ENTERING_WORLD", updateBubble)
	end

	-- Instant delete
	local deleteDialog = StaticPopupDialogs["DELETE_GOOD_ITEM"]
	if deleteDialog.OnShow then
		hooksecurefunc(deleteDialog, "OnShow", function(self)
			self.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
		end)
	end

	-- Fix blizz bug in addon list
	local _AddonTooltip_Update = AddonTooltip_Update
	function AddonTooltip_Update(owner)
		if not owner then
			return
		end

		if owner:GetID() < 1 then
			return
		end
		_AddonTooltip_Update(owner)
	end
end

-- Hunter pet happiness
local lastHappiness
local petHappinessStr = {
	[1] = "%sYour pet [%s] is about to run away.",
	[2] = "%sYour pet [%s] is not in a good mood.",
	[3] = "%sYour pet [%s] feels happy now.",
}

local function CheckPetHappiness(_, unit)
	if unit ~= "pet" then
		return
	end

	local happiness = GetPetHappiness()
	if not lastHappiness or lastHappiness ~= happiness then
		local str = petHappinessStr[happiness]
		if str then
			local petName = UnitName(unit)
			UIErrorsFrame:AddMessage(string.format(str, K.InfoColor, petName))
			K.Print(string.format(str, K.InfoColor, petName))
		end

		lastHappiness = happiness
	end
end

function Module:CreatePetHappiness()
	if K.Class ~= "HUNTER" then
		return
	end

	if C["Misc"].PetHappiness then
		K:RegisterEvent("UNIT_HAPPINESS", CheckPetHappiness)
	else
		K:UnregisterEvent("UNIT_HAPPINESS", CheckPetHappiness)
	end
end

-- Auto dismount on Taxi
function Module:CreateTaxiDismount()
	local lastTaxiIndex
	local function retryTaxi()
		if InCombatLockdown() then
			return
		end

		if lastTaxiIndex then
			TakeTaxiNode(lastTaxiIndex)
			lastTaxiIndex = nil
		end
	end

	hooksecurefunc("TakeTaxiNode", function(index)
		if not C["Misc"].AutoDismount then
			return
		end

		if not IsMounted() then
			return
		end

		Dismount()
		lastTaxiIndex = index
		C_Timer_After(0.5, retryTaxi)
	end)
end

local function KKUI_UpdateDragCursor(self)
	local mx, my = Minimap:GetCenter()
	local px, py = GetCursorPosition()
	local scale = Minimap:GetEffectiveScale()
	px, py = px / scale, py / scale

	local angle = atan2(py - my, px - mx)
	local x, y, q = cos(angle), sin(angle), 1
	if x < 0 then
		q = q + 1
	end
	if y > 0 then
		q = q + 2
	end

	local w = (Minimap:GetWidth() / 2) + 5
	local h = (Minimap:GetHeight() / 2) + 5
	local diagRadiusW = sqrt(2 * w ^ 2) - 10
	local diagRadiusH = sqrt(2 * h ^ 2) - 10
	x = max(-w, min(x * diagRadiusW, w))
	y = max(-h, min(y * diagRadiusH, h))

	self:ClearAllPoints()
	self:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function KKUI_ClickMinimapButton(_, btn)
	if btn == "LeftButton" then
		-- Prevent options panel from showing if Blizzard options panel is showing
		if InterfaceOptionsFrame:IsShown() or VideoOptionsFrame:IsShown() or ChatConfigFrame:IsShown() then
			return
		end

		-- No modifier key toggles the options panel
		if InCombatLockdown() then
			UIErrorsFrame:AddMessage(K.InfoColor .. ERR_NOT_IN_COMBAT)
			return
		end

		K["GUI"]:Toggle()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
	elseif btn == "RightButton" then
		--K.Print("Help info needs to be wrote")
	end
end

function Module:CreateMinimapButtonToggle()
	local mmb = CreateFrame("Button", "KKUI_MinimapButton", Minimap)
	mmb:SetPoint("BOTTOMLEFT", -15, 20)
	mmb:SetSize(32, 32)
	mmb:SetMovable(true)
	mmb:SetUserPlaced(true)
	mmb:RegisterForDrag("LeftButton")
	mmb:SetHighlightTexture(C["Media"].Textures.LogoSmallTexture)
	mmb:GetHighlightTexture():SetSize(18, 9)
	mmb:GetHighlightTexture():ClearAllPoints()
	mmb:GetHighlightTexture():SetPoint("CENTER")

	local overlay = mmb:CreateTexture(nil, "OVERLAY")
	overlay:SetSize(53, 53)
	overlay:SetTexture(136430) -- "Interface\\Minimap\\MiniMap-TrackingBorder"
	overlay:SetPoint("TOPLEFT")

	local background = mmb:CreateTexture(nil, "BACKGROUND")
	background:SetSize(20, 20)
	background:SetTexture(136467) -- "Interface\\Minimap\\UI-Minimap-Background"
	background:SetPoint("TOPLEFT", 7, -5)

	local icon = mmb:CreateTexture(nil, "ARTWORK")
	icon:SetSize(22, 11)
	icon:SetPoint("CENTER")
	icon:SetTexture(C["Media"].Textures.LogoSmallTexture)

	mmb:SetScript("OnEnter", function()
		GameTooltip:ClearLines()
		GameTooltip:Hide()
		GameTooltip:SetOwner(mmb, "ANCHOR_LEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine("KkthnxUI", 1, 1, 1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("LeftButton: Toggle Config", 0.6, 0.8, 1)
		-- GameTooltip:AddLine("RightButton: Toggle MoveUI", 0.6, 0.8, 1)
		GameTooltip:Show()
	end)
	mmb:SetScript("OnLeave", GameTooltip_Hide)
	mmb:RegisterForClicks("AnyUp")
	mmb:SetScript("OnClick", KKUI_ClickMinimapButton)
	mmb:SetScript("OnDragStart", function(self)
		self:SetScript("OnUpdate", KKUI_UpdateDragCursor)
	end)
	mmb:SetScript("OnDragStop", function(self)
		self:SetScript("OnUpdate", nil)
	end)

	-- Function to toggle LibDBIcon
	function Module:ToggleMinimapIcon()
		if C["General"].MinimapIcon then
			mmb:Show()
		else
			mmb:Hide()
		end
	end

	Module:ToggleMinimapIcon()
end

local function MainMenu_OnShow(self)
	_G.GameMenuButtonLogout:SetPoint("TOP", Module.GameMenuButton, "BOTTOM", 0, -14)
	self:SetHeight(self:GetHeight() + Module.GameMenuButton:GetHeight() + 15 + 24)

	_G.GameMenuButtonStore:ClearAllPoints()
	_G.GameMenuButtonStore:SetPoint("TOP", _G.GameMenuButtonHelp, "BOTTOM", 0, -6)

	_G.GameMenuButtonUIOptions:ClearAllPoints()
	_G.GameMenuButtonUIOptions:SetPoint("TOP", _G.GameMenuButtonOptions, "BOTTOM", 0, -6)

	_G.GameMenuButtonKeybindings:ClearAllPoints()
	_G.GameMenuButtonKeybindings:SetPoint("TOP", _G.GameMenuButtonUIOptions, "BOTTOM", 0, -6)

	_G.GameMenuButtonMacros:ClearAllPoints()
	_G.GameMenuButtonMacros:SetPoint("TOP", _G.GameMenuButtonKeybindings, "BOTTOM", 0, -6)

	_G.GameMenuButtonAddons:ClearAllPoints()
	_G.GameMenuButtonAddons:SetPoint("TOP", _G.GameMenuButtonMacros, "BOTTOM", 0, -6)

	_G.GameMenuButtonQuit:ClearAllPoints()
	_G.GameMenuButtonQuit:SetPoint("TOP", _G.GameMenuButtonLogout, "BOTTOM", 0, -6)
end

local function Button_OnClick()
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(K.InfoColor .. ERR_NOT_IN_COMBAT)
		return
	end

	K["GUI"]:Toggle()
	HideUIPanel(_G.GameMenuFrame)
	PlaySound(_G.SOUNDKIT.IG_MAINMENU_OPTION)
end

function Module:CreateGUIGameMenuButton()
	local bu = CreateFrame("Button", "KKUI_GameMenuButton", _G.GameMenuFrame, "GameMenuButtonTemplate")
	bu:SetText(K.Title)
	bu:SetPoint("TOP", _G.GameMenuButtonAddons, "BOTTOM", 0, -14)
	bu:SetScript("OnClick", Button_OnClick)
	bu:SkinButton()

	Module.GameMenuButton = bu

	_G.GameMenuFrame:HookScript("OnShow", MainMenu_OnShow)
end

-- Reanchor DurabilityFrame
function Module:CreateDurabilityFrameMove()
	hooksecurefunc(DurabilityFrame, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == MinimapCluster then
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", -40, -50)
		end
	end)
end

-- Reanchor TicketStatusFrame
function Module:CreateTicketStatusFrameMove()
	hooksecurefunc(TicketStatusFrame, "SetPoint", function(self, relF)
		if relF == "TOPRIGHT" then
			self:ClearAllPoints()
			self:SetPoint("TOP", UIParent, "TOP", -400, -20)
		end
	end)
end

-- Hide boss emote
function Module:CreateBossEmote()
	if C["Misc"].HideBossEmote then
		RaidBossEmoteFrame:UnregisterAllEvents()
	else
		RaidBossEmoteFrame:RegisterEvent("RAID_BOSS_EMOTE")
		RaidBossEmoteFrame:RegisterEvent("RAID_BOSS_WHISPER")
		RaidBossEmoteFrame:RegisterEvent("CLEAR_BOSS_EMOTES")
	end
end

local function SetupErrorFrameToggle(event)
	if event == "PLAYER_REGEN_DISABLED" then
		_G.UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
		K:RegisterEvent("PLAYER_REGEN_ENABLED", SetupErrorFrameToggle)
	else
		_G.UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
		K:UnregisterEvent(event, SetupErrorFrameToggle)
	end
end

function Module:CreateErrorFrameToggle()
	if C["General"].NoErrorFrame then
		K:RegisterEvent("PLAYER_REGEN_DISABLED", SetupErrorFrameToggle)
	else
		K:UnregisterEvent("PLAYER_REGEN_DISABLED", SetupErrorFrameToggle)
	end
end

function Module:CreateQuestSizeUpdate()
	QuestTitleFont:SetFont(QuestTitleFont:GetFont(), C["Skins"].QuestFontSize + 3, nil)
	QuestFont:SetFont(QuestFont:GetFont(), C["Skins"].QuestFontSize + 1, nil)
	QuestFontNormalSmall:SetFont(QuestFontNormalSmall:GetFont(), C["Skins"].QuestFontSize, nil)
end

function Module:CreateObjectiveSizeUpdate()
	ObjectiveFont:SetFontObject(K.UIFont)
	ObjectiveFont:SetFont(ObjectiveFont:GetFont(), C["Skins"].ObjectiveFontSize, select(3, ObjectiveFont:GetFont()))
end

-- TradeFrame hook
function Module:CreateTradeTargetInfo()
	local infoText = K.CreateFontString(TradeFrame, 16, "", "")
	infoText:ClearAllPoints()
	infoText:SetPoint("TOP", TradeFrameRecipientNameText, "BOTTOM", 0, -8)

	local function updateColor()
		local r, g, b = K.UnitColor("NPC")
		TradeFrameRecipientNameText:SetTextColor(r, g, b)

		local guid = UnitGUID("NPC")
		if not guid then
			return
		end

		local text = "|cffff0000" .. L["Stranger"]
		if C_BattleNet_GetGameAccountInfoByGUID(guid) or C_FriendList_IsFriend(guid) then
			text = "|cffffff00" .. FRIEND
		elseif IsGuildMember(guid) then
			text = "|cff00ff00" .. GUILD
		end
		infoText:SetText(text)
	end
	hooksecurefunc("TradeFrame_Update", updateColor)
end

-- ALT+RightClick to buy a stack
do
	local cache = {}
	local itemLink, id

	StaticPopupDialogs["BUY_STACK"] = {
		text = L["Stack Buying Check"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			if not itemLink then
				return
			end
			BuyMerchantItem(id, GetMerchantItemMaxStack(id))
			cache[itemLink] = true
			itemLink = nil
		end,
		hideOnEscape = 1,
		hasItemFrame = 1,
	}

	local _MerchantItemButton_OnModifiedClick = MerchantItemButton_OnModifiedClick
	function MerchantItemButton_OnModifiedClick(self, ...)
		if IsAltKeyDown() then
			id = self:GetID()
			itemLink = GetMerchantItemLink(id)
			if not itemLink then
				return
			end

			local name, _, quality, _, _, _, _, maxStack, _, texture = GetItemInfo(itemLink)
			if maxStack and maxStack > 1 then
				if not cache[itemLink] then
					local r, g, b = GetItemQualityColor(quality or 1)
					StaticPopup_Show("BUY_STACK", " ", " ", {
						["texture"] = texture,
						["name"] = name,
						["color"] = { r, g, b, 1 },
						["link"] = itemLink,
						["index"] = id,
						["count"] = maxStack,
					})
				else
					BuyMerchantItem(id, GetMerchantItemMaxStack(id))
				end
			end
		end

		_MerchantItemButton_OnModifiedClick(self, ...)
	end
end

-- Select target when click on raid units
do
	local function fixRaidGroupButton()
		for i = 1, 40 do
			local bu = _G["RaidGroupButton" .. i]
			if bu and bu.unit and not bu.clickFixed then
				bu:SetAttribute("type", "target")
				bu:SetAttribute("unit", bu.unit)

				bu.clickFixed = true
			end
		end
	end

	local function setupMisc(event, addon)
		if event == "ADDON_LOADED" and addon == "Blizzard_RaidUI" then
			if not InCombatLockdown() then
				fixRaidGroupButton()
			else
				K:RegisterEvent("PLAYER_REGEN_ENABLED", setupMisc)
			end
			K:UnregisterEvent(event, setupMisc)
		elseif event == "PLAYER_REGEN_ENABLED" then
			if RaidGroupButton1 and RaidGroupButton1:GetAttribute("type") ~= "target" then
				fixRaidGroupButton()
				K:UnregisterEvent(event, setupMisc)
			end
		end
	end

	K:RegisterEvent("ADDON_LOADED", setupMisc)
end

-- make it only split stacks with shift-rightclick if the TradeSkillFrame is open
-- shift-leftclick should be reserved for the search box
do
	local function hideSplitFrame(_, button)
		if TradeSkillFrame and TradeSkillFrame:IsShown() then
			if button == "LeftButton" then
				StackSplitFrame:Hide()
			end
		end
	end
	hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", hideSplitFrame)
	hooksecurefunc("MerchantItemButton_OnModifiedClick", hideSplitFrame)
end

do
	local function soundOnResurrect()
		if C["Unitframe"].ResurrectSound then
			PlaySound("72978", "Master")
		end
	end
	K:RegisterEvent("RESURRECT_REQUEST", soundOnResurrect)
end

function Module:CreateBlockStrangerInvites()
	K:RegisterEvent("PARTY_INVITE_REQUEST", function(a, b, c, d, e, f, g, guid)
		if C["Automation"].AutoBlockStrangerInvites and not (C_BattleNet_GetGameAccountInfoByGUID(guid) or C_FriendList_IsFriend(guid) or IsGuildMember(guid)) then
			_G.DeclineGroup()
			_G.StaticPopup_Hide("PARTY_INVITE")
			K.Print("Blocked invite request from a stranger!", a, b, c, d, e, f, g, guid)
		end
	end)
end

-- Make it so we can move this
function Module:PostBNToastMove(_, anchor)
	if anchor ~= BNToastFrame.mover then
		self:ClearAllPoints()
		self:SetPoint(BNToastFrame.mover.anchorPoint or "TOPLEFT", BNToastFrame.mover, BNToastFrame.mover.anchorPoint or "TOPLEFT")
	end
end

function Module:UpdateMaxCameraZoom()
	SetCVar("cameraDistanceMaxZoomFactor", C["Misc"].MaxCameraZoom)
end
