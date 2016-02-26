CREATE OR REPLACE FUNCTION siose.which_area_by_coverage()
  RETURNS void AS
$BODY$
  PREPARE q(geometry) AS
  WITH join_data AS (
    SELECT p.id_polygon, p.siose_code, c.cover_code,
           siose.attribute_code_lookup(attributes) AS attribute_codes,
           v.area_ha, v.area_perc
    FROM siose.siose_polygons p JOIN siose.siose_values v USING(id_polygon)
    JOIN siose.siose_coverages AS c USING(id_cover)
    WHERE p.geom && $1
  ),
  replace_cover_code AS (
    SELECT id_polygon, siose_code,
           COALESCE (cover_code, attribute_codes[1]) AS id_cover,--Move A,R,I attribute codes to the cover_code column
           area_ha, area_perc
    FROM join_data
  )
  SELECT id_polygon, id_cover, sum(area_perc) AS sum_area_perc, sum(area_ha) AS sum_area_ha
  FROM replace_cover_code 
  GROUP BY id_polygon, siose_code, id_cover;
  SELECT siose.log_query_plans('which_area_by_coverage');
$BODY$
  LANGUAGE sql VOLATILE;

