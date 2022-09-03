local AddOnName, Engine = ...

local _G = _G
local bit_band = _G.bit.band
local bit_bor = _G.bit.bor
local math_max = _G.math.max
local math_min = _G.math.min
local next = _G.next
local pairs = _G.pairs
local select = _G.select
local string_format = _G.string.format
local string_lower = _G.string.lower
local table_insert = _G.table.insert
local tonumber = _G.tonumber
local unpack = _G.unpack

local BAG_ITEM_QUALITY_COLORS = _G.BAG_ITEM_QUALITY_COLORS
local COMBATLOG_OBJECT_AFFILIATION_MINE = _G.COMBATLOG_OBJECT_AFFILIATION_MINE
local COMBATLOG_OBJECT_AFFILIATION_PARTY = _G.COMBATLOG_OBJECT_AFFILIATION_PARTY
local COMBATLOG_OBJECT_AFFILIATION_RAID = _G.COMBATLOG_OBJECT_AFFILIATION_RAID
local COMBATLOG_OBJECT_CONTROL_PLAYER = _G.COMBATLOG_OBJECT_CONTROL_PLAYER
local COMBATLOG_OBJECT_REACTION_FRIENDLY = _G.COMBATLOG_OBJECT_REACTION_FRIENDLY
local COMBATLOG_OBJECT_TYPE_PET = _G.COMBATLOG_OBJECT_TYPE_PET
local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS
local CombatLogGetCurrentEventInfo = _G.CombatLogGetCurrentEventInfo
local CreateFrame = _G.CreateFrame
local Enum = _G.Enum
local GetAddOnEnableState = _G.GetAddOnEnableState
local GetAddOnInfo = _G.GetAddOnInfo
local GetAddOnMetadata = _G.GetAddOnMetadata
local GetBuildInfo = _G.GetBuildInfo
local GetLocale = _G.GetLocale
local GetNumAddOns = _G.GetNumAddOns
local GetPhysicalScreenSize = _G.GetPhysicalScreenSize
local GetRealmName = _G.GetRealmName
local LOCALIZED_CLASS_NAMES_FEMALE = _G.LOCALIZED_CLASS_NAMES_FEMALE
local LOCALIZED_CLASS_NAMES_MALE = _G.LOCALIZED_CLASS_NAMES_MALE
local LibStub = _G.LibStub
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local UnitClass = _G.UnitClass
local UnitFactionGroup = _G.UnitFactionGroup
local UnitGUID = _G.UnitGUID
local UnitLevel = _G.UnitLevel
local UnitName = _G.UnitName
local UnitRace = _G.UnitRace
local UnitSex = _G.UnitSex

-- Engine
Engine[1] = {} -- K, Main
Engine[2] = {} -- C, Config
Engine[3] = {} -- L, Locale

local K, C, L = unpack(Engine)

do
	K.Base64 = LibStub("LibBase64-1.0-KkthnxUI")
	K.ChangeLog = LibStub("LibChangelog-KkthnxUI")
	K.Deflate = LibStub("LibDeflate-KkthnxUI")
	K.HideButtonGlow = LibStub("LibButtonGlow-1.0-KkthnxUI", true).HideOverlayGlow
	K.SharedMedia = LibStub("LibSharedMedia-3.0", true)
	K.RangeCheck = LibStub("LibRangeCheck-2.0-KkthnxUI")
	K.Serialize = LibStub("LibSerialize-KkthnxUI")
	K.ShowButtonGlow = LibStub("LibButtonGlow-1.0-KkthnxUI", true).ShowOverlayGlow
	K.Unfit = LibStub("Unfit-1.0-KkthnxUI")
	K.cargBags = Engine.cargBags
	K.oUF = Engine.oUF
end

K.Title = GetAddOnMetadata(AddOnName, "Title")
K.Version = GetAddOnMetadata(AddOnName, "Version")

K.Noop = function() end

