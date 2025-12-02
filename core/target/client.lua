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
            event       = "mh-parking:infomenu",
            type        = "client",
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
            name     = "clamp_wheel",
            icon     = "fas fa-lock",
            label    = "Add Wheelclamp (police)",
            event    = "mh-parking:clampWheel",
            type     = "client",
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
            num      = 3,
            name     = "unclamp_wheel",
            icon     = "fas fa-lock-open",
            label    = "Remove Wheel Clamp (police)",
            event    = "mh-parking:unclampWheel",
            type     = "client",
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
            num      = 4,
            name     = "impound_vehicle",
            icon     = "fas fa-truck-pickup",
            label    = "Impound vehicle (police)",
            type     = "server",
            event    = "mh-parking:server:impound",
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