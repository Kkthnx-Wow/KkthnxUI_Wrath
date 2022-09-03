local _, C = unpack(KkthnxUI)

-- Lua
local _G = _G

C.themes["Blizzard_InspectUI"] = function()
	for _, slot in ipairs({ _G.InspectPaperDollItemsFrame:GetChildren() }) do
		local icon = _G[slot:GetName() .. "IconTexture"]

		slot:StripTextures()
		slot:CreateBorder()
		slot:StyleButton()

		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		icon:SetAllPoints()
	end

	hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
		local unit = button.hasItem and _G.InspectFrame.unit
		if not unit then
			return
		end

		local itemID = GetInventoryItemID(unit, button:GetID())
		if itemID then
			local quality = select(3, GetItemInfo(itemID))
			if quality and quality > 1 then
				button.KKUI_Border:SetVertexColor(GetItemQualityColor(quality))
				return
			end
		end

		button.KKUI_Border:SetVertexColor(1, 1, 1)
	end)
end
