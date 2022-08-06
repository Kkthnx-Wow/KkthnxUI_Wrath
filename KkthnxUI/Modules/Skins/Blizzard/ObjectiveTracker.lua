local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local pairs = _G.pairs
local select = _G.select
local tinsert = _G.tinsert

local FauxScrollFrame_GetOffset = _G.FauxScrollFrame_GetOffset
local GetCVarBool = _G.GetCVarBool
local GetNumQuestLeaderBoards = _G.GetNumQuestLeaderBoards
local GetNumQuestLogEntries = _G.GetNumQuestLogEntries
local GetNumQuestWatches = _G.GetNumQuestWatches
local GetQuestIndexForWatch = _G.GetQuestIndexForWatch
local GetQuestLogLeaderBoard = _G.GetQuestLogLeaderBoard
local GetQuestLogTitle = _G.GetQuestLogTitle
local IsShiftKeyDown = _G.IsShiftKeyDown
local RemoveQuestWatch = _G.RemoveQuestWatch
local ShowUIPanel = _G.ShowUIPanel

local cr, cg, cb = K.r, K.g, K.b
local MAX_QUESTLOG_QUESTS = _G.MAX_QUESTLOG_QUESTS or 20
local MAX_WATCHABLE_QUESTS = _G.MAX_WATCHABLE_QUESTS or 5
local headerString = _G.QUESTS_LABEL .. " %s/%s"

local frame

-- Handle collapse
local function updateCollapseTexture(texture, collapsed)
	if collapsed then
		texture:SetTexCoord(0, 0.4375, 0, 0.4375)
	else
		texture:SetTexCoord(0.5625, 1, 0, 0.4375)
	end
end

local function resetCollapseTexture(self, texture)
	if self.settingTexture then
		return
	end
	self.settingTexture = true
	self:SetNormalTexture("")

	if texture and texture ~= "" then
		if strfind(texture, "Plus") or strfind(texture, "Closed") then
			self.__texture:DoCollapse(true)
		elseif strfind(texture, "Minus") or strfind(texture, "Open") then
			self.__texture:DoCollapse(false)
		end
		self.bg:Show()
	else
		self.bg:Hide()
	end
	self.settingTexture = nil
end

function Module:ReskinCollapse(isAtlas)
	self:SetHighlightTexture("")
	self:SetPushedTexture("")
	self:SetDisabledTexture("")

	local bg = CreateFrame("Frame", nil, self, "BackdropTemplate")
	bg:SetAllPoints(self)
	bg:SetFrameLevel(self:GetFrameLevel())
	bg:CreateBorder()

	bg:ClearAllPoints()
	bg:SetSize(13, 13)
	bg:SetPoint("TOPLEFT", self:GetNormalTexture())
	self.bg = bg

	self.__texture = bg:CreateTexture(nil, "OVERLAY")
	self.__texture:SetPoint("CENTER")
	self.__texture:SetSize(7, 7)
	self.__texture:SetTexture("Interface\\Buttons\\UI-PlusMinus-Buttons")
	self.__texture.DoCollapse = updateCollapseTexture

	if isAtlas then
		hooksecurefunc(self, "SetNormalAtlas", resetCollapseTexture)
	else
		hooksecurefunc(self, "SetNormalTexture", resetCollapseTexture)
	end
end

