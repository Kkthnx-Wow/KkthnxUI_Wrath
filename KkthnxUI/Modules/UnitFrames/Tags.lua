local K, C, L = unpack(select(2, ...))
local oUF = oUF or K.oUF

local _G = _G
local string_format = _G.string.format
local string_find = _G.string.find

local ALTERNATE_POWER_INDEX = _G.ALTERNATE_POWER_INDEX or 10
local DEAD = _G.DEAD
local GetCreatureDifficultyColor = _G.GetCreatureDifficultyColor
local LEVEL = _G.LEVEL
local PLAYER_OFFLINE = _G.PLAYER_OFFLINE
local UnitClass = _G.UnitClass
local UnitClassification = _G.UnitClassification
local UnitHealth = _G.UnitHealth
local UnitHealthMax = _G.UnitHealthMax
local UnitIsAFK = _G.UnitIsAFK
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDND = _G.UnitIsDND
local UnitIsDead = _G.UnitIsDead
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitIsGhost = _G.UnitIsGhost
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsTapDenied = _G.UnitIsTapDenied
local UnitLevel = _G.UnitLevel
local UnitPower = _G.UnitPower
local UnitPowerType = _G.UnitPowerType
local UnitReaction = _G.UnitReaction
local GetSpellInfo = _G.GetSpellInfo
local UnitIsFeignDeath = _G.UnitIsFeignDeath

local FEIGN_DEATH
local function GetFeignDeathTag()
	if not FEIGN_DEATH then
		FEIGN_DEATH = GetSpellInfo(5384)
	end
	return FEIGN_DEATH
end

local function ColorPercent(value)
	local r, g, b
	if value < 20 then
		r, g, b = 1, 0.1, 0.1
	elseif value < 35 then
		r, g, b = 1, 0.5, 0
	elseif value < 80 then
		r, g, b = 1, 0.9, 0.3
	else
		r, g, b = 1, 1, 1
	end

	return K.RGBToHex(r, g, b)..value
end

local function ValueAndPercent(cur, per)
	if per < 100 then
		return K.ShortValue(cur).." - "..ColorPercent(per)
	else
		return K.ShortValue(cur)
	end
end

local function GetUnitHealthPerc(unit)
	local unitMaxHealth = UnitHealthMax(unit)
	if unitMaxHealth == 0 then
		return 0
	else
		return K.Round(UnitHealth(unit) / unitMaxHealth * 100, 1)
	end
end

oUF.Tags.Methods["hp"] = function(unit)
	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) or UnitIsFeignDeath(unit) then
		return oUF.Tags.Methods["DDG"](unit)
	else
		local per = GetUnitHealthPerc(unit) or 0
		local cur = UnitHealth(unit)
		if unit == "player" or unit == "target" or unit == "focus" or string_find(unit, "party") then
			return ValueAndPercent(cur, per)
		else
			return ColorPercent(per)
		end
	end
