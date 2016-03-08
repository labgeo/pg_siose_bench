
CREATE OR REPLACE FUNCTION siose.which_large_coniferous_patches()
  RETURNS void AS
$BODY$


DECLARE
script text;

BEGIN

script:= $literal$


  PREPARE q(geometry) AS
  SELECT p.id_polygon
  FROM siose.siose_polygons p JOIN siose.siose_values v USING(id_polygon)
  WHERE p.geom && $1 AND v.id_cover=316 AND v.area_ha > 1
  GROUP BY p.id_polygon;
  SELECT reports.log_query_plans('relational.which_large_coniferous_patches()');
$literal$;


EXECUTE script;

END
$BODY$ LANGUAGE plpgsql;
