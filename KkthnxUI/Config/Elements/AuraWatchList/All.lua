local K, _, L = unpack(KkthnxUI)
local Module = K:GetModule("AurasTable")

-- 全职业的相关监控
local list = {
	["Enchant Aura"] = { -- 附魔及饰品组
		-- 种族天赋
		{ AuraID = 58984, UnitID = "player" }, -- 影遁 暗夜
		{ AuraID = 20594, UnitID = "player" }, -- 石像形态 矮人
		{ AuraID = 26297, UnitID = "player" }, -- 狂暴 巨魔
		{ AuraID = 20572, UnitID = "player" }, -- 血性狂暴 兽人
		{ AuraID = 33697, UnitID = "player" }, -- 血性狂暴 兽人
		{ AuraID = 33702, UnitID = "player" }, -- 血性狂暴 兽人
		-- 附魔药水
		{ AuraID = 28093, UnitID = "player" }, -- 闪电之速，猫鼬
		{ AuraID = 28515, UnitID = "player" }, -- 铁盾药水
		{ AuraID = 28504, UnitID = "player" }, -- 特效无梦睡眠药水
		{ AuraID = 28506, UnitID = "player" }, -- 英雄药水
		{ AuraID = 28507, UnitID = "player" }, -- 加速药水
		{ AuraID = 28508, UnitID = "player" }, -- 毁灭药水
		--{AuraID = 28511, UnitID = "player"},	-- 防护火焰药水
		--{AuraID = 28512, UnitID = "player"},	-- 防护冰霜药水
		--{AuraID = 28513, UnitID = "player"},	-- 防护自然药水
		--{AuraID = 28537, UnitID = "player"},	-- 防护暗影药水
		--{AuraID = 28538, UnitID = "player"},	-- 防护神圣药水
		-- 饰品
	},
	["Raid Buff"] = { -- 团队增益组
		-- 战鼓
		{ AuraID = 35474, UnitID = "player" }, -- 恐慌之鼓
		{ AuraID = 35475, UnitID = "player" }, -- 战争之鼓
		{ AuraID = 35476, UnitID = "player" }, -- 战斗之鼓
		{ AuraID = 35477, UnitID = "player" }, -- 速度之鼓
		{ AuraID = 35478, UnitID = "player" }, -- 恢复之鼓
		-- 团队增益或减伤
		{ AuraID = 2825, UnitID = "player" }, -- 嗜血
		{ AuraID = 32182, UnitID = "player" }, -- 英勇
		{ AuraID = 1022, UnitID = "player" }, -- 保护祝福
		{ AuraID = 6940, UnitID = "player" }, -- 牺牲祝福
		{ AuraID = 1044, UnitID = "player" }, -- 自由祝福
		{ AuraID = 29166, UnitID = "player" }, -- 激活
		{ AuraID = 10060, UnitID = "player" }, -- 能量灌注
		{ AuraID = 13159, UnitID = "player" }, -- 豹群守护
	},
	["Raid Debuff"] = { -- 团队减益组
		--{AuraID = 209858, UnitID = "player"},	-- 死疽溃烂
	},
	["Warning"] = { -- 目标重要光环组
		--{AuraID = 226510, UnitID = "target"},	-- 血池回血
		-- PVP
		{ AuraID = 498, UnitID = "target" }, -- 圣佑术
		{ AuraID = 642, UnitID = "target" }, -- 圣盾术
		{ AuraID = 871, UnitID = "target" }, -- 盾墙
		{ AuraID = 5277, UnitID = "target" }, -- 闪避
		{ AuraID = 1044, UnitID = "target" }, -- 自由祝福
		{ AuraID = 6940, UnitID = "target" }, -- 牺牲祝福
		{ AuraID = 1022, UnitID = "target" }, -- 保护祝福
		{ AuraID = 19574, UnitID = "target" }, -- 狂野怒火
		{ AuraID = 23920, UnitID = "target" }, -- 法术反射
		{ AuraID = 33206, UnitID = "target" }, -- 痛苦压制
	},
	["InternalCD"] = { -- 自定义内置冷却组
		--{IntID = 240447, Duration = 20},	-- 践踏
	},
}

Module:AddNewAuraWatch("ALL", list)
