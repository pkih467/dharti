# dharti – India atlas (SHRUG-style) data + MapLibre pipeline

This repository contains the pipeline, schema, and app skeleton to build a SHRUG-like India atlas:
- Admin boundaries (states / districts / talukas) sourced from DataMeet / Census / OSM
- Indicator tables and PostGIS schema
- Vector tile pipeline: mapshaper → tippecanoe → tileserver-gl
- Client: MapLibre GL JS (React skeleton) with legend, left accordion, search, highlight/pin and popup card.

Top-level files:
- sql/schema.sql                -- PostGIS DDL
- data/regions_states.json      -- 36 states / UTs metadata (names, ISO codes, capitals)
- scripts/build_tiles.sh        -- pipeline to fetch datameet, simplify, and build mbtiles
- scripts/run_tileserver.sh     -- serve mbtiles with Tileserver GL
- web/                          -- MapLibre React app skeleton (see below)
- sources.json                  -- metadata about data sources & licenses

Quick start (local):
1) Install prerequisites:
   - Node 18+, npm/yarn
   - mapshaper (npm i -g mapshaper) or via conda
   - tippecanoe (Linux/Mac; brew on Mac or compile)
   - Docker (for tileserver)

2) Build vector tiles (example)
   ./scripts/build_tiles.sh
   (inspect tilesource and adjust paths; some datameet files are per-state and require merging)

3) Serve tiles locally
   ./scripts/run_tileserver.sh
   Open http://localhost:8080 to see tile endpoint and tilejson.

4) Run the web app
   cd web
   npm install
   npm start
   Open http://localhost:3000 (or port from create-react-app)

Data sources & licensing
- Primary boundary source: DataMeet Maps (https://github.com/datameet/maps) — MIT license on repo; some files CC-BY-SA 4.0. Check per-file metadata and include attribution.
- Alternative / supplemental: GADM, Census of India (Census GIS), OpenStreetMap (ODbL). See sources.json for details.
- Indicator sources: NITI Aayog, NFHS, MoSPI, UDISE+, WorldPop, UN, IMF, World Bank, Meta RWI, Pew. Many are public; some (RWI, Meta) have separate terms — we provide access instructions and metadata for those.

Notes & caveats
- Taluka (admin3) coverage varies by source. DataMeet has many subdistrict shapefiles; some states require OSM extraction or Census shapefiles.
- For glitch-free client rendering we highly recommend vector tiles (MBTiles via tippecanoe) and MapLibre GL JS on the client.
- Precompute legend bins (indicator_legend) server-side and store them (indicator_legend table) so the client only reads JSON for color breaks and does not recompute heavy quantiles.

Next steps / TODO
- I will create example region_indicators CSV templates and populate country-level demographics (population/gdp/literacy/religion shares) from public sources and attach them as data/country_demographics.json if you want.
- If you'd like, I can prepare a completed sample MBTiles file for admin1+admin2 (reduced zoom) and a populated sample indicator dataset (district-level per-capita consumption, RWI sample) — note MBTiles distribution might be large; I can provide a small sample MBTiles for review.
