--Query returned successfully with no result in 29828 ms.
CREATE INDEX IF NOT EXISTS docstore_jsonb_geom_idx
  ON siose.docstore_jsonb
  USING gist
  (geom);



CREATE INDEX docstore_jsonb_docs_idx
  ON siose.docstore_jsonb
  USING gin
  (docs);
