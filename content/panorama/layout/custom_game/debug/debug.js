function OnNextPhaseButtonPressed()
{
	GameEvents.SendCustomGameEventToServer("www:on_next_phase_button_pressed", {});
}
