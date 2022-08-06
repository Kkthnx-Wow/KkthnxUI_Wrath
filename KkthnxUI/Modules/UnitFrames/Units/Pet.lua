local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")

local _G = _G

local CreateFrame = _G.CreateFrame

function Module:CreatePet()
	self.mystyle = "pet"
	local UnitframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local UnitframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)

	self.Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	self.Overlay:SetAllPoints()
	self.Overlay:SetFrameLevel(5)

	Module.CreateHeader(self)

	self.Health = CreateFrame("StatusBar", nil, self)
	if C["Unitframe"].PetPower then
		self.Health:SetHeight(C["Unitframe"].PetFrameHeight * 0.7)
	else
		self.Health:SetHeight(C["Unitframe"].PetFrameHeight + 6)
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
	if C["Unitframe"].PetPower then
		self.Power:SetHeight(C["Unitframe"].PetFrameHeight * 0.4)
	else
		self.Power:SetHeight(0)
	end
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.frequentUpdates = false

	local portraitSize
	if C["Unitframe"].PetPower and C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
		portraitSize = self.Health:GetHeight() + self.Power:GetHeight() + 6
	else
		portraitSize = self.Health:GetHeight() + self.Power:GetHeight()
	end

	if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
		if C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits" then
			self.Portrait = CreateFrame("PlayerModel", "KKUI_PetPortrait", self.Health)
			self.Portrait:SetFrameStrata(self:GetFrameStrata())
			self.Portrait:SetSize(portraitSize, portraitSize)
			self.Portrait:SetPoint("TOPRIGHT", self, "TOPLEFT", -6 ,0)
			self.Portrait:CreateBorder()
		elseif C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits" then
			self.Portrait = self.Health:CreateTexture("KKUI_PetPortrait", "BACKGROUND", nil, 1)
			self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
			self.Portrait:SetSize(portraitSize, portraitSize)
			self.Portrait:SetPoint("TOPRIGHT", self, "TOPLEFT", -6 ,0)

			self.Portrait.Border = CreateFrame("Frame", nil, self)
			self.Portrait.Border:SetAllPoints(self.Portrait)
			self.Portrait.Border:CreateBorder()

			if (C["Unitframe"].PortraitStyle.Value == "ClassPortraits" or C["Unitframe"].PortraitStyle.Value == "NewClassPortraits") then
				self.Portrait.PostUpdate = Module.UpdateClassPortraits
			end
		end
	end

	self.HappinessIndicator = self.Overlay:CreateTexture(nil, "ARTWORK") CreateFrame("Frame", self:GetName().."_PetHappiness", self)
	self.HappinessIndicator:SetSize(20, 20)
	if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
		self.HappinessIndicator:SetPoint("RIGHT", self.Portrait, "LEFT", -4, 0)
	else
		self.HappinessIndicator:SetPoint("RIGHT", self.Health, "LEFT", -4, 0)
	end

	self.HappinessIndicator.IconBorder = self.HappinessIndicator.IconBorder or CreateFrame("Frame", self:GetName().."_PetHappiness", self)
	self.HappinessIndicator.IconBorder:EnableMouse(true)
	self.HappinessIndicator.IconBorder:SetFrameLevel(5)
	self.HappinessIndicator.IconBorder:SetPoint("TOPLEFT", self.HappinessIndicator, 2, -2)
	self.HappinessIndicator.IconBorder:SetPoint("BOTTOMRIGHT", self.HappinessIndicator, -2, 2)
	self.HappinessIndicator.IconBorder:CreateBorder()

	self.Name = self:CreateFontString(nil, "OVERLAY")
	if C["Unitframe"].PetPower then
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
	self.Name:SetShown(not C["Unitframe"].HidePetName)

	self.Level = self:CreateFontString(nil, "OVERLAY")
	if C["Unitframe"].PortraitStyle.Value == "NoPortraits" then
		if C["Unitframe"].PetPower then
			self.Level:SetPoint("BOTTOMLEFT", self.Power, 0, -16)
		else
			self.Level:SetPoint("BOTTOMLEFT", self.Health, 0, -16)
		end
	else
		self.Level:SetPoint("BOTTOM", self.Portrait, 0, -16)
	end
	self.Level:SetFontObject(UnitframeFont)
	self:Tag(self.Level, "[fulllevel]")
	self.Level:SetShown(not C["Unitframe"].HidePetLevel)

	self.Buffs = CreateFrame("Frame", self:GetName().."Buffs", self)
	self.Buffs:SetWidth(82)
	self.Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, C["Unitframe"].HidePetName and C["Unitframe"].HidePetLevel and -6 or -20)
	self.Buffs.num = 4 * 2
	self.Buffs.spacing = 6
	self.Buffs.size = ((((self.Buffs:GetWidth() - (self.Buffs.spacing * (self.Buffs.num / 2 - 1))) / self.Buffs.num)) * 2)
	self.Buffs:SetHeight(self.Buffs.size * 2)
	self.Buffs.initialAnchor = "TOPLEFT"
	self.Buffs["growth-y"] = "DOWN"
	self.Buffs["growth-x"] = "RIGHT"
	self.Buffs.CustomFilter = Module.CustomFilter
	self.Buffs.PostCreateIcon = Module.PostCreateAura
	self.Buffs.PostUpdateIcon = Module.PostUpdateAura

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
		self.RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
	else
		self.RaidTargetIndicator:SetPoint("TOP", self.Health, "TOP", 0, 8)
	end
	self.RaidTargetIndicator:SetSize(12, 12)

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

	self.ThreatIndicator = {
		IsObjectType = K.Noop,
		Override = Module.UpdateThreat,
	}

	self.Range = Module.CreateRangeIndicator(self)
end