local K, C = unpack(select(2, ...))
local Module = K:GetModule("Bags")

local _G = _G

local AmmoEquipLoc = _G.INVTYPE_AMMO
local LE_ITEM_CLASS_ARMOR = _G.LE_ITEM_CLASS_ARMOR
local LE_ITEM_CLASS_CONSUMABLE = _G.LE_ITEM_CLASS_CONSUMABLE
local LE_ITEM_CLASS_ITEM_ENHANCEMENT = _G.LE_ITEM_CLASS_ITEM_ENHANCEMENT
local LE_ITEM_CLASS_TRADEGOODS = _G.LE_ITEM_CLASS_TRADEGOODS
local LE_ITEM_CLASS_WEAPON = _G.LE_ITEM_CLASS_WEAPON
local LE_ITEM_QUALITY_LEGENDARY = _G.LE_ITEM_QUALITY_LEGENDARY
local LE_ITEM_QUALITY_POOR = _G.LE_ITEM_QUALITY_POOR

local function isCustomFilter(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	return C.CustomFilterList[item.id]
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

	return (item.rarity == LE_ITEM_QUALITY_POOR or KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList[item.id]) and item.sellPrice and item.sellPrice > 0
end

local function isItemAmmo(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterAmmo then
		return
	end

	if K.Class == "HUNTER" then
		return item.equipLoc == AmmoEquipLoc or Module.BagsType[item.bagID] == -1
	elseif K.Class == "WARLOCK" then
		return item.id == 6265 or Module.BagsType[item.bagID] == 1
	end
end

local function isItemEquipment(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterEquipment then
		return
	end

	return item.level and item.rarity > LE_ITEM_QUALITY_POOR and (item.classID == LE_ITEM_CLASS_WEAPON or item.classID == LE_ITEM_CLASS_ARMOR)
end

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

	return isCustomFilter(item) or (item.classID and (item.classID == LE_ITEM_CLASS_CONSUMABLE or item.classID == LE_ITEM_CLASS_ITEM_ENHANCEMENT))
end

local function isItemMount(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterMount then
		return
	end

	return C.MountFilterList[item.id]
end

local function isItemLegendary(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterLegendary then
		return
	end

	return item.rarity == LE_ITEM_QUALITY_LEGENDARY
end

local function isItemFavourite(item)
	if not C["Inventory"].ItemFilter then
		return
	end

	if not C["Inventory"].FilterFavourite then
		return
	end

	return item.id and KkthnxUIDB.Variables[K.Realm][K.Name].FavouriteItems[item.id]
end

local function isEmptySlot(item)
	if not C["Inventory"].GatherEmpty then
		return
	end

	return Module.initComplete and not item.texture and Module.BagsType[item.bagID] == 0
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

	return item.isQuestItem or item.id == 24504 -- Idk why Howling Wind is not a quest item?
end

function Module:GetFilters()
	local filters = {}

	filters.onlyBags = function(item) return isItemInBag(item) and not isEmptySlot(item) end
	filters.bagAmmo = function(item) return isItemInBag(item) and isItemAmmo(item) end
	filters.bagMount = function(item) return isItemInBag(item) and isItemMount(item) end
	filters.bagEquipment = function(item) return isItemInBag(item) and isItemEquipment(item) end
	filters.bagConsumable = function(item) return isItemInBag(item) and isItemConsumable(item) end
	filters.bagsJunk = function(item) return isItemInBag(item) and isItemJunk(item) end
	filters.onlyBank = function(item) return isItemInBank(item) and not isEmptySlot(item) end
	filters.bankAmmo = function(item) return isItemInBank(item) and isItemAmmo(item) end
	filters.bankLegendary = function(item) return isItemInBank(item) and isItemLegendary(item) end
	filters.bankEquipment = function(item) return isItemInBank(item) and isItemEquipment(item) end
	filters.bankConsumable = function(item) return isItemInBank(item) and isItemConsumable(item) end
	filters.onlyReagent = function(item) return item.bagID == -3 end
	filters.bagFavourite = function(item) return isItemInBag(item) and isItemFavourite(item) end
	filters.bankFavourite = function(item) return isItemInBank(item) and isItemFavourite(item) end
	filters.onlyKeyring = function(item) return isItemKeyRing(item) end
	filters.bagGoods = function(item) return isItemInBag(item) and isTradeGoods(item) end
	filters.bankGoods = function(item) return isItemInBank(item) and isTradeGoods(item) end
	filters.bagQuest = function(item) return isItemInBag(item) and isQuestItem(item) end
	filters.bankQuest = function(item) return isItemInBank(item) and isQuestItem(item) end

	return filters
end