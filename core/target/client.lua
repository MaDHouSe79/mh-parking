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
            label       = Lang:t('vehicle.info'),
            distance    = 3.0,
            action = function(data)
                local entity = getEntity(data)
                TriggerEvent('mh-parking:infomenu', entity)
            end,
            canInteract = function(data)
                local entity = getEntity(data)
                return DoesEntityExist(entity) and IsEntityAVehicle(entity)
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

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    if Target.name == "ox_target" then
        exports.ox_target:removeGlobalObject("parking_info")
    elseif Target.name == "qb-target" or Target.name == "qtarget" then
        exports['qb-target']:RemoveGlobalObject("parking_info")
    end
end)