-- 3.1.1. Agrupación de coberturas por polígono.
WITH mapwindow AS(
	SELECT * 
	FROM siose.spain_grid_1m 
	WHERE gid=12
),
polygons AS(
	SELECT * 
	FROM siose.siose_polygons p, mapwindow 
	WHERE mapwindow.geom && p.geom
),
join_data AS (

	SELECT
		sp.id_polygon,
		siose_code,

		cover_code,
		siose.table_lookup(attributes,'siose.siose_attributes'::regclass, 'id_attribute','attribute_code') AS attribute_codes,

		area_ha,
		area_perc

	FROM polygons AS sp

	JOIN siose.siose_values AS sv ON sp.id_polygon=sv.id_polygon
	JOIN siose.siose_coverages AS sc ON sc.id_cover=sv.id_cover
),
replace_cover_code AS (
	SELECT
		id_polygon,
		COALESCE (cover_code, attribute_codes[1]) AS id_cover,--Put A,R,I attribute codes in the cover_code column
		area_ha,
		area_perc
	FROM join_data
)
SELECT r.id_polygon, id_cover, SUM(area_perc) AS sum_area_perc ,SUM(area_ha) AS sum_area_ha
FROM replace_cover_code r, polygons p
WHERE r.id_polygon IN (p.id_polygon)
GROUP BY r.id_polygon, siose_code, id_cover;
