if Players == nil then Players = class({}) end

PLAYERS_STARTING_GOLD = 10000

function Players:Init()
	PlayerTables:CreateTable("players", {}, true)
	
	-- Fill players table and set starting gold
	self:DoForEach(function(player_id)
		PlayerTables:SetTableValue("players", player_id, {gold = PLAYERS_STARTING_GOLD + RandomInt(-100, 100)})
	end)
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
