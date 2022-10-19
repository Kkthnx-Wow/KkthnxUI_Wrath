local _, C = unpack(KkthnxUI)

-- Lua
local _G = _G

C.themes["Blizzard_InspectUI"] = function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	-- Inspect
	local slots = {
		"Head",
		"Neck",
		"Shoulder",
		"Shirt",
		"Chest",
		"Waist",
		"Legs",
		"Feet",
		"Wrist",
		"Hands",
		"Finger0",
		"Finger1",
		"Trinket0",
		"Trinket1",
		"Back",
		"MainHand",
		"SecondaryHand",
		"Tabard",
		"Ranged",
	}

	for i = 1, #slots do
		local slot = _G["Inspect" .. slots[i] .. "Slot"]

		slot:StripTextures()
		slot:SetNormalTexture("")
		slot.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

		slot.bg = CreateFrame("Frame", nil, slot)
		slot.bg:SetAllPoints(slot.icon)
		slot.bg:SetFrameLevel(slot:GetFrameLevel())
		slot.bg:CreateBorder()
	end
end
