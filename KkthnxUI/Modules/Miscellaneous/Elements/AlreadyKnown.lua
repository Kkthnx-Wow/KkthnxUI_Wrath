local K = unpack(select(2, ...))

-- Sourced: AlreadyKnown (villiv)
-- Edited: KkthnxUI (Kkthnx)

local _G = _G
local mod = _G.mod
local string_find = _G.string.find
local string_match = _G.string.match

local BUYBACK_ITEMS_PER_PAGE = _G.BUYBACK_ITEMS_PER_PAGE or 12
local COLLECTED = _G.COLLECTED
local GetBuybackItemInfo = _G.GetBuybackItemInfo
local GetBuybackItemLink = _G.GetBuybackItemLink
local GetCurrentGuildBankTab = _G.GetCurrentGuildBankTab
local GetGuildBankItemInfo = _G.GetGuildBankItemInfo
local GetGuildBankItemLink = _G.GetGuildBankItemLink
local GetItemInfo = _G.GetItemInfo
local GetMerchantItemInfo = _G.GetMerchantItemInfo
local GetMerchantItemLink = _G.GetMerchantItemLink
local GetMerchantNumItems = _G.GetMerchantNumItems
local GetNumBuybackItems = _G.GetNumBuybackItems
local ITEM_SPELL_KNOWN = _G.ITEM_SPELL_KNOWN
local LE_ITEM_CLASS_BATTLEPET = _G.LE_ITEM_CLASS_BATTLEPET
local LE_ITEM_CLASS_CONSUMABLE = _G.LE_ITEM_CLASS_CONSUMABLE
local LE_ITEM_CLASS_MISCELLANEOUS = _G.LE_ITEM_CLASS_MISCELLANEOUS
local LE_ITEM_CLASS_RECIPE = _G.LE_ITEM_CLASS_RECIPE
local MAX_GUILDBANK_SLOTS_PER_TAB = _G.MAX_GUILDBANK_SLOTS_PER_TAB or 98
local MERCHANT_ITEMS_PER_PAGE = _G.MERCHANT_ITEMS_PER_PAGE or 10
local NUM_SLOTS_PER_GUILDBANK_GROUP = _G.NUM_SLOTS_PER_GUILDBANK_GROUP or 14
local SetItemButtonTextureVertexColor = _G.SetItemButtonTextureVertexColor
local UIParent = _G.UIParent
local hooksecurefunc = _G.hooksecurefunc

local COLOR = {r = .1, g = 1, b = .1}
local knowables, knowns = {
	[LE_ITEM_CLASS_CONSUMABLE] = true,
	[LE_ITEM_CLASS_RECIPE] = true,
	[LE_ITEM_CLASS_MISCELLANEOUS] = true,
}, {}

local function isPetCollected(speciesID)
	if not speciesID or speciesID == 0 then
		return
	end

	local numOwned = C_PetJournal.GetNumCollectedInfo(speciesID)
	if numOwned > 0 then
		return true
	end
end

local function IsAlreadyKnown(link, index)
	if not link then
		return
	end

	if string_match(link, "battlepet:") then
		local speciesID = select(2, string.split(":", link))
		return isPetCollected(speciesID)
	elseif string_match(link, "item:") then
		local name, _, _, _, _, _, _, _, _, _, _, itemClassID = GetItemInfo(link)
		if not name then
			return
		end

		if itemClassID == LE_ITEM_CLASS_BATTLEPET and index then
			local speciesID = K.ScanTooltip:SetGuildBankItem(GetCurrentGuildBankTab(), index)
			return isPetCollected(speciesID)
		else
			if knowns[link] then
				return true
			end

			if not knowables[itemClassID] then
				return
			end

			K.ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
			K.ScanTooltip:SetHyperlink(link)
			for i = 1, K.ScanTooltip:NumLines() do
				local text = _G["KKUI_ScanTooltipTextLeft"..i]:GetText() or ""
				if string_find(text, COLLECTED) or text == ITEM_SPELL_KNOWN then
					knowns[link] = true
					return true
				end
			end
		end
	end
end

