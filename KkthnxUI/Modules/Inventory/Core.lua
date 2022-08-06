local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Bags")

local Unfit = K.Unfit
local cargBags = K.cargBags

local _G = _G
local ceil = _G.ceil
local ipairs = _G.ipairs
local string_match = _G.string.match
local table_wipe = _G.table.wipe
local unpack = _G.unpack

local C_NewItems_IsNewItem = _G.C_NewItems.IsNewItem
local C_NewItems_RemoveNewItem = _G.C_NewItems.RemoveNewItem
local ClearCursor = _G.ClearCursor
local CreateFrame = _G.CreateFrame
local DeleteCursorItem = _G.DeleteCursorItem
local GetContainerItemID = _G.GetContainerItemID
local GetContainerItemInfo = _G.GetContainerItemInfo
local GetContainerNumSlots = _G.GetContainerNumSlots
local GetInventoryItemID = _G.GetInventoryItemID
local GetItemInfo = _G.GetItemInfo
local InCombatLockdown = _G.InCombatLockdown
local IsAltKeyDown = _G.IsAltKeyDown
local IsControlKeyDown = _G.IsControlKeyDown
local LE_ITEM_CLASS_ARMOR = _G.LE_ITEM_CLASS_ARMOR
local LE_ITEM_CLASS_WEAPON = _G.LE_ITEM_CLASS_WEAPON
local LE_ITEM_QUALITY_POOR = _G.LE_ITEM_QUALITY_POOR
local PickupContainerItem = _G.PickupContainerItem
local PlaySound = _G.PlaySound
local SOUNDKIT = _G.SOUNDKIT
local SortBags = _G.SortBags
local SortBankBags = _G.SortBankBags

local bagsFont = K.GetFont(C["UIFonts"].InventoryFonts)
local toggleButtons = {}
local deleteEnable, favouriteEnable, splitEnable, customJunkEnable
local sortCache = {}

_G.StaticPopupDialogs["KKUI_WIPE_JUNK_LIST"] = {
	text = "Are you sure to wipe the custom junk list?",
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		table_wipe(KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList)
	end,
	whileDead = 1,
}

function Module:ReverseSort()
	for bag = 0, 4 do
		local numSlots = GetContainerNumSlots(bag)
		for slot = 1, numSlots do
			local texture, _, locked = GetContainerItemInfo(bag, slot)
			if (slot <= numSlots / 2) and texture and not locked and not sortCache["b"..bag.."s"..slot] then
				PickupContainerItem(bag, slot)
				PickupContainerItem(bag, numSlots+1 - slot)
				sortCache["b"..bag.."s"..slot] = true
			end
		end
	end

	Module.Bags.isSorting = false
	Module:UpdateAllBags()
end

function Module:UpdateAnchors(parent, bags)
	if not parent:IsShown() then
		return
	end

	local anchor = parent
	for _, bag in ipairs(bags) do
		if bag:GetHeight() > 45 then
			bag:Show()
		else
			bag:Hide()
		end

		if bag:IsShown() then
			bag:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, 6)
			anchor = bag
		end
	end
end

local function highlightFunction(button, match)
	button:SetAlpha(match and 1 or 0.25)
end

function Module:CreateInfoFrame()
	local infoFrame = CreateFrame("Button", nil, self)
	infoFrame:SetPoint("TOPLEFT", 10, 0)
	infoFrame:SetSize(160, 32)

	local icon = CreateFrame("Button", nil, infoFrame)
	icon:SetSize(18, 18)
	icon:SetPoint("LEFT")
	icon:EnableMouse(false)

	icon.Icon = icon:CreateTexture(nil, "ARTWORK")
	icon.Icon:SetAllPoints()
	icon.Icon:SetTexCoord(unpack(K.TexCoords))
	icon.Icon:SetTexture("Interface\\Minimap\\Tracking\\None")

	local search = self:SpawnPlugin("SearchBar", infoFrame)
	search.highlightFunction = highlightFunction
	search.isGlobal = true
	search:SetPoint("LEFT", 0, 5)
	search:DisableDrawLayer("BACKGROUND")
	search:CreateBackdrop()
	search.Backdrop:SetPoint("TOPLEFT", -5, -7)
	search.Backdrop:SetPoint("BOTTOMRIGHT", 5, 7)

	local moneyTag = self:SpawnPlugin("TagDisplay", "[money]", infoFrame)
	moneyTag:SetFontObject(bagsFont)
	moneyTag:SetFont(select(1, moneyTag:GetFont()), 13, select(3, moneyTag:GetFont()))
	moneyTag:SetPoint("LEFT", icon, "RIGHT", 5, 0)

	local moneyTagFrame = CreateFrame("Frame", nil, UIParent)
	moneyTagFrame:SetParent(infoFrame)
	moneyTagFrame:SetAllPoints(moneyTag)
	moneyTagFrame:SetScript("OnEnter", K.GoldButton_OnEnter)
	moneyTagFrame:SetScript("OnLeave", K.GoldButton_OnLeave)
end

function Module:CreateBagBar(settings, columns)
	local bagBar = self:SpawnPlugin("BagBar", settings.Bags)
	local width, height = bagBar:LayoutButtons("grid", columns, 6, 5, -5)
	bagBar:SetSize(width + 10, height + 10)
	bagBar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -6)
	bagBar:CreateBorder()
	bagBar.highlightFunction = highlightFunction
	bagBar.isGlobal = true
	bagBar:Hide()

	self.BagBar = bagBar
end

