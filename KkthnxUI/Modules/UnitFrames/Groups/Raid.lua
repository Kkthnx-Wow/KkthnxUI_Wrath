local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")

local _G = _G
local select = _G.select

local CreateFrame = _G.CreateFrame
local GetThreatStatusColor = _G.GetThreatStatusColor
local UnitIsUnit = _G.UnitIsUnit
local UnitPowerType = _G.UnitPowerType
local UnitThreatSituation = _G.UnitThreatSituation

local function UpdateRaidThreat(self, _, unit)
	if unit ~= self.unit then
		return
	end

	local situation = UnitThreatSituation(unit)
	if (situation and situation > 0) then
		local r, g, b = GetThreatStatusColor(situation)
		self.KKUI_Border:SetVertexColor(r, g, b)
	else
		self.KKUI_Border:SetVertexColor(1, 1, 1)
	end
end

local function UpdateRaidPower(self, _, unit)
	if self.unit ~= unit then
		return
	end

	local _, powerToken = UnitPowerType(unit)

	if powerToken == "MANA" and C["Raid"].ManabarShow then
		if not self.Power:IsVisible() then
			self.Health:ClearAllPoints()
			self.Health:SetPoint("BOTTOMLEFT", self, 0, 6)
			self.Health:SetPoint("TOPRIGHT", self)

			self.Power:Show()
		end
	else
		if self.Power:IsVisible() then
			self.Health:ClearAllPoints()
			self.Health:SetAllPoints(self)
			self.Power:Hide()
		end
	end
end

