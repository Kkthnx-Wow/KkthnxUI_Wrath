local K, C = unpack(select(2, ...))

-- Sourced: ElvUI (Elvz, Blazeflack)

local _G = _G
local math_max = math.max

local CreateFrame = _G.CreateFrame
local GetAddOnInfo = _G.GetAddOnInfo
local GetLocale = _G.GetLocale
local GetNumAddOns = _G.GetNumAddOns

local Status = CreateFrame("Frame", "KKUI_Status", UIParent)

function Status:AddonsCheck()
	for i = 1, GetNumAddOns() do
		local Name = GetAddOnInfo(i)
		if ((Name ~= "KkthnxUI") and IsAddOnLoaded(Name)) then
			return "Yes"
		end
	end

	return "No"
end

function Status:ShowWindow()
	self:Show()
	self:SetSize(300, 350)
	self:SetPoint("CENTER")
	self:CreateBorder()

	K.CreateMoverFrame(self)

	self.Logo = self:CreateTexture(nil, "OVERLAY")
	self.Logo:SetSize(512, 256)
	self.Logo:SetBlendMode("ADD")
	self.Logo:SetAlpha(0.04)
	self.Logo:SetTexture(C["Media"].Textures.LogoTexture)
	self.Logo:SetPoint("CENTER", self, "CENTER", 0, 0)

	self.Title = self:CreateFontString(nil, "OVERLAY")
	self.Title:SetFont(C["Media"].Fonts.KkthnxUIFont, 16, "THINOUTLINE")
	self.Title:SetPoint("TOP", 0, 20)
	self.Title:SetText(K.InfoColor.."Debug Status Window")

	self.Version = self:CreateFontString(nil, "OVERLAY")
	self.Version.Value = K.Version
	self.Version:SetFont(C["Media"].Fonts.KkthnxUIFont, 12, "THINOUTLINE")
	self.Version:SetPoint("TOP", 0, -24)
	self.Version:SetText(K.SystemColor.."KkthnxUI Version: "..K.GreyColor..self.Version.Value)

	self.Addons = self:CreateFontString(nil, "OVERLAY")
	self.Addons.Value = self.AddonsCheck()
	self.Addons:SetFont(C["Media"].Fonts.KkthnxUIFont, 12, "THINOUTLINE")
	self.Addons:SetPoint("TOP", self.Version, 0, -20)
	self.Addons:SetText(K.SystemColor.."Other AddOns Enabled: "..K.GreyColor..self.Addons.Value)

	self.UIScale = self:CreateFontString(nil, "OVERLAY")
	self.UIScale.Value = C.General.UIScale
	self.UIScale:SetFont(C["Media"].Fonts.KkthnxUIFont, 12, "THINOUTLINE")
	self.UIScale:SetPoint("TOP", self.Addons, 0, -20)
	self.UIScale:SetText(K.SystemColor.."Scaling: "..K.GreyColor..K.Round(self.UIScale.Value, 2))

	self.RecommendedUIScale = self:CreateFontString(nil, "OVERLAY")
	self.RecommendedUIScale.Value = math_max(0.4, math.min(1.15, 768 / K.ScreenHeight))
	self.RecommendedUIScale:SetFont(C["Media"].Fonts.KkthnxUIFont, 12, "THINOUTLINE")
	self.RecommendedUIScale:SetPoint("TOP", self.UIScale, 0, -20)
	self.RecommendedUIScale:SetText(K.SystemColor.."Recommended Scale: "..K.GreyColor..K.Round(self.RecommendedUIScale.Value, 2))

	self.WoWBuild = self:CreateFontString(nil, "OVERLAY")
	self.WoWBuild.Value = K.WowPatch.." ("..K.WowBuild..")"
	self.WoWBuild:SetFont(C["Media"].Fonts.KkthnxUIFont, 12, "THINOUTLINE")
	self.WoWBuild:SetPoint("TOP", self.RecommendedUIScale, 0, -20)
	self.WoWBuild:SetText(K.SystemColor.."Version of WoW: "..K.GreyColor..self.WoWBuild.Value)

	self.Language = self:CreateFontString(nil, "OVERLAY")
	self.Language.Value = GetLocale()
	self.Language:SetFont(C["Media"].Fonts.KkthnxUIFont, 12, "THINOUTLINE")
	self.Language:SetPoint("TOP", self.WoWBuild, 0, -20)
	self.Language:SetText(K.SystemColor.."Language: "..K.GreyColor..self.Language.Value)

	self.Resolution = self:CreateFontString(nil, "OVERLAY")
	self.Resolution.Value = K.Resolution
	self.Resolution:SetFont(C["Media"].Fonts.KkthnxUIFont, 12, "THINOUTLINE")
	self.Resolution:SetPoint("TOP", self.Language, 0, -20)
	self.Resolution:SetText(K.SystemColor.."Resolution: "..K.GreyColor..self.Resolution.Value)

	self.Mac = self:CreateFontString(nil, "OVERLAY")
	self.Mac.Value = IsMacClient() == true and "Yes" or "No"
	self.Mac:SetFont(C["Media"].Fonts.KkthnxUIFont, 12, "THINOUTLINE")
	self.Mac:SetPoint("TOP", self.Resolution, 0, -20)
	self.Mac:SetText(K.SystemColor.."Mac client: "..K.GreyColor..self.Mac.Value)

	if UnitFactionGroup("player") == "Alliance" then
		self.FactionColor = "|cff004a93"
	elseif UnitFactionGroup("player") == "Horde" then
		self.FactionColor = "|cff8C1616"
	else
		self.FactionColor = "|cffffffff"
	end

	self.Faction = self:CreateFontString(nil, "OVERLAY")
	self.Faction.Value = UnitFactionGroup("player")
	self.Faction:SetFont(C["Media"].Fonts.KkthnxUIFont, 12, "THINOUTLINE")
	self.Faction:SetPoint("TOP", self.Mac, 0, -20)
	self.Faction:SetText(K.SystemColor.."Faction: "..self.FactionColor..self.Faction.Value.."|r")

	self.Race = self:CreateFontString(nil, "OVERLAY")
	self.Race.Value = select(2, UnitRace("player"))
	self.Race:SetFont(C["Media"].Fonts.KkthnxUIFont, 12, "THINOUTLINE")
	self.Race:SetPoint("TOP", self.Faction, 0, -20)
	self.Race:SetText(K.SystemColor.."Race: "..K.GreyColor..self.Race.Value)

	self.Class = self:CreateFontString(nil, "OVERLAY")
	self.Class.Value = select(1, UnitClass("player"))
	self.Class:SetFont(C["Media"].Fonts.KkthnxUIFont, 12, "THINOUTLINE")
	self.Class:SetPoint("TOP", self.Race, 0, -20)
	self.Class:SetText(K.SystemColor.."Class: |r"..K.MyClassColor..self.Class.Value.."|r")

	self.Level = self:CreateFontString(nil, "OVERLAY")
	self.Level.Value = UnitLevel("player")
	self.Level:SetFont(C["Media"].Fonts.KkthnxUIFont, 12, "THINOUTLINE")
	self.Level:SetPoint("TOP", self.Class, 0, -20)
	self.Level:SetText(K.SystemColor.."Level:|r "..K.GreyColor..self.Level.Value)

	self.Zone = self:CreateFontString(nil, "OVERLAY")
	self.Zone.Value = GetZoneText()
	self.Zone:SetFont(C["Media"].Fonts.KkthnxUIFont, 12, "THINOUTLINE")
	self.Zone:SetPoint("TOP", self.Level, 0, -20)
	self.Zone:SetText(K.SystemColor.."Current zone: "..K.GreyColor..self.Zone.Value)

	self.Close = CreateFrame("Button", nil, self)
	self.Close:SetSize(116, 26)
	self.Close:SkinButton()
	self.Close:SetPoint("TOP", self.Zone, 0, -40)
	self.Close.Text = self.Close:CreateFontString(nil, "OVERLAY")
	self.Close.Text:SetFont(C["Media"].Fonts.KkthnxUIFont, 12, "THINOUTLINE")
	self.Close.Text:SetPoint("CENTER")
	self.Close.Text:SetText(CLOSE)
	self.Close:SetScript("OnClick", function(self) self:GetParent():Hide() end)
end

_G.SlashCmdList["KKUI_STATUSREPORT"] = function()
	Status:ShowWindow()
end
_G.SLASH_KKUI_STATUSREPORT1 = "/kstatus"