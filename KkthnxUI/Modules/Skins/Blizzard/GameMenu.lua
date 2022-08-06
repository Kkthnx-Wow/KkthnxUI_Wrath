local K, C = unpack(select(2, ...))

local _G = _G
local table_insert = _G.table.insert

table_insert(C.defaultThemes, function()
	GameMenuFrameHeader:StripTextures()
	GameMenuFrameHeader:ClearAllPoints()
	GameMenuFrameHeader:SetPoint("TOP", GameMenuFrame, 0, 7)
    GameMenuFrame:StripTextures()
	GameMenuFrame:CreateBorder(nil, nil, C["General"].BorderStyle.Value ~= "KkthnxUI_Pixel" and 32 or nil, nil, C["General"].BorderStyle.Value ~= "KkthnxUI_Pixel" and -10 or nil)

	local buttons = {
		GameMenuButtonHelp,
		GameMenuButtonWhatsNew,
		GameMenuButtonStore,
		GameMenuButtonOptions,
		GameMenuButtonUIOptions,
		GameMenuButtonKeybindings,
		GameMenuButtonMacros,
		GameMenuButtonAddons,
		GameMenuButtonLogout,
		GameMenuButtonQuit,
		GameMenuButtonContinue
	}

	for _, button in next, buttons do
		button:SkinButton()
	end

	GameMenuButtonLogoutText:SetTextColor(1, 1, 0)
	GameMenuButtonQuitText:SetTextColor(1, 0, 0)
	GameMenuButtonContinueText:SetTextColor(0, 1, 0)
end)