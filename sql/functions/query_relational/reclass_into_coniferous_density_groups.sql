
CREATE OR REPLACE FUNCTION relational.reclass_into_coniferous_density_groups()
  RETURNS void AS
$BODY$

DECLARE
script text;

BEGIN

script:= $literal$

  PREPARE q(geometry) AS
  SELECT densclas AS density_classification, COUNT(densclas) AS patches, SUM(sum) AS area_ha FROM 
  ((SELECT p.id_polygon, '1.- Low density' AS densclas, SUM(v.area_ha)
  FROM relational.siose_polygons p JOIN relational.siose_values v USING(id_polygon)
  WHERE p.geom && $1 AND v.id_cover = 316
  AND v.area_perc BETWEEN 0 AND 25
  GROUP BY p.id_polygon)

  UNION ALL

  (SELECT p.id_polygon, '2.- Medium density' AS densclas, SUM(v.area_ha)
  FROM relational.siose_polygons p JOIN relational.siose_values v USING(id_polygon)
  WHERE p.geom && $1 AND v.id_cover = 316
  AND v.area_perc BETWEEN 25 AND 50
  GROUP BY p.id_polygon)

  UNION ALL

  (SELECT p.id_polygon, '3.- High density' AS densclas, SUM(v.area_ha)
  FROM relational.siose_polygons p JOIN relational.siose_values v USING(id_polygon)
  WHERE p.geom && $1 AND v.id_cover = 316
  AND v.area_perc BETWEEN 50 AND 75
  GROUP BY p.id_polygon)

  UNION ALL

  (SELECT p.id_polygon, '4.- Very high density' AS densclas, SUM(v.area_ha)
  FROM relational.siose_polygons p JOIN relational.siose_values v USING(id_polygon)
  WHERE p.geom && $1 AND v.id_cover = 316
  AND v.area_perc BETWEEN 75 AND 100
  GROUP BY p.id_polygon)) AS reclass

  GROUP BY densclas
  ORDER BY density_classification ASC;

  SELECT reports.log_query_plans('relational.reclass_into_coniferous_density_groups()');

$literal$;

EXECUTE script;

END
$BODY$ LANGUAGE plpgsql;

