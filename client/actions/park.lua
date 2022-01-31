-- Park
local function ParkCar(player, vehicle)
    TaskLeaveVehicle(player, vehicle)
    for i = 0, 5 do
        SetVehicleDoorShut(vehicle, i, false) -- will close all doors from 0-5
        if Config.SoundWhenCloseDoors then
            PlayVehicleDoorCloseSound(vehicle, i)
        end
    end
    Wait(2000)
    SetVehicleDoorsLocked(vehicle, 2)
    SetVehicleLights(vehicle, 2)
    Wait(150)
    SetVehicleLights(vehicle, 0)
    Wait(150)
    SetVehicleLights(vehicle, 2)
    Wait(150)
    SetVehicleLights(vehicle, 0)
end

-- Send Email to the player phone
local function SendMail(mail_sender, mail_subject, mail_message)
    if PhoneNotification then
        local coords = GetEntityCoords(PlayerPedId())
        TriggerServerEvent('qb-phone:server:sendNewMail', {
            sender  = mail_sender,
            subject = mail_subject,
            message = mail_message,
            button = {
                enabled = true,
                buttonEvent = "qb-parking:client:setParkedVecihleLocation",
                buttonData = coords
            }
        })
    end
end

-- Get the street name where you are at the moment.
local function GetStreetName()
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

-- Save
function Save(player, vehicle)
    ParkCar(player, vehicle)
    local vehicleProps = QBCore.Functions.GetVehicleProperties(vehicle)
    local displaytext  = GetDisplayNameFromVehicleModel(vehicleProps["model"])
    local carModelName = GetLabelText(displaytext)
    action             = 'park'
    LastUsedPlate      = vehicleProps.plate
    QBCore.Functions.TriggerCallback("qb-parking:server:save", function(callback)
        if callback.status then
            DeleteVehicle(vehicle)
            SendMail(
            Lang:t('mail.sender' , {
                company   = Lang:t('info.companyName'),
            }),
            Lang:t('mail.subject', {
                model     = carModelName,
                plate     = LastUsedPlate,
            }),
            Lang:t('mail.message', {
                street    = GetStreetName(),
                    company   = Lang:t('info.companyName'),
                username  = PlayerData.charinfo.firstname,
                model     = carModelName,
                plate     = LastUsedPlate,
            })
            )
        else
            QBCore.Functions.Notify(callback.message, "error", 5000)
        end
    end, {
        props       = vehicleProps,
        livery      = GetVehicleLivery(vehicle),
        citizenid   = PlayerData.citizenid,
        plate       = vehicleProps.plate,
        model       = carModelName,
        health      = {engine = GetVehicleEngineHealth(vehicle), body = GetVehicleBodyHealth(vehicle), tank = GetVehiclePetrolTankHealth(vehicle) },
        location    = vector4(GetEntityCoords(vehicle).x, GetEntityCoords(vehicle).y, GetEntityCoords(vehicle).z - 0.5, GetEntityHeading(vehicle)),
    })
end
