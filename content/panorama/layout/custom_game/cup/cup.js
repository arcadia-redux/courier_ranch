const CUPS_BRACKETS_QUARTER = 1;
const CUPS_BRACKETS_SEMI = 2;
const CUPS_BRACKETS_FINAL = 3;

const CupPanel = $("#Cup");
const BracketsPanel = $("#Brackets");
const WinnerSlotPanel = $("#WinnerSlot");

function UpdateCupPanel(cup) {
	let current = cup["current"];
	let currentArmyDuelPanelID = "ArmyDuel" + current["bracket"] + current["duel"];
	BracketsPanel.FindChildrenWithClassTraverse("ArmyDuel").forEach(function (panel) {
		panel.Children().forEach(function (panel) {
			panel.RemoveAndDeleteChildren();
			panel.SetHasClass("Winner", false);
		});
		panel.SetHasClass("Current", panel.id == currentArmyDuelPanelID);
	});

	const armies = cup["armies"];
	const brackets = cup["brackets"];
	for (let i = CUPS_BRACKETS_QUARTER; i < CUPS_BRACKETS_FINAL + 1; i++) {
		const duels = brackets[i];
		if (duels != null) {
			for (var duelKey in duels) {
				const duel = duels[duelKey];
				for (var armyKey in duel) {
					if (armyKey != "winner")
					{
						const armySlotPanel = $("#ArmySlot" + i + duelKey + armyKey);
						FillArmySlot(armySlotPanel, armies[duel[armyKey]], duel["winner"] == armyKey);
					}
				}
			}
		}
	}

	if (cup["winner"]) {
		FillArmySlot(WinnerSlotPanel, armies[cup["winner"]], true)
	}
	else {
		WinnerSlotPanel.RemoveAndDeleteChildren();
	}
}

function FillArmySlot(armySlotPanel, army, isWinner) {
	armySlotPanel.SetHasClass("Winner", isWinner);
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
	FillArmySlot($("#StatusSlot0"), cup["armies"][armies["1"]], armies["winner"] == "1");
	FillArmySlot($("#StatusSlot1"), cup["armies"][armies["2"]], armies["winner"] == "2");
}

function OnCupPlayerTableChanged(tableName, changes, deletions) {
	if (changes["brackets"] || changes["current"])
	{
		// @TODO - Optimize
		const cup = PlayerTables.GetAllTableValues(tableName);
		UpdateCupPanel(cup);
		UpdateCupPreviewPanel(cup);
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

	HookAndFirePlayer("cup", OnCupPlayerTableChanged);
})();
