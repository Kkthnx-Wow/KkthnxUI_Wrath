local _, C = unpack(select(2, ...))

local _G = _G

local GUILD = _G.GUILD
local NONE = _G.NONE
local PLAYER = _G.PLAYER

-- Actionbar
C["ActionBar"] = {
	["AspectBar"] = false,
	["AspectSize"] = 24,
	["Cooldowns"] = true,
	["Count"] = true,
	["CustomBar"] = false,
	["CustomBarButtonSize"] = 34,
	["CustomBarNumButtons"] = 12,
	["CustomBarNumPerRow"] = 12,
	["DecimalCD"] = true,
	["DefaultButtonSize"] = 34,
	["Enable"] = true,
	["FadeBottomBar3"] = false,
	["FadeCustomBar"] = false,
	["FadeMicroBar"] = false,
	["FadePetBar"] = false,
	["FadeRightBar"] = false,
	["FadeRightBar2"] = false,
	["FadeStanceBar"] = false,
	["Hotkey"] = true,
	["Macro"] = true,
	["MicroBar"] = true,
	["OverrideWA"] = false,
	["PetBar"] = true,
	["RightButtonSize"] = 34,
	["StanceBar"] = true,
	["StancePetSize"] = 30,
	["VerticleAspect"] = false,
	["Layout"] = {
		["Options"] = {
			["Mainbar 2x3x4"] = "3x4 Boxed arrangement",
			["Mainbar 3x12"] = "Default Style",
			["Mainbar 4x12"] = "Four Stacked",
		},
		["Value"] = "Default Style"
	},
}

-- Announcements
C["Announcements"] = {
	["AlertInInstance"] = true,
	["BrokenSpell"] = false,
	["HealthAlert"] = false,
	["HealthAlertEmote"] = false,
	["HealthThreshold"] = 20,
	["Interrupt"] = false,
	["ItemAlert"] = false,
	["ManaAlert"] = false,
	["ManaAlertEmote"] = false,
	["ManaThreshold"] = 20,
	["OnlyCompleteRing"] = false,
	["OwnInterrupt"] = true,
	["PullCountdown"] = true,
	["PvPEmote"] = false,
	["QuestNotifier"] = false,
	["QuestProgress"] = false,
	["ResetInstance"] = true,
	["SaySapped"] = false,
	["InterruptChannel"] = {
		["Options"] = {
			[EMOTE] = 6,
			[PARTY.." / "..RAID] = 2,
			[PARTY] = 1,
			[RAID] = 3,
			[SAY] = 4,
			[YELL] = 5,
		},
		["Value"] = 2
	},
}

-- Automation
C["Automation"] = {
	["AutoBlockStrangerInvites"] = false,
	["AutoCollapse"] = false,
	["AutoDeclineDuels"] = false,
	["AutoDisenchant"] = false,
	["AutoDismount"] = false,
	["AutoInvite"] = false,
	["AutoOpenItems"] = false,
	["AutoQuest"] = false,
	["AutoRelease"] = false,
	["AutoResurrect"] = false,
	["AutoResurrectThank"] = false,
	["AutoReward"] = false,
	["AutoSkipCinematic"] = false,
	["AutoSummon"] = false,
	["AutoTabBinder"] = false,
	["CounterSpitters"] = false,
	["NoBadBuffs"] = false,
	["RefillAmmo"] = false,
	["WhisperInvite"] = "inv+",
}

