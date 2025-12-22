const menu = document.getElementById("menu");
const stats = document.getElementById("stats");
const parkingList = document.getElementById("parkingList");
const vehicleInfo = document.getElementById("vehicleInfo");
const searchContainer = document.getElementById("search-container");
const searchInput = document.getElementById("searchInput");

let lang = null;
let editMode = false;
let isPolice = false;
let isClamped = false;
let isOwner = false;
let isParked = false;
let isDragging = false;
let offsetX = 0;
let offsetY = 0;

window.addEventListener('resize', snapToCenterIfOutOfBounds);

window.addEventListener("message", event => {
    const data = event.data;
    if (data.lang) lang = data.lang;
    lang = data.lang;
    searchInput.value = "";
    if (data.theme) setTheme(data.theme);
    

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
    if (data.action !== "open") return;
    SetDayOrNight(data.hour);

    var top = menu.style.top.replace("px", "");
    if (top < 330) { menu.style.top = "336px"; }

    if (data.type === "parked") { // parked vehicles list
        menu.style.display = "block";
        menu.style.height = "660px";
        parkingList.style.display = "block";
        searchContainer.style.display = "block";
        vehicleInfo.style.display = "none";
        isOwner = data.isOwner;
        data.vehicles.forEach(v => {
            const div = document.createElement("div");
            div.className = "vehicle";
            let html = `<div class="card" id="${v.vehicle}">`;
            html += `    <center><img class="card-img-top" style="width: 250px;" src="../html/assets/images/${v.vehicle}.png" alt="Vehicle image"></center>`;
            html += `    <div class="card-body">`;
            html += `        <h5 class="card-title text-center">${v.vehicle} / ${v.plate}</h5>`;
            if (isOwner) {
                html += `    <p class="card-text text-center"><small>${v.engine} | ${v.body} | ${v.fuel}</small></p>`;
                html += `    <div class="btn-group-sm center" role="group">`;
                html += `        <a href="#" class="btn givekeys">${lang.givekeys}</a>`;
                html += `        <a href="#" class="btn setwaypoint">${lang.setwaypoint}</a>`;
                html += `    </div>`;
            }
            html += `    </div>`;
            html += `</div>`;
            div.innerHTML = html;
            div.querySelector(".givekeys")?.addEventListener("click", e => {
                e.stopPropagation();
                giveKeys(v.plate);
            });
            div.querySelector(".setwaypoint")?.addEventListener("click", e => {
                e.stopPropagation();
                setWaypoint(v.coords);
            });
            parkingList.appendChild(div);
        });
        searchInput.addEventListener('input', function () {
            const term = this.value.toLowerCase();
            document.querySelectorAll('#parkingList .vehicle').forEach(item => {
                item.style.display = item.textContent.toLowerCase().includes(term) ? 'block' : 'none';
            });
        });
    } else if (data.type === "info") { // current parked vehicle info
        isPolice = data.isPolice;
        isClamped = data.isClamped;
        isOwner = data.isOwner;
        isParked = data.isParked;
        menu.style.display = "block";
        menu.style.height = "440px";
        searchContainer.style.display = "none";
        parkingList.style.display = "none";
        vehicleInfo.style.display = "block";
        snapToCenterIfOutOfBounds();
        if (data.vehicle) {
            const div = document.createElement("div");
            div.className = "vehicle";
            let html = `<div class="card">`;
            html += `    <center><img class="card-img-top" style="width: 250px;" src="../html/assets/images/${data.vehicle.model}.png" alt="Vehicle image"></center>`;
            html += `    <div class="card-body">`;
            html += `        <h5 class="card-title text-center">${data.vehicle.displayName} / ${data.vehicle.plate}</h5>`;
            if (isOwner) {
                html += `    <p class="card-text text-center"><small>${data.vehicle.class} | ${data.vehicle.engine} | ${data.vehicle.body} | ${data.vehicle.fuel} | ${data.vehicle.oil}</small></p>`;
            }
            html += `        <p class="card-text text-center"><small>${lang.parkinfo}</small></p>`;
            html += `    </div>`;
            html += `</div>`;
            html += `<div class="card">`;
            html += `    <h5 class="card-title text-center">${lang.options}</h5>`;
            html += `    <div class="btn-group-sm center" role="group">`;
            if (isOwner) {
                html += `<a href="#" class="btn givekeys">${lang.givekeys}</a>` 
                if (!isClamped) {
                    html += isParked ? `<a href="#" class="btn unpark">${lang.unpark}</a>` : `<a href="#" class="btn park">${lang.park}</a>`;
                }
                html += isClamped ? `<a href="#" class="btn payclampbill">${lang.pay_to_unclamp}</a>` : ``;
            }
            if (isPolice) {
                //if (data.isOverTime) {
                    html += isClamped ? `<a href="#" class="btn removewheelclamp">${lang.removeclamp}</a>` : `<a href="#" class="btn setwheelclamp">${lang.addclamp}</a>`;
                //}
                html += `<a href="#" class="btn impound">${lang.impound}</a>`;
            }
            html += `    </div>`;
            html += `</div>`;
            div.innerHTML = html;

            div.querySelector(".givekeys")?.addEventListener("click", e => {
                e.stopPropagation();
                giveKeys(data.vehicle.plate);
            });

            div.querySelector(".unpark")?.addEventListener("click", e => {
                e.stopPropagation();
                unpark(data.vehicle.plate);
            });
            div.querySelector(".park")?.addEventListener("click", e => {
                e.stopPropagation();
                park(data.vehicle.plate);
            });

            div.querySelector(".payclampbill")?.addEventListener("click", e => {
                e.stopPropagation();
                payWheelclampBill(data.vehicle.plate);
            });

            div.querySelector(".setwheelclamp")?.addEventListener("click", e => {
                e.stopPropagation();
                addWheelClamp();
            });
            div.querySelector(".removewheelclamp")?.addEventListener("click", e => {
                e.stopPropagation();
                removeWheelClamp();
            });
            div.querySelector(".impound")?.addEventListener("click", e => {
                e.stopPropagation();
                impoundVehicle();
            });
            vehicleInfo.appendChild(div);
        }
    }
});