function Module:CreateCloseButton()
	local closeButton = CreateFrame("Button", nil, self)
	closeButton:SetSize(18, 18)
	closeButton:CreateBorder()
	closeButton:StyleButton()

	closeButton.Icon = closeButton:CreateTexture(nil, "ARTWORK")
	closeButton.Icon:SetAllPoints()
	closeButton.Icon:SetTexCoord(unpack(K.TexCoords))
	closeButton.Icon:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\CloseButton_32")

	closeButton:SetScript("OnClick", _G.CloseAllBags)
	closeButton.title = _G.CLOSE
	K.AddTooltip(closeButton, "ANCHOR_TOP")

	return closeButton
end

function Module:CreateRestoreButton(f)
	local restoreButton = CreateFrame("Button", nil, self)
	restoreButton:SetSize(18, 18)
	restoreButton:CreateBorder()
	restoreButton:StyleButton()

	restoreButton.Icon = restoreButton:CreateTexture(nil, "ARTWORK")
	restoreButton.Icon:SetAllPoints()
	restoreButton.Icon:SetTexCoord(unpack(K.TexCoords))
	restoreButton.Icon:SetAtlas("transmog-icon-revert")

	restoreButton:SetScript("OnClick", function()
		KkthnxUIDB.Variables[K.Realm][K.Name]["TempAnchor"][f.main:GetName()] = nil
		KkthnxUIDB.Variables[K.Realm][K.Name]["TempAnchor"][f.bank:GetName()] = nil
		f.main:ClearAllPoints()
		f.main:SetPoint("BOTTOMRIGHT", -86, 76)
		f.bank:ClearAllPoints()
		f.bank:SetPoint("BOTTOMRIGHT", f.main, "BOTTOMLEFT", -12, 0)
		PlaySound(SOUNDKIT.IG_MINIMAP_OPEN)
	end)
	restoreButton.title = _G.RESET
	K.AddTooltip(restoreButton, "ANCHOR_TOP")

	return restoreButton
end

function Module:CreateBankButton(f)
	local BankButton = CreateFrame("Button", nil, self)
	BankButton:SetSize(18, 18)
	BankButton:CreateBorder()
	BankButton:StyleButton()

	BankButton.Icon = BankButton:CreateTexture(nil, "ARTWORK")
	BankButton.Icon:SetAllPoints()
	BankButton.Icon:SetTexCoord(unpack(K.TexCoords))
	BankButton.Icon:SetAtlas("Banker")

	BankButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
		_G.BankFrame.selectedTab = 1
		f.bank:Show()
	end)

	BankButton.title = _G.BANK
	K.AddTooltip(BankButton, "ANCHOR_TOP")

	return BankButton
end

function Module:CreateBagToggle()
	local bagToggleButton = CreateFrame("Button", nil, self)
	bagToggleButton:SetSize(18, 18)
	bagToggleButton:CreateBorder()
	bagToggleButton:StyleButton()

	bagToggleButton.Icon = bagToggleButton:CreateTexture(nil, "ARTWORK")
	bagToggleButton.Icon:SetAllPoints()
	bagToggleButton.Icon:SetTexCoord(unpack(K.TexCoords))
	bagToggleButton.Icon:SetTexture("Interface\\Buttons\\Button-Backpack-Up")

	bagToggleButton:SetScript("OnClick", function()
		K.TogglePanel(self.BagBar)
		if self.BagBar:IsShown() then
			bagToggleButton.KKUI_Border:SetVertexColor(1, 0, 0)
			bagToggleButton.Icon:SetDesaturated(true)
			PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
			if self.keyring and self.keyring:IsShown() then
				self.keyToggle:Click()
			end
		else
			if C["General"].ColorTextures then
				bagToggleButton.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
			else
				bagToggleButton.KKUI_Border:SetVertexColor(1, 1, 1)
			end
			bagToggleButton.Icon:SetDesaturated(false)
			PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
		end
	end)
	bagToggleButton.title = _G.BACKPACK_TOOLTIP
	K.AddTooltip(bagToggleButton, "ANCHOR_TOP")

	self.bagToggle = bagToggleButton

	return bagToggleButton
end

function Module:CreateKeyToggle()
	local keyButton = CreateFrame("Button", nil, self)
	keyButton:SetSize(18, 18)
	keyButton:CreateBorder()
	keyButton:StyleButton()

	keyButton.Icon = keyButton:CreateTexture(nil, "ARTWORK")
	keyButton.Icon:SetAllPoints()
	keyButton.Icon:SetTexCoord(unpack(K.TexCoords))
	keyButton.Icon:SetTexture("Interface\\ICONS\\INV_Misc_Key_12")

	keyButton:SetScript("OnClick", function()
		ToggleFrame(self.keyring)
		if self.keyring:IsShown() then
			keyButton.KKUI_Border:SetVertexColor(1, 0, 0)
			keyButton.Icon:SetDesaturated(true)
			PlaySound(SOUNDKIT.KEY_RING_OPEN)
			if self.BagBar and self.BagBar:IsShown() then
				self.bagToggle:Click()
			end
		else
			if C["General"].ColorTextures then
				keyButton.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
			else
				keyButton.KKUI_Border:SetVertexColor(1, 1, 1)
			end
			keyButton.Icon:SetDesaturated(false)
			PlaySound(SOUNDKIT.KEY_RING_CLOSE)
		end
	end)
	keyButton.title = KEYRING
	K.AddTooltip(keyButton, "ANCHOR_TOP")

	self.keyToggle = keyButton

	return keyButton
end

