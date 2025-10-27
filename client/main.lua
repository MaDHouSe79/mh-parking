local zones = {}
local zonesBlips = {}
local parkedBlips = {} 
local parkedVehicles = {}
local isEnteringVehicle = false
local isInVehicle = false
local isAdmin = false
local currentVehicle = nil
local currentSeat = nil
local currentPlate = nil
local inparkzone = false
local parkLabel = nil
local parkCoords = nil
local parkOwner = nil
local parkZoneId = nil

local display3DText = Config.Display3DText
local saveSteeringAngle = Config.SaveSteeringAngle
local useDebugPoly = Config.UseDebugPoly

local function DeleteZones()
	for k, zone in pairs(zones) do
		if zone ~= nil then
			zone:destroy()
		end
	end
	zones = {}

	for k, blip in pairs(zonesBlips) do
		if DoesBlipExist(blip) then
			RemoveBlip(blip)
			blip = nil
		end
	end
	zonesBlips = {}
end

local function RemoveParkBlip(zoneid)
	for k, blip in pairs(zonesBlips) do
		if DoesBlipExist(blip) and blip == Config.PrivedParking[zoneid].blip then
			Config.PrivedParking[zoneid].blip = nil
			RemoveBlip(blip)
			blip = nil
			break
		end
	end
end

local function CreateZoneBlipCircle(coords, text, color, sprite)
	local blip = AddBlipForCoord(coords)
	SetBlipHighDetail(blip, true)
	SetBlipSprite(blip, sprite)
	SetBlipScale(blip, 0.7)
	SetBlipColour(blip, color)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandSetBlipName(blip)
	zonesBlips[#parkedBlips + 1] = blip
	return blip
end

local function LoadZone()
	DeleteZones()
	Wait(1000)
	if type(Config.PrivedParking) == 'table' and #Config.PrivedParking >= 1 then
		for i = 1, #Config.PrivedParking, 1 do
			if Config.PrivedParking[i] ~= nil then
				local v = Config.PrivedParking[i] 
				zones[#zones + 1] = BoxZone:Create(vector3(v.coords.x, v.coords.y, v.coords.z), v.size.length, v.size.width, {
					name = i.."_parkzone",
					offset = {0.0, 0.0, 0.0},
					scale = {v.size.width, v.size.width, v.size.width},
					heading = v.coords.w,
					debugPoly = useDebugPoly,
				})
				Config.PrivedParking[i].blip = CreateZoneBlipCircle(v.coords, "parking Lot", 2, 225)
			end
		end
	end
end

local function DeleteVehicleAtcoords(coords)
	local closestVehicle, closestDistance = GetClosestVehicle(coords)
	if closestVehicle ~= -1 and closestDistance <= 2.0 then
		SetEntityAsMissionEntity(closestVehicle, true, true)
		DeleteEntity(closestVehicle)
		while DoesEntityExist(closestVehicle) do
			DeleteEntity(closestVehicle)
			Wait(50)
		end
	end
end

local function GetPedVehicleSeat(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)
    for i = -2, GetVehicleMaxNumberOfPassengers(vehicle) do
        if (GetPedInVehicleSeat(vehicle, i) == ped) then return i end
    end
    return -2
end

local function DoesPlateExist(plate)
	for i = 1, #parkedVehicles, 1 do
		if parkedVehicles[i].plate == plate then
			return true
		end
	end
	return false
end

local function DeleteparkedVehicles()
	for i = 1, #parkedVehicles, 1 do
		parkedVehicles[i] = nil
	end
	parkedVehicles = {}
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

