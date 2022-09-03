local K, C = unpack(KkthnxUI)

-- Sourced: ExtraQuestButton, by p3lim

-- local _G = _G
-- local next = _G.next
-- local sqrt = _G.sqrt
-- local string_format = _G.string.format
-- local type = _G.type

-- local C_Map_GetBestMapForUnit = _G.C_Map.GetBestMapForUnit
-- local C_QuestLog_GetDistanceSqToQuest = _G.C_QuestLog.GetDistanceSqToQuest
-- local C_QuestLog_GetInfo = _G.C_QuestLog.GetInfo
-- local C_QuestLog_GetLogIndexForQuestID = _G.C_QuestLog.GetLogIndexForQuestID
-- local C_QuestLog_GetNumQuestLogEntries = _G.C_QuestLog.GetNumQuestLogEntries
-- local C_QuestLog_GetNumQuestWatches = _G.C_QuestLog.GetNumQuestWatches
-- local C_QuestLog_GetNumWorldQuestWatches = _G.C_QuestLog.GetNumWorldQuestWatches
-- local C_QuestLog_GetQuestIDForQuestWatchIndex = _G.C_QuestLog.GetQuestIDForQuestWatchIndex
-- local C_QuestLog_GetQuestIDForWorldQuestWatchIndex = _G.C_QuestLog.GetQuestIDForWorldQuestWatchIndex
-- local C_QuestLog_IsComplete = _G.C_QuestLog.IsComplete
-- local C_QuestLog_IsOnMap = _G.C_QuestLog.IsOnMap
-- local C_QuestLog_IsWorldQuest = _G.C_QuestLog.IsWorldQuest
-- local CreateFrame = _G.CreateFrame
-- local GameTooltip = _G.GameTooltip
-- local GetBindingKey = _G.GetBindingKey
-- local GetBindingText = _G.GetBindingText
-- local GetItemCooldown = _G.GetItemCooldown
-- local GetItemCount = _G.GetItemCount
-- local GetItemIcon = _G.GetItemIcon
-- local GetItemInfoFromHyperlink = _G.GetItemInfoFromHyperlink
-- local GetQuestLogSpecialItemInfo = _G.GetQuestLogSpecialItemInfo
-- local GetTime = _G.GetTime
-- local HasExtraActionBar = _G.HasExtraActionBar
-- local InCombatLockdown = _G.InCombatLockdown
-- local IsItemInRange = _G.IsItemInRange
-- local ItemHasRange = _G.ItemHasRange
-- local QuestHasPOIInfo = _G.QuestHasPOIInfo
-- local RANGE_INDICATOR = _G.RANGE_INDICATOR
-- local RegisterStateDriver = _G.RegisterStateDriver
-- local TOOLTIP_UPDATE_TIME = _G.TOOLTIP_UPDATE_TIME
-- local UIParent = _G.UIParent

-- local MAX_DISTANCE_YARDS = 1e4 -- needs review
-- local onlyCurrentZone = true
-- -- stylua: ignore
-- local ExtraQuestButton = CreateFrame("Button", "KKUI_ExtraQuestButton", UIParent, "SecureActionButtonTemplate, SecureHandlerStateTemplate, SecureHandlerAttributeTemplate")
-- ExtraQuestButton:SetMovable(true)
-- ExtraQuestButton:RegisterEvent("PLAYER_LOGIN")
-- ExtraQuestButton:Hide()
-- ExtraQuestButton:SetScript("OnEvent", function(self, event, ...)
-- 	if self[event] then
-- 		self[event](self, event, ...)
-- 	else
-- 		self:Update()
-- 	end
-- end)