C["Inventory"] = {
	["AutoDeposit"] = false,
	["AutoSell"] = true,
	["BagBar"] = true,
	["BagBarMouseover"] = false,
	["BagsItemLevel"] = false,
	["BagsScale"] = 1,
	["BagsWidth"] = 12,
	["BankWidth"] = 14,
	["DeleteButton"] = true,
	["Enable"] = true,
	["FilterAmmo"] = false,
	["FilterCollection"] = true,
	["FilterConsumable"] = true,
	["FilterEquipment"] = true,
	["FilterFavourite"] = true,
	["FilterGoods"] = false,
	["FilterJunk"] = true,
	["FilterLegendary"] = true,
	["FilterMount"] = false,
	["FilterQuest"] = true,
	["GatherEmpty"] = false,
	["IconSize"] = 34,
	["ItemFilter"] = true,
	["ShowNewItem"] = true,
	["SpecialBagsColor"] = false,
	["UpgradeIcon"] = true,
	["BagSortMode"] = {
		["Options"] = {
			["Forward"] = 1,
			["Backward"] = 2,
			[DISABLE] = 3,
		},
		["Value"] = 1
	},
	["AutoRepair"] = {
		["Options"] = {
			[NONE] = 0,
			[GUILD] = 1,
			[PLAYER] = 2,
		},
		["Value"] = 2
	},
}

-- Buffs & Debuffs
C["Auras"] = {
	["BuffSize"] = 30,
	["BuffsPerRow"] = 16,
	["DebuffSize"] = 34,
	["DebuffsPerRow"] = 16,
	["Enable"] = true,
	["Reminder"] = false,
	["ReverseBuffs"] = false,
	["ReverseDebuffs"] = false,
	["TotemSize"] = 32,
	["Totems"] = true,
	["VerticalTotems"] = true,
}

-- Chat
C["Chat"] = {
	["BlockSpammer"] = true,
	["Background"] = true,
	["BlockAddonAlert"] = false,
	["BlockStranger"] = false,
	["ChatFilterList"] = "%*",
	["ChatFilterWhiteList"] = "",
	["ChatItemLevel"] = true,
	["ChatMenu"] = true,
	["Emojis"] = false,
	["Enable"] = true,
	["EnableFilter"] = true,
	["Fading"] = true,
	["FadingTimeVisible"] = 100,
	["FilterMatches"] = 1,
	["Freedom"] = true,
	["Height"] = 150,
	["Lock"] = true,
	["LogMax"] = 0,
	-- ["LootIcons"] = false,
	["OldChatNames"] = false,
	["Sticky"] = false,
	["WhisperColor"] = true,
	["Width"] = 392,
	["TimestampFormat"] = {
		["Options"] = {
			["Disable"] = 1,
			["03:27 PM"] = 2,
			["03:27:32 PM"] = 3,
			["15:27"] = 4,
			["15:27:32"] = 5,
		},
		["Value"] = 1
	},
}

-- DataBars
C["DataBars"] = {
	["AutoTrackReputation"] = false,
	["Enable"] = true,
	["ExperienceColor"] = {0, .4, 1, .8},
	["Height"] = 14,
	["MouseOver"] = false,
	["PetExperience"] = false,
	["PetExperienceColor"] = {1, 1, 0.41, 0.8},
	["RestedColor"] = {1, 0, 1, .4},
	["Width"] = 180,
	["Text"] = {
		["Options"] = {
			["NONE"] = 0,
			["PERCENT"] = 1,
			["CURMAX"] = 2,
			["CURPERC"] = 3,
			["CUR"] = 4,
			["REM"] = 5,
			["CURREM"] = 6,
			["CURPERCREM"] = 7,
		},
		["Value"] = 1
	},
}

-- Datatext
C["DataText"] = {
	["Coords"] = false,
	["Friends"] = false,
	["Gold"] = false,
	["Guild"] = false,
	["GuildSortBy"] = 1,
	["GuildSortOrder"] = true,
	["HideText"] = false,
	["IconColor"] = {102/255, 157/255, 255/255},
	["Latency"] = true,
	["Location"] = true,
	["System"] = true,
	["Time"] = true,
}

C["AuraWatch"] = {
	["ClickThrough"] = false,
	["Enable"] = true,
	["IconScale"] = 1,
	["WatchSpellRank"] = true,
}

