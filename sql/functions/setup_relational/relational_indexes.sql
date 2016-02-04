--Index on polygons
CREATE INDEX siose_polygons_id_polygon_idx
  ON siose.siose_polygons
  USING btree
  (id_polygon COLLATE pg_catalog."default");

--Index on values
CREATE INDEX siose_values_inter_id_idx_nulls_low
  ON siose.siose_values
  USING btree
  (inter_id NULLS FIRST);


CREATE INDEX siose_values_id_polygon_idx
  ON siose.siose_values
  USING btree
  (id_polygon COLLATE pg_catalog."default");


CREATE INDEX siose_values_id_cover_idx
  ON siose.siose_values
  USING btree
  (id_cover);


--Index array columns
CREATE INDEX siose_values_id_parents_idx on siose.siose_values USING GIN (id_parents);
CREATE INDEX siose_values_inter_parents_idx on siose.siose_values USING GIN (inter_parents);
CREATE INDEX siose_values_attributes_idx on siose.siose_values USING GIN (attributes);