-- local visibilityState = "[extrabar][petbattle] hide; show"
-- local onAttributeChanged = [[
-- if name == "item" then
-- 	if value and not self:IsShown() and not HasExtraActionBar() then
-- 		self:Show()
-- 	elseif not value then
-- 		self:Hide()
-- 		self:ClearBindings()
-- 	end
-- elseif name == "state-visible" then
-- 	if value == "show" then
-- 		self:Show()
-- 		self:CallMethod("Update")
-- 	else
-- 		self:Hide()
-- 		self:ClearBindings()
-- 	end
-- end

-- if self:IsShown() then
-- 	self:ClearBindings()
-- 	local key1, key2 = GetBindingKey("EXTRAACTIONBUTTON1")
-- 	if key1 then
-- 		self:SetBindingClick(1, key1, self, "LeftButton")
-- 	end
-- 	if key2 then
-- 		self:SetBindingClick(2, key2, self, "LeftButton")
-- 	end
-- end
-- ]]

-- function ExtraQuestButton:BAG_UPDATE_COOLDOWN()
-- 	if self:IsShown() and self.itemID then
-- 		local start, duration = GetItemCooldown(self.itemID)
-- 		if duration > 0 then
-- 			self.Cooldown:SetCooldown(start, duration)
-- 			self.Cooldown:Show()
-- 		else
-- 			self.Cooldown:Hide()
-- 		end
-- 	end
-- end

-- function ExtraQuestButton:UpdateCount()
-- 	if self:IsShown() then
-- 		local count = GetItemCount(self.itemLink)
-- 		self.Count:SetText(count and count > 1 and count or "")
-- 	end
-- end

-- function ExtraQuestButton:BAG_UPDATE_DELAYED()
-- 	self:Update()
-- 	self:UpdateCount()
-- end

-- function ExtraQuestButton:UpdateAttributes()
-- 	if InCombatLockdown() then
-- 		if not self.itemID and self:IsShown() then
-- 			self:SetAlpha(0)
-- 		end
-- 		self:RegisterEvent("PLAYER_REGEN_ENABLED")
-- 		return
-- 	else
-- 		self:SetAlpha(1)
-- 	end

-- 	if self.itemID then
-- 		self:SetAttribute("item", "item:" .. self.itemID)
-- 		self:BAG_UPDATE_COOLDOWN()
-- 	else
-- 		self:SetAttribute("item", nil)
-- 	end
-- end

-- function ExtraQuestButton:PLAYER_REGEN_ENABLED(event)
-- 	self:UpdateAttributes()
-- 	self:UnregisterEvent(event)
-- end

-- function ExtraQuestButton:UPDATE_BINDINGS()
-- 	if self:IsShown() then
-- 		self:SetItem()
-- 		self:SetAttribute("binding", GetTime())
-- 	end
-- end

-- function ExtraQuestButton:PLAYER_LOGIN()
-- 	-- local ExtraActionButton1 = _G.ExtraActionButton1

-- 	RegisterStateDriver(self, "visible", visibilityState)
-- 	self:SetAttribute("_onattributechanged", onAttributeChanged)
-- 	self:SetAttribute("type", "item")

-- 	-- self:SetSize(ExtraActionButton1:GetSize())
-- 	-- self:SetScale(ExtraActionButton1:GetScale())
-- 	self:SetSize(38, 38)
-- 	self:SetScale(1)
-- 	self:SetScript("OnLeave", K.HideTooltip)
-- 	self:SetClampedToScreen(true)
-- 	self:SetToplevel(true)

-- 	if not self:GetPoint() then
-- 		if _G.KKUI_ActionBarZone then
-- 			self:SetPoint("CENTER", _G.KKUI_ActionBarZone)
-- 		else
-- 			K.Mover(self, "ExtraQuestButton", "Extrabar", { "BOTTOM", UIParent, "BOTTOM", 270, 44 })
-- 		end
-- 	end

-- 	self.updateTimer = 0
-- 	self.rangeTimer = 0

