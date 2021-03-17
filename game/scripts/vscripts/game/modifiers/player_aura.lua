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

function player_aura:OnCreated()
	if IsServer() then
		self.start_time = GameRules:GetGameTime()
		self.attached_units = {}
		self:StartIntervalThink(0.0)
	end
end

function player_aura:OnIntervalThink()
	if IsServer() then
		local origin = self:GetParent():GetAbsOrigin()
		local elapsed_time = GameRules:GetGameTime() - self.start_time

		local current_rotation_angle = elapsed_time * 85.5
		local rotation_angle_offset	= 360 / #self.attached_units

		for k,v in pairs(self.attached_units) do
			local rotation_angle = current_rotation_angle - rotation_angle_offset * (k - 1)
			local relative_location = Vector( 0, 200, 0 )
			relative_location = RotatePosition( Vector(0,0,0), QAngle( 0, -rotation_angle, 0 ), relative_location )
	
			local location = GetGroundPosition( relative_location + origin, self:GetParent() )
			
			v:SetForwardVector(UnitLookAtPoint(v, location))
			v:SetAbsOrigin( location )
		end
	end
end
