local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")

local _G = _G
local select = _G.select
local math_floor = _G.math.floor

local CreateFrame = _G.CreateFrame
local UnitIsUnit = _G.UnitIsUnit

function Module:CreateParty()
	self.mystyle = "party"

	local UnitframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local UnitframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)
	local HealPredictionTexture = K.GetTexture(C["UITextures"].HealPredictionTextures)

	self.Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	self.Overlay:SetAllPoints()
	self.Overlay:SetFrameLevel(6)

	Module.CreateHeader(self)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetHeight(18)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

	self.Health.PostUpdate = C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits" and Module.UpdateHealth
	self.Health.colorDisconnected = true
	self.Health.frequentUpdates = true

	if C["Party"].HealthbarColor.Value == "Value" then
		self.Health.colorSmooth = true
		self.Health.colorClass = false
		self.Health.colorReaction = false
	elseif C["Party"].HealthbarColor.Value == "Dark" then
		self.Health.colorSmooth = false
		self.Health.colorClass = false
		self.Health.colorReaction = false
		self.Health:SetStatusBarColor(0.31, 0.31, 0.31)
	else
		self.Health.colorSmooth = false
		self.Health.colorClass = true
		self.Health.colorReaction = true
	end

	if C["Party"].Smooth then
		K:SmoothBar(self.Health)
	end

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self.Health.Value:SetFontObject(UnitframeFont)
	self.Health.Value:SetFont(select(1, self.Health.Value:GetFont()), 10, select(3, self.Health.Value:GetFont()))
	self:Tag(self.Health.Value, "[hp]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetHeight(10)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.SetFrequentUpdates = true

	if C["Party"].Smooth then
		K:SmoothBar(self.Power)
	end

	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("TOP", self.Health, 0, 16)
	self.Name:SetWidth(124)
	self.Name:SetFontObject(UnitframeFont)
	self.Name:SetWordWrap(false)
	if C["Party"].HealthbarColor.Value == "Class" then
		self:Tag(self.Name, "[name]")
	else
		self:Tag(self.Name, "[color][name]")
	end

	if C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits" then
		self.Portrait = CreateFrame("PlayerModel", "KKUI_PartyPortrait", self.Health)
		self.Portrait:SetFrameStrata(self:GetFrameStrata())
		self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
		self.Portrait:SetPoint("TOPLEFT", self, "TOPLEFT", 0 ,0)
		self.Portrait:CreateBorder()
	elseif C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits" then
		self.Portrait = self.Health:CreateTexture("KKUI_PartyPortrait", "BACKGROUND", nil, 1)
		self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
		self.Portrait:SetPoint("TOPLEFT", self, "TOPLEFT", 0 ,0)

		self.Portrait.Border = CreateFrame("Frame", nil, self)
		self.Portrait.Border:SetAllPoints(self.Portrait)
		self.Portrait.Border:CreateBorder()

		if (C["Unitframe"].PortraitStyle.Value == "ClassPortraits" or C["Unitframe"].PortraitStyle.Value == "NewClassPortraits") then
			self.Portrait.PostUpdate = Module.UpdateClassPortraits
		end
	end

	self.Health:ClearAllPoints()
	self.Health:SetPoint("TOPLEFT", self.Portrait:GetWidth() + 6, 0)
	self.Health:SetPoint("TOPRIGHT")

	self.Level = self:CreateFontString(nil, "OVERLAY")
	self.Level:SetPoint("TOP", self.Portrait, 0, 15)
	self.Level:SetFontObject(UnitframeFont)
	self:Tag(self.Level, "[nplevel]")

	local aurasSetWidth = 124
	if C["Party"].ShowBuffs then
		self.Buffs = CreateFrame("Frame", self:GetName().."Buffs", self)
		self.Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		self.Buffs.initialAnchor = "TOPLEFT"
		self.Buffs["growth-x"] = "RIGHT"
		self.Buffs["growth-y"] = "DOWN"
		self.Buffs.num = 6
		self.Buffs.spacing = 6
		self.Buffs.iconsPerRow = 6
		self.Buffs.onlyShowPlayer = false
		self.Buffs.size = Module.auraIconSize(aurasSetWidth, self.Buffs.iconsPerRow, self.Buffs.spacing)
		self.Buffs:SetWidth(aurasSetWidth)
		self.Buffs:SetHeight((self.Buffs.size + self.Buffs.spacing) * math_floor(self.Buffs.num / self.Buffs.iconsPerRow + 0.5))
		self.Buffs.CustomFilter = Module.CustomFilter
		self.Buffs.showStealableBuffs = true
		self.Buffs.PostCreateIcon = Module.PostCreateAura
		self.Buffs.PostUpdateIcon = Module.PostUpdateAura
	end

	self.Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)
	self.Debuffs.spacing = 6
	self.Debuffs.initialAnchor = "LEFT"
	self.Debuffs["growth-x"] = "RIGHT"
	self.Debuffs["growth-y"] = "DOWN"
	self.Debuffs:SetPoint("LEFT", self.Health, "RIGHT", 6, 0)
	self.Debuffs.num = 5
	self.Debuffs.iconsPerRow = 5
	self.Debuffs.size = Module.auraIconSize(aurasSetWidth, self.Debuffs.iconsPerRow, self.Debuffs.spacing + 2.5)
	self.Debuffs:SetWidth(aurasSetWidth)
	self.Debuffs:SetHeight((self.Debuffs.size + self.Debuffs.spacing) * math_floor(self.Debuffs.num/self.Debuffs.iconsPerRow + 0.5))
	self.Debuffs.CustomFilter = Module.CustomFilter
	self.Debuffs.PostCreateIcon = Module.PostCreateAura
	self.Debuffs.PostUpdateIcon = Module.PostUpdateAura

	if (C["Party"].Castbars) then
		self.Castbar = CreateFrame("StatusBar", "PartyCastbar", self)
		self.Castbar:SetStatusBarTexture(UnitframeTexture)
		self.Castbar:SetClampedToScreen(true)
		self.Castbar:CreateBorder()

		self.Castbar:ClearAllPoints()
		self.Castbar:SetPoint("TOPLEFT", 22, 22)
		self.Castbar:SetPoint("TOPRIGHT", 0, 22)
		self.Castbar:SetHeight(16)

		self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.Spark:SetTexture(C["Media"].Textures.Spark128Texture)
		self.Castbar.Spark:SetSize(128, self.Castbar:GetHeight())
		self.Castbar.Spark:SetBlendMode("ADD")

		self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY", UnitframeFont)
		self.Castbar.Time:SetFont(select(1, self.Castbar.Time:GetFont()), 11, select(3, self.Castbar.Time:GetFont()))
		self.Castbar.Time:SetPoint("RIGHT", -3.5, 0)
		self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)
		self.Castbar.Time:SetJustifyH("RIGHT")

		self.Castbar.decimal = "%.2f"

		self.Castbar.OnUpdate = Module.OnCastbarUpdate
		self.Castbar.PostCastStart = Module.PostCastStart
		self.Castbar.PostChannelStart = Module.PostCastStart
		self.Castbar.PostCastStop = Module.PostCastStop
		self.Castbar.PostChannelStop = Module.PostChannelStop
		self.Castbar.PostCastDelayed = Module.PostCastUpdate
		self.Castbar.PostChannelUpdate = Module.PostCastUpdate
		self.Castbar.PostCastFailed = Module.PostCastFailed
		self.Castbar.PostCastInterrupted = Module.PostCastFailed
		self.Castbar.PostCastInterruptible = Module.PostUpdateInterruptible
		self.Castbar.PostCastNotInterruptible = Module.PostUpdateInterruptible

		self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY", UnitframeFont)
		self.Castbar.Text:SetFont(select(1, self.Castbar.Text:GetFont()), 11, select(3, self.Castbar.Text:GetFont()))
		self.Castbar.Text:SetPoint("LEFT", 3.5, 0)
		self.Castbar.Text:SetPoint("RIGHT", self.Castbar.Time, "LEFT", -3.5, 0)
		self.Castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		self.Castbar.Text:SetJustifyH("LEFT")
		self.Castbar.Text:SetWordWrap(false)

		self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
		self.Castbar.Button:SetSize(16, 16)
		self.Castbar.Button:CreateBorder()

		self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
		self.Castbar.Icon:SetSize(self.Castbar:GetHeight(), self.Castbar:GetHeight())
		self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		self.Castbar.Icon:SetPoint("RIGHT", self.Castbar, "LEFT", -6, 0)

		self.Castbar.Button:SetAllPoints(self.Castbar.Icon)
	end

	if C["Party"].ShowHealPrediction then
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

	self.StatusIndicator = self.Power:CreateFontString(nil, "OVERLAY")
	self.StatusIndicator:SetPoint("CENTER", 0, 0.5)
	self.StatusIndicator:SetFontObject(UnitframeFont)
	self.StatusIndicator:SetFont(select(1, self.StatusIndicator:GetFont()), 10, select(3, self.StatusIndicator:GetFont()))
	self:Tag(self.StatusIndicator, "[afkdnd]")

	if (C["Party"].TargetHighlight) then
		self.TargetHighlight = self.TargetHighlight or CreateFrame("Frame", nil, self.Overlay, "BackdropTemplate")
		self.TargetHighlight:SetFrameLevel(6)
		self.TargetHighlight:SetBackdrop({edgeFile = C["Media"].Borders.GlowBorder, edgeSize = 12})
		self.TargetHighlight:SetPoint("TOPLEFT", self.Portrait, -5, 5)
		self.TargetHighlight:SetPoint("BOTTOMRIGHT", self.Portrait, 5, -5)
		self.TargetHighlight:SetBackdropBorderColor(1, 1, 0, 0.8)
		self.TargetHighlight:Hide()

		local function UpdatePartyTargetGlow()
			if UnitIsUnit("target", self.unit) then
				self.TargetHighlight:Show()
			else
				self.TargetHighlight:Hide()
			end
		end

		self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdatePartyTargetGlow, true)
		self:RegisterEvent("GROUP_ROSTER_UPDATE", UpdatePartyTargetGlow, true)
	end

	self.LeaderIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.LeaderIndicator:SetPoint("TOPLEFT", self.Portrait, 0, 8)
	self.LeaderIndicator:SetSize(12, 12)

	self.AssistantIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.AssistantIndicator:SetPoint("TOPLEFT", self.Portrait, 0, 8)
	self.AssistantIndicator:SetSize(12, 12)

	self.MasterLooterIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.MasterLooterIndicator:SetPoint("TOPRIGHT", self.Portrait, 0, 8)
	self.MasterLooterIndicator:SetSize(12, 12)

	self.ReadyCheckIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.ReadyCheckIndicator:SetSize(20, 20)
	self.ReadyCheckIndicator:SetPoint("LEFT", 0, 0)

	self.PhaseIndicator = self:CreateTexture(nil, "OVERLAY")
	self.PhaseIndicator:SetSize(20, 20)
	self.PhaseIndicator:SetPoint("LEFT", self.Health, "RIGHT", 4, 0)
	self.PhaseIndicator:SetTexture([[Interface\AddOns\KkthnxUI\Media\Textures\PhaseIcons.tga]])
	self.PhaseIndicator.PostUpdate = Module.UpdatePhaseIcon

	self.SummonIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.SummonIndicator:SetSize(40, 40)
	self.SummonIndicator:SetPoint("CENTER", self.Portrait)

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
	self.RaidTargetIndicator:SetSize(14, 14)

	self.ResurrectIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.ResurrectIndicator:SetSize(28, 28)
	self.ResurrectIndicator:SetPoint("CENTER", self.Portrait)

	if C["Unitframe"].DebuffHighlight then
		self.DebuffHighlight = self.Health:CreateTexture(nil, "OVERLAY")
		self.DebuffHighlight:SetAllPoints(self.Health)
		self.DebuffHighlight:SetTexture(C["Media"].Textures.BlankTexture)
		self.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
		self.DebuffHighlight:SetBlendMode("ADD")

		self.DebuffHighlightAlpha = 0.45
		self.DebuffHighlightFilter = true
	end

	self.Highlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.Highlight:SetAllPoints()
	self.Highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	self.Highlight:SetTexCoord(0, 1, .5, 1)
	self.Highlight:SetVertexColor(.6, .6, .6)
	self.Highlight:SetBlendMode("ADD")
	self.Highlight:Hide()

	local altPower = K.CreateFontString(self, 10, "")
	altPower:SetPoint("LEFT", self.Power, "RIGHT", 6, 0)
	self:Tag(altPower, "[altpower]")
	altPower:Show()

	self.ThreatIndicator = {
		IsObjectType = K.Noop,
		Override = Module.UpdateThreat,
	}

	self.Range = Module.CreateRangeIndicator(self)
end