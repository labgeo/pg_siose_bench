
CREATE OR REPLACE FUNCTION siose.which_scattered_urbanisation()
  RETURNS void AS
$BODY$
  PREPARE q(geometry) AS
  SELECT p.id_polygon
  FROM siose.siose_polygons p JOIN siose.siose_values v USING(id_polygon)
  WHERE p.geom && $1 AND v.id_cover = 101 AND v.id_parents @> ARRAY[813]
  GROUP BY p.id_polygon;
  SELECT siose.log_query_plans('which_scattered_urbanisation');
$BODY$
  LANGUAGE sql VOLATILE;

