local K = unpack(select(2, ...))
local Module = K:GetModule("Bags")

-- This Is A Personal File. For Kkthnx only :D

local _G = _G

local GetContainerNumSlots = _G.GetContainerNumSlots
local GetContainerItemLink = _G.GetContainerItemLink

local itemsToDelete = {
	-- Punch Cards
	-- Red
	[167556] = true, -- Subroutine: Overclock
	[167677] = true, -- Harmonic Dematerializer
	[168632] = true, -- Slipstream Generator
	[168756] = true, -- Hijack Synaptic Circuits
	[168785] = true, -- Subroutine: Defragmentation
	[168798] = true, -- Trajectory Analysis
	[168800] = true, -- Subroutine: Recalibration
	[168909] = true, -- Subroutine: Emergency Repairs
	[168912] = true, -- Subroutine: Optimization
	[168913] = true, -- Regenerative Capacitors
    [167672] = true, -- Cyclotronic Blast

	-- Yellow
	[168741] = true, -- Forceful Refined Logic Board
	[168742] = true, -- Forceful Adaptable Logic Board
	[168743] = true, -- Forceful Efficient Logic Board
	[168744] = true, -- Optimized Efficient Logic Board
	[168745] = true, -- Optimized Effective Logic Board
	[168746] = true, -- Optimized Adaptable Logic Board
	[168747] = true, -- Performant Adaptable Logic Board
	[168748] = true, -- Performant Refined Logic Board
	[168749] = true, -- Performant Effective Logic Board
	[168750] = true, -- Omnipurpose Refined Logic Board
	[168751] = true, -- Omnipurpose Effective Logic Board
	[168752] = true, -- Omnipurpose Efficient Logic Board
	[170507] = true, -- Omnipurpose Logic Board
	[170508] = true, -- Optimized Logic Board
	[170509] = true, -- Performant Logic Board
	[170510] = true, -- Forceful Logic Board

	-- Blue
	[167693] = true, -- Neural Autonomy
	[168435] = true, -- Remote Circuit Bypasser
	[168631] = true, -- Metal Detector
	[168632] = true, -- Slipstream Generator
	[168633] = true, -- Supplemental Oxygenation Device
	[168648] = true, -- Emergency Anti-Gravity Device
	[168657] = true, -- Friend-or-Foe Identifier
	[168671] = true, -- Electromagnetic Resistors
}

function Module.SetupAutoDelete()
	for bag = 0, 4 do
		for slot = 0, GetContainerNumSlots(bag) do
			local _, _, locked, _, _, _, _, _, _, id = _G.GetContainerItemInfo(bag, slot)
			if not locked and id and itemsToDelete[id] then
				K.Print(K.SystemColor.._G.DELETE.." "..GetContainerItemLink(bag, slot))
				_G.PickupContainerItem(bag, slot)
				_G.DeleteCursorItem()
				return
			end
		end
	end
end

function Module:CreateAutoDelete()
    if not K.isDeveloper then
        return
    end

    K:RegisterEvent("BAG_UPDATE_DELAYED", Module.SetupAutoDelete)
end