if Preparation == nil then Preparation = class({}) end

Preparation.TIME = 10

function Preparation:OnEnter()
	WWW:SpawnCurrentCreeps()
	Couriers:GrantCourierSelectionToPlayers()
end

function Preparation:OnThink()
end

function Preparation:OnExit()
	WWW:StartPhase(WWW_STATE_CASTING)
end
