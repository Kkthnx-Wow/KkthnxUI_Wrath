local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Miscellaneous")

local math_min = _G.math.min
local string_format = _G.string.format
local pairs = _G.pairs
local select = _G.select

local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS
local GetWatchedFactionInfo = _G.GetWatchedFactionInfo
local GetXPExhaustion = _G.GetXPExhaustion
local IsLevelAtEffectiveMaxLevel = _G.IsLevelAtEffectiveMaxLevel
local IsPlayerAtEffectiveMaxLevel = _G.IsPlayerAtEffectiveMaxLevel
local IsTrialAccount = _G.IsTrialAccount
local IsVeteranTrialAccount = _G.IsVeteranTrialAccount
local IsXPUserDisabled = _G.IsXPUserDisabled
local LEVEL = _G.LEVEL
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax

local CurrentXP, XPToLevel, RestedXP, PercentRested
local PercentXP, RemainXP, RemainTotal, RemainBars

local function GetValues(curValue, minValue, maxValue)
	local maximum = maxValue - minValue
	local current, diff = curValue - minValue, maximum

	if diff == 0 then -- prevent a division by zero
		diff = 1
	end

	if current == maximum then
		return 1, 1, 100, true
	else
		return current, maximum, current / diff * 100
	end
end

function Module:ExpBar_Update()
	if not IsPlayerAtEffectiveMaxLevel() then
		CurrentXP, XPToLevel, RestedXP = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
		if XPToLevel <= 0 then
			XPToLevel = 1
		end

		local remainXP = XPToLevel - CurrentXP
		local remainPercent = remainXP / XPToLevel
		RemainTotal, RemainBars = remainPercent * 100, remainPercent * 20
		PercentXP, RemainXP = (CurrentXP / XPToLevel) * 100, K.ShortValue(remainXP)

		self:SetStatusBarColor(0, 0.4, 1, 0.8)
		self.restBar:SetStatusBarColor(1, 0, 1, 0.4)

		local displayString = ""

		self:SetMinMaxValues(0, XPToLevel)
		self:SetValue(CurrentXP)
		self:Show()

		displayString = string_format("%s - %.2f%%", K.ShortValue(CurrentXP), PercentXP)

		local isRested = RestedXP and RestedXP > 0
		if isRested then
			self.restBar:SetMinMaxValues(0, XPToLevel)
			self.restBar:SetValue(math_min(CurrentXP + RestedXP, XPToLevel))

			PercentRested = (RestedXP / XPToLevel) * 100
			displayString = string_format("%s R:%s [%.2f%%]", displayString, K.ShortValue(RestedXP), PercentRested)
		end
		self.restBar:SetShown(isRested)

		if IsLevelAtEffectiveMaxLevel(K.Level) or IsXPUserDisabled() or (IsTrialAccount() or IsVeteranTrialAccount()) and (K.Level == 20) then
			self:SetMinMaxValues(0, 1)
			self:SetValue(1)
			self:Show()

			displayString = IsXPUserDisabled() and "Disabled" or "Max Level"
		end

		self.text:SetText(displayString)
		self.text:Show()
	elseif GetWatchedFactionInfo() then
		local label, rewardPending
		local name, reaction, minValue, maxValue, curValue = GetWatchedFactionInfo()

		if not label then
			label = _G["FACTION_STANDING_LABEL" .. reaction] or UNKNOWN
		end

		local color = (reaction == 9 and { r = 0, g = 0.5, b = 0.9 }) or _G.FACTION_BAR_COLORS[reaction] -- reaction 9 is Paragon
		self:SetStatusBarColor(color.r, color.g, color.b)
		self:SetMinMaxValues(minValue, maxValue)
		self:SetValue(curValue)
		self:Show()
		self.reward:SetShown(rewardPending)

		local current, _, percent, capped = GetValues(curValue, minValue, maxValue)
		if capped then -- show only name and standing on exalted
			self.text:SetText(string_format("%s: [%s]", name, label))
		else
			self.text:SetText(string_format("%s: %s - %d%% [%s]", name, K.ShortValue(current), percent, K.ShortenString(label, 1, false)))
		end
		self.text:Show()
	else
		self:Hide()
		self.text:Hide()
	end
end

