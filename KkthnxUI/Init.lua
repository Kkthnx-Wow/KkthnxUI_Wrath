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
local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS
local CombatLogGetCurrentEventInfo = _G.CombatLogGetCurrentEventInfo
local CreateFrame = _G.CreateFrame
local GetAddOnEnableState = _G.GetAddOnEnableState
local GetAddOnInfo = _G.GetAddOnInfo
local GetAddOnMetadata = _G.GetAddOnMetadata
local GetBuildInfo = _G.GetBuildInfo
local GetLocale = _G.GetLocale
local GetNumAddOns = _G.GetNumAddOns
local GetPhysicalScreenSize = _G.GetPhysicalScreenSize
local GetRealmName = _G.GetRealmName
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

-- Deprecated
LE_ITEM_CLASS_CONSUMABLE = LE_ITEM_CLASS_CONSUMABLE or Enum.ItemClass.Consumable
LE_ITEM_CLASS_CONTAINER = LE_ITEM_CLASS_CONTAINER or Enum.ItemClass.Container
LE_ITEM_CLASS_WEAPON = LE_ITEM_CLASS_WEAPON or Enum.ItemClass.Weapon
LE_ITEM_CLASS_GEM = LE_ITEM_CLASS_GEM or Enum.ItemClass.Gem
LE_ITEM_CLASS_ARMOR = LE_ITEM_CLASS_ARMOR or Enum.ItemClass.Armor
LE_ITEM_CLASS_REAGENT = LE_ITEM_CLASS_REAGENT or Enum.ItemClass.Reagent
LE_ITEM_CLASS_PROJECTILE = LE_ITEM_CLASS_PROJECTILE or Enum.ItemClass.Projectile
LE_ITEM_CLASS_TRADEGOODS = LE_ITEM_CLASS_TRADEGOODS or Enum.ItemClass.Tradegoods
LE_ITEM_CLASS_ITEM_ENHANCEMENT = LE_ITEM_CLASS_ITEM_ENHANCEMENT or Enum.ItemClass.ItemEnhancement
LE_ITEM_CLASS_RECIPE = LE_ITEM_CLASS_RECIPE or Enum.ItemClass.Recipe
LE_ITEM_CLASS_QUIVER = LE_ITEM_CLASS_QUIVER or Enum.ItemClass.Quiver
LE_ITEM_CLASS_QUESTITEM = LE_ITEM_CLASS_QUESTITEM or Enum.ItemClass.Questitem
LE_ITEM_CLASS_KEY = LE_ITEM_CLASS_KEY or Enum.ItemClass.Key
LE_ITEM_CLASS_MISCELLANEOUS = LE_ITEM_CLASS_MISCELLANEOUS or Enum.ItemClass.Miscellaneous
LE_ITEM_CLASS_GLYPH = LE_ITEM_CLASS_GLYPH or Enum.ItemClass.Glyph
LE_ITEM_CLASS_BATTLEPET = LE_ITEM_CLASS_BATTLEPET or Enum.ItemClass.Battlepet
LE_ITEM_CLASS_WOW_TOKEN = LE_ITEM_CLASS_WOW_TOKEN or Enum.ItemClass.WoWToken

-- Engine
Engine[1] = {} -- K, Main
Engine[2] = {} -- C, Config
Engine[3] = {} -- L, Locales

local K, C, L = unpack(Engine)

do
	K.Base64 = LibStub("LibBase64-1.0-KkthnxUI")
	K.Deflate = LibStub("LibDeflate-KkthnxUI")
	K.HideButtonGlow = LibStub("LibButtonGlow-1.0-KkthnxUI", true).HideOverlayGlow
	K.Serialize = LibStub("LibSerialize-KkthnxUI")
	K.ShowButtonGlow = LibStub("LibButtonGlow-1.0-KkthnxUI", true).ShowOverlayGlow
	K.Unfit = LibStub("Unfit-1.0-KkthnxUI")
	K.RangeCheck = LibStub("LibRangeCheck-2.0-KkthnxUI")
	K.LibSharedMedia = LibStub("LibSharedMedia-3.0", true)
	K.cargBags = Engine.cargBags
	K.oUF = Engine.oUF
