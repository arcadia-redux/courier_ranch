if Fight == nil then Fight = class({}) end

Fight.TIME = 30

function Fight:OnEnter()
	WWW:GetCurrentMap():ReleaseCreeps()
end

function Fight:OnThink()
end

function Fight:OnExit()
	WWW:StartPhase(WWW_STATE_POST_FIGHT)
end
