if Armies == nil then Armies = class({}) end

ARMIES_SMALL = 1
ARMIES_MEDIUM = 2
ARMIES_LARGE = 3

ARMIES_SPAWN_DELAY = 0.5

function Armies:Init()
	LinkLuaModifier("creep_aura", "game/modifiers/creep_aura", LUA_MODIFIER_MOTION_NONE)

	self["Units"] = LoadKeyValues("scripts/kv/armies.kv")
end

function Armies:GetRandomArmiesDefault(count)
	local armies = {}
    for i = 1, count do
		local army = {}

		table.insert(army, table.random(Armies["Units"]["Small"]))
		table.insert(army, table.random(Armies["Units"]["Medium"]))
		table.insert(army, table.random(Armies["Units"]["Large"]))

		armies[i] = army
    end

	return armies
end

-- Returns spawned creeps
function Armies:SpawnCreepsAtLocationForTeam(creeps, location, team, creep_spawned_callback)
	for s,creep in pairs(creeps) do
		local count = (ARMIES_LARGE+1 - tonumber(s)) * 2
		local i = 1
		Timers:CreateTimer(function()
			CreateUnitByNameAsync(creep, location, true, nil, nil, team, function (creep)
				creep:AddNewModifier( creep, nil, "creep_aura", {} )
				creep:AddNewModifier( creep, nil, "modifier_rooted", {} )
				ParticleManager:CreateParticle("particles/econ/events/pw_compendium_2014/teleport_end_ground_flash_pw2014.vpcf", PATTACH_ABSORIGIN, creep)
				if creep_spawned_callback ~= nil then
					creep_spawned_callback(creep)
				end
			end)
			i = i + 1
			if i > count then
				return nil
			else
				return ARMIES_SPAWN_DELAY
			end
		end)
	end
end

function Armies:StartBasicWaypointAI(creep, waypoints, reverse)
	local number_of_waypoints = table.getn(waypoints)

	local current_waypoint = 2
	if reverse then
		current_waypoint = number_of_waypoints - 1
	end

	function NextWaypoint()
		if reverse then
			current_waypoint = current_waypoint - 1
		else
			current_waypoint = current_waypoint + 1
		end
	end

	creep.waypoint_ai_timer = Timers:CreateTimer(function()
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
		return 0.5
	end)
end
