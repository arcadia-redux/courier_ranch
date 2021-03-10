require("game/courier_abilities/courier_ability_base")

if courier_venom_gale == nil then
	courier_venom_gale = class(courier_ability_base)
end

function courier_venom_gale:GetAbilityTextureName()
	return "venomancer_venomous_gale"
end
