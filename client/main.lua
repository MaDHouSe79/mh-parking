-- [[ ===================================================== ]] --
-- [[               MH Parking V2 by MaDHouSe79             ]] --
-- [[ ===================================================== ]] --
local parkedVehicles = {}
local noParkingBlips = {}
local isUsingParkCommand = false
local isEnteringVehicle = false
local isInVehicle = false
local currentVehicle = nil
local currentSeat = nil
local currentPlate = nil

local display3DText = Config.Display3DText
local saveSteeringAngle = Config.SaveSteeringAngle

local function LoadModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(1)
    end
end

local function LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Wait(1) end
    end
end

local function Draw3DText(x, y, z, textInput, fontId, scaleX, scaleY)
    local p = GetGameplayCamCoords()
    local dist = #(p - vector3(x, y, z))
    local scale = (1 / dist) * 20
    local fov = (1 / GetGameplayCamFov()) * 100
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

local function SetFuel(vehicle, fuel)
	if not DoesEntityExist(vehicle) then return end
	if fuel < 0 then fuel = 0 end
	if fuel > 100 then fuel = 100 end	
	if GetResourceState(Config.FuelScript) ~= 'missing' then
		exports[Config.FuelScript]:SetFuel(vehicle, fuel)
	else
		NetworkRequestControlOfEntity(vehicle)
		Entity(vehicle).state:set('fuel', fuel + 0.0, true)
		SetVehicleFuelLevel(vehicle, fuel + 0.0)
	end
end

local function GetFuel(vehicle)
    if not DoesEntityExist(vehicle) then return end
	if GetResourceState(Config.FuelScript) ~= 'missing' then
    	return exports[Config.FuelScript]:GetFuel(vehicle)
	else
		return Entity(vehicle).state.fuel or -1.0
	end
end

local function GetPedVehicleSeat(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)
    for i = -2, GetVehicleMaxNumberOfPassengers(vehicle) do
        if (GetPedInVehicleSeat(vehicle, i) == ped) then return i end
    end
    return -2
end

local function GetAllPlayersInVehicle(vehicle)
    local pedsincar = {}
    local numPas = GetVehicleModelNumberOfSeats(GetEntityModel(vehicle))
    for i = -1, numPas, 1 do
        if not IsVehicleSeatFree(vehicle, i) then
            local ped = GetPedInVehicleSeat(vehicle, i)
            if IsPedAPlayer(ped) then
                pedsincar[#pedsincar + 1] = {
					playerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped)),
					seat = i
				}
            end
        end
    end
    return pedsincar
end

local function AllPlayersLeaveVehicle(vehicle)
    if DoesEntityExist(vehicle) then
		local players = GetAllPlayersInVehicle(vehicle)
		TriggerServerEvent('mh-parking:server:AllPlayersLeaveVehicle', VehToNet(vehicle), players)
	end
end

local function LeaveVehicle(data)
    local player = GetPlayerServerId(PlayerId())
    if data.playerId == GetPlayerServerId(PlayerId()) then
        local vehicle = NetToVeh(data.vehicleNetID)
        if DoesEntityExist(vehicle) then
            TaskLeaveVehicle(PlayerPedId(), vehicle, 0)
        end
    end    
end

local function BlinkVehiclelights(vehicle, state)
	local ped = PlayerPedId()
	local model = 'prop_cuff_keys_01'
	LoadAnimDict('anim@mp_player_intmenu@key_fob@')
	LoadModel(model)
	local object = CreateObject(model, 0, 0, 0, true, true, true)
	while not DoesEntityExist(object) do Wait(1) end
	AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, 57005), 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
	TaskPlayAnim(ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 8.0, -8.0, -1, 52, 0, false, false, false)
	TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "lock", 0.2)
	SetVehicleLights(vehicle, 2)
	Wait(150)
	SetVehicleLights(vehicle, 0)
	Wait(150)
	SetVehicleLights(vehicle, 2)
	Wait(150)
	SetVehicleLights(vehicle, 0)
	if IsEntityPlayingAnim(ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3) then
		DeleteObject(object)
		StopAnimTask(ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 8.0)
	end
	local doorLockState = GetVehicleDoorLockStatus(vehicle)
	if state == doorLockState then
		TriggerServerEvent('mh-parking:server:setVehLockState', VehToNet(vehicle), state)
		SetVehicleDoorsLocked(vehicle, state)
		if state == 1 then
			Notify("Doords are unlocked","success", 5000)
		else
			Notify("Doords are locked","success", 5000)
		end
	elseif state ~= doorLockState then
		if doorLockState == 1 then
			TriggerServerEvent('mh-parking:server:setVehLockState', VehToNet(vehicle), 2)
			SetVehicleDoorsLocked(vehicle, 2)
			Notify("Doords are locked","success", 5000)
		elseif doorLockState == 2 then
			TriggerServerEvent('mh-parking:server:setVehLockState', VehToNet(vehicle), 1)
			SetVehicleDoorsLocked(vehicle, 1)
			Notify("Doords are unlocked","success", 5000)
		end
	end

