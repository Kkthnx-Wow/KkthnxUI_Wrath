local _, C = unpack(KkthnxUI)

-- Reminder Buffs Checklist
C.SpellReminderBuffs = {
	MAGE = {
		{
			spells = { -- 奥术智慧
				[1459] = true,
				[8096] = true, -- 智力卷轴
				[23028] = true, -- 奥术光辉
				[46302] = true, -- 基鲁的胜利之歌
			},
			depend = 1459,
			combat = true,
			instance = true,
			pvp = true,
		},
		{
			spells = {
				[168] = true, -- 霜甲术
				[7302] = true, -- 冰甲术
				[6117] = true, -- 法师护甲
				[30482] = true, -- 熔岩护甲
			},
			depend = 168,
			combat = true,
			instance = true,
			pvp = true,
		},
	},
	PRIEST = {
		{
			spells = { -- 真言术耐
				[1243] = true,
				[8099] = true, -- 耐力卷轴
				[21562] = true, -- 坚韧祷言
			},
			depend = 1243,
			combat = true,
			instance = true,
			pvp = true,
		},
		{
			spells = { -- 心灵之火
				[588] = true,
			},
			depend = 588,
			pvp = true,
		},
	},
	DRUID = {
		{
			spells = { -- 野性印记
				[1126] = true,
				[21849] = true, -- 野性赐福
			},
			depend = 1126,
			combat = true,
			instance = true,
			pvp = true,
		},
		{
			spells = { --- 荆棘术
				[467] = true,
			},
			depend = 467,
			pvp = true,
		},
	},
	WARRIOR = {
		{
			spells = { -- 战斗怒吼
				[6673] = true,
			},
			depends = { 6673, 5242, 6192, 11549, 11550, 11551, 25289, 2048 },
			gemini = {
				[GetSpellInfo(469)] = true, -- 命令怒吼
			},
			combat = true,
			instance = true,
			pvp = true,
		},
		{
			spells = { -- 命令怒吼
				[469] = true,
			},
			depend = 469,
			gemini = {
				[GetSpellInfo(6673)] = true, -- 战斗怒吼
			},
			combat = true,
			instance = true,
			pvp = true,
		},
	},
	HUNTER = {
		{
			spells = { -- 雄鹰守护
				[13165] = true,
				[61846] = true, -- 龙鹰
			},
			depend = 13165,
			combat = true,
			instance = true,
			pvp = true,
		},
		{
			spells = { --- 强击光环
				[19506] = true,
			},
			depend = 19506,
			combat = true,
			instance = true,
			pvp = true,
		},
	},
	WARLOCK = {
		{
			spells = {
				[28176] = true, -- 邪甲术
				[706] = true, -- 魔甲术
				[687] = true, -- 恶魔皮肤
			},
			depend = 28176,
			combat = true,
			instance = true,
			pvp = true,
		},
	},
	DEATHKNIGHT = {
		{
			spells = { -- 寒冬号角
				[57330] = true,
			},
			depend = 57330,
			combat = true,
			instance = true,
			pvp = true,
		},
	},
}
