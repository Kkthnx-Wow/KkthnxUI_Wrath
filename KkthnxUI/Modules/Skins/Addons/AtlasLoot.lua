local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

function Module:ReskinAtlasLoot()
	if not C["Skins"].AtlasLoot then
		return
	end

	if not K.CheckAddOnState("AtlasLootClassic") then
		return
	end

	local AtlasLootFrame = _G["AtlasLoot_GUI-Frame"]
	AtlasLootFrame:StripTextures()
	AtlasLootFrame:CreateBorder()
	AtlasLootFrame.CloseButton:SkinCloseButton()
	AtlasLootFrame.titleFrame:StripTextures()

	local function SkinDropDown(Frame)
		_G[Frame]:StripTextures()
		_G[Frame]:CreateBackdrop()
		_G[Frame].Backdrop:SetPoint("TOPLEFT", 2, -2)
		_G[Frame].Backdrop:SetPoint("BOTTOMRIGHT", -2, 2)
		K.ReskinArrow(_G[Frame.."-button"], "down")
		local a, b, c, d = _G[Frame.."-button"]:GetPoint()
		_G[Frame.."-button"]:SetPoint(a, b, c, d - 8, 0)
		_G[Frame]:HookScript("OnUpdate", function()
			for i = 1, 3 do
				local CatFrame = _G["AtlasLoot-DropDown-CatFrame"..i]
				if CatFrame and not CatFrame.IsSkinned then
					local r, g, b = CatFrame:GetBackdropColor()
					CatFrame:StripTextures()
					CatFrame:CreateBorder()
					CatFrame.KKUI_Border:SetVertexColor(r, g, b)

					CatFrame:HookScript("OnShow", function(self)
						local a, f, c, d, e = self:GetPoint()
						self:SetPoint(a, f, c, d, e - 6)
					end)

					CatFrame:GetScript("OnShow")(CatFrame)
					CatFrame.IsSkinned = true
				end
			end
		end)
	end

	SkinDropDown("AtlasLoot-DropDown-1")
	SkinDropDown("AtlasLoot-DropDown-2")

	for i = 1, 3 do
		_G["AtlasLoot-Select-"..i]:StripTextures()
		_G["AtlasLoot-Select-"..i]:CreateBorder()
	end

	local AtlasLootItemFrame = _G["AtlasLoot_GUI-ItemFrame"]
	local AtlasLootItemFrameDownBG = _G["AtlasLoot_GUI-ItemFrame-downBG"]
	AtlasLootItemFrame:StripTextures()
	AtlasLootItemFrame:CreateBorder()
	AtlasLootItemFrame.nextPageButton:SetPoint("RIGHT", AtlasLootItemFrameDownBG, -6, 0)
	K.ReskinArrow(AtlasLootItemFrame.nextPageButton, "right")
	AtlasLootItemFrame.modelButton:SkinButton()
	AtlasLootItemFrame.soundsButton:SkinButton()
	K.ReskinArrow(AtlasLootItemFrame.prevPageButton, "left")
	AtlasLootItemFrame.itemsButton:SkinButton()
	AtlasLootItemFrame.clasFilterButton:SkinButton()
	AtlasLootItemFrame.clasFilterButton.texture:SetAllPoints()
	AtlasLootItemFrame.clasFilterButton:HookScript("OnUpdate", function(self)
		if self.texture:GetTexture() == "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes" then
			self.texture:SetTexCoord(CLASS_ICON_TCOORDS[K.Class][1] + 0.015, CLASS_ICON_TCOORDS[K.Class][2] - 0.02, CLASS_ICON_TCOORDS[K.Class][3] + 0.018, CLASS_ICON_TCOORDS[K.Class][4] - .02)
		else
			self.texture:SetTexCoord(unpack(K.TexCoords))
		end
	end)
end