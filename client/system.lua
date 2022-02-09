QBCore = exports['qb-core']:GetCoreObject()

local Email = function()
    self.sender = nil
    self.subject = nil
    self.message = nil

    self.SetSender = function(sender)
        self.sender = sender
    end

    self.SetSubject = function(subject)
        self.subject = subject
    end

    self.SetMessage = function(message)
        self.message = message
    end

    self.Send = function()
        if PhoneNotification then
            local coords = GetEntityCoords(PlayerPedId())
            TriggerServerEvent('qb-phone:server:sendNewMail', {
                sender  = self.sender,
                subject = self.subject,
                message = self.message,
                button = {
                    enabled = true,
                    buttonEvent = "qb-parking:client:setParkedVecihleLocation",
                    buttonData = coords
                }
            })
        end
    end
    return self
end

local LocalList = function()
    self.vehicleList = {}

    self.Add = function(vehiclw, data)  
        self.vehicleList[#self.vehicleList+1] = { entity = vehiclw, vehicle = data.mods,  plate = data.plate, citizenid = data.citizenid,  citizenname = data.citizenname, livery = data.vehicle.livery, health = data.vehicle.health, model = data.model,location = {x = data.vehicle.location.x, y = data.vehicle.location.y, z = data.vehicle.location.z + 0.5, w = data.vehicle.location.w }} 
    end

    self.Remove = function(num)        
        self.vehicleList[num] = nil 
    end

    self.Get = function(num)
         return self.vehicleList[num]       
    end

    self.List = function() 
        return self.vehicleList            
    end

    self.Clear = function()            
        self.vehicleList = {}       
    end

    return self
end

local Screen = function()

    self.GetDisplayNames = function(vehicleData)
        local owner = string.format(Lang:t("info.owner", {owner = vehicleData.citizenname}))..'\n'
        local model = string.format(Lang:t("info.model", {model = vehicleData.model}))..'\n'
        local plate = string.format(Lang:t("info.plate", {plate = vehicleData.plate}))..'\n'
        return string.format("%s", model..plate..owner)
    end

    self.OwnerText = function()
        if not HideParkedVehicleNames then -- for performes
            local pl = GetEntityCoords(PlayerPedId())
            local displayWhoOwnesThisCar = nil
            for k, vehicle in pairs(self.LocalVehicles.List()) do
                displayWhoOwnesThisCar = self.GetDisplayNames(vehicle)
                if #(pl - vector3(vehicle.location.x, vehicle.location.y, vehicle.location.z)) < Config.DisplayDistance then
                    if PlayerJob == "police" and OnDuty == true then
                        self.Display.Draw3DText(vehicle.location.x, vehicle.location.y, vehicle.location.z - 0.2, displayWhoOwnesThisCar, 0, 0.04, 0.04)
                    end
                    if self.PlayerData.citizenid == vehicle.citizenid then
                        self.Display.Draw3DText(vehicle.location.x, vehicle.location.y, vehicle.location.z - 0.2, displayWhoOwnesThisCar, 0, 0.04, 0.04)
                    end
                end
            end
        end
    end

    self.GetStreetName = function()
        local ped       = PlayerPedId()
        local veh       = GetVehiclePedIsIn(ped, false)
        local coords    = GetEntityCoords(PlayerPedId())
        local zone      = GetNameOfZone(coords.x, coords.y, coords.z)
        local zoneLabel = GetLabelText(zone)
        local var       = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
        local hash      = GetStreetNameFromHashKey(var)
        local street    = nil
        if hash == '' then street = zoneLabel else street = hash..', '..zoneLabel end
        return street
    end

    -- Draw 3d text on screen
    self.Draw3DText = function(x, y, z, textInput, fontId, scaleX, scaleY)
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

    self.DisplayHelpText = function(text)
        SetTextComponentFormat('STRING')
        AddTextComponentString(text)
        DisplayHelpTextFromStringLabel(0, 0, 1, -1)
    end

    return self
end

local Vehicle = function()
    self.entity = nil
    self.data = nil
    self.vehicle = nil

    self.SetEntity = function(entity)
        self.entity = entity
    end

    self.SetData = function(data)
        self.data = data
    end

    self.SetVehicle = function(vehicle)
        self.vehicle = vehicle
    end

    self.SetProperties = function()
        return QBCore.Functions.SetVehicleProperties(self.entity, self.data.vehicle.props)
    end

    self.GetProperties = function(vehicle)
        return QBCore.Functions.GetVehicleProperties(vehicle)
    end

    self.LoadModel = function(model)
        QBCore.Functions.LoadModel(model)
    end

    self.Create = function(vehicle)
        self.LoadModel(self.vehicle.props["model"])
        return CreateVehicle(self.vehicle.props["model"], self.vehicle.location.x, self.vehicle.location.y, self.vehicle.location.z, self.vehicle.location.w, true)
    end

    self.SetRadioStatio = function(state)
        if state then
            SetVehRadioStation(self.entity, 'ON')
        else
            SetVehRadioStation(self.entity, 'OFF')
        end
    end

    self.SetOnGroundProperly = function()
        RequestCollisionAtCoord(self.data.vehicle.location.x, self.data.vehicle.location.y, self.data.vehicle.location.z)
        SetVehicleOnGroundProperly(self.entity)
    end

    self.SetAsMissionEntity = function(state)
        SetEntityAsMissionEntity(self.entity, state, state)
    end

    self.SetInvincible = function(state)
        SetEntityInvincible(state)
    end

    self.SetHeading = function()
        SetEntityHeading(self.entity, self.data.vehicle.location.w)
    end

    self.SetLivery = function()
        SetVehicleLivery(self.entity, self.data.vehicle.livery)
    end
    
    self.SetEngineHealth = function ()
        SetVehicleEngineHealth(self.entity, self.data.vehicle.health.engine)
    end

    self.SetBodyHealth = function()
        SetVehicleBodyHealth(self.entity, self.data.vehicle.health.body)
    end

    self.SetPetrolTankHealth = function()
        SetVehiclePetrolTankHealth(self.entity, self.data.vehicle.health.tank)
        exports[Config.YourFuelExportName]:SetFuel(self.entity, self.data.vehicle.health.tank)
    end

    self.SetDirtLevel = function(num)
        SetVehicleDirtLevel(self.entity, num)
    end

    self.SetEngine = function(state)
        SetVehicleEngineOn(self.entity, state, state, true)
    end

    self.SetLocked = function(state)
        if state then
            SetVehicleDoorsLocked(self.entity, 2)
        else
            SetVehicleDoorsLocked(self.entity, 0)
        end
    end

    self.ModelNoLongerNeeded = function()
        SetModelAsNoLongerNeeded(self.data.vehicle.props["model"])
    end

    self.WarpIntoVehicle = function(ped)
        TaskWarpPedIntoVehicle(ped, self.entity, -1)
    end

    self.SetOnGroundProperly = function()
        RequestCollisionAtCoord(self.vehicle.location.x, self.vehicle.location.y, self.vehicle.location.z)
        SetVehicleOnGroundProperly(self.entity)
    end

    self.SetHotwired = function(ped, state)
        SetVehicleNeedsToBeHotwired(GetVehiclePedIsTryingToEnter(ped), state)     
    end

    self.Freeze = function( state)
        FreezeEntityPosition(self.vehicle, state)    
    end

    self.Prepare = function()
        self.SetOnGroundProperly()
        self.SetAsMissionEntity(true)
        self.SetInvincible(true)
        self.SetHeading()
        self.SetLivery()
        self.SetEngineHealth()
        self.SetBodyHealth()
        self.SetPetrolTankHealth()
        self.SetRadioStatio(false)
        self.SetDirtLevel(0)
        self.SetProperties()
        self.SetEngine(false)
        self.ModelNoLongerNeeded()
    end

    self.MakeReady = function(vehicle)
        -- Delete the local entity first
        self.DeleteNearByVehicle(vector3(vehicle.location.x, vehicle.location.y, vehicle.location.z))
        self.SetVehicle(vehicle)
        self.entity = self.Create(vehicle)
        self.WarpIntoVehicle(PlayerPedId())
        self.SetProperties()
        self.SetOnGroundProperly()
        self.Freeze(false)
        self.SetLivery()
        self.SetEngineHealth()
        self.SetBodyHealth()
        self.SetPetrolTankHealth()
        self.SetRadioStatio(false)
        self.SetDirtLevel(0)
        self.SetLocked(true)
        self.ModelNoLongerNeeded()
    end

    self.Spawn = function(vehicleData, type)
        self.LoadModel(vehicleData.vehicle.props["model"])
        self.entity = CreateVehicle(vehicleData.vehicle.props["model"], vehicleData.vehicle.location.x, vehicleData.vehicle.location.y, vehicleData.vehicle.location.z - 0.1, vehicleData.vehicle.location.w, false)
        QBCore.Functions.SetVehicleProperties(self.entity, vehicleData.vehicle.props)
        exports[Config.YourFuelExportName]:SetFuel(self.entity, vehicleData.vehicle.health.tank)
        SetVehicleEngineOn(self.entity, false, false, true)
        if type == 'server' then
            if not Config.ImUsingOtherKeyScript then
                TriggerEvent('vehiclekeys:client:SetVehicleOwnerToCitizenid', vehicleData.plate, vehicleData.citizenid)
            end
        end
        self.SetEntity(self.entity)
        self.SetData(vehicleData)
        self.SetVehicle(vehicleData.vehicle)
        self.Prepare()
    end

    self.Delete = function(vehicle)
        DeleteEntity(vehicle)
    end

    return self
end

ParkClient = function()
    self                 = {}
    self.PlayerData      = {}
    self.PlayerJob       = {}
    self.OnDuty          = false
    self.Citizenid       = nil
    self.Action          = 'none'      
    self.InParking       = false
    self.SpawnedVehicles = false
    self.UpdateAvailable = false
    self.IsUsingCommand  = false
    self.IsDeleting      = false
    self.LastUsedPlate   = nil
    self.entity          = nil
    self.LocalVehicles   = LocalList()
    self.Display         = Screen()
    self.Vehicle         = Vehicle()
    self.GlobalVehicles  = {}
    self.crParking       = nil

    -- Wait
    self.Wait = function(timer)
        Wait(timer)
    end

    -- Set Player Data
    self.SetPlayerData = function(data)
        self.PlayerData = data
        self.Citizenid  = self.PlayerData.citizenid
        self.PlayerJob  = self.PlayerData.job
    end

    -- Set On Duty
    self.SetOnDuty = function(state)
        self.OnDuty = state
    end

    -- Set Player Job
    self.SetPlayerJob = function(job)
        self.PlayerJob = job
    end

    -- Press Button
    self.PressButton = function()
        return IsControlJustReleased(0, Config.parkingButton)
    end

    -- Notify
    self.Notify = function(msg, type)
        QBCore.Functions.Notify(msg, type)
    end

    -- Set Vehicle Engine On
    self.SetVehicleEngineOn = function(Vehicle, parm, parm)
        SetVehicleEngineOn(Vehicle, parm, parm, true)
    end

    -- Freeze Entity
    self.FreezeEntity = function(Vehicle, state)
        FreezeEntityPosition(Vehicle, state)    
    end

    -- Get Model Readable Name
    self.GetModelReadableName = function(model)
        return GetLabelText(GetDisplayNameFromVehicleModel(model))
    end

    -- Do Action
    self.DoAction = function(action)
        if self.Action == 'drive' then
            self.Action = nil
            if self.LastUsedPlate and vehicles[i].plate == self.LastUsedPlate then
                TaskWarpPedIntoVehicle(PlayerPedId(), self.entity, -1)
                TaskLeaveVehicle(PlayerPedId(), self.entity)
                self.LastUsedPlate = nil
            end
        end
    end

    -- Get Player In Stored Car
    self.GetPlayerInStoredCar = function(player)
        local entity = GetVehiclePedIsIn(player)
        local findVehicle = false
        for i = 1, #self.LocalVehicles.List() do
            if self.LocalVehicles.Get(i).entity == entity then
                findVehicle = self.LocalVehicles.Get(i)
                break
            end
        end
        return findVehicle
    end

    -- Save
    self.Save = function(player, vehicle)
        self.ParkCarAnimation(player, vehicle)
        local vehicleProps = self.Vehicle.GetProperties(vehicle)
        local carModelName = self.GetModelReadableName(vehicleProps["model"]) 
        self.Action        = 'park'
        self.LastUsedPlate = vehicleProps.plate
        QBCore.Functions.TriggerCallback("qb-parking:server:save", function(callback)
            if callback.status then
                QBCore.Functions.DeleteVehicle(vehicle)
                local email = Email()
                email.SetSender(Lang:t('mail.sender', {company = Lang:t('info.companyName')}))
                email.SetSubject(Lang:t('mail.subject', {model = carModelName, plate = self.LastUsedPlate}))
                email.SetMessage(Lang:t('mail.message', {street = self.Display.GetStreetName(), company = Lang:t('info.companyName'), username = self.PlayerData.charinfo.firstname, model = carModelName, plate = self.LastUsedPlate}))
                email.Send()
            else
                self.Notify(callback.message, "error", 5000)
            end
        end, {
            props       = vehicleProps,
            livery      = GetVehicleLivery(vehicle),
            citizenid   = self.PlayerData.citizenid,
            plate       = vehicleProps.plate,
            model       = carModelName,
            health      = {engine = GetVehicleEngineHealth(vehicle), body = GetVehicleBodyHealth(vehicle), tank = GetVehiclePetrolTankHealth(vehicle) },
            location    = vector4(GetEntityCoords(vehicle).x, GetEntityCoords(vehicle).y, GetEntityCoords(vehicle).z - 0.5, GetEntityHeading(vehicle)),
        })
    end

    -- Drive
    self.Drive = function(player, vehicle)
        self.Action = 'drive'
        QBCore.Functions.TriggerCallback("qb-parking:server:drive", function(callback)
            if callback.status then
                QBCore.Functions.DeleteVehicle(vehicle.entity)
                QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(player))
                vehicle = false
                self.Vehicle.MakeReady(callback.data)
            else
                self.Notify(callback.message, "error", 5000)
            end
        end, vehicle)
    end

    -- Delete Local Vehicle
    self.DeleteLocalVehicle = function(vehicle)
        if type(self.LocalVehicles.List()) == 'table' and #self.LocalVehicles.List() > 0 and self.LocalVehicles.Get(1) then
            for i = 1, #self.LocalVehicles.List() do
                if vehicle and vehicle.plate == self.LocalVehicles.Get(i).plate then
                    DeleteEntity(self.LocalVehicles.Get(i).entity)
                    self.LocalVehicles.Remove(i)
                end
            end
        end
    end

    -- Spawn Vehicles
    self.SpawnVehicles = function(vehicles)
        CreateThread(function()
            while self.IsDeleting do Citizen.Wait(100) end
            if type(vehicles) == 'table' and #vehicles > 0 and vehicles[1] then
                for i = 1, #vehicles, 1 do
                    self.DeleteLocalVehicle(vehicles[i].vehicle)
                    self.Vehicle.SetEntity(self.entity)
                    self.Vehicle.Spawn(vehicles[i], 'server')
                    self.Vehicle.SetEngine(false)
                    self.Vehicle.SetLocked(true)
                    self.Vehicle.SetHotwired(ped, true)
                    self.Wait(500)
                    self.Vehicle.Freeze(true)
                    self.Add(self.entity, vehicles[i])
                    self.DoAction(action)
                end
            end
        end)
    end

    -- Spawn Vehicle
    self.SpawnVehicle = function(vehicleData)
        CreateThread(function()
            if LocalPlayer.state.isLoggedIn then
                while self.IsDeleting do Wait(100) end
                self.DeleteLocalVehicle(vehicleData.vehicle)
                self.Vehicle.Spawn(vehicleData, 'client')
                self.Vehicle.SetEntity(self.entity)
                self.Vehicle.SetData(vehicleData)
                self.Vehicle.SetVehicle(vehicleData.vehicle)
                self.Vehicle.Prepare()
                self.Vehicle.Freeze(true)
                if vehicleData.citizenid ~= QBCore.Functions.GetPlayerData().citizenid then
                    self.Vehicle.SetLocked(true)
                end
                self.Add(self.entity, vehicleData)
                self.DoAction(action)
            end
        end)
    end

    -- Remove Vehicles
    self.RemoveVehicles = function(vehicles)
        self.IsDeleting = true
        if type(vehicles) == 'table' and #vehicles > 0 and vehicles[1] then
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
        self.LocalVehicles.Clear()
        self.IsDeleting = false
    end

    -- Load Anim Dict
    self.loadAnimDict = function(dict)
        while (not HasAnimDictLoaded(dict)) do
            RequestAnimDict(dict)
            Wait(5)
        end
    end

    --Park Car Animation
    self.ParkCarAnimation = function(player, vehicle)
        self.Vehicle.SetEntity(vehicle)
        self.loadAnimDict('anim@mp_player_intmenu@key_fob@')
        TaskLeaveVehicle(player, vehicle)
        TaskPlayAnim(player, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49, 0, false, false)
        self.Wait(2000)
        ClearPedTasks(player)
        SetVehicleLights(vehicle, 2)
        self.Wait(150)
        SetVehicleLights(vehicle, 0)
        self.Wait(150)
        SetVehicleLights(vehicle, 2)
        self.Wait(150)
        SetVehicleLights(vehicle, 0)
        self.Vehicle.SetLocked(true)
        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "lock", 0.3)
    end

    -- Delete Near By Vehicle
    self.DeleteNearByVehicle = function(location)
        local vehicle, distance = QBCore.Functions.GetClosestVehicle(location)
        if distance <= 1 then
            for i = 1, #self.LocalVehicles.List do
                if self.LocalVehicles.Get(i).entity == vehicle then
                    self.LocalVehicles.Remove(i)
                end
                local tmpModel = GetEntityModel(vehicle)
                SetModelAsNoLongerNeeded(tmpModel)
                DeleteEntity(vehicle)
                tmpModel = nil
            end
        end
    end

    -- Impound
    self.Impound = function(entity)
        for i = 1, #self.LocalVehicles.List() do
            if entity == self.LocalVehicles.Get(i).entity then
                QBCore.Functions.TriggerCallback("qb-parking:server:impound", function(callback)
                    if callback.status then
                        self.Vehicle.SetEntity(self.LocalVehicles.Get(i).entity)
                        self.Vehicle.Freeze(true)
                        self.Vehicle.Delete(self.LocalVehicles.Get(i).entity)
                        self.LocalVehicles.Remove(i)

                    end
                end, self.LocalVehicles.Get(i))
            end
        end
    end

    -- Stolen
    self.Stolen = function(entity)
        for i = 1, #self.LocalVehicles.List() do
            if entity == self.LocalVehicles.Get(i).entity then
                QBCore.Functions.TriggerCallback("qb-parking:server:stolen", function(callback)
                    if callback.status then
                        self.Vehicle.SetEntity(Park.LocalVehicles.Get(i).entity)
                        self.Vehicle.Freeze(false)
                        self.LocalVehicles.Remove(i)
                    end
                end, self.LocalVehicles.Get(i))
            end
        end
    end

    -- SetNewWaypoint
    self.SetNewWaypoint = function(x, y)
        SetNewWaypoint(x, y)
        self.Notify(Lang:t("success.route_has_been_set"), 'success')
    end

    -- RefreshVehicles
    self.RefreshVehicles = function(vehicles)
        self.GlobalVehicles = vehicles
        self.RemoveVehicles(vehicles)
        self.Wait(1000)
        self.SpawnVehicles(vehicles)
        self.Wait(1000)
    end

    self.RunLocatiobControll = function()
        if UseParkingSystem then
            while true do
                local pl = GetEntityCoords(PlayerPedId())
                if #(pl - vector3(Config.ParkingLocation.x, Config.ParkingLocation.y, Config.ParkingLocation.z)) < Config.ParkingLocation.s then
                    self.InParking = true
                    self.crParking = 'allparking'
                end
                if self.InParking then
                    if not self.SpawnedVehicles then
                        self.RemoveVehicles(self.GlobalVehicles)
                        TriggerServerEvent("qb-parking:server:refreshVehicles", self.crParking)
                        self.SpawnedVehicles = true
                        self.Wait(2000)
                    end
                else
                    if self.SpawnedVehicles then
                        self.RemoveVehicles(self.GlobalVehicles)
                        self.SpawnedVehicles = false
                    end
                end
                self.Wait(0)
            end
        end
    end
    -- park and drive controll
    self.RunParkControll = function()
        if UseParkingSystem then
            while true do
                local player = PlayerPedId()
                if self.InParking and IsPedInAnyVehicle(player) then
                    local storedVehicle = self.GetPlayerInStoredCar(player)
                    local vehicle = GetVehiclePedIsIn(player)
                    if storedVehicle ~= false then
                        self.Display.DisplayHelpText(Lang:t("info.press_drive_car"))
                        if self.PressButton() then
                            self.IsUsingCommand = true
                        end
                    end
                    if self.IsUsingCommand then
                        self.IsUsingCommand = false
                        if storedVehicle ~= false then
                            self.Drive(player, storedVehicle)
                        else
                            if vehicle then
                                if IsThisModelACar(GetEntityModel(vehicle)) or IsThisModelABike(GetEntityModel(vehicle)) or IsThisModelABicycle(GetEntityModel(vehicle)) then
                                    self.Save(player, vehicle)
                                else
                                    self.Notify(Lang:t("info.only_cars_allowd"), "error", 5000)
                                end						
                            end
                        end
                    end
                else
                    self.IsUsingCommand = false
                end
                self.Wait(0)
            end
        end
    end

    -- display owners text
    self.RunDisplayOwnerText = function()
        if UseParkingSystem and not HideParkedVehicleNames then
            while true do
                self.Display.OwnerText()
                self.Wait(0)
            end
        end
    end

    -- commands
    self.CommandNotification = function()
        PhoneNotification = not PhoneNotification
        if PhoneNotification then
            self.Notify(Lang:t('system.enable', {type = "notifications"}), "primary", 5000)
        else
            self.Notify(Lang:t('system.disable', {type = "notifications"}), "error", 5000)
        end
    end

    -- parking names
    self.CommandParknames = function()
        HideParkedVehicleNames = not HideParkedVehicleNames
        if HideParkedVehicleNames == true then
            self.Notify(Lang:t('system.enable', {type = "names"}), "primary", 5000)
        else
            self.Notify(Lang:t('system.disable', {type = "names"}), "error", 5000)
        end
    end

    -- Update check
    self.UpdateSystem = function(state)
        self.UpdateAvailable = state
        if self.UpdateAvailable then
            print("There is a update available for qb-parking")
        end
    end

    return self
end