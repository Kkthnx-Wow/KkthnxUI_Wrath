local _, C = unpack(select(2, ...))

local _G = _G

C.NameplateWhiteList = {
	-- Buffs
	[642]	= true,	-- 圣盾术
	[1022]	= true,	-- 保护之手
	[23920]	= true,	-- 法术反射
	[45438]	= true,	-- 寒冰屏障
	-- Debuffs
	[2094]	= true,	-- 致盲
}

C.NameplateBlackList = {
	[15407] = true, -- 精神鞭笞
}

C.NameplateCustomUnits = {
	[120651] = true, -- 爆炸物
}

C.NameplateShowPowerList = {
	[155432] = true, -- 魔力使者
}

C.PlayerNameplateWhiteList = {
	-- Druid
	[2893] = true,	-- Abolish Poison
	[22812] = true,	-- Barkskin
	[1850] = true,	-- Dash
	[5229] = true,	-- Enrage
	[22842] = true,	-- Frenzied Regeneration
	[29166] = true,	-- Innervate
	-- [24932] = true,	-- Leader of the Pack
	[33763] = true,	-- Lifebloom
	-- [45281] = true,	-- Natural Perfection
	-- [16886] = true,	-- Nature's Grace
	[16689] = true,	-- Nature's Grasp
	[17116] = true,	-- Nature's Swiftness
	-- [16870] = true,	-- Omen of Clarity (Clearcasting)
	-- [5215] = true,	-- Prowl
	[8936] = true,	-- Regrowth
	[774] = true,	-- Rejuvenation
	-- [34123] = true,	-- Tree of Life
	[5217] = true,	-- Tiger's Fury
	-- [5225] = true,	-- Track Humanoids
	[740] = true,	-- Tranquility

	-- Hunter
	-- [13161] = true,	-- Aspect of the Beast
	[5118] = true,	-- Aspect of the Cheetah
	-- [13165] = true,	-- Aspect of the Hawk
	-- [13163] = true,	-- Aspect of the Monkey
	[13159] = true,	-- Aspect of the Pack
	[34074] = true,	-- Aspect of the Viper
	-- [20043] = true,	-- Aspect of the Wild
	[19574] = true,	-- Bestial Wrath
	[25077] = true,	-- Cobra Reflexes
	[23099] = true,	-- Dash (Pet)
	[19263] = true,	-- Deterrence
	[23145] = true,	-- Dive (Pet)
	[1002] = true,	-- Eyes of the Beast
	-- [1539] = true,	-- Feed Pet Effect
	[5384] = true,	-- Feign Death
	-- [34456] = true,	-- Ferocious Inspiration
	[19615] = true,	-- Frenzy Effect
	[24604] = true,	-- Furious Howl (Wolf)
	[34833] = true,	-- Master Tactician
	[136] = true,	-- Mend Pet
	-- [24450] = true,	-- Prowl (Cat)
	[3045] = true,	-- Rapid Fire
	[35098] = true,	-- Rapid Killing
	[26064] = true,	-- Shell Shield (Turtle)
	-- [19579] = true,	-- Spirit Bond
	-- [1515] = true,	-- Tame Beast
	[34471] = true,	-- The Beast Within
	-- [1494] = true,	-- Track Beasts
	-- [19878] = true,	-- Track Demons
	-- [19879] = true,	-- Track Dragonkin
	-- [19880] = true,	-- Track Elementals
	-- [19882] = true,	-- Track Giants
	-- [19885] = true,	-- Track Hidden
	-- [19883] = true,	-- Track Humanoids
	-- [19884] = true,	-- Track Undead
	-- [19506] = true,	-- Trueshot Aura
	[35346] = true,	-- Warp (Pet)

	-- Mage
	-- [12536] = true,	-- Arcane Concentration (Clearcasting)
	[12042] = true,	-- Arcane Power
	[31643] = true,	-- Blazing Speed
	[28682] = true,	-- Combustion
	[543] = true,	-- Fire Ward
	[6143] = true,	-- Frost Ward
	[11426] = true,	-- Ice Barrier
	[11958] = true,	-- Ice Block
	[12472] = true,	-- Icy Veins
	[47000] = true,	-- Improved Blink
	-- [66] = true,		-- Invisibility
	[1463] = true,	-- Mana Shield
	[130] = true,	-- Slow Fall
	[12043] = true,	-- Presence of Mind

	-- Paladin
	[31884] = true,	-- Avenging Wrath
	[1044] = true,	-- Blessing of Freedom
	[1022] = true,	-- Blessing of Protection
	[6940] = true,	-- Blessing of Sacrifice
	-- [19746] = true,	-- Concentration Aura
	-- [32223] = true,	-- Crusader Aura
	-- [465] = true,	-- Devotion Aura
	[20216] = true,	-- Divine Favor
	[31842] = true,	-- Divine Illumination
	-- [19752] = true,	-- Divine Intervention
	[498] = true,	-- Divine Protection
	[642] = true,	-- Divine Shield
	-- [19891] = true,	-- Fire Resistance Aura
	-- [19888] = true,	-- Frost Resistance Aura
	[20925] = true,	-- Holy Shield
	[20233] = true,	-- Lay on Hands (Armor Bonus)
	-- [31834] = true,	-- Light's Grace
	-- [20178] = true,	-- Reckoning
	-- [20128] = true,	-- Redoubt
	-- [7294] = true,	-- Retribution Aura
	-- [20218] = true,	-- Sanctity Aura
	[31892] = true,	-- Seal of Blood
	[27170] = true,	-- Seal of Command
	[20164] = true,	-- Seal of Justice
	[20165] = true,	-- Seal of Light
	[21084] = true,	-- Seal of Righteousness
	[31801] = true,	-- Seal of Vengeance
	[20166] = true,	-- Seal of Wisdom
	[21082] = true,	-- Seal of the Crusader
	-- [5502] = true,	-- Sense Undead
	-- [19876] = true,	-- Shadow Resistance Aura
	[20050] = true,	-- Vengeance

	-- Priest
	[552] = true,	-- Abolish Disease
	[27813] = true,	-- Blessed Recovery
	[33143] = true,	-- Blessed Resilience
	[2651] = true,	-- Elune's Grace
	-- [586] = true,	-- Fade
	[6346] = true,	-- Fear Ward
	[13896] = true,	-- Feedback
	-- [45237] = true,	-- Focused Will
	-- [34754] = true,	-- Holy Concentration (Clearcasting)
	[588] = true,	-- Inner Fire
	[14751] = true,	-- Inner Focus
	[14893] = true,	-- Inspiration
	[1706] = true,	-- Levitate
	[7001] = true,	-- Lightwell Renew
	-- [14743] = true,	-- Martyrdom (Focused Casting)
	[10060] = true,	-- Power Infusion
	[33206] = true,	-- Pain Suppression
	[17] = true,		-- Power Word: Shield
	[41635] = true,	-- Prayer of Mending
	[139] = true,	-- Renew
	-- [15473] = true,	-- Shadowform
	[18137] = true,	-- Shadowguard
	[27827] = true,	-- Spirit of Redemption
	[15271] = true,	-- Spirit Tap
	-- [33150] = true,	-- Surge of Light
	[32548] = true,	-- Symbol of Hope
	[2652] = true,	-- Touch of Weakness
	-- [15290] = true,	-- Vampiric Embrace
	-- [34919] = true,	-- Vampiric Touch

	-- Rogue
	[13750] = true,	-- Adrenaline Rush
	[13877] = true,	-- Blade Flurry
	[31224] = true,	-- Cloak of Shadows
	[14177] = true,	-- Cold Blood
	[5277] = true,	-- Evasion
	[31234] = true,	-- Find Weakness
	[14278] = true,	-- Ghostly Strike
	[5171] = true,	-- Slice and Dice
	[2983] = true,	-- Sprint
	-- [1784] = true,	-- Stealth
	-- [31621] = true,	-- Stealth (Vanish)
	[14143] = true,	-- Remorseless Attacks
	[36563] = true,	-- Shadowstep

	-- Shaman
	[2825] = true,	-- Bloodlust
	[974] = true,	-- Earth Shield
	[30165] = true,	-- Elemental Devastation
	-- [16246] = true,	-- Elemental Focus (Clearcasting)
	[16166] = true,	-- Elemental Mastery
	-- [29063] = true,	-- Eye of the Storm (Focused Casting)
	-- [8185] = true,	-- Fire Resistance Totem
	[16257] = true,	-- Flurry
	-- [8182] = true,	-- Frost Resistance Totem
	-- [2645] = true,	-- Ghost Wolf
	-- [8836] = true,	-- Grace of Air
	[8178] = true,	-- Grounding Totem Effect
	-- [5672] = true,	-- Healing Stream
	[29203] = true,	-- Healing Way
	[32182] = true,	-- Heroism
	[324] = true,	-- Lightning Shield
	-- [5677] = true,	-- Mana Spring Totem
	[16191] = true,	-- Mana Tide Totem
	[16188] = true,	-- Nature's Swiftness
	-- [10596] = true,	-- Nature Resistance Totem
	-- [6495] = true,	-- Sentry Totem
	-- [43339] = true,	-- Shamanistic Focus (Focused)
	[30823] = true,	-- Shamanistic Rage
	-- [8072] = true,	-- Stoneskin Totem
	-- [8076] = true,	-- Strength of Earth
	-- [30708] = true,	-- Totem of Wrath
	[30803] = true,	-- Unleashed Rage
	[24398] = true,	-- Water Shield
	-- [15108] = true,	-- Windwall Totem
	-- [2895] = true,	-- Wrath of Air Totem

	-- Warlock
	[18288] = true,	-- Amplify Curse
	[34936] = true,	-- Backlash
	-- [6307] = true,	-- Blood Pact (Imp)
	[17767] = true,	-- Consume Shadows (Voidwalker)
	[126] = true,	-- Eye of Kilrogg
	[2947] = true,	-- Fire Shield (Imp)
	[755] = true,	-- Health Funnel
	[1949] = true,	-- Hellfire
	-- [7870] = true,	-- Lesser Invisibility (Succubus)
	-- [23759] = true,	-- Master Demonologist (Imp - Reduced Threat)
	-- [23760] = true,	-- Master Demonologist (Voidwalker - Reduced Physical Taken)
	-- [23761] = true,	-- Master Demonologist (Succubus - Increased Damage)
	-- [23762] = true,	-- Master Demonologist (Felhunter - Increased Resistance)
	-- [35702] = true,	-- Master Demonologist (Felguard - Increased Damage/Resistance)
	[30300] = true,	-- Nether Protection
	-- [19480] = true,	-- Paranoia (Felhunter)
	-- [4511] = true,	-- Phase Shift (Imp)
	[7812] = true,	-- Sacrifice (Voidwalker)
	-- [5500] = true,	-- Sense Demons
	[17941] = true,	-- Shadow Trance
	[6229] = true,	-- Shadow Ward
	[20707] = true,	-- Soulstone Resurrection
	[25228] = true,	-- Soul Link
	[19478] = true,	-- Tainted Blood (Felhunter)

	-- Warrior
	[6673] = true,	-- Battle Shout
	[18499] = true,	-- Berserker Rage
	[29131] = true,	-- Bloodrage
	[23885] = true,	-- Bloodthirst
	[16488] = true,	-- Blood Craze
	[469] = true,	-- Commanding Shout
	[12292] = true,	-- Death Wish
	[12880] = true,	-- Enrage
	[12966] = true,	-- Flurry
	[3411] = true,	-- Intervene
	[12975] = true,	-- Last Stand
	-- [29801] = true,	-- Rampage (Base)
	[30029] = true,	-- Rampage (Stack)
	[1719] = true,	-- Recklessness
	[20230] = true,	-- Retaliation
	[29841] = true,	-- Second Wind
	[871] = true,	-- Shield Wall
	[23920] = true,	-- Spell Reflection
	[12328] = true,	-- Sweeping Strikes

	-- Racial
	[20554] = true,	-- Berserking (Mana)
	-- [26296] = true,	-- Berserking (Rage)
	-- [26297] = true,	-- Berserking (Energy)
	-- [20572] = true,	-- Blood Fury (Physical)
	[33697] = true,	-- Blood Fury (Both)
	-- [33702] = true,	-- Blood Fury (Spell)
	-- [2481] = true,	-- Find Treasure
	[28880] = true,	-- Gift of the Naaru
	[20600] = true,	-- Perception
	-- [20580] = true,	-- Shadowmeld
	[20594] = true,	-- Stoneform
	[7744] = true,	-- Will of the Forsaken
}