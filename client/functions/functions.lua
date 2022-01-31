local function CreateParkDisPlay(vehicleData)
    local owner = string.format(Lang:t("info.owner", {owner = vehicleData.citizenname}))..'\n'
    local model = string.format(Lang:t("info.model", {model = vehicleData.model}))..'\n'
    local plate = string.format(Lang:t("info.plate", {plate = vehicleData.plate}))..'\n'
    return string.format("%s", model..plate..owner)
end

local function PrepareVehicle(entity, vehicleData)
    -- Add Vehicle On Ground Properly
    RequestCollisionAtCoord(vehicleData.vehicle.location.x, vehicleData.vehicle.location.y, vehicleData.vehicle.location.z)
    SetVehicleOnGroundProperly(entity)
    SetEntityAsMissionEntity(entity, true, true)
    SetEntityInvincible(entity, true)
    SetEntityHeading(vehicle, vehicleData.vehicle.location.w)
    SetVehicleLivery(entity, vehicleData.vehicle.livery)
    SetVehicleEngineHealth(entity, vehicleData.vehicle.health.engine)
    SetVehicleBodyHealth(entity, vehicleData.vehicle.health.body)
    SetVehiclePetrolTankHealth(entity, vehicleData.vehicle.health.tank)
    exports[Config.YourFuelExportName]:SetFuel(entity, vehicleData.vehicle.health.tank)
    SetVehRadioStation(entity, 'OFF')
    SetVehicleDirtLevel(entity, 0)
    QBCore.Functions.SetVehicleProperties(entity, vehicleData.vehicle.props)
    SetModelAsNoLongerNeeded(vehicleData.vehicle.props["model"])
end

-- Load Entity
local function LoadEntity(vehicleData, type)
    LoadModel(vehicleData.vehicle.props["model"])
    vehicleEntity = CreateVehicle(vehicleData.vehicle.props["model"], vehicleData.vehicle.location.x, vehicleData.vehicle.location.y, vehicleData.vehicle.location.z, vehicleData.vehicle.location.w, false)
    QBCore.Functions.SetVehicleProperties(vehicleEntity, vehicleData.vehicle.props)
    if type == 'server' then
        TriggerEvent('vehiclekeys:client:SetVehicleOwnerToCitizenid', vehicleData.plate, vehicleData.citizenid)
    end
    PrepareVehicle(vehicleEntity, vehicleData)
end

local function DoAction(action)
    if action == 'drive' then
	action = nil
	if LastUsedPlate and vehicles[i].plate == LastUsedPlate then
	    TaskWarpPedIntoVehicle(PlayerPedId(), vehicleEntity, -1)
	    TaskLeaveVehicle(PlayerPedId(), vehicleEntity)
	    LastUsedPlate = nil
	end
    end
end

-- Insert Data to table
local function TableInsert(vehicleEntity, vehicleData)
    table.insert(LocalVehicles, {
	entity      = vehicleEntity,
	vehicle     = vehicleData.data,
	plate       = vehicleData.plate,
	citizenid   = vehicleData.citizenid,
	citizenname = vehicleData.citizenname,
	livery      = vehicleData.vehicle.livery,
	health      = vehicleData.vehicle.health,
	model       = vehicleData.model,
	location    = {
	    x = vehicleData.vehicle.location.x,
	    y = vehicleData.vehicle.location.y,
	    z = vehicleData.vehicle.location.z + 0.5,
	    w = vehicleData.vehicle.location.w
	}
    })
end

