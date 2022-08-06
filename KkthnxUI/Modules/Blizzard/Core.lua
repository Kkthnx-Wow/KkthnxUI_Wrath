local K = unpack(select(2, ...))
local Module = K:NewModule("Blizzard")

function Module:OnEnable()
	self:CreateUIWidgets()
	self:CreateMirrorBars()
	self:CreateAlertFrames()
	self:CreateColorPicker()
	self:CreateMirrorBars()
	self:CreateNoBlizzardTutorials()
	self:CreateRaidUtility()
end