local _, C = unpack(select(2, ...))

local _G = _G
local table_insert = _G.table.insert

local hooksecurefunc = _G.hooksecurefunc

table_insert(C.defaultThemes, function()
	local StackSplitFrame = _G.StackSplitFrame
	StackSplitFrame:StripTextures()
	StackSplitFrame:CreateBackdrop('Transparent')

	StackSplitFrame.bg1 = CreateFrame('Frame', nil, StackSplitFrame)
	StackSplitFrame.bg1:CreateBorder()
	StackSplitFrame.bg1:SetPoint('TOPLEFT', 28, -18)
	StackSplitFrame.bg1:SetPoint('BOTTOMRIGHT', -26, 56)
	StackSplitFrame.bg1:SetFrameLevel(StackSplitFrame.bg1:GetFrameLevel() - 1)

	StackSplitOkayButton:SkinButton()
    StackSplitCancelButton:SkinButton()
end)