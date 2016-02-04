--Query returned successfully with no result in 29745 ms.
CREATE INDEX IF NOT EXISTS docstore_json_geom_idx
  ON siose.docstore_json
  USING gist
  (geom);
