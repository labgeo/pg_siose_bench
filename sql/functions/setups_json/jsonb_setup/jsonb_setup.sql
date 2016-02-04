
--TODO:test as a function
CREATE OR REPLACE FUNCTION jsonb_setup()
  RETURNS VOID AS
$func$
BEGIN

EXECUTE format('
-- Query returned successfully: 2477593 rows affected, 2149777 ms execution time.
CREATE TABLE IF NOT EXISTS siose.docstore_jsonb AS(
	SELECT 
		gid,
		id_polygon,
		siose_code,
		geom,
		siose.json_builder(id_polygon)::jsonb AS docs
	FROM siose.siose_polygons 
)


--Columns indexing and maintenance
--Query returned successfully with no result in 7787 ms.
ALTER TABLE siose.docstore_jsonb ADD PRIMARY KEY (gid);

--Remove the other tables
DROP TABLE siose.siose_attributes;
DROP TABLE siose.siose_coverages;
DROP TABLE siose.siose_polygons;
DROP TABLE siose.siose_values;');

END
$func$ LANGUAGE plpgsql;
