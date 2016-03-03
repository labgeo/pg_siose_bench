

CREATE OR REPLACE FUNCTION reports.setup_log_query_plans()
  RETURNS VOID AS
$SETUP$


DECLARE 
script text;

BEGIN

script:= 

$literal$
--Create log table
CREATE TABLE reports.query_plans
(
  query_id text NOT NULL,
  grid_id text NOT NULL,
  cell_gid bigint NOT NULL,
  iteration integer NOT NULL,
  query_plan jsonb,
  CONSTRAINT query_plans_pkey PRIMARY KEY (query_id, grid_id, cell_gid, iteration)
);

--Index log table for queries combining query_id and grid_id
CREATE INDEX query_plans_query_id_grid_id_idx
  ON reports.query_plans
  USING btree
  (query_id COLLATE pg_catalog."default", grid_id COLLATE pg_catalog."default");

--Index log table for accessing query plan data using jsonb operators
CREATE INDEX query_plans_query_plan_idx
  ON reports.query_plans
  USING gin
  (query_plan);

ANALYZE;


CREATE OR REPLACE FUNCTION reports.log_query_plans(query_key text)
  RETURNS void AS
$BODY$
DECLARE
  grids text[] := ARRAY['spain_grid_1m', 'spain_grid_500k', 'spain_grid_200k', 
                        'spain_grid_100k', 'spain_grid_50k', 'spain_grid_25k', 'spain_grid_10k'];
  grid_key text;
  cell_key bigint;
  cell_geom geometry;
  log_entry reports.query_plans%ROWTYPE;
BEGIN
log_entry.query_id := query_key;
FOREACH grid_key IN ARRAY grids LOOP
  log_entry.grid_id := grid_key;
  FOR i IN 1..4 LOOP
    log_entry.iteration := i;    
    FOR cell_key, cell_geom IN EXECUTE format('SELECT gid, geom FROM grids.%I', grid_key) LOOP
      log_entry.cell_gid := cell_key;
      EXECUTE format('EXPLAIN (ANALYZE TRUE, FORMAT json) EXECUTE q(%L)', cell_geom) INTO log_entry.query_plan;
      INSERT INTO reports.query_plans (select log_entry.*) 
        ON CONFLICT (query_id, grid_id, cell_gid, iteration) 
        DO UPDATE SET (query_plan) = (log_entry.query_plan);
    END LOOP;
  END LOOP;
END LOOP;

DEALLOCATE q;
END;
$BODY$
LANGUAGE plpgsql VOLATILE;



$literal$;

EXECUTE script;


END
$SETUP$ 
LANGUAGE plpgsql;
