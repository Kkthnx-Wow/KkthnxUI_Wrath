local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("DataBars")

local _G = _G
local pairs = _G.pairs
local select = _G.select
local string_format = _G.string.format

local CreateFrame = _G.CreateFrame
local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS
local GameTooltip = _G.GameTooltip
local GetPetExperience = _G.GetPetExperience
local GetWatchedFactionInfo = _G.GetWatchedFactionInfo
local GetXPExhaustion = _G.GetXPExhaustion
local HasPetUI = _G.HasPetUI
local IsPlayerAtEffectiveMaxLevel = _G.IsPlayerAtEffectiveMaxLevel
local LEVEL = _G.LEVEL
local REPUTATION = _G.REPUTATION
local STANDING = _G.STANDING
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax

-- Experience
local CurrentXP, XPToLevel, RestedXP, PercentRested
local PercentXP, RemainXP, RemainTotal, RemainBars
-- Pet Experience
local PetCurrentXP, PetXPToLevel
local PetPercentXP, PetRemainXP, PetRemainTotal, PetRemainBars
-- Reputation
local KKUI_FACTION_BAR_COLORS = {
	[1] = {r = .8, g = .3, b = .22},
	[2] = {r = .8, g = .3, b = .22},
	[3] = {r = .75, g = .27, b = 0},
	[4] = {r = .9, g = .7, b = 0},
	[5] = {r = 0, g = .6, b = .1},
	[6] = {r = 0, g = .6, b = .1},
	[7] = {r = 0, g = .6, b = .1},
	[8] = {r = 0, g = .6, b = .1},
	[9] = {r = 0, g = .6, b = .1},
}

function Module:SetupExperience()
	local expbar = CreateFrame("StatusBar", "KKUI_ExperienceBar", self.Container)
	expbar:SetStatusBarTexture(self.DatabaseTexture)
	expbar:SetStatusBarColor(C["DataBars"].ExperienceColor[1], C["DataBars"].ExperienceColor[2], C["DataBars"].ExperienceColor[3], C["DataBars"].ExperienceColor[4])
	expbar:SetSize(C["DataBars"].Width, C["DataBars"].Height)
	expbar:CreateBorder()

	local restbar = CreateFrame("StatusBar", "KKUI_RestBar", self.Container)
	restbar:SetStatusBarTexture(self.DatabaseTexture)
	restbar:SetStatusBarColor(C["DataBars"].RestedColor[1], C["DataBars"].RestedColor[2], C["DataBars"].RestedColor[3], C["DataBars"].RestedColor[4])
	restbar:SetFrameLevel(3)
	restbar:SetSize(C["DataBars"].Width, C["DataBars"].Height)
	restbar:SetAlpha(0.5)
	restbar:SetAllPoints(expbar)

	local espark = expbar:CreateTexture(nil, "OVERLAY")
	espark:SetTexture(C["Media"].Textures.Spark16Texture)
	espark:SetHeight(C["DataBars"].Height)
	espark:SetBlendMode("ADD")
	espark:SetPoint("CENTER", expbar:GetStatusBarTexture(), "RIGHT", 0, 0)

	local etext = expbar:CreateFontString(nil, "OVERLAY")
	etext:SetFontObject(self.DatabaseFont)
	etext:SetFont(select(1, etext:GetFont()), 11, select(3, etext:GetFont()))
	etext:SetPoint("LEFT", expbar, "RIGHT", -3, 0)
	etext:SetPoint("RIGHT", expbar, "LEFT", 3, 0)

	self.Bars.Experience = expbar
	expbar.RestBar = restbar
	expbar.Text = etext
end

