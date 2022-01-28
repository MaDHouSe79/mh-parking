-- Impound vehicle for esx_policejob
function ImpoundVehicle(vehicle)
	for i = 1, #LocalVehicles do
		if vehicle == LocalVehicles[i].entity then
			QBCore.Functions.TriggerCallback("qb-parking:server:impound", function(callback)
				if callback.status then
					DeleteEntity(LocalVehicles[i].entity)
					table.remove(LocalVehicles, i)
				end
			end, LocalVehicles[i])
		end
	end
end