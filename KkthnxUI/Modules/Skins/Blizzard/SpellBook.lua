local K, C = unpack(select(2, ...))

local _G = _G
local pairs = pairs
local table_insert = table.insert

local BOOKTYPE_PROFESSION = _G.BOOKTYPE_PROFESSION
local GetProfessionInfo = _G.GetProfessionInfo
local IsPassiveSpell = _G.IsPassiveSpell
local SPELLS_PER_PAGE = _G.SPELLS_PER_PAGE
local hooksecurefunc = _G.hooksecurefunc

table_insert(C.defaultThemes, function()
	SpellBookFrame:SetIgnoreParentScale(true)
	SpellBookFrame:SetScale(C["General"].UIScale)

	for i = 1, SPELLS_PER_PAGE do
		local bu = _G["SpellButton"..i]
		local ic = _G["SpellButton"..i.."IconTexture"]

		bu:StripTextures()
		bu:DisableDrawLayer("BACKGROUND")

		ic:SetTexCoord(unpack(K.TexCoords))

		ic.bg = CreateFrame("Frame", nil, bu)
		ic.bg:SetAllPoints(ic)
		ic.bg:SetFrameLevel(bu:GetFrameLevel())
		ic.bg:CreateBorder()
	end

	hooksecurefunc("SpellButton_UpdateButton", function(self)
		if SpellBookFrame.bookType == BOOKTYPE_PROFESSION then
			return
		end

		for i = 1, SPELLS_PER_PAGE do
			local button = _G["SpellButton"..i]
			if button.SpellHighlightTexture then
				button.SpellHighlightTexture:SetTexture("")
			end
		end

		local slot = SpellBook_GetSpellBookSlot(self)
		local isPassive = IsPassiveSpell(slot, SpellBookFrame.bookType)
		local name = self:GetName()
		local highlightTexture = _G[name.."Highlight"]
		highlightTexture:SetPoint("TOPLEFT", 2, -2)
		highlightTexture:SetPoint("BOTTOMRIGHT", -2, 2)
		if isPassive then
			highlightTexture:SetColorTexture(1, 1, 1, 0)
		else
			highlightTexture:SetColorTexture(1, 1, 1, .25)
		end

		local ic = _G[name.."IconTexture"]
		if ic.bg then
			ic.bg:SetShown(ic:IsShown())
		end
	end)
end)