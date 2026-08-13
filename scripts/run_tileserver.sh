#!/usr/bin/env bash
# Serve MBTiles with Tileserver GL Docker image
# Requirements: Docker Desktop running
# Usage: ./scripts/run_tileserver.sh

BASE_DIR=$(cd "$(dirname "$0")/.." && pwd)
MBTILES="$BASE_DIR/mbtiles/india_admins.mbtiles"

if [ ! -f "$MBTILES" ]; then
  echo "MBTiles not found at $MBTILES"
  exit 1
fi

echo "Starting tileserver-gl on http://localhost:8080"
docker run --rm -it -v "$MBTILES":/data/india_admins.mbtiles -p 8080:80 klokantech/tileserver-gl
