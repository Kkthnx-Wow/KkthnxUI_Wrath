local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")

local _G = _G
local math_rad = _G.math.rad
local pairs = _G.pairs
local string_match = _G.string.match
local table_wipe = _G.table.wipe
local tonumber = _G.tonumber
local unpack = _G.unpack

local Ambiguate = _G.Ambiguate
local C_NamePlate_GetNamePlateForUnit = _G.C_NamePlate.GetNamePlateForUnit
local CreateFrame = _G.CreateFrame
local GetPlayerInfoByGUID = _G.GetPlayerInfoByGUID
local INTERRUPTED = _G.INTERRUPTED
local InCombatLockdown = _G.InCombatLockdown
local SetCVar = _G.SetCVar
local UnitClassification = _G.UnitClassification
local UnitExists = _G.UnitExists
local UnitGUID = _G.UnitGUID
local UnitIsConnected = _G.UnitIsConnected
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsTapDenied = _G.UnitIsTapDenied
local UnitIsUnit = _G.UnitIsUnit
local UnitName = _G.UnitName
local UnitPlayerControlled = _G.UnitPlayerControlled
local UnitReaction = _G.UnitReaction
local UnitThreatSituation = _G.UnitThreatSituation
local hooksecurefunc = _G.hooksecurefunc

local customUnits = {}
local guidToPlate = {}
local isInInstance
local isTargetClassPower
local showPowerList = {}

-- Unit classification
local classify = {
	elite = {1, 1, 1},
	rare = {1, 1, 1, true},
	rareelite = {1, 0.1, 0.1},
	worldboss = {0, 1, 0},
}

-- Init
function Module:UpdatePlateRange()
	SetCVar("nameplateMaxDistance", C["Nameplate"].Distance)
end

function Module:UpdatePlateScale()
	SetCVar("namePlateMinScale", C["Nameplate"].MinScale)
	SetCVar("namePlateMaxScale", C["Nameplate"].MinScale)
end

function Module:UpdatePlateAlpha()
	SetCVar("nameplateMinAlpha", C["Nameplate"].MinAlpha)
	SetCVar("nameplateMaxAlpha", C["Nameplate"].MinAlpha)
	SetCVar("nameplateNotSelectedAlpha", C["Nameplate"].MinAlpha)
end

function Module:UpdatePlateSpacing()
	SetCVar("nameplateOverlapV", C["Nameplate"].VerticalSpacing)
end

function Module:SetupCVars()
	Module:UpdatePlateRange()
	SetCVar("nameplateOverlapH", 0.8)
	Module:UpdatePlateSpacing()
	Module:UpdatePlateAlpha()
	SetCVar("nameplateSelectedAlpha", 1)

	Module:UpdatePlateScale()
	SetCVar("nameplateSelectedScale", 1)
	SetCVar("nameplateLargerScale", 1)
	SetCVar("nameplateGlobalScale", 1)

	if IsAddOnLoaded("Questie") then
		_QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
		_QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
		_QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")
	end
end

function Module:BlockAddons()
	if not _G.DBM or not _G.DBM.Nameplate then
		return
	end

	function _G.DBM.Nameplate:SupportedNPMod()
		return true
	end

	local function showAurasForDBM(_, _, _, spellID)
		if not tonumber(spellID) then
			return
		end

		if not C.NameplateWhiteList[spellID] then
			C.NameplateWhiteList[spellID] = true
		end
	end

	hooksecurefunc(_G.DBM.Nameplate, "Show", showAurasForDBM)
end

function Module:CreateUnitTable()
	table_wipe(customUnits)
	if not C["Nameplate"].CustomUnitColor then
		return
	end

	K.CopyTable(C.NameplateCustomUnits, customUnits)
	K.SplitList(customUnits, C["Nameplate"].CustomUnitList)
end

function Module:CreatePowerUnitTable()
	table_wipe(showPowerList)
	K.CopyTable(C.NameplateShowPowerList, showPowerList)
	K.SplitList(showPowerList, C["Nameplate"].PowerUnitList)
end

function Module:UpdateUnitPower()
	local unitName = self.unitName
	local npcID = self.npcID
	local shouldShowPower = showPowerList[unitName] or showPowerList[npcID]
	if shouldShowPower then
		self.powerText:Show()
	else
		self.powerText:Hide()
	end
end

