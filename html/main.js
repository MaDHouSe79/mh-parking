const formContainer = document.getElementById('formContainer');
const newParkForm = document.getElementById('newPark');
const parkContainer = document.getElementById('container');
const park = document.getElementById('park');

var formInfo = {
    parkname: document.getElementById('parkname'),
    display: document.getElementById('display'),
    parktype: document.getElementById('parktype'),
    job: document.getElementById('job'),
    cid: document.getElementById('cid'),
    cost: document.getElementById('cost'),
    radius: document.getElementById('radius'),
    marker: document.getElementById('marker'),
}

window.addEventListener('message', ({ data }) => {
    if (data.color) {
        park.style.background = data.color;
    }
    if (data.type == "newParkSetup") {
        data.enable ? formContainer.style.display = "flex" : formContainer.style.display = "none";
        data.enable ? parkContainer.style.display = "none" : parkContainer.style.display = "block";

    } else if (data.type == "display") {
        if (data.text !== undefined) {
            park.style.display = 'block';
            park.innerHTML = data.text;
            park.classList.add('slide-in');
        }
    } else if (data.type == "hide") {
        park.classList.add('slide-out');
        setTimeout(function() {
            park.innerHTML = '';
            park.style.display = 'none';
            park.classList.remove('slide-in');
            park.classList.remove('slide-out');
        }, 1000)
    }
})

document.addEventListener('keyup', (e) => {
    if (e.key == 'Escape') {
        sendNUICB('close');
    }
});

document.getElementById('newPark').addEventListener('submit', (e) => {
    e.preventDefault();
    sendNUICB('newParkLocation', {
        parkname: formInfo.parkname.value,
        display: formInfo.display.value,
        parktype: formInfo.parktype.value,
        job: formInfo.job.value,
        cid: formInfo.cid.value,
        cost: formInfo.cost.value,
        radius: formInfo.radius.value,
        marker: formInfo.marker.value,
    });
})

function sendNUICB(event, data = {}, cb = () => {}) {
	fetch(`https://${GetParentResourceName()}/${event}`, {
		method: 'POST',
		headers: { 'Content-Type': 'application/json; charset=UTF-8', },
		body: JSON.stringify(data)
	}).then(resp => resp.json()).then(resp => cb(resp));
}