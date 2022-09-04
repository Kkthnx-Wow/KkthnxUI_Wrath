local K, C = unpack(KkthnxUI)
local Module = K:NewModule("Unitframes")
local AuraModule = K:GetModule("Auras")
local oUF = K.oUF

local _G = _G

local pairs = _G.pairs
local string_format = _G.string.format
local unpack = _G.unpack

local CLASS_ICON_TCOORDS = _G.CLASS_ICON_TCOORDS
local CreateFrame = _G.CreateFrame
local GetRuneCooldown = _G.GetRuneCooldown
local IsInInstance = _G.IsInInstance
local IsReplacingUnit = _G.IsReplacingUnit
local MAX_BOSS_FRAMES = _G.MAX_BOSS_FRAMES
local PlaySound = _G.PlaySound
local SOUNDKIT = _G.SOUNDKIT
local UIParent = _G.UIParent
local UnitClass = _G.UnitClass
local UnitExists = _G.UnitExists
local UnitFactionGroup = _G.UnitFactionGroup
local UnitFrame_OnEnter = _G.UnitFrame_OnEnter
local UnitFrame_OnLeave = _G.UnitFrame_OnLeave
local UnitIsEnemy = _G.UnitIsEnemy
local UnitIsFriend = _G.UnitIsFriend
local UnitIsPVP = _G.UnitIsPVP
local UnitIsPVPFreeForAll = _G.UnitIsPVPFreeForAll
local UnitIsPlayer = _G.UnitIsPlayer
local UnitThreatSituation = _G.UnitThreatSituation
local oUF_RaidDebuffs = _G.oUF_RaidDebuffs

local lastPvPSound = false
local phaseIconTexCoords = {
	[1] = { 1 / 128, 33 / 128, 1 / 64, 33 / 64 },
	[2] = { 34 / 128, 66 / 128, 1 / 64, 33 / 64 },
}
local filteredStyle = {
	["arena"] = true,
	["boss"] = true,
	["nameplate"] = true,
	["target"] = true,
}

function Module:UpdateClassPortraits(unit)
	if C["Unitframe"].PortraitStyle.Value == "NoPortraits" then
		return
	end

	if not unit then
		return
	end

	local _, unitClass = UnitClass(unit)
	if unitClass then
		local PortraitValue = C["Unitframe"].PortraitStyle.Value
		local ClassTCoords = CLASS_ICON_TCOORDS[unitClass]

		local defaultCPs = "ClassPortraits"
		local newCPs = "NewClassPortraits"

		for _, value in pairs({ PortraitValue }) do
			if value and value == defaultCPs and UnitIsPlayer(unit) then
				self:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Unitframes\\OLD-ICONS-CLASSES")
				if ClassTCoords then
					self:SetTexCoord(ClassTCoords[1], ClassTCoords[2], ClassTCoords[3], ClassTCoords[4])
				end
			elseif value and value == newCPs and UnitIsPlayer(unit) then
				self:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Unitframes\\NEW-ICONS-CLASSES")
				if ClassTCoords then
					self:SetTexCoord(ClassTCoords[1], ClassTCoords[2], ClassTCoords[3], ClassTCoords[4])
				end
			else
				self:SetTexCoord(0.15, 0.85, 0.15, 0.85)
			end
		end
	end
end

function Module:PostUpdatePvPIndicator(unit, status)
	local factionGroup = UnitFactionGroup(unit)

	if UnitIsPVPFreeForAll(unit) and status == "ffa" then
		self:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
		self:SetTexCoord(0, 0.65625, 0, 0.65625)
	elseif factionGroup and UnitIsPVP(unit) and status ~= nil then
		self:SetTexture("Interface\\QUESTFRAME\\objectivewidget")

		if factionGroup == "Alliance" then
			self:SetTexCoord(0.00390625, 0.136719, 0.511719, 0.671875)
		else
			self:SetTexCoord(0.00390625, 0.136719, 0.679688, 0.839844)
		end
	end
end

function Module:UpdateThreat(_, unit)
	if unit ~= self.unit then
		return
	end

	local portraitStyle = C["Unitframe"].PortraitStyle.Value
	local status = UnitThreatSituation(unit)
	local health = self.Health
	local portrait = self.Portrait
	local r, g, b

	if portraitStyle == "ThreeDPortraits" then
		if not portrait then
			return
		end

		if status and status > 1 then
			r, g, b = GetThreatStatusColor(status)
			portrait.KKUI_Border:SetVertexColor(r, g, b)
		else
			if C["General"].ColorTextures then
				portrait.KKUI_Border:SetVertexColor(C["General"].TexturesColor[1], C["General"].TexturesColor[2], C["General"].TexturesColor[3])
			else
				portrait.KKUI_Border:SetVertexColor(1, 1, 1)
			end
		end
	elseif portraitStyle ~= "ThreeDPortraits" and portraitStyle ~= "NoPortraits" and portraitStyle ~= "OverlayPortrait" then
		if not portrait then
			return
		end

		if status and status > 1 then
			r, g, b = GetThreatStatusColor(status)
			portrait.Border.KKUI_Border:SetVertexColor(r, g, b)
		else
			if C["General"].ColorTextures then
				portrait.Border.KKUI_Border:SetVertexColor(C["General"].TexturesColor[1], C["General"].TexturesColor[2], C["General"].TexturesColor[3])
			else
				portrait.Border.KKUI_Border:SetVertexColor(1, 1, 1)
			end
		end
	elseif portraitStyle == "NoPortraits" then
		if not health then
			return
		end

		if status and status > 1 then
			r, g, b = GetThreatStatusColor(status)
			health.KKUI_Border:SetVertexColor(r, g, b)
		else
			if C["General"].ColorTextures then
				health.KKUI_Border:SetVertexColor(C["General"].TexturesColor[1], C["General"].TexturesColor[2], C["General"].TexturesColor[3])
			else
				health.KKUI_Border:SetVertexColor(1, 1, 1)
			end
		end
	end
end

local function UF_OnEnter(self)
	UnitFrame_OnEnter(self)
	self.Highlight:Show()
end

local function UF_OnLeave(self)
	UnitFrame_OnLeave(self)
	self.Highlight:Hide()
end

function Module:CreateHeader(self, onKeyDown)
	local hl = self.Health:CreateTexture(nil, "OVERLAY")
	hl:SetAllPoints()
	hl:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	hl:SetTexCoord(0, 1, 0.5, 1)
	hl:SetVertexColor(0.6, 0.6, 0.6)
	hl:SetBlendMode("ADD")
	hl:Hide()
	self.Highlight = hl

	self:RegisterForClicks(onKeyDown and "AnyDown" or "AnyUp")
	self:HookScript("OnEnter", UF_OnEnter)
	self:HookScript("OnLeave", UF_OnLeave)
end

function Module:CreatePortrait(self)
	local portraitStyle = C["Unitframe"].PortraitStyle.Value
	local mystyle = self.mystyle
	local health = self.Health
	local power = self.Power

	if portraitStyle ~= "NoPortraits" then
		if portraitStyle == "OverlayPortrait" then
			local Portrait = CreateFrame("PlayerModel", "KKUI_" .. mystyle .. "Portrait", self)
			Portrait:SetFrameStrata(self:GetFrameStrata())
			Portrait:SetPoint("TOPLEFT", health, "TOPLEFT", 1, -1)
			Portrait:SetPoint("BOTTOMRIGHT", health, "BOTTOMRIGHT", -1, 1)
			Portrait:SetAlpha(0.6)

			self.Portrait = Portrait
		elseif portraitStyle == "ThreeDPortraits" then
			local Portrait = CreateFrame("PlayerModel", "KKUI_" .. mystyle .. "Portrait", health)
			Portrait:SetFrameStrata(self:GetFrameStrata())
			Portrait:SetSize(health:GetHeight() + power:GetHeight() + 6, health:GetHeight() + power:GetHeight() + 6)
			if mystyle == "target" or mystyle == "focus" or mystyle == "targetoftarget" then
				Portrait:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, 0)
			else
				Portrait:SetPoint("TOPRIGHT", self, "TOPLEFT", -6, 0)
			end
			Portrait:CreateBorder()

			self.Portrait = Portrait
		elseif portraitStyle ~= "ThreeDPortraits" and portraitStyle ~= "OverlayPortrait" then
			local Portrait = health:CreateTexture("KKUI_" .. mystyle .. "Portrait", "BACKGROUND", nil, 1)
			Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
			Portrait:SetSize(health:GetHeight() + power:GetHeight() + 6, health:GetHeight() + power:GetHeight() + 6)
			if mystyle == "target" or mystyle == "focus" or mystyle == "targetoftarget" then
				Portrait:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, 0)
			else
				Portrait:SetPoint("TOPRIGHT", self, "TOPLEFT", -6, 0)
			end

			Portrait.Border = CreateFrame("Frame", nil, self)
			Portrait.Border:SetAllPoints(Portrait)
			Portrait.Border:CreateBorder()

			if portraitStyle == "ClassPortraits" or portraitStyle == "NewClassPortraits" then
				Portrait.PostUpdate = Module.UpdateClassPortraits
			end

			self.Portrait = Portrait
		end
	end
