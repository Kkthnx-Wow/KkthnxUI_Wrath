local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Skins")

-- Credit: LeatrixPlus

L["EditBox Tip"] = "Press KEY ENTER when you finish typing"
L["InvalidName"] = "Invalid content input"
L["NoMatchReult"] = "No more matched results"
L["Tips"] = "Tips"
L["TradeSearchTip"] = "Search the recipe name you need, press key ESC to clear input"

local _G = _G
local string_find = _G.string.find

local GetTradeSkillSelectionIndex = _G.GetTradeSkillSelectionIndex
local GetTradeSkillInfo = _G.GetTradeSkillInfo
local GetNumTradeSkills = _G.GetNumTradeSkills
local GetCraftSelectionIndex = _G.GetCraftSelectionIndex
local GetCraftInfo = _G.GetCraftInfo
local GetNumCrafts = _G.GetNumCrafts

local skinIndex = 0
function Module:TradeSkill_OnEvent(addon)
	if addon == "Blizzard_CraftUI" then
		Module:EnhancedCraft()
		skinIndex = skinIndex + 1
	elseif addon == "Blizzard_TradeSkillUI" then
		Module:EnhancedTradeSkill()
		skinIndex = skinIndex + 1
	end

	if skinIndex >= 2 then
		K:UnregisterEvent("ADDON_LOADED", Module.TradeSkill_OnEvent)
	end
end

function Module:CreateEnhancedTradeSkill()
	if not C["Skins"].EnhancedTradeSkill then
		return
	end

	K:RegisterEvent("ADDON_LOADED", Module.TradeSkill_OnEvent)
end

local function createArrowButton(parent, anchor, direction)
	local button = CreateFrame("Button", nil, parent)
	button:SetPoint("LEFT", anchor, "RIGHT", 3, 0)
	K.ReskinArrow(button, direction, false)

	return button
end

local function removeInputText(self)
	self:SetText("")
end

local function editBoxClearFocus(self)
	self:ClearFocus()
end

function Module:CreateSearchWidget(parent, anchor)
	local title = K.CreateFontString(parent, 12, SEARCH, "", "system")
	title:ClearAllPoints()

	local searchBox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
	searchBox:SetSize(150, 20)
	searchBox:SetAutoFocus(false)
	searchBox:SetTextInsets(5, 5, 0, 0)
	searchBox:SetScript("OnEscapePressed", editBoxClearFocus)
	searchBox:SetScript("OnEnterPressed", editBoxClearFocus)

	title:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 5, -5)
	searchBox:SetFrameLevel(6)
	searchBox:SetPoint("TOPLEFT", title, "TOPRIGHT", 3, 1)
	searchBox:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -42, -20)
	searchBox:HookScript("OnEscapePressed", removeInputText)
	searchBox.title = L["Tips"]
	K.AddTooltip(searchBox, "ANCHOR_TOP", L["TradeSearchTip"]..L["EditBox Tip"], "info")

	local nextButton = createArrowButton(searchBox, searchBox, "down")
	local prevButton = createArrowButton(searchBox, nextButton, "up")

	return searchBox, nextButton, prevButton
end

local function updateScrollBarValue(scrollBar, maxSkills, selectSkill)
	local _, maxValue = scrollBar:GetMinMaxValues()
	if maxValue == 0 then
		return
	end

	local maxIndex = maxSkills - 22
	if maxIndex <= 0 then
		return
	end

	local selectIndex = selectSkill - 22
	if selectIndex < 0 then
		selectIndex = 0
	end

	scrollBar:SetValue(selectIndex / maxIndex * maxValue)
end

function Module:UpdateTradeSelection(i, maxSkills)
	TradeSkillFrame_SetSelection(i)
	TradeSkillFrame_Update()
	updateScrollBarValue(TradeSkillListScrollFrameScrollBar, maxSkills, GetTradeSkillSelectionIndex())
end

function Module:GetTradeSearchResult(text, from, to, step)
	for i = from, to, step do
		local skillName, skillType = GetTradeSkillInfo(i)
		if skillType ~= "header" and string_find(skillName, text) then
			Module:UpdateTradeSelection(i, GetNumTradeSkills())
			return true
		end
	end
end

function Module:UpdateCraftSelection(i, maxSkills)
	CraftFrame_SetSelection(i)
	CraftFrame_Update()
	updateScrollBarValue(CraftListScrollFrameScrollBar, maxSkills, GetCraftSelectionIndex())
end

function Module:GetCraftSearchResult(text, from, to, step)
	for i = from, to, step do
		local skillName, skillType = GetCraftInfo(i)
		if skillType ~= "header" and string_find(skillName, text) then
			Module:UpdateCraftSelection(i, GetNumCrafts())
			return true
		end
	end
