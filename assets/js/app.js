// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"

// assets/js/app.js
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import L from 'leaflet'

// let geojsonFeature = {
//     "type": "Feature",
//     "properties": {
//         "name": "My Home",
//     },
//     "geometry": {
//         "type": "Point",
//         "coordinates": [3.0642345, 101.5816646]
//     }
// };
let geojsonMarkerOptions = {
    radius: 8,
    fillColor: "#ff7800",
    color: "#000",
    weight: 1,
    opacity: 1,
    fillOpacity: 0.8
};

let Hooks = {}
let map;
Hooks.LeafletMap = {
    // TODO: there is a bug where the map disappear when you update liveview
    // maybe you need to connect the vouch buttons to this hook
    mounted() {
        let lat = this.el.dataset.lat;
        let lng = this.el.dataset.lng;
        
        map = L.map('map').setView([lat, lng], 16);

        L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
            attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
            maxZoom: 18,
            id: 'mapbox/streets-v11',
            tileSize: 512,
            zoomOffset: -1,
            accessToken: 'pk.eyJ1Ijoia2FtYWxhcmllZmYiLCJhIjoiY2t0bG82cDB6MDgwZTJubDJiamQzNG40MSJ9.P_IARn2JxUUHe6XsPEoyeg'
        }).addTo(map);
        // L.marker([3.0642345, 101.5816646]).addTo(map);
        L.marker([lat, lng]).addTo(map);
        // map.locate({setView: true, maxZoom: 16});
    },
}

Hooks.InsertMap = {
    mounted() {
        const map = L.map('insert-map');
        const onLocationFound = (e) => {
            this.pushEvent("save-my-location", {latlng: e.latlng});
        }
        // function onLocationFound(e) {
        //     let geojsonFeature = {
        //         "type": "Feature",
        //         "properties": {
        //             "name": "My Home",
        //         },
        //         "geometry": {
        //             "type": "Point",
        //             // this is reverse for some reason
        //             "coordinates": [e.latlng.lng, e.latlng.lat]
        //         }
        //     };
        //     L.geoJSON(geojsonFeature, {
        //         pointToLayer: function (feature, latlng) {
        //             return L.circleMarker(latlng, geojsonMarkerOptions);
        //         }
        //     }).addTo(map);
        // }
        map.on('locationfound', onLocationFound);
        map.locate();
    }
}


let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks})

// Connect if there are any LiveViews on the page
liveSocket.connect()

// Expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
// The latency simulator is enabled for the duration of the browser session.
// Call disableLatencySim() to disable:
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

