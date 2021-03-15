if Debug == nil then Debug = class({}) end

function Debug:Init()
	Convars:RegisterCommand("test_gold", Dynamic_Wrap(self, "TestGold"), "Adds -100 to 100 gold to first player", FCVAR_CHEAT)
end

function Debug:TestGold()
	Players:ModifyGold(0, RandomInt(-100, 100))
end
