local K = unpack(KkthnxUI)
local Module = K:GetModule("Auras")

if K.Class ~= "HUNTER" then
	return
end

local CreateFrame = _G.CreateFrame
local GetSpecialization = _G.GetSpecialization
local IsPlayerSpell = _G.IsPlayerSpell
local GetSpellTexture = _G.GetSpellTexture
local IsEquippedItem = _G.IsEquippedItem

local GetSpellCost = {
	[53351] = 10, -- 杀戮射击
	[19434] = 35, -- 瞄准射击
	[185358] = 20, -- 奥术射击
	[257620] = 20, -- 多重射击
	[271788] = 10, -- 毒蛇钉刺
	[212431] = 20, -- 爆炸射击
	[186387] = 10, -- 爆裂射击
	[157863] = 35, -- 复活宠物
	[131894] = 20, -- 夺命黑鸦
	[120360] = 30, -- 弹幕射击
	[342049] = 20, -- 奇美拉射击
	[355589] = 15, -- 哀痛箭
}

function Module:UpdateFocusCost(unit, _, spellID)
	if unit ~= "player" then
		return
	end

	local focusCal = Module.MMFocus
	local cost = GetSpellCost[spellID]
	if cost then
		focusCal.cost = focusCal.cost + cost
	end
	if spellID == 19434 then
		--print("带着技巧读条："..tostring(focusCal.isTrickCast), "消耗技巧层数："..focusCal.trickActive)
		if (focusCal.isTrickCast and focusCal.trickActive == 1) or (not focusCal.isTrickCast and focusCal.trickActive == 0) then
			focusCal.cost = 35
			--print("此时重置集中值为35")
		end
	end
	focusCal:SetFormattedText("%d/40", focusCal.cost % 40)
end

function Module:ResetFocusCost()
	Module.MMFocus.cost = 0
	Module.MMFocus:SetFormattedText("%d/40", Module.MMFocus.cost % 40)
end

function Module:ResetOnRaidEncounter(_, _, _, groupSize)
	if groupSize and groupSize > 5 then
		Module:ResetFocusCost()
	end
end

local eventSpentIndex = {
	["SPELL_AURA_APPLIED"] = 1,
	["SPELL_AURA_REFRESH"] = 2,
	["SPELL_AURA_REMOVED"] = 0,
}

function Module:CheckTrickState(...)
	local _, eventType, _, sourceGUID, _, _, _, _, _, _, _, spellID = ...
	if eventSpentIndex[eventType] and spellID == 257622 and sourceGUID == K.GUID then
		Module.MMFocus.trickActive = eventSpentIndex[eventType]
	end
end

function Module:StartAimedShot(unit, _, spellID)
	if unit ~= "player" then
		return
	end
	if spellID == 19434 then
		Module.MMFocus.isTrickCast = Module.MMFocus.trickActive ~= 0
	end
end

local hunterSets = { 188856, 188858, 188859, 188860, 188861 }

function Module:CheckSetsCount()
	local count = 0
	for _, itemID in pairs(hunterSets) do
		if IsEquippedItem(itemID) then
			count = count + 1
		end
	end

	if count < 4 then
		Module.MMFocus:Hide()
		K:UnregisterEvent("UNIT_SPELLCAST_START", Module.StartAimedShot)
		K:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.UpdateFocusCost)
		K:UnregisterEvent("PLAYER_DEAD", Module.ResetFocusCost)
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", Module.ResetFocusCost)
		K:UnregisterEvent("ENCOUNTER_START", Module.ResetOnRaidEncounter)
		K:UnregisterEvent("CLEU", Module.CheckTrickState)
	else
		Module.MMFocus:Show()
		K:RegisterEvent("UNIT_SPELLCAST_START", Module.StartAimedShot, "player")
		K:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.UpdateFocusCost, "player")
		K:RegisterEvent("PLAYER_DEAD", Module.ResetFocusCost)
		K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.ResetFocusCost)
		K:RegisterEvent("ENCOUNTER_START", Module.ResetOnRaidEncounter)
		K:RegisterEvent("CLEU", Module.CheckTrickState)
	end
end

local oldSpec
function Module:ToggleFocusCalculation()
	if not Module.MMFocus then
		return
	end

	local spec = GetSpecialization()
	-- if C["Auras"].MMT29X4 and spec == 2 then
	if spec == 2 then
		if self ~= "PLAYER_SPECIALIZATION_CHANGED" or spec ~= oldSpec then -- don't reset when talent changed only
			Module:ResetFocusCost() -- reset calculation when switch on
		end
		Module.MMFocus:Show()
		Module:CheckSetsCount()
		K:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", Module.CheckSetsCount)
	else
		K:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED", Module.CheckSetsCount)
	end
	oldSpec = spec
end

