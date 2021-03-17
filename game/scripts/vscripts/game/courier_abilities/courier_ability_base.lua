if courier_ability_base == nil then
	courier_ability_base = class({})

	courier_ability_base.attach_to_unit = 0
	courier_ability_base.attach_to_unit_modifier = ""
end

function courier_ability_base:GetCastPoint()
	return 0.0
end

function courier_ability_base:GetBehavior()
	if IsServer() then
		local phase_id = CustomNetTables:GetTableValue("www", "meta")["phase_id"]
		if phase_id ~= WWW_STATE_CASTING then
			return DOTA_ABILITY_BEHAVIOR_PASSIVE
		else
			return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
		end
	end
	if IsClient() then
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	end
end

function courier_ability_base:GetAbilityTextureName()
	return "venomancer_poison_sting"
end

function courier_ability_base:GetManaCost()
	return 1
end

function courier_ability_base:GetCooldown()
	return 10
end

function courier_ability_base:OnSpellStart()
	if IsServer() then
		local cursor = self:GetCursorPosition()

		EmitSoundOnLocationWithCaster(cursor, "DOTA_Item.HotD.Activate", self:GetCaster())

		local particle = ParticleManager:CreateParticle("particles/courier_mark.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(particle, 0, cursor)
		ParticleManager:SetParticleControl(particle, 9, TEAM_COLORS[self:GetCaster():GetTeam()])
		ParticleManager:SetParticleControl(particle, 10, Vector(self:GetCaster():GetTeam(),0,0))
		
		local thinker = CreateModifierThinker(self:GetCaster(), self, "modifier_courier_ability_trigger", {
			particle = particle,
			attach_to_unit = self.attach_to_unit,
			attach_to_unit_modifier = self.attach_to_unit_modifier
		}, cursor, self:GetCaster():GetTeam(), false)
		WWW:GetCurrentMap():AddCourierAbilityThinker(thinker)

		-- Put cooldown on all abilities
		local caster = self:GetCaster()
		for i=0,caster:GetAbilityCount()-1 do
			local ability = caster:GetAbilityByIndex(i)
			if IsValidEntity(ability) then
				ability:StartCooldown(self:GetCooldown())
			end
		end
	end
end

function courier_ability_base:OnTriggered(data)
	print("[Warning] "..self:GetAbilityName()..":OnTriggered is not implemented!")
end
