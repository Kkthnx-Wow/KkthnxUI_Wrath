local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("WorldMap")

local _G = _G

local GetLocale = _G.GetLocale
local IsAddOnLoaded = _G.IsAddOnLoaded
local hooksecurefunc = _G.hooksecurefunc
local setmetatable = _G.setmetatable

-- Wowhead Links
local GameLocale = GetLocale()
function Module:CreateWowHeadLinks()
	if not C["Misc"].ShowWowHeadLinks or IsAddOnLoaded("Leatrix_Maps") then
		return
	end

	-- Add wowhead link by Goldpaw "Lars" Norberg
	local subDomain = (setmetatable({
		ruRU = "ru",
		frFR = "fr", deDE = "de",
		esES = "es", esMX = "es",
		ptBR = "pt", ptPT = "pt", itIT = "it",
		koKR = "ko", zhTW = "cn", zhCN = "cn"
	}, { __index = function(t, v) return "www" end }))[GameLocale]

	local wowheadLoc = subDomain..".wowhead.com"
	local urlQuestIcon = [[|TInterface\OptionsFrame\UI-OptionsFrame-NewFeatureIcon:0:0:0:0|t]]

	-- Create editbox
	local mEB = CreateFrame("EditBox", nil, QuestLogFrame)
	mEB:ClearAllPoints()
	mEB:SetPoint("TOPLEFT", 70, 4)
	mEB:SetHeight(16)
	mEB:SetFontObject("GameFontNormal")
	mEB:SetBlinkSpeed(0)
	mEB:SetAutoFocus(false)
	mEB:EnableKeyboard(false)
	mEB:SetHitRectInsets(0, 90, 0, 0)
	mEB:SetScript("OnKeyDown", function() end)
	mEB:SetScript("OnMouseUp", function()
		if mEB:IsMouseOver() then
			mEB:HighlightText()
		else
			mEB:HighlightText(0, 0)
		end
	end)

	-- Set the background color
	mEB.t = mEB:CreateTexture(nil, "BACKGROUND")
	mEB.t:SetPoint(mEB:GetPoint())
	mEB.t:SetSize(mEB:GetSize())
	mEB.t:SetColorTexture(0.05, 0.05, 0.05, 1.0)

	-- Create hidden font string (used for setting width of editbox)
	mEB.z = mEB:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	mEB.z:Hide()

	-- Function to set editbox value
	local function SetQuestInBox(questListID)

		local questTitle, _, _, isHeader, _, _, _, questID = GetQuestLogTitle(questListID)
		if questID and not isHeader then

			-- Hide editbox if quest ID is invalid
			if questID == 0 then mEB:Hide() else mEB:Show() end

			-- Set editbox text
			mEB:SetText(urlQuestIcon.."https://" .. wowheadLoc .. "/quest=" .. questID)

			-- Set hidden fontstring then resize editbox to match
			mEB.z:SetText(mEB:GetText())
			mEB:SetWidth(mEB.z:GetStringWidth() + 90)
			mEB.t:SetWidth(mEB.z:GetStringWidth())

			-- Get quest title for tooltip
			if questTitle then
				mEB.tiptext = questTitle .. "|n" .. L["Press To Copy"]
			else
				mEB.tiptext = ""
				if mEB:IsMouseOver() and GameTooltip:IsShown() then
					GameTooltip:Hide()
				end
			end

		end
	end

	-- Set URL when quest is selected
	hooksecurefunc("QuestLog_SetSelection", function(questListID)
		SetQuestInBox(questListID)
	end)

	-- Create tooltip
	mEB:HookScript("OnEnter", function()
		mEB:HighlightText()
		mEB:SetFocus()
		GameTooltip:SetOwner(mEB, "ANCHOR_BOTTOM", 0, -10)
		GameTooltip:SetText(mEB.tiptext, nil, nil, nil, nil, true)
		GameTooltip:Show()
	end)

	mEB:HookScript("OnLeave", function()
		mEB:HighlightText(0, 0)
		mEB:ClearFocus()
		GameTooltip:Hide()
	end)
end