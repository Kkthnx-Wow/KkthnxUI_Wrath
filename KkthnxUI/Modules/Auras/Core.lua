local K, C, L = unpack(KkthnxUI)
local Module = K:NewModule("Auras")

-- Sourced: NDui (Siweia)

local _G = _G
local math_floor = _G.math.floor
local select = _G.select
local string_format = _G.string.format
local string_match = _G.string.match

local CreateFrame = _G.CreateFrame
local DebuffTypeColor = _G.DebuffTypeColor
local GameTooltip = _G.GameTooltip
local GetInventoryItemQuality = _G.GetInventoryItemQuality
local GetInventoryItemTexture = _G.GetInventoryItemTexture
local GetItemQualityColor = _G.GetItemQualityColor
local GetTime = _G.GetTime
local GetWeaponEnchantInfo = _G.GetWeaponEnchantInfo
local RegisterAttributeDriver = _G.RegisterAttributeDriver
local RegisterStateDriver = _G.RegisterStateDriver
local SecureHandlerSetFrameRef = _G.SecureHandlerSetFrameRef
local UIParent = _G.UIParent
local UnitAura = _G.UnitAura

local day, hour, minute = 86400, 3600, 60

function Module:OnEnable()
	Module:HideBlizBuff()
	Module:BuildBuffFrame()
	Module:CreateTotems()
	Module:CreateReminder()
end

function Module:HideBlizBuff()
	if not C["Auras"].Enable and not C["Auras"].HideBlizBuff then
		return
	end

	K.HideInterfaceOption(_G.BuffFrame)
	K.HideInterfaceOption(_G.TemporaryEnchantFrame)
end

function Module:BuildBuffFrame()
	if not C["Auras"].Enable then
		return
	end

	-- Config
	Module.settings = {
		Buffs = {
			offset = 12,
			size = C["Auras"].BuffSize,
			wrapAfter = C["Auras"].BuffsPerRow,
			maxWraps = 3,
			reverseGrow = C["Auras"].ReverseBuffs,
		},
		Debuffs = {
			offset = 12,
			size = C["Auras"].DebuffSize,
			wrapAfter = C["Auras"].DebuffsPerRow,
			maxWraps = 1,
			reverseGrow = C["Auras"].ReverseDebuffs,
		},
	}

	-- Movers
	Module.BuffFrame = Module:CreateAuraHeader("HELPFUL")
	Module.BuffFrame.mover = K.Mover(Module.BuffFrame, "Buffs", "BuffAnchor", { "TOPRIGHT", _G.Minimap, "TOPLEFT", -6, 0 })
	Module.BuffFrame:ClearAllPoints()
	Module.BuffFrame:SetPoint("TOPRIGHT", Module.BuffFrame.mover)

	Module.DebuffFrame = Module:CreateAuraHeader("HARMFUL")
	Module.DebuffFrame.mover = K.Mover(Module.DebuffFrame, "Debuffs", "DebuffAnchor", { "TOPRIGHT", Module.BuffFrame.mover, "BOTTOMRIGHT", 0, -12 })
	Module.DebuffFrame:ClearAllPoints()
	Module.DebuffFrame:SetPoint("TOPRIGHT", Module.DebuffFrame.mover)
end

function Module:FormatAuraTime(s)
	if s >= day then
		return string_format("%d" .. K.MyClassColor .. "d", s / day), s % day
	elseif s >= 2 * hour then
		return string_format("%d" .. K.MyClassColor .. "h", s / hour), s % hour
	elseif s >= 10 * minute then
		return string_format("%d" .. K.MyClassColor .. "m", s / minute), s % minute
	elseif s >= minute then
		return string_format("%d:%.2d", s / minute, s % minute), s - math_floor(s)
	elseif s > 10 then
		return string_format("%d" .. K.MyClassColor .. "s", s), s - math_floor(s)
	elseif s > 5 then
		return string_format("|cffffff00%.1f|r", s), s - string_format("%.1f", s)
	else
		return string_format("|cffff0000%.1f|r", s), s - string_format("%.1f", s)
	end
end

function Module:UpdateTimer(elapsed)
	local onTooltip = GameTooltip:IsOwned(self)

	if not (self.timeLeft or self.offset or onTooltip) then
		self:SetScript("OnUpdate", nil)
		return
	end

	if self.offset then
		local expiration = select(self.offset, GetWeaponEnchantInfo())
		if expiration then
			self.timeLeft = expiration / 1e3
		else
			self.timeLeft = 0
		end
	elseif self.timeLeft then
		self.timeLeft = self.timeLeft - elapsed
	end

	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
		return
	end

	if self.timeLeft and self.timeLeft >= 0 then
		local timer, nextUpdate = Module:FormatAuraTime(self.timeLeft)
		self.nextUpdate = nextUpdate
		self.timer:SetText(timer)
	end

	if onTooltip then
		Module:Button_SetTooltip(self)
	end
