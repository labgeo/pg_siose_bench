--Query returned successfully with no result in 7535 ms.
VACUUM;

-- Query returned successfully with no result in 156142 ms.
CLUSTER siose.docstore_json USING docstore_json_geom_idx; 

--Query returned successfully with no result in 545 ms.
ANALYZE siose.docstore_json;
