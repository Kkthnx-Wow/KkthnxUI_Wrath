local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Skins")

function Module:ReskinTellMeWhen()
	if not IsAddOnLoaded("TellMeWhen") then
		return
	end

	if not C["Skins"].TellMeWhen then
		return
	end

	TMW.Classes.Icon:PostHookMethod("OnNewInstance", function(self)
		if not self.bg then
			self.bg = CreateFrame("Frame", nil, self)
			self.bg:SetFrameLevel(self:GetFrameLevel())
			self.bg:SetAllPoints(self)
			self.bg:CreateBorder()
		end
	end)

	TMW.Classes.IconModule_Texture:PostHookMethod("OnNewInstance", function(self)
		self.texture:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	end)
end
