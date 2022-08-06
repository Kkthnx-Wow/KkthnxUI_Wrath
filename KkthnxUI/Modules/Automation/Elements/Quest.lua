local K, C, L = unpack(select(2, ...))

local _G = _G
local table_wipe = _G.table.wipe
local string_match = _G.string.match

local AcceptQuest = _G.AcceptQuest
local CloseQuest = _G.CloseQuest
local CompleteQuest = _G.CompleteQuest
local GameTooltip = _G.GameTooltip
local GetActiveTitle = _G.GetActiveTitle
local GetGossipActiveQuests = _G.GetGossipActiveQuests
local GetGossipAvailableQuests = _G.GetGossipAvailableQuests
local GetGossipOptions = _G.GetGossipOptions
local GetInstanceInfo = _G.GetInstanceInfo
local GetItemInfo = _G.GetItemInfo
local GetNumActiveQuests = _G.GetNumActiveQuests
local GetNumAvailableQuests = _G.GetNumAvailableQuests
local GetNumGossipActiveQuests = _G.GetNumGossipActiveQuests
local GetNumGossipAvailableQuests = _G.GetNumGossipAvailableQuests
local GetNumGossipOptions = _G.GetNumGossipOptions
local GetNumQuestChoices = _G.GetNumQuestChoices
local GetNumQuestItems = _G.GetNumQuestItems
local GetNumQuestLogEntries = _G.GetNumQuestLogEntries
local GetQuestID = _G.GetQuestID
local GetQuestItemInfo = _G.GetQuestItemInfo
local GetQuestItemLink = _G.GetQuestItemLink
local GetQuestLogTitle = _G.GetQuestLogTitle
local GetQuestReward = _G.GetQuestReward
local GetQuestTagInfo = _G.GetQuestTagInfo
local IsQuestCompletable = _G.IsQuestCompletable
local IsShiftKeyDown = _G.IsShiftKeyDown
local SelectActiveQuest = _G.SelectActiveQuest
local SelectAvailableQuest = _G.SelectAvailableQuest
local SelectGossipActiveQuest = _G.SelectGossipActiveQuest
local SelectGossipAvailableQuest = _G.SelectGossipAvailableQuest
local SelectGossipOption = _G.SelectGossipOption
local StaticPopup_Hide = _G.StaticPopup_Hide
local UnitGUID = _G.UnitGUID

local quests, choiceQueue = {}
local QuickQuest = CreateFrame("Frame")
QuickQuest:SetScript("OnEvent", function(self, event, ...)
	self[event](...)
end)

function QuickQuest:Register(event, func)
	self:RegisterEvent(event)
	self[event] = function(...)
		if KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuest == true and not IsShiftKeyDown() then
			func(...)
		end
	end
end

local isCheckButtonCreated
local function SetupAutoQuestCheckButton()
	if isCheckButtonCreated then
		return
	end

	local AutoQuestCheckButton = CreateFrame("CheckButton", nil, WorldMapFrame, "OptionsCheckButtonTemplate")
	if C["Skins"].WorldMap then
		AutoQuestCheckButton:SetPoint("TOPRIGHT", -160, -78)
		AutoQuestCheckButton:SetSize(16, 16)
		AutoQuestCheckButton:SkinCheckBox()
		AutoQuestCheckButton:SetFrameLevel(WorldMapFrameCloseButton:GetFrameLevel())
	else
		AutoQuestCheckButton:SetPoint("TOPRIGHT", -140, 0)
		AutoQuestCheckButton:SetSize(24, 24)
	end

	AutoQuestCheckButton.text = AutoQuestCheckButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	AutoQuestCheckButton.text:SetPoint("LEFT", 24, 0)
	AutoQuestCheckButton.text:SetText(L["Auto Quest"])

	AutoQuestCheckButton:SetHitRectInsets(0, 0 - AutoQuestCheckButton.text:GetWidth(), 0, 0)
	AutoQuestCheckButton:SetChecked(KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuest)
	AutoQuestCheckButton:SetScript("OnClick", function(self)
		KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuest = self:GetChecked()
	end)

	isCheckButtonCreated = true

	function AutoQuestCheckButton.UpdateTooltip(self)
		if (GameTooltip:IsForbidden()) then
			return
		end

		GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 10)

		local r, g, b = 0.2, 1.0, 0.2

		if KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuest == true then
			GameTooltip:AddLine(L["Auto Quest Enabled"])
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L["Auto Quest Enabled Desc"], r, g, b)
		else
			GameTooltip:AddLine(L["Auto Quest Disabled"])
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L["Auto Quest Disabled Desc"], r, g, b)
		end

		GameTooltip:Show()
	end

	AutoQuestCheckButton:HookScript("OnEnter", function(self)
		if (GameTooltip:IsForbidden()) then
			return
		end

		self:UpdateTooltip()
	end)

	AutoQuestCheckButton:HookScript("OnLeave", function()
		if (GameTooltip:IsForbidden()) then
			return
		end

		GameTooltip:Hide()
	end)

	AutoQuestCheckButton:SetScript("OnClick", function(self)
		KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuest = self:GetChecked()
	end)
