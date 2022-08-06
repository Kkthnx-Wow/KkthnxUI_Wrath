local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Chat")

local _G = _G
local string_sub = _G.string.sub
local string_len = _G.string.len
local string_gsub = _G.string.gsub
local string_find = _G.string.find
local string_format = _G.string.format

local GetInstanceInfo = _G.GetInstanceInfo
local InCombatLockdown = _G.InCombatLockdown
local UnitName = _G.UnitName
local ChatTypeInfo = _G.ChatTypeInfo
local ConsoleExec = _G.ConsoleExec
local GetCVar = _G.GetCVar
local GetChannelName = _G.GetChannelName
local IsControlKeyDown = _G.IsControlKeyDown
local IsInGroup = _G.IsInGroup
local IsInGuild = _G.IsInGuild
local IsInRaid = _G.IsInRaid
local IsShiftKeyDown = _G.IsShiftKeyDown
local SetCVar = _G.SetCVar
local hooksecurefunc = _G.hooksecurefunc

local messageSoundID = SOUNDKIT.TELL_MESSAGE
local maxLines = 1024

local function GetGroupDistribution()
	local _, instanceType = GetInstanceInfo()
	if instanceType == "pvp" then
		return "/bg "
	end

	if IsInRaid() then
		return "/ra "
	end

	if IsInGroup() then
		return "/p "
	end

	return "/s "
end

do
	local charCount
	local function CountLinkCharacters(self)
		charCount = charCount + (string_len(self) + 4) -- 4 is ending "|h|r"
	end

	local a1, a2 = "", "[%s%-]"
	local function ShortenRealm(realm)
		return string_gsub(realm, a2, a1)
	end

	local repeatedText
	function Module:EditBoxOnTextChanged()
		local text = self:GetText()
		local len = string_len(text)
		if (not repeatedText or not string_find(text, repeatedText, 1, true)) and InCombatLockdown() then
			local MIN_REPEAT_CHARACTERS = 5
			if len > MIN_REPEAT_CHARACTERS then
				local repeatChar = true
				for i = 1, MIN_REPEAT_CHARACTERS, 1 do
					local first = -1 - i
					if string_sub(text, -i, -i) ~= string_sub(text, first, first) then
						repeatChar = false
						break
					end
				end

				if repeatChar then
					repeatedText = text
					self:Hide()
					return
				end
			end
		end

		if len == 4 then
			if text == "/tt " then
				local Name, Realm = UnitName("target")
				if Name then
					Name = string_gsub(Name, "%s", "")
					if Realm and Realm ~= "" then
						Name = string_format("%s-%s", Name, ShortenRealm(Realm))
					end
				end

				if Name then
					_G.ChatFrame_SendTell(Name, self.chatFrame)
				else
					_G.UIErrorsFrame:AddMessage(K.InfoColor..L["Invalid Target"])
				end
			elseif text == "/gr " then
				self:SetText(GetGroupDistribution()..string_sub(text, 5))
				_G.ChatEdit_ParseText(self, 0)
			end
		end

		-- recalculate the character count correctly with hyperlinks in it, using gsub so it matches multiple without gmatch
		charCount = 0
		string_gsub(text, "(|cff%x%x%x%x%x%x|H.-|h).-|h|r", CountLinkCharacters)
		if charCount ~= 0 then
			len = len - charCount
		end

		self.__characterCount:SetText(len > 0 and (255 - len) or "")

		if repeatedText then
			repeatedText = nil
		end
	end
end

function Module:TabSetAlpha(alpha)
	if self.glow:IsShown() and alpha ~= 1 then
		self:SetAlpha(1)
	elseif alpha < 0 then
		self:SetAlpha(0)
	end
end

local isScaling = false
function Module:UpdateChatSize()
	if not C["Chat"].Lock then
		return
	end

	if isScaling then
		return
	end
	isScaling = true

	if ChatFrame1:IsMovable() then
		ChatFrame1:SetUserPlaced(true)
	end

	if ChatFrame1.FontStringContainer then
		ChatFrame1.FontStringContainer:SetPoint("TOPLEFT", ChatFrame1, "TOPLEFT", -1, 1)
		ChatFrame1.FontStringContainer:SetPoint("BOTTOMRIGHT", ChatFrame1, "BOTTOMRIGHT", 1, -1)
	end

	ChatFrame1:ClearAllPoints()
	ChatFrame1:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 7, 11)
	ChatFrame1:SetWidth(C["Chat"].Width)
	ChatFrame1:SetHeight(C["Chat"].Height)

	isScaling = false
