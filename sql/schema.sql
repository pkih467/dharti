-- PostGIS-ready schema for Dharti (atlas/shrug) repository
-- India admin1 (states), admin2 (districts), admin3 (talukas)
-- Uses geometry columns in EPSG:4326

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;

-- Administrative regions table
CREATE TABLE regions (
  id             BIGSERIAL PRIMARY KEY,
  shrid          TEXT NOT NULL UNIQUE,         -- canonical ID: IN-SS-DD-TT (TT optional)
  country_code   CHAR(2) NOT NULL DEFAULT 'IN',
  admin_level    SMALLINT NOT NULL,            -- 1=state, 2=district, 3=taluka
  name           TEXT NOT NULL,
  name_alt       TEXT,
  code_iso       TEXT,
  state_name     TEXT,
  district_name  TEXT,
  state_code     TEXT,
  district_code  TEXT,
  taluka_code    TEXT,
  capital        TEXT,
  population     BIGINT,
  geom           geometry(MultiPolygon,4326),
  geom_simpl     geometry(MultiPolygon,4326),
  bbox           geometry(Polygon,4326),
  centroid       geometry(Point,4326),
  metadata       JSONB DEFAULT '{}'
);

CREATE INDEX idx_regions_admin_lvl ON regions(admin_level);
CREATE INDEX idx_regions_shrid ON regions (shrid);
CREATE INDEX idx_regions_geom_gist ON regions USING GIST (geom);
CREATE INDEX idx_regions_centroid ON regions USING GIST (centroid);

-- Country-level indicators by year
CREATE TABLE country_indicators (
  id           BIGSERIAL PRIMARY KEY,
  year         INTEGER NOT NULL,
  indicator    TEXT NOT NULL,
  value_num    NUMERIC,
  unit         TEXT,
  source       TEXT,
  source_url   TEXT,
  updated_at   TIMESTAMP DEFAULT now(),
  UNIQUE(year, indicator)
);

-- Region indicators table
CREATE TABLE region_indicators (
  id           BIGSERIAL PRIMARY KEY,
  shrid        TEXT NOT NULL REFERENCES regions(shrid) ON DELETE CASCADE,
  year         INTEGER,
  indicator    TEXT NOT NULL,
  value_num    NUMERIC,
  value_str    TEXT,
  unit         TEXT,
  source       TEXT,
  source_url   TEXT,
  updated_at   TIMESTAMP DEFAULT now(),
  UNIQUE(shrid, year, indicator)
);
CREATE INDEX idx_region_indicators_shrid ON region_indicators(shrid);
CREATE INDEX idx_region_indicators_indicator ON region_indicators(indicator);

-- Elections skeleton
CREATE TABLE elections_results (
  id             BIGSERIAL PRIMARY KEY,
  shrid          TEXT NOT NULL REFERENCES regions(shrid),
  election_year  INTEGER NOT NULL,
  election_type  TEXT,
  turnout_pct     NUMERIC,
  winner_party    TEXT,
  margin_pct      NUMERIC,
  votes_winner    BIGINT,
  votes_runnerup  BIGINT,
  source          TEXT,
  source_url      TEXT,
  UNIQUE(shrid, election_year, election_type)
);

-- Indicator legend (precomputed buckets)
CREATE TABLE indicator_legend (
  id           BIGSERIAL PRIMARY KEY,
  indicator    TEXT NOT NULL,
  year         INTEGER,
  num_bins     SMALLINT,
  bins_json    JSONB,
  updated_at   TIMESTAMP DEFAULT now(),
  UNIQUE(indicator, year)
);

-- Primary non-farm sector per region
CREATE TABLE region_primary_sector (
  id         BIGSERIAL PRIMARY KEY,
  shrid      TEXT NOT NULL REFERENCES regions(shrid),
  year       INTEGER,
  top_sector TEXT,
  share_pct  NUMERIC,
  source     TEXT,
  source_url TEXT,
  UNIQUE(shrid, year)
);

-- Example convenience view for states
CREATE VIEW states_summary AS
SELECT shrid, name, state_code, population, centroid, geom_simpl
FROM regions WHERE admin_level = 1;
