local K, C = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local _G = _G

local C_Timer_After = _G.C_Timer.After
local Dismount = _G.Dismount
local InCombatLockdown = _G.InCombatLockdown
local IsMounted = _G.IsMounted
local TakeTaxiNode = _G.TakeTaxiNode
local hooksecurefunc = _G.hooksecurefunc

-- Auto dismount on Taxi
function Module:CreateAutoDismount()
	local lastTaxiIndex

	local function retryTaxi()
		if InCombatLockdown() then
			return
		end

		if lastTaxiIndex then
			TakeTaxiNode(lastTaxiIndex)
			lastTaxiIndex = nil
		end
	end

	hooksecurefunc("TakeTaxiNode", function(index)
		if not C["Automation"].AutoDismount then
			return
		end

		if not IsMounted() then
			return
		end

		Dismount()
		lastTaxiIndex = index
		C_Timer_After(0.5, retryTaxi)
	end)
end