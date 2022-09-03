local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Unitframes")

local _G = _G

local CreateFrame = _G.CreateFrame

function Module:CreatePet()
	self.mystyle = "pet"

	local petHeight = C["Unitframe"].PetHealthHeight
	local petPortraitStyle = C["Unitframe"].PortraitStyle.Value
	local petTexture = K.GetTexture(C["General"].Texture)

	local Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	Overlay:SetAllPoints()
	Overlay:SetFrameLevel(5)

	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetHeight(petHeight)
	Health:SetPoint("TOPLEFT")
	Health:SetPoint("TOPRIGHT")
	Health:SetStatusBarTexture(petTexture)
	Health:CreateBorder()

	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.frequentUpdates = true

	if C["Unitframe"].HealthbarColor.Value == "Value" then
		Health.colorSmooth = true
		Health.colorClass = false
		Health.colorReaction = false
	elseif C["Unitframe"].HealthbarColor.Value == "Dark" then
		Health.colorSmooth = false
		Health.colorClass = false
		Health.colorReaction = false
		Health:SetStatusBarColor(0.31, 0.31, 0.31)
	else
		Health.colorSmooth = false
		Health.colorClass = true
		Health.colorReaction = true
	end

	Health.Value = Health:CreateFontString(nil, "OVERLAY")
	Health.Value:SetPoint("CENTER", Health, "CENTER", 0, 0)
	Health.Value:SetFontObject(K.UIFont)
	Health.Value:SetFont(select(1, Health.Value:GetFont()), 10, select(3, Health.Value:GetFont()))
	self:Tag(Health.Value, "[hp]")

	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetHeight(C["Unitframe"].PetPowerHeight)
	Power:SetPoint("TOPLEFT", Health, "BOTTOMLEFT", 0, -6)
	Power:SetPoint("TOPRIGHT", Health, "BOTTOMRIGHT", 0, -6)
	Power:SetStatusBarTexture(petTexture)
	Power:CreateBorder()

	Power.colorPower = true
	Power.frequentUpdates = false

	local Name = self:CreateFontString(nil, "OVERLAY")
	Name:SetPoint("TOPLEFT", Power, "BOTTOMLEFT", 0, -4)
	Name:SetPoint("TOPRIGHT", Power, "BOTTOMRIGHT", 0, -4)
	Name:SetFontObject(K.UIFont)
	Name:SetWordWrap(false)

	if petPortraitStyle == "NoPortraits" or petPortraitStyle == "OverlayPortrait" then
		if C["Unitframe"].HealthbarColor.Value == "Class" then
			self:Tag(Name, "[name] [fulllevel]")
		else
			self:Tag(Name, "[color][name] [fulllevel]")
		end
	else
		if C["Unitframe"].HealthbarColor.Value == "Class" then
			self:Tag(Name, "[name]")
		else
			self:Tag(Name, "[color][name]")
		end
	end
	Name:SetShown(not C["Unitframe"].HidePetName)

	if petPortraitStyle ~= "NoPortraits" then
		if petPortraitStyle == "OverlayPortrait" then
			local Portrait = CreateFrame("PlayerModel", "KKUI_PetPortrait", self)
			Portrait:SetFrameStrata(self:GetFrameStrata())
			Portrait:SetPoint("TOPLEFT", Health, "TOPLEFT", 1, -1)
			Portrait:SetPoint("BOTTOMRIGHT", Health, "BOTTOMRIGHT", -1, 1)
			Portrait:SetAlpha(0.6)

			self.Portrait = Portrait
		elseif petPortraitStyle == "ThreeDPortraits" then
			local Portrait = CreateFrame("PlayerModel", "KKUI_PetPortrait", Health)
			Portrait:SetFrameStrata(self:GetFrameStrata())
			Portrait:SetSize(Health:GetHeight() + Power:GetHeight() + 6, Health:GetHeight() + Power:GetHeight() + 6)
			Portrait:SetPoint("TOPRIGHT", self, "TOPLEFT", -6, 0)
			Portrait:CreateBorder()

			self.Portrait = Portrait
		elseif petPortraitStyle ~= "ThreeDPortraits" and petPortraitStyle ~= "OverlayPortrait" then
			local Portrait = Health:CreateTexture("KKUI_PetPortrait", "BACKGROUND", nil, 1)
			Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
			Portrait:SetSize(Health:GetHeight() + Power:GetHeight() + 6, Health:GetHeight() + Power:GetHeight() + 6)
			Portrait:SetPoint("TOPRIGHT", self, "TOPLEFT", -6, 0)

			Portrait.Border = CreateFrame("Frame", nil, self)
			Portrait.Border:SetAllPoints(Portrait)
			Portrait.Border:CreateBorder()

			self.Portrait = Portrait

			if petPortraitStyle == "ClassPortraits" or petPortraitStyle == "NewClassPortraits" then
				Portrait.PostUpdate = Module.UpdateClassPortraits
			end
		end
	end

	local Level = self:CreateFontString(nil, "OVERLAY")
	Level:SetFontObject(K.UIFont)
	if petPortraitStyle ~= "NoPortraits" and petPortraitStyle ~= "OverlayPortrait" and not C["Unitframe"].HidePetLevel then
		Level:Show()
	else
		Level:Hide()
	end
	Level:SetPoint("TOPLEFT", self.Portrait, "BOTTOMLEFT", 0, -4)
	Level:SetPoint("TOPRIGHT", self.Portrait, "BOTTOMRIGHT", 0, -4)
	self:Tag(Level, "[fulllevel]")

	local Debuffs = CreateFrame("Frame", nil, self)
	Debuffs.spacing = 6
	Debuffs.initialAnchor = "TOPLEFT"
	Debuffs["growth-x"] = "RIGHT"
	Debuffs["growth-y"] = "DOWN"
	Debuffs:SetPoint("TOPLEFT", C["Unitframe"].HidePetName and Power or Name, "BOTTOMLEFT", 0, -6)
	Debuffs:SetPoint("TOPRIGHT", C["Unitframe"].HidePetName and Power or Name, "BOTTOMRIGHT", 0, -6)
	Debuffs.num = 8
	Debuffs.iconsPerRow = 4

	local ThreatIndicator = {
		IsObjectType = K.Noop,
		Override = Module.UpdateThreat,
	}

	local Range = Module.CreateRangeIndicator(self)

	self.Overlay = Overlay
	self.Health = Health
	self.Power = Power
	self.Name = Name
	self.Level = Level
	self.Debuffs = Debuffs
	self.ThreatIndicator = ThreatIndicator
	self.Range = Range

	Module:CreateHeader(self)
	Module:CreateDebuffHighlight(self)
end