function Module:CreateSortButton(name)
	local sortButton = CreateFrame("Button", nil, self)
	sortButton:SetSize(18, 18)
	sortButton:CreateBorder()
	sortButton:StyleButton()

	sortButton.Icon = sortButton:CreateTexture(nil, "ARTWORK")
	sortButton.Icon:SetAllPoints()
	sortButton.Icon:SetTexCoord(unpack(K.TexCoords))
	sortButton.Icon:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Inventory\\SortIcon")

	sortButton:SetScript("OnClick", function()
		if C["Inventory"].BagSortMode.Value == 3 then
			UIErrorsFrame:AddMessage(K.InfoColor.."BagSort has been disabled in GUI.")
			return
		end

		if InCombatLockdown() then
			UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_IN_COMBAT)
			return
		end

		if name == "Bank" then
			SortBankBags()
		else
			SortBags()
		end
	end)
	sortButton.title = "Sort"
	K.AddTooltip(sortButton, "ANCHOR_TOP")

	return sortButton
end

function Module:GetContainerEmptySlot(bagID)
	for slotID = 1, GetContainerNumSlots(bagID) do
		if not GetContainerItemID(bagID, slotID) then
			return slotID
		end
	end
end

function Module:GetEmptySlot(name)
	if name == "Bag" then
		for bagID = 0, NUM_BAG_SLOTS do
			local slotID = Module:GetContainerEmptySlot(bagID)
			if slotID then
				return bagID, slotID
			end
		end
	elseif name == "Bank" then
		local slotID = Module:GetContainerEmptySlot(-1)
		if slotID then
			return -1, slotID
		end

		for bagID = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
			local slotID = Module:GetContainerEmptySlot(bagID)
			if slotID then
				return bagID, slotID
			end
		end
	end
end

function Module:FreeSlotOnDrop()
	local bagID, slotID = Module:GetEmptySlot(self.__name)
	if slotID then
		PickupContainerItem(bagID, slotID)
	end
end

local freeSlotContainer = {
	["Bag"] = true,
	["Bank"] = true,
}

function Module:CreateFreeSlots()
	local name = self.name
	if not freeSlotContainer[name] then
		return
	end

	local slot = CreateFrame("Button", name.."FreeSlot", self)
	slot:SetSize(self.iconSize, self.iconSize)
	slot:CreateBorder()
	slot:StyleButton()
	slot:SetScript("OnMouseUp", Module.FreeSlotOnDrop)
	slot:SetScript("OnReceiveDrag", Module.FreeSlotOnDrop)
	K.AddTooltip(slot, "ANCHOR_RIGHT", "FreeSlots")
	slot.__name = name

	local tag = self:SpawnPlugin("TagDisplay", "[space]", slot)
	tag:SetFontObject(bagsFont)
	tag:SetFont(select(1, tag:GetFont()), 16, select(3, tag:GetFont()))
	tag:SetPoint("CENTER", 1, 0)
	tag.__name = name

	self.freeSlot = slot
end

function Module:SelectToggleButton(id)
	for index, button in pairs(toggleButtons) do
		if index ~= id then
			button.__turnOff()
		end
	end
end

local function saveSplitCount(self)
	local count = self:GetText() or ""
	KkthnxUIDB.Variables[K.Realm][K.Name].SplitCount = tonumber(count) or 1
end

local function editBoxClearFocus(self)
	self:ClearFocus()
end

function Module:CreateSplitButton()
	local enabledText = K.SystemColor..L["StackSplitEnable"]

	local splitFrame = CreateFrame("Frame", nil, self)
	splitFrame:SetSize(100, 50)
	splitFrame:SetPoint("TOPRIGHT", self, "TOPLEFT", -6, 0)
	K.CreateFontString(splitFrame, 14, L["Split Count"], "", "system", "TOP", 1, -5)
	splitFrame:CreateBorder()
	splitFrame:Hide()

	local editBox = CreateFrame("EditBox", nil, splitFrame)
	editBox:CreateBorder()
	editBox:SetWidth(90)
	editBox:SetHeight(20)
	editBox:SetAutoFocus(false)
	editBox:SetTextInsets(5, 5, 0, 0)
	editBox:SetFontObject(bagsFont)
	editBox:SetPoint("BOTTOMLEFT", 5, 5)
	editBox:SetScript("OnEscapePressed", editBoxClearFocus)
	editBox:SetScript("OnEnterPressed", editBoxClearFocus)
	editBox:SetScript("OnTextChanged", saveSplitCount)

	local splitButton = CreateFrame("Button", nil, self)
	splitButton:SetSize(18, 18)
	splitButton:CreateBorder()
	splitButton:StyleButton()

	splitButton.Icon = splitButton:CreateTexture(nil, "ARTWORK")
	splitButton.Icon:SetPoint("TOPLEFT", -1, 3)
	splitButton.Icon:SetPoint("BOTTOMRIGHT", 1, -3)
	splitButton.Icon:SetTexCoord(unpack(K.TexCoords))
	splitButton.Icon:SetTexture("Interface\\HELPFRAME\\ReportLagIcon-AuctionHouse")

	splitButton.__turnOff = function()
		if C["General"].ColorTextures then
			splitButton.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
		else
			splitButton.KKUI_Border:SetVertexColor(1, 1, 1)
		end
		splitButton.Icon:SetDesaturated(false)
		splitButton.text = nil
		splitFrame:Hide()
		splitEnable = nil
	end

	splitButton:SetScript("OnClick", function(self)
		Module:SelectToggleButton(1)
		splitEnable = not splitEnable
		if splitEnable then
			self.KKUI_Border:SetVertexColor(1, 0, 0)
			self.Icon:SetDesaturated(true)
			self.text = enabledText
			splitFrame:Show()
			editBox:SetText(KkthnxUIDB.Variables[K.Realm][K.Name].SplitCount)
		else
			self.__turnOff()
		end
		self:GetScript("OnEnter")(self)
	end)
	splitButton:SetScript("OnHide", splitButton.__turnOff)
	splitButton.title = L["Quick Split"]
	K.AddTooltip(splitButton, "ANCHOR_TOP")

	toggleButtons[1] = splitButton

	return splitButton
