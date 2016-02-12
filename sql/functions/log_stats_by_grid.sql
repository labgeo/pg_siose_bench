--TODO: Add parameters for number of iterations or warm-up iteration
CREATE OR REPLACE FUNCTION siose.log_stats_by_grid(_grid_name text)
  RETURNS TABLE (
	grid_name text,
	query_id text,   -- visible as OUT parameter inside and outside function
	total_polygons numeric,
	total_returned_rows bigint,
	total_returned_polygons_perc numeric,
	total_execution_time numeric,
	avg_execution_time numeric,
	stdev_execution_time numeric,
	polygons_per_ms numeric) AS
$func$
BEGIN
RETURN QUERY

EXECUTE format(E'
WITH tests AS(
	SELECT query_id, query_plan, grid_id, polycount
	FROM siose.query_plans
	JOIN siose.%I ON cell_gid=gid
	WHERE iteration != 1 AND grid_id = \'%I\'
),
full_experiment AS(
	--Aggregate data
	SELECT query_id,
		sum(polycount) AS total_polygons,
		sum((query_plan->0->\'Plan\'->>\'Actual Rows\')::integer) AS total_actual_rows,
 
		sum((query_plan->0->>\'Execution Time\')::numeric) AS total_execution_time,
		avg((query_plan->0->>\'Execution Time\')::numeric) AS avg_execution_time,
		stddev((query_plan->0->>\'Execution Time\')::numeric) AS stdev_execution_time

	FROM tests
	GROUP BY 1 ORDER BY 1
),
reference_values AS(
	SELECT query_id,
		total_polygons/3 AS total_polygons,
		total_actual_rows/3 AS total_returned_rows,
		(((total_actual_rows/3) / (total_polygons/3))*100) AS total_returned_polygons_perc,

		total_execution_time/3 AS total_execution_time,
		avg_execution_time,
		stdev_execution_time


	FROM full_experiment	
)

SELECT \'%I\'::text AS grid_name, *, total_polygons/total_execution_time AS polygons_per_ms FROM reference_values;', _grid_name, _grid_name, _grid_name);

RETURN;

END
$func$  LANGUAGE plpgsql;


--SELECT * FROM siose.log_stats_by_grid('spain_grid_1m')