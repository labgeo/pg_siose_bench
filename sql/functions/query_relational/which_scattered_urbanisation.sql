
CREATE OR REPLACE FUNCTION relational.which_scattered_urbanisation()
  RETURNS void AS
$BODY$

DECLARE
script text;

BEGIN

script:= $literal$

  PREPARE q(geometry) AS
  SELECT p.id_polygon
  FROM relational.siose_polygons p JOIN relational.siose_values v USING(id_polygon)
  WHERE p.geom && $1 AND v.id_cover = 101 AND v.id_parents @> ARRAY[813]
  GROUP BY p.id_polygon;
  SELECT reports.log_query_plans('relational.which_scattered_urbanisation()');
$literal$;


EXECUTE script;

END
$BODY$ LANGUAGE plpgsql;
