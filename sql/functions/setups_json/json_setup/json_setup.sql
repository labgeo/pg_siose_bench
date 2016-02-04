
--TODO:test as a function
CREATE OR REPLACE FUNCTION json_setup()
  RETURNS VOID AS
$func$
BEGIN

EXECUTE format('
-- Query returned successfully: 2477593 rows affected, 2100585 ms execution time.
CREATE TABLE siose.docstore_json AS(
	SELECT 
		gid,
		id_polygon,
		siose_code,
		geom,
		siose.json_builder(id_polygon) AS docs
	FROM siose.siose_polygons 
)


--Query returned successfully with no result in 7575 ms.
ALTER TABLE siose.docstore_json ADD PRIMARY KEY (gid);


--Remove the other tables
DROP TABLE siose.siose_attributes;
DROP TABLE siose.siose_coverages;
DROP TABLE siose.siose_polygons;
DROP TABLE siose.siose_values;');

END
$func$ LANGUAGE plpgsql;
