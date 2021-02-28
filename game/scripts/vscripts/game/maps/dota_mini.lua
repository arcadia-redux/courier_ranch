if DotaMini == nil then DotaMini = class({}) end

function DotaMini:SpawnCreeps(creeps_goodguys, creeps_badguys)
	local spawn_locations_goodguys = ExtractEntitiesLocations("dota_mini_goodguys_spawn")
	local spawn_locations_badguys = ExtractEntitiesLocations("dota_mini_badguys_spawn")

	SpawnCreepsAtLocationsForTeam(creeps_goodguys, spawn_locations_goodguys, DOTA_TEAM_GOODGUYS)
	SpawnCreepsAtLocationsForTeam(creeps_badguys, spawn_locations_badguys, DOTA_TEAM_BADGUYS)
end

function SpawnCreepsAtLocationsForTeam(creeps, locations, team)
	for _,location in pairs(locations) do
		for _,creep in pairs(creeps) do
			local creep = CreateUnitByName(creep, location, true, nil, nil, team)
			ParticleManager:CreateParticle("particles/econ/events/pw_compendium_2014/teleport_end_ground_flash_pw2014.vpcf", PATTACH_ABSORIGIN, creep)
		end
	end
end

-- @TOMOVE
function ExtractEntitiesLocations(name)
	local t = {}
	local ents = Entities:FindAllByName(name)
	for _,ent in pairs(ents) do
		table.insert(t, ent:GetAbsOrigin())
	end
	return t
end
