_G.GameMode = GameMode or {}

require("libraries/timers")
require("libraries/playertables")

require("extensions/init")

require("game/constants")
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

	PrecacheResource( "particle", "particles/courier_mark.vpcf", context )
end

function Activate()
	RegisterCustomAnimationScriptForModel(
		"models/props_structures/rock_golem/tower_radiant_rock_golem.vmdl",
		"animation/props_structures/rock_golem/tower_radiant_rock_golem.lua"
	)

	RegisterCustomAnimationScriptForModel(
		"models/props_structures/rock_golem/tower_dire_rock_golem.vmdl",
		"animation/props_structures/rock_golem/tower_radiant_rock_golem.lua"
	)

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

	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)
	SetTeamCustomHealthbarColor(DOTA_TEAM_BADGUYS, 255, 28, 28)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 0)
	SetTeamCustomHealthbarColor(DOTA_TEAM_GOODGUYS, 28, 28, 255)
	for team=DOTA_TEAM_CUSTOM_1,DOTA_TEAM_CUSTOM_8 do
		GameRules:SetCustomGameTeamMaxPlayers(team, 1)
		SetTeamCustomHealthbarColor(team, TEAM_COLORS[team][1], TEAM_COLORS[team][2], TEAM_COLORS[team][3])
	end

	game_mode_entity:SetCustomGameForceHero("npc_dota_hero_wisp")
	game_mode_entity:SetFogOfWarDisabled(false)
	game_mode_entity:SetUnseenFogOfWarEnabled(true)
	game_mode_entity:SetTowerBackdoorProtectionEnabled(false)
	game_mode_entity:SetCameraDistanceOverride(1400)

	Couriers:Init()
	Armies:Init()
	WWW:Init()

	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(GameMode, 'OnGameRulesStateChange'),  self)
end

function GameMode:OnGameRulesStateChange()
	local state = GameRules:State_Get()
	if state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
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
	PlayerResource:SetCustomTeamAssignment(0, DOTA_TEAM_CUSTOM_1)

	-- GameRules:LockCustomGameSetupTeamAssignment(true)
	-- GameRules:FinishCustomGameSetup()
end
