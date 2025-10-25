-- [[ ===================================================== ]] --
-- [[              MH Park System by MaDHouSe79             ]] --
-- [[ ===================================================== ]] --
local parkedVehicles = {}
local noParkingBlips = {}
local plateExsist = {}
local zones = {}
local hasspaned = false
local IsUsingParkCommand = false
local isEnteringVehicle = false
local isInVehicle = false
local inparkzone = false
local currentVehicle = nil
local currentSeat = nil
local currentPlate = nil
local parkLabel = nil
local parkCoords = nil
local parkOwner = nil
local parkZoneId = nil
local useDebugPoly = Config.UseDebugPoly
local display3DText = Config.Display3DText
local saveSteeringAngle = Config.SaveSteeringAngle
local disableParkedVehiclesCollision = Config.DisableParkedVehiclesCollision

local disableNeedByPumpModels = {
    ['prop_vintage_pump'] = true,
    ['prop_gas_pump_1a'] = true,
    ['prop_gas_pump_1b'] = true,
    ['prop_gas_pump_1c'] = true,
    ['prop_gas_pump_1d'] = true,
    ['prop_gas_pump_old2'] = true,
    ['prop_gas_pump_old3'] = true
}

local function DeleteZones()
	for k, zone in pairs(zones) do
		if zone ~= nil then
			zone:destroy()
		end
	end	
end

local function LoadZone()
	zones = {}
	for i = 1, #Config.PrivedParking, 1 do
		local v = Config.PrivedParking[i]
        zones[#zones + 1] = BoxZone:Create(vector3(v.coords.x, v.coords.y, v.coords.z), v.size.length, v.size.width, {
			name = "park_boxzone_"..v.id,
			id = v.id,
			offset = {0.0, 0.0, 0.0},
			scale = {v.size.width, v.size.width, v.size.width},
			heading = v.coords.w,
			debugPoly = useDebugPoly,
		})
    end	
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

local function BlinkVehiclelights(vehicle)
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
		StopAnimTask(ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 8.0)
		DeleteObject(object)
	end
	Wait(100)
	DeleteObject(object)
end

local function IsCloseByPrivedParkingCoords(coords)
	for k, v in pairs(Config.PrivedParking) do
		if v.citizenid ~= PlayerData.citizenid then
			local distance = GetDistance(coords, v.coords)
			if (distance < v.size.width) or (distance < v.size.length) then return true end
		end		
	end
	return false
end

local function IsCloseByStationPump(coords)
	for hash in pairs(disableNeedByPumpModels) do
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
	local allow = true
	if IsCloseByStationPump(coords) then
		allow = false
	else
		if IsCloseByCoords(coords) then
			allow = false
		else
			if Config.UseParkingLotsOnly then
				if not IsCloseByParkingLot(coords) then
					if Config.UsePrivedParking then
						if IsCloseByPrivedParkingCoords(coords) then
							allow = false
						end
					else
						allow = false
					end
				end
			else
				if Config.UsePrivedParking then
					if IsCloseByPrivedParkingCoords(coords) then
						allow = false
					end
				else
					allow = false
				end
			end
		end
	end
	return allow
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

