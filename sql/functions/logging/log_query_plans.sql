
CREATE OR REPLACE FUNCTION siose.log_query_plans(query_key text)
  RETURNS void AS
$BODY$
DECLARE
  grids text[] := ARRAY['spain_grid_1m', 'spain_grid_500k', 'spain_grid_200k', 
                        'spain_grid_100k', 'spain_grid_50k', 'spain_grid_25k', 'spain_grid_10k'];
  grid_key text;
  cell_key bigint;
  cell_geom geometry;
  log_entry siose.query_plans%ROWTYPE;
BEGIN
log_entry.query_id := query_key;
FOREACH grid_key IN ARRAY grids LOOP
  log_entry.grid_id := grid_key;
  FOR i IN 1..4 LOOP
    log_entry.iteration := i;    
    FOR cell_key, cell_geom IN EXECUTE format('SELECT gid, geom FROM siose.%I', grid_key) LOOP
      log_entry.cell_gid := cell_key;
      EXECUTE format('EXPLAIN (ANALYZE TRUE, FORMAT json) EXECUTE q(%L)', cell_geom) INTO log_entry.query_plan;
      INSERT INTO siose.query_plans (select log_entry.*) 
        ON CONFLICT (query_id, grid_id, cell_gid, iteration) 
        DO UPDATE SET (query_plan) = (log_entry.query_plan);
    END LOOP;
  END LOOP;
END LOOP;

DEALLOCATE q;
END;
$BODY$
LANGUAGE plpgsql VOLATILE;