end

function Module:CreateTargetHighlight(self)
	local portraitStyle = C["Unitframe"].PortraitStyle.Value

	local TargetHighlight = CreateFrame("Frame", nil, self.Overlay, "BackdropTemplate")
	TargetHighlight:SetBackdrop({ edgeFile = C["Media"].Borders.GlowBorder, edgeSize = 12 })
	TargetHighlight:SetFrameLevel(6)

	local relativeTo
	if self.mystyle == "raid" then
		relativeTo = self
	elseif portraitStyle == "NoPortraits" or portraitStyle == "OverlayPortrait" and TargetHighlight then
		relativeTo = self.Health
	else
		relativeTo = self.Portrait
	end

	TargetHighlight:SetPoint("TOPLEFT", relativeTo, -5, 5)
	TargetHighlight:SetPoint("BOTTOMRIGHT", relativeTo, 5, -5)
	TargetHighlight:SetBackdropBorderColor(1, 1, 0)
	TargetHighlight:Hide()

	local function UpdateTargetGlow()
		if UnitIsUnit("target", self.unit) then
			TargetHighlight:Show()
		else
			TargetHighlight:Hide()
		end
	end

	self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateTargetGlow, true)
	self:RegisterEvent("GROUP_ROSTER_UPDATE", UpdateTargetGlow, true)

	self.TargetHighlight = TargetHighlight
end

function Module:CreateDebuffHighlight(self)
	if not C["Unitframe"].DebuffHighlight then
		return
	end

	local DebuffHighlight = self.Health:CreateTexture(nil, "OVERLAY")
	DebuffHighlight:SetAllPoints()
	DebuffHighlight:SetTexture(C["Media"].Textures.BlankTexture)
	DebuffHighlight:SetVertexColor(0, 0, 0, 0)
	DebuffHighlight:SetBlendMode("ADD")

	self.DebuffHighlight = DebuffHighlight

	self.DebuffHighlightAlpha = 0.45
	self.DebuffHighlightFilter = true
end

local function createBarMover(bar, text, value, anchor)
	local mover = K.Mover(bar, text, value, anchor, bar:GetHeight() + bar:GetWidth() + 6, bar:GetHeight())
	bar:ClearAllPoints()
	bar:SetPoint("RIGHT", mover)
	bar.mover = mover
end

local function updateSpellTarget(self, _, unit)
	Module.PostCastUpdate(self.Castbar, unit)
end

function Module:ToggleCastBarLatency(frame)
	frame = frame or _G.oUF_Player
	if not frame then
		return
	end

	if C["Unitframe"].CastbarLatency then
		-- frame:RegisterEvent("GLOBAL_MOUSE_UP", Module.OnCastSent, true) -- Fix quests with WorldFrame interaction
		-- frame:RegisterEvent("GLOBAL_MOUSE_DOWN", Module.OnCastSent, true)
		frame:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", Module.OnCastSent, true)
	else
		-- frame:UnregisterEvent("GLOBAL_MOUSE_UP", Module.OnCastSent)
		-- frame:UnregisterEvent("GLOBAL_MOUSE_DOWN", Module.OnCastSent)
		frame:UnregisterEvent("CURRENT_SPELL_CAST_CHANGED", Module.OnCastSent)
		if frame.Castbar then
			frame.Castbar.__sendTime = nil
		end
	end
end

function Module:CreateCastBar(self)
	local mystyle = self.mystyle
	-- if mystyle ~= "nameplate" and not C["Unitframe"].Castbars then
	-- 	return
	-- end

	local Castbar = CreateFrame("StatusBar", "oUF_Castbar" .. mystyle, self)
	Castbar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	Castbar:SetHeight(20)
	Castbar:SetWidth(self:GetWidth() - 22)
	if mystyle == "nameplate" then
		Castbar:CreateShadow(true)
	else
		Castbar:CreateBorder()
	end

	Castbar.Spark = Castbar:CreateTexture(nil, "OVERLAY")
	Castbar.Spark:SetTexture(C["Media"].Textures.Spark128Texture)
	Castbar.Spark:SetBlendMode("ADD")
	Castbar.Spark:SetAlpha(0.9)

	if mystyle == "player" then
		Castbar:SetFrameLevel(10)
		Castbar:SetSize(C["Unitframe"].PlayerCastbarWidth, C["Unitframe"].PlayerCastbarHeight)
		createBarMover(Castbar, "Player Castbar", "PlayerCB", { "BOTTOM", UIParent, "BOTTOM", 0, 200 })

		Castbar.Spark:SetSize(64, Castbar:GetHeight())
	elseif mystyle == "target" then
		Castbar:SetFrameLevel(10)
		Castbar:SetSize(C["Unitframe"].TargetCastbarWidth, C["Unitframe"].TargetCastbarHeight)
		createBarMover(Castbar, "Target Castbar", "TargetCB", { "BOTTOM", UIParent, "BOTTOM", 0, 342 })

		Castbar.Spark:SetSize(64, Castbar:GetHeight())

		local shield = Castbar:CreateTexture(nil, "OVERLAY", nil, 4)
		shield:SetAtlas("Soulbinds_Portrait_Lock")
		shield:SetSize(C["Unitframe"].TargetCastbarHeight + 10, C["Unitframe"].TargetCastbarHeight + 10)
		shield:SetPoint("TOP", Castbar, "CENTER", 0, 6)
		Castbar.Shield = shield
		-- elseif mystyle == "focus" then
		-- 	Castbar:SetFrameLevel(10)
		-- 	Castbar:SetSize(C["Unitframe"].FocusCastbarWidth, C["Unitframe"].FocusCastbarHeight)
		-- 	createBarMover(Castbar, "Focus Castbar", "FocusCB", C.UFs.Focuscb)
		-- elseif mystyle == "boss" or mystyle == "arena" then
		-- 	Castbar:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -8)
		-- 	Castbar:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -8)
		-- 	Castbar:SetHeight(10)
	elseif mystyle == "nameplate" then
		Castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -3)
		Castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -3)
		Castbar:SetHeight(self:GetHeight())

		Castbar.Spark:SetSize(64, Castbar:GetHeight())
	end

	local timer = K.CreateFontString(Castbar, 12, "", "", false, "RIGHT", -3, 0)
	local name = K.CreateFontString(Castbar, 12, "", "", false, "LEFT", 3, 0)
	name:SetPoint("RIGHT", timer, "LEFT", -5, 0)
	name:SetJustifyH("LEFT")

	if mystyle ~= "boss" and mystyle ~= "arena" then
		Castbar.Icon = Castbar:CreateTexture(nil, "ARTWORK")
		Castbar.Icon:SetSize(Castbar:GetHeight(), Castbar:GetHeight())
		Castbar.Icon:SetPoint("BOTTOMRIGHT", Castbar, "BOTTOMLEFT", -6, 0)
		Castbar.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

		Castbar.Button = CreateFrame("Frame", nil, Castbar)
		if mystyle == "nameplate" then
			Castbar.Button:CreateShadow(true)
		else
			Castbar.Button:CreateBorder()
		end
		Castbar.Button:SetAllPoints(Castbar.Icon)
		Castbar.Button:SetFrameLevel(Castbar:GetFrameLevel())
	end

	if mystyle == "player" then
		local safeZone = Castbar:CreateTexture(nil, "OVERLAY")
		safeZone:SetTexture(K.GetTexture(C["General"].Texture))
		safeZone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
		safeZone:SetPoint("TOPRIGHT")
		safeZone:SetPoint("BOTTOMRIGHT")
		Castbar:SetFrameLevel(10)
		Castbar.SafeZone = safeZone

		local lagStr = K.CreateFontString(Castbar, 10)
		lagStr:ClearAllPoints()
		lagStr:SetPoint("BOTTOM", Castbar, "TOP", 0, 4)
		Castbar.LagString = lagStr

		Module:ToggleCastBarLatency(self)
	elseif mystyle == "nameplate" then
		name:SetPoint("TOPLEFT", Castbar, "LEFT", 0, -1)
		timer:SetPoint("TOPRIGHT", Castbar, "RIGHT", 0, -1)

		local shield = Castbar:CreateTexture(nil, "OVERLAY", nil, 4)
		shield:SetAtlas("Soulbinds_Portrait_Lock")
		shield:SetSize(self:GetHeight() + 14, self:GetHeight() + 14)
		shield:SetPoint("TOP", Castbar, "CENTER", 0, 6)
		Castbar.Shield = shield

		local iconSize = self:GetHeight() * 2 + 5
		Castbar.Icon:SetSize(iconSize, iconSize)
		Castbar.Icon:SetPoint("BOTTOMRIGHT", Castbar, "BOTTOMLEFT", -3, 0)
		Castbar.timeToHold = 0.5

		Castbar.glowFrame = CreateFrame("Frame", nil, Castbar)
		Castbar.glowFrame:SetPoint("CENTER", Castbar.Icon)
		Castbar.glowFrame:SetSize(iconSize, iconSize)

		local spellTarget = K.CreateFontString(Castbar, C["Nameplate"].NameTextSize + 2)
		spellTarget:ClearAllPoints()
		spellTarget:SetJustifyH("LEFT")
		spellTarget:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -6)
		Castbar.spellTarget = spellTarget

		self:RegisterEvent("UNIT_TARGET", updateSpellTarget)
	end

	if mystyle == "nameplate" or mystyle == "boss" or mystyle == "arena" then
		Castbar.decimal = "%.1f"
	else
		Castbar.decimal = "%.2f"
	end

	Castbar.Time = timer
	Castbar.Text = name
	Castbar.OnUpdate = Module.OnCastbarUpdate
	Castbar.PostCastStart = Module.PostCastStart
	Castbar.PostCastUpdate = Module.PostCastUpdate
	Castbar.PostCastStop = Module.PostCastStop
	Castbar.PostCastFail = Module.PostCastFailed
	Castbar.PostCastInterruptible = Module.PostUpdateInterruptible

	self.Castbar = Castbar
