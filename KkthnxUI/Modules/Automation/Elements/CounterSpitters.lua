local K, C = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local SpitterEmotes = {
	"BONK",
	"CHUCKLE",
	"FLEX",
	"PITY",
	"SLAP",
	"VIOLIN",
}

local function SetupCounterSpitters(_, _, msg, spitter)
	if string.find(msg, "spits on you") then
		DoEmote(SpitterEmotes[math.random(1, #SpitterEmotes)], spitter)
	end
end

function Module:CreateCounterSpitters()
    if not C["Automation"].CounterSpitters then
        return
    end

    ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", SetupCounterSpitters)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", SetupCounterSpitters)
end