end

K.AddOns = {}
K.AddOnVersion = {}

K.Title = GetAddOnMetadata(AddOnName, "Title")
K.Version = GetAddOnMetadata(AddOnName, "Version")
K.Credits = GetAddOnMetadata(AddOnName, "X-Credits")

_G.BINDING_HEADER_KKUI = K.Title

K.Noop = function()
	return
end

K.Name = UnitName("player")
K.Class = select(2, UnitClass("player"))
K.Race = UnitRace("player")
K.Faction = UnitFactionGroup("player")
K.Level = UnitLevel("player")
K.Client = GetLocale()
K.Realm = GetRealmName()
K.FullName = K.Name.."-"..K.Realm
K.Sex = UnitSex("player")
K.Media = "Interface\\AddOns\\KkthnxUI\\Media\\"
K.ScreenWidth, K.ScreenHeight = GetPhysicalScreenSize()
K.Resolution = string_format("%dx%d", K.ScreenWidth, K.ScreenHeight)
K.TexCoords = {0.08, 0.92, 0.08, 0.92}
K.Welcome = "|cff669DFFKkthnxUI "..K.Version.." "..K.Client.."|r - /helpui"
K.ScanTooltip = CreateFrame("GameTooltip", "KKUI_ScanTooltip", nil, "GameTooltipTemplate")
K.EasyMenu = CreateFrame("Frame", "KKUI_EasyMenu", UIParent, "UIDropDownMenuTemplate")
K.WowPatch, K.WowBuild, K.WowRelease, K.TocVersion = GetBuildInfo()
K.WowBuild = tonumber(K.WowBuild)
K.GreyColor = "|CFF7b8489"
K.InfoColor = "|CFF669DFF"
K.InfoColorTint = "|CFFA3D3FF"
K.SystemColor = "|CFFFFCC66"
K.LeftButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:230:307|t "
K.RightButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:410|t "
K.ScrollButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t "
K.AFKTex = "|T"..FRIENDS_TEXTURE_AFK..":14:14:0:0:16:16:1:15:1:15|t"
K.DNDTex = "|T"..FRIENDS_TEXTURE_DND..":14:14:0:0:16:16:1:15:1:15|t"
K.KkthnxUIString = "[KkthnxUI]: "

