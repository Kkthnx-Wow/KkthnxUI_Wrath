local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Unitframes")

local _G = _G
local format = _G.format
local min = _G.min

local GetTime = _G.GetTime
local IsPlayerSpell = _G.IsPlayerSpell
local UnitExists = _G.UnitExists
local UnitInVehicle = _G.UnitInVehicle
local UnitIsUnit = _G.UnitIsUnit
local UnitName = _G.UnitName
local YOU = _G.YOU

local ticks = {}
local channelingTicks = {
	-- Death Knight
	[42650] = 8, -- Army of the Dead
	--Druid
	[740] = 4, -- Tranquility (Rank 1)
	[8918] = 4, -- Tranquility (Rank 2)
	[9862] = 4, -- Tranquility (Rank 3)
	[9863] = 4, -- Tranquility (Rank 4)
	[26983] = 4, -- Tranquility (Rank 5)
	[48446] = 4, -- Tranquility (Rank 6)
	[48447] = 4, -- Tranquility (Rank 7)
	[16914] = 10, -- Hurricane (Rank 1)
	[17401] = 10, -- Hurricane (Rank 2)
	[17402] = 10, -- Hurricane (Rank 3)
	[27012] = 10, -- Hurricane (Rank 4)
	[48467] = 10, -- Hurricane (Rank 5)
	--Hunter
	[1510] = 6, -- Volley (Rank 1)
	[14294] = 6, -- Volley (Rank 2)
	[14295] = 6, -- Volley (Rank 3)
	[27022] = 6, -- Volley (Rank 4)
	[58431] = 6, -- Volley (Rank 5)
	[58434] = 6, -- Volley (Rank 6)
	-- Mage
	[10] = 8, -- Blizzard (Rank 1)
	[6141] = 8, -- Blizzard (Rank 2)
	[8427] = 8, -- Blizzard (Rank 3)
	[10185] = 8, -- Blizzard (Rank 4)
	[10186] = 8, -- Blizzard (Rank 5)
	[10187] = 8, -- Blizzard (Rank 6)
	[27085] = 8, -- Blizzard (Rank 7)
	[42939] = 8, -- Blizzard (Rank 8)
	[42940] = 8, -- Blizzard (Rank 9)
	[5143] = 3, -- Arcane Missiles (Rank 1)
	[5144] = 4, -- Arcane Missiles (Rank 2)
	[5145] = 5, -- Arcane Missiles (Rank 3)
	[8416] = 5, -- Arcane Missiles (Rank 4)
	[8417] = 5, -- Arcane Missiles (Rank 5)
	[10211] = 5, -- Arcane Missiles (Rank 6)
	[10212] = 5, -- Arcane Missiles (Rank 7)
	[25345] = 5, -- Arcane Missiles (Rank 8)
	[27075] = 5, -- Arcane Missiles (Rank 9)
	[38699] = 5, -- Arcane Missiles (Rank 10)
	[38704] = 5, -- Arcane Missiles (Rank 11)
	[42843] = 5, -- Arcane Missiles (Rank 12)
	[42846] = 5, -- Arcane Missiles (Rank 13)
	[12051] = 4, -- Evocation
	-- Priest
	[15407] = 3, -- Mind Flay (Rank 1)
	[17311] = 3, -- Mind Flay (Rank 2)
	[17312] = 3, -- Mind Flay (Rank 3)
	[17313] = 3, -- Mind Flay (Rank 4)
	[17314] = 3, -- Mind Flay (Rank 5)
	[18807] = 3, -- Mind Flay (Rank 6)
	[25387] = 3, -- Mind Flay (Rank 7)
	[48155] = 3, -- Mind Flay (Rank 8)
	[48156] = 3, -- Mind Flay (Rank 9)
	[64843] = 4, -- Divine Hymn
	[64901] = 4, -- Hymn of Hope -- TODO: Accurate without glyph - with glyph it is 5 ticks
	[48045] = 5, -- Mind Sear (Rank 1)
	[53023] = 5, -- Mind Sear (Rank 2)
	[47540] = 2, -- Penance (Rank 1) (Dummy)
	[47750] = 2, -- Penance (Rank 1) (Heal A)
	[47757] = 2, -- Penance (Rank 1) (Heal B)
	[47666] = 2, -- Penance (Rank 1) (DPS A)
	[47758] = 2, -- Penance (Rank 1) (DPS B)
	[53005] = 2, -- Penance (Rank 2) (Dummy)
	[52983] = 2, -- Penance (Rank 2) (Heal A)
	[52986] = 2, -- Penance (Rank 2) (Heal B)
	[52998] = 2, -- Penance (Rank 2) (DPS A)
	[53001] = 2, -- Penance (Rank 2) (DPS B)
	[53006] = 2, -- Penance (Rank 3) (Dummy)
	[52984] = 2, -- Penance (Rank 3) (Heal A)
	[52987] = 2, -- Penance (Rank 3) (Heal B)
	[52999] = 2, -- Penance (Rank 3) (DPS A)
	[53002] = 2, -- Penance (Rank 3) (DPS B)
	[53007] = 2, -- Penance (Rank 4) (Dummy)
	[52985] = 2, -- Penance (Rank 4) (Heal A)
	[52988] = 2, -- Penance (Rank 4) (Heal B)
	[53000] = 2, -- Penance (Rank 4) (DPS A)
	[53003] = 2, -- Penance (Rank 4) (DPS B)
	-- Warlock
	[1120] = 5, -- Drain Soul (Rank 1)
	[8288] = 5, -- Drain Soul (Rank 2)
	[8289] = 5, -- Drain Soul (Rank 3)
	[11675] = 5, -- Drain Soul (Rank 4)
	[27217] = 5, -- Drain Soul (Rank 5)
	[47855] = 5, -- Drain Soul (Rank 6)
	[755] = 10, -- Health Funnel (Rank 1)
	[3698] = 10, -- Health Funnel (Rank 2)
	[3699] = 10, -- Health Funnel (Rank 3)
	[3700] = 10, -- Health Funnel (Rank 4)
	[11693] = 10, -- Health Funnel (Rank 5)
	[11694] = 10, -- Health Funnel (Rank 6)
	[11695] = 10, -- Health Funnel (Rank 7)
	[27259] = 10, -- Health Funnel (Rank 8)
	[47856] = 10, -- Health Funnel (Rank 9)
	[689] = 5, -- Drain Life (Rank 1)
	[699] = 5, -- Drain Life (Rank 2)
	[709] = 5, -- Drain Life (Rank 3)
	[7651] = 5, -- Drain Life (Rank 4)
	[11699] = 5, -- Drain Life (Rank 5)
	[11700] = 5, -- Drain Life (Rank 6)
	[27219] = 5, -- Drain Life (Rank 7)
	[27220] = 5, -- Drain Life (Rank 8)
	[47857] = 5, -- Drain Life (Rank 9)
	[5740] = 4, -- Rain of Fire (Rank 1)
	[6219] = 4, -- Rain of Fire (Rank 2)
	[11677] = 4, -- Rain of Fire (Rank 3)
	[11678] = 4, -- Rain of Fire (Rank 4)
	[27212] = 4, -- Rain of Fire (Rank 5)
	[47819] = 4, -- Rain of Fire (Rank 6)
	[47820] = 4, -- Rain of Fire (Rank 7)
	[1949] = 15, -- Hellfire (Rank 1)
	[11683] = 15, -- Hellfire (Rank 2)
	[11684] = 15, -- Hellfire (Rank 3)
	[27213] = 15, -- Hellfire (Rank 4)
	[47823] = 15, -- Hellfire (Rank 5)
	[5138] = 5, -- Drain Mana
	-- First Aid
	[45544] = 8, -- Heavy Frostweave Bandage
	[45543] = 8, -- Frostweave Bandage
	[27031] = 8, -- Heavy Netherweave Bandage
	[27030] = 8, -- Netherweave Bandage
	[23567] = 8, -- Warsong Gulch Runecloth Bandage
	[23696] = 8, -- Alterac Heavy Runecloth Bandage
	[24414] = 8, -- Arathi Basin Runecloth Bandage
	[18610] = 8, -- Heavy Runecloth Bandage
	[18608] = 8, -- Runecloth Bandage
	[10839] = 8, -- Heavy Mageweave Bandage
	[10838] = 8, -- Mageweave Bandage
	[7927] = 8, -- Heavy Silk Bandage
	[7926] = 8, -- Silk Bandage
	[3268] = 7, -- Heavy Wool Bandage
	[3267] = 7, -- Wool Bandage
	[1159] = 6, -- Heavy Linen Bandage
	[746] = 6, -- Linen Bandage
}