local function CreateBlipCircle(coords, text, radius, color, sprite)
	local blip = nil
	if Config.DebugBlipForRadius then
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
	parkedBlips[#parkedBlips + 1] = blip
end

local function DeleteAllBlips()
	for k, blip in pairs(parkedBlips) do
		if DoesBlipExist(blip) then
			RemoveBlip(blip)
			blip = nil
		end
	end
	parkedBlips = {}
end

local function CreateBlips()
	if Config.UseUnableParkingBlips then
		for k, zone in pairs(Config.NoParkingLocations) do
			CreateBlipCircle(zone.coords, 'Unable to park', zone.radius, zone.color, zone.sprite)
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
		DeleteObject(object)
		StopAnimTask(ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 8.0)
	end
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
		if Config.OnlyAutoParkWhenEngineIsOff then
			local engineIsOn = GetIsVehicleEngineRunning(vehicle)
			if not engineIsOn then
				TriggerServerEvent('mh-parking:server:AllPlayersLeaveVehicle', VehToNet(vehicle), players)
			end
		else
			TriggerServerEvent('mh-parking:server:AllPlayersLeaveVehicle', VehToNet(vehicle), players)
		end
	end
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
							icon = "nui://mh-parking/core/images/".. v.vehicle..".png",
							description = Lang:t('info.street', {street = v.street}) .. '\n'.. Lang:t('info.fuel', {fuel = v.fuel}) .. '\n'.. Lang:t('info.engine', {engine = v.engine}) .. '\n'.. Lang:t('info.body', {body = v.body}) .. '\n'..Lang:t('info.click_to_set_waypoint'),
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

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        PlayerData = {}
        isLoggedIn = false
		DeleteAllBlips()
		DeleteparkedVehicles()
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
		PlayerData = GetPlayerData()
		isLoggedIn = true
        TriggerServerEvent('mh-parking:server:OnJoin')
    end
end)

RegisterNetEvent(OnPlayerUnload)
AddEventHandler(OnPlayerUnload, function()
    PlayerData = {}
    isLoggedIn = false
	DeleteZones()
end)

RegisterNetEvent(OnPlayerLoaded)
AddEventHandler(OnPlayerLoaded, function()
    PlayerData = GetPlayerData()
    isLoggedIn = true
	TriggerServerEvent('mh-parking:server:OnJoin')
end)

RegisterNetEvent('mh-parking:client:OpenParkMenu', function(data)
	if data.status then
		GetVehicleMenu()
	end
end)

RegisterNetEvent('mh-parking:client:leaveVehicle', function(data) 
	LeaveVehicle(data) 
end)

RegisterNetEvent('mh-parking:client:ToggleFreezeVehicle', function(data)
	local vehicle = NetworkGetEntityFromNetworkId(data.netid)
	if DoesEntityExist(vehicle) then
		if PlayerData.citizenid == data.owner then
			TriggerServerEvent('mh-parking:server:setVehLockState', data.netid, 1)
			SetVehicleDoorsLocked(vehicle, 1)
			FreezeEntityPosition(vehicle, false)
			return
		else
			TriggerServerEvent('mh-parking:server:setVehLockState', data.netid, 2)
			SetVehicleDoorsLocked(vehicle, 2)
			FreezeEntityPosition(vehicle, true)
			return
		end
	end
end)

RegisterNetEvent('mh-parking:client:AddVehicle', function(result)
	local vehicle = NetworkGetEntityFromNetworkId(result.data.netid)
	if DoesEntityExist(vehicle) then
		SetEntityAsMissionEntity(vehicle, true, true)
		SetFuel(vehicle, result.data.fuel + 0.0)
		SetVehicleSteeringAngle(vehicle, result.data.steerangle + 0.0)
		parkedVehicles[#parkedVehicles + 1] = {
			owner = result.data.owner,
			fullname = result.data.fullname,
			netid = result.data.netid,
			entity = result.data.entity,
			mods = result.data.mods,
			hash = result.data.hash,
			plate = result.data.plate, 
			model = result.data.model,
			fuel = result.data.fuel,
			body = result.data.body,
			engine = result.data.engine,
			steerangle = result.data.steerangle,
			location = result.data.location,
			blip = CreateParkedBlip(result.data)
		}
		if PlayerData.citizenid == result.data.owner then
			local last = Config.DebugBlipForRadius
			if last then Config.DebugBlipForRadius = false end
			BlinkVehiclelights(vehicle)
			Config.DebugBlipForRadius = last
		end		
	end
end)

