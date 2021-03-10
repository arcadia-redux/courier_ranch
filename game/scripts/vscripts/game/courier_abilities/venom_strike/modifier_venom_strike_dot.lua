if modifier_venom_strike_dot == nil then modifier_venom_strike_dot = class({}) end

function modifier_venom_strike_dot:OnCreated()
	self:StartIntervalThink(0.5)
end

function modifier_venom_strike_dot:IsPurgable()
    return false
end

function modifier_venom_strike_dot:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_venom_strike_dot:OnIntervalThink()
	if IsServer() then
		local damage = {
			victim=self:GetParent(),
			attacker=self:GetCaster(),
			damage=10,
			damage_type=DAMAGE_TYPE_MAGICAL
		}
		ApplyDamage(damage)
	
		local p = ParticleManager:CreateParticle("particles/units/heroes/hero_viper/viper_nethertoxin_proj_launch_vapor.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent())
		ParticleManager:ReleaseParticleIndex(p)
	end
end