end

function Module:ToggleSwingBars() -- Config This!!!
	local frame = _G.oUF_Player
	if not frame then
		return
	end

	if C.db["UFs"]["SwingBar"] then
		if not frame:IsElementEnabled("Swing") then
			frame:EnableElement("Swing")
		end
	elseif frame:IsElementEnabled("Swing") then
		frame:DisableElement("Swing")
	end
end

function Module:CreateSwing(self)
	local width, height = C["Unitframe"].PlayerCastbarWidth - C["Unitframe"].PlayerCastbarHeight - 5, 13

	local bar = CreateFrame("Frame", nil, self)
	bar:SetSize(width, height)
	bar.mover = K.Mover(bar, "UFs SwingBar", "Swing", { "BOTTOM", UIParent, "BOTTOM", 0, 170 })
	bar:ClearAllPoints()
	bar:SetPoint("CENTER", bar.mover)

	local two = CreateFrame("StatusBar", nil, bar)
	two:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	two:SetStatusBarColor(0.8, 0.8, 0.8)
	two:Hide()
	two:SetAllPoints()
	two:CreateBorder()

	two.Spark = two:CreateTexture(nil, "OVERLAY")
	two.Spark:SetPoint("CENTER", two:GetStatusBarTexture(), "RIGHT", 0, 0)
	two.Spark:SetTexture(C["Media"].Textures.Spark128Texture)
	two.Spark:SetSize(64, height)
	two.Spark:SetBlendMode("ADD")
	two.Spark:SetAlpha(0.6)

	local main = CreateFrame("StatusBar", nil, bar)
	main:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	main:SetStatusBarColor(0.8, 0.8, 0.8)
	main:Hide()
	main:SetAllPoints()
	main:CreateBorder()

	main.Spark = main:CreateTexture(nil, "OVERLAY")
	main.Spark:SetPoint("CENTER", main:GetStatusBarTexture(), "RIGHT", 0, 0)
	main.Spark:SetTexture(C["Media"].Textures.Spark128Texture)
	main.Spark:SetSize(64, height)
	main.Spark:SetBlendMode("ADD")
	main.Spark:SetAlpha(0.6)

	local off = CreateFrame("StatusBar", nil, bar)
	off:Hide()
	local OffOnTop = false -- Config This!!!
	if OffOnTop then
		off:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 0, 6)
		off:SetPoint("BOTTOMRIGHT", bar, "TOPRIGHT", 0, 6)
	else
		off:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, -6)
		off:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, -6)
	end
	off:SetHeight(height)
	off:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	off:SetStatusBarColor(0.8, 0.8, 0.8)
	off:CreateBorder()

	off.Spark = off:CreateTexture(nil, "OVERLAY")
	off.Spark:SetPoint("CENTER", off:GetStatusBarTexture(), "RIGHT", 0, 0)
	off.Spark:SetTexture(C["Media"].Textures.Spark128Texture)
	off.Spark:SetSize(64, height)
	two.Spark:SetBlendMode("ADD")
	off.Spark:SetAlpha(0.6)

	bar.Text = K.CreateFontString(bar, 12, "", "")
	bar.Text:SetShown(C["Unitframe"].SwingbarTimer)
	bar.TextMH = K.CreateFontString(main, 12, "", "")
	bar.TextMH:SetShown(C["Unitframe"].SwingbarTimer)
	bar.TextOH = K.CreateFontString(off, 12, "", "")
	bar.TextOH:SetShown(C["Unitframe"].SwingbarTimer)

	self.Swing = bar
	self.Swing.Twohand = two
	self.Swing.Mainhand = main
	self.Swing.Offhand = off
	self.Swing.hideOoc = true
end

function Module:CreateIndicators(self)
	local mystyle = self.mystyle
	local overlay = self.Overlay
	if mystyle == "player" then
		local combat = self.Health:CreateTexture(nil, "OVERLAY")
		combat:SetPoint("LEFT", self.Health, "LEFT", 3, 0)
		combat:SetSize(23, 23)
		self.CombatIndicator = combat

		local rest = self.Health:CreateTexture(nil, "OVERLAY")
		rest:SetPoint("RIGHT", self.Health, "RIGHT", -3, 0)
		rest:SetSize(23, 23)
		rest:SetAlpha(0.9)
		self.RestingIndicator = rest
	elseif mystyle == "target" then
		local quest = overlay:CreateTexture(nil, "OVERLAY")
		quest:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 8)
		quest:SetSize(16, 16)
		self.QuestIndicator = quest
	end

	local phase = CreateFrame("Frame", nil, overlay)
	phase:SetSize(24, 24)
	phase:SetPoint("CENTER", self.Health)
	phase:SetFrameLevel(5)
	phase:EnableMouse(true)

	local icon = phase:CreateTexture(nil, "OVERLAY")
	icon:SetAllPoints()
	phase.Icon = icon
	self.PhaseIndicator = phase

	local ri = overlay:CreateTexture(nil, "OVERLAY")
	if mystyle == "raid" then
		ri:SetPoint("TOPRIGHT", self, 5, 5)
	else
		ri:SetPoint("TOPRIGHT", self, 0, 8)
	end
	ri:SetSize(15, 15)
	self.GroupRoleIndicator = ri

	local li = overlay:CreateTexture(nil, "OVERLAY")
	li:SetPoint("TOPLEFT", self, -1, 8)
	li:SetSize(12, 12)
	self.LeaderIndicator = li

	local ai = overlay:CreateTexture(nil, "OVERLAY")
	ai:SetPoint("TOPLEFT", self, -1, 8)
	ai:SetSize(12, 12)
	self.AssistantIndicator = ai
end

-- function Module:CreateIndicators(self)
-- 	local mystyle = self.mystyle
-- 	local portraitStyle = C["Unitframe"].PortraitStyle.Value
-- 	local health = self.Health
-- 	local power = self.Power
-- 	local overlay = self.Overlay

-- 	local LeaderIndicator = overlay:CreateTexture(nil, "OVERLAY")
-- 	LeaderIndicator:SetSize(12, 12)

-- 	local AssistantIndicator = overlay:CreateTexture(nil, "OVERLAY")
-- 	AssistantIndicator:SetSize(12, 12)

-- 	local PvPIndicator = self:CreateTexture(nil, "OVERLAY")
-- 	PvPIndicator:SetSize(30, 33)
-- 	PvPIndicator.PostUpdate = Module.PostUpdatePvPIndicator