local function SetTable(entity, data)
	if parkedVehicles[data.plate] then 
		if parkedVehicles[data.plate].blip ~= nil then
			if DoesBlipExist(parkedVehicles[data.plate].blip) then
				RemoveBlip(parkedVehicles[data.plate].blip)
				parkedVehicles[data.plate].blip = nil
			end
		end
	end
	parkedVehicles[data.plate] = nil
	local blip = false
	if data.owner == PlayerData.citizenid then blip = CreateParkedBlip(data) end
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
	}
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
			if result.data ~= nil then
				local num = 0
				local options = {}
				for k, v in pairs(result.data) do
					if v.state == 3 then
						num = num + 1
						local coords = json.decode(v.location)
						options[#options + 1] = {
							id = num,
							title = FirstToUpper(v.vehicle) .. " " .. v.plate .. " is parked",
							description = Lang:t('info.steet', {steet = v.steet}) .. '\n'.. Lang:t('info.fuel', {fuel = v.fuel}) .. '\n'.. Lang:t('info.engine', {engine = v.engine}) .. '\n'.. Lang:t('info.body', {body = v.body}) .. '\n'..Lang:t('info.click_to_set_waypoint'),
							arrow = false,
							onSelect = function()
								SetVehicleWaypoit(coords)
							end
						}
					end
				end
				num = num + 1
				options[#options + 1] = {
					id = num,
					title = Lang:t('info.close'), 
					icon = "fa-solid fa-stop", 
					description = '', 
					arrow = false, 
					onSelect = function() 
					end
				}
				lib.registerContext({id = 'parkMenu', title = "MH Parking V2", icon = "fa-solid fa-warehouse", options = options})
				lib.showContext('parkMenu')
			else
				Notify(Lang:t('info.no_vehicles_parked'), "error", 5000)
			end
		end
	end)
end

local function GetPlayerInParkedVehicle(vehicle)
	local findVeh = false
	if DoesEntityExist(vehicle) then
		local plate = GetPlate(vehicle)
		local netid = VehToNet(vehicle)
		if parkedVehicles[plate] ~= nil then
			if parkedVehicles[plate].netid == netid then
				findVeh = parkedVehicles[plate]
			end
		end
	end
	return findVeh
end

local function isVehicleAllowedToPark(vehicle)
	local access = false
	if IsThisModelACar(GetEntityModel(vehicle)) or 
		IsThisModelABike(GetEntityModel(vehicle)) or 
		IsThisModelABicycle(GetEntityModel(vehicle)) or 
		IsThisModelAPlane(GetEntityModel(vehicle)) or 
		IsThisModelABoat(GetEntityModel(vehicle)) or 
		IsThisModelAHeli(GetEntityModel(vehicle)) then
		access = true
	end
	return access
end

local function DoorsLocked(netid)
	local vehicle = NetToVeh(netid)
	local doorLockState = GetVehicleDoorLockStatus(vehicle)
	if doorLockState == 1 then
		TriggerServerEvent('mh-parking:server:setVehLockState', netid, 2)
		SetVehicleDoorsLocked(vehicle, 2)
	elseif doorLockState == 2 then
		TriggerServerEvent('mh-parking:server:setVehLockState', netid, 2)
		SetVehicleDoorsLocked(vehicle, 2)
	end
end

local function DoorsUnocked(netid)
	local vehicle = NetToVeh(netid)
	local doorLockState = GetVehicleDoorLockStatus(vehicle)
	if doorLockState == 1 then
		TriggerServerEvent('mh-parking:server:setVehLockState', netid, 1)
		SetVehicleDoorsLocked(vehicle, 1)
	elseif doorLockState == 2 then
		TriggerServerEvent('mh-parking:server:setVehLockState', netid, 1)
		SetVehicleDoorsLocked(vehicle, 1)
	end
end

RegisterKeyMapping('park', 'Park or Drive', 'keyboard', Config.KeyParkBindButton)
RegisterCommand('park', function() IsUsingParkCommand = true end, false)

RegisterNetEvent('mh-parking:client:CreatePark')
AddEventHandler('mh-parking:client:CreatePark', function(data)
	TriggerCallback('mh-parking:server:IsAdmin', function(result)
		if result.status and result.isadmin then
			if data.id ~= nil and data.name ~= nil and data.label ~= nil then
				local data = {
					id = data.id, 
					name = data.name, 
					job = data.job, 
					label = data.label, 
					coords = GetEntityCoords(PlayerPedId()), 
					heading = GetEntityHeading(PlayerPedId()),
				}
				TriggerServerEvent('mh-parking:server:CreatePark', data)			
			end
		end
	end)
end)

