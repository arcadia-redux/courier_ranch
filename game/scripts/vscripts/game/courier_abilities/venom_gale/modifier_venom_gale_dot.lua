if modifier_venom_gale_dot == nil then modifier_venom_gale_dot = class({}) end

function modifier_venom_gale_dot:OnCreated()
	self:StartIntervalThink(0.1)
end

function modifier_venom_gale_dot:IsPurgable()
    return false
end

function modifier_venom_gale_dot:GetStatusEffectName()
	return "particles/status_fx/status_effect_poison_venomancer.vpcf"
end

function modifier_venom_gale_dot:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_venom_gale_dot:OnIntervalThink()
	if IsServer() then
		local damage = {
			victim=self:GetParent(),
			attacker=self:GetCaster(),
			damage=1,
			damage_type=DAMAGE_TYPE_MAGICAL
		}
		ApplyDamage(damage)
	end
end

function modifier_venom_gale_dot:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	}
end

function modifier_venom_gale_dot:GetModifierMoveSpeedBonus_Constant(params)
	return -200
end