end
oUF.Tags.Events["hp"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

oUF.Tags.Methods["power"] = function(unit)
	local cur = UnitPower(unit)
	local per = oUF.Tags.Methods["perpp"](unit) or 0
	if unit == "player" or unit == "target" or unit == "focus" then
		if per < 100 and UnitPowerType(unit) == 0 then
			return K.ShortValue(cur).." - "..per
		else
			return K.ShortValue(cur)
		end
	else
		return per
	end
end
oUF.Tags.Events["power"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER"

oUF.Tags.Methods["color"] = function(unit)
	local class = select(2, UnitClass(unit))
	local reaction = UnitReaction(unit, "player")

	if UnitIsTapDenied(unit) then
		return K.RGBToHex(oUF.colors.tapped)
	elseif UnitIsPlayer(unit) then
		return K.RGBToHex(K.Colors.class[class])
	elseif reaction then
		return K.RGBToHex(K.Colors.reaction[reaction])
	else
		return K.RGBToHex(1, 1, 1)
	end
end
oUF.Tags.Events["color"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_FACTION UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

oUF.Tags.Methods["afkdnd"] = function(unit)
	if UnitIsAFK(unit) then
		return "|cffCFCFCF <"..AFK..">|r"
	elseif UnitIsDND(unit) then
		return "|cffCFCFCF <"..DND..">|r"
	else
		return ""
	end
end
oUF.Tags.Events["afkdnd"] = "PLAYER_FLAGS_CHANGED"

oUF.Tags.Methods["DDG"] = function(unit)
	if UnitIsFeignDeath(unit) then
		return "|cffffffff"..GetFeignDeathTag().."|r"
	elseif UnitIsDead(unit) then
		return "|cffCFCFCF"..DEAD.."|r"
	elseif UnitIsGhost(unit) then
		return "|cffCFCFCF"..L["Ghost"].."|r"
	elseif not UnitIsConnected(unit) then
		return "|cffCFCFCF"..PLAYER_OFFLINE.."|r"
	end
end
oUF.Tags.Events["DDG"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

-- Level tags
oUF.Tags.Methods["fulllevel"] = function(unit)
	local level = UnitLevel(unit)
	local color = K.RGBToHex(GetCreatureDifficultyColor(level))
	if level > 0 then
		level = color..level.."|r"
	else
		level = "|cffff0000??|r"
	end

	local str = level
	local class = UnitClassification(unit)
	if class == "worldboss" then
		str = "|cffAF5050Boss|r"
	elseif class == "rareelite" then
		str = str.."|cffAF5050R|r+"
	elseif class == "elite" then
		str = str.."|cffAF5050+|r"
	elseif class == "rare" then
		str = str.."|cffAF5050R|r"
	end

	return str
end
oUF.Tags.Events["fulllevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED"

-- RaidFrame tags
oUF.Tags.Methods["raidhp"] = function(unit)
	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) or UnitIsFeignDeath(unit) then
		return oUF.Tags.Methods["DDG"](unit)
	elseif C["Raid"].HealthFormat.Value == 2 then
		local per = GetUnitHealthPerc(unit) or 0
		return ColorPercent(per)
	elseif C["Raid"].HealthFormat.Value == 3 then
		local cur = UnitHealth(unit)
		return K.ShortValue(cur)
	elseif C["Raid"].HealthFormat.Value == 4 then
		local loss = UnitHealthMax(unit) - UnitHealth(unit)
		if loss == 0 then return end
		return K.ShortValue(loss)
	end
end
oUF.Tags.Events["raidhp"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

-- Nameplate tags
oUF.Tags.Methods["nphp"] = function(unit)
	local per = GetUnitHealthPerc(unit) or 0
	if C["Nameplate"].FullHealth then
		local cur = UnitHealth(unit)
		return ValueAndPercent(cur, per)
	elseif per < 100 then
		return ColorPercent(per)
	end
end
oUF.Tags.Events["nphp"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION"

oUF.Tags.Methods["nppp"] = function(unit)
	local per = oUF.Tags.Methods["perpp"](unit)
	local color
	if per > 85 then
		color = K.RGBToHex(1, .1, .1)
	elseif per > 50 then
		color = K.RGBToHex(1, 1, .1)
	else
		color = K.RGBToHex(.8, .8, 1)
	end
	per = color..per.."|r"

	return per
end
oUF.Tags.Events["nppp"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER"

oUF.Tags.Methods["nplevel"] = function(unit)
	local level = UnitLevel(unit)
	if level and level ~= UnitLevel("player") then
		if level > 0 then
			level = K.RGBToHex(GetCreatureDifficultyColor(level))..level.."|r "
		else
			level = "|cffff0000??|r "
		end
	else
		level = ""
	end

	return level
end
oUF.Tags.Events["nplevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED"

oUF.Tags.Methods["pppower"] = function(unit)
	local cur = UnitPower(unit)
	local per = oUF.Tags.Methods["perpp"](unit) or 0
	if UnitPowerType(unit) == 0 then
		return per
	else
		return cur
	end
end
oUF.Tags.Events["pppower"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER"

oUF.Tags.Methods["npctitle"] = function(unit)
	if UnitIsPlayer(unit) then
		return
	end

	K.ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	K.ScanTooltip:SetUnit(unit)

	local title = _G[string_format("KKUI_ScanTooltipTextLeft%d", GetCVarBool("colorblindmode") and 3 or 2)]:GetText()
	if title and not string_find(title, "^"..LEVEL) then
		return title
	end
end
oUF.Tags.Events["npctitle"] = "UNIT_NAME_UPDATE"

oUF.Tags.Methods["guildname"] = function(unit)
	if not UnitIsPlayer(unit) then
		return
	end

	local guildName = GetGuildInfo(unit)
	if guildName then
		return string_format("<%s>", guildName)
	end
end
oUF.Tags.Events["guildname"] = "UNIT_NAME_UPDATE PLAYER_GUILD_UPDATE"

oUF.Tags.Methods["tarname"] = function(unit)
	local tarUnit = unit.."target"
	if UnitExists(tarUnit) then
		local tarClass = select(2, UnitClass(tarUnit))
		return K.RGBToHex(K.Colors.class[tarClass])..UnitName(tarUnit)
	end
end
oUF.Tags.Events["tarname"] = "UNIT_NAME_UPDATE UNIT_THREAT_SITUATION_UPDATE UNIT_HEALTH"

-- AltPower value tag
oUF.Tags.Methods["altpower"] = function(unit)
	local cur = UnitPower(unit, ALTERNATE_POWER_INDEX)
	local max = UnitPowerMax(unit, ALTERNATE_POWER_INDEX)
	if max > 0 and not UnitIsDeadOrGhost(unit) then
		return string_format("%s%%", math.floor(cur / max * 100 + 0.5))
	end
end
oUF.Tags.Events["altpower"] = "UNIT_POWER_UPDATE"

oUF.Tags.Methods["pethappiness"] = function(unit)
	local hasPetUI, isHunterPet = HasPetUI()
	if (UnitIsUnit("pet", unit) and hasPetUI and isHunterPet) then
		local left, right, top, bottom
		local happiness = GetPetHappiness()

		if(happiness == 1) then
			left, right, top, bottom = 0.375, 0.5625, 0, 0.359375
		elseif(happiness == 2) then
			left, right, top, bottom = 0.1875, 0.375, 0, 0.359375
		elseif(happiness == 3) then
			left, right, top, bottom = 0, 0.1875, 0, 0.359375
		end

		return CreateTextureMarkup([[Interface\PetPaperDollFrame\UI-PetHappiness]], 128, 64, 14, 14, left, right, top, bottom, 0, 0)
	end
end
oUF.Tags.Events["pethappiness"] = "UNIT_HAPPINESS PET_UI_UPDATE"