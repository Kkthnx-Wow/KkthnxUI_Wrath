local K = unpack(KkthnxUI)
local oUF = K.oUF

-- Sourced: yClassColors (yleaf)
-- Edited: KkthnxUI (Kkthnx)

local _G = _G
local string_format = _G.string.format
local table_insert = _G.table.insert
local string_split = _G.string.split

local BNET_CLIENT_WOW = _G.BNET_CLIENT_WOW
local BNGetFriendInfo = _G.BNGetFriendInfo
local BNGetGameAccountInfo = _G.BNGetGameAccountInfo
local FRIENDS_BUTTON_TYPE_BNET = _G.FRIENDS_BUTTON_TYPE_BNET
local FRIENDS_BUTTON_TYPE_WOW = _G.FRIENDS_BUTTON_TYPE_WOW
local FRIENDS_WOW_NAME_COLOR_CODE = _G.FRIENDS_WOW_NAME_COLOR_CODE
local FauxScrollFrame_GetOffset = _G.FauxScrollFrame_GetOffset
local GUILDMEMBERS_TO_DISPLAY = _G.GUILDMEMBERS_TO_DISPLAY
local GetQuestDifficultyColor = _G.GetQuestDifficultyColor
local UIDropDownMenu_GetSelectedID = _G.UIDropDownMenu_GetSelectedID
local WHOS_TO_DISPLAY = _G.WHOS_TO_DISPLAY

local SCORE_BUTTONS_MAX = _G.SCORE_BUTTONS_MAX or 20
local FRIENDS_LEVEL_TEMPLATE = _G.FRIENDS_LEVEL_TEMPLATE:gsub("%%d", "%%s")
FRIENDS_LEVEL_TEMPLATE = FRIENDS_LEVEL_TEMPLATE:gsub("%$d", "%$s")
local columnTable = {}
local rankColor = { 1, 0, 0, 1, 1, 0, 0, 1, 0 }

-- Colors
local function yClassColors(class, showRGB)
	local color = K.ClassColors[K.ClassList[class] or class]
	if not color then
		color = K.ClassColors["PRIEST"]
	end

	if showRGB then
		return color.r, color.g, color.b
	else
		return "|c" .. color.colorStr
	end
end

local function diffColor(level)
	return K.RGBToHex(GetQuestDifficultyColor(level))
end

-- Guild
local function updateGuildStatus()
	local guildIndex
	local playerArea = GetRealZoneText()
	local guildOffset = FauxScrollFrame_GetOffset(GuildListScrollFrame)
	if FriendsFrame.playerStatusFrame then
		for i = 1, GUILDMEMBERS_TO_DISPLAY, 1 do
			guildIndex = guildOffset + i
			local fullName, _, _, level, class, zone, _, _, online = GetGuildRosterInfo(guildIndex)
			if fullName and online then
				local r, g, b = yClassColors(class, true)
				_G["GuildFrameButton" .. i .. "Name"]:SetTextColor(r, g, b)
				if zone == playerArea then
					_G["GuildFrameButton" .. i .. "Zone"]:SetTextColor(0, 1, 0)
				end

				local color = GetQuestDifficultyColor(level)
				_G["GuildFrameButton" .. i .. "Level"]:SetTextColor(color.r, color.g, color.b)
				_G["GuildFrameButton" .. i .. "Class"]:SetTextColor(r, g, b)
			end
		end
	else
		for i = 1, GUILDMEMBERS_TO_DISPLAY, 1 do
			guildIndex = guildOffset + i
			local fullName, _, rankIndex, _, class, _, _, _, online = GetGuildRosterInfo(guildIndex)
			if fullName and online then
				local r, g, b = yClassColors(class, true)
				_G["GuildFrameGuildStatusButton" .. i .. "Name"]:SetTextColor(r, g, b)
				local lr, lg, lb = oUF:RGBColorGradient(rankIndex, 10, unpack(rankColor))
				if lr then
					_G["GuildFrameGuildStatusButton" .. i .. "Rank"]:SetTextColor(lr, lg, lb)
				end
			end
		end
	end
end

