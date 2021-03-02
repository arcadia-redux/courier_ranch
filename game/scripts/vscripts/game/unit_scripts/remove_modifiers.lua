function Spawn(entityKeyValues)
	Timers:CreateTimer(function ()
		for i=0,thisEntity:GetModifierCount() do 
			thisEntity:RemoveModifierByName(thisEntity:GetModifierNameByIndex(i))
		end
	end)
end