K.Name = UnitName("player")
K.Class = select(2, UnitClass("player"))
K.Race = UnitRace("player")
K.Faction = UnitFactionGroup("player")
K.Level = UnitLevel("player")
K.Client = GetLocale()
K.Realm = GetRealmName()
K.Sex = UnitSex("player")
K.GUID = UnitGUID("player")
K.ScreenWidth, K.ScreenHeight = GetPhysicalScreenSize()
K.Resolution = string_format("%dx%d", K.ScreenWidth, K.ScreenHeight)
K.TexCoords = { 0.08, 0.92, 0.08, 0.92 }
K.ScanTooltip = CreateFrame("GameTooltip", "KKUI_ScanTooltip", nil, "GameTooltipTemplate")
K.EasyMenu = CreateFrame("Frame", "KKUI_EasyMenu", UIParent, "UIDropDownMenuTemplate")
K.WowPatch, K.WowBuild, K.WowRelease, K.TocVersion = GetBuildInfo()
K.WowBuild = tonumber(K.WowBuild)

K.GreyColor = "|CFFC0C0C0"
K.InfoColor = "|CFF669DFF"
K.InfoColorTint = "|CFF3ba1c5" -- 30% Tint
K.SystemColor = "|CFFFFCC66"

K.MediaFolder = "Interface\\AddOns\\KkthnxUI\\Media\\"
K.UIFont = "KkthnxUIFont"
K.UIFontOutline = "KkthnxUIFontOutline"
K.LeftButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:230:307|t "
K.RightButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:410|t "
K.ScrollButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t "

K.ClassList = {}
K.ClassColors = {}
K.QualityColors = {}
K.AddOns = {}
K.AddOnVersion = {}

K.PartyPetFlags = bit_bor(COMBATLOG_OBJECT_AFFILIATION_PARTY, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)
K.RaidPetFlags = bit_bor(COMBATLOG_OBJECT_AFFILIATION_RAID, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)

local eventsFrame = CreateFrame("Frame")
local events = {}
local modules = {}
local modulesQueue = {}
local isScaling = false

