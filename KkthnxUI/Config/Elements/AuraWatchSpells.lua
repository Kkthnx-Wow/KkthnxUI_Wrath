local K, C = unpack(select(2, ...))
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
	["Player Aura"] = {"LEFT", 6, "ICON", 22, {"BOTTOMRIGHT", UIParent, "BOTTOM", -166, 506}},
	["Target Aura"] = {"RIGHT", 6, "ICON", 22, {"BOTTOMLEFT", UIParent, "BOTTOM", 166, 506}},
	["Special Aura"] = {"LEFT", 6, "ICON", 36, {"BOTTOMRIGHT", UIParent, "BOTTOM", -166, 534}},
	["Focus Aura"] = {"RIGHT", 6, "ICON", 22, {"BOTTOMLEFT", UIParent, "LEFT", 5, -230}},
	["Spell Cooldown"] = {"UP", 6, "BAR", 18, {"BOTTOMRIGHT", UIParent, "BOTTOM", -374, 150}, 150},
	["Enchant Aura"] = {"LEFT", 6, "ICON", 36, {"BOTTOMRIGHT", UIParent, "BOTTOM", -166, 575}},
	["Raid Buff"] = {"LEFT", 6, "ICON", 42, {"CENTER", UIParent, "CENTER", -186, 300}},
	["Raid Debuff"] = {"RIGHT", 6, "ICON", 42, {"CENTER", UIParent, "CENTER", 186, 300}},
	["Warning"] = {"RIGHT", 6, "ICON", 42, {"BOTTOMLEFT", UIParent, "BOTTOM", 166, 534}},
	["InternalCD"] = {"UP", 6, "BAR", 18, {"BOTTOMRIGHT", UIParent, "BOTTOM", -394, 618}, 150},
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
			List = newAuraFormat(v)
		})
	end
end

function Module:OnEnable()
	C.AuraWatchList = AuraWatchList
end