end
WorldMapFrame:HookScript("OnShow", SetupAutoQuestCheckButton)

local function GetNPCID()
	return K.GetNPCID(UnitGUID("npc"))
end

local ignoreQuestNPC = {
	[15192] = true, -- Anachronos (Caverns of Time)
	[3430] = true, -- Mangletooth (Blood Shard quests, Barrens)
	[14828] = true, -- Gelvas Grimegate (Darkmoon Faire Ticket Redemption, Elwynn Forest and Mulgore)
	[14921] = true, -- Rin'wosho the Trader (Zul'Gurub Isle, Stranglethorn Vale)
	[18166] = true, -- Khadgar (Allegiance to Aldor/Scryer, Shattrath)
	[18253] = true, -- Archmage Leryda (Violet Signet, Karazhan)

	-- Classic escort quests
	[467] = true, -- The Defias Traitor (The Defias Brotherhood)
	[349] = true, -- Corporal Keeshan (Missing In Action)
	[1379] = true, -- Miran (Protecting the Shipment)
	[7766] = true, -- Tyrion (The Attack!)
	[1978] = true, -- Deathstalker Erland (Escorting Erland)
	[7784] = true, -- Homing Robot OOX-17/TN (Rescue OOX-17/TN!)
	[2713] = true, -- Kinelory (Hints of a New Plague?)
	[2768] = true, -- Professor Phizzlethorpe (Sunken Treasure)
	[2610] = true, -- Shakes O'Breen (Death From Below)
	[2917] = true, -- Prospector Remtravel (The Absent Minded Prospector)
	[7806] = true, -- Homing Robot OOX-09/HL (Rescue OOX-09/HL!)
	[3439] = true, -- Wizzlecrank's Shredder (The Escape)
	[3465] = true, -- Gilthares Firebough (Free From the Hold)
	[3568] = true, -- Mist (Mist)
	[3584] = true, -- Therylune (Therylune's Escape)
	[4484] = true, -- Feero Ironhand (Supplies to Auberdine)
	[3692] = true, -- Volcor (Escape Through Force)
	[4508] = true, -- Willix the Importer (Willix the Importer)
	[4880] = true, -- "Stinky" Ignatz (Stinky's Escape)
	[4983] = true, -- Ogron (Questioning Reethe)
	[5391] = true, -- Galen Goodward (Galen's Escape)
	[5644] = true, -- Dalinda Malem (Return to Vahlarriel)
	[5955] = true, -- Tooga (Tooga's Quest)
	[7780] = true, -- Rin'ji (Rin'ji is Trapped!)
	[7807] = true, -- Homing Robot OOX-22/FE (Rescue OOX-22/FE!)
	[7774] = true, -- Shay Leafrunner (Wandering Shay)
	[7850] = true, -- Kernobee (A Fine Mess)
	[8284] = true, -- Dorius Stonetender (Suntara Stones)
	[8380] = true, -- Captain Vanessa Beltis (A Crew Under Fire)
	[8516] = true, -- Belnistrasz (Extinguishing the Idol)
	[9020] = true, -- Commander Gor'shak (What Is Going On?)
	[9520] = true, -- Grark Lorkrub (Precarious Predicament)
	[9623] = true, -- A-Me 01 (Chasing A-Me 01)
	[9598] = true, -- Arei (Ancient Spirit)
	[9023] = true, -- Marshal Windsor (Jail Break!)
	[9999] = true, -- Ringo (A Little Help From My Friends)
	[10427] = true, -- Pao'ka Swiftmountain (Homeward Bound)
	[10300] = true, -- Ranshalla (Guardians of the Altar)
	[10646] = true, -- Lakota Windsong (Free at Last)
	[10638] = true, -- Kanati Greycloud (Protect Kanati Greycloud)
	[11016] = true, -- Captured Arko'narin (Rescue From Jaedenar)
	[11218] = true, -- Kerlonian Evershade (The Sleeper Has Awakened)
	[11711] = true, -- Sentinel Aynasha (One Shot. One Kill.)
	[11625] = true, -- Cork Gizelton (Bodyguard for Hire)
	[11626] = true, -- Rigger Gizelton (Gizelton Caravan)
	[1842] = true, -- Highlord Taelan Fordring (In Dreams)
	[12277] = true, -- Melizza Brimbuzzle (Get Me Out of Here!)
	[12580] = true, -- Reginald Windsor (The Great Masquerade)
	[12818] = true, -- Ruul Snowhoof (Freedom to Ruul)
	[11856] = true, -- Kaya Flathoof (Protect Kaya)
	[12858] = true, -- Torek (Torek's Assault)
	[12717] = true, -- Muglash (Vorsha the Lasher)
	[13716] = true, -- Celebras the Redeemed (The Scepter of Celebras)
	[19401] = true, -- Wing Commander Brack (Return to the Abyssal Shelf) (Horde)
	[20235] = true, -- Gryphoneer Windbellow (Return to the Abyssal Shelf) (Alliance)

	-- BCC escort quests
	[16295] = true, -- Ranger Lilatha (Escape from the Catacombs)
	[17238] = true, -- Anchorite Truuen (Tomb of the Lightbringer)
	[17312] = true, -- Magwin (A Cry For Help)
	[17877] = true, -- Fhwoor (Fhwoor Smash!)
	[17969] = true, -- Kayra Longmane (Escape from Umbrafen)
	[18210] = true, -- Mag'har Captive (The Totem of Kar'dash, Horde)
	[18209] = true, -- Kurenai Captive (The Totem of Kar'dash, Alliance)
	[18760] = true, -- Isla Starmane (Escape from Firewing Point!)
	[19589] = true, -- Maxx A. Million Mk. V (Mark V is Alive!)
	[19671] = true, -- Cryo-Engineer Sha'heen (Someone Else's Hard Work Pays Off)
	[20281] = true, -- Drijya (Sabotage the Warp-Gate!)
	[20415] = true, -- Bessy (When the Cows Come Home)
	[20482] = true, -- Image of Commander Ameer (Delivering the Message)
	[20763] = true, -- Captured Protectorate Vanguard (Escape from the Staging Grounds)
	[21027] = true, -- Earthmender Wilda (Escape from Coilskar Cistern)
	[22424] = true, -- Skywing (Skywing)
	[22458] = true, -- Chief Archaeologist Letoll (Digging Through Bones)
	[23383] = true, -- Skyguard Prisoner (Escape from Skettis)
}

local function GetQuestLogQuests(onlyComplete)
	table_wipe(quests)

	for index = 1, GetNumQuestLogEntries() do
		local title, _, _, isHeader, _, isComplete, _, questID = GetQuestLogTitle(index)
		if (not isHeader) then
			if (onlyComplete and isComplete or not onlyComplete) then
				quests[title] = questID
			end
		end
	end

	return quests
end

QuickQuest:Register("QUEST_GREETING", function()
	local npcID = GetNPCID()
	if (ignoreQuestNPC[npcID]) then
		return
	end

	local active = GetNumActiveQuests()
	if (active > 0) then
		local logQuests = GetQuestLogQuests(true)
		for index = 1, active do
			local name, complete = GetActiveTitle(index)
			if (complete) then
				local questID = logQuests[name]
				if (not questID) then
					SelectActiveQuest(index)
				else
					local _, _, worldQuest = GetQuestTagInfo(questID)
					if (not worldQuest) then
						SelectActiveQuest(index)
					end
				end
			end
		end
	end

	local available = GetNumAvailableQuests()
	if (available > 0) then
		for index = 1, available do
			local isTrivial = IsActiveQuestTrivial(index)
			if not isTrivial then
				SelectAvailableQuest(index)
			end
		end
	end
end)

-- This should be part of the API, really
local function GetAvailableGossipQuestInfo(index)
	local name, level, isTrivial, frequency, isRepeatable, isLegendary, isIgnored = select(((index * 7) - 7) + 1, GetGossipAvailableQuests())
	return name, level, isTrivial, isIgnored, isRepeatable, frequency == 2, frequency == 3, isLegendary
end

local function GetActiveGossipQuestInfo(index)
	local name, level, isTrivial, isComplete, isLegendary, isIgnored = select(((index * 6) - 6) + 1, GetGossipActiveQuests())
	return name, level, isTrivial, isIgnored, isComplete, isLegendary
end

local ignoreGossipNPC = {
	-- Ignore specific NPCs for selecting quests only (only used for items that have no other purpose)
	[12944] = true, -- Lokhtos Darkbargainer (Thorium Brotherhood, Blackrock Depths)
	[10307] = true, -- Witch Doctor Mau'ari (E'Ko quests, Winterspring)
	-- Ahn'Qiraj War Effort (Alliance, Ironforge)
	[15446] = true, -- Bonnie Stoneflayer (Light Leather Collector)
	[15458] = true, -- Commander Stronghammer (Alliance Ambassador)
	[15431] = true, -- Corporal Carnes (Iron Bar Collector)
	[15432] = true, -- Dame Twinbraid (Thorium Bar Collector)
	[15453] = true, -- Keeper Moonshade (Runecloth Bandage Collector)
	[15457] = true, -- Huntress Swiftriver (Spotted Yellowtail Collector)
	[15450] = true, -- Marta Finespindle (Thick Leather Collector)
	[15437] = true, -- Master Nightsong (Purple Lotus Collector)
	[15452] = true, -- Nurse Stonefield (Silk Bandage Collector)
	[15434] = true, -- Private Draxlegauge (Stranglekelp Collector)
	[15448] = true, -- Private Porter (Medium Leather Collector)
	[15456] = true, -- Sarah Sadwhistle (Roast Raptor Collector)
	[15451] = true, -- Sentinel Silversky (Linen Bandage Collector)
	[15445] = true, -- Sergeant Major Germaine (Arthas' Tears Collector)
	[15383] = true, -- Sergeant Stonebrow (Copper Bar Collector)
	[15455] = true, -- Slicky Gastronome (Rainbow Fin Albacore Collector)
	-- Ahn'Qiraj War Effort (Horde, Orgrimmar)
	[15512] = true, -- Apothecary Jezel (Purple Lotus Collector)
	[15508] = true, -- Batrider Pele'keiki (Firebloom Collector)
	[15533] = true, -- Bloodguard Rawtar (Lean Wolf Steak Collector)
	[15535] = true, -- Chief Sharpclaw (Baked Salmon Collector)
	[15525] = true, -- Doctor Serratus (Rugged Leather Collector)
	[15534] = true, -- Fisherman Lin'do (Spotted Yellowtail Collector)
	[15539] = true, -- General Zog (Horde Ambassador)
	[15460] = true, -- Grunt Maug (Tin Bar Collector)
	[15528] = true, -- Healer Longrunner (Wool Bandage Collector)
	[15477] = true, -- Herbalist Proudfeather (Peacebloom Collector)
	[15529] = true, -- Lady Callow (Mageweave Bandage Collector)
	[15459] = true, -- Miner Cromwell (Copper Bar Collector)
	[15469] = true, -- Senior Sergeant T'kelah (Mithril Bar Collector)
	[15522] = true, -- Sergeant Umala (Thick Leather Collector)
	[15515] = true, -- Skinner Jamani (Heavy Leather Collector)
	[15532] = true, -- Stoneguard Clayhoof (Runecloth Bandage Collector)
	-- Alliance Commendations
	[15764] = true, -- Officer Ironbeard (Ironforge Commendations)
	[15762] = true, -- Officer Lunalight (Darnassus Commendations)
	[15766] = true, -- Officer Maloof (Stormwind Commendations)
	[15763] = true, -- Officer Porterhouse (Gnomeregan Commendations)
	-- Horde Commendations
	[15768] = true, -- Officer Gothena (Undercity Commendations)
	[15765] = true, -- Officer Redblade (Orgrimmar Commendations)
	[15767] = true, -- Officer Thunderstrider (Thunder Bluff Commendations)
	[15761] = true, -- Officer Vu'Shalay (Darkspear Commendations)
	-- Battlegrounds (Alliance)
	[13442] = true, -- Arch Druid Renferal (Storm Crystal, Alterac Valley)
	-- Battlegrounds (Horde)
	[13236] = true, -- Primalist Thurloga (Stormpike Soldier's Blood, Alterac Valley)
	-- Scourgestones
	[11039] = true, -- Duke Nicholas Zverenhoff (Eastern Plaguelands)
	-- Un'Goro crystals
	[9117] = true, 	-- J. D. Collie (Un'Goro Crater)
}

local autoGossipTypes = {
	["taxi"] = true,
	["gossip"] = true,
	["banker"] = true,
	["vendor"] = true,
	["trainer"] = true,
}

QuickQuest:Register("GOSSIP_SHOW", function()
	local npcID = GetNPCID()
	if(ignoreQuestNPC[npcID]) then
		return
	end

	local active = GetNumGossipActiveQuests()
	if (active > 0) then
		local logQuests = GetQuestLogQuests(true)
		for index = 1, active do
			local name, _, _, _, complete = GetActiveGossipQuestInfo(index)
			if (complete) then
				local questID = logQuests[name]
				if (not questID) then
					SelectGossipActiveQuest(index)
				else
					local _, _, worldQuest = GetQuestTagInfo(questID)
					if (not worldQuest) then
						SelectGossipActiveQuest(index)
					end
				end
			end
		end
	end

	local available = GetNumGossipAvailableQuests()
	if (available > 0) then
		for index = 1, available do
			local _, _, trivial, ignored = GetAvailableGossipQuestInfo(index)
			if (not trivial and not ignored) then
				SelectGossipAvailableQuest(index)
			end
		end
	end

	if (available == 0 and active == 0) then
		if GetNumGossipOptions() == 1 then
			local _, instance = GetInstanceInfo()
			if(instance ~= "raid" and not ignoreGossipNPC[npcID]) then
				local _, type = GetGossipOptions()
				if autoGossipTypes[type] then
					SelectGossipOption(1)
					return
				end
			end
		end
	end
end)

local darkmoonNPC = {}

QuickQuest:Register("GOSSIP_CONFIRM", function(index)
	local npcID = GetNPCID()
	if (npcID and darkmoonNPC[npcID]) then
		SelectGossipOption(index, "", true)
		StaticPopup_Hide("GOSSIP_CONFIRM")
	end
end)

QuickQuest:Register("QUEST_DETAIL", function()
	AcceptQuest()
end)

QuickQuest:Register("QUEST_ACCEPT_CONFIRM", AcceptQuest)

QuickQuest:Register("QUEST_ACCEPTED", function()
	if QuestFrame:IsShown() then
		CloseQuest()
	end
end)

QuickQuest:Register("QUEST_ITEM_UPDATE", function()
	if (choiceQueue and QuickQuest[choiceQueue]) then
		QuickQuest[choiceQueue]()
	end
end)

local itemBlacklist = {}

local ignoreProgressNPC = {}

QuickQuest:Register("QUEST_PROGRESS", function()
	if(IsQuestCompletable()) then
		local id, _, worldQuest = GetQuestTagInfo(GetQuestID())
		if id == 153 or worldQuest then
			return
		end

		local npcID = GetNPCID()
		if ignoreProgressNPC[npcID] then
			return
		end

		local requiredItems = GetNumQuestItems()
		if (requiredItems > 0) then
			for index = 1, requiredItems do
				local link = GetQuestItemLink("required", index)
				if (link) then
					local id = tonumber(string_match(link, "item:(%d+)"))
					for _, itemID in next, itemBlacklist do
						if (itemID == id) then
							return
						end
					end
				else
					choiceQueue = "QUEST_PROGRESS"
					return
				end
			end
		end
		CompleteQuest()
	end
end)

local cashRewards = {}

QuickQuest:Register("QUEST_COMPLETE", function()
	local choices = GetNumQuestChoices()
	if (choices <= 1) then
		GetQuestReward(1)
	elseif (choices > 1) then
		local bestValue, bestIndex = 0
		for index = 1, choices do
			local link = GetQuestItemLink("choice", index)
			if (link) then
				local _, _, _, _, _, _, _, _, _, _, value = GetItemInfo(link)
				value = cashRewards[tonumber(string_match(link, "item:(%d+):"))] or value

				if(value > bestValue) then
					bestValue, bestIndex = value, index
				end
			else
				choiceQueue = "QUEST_COMPLETE"
				return GetQuestItemInfo("choice", index)
			end
		end

		local button = bestIndex and QuestInfoRewardsFrame.RewardButtons[bestIndex]
		if button then
			QuestInfoItem_OnClick(button)
		end
	end
end)

local function AttemptAutoComplete(event)
	C_Timer.After(1, AttemptAutoComplete)

	if (event == "PLAYER_REGEN_ENABLED") then
		QuickQuest:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end
end
QuickQuest:Register("PLAYER_LOGIN", AttemptAutoComplete)
QuickQuest:Register("QUEST_AUTOCOMPLETE", AttemptAutoComplete)