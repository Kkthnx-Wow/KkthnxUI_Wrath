local K = unpack(KkthnxUI)
local Module = K:NewModule("Blizzard")

function Module:OnEnable()
	self:CreateAlertFrames()
	self:CreateColorPicker()
	self:CreateMirrorBars()
	-- self:CreateObjectiveFrame()
	self:CreateRaidUtility()
	self:CreateTimerTracker()
	self:CreateUIWidgets()
end