-- 	local RaidTargetIndicator = overlay:CreateTexture(nil, "OVERLAY")
-- 	RaidTargetIndicator:SetSize(16, 16)

-- 	local ReadyCheckIndicator = overlay:CreateTexture(nil, "OVERLAY")
-- 	ReadyCheckIndicator:SetSize(self:GetHeight() - 4, self:GetHeight() - 4)

-- 	local ResurrectIndicator = overlay:CreateTexture(nil, "OVERLAY")
-- 	ResurrectIndicator:SetSize(44, 44)

-- 	if mystyle == "player" then
-- 		if portraitStyle ~= "NoPortraits" and portraitStyle ~= "OverlayPortrait" then
-- 			LeaderIndicator:SetPoint("TOPLEFT", self.Portrait, 0, 8)
-- 			AssistantIndicator:SetPoint("TOPLEFT", self.Portrait, 0, 8)
-- 			RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
-- 			ReadyCheckIndicator:SetPoint("CENTER", self.Portrait)
-- 			ResurrectIndicator:SetPoint("CENTER", self.Portrait)
-- 			if C["Unitframe"].PvPIndicator then
-- 				PvPIndicator:SetPoint("RIGHT", self.Portrait, "LEFT", -2, 0)
-- 			end
-- 		else
-- 			LeaderIndicator:SetPoint("TOPLEFT", health, 0, 8)
-- 			AssistantIndicator:SetPoint("TOPLEFT", health, 0, 8)
-- 			RaidTargetIndicator:SetPoint("TOP", health, "TOP", 0, 8)
-- 			ReadyCheckIndicator:SetPoint("CENTER", health)
-- 			ResurrectIndicator:SetPoint("CENTER", health)
-- 			if C["Unitframe"].PvPIndicator then
-- 				PvPIndicator:SetPoint("RIGHT", health, "LEFT", -2, 0)
-- 			end
-- 		end

-- 		local CombatIndicator = health:CreateTexture(nil, "OVERLAY")
-- 		CombatIndicator:SetSize(20, 20)
-- 		CombatIndicator:SetPoint("LEFT", 2, 0)

-- 		local RestingIndicator = health:CreateTexture(nil, "OVERLAY")
-- 		RestingIndicator:SetPoint("RIGHT", -2, 2)
-- 		RestingIndicator:SetSize(22, 22)

-- 		local QuestSyncIndicator = overlay:CreateTexture(nil, "OVERLAY")
-- 		if portraitStyle ~= "NoPortraits" and portraitStyle ~= "OverlayPortrait" then
-- 			QuestSyncIndicator:SetPoint("BOTTOM", self.Portrait, "BOTTOM", 0, -13)
-- 		else
-- 			QuestSyncIndicator:SetPoint("BOTTOM", health, "BOTTOM", 0, -13)
-- 		end
-- 		QuestSyncIndicator:SetSize(26, 26)
-- 		QuestSyncIndicator:SetAtlas("QuestSharing-DialogIcon")
-- 		QuestSyncIndicator:Hide()

-- 		local function updatePartySync()
-- 			local hasJoined = C_QuestSession.HasJoined()
-- 			if hasJoined then
-- 				QuestSyncIndicator:Show()
-- 			else
-- 				QuestSyncIndicator:Hide()
-- 			end
-- 		end

-- 		self:RegisterEvent("QUEST_SESSION_LEFT", updatePartySync, true)
-- 		self:RegisterEvent("QUEST_SESSION_JOINED", updatePartySync, true)
-- 		self:RegisterEvent("PLAYER_ENTERING_WORLD", updatePartySync, true)

-- 		local ThreatIndicator = {
-- 			IsObjectType = K.Noop,
-- 			Override = Module.UpdateThreat,
-- 		}

-- 		self.LeaderIndicator = LeaderIndicator
-- 		self.AssistantIndicator = AssistantIndicator
-- 		self.RaidTargetIndicator = RaidTargetIndicator
-- 		self.ReadyCheckIndicator = ReadyCheckIndicator
-- 		self.ResurrectIndicator = ResurrectIndicator
-- 		self.PvPIndicator = PvPIndicator
-- 		self.CombatIndicator = CombatIndicator
-- 		self.RestingIndicator = RestingIndicator
-- 		self.QuestSyncIndicator = QuestSyncIndicator
-- 		self.ThreatIndicator = ThreatIndicator
-- 	elseif mystyle == "target" then
-- 		if portraitStyle ~= "NoPortraits" and portraitStyle ~= "OverlayPortrait" then
-- 			LeaderIndicator:SetPoint("TOPRIGHT", self.Portrait, 0, 8)
-- 			RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
-- 			ReadyCheckIndicator:SetPoint("CENTER", self.Portrait)
-- 			ResurrectIndicator:SetPoint("CENTER", self.Portrait)
-- 			if C["Unitframe"].PvPIndicator then
-- 				PvPIndicator:SetPoint("LEFT", self.Portrait, "RIGHT", 2, 0)
-- 			end
-- 		else
-- 			LeaderIndicator:SetPoint("TOPRIGHT", health, 0, 8)
-- 			RaidTargetIndicator:SetPoint("TOP", health, "TOP", 0, 8)
-- 			ReadyCheckIndicator:SetPoint("CENTER", health)
-- 			ResurrectIndicator:SetPoint("CENTER", health)
-- 			if C["Unitframe"].PvPIndicator then
-- 				PvPIndicator:SetPoint("LEFT", health, "RIGHT", 2, 0)
-- 			end
-- 		end

-- 		local QuestIndicator = overlay:CreateTexture(nil, "OVERLAY")
-- 		QuestIndicator:SetSize(20, 20)
-- 		QuestIndicator:SetPoint("TOPLEFT", health, "TOPRIGHT", -6, 6)

-- 		local ThreatIndicator = {
-- 			IsObjectType = K.Noop,
-- 			Override = Module.UpdateThreat,
-- 		}

-- 		local Range = Module.CreateRangeIndicator(self)

-- 		self.LeaderIndicator = LeaderIndicator
-- 		self.RaidTargetIndicator = RaidTargetIndicator
-- 		self.ReadyCheckIndicator = ReadyCheckIndicator
-- 		self.ResurrectIndicator = ResurrectIndicator
-- 		self.QuestIndicator = QuestIndicator
-- 		self.ThreatIndicator = ThreatIndicator
-- 		self.Range = Range
-- 	elseif mystyle == "party" then
-- 		local StatusIndicator = power:CreateFontString(nil, "OVERLAY")
-- 		StatusIndicator:SetPoint("CENTER", 0, 0.5)
-- 		StatusIndicator:SetFontObject(K.UIFont)
-- 		StatusIndicator:SetFont(select(1, StatusIndicator:GetFont()), 10, select(3, StatusIndicator:GetFont()))
-- 		self:Tag(StatusIndicator, "[afkdnd]")

-- 		if portraitStyle == "NoPortraits" or portraitStyle == "OverlayPortrait" then
-- 			LeaderIndicator:SetPoint("TOPLEFT", health, 0, 8)
-- 			AssistantIndicator:SetPoint("TOPLEFT", health, 0, 8)
-- 			ReadyCheckIndicator:SetPoint("CENTER", self.Portrait)
-- 			RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
-- 			ResurrectIndicator:SetPoint("CENTER", self.Portrait)
-- 		else
-- 			LeaderIndicator:SetPoint("TOPLEFT", self.Portrait, 0, 8)
-- 			AssistantIndicator:SetPoint("TOPLEFT", self.Portrait, 0, 8)
-- 			ReadyCheckIndicator:SetPoint("LEFT", 0, 0)
-- 			RaidTargetIndicator:SetPoint("TOP", health, "TOP", 0, 8)
-- 			ResurrectIndicator:SetPoint("CENTER", health)
-- 		end

-- 		local PhaseIndicator = self:CreateTexture(nil, "OVERLAY")
-- 		PhaseIndicator:SetSize(20, 20)
-- 		PhaseIndicator:SetPoint("LEFT", health, "RIGHT", 4, 0)
-- 		PhaseIndicator:SetTexture([[Interface\AddOns\KkthnxUI\Media\Textures\PhaseIcons.tga]])
-- 		PhaseIndicator.PostUpdate = function(_, isPhased)
-- 			PhaseIndicator:SetTexCoord(unpack(phaseIconTexCoords[isPhased == 2 and 2 or 1]))
-- 		end