function Module:EnhancedQuestLog()
	if IsAddOnLoaded("Leatrix_Plus") then
		return
	end

	if not C["Skins"].EnhancedQuestLog then
		return
	end
	-- Make the quest log frame double-wide
	UIPanelWindows["QuestLogFrame"] = { area = "override", pushable = 0, xoffset = -16, yoffset = 12, bottomClampOverride = 140 + 12, width = 714, height = 487, whileDead = 1 }

	-- Size the quest log frame
	QuestLogFrame:SetWidth(714)
	QuestLogFrame:SetHeight(487)

	-- Adjust quest log title text
	QuestLogTitleText:ClearAllPoints()
	QuestLogTitleText:SetPoint("TOP", QuestLogFrame, "TOP", 0, -18)

	-- Move the detail frame to the right and stretch it to full height
	QuestLogDetailScrollFrame:ClearAllPoints()
	QuestLogDetailScrollFrame:SetPoint("TOPLEFT", QuestLogListScrollFrame, "TOPRIGHT", 31, 1)
	QuestLogDetailScrollFrame:SetHeight(336)

	-- Expand the quest list to full height
	QuestLogListScrollFrame:SetHeight(336)

	-- Create additional quest rows
	local oldQuestsDisplayed = QUESTS_DISPLAYED
	_G.QUESTS_DISPLAYED = _G.QUESTS_DISPLAYED + 16
	for i = oldQuestsDisplayed + 1, QUESTS_DISPLAYED do
		local button = CreateFrame("Button", "QuestLogTitle" .. i, QuestLogFrame, "QuestLogTitleButtonTemplate")
		button:SetID(i)
		button:Hide()
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", _G["QuestLogTitle" .. (i - 1)], "BOTTOMLEFT", 0, 1)
	end

	-- Get quest frame textures
	local regions = { QuestLogFrame:GetRegions() }

	-- Set top left texture
	regions[3]:SetTexture("Interface\\QUESTFRAME\\UI-QuestLogDualPane-Left")
	regions[3]:SetSize(512, 512)

	-- Set top right texture
	regions[4]:ClearAllPoints()
	regions[4]:SetPoint("TOPLEFT", regions[3], "TOPRIGHT", 0, 0)
	regions[4]:SetTexture("Interface\\QUESTFRAME\\UI-QuestLogDualPane-Right")
	regions[4]:SetSize(256, 512)

	-- Hide bottom left and bottom right textures
	regions[5]:Hide()
	regions[6]:Hide()

	-- Position and resize abandon button
	QuestLogFrameAbandonButton:SetSize(110, 21)
	QuestLogFrameAbandonButton:SetText(ABANDON_QUEST_ABBREV)
	QuestLogFrameAbandonButton:ClearAllPoints()
	QuestLogFrameAbandonButton:SetPoint("BOTTOMLEFT", QuestLogFrame, "BOTTOMLEFT", 17, 54)

	-- Position and resize share button
	QuestFramePushQuestButton:SetSize(100, 21)
	QuestFramePushQuestButton:SetText(SHARE_QUEST_ABBREV)
	QuestFramePushQuestButton:ClearAllPoints()
	QuestFramePushQuestButton:SetPoint("LEFT", QuestLogFrameAbandonButton, "RIGHT", -3, 0)

	-- Add map button
	local logMapButton = CreateFrame("Button", nil, QuestLogFrame, "UIPanelButtonTemplate")
	logMapButton:SetText("Map")
	logMapButton:ClearAllPoints()
	logMapButton:SetPoint("LEFT", QuestFramePushQuestButton, "RIGHT", -3, 0)
	logMapButton:SetSize(100, 21)
	logMapButton:SetScript("OnClick", ToggleWorldMap)

	-- Position and size close button
	QuestFrameExitButton:SetSize(80, 22)
	QuestFrameExitButton:SetText(CLOSE)
	QuestFrameExitButton:ClearAllPoints()
	QuestFrameExitButton:SetPoint("BOTTOMRIGHT", QuestLogFrame, "BOTTOMRIGHT", -42, 54)

	-- Empty quest frame
	QuestLogNoQuestsText:ClearAllPoints()
	QuestLogNoQuestsText:SetPoint("TOP", QuestLogListScrollFrame, 0, -50)
	hooksecurefunc(EmptyQuestLogFrame, "Show", function()
		EmptyQuestLogFrame:ClearAllPoints()
		EmptyQuestLogFrame:SetPoint("BOTTOMLEFT", QuestLogFrame, "BOTTOMLEFT", 20, -76)
		EmptyQuestLogFrame:SetHeight(487)
	end)

	-- Show map button (not currently used)
	local mapButton = CreateFrame("BUTTON", nil, QuestLogFrame)
	mapButton:SetSize(36, 25)
	mapButton:SetPoint("TOPRIGHT", -390, -44)
	mapButton:SetNormalTexture("Interface\\QuestFrame\\UI-QuestMap_Button")
	mapButton:GetNormalTexture():SetTexCoord(0.125, 0.875, 0, 0.5)
	mapButton:SetPushedTexture("Interface\\QuestFrame\\UI-QuestMap_Button")
	mapButton:GetPushedTexture():SetTexCoord(0.125, 0.875, 0.5, 1.0)
	mapButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	mapButton:SetScript("OnClick", ToggleWorldMap)
	mapButton:Hide()

	-- Move ClassicCodex
	if CodexQuest then
		local buttonShow = CodexQuest.buttonShow
		buttonShow:SetWidth(55)
		buttonShow:SetText(K.InfoColor .. SHOW)

		local buttonHide = CodexQuest.buttonHide
		buttonHide:ClearAllPoints()
		buttonHide:SetPoint("LEFT", buttonShow, "RIGHT", 5, 0)
		buttonHide:SetWidth(55)
		buttonHide:SetText(K.InfoColor .. HIDE)

		local buttonReset = CodexQuest.buttonReset
		buttonReset:ClearAllPoints()
		buttonReset:SetPoint("LEFT", buttonHide, "RIGHT", 5, 0)
		buttonReset:SetWidth(55)
		buttonReset:SetText(K.InfoColor .. RESET)
	end
