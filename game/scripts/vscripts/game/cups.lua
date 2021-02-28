if Cups == nil then Cups = class({}) end

require("game/armies")
require("game/maps/dota_mini")

CUPS_ARMY_COUNT = 8

CUPS_BRACKETS_QUARTER = 1
CUPS_BRACKETS_SEMI = 2
CUPS_BRACKETS_FINAL = 3

function Cups:Init()
	
end

function Cups:CreateCup()
	local cup = {}

	cup.armies = Armies:GetRandomArmiesDefault(CUPS_ARMY_COUNT)

	-- Arrange brackets
	-- Filling with army IDs
	cup.brackets = {{},{},{}}
	for i = 1, CUPS_ARMY_COUNT, 2 do
		table.insert(cup.brackets[CUPS_BRACKETS_QUARTER], {i, i+1})
	end
	cup.current = {bracket=CUPS_BRACKETS_QUARTER, duel=1}

	CustomNetTables:SetTableValue("cups", "active", cup)

	self:SpawnCurrentCreeps()
end

function Cups:MainLoop()

end

function Cups:SpawnCurrentCreeps()
	local creeps_goodguys, creeps_badguys = self:GetCurrentDuelArmies()
	DotaMini:SpawnCreeps(creeps_goodguys, creeps_badguys)
end

function Cups:GetCurrentDuelArmies()
	local cup = CustomNetTables:GetTableValue("cups", "active")

	local armies = cup.armies
	local brackets = cup.brackets

	local current_bracket = brackets[tostring(cup.current.bracket)]
	local current_duel = current_bracket[tostring(cup.current.duel)]

	return armies[tostring(current_duel["1"])], armies[tostring(current_duel["2"])]
end
