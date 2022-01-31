-- Shared By Server And Client
QBCore                 = exports['qb-core']:GetCoreObject()

-- Client Only
PlayerData             = {}
PlayerJob              = {}
LocalVehiclesList      = {}
GlobalVehiclesList     = {}
SpawnedVehicles        = false
isUsingParkCommand     = false
IsDeleting             = false
onDuty                 = false
inParking              = false
Citizenid              = nil
LastUsedPlate          = nil
parkName               = nil
vehicleEntity          = nil
action                 = 'none'

-- Server Only
VehiclesList           = {}

-- Shared By Server And Client
PhoneNotification      = Config.PhoneNotification
UseParkingSystem       = Config.UseParkingSystem
OnlyAllowVipPlayers    = Config.OnlyAllowVipPlayers
HideParkedVehicleNames = Config.HideParkedVehicleNames
