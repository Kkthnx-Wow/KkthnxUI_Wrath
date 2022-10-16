local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Unitframes")

local _G = _G
local select = select

local CreateFrame = _G.CreateFrame

function Module:CreateTarget()
	self.mystyle = "target"

	local targetWidth = C["Unitframe"].TargetHealthWidth
	local targetHeight = C["Unitframe"].TargetHealthHeight
	local targetPortraitStyle = C["Unitframe"].PortraitStyle.Value

	local UnitframeTexture = K.GetTexture(C["General"].Texture)
	local HealPredictionTexture = K.GetTexture(C["General"].Texture)

	Module.CreateHeader(self)

	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetHeight(targetHeight)
	Health:SetPoint("TOPLEFT")
	Health:SetPoint("TOPRIGHT")
	Health:SetStatusBarTexture(UnitframeTexture)
	Health:CreateBorder()

	local Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	Overlay:SetAllPoints(Health)
	Overlay:SetFrameLevel(5)

	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.frequentUpdates = true

	if C["Unitframe"].Smooth then
		K:SmoothBar(Health)
	end

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
	self:Tag(Health.Value, "[hp]")

	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetHeight(C["Unitframe"].TargetPowerHeight)
	Power:SetPoint("TOPLEFT", Health, "BOTTOMLEFT", 0, -6)
	Power:SetPoint("TOPRIGHT", Health, "BOTTOMRIGHT", 0, -6)
	Power:SetStatusBarTexture(UnitframeTexture)
	Power:CreateBorder()

	Power.colorPower = true
	Power.frequentUpdates = true

	if C["Unitframe"].Smooth then
		K:SmoothBar(Power)
	end

	Power.Value = Power:CreateFontString(nil, "OVERLAY")
	Power.Value:SetPoint("CENTER", Power, "CENTER", 0, 0)
	Power.Value:SetFontObject(K.UIFont)
	Power.Value:SetFont(select(1, Power.Value:GetFont()), 11, select(3, Power.Value:GetFont()))
	self:Tag(Power.Value, "[power]")

	local Name = self:CreateFontString(nil, "OVERLAY")
	Name:SetPoint("BOTTOMLEFT", Health, "TOPLEFT", 0, 4)
	Name:SetPoint("BOTTOMRIGHT", Health, "TOPRIGHT", 0, 4)
	Name:SetFontObject(K.UIFont)
	Name:SetWordWrap(false)

	if targetPortraitStyle == "NoPortraits" or targetPortraitStyle == "OverlayPortrait" then
		if C["Unitframe"].HealthbarColor.Value == "Class" then
			self:Tag(Name, "[name] [fulllevel][afkdnd]")
		else
			self:Tag(Name, "[color][name] [fulllevel][afkdnd]")
		end
	else
		if C["Unitframe"].HealthbarColor.Value == "Class" then
			self:Tag(Name, "[name][afkdnd]")
		else
			self:Tag(Name, "[color][name][afkdnd]")
		end
	end

	if targetPortraitStyle ~= "NoPortraits" then
		if targetPortraitStyle == "OverlayPortrait" then
			local Portrait = CreateFrame("PlayerModel", "KKUI_TargetPortrait", self)
			Portrait:SetFrameStrata(self:GetFrameStrata())
			Portrait:SetPoint("TOPLEFT", Health, "TOPLEFT", 1, -1)
			Portrait:SetPoint("BOTTOMRIGHT", Health, "BOTTOMRIGHT", -1, 1)
			Portrait:SetAlpha(0.6)
			--Portrait:SetParent()

			self.Portrait = Portrait
		elseif targetPortraitStyle == "ThreeDPortraits" then
			local Portrait = CreateFrame("PlayerModel", "KKUI_TargetPortrait", Health)
			Portrait:SetFrameStrata(self:GetFrameStrata())
			Portrait:SetSize(Health:GetHeight() + Power:GetHeight() + 6, Health:GetHeight() + Power:GetHeight() + 6)
			Portrait:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, 0)
			Portrait:CreateBorder()

			self.Portrait = Portrait
		elseif targetPortraitStyle ~= "ThreeDPortraits" and targetPortraitStyle ~= "OverlayPortrait" then
			local Portrait = Health:CreateTexture("KKUI_TargetPortrait", "BACKGROUND", nil, 1)
			Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
			Portrait:SetSize(Health:GetHeight() + Power:GetHeight() + 6, Health:GetHeight() + Power:GetHeight() + 6)
			Portrait:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, 0)

			Portrait.Border = CreateFrame("Frame", nil, self)
			Portrait.Border:SetAllPoints(Portrait)
			Portrait.Border:CreateBorder()

			self.Portrait = Portrait

			if targetPortraitStyle == "ClassPortraits" or targetPortraitStyle == "NewClassPortraits" then
				Portrait.PostUpdate = Module.UpdateClassPortraits
			end
		end
	end

	if C["Unitframe"].TargetDebuffs then -- and C["Unitframe"].TargetDebuffsTop
		local Debuffs = CreateFrame("Frame", nil, self)
		Debuffs.spacing = 6
		Debuffs.initialAnchor = "BOTTOMLEFT"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs["growth-y"] = "UP"
		Debuffs:SetPoint("BOTTOMLEFT", Name, "TOPLEFT", 0, 6)
		Debuffs:SetPoint("BOTTOMRIGHT", Name, "TOPRIGHT", 0, 6)
		Debuffs.num = 14
		Debuffs.iconsPerRow = C["Unitframe"].TargetDebuffsPerRow

		Module:UpdateAuraContainer(targetWidth, Debuffs, Debuffs.num)

		Debuffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
		Debuffs.PostCreateIcon = Module.PostCreateAura
		Debuffs.PostUpdateIcon = Module.PostUpdateAura

		self.Debuffs = Debuffs
	end

	if C["Unitframe"].TargetBuffs then -- and C["Unitframe"].TargetDebuffsTop
		local Buffs = CreateFrame("Frame", nil, self)
		Buffs:SetPoint("TOPLEFT", Power, "BOTTOMLEFT", 0, -6)
		Buffs:SetPoint("TOPRIGHT", Power, "BOTTOMRIGHT", 0, -6)
		Buffs.initialAnchor = "TOPLEFT"
		Buffs["growth-x"] = "RIGHT"
		Buffs["growth-y"] = "DOWN"
		Buffs.num = 20
		Buffs.spacing = 6
		Buffs.iconsPerRow = C["Unitframe"].TargetBuffsPerRow
		Buffs.onlyShowPlayer = false

		Module:UpdateAuraContainer(targetWidth, Buffs, Buffs.num)

		Buffs.showStealableBuffs = true
		Buffs.PostCreateIcon = Module.PostCreateAura
		Buffs.PostUpdateIcon = Module.PostUpdateAura
		Buffs.PreUpdate = Module.bolsterPreUpdate
		Buffs.PostUpdate = Module.bolsterPostUpdate

		self.Buffs = Buffs
	end

	if C["Unitframe"].TargetCastbar then
		Module:CreateCastBar(self)
	end

	if C["Unitframe"].ShowHealPrediction then
		local frame = CreateFrame("Frame", nil, self)
		frame:SetAllPoints()

		local mhpb = frame:CreateTexture(nil, "BORDER", nil, 5)
		mhpb:SetWidth(1)
		mhpb:SetTexture(K.GetTexture(C["General"].Texture))
		mhpb:SetVertexColor(0, 1, 0, 0.5)

		local ohpb = frame:CreateTexture(nil, "BORDER", nil, 5)
		ohpb:SetWidth(1)
		ohpb:SetTexture(K.GetTexture(C["General"].Texture))
		ohpb:SetVertexColor(0, 1, 1, 0.5)

		self.HealPredictionAndAbsorb = {
			myBar = mhpb,
			otherBar = ohpb,
			maxOverflow = 1,
		}
		self.predicFrame = frame
	end

	-- Level
	local Level = self:CreateFontString(nil, "OVERLAY")
	if targetPortraitStyle ~= "NoPortraits" and targetPortraitStyle ~= "OverlayPortrait" then
		Level:Show()
		Level:SetPoint("BOTTOMLEFT", self.Portrait, "TOPLEFT", 0, 4)
		Level:SetPoint("BOTTOMRIGHT", self.Portrait, "TOPRIGHT", 0, 4)
	else
		Level:Hide()
	end
	Level:SetFontObject(K.UIFont)
	self:Tag(Level, "[fulllevel]")

	if C["Unitframe"].CombatText then
		local parentFrame = CreateFrame("Frame", nil, UIParent)
		local FloatingCombatFeedback = CreateFrame("Frame", "oUF_Target_CombatTextFrame", parentFrame)
		FloatingCombatFeedback:SetSize(32, 32)
		K.Mover(FloatingCombatFeedback, "CombatText", "TargetCombatText", { "BOTTOM", self, "TOPRIGHT", 0, 120 })

		for i = 1, 36 do
			FloatingCombatFeedback[i] = parentFrame:CreateFontString("$parentText", "OVERLAY")
		end

		FloatingCombatFeedback.font = select(1, KkthnxUIFontOutline:GetFont())
		FloatingCombatFeedback.fontFlags = "OUTLINE"
		FloatingCombatFeedback.abbreviateNumbers = true

		self.FloatingCombatFeedback = FloatingCombatFeedback

		-- Default CombatText
		SetCVar("enableFloatingCombatText", 0)
		K.HideInterfaceOption(_G.InterfaceOptionsCombatPanelEnableFloatingCombatText)
	end

	if C["Unitframe"].PvPIndicator then
		local PvPIndicator = self:CreateTexture(nil, "OVERLAY")
		PvPIndicator:SetSize(30, 33)
		if targetPortraitStyle ~= "NoPortraits" and targetPortraitStyle ~= "OverlayPortrait" then
			PvPIndicator:SetPoint("LEFT", self.Portrait, "RIGHT", 2, 0)
		else
			PvPIndicator:SetPoint("LEFT", Health, "RIGHT", 2, 0)
		end
		PvPIndicator.PostUpdate = Module.PostUpdatePvPIndicator

		self.PvPIndicator = PvPIndicator
	end

	local LeaderIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	LeaderIndicator:SetSize(12, 12)
	if targetPortraitStyle ~= "NoPortraits" and targetPortraitStyle ~= "OverlayPortrait" then
		LeaderIndicator:SetPoint("TOPRIGHT", self.Portrait, 0, 8)
	else
		LeaderIndicator:SetPoint("TOPRIGHT", Health, 0, 8)
	end

	local RaidTargetIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	if targetPortraitStyle ~= "NoPortraits" and targetPortraitStyle ~= "OverlayPortrait" then
		RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
	else
		RaidTargetIndicator:SetPoint("TOP", Health, "TOP", 0, 8)
	end
	RaidTargetIndicator:SetSize(16, 16)

	local ReadyCheckIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	if targetPortraitStyle ~= "NoPortraits" and targetPortraitStyle ~= "OverlayPortrait" then
		ReadyCheckIndicator:SetPoint("CENTER", self.Portrait)
	else
		ReadyCheckIndicator:SetPoint("CENTER", Health)
	end
	ReadyCheckIndicator:SetSize(targetHeight - 4, targetHeight - 4)

	local ResurrectIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	ResurrectIndicator:SetSize(44, 44)
	if targetPortraitStyle ~= "NoPortraits" and targetPortraitStyle ~= "OverlayPortrait" then
		ResurrectIndicator:SetPoint("CENTER", self.Portrait)
	else
		ResurrectIndicator:SetPoint("CENTER", Health)
	end

	local QuestIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	QuestIndicator:SetSize(20, 20)
	QuestIndicator:SetPoint("TOPLEFT", Health, "TOPRIGHT", -6, 6)

	if C["Unitframe"].DebuffHighlight then
		local DebuffHighlight = Health:CreateTexture(nil, "OVERLAY")
		DebuffHighlight:SetAllPoints(Health)
		DebuffHighlight:SetTexture(C["Media"].Textures.BlankTexture)
		DebuffHighlight:SetVertexColor(0, 0, 0, 0)
		DebuffHighlight:SetBlendMode("ADD")

		self.DebuffHighlight = DebuffHighlight

		self.DebuffHighlightAlpha = 0.45
		self.DebuffHighlightFilter = true
	end

	local Highlight = Health:CreateTexture(nil, "OVERLAY")
	Highlight:SetAllPoints()
	Highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	Highlight:SetTexCoord(0, 1, 0.5, 1)
	Highlight:SetVertexColor(0.6, 0.6, 0.6)
	Highlight:SetBlendMode("ADD")
	Highlight:Hide()

	self.ThreatIndicator = {
		IsObjectType = K.Noop,
		Override = Module.UpdateThreat,
	}

	self.Range = Module.CreateRangeIndicator(self)

	self.Overlay = Overlay
	self.Health = Health
	self.Power = Power
	self.Name = Name
	self.Level = Level
	self.LeaderIndicator = LeaderIndicator
	self.RaidTargetIndicator = RaidTargetIndicator
	self.ReadyCheckIndicator = ReadyCheckIndicator
	self.ResurrectIndicator = ResurrectIndicator
	self.QuestIndicator = QuestIndicator
	self.Highlight = Highlight
end
