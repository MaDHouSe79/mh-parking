## ---------------------------------------------Updates------------------------------------------------
## Added 👊😉👍 3-2-2022
- ✔️ Added: Trigger for if you are using a cartief or picklock script
- ✔️ Changes: i change the directories and added a few functions.

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
- use this to update your player_parking table:
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
