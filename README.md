# dharti — India atlas

What this package contains
- sql/schema.sql: PostGIS-ready schema for regions and indicators.
- scripts/build_tiles.sh: pipeline to pull datameet maps, merge, simplify, and produce MBTiles via tippecanoe.
- scripts/run_tileserver.sh: serve MBTiles with Tileserver GL Docker image.
- data/: sample metadata, country_demographics.json, templates, and small GeoJSON preview fixtures.
- web/demo/index.html: single-file MapLibre demo (open in browser immediately).
- web/: scaffold for full React app (package.json).

Quick preview (no install) — open demo now
1. Locate `web/demo/index.html` in this folder.
2. Recommended: serve via a simple HTTP server to avoid file:// limitations:
   - Python (macOS): `cd web/demo && python3 -m http.server 8000`
   - Then open: http://localhost:8000/index.html
3. The demo uses embedded sample GeoJSON and MapLibre. Click a polygon to highlight, drop a pin, and open the info card.

Recommended local full setup (macOS) — produces vector tiles + tileserver + full app
Prerequisites (macOS)
- Homebrew (https://brew.sh/) installed.
- Install Docker Desktop for Mac: https://www.docker.com/products/docker-desktop
- Install tippecanoe: `brew install tippecanoe`
- Install mapshaper (node): `npm install -g mapshaper`
- (Optional) Node.js & npm: https://nodejs.org/ (for full React app)

Build tiles (one-time)
1. Make scripts executable: `chmod +x scripts/*.sh`
2. Run build: `./scripts/build_tiles.sh`
   - This clones datameet/maps, copies GeoJSON into `tilesource`, merges with `mapshaper`, and builds `mbtiles/india_admins.mbtiles` with `tippecanoe`.
   - If datameet layout differs, you may need to adjust the rsync/find patterns in the script.

Serve tiles (Tileserver GL)
1. Start Docker Desktop.
2. Run server: `./scripts/run_tileserver.sh`
3. Visit: http://localhost:8080 — Tileserver provides TileJSON and vector tile endpoints (e.g., `/data/india_admins.json` and `/data/india_admins/{z}/{x}/{y}.pbf`).

Run the web app (React dev)
1. `cd web`
2. `npm install`
3. `npm start`
4. Open http://localhost:3000 — edit config in `web/src` to point `TILEJSON_URL` to `http://localhost:8080/data/india_admins.json`.

Notes and guidance
- Taluka (admin3) coverage may vary by source. The build script copies whatever GeoJSON files are available in datameet/maps; inspect `tilesource/` to confirm coverage.
- For best client performance use MapLibre + vector tiles (this pipeline). The demo uses embedded GeoJSON only for preview and does not require a tileserver.
- Licensing: inspect `sources.json`. DataMeet, OSM, Census, IMF, UN, World Bank all have different licenses/terms — read them before redistributing data.
