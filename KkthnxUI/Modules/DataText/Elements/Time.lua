local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Infobar")

local _G = _G
local date = _G.date
local string_format = _G.string.format
local tonumber = _G.tonumber

local CALENDAR_FULLDATE_MONTH_NAMES = _G.CALENDAR_FULLDATE_MONTH_NAMES
local CALENDAR_WEEKDAY_NAMES = _G.CALENDAR_WEEKDAY_NAMES
local C_DateAndTime_GetCurrentCalendarTime = _G.C_DateAndTime.GetCurrentCalendarTime
local FULLDATE = _G.FULLDATE
local GameTime_GetGameTime = _G.GameTime_GetGameTime
local GameTime_GetLocalTime = _G.GameTime_GetLocalTime
local GameTooltip = _G.GameTooltip
local GetCVarBool = _G.GetCVarBool
local GetGameTime = _G.GetGameTime
local GetNumSavedInstances = _G.GetNumSavedInstances
local GetSavedInstanceInfo = _G.GetSavedInstanceInfo
local RequestRaidInfo = _G.RequestRaidInfo
local SecondsToTime = _G.SecondsToTime
local TIMEMANAGER_TICKER_12HOUR = _G.TIMEMANAGER_TICKER_12HOUR
local TIMEMANAGER_TICKER_24HOUR = _G.TIMEMANAGER_TICKER_24HOUR

local timeEntered

function Module:updateTimerFormat(color, hour, minute)
	if GetCVarBool("timeMgrUseMilitaryTime") then
		return string_format(color..TIMEMANAGER_TICKER_24HOUR, hour, minute)
	else
		local timerUnit = K.MyClassColor..(hour < 12 and "am" or "pm")

		if hour >= 12 then
			if hour > 12 then
				hour = hour - 12
			end
		else
			if hour == 0 then
				hour = 12
			end
		end

		return string_format(color..TIMEMANAGER_TICKER_12HOUR..timerUnit, hour, minute)
	end
end

function Module:TimeOnUpdate(elapsed)
	Module.timer = (Module.timer or 3) + elapsed
	if Module.timer > 5 then
		local color = ""

		local hour, minute
		if GetCVarBool("timeMgrUseLocalTime") then
			hour, minute = tonumber(date("%H")), tonumber(date("%M"))
		else
			hour, minute = GetGameTime()
		end
		Module.TimeFont:SetText(Module:updateTimerFormat(color, hour, minute))

		Module.timer = 0
	end
end

local title
local function addTitle(text)
	if not title then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(text..":")
		title = true
	end
end

function Module:TimeOnShiftDown()
	if timeEntered then
		Module:TimeOnEnter()
	end
end

function Module:TimeOnEnter()
	timeEntered = true
	RequestRaidInfo()

	local r, g, b
	GameTooltip:SetOwner(Module.TimeFrame, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(Module.TimeFrame))
	GameTooltip:ClearLines()

	local today = C_DateAndTime_GetCurrentCalendarTime()
	local w, m, d, y = today.weekday, today.month, today.monthDay, today.year
	GameTooltip:AddLine(string_format(FULLDATE, CALENDAR_WEEKDAY_NAMES[w], CALENDAR_FULLDATE_MONTH_NAMES[m], d, y), 0, 0.6, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(L["Local Time"], GameTime_GetLocalTime(true), nil, nil, nil, 192/255, 192/255, 192/255)
	GameTooltip:AddDoubleLine(L["Realm Time"], GameTime_GetGameTime(true), nil, nil, nil, 192/255, 192/255, 192/255)

	-- Herioc/Mythic Dungeons
	title = false
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, diff, locked, extended, _, _, maxPlayers, diffName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
		if (diff == 2 or diff == 23) and (locked or extended) and name then
			addTitle("Saved Dungeon(s)")
			if extended then
				r, g, b = 0.3, 1, 0.3
			else
				r, g, b = 192/255, 192/255, 192/255
			end

			GameTooltip:AddDoubleLine(name.." - "..maxPlayers.." "..PLAYER.." ("..diffName..") ("..encounterProgress.."/"..numEncounters..")", SecondsToTime(reset, true, nil, 3), 1, 1, 1, r, g, b)
		end
	end

	-- Raids
	title = false
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, _, locked, extended, _, isRaid, _, diffName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
		if isRaid and (locked or extended) then
			addTitle(L["Saved Raid(s)"])
			if extended then
				r, g, b = 0.3, 1, 0.3
			else
				r, g, b = 192/255, 192/255, 192/255
			end

			GameTooltip:AddDoubleLine(name.." - "..diffName.." ("..encounterProgress.."/"..numEncounters..")", SecondsToTime(reset, true, nil, 3), 1, 1, 1, r, g, b)
		end
	end

	-- Help Info
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(K.RightButton.."Toggle Clock")
	GameTooltip:Show()
end

function Module:TimeOnLeave()
	timeEntered = true
	GameTooltip:Hide()
end

function Module:TimeOnMouseUp(btn)
	if btn == "RightButton" then
		ToggleFrame(TimeManagerFrame)
	end
end

function Module:CreateTimeDataText()
	if not C["DataText"].Time then
		return
	end

	if not Minimap then
		return
	end

	Module.TimeFrame = CreateFrame("Frame", "KKUI_TimeDataText", Minimap)

	Module.TimeFont = Module.TimeFrame:CreateFontString("OVERLAY")
	Module.TimeFont:FontTemplate(nil, 13)
	Module.TimeFont:SetPoint("BOTTOM", _G.Minimap, "BOTTOM", 0, 2)

	Module.TimeFrame:SetAllPoints(Module.TimeFont)

	Module.TimeFrame:SetScript("OnUpdate", Module.TimeOnUpdate)
	Module.TimeFrame:SetScript("OnEnter", Module.TimeOnEnter)
	Module.TimeFrame:SetScript("OnLeave", Module.TimeOnLeave)
	Module.TimeFrame:SetScript("OnMouseUp", Module.TimeOnMouseUp)
end