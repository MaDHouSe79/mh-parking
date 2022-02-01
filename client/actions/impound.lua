-- Impound vehicle.
function ImpoundVehicle(entity)
    for i = 1, #LocalVehicles do
		if entity == LocalVehicles[i].entity then
			QBCore.Functions.TriggerCallback("qb-parking:server:impound", function(callback)
				if callback.status then
					FreezeEntityPosition(LocalVehicles[i].entity, false)
					DeleteEntity(LocalVehicles[i].entity)
					table.remove(LocalVehicles, i)
				end
			end, LocalVehicles[i])
		end
    end
end

