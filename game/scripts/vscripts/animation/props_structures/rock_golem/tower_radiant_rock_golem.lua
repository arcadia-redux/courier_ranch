model:CreateSequence(
	{
		name = "idle_custom",
		looping = true,
		sequences = {
			{ "idle_neutral" }
		},
		activities = {
				{ name = "ACT_DOTA_IDLE", weight = 1 }
		}
	}
)

model:CreateSequence(
	{
		name = "attack_custom",
		looping = true,
		sequences = {
			{ "attack_neutral" }
		},
		activities = {
				{ name = "ACT_DOTA_ATTACK", weight = 1 }
		}
	}
)

model:CreateSequence(
	{
		name = "death_custom",
		looping = false,
		sequences = {
			{ "death_neutral" }
		},
		activities = {
				{ name = "ACT_DOTA_DIE", weight = 1 }
		}
	}
)
