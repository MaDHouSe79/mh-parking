## ---------------------------------------------Updates------------------------------------------------
## Add And Fix 👊😉👍 12-2-2022
- ✔️ Add Reset State: on server start, vehicles that are not parked and are added to the parking database will be removed now.
- ✔️ Fix Floating Vehicles: it can happen, that you see that the vehicle get placed on the ground. (the radius is 100 for this event)
- ✔️ Vehicles are now spawn with damage, if you park it with damage.
- ✔️ Finally i fixed the fuel.


✔️ Again this time you don't have to do anything, just update qb-parking, and you ready to go 👊😉👍

## 😎 Special thanks for helping me with testing 👊😉👍
- 💪 Jazerra
- 💪 ameN
- 💪 MulGirtab
- 💪 DannyJ
- 💪 MasonJason310
- 💪 Enxsistanz
- 💪 !ExiledVibe!
- 💪 FARRUKO

## ---------------------------------------------Updates------------------------------------------------
- ✔️ Triggers:  Added a trigger for other scripts, to unpark the vehicles if needed.
- ✔️ Change: I change from entity to plate.

if you are using a other version or you had already one of this triggers below running,
you must change the vehicle to plate, cause we olny use the plate now and not the hole entity.

## Stolen Trigger, when the vehicle gets stolen by a other player with picklock
```lua
 TriggerEvent("qb-parking:client:stolen", plate) 
```

## Impound Trigger, to unpark the vehicle.
```lua
 TriggerEvent("qb-parking:client:impound", plate) 
```

## Unpark Trigger, to unpark the vehicle, just for other garages scripts.
```lua
 TriggerEvent("qb-parking:client:unpark", plate) 
```

## ---------------------------------------------Updates------------------------------------------------
## Added And Fixes 👊😉👍 9-2-2022
- ✔️ Triggers:  Added a trigger for other scripts, to unpark the vehicles if needed.
- ✔️ Lock:      You have to unlock the vehicle with [L], cause you alse lock it when you park the vehicle.
- ✔️ Names:     Parked car names are now correctly visible for police and owner. (for police only if onduty)
- ✔️ Commands:  /park-system & /park-names is now working correct, and display the correct state. 
- ✔️ Drive:     You can not drive away anymore when toggle the engine on if the vehicle is parked.
- ✔️ Inventory: Is not possible anymore, you have you unlock your vehicle to get access.


## Stolen Trigger, when the vehicle gets stolen by a other player with picklock
```lua
 TriggerEvent("qb-parking:client:stolen', plate) 
```

## Impound Trigger, to unpark the vehicle.
```lua
 TriggerEvent("qb-parking:client:impound', plate) 
```

## Unpark Trigger, to unpark the vehicle, just for other script if needed.
```lua
 TriggerEvent("qb-parking:client:unpark', plate) 
```

## ---------------------------------------------Updates------------------------------------------------


## You have to add a new Database Table to your database
```sql
CREATE TABLE IF NOT EXISTS `player_parking_vips` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `citizenname` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `maxparking` int(5) NOT NULL DEFAULT 0,
  `hasparked` int(5) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
```
## Added 👊😉👍 4-2-2022
- ✔️ You can now add/remove a player as vip by command.
- ✔️ A player can park right after you have add this player as vip.
- ✔️ If the player is not online, you have to remove it from the database (player_parking_vips) yourself.
- ✔️ Aslong this player don't unpart this vehicle the vehicle stays parked, untill the player unpark it.
- ✔️ When unparked the player is unable to park again and he must use the garage to store his vehicle.

## New commands
- /park-addvid [id] to add a online player as vip       (Admin Only)
- /park-removevip [id] to remove a online player ad vip (Admin Only)

## Extra info
- The id is not the citizenid but the ingame player id,
- so if this user had the id 2 you use the 2 as id to add this player as vip,
- the same for removeing this player, but this player has to be online or you have to remove it by hand from the database,
- 👉👉👉 DONT FOTGET TO ADD YOUR SELF AS VIP, or you can't park 😉👍
Enjoy 👊😉👍


## ---------------------------------------------Updates------------------------------------------------
## Added 👊😉👍 3-2-2022
- ✔️ Added: Trigger for if you are using a cartief or picklock script
- ✔️ Changes: i change the directories and added a few functions.
- ✔️ Major cleanup and code improvement, speed up the parking, instance spawn after you get out of the vehicle after parking.
- ✔️ Added Animation when parking the vehicle, remote control animation and sound.

## 😎 Special thanks to ameN 👊😉👍

## ---------------------------------------------Updates------------------------------------------------

## Added 👊😉👍 2-2-2022
- ✔️ Added: Engine start after pressing F5 or using /park command
- ✔️ Added: You can now only park when you vehicle is complety stopped, so 0 speed.
- ✔️ Added: If you are using a diffrent fuel script, you can changed this in the config file. 
- ✔️ Added: qb-parking update check, to see if your qb-parking is up to date.
- ✔️ Added: New language, you can also easy add your one language, and make a pull reqwuest on githud.

## 🥵 You have to add more code to your qb-garage script.
- ✔️ This to make the qb-parking work with qb-garages garage and impound menus.

## 🥵 You have to update your database 
- 👇 Use this to update your player_parking table
```php
ALTER TABLE `player_parking` ADD `fuel` int(15) NOT NULL DEFAULT 0
```

## The Update Check
- ✔️ Keep qb-parking up to date to avoid any issues. you can turn this off in de config.lua, but this is not recommended.

## 🐞 Fixed bugs.
- ✔️ When the server start, players could drive away without unparking the vecihle.
- ✔️ Some other small issues.

## 🤬 Not fixed yet, i'm on it 👍
- ❌ The Fuel is a issue, i can't fix this right now, cause an other script in qbcore is doeing this, and even if i force it.

## 😎 Special thanks to MulGirtab. 👊😉👍
- Who help me to test qb-parking with the server restart issues, You're awesome thank you!!

## 🙈 Youtube & Discord & Twitter 👊😉👍
- [Youtube](https://www.youtube.com/channel/UC6431XeIqHjswry5OYtim0A)
- [Discord](https://discord.gg/cEMSeE9dgS)
- [Twitter](https://twitter.com/madhouse1979)
