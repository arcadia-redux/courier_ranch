if creep_aura == nil then creep_aura = class({}) end

function creep_aura:IsPurgable()
    return false
end

function creep_aura:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function creep_aura:IsHidden()
    return true
end

function creep_aura:GetModifierMoveSpeedBonus_Constant(params)
	return 100 --200
end

function creep_aura:GetModifierAttackSpeedBonus_Constant(params)
	return 50 --200
end

function creep_aura:GetModifierPreAttack_BonusDamage(params)
	return 5--75
end

function creep_aura:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}

	return funcs
end