end

function Module:QuestLogLevel()
	if IsAddOnLoaded("Leatrix_Plus") then
		return
	end

	if not C["Skins"].EnhancedQuestLog then
		return
	end

	local numEntries = GetNumQuestLogEntries()
	for i = 1, QUESTS_DISPLAYED, 1 do
		local questIndex = i + FauxScrollFrame_GetOffset(QuestLogListScrollFrame)
		if questIndex <= numEntries then
			local questLogTitle = _G["QuestLogTitle" .. i]
			local questTitleTag = _G["QuestLogTitle" .. i .. "Tag"]
			local questLogTitleText, level, _, isHeader, _, isComplete = GetQuestLogTitle(questIndex)
			if not isHeader then
				questLogTitle:SetText("[" .. level .. "] " .. questLogTitleText)
				if isComplete then
					questLogTitle.r = 1
					questLogTitle.g = 0.5
					questLogTitle.b = 1
					questTitleTag:SetTextColor(1, 0.5, 1)
				end
			end

			local questText = _G["QuestLogTitle" .. i .. "NormalText"]
			local questCheck = _G["QuestLogTitle" .. i .. "Check"]
			if questText then
				local width = questText:GetStringWidth()
				if width then
					if width <= 210 then
						questCheck:SetPoint("LEFT", questLogTitle, "LEFT", width + 22, 0)
					else
						questCheck:SetPoint("LEFT", questLogTitle, "LEFT", 210, 0)
					end
				end
			end

			local questNumGroupMates = _G["QuestLogTitle" .. i .. "GroupMates"]
			if not questNumGroupMates.anchored then
				questNumGroupMates:SetPoint("LEFT")
				questNumGroupMates.anchored = true
			end
		end
	end
end

