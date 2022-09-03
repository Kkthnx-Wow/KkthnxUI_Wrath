local K, C = unpack(KkthnxUI)

local _G = _G

tinsert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	local slots = {
		_G.CharacterHeadSlot,
		_G.CharacterNeckSlot,
		_G.CharacterShoulderSlot,
		_G.CharacterShirtSlot,
		_G.CharacterChestSlot,
		_G.CharacterWaistSlot,
		_G.CharacterLegsSlot,
		_G.CharacterFeetSlot,
		_G.CharacterWristSlot,
		_G.CharacterHandsSlot,
		_G.CharacterFinger0Slot,
		_G.CharacterFinger1Slot,
		_G.CharacterTrinket0Slot,
		_G.CharacterTrinket1Slot,
		_G.CharacterBackSlot,
		_G.CharacterMainHandSlot,
		_G.CharacterSecondaryHandSlot,
		_G.CharacterRangedSlot,
		_G.CharacterTabardSlot,
		_G.CharacterAmmoSlot,
	}

	for _, slot in pairs(slots) do
		if slot:IsObjectType("Button") then
			local icon = _G[slot:GetName() .. "IconTexture"]

			slot:StripTextures()
			slot:CreateBorder()
			slot:StyleButton()

			icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			icon:SetAllPoints()
		end
	end

	hooksecurefunc("PaperDollItemSlotButton_Update", function(frame)
		if frame.KKUI_Border then
			local rarity = GetInventoryItemQuality("player", frame:GetID())
			if rarity and rarity > 1 then
				frame.KKUI_Border:SetVertexColor(GetItemQualityColor(rarity))
			else
				frame.KKUI_Border:SetVertexColor(1, 1, 1)
			end
		end
	end)
end)
