local K, C = unpack(select(2, ...))

local _G = _G
local table_insert = _G.table.insert

local hooksecurefunc = _G.hooksecurefunc

local blizzRegions = {
	"Left",
	"Middle",
	"Right",
	"Mid",
	"LeftDisabled",
	"MiddleDisabled",
	"RightDisabled",
	"TopLeft",
	"TopRight",
	"BottomLeft",
	"BottomRight",
	"TopMiddle",
	"MiddleLeft",
	"MiddleRight",
	"BottomMiddle",
	"MiddleMiddle",
	"TabSpacer",
	"TabSpacer1",
	"TabSpacer2",
	"_RightSeparator",
	"_LeftSeparator",
	"Cover",
	"Border",
	"Background",
	"TopTex",
	"TopLeftTex",
	"TopRightTex",
	"LeftTex",
	"BottomTex",
	"BottomLeftTex",
	"BottomRightTex",
	"RightTex",
	"MiddleTex",
	"Center",
}

-- Handle editbox
local function ReskinEditBox(self, height, width)
	local frameName = self.GetName and self:GetName()
	for _, region in pairs(blizzRegions) do
		region = frameName and _G[frameName..region] or self[region]
		if region then
			region:SetAlpha(0)
		end
	end

	local bg = CreateFrame("Frame", nil, self)
	bg:SetAllPoints(self)
	bg:SetFrameLevel(self:GetFrameLevel())
	bg:SetPoint("TOPLEFT", -2, 0)
	bg:SetPoint("BOTTOMRIGHT")
	bg:CreateBorder()

	if height then
		self:SetHeight(height)
	end

	if width then
		self:SetWidth(width)
	end
end

table_insert(C.defaultThemes, function()
	for i = 1, 4 do
		local frame = _G["StaticPopup"..i]
		local bu = _G["StaticPopup"..i.."ItemFrame"]
		local close = _G["StaticPopup"..i.."CloseButton"]

		local gold = _G["StaticPopup"..i.."MoneyInputFrameGold"]
		local silver = _G["StaticPopup"..i.."MoneyInputFrameSilver"]
		local copper = _G["StaticPopup"..i.."MoneyInputFrameCopper"]

		_G["StaticPopup"..i.."ItemFrameNameFrame"]:Hide()
		_G["StaticPopup"..i.."ItemFrameIconTexture"]:SetTexCoord(.08, .92, .08, .92)

		bu:SetNormalTexture("")
		bu:SetHighlightTexture("")
		bu:SetPushedTexture("")
		bu:CreateBorder()
		bu.IconBorder:SetAlpha(0)

		silver:SetPoint("LEFT", gold, "RIGHT", 1, 0)
		copper:SetPoint("LEFT", silver, "RIGHT", 1, 0)

		frame:StripTextures()
		frame:CreateBorder()
		for j = 1, 4 do
			frame["button"..j]:SkinButton()
		end
		frame["extraButton"]:SkinButton()
		close:SkinCloseButton()

		ReskinEditBox(_G["StaticPopup"..i.."EditBox"], 20)
		ReskinEditBox(gold)
		ReskinEditBox(silver)
		ReskinEditBox(copper)
	end

	hooksecurefunc("StaticPopup_Show", function(which, _, _, data)
		local info = StaticPopupDialogs[which]

		if not info then
			return
		end

		local dialog = nil
		dialog = StaticPopup_FindVisible(which, data)

		if not dialog then
			local index = 1
			if info.preferredIndex then
				index = info.preferredIndex
			end

			for i = index, STATICPOPUP_NUMDIALOGS do
				local frame = _G["StaticPopup"..i]
				if not frame:IsShown() then
					dialog = frame
					break
				end
			end

			if not dialog and info.preferredIndex then
				for i = 1, info.preferredIndex do
					local frame = _G["StaticPopup"..i]
					if not frame:IsShown() then
						dialog = frame
						break
					end
				end
			end
		end

		if not dialog then
			return
		end

		if info.closeButton then
			local closeButton = _G[dialog:GetName().."CloseButton"]

			closeButton:SetNormalTexture("")
			closeButton:SetPushedTexture("")

			if info.closeButtonIsHide then
				for _, pixel in pairs(closeButton.pixels) do
					pixel:Hide()
				end
				closeButton.minimize:Show()
			else
				for _, pixel in pairs(closeButton.pixels) do
					pixel:Show()
				end
				closeButton.minimize:Hide()
			end
		end
	end)
end)

-- PlayerReportFrame
PlayerReportFrame:HookScript("OnShow", function(self)
	if not self.styled then
		self:StripTextures()
		self:CreateBorder()
		self.Comment:StripTextures()
		ReskinEditBox(self.Comment)
		self.ReportButton:SkinButton()
		self.CancelButton:SkinButton()

		self.styled = true
	end
end)