function Module:EnhancedQuestTracker()
	local header = CreateFrame("Frame", nil, frame)
	header:SetAllPoints()
	header:SetParent(QuestWatchFrame)
	header.Text = K.CreateFontString(header, 14, "", "", true, "TOPLEFT", 0, 15)
	-- header.Text:SetFontObject(K.GetFont(C["UIFonts"].QuestTrackerFonts))

	local bg = header:CreateTexture(nil, "ARTWORK")
	bg:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
	bg:SetTexCoord(0, 0.66, 0, 0.31)
	bg:SetVertexColor(cr, cg, cb, 0.8)
	bg:SetPoint("TOPLEFT", 0, 20)
	bg:SetSize(250, 30)

	local bu = CreateFrame("Button", nil, frame)
	bu:SetSize(20, 20)
	bu:SetPoint("TOPRIGHT", 0, 18)
	bu.collapse = false
	bu:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
	bu:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
	bu:SetPoint("TOPRIGHT", 0, 14)
	Module.ReskinCollapse(bu)
	bu:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
	bu:SetShown(GetNumQuestWatches() > 0)

	bu.Text = K.CreateFontString(bu, 14, TRACKER_HEADER_OBJECTIVE, "", "system", "RIGHT", -24, 3)
	-- bu.Text:SetFontObject(K.GetFont(C["UIFonts"].QuestTrackerFonts))
	bu.Text:Hide()

	bu:SetScript("OnClick", function(self)
		self.collapse = not self.collapse
		if self.collapse then
			self:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
			self.Text:Show()
			QuestWatchFrame:Hide()
		else
			self:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
			self.Text:Hide()
			if GetNumQuestWatches() > 0 then
				QuestWatchFrame:Show()
			end
		end
	end)

	-- Change font of watched quests
	for i = 1, 30 do
		local QuestLine = _G["QuestWatchLine" .. i]
		QuestLine:SetFontObject(K.GetFont(C["UIFonts"].QuestTrackerFonts))
	end

	-- ModernQuestWatch, Ketho
	local function onMouseUp(self)
		if IsShiftKeyDown() then -- untrack quest
			local questID = GetQuestIDFromLogIndex(self.questIndex)
			for index, value in ipairs(QUEST_WATCH_LIST) do
				if value.id == questID then
					tremove(QUEST_WATCH_LIST, index)
				end
			end
			RemoveQuestWatch(self.questIndex)
			QuestWatch_Update()
		else -- open to quest log
			if QuestLogEx then -- https://www.wowinterface.com/downloads/info24980-QuestLogEx.html
				ShowUIPanel(QuestLogExFrame)
				QuestLogEx:QuestLog_SetSelection(self.questIndex)
				QuestLogEx:Maximize()
			elseif ClassicQuestLog then -- https://www.wowinterface.com/downloads/info24937-ClassicQuestLogforClassic.html
				ShowUIPanel(ClassicQuestLog)
				QuestLog_SetSelection(self.questIndex)
			elseif QuestGuru then -- https://www.curseforge.com/wow/addons/questguru_classic
				ShowUIPanel(QuestGuru)
				QuestLog_SetSelection(self.questIndex)
			else
				ShowUIPanel(QuestLogFrame)
				QuestLog_SetSelection(self.questIndex)
				local valueStep = QuestLogListScrollFrame.ScrollBar:GetValueStep()
				QuestLogListScrollFrame.ScrollBar:SetValue(self.questIndex * valueStep / 2)
			end
		end
		QuestLog_Update()
	end

	local function onEnter(self)
		if self.completed then
			-- use normal colors instead as highlight
			self.headerText:SetTextColor(0.75, 0.61, 0)
			for _, text in ipairs(self.objectiveTexts) do
				text:SetTextColor(0.8, 0.8, 0.8)
			end
		else
			self.headerText:SetTextColor(1, 0.8, 0)
			for _, text in ipairs(self.objectiveTexts) do
				text:SetTextColor(1, 1, 1)
			end
		end
	end

	local ClickFrames = {}
	local function SetClickFrame(watchIndex, questIndex, headerText, objectiveTexts, completed)
		if not ClickFrames[watchIndex] then
			ClickFrames[watchIndex] = CreateFrame("Frame")
			ClickFrames[watchIndex]:SetScript("OnMouseUp", onMouseUp)
			ClickFrames[watchIndex]:SetScript("OnEnter", onEnter)
			ClickFrames[watchIndex]:SetScript("OnLeave", QuestWatch_Update)
		end

		local f = ClickFrames[watchIndex]
		f:SetAllPoints(headerText)
		f.watchIndex = watchIndex
		f.questIndex = questIndex
		f.headerText = headerText
		f.objectiveTexts = objectiveTexts
		f.completed = completed
	end

	hooksecurefunc("QuestWatch_Update", function()
		local numQuests = select(2, GetNumQuestLogEntries())
		header.Text:SetFormattedText(headerString, numQuests, MAX_QUESTLOG_QUESTS)

		local watchTextIndex = 1
		local numWatches = GetNumQuestWatches()
		for i = 1, numWatches do
			local questIndex = GetQuestIndexForWatch(i)
			if questIndex then
				local numObjectives = GetNumQuestLeaderBoards(questIndex)
				if numObjectives > 0 then
					local headerText = _G["QuestWatchLine" .. watchTextIndex]
					if watchTextIndex > 1 then
						headerText:SetPoint("TOPLEFT", "QuestWatchLine" .. (watchTextIndex - 1), "BOTTOMLEFT", 0, -10)
					end
					watchTextIndex = watchTextIndex + 1
					local objectivesGroup = {}
					local objectivesCompleted = 0
					for j = 1, numObjectives do
						local finished = select(3, GetQuestLogLeaderBoard(j, questIndex))
						if finished then
							objectivesCompleted = objectivesCompleted + 1
						end
						_G["QuestWatchLine" .. watchTextIndex]:SetPoint("TOPLEFT", "QuestWatchLine" .. (watchTextIndex - 1), "BOTTOMLEFT", 0, -5)
						tinsert(objectivesGroup, _G["QuestWatchLine" .. watchTextIndex])
						watchTextIndex = watchTextIndex + 1
					end
					SetClickFrame(i, questIndex, headerText, objectivesGroup, objectivesCompleted == numObjectives)
				end
			end
		end
		-- hide/show frames so it doesnt eat clicks, since we cant parent to a FontString
		for _, frame in pairs(ClickFrames) do
			frame[GetQuestIndexForWatch(frame.watchIndex) and "Show" or "Hide"](frame)
		end

		bu:SetShown(numWatches > 0)
		if bu.collapse then
			QuestWatchFrame:Hide()
		end
	end)

	local function autoQuestWatch(_, questIndex)
		-- tracking otherwise untrackable quests (without any objectives) would still count against the watch limit
		-- calling AddQuestWatch() while on the max watch limit silently fails
		if GetCVarBool("autoQuestWatch") and GetNumQuestLeaderBoards(questIndex) ~= 0 and GetNumQuestWatches() < MAX_WATCHABLE_QUESTS then
			AutoQuestWatch_Insert(questIndex, QUEST_WATCH_NO_EXPIRE)
		end
	end
	K:RegisterEvent("QUEST_ACCEPTED", autoQuestWatch)