-- 		local SummonIndicator = health:CreateTexture(nil, "OVERLAY")
-- 		SummonIndicator:SetSize(20, 20)
-- 		SummonIndicator:SetPoint("LEFT", 2, 0)

-- 		local altPower = K.CreateFontString(self, 10, "")
-- 		altPower:SetPoint("LEFT", power, "RIGHT", 6, 0)
-- 		self:Tag(altPower, "[altpower]")

-- 		local ThreatIndicator = {
-- 			IsObjectType = K.Noop,
-- 			Override = Module.UpdateThreat,
-- 		}

-- 		local RangeIndicator = Module.CreateRangeIndicator(self)

-- 		self.StatusIndicator = StatusIndicator
-- 		self.LeaderIndicator = LeaderIndicator
-- 		self.AssistantIndicator = AssistantIndicator
-- 		self.ReadyCheckIndicator = ReadyCheckIndicator
-- 		self.RaidTargetIndicator = RaidTargetIndicator
-- 		self.ResurrectIndicator = ResurrectIndicator
-- 		self.PhaseIndicator = PhaseIndicator
-- 		self.SummonIndicator = SummonIndicator
-- 		self.ThreatIndicator = ThreatIndicator
-- 		self.RangeIndicator = RangeIndicator
-- 	end
-- end

function Module.auraIconSize(w, n, s)
	return (w - (n - 1) * s) / n
end

function Module:UpdateAuraContainer(width, element, maxAuras)
	local iconsPerRow = element.iconsPerRow
	local maxLines = iconsPerRow and K.Round(maxAuras / iconsPerRow) or 2
	element.size = iconsPerRow and Module.auraIconSize(width, iconsPerRow, element.spacing) or element.size
	element:SetWidth(width)
	element:SetHeight((element.size + element.spacing) * maxLines)
end

function Module.PostCreateAura(element, button)
	local fontSize = element.fontSize or element.size * 0.52
	local parentFrame = CreateFrame("Frame", nil, button)
	parentFrame:SetAllPoints()
	parentFrame:SetFrameLevel(button:GetFrameLevel() + 3)
	button.count = K.CreateFontString(parentFrame, fontSize - 1, "", "OUTLINE", false, "BOTTOMRIGHT", 6, -3)
	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	button.cd:SetReverse(true)
	button.cd:SetHideCountdownNumbers(true)
	button.icon:SetAllPoints()
	button.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	button.cd:ClearAllPoints()

	if element.__owner.mystyle == "nameplate" then
		button.cd:SetAllPoints()
		button:CreateShadow(true)
	else
		button.cd:SetPoint("TOPLEFT", 1, -1)
		button.cd:SetPoint("BOTTOMRIGHT", -1, 1)
		button:CreateBorder()
	end

	button.overlay:SetTexture(nil)
	button.stealable:SetParent(parentFrame)
	button.stealable:SetAtlas("bags-newitem")
	button:HookScript("OnMouseDown", AuraModule.RemoveSpellFromIgnoreList)

	button.timer = K.CreateFontString(parentFrame, fontSize, "", "OUTLINE")
end

Module.ReplacedSpellIcons = {
	[368078] = 348567, -- 移速
	[368079] = 348567, -- 移速
	[368103] = 648208, -- 急速
	[368243] = 237538, -- CD
	[373785] = 236293, -- S4，大魔王伪装
}

function Module.PostUpdateAura(element, _, button, _, _, duration, expiration, debuffType)
	local style = element.__owner.mystyle
	if style == "nameplate" then
		button:SetSize(element.size, element.size - 4)
	else
		button:SetSize(element.size, element.size)
	end

	if button.isDebuff and filteredStyle[style] and not button.isPlayer then
		button.icon:SetDesaturated(true)
	else
		button.icon:SetDesaturated(false)
	end

	if button.isDebuff then
		local color = oUF.colors.debuff[debuffType] or oUF.colors.debuff.none
		if style == "nameplate" and button.Shadow then
			button.Shadow:SetBackdropBorderColor(color[1], color[2], color[3], 0.8)
		else
			if C["General"].ColorTextures then
				button.KKUI_Border:SetVertexColor(C["General"].TexturesColor[1], C["General"].TexturesColor[2], C["General"].TexturesColor[3])
			else
				button.KKUI_Border:SetVertexColor(color[1], color[2], color[3])
			end
		end
	else
		if style == "nameplate" and button.Shadow then
			button.Shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
		elseif C["General"].ColorTextures then
			button.KKUI_Border:SetVertexColor(C["General"].TexturesColor[1], C["General"].TexturesColor[2], C["General"].TexturesColor[3])
		else
			button.KKUI_Border:SetVertexColor(1, 1, 1)
		end
	end

	if duration and duration > 0 then
		button.expiration = expiration
		button:SetScript("OnUpdate", K.CooldownOnUpdate)
		button.timer:Show()
	else
		button:SetScript("OnUpdate", nil)
		button.timer:Hide()
	end

	local newTexture = Module.ReplacedSpellIcons[button.spellID]
	if newTexture then
		button.icon:SetTexture(newTexture)
	end
end

function Module.bolsterPreUpdate(element)
	element.bolster = 0
	element.bolsterIndex = nil
end

function Module.bolsterPostUpdate(element)
	if not element.bolsterIndex then
		return
	end

	for _, button in pairs(element) do
		if button == element.bolsterIndex then
			button.count:SetText(element.bolster)
			return
		end
	end
end

local isCasterPlayer = {
	["player"] = true,
	["pet"] = true,
	["vehicle"] = true,
}

function Module.CustomFilter(element, unit, button, name, _, _, _, _, _, caster, isStealable, _, spellID, _, _, _, nameplateShowAll)
	local style = element.__owner.mystyle
	if name and spellID == 209859 then
		element.bolster = element.bolster + 1
		if not element.bolsterIndex then
			element.bolsterIndex = button
			return true
		end
	elseif style == "nameplate" or style == "boss" or style == "arena" then
		if element.__owner.plateType == "NameOnly" then
			return C.NameplateWhiteList[spellID]
		elseif C.NameplateBlackList[spellID] then
			return false
		elseif element.showStealableBuffs and isStealable and not UnitIsPlayer(unit) then
			return true
		elseif C.NameplateWhiteList[spellID] then
			return true
		else
			local auraFilter = C["Nameplate"].AuraFilter.Value
			return (auraFilter == 3 and nameplateShowAll) or (auraFilter ~= 1 and isCasterPlayer[caster])
		end
	else
		return (element.onlyShowPlayer and button.isPlayer) or (not element.onlyShowPlayer and name)
	end
end

-- Post Update Runes
local function OnUpdateRunes(self, elapsed)
	local duration = self.duration + elapsed
	self.duration = duration
	self:SetValue(duration)

	if self.timer then
		local remain = self.runeDuration - duration
		if remain > 0 then
			self.timer:SetText(K.FormatTime(remain))
		else
			self.timer:SetText(nil)
		end
	end
end

function Module.PostUpdateRunes(element, runemap)
	for index, runeID in next, runemap do
		local rune = element[index]
		local start, duration, runeReady = GetRuneCooldown(runeID)
		if rune:IsShown() then
			if runeReady then
				rune:SetAlpha(1)
				rune:SetScript("OnUpdate", nil)
				if rune.timer then
					rune.timer:SetText(nil)
				end
			elseif start then
				rune:SetAlpha(0.6)
				rune.runeDuration = duration
				rune:SetScript("OnUpdate", OnUpdateRunes)
			end
		end
	end
end

function Module.PostUpdateClassPower(element, cur, max, diff, powerType, chargedPowerPoints)
	if not cur or cur == 0 then
		element.prevColor = nil
	else
		element.thisColor = cur == max and 1 or 2
		if not element.prevColor or element.prevColor ~= element.thisColor then
			local r, g, b = 1, 0, 0
			if element.thisColor == 2 then
				local color = element.__owner.colors.power[powerType]
				r, g, b = color[1], color[2], color[3]
			end
			for i = 1, #element do
				element[i]:SetStatusBarColor(r, g, b)
			end
			element.prevColor = element.thisColor
		end
	end

	if diff then
		for i = 1, max do
			element[i]:SetWidth((element.__owner.ClassPowerBar:GetWidth() - (max - 1) * 6) / max)
		end
	end

	for i = 1, 6 do
		local bar = element[i]
		if not bar.chargeStar then
			break
		end

		bar.chargeStar:SetShown(chargedPowerPoints and tContains(chargedPowerPoints, i))
	end
end

