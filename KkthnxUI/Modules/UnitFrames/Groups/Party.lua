local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Unitframes")

local _G = _G
local select = _G.select

local CreateFrame = _G.CreateFrame

function Module:CreateParty()
	self.mystyle = "party"

	local partyWidth = C["Party"].HealthWidth
	local partyHeight = C["Party"].HealthHeight
	local partyPortraitStyle = C["Unitframe"].PortraitStyle.Value
	local partyTexture = K.GetTexture(C["General"].Texture)

	local Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	Overlay:SetAllPoints()
	Overlay:SetFrameLevel(6)

	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetHeight(partyHeight)
	Health:SetPoint("TOPLEFT")
	Health:SetPoint("TOPRIGHT")
	Health:SetStatusBarTexture(partyTexture)
	Health:CreateBorder()

	Health.PostUpdate = Module.UpdateHealth
	Health.colorDisconnected = true
	Health.frequentUpdates = true

	if C["Party"].Smooth then
		K:SmoothBar(Health)
	end

	if C["Party"].HealthbarColor.Value == "Value" then
		Health.colorSmooth = true
		Health.colorClass = false
		Health.colorReaction = false
	elseif C["Party"].HealthbarColor.Value == "Dark" then
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
	Power:SetHeight(C["Party"].PowerHeight)
	Power:SetPoint("TOPLEFT", Health, "BOTTOMLEFT", 0, -6)
	Power:SetPoint("TOPRIGHT", Health, "BOTTOMRIGHT", 0, -6)
	Power:SetStatusBarTexture(partyTexture)
	Power:CreateBorder()
	Power.colorPower = true
	Power.SetFrequentUpdates = true

	if C["Party"].Smooth then
		K:SmoothBar(Power)
	end

	local Name = self:CreateFontString(nil, "OVERLAY")
	Name:SetPoint("BOTTOMLEFT", Health, "TOPLEFT", 0, 4)
	Name:SetPoint("BOTTOMRIGHT", Health, "TOPRIGHT", 0, 4)
	Name:SetWidth(partyWidth)
	Name:SetWordWrap(false)
	Name:SetFontObject(K.UIFont)
	if partyPortraitStyle == "NoPortraits" or partyPortraitStyle == "OverlayPortrait" then
		if C["Unitframe"].HealthbarColor.Value == "Class" then
			self:Tag(Name, "[lfdrole][name] [nplevel]")
		else
			self:Tag(Name, "[lfdrole][color][name] [nplevel]")
		end
	else
		if C["Unitframe"].HealthbarColor.Value == "Class" then
			self:Tag(Name, "[lfdrole][name]")
		else
			self:Tag(Name, "[lfdrole][color][name]")
		end
	end

	local Level = self:CreateFontString(nil, "OVERLAY")
	if partyPortraitStyle ~= "NoPortraits" and partyPortraitStyle ~= "OverlayPortrait" then
		Level:Show()
		Level:SetPoint("BOTTOMLEFT", self.Portrait, "TOPLEFT", 0, 4)
		Level:SetPoint("BOTTOMRIGHT", self.Portrait, "TOPRIGHT", 0, 4)
	else
		Level:Hide()
	end
	Level:SetFontObject(K.UIFont)
	self:Tag(Level, "[nplevel]")

	if C["Party"].ShowBuffs then
		local Buffs = CreateFrame("Frame", "KKUI_PartyBuffs", self)
		Buffs:SetPoint("TOPLEFT", Power, "BOTTOMLEFT", 0, -6)
		Buffs:SetPoint("TOPRIGHT", Power, "BOTTOMRIGHT", 0, -6)
		Buffs.initialAnchor = "TOPLEFT"
		Buffs["growth-x"] = "RIGHT"
		Buffs["growth-y"] = "DOWN"
		Buffs.num = 6
		Buffs.spacing = 6
		Buffs.iconsPerRow = 6
		Buffs.onlyShowPlayer = false

		Module:UpdateAuraContainer(partyWidth, Buffs, Buffs.num)

		Buffs.PostCreateIcon = Module.PostCreateAura
		Buffs.PostUpdateIcon = Module.PostUpdateAura

		self.Buffs = Buffs
	end

	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	Debuffs.spacing = 6
	Debuffs.initialAnchor = "LEFT"
	Debuffs["growth-x"] = "RIGHT"
	Debuffs:SetPoint("LEFT", Health, "RIGHT", 6, 0)
	Debuffs.num = 5
	Debuffs.iconsPerRow = 5

	Module:UpdateAuraContainer(partyWidth - 10, Debuffs, Debuffs.num)

	Debuffs.PostCreateIcon = Module.PostCreateAura
	Debuffs.PostUpdateIcon = Module.PostUpdateAura

	self.Overlay = Overlay
	self.Health = Health
	self.Power = Power
	self.Debuffs = Debuffs

	Module:CreateHeader(self)
	Module:CreatePortrait(self)
	Module:CreatePrediction(self)
	Module:CreateTargetHighlight(self)
	Module:CreateDebuffHighlight(self)
	Module:CreateIndicators(self)
end