RegisterNetEvent('mh-parking:client:RemoveVehicle', function(data)
	local netid = data.netid
	for i = 1, #parkedVehicles, 1 do
		local vehicle = NetworkGetEntityFromNetworkId(netid)
		if DoesEntityExist(vehicle) then
			local plate = GetVehicleNumberPlateText(vehicle)
			if parkedVehicles[i].plate == plate then
				if PlayerData.citizenid == parkedVehicles[i].owner then
					BlinkVehiclelights(parkedVehicles[i].entity)
				end
				if parkedVehicles[i].blip ~= nil then
					if DoesBlipExist(parkedVehicles[i].blip) then
						RemoveBlip(parkedVehicles[i].blip)
						parkedVehicles[i].blip = nil
					end
				end
				table.remove(parkedVehicles, i)
				break
			end
		end
	end
end)

RegisterNetEvent('mh-parking:client:Onjoin', function(data)
    PlayerData = GetPlayerData()
    isLoggedIn = true
	TriggerCallback('mh-parking:server:IsAdmin', function(result)
		isAdmin = result.isadmin
	end)
	LoadZone()
	CreateBlips()
	if data.status == true then
		local vehicles = data.vehicles
		for k, v in pairs(vehicles) do
			local vehicle = NetworkGetEntityFromNetworkId(v.netid)
			if DoesEntityExist(vehicle) then
				SetEntityAsMissionEntity(vehicle, true, true)
				SetVehicleProperties(vehicle, v.mods)
				SetVehicleSteeringAngle(vehicle, v.steerangle + 0.0)
				DoVehicleDamage(vehicle, v.body, v.engine)
				SetFuel(vehicle, v.fuel + 0.0)
				local exist = DoesPlateExist(v.plate)
				if not exist then
					parkedVehicles[#parkedVehicles + 1] = {
						owner = v.owner, 
						fullname = v.fullname,
						netid = v.netid,
						entity = v.entity,
						mods = v.mods,
						hash = v.hash,
						plate = v.plate, 
						model = v.model,
						fuel = v.fuel,
						body = v.body,
						engine = v.engine,
						steerangle = v.steerangle,
						location = v.location,
						blip = CreateParkedBlip(v),
					}
				end
			end
		end
	end
end)

RegisterNetEvent('mh-parking:client:TogglDebugPoly', function(data)
	isAdmin = false
	TriggerCallback('mh-parking:server:IsAdmin', function(result)
		useDebugPoly = not useDebugPoly
		if result.status and result.isadmin then
			isAdmin = true
			local txt = ""
			if useDebugPoly then txt = "enable" else txt = "disable" end
			Notify("Polyzone debug is now "..txt)			
		end
		LoadZone()			
	end)
end)

RegisterNetEvent('mh-parking:client:toggleParkText', function()
	display3DText = not display3DText
	local txt = nil
	if display3DText then txt = "enable" else txt = "disable" end
	Notify("Parked vehicle text is now "..txt, "success", 5000)
end)

RegisterNetEvent('mh-parking:client:toggleSteerAngle', function()
	saveSteeringAngle = not saveSteeringAngle
	local txt = nil
	if saveSteeringAngle then txt = "enable" else txt = "disable" end
	Notify("Steer angle save is now "..txt, "success", 5000)
end)

RegisterNetEvent('mh-parking:client:reloadZones', function(input)
	Config.PrivedParking = input.data
	inparkzone = false
	Wait(100)
	LoadZone()
end)

RegisterNetEvent('mh-parking:client:CreatePark', function(data)
	if data.id ~= nil and data.name ~= nil and data.label ~= nil then
		local data = {
			id = data.id, 
			name = data.name, 
			job = data.job, 
			label = data.label, 
			street = GetStreetName(GetEntityCoords(PlayerPedId())),
			coords = GetEntityCoords(PlayerPedId()), 
			heading = GetEntityHeading(PlayerPedId()),
		}
		useDebugPoly = true
		TriggerServerEvent('mh-parking:server:CreatePark', data)			
	end
end)