function Module:SetupPetExperience()
	local petExpbar = CreateFrame("StatusBar", "KKUI_PetExperienceBar", self.Container)
	petExpbar:SetStatusBarTexture(self.DatabaseTexture)
	petExpbar:SetStatusBarColor(C["DataBars"].PetExperienceColor[1], C["DataBars"].PetExperienceColor[2], C["DataBars"].PetExperienceColor[3], C["DataBars"].PetExperienceColor[4])
	petExpbar:SetSize(C["DataBars"].Width, C["DataBars"].Height)
	petExpbar:CreateBorder()

	local pspark = petExpbar:CreateTexture(nil, "OVERLAY")
	pspark:SetTexture(C["Media"].Textures.Spark16Texture)
	pspark:SetHeight(C["DataBars"].Height)
	pspark:SetBlendMode("ADD")
	pspark:SetPoint("CENTER", petExpbar:GetStatusBarTexture(), "RIGHT", 0, 0)

	local ptext = petExpbar:CreateFontString(nil, "OVERLAY")
	ptext:SetFontObject(self.DatabaseFont)
	ptext:SetFont(select(1, ptext:GetFont()), 11, select(3, ptext:GetFont()))
	ptext:SetPoint("LEFT", petExpbar, "RIGHT", -3, 0)
	ptext:SetPoint("RIGHT", petExpbar, "LEFT", 3, 0)

	self.Bars.PetExperience = petExpbar
	petExpbar.Text = ptext
end

function Module:SetupReputation()
	local reputation = CreateFrame("StatusBar", "KKUI_ReputationBar", self.Container)
	reputation:SetStatusBarTexture(self.DatabaseTexture)
	reputation:SetStatusBarColor(1, 1, 1)
	reputation:SetSize(C["DataBars"].Width, C["DataBars"].Height)
	reputation:CreateBorder()

	local rspark = reputation:CreateTexture(nil, "OVERLAY")
	rspark:SetTexture(C["Media"].Textures.Spark16Texture)
	rspark:SetHeight(C["DataBars"].Height)
	rspark:SetBlendMode("ADD")
	rspark:SetPoint("CENTER", reputation:GetStatusBarTexture(), "RIGHT", 0, 0)

	local rtext = reputation:CreateFontString(nil, "OVERLAY")
	rtext:SetFontObject(self.DatabaseFont)
	rtext:SetFont(select(1, rtext:GetFont()), 11, select(3, rtext:GetFont()))
	rtext:SetWidth(C["DataBars"].Width - 6)
	rtext:SetWordWrap(false)
	rtext:SetPoint("LEFT", reputation, "RIGHT", -3, 0)
	rtext:SetPoint("RIGHT", reputation, "LEFT", 3, 0)

	self.Bars.Reputation = reputation
	reputation.Text = rtext
end

function Module:UpdateExperience()
	local expBar = self.Bars.Experience

	if IsPlayerAtEffectiveMaxLevel() then
		expBar:Hide()
		return
	else
		expBar:Show()
	end

	CurrentXP, XPToLevel, RestedXP = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
	if XPToLevel <= 0 then
		XPToLevel = 1
	end

	local remainXP = XPToLevel - CurrentXP
	local remainPercent = remainXP / XPToLevel
	RemainTotal, RemainBars = remainPercent * 100, remainPercent * 20
	PercentXP, RemainXP = (CurrentXP / XPToLevel) * 100, K.ShortValue(remainXP)

	local displayString, textFormat = "", C["DataBars"].Text.Value
	if IsPlayerAtEffectiveMaxLevel() then
		expBar:SetMinMaxValues(0, 1)
		expBar:SetValue(1)

		if textFormat ~= 0 then
			displayString = "Max Level"
		end
	else
		expBar:SetMinMaxValues(0, XPToLevel)
		expBar:SetValue(CurrentXP)

		if textFormat == 1 then
			displayString = string_format("%.2f%%", PercentXP)
		elseif textFormat == 2 then
			displayString = string_format("%s - %s", K.ShortValue(CurrentXP), K.ShortValue(XPToLevel))
		elseif textFormat == 3 then
			displayString = string_format("%s - %.2f%%", K.ShortValue(CurrentXP), PercentXP)
		elseif textFormat == 4 then
			displayString = string_format("%s", K.ShortValue(CurrentXP))
		elseif textFormat == 5 then
			displayString = string_format("%s", RemainXP)
		elseif textFormat == 6 then
			displayString = string_format("%s - %s", K.ShortValue(CurrentXP), RemainXP)
		elseif textFormat == 7 then
			displayString = string_format("%s - %.2f%% (%s)", K.ShortValue(CurrentXP), PercentXP, RemainXP)
		end

		local isRested = RestedXP and RestedXP > 0
		if isRested then
			expBar.RestBar:SetMinMaxValues(0, XPToLevel)
			expBar.RestBar:SetValue(math.min(CurrentXP + RestedXP, XPToLevel))

			PercentRested = (RestedXP / XPToLevel) * 100

			if textFormat == 1 then
				displayString = string_format("%s R:%.2f%%", displayString, PercentRested)
			elseif textFormat == 3 then
				displayString = string_format("%s R:%s [%.2f%%]", displayString, K.ShortValue(RestedXP), PercentRested)
			elseif textFormat ~= 0 then
				displayString = string_format("%s R:%s", displayString, K.ShortValue(RestedXP))
			end
		end
		expBar.RestBar:SetShown(isRested)
	end

	expBar.Text:SetText(displayString)
