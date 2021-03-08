const PlayerTables = GameUI.CustomUIConfig().PlayerTables;

function HookAndFire(tableName, callback) {
	CustomNetTables.SubscribeNetTableListener(tableName, callback);
	var data = CustomNetTables.GetAllTableValues(tableName);
	if (data != null) {
		for (var i = 0; i < data.length; ++i) {
			var info = data[i];
			callback(tableName, info.key, info.value);
		}
	}
}

function HookAndFirePlayer(tableName, callback) {
	PlayerTables.SubscribeNetTableListener(tableName, callback);
	var data = PlayerTables.GetAllTableValues(tableName);
	if (data != null) {
		callback(tableName, data, null);
	}
}
