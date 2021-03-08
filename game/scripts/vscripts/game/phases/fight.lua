if Fight == nil then Fight = class({}) end

Fight.TIME = 30

function Fight:OnEnter()
	WWW:GetCurrentMap():ReleaseCreeps()

	self.fort_destroyed_listener = ListenToGameEvent("fort_destroyed", Dynamic_Wrap(self, "OnFortDestroyed"), self)
end

function Fight:OnThink()
end

function Fight:OnExit()
	if self.won_team == nil then
		self.won_team = WWW:GetCurrentMap():GetTeamWithMostCreeps()
	end

	StopListeningToGameEvent(self.fort_destroyed_listener)
	WWW:RecordWin(self.won_team)
	WWW:GetCurrentMap():StopAllCreepsAndPlayVictoryGesture(self.won_team)
	WWW:StartPhase(WWW_STATE_POST_FIGHT)

	self.won_team = nil
	self.fort_destroyed_listener = nil
end

function Fight:OnFortDestroyed(event)
	self.won_team = event.won_team
	WWW:ForceNextPhase()
end
