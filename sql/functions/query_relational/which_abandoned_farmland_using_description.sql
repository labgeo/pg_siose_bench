
CREATE OR REPLACE FUNCTION siose.which_abandoned_farmland_using_description()
  RETURNS void AS
$BODY$


DECLARE
script text;

BEGIN

script:= $literal$


  PREPARE q(geometry) AS
  WITH lookup AS (
  SELECT p.id_polygon,
         c.cover_desc,
         siose.attribute_description_lookup(v.attributes) AS attribute_desc
  FROM siose.siose_polygons p JOIN siose.siose_values v USING(id_polygon)
  JOIN siose.siose_coverages AS c USING(id_cover)
  WHERE p.geom && (SELECT geom FROM siose.spain_grid_100k WHERE gid=50)
  )
  SELECT id_polygon FROM lookup WHERE cover_desc = 'Matorral' AND attribute_desc @> ARRAY['procedencia de cultivos'] 
  GROUP BY 1;  
  SELECT reports.log_query_plans('which_abandoned_farmland_using_description');
$literal$;


EXECUTE script;

END
$BODY$ LANGUAGE plpgsql;

