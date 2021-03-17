if Players == nil then Players = class({}) end

PLAYERS_STARTING_GOLD = 10000

function Players:Init()
	self.heroes = {}

	ListenToGameEvent('npc_spawned', Dynamic_Wrap(self, "OnHeroSpawned"), self)

	PlayerTables:CreateTable("players", {}, true)
	
	-- Fill players table and set starting gold
	self:DoForEach(function(player_id)
		PlayerTables:SetTableValue("players", player_id, {gold = PLAYERS_STARTING_GOLD + RandomInt(-100, 100)})
	end)
end

function Players:OnHeroSpawned(keys)
	local npc = EntIndexToHScript(keys.entindex)
	if npc:IsRealHero() then
		self.heroes[npc:GetPlayerOwnerID()] = npc
		npc:AddNewModifier( npc, nil, "player_aura", {} )
	end
end

function Players:ModifyGold(player_id, amount)
	local current_gold = PlayerTables:GetTableValue("players", player_id)["gold"]
	PlayerTables:SetSubTableValue("players", player_id, "gold", current_gold + amount)
end

function Players:DoForEach(func)
	for player_id=0, WWW_MAX_PLAYERS-1 do
		func(player_id)
	end
end

function Players:AttachCourierToHero(player_id, courier)
	local hero = self:GetHero(player_id)
	if IsValidEntity(hero) then
		table.insert(self.heroes[player_id]:FindModifierByName("player_aura").attached_units, courier)
	end
end

function Players:DetachCourierFromHero(player_id, courier)
	local hero = self:GetHero(player_id)
	if IsValidEntity(hero) then
		table.remove_item(self.heroes[player_id]:FindModifierByName("player_aura").attached_units, courier)
	end
end

function Players:GetHero(player_id)
	return self.heroes[player_id]
end
