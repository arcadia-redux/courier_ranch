if courier_ability_base == nil then
	courier_ability_base = class({})

	courier_ability_base.attach_to_unit = 0
	courier_ability_base.attach_to_unit_modifier = ""
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

function courier_ability_base:OnSpellStart()
	if IsServer() then
		local cursor = self:GetCursorPosition()

		local particle = ParticleManager:CreateParticle("particles/courier_mark.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(particle, 0, cursor)
		ParticleManager:SetParticleControl(particle, 9, TEAM_COLORS[self:GetCaster():GetTeam()])
		ParticleManager:SetParticleControl(particle, 10, Vector(self:GetCaster():GetTeam(),0,0))
		
		local thinker = CreateModifierThinker(self:GetCaster(), self, "modifier_courier_ability_trigger", {attach_to_unit=self.attach_to_unit, particle=particle, attach_to_unit_modifier=self.attach_to_unit_modifier}, cursor, self:GetCaster():GetTeam(), false)
	end
end

function courier_ability_base:OnTriggered(data)
	print("courier_ability_base:OnTriggered")
end