-- Draw 3d text on screen
local function Draw3DText(x, y, z, textInput, fontId, scaleX, scaleY)
    local p     = GetGameplayCamCoords()
    local dist  = #(p - vector3(x, y, z))
    local scale = (1 / dist) * 20
    local fov   = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    SetTextScale(scaleX * scale, scaleY * scale)
    SetTextFont(fontId)
    SetTextProportional(1)
    SetTextColour(250, 250, 250, 255)
    SetTextDropshadow(1, 1, 1, 1, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(textInput)
    SetDrawOrigin(x, y, z + 2, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

function DisplayParkedOwnerText()
    if not HideParkedVehicleNames then -- for performes
	local pl = GetEntityCoords(PlayerPedId())
	local displayWhoOwnesThisCar = nil
	for k, vehicle in pairs(LocalVehicles) do
	    displayWhoOwnesThisCar = CreateParkDisPlay(vehicle)
	    if #(pl - vector3(vehicle.location.x, vehicle.location.y, vehicle.location.z)) < Config.DisplayDistance then
		if PlayerJob == "police" and onDuty == true then
		    Draw3DText(vehicle.location.x, vehicle.location.y, vehicle.location.z - 0.2, displayWhoOwnesThisCar, 0, 0.04, 0.04)
		end
		if PlayerData.citizenid == vehicle.citizenid then
		    Draw3DText(vehicle.location.x, vehicle.location.y, vehicle.location.z - 0.2, displayWhoOwnesThisCar, 0, 0.04, 0.04)
		end
	    end
	end
    end
end

-- Get the stored vehicle player is in
function GetPlayerInStoredCar(player)
    local entity = GetVehiclePedIsIn(player)
    local findVehicle = false
    for i = 1, #LocalVehicles do
	if LocalVehicles[i].entity == entity then
	    findVehicle = LocalVehicles[i]
	    break
	end
    end
    return findVehicle
end

-- Spawn local vehicles(server data)
function SpawnVehicles(vehicles)
    CreateThread(function()
	while IsDeleting do Citizen.Wait(100) end
	if type(vehicles) == 'table' and #vehicles > 0 and vehicles[1] then
	    for i = 1, #vehicles, 1 do
		DeleteLocalVehicle(vehicles[i].vehicle)
		LoadEntity(vehicles[i], 'server')
		Wait(50)
		TableInsert(vehicleEntity, vehicles[i])
                DoAction(action)
		Wait(100)
	    end
	end
    end)
end

-- Spawn single vehicle(client data)
function SpawnVehicle(vehicleData)
    CreateThread(function()
	if LocalPlayer.state.isLoggedIn then
	    while IsDeleting do Wait(100) end
	    DeleteLocalVehicle(vehicleData.vehicle)
	    Wait(500)
	    LoadEntity(vehicleData, 'client')
	    PrepareVehicle(vehicleEntity, vehicleData)
	    Wait(50)
	    FreezeEntityPosition(vehicleEntity, true)
	    if vehicleData.citizenid ~= QBCore.Functions.GetPlayerData().citizenid then
		SetVehicleDoorsLocked(vehicleEntity, 2)
	    end
	    TableInsert(vehicleEntity, vehicleData)
            DoAction(action)
	end
    end)
end

-- remove all Vehicles
function RemoveVehicles(vehicles)
    IsDeleting = true
    if type(vehicles) == 'table' and #vehicles > 0 and vehicles[1] ~= nil then
	for i = 1, #vehicles, 1 do
	    local vehicle, distance = QBCore.Functions.GetClosestVehicle(vehicles[i].vehicle.location)
	    if NetworkGetEntityIsLocal(vehicle) and distance < 1 then
		local driver = GetPedInVehicleSeat(vehicle, -1)
		if not DoesEntityExist(driver) or not IsPedAPlayer(driver) then
		    local tmpModel = GetEntityModel(vehicle)
		    SetModelAsNoLongerNeeded(tmpModel)
		    DeleteEntity(vehicle)
		    Citizen.Wait(300)
		end
	    end
	    -- Clean memory
	    vehicle, distance, driver, tmpModel = nil
	end
    end
    LocalVehicles    = {}
    IsDeleting = false
end

-- Delete single vehicle
function DeleteLocalVehicle(vehicle)
    if type(LocalVehicles) == 'table' and #LocalVehicles > 0 and LocalVehicles[1] ~= nil then
	for i = 1, #LocalVehicles do
	    if vehicle ~= nil then
		if type(vehicle.plate) ~= 'nil' and type(LocalVehicles[i].plate) ~= 'nil' then
		    if vehicle.plate == LocalVehicles[i].plate then
			local tmpModel = GetEntityModel(veh)
			SetModelAsNoLongerNeeded(tmpModel)
			DeleteEntity(LocalVehicles[i].entity)
			table.remove(LocalVehicles, i)
			tmpModel = nil
		    end
		end
	    end
	end
    end
end

-- Just some help text
function DisplayHelpText(text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

-- Load car model
function LoadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
end