local function CreateAndUpdateBarTicks(bar, ticks, numTicks)
	for i = 1, #ticks do
		ticks[i]:Hide()
	end

	if numTicks and numTicks > 0 then
		local width, height = bar:GetSize()
		local delta = width / numTicks
		for i = 1, numTicks - 1 do
			if not ticks[i] then
				ticks[i] = bar:CreateTexture(nil, "OVERLAY")
				ticks[i]:SetTexture(C["Media"].Textures.BlankTexture)
				ticks[i]:SetVertexColor(0, 0, 0, 0.7)
				ticks[i]:SetWidth(K.Mult)
				ticks[i]:SetHeight(height)
			end
			ticks[i]:ClearAllPoints()
			ticks[i]:SetPoint("RIGHT", bar, "LEFT", delta * i, 0)
			ticks[i]:Show()
		end
	end
end

function Module:OnCastbarUpdate(elapsed)
	if self.casting or self.channeling then
		local decimal = self.decimal

		local duration = self.casting and (self.duration + elapsed) or (self.duration - elapsed)
		if (self.casting and duration >= self.max) or (self.channeling and duration <= 0) then
			self.casting = nil
			self.channeling = nil
			return
		end

		if self.__owner.unit == "player" then
			if self.delay ~= 0 then
				self.Time:SetFormattedText(decimal .. " - |cffff0000" .. decimal, duration, self.casting and self.max + self.delay or self.max - self.delay)
			else
				self.Time:SetFormattedText(decimal .. " - " .. decimal, duration, self.max)
			end
		else
			if duration > 1e4 then
				self.Time:SetText("∞ - ∞")
			else
				self.Time:SetFormattedText(decimal .. " - " .. decimal, duration, self.casting and self.max + self.delay or self.max - self.delay)
			end
		end
		self.duration = duration
		self:SetValue(duration)
		self.Spark:SetPoint("CENTER", self, "LEFT", (duration / self.max) * self:GetWidth(), 0)
	elseif self.holdTime > 0 then
		self.holdTime = self.holdTime - elapsed
	else
		self.Spark:Hide()
		local alpha = self:GetAlpha() - 0.02
		if alpha > 0 then
			self:SetAlpha(alpha)
		else
			self.fadeOut = nil
			self:Hide()
		end
	end