end

function Module:UpdatePetExperience()
	if K.Class ~= "HUNTER" or not C["DataBars"].PetExperience then
		if self.Bars.PetExperience then
			self.Bars.PetExperience:Hide()
		end
		return
	end

	local petExpBar = self.Bars.PetExperience
	local _, hunterPet = HasPetUI()
	local hideBar = not hunterPet or (UnitLevel("pet") == 70 and true)

	if hideBar then
		petExpBar:Hide()
	elseif not hideBar then
		petExpBar:Show()

		PetCurrentXP, PetXPToLevel = GetPetExperience()
		if PetXPToLevel <= 0 then
			PetXPToLevel = 1
		end

		local petremainXP = PetXPToLevel - PetCurrentXP
		local petremainPercent = petremainXP / PetXPToLevel
		PetRemainTotal, PetRemainBars = petremainPercent * 100, petremainPercent * 20
		PetPercentXP, PetRemainXP = (PetCurrentXP / PetXPToLevel) * 100, K.ShortValue(petremainXP)

		local displayString, textFormat = "", C["DataBars"].Text.Value
		petExpBar:SetMinMaxValues(0, PetXPToLevel)
		petExpBar:SetValue(PetCurrentXP)

		if textFormat == 1 then
			displayString = string_format("%.2f%%", PetPercentXP)
		elseif textFormat == 2 then
			displayString = string_format("%s - %s", K.ShortValue(PetCurrentXP), K.ShortValue(PetXPToLevel))
		elseif textFormat == 3 then
			displayString = string_format("%s - %.2f%%", K.ShortValue(PetCurrentXP), PetPercentXP)
		elseif textFormat == 4 then
			displayString = string_format("%s", K.ShortValue(PetCurrentXP))
		elseif textFormat == 5 then
			displayString = string_format("%s", PetRemainXP)
		elseif textFormat == 6 then
			displayString = string_format("%s - %s", K.ShortValue(PetCurrentXP), PetRemainXP)
		elseif textFormat == 7 then
			displayString = string_format("%s - %.2f%% (%s)", K.ShortValue(PetCurrentXP), PetPercentXP, PetRemainXP)
		end

		petExpBar.Text:SetText(displayString)
	end
end