RegisterNetEvent('mh-parking:client:DeletePark', function(args)
	TriggerCallback('mh-parking:server:IsAdmin', function(result)
		if result.status and result.isadmin then
			local id = nil
			local filename = nil
			if parkZoneId ~= nil then
				if args[1] ~= nil then id = tonumber(args[1]) end
				if args[2] ~= nil then filename = tostring(args[2]) end
				TriggerServerEvent('mh-parking:server:DeletePark', {id = id, filename = filename, zoneid = parkZoneId})			
			end
		end
	end)	
end)

RegisterNetEvent('mh-parking:client:reloadZone', function(input)
	DeleteZones()
	Wait(100)
	if not input.state then
		Config.PrivedParking[input.zoneid] = nil
		inparkzone = false
	elseif input.state then
		Config.PrivedParking[input.zoneid] = {
			id = input.zoneid,
			citizenid = input.data.citizenid,
			label = input.data.label,
			name = input.data.name,
			coords = vector4(input.data.coords.x, input.data.coords.y, input.data.coords.z, input.data.coords.w),
			size = { width = 1.5, length = 4.0 },
			job = input.data.job,
		}
	end
	LoadZone()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        PlayerData = {}
        isLoggedIn = false
		hasspaned = false
		DeleteAllBlips()
		parkedVehicles = {}
		plateExsist = {}
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
		PlayerData = GetPlayerData()
		display3DText = Config.Display3DText
		aveSteeringAngle = Config.SaveSteeringAngle
		disableParkedVehiclesCollision = Config.DisableParkedVehiclesCollision
		TriggerServerEvent('mh-parking:server:OnJoin')
	end
end)

RegisterNetEvent(OnPlayerLoaded)
AddEventHandler(OnPlayerLoaded, function()
	PlayerData = GetPlayerData()
	TriggerServerEvent('mh-parking:server:OnJoin')	
end)

RegisterNetEvent(OnPlayerUnload)
AddEventHandler(OnPlayerUnload, function()
	PlayerData = {}
    isLoggedIn = false
	hasspaned = false
	DeleteAllBlips()
	parkedVehicles = {}
	plateExsist = {}
end)

RegisterNetEvent('mh-parking:client:AddVehicle')
AddEventHandler('mh-parking:client:AddVehicle', function(result)
	local vehicle = NetToVeh(result.data.netid)
	if DoesEntityExist(vehicle) then
		DoorsLocked(result.data.netid)
		SetTable(vehicle, result.data)
		if result.data.owner == PlayerData.citizenid then
			BlinkVehiclelights(vehicle)
			--Notify("Vehicle add to parked state", "success", 5000)
		end
		FreezeEntityPosition(vehicle, true)
	end
end)

RegisterNetEvent('mh-parking:client:RemoveVehicle', function(data)
	local vehicle = NetToVeh(data.netid)
	if parkedVehicles[data.plate] and parkedVehicles[data.plate].netid == data.netid then
		if parkedVehicles[data.plate].owner == PlayerData.citizenid then
			if parkedVehicles[data.plate].blip ~= false then
				if DoesBlipExist(parkedVehicles[data.plate].blip) then
					RemoveBlip(parkedVehicles[data.plate].blip)
				end
			end
			--Notify("Vehicle remved from park state...", "success", 5000)
			DoorsUnocked(data.netid)
			BlinkVehiclelights(vehicle)
			FreezeEntityPosition(vehicle, false)
			if not Config.UseAutoPark then
				SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
			end
		end
		parkedVehicles[data.plate] = nil
	end
end)