-- 	local Icon = self:CreateTexture("$parentIcon", "ARTWORK")
-- 	Icon:SetAllPoints()
-- 	Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
-- 	local bg = CreateFrame("Frame", nil, self, "BackdropTemplate")
-- 	bg:SetAllPoints(Icon)
-- 	bg:SetFrameLevel(self:GetFrameLevel())
-- 	bg:CreateBorder()
-- 	bg:StyleButton()
-- 	bg.KKUI_Border:SetVertexColor(1, 0.82, 0.2)

-- 	self.HL = self:CreateTexture(nil, "HIGHLIGHT")
-- 	self.HL:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
-- 	self.HL:SetPoint("TOPLEFT", Icon, "TOPLEFT", 0, -0)
-- 	self.HL:SetPoint("BOTTOMRIGHT", Icon, "BOTTOMRIGHT", -0, 0)
-- 	self.HL:SetBlendMode("ADD")
-- 	self.Icon = Icon

-- 	local HotKey = self:CreateFontString("$parentHotKey", nil, "NumberFontNormal")
-- 	HotKey:SetPoint("TOP", 0, -5)
-- 	self.HotKey = HotKey

-- 	local Count = self:CreateFontString("$parentCount", nil, "NumberFont_Shadow_Med")
-- 	Count:SetPoint("BOTTOMRIGHT", -3, 3)
-- 	self.Count = Count

-- 	local Cooldown = CreateFrame("Cooldown", "$parentCooldown", self, "CooldownFrameTemplate")
-- 	Cooldown:SetPoint("TOPLEFT", 1, -1)
-- 	Cooldown:SetPoint("BOTTOMRIGHT", -1, 1)
-- 	Cooldown:SetReverse(false)
-- 	Cooldown:Hide()
-- 	self.Cooldown = Cooldown

-- 	local Artwork = self:CreateTexture("$parentArtwork", "OVERLAY")
-- 	Artwork:SetPoint("BOTTOMLEFT", 2, 2)
-- 	Artwork:SetSize(28, 26)
-- 	Artwork:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Inventory\\QuestIcon.tga")
-- 	self.Artwork = Artwork

-- 	self:RegisterEvent("UPDATE_BINDINGS")
-- 	self:RegisterEvent("BAG_UPDATE_COOLDOWN")
-- 	self:RegisterEvent("BAG_UPDATE_DELAYED")
-- 	self:RegisterEvent("QUEST_LOG_UPDATE")
-- 	-- self:RegisterEvent("QUEST_POI_UPDATE")
-- 	self:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
-- 	self:RegisterEvent("QUEST_ACCEPTED")
-- 	self:RegisterEvent("ZONE_CHANGED")
-- 	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
-- end

-- ExtraQuestButton:SetScript("OnEnter", function(self)
-- 	if not self.itemLink then
-- 		return
-- 	end

-- 	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
-- 	GameTooltip:SetHyperlink(self.itemLink)
-- end)

-- ExtraQuestButton:SetScript("OnUpdate", function(self, elapsed)
-- 	if self.updateRange then
-- 		if (self.rangeTimer or 0) > TOOLTIP_UPDATE_TIME then
-- 			local HotKey = self.HotKey
-- 			local Icon = self.Icon

-- 			-- BUG: IsItemInRange() is broken versus friendly npcs (and possibly others)
-- 			local inRange = IsItemInRange(self.itemLink, "target")
-- 			if HotKey:GetText() == RANGE_INDICATOR then
-- 				if inRange == false then
-- 					HotKey:SetTextColor(1, 0.1, 0.1)
-- 					HotKey:Show()
-- 					Icon:SetVertexColor(1, 0.1, 0.1)
-- 				elseif inRange then
-- 					HotKey:SetTextColor(0.6, 0.6, 0.6)
-- 					HotKey:Show()
-- 					Icon:SetVertexColor(1, 1, 1)
-- 				else
-- 					HotKey:Hide()
-- 				end
-- 			else
-- 				if inRange == false then
-- 					HotKey:SetTextColor(1, 0.1, 0.1)
-- 					Icon:SetVertexColor(1, 0.1, 0.1)
-- 				else
-- 					HotKey:SetTextColor(0.6, 0.6, 0.6)
-- 					Icon:SetVertexColor(1, 1, 1)
-- 				end
-- 			end

-- 			self.rangeTimer = 0
-- 		else
-- 			self.rangeTimer = (self.rangeTimer or 0) + elapsed
-- 		end
-- 	end

-- 	if (self.updateTimer or 0) > 5 then
-- 		self:Update()
-- 		self.updateTimer = 0
-- 	else
-- 		self.updateTimer = (self.updateTimer or 0) + elapsed
-- 	end
-- end)

