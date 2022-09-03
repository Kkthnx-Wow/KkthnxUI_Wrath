local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Infobar")

local _G = _G
local date = _G.date
local ipairs = _G.ipairs
local mod = _G.mod
local pairs = _G.pairs
local string_find = _G.string.find
local string_format = _G.string.format
local time = _G.time
local tonumber = _G.tonumber

local CALENDAR_FULLDATE_MONTH_NAMES = _G.CALENDAR_FULLDATE_MONTH_NAMES
local CALENDAR_WEEKDAY_NAMES = _G.CALENDAR_WEEKDAY_NAMES
local C_AreaPoiInfo_GetAreaPOIInfo = _G.C_AreaPoiInfo.GetAreaPOIInfo
local C_AreaPoiInfo_GetAreaPOISecondsLeft = _G.C_AreaPoiInfo.GetAreaPOISecondsLeft
local C_Calendar_GetDayEvent = _G.C_Calendar.GetDayEvent
local C_Calendar_GetNumDayEvents = _G.C_Calendar.GetNumDayEvents
local C_Calendar_GetNumPendingInvites = _G.C_Calendar.GetNumPendingInvites
local C_Calendar_OpenCalendar = _G.C_Calendar.OpenCalendar
local C_Calendar_SetAbsMonth = _G.C_Calendar.SetAbsMonth
local C_DateAndTime_GetCurrentCalendarTime = _G.C_DateAndTime.GetCurrentCalendarTime
local C_Map_GetMapInfo = _G.C_Map.GetMapInfo
local C_QuestLog_IsQuestFlaggedCompleted = _G.C_QuestLog.IsQuestFlaggedCompleted
local C_TaskQuest_GetQuestInfoByQuestID = _G.C_TaskQuest.GetQuestInfoByQuestID
local C_TaskQuest_GetThreatQuests = _G.C_TaskQuest.GetThreatQuests
local C_UIWidgetManager_GetTextWithStateWidgetVisualizationInfo = _G.C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo
local FULLDATE = _G.FULLDATE
local GameTime_GetGameTime = _G.GameTime_GetGameTime
local GameTime_GetLocalTime = _G.GameTime_GetLocalTime
local GameTooltip = _G.GameTooltip
local GetCVar = _G.GetCVar
local GetCVarBool = _G.GetCVarBool
local GetGameTime = _G.GetGameTime
local GetNumSavedInstances = _G.GetNumSavedInstances
local GetNumSavedWorldBosses = _G.GetNumSavedWorldBosses
local GetSavedInstanceInfo = _G.GetSavedInstanceInfo
local GetSavedWorldBossInfo = _G.GetSavedWorldBossInfo
local InCombatLockdown = _G.InCombatLockdown
local PLAYER_DIFFICULTY_TIMEWALKER = _G.PLAYER_DIFFICULTY_TIMEWALKER
local QUESTS_LABEL = _G.QUESTS_LABEL
local QUEST_COMPLETE = _G.QUEST_COMPLETE
local QUEUE_TIME_UNAVAILABLE = _G.QUEUE_TIME_UNAVAILABLE
local RequestRaidInfo = _G.RequestRaidInfo
local SecondsToTime = _G.SecondsToTime
local TIMEMANAGER_TICKER_12HOUR = _G.TIMEMANAGER_TICKER_12HOUR
local TIMEMANAGER_TICKER_24HOUR = _G.TIMEMANAGER_TICKER_24HOUR

local TimeDataText
local TimeDataTextEntered

-- Data
local region = GetCVar("portal")
local legionZoneTime = {
	["EU"] = 1565168400, -- CN-16
	["US"] = 1565197200, -- CN-8
	["CN"] = 1565226000, -- CN time 8/8/2019 09:00 [1]
}
local bfaZoneTime = {
	["CN"] = 1546743600, -- CN time 1/6/2019 11:00 [1]
	["EU"] = 1546768800, -- CN+7
	["US"] = 1546769340, -- CN+16
}

local invIndex = {
	[1] = { title = L["Legion Invasion"], duration = 66600, maps = { 630, 641, 650, 634 }, timeTable = {}, baseTime = legionZoneTime[region] or legionZoneTime["CN"] },
	[2] = {
		title = L["BFA Invasion"],
		duration = 68400,
		maps = { 862, 863, 864, 896, 942, 895 },
		timeTable = { 4, 1, 6, 2, 5, 3 },
		baseTime = bfaZoneTime[region] or bfaZoneTime["CN"],
	},
}

local mapAreaPoiIDs = {
	[630] = 5175,
	[641] = 5210,
	[650] = 5177,
	[634] = 5178,
	[862] = 5973,
	[863] = 5969,
	[864] = 5970,
	[896] = 5964,
	[942] = 5966,
	[895] = 5896,
}

