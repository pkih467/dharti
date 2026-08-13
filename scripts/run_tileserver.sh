#!/usr/bin/env bash
# Place india_admins.mbtiles in current directory or /data for the container
docker run --rm -it -v $(pwd):/data -p 8080:80 klokantech/tileserver-gl
# Visit: http://localhost:8080 to view tilejson and tiles
