let editMode = false;
const menu = document.getElementById("menu");
const parkingList = document.getElementById("parkingList");
const vehicleInfo = document.getElementById("vehicleInfo");

function setTheme(theme) {
    const root = document.documentElement;
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

window.addEventListener("message", event => {
    const data = event.data;
    if (data.action === "setHudPos") {
        menu.style.left = data.x + "px";
        menu.style.top = data.y + "px";
    }
    
    if (data.action === "open") {

        if (data.theme) { setTheme(data.theme) }

        const hour = parseInt(data.hour) || 12;

        if (hour >= 6 && hour < 18) {
            menu.classList.add('day');
            menu.classList.remove('night');
        } else {
            menu.classList.add('night');
            menu.classList.remove('day');
        }

        parkingList.innerHTML = "";
        vehicleInfo.innerHTML = "";

        if (data.type == "parked") {
            menu.style.display = "block";
            data.vehicles.forEach(v => {
                const div = document.createElement("div");
                div.className = "vehicle";

                var html = `<table><tr><td><img class="vehicleImage" src="../html/assets/images/`+ v.vehicle + `.png"></td><td>`;

                html += `
                    <strong>${v.vehicle.toUpperCase()} ${v.plate}</strong>
                    <small>Parked Street: ${v.street}</small>
                    <small>Fuel: ${v.fuel}% | Engine: ${v.engine} | Body: ${v.body}</small>
                    <small>Press to set a waypoint</small>
                `;

                html += `</td></tr></table>`;

                div.innerHTML = html;
                div.onclick = () => {
                    fetch(`https://${GetParentResourceName()}/setWaypoint`, {
                        method: "POST",
                        headers: { "Content-Type": "application/json" },
                        body: JSON.stringify({ coords: v.coords })
                    });
                    menu.style.display = "none";
                    fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
                };

                parkingList.appendChild(div);
            });
        } else if (e.data.type == "info") {
            menu.style.display = "block";
            if (data.vehicle != null) {
                const div = document.createElement("div");
                div.className = "vehicle";
                var html = `<table><tr><td><img class="vehicleImage" src="../html/assets/images/`+ data.vehicle.model + `.png"></td><td>`;
                html += `<table>`;
                html += `<tr><td>Model</td><td>${data.vehicle.displayName}</td></tr>`;
                html += `<tr><td>Plate</td><td>${data.vehicle.plate}</td></tr>`;
                html += `<tr><td>Class</td><td>${data.vehicle.class}</td></tr>`;
                if (data.vehicle.isOwner === true) { 
                    html += `
                        <tr><td>Fuel</td><td>${data.vehicle.fuel}%</td></tr>
                        <tr><td>Engine</td><td>${data.vehicle.engine}%</td></tr>
                        <tr><td>Body</td><td>${data.vehicle.body}%</td></tr>
                        <tr><td>Oil</td><td>${data.vehicle.oil} fL</td></tr>
                        <tr><td>Temp</td><td>${data.vehicle.temp} °C</td></tr>
                    `
                }
                html += `</table>`;
                html += `</td></tr></table>`;
                div.innerHTML = html;

                vehicleInfo.appendChild(div);
            }
        }

    }
});

function toggleEditMode() {
    editMode = !editMode;
    if (editMode == true) {
        menu.style.cursor = "move"
        menu.style.outline = "2px dashed #fff";
    } else  {
        menu.style.cursor = "pointer"
        menu.style.outline = "none";
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