function Module:ExpBar_UpdateTooltip()
	if GameTooltip:IsForbidden() then
		return
	end
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")

	if not IsPlayerAtEffectiveMaxLevel() then
		CurrentXP, XPToLevel, RestedXP = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
		if XPToLevel <= 0 then
			XPToLevel = 1
		end

		local remainXP = XPToLevel - CurrentXP
		local remainPercent = remainXP / XPToLevel
		RemainTotal, RemainBars = remainPercent * 100, remainPercent * 20
		PercentXP, RemainXP = (CurrentXP / XPToLevel) * 100, K.ShortValue(remainXP)

		GameTooltip:AddLine("Experience", 0, 0.4, 1)
		GameTooltip:AddDoubleLine(LEVEL, K.Level, 1, 1, 1)
		GameTooltip:AddDoubleLine("XP:", string_format(" %d / %d (%.2f%%)", CurrentXP, XPToLevel, PercentXP), 1, 1, 1)
		GameTooltip:AddDoubleLine("Remaining:", string_format(" %s (%.2f%% - %d " .. L["Bars"] .. ")", RemainXP, RemainTotal, RemainBars), 1, 1, 1)

		if RestedXP and RestedXP > 0 then
			GameTooltip:AddDoubleLine("Rested:", string_format("%d (%.2f%%)", RestedXP, PercentRested), 1, 1, 1)
		end
	end

	if GetWatchedFactionInfo() then
		local name, reaction, minValue, maxValue, curValue = GetWatchedFactionInfo()

		if name then
			GameTooltip:AddLine(name, FACTION_BAR_COLORS[reaction].r, FACTION_BAR_COLORS[reaction].g, FACTION_BAR_COLORS[reaction].b)

			if reaction ~= _G.MAX_REPUTATION_REACTION then
				local current, maximum, percent = GetValues(curValue, minValue, maxValue)
				GameTooltip:AddDoubleLine(REPUTATION .. ":", string_format("%d / %d (%d%%)", current, maximum, percent), 1, 1, 1)
			end
		end
	end

	GameTooltip:Show()
end

function Module:SetupExpRepScript(bar)
	bar.eventList = {
		"PLAYER_XP_UPDATE",
		"PLAYER_LEVEL_UP",
		"UPDATE_EXHAUSTION",
		"PLAYER_ENTERING_WORLD",
		"UPDATE_FACTION",
		"UNIT_INVENTORY_CHANGED",
		"ENABLE_XP_GAIN",
		"DISABLE_XP_GAIN",
	}

	for _, event in pairs(bar.eventList) do
		bar:RegisterEvent(event)
	end

	bar:SetScript("OnEvent", Module.ExpBar_Update)
	bar:SetScript("OnEnter", Module.ExpBar_UpdateTooltip)
	bar:SetScript("OnLeave", K.HideTooltip)
end

function Module:CreateExpbar()
	if not C["Misc"].ExpRep then
		return
	end

	local bar = CreateFrame("StatusBar", "KKUI_ExpRepBar", MinimapCluster)
	bar:SetPoint("TOP", Minimap, "BOTTOM", 0, -6)
	bar:SetSize(Minimap:GetWidth() or 190, 14)
	bar:SetHitRectInsets(0, 0, 0, -10)
	bar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))

	local spark = bar:CreateTexture(nil, "OVERLAY")
	spark:SetTexture(C["Media"].Textures.Spark16Texture)
	spark:SetHeight(bar:GetHeight())
	spark:SetBlendMode("ADD")
	spark:SetPoint("CENTER", bar:GetStatusBarTexture(), "RIGHT", 0, 0)

	local border = CreateFrame("Frame", nil, bar)
	border:SetAllPoints(bar)
	border:SetFrameLevel(bar:GetFrameLevel())
	border:CreateBorder()

	local rest = CreateFrame("StatusBar", nil, bar)
	rest:SetAllPoints()
	rest:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	rest:SetStatusBarColor(1, 0, 1, 0.4)
	rest:SetFrameLevel(bar:GetFrameLevel() - 1)
	bar.restBar = rest

	local reward = bar:CreateTexture(nil, "OVERLAY")
	reward:SetAtlas("ParagonReputation_Bag")
	reward:SetSize(12, 14)
	bar.reward = reward

	local text = bar:CreateFontString(nil, "OVERLAY")
	text:SetFontObject(K.UIFont)
	text:SetFont(select(1, text:GetFont()), 11, select(3, text:GetFont()))
	text:SetWidth(bar:GetWidth() - 6)
	text:SetWordWrap(false)
	text:SetPoint("LEFT", bar, "RIGHT", -3, 0)
	text:SetPoint("RIGHT", bar, "LEFT", 3, 0)
	bar.text = text

	Module:SetupExpRepScript(bar)

	if not bar.mover then
		bar.mover = K.Mover(bar, "bar", "bar", { "TOP", Minimap, "BOTTOM", 0, -6 })
	else
		bar.mover:SetSize(Minimap:GetWidth() or 190, 14)
	end
end
Module:RegisterMisc("ExpRep", Module.CreateExpbar)