end

local function splitOnClick(self)
	if not splitEnable then
		return
	end

	PickupContainerItem(self.bagID, self.slotID)

	local texture, itemCount, locked = GetContainerItemInfo(self.bagID, self.slotID)
	if texture and not locked and itemCount and itemCount > KkthnxUIDB.Variables[K.Realm][K.Name].SplitCount then
		SplitContainerItem(self.bagID, self.slotID, KkthnxUIDB.Variables[K.Realm][K.Name].SplitCount)

		local bagID, slotID = Module:GetEmptySlot("Bag")
		if slotID then
			PickupContainerItem(bagID, slotID)
		end
	end
end

function Module:CreateFavouriteButton()
	local enabledText = K.SystemColor..L["Favourite Mode Enabled"]

	local favouriteButton = CreateFrame("Button", nil, self)
	favouriteButton:SetSize(18, 18)
	favouriteButton:CreateBorder()
	favouriteButton:StyleButton()

	favouriteButton.Icon = favouriteButton:CreateTexture(nil, "ARTWORK")
	favouriteButton.Icon:SetPoint("TOPLEFT", -3, -1)
	favouriteButton.Icon:SetPoint("BOTTOMRIGHT", 3, -4)
	favouriteButton.Icon:SetTexCoord(unpack(K.TexCoords))
	favouriteButton.Icon:SetTexture("Interface\\Common\\friendship-heart")

	favouriteButton.__turnOff = function()
		if C["General"].ColorTextures then
			favouriteButton.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
		else
			favouriteButton.KKUI_Border:SetVertexColor(1, 1, 1)
		end
		favouriteButton.Icon:SetDesaturated(false)
		favouriteButton.text = nil
		favouriteEnable = nil
	end

	favouriteButton:SetScript("OnClick", function(self)
		Module:SelectToggleButton(2)
		favouriteEnable = not favouriteEnable
		if favouriteEnable then
			self.KKUI_Border:SetVertexColor(1, 0, 0)
			self.Icon:SetDesaturated(true)
			self.text = enabledText
		else
			self.__turnOff()
		end
		self:GetScript("OnEnter")(self)
	end)
	favouriteButton:SetScript("OnHide", favouriteButton.__turnOff)
	favouriteButton.title = L["Favourite Mode"]
	K.AddTooltip(favouriteButton, "ANCHOR_TOP")

	toggleButtons[2] = favouriteButton

	return favouriteButton
end

local function favouriteOnClick(self)
	if not favouriteEnable then
		return
	end

	local texture, _, _, quality, _, _, _, _, _, itemID = GetContainerItemInfo(self.bagID, self.slotID)
	if texture and quality > LE_ITEM_QUALITY_POOR then
		if KkthnxUIDB.Variables[K.Realm][K.Name].FavouriteItems[itemID] then
			KkthnxUIDB.Variables[K.Realm][K.Name].FavouriteItems[itemID] = nil
		else
			KkthnxUIDB.Variables[K.Realm][K.Name].FavouriteItems[itemID] = true
		end
		ClearCursor()
		Module:UpdateAllBags()
	end
end

function Module:CreateJunkButton()
	local enabledText = K.InfoColor.."|nClick an item to tag it as junk.|n|nIf 'Module Autosell' is enabled, these items will be sold as well.|n|nThe list is saved account-wide."

	local JunkButton = CreateFrame("Button", nil, self)
	JunkButton:SetSize(18, 18)
	JunkButton:CreateBorder()
	JunkButton:StyleButton()

	JunkButton.Icon = JunkButton:CreateTexture(nil, "ARTWORK")
	JunkButton.Icon:SetPoint("TOPLEFT", 1, -2)
	JunkButton.Icon:SetPoint("BOTTOMRIGHT", -1, -2)
	JunkButton.Icon:SetTexCoord(unpack(K.TexCoords))
	JunkButton.Icon:SetTexture("Interface\\BUTTONS\\UI-GroupLoot-Coin-Up")

	JunkButton.__turnOff = function()
		if C["General"].ColorTextures then
			JunkButton.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
		else
			JunkButton.KKUI_Border:SetVertexColor(1, 1, 1)
		end
		JunkButton.Icon:SetDesaturated(false)
		JunkButton.text = nil
		customJunkEnable = nil
	end

	JunkButton:SetScript("OnClick", function(self)
		if IsAltKeyDown() and IsControlKeyDown() then
			StaticPopup_Show("KKUI_WIPE_JUNK_LIST")
			return
		end

		Module:SelectToggleButton(3)
		customJunkEnable = not customJunkEnable
		if customJunkEnable then
			self.KKUI_Border:SetVertexColor(1, 0, 0)
			self.Icon:SetDesaturated(true)
			self.text = enabledText
		else
			JunkButton.__turnOff()
		end
		Module:UpdateAllBags()
		self:GetScript("OnEnter")(self)
	end)
	JunkButton:SetScript("OnHide", JunkButton.__turnOff)
	JunkButton.title = "Custom Junk List"
	K.AddTooltip(JunkButton, "ANCHOR_TOP")

	toggleButtons[3] = JunkButton

	return JunkButton
end

