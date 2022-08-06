local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Tooltip")

local _G = _G
local math_floor = _G.math.floor
local select = _G.select
local string_find = _G.string.find
local string_format = _G.string.format
local string_gsub = _G.string.gsub
local string_match = _G.string.match
local tonumber = _G.tonumber

local BAGSLOT = _G.BAGSLOT
local BANK = _G.BANK
local CURRENCY = _G.CURRENCY
local GetItemCount = _G.GetItemCount
local GetItemInfo = _G.GetItemInfo
local GetMouseFocus = _G.GetMouseFocus
local GetUnitName = _G.GetUnitName
local TALENT = _G.TALENT
local UnitAura = _G.UnitAura
local hooksecurefunc = _G.hooksecurefunc

local SELL_PRICE_TEXT = string_format("|cffffffff%s%s%%s|r", SELL_PRICE, HEADER_COLON)
local ITEM_LEVEL_STR = string_gsub(ITEM_LEVEL_PLUS, "%+", "")
ITEM_LEVEL_STR = string_format("|cffffd100%s|r|n%%s", ITEM_LEVEL_STR)

local types = {
	spell = SPELLS.."ID:",
	item = ITEMS.."ID:",
	quest = QUESTS_LABEL.."ID:",
	talent = TALENT.."ID:",
	achievement = ACHIEVEMENTS.."ID:",
	currency = CURRENCY.."ID:",
	azerite = L["Trait"].."ID:",
}

local function createIcon(index)
	return string_format(" |TInterface\\MoneyFrame\\UI-%sIcon:14:14:0:0|t", index)
end

local function setupMoneyString(money)
	local g, s, c = math_floor(money / 1e4), math_floor(money / 100) % 100, money % 100
	local str = ""
	if g > 0 then
		str = str.." "..g..createIcon("Gold")
	end

	if s > 0 then
		str = str.." "..s..createIcon("Silver")
	end

	if c > 0 then
		str = str.." "..c..createIcon("Copper")
	end

	return str
end

function Module:UpdateItemSellPrice()
	local frame = GetMouseFocus()
	if frame and frame.GetName then
		if frame:IsForbidden() then -- Forbidden on blizz store
			return
		end

		local name = frame:GetName()
		if not MerchantFrame:IsShown() or name and (string_find(name, "Character") or string_find(name, "TradeSkill")) then
			local link = select(2, self:GetItem())
			if link then
				local price = select(11, GetItemInfo(link))
				if price and price > 0 then
					local object = frame:GetObjectType()
					local count
					if object == "Button" then -- ContainerFrameItem, QuestInfoItem, PaperDollItem
						count = frame.count
					elseif object == "CheckButton" then -- MailItemButton or ActionButton
						count = frame.count or frame.Count:GetText()
					end

					local cost = (tonumber(count) or 1) * price
					self:AddLine(string_format(SELL_PRICE_TEXT, setupMoneyString(cost)))
				end
			end
		end
	end
end

local iLvlItemClassIDs = {
	[LE_ITEM_CLASS_ARMOR] = true,
	[LE_ITEM_CLASS_WEAPON] = true,
}

