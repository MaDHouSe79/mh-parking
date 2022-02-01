## - Update 2 -------------------------------------------------------------------------------------------------------

## Added 👊😉👍
- ✔️ Added: Engine start after pressing F5 or using /park command
- ✔️ Added: You can now only park when you vehicle is complety stopped, so 0 speed.
- ✔️ Added: If you are using a diffrent fuel script, you can changed this in the config file. 
- ✔️ Added: qb-parking update check, to see if your qb-parking is up to date.
- ✔️ Added: New language, you can also easy add you one language, and make a pull reqwuest on githud.

## 🥵 You have to add more code to your qb-garage script.
- ✔️ This to make the qb-parking work with qb-garages garage and impound menus.

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
- To this code, has to be at lines 469 to 470 
- Go to resources/[qb]/qb-garages/client/main.lua line 468 and at the end of this line press enter,
```
elseif v.state == 3 then -- this has to be on line 469
    v.state = Lang:t("info.parked") -- this has to be on line 470
```

- This code, has to be at lines 620 to 621
- Go to resources/[qb]/qb-garages/client/main.lua line 619 and at the end of this line press enter,
```
elseif vehicle.state == Lang:t("info.parked") then -- this has to be on line 620
    QBCore.Functions.Notify(Lang:t("error.parked_outsite"), "error", 4000) -- this has to be on line 621

```

- Important!! add the language, go to resources/[qb]/qb-garages/locales/
- place this in al the languages files, or the language that you use at the moment.
```
parked_outsite = "You have parked your vecihle outsite...", -- (this wil be line 10 in every language file)
parked         = "Parked Outside", -                        -- (this wil be line 22 in every language file)
```



## - Update 1 -------------------------------------------------------------------------------------------------------
- Lot off bugs fixed. 👊😁👍