end

local function CreateBackground(self)
	local frame = CreateFrame("Frame", nil, self)
	frame:SetPoint("TOPLEFT", self.Background, "TOPLEFT", -1, 1)
	frame:SetPoint("BOTTOMRIGHT", self.Background, "BOTTOMRIGHT", 22, -1)
	frame:SetFrameLevel(self:GetFrameLevel())
	frame:CreateBorder()
	frame:SetShown(C["Chat"].Background)

	return frame
end

-- https://git.tukui.org/Tukz/Tukui/-/blob/master/Tukui/Modules/ChatFrames/ChatFrames.lua#L55
function Module:SetChatFont()
	local Font = K.GetFont(C["UIFonts"].ChatFonts)
	local Path, _, Flag = _G[Font]:GetFont()
	local CurrentFont, CurrentSize, CurrentFlag = self:GetFont()

	if (CurrentFont == Path and CurrentFlag == Flag) then
		return
	end

	self:SetFont(Path, CurrentSize, Flag)
end

function Module:SkinChat()
	if not self or self.styled then
		return
	end

	local id = self:GetID()
	local name = self:GetName()
	local getTabFont = K.GetFont(C["UIFonts"].ChatFonts)
	local tabFont, tabFontSize, tabFontFlags = _G[getTabFont]:GetFont()

	self:SetMaxResize(K.ScreenWidth, K.ScreenHeight)
	self:SetMinResize(100, 50)
	self:SetClampRectInsets(0, 0, 0, 0)
	self:SetClampedToScreen(false)
	self:SetFading(C["Chat"].Fading)
	self:SetTimeVisible(C["Chat"].FadingTimeVisible)

	if self:GetMaxLines() < maxLines then
		self:SetMaxLines(maxLines)
	end

	self.__background = CreateBackground(self)

	local eb = _G[name.."EditBox"]
	eb:SetAltArrowKeyMode(false)
	eb:ClearAllPoints()
	eb:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -3, 25)
	eb:SetPoint("TOPRIGHT", self, "TOPRIGHT", 25, 50)
	eb:StripTextures(2)
	eb:CreateBorder()
	eb:Hide()
	eb:HookScript("OnTextChanged", Module.EditBoxOnTextChanged)

	local lang = _G[name.."EditBoxLanguage"]
	lang:GetRegions():SetAlpha(0)
	lang:SetPoint("TOPLEFT", eb, "TOPRIGHT", 5, 0)
	lang:SetPoint("BOTTOMRIGHT", eb, "BOTTOMRIGHT", 29, 0)
	lang:CreateBorder()

	local tab = _G[name.."Tab"]
	tab:SetAlpha(1)
	tab.Text:SetFont(tabFont, tabFontSize + 1, tabFontFlags)
	tab.Text.SetFont = K.Noop
	tab:StripTextures(7)
	hooksecurefunc(tab, "SetAlpha", Module.TabSetAlpha)

	-- Hide editbox every time we click on a tab
	tab:HookScript("OnClick", function()
		eb:Hide()
	end)

	-- Character count
	local charCount = eb:CreateFontString(nil, "ARTWORK")
	charCount:FontTemplate()
	charCount:SetTextColor(190, 190, 190, 0.4)
	charCount:SetPoint("TOPRIGHT", eb, "TOPRIGHT", 4, 0)
	charCount:SetPoint("BOTTOMRIGHT", eb, "BOTTOMRIGHT", 4, 0)
	charCount:SetJustifyH("CENTER")
	charCount:SetWidth(40)
	eb.__characterCount = charCount

	self.buttonFrame:Kill()
	--self.ScrollBar:Kill()
	self.ScrollToBottomButton:Kill()
	Module:ToggleChatFrameTextures(self)

	self.oldAlpha = self.oldAlpha or 0 -- fix blizz error

	-- Temp Chats
	if (id > 10) then
		Module.SetChatFont(self)
	end

	-- Security for font, in case if revert back to WoW default we restore instantly the kkthnxui font default.
	hooksecurefunc(self, "SetFont", Module.SetChatFont)

	self.styled = true
end

function Module:ToggleChatFrameTextures(frame)
	if C["Chat"].Background then
		frame:DisableDrawLayer("BORDER")
		frame:DisableDrawLayer("BACKGROUND")
	else
		frame:EnableDrawLayer("BORDER")
		frame:EnableDrawLayer("BACKGROUND")
	end