end

local SharedWindowData = {
	area = "override",
	pushable = 1,
	xoffset = -16,
	yoffset = 12,
	bottomClampOverride = 140 + 12,
	width = 714,
	height = 487,
	whileDead = 1,
}

local function ResizeHighlightFrame(self)
	self:SetWidth(290)
end

function Module:EnhancedTradeSkill()
	if TradeSkillFrame:GetWidth() > 700 then
		return
	end

	-- Make the tradeskill frame double-wide
	UIPanelWindows["TradeSkillFrame"] = SharedWindowData

	-- Size the tradeskill frame
	TradeSkillFrame:SetWidth(714)
	TradeSkillFrame:SetHeight(487)

	-- Adjust title text
	TradeSkillFrameTitleText:ClearAllPoints()
	TradeSkillFrameTitleText:SetPoint("TOP", TradeSkillFrame, "TOP", 0, -18)

	-- Expand the tradeskill list to full height
	TradeSkillListScrollFrame:ClearAllPoints()
	TradeSkillListScrollFrame:SetPoint("TOPLEFT", TradeSkillFrame, "TOPLEFT", 25, -75)
	TradeSkillListScrollFrame:SetSize(295, 336)

	-- Create additional list rows
	local oldTradeSkillsDisplayed = TRADE_SKILLS_DISPLAYED

	-- Position existing buttons
	for i = 1 + 1, TRADE_SKILLS_DISPLAYED do
		_G["TradeSkillSkill"..i]:ClearAllPoints()
		_G["TradeSkillSkill"..i]:SetPoint("TOPLEFT", _G["TradeSkillSkill"..(i - 1)], "BOTTOMLEFT", 0, 1)
	end

	-- Create and position new buttons
	_G.TRADE_SKILLS_DISPLAYED = _G.TRADE_SKILLS_DISPLAYED + 14
	for i = oldTradeSkillsDisplayed + 1, TRADE_SKILLS_DISPLAYED do
		local button = CreateFrame("Button", "TradeSkillSkill"..i, TradeSkillFrame, "TradeSkillSkillButtonTemplate")
		button:SetID(i)
		button:Hide()
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", _G["TradeSkillSkill"..(i - 1)], "BOTTOMLEFT", 0, 1)
	end

	-- Set highlight bar width when shown
	hooksecurefunc(TradeSkillHighlightFrame, "Show", ResizeHighlightFrame)

	-- Move the tradeskill detail frame to the right and stretch it to full height
	TradeSkillDetailScrollFrame:ClearAllPoints()
	TradeSkillDetailScrollFrame:SetPoint("TOPLEFT", TradeSkillFrame, "TOPLEFT", 352, -74)
	TradeSkillDetailScrollFrame:SetSize(298, 336)

	-- Hide detail scroll frame textures
	TradeSkillDetailScrollFrameTop:SetAlpha(0)
	TradeSkillDetailScrollFrameBottom:SetAlpha(0)

	-- Create texture for skills list
	local RecipeInset = TradeSkillFrame:CreateTexture(nil, "ARTWORK")
	RecipeInset:SetSize(304, 361)
	RecipeInset:SetPoint("TOPLEFT", TradeSkillFrame, "TOPLEFT", 16, -72)
	RecipeInset:SetTexture("Interface\\RAIDFRAME\\UI-RaidFrame-GroupBg")

	-- Set detail frame backdrop
	local DetailsInset = TradeSkillFrame:CreateTexture(nil, "ARTWORK")
	DetailsInset:SetSize(302, 339)
	DetailsInset:SetPoint("TOPLEFT", TradeSkillFrame, "TOPLEFT", 348, -72)
	DetailsInset:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated")

	-- Hide expand tab (left of All button)
	TradeSkillExpandTabLeft:Hide()

	-- Get tradeskill frame textures
	local regions = {TradeSkillFrame:GetRegions()}

	-- Set top left texture
	regions[2]:SetTexture("Interface\\QUESTFRAME\\UI-QuestLogDualPane-Left")
	regions[2]:SetSize(512, 512)

	-- Set top right texture
	regions[3]:ClearAllPoints()
	regions[3]:SetPoint("TOPLEFT", regions[2], "TOPRIGHT", 0, 0)
	regions[3]:SetTexture("Interface\\QUESTFRAME\\UI-QuestLogDualPane-Right")
	regions[3]:SetSize(256, 512)

	-- Hide bottom left and bottom right textures
	regions[4]:Hide()
	regions[5]:Hide()

	-- Hide skills list dividing bar
	regions[9]:Hide()
	regions[10]:Hide()

	-- Move create button row
	TradeSkillCreateButton:ClearAllPoints()
	TradeSkillCreateButton:SetPoint("RIGHT", TradeSkillCancelButton, "LEFT", -1, 0)

	-- Position and size close button
	TradeSkillCancelButton:SetSize(80, 22)
	TradeSkillCancelButton:SetText(CLOSE)
	TradeSkillCancelButton:ClearAllPoints()
	TradeSkillCancelButton:SetPoint("BOTTOMRIGHT", TradeSkillFrame, "BOTTOMRIGHT", -42, 54)

	-- Position close box
	TradeSkillFrameCloseButton:ClearAllPoints()
	TradeSkillFrameCloseButton:SetPoint("TOPRIGHT", TradeSkillFrame, "TOPRIGHT", -30, -8)

	-- Position dropdown menus
	TradeSkillInvSlotDropDown:ClearAllPoints()
	TradeSkillInvSlotDropDown:SetPoint("TOPLEFT", TradeSkillFrame, "TOPLEFT", 510, -40)
	TradeSkillSubClassDropDown:ClearAllPoints()
	TradeSkillSubClassDropDown:SetPoint("RIGHT", TradeSkillInvSlotDropDown, "LEFT", 0, 0)

	-- Search widgets
	local searchBox, nextButton, prevButton = Module:CreateSearchWidget(TradeSkillFrame, TradeSkillRankFrame)
	searchBox:HookScript("OnEnterPressed", function(self)
		local text = self:GetText()
		if not text or text == "" then
			return
		end

		if not Module:GetTradeSearchResult(text, 1, GetNumTradeSkills(), 1) then
			UIErrorsFrame:AddMessage(K.InfoColor..L["InvalidName"])
		end
	end)

	nextButton:SetScript("OnClick", function()
		local text = searchBox:GetText()
		if not text or text == "" then
			return
		end

		if not Module:GetTradeSearchResult(text, GetTradeSkillSelectionIndex() + 1, GetNumTradeSkills(), 1) then
			UIErrorsFrame:AddMessage(K.InfoColor..L["NoMatchReult"])
		end
	end)

	prevButton:SetScript("OnClick", function()
		local text = searchBox:GetText()
		if not text or text == "" then
			return
		end

		if not Module:GetTradeSearchResult(text, GetTradeSkillSelectionIndex() - 1, 1, -1) then
			UIErrorsFrame:AddMessage(K.InfoColor..L["NoMatchReult"])
		end
	end)
