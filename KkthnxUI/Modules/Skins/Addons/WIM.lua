local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G

function Module:ReskinWIM()
	if not IsAddOnLoaded("WIM") then
		return
	end

	if not C["Skins"].WIM then
		return
	end

	local WIM = _G.WIM
	local backdrops = {"tl", "tr", "bl", "br", "t", "b", "l", "r", "bg"}
	local funcs = {"SetNormalTexture", "SetPushedTexture", "SetDisabledTexture", "SetHighlightTexture", "SetWidth", "SetHeight"}

	local function disableSkin(button)
		for _, func in pairs(funcs) do
			if button[func] then button[func] = K.Noop end
		end
	end

	local function reskinChatFrame(frame)
		local backdrop = frame.widgets.Backdrop
		local msgbox = frame.widgets.msg_box
		local chat = frame.widgets.chat_display
		local up = frame.widgets.scroll_up
		local down = frame.widgets.scroll_down
        local close = frame.widgets.close

		for _, v in pairs(backdrops) do
			backdrop[v]:SetTexture(nil)
			backdrop[v].SetTexture = K.Noop
		end
		backdrop:CreateBorder()

        msgbox.bg = msgbox.bg or CreateFrame("Frame", nil, msgbox)
		msgbox.bg:SetPoint("TOPLEFT", -6, -2)
		msgbox.bg:SetPoint("BOTTOMRIGHT", K.Mult, 2)
		msgbox.bg:SetFrameLevel(msgbox:GetFrameLevel())
		msgbox.bg:CreateBorder()

        chat.bg = chat.bg or CreateFrame("Frame", nil, chat)
		chat.bg:SetPoint("TOPLEFT", -6, K.Mult)
		chat.bg:SetPoint("BOTTOMRIGHT", 4, -6)
		chat.bg:SetFrameLevel(chat:GetFrameLevel())
		chat.bg:CreateBorder()

		K.ReskinArrow(up, "up")
		up:SetPoint("TOPRIGHT", -10, -49)
		disableSkin(up)
		K.ReskinArrow(down, "down")
		down:SetPoint("BOTTOMRIGHT", -10, 33)
		disableSkin(down)
        K.ReskinArrow(close, "down")
		disableSkin(close)

		close:SetPoint("TOPRIGHT", -7, -7)

		frame.circle = frame:CreateTexture(nil, "ARTWORK")
		frame.circle:SetTexture("Interface\\WorldStateFrame\\ICONS-CLASSES")
		frame.circle:SetSize(32, 32)
		frame.circle:SetPoint("TOPLEFT", 8, -8)
		frame.circle:Hide()

        local circleBorder = CreateFrame("Frame", nil, frame)
		circleBorder:SetFrameLevel(frame:GetFrameLevel())
		circleBorder:SetAllPoints(frame.circle)
		circleBorder:CreateBorder()
		circleBorder:Hide()

		if frame.UpdateIcon then
			hooksecurefunc(frame, "UpdateIcon", function(self)
				self.circle:Hide()
				circleBorder:Hide()
				if(WIM.constants.classes[self.class]) then
					local classTag = WIM.constants.classes[self.class].tag
					local tcoords = CLASS_ICON_TCOORDS[classTag]
					if tcoords then
						self.widgets.class_icon:SetTexture(nil)
						self.circle:SetTexCoord(tcoords[1], tcoords[2], tcoords[3], tcoords[4])
						self.circle:Show()
						circleBorder:Show()
					end
				end
			end)
		end
	end

	local minimap = _G.WIM3MinimapButton
	if minimap then
		for i = 1, minimap:GetNumRegions() do
			local region = select(i, minimap:GetRegions())
			local texture = region.GetTexture and region:GetTexture()
			if texture and texture ~= "" then
				if type(texture) == "number" and texture == 136430 then
					region:SetTexture("")
				end

				if type(texture) == "string" and (texture:find("TempPortraitAlphaMask") or texture:find("TrackingBorder")) then
					region:SetTexture("")
				end
			end
		end
	end

	local function reskinFunc()
		local index = 1
		local msgFrame = _G["WIM3_msgFrame"..index]
		while msgFrame do
			if not msgFrame.styled then
				reskinChatFrame(msgFrame)
				msgFrame.styled = true
			end

			index = index + 1
			msgFrame = _G["WIM3_msgFrame"..index]
		end

		index = 1
		local button = _G["WIM_ShortcutBarButton"..index]
		while button do
			if button.icon and not button.styled then
                button:SetNormalTexture("")
				button:SetPushedTexture("")
				button.SetPushedTexture = K.Noop
				button.icon:SetTexCoord(unpack(K.TexCoords))

                local iconBorder = CreateFrame("Frame", nil, button)
		        iconBorder:SetAllPoints(button.icon)
		        iconBorder:SetFrameLevel(button:GetFrameLevel())
		        iconBorder:CreateBorder()

				button.styled = true
			end
			index = index + 1
			button = _G["WIM_ShortcutBarButton"..index]
		end
	end

	hooksecurefunc(WIM, "CreateWhisperWindow", reskinFunc)
	hooksecurefunc(WIM, "CreateChatWindow", reskinFunc)
	hooksecurefunc(WIM, "CreateW2WWindow", reskinFunc)
	hooksecurefunc(WIM, "ShowDemoWindow", reskinFunc)
end