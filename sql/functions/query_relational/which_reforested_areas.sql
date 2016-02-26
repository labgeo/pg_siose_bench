CREATE OR REPLACE FUNCTION siose.which_reforested_areas()
  RETURNS void AS
$BODY$
  PREPARE q(geometry) AS
  SELECT p.id_polygon
  FROM siose.siose_polygons p JOIN siose.siose_values v USING(id_polygon)
  WHERE p.geom && $1 AND (v.attributes @> ARRAY[46] OR v.attributes @> ARRAY[40])
  GROUP BY p.id_polygon;
  SELECT siose.log_query_plans('which_reforested_areas');
$BODY$
  LANGUAGE sql VOLATILE;
