if Couriers == nil then Couriers = class({}) end

COURIERS_START_AMOUNT = 10
COURIERS_SELECTION_AMOUNT = 3
COURIERS_MAX_ACTIVE = 5

COURIERS_COMMON = 1
COURIERS_UNCOMMON = 2
COURIERS_RARE = 3
COURIERS_MYTHICAL = 4
COURIERS_LEGENDARY = 5

function Couriers:Init()
	LinkLuaModifier("courier_aura", "game/modifiers/courier_aura", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_courier_ability_trigger", "game/courier_abilities/modifier_courier_ability_trigger", LUA_MODIFIER_MOTION_NONE)

	self["Couriers"] = LoadKeyValues("scripts/kv/couriers.kv")
	self["AllCouriers"] = {}
	for rarity=COURIERS_COMMON,COURIERS_LEGENDARY do
		self["AllCouriers"] = table.join(self["AllCouriers"], self["Couriers"][tostring(rarity)])
	end
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

	ListenToGameEvent('dota_non_player_used_ability', Dynamic_Wrap(self, "OnPlayerUsedAbility"), self)
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(self, "OnNPCSpawned"), self)

	-- Couriers player table
	-- "selections" lists all available courier selections to a player, in groups of three entindices
	-- selections = {randomKeyString1 = {1 = courier_entindex1, 2 = courier_entindex2, 3 = courier_entindex3}}
	-- "rancho" lists courier entindices at rancho while "active" lists couriers running around the player at battlefield
	-- rancho = {courier_entindex1=1,courier_entindex2=1,courier_entindex3=1,etc...}
	for player_id=0,WWW_MAX_PLAYERS-1 do
		PlayerTables:CreateTable(self:GetCouriersPlayerTableName(player_id), {rancho={},active={},selections={}}, {player_id})
	end
end

function Couriers:OnNPCSpawned(data)
	local unit = EntIndexToHScript(data.entindex)
	
	if IsValidEntity(unit) and unit:IsHero() then
		self:FillEmptyRancho(unit)
	end
end

function Couriers:FillEmptyRancho(hero)
	for _=1,COURIERS_START_AMOUNT do
		self:AddNewCourierToPlayerRancho(hero, table.random(self["AllCouriers"]))
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
		if event.order_type == DOTA_UNIT_ORDER_CAST_POSITION or event.order_type == DOTA_UNIT_ORDER_CAST_TARGET then
			return true
		else
			return false
		end
	end

	return true
end

-- Active/Rancho transitions

function Couriers:OnPlayerUsedAbility(data)
	local caster = EntIndexToHScript(data.caster_entindex)
	if IsValidEntity(caster) and caster:HasModifier("courier_aura") then
		if caster:GetMana() == 0 then
			self:ReturnCourierToRancho(caster:GetPlayerOwnerID(), caster)
		end
	end
end

function Couriers:ReturnCourierToRancho(player_id, courier)
	local table_name = self:GetCouriersPlayerTableName(player_id)

	PlayerTables:SetSubTableValue(table_name, "rancho", courier:entindex(), true)
	PlayerTables:SetSubTableValue(table_name, "active", courier:entindex(), false)

	self:OnCourierAddedToRancho(player_id, courier)
end

function Couriers:ActivateRanchoCourier(player_id, courier)
	local table_name = self:GetCouriersPlayerTableName(player_id)

	PlayerTables:SetSubTableValue(table_name, "rancho", courier:entindex(), false)
	PlayerTables:SetSubTableValue(table_name, "active", courier:entindex(), true)

	Timers:RemoveTimer(courier.roam_timer)
	courier:SetMana(courier:GetMaxMana())
	courier:Stop()
	courier:StartGesture(ACT_DOTA_RUN)
	courier:SetControllableByPlayer(player_id, true)

	Players:AttachCourierToHero(player_id, courier)
end

function Couriers:AddNewCourierToPlayerRancho(hero, courier_name)
	local player_id = hero:GetPlayerOwnerID()
	local courier = CreateUnitByName(courier_name, self:GetRandomPositionInsideRancho(player_id), true, nil, hero, PlayerResource:GetTeam(player_id))
	courier:AddNewModifier(courier, nil, "courier_aura", {})
	self:OnCourierAddedToRancho(player_id, courier)

	local table_name = self:GetCouriersPlayerTableName(player_id)
	PlayerTables:SetSubTableValue(table_name, "rancho", courier:entindex(), true)

	return courier
end

function Couriers:OnCourierAddedToRancho(player_id, courier)
	Players:DetachCourierFromHero(player_id, courier)
	courier:SetAbsOrigin(self:GetRandomPositionInsideRancho(player_id))
	courier:SetControllableByPlayer(player_id, false)
	self:BasicRoamAI(courier, player_id)
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

-- Selection

function Couriers:OnPlayerSelectedCourier(data)
	local player_id = data.PlayerID
	local courier_key = data.courier_key
	local selection_key = data.selection_key

	local table_name = self:GetCouriersPlayerTableName(player_id)
	local selections = PlayerTables:GetTableValue(table_name, "selections")
	local selection = selections[selection_key]

	if type(selection) == "table" then
		local courier_data = selection[courier_key]
		local courier = EntIndexToHScript(courier_data)

		if IsValidEntity(courier) then
			PlayerTables:SetSubTableValue(table_name, "selections", selection_key, nil)

			self:ActivateRanchoCourier(player_id, courier)
		end
	end
end

function Couriers:GrantCourierSelectionToPlayers()
	for player_id=0,WWW_MAX_PLAYERS-1 do
		self:GrantCourierSelectionToPlayer(player_id)
	end
end

function Couriers:GrantCourierSelectionToPlayer(player_id)
	local table_name = self:GetCouriersPlayerTableName(player_id)
	
	if table.count(PlayerTables:GetTableValue(table_name, "selections")) >= COURIERS_MAX_ACTIVE then
		return
	end
	
	-- @TODO
	-- Take already present selections into account
	local couriers = self:GetRandomCouriersFromPlayerRancho(player_id, COURIERS_SELECTION_AMOUNT)
	local new_selection = {}
	for _,v in pairs(couriers) do
		table.insert(new_selection, v)
	end

	PlayerTables:SetSubTableValue(table_name, "selections", DoUniqueString(table_name), new_selection)
end

-- Utils

function Couriers:GetCouriersPlayerTableName(player_id)
	return "couriers_player"..tostring(player_id)
end

function Couriers:GetRandomCouriersFromPlayerRancho(player_id, amount)
	local table_name = self:GetCouriersPlayerTableName(player_id)
	local rancho_couriers = PlayerTables:GetTableValue(table_name, "rancho")
	
	return table.random_some(table.make_key_table_with_value(rancho_couriers, true), amount)
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
