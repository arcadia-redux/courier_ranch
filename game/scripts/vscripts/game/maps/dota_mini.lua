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
