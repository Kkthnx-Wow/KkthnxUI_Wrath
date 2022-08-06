local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")

local _G = _G
local pairs = _G.pairs
local table_insert = _G.table.insert
local table_sort = _G.table.sort

local GetSpellCooldown = _G.GetSpellCooldown
local GetSpellInfo = _G.GetSpellInfo
local IsPlayerSpell = _G.IsPlayerSpell
local UnitAura = _G.UnitAura

local aspects = {
	[1] = {spellID = 13165, known = false}, -- Eagle
	[2] = {spellID = 34074, known = false}, -- Viper
	[3] = {spellID = 13163, known = false}, -- Monkey
	[4] = {spellID = 5118, known = false}, -- Cheetah
	[5] = {spellID = 13159, known = false}, -- Leopard Group
	[6] = {spellID = 13161, known = false}, -- Beast
	[7] = {spellID = 20043, known = false}, -- Wild
}

local knownAspect = {}
local aspectButtons = {}
local aspectFrame

function Module:UpdateAspectCooldown()
	local start, duration = GetSpellCooldown(self.spellID)
	if start > 0 and duration > 0 then
		self.CD:SetCooldown(start, duration)
		self.CD:Show()
	else
		self.CD:Hide()
	end
end

function Module:CreateAspectButton(spellID, index)
	local name, _, texture = GetSpellInfo(spellID)
	local size = C["ActionBar"].AspectSize

	local button = CreateFrame("Button", "$parentButton"..index, aspectFrame, "SecureActionButtonTemplate")
	button:SetSize(size, size)
	button:SetAttribute("type", "spell")
	button:SetAttribute("spell", name)

	button:CreateBorder()
	button:StyleButton()

	button.Icon = button:CreateTexture(nil, "ARTWORK")
	button.Icon:SetAllPoints(button)
	button.Icon:SetTexCoord(unpack(K.TexCoords))
	button.Icon:SetTexture(texture)

	K.AddTooltip(button, "ANCHOR_TOP", name)

	button.CD = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
	button.CD:SetAllPoints()
	button.CD:SetDrawEdge(false)
	button.spellID = spellID
	button:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	button:SetScript("OnEvent", Module.UpdateAspectCooldown)

	button.cover = button:CreateTexture(nil, "ARTWORK", nil, 5)
	button.cover:SetAllPoints(button)
	button.cover:SetTexCoord(unpack(K.TexCoords))
	button.cover:SetTexture("Interface\\Icons\\Spell_Nature_WispSplode")

	knownAspect[name] = true
	table_insert(aspectButtons, {button, index, name})
end

local function table_sortButtons(a, b)
	if a and b then
		return a[2] < b[2]
	end
end

function Module:UpdateAspectAnchor()
	table_sort(aspectButtons, table_sortButtons)

	local prevButton
	for _, value in pairs(aspectButtons) do
		value[1]:ClearAllPoints()
		if not prevButton then
			value[1]:SetPoint("TOPLEFT", 3, -3)
		else
			if C["ActionBar"].VerticleAspect then
				value[1]:SetPoint("TOP", prevButton, "BOTTOM", 0, -6)
			else
				value[1]:SetPoint("LEFT", prevButton, "RIGHT", 6, 0)
			end
		end
		prevButton = value[1]
	end
end

function Module:CheckKnownAspects()
	for index, value in pairs(aspects) do
		if not value.known and IsPlayerSpell(value.spellID) then
			Module:CreateAspectButton(value.spellID, index)
			value.known = true
		end
	end

	Module:UpdateAspectAnchor()
end

function Module:CheckActiveAspect(unit)
	if unit ~= "player" then
		return
	end

	local foundAspect
	for i = 1, 40 do
		local name, _, _, _, _, _, caster = UnitAura("player", i)
		if not name then
			break
		end

		if knownAspect[name] and caster == "player" then
			foundAspect = name
		end
	end

	for _, value in pairs(aspectButtons) do
		value[1].cover:SetShown(value[3] == foundAspect)
	end
end

function Module:UpdateAspectStatus()
	if not aspectFrame then
		return
	end

	local size = C["ActionBar"].AspectSize
	local width, height = size * 7 + 3 * 14, size + 3 * 2
	if C["ActionBar"].VerticleAspect then
		aspectFrame:SetSize(height, width)
		aspectFrame.mover:SetSize(height, width)
	else
		aspectFrame:SetSize(width, height)
		aspectFrame.mover:SetSize(width, height)
	end

	for _, value in pairs(aspectButtons) do
		value[1]:SetSize(size, size)
	end
	Module:UpdateAspectAnchor()
end

function Module:ToggleAspectBar()
	if not aspectFrame then
		return
	end

	if C["ActionBar"].AspectBar then
		Module.CheckKnownAspects()
		K:RegisterEvent("LEARNED_SPELL_IN_TAB", Module.CheckKnownAspects)
		Module:CheckActiveAspect("player")
		K:RegisterEvent("UNIT_AURA", Module.CheckActiveAspect)
		aspectFrame:Show()
	else
		K:UnregisterEvent("LEARNED_SPELL_IN_TAB", Module.CheckKnownAspects)
		K:UnregisterEvent("UNIT_AURA", Module.CheckActiveAspect)
		aspectFrame:Hide()
	end
end


function Module:CreateAspectBar()
	if K.Class ~= "HUNTER" then
		return
	end

	local size = C["ActionBar"].AspectSize or 50
	local width, height = size * 7 + 3 * 14, size + 3 * 2

	aspectFrame = CreateFrame("Frame", "KKUI_AspectFrame", UIParent)
	if C["ActionBar"].VerticleAspect then
		aspectFrame:SetSize(height, width)
	else
		aspectFrame:SetSize(width, height)
	end
	aspectFrame.mover = K.Mover(aspectFrame, "AspectBar", "AspectBar", {"BOTTOM", _G.KKUI_PetActionBar, "TOP", 0, 3})

	Module:ToggleAspectBar()
end