function K.IsMyPet(flags)
	return bit_band(flags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0
end
K.PartyPetFlags = bit_bor(COMBATLOG_OBJECT_AFFILIATION_PARTY, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)
K.RaidPetFlags = bit_bor(COMBATLOG_OBJECT_AFFILIATION_RAID, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)

K.CodeDebug = false

K.QualityColors = {}
local qualityColors = BAG_ITEM_QUALITY_COLORS
for index, value in pairs(qualityColors) do
	K.QualityColors[index] = {r = value.r, g = value.g, b = value.b}
end
K.QualityColors[-1] = {r = 1, g = 1, b = 1}
K.QualityColors[LE_ITEM_QUALITY_POOR] = {r = 0.61, g = 0.61, b = 0.61}
K.QualityColors[LE_ITEM_QUALITY_COMMON] = {r = 1, g = 1, b = 1}

K.ClassList = {}
for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	K.ClassList[v] = k
end

K.ClassColors = {}
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

local events = {}
local host = CreateFrame("Frame")
local modules, initQueue = {}, {}

host:SetScript("OnEvent", function(_, event, ...)
	for func in pairs(events[event]) do
		if event == "COMBAT_LOG_EVENT_UNFILTERED" then
			func(event, CombatLogGetCurrentEventInfo())
		else
			func(event, ...)
		end
	end
end)

function K:RegisterEvent(event, func, unit1, unit2)
	if not events[event] then
		events[event] = {}
		if unit1 then
			host:RegisterUnitEvent(event, unit1, unit2)
		else
			host:RegisterEvent(event)
		end
	end

	events[event][func] = true
end

function K:UnregisterEvent(event, func)
	local funcs = events[event]
	if funcs and funcs[func] then
		funcs[func] = nil
		if not next(funcs) then
			events[event] = nil
			host:UnregisterEvent(event)
		end
	end
end

-- Modules
function K:NewModule(name)
	if modules[name] then
		K.Print("Module ["..name.."] has already been registered.")
		return
	end

	local module = {}
	module.name = name
	modules[name] = module

	table_insert(initQueue, module)

	return module
end

function K:GetModule(name)
	if not modules[name] then
		K.Print("Module <"..name.."> does not exist.")
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
		if scale >= 0.64 then
			SetCVar("uiscale", scale) -- Fix blizzard chatframe offset
		end
		UIParent:SetScale(scale)
	end
end

local isScaling = false
local function UpdatePixelScale(event)
	if isScaling then
		return
	end
	isScaling = true

	if event == "UI_SCALE_CHANGED" then
		K.ScreenWidth, K.ScreenHeight = GetPhysicalScreenSize()
	end

	K.SetupUIScale(true)
	K.SetupUIScale()

	isScaling = false
end

K:RegisterEvent("PLAYER_LOGIN", function()
	SetCVar("useUiScale", 1) -- Fix blizzard chatframe offset
	K.SetupUIScale()
	K:RegisterEvent("UI_SCALE_CHANGED", UpdatePixelScale)

	local playerGUID = UnitGUID("player")
	local _, serverID = string.split("-", playerGUID)
	K.ServerID = tonumber(serverID)
	K.GUID = playerGUID

	for _, module in next, initQueue do
		if module.OnEnable then
			module:OnEnable()
		else
			K.Print("Module ["..module.name.."] failed to load!")
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
	local Name = GetAddOnInfo(i)
	K.AddOns[string_lower(Name)] = GetAddOnEnableState(K.Name, Name) == 2
	K.AddOnVersion[string_lower(Name)] = GetAddOnMetadata(Name, "Version")
end

-- Debugging
-- Sourced: GW2_UI

-- AddOns Needed
-- !Stragglers
-- _DebugLog

-- If you wanna debug, you need to add your name-realm to dev
-- Go to 'Interface\AddOns\KkthnxUI\Developer\Elements\Frame.lua'
-- Go to line 45 and add your name and realm as the others are added.
-- Reload your UI and add any debugging you wanna check.

-- Examples
-- K.Debug("Level Thing:", K.Level)
-- K.AddForProfiling("Something", "Function Name", Function)
-- if K.inDebug then
-- 	GetBestScale()
-- end

local function AddForProfiling(unit, name, ...)
	if not K.IsDeveloper then
		return
	end

	local gName = "KKUI_Profiling_"..unit
	if not _G[gName] then
		_G[gName] = {}
	end
	_G[gName][name] = ...
end

local function Debug(...)
	if not K.IsDeveloper then
		return
	end

	if DLAPI then
		local msg = ""
		for i = 1, select("#", ...) do
			local arg = select(i, ...)
			msg = msg..tostring(arg).." "
		end
		DLAPI.DebugLog("KkthnxUI", "%s", msg)
	end
end

local function Trace()
	if not K.IsDeveloper then
		return
	end

	if DLAPI then
		DLAPI.DebugLog("KkthnxUITrace", "%s", "------------------------- Trace -------------------------")
		for i, v in ipairs({("\n"):split(debugstack(2))}) do
			if v ~= "" then
				DLAPI.DebugLog("KkthnxUITrace", "%d: %s", i, v)
			end
		end
		DLAPI.DebugLog("KkthnxUITrace", "%s", "---------------------------------------------------------")
	end
end

local function DebugOff()
	return
end

local function AddForProfilingOff()
	return
end

local function TraceOff()
	return
end

K.inDebug = nil
if DLAPI then
	K.Debug = Debug
	K.Trace = Trace
	K.inDebug = K.IsDeveloper and true or false
	SetCVar("fstack_preferParentKeys", 0)
	Debug("debug log initialized")
else
	K.Debug = DebugOff
	K.Trace = TraceOff
	K.inDebug = false
end

if Profiler then
	K.AddForProfiling = AddForProfiling
else
	K.AddForProfiling = AddForProfilingOff
end

_G[AddOnName] = Engine