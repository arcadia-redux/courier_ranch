const GameTimeLabel = $("#GameTimeLabel")

function OnCupsNetTableChanged(table_name, key, data) {
	if (key == "meta") {
		GameTimeLabel.text = data.game_time;
	}
}

(function () {
	HookAndFire("cups", OnCupsNetTableChanged);
})();
