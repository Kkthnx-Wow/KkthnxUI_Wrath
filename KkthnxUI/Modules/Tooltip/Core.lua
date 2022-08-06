local K, C = unpack(select(2, ...))
local Module = K:NewModule("Tooltip")

local _G = _G
local pairs = _G.pairs
local select = _G.select
local string_find = _G.string.find
local string_format = _G.string.format
local string_len = _G.string.len
local string_upper = _G.string.upper
local unpack = _G.unpack

local AFK = _G.AFK
local BOSS = _G.BOSS
local C_Timer_After = _G.C_Timer.After
local CreateFrame = _G.CreateFrame
local DEAD = _G.DEAD
local DND = _G.DND
local FACTION_ALLIANCE = _G.FACTION_ALLIANCE
local FACTION_HORDE = _G.FACTION_HORDE
local FOREIGN_SERVER_LABEL = _G.FOREIGN_SERVER_LABEL
local GetCreatureDifficultyColor = _G.GetCreatureDifficultyColor
local GetGuildInfo = _G.GetGuildInfo
local GetItemInfo = _G.GetItemInfo
local GetMouseFocus = _G.GetMouseFocus
local GetRaidTargetIndex = _G.GetRaidTargetIndex
local ICON_LIST = _G.ICON_LIST
local INTERACTIVE_SERVER_LABEL = _G.INTERACTIVE_SERVER_LABEL
local InCombatLockdown = _G.InCombatLockdown
local IsInGuild = _G.IsInGuild
local IsShiftKeyDown = _G.IsShiftKeyDown
local LEVEL = _G.LEVEL
local LE_REALM_RELATION_COALESCED = _G.LE_REALM_RELATION_COALESCED
local LE_REALM_RELATION_VIRTUAL = _G.LE_REALM_RELATION_VIRTUAL
local PLAYER_OFFLINE = _G.PLAYER_OFFLINE
local PVP = _G.PVP
local TARGET = _G.TARGET
local UIDROPDOWNMENU_MAXLEVELS = _G.UIDROPDOWNMENU_MAXLEVELS
local UIParent = _G.UIParent
local UnitClass = _G.UnitClass
local UnitClassification = _G.UnitClassification
local UnitCreatureType = _G.UnitCreatureType
local UnitExists = _G.UnitExists
local UnitFactionGroup = _G.UnitFactionGroup
local UnitGUID = _G.UnitGUID
local UnitIsAFK = _G.UnitIsAFK
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDND = _G.UnitIsDND
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitIsPVP = _G.UnitIsPVP
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsUnit = _G.UnitIsUnit
local UnitLevel = _G.UnitLevel
local UnitName = _G.UnitName
local UnitPVPName = _G.UnitPVPName
local UnitRace = _G.UnitRace
local UnitRealmRelationship = _G.UnitRealmRelationship
local YOU = _G.YOU
local hooksecurefunc = _G.hooksecurefunc

local tipTable = {}
local GameTooltip_Mover

local classification = {
	worldboss = string_format("|cffAF5050 %s|r", BOSS),
	rareelite = string_format("|cffAF5050+ %s|r", ITEM_QUALITY3_DESC),
	elite = "|cffAF5050+|r",
	rare = string_format("|cffAF5050 %s|r", ITEM_QUALITY3_DESC),
}
local npcIDstring = "ID: " .. K.InfoColor .. "%s"

function Module:GetUnit()
	local _, unit = self and self:GetUnit()
	if not unit then
		local mFocus = GetMouseFocus()
		unit = mFocus and (mFocus.unit or (mFocus.GetAttribute and mFocus:GetAttribute("unit"))) or "mouseover"
	end

	return unit
end

function Module:HideLines()
	if self:IsForbidden() then
		return
	end

	for i = 3, self:NumLines() do
		local tiptext = _G["GameTooltipTextLeft" .. i]
		local linetext = tiptext:GetText()
		if linetext then
			if linetext == PVP then
				tiptext:SetText(nil)
				tiptext:Hide()
			elseif linetext == FACTION_HORDE then
				if C["Tooltip"].FactionIcon then
					tiptext:SetText(nil)
					tiptext:Hide()
				else
					tiptext:SetText("|cffff5040" .. linetext .. "|r")
				end
			elseif linetext == FACTION_ALLIANCE then
				if C["Tooltip"].FactionIcon then
					tiptext:SetText(nil)
					tiptext:Hide()
				else
					tiptext:SetText("|cff4080ff" .. linetext .. "|r")
				end
			end
		end
	end
