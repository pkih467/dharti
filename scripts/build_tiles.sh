#!/usr/bin/env bash
set -euo pipefail

# 1) Clone DataMeet maps (or download specific geojson releases)
# (Note: datameet/maps is MIT; individual source files may have different licences - check each)
git clone https://github.com/datameet/maps.git datameet-maps
cd datameet-maps

# Example: find district/taluka GeoJSON paths. datameet repo organizes per-state folders:
# e.g., maps/India/districts/<state>/*.geojson or subdistricts/
# You may copy or aggregate relevant files into a single folder.
mkdir -p ../tilesource
# (This loop is illustrative — inspect datameet folder structure)
find . -type f -name "*district*.geojson" -exec cp {} ../tilesource/ \;
find . -type f -name "*subdistrict*.geojson" -exec cp {} ../tilesource/ \;

cd ../tilesource

# 2) Merge per-level files into single GeoJSON for tippecanoe, preserving a property admin_level
# Example: admin1 (states), admin2 (districts), admin3 (talukas) should be merged separately or merged with property admin_level
# If you have individual files per state, use jq/mapshaper to merge.

# Example using mapshaper to merge & simplify:
# Merge all GeoJSON into one, set admin_level based on file naming or pre-processing
mapshaper '*.geojson' -merge-layers -o merged_all.geojson

# Optionally create simplified geometry for low-zoom
mapshaper merged_all.geojson -simplify dp 5% keep-shapes -o merged_all_simplified.geojson

# 3) Tippecanoe: create MBTiles vector tiles (adjust max zoom -Z 12..14)
# name output mbtiles accordingly; drop densest features as needed
tippecanoe -o india_admins.mbtiles -z12 -Z0 --drop-densest-as-needed --extend-zooms-if-still-dropping merged_all.geojson

# 4) Export MBTiles as tileserver or host MBTiles directly with Tileserver GL
# (See README for tileserver-gl docker command)
echo "Built india_admins.mbtiles"
