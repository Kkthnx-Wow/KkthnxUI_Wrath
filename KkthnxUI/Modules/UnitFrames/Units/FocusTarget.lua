local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Unitframes")

local _G = _G

local CreateFrame = _G.CreateFrame

function Module:CreateFocusTarget()
	self.mystyle = "focustarget"

	local focusTargetWidth = C["Unitframe"].FocusTargetHealthWidth
	local focusTargetHeight = C["Unitframe"].FocusTargetHealthHeight
	local focusTargetPortraitStyle = C["Unitframe"].PortraitStyle.Value
	local focusTexture = K.GetTexture(C["General"].Texture)

	self.Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	self.Overlay:SetAllPoints()
	self.Overlay:SetFrameLevel(5)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetHeight(focusTargetHeight)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(focusTexture)
	self.Health:CreateBorder()

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
	self.Health.Value:SetFontObject(K.UIFont)
	self.Health.Value:SetFont(select(1, self.Health.Value:GetFont()), 10, select(3, self.Health.Value:GetFont()))
	self:Tag(self.Health.Value, "[hp]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetHeight(C["Unitframe"].FocusTargetPowerHeight)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(focusTexture)
	self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.frequentUpdates = false

	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -4)
	self.Name:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -4)
	self.Name:SetFontObject(K.UIFont)
	self.Name:SetWordWrap(false)

	if focusTargetPortraitStyle == "NoPortraits" or focusTargetPortraitStyle == "OverlayPortrait" then
		if C["Unitframe"].HealthbarColor.Value == "Class" then
			self:Tag(self.Name, "[name] [fulllevel][afkdnd]")
		else
			self:Tag(self.Name, "[color][name] [fulllevel][afkdnd]")
		end
	else
		if C["Unitframe"].HealthbarColor.Value == "Class" then
			self:Tag(self.Name, "[name][afkdnd]")
		else
			self:Tag(self.Name, "[color][name][afkdnd]")
		end
	end
	self.Name:SetShown(not C["Unitframe"].HideFocusTargetName)

	self.Level = self:CreateFontString(nil, "OVERLAY")
	self.Level:SetFontObject(K.UIFont)
	if focusTargetPortraitStyle ~= "NoPortraits" and focusTargetPortraitStyle ~= "OverlayPortrait" and not C["Unitframe"].HideFocusTargetLevel then
		self.Level:Show()
	else
		self.Level:Hide()
	end
	self.Level:SetPoint("TOPLEFT", self.Portrait, "BOTTOMLEFT", 0, -4)
	self.Level:SetPoint("TOPRIGHT", self.Portrait, "BOTTOMRIGHT", 0, -4)
	self:Tag(self.Level, "[fulllevel]")

	self.Debuffs = CreateFrame("Frame", nil, self)
	self.Debuffs.spacing = 6
	self.Debuffs.initialAnchor = "TOPLEFT"
	self.Debuffs["growth-x"] = "RIGHT"
	self.Debuffs["growth-y"] = "DOWN"
	self.Debuffs:SetPoint("TOPLEFT", C["Unitframe"].HideFocusTargetName and self.Power or self.Name, "BOTTOMLEFT", 0, -6)
	self.Debuffs:SetPoint("TOPRIGHT", C["Unitframe"].HideFocusTargetName and self.Power or self.Name, "BOTTOMRIGHT", 0, -6)
	self.Debuffs.num = 8
	self.Debuffs.iconsPerRow = 4

	Module:UpdateAuraContainer(focusTargetWidth, self.Debuffs, self.Debuffs.num)

	self.Debuffs.PostCreateIcon = Module.PostCreateAura
	self.Debuffs.PostUpdateIcon = Module.PostUpdateAura

	self.ThreatIndicator = {
		IsObjectType = K.Noop,
		Override = Module.UpdateThreat,
	}

	self.Range = Module.CreateRangeIndicator(self)

	Module:CreateHeader(self)
end
