local K, C = unpack(select(2, ...))

local _G = _G

local hooksecurefunc = _G.hooksecurefunc

local function replaceBlueColor(bar, r, g, b)
	if r == 0 and g == 0 and b > 0.99 then
		bar:SetStatusBarColor(0, 0.6, 1, 0.5)
	end
end

tinsert(C.defaultThemes, function()
	for _, slot in pairs({ PaperDollItemsFrame:GetChildren() }) do
		if slot:IsObjectType("Button") then
			local icon = _G[slot:GetName() .. "IconTexture"]

			slot:StripTextures()
			slot:CreateBorder()
			slot:StyleButton(slot)
			--icon:SetTexCoord(unpack(K.TexCoords))
		end
	end

	hooksecurefunc("PaperDollItemSlotButton_Update", function(slot)
		local highlight = slot:GetHighlightTexture()
		highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
		highlight:SetBlendMode("ADD")
		highlight:SetAllPoints()
	end)

	local newResIcons = { 136116, 135826, 136074, 135843, 135945 }
	for i = 1, 5 do
		local bu = _G["MagicResFrame" .. i]
		bu:SetSize(24, 24)
		local icon = bu:GetRegions()

		local iconborder = CreateFrame("Frame", nil, bu)
		iconborder:SetAllPoints(icon)
		iconborder:SetFrameLevel(bu:GetFrameLevel())
		iconborder:CreateBorder()

		icon:SetTexCoord(unpack(K.TexCoords))
		icon:SetTexture(newResIcons[i])
		icon:SetAlpha(0.5)
	end

	CharacterModelFrame:HookScript("OnMouseWheel", Model_OnMouseWheel)

	local function UpdateFactionSkins()
		for i = 1, GetNumFactions() do
			local bar = _G["ReputationBar" .. i]
			if bar and not bar.styled then
				bar:SetStatusBarTexture(K.GetTexture(C["UITextures"].SkinTextures))
				bar.styled = true
			end
		end
	end

	-- ReputationFrame:HookScript("OnShow", UpdateFactionSkins)
	-- ReputationFrame:HookScript("OnEvent", UpdateFactionSkins)

	SkillDetailStatusBar:SetStatusBarTexture(K.GetTexture(C["UITextures"].SkinTextures))
	hooksecurefunc(SkillDetailStatusBar, "SetStatusBarColor", replaceBlueColor)

	for i = 1, 12 do
		local name = "SkillRankFrame" .. i
		local bar = _G[name]
		bar:SetStatusBarTexture(K.GetTexture(C["UITextures"].SkinTextures))
		hooksecurefunc(bar, "SetStatusBarColor", replaceBlueColor)
	end
end)