end

function Module:CreateQuestTracker()
	-- Mover for quest tracker
	frame = CreateFrame("Frame", "KKUI_QuestMover", UIParent)
	frame:SetSize(240, 50)
	K.Mover(frame, "QuestTracker", "QuestTracker", { "TOPRIGHT", UIParent, "TOPRIGHT", -120, -318 })

	-- QuestWatchFrame:SetHeight(GetScreenHeight()*.65)
	QuestWatchFrame:SetClampedToScreen(false)
	QuestWatchFrame:SetMovable(true)
	QuestWatchFrame:SetUserPlaced(true)

	hooksecurefunc(QuestWatchFrame, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == _G.MinimapCluster then
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", frame, 5, -5)
		end
	end)

	local timerMover = CreateFrame("Frame", "KKUI_QuestTimerMover", UIParent)
	timerMover:SetSize(150, 30)
	K.Mover(timerMover, QUEST_TIMERS, "QuestTimer", { "TOPRIGHT", frame, "TOPLEFT", -16, 6 })

	hooksecurefunc(QuestTimerFrame, "SetPoint", function(self, _, parent)
		if parent ~= timerMover then
			self:ClearAllPoints()
			self:SetPoint("TOP", timerMover)
		end
	end)

	QuestTimerFrame:StripTextures()
	QuestTimerFrame:CreateBorder(nil, nil, C["General"].BorderStyle.Value ~= "KkthnxUI_Pixel" and 32 or nil, nil, C["General"].BorderStyle.Value ~= "KkthnxUI_Pixel" and -8 or nil, nil, nil, nil, nil, nil, nil, nil, -2)

	Module:EnhancedQuestLog()
	Module:EnhancedQuestTracker()
	hooksecurefunc("QuestLog_Update", Module.QuestLogLevel)
end
