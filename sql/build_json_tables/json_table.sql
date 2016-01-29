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


--Columns indexing and maintenance
--Query returned successfully with no result in 7575 ms.
ALTER TABLE siose.docstore_json ADD PRIMARY KEY (gid);

--Query returned successfully with no result in 29745 ms.
CREATE INDEX docstore_json_geom_idx
  ON siose.docstore_json
  USING gist
  (geom);


--Query returned successfully with no result in 7535 ms.
VACUUM;

-- Query returned successfully with no result in 156142 ms.
CLUSTER siose.docstore_json USING docstore_json_geom_idx; 

--Query returned successfully with no result in 545 ms.
ANALYZE siose.docstore_json;
