let lang = null;
let editMode = false;
let isPolice = false;
let isClamped = false;
let isOwner = false;

const menu = document.getElementById("menu");
const stats = document.getElementById("stats");
const parkingList = document.getElementById("parkingList");
const vehicleInfo = document.getElementById("vehicleInfo");
const searchContainer = document.getElementById("search-container");

function setTheme(theme) {
    const root = document.documentElement;
    root.style.setProperty('--header-title-text-color', theme.header_title_text_color);
    root.style.setProperty('--primary-font', theme.primary_font);
    root.style.setProperty('--bg-transparent', theme.bg_transparent);
    root.style.setProperty('--bg-primary', theme.bg_primary);
    root.style.setProperty('--bg-secondary', theme.bg_secondary);
    root.style.setProperty('--text-color', theme.text_color);
    root.style.setProperty('--glass', theme.glass);
    root.style.setProperty('--glass-hover', theme.glass_hover);
    root.style.setProperty('--neon-cyan', theme.neon_cyan);
    root.style.setProperty('--neon-purple', theme.neon_purple);
    root.style.setProperty('--glow-cyan', theme.glow_cyan);
    root.style.setProperty('--glow-purple', theme.glow_purple);
    root.style.setProperty('--border-glass', theme.border_glass);
    root.style.setProperty('--border-bottom', theme.border_bottom);
    root.style.setProperty('--box-shadow', theme.box_shadow);
    root.style.setProperty('--text-secondary', theme.text_secondary);
}

