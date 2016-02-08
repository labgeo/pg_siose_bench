-- 3.1.1. Agrupación de coberturas por polígono.
WITH mapwindow AS(
	SELECT * 
	FROM siose.spain_grid_100k 
	WHERE gid=1
),
polygons AS(
	SELECT * 
	FROM siose.siose_polygons p, mapwindow 
	WHERE mapwindow.geom && p.geom
)
SELECT v.id_polygon, v.id_cover, SUM(v.area_perc) AS sum_area_perc ,SUM(v.area_ha) AS sum_area_ha
FROM siose.siose_values v, polygons p
WHERE v.id_polygon IN (p.id_polygon)
GROUP BY p.siose_code, v.id_polygon, v.id_cover;