-- Update unit color
function Module:UpdateColor(_, unit)
	if not unit or self.unit ~= unit then
		return
	end

	local element = self.Health
	local name = self.unitName
	local npcID = self.npcID
	local isCustomUnit = customUnits[name] or customUnits[npcID]
	local isPlayer = self.isPlayer
	local isFriendly = self.isFriendly
	local status = UnitThreatSituation("player", unit) or false -- just in case

	local customColor = C["Nameplate"].CustomColor
	local targetColor = C["Nameplate"].TargetColor
	local insecureColor = C["Nameplate"].InsecureColor
	local secureColor = C["Nameplate"].SecureColor
	local transColor = C["Nameplate"].TransColor

	local executeRatio = C["Nameplate"].ExecuteRatio
	local healthPerc = UnitHealth(unit) / (UnitHealthMax(unit) + .0001) * 100

	local r, g, b
	if not UnitIsConnected(unit) then
		r, g, b = 0.7, 0.7, 0.7
	else
		if C["Nameplate"].ColoredTarget and UnitIsUnit(unit, "target") then
			r, g, b = targetColor[1], targetColor[2], targetColor[3]
		elseif isCustomUnit then
			r, g, b = customColor[1], customColor[2], customColor[3]
		elseif isPlayer and isFriendly then
			if C["Nameplate"].FriendlyCC then
				r, g, b = K.UnitColor(unit)
			else
				r, g, b = unpack(K.Colors.power["MANA"])
			end
		elseif isPlayer and (not isFriendly) and C["Nameplate"].HostileCC then
			r, g, b = K.UnitColor(unit)
		elseif UnitIsTapDenied(unit) and not UnitPlayerControlled(unit) then
			r, g, b = .6, .6, .6
		else
			r, g, b = K.oUF:UnitSelectionColor(unit, true)
			if status and C["Nameplate"].TankMode then
				if status == 3 then
					r, g, b = secureColor[1], secureColor[2], secureColor[3]
				elseif status == 2 or status == 1 then
					r, g, b = transColor[1], transColor[2], transColor[3]
				elseif status == 0 then
					r, g, b = insecureColor[1], insecureColor[2], insecureColor[3]
				end
			end
		end
	end

	if r or g or b then
		element:SetStatusBarColor(r, g, b)
	end

	if isCustomUnit or not C["Nameplate"].TankMode then
		if status and status == 3 then
			self.ThreatIndicator:SetBackdropBorderColor(1, 0, 0)
			self.ThreatIndicator:Show()
		elseif status and (status == 2 or status == 1) then
			self.ThreatIndicator:SetBackdropBorderColor(1, 1, 0)
			self.ThreatIndicator:Show()
		else
			self.ThreatIndicator:Hide()
		end
	else
		self.ThreatIndicator:Hide()
	end

	if executeRatio > 0 and healthPerc <= executeRatio then
		self.nameText:SetTextColor(1, 0, 0)
	else
		self.nameText:SetTextColor(1, 1, 1)
	end
end

function Module:UpdateThreatColor(_, unit)
	if unit ~= self.unit then
		return
	end

	Module.UpdateColor(self, _, unit)
end

-- Backdrop shadow
function Module:CreateThreatColor(self)
	local threatIndicator = self:CreateShadow()
	threatIndicator:SetPoint("TOPLEFT", self.Health.backdrop, "TOPLEFT", -1, 1)
	threatIndicator:SetPoint("BOTTOMRIGHT", self.Health.backdrop, "BOTTOMRIGHT", 1, -1)
	threatIndicator:Hide()

	self.ThreatIndicator = threatIndicator
	self.ThreatIndicator.Override = Module.UpdateThreatColor
end

-- Target indicator
function Module:UpdateTargetChange()
	local element = self.TargetIndicator
	local unit = self.unit
	if C["Nameplate"].TargetIndicator.Value == 1 then
		return
	end

	if C["Nameplate"].TargetIndicator.Value ~= 1 then
		if UnitIsUnit(unit, "target") and not UnitIsUnit(unit, "player") then
			element:Show()
		else
			element:Hide()
		end
	end

	if C["Nameplate"].ColoredTarget then
		Module.UpdateThreatColor(self, _, unit)
	end
end

function Module:UpdateTargetIndicator()
	local style = C["Nameplate"].TargetIndicator.Value

	local element = self.TargetIndicator
	local isNameOnly = self.isNameOnly
	if style == 1 then
		element:Hide()
	else
		if style == 2 then
			element.TopArrow:Show()
			element.RightArrow:Hide()
			element.Glow:Hide()
			element.nameGlow:Hide()
		elseif style == 3 then
			element.TopArrow:Hide()
			element.RightArrow:Show()
			element.Glow:Hide()
			element.nameGlow:Hide()
		elseif style == 4 then
			element.TopArrow:Hide()
			element.RightArrow:Hide()
			if isNameOnly then
				element.Glow:Hide()
				element.nameGlow:Show()
			else
				element.Glow:Show()
				element.nameGlow:Hide()
			end
		elseif style == 5 then
			element.TopArrow:Show()
			element.RightArrow:Hide()
			if isNameOnly then
				element.Glow:Hide()
				element.nameGlow:Show()
			else
				element.Glow:Show()
				element.nameGlow:Hide()
			end
		elseif style == 6 then
			element.TopArrow:Hide()
			element.RightArrow:Show()
			if isNameOnly then
				element.Glow:Hide()
				element.nameGlow:Show()
			else
				element.Glow:Show()
				element.nameGlow:Hide()
			end
		end
		element:Show()
	end
end

function Module:AddTargetIndicator(self)
	self.TargetIndicator = CreateFrame("Frame", nil, self)
	self.TargetIndicator:SetAllPoints()
	self.TargetIndicator:SetFrameLevel(0)
	self.TargetIndicator:Hide()

	self.TargetIndicator.TopArrow = self.TargetIndicator:CreateTexture(nil, "BACKGROUND", nil, -5)
	self.TargetIndicator.TopArrow:SetSize(128 / 2, 128 / 2)
	self.TargetIndicator.TopArrow:SetTexture(C["Nameplate"].TargetIndicatorTexture.Value)
	self.TargetIndicator.TopArrow:SetPoint("BOTTOM", self.TargetIndicator, "TOP", 0, 40)

	self.TargetIndicator.RightArrow = self.TargetIndicator:CreateTexture(nil, "BACKGROUND", nil, -5)
	self.TargetIndicator.RightArrow:SetSize(128 / 2, 128 / 2)
	self.TargetIndicator.RightArrow:SetTexture(C["Nameplate"].TargetIndicatorTexture.Value)
	self.TargetIndicator.RightArrow:SetPoint("LEFT", self.TargetIndicator, "RIGHT", 3, 0)
	self.TargetIndicator.RightArrow:SetRotation(math_rad(-90))

	self.TargetIndicator.Glow = CreateFrame("Frame", nil, self.TargetIndicator, "BackdropTemplate")
	self.TargetIndicator.Glow:SetPoint("TOPLEFT", self.Health.backdrop, -2, 2)
	self.TargetIndicator.Glow:SetPoint("BOTTOMRIGHT", self.Health.backdrop, 2, -2)
	self.TargetIndicator.Glow:SetBackdrop({edgeFile = C["Media"].Textures.GlowTexture, edgeSize = 4})
	self.TargetIndicator.Glow:SetBackdropBorderColor(unpack(C["Nameplate"].TargetIndicatorColor))
	self.TargetIndicator.Glow:SetFrameLevel(0)

	self.TargetIndicator.nameGlow = self.TargetIndicator:CreateTexture(nil, "BACKGROUND", nil, -5)
	self.TargetIndicator.nameGlow:SetSize(150, 80)
	self.TargetIndicator.nameGlow:SetTexture("Interface\\GLUES\\Models\\UI_Draenei\\GenericGlow64")
	self.TargetIndicator.nameGlow:SetVertexColor(102/255, 157/255, 255/255)
	self.TargetIndicator.nameGlow:SetBlendMode("ADD")
	self.TargetIndicator.nameGlow:SetPoint("CENTER", self, "BOTTOM")

	self:RegisterEvent("PLAYER_TARGET_CHANGED", Module.UpdateTargetChange, true)
	Module.UpdateTargetIndicator(self)