RegisterNetEvent('mh-parking:client:Onjoin')
AddEventHandler('mh-parking:client:Onjoin', function(result)
	isLoggedIn = true
	if hasspaned then return end
	hasspaned = true
	LoadZone()
	CreateBlips()
	TriggerCallback('mh-parking:server:GetParkedVehicles', function(vehicles)
		for _, v in pairs(vehicles) do
			if not parkedVehicles[v.plate] then
				local vehicle = NetToVeh(v.netid)
				if DoesEntityExist(vehicle) then					
					SetEntityAsMissionEntity(vehicle, true, true)
					SetVehicleProperties(vehicle, v.mods)
					RequestCollisionAtCoord(v.location.x, v.location.y, v.location.z)
					SetVehicleOnGroundProperly(vehicle)
					SetVehicleLivery(vehicle, v.mods.livery)
					SetVehicleNumberPlateText(vehicle, v.plate)
					if Config.SaveSteeringAngle then
						SetVehicleSteeringAngle(vehicle, v.steerangle + 0.0)
					end
					DoVehicleDamage(vehicle, v.body, v.engine)
					SetFuel(vehicle, v.fuel + 0.0)
					SetVehicleKeepEngineOnWhenAbandoned(vehicle, Config.keepEngineOnWhenAbandoned)
					FreezeEntityPosition(vehicle, true)
					SetTable(vehicle, v)	
					if Config.Framework == 'qb' or Config.Framework == 'esx' or Config.Framework == 'qbx' then
						if PlayerData ~= nil then
							if v.owner ~= PlayerData.citizenid then -- if not owner vehicle
								DoorsLocked(v.netid)
							elseif v.owner == PlayerData.citizenid then -- if owner vehicle
								NetworkRequestControlOfEntity(vehicle)
								SetClientVehicleOwnerKey(v.plate, vehicle)
								DoorsUnocked(v.netid)				
							end
						end
					end
					Wait(500)
				end
			end	
		end
	end)
end)

RegisterNetEvent('mh-parking:client:leaveVehicle', function(data) 
	LeaveVehicle(data) 
end)

RegisterNetEvent('mh-parking:client:OpenParkMenu', function(data)
	if data.status then
		GetVehicleMenu()
	end
end)

RegisterNetEvent('mh-parking:client:toggleParkText', function()
	display3DText = not display3DText
	local txt = nil
	if display3DText then txt = "enable" else txt = "disable" end
	--Notify("Parked vehicle text is now "..txt, "success", 5000)
end)

RegisterNetEvent('mh-parking:client:toggleSteerAngle', function()
	saveSteeringAngle = not saveSteeringAngle
	local txt = nil
	if saveSteeringAngle then txt = "enable" else txt = "disable" end
	--Notify("Steer angle save is now "..txt, "success", 5000)
end)

RegisterNetEvent('mh-parking:client:toggleDebugPoly', function()
	TriggerCallback('mh-parking:server:IsAdmin', function(result)
		if result.status and result.isadmin then
			local vehicle
			for k, v in pairs(parkedVehicles) do
				if v.netid ~= nil then
					local vehicle = NetToVeh(v.netid)
					while not DoesEntityExist(vehicle) do
						Wait(0)
					end
				end
			end
			useDebugPoly = not useDebugPoly
			local txt = nil
			if useDebugPoly then txt = "enable" else txt = "disable" end
			--Notify("Debug poly is now "..txt, "success", 5000)
			for k, zone in pairs(zones) do
				if zone ~= nil then
					zone:destroy()
				end
			end
			LoadZone()
		end
	end)
end)

local menu = nil
if Config.RadialMenuScript == "qb-radialmenu" then
	RegisterNetEvent('qb-radialmenu:client:onRadialmenuOpen', function()
		if menu ~= nil then
			exports['qb-radialmenu']:RemoveOption(menu)
			menu = nil
		end
		menu = exports['qb-radialmenu']:AddOption({
			id = 'park_vehicle',
			title = 'Park Menu',
			icon = "square-parking",
			type = 'client',
			event = "mh-parking:client:OpenParkMenu",
			shouldClose = true
		}, menu)
	end)
elseif Config.RadialMenuScript == "ox_lib" then
	-- to do
end

