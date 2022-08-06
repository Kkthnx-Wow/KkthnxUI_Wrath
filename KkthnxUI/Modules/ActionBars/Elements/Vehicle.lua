local K, C = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")
local FilterConfig = C.ActionBars.leaveVehicle

local _G = _G
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local MainMenuBarVehicleLeaveButton_OnEnter = _G.MainMenuBarVehicleLeaveButton_OnEnter
local TaxiRequestEarlyLanding = _G.TaxiRequestEarlyLanding
local UIParent = _G.UIParent
local UnitOnTaxi = _G.UnitOnTaxi

local padding, margin = 0, 5

local function SetFrameSize(frame, size, num)
	size = size or frame.buttonSize
	num = num or frame.numButtons

	frame:SetWidth(num * size + (num - 1) * margin + 2 * padding)
	frame:SetHeight(size + 2 * padding)
	if not frame.mover then
		frame.mover = K.Mover(frame, "LeaveVehicle", "LeaveVehicle", frame.Pos)
	else
		frame.mover:SetSize(frame:GetSize())
	end

	if not frame.SetFrameSize then
		frame.buttonSize = size
		frame.numButtons = num
		frame.SetFrameSize = SetFrameSize
	end
end

function Module:CreateLeaveVehicle()
	local num = 1
	local buttonList = {}
	local buttonSize = C["ActionBar"].DefaultButtonSize

	-- Create The Frame To Hold The Buttons
	local frame = CreateFrame("Frame", "KKUI_LeaveVehicleBar", UIParent)
	frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 260, 4}

	-- The Button
	local button = CreateFrame("CheckButton", "KKUI_LeaveVehicleButton", frame, "ActionButtonTemplate")
	table_insert(buttonList, button) -- Add The Button Object To The List
	button:SetSize(buttonSize, buttonSize)
	button:SetPoint("BOTTOMLEFT", frame, padding, padding)
	button:StyleButton()
	button:RegisterForClicks("AnyUp")
	button.icon:SetTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
	button.icon:SetTexCoord(0.216, 0.784, 0.216, 0.784)
	button.icon.__lockdown = true

	hooksecurefunc("MainMenuBarVehicleLeaveButton_Update", function()
		if UnitOnTaxi("player") then
			button:Show()
		else
			button:Hide()
			button:SetChecked(false)
		end
	end)

	button:SetScript("OnClick", function()
		if UnitOnTaxi("player") then
			TaxiRequestEarlyLanding()
		end
		button:SetChecked(true)
	end)
	button:SetScript("OnEnter", MainMenuBarVehicleLeaveButton_OnEnter)
	button:SetScript("OnLeave", K.HideTooltip)

	frame.buttonList = buttonList
	SetFrameSize(frame, buttonSize, num)

	-- create the mouseover functionality
	if FilterConfig.fader then
		K.CreateButtonFrameFader(frame, buttonList, FilterConfig.fader)
	end
end