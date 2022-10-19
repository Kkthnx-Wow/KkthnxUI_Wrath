local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Auras")

local _G = _G
local next = _G.next
local pairs = _G.pairs
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local GetSpellTexture = _G.GetSpellTexture
local GetZonePVPInfo = _G.GetZonePVPInfo
local InCombatLockdown = _G.InCombatLockdown
local IsInInstance = _G.IsInInstance
local IsPlayerSpell = _G.IsPlayerSpell
local UIParent = _G.UIParent
local UnitBuff = _G.UnitBuff
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost

local groups = C.SpellReminderBuffs[K.Class]
local iconSize = 36
local frames = {}
local parentFrame

function Module:Reminder_ConvertToName(cfg)
	local cache = {}
	for spellID in pairs(cfg.spells) do
		local name = GetSpellInfo(spellID)
		if name then
			cache[name] = true
		end
	end

	for name in pairs(cache) do
		cfg.spells[name] = true
	end
end

function Module:Reminder_CheckMeleeSpell()
	for _, cfg in pairs(groups) do
		local depends = cfg.depends
		if depends then
			for _, spellID in pairs(depends) do
				if IsPlayerSpell(spellID) then
					cfg.dependsKnown = true
					break
				end
			end
		end
	end
end

function Module:Reminder_Update(cfg)
	local frame = cfg.frame
	local depend = cfg.depend
	local depends = cfg.depends
	local combat = cfg.combat
	local instance = cfg.instance
	local pvp = cfg.pvp
	local isPlayerSpell = true
	local isInCombat
	local isInInst
	local isInPVP
	local inInst, instType = IsInInstance()

	if depend and not IsPlayerSpell(depend) then
		isPlayerSpell = false
	end

	if depends and not cfg.dependsKnown then
		isPlayerSpell = false
	end

	if combat and InCombatLockdown() then
		isInCombat = true
	end

	if instance and inInst and (instType == "scenario" or instType == "party" or instType == "raid") then
		isInInst = true
	end

	if pvp and (instType == "arena" or instType == "pvp" or GetZonePVPInfo() == "combat") then
		isInPVP = true
	end

	if not combat and not instance and not pvp then
		isInCombat, isInInst, isInPVP = true, true, true
	end

	frame:Hide()
	if isPlayerSpell and (isInCombat or isInInst or isInPVP) and not UnitIsDeadOrGhost("player") then
		for i = 1, 32 do
			local name, _, _, _, _, _, caster = UnitBuff("player", i)
			if not name then
				break
			end

			if name and (cfg.spells[name] or cfg.gemini and cfg.gemini[name] and caster == "player") then
				frame:Hide()
				return
			end
		end

		frame:Show()
	end
end

function Module:Reminder_Create(cfg)
	local frame = CreateFrame("Frame", nil, parentFrame)
	frame:SetSize(iconSize, iconSize)

	frame.Icon = frame:CreateTexture(nil, "ARTWORK")
	frame.Icon:SetAllPoints()
	frame.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	if cfg.texture then
		frame.Icon:SetTexture(cfg.texture)
	else
		for spell in pairs(cfg.spells) do
			frame.Icon:SetTexture(GetSpellTexture(spell))
			break
		end
	end
	frame:CreateBorder()

	frame.text = frame:CreateFontString(nil, "OVERLAY")
	frame.text:SetFontObject(K.UIFontOutline)
	frame.text:SetText(L["Lack"])
	frame.text:SetPoint("TOP", frame, "TOP", 1, 15)

	frame:Hide()
	cfg.frame = frame

	table_insert(frames, frame)
end

function Module:Reminder_UpdateAnchor()
	local index = 0
	local offset = iconSize + 6
	for _, frame in next, frames do
		if frame:IsShown() then
			frame:SetPoint("LEFT", offset * index, 0)
			index = index + 1
		end
	end

	parentFrame:SetWidth(offset * index)
end

function Module:Reminder_OnEvent()
	for _, cfg in pairs(groups) do
		if not cfg.frame then
			Module:Reminder_Create(cfg)
			Module:Reminder_ConvertToName(cfg)
		end
		Module:Reminder_Update(cfg)
	end

	Module:Reminder_UpdateAnchor()
end

function Module:CreateReminder()
	if not groups then
		return
	end

	if C["Auras"].Reminder then
		if not parentFrame then
			parentFrame = CreateFrame("Frame", nil, UIParent)
			parentFrame:SetPoint("CENTER", -220, 130)
			parentFrame:SetSize(iconSize, iconSize)
		end
		parentFrame:Show()

		Module:Reminder_CheckMeleeSpell()
		K:RegisterEvent("LEARNED_SPELL_IN_TAB", Module.Reminder_CheckMeleeSpell)

		Module:Reminder_OnEvent()
		K:RegisterEvent("UNIT_AURA", Module.Reminder_OnEvent, "player")
		K:RegisterEvent("PLAYER_REGEN_ENABLED", Module.Reminder_OnEvent)
		K:RegisterEvent("PLAYER_REGEN_DISABLED", Module.Reminder_OnEvent)
		K:RegisterEvent("ZONE_CHANGED_NEW_AREA", Module.Reminder_OnEvent)
		K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.Reminder_OnEvent)
	else
		if parentFrame then
			parentFrame:Hide()
			K:UnregisterEvent("LEARNED_SPELL_IN_TAB", Module.Reminder_CheckMeleeSpell)
			K:UnregisterEvent("UNIT_AURA", Module.Reminder_OnEvent)
			K:UnregisterEvent("PLAYER_REGEN_ENABLED", Module.Reminder_OnEvent)
			K:UnregisterEvent("PLAYER_REGEN_DISABLED", Module.Reminder_OnEvent)
			K:UnregisterEvent("ZONE_CHANGED_NEW_AREA", Module.Reminder_OnEvent)
			K:UnregisterEvent("PLAYER_ENTERING_WORLD", Module.Reminder_OnEvent)
		end
	end
end