-- General
C["General"] = {
	["AutoScale"] = true,
	["ColorTextures"] = false,
	["MissingTalentAlert"] = true,
	["MoveBlizzardFrames"] = false,
	["NoErrorFrame"] = false,
	["NoTutorialButtons"] = false,
	["TexturesColor"] = {1, 1, 1},
	["UIScale"] = 0.71111,
	["UseGlobal"] = false,
	["VersionCheck"] = true,
	["Welcome"] = true,
	["BorderStyle"] = {
		["Options"] = {
			["KkthnxUI"] = "KkthnxUI",
			["AzeriteUI"] = "AzeriteUI",
			["KkthnxUI_Pixel"] = "KkthnxUI_Pixel",
		},
		["Value"] = "KkthnxUI"
	},
	["NumberPrefixStyle"] = {
		["Options"] = {
			["Standard: b/m/k"] = 1,
			["Asian: y/w"] = 2,
			["Full Digits"] = 3,
		},
		["Value"] = 1
	},
	["Profiles"] = {
		["Options"] = {},
	},
}

-- Loot
C["Loot"] = {
	["AutoConfirm"] = false,
	["AutoGreed"] = false,
	["Enable"] = true,
	["FastLoot"] = false,
	["GroupLoot"] = true,
}

-- Minimap
C["Minimap"] = {
	["Enable"] = true,
	["ShowRecycleBin"] = true,
	["Size"] = 180,
	["RecycleBinPosition"] = {
		["Options"] = {
			["BottomLeft"] = 1,
			["BottomRight"] = 2,
			["TopLeft"] = 3,
			["TopRight"] = 4,
		},
		["Value"] = "BottomLeft"
	},
	["LocationText"] = {
		["Options"] = {
			["Always Display"] = "SHOW",
			["Hide"] = "Hide",
			["Minimap Mouseover"] = "MOUSEOVER",
		},
		["Value"] = "MOUSEOVER"
	},
	["BlipTexture"] = {
		["Options"] = {
			["Blizzard"] = "Interface\\MiniMap\\ObjectIconsAtlas",
			["Charmed"] = "Interface\\AddOns\\KkthnxUI\\Media\\MiniMap\\Blip-Charmed",
			["Nandini"] = "Interface\\AddOns\\KkthnxUI\\Media\\MiniMap\\Blip-Nandini-New",
		},
		["Value"] = "Interface\\MiniMap\\ObjectIconsAtlas"
	},
}

-- Miscellaneous
C["Misc"] = {
	["AFKCamera"] = false,
	["AutoBubbles"] = false,
	["ColorPicker"] = false,
	["EasyMarking"] = false,
	["EnhancedFriends"] = false,
	["EnhancedMail"] = true,
	["ExpandStat"] = true,
	["GemEnchantInfo"] = false,
	["HelmCloakToggle"] = false,
	["HideBossEmote"] = false,
	["ItemLevel"] = false,
	["MailSaver"] = false,
	["MailTarget"] = "",
	["MouseTrail"] = false,
	["MouseTrailColor"] = {1, 1, 1, 0.6},
	["MuteSounds"] = false,
	["PetHappiness"] = false,
	["ShowWowHeadLinks"] = false,
	["SlotDurability"] = false,
	["StatOrder"] = "12345",
	["TradeTabs"] = false,
	["MouseTrailTexture"] = {
		["Options"] = {
			["Circle"] = "Interface\\AddOns\\KkthnxUI\\Media\\Textures\\Aura73",
			["Star"] = "Interface\\Cooldown\\Star4",
		},
		["Value"] = "Interface\\AddOns\\KkthnxUI\\Media\\Textures\\Aura73"
	},
	["ShowMarkerBar"] = {
		["Options"] = {
			["Grids"] = 1,
			["Horizontal"] = 2,
			["Vertical"] = 3,
			[DISABLE] = 4,
		},
		["Value"] = 4
	},
}

