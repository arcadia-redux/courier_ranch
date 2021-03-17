if Bets == nil then Bets = class({}) end

function Bets:Init()
	PlayerTables:CreateTable("bets", {}, true)
end
