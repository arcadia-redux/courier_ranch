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

function courier_aura:OnIntervalThink()
	if IsClient() == false then
		local elapsed_time = GameRules:GetGameTime() - self.start_time

		local current_rotation_angle = elapsed_time * 85.5
		local rotation_angle_offset	= 360 / 1

		local rotation_angle = current_rotation_angle - rotation_angle_offset * 0
		local relative_location = Vector( 0, 200, 0 )
		relative_location = RotatePosition( Vector(0,0,0), QAngle( 0, -rotation_angle, 0 ), relative_location )

		local location = GetGroundPosition( relative_location + self.hero_owner:GetAbsOrigin(), self:GetParent() )
		
		self:GetParent():SetForwardVector(UnitLookAtPoint( self:GetParent(), location))
		self:GetParent():SetAbsOrigin( location )
	end
end
