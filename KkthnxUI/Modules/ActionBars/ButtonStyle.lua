local K, C = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")

local _G = _G
local next = _G.next
local string_gsub = _G.string.gsub
local unpack = _G.unpack

local GetBindingKey = _G.GetBindingKey
local hooksecurefunc = _G.hooksecurefunc

local function CallButtonFunctionByName(button, func, ...)
	if button and func and button[func] then
		button[func](button, ...)
	end
end

local function ResetNormalTexture(self, file)
	if not self.__normalTextureFile then
		return
	end

	if file == self.__normalTextureFile then
		return
	end

	self:SetNormalTexture(self.__normalTextureFile)
end

local function ResetTexture(self, file)
	if not self.__textureFile then
		return
	end

	if file == self.__textureFile then
		return
	end

	self:SetTexture(self.__textureFile)
end

local function ResetVertexColor(self, r, g, b, a)
	if not self.__vertexColor then
		return
	end

	local r2, g2, b2, a2 = unpack(self.__vertexColor)
	if not a2 then
		a2 = 1
	end

	if r ~= r2 or g ~= g2 or b ~= b2 or a ~= a2 then
		self:SetVertexColor(r2, g2, b2, a2)
	end
end

local function ApplyPoints(self, points)
	if not points then
		return
	end

	self:ClearAllPoints()
	for _, point in next, points do
		self:SetPoint(unpack(point))
	end
end

local function ApplyTexCoord(texture, texCoord)
	if texture.__lockdown or not texCoord then
		return
	end

	texture:SetTexCoord(unpack(texCoord))
end

local function ApplyVertexColor(texture, color)
	if not color then
		return
	end

	texture.__vertexColor = color
	texture:SetVertexColor(unpack(color))
	hooksecurefunc(texture, "SetVertexColor", ResetVertexColor)
end

local function ApplyAlpha(region, alpha)
	if not alpha then
		return
	end

	region:SetAlpha(alpha)
end

local function ApplyFont(fontString, font)
	if not font then
		return
	end

	fontString:SetFontObject(font)
end

local function ApplyHorizontalAlign(fontString, align)
	if not align then
		return
	end

	fontString:SetJustifyH(align)
end

local function ApplyVerticalAlign(fontString, align)
	if not align then
		return
	end

	fontString:SetJustifyV(align)
end

local function ApplyTexture(texture, file)
	if not file then
		return
	end

	texture.__textureFile = file
	texture:SetTexture(file)
	hooksecurefunc(texture, "SetTexture", ResetTexture)
end

local function ApplyNormalTexture(button, file)
	if not file then
		return
	end

	button.__normalTextureFile = file
	button:SetNormalTexture(file)
	hooksecurefunc(button, "SetNormalTexture", ResetNormalTexture)
end

local function ApplyBlend(texture, blend)
	if not blend then
		return
	end

	texture:SetBlendMode(blend)
end

local function SetupTexture(texture, cfg, func, button)
	if not texture or not cfg then
		return
	end

	ApplyTexCoord(texture, cfg.texCoord)
	ApplyPoints(texture, cfg.points)
	ApplyVertexColor(texture, cfg.color)
	ApplyAlpha(texture, cfg.alpha)
	ApplyBlend(texture, cfg.blend)

	if func == "SetTexture" then
		ApplyTexture(texture, cfg.file)
	elseif func == "SetNormalTexture" then
		ApplyNormalTexture(button, cfg.file)
	elseif cfg.file then
		CallButtonFunctionByName(button, func, cfg.file)
	end
end

local function SetupFontString(fontString, cfg)
	if not fontString or not cfg then
		return
	end

	ApplyPoints(fontString, cfg.points)
	ApplyFont(fontString, cfg.font)
	ApplyAlpha(fontString, cfg.alpha)
	ApplyHorizontalAlign(fontString, cfg.halign)
	ApplyVerticalAlign(fontString, cfg.valign)
end

local function SetupCooldown(cooldown, cfg)
	if not cooldown or not cfg then
		return
	end

	ApplyPoints(cooldown, cfg.points)
end

local function SetupBorder(icon)
	icon:CreateBorder()
