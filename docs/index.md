<p align="center">
  <picture>
    <source srcset="assets/logo/logo-dark.png" media="(prefers-color-scheme: dark)">
    <img src="assets/logo/logo-light.png" alt="CoolCities logo" width="280">
  </picture>
</p>

<div style="text-align:center;">
  <h1 style="font-size:56px">CoolCities</h1>
  <h1 style="font-size:40px">3rd Prize Cassini Hackathon 2025</h1>
  <h2 style="font-size:40px">Germany</h2>
</div>

## Team

- [Stephen](https://github.com/sjtobin) – Cognitive scientist and linguist (PhD) with experience in data analysis and computational modeling. Brings systems thinking and user insight to connect data and experience.
- [Laurent](https://github.com/multitudes) – iOS engineer with expertise in Swift, UX, and frontend development. Leads interface design and implementation, turning concepts into intuitive user experiences.
- [Jen](https://github.com/jng-jng) - User experience expert, her role is to manage and analyze all customer and potential customer interactions and data
- [Matthias](https://github.com/uschi909) – Data scientist specializing in analysis and modeling. Handles data processing and fusion of Sentinel and Galileo datasets into usable temperature and navigation layers.

## Our Idea
- Category "Beyond Horizons – Redefining Travel with Space Innovation"

CoolCities helps tourists and locals plan their days and routes to stay comfortable during hot weather and to avoid heat exposure. Using high-resolution satellite-derived temperature and vegetation maps, the app identifies cooler streets, shaded paths, parks and green corridors and suggests alternative routes and transport modes (walking, bikes, scooters, rollers) that prioritize lower heat exposure. The suggestions aim at improving comfort and health while encouraging low‑emission, active mobility.

### Why this matters

- Climate warming is increasing the number, extent and severity of very hot places worldwide. Urban areas are particularly affected: dense built materials (asphalt, concrete), multi-lane roads, traffic, tall buildings that trap heat, and clusters of electrical equipment create urban heat islands and strong microclimates.
- These microclimates mean some city blocks — busy streets, enclosed courtyards, or areas with little vegetation — can be much hotter than nearby locations. That difference matters for comfort, health (heat stress), and tourism experience.
- By combining Sentinel-2 and Sentinel-3 observations with processing and downscaling methods, we can produce high-resolution surface-temperature and vegetation maps (targeting ~10 m spatial precision). With calibration and modelling, these layers allow us to infer near-ground walking-level temperatures and identify cooler corridors at neighborhood scale.
- With those layers we can offer routing that trades a small amount of travel time for substantially lower heat exposure — e.g., a shaded bike route instead of a sunny arterial — benefiting tourists and locals during hot months in Europe and year-round in tropical regions. This routing is useful for general users and especially important for heat-vulnerable people.

**Limitations & considerations:** the app uses aggregated environmental layers and modelling to infer near-ground conditions; local shading, micro-sprinklers, or transient heat sources may cause variations. Routing decisions should also weigh safety, accessibility, and user preferences.

## Use of EU Space Technologies
CoolCities combines data from Copernicus Sentinel 2 and 3 to detect land temperature and vegetation cooling, providing temperature maps at 10 m resolution.  
Galileo global navigation satellites provide precise positioning for routing through the temperature map.  
CoolCities translates EU space data into user comfort and wellness.

## How we use the data
[See the data aspect of the project here](data.md)



## Resources
The Cassini Hackathon 2025 call for submissions:  
https://www.cassini.eu/hackathons/germany

Our project page:  
https://taikai.network/cassinihackathons/hackathons/eu-space-consumer-experience/projects/cmhoxqgry003vxtcrhox121xq/idea 

Business Design Playbook:  
https://www.cassini.eu/hackathons/sites/default/files/2024-11/Business%20Design%20Playbook_update.pdf  

Air Pollution API concept:
https://openweathermap.org/api/air-pollution  

Overpass-turbo is a web-based data mining and visualization tool for OpenStreetMap:
https://overpass-turbo.eu  

A similar open source project which is more general in scope:
https://www.hotmaps-project.eu
which then moved to:
https://citiwatts.eu  
https://citiwatts.eu/map   

Some tools at our didposition:
https://www.cassini.eu/hackathons/tools  

Participants Playbook:
https://www.cassini.eu/hackathons/sites/default/files/2025-11/Participant%20Playbook_10th%20CASSINI%20Hackathon_1.pdf  

Previous Hackathons code base for inspiration:
https://github.com/cassinihackathons  


Some interesting Hardware we did not have the chance to inspect yet:
https://kineis.com  

The satellites:
https://dataspace.copernicus.eu/data-collections/copernicus-sentinel-missions  