function Module:CreateClassPower(self)
	local barWidth = C["Unitframe"].PlayerHealthWidth
	local barHeight = 14
	local barPoint = { "BOTTOMLEFT", self, "TOPLEFT", 0, 6 }
	if self.mystyle == "PlayerPlate" then
		barWidth = C["Nameplate"].PlateWidth
		barHeight = C["Nameplate"].PlateHeight
		barPoint = { "BOTTOMLEFT", self, "TOPLEFT", 0, 6 }
	elseif self.mystyle == "targetplate" then
		barWidth = C["Nameplate"].PlateWidth
		barHeight = C["Nameplate"].PlateHeight - 2
		barPoint = { "CENTER", self }
	end

	local bar = CreateFrame("Frame", "$parentClassPowerBar", self)
	bar:SetSize(barWidth, barHeight)
	bar:SetPoint(unpack(barPoint))

	local bars = {}
	for i = 1, 6 do
		bars[i] = CreateFrame("StatusBar", nil, bar)
		bars[i]:SetHeight(barHeight)
		bars[i]:SetWidth((barWidth - 5 * 6) / 6)
		bars[i]:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
		bars[i]:SetFrameLevel(self:GetFrameLevel() + 5)
		if self.mystyle == "PlayerPlate" or self.mystyle == "targetplate" then
			bars[i]:CreateShadow(true)
		else
			bars[i]:CreateBorder()
		end

		if i == 1 then
			bars[i]:SetPoint("BOTTOMLEFT")
		else
			bars[i]:SetPoint("LEFT", bars[i - 1], "RIGHT", 6, 0)
		end

		if K.Class == "DEATHKNIGHT" then
			bars[i].timer = K.CreateFontString(bars[i], 10, "")
		elseif K.Class == "ROGUE" then
			if not bar.chargeParent then
				bar.chargeParent = CreateFrame("Frame", nil, bar)
				bar.chargeParent:SetAllPoints()
				bar.chargeParent:SetFrameLevel(8)
			end

			local chargeStar = bar.chargeParent:CreateTexture()
			chargeStar:SetAtlas("VignetteKill")
			chargeStar:SetDesaturated(true)
			chargeStar:SetSize(22, 22)
			chargeStar:SetPoint("CENTER", bars[i])
			chargeStar:Hide()

			bars[i].chargeStar = chargeStar
		end
	end

	if K.Class == "DEATHKNIGHT" then
		bars.colorSpec = true
		bars.sortOrder = "asc"
		bars.PostUpdate = Module.PostUpdateRunes
		bars.__max = 6
		self.Runes = bars
	else
		bars.PostUpdate = Module.PostUpdateClassPower
		self.ClassPower = bars
	end

	self.ClassPowerBar = bar
end

local textScaleFrames = {
	["player"] = true,
	["target"] = true,
}

function Module:UpdateTextScale()
	local scale = C["Unitframe"].AllTextScale
	for _, frame in pairs(oUF.objects) do
		local style = frame.mystyle
		if style and textScaleFrames[style] then
			if frame.Name then
				frame.Name:SetScale(scale)
			end

			if frame.Level then
				frame.Level:SetScale(scale)
			end

			frame.Health.Value:SetScale(scale)

			if frame.Power.Value then
				frame.Power.Value:SetScale(scale)
			end

			local castbar = frame.Castbar
			if castbar then
				castbar.Text:SetScale(scale)
				castbar.Time:SetScale(scale)
				if castbar.Lag then
					castbar.Lag:SetScale(scale)
				end
			end
		end
	end
end

function Module:CreatePrediction(self)
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

local scrolls = {}
function Module:UpdateScrollingFont()
	local fontSize = 16
	for _, scroll in pairs(scrolls) do
		scroll:SetFont(select(1, _G.KkthnxUIFontOutline:GetFont()), fontSize, "OUTLINE")
		scroll:SetSize(10 * fontSize, 10 * fontSize)
	end
end

function Module:CreateFCT(self)
	if not C["Unitframe"].CombatText then
		return
	end

	local parentFrame = CreateFrame("Frame", nil, UIParent)
	local parentName = self:GetName()
	local fcf = CreateFrame("Frame", parentName .. "CombatTextFrame", parentFrame)
	fcf:SetSize(32, 32)
	if self.mystyle == "player" then
		K.Mover(fcf, "CombatText", "PlayerCombatText", { "BOTTOM", self, "TOPLEFT", 0, 120 })
	else
		K.Mover(fcf, "CombatText", "TargetCombatText", { "BOTTOM", self, "TOPRIGHT", 0, 120 })
	end

	for i = 1, 36 do
		fcf[i] = parentFrame:CreateFontString("$parentText", "OVERLAY")
	end

	local scrolling = CreateFrame("ScrollingMessageFrame", parentName .. "CombatTextScrollingFrame", parentFrame)
	scrolling:SetSpacing(3)
	scrolling:SetMaxLines(20)
	scrolling:SetFadeDuration(0.2)
	scrolling:SetTimeVisible(3)
	scrolling:SetJustifyH("CENTER")
	scrolling:SetPoint("BOTTOM", fcf)
	fcf.Scrolling = scrolling
	tinsert(scrolls, scrolling)

	fcf.font = select(1, _G.KkthnxUIFontOutline:GetFont())
	fcf.fontFlags = select(3, _G.KkthnxUIFontOutline:GetFont())
	fcf.abbreviateNumbers = true
	self.FloatingCombatFeedback = fcf

	-- Default CombatText
	SetCVar("enableFloatingCombatText", 0)
	K.HideInterfaceOption(InterfaceOptionsCombatPanelEnableFloatingCombatText)
end