end

function Module:OnCastSent()
	local element = self.Castbar
	if not element.SafeZone then
		return
	end
	element.__sendTime = GetTime()
end

local function ResetSpellTarget(self)
	if self.spellTarget then
		self.spellTarget:SetText("")
	end
end

local function UpdateSpellTarget(self, unit)
	if not C["Nameplate"].CastTarget then
		return
	end

	if not self.spellTarget then
		return
	end

	local unitTarget = unit and unit .. "target"
	if unitTarget and UnitExists(unitTarget) then
		local nameString
		if UnitIsUnit(unitTarget, "player") then
			nameString = format("|cffff0000%s|r", ">" .. strupper(YOU) .. "<")
		else
			nameString = K.RGBToHex(K.UnitColor(unitTarget)) .. UnitName(unitTarget)
		end
		self.spellTarget:SetText(nameString)
	else
		ResetSpellTarget(self) -- when unit loses target
	end
end

local function UpdateCastBarColor(self, unit)
	local color = K.Colors.castbar.CastingColor
	if C["Unitframe"].CastClassColor and UnitIsPlayer(unit) then
		local _, Class = UnitClass(unit)
		local t = Class and K.Colors.class[Class]
		if t then
			color = K.Colors.class[Class]
		end
	elseif C["Unitframe"].CastReactionColor then
		local Reaction = UnitReaction(unit, "player")
		local t = Reaction and K.Colors.reaction[Reaction]
		if t then
			color = K.Colors.reaction[Reaction]
		end
	elseif not UnitIsUnit(unit, "player") and self.notInterruptible then
		color = K.Colors.castbar.notInterruptibleColor
	end

	self:SetStatusBarColor(color[1], color[2], color[3])
end

function Module:PostCastStart(unit)
	self:SetAlpha(1)
	self.Spark:Show()

	local safeZone = self.SafeZone
	local lagString = self.LagString

	if unit == "vehicle" or UnitInVehicle("player") then
		if safeZone then
			safeZone:Hide()
			lagString:Hide()
		end
	elseif unit == "player" then
		if safeZone then
			local sendTime = self.__sendTime
			local timeDiff = sendTime and min((GetTime() - sendTime), self.max)
			if timeDiff and timeDiff ~= 0 then
				safeZone:SetWidth(self:GetWidth() * timeDiff / self.max)
				safeZone:Show()
				lagString:SetFormattedText("%d ms", timeDiff * 1000)
				lagString:Show()
			else
				safeZone:Hide()
				lagString:Hide()
			end
			self.__sendTime = nil
		end

		local numTicks = 0
		if self.channeling then
			numTicks = channelingTicks[self.spellID] or 0
		end
		CreateAndUpdateBarTicks(self, ticks, numTicks)
	end

	UpdateCastBarColor(self, unit)

	if self.__owner.mystyle == "nameplate" then
		-- Major spells
		-- if C.db["Nameplate"]["CastbarGlow"] and
		if Module.MajorSpells[self.spellID] then
			K.ShowButtonGlow(self.glowFrame)
		else
			K.HideButtonGlow(self.glowFrame)
		end

		-- Spell target
		UpdateSpellTarget(self, unit)
	end
end

function Module:PostCastUpdate(unit)
	UpdateSpellTarget(self, unit)
end

function Module:PostUpdateInterruptible(unit)
	UpdateCastBarColor(self, unit)
end

function Module:PostCastStop()
	if not self.fadeOut then
		self:SetStatusBarColor(K.Colors.castbar.CompleteColor[1], K.Colors.castbar.CompleteColor[2], K.Colors.castbar.CompleteColor[3])
		self.fadeOut = true
	end

	self:Show()
	ResetSpellTarget(self)
end

function Module:PostCastFailed()
	self:SetStatusBarColor(K.Colors.castbar.FailColor[1], K.Colors.castbar.FailColor[2], K.Colors.castbar.FailColor[3])
	self:SetValue(self.max)
	self.fadeOut = true
	self:Show()
	ResetSpellTarget(self)
end
