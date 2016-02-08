--3.2.1. Selección de polígonos por una única cobertura.
-- 316 - Coniferas
WITH mapwindow AS(
	SELECT * 
	FROM siose.spain_grid_100k 
	WHERE gid = 1
),
polygons AS(
	SELECT * 
	FROM siose.siose_polygons p, mapwindow 
	WHERE mapwindow.geom && p.geom
)

SELECT DISTINCT v.id_polygon
FROM siose.siose_values v, polygons p
WHERE v.id_polygon IN (p.id_polygon) AND v.id_cover=316;