end

local function IsCloseByStationPump(coords)
	for hash in pairs(Config.DisableNeedByPumpModels) do
		local pump = GetClosestObjectOfType(coords.x, coords.y, coords.z, 10.0, hash, false, true, true)
		if pump ~= 0 then return true end
	end
	return false
end

local function IsCloseByCoords(coords)
	for k, v in pairs(Config.NoParkingLocations) do
		if GetDistance(coords, v.coords) < v.radius then
			if v.job == nil then
				return true
			elseif v.job ~= nil and v.job ~= PlayerData.job.name then
				return true
			end
		end
	end
	return false
end

local function IsCloseByParkingLot(coords)
	for k, v in pairs(Config.AllowedParkingLots) do
		if GetDistance(coords, v.coords) < v.radius then return true end
	end
	return false
end

local function AllowToPark(coords)
	local isAllowd = false
	if Config.UseParkingLotsOnly then
		if IsCloseByParkingLot(coords) and not IsCloseByStationPump(coords) then isAllowd = true end
	else
		if not IsCloseByCoords(coords) and not IsCloseByStationPump(coords) then isAllowd = true end
	end
	return isAllowd
end

local function CreateParkedBlip(data)
	local name = "unknow"
	local brand = "unknow"
	for k, vehicle in pairs(Config.Vehicles) do
		if vehicle.model == data.model then
			name = vehicle.name 
			brand = vehicle.brand
			break
		end
	end
	local blip = AddBlipForCoord(data.location.x, data.location.y, data.location.z)
	SetBlipSprite(blip, 545)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, 0.6)
	SetBlipAsShortRange(blip, true)
	SetBlipColour(blip, 25)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName(name .. " " .. brand)
	EndTextCommandSetBlipName(blip)
	return blip
end