end

local function CheckInstanceStatus()
	isInInstance = IsInInstance()
end

function Module:QuestIconCheck()
	if not C["Nameplate"].QuestIndicator then
		return
	end

	CheckInstanceStatus()
	K:RegisterEvent("PLAYER_ENTERING_WORLD", CheckInstanceStatus)
end

function Module:UpdateQuestUnit(_, unit)
	if not C["Nameplate"].QuestIndicator then
		return
	end

	if isInInstance then
		self.questIcon:Hide()
		self.questCount:SetText("")
		return
	end

	unit = unit or self.unit

	local isLootQuest, questProgress
	K.ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	K.ScanTooltip:SetUnit(unit)

	for i = 2, K.ScanTooltip:NumLines() do
		local textLine = _G["KKUI_ScanTooltipTextLeft"..i]
		local text = textLine:GetText()
		if textLine and text then
			local r, g, b = textLine:GetTextColor()
			local unitName, progressText = string_match(text, "^ ([^ ]-) ?%- (.+)$")
			if r > .99 and g > .82 and b == 0 then
				isLootQuest = true
			elseif unitName and progressText then
				isLootQuest = false
				if unitName == "" or unitName == K.Name then
					local current, goal = string_match(progressText, "(%d+)/(%d+)")
					local progress = string_match(progressText, "([%d%.]+)%%")
					if current and goal then
						if tonumber(current) < tonumber(goal) then
							questProgress = goal - current
							break
						end
					elseif progress then
						progress = tonumber(progress)
						if progress and progress < 100 then
							questProgress = progress.."%"
							break
						end
					else
						isLootQuest = true
						break
					end
				end
			end
		end
	end

	if questProgress then
		self.questCount:SetText(questProgress)
		self.questIcon:SetTexture("Interface\\WorldMap\\Skull_64Grey")
		self.questIcon:Show()
	else
		self.questCount:SetText("")
		if isLootQuest then
			self.questIcon:SetAtlas("QuestNormal")
			self.questIcon:Show()
		else
			self.questIcon:Hide()
		end
	end
end

function Module:UpdateForQuestie(npcID)
	local data = _QuestieTooltips.lookupByKey and _QuestieTooltips.lookupByKey["m_"..npcID]
	if data then
		local foundObjective, progressText
		for _, tooltip in pairs(data) do
			local questID = tooltip.questId
			_QuestieQuest:UpdateQuest(questID)

			if _QuestiePlayer.currentQuestlog[questID] then
				foundObjective = true

				if tooltip.objective and tooltip.objective.Needed then
					progressText = tooltip.objective.Needed - tooltip.objective.Collected
					if progressText == 0 then
						foundObjective = nil
					end
					break
				end
			end
		end

		if foundObjective then
			self.questIcon:Show()
			self.questCount:SetText(progressText)
		end
	end
end

function Module:UpdateCodexQuestUnit(name)
	if name and CodexMap.tooltips[name] then
		for _, meta in pairs(CodexMap.tooltips[name]) do
			local questData = meta["quest"]
			local quests = CodexDB.quests.loc

			if questData then
				for questIndex = 1, GetNumQuestLogEntries() do
					local _, _, _, header, _, _, _, questId = GetQuestLogTitle(questIndex)
					if not header and quests[questId] and questData == quests[questId].T then
						local objectives = GetNumQuestLeaderBoards(questIndex)
						local foundObjective, progressText = nil
						if objectives then
							for i = 1, objectives do
								local text, type = GetQuestLogLeaderBoard(i, questIndex)
								if type == "monster" then
									local _, _, monsterName, objNum, objNeeded = strfind(text, Codex:SanitizePattern(QUEST_MONSTERS_KILLED))
									if meta["spawn"] == monsterName then
										progressText = objNeeded - objNum
										foundObjective = true
										break
									end
								elseif table.getn(meta["item"]) > 0 and type == "item" and meta["dropRate"] then
									local _, _, itemName, objNum, objNeeded = strfind(text, Codex:SanitizePattern(QUEST_OBJECTS_FOUND))
									for _, item in pairs(meta["item"]) do
										if item == itemName then
											progressText = objNeeded - objNum
											foundObjective = true
											break
										end
									end
								end
							end
						end

						if foundObjective and progressText > 0 then
							self.questIcon:Show()
							self.questCount:SetText(progressText)
						elseif not foundObjective then
							self.questIcon:Show()
						end
					end
				end
			end
		end
	end
end

function Module:UpdateQuestIndicator()
	if not C["Nameplate"].QuestIndicator then
		return
	end

	self.questIcon:Hide()
	self.questCount:SetText("")

	if CodexMap then
		Module.UpdateCodexQuestUnit(self, self.unitName)
	elseif _QuestieTooltips then
		Module.UpdateForQuestie(self, self.npcID)
	end
