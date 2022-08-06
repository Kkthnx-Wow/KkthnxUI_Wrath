local K, C = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local _G = _G

local CancelDuel = _G.CancelDuel
local StaticPopup_Hide = _G.StaticPopup_Hide

function Module:DUEL_REQUESTED()
	CancelDuel()
	StaticPopup_Hide("DUEL_REQUESTED")
end

function Module:CreateAutoDeclineDuels()
	if C["Automation"].AutoDeclineDuels then
		K:RegisterEvent("DUEL_REQUESTED", Module.DUEL_REQUESTED)
	else
		K:UnregisterEvent("DUEL_REQUESTED", Module.DUEL_REQUESTED)
	end
end