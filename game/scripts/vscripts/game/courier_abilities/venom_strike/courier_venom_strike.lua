if courier_venom_strike == nil then
	courier_venom_strike = class({})

	LinkLuaModifier("modifier_venom_strike", "game/courier_abilities/venom_strike/modifier_venom_strike", LUA_MODIFIER_MOTION_NONE)
end

function courier_venom_strike:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

function courier_venom_strike:GetAbilityTextureName()
	return "venomancer_poison_sting"
end

function courier_venom_strike:OnSpellStart()
	
end
