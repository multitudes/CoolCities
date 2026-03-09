#!/usr/bin/env python3
"""
High-Resolution Temperature using DisTrad Method
Creates individual map files for pitch deck
Method simplified from: Kustas et al. (2003) and Essa et al. (2023)
"""
import os
import time
import openeo
import rasterio
import numpy as np
import matplotlib.cm as cm
import matplotlib.pyplot as plt
import matplotlib.colors as colors

from PIL import Image
from datetime import datetime, timedelta
from scipy.ndimage import zoom, uniform_filter
from matplotlib.colors import LinearSegmentedColormap

connection = openeo.connect("https://openeo.dataspace.copernicus.eu")
connection.authenticate_oidc()

demo_bounds = {
    "west": 13.20,
    "south": 52.45,
    "east": 13.75,
    "north": 52.58
}

# Heat wave period for best demonstration
temporal_extent = ["2018-07-15", "2018-08-15"]

print("=" * 60)
print("High-Resolution LST - DisTrad-inspired Method (Demo Area)")
print("=" * 60)
print(f"\n📍 Area: Berlin/Brandenburg region")
print(f"   Bounds: {demo_bounds}")
print(f"📅 Period: {temporal_extent[0]} to {temporal_extent[1]}")

# Step 1: Get high-resolution NDVI (10m) from Sentinel-2
print("\n📡 Step 1: Loading Sentinel-2 NDVI (10m resolution)...")

s2_datacube = connection.load_collection(
    "SENTINEL2_L2A",
    spatial_extent=demo_bounds,
    temporal_extent=temporal_extent,
    bands=["B04", "B08"]
)

ndvi = s2_datacube.ndvi(red="B04", nir="B08")
ndvi_10m = ndvi.max_time()

result_ndvi = ndvi_10m.save_result(format="GTiff")
job_ndvi = result_ndvi.create_job(title="Demo_NDVI_10m")

# Step 2: Get low-resolution LST (1km) from Sentinel-3
print("📡 Step 2: Loading Sentinel-3 LST (1km resolution)...")

s3_datacube = connection.load_collection(
    "SENTINEL3_SLSTR",
    spatial_extent=demo_bounds,
    temporal_extent=temporal_extent,
    bands=["S8"]
)

lst_1km = s3_datacube.max_time()

result_lst = lst_1km.save_result(format="GTiff")
job_lst = result_lst.create_job(title="Demo_LST_1km")

# Launch jobs concurrently
print("\n🚀 Jobs running concurrently...")
job_ndvi.start_job()
job_lst.start_job()

# Wait for completion
print("⏳ Waiting for jobs to complete...")

while True:
    status_ndvi = job_ndvi.status()
    status_lst = job_lst.status()
    
    print(f"  NDVI: {status_ndvi:12}, LST: {status_lst:12}", end='\r')
    
    if status_ndvi == 'finished' and status_lst == 'finished':
        print("\n✅ Both jobs complete!")
        break
    elif 'error' in [status_ndvi, status_lst]:
        print("\n❌ Job failed!")
        break
    
    time.sleep(20)

print("\n📥 Downloading results...")
job_ndvi.get_results().download_files("./demo_output/ndvi_10m")
job_lst.get_results().download_files("./demo_output/lst_1km")

print("\n🔬 Applying DisTrad downscaling algorithm...")

# Load NDVI (10m resolution)
with rasterio.open('./demo_output/ndvi_10m/openEO.tif') as src:
    ndvi_10m_data = src.read(1)
    profile_10m = src.profile
    height_10m, width_10m = ndvi_10m_data.shape

print(f"   NDVI shape: {ndvi_10m_data.shape} (10m resolution)")

# Load LST (1km resolution)  
with rasterio.open('./demo_output/lst_1km/openEO.tif') as src:
    lst_1km_data = src.read(1)
    # use mean where there is no data
    lst_1km_data = np.where(np.isnan(lst_1km_data),
                        np.nanmean(lst_1km_data),
                        lst_1km_data)
    height_1km, width_1km = lst_1km_data.shape

print(f"   LST shape: {lst_1km_data.shape} (1km resolution)")

# Convert LST from Kelvin to Celsius (if needed)
if np.nanmean(lst_1km_data) > 200:
    lst_1km_data = lst_1km_data - 273.15
    print(f"   Converted LST from Kelvin to Celsius")

# Create low-resolution NDVI by aggregating high-res NDVI
scale_factor = height_10m / height_1km
print(f"   Scale factor: {scale_factor:.1f}x")

