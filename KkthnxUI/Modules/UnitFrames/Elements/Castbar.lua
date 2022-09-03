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
	[120360] = 15, -- 弹幕射击
	[12051] = 6, -- 唤醒
	[15407] = 6, -- 精神鞭笞
	[198013] = 10, -- 眼棱
	[198590] = 5, -- 吸取灵魂
	[205021] = 5, -- 冰霜射线
	[205065] = 6, -- 虚空洪流
	[206931] = 3, -- 饮血者
	[212084] = 10, -- 邪能毁灭
	[234153] = 5, -- 吸取生命
	[257044] = 7, -- 急速射击
	[291944] = 6, -- 再生，赞达拉巨魔
	[314791] = 4, -- 变易幻能
	[324631] = 8, -- 血肉铸造，盟约
	[47757] = 3, -- 苦修
	[47758] = 3, -- 苦修
	[48045] = 6, -- 精神灼烧
	[5143] = 4, -- 奥术飞弹
	[64843] = 4, -- 神圣赞美诗
	[740] = 4, -- 宁静
	[755] = 5, -- 生命通道
}

if K.Class == "PRIEST" then
	local function updateTicks()
		local numTicks = 3
		if IsPlayerSpell(193134) then
			numTicks = 4
		end
		channelingTicks[47757] = numTicks
		channelingTicks[47758] = numTicks
	end

	K:RegisterEvent("PLAYER_LOGIN", updateTicks)
	K:RegisterEvent("PLAYER_TALENT_UPDATE", updateTicks)
end

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
