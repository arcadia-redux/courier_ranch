function NewMap()
	local map = class({})

	map.spawned_creeps_goodguys = {}
	map.spawned_creeps_badguys = {}

	map.spawn_locations_goodguys = ""
	map.spawn_locations_badguys = ""

	return map
end

function ExtractEntitiesLocations(name)
	local t = {}
	local ents = Entities:FindAllByName(name)
	for _,ent in pairs(ents) do
		table.insert(t, ent:GetAbsOrigin())
	end
	return t
end

-- Expects table of entities with 1, 2, 3.. in name
-- Will do sorting
-- Example:
-- { dota_mini_waypoint_1_top, dota_mini_waypoint_2_top, etc... }
function ExtractWaypointsLocations(name)
	local t = {}
	local ents = Entities:FindAllByName(name)
	function Compare(a, b)
		return tonumber(string.match(a:GetName(), "%d+")) < tonumber(string.match(b:GetName(), "%d+"))
	end
	table.sort(ents, Compare)
	for _,ent in pairs(ents) do
		table.insert(t, ent:GetAbsOrigin())
	end
	return t
end

function AddFOWViewers(location, radius, duration, obstructed_Vision)
	local o = {}
	for team=DOTA_TEAM_CUSTOM_1,DOTA_TEAM_CUSTOM_8 do
		AddFOWViewer(team, location, radius, duration, obstructed_Vision)
	end
	return o
end