end

function Module:GetLevelLine()
	if self:IsForbidden() then
		return
	end

	for i = 2, self:NumLines() do
		local tiptext = _G["GameTooltipTextLeft" .. i]
		local linetext = tiptext:GetText()
		if linetext and string_find(linetext, LEVEL) then
			return tiptext
		end
	end
end

function Module:GetTarget(unit)
	if UnitIsUnit(unit, "player") then
		return string_format("|cffff0000%s|r", ">" .. string_upper(YOU) .. "<")
	else
		return K.RGBToHex(K.UnitColor(unit)) .. UnitName(unit) .. "|r"
	end
end

function Module:InsertFactionFrame(faction)
	if not self.factionFrame then
		self.factionFrame = self:CreateTexture(nil, "OVERLAY")
		self.factionFrame:SetPoint("TOPRIGHT", 0, -4)
		self.factionFrame:SetBlendMode("ADD")
		self.factionFrame:SetSize(38, 38)
	end

	self.factionFrame:SetTexture("Interface\\Timer\\" .. faction .. "-Logo")
	self.factionFrame:SetAlpha(0.3)
end

function Module:OnTooltipCleared()
	if self:IsForbidden() then
		return
	end

	if self.factionFrame and self.factionFrame:GetAlpha() ~= 0 then
		self.factionFrame:SetAlpha(0)
	end
end

function Module:OnTooltipSetUnit()
	if self:IsForbidden() then
		return
	end

	if C["Tooltip"].CombatHide and InCombatLockdown() then
		self:Hide()
		return
	end

	Module.HideLines(self)

	local unit = Module.GetUnit(self)
	local isShiftKeyDown = IsShiftKeyDown()
	if UnitExists(unit) then
		local hexColor = K.RGBToHex(K.UnitColor(unit))
		local ricon = GetRaidTargetIndex(unit)
		local text = GameTooltipTextLeft1:GetText()

		if ricon and ricon > 8 then
			ricon = nil
		end

		if ricon and text then
			GameTooltipTextLeft1:SetFormattedText("%s %s", ICON_LIST[ricon] .. "18|t", text)
		end

		local isPlayer = UnitIsPlayer(unit)
		if isPlayer then
			local name, realm = UnitName(unit)
			local pvpName = UnitPVPName(unit)
			local relationship = UnitRealmRelationship(unit)

			if not C["Tooltip"].HideTitle and pvpName then
				name = pvpName
			end

			if realm and realm ~= "" then
				if isShiftKeyDown or not C["Tooltip"].HideRealm then
					name = name .. "-" .. realm
				elseif relationship == LE_REALM_RELATION_COALESCED then
					name = name .. FOREIGN_SERVER_LABEL
				elseif relationship == LE_REALM_RELATION_VIRTUAL then
					name = name .. INTERACTIVE_SERVER_LABEL
				end
			end

			local status = (UnitIsAFK(unit) and AFK) or (UnitIsDND(unit) and DND) or (not UnitIsConnected(unit) and PLAYER_OFFLINE)
			if status then
				status = string_format(" |cffffcc00[%s]|r", status)
			end
			GameTooltipTextLeft1:SetFormattedText("%s", name .. (status or ""))

			if C["Tooltip"].FactionIcon then
				local faction = UnitFactionGroup(unit)
				if faction and faction ~= "Neutral" then
					Module.InsertFactionFrame(self, faction)
				end
			end

			local guildName, rank, rankIndex, guildRealm = GetGuildInfo(unit)
			local hasText = GameTooltipTextLeft2:GetText()
			if guildName and hasText then
				local myGuild, _, _, myGuildRealm = GetGuildInfo("player")
				if IsInGuild() and guildName == myGuild and guildRealm == myGuildRealm then
					GameTooltipTextLeft2:SetTextColor(0.25, 1, 0.25)
				else
					GameTooltipTextLeft2:SetTextColor(0.6, 0.8, 1)
				end

				rankIndex = rankIndex + 1
				if C["Tooltip"].HideRank then
					rank = ""
				end

				if guildRealm and isShiftKeyDown then
					guildName = guildName .. "-" .. guildRealm
				end

				if C["Tooltip"].HideJunkGuild and not isShiftKeyDown then
					if string_len(guildName) > 31 then
						guildName = "..."
					end
				end
				GameTooltipTextLeft2:SetText("<" .. guildName .. "> " .. rank .. "(" .. rankIndex .. ")")
			end
		end

		local line1 = GameTooltipTextLeft1:GetText()
		GameTooltipTextLeft1:SetFormattedText("%s", hexColor .. line1)

		local alive = not UnitIsDeadOrGhost(unit)
		local level = UnitLevel(unit)

		if level then
			local boss
			if level == -1 then
				boss = "|cffff0000??|r"
			end

			local diff = GetCreatureDifficultyColor(level)
			local classify = UnitClassification(unit)
			local textLevel = string_format("%s%s%s|r", K.RGBToHex(diff), boss or string_format("%d", level), classification[classify] or "")
			local tiptextLevel = Module.GetLevelLine(self)
			if tiptextLevel then
				local pvpFlag = isPlayer and UnitIsPVP(unit) and string_format(" |cffff0000%s|r", PVP) or ""
				local unitClass = isPlayer and string_format("%s %s", UnitRace(unit) or "", hexColor .. (UnitClass(unit) or "") .. "|r") or UnitCreatureType(unit) or ""
				tiptextLevel:SetFormattedText("%s%s %s %s", textLevel, pvpFlag, unitClass, (not alive and "|cffCCCCCC" .. DEAD .. "|r" or ""))
			end
		end

		if UnitExists(unit .. "target") then
			local tarRicon = GetRaidTargetIndex(unit .. "target")
			if tarRicon and tarRicon > 8 then
				tarRicon = nil
			end

			local tar = string_format("%s%s", (tarRicon and ICON_LIST[tarRicon] .. "10|t") or "", Module:GetTarget(unit .. "target"))
			self:AddLine(TARGET .. ": " .. tar)
		end

		if not isPlayer and isShiftKeyDown then
			local guid = UnitGUID(unit)
			local npcID = K.GetNPCID(guid)
			if npcID then
				self:AddLine(string_format(npcIDstring, npcID))
			end
		end

		if alive then
			self.StatusBar:SetStatusBarColor(K.UnitColor(unit))
		else
			self.StatusBar:Hide()
		end
	else
		self.StatusBar:SetStatusBarColor(0, 0.9, 0)
	end
