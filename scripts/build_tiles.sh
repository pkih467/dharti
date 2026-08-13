#!/usr/bin/env bash
set -euo pipefail

# Build vector tiles (MBTiles) from GeoJSON sources (datameet/maps)
# REQUIREMENTS (macOS):
#  - git, node, mapshaper (npm i -g mapshaper), tippecanoe (brew install tippecanoe)
# Usage: ./scripts/build_tiles.sh
BASE_DIR=$(cd "$(dirname "$0")/.." && pwd)
mkdir -p "$BASE_DIR/tilesource" "$BASE_DIR/mbtiles" "$BASE_DIR/tmp"

echo "1) Cloning datameet/maps (if not present)..."
if [ ! -d "$BASE_DIR/datameet-maps" ]; then
  git clone https://github.com/datameet/maps.git "$BASE_DIR/datameet-maps"
else
  echo "datameet-maps already cloned; pulling latest..."
  git -C "$BASE_DIR/datameet-maps" pull --ff-only || true
fi

echo "2) Copying geojson into tilesource (state/district/subdistrict where available)..."
# This is a conservative copy; adjust patterns based on datameet layout.
rsync -av --include='*/' --include='*.geojson' --exclude='*' "$BASE_DIR/datameet-maps/" "$BASE_DIR/tilesource/"

echo "3) Merging GeoJSON files into single merged_all.geojson (admin level property may be present)"
cd "$BASE_DIR/tilesource"
# If files have different properties, mapshaper will merge attributes.
mapshaper '*.geojson' -merge-layers -o "$BASE_DIR/tmp/merged_all.geojson" force

echo "4) Simplify geometry for faster tile generation (create simplified version)"
mapshaper "$BASE_DIR/tmp/merged_all.geojson" -simplify dp 5% keep-shapes -o "$BASE_DIR/tmp/merged_all_simplified.geojson" force

echo "5) Build MBTiles with tippecanoe (vector tiles). Adjust -z / -Z for zoom range."
tippecanoe -o "$BASE_DIR/mbtiles/india_admins.mbtiles" -zg --drop-densest-as-needed --extend-zooms-if-still-dropping "$BASE_DIR/tmp/merged_all.geojson"

echo "Built MBTiles at: $BASE_DIR/mbtiles/india_admins.mbtiles"
