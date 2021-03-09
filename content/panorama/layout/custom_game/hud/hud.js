const GameTimeLabel = $("#GameTimeLabel");
const PhaseLabel = $("#PhaseLabel");

const Phases = { "1": "Preparation", "2": "Casting", "3": "Betting", "4": "Fight", "5": "Post Fight" };

function OnCupsNetTableChanged(table_name, key, data) {
	if (key == "meta") {
		GameTimeLabel.text = data.game_time;
		PhaseLabel.text = Phases[data.phase_id];
	}
}

(function () {
	HookAndFire("www", OnCupsNetTableChanged);
})();
