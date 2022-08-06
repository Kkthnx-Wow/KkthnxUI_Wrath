local K = unpack(select(2, ...))
local oUF = oUF or K.oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Colors.lua code!")
	return
end

oUF.colors.castbar = {
	CastingColor = { 1.0, 0.7, 0.0 },
	ChannelingColor = { 0.0, 1.0, 0.0 },
	notInterruptibleColor = { 0.7, 0.7, 0.7 },
	CompleteColor = { 0.0, 1.0, 0.0 },
	FailColor = { 1.0, 0.0, 0.0 },
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

oUF.colors.power = {
	["ALTPOWER"] = { 0.00, 1.00, 1.00 },
	["AMMOSLOT"] = { 0.80, 0.60, 0.00 },
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
	["STAGGER"] = {
		{ 132 / 255, 255 / 255, 132 / 255 },
		{ 255 / 255, 250 / 255, 183 / 255 },
		{ 255 / 255, 107 / 255, 107 / 255 },
	},
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
}

oUF.colors.selection = {
	-- these colours are sorted by r, then by g, then by b
	-- very light yellow, used for player's character while in combat
	[1] = { 0.89, 0.83, 0.54 },
	-- yellow, used for neutral units
	[2] = { 0.85, 0.77, 0.36 },
	-- orange, used for non-interactive unfriendly units
	[3] = { 0.90, 0.53, 0.26 },
	-- red, used for hostile units
	[4] = { 0.87, 0.37, 0.37 },
	-- grey, used for dead units
	[5] = { 0.7, 0.7, 0.7 },
	-- green, used for friendly units
	[6] = { 0.29, 0.67, 0.30 },
	-- blue, the default colour, also used for friendly player names in dungeons, sanctuaries, unattackable
	[7] = { 0.31, 0.45, 0.63 },
}

function oUF:UnitSelectionColor(unit)
	local r, g, b = UnitSelectionColor(unit)
	r = r * 255 + 0.5 - (r * 255 + 0.5) % 1
	g = g * 255 + 0.5 - (g * 255 + 0.5) % 1
	b = b * 255 + 0.5 - (b * 255 + 0.5) % 1
	local color
	if r == 255 and g == 255 and b == 139 then
		color = oUF.colors.selection[1]
	elseif r == 255 and g == 255 and b == 0 then
		color = oUF.colors.selection[2]
	elseif r == 255 and g == 129 and b == 0 then
		color = oUF.colors.selection[3]
	elseif r == 255 and g == 0 and b == 0 then
		color = oUF.colors.selection[4]
	elseif r == 128 and g == 128 and b == 128 then
		color = oUF.colors.selection[5]
	elseif r == 0 and g == 255 and b == 0 then
		color = oUF.colors.selection[6]
	elseif r == 0 and g == 0 and b == 255 then
		color = oUF.colors.selection[7]
	else
		print("|cffffd200Unknown colour:|r", r, g, b)
		color = oUF.colors.selection[7]
	end
	return color[1], color[2], color[3]
end

oUF.colors.happiness = {
	[1] = { 0.69, 0.31, 0.31 },
	[2] = { 0.65, 0.63, 0.35 },
	[3] = { 0.33, 0.59, 0.33 },
}

K["Colors"] = oUF.colors
