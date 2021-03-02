if Couriers == nil then Couriers = class({}) end

COURIERS_COMMON = 1
COURIERS_UNCOMMON = 2
COURIERS_RARE = 3
COURIERS_MYTHICAL = 4
COURIERS_LEGENDARY = 5

function Couriers:Init()
	self["Couriers"] = LoadKeyValues("scripts/kv/couriers.kv")
	self:BuildRarityMap()

	CustomGameEventManager:RegisterListener("couriers:courier_selected", Dynamic_Wrap(self, 'OnPlayerSelectedCourier'))
end

function Couriers:OnPlayerSelectedCourier(data)
	local player_id = data.PlayerID
	local courier_key = data.courier_key
	local selection_key = data.selection_key

	local selection = CustomNetTables:GetTableValue("couriers", "selection")

	local player_selection = selection[tostring(player_id)]

	if type(player_selection) == "table" then
		local courier_name = player_selection[selection_key][courier_key]

		local player_hero = PlayerResource:GetPlayer(player_id):GetAssignedHero()
		
		local creep = CreateUnitByName(courier_name, math.random_point_inside_circle(player_hero:GetAbsOrigin(), 250, 100), true, player_hero, player_hero, PlayerResource:GetTeam(player_id))
		creep:SetControllableByPlayer(player_id, true)

		-- Update nettable
		selection[tostring(player_id)][selection_key] = nil
		CustomNetTables:SetTableValue("couriers", "selection", selection)
	end
end

function Couriers:BuildRarityMap()
	local rarity_map = {}

	for i=COURIERS_COMMON,COURIERS_LEGENDARY do
		for k,v in pairs(self["Couriers"][tostring(i)]) do
			rarity_map[v] = tostring(i)
		end
	end

	CustomNetTables:SetTableValue("couriers", "rarity_map", rarity_map)
end

function Couriers:GrantCourierSelectionToPlayers()
	local selection = CustomNetTables:GetTableValue("couriers", "selection") or {}

	for player_id=0,7 do
		selection[player_id] = selection[player_id] or {}
		for i=1,3 do
			table.insert(selection[player_id], self:GetThreeRandomCouriers())
		end
	end

	CustomNetTables:SetTableValue("couriers", "selection", selection)
end

function Couriers:GetThreeRandomCouriers()
	local all_couriers = {}
	for i=COURIERS_COMMON,COURIERS_LEGENDARY do
		for k,v in pairs(self["Couriers"][tostring(i)]) do
			table.insert(all_couriers, v)
		end
	end
	return table.random_some(all_couriers, 3)
end
