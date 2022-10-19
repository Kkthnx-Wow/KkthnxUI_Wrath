local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("ActionBar")

local _G = _G
local math_min = _G.math.min
local math_ceil = _G.math.ceil
local table_insert = _G.table.insert

local RegisterStateDriver = _G.RegisterStateDriver

local cfg = C.Bars.Bar4
local margin, padding = C.Bars.BarMargin, C.Bars.BarPadding

local prevPage = 8
local function ChangeActionPageForDruid()
	local page = IsPlayerSpell(33891) and 10 or 8
	if prevPage ~= page then
		RegisterStateDriver(_G["KKUI_ActionBarX"], "page", page)
		for i = 1, 12 do
			local button = _G["KKUI_ActionBarXButton" .. i]
			button.id = (page - 1) * 12 + i
			button:SetAttribute("action", button.id)
		end

		prevPage = page
	end
end

local function UpdatePageBySpells()
	if InCombatLockdown() then
		K:RegisterEvent("PLAYER_REGEN_ENABLED", UpdatePageBySpells)
	else
		ChangeActionPageForDruid()
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", UpdatePageBySpells)
	end
end

local morePagesSpec = {
	["WARRIOR"] = true,
	["ROGUE"] = true,
}

function Module:SetupCustomBar(anchor)
	local num = 12
	local name = "KKUI_ActionBarX"
	local page = morePagesSpec[K.Class] and 10 or 8

	local frame = CreateFrame("Frame", name, UIParent, "SecureHandlerStateTemplate")
	frame.mover = K.Mover(frame, L[name], "CustomBar", anchor)

	-- stylua: ignore
	--	RegisterStateDriver(frame, "visibility", "[petbattle] hide; show")
	RegisterStateDriver(frame, "page", page)

	local buttonList = {}
	for i = 1, num do
		local button = CreateFrame("CheckButton", "$parentButton" .. i, frame, "ActionBarButtonTemplate")
		button.id = (page - 1) * 12 + i
		button.isCustomButton = true
		button.commandName = L[name] .. i
		button:SetAttribute("action", button.id)
		table_insert(buttonList, button)
		table_insert(Module.buttons, button)
	end
	frame.buttons = buttonList

	if cfg.fader then
		frame.isDisable = not C["ActionBar"].BarXFader
		Module.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end

	Module:UpdateCustomBar()
end

function Module:UpdateCustomBar()
	local frame = _G.KKUI_ActionBarX
	if not frame then
		return
	end

	local size = C["ActionBar"].CustomBarButtonSize
	local scale = size / 34
	local num = C["ActionBar"].CustomBarNumButtons
	local perRow = C["ActionBar"].CustomBarNumPerRow
	for i = 1, num do
		local button = frame.buttons[i]
		button:SetSize(size, size)
		button.Name:SetScale(scale)
		button.Count:SetScale(scale)
		button.HotKey:SetScale(scale)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("TOPLEFT", frame, padding, -padding)
		elseif mod(i - 1, perRow) == 0 then
			button:SetPoint("TOP", frame.buttons[i - perRow], "BOTTOM", 0, -margin)
		else
			button:SetPoint("LEFT", frame.buttons[i - 1], "RIGHT", margin, 0)
		end
		button:SetAttribute("statehidden", false)
		button:Show()
	end

	for i = num + 1, 12 do
		local button = frame.buttons[i]
		button:SetAttribute("statehidden", true)
		button:Hide()
	end

	local column = math_min(num, perRow)
	local rows = math_ceil(num / perRow)
	frame:SetWidth(column * size + (column - 1) * margin + 2 * padding)
	frame:SetHeight(size * rows + (rows - 1) * margin + 2 * padding)
	frame.mover:SetSize(frame:GetSize())
end

function Module:CreateCustomBar()
	if not C["ActionBar"].CustomBar then
		return
	end

	Module:SetupCustomBar({ "BOTTOM", UIParent, "BOTTOM", 0, 140 })
	if K.Class == "DRUID" then
		UpdatePageBySpells()
		K:RegisterEvent("LEARNED_SPELL_IN_TAB", UpdatePageBySpells)
	end
end