CreateThread(function()
	while true do 
		local sleep = 1000
		for k, zone in pairs(zones) do
			zone:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside, point)
				if Config.PrivedParking[k] then
					local data = Config.PrivedParking[k]
					if isPointInside then
						if Config.UsePrivedParking and not inparkzone then
							inparkzone = true
							parkZoneId = data.id
							parkOwner = data.citizenid
							parkCoords = data.coords
							parkLabel = "~w~Zone ID: ~b~"..data.id.."\n~b~"..data.label.. "~w~\n Owner: ~g~"..data.name.."~w~"
						end
					else
						if Config.UsePrivedParking and inparkzone then
							inparkzone = false
							parkZoneId = nil
							parkOwner = nil
							parkCoords = nil
							parkLabel = nil
						end
					end
				end
			end)			
		end
		Wait(sleep)
	end
end)

--- Draw 3D Text for polyzones
CreateThread(function()
	while true do 
		local sleep = 100
		if isLoggedIn and inparkzone then
			sleep = 0
			Draw3DText(parkCoords.x, parkCoords.y, parkCoords.z, parkLabel, 0, 0.04, 0.04)
		end
		Wait(sleep)
	end
end)

-- Set vehicle steering angle
CreateThread(function()
	local angle = 0.0
	local speed = 0.0
	while true do
		Wait(0)
		if isLoggedIn and saveSteeringAngle then
			local vehicle = GetVehiclePedIsUsing(PlayerPedId())
			if DoesEntityExist(vehicle) then
				local tangle = GetVehicleSteeringAngle(vehicle)
				if tangle > 10 or tangle < -10 then angle = tangle end
				speed = GetEntitySpeed(vehicle)
				if speed < 0.1 and DoesEntityExist(vehicle) and not GetIsTaskActive(PlayerPedId(), 151) and not GetIsVehicleEngineRunning(vehicle) then
					SetVehicleSteeringAngle(vehicle, angle)
				end
			end
		end
	end
end)