function Module:CreateRaid()
	local RaidframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local RaidframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)
	local HealPredictionTexture = K.GetTexture(C["UITextures"].HealPredictionTextures)

	Module.CreateHeader(self)

	self:CreateBorder()

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetFrameLevel(self:GetFrameLevel())
	self.Health:SetAllPoints(self)
	self.Health:SetStatusBarTexture(RaidframeTexture)

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetPoint("CENTER", self.Health, 0, -9)
	self.Health.Value:SetFontObject(RaidframeFont)
	self.Health.Value:SetFont(select(1, self.Health.Value:GetFont()), 11, select(3, self.Health.Value:GetFont()))
	self:Tag(self.Health.Value, "[raidhp]")

	self.Health.colorDisconnected = true
	self.Health.frequentUpdates = true

	if C["Raid"].HealthbarColor.Value == "Value" then
		self.Health.colorSmooth = true
		self.Health.colorClass = false
		self.Health.colorReaction = false
	elseif C["Raid"].HealthbarColor.Value == "Dark" then
		self.Health.colorSmooth = false
		self.Health.colorClass = false
		self.Health.colorReaction = false
		self.Health:SetStatusBarColor(0.31, 0.31, 0.31)
	else
		self.Health.colorSmooth = false
		self.Health.colorClass = true
		self.Health.colorReaction = true
	end

	if C["Raid"].Smooth then
		K:SmoothBar(self.Health)
	end

	if C["Raid"].ManabarShow then
		self.Power = CreateFrame("StatusBar", nil, self)
		self.Power:SetFrameStrata("LOW")
		self.Power:SetFrameLevel(self:GetFrameLevel())
		self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -1)
		self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -1)
		self.Power:SetHeight(5.5)
		self.Power:SetStatusBarTexture(RaidframeTexture)

		self.Power.colorPower = true
		self.Power.frequentUpdates = false

		if C["Raid"].Smooth then
			K:SmoothBar(self.Power)
		end

		self.Power.Background = self.Power:CreateTexture(nil, "BORDER")
		self.Power.Background:SetAllPoints(self.Power)
		self.Power.Background:SetColorTexture(.2, .2, .2)
		self.Power.Background.multiplier = 0.3

		table.insert(self.__elements, UpdateRaidPower)
		self:RegisterEvent("UNIT_DISPLAYPOWER", UpdateRaidPower)
		UpdateRaidPower(self)
	end

	if C["Raid"].ShowHealPrediction then
		local myBar = CreateFrame("StatusBar", nil, self)
		myBar:SetWidth(self:GetWidth())
		myBar:SetPoint("TOP", self.Health, "TOP")
		myBar:SetPoint("BOTTOM", self.Health, "BOTTOM")
		myBar:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
		myBar:SetStatusBarTexture(HealPredictionTexture)
		myBar:SetStatusBarColor(0, 1, 0.5, 0.25)
		myBar:Hide()

		local otherBar = CreateFrame("StatusBar", nil, self)
		otherBar:SetWidth(self:GetWidth())
		otherBar:SetPoint("TOP", self.Health, "TOP")
		otherBar:SetPoint("BOTTOM", self.Health, "BOTTOM")
		otherBar:SetPoint("LEFT", myBar:GetStatusBarTexture(), "RIGHT")
		otherBar:SetStatusBarTexture(HealPredictionTexture)
		otherBar:SetStatusBarColor(0, 1, 0, 0.25)
		otherBar:Hide()

		self.HealthPrediction = {
			myBar = myBar,
			otherBar = otherBar,
			maxOverflow = 1,
		}
	end

	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -15)
	self.Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -15)
	self.Name:SetFontObject(RaidframeFont)
	self.Name:SetWordWrap(false)
	self:Tag(self.Name, "[name]")

	self.Overlay = CreateFrame("Frame", nil, self)
	self.Overlay:SetAllPoints(self.Health)
	self.Overlay:SetFrameLevel(self:GetFrameLevel() + 4)

	self.ReadyCheckIndicator = self.Overlay:CreateTexture(nil, "OVERLAY", 2)
	self.ReadyCheckIndicator:SetSize(22, 22)
	self.ReadyCheckIndicator:SetPoint("CENTER")

	self.PhaseIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.PhaseIndicator:SetSize(20, 20)
	self.PhaseIndicator:SetPoint("CENTER")
	self.PhaseIndicator:SetTexture([[Interface\AddOns\KkthnxUI\Media\Textures\PhaseIcons.tga]])
	self.PhaseIndicator.PostUpdate = Module.UpdatePhaseIcon

	self.SummonIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.SummonIndicator:SetSize(20, 20)
	self.SummonIndicator:SetPoint("CENTER", self.Overlay)

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetSize(16, 16)
	self.RaidTargetIndicator:SetPoint("TOP", self, 0, 8)

	self.ResurrectIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.ResurrectIndicator:SetSize(30, 30)
	self.ResurrectIndicator:SetPoint("CENTER", 0, -3)

	self.LeaderIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.LeaderIndicator:SetPoint("TOPLEFT", self.Health, 0, 8)
	self.LeaderIndicator:SetSize(12, 12)

	self.AssistantIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.AssistantIndicator:SetPoint("TOPLEFT", self.Health, 0, 8)
	self.AssistantIndicator:SetSize(12, 12)

	self.MasterLooterIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.MasterLooterIndicator:SetPoint("TOPRIGHT", self.Health, 0, 8)
	self.MasterLooterIndicator:SetSize(12, 12)

	if C["Raid"].ShowNotHereTimer then
		-- self.StatusIndicator = self:CreateFontString(nil, "OVERLAY")
		-- self.StatusIndicator:SetPoint("CENTER", self.Overlay, "BOTTOM", 0, 6)
		-- self.StatusIndicator:SetFontObject(RaidframeFont)
		-- self.StatusIndicator:SetFont(select(1, self.StatusIndicator:GetFont()), 10, select(3, self.StatusIndicator:GetFont()))
		-- self.StatusIndicator:SetTextColor(1, 0, 0)
		-- self:Tag(self.StatusIndicator, "")
	end

	if C["Raid"].RaidBuffsStyle.Value == "Aura Track" then
		self.AuraTrack = self.AuraTrack or CreateFrame("Frame", nil, self.Health)
		self.AuraTrack:SetPoint("TOPLEFT", self.Health ,"TOPLEFT", -4, -6)
		self.AuraTrack:SetPoint("BOTTOMRIGHT", self.Health ,"BOTTOMRIGHT", 4, 6)
		self.AuraTrack.Texture = RaidframeTexture
		self.AuraTrack.Icons = C["Raid"].AuraTrackIcons
		self.AuraTrack.SpellTextures = C["Raid"].AuraTrackSpellTextures
		self.AuraTrack.Thickness = C["Raid"].AuraTrackThickness
		self.AuraTrack.Font = C["Media"].Fonts.KkthnxUIFont
	elseif C["Raid"].RaidBuffsStyle.Value == "Standard" then
		local filter = C["Raid"].RaidBuffs.Value == "All" and "HELPFUL" or "HELPFUL|RAID"
		local onlyShowPlayer = C["Raid"].RaidBuffs.Value == "Self"

		self.Buffs = self.Buffs or CreateFrame("Frame", self:GetName().."Buffs", self.Health)
		self.Buffs:SetPoint("TOPLEFT", self.Health, "TOPLEFT", 0, 0)
		self.Buffs:SetHeight(16)
		self.Buffs:SetWidth(79)
		self.Buffs.size = 16
		self.Buffs.num = 5
		self.Buffs.numRow = 1
		self.Buffs.spacing = 0
		self.Buffs.initialAnchor = "TOPLEFT"
		self.Buffs.disableCooldown = true
		self.Buffs.disableMouse = true
		self.Buffs.onlyShowPlayer = onlyShowPlayer
		self.Buffs.filter = filter
		self.Buffs.IsRaid = true
		self.Buffs.PostCreateIcon = Module.PostCreateAura
		self.Buffs.PostUpdateIcon = Module.PostUpdateAura
	end

	if C["Raid"].DebuffWatch then
		local Height = C["Raid"].Height
		local DebuffSize = Height >= 32 and Height - 20 or Height

		self.RaidDebuffs = self.RaidDebuffs or CreateFrame("Frame", nil, self.Health)
		self.RaidDebuffs:SetHeight(DebuffSize)
		self.RaidDebuffs:SetWidth(DebuffSize)
		self.RaidDebuffs:SetPoint("CENTER", self.Health)
		self.RaidDebuffs:SetFrameLevel(self.Health:GetFrameLevel() + 10)
		self.RaidDebuffs:CreateBorder()

		self.RaidDebuffs.icon = self.RaidDebuffs:CreateTexture(nil, "ARTWORK")
		self.RaidDebuffs.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		self.RaidDebuffs.icon:SetAllPoints(self.RaidDebuffs)

		self.RaidDebuffs.cd = CreateFrame("Cooldown", nil, self.RaidDebuffs, "CooldownFrameTemplate")
		self.RaidDebuffs.cd:SetAllPoints(self.RaidDebuffs)
		self.RaidDebuffs.cd:SetReverse(true)
		self.RaidDebuffs.cd.noOCC = true
		self.RaidDebuffs.cd.noCooldownCount = true
		self.RaidDebuffs.cd:SetHideCountdownNumbers(true)
		self.RaidDebuffs.cd:SetAlpha(0.7)

		self.RaidDebuffs.onlyMatchSpellID = true
		self.RaidDebuffs.showDispellableDebuff = true

		self.RaidDebuffs.time = self.RaidDebuffs:CreateFontString(nil, "OVERLAY")
		self.RaidDebuffs.time:SetFont(C["Media"].Fonts.KkthnxUIFont, 12, "OUTLINE")
		self.RaidDebuffs.time:SetPoint("CENTER", self.RaidDebuffs, 1, 0)

		self.RaidDebuffs.count = self.RaidDebuffs:CreateFontString(nil, "OVERLAY")
		self.RaidDebuffs.count:SetFont(C["Media"].Fonts.KkthnxUIFont, 12, "OUTLINE")
		self.RaidDebuffs.count:SetPoint("BOTTOMRIGHT", self.RaidDebuffs, "BOTTOMRIGHT", 2, 0)
		self.RaidDebuffs.count:SetTextColor(1, 0.9, 0)

		-- RaidDebuffs.forceShow = true
	end

	if C["Raid"].TargetHighlight then
		self.TargetHighlight = self.TargetHighlight or CreateFrame("Frame", nil, self.Overlay, "BackdropTemplate")
		self.TargetHighlight:SetFrameLevel(6)
		self.TargetHighlight:SetBackdrop({edgeFile = C["Media"].Borders.GlowBorder, edgeSize = 12})
		self.TargetHighlight:SetPoint("TOPLEFT", self, -5, 5)
		self.TargetHighlight:SetPoint("BOTTOMRIGHT", self, 5, -5)
		self.TargetHighlight:SetBackdropBorderColor(1, 1, 0)
		self.TargetHighlight:Hide()

		local function UpdateRaidTargetGlow()
			if UnitIsUnit("target", self.unit) then
				self.TargetHighlight:Show()
			else
				self.TargetHighlight:Hide()
			end
		end

		self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateRaidTargetGlow, true)
		self:RegisterEvent("GROUP_ROSTER_UPDATE", UpdateRaidTargetGlow, true)
	end

	self.DebuffHighlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.DebuffHighlight:SetAllPoints(self.Health)
	self.DebuffHighlight:SetTexture(C["Media"].Textures.BlankTexture)
	self.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
	self.DebuffHighlight:SetBlendMode("ADD")

	self.DebuffHighlightAlpha = 0.45
	self.DebuffHighlightFilter = true

	self.Highlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.Highlight:SetAllPoints()
	self.Highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	self.Highlight:SetTexCoord(0, 1, 0.5, 1)
	self.Highlight:SetVertexColor(0.6, 0.6, 0.6)
	self.Highlight:SetBlendMode("ADD")
	self.Highlight:Hide()

	self.ThreatIndicator = {
		IsObjectType = function() end,
		Override = UpdateRaidThreat,
	}

	self.Range = Module.CreateRangeIndicator(self)
end