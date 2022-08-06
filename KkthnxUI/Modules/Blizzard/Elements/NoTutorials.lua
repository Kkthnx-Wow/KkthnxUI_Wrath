local K, C = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

local _G = _G

local NUM_LE_FRAME_TUTORIALS = _G.NUM_LE_FRAME_TUTORIALS

function Module:CreateNoBlizzardTutorials()
	if not C["General"].NoTutorialButtons then
		return
	end

	local lastInfoFrame = C_CVar.GetCVarBitfield("closedInfoFrames", NUM_LE_FRAME_TUTORIALS)
	if not lastInfoFrame then
		C_CVar.SetCVar("showTutorials", 0)
		C_CVar.SetCVar("showNPETutorials", 0)

		-- help plates
		for i = 1, NUM_LE_FRAME_TUTORIALS do
			C_CVar.SetCVarBitfield("closedInfoFrames", i, true)
		end
	end

	_G.HelpPlate:Kill()
	_G.HelpPlateTooltip:Kill()
end