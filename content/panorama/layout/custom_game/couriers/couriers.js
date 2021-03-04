const COURIERS_COMMON = 1;
const COURIERS_UNCOMMON = 2;
const COURIERS_RARE = 3;
const COURIERS_MYTHICAL = 4;
const COURIERS_LEGENDARY = 5;

const CourierSelection = $("#CourierSelection");
const CouriersRowPanel = $("#CouriersRow");

let rarityMap = null;

function ShowCourierSelection(couriers, selectionKey) {
	CouriersRowPanel.RemoveAndDeleteChildren();
	Object.keys(couriers).forEach(key => {
		const courierKey = key;
		const courierName = couriers[courierKey]["courier_name"];
		const courierPanel = $.CreatePanel("Panel", CouriersRowPanel, "Courier");
		courierPanel.BLoadLayoutSnippet("Courier");

		const courierPortraitRoot = courierPanel.FindChildTraverse("CourierPortraitRoot");
		courierPortraitRoot.BCreateChildren("<DOTAScenePanel environment='default' particleonly='false' unit='" + courierName + "' />");
	
		const courierRarityLabel = courierPanel.FindChildTraverse("RarityLabel");
		courierRarityLabel.text = $.Localize("rarity" + rarityMap[courierName]);
		courierRarityLabel.SetHasClass("Rarity" + rarityMap[courierName], true);

		const courierNameLabel = courierPanel.FindChildTraverse("CourierName");
		courierNameLabel.text = $.Localize(courierName);

		courierPanel.SetPanelEvent("onactivate", function() { 
			OnCourierSelected(selectionKey, courierKey);
		});
	});
	CourierSelection.visible = true;
}

function UpdateSelection(selections) {
	const keys = Object.keys(selections);
	if (keys.length > 0) {
		ShowCourierSelection(selections[keys[0]], keys[0]);
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

function OnRanchoButtonPressed()
{
	GameEvents.SendCustomGameEventToServer("couriers:on_rancho_button_pressed", {});
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
