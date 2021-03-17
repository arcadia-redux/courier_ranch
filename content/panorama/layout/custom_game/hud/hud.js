const GameTimeLabel = $("#GameTimeLabel");
const PhaseLabel = $("#PhaseLabel");

const Phases = { "1": "Preparation", "2": "Casting", "3": "Betting", "4": "Fight", "5": "Post Fight" };

let phase = -1;

function OnWWWNetTableChanged(table_name, key, data) {
	if (key == "meta") {
		GameTimeLabel.text = data.game_time;
		PhaseLabel.text = Phases[data.phase_id];
		phase = data.phase_id;
	}
}

function IsCastingPhase() {
	return phase == 2;
}

(function () {
	HookAndFire("www", OnWWWNetTableChanged);

	GameUI.CustomUIConfig().IsCastingPhase = IsCastingPhase;
})();