end

function Module:ToggleChatBackground()
	for _, chatFrameName in ipairs(CHAT_FRAMES) do
		local frame = _G[chatFrameName]
		if frame.__background then
			frame.__background:SetShown(C["Chat"].Background)
		end
		Module:ToggleChatFrameTextures(frame)
	end
end

-- Swith channels by Tab
local cycles = {
	{chatType = "SAY", use = function()
			return 1
	end},

	{chatType = "PARTY", use = function()
			return IsInGroup()
	end},

	{chatType = "RAID", use = function()
			return IsInRaid()
	end},

	{chatType = "GUILD", use = function()
			return IsInGuild()
	end},

	{chatType = "SAY", use = function()
			return 1
	end},
}

-- Update editbox border color
function Module:UpdateEditBoxColor()
	if not C["Chat"].Enable then
		return
	end

	if IsAddOnLoaded("Prat-3.0") or IsAddOnLoaded("Chatter") or IsAddOnLoaded("BasicChatMods") or IsAddOnLoaded("Glass") then
		return
	end

	local editBox = ChatEdit_ChooseBoxForSend()
	local chatType = editBox:GetAttribute("chatType")
	local editBoxBorder = editBox.KKUI_Border

	if not chatType then
		return
	end

	-- Increase inset on right side to make room for character count text
	local insetLeft, insetRight, insetTop, insetBottom = editBox:GetTextInsets()
	editBox:SetTextInsets(insetLeft, insetRight + 18, insetTop, insetBottom)

	if editBoxBorder then
		if (chatType == "CHANNEL") then
			local id = GetChannelName(editBox:GetAttribute("channelTarget"))

			if (id == 0) then
				local r, g, b
				if C["General"].ColorTextures then
					r, g, b = unpack(C["General"].TexturesColor)
				else
					r, g, b = 1, 1, 1
				end
				editBoxBorder:SetVertexColor(r, g, b)
			else
				local r, g, b = ChatTypeInfo[chatType..id].r, ChatTypeInfo[chatType..id].g, ChatTypeInfo[chatType..id].b
				editBoxBorder:SetVertexColor(r, g, b)
			end
		else
			local r, g, b = ChatTypeInfo[chatType].r, ChatTypeInfo[chatType].g, ChatTypeInfo[chatType].b
			editBoxBorder:SetVertexColor(r, g, b)
		end
	end
end
hooksecurefunc("ChatEdit_UpdateHeader", Module.UpdateEditBoxColor)

function Module:UpdateTabChannelSwitch()
	if not C["Chat"].Enable then
		return
	end

	if IsAddOnLoaded("Prat-3.0") or IsAddOnLoaded("Chatter") or IsAddOnLoaded("BasicChatMods") or IsAddOnLoaded("Glass") then
		return
	end

	if string_sub(tostring(self:GetText()), 1, 1) == "/" then
		return
	end

	local currChatType = self:GetAttribute("chatType")
	for i, curr in ipairs(cycles) do
		if curr.chatType == currChatType then
			local h, r, step = i + 1, #cycles, 1
			if IsShiftKeyDown() then
				h, r, step = i - 1, 1, -1
			end

			for j = h, r, step do
				if cycles[j]:use(self, currChatType) then
					self:SetAttribute("chatType", cycles[j].chatType)
					ChatEdit_UpdateHeader(self)
					return
				end
			end
		end
	end
end
hooksecurefunc("ChatEdit_CustomTabPressed", Module.UpdateTabChannelSwitch)

-- Quick Scroll
function Module:QuickMouseScroll(dir)
	if not C["Chat"].Enable then
		return
	end

	if IsAddOnLoaded("Prat-3.0") or IsAddOnLoaded("Chatter") or IsAddOnLoaded("BasicChatMods") or IsAddOnLoaded("Glass") then
		return
	end

	if dir > 0 then
		if IsShiftKeyDown() then
			self:ScrollToTop()
		elseif IsControlKeyDown() then
			self:ScrollUp()
			self:ScrollUp()
		end
	else
		if IsShiftKeyDown() then
			self:ScrollToBottom()
		elseif IsControlKeyDown() then
			self:ScrollDown()
			self:ScrollDown()
		end
	end
end
hooksecurefunc("FloatingChatFrame_OnMouseScroll", Module.QuickMouseScroll)

