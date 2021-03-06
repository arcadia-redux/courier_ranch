if WWW == nil then WWW = class({}) end

require("game/util")
require("game/maps/dota_mini")

require("game/phases/preparation")
require("game/phases/casting")
require("game/phases/betting")
require("game/phases/fight")
require("game/phases/post_fight")

CUPS_ARMY_COUNT = 8

CUPS_BRACKETS_QUARTER = 1
CUPS_BRACKETS_SEMI = 2
CUPS_BRACKETS_FINAL = 3

CUPS_DUEL_COUNT = {}
CUPS_DUEL_COUNT[CUPS_BRACKETS_QUARTER] = 4
CUPS_DUEL_COUNT[CUPS_BRACKETS_SEMI] = 2
CUPS_DUEL_COUNT[CUPS_BRACKETS_FINAL] = 1

CUPS_MINIMUM_BETS = {}
CUPS_MINIMUM_BETS[1] = 500
CUPS_MINIMUM_BETS[2] = 1000
CUPS_MINIMUM_BETS[3] = 2000
CUPS_MINIMUM_BETS[4] = 3500
CUPS_MINIMUM_BETS[5] = 5000
CUPS_MINIMUM_BETS[6] = 7000
CUPS_MINIMUM_BETS[7] = 10000
CUPS_MINIMUM_BETS[8] = 15000
CUPS_MINIMUM_BETS[9] = 20000
CUPS_MINIMUM_BETS[10] = 30000
CUPS_MINIMUM_BETS[11] = 50000
CUPS_MINIMUM_BETS[12] = 100000
CUPS_MINIMUM_BETS[13] = 1000000
CUPS_MINIMUM_BETS[14] = 10000000
CUPS_MINIMUM_BETS[15] = 100000000

WWW_STATE_PREPARATION = 1
WWW_STATE_CASTING = 2
WWW_STATE_BETTING = 3
WWW_STATE_FIGHT = 4
WWW_STATE_POST_FIGHT = 5

WWW_MAX_PLAYERS = 8

function WWW:Init()
	LinkLuaModifier("player_aura", "game/modifiers/player_aura", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("dummy_aura", "game/modifiers/dummy_aura", LUA_MODIFIER_MOTION_NONE)

	ListenToGameEvent('npc_spawned', Dynamic_Wrap(self, "OnNPCSpawned"), self)
	ListenToGameEvent("entity_killed", Dynamic_Wrap(self, "OnEntityKilled"), self)

	CustomGameEventManager:RegisterListener("www:on_next_phase_button_pressed", function (_, data)
		self:ForceNextPhase()
	end)

	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(WWW, "OrderFilter"), self)

	self.phases = {}
	self.phases[WWW_STATE_PREPARATION] = Preparation
	self.phases[WWW_STATE_CASTING] = Casting
	self.phases[WWW_STATE_BETTING] = Betting
	self.phases[WWW_STATE_FIGHT] = Fight
	self.phases[WWW_STATE_POST_FIGHT] = PostFight

	self.current_cup_id = 1

	PlayerTables:CreateTable("cup", {}, true)
end

function WWW:OrderFilter(event)
	return Couriers:OrderFilter(event)
end

function WWW:OnNPCSpawned(keys)
	local npc = EntIndexToHScript(keys.entindex)
end

function WWW:OnEntityKilled(keys)
	local killed_unit = EntIndexToHScript(keys.entindex_killed)

	if killed_unit then
		-- Destroy unit particles
		if killed_unit.particles then
			for _,v in pairs(killed_unit.particles) do
				ParticleManager:DestroyParticle(v, false)
				ParticleManager:ReleaseParticleIndex(v)
			end
		end
		-- Track fort destroyed event
		if killed_unit:IsBuilding() then
			if string.match(killed_unit:GetUnitName(), "npc_dota_badguys_fort")
			or string.match(killed_unit:GetUnitName(), "npc_dota_goodguys_fort") then
				local won_team = EntIndexToHScript(keys.entindex_attacker):GetTeam()
				FireGameEventLocal("fort_destroyed", {won_team=won_team})
			end
		end
	end
end

function WWW:CreateCup(id)
	local cup = {}

	cup.id = id or 1
	if #CUPS_MINIMUM_BETS < cup.id then
		cup.minimum_bet = CUPS_MINIMUM_BETS[#CUPS_MINIMUM_BETS]
	else
		cup.minimum_bet = CUPS_MINIMUM_BETS[cup.id]
	end

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
	PlayerTables:SetTableValues("cup", cup)

	self:GetCurrentMap():Init()
end

function WWW:RecordWin(team)
	local cup = PlayerTables:GetAllTableValues("cup")
	
	-- Record winners
	cup.brackets[cup.current.bracket][cup.current.duel]["winner"] = team-1
	
	-- Update next brackets
	local current_army = cup.brackets[cup.current.bracket][cup.current.duel][team-1]
	if cup.current.bracket == CUPS_BRACKETS_FINAL then
		cup.winner = current_army
	else
		local next_duel_id = math.floor((cup.current.duel / 2)+0.5)
		cup.brackets[cup.current.bracket+1][next_duel_id] = cup.brackets[cup.current.bracket+1][next_duel_id] or {}
		cup.brackets[cup.current.bracket+1][next_duel_id][math.repeat_value(tonumber(cup.current.duel)-1,2)+1] = current_army
	end

	PlayerTables:SetTableValues("cup", cup)
end

function WWW:AdvanceCurrentCup()
	local cup = PlayerTables:GetAllTableValues("cup")

	if cup.current.bracket == CUPS_BRACKETS_FINAL then
		WWW:CreateCup(cup.id + 1)
	else
		if cup.current.duel == CUPS_DUEL_COUNT[cup.current.bracket] then
			cup.current.duel = 1
			cup.current.bracket = cup.current.bracket + 1
		else
			cup.current.duel = cup.current.duel + 1
		end
	
		PlayerTables:SetTableValues("cup", cup)
	end
end

function WWW:MainLoop()
	self:CreateCup()
	self:StartPhase(WWW_STATE_PREPARATION)
end

function WWW:ForceNextPhase()
	Timers:RemoveTimer(self.phase_timer)
	self.current_phase:OnExit()
end

function WWW:StartPhase(phase_id)
	self.current_phase = self.phases[phase_id]
	local game_time = self.current_phase.TIME
	CustomNetTables:SetTableValue("www", "meta", {game_time = game_time, phase_id = phase_id})
	self.current_phase:OnEnter()
	self.phase_timer = Timers:CreateTimer(1.0, function()
		game_time = game_time - 1
		CustomNetTables:SetTableValue("www", "meta", {game_time = game_time, phase_id = phase_id})
		self.current_phase:OnThink()
		if game_time < 0 then
			self.current_phase:OnExit()
			return nil
		end
		return 1.0
	end)
end

function WWW:SpawnCurrentCreeps()
	local creeps_goodguys, creeps_badguys = self:GetCurrentDuelArmies()
	self:GetCurrentMap():SpawnCreeps(creeps_goodguys, creeps_badguys)
end

function WWW:GetCurrentDuelArmies()
	local cup = PlayerTables:GetAllTableValues("cup")

	local armies = cup.armies
	local brackets = cup.brackets

	local current_bracket = brackets[cup.current.bracket]
	local current_duel = current_bracket[cup.current.duel]

	return armies[current_duel[1]], armies[current_duel[2]]
end

function WWW:GetCurrentMap()
	return _G[PlayerTables:GetTableValue("cup", "map")]
end
