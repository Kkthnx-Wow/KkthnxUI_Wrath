local K, C = unpack(select(2, ...))
local Module = K:GetModule("Announcements")

local _G = _G
local bit_band = _G.bit.band
local math_random = _G.math.random

local CombatLogGetCurrentEventInfo = _G.CombatLogGetCurrentEventInfo
local DoEmote = _G.DoEmote

local pvpEmoteList = {
	"ANGRY", "BARK", "BITE", "BONK", "BURP", "BYE", "CACKLE",
	"CALM", "CHUCKLE", "COMFORT", "CRACK", "CUDDLE", "CURTSEY", "FLEX",
	"GIGGLE", "GLOAT", "GRIN", "GROWL", "GUFFAW", "INSULT",
	"LAUGH", "LICK", "MOCK", "MOO", "MOON", "MOURN",
	"NO", "NOSEPICK", "PITY", "RASP", "ROAR", "ROFL", "RUDE",
	"SCRATCH", "SHOO", "SIGH", "SLAP", "SMIRK", "SNARL",
	"SNICKER", "SNIFF", "SNUB", "SOOTHE", "TAP", "TAUNT",
	"TEASE", "THANK", "THREATEN", "TICKLE", "VETO", "VIOLIN", "YAWN"
}

function Module:SetupKillingBlow()
	local _, subevent, _, _, Caster, _, _, _, TargetName, TargetFlags = CombatLogGetCurrentEventInfo()
	if subevent == "PARTY_KILL" then
		local mask = bit_band(TargetFlags, COMBATLOG_OBJECT_TYPE_PLAYER) -- Don't ask me, it's some dark magic. If bit mask for this is positive, it means a player was killed
		if Caster == K.Name and (mask > 0) then -- If this is my kill and target is a player (world)
			C_Timer.After(0.5, function()
				DoEmote(pvpEmoteList[math_random(1, #pvpEmoteList)], TargetName)
				PlaySoundFile("Interface\\AddOns\\KkthnxUI\\Media\\Sounds\\KillingBlow.ogg", "Master")
			end)
		end
	end
end

function Module:CreateKillingBlow()
	if not C["Announcements"].PvPEmote then
		return
	end

	K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.SetupKillingBlow)
end