

CREATE OR REPLACE FUNCTION siose.jsonb_setup()
  RETURNS VOID AS
$BODY$

DECLARE
script text;

BEGIN

script:= $literal$

-- JSON returned successfully: 2477593 rows affected, 2149777 ms execution time.
-- JSONB 5108119 ms
CREATE TABLE IF NOT EXISTS sioseb.docstore_jsonb AS(
	SELECT 
		gid,
		id_polygon,
		siose_code,
		geom,
		siose.json_builder(id_polygon)::jsonb AS docs
	FROM siose.siose_polygons 
);


--Columns indexing and maintenance
--Query returned successfully with no result in 7787 ms.
ALTER TABLE sioseb.docstore_jsonb ADD PRIMARY KEY (gid);

--We don't remove the other tables. The user will.
--DROP TABLE siose.siose_attributes;
--DROP TABLE siose.siose_coverages;
--DROP TABLE siose.siose_polygons;
--DROP TABLE siose.siose_values;


--Query returned successfully with no result in 29828 ms.
CREATE INDEX IF NOT EXISTS docstore_jsonb_geom_idx
  ON sioseb.docstore_jsonb
  USING gist
  (geom);

CREATE INDEX docstore_jsonb_docs_idx
  ON sioseb.docstore_jsonb
  USING gin
  (docs);

--Query returned successfully with no result in 161451 ms.
CLUSTER sioseb.docstore_jsonb USING docstore_jsonb_geom_idx;

--Query returned successfully with no result in 816 ms.
ANALYZE sioseb.docstore_jsonb;
$literal$;

EXECUTE script;

END
$BODY$ 
LANGUAGE plpgsql;

