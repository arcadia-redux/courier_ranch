if courier_venom_strike == nil then
	courier_venom_strike = class({})

	LinkLuaModifier("modifier_venom_strike", "game/courier_abilities/venom_strike/modifier_venom_strike", LUA_MODIFIER_MOTION_NONE)
end

function courier_venom_strike:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
end

function courier_venom_strike:GetAbilityTextureName()
	return "venomancer_poison_sting"
end

function courier_venom_strike:OnSpellStart(keys)
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
		-- ParticleManager:SetParticleControl(particle, 10, Vector(self:GetCaster():GetTeam(),0,0))
		ParticleManager:SetParticleControl(particle, 10, Vector(self:GetCaster():GetTeam(),0,0))
	end
end
