local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Unitframes")

local _G = _G
local select = _G.select

local CreateFrame = _G.CreateFrame
local GetThreatStatusColor = _G.GetThreatStatusColor
local UnitIsUnit = _G.UnitIsUnit
local UnitThreatSituation = _G.UnitThreatSituation

local function UpdateRaidThreat(self, _, unit)
	if unit ~= self.unit then
		return
	end

	if not self.KKUI_Border then
		return
	end

	local situation = UnitThreatSituation(unit)
	if situation and situation > 0 then
		local r, g, b = GetThreatStatusColor(situation)
		self.KKUI_Border:SetVertexColor(r, g, b)
	else
		if C["General"].ColorTextures then
			self.KKUI_Border:SetVertexColor(C["General"].TexturesColor[1], C["General"].TexturesColor[2], C["General"].TexturesColor[3])
		else
			self.KKUI_Border:SetVertexColor(1, 1, 1)
		end
	end
end

local function UpdateRaidPower(self, _, unit)
	if self.unit ~= unit then
		return
	end

	if C["Raid"].ManabarShow then
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
	self.mystyle = "raid"

	local raidTexture = K.GetTexture(C["General"].Texture)

	self:CreateBorder()

	local Overlay = CreateFrame("Frame", nil, self)
	Overlay:SetAllPoints()
	Overlay:SetFrameLevel(self:GetFrameLevel() + 4)

	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetFrameLevel(self:GetFrameLevel())
	Health:SetAllPoints(self)
	Health:SetStatusBarTexture(raidTexture)

	Health.Value = Health:CreateFontString(nil, "OVERLAY")
	Health.Value:SetPoint("CENTER", Health, 0, -9)
	Health.Value:SetFontObject(K.UIFont)
	Health.Value:SetFont(select(1, Health.Value:GetFont()), 11, select(3, Health.Value:GetFont()))
	self:Tag(Health.Value, "[raidhp]")

	Health.colorDisconnected = true
	Health.frequentUpdates = true

	if C["Raid"].HealthbarColor.Value == "Value" then
		Health.colorSmooth = true
		Health.colorClass = false
		Health.colorReaction = false
	elseif C["Raid"].HealthbarColor.Value == "Dark" then
		Health.colorSmooth = false
		Health.colorClass = false
		Health.colorReaction = false
		Health:SetStatusBarColor(0.31, 0.31, 0.31)
	else
		Health.colorSmooth = false
		Health.colorClass = true
		Health.colorReaction = true
	end

	if C["Raid"].Smooth then
		K:SmoothBar(Health)
	end

	if C["Raid"].ManabarShow then
		local Power = CreateFrame("StatusBar", nil, self)
		Power:SetFrameStrata("LOW")
		Power:SetFrameLevel(self:GetFrameLevel())
		Power:SetPoint("TOPLEFT", Health, "BOTTOMLEFT", 0, -1)
		Power:SetPoint("TOPRIGHT", Health, "BOTTOMRIGHT", 0, -1)
		Power:SetHeight(4)
		Power:SetStatusBarTexture(raidTexture)

		Power.colorPower = true
		Power.frequentUpdates = false

		if C["Raid"].Smooth then
			K:SmoothBar(Power)
		end

		self.Power = Power

		table.insert(self.__elements, UpdateRaidPower)
		self:RegisterEvent("UNIT_DISPLAYPOWER", UpdateRaidPower)
		self:RegisterEvent("UNIT_POWER_UPDATE", UpdateRaidPower)
		self:RegisterEvent("UNIT_MAXPOWER", UpdateRaidPower)
		self:RegisterEvent("UNIT_DISPLAYPOWER", UpdateRaidPower)
	end

	local Name = self:CreateFontString(nil, "OVERLAY")
	Name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -15)
	Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -15)
	Name:SetFontObject(K.UIFont)
	Name:SetWordWrap(false)
	self:Tag(Name, "[lfdrole][name]")

	if C["Raid"].RaidBuffsStyle.Value == "Aura Track" then
		local AuraTrack = CreateFrame("Frame", nil, Health)
		AuraTrack.Texture = raidTexture
		AuraTrack.Icons = C["Raid"].AuraTrackIcons
		AuraTrack.SpellTextures = C["Raid"].AuraTrackSpellTextures
		AuraTrack.Thickness = C["Raid"].AuraTrackThickness
		AuraTrack.Font = select(1, _G.KkthnxUIFontOutline:GetFont())

		AuraTrack:ClearAllPoints()
		if AuraTrack.Icons ~= true then
			AuraTrack:SetPoint("TOPLEFT", Health, "TOPLEFT", 2, -2)
			AuraTrack:SetPoint("BOTTOMRIGHT", Health, "BOTTOMRIGHT", -2, 2)
		else
			AuraTrack:SetPoint("TOPLEFT", Health, "TOPLEFT", -4, -6)
			AuraTrack:SetPoint("BOTTOMRIGHT", Health, "BOTTOMRIGHT", 4, 6)
		end

		self.AuraTrack = AuraTrack
	elseif C["Raid"].RaidBuffsStyle.Value == "Standard" then
		local filter = C["Raid"].RaidBuffs.Value == "All" and "HELPFUL" or "HELPFUL|RAID"
		local onlyShowPlayer = C["Raid"].RaidBuffs.Value == "Self"

		local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", Health)
		Buffs:SetPoint("TOPLEFT", Health, "TOPLEFT", 2, -2)
		Buffs:SetPoint("BOTTOMRIGHT", Health, "BOTTOMRIGHT", -2, 2)
		Buffs:SetHeight(16)
		Buffs:SetWidth(79)
		Buffs.size = 16
		Buffs.num = 5
		Buffs.numRow = 1
		Buffs.spacing = 6
		Buffs.initialAnchor = "TOPLEFT"
		Buffs.disableCooldown = true
		Buffs.disableMouse = true
		Buffs.onlyShowPlayer = onlyShowPlayer
		Buffs.filter = filter
		Buffs.IsRaid = true
		Buffs.PostCreateIcon = Module.PostCreateAura
		Buffs.PostUpdateIcon = Module.PostUpdateAura

		self.Buffs = Buffs
	end

	if C["Raid"].DebuffWatch then
		local Height = C["Raid"].Height
		local DebuffSize = Height >= 32 and Height - 20 or Height

		local RaidDebuffs = CreateFrame("Frame", nil, Health)
		RaidDebuffs:SetHeight(DebuffSize)
		RaidDebuffs:SetWidth(DebuffSize)
		RaidDebuffs:SetPoint("CENTER", Health)
		RaidDebuffs:SetFrameLevel(Health:GetFrameLevel() + 10)
		RaidDebuffs:CreateBorder()
		RaidDebuffs:Hide()

		RaidDebuffs.icon = RaidDebuffs:CreateTexture(nil, "ARTWORK")
		RaidDebuffs.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		RaidDebuffs.icon:SetAllPoints(RaidDebuffs)

		RaidDebuffs.cd = CreateFrame("Cooldown", nil, RaidDebuffs, "CooldownFrameTemplate")
		RaidDebuffs.cd:SetAllPoints(RaidDebuffs)
		RaidDebuffs.cd:SetReverse(true)
		RaidDebuffs.cd.noOCC = true
		RaidDebuffs.cd.noCooldownCount = true
		RaidDebuffs.cd:SetHideCountdownNumbers(true)
		RaidDebuffs.cd:SetAlpha(0.7)

		RaidDebuffs.onlyMatchSpellID = true
		RaidDebuffs.showDispellableDebuff = true

		local parentFrame = CreateFrame("Frame", nil, RaidDebuffs)
		parentFrame:SetAllPoints()
		parentFrame:SetFrameLevel(RaidDebuffs:GetFrameLevel() + 6)

		RaidDebuffs.timer = parentFrame:CreateFontString(nil, "OVERLAY")
		RaidDebuffs.timer:SetFont(select(1, _G.KkthnxUIFont:GetFont()), 12, "OUTLINE")
		RaidDebuffs.timer:SetPoint("CENTER", RaidDebuffs, 1, 0)

		RaidDebuffs.count = parentFrame:CreateFontString(nil, "OVERLAY")
		RaidDebuffs.count:SetFont(select(1, _G.KkthnxUIFontOutline:GetFont()), 11, "OUTLINE")
		RaidDebuffs.count:SetPoint("BOTTOMRIGHT", RaidDebuffs, "BOTTOMRIGHT", 2, 0)
		RaidDebuffs.count:SetTextColor(1, 0.9, 0)

		RaidDebuffs.forceShow = false
		RaidDebuffs.ShowDispellableDebuff = true

		self.RaidDebuffs = RaidDebuffs
	end

	self.ThreatIndicator = {
		IsObjectType = function() end,
		Override = UpdateRaidThreat,
	}

	self.Range = Module.CreateRangeIndicator(self)

	self.Health = Health
	self.Name = Name
	self.Overlay = Overlay

	Module:CreateHeader(self)
	Module:CreatePrediction(self)
	Module:CreateTargetHighlight(self)
	Module:CreateDebuffHighlight(self)
	Module:CreateIndicators(self)
end