function Module:UpdateReputation()
	local repBar = self.Bars.Reputation
	local name, reaction, Min, Max, value = GetWatchedFactionInfo()

	if not name then
		repBar:Hide()
		return
	else
		repBar:Show()
	end

	local displayString, textFormat = "", C["DataBars"].Text.Value
	local isCapped, standingLabel
	local color = KKUI_FACTION_BAR_COLORS[reaction] or _G.FACTION_BAR_COLORS[reaction]

	if reaction == _G.MAX_REPUTATION_REACTION then
		Min, Max, value = 0, 1, 1
		isCapped = true
	end

	repBar:SetMinMaxValues(Min, Max)
	repBar:SetValue(value)
	repBar:SetStatusBarColor(color.r, color.g, color.b)

	standingLabel = _G["FACTION_STANDING_LABEL"..reaction]

	-- Prevent a division by zero
	local maxMinDiff = Max - Min
	if maxMinDiff == 0 then
		maxMinDiff = 1
	end

	if isCapped and textFormat ~= 0 then
		-- show only name and standing on exalted
		displayString = string_format("%s: [%s]", name, K.ShortenString(standingLabel, 1, false))
	else
		if textFormat == 1 then
			displayString = string_format("%s: %d%% [%s]", name, ((value - Min) / (maxMinDiff) * 100), standingLabel)
		elseif textFormat == 2 then
			displayString = string_format("%s: %s - %s [%s]", name, K.ShortValue(value - Min), K.ShortValue(Max - Min), standingLabel)
		elseif textFormat == 3 then
			displayString = string_format("%s: %s - %d%% [%s]", name, K.ShortValue(value - Min), ((value - Min) / (maxMinDiff) * 100), standingLabel)
		elseif textFormat == 4 then
			displayString = string_format("%s: %s [%s]", name, K.ShortValue(value - Min), standingLabel)
		elseif textFormat == 5 then
			displayString = string_format("%s: %s [%s]", name, K.ShortValue((Max - Min) - (value-Min)), standingLabel)
		elseif textFormat == 6 then
			displayString = string_format("%s: %s - %s [%s]", name, K.ShortValue(value - Min), K.ShortValue((Max - Min) - (value-Min)), standingLabel)
		elseif textFormat == 7 then
			displayString = string_format("%s: %s - %d%% (%s) [%s]", name, K.ShortValue(value - Min), ((value - Min) / (maxMinDiff) * 100), K.ShortValue((Max - Min) - (value-Min)), standingLabel)
		end
	end

	repBar.Text:SetText(displayString)
end

function Module:OnEnter()
	if GameTooltip:IsForbidden() then
		return
	end

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
	GameTooltip:ClearLines()

	if C["DataBars"].MouseOver then
		UIFrameFadeIn(Module.Container, 0.2, Module.Container:GetAlpha(), 1)
	end

	if not IsPlayerAtEffectiveMaxLevel() then
		GameTooltip:AddLine(L["Experience"])
		GameTooltip:AddDoubleLine(LEVEL, string_format("%s", K.Level), 1, 1, 1)
		GameTooltip:AddDoubleLine(L["XP"], string_format(" %d / %d (%.2f%%)", CurrentXP, XPToLevel, PercentXP), 1, 1, 1)
		GameTooltip:AddDoubleLine(L["Remaining"], string_format(" %s (%.2f%% - %d "..L["Bars"]..")", RemainXP, RemainTotal, RemainBars), 1, 1, 1)

		if RestedXP and RestedXP > 0 then
			GameTooltip:AddDoubleLine(L["Rested"], string_format("+%d (%.2f%%)", RestedXP, PercentRested), 1, 1, 1)
		end
	end

	local _, hunterPet = HasPetUI()
	local showPetInfo = hunterPet and (UnitLevel("pet") ~= 70 and true)
	if showPetInfo and K.Class == "HUNTER" and C["DataBars"].PetExperience then
		if not IsPlayerAtEffectiveMaxLevel() then
			GameTooltip:AddLine(" ")
		end

		GameTooltip:AddLine("Pet Experience")
		GameTooltip:AddDoubleLine(LEVEL, string_format("%s", UnitLevel('pet')), 1, 1, 1)
		GameTooltip:AddDoubleLine(L["XP"], string_format(" %d / %d (%.2f%%)", PetCurrentXP, PetXPToLevel, PetPercentXP), 1, 1, 1)
		GameTooltip:AddDoubleLine(L["Remaining"], string_format(" %s (%.2f%% - %d "..L["Bars"]..")", PetRemainXP, PetRemainTotal, PetRemainBars), 1, 1, 1)
	end

	if GetWatchedFactionInfo() then
		if not IsPlayerAtEffectiveMaxLevel() then
			GameTooltip:AddLine(" ")
		end

		local name, reaction, min, max, value = GetWatchedFactionInfo()

		if name then
			local color = FACTION_BAR_COLORS[reaction] or backupColor
			GameTooltip:AddLine(name, color.r, color.g, color.b)
			_G.GameTooltip:AddDoubleLine(STANDING..":", _G["FACTION_STANDING_LABEL"..reaction], 1, 1, 1)
			if reaction ~= _G.MAX_REPUTATION_REACTION then
				_G.GameTooltip:AddDoubleLine(REPUTATION..":", string_format("%d / %d (%d%%)", value - min, max - min, (value - min) / ((max - min == 0) and max or (max - min)) * 100), 1, 1, 1)
			end
			_G.GameTooltip:Show()
		end
	end

	GameTooltip:Show()