end

function Module:StatusBar_OnValueChanged(value)
	if self:IsForbidden() or not value then
		return
	end

	local min, max = self:GetMinMaxValues()
	if (value < min) or (value > max) then
		return
	end

	if not self.text then
		self.text = K.CreateFontString(self, 11, nil, "")
	end

	if value > 0 and max == 1 then
		self.text:SetFormattedText("%d%%", value * 100)
	else
		self.text:SetText(K.ShortValue(value) .. " - " .. K.ShortValue(max))
	end
end

function Module:ReskinStatusBar()
	if not self or self:IsForbidden() or not self.StatusBar then
		return
	end

	self.StatusBar:ClearAllPoints()
	self.StatusBar:SetPoint("BOTTOMLEFT", self.tooltipStyle, "TOPLEFT", 0, 6)
	self.StatusBar:SetPoint("BOTTOMRIGHT", self.tooltipStyle, "TOPRIGHT", -0, 6)
	self.StatusBar:SetStatusBarTexture(K.GetTexture(C["UITextures"].TooltipTextures))
	self.StatusBar:SetHeight(11)
	self.StatusBar:CreateBorder()
end

function Module:GameTooltip_ShowStatusBar()
	if not self or self:IsForbidden() or not self.statusBarPool then
		return
	end

	local bar = self.statusBarPool:GetNextActive()
	if (not bar or not bar.text) or bar.isStyled then
		return
	end

	bar:StripTextures()
	bar:CreateBorder()
	bar:SetStatusBarTexture(K.GetTexture(C["UITextures"].TooltipTextures))

	bar.isStyled = true
end

function Module:GameTooltip_ShowProgressBar()
	if not self or self:IsForbidden() or not self.progressBarPool then
		return
	end

	local bar = self.progressBarPool:GetNextActive()
	if (not bar or not bar.Bar) or bar.isStyled then
		return
	end

	bar.Bar:StripTextures()
	bar.Bar:SetStatusBarTexture(K.GetTexture(C["UITextures"].TooltipTextures))
	bar.Bar:CreateBorder()

	bar.isStyled = true
end

