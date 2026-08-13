-- PostGIS-ready schema for Dharti (atlas/shrug) repository
-- Created for India admin1 (states), admin2 (districts), admin3 (talukas)
-- Uses geometry column (MultiPolygon) in EPSG:4326

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;

-- Administrative regions (one row per polygon feature)
CREATE TABLE regions (
  id             BIGSERIAL PRIMARY KEY,
  shrid          TEXT NOT NULL UNIQUE,         -- canonical ID: IN-SS-DD-TT (TT optional)
  country_code   CHAR(2) NOT NULL DEFAULT 'IN',
  admin_level    SMALLINT NOT NULL,            -- 1=state, 2=district, 3=taluka
  name           TEXT NOT NULL,
  name_alt       TEXT,                         -- alternate names
  code_iso       TEXT,                         -- ISO 3166-2 where available (IN-XX)
  state_name     TEXT,                         -- parent state name (for admin2/admin3 convenience)
  district_name  TEXT,                         -- parent district name (for admin3)
  state_code     TEXT,                         -- state ISO/code
  district_code  TEXT,                         -- district code if present
  taluka_code    TEXT,                         -- taluka code if present
  capital        TEXT,                         -- for admin1 rows
  population     BIGINT,                       -- optional precomputed pop
  geom           geometry(MultiPolygon,4326),  -- geometry
  geom_simpl     geometry(MultiPolygon,4326),  -- simplified geometry for low-zoom display
  bbox           geometry(Polygon,4326),       -- optional bounding box
  centroid       geometry(Point,4326),
  metadata       JSONB DEFAULT '{}'            -- free-form per-region metadata & source references
);

CREATE INDEX idx_regions_admin_lvl ON regions(admin_level);
CREATE INDEX idx_regions_shrid ON regions (shrid);
CREATE INDEX idx_regions_geom_gist ON regions USING GIST (geom);
CREATE INDEX idx_regions_centroid ON regions USING GIST (centroid);

-- Country-level indicators by year
CREATE TABLE country_indicators (
  id           BIGSERIAL PRIMARY KEY,
  year         INTEGER NOT NULL,
  indicator    TEXT NOT NULL,      -- e.g., population, gdp_nominal_usd, literacy_total_pct
  value_num    NUMERIC,
  unit         TEXT,
  source       TEXT,
  source_url   TEXT,
  updated_at   TIMESTAMP DEFAULT now(),
  UNIQUE(year, indicator)
);

-- Region indicators (generic table; store numeric indicators per region and year)
CREATE TABLE region_indicators (
  id           BIGSERIAL PRIMARY KEY,
  shrid        TEXT NOT NULL REFERENCES regions(shrid) ON DELETE CASCADE,
  year         INTEGER,
  indicator    TEXT NOT NULL,      -- e.g., per_capita_consumption, rwi, mpi, literacy_total_pct
  value_num    NUMERIC,
  value_str    TEXT,               -- for non-numeric (category)
  unit         TEXT,
  source       TEXT,
  source_url   TEXT,
  updated_at   TIMESTAMP DEFAULT now(),
  UNIQUE(shrid, year, indicator)
);
CREATE INDEX idx_region_indicators_shrid ON region_indicators(shrid);
CREATE INDEX idx_region_indicators_indicator ON region_indicators(indicator);

-- Election results (example skeleton)
CREATE TABLE elections_results (
  id             BIGSERIAL PRIMARY KEY,
  shrid          TEXT NOT NULL REFERENCES regions(shrid),
  election_year  INTEGER NOT NULL,
  election_type  TEXT,             -- 'assembly', 'parliamentary'
  turnout_pct     NUMERIC,
  winner_party    TEXT,
  margin_pct      NUMERIC,
  votes_winner    BIGINT,
  votes_runnerup  BIGINT,
  source          TEXT,
  source_url      TEXT,
  UNIQUE(shrid, election_year, election_type)
);

-- Materialized precomputed legend buckets per indicator (so client reads precomputed bins)
CREATE TABLE indicator_legend (
  id           BIGSERIAL PRIMARY KEY,
  indicator    TEXT NOT NULL,
  year         INTEGER,
  num_bins     SMALLINT,
  bins_json    JSONB,              -- {"breaks":[...],"colors":[...],"method":"quantile"}
  updated_at   TIMESTAMP DEFAULT now(),
  UNIQUE(indicator, year)
);

-- Small table for primary non-farm employment sector per region
CREATE TABLE region_primary_sector (
  id         BIGSERIAL PRIMARY KEY,
  shrid      TEXT NOT NULL REFERENCES regions(shrid),
  year       INTEGER,
  top_sector TEXT,        -- e.g., "Manufacturing", "Trade", "Construction", "Services"
  share_pct  NUMERIC,
  source     TEXT,
  source_url TEXT,
  UNIQUE(shrid, year)
);

-- Convenience view for admin1 summary
CREATE VIEW states_summary AS
SELECT shrid, name, state_code, population, centroid, geom_simpl
FROM regions WHERE admin_level = 1;

-- End of schema