# Downsample NDVI to match LST resolution
block_size = int(scale_factor)
ndvi_1km_data = uniform_filter(ndvi_10m_data, size=block_size, mode='nearest')[::block_size, ::block_size]

# Crop to shared extent
min_height = min(lst_1km_data.shape[0], ndvi_1km_data.shape[0])
min_width  = min(lst_1km_data.shape[1], ndvi_1km_data.shape[1])
lst_1km_data = lst_1km_data[:min_height, :min_width]
ndvi_1km_data = ndvi_1km_data[:min_height, :min_width]

# Ensure shapes match
if ndvi_1km_data.shape != lst_1km_data.shape:
    zoom_factors = (lst_1km_data.shape[0] / ndvi_1km_data.shape[0],
                    lst_1km_data.shape[1] / ndvi_1km_data.shape[1])
    ndvi_1km_data = zoom(ndvi_1km_data, zoom_factors, order=1)

print(f"   Downsampled NDVI shape: {ndvi_1km_data.shape}")

# Upsample LST to 10m resolution
zoom_factors = (height_10m / height_1km, width_10m / width_1km)
lst_10m_upsampled = zoom(lst_1km_data, zoom_factors, order=1)

# Upsample low-res NDVI to 10m for calculation
ndvi_1km_upsampled = zoom(ndvi_1km_data, zoom_factors, order=1)

print(f"   Upsampled to 10m: {lst_10m_upsampled.shape}")

# Ratio-based thermal sharpening (simplified approach inspired by DisTrad)
# alpha controls the strength of the NDVI-driven temperature adjustment
alpha = 0.7

# Clip NDVI to reasonable range
ndvi_10m_data = np.clip(ndvi_10m_data, -0.2, 1.0)
ndvi_1km_upsampled = np.clip(ndvi_1km_upsampled, -0.2, 1.0)

# Avoid division by zero - use slightly positive values
ndvi_1km_upsampled = np.where(np.abs(ndvi_1km_upsampled) < 0.01, 0.01, ndvi_1km_upsampled)
ndvi_10m_data = np.where(np.abs(ndvi_10m_data) < 0.01, 0.01, ndvi_10m_data)

# Apply DisTrad with bounds checking
min_height = min(ndvi_10m_data.shape[0], ndvi_1km_upsampled.shape[0])
min_width  = min(ndvi_10m_data.shape[1], ndvi_1km_upsampled.shape[1])

ndvi_10m_data = ndvi_10m_data[:min_height, :min_width]
ndvi_1km_upsampled = ndvi_1km_upsampled[:min_height, :min_width]
lst_10m_upsampled = lst_10m_upsampled[:min_height, :min_width]

ndvi_ratio = ndvi_10m_data / ndvi_1km_upsampled

# Prevents extreme temperature values
ndvi_ratio = np.clip(ndvi_ratio, 0.5, 2.0)

# Suppress runtime warning for this operation
with np.errstate(invalid='ignore'):
    lst_10m_sharpened = lst_10m_upsampled * (ndvi_ratio ** alpha)


# Additional constraint: Keep temperatures within reasonable range
# Based on the original LST range
lst_min_reasonable = np.nanmin(lst_1km_data) - 5  # Allow 5°C below original
lst_max_reasonable = np.nanmax(lst_1km_data) + 10  # Allow 10°C above original

lst_10m_sharpened = np.clip(lst_10m_sharpened, lst_min_reasonable, lst_max_reasonable)

# Mask invalid values
# lst_10m_sharpened = np.ma.masked_invalid(lst_10m_sharpened)
lst_10m_sharpened = np.nan_to_num(lst_10m_sharpened, nan=np.nanmean(lst_10m_sharpened))
lst_10m_sharpened = np.ma.masked_less(lst_10m_sharpened, -20)
lst_10m_sharpened = np.ma.masked_greater(lst_10m_sharpened, 60)

print(f"\n🌡️ Temperature Statistics (DisTrad-inspired Method):")
print(f"   Original 1km LST:")
print(f"     Min:  {np.nanmin(lst_1km_data):.1f}°C")
print(f"     Max:  {np.nanmax(lst_1km_data):.1f}°C")
print(f"     Mean: {np.nanmean(lst_1km_data):.1f}°C")
print(f"\n   Sharpened 10m LST:")
print(f"     Min:  {np.nanmin(lst_10m_sharpened):.1f}°C")
print(f"     Max:  {np.nanmax(lst_10m_sharpened):.1f}°C")
print(f"     Mean: {np.nanmean(lst_10m_sharpened):.1f}°C")
print(f"     Resolution: 10 meters")

