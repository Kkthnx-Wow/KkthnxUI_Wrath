local K, C = unpack(select(2, ...))
local Module = K:GetModule("Loot")

local _G = _G

local GetCVarBool = _G.GetCVarBool
local GetLootMethod = _G.GetLootMethod
local GetLootSlotInfo = _G.GetLootSlotInfo
local GetLootSlotType = _G.GetLootSlotType
local GetLootThreshold = _G.GetLootThreshold
local GetNumLootItems = _G.GetNumLootItems
local GetTime = _G.GetTime
local IsInGroup = _G.IsInGroup
local IsModifiedClick = _G.IsModifiedClick
local LootSlot = _G.LootSlot

local lootDelay = 0
local function SetupFasterLoot()
	if GetTime() - lootDelay >= 0.3 then
		lootDelay = GetTime()
		 if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
			local lootMethod = GetLootMethod()
			if lootMethod == "master" then
				-- Master loot is enabled so fast loot if item should be auto looted
				local lootThreshold = GetLootThreshold()
				for i = GetNumLootItems(), 1, -1 do
					local _, _, _, _, lootQuality = GetLootSlotInfo(i)
					if lootQuality and lootThreshold and lootQuality < lootThreshold then
						LootSlot(i)
					end
				end
			else -- Master loot is disabled so fast loot regardless
				local grouped = IsInGroup()
				for i = GetNumLootItems(), 1, -1 do
					local _, lootName, _, _, _, locked = GetLootSlotInfo(i)
					local slotType = GetLootSlotType(i)
					if lootName and not locked then
						if not grouped then
							LootSlot(i)
						else
							if lootMethod == "freeforall" then
								if slotType == LOOT_SLOT_ITEM then
									LootSlot(i)
								end
							else
								LootSlot(i)
							end
						end
					end
				end
			end
			lootDelay = GetTime()
		end
	end
end

function Module:CreateFasterLoot()
	if IsAddOnLoaded("SpeedyAutoLoot") then
		return
	end

	if C["Loot"].FastLoot then
		K:RegisterEvent("LOOT_READY", SetupFasterLoot)
	else
		K:UnregisterEvent("LOOT_READY", SetupFasterLoot)
	end
end