if Casting == nil then Casting = class({}) end

Casting.TIME = 10

function Casting:OnEnter()
end

function Casting:OnThink()
end

function Casting:OnExit()
	WWW:StartPhase(WWW_STATE_BETS)
end