end

function Module:EnhancedCraft()
	-- Make the craft frame double-wide
	UIPanelWindows["CraftFrame"] = SharedWindowData

	-- Size the craft frame
	CraftFrame:SetWidth(714)
	CraftFrame:SetHeight(487)

	-- Adjust title text
	CraftFrameTitleText:ClearAllPoints()
	CraftFrameTitleText:SetPoint("TOP", CraftFrame, "TOP", 0, -18)

	-- Expand the crafting list to full height
	CraftListScrollFrame:ClearAllPoints()
	CraftListScrollFrame:SetPoint("TOPLEFT", CraftFrame, "TOPLEFT", 25, -75)
	CraftListScrollFrame:SetSize(295, 336)

	-- Create additional list rows
	local oldCraftsDisplayed = CRAFTS_DISPLAYED

	-- Position existing buttons
	Craft1Cost:ClearAllPoints()
	Craft1Cost:SetPoint("RIGHT", Craft1, "RIGHT", -30, 0)
	for i = 1 + 1, CRAFTS_DISPLAYED do
		_G["Craft"..i]:ClearAllPoints()
		_G["Craft"..i]:SetPoint("TOPLEFT", _G["Craft"..(i - 1)], "BOTTOMLEFT", 0, 1)
		_G["Craft"..i.."Cost"]:ClearAllPoints()
		_G["Craft"..i.."Cost"]:SetPoint("RIGHT", _G["Craft"..i], "RIGHT", -30, 0)
	end

	-- Create and position new buttons
	_G.CRAFTS_DISPLAYED = _G.CRAFTS_DISPLAYED + 14
	for i = oldCraftsDisplayed + 1, CRAFTS_DISPLAYED do
		local button = CreateFrame("Button", "Craft"..i, CraftFrame, "CraftButtonTemplate")
		button:SetID(i)
		button:Hide()
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", _G["Craft"..(i-1)], "BOTTOMLEFT", 0, 1)
		_G["Craft"..i.."Cost"]:ClearAllPoints()
		_G["Craft"..i.."Cost"]:SetPoint("RIGHT", _G["Craft"..i], "RIGHT", -30, 0)
	end

	-- Move craft frame points (such as Beast Training)
	CraftFramePointsLabel:ClearAllPoints()
	CraftFramePointsLabel:SetPoint("TOPLEFT", CraftFrame, "TOPLEFT", 100, -70)
	CraftFramePointsText:ClearAllPoints()
	CraftFramePointsText:SetPoint("LEFT", CraftFramePointsLabel, "RIGHT", 3, 0)

	-- Set highlight bar width when shown
	hooksecurefunc(CraftHighlightFrame, "Show", ResizeHighlightFrame)

	-- Move the craft detail frame to the right and stretch it to full height
	CraftDetailScrollFrame:ClearAllPoints()
	CraftDetailScrollFrame:SetPoint("TOPLEFT", CraftFrame, "TOPLEFT", 352, -74)
	CraftDetailScrollFrame:SetSize(298, 336)
	-- CraftReagent1:SetHeight(500) -- Debug

	-- Hide detail scroll frame textures
	CraftDetailScrollFrameTop:SetAlpha(0)
	CraftDetailScrollFrameBottom:SetAlpha(0)

	-- Create texture for skills list
	local RecipeInset = CraftFrame:CreateTexture(nil, "ARTWORK")
	RecipeInset:SetSize(304, 361)
	RecipeInset:SetPoint("TOPLEFT", CraftFrame, "TOPLEFT", 16, -72)
	RecipeInset:SetTexture("Interface\\RAIDFRAME\\UI-RaidFrame-GroupBg")

	-- Set detail frame backdrop
	local DetailsInset = CraftFrame:CreateTexture(nil, "ARTWORK")
	DetailsInset:SetSize(302, 339)
	DetailsInset:SetPoint("TOPLEFT", CraftFrame, "TOPLEFT", 348, -72)
	DetailsInset:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated")

	-- Hide expand tab (left of All button)
	CraftExpandTabLeft:Hide()

	-- Get craft frame textures
	local regions = {CraftFrame:GetRegions()}

	-- Set top left texture
	regions[2]:SetTexture("Interface\\QUESTFRAME\\UI-QuestLogDualPane-Left")
	regions[2]:SetSize(512, 512)

	-- Set top right texture
	regions[3]:ClearAllPoints()
	regions[3]:SetPoint("TOPLEFT", regions[2], "TOPRIGHT", 0, 0)
	regions[3]:SetTexture("Interface\\QUESTFRAME\\UI-QuestLogDualPane-Right")
	regions[3]:SetSize(256, 512)

	-- Hide bottom left and bottom right textures
	regions[4]:Hide()
	regions[5]:Hide()

	-- Hide skills list dividing bar
	regions[9]:Hide()
	regions[10]:Hide()

	-- Move create button row
	CraftCreateButton:ClearAllPoints()
	CraftCreateButton:SetPoint("RIGHT", CraftCancelButton, "LEFT", -1, 0)

	-- Position and size close button
	CraftCancelButton:SetSize(80, 22)
	CraftCancelButton:SetText(CLOSE)
	CraftCancelButton:ClearAllPoints()
	CraftCancelButton:SetPoint("BOTTOMRIGHT", CraftFrame, "BOTTOMRIGHT", -42, 54)

	-- Position close box
	CraftFrameCloseButton:ClearAllPoints()
	CraftFrameCloseButton:SetPoint("TOPRIGHT", CraftFrame, "TOPRIGHT", -34, -13)

	local searchBox, nextButton, prevButton = Module:CreateSearchWidget(CraftFrame, CraftRankFrame)
	searchBox:HookScript("OnEnterPressed", function(self)
		local text = self:GetText()
		if not text or text == "" then
			return
		end

		if not Module:GetCraftSearchResult(text, 1, GetNumCrafts(), 1) then
			UIErrorsFrame:AddMessage(K.InfoColor..L["InvalidName"])
		end
	end)

	nextButton:SetScript("OnClick", function()
		local text = searchBox:GetText()
		if not text or text == "" then
			return
		end

		if not Module:GetCraftSearchResult(text, GetCraftSelectionIndex() + 1, GetNumCrafts(), 1) then
			UIErrorsFrame:AddMessage(K.InfoColor..L["NoMatchReult"])
		end
	end)

	prevButton:SetScript("OnClick", function()
		local text = searchBox:GetText()
		if not text or text == "" then
			return
		end

		if not Module:GetCraftSearchResult(text, GetCraftSelectionIndex() - 1, 1, -1) then
			UIErrorsFrame:AddMessage(K.InfoColor..L["NoMatchReult"])
		end
	end)
end