local function customJunkOnClick(self)
	if not customJunkEnable then
		return
	end

	local texture, _, _, _, _, _, _, _, _, itemID = GetContainerItemInfo(self.bagID, self.slotID)
	local price = select(11, GetItemInfo(itemID))
	if texture and price > 0 then
		if KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList[itemID] then
			KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList[itemID] = nil
		else
			KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList[itemID] = true
		end
		ClearCursor()
		Module:UpdateAllBags()
	end
end

function Module:CreateDeleteButton()
	local enabledText = K.SystemColor..L["Delete Mode Enabled"]

	local deleteButton = CreateFrame("Button", nil, self)
	deleteButton:SetSize(18, 18)
	deleteButton:CreateBorder()
	deleteButton:StyleButton()

	deleteButton.Icon = deleteButton:CreateTexture(nil, "ARTWORK")
	deleteButton.Icon:SetPoint("TOPLEFT", 3, -2)
	deleteButton.Icon:SetPoint("BOTTOMRIGHT", -1, 2)
	deleteButton.Icon:SetTexCoord(unpack(K.TexCoords))
	deleteButton.Icon:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")

	deleteButton.__turnOff = function()
		if C["General"].ColorTextures then
			deleteButton.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
		else
			deleteButton.KKUI_Border:SetVertexColor(1, 1, 1)
		end
		deleteButton.Icon:SetDesaturated(false)
		deleteButton.text = nil
		deleteEnable = nil
	end

	deleteButton:SetScript("OnClick", function(self)
		Module:SelectToggleButton(4)
		deleteEnable = not deleteEnable
		if deleteEnable then
			self.KKUI_Border:SetVertexColor(1, 0, 0)
			self.Icon:SetDesaturated(true)
			self.text = enabledText
		else
			deleteButton.__turnOff()
		end
		self:GetScript("OnEnter")(self)
	end)
	deleteButton:SetScript("OnHide", deleteButton.__turnOff)
	deleteButton.title = L["Item Delete Mode"]
	K.AddTooltip(deleteButton, "ANCHOR_TOP")

	toggleButtons[4] = deleteButton

	return deleteButton
end

local function deleteButtonOnClick(self)
	if not deleteEnable then
		return
	end

	local texture, _, _, quality = GetContainerItemInfo(self.bagID, self.slotID)
	if IsControlKeyDown() and IsAltKeyDown() and texture and (quality < LE_ITEM_QUALITY_RARE) then
		PickupContainerItem(self.bagID, self.slotID)
		DeleteCursorItem()
	end
end

function Module:ButtonOnClick(btn)
	if btn ~= "LeftButton" then
		return
	end

	splitOnClick(self)
	favouriteOnClick(self)
	customJunkOnClick(self)
	deleteButtonOnClick(self)
end

function Module:UpdateAllBags()
	if self.Bags and self.Bags:IsShown() then
		self.Bags:BAG_UPDATE()
	end
end

function Module:OpenBags()
	OpenAllBags(true)
end

function Module:CloseBags()
	CloseAllBags()
end

