local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G
local next = _G.next
local pairs = _G.pairs
local select = _G.select

local GetInventoryItemLink = _G.GetInventoryItemLink
local GetItemInfo = _G.GetItemInfo
local UnitExists = _G.UnitExists
local UnitGUID = _G.UnitGUID

local inspectSlots = {
	"Head",
	"Neck",
	"Shoulder",
	"Shirt",
	"Chest",
	"Waist",
	"Legs",
	"Feet",
	"Wrist",
	"Hands",
	"Finger0",
	"Finger1",
	"Trinket0",
	"Trinket1",
	"Back",
	"MainHand",
	"SecondaryHand",
	"Ranged",
}

function Module:GetSlotAnchor(index)
	if not index then
		return
	end

	if index <= 5 or index == 9 or index == 15 then
		return "BOTTOMLEFT", 46, 20
	elseif index == 16 then
		return "BOTTOMRIGHT", -46, 2
	elseif index == 17 then
		return "BOTTOMLEFT", 46, 2
	else
		return "BOTTOMRIGHT", -46, 20
	end
end

function Module:CreateItemTexture(slot, relF, x, y)
	local icon = slot:CreateTexture(nil, "ARTWORK")
	icon:SetPoint(relF, x, y)
	icon:SetSize(14, 14)
	icon:SetTexCoord(unpack(K.TexCoords))

	icon.bg = icon.bg or CreateFrame("Frame", nil, slot)
	icon.bg:SetAllPoints(icon)
	icon.bg:SetFrameLevel(slot:GetFrameLevel())
	icon.bg:CreateBorder()
	icon.bg:Hide()

	return icon
end

function Module:CreateColorBorder()
	local frame = CreateFrame("Frame", nil, self)
	frame:SetAllPoints()

	self.colorBG = self.colorBG or CreateFrame("Frame", nil, self)
	self.colorBG:SetAllPoints(frame)
	self.colorBG:SetFrameLevel(self:GetFrameLevel())
	self.colorBG:CreateBorder()
end

function Module:CreateItemString(frame, strType)
	if frame.fontCreated then
		return
	end

	for index, slot in pairs(inspectSlots) do
		--if index ~= 4 then -- need color border for some shirts
			local slotFrame = _G[strType..slot.."Slot"]
			slotFrame.iLvlText = slotFrame.iLvlText or K.CreateFontString(slotFrame, 12, "", "OUTLINE")
			slotFrame.iLvlText:ClearAllPoints()
			slotFrame.iLvlText:SetPoint("BOTTOMLEFT", slotFrame, 1, 1)

			local relF, x, y = Module:GetSlotAnchor(index)
			for i = 1, 5 do
				local offset = (i - 1) * 20 + 2
				local iconX = x > 0 and x + offset or x - offset
				local iconY = index > 15 and 20 or 4
				slotFrame["textureIcon"..i] = Module:CreateItemTexture(slotFrame, relF, iconX, iconY)
			end
			Module.CreateColorBorder(slotFrame)
		-- end
	end

	frame.fontCreated = true
end

function Module:ItemBorderSetColor(slotFrame, r, g, b)
	if slotFrame.colorBG then
		slotFrame.colorBG.KKUI_Border:SetVertexColor(r, g, b)
	end
end

local pending = {}
local gemSlotBlackList = {
	[16] = true,
	[17] = true,
	[18] = true, -- ignore weapons, until I find a better way
}

function Module:ItemLevel_UpdateGemInfo(link, unit, index, slotFrame)
	if C["Misc"].GemEnchantInfo and not gemSlotBlackList[index] then
		local info = K.GetItemLevel(link, unit, index, true)
		if info then
			local gemStep = 1
			for i = 1, 5 do
				local texture = slotFrame["textureIcon"..i]
				local bg = texture.bg
				local gem = info.gems and info.gems[gemStep]
				if gem then
					texture:SetTexture(gem)
					bg:Show()

					gemStep = gemStep + 1
				end
			end
		end
	end
end

function Module:RefreshButtonInfo()
	local unit = InspectFrame and InspectFrame.unit
	if unit then
		for index, slotFrame in pairs(pending) do
			local link = GetInventoryItemLink(unit, index)
			if link then
				local quality, level = select(3, GetItemInfo(link))
				if quality then
					local color = K.QualityColors[quality]
					Module:ItemBorderSetColor(slotFrame, color.r, color.g, color.b)
					if C["Misc"].ItemLevel and level and level > 1 and quality > 1 then
						slotFrame.iLvlText:SetText(level)
						slotFrame.iLvlText:SetTextColor(color.r, color.g, color.b)
					end
					Module:ItemLevel_UpdateGemInfo(link, unit, index, slotFrame)
					Module:UpdateInspectILvl()

					pending[index] = nil
				end
			end
		end

		if not next(pending) then
			self:Hide()
			return
		end
	else
		wipe(pending)
		self:Hide()
	end
