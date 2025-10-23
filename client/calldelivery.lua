local menu = nil

local function CreateEntityBlip(entity)
    local blip = GetBlipFromEntity(entity)
    if not DoesBlipExist(blip) then
        blip = AddBlipForEntity(entity)
        SetBlipSprite(blip, 161)
        SetBlipScale(blip, 1.0)
        SetBlipColour(blip, 0)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString("Driver")
        EndTextCommandSetBlipName(blip)
    end
    if GetBlipFromEntity(PlayerPedId()) == blip then RemoveBlip(blip) end
    return blip
end

local function SpawnDriver(coords, vehicle)
	local model = "mp_m_freemode_01"
    local weapon = Config.Weapons[math.random(1, #Config.Weapons)]
	LoadModel(model)
	local entity = CreatePed(4, model, coords.x, coords.y, coords.z, 0, true, true)
	while not DoesEntityExist(entity) do Wait(1) end
	SetEntityAsMissionEntity(entity, true, true)
	SetModelAsNoLongerNeeded(model)
	SetPedOutfit(entity)
    SetPedIntoVehicle(entity, vehicle, -1)
    GiveWeaponToPed(entity, weapon, 999, false, true)
    SetPedInfiniteAmmo(entity, true, GetHashKey(weapon))
    SetEntityHealth(entity, 250)
    SetPedArmour(entity, 100)
    SetPedAsCop(entity, true)
    SetPedKeepTask(entity, true)
    SetPedAccuracy(entity, 50)
    SetPedDropsWeaponsWhenDead(entity, false)
    SetCanAttackFriendly(entity, false, true)
    SetPedCanSwitchWeapon(entity, true)
    SetPedCombatAbility(entity, 100)
    SetPedCombatMovement(entity, 3)
    SetPedCombatRange(entity, 2)
    SetPedCombatAttributes(entity, 46, true)
    SetPedSeeingRange(entity, 150.0)
    SetPedHearingRange(entity, 150.0)
    SetPedAlertness(entity, 3)
	SetPedKeepTask(entity, true)
	return entity
end

local function SpawnVeh(model, plate, coords, heading)
	LoadModel(model)
	ClearAreaOfVehicles(coords.x, coords.y, coords.z, 10000, false, false, false, false, false)
    local entity = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, true)
	while not DoesEntityExist(entity) do Wait(1) end
    SetModelAsNoLongerNeeded(model)
	SetEntityAsMissionEntity(entity, true, true)
	SetVehicleNumberPlateText(entity, plate)
	RequestCollisionAtCoord(coords.x, coords.y, coords.z)
	SetVehicleOnGroundProperly(entity)
    SetVehicleBodyHealth(entity, 1000.0)
    SetVehicleEngineHealth(entity, 1000.0)
    SetVehicleFuelLevel(entity, 100.0)
	SetVehRadioStation(entity, 'OFF')
	SetVehicleDirtLevel(entity, 0)
	return entity
end

local function CallVehicleDelivery(data)
	local spawnCoords = GetEntityCoords(PlayerPedId())
	local retval, coords, heading = GetClosestVehicleNodeWithHeading(spawnCoords.x + math.random(-350, 350), spawnCoords.y + math.random(-350, 350), spawnCoords.z, 0, 3, 0)
	local vehicle = SpawnVeh(data.model, data.plate, coords, heading)
	local driver = SpawnDriver(coords, vehicle)

	if DoesEntityExist(vehicle) and DoesEntityExist(driver) then
		local garageBlip = CreateEntityBlip(vehicle)
		local isDriving = true

		-- Drive to player
		while isDriving do
			local playerCoords = GetEntityCoords(PlayerPedId())
			local driverCoords = GetEntityCoords(driver)
			if GetDistance(driverCoords, playerCoords) < 10.0 then isDriving = false end
			TaskVehicleDriveToCoord(driver, vehicle, playerCoords.x, playerCoords.y, playerCoords.z, 100.0, 1.0, GetEntityModel(vehicle), 786603, 1.0, true)
			Wait(100)
		end

		-- Get out vehicle
		RemoveBlip(garageBlip)
		SetVehicleEngineOn(vehicle, false, false, true)
		TaskLeaveVehicle(driver, vehicle, 0)
		Wait(2000)

		-- Walk to player
		local isWalking = true
		while isWalking do
			if GetDistance(GetEntityCoords(driver), GetEntityCoords(PlayerPedId())) < 1.5 then isWalking = false end
			TaskGoToCoordAnyMeans(driver, GetEntityCoords(PlayerPedId()), 2.0, 0, 0, 786603, 0xbf800000)
			Wait(100)
		end

		GiveTakeAnimation(driver, PlayerPedId())
		Wait(10)
		TriggerEvent('vehiclekeys:client:SetOwner', GetPlate(vehicle))

		-- Job done
		TaskWanderStandard(driver, 10.0, 10)
		Wait(60000)
		DeleteEntity(driver)
		isDriving = false
		isWalking = false
		garageBlip = nil
		driver = nil
		vehicle = nil
	end
end

local function GetVehicleMenu()
	TriggerCallback("mh-parking:server:GetVehicles", function(result)
		if #result.data >= 1 then
			local vehicles = result.data
			if Config.MenuScript == "ox_lib" then
				local options = {}
				local num = 1
				for k, v in pairs(vehicles) do
					local description = Lang:t('vehicle.plate', {plate = v.plate}) .. '\n' .. Lang:t('vehicle.fuel', {fuel = v.fuel}) .. '\n' .. Lang:t('vehicle.engine', {engine = Round(v.engine / 10, 0)}) .. '\n' .. Lang:t('vehicle.body', {body = Round(v.body / 10, 0)})
					local txt = "unknow"
					options[#options + 1] = {
						id = num,
						title = Config.Vehicles[GetHashKey(v.vehicle)].name.." "..Config.Vehicles[GetHashKey(v.vehicle)].brand,
						icon = "nui://mh-parking/images/" .. v.vehicle:lower() .. ".png",
						description = description,
						arrow = false,
						onSelect = function()
							TriggerEvent('mh-parking:client:CallVehicleDelivery', {model = v.vehicle:lower(), plate = v.plate})
						end
					}
					num = num + 1
				end
				options[#options + 1] = {id = num,title = Lang:t('info.close'), icon = "fa-solid fa-stop", description = '', arrow = false, onSelect = function() end}
				table.sort(options, function(a, b) return a.id < b.id end)
				lib.registerContext({id = 'menu', title = "Call Vehicle Delivery", icon = "fa-solid fa-car", options = options})
				lib.showContext('menu')
			elseif Config.MenuScript == "qb-menu" then
				local options = {{header = "Call Vehicle Delivery", isMenuHeader = true}}
				for k, v in pairs(vehicles) do
					local description = Lang:t('vehicle.model', {model = Config.Vehicles[GetHashKey(v.vehicle:lower())].name}) .. "<br />" .. Lang:t('vehicle.brand', {brand = Config.Vehicles[GetHashKey(v.vehicle:lower())].brand}) .. "<br />" .. Lang:t('vehicle.plate', {plate = v.plate}) .. '<br />' .. Lang:t('vehicle.fuel', {fuel = v.fuel}) .. '<br />' .. Lang:t('vehicle.engine', {engine = Round(v.engine / 10, 0)}) .. '<br />' .. Lang:t('vehicle.body', {body = Round(v.body / 10, 0)})
					if v.state == 1 then 
						options[#options + 1] = {
							header = "", 
							txt = '<table><td style="text-align:left; height: 50px; padding: 5px;"><img src='.."nui://mh-parking/images/" .. v.vehicle:lower() .. ".png"..' style="width:80px;"></td><td style="text-align:top; height: 50px; padding: 15px;">'..description..'</td></table>', 
							params = {event = 'mh-parking:client:CallVehicleDelivery', 
								args = {model = v.vehicle:lower(), plate = v.plate}
							}
						} 
					end
				end
				options[#options + 1] = {header = Lang:t('info.close'), txt = '', params = {event = 'qb-menu:client:closeMenu'}}
				exports['qb-menu']:openMenu(options)
			end
        end
    end)
end

RegisterNetEvent('mh-parking:client:CallVehicleDelivery', function(data)
    CallVehicleDelivery(data)
end)

RegisterNetEvent('mh-parking:client:GetVehiclesMenu', function()
    GetVehicleMenu()
end)

if GetResourceState("qb-core") ~= 'missing' then
    RegisterNetEvent('qb-radialmenu:client:onRadialmenuOpen', function()
        if menu ~= nil then exports['qb-radialmenu']:RemoveOption(menu) menu = nil end
        menu = exports['qb-radialmenu']:AddOption({id = 'CallVehicleDelivery_menu', title = "Call Delivery", icon = "info", type = 'client', event = "mh-parking:client:GetVehiclesMenu", shouldClose = true}, menu)
    end)
elseif GetResourceState("es_extended") ~= 'missing' then
    lib.addRadialItem({{id = 'CallVehicleDelivery_menu', label = "Call Delivery", icon = 'info', onSelect = function() TriggerEvent("mh-parking:client:GetVehiclesMenu") end }})
end