h, w = lst_10m_sharpened.shape
new_profile = profile_10m.copy()
new_profile.update({
    "height": h,
    "width": w,
    "dtype": "float32",
    "count": 1,
    "nodata": -9999.0,
    "compress": "deflate",
    "tiled": True
})

# --- Write dataset with explicit dimensions and nodata ---
with rasterio.open('./demo_output/temperature_10m_demo.tif', 'w', **new_profile) as dst:
    data_out = np.where(np.isfinite(lst_10m_sharpened),
                        lst_10m_sharpened, -9999.0).astype(np.float32)
    dst.write(data_out, 1)

print("\n✅ GeoTIFF correctly written with matching dimensions:")
print(f"   → height: {h}, width: {w}, dtype: float32")

print("\n✅ GeoTIFF saved: ./demo_output/temperature_10m_demo.tif")

# DEBUG 
with rasterio.open('./demo_output/temperature_10m_demo.tif') as src:
    arr = src.read(1)
    prof = src.profile

print("TIFF shape:", arr.shape)
print("dtype:", arr.dtype)
print("finite count:", np.sum(np.isfinite(arr)))
print("nan count:", np.sum(np.isnan(arr)))
print("min/max (finite):", np.nanmin(arr), np.nanmax(arr))
print("profile:", prof)


# ============================================================================
# CREATE INDIVIDUAL MAP EXPORTS FOR PITCH DECK
# ============================================================================

print("\n🎨 Creating individual map exports...")

# Check if demo image exists, otherwise use default dimensions
demo_path = 'image.png'
if os.path.exists(demo_path):
    demo = Image.open(demo_path)
    demo_width, demo_height = demo.size
    print(f"   Using demo dimensions: {demo_width}x{demo_height}")
else:
    print(f"   ⚠️  Demo image not found, using default dimensions")
    demo_width, demo_height = 792, 506
    print(f"   Default dimensions: {demo_width}x{demo_height}")

aspect_ratio = demo_width / demo_height
print(f"   Aspect ratio: {aspect_ratio:.2f}")

# Define colormaps
temp_colors = ['#0000FF', '#4169E1', '#00BFFF', '#00FFFF',
               '#7FFF00', '#FFFF00', '#FFD700',
               '#FFA500', '#FF4500', '#FF0000', '#8B0000']
temp_cmap = LinearSegmentedColormap.from_list('temperature', temp_colors, N=256)

ndvi_cmap = 'RdYlGn'
diff_cmap = 'RdBu_r'

# Figure settings
fig_width = 10
fig_height = fig_width / aspect_ratio
dpi = 150

# Use reasonable bounds (already calculated)
temp_vmin = lst_min_reasonable
temp_vmax = lst_max_reasonable

print(f"\n   Using temperature range: {temp_vmin:.1f}°C to {temp_vmax:.1f}°C")

# ============================================================================
# MAP 1: Original Sentinel-3 LST (1km upsampled)
# ============================================================================

print("\n   Creating Map 1: Original LST (1km)...")

# With legend
fig, ax = plt.subplots(figsize=(fig_width, fig_height), dpi=dpi)
im = ax.imshow(lst_10m_upsampled, cmap=temp_cmap, vmin=temp_vmin, vmax=temp_vmax, interpolation='bilinear')
ax.set_title('Original Sentinel-3 LST (1km)\nUpsampled to 10m', fontsize=14, weight='bold', pad=15)
ax.axis('off')
cbar = plt.colorbar(im, ax=ax, shrink=0.85, pad=0.02)
cbar.set_label('Temperature (°C)', fontsize=12, weight='bold')
cbar.ax.tick_params(labelsize=10)
plt.tight_layout()
plt.savefig('./demo_output/1_original_lst_WITH_LEGEND.png', dpi=dpi, bbox_inches='tight', facecolor='white')
plt.close()

# Without legend (clean)
fig, ax = plt.subplots(figsize=(fig_width, fig_height), dpi=dpi)
fig.patch.set_alpha(0)
ax.set_aspect('equal')
ax.imshow(lst_10m_upsampled, cmap=temp_cmap, vmin=temp_vmin, vmax=temp_vmax, interpolation='bilinear')
ax.axis('off')
plt.subplots_adjust(left=0, right=1, top=1, bottom=0, wspace=0, hspace=0)
plt.savefig('./demo_output/1_original_lst_CLEAN.png', dpi=dpi, bbox_inches='tight', 
            pad_inches=0, transparent=True)
