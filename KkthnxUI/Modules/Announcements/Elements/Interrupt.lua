local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Announcements")

local _G = _G
local string_format = _G.string.format

local GetSpellLink = _G.GetSpellLink
local IsInGroup = _G.IsInGroup
local IsInInstance = _G.IsInInstance
local IsInRaid = _G.IsInRaid
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid
local AURA_TYPE_BUFF = _G.AURA_TYPE_BUFF

local function msgChannel()
	local inInstance, inRaid = IsInRaid(), IsInInstance()
	local Value = C["Announcements"].InterruptChannel.Value
	if Value == 1 then
		return "PARTY"
	elseif Value == 2 then
		return inRaid and "RAID" or "PARTY"
	elseif Value == 3 and inRaid then
		return "RAID"
	elseif Value == 4 and inInstance then
		return "SAY"
	elseif Value == 5 and inInstance then
		return "YELL"
	elseif Value == 6 then
		return "EMOTE"
	end
end

local infoType = {
	["SPELL_AURA_BROKEN_SPELL"] = L["BrokenSpell"],
	-- ["SPELL_DISPEL"] = L["Dispel"],
	["SPELL_INTERRUPT"] = L["Interrupt"],
	["SPELL_STOLEN"] = L["Steal"],
}

local blackList = {
	[122] = true, -- Frost Nova
	[1776] = true, -- Gouge
	[1784] = true, -- Stealth
	[31661] = true, -- Dragon's Breath
	[33395] = true, -- Freeze
	[5246] = true, -- Intimidating Shout
	[8122] = true, -- Psychic Scream
	[99] = true, -- Demoralizing Roar
}

function Module:IsAllyPet(sourceFlags)
	if K.IsMyPet(sourceFlags) or (not C["Announcements"].OwnInterrupt and (sourceFlags == K.PartyPetFlags or sourceFlags == K.RaidPetFlags)) then
		return true
	end
end

function Module:InterruptAlert_Update(...)
	if C["Announcements"].AlertInInstance and (not IsInInstance()) then
		return
	end

	local _, eventType, _, sourceGUID, sourceName, sourceFlags, _, _, destName, _, _, spellID, _, _, extraskillID, _, _, auraType = ...
	if not sourceGUID or sourceName == destName then
		return
	end

	if UnitInRaid(sourceName) or UnitInParty(sourceName) or Module:IsAllyPet(sourceFlags) then
		local infoText = infoType[eventType]
		if infoText then
			if infoText == L["BrokenSpell"] then
				if not C["Announcements"].BrokenSpell then
					return
				end

				if auraType and auraType == AURA_TYPE_BUFF or blackList[spellID] then
					return
				end
				SendChatMessage(string_format(infoText, sourceName, destName, GetSpellLink(extraskillID)), msgChannel())
			else
				if C["Announcements"].OwnInterrupt and sourceName ~= K.Name and not Module:IsAllyPet(sourceFlags) then
					return
				end
				SendChatMessage(string_format(infoText, destName, GetSpellLink(extraskillID)), msgChannel())
			end
		end
	end
end

function Module:InterruptAlert_CheckGroup()
	if IsInGroup() then
		K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.InterruptAlert_Update)
	else
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.InterruptAlert_Update)
	end
end

function Module:CreateInterruptAnnounce()
	if C["Announcements"].Interrupt then
		self:InterruptAlert_CheckGroup()
		K:RegisterEvent("GROUP_LEFT", self.InterruptAlert_CheckGroup)
		K:RegisterEvent("GROUP_JOINED", self.InterruptAlert_CheckGroup)
	else
		K:UnregisterEvent("GROUP_LEFT", self.InterruptAlert_CheckGroup)
		K:UnregisterEvent("GROUP_JOINED", self.InterruptAlert_CheckGroup)
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.InterruptAlert_Update)
	end
end