C["Nameplate"] = {
	["AuraSize"] = 26,
	["ClassIcon"] = false,
	["ColoredTarget"] = true,
	["CustomColor"] = {0, 0.8, 0.3},
	["CustomUnitColor"] = true,
	["CustomUnitList"] = "",
	["Distance"] = 41,
	["Enable"] = true,
	["ExecuteRatio"] = 0,
	["FriendlyCC"] = false,
	["FullHealth"] = false,
	["HealthTextSize"] = 13,
	["HostileCC"] = true,
	["InsecureColor"] = {1, 0, 0},
	["InsideView"] = true,
	["MaxAuras"] = 5,
	["MinAlpha"] = 1,
	["MinScale"] = 1,
	["NameOnly"] = true,
	["NameTextSize"] = 13,
	["NameplateClassPower"] = true,
	["PPGCDTicker"] = true,
	["PPHeight"] = 5,
	["PPHideOOC"] = true,
	["PPIconSize"] = 32,
	["PPPHeight"] = 6,
	["PPPowerText"] = true,
	["PPWidth"] = 175,
	["PlateHeight"] = 13,
	["PlateWidth"] = 184,
	["PowerUnitList"] = "",
	["QuestIndicator"] = true,
	["SecureColor"] = {1, 0, 1},
	["ShowPlayerPlate"] = false,
	["Smooth"] = false,
	["TankMode"] = false,
	["TargetColor"] = {0, 0.6, 1},
	["TargetIndicatorColor"] = {1, 1, 0},
	["TransColor"] = {1, 0.8, 0},
	["VerticalSpacing"] = 0.7,
	["AuraFilter"] = {
		["Options"] = {
			["White & Black List"] = 1,
			["List & Player"] = 2,
			["List & Player & CCs"] = 3,
		},
		["Value"] = 3
	},
	["TargetIndicator"] = {
		["Options"] = {
			["Disable"] = 1,
			["Top Arrow"] = 2,
			["Right Arrow"] = 3,
			["Border Glow"] = 4,
			["Top Arrow + Glow"] = 5,
			["Right Arrow + Glow"] = 6,
		},
		["Value"] = 4
	},
	["TargetIndicatorTexture"] = {
		["Options"] = {
			["Blue Arrow 2".."|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\BlueArrow2:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\BlueArrow2]],
			["Blue Arrow".."|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\BlueArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\BlueArrow]],
			["Neon Blue Arrow".."|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonBlueArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\NeonBlueArrow]],
			["Neon Green Arrow".."|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonGreenArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\NeonGreenArrow]],
			["Neon Pink Arrow".."|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonPinkArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\NeonPinkArrow]],
			["Neon Red Arrow".."|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonRedArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\NeonRedArrow]],
			["Neon Purple Arrow".."|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonPurpleArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\NeonPurpleArrow]],
			["Purple Arrow".."|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\PurpleArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\PurpleArrow]],
			["Red Arrow 2".."|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedArrow2.tga:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\RedArrow2]],
			["Red Arrow".."|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\RedArrow]],
			["Red Chevron Arrow".."|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedChevronArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\RedChevronArrow]],
			["Red Chevron Arrow2".."|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedChevronArrow2:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\RedChevronArrow2]],
		},
		["Value"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\NeonBlueArrow]]
	},
}

C["PulseCooldown"] = {
	["AnimScale"] = 1.5,
	["Enable"] = false,
	["HoldTime"] = 0.5,
	["Size"] = 75,
	["Sound"] = false,
	["Threshold"] = 3,
}

-- Skins
C["Skins"] = {
	["AtlasLoot"] = false,
	["Bartender4"] = false,
	["BigWigs"] = false,
	["BlizzardFrames"] = true,
	["ChatBubbleAlpha"] = 0.9,
	["ChatBubbles"] = true,
	["DeadlyBossMods"] = false,
	["Details"] = false,
	["Dominos"] = false,
	["EnhancedQuestLog"] = false,
	["EnhancedTradeSkill"] = false,
	["LFGBulletinBoard"] = false,
	["Skada"] = false,
	["WIM"] = false,
	["WeakAuras"] = false,
	["WorldMap"] = true,
}

-- Tooltip
C["Tooltip"] = {
	["ClassColor"] = false,
	["CombatHide"] = false,
	["Cursor"] = false,
	["FactionIcon"] = false,
	["HideJunkGuild"] = true,
	["HideRank"] = true,
	["HideRealm"] = true,
	["HideTitle"] = true,
	["Icons"] = true,
	["ShowIDs"] = false,
	["TargetBy"] = true,
}

-- Fonts
C["UIFonts"] = {
	["ActionBarsFonts"] = "KkthnxUI Outline",
	["AuraFonts"] = "KkthnxUI Outline",
	["ChatFonts"] = "KkthnxUI",
	["DataBarsFonts"] = "KkthnxUI",
	["DataTextFonts"] = "KkthnxUI",
	["FilgerFonts"] = "KkthnxUI Outline",
	["GeneralFonts"] = "KkthnxUI",
	["InventoryFonts"] = "KkthnxUI Outline",
	["MinimapFonts"] = "KkthnxUI",
	["NameplateFonts"] = "KkthnxUI",
	["QuestTrackerFonts"] = "KkthnxUI",
	["SkinFonts"] = "KkthnxUI",
	["TooltipFonts"] = "KkthnxUI",
	["UnitframeFonts"] = "KkthnxUI",
	-- Font Sizes Will Go Here (Not Sure How Much I Care About Improving This)
	["QuestFontSize"] = 11,
}

-- Textures
C["UITextures"] = {
	["DataBarsTexture"] = "KkthnxUI",
	["FilgerTextures"] = "KkthnxUI",
	["GeneralTextures"] = "KkthnxUI",
	["HealPredictionTextures"] = "KkthnxUI",
	["LootTextures"] = "KkthnxUI",
	["NameplateTextures"] = "KkthnxUI",
	["QuestTrackerTexture"] = "KkthnxUI",
	["SkinTextures"] = "KkthnxUI",
	["TooltipTextures"] = "KkthnxUI",
	["UnitframeTextures"] = "KkthnxUI",
}

-- Unitframe
C["Unitframe"] = {
	["PlayerHealthTextSize"] = 12,
	["PlayerPowerTextSize"] = 11,
	["TargetHealthTextSize"] = 12,
	["TargetPowerTextSize"] = 11,
	["AdditionalPower"] = false,
	["AutoAttack"] = true,
	["CastClassColor"] = false,
	["CastReactionColor"] = false,
	["CastbarLatency"] = true,
	["ClassResources"] = true,
	["CombatFade"] = false,
	["CombatText"] = false,
	["DebuffHighlight"] = true,
	["Enable"] = true,
	["EnergyTick"] = true,
	["FCTOverHealing"] = false,
	["FocusFrameHeight"] = 40,
	["FocusFrameWidth"] = 210,
	["FocusPower"] = true,
	["FocusTargetFrameHeight"] = 20,
	["FocusTargetFrameWidth"] = 110,
	["FocusTargetPower"] = true,
	["HidePetLevel"] = true,
	["HidePetName"] = true,
	["HideTargetOfTargetLevel"] = false,
	["HideTargetOfTargetName"] = false,
	["HideTargetofTarget"] = false,
	["HotsDots"] = true,
	["OnlyShowPlayerDebuff"] = false,
	["PetCombatText"] = true,
	["PetFrameHeight"] = 20,
	["PetFrameWidth"] = 110,
	["PetPower"] = true,
	["PlayerBuffs"] = false,
	["PlayerCastbar"] = true,
	["PlayerCastbarHeight"] = 24,
	["PlayerCastbarWidth"] = 260,
	["PlayerDeBuffs"] = false,
	["PlayerFrameHeight"] = 44,
	["PlayerFrameWidth"] = 218,
	["PlayerPower"] = true,
	["PlayerPowerPrediction"] = true,
	["ResurrectSound"] = false,
	["ShowHealPrediction"] = true,
	["ShowPlayerLevel"] = true,
	["ShowPlayerName"] = false,
	["Smooth"] = false,
	["Swingbar"] = false,
	["SwingbarTimer"] = false,
	["TargetBuffs"] = true,
	["TargetBuffsPerRow"] = 6,
	["TargetCastbar"] = true,
	["TargetCastbarHeight"] = 30,
	["TargetCastbarWidth"] = 260,
	["TargetDebuffs"] = true,
	["TargetDebuffsPerRow"] = 5,
	["TargetFrameHeight"] = 44,
	["TargetFrameWidth"] = 218,
	["TargetPower"] = true,
	["TargetTargetFrameHeight"] = 20,
	["TargetTargetFrameWidth"] = 110,
	["TargetTargetPower"] = true,
	["HealthbarColor"] = {
		["Options"] = {
			["Dark"] = "Dark",
			["Value"] = "Value",
			["Class"] = "Class",
		},
		["Value"] = "Class"
	},
	["PortraitStyle"] = {
		["Options"] = {
			["3D Portraits"] = "ThreeDPortraits",
			["Class Portraits"] = "ClassPortraits",
			["New Class Portraits"] = "NewClassPortraits",
			["Default Portraits"] = "DefaultPortraits",
			["No Portraits"] = "NoPortraits"
		},
		["Value"] = "DefaultPortraits"
	},
}

C["Party"] = {
	["Castbars"] = false,
	["Enable"] = true,
	["PortraitTimers"] = false,
	["ShowBuffs"] = true,
	["ShowHealPrediction"] = true,
	["ShowPartySolo"] = false,
	["ShowPet"] = false,
	["ShowPlayer"] = true,
	["Smooth"] = false,
	["TargetHighlight"] = false,
	["HealthbarColor"] = {
		["Options"] = {
			["Dark"] = "Dark",
			["Value"] = "Value",
			["Class"] = "Class",
		},
		["Value"] = "Class"
	},
}

C["Arena"] = {
	["Castbars"] = true,
	["Enable"] = true,
	["Height"] = 34,
	["Power"] = true,
	["Smooth"] = false,
	["Width"] = 174,
	["HealthbarColor"] = {
		["Options"] = {
			["Dark"] = "Dark",
			["Value"] = "Value",
			["Class"] = "Class",
		},
		["Value"] = "Class"
	},
}

-- Raidframe
C["Raid"] = {
	-- ["SpecRaidPos"] = false,
	["AuraTrackIcons"] = true,
	["AuraTrackSpellTextures"] = true,
	["AuraTrackThickness"] = 5,
	["DebuffWatch"] = true,
	["DebuffWatchDefault"] = true,
	["DesaturateBuffs"] = false,
	["Enable"] = true,
	["Height"] = 40,
	["HorizonRaid"] = false,
	["MainTankFrames"] = true,
	["ManabarShow"] = false,
	["NumGroups"] = 6,
	["RaidUtility"] = false,
	["ReverseRaid"] = false,
	["ShowHealPrediction"] = true,
	["ShowNotHereTimer"] = true,
	["ShowRaidSolo"] = false,
	["ShowTeamIndex"] = false,
	["Smooth"] = false,
	["TargetHighlight"] = false,
	["Width"] = 66,
	["RaidBuffsStyle"] = {
		["Options"] = {
			["Aura Track"] = "Aura Track",
			["Standard"] = "Standard",
			["None"] = "None",
		},
		["Value"] = "Aura Track",
	},
	["RaidBuffs"] = {
		["Options"] = {
			["Only my buffs"] = "Self",
			["Only castable buffs"] = "Castable",
			["All buffs"] = "All",
		},
		["Value"] = "Self",
	},
	["HealthbarColor"] = {
		["Options"] = {
			["Dark"] = "Dark",
			["Value"] = "Value",
			["Class"] = "Class",
		},
		["Value"] = "Class"
	},
	["HealthFormat"] = {
		["Options"] = {
			["Disable HP"] = 1,
			["Health Percentage"] = 2,
			["Health Remaining"] = 3,
			["Health Lost"] = 4,
		},
		["Value"] = 1
	},
}

-- Worldmap
C["WorldMap"] = {
	["AlphaWhenMoving"] = 0.35,
	["AutoZoneChange"] = true,
	["Coordinates"] = true,
	["FadeWhenMoving"] = true,
	["MapRevealGlow"] = true,
	["MapRevealGlowColor"] = {0.4, 0.61, 1},
	["RememberZoom"] = true,
	["SmallWorldMap"] = true,
}