
CREATE OR REPLACE FUNCTION siose.which_coniferous_patches()
  RETURNS void AS
$BODY$
  PREPARE q(geometry) AS
  SELECT p.id_polygon
  FROM siose.siose_polygons p JOIN siose.siose_values v USING(id_polygon)
  WHERE p.geom && $1 AND v.id_cover = 316
  GROUP BY p.id_polygon;
  SELECT siose.log_query_plans('which_coniferous_patches');
$BODY$
  LANGUAGE sql VOLATILE;