/* This is the send client to nui */
window.addEventListener("message", event => {
    const data = event.data;
    searchInput.value = "";
    menu.style.left = "50%";
    menu.style.top = "50%";

    lang = data.lang

    if (data.theme != null) { setTheme(data.theme ); }
   
    if (data.action === "resetHudPos") {
        menu.style.left = "50%";
        menu.style.top = "50%";
    }

    if (data.action === "setHudPos") {
        menu.style.left = data.x + "px";
        menu.style.top = data.y + "px";
    }

    parkingList.innerHTML = "";
    vehicleInfo.innerHTML = "";

    if (data.action === "open") {
        SetDayOrNight(data.hour)
        const div1 = document.createElement("div");
        div1.className = "vehicle";
        div1.innerHTML = ""
        if (data.type == "parked") {
            menu.style.display = "block";
            menu.style.height = "660px";
            stats.style.height = "auto";
            parkingList.innerHTML = "";
            parkingList.style.display = "block";
            searchContainer.style.display = "block";
            vehicleInfo.style.display = "none";            
            isOwner = data.isOwner
            data.vehicles.forEach(v => { 
                const div = document.createElement("div");
                div.className = "vehicle";
                var html = `<div class="card" id="${v.vehicle}">`;
                html += `    <center><img class="card-img-top" style="width: 250px;" src="../html/assets/images/`+ v.vehicle + `.png" alt="Vehicle image cap"></center>`;
                html += `    <div class="card-body">`;
                html += `        <h5 class="card-title" style="text-align:center;">${v.vehicle} / ${v.plate}</h5>`;
                if (isOwner === true) {
                    html += `    <p class="card-text" style="text-align:center;">`;
                    html += `        <small> ${v.engine} | ${v.body} | ${v.fuel} </small>`;
                    html += `    </p>`;
                    html += `    <div class="btn-group-sm center" role="group" aria-label="Basic example">`;
                    html += `        <a href="#" class="btn givekeys">${lang.givekeys}</a>`
                    html += `        <a href="#" class="btn setwaypoint">${lang.setwaypoint}</a>`
                    html += `    </div>`;
                }            
                html += `    </div>`;
                html += `</div>`;
                div.innerHTML = html;
                const setwaypoint = div.querySelector(".setwaypoint");
                if (setwaypoint) {
                    setwaypoint.onclick = (e) => {
                        e.stopPropagation();
                        setWaypoint(v.coords);
                    };
                    setwaypoint.style.cursor = "pointer";
                }
                const takekeys = div.querySelector(".givekeys");
                if (takekeys) {
                    takekeys.onclick = (e) => {
                        e.stopPropagation();
                        giveKeys(v.plate);
                    };
                    takekeys.style.cursor = "pointer";
                }
                parkingList.appendChild(div);
            });
            searchInput.addEventListener('input', function() {
                const searchTerm = this.value.toLowerCase();
                const vehicleItems = document.querySelectorAll('#parkingList .vehicle');
                vehicleItems.forEach(item => {
                    if (item.textContent.toLowerCase().includes(searchTerm)) {
                        item.style.display = 'block';
                    } else {
                        item.style.display = 'none';
                    }
                });
            });
        } else if (data.type == "info") {
            isPolice = data.isPolice
            isClamped = data.isClamped
            isOwner = data.isOwner
            isParked = data.isParked            
            menu.style.display = "block";
            menu.style.height = "385px";
            if (isPolice === true) { menu.style.height = "440px"; }
            stats.style.height = "auto";
            searchContainer.style.display = "none";
            parkingList.style.display = "none";
            vehicleInfo.style.display = "block";
            vehicleInfo.innerHTML = "";
            if (data.vehicle != null) {
                const div = document.createElement("div");
                div.className = "vehicle";
                var html = `<div class="card">`;
                html += `    <center><img class="card-img-top" style="width: 250px;" src="../html/assets/images/`+ data.vehicle.model + `.png" alt="Vehicle image cap"></center>`;
                html += `    <div class="card-body">`;
                html += `        <h5 class="card-title" style="text-align:center;">${data.vehicle.displayName} / ${data.vehicle.plate}</h5>`;
                if (isOwner === true) {
                    html += `    <p class="card-text" style="text-align:center;">`;
                    html += `        <small> ${data.vehicle.class} | ${data.vehicle.engine} | ${data.vehicle.body} | ${data.vehicle.fuel} | ${data.vehicle.oil} </small>`;
                    html += `    </p>`;
                }
                if (isPolice === true) {
                    html += `    <p class="card-text" style="text-align:center;">`;
                    html += `        <small> ${lang.parkinfo}</small>`;
                    html += `    </p>`;
                }
                html += `    </div>`;
                html += `</div>`;
                html += `<div class="card">`;
                html += `    <h5 class="card-title" style="text-align:center;">${lang.options}</h5>`;
                html += `    <div class="btn-group-sm center" role="group" aria-label="Options">`;
                if (isOwner === true) {
                    if (isParked === true) {
                        html += `<a href="#" class="btn unpark">${lang.unpark}</a>`
                    } else {
                        html += `<a href="#" class="btn park">${lang.park}</a>`
                    }
                }   
                if (isPolice === true) {
                    if (data.isOverTime === true) {
                        if (isClamped === true) {
                            html += `<a href="#" class="btn removewheelclamp">${lang.removeclamp}</a>`;
                        } else {
                            html += `<a href="#" class="btn setwheelclamp">${lang.addclamp}</a>`;
                        }
                    }
                    html += `<a href="#" class="btn impound">${lang.impound}</a>`;
                }
                html += `    </div>`;
                html += `</div>`;
                div.innerHTML = html;

                const unparking = div.querySelector(".unpark");
                if (unparking) {
                    unparking.onclick = (e) => {
                        e.stopPropagation();
                        unpark(data.vehicle.plate);
                    };
                    unparking.style.cursor = "pointer";
                }

                const parking = div.querySelector(".park");
                if (parking) {
                    parking.onclick = (e) => {
                        e.stopPropagation();
                        park(data.vehicle.plate);
                    };
                    parking.style.cursor = "pointer";
                }

                const setwheelclamp = div.querySelector(".setwheelclamp");
                if (setwheelclamp) {
                    setwheelclamp.onclick = (e) => {
                        e.stopPropagation();
                        addWheelClamp();
                    };
                    setwheelclamp.style.cursor = "pointer";
                }

                const removewheelclamp = div.querySelector(".removewheelclamp");
                if (removewheelclamp) {
                    removewheelclamp.onclick = (e) => {
                        e.stopPropagation();
                        removeWheelClamp();
                    };
                    removewheelclamp.style.cursor = "pointer";
                }

                const impound = div.querySelector(".impound");
                if (impound) {
                    impound.onclick = (e) => {
                        e.stopPropagation();
                        impoundVehicle();
                    };
                    impound.style.cursor = "pointer";
                }

                vehicleInfo.appendChild(div);
            }
        }
    }
});

