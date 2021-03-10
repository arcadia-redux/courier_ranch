if courier_ability_base == nil then
	courier_ability_base = class({})
end

function courier_ability_base:GetCastPoint()
	return 0.0
end

function courier_ability_base:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
end

function courier_ability_base:GetAbilityTextureName()
	return "venomancer_poison_sting"
end

function courier_ability_base:OnSpellStart(keys)
	if IsServer() then
		local target_unit = self:GetCursorTarget()
		if IsValidEntity(target_unit) == false then
			local cursor = self:GetCursorPosition()
			local closest_units = FindUnitsInRadius(self:GetCaster():GetTeam(),cursor,nil,2000,DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
			for _,unit in pairs(closest_units) do
				if v:HasModifier("creep_aura") then
					target_unit = unit
					break
				end
			end
		end

		if IsValidEntity(target_unit) == false then
			return
		end

		local particle = ParticleManager:CreateParticle("particles/courier_mark.vpcf", PATTACH_ABSORIGIN_FOLLOW, target_unit)
		ParticleManager:SetParticleControl(particle, 9, TEAM_COLORS[self:GetCaster():GetTeam()])
		ParticleManager:SetParticleControl(particle, 10, Vector(self:GetCaster():GetTeam(),0,0))

		target_unit:AddNewModifier(self:GetCaster(), self, "modifier_venom_strike", {})
	end
end
