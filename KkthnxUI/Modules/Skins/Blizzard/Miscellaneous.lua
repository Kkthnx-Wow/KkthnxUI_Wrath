local K, C = unpack(select(2, ...))

local _G = _G
local table_insert = _G.table.insert

local function UpdateMerchantItemQuality(self, link)
	local quality = link and select(3, GetItemInfo(link))
	local textR, textG, textB = 1, 1, 1
	if quality then
		textR, textG, textB = GetItemQualityColor(quality)
	else
		MerchantFrame_RegisterForQualityUpdates()
	end

	if self.Name then
		self.Name:SetTextColor(textR, textG, textB)
	end
end

table_insert(C.defaultThemes, function()
    hooksecurefunc("MerchantFrameItem_UpdateQuality", UpdateMerchantItemQuality)
end)