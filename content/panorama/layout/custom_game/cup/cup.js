const CUPS_BRACKETS_QUARTER = 1;
const CUPS_BRACKETS_SEMI = 2;
const CUPS_BRACKETS_FINAL = 3;

const CupPanel = $("#Cup");
const BracketsPanel = $("#Brackets");

function UpdateCupPanel(cup) {
	const armies = cup["armies"];
	const brackets = cup["brackets"];
	for (let i = CUPS_BRACKETS_QUARTER; i < CUPS_BRACKETS_FINAL + 1; i++) {
		const duels = brackets[i];
		if (duels != null) {
			for (var duelKey in duels) {
				const duel = duels[duelKey];
				for (var armyKey in duel) {
					FillArmySlot($("#ArmySlot" + i + duelKey + armyKey), armies[duel[armyKey]]);
				}	
			}
		}
	}
	BracketsPanel.FindChildrenWithClassTraverse("ArmyDuel").forEach(function(panel) {
		panel.SetHasClass("Current", false);
	});
	let current = cup["current"];
	$("#ArmyDuel"+current["bracket"]+current["duel"]).AddClass("Current");
}

function FillArmySlot(armySlotPanel, army) {
	armySlotPanel.RemoveAndDeleteChildren();
	let armyPanel = $.CreatePanel("Panel", armySlotPanel, "Army");
	armyPanel.BLoadLayoutSnippet("Army");
	let unitsRootPanel = armySlotPanel.FindChildrenWithClassTraverse("Units")[0];
	for (var key in army) {
		const unit = army[key];
		unitsRootPanel.BCreateChildren("<DOTAScenePanel environment='default' particleonly='false' unit='" + unit + "' />");
	}
}

function UpdateCupPreviewPanel(cup) {
	let current = cup["current"];
	let currentDuel = current["duel"];
	let currentBracket = current["bracket"];
	let armies = cup["brackets"][currentBracket][currentDuel];
	FillArmySlot($("#StatusSlot0"), cup["armies"][armies["1"]]);
	FillArmySlot($("#StatusSlot1"), cup["armies"][armies["2"]]);
}

function OnCupsNetTableChanged(table_name, key, data) {
	if (key == "active") {
		UpdateCupPanel(data);
		UpdateCupPreviewPanel(data);
	}
}

function OnCloseButtonPressed() {
	CupPanel.visible = false;
}

function OnDetailsButtonPressed() {
	CupPanel.visible = true;
}

(function () {
	OnCloseButtonPressed();

	HookAndFire("cups", OnCupsNetTableChanged);
})();
