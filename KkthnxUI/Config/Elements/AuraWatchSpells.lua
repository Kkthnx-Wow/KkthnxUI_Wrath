local K, C = unpack(KkthnxUI)
local Module = K:NewModule("AurasTable")

local _G = _G
local string_format = _G.string.format
local table_wipe = _G.table.wipe

local GetSpellInfo = _G.GetSpellInfo
local UIParent = _G.UIParent

-- AuraWatch
local AuraWatchList = {}
local groups = {
	-- groups name = direction, interval, mode, iconsize, position, barwidth
	["Player Aura"] = { "LEFT", 6, "ICON", 30, { "BOTTOMRIGHT", UIParent, "BOTTOM", -160, 432 } },
	["Target Aura"] = { "RIGHT", 6, "ICON", 36, { "BOTTOMLEFT", UIParent, "BOTTOM", 160, 468 } },
	["Special Aura"] = { "LEFT", 6, "ICON", 36, { "BOTTOMRIGHT", UIParent, "BOTTOM", -160, 468 } },
	["Focus Aura"] = { "RIGHT", 6, "ICON", 35, { "BOTTOMLEFT", UIParent, "LEFT", 5, -230 } },
	["Spell Cooldown"] = { "UP", 6, "BAR", 18, { "BOTTOMRIGHT", UIParent, "BOTTOM", -380, 140 }, 150 },
	["Enchant Aura"] = { "LEFT", 6, "ICON", 36, { "BOTTOMRIGHT", UIParent, "BOTTOM", -160, 510 } },
	["Raid Buff"] = { "LEFT", 6, "ICON", 42, { "CENTER", UIParent, "CENTER", -220, 300 } },
	["Raid Debuff"] = { "RIGHT", 6, "ICON", 42, { "CENTER", UIParent, "CENTER", 220, 300 } },
	["Warning"] = { "RIGHT", 6, "ICON", 42, { "BOTTOMLEFT", UIParent, "BOTTOM", 160, 510 } },
	["InternalCD"] = { "UP", 6, "BAR", 18, { "BOTTOMRIGHT", UIParent, "BOTTOM", -425, 600 }, 150 },
}

local function newAuraFormat(value)
	local newTable = {}
	for _, v in pairs(value) do
		local id = v.AuraID or v.SpellID or v.ItemID or v.SlotID or v.TotemID or v.IntID
		if id then
			newTable[id] = v
		end
	end
	return newTable
end

function Module:AddNewAuraWatch(class, list)
	for _, k in pairs(list) do
		for _, v in pairs(k) do
			local spellID = v.AuraID or v.SpellID
			if spellID then
				local name = GetSpellInfo(spellID)
				if not name then
					table_wipe(v)
					if K.isDeveloper then
						K.Print(string_format("|cffFF0000Invalid spellID:|r '%s' %s", class, spellID))
					end
				end
			end
		end
	end

	if class ~= "ALL" and class ~= K.Class then
		return
	end

	if not AuraWatchList[class] then
		AuraWatchList[class] = {}
	end

	for name, v in pairs(list) do
		local direction, interval, mode, size, pos, width = unpack(groups[name])
		table.insert(AuraWatchList[class], {
			Name = name,
			Direction = direction,
			Interval = interval,
			Mode = mode,
			IconSize = size,
			Pos = pos,
			BarWidth = width,
			List = newAuraFormat(v),
		})
	end
end

function Module:AddDeprecatedGroup()
	for name, value in pairs(C.DeprecatedAuras) do
		for _, list in pairs(AuraWatchList["ALL"]) do
			if list.Name == name then
				local newTable = newAuraFormat(value)
				for spellID, v in pairs(newTable) do
					list.List[spellID] = v
				end
			end
		end
	end

	table_wipe(C.DeprecatedAuras)
end

function Module:CheckMajorSpells()
	for spellID in pairs(C.MajorSpells) do
		local name = GetSpellInfo(spellID)
		if name then
			if KkthnxUIDB.MajorSpells[spellID] then
				KkthnxUIDB.MajorSpells[spellID] = nil
			end
		else
			if K.isDeveloper then
				K.Print("Invalid majorspells ID: " .. spellID)
			end
		end
	end

	for spellID, value in pairs(KkthnxUIDB.MajorSpells) do
		if value == false and C.MajorSpells[spellID] == nil then
			KkthnxUIDB.MajorSpells[spellID] = nil
		end
	end
end

function Module:OnEnable()
	-- Module:AddDeprecatedGroup()
	C.AuraWatchList = AuraWatchList
	Module:CheckMajorSpells()
end
