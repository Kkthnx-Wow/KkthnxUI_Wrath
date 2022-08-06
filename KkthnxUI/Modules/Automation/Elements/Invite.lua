local K, C = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local _G = _G

local AcceptGroup = _G.AcceptGroup
local BNGetGameAccountInfoByGUID = _G.BNGetGameAccountInfoByGUID
local C_FriendList_IsFriend = _G.C_FriendList.IsFriend
local IsGuildMember = _G.IsGuildMember
local StaticPopup_Hide = _G.StaticPopup_Hide

function Module.AutoInvite(event, _, _, _, _, _, _, inviterGUID)
	if event == "PARTY_INVITE_REQUEST" then
		if BNGetGameAccountInfoByGUID(inviterGUID) or C_FriendList_IsFriend(inviterGUID) or IsGuildMember(inviterGUID) then
			AcceptGroup()
			_G.StaticPopupDialogs.PARTY_INVITE.inviteAccepted = 1
			StaticPopup_Hide("PARTY_INVITE")
		end
	end

end

function Module:CreateAutoInvite()
	if C["Automation"].AutoInvite then
		K:RegisterEvent("PARTY_INVITE_REQUEST", Module.AutoInvite)
		K:RegisterEvent("GROUP_ROSTER_UPDATE", Module.AutoInvite)
	else
		K:UnregisterEvent("PARTY_INVITE_REQUEST", Module.AutoInvite)
		K:UnregisterEvent("GROUP_ROSTER_UPDATE", Module.AutoInvite)
	end
end