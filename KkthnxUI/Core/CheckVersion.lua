local K, C = unpack(select(2, ...))
local Module = K:NewModule("VersionCheck")

-- Sourced: NDui (siweia)
-- Edited: KkthnxUI (Kkthnx)

local _G = _G
-- local string_format = _G.string.format
local string_gsub = _G.string.gsub
local string_split = _G.string.split

local Ambiguate = _G.Ambiguate
local C_ChatInfo_RegisterAddonMessagePrefix = _G.C_ChatInfo.RegisterAddonMessagePrefix
local C_ChatInfo_SendAddonMessage = _G.C_ChatInfo.SendAddonMessage
local GetTime = _G.GetTime
local IsInGroup = _G.IsInGroup
local IsInGuild = _G.IsInGuild

function Module:VersionCheck_Compare(new, old)
	local new1, new2 = string_split(".", new)
	new1, new2 = tonumber(new1), tonumber(new2)
	if new1 > 10 then
		new1, new2 = 0, 0
	end

	local old1, old2 = string_split(".", old)
	old1, old2 = tonumber(old1), tonumber(old2)
	if old1 > 10 then
		old1, old2 = 0, 0
 	end

	if new1 > old1 or (new1 == old1 and new2 > old2) then
		return "IsNew"
	elseif new1 < old1 or (new1 == old1 and new2 < old2) then
		return "IsOld"
	end
end

local hasChecked
function Module:VersionCheck_Initial()
	if not hasChecked then
		if Module:VersionCheck_Compare(KkthnxUIDB.Variables[K.Realm][K.Name].DetectVersion, K.Version) == "IsNew" then
			local release = string_gsub(KkthnxUIDB.Variables[K.Realm][K.Name].DetectVersion, "(%d+)$", "0")
			-- K.ShowHelpTip(ChatFrame1, string_format("|cff669dffKkthnxUI|r is out of date, the latest release is |cff70C0F5%s|r", release), "TOP", 0, 70, nil, "Version")
			K.Print("|cff669dffKkthnxUI|r is out of date, the latest release is |cff70C0F5%s|r", release)
		end

		hasChecked = true
	end
end

local lastTime = 0
function Module:VersionCheck_Update(...)
	local prefix, msg, distType, author = ...
	if prefix ~= "KKUI_VersionCheck" then
		return
	end

	if Ambiguate(author, "none") == K.Name then
		return
	end

	local status = Module:VersionCheck_Compare(msg, KkthnxUIDB.Variables[K.Realm][K.Name].DetectVersion)
	if status == "IsNew" then
		KkthnxUIDB.Variables[K.Realm][K.Name].DetectVersion = msg
	elseif status == "IsOld" then
		if GetTime() - lastTime > 10 then
			C_ChatInfo_SendAddonMessage("KKUI_VersionCheck", KkthnxUIDB.Variables[K.Realm][K.Name].DetectVersion, distType)
			lastTime = GetTime()
		end
	end

	Module:VersionCheck_Initial()
end

local prevTime = 0
function Module:VersionCheck_UpdateGroup()
	if not IsInGroup() or (GetTime() - prevTime < 30) then
		return
	end

	prevTime = GetTime()
	C_ChatInfo_SendAddonMessage("KKUI_VersionCheck", K.Version, IsInRaid() and "RAID" or "PARTY")
end

function Module:OnEnable()
	hasChecked = not C["General"].VersionCheck

	K:RegisterEvent("CHAT_MSG_ADDON", self.VersionCheck_Update)

	Module:VersionCheck_Initial()
	C_ChatInfo_RegisterAddonMessagePrefix("KKUI_VersionCheck")
	if IsInGuild() then
		C_ChatInfo_SendAddonMessage("KKUI_VersionCheck", K.Version, "GUILD")
	end

	self:VersionCheck_UpdateGroup()
	K:RegisterEvent("GROUP_ROSTER_UPDATE", self.VersionCheck_UpdateGroup)
end