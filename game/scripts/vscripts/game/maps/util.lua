function NewMap()
	local map = class({})

	map.spawned_creeps_goodguys = {}
	map.spawned_creeps_badguys = {}

	map.spawn_locations_goodguys = ""
	map.spawn_locations_badguys = ""

	return map
end

function SpawnCreepsAtLocationForTeam(creeps, location, team, creep_spawned_callback)
	local o = {}
	for _,creep in pairs(creeps) do
		local creep = CreateUnitByName(creep, location, true, nil, nil, team)
		creep:AddNewModifier( creep, nil, "creep_aura", {} )
		ParticleManager:CreateParticle("particles/econ/events/pw_compendium_2014/teleport_end_ground_flash_pw2014.vpcf", PATTACH_ABSORIGIN, creep)
		table.insert(o, creep)
		if creep_spawned_callback ~= nil then
			creep_spawned_callback(creep)
		end
	end
	return o
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

function StartBasicWaypointAI(creep, waypoints, reverse)
	local number_of_waypoints = table.getn(waypoints)

	local current_waypoint = 1
	if reverse then
		current_waypoint = number_of_waypoints
	end

	function NextWaypoint()
		if reverse then
			current_waypoint = current_waypoint - 1
		else
			current_waypoint = current_waypoint + 1
		end
	end

	Timers:CreateTimer(function()
		if IsValidEntity(creep) == false then
			return nil
		end
		if (waypoints[current_waypoint] - creep:GetAbsOrigin()):Length2D() < 200 then
			if reverse then
				current_waypoint = current_waypoint - 1
			else
				current_waypoint = current_waypoint + 1
			end
			if waypoints[current_waypoint] == nil then
				return nil
			end
		end
		if creep:IsAttacking() == false then
			creep:MoveToPositionAggressive(waypoints[current_waypoint])
		end
		DebugDrawLine(creep:GetAbsOrigin(), waypoints[current_waypoint], 1, 1, 1, true, 0.5)
		return 0.5
	end)
end
