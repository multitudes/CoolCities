# Getting the raw data

We do fetching and processing satellite imagery from the Sentinel Hub service. 

### How it Works
two types of data: a high-resolution NDVI grid and a coarse-resolution LST grid.
We make two separate calls to the Sentinel Hub "Process API":
*   `fetchSentinel2Ndvi`: Gets Normalized Difference Vegetation Index (NDVI) data.
*   `fetchSentinel3Lst`: Gets Land Surface Temperature (LST) data.
3.  **Authentication**: Before making API calls, we use `getAccessToken` to obtain an OAuth token. This token is cached to avoid re-requesting it for every call.
4.  **Data Processing**: The API returns the processed data as a PNG image. The app then decodes this image (`decodeNdviPngToRaster`, `decodeLstPngToRaster`), converting the pixel grayscale values back into scientific data (NDVI values from -1.0 to 1.0, and temperature in Celsius).
5.  **Fallback**: If any API call fails, it generates synthetic data (`syntheticData`) so the app can still display something.

### Your Questions Answered

*   **How do I get the token?**
    The `getAccessToken` function handles this. It sends a `POST` request with the `client_id` and `client_secret` to the Sentinel Hub token endpoint. These credentials should be stored in the `SHConfig` struct (which is likely in another file). 
    Need to register for a free trial account on the [Sentinel Hub website](https://www.sentinel-hub.com/) to get your own client ID and secret.

*   **Which satellites are involved?**
    *   **Sentinel-2**: Used for high-resolution NDVI data. The code specifies `"sentinel-2-l2a"`.
    *   **Sentinel-3**: Used for coarse-resolution LST data, specifically from the SLSTR instrument. The code specifies `"sentinel-3-slstr"`.

*   **What are the endpoints?**
    The code uses two main endpoints, which are defined in the `SHConfig` struct:
    *   Token Endpoint: `SHConfig.tokenURL` (e.g., `https://services.sentinel-hub.com/oauth/token`)
    *   Process API Endpoint: `SHConfig.processURL` (e.g., `https://services.sentinel-hub.com/api/v1/process`)

*   **How is the data format?**
    *   **Request**: The app sends a `POST` request with a `JSON` body to the Process API. This JSON defines the geographical bounding box, time range, satellite source, and a custom JavaScript `evalscript` to process the data on the server.
    *   **Response**: The app requests and receives a `image/png`. The `evalscript` maps the scientific data (like NDVI or temperature) to a grayscale value (0-255) in the image. The app then decodes this image back into floating-point numbers.





## resources
Register for a free account on the Sentinel Hub website to get your own client ID and secret:  
https://www.sentinel-hub.com  

**Sentinel Hub documentation**. The "Process API" is the most relevant part for this code.
https://docs.sentinel-hub.com/api/latest/api/process/



