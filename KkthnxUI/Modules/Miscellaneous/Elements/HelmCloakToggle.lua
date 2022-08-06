local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

function Module:CreateHelmCloakToggle()
	if not C["Misc"].HelmCloakToggle then
		return
	end

    local KKUI_ShowHelm = CreateFrame("CheckButton", "KKUI_ShowHelmButton", PaperDollFrame, "ChatConfigCheckButtonTemplate")
	KKUI_ShowHelm:SetPoint("TOPLEFT", 70, -246)
	KKUI_ShowHelm:SetSize(16, 16)
	KKUI_ShowHelm:SetFrameStrata("HIGH")
	KKUI_ShowHelm:SkinCheckBox()
	KKUI_ShowHelm:SetAlpha(0.25)

	local KKUI_ShowHelm_Text = KKUI_ShowHelm:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	KKUI_ShowHelm_Text:SetText("Helm")
	KKUI_ShowHelm_Text:SetPoint("LEFT", KKUI_ShowHelm, "RIGHT", 4, 0)
	KKUI_ShowHelm:SetHitRectInsets(3, -KKUI_ShowHelm_Text:GetStringWidth(), 0, 0)

	KKUI_ShowHelm:HookScript("OnEnter", function(self)
		UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)
	end)

	KKUI_ShowHelm:HookScript("OnLeave", function(self)
		UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)
	end)

	KKUI_ShowHelm:HookScript("OnClick", function(self)
		self:Disable()
		self:SetAlpha(1.0)
		C_Timer.After(0.5, function()
			if ShowingHelm() then
				ShowHelm(false)
			else
				ShowHelm(true)
			end
			self:Enable()
			if not self:IsMouseOver() then
				self:SetAlpha(0.25)
			end
		end)
	end)

	local KKUI_ShowCloak = CreateFrame("CheckButton", "KKUI_ShowCloakButton", PaperDollFrame, "ChatConfigCheckButtonTemplate")
	KKUI_ShowCloak:SetPoint("TOPLEFT", 277, -246)
	KKUI_ShowCloak:SetSize(16, 16)
	KKUI_ShowCloak:SetFrameStrata("HIGH")
	KKUI_ShowCloak:SkinCheckBox()
	KKUI_ShowCloak:SetAlpha(0.25)

	local KKUI_ShowCloak_Text = KKUI_ShowCloak:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	KKUI_ShowCloak_Text:SetJustifyH("RIGHT")
	KKUI_ShowCloak_Text:SetWordWrap(false)
	KKUI_ShowCloak_Text:SetText("Cloak")
	KKUI_ShowCloak_Text:SetPoint("RIGHT", KKUI_ShowCloak, "LEFT", -2, 0)
	KKUI_ShowCloak:SetHitRectInsets(-KKUI_ShowCloak_Text:GetStringWidth(), 3, 0, 0)

	KKUI_ShowCloak:HookScript("OnEnter", function(self)
		UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)
	end)

	KKUI_ShowCloak:HookScript("OnLeave", function(self)
		UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)
	end)

	KKUI_ShowCloak:HookScript("OnClick", function(self)
		self:Disable()
		self:SetAlpha(1.0)
		C_Timer.After(0.5, function()
			if ShowingCloak() then
				ShowCloak(false)
			else
				ShowCloak(true)
			end
			self:Enable()
			if not self:IsMouseOver() then
				self:SetAlpha( 0.25)
			end
		end)
	end)

	KKUI_ShowCloak:HookScript("OnShow", function()
		if ShowingHelm() then
			KKUI_ShowHelm:SetChecked(true)
		else
			KKUI_ShowHelm:SetChecked(false)
		end

		if ShowingCloak() then
			KKUI_ShowCloak:SetChecked(true)
		else
			KKUI_ShowCloak:SetChecked(false)
		end
	end)
end