function SetDayOrNight(_hour) {
    const hour = parseInt(_hour) || 12;
    if (hour >= 6 && hour < 18) {
        menu.classList.add('day');
        menu.classList.remove('night');
    } else {
        menu.classList.add('night');
        menu.classList.remove('day');
    } 
}

function park(plate) {
    fetch(`https://${GetParentResourceName()}/park`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ plate: plate })
    });
    menu.style.display = "none";
    fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });

}
function unpark(plate) {
    fetch(`https://${GetParentResourceName()}/unpark`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ plate: plate })
    });
    menu.style.display = "none";
    fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
}

function giveKeys(plate) {
    if (isOwner === true) {
        isOwner = false;
        fetch(`https://${GetParentResourceName()}/giveKeys`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ plate: plate })
        });
        menu.style.display = "none";
        fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
    }
}

function setWaypoint(coords) {
    if (isOwner === true) {
        isOwner = false;
        fetch(`https://${GetParentResourceName()}/setWaypoint`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ coords: coords })
        });
        menu.style.display = "none";
        fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
    }
}

function impoundVehicle() {
    if (isPolice === true) {
        isPolice = false;
        fetch(`https://${GetParentResourceName()}/impoundVehicle`, {method: "POST"});
        menu.style.display = "none";
        fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
    }
}

function addWheelClamp() {
    if (isPolice === true) {
        isPolice = false;
        fetch(`https://${GetParentResourceName()}/setWheelClamp`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ action: "add" })
        });
        menu.style.display = "none";
        fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
    }
}

function removeWheelClamp() {
    if (isPolice === true) {
        isPolice = false;
        fetch(`https://${GetParentResourceName()}/setWheelClamp`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ action: "remove" })
        });
        menu.style.display = "none";
        fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
    }
}

function toggleEditMode() {
    editMode = !editMode;
    if (editMode == true) {
        menu.style.cursor = "move";
        menu.style.outline = "2px dashed #fff";
        resetBtn.style.display = "block";
    } else  {
        menu.style.cursor = "pointer";
        menu.style.outline = "0px";
        menu.style.border = "0px";
        resetBtn.style.display = "none";
    }
}

const editBtn = document.getElementById("edit");
editBtn.onclick = () => { toggleEditMode(); };

const closeBtn = document.getElementById("close");
closeBtn.onclick = () => {
    menu.style.display = "none";
    if (editMode == true) {
        editMode = false
        menu.style.cursor = "pointer"
        menu.style.outline = "none";
    }
    fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
};

const resetBtn = document.getElementById("reset");
resetBtn.onclick = () => {
    if (editMode == true) { editMode = false }
    menu.style.display = "none";
    menu.style.left = "50%";
    menu.style.top = "50%";
    menu.style.cursor = "pointer";
    menu.style.outline = "0px";
    menu.style.border = "0px";    
    menu.style.display = "block";
    resetBtn.style.display = "none";
};

// dragging hud
let isDragging = false;
let offsetX = 0;
let offsetY = 0;

// Start drag
menu.addEventListener("mousedown", (e) => {
    if (!editMode) return;
    isDragging = true;
    offsetX = e.clientX - menu.offsetLeft;
    offsetY = e.clientY - menu.offsetTop;
});

// Drag
document.addEventListener("mousemove", (e) => {
    if (!isDragging) return;
    menu.style.left = (e.clientX - offsetX) + "px";
    menu.style.top = (e.clientY - offsetY) + "px";
});

// Stop drag + save
document.addEventListener("mouseup", () => {
    if (!isDragging) return;
    isDragging = false;
    const pos = { x: menu.offsetLeft, y: menu.offsetTop};
    fetch(`https://${GetParentResourceName()}/saveHudPos`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(pos)
    });
});