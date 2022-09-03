local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Chat")

local _G = _G
local table_insert = _G.table.insert
local table_remove = _G.table.remove
local time = _G.time
local unpack = _G.unpack

local ChatFrame1 = _G.ChatFrame1
local ChatFrame_MessageEventHandler = _G.ChatFrame_MessageEventHandler

local EntryEvent = 30
local EntryTime = 31
local LogMax
local Events = {
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_EMOTE",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_GUILD_ACHIEVEMENT",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_SAY",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_YELL",
}

function Module:PrintChatHistory()
	local Temp

	Module.IsPrinting = true

	for i = #KkthnxUIDB.ChatHistory, 1, -1 do
		Temp = KkthnxUIDB.ChatHistory[i]

		ChatFrame_MessageEventHandler(ChatFrame1, Temp[EntryEvent], unpack(Temp))
	end

	Module.IsPrinting = false
	Module.HasPrinted = true
end

function Module:SaveChatHistory(event, ...)
	local Temp = { ... }

	if Temp[1] then
		Temp[EntryEvent] = event
		Temp[EntryTime] = time()

		table_insert(KkthnxUIDB.ChatHistory, 1, Temp)

		for _ = LogMax, #KkthnxUIDB.ChatHistory do
			table_remove(KkthnxUIDB.ChatHistory, LogMax)
		end
	end
end

function Module:SetupChatHistory(event, ...)
	if Module.HasPrinted then
		Module:SaveChatHistory(event, ...)
	end
end

function Module:CreateChatHistory()
	-- Disable if we don't want any lines
	if C["Chat"].LogMax == 0 then
		return
	end

	-- This is the global table where we save chat
	KkthnxUIDB.ChatHistory = type(KkthnxUIDB.ChatHistory) == "table" and KkthnxUIDB.ChatHistory or {}

	-- Max number of entries logged
	LogMax = C["Chat"].LogMax

	for i = 1, #Events do
		K:RegisterEvent(Events[i], Module.SetupChatHistory)
	end

	Module:PrintChatHistory()
end
