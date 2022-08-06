local K, C = unpack(select(2, ...))

local _G = _G
local table_insert = _G.table.insert

local hooksecurefunc = _G.hooksecurefunc

table_insert(C.defaultThemes, function()
	-- Battlenet toast frame
	BNToastFrame:SetClampedToScreen(true)
	BNToastFrame:SetBackdrop(nil)
	BNToastFrame:CreateBorder()
	-- BNToastFrame.TooltipFrame:SetBackdrop(nil)
	BNToastFrame.TooltipFrame:CreateBorder()
	BNToastFrame.CloseButton:SkinCloseButton()
	BNToastFrame.CloseButton:SetSize(32, 32)
	BNToastFrame.CloseButton:SetPoint("TOPRIGHT", 4, 4)

	-- if C["DataTex"].Friends then
	-- 	return
	-- end

	local friendTex = "Interface\\HELPFRAME\\ReportLagIcon-Chat"
	local queueTex = "Interface\\HELPFRAME\\HelpIcon-ItemRestoration"
	local homeTex = "Interface\\Buttons\\UI-HomeButton"

	ChatFrameChannelButton:SkinButton()
	ChatFrameChannelButton:SetSize(16, 16)

	ChatFrameMenuButton:SkinButton()
	ChatFrameMenuButton:SetSize(16, 16)
	ChatFrameMenuButton:SetNormalTexture(homeTex)
	ChatFrameMenuButton:SetPushedTexture(homeTex)

	VoiceChatChannelActivatedNotification:SetBackdrop(nil)
	VoiceChatChannelActivatedNotification:CreateBorder()
	VoiceChatChannelActivatedNotification.CloseButton:SkinCloseButton()
	VoiceChatChannelActivatedNotification.CloseButton:SetSize(32, 32)
	VoiceChatChannelActivatedNotification.CloseButton:SetPoint("TOPRIGHT", 4, 4)
end)