function K.IsMyPet(flags)
	return bit_band(flags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0
end

for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	K.ClassList[v] = k
end

for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
	K.ClassList[v] = k
end

local colors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
for class, value in pairs(colors) do
	K.ClassColors[class] = {}
	K.ClassColors[class].r = value.r
	K.ClassColors[class].g = value.g
	K.ClassColors[class].b = value.b
	K.ClassColors[class].colorStr = value.colorStr
end

K.r, K.g, K.b = K.ClassColors[K.Class].r, K.ClassColors[K.Class].g, K.ClassColors[K.Class].b
K.MyClassColor = string_format("|cff%02x%02x%02x", K.r * 255, K.g * 255, K.b * 255)

local qualityColors = BAG_ITEM_QUALITY_COLORS
for index, value in pairs(qualityColors) do
	K.QualityColors[index] = { r = value.r, g = value.g, b = value.b }
end
K.QualityColors[-1] = { r = 1, g = 1, b = 1 }
K.QualityColors[LE_ITEM_QUALITY_POOR] = { r = 0.61, g = 0.61, b = 0.61 }
K.QualityColors[LE_ITEM_QUALITY_COMMON] = { r = 1, g = 1, b = 1 }

eventsFrame:SetScript("OnEvent", function(_, event, ...)
	for func in pairs(events[event]) do
		if event == "COMBAT_LOG_EVENT_UNFILTERED" then
			func(event, CombatLogGetCurrentEventInfo())
		else
			func(event, ...)
		end
	end
end)

function K:RegisterEvent(event, func, unit1, unit2)
	if event == "CLEU" then
		event = "COMBAT_LOG_EVENT_UNFILTERED"
	end

	if not events[event] then
		events[event] = {}
		if unit1 then
			eventsFrame:RegisterUnitEvent(event, unit1, unit2)
		else
			eventsFrame:RegisterEvent(event)
		end
	end

	events[event][func] = true
end

function K:UnregisterEvent(event, func)
	if event == "CLEU" then
		event = "COMBAT_LOG_EVENT_UNFILTERED"
	end

	local funcs = events[event]
	if funcs and funcs[func] then
		funcs[func] = nil
		if not next(funcs) then
			events[event] = nil
			eventsFrame:UnregisterEvent(event)
		end
	end
end

-- Modules
function K:NewModule(name)
	if modules[name] then
		error(("Usage: K:NewModule(" .. name .. "): Module '%s' already exists."):format(name), 2)
		return
	end

	local module = {}
	module.name = name
	modules[name] = module

	table_insert(modulesQueue, module)

	return module
end

function K:GetModule(name)
	if not modules[name] then
		error(("Usage: K:GetModule(" .. name .. ") Cannot find Module '%s'."):format(tostring(name)), 2)
		return
	end

	return modules[name]
end

local function GetBestScale()
	local scale = math_max(0.4, math_min(1.15, 768 / K.ScreenHeight))
	return K.Round(scale, 2)
end

function K.SetupUIScale(init)
	if C["General"].AutoScale then
		C["General"].UIScale = GetBestScale()
	end

	local scale = C["General"].UIScale
	if init then
		local pixel = 1
		local ratio = 768 / K.ScreenHeight
		K.Mult = (pixel / scale) - ((pixel - ratio) / scale)
	elseif not InCombatLockdown() then
		UIParent:SetScale(scale)
	end
end

local function UpdatePixelScale(event)
	if isScaling then
		return
	end
	isScaling = true

	if event == "UI_SCALE_CHANGED" then
		print("UpdatePixelScale", event)
		K.ScreenWidth, K.ScreenHeight = GetPhysicalScreenSize()
	end

	K.SetupUIScale(true)
	K.SetupUIScale()

	isScaling = false
end

K:RegisterEvent("PLAYER_LOGIN", function()
	K.SetupUIScale()
	K:RegisterEvent("UI_SCALE_CHANGED", UpdatePixelScale)
	K:SetSmoothingAmount(C["General"].SmoothAmount)

	for _, module in next, modulesQueue do
		if module.OnEnable and not module.Enabled then
			module:OnEnable()
			module.Enabled = true
		else
			error(("Module ('%s') has failed to load."):format(tostring(module.name)), 2)
		end
	end

	K.Modules = modules
end)

-- Event return values were wrong: https://wow.gamepedia.com/PLAYER_LEVEL_UP
K:RegisterEvent("PLAYER_LEVEL_UP", function(_, level)
	if not K.Level then
		return
	end

	K.Level = level
end)

for i = 1, GetNumAddOns() do
	local Name, _, _, _, Reason = GetAddOnInfo(i)
	K.AddOns[string_lower(Name)] = GetAddOnEnableState(K.Name, Name) == 2 and (not Reason or Reason ~= "DEMAND_LOADED")
	K.AddOnVersion[string_lower(Name)] = GetAddOnMetadata(Name, "Version")
end

-- Profiling
do
	local info = {}
	function K:LogDebugInfo(name, time, mem)
		info[name] = info[name] or { timeLog = {}, memLog = {}, calls = 0 }

		if #info[name].timeLog > 1000 then
			table.remove(info[name].timeLog, 1)
		end

		table.insert(info[name].timeLog, time)

		if #info[name].memLog > 1000 then
			table.remove(info[name].memLog, 1)
		end

		table.insert(info[name].memLog, mem)

		info[name].calls = info[name].calls + 1

		print("|cffffd200" .. name .. "|r")
		print("time:", info[name].timeLog[#info[name].timeLog])
		print("mem:", info[name].memLog[#info[name].memLog])
		print("calls:", info[name].calls)
	end

	K.isProfiling = true
end

_G.KkthnxUI = Engine
