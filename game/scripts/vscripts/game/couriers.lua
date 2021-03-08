if Couriers == nil then Couriers = class({}) end

COURIERS_START_AMOUNT = 10
COURIERS_SELECTION_AMOUNT = 3

COURIERS_COMMON = 1
COURIERS_UNCOMMON = 2
COURIERS_RARE = 3
COURIERS_MYTHICAL = 4
COURIERS_LEGENDARY = 5

function Couriers:Init()
	LinkLuaModifier("courier_aura", "game/modifiers/courier_aura", LUA_MODIFIER_MOTION_NONE)

	self["Couriers"] = LoadKeyValues("scripts/kv/couriers.kv")
	self:BuildRarityMap()

	self["Ranchos"] = {}
	for i=0,7 do 
		local rancho = {}
		local min = Entities:FindByName(nil, "ranch_"..tostring(i).."_min"):GetAbsOrigin()
		local max = Entities:FindByName(nil, "ranch_"..tostring(i).."_max"):GetAbsOrigin()
		local center_unit_location = Vector((min[1] + max[1]) / 2, (min[2] + max[2]) / 2, min[3])
		rancho["center_unit"] = CreateTargetDummyUnit(center_unit_location)
		rancho["min"] = min
		rancho["max"] = max
		self["Ranchos"][i] = rancho
	end

	CustomGameEventManager:RegisterListener("couriers:courier_selected", function (_, data)
		self:OnPlayerSelectedCourier(data)
	end)

	CustomGameEventManager:RegisterListener("couriers:on_rancho_button_pressed", function (_, data)
		self:OnPlayerPressedRanchoButton(data)
	end)

	for player_id=0,WWW_MAX_PLAYERS-1 do
		PlayerTables:CreateTable(self:GetCouriersPlayerTableName(player_id), {rancho={},active={},selections={}}, {player_id})
	end
end

function Couriers:GetCouriersPlayerTableName(player_id)
	return "couriers_player"..tostring(player_id)
end

function Couriers:FillEmptyRanchos()
	local all_couriers = {}
	for rarity=COURIERS_COMMON,COURIERS_LEGENDARY do
		all_couriers = table.join(all_couriers, self["Couriers"][tostring(rarity)])
	end
	for i=0,7 do
		for _=1,COURIERS_START_AMOUNT do
			table.insert(self["Ranchos"][i], self:AddCourierToPlayerRancho(i, table.random(all_couriers)))
		end
	end
end

function Couriers:OnPlayerPressedRanchoButton(data)
	local player_id = data.PlayerID

	CenterCameraOnUnit(player_id, self["Ranchos"][player_id]["center_unit"])
end

function Couriers:OrderFilter(event)
	local any_couriers = false
	for _,v in pairs(event.units) do
		local unit = EntIndexToHScript(v)
		if IsValidEntity(unit) and unit:HasModifier("courier_aura") then
			any_couriers = true
			break
		end
	end

	if any_couriers then
		if event.order_type == DOTA_UNIT_ORDER_CAST_NO_TARGET then
			return true
		else
			return false
		end
	end

	return true
end

function Couriers:OnPlayerSelectedCourier(data)
	local player_id = data.PlayerID
	local courier_key = data.courier_key
	local selection_key = data.selection_key

	local table_name = self:GetCouriersPlayerTableName(player_id)
	local selections = PlayerTables:GetTableValue(table_name, "selections")
	local selection = selections[selection_key]

	if type(selection) == "table" then
		local courier_data = selection[courier_key]
		local courier = EntIndexToHScript(courier_data["courier_entindex"])

		if IsValidEntity(courier) then
			PlayerTables:SetSubTableKeyValuePair(table_name, "selections", selection_key, nil)

			self:ActivateRanchoCourier(player_id, courier)
		end
	end
end

function Couriers:ActivateRanchoCourier(player_id, courier)
	local table_name = self:GetCouriersPlayerTableName(player_id)

	PlayerTables:SetSubTableKeyValuePair(table_name, "rancho", courier:entindex(), nil)
	PlayerTables:SetSubTableKeyValuePair(table_name, "active", courier:entindex(), true)

	Timers:RemoveTimer(courier.roam_timer)
	courier:Stop()
	courier.courier_modifier.start_time = GameRules:GetGameTime()
	courier.courier_modifier.hero_owner = PlayerResource:GetPlayer(player_id):GetAssignedHero()
	courier.courier_modifier:StartIntervalThink(0)
	courier:StartGesture(ACT_DOTA_RUN)
end

function Couriers:AddCourierToPlayerRancho(player_id, courier_name)
	local courier = CreateUnitByName(courier_name, self:GetRandomPositionInsideRancho(player_id), true, nil, nil, PlayerResource:GetTeam(player_id))
	courier:SetControllableByPlayer(player_id, true)
	courier.courier_modifier = courier:AddNewModifier(courier, nil, "courier_aura", {})
	self:BasicRoamAI(courier, player_id)

	local table_name = self:GetCouriersPlayerTableName(player_id)
	PlayerTables:SetSubTableKeyValuePair(table_name, "rancho", courier:entindex(), true)

	return courier
end

function Couriers:GetRandomPositionInsideRancho(player_id)
	local min = self["Ranchos"][player_id]["min"]
	local max = self["Ranchos"][player_id]["max"]

	return Vector(math.random(min[1], max[1]), math.random(min[2], max[2]), min[3])
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
	for player_id=0,WWW_MAX_PLAYERS-1 do
		self:GrantCourierSelectionToPlayer(player_id)
	end
end

function Couriers:GrantCourierSelectionToPlayer(player_id)
	-- @TODO
	-- Take already present selections into account
	local couriers = self:GetRandomCouriersFromPlayerRancho(player_id, COURIERS_SELECTION_AMOUNT)
	local new_selection = {}
	for _,v in pairs(couriers) do
		table.insert(new_selection, {courier_entindex=v})
	end

	local table_name = self:GetCouriersPlayerTableName(player_id)
	PlayerTables:SetSubTableKeyValuePair(table_name, "selections", DoUniqueString(table_name), new_selection)
end

function Couriers:GetRandomCouriersFromPlayerRancho(player_id, amount)
	local table_name = self:GetCouriersPlayerTableName(player_id)
	local rancho_couriers = PlayerTables:GetTableValue(table_name, "rancho")
	
	return table.random_some(table.make_key_table(rancho_couriers), amount)
end

function Couriers:BasicRoamAI(courier, player_id)
	courier.roam_timer = Timers:CreateTimer(function()
		if IsValidEntity(courier) == false then
			return nil
		end
		courier:MoveToPosition(self:GetRandomPositionInsideRancho(player_id))
		return math.random(1,4)
	end)
end
