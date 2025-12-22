-- ═══════════════════════════════════════════════════════════ --
--          MH-PARKING – 100% Statebag by MaDHouSe79           --
-- ═══════════════════════════════════════════════════════════ --
SV_Config = {}

SV_Config.distance = 500.0
SV_Config.freezeParkedVehicles = false
SV_Config.onlyAutoParkWhenEngineIsOff = true

SV_Config.UseSteerAnlgeParking = false -- when true is take some extra cpu, so keep it false if you dont need it

SV_Config.UseTimerPark = false -- when true players have a limit time to park
SV_Config.MaxTimeParking = 86400000 -- 24 hours, this wil stil work if SV_Config.UseTimerParkis false
SV_Config.PayTimeInSecs = 10
SV_Config.ParkPrice = 50
SV_Config.MoneySign = "€"

SV_Config.PayCompany = true -- if true all fines and parking feess goes to the police bank account
SV_Config.BankAccount = 'police'

SV_Config.UseAsVip = false
SV_Config.DefaultMaxParking = 10

SV_Config.PoliceJobs = {'police', 'sheriff'} -- Jobs than can add a clamp to a vehicle
SV_Config.ImpoundPrice = 500


SV_Config.ClampFine = 5000  -- fine for un clamping a wheel
SV_Config.ClampProp = "prop_spot_clamp" -- Attach clamp prop (or use a custom stream model)
SV_Config.ClampOffset = {
    x = 0.0, 
    y = 0.0, 
    z = -0.09, 
    rx = 0.5, 
    ry = 0.0, 
    rz = 0.5,
}

function PoliceImpound(plate, fullImpound, price, body, engine, fuel)
    TriggerEvent("police:server:Impound", plate, fullImpound, price, body, engine, fuel) -- qb
    -- or add your inpound trigger here
end