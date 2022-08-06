local K, C = unpack(select(2, ...))

local _G = _G
local table_insert = _G.table.insert

table_insert(C.defaultThemes, function()
	if not C["Skins"].WorldMap then
		return
	end

	local WorldMapFrame = _G.WorldMapFrame

	WorldMapFrame.BorderFrame:Hide()
	WorldMapZoneDropDown:Hide()
	WorldMapContinentDropDown:Hide()
	WorldMapZoneMinimapDropDown:Hide()
	WorldMapZoomOutButton:Hide()
	WorldMapMagnifyingGlassButton:Hide()

	WorldMapFrame:SetHitRectInsets(-20, -20, 38, 0)
	WorldMapFrame:SetClampedToScreen(false)

	local NewBorder = CreateFrame("Frame", nil, WorldMapFrame.ScrollContainer)
	NewBorder:SetPoint("TOPLEFT", 6, -6)
	NewBorder:SetPoint("BOTTOMRIGHT", -6, 6)
	NewBorder:CreateBorder(nil, nil, C["General"].BorderStyle.Value ~= "KkthnxUI_Pixel" and 32 or nil, nil, nil, nil, nil, nil, nil, "", nil, nil, nil, nil, nil, nil, nil, false)

	WorldMapFrameCloseButton:SetFrameLevel(10)
	WorldMapFrameCloseButton:SetSize(34, 34)
	WorldMapFrameCloseButton:ClearAllPoints()
	WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapFrame, "TOPRIGHT", -10, -68)
	WorldMapFrameCloseButton:SkinCloseButton()

	C_Timer.After(5, function()
		if Questie_Toggle then
			-- Hide original toggle button
			Questie_Toggle:Hide()

			-- Create our own button
			local QuestButton = CreateFrame("Button", nil, WorldMapFrame)
			QuestButton:SetSize(18, 18)
			QuestButton:SetPoint("TOPRIGHT", -50, -76)
			QuestButton:SetFrameLevel(WorldMapFrameCloseButton:GetFrameLevel())

			QuestButton:SetScript("OnClick", function()
				PlaySound(825)
				Questie_Toggle:Click()
			end)

			QuestButton:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", -1, 5)
				GameTooltip:AddLine("Toggle Questie")
				GameTooltip:Show()
			end)

			QuestButton:SetScript("OnLeave", K.HideTooltip)

			QuestButton:SkinButton()

			QuestButton.Texture = QuestButton.Texture or QuestButton:CreateTexture(nil, "OVERLAY")
			QuestButton.Texture:SetSize(18, 18)
			QuestButton.Texture:SetPoint("CENTER")
			QuestButton.Texture:SetTexture([[Interface\AddOns\Questie\Icons\available]])
		end
	end)
end)