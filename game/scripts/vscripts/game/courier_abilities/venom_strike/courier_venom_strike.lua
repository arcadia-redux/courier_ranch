require("game/courier_abilities/courier_ability_base")

if courier_venom_strike == nil then
	courier_venom_strike = class(courier_ability_base)

	LinkLuaModifier("modifier_venom_strike", "game/courier_abilities/venom_strike/modifier_venom_strike", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_venom_strike_dot", "game/courier_abilities/venom_strike/modifier_venom_strike_dot", LUA_MODIFIER_MOTION_NONE)

	courier_venom_strike.attach_to_unit = 1
	courier_venom_strike.attach_to_unit_modifier = "modifier_venom_strike"
end

function courier_venom_strike:GetAbilityTextureName()
	return "venomancer_poison_sting"
end
