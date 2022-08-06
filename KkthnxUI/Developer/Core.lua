local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Dev")

-- Buttons to enhance popup menu
function Module:MenuButton_AddFriend()
	C_FriendList.AddFriend(Module.MenuButtonName)
end

function Module:MenuButton_CopyName()
	local editBox = ChatEdit_ChooseBoxForSend()
	local hasText = (editBox:GetText() ~= "")
	ChatEdit_ActivateChat(editBox)
	editBox:Insert(Module.MenuButtonName)
	if not hasText then
        editBox:HighlightText()
    end
end

function Module:MenuButton_GuildInvite()
	GuildInvite(Module.MenuButtonName)
end

function Module:QuickMenuButton()
	--if not C.db["Misc"]["MenuButton"] then return end

	local menuList = {
		{text = ADD_FRIEND, func = Module.MenuButton_AddFriend, color = {0, .6, 1}},
		{text = gsub(CHAT_GUILD_INVITE_SEND, HEADER_COLON, ""), func = Module.MenuButton_GuildInvite, color = {0, .8, 0}},
		{text = COPY_NAME, func = Module.MenuButton_CopyName, color = {1, 0, 0}},
	}

	local frame = CreateFrame("Frame", "KKUI_MenuButtonFrame", DropDownList1)
	frame:SetSize(10, 10)
	frame:SetPoint("TOPLEFT")
	frame:Hide()

	for i = 1, 3 do
		local button = CreateFrame("Button", nil, frame)
		button:SetSize(25, 10)
		button:SetPoint("TOPLEFT", frame, (i - 1) * 28 + 4, -4)

        button.Icon = button:CreateTexture(nil, "ARTWORK")
		button.Icon:SetAllPoints()
		button.Icon:SetTexCoord(unpack(K.TexCoords))
        button.Icon:SetTexture(C["Media"].Statusbars.KkthnxUIStatusbar)
		button.Icon:SetVertexColor(unpack(menuList[i].color))

        button:EnableMouse(true)
		button.HL = button:CreateTexture(nil, "HIGHLIGHT")
		button.HL:SetColorTexture(1, 1, 1, .25)
		button.HL:SetAllPoints(button.Icon)

		button:SetScript("OnClick", menuList[i].func)
		K.AddTooltip(button, "ANCHOR_TOP", menuList[i].text)
	end

	hooksecurefunc("ToggleDropDownMenu", function(level, _, dropdownMenu)
		if level and level > 1 then
            return
        end

		local unit = dropdownMenu.unit
		local isPlayer = unit and UnitIsPlayer(unit)
		local isFriendMenu = dropdownMenu == FriendsDropDown -- menus on FriendsFrame
		if not isPlayer and not dropdownMenu.chatType and not isFriendMenu then
			frame:Hide()
			return
		end

		local name = dropdownMenu.name
		local server = dropdownMenu.server
		if not server then
			server = K.Realm
		end
		Module.MenuButtonName = name.."-"..server
		frame:Show()
	end)
end

function Module:OnEnable()
    Module:QuickMenuButton()
end
