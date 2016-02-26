
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
DROP TABLE siose.siose_values;


--Query returned successfully with no result in 29828 ms.
CREATE INDEX IF NOT EXISTS docstore_jsonb_geom_idx
  ON siose.docstore_jsonb
  USING gist
  (geom);

CREATE INDEX docstore_jsonb_docs_idx
  ON siose.docstore_jsonb
  USING gin
  (docs);

--Query returned successfully with no result in 161451 ms.
CLUSTER siose.docstore_jsonb USING docstore_jsonb_geom_idx;

--Query returned successfully with no result in 816 ms.
ANALYZE siose.docstore_jsonb;

');

END
$func$ LANGUAGE plpgsql;