end

function Module:AddQuestIcon(self)
	if not C["Nameplate"].QuestIndicator then
		return
	end

	self.questIcon = self:CreateTexture(nil, "OVERLAY", nil, 2)
	self.questIcon:SetPoint("LEFT", self, "RIGHT", 1, 0)
	self.questIcon:SetSize(25, 25)
	self.questIcon:SetAtlas("QuestNormal")
	self.questIcon:Hide()

	self.questCount = K.CreateFontString(self, 13, "", "", nil, "LEFT", 0, 0)
	self.questCount:SetPoint("LEFT", self.questIcon, "RIGHT", -2, 0)

	self:RegisterEvent("QUEST_LOG_UPDATE", Module.UpdateQuestIndicator, true)
end

function Module:AddClassIcon(self)
	if not C["Nameplate"].ClassIcon then
		return
	end

	self.Class = CreateFrame("Frame", nil, self)
	self.Class:SetSize(self:GetHeight() * 2 + 3, self:GetHeight() * 2 + 3)
	self.Class:SetPoint("BOTTOMLEFT", self.Castbar, "BOTTOMRIGHT", 3, 0)
	self.Class:CreateShadow(true)
	self.Class:SetAlpha(0)

	self.Class.Icon = self.Class:CreateTexture(nil, "OVERLAY")
	self.Class.Icon:SetAllPoints(self.Class)
	self.Class.Icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
end

function Module:UpdateClassIcon(self, unit)
	if C["Nameplate"].ClassIcon and UnitIsPlayer(unit) and (UnitReaction(unit, "player") and UnitReaction(unit, "player") <= 4) then
		local unitClass = select(2, UnitClass(unit))

		if unitClass then
			local Left, Right, Top, Bottom = unpack(CLASS_ICON_TCOORDS[unitClass])

			-- Remove borders on icon
			Left = Left + (Right - Left) * 0.075
			Right = Right - (Right - Left) * 0.075
			Top = Top + (Bottom - Top) * 0.075
			Bottom = Bottom - (Bottom - Top) * 0.075

			self.Class.Icon:SetTexCoord(Left, Right, Top, Bottom)
			self.Class:SetAlpha(1)
		end
	elseif self.Class then -- Make sure we check before we try to change it
		self.Class:SetAlpha(0)
	end
end

function Module:AddCreatureIcon(self)
	local iconFrame = CreateFrame("Frame", nil, self)
	iconFrame:SetAllPoints()
	iconFrame:SetFrameLevel(self:GetFrameLevel() + 2)

	self.ClassifyIndicator = iconFrame:CreateTexture(nil, "ARTWORK")
	self.ClassifyIndicator:SetAtlas("VignetteKill")
	self.ClassifyIndicator:SetPoint("BOTTOMLEFT", self, "LEFT", 0, -4)
	self.ClassifyIndicator:SetSize(19, 19)
	self.ClassifyIndicator:Hide()
end

function Module:UpdateUnitClassify(unit)
	if self.ClassifyIndicator then
		local class = UnitClassification(unit)
		if (not self.isNameOnly) and class and classify[class] then
			local r, g, b, desature = unpack(classify[class])
			self.ClassifyIndicator:SetVertexColor(r, g, b)
			self.ClassifyIndicator:SetDesaturated(desature)
			self.ClassifyIndicator:Show()
		else
			self.ClassifyIndicator:Hide()
		end
	end
end

-- Mouseover indicator
function Module:IsMouseoverUnit()
	if not self or not self.unit then
		return
	end

	if self:IsVisible() and UnitExists("mouseover") then
		return UnitIsUnit("mouseover", self.unit)
	end

	return false
end

function Module:UpdateMouseoverShown()
	if not self or not self.unit then
		return
	end

	if self:IsShown() and UnitIsUnit("mouseover", self.unit) then
		self.HighlightIndicator:Show()
		self.HighlightUpdater:Show()
	else
		self.HighlightUpdater:Hide()
	end
end

function Module:MouseoverIndicator(self)
	self.HighlightIndicator = CreateFrame("Frame", nil, self.Health)
	self.HighlightIndicator:SetAllPoints(self)
	self.HighlightIndicator:Hide()

	self.HighlightIndicator.Texture = self.HighlightIndicator:CreateTexture(nil, "ARTWORK")
	self.HighlightIndicator.Texture:SetAllPoints()
	self.HighlightIndicator.Texture:SetColorTexture(1, 1, 1, .25)

	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", Module.UpdateMouseoverShown, true)

	self.HighlightUpdater = CreateFrame("Frame", nil, self)
	self.HighlightUpdater:SetScript("OnUpdate", function(_, elapsed)
		self.HighlightUpdater.elapsed = (self.HighlightUpdater.elapsed or 0) + elapsed
		if self.HighlightUpdater.elapsed > .1 then
			if not Module.IsMouseoverUnit(self) then
				self.HighlightUpdater:Hide()
			end

			self.HighlightUpdater.elapsed = 0
		end
	end)

	self.HighlightUpdater:HookScript("OnHide", function()
		self.HighlightIndicator:Hide()
	end)
end

-- Interrupt info on castbars
function Module:UpdateCastbarInterrupt(...)
	local _, eventType, _, sourceGUID, sourceName, _, _, destGUID = ...
	if eventType == "SPELL_INTERRUPT" and destGUID and sourceName and sourceName ~= "" then
		local nameplate = guidToPlate[destGUID]
		if nameplate and nameplate.Castbar then
			local _, class = GetPlayerInfoByGUID(sourceGUID)
			local r, g, b = K.ColorClass(class)
			local color = K.RGBToHex(r, g, b)
			local sourceName = Ambiguate(sourceName, "short")
			nameplate.Castbar.Text:SetText(INTERRUPTED.." > "..color..sourceName)
			nameplate.Castbar.Time:SetText("")
		end
	end
