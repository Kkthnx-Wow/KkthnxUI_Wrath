local K, C = unpack(select(2, ...))

local function KKUI_CreateDefaults()
	K.Defaults = {}

	for group, options in pairs(C) do
		if (not K.Defaults[group]) then
			K.Defaults[group] = {}
		end

		for option, value in pairs(options) do
			K.Defaults[group][option] = value

			if (type(C[group][option]) == "table") then
				if C[group][option].Options then
					K.Defaults[group][option] = value.Value
				else
					K.Defaults[group][option] = value
				end
			else
				K.Defaults[group][option] = value
			end
		end
	end
end

local function KKUI_LoadCustomSettings()
	local Settings = KkthnxUIDB.Settings[K.Realm][K.Name]

	for group, options in pairs(Settings) do
		if C[group] then
			local Count = 0

			for option, value in pairs(options) do
				if (C[group][option] ~= nil) then
					if (C[group][option] == value) then
						Settings[group][option] = nil
					else
						Count = Count + 1

						if (type(C[group][option]) == "table") then
							if C[group][option].Options then
								C[group][option].Value = value
							else
								C[group][option] = value
							end
						else
							C[group][option] = value
						end
					end
				end
			end

			-- Keeps settings clean and small
			if (Count == 0) then
				Settings[group] = nil
			end
		else
			Settings[group] = nil
		end
	end
end

local function KKUI_LoadProfiles()
	local Profiles = C["General"].Profiles
	local Menu = Profiles.Options
	local Data = KkthnxUIDB.Variables
	local GUISettings = KkthnxUIDB.Settings
	local Nickname = K.Name
	local Server = K.Realm

	if not GUISettings then
		return
	end

	for Index, Table in pairs(GUISettings) do
		local Server = Index

		for Nickname, Settings in pairs(Table) do
			local ProfileName = Server.."-"..Nickname
			local MyProfileName = K.Realm.."-"..K.Name

			if MyProfileName ~= ProfileName then
				Menu[ProfileName] = ProfileName
			end
		end
	end
end

local function KKUI_MergeDatabase()
	if KkthnxUIData then
		KkthnxUIDB["Variables"] = KkthnxUIData
		KkthnxUIData = nil
	end

	if KkthnxUISettingsPerCharacter then
		KkthnxUIDB["Settings"] = KkthnxUISettingsPerCharacter
		KkthnxUISettingsPerCharacter = nil
	end

	if KkthnxUIGold then
		KkthnxUIDB["Gold"] = KkthnxUIGold
		KkthnxUIGold = nil
	end

	if KkthnxUIChatHistory then
		KkthnxUIDB["ChatHistory"] = KkthnxUIChatHistory
		KkthnxUIChatHistory = nil
	end
end

local function KKUI_VerifyDatabase()
	if not KkthnxUIDB then
		KkthnxUIDB = {}
	end

	-- VARIABLES
	if not KkthnxUIDB.Variables then
		KkthnxUIDB.Variables = {}
	end

	if not KkthnxUIDB.Variables[K.Realm] then
		KkthnxUIDB.Variables[K.Realm] = {}
	end

	if not KkthnxUIDB.Variables[K.Realm][K.Name] then
		KkthnxUIDB.Variables[K.Realm][K.Name] = {}
	end

	if KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuest == nil then
		KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuest = false
	end

	if not KkthnxUIDB.Variables[K.Realm][K.Name].BindType then
		KkthnxUIDB.Variables[K.Realm][K.Name].BindType = 1
	end

	if not KkthnxUIDB.Variables[K.Realm][K.Name].ChangeLog then
		KkthnxUIDB.Variables[K.Realm][K.Name].ChangeLog = {}
	end

	if not KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList then
		KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList = {}
	end

	if KkthnxUIDB.Variables[K.Realm][K.Name].DetectVersion == nil then
		KkthnxUIDB.Variables[K.Realm][K.Name].DetectVersion = K.Version
	end

	if not KkthnxUIDB.Variables[K.Realm][K.Name].FavouriteItems then
		KkthnxUIDB.Variables[K.Realm][K.Name].FavouriteItems = {}
	end

	if not KkthnxUIDB.Variables[K.Realm][K.Name].Mover then
		KkthnxUIDB.Variables[K.Realm][K.Name].Mover = {}
	end

	if not KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchMover then
		KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchMover = {}
	end

	if not KkthnxUIDB.Variables[K.Realm][K.Name].Tracking then
		KkthnxUIDB.Variables[K.Realm][K.Name].Tracking = {}
	end

	if not KkthnxUIDB.Variables[K.Realm][K.Name].Tracking.PvP then
		KkthnxUIDB.Variables[K.Realm][K.Name].Tracking.PvP = {}
	end

	if not KkthnxUIDB.Variables[K.Realm][K.Name].Tracking.PvE then
		KkthnxUIDB.Variables[K.Realm][K.Name].Tracking.PvE = {}
	end

	if KkthnxUIDB.Variables[K.Realm][K.Name].RevealWorldMap == nil then
		KkthnxUIDB.Variables[K.Realm][K.Name].RevealWorldMap = false
	end

	if not KkthnxUIDB.Variables[K.Realm][K.Name].SplitCount then
		KkthnxUIDB.Variables[K.Realm][K.Name].SplitCount = 1
	end

	if not KkthnxUIDB.Variables[K.Realm][K.Name].ContactList then
		KkthnxUIDB.Variables[K.Realm][K.Name].ContactList = {}
	end

	if not KkthnxUIDB.Variables[K.Realm][K.Name].TempAnchor then
		KkthnxUIDB.Variables[K.Realm][K.Name].TempAnchor = {}
	end

	if not KkthnxUIDB.Variables[K.Realm][K.Name].InternalCD then
		KkthnxUIDB.Variables[K.Realm][K.Name].InternalCD = {}
	end

	if not KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList then
		KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList = {}
	end

	if not KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList.Switcher then
		KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList.Switcher = {}
	end

	if not KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList.IgnoreSpells then
		KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList.IgnoreSpells = {}
	end

	-- Settings
	if (not KkthnxUIDB.Settings) then
		KkthnxUIDB.Settings = {}
	end

	if not KkthnxUIDB.Settings[K.Realm] then
		KkthnxUIDB.Settings[K.Realm] = {}
	end

	if not KkthnxUIDB.Settings[K.Realm][K.Name] then
		KkthnxUIDB.Settings[K.Realm][K.Name] = {}
	end

	-- Chat History
	if not KkthnxUIDB.ChatHistory then
		KkthnxUIDB.ChatHistory = {}
	end

	-- Gold
	if not KkthnxUIDB.Gold then
		KkthnxUIDB.Gold = {}
	end

	if KkthnxUIDB.ShowSlots == nil then
		KkthnxUIDB.ShowSlots = false
	end
end

local addonLoader = CreateFrame("Frame")
addonLoader:RegisterEvent("ADDON_LOADED")
addonLoader:SetScript("OnEvent", function(self, _, addon)
	if addon ~= "KkthnxUI" then
		return
	end

	-- We verify everything is ok with our savedvariables
	KKUI_VerifyDatabase()
	-- KkthnxUI was using different table to save settings, when players will hit this version, we need to move their settings into our new table
	KKUI_MergeDatabase()

	KKUI_CreateDefaults()
	KKUI_LoadProfiles()
	KKUI_LoadCustomSettings()

	K.GUI:Enable()
	K.Profiles:Enable()
	K.SetupUIScale(true)

	self:UnregisterAllEvents()
end)