_G.GameMode = GameMode or {}

require("libraries/timers")

require("extensions/init")

require("game/WWW")
require("game/couriers")
require("game/armies")

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

function Activate()
	GameMode:InitGameMode()
end

function GameMode:InitGameMode()
	local game_mode_entity = GameRules:GetGameModeEntity()
	game_mode_entity.GameMode = self

	GameRules:SetStartingGold(10000)
	GameRules:SetPreGameTime(0)
	GameRules:SetStrategyTime(0)
	GameRules:SetShowcaseTime(0)
	GameRules:EnableCustomGameSetupAutoLaunch(true)
	GameRules:SetCustomGameSetupAutoLaunchDelay(5)

	game_mode_entity:SetCustomGameForceHero("npc_dota_hero_wisp")
	game_mode_entity:SetFogOfWarDisabled(true)

	Armies:Init()
	WWW:Init()

	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(GameMode, 'OnGameRulesStateChange'),  self)
end

function GameMode:OnGameRulesStateChange()
	local state = GameRules:State_Get()
	if state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		Couriers:Init()
		GameMode:OnEnteredCustomGameSetup()
	elseif state == DOTA_GAMERULES_STATE_HERO_SELECTION then
	elseif state == DOTA_GAMERULES_STATE_PRE_GAME then
		Couriers:FillEmptyRanchos()
	elseif state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		WWW:MainLoop()
	elseif state >= DOTA_GAMERULES_STATE_POST_GAME then
	end
end

function GameMode:OnEnteredCustomGameSetup()
	PlayerResource:SetCustomTeamAssignment(0, DOTA_TEAM_GOODGUYS)

	GameRules:LockCustomGameSetupTeamAssignment(true)
	GameRules:FinishCustomGameSetup()
end