CreateThread(function()
	while true do
		local sleep = 1000
		if isLoggedIn then
			for k, zone in pairs(zones) do
				zone:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside, point)
					local id = string.sub(zone.name, 1, 1)
					if Config.PrivedParking[tonumber(id)] then
						local data = Config.PrivedParking[tonumber(id)]
						if isPointInside then
							if Config.UsePrivedParking and not inparkzone then
								inparkzone = true
								parkZoneId = string.sub(zone.name, 1, 1)
								parkOwner = data.citizenid
								parkCoords = data.coords
								local adminTxt = ""
								if isAdmin then adminTxt = "~w~Zone ID: ~o~"..parkZoneId.."\n~w~Filename: ~o~"..data.name.. "~w~\n" end
								local street = "~w~Street: ~b~"..data.street.."\n"
								parkLabel = adminTxt .. street.. "Owner: ~g~"..data.label.."~w~\n"
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
		end
		Wait(sleep)
	end
end)

CreateThread(function()
	while true do
		Wait(0)
		if isLoggedIn and display3DText then
			local playerCoords = GetEntityCoords(GetPlayerPed(-1))
			local txt = ""
			for i = 1, #parkedVehicles, 1 do
				if parkedVehicles[i] ~= nil then
					local vehicle = NetToVeh(parkedVehicles[i].netid)
					if DoesEntityExist(vehicle) then
						local entityCoords = GetEntityCoords(vehicle)
						local distance = GetDistance(playerCoords, entityCoords)
						if distance < Config.DisplayDistance then
							local owner, plate, model, brand = parkedVehicles[i].fullname, parkedVehicles[i].plate, nil, nil
							for k, vehicle in pairs(Config.Vehicles) do
								if vehicle.model == parkedVehicles[i].model then
									model, brand = vehicle.name, vehicle.brand
									break
								end
							end
							if model ~= nil and brand ~= nil then
								txt = "Model: ~b~"..model.."~s~".. '\n' .. "Brand: ~o~"..brand.."~s~".. '\n' .. "Plate: ~g~"..plate.."~s~".. '\n' .. "Owner: ~y~"..owner.."~s~"
								if Config.DisplayToAllPlayers then
									Draw3DText(entityCoords.x, entityCoords.y, entityCoords.z, txt, 0, 0.04, 0.04)
								else
									if PlayerData.citizenid == owner then
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
					TriggerServerEvent('mh-parking:server:EnteringVehicle', netid, currentSeat, currentPlate)
				elseif not DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not IsPedInAnyVehicle(ped, true) and isEnteringVehicle then
					isEnteringVehicle = false
				elseif IsPedInAnyVehicle(ped, false) then
					isEnteringVehicle = false
					isInVehicle = true
					currentVehicle = GetVehiclePedIsUsing(ped)
					currentSeat = GetPedVehicleSeat(ped)
					currentPlate = GetPlate(currentVehicle)
                    local netid = VehToNet(currentVehicle)
					TriggerServerEvent('mh-parking:server:EnteredVehicle', netid, currentSeat, currentPlate)
				end
			elseif isInVehicle then
				if not IsPedInAnyVehicle(ped, false) or IsPlayerDead(PlayerId()) then
                    local vehicle = GetVehiclePedIsIn(ped, true)
                    local netid = VehToNet(currentVehicle)
					local steerangle = GetVehicleSteeringAngle(currentVehicle) + 0.0
					local coords = GetEntityCoords(currentVehicle)
					local heading = GetEntityHeading(currentVehicle)
					local street = GetStreetName(coords)
					currentPlate = GetPlate(currentVehicle)
					local location = { x = coords.x, y = coords.y, z = coords.z, h = heading }
					local fuel = GetFuel(currentVehicle)
					local isAllowd = AllowToPark(coords)
					if isAllowd then
						AllPlayersLeaveVehicle(currentVehicle)
						Wait(2000)
						TriggerServerEvent('mh-parking:server:LeftVehicle', netid, currentSeat, currentPlate, location, steerangle, fuel, street)
					end
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

CreateThread(function()
	while true do 
		local sleep = 100
		if isLoggedIn and inparkzone and parkZoneId ~= nil then
			sleep = 0
			Draw3DText(parkCoords.x, parkCoords.y, parkCoords.z, parkLabel, 0, 0.04, 0.04)
		end
		Wait(sleep)
	end
end)
