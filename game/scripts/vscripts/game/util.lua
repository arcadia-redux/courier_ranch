function CreateTargetDummyUnit(location)
	local unit = CreateUnitByName("npc_dota_target_dummy", location, true, nil, nil, DOTA_TEAM_NOTEAM)
	unit:AddNewModifier(unit, nil, "dummy_aura", {})

	return unit
end

function UnitLookAtPoint(unit, point)
	local dir = (point - unit:GetAbsOrigin()):Normalized()
	dir.z = 0
	if dir == Vector(0,0,0) then return unit:GetForwardVector() end
	return dir
end
