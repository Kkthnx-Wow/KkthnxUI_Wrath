local K = unpack(select(2, ...))
local Module = K:GetModule("Tooltip")

local _G = _G
local string_match = _G.string.match

local GameTooltip = _G.GameTooltip
local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS

local orig1, orig2 = {}, {}
local linkTypes = {
	item = true,
	enchant = true,
	spell = true,
	quest = true,
	unit = true,
	talent = true,
	instancelock = true,
}

function Module:HyperLink_SetTypes(link)
	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", -3, 5)
	GameTooltip:SetHyperlink(link)
	GameTooltip:Show()
end

function Module:HyperLink_OnEnter(link, ...)
	local linkType = string_match(link, "^([^:]+)")
	if linkType and linkTypes[linkType] then
		Module.HyperLink_SetTypes(self, link)
	end

	if orig1[self] then
		return orig1[self](self, link, ...)
	end
end

function Module:HyperLink_OnLeave(_, ...)
	GameTooltip:Hide()

	if orig2[self] then
		return orig2[self](self, ...)
	end
end

for i = 1, NUM_CHAT_WINDOWS do
	local frame = _G["ChatFrame"..i]
	orig1[frame] = frame:GetScript("OnHyperlinkEnter")
	frame:SetScript("OnHyperlinkEnter", Module.HyperLink_OnEnter)
	orig2[frame] = frame:GetScript("OnHyperlinkLeave")
	frame:SetScript("OnHyperlinkLeave", Module.HyperLink_OnLeave)
end