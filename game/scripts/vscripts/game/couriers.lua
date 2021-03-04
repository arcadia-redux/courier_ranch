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
		rancho["couriers"] = {}
		self["Ranchos"][i] = rancho
	end

	CustomGameEventManager:RegisterListener("couriers:courier_selected", function (_, data)
		self:OnPlayerSelectedCourier(data)
	end)

	CustomGameEventManager:RegisterListener("couriers:on_rancho_button_pressed", function (_, data)
		self:OnPlayerPressedRanchoButton(data)
	end)
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

	local selection = CustomNetTables:GetTableValue("couriers", "selection")

	local player_selection = selection[tostring(player_id)]

	if type(player_selection) == "table" then
		local courier_data = player_selection[selection_key][courier_key]
		local courier = EntIndexToHScript(courier_data["courier_entindex"])

		if IsValidEntity(courier) then
			table.remove_item(self["Ranchos"][player_id]["couriers"], courier)
			Timers:RemoveTimer(courier.roam_timer)
			courier:Stop()
			courier.courier_modifier.start_time = GameRules:GetGameTime()
			courier.courier_modifier.hero_owner = PlayerResource:GetPlayer(player_id):GetAssignedHero()
			courier.courier_modifier:StartIntervalThink(0)
			courier:StartGesture(ACT_DOTA_RUN)

			-- Update nettable
			selection[tostring(player_id)][selection_key] = nil
			CustomNetTables:SetTableValue("couriers", "selection", selection)
		end
	end
end

function Couriers:AddCourierToPlayerRancho(player_id, courier_name)
	local courier = CreateUnitByName(courier_name, self:GetRandomPositionInsideRancho(player_id), true, nil, nil, PlayerResource:GetTeam(player_id))
	courier:SetControllableByPlayer(player_id, true)
	courier.courier_modifier = courier:AddNewModifier(courier, nil, "courier_aura", {})
	table.insert(self["Ranchos"][player_id]["couriers"], courier)
	self:BasicRoamAI(courier, player_id)
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
	local selection = CustomNetTables:GetTableValue("couriers", "selection") or {}

	for player_id=0,7 do
		selection[player_id] = selection[player_id] or {}
		local couriers = self:GetRandomCouriersFromPlayerRancho(player_id, COURIERS_SELECTION_AMOUNT)
		local current_selection = {}
		for _,v in pairs(couriers) do
			table.insert(current_selection, {courier_entindex=v:entindex(), courier_name=v:GetUnitName()})
		end
		table.insert(selection[player_id], current_selection)
	end

	CustomNetTables:SetTableValue("couriers", "selection", selection)
end

function Couriers:GetRandomCouriersFromPlayerRancho(player_id, amount)
	return table.random_some(self["Ranchos"][player_id]["couriers"], amount)
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