end

local keyButton = string_gsub(KEY_BUTTON4, "%d", "")
local keyNumpad = string_gsub(KEY_NUMPAD1, "%d", "")
local replaces = {
	{"("..keyButton..")", "M"},
	{"("..keyNumpad..")", "N"},
	{"(a%-)", "a"},
	{"(c%-)", "c"},
	{"(s%-)", "s"},
	{KEY_BUTTON3, "M3"},
	{KEY_MOUSEWHEELUP, "MU"},
	{KEY_MOUSEWHEELDOWN, "MD"},
	{KEY_SPACE, "Sp"},
	{CAPSLOCK_KEY_TEXT, "CL"},
	{"BUTTON", "M"},
	{"NUMPAD", "N"},
	{"(ALT%-)", "a"},
	{"(CTRL%-)", "c"},
	{"(SHIFT%-)", "s"},
	{"MOUSEWHEELUP", "MU"},
	{"MOUSEWHEELDOWN", "MD"},
	{"SPACE", "Sp"},
}

function Module:UpdateHotKey()
	local hotkey = _G[self:GetName().."HotKey"]
	if hotkey and hotkey:IsShown() and not C["ActionBar"].Hotkey then
		hotkey:Hide()
		return
	end

	local text = hotkey:GetText()
	if not text then
		return
	end

	for _, value in pairs(replaces) do
		text = string_gsub(text, value[1], value[2])
	end

	if text == RANGE_INDICATOR then
		hotkey:SetText("")
	else
		hotkey:SetText(text)
	end
end

function Module:UpdateEquipItemColor()
	if not self.KKUI_Border then
		return
	end

	if IsEquippedAction(self.action) then
		self.KKUI_Border:SetVertexColor(0, 0.7, 0.1)
	else
		if C["General"].ColorTextures then
			self.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
		else
			self.KKUI_Border:SetVertexColor(1, 1, 1)
		end
	end
end

function Module:StyleActionButton(button, cfg)
	if not button then
		return
	end

	if button.__styled then
		return
	end

	local buttonName = button:GetName()
	local icon = _G[buttonName.."Icon"]
	local flash = _G[buttonName.."Flash"]
	local hotkey = _G[buttonName.."HotKey"]
	local count = _G[buttonName.."Count"]
	local name = _G[buttonName.."Name"]
	local border = _G[buttonName.."Border"]
	local autoCastable = _G[buttonName.."AutoCastable"]
	local NewActionTexture = button.NewActionTexture
	local cooldown = _G[buttonName.."Cooldown"]
	local normalTexture = button:GetNormalTexture()
	local pushedTexture = button:GetPushedTexture()
	local highlightTexture = button:GetHighlightTexture()

	-- Normal buttons do not have a checked texture, but checkbuttons do and normal actionbuttons are checkbuttons
	local checkedTexture
	if button.GetCheckedTexture then
		checkedTexture = button:GetCheckedTexture()
	end

	-- Hide stuff
	local floatingBG = _G[buttonName.."FloatingBG"]
	if floatingBG then
		floatingBG:Hide()
	end

	if NewActionTexture then
		NewActionTexture:SetTexture(nil)
	end

	-- Backdrop
	SetupBorder(icon)

	-- Textures
	SetupTexture(icon, cfg.icon, "SetTexture", icon)
	SetupTexture(flash, cfg.flash, "SetTexture", flash)
	SetupTexture(border, cfg.border, "SetTexture", border)
	SetupTexture(normalTexture, cfg.normalTexture, "SetNormalTexture", button)
	SetupTexture(pushedTexture, cfg.pushedTexture, "SetPushedTexture", button)
	SetupTexture(highlightTexture, cfg.highlightTexture, "SetHighlightTexture", button)

	if checkedTexture then
		SetupTexture(checkedTexture, cfg.checkedTexture, "SetCheckedTexture", button)
	end

	-- Cooldown
	SetupCooldown(cooldown, cfg.cooldown)

	-- No clue why but blizzard created count and duration on background layer, need to fix that
	local overlay = CreateFrame("Frame", nil, button)
	overlay:SetAllPoints()

	if count then
		if C["ActionBar"].Count then
			count:SetParent(overlay)
			SetupFontString(count, cfg.count)
		else
			count:Hide()
		end
	end

	if hotkey then
		hotkey:SetParent(overlay)
		Module.UpdateHotKey(button)
		SetupFontString(hotkey, cfg.hotkey)
	end

	if name then
		if C["ActionBar"].Macro then
			name:SetParent(overlay)
			SetupFontString(name, cfg.name)
		else
			name:Hide()
		end
	end

	if autoCastable then
		autoCastable:SetTexCoord(.217, .765, .217, .765)
		autoCastable:SetAllPoints()
	end

	button.__styled = true