local questlist = {
	{ name = "Mean One", id = 6983 },
	{ name = "Blingtron", id = 34774 },
	{ name = "Tormentors of Torghast", id = 63854 },
	{ name = "Timewarped", id = 40168, texture = 1129674 }, -- TBC
	{ name = "Timewarped", id = 40173, texture = 1129686 }, -- WotLK
	{ name = "Timewarped", id = 40786, texture = 1304688 }, -- Cata
	{ name = "Timewarped", id = 45563, texture = 1530590 }, -- MoP
	{ name = "Timewarped", id = 55499, texture = 1129683 }, -- WoD
	{ name = "Timewarped", id = 64710, texture = 1467047 }, -- Legion
}

local lesserVisions = { 58151, 58155, 58156, 58167, 58168 }
local horrificVisions = {
	[1] = { id = 57848, desc = "470 (5+5)" },
	[2] = { id = 57844, desc = "465 (5+4)" },
	[3] = { id = 57847, desc = "460 (5+3)" },
	[4] = { id = 57843, desc = "455 (5+2)" },
	[5] = { id = 57846, desc = "450 (5+1)" },
	[6] = { id = 57842, desc = "445 (5+0)" },
	[7] = { id = 57845, desc = "430 (3+0)" },
	[8] = { id = 57841, desc = "420 (1+0)" },
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

local isTimeWalker, walkerTexture
local function checkTimeWalker(event)
	local date = C_DateAndTime_GetCurrentCalendarTime()
	C_Calendar_SetAbsMonth(date.month, date.year)
	C_Calendar_OpenCalendar()

	local today = date.monthDay
	local numEvents = C_Calendar_GetNumDayEvents(0, today)
	if numEvents <= 0 then
		return
	end

	for i = 1, numEvents do
		local info = C_Calendar_GetDayEvent(0, today, i)
		if info and string_find(info.title, PLAYER_DIFFICULTY_TIMEWALKER) and info.sequenceType ~= "END" then
			isTimeWalker = true
			walkerTexture = info.iconTexture
			break
		end
	end
	K:UnregisterEvent(event, checkTimeWalker)
end
K:RegisterEvent("PLAYER_ENTERING_WORLD", checkTimeWalker)

local function checkTexture(texture)
	if not walkerTexture then
		return
	end
	if walkerTexture == texture or walkerTexture == texture - 1 then
		return true
	end
end

local function getInvasionInfo(mapID)
	local areaPoiID = mapAreaPoiIDs[mapID]
	local seconds = C_AreaPoiInfo_GetAreaPOISecondsLeft(areaPoiID)
	local mapInfo = C_Map_GetMapInfo(mapID)
	return seconds, mapInfo.name
end

local function CheckInvasion(index)
	for _, mapID in pairs(invIndex[index].maps) do
		local timeLeft, name = getInvasionInfo(mapID)
		if timeLeft and timeLeft > 0 then
			return timeLeft, name
		end
	end
end

local function GetNextTime(baseTime, index)
	local currentTime = time()
	local duration = invIndex[index].duration
	local elapsed = mod(currentTime - baseTime, duration)
	return duration - elapsed + currentTime
end

local function GetNextLocation(nextTime, index)
	local inv = invIndex[index]
	local count = #inv.timeTable
	if count == 0 then
		return QUEUE_TIME_UNAVAILABLE
	end

	local elapsed = nextTime - inv.baseTime
	local round = mod(floor(elapsed / inv.duration) + 1, count)
	if round == 0 then
		round = count
	end
	return C_Map_GetMapInfo(inv.maps[inv.timeTable[round]]).name
end

local cache = {}
local nzothAssaults
local function GetNzothThreatName(questID)
	local name = cache[questID]
	if not name then
		name = C_TaskQuest_GetQuestInfoByQuestID(questID)
		cache[questID] = name
	end
	return name
end

-- Torghast
local TorghastWidgets, TorghastInfo = {
	{ nameID = 2925, levelID = 2930 }, -- Fracture Chambers
	{ nameID = 2926, levelID = 2932 }, -- Skoldus Hall
	{ nameID = 2924, levelID = 2934 }, -- Soulforges
	{ nameID = 2927, levelID = 2936 }, -- Coldheart Interstitia
	{ nameID = 2928, levelID = 2938 }, -- Mort'regar
	{ nameID = 2929, levelID = 2940 }, -- The Upper Reaches
}

local function CleanupLevelName(text)
	return string.gsub(text, "|n", "")
end

local title
local function addTitle(text)
	if not title then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(text .. ":")
		title = true
	end
end

function Module:TimeOnShiftDown()
	if TimeDataTextEntered then
		Module:TimeOnEnter()
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

	-- World bosses
	-- title = false
	-- for i = 1, GetNumSavedWorldBosses() do
	-- 	local name, id, reset = GetSavedWorldBossInfo(i)
	-- 	if not (id == 11 or id == 12 or id == 13) then
	-- 		addTitle(RAID_INFO_WORLD_BOSS)
	-- 		GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1, 1, 1, 192 / 255, 192 / 255, 192 / 255)
	-- 	end
	-- end

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

			GameTooltip:AddDoubleLine(name .. " - " .. maxPlayers .. " " .. PLAYER .. " (" .. diffName .. ") (" .. encounterProgress .. "/" .. numEncounters .. ")", SecondsToTime(reset, true, nil, 3), 1, 1, 1, r, g, b)
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

	-- Torghast
	if not TorghastInfo then
		TorghastInfo = C_AreaPoiInfo_GetAreaPOIInfo(1543, 6640)
	end

	if TorghastInfo and C_QuestLog_IsQuestFlaggedCompleted(60136) then
		title = false
		for _, value in pairs(TorghastWidgets) do
			local nameInfo = C_UIWidgetManager_GetTextWithStateWidgetVisualizationInfo(value.nameID)
			if nameInfo and nameInfo.shownState == 1 then
				addTitle(TorghastInfo.name)
				local nameText = CleanupLevelName(nameInfo.text)
				local levelInfo = C_UIWidgetManager_GetTextWithStateWidgetVisualizationInfo(value.levelID)
				local levelText = AVAILABLE
				if levelInfo and levelInfo.shownState == 1 then
					levelText = CleanupLevelName(levelInfo.text)
				end
				GameTooltip:AddDoubleLine(nameText, levelText)
			end
		end
	end

	-- Quests
	title = false

	for _, v in pairs(questlist) do
		if v.name and C_QuestLog_IsQuestFlaggedCompleted(v.id) then
			if v.name == "500 Timewarped Badges" and isTimeWalker and checkTexture(v.texture) or v.name ~= "500 Timewarped Badges" then
				addTitle(QUESTS_LABEL)
				GameTooltip:AddDoubleLine(v.name, QUEST_COMPLETE, 1, 1, 1, 1, 0, 0)
			end
		end
	end

	if IsShiftKeyDown() then
		-- Nzoth relavants
		for _, v in ipairs(horrificVisions) do
			if C_QuestLog_IsQuestFlaggedCompleted(v.id) then
				addTitle(QUESTS_LABEL)
				GameTooltip:AddDoubleLine(SPLASH_BATTLEFORAZEROTH_8_3_0_FEATURE1_TITLE, v.desc, 1, 1, 1, 0, 1, 0)
				break
			end
		end

		for _, id in pairs(lesserVisions) do
			if C_QuestLog_IsQuestFlaggedCompleted(id) then
				addTitle(QUESTS_LABEL)
				GameTooltip:AddDoubleLine("Lesser Vision of N'Zoth", QUEST_COMPLETE, 1, 1, 1, 1, 0, 0)
				break
			end
		end

		if not nzothAssaults then
			nzothAssaults = C_TaskQuest_GetThreatQuests() or {}
		end
		for _, v in pairs(nzothAssaults) do
			if C_QuestLog_IsQuestFlaggedCompleted(v) then
				addTitle(QUESTS_LABEL)
				GameTooltip:AddDoubleLine(GetNzothThreatName(v), QUEST_COMPLETE, 1, 1, 1, 1, 0, 0)
			end
		end

		-- Invasions
		for index, value in ipairs(invIndex) do
			title = false
			addTitle(value.title)
			local timeLeft, zoneName = CheckInvasion(index)
			local nextTime = GetNextTime(value.baseTime, index)
			if timeLeft then
				timeLeft = timeLeft / 60
				if timeLeft < 60 then
					r, g, b = 1, 0, 0
				else
					r, g, b = 0, 1, 0
				end
				GameTooltip:AddDoubleLine(L["Current Invasion"] .. zoneName, string_format("%.2d:%.2d", timeLeft / 60, timeLeft % 60), 1, 1, 1, r, g, b)
			end
			local nextLocation = GetNextLocation(nextTime, index)
			GameTooltip:AddDoubleLine(L["Next Invasion"] .. nextLocation, date("%m/%d %H:%M", nextTime), 1, 1, 1, 192 / 255, 192 / 255, 192 / 255)
		end
	else
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(K.InfoColor .. "Hold SHIFT for info|r")
	end

	-- Help Info
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(K.LeftButton .. "Toggle Calendar")
	--GameTooltip:AddLine(K.ScrollButton .. RATED_PVP_WEEKLY_VAULT)
	GameTooltip:AddLine(K.RightButton .. "Toggle Clock")
	GameTooltip:Show()

	K:RegisterEvent("MODIFIER_STATE_CHANGED", Module.TimeOnShiftDown)
end

function Module:TimeOnLeave()
	TimeDataTextEntered = false
	K.HideTooltip()
	K:UnregisterEvent("MODIFIER_STATE_CHANGED", Module.TimeOnShiftDown)
end

function Module:TimeOnMouseUp(btn)
	if btn == "RightButton" then
		_G.ToggleTimeManager()
	elseif btn == "MiddleButton" then
		if not WeeklyRewardsFrame then
			LoadAddOn("Blizzard_WeeklyRewards")
		end
		if InCombatLockdown() then
			K.TogglePanel(WeeklyRewardsFrame)
		else
			ToggleFrame(WeeklyRewardsFrame)
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
