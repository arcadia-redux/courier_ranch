if courier_aura == nil then courier_aura = class({}) end

function courier_aura:IsPurgable()
    return false
end

function courier_aura:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function courier_aura:IsHidden()
    return true
end

function courier_aura:DeclareFunctions()
	return { MODIFIER_PROPERTY_MODEL_SCALE }
end

function courier_aura:GetModifierModelScale()
	return 2.5
end

function courier_aura:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true
	}

	return state
end