-- Sticky whisper
function Module:ChatWhisperSticky()
	if C["Chat"].Sticky then
		ChatTypeInfo["WHISPER"].sticky = 1
		ChatTypeInfo["BN_WHISPER"].sticky = 1
	else
		ChatTypeInfo["WHISPER"].sticky = 0
		ChatTypeInfo["BN_WHISPER"].sticky = 0
	end
end

-- Tab colors
function Module:UpdateTabColors(selected)
	if selected then
		self.Text:SetTextColor(1, 0.8, 0)
		self.whisperIndex = 0
	else
		self.Text:SetTextColor(0.5, 0.5, 0.5)
	end

	if self.whisperIndex == 1 then
		self.glow:SetVertexColor(1, 0.5, 1)
	elseif self.whisperIndex == 2 then
		self.glow:SetVertexColor(0, 1, 0.96)
	else
		self.glow:SetVertexColor(1, 0.8, 0)
	end
end

function Module:UpdateTabEventColors(event)
	local tab = _G[self:GetName().."Tab"]
	local selected = GeneralDockManager.selected:GetID() == tab:GetID()
	if event == "CHAT_MSG_WHISPER" then
		tab.whisperIndex = 1
		Module.UpdateTabColors(tab, selected)
	elseif event == "CHAT_MSG_BN_WHISPER" then
		tab.whisperIndex = 2
		Module.UpdateTabColors(tab, selected)
	end
end

local whisperEvents = {
	["CHAT_MSG_WHISPER"] = true,
	["CHAT_MSG_BN_WHISPER"] = true,
}
function Module:PlayWhisperSound(event)
	if whisperEvents[event] then
		if Module.MuteThisTime then
			Module.MuteThisTime = nil
			return
		end

		local currentTime = GetTime()
		if not self.soundTimer or currentTime > self.soundTimer then
			PlaySound(messageSoundID, "master")
		end
		self.soundTimer = currentTime + 5
	end
end

function Module:OnEnable()
	if not C["Chat"].Enable then
		return
	end

	if IsAddOnLoaded("Prat-3.0") or IsAddOnLoaded("Chatter") or IsAddOnLoaded("BasicChatMods") or IsAddOnLoaded("Glass") then
		return
	end

	for i = 1, NUM_CHAT_WINDOWS do
		Module.SkinChat(_G["ChatFrame"..i])
		Module.SetChatFont(_G["ChatFrame"..i])
	end

	hooksecurefunc("FCF_OpenTemporaryWindow", function()
		for _, chatFrameName in ipairs(CHAT_FRAMES) do
			local frame = _G[chatFrameName]
			if frame.isTemporary then
				Module.SkinChat(frame)
			end
		end
	end)

	hooksecurefunc("FCFTab_UpdateColors", Module.UpdateTabColors)
	hooksecurefunc("FloatingChatFrame_OnEvent", Module.UpdateTabEventColors)
	hooksecurefunc("ChatFrame_MessageEventHandler", Module.PlayWhisperSound)

	-- Font size
	for i = 1, 15 do
		CHAT_FONT_HEIGHTS[i] = i + 9
	end

	-- Default
	if CHAT_OPTIONS then -- only flash whisper
		CHAT_OPTIONS.HIDE_FRAME_ALERTS = true
	end
	SetCVar("chatStyle", "classic")
	SetCVar("chatClassColorOverride", 0)
	K.HideInterfaceOption(InterfaceOptionsSocialPanelChatStyle)
	CombatLogQuickButtonFrame_CustomTexture:SetTexture(nil)

	-- Add Elements
	Module:ChatWhisperSticky()
	Module:CreateChatFilter()
	Module:CreateChatHistory()
	Module:CreateChatItemLevels()
	Module:CreateChatRename()
	Module:CreateCopyChat()
	Module:CreateCopyURL()
	Module:CreateEmojis()
	Module:CreateVoiceActivity()

	-- Lock chatframe
	if C["Chat"].Lock then
		Module:UpdateChatSize()
		K:RegisterEvent("UI_SCALE_CHANGED", Module.UpdateChatSize)
		hooksecurefunc("FCF_SavePositionAndDimensions", Module.UpdateChatSize)
		FCF_SavePositionAndDimensions(ChatFrame1)
	end

	-- ProfanityFilter
	if not BNFeaturesEnabledAndConnected() then
		return
	end

	if C["Chat"].Freedom then
		if GetCVar("portal") == "CN" then
			ConsoleExec("portal TW")
		end
		SetCVar("profanityFilter", 0)
	else
		SetCVar("profanityFilter", 1)
	end
end