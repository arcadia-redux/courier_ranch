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
	if (!$.GetContextPanel().pt_listeners)
	{
		$.GetContextPanel().pt_listeners = {};
	}
	if ($.GetContextPanel().pt_listeners[tableName])
	{
		$.Msg("HookAndFirePlayer found existing listener (" + tableName + "); replacing with a new one...")
		PlayerTables.UnsubscribeNetTableListener($.GetContextPanel().pt_listeners[tableName]);
	}
	$.GetContextPanel().pt_listeners[tableName] = PlayerTables.SubscribeNetTableListener(tableName, callback);
	var data = PlayerTables.GetAllTableValues(tableName);
	if (data != null) {
		callback(tableName, data, null);
	}
}

function ComponentToHex(c) {
	var hex = c.toString(16);
	return hex.length == 1 ? "0" + hex : hex;
}

function RGBToHex(r, g, b) {
	return "#" + ComponentToHex(r) + ComponentToHex(g) + ComponentToHex(b);
}
