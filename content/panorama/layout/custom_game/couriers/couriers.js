const COURIERS_COMMON = 1;
const COURIERS_UNCOMMON = 2;
const COURIERS_RARE = 3;
const COURIERS_MYTHICAL = 4;
const COURIERS_LEGENDARY = 5;

const CourierSelectionPanel = $("#CourierSelection");
const CouriersSelectionRowPanel = $("#CouriersRow");
const CouriersHUDPanel = $("#CouriersHUD");

let rarityMap = null;
let courierHUDs = {};

function ShowCourierSelection(couriers, selectionKey) {
	CouriersSelectionRowPanel.RemoveAndDeleteChildren();
	Object.keys(couriers).forEach(key => {
		const courierKey = key;
		const courierName = Entities.GetUnitName(couriers[courierKey]);
		const courierPanel = $.CreatePanel("Panel", CouriersSelectionRowPanel, "Courier");
		courierPanel.BLoadLayoutSnippet("Courier");

		const courierPortraitRoot = courierPanel.FindChildTraverse("CourierPortraitRoot");
		courierPortraitRoot.BCreateChildren("<DOTAScenePanel environment='default' particleonly='false' unit='" + courierName + "' />");

		const courierRarityLabel = courierPanel.FindChildTraverse("RarityLabel");
		courierRarityLabel.text = $.Localize("rarity" + rarityMap[courierName]);
		courierRarityLabel.SetHasClass("Rarity" + rarityMap[courierName], true);

		const courierNameLabel = courierPanel.FindChildTraverse("CourierName");
		courierNameLabel.text = $.Localize(courierName);

		courierPanel.SetPanelEvent("onactivate", function () {
			GameEvents.SendCustomGameEventToServer("couriers:courier_selected", { selection_key: selectionKey, courier_key: parseInt(courierKey) });
		});
	});
	CourierSelectionPanel.visible = true;
}

function UpdateSelection(selections) {
	const keys = Object.keys(selections);
	if (keys.length > 0) {
		ShowCourierSelection(selections[keys[0]], keys[0]);
	}

	else {
		CourierSelectionPanel.visible = false;
	}
}

function OnRanchoButtonPressed() {
	GameEvents.SendCustomGameEventToServer("couriers:on_rancho_button_pressed", {});
}

function UpdateActiveCouriers(changes) {
	if (changes) {
		for (const [courierEntindexString, state] of Object.entries(changes))
		{
			if (!courierHUDs[courierEntindexString] && state) {
				courierHUDs[courierEntindexString] = AddCourierHUD(courierEntindexString);
			}
			else if (courierHUDs[courierEntindexString] && !state)
			{
				courierHUDs[courierEntindexString].DeleteAsync(0.5);
				courierHUDs[courierEntindexString].SetHasClass("Appear", true);
				delete courierHUDs[courierEntindexString];
			}
		}
	}
}

function AddCourierHUD(entindexString) {
	const entindex = parseInt(entindexString);
	const courierHUDPanel = $.CreatePanel("Panel", CouriersHUDPanel, "CourierHUD" + entindex);
	courierHUDPanel.SetAttributeInt("entindex", entindex);
	courierHUDPanel.BLoadLayoutSnippet("CourierHUD");
	courierHUDPanel.SetHasClass("Appear", false);
	courierHUDPanel.BCreateChildren("<DOTAScenePanel environment='default' particleonly='false' unit='" + Entities.GetUnitName(entindex) + "' />");
	const abilitiesPanel = courierHUDPanel.FindChildTraverse("Abilities");

	SetupAbility(abilitiesPanel.FindChildTraverse("CourierAbility1"), Entities.GetAbility(entindex, 0), entindex);
	SetupAbility(abilitiesPanel.FindChildTraverse("CourierAbility2"), Entities.GetAbility(entindex, 1), entindex);

	const courierManaPanel = courierHUDPanel.FindChildTraverse("ManaProgress");

	courierHUDPanel.MoveChildAfter(abilitiesPanel, courierHUDPanel.GetChild(2));
	courierHUDPanel.MoveChildAfter(courierManaPanel, courierHUDPanel.GetChild(1));

	return courierHUDPanel;
}

function SetupAbility(abilityPanel, ability, entindex) {
	const abilityName = Abilities.GetAbilityName(ability);
	abilityPanel.abilityname = abilityName;
	abilityPanel.contextEntityIndex = entindex;
	abilityPanel.SetPanelEvent("onmouseover", function () {
		$.DispatchEvent( "DOTAShowAbilityTooltipForEntityIndex", abilityPanel, abilityName, entindex );
	});
	abilityPanel.SetPanelEvent("onmouseout", function () {
		$.DispatchEvent( "DOTAHideAbilityTooltip", abilityPanel );
	});
	abilityPanel.SetPanelEvent("onactivate", function () {
		Abilities.ExecuteAbility( ability, entindex, false );
	});
}

function OnCouriersPlayerTableChanged(tableName, changes, deletions) {
	if (changes["selections"]) {
		UpdateSelection(changes["selections"]);
	}
	if (changes["active"]) {
		UpdateActiveCouriers(changes["active"]);
	}
}

function UpdateCourierHUDs() {
	$.Schedule(0.1, function () {
		Object.values(courierHUDs).forEach(courierHUDPanel => {
			const manaLabel = courierHUDPanel.FindChildTraverse("ManaLabel");
			const entindex = courierHUDPanel.GetAttributeInt("entindex", 0);
			const mana = Entities.GetMana(entindex);
			const manaMax = Entities.GetMaxMana(entindex);
			manaLabel.text = mana + " / " + manaMax;

			const courierManaPanel = courierHUDPanel.FindChildTraverse("ManaProgress");
			courierManaPanel.value = mana / manaMax;
		});
		UpdateCourierHUDs();
	});
}

function OnCouriersTableChanged(tableName, key, data) {
	if (key == "rarity_map") {
		rarityMap = data;
	}
}

(function () {
	CouriersHUDPanel.RemoveAndDeleteChildren();
	CourierSelectionPanel.visible = false;

	HookAndFire("couriers", OnCouriersTableChanged);
	HookAndFirePlayer("couriers_player" + Game.GetLocalPlayerID(), OnCouriersPlayerTableChanged);

	UpdateCourierHUDs();
})();
