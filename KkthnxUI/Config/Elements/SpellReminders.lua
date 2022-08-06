local _, C = unpack(select(2, ...))

-- Reminder Buffs Checklist
C.SpellReminderBuffs = {
	MAGE = {
			{	spells = {
				[1459] = true, -- Arcane Intellect(Rank 1)
				[8096] = true, -- Intellect(Rank 1)
				[23028] = true, -- Arcane Brilliance(Rank 1)
			},
			depend = 1459,
			combat = true,
			instance = true,
			pvp = true,
		},
	},
	PRIEST = {
			{	spells = {
				[1243] = true, -- Power Word: Fortitude(Rank 1)
				[8099] = true, -- Stamina(Rank 1)
				[21562] = true, -- Prayer of Fortitude(Rank 1)
			},
			depend = 1243,
			combat = true,
			instance = true,
			pvp = true,
		},
			{	spells = {
				[588] = true, -- Inner Fire(Rank 1)
			},
			depend = 588,
			pvp = true,
		},
	},
	DRUID = {
			{	spells = {
				[1126] = true, -- Mark of the Wild(Rank 1)
				[21849] = true, -- Gift of the Wild(Rank 1)
			},
			depend = 1126,
			combat = true,
			instance = true,
			pvp = true,
		},
			{	spells = {
				[467] = true, -- Thorns(Rank 1)
			},
			depend = 467,
			pvp = true,
		},
	},
	WARRIOR = {
			{	spells = {
				[6673] = true, -- Battle Shout(Rank 1)
				[25289] = true, -- Battle Shout(Rank 7)
			},
			depends = {6673, 5242, 6192, 11549, 11550, 11551, 25289, 2048},
			combat = true,
			instance = true,
			pvp = true,
		},
	},
	HUNTER = {
			{	spells = {
				[13165] = true, -- Aspect of the Hawk(Rank 1)
			},
			depend = 13165,
			combat = true,
			instance = true,
			pvp = true,
		},
			{	spells = {
				[19506] = true, -- Trueshot Aura(Rank 1)
			},
			depend = 19506,
			combat = true,
			instance = true,
			pvp = true,
		},
	},
	WARLOCK = {
			{	spells = {
				[28176] = true,	-- Fel Armor(Rank 1)
				[706] = true, -- Demon Armor(Rank 1)
			},
			depend = 28176,
			combat = true,
			instance = true,
			pvp = true,
		},
	},
}