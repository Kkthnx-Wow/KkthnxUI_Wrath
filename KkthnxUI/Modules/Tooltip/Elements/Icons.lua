local K, C = unpack(select(2, ...))
local Module = K:GetModule("Tooltip")

local _G = _G
local gsub = _G.gsub
local string_match = _G.string.match

local CreateFrame = _G.CreateFrame
local GetItemIcon = _G.GetItemIcon
local GetSpellTexture = _G.GetSpellTexture
local hooksecurefunc = _G.hooksecurefunc
local unpack = _G.unpack

local newString = "0:0:64:64:5:59:5:59"
function Module:SetupTooltipIcon(icon)
	local title = icon and _G[self:GetName().."TextLeft1"]
	local titleText = title and title:GetText()
	if titleText then
		title:SetFormattedText("|T%s:20:20:"..newString..":%d|t %s", icon, 20, titleText)
	end

	for i = 2, self:NumLines() do
		local line = _G[self:GetName().."TextLeft"..i]
		if not line then break end
		local text = line:GetText() or ""
		if string_match(text, "|T.-:[%d+:]+|t") then
			line:SetText(gsub(text, "|T(.-):[%d+:]+|t", "|T%1:12:12:"..newString.."|t"))
		end
	end
end

function Module:HookTooltipCleared()
	self.tipModified = false
end

function Module:HookTooltipSetItem()
	if not self.tipModified then
		local _, link = self:GetItem()
		if link then
			Module.SetupTooltipIcon(self, GetItemIcon(link))
		end

		self.tipModified = true
	end
end

function Module:HookTooltipSetSpell()
	if not self.tipModified then
		local _, id = self:GetSpell()
		if id then
			Module.SetupTooltipIcon(self, GetSpellTexture(id))
		end

		self.tipModified = true
	end
end

function Module:HookTooltipMethod()
	self:HookScript("OnTooltipSetItem", Module.HookTooltipSetItem)
	self:HookScript("OnTooltipSetSpell", Module.HookTooltipSetSpell)
	self:HookScript("OnTooltipCleared", Module.HookTooltipCleared)
end

local function updateBackdropColor(self, r, g, b)
	self:GetParent().bg.KKUI_Border:SetVertexColor(r, g, b)
end

local function resetBackdropColor(self)
	self:GetParent().bg.KKUI_Border:SetVertexColor(1, 1, 1)
end

function Module:ReskinRewardIcon()
	self.Icon:SetTexCoord(unpack(K.TexCoords))

	self.Count:ClearAllPoints()
	self.Count:SetPoint("BOTTOMRIGHT", self.Icon, "BOTTOMRIGHT", 1, 1)

	self.bg = CreateFrame("Frame", nil, self)
	self.bg:SetAllPoints(self.Icon)
	self.bg:SetFrameLevel(2)
	self.bg:CreateBorder()

	local iconBorder = self.IconBorder
	iconBorder:SetAlpha(0)

	hooksecurefunc(iconBorder, "SetVertexColor", updateBackdropColor)
	hooksecurefunc(iconBorder, "Hide", resetBackdropColor)
end

function Module:ReskinTooltipIcons()
	Module.HookTooltipMethod(GameTooltip)
	Module.HookTooltipMethod(ItemRefTooltip)

	hooksecurefunc(GameTooltip, "SetUnitAura", function(self)
		Module.SetupTooltipIcon(self)
	end)

	-- Tooltip rewards icon
	Module.ReskinRewardIcon(EmbeddedItemTooltip.ItemTooltip)
end

function Module:CreateTooltipIcons()
	if not C["Tooltip"].Icons then
		return
	end

	self:ReskinTooltipIcons()
end