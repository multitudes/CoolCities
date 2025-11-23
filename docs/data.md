<p align="center">
  <picture>
    <source srcset="assets/logo/logo-dark.png" media="(prefers-color-scheme: dark)">
    <img src="assets/logo/logo-light.png" alt="CoolCities logo" width="280">
  </picture>
</p>

# Getting the raw data

We do fetching and processing satellite imagery from the Sentinel Hub service. 

### How it Works
Two types of overlay data are produced: a high-resolution NDVI grid and a coarse-resolution LST grid.

We make two separate requests to the Sentinel Hub "Process API":
- One request to obtain Normalized Difference Vegetation Index (NDVI) imagery derived from Sentinel-2.
- One request to obtain Land Surface Temperature (LST) imagery derived from Sentinel-3 (SLSTR).

1.  **Authentication**: Before calling the Process API the app obtains an OAuth access token. The token is cached to avoid re-requesting it for every call; client credentials must be stored securely (for example in environment variables or a private secrets store).
2.  **Data Processing**: The Process API can return the processed data as a PNG image. The app decodes the PNG into a raster and maps grayscale pixel values back into scientific values (NDVI in the range -1.0 to 1.0, and temperature in Celsius).
3.  **Fallback**: If an API call fails or is unavailable, the app will show the appropriate alert.

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