local function CreateBlipCircle(coords, text, radius, color, sprite)
	local blip = nil
	if Config.UseRadiusForBlips then
		blip = AddBlipForRadius(coords, radius)
		SetBlipHighDetail(blip, true)
		SetBlipColour(blip, color)
		SetBlipAlpha(blip, 128)
	end
	blip = AddBlipForCoord(coords)
	SetBlipHighDetail(blip, true)
	SetBlipSprite(blip, sprite)
	SetBlipScale(blip, 0.7)
	SetBlipColour(blip, color)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandSetBlipName(blip)
	noParkingBlips[#noParkingBlips + 1] = blip
end

local function DeleteAllBlips()
	for k, blip in pairs(noParkingBlips) do
		if DoesBlipExist(blip) then
			RemoveBlip(blip)
			blip = nil
		end
	end
	noParkingBlips = {}
end

local function CreateBlips()
	if Config.UseUnableParkingBlips then
		for k, zone in pairs(Config.NoParkingLocations) do
			if not Config.UseRadiusForBlips then Config.UseRadiusForBlips = true end
			CreateBlipCircle(zone.coords, 'Unable to park', zone.radius, zone.color, zone.sprite)
			Config.UseRadiusForBlips = false
		end
	end
	if Config.UseParkingLotsOnly then
		for k, zone in pairs(Config.AllowedParkingLots) do
			if Config.UseParkingLotsBlips then
				CreateBlipCircle(zone.coords, 'Parking lot', zone.radius, zone.color, zone.sprite)
			end
		end
	end
end

local function GetPlayerInParkedVehicle(ped)
	local findVeh = false
	local entity = GetVehiclePedIsIn(ped, false)
	for i = 1, #parkedVehicles do
		if parkedVehicles[i] ~= nil and parkedVehicles[i].entity ~= nil and parkedVehicles[i].entity == entity then
			findVeh = parkedVehicles[i]
			break
		end
	end
	return findVeh
end

local function SetTable(entity, data)
	if not parkedVehicles[data.plate] then
		local blip = false
		if PlayerData.citizenid == data.owner then blip = CreateParkedBlip(data) end		
		parkedVehicles[data.plate] = {
			fullname = data.fullname,
			owner = data.owner, 
			netid = data.netid,
			entity = entity,
			mods = data.mods,
			hash = data.hash,
			plate = data.plate, 
			model = data.model,
			fuel = data.fuel,
			body = data.body,
			engine = data.engine,
			steerangle = data.steerangle,
			location = data.location,
			blip = blip,
			isParked = true,
		}
	end
end

local function SetVehicleWaypoit(coords)
	local playerCoords = GetEntityCoords(PlayerPedId())
	local distance = GetDistance(playerCoords, coords)
	if distance < 200 then
		Notify(Lang:t('info.no_waipoint', { distance = Round(distance, 2) }), "error", 5000)
	elseif distance > 200 then
		SetNewWaypoint(coords.x, coords.y)
	end
end

local function GetVehicleMenu()
	TriggerCallback("mh-parking:server:GetVehicles", function(result)
		if result.status then
			if #result.data >= 1 then
				local options = {}
				for k, v in pairs(result.data) do
					if v.state == 3 then
						local coords = json.decode(v.location)
						options[#options + 1] = {
							title = FirstToUpper(v.vehicle) .. " " .. v.plate .. " is parked",
							description = Lang:t('info.steet', {steet = v.steet}) .. '\n'.. Lang:t('info.fuel', {fuel = v.fuel}) .. '\n'.. Lang:t('info.engine', {engine = v.engine}) .. '\n'.. Lang:t('info.body', {body = v.body}) .. '\n'..Lang:t('info.click_to_set_waypoint'),
							arrow = false,
							onSelect = function()
								SetVehicleWaypoit(coords)
							end
						}
					end
				end
				options[#options + 1] = {title = Lang:t('info.close'), icon = "fa-solid fa-stop", description = '', arrow = false, onSelect = function() end}
				lib.registerContext({id = 'parkMenu', title = "MH Parking V2", icon = "fa-solid fa-warehouse", options = options})
				lib.showContext('parkMenu')
			else
				Notify(Lang:t('info.no_vehicles_parked'), "error", 5000)
			end
		end
	end)
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        PlayerData = {}
        isLoggedIn = false
		parkedVehicles = {}
		DeleteAllBlips()
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
		PlayerData = GetPlayerData()
        TriggerServerEvent('mh-parking:server:OnJoin')
    end
end)

if Config.Framework ~= 'qb' and Config.Framework ~= 'esx' and Config.Framework ~= 'qbx' then 
	AddEventHandler('playerSpawned', function()
		TriggerServerEvent('mh-parking:server:OnJoin')
	end)
elseif Config.Framework == 'qb' or Config.Framework == 'esx' or Config.Framework == 'qbx' then 
	RegisterNetEvent(OnPlayerLoaded)
	AddEventHandler(OnPlayerLoaded, function()
		PlayerData = GetPlayerData()
		TriggerServerEvent('mh-parking:server:OnJoin')	
	end)

	RegisterNetEvent(OnPlayerUnload)
	AddEventHandler(OnPlayerUnload, function()
		PlayerData = {}
		isLoggedIn = false
	end)
end

RegisterNetEvent('mh-parking:client:AddVehicle')
AddEventHandler('mh-parking:client:AddVehicle', function(result)
	local vehicle = NetToVeh(result.data.netid)
	if DoesEntityExist(vehicle) then 
		SetTable(vehicle, result.data)
		BlinkVehiclelights(vehicle, 2)
		FreezeEntityPosition(vehicle, true)
	end
end)

RegisterNetEvent('mh-parking:client:RemoveVehicle', function(data)
	local vehicle = NetToVeh(data.netid)
	if parkedVehicles[data.plate] and parkedVehicles[data.plate].netid == data.netid then
		if DoesBlipExist(parkedVehicles[data.plate].blip) then RemoveBlip(parkedVehicles[data.plate].blip) end
		if PlayerData.citizenid == parkedVehicles[data.plate].owner then
			BlinkVehiclelights(vehicle, 1)
			FreezeEntityPosition(vehicle, false)
			parkedVehicles[data.plate].isParked = false 
		end
		parkedVehicles[data.plate] = nil
	end
end)

RegisterNetEvent('mh-parking:client:Onjoin')
AddEventHandler('mh-parking:client:Onjoin', function(data)
    isLoggedIn = true
	display3DText = Config.Display3DText
	saveSteeringAngle = Config.SaveSteeringAngle
	CreateBlips()
	if data.status == true then
		local vehicles = data.vehicles
		for k, v in pairs(vehicles) do
			local vehicle = NetToVeh(v.netid)
			if DoesEntityExist(vehicle) then
				SetEntityAsMissionEntity(vehicle, true, true)
				SetVehicleKeepEngineOnWhenAbandoned(vehicle, Config.keepEngineOnWhenAbandoned)
				RequestCollisionAtCoord(v.location.x, v.location.y, v.location.z)
				SetVehicleOnGroundProperly(vehicle)
				SetVehicleProperties(vehicle, v.mods)
				SetVehicleSteeringAngle(vehicle, v.steerangle + 0.0)
				DoVehicleDamage(vehicle, v.body, v.engine)
				SetFuel(vehicle, v.fuel + 0.0)
				SetTable(vehicle, v)
				if Config.Framework == 'qb' or Config.Framework == 'esx' or Config.Framework == 'qbx' then
					if PlayerData ~= nil then
						if v.owner ~= PlayerData.citizenid then -- if not owner vehicle
							TriggerServerEvent('mh-parking:server:setVehLockState', v.netid, 2)
							SetVehicleDoorsLocked(vehicle, 2)
							FreezeEntityPosition(vehicle, true)
						elseif v.owner == PlayerData.citizenid then -- if owner vehicle
							NetworkRequestControlOfEntity(vehicle)
							SetClientVehicleOwnerKey(v.plate, vehicle)
							Notify("Je hebt de sleutels gekregen...", "suscess", 5000)
							TriggerServerEvent('mh-parking:server:setVehLockState', v.netid, 1)
							SetVehicleDoorsLocked(vehicle, 1)
							FreezeEntityPosition(vehicle, false)
						end						
					end
				end
			end
		end
	end
end)

RegisterNetEvent('mh-parking:client:leaveVehicle', function(data) 
	LeaveVehicle(data) 
end)

RegisterNetEvent('mh-parking:client:toggleParkText', function(data)
	display3DText = not display3DText
	local txt
	if display3DText then txt = "enable" else txt = "disable" end
	Notify("3D text is now "..txt, "sucess", 5000)
end)

RegisterNetEvent('mh-parking:client:toggleSteerAngle', function(data)
	saveSteeringAngle = not saveSteeringAngle
	local txt
	if saveSteeringAngle then txt = "enable" else txt = "disable" end
	Notify("Save steering angle is now "..txt, "sucess", 5000)
end)

RegisterNetEvent('mh-parking:client:OpenParkMenu', function(data)
	if data.status then
		GetVehicleMenu()
	end
end)

-- Display 3D text
CreateThread(function()
	while true do
		Wait(0)
		if isLoggedIn and display3DText then
			local playerCoords = GetEntityCoords(GetPlayerPed(-1))
			local txt = ""
			for k, data in pairs(parkedVehicles) do
				if data ~= nil and data.isParked then
					local vehicle = NetToVeh(data.netid)
					if DoesEntityExist(vehicle) then
						local entityCoords = GetEntityCoords(vehicle)
						local distance = GetDistance(playerCoords, entityCoords)
						if distance < Config.DisplayDistance then
							local owner, plate, model, brand = data.fullname, data.plate, nil, nil
							for k, vehicle in pairs(Config.Vehicles) do
								if vehicle.model == data.model then
									model, brand = vehicle.name, vehicle.brand
									break
								end
							end
							if model ~= nil and brand ~= nil then
								txt = "Model: ~b~"..model.."~s~".. '\n' .. "Brand: ~o~"..brand.."~s~".. '\n' .. "Plate: ~g~"..plate.."~s~".. '\n' .. "Owner: ~y~"..owner.."~s~"
								if Config.DisplayToAllPlayers then
									Draw3DText(entityCoords.x, entityCoords.y, entityCoords.z, txt, 0, 0.04, 0.04)
								else
									if PlayerData.citizenid == data.owner then
										Draw3DText(entityCoords.x, entityCoords.y, entityCoords.z, txt, 0, 0.04, 0.04)
									end
								end
							end
						end
					end
				end
			end
		end
	end
end)

-- Set vehicle steering angle
CreateThread(function()
	local angle = 0.0
	local speed = 0.0
	while true do
		Wait(0)
		if isLoggedIn and saveSteeringAngle then
			local veh = GetVehiclePedIsUsing(PlayerPedId())
			if DoesEntityExist(veh) then
				local tangle = GetVehicleSteeringAngle(veh)
				if tangle > 10.0 or tangle < -10.0 then angle = tangle end
				speed = GetEntitySpeed(veh)
				local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
				if speed < 0.1 and DoesEntityExist(vehicle) and not GetIsTaskActive(PlayerPedId(), 151) and not GetIsVehicleEngineRunning(vehicle) then
					SetVehicleSteeringAngle(vehicle, angle)
				end
			end
		end
	end
end)

-- Keep engine running
CreateThread(function() 
	while true do 
		Wait(0) 
		if isLoggedIn then
			if IsPedInAnyVehicle(PlayerPedId(), false) and IsControlPressed(2, 75) and not IsEntityDead(PlayerPedId()) then
				SetVehicleEngineOn(GetVehiclePedIsIn(PlayerPedId(), false), true, true, true)
			end
		end
	end
end)

-- Automatic park logic
CreateThread(function()
	while true do 
		local sleep = 1000 
		if isLoggedIn then
			local ped = PlayerPedId()
			if not isInVehicle and not IsPlayerDead(PlayerId()) then
				if DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not isEnteringVehicle then
					currentVehicle = GetVehiclePedIsTryingToEnter(ped)
					currentSeat = GetSeatPedIsTryingToEnter(ped)
					isEnteringVehicle = true
					currentPlate = GetPlate(currentVehicle)
					local netid = VehToNet(currentVehicle)
					if not IsDead() and not InLaststand() then
						TriggerServerEvent('mh-parking:server:EnteringVehicle', netid, currentSeat, currentPlate)
					end
				elseif not DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not IsPedInAnyVehicle(ped, true) and isEnteringVehicle then
					isEnteringVehicle = false
				elseif IsPedInAnyVehicle(ped, false) then
					isEnteringVehicle = false
					isInVehicle = true
					currentVehicle = GetVehiclePedIsUsing(ped)
					currentSeat = GetPedVehicleSeat(ped)
					currentPlate = GetPlate(currentVehicle)
					local netid = VehToNet(currentVehicle)
					if not IsDead() and not InLaststand() then
						TriggerServerEvent('mh-parking:server:EnteredVehicle', netid, currentSeat, currentPlate)
						SetEntityVisible(ped, true)
					end
				end
			elseif isInVehicle then
				if not IsPedInAnyVehicle(ped, false) and not IsDead() and not InLaststand() then
					local vehicle = GetVehiclePedIsIn(ped, true)
					local plate = GetPlate(vehicle)
					local netid = VehToNet(vehicle)
					local steerangle = GetVehicleSteeringAngle(vehicle) + 0.0
					local coords = GetEntityCoords(vehicle)
					local heading = GetEntityHeading(vehicle)
					local plate  = GetPlate(vehicle)
					local street = GetStreetName(vehicle)
					local location = { x = coords.x, y = coords.y, z = coords.z, h = heading }
					local canSave = true
					if AllowToPark(coords) then
						if Config.OnlyAutoParkWhenEngineIsOff then
							local engineIsOn = GetIsVehicleEngineRunning(vehicle)
							if engineIsOn then canSave = false end
						end
					else
						canSave = false
					end
					if canSave then
						AllPlayersLeaveVehicle(vehicle)
						Wait(2000)
						TriggerServerEvent('mh-parking:server:LeftVehicle', netid, currentSeat, plate, location, steerangle, street)
					end
					isEnteringVehicle = false
					isInVehicle = false
					currentVehicle = 0
					currentSeat = 0
				elseif not IsPedInAnyVehicle(ped, false) and IsDead() or InLaststand() then
					isEnteringVehicle = false
					isInVehicle = false
					currentVehicle = 0
					currentSeat = 0
				end
			end
			sleep = 50
		end
		Wait(sleep)
	end
end)

-- Disable Parked Vehicles Collision
CreateThread(function()
	while true do
		Wait(0)
		if isLoggedIn and Config.DisableParkedVehiclesCollision then
			local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
			if vehicle ~= nil and vehicle ~= 0 then
				for k, v in pairs(parkedVehicles) do
					local distance = GetDistance(GetEntityCoords(PlayerPedId()), v.location)
					if distance < 10 then
						SetEntityNoCollisionEntity(v.entity, vehicle, true)
                        SetEntityNoCollisionEntity(vehicle, v.entity, true)
					end
				end
			end
		end
	end

end)