document.getElementById("edit").onclick = toggleEditMode;
document.getElementById("close").onclick = () => {
    menu.style.display = "none";
    if (editMode) {
        editMode = false;
        menu.style.cursor = "pointer";
        menu.style.outline = "none";
    }
    fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
};

document.getElementById("reset").onclick = () => {
    if (editMode) editMode = false;
    menu.style.display = "none";
    menu.style.left = "50%";
    menu.style.top = "50%";
    menu.style.cursor = "pointer";
    menu.style.outline = "none";
    menu.style.border = "0px";
    menu.style.display = "block";
    document.getElementById("reset").style.display = "none";
};

menu.addEventListener('contextmenu', e => {
    e.preventDefault();
    menu.style.left = "50%";
    menu.style.top = "50%";
    fetch(`https://${GetParentResourceName()}/saveHudPos`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ x: '50%', y: '50%' })
    });
});

menu.addEventListener("mousedown", e => {
    if (!editMode) return;
    isDragging = true;
    offsetX = e.clientX - menu.offsetLeft;
    offsetY = e.clientY - menu.offsetTop;
});

document.addEventListener("mousemove", e => {
    if (!isDragging) return;
    menu.style.left = (e.clientX - offsetX) + "px";
    menu.style.top = (e.clientY - offsetY) + "px";
});

document.addEventListener("mouseup", () => {
    if (!isDragging) return;
    isDragging = false;
    snapToCenterIfOutOfBounds();
    fetch(`https://${GetParentResourceName()}/saveHudPos`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ x: menu.offsetLeft, y: menu.offsetTop })
    });
});

function setTheme(theme) {
    const root = document.documentElement;
    Object.keys(theme).forEach(key => root.style.setProperty(`--${key.replace(/_/g, '-')}`, theme[key]));
}

function SetDayOrNight(hour) {
    const h = parseInt(hour) || 12;
    menu.classList.toggle('day', h >= 6 && h < 18);
    menu.classList.toggle('night', !(h >= 6 && h < 18));
}

function park(plate) {
    menu.style.display = "none";
    fetch(`https://${GetParentResourceName()}/park`, { method: "POST", body: JSON.stringify({ plate }) });
    fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
}

function unpark(plate) {
    menu.style.display = "none";
    fetch(`https://${GetParentResourceName()}/unpark`, { method: "POST", body: JSON.stringify({ plate }) });
    fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
}

function payWheelclampBill(plate) {
    menu.style.display = "none";
    fetch(`https://${GetParentResourceName()}/payWheelclampBill`, { method: "POST", body: JSON.stringify({ plate }) });
    fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
}

function giveKeys(plate) {
    if (!isOwner) return;
    isOwner = false;
    menu.style.display = "none";
    fetch(`https://${GetParentResourceName()}/giveKeys`, { method: "POST", body: JSON.stringify({ plate }) });
    fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
}

function setWaypoint(coords) {
    if (!isOwner) return;
    isOwner = false;
    menu.style.display = "none";
    fetch(`https://${GetParentResourceName()}/setWaypoint`, { method: "POST", body: JSON.stringify({ coords }) });
    fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
}

function impoundVehicle() {
    if (!isPolice) return;
    isPolice = false;
    menu.style.display = "none";
    fetch(`https://${GetParentResourceName()}/impoundVehicle`, { method: "POST" });
    fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
}

function addWheelClamp() {
    if (!isPolice) return;
    isPolice = false;
    menu.style.display = "none";
    fetch(`https://${GetParentResourceName()}/setWheelClamp`, { method: "POST", body: JSON.stringify({ action: "add" }) });
    fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
}

function removeWheelClamp() {
    if (!isPolice) return;
    isPolice = false;
    menu.style.display = "none";
    fetch(`https://${GetParentResourceName()}/setWheelClamp`, { method: "POST", body: JSON.stringify({ action: "remove" }) });
    fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
}

// Edit mode toggle
function toggleEditMode() {
    editMode = !editMode;
    menu.style.cursor = editMode ? "move" : "pointer";
    menu.style.outline = editMode ? "2px dashed #fff" : "none";
    document.getElementById("reset").style.display = editMode ? "block" : "none";
}

// Snap To Center If Out Of Bounds
function snapToCenterIfOutOfBounds() {
    const rect = menu.getBoundingClientRect();
    const w = window.innerWidth;
    const h = window.innerHeight;
    if (rect.left < 0 || rect.right > w || rect.top < 0 || rect.bottom > h) {
        menu.style.left = '50%';
        menu.style.top = '50%';
        menu.style.transform = 'translate(-50%, -50%)';
        fetch(`https://${GetParentResourceName()}/saveHudPos`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ x: '50%', y: '50%' })
        });
    }
}