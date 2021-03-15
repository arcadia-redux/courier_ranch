if modifier_courier_ability_trigger == nil then modifier_courier_ability_trigger = class({}) end

function modifier_courier_ability_trigger:OnCreated(data)
	if IsServer() then
		self.creation_table = data
		self:StartIntervalThink(0.0)
	end
end

function modifier_courier_ability_trigger:IsHidden()
    return true
end

function modifier_courier_ability_trigger:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_courier_ability_trigger:OnIntervalThink()
	if IsServer() then
		local units = FindUnitsInRadius(self:GetCaster():GetTeam(), self:GetParent():GetAbsOrigin(), nil, 100, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
		for _,unit in pairs(units) do
			if unit:HasModifier("creep_aura") then
				if self.creation_table.attach_to_unit == 1 then
					ParticleManager:SetParticleControlEnt(self.creation_table.particle, 0, unit, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", unit:GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(self.creation_table.particle)
					unit:AddNewModifier(self:GetCaster(), self:GetAbility(), self.creation_table.attach_to_unit_modifier, {})
				else
					ParticleManager:DestroyParticle(self.creation_table.particle, true)
					self:GetAbility():OnTriggered({
						triggered_unit = unit,
						thinker_origin = self:GetParent():GetAbsOrigin()
					})
				end
				UTIL_Remove(self:GetParent())
				break
			end
		end
	end
end
