-- Create Vehicle Entity.
local function CreateVehicleEntity(vehicle)
    LoadModel(vehicle.props["model"])
    return CreateVehicle(vehicle.props["model"], vehicle.location.x, vehicle.location.y, vehicle.location.z, vehicle.location.w, true)
end

-- Delete the vehicle near the location.
local function DeleteNearByVehicle(location)
    local vehicle, distance = QBCore.Functions.GetClosestVehicle(location)
    if distance <= 1 then
        for i = 1, #LocalVehicles do
            if LocalVehicles[i].entity == vehicle then
            table.remove(LocalVehicles, i)
            end
            local tmpModel = GetEntityModel(vehicle)
            SetModelAsNoLongerNeeded(tmpModel)
            DeleteEntity(vehicle)
            tmpModel = nil
        end
    end
end

-- Make vehicle ready to drive.
local function MakeVehicleReadyToDrive(vehicle)
    DeleteNearByVehicle(vector3(vehicle.location.x, vehicle.location.y, vehicle.location.z)) -- Delete the local entity first
    LoadModel(vehicle.props["model"])
    local vehicleEntity = CreateVehicleEntity(vehicle)
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicleEntity, -1)
    QBCore.Functions.SetVehicleProperties(vehicleEntity, vehicle.props)
    RequestCollisionAtCoord(vehicle.location.x, vehicle.location.y, vehicle.location.z)      -- Add Vehicle On Ground Properly
    SetVehicleOnGroundProperly(vehicleEntity)
    FreezeEntityPosition(vehicleEntity, false)
    SetVehicleLivery(vehicleEntity, vehicle.livery)
    SetVehRadioStation(vehicleEntity, 'OFF')
    SetVehicleDirtLevel(vehicleEntity, 0)
    SetVehicleEngineHealth(vehicleEntity, vehicle.health.engine)
    SetVehicleBodyHealth(vehicleEntity, vehicle.health.body)
    SetVehiclePetrolTankHealth(vehicleEntity, vehicle.health.tank)
    exports[Config.YourFuelExportName]:SetFuel(vehicleEntity, vehicle.health.tank)
    SetModelAsNoLongerNeeded(vehicle.props["model"])
end

-- Drive The vehicle.
function Drive(player, vehicle)
    action = 'drive'
    QBCore.Functions.TriggerCallback("qb-parking:server:drive", function(callback)
        if callback.status then
            DeleteVehicle(vehicle.entity)
            DeleteVehicle(GetVehiclePedIsIn(player))
            vehicle = false
            MakeVehicleReadyToDrive(callback.data)
        else
            QBCore.Functions.Notify(callback.message, "error", 5000)
        end
    end, vehicle)
end
