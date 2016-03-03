
CREATE SCHEMA IF NOT EXISTS grids;

CREATE TYPE siose.grid AS (
  gcol  int4,
  grow  int4,
  geom geometry
);
