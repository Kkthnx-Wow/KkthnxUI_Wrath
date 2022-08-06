local K, C = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local _G = _G
local bit_band = _G.bit.band

local BuyMerchantItem = _G.BuyMerchantItem
local GetContainerNumFreeSlots = _G.GetContainerNumFreeSlots
local GetInventoryItemID = _G.GetInventoryItemID
local GetInventorySlotInfo = _G.GetInventorySlotInfo
local GetItemInfo = _G.GetItemInfo
local GetMerchantItemInfo = _G.GetMerchantItemInfo
local GetMerchantNumItems = _G.GetMerchantNumItems

local ammoBag, freeAmmoSlots, refillAmmoID

local function FindAmmoBag()
	for i = 0, NUM_BAG_SLOTS do
		local freeSlots, bagType = GetContainerNumFreeSlots(i)
		if bagType ~= nil then
			if freeSlots >= 0 and (bit_band(0x0003, bagType) == 1) or (bit_band(0x0003, bagType) == 2) then
				return i, freeSlots, bagType
			end
			-- else
			-- return 0, 0, 1
		end
	end
end

local function GetPlayerAmmoInfo()
	ammoBag, freeAmmoSlots = FindAmmoBag()
	local rangedItemID = GetInventoryItemID("player", 18)
	if rangedItemID ~= nil then
		-- local subclassID = select(7, GetItemInfoInstant(rangedItemID))
		refillAmmoID = GetInventoryItemID("player", GetInventorySlotInfo("AmmoSlot"))
	else
		refillAmmoID = nil
	end

	if refillAmmoID ~= nil then
		local ammoName = GetItemInfo(refillAmmoID)
		-- K.Print(ammoName)
		return ammoName
	else
		local ammoName = "ammo"
		return ammoName
	end
end

local function MerchantHasAmmo()
	local playerAmmoName = GetPlayerAmmoInfo()
	for i = 1, GetMerchantNumItems() do
		-- K.Print(playerAmmoName)
		local mAmmoName = GetMerchantItemInfo(i)
		if mAmmoName == playerAmmoName then
			return i
		end
	end
end

local function BuyAmmo(mSlot)
	if not mSlot then
		mSlot = MerchantHasAmmo()
	end

	for i = 1, freeAmmoSlots do
		BuyMerchantItem(mSlot)
	end
	ammoBag, freeAmmoSlots = nil, nil
end

local function SetupRefillAmmo()
	ammoBag, freeAmmoSlots = FindAmmoBag()
	if ammoBag ~= nil then
		StaticPopupDialogs["KKUI_REFILLAMMO"].text = "Refill "..freeAmmoSlots.." stacks of x200 " ..K.SystemColor.."["..GetPlayerAmmoInfo().."]".."|r?"

		if ammoBag and freeAmmoSlots ~= 0 then
			local hasAmmo = MerchantHasAmmo()
			if hasAmmo then
				if C["Automation"].RefillAmmo then
					StaticPopup_Show("KKUI_REFILLAMMO")
                else
					BuyAmmo(hasAmmo)
				end
			end
		else
			ammoBag, freeAmmoSlots = nil, nil
		end
	end
end

StaticPopupDialogs["KKUI_REFILLAMMO"] = {
    text = "Refill?",
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function()
        BuyAmmo()
    end,
    timeout = 0,
    whileDead = 0,
    hideOnEscape = 1
}

function Module:CreateAutoRefillAmmo()
	if K.Class ~= "HUNTER" then
		return
	end

	if not C["Automation"].RefillAmmo then
		return
	end

	K:RegisterEvent("MERCHANT_SHOW", SetupRefillAmmo)
end