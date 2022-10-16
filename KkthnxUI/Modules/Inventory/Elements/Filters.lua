local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Bags")
local cargBags = K.cargBags

local LE_ITEM_QUALITY_POOR, LE_ITEM_QUALITY_LEGENDARY = LE_ITEM_QUALITY_POOR, LE_ITEM_QUALITY_LEGENDARY
local LE_ITEM_CLASS_CONSUMABLE, LE_ITEM_CLASS_ITEM_ENHANCEMENT = LE_ITEM_CLASS_CONSUMABLE, LE_ITEM_CLASS_ITEM_ENHANCEMENT
local LE_ITEM_CLASS_WEAPON, LE_ITEM_CLASS_ARMOR, LE_ITEM_CLASS_TRADEGOODS = LE_ITEM_CLASS_WEAPON, LE_ITEM_CLASS_ARMOR, LE_ITEM_CLASS_TRADEGOODS
local AmmoEquipLoc = _G.INVTYPE_AMMO

-- Custom filter for consumable
local CustomFilterList = {
	[12450] = true, -- Juju Flurry
	[12451] = true, -- Juju Power
	[12455] = true, -- Juju Ember
	[12457] = true, -- Juju Chill
	[12458] = true, -- Juju Guile
	[12459] = true, -- Juju Escape
	[12460] = true, -- Juju Might
	[10646] = true, -- 地精工兵炸药
	[23737] = true, -- 精金手雷
	[23827] = true, -- 超级神风炸药

	[4366] = true, -- 活动假人
	[12662] = true, -- 恶魔符文
	[20520] = true, -- 黑暗符文
	[16023] = true, -- 高级活动假人
	[22797] = true, -- 梦魇草
	[39970] = false, -- 火叶
}

local function isCustomFilter(item)
	if not C["Inventory"].ItemFilter then
		return
	end
	return CustomFilterList[item.id]
end

-- Default filter
local function isItemInBag(item)
	return item.bagID >= 0 and item.bagID <= 4
end

local function isItemInBank(item)
	return item.bagID == -1 or item.bagID >= 5 and item.bagID <= 11
end

local function isItemJunk(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterJunk then
		return
	end

	return (item.quality == LE_ITEM_QUALITY_POOR or KkthnxUIDB.CustomJunkList[item.id]) and item.hasPrice
end

local function isItemEquipSet(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterEquipSet then
		return
	end

	return item.isInSet
end

local function isItemAmmo(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterAmmo then
		return
	end

	if C["Inventory"].GatherEmpty and not item.texture then
		return false
	end

	if K.Class == "HUNTER" then
		return item.equipLoc == AmmoEquipLoc or cargBags.BagGroups[item.bagID] == -1
	elseif K.Class == "WARLOCK" then
		return item.id == 6265 or cargBags.BagGroups[item.bagID] == 1
	end
end

K.iLvlClassIDs = {
	[LE_ITEM_CLASS_ARMOR] = true,
	[LE_ITEM_CLASS_WEAPON] = true,
}
function Module:IsItemHasLevel(item)
	return K.iLvlClassIDs[item.classID]
end

local function isItemEquipment(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterEquipment then
		return
	end

	return item.link and item.quality > LE_ITEM_QUALITY_COMMON and Module:IsItemHasLevel(item)
end

local consumableIDs = {
	[LE_ITEM_CLASS_CONSUMABLE] = true,
	[LE_ITEM_CLASS_ITEM_ENHANCEMENT] = true,
}

local function isItemConsumable(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterConsumable then
		return
	end

	if isCustomFilter(item) == false then
		return
	end

	return isCustomFilter(item) or consumableIDs[item.classID]
end

local function isItemLegendary(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterLegendary then
		return
	end

	return item.quality == LE_ITEM_QUALITY_LEGENDARY
end

local function isItemCustom(item, index)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterFavourite then
		return
	end

	local customIndex = item.id and KkthnxUIDB.Variables[K.Realm][K.Name].CustomItems[item.id]
	return customIndex and customIndex == index
end

local function isEmptySlot(item)
	if not C["Inventory"].GatherEmpty then
		return
	end

	return Module.initComplete and not item.texture and (C["Inventory"].ItemFilter or cargBags.BagGroups[item.bagID] == 0)
end

local function isItemKeyRing(item)
	return item.bagID == -2
end

local function isTradeGoods(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterGoods then
		return
	end

	return item.classID == LE_ITEM_CLASS_TRADEGOODS
end

local function isQuestItem(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterQuest then
		return
	end
	return item.isQuestItem
end

function Module:GetFilters()
	local filters = {}

	filters.onlyBags = function(item)
		return isItemInBag(item) and not isEmptySlot(item)
	end
	filters.bagAmmo = function(item)
		return isItemInBag(item) and isItemAmmo(item)
	end
	filters.bagEquipment = function(item)
		return isItemInBag(item) and isItemEquipment(item)
	end
	filters.bagEquipSet = function(item)
		return isItemInBag(item) and isItemEquipSet(item)
	end
	filters.bagConsumable = function(item)
		return isItemInBag(item) and isItemConsumable(item)
	end
	filters.bagsJunk = function(item)
		return isItemInBag(item) and isItemJunk(item)
	end
	filters.onlyBank = function(item)
		return isItemInBank(item) and not isEmptySlot(item)
	end
	filters.bankAmmo = function(item)
		return isItemInBank(item) and isItemAmmo(item)
	end
	filters.bankLegendary = function(item)
		return isItemInBank(item) and isItemLegendary(item)
	end
	filters.bankEquipment = function(item)
		return isItemInBank(item) and isItemEquipment(item)
	end
	filters.bankEquipSet = function(item)
		return isItemInBank(item) and isItemEquipSet(item)
	end
	filters.bankConsumable = function(item)
		return isItemInBank(item) and isItemConsumable(item)
	end
	filters.onlyReagent = function(item)
		return item.bagID == -3
	end
	filters.onlyKeyring = function(item)
		return isItemKeyRing(item)
	end
	filters.bagGoods = function(item)
		return isItemInBag(item) and isTradeGoods(item)
	end
	filters.bankGoods = function(item)
		return isItemInBank(item) and isTradeGoods(item)
	end
	filters.bagQuest = function(item)
		return isItemInBag(item) and isQuestItem(item)
	end
	filters.bankQuest = function(item)
		return isItemInBank(item) and isQuestItem(item)
	end

	for i = 1, 5 do
		filters["bagCustom" .. i] = function(item)
			return isItemInBag(item) and isItemCustom(item, i)
		end
		filters["bankCustom" .. i] = function(item)
			return isItemInBank(item) and isItemCustom(item, i)
		end
	end

	return filters
end