end

function Module:GetSpellStat(arg16, arg17, arg18)
	return (arg16 > 0 and L["Versa"]) or (arg17 > 0 and L["Mastery"]) or (arg18 > 0 and L["Haste"]) or L["Crit"]
end

function Module:UpdateAuras(button, index)
	local unit, filter = button.header:GetAttribute("unit"), button.filter
	local name, texture, count, debuffType, duration, expirationTime, _, _, _, spellID, _, _, _, _, _, arg16, arg17, arg18 = UnitAura(unit, index, filter)
	if not name then
		return
	end

	if duration > 0 and expirationTime then
		local timeLeft = expirationTime - GetTime()
		if not button.timeLeft then
			button.nextUpdate = -1
			button.timeLeft = timeLeft
			button:SetScript("OnUpdate", Module.UpdateTimer)
		else
			button.timeLeft = timeLeft
		end
		button.nextUpdate = -1
		Module.UpdateTimer(button, 0)
	else
		button.timeLeft = nil
		button.timer:SetText("")
	end

	if count and count > 1 then
		button.count:SetText(count)
	else
		button.count:SetText("")
	end

	if filter == "HARMFUL" then
		local color = DebuffTypeColor[debuffType or "none"]
		button.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
	else
		if C["General"].ColorTextures then
			button.KKUI_Border:SetVertexColor(C["General"].TexturesColor[1], C["General"].TexturesColor[2], C["General"].TexturesColor[3])
		else
			button.KKUI_Border:SetVertexColor(1, 1, 1)
		end
	end

	-- Show spell stat for 'Soleahs Secret Technique'
	if spellID == 368512 then
		button.count:SetText(Module:GetSpellStat(arg16, arg17, arg18))
	end

	button.spellID = spellID
	button.icon:SetTexture(texture)
	button.offset = nil
end

function Module:UpdateTempEnchant(button, index)
	local quality = GetInventoryItemQuality("player", index)
	button.icon:SetTexture(GetInventoryItemTexture("player", index))

	local offset = 2
	local weapon = button:GetName():sub(-1)
	if string_match(weapon, "2") then
		offset = 6
	end

	if quality then
		button.KKUI_Border:SetVertexColor(GetItemQualityColor(quality))
	end

	local expirationTime = select(offset, GetWeaponEnchantInfo())
	if expirationTime then
		button.offset = offset
		button:SetScript("OnUpdate", Module.UpdateTimer)
		button.nextUpdate = -1
		Module.UpdateTimer(button, 0)
	else
		button.offset = nil
		button.timeLeft = nil
		button.timer:SetText("")
	end
end

function Module:OnAttributeChanged(attribute, value)
	if attribute == "index" then
		Module:UpdateAuras(self, value)
	elseif attribute == "target-slot" then
		Module:UpdateTempEnchant(self, value)
	end
end

function Module:UpdateHeader(header)
	local cfg = Module.settings.Debuffs
	if header.filter == "HELPFUL" then
		cfg = Module.settings.Buffs
		header:SetAttribute("consolidateTo", 0)
		header:SetAttribute("weaponTemplate", string_format("KKUI_AuraTemplate%d", cfg.size))
	end

	local margin = 6

	header:SetAttribute("separateOwn", 1)
	header:SetAttribute("sortMethod", "INDEX")
	header:SetAttribute("sortDirection", "+")
	header:SetAttribute("wrapAfter", cfg.wrapAfter)
	header:SetAttribute("maxWraps", cfg.maxWraps)
	header:SetAttribute("point", cfg.reverseGrow and "TOPLEFT" or "TOPRIGHT")
	header:SetAttribute("minWidth", (cfg.size + margin) * cfg.wrapAfter)
	header:SetAttribute("minHeight", (cfg.size + cfg.offset) * cfg.maxWraps)
	header:SetAttribute("xOffset", (cfg.reverseGrow and 1 or -1) * (cfg.size + margin))
	header:SetAttribute("yOffset", 0)
	header:SetAttribute("wrapXOffset", 0)
	header:SetAttribute("wrapYOffset", -(cfg.size + cfg.offset))
	header:SetAttribute("template", string_format("KKUI_AuraTemplate%d", cfg.size))

	local fontSize = math_floor(cfg.size / 30 * 12 + 0.5)
	local index = 1
	local child = select(index, header:GetChildren())
	while child do
		if (math_floor(child:GetWidth() * 100 + 0.5) / 100) ~= cfg.size then
			child:SetSize(cfg.size, cfg.size)
		end

		child.count:SetFontObject(K.UIFontOutline)
		child.count:SetFont(select(1, child.count:GetFont()), fontSize, select(3, child.count:GetFont()))

		child.timer:SetFontObject(K.UIFontOutline)
		child.timer:SetFont(select(1, child.timer:GetFont()), fontSize, select(3, child.timer:GetFont()))

		-- Blizzard bug fix, icons arent being hidden when you reduce the amount of maximum buttons
		if index > (cfg.maxWraps * cfg.wrapAfter) and child:IsShown() then
			child:Hide()
		end

		index = index + 1
		child = select(index, header:GetChildren())
	end
