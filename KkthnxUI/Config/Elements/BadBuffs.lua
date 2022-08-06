local K, C = unpack(select(2, ...))

local _G = _G

local GetSpellInfo = _G.GetSpellInfo

local function SpellName(id)
	local name = GetSpellInfo(id)
	if name then
		return name
	else
		K.Print("|cffff0000WARNING: [BadBuffsFilter] - spell ID ["..tostring(id).."] no longer exists! Report this to Kkthnx.|r")
		return "Empty"
	end
end

C.CheckBadBuffs = {
	[SpellName(44212)] = true,	-- Jack-o'-Lanterned!
	[SpellName(24732)] = true,	-- Bat Costume
	[SpellName(24735)] = true,	-- Ghost Costume
	[SpellName(24712)] = true,	-- Leper Gnome Costume
	[SpellName(24710)] = true,	-- Ninja Costume
	[SpellName(24709)] = true,	-- Pirate Costume
	[SpellName(24723)] = true,	-- Skeleton Costume
	[SpellName(24740)] = true,	-- Wisp Costume
}