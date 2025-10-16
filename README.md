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

# Youtube Channel
- [Subscribe](https://www.youtube.com/@MaDHouSe79) 

# mh-parking
- Download V2 here [mh-parkingV2](https://github.com/MH-Scripts/mh-parkingV2)
* An Advanced Parking System build by MaDHouSe79.
* when you park, befor you hit F5 turn your steel and lock it at that position when parked.

subscribe to my channel It helps the channel grow
[Youtube](https://www.youtube.com/MaDHouSe79)


## 🎥 Video 👊😁👍
[![Watch the video1](https://www.madirc.nl/fivem/video.png)](https://youtu.be/cLCthqPRLQQ)
[![Watch the video1](https://www.madirc.nl/fivem/foto11.png)](https://youtu.be/QRJZ2r7FD4w)

## 💪 Dependencies
- ✅ [oxmysql](https://github.com/overextended/oxmysql/releases/tag/v1.9.3)
- ✅ [qb-core](https://github.com/qbcore-framework/qb-core)

## 💪 Optional
- ✅ [mh-autopark](https://github.com/MaDHouSe79/mh-autopark)
- ✅ [interact-sound](https://github.com/qbcore-framework/interact-sound)

## 🙏 How to install and do not forget anything, or it will not work, or give many errors.
- 👉 Step 1: First stop your server. 😁
- 👉 Step 2: Copy the directory mh-parking to resources/[mh]/
- 👉 Step 3: Read this file! (the database will install automaticly)
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


## 👉 NOTE DONT FORGET  TO ADD YOUR SELF AS VIP


## 💯 What i recommend for using this mod
- 👉 I recommend to use this mod only for vip players or for players who are most online on you server.
- 👉 Try not to spawn too many vehicles in world space, this can cause issues and hiccups. 
- 👉 It is also recommended to have a good computer/server to use this mod, cause you will need it.
- 👉 To keep the server nice and clean for everyody, use this system only for vip players. 


## 💯 I tested this mod on a computer/server with the following settings
- ✅ Prossessor: I7 12xCore
- ✅ Memory: 16 gig memory
- ✅ Graphics: GTX 1050 TI 4GB


## Unpark trigger event (use this server side)
- this only unpark the vehicle, it does not delete the entity from the gameworld.
- use this trigger in qb-policejob/server/main.lua, replace it with this (around line 888)
- 
```lua
RegisterNetEvent('police:server:Impound', function(plate, fullImpound, price, body, engine, fuel)
    local src = source
    price = price and price or 0
    if IsVehicleOwned(plate) then
        if not fullImpound then
            MySQL.query('UPDATE player_vehicles SET state = ?, depotprice = ?, body = ?, engine = ?, fuel = ? WHERE plate = ?', { 0, price, body, engine, fuel, plate })
            TriggerClientEvent('QBCore:Notify', src, Lang:t('info.vehicle_taken_depot', { price = price }))
        else
            MySQL.query('UPDATE player_vehicles SET state = ?, body = ?, engine = ?, fuel = ? WHERE plate = ?', { 2, body, engine, fuel, plate })
            TriggerClientEvent('QBCore:Notify', src, Lang:t('info.vehicle_seized'))
        end
        TriggerEvent('mh-parking:server:impound', plate) -- ADD HERE
    end
end)
```


## qb-garages (old) integration, this part is also for the phone app
- you need to find this in your qb-garages server and client file
```lua
if v.state == 0 then
    v.state = Lang:t("status.out")
elseif v.state == 1 then
    v.state = Lang:t("status.garaged")
elseif v.state == 2 then
    v.state = Lang:t("status.impound")
elseif v.state == 3 then
    v.state = "Parked outside"
end
```

## qb-garages (new) integration
- find and replace in `qb-garage/html/script.js` around line 43
- From
```lua
function populateVehicleList(garageLabel, vehicles) {
    const vehicleContainerElem = document.querySelector(".vehicle-table");
    const fragment = document.createDocumentFragment();

    while (vehicleContainerElem.firstChild) {
        vehicleContainerElem.removeChild(vehicleContainerElem.firstChild);
    }

    const garageHeader = document.getElementById("garage-header");
    garageHeader.textContent = garageLabel;

    vehicles.forEach((v) => {
        const vehicleItem = document.createElement("div");
        vehicleItem.classList.add("vehicle-item");

        // Vehicle Info: Name, Plate & Mileage
        const vehicleInfo = document.createElement("div");
        vehicleInfo.classList.add("vehicle-info");

        const vehicleName = document.createElement("span");
        vehicleName.classList.add("vehicle-name");
        vehicleName.textContent = v.vehicleLabel;
        vehicleInfo.appendChild(vehicleName);

        const plate = document.createElement("span");
        plate.classList.add("plate");
        plate.textContent = v.plate;
        vehicleInfo.appendChild(plate);

        const mileage = document.createElement("span");
        mileage.classList.add("mileage");
        mileage.textContent = `${v.distance}mi`;
        vehicleInfo.appendChild(mileage);

        vehicleItem.appendChild(vehicleInfo);

        // Finance Info
        const financeDriveContainer = document.createElement("div");
        financeDriveContainer.classList.add("finance-drive-container");
        const financeInfo = document.createElement("div");
        financeInfo.classList.add("finance-info");

        if (v.balance && v.balance > 0) {
            financeInfo.textContent = "Balance: $" + v.balance.toFixed(0);
        } else {
            financeInfo.textContent = "Paid Off";
        }

        financeDriveContainer.appendChild(financeInfo);

        // Drive Button
        let status;
        let isDepotPrice = false;

        if (v.state === 0) {
            if (v.depotPrice && v.depotPrice > 0) {
                isDepotPrice = true;

                if (v.type === "public") {
                    status = "Depot";
                } else if (v.type === "depot") {
                    status = "$" + v.depotPrice.toFixed(0);
                } else {
                    status = "Out";
                }
            } else {
                status = "Out";
            }
        } else if (v.state === 1) {
            if (v.depotPrice && v.depotPrice > 0) {
                isDepotPrice = true;

                if (v.type === "depot") {
                    status = "$" + v.depotPrice.toFixed(0);
                } else if (v.type === "public") {
                    status = "Depot";
                } else {
                    status = "Drive";
                }
            } else {
                status = "Drive";
            }
        } else if (v.state === 2) {
            status = "Impound";
        }

        const driveButton = document.createElement("button");
        driveButton.classList.add("drive-btn");
        driveButton.textContent = status;

        if (status === "Depot" || status === "Impound") {
            driveButton.style.backgroundColor = "#222";
            driveButton.disabled = true;
        }

        if (status === "Out") {
            driveButton.style.backgroundColor = "#222";
        }

        driveButton.onclick = function () {
            if (driveButton.disabled) return;

            const vehicleStats = {
                fuel: v.fuel,
                engine: v.engine,
                body: v.body,
            };

            const vehicleData = {
                vehicle: v.vehicle,
                garage: v.garage,
                index: v.index,
                plate: v.plate,
                type: v.type,
                depotPrice: v.depotPrice,
                stats: vehicleStats,
            };

            if (status === "Out") {
                fetch("https://qb-garages/trackVehicle", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json; charset=UTF-8",
                    },
                    body: JSON.stringify(v.plate),
                })
                    .then((response) => response.json())
                    .then((data) => {
                        if (data === "ok") {
                            closeGarageMenu();
                        } else {
                            return;
                        }
                    });
            } else if (isDepotPrice) {
                fetch("https://qb-garages/takeOutDepo", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json; charset=UTF-8",
                    },
                    body: JSON.stringify(vehicleData),
                })
                    .then((response) => response.json())
                    .then((data) => {
                        if (data === "ok") {
                            closeGarageMenu();
                        } else {
                            console.error("Failed to pay depot price.");
                        }
                    });
            } else {
                fetch("https://qb-garages/takeOutVehicle", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json; charset=UTF-8",
                    },
                    body: JSON.stringify(vehicleData),
                })
                    .then((response) => response.json())
                    .then((data) => {
                        if (data === "ok") {
                            closeGarageMenu();
                        } else {
                            console.error("Failed to close Garage UI.");
                        }
                    });
            }
        };

        financeDriveContainer.appendChild(driveButton);
        vehicleItem.appendChild(financeDriveContainer);

        // Progress Bars: Fuel, Engine, Body
        const stats = document.createElement("div");
        stats.classList.add("stats");

        const maxValues = {
            fuel: 100,
            engine: 1000,
            body: 1000,
        };

        ["fuel", "engine", "body"].forEach((statLabel) => {
            const stat = document.createElement("div");
            stat.classList.add("stat");
            const label = document.createElement("div");
            label.classList.add("label");
            label.textContent = statLabel.charAt(0).toUpperCase() + statLabel.slice(1);
            stat.appendChild(label);
            const progressBar = document.createElement("div");
            progressBar.classList.add("progress-bar");
            const progress = document.createElement("span");
            const progressText = document.createElement("span");
            progressText.classList.add("progress-text");
            const percentage = (v[statLabel] / maxValues[statLabel]) * 100;
            progress.style.width = percentage + "%";
            progressText.textContent = Math.round(percentage) + "%";

            if (percentage >= 75) {
                progress.classList.add("bar-green");
            } else if (percentage >= 50) {
                progress.classList.add("bar-yellow");
            } else {
                progress.classList.add("bar-red");
            }

            progressBar.appendChild(progressText);
            progressBar.appendChild(progress);
            stat.appendChild(progressBar);
            stats.appendChild(stat);
            vehicleItem.appendChild(stats);
        });

        fragment.appendChild(vehicleItem);
    });

    vehicleContainerElem.appendChild(fragment);
}
```

- To
```lua
function populateVehicleList(garageLabel, vehicles) {
    const vehicleContainerElem = document.querySelector(".vehicle-table");
    const fragment = document.createDocumentFragment();

    while (vehicleContainerElem.firstChild) {
        vehicleContainerElem.removeChild(vehicleContainerElem.firstChild);
    }

    const garageHeader = document.getElementById("garage-header");
    garageHeader.textContent = garageLabel;

    vehicles.forEach((v) => {
        const vehicleItem = document.createElement("div");
        vehicleItem.classList.add("vehicle-item");

        // Vehicle Info: Name, Plate & Mileage
        const vehicleInfo = document.createElement("div");
        vehicleInfo.classList.add("vehicle-info");

        const vehicleName = document.createElement("span");
        vehicleName.classList.add("vehicle-name");
        vehicleName.textContent = v.vehicleLabel;
        vehicleInfo.appendChild(vehicleName);

        const plate = document.createElement("span");
        plate.classList.add("plate");
        plate.textContent = v.plate;
        vehicleInfo.appendChild(plate);

        const mileage = document.createElement("span");
        mileage.classList.add("mileage");
        mileage.textContent = `${v.distance}mi`;
        vehicleInfo.appendChild(mileage);

        vehicleItem.appendChild(vehicleInfo);

        // Finance Info
        const financeDriveContainer = document.createElement("div");
        financeDriveContainer.classList.add("finance-drive-container");
        const financeInfo = document.createElement("div");
        financeInfo.classList.add("finance-info");

        if (v.balance && v.balance > 0) {
            financeInfo.textContent = "Balance: $" + v.balance.toFixed(0);
        } else {
            financeInfo.textContent = "Paid Off";
        }

        financeDriveContainer.appendChild(financeInfo);

        // Drive Button
        let status;
        let isDepotPrice = false;

        if (v.state === 0) {
            if (v.depotPrice && v.depotPrice > 0) {
                isDepotPrice = true;

                if (v.type === "public") {
                    status = "Depot";
                } else if (v.type === "depot") {
                    status = "$" + v.depotPrice.toFixed(0);
                } else {
                    status = "Out";
                }
            } else {
                status = "Out";
            }
        } else if (v.state === 1) {
            if (v.depotPrice && v.depotPrice > 0) {
                isDepotPrice = true;

                if (v.type === "depot") {
                    status = "$" + v.depotPrice.toFixed(0);
                } else if (v.type === "public") {
                    status = "Depot";
                } else {
                    status = "Drive";
                }
            } else {
                status = "Drive";
            }
        } else if (v.state === 2) {
            status = "Impound";

        } else if (v.state === 3) { // mh-oarking
            status = "Parked outside"
        }

        const driveButton = document.createElement("button");
        driveButton.classList.add("drive-btn");
        driveButton.textContent = status;

        if (status === "Depot" || status === "Impound") {
            driveButton.style.backgroundColor = "#222";
            driveButton.disabled = true;
        }

        if (status === "Parked outside") { // mh-parking 
            driveButton.style.backgroundColor = "#222";
            driveButton.disabled = true;
        }

        if (status === "Out") {
            driveButton.style.backgroundColor = "#222";
        }

        
        driveButton.onclick = function () {
            if (driveButton.disabled) return;

            const vehicleStats = {
                fuel: v.fuel,
                engine: v.engine,
                body: v.body,
            };

            const vehicleData = {
                vehicle: v.vehicle,
                garage: v.garage,
                index: v.index,
                plate: v.plate,
                type: v.type,
                depotPrice: v.depotPrice,
                stats: vehicleStats,
            };

            if (status === "Out") {
                fetch("https://qb-garages/trackVehicle", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json; charset=UTF-8",
                    },
                    body: JSON.stringify(v.plate),
                })
                    .then((response) => response.json())
                    .then((data) => {
                        if (data === "ok") {
                            closeGarageMenu();
                        } else {
                            return;
                        }
                    });
            } else if (isDepotPrice) {
                fetch("https://qb-garages/takeOutDepo", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json; charset=UTF-8",
                    },
                    body: JSON.stringify(vehicleData),
                })
                    .then((response) => response.json())
                    .then((data) => {
                        if (data === "ok") {
                            closeGarageMenu();
                        } else {
                            console.error("Failed to pay depot price.");
                        }
                    });
            } else {
                fetch("https://qb-garages/takeOutVehicle", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json; charset=UTF-8",
                    },
                    body: JSON.stringify(vehicleData),
                })
                    .then((response) => response.json())
                    .then((data) => {
                        if (data === "ok") {
                            closeGarageMenu();
                        } else {
                            console.error("Failed to close Garage UI.");
                        }
                    });
            }
        };

        financeDriveContainer.appendChild(driveButton);
        vehicleItem.appendChild(financeDriveContainer);

        // Progress Bars: Fuel, Engine, Body
        const stats = document.createElement("div");
        stats.classList.add("stats");

        const maxValues = {
            fuel: 100,
            engine: 1000,
            body: 1000,
        };

        ["fuel", "engine", "body"].forEach((statLabel) => {
            const stat = document.createElement("div");
            stat.classList.add("stat");
            const label = document.createElement("div");
            label.classList.add("label");
            label.textContent = statLabel.charAt(0).toUpperCase() + statLabel.slice(1);
            stat.appendChild(label);
            const progressBar = document.createElement("div");
            progressBar.classList.add("progress-bar");
            const progress = document.createElement("span");
            const progressText = document.createElement("span");
            progressText.classList.add("progress-text");
            const percentage = (v[statLabel] / maxValues[statLabel]) * 100;
            progress.style.width = percentage + "%";
            progressText.textContent = Math.round(percentage) + "%";

            if (percentage >= 75) {
                progress.classList.add("bar-green");
            } else if (percentage >= 50) {
                progress.classList.add("bar-yellow");
            } else {
                progress.classList.add("bar-red");
            }

            progressBar.appendChild(progressText);
            progressBar.appendChild(progress);
            stat.appendChild(progressBar);
            stats.appendChild(stat);
            vehicleItem.appendChild(stats);
        });

        fragment.appendChild(vehicleItem);
    });

    vehicleContainerElem.appendChild(fragment);
}
```

- if you get this error
- `script:qb-core] SCRIPT ERROR: citizen:/scripting/lua/scheduler.lua:741: SCRIPT ERROR: @qb-phone/server/main.lua:233: attempt to index a nil value (field 'Garages')`
## Check the config file from qb-phone
- check if you have this
```lua
Config.Garages = Garages
```


## 👇 To keep things nice and clean for the qb-core system and database.
- ✅ Go to resources[qb]/qb-core/server/player.lua around line 506, and find, local playertables = {}. 
- ✅ This is, if we want to delete a character, we also want to delete the parked vehicles in the database,
- ✅ Place the line below at the bottom in playertables (there are more insite), so place this one at the bottom.
````lua
{ table = 'player_parking' },
{ table = 'player_parking_vips' },
````

## Contributers
<a href="https://github.com/MH-Scripts/mh-parking/graphs/contributors">
  <img src="https://contributors-img.web.app/image?repo=MH-Scripts/mh-parking" />
</a>

## 😎 Special thanks for helping me with testing 👊😉👍
- 💪 GUS
- 💪 Jazerra
- 💪 ameN
- 💪 MulGirtab
- 💪 DannyJ
- 💪 MasonJason310
- 💪 Enxsistanz
- 💪 !ExiledVibe!
- 💪 FARRUKO

# LICENSE
[GPL LICENSE](./LICENSE)<br />
&copy; [MaDHouSe79](https://www.youtube.com/@MaDHouSe79)


