local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Automation")

local _G = _G
local string_lower = string.lower

local BNInviteFriend = _G.BNInviteFriend
local C_BattleNet_GetAccountInfoByID = _G.C_BattleNet.GetAccountInfoByID
local CanCooperateWithGameAccount = _G.CanCooperateWithGameAccount
local InviteUnit = _G.InviteUnit
local IsInGroup = _G.IsInGroup
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local UnitIsGroupLeader = _G.UnitIsGroupLeader

function Module.SetupWhisperInvite(event, ...)
	local msg, author, _, _, _, _, _, _, _, _, _, _, presenceID = ...
	if (not IsInGroup() or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and string_lower(msg) == string_lower(C["Automation"].WhisperInvite) then
		if event == "CHAT_MSG_WHISPER" then
			InviteUnit(author)
		elseif event == "CHAT_MSG_BN_WHISPER" then
			local accountInfo = C_BattleNet_GetAccountInfoByID(presenceID)
			if accountInfo then
				local gameAccountInfo = accountInfo.gameAccountInfo
				local gameID = gameAccountInfo.gameAccountID
				if gameID then
					if CanCooperateWithGameAccount(accountInfo) then
						BNInviteFriend(gameID)
					end
				end
			end
		end
	end
end

function Module:CreateAutoWhisperInvite()
	K:RegisterEvent("CHAT_MSG_WHISPER", self.SetupWhisperInvite)
	K:RegisterEvent("CHAT_MSG_BN_WHISPER", self.SetupWhisperInvite)
end
