local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Infobar")

local _G = _G
local math_floor = _G.math.floor
local string_gsub = _G.string.gsub
local table_sort = _G.table.sort

local GetInventoryItemLink = _G.GetInventoryItemLink
local GetInventoryItemDurability = _G.GetInventoryItemDurability
local GetInventoryItemTexture = _G.GetInventoryItemTexture

local DurabilityDataText
local repairCostString = string_gsub(REPAIR_COST, HEADER_COLON, ":")

local localSlots = {
	[1] = { 1, INVTYPE_HEAD, 1000 },
	[2] = { 3, INVTYPE_SHOULDER, 1000 },
	[3] = { 5, INVTYPE_CHEST, 1000 },
	[4] = { 6, INVTYPE_WAIST, 1000 },
	[5] = { 9, INVTYPE_WRIST, 1000 },
	[6] = { 10, INVTYPE_HAND, 1000 },
	[7] = { 7, INVTYPE_LEGS, 1000 },
	[8] = { 8, INVTYPE_FEET, 1000 },
	[9] = { 16, INVTYPE_WEAPONMAINHAND, 1000 },
	[10] = { 17, INVTYPE_WEAPONOFFHAND, 1000 },
	[11] = { 18, INVTYPE_RANGED, 1000 },
}

local function sortSlots(a, b)
	if a and b then
		return (a[3] == b[3] and a[1] < b[1]) or (a[3] < b[3])
	end
end

local function UpdateAllSlots()
	local numSlots = 0
	for i = 1, #localSlots do
		localSlots[i][3] = 1000
		local index = localSlots[i][1]
		if GetInventoryItemLink("player", index) then
			local current, max = GetInventoryItemDurability(index)
			if current then
				localSlots[i][3] = current / max
				numSlots = numSlots + 1
			end

			local iconTexture = GetInventoryItemTexture("player", index) or 134400
			localSlots[i][4] = "|T" .. iconTexture .. ":13:15:0:0:50:50:4:46:4:46|t " or ""
		end
	end
	table_sort(localSlots, sortSlots)

	return numSlots
end

local function getDurabilityColor(cur, max)
	local r, g, b = K.oUF:RGBColorGradient(cur, max, 1, 0, 0, 1, 1, 0, 0, 1, 0)
	return r, g, b
end

local eventList = {
	"UPDATE_INVENTORY_DURABILITY",
	"PLAYER_ENTERING_WORLD",
}

local function OnEvent(_, event)
	if event == "PLAYER_ENTERING_WORLD" then
		DurabilityDataText:UnregisterEvent(event)
	end

	local numSlots = UpdateAllSlots()

	if event == "PLAYER_REGEN_ENABLED" then
		DurabilityDataText:UnregisterEvent(event)
		DurabilityDataText:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	else
		if numSlots > 0 then
			local r, g, b = getDurabilityColor(math_floor(localSlots[1][3] * 100), 100)
			DurabilityDataText.Text:SetFormattedText("%s%%|r" .. " " .. DURABILITY, K.RGBToHex(r, g, b) .. math_floor(localSlots[1][3] * 100))
		else
			DurabilityDataText.Text:SetText(DURABILITY .. ": " .. K.MyClassColor .. NONE)
		end
	end
end

local function OnEnter()
	GameTooltip:SetOwner(DurabilityDataText, "ANCHOR_NONE")
	GameTooltip:SetPoint("BOTTOMLEFT", DurabilityDataText, "TOPRIGHT", 0, 0)
	GameTooltip:AddDoubleLine(DURABILITY, " ", 0.4, 0.6, 1, 0.4, 0.6, 1)
	GameTooltip:AddLine(" ")

	local totalCost = 0
	for i = 1, #localSlots do
		if localSlots[i][3] ~= 1000 then
			local slot = localSlots[i][1]
			local cur = math_floor(localSlots[i][3] * 100)
			local slotIcon = localSlots[i][4]
			GameTooltip:AddDoubleLine(slotIcon .. localSlots[i][2], cur .. "%", 1, 1, 1, getDurabilityColor(cur, 100))

			K.ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
			totalCost = totalCost + select(3, K.ScanTooltip:SetInventoryItem("player", slot))
		end
	end

	if totalCost > 0 then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(repairCostString, K.FormatMoney(totalCost), 0.4, 0.6, 1, 1, 1, 1)
	end

	GameTooltip:Show()
end

local function OnLeave()
	GameTooltip:Hide()
end

local function NewSetLevelFunction()
	local class = UnitClass("player")
	CharacterLevelText:SetFormattedText(K.Name .. " " .. K.Level .. " " .. K.MyClassColor .. class .. "|r")
end

function Module:CreateDurabilityDataText()
	if not C["Misc"].SlotDurability then
		return
	end

	if CharacterNameFrame then
		CharacterNameFrame:Hide()
	end

	_G.hooksecurefunc("PaperDollFrame_SetLevel", NewSetLevelFunction) -- Replace this function as we set our own style so we can set our durr stat

	DurabilityDataText = DurabilityDataText or CreateFrame("Frame", nil, UIParent)
	DurabilityDataText:SetFrameLevel(PaperDollFrame:GetFrameLevel() + 2)
	DurabilityDataText:SetParent(PaperDollFrame)

	DurabilityDataText.Text = DurabilityDataText.Text or DurabilityDataText:CreateFontString(nil, "ARTWORK")
	DurabilityDataText.Text:SetPoint("CENTER", CharacterNameFrame, 0, 2)
	DurabilityDataText.Text:SetFontObject(K.UIFont)
	DurabilityDataText.Text:SetFont(select(1, DurabilityDataText.Text:GetFont()), 11, select(3, DurabilityDataText.Text:GetFont()))

	DurabilityDataText:SetAllPoints(DurabilityDataText.Text)

	for _, event in pairs(eventList) do
		DurabilityDataText:RegisterEvent(event)
	end

	DurabilityDataText:SetScript("OnEvent", OnEvent)
	DurabilityDataText:SetScript("OnEnter", OnEnter)
	DurabilityDataText:SetScript("OnLeave", OnLeave)
end