end

function Module:CreateAuraHeader(filter)
	local name = "KKUI_PlayerDebuffs"
	if filter == "HELPFUL" then
		name = "KKUI_PlayerBuffs"
	end

	local header = CreateFrame("Frame", name, UIParent, "SecureAuraHeaderTemplate")
	header:SetClampedToScreen(true)
	header:SetAttribute("unit", "player")
	header:SetAttribute("filter", filter)
	header.filter = filter
	RegisterAttributeDriver(header, "unit", "[vehicleui] vehicle; player")

	header.visibility = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
	SecureHandlerSetFrameRef(header.visibility, "AuraHeader", header)
	RegisterStateDriver(header.visibility, "customVisibility", "[petbattle] 0;1")
	header.visibility:SetAttribute(
		"_onstate-customVisibility",
		[[
		local header = self:GetFrameRef("AuraHeader")
		local hide, shown = newstate == 0, header:IsShown()
		if hide and shown then header:Hide() elseif not hide and not shown then header:Show() end
	]]
	) -- use custom script that will only call hide when it needs to, this prevents spam to `SecureAuraHeader_Update`

	if filter == "HELPFUL" then
		header:SetAttribute("consolidateDuration", -1)
		header:SetAttribute("includeWeapons", 1)
	end

	Module:UpdateHeader(header)
	header:Show()

	return header
end

function Module:RemoveSpellFromIgnoreList()
	if IsAltKeyDown() and IsControlKeyDown() and self.spellID and KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList.IgnoreSpells[self.spellID] then
		KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList.IgnoreSpells[self.spellID] = nil
		K.Print(string.format(L["RemoveFromIgnoreList"], "", self.spellID))
	end
end

function Module:Button_SetTooltip(button)
	if button:GetAttribute("index") then
		GameTooltip:SetUnitAura(button.header:GetAttribute("unit"), button:GetID(), button.filter)
	elseif button:GetAttribute("target-slot") then
		GameTooltip:SetInventoryItem("player", button:GetID())
	end
end

function Module:Button_OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", -5, -5)
	-- Update tooltip
	self.nextUpdate = -1
	self:SetScript("OnUpdate", Module.UpdateTimer)
end

function Module:CreateAuraIcon(button)
	button.header = button:GetParent()
	button.filter = button.header.filter

	local cfg = Module.settings.Debuffs
	if button.filter == "HELPFUL" then
		cfg = Module.settings.Buffs
	end
	local fontSize = math_floor(cfg.size / 30 * 12 + 0.5)

	button.icon = button:CreateTexture(nil, "BORDER")
	button.icon:SetAllPoints()
	button.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	button.count = button:CreateFontString(nil, "OVERLAY")
	button.count:SetPoint("TOPRIGHT", -1, -3)
	button.count:SetFontObject(K.UIFontOutline)
	button.count:SetFont(select(1, button.count:GetFont()), fontSize, select(3, button.count:GetFont()))

	button.timer = button:CreateFontString(nil, "OVERLAY")
	button.timer:SetPoint("TOP", button, "BOTTOM", 1, 5)
	button.timer:SetFontObject(K.UIFontOutline)
	button.timer:SetFont(select(1, button.timer:GetFont()), fontSize, select(3, button.timer:GetFont()))

	button:StyleButton()
	button:CreateBorder()

	button:RegisterForClicks("RightButtonUp")
	button:SetScript("OnAttributeChanged", Module.OnAttributeChanged)
	button:HookScript("OnMouseDown", Module.RemoveSpellFromIgnoreList)
	button:SetScript("OnEnter", Module.Button_OnEnter)
	button:SetScript("OnLeave", K.HideTooltip)
end