-- Anchor and mover
function Module:GameTooltip_SetDefaultAnchor(parent)
	if self:IsForbidden() then
		return
	end

	if not parent then
		return
	end

	if C["Tooltip"].Cursor then
		self:SetOwner(parent, "ANCHOR_CURSOR_RIGHT")
	else
		if not GameTooltip_Mover then
			GameTooltip_Mover = K.Mover(self, "Tooltip", "GameTooltip", { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -182, 36 }, 240, 120)
		end

		self:SetOwner(parent, "ANCHOR_NONE")
		self:ClearAllPoints()
		self:SetPoint("BOTTOMRIGHT", GameTooltip_Mover)
	end
end

-- Fix comparison error on cursor
function Module:GameTooltip_ComparisonFix(anchorFrame, shoppingTooltip1, shoppingTooltip2, _, secondaryItemShown)
	local point = shoppingTooltip1:GetPoint(2)
	if secondaryItemShown then
		if point == "TOP" then
			shoppingTooltip1:ClearAllPoints()
			shoppingTooltip1:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", 3, 0)
			shoppingTooltip2:ClearAllPoints()
			shoppingTooltip2:SetPoint("TOPLEFT", shoppingTooltip1, "TOPRIGHT", 3, 0)
		elseif point == "RIGHT" then
			shoppingTooltip1:ClearAllPoints()
			shoppingTooltip1:SetPoint("TOPRIGHT", anchorFrame, "TOPLEFT", -3, 0)
			shoppingTooltip2:ClearAllPoints()
			shoppingTooltip2:SetPoint("TOPRIGHT", shoppingTooltip1, "TOPLEFT", -3, 0)
		end
	else
		if point == "LEFT" then
			shoppingTooltip1:ClearAllPoints()
			shoppingTooltip1:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", 3, 0)
		elseif point == "RIGHT" then
			shoppingTooltip1:ClearAllPoints()
			shoppingTooltip1:SetPoint("TOPRIGHT", anchorFrame, "TOPLEFT", -3, 0)
		end
	end
end

-- Tooltip skin
local fakeBg = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
fakeBg:SetBackdrop({
	bgFile = C["Media"].Textures.BlankTexture,
	edgeFile = "Interface\\AddOns\\KkthnxUI\\Media\\Border\\" .. C["General"].BorderStyle.Value .. "\\Border_Tooltip.tga",
	edgeSize = 12,
	insets = { left = 4, right = 4, top = 4, bottom = 4 },
})

local function __GetBackdrop()
	return fakeBg:GetBackdrop()
end

local function __GetBackdropColor()
	return 0.04, 0.04, 0.04, 0.9
end

local function __GetBackdropBorderColor()
	return 1, 1, 1
end

function Module:ReskinTooltip()
	if not self then
		if K.isDeveloper then
			K.Print("Unknown tooltip spotted!")
		end
		return
	end

	if self:IsForbidden() then
		return
	end

	if not self.isTipStyled then
		if self.NineSlice then
			self.NineSlice:SetAlpha(0)
		end

		if self.SetBackdrop then
			self:SetBackdrop(nil)
		end
		self:DisableDrawLayer("BACKGROUND")

		self.tooltipStyle = CreateFrame("Frame", nil, self)
		self.tooltipStyle:SetPoint("TOPLEFT", self, 2, -2)
		self.tooltipStyle:SetPoint("BOTTOMRIGHT", self, -2, 2)
		self.tooltipStyle:SetFrameLevel(self:GetFrameLevel())
		self.tooltipStyle:CreateBorder(nil, -1)

		if self.StatusBar then
			Module.ReskinStatusBar(self)
		end

		if self.GetBackdrop then
			self.GetBackdrop = __GetBackdrop
			self.GetBackdropColor = __GetBackdropColor
			self.GetBackdropBorderColor = __GetBackdropBorderColor
		end

		self.isTipStyled = true
	end

	if C["General"].ColorTextures then
		self.tooltipStyle.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
	else
		self.tooltipStyle.KKUI_Border:SetVertexColor(1, 1, 1)
	end

	if C["Tooltip"].ClassColor and self.GetItem then
		local _, item = self:GetItem()
		if item then
			local quality = select(3, GetItemInfo(item))
			local color = K.QualityColors[quality or 1]
			if color then
				self.tooltipStyle.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
			end
		end
	end
end

