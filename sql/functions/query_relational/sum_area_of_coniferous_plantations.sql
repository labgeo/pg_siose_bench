
CREATE OR REPLACE FUNCTION relational.sum_area_of_coniferous_plantations()
  RETURNS void AS
$BODY$


DECLARE
script text;

BEGIN

script:= $literal$


  PREPARE q(geometry) AS
  SELECT SUM(v.area_ha)
  FROM relational.siose_polygons p JOIN relational.siose_values v USING(id_polygon)
  WHERE p.geom && $1 AND v.id_cover=316 AND v.attributes @> ARRAY[40];
  SELECT reports.log_query_plans('relational.sum_area_of_coniferous_plantations()');

$literal$;


EXECUTE script;

END
$BODY$ LANGUAGE plpgsql;
