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
import L from "leaflet"

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
let Hooks = {};

class LeafletMap extends HTMLElement {}
customElements.define("leaflet-map", LeafletMap);

class LeafletMarker extends HTMLElement {}
customElements.define("leaflet-marker", LeafletMarker);

// Hooks.LeafletMap = {
//     // TODO: there is a bug where the map disappear when you update liveview
//     // maybe you need to connect the vouch buttons to this hook
//     // 2021-12-12 16:38:16 I've tried to follow some code using HTML components. The map doesn't disappear anymore but the marker icon is not showing. it did work when I don't include the CSS in the custom element
//     mounted() {
//         let lat = this.el.dataset.lat;
//         let lng = this.el.dataset.lng;
//
//         map = L.map('map').setView([lat, lng], 16);
//
//         L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
//             attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
//             maxZoom: 18,
//             id: 'mapbox/streets-v11',
//             tileSize: 512,
//             zoomOffset: -1,
//             accessToken: 'pk.eyJ1Ijoia2FtYWxhcmllZmYiLCJhIjoiY2t0bG82cDB6MDgwZTJubDJiamQzNG40MSJ9.P_IARn2JxUUHe6XsPEoyeg'
//         }).addTo(map);
//         // L.marker([3.0642345, 101.5816646]).addTo(map);
//         L.marker([lat, lng]).addTo(map);
//         // map.locate({setView: true, maxZoom: 16});
//     },
// }

// these are all taken from the dispatch repo
Hooks.LeafletMap = {
  mounted() {
    const template = document.createElement("template");
    template.innerHTML = `
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css"
     integrity="sha512-xodZBNTC5n17Xt2atTPuE1HxjVMSvLVW9ocqUKLsCC5CXdbqCmblAshOMAS6/keqq/sMZMZ19scR4PsZChSR7A=="
     crossorigin=""/>
    <div style="height: 580px; z-index:0;">
        <slot />
    </div>
`;
    this.el.attachShadow({
      mode: "open",
    });
    this.el.shadowRoot.appendChild(template.content.cloneNode(true));
    this.mapElement = this.el.shadowRoot.querySelector("div");
    let lat = this.el.dataset.lat || "43.6532";
    let lng = this.el.dataset.lng || "-79.3832";

    this.map = L.map(this.mapElement).setView(
      [lat, lng],
      this.el.dataset.zoom || 13
    );

    L.tileLayer(
      "https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}",
      {
        attribution:
          'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
        maxZoom: 18,
        id: "mapbox/streets-v11",
        tileSize: 512,
        zoomOffset: -1,
        accessToken:
          "pk.eyJ1Ijoia2FtYWxhcmllZmYiLCJhIjoiY2t0bG82cDB6MDgwZTJubDJiamQzNG40MSJ9.P_IARn2JxUUHe6XsPEoyeg",
      }
    ).addTo(this.map);

    this.layers = {};

    this.el.addEventListener("layer:created", (e) => {
      this.layers[e.detail.id] = e.detail.layer;
      e.detail.layer.addTo(this.map);
    });

    this.el.addEventListener("layer:updated", (e) => {
      if (this.layers[e.detail.id]) {
        this.layers[e.detail.id].removeFrom(this.map);
      }
      this.layers[e.detail.id] = e.detail.layer;
      e.detail.layer.addTo(this.map);
    });

    this.el.addEventListener("layer:destroyed", (e) => {
      if (this.layers[e.detail.id]) {
        this.layers[e.detail.id].removeFrom(this.map);
        delete this.layers[e.detail.id];
      }
    });
  },
};

const LeafletLayer = {
  mounted() {
    withMapEl(this.el, (el) =>
      el.dispatchEvent(
        new CustomEvent("layer:created", {
          detail: {
            id: this.el.id,
            layer: this.layer(),
          },
        })
      )
    );
  },

  updated() {
    withMapEl(this.el, (el) =>
      el.dispatchEvent(
        new CustomEvent("layer:updated", {
          detail: {
            id: this.el.id,
            layer: this.layer(),
          },
        })
      )
    );
  },

  destroyed() {
    withMapEl(this.el, (el) =>
      el.dispatchEvent(
        new CustomEvent("layer:destroyed", {
          detail: {
            id: this.el.id,
            layer: this.layer(),
          },
        })
      )
    );
  },
};

function withMapEl(el, callback) {
  let mapEl = el.closest("leaflet-map");
  if (mapEl) {
    return callback(mapEl);
  } else {
    console.error("No leaflet-map elements found!");
  }
}

Hooks.LeafletMarker = {
  ...LeafletLayer,
  ...{
    layer() {
      // TODO: For icon, it's better to give your own images
      // Otherwise, it's a bit of a hassle to get it from the default leaflet node_modules
      let marker = L.marker([this.el.dataset.lat, this.el.dataset.lng]);
      return marker;
    },
  },
};

Hooks.InsertMap = {
  mounted() {
    const map = L.map("insert-map");
    const onLocationFound = (e) => {
      this.pushEvent("save-my-location", { latlng: e.latlng });
    };
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
    map.on("locationfound", onLocationFound);
    map.locate();
  },
};

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
