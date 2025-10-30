<p align="center">
    <img width="140" src="https://icons.iconarchive.com/icons/iconarchive/red-orb-alphabet/128/Letter-M-icon.png" />  
    <h1 align="center">Hi 👋, I'm MaDHouSe</h1>
    <h3 align="center">A passionate allround developer </h3>    
</p>

<p align="center">
    <a href="https://github.com/MaDHouSe79/mh-parking/issues">
        <img src="https://img.shields.io/github/issues/MaDHouSe79/mh-parking"/> 
    </a>
    <a href="https://github.com/MaDHouSe79/mh-parking/watchers">
        <img src="https://img.shields.io/github/watchers/MaDHouSe79/mh-parking"/> 
    </a> 
    <a href="https://github.com/MaDHouSe79/mh-parking/network/members">
        <img src="https://img.shields.io/github/forks/MaDHouSe79/mh-parking"/> 
    </a>  
    <a href="https://github.com/MaDHouSe79/mh-parking/stargazers">
        <img src="https://img.shields.io/github/stars/MaDHouSe79/mh-parking?color=white"/> 
    </a>
    <a href="https://github.com/MaDHouSe79/mh-parking/blob/main/LICENSE">
        <img src="https://img.shields.io/github/license/MaDHouSe79/mh-parking?color=black"/> 
    </a>      
</p>

<p align="center">
    <img src="https://komarev.com/ghpvc/?username=MaDHouSe79&label=Profile%20views&color=3464eb&style=for-the-badge&logo=star&abbreviated=true" alt="MaDHouSe79" style="padding-right:20px;" />
</p>

# My Youtube Channel
- [Subscribe](https://www.youtube.com/@MaDHouSe79) 

# MH Park System (QB/QBX/ESX) by MaDHouSe79
- With auto park and unpark vehicles when you press `F`.
- VIP system included
- Vehicle spawns are server side
- Automatic police impound.
- Park Timer, when the timer is 0 it will be impounded.

# Dependencies (QB/QBX/ESX)
- [oxmysql](https://github.com/overextended/oxmysql/releases/tag/v1.9.3)
- [ox_lib](https://github.com/overextended/ox_lib/releases)

# Installation
- Step 2: Copy the directory `mh-parking` to `resources/[mh]/`.
- Stap 3: Add `ensure [mh]` in `server.cfg` below `ensure [defaultmaps]`.
- Step 4: Edit the config file in `shared/config.lua` to your needs.
- Step 5: Retart your server.

# Admin Commands
- `/addparkvip [id] [amount]` Add a player as vip, the amount is the max total this player can park vehicles
- `/removeparkvip [id]` Remove a vip player
- `/togglesteerangle` Disable or Enable the save teer angle when park
- `/parkresetall` Reset all players vehicles.
- `/parkresetplayer [id]` Reset all player vehicles for this player.

# Admin Create/Delete Parking Lots
- `/toggledebugpoly` You need to to this so you can see how it is placed.
- `/createpark [player_id] [filename] [job] [label]` To create a prived parking spot.
- `/deletepark [zone id] [filename]`To delete a created parking pot.

# User Commands
- `/parkmenu` To Open the parked vehicle menu
- `/park or F5 or F` To park of drive your vehicle.
- `/toggleparktext` Disable or Enable the text above the parked vehicles (for streamers)

# Rewrite Vehicle File
- When you do this you get a file in de root folder inside `mh-parking`, the new file is `vehicles.lua`
- You need to copy this data to the `shared/vehicles.lua` file in `mh-parking` folder.
- When you did that you need to set `Config.RewriteVehicleFile` to `false` again.

# You can not restart
- There is no onstart but only a onjoin check when a player jois the server.
- so when something does not work you need te restart your game.

# Add Code in your garage/vehicleshop scripts
- You need to this inder to make parking work propperly,
- add this below in your config file of your garage script,
- go to your client file and add this after you spawn the vehcle.
- `vehicle` can also by `veh` in your script.
```lua
SetVehicleKeepEngineOnWhenAbandoned(vehicle, true)
```

# ScreenShots
![foto](https://github.com/MaDHouSe79/mh-parking/blob/main/screenshots/1.png)
![foto](https://github.com/MaDHouSe79/mh-parking/blob/main/screenshots/2.png)
![foto](https://github.com/MaDHouSe79/mh-parking/blob/main/screenshots/3.png)
![foto](https://github.com/MaDHouSe79/mh-parking/blob/main/screenshots/4.png)
![foto](https://github.com/MaDHouSe79/mh-parking/blob/main/screenshots/5.png)

# LICENSE
[GPL LICENSE](./LICENSE)<br />
&copy; [MaDHouSe79](https://www.youtube.com/@MaDHouSe79)