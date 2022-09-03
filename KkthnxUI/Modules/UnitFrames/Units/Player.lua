local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Unitframes")

local _G = _G
local select = _G.select
local string_format = _G.string.format

local CreateFrame = _G.CreateFrame

function Module.PostUpdateAddPower(element, cur, max)
	if element.Text and max > 0 then
		local perc = cur / max * 100
		if perc == 100 then
			perc = ""
			element:SetAlpha(0)
		else
			perc = string_format("%d%%", perc)
			element:SetAlpha(1)
		end

		element.Text:SetText(perc)
	end
end

-- local function updatePartySync(self)
-- 	local hasJoined = C_QuestSession.HasJoined()
-- 	if hasJoined then
-- 		self.QuestSyncIndicator:Show()
-- 	else
-- 		self.QuestSyncIndicator:Hide()
-- 	end
-- end

function Module:CreatePlayer()
	self.mystyle = "player"

	local playerWidth = C["Unitframe"].PlayerHealthWidth
	local playerHeight = C["Unitframe"].PlayerHealthHeight
	local playerPortraitStyle = C["Unitframe"].PortraitStyle.Value
	local playerTexture = K.GetTexture(C["General"].Texture)

	local Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	Overlay:SetAllPoints()
	Overlay:SetFrameLevel(5)

	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetHeight(playerHeight)
	Health:SetPoint("TOPLEFT")
	Health:SetPoint("TOPRIGHT")
	Health:SetStatusBarTexture(playerTexture)
	Health:CreateBorder()

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
	Health.Value:SetFontObject(K.UIFont)
	Health.Value:SetPoint("CENTER", Health, "CENTER", 0, 0)
	self:Tag(Health.Value, "[hp]")

	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetHeight(C["Unitframe"].PlayerPowerHeight)
	Power:SetPoint("TOPLEFT", Health, "BOTTOMLEFT", 0, -6)
	Power:SetPoint("TOPRIGHT", Health, "BOTTOMRIGHT", 0, -6)
	Power:SetStatusBarTexture(playerTexture)
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

	if C["Unitframe"].PlayerDebuffs then -- and C["Unitframe"].TargetDebuffsTop
		local Debuffs = CreateFrame("Frame", nil, self)
		Debuffs.spacing = 6
		Debuffs.initialAnchor = "BOTTOMLEFT"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs["growth-y"] = "UP"
		Debuffs:SetPoint("BOTTOMLEFT", Health, "TOPLEFT", 0, 6)
		Debuffs:SetPoint("BOTTOMRIGHT", Health, "TOPRIGHT", 0, 6)
		Debuffs.num = 14
		Debuffs.iconsPerRow = C["Unitframe"].PlayerDebuffsPerRow

		Module:UpdateAuraContainer(playerWidth, Debuffs, Debuffs.num)

		Debuffs.PostCreateIcon = Module.PostCreateAura
		Debuffs.PostUpdateIcon = Module.PostUpdateAura

		self.Debuffs = Debuffs
	end

	if C["Unitframe"].PlayerBuffs then -- and C["Unitframe"].TargetDebuffsTop
		local Buffs = CreateFrame("Frame", nil, self)
		Buffs:SetPoint("TOPLEFT", Power, "BOTTOMLEFT", 0, -6)
		Buffs:SetPoint("TOPRIGHT", Power, "BOTTOMRIGHT", 0, -6)
		Buffs.initialAnchor = "TOPLEFT"
		Buffs["growth-x"] = "RIGHT"
		Buffs["growth-y"] = "DOWN"
		Buffs.num = 20
		Buffs.spacing = 6
		Buffs.iconsPerRow = C["Unitframe"].PlayerBuffsPerRow
		Buffs.onlyShowPlayer = false

		Module:UpdateAuraContainer(playerWidth, Buffs, Buffs.num)

		Buffs.PostCreateIcon = Module.PostCreateAura
		Buffs.PostUpdateIcon = Module.PostUpdateAura

		self.Buffs = Buffs
	end

	-- if C["Unitframe"].PlayerPowerPrediction then
	-- 	local mainBar = CreateFrame("StatusBar", self:GetName() .. "PowerPrediction", Power)
	-- 	mainBar:SetReverseFill(true)
	-- 	mainBar:SetPoint("TOP", 0, -1)
	-- 	mainBar:SetPoint("BOTTOM", 0, 1)
	-- 	mainBar:SetPoint("RIGHT", Power:GetStatusBarTexture(), "RIGHT", -1, 0)
	-- 	mainBar:SetStatusBarTexture(playerTexture)
	-- 	mainBar:SetStatusBarColor(0.8, 0.1, 0.1, 0.6)
	-- 	mainBar:SetWidth(playerWidth)

	-- 	self.PowerPrediction = {
	-- 		mainBar = mainBar,
	-- 	}
	-- end

	-- Level
	if C["Unitframe"].ShowPlayerLevel then
		local Level = self:CreateFontString(nil, "OVERLAY")
		if playerPortraitStyle ~= "NoPortraits" and playerPortraitStyle ~= "OverlayPortrait" then
			Level:Show()
			Level:SetPoint("TOP", self.Portrait, 0, 15)
		else
			Level:Hide()
		end
		Level:SetFontObject(K.UIFont)
		self:Tag(Level, "[fulllevel]")

		self.Level = Level
	end

	if C["Unitframe"].Stagger then
		if K.Class == "MONK" then
			local Stagger = CreateFrame("StatusBar", self:GetName() .. "Stagger", self)
			Stagger:SetPoint("BOTTOMLEFT", Health, "TOPLEFT", 0, 6)
			Stagger:SetSize(playerWidth, 14)
			Stagger:SetStatusBarTexture(playerTexture)
			Stagger:CreateBorder()

			Stagger.Value = Stagger:CreateFontString(nil, "OVERLAY")
			Stagger.Value:SetFontObject(K.UIFont)
			Stagger.Value:SetPoint("CENTER", Stagger, "CENTER", 0, 0)
			self:Tag(Stagger.Value, "[monkstagger]")

			self.Stagger = Stagger
		end
	end

	if C["Unitframe"].AdditionalPower then
		local AdditionalPower = CreateFrame("StatusBar", self:GetName() .. "AdditionalPower", Health)
		AdditionalPower.frequentUpdates = true
		AdditionalPower:SetWidth(12)
		AdditionalPower:SetOrientation("VERTICAL")
		if playerPortraitStyle ~= "NoPortraits" and playerPortraitStyle ~= "OverlayPortrait" then
			AdditionalPower:SetPoint("TOPLEFT", self.Portrait, -18, 0)
			AdditionalPower:SetPoint("BOTTOMLEFT", self.Portrait, -18, 0)
		else
			AdditionalPower:SetPoint("TOPLEFT", self, -18, 0)
			AdditionalPower:SetPoint("BOTTOMLEFT", self, -18, 0)
		end
		AdditionalPower:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
		AdditionalPower:SetStatusBarColor(unpack(K.Colors.power.MANA))
		AdditionalPower:CreateBorder()

		if C["Unitframe"].Smooth then
			K:SmoothBar(AdditionalPower)
		end

		AdditionalPower.Text = AdditionalPower:CreateFontString(nil, "OVERLAY")
		AdditionalPower.Text:SetFontObject(K.UIFont)
		AdditionalPower.Text:SetFont(select(1, AdditionalPower.Text:GetFont()), 9, select(3, AdditionalPower.Text:GetFont()))
		AdditionalPower.Text:SetPoint("CENTER", AdditionalPower, 2, 0)

		AdditionalPower.PostUpdate = Module.PostUpdateAddPower

		self.AdditionalPower = AdditionalPower
	end

	if C["Unitframe"].GlobalCooldown then
		local GCD = CreateFrame("Frame", "oUF_PlayerGCD", Power)
		GCD:SetWidth(playerWidth)
		GCD:SetHeight(C["Unitframe"].PlayerPowerHeight - 2)
		GCD:SetPoint("LEFT", Power, "LEFT", 0, 0)

		GCD.Color = { 1, 1, 1, 0.6 }
		GCD.Texture = C["Media"].Textures.Spark128Texture
		GCD.Height = C["Unitframe"].PlayerPowerHeight - 2
		GCD.Width = 128 / 2

		self.GCD = GCD
	end

	local ThreatIndicator = {
		IsObjectType = K.Noop,
		Override = Module.UpdateThreat,
	}

	-- Fader
	if C["Unitframe"].CombatFade then
		self.Fader = {
			[1] = { Combat = 1, Arena = 1, Instance = 1 },
			[2] = { PlayerTarget = 1, PlayerNotMaxHealth = 1, PlayerNotMaxMana = 1, Casting = 1 },
			[3] = { Stealth = 0.5 },
			[4] = { notCombat = 0, PlayerTaxi = 0 },
		}
		self.NormalAlpha = 1
	end

	self.Overlay = Overlay
	self.Health = Health
	self.Power = Power
	self.ThreatIndicator = ThreatIndicator

	Module:CreateHeader(self)
	Module:CreatePortrait(self)
	Module:CreateCastBar(self)
	Module:CreateClassPower(self)
	Module:CreateFCT(self)
	Module:CreateSwing(self)
	Module:CreatePrediction(self)
	Module:CreateDebuffHighlight(self)
	Module:CreateIndicators(self)
end
