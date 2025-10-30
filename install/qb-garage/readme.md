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
