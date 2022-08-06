local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G

function Module:ReskinPawn()
	if not IsAddOnLoaded("Pawn") then
		return
	end

	do
		-- General
		PawnUIFrame:StripTextures()
		PawnUIFrame:CreateBorder()
		PawnUIFrame_TinyCloseButton:SkinCloseButton()
		PawnUIScaleSelectorScrollFrameScrollBar:SkinScrollBar()
		PawnUIStringDialogMultiLine:StripTextures()
		PawnUIStringDialogMultiLine:CreateBorder()
		-- SkinEditBox(PawnUIStringDialogMultiLine_TextBox)
		PawnUIStringDialogMultiLine.OKButton:SkinButton()
		PawnUIStringDialogMultiLine.CancelButton:SkinButton()

		-- PawnUI_InventoryPawnButton:SkinButton()
		-- PawnUI_InventoryPawnButton:SetNormalTexture(Texture)
		-- PawnUI_InventoryPawnButton:SetSize(40, 20)
		-- PawnUI_InventoryPawnButton:GetNormalTexture():SetTexCoord(0, 1, 0, 1)

		for i = 1, PawnUIFrame.numTabs do
			_G["PawnUIFrameTab"..i]:StripTextures()
			_G["PawnUIFrameTab"..i]:CreateBackdrop()
			_G["PawnUIFrameTab"..i].Backdrop:SetPoint("TOPLEFT", _G["PawnUIFrameTab"..i], "TOPLEFT", 12, -4)
			_G["PawnUIFrameTab"..i].Backdrop:SetPoint("BOTTOMRIGHT", _G["PawnUIFrameTab"..i], "BOTTOMRIGHT", -12, 4)
		end

		-- Scale
		PawnUIFrame_RenameScaleButton:SkinButton()
		PawnUIFrame_DeleteScaleButton:SkinButton()
		PawnUIFrame_ShowScaleCheck:SetSize(18, 18)
		PawnUIFrame_ShowScaleCheck:SkinCheckBox()
		PawnUIFrame_ImportScaleButton:SkinButton()
		PawnUIFrame_ExportScaleButton:SkinButton()
		PawnUIFrame_CopyScaleButton:SkinButton()
		PawnUIFrame_NewScaleFromDefaultsButton:SkinButton()
		PawnUIFrame_NewScaleButton:SkinButton()
		PawnUIFrame_AutoSelectScalesOnButton:SkinButton() -- huge button, with highlight
		PawnUIFrame_AutoSelectScalesOffButton:SkinButton() -- huge button, with highlight
		PawnUIFrame_ScaleColorSwatch:StripTextures(4)
		PawnUIFrame_ScaleColorSwatch:CreateBackdrop()
		PawnUIFrame_ScaleColorSwatch.Backdrop:SetPoint("TOPLEFT", PawnUIFrame_ScaleColorSwatch, "TOPLEFT", 8, -8)
		PawnUIFrame_ScaleColorSwatch.Backdrop:SetPoint("BOTTOMRIGHT", PawnUIFrame_ScaleColorSwatch, "BOTTOMRIGHT", -8, 8)

		-- Weights
		PawnUIFrame_StatsListScrollBar:SkinScrollBar()
		PawnUIFrame_NormalizeValuesCheck:SkinCheckBox()
		PawnUIFrame_NormalizeValuesCheck:SetSize(18, 18)
		PawnUIFrame_StatValueBox:StripTextures()
		PawnUIFrame_StatValueBox:CreateBorder()
		PawnUIFrame_ClearValueButton:SkinButton()

		-- Compare
		PawnUICompareItemIcon1:StripTextures()
		PawnUICompareItemIcon1:GetNormalTexture():SetTexCoord(unpack(K.TexCoords))
		PawnUICompareItemIcon1:SkinButton()
		PawnUICompareItemIcon2:StripTextures()
		PawnUICompareItemIcon2:GetNormalTexture():SetTexCoord(unpack(K.TexCoords))
		PawnUICompareItemIcon2:SkinButton()
		PawnUIFrame_ClearItemsButton:SkinButton()
		PawnUIFrame_CompareSwapButton:SkinButton()
		PawnUICompareScrollFrameScrollBar:SkinScrollBar()
		PawnUIFrame_ScaleSelector_SpecIcon:SetTexCoord(unpack(K.TexCoords))
		PawnUIScaleSelectorAuto:CreateBackdrop()
		PawnUIScaleSelectorAuto.Backdrop:SetAllPoints(PawnUIFrame_ScaleSelector_SpecIcon)

		-- Lets add our own icon to PawnUICompareItemIcon1
		if not PawnUICompareItemIcon1.Icon then
			PawnUICompareItemIcon1.Icon = PawnUICompareItemIcon1:CreateTexture(nil, "ARTWORK")
			PawnUICompareItemIcon1.Icon:SetAllPoints(PawnUICompareItemIcon1)
			PawnUICompareItemIcon1.Icon:SetTexCoord(unpack(K.TexCoords))
			PawnUICompareItemIcon1.Icon:SetTexture("Interface\\LootFrame\\LootPanel-Icon")
			--PawnUICompareItemIcon1.Icon:SetDesaturated(1)
			PawnUICompareItemIcon1.Icon:SetAlpha(0.5)
			PawnUICompareItemIcon1.Icon = true
		end

		-- Lets add our own icon to PawnUICompareItemIcon2
		if not PawnUICompareItemIcon2.Icon then
			PawnUICompareItemIcon2.Icon = PawnUICompareItemIcon2:CreateTexture(nil, "ARTWORK")
			PawnUICompareItemIcon2.Icon:SetAllPoints()
			PawnUICompareItemIcon2.Icon:SetTexCoord(unpack(K.TexCoords))
			PawnUICompareItemIcon2.Icon:SetTexture("Interface\\LootFrame\\LootPanel-Icon")
			--PawnUICompareItemIcon2.Icon:SetDesaturated(1)
			PawnUICompareItemIcon2.Icon:SetAlpha(0.5)
			PawnUICompareItemIcon2.Icon = true
		end

		-- Lets add our own icon to PawnUIFrame_ClearItemsButton
		if not PawnUIFrame_ClearItemsButton.Icon then
			PawnUIFrame_ClearItemsButton.Icon = PawnUIFrame_ClearItemsButton:CreateTexture(nil, "ARTWORK")
			PawnUIFrame_ClearItemsButton.Icon:SetAllPoints()
			PawnUIFrame_ClearItemsButton.Icon:SetTexCoord(unpack(K.TexCoords))
			PawnUIFrame_ClearItemsButton.Icon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
			--PawnUIFrame_ClearItemsButton.Icon:SetDesaturated(1)
			PawnUIFrame_ClearItemsButton.Icon:SetAlpha(0.5)
			PawnUIFrame_ClearItemsButton.Icon = true
		end

		-- Gems
		PawnUIFrame_GemQualityLevelBox:StripTextures(2)
		PawnUIFrame_GemQualityLevelBox:CreateBackdrop()
		PawnUIFrame_GemQualityLevelBox.Backdrop:SetPoint("TOPLEFT", PawnUIFrame_GemQualityLevelBox, "TOPLEFT", -3, -4)
		PawnUIFrame_GemQualityLevelBox.Backdrop:SetPoint("BOTTOMRIGHT", PawnUIFrame_GemQualityLevelBox, "BOTTOMRIGHT", -1, 4)
		PawnUIGemScrollFrameScrollBar:SkinScrollBar()

		-- Options
		PawnUIFrame_ResetUpgradesButton:SkinButton()
		PawnUIFrame_EnchantedValuesCheck:SkinCheckBox()
		PawnUIFrame_EnchantedValuesCheck:SetSize(18, 18)
		PawnUIFrame_ShowIconsCheck:SkinCheckBox()
		PawnUIFrame_ShowIconsCheck:SetSize(18, 18)
		PawnUIFrame_ShowSpecIconsCheck:SkinCheckBox()
		PawnUIFrame_ShowSpecIconsCheck:SetSize(18, 18)
		PawnUIFrame_AlignRightCheck:SkinCheckBox()
		PawnUIFrame_AlignRightCheck:SetSize(18, 18)
		PawnUIFrame_ColorTooltipBorderCheck:SkinCheckBox()
		PawnUIFrame_ColorTooltipBorderCheck:SetSize(18, 18)
		PawnUIFrame_ShowBagUpgradeAdvisorCheck:SkinCheckBox()
		PawnUIFrame_ShowBagUpgradeAdvisorCheck:SetSize(18, 18)
		PawnUIFrame_ShowLootUpgradeAdvisorCheck:SkinCheckBox()
		PawnUIFrame_ShowLootUpgradeAdvisorCheck:SetSize(18, 18)
		PawnUIFrame_ShowQuestUpgradeAdvisorCheck:SkinCheckBox()
		PawnUIFrame_ShowQuestUpgradeAdvisorCheck:SetSize(18, 18)
		PawnUIFrame_ShowSocketingAdvisorCheck:SkinCheckBox()
		PawnUIFrame_ShowSocketingAdvisorCheck:SetSize(18, 18)
		PawnUIFrame_IgnoreGemsWhileLevelingCheck:SkinCheckBox()
		PawnUIFrame_IgnoreGemsWhileLevelingCheck:SetSize(18, 18)
		PawnUIFrame_ShowItemLevelUpgradesCheck:SkinCheckBox()
		PawnUIFrame_ShowItemLevelUpgradesCheck:SetSize(18, 18)
		PawnUIFrame_DebugCheck:SkinCheckBox()
		PawnUIFrame_DebugCheck:SetSize(18, 18)
		PawnUIFrame_ShowItemIDsCheck:SkinCheckBox()
		PawnUIFrame_ShowItemIDsCheck:SetSize(18, 18)
	end
end