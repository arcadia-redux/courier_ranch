require("game/courier_abilities/courier_ability_base")

if courier_venom_gale == nil then
	courier_venom_gale = class(courier_ability_base)

	LinkLuaModifier("modifier_venom_gale_dot", "game/courier_abilities/venom_gale/modifier_venom_gale_dot", LUA_MODIFIER_MOTION_NONE)
end

function courier_venom_gale:GetAbilityTextureName()
	return "venomancer_venomous_gale"
end

function courier_venom_gale:OnTriggered(data)
	local triggered_unit = data.triggered_unit
	local thinker_origin = data.thinker_origin

    local particle = ParticleManager:CreateParticle("particles/econ/items/rubick/rubick_arcana/rbck_arc_venomancer_poison_nova.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, triggered_unit)
    ParticleManager:SetParticleControlEnt(particle, 0, nil, PATTACH_CUSTOMORIGIN_FOLLOW, "attach_head", triggered_unit:GetOrigin(), true)
    ParticleManager:SetParticleControlForward(particle, 1, (triggered_unit:GetOrigin() - triggered_unit:GetOrigin()):Normalized())
	ParticleManager:ReleaseParticleIndex(particle)
	local units = FindUnitsInRadius(triggered_unit:GetTeam(), thinker_origin, nil, 600, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
    for _,unit in pairs(units) do
        unit:AddNewModifier(unit, self, "modifier_venom_gale_dot", { duration = 5 })
    end
end
