local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Announcements")

local _G = _G

local DoEmote = _G.DoEmote
local UnitHealth = _G.UnitHealth
local UnitHealthMax = _G.UnitHealthMax
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax
local UnitPowerType = _G.UnitPowerType

-- Low Mana
local oom = false
local function IamOutOfMana()
    local _, powerToken = UnitPowerType("player")
    if powerToken and powerToken == "MANA" then
        local mana = UnitPower("player")
        local manamax = UnitPowerMax("player")
        local manaperc = K.Round(mana / manamax * 100, 1)

        -- OOM
        if manaperc <= C["Announcements"].ManaThreshold and not oom then
            oom = true
            if C["Announcements"].ManaAlertEmote then
                DoEmote("oom")
            end
			UIErrorsFrame:AddMessage(K.InfoColor.."Your MANA is below "..C["Announcements"].ManaThreshold.."%!!!")
        elseif manaperc > C["Announcements"].ManaThreshold + 20 and oom then
            oom = false
        end
    end
end

-- Near Death
local neardeath = false
local function IamNearDeath()
    local health = UnitHealth("player")
	local healthmax = UnitHealthMax("player")
	local healthperc = K.Round(health / healthmax * 100, 1)

    if healthperc <= C["Announcements"].HealthThreshold and not neardeath then
        neardeath = true
        if C["Announcements"].HealthAlertEmote then
            DoEmote("flee")
        end
		UIErrorsFrame:AddMessage(K.InfoColor.."Your HEALTH is below "..C["Announcements"].HealthThreshold.."%!!!")
    elseif healthperc > C["Announcements"].HealthThreshold + 20 and neardeath then
        neardeath = false
    end
end

function Module:CreateHealthAnnounce()
	if C["Announcements"].HealthAlert then
		K:RegisterEvent("UNIT_HEALTH_FREQUENT", IamNearDeath)
	else
		K:UnregisterEvent("UNIT_HEALTH_FREQUENT", IamNearDeath)
	end

	if C["Announcements"].ManaAlert then
		K:RegisterEvent("UNIT_POWER_FREQUENT", IamOutOfMana)
	else
		K:UnregisterEvent("UNIT_POWER_FREQUENT", IamOutOfMana)
	end
end