function Module:AddLineForID(id, linkType, noadd)
	for i = 1, self:NumLines() do
		local line = _G[self:GetName().."TextLeft"..i]
		if not line then
			break
		end

		local text = line:GetText()
		if text and text == linkType then
			return
		end
	end

	if linkType == types.item then
		Module.UpdateItemSellPrice(self)
	end

	if not noadd then
		self:AddLine(" ")
	end

	if linkType == types.item then
		local bagCount = GetItemCount(id)
		local bankCount = GetItemCount(id, true) - bagCount
		local name, _, _, itemLevel, _, _, _, itemStackCount, _, _, _, classID = GetItemInfo(id)
		if bankCount > 0 then
			self:AddDoubleLine(BAGSLOT.."/"..BANK..":", K.InfoColor..bagCount.."/"..bankCount)
		elseif bagCount > 0 then
			self:AddDoubleLine(BAGSLOT..":", K.InfoColor..bagCount)
		end

		if itemStackCount and itemStackCount > 1 then
			self:AddDoubleLine(L["Stack Cap"]..":", K.InfoColor..itemStackCount)
		end

		-- iLvl info like retail
		if name and itemLevel and itemLevel > 1 and iLvlItemClassIDs[classID] then
			local tipName = self:GetName()
			local index = string_find(tipName, "Shopping") and 3 or 2
			local line = _G[tipName.."TextLeft"..index]
			local lineText = line and line:GetText()
			if lineText then
				line:SetFormattedText(ITEM_LEVEL_STR, itemLevel, lineText)
				line:SetJustifyH("LEFT")
			end
		end
	end

	self:AddDoubleLine(linkType, string_format(K.InfoColor.."%s|r", id))
	self:Show()
end

function Module:SetHyperLinkID(link)
	local linkType, id = string_match(link, "^(%a+):(%d+)")
	if not linkType or not id then
		return
	end

	if linkType == "spell" or linkType == "enchant" or linkType == "trade" then
		Module.AddLineForID(self, id, types.spell)
	elseif linkType == "talent" then
		Module.AddLineForID(self, id, types.talent, true)
	elseif linkType == "quest" then
		Module.AddLineForID(self, id, types.quest)
	elseif linkType == "achievement" then
		Module.AddLineForID(self, id, types.achievement)
	elseif linkType == "item" then
		Module.AddLineForID(self, id, types.item)
	elseif linkType == "currency" then
		Module.AddLineForID(self, id, types.currency)
	end
end

function Module:SetItemID()
	local link = select(2, self:GetItem())
	if link then
		local id = string_match(link, "item:(%d+):")
		local keystone = string_match(link, "|Hkeystone:([0-9]+):")
		if keystone then
			id = tonumber(keystone)
		end

		if id then
			Module.AddLineForID(self, id, types.item)
		end
	end
end

function Module:UpdateSpellCaster(...)
	local unitCaster = select(7, UnitAura(...))
	if unitCaster then
		local name = GetUnitName(unitCaster, true)
		local hexColor = K.RGBToHex(K.UnitColor(unitCaster))
		self:AddDoubleLine(L["From"]..":", hexColor..name)
		self:Show()
	end
end

function Module:CreateTooltipID()
	if not C["Tooltip"].ShowIDs then
		return
	end

	-- Update all
	hooksecurefunc(GameTooltip, "SetHyperlink", Module.SetHyperLinkID)
	hooksecurefunc(ItemRefTooltip, "SetHyperlink", Module.SetHyperLinkID)

	-- Spells
	hooksecurefunc(GameTooltip, "SetUnitAura", function(self, ...)
		local id = select(10, UnitAura(...))
		if id then
			Module.AddLineForID(self, id, types.spell)
		end
	end)

	GameTooltip:HookScript("OnTooltipSetSpell", function(self)
		local id = select(2, self:GetSpell())
		if id then
			Module.AddLineForID(self, id, types.spell)
		end
	end)

	hooksecurefunc("SetItemRef", function(link)
		local id = tonumber(string_match(link, "spell:(%d+)"))
		if id then
			Module.AddLineForID(ItemRefTooltip, id, types.spell)
		end
	end)

	-- Items
	GameTooltip:HookScript("OnTooltipSetItem", Module.SetItemID)
	ItemRefTooltip:HookScript("OnTooltipSetItem", Module.SetItemID)
	ShoppingTooltip1:HookScript("OnTooltipSetItem", Module.SetItemID)
	ShoppingTooltip2:HookScript("OnTooltipSetItem", Module.SetItemID)
	ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", Module.SetItemID)
	ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", Module.SetItemID)

	-- Spell caster
	hooksecurefunc(GameTooltip, "SetUnitAura", Module.UpdateSpellCaster)
end