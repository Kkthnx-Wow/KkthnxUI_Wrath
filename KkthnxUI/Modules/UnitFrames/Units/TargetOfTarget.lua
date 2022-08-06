local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")

local _G = _G

local CreateFrame = _G.CreateFrame

function Module:CreateTargetOfTarget()
	local UnitframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local UnitframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)

	self.Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	self.Overlay:SetAllPoints()
	self.Overlay:SetFrameLevel(5)

	Module.CreateHeader(self)

	self.Health = CreateFrame("StatusBar", nil, self)
	if C["Unitframe"].TargetTargetPower then
		self.Health:SetHeight(C["Unitframe"].TargetTargetFrameHeight * 0.7)
	else
		self.Health:SetHeight(C["Unitframe"].TargetTargetFrameHeight + 6)
	end
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

	self.Health.PostUpdate = C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits" and Module.UpdateHealth
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.frequentUpdates = true

	if C["Unitframe"].HealthbarColor.Value == "Value" then
		self.Health.colorSmooth = true
		self.Health.colorClass = false
		self.Health.colorReaction = false
	elseif C["Unitframe"].HealthbarColor.Value == "Dark" then
		self.Health.colorSmooth = false
		self.Health.colorClass = false
		self.Health.colorReaction = false
		self.Health:SetStatusBarColor(0.31, 0.31, 0.31)
	else
		self.Health.colorSmooth = false
		self.Health.colorClass = true
		self.Health.colorReaction = true
	end

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self.Health.Value:SetFontObject(UnitframeFont)
	self.Health.Value:SetFont(select(1, self.Health.Value:GetFont()), 10, select(3, self.Health.Value:GetFont()))
	self:Tag(self.Health.Value, "[hp]")

	self.Power = CreateFrame("StatusBar", nil, self)
	if C["Unitframe"].TargetTargetPower then
		self.Power:SetHeight(C["Unitframe"].TargetTargetFrameHeight * 0.4)
	else
		self.Power:SetHeight(0)
	end
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.frequentUpdates = false

	self.Name = self:CreateFontString(nil, "OVERLAY")
	if C["Unitframe"].TargetTargetPower then
		self.Name:SetPoint("BOTTOM", self.Power, 0, -16)
	else
		self.Name:SetPoint("BOTTOM", self.Health, 0, -16)
	end
	self.Name:SetWidth(81 * 0.96)
	self.Name:SetFontObject(UnitframeFont)
	self.Name:SetWordWrap(false)
	if C["Unitframe"].HealthbarColor.Value == "Class" then
		self:Tag(self.Name, "[name]")
	else
		self:Tag(self.Name, "[color][name]")
	end
	self.Name:SetShown(not C["Unitframe"].HideTargetOfTargetName)

	local portraitSize
	if C["Unitframe"].TargetTargetPower and C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
		portraitSize = self.Health:GetHeight() + self.Power:GetHeight() + 6
	else
		portraitSize = self.Health:GetHeight() + self.Power:GetHeight()
	end

	if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
		if C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits" then
			self.Portrait = CreateFrame("PlayerModel", "KKUI_TargetTargetPortrait", self.Health)
			self.Portrait:SetFrameStrata(self:GetFrameStrata())
			self.Portrait:SetSize(portraitSize, portraitSize)
			self.Portrait:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, 0)
			self.Portrait:CreateBorder()
		elseif C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits" then
			self.Portrait = self.Health:CreateTexture("KKUI_TargetTargetPortrait", "BACKGROUND", nil, 1)
			self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
			self.Portrait:SetSize(portraitSize, portraitSize)
			self.Portrait:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, 0)

			self.Portrait.Border = CreateFrame("Frame", nil, self)
			self.Portrait.Border:SetAllPoints(self.Portrait)
			self.Portrait.Border:CreateBorder()

			if (C["Unitframe"].PortraitStyle.Value == "ClassPortraits" or C["Unitframe"].PortraitStyle.Value == "NewClassPortraits") then
				self.Portrait.PostUpdate = Module.UpdateClassPortraits
			end
		end
	end

	self.Level = self:CreateFontString(nil, "OVERLAY")
	if C["Unitframe"].PortraitStyle.Value == "NoPortraits" then
		if C["Unitframe"].TargetTargetPower then
			self.Level:SetPoint("BOTTOMRIGHT", self.Power, 0, -16)
		else
			self.Level:SetPoint("BOTTOMRIGHT", self.Health, 0, -16)
		end
	else
		self.Level:SetPoint("BOTTOM", self.Portrait, 0, -16)
	end
	self.Level:SetFontObject(UnitframeFont)
	self:Tag(self.Level, "[fulllevel]")
	self.Level:SetShown(not C["Unitframe"].HideTargetOfTargetLevel)

	self.Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)
	self.Debuffs:SetWidth(82)
	self.Debuffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, C["Unitframe"].HideTargetOfTargetName and C["Unitframe"].HideTargetOfTargetLevel and -6 or -20)
	self.Debuffs.num = 4 * 4
	self.Debuffs.spacing = 6
	self.Debuffs.size = ((((self.Debuffs:GetWidth() - (self.Debuffs.spacing * (self.Debuffs.num / 4 - 1))) / self.Debuffs.num)) * 4)
	self.Debuffs:SetHeight(self.Debuffs.size * 4)
	self.Debuffs.initialAnchor = "TOPLEFT"
	self.Debuffs["growth-y"] = "DOWN"
	self.Debuffs["growth-x"] = "RIGHT"
	self.Debuffs.CustomFilter = Module.CustomFilter
	self.Debuffs.PostCreateIcon = Module.PostCreateAura
	self.Debuffs.PostUpdateIcon = Module.PostUpdateAura

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
		self.RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
	else
		self.RaidTargetIndicator:SetPoint("TOP", self.Health, "TOP", 0, 8)
	end
	self.RaidTargetIndicator:SetSize(12, 12)

	self.Highlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.Highlight:SetAllPoints()
	self.Highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	self.Highlight:SetTexCoord(0, 1, .5, 1)
	self.Highlight:SetVertexColor(.6, .6, .6)
	self.Highlight:SetBlendMode("ADD")
	self.Highlight:Hide()

	self.ThreatIndicator = {
		IsObjectType = K.Noop,
		Override = Module.UpdateThreat,
	}

	self.Range = Module.CreateRangeIndicator(self)
end