-- merchant frame
local function MerchantFrame_UpdateMerchantInfo()
	local numItems = GetMerchantNumItems()
	for i = 1, MERCHANT_ITEMS_PER_PAGE do
		local index = (MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE + i
		if index > numItems then return end

		local button = _G["MerchantItem"..i.."ItemButton"]
		if button and button:IsShown() then
			local _, _, _, _, numAvailable, isUsable = GetMerchantItemInfo(index)
			if isUsable and IsAlreadyKnown(GetMerchantItemLink(index)) then
				local r, g, b = COLOR.r, COLOR.g, COLOR.b
				if numAvailable == 0 then
					r, g, b = r * 0.5, g * 0.5, b * 0.5
				end
				SetItemButtonTextureVertexColor(button, r, g, b)
			end
		end
	end
end
hooksecurefunc("MerchantFrame_UpdateMerchantInfo", MerchantFrame_UpdateMerchantInfo)

local function MerchantFrame_UpdateBuybackInfo()
	local numItems = GetNumBuybackItems()
	for index = 1, BUYBACK_ITEMS_PER_PAGE do
		if index > numItems then
			return
		end

		local button = _G["MerchantItem"..index.."ItemButton"]
		if button and button:IsShown() then
			local _, _, _, _, _, isUsable = GetBuybackItemInfo(index)
			if isUsable and IsAlreadyKnown(GetBuybackItemLink(index)) then
				SetItemButtonTextureVertexColor(button, COLOR.r, COLOR.g, COLOR.b)
			end
		end
	end
end
hooksecurefunc("MerchantFrame_UpdateBuybackInfo", MerchantFrame_UpdateBuybackInfo)

-- guild bank frame
local function GuildBankFrame_Update()
	if GuildBankFrame.mode ~= "bank" then
		return
	end

	local tab = GetCurrentGuildBankTab()
	for i = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local index = mod(i, NUM_SLOTS_PER_GUILDBANK_GROUP)
		if index == 0 then
			index = NUM_SLOTS_PER_GUILDBANK_GROUP
		end

		local button = _G["GuildBankColumn"..math.ceil((i - 0.5) / NUM_SLOTS_PER_GUILDBANK_GROUP).."Button"..index]
		if button and button:IsShown() then
			local texture, _, locked = GetGuildBankItemInfo(tab, i)
			if texture and not locked then
				if IsAlreadyKnown(GetGuildBankItemLink(tab, i), i) then
					SetItemButtonTextureVertexColor(button, COLOR.r, COLOR.g, COLOR.b)
				else
					SetItemButtonTextureVertexColor(button, 1, 1, 1)
				end
			end
		end
	end
end

local isBlizzard_GuildBankUILoaded
if IsAddOnLoaded("Blizzard_GuildBankUI") then
	isBlizzard_GuildBankUILoaded = true
	hooksecurefunc("GuildBankFrame_Update", GuildBankFrame_Update)
end

-- auction frame
local function AuctionFrameBrowse_Update()
	local numItems = GetNumAuctionItems("list")
	local offset = FauxScrollFrame_GetOffset(BrowseScrollFrame)
	for i = 1, NUM_BROWSE_TO_DISPLAY do
		local index = offset + i
		if index > numItems then
			return
		end

		local texture = _G["BrowseButton"..i.."ItemIconTexture"]
		if texture and texture:IsShown() then
			local _, _, _, _, canUse = GetAuctionItemInfo("list", index)
			if canUse and IsAlreadyKnown(GetAuctionItemLink("list", index)) then
				texture:SetVertexColor(COLOR.r, COLOR.g, COLOR.b)
			end
		end
	end
end

local function AuctionFrameBid_Update()
	local numItems = GetNumAuctionItems("bidder")
	local offset = FauxScrollFrame_GetOffset(BidScrollFrame)
	for i = 1, NUM_BIDS_TO_DISPLAY do
		local index = offset + i
		if index > numItems then
			return
		end

		local texture = _G["BidButton"..i.."ItemIconTexture"]
		if texture and texture:IsShown() then
			local _, _, _, _, canUse = GetAuctionItemInfo("bidder", index)
			if canUse and IsAlreadyKnown(GetAuctionItemLink("bidder", index)) then
				texture:SetVertexColor(COLOR.r, COLOR.g, COLOR.b)
			end
		end
	end
end

local function AuctionFrameAuctions_Update()
	local numItems = GetNumAuctionItems("owner")
	local offset = FauxScrollFrame_GetOffset(AuctionsScrollFrame)
	for i = 1, NUM_AUCTIONS_TO_DISPLAY do
		local index = offset + i
		if index > numItems then
			return
		end

		local texture = _G["AuctionsButton"..i.."ItemIconTexture"]
		if texture and texture:IsShown() then
			local _, _, _, _, canUse, _, _, _, _, _, _, _, saleStatus = GetAuctionItemInfo("owner", index)
			if canUse and IsAlreadyKnown(GetAuctionItemLink("owner", index)) then
				local r, g, b = COLOR.r, COLOR.g, COLOR.b
				if saleStatus == 1 then
					r, g, b = r * 0.5, g * 0.5, b * 0.5
				end
				texture:SetVertexColor(r, g, b)
			end
		end
	end
end

local isBlizzard_AuctionUILoaded
if IsAddOnLoaded("Blizzard_AuctionUI") then
	isBlizzard_AuctionUILoaded = true
	hooksecurefunc("AuctionFrameBrowse_Update", AuctionFrameBrowse_Update)
	hooksecurefunc("AuctionFrameBid_Update", AuctionFrameBid_Update)
	hooksecurefunc("AuctionFrameAuctions_Update", AuctionFrameAuctions_Update)
end

-- for LoD addons
if not (isBlizzard_GuildBankUILoaded and isBlizzard_AuctionUILoaded) then
	local function OnEvent(event, addonName)
		if addonName == "Blizzard_GuildBankUI" then
			isBlizzard_GuildBankUILoaded = true
			hooksecurefunc("GuildBankFrame_Update", GuildBankFrame_Update)
		elseif addonName == "Blizzard_AuctionUI" then
			isBlizzard_AuctionUILoaded = true
			hooksecurefunc("AuctionFrameBrowse_Update", AuctionFrameBrowse_Update)
			hooksecurefunc("AuctionFrameBid_Update", AuctionFrameBid_Update)
			hooksecurefunc("AuctionFrameAuctions_Update", AuctionFrameAuctions_Update)
		end
		if isBlizzard_GuildBankUILoaded and isBlizzard_AuctionUILoaded then
			K:UnregisterEvent(event, OnEvent)
		end
	end
	K:RegisterEvent("ADDON_LOADED", OnEvent)
end