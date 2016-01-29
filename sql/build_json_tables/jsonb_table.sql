-- Query returned successfully: 2477593 rows affected, 2149777 ms execution time.
CREATE TABLE siose.docstore_jsonb AS(
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

--Query returned successfully with no result in 29828 ms.
CREATE INDEX docstore_jsonb_geom_idx
  ON siose.docstore_jsonb
  USING gist
  (geom);

--Query returned successfully with no result in 7776 ms.
VACUUM;
--Query returned successfully with no result in 161451 ms.
CLUSTER siose.docstore_jsonb USING docstore_jsonb_geom_idx;
--Query returned successfully with no result in 816 ms.
ANALYZE siose.docstore_jsonb;
