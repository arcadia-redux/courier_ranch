if Armies == nil then Armies = class({}) end

function Armies:Init()
	Armies["Units"] = LoadKeyValues("scripts/kv/armies.kv")
end

function Armies:GetRandomArmiesDefault(count)
	local armies = {}
    for i = 1, count do
		local army = {}

		table.insert(army, table.random(Armies["Units"]["Small"]))
		table.insert(army, table.random(Armies["Units"]["Medium"]))
		table.insert(army, table.random(Armies["Units"]["Large"]))

		armies[i] = army
    end

	return armies
end