end

function Module:UpdateStanceHotKey()
	for i = 1, NUM_STANCE_SLOTS do
		_G["StanceButton"..i.."HotKey"]:SetText(GetBindingKey("SHAPESHIFTBUTTON"..i))
		Module.UpdateHotKey(_G["StanceButton"..i])
	end
end

function Module:StyleAllActionButtons(cfg)
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		Module:StyleActionButton(_G["ActionButton"..i], cfg)
		Module:StyleActionButton(_G["MultiBarBottomLeftButton"..i], cfg)
		Module:StyleActionButton(_G["MultiBarBottomRightButton"..i], cfg)
		Module:StyleActionButton(_G["MultiBarRightButton"..i], cfg)
		Module:StyleActionButton(_G["MultiBarLeftButton"..i], cfg)
		Module:StyleActionButton(_G["KKUI_CustomBarButton"..i], cfg)
	end

	for i = 1, 6 do
		Module:StyleActionButton(_G["OverrideActionBarButton"..i], cfg)
	end

	--leave vehicle
	Module:StyleActionButton(_G["KKUI_LeaveVehicleButton"], cfg)

	-- Petbar buttons
	for i = 1, NUM_PET_ACTION_SLOTS do
		Module:StyleActionButton(_G["PetActionButton"..i], cfg)
	end

	-- Stancebar buttons
	for i = 1, NUM_STANCE_SLOTS do
		Module:StyleActionButton(_G["StanceButton"..i], cfg)
	end
end

function Module:CreateBarSkin()
	local cfgFont = K.GetFont(C["UIFonts"].ActionBarsFonts)
	local cfg = {
		icon = {
			texCoord = K.TexCoords,
		},

		border = {
			file = ""
		},

		normalTexture = {
			file = "",
		},

		flash = {
			file = ""
		},

		pushedTexture = {
			file = "Interface\\Buttons\\ButtonHilight-Square",
			color = {246/255, 196/255, 66/255},
			blend = "ADD",
		},

		checkedTexture = {
			file = "Interface\\Buttons\\CheckButtonHilight",
			blend = "ADD",
		},

		highlightTexture = {
			file = "Interface\\Buttons\\ButtonHilight-Square",
			blend = "ADD",
		},

		cooldown = {
			points = {
				{"TOPLEFT", 1, -1},
				{"BOTTOMRIGHT", -1, 1},
			},
		},

		name = {
			font = cfgFont,
			points = {
				{"BOTTOMLEFT", 0, 0},
				{"BOTTOMRIGHT", 0, 0},
			},
		},

		hotkey = {
			font = cfgFont,
			points = {
				{"TOPRIGHT", 0, -3},
				{"TOPLEFT", 0, -3},
			},
		},

		count = {
			font = cfgFont,
			points = {
				{"BOTTOMRIGHT", 2, 0},
			},
		},

		buttonstyle = {
			file = ""
		},
	}

	Module:StyleAllActionButtons(cfg)

	-- Update hotkeys
	hooksecurefunc("ActionButton_UpdateHotkeys", Module.UpdateHotKey)
	hooksecurefunc("PetActionButton_SetHotkeys", Module.UpdateHotKey)
	Module:UpdateStanceHotKey()
	K:RegisterEvent("UPDATE_BINDINGS", Module.UpdateStanceHotKey)
	-- Equip item
	hooksecurefunc("ActionButton_Update", Module.UpdateEquipItemColor)
end