local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Infobar")

local _G = _G
local date = _G.date
local mod = _G.mod
local pairs = _G.pairs
local string_format = _G.string.format
local tonumber = _G.tonumber

local CALENDAR_FULLDATE_MONTH_NAMES = _G.CALENDAR_FULLDATE_MONTH_NAMES
local CALENDAR_WEEKDAY_NAMES = _G.CALENDAR_WEEKDAY_NAMES
local C_Calendar_GetNumPendingInvites = _G.C_Calendar.GetNumPendingInvites
local C_DateAndTime_GetCurrentCalendarTime = _G.C_DateAndTime.GetCurrentCalendarTime
local C_QuestLog_IsQuestFlaggedCompleted = _G.C_QuestLog.IsQuestFlaggedCompleted
local FULLDATE = _G.FULLDATE
local GameTime_GetGameTime = _G.GameTime_GetGameTime
local GameTime_GetLocalTime = _G.GameTime_GetLocalTime
local GameTooltip = _G.GameTooltip
local GetCVarBool = _G.GetCVarBool
local GetGameTime = _G.GetGameTime
local GetNumSavedInstances = _G.GetNumSavedInstances
local GetSavedInstanceInfo = _G.GetSavedInstanceInfo
local QUESTS_LABEL = _G.QUESTS_LABEL
local QUEST_COMPLETE = _G.QUEST_COMPLETE
local RequestRaidInfo = _G.RequestRaidInfo
local SecondsToTime = _G.SecondsToTime
local TIMEMANAGER_TICKER_12HOUR = _G.TIMEMANAGER_TICKER_12HOUR
local TIMEMANAGER_TICKER_24HOUR = _G.TIMEMANAGER_TICKER_24HOUR

local TimeDataText

-- Data

local questlist = {
	{ name = "Mean One", id = 6983 },
	{ name = "Blingtron", id = 34774 },
}

local function updateTimerFormat(color, hour, minute)
	if GetCVarBool("timeMgrUseMilitaryTime") then
		return string_format(color .. TIMEMANAGER_TICKER_24HOUR, hour, minute)
	else
		local timerUnit = K.MyClassColor .. (hour < 12 and "AM" or "PM")

		if hour >= 12 then
			if hour > 12 then
				hour = hour - 12
			end
		else
			if hour == 0 then
				hour = 12
			end
		end

		return string_format(color .. TIMEMANAGER_TICKER_12HOUR .. timerUnit, hour, minute)
	end
end

function Module:TimeOnUpdate(elapsed)
	self.timer = (self.timer or 3) + elapsed
	if self.timer > 5 then
		local color = C_Calendar_GetNumPendingInvites() > 0 and "|cffFF0000" or ""
		local hour, minute
		if GetCVarBool("timeMgrUseLocalTime") then
			hour, minute = tonumber(date("%H")), tonumber(date("%M"))
		else
			hour, minute = GetGameTime()
		end
		TimeDataText.Font:SetText(updateTimerFormat(color, hour, minute))

		self.timer = 0
	end
end

local title
local function addTitle(text)
	if not title then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(text .. ":")
		title = true
	end
end

function Module:TimeOnEnter()
	TimeDataTextEntered = true

	RequestRaidInfo()

	local r, g, b
	GameTooltip:SetOwner(TimeDataText, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(TimeDataText))
	GameTooltip:ClearLines()

	local today = C_DateAndTime_GetCurrentCalendarTime()
	local w, m, d, y = today.weekday, today.month, today.monthDay, today.year
	GameTooltip:AddLine(string_format(FULLDATE, CALENDAR_WEEKDAY_NAMES[w], CALENDAR_FULLDATE_MONTH_NAMES[m], d, y), 0.4, 0.6, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(L["Local Time"], GameTime_GetLocalTime(true), nil, nil, nil, 192 / 255, 192 / 255, 192 / 255)
	GameTooltip:AddDoubleLine(L["Realm Time"], GameTime_GetGameTime(true), nil, nil, nil, 192 / 255, 192 / 255, 192 / 255)

	-- Herioc/Mythic Dungeons
	title = false
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, diff, locked, extended, _, _, maxPlayers, diffName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
		if (diff == 2 or diff == 23) and (locked or extended) and name then
			addTitle("Saved Dungeon(s)")
			if extended then
				r, g, b = 0.3, 1, 0.3
			else
				r, g, b = 192 / 255, 192 / 255, 192 / 255
			end

			GameTooltip:AddDoubleLine(name .. " - " .. maxPlayers .. " " .. _G.PLAYER .. " (" .. diffName .. ") (" .. encounterProgress .. "/" .. numEncounters .. ")", SecondsToTime(reset, true, nil, 3), 1, 1, 1, r, g, b)
		end
	end

	-- Raids
	title = false
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, _, locked, extended, _, isRaid, _, diffName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
		if isRaid and (locked or extended) and name then
			addTitle(L["Saved Raid(s)"])
			if extended then
				r, g, b = 0.3, 1, 0.3
			else
				r, g, b = 192 / 255, 192 / 255, 192 / 255
			end

			GameTooltip:AddDoubleLine(name .. " - " .. diffName .. " (" .. encounterProgress .. "/" .. numEncounters .. ")", SecondsToTime(reset, true, nil, 3), 1, 1, 1, r, g, b)
		end
	end

	-- Quests
	title = false
	for _, v in pairs(questlist) do
		if v.name and C_QuestLog_IsQuestFlaggedCompleted(v.id) then
			addTitle(QUESTS_LABEL)
			GameTooltip:AddDoubleLine(v.name, QUEST_COMPLETE, 1, 1, 1, 1, 0, 0)
		end
	end

	-- Help Info
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(K.LeftButton .. "Toggle Calendar")
	GameTooltip:AddLine(K.RightButton .. "Toggle Clock")
	GameTooltip:Show()
end

function Module:TimeOnLeave()
	TimeDataTextEntered = false
	K.HideTooltip()
end

function Module:TimeOnMouseUp(btn)
	if btn == "RightButton" then
		TimeManager_LoadUI()
		if TimeManager_Toggle then
			TimeManager_Toggle()
		end
	else
		_G.ToggleCalendar()
	end
end

function Module:CreateTimeDataText()
	if not C["DataText"].Time then
		return
	end

	if not Minimap then
		return
	end

	TimeDataText = TimeDataText or CreateFrame("Frame", "KKUI_TimeDataText", Minimap)
	TimeDataText:SetFrameLevel(8)

	TimeDataText.Font = TimeDataText.Font or TimeDataText:CreateFontString("OVERLAY")
	TimeDataText.Font:SetFontObject(K.UIFont)
	TimeDataText.Font:SetFont(select(1, TimeDataText.Font:GetFont()), 13, select(3, TimeDataText.Font:GetFont()))
	TimeDataText.Font:SetPoint("BOTTOM", _G.Minimap, "BOTTOM", 0, 2)

	TimeDataText:SetAllPoints(TimeDataText.Font)

	TimeDataText:SetScript("OnUpdate", Module.TimeOnUpdate)
	TimeDataText:SetScript("OnEnter", Module.TimeOnEnter)
	TimeDataText:SetScript("OnLeave", Module.TimeOnLeave)
	TimeDataText:SetScript("OnMouseUp", Module.TimeOnMouseUp)
end