-- ExtraQuestButton:SetScript("OnEnable", function(self)
-- 	RegisterStateDriver(self, "visible", visibilityState)
-- 	self:SetAttribute("_onattributechanged", onAttributeChanged)
-- 	self:Update()
-- 	self:SetItem()
-- end)

-- ExtraQuestButton:SetScript("OnDisable", function(self)
-- 	if not self:IsMovable() then
-- 		self:SetMovable(true)
-- 	end

-- 	RegisterStateDriver(self, "visible", "show")
-- 	self:SetAttribute("_onattributechanged", nil)
-- 	self.Icon:SetTexture([[Interface\Icons\INV_Misc_Wrench_01]])
-- 	self.HotKey:Hide()
-- end)

-- function ExtraQuestButton:SetItem(itemLink)
-- 	if HasExtraActionBar() then
-- 		return
-- 	end

-- 	if itemLink then
-- 		self.Icon:SetTexture(GetItemIcon(itemLink))
-- 		local itemID = GetItemInfoFromHyperlink(itemLink)
-- 		self.itemID = itemID
-- 		self.itemLink = itemLink

-- 		if C.ExtraQuestButton_Blacklist[itemID] then
-- 			return
-- 		end
-- 	end

-- 	if self.itemID then
-- 		local HotKey = self.HotKey
-- 		local key = GetBindingKey("EXTRAACTIONBUTTON1")
-- 		local hasRange = ItemHasRange(itemLink)
-- 		if key then
-- 			HotKey:SetText(GetBindingText(key, 1))
-- 			HotKey:Show()
-- 		elseif hasRange then
-- 			HotKey:SetText(RANGE_INDICATOR)
-- 			HotKey:Show()
-- 		else
-- 			HotKey:Hide()
-- 		end
-- 		K:GetModule("ActionBar").UpdateHotKey(self)

-- 		self:UpdateAttributes()
-- 		self:UpdateCount()
-- 		self.updateRange = hasRange
-- 	end
-- end

-- function ExtraQuestButton:RemoveItem()
-- 	self.itemID = nil
-- 	self.itemLink = nil
-- 	self:UpdateAttributes()
-- end

-- local function IsQuestOnMap(questID)
-- 	return not onlyCurrentZone or C_QuestLog_IsOnMap(questID)
-- end

-- local function GetQuestDistanceWithItem(questID)
-- 	local questLogIndex = C_QuestLog_GetLogIndexForQuestID(questID)
-- 	if not questLogIndex then
-- 		return
-- 	end

-- 	local itemLink, _, _, showWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex)
-- 	if not itemLink then
-- 		local fallbackItemID = C.ExtraQuestButton_QuestItems[questID]
-- 		if fallbackItemID then
-- 			itemLink = string_format("|Hitem:%d|h", fallbackItemID)
-- 		end
-- 	end

-- 	if not itemLink then
-- 		return
-- 	end

-- 	if GetItemCount(itemLink) == 0 then
-- 		return
-- 	end

-- 	local itemID = GetItemInfoFromHyperlink(itemLink)
-- 	if C.ExtraQuestButton_Blacklist[itemID] then
-- 		return
-- 	end

