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

# You need to rejoin when
- You change someting in code.
- There is no onstart but only a onjoin check when a player jois the server.

# Add Code in your garage script
- you need to this inder to make parking work propperly
- add this below in your config file of your garage script
```lua
Config.keepEngineOnWhenAbandoned = true
```
- go to your client file and add this after you spawn the vehcle
```lua
SetVehicleKeepEngineOnWhenAbandoned(vehicle, Config.keepEngineOnWhenAbandoned)
```
- `vehicle` can also by `veh` in your script.

# For qb-garage/html/script.js around line 43
- replace this function below
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

# LICENSE
[GPL LICENSE](./LICENSE)<br />
&copy; [MaDHouSe79](https://www.youtube.com/@MaDHouSe79)
