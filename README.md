## QB-Parking
This is a very awesome parking mod, that i specially made for [qb-core](https://github.com/qbcore-framework/qb-core) 
This is just how you park in real live 😁 so park anywhere you want 👊😁👍
This mod is more intended for large servers, with VIP players, you can give this player an extra feature, to let them park in front of there own house, or you can use this, if you are a youtuber, and you don't want to mesh up and get your scene back togetter again, and getting al your vehicles from garage back on it place, you can also use this mod, so your scene stays how you put it, just a little thing I thought of what you also can do with this mod. 😁

This mod is also good if players crashes or if the server gets a reboot, and if you have permission to park,
and you have parked your vehicle, then you never have to get your vehicle from the garage again, but if you do forget to park your vehicle, your vehicle can be found in garage or impound.

This is my second mod i make public, so please by kind to my 😁 i still have much to learn.

## Read The Updates.md for updates and changes.

## 📸 Screenshot 👊😁👍
![foto1](https://www.madirc.nl/fivem/foto1.png)


## 🎥 Video 👊😁👍
[![Watch the video1](https://www.madirc.nl/fivem/video.png)](https://youtu.be/cLCthqPRLQQ)


## 💪 Dependencies
- ✅ [oxmysql](https://github.com/overextended/oxmysql/releases/tag/v1.9.3)
- ✅ [qb-core](https://github.com/qbcore-framework/qb-core)
- ✅ [qb-phone](https://github.com/qbcore-framework/qb-phone)
- ✅ [qb-garages](https://github.com/qbcore-framework/qb-garages)
- ✅ [qb-vehiclekeys](https://github.com/qbcore-framework/qb-vehiclekeys)


## 💪 Optional
- ✅ [cc-fuel](https://github.com/CQC-Scripting/cc-fuel)
- ✅ you can also use other vehiclekey scripts, change this in the config file.


## 🙏 How to install and do not forget anything, or it will not work, or give many errors.
- 👉 Step 1: First stop your server. 😁
- 👉 Step 2: Copy the directory qb-parking to resources/[qb]/
- 👉 Step 3: Add the player_parking.sql with 2 tables to your correct database.
- 👉 Step 4: Add any recommended extra code what I say you should add.
- 👉 Step 5: If you are 100% sure, you have done all 4 steps correctly, go to step 6.😁
- 👉 Step 6: Add your self as admin in the config and you can use the command: /park-addvid [id]
- 👉 Step 7: Start your server. 
- 👉 Step 8: Most importent step -> Enjoy 👊😎👍


## 🍀 Features
- ✅ Easy to install and use
- ✅ QB-Phone notifications
- ✅ Admin Controll like disable or enable the system or set it to only allowed for vip players only.
- ✅ User Controll like displaying text on screen.
- ✅ Police can, if thay want, always see who owns the vehicle by using /park-names
- ✅ Players with user status will only see the model name of this vecihle, not the owners name or plate.
- ✅ 3D Waypoints is optional to use, uncommand the d3 waypoint in fxmanifest.lua file.
- 👉 Your players will love this extra feature, if they can park there own vehicle in front of there housees or clubs. 
- 👉 Your players can setup youtube scenes, and if they want, they can come back later, and your vechiles are still there.
- 👉 This is very usefull cause if you make a scene and somehthing goes wrong, then don't wory you vechiles are right there.
- 👉 And of course you should not forget to park your vehicle 👊😁👍


## 🎮 How To Use
- 👉 Typ "/park" to park or drive your vehicle where you are at that moment. (Users and Admins)
- 👉 Typ "/park-names if you want to display the names ontop of the vehicle that is parked. (Users and Admins)
- 👉 Typ "/park-notification" to turn on or of the phone notification (Users and Admins)
- 👉 Typ "/park-system" if you want to turn on or off the system. (Admin Only)
- 👉 Typ "/park-addvid [id]" if you want to add a vip. (Admin Only)
- 👉 Typ "/park-removevip [id]" if you want to remove a vip. (Admin Only)
- 👉 If you want to use the F5 button, you must add it to your /binds and add on F5 the word "park"


## ⚙️ Settings
- 👉 Change the max cars that can park in the world space, change the amount from Config.Maxcarparking in the config.lua file. 
- 👉 Vip users can be added in shared/config.lua => Config.VipPlayers = {} only if you use the vip option.
- 👉 Knowledge of programming and use your brains cause i'am not going to help you install this mod, cause it's very easy to do.


## 💯 What i recommend for using this mod
- 👉 I recommend to use this mod only for vip players or for players who are most online on you server.
- 👉 Try not to spawn too many vehicles in world space, this can cause issues and hiccups. 
- 👉 It is also recommended to have a good computer/server to use this mod, cause you will need it.
- 👉 To keep the server nice and clean for everyody, use this system only for vip players. 


## 💯 I tested this mod on a computer/server with the following settings
- ✅ Prossessor: I7 12xCore
- ✅ Memory: 16 gig memory
- ✅ Graphics: GTX 1050 TI 4GB


## 🙏 Don't do this...
- 👉 DO NOT park your vehicles on roofs or that kind of stuff, just don't do it, it will work, but it breaks the mod,
- 👉 use the recommended parking spots in the world like you do in real life,
- 👉 you can do of course just park at your own house on a parking spot to keep it nice and clean for everyone.


## 💯 Police and Mechanic Impound Trigger
- ✅ You can impound this vehicles, if a user park their vehicle incorrectly, and you added the trigger correctly...
- ✅ You can give a fine, and then if you want, you can still impound this vehicle.
- ✅ If a player as police, if they can enable the hud to see the name and plate of this persons parked vehicle, by using /park-names.
- ✅ The Polices and Mechanics client side trigger event, for the police or mechanic to impount a vehicle correctly. 
- ✅ You MUST add this to your police impound trigger event.


## 👇 Extra Code in resources/[qb]/qb-vehiclekeys/client/main.lua.
````lua
RegisterNetEvent('vehiclekeys:client:SetVehicleOwnerToCitizenid', function(plate, citizenid)
    TriggerServerEvent('vehiclekeys:server:SetVehicleOwnerToCitizenid', plate, citizenid)
end)
````

## 👇 Extra Code in resources/[qb]/qb-vehiclekeys/server/main.lua.
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

## 👇 To keep things nice and clean for the qb-core system and database.
- ✅ Go to resources[qb]/qb-core/server/player.lua around line 506, and find, local playertables = {}. 
- ✅ This is, if we want to delete a character, we also want to delete the parked vehicles in the database,
- ✅ Place the line below at the bottom in playertables (there are more insite), so place this one at the bottom.
````lua
{ table = 'player_parking' },
````


## ⚙️ Database Table
````sql
CREATE TABLE `player_parking`  (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `citizenname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `plate` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `fuel` int(15) NOT NULL DEFAULT 0,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `time` bigint(20) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;
````

````sql
CREATE TABLE IF NOT EXISTS `player_parking_vips` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `citizenname` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

````

## 🤬 If you have issues with impound and fuel, then replace this code.
- Go to resources[qb]/qb-policejob/client/job.lua go to line 122.
- Find 👇
````lua
function TakeOutImpound(vehicle)
    local coords = Config.Locations["impound"][currentGarage]
    if coords then
        QBCore.Functions.SpawnVehicle(vehicle.vehicle, function(veh)
            QBCore.Functions.TriggerCallback('qb-garage:server:GetVehicleProperties', function(properties)
                QBCore.Functions.SetVehicleProperties(veh, properties)
                SetVehicleNumberPlateText(veh, vehicle.plate)
                SetEntityHeading(veh, coords.w)
                exports['LegacyFuel']:SetFuel(veh, vehicle.fuel)
                doCarDamage(veh, vehicle)
                TriggerServerEvent('police:server:TakeOutImpound',vehicle.plate)
                closeMenuFull()
                TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
                SetVehicleEngineOn(veh, true, true)
            end, vehicle.plate)
        end, coords, true)
    end
end
````

- Replace 👇
````lua
function TakeOutImpound(vehicle)
    local coords = Config.Locations["impound"][currentGarage]
    if coords then
        QBCore.Functions.SpawnVehicle(vehicle.vehicle, function(veh)
            QBCore.Functions.TriggerCallback('qb-garage:server:GetVehicleProperties', function(properties)
                QBCore.Functions.SetVehicleProperties(veh, properties)
                SetVehicleNumberPlateText(veh, vehicle.plate)
                SetEntityHeading(veh, coords.w)
                exports['LegacyFuel']:SetFuel(veh, 100.0) -- The Change
                doCarDamage(veh, vehicle)
                TriggerServerEvent('police:server:TakeOutImpound',vehicle.plate)
                closeMenuFull()
                TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
                SetVehicleEngineOn(veh, true, true)
            end, vehicle.plate)
        end, coords, true)
    end
end
````

## 🦹‍♂️ if you use a picklock or car thief script you must use this trigger
```lua
TriggerEvent('qb-parking:client:stolenVehicle', vehicle)
```

## 👮‍♂️ Impound trigger
- Go to resources\[qb]\qb-policejob\client.lua line 332
- Find 👇 
````lua
RegisterNetEvent('police:client:ImpoundVehicle', function(fullImpound, price)
    local vehicle = QBCore.Functions.GetClosestVehicle()
    local bodyDamage = math.ceil(GetVehicleBodyHealth(vehicle))
    local engineDamage = math.ceil(GetVehicleEngineHealth(vehicle))
    local totalFuel = exports['LegacyFuel']:GetFuel(vehicle)
    if vehicle ~= 0 and vehicle then
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local vehpos = GetEntityCoords(vehicle)
        if #(pos - vehpos) < 5.0 and not IsPedInAnyVehicle(ped) then
            local plate = QBCore.Functions.GetPlate(vehicle)
            TriggerServerEvent("police:server:Impound", plate, fullImpound, price, bodyDamage, engineDamage, totalFuel)
            QBCore.Functions.DeleteVehicle(vehicle)
        end
    end
end)
````

- Replace 👇
```lua 
RegisterNetEvent('police:client:ImpoundVehicle', function(fullImpound, price)
    local vehicle = QBCore.Functions.GetClosestVehicle()
    local bodyDamage = math.ceil(GetVehicleBodyHealth(vehicle))
    local engineDamage = math.ceil(GetVehicleEngineHealth(vehicle))
    local totalFuel = exports['LegacyFuel']:GetFuel(vehicle)
    if vehicle ~= 0 and vehicle then
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local vehpos = GetEntityCoords(vehicle)
        if #(pos - vehpos) < 5.0 and not IsPedInAnyVehicle(ped) then
            local plate = QBCore.Functions.GetPlate(vehicle)
            TriggerEvent('qb-parking:client:impoundVehicle', vehicle) -- <--- impound qb-parking trigger
            TriggerServerEvent("police:server:Impound", plate, fullImpound, price, bodyDamage, engineDamage, totalFuel)
            QBCore.Functions.DeleteVehicle(vehicle)
        end
    end
end)
```


## 👇 To Fix The qb-garages garage and impound menus
- This code has to be at lines 467 to 468
- Go to resources/[qb]/qb-garages/client/main.lua line 468 and at the end of this line press enter,
```lua
elseif v.state == 3 then -- this has to be on line 467
    v.state = Lang:t("info.parked") -- this has to be on line 468
```

- This code has to be at lines 621 to 622
- 👇 Go to resources/[qb]/qb-garages/client/main.lua line 619 and at the end of this line press enter,
```lua
elseif vehicle.state == Lang:t("info.parked") then -- this has to be on line 621
    QBCore.Functions.Notify(Lang:t("error.parked_outsite"), "error", 4000) -- this has to be on line 622
```

- Important!! add the language, go to resources/[qb]/qb-garages/locales/
- 👇 place this in al the languages files, or the language that you use at the moment.
```lua
parked_outsite = "You have parked your vecihle outsite...", -- (this wil be line 11 in every language file)
parked         = "Parked Outside",                          -- (this wil be line 23 in every language file)
```


## ⚙️ To get a other languages.
- 1: copy a file from the resources[qb]/qb-parking/locales directory
- 2: rename this file for example fr.lua or sp.lua
- 3: translate the lines in the file to your language
- 4: you now have added a new language to the system, enjoy 😎


## 🐞 Any bugs issues or suggestions, let my know.
- If you have any suggestions or nice ideas let me know and we can see what we can do 👊😎
- Keep it nice and clean for everybody and have fun with this awesome qb-parking mod 😎👍


## 🙈 Youtube & Discord & Twitter
- [Youtube](https://www.youtube.com/channel/UC6431XeIqHjswry5OYtim0A)
- [Discord](https://discord.gg/cEMSeE9dgS)
- [Twitter](https://twitter.com/madhouse1979)