function Module:CreateUnits()
	local horizonRaid = C["Raid"].HorizonRaid
	local numGroups = C["Raid"].NumGroups
	local raidWidth, raidHeight = C["Raid"].Width, C["Raid"].Height
	local reverse = C["Raid"].ReverseRaid
	local showPartyFrame = C["Party"].Enable
	local showTeamIndex = C["Raid"].ShowTeamIndex

	if C["Nameplate"].Enable then
		Module:SetupCVars()
		Module:BlockAddons()
		Module:CreateUnitTable()
		Module:CreatePowerUnitTable()
		Module:CheckExplosives()
		Module:UpdateGroupRoles()
		Module:QuestIconCheck()
		Module:RefreshPlateOnFactionChanged()
		Module:RefreshMajorSpells()

		oUF:RegisterStyle("Nameplates", Module.CreatePlates)
		oUF:SetActiveStyle("Nameplates")
		oUF:SpawnNamePlates("oUF_NPs", Module.PostUpdatePlates)
	end

	do -- Playerplate-like PlayerFrame
		oUF:RegisterStyle("PlayerPlate", Module.CreatePlayerPlate)
		oUF:SetActiveStyle("PlayerPlate")
		local plate = oUF:Spawn("player", "oUF_PlayerPlate", true)
		plate.mover = K.Mover(plate, "PlayerPlate", "PlayerPlate", { "BOTTOM", UIParent, "BOTTOM", 0, 300 })
		Module:TogglePlayerPlate()
	end

	do -- Fake nameplate for target class power
		oUF:RegisterStyle("TargetPlate", Module.CreateTargetPlate)
		oUF:SetActiveStyle("TargetPlate")
		oUF:Spawn("player", "oUF_TargetPlate", true)
		Module:ToggleTargetClassPower()
	end

	if C["Unitframe"].Enable then
		oUF:RegisterStyle("Player", Module.CreatePlayer)
		oUF:RegisterStyle("Target", Module.CreateTarget)
		oUF:RegisterStyle("ToT", Module.CreateTargetOfTarget)
		oUF:RegisterStyle("Focus", Module.CreateFocus)
		oUF:RegisterStyle("FocusTarget", Module.CreateFocusTarget)
		oUF:RegisterStyle("Pet", Module.CreatePet)

		oUF:SetActiveStyle("Player")
		local Player = oUF:Spawn("player", "oUF_Player")
		local PlayerFrameHeight = C["Unitframe"].PlayerHealthHeight + C["Unitframe"].PlayerPowerHeight + 6
		local PlayerFrameWidth = C["Unitframe"].PlayerHealthWidth
		Player:SetSize(PlayerFrameWidth, PlayerFrameHeight)
		K.Mover(Player, "PlayerUF", "PlayerUF", { "BOTTOM", UIParent, "BOTTOM", -250, 320 }, PlayerFrameWidth, PlayerFrameHeight)

		oUF:SetActiveStyle("Target")
		local Target = oUF:Spawn("target", "oUF_Target")
		local TargetFrameHeight = C["Unitframe"].TargetHealthHeight + C["Unitframe"].TargetPowerHeight + 6
		local TargetFrameWidth = C["Unitframe"].TargetHealthWidth
		Target:SetSize(TargetFrameWidth, TargetFrameHeight)
		K.Mover(Target, "TargetUF", "TargetUF", { "BOTTOM", UIParent, "BOTTOM", 250, 320 }, TargetFrameWidth, TargetFrameHeight)

		if not C["Unitframe"].HideTargetofTarget then
			oUF:SetActiveStyle("ToT")
			local TargetOfTarget = oUF:Spawn("targettarget", "oUF_ToT")
			local TargetOfTargetFrameHeight = C["Unitframe"].TargetTargetHealthHeight + C["Unitframe"].TargetTargetPowerHeight + 6
			local TargetOfTargetFrameWidth = C["Unitframe"].TargetTargetHealthWidth
			TargetOfTarget:SetSize(TargetOfTargetFrameWidth, TargetOfTargetFrameHeight)
			K.Mover(TargetOfTarget, "TotUF", "TotUF", { "TOPLEFT", Target, "BOTTOMRIGHT", 6, -6 }, TargetOfTargetFrameWidth, TargetOfTargetFrameHeight)
		end

		oUF:SetActiveStyle("Pet")
		local Pet = oUF:Spawn("pet", "oUF_Pet")
		local PetFrameHeight = C["Unitframe"].PetHealthHeight + C["Unitframe"].PetPowerHeight + 6
		local PetFrameWidth = C["Unitframe"].PetHealthWidth
		Pet:SetSize(PetFrameWidth, PetFrameHeight)
		K.Mover(Pet, "Pet", "Pet", { "TOPRIGHT", Player, "BOTTOMLEFT", -6, -6 }, PetFrameWidth, PetFrameHeight)
		if C["Unitframe"].CombatFade and Player and not InCombatLockdown() then
			Pet:SetParent(Player)
		end

		oUF:SetActiveStyle("Focus")
		local Focus = oUF:Spawn("focus", "oUF_Focus")
		local FocusFrameHeight = C["Unitframe"].FocusHealthHeight + C["Unitframe"].FocusPowerHeight + 6
		local FocusFrameWidth = C["Unitframe"].FocusHealthWidth
		Focus:SetSize(FocusFrameWidth, FocusFrameHeight)
		K.Mover(Focus, "FocusUF", "FocusUF", { "BOTTOMRIGHT", Player, "TOPLEFT", -60, 200 }, FocusFrameWidth, FocusFrameHeight)

		if not C["Unitframe"].HideFocusTarget then
			oUF:SetActiveStyle("FocusTarget")
			local FocusTarget = oUF:Spawn("focustarget", "oUF_FocusTarget")
			local FocusTargetFrameHeight = C["Unitframe"].FocusTargetHealthHeight + C["Unitframe"].FocusTargetPowerHeight + 6
			local FoucsTargetFrameWidth = C["Unitframe"].FocusTargetHealthWidth
			FocusTarget:SetSize(FoucsTargetFrameWidth, FocusTargetFrameHeight)
			K.Mover(FocusTarget, "FocusTarget", "FocusTarget", { "TOPLEFT", Focus, "BOTTOMRIGHT", 6, -6 }, FoucsTargetFrameWidth, FocusTargetFrameHeight)
		end

		K.HideInterfaceOption(InterfaceOptionsCombatPanelTargetOfTarget)
		K:RegisterEvent("PLAYER_TARGET_CHANGED", Module.PLAYER_TARGET_CHANGED)
		K:RegisterEvent("PLAYER_FOCUS_CHANGED", Module.PLAYER_FOCUS_CHANGED)
		K:RegisterEvent("UNIT_FACTION", Module.UNIT_FACTION)

		Module:UpdateTextScale()
	end

	if C["Boss"].Enable then
		oUF:RegisterStyle("Boss", Module.CreateBoss)
		oUF:SetActiveStyle("Boss")

		local Boss = {}
		for i = 1, MAX_BOSS_FRAMES do
			Boss[i] = oUF:Spawn("boss" .. i, "oUF_Boss" .. i)
			Boss[i]:SetSize(C["Boss"].HealthWidth, C["Boss"].HealthHeight + C["Boss"].PowerHeight + 6)

			local bossMoverWidth, bossMoverHeight = C["Boss"].HealthWidth, C["Boss"].HealthHeight + C["Boss"].PowerHeight + 6
			if i == 1 then
				Boss[i].mover = K.Mover(Boss[i], "BossFrame" .. i, "Boss1", { "BOTTOMRIGHT", UIParent, "RIGHT", -250, 140 }, bossMoverWidth, bossMoverHeight)
			else
				Boss[i].mover = K.Mover(Boss[i], "BossFrame" .. i, "Boss" .. i, { "TOPLEFT", Boss[i - 1], "BOTTOMLEFT", 0, -C["Boss"].YOffset }, bossMoverWidth, bossMoverHeight)
			end
		end
	end

	if C["Arena"].Enable then
		oUF:RegisterStyle("Arena", Module.CreateArena)
		oUF:SetActiveStyle("Arena")

		local Arena = {}
		for i = 1, 5 do
			Arena[i] = oUF:Spawn("arena" .. i, "oUF_Arena" .. i)
			Arena[i]:SetSize(C["Arena"].HealthWidth, C["Arena"].HealthHeight + C["Arena"].PowerHeight + 6)

			local arenaMoverWidth, arenaMoverHeight = C["Arena"].HealthWidth, C["Arena"].HealthHeight + C["Arena"].PowerHeight + 6
			if i == 1 then
				Arena[i].mover = K.Mover(Arena[i], "ArenaFrame" .. i, "Arena1", { "BOTTOMRIGHT", UIParent, "RIGHT", -250, 140 }, arenaMoverWidth, arenaMoverHeight)
			else
				Arena[i].mover = K.Mover(Arena[i], "ArenaFrame" .. i, "Arena" .. i, { "TOPLEFT", Arena[i - 1], "BOTTOMLEFT", 0, -C["Arena"].YOffset }, arenaMoverWidth, arenaMoverHeight)
			end
		end

		SetCVar("showArenaEnemyFrames", 0) -- Why these still load and show is dumb.
	end

	local partyMover
	if showPartyFrame then
		oUF:RegisterStyle("Party", Module.CreateParty)
		oUF:SetActiveStyle("Party")

		local partyXOffset, partyYOffset = 6, C["Party"].ShowBuffs and 52 or 28
		local partyMoverWidth = C["Party"].HealthWidth
		local partyMoverHeight = C["Party"].HealthHeight + C["Party"].PowerHeight + 1 + partyYOffset * 8
		local partyGroupingOrder = "NONE,DAMAGER,HEALER,TANK"

		-- stylua: ignore
		local party = oUF:SpawnHeader(
			"oUF_Party", nil, "solo,party",
			"showPlayer", C["Party"].ShowPlayer,
			"showSolo", C["Party"].ShowPartySolo,
			"showParty", true,
			"showRaid", false,
			"xoffset", partyXOffset,
			"yOffset", partyYOffset,
			"groupFilter", "1",
			"groupingOrder", partyGroupingOrder,
			"groupBy", "ASSIGNEDROLE",
			"sortMethod", "NAME",
			"point", "BOTTOM",
			"columnAnchorPoint", "LEFT",
			"oUF-initialConfigFunction", ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
			]]):format(C["Party"].HealthWidth, C["Party"].HealthHeight + C["Party"].PowerHeight + 6)
		)

		partyMover = K.Mover(party, "PartyFrame", "PartyFrame", { "TOPLEFT", UIParent, "TOPLEFT", 46, -200 }, partyMoverWidth, partyMoverHeight)
		party:ClearAllPoints()
		party:SetPoint("TOPLEFT", partyMover)

		if C["Party"].ShowPet then
			oUF:RegisterStyle("PartyPet", Module.CreatePartyPet)
			oUF:SetActiveStyle("PartyPet")

			local partypetXOffset, partypetYOffset = 6, 25
			local partpetMoverWidth = 60
			local partpetMoverHeight = 34 * 5 + partypetYOffset * 4

			-- stylua: ignore
			local partyPet = oUF:SpawnHeader(
				"oUF_PartyPet", nil, "solo,party",
				"showPlayer", true,
				"showSolo", false,
				"showParty", true,
				"showRaid", false,
				"xoffset", partypetXOffset,
				"yOffset", partypetYOffset,
				"point", "BOTTOM",
				"columnAnchorPoint", "LEFT",
				"oUF-initialConfigFunction", ([[
					self:SetWidth(%d)
					self:SetHeight(%d)
					self:SetAttribute("unitsuffix", "pet")
				]]):format(60, 34)
			)

			local moverAnchor = { "TOPLEFT", partyMover, "TOPRIGHT", 6, -40 }
			local petMover = K.Mover(partyPet, "PartyPetFrame", "PartyPetFrame", moverAnchor, partpetMoverWidth, partpetMoverHeight)
			partyPet:ClearAllPoints()
			partyPet:SetPoint("TOPLEFT", petMover)
		end
	end

	if C["Raid"].Enable then
		SetCVar("predictedHealth", 1)
		oUF:RegisterStyle("Raid", Module.CreateRaid)
		oUF:SetActiveStyle("Raid")

		-- Hide Default RaidFrame
		if _G.CompactRaidFrameManager_SetSetting then
			_G.CompactRaidFrameManager_SetSetting("IsShown", "0")
			UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")
			_G.CompactRaidFrameManager:UnregisterAllEvents()
			_G.CompactRaidFrameManager:SetParent(K.UIFrameHider)
		end

		local raidMover
		-- stylua: ignore
		local function CreateGroup(name, i)
			local group = oUF:SpawnHeader(
				name, nil, "solo,party,raid",
				"showPlayer", true,
				"showSolo", not showPartyFrame and C["Raid"].ShowRaidSolo,
				"showParty", not showPartyFrame,
				"showRaid", true,
				"xoffset", 6,
				"yOffset", -6,
				"groupFilter", tostring(i),
				"groupingOrder", "1,2,3,4,5,6,7,8",
				"groupBy", "GROUP",
				"sortMethod", "INDEX",
				"maxColumns", 1,
				"unitsPerColumn", 5,
				"columnSpacing", 5,
				"point", horizonRaid and "LEFT" or "TOP",
				"columnAnchworPoint", "LEFT",
				"oUF-initialConfigFunction", ([[
					self:SetWidth(%d)
					self:SetHeight(%d)
				]]):format(raidWidth, raidHeight)
			)

			return group
		end

		local function CreateTeamIndex(header)
			local parent = _G[header:GetName() .. "UnitButton1"]
			if parent and not parent.teamIndex then
				local teamIndex = K.CreateFontString(parent, 11, string_format(_G.GROUP_NUMBER, header.index), "")
				teamIndex:ClearAllPoints()
				teamIndex:SetPoint("BOTTOM", parent, "TOP", 0, 3)
				teamIndex:SetTextColor(255 / 255, 204 / 255, 102 / 255)

				parent.teamIndex = teamIndex
			end
		end

		local groups = {}
		for i = 1, numGroups do
			groups[i] = CreateGroup("oUF_Raid" .. i, i)
			groups[i].index = i

			if i == 1 then
				if horizonRaid then
					raidMover = K.Mover(groups[i], "RaidFrame", "RaidFrame", { "TOPLEFT", UIParent, "TOPLEFT", 4, -180 }, (raidWidth + 5) * 5, (raidHeight + (showTeamIndex and 15 or 5)) * numGroups)
					if reverse then
						groups[i]:ClearAllPoints()
						groups[i]:SetPoint("BOTTOMLEFT", raidMover)
					end
				else
					raidMover = K.Mover(groups[i], "RaidFrame", "RaidFrame", { "TOPLEFT", UIParent, "TOPLEFT", 4, -180 }, (raidWidth + 5) * numGroups, (raidHeight + 5) * 5)
					if reverse then
						groups[i]:ClearAllPoints()
						groups[i]:SetPoint("TOPRIGHT", raidMover)
					end
				end
			else
				if horizonRaid then
					if reverse then
						groups[i]:SetPoint("BOTTOMLEFT", groups[i - 1], "TOPLEFT", 0, showTeamIndex and 18 or 6)
					else
						groups[i]:SetPoint("TOPLEFT", groups[i - 1], "BOTTOMLEFT", 0, showTeamIndex and -18 or -6)
					end
				else
					if reverse then
						groups[i]:SetPoint("TOPRIGHT", groups[i - 1], "TOPLEFT", -6, 0)
					else
						groups[i]:SetPoint("TOPLEFT", groups[i - 1], "TOPRIGHT", 6, 0)
					end
				end
			end

			if showTeamIndex then
				CreateTeamIndex(groups[i])
				groups[i]:HookScript("OnShow", CreateTeamIndex)
			end
		end

		if C["Raid"].MainTankFrames then
			oUF:RegisterStyle("MainTank", Module.CreateRaid)
			oUF:SetActiveStyle("MainTank")

			local horizonTankRaid = C["Raid"].HorizonRaid
			local raidTankWidth, raidTankHeight = C["Raid"].Width, C["Raid"].Height
			-- stylua: ignore
			local raidtank = oUF:SpawnHeader(
				"oUF_MainTank", nil, "raid",
				"showRaid", true,
				"xoffset", 6,
				"yOffset", -6,
				"groupFilter", "MAINTANK",
				"point", horizonTankRaid and "LEFT" or "TOP",
				"columnAnchworPoint", "LEFT",
				"template", C["Raid"].MainTankFrames and "oUF_MainTankTT" or "oUF_MainTank",
				"oUF-initialConfigFunction", ([[
					self:SetWidth(%d)
					self:SetHeight(%d)
				]]):format(raidTankWidth, raidTankHeight)
			)

			local raidtankMover = K.Mover(raidtank, "MainTankFrame", "MainTankFrame", { "TOPLEFT", UIParent, "TOPLEFT", 4, -50 }, raidTankWidth, raidTankHeight)
			raidtank:ClearAllPoints()
			raidtank:SetPoint("TOPLEFT", raidtankMover)
		end
	end
