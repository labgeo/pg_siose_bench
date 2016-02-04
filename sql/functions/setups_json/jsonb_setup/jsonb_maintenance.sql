--Query returned successfully with no result in 7776 ms.
VACUUM;
--Query returned successfully with no result in 161451 ms.
CLUSTER siose.docstore_jsonb USING docstore_jsonb_geom_idx;
--Query returned successfully with no result in 816 ms.
ANALYZE siose.docstore_jsonb;
