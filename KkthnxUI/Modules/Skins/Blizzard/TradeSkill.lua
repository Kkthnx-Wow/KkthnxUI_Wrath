local K, C = unpack(select(2, ...))

local _G = _G

C.themes["Blizzard_TradeSkillUI"] = function()
	TradeSkillRankFrame:SetStatusBarTexture(K.GetTexture(C["UITextures"].SkinTextures))
	TradeSkillRankFrame.SetStatusBarColor = K.Noop
	--TradeSkillRankFrame:GetStatusBarTexture():SetGradient("VERTICAL", .1, .3, .9, .2, .4, 1)
end