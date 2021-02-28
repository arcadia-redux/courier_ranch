if Cups == nil then Cups = class({}) end

require("game/armies")

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

	table.print(cup)

	CustomNetTables:SetTableValue("cups", "active", cup)
end

function Cups:MainLoop()

end
