local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Bags")

local _G = _G
local table_wipe = _G.table.wipe

local C_Timer_After = _G.C_Timer.After
local GetContainerItemInfo = _G.GetContainerItemInfo
local GetContainerNumSlots = _G.GetContainerNumSlots
local IsShiftKeyDown = _G.IsShiftKeyDown

local autoSellStop = true
local autoSellCache = {}
local autoSellErrorText = _G.ERR_VENDOR_DOESNT_BUY

local function startSelling()
	if autoSellStop then
		return
	end

	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			if autoSellStop then
				return
			end

			local _, _, _, quality, _, _, link, _, noValue, itemID = GetContainerItemInfo(bag, slot)
			if link and not noValue and (quality == 0 or KkthnxUIDB.CustomJunkList[itemID]) and not autoSellCache["b"..bag.."s"..slot] then
				autoSellCache["b" .. bag .. "s" .. slot] = true
				UseContainerItem(bag, slot)
				C_Timer_After(0.15, startSelling)
				return
			end
		end
	end
end

local function updateSelling(event, ...)
	if not C["Inventory"].AutoSell then
		return
	end

	local _, arg = ...
	if event == "MERCHANT_SHOW" then
		if IsShiftKeyDown() then
			return
		end

		autoSellStop = false
		table_wipe(autoSellCache)
		startSelling()
		K:RegisterEvent("UI_ERROR_MESSAGE", updateSelling)
	elseif event == "UI_ERROR_MESSAGE" and arg == autoSellErrorText or event == "MERCHANT_CLOSED" then
		autoSellStop = true
	end
end

function Module:CreateAutoSell()
	K:RegisterEvent("MERCHANT_SHOW", updateSelling)
	K:RegisterEvent("MERCHANT_CLOSED", updateSelling)
end
