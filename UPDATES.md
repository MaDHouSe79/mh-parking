## ---------------------------------------------Updates------------------------------------------------

## You have to add a new Database Table to your database
```php
CREATE TABLE IF NOT EXISTS `player_parking_vips` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `citizenname` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
```
## Added 👊😉👍 4-2-2022
- ✔️ You can now add/remove a player as vip by command.
- ✔️ A player can park right after you have add this player as vip.
- ✔️ If the player is not online, you have to remove it from the database (player_parking_vips) yourself.
- ✔️ Aslong this player don't unpart this vehicle the vehicle stays parked, untill the player unpark it.
- ✔️ When unparked the player is unable to park again and he must use the garage to store his vehicle.

## New commands
- /park-addvip [id] to add a online player as vip       (Admin Only)
- /park-removevip [id] to remove a online player ad vip (Admin Only)

## Extra info
- The id is not the citizenid but the ingame player id,
- so if this user had the is 2 you use the 2 as id to add this player as vip,
- the same for removeing this player, but this player has to be online or you have to remove it by hand from the database,
- 👉👉👉 Ow and dont forget to add your self as vip or you cant not park 😉👍
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


## To Fix The qb-garages garage and impound menus
- This code has to be at lines 467 to 468 
- Go to resources/[qb]/qb-garages/client/main.lua line 468 and at the end of this line press enter,
```lua
elseif v.state == 3 then                                                   -- this has to be on line 467
    v.state = Lang:t("info.parked")                                        -- this has to be on line 468
```

- This code has to be at lines 621 to 622
- Go to resources/[qb]/qb-garages/client/main.lua line 619 and at the end of this line press enter,
```lua
elseif vehicle.state == Lang:t("info.parked") then                         -- this has to be on line 621
    QBCore.Functions.Notify(Lang:t("error.parked_outsite"), "error", 4000) -- this has to be on line 622
```

- Important!! add the language, go to resources/[qb]/qb-garages/locales/
- place this in al the languages files, or the language that you use at the moment.
```lua
parked_outsite = "You have parked your vecihle outsite...",                -- this wil be line 11 in every language file
parked         = "Parked Outside",                                         -- this wil be line 23 in every language file
```

## 🙈 Youtube & Discord & Twitter 👊😉👍
- [Youtube](https://www.youtube.com/channel/UC6431XeIqHjswry5OYtim0A)
- [Discord](https://discord.gg/cEMSeE9dgS)
- [Twitter](https://twitter.com/madhouse1979)