end

function Module:AddInterruptInfo()
	K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.UpdateCastbarInterrupt)
end

-- Create Nameplates
local platesList = {}
function Module:CreatePlates()
	self.mystyle = "nameplate"

	self:SetSize(C["Nameplate"].PlateWidth, C["Nameplate"].PlateHeight)
	self:SetPoint("CENTER")
	self:SetScale(C["General"].UIScale)

	self.Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	self.Overlay:SetAllPoints()
	self.Overlay:SetFrameLevel(4)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetAllPoints()
	self.Health:SetStatusBarTexture(K.GetTexture(C["UITextures"].NameplateTextures))

	self.Health.backdrop = self.Health:CreateShadow(true) -- don't mess up with libs
	self.Health.backdrop:SetPoint("TOPLEFT", self.Health, "TOPLEFT", -3, 3)
	self.Health.backdrop:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 3, -3)
	self.Health.backdrop:SetFrameLevel(self.Health:GetFrameLevel())

	self.Health.frequentUpdates = true
	self.Health.UpdateColor = Module.UpdateColor

	if C["Nameplate"].Smooth then
		K:SmoothBar(self.Health)
	end

	self.levelText = K.CreateFontString(self, C["Nameplate"].NameTextSize, "", "", false)
	self.levelText:SetJustifyH("RIGHT")
	self.levelText:ClearAllPoints()
	self.levelText:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 3)
	self:Tag(self.levelText, "[nplevel]")

	self.nameText = K.CreateFontString(self, C["Nameplate"].NameTextSize, "", "", false)
	self.nameText:SetJustifyH("LEFT")
	self.nameText:SetWidth(self:GetWidth() * 0.85)
	self.nameText:ClearAllPoints()
	self.nameText:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 3)
	self:Tag(self.nameText, "[name]")

	self.npcTitle = K.CreateFontString(self, C["Nameplate"].NameTextSize - 1)
	self.npcTitle:ClearAllPoints()
	self.npcTitle:SetPoint("TOP", self, "BOTTOM", 0, -10)
	self.npcTitle:Hide()
	self:Tag(self.npcTitle, "[npctitle]")

	self.guildName = K.CreateFontString(self, C["Nameplate"].NameTextSize - 1)
	self.guildName:SetTextColor(211/255, 211/255, 211/255)
	self.guildName:ClearAllPoints()
	self.guildName:SetPoint("TOP", self, "BOTTOM", 0, -10)
	self.guildName:Hide()
	self:Tag(self.guildName, "[guildname]")

	self.healthValue = K.CreateFontString(self.Overlay, C["Nameplate"].HealthTextSize, "", "", false, "CENTER", 0, 0)
	self.healthValue:SetPoint("CENTER", self.Overlay, 0, 0)
	self:Tag(self.healthValue, "[nphp]")

	self.Castbar = CreateFrame("StatusBar", "oUF_CastbarNameplate", self)
	self.Castbar:SetHeight(20)
	self.Castbar:SetWidth(self:GetWidth() - 22)
	self.Castbar:SetStatusBarTexture(K.GetTexture(C["UITextures"].NameplateTextures))
	self.Castbar:CreateShadow(true)
	self.Castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -3)
	self.Castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -3)
	self.Castbar:SetHeight(self:GetHeight())

	self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Spark:SetTexture(C["Media"].Textures.Spark128Texture)
	self.Castbar.Spark:SetSize(64, self.Castbar:GetHeight())
	self.Castbar.Spark:SetBlendMode("ADD")

	self.Castbar.Time = K.CreateFontString(self.Castbar, C["Nameplate"].NameTextSize, "", "", false, "RIGHT", -2, 0)
	self.Castbar.Text = K.CreateFontString(self.Castbar, C["Nameplate"].NameTextSize, "", "", false, "LEFT", 2, 0)
	self.Castbar.Text:SetPoint("RIGHT", self.Castbar.Time, "LEFT", -5, 0)
	self.Castbar.Text:SetJustifyH("LEFT")

	self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
	self.Castbar.Button:SetSize(self:GetHeight() * 2 + 3, self:GetHeight() * 2 + 3)
	self.Castbar.Button:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMLEFT", -3, 0)
	self.Castbar.Button:CreateShadow(true)

	self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
	self.Castbar.Icon:SetAllPoints()
	self.Castbar.Icon:SetTexCoord(unpack(K.TexCoords))

	self.Castbar.Text:SetPoint("LEFT", self.Castbar, 0, -5)
	self.Castbar.Time:SetPoint("RIGHT", self.Castbar, 0, -5)

	self.Castbar.Shield = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Shield:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\CastBorderShield")
	self.Castbar.Shield:SetTexCoord(0, 0.84375, 0, 1)
	self.Castbar.Shield:SetSize(16 * 0.84375, 16)
	self.Castbar.Shield:SetPoint("CENTER", 0, -5)
	self.Castbar.Shield:SetVertexColor(0.5, 0.5, 0.7)

	self.Castbar.timeToHold = .5
	self.Castbar.decimal = "%.1f"

	self.Castbar.spellTarget = K.CreateFontString(self.Castbar, C["Nameplate"].NameTextSize + 3)
	self.Castbar.spellTarget:ClearAllPoints()
	self.Castbar.spellTarget:SetJustifyH("LEFT")
	self.Castbar.spellTarget:SetPoint("TOP", self.Castbar, "BOTTOM", 0, -6)

	self.Castbar.OnUpdate = Module.OnCastbarUpdate
	self.Castbar.PostCastStart = Module.PostCastStart
	self.Castbar.PostChannelStart = Module.PostCastStart
	self.Castbar.PostCastStop = Module.PostCastStop
	self.Castbar.PostChannelStop = Module.PostChannelStop
	self.Castbar.PostCastDelayed = Module.PostCastUpdate
	self.Castbar.PostChannelUpdate = Module.PostCastUpdate
	self.Castbar.PostCastFailed = Module.PostCastFailed
	self.Castbar.PostCastInterrupted = Module.PostCastFailed
	self.Castbar.PostCastInterruptible = Module.PostUpdateInterruptible
	self.Castbar.PostCastNotInterruptible = Module.PostUpdateInterruptible

	self.RaidTargetIndicator = self:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 20)
	self.RaidTargetIndicator:SetParent(self.Health)
	self.RaidTargetIndicator:SetSize(16, 16)

	do
		local myBar = CreateFrame("StatusBar", nil, self)
		myBar:SetWidth(self:GetWidth())
		myBar:SetPoint("TOP", self.Health, "TOP")
		myBar:SetPoint("BOTTOM", self.Health, "BOTTOM")
		myBar:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
		myBar:SetStatusBarTexture(C["UITextures"].HealPredictionTextures)
		myBar:SetStatusBarColor(0, 1, 0.5, 0.25)
		myBar:Hide()

		local otherBar = CreateFrame("StatusBar", nil, self)
		otherBar:SetWidth(self:GetWidth())
		otherBar:SetPoint("TOP", self.Health, "TOP")
		otherBar:SetPoint("BOTTOM", self.Health, "BOTTOM")
		otherBar:SetPoint("LEFT", myBar:GetStatusBarTexture(), "RIGHT")
		otherBar:SetStatusBarTexture(C["UITextures"].HealPredictionTextures)
		otherBar:SetStatusBarColor(0, 1, 0, 0.25)
		otherBar:Hide()

		self.HealthPrediction = {
			myBar = myBar,
			otherBar = otherBar,
			maxOverflow = 1,
		}
	end

	self.Auras = CreateFrame("Frame", nil, self)
	self.Auras:SetFrameLevel(self:GetFrameLevel() + 2)
	self.Auras.spacing = 4
	self.Auras.initdialAnchor = "BOTTOMLEFT"
	self.Auras["growth-y"] = "UP"
	if C["Nameplate"].ShowPlayerPlate and C["Nameplate"].NameplateClassPower then
		self.Auras:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 6 + _G.oUF_ClassPowerBar:GetHeight())
	else
		self.Auras:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 5)
	end
	self.Auras.numTotal = C["Nameplate"].MaxAuras
	self.Auras.size = C["Nameplate"].AuraSize
	self.Auras.gap = false
	self.Auras.disableMouse = true

	local width = self:GetWidth()
	local maxLines = 2
	self.Auras:SetWidth(width)
	self.Auras:SetHeight((self.Auras.size + self.Auras.spacing) * maxLines)

	self.Auras.showStealableBuffs = true
	self.Auras.CustomFilter = Module.CustomFilter
	self.Auras.PostCreateIcon = Module.PostCreateAura
	self.Auras.PostUpdateIcon = Module.PostUpdateAura

	Module:CreateThreatColor(self)

	self.PvPClassificationIndicator = self:CreateTexture(nil, "ARTWORK")
	self.PvPClassificationIndicator:SetSize(18, 18)
	self.PvPClassificationIndicator:ClearAllPoints()
	if C["Nameplate"].ClassIcon then
		self.PvPClassificationIndicator:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 20)
	else
		self.PvPClassificationIndicator:SetPoint("LEFT", self, "RIGHT", 6, 0)
	end

	self.powerText = K.CreateFontString(self, 15)
	self.powerText:ClearAllPoints()
	self.powerText:SetPoint("TOP", self.Castbar, "BOTTOM", 0, -4)
	self:Tag(self.powerText, "[nppp]")

	Module:MouseoverIndicator(self)
	Module:AddTargetIndicator(self)
	Module:AddCreatureIcon(self)
	Module:AddQuestIcon(self)
	Module:AddClassIcon(self)

	platesList[self] = self:GetName()