function Module:PostCreateLumos(self)
	local iconSize = self.lumos[1]:GetWidth()
	local boom = CreateFrame("Frame", nil, self.Health)
	boom:SetSize(iconSize, iconSize)
	boom:SetPoint("BOTTOM", self.Health, "TOP", 0, 5)

	boom.CD = CreateFrame("Cooldown", nil, boom, "CooldownFrameTemplate")
	boom.CD:SetAllPoints()
	boom.CD:SetReverse(true)

	boom.Icon = boom:CreateTexture(nil, "ARTWORK")
	boom.Icon:SetAllPoints()
	boom.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	boom:CreateShadow()

	boom:Hide()

	self.boom = boom

	-- MM hunter T29 4sets
	Module.MMFocus = K.CreateFontString(self.Health, 16)
	Module.MMFocus:ClearAllPoints()
	Module.MMFocus:SetPoint("BOTTOM", self.Health, "TOP", 0, 5)
	Module.MMFocus.trickActive = 0
	Module:ToggleFocusCalculation()
	K:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", Module.ToggleFocusCalculation)
end

function Module:PostUpdateVisibility(self)
	if self.boom then
		self.boom:Hide()
	end
end

local function GetUnitAura(unit, spell, filter)
	return Module:GetUnitAura(unit, spell, filter)
end

local function UpdateCooldown(button, spellID, texture)
	return Module:UpdateCooldown(button, spellID, texture)
end

local function UpdateBuff(button, spellID, auraID, cooldown, isPet, glow)
	return Module:UpdateAura(button, isPet and "pet" or "player", auraID, "HELPFUL", spellID, cooldown, glow)
end

local function UpdateDebuff(button, spellID, auraID, cooldown, glow)
	return Module:UpdateAura(button, "target", auraID, "HARMFUL", spellID, cooldown, glow)
end

local function UpdateSpellStatus(button, spellID)
	button.Icon:SetTexture(GetSpellTexture(spellID))
	if IsUsableSpell(spellID) then
		button.Icon:SetDesaturated(false)
	else
		button.Icon:SetDesaturated(true)
	end
end

local boomGroups = {
	[270339] = 186270,
	[270332] = 259489,
	[271049] = 259491,
}

function Module:ChantLumos(self)
	local spec = GetSpecialization()
	if spec == 1 then
		UpdateCooldown(self.lumos[1], 34026, true)
		UpdateCooldown(self.lumos[2], 217200, true)
		UpdateBuff(self.lumos[3], 106785, 272790, false, true, "END")
		UpdateBuff(self.lumos[4], 19574, 19574, true, false, true)
		UpdateBuff(self.lumos[5], 193530, 193530, true, false, true)
	elseif spec == 2 then
		UpdateCooldown(self.lumos[1], 19434, true)
		UpdateCooldown(self.lumos[2], 257044, true)
		UpdateBuff(self.lumos[3], 257622, 257622)

		do
			local button = self.lumos[4]
			if IsPlayerSpell(260402) then
				UpdateBuff(button, 260402, 260402, true, false, true)
			elseif IsPlayerSpell(321460) then
				UpdateCooldown(button, 53351)
				UpdateSpellStatus(button, 53351)
			else
				UpdateBuff(button, 260242, 260242)
			end
		end

		UpdateBuff(self.lumos[5], 288613, 288613, true, false, true)
	elseif spec == 3 then
		UpdateDebuff(self.lumos[1], 259491, 259491, false, "END")

		do
			local button = self.lumos[2]
			if IsPlayerSpell(260248) then
				UpdateBuff(button, 260248, 260249)
			elseif IsPlayerSpell(162488) then
				UpdateDebuff(button, 162488, 162487, true)
			else
				UpdateDebuff(button, 131894, 131894, true)
			end
		end

		do
			local button = self.lumos[3]
			local boom = self.boom
			if IsPlayerSpell(271014) then
				boom:Show()

				local name, _, duration, expire, caster, spellID = GetUnitAura("target", 270339, "HARMFUL")
				if not name then
					name, _, duration, expire, caster, spellID = GetUnitAura("target", 270332, "HARMFUL")
				end

				if not name then
					name, _, duration, expire, caster, spellID = GetUnitAura("target", 271049, "HARMFUL")
				end

				if name and caster == "player" then
					boom.Icon:SetTexture(GetSpellTexture(boomGroups[spellID]))
					boom.CD:SetCooldown(expire - duration, duration)
					boom.CD:Show()
					boom.Icon:SetDesaturated(false)
				else
					local texture = GetSpellTexture(259495)
					if texture == GetSpellTexture(270323) then
						boom.Icon:SetTexture(GetSpellTexture(259489))
					elseif texture == GetSpellTexture(271045) then
						boom.Icon:SetTexture(GetSpellTexture(259491))
					else
						boom.Icon:SetTexture(GetSpellTexture(186270)) -- 270335
					end
					boom.Icon:SetDesaturated(true)
				end

				UpdateCooldown(button, 259495, true)
			else
				boom:Hide()
				UpdateDebuff(button, 259495, 269747, true)
			end
		end

		do
			local button = self.lumos[4]
			if IsPlayerSpell(260285) then
				UpdateBuff(button, 260285, 260286)
			elseif IsPlayerSpell(269751) then
				UpdateCooldown(button, 269751, true)
			else
				UpdateBuff(button, 259387, 259388, false, false, "END")
			end
		end

		UpdateBuff(self.lumos[5], 266779, 266779, true, false, true)
	end
end
