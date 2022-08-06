local K, C = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

local _G = _G
local UIParent = _G.UIParent
local GroupLootContainer = _G.GroupLootContainer

local POSITION, YOFFSET = "TOP", -10
local parentFrame

function Module:GroupLootContainer_UpdateAnchor()
	local y = select(2, parentFrame:GetCenter())
	local screenHeight = UIParent:GetTop()
	if y > screenHeight / 2 then
		POSITION = "TOP"
		YOFFSET = -10
	else
		POSITION = "BOTTOM"
		YOFFSET = 10
	end

	GroupLootContainer:ClearAllPoints()
	GroupLootContainer:SetPoint(POSITION, parentFrame)
end

function Module:UpdatGroupLootContainer()
	local lastIdx = nil

	for i = 1, self.maxIndex do
		local frame = C["Loot"].GroupLoot and K:GetModule("Loot").RollBars[i] or self.rollFrames[i]
		if frame then
			frame:ClearAllPoints()
			frame:SetPoint("CENTER", self, POSITION, 0, self.reservedSize * (i - 1 + 0.5) * YOFFSET / 10)
			lastIdx = i
		end
	end

	if lastIdx then
		self:SetHeight(self.reservedSize * lastIdx)
		self:Show()
	else
		self:Hide()
	end
end

function Module:CreateAlertFrames()
	parentFrame = parentFrame or CreateFrame("Frame", "KKUI_GroupLootHolder", UIParent)
	parentFrame:SetSize(328, 26)
	K.Mover(parentFrame, "GroupLoot", "GroupLoot", {"TOP", UIParent, 0, -170})

	GroupLootContainer:EnableMouse(false)
	GroupLootContainer.ignoreFramePositionManager = true

	Module:GroupLootContainer_UpdateAnchor()
	hooksecurefunc("GroupLootFrame_OpenNewFrame", Module.GroupLootContainer_UpdateAnchor)
	hooksecurefunc("GroupLootContainer_Update", Module.UpdatGroupLootContainer)
end