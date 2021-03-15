const PlayerColors = [
	RGBToHex(255, 0, 0),
	RGBToHex(0, 65, 100),
	RGBToHex(24, 230, 185),
	RGBToHex(83, 0, 129),
	RGBToHex(255, 251, 0),
	RGBToHex(254, 185, 13),
	RGBToHex(32, 192, 0),
	RGBToHex(228, 91, 176)
];

const PlayersPanel = $("#Players");

var PlayerPanels = [];

function CreatePlayers() {
	PlayersPanel.RemoveAndDeleteChildren();
	for (let i = 0; i < 8; i++) {
		let playerPanel = $.CreatePanel("Panel", PlayersPanel, "Player" + i);
		playerPanel.BLoadLayoutSnippet("Player");
		playerPanel.SetAttributeInt("playerId", i);
		playerPanel.style.borderColor = PlayerColors[i];

		PlayerPanels[i] = playerPanel;
	}
}

function UpdatePlayers(changes) {
	for (const [playerIdString, playerData] of Object.entries(changes)) {
		const playerId = parseInt(playerIdString);
		const playerPanel = PlayerPanels[playerId];

		const avatarImagePanel = playerPanel.FindChildTraverse("AvatarImage");
		const userNamePanel = playerPanel.FindChildTraverse("UserName");
		const goldLabelPanel = playerPanel.FindChildTraverse("GoldLabel");

		const playerInfo = Game.GetPlayerInfo(playerId);
		playerPanel.SetHasClass("NoPlayer", playerInfo == null);

		if (playerInfo) {
			avatarImagePanel.steamid = playerInfo.player_steamid;
			userNamePanel.steamid = playerInfo.player_steamid;
			goldLabelPanel.text = playerData.gold;
			playerPanel.SetAttributeInt("gold", playerData.gold);

			playerPanel.SetHasClass("Disconnected", playerInfo.player_connection_state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED);
		}
	}

	SortPlayerPanels();
}

function PlayerComparer(a, b) {
	let result = 0;
	if (a.GetAttributeInt("gold", 0) > b.GetAttributeInt("gold", 0)) {
		result = 1;
	} else {
		if (a.GetAttributeInt("gold", 0) != b.GetAttributeInt("gold", 0)) {
			result = -1;
		}
	}
	return result;
}

function SortPlayerPanels() {
	const playerPanels = PlayersPanel.Children();
	for (const panel of playerPanels.sort(PlayerComparer)) {
		panel.style.transitionDuration = "0.5s";
		PlayersPanel.MoveChildBefore(panel, PlayersPanel.GetChild(0));
		$.Schedule(2, () => {
			panel.style.transitionDuration = "0s";
		});
	}
}

function OnPlayersPlayerTableChanged(tableName, changes, deletions) {
	UpdatePlayers(changes);
}

(function () {
	CreatePlayers();

	HookAndFirePlayer("players", OnPlayersPlayerTableChanged);
})();