local function updateFriendsFrame()
	local scrollFrame = _G.FriendsFrameFriendsScrollFrame
	local buttons = scrollFrame.buttons
	local playerArea = GetRealZoneText()

	for i = 1, #buttons do
		local nameText, infoText
		local button = buttons[i]
		if button:IsShown() then
			if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
				local info = C_FriendList.GetFriendInfoByIndex(button.id)
				if info and info.connected then
					nameText = yClassColors(info.className) .. info.name .. "|r, " .. string_format(FRIENDS_LEVEL_TEMPLATE, diffColor(info.level) .. info.level .. "|r", info.className)
					if info.area == playerArea then
						infoText = string_format("|cff00ff00%s|r", info.area)
					end
				end
			elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
				local _, presenceName, _, _, _, gameID, client, isOnline = BNGetFriendInfo(button.id)
				if isOnline and client == BNET_CLIENT_WOW then
					local _, charName, _, _, _, faction, _, class, _, zoneName = BNGetGameAccountInfo(gameID)
					if presenceName and charName and class and faction == UnitFactionGroup("player") then
						nameText = presenceName .. " " .. FRIENDS_WOW_NAME_COLOR_CODE .. "(" .. yClassColors(class) .. charName .. FRIENDS_WOW_NAME_COLOR_CODE .. ")"
						if zoneName == playerArea then
							infoText = string_format("|cff00ff00%s|r", zoneName)
						end
					end
				end
			end
		end

		if nameText then
			button.name:SetText(nameText)
		end
		if infoText then
			button.info:SetText(infoText)
		end
	end
end

local function updateWhoList()
	local whoOffset = FauxScrollFrame_GetOffset(WhoListScrollFrame)
	local playerZone = GetRealZoneText()
	local playerGuild = GetGuildInfo("player")
	local playerRace = UnitRace("player")

	for i = 1, WHOS_TO_DISPLAY, 1 do
		local index = whoOffset + i
		local nameText = _G["WhoFrameButton" .. i .. "Name"]
		local levelText = _G["WhoFrameButton" .. i .. "Level"]
		local variableText = _G["WhoFrameButton" .. i .. "Variable"]
		local info = C_FriendList.GetWhoInfo(index)
		if info then
			local guild, level, race, zone, class = info.fullGuildName, info.level, info.raceStr, info.area, info.filename
			if zone == playerZone then
				zone = "|cff00ff00" .. zone
			end

			if guild == playerGuild then
				guild = "|cff00ff00" .. guild
			end

			if race == playerRace then
				race = "|cff00ff00" .. race
			end

			wipe(columnTable)
			table_insert(columnTable, zone)
			table_insert(columnTable, guild)
			table_insert(columnTable, race)

			nameText:SetTextColor(yClassColors(class, true))
			levelText:SetText(diffColor(level) .. level)
			variableText:SetText(columnTable[UIDropDownMenu_GetSelectedID(WhoFrameDropDown)])
		end
	end
end

local function updateStateScoreFrame()
	local offset = FauxScrollFrame_GetOffset(WorldStateScoreScrollFrame)

	for i = 1, SCORE_BUTTONS_MAX do
		local index = offset + i
		local fullName, _, _, _, _, faction, _, _, class = GetBattlefieldScore(index)
		if fullName then
			local name, realm = string_split(" - ", fullName)
			name = yClassColors(class) .. name .. "|r"
			if fullName == K.Name then
				name = "> " .. name .. " <"
			end

			if realm then
				local color = "|cffff1919"
				if faction == 1 then
					color = "|cff00adf0"
				end

				realm = color .. realm .. "|r"
				name = name .. " - " .. realm
			end

			local button = _G["WorldStateScoreButton" .. i]
			if button then
				button.name.text:SetText(name)
			end
		end
	end
end

hooksecurefunc(FriendsFrameFriendsScrollFrame, "update", updateFriendsFrame)
hooksecurefunc("FriendsFrame_UpdateFriends", updateFriendsFrame)
hooksecurefunc("WhoList_Update", updateWhoList)
hooksecurefunc("GuildStatus_Update", updateGuildStatus)
hooksecurefunc("WorldStateScoreFrame_Update", updateStateScoreFrame)
