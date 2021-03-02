if WWW == nil then WWW = class({}) end

require("game/maps/dota_mini")

CUPS_ARMY_COUNT = 8

CUPS_BRACKETS_QUARTER = 1
CUPS_BRACKETS_SEMI = 2
CUPS_BRACKETS_FINAL = 3

function WWW:Init()
	LinkLuaModifier( "creep_aura", "game/modifiers/creep_aura", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "player_aura", "game/modifiers/player_aura", LUA_MODIFIER_MOTION_NONE )

	ListenToGameEvent('npc_spawned', Dynamic_Wrap(WWW, "OnHeroSpawned"), WWW)
end

function WWW:OnHeroSpawned(keys)
	local npc = EntIndexToHScript(keys.entindex)
	if npc:IsRealHero() then
		npc:AddNewModifier( npc, nil, "player_aura", {} )
	end
end

function WWW:CreateCup()
	local cup = {}

	cup.armies = Armies:GetRandomArmiesDefault(CUPS_ARMY_COUNT)

	-- Arrange brackets
	-- Filling with army IDs
	cup.brackets = {{},{},{}}
	for i = 1, CUPS_ARMY_COUNT, 2 do
		table.insert(cup.brackets[CUPS_BRACKETS_QUARTER], {i, i+1})
	end
	cup.current = {bracket=CUPS_BRACKETS_QUARTER, duel=1}

	-- Select Map
	cup.map = "DotaMini"

	-- @TODO
	-- Optimize table usage
	CustomNetTables:SetTableValue("cups", "active", cup)

	GetCurrentMap():Init()
	self:SpawnCurrentCreeps()
	self:MainLoop()
end

function WWW:MainLoop()
	Couriers:GrantCourierSelectionToPlayers()
end

function WWW:SpawnCurrentCreeps()
	local creeps_goodguys, creeps_badguys = self:GetCurrentDuelArmies()
	GetCurrentMap():SpawnCreeps(creeps_goodguys, creeps_badguys)
end

function WWW:GetCurrentDuelArmies()
	local cup = CustomNetTables:GetTableValue("cups", "active")

	local armies = cup.armies
	local brackets = cup.brackets

	local current_bracket = brackets[tostring(cup.current.bracket)]
	local current_duel = current_bracket[tostring(cup.current.duel)]

	return armies[tostring(current_duel["1"])], armies[tostring(current_duel["2"])]
end

function GetCurrentMap()
	local cup = CustomNetTables:GetTableValue("cups", "active")
	return _G[cup.map]
end