end

-- Classpower on target nameplate
function Module:UpdateClassPowerAnchor()
	if not isTargetClassPower then
		return
	end

	local bar = _G.oUF_ClassPowerBar
	local nameplate = C_NamePlate_GetNamePlateForUnit("target")
	if nameplate then
		bar:SetParent(nameplate.unitFrame)
		bar:ClearAllPoints()
		bar:SetPoint("BOTTOM", nameplate.unitFrame, "TOP", 0, 18)
		bar:Show()
	else
		bar:Hide()
	end
end

function Module:UpdateTargetClassPower()
	local bar = _G.oUF_ClassPowerBar
	local playerPlate = _G.oUF_PlayerPlate

	if not bar or not playerPlate then
		return
	end

	if C["Nameplate"].NameplateClassPower then
		isTargetClassPower = true
		Module:UpdateClassPowerAnchor()
	else
		isTargetClassPower = false
		bar:SetParent(playerPlate.Health)
		bar:ClearAllPoints()
		bar:SetPoint("BOTTOMLEFT", playerPlate.Health, "TOPLEFT", 0, 3)
		bar:Show()
	end
end

function Module:RefreshNameplates()
	local plateHeight = C["Nameplate"].PlateHeight
	local nameTextSize = C["Nameplate"].NameTextSize
	local iconSize = plateHeight * 2 + 3

	for nameplate in pairs(platesList) do
		nameplate:SetSize(C["Nameplate"].PlateWidth, plateHeight)
		nameplate.nameText:SetFont(C["Media"].Fonts.KkthnxUIFont, nameTextSize, "")
		nameplate.npcTitle:SetFont(C["Media"].Fonts.KkthnxUIFont, nameTextSize - 1, "")
		nameplate.Castbar.Icon:SetSize(iconSize, iconSize)
		nameplate.Castbar:SetHeight(plateHeight)
		nameplate.Castbar.Time:SetFont(C["Media"].Fonts.KkthnxUIFont, nameTextSize, "")
		nameplate.Castbar.Text:SetFont(C["Media"].Fonts.KkthnxUIFont, nameTextSize, "")
		nameplate.Castbar.spellTarget:SetFont(C["Media"].Fonts.KkthnxUIFont, nameTextSize + 3, "")
		nameplate.healthValue:SetFont(C["Media"].Fonts.KkthnxUIFont, C["Nameplate"].HealthTextSize, "")
		nameplate.healthValue:UpdateTag()
		-- Module.UpdateNameplateAuras(nameplate)
		Module.UpdateTargetIndicator(nameplate)
		Module.UpdateTargetChange(nameplate)
	end
