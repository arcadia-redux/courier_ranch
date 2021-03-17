if Betting == nil then Betting = class({}) end

Betting.TIME = 10

function Betting:OnEnter()
end

function Betting:OnThink()
end

function Betting:OnExit()
	WWW:StartPhase(WWW_STATE_FIGHT)
end