end

function Module:ItemLevel_SetupLevel(frame, strType, unit)
	if not UnitExists(unit) then
		return
	end

	Module:CreateItemString(frame, strType)
	for index, slot in pairs(inspectSlots) do
		-- if index ~= 4 then
			local slotFrame = _G[strType..slot.."Slot"]
			slotFrame.iLvlText:SetText("")
			for i = 1, 5 do
				local texture = slotFrame["textureIcon"..i]
				texture:SetTexture(nil)
				texture.bg:Hide()
			end
			Module:ItemBorderSetColor(slotFrame, 1, 1, 1)

			local itemTexture = GetInventoryItemTexture(unit, index)
			if itemTexture then
				local link = GetInventoryItemLink(unit, index)
				if link then
					local quality, level = select(3, GetItemInfo(link))
					if quality then
						local color = K.QualityColors[quality]
						Module:ItemBorderSetColor(slotFrame, color.r, color.g, color.b)
						if C["Misc"].ItemLevel and level and level > 1 and quality > 1 then
							slotFrame.iLvlText:SetText(level)
							slotFrame.iLvlText:SetTextColor(color.r, color.g, color.b)
						end

						Module:ItemLevel_UpdateGemInfo(link, unit, index, slotFrame)
					else
						pending[index] = slotFrame
						Module.QualityUpdater:Show()
					end
				else
					pending[index] = slotFrame
					Module.QualityUpdater:Show()
				end
			end
		-- end
	end
end

function Module:ItemLevel_UpdatePlayer()
	Module:ItemLevel_SetupLevel(CharacterFrame, "Character", "player")
end

function Module:UpdateInspectILvl()
	if not Module.InspectILvl then
		return
	end

	Module:UpdateUnitILvl(InspectFrame.unit, Module.InspectILvl)
	Module.InspectILvl:SetFormattedText(ITEM_LEVEL_ABBR.." %s", Module.InspectILvl:GetText())
end

local isHidden
local function HideInspectRotate()
	if isHidden then
		return
	end
	InspectModelFrameRotateRightButton:Hide()
	InspectModelFrameRotateLeftButton:Hide()

	Module.InspectILvl = Module.InspectILvl or K.CreateFontString(InspectPaperDollFrame, 14)
	Module.InspectILvl:ClearAllPoints()
	Module.InspectILvl:SetPoint("TOP", InspectLevelText, "BOTTOM", 0, -6)

	Module.InspectILvl.Background = Module.InspectILvl.Background or InspectPaperDollFrame:CreateTexture(nil, "OVERLAY", 7)
	Module.InspectILvl.Background:SetAtlas("UI-Character-Info-Line-Bounce", true)
	Module.InspectILvl.Background:SetVertexColor(0.3, 0.3, 0.3)
	Module.InspectILvl.Background:SetAlpha(0.7)
	Module.InspectILvl.Background:SetPoint("CENTER", Module.InspectILvl)

	isHidden = true
end

function Module:ItemLevel_UpdateInspect(...)
	local guid = ...
	if InspectFrame and InspectFrame.unit and UnitGUID(InspectFrame.unit) == guid then
		HideInspectRotate()
		Module:ItemLevel_SetupLevel(InspectFrame, "Inspect", InspectFrame.unit)
		Module:UpdateInspectILvl()
	end
end

function Module:CreateSlotItemLevel()
	if not C["Misc"].ItemLevel then
		return
	end

	-- iLvl on CharacterFrame
	CharacterFrame:HookScript("OnShow", Module.ItemLevel_UpdatePlayer)
	K:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", Module.ItemLevel_UpdatePlayer)
	CharacterModelFrameRotateRightButton:Hide()
	CharacterModelFrameRotateLeftButton:Hide()

	-- iLvl on InspectFrame
	K:RegisterEvent("INSPECT_READY", Module.ItemLevel_UpdateInspect)

	-- Update item quality
	Module.QualityUpdater = CreateFrame("Frame")
	Module.QualityUpdater:Hide()
	Module.QualityUpdater:SetScript("OnUpdate", Module.RefreshButtonInfo)
end