function Module:OnEnable()
	GameTooltip.StatusBar = GameTooltipStatusBar
	GameTooltip:HookScript("OnTooltipCleared", Module.OnTooltipCleared)
	GameTooltip:HookScript("OnTooltipSetUnit", Module.OnTooltipSetUnit)
	GameTooltip.StatusBar:SetScript("OnValueChanged", Module.StatusBar_OnValueChanged)
	hooksecurefunc("GameTooltip_ShowStatusBar", Module.GameTooltip_ShowStatusBar)
	hooksecurefunc("GameTooltip_ShowProgressBar", Module.GameTooltip_ShowProgressBar)
	hooksecurefunc("GameTooltip_SetDefaultAnchor", Module.GameTooltip_SetDefaultAnchor)
	hooksecurefunc("GameTooltip_AnchorComparisonTooltips", Module.GameTooltip_ComparisonFix)

	-- Elements
	self:CreateTargetedInfo()
	self:CreateTooltipID()
	self:CreateTooltipIcons()
end

-- Tooltip Skin Registration
function Module:RegisterTooltips(addon, func)
	tipTable[addon] = func
end

local function addonStyled(_, addon)
	if tipTable[addon] then
		tipTable[addon]()
		tipTable[addon] = nil
	end
end
K:RegisterEvent("ADDON_LOADED", addonStyled)

Module:RegisterTooltips("KkthnxUI", function()
	local tooltips = {
		AutoCompleteBox,
		ChatMenu,
		EmbeddedItemTooltip,
		EmoteMenu,
		FriendsTooltip,
		GameTooltip,
		GeneralDockManagerOverflowButtonList,
		IMECandidatesFrame,
		ItemRefShoppingTooltip1,
		ItemRefShoppingTooltip2,
		ItemRefTooltip,
		LanguageMenu,
		NamePlateTooltip,
		ShoppingTooltip1,
		ShoppingTooltip2,
		VoiceMacroMenu,
		WorldMapTooltip,
	}

	for _, f in pairs(tooltips) do
		f:HookScript("OnShow", Module.ReskinTooltip)
	end

	_G.ItemRefCloseButton:SkinCloseButton()

	-- DropdownMenu
	local function reskinDropdown()
		for _, name in pairs({ "DropDownList", "L_DropDownList", "Lib_DropDownList" }) do
			for i = 1, UIDROPDOWNMENU_MAXLEVELS do
				local menu = _G[name .. i .. "MenuBackdrop"]
				if menu and not menu.isStyled then
					menu:HookScript("OnShow", Module.ReskinTooltip)
					menu.isStyled = true
				end
			end
		end
	end
	hooksecurefunc("UIDropDownMenu_CreateFrames", reskinDropdown)

	-- IME
	local r, g, b = K.r, K.g, K.b
	IMECandidatesFrame.selection:SetVertexColor(r, g, b)

	-- Others
	C_Timer_After(5, function()
		-- BagSync
		if BSYC_EventAlertTooltip then
			Module.ReskinTooltip(BSYC_EventAlertTooltip)
		end

		-- Lib minimap icon
		if LibDBIconTooltip then
			Module.ReskinTooltip(LibDBIconTooltip)
		end

		-- TomTom
		if TomTomTooltip then
			Module.ReskinTooltip(TomTomTooltip)
		end

		-- RareScanner
		if RSMapItemToolTip then
			Module.ReskinTooltip(RSMapItemToolTip)
		end

		if LootBarToolTip then
			Module.ReskinTooltip(LootBarToolTip)
		end

		-- Narcissus
		if NarciGameTooltip then
			Module.ReskinTooltip(NarciGameTooltip)
		end

		if CharNoteTooltip then
			Module.ReskinTooltip(CharNoteTooltip)
		end

		if AceGUITooltip then
			Module.ReskinTooltip(AceGUITooltip)
		end

		if AceConfigDialogTooltip then
			Module.ReskinTooltip(AceConfigDialogTooltip)
		end

		if WhatsTrainingTooltip then
			Module.ReskinTooltip(WhatsTrainingTooltip)
		end

		if GameCooltipFrame then
			Module.ReskinTooltip(GameCooltipFrame)
		end
	end)
end)

Module:RegisterTooltips("Blizzard_DebugTools", function()
	Module.ReskinTooltip(FrameStackTooltip)
	FrameStackTooltip:SetScale(UIParent:GetScale())
end)

Module:RegisterTooltips("Blizzard_EventTrace", function()
	Module.ReskinTooltip(EventTraceTooltip)
end)
