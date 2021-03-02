const COURIERS_COMMON = 1;
const COURIERS_UNCOMMON = 2;
const COURIERS_RARE = 3;
const COURIERS_MYTHICAL = 4;
const COURIERS_LEGENDARY = 5;

const CourierSelection = $("#CourierSelection");
const CouriersRowPanel = $("#CouriersRow");

let rarityMap = null;

function ShowCourierSelection(selections, selectionKey) {
	const couriers = selections[selectionKey];
	CouriersRowPanel.RemoveAndDeleteChildren();
	Object.keys(couriers).forEach(key => {
		const courierKey = key;
		const courier = couriers[courierKey];
		const courierPanel = $.CreatePanel("Panel", CouriersRowPanel, "Courier");
		courierPanel.BLoadLayoutSnippet("Courier");

		const courierPortraitRoot = courierPanel.FindChildTraverse("CourierPortraitRoot");
		courierPortraitRoot.BCreateChildren("<DOTAScenePanel environment='default' particleonly='false' unit='" + courier + "' />");
	
		const courierRarityLabel = courierPanel.FindChildTraverse("RarityLabel");
		courierRarityLabel.text = $.Localize("rarity" + rarityMap[courier]);
		courierRarityLabel.SetHasClass("Rarity" + rarityMap[courier], true);

		const courierNameLabel = courierPanel.FindChildTraverse("CourierName");
		courierNameLabel.text = $.Localize(courier);

		courierPanel.SetPanelEvent("onactivate", function() { 
			$.Msg(courierKey);
			OnCourierSelected(selectionKey, courierKey);
		});
	});
	CourierSelection.visible = true;
}

function UpdateSelection(selectionData) {
	const keys = Object.keys(selectionData);
	if (keys.length > 0) {
		ShowCourierSelection(selectionData, keys[0]);
	}
	else
	{
		CourierSelection.visible = false;
	}
}

function OnCourierSelected(selectionKey, courierKey)
{
	GameEvents.SendCustomGameEventToServer("couriers:courier_selected", { selection_key: selectionKey, courier_key: courierKey });
}

function OnCouriersNetTableChanged(table_name, key, data) {
	if (key == "selection") {
		UpdateSelection(data[Game.GetLocalPlayerID()]);
	}
	else if (key == "rarity_map") {
		rarityMap = data;
	}
}

(function () {
	CourierSelection.visible = false;

	HookAndFire("couriers", OnCouriersNetTableChanged);
})();
