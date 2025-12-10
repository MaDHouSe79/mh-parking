-- ═══════════════════════════════════════════════════════════ --
--          MH-PARKING – 100% Statebag by MaDHouSe79           --
-- ═══════════════════════════════════════════════════════════ --

local Target = {}

if GetResourceState("ox_target") == "started" then
    Target.name = "ox_target"
    Target.addGlobalVehicle = function(options) exports.ox_target:addGlobalVehicle(options) end
elseif GetResourceState("qb-target") == "started" or GetResourceState("qtarget") == "started" then
    Target.name = GetResourceState("qb-target") == "started" and "qb-target" or "qtarget"
    local exportName = GetResourceState("qb-target") == "started" and "qb-target" or "qtarget"
    Target.addGlobalVehicle = function(options) exports[exportName]:AddGlobalVehicle({options = options, distance = 4.0}) end
end

local function getEntity(data)
    if type(data) == 'table' then return data.entity else return data end
end

local function createParkingOptions()
    return {
        {
            num         = 1,
            name        = "parking_info",
            icon        = "fas fa-circle-info",
            label       = "Vehicle Info",
            distance    = 3.0,
            action = function(data)
                TriggerEvent("mh-parking:infomenu")
            end,
            canInteract = function(data)
                local entity = getEntity(data)
                return DoesEntityExist(entity) and IsEntityAVehicle(entity)
            end,
        },
        {
            num      = 2,
            name     = "give_keys",
            icon     = "fas fa-lock-open",
            label    = "Give Keys (owner)",
            distance = 3.0,
            action = function(data)
                local entity = getEntity(data)
                local plate = GetPlate(entity)
                TriggerServerEvent('mh-parking:givekey', plate)
            end,
            canInteract = function(data)
                local entity = getEntity(data)
                local state = Entity(entity).state
                if state then 
                    if state.citizenid ~= nil and GetIdentifier() ~= state.citizenid then return false end
                else
                    return false
                end
                return true
            end,
        },
        {
            num      = 3,
            name     = "unpark_vehicle",
            icon     = "fas fa-lock-open",
            label    = "Unpark Vehicle (owner)",
            distance = 3.0,
            action = function(data)
                local entity = getEntity(data)
                local netid = SafeNetId(entity)
                BlinkVehiclelights(entity)
                TriggerServerEvent('mh-parking:server:setVehLockState', netid, 1)
                SetVehicleDoorsLocked(entity, 1)
                TriggerServerEvent('mh-parking:autoUnpark', netid)
            end,
            canInteract = function(data)
                local entity = getEntity(data)
                local state = Entity(entity).state
                if state then
                    if state.citizenid ~= nil and GetIdentifier() ~= state.citizenid then return false end
                    if not state.isParked then return false end
                else
                    return false
                end
                return true
            end,
        },
        {
            num      = 4,
            name     = "park_vehicle",
            icon     = "fas fa-lock-open",
            label    = "Park Vehicle (owner)",
            distance = 3.0,
            action = function(data)
                local entity = getEntity(data)
                local netid = SafeNetId(entity)
                local steerangle = GetVehicleSteeringAngle(entity) 
                local street = GetStreetName(GetEntityCoords(ped))
                local fuel = GetVehicleFuelLevel(entity)
                local engine = GetVehicleEngineHealth(entity)
                local body = GetVehicleBodyHealth(entity)
                local mods = GetVehicleProperties(entity)
                BlinkVehiclelights(entity) 
                SetVehicleEngineOn(entity, false, false, false)                                    
                TriggerServerEvent('mh-parking:autoPark', netid, steerangle, street, mods, fuel, body, engine) 
            end,
            canInteract = function(data)
                local entity = getEntity(data)
                local state = Entity(entity).state
                if state then
                    if state.citizenid ~= nil and GetIdentifier() ~= state.citizenid then return false end
                    if state.isParked then return false end
                else
                    return false
                end
                return true
            end,
        },
        {
            num      = 5,
            name     = "clamp_wheel",
            icon     = "fas fa-lock",
            label    = "Add Wheelclamp (police)",
            job      = { ["police"] = 0 },
            distance = 3.0,
            action = function(data)
                local entity = getEntity(data)
                local vehicle = entity
                TriggerServerEvent("mh-parking:server:toggleClamp", SafeNetId(vehicle), true)
            end,
            canInteract = function(data)
                local entity = getEntity(data)
                local plate = GetPlate(entity)
                local state = Entity(entity).state
                return state and not state.isClamped and DoesEntityExist(entity)
            end,
        },
        {
            num      = 6,
            name     = "unclamp_wheel",
            icon     = "fas fa-lock-open",
            label    = "Remove Wheel Clamp (police)",
            job      = { ["police"] = 0 },
            distance = 3.0,
            action = function(data)
                local entity = getEntity(data)
                local vehicle = entity
                TriggerServerEvent("mh-parking:server:toggleClamp", SafeNetId(vehicle), false)
            end,
            canInteract = function(data)
                local entity = getEntity(data)
                local state = Entity(entity).state
                return state and state.isClamped
            end,
        },
        {
            num      = 7,
            name     = "impound_vehicle",
            icon     = "fas fa-truck-pickup",
            label    = "Impound vehicle (police)",
            job      = { ["police"] = 0 },
            distance = 5.0,
            action = function(data)
                local entity = getEntity(data)
                local plate = GetPlate(entity)
                TriggerServerEvent('mh-parking:impound', plate)
                SetEntityAsMissionEntity(entity, true, true)
                DeleteEntity(entity)
                lib.notify({title = "Impound", description = "Voertuig " .. plate .. " in beslag genomen", type = "success"})
            end,            
            canInteract = function(data)
                local entity = getEntity(data)
                local state = Entity(entity).state
                return state and state.isParked
            end,
        },
    }
end

CreateThread(function()
    Wait(2000)
    if next(Target) then
        local options = createParkingOptions()
        for _, opt in ipairs(options) do if Target.name == "ox_target" then opt.onSelect = opt.action end end
        Target.addGlobalVehicle(options)
    end
end)
