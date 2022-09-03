local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Unitframes")

local _G = _G
local select = select

local CreateFrame = _G.CreateFrame

function Module:CreateFocus()
	self.mystyle = "focus"

	local focusWidth = C["Unitframe"].FocusHealthWidth
	local focusPortraitStyle = C["Unitframe"].PortraitStyle.Value
	local focusTexture = K.GetTexture(C["General"].Texture)

	self.Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	self.Overlay:SetAllPoints()
	self.Overlay:SetFrameLevel(5)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetHeight(C["Unitframe"].FocusHealthHeight)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(focusTexture)
	self.Health:CreateBorder()

	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.frequentUpdates = true

	if C["Unitframe"].Smooth then
		K:SmoothBar(self.Health)
	end

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
	self:Tag(self.Health.Value, "[hp]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetHeight(C["Unitframe"].FocusPowerHeight)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(focusTexture)
	self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.frequentUpdates = true

	if C["Unitframe"].Smooth then
		K:SmoothBar(self.Power)
	end

	self.Power.Value = self.Power:CreateFontString(nil, "OVERLAY")
	self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
	self.Power.Value:SetFontObject(K.UIFont)
	self.Power.Value:SetFont(select(1, self.Power.Value:GetFont()), 11, select(3, self.Power.Value:GetFont()))
	self:Tag(self.Power.Value, "[power]")

	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 4)
	self.Name:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 4)
	self.Name:SetFontObject(K.UIFont)
	self.Name:SetWordWrap(false)

	if focusPortraitStyle == "NoPortraits" then
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

	if C["Unitframe"].FocusDebuffs then
		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs.spacing = 6
		self.Debuffs.initialAnchor = "BOTTOMLEFT"
		self.Debuffs["growth-x"] = "RIGHT"
		self.Debuffs["growth-y"] = "UP"
		self.Debuffs:SetPoint("BOTTOMLEFT", self.Name, "TOPLEFT", 0, 6)
		self.Debuffs:SetPoint("BOTTOMRIGHT", self.Name, "TOPRIGHT", 0, 6)
		self.Debuffs.num = 15
		self.Debuffs.iconsPerRow = C["Unitframe"].TargetDebuffsPerRow

		Module:UpdateAuraContainer(focusWidth, self.Debuffs, self.Debuffs.num)

		self.Debuffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
		self.Debuffs.PostCreateIcon = Module.PostCreateAura
		self.Debuffs.PostUpdateIcon = Module.PostUpdateAura
	end

	if C["Unitframe"].FocusBuffs then
		self.Buffs = CreateFrame("Frame", nil, self)
		self.Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		self.Buffs:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -6)
		self.Buffs.initialAnchor = "TOPLEFT"
		self.Buffs["growth-x"] = "RIGHT"
		self.Buffs["growth-y"] = "DOWN"
		self.Buffs.num = 20
		self.Buffs.spacing = 6
		self.Buffs.iconsPerRow = C["Unitframe"].TargetBuffsPerRow
		self.Buffs.onlyShowPlayer = false

		Module:UpdateAuraContainer(focusWidth, self.Buffs, self.Buffs.num)

		self.Buffs.showStealableBuffs = true
		self.Buffs.PostCreateIcon = Module.PostCreateAura
		self.Buffs.PostUpdateIcon = Module.PostUpdateAura
	end

	-- Level
	self.Level = self:CreateFontString(nil, "OVERLAY")
	if focusPortraitStyle ~= "NoPortraits" and focusPortraitStyle ~= "OverlayPortrait" then
		self.Level:Show()
		self.Level:SetPoint("BOTTOMLEFT", self.Portrait, "TOPLEFT", 0, 4)
		self.Level:SetPoint("BOTTOMRIGHT", self.Portrait, "TOPRIGHT", 0, 4)
	else
		self.Level:Hide()
	end
	self.Level:SetFontObject(K.UIFont)
	self:Tag(self.Level, "[fulllevel]")

	self.ThreatIndicator = {
		IsObjectType = K.Noop,
		Override = Module.UpdateThreat,
	}

	self.Range = Module.CreateRangeIndicator(self)

	Module:CreateHeader(self)
	Module:CreatePortrait(self)
	Module:CreateDebuffHighlight(self)
end
