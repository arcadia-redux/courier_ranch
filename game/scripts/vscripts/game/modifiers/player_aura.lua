if player_aura == nil then player_aura = class({}) end

function player_aura:IsPurgable()
    return false
end

function player_aura:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function player_aura:IsHidden()
    return true
end

function player_aura:GetModifierMoveSpeedBonus_Constant( params )
	return 200
end

function player_aura:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	}

	return funcs
end

function player_aura:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_FLYING] = true
	}

	return state
end
