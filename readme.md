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
- Park Timer, when the timer is 0 it wil bt impounded.

# Dependencies (QB/QBX/ESX)
- [oxmysql](https://github.com/overextended/oxmysql/releases/tag/v1.9.3)
- [ox_lib](https://github.com/overextended/ox_lib/releases)

# Installation
- Step 1: First stop your server.
- Step 2: Copy the directory `mh-parking` to `resources/[mh]/`.
- Stap 3: Add `ensure [mh]` in `server.cfg` below `ensure [defaultmaps]`.
- Stap 4: For QBX you need to set SetConvarReplicated('game_enableFlyThroughWindscreen', 'true') to false in `qbx_seatbelt/server/main.lua` line 1
- Step 5: Start your server.

# Admin Commands
- `/addparkvip [id] [amount]` Add a player as vip, the amount is the max total this player can park vehicles
- `/removeparkvip [id]` Remove a vip player
- `/togglesteerangle` Disable or Enable the save teer angle when park
- `/parkresetall` Reset all player vehicles.
- `/parkresetplayer [id]` Reset all vehicles for this player.

# User Commands
- `/park or F5` To park of drive your vehicle.
- `/parkmenu` To Open the parked vehicle menu
- `/toggleparktext` Disable or Enable the text above the parked vehicles (for streamers)

# LICENSE
[GPL LICENSE](./LICENSE)<br />
&copy; [MaDHouSe79](https://www.youtube.com/@MaDHouSe79)