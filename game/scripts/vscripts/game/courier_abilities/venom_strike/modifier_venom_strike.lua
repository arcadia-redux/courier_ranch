if modifier_venom_strike == nil then modifier_venom_strike = class({}) end

function modifier_venom_strike:IsPurgable()
    return false
end

function modifier_venom_strike:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_venom_strike:OnAttackLanded(data)
	table.print(data)
end

function modifier_venom_strike:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED }
end
