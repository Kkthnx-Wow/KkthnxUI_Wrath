local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Announcements")

local _G = _G
local string_format = _G.string.format

local GetSpellInfo = _G.GetSpellInfo
local GetSpellLink = _G.GetSpellLink
local GetTime = _G.GetTime
local IsInGroup = _G.IsInGroup
local SendChatMessage = _G.SendChatMessage
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid
local UnitName = _G.UnitName

local lastTime = 0
local itemList = {
	[13379] = true, -- Piccolo of the Flaming Fire
	[17512] = true, -- Piccolo of the Flaming Fire
	[18232] = true, -- Field Repair Bot 74A
	[18400] = true, -- Piccolo of the Flaming Fire
	[22700] = true, -- Field Repair Bot 74A
	[29893] = true, -- Ritual of Souls
	[43987] = true, -- Ritual of Refreshment
	[44389] = true, -- Field Repair Bot 110G
	[49844] = true, -- Direbrew's Remote
	[51508] = true, -- Party G.R.E.N.A.D.E.
	[51510] = true, -- Party G.R.E.N.A.D.E.
	[698] = true, -- Ritual of Summoning
	-- Alliance
	[10059] = true, -- Stormwind
	[11416] = true, -- Ironforge
	[11419] = true, -- Darnassus
	[32266] = true, -- Exodar
	[33691] = true, -- Shattrath
	[49360] = true, -- Theramore
	-- Horde
	[11417] = true, -- Orgrimmar
	[11418] = true, -- Undercity
	[11420] = true, -- Thunder Bluff
	[32267] = true, -- Silvermoon
	[35717] = true, -- Shattrath
	[49361] = true, -- Stonard
	-- Alliance/Horde
	[28148] = true, -- Karazhan
}

function Module:ItemAlert_Update(unit, _, spellID)
	if (UnitInRaid(unit) or UnitInParty(unit)) and spellID and itemList[spellID] and lastTime ~= GetTime() then
		local who = UnitName(unit)
		local link = GetSpellLink(spellID)
		local name = GetSpellInfo(spellID)
		SendChatMessage(string_format(L["Item Placed"], who, link or name), K.CheckChat())

		lastTime = GetTime()
	end
end

function Module:ItemAlert_CheckGroup()
	if IsInGroup() then
		K:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.ItemAlert_Update)
	else
		K:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.ItemAlert_Update)
	end
end

function Module:PlacedItemAlert()
	Module:ItemAlert_CheckGroup()
	K:RegisterEvent("GROUP_LEFT", Module.ItemAlert_CheckGroup)
	K:RegisterEvent("GROUP_JOINED", Module.ItemAlert_CheckGroup)
end

function Module:CreateItemAnnounce()
	if not C["Announcements"].ItemAlert then
		return
	end

	Module:PlacedItemAlert()
end