local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

function Module:ReskinLFGBulletinBoard()
	if not C["Skins"].LFGBulletinBoard then
		return
	end

	if not K.CheckAddOnState("LFGBulletinBoard") then
		return
	end

	local GroupBulletinBoardFrame = _G.GroupBulletinBoardFrame

	GroupBulletinBoardFrame:StripTextures()
	GroupBulletinBoardFrame:CreateBorder()

		GroupBulletinBoardFrameCloseButton:ClearAllPoints()
		GroupBulletinBoardFrameCloseButton:SetPoint("TOPRIGHT", GroupBulletinBoardFrame, "TOPRIGHT", 0, 1)
		GroupBulletinBoardFrameCloseButton:StripTextures(true)
		GroupBulletinBoardFrameCloseButton:SetSize(32, 32)
		GroupBulletinBoardFrameCloseButton:SkinCloseButton()

	GroupBulletinBoardFrameSettingsButton:SetSize(16, 16)
	GroupBulletinBoardFrameSettingsButton:SkinButton()

	GroupBulletinBoardFrame_ScrollFrameScrollBar:SkinScrollBar()
end