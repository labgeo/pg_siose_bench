CREATE OR REPLACE FUNCTION siose.sum_area_of_coniferous_plantations()
  RETURNS void AS
$BODY$
  PREPARE q(geometry) AS
  SELECT SUM(v.area_ha)
  FROM siose.siose_polygons p JOIN siose.siose_values v USING(id_polygon)
  WHERE p.geom && $1 AND v.id_cover=316 AND v.attributes @> ARRAY[40];
  SELECT siose.log_query_plans('sum_area_of_coniferous_plantations');
$BODY$
  LANGUAGE sql VOLATILE;
