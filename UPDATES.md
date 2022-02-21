## ---------------------------------------------Updates------------------------------------------------

## Update for optimization 👊😉👍 21-2-2022
- 👉 Change the way you unpark your vehicle, vehicles dont de-spawn anymore.
- 👉 Remove a lot from config file that was not needed anymore. 
- 👉 Change the way vehicle spawning works, just for optimization.
- 👉 No more blinking when you unpark you vehicle, unlock your vehicle go in and hit F5 and go. 
- 👉 Minimal Speed To Park addedd, players now have to stop before parking.
- 👉 Refresh vehicles, check if vehicels are on the ground i a amount of radius. default 50, higher is bigger radius.


## YOU CAN ALSO REMOVE THIS OLD CODE, you normal had to add this for this mod but this is no longer needed.
## 👇 REMOVE old code in resources/[qb]/qb-vehiclekeys/client/main.lua.
````lua
RegisterNetEvent('vehiclekeys:client:SetVehicleOwnerToCitizenid', function(plate, citizenid)
    TriggerServerEvent('vehiclekeys:server:SetVehicleOwnerToCitizenid', plate, citizenid)
end)
````

## 👇 Remove old code in resources/[qb]/qb-vehiclekeys/server/main.lua.
````lua
RegisterNetEvent('vehiclekeys:server:SetVehicleOwnerToCitizenid', function(plate, citizenid)
    if VehicleList then
        local val = VehicleList[plate]
        if val then
            VehicleList[plate].owners[citizenid] = true
        else
            VehicleList[plate] = { owners = {} }
            VehicleList[plate].owners[citizenid] = true
        end
    else
        VehicleList = {}
        VehicleList[plate] = { owners = {} }
        VehicleList[plate].owners[citizenid] = true
    end
end)
````

## 😎 Special thanks for the people who helping me with testing 👊😉👍
- 💪 Jazerra
- 💪 ameN
- 💪 MulGirtab
- 💪 DannyJ
- 💪 MasonJason310
- 💪 Enxsistanz
- 💪 !ExiledVibe!
- 💪 FARRUKO

## 🙈 Youtube & Discord & Twitter 👊😉👍
- [Youtube](https://www.youtube.com/channel/UC6431XeIqHjswry5OYtim0A)
- [Discord](https://discord.gg/cEMSeE9dgS)
- [Twitter](https://twitter.com/madhouse1979)
