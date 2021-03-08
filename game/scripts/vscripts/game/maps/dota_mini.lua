require("game/maps/util")

if DotaMini == nil then
	DotaMini = NewMap()
	DotaMini.spawn_locations_goodguys_name = "dota_mini_goodguys_spawn"
	DotaMini.spawn_locations_badguys_name = "dota_mini_badguys_spawn"
end

function DotaMini:Init()
	self.spawn_locations_goodguys = ExtractEntitiesLocations(self.spawn_locations_goodguys_name)
	self.spawn_locations_badguys = ExtractEntitiesLocations(self.spawn_locations_badguys_name)

	self.waypoints_top = ExtractWaypointsLocations("dota_mini_waypoint_*_top")
	self.waypoints_bottom = ExtractWaypointsLocations("dota_mini_waypoint_*_bottom")

	self.buildings = Entities:FindAllByName("dota_mini_building")

	self.spawned_creeps = {}
end

function DotaMini:SpawnCreeps(creeps_goodguys, creeps_badguys)
	-- 1 is bottom; 2 is top
	-- Goodguys
	for i=1,2 do
		local waypoints = nil
		if i == 1 then
			waypoints = self.waypoints_top
		else
			waypoints = self.waypoints_bottom
		end
		Armies:SpawnCreepsAtLocationForTeam(creeps_goodguys, self.spawn_locations_goodguys[i], DOTA_TEAM_GOODGUYS, function (creep)
			table.insert(self.spawned_creeps, creep)
			Armies:StartBasicWaypointAI(creep, waypoints)
		end)
	end
	-- Badguys
	for i=1,2 do
		local waypoints = nil
		if i == 1 then
			waypoints = self.waypoints_bottom
		else
			waypoints = self.waypoints_top
		end
		Armies:SpawnCreepsAtLocationForTeam(creeps_badguys, self.spawn_locations_badguys[i], DOTA_TEAM_BADGUYS, function (creep)
			table.insert(self.spawned_creeps, creep)
			Armies:StartBasicWaypointAI(creep, waypoints, true)
		end)
	end
end

function DotaMini:ReleaseCreeps()
	for _,creep in pairs(self.spawned_creeps) do
		creep:RemoveModifierByName("modifier_rooted")
	end
end

function DotaMini:RemoveAllCreeps()
	for _,creep in pairs(self.spawned_creeps) do
		if IsValidEntity(creep) then
			UTIL_Remove(creep)
		end
	end
	self.spawned_creeps = {}
end

function DotaMini:StopAllCreepsAndPlayVictoryGesture(team)
	for _,creep in pairs(self.spawned_creeps) do
		if IsValidEntity(creep) then
			if creep.waypoint_ai_timer then
				Timers:RemoveTimer(creep.waypoint_ai_timer)
			end
			creep:AddNewModifier( creep, nil, "modifier_disarmed", {} )
			creep:Stop()
			if creep:GetTeam() == team then
				creep:StartGesture(ACT_DOTA_VICTORY)
			end
		end
	end
end

function DotaMini:GetTeamWithMostCreeps()
	local teams = {}
	teams[DOTA_TEAM_GOODGUYS] = 0
	teams[DOTA_TEAM_BADGUYS] = 0

	for _,creep in pairs(self.spawned_creeps) do
		if IsValidEntity(creep) and creep:IsAlive() then
			teams[creep:GetTeam()] = teams[creep:GetTeam()] + 1
		end
	end
	if teams[DOTA_TEAM_GOODGUYS] > teams[DOTA_TEAM_BADGUYS] then
		return DOTA_TEAM_GOODGUYS
	elseif teams[DOTA_TEAM_GOODGUYS] < teams[DOTA_TEAM_BADGUYS] then
		return DOTA_TEAM_BADGUYS
	else
		return DOTA_TEAM_NOTEAM
	end
end

function DotaMini:RespawnBuildings()
	for _,building in pairs(self.buildings) do
		if building:IsAlive() == false then
			building:RespawnUnit()
		end
	end
end