end

function Module:OnLeave()
	if C["DataBars"].MouseOver then
		UIFrameFadeOut(Module.Container, 0.2, Module.Container:GetAlpha(), 0)
	end

	GameTooltip:Hide()
end

function Module:OnUpdate()
	Module:UpdateExperience()
	Module:UpdatePetExperience()
	Module:UpdateReputation()

	if C["DataBars"].MouseOver then
		Module.Container:SetAlpha(0)
	else
		Module.Container:SetAlpha(1)
	end

	local num_bars = 0
	local prev
	for _, bar in pairs(Module.Bars) do
		if bar:IsShown() then
			num_bars = num_bars + 1

			bar:ClearAllPoints()
			if prev then
				bar:SetPoint("TOP", prev, "BOTTOM", 0, -6)
			else
				bar:SetPoint("TOP", Module.Container)
			end
			prev = bar
		end
	end

	Module.Container:SetHeight(num_bars * (C["DataBars"].Height + 6) - 6)
end

function Module:UpdateDataBarsSize()
	KKUI_ExperienceBar:SetSize(C["DataBars"].Width, C["DataBars"].Height)
	KKUI_PetExperienceBar:SetSize(C["DataBars"].Width, C["DataBars"].Height)
	KKUI_ReputationBar:SetSize(C["DataBars"].Width, C["DataBars"].Height)

	local num_bars = 0
	for _, bar in pairs(Module.Bars) do
		if bar:IsShown() then
			num_bars = num_bars + 1
		end
	end

	Module.Container:SetSize(C["DataBars"].Width, num_bars * (C["DataBars"].Height + 6) - 6)
	self.Container.mover:SetSize(C["DataBars"].Width, self.Container:GetHeight())
end

function Module:OnEnable()
	self.DatabaseTexture = K.GetTexture(C["UITextures"].DataBarsTexture)
	self.DatabaseFont = K.GetFont(C["UIFonts"].DataBarsFonts)

	if not C["DataBars"].Enable then
		return
	end

	self.Bars = {}

	self.Container = CreateFrame("button", "KKUI_Databars", K.PetBattleHider)
	self.Container:SetWidth(C["DataBars"].Width)
	self.Container:SetPoint("TOP", "Minimap", "BOTTOM", 0, -6)
	self.Container:HookScript("OnEnter", self.OnEnter)
	self.Container:HookScript("OnLeave", self.OnLeave)

	self:SetupExperience()
	self:SetupPetExperience()
	self:SetupReputation()
	self:OnUpdate()

	K:RegisterEvent("COMBAT_TEXT_UPDATE", self.OnUpdate)
	K:RegisterEvent("DISABLE_XP_GAIN", self.OnUpdate)
	K:RegisterEvent("ENABLE_XP_GAIN", self.OnUpdate)
	K:RegisterEvent("PLAYER_ENTERING_WORLD", self.OnUpdate)
	K:RegisterEvent("PLAYER_LEVEL_UP", self.OnUpdate)
	K:RegisterEvent("PLAYER_XP_UPDATE", self.OnUpdate)
	K:RegisterEvent("UNIT_INVENTORY_CHANGED", self.OnUpdate)
	K:RegisterEvent("UNIT_PET", self.OnUpdate)
	K:RegisterEvent("UNIT_PET_EXPERIENCE", self.OnUpdate)
	K:RegisterEvent("UPDATE_EXHAUSTION", self.OnUpdate)
	K:RegisterEvent("UPDATE_FACTION", self.OnUpdate)

	if not self.Container.mover then
		self.Container.mover = K.Mover(self.Container, "DataBars", "DataBars", {"TOP", "Minimap", "BOTTOM", 0, -6})
	else
		self.Container.mover:SetSize(C["DataBars"].Width, self.Container:GetHeight())
	end
end