## QB-parking Version 1.0 Created by MaDHouSe (Coming Soon)

This is a very awesome parking mod, that i specially made for [qb-core](https://github.com/qbcore-framework/qb-core) 

This is just how you park in real live 😁 so park anywhere you want 👊😁👍

This mod is more intended for large servers, with VIP players, you can give this player an extra feature, to let them park in front of there own house,
or you can use this, if you are a youtuber, and you don't want to mesh up and get your scene back togetter again, and getting al your vehicles from garage back on it place,
you can also use this mod, so your scene stays how you put it, just a little thing I thought of what you also can do with this mod. 😁

This mod is also good if players crashes or if the server gets a reboot, and if you have permossion to park,
and you have parked your vehicle, then you never have to get your vehicle from the garage again, but if you do forget to park your vehicle, your vehicle can be found in garage or impound.

This is my second mod i make public, so please by kind to my 😁 i still have much to learn.



## 📸 Screenshots 👊😁👍
![foto1](https://www.madirc.nl/fivem/foto1.png)
![foto2](https://www.madirc.nl/fivem/foto2.png)
![foto3](https://www.madirc.nl/fivem/foto3.png) 
![foto4](https://www.madirc.nl/fivem/foto5.png) 
![foto4](https://www.madirc.nl/fivem/foto6.png) 
![foto4](https://www.madirc.nl/fivem/foto8.png) 



## 🎥 Videos 👊😁👍
[![Watch the video1](https://www.madirc.nl/fivem/video.png)](https://youtu.be/cLCthqPRLQQ)
[![Watch the video2](https://www.madirc.nl/fivem/foto1.png)](https://www.youtube.com/watch?v=bSRZpbHlDkk)

## 💪 Dependencies
- ✅ [oxmysql](https://github.com/overextended/oxmysql/releases/tag/v1.9.3)
- ✅ [qb-core](https://github.com/qbcore-framework/qb-core)
- ✅ [qb-phone](https://github.com/qbcore-framework/qb-phone)
- ✅ [qb-garages](https://github.com/qbcore-framework/qb-garages)
- ✅ [qb-vehiclekeys](https://github.com/qbcore-framework/qb-vehiclekeys) 


## 🍀 Features
- ✅ Easy to install and use
- ✅ QB-Phone notifications
- ✅ Admin Controll like disable or enable the system or set it to only allowed for vip players only.
- ✅ User Controll like displaying text on screen.
- ✅ Police can, if thay want, always see who owns the vehicle by using /parknames



## 🎮 How To Use
- 👉 Typ "/park" to park or drive your vehicle where you are at that moment. (Users and Admins)
- 👉 Typ "/parknames if you want to display the names ontop of the vehicle that is parked. (Users and Admins)
- 👉 Typ "/parkvip" if you only want to use vip parking. (Admin Only)
- 👉 Typ "/parksystem" if you want to turn on or off the system. (Admin Only)



## ⚙️ Settings
- 👉 Change the max cars that can park in the world space, change the amount from Config.Maxcarparking in the config.lua file. 
- 👉 Vip users can be added in shared/config.lua => Config.VipPlayers = {} only if you use the vip option.
- 👉 Knowledge of programming and use your brains cause i'am not going to help you install this mod, cause it's very easy to do.



## 💯 What i recommend for using this mod
- 👉 I recommend to use this mod only for vip players or for players who are most online on you server.
- 👉 Your players will love this extra feature, if they can park there own vehicle in front of there house or clubs. 
- 👉 Try not to spawn too many vehicles in world space, this can cause issues and hiccups. 
- 👉 It is also recommended to have a good computer/server to use this mod, cause you will need it.
- 👉 To keep the server nice and clean for everyody, use this system only for vip players. 



## 💯 I tested this mod on a computer/server with the following settings
- ✅ Prossessor: I7 12xCore
- ✅ Memory: 16 gig memory
- ✅ Graphics: GTX 1050 TI 4GB



## 🙏 Don't do this...
- 👉 DO NOT park your vehicles on roofs or that kind of stuff, just don't do it, it will work, but it breaks the mod.
- 👉 Just use the recommended parking spots in the world like you do in real life.
- 👉 You can do of course just park at your own house on a parking spot to keep it nice and clean for everyone.



## 💯 Polices and Mechanics Impound Trigger
- ✅ You can impound this vehicles, if a user park their vehicle incorrectly, and you added the trigger correctly...
- ✅ You can give a fine, and then if you want, you can still impound this vehicle.
- ✅ If a player want, they can enable the hud to see the name and plate of this persons parked vehicle, by using /parknames.
- ✅ The Polices and Mechanics client side trigger event, for the police or mechanic to impount a vehicle correctly. 
- ✅ You MUST add this to your police impound client function or client trigger event.
- 💥 DONT FORGET THIS PART BELOW, OR PLAYERS CAN GET THERE VEHICLE AT THE GARAGE FOR FREE.
````
TriggerEvent('qb-parking:client:impoundVehicle', vehicle)
````


## 👇 Extra Code in resources/[qb]/qb-vehicleshop/client.lua at the bottom.
```
RegisterNetEvent('qb-vehicleshop:client:reloadShops', function(source)
    for k,v in pairs(Config.Shops) do
        for i = 1, #Config.Shops[k]['ShowroomVehicles'] do
            local model = GetHashKey(Config.Shops[k]["ShowroomVehicles"][i].defaultVehicle)
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(0)
            end
            local veh = CreateVehicle(model, Config.Shops[k]["ShowroomVehicles"][i].coords.x, Config.Shops[k]["ShowroomVehicles"][i].coords.y, Config.Shops[k]["ShowroomVehicles"][i].coords.z, false, false)
            SetModelAsNoLongerNeeded(model)
            SetEntityAsMissionEntity(veh, true, true)
            SetVehicleOnGroundProperly(veh)
            SetEntityInvincible(veh,true)
            SetVehicleDirtLevel(veh, 0.0)
            SetVehicleDoorsLocked(veh, 3)
            SetEntityHeading(veh, Config.Shops[k]["ShowroomVehicles"][i].coords.w)
            FreezeEntityPosition(veh,true)
            SetVehicleNumberPlateText(veh, 'BUY ME')
        end    
        createVehZones(k)
    end
end)    
```


## 👇 Extra Code in resources/[qb]/qb-vehiclekeys/server/main.lua.
````
RegisterNetEvent('vehiclekeys:client:SetVehicleOwnerToCitizenid', function(plate, citizenid)
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


## 👇 Extra Code in resources/[qb]/qb-vehiclekeys/client/main.lua.
````
RegisterNetEvent('vehiclekeys:client:SetVehicleOwnerToCitizenid', function(plate, citizenid)
    TriggerServerEvent('vehiclekeys:client:SetVehicleOwnerToCitizenid', plate, citizenid)
end)
````


## 👇 To keep things nice and clean for the qb-core system and database.
- ✅ Go to resources[qb]/qb-core/server/player.lua Line:506, find: local playertables = {}. 
- ✅ Place at the bottom in playertables (there are more insite), so place this one at the bottom,
- ✅ This is, if we want to delete a character, we also want to delete the parked vehicles in the database,
- ✅ to keep things nice and clean.

## resources[qb]/qb-core/server/player.lua Line:506
````
{ table = 'player_parking' },
````


## ⚙️ Database
````
CREATE TABLE `player_parking`  (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `citizenname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `plate` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `time` bigint(20) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;
````


## ⚙️ To get a other languages
- 1: copy a file from the locales directiry
- 2: rename this file for example fr.lua or sp.lua
- 3: translate the lines in the file to your language
- 4: go to config.lua and replace nl with your language filename name
- 5: you now have added a new language to the system, enjoy 😎


## 🙈 Subscribe & Discord
- [Subscribe](https://www.youtube.com/channel/UC6431XeIqHjswry5OYtim0A)
- [Discord](https://discord.gg/cEMSeE9dgS)



## 🐞 Any bugs or issues, let my know, and i try to fix it.
Keep it nice and clean for everybody and have fun with this awesome parking mod 😎