plt.close()

print("      ✓ 1_original_lst_WITH_LEGEND.png")
print("      ✓ 1_original_lst_CLEAN.png")

# ============================================================================
# MAP 2: Sentinel-2 NDVI (10m)
# ============================================================================

print("   Creating Map 2: NDVI (10m)...")

# With legend
fig, ax = plt.subplots(figsize=(fig_width, fig_height), dpi=dpi)
im = ax.imshow(ndvi_10m_data, cmap=ndvi_cmap, vmin=-0.2, vmax=0.8, interpolation='bilinear')
ax.set_title('Sentinel-2 NDVI (10m)', fontsize=14, weight='bold', pad=15)
ax.axis('off')
cbar = plt.colorbar(im, ax=ax, shrink=0.85, pad=0.02)
cbar.set_label('NDVI', fontsize=12, weight='bold')
cbar.ax.tick_params(labelsize=10)
plt.tight_layout()
plt.savefig('./demo_output/2_ndvi_10m_WITH_LEGEND.png', dpi=dpi, bbox_inches='tight', facecolor='white')
plt.close()

# Without legend (clean)
fig, ax = plt.subplots(figsize=(fig_width, fig_height), dpi=dpi)
fig.patch.set_alpha(0)
ax.set_aspect('equal')
ax.imshow(ndvi_10m_data, cmap=ndvi_cmap, vmin=-0.2, vmax=0.8, interpolation='bilinear')
ax.axis('off')
plt.subplots_adjust(left=0, right=1, top=1, bottom=0, wspace=0, hspace=0)
plt.savefig('./demo_output/2_ndvi_10m_CLEAN.png', dpi=dpi, bbox_inches='tight', 
            pad_inches=0, transparent=True)
plt.close()

print("      ✓ 2_ndvi_10m_WITH_LEGEND.png")
print("      ✓ 2_ndvi_10m_CLEAN.png")

# ============================================================================
# MAP 3: DisTrad Sharpened LST (10m) - THE MAIN OUTPUT
# ============================================================================

print("   Creating Map 3: DisTrad Sharpened LST (10m)...")

# With legend
fig, ax = plt.subplots(figsize=(fig_width, fig_height), dpi=dpi)
im = ax.imshow(lst_10m_sharpened, cmap=temp_cmap, vmin=temp_vmin, vmax=temp_vmax, interpolation='bilinear')
ax.set_title('DisTrad Sharpened LST (10m)\nKustas et al. (2003)-inspired Method', 
             fontsize=14, weight='bold', pad=15)
ax.axis('off')
cbar = plt.colorbar(im, ax=ax, shrink=0.85, pad=0.02)
cbar.set_label('Temperature (°C)', fontsize=12, weight='bold')
cbar.ax.tick_params(labelsize=10)
plt.tight_layout()
plt.savefig('./demo_output/3_sharpened_lst_10m_WITH_LEGEND.png', dpi=dpi, bbox_inches='tight', facecolor='white')
plt.close()

# Without legend (clean) - Demo Overlay
fig, ax = plt.subplots(figsize=(fig_width, fig_height), dpi=dpi)
fig.patch.set_alpha(0)
ax.set_aspect('equal')
ax.imshow(lst_10m_sharpened, cmap=temp_cmap, vmin=temp_vmin, vmax=temp_vmax, interpolation='bilinear')
ax.axis('off')
plt.subplots_adjust(left=0, right=1, top=1, bottom=0, wspace=0, hspace=0)
plt.savefig('./demo_output/3_sharpened_lst_10m_CLEAN.png', dpi=dpi, bbox_inches='tight', 
            pad_inches=0, transparent=True)
plt.close()

print("      ✓ 3_sharpened_lst_10m_WITH_LEGEND.png")
print("      ✓ 3_sharpened_lst_10m_CLEAN.png ⭐ MAIN OVERLAY")

# ============================================================================
# MAP 4: Difference Map (shows the improvement)
# ============================================================================

print("   Creating Map 4: Temperature Adjustment...")

difference = lst_10m_sharpened - lst_10m_upsampled

