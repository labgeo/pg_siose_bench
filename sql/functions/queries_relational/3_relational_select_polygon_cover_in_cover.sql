--3.2.4. Selección de polígonos que contengan una cobertura dentro de otra.
-- 111 - Otras construcciones
-- 912 - Conducciones y canales
WITH mapwindow AS(
	SELECT * 
	FROM siose.spain_grid_500k 
	WHERE gid = 19
),
polygons AS(
	SELECT * 
	FROM siose.siose_polygons p, mapwindow 
	WHERE mapwindow.geom && p.geom
)

SELECT DISTINCT v.id_polygon
FROM siose.siose_values v, polygons p
WHERE v.id_polygon IN (p.id_polygon) AND v.id_cover=111 AND v.id_parents @> ARRAY[912];


