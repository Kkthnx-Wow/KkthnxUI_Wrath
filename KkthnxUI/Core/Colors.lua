local K = unpack(KkthnxUI)
local oUF = K.oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Colors.lua code!")
	return
end

oUF.colors.fallback = { 1, 1, 0.8 }

oUF.colors.castbar = {
	CastingColor = { 1.0, 0.7, 0.0 },
	ChannelingColor = { 0.0, 1.0, 0.0 },
	notInterruptibleColor = { 0.7, 0.7, 0.7 },
	CompleteColor = { 0.0, 1.0, 0.0 },
	FailColor = { 1.0, 0.0, 0.0 },
}

-- Aura Coloring
oUF.colors.debuff = {
	none = { 204 / 255, 0 / 255, 0 / 255 },
	Magic = { 51 / 255, 153 / 255, 255 / 255 },
	Curse = { 204 / 255, 0 / 255, 255 / 255 },
	Disease = { 153 / 255, 102 / 255, 0 / 255 },
	Poison = { 0 / 255, 153 / 255, 0 / 255 },
	[""] = { 0 / 255, 0 / 255, 0 / 255 },
}

oUF.colors.reaction = {
	[1] = { 0.87, 0.37, 0.37 }, -- Hated
	[2] = { 0.87, 0.37, 0.37 }, -- Hostile
	[3] = { 0.87, 0.37, 0.37 }, -- Unfriendly
	[4] = { 0.85, 0.77, 0.36 }, -- Neutral
	[5] = { 0.29, 0.67, 0.30 }, -- Friendly
	[6] = { 0.29, 0.67, 0.30 }, -- Honored
	[7] = { 0.29, 0.67, 0.30 }, -- Revered
	[8] = { 0.29, 0.67, 0.30 }, -- Exalted
}

oUF.colors.selection = {
	[0] = { 255 / 255, 0 / 255, 0 / 255 }, -- Hostile
	[1] = { 255 / 255, 129 / 255, 0 / 255 }, -- Unfriendly
	[2] = { 255 / 255, 255 / 255, 0 / 255 }, -- Neutral
	[3] = { 0 / 255, 255 / 255, 0 / 255 }, -- Friendly
	[4] = { 0 / 255, 0 / 255, 255 / 255 }, -- Player Simple
	[5] = { 96 / 255, 96 / 255, 255 / 255 }, -- Player Extended
	[6] = { 170 / 255, 170 / 255, 255 / 255 }, -- Party
	[7] = { 170 / 255, 255 / 255, 170 / 255 }, -- Party PvP
	[8] = { 83 / 255, 201 / 255, 255 / 255 }, -- Friend
	[9] = { 128 / 255, 128 / 255, 128 / 255 }, -- Dead
	[12] = { 255 / 255, 255 / 255, 139 / 255 }, -- Self, buggy
	[13] = { 0 / 255, 153 / 255, 0 / 255 }, -- Battleground Friendly PvP
}

oUF.colors.power = {
	["ALTPOWER"] = { 0.00, 1.00, 1.00 },
	["AMMOSLOT"] = { 0.80, 0.60, 0.00 },
	["ARCANE_CHARGES"] = { 0.41, 0.8, 0.94 },
	["CHI"] = { 0.71, 1.00, 0.92 },
	["COMBO_POINTS"] = { 0.69, 0.31, 0.31 },
	["ENERGY"] = { 0.65, 0.63, 0.35 },
	["FOCUS"] = { 0.71, 0.43, 0.27 },
	["FUEL"] = { 0.00, 0.55, 0.50 },
	["FURY"] = { 0.78, 0.26, 0.99 },
	["HOLY_POWER"] = { 0.95, 0.90, 0.60 },
	["INSANITY"] = { 0.40, 0.00, 0.80 },
	["LUNAR_POWER"] = { 0.93, 0.51, 0.93 },
	["MAELSTROM"] = { 0.00, 0.50, 1.00 },
	["MANA"] = { 0.31, 0.45, 0.63 },
	["PAIN"] = { 1.00, 0.61, 0.00 },
	["POWER_TYPE_PYRITE"] = { 0.60, 0.09, 0.17 },
	["POWER_TYPE_STEAM"] = { 0.55, 0.57, 0.61 },
	["RAGE"] = { 0.78, 0.25, 0.25 },
	["RUNES"] = { 0.55, 0.57, 0.61 },
	["RUNIC_POWER"] = { 0, 0.82, 1 },
	["SOUL_SHARDS"] = { 0.50, 0.32, 0.55 },
	["UNUSED"] = { 195 / 255, 202 / 255, 217 / 255 },
}

oUF.colors.class = {
	["DEATHKNIGHT"] = { 0.77, 0.12, 0.24 },
	["DRUID"] = { 1.00, 0.49, 0.03 },
	["HUNTER"] = { 0.67, 0.84, 0.45 },
	["MAGE"] = { 0.41, 0.80, 1.00 },
	["PALADIN"] = { 0.96, 0.55, 0.73 },
	["PRIEST"] = { 0.86, 0.92, 0.98 },
	["ROGUE"] = { 1.00, 0.95, 0.32 },
	["SHAMAN"] = { 0.16, 0.31, 0.61 },
	["WARLOCK"] = { 0.58, 0.51, 0.79 },
	["WARRIOR"] = { 0.78, 0.61, 0.43 },
	["UNKNOWN"] = { 0.76, 0.79, 0.85 },
}

K["Colors"] = oUF.colors