end

function Module:UpdateRaidDebuffIndicator()
	local ORD = K.oUF_RaidDebuffs or oUF_RaidDebuffs

	if ORD then
		local _, InstanceType = IsInInstance()

		ORD:ResetDebuffData()

		if InstanceType == "party" or InstanceType == "raid" then
			if C["Raid"].DebuffWatchDefault then
				ORD:RegisterDebuffs(C["DebuffsTracking_PvE"].spells)
			end

			ORD:RegisterDebuffs(KkthnxUIDB.Variables[K.Realm][K.Name].Tracking.PvE)
		else
			if C["Raid"].DebuffWatchDefault then
				ORD:RegisterDebuffs(C["DebuffsTracking_PvP"].spells)
			end

			ORD:RegisterDebuffs(KkthnxUIDB.Variables[K.Realm][K.Name].Tracking.PvP)
		end
	end
end

local function CreateTargetSound(_, unit)
	if UnitExists(unit) then
		if UnitIsEnemy("player", unit) then
			PlaySound(SOUNDKIT.IG_CREATURE_AGGRO_SELECT)
		elseif UnitIsFriend("player", unit) then
			PlaySound(SOUNDKIT.IG_CHARACTER_NPC_SELECT)
		else
			PlaySound(SOUNDKIT.IG_CREATURE_NEUTRAL_SELECT)
		end
	else
		PlaySound(SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT)
	end
end

function Module:PLAYER_FOCUS_CHANGED()
	CreateTargetSound(_, "focus")
end

function Module:PLAYER_TARGET_CHANGED()
	CreateTargetSound(_, "target")
end

function Module:UNIT_FACTION(unit)
	if unit ~= "player" then
		return
	end

	local isPvP = not not (UnitIsPVPFreeForAll("player") or UnitIsPVP("player"))
	if isPvP and not lastPvPSound then
		PlaySound(SOUNDKIT.IG_PVP_UPDATE)
	end

	lastPvPSound = isPvP
end

function Module:OnEnable()
	-- Register our units / layout
	self:CreateUnits()

	if C["Raid"].DebuffWatch then
		local ORD = K.oUF_RaidDebuffs or oUF_RaidDebuffs
		local RaidDebuffs = CreateFrame("Frame")

		RaidDebuffs:RegisterEvent("PLAYER_ENTERING_WORLD")
		RaidDebuffs:SetScript("OnEvent", Module.UpdateRaidDebuffIndicator)

		if ORD then
			ORD.ShowDispellableDebuff = true
			ORD.FilterDispellableDebuff = true
			ORD.MatchBySpellName = false
		end

		self:CreateTracking()
	end
end