-- Disable Parked Vehicles Collision
CreateThread(function()
	while true do
		Wait(0)
		if isLoggedIn and disableParkedVehiclesCollision then
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

-- Display 3D text
CreateThread(function()
	while true do
		local sleep = 1000
		if isLoggedIn and display3DText and inparkzone then
			local playerCoords = GetEntityCoords(GetPlayerPed(-1))
			for k, data in pairs(parkedVehicles) do
				if data ~= nil then
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
								sleep = 0
								local txt = ""
								if Config.DisplayBrand then txt = txt .. Lang:t('info.brand', {brand = brand })..'\n' end
								if Config.DisplayModel then txt = txt .. Lang:t('info.model', {model = model })..'\n' end
								if Config.DisplaPlate  then txt = txt .. Lang:t('info.plate', {plate = plate })..'\n' end
								if Config.DisplayOwner then txt = txt .. Lang:t('info.owner', {owner = owner })..'\n' end
								local canDisplay = false
								if Config.DisplayToAllPlayers then
									canDisplay = true
								else
									if Config.DisplayToPlolice then
										if (PlayerData.job.name == "police" and PlayerData.job.onduty) then
											canDisplay = true
										end
									end
									if PlayerData.citizenid == data.owner then
										canDisplay = true
									end
								end
								if canDisplay then
									Draw3DText(entityCoords.x, entityCoords.y, entityCoords.z + 0.5, txt, 0, 0.04, 0.04)
								end
							end
						end
					end
				end
			end
		end
		Wait(sleep)
	end
end)

-- Park logic
CreateThread(function()
	while true do 
		local sleep = 1000 
		if isLoggedIn then
			local ped = PlayerPedId()
			if Config.UseAutoPark then
				sleep = 100
				if not isInVehicle and not IsPlayerDead(PlayerId()) then
					if DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not isEnteringVehicle then
						currentVehicle = GetVehiclePedIsTryingToEnter(ped)
						currentSeat = GetSeatPedIsTryingToEnter(ped)
						isEnteringVehicle = true
						currentPlate = GetPlate(currentVehicle)
						local netid = VehToNet(currentVehicle)
						TriggerServerEvent('mh-parking:server:EnteringVehicle', netid, currentSeat, currentPlate)
					elseif not DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not IsPedInAnyVehicle(ped, true) and isEnteringVehicle then
						isEnteringVehicle = false
					elseif IsPedInAnyVehicle(ped, false) then
						isEnteringVehicle = false
						isInVehicle = true
						currentVehicle = GetVehiclePedIsUsing(ped)
						currentSeat = GetPedVehicleSeat(ped)
						currentPlate = GetPlate(currentVehicle)
					end
				elseif isInVehicle and not IsPlayerDead(PlayerId()) then
					if not IsPedInAnyVehicle(ped, false) then
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
						local allowToPark = AllowToPark(coords)
						if allowToPark then
							if Config.OnlyAutoParkWhenEngineIsOff then
								local engineIsOn = GetIsVehicleEngineRunning(vehicle)
								if engineIsOn then 
									canSave = false										
								end
							end
						else
							canSave = false
						end
						if canSave then
							AllPlayersLeaveVehicle(vehicle)
							Citizen.Wait(2500)
							TriggerServerEvent('mh-parking:server:LeftVehicle', netid, currentSeat, plate, location, steerangle, street)
							SetVehicleEngineOn(vehicle, false, false, true)
						end
						isEnteringVehicle = false
						isInVehicle = false
						currentVehicle = 0
						currentSeat = 0
						Citizen.Wait(2500)
						SetVehicleEngineOn(vehicle, false, false, true)
					elseif not IsPedInAnyVehicle(ped, false) and not IsPlayerDead(PlayerId()) then
						isEnteringVehicle = false
						isInVehicle = false
						currentVehicle = 0
						currentSeat = 0
					end
				end
			elseif not Config.UseAutoPark then
				if IsPedInAnyVehicle(ped) then
					local vehicle = GetVehiclePedIsIn(ped, false)
					if vehicle ~= 0 then
						local isDriver = (GetPedInVehicleSeat(vehicle, -1) == ped)
						if isDriver then
							sleep = 0
							local storedVehicle = GetPlayerInParkedVehicle(vehicle)
							if storedVehicle ~= false then
								DisplayHelpText(Lang:t("info.press_drive_car", {key = Config.KeyParkBindButton}))
								if IsControlJustReleased(0, Config.ParkingButton) then
									IsUsingParkCommand = true
								end
							end
							if IsUsingParkCommand then
								IsUsingParkCommand = false
								if storedVehicle ~= false then
									SetPedIntoVehicle(ped, vehicle, -1)
									TriggerServerEvent('mh-parking:server:EnteringVehicle', storedVehicle.netid, -1, storedVehicle.plate)
									storedVehicle = nil
									sleep = 2000
								else
									local vehicle = GetVehiclePedIsIn(ped, false)
									local speed = GetEntitySpeed(vehicle)
									if speed > 0.1 then
										Notify(Lang:t("info.stop_car"), "primary", 5000)
									else
										local hasAccess = isVehicleAllowedToPark(vehicle)
										if hasAccess then
											local canSave = true
											local coords = GetEntityCoords(vehicle)
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
												TaskLeaveVehicle(ped, vehicle, 0)
												Wait(2000)
												local netid = VehToNet(vehicle)
												local seat = GetPedVehicleSeat(ped)
												local plate  = GetPlate(vehicle)
												local heading = GetEntityHeading(vehicle)
												local location = {x = coords.x, y = coords.y, z = coords.z, h = heading}
												local steerangle = GetVehicleSteeringAngle(vehicle) + 0.0
												local street = GetStreetName(vehicle)
												TriggerServerEvent('mh-parking:server:LeftVehicle', netid, -1, plate, location, steerangle, street)
												isInVehicle = false
												currentVehicle = 0
												currentSeat = 0
												sleep = 2000
											end
										else
											Notify(Lang:t("info.only_cars_allowd"), "primary", 5000)
										end
									end
								end
							end
						end
					end
				else
					IsUsingParkCommand = false
				end
			end
		end
		Wait(sleep)
	end
end)