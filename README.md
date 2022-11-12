<p align="center">
    <img width="140" src="https://icons.iconarchive.com/icons/iconarchive/red-orb-alphabet/128/Letter-M-icon.png" />  
    <h1 align="center">Hi 👋, I'm MaDHouSe</h1>
    <h3 align="center">A passionate allround developer </h3>    
</p>
<p align="center">
  <a href="https://github.com/MaDHouSe79/mh-parking/issues">
    <img src="https://img.shields.io/github/issues/MaDHouSe79/mh-parking"/> 
  </a>
  <a href="https://github.com/MaDHouSe79/mh-parking/network/members">
    <img src="https://img.shields.io/github/forks/MaDHouSe79/mh-parking"/> 
  </a>  
  <a href="https://github.com/MaDHouSe79/mh-parking/stargazers">
    <img src="https://img.shields.io/github/stars/MaDHouSe79/mh-parking"/> 
  </a>
  
  <a href="https://github.com/MaDHouSe79/mh-parking/blob/main/LICENSE">
        <img src="https://img.shields.io/github/license/MaDHouSe79/mh-parking"/> 
    </a>
</p>

<p align="center">
  <img alig src="https://github-profile-trophy.vercel.app/?username=MaDHouSe79&margin-w=15&column=6" />
</p>


## mh-parking 
- An Advanced Parking System build by MaDHouSe79.


subscribe to my channel It helps the channel grow
[Youtube](https://www.youtube.com/c/MaDHouSe79)


## 📸 Screenshot 👊😁👍
![foto1](https://www.madirc.nl/fivem/new7.png)
![foto1](https://www.madirc.nl/fivem/new1.png)
![foto1](https://www.madirc.nl/fivem/new2.png)
![foto1](https://www.madirc.nl/fivem/new3.png)
![foto1](https://www.madirc.nl/fivem/new4.png)
![foto1](https://www.madirc.nl/fivem/new5.png)
![foto1](https://www.madirc.nl/fivem/new9.png)
![foto1](https://www.madirc.nl/fivem/new10.png)
![foto1](https://www.madirc.nl/fivem/foto1.png)
![foto1](https://www.madirc.nl/fivem/foto9.png)
![foto1](https://www.madirc.nl/fivem/foto11.png)

## 🎥 Video 👊😁👍
[![Watch the video1](https://www.madirc.nl/fivem/video.png)](https://youtu.be/cLCthqPRLQQ)
[![Watch the video1](https://www.madirc.nl/fivem/foto11.png)](https://youtu.be/QRJZ2r7FD4w)

## 💪 Dependencies
- ✅ [oxmysql](https://github.com/overextended/oxmysql/releases/tag/v1.9.3)
- ✅ [qb-core](https://github.com/qbcore-framework/qb-core)

## 💪 Optional
- ✅ [interact-sound](https://github.com/qbcore-framework/interact-sound)

## 🙏 How to install and do not forget anything, or it will not work, or give many errors.
- 👉 Step 1: First stop your server. 😁
- 👉 Step 2: Copy the directory mh-parking to resources/[qb]/
- 👉 Step 3: Add the player_parking.sql with 2 tables to your correct database.
- 👉 Step 4: Start your server.  
- 👉 Step 5: Add your self or other as vip, you can use the command: /park-addvip [id]
- 👉 Step 6: Most important step -> Enjoy 👊😎👍

## 🎮 Commands
- 👉 Typ "/park" to park or drive your vehicle where you are at that moment. (Users and Admins)
- 👉 Typ "/park-names if you want to display the names ontop of the vehicle that is parked. (Users and Admins)
- 👉 Typ "/park-lotnames if you want to display the names of the parking lots. (Users and Admins)
- 👉 Typ "/park-cmenu" to create a new parking space (Admin only)
- 👉 Typ "/park-bmode" to go in to build mode (Admin only)
- 👉 Typ "/park-system" if you want to turn on or off the system. (Admin Only)
- 👉 Typ "/park-usevip" to turn on and of the vip system
- 👉 Typ "/park-addvip [id]" if you want to add a vip. (Admin Only)
- 👉 Typ "/park-removevip [id]" if you want to remove a vip. (Admin Only)
- 👉 If you want to use the F5 button, you must add it to your /binds and add on F5 the word "park"

## Unpark trigger event (use this client side)
- this only unpark the vehicle, it does not delete the entity from the gameworld.
```lua
TriggerServerEvent('mh-parking:server:unpark', plate)
```

## 👇 To keep things nice and clean for the qb-core system and database.
- ✅ Go to resources[qb]/qb-core/server/player.lua around line 506, and find, local playertables = {}. 
- ✅ This is, if we want to delete a character, we also want to delete the parked vehicles in the database,
- ✅ Place the line below at the bottom in playertables (there are more insite), so place this one at the bottom.
````lua
{ table = 'player_parking' },
{ table = 'player_parking_vips' },
````

## 🐞 Any bugs issues or suggestions, let my know. 👊😎

## 🙈 Youtube & Discord
- [Youtube](https://www.youtube.com/@MaDHouSe79) for videos
- [Discord](https://discord.gg/cEMSeE9dgS)