end

function Module:RefreshAllPlates()
	if C["Nameplate"].ShowPlayerPlate then
		Module:ResizePlayerPlate()
	end
	Module:RefreshNameplates()
end

local DisabledElements = {
	"Health", "Castbar", "HealthPrediction", "ThreatIndicator"
}
function Module:UpdatePlateByType()
	local name = self.nameText
	local level = self.levelText
	local hpval = self.healthValue
	local title = self.npcTitle
	local guild = self.guildName
	local raidtarget = self.RaidTargetIndicator
	local classify = self.ClassifyIndicator
	local questIcon = self.questIcon
	local widgetBar = self.WidgetXPBar

	name:ClearAllPoints()
	raidtarget:ClearAllPoints()

	if self.isNameOnly then
		for _, element in pairs(DisabledElements) do
			if self:IsElementEnabled(element) then
				self:DisableElement(element)
			end
		end

		name:SetJustifyH("CENTER")
		self:Tag(name, "[color][name] [nplevel]")
		name:UpdateTag()
		name:SetPoint("CENTER", self, "BOTTOM")

		level:Hide()
		hpval:Hide()
		title:Show()
		guild:Show()

		raidtarget:SetPoint("TOP", title, "BOTTOM", 0, -5)
		raidtarget:SetParent(self)
		classify:Hide()
		if questIcon then
			questIcon:SetPoint("LEFT", name, "RIGHT", 0, 0)
		end

		if widgetBar then
			widgetBar:SetPoint("TOP", self.Castbar, "BOTTOM", 0, -12)
		end
	else
		for _, element in pairs(DisabledElements) do
			if not self:IsElementEnabled(element) then
				self:EnableElement(element)
			end
		end

		name:SetJustifyH("LEFT")
		self:Tag(name, "[name]")
		name:UpdateTag()
		name:SetWidth(self:GetWidth() * 0.85)
		name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 3)

		level:Show()
		hpval:Show()
		title:Hide()
		guild:Hide()

		raidtarget:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 20)
		raidtarget:SetParent(self.Health)
		classify:Show()
		if questIcon then
			questIcon:SetPoint("LEFT", self, "RIGHT", 1, 0)
		end

		if widgetBar then
			widgetBar:ClearAllPoints()
			widgetBar:SetPoint("TOP", self.Castbar, "BOTTOM", 0, -5)
		end
	end

	Module.UpdateTargetIndicator(self)
end

function Module:RefreshPlateType(unit)
	self.reaction = UnitReaction(unit, "player")
	self.isFriendly = self.reaction and self.reaction >= 5
	self.isNameOnly = C["Nameplate"].NameOnly and self.isFriendly or false

	if self.previousType == nil or self.previousType ~= self.isNameOnly then
		Module.UpdatePlateByType(self)
		self.previousType = self.isNameOnly
	end
end

function Module:OnUnitFactionChanged(unit)
	local nameplate = C_NamePlate_GetNamePlateForUnit(unit, issecure())
	local unitFrame = nameplate and nameplate.unitFrame
	if unitFrame and unitFrame.unitName then
		Module.RefreshPlateType(unitFrame, unit)
	end
end

function Module:RefreshPlateOnFactionChanged()
	K:RegisterEvent("UNIT_FACTION", Module.OnUnitFactionChanged)
end

function Module:PostUpdatePlates(event, unit)
	if not self then
		return
	end

	if event == "NAME_PLATE_UNIT_ADDED" then
		self.unitName = UnitName(unit)
		self.unitGUID = UnitGUID(unit)
		if self.unitGUID then
			guidToPlate[self.unitGUID] = self
		end

		self.isPlayer = UnitIsPlayer(unit)
		self.npcID = K.GetNPCID(self.unitGUID)

		local blizzPlate = self:GetParent().UnitFrame
		self.widgetContainer = blizzPlate and blizzPlate.WidgetContainer
		Module.RefreshPlateType(self, unit)
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		if self.unitGUID then
			guidToPlate[self.unitGUID] = nil
		end
		self.npcID = nil
	end

	if event ~= "NAME_PLATE_UNIT_REMOVED" then
		Module.UpdateUnitPower(self)
		Module.UpdateTargetChange(self)
		-- Module.UpdateQuestUnit(self, event, unit)
		Module.UpdateQuestIndicator(self)
		Module.UpdateUnitClassify(self, unit)
		Module:UpdateClassIcon(self, unit)
		Module:UpdateClassPowerAnchor()
	end
end

-- Player Nameplate
function Module:PlateVisibility(event)
	if (event == "PLAYER_REGEN_DISABLED" or InCombatLockdown()) and UnitIsUnit("player", self.unit) then
		UIFrameFadeIn(self.Health, 0.2, self.Health:GetAlpha(), 1)
		UIFrameFadeIn(self.Power, 0.2, self.Power:GetAlpha(), 1)
		UIFrameFadeIn(self.Buffs, 0.2, self.Power:GetAlpha(), 1)
	else
		UIFrameFadeOut(self.Health, 0.2, self.Health:GetAlpha(), 0)
		UIFrameFadeOut(self.Power, 0.2, self.Power:GetAlpha(), 0)
		UIFrameFadeOut(self.Buffs, 0.2, self.Power:GetAlpha(), 0)
	end
end

function Module:CreatePlayerPlate()
	self.mystyle = "PlayerPlate"

	local iconSize, margin = C["Nameplate"].PPIconSize, 2
	self:SetSize(iconSize * 5 + margin * 4, C["Nameplate"].PPHeight)
	self:EnableMouse(false)
	self.iconSize = iconSize

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetAllPoints()
	self.Health:SetStatusBarTexture(K.GetTexture(C["UITextures"].NameplateTextures))
	self.Health:SetStatusBarColor(0.1, 0.1, 0.1)
	self.Health:CreateShadow(true)

	self.Health.colorHealth = true

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetStatusBarTexture(K.GetTexture(C["UITextures"].NameplateTextures))
	self.Power:SetHeight(C["Nameplate"].PPPHeight)
	self.Power:SetWidth(self:GetWidth())
	self.Power:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -3)
	self.Power:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -3)
	self.Power:CreateShadow(true)

	self.Power.colorClass = true
	self.Power.colorTapping = true
	self.Power.colorDisconnected = true
	self.Power.colorReaction = true
	self.Power.frequentUpdates = true

	Module:CreateClassPower(self)

	-- Aura tracking
	self.Buffs = CreateFrame("Frame", nil, self)
	self.Buffs:SetFrameLevel(self:GetFrameLevel() + 2)
	self.Buffs.spacing = 4
	self.Buffs.initdialAnchor = "BOTTOMLEFT"
	self.Buffs["growth-y"] = "UP"
	if C["Nameplate"].ShowPlayerPlate and not C["Nameplate"].NameplateClassPower then
		self.Buffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 6 + _G.oUF_ClassPowerBar:GetHeight())
	else
		self.Buffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 5)
	end
	self.Buffs.numTotal = C["Nameplate"].MaxAuras
	self.Buffs.size = C["Nameplate"].AuraSize
	self.Buffs.gap = false
	self.Buffs.disableMouse = true

	local width = self:GetWidth()
	local maxLines = 2
	self.Buffs:SetWidth(width)
	self.Buffs:SetHeight((self.Buffs.size + self.Buffs.spacing) * maxLines)

	self.Buffs.CustomFilter = Module.CustomFilter
	self.Buffs.PostCreateIcon = Module.PostCreateAura
	self.Buffs.PostUpdateIcon = Module.PostUpdateAura

	local textFrame = CreateFrame("Frame", nil, self.Power)
	textFrame:SetAllPoints()
	self.powerText = K.CreateFontString(textFrame, 14, "")
	self:Tag(self.powerText, "[pppower]")
	Module:TogglePlatePower()

	Module:CreateGCDTicker(self)
	Module:UpdateTargetClassPower()
	Module:TogglePlateVisibility()
end

function Module:TogglePlatePower()
	local plate = _G.oUF_PlayerPlate
	if not plate then
		return
	end

	plate.powerText:SetShown(C["Nameplate"].PPPowerText)
end

function Module:TogglePlateVisibility()
	local plate = _G.oUF_PlayerPlate
	if not plate then
		return
	end

	if C["Nameplate"].PPHideOOC then
		plate:RegisterEvent("PLAYER_REGEN_ENABLED", Module.PlateVisibility, true)
		plate:RegisterEvent("PLAYER_REGEN_DISABLED", Module.PlateVisibility, true)
		plate:RegisterEvent("PLAYER_ENTERING_WORLD", Module.PlateVisibility, true)
		Module.PlateVisibility(plate)
	else
		plate:UnregisterEvent("PLAYER_REGEN_ENABLED", Module.PlateVisibility)
		plate:UnregisterEvent("PLAYER_REGEN_DISABLED", Module.PlateVisibility)
		plate:UnregisterEvent("PLAYER_ENTERING_WORLD", Module.PlateVisibility)
		Module.PlateVisibility(plate, "PLAYER_REGEN_DISABLED")
	end
end

function Module:UpdateGCDTicker()
	local start, duration = GetSpellCooldown(61304)
	if start > 0 and duration > 0 then
		if self.duration ~= duration then
			self:SetMinMaxValues(0, duration)
			self.duration = duration
		end
		self:SetValue(GetTime() - start)
		self.spark:Show()
	else
		self.spark:Hide()
	end
end

function Module:CreateGCDTicker(self)
	local ticker = CreateFrame("StatusBar", nil, self.Power)
	ticker:SetFrameLevel(self:GetFrameLevel() + 3)
	ticker:SetStatusBarTexture(K.GetTexture(C["UITextures"].NameplateTextures))
	ticker:GetStatusBarTexture():SetAlpha(0)
	ticker:SetAllPoints()

	local spark = ticker:CreateTexture(nil, "OVERLAY")
	spark:SetTexture(C["Media"].Textures.Spark16Texture)
	spark:SetSize(8, self.Power:GetHeight())
	spark:SetBlendMode("ADD")
	spark:SetPoint("CENTER", ticker:GetStatusBarTexture(), "RIGHT", 0, 0)
	ticker.spark = spark

	ticker:SetScript("OnUpdate", Module.UpdateGCDTicker)
	self.GCDTicker = ticker

	Module:ToggleGCDTicker()
end

function Module:ToggleGCDTicker()
	local plate = _G.oUF_PlayerPlate
	local ticker = plate and plate.GCDTicker
	if not ticker then
		return
	end

	ticker:SetShown(C["Nameplate"].PPGCDTicker)
end