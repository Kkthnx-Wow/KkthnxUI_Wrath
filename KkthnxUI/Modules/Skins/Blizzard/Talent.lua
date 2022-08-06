local K, C = unpack(select(2, ...))

local _G = _G

C.themes["Blizzard_TalentUI"] = function()
	for i = 1, _G.MAX_NUM_TALENTS do
		local talent = _G["PlayerTalentFrameTalent"..i]
		local icon = _G["PlayerTalentFrameTalent"..i.."IconTexture"]
		local rank = _G["PlayerTalentFrameTalent"..i.."Rank"]

		if talent then
			talent:StripTextures()
			talent:CreateBorder()
			talent:StyleButton()

			icon:SetAllPoints()
			icon:SetTexCoord(unpack(K.TexCoords))
			icon:SetDrawLayer("ARTWORK")

			rank:SetFont(C["Media"].Fonts.KkthnxUIFont, 12, "OUTLINE")
			rank:SetShadowOffset(0, 0)
		end
	end
end