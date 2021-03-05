if Bets == nil then Bets = class({}) end

Bets.TIME = 10

function Bets:OnEnter()
end

function Bets:OnThink()
end

function Bets:OnExit()
	WWW:StartPhase(WWW_STATE_FIGHT)
end