-- 	if C_QuestLog_IsComplete(questID) then
-- 		if showWhenComplete and C.Complete_HiddenItems[itemID] then -- Hide item when quest completed
-- 			return
-- 		end

-- 		if not showWhenComplete and not C.Complete_ShownItems[itemID] then -- Show item even quest completed
-- 			return
-- 		end
-- 	end

-- 	local distanceSq = C_QuestLog_GetDistanceSqToQuest(questID)
-- 	local distanceYd = distanceSq and sqrt(distanceSq)
-- 	if IsQuestOnMap(questID) and distanceYd and distanceYd <= MAX_DISTANCE_YARDS then
-- 		return distanceYd, itemLink
-- 	end

-- 	local questMapID = C.ExtraQuestButton_InaccurateQuestAreas[questID]
-- 	if questMapID then
-- 		local currentMapID = C_Map_GetBestMapForUnit("player")
-- 		if type(questMapID) == "boolean" then
-- 			return MAX_DISTANCE_YARDS - 1, itemLink
-- 		elseif type(questMapID) == "number" then
-- 			if questMapID == currentMapID then
-- 				return MAX_DISTANCE_YARDS - 2, itemLink
-- 			end
-- 		elseif type(questMapID) == "table" then
-- 			for _, mapID in next, questMapID do
-- 				if mapID == currentMapID then
-- 					return MAX_DISTANCE_YARDS - 2, itemLink
-- 				end
-- 			end
-- 		end
-- 	end
-- end

-- local function GetClosestQuestItem()
-- 	local closestQuestItemLink
-- 	local closestDistance = MAX_DISTANCE_YARDS

-- 	for index = 1, C_QuestLog_GetNumWorldQuestWatches() do
-- 		-- this only tracks supertracked worldquests,
-- 		-- e.g. stuff the player has shift-clicked on the map
-- 		local questID = C_QuestLog_GetQuestIDForWorldQuestWatchIndex(index)
-- 		if questID then
-- 			local distance, itemLink = GetQuestDistanceWithItem(questID)
-- 			if distance and distance <= closestDistance then
-- 				closestDistance = distance
-- 				closestQuestItemLink = itemLink
-- 			end
-- 		end
-- 	end

-- 	if not closestQuestItemLink then
-- 		for index = 1, C_QuestLog_GetNumQuestWatches() do
-- 			local questID = C_QuestLog_GetQuestIDForQuestWatchIndex(index)
-- 			if questID and QuestHasPOIInfo(questID) then
-- 				local distance, itemLink = GetQuestDistanceWithItem(questID)
-- 				if distance and distance <= closestDistance then
-- 					closestDistance = distance
-- 					closestQuestItemLink = itemLink
-- 				end
-- 			end
-- 		end
-- 	end

-- 	if not closestQuestItemLink then
-- 		for index = 1, C_QuestLog_GetNumQuestLogEntries() do
-- 			local info = C_QuestLog_GetInfo(index)
-- 			local questID = info and info.questID
-- 			if questID and not info.isHeader and (not info.isHidden or C_QuestLog_IsWorldQuest(questID)) and QuestHasPOIInfo(questID) then
-- 				local distance, itemLink = GetQuestDistanceWithItem(questID)
-- 				if distance and distance <= closestDistance then
-- 					closestDistance = distance
-- 					closestQuestItemLink = itemLink
-- 				end
-- 			end
-- 		end
-- 	end

-- 	return closestQuestItemLink
-- end

-- function ExtraQuestButton:Update()
-- 	-- if HasExtraActionBar() or self.locked then
-- 	-- 	return
-- 	-- end

-- 	if self.locked then
-- 		return
-- 	end

-- 	local itemLink = GetClosestQuestItem()
-- 	if itemLink then
-- 		if itemLink ~= self.itemLink then
-- 			self:SetItem(itemLink)
-- 		end
-- 	elseif self:IsShown() then
-- 		self:RemoveItem()
-- 	end
-- end