# With legend
fig, ax = plt.subplots(figsize=(fig_width, fig_height), dpi=dpi)
im = ax.imshow(difference, cmap=diff_cmap, vmin=-5, vmax=5, interpolation='bilinear')
ax.set_title('Temperature Adjustment\n(Sharpened - Original)', 
             fontsize=14, weight='bold', pad=15)
ax.axis('off')
cbar = plt.colorbar(im, ax=ax, shrink=0.85, pad=0.02)
cbar.set_label('ΔT (°C)', fontsize=12, weight='bold')
cbar.ax.tick_params(labelsize=10)
plt.tight_layout()
plt.savefig('./demo_output/4_difference_map_WITH_LEGEND.png', dpi=dpi, bbox_inches='tight', facecolor='white')
plt.close()

# Without legend (clean)
fig, ax = plt.subplots(figsize=(fig_width, fig_height), dpi=dpi)
fig.patch.set_alpha(0)
ax.set_aspect('equal')
ax.imshow(difference, cmap=diff_cmap, vmin=-5, vmax=5, interpolation='bilinear')
ax.axis('off')
plt.subplots_adjust(left=0, right=1, top=1, bottom=0, wspace=0, hspace=0)
plt.savefig('./demo_output/4_difference_map_CLEAN.png', dpi=dpi, bbox_inches='tight', 
            pad_inches=0, transparent=True)
plt.close()

print("      ✓ 4_difference_map_WITH_LEGEND.png")
print("      ✓ 4_difference_map_CLEAN.png")

# ============================================================================
# BONUS: Transparent overlay at 60% alpha matching demo size exactly
# ============================================================================

print("\n   Creating exact size overlay...")

fig, ax = plt.subplots(figsize=(demo_width/100, demo_height/100), dpi=100)
fig.patch.set_alpha(0)
ax.set_aspect('auto')  # allow full data extent instead of forced equal ratio
ax.imshow(lst_10m_sharpened, cmap=temp_cmap, alpha=0.6,
          vmin=temp_vmin, vmax=temp_vmax, interpolation='bilinear',
          extent=[0, lst_10m_sharpened.shape[1], 0, lst_10m_sharpened.shape[0]])
ax.axis('off')
plt.subplots_adjust(left=0, right=1, top=1, bottom=0, wspace=0, hspace=0)
plt.savefig('./demo_output/OVERLAY_FOR_DEMO.png',
            dpi=100, bbox_inches=None, pad_inches=0, transparent=True)
plt.close()

print(f"      ✓ OVERLAY_FOR_DEMO.png ({demo_width}x{demo_height}, 60% alpha)")

# ============================================================================
# Summary
# ============================================================================

print("\n" + "=" * 60)
print("✨ ALL MAPS EXPORTED!")
print("=" * 60)
print("\nFiles created in ./demo_output/:")
print("\n  📊 WITH LEGEND (for explanation slides):")
print("     1_original_lst_WITH_LEGEND.png")
print("     2_ndvi_10m_WITH_LEGEND.png")
print("     3_sharpened_lst_10m_WITH_LEGEND.png")
print("     4_difference_map_WITH_LEGEND.png")
print("\n  🎨 CLEAN (for overlays/design):")
print("     1_original_lst_CLEAN.png")
print("     2_ndvi_10m_CLEAN.png")
print("     3_sharpened_lst_10m_CLEAN.png ⭐")
print("     4_difference_map_CLEAN.png")
print("\n  📱 SPECIAL:")
print("     OVERLAY_FOR_DEMO.png (exact demo size)")
print("\n  💾 DATA:")
print("     temperature_10m_demo.tif (GeoTIFF)")
print("=" * 60)
print(f"\n🎯 Temperature range: {temp_vmin:.1f}°C to {temp_vmax:.1f}°C")
print("=" * 60)




with rasterio.open('./demo_output/temperature_10m_demo.tif') as src:
    data = src.read(1)
    prof = src.profile

norm = colors.Normalize(vmin=np.nanmin(data), vmax=np.nanmax(data), clip=True)
data_norm = norm(data)
cmap = cm.get_cmap('jet')
rgba = cmap(data_norm)
rgb = (rgba[..., :3] * 255).astype('uint8')

rgb_profile = prof.copy()
rgb_profile.update(dtype='uint8', count=3, nodata=0)

with rasterio.open('./demo_output/temperature_10m_demo_rgb.tif', 'w', **rgb_profile) as dst:
    for i in range(3):
        dst.write(rgb[..., i], i + 1)

print("✅ Saved: temperature_10m_demo_rgb.tif (RGB colorized version)")
