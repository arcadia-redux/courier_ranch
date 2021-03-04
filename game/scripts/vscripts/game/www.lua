if WWW == nil then WWW = class({}) end

require("game/constants")
require("game/util")
require("game/maps/dota_mini")

CUPS_ARMY_COUNT = 8

CUPS_BRACKETS_QUARTER = 1
CUPS_BRACKETS_SEMI = 2
CUPS_BRACKETS_FINAL = 3

WWW_STATE_PREPARATION = 1
WWW_STATE_CASTING = 2
WWW_STATE_BETS = 3
WWW_STATE_FIGHT = 4
WWW_STATE_POST_FIGHT = 5

function WWW:Init()
	LinkLuaModifier("player_aura", "game/modifiers/player_aura", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("dummy_aura", "game/modifiers/dummy_aura", LUA_MODIFIER_MOTION_NONE)

	ListenToGameEvent('npc_spawned', Dynamic_Wrap(self, "OnHeroSpawned"), self)

	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(WWW, "OrderFilter"), self)
end

function WWW:OrderFilter(event)
	return Couriers:OrderFilter(event)
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
end

function WWW:MainLoop()
	self.state = WWW_STATE_PREPARATION

	WWW:CreateCup()

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
