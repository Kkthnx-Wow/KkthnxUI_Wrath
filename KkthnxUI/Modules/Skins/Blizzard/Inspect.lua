local K, C = unpack(select(2, ...))

-- Lua
local _G = _G

local HideUIPanel = _G.HideUIPanel
local hooksecurefunc = _G.hooksecurefunc

C.themes["Blizzard_InspectUI"] = function()
	for _, slot in pairs({InspectPaperDollItemsFrame:GetChildren()}) do
		if slot:IsObjectType('Button') then
			local icon = _G[slot:GetName()..'IconTexture']

			slot:StripTextures()
			slot:CreateBorder()
			slot:StyleButton(slot)
			icon:SetTexCoord(unpack(K.TexCoords))
		end
	end

	hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(slot)
		local highlight = slot:GetHighlightTexture()
		highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
		highlight:SetBlendMode("ADD")
		highlight:SetAllPoints()
	end)

	InspectModelFrame:HookScript("OnMouseWheel", Model_OnMouseWheel)
end