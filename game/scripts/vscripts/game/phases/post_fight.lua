if PostFight == nil then PostFight = class({}) end

PostFight.TIME = 10

function PostFight:OnEnter()
end

function PostFight:OnThink()
end

function PostFight:OnExit()
	WWW:GetCurrentMap():RemoveAllCreeps()
	WWW:AdvanceCurrentCup()
	WWW:StartPhase(WWW_STATE_PREPARATION)
end
