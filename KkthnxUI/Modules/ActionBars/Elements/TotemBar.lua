local K, C = unpack(KkthnxUI)
local Bar = K:GetModule("ActionBar")
local iconSize = 36

local colorTable = {
	summon = K.QualityColors[1],
	[_G.EARTH_TOTEM_SLOT] = K.QualityColors[2],
	[_G.FIRE_TOTEM_SLOT] = K.QualityColors[5],
	[_G.WATER_TOTEM_SLOT] = K.QualityColors[3],
	[_G.AIR_TOTEM_SLOT] = K.QualityColors[4],
}

local function reskinTotemButton(button, nobg, uncut)
	button:StripTextures(1)
	button:StyleButton()

	local icon = button:GetRegions()
	if not button.icon then
		button.icon = icon
	end

	if not uncut then
		icon:SetTexCoord(unpack(K.TexCoords))
	end

	if not nobg then
		button.bg = CreateFrame("Frame", nil, button)
		button.bg:SetAllPoints(button)
		button.bg:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, "")
	end
end

local function reskinTotemArrow(button, direction)
	button:StripTextures(2)
	button:SetWidth(iconSize * 6 + 6 * 5, iconSize)

	local tex = button:CreateTexture(nil, "ARTWORK")
	tex:SetSize(20, 20)
	tex:SetPoint("CENTER")
	K.SetupArrow(tex, direction)
	button.__texture = tex
	-- button:HookScript("OnEnter", K.Texture_OnEnter)
	-- button:HookScript("OnLeave", K.Texture_OnLeave)
end
-- TODO: Add custom options
function Bar:CreateTotemBar()
	if K.Class ~= "SHAMAN" then
		return
	end
	-- if not C["Actionbar"].TotemBar then
	--     return
	-- end

	local margin = 6
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetSize(iconSize * 6 + margin * 5, iconSize)
	frame.Mover = K.Mover(frame, "TotemBar", "TotemBar", { "BOTTOM", UIParent, 0, 275 })
	--frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", frame.Mover, -5, -6)
	--K.Mover(frame, "TotemBar", "TotemBar", { "BOTTOM", UIParent, 0, 275 })

	MultiCastActionBarFrame:SetParent(frame)
	MultiCastActionBarFrame.SetParent = K.Noop
	MultiCastActionBarFrame:ClearAllPoints()
	MultiCastActionBarFrame:SetPoint("BOTTOMLEFT", 0, margin / 2)
	MultiCastActionBarFrame.SetPoint = K.Noop
	MultiCastActionBarFrame:SetScript("OnUpdate", nil)
	MultiCastActionBarFrame:SetScript("OnShow", nil)
	MultiCastActionBarFrame:SetScript("OnHide", nil)

	reskinTotemButton(MultiCastSummonSpellButton)
	MultiCastSummonSpellButton:SetSize(iconSize, iconSize)
	MultiCastSummonSpellButton:ClearAllPoints()
	MultiCastSummonSpellButton:SetPoint("RIGHT", _G.MultiCastSlotButton1, "LEFT", -margin, 0)

	reskinTotemButton(MultiCastRecallSpellButton)
	MultiCastRecallSpellButton:SetSize(iconSize, iconSize)

	local old_update = MultiCastRecallSpellButton_Update
	function MultiCastRecallSpellButton_Update(button)
		if InCombatLockdown() then
			return
		end

		old_update(button)
		button:SetPoint("LEFT", _G.MultiCastSlotButton4, "RIGHT", margin, 0)
	end

	local prevButton
	for i = 1, 4 do
		local button = _G["MultiCastSlotButton" .. i]
		reskinTotemButton(button)
		button:SetSize(iconSize, iconSize)
		if i ~= 1 then
			button:SetPoint("LEFT", prevButton, "RIGHT", margin, 0)
		end

		prevButton = button
	end

	for i = 1, 12 do
		local button = _G["MultiCastActionButton" .. i]
		reskinTotemButton(button, true)
		button:SetAttribute("type2", "destroytotem")
		button:SetAttribute("*totem-slot*", i == 1 and 2 or i == 2 and 1 or i)
	end

	hooksecurefunc("MultiCastSlotButton_Update", function(button, slot)
		local color = colorTable[slot]
		if color then
			button.bg.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
		end
	end)

	hooksecurefunc("MultiCastActionButton_Update", function(button)
		if InCombatLockdown() then
			return
		end

		button:ClearAllPoints()
		button:SetAllPoints(button.slotButton)
	end)

	MultiCastFlyoutFrame:StripTextures()
	reskinTotemArrow(MultiCastFlyoutFrameOpenButton, "up")
	reskinTotemArrow(MultiCastFlyoutFrameCloseButton, "down")

	hooksecurefunc(MultiCastFlyoutFrame, "SetHeight", function(frame, _, force)
		if force then
			return
		end

		local buttons = frame.buttons
		local count = 0
		for i = 1, #buttons do
			local button = buttons[i]
			if button:IsShown() then
				if i ~= 1 then
					button:ClearAllPoints()
					button:SetPoint("BOTTOM", buttons[i - 1], "TOP", 0, margin)
				end

				count = count + 1
			end
		end

		frame:SetHeight(count * (iconSize + margin) + 20, true)
	end)

	hooksecurefunc("MultiCastFlyoutFrame_ToggleFlyout", function(frame, type, parent)
		for i = 1, #frame.buttons do
			local button = frame.buttons[i]
			if not button.bg then
				reskinTotemButton(button, nil, true)
				button:SetSize(iconSize, iconSize)
			end

			if not (type == "slot" and i == 1) then
				button.icon:SetTexCoord(unpack(K.TexCoords))
			end

			local color = type == "page" and colorTable.summon or colorTable[parent:GetID()]
			button.bg.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
		end
	end)
end
