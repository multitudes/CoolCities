<p align="center">
  <picture>
    <source srcset="assets/logo/logo-dark.png" media="(prefers-color-scheme: dark)">
    <img src="assets/logo/logo-light.png" alt="CoolCities logo" width="280">
  </picture>
</p>

# Getting the raw data

We fetch and process satellite imagery from the Sentinel Hub service to generate the overlay layers used in the app.

<!-- Sentinel satellite images: drop `sentinel2.jpeg` and `sentinel3.jpeg` into docs/assets/ -->
<div style="display:flex;gap:12px;justify-content:center;align-items:center;margin:12px 0">
  <img src="assets/sentinel2.jpeg" alt="Sentinel-2" style="width:40%;max-width:340px;height:auto;border:1px solid #ddd;padding:4px;background:#fff" />
  <img src="assets/sentinel3.jpeg" alt="Sentinel-3" style="width:40%;max-width:340px;height:auto;border:1px solid #ddd;padding:4px;background:#fff" />
</div>

### How it Works
We produce two main overlay types:

- High-resolution NDVI (vegetation index) derived from Sentinel-2 imagery.
- Land Surface Temperature (LST) derived from Sentinel-3 SLSTR observations.

Summary of the processing pipeline:

1. **Authentication** — the app obtains an OAuth access token (cached) using private client credentials. Keep credentials out of the public repository.
2. **Server-side processing** — the app sends a POST to the Sentinel Hub Process API with geographic bounds, time range and a processing script (evalscript) that extracts and encodes the requested measurement.
3. **Image encoding** — the Process API returns an image (typically PNG) where measurements are encoded as grayscale values (0–255).
4. **Client decoding & scaling** — the client decodes the PNG into a raster and maps pixel values back into scientific units (NDVI, °C) using the same scaling factors applied server-side.
5. **Calibration & downscaling** — we apply fusion and downscaling techniques to produce near-ground, walking-level estimates at neighborhood scale (targeting ~10 m precision), using in-situ sensors for calibration where available.
6. **Fallback & caching** — cached tiles or synthetic data are used when external calls fail or to speed up the UI for demos.

<div style="display:flex;gap:12px;justify-content:center;align-items:center;margin:16px 0">
  <img src="assets/Overlays/Overlay1.jpg" alt="Overlay 1" style="width:32%;max-width:300px;height:auto;border:1px solid #ddd;padding:4px;background:#fff" />
  <img src="assets/Overlays/Overlay2.jpg" alt="Overlay 2" style="width:32%;max-width:300px;height:auto;border:1px solid #ddd;padding:4px;background:#fff" />
  <img src="assets/Overlays/Overlay3.jpg" alt="Overlay 3" style="width:32%;max-width:300px;height:auto;border:1px solid #ddd;padding:4px;background:#fff" />
</div>

### Your Questions Answered

*   **How do I get the token?**
    The app's authentication routine handles this. It sends a POST request with your client ID and client secret to the Sentinel Hub token endpoint. Store these credentials securely (for example, in environment variables or a private secrets store) and do not commit them to the repository. Register for a free trial account on the [Sentinel Hub website](https://www.sentinel-hub.com/) to obtain a client ID and secret.

*   **Which satellites are involved?**
    *   **Sentinel-2**: Used for high-resolution NDVI data (example source: sentinel-2-l2a).
    *   **Sentinel-3**: Used for coarse-resolution LST data from the SLSTR instrument (example source: sentinel-3-slstr).

*   **What are the endpoints?**
    The Process API uses two main endpoints (examples shown):
    *   Token endpoint (example): `https://services.sentinel-hub.com/oauth/token`
    *   Process API endpoint (example): `https://services.sentinel-hub.com/api/v1/process`

*   **How is the data format?**
    *   **Request**: The app sends a POST request with a JSON body to the Process API. The JSON describes the geographic bounding box, time range, chosen data source, and includes a server-side processing script (evalscript) that computes the requested measurement.
    *   **Response**: The API can return a PNG image where scientific values are encoded as grayscale (0–255). The app decodes the PNG into a raster and converts pixel values back into floating-point scientific units (NDVI or temperature) using the same scaling applied server-side.

## resources
Register for a free account (one month trial) on the Sentinel Hub website to get your own client ID and secret:  
https://www.sentinel-hub.com  

**Sentinel Hub documentation**.  
The "Process API" is the most relevant part for our app.    
https://docs.sentinel-hub.com/api/latest/api/process/