function Module:OnEnable()
	self:CreateInventoryBar()
	self:CreateAutoRepair()
	self:CreateAutoSell()
	self:CreateAutoDelete()

	if not C["Inventory"].Enable then
		return
	end

	if IsAddOnLoaded("AdiBags") or IsAddOnLoaded("ArkInventory") or IsAddOnLoaded("cargBags_Nivaya") or IsAddOnLoaded("cargBags") or IsAddOnLoaded("Bagnon") or IsAddOnLoaded("Combuctor") or IsAddOnLoaded("TBag") or IsAddOnLoaded("BaudBag") then
		return
	end

	-- Settings
	local bagsScale = C["Inventory"].BagsScale
	local bagsWidth = C["Inventory"].BagsWidth
	local bankWidth = C["Inventory"].BankWidth
	local iconSize = C["Inventory"].IconSize
	local showItemLevel = C["Inventory"].BagsItemLevel
	local deleteButton = C["Inventory"].DeleteButton
	local showNewItem = C["Inventory"].ShowNewItem
	local hasPawn = IsAddOnLoaded("Pawn")

	-- Init
	local Backpack = cargBags:NewImplementation("KKUI_Backpack")
	Backpack:RegisterBlizzard()
	Backpack:SetScale(bagsScale)

	Backpack:HookScript("OnShow", function()
		PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
	end)

	Backpack:HookScript("OnHide", function()
		PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
	end)

	Module.Bags = Backpack
	Module.BagsType = {}
	Module.BagsType[0] = 0	-- backpack
	Module.BagsType[-1] = 0	-- bank

	local f = {}
	local filters = Module:GetFilters()
	local MyContainer = Backpack:GetContainerClass()
	local ContainerGroups = {["Bag"] = {}, ["Bank"] = {}}

	local function AddNewContainer(bagType, index, name, filter)
		local width = bagsWidth
		if bagType == "Bank" then
			width = bankWidth
		end

		local newContainer = MyContainer:New(name, {Columns = width, BagType = bagType})
		newContainer:SetFilter(filter, true)
		ContainerGroups[bagType][index] = newContainer
	end

	function Backpack:OnInit()
		AddNewContainer("Bag", 8, "Junk", filters.bagsJunk)
		AddNewContainer("Bag", 4, "BagFavourite", filters.bagFavourite)
		AddNewContainer("Bag", 1, "AmmoItem", filters.bagAmmo)
		AddNewContainer("Bag", 2, "BagMount", filters.bagMount)
		AddNewContainer("Bag", 3, "Equipment", filters.bagEquipment)
		AddNewContainer("Bag", 6, "Consumable", filters.bagConsumable)
		AddNewContainer("Bag", 5, "BagGoods", filters.bagGoods)
		AddNewContainer("Bag", 7, "BagQuest", filters.bagQuest)

		f.main = MyContainer:New("Bag", {Columns = bagsWidth, Bags = "bags"})
		f.main:SetPoint("BOTTOMRIGHT", -86, 76)
		f.main:SetFilter(filters.onlyBags, true)

		f.main.keyring = MyContainer:New("Keyring", {Columns = bagsWidth, Parent = f.main})
		f.main.keyring:SetFilter(filters.onlyKeyring, true)
		f.main.keyring:SetPoint("BOTTOMRIGHT", f.main, "BOTTOMLEFT", -6, 0)
		f.main.keyring:Hide()

		AddNewContainer("Bank", 4, "BankFavourite", filters.bankFavourite)
		AddNewContainer("Bank", 1, "bankAmmoItem", filters.bankAmmo)
		AddNewContainer("Bank", 3, "BankLegendary", filters.bankLegendary)
		AddNewContainer("Bank", 2, "BankEquipment", filters.bankEquipment)
		AddNewContainer("Bank", 6, "BankConsumable", filters.bankConsumable)
		AddNewContainer("Bank", 5, "BankGoods", filters.bankGoods)
		AddNewContainer("Bank", 7, "BankQuest", filters.bankQuest)

		f.bank = MyContainer:New("Bank", {Columns = bankWidth, Bags = "bank"})
		f.bank:SetPoint("BOTTOMRIGHT", f.main, "BOTTOMLEFT", -12, 0)
		f.bank:SetFilter(filters.onlyBank, true)
		f.bank:Hide()

		for bagType, groups in pairs(ContainerGroups) do
			for _, container in ipairs(groups) do
				local parent = Backpack.contByName[bagType]
				container:SetParent(parent)
				K.CreateMoverFrame(container, parent, true)
			end
		end
	end

	local initBagType
	function Backpack:OnBankOpened()
		self:GetContainer("Bank"):Show()

		if not initBagType then
			Module:UpdateAllBags() -- Initialize bagType
			initBagType = true
		end
	end

	function Backpack:OnBankClosed()
		self:GetContainer("Bank"):Hide()
	end

	local MyButton = Backpack:GetItemButtonClass()
	MyButton:Scaffold("Default")

	function MyButton:OnCreate()
		self:SetNormalTexture(nil)
		self:SetPushedTexture(nil)
		self:SetSize(iconSize, iconSize)

		self.Icon:SetAllPoints()
		self.Icon:SetTexCoord(unpack(K.TexCoords))

		self.Count:SetPoint("BOTTOMRIGHT", 1, 1)
		self.Count:SetFontObject(bagsFont)

		self.Cooldown:SetPoint("TOPLEFT", 1, -1)
		self.Cooldown:SetPoint("BOTTOMRIGHT", -1, 1)

		self.IconOverlay:SetPoint("TOPLEFT", 1, -1)
		self.IconOverlay:SetPoint("BOTTOMRIGHT", -1, 1)

		self:CreateBorder()
		self:StyleButton()

		local parentFrame = CreateFrame("Frame", nil, self)
		parentFrame:SetAllPoints()
		parentFrame:SetFrameLevel(5)

		self.Favourite = parentFrame:CreateTexture(nil, "OVERLAY")
		self.Favourite:SetAtlas("collections-icon-favorites")
		self.Favourite:SetSize(24, 24)
		self.Favourite:SetPoint("TOPRIGHT", 3, 2)

		self.Quest = self:CreateTexture(nil, "OVERLAY")
		self.Quest:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Inventory\\QuestIcon.tga")
		self.Quest:SetSize(26, 26)
		self.Quest:SetPoint("LEFT", 0, 1)

		self.iLvl = K.CreateFontString(self, 12, "", "OUTLINE", false, "BOTTOMLEFT", 1, 1)
		self.iLvl:SetFontObject(bagsFont)
		self.iLvl:SetFont(select(1, self.iLvl:GetFont()), 12, select(3, self.iLvl:GetFont()))

		if showNewItem then
			self.glowFrame = self.glowFrame or CreateFrame("Frame", nil, self, "BackdropTemplate")
			self.glowFrame:SetBackdrop({edgeFile = C["Media"].Borders.GlowBorder, edgeSize = 16})
			self.glowFrame:SetPoint("TOPLEFT", self, -5, 5)
			self.glowFrame:SetPoint("BOTTOMRIGHT", self, 5, -5)
			self.glowFrame:Hide()

			self.glowFrame.Animation = self.glowFrame.Animation or self.glowFrame:CreateAnimationGroup()
			self.glowFrame.Animation:SetLooping("BOUNCE")
			self.glowFrame.Animation.Fader = self.glowFrame.Animation:CreateAnimation("Alpha")
			self.glowFrame.Animation.Fader:SetFromAlpha(1)
			self.glowFrame.Animation.Fader:SetToAlpha(0.1)
			self.glowFrame.Animation.Fader:SetDuration(0.6)
			self.glowFrame.Animation.Fader:SetSmoothing("OUT")
		end

		self:HookScript("OnClick", Module.ButtonOnClick)
	end

	function MyButton:ItemOnEnter()
		if self.glowFrame then
			if self.glowFrame:IsShown() or self.glowFrame.Animation:IsPlaying() then
				C_NewItems_RemoveNewItem(self.bagID, self.slotID)
				self.glowFrame:Hide()
				self.glowFrame.Animation:Stop()
			end
		end
	end

	local bagTypeColor = {
		[-1] = {0.67, 0.83, 0.45, 0.4},
		[0] = {C["Media"].Backdrops.ColorBackdrop[1], C["Media"].Backdrops.ColorBackdrop[2], C["Media"].Backdrops.ColorBackdrop[3], C["Media"].Backdrops.ColorBackdrop[4]},
		[1] = {0.53, 0.53, 0.93, 0.4},
		[2] = {0, 0.5, 0, 0.4},
		[3] = {0, 0.5, 0.8, 0.4},
	}

	local iLvlItemClassIDs = {
		[LE_ITEM_CLASS_ARMOR] = true,
		[LE_ITEM_CLASS_WEAPON] = true,
	}

	local function isItemNeedsLevel(item)
		return item.link and item.level and item.rarity > 1 and iLvlItemClassIDs[item.classID]
	end

	local function UpdatePawnArrow(self, item)
		if not hasPawn then
			return
		end

		if not PawnIsContainerItemAnUpgrade then
			return
		end

		if self.UpgradeIcon then
			self.UpgradeIcon:SetShown(PawnIsContainerItemAnUpgrade(item.bagID, item.slotID))
		end
	end

	function MyButton:OnUpdate(item)
		if MerchantFrame:IsShown() then
			if item.isInSet then
				self:SetAlpha(.5)
			else
				self:SetAlpha(1)
			end
		end

		if self.JunkIcon then
			if (item.rarity == LE_ITEM_QUALITY_POOR or KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList[item.id]) and item.sellPrice and item.sellPrice > 0 then
				self.JunkIcon:Show()
			else
				self.JunkIcon:Hide()
			end
		end

		if KkthnxUIDB.Variables[K.Realm][K.Name].FavouriteItems[item.id] then
			self.Favourite:Show()
		else
			self.Favourite:Hide()
		end

		if showItemLevel and isItemNeedsLevel(item) then
			--local level = B.GetItemLevel(item.link, item.bagID, item.slotID) or item.level
			local level = item.level
			local color = K.QualityColors[item.rarity]
			self.iLvl:SetText(level)
			self.iLvl:SetTextColor(color.r, color.g, color.b)
		else
			self.iLvl:SetText("")
		end

		-- Determine if we can use that item or not?
		if (Unfit:IsItemUnusable(item.id) or item.minLevel and item.minLevel > K.Level) and not item.locked then
			_G[self:GetName().."IconTexture"]:SetVertexColor(1, 0.1, 0.1)
		else
			_G[self:GetName().."IconTexture"]:SetVertexColor(1, 1, 1)
		end

		if self.glowFrame then
			if C_NewItems_IsNewItem(item.bagID, item.slotID) then
				local color = K.QualityColors[item.rarity]
				if item.isQuestItem or item.id == 24504 then
					self.glowFrame:SetBackdropBorderColor(1, .82, .2)
				elseif color and item.rarity and item.rarity > -1 then
					self.glowFrame:SetBackdropBorderColor(color.r, color.g, color.b)
				else
					self.glowFrame:SetBackdropBorderColor(1, 1, 1)
				end

				if not self.glowFrame:IsShown() or not self.glowFrame.Animation:IsPlaying() then
					self.glowFrame:Show()
					self.glowFrame.Animation:Stop()
					self.glowFrame.Animation:Play()
				end
			else
				if self.glowFrame:IsShown() or self.glowFrame.Animation:IsPlaying() then
					self.glowFrame:Hide()
					self.glowFrame.Animation:Stop()
				end
			end
		end

		if C["Inventory"].SpecialBagsColor then
			local bagType = Module.BagsType[item.bagID]
			local color = bagTypeColor[bagType] or bagTypeColor[0]
			self.KKUI_Background:SetVertexColor(unpack(color))
		else
			self.KKUI_Background:SetVertexColor(C["Media"].Backdrops.ColorBackdrop[1], C["Media"].Backdrops.ColorBackdrop[2], C["Media"].Backdrops.ColorBackdrop[3], C["Media"].Backdrops.ColorBackdrop[4])
		end

		-- Hide empty tooltip
		if GameTooltip:GetOwner() == self and not GetContainerItemInfo(item.bagID, item.slotID) then
			GameTooltip:Hide()
		end

		-- Support Pawn
		UpdatePawnArrow(self, item)
	end

	function MyButton:OnUpdateQuest(item)
		if item.isQuestItem or item.id == 24504 then
			self.KKUI_Border:SetVertexColor(1, .82, .2)
		elseif item.rarity and item.rarity > -1 then
			local color = K.QualityColors[item.rarity]
			self.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
		else
			if C["General"].ColorTextures then
				self.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
			else
				self.KKUI_Border:SetVertexColor(1, 1, 1)
			end
		end

		self.Quest:SetShown(C.IsAcceptableQuestItem[item.id])
	end

	function MyContainer:OnContentsChanged()
		self:SortButtons("bagSlot")

		local columns = self.Settings.Columns
		local offset = 38
		local spacing = 6
		local xOffset = 6
		local yOffset = -offset + xOffset
		local _, height = self:LayoutButtons("grid", columns, spacing, xOffset, yOffset)
		local width = columns * (iconSize + spacing) - spacing
		if self.freeSlot then
			if C["Inventory"].GatherEmpty then
				local numSlots = #self.buttons + 1
				local row = ceil(numSlots / columns)
				local col = numSlots % columns
				if col == 0 then
					col = columns
				end

				local xPos = (col - 1) * (iconSize + spacing)
				local yPos = -1 * (row - 1) * (iconSize + spacing)

				self.freeSlot:ClearAllPoints()
				self.freeSlot:SetPoint("TOPLEFT", self, "TOPLEFT", xPos+xOffset, yPos + yOffset)
				self.freeSlot:Show()

				if height < 0 then
					height = iconSize
				elseif col == 1 then
					height = height + iconSize + spacing
				end
			else
				self.freeSlot:Hide()
			end
		end
		self:SetSize(width + xOffset * 2, height + offset)

		Module:UpdateAnchors(f.main, ContainerGroups["Bag"])
		Module:UpdateAnchors(f.bank, ContainerGroups["Bank"])
	end

	function MyContainer:OnCreate(name, settings)
		self.Settings = settings
		self:SetFrameStrata("HIGH")
		self:SetClampedToScreen(true)
		self:CreateBorder()

		if settings.Bags then
			K.CreateMoverFrame(self, nil, true)
		end

		local label
		if string_match(name, "AmmoItem$") then
			label = K.Class == "HUNTER" and INVTYPE_AMMO or SOUL_SHARDS
		elseif string_match(name, "Equipment$") then
			label = BAG_FILTER_EQUIPMENT
		elseif name == "BankLegendary" then
			label = LOOT_JOURNAL_LEGENDARIES
		elseif string_match(name, "Consumable$") then
			label = BAG_FILTER_CONSUMABLES
		elseif name == "Junk" then
			label = BAG_FILTER_JUNK
		elseif string_match(name, "Favourite") then
			label = PREFERENCES
		elseif name == "Keyring" then
			label = KEYRING
		elseif string_match(name, "Goods") then
			label = AUCTION_CATEGORY_TRADE_GOODS
		elseif string_match(name, "Quest") then
			label = QUESTS_LABEL
		elseif string_match(name, "Mount$") then
			label = MOUNTS
		end

		if label then
			self.label = K.CreateFontString(self, 13, label, "OUTLINE", true, "TOPLEFT", 5, -8)
			return
		end

		Module.CreateInfoFrame(self)

		local buttons = {}
		buttons[1] = Module.CreateCloseButton(self)
		if name == "Bag" then
			Module.CreateBagBar(self, settings, NUM_BAG_SLOTS)
			buttons[2] = Module.CreateRestoreButton(self, f)
			buttons[3] = Module.CreateBagToggle(self)
			buttons[4] = Module.CreateKeyToggle(self)
			buttons[5] = Module.CreateSortButton(self, name)
			buttons[6] = Module.CreateSplitButton(self)
			buttons[7] = Module.CreateFavouriteButton(self)
			buttons[8] = Module.CreateJunkButton(self)
			if deleteButton then
				buttons[9] = Module.CreateDeleteButton(self)
			end
		elseif name == "Bank" then
			Module.CreateBagBar(self, settings, NUM_BANKBAGSLOTS - 1) -- We only have 6... NUM_BANKBAGSLOTS returns 7?
			buttons[2] = Module.CreateBagToggle(self)
			buttons[3] = Module.CreateSortButton(self, name)
		end

		for i = 1, #buttons do
			local bu = buttons[i]
			if not bu then
				break
			end

			if i == 1 then
				bu:SetPoint("TOPRIGHT", -6, -6)
			else
				bu:SetPoint("RIGHT", buttons[i - 1], "LEFT", -5, 0)
			end
		end

		self:HookScript("OnShow", K.RestoreMoverFrame)

		self.iconSize = iconSize
		Module.CreateFreeSlots(self)
	end

	local BagButton = Backpack:GetClass("BagButton", true, "BagButton")
	function BagButton:OnCreate()
		self:SetNormalTexture(nil)
		self:SetPushedTexture(nil)

		self:SetSize(iconSize, iconSize)
		self:CreateBorder()
		self:StyleButton()

		self.Icon:SetAllPoints()
		self.Icon:SetTexCoord(unpack(K.TexCoords))
	end

	function BagButton:OnUpdate()
		local id = GetInventoryItemID("player", (self.GetInventorySlot and self:GetInventorySlot()) or self.invID)
		if not id then
			return
		end

		local _, _, quality, _, _, _, _, _, _, _, _, classID, subClassID = GetItemInfo(id)
		if not quality or quality == 1 then
			quality = 0
		end

		local color = K.QualityColors[quality]
		if not self.hidden and not self.notBought then
			self.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
		else
			if C["General"].ColorTextures then
				self.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
			else
				self.KKUI_Border:SetVertexColor(1, 1, 1)
			end
		end

		if classID == LE_ITEM_CLASS_CONTAINER then
			Module.BagsType[self.bagID] = subClassID or 0
		elseif classID == LE_ITEM_CLASS_QUIVER then
			Module.BagsType[self.bagID] = -1
		else
			Module.BagsType[self.bagID] = 0
		end
	end

	-- Sort order
	SetSortBagsRightToLeft(C["Inventory"].BagSortMode.Value == 1)
	SetInsertItemsLeftToRight(false)

	-- Init
	ToggleAllBags()
	ToggleAllBags()
	Module.initComplete = true

	K:RegisterEvent("TRADE_SHOW", Module.OpenBags)
	K:RegisterEvent("AUCTION_HOUSE_SHOW", Module.OpenBags)
	K:RegisterEvent("AUCTION_HOUSE_CLOSED", Module.CloseBags)

	-- Fixes
	BankFrameItemButton_Update = K.Noop

	-- Shift key alert
	local function OnShiftUpdate(self, elapsed)
		if IsShiftKeyDown() then
			self.elapsed = (self.elapsed or 0) + elapsed
			if self.elapsed > 5 then
				UIErrorsFrame:AddMessage(K.InfoColor.."Your SHIFT key may be stuck!")
				self.elapsed = 0
			end
		end
	end

	local ShiftUpdaterFrame = CreateFrame("Frame", nil, f.main)
	ShiftUpdaterFrame:SetScript("OnUpdate